#!/usr/bin/env python3
r"""The games the site hands out, against the games in the repository.

`Website/docs/examples.html` carries the source of every example inside itself,
in a JavaScript template literal, and that is what a reader copies. The
games also exist as files under `Demos/`. Two copies of the same program.

They drifted. The corrections of 2026-08 landed in `Demos/` and never in the
page: on 2026-08-19 the site was still handing out the three-parameter keyboard
handler of section 28 and twenty-three comparisons written for the contract
`instr` had before 1.1. The author copied `flappy_bird` from the site, ran it,
and its keyboard was dead -- from a defect the repository had already fixed.

So the two copies have to agree, and a check has to say so.

Only the nine games are paired that way. `calculator` exists in both places and
is two different programs that share a name, which is why the games pair by an
explicit list and not by matching filenames.

The same question is asked a second time, of two directories. `Examples/` and
`Website/assets/examples/` hold the same 98 programs under names differing only
by a leading number, and nothing has ever said which direction the copying runs.
`ChuckNorrisFacts_Demo.bas` had drifted: the site's copy was the older one,
without the dropdown's backing rectangle and still calling the two-parameter
`onitemclick` where the other had moved to `onchange`. The site's copy is the
one people download. It was named in section 1b of the analysis on the day it
was found, and stayed drifted until 2026-08-19.

Naming one canonical and generating the other would have worked too. Keeping
both and checking them is what this does, because the two are read by different
things -- one is the repository's own examples, one is the site's downloads --
and neither is obviously the copy of the other.

There is a third directory, and for two months nothing asked it. When the applet
runner was folded in on 2026-08-19 (f8d1905) it brought `runner/assets/examples/`
with it: 21 programs, 17 of them under the same name as a catalogue file. Two of
those 17 were the runner repository's older copies, from before fixes that had
already landed here. `Base64Lib_tests.bas` called `savetext$` with its arguments
in the order b3e871b had corrected, and `strlib_test.bas` called `startsstr` and
`endsstr` pattern-first, as 4570de8 had corrected. This check still printed "all
identical", truthfully, about the two directories it knew. The runner's copies
are now held to the catalogue wherever the names match; its four programs of its
own (`hello_ai.bas` and the like) have nothing to match and are left alone.

The Base64 one was not caught by the applet run either, and that is worth
knowing. It writes `b64_test_input.txt` without checking `savetext$` succeeded,
and the runner keeps one working directory per worker for every file on it. In
`check-all.py`, which runs all three folders together, the timing cache packed
the good `Examples/21_Base64Lib_tests.bas` onto the same worker just ahead of
the bad copy, which then found the good copy's file and passed. Run alone, the
runner's folder failed every time.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PAGE = os.path.join(ROOT, 'Website', 'docs', 'examples.html')

#id in the page  ->  file in the repository
PAIRS = {name: os.path.join(ROOT, 'Demos', name + '.bas') for name in [
    '2048', 'asteroids', 'breakout', 'flappy_bird', 'lunar_lander',
    'missile_command', 'snake', 'space_invaders', 'space_mines',
    'girder',
    'tractor',
    'whack_a_mole']}

ENTRY = re.compile(r"id:\s*'([^']+)'.*?code:\s*`(.*?)`\s*[,}]", re.S)

#Examples/61_ChuckNorrisFacts_Demo.bas <-> Website/assets/examples/ChuckNorrisFacts_Demo.bas
REPO_EXAMPLES = os.path.join(ROOT, 'Examples')
SITE_EXAMPLES = os.path.join(ROOT, 'Website', 'assets', 'examples')
LEADING_NUMBER = re.compile(r'^\d+[_-]?')

#runner/assets/examples/Base64Lib_tests.bas <-> Website/assets/examples/Base64Lib_tests.bas
RUNNER_EXAMPLES = os.path.join(ROOT, 'runner', 'assets', 'examples')


def embedded():
    """Every example the page carries, by id."""
    text = open(PAGE, encoding='utf-8', errors='replace').read()
    out = {}
    for m in ENTRY.finditer(text):
        body = m.group(2)
        #Some entries store the source with the newline escaped rather than
        #written out; a template literal reads both the same way.
        if chr(92) + 'n' in body and chr(10) not in body:
            body = body.replace(chr(92) + 'n', chr(10))
        out[m.group(1)] = body
    return out


def normal(text):
    return text.replace('\r\n', '\n').strip('\n')


def read(path):
    #utf-8-sig, because a byte order mark is an encoding difference and not a
    #difference in the program. Two thirds of these files carry one, on both
    #sides, and which ones is an accident of whatever wrote them.
    return normal(open(path, encoding='utf-8-sig', errors='replace').read())


def mirrored():
    """The two example directories, paired by name without the leading number."""
    def index(folder):
        if not os.path.isdir(folder):
            return {}
        return {LEADING_NUMBER.sub('', f).lower(): f
                for f in os.listdir(folder) if f.endswith('.bas')}

    repo, site = index(REPO_EXAMPLES), index(SITE_EXAMPLES)
    out = []
    for k in sorted(set(repo) | set(site)):
        if k not in site:
            out.append((repo[k], 'Website/assets/examples/ has no copy of it'))
        elif k not in repo:
            out.append((site[k], 'Examples/ has no copy of it'))
        else:
            a = read(os.path.join(REPO_EXAMPLES, repo[k]))
            b = read(os.path.join(SITE_EXAMPLES, site[k]))
            if a != b:
                la, lb = a.split('\n'), b.split('\n')
                d = sum(1 for x, y in zip(la, lb) if x != y)
                d += abs(len(la) - len(lb))
                out.append((repo[k], f'{d} line(s) differ from the site copy'))
    return out, len(set(repo) & set(site))


def runner_copies():
    """The runner's examples that share a name with the catalogue."""
    if not os.path.isdir(RUNNER_EXAMPLES) or not os.path.isdir(SITE_EXAMPLES):
        return [], 0
    site = {f.lower(): f for f in os.listdir(SITE_EXAMPLES) if f.endswith('.bas')}
    out, counted = [], 0
    for f in sorted(os.listdir(RUNNER_EXAMPLES)):
        if not f.endswith('.bas') or f.lower() not in site:
            continue
        counted += 1
        a = read(os.path.join(RUNNER_EXAMPLES, f))
        b = read(os.path.join(SITE_EXAMPLES, site[f.lower()]))
        if a != b:
            la, lb = a.split('\n'), b.split('\n')
            d = sum(1 for x, y in zip(la, lb) if x != y)
            d += abs(len(la) - len(lb))
            out.append(('runner/assets/examples/' + f,
                        f'{d} line(s) differ from the catalogue copy'))
    return out, counted


