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

#The dispatcher naming the shape it will call. Two forms are in use, and the
#first version of this matched only one:
#
#    Signature := LowerCase(FOnClickFunc) + '@#';           the assignment form
#    ExecuteCallback(LowerCase(FOnTimerFunc) + '@#', Args); 236 sites inline
#    ExecuteCallback(FOnChangeFunc.ToLower() + '@#', ...);  the method form
#
#Missing the second skipped every timer, click, change and drag callback and
#still reported ok; missing the third skipped the track bar. A check that
#skips in silence is the failure this file was written to catch, committed
#inside the file itself.
DISPATCH = re.compile(
    r"(?:LowerCase\(F(\w+?)Func\)|F(\w+?)Func\.ToLower\(\))"
    r"\s*\+\s*'(@[^']*)'")

#A program registering one, e.g.  form_onkeydown#(frm#, "OnKeyDown")
IDENT = '[A-Za-z0-9_#$]'
REGISTER = re.compile(r'\b(\w*_(on\w+))#\s*\(\s*' + IDENT + r'+\s*,\s*"([^"]+)"',
                      re.I)

#The prefix a library answers to, from its own registrations:
#    Lib.Add('form_onkeydown#@#$', Fn)   ->  form
REGISTERS = re.compile(r"Lib\.Add\('([a-z][a-z0-9]*)_on[a-z]")

#A comment naming a signature, so it can be held against the code beside it.
#FormLib documented the keyboard handler as @#nn$ while sending @#n$$, which
#types the third parameter as a number where a string arrives. Whoever reads
#the comment in order to write a handler is told the wrong shape.
COMMENT_SIG = re.compile(r'//.*?@([#n$]+)')

DECLARE = re.compile(r'^\s*function\s+([A-Za-z0-9_]+)\s*\(([^)]*)\)', re.I | re.M)


def declared_types(params):
    """A BASIC parameter list as the engine encodes it: # pointer, $ string,
    anything else a number. This is what the signature lookup compares, so it
    is what a check has to compare."""
    out = ''
    for p in params.split(','):
        p = p.strip()
        if not p:
            continue
        out += '#' if p.endswith('#') else ('$' if p.endswith('$') else 'n')
    return out


def pascal_sources():
    for base, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in SKIP]
        for f in sorted(files):
            if f.endswith('.pas'):
                yield os.path.join(base, f)


#The examples page carries the source of each example inside itself, in a
#template literal, and that copy is what a reader runs. It went unchecked while
#the files did not, and it was the copy still handing out the dead keyboard
#handler of section 28 after the files were fixed.
PAGE = os.path.join(ROOT, 'Website', 'docs', 'examples.html')
EMBEDDED = re.compile(r"id:\s*'([^']+)'.*?code:\s*`(.*?)`\s*[,}]", re.S)


def programs():
    """Every Plan9Basic program in the tree, named and read."""
    for base, dirs, files in os.walk(ROOT):
        dirs[:] = [d for d in dirs if d not in SKIP]
        for f in sorted(files):
            if not f.endswith('.bas'):
                continue
            path = os.path.join(base, f)
            yield (os.path.relpath(path, ROOT).replace(os.sep, '/'),
                   open(path, encoding='utf-8', errors='replace').read())

    if not os.path.isfile(PAGE):
        return
    page = open(PAGE, encoding='utf-8', errors='replace').read()
    rel = os.path.relpath(PAGE, ROOT).replace(os.sep, '/')
    for m in EMBEDDED.finditer(page):
        body = m.group(2)
        #some entries store the newline escaped; a template literal reads
        #both forms the same way
        if chr(92) + 'n' in body and chr(10) not in body:
            body = body.replace(chr(92) + 'n', chr(10))
        yield (rel + ' [' + m.group(1) + ']', body)


def arity(sig):
    """The parameter TYPES a signature describes, as written after the @.

    Counting them was not enough. onmousedown is sent as @#nnn$ by eighteen
    libraries and as @#n$nn by five: the same five parameters with the shift
    string third instead of last. Both are arity 5, so a count-based check
    calls them equal -- and the engine does not, because the signature it
    looks up is the type string. A handler written for one and used on the
    other is dropped in silence, which is the failure this file exists to
    catch, and it would have walked past it.
    """
    return sig[1:]


