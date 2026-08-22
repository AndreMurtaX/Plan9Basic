r"""Which units under engine/ reach FireMonkey.

`engine/` is the part meant to link without a windowing system -- it is what
`tests/NoFmxProbe.dpr` builds into a console host, and what a future non-FMX
front end would build on. Nothing enforces that boundary in the compiler: a
`uses FMX.Forms` added under engine/ compiles here exactly as well as anywhere
else, and the IDE build never notices.

It used to look enforced. `tests/build-nofmx.ps1` compiled the probe with a
search path it described as "the RTL only, with no FMX directory anywhere",
and treated success as proof. But dcc64 ships the FMX .dcu files in that same
lib\Win64\release directory -- 209 of them -- so the path never excluded
anything, and the probe linked 58 FMX units while reporting that it had proved
the engine needed none. A check that passes for the wrong reason is worse than
no check, because it answers the question and stops anyone asking it again.

So this asks the question directly, by reading the uses clauses, and holds the
answer as a ratchet: the units below are the ones that still reach FMX and why.
A new one fails the run. Cleaning one up and not editing this list fails too,
so the list cannot rot into fiction.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ENGINE = os.path.join(ROOT, 'engine')
RUNNER = os.path.join(ROOT, 'tests', 'Plan9BasicTest.dpr')

# Registered inside RegisterGuiLibs without reaching FMX -- allowed only with a
# reason, the same ratchet KNOWN uses.
GUI_BLOCK_OK = {}

# Unit -> why it is still allowed to reach FireMonkey.
KNOWN = {
    'TimerLib': 'a GUI library by design, kept here because exec.pas needs it',
}

# `uses` runs to the first semicolon; comments and directives can sit inside it.
USES = re.compile(r'^[ \t]*uses\b(.*?);', re.S | re.M | re.I)
COMMENT = re.compile(r'\(\*.*?\*\)|\{[^$].*?\}|\{\}|//[^\n]*', re.S)


def fmx_imports(path):
    with open(path, encoding='utf-8-sig', errors='replace') as f:
        src = f.read()
    found = set()
    for m in USES.finditer(src):
        clause = COMMENT.sub(' ', m.group(1))
        found.update(re.findall(r'\bFMX\.[A-Za-z0-9_.]+', clause))
    return sorted(found)


def unit_paths():
    """Unit -> the file the runner actually compiles, from its own uses clause.

    Resolved this way rather than by searching the tree, because the two are not
    the same question: `engine/` holds the portable core and the root `Libs/`
    holds the FireMonkey side, and a unit name alone does not say which tree it
    came from. An earlier version of this check walked engine/ only, found one
    FMX unit there, and duly declared the other 98 GUI libraries misplaced.
    """
    with open(RUNNER, encoding='utf-8-sig', errors='replace') as f:
        src = f.read()
    base = os.path.dirname(RUNNER)
    found = {}
    for name, rel in re.findall(r"\b([A-Za-z0-9_]+)\s+in\s+'([^']+)'", src):
        found[name] = os.path.normpath(os.path.join(base, rel.replace('\\', os.sep)))
    return found


def find_unit(name):
    """Where a unit lives when the uses clause does not say.

    Not every registered unit is listed with `in`: SwipeTransitionEffectLib is
    pulled in through the unit search path instead, and compiles perfectly well
    without appearing in the project file at all. Searching is a fallback rather
    than the rule, and an ambiguous name is reported rather than guessed at.
    """
    hits = []
    for root in (os.path.join(ROOT, 'engine'), os.path.join(ROOT, 'Libs')):
        for base, dirs, files in os.walk(root):
            dirs[:] = [d for d in dirs
                       if d not in ('__history', 'archive', '__recovery')]
            if name + '.pas' in files:
                hits.append(os.path.join(base, name + '.pas'))
    return hits[0] if len(hits) == 1 else None


def gui_registered():
    """Unit names registered inside RegisterGuiLibs."""
    with open(RUNNER, encoding='utf-8-sig', errors='replace') as f:
        src = f.read()
    start = src.find('procedure RegisterGuiLibs')
    if start < 0:
        return None
    # The block ends at the first line that is exactly `end;` at column zero.
    end = re.search(r'^end;', src[start:], re.M)
    block = src[start:start + end.end()] if end else src[start:]
    block = COMMENT.sub(' ', block)
    return sorted(set(re.findall(r'^\s*([A-Za-z0-9_]+)\.Register', block, re.M)))


def check_gui_block():
    """Every library registered as a GUI library should actually be one.

    SQLiteLib, AILib and RAGLib sat in that block without touching FireMonkey,
    so a headless program asking for rag# was told there is no function with
    such arguments -- true, and useless, because nothing had registered it. The
    signature lookup cannot tell "wrong arguments" from "never registered",
    which is what made a registration mistake read like a language limit.
    """
    units = gui_registered()
    if units is None:
        print('\nFAIL  RegisterGuiLibs not found in tests/Plan9BasicTest.dpr.')
        return 1
    paths = unit_paths()
    stray, missing = [], []
    for unit in units:
        if unit in GUI_BLOCK_OK:
            continue
        path = paths.get(unit) or find_unit(unit)
        if not path or not os.path.exists(path):
            missing.append(unit)
        elif not fmx_imports(path):
            stray.append(unit)

    for unit in missing:
        print('\nFAIL  %s is registered but its unit file could not be found' % unit)
        print('      through the uses clause. The check cannot judge it.')
    for unit in stray:
        print('\nFAIL  %s is registered inside RegisterGuiLibs but does not' % unit)
        print('      reach FireMonkey. Register it with the core libraries so a')
        print('      headless host has it too -- or add it to GUI_BLOCK_OK with')
        print('      a reason.')
    if stray or missing:
        return 1
    print('  ok  %d library(ies) registered as GUI, every one reaching FMX'
          % len(units))
    return 0


def main():
    actual = {}
    for base, dirs, files in os.walk(ENGINE):
        dirs[:] = [d for d in dirs if d != '__history']
        for name in sorted(files):
            if not name.lower().endswith('.pas'):
                continue
            hits = fmx_imports(os.path.join(base, name))
            if hits:
                actual[os.path.splitext(name)[0]] = hits

    new = sorted(set(actual) - set(KNOWN))
    gone = sorted(set(KNOWN) - set(actual))

    for unit in sorted(actual):
        mark = 'NEW ' if unit in new else '    '
        note = KNOWN.get(unit, 'not on the list')
        print(f'  {mark}{unit:<14} {", ".join(actual[unit])}')
        print(f'      {note}')

    if not (new or gone):
        print(f'\nok  {len(actual)} unit(s) reach FMX, all of them expected')
        return check_gui_block()

    for unit in new:
        print(f'\nFAIL  {unit} reaches FireMonkey and is not on the list.')
        print('      Route it through a host callback, the way PrintProc and')
        print('      InputProc already are -- or add it above with a reason.')
    for unit in gone:
        print(f'\nFAIL  {unit} no longer reaches FireMonkey. Drop it from the')
        print('      list in this file, so the list keeps describing the tree.')
    return 1


if __name__ == '__main__':
    sys.exit(main())
