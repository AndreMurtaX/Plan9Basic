#!/usr/bin/env python3
r"""The handler shape a reference page promises, against the one the code sends.

`check-callbacks.py` reads the programs in this tree and holds them to the
dispatchers. Every one of them agrees. What nothing read was the **reference
pages**, which is what a person writing a new program actually follows:

    rectangle_onresize#(r#, func$)   ->   function name(sender#)

and the dispatcher sends `@#nn` -- sender, width, height. A handler written as
the page describes it compiles, registers, and is never called, because the
signature the engine looks up is built from the parameter types and does not
match. No error is raised anywhere: this is section 28's defect with the
documentation as its source.

48 of the 331 comparable events disagreed when this was first run.

Types, not counts. `onmousedown` is sent as `@#nnn$` by eighteen libraries and
as `@#n$nn` by five -- the same five parameters with the shift string third
instead of last. Counting them calls those equal and the engine does not.
"""
import os
import re
import sys
import glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKIP = ('.git', '__history', 'dist', 'Android64', 'Win64', 'Linux64', 'Win32',
        'OSX64', 'bin')

DISP = re.compile(r"(?:LowerCase\(F(\w+?)Func\)|F(\w+?)Func\.ToLower\(\))"
                  r"\s*\+\s*'@([^']*)'")
REG = re.compile(r"Lib\.Add\('([a-z][a-z0-9]*)_on([a-z]+)#@")

#A reference row: the setter, its getter, and the handler shape it promises.
ROW = re.compile(r'<code>([a-z][a-z0-9]*)_on([a-z]+)#\([^)]*\)</code></td>\s*'
                 r'<td><code>[^<]*</code></td>\s*'
                 r'<td><code>function name\(([^)]*)\)</code>')


def types(params):
    """A parameter list as the engine encodes it: # pointer, $ string, n number."""
    out = ''
    for p in params.split(','):
        p = p.strip()
        if not p:
            continue
        out += '#' if p.endswith('#') else ('$' if p.endswith('$') else 'n')
    return out


def sent():
    """(library, event) -> the signatures its dispatchers build."""
    out = {}
    for base, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in SKIP]
        for f in sorted(files):
            if not f.endswith('.pas'):
                continue
            text = open(os.path.join(base, f), encoding='utf-8-sig',
                        errors='replace').read()
            prefixes = {m.group(1) for m in REG.finditer(text)}
            if not prefixes:
                continue
            for a, b, sig in DISP.findall(text):
                event = (a or b).lower()
                if event.startswith('on'):
                    event = event[2:]
                for p in prefixes:
                    out.setdefault((p, event), set()).add(sig)
    return out


def promised():
    """(library, event) -> (types the page promises, page)."""
    out = {}
    for p in glob.glob(os.path.join(ROOT, 'Website', 'docs', '**', '*.html'),
                       recursive=True):
        text = open(p, encoding='utf-8', errors='replace').read()
        for lib, event, params in ROW.findall(text):
            out[(lib, event)] = (types(params),
                                 os.path.relpath(p, ROOT).replace(os.sep, '/'))
    return out


def main():
    code, page = sent(), promised()
    both = sorted(set(code) & set(page))
    problems = []
    for key in both:
        want, (got, where) = code[key], page[key]
        if got not in want:
            lib, event = key
            problems.append(f'{where}: {lib}_on{event} is documented as '
                            f'function name(@{got}) and sent as '
                            f'@{" or @".join(sorted(want))}')

    for p in problems:
        print(f'  {p}')
    if problems:
        print(f'\n{len(problems)} page(s) describe a handler the engine will '
              f'never call.')
        print('The lookup is on the type signature, and nothing reports a miss.')
        return 1

    print(f'ok  {len(both)} documented event(s), every handler shape the one '
          f'its dispatcher sends')
    return 0


if __name__ == '__main__':
    sys.exit(main())
