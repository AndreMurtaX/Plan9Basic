#!/usr/bin/env python3
"""
check-coverage.py - which registered functions has a test ever called?

The library surface is defined by the Lib.Add / Funcs.Add calls, exactly as
check-docs.py reads it. This asks a different question of the same list: not
"is it documented" but "has anything ever run it".

The unit is the NAME, not the signature. A name with three overloads counts
once, because a suffix-typed argument list in BASIC is often an expression
rather than a literal and typing it would mean evaluating it. Claiming
signature-level coverage from a static read would be inventing precision.

That makes the number an upper bound on how well tested the surface is, and it
is reported as such. An uncovered name is certain: nothing in the suites names
it, so nobody has ever run it and any defect in it is undiscovered by
construction. A covered name only means somebody called it once.

    python tools/check-coverage.py              summary per library
    python tools/check-coverage.py --uncovered  list what nothing calls
    python tools/check-coverage.py --min N      fail under N% overall
    python tools/check-coverage.py --quiet      exit code only
"""
import glob
import os
import re
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

CODE_GLOBS = ['Libs/**/*.pas', 'engine/Libs/**/*.pas']
TEST_GLOBS = ['tests/suite/*.bas', 'tests/gui/*.bas', 'tests/negative/*.bas',
              # tests/local/ needs something the machine may not have -- a model
              # on localhost. verify.ps1 reports that step as skipped rather than
              # failed. Counted here because the functions are covered wherever the
              # step does run, and a count that ignored them would understate what
              # is tested on a machine that has one.
              'tests/local/*.bas']

REGISTER = re.compile(r"\b(?:Lib|Funcs)\.Add\('([^']+)'")
VARIADIC = re.compile(r"\b(?:Lib|Funcs)\.Add\('([^']+)' *\+")

# A call in BASIC, by the same suffix rule the engine registers under. The
# opening parenthesis is required: a bare identifier is a variable, and
# counting it would mark a function covered because a test happened to name a
# variable the same thing.
CALL = re.compile(r'\b([a-z][a-z0-9_]*[$#]?)\s*\(')

# The harness is not the surface under test.
HARNESS = {
    'test_case', 'assert_true', 'assert_false', 'assert_eq', 'assert_neq',
    'assert_near', 'assert_error', 'assert_noerror',
}

# Statements, not functions: they are parsed by the parser, never registered,
# and the suites reach them constantly. Listing them here keeps them out of
# the call set rather than silently matching nothing.
KEYWORDS = {
    'if', 'while', 'until', 'for', 'print', 'println', 'let', 'return',
    'function', 'sub', 'do', 'loop', 'next', 'then', 'else', 'end', 'dim',
    'and', 'or', 'not', 'mod', 'to', 'step', 'rem', 'goto', 'gosub',
}


def read(path):
    with open(path, encoding='utf-8-sig', errors='replace') as f:
        return f.read()


def strip_comments(src):
    """BASIC comments: rem to end of line, and a leading apostrophe."""
    out = []
    for line in src.split('\n'):
        line = re.sub(r"\brem\b.*$", '', line, flags=re.I)
        # An apostrophe inside a string is not a comment, so walk the quotes.
        cut, inside = len(line), False
        for i, ch in enumerate(line):
            if ch == '"':
                inside = not inside
            elif ch == "'" and not inside:
                cut = i
                break
        out.append(line[:cut])
    return '\n'.join(out)


def library_of(path):
    return os.path.splitext(os.path.basename(path))[0]


def registered():
    """{library: {name}} for every function the engine registers."""
    out = defaultdict(set)
    for pattern in CODE_GLOBS:
        for path in sorted(glob.glob(os.path.join(ROOT, pattern), recursive=True)):
            if '__history' in path or os.sep + 'archive' + os.sep in path:
                continue
            src = read(path)
            lib = library_of(path)
            for sig in REGISTER.findall(src) + VARIADIC.findall(src):
                out[lib].add(sig.split('@')[0])
    return out


def called():
    """Every function name the suites call."""
    names = set()
    for pattern in TEST_GLOBS:
        for path in sorted(glob.glob(os.path.join(ROOT, pattern))):
            for name in CALL.findall(strip_comments(read(path))):
                if name.lower() not in KEYWORDS and name not in HARNESS:
                    names.add(name)
    return names


def main():
    args = sys.argv[1:]
    quiet = '--quiet' in args
    show = '--uncovered' in args
    floor = 0
    if '--min' in args:
        floor = int(args[args.index('--min') + 1])

    surface, hit = registered(), called()
    rows, total, covered = [], 0, 0
    for lib in sorted(surface):
        names = surface[lib]
        n = len(names & hit)
        rows.append((lib, n, len(names), sorted(names - hit)))
        total += len(names)
        covered += n

    pct = 100.0 * covered / total if total else 100.0
    if not quiet:
        for lib, n, all_, missing in sorted(rows, key=lambda r: (r[1] / r[2] if r[2] else 1, -r[2])):
            bar = 100.0 * n / all_ if all_ else 100.0
            print('  %-28s %4d/%-4d  %5.1f%%' % (lib, n, all_, bar))
            if show and missing:
                for name in missing:
                    print('        %s' % name)
        print()
        print('  %d of %d registered name(s) called by a test -- %.1f%%'
              % (covered, total, pct))
        print('  an upper bound: a name counts as covered the first time'
              ' anything calls it')

    if floor and pct < floor:
        if not quiet:
            print('\nFAIL: coverage %.1f%% is below the %d%% floor' % (pct, floor))
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
