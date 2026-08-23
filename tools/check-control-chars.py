r"""No stray control characters in the tracked text files.

Written after the README that GitHub renders on the project's front page went
public reading `.<TAB>ools<VT>erify.ps1`. The line was meant to say
`.\tools\verify.ps1`; it had been written through a layer that treated the
backslashes as escapes, so `\t` became a tab and `\v` a vertical tab. The same
accident had already put a backspace into five places in the analysis -- in the
paragraphs describing that exact trap -- and an 0x01 into a sixth, from `\01`.

Nothing catches this by reading. A tab looks like spacing, and a vertical tab
and a backspace look like nothing at all in most editors: the text simply reads
oddly, or renders with a replacement glyph on somebody else's screen. So it is
checked by ordinal rather than by eye.

Tab, newline and carriage return are the three that belong in a text file.
Everything below 0x20 apart from those is a mistake, and so is 0x7F.
"""
import io
import subprocess
import sys

ALLOWED = {0x09, 0x0A, 0x0D}


def tracked():
    out = subprocess.run(['git', 'ls-files'], capture_output=True, text=True).stdout
    return [f for f in out.split('\n') if f]


def offenders(path):
    try:
        raw = io.open(path, 'rb').read()
    except OSError:
        return []
    if b'\x00' in raw[:8000]:      # binary; not this check's business
        return []
    try:
        text = raw.decode('utf-8')
    except UnicodeDecodeError:
        return []                  # not UTF-8 text; likewise
    found = []
    for n, line in enumerate(text.split('\n'), 1):
        bad = sorted({ord(c) for c in line
                      if (ord(c) < 0x20 or ord(c) == 0x7F) and ord(c) not in ALLOWED})
        if bad:
            found.append((n, bad, line.strip()[:70]))
    return found


def main():
    total = 0
    for path in tracked():
        for n, bad, preview in offenders(path):
            total += 1
            names = ', '.join('0x%02X' % b for b in bad)
            print(f'\nFAIL  {path}:{n} carries {names}')
            print(f'      {preview}')
    if total:
        print('\n      A backslash was almost certainly read as an escape on the way')
        print('      in. Write the path with chr(92), or through a tool that does')
        print('      not interpret the string.')
        return 1
    print('  ok  no stray control characters in the tracked text files')
    return 0


if __name__ == '__main__':
    sys.exit(main())
