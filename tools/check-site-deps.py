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

# The version the IDE prints, and the pages that state it to a reader.
#
# On 2026-08-20 the engine had been 1.8 (BETA) for some time and every page
# still said v1.0. Nobody noticed because nothing compares them: check-docs.py
# holds signatures to code and check-event-docs.py holds event shapes, and a
# number in prose has no such guard. A reader deciding whether the page in front
# of them describes the thing they installed has only this to go on.
VERSION_IN_CODE = re.compile(r"VERSION\s*=\s*'([^']+)'")
VERSION_ON_PAGE = re.compile(r'v(\d+\.\d+(?:\.\d+)?(?: \(BETA\))?)')
VERSION_PAGES = [
    ('index.html', 3),                      # boot banner, badge, boot animation
    (os.path.join('docs', 'language-reference.html'), 1),
]


# utils/Translations.ini is the source; the IDE downloads
# Website/assets/devenv/Translations.ini on a fresh install. Two copies of one
# file, and nothing kept them equal: on 2026-08-21 the picker's catalogue row
# read "FilePickerExamplesRow" on screen, because a missing key falls back to
# its own name and the copy beside the executable was a line behind.
#
# The build output copies -- bin/ and Win64/Release/ -- are not checked here:
# git ignores them, so a clone does not have them and this would fail for
# everybody but the person who last built.
TRANSLATION_COPIES = [
    os.path.join('utils', 'Translations.ini'),
    os.path.join('Website', 'assets', 'devenv', 'Translations.ini'),
]


def translations_agree():
    """Every tracked copy of Translations.ini is the same file."""
    texts = {}
    for rel in TRANSLATION_COPIES:
        path = os.path.join(ROOT, rel)
        if not os.path.exists(path):
            print(f'FAIL  {rel} is missing')
            return 1
        with open(path, encoding='utf-8-sig', errors='replace') as f:
            texts[rel] = f.read().replace(chr(13), '')

    first = TRANSLATION_COPIES[0]
    bad = 0
    for rel in TRANSLATION_COPIES[1:]:
        if texts[rel] != texts[first]:
            a = set(texts[first].split(chr(10)))
            b = set(texts[rel].split(chr(10)))
            print(f'FAIL  {rel} differs from {first}')
            for line in sorted(a - b)[:5]:
                print(f'      only in {first}: {line.strip()}')
            for line in sorted(b - a)[:5]:
                print(f'      only in {rel}: {line.strip()}')
            print('      The IDE downloads the site copy on a fresh install, so a '
                  'key missing there shows on screen as its own name.')
            bad += 1
    if bad == 0:
        print(f'  strings  {len(TRANSLATION_COPIES)} copies of Translations.ini agree')
    return bad


def version_agrees():
    """The pages that state a version state the one the IDE prints."""
    src_path = os.path.join(ROOT, 'UnitMain.pas')
    with open(src_path, encoding='utf-8-sig', errors='replace') as f:
        m = VERSION_IN_CODE.search(f.read())
    if not m:
        print('FAIL  UnitMain.pas states no VERSION')
        return 1
    want = m.group(1)

    bad = 0
    for rel, expected in VERSION_PAGES:
        path = os.path.join(SITE, rel)
        if not os.path.exists(path):
            print(f'FAIL  {rel} is named as stating a version and is not there')
            bad += 1
            continue
        with open(path, encoding='utf-8-sig', errors='replace') as f:
            found = VERSION_ON_PAGE.findall(f.read())
        hits = [v for v in found if v == want]
        if len(hits) != expected:
            print(f'FAIL  {rel} states v{want} {len(hits)} time(s), expected '
                  f'{expected}')
            others = sorted({v for v in found if v != want})
            if others:
                print(f'      it also says: {", ".join("v" + o for o in others)}')
            print(f'      The IDE prints {want}. A page that says otherwise tells '
                  f'a reader they are looking at something else.')
            bad += 1
    if bad == 0:
        print(f'  version  every page states v{want}, as the IDE does')
    return bad

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

    bad_version = version_agrees()
    bad_strings = translations_agree()

    if missing or stale or bad_version or bad_strings:
        return 1
    print(f'\nok  {ok} fetched path(s) present, {len(served)} served by the host')
    return 0


if __name__ == '__main__':
    sys.exit(main())
