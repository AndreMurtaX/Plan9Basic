#!/usr/bin/env python3
r"""Does the website still say what is true about the engine?

Three claims drift, because nothing forces the pages to agree with the code or
with each other. All three had drifted when a reader pointed it out: the home
page advertised 300+ functions while the library guide said 600+ and the real
number was over four thousand; one page footer still read v1.0; and several
pages named macOS and iOS as supported platforms.

The last one is the reason this file exists rather than a one-off correction.
The project has never been built for macOS or iOS -- they compile and have never
been linked, for want of an SDK -- so the site was promising something nobody
had ever run. A count being stale is untidy. A platform claim being wrong is a
person downloading a repository to build something that will not build.

WHAT IS CHECKED

  * The version. Every version string outside a code sample must match
    UnitMain.pas. Code samples are excluded because `form_caption#(frm#,
    "My Application v1.0")` is a caption, not a claim -- a reviewer reading
    text alone flagged exactly that as a defect.

  * The function count. A claim of the form "N+ functions" must not exceed what
    the libraries register, and must not be so far below it as to be stale.
    What the libraries register is asked of git, not of the disk: Libs/AI/archive
    holds seven superseded sources nobody builds, and counting those reports 41
    functions that do not exist.

  * The exact number the home page's boot animation counts out loud, which is
    not a "N+" and so goes stale on its own schedule. It read 3648.

  * The platforms, and this one is matched by SHAPE rather than by keyword.
    Searching the pages for the word "macOS" finds it dozens of times and
    almost every one is legitimate -- a table of per-OS configuration paths, a
    per-control support matrix, BASIC that branches on PLATFORM$, a note about
    how wide Extended is on each target. An allow-list for those would need
    curating forever, and a check that needs curating is a check that gets
    switched off.

    What went wrong had a shape instead: a LIST of platforms in prose, of the
    form "Windows, macOS, Linux, Android, and iOS", telling a reader where the
    project runs. That is what is matched here, along with a claim of a number
    of platforms. Tables that describe what FireMonkey does on a given OS are
    left alone; they are statements about a control, not a promise of a build.
"""
import io
import os
import re
import subprocess
import sys

#The pages carry arrows and dashes that a cp1252 console cannot print, and a
#check that dies while reporting a finding is worse than one that finds nothing.
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SITE = os.path.join(ROOT, 'Website')
IDE = os.path.join(ROOT, 'UnitMain.pas')

#Platforms the project is built and tested for. Adding one here is a promise;
#make the build first.
SHIPPING = ('Windows', 'Linux', 'Android')

#Names that can appear in a platform list. A list in prose that mentions one of
#the last two is claiming somewhere the project has never been built.
KNOWN = ('Windows', 'Linux', 'Android', 'macOS', 'OSX', 'iOS')
UNSHIPPED = ('macOS', 'OSX', 'iOS')

#A run of at least three platform names separated by commas, with an optional
#"and" before the last -- the shape of a sentence telling somebody where this
#runs.
PLATFORM_LIST = re.compile(
    r'\b(?:' + '|'.join(KNOWN) + r')\b'
    r'(?:\s*,\s*(?:and\s+)?(?:' + '|'.join(KNOWN) + r')\b){2,}')

#The home page's fake boot sequence counts the functions out loud. It is an
#exact number rather than a "4,000+", so it goes stale on its own schedule --
#it was reading 3648 while the libraries registered 4374.
BOOT_COUNT = re.compile(r'Registering functions[.\s]*(\d+)\s*ready')

#"six platforms", "all 6 platforms"
PLATFORM_COUNT = re.compile(r'\b(?:all\s+)?(\d+|six|five|four)\s+platforms\b', re.I)
WORD_NUM = {'four': 4, 'five': 5, 'six': 6}


def read(p):
    return open(p, encoding='utf-8', errors='replace').read()


def strip_code(html):
    """Remove <pre> blocks, so a version inside a sample is not read as a claim."""
    return re.sub(r'<pre\b.*?</pre>', ' ', html, flags=re.S | re.I)


def pages():
    for base, dirs, files in os.walk(SITE):
        dirs[:] = [d for d in dirs if not d.startswith('.')]
        for f in sorted(files):
            if f.endswith('.html'):
                yield os.path.join(base, f)


def engine_version():
    m = re.search(r"VERSION\s*=\s*'([^']+)'", read(IDE))
    return m.group(1) if m else None


