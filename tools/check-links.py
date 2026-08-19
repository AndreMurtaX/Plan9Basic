#!/usr/bin/env python3
"""
check-links.py - resolves every internal link on the website.

The site is 124 pages that reference each other, and a page moved into a
subdirectory keeps whatever relative path it was written with. That is how the
"Language Reference" link in the navigation of all 64 effect pages came to point
at a file beside them which was never there.

Only links to files in the tree are checked. An external URL is somebody else's
to keep working, and a fragment is a position within a page rather than a page.

    python tools/check-links.py           report unresolved links
    python tools/check-links.py --fix     when the target name is unambiguous,
                                          rewrite the path to reach it
"""
import re
import sys
import glob
import os
import subprocess
import urllib.parse
from collections import defaultdict

ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                    'Website')

LINK = re.compile(r'(href|src)="([^"#?][^"]*)"')
EXTERNAL = ('http://', 'https://', 'mailto:', 'data:', 'tel:', '//')


def norm(path):
    return path.replace(os.sep, '/')


def every_file():
    return {norm(os.path.relpath(p, ROOT))
            for p in glob.glob(os.path.join(ROOT, '**', '*'), recursive=True)
            if os.path.isfile(p)}


def scan(files):
    """{(directory, written link): {pages that write it}} for links that miss."""
    broken = defaultdict(set)
    total = 0
    for path in sorted(glob.glob(os.path.join(ROOT, '**', '*.html'), recursive=True)):
        rel = norm(os.path.relpath(path, ROOT))
        base = os.path.dirname(rel)
        with open(path, encoding='utf-8', errors='replace') as f:
            text = f.read()
        for _, written in LINK.findall(text):
            target = written.split('#')[0].split('?')[0]
            # A template placeholder is filled in by script at load time and is
            # not a path yet.
            if not target or target.startswith(EXTERNAL) or '${' in target:
                continue
            total += 1
            if norm(os.path.normpath(os.path.join(base, target))) not in files:
                broken[(base, target)].add(rel)
    return total, broken


def ignored_by_git(paths):
    """
    Of these repository-relative paths, the ones git is told to ignore.

    Some link targets are deliberately absent from the tree. A clone cannot
    resolve them, and calling that a failure would make this check useless to
    everyone but the machine with the untracked files sitting there.

    It used to be the download binaries and an archived library; both are gone,
    the first because the site stopped handing out binaries in 4.4. What is left
    is two PDFs under assets/ebooks/. See published_but_untracked(), which names
    them on every run rather than only where they break.

    NUL-separated in both directions, and bytes rather than text. On Windows a
    text-mode pipe rewrites the newlines being sent, so git receives every path
    but the last with a carriage return glued to it, matches anyway, and answers
    with a quoted name that no longer compares equal to what was asked.
    """
    if not paths:
        return set()
    try:
        res = subprocess.run(['git', 'check-ignore', '-z', '--stdin'],
                             input=b'\0'.join(p.encode('utf-8') for p in sorted(paths)),
                             capture_output=True,
                             cwd=os.path.dirname(ROOT))
    except OSError:
        return set()
    return {norm(p.decode('utf-8', 'replace'))
            for p in res.stdout.split(b'\0') if p}


def resolve(target, base, files):
    """The path from base that reaches target, when exactly one file bears its name."""
    name = os.path.basename(target)
    matches = [f for f in files if os.path.basename(f) == name]
    if len(matches) != 1:
        return None
    return norm(os.path.relpath(matches[0], base or '.'))


