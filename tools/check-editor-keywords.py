#!/usr/bin/env python3
r"""Does the IDE's editor know the same words the language does?

The editor uppercases reserved words on the line you have just left, and to do
that it carries its own list of them in `TfrmMain.IsKeyword`. That list is a
second copy of something the lexer already knows, maintained by hand, and a
second copy of anything drifts: CONST and ELSEIF were added to the language and
the editor went on treating them as ordinary identifiers, so a program written
in the editor looked different from the same program written anywhere else.

This compares the two and fails when they disagree. It is a text comparison of
two Pascal sources rather than anything clever, which is enough: both lists are
literal strings and neither is computed.

TWO KINDS OF KEYWORD, and the difference matters.

  * Lexer keywords live in TBasicLexer.BasIdentKind. A word there is reserved
    everywhere, so the editor may uppercase it wherever it appears.

  * Contextual keywords -- CONST and ELSEIF -- are NOT in that table, on
    purpose: putting them there would stop them being usable as variable and
    function names, and `const = 7` compiles and runs today. The parser
    recognises them only where a statement begins and only when they are not
    being assigned to, and the editor has to apply the same rule. So these are
    read from the parser instead, and the editor must know them as contextual
    rather than as plain keywords -- listing one in IsKeyword would be a bug of
    the opposite kind.
"""
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LEXER = os.path.join(ROOT, 'engine', 'lexer.pas')
PARSER = os.path.join(ROOT, 'engine', 'parser.pas')
IDE = os.path.join(ROOT, 'UnitMain.pas')


def read(path):
    return open(path, encoding='utf-8', errors='replace').read()


def lexer_keywords():
    """Every word TBasicLexer.BasIdentKind turns into a token."""
    s = read(LEXER)
    m = re.search(r'function\s+TBasicLexer\.BasIdentKind.*?\n\s*end;\s*\nend;',
                  s, re.S | re.I)
    if not m:
        return None
    #The comparisons are written as `tokStr = 'IF'`, and the spelling of the
    #variable is not consistent in that file -- tokstr, tokStr and even TOKsTR
    #all appear. Pascal does not care and neither can this: matching only one
    #spelling silently under-reports, which it did on the first attempt here.
    return {w.upper() for w in re.findall(r"tokstr\s*=\s*'([A-Za-z_]+)'",
                                          m.group(0), re.I)}


def parser_contextual():
    """The words the parser recognises only at the start of a statement."""
    s = read(PARSER)
    return {w.upper() for w in re.findall(r"AtContextualKeyword\('([A-Za-z_]+)'\)", s)}


def ide_keywords():
    s = read(IDE)
    m = re.search(r"function\s+TfrmMain\.IsKeyword.*?\nend;", s, re.S | re.I)
    if not m:
        return None
    return {w.upper() for w in re.findall(r"W\s*=\s*'([A-Za-z_]+)'", m.group(0), re.I)}


def ide_contextual():
    s = read(IDE)
    m = re.search(r"function\s+TfrmMain\.IsContextualKeyword.*?\nend;", s, re.S | re.I)
    if not m:
        return None
    return {w.upper() for w in re.findall(r"SameText\(Word,\s*'([A-Za-z_]+)'\)",
                                          m.group(0), re.I)}


def main():
    problems = []

    lex = lexer_keywords()
    ide = ide_keywords()
    ctx_parser = parser_contextual()
    ctx_ide = ide_contextual()

    for name, value in (('TBasicLexer.BasIdentKind', lex),
                        ('TfrmMain.IsKeyword', ide),
                        ('TfrmMain.IsContextualKeyword', ctx_ide)):
        if value is None:
            problems.append(f'cannot find {name}; this check has stopped '
                            f'checking anything')

    if problems:
        for p in problems:
            print(f'  {p}')
        print(f'\n{len(problems)} problem(s) with the editor keyword lists.')
        return 1

    for w in sorted(lex - ide):
        problems.append(f'{w} is a keyword and the editor does not uppercase it')
    for w in sorted(ide - lex - ctx_parser):
        problems.append(f'the editor uppercases {w} and the lexer does not know it')

    for w in sorted(ctx_parser - ctx_ide):
        problems.append(f'{w} is a contextual keyword in the parser and the '
                        f'editor does not know it')
    for w in sorted(ctx_ide - ctx_parser):
        problems.append(f'the editor treats {w} as a contextual keyword and the '
                        f'parser does not')
    #A contextual keyword listed in IsKeyword would be uppercased everywhere,
    #including where it is somebody's variable.
    for w in sorted(ctx_parser & ide):
        problems.append(f'{w} is contextual and is also in IsKeyword, so the '
                        f'editor would uppercase it where it is a variable')

    for p in problems:
        print(f'  {p}')
    if problems:
        print(f'\n{len(problems)} problem(s) with the editor keyword lists.')
        return 1

    print(f'ok  the editor knows the same {len(lex)} keyword(s) as the lexer, '
          f'and the same {len(ctx_parser)} contextual one(s) as the parser')
    return 0


if __name__ == '__main__':
    sys.exit(main())
