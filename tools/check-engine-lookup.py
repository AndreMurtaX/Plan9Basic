#!/usr/bin/env python3
r"""A control asks for its engine only after it has a parent to ask through.

Phase 2.2 replaced the per-library engine variable with `EngineOf`, which walks
a control's parent chain up to the form that owns one. That is right, and it has
one precondition nothing enforced: **the control must already be parented.**

Seven libraries called it on an orphan -- created with `Create(nil)` and given
its parent on the next line but one -- so the walk started nowhere, `EngineOf`
answered False, `BasicEngine` stayed nil, and every event on those controls was
dead. `label`, `layout`, `panel`, `progressbar`, `rectangle` and `trackbar`,
which is why flappy_bird answered neither a key nor a tap.

None of it was visible. `ControlCommon.CallbackCore` exits on `not
Assigned(Engine)` without a word, so a dead handler and a handler that was never
meant to fire look exactly alike from BASIC. `check-callbacks.py` proves the
shapes agree, and they did; delivery is what nobody asked about.

A form is the other half of the same mistake and cannot be fixed by ordering: it
is the ROOT of the chain, so there is never anything above it. `FormLib` is
given the engine at registration instead, and `check-module-state.py` names it.

This reads the order. For every object created in a GUI library, if `EngineOf`
is called on it, a `Parent` assignment has to come first.
"""
import os
import re
import sys
import glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
GUI = os.path.join(ROOT, 'Libs', 'GUI')

CREATE = re.compile(r'^\s*(\w+)\s*:=\s*T\w+\.Create\(')
PARENT = re.compile(r'^\s*(\w+)\.Parent\s*:=')
ENGINE = re.compile(r'EngineOf\(\s*(\w+)')

#How far after the constructor to keep looking. Beyond this the two are not
#part of one construction sequence and the pairing would be a guess.
WINDOW = 40


def units():
    for p in sorted(glob.glob(os.path.join(GUI, '**', '*.pas'), recursive=True)):
        if '__history' not in p:
            yield p


def main():
    problems = []
    checked = 0
    for path in units():
        rel = os.path.relpath(path, ROOT).replace(os.sep, '/')
        lines = open(path, encoding='utf-8-sig', errors='replace').read().split('\n')
        for i, line in enumerate(lines):
            m = CREATE.match(line)
            if not m:
                continue
            var = m.group(1)
            parented = False
            #Nesting relative to the constructor. A lookup one level in is
            #inside a branch, so it runs for one kind of parent and not the
            #other -- which is what an automated move of these blocks did to
            #ProgressBarLib and TrackBarLib on 2026-08-20, putting the lookup
            #inside the else and skipping it whenever the parent was a form.
            #The first version of this check passed on that.
            depth = 0
            for j in range(i + 1, min(i + WINDOW, len(lines))):
                body = lines[j].split('//')[0]
                depth += len(re.findall(r'\bbegin\b', body, re.I))
                depth -= len(re.findall(r'\bend\b', body, re.I))
                pm = PARENT.match(lines[j])
                if pm and pm.group(1) == var:
                    parented = True
                em = ENGINE.search(lines[j])
                if em and em.group(1) == var:
                    checked += 1
                    if not parented:
                        problems.append(
                            f'{rel}:{j + 1}: EngineOf({var}) runs before '
                            f'{var}.Parent is set, so the walk starts from an '
                            f'orphan and every event on it will be dead')
                    elif depth > 0:
                        problems.append(
                            f'{rel}:{j + 1}: EngineOf({var}) is {depth} level(s) '
                            f'inside a branch, so it runs for one kind of parent '
                            f'and is skipped for the other')
                    break

    for p in problems:
        print(f'  {p}')
    if problems:
        print(f'\n{len(problems)} control(s) ask for an engine they cannot reach.')
        print('Nothing reports this at run time: the dispatcher exits silently.')
        return 1

    print(f'ok  {checked} construction(s) look up the engine, every one of them '
          f'after the parent is set')
    return 0


if __name__ == '__main__':
    sys.exit(main())