def published_but_untracked():
    """Files the pages link to that git ignores, and this machine happens to have.

    These are the ones the check is quietest about, and they are the ones worth
    saying out loud. A target git ignores resolves here, because the file is
    sitting in the working tree, and resolves nowhere else -- so the run reports
    "all resolve" on the one machine that cannot discover the problem, and lists
    them only on a clone, where nobody is looking.

    They are not defects. They are content that exists on this disk and on the
    server and in no other place, which is worth knowing before anything decides
    the repository is the site.
    """
    try:
        res = subprocess.run(['git', 'ls-files', '--others', '--ignored',
                              '--exclude-standard', '-z', 'Website'],
                             capture_output=True, cwd=os.path.dirname(ROOT))
    except OSError:
        return []
    on_disk = {norm(p.decode('utf-8', 'replace'))
               for p in res.stdout.split(chr(0).encode()) if p}
    if not on_disk:
        return []

    # Matched through LINK rather than by searching the page text, or a file
    # merely named in prose counts as linked: downloads.html discusses
    # Translations.ini and Plan9Basic.exe at length and points at neither.
    #
    # every_file() answers relative to ROOT, and an href arrives percent-encoded,
    # so both have to be undone before comparing. The first attempt did neither
    # and reported nothing, the OSError swallowed by the guard below.
    names = {os.path.basename(p): p for p in on_disk}
    hit = set()
    for page in every_file():
        if not page.lower().endswith(('.html', '.htm')):
            continue
        try:
            with open(os.path.join(ROOT, page), encoding='utf-8',
                      errors='replace') as f:
                text = f.read()
        except OSError:
            continue
        for _, written in LINK.findall(text):
            # An absolute URL is not a path into this tree, and its last segment
            # collides readily: the repository link ends in "Plan9Basic", which
            # is exactly the name of the Linux binary.
            if written.startswith(EXTERNAL) or '${' in written:
                continue
            target = written.split('#')[0].split('?')[0]
            name = os.path.basename(urllib.parse.unquote(target))
            if name in names:
                hit.add(names[name])
    return sorted(hit)


def main():
    fix = '--fix' in sys.argv
    files = every_file()
    total, broken = scan(files)

    # Split off the targets git is told to ignore before judging anything.
    wanted = {norm(os.path.join('Website', os.path.normpath(os.path.join(base, target))))
              for base, target in broken}
    ignored = ignored_by_git(wanted)
    deploy, real = {}, {}
    for key, pages in broken.items():
        base, target = key
        full = norm(os.path.join('Website', os.path.normpath(os.path.join(base, target))))
        (deploy if full in ignored else real)[key] = pages

    if deploy:
        print(f'{sum(len(v) for v in deploy.values())} link(s) point at paths git '
              f'ignores, produced at deploy time:')
        for (base, target), pages in sorted(deploy.items()):
            print(f'  {len(pages):3}x  "{target}"')
        print()

    # Said on every run, not only where they fail, because the machine that has
    # these files is the machine that would otherwise never hear about them.
    untracked = published_but_untracked()
    if untracked:
        size = sum(os.path.getsize(p) for p in untracked if os.path.exists(p))
        print(f'{len(untracked)} linked file(s) git ignores, present here and '
              f'nowhere the repository can see ({size / 1048576:.0f} MB):')
        for p in untracked:
            print(f'  {p}')
        print()

    if not real:
        print(f'{total} internal link(s), all resolve')
        return 0
    broken = real

    print(f'{total} internal link(s), {sum(len(v) for v in broken.values())} '
          f'unresolved across {len(broken)} distinct path(s)\n')

    fixed = 0
    for (base, target), pages in sorted(broken.items(), key=lambda kv: -len(kv[1])):
        good = resolve(target, base, files)
        where = f'{base}/' if base else './'
        print(f'  {len(pages):3}x  {where}  "{target}"')
        if good:
            print(f'        reaches it as  "{good}"')
        else:
            print('        no single file bears that name')
        if fix and good:
            for page in pages:
                path = os.path.join(ROOT, page)
                with open(path, encoding='utf-8', errors='replace', newline='') as f:
                    src = f.read()
                new = (src.replace(f'href="{target}"', f'href="{good}"')
                          .replace(f'src="{target}"', f'src="{good}"')
                          .replace(f'href="{target}#', f'href="{good}#'))
                if new != src:
                    with open(path, 'w', encoding='utf-8', newline='') as f:
                        f.write(new)
                    fixed += 1

    if fix:
        print(f'\nrewrote {fixed} page(s); run again to confirm')
        return 0
    return 1


if __name__ == '__main__':
    sys.exit(main())
