#!/usr/bin/env python3
"""
check-doc-blocks.py - compiles the documentation's code blocks.

check-docs.py checks the calls written in spans. gen-doc-examples.py runs the
worked examples. Neither touches the code blocks, which is what a reader copies:
1,719 in the markdown and 901 on the website.

Scanning them by pattern was tried and abandoned -- comments and string literals
read as calls, and the noise floor swallowed the signal. This compiles them
instead, with the interpreter's own parser, which is the only thing that knows
BASIC. Nothing is executed: an example may open a window or reach the network,
and a reader is not asking for either.

Many blocks are fragments -- a loop body, a couple of lines lifted out of a
program -- and a fragment is not expected to compile on its own. So a failure is
only reported when the block looks whole, which here means it has no unclosed
block statement. What that leaves is examples a reader could paste and run, and
those must compile.

The applets the site distributes are checked the same way, and more simply,
since a whole file needs none of the filtering a fragment does:

    tests/bin/Plan9BasicTest.exe --gui --compile-only Website/assets/examples

    python tools/check-doc-blocks.py            compile them, report failures
    python tools/check-doc-blocks.py --all      report fragments too
    python tools/check-doc-blocks.py --keep     leave the generated .bas files
"""
import re
import sys
import glob
import os
import html
import shutil
import subprocess
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RUNNER = os.path.join(ROOT, 'tests', 'bin', 'Plan9BasicTest.exe')

# What is left after the filters is not zero and will not become zero: nine
# blocks belong to an AI library that is documented but not built, and the rest
# are illustrative -- obj# = createSomeObject() teaches a shape and names a
# function nobody wrote. Those are recorded here so the check can answer the
# only question worth asking of it: is there anything new?
BASELINE = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                        'check-doc-blocks.baseline')

SOURCES = [
    # The language tag is required. Made optional, the pattern treats a closing
    # fence as an opening one and returns the prose between two blocks as a
    # third, which is how 1,680 blocks first counted as 2,620.
    ('New docs/**/*.md', re.compile(r'```(?:basic|bas)[ \t]*\r?\n(.*?)```', re.S), False),
    ('Website/docs/**/*.html', re.compile(r'<pre>(.*?)</pre>', re.S), True),
]

# A block that opens one of these and never closes it is a fragment: the reader
# is being shown the inside of something, not a program.
OPENERS = [(re.compile(r'^\s*(?:for)\b', re.I), re.compile(r'^\s*next\b', re.I)),
           (re.compile(r'^\s*while\b', re.I), re.compile(r'^\s*(?:endwhile|wend)\b', re.I)),
           (re.compile(r'^\s*function\b', re.I), re.compile(r'^\s*end\s+function\b', re.I)),
           (re.compile(r'^\s*select\b', re.I), re.compile(r'^\s*endselect\b', re.I))]
IF_OPEN = re.compile(r'^\s*if\b.*\bthen\s*$', re.I)
IF_CLOSE = re.compile(r'^\s*end\s+if\b', re.I)


# The one complaint that is not about the block itself: it names a variable an
# earlier block on the same page created.
IGNORED = re.compile(r'Unknown variable', re.I)


# The website highlights its BASIC, so a <pre> that is BASIC carries spans. One
# that carries none is holding something else: an ASCII diagram of a crop
# rectangle, SVG path data, a bracketed section header. The markdown says the
# same thing with its language tag; this is the website's version of it.
HIGHLIGHTED = re.compile(r'class="(?:kw|fn|str|num|cmt)"')


def strip_html(text):
    return html.unescape(re.sub(r'<[^>]+>', '', text))


# A synopsis states the shape of a call rather than making one, with the
# brackets and ellipsis that notation uses:
#     arrayPointer# = dim#(size1 [, size2, ..., size10])
# It sits in a basic-tagged fence like any example and is not one.
SYNOPSIS = re.compile(r'\([^)\n]*(?:\[|\.\.\.)')


def looks_whole(src):
    """True when nothing the block opens is left unclosed."""
    if SYNOPSIS.search(src):
        return False
    lines = src.split('\n')
    for opener, closer in OPENERS:
        if sum(bool(opener.match(l)) for l in lines) != \
           sum(bool(closer.match(l)) for l in lines):
            return False
    if sum(bool(IF_OPEN.match(l)) for l in lines) != \
       sum(bool(IF_CLOSE.match(l)) for l in lines):
        return False
    return True


