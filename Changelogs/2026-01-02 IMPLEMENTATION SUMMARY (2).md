# Plan9Basic - Phase 5 Implementation Summary

## Feature Implemented: DO...LOOP Structure

Five variants implemented:

### 1. DO WHILE...LOOP (Pre-test, continues while condition is true)
```basic
x = 0
DO WHILE x < 5
  PRINT x; "\r\n"
  x = x + 1
LOOP
' Prints: 0, 1, 2, 3, 4
```

### 2. DO UNTIL...LOOP (Pre-test, continues until condition becomes true)
```basic
x = 0
DO UNTIL x >= 5
  PRINT x; "\r\n"
  x = x + 1
LOOP
' Prints: 0, 1, 2, 3, 4
```

### 3. DO...LOOP (Infinite loop - use BREAK to exit)
```basic
x = 0
DO
  PRINT x; "\r\n"
  x = x + 1
  IF x >= 5 THEN BREAK
LOOP
' Prints: 0, 1, 2, 3, 4
```

### 4. DO...LOOP WHILE (Post-test, continues while condition is true)
```basic
x = 0
DO
  PRINT x; "\r\n"
  x = x + 1
LOOP WHILE x < 5
' Prints: 0, 1, 2, 3, 4
```

### 5. DO...LOOP UNTIL (Post-test, continues until condition becomes true)
```basic
x = 0
DO
  PRINT x; "\r\n"
  x = x + 1
LOOP UNTIL x >= 5
' Prints: 0, 1, 2, 3, 4
```

---

## Implementation Details

### Lexer Changes (lexer.pas)
- New tokens: `btkDo`, `btkLoop`
- Hash codes: DO=147, LOOP=314

### Parser Changes (parser.pas)
- `doCnt` counter for nesting tracking
- `ParseDo()` - handles DO, DO WHILE, DO UNTIL
- `ParseLoop()` - handles LOOP, LOOP WHILE, LOOP UNTIL
- `AssignDo()` - compiler pass to transform intermediate code
- BREAK/CONTINUE support extended for DO/LOOP

### Exec Changes (exec.pas)
- New ASM tokens: `atkDoStart`, `atkDoWhile`, `atkDoUntil`, `atkLoopEnd`, `atkLoopWhile`, `atkLoopUntil`

---

## Files Modified

1. **lexer.pas** - Token definitions and recognition
2. **parser.pas** - Parsing logic and compiler pass
3. **exec.pas** - VM token definitions

---

## Test Code

```basic
' Test DO WHILE (pre-test)
PRINT "DO WHILE test:" / "\r\n"
x = 1
DO WHILE x <= 3
  PRINT x; "\r\n"
  x = x + 1
LOOP

PRINT "\r\n"

' Test DO UNTIL (pre-test)
PRINT "DO UNTIL test:" / "\r\n"
x = 1
DO UNTIL x > 3
  PRINT x; "\r\n"
  x = x + 1
LOOP

PRINT "\r\n"

' Test DO...LOOP WHILE (post-test)
PRINT "LOOP WHILE test:" / "\r\n"
x = 1
DO
  PRINT x; "\r\n"
  x = x + 1
LOOP WHILE x <= 3

PRINT "\r\n"

' Test DO...LOOP UNTIL (post-test)
PRINT "LOOP UNTIL test:" / "\r\n"
x = 1
DO
  PRINT x; "\r\n"
  x = x + 1
LOOP UNTIL x > 3

PRINT "\r\n"

' Test BREAK in DO loop
PRINT "BREAK test:" / "\r\n"
x = 1
DO
  IF x > 3 THEN BREAK
  PRINT x; "\r\n"
  x = x + 1
LOOP

PRINT "\r\n"

' Test CONTINUE in DO loop
PRINT "CONTINUE test (skips 2):" / "\r\n"
x = 0
DO WHILE x < 4
  x = x + 1
  IF x = 2 THEN CONTINUE
  PRINT x; "\r\n"
LOOP

PRINT "\r\n"

' Test nested DO loops
PRINT "Nested test:" / "\r\n"
i = 1
DO WHILE i <= 2
  j = 1
  DO WHILE j <= 2
    PRINT i, j; "\r\n"
    j = j + 1
  LOOP
  i = i + 1
LOOP
```

### Expected Output
```
DO WHILE test:
1
2
3

DO UNTIL test:
1
2
3

LOOP WHILE test:
1
2
3

LOOP UNTIL test:
1
2
3

BREAK test:
1
2
3

CONTINUE test (skips 2):
1
3
4

Nested test:
1     1
1     2
2     1
2     2
```
