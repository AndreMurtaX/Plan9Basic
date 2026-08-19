r"""Assemble exactly what belongs on the web server, into one directory.

The site is published by hand, over FTP. Nothing in this repository does it and
nothing recorded how, which is why 111 corrected files sat in Website/ for a
month looking finished while plan9basic.com served documentation for six HTTP
functions that do not exist.

This does not publish anything. It removes the judgement from the step that
does: instead of working out which of 124 pages changed, the answer is "upload
this directory". What it assembles is Website/ as git sees it, plus the files
the pages link to that git deliberately ignores -- the two ebooks, which live on
this disk and on the server and in no third place.

    python tools/package-site.py

Writes dist/site/ and a manifest beside it. --zip makes an archive instead of a
directory, for clients that prefer one upload. --out moves the destination.

It refuses to write a package that would take the site backwards: a page that
links to a file this machine does not have would upload as a broken link, so
that is an error here rather than a discovery in a browser.
"""
import argparse
import hashlib
import os
import shutil
import subprocess
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SITE = os.path.join(ROOT, 'Website')


def norm(p):
    return p.replace(chr(92), '/')


def tracked():
    """Website files git knows about, which are the ones review has seen."""
    res = subprocess.run(['git', 'ls-files', '-z', 'Website'],
                         capture_output=True, cwd=ROOT)
    return sorted(norm(p.decode('utf-8', 'replace'))
                  for p in res.stdout.split(chr(0).encode()) if p)


def ignored_present():
    """Website files git ignores that are sitting here anyway."""
    res = subprocess.run(['git', 'ls-files', '--others', '--ignored',
                          '--exclude-standard', '-z', 'Website'],
                         capture_output=True, cwd=ROOT)
    return sorted(norm(p.decode('utf-8', 'replace'))
                  for p in res.stdout.split(chr(0).encode()) if p)


def checker():
    """check-links as a module, so the two cannot disagree about the site."""
    import importlib.util
    spec = importlib.util.spec_from_file_location(
        'check_links', os.path.join(ROOT, 'tools', 'check-links.py'))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def linked_ignored():
    """Every file the pages link to that git ignores -- present here or not.

    The "or not" is the whole point, and the first version of this function
    missed it. It asked `git ls-files --others --ignored`, which only ever
    reports files that exist, so a linked file that had gone missing simply
    stopped being needed and the guard below could not fire. Moving an ebook out
    of the tree produced a package one file smaller and a report saying nothing
    was wrong -- a check incapable of failing, built the same day two others
    were fixed for exactly that.

    `git check-ignore` answers about paths rather than about files, so it works
    on one that is not there, which is the question actually being asked.
    """
    mod = checker()
    wanted = set(mod.published_but_untracked())          # linked and present

    # Links that do not resolve at all: some of those are the same content,
    # missing rather than merely untracked.
    _, broken = mod.scan(mod.every_file())
    paths = {mod.norm(os.path.join('Website', os.path.normpath(
        os.path.join(base, target)))) for base, target in broken}
    if paths:
        res = subprocess.run(['git', 'check-ignore', '-z', '--stdin'],
                             input=chr(0).encode().join(
                                 p.encode('utf-8') for p in sorted(paths)),
                             capture_output=True, cwd=ROOT)
        wanted |= {norm(p.decode('utf-8', 'replace'))
                   for p in res.stdout.split(chr(0).encode()) if p}
    return sorted(norm(p) for p in wanted)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--out', default=os.path.join(ROOT, 'dist', 'site'))
    ap.add_argument('--zip', action='store_true')
    args = ap.parse_args()

    files = tracked()
    if not files:
        print('no tracked files under Website/ -- is this a git checkout?')
        return 2

    needed = linked_ignored()
    missing = [p for p in needed
               if not os.path.exists(os.path.join(ROOT, p))]
    if missing:
        print(f'{len(missing)} file(s) the pages link to are not on this disk:')
        for p in missing:
            print(f'  {p}')
        print('\nuploading without them would publish a broken link.')
        return 1

    payload = files + needed
    out = os.path.abspath(args.out)

    if args.zip:
        dest = out + '.zip' if not out.endswith('.zip') else out
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        with zipfile.ZipFile(dest, 'w', zipfile.ZIP_DEFLATED) as z:
            for rel in payload:
                z.write(os.path.join(ROOT, rel), rel[len('Website/'):])
        total = os.path.getsize(dest)
    else:
        shutil.rmtree(out, ignore_errors=True)
        total = 0
        lines = []
        for rel in payload:
            src = os.path.join(ROOT, rel)
            dst = os.path.join(out, rel[len('Website/'):])
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy2(src, dst)
            size = os.path.getsize(src)
            total += size
            with open(src, 'rb') as f:
                digest = hashlib.sha256(f.read()).hexdigest()[:16]
            lines.append(f'{digest}  {size:>10}  {rel[len("Website/"):]}')
        with open(out + '.manifest.txt', 'w', encoding='utf-8',
                  newline='\n') as f:
            f.write('\n'.join(lines) + '\n')
        dest = out

    print(f'  {len(files)} tracked file(s)')
    if needed:
        print(f'  {len(needed)} linked file(s) git ignores, copied from this disk:')
        for p in needed:
            print(f'      {p}')
    print(f'\n{len(payload)} file(s), {total / 1048576:.1f} MB')
    print(f'ready to upload: {dest}')
    if not args.zip:
        print(f'checksums:       {out}.manifest.txt')
    print('\nthe server\'s document root is the contents of that directory, '
          'not the directory itself.')
    return 0


if __name__ == '__main__':
    sys.exit(main())
