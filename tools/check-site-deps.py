r"""Every plan9basic.com URL the product fetches must exist in the publish tree.

The website is not only documentation. The IDE downloads its translations and
its examples browser from it on first run, and four of the demo games download
their sounds. Those URLs live in Pascal and BASIC source, not in an href, so
check-links.py cannot see them: it reads pages.

That gap had teeth. On 2026-08-19, assets/devenv/ was moved out of Website/ for
being unreferenced -- no page links it, which was true -- and it holds
Translations.ini, which UnitMain.pas fetches on the first run of every fresh
installation. Publishing the tree in that state would have 404ed all of them,
silently, and nothing in the repository would have disagreed.

So this asks the question the other checkers cannot: for each URL the product
fetches, is the file there?

Server-only endpoints are named below rather than guessed at. An entry that
stops being referenced fails, so the list cannot rot into a comment.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SITE = os.path.join(ROOT, 'Website')

URL = re.compile(r'https?://(?:www\.)?plan9basic\.com/([A-Za-z0-9_./-]*)')

# Paths served by the host that are not files in this tree, and why.
#
# Empty since 2026-08-19. It held `api/examples.php`, a PHP endpoint whose
# source was never here, which is why an upload had to merge rather than
# replace. The Examples Browser now reads `api/examples.json`, a file in this
# tree, so the site is entirely files again and an upload can be an upload.
SERVER_ONLY = {}

# Build output carries copies of tracked sources; the originals are checked.
SKIP = ('Android64', 'Win64', 'Linux64', 'Win32', 'OSX64', 'dist', '__history')


def sources():
    for base, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in SKIP and not d.startswith('.')]
        for name in sorted(files):
            if name.lower().endswith(('.pas', '.dpr', '.bas', '.dproj')):
                yield os.path.join(base, name)


def main():
    wanted = {}
    for path in sources():
        try:
            text = open(path, encoding='utf-8', errors='replace').read()
        except OSError:
            continue
        for hit in URL.findall(text):
            # A URL written as a prefix in a comment ends at a directory.
            hit = hit.strip('/')
            if not hit:
                continue
            wanted.setdefault(hit, set()).add(os.path.relpath(path, ROOT))

    missing, ok, served = [], 0, []
    for path in sorted(wanted):
        full = os.path.join(SITE, *path.split('/'))
        if path in SERVER_ONLY:
            served.append(path)
        elif os.path.exists(full):
            ok += 1
        else:
            missing.append(path)

    for path in sorted(wanted):
        mark = ('MISSING' if path in missing else
                'server ' if path in served else 'ok     ')
        print(f'  {mark}  {path}')

    stale = sorted(set(SERVER_ONLY) - set(wanted))

    if missing:
        print(f'\n{len(missing)} URL(s) the product fetches are not in Website/:')
        for path in missing:
            print(f'\n  {path}')
            for who in sorted(wanted[path]):
                print(f'      fetched by {who}')
            print('      Publishing without it 404s for every user that asks.')
    for path in stale:
        print(f'\nFAIL  {path} is listed as server-only and nothing fetches it.')
        print('      Drop it from SERVER_ONLY so the list keeps describing the tree.')

    if missing or stale:
        return 1
    print(f'\nok  {ok} fetched path(s) present, {len(served)} served by the host')
    return 0


if __name__ == '__main__':
    sys.exit(main())
