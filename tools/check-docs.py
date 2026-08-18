#!/usr/bin/env python3
"""
check-docs.py - checks the reference documentation against the code.

The library surface is defined in exactly one place: the Lib.Add / Funcs.Add
calls that register a native function under a string signature. This compares
the documentation's claims against that surface and reports where they part.

    name@params     the signature the engine registers
                    $ string, # pointer, n number; the suffix on the name is
                    the return type by the same rule

Documentation writes the same thing as a call:

    `arc#(parent#, width, height)`   ->  arc#@#nn

so a documented call can be turned into a signature and looked up. That catches
more than a missing function: an argument added, dropped or retyped since the
page was written shows up too.

Findings come in three kinds:

  MISSING    a documented function that is not registered anywhere. Someone
             copying that line out of the docs gets a compile error.
  SIGNATURE  the name exists but no registered overload takes what the page
             says it takes. Same outcome, later, and harder to spot.
  UNDOCUMENTED  registered and never documented. Reported for the count, and
             never a failure: nobody is misled by silence.

Only MISSING and SIGNATURE set a non-zero exit code. Changelogs/ is history --
a page describing what a release did is not promising the function still
exists -- so it is scanned separately and never fails the run.

    python tools/check-docs.py                 summary and findings
    python tools/check-docs.py --undocumented  add the undocumented list
    python tools/check-docs.py --quiet         exit code only
"""
import re
import sys
import glob
import os
from collections import defaultdict

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Documentation writes the shape of a callback the same way it writes a call.
# These are the names it uses for "a function you write", not functions the
# engine provides. A new one shows up as a MISSING finding, which is the right
# way to notice it needs adding here.
PLACEHOLDERS = {
    'function', 'name', 'name$', 'callback', 'handler', 'myfunc', 'func',
    'funcname',
}

CODE_GLOBS = ['Libs/**/*.pas', 'engine/Libs/**/*.pas']

# Three generations of documentation describe the same surface. The first two
# are checked; Changelogs/ is history, and a page describing what a release did
# is not promising the function still exists.
#
#   (label, glob, how a call is written)
REFERENCES = [
    ('New docs', 'New docs/**/*.md', 'md'),
    ('Website', 'Website/docs/**/*.html', 'html'),
]
HISTORY = ('Changelogs', 'Changelogs/**/*.md', 'md')

REGISTER = re.compile(r"\b(?:Lib|Funcs)\.Add\('([^']+)'")
# Nine functions register one signature per dimension, in a loop:
#     Lib.Add('narr_get@#' + nStr, FnData)
# Only the prefix is a literal, so the arity cannot be read statically. Their
# names are collected here and checked for existence but not for shape --
# claiming otherwise would be inventing a finding.
VARIADIC = re.compile(r"\b(?:Lib|Funcs)\.Add\('([^']+)' *\+")
# One level of nesting, so a call used as an argument does not truncate the
# match: json_getn(json_parse#("..."), "k") reads as two arguments, not one.
DOCCALL = re.compile(r'`([a-z][a-z0-9_]*[$#]?)\(((?:[^`()]|\([^`()]*\))*)\)`')
# The website writes the same thing inside <code>, so the two differ only in
# what delimits the span.
HTMLCALL = re.compile(
    r'<code[^>]*>\s*([a-z][a-z0-9_]*[$#]?)\(((?:[^<()]|\([^<()]*\))*)\)\s*</code>')

# Documentation also writes calls it is telling you NOT to make: "the syntax is
# formatdatetime$(...) -- Not format$(value, ...)". The page is right and the
# call is deliberately wrong, so a match a negation introduced is not a claim.
NEGATED = re.compile(r'(?:not|never|instead of|rather than)\W{0,4}$', re.I)

NUMERIC = re.compile(r'^[-+]?(\d+\.?\d*|\.\d+)$')
QUOTES = '"' + "'"


def split_args(argstr):
    """Split on commas that are not inside a nested call."""
    out, depth, cur = [], 0, ''
    for ch in argstr:
        if ch == '(':
            depth += 1
        elif ch == ')':
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur)
            cur = ''
        else:
            cur += ch
    if cur.strip():
        out.append(cur)
    return [a.strip() for a in out]