def registered_count():
    """How many functions the shipping libraries register.

    Asked of git rather than of the disk. Walking the filesystem counts
    Libs/AI/archive, seven superseded sources nobody builds, and reports 41
    functions that do not exist -- so the number printed here would depend on
    which dead files a given machine happens to be carrying. check-pages.py
    learned the same lesson from the other direction: it judged staleness from
    the filesystem and passed in CI, where the files it was looking for were
    simply absent.
    """
    out = subprocess.run(['git', 'ls-files', '--', 'engine/Libs', 'Libs'],
                         cwd=ROOT, capture_output=True, text=True)
    if out.returncode != 0:
        return None
    n = 0
    for rel in out.stdout.split():
        if rel.endswith('.pas'):
            n += len(re.findall(r"Lib\.Add\('",
                                read(os.path.join(ROOT, rel.replace('/', os.sep)))))
    return n


def scan(rel, html, version, total):
    """Every rule, applied to one page."""
    problems = []
    prose = strip_code(html)

    #--- version
    for v in set(re.findall(r'v(\d+\.\d+)', prose)):
        if not version.startswith(v):
            problems.append(f'{rel} says v{v}; the engine is {version}')

    #--- function count
    for claim in re.findall(r'([\d,]+)\+\s*(?:built-in\s+|core\s+)?functions',
                            prose, re.I):
        n = int(claim.replace(',', ''))
        #A per-library page legitimately says "18 functions". Only a
        #headline number is a claim about the whole surface.
        if n < 100:
            continue
        if n > total:
            problems.append(f'{rel} claims {claim}+ functions and only '
                            f'{total} are registered')
        elif n < total * 0.75:
            problems.append(f'{rel} claims {claim}+ functions and {total} '
                            f'are registered; the claim has gone stale')

    #--- the boot animation on the home page counts them out loud
    for m in BOOT_COUNT.finditer(prose):
        if int(m.group(1)) != total:
            problems.append(f'{rel} boots with "{m.group(0)}" and {total} '
                            f'are registered')

    #--- platforms
    for m in PLATFORM_LIST.finditer(prose):
        named = [w for w in UNSHIPPED if re.search(r'\b' + w + r'\b', m.group(0))]
        if named:
            problems.append(f'{rel} lists {", ".join(named)} among the '
                            f'platforms it runs on: "{m.group(0)}"')
    for m in PLATFORM_COUNT.finditer(prose):
        raw = m.group(1).lower()
        n = WORD_NUM.get(raw, int(raw) if raw.isdigit() else 0)
        if n > len(SHIPPING):
            problems.append(f'{rel} claims {m.group(0)}; the project is '
                            f'built for {len(SHIPPING)}')

    return problems


#A page that breaks all four rules at once, scanned on every run.
#
#The rules are regexes, and a regex that has quietly stopped matching reports a
#clean site forever. That is not hypothetical: the word boundaries in the two
#platform patterns were once written as literal backspace characters, which no
#HTML page contains, so neither rule could match anything. The check passed
#while three pages named macOS, and it would have gone on passing. A clean
#result only means something if the rules are known to still fire.
CANARY_PAGE = (
    '<p>Version v0.1 of the interpreter, with 999999+ functions, runs on '
    'Windows, macOS, Linux, Android, and iOS &mdash; all 6 platforms.</p>'
    '<p>Registering functions........ 1 ready</p>')
CANARY_RULES = 5


def main():
    version = engine_version()
    if not version:
        print('  cannot find VERSION in UnitMain.pas; this check has stopped '
              'checking anything')
        return 1
    total = registered_count()
    if total is None:
        print('  git will not list the library sources; this check has stopped '
              'checking anything')
        return 1

    fired = scan('<canary>', CANARY_PAGE, version, total)
    if len(fired) < CANARY_RULES:
        print(f'  the canary page should break {CANARY_RULES} rules and broke '
              f'{len(fired)}; this check has stopped checking')
        for f in fired:
            print(f'    fired: {f}')
        return 1

    problems = []
    for p in pages():
        rel = os.path.relpath(p, SITE).replace(os.sep, '/')
        problems += scan(rel, read(p), version, total)

    for p in problems:
        print(f'  {p}')
    if problems:
        print(f'\n{len(problems)} claim(s) the site makes that the code does not '
              f'support.')
        return 1

    print(f'ok  the site agrees with the code: v{version}, {total} registered '
          f'function(s), and {"/".join(SHIPPING)} as the platforms')
    return 0


if __name__ == '__main__':
    sys.exit(main())
