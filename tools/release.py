#!/usr/bin/env python3
r"""Build, verify and stage a release of the IDE.

The 1.8.0 release was assembled by hand on 2026-08-31, and none of what it took
was written down anywhere. Three things in particular were learned the hard way
and are encoded here so the next one does not have to learn them again:

  * Android's APK does not come from the Build target. `msbuild /t:Build` for
    Android64 compiles and links libPlan9Basic.so and stops -- no aapt, no
    packaging, exit code 0, and no .apk. The APK comes from /t:Deploy.

  * A build dirties the source tree. msbuild rewrites the default <Platform> in
    the .dproj to whatever was built last, and an Android build puts the
    attached device's serial back into .deployproj. Both are reverted here, so a
    release cannot arrive as an accidental commit.

  * The asset names are a contract. downloads.html points at
    /releases/latest/download/<name>, which is what lets the page stay unedited
    across releases -- so a renamed asset is a 404 on a page nobody thought to
    change. tools/check-release.py holds the same names from the other side.

Nothing here publishes. It builds, checks what it built, stages the files under
dist/ with the names the site expects, and prints the command to create the
release. Publishing is a decision, and it is not this script's to make.

    python tools/release.py                 build, verify and stage
    python tools/release.py --skip-build    verify and stage what is already built
"""
import hashlib
import io
import os
import re
import shutil
import struct
import subprocess
import sys
import zipfile

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'dist', 'release')
IDE = os.path.join(ROOT, 'UnitMain.pas')
RSVARS = r'C:\Program Files (x86)\Embarcadero\Studio\37.0\bin\rsvars.bat'

#platform, the target that produces the artifact, where it lands, the name the
#site asks for, and what the file must turn out to be.
TARGETS = [
    ('Win64', 'Build', r'Win64\Release\Plan9Basic.exe',
     'Plan9Basic-Win64.exe', 'pe', 'x86-64'),
    ('Win32', 'Build', r'Win32\Release\Plan9Basic.exe',
     'Plan9Basic-Win32.exe', 'pe', 'x86'),
    ('Linux64', 'Build', r'Linux64\Release\Plan9Basic',
     'Plan9Basic-Linux64', 'elf', 'x86-64'),
    #Deploy rather than Build: see the note at the top.
    ('Android64', 'Deploy', r'Android64\Release\Plan9Basic\bin\Plan9Basic.apk',
     'Plan9Basic-Android64.apk', 'apk', 'arm64-v8a'),
]

PE_MACHINE = {0x014c: 'x86', 0x8664: 'x86-64', 0xaa64: 'arm64'}
ELF_MACHINE = {0x03: 'x86', 0x3e: 'x86-64', 0xb7: 'arm64'}

DIRTIED = ['*.dproj', '*.deployproj', '*.res']


def version():
    m = re.search(r"VERSION\s*=\s*'([^']+)'",
                  io.open(IDE, encoding='utf-8', errors='replace').read())
    return m.group(1) if m else None


def build(platform, target):
    #shell=True, and the command as one string. Handing ['cmd', '/c', cmd] to
    #subprocess instead gets the argument quoted for it -- the string both
    #starts with a quote and contains spaces -- and cmd receives \"C:\Program
    #Files (x86)\...\rsvars.bat\", which it reports as not being a command.
    cmd = (f'call "{RSVARS}" && msbuild Plan9Basic.dproj /t:{target} '
           f'/p:Config=Release /p:Platform={platform} /v:minimal /nologo')
    res = subprocess.run(cmd, shell=True, cwd=ROOT, capture_output=True,
                         text=True, encoding='utf-8', errors='replace')
    return res.returncode, (res.stdout or '') + (res.stderr or '')


def arch_of(path, kind):
    data = open(path, 'rb').read()
    if kind == 'pe':
        off = struct.unpack_from('<I', data, 0x3c)[0]
        if data[off:off + 4] != b'PE\0\0':
            return None, data
        return PE_MACHINE.get(struct.unpack_from('<H', data, off + 4)[0]), data
    if kind == 'elf':
        if data[:4] != b'\x7fELF':
            return None, data
        return ELF_MACHINE.get(struct.unpack_from('<H', data, 0x12)[0]), data
    with zipfile.ZipFile(path) as z:
        names = z.namelist()
        abis = sorted({n.split('/')[1] for n in names
                       if n.startswith('lib/') and n.count('/') >= 2})
        #The version lives in the packaged library, not in the zip's own bytes,
        #and Delphi stores its strings as UTF-16.
        inner = b''
        for n in names:
            if n.startswith('lib/arm64-v8a/') and n.endswith('.so'):
                inner = z.read(n)
        signed = any(n.startswith('META-INF/') and
                     n.upper().endswith(('.RSA', '.DSA', '.EC')) for n in names)
    return (','.join(abis) if abis else None), (inner, signed)