def stale_comments():
    """Dispatchers whose neighbouring comment names a different signature."""
    out = []
    for path in pascal_sources():
        text = open(path, encoding='utf-8-sig', errors='replace').read()
        lines = text.split(chr(10))
        for i, line in enumerate(lines):
            m = DISPATCH.search(line)
            if not m:
                continue
            built = m.group(3)[1:]
            #the nearest comment above that names a signature at all
            for j in range(i - 1, max(-1, i - 7), -1):
                said = COMMENT_SIG.search(lines[j])
                if said:
                    if said.group(1) != built:
                        out.append((os.path.relpath(path, ROOT).replace(os.sep, '/'),
                                    j + 1, m.group(1) or m.group(2),
                                    said.group(1), built))
                    break
    return out


def main():
    #Keyed by library as well as event, because the same event name is sent in
    #different shapes by different controls: a form's OnKeyDown carries four
    #parameters and another control's carries three. Keyed by event alone this
    #accepted both, and stopped catching the very bug it was written for.
    #
    #Which prefix a library answers to is read from the library itself, not
    #guessed from its filename: CalloutRectangleLib.pas answers callout_*, and
    #FloatAnimationLib.pas answers floatani_*. A table mapping one to the other
    #would be wrong the first time a unit was renamed.
    expected = {}
    for path in pascal_sources():
        text = open(path, encoding='utf-8-sig', errors='replace').read()
        prefixes = {m.lower() for m in REGISTERS.findall(text)}
        if not prefixes:
            continue
        for a, b, sig in DISPATCH.findall(text):
            field = a or b
            name = field.lower()
            if name.startswith('on'):
                name = name[2:]
            for prefix in prefixes:
                expected.setdefault((prefix, name), set()).add(arity(sig))

    problems, checked = [], 0
    unknown = set()
    nameonly = []
    for rel, text in programs():
        regs = REGISTER.findall(text)
        if not regs:
            continue
        declared = {m.group(1).lower(): declared_types(m.group(2))
                    for m in DECLARE.finditer(text)}
        for full, event, fname in regs:
            #form_onkeydown# -> ('form', 'keydown')
            prefix = full.lower().split('_on', 1)[0]
            name = (event.lower()[2:] if event.lower().startswith('on')
                    else event.lower())
            key = (prefix, name)
            want = expected.get(key)
            if not want:
                unknown.add(key)
                continue
            got = declared.get(fname.lower())
            if got is None:
                #Not a defect. Eleven of the library example programs set a
                #callback name and then assert the getter returns it, testing
                #the round trip and never the dispatch, so the name they set
                #need not exist. Counted rather than dropped in silence.
                nameonly.append(rel)
                continue
            checked += 1
            if got not in want:
                problems.append((rel, event, fname, got, sorted(want)))

    for rel, event, fname, got, want in problems:
        print(f'  {rel}')
        print(f'      {event} calls {fname} as @{want[0]}, '
              f'and it declares @{got}')

    if unknown:
        #Named rather than skipped. A name here means a library registers an
        #event no dispatcher calls, or one whose signature is built in a third
        #shape this does not read yet.
        print(f'  {len(unknown)} event(s) no dispatcher names, unchecked:')
        print('     ' + ', '.join(a + '_on' + b for a, b in sorted(unknown)))

    stale = stale_comments()
    for rel, ln, field, said, built in stale:
        print(f'  {rel}:{ln}')
        print(f'      {field} is documented as @{said} and sent as @{built}')

    if nameonly:
        names = sorted(set(nameonly))
        print(f'  {len(nameonly)} registration(s) in {len(names)} program(s) name a')
        print('  function the program never declares, which is how the library')
        print('  round-trip examples are written, and is not a defect.')

    if problems or stale:
        print(f'\n{len(problems)} callback(s) the engine will never find.')
        print('The lookup is exact, so the event is dropped in silence.')
        if stale:
            print(f'{len(stale)} comment(s) name a shape the code does not send.')
        return 1
    print(f'ok  {checked} registered callback(s), every one the right shape')
    return 0


if __name__ == '__main__':
    sys.exit(main())
