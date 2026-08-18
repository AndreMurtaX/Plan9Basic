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
}

CODE_GLOBS = ['Libs/**/*.pas', 'engine/Libs/**/*.pas']
REFERENCE = 'New docs'      # checked strictly
HISTORY = 'Changelogs'      # scanned, never fails

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

    Returns None when the list is empty. That is not a claim of "takes no
    arguments" -- prose says `arr_free()` to name the function, the way English
    does -- so the caller checks only that the name exists.
    """
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


def read_docs(folder):
    """Documented calls as signatures, each remembering where it was written."""
    claims = defaultdict(set)
    base = os.path.join(ROOT, folder)
    for path in glob.glob(os.path.join(base, '**', '*.md'), recursive=True):
        rel = os.path.relpath(path, ROOT).replace('\\', '/')
        with open(path, encoding='utf-8', errors='replace') as f:
            for m in DOCCALL.finditer(f.read()):
                name = m.group(1)
                if name in PLACEHOLDERS:
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
    ref = read_docs(REFERENCE)
    hist = read_docs(HISTORY)

    missing, mismatch = check(ref, sigs, names, variadic)
    documented = {s.split('@')[0] for s in ref}
    undocumented = sorted(names - documented)

    if not quiet:
        print(f'code       {len(sigs)} signatures, {len(names)} names')
        print(f'{REFERENCE + "/":<11}{len(ref)} documented calls, '
              f'{len(documented)} names, '
              f'{100 * len(names & documented) / len(names):.1f}% covered')
        print(f'{HISTORY + "/":<11}{len(hist)} documented calls (history, not checked)')
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