def collect():
    """(source, index, code, whole) for every block found."""
    out = []
    for pattern, rx, ishtml in SOURCES:
        for path in sorted(glob.glob(os.path.join(ROOT, pattern), recursive=True)):
            rel = os.path.relpath(path, ROOT).replace('\\', '/')
            with open(path, encoding='utf-8', errors='replace') as f:
                text = f.read()
            for i, blk in enumerate(rx.findall(text), 1):
                if ishtml and not HIGHLIGHTED.search(blk):
                    continue
                code = strip_html(blk) if ishtml else blk
                if not code.strip():
                    continue
                out.append((rel, i, code.rstrip(), looks_whole(code)))
    return out


def main():
    show_all = '--all' in sys.argv
    keep = '--keep' in sys.argv

    if not os.path.exists(RUNNER):
        print(f'runner not built: {RUNNER}')
        print('build it with tests/build.ps1')
        return 2

    blocks = collect()
    whole = [b for b in blocks if b[3]]
    print(f'{len(blocks)} block(s), {len(whole)} whole enough to compile')

    work = tempfile.mkdtemp(prefix='p9b-blocks-')
    index = {}
    try:
        for n, (rel, i, code, is_whole) in enumerate(blocks):
            if not (is_whole or show_all):
                continue
            name = f'b{n:05d}.bas'
            index[name] = (rel, i)
            with open(os.path.join(work, name), 'w',
                      encoding='utf-8', newline='\r\n') as f:
                f.write(code)

        res = subprocess.run([RUNNER, '--gui', '--compile-only', work],
                             capture_output=True, text=True)
        failures = []
        current = None
        for line in res.stdout.split('\n'):
            m = re.match(r'^(COMPILE|RUNTIME)\s+(b\d+\.bas)', line)
            if m:
                current = index.get(m.group(2))
                continue
            if current and line.strip().startswith('!'):
                why = line.strip().lstrip('! ')
                # Pages are written cumulatively: a block configures the client
                # an earlier block created, and compiled alone it has no idea
                # what ai# is. That is the page working as intended, not a
                # defect, and it is the majority of what compiling in isolation
                # reports. Any other complaint is about the code itself.
                if not IGNORED.search(why):
                    failures.append((current, why))
                current = None

        # A block is identified by where it lives, not by its position, so that
        # editing the prose around it does not read as a new failure.
        seen = {f'{rel}#{why}' for (rel, _), why in failures}

        if '--baseline' in sys.argv:
            with open(BASELINE, 'w', encoding='utf-8', newline='\n') as f:
                f.write('\n'.join(sorted(seen)) + '\n')
            print(f'\nrecorded {len(seen)} known failure(s) as the baseline')
            return 0

        known = set()
        if os.path.exists(BASELINE):
            with open(BASELINE, encoding='utf-8') as f:
                known = {l.strip() for l in f if l.strip()}

        new = sorted(seen - known)
        gone = sorted(known - seen)

        if new:
            print(f'\n{len(new)} block(s) newly failing to compile:\n')
            for key in new:
                rel, why = key.split('#', 1)
                print(f'  {rel}')
                print(f'    {why}')
        # A baseline entry for a failure that no longer happens has stopped
        # describing the tree, and the usual cause is that the file was deleted,
        # so the exception now excuses nothing. Left as a warning it rots: five
        # of these outlived the retired AI archive, the run stayed green, and
        # check-all printed one of the dead filenames where a verdict belongs.
        if gone:
            print(f'\n{len(gone)} known failure(s) no longer occur — '
                  f'rerun with --baseline to record that:\n')
            for key in gone:
                rel = key.split('#', 1)[0]
                lost = '' if os.path.exists(os.path.join(ROOT, rel)) else '   (the file is gone)'
                print(f'  {rel}{lost}')
        if not new and not gone:
            print(f'\nOK - {len(seen)} known failure(s), nothing new')
        return 1 if (new or gone) else 0
    finally:
        if keep:
            print(f'\nkept: {work}')
        else:
            shutil.rmtree(work, ignore_errors=True)


if __name__ == '__main__':
    sys.exit(main())
