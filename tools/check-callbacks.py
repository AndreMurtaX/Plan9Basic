r"""Every callback a program registers, against the signature the engine sends.

A GUI library dispatches an event by building a signature and looking it up:

    Signature := LowerCase(FOnKeyDownFunc) + '@#n$$';
    ...
    if UserFunctionsTable.ContainsKey(Signature) then

ContainsKey is exact. A BASIC function declared with the wrong number of
parameters compiles to a different signature, is never found, and the event is
silently dropped. The key is pressed and the program does not hear.

That is how five of the nine shipped games came to have dead keyboard handlers.
flappy_bird's start screen did not respond to UP, on any platform, and the
applet suites could not see it: they run a program to completion and never send
it an event.

So this reads both sides. The libraries say what shape they will call; the
programs say what shape they declared; and where a name is registered, the two
have to agree.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKIP = ('.git', '__history', 'dist', 'Android64', 'Win64', 'Linux64', 'Win32',
        'OSX64', 'bin')

#The dispatcher's own line, e.g.  Signature := LowerCase(FOnClickFunc) + '@#';
DISPATCH = re.compile(
    r"Signature\s*:=\s*LowerCase\(F(\w+?)Func\)\s*\+\s*'(@[^']*)'")

#A program registering one, e.g.  form_onkeydown#(frm#, "OnKeyDown")
IDENT = '[A-Za-z0-9_#$]'
REGISTER = re.compile(r'\b(\w*_(on\w+))#\s*\(\s*' + IDENT + r'+\s*,\s*"([^"]+)"',
                      re.I)

DECLARE = re.compile(r'^\s*function\s+([A-Za-z0-9_]+)\s*\(([^)]*)\)', re.I | re.M)


def pascal_sources():
    for base, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in SKIP]
        for f in sorted(files):
            if f.endswith('.pas'):
                yield os.path.join(base, f)


def basic_sources():
    for base, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in SKIP]
        for f in sorted(files):
            if f.endswith('.bas'):
                yield os.path.join(base, f)


def arity(sig):
    """How many parameters a signature after the @ describes."""
    return len(sig) - 1


def main():
    #event name (lowercased, without the leading 'On') -> expected arity
    expected = {}
    for path in pascal_sources():
        text = open(path, encoding='utf-8-sig', errors='replace').read()
        for field, sig in DISPATCH.findall(text):
            name = field.lower()
            if name.startswith('on'):
                name = name[2:]
            expected.setdefault(name, set()).add(arity(sig))

    problems, checked = [], 0
    for path in basic_sources():
        text = open(path, encoding='utf-8', errors='replace').read()
        regs = REGISTER.findall(text)
        if not regs:
            continue
        declared = {m.group(1).lower():
                    len([a for a in m.group(2).split(',') if a.strip()])
                    for m in DECLARE.finditer(text)}
        rel = os.path.relpath(path, ROOT).replace(os.sep, '/')
        for _, event, fname in regs:
            want = expected.get(event.lower()[2:] if event.lower().startswith('on')
                                else event.lower())
            if not want:
                continue          # an event no dispatcher names; nothing to check
            got = declared.get(fname.lower())
            if got is None:
                continue          # registered by name only, never declared here
            checked += 1
            if got not in want:
                problems.append((rel, event, fname, got, sorted(want)))

    for rel, event, fname, got, want in problems:
        print(f'  {rel}')
        print(f'      {event} calls {fname} with {want[0]} parameter(s), '
              f'and it declares {got}')

    if problems:
        print(f'\n{len(problems)} callback(s) the engine will never find.')
        print('The lookup is exact, so the event is dropped in silence.')
        return 1
    print(f'ok  {checked} registered callback(s), every one the right shape')
    return 0


if __name__ == '__main__':
    sys.exit(main())
