#!/usr/bin/env python3
r"""Per-module engine state: who still keeps it, and whether they read it.

Every library used to hold `ModuleEngine` and `ModuleOutput` as unit variables,
set once when the library registered itself. Two engines in one process were
impossible and the VM could not leave the interface thread, which is what
ANALYSIS 3.5 is about.

Phase 2.2 replaced the lookup for visual controls: a control finds its engine by
walking up its parents to the form that owns one. What it did not do is remove
the variables. Thirty-four units went on declaring them and assigning them on
every registration, and reading them nowhere -- dead state that reads as live,
in the exact place the documentation said the state was gone.

Some units keep it for a real reason, and those are named below. A timer, a
string list and a media player are not in the visual tree, so there is no parent
chain to walk and the module variable is the only way they have.

This fails in both directions: a unit that declares one of these and never reads
it, and a name in READERS that has stopped reading. A list that stops describing
the tree is how the thing above happened.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKIP = ('.git', '__history', 'dist', 'Android64', 'Win64', 'Linux64', 'Win32',
        'OSX64', 'bin')
NAMES = ('ModuleEngine', 'ModuleOutput')

#Units with no parent chain to walk, and why each has none.
READERS = {
    'engine/Libs/GUI/TimerLib.pas':
        'a timer is not a visual control and has no parent to walk up to',
    'Libs/StrListLib.pas':
        'a string list is not in the visual tree at all',
    'Libs/GUI/MediaPlayerLib.pas':
        'the player is not necessarily parented when it is created',
    'tests/TestLib.pas':
        'the test harness reaches the parser directly, which is its job',
    'Libs/GUI/FormLib.pas':
        'a form is the root of the parent chain, so there is nothing above it '
        'for EngineOf to ask. Phase 2.2 gave it the parent walk anyway and '
        'every form event was dead until 2026-08-20',
}


def strip_comments(text):
    text = re.sub(r'//[^\n]*', '', text)
    text = re.sub(r'\{[^}]*\}', '', text, flags=re.S)
    return re.sub(r'\(\*.*?\*\)', '', text, flags=re.S)


def units():
    for base, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in SKIP]
        for f in sorted(files):
            if f.endswith('.pas'):
                yield os.path.join(base, f)


def reads(code, name):
    """Uses that are neither the declaration nor an assignment to it."""
    decl = re.compile(r'^\s*' + name + r'\s*:\s*[A-Za-z]', re.M)
    if not decl.search(code):
        return None                      # does not declare it at all
    found = 0
    for m in re.finditer(r'\b' + name + r'\b', code):
        start = code.rfind('\n', 0, m.start()) + 1
        line = code[start:code.find('\n', m.end())]
        if code[m.end():m.end() + 3].lstrip().startswith(':=') or decl.match(line):
            continue
        found += 1
    return found


def main():
    problems = []
    holders = {}
    for path in units():
        rel = os.path.relpath(path, ROOT).replace(os.sep, '/')
        code = strip_comments(open(path, encoding='utf-8-sig',
                                   errors='replace').read())
        for name in NAMES:
            n = reads(code, name)
            if n is None:
                continue
            holders.setdefault(rel, []).append((name, n))

    for rel, found in sorted(holders.items()):
        live = [name for name, n in found if n]
        dead = [name for name, n in found if not n]
        if dead:
            problems.append(f'{rel} declares {" and ".join(dead)} and never '
                            f'reads it; Phase 2.2 left the lookup behind')
        if live and rel not in READERS:
            problems.append(f'{rel} reads {" and ".join(live)} and READERS does '
                            f'not say why it cannot walk up to its engine')

    for rel in sorted(READERS):
        if rel not in holders:
            problems.append(f'READERS names {rel} and it no longer keeps module '
                            f'state; drop it so the list keeps describing the tree')

    for p in problems:
        print(f'  {p}')
    if problems:
        print(f'\n{len(problems)} problem(s) with per-module engine state.')
        return 1

    print(f'ok  {len(holders)} unit(s) keep module state, every one of them '
          f'named and reading it')
    return 0


if __name__ == '__main__':
    sys.exit(main())