def arg_types(argstr):
    """
    Types of a documented argument list, by the engine's own suffix rule.

    Documentation writes both declarations and examples, and both have to type
    the same way or the examples read as mismatches:

        asc(s$)     a named parameter, typed by its suffix
        asc("A")    a literal, typed by what it is

    Returns None when the list carries no arity to compare, and the caller then
    checks only that the name exists. That covers two cases:

        `arr_free()`                        prose naming the function
        `arc#(parent#[, w, h] | [, x, y])`  a synopsis of the overloads

    The second is a summary of several signatures at once, written with the
    brackets and bars that notation uses. Reading it as one argument list
    invents an overload nobody claimed.
    """
    if any(c in argstr for c in '[]|') or '...' in argstr:
        return None
    args = split_args(argstr)
    if not args:
        return None
    out = ''
    for a in args:
        a = a.split('=')[0].strip()
        if a[:1] in QUOTES or a[-1:] in QUOTES:
            out += '$'                       # string literal
        elif NUMERIC.match(a):
            out += 'n'                       # numeric literal
        elif a.endswith('#'):
            out += '#'
        elif a.endswith('$'):
            out += '$'
        else:
            out += 'n'
    return out


def read_code():
    """Every signature the engine registers, and the names behind them."""
    sigs, variadic = set(), set()
    for pattern in CODE_GLOBS:
        for path in glob.glob(os.path.join(ROOT, pattern), recursive=True):
            with open(path, encoding='utf-8-sig', errors='replace') as f:
                src = f.read()
            sigs.update(m.group(1) for m in REGISTER.finditer(src))
            variadic.update(m.group(1).split('@')[0]
                            for m in VARIADIC.finditer(src))
    return sigs, {s.split('@')[0] for s in sigs}, variadic


def read_docs(pattern, kind):
    """Documented calls as signatures, each remembering where it was written."""
    claims = defaultdict(set)
    rx = HTMLCALL if kind == 'html' else DOCCALL
    for path in glob.glob(os.path.join(ROOT, pattern), recursive=True):
        rel = os.path.relpath(path, ROOT).replace('\\', '/')
        with open(path, encoding='utf-8', errors='replace') as f:
            text = f.read()
        for m in rx.finditer(text):
            name = m.group(1)
            if name in PLACEHOLDERS:
                continue
            if NEGATED.search(text[max(0, m.start() - 24):m.start()]):
                continue
            types = arg_types(m.group(2))
            key = name if types is None else f'{name}@{types}'
            claims[key].add(rel)
    return claims
def check(claims, sigs, names, variadic):
    missing, mismatch = [], []
    for sig, where in sorted(claims.items()):
        name = sig.split('@')[0]
        if name not in names:
            missing.append((sig, where))
        elif '@' not in sig:
            continue          # a bare mention: the name is all it claimed
        elif name in variadic:
            continue          # arity built at registration; nothing to compare
        elif sig not in sigs:
            takes = sorted(s for s in sigs if s.split('@')[0] == name)
            mismatch.append((sig, where, takes))
    return missing, mismatch


def main():
    quiet = '--quiet' in sys.argv
    show_undocumented = '--undocumented' in sys.argv

    sigs, names, variadic = read_code()

    claims = defaultdict(set)
    missing, mismatch = [], []
    per_source = []
    for label, pattern, kind in REFERENCES:
        found = read_docs(pattern, kind)
        per_source.append((label, found))
        for sig, where in found.items():
            claims[sig] |= where
    hist = read_docs(HISTORY[1], HISTORY[2])

    missing, mismatch = check(claims, sigs, names, variadic)
    documented = {s.split('@')[0] for s in claims}
    undocumented = sorted(names - documented)

    if not quiet:
        print(f'code       {len(sigs)} signatures, {len(names)} names')
        for label, found in per_source:
            covered = {s.split('@')[0] for s in found} & names
            print(f'{label + "/":<11}{len(found)} documented calls, '
                  f'{len(covered)} names, '
                  f'{100 * len(covered) / len(names):.1f}% covered')
        print(f'{HISTORY[0] + "/":<11}{len(hist)} documented calls '
              f'(history, not checked)')
        print()

        if missing:
            print(f'MISSING - documented, never registered ({len(missing)})')
            for sig, where in missing:
                print(f'  {sig:<34} {", ".join(sorted(where))}')
            print()

        if mismatch:
            print(f'SIGNATURE - name exists, arguments do not ({len(mismatch)})')
            for sig, where, takes in mismatch:
                print(f'  {sig:<34} {", ".join(sorted(where))}')
                print(f'  {"":<34} engine has: {", ".join(takes)}')
            print()

        if show_undocumented and undocumented:
            print(f'UNDOCUMENTED - registered, never documented ({len(undocumented)})')
            for i in range(0, len(undocumented), 6):
                print('  ' + '  '.join(f'{n:<22}' for n in undocumented[i:i + 6]))
            print()
        elif undocumented:
            print(f'UNDOCUMENTED  {len(undocumented)} registered names have no '
                  f'reference page (--undocumented to list)')
            print()

        bad = len(missing) + len(mismatch)
        print('OK - the documentation matches the code' if not bad
              else f'{bad} finding(s) - the documentation disagrees with the code')

    return 1 if (missing or mismatch) else 0


if __name__ == '__main__':
    sys.exit(main())
