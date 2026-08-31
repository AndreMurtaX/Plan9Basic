#!/usr/bin/env python3
"""Do the download buttons point at a release that exists, and is it this one?

check-site-claims.py holds what the pages SAY to the code -- the version, the
function counts, the platforms. It would pass a page whose download buttons led
nowhere, and that was not hypothetical: between the commit that added them and
the upload that published them, downloads.html offered four files that returned
404 to anyone who clicked.

Two halves, deliberately.

OFFLINE, and this is what runs in the suite. Every download link must have the
shape /releases/latest/download/<name>, and <name> must be one this project
actually builds. The shape matters as much as the name: a link pinned to a tag
(/releases/download/v1.8.0/...) works today and rots at the next release, which
is the whole reason /latest/ was chosen -- the page is written once and never
edited again.

ONLINE, and only when asked for with --online. It talks to the GitHub API: the
newest release must carry every expected asset, must not be a draft or a
prerelease -- /releases/latest ignores both, so marking a release "prerelease"
because the version says BETA would silently break all four buttons -- and its
tag must be the version the engine reports.

The network half is opt-in for a reason this repository learned the hard way on
2026-08-31: one shipped example fetches images from a third-party host, that
host returned 503, and the whole suite went red for nineteen minutes over
somebody else's outage. A check that fails when GitHub hiccups teaches people to
ignore checks.

    python tools/check-release.py             the shape of the links
    python tools/check-release.py --online    and that the release is really there
"""
import json
import os
import re
import subprocess
import sys
import urllib.error
import urllib.request

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SITE = os.path.join(ROOT, 'Website')
IDE = os.path.join(ROOT, 'UnitMain.pas')

#The assets a release is expected to carry, and the platform each one is for.
#tools/release.py builds exactly these names; the site links to exactly these
#names; nothing else may appear in a download link.
ASSETS = {
    'Plan9Basic-Win64.exe': 'Windows 64-bit',
    'Plan9Basic-Win32.exe': 'Windows 32-bit',
    'Plan9Basic-Linux64': 'Linux 64-bit',
    'Plan9Basic-Android64.apk': 'Android 64-bit',
}

LATEST = re.compile(
    r'https://github\.com/([^/"]+)/([^/"]+)/releases/latest/download/([^"]+)')
#Any other releases URL that looks like a file: pinned to a tag, or to a
#release page that will not serve a download.
OTHER = re.compile(r'https://github\.com/[^"]*/releases/(?!latest/download/)[^"]*'
                   r'\.(?:exe|apk|zip|tar\.gz|dmg|deb)')


def pages():
    for base, dirs, files in os.walk(SITE):
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for f in sorted(files):
            if f.endswith('.html'):
                yield os.path.join(base, f)


def engine_version():
    m = re.search(r"VERSION\s*=\s*'([^']+)'",
                  open(IDE, encoding='utf-8', errors='replace').read())
    return m.group(1) if m else None


def repo_slug():
    """owner/repo, from the remote rather than from a constant here."""
    out = subprocess.run(['git', 'remote', 'get-url', 'origin'],
                         cwd=ROOT, capture_output=True, text=True)
    if out.returncode != 0:
        return None
    m = re.search(r'github\.com[:/]([^/]+)/([^/\s.]+)', out.stdout)
    return f'{m.group(1)}/{m.group(2)}' if m else None


def offline():
    problems = []
    seen = set()
    slugs = set()

    for p in pages():
        rel = os.path.relpath(p, SITE).replace(os.sep, '/')
        html = open(p, encoding='utf-8', errors='replace').read()

        for owner, repo, name in LATEST.findall(html):
            slugs.add(f'{owner}/{repo}')
            seen.add(name)
            if name not in ASSETS:
                problems.append(f'{rel} offers "{name}", which is not a file '
                                f'this project builds')

        for bad in OTHER.findall(html):
            problems.append(f'{rel} links a release file by a path that is not '
                            f'/releases/latest/download/: {bad}')

    if not seen:
        problems.append('no page offers a download at all; if that is intended, '
                        'this check has nothing left to hold')
    missing = set(ASSETS) - seen
    for name in sorted(missing):
        problems.append(f'nothing links {name} ({ASSETS[name]})')

    slug = repo_slug()
    for s in sorted(slugs):
        if slug and s.lower() != slug.lower():
            problems.append(f'a download points at {s}, but origin is {slug}')

    return problems, seen


def online(version):
    slug = repo_slug()
    if not slug:
        return ['cannot tell which repository this is; no origin remote']
    url = f'https://api.github.com/repos/{slug}/releases/latest'
    req = urllib.request.Request(url, headers={
        'User-Agent': 'plan9basic-check-release',
        'Accept': 'application/vnd.github+json'})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            rel = json.load(r)
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return ['the repository has no published release, so every download '
                    'link on the site is a 404']
        return [f'GitHub answered {e.code}; not treating that as a finding']
    except Exception as e:
        return [f'could not reach GitHub ({e}); not treating that as a finding']

    problems = []
    if rel.get('draft'):
        problems.append('the newest release is a draft')
    if rel.get('prerelease'):
        problems.append('the newest release is marked prerelease, and '
                        '/releases/latest ignores those -- every download '
                        'button on the site is a 404')

    tag = (rel.get('tag_name') or '').lstrip('vV')
    #The tag is 1.8.0 where the engine says 1.8 (BETA): compare what they share.
    want = re.match(r'[\d.]+', version or '')
    want = want.group(0).rstrip('.') if want else ''
    if want and not tag.startswith(want):
        problems.append(f'the newest release is tagged {rel.get("tag_name")} '
                        f'and the engine reports {version}')

    have = {a['name'] for a in rel.get('assets', [])}
    for name in sorted(set(ASSETS) - have):
        problems.append(f'the release carries no {name} ({ASSETS[name]})')

    return problems


def main():
    version = engine_version()
    if not version:
        print('  cannot find VERSION in UnitMain.pas; this check has stopped '
              'checking anything')
        return 1

    problems, seen = offline()
    if '--online' in sys.argv:
        problems += online(version)

    for p in problems:
        print(f'  {p}')
    if problems:
        print(f'\n{len(problems)} problem(s) with what the site offers to download')
        return 1

    where = 'and the release carries them' if '--online' in sys.argv else \
            '(the release itself is only checked with --online)'
    print(f'ok  {len(seen)} download link(s), all of the /releases/latest/ form, '
          f'{where}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
