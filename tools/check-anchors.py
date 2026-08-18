#!/usr/bin/env python3
"""
check-anchors.py - resolves every in-page fragment on the website.

check-links.py answers whether a link reaches a file. This answers the other
half: whether the `#section` on the end of it names anything once you arrive.
A fragment that names nothing does not fail — the browser silently leaves the
reader at the top of the page, which is worse than an error, because nobody
reports it.

Fragments the page builds at run time are skipped. The site writes

    href="...#'+e.target.id+'"

inside a script, and that is JavaScript concatenation, not a fragment. It was
read as one on the first attempt at this, and is the fourth time in this project
that scanning without parsing has taken code for content.

    python tools/check-anchors.py     report fragments that name nothing
"""
import re
import sys
import glob
import os
from collections import defaultdict

ROOT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                    'Website')

# The scheme carries its colon. Without it, 'httplib.html'.startswith('http')
# is true and the checker skips the very page it is meant to examine.
EXTERNAL = ('http://', 'https://', 'mailto:', 'data:', 'tel:', '//')

ANCHORED = re.compile(r'href="([^"]*#[^"]+)"')
ID = re.compile(r'\bid="([^"]+)"')
NAME = re.compile(r'\bname="([^"]+)"')


def norm(path):
    return path.replace(os.sep, '/')


def main():
    pages = sorted(glob.glob(os.path.join(ROOT, '**', '*.html'), recursive=True))

    text, ids = {}, {}
    for path in pages:
        rel = norm(os.path.relpath(path, ROOT))
        with open(path, encoding='utf-8', errors='replace') as f:
            text[rel] = f.read()
        ids[rel] = set(ID.findall(text[rel])) | set(NAME.findall(text[rel]))

    dangling, checked = defaultdict(set), 0
    for rel, body in text.items():
        base = os.path.dirname(rel)
        for written in ANCHORED.findall(body):
            path, frag = written.split('#', 1)
            if path.startswith(EXTERNAL) or '${' in written or "'" in frag:
                continue
            landing = rel if not path else norm(os.path.normpath(os.path.join(base, path)))
            if landing not in ids:
                continue            # an unresolved link is check-links.py's report
            checked += 1
            if frag not in ids[landing]:
                dangling[(landing, frag)].add(rel)

    if not dangling:
        print(f'{checked} fragment(s) across {len(pages)} page(s), '
              f'all name something')
        return 0

    print(f'{checked} fragment(s), {len(dangling)} naming nothing:\n')
    for (landing, frag), srcs in sorted(dangling.items(), key=lambda kv: -len(kv[1])):
        print(f'  {len(srcs):3}x  {landing}#{frag}')
        print(f'        written by {", ".join(sorted(srcs)[:2])}'
              f'{" and others" if len(srcs) > 2 else ""}')
    return 1


if __name__ == '__main__':
    sys.exit(main())
