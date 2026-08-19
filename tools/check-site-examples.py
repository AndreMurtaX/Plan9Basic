#!/usr/bin/env python3
r"""The games the site hands out, against the games in the repository.

`Website/docs/examples.html` carries the source of every example inside itself,
in a JavaScript template literal, and that is what a reader copies. The nine
games also exist as files under `Demos/`. Two copies of the same program.

They drifted. The corrections of 2026-08 landed in `Demos/` and never in the
page: on 2026-08-19 the site was still handing out the three-parameter keyboard
handler of section 28 and twenty-three comparisons written for the contract
`instr` had before 1.1. The author copied `flappy_bird` from the site, ran it,
and its keyboard was dead -- from a defect the repository had already fixed.

So the two copies have to agree, and a check has to say so.

Only the nine games are paired. `calculator` exists in both places and is two
different programs that share a name, which is why this pairs by an explicit
list and not by matching filenames.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PAGE = os.path.join(ROOT, 'Website', 'docs', 'examples.html')

#id in the page  ->  file in the repository
PAIRS = {name: os.path.join(ROOT, 'Demos', name + '.bas') for name in [
    '2048', 'asteroids', 'breakout', 'flappy_bird', 'lunar_lander',
    'missile_command', 'snake', 'space_invaders', 'whack_a_mole']}

ENTRY = re.compile(r"id:\s*'([^']+)'.*?code:\s*`(.*?)`\s*[,}]", re.S)


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

    for name, why in problems:
        print(f'  {name}: {why}')

    if problems:
        print(f'\n{len(problems)} example(s) the site and the repository disagree on.')
        print('The site is what a reader copies, so it is what they run.')
        return 1
    print(f'ok  {len(found)} example(s) on the page, '
          f'{len(PAIRS)} paired with the repository and identical')
    return 0


if __name__ == '__main__':
    sys.exit(main())
