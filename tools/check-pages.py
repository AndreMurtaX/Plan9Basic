#!/usr/bin/env python3
r"""Is the tree laid out the way GitHub Pages expects, and what would not survive.

PLAN 4.6 ends with the repository being the site: Pages serving `Website/`
directly, so publishing is a consequence of the push that already happens, and
the drift that let 111 corrected files sit unpublished for a month stops being
possible rather than becoming easier to fix.

The layout for that is committed and inert -- `CNAME`, `.nojekyll`, the
workflow -- because it can be reviewed while nothing depends on it.

What cannot be committed early is the part that has to change on the live site,
and this is the file that refuses to let it be forgotten. Pages serves **static
files, over GET**, and only what git tracks. Three consequences, all real today:

  * a PHP endpoint does not run
  * a POST is answered by nothing, so a static file is not a stand-in either
  * a file the pages link to but git ignores is a 404

So the two lists below are the state of the flip. They are not a to-do: they are
what is true, and this check fails when the tree stops matching them -- when a
new dynamic endpoint appears, or a new linked file is left out of git, or one of
these is settled and the record here is not.
"""
import os
import re
import subprocess
import sys
from urllib.parse import unquote

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SITE = os.path.join(ROOT, 'Website')
FLOW = os.path.join(ROOT, '.github', 'workflows', 'pages.yml')

#Referenced paths the host executes rather than serves. Pages runs nothing.
DYNAMIC = {
    'api/examples.php':
        'the Examples Browser applet POSTs to it for its catalogue. Pages '
        'answers no POST and runs no PHP, so this needs a static catalogue '
        'and an applet that GETs it',
}

#Linked from a page, present on this disk, and not in git. Pages serves what
#git tracks, so on Pages these are 404 until they are committed.
UNTRACKED = {
    'assets/ebooks/Computer Spacegames (1982)(Usborne Publishing).pdf':
        'linked from the story on the front page',
    'assets/ebooks/programas_de_jogos_espaciais.pdf':
        'linked from the story on the front page',
}

SELF = re.compile(r'https?://(?:www\.)?plan9basic\.com/([A-Za-z0-9_./%-]*)')
LOCAL = re.compile(r'(?:href|src)\s*=\s*["\']([^"\'#?]+)["\']', re.I)
EXECUTED = ('.php', '.cgi', '.asp', '.aspx', '.jsp')


def pages():
    for base, dirs, files in os.walk(SITE):
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for f in sorted(files):
            if f.endswith(('.html', '.htm')):
                yield os.path.join(base, f)


def sources():
    """Every file that could name a URL on this host."""
    skip = ('Android64', 'Win64', 'Linux64', 'Win32', 'OSX64', 'dist',
            '__history', '.git')
    for base, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in skip and not d.startswith('.')]
        for f in sorted(files):
            if f.lower().endswith(('.pas', '.dpr', '.bas', '.html', '.htm')):
                yield os.path.join(base, f)


def tracked_site():
    out = subprocess.run(['git', 'ls-files', 'Website'], cwd=ROOT,
                         capture_output=True, text=True)
    return {line.strip() for line in out.stdout.split('\n') if line.strip()}


def found_dynamic():
    """Referenced paths on this host that a server would have to execute."""
    hits = set()
    for path in sources():
        text = open(path, encoding='utf-8', errors='replace').read()
        for ref in SELF.findall(text):
            ref = unquote(ref).split('?')[0]
            if ref.lower().endswith(EXECUTED):
                hits.add(ref)
    return hits


def found_untracked(tracked):
    """Files a page links to that are on this disk and not in git."""
    hits = set()
    for page in pages():
        base = os.path.dirname(page)
        text = open(page, encoding='utf-8', errors='replace').read()
        for ref in LOCAL.findall(text):
            if '://' in ref or ref.startswith(('mailto:', 'data:', '//')):
                continue
            target = os.path.normpath(os.path.join(base, unquote(ref)))
            if not target.startswith(SITE) or not os.path.isfile(target):
                continue
            rel = os.path.relpath(target, SITE).replace(os.sep, '/')
            if 'Website/' + rel not in tracked:
                hits.add(rel)
    return hits


def main():
    problems = []

    #--- the layout, which is the half that could be committed early
    cname = os.path.join(SITE, 'CNAME')
    if not os.path.isfile(cname):
        problems.append('Website/CNAME is missing; Pages would serve the '
                        'github.io address and the domain would not follow')
    else:
        domain = open(cname, encoding='utf-8').read().strip()
        named = set()
        for page in pages():
            named |= set(re.findall(r'https?://(?:www\.)?([a-z0-9.-]*plan9basic\.com)',
                                    open(page, encoding='utf-8', errors='replace').read()))
        if named and domain not in named:
            problems.append(f'Website/CNAME says {domain} and the pages link to '
                            f'{", ".join(sorted(named))}')

    if not os.path.isfile(os.path.join(SITE, '.nojekyll')):
        problems.append('Website/.nojekyll is missing; Pages would run Jekyll '
                        'over the site and drop paths beginning with an underscore')

    if not os.path.isfile(FLOW):
        problems.append('.github/workflows/pages.yml is missing')
    else:
        flow = open(FLOW, encoding='utf-8').read()
        if not re.search(r'path:\s*Website\b', flow):
            problems.append('the workflow does not upload Website as the root')

    #--- the half that cannot be, and has to stay described accurately
    dyn = found_dynamic()
    for extra in sorted(dyn - set(DYNAMIC)):
        problems.append(f'{extra} is executed by the host and DYNAMIC does not '
                        f'name it, so the flip would break it silently')
    for gone in sorted(set(DYNAMIC) - dyn):
        problems.append(f'DYNAMIC still names {gone} and nothing references it; '
                        f'drop it so the list keeps describing the tree')

    tracked = tracked_site()
    unt = found_untracked(tracked)
    for extra in sorted(unt - set(UNTRACKED)):
        problems.append(f'{extra} is linked and not in git, and UNTRACKED does '
                        f'not name it; on Pages it is a 404')
    for gone in sorted(set(UNTRACKED) - unt):
        problems.append(f'UNTRACKED still names {gone} and it is either '
                        f'committed or no longer linked; drop it')

    for p in problems:
        print(f'  {p}')
    if problems:
        print(f'\n{len(problems)} problem(s) with the Pages layout.')
        return 1

    print(f'ok  the Pages layout is in place, and {len(DYNAMIC)} endpoint(s) and '
          f'{len(UNTRACKED)} linked file(s) still stand between it and the flip')
    return 0


if __name__ == '__main__':
    sys.exit(main())
