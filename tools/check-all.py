#!/usr/bin/env python3
"""
check-all.py - every check that answers a question about the documentation.

Six of them were written one at a time, each answering a question nobody had
asked before, and each ended up a separate script somebody has to remember. This
runs the lot and gives one verdict, so the investment survives the person who
made it.

    the registered surface   check-docs.py      does a documented function exist,
                                                and take what the page says
    the worked examples      the test suite     does it return what the page claims
    the code blocks          check-doc-blocks   does what a reader copies compile
    the applets              the runner         do the files offered for download
    the links                check-links.py     does a link reach a file
    the fragments            check-anchors.py   does the #section name anything
    the site's examples      check-site-examples  does the page hand out the
                                                same program the repository has
    the Pages layout         check-pages.py     is the tree laid out the way
                                                Pages expects, and what would
                                                not survive the switch
    the examples catalogue   check-examples-catalog  does the list the browser
                                                reads match the files beside it
    per-module state         check-module-state  does a library still keep an
                                                engine it never reads
    the event setters        check-event-binding  does each one wire the event
                                                its own name promises
    the generated suites     gen_*_suite --check  is the committed .bas still
                                                what its generator produces

Everything here is read-only. The generators that write files --
gen-doc-examples.py and check-doc-blocks.py --baseline -- are run by hand, since
regenerating a fixture is a decision and not a check.

    python tools/check-all.py            run everything, one verdict
    python tools/check-all.py --quick    skip the two that compile, which are
                                         most of the wall clock
"""
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOLS = os.path.join(ROOT, 'tools')
RUNNER = os.path.join(ROOT, 'tests', 'bin', 'Plan9BasicTest.exe')

APPLETS = ['Examples', 'Website/assets/examples', 'Demos',
           'runner/assets/examples']


def tool(name, *args):
    return [sys.executable, os.path.join(TOOLS, name), *args]


def applets(folder):
    #Run them, rather than only compiling them. Compiling proved the source
    #was valid and nothing else, and the day that changed found a library
    #function that always answered 0, an assertion about scrollbox parents
    #that had never been true, and eighty comparisons written for the
    #contract instr had before 1.1 -- including the platform detection in
    #every shipped game.
    return [RUNNER, '--gui', '--smoke', os.path.join(ROOT, *folder.split('/'))]


def run(label, cmd, slow=False):
    """Run one check; return (ok, the line worth keeping)."""
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, cwd=ROOT)
    except OSError as e:
        return False, f'could not run: {e}'
    lines = [l for l in res.stdout.split('\n') if l.strip()]
    tail = lines[-1] if lines else '(no output)'
    return res.returncode == 0, tail


def main():
    quick = '--quick' in sys.argv

    checks = [
        ('registered surface', tool('check-docs.py'), False),
        ('control chars', tool('check-control-chars.py'), False),
        ('links', tool('check-links.py'), False),
        ('fragments', tool('check-anchors.py'), False),
        ('fmx boundary', tool('check-fmx-boundary.py'), False),
        ('site deps', tool('check-site-deps.py'), False),
        ('callbacks', tool('check-callbacks.py'), False),
        ('site examples', tool('check-site-examples.py'), False),
        ('pages layout', tool('check-pages.py'), False),
        ('examples catalogue', tool('check-examples-catalog.py'), False),
        ('module state', tool('check-module-state.py'), False),
        ('event binding', tool('check-event-binding.py'), False),
        ('engine lookup', tool('check-engine-lookup.py'), False),
        ('event docs', tool('check-event-docs.py'), False),
        ('generated suites', [sys.executable, os.path.join(ROOT, 'tests', 'gen_property_suite.py'), '--check'], False),
        ('generated effects', [sys.executable, os.path.join(ROOT, 'tests', 'gen_effects_suite.py'), '--check'], False),
        ('generated lifecycle', [sys.executable, os.path.join(ROOT, 'tests', 'gen_lifecycle_suite.py'), '--check'], False),
        ('generated geometry', [sys.executable, os.path.join(ROOT, 'tests', 'gen_geometry_suite.py'), '--check'], False),
    ]
    if not quick:
        checks += [('code blocks', tool('check-doc-blocks.py'), True)]
        checks += [(f'applets in {f}', applets(f), True) for f in APPLETS]

    if not os.path.exists(RUNNER) and not quick:
        print('the test runner is not built; build it with tests/build.ps1')
        print('or pass --quick to run only the checks that do not compile\n')
        return 2

    width = max(len(label) for label, _, _ in checks)
    failed = []
    for label, cmd, slow in checks:
        ok, tail = run(label, cmd, slow)
        mark = 'ok  ' if ok else 'FAIL'
        print(f'  {mark}  {label:<{width}}  {tail}')
        if not ok:
            failed.append(label)

    print()
    if failed:
        print(f'{len(failed)} check(s) failed: {", ".join(failed)}')
        print('run the one that failed on its own for the detail')
        return 1
    print(f'{len(checks)} check(s) passed'
          + ('  (--quick: the compiling ones were skipped)' if quick else ''))
    return 0


if __name__ == '__main__':
    sys.exit(main())