def main():
    if not os.path.isfile(PAGE):
        print('the examples page is not where this expects it: ' + PAGE)
        return 2

    found = embedded()
    problems = []
    for name, path in sorted(PAIRS.items()):
        if name not in found:
            problems.append((name, 'the page no longer carries it'))
            continue
        if not os.path.isfile(path):
            problems.append((name, 'the repository no longer carries it'))
            continue
        disk = normal(open(path, encoding='utf-8', errors='replace').read())
        site = normal(found[name])
        if disk != site:
            d = len([1 for a, b in zip(disk.split('\n'), site.split('\n')) if a != b])
            d += abs(len(disk.split('\n')) - len(site.split('\n')))
            problems.append((name, f'{d} line(s) differ from Demos/{name}.bas'))

    mirror, counted = mirrored()
    problems += mirror
    runner, shared = runner_copies()
    problems += runner

    for name, why in problems:
        print(f'  {name}: {why}')

    if problems:
        print(f'\n{len(problems)} example(s) the site and the repository disagree on.')
        print('The site is what a reader copies, so it is what they run.')
        return 1
    print(f'ok  {len(found)} example(s) on the page, {len(PAIRS)} paired with '
          f'the repository, {counted} in both example directories, and '
          f'{shared} shared with the runner\'s, all identical')
    return 0


if __name__ == '__main__':
    sys.exit(main())