def revert(label):
    dirty = subprocess.run(['git', 'status', '--porcelain', '--'] + DIRTIED,
                           cwd=ROOT, capture_output=True, text=True).stdout.strip()
    if dirty:
        print(f'  {label}: the build modified project files, reverting')
        for line in dirty.splitlines():
            print(f'      {line}')
        subprocess.run(['git', 'checkout', '--'] + DIRTIED, cwd=ROOT,
                       capture_output=True)


def main():
    want = version()
    if not want:
        print('  cannot find VERSION in UnitMain.pas')
        return 1
    print(f'Plan9Basic {want}')
    print()

    skip = '--skip-build' in sys.argv
    problems = []

    if not skip:
        if not os.path.exists(RSVARS):
            print(f'  RAD Studio is not where this expects it: {RSVARS}')
            return 1
        for platform, target, rel, _name, _kind, _arch in TARGETS:
            path = os.path.join(ROOT, rel)
            if os.path.exists(path):
                os.remove(path)
            code, log = build(platform, target)
            ok = code == 0 and os.path.exists(path)
            size = os.path.getsize(path) if os.path.exists(path) else 0
            print(f'  build {platform:10} {"ok " if ok else "FAILED"}  '
                  f'{size / 1048576:6.1f} MB')
            if not ok:
                problems.append(f'{platform} did not build ({rel} is not there)')
                for line in log.splitlines():
                    if re.search(r'\berror\b', line, re.I):
                        print(f'      {line.strip()[:150]}')
            revert(platform)
        print()

    #Clear the assets this script owns, and leave anything else -- the release
    #notes are written by hand and staged here, and deleting somebody's draft
    #because a build ran is not a thing a build script should do.
    os.makedirs(OUT, exist_ok=True)
    for _p, _t, _r, name, _k, _a in TARGETS:
        stale = os.path.join(OUT, name)
        if os.path.exists(stale):
            os.remove(stale)

    sums = []
    for _platform, _target, rel, name, kind, expect in TARGETS:
        path = os.path.join(ROOT, rel)
        if not os.path.exists(path):
            problems.append(f'{name}: nothing at {rel}')
            print(f'  {name:28} MISSING')
            continue

        got, extra = arch_of(path, kind)
        raw = open(path, 'rb').read()
        if kind == 'apk':
            inner, signed = extra
            has_version = want.encode('utf-16-le') in inner
            note = 'arm64-v8a, signed' if signed else 'arm64-v8a, UNSIGNED'
            if not signed:
                problems.append(f'{name} is not signed')
            #Not a failure, but worth saying out loud: the package still
            #carries stub libraries for armeabi, armeabi-v7a and mips, dated
            #March and built for architectures this project does not target.
            #mips has been dead since 2017.
            dead = [a for a in (got or '').split(',') if a and a != expect]
            if dead:
                note += f' (+{len(dead)} dead ABI: {", ".join(dead)})'
        else:
            has_version = (want.encode('utf-8') in extra or
                           want.encode('utf-16-le') in extra)
            note = got or 'unrecognised'

        if got is None or expect not in got:
            problems.append(f'{name}: expected {expect}, found {got}')
        if not has_version:
            problems.append(f'{name} does not carry the string "{want}"; '
                            f'it is probably from an older build')

        dst = os.path.join(OUT, name)
        shutil.copy2(path, dst)
        sha = hashlib.sha256(raw).hexdigest()
        sums.append(f'{sha}  {name}')
        print(f'  {name:28} {len(raw) / 1048576:6.1f} MB  {note:22} '
              f'version {"ok" if has_version else "MISSING"}')

    io.open(os.path.join(OUT, 'SHA256SUMS.txt'), 'w',
            encoding='utf-8', newline='\n').write('\n'.join(sums) + '\n')

    print()
    for p in problems:
        print(f'  {p}')
    if problems:
        print(f'\n{len(problems)} problem(s); nothing is fit to publish')
        return 1

    tag = 'v' + (re.match(r'[\d.]+', want).group(0).rstrip('.'))
    if tag.count('.') == 1:
        tag += '.0'
    files = ' '.join(f'dist/release/{n}' for _p, _t, _r, n, _k, _a in TARGETS)
    print(f'staged in dist/release, {len(TARGETS)} file(s) and SHA256SUMS.txt')
    print()
    print('  Nothing has been published. To publish, with the release notes')
    print('  written first and NOT marked prerelease -- /releases/latest')
    print('  ignores prereleases, and every download button on the site reads')
    print('  from /releases/latest:')
    print()
    print(f'    gh release create {tag} {files} \\')
    print(f'      --title "Plan9Basic {want}" --notes-file dist/release/RELEASE-NOTES.md')
    print()
    print('  Then: python tools/check-release.py --online')
    return 0


if __name__ == '__main__':
    sys.exit(main())
