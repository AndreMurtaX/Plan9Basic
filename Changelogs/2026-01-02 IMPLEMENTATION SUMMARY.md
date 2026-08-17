# Plan9Basic - Phase 5 Implementation Summary

## Features Implemented

### 1. TRUE/FALSE Boolean Constants

**Lexer (lexer.pas):**
- Added `btkTrue` and `btkFalse` to `TBasToken` enum
- Hash recognition: TRUE=320, FALSE=363

**Parser (parser.pas):**
- `NextValue()` handles `btkTrue` → `PUSHC 1` and `btkFalse` → `PUSHC 0`

**Usage:**
```basic
x = TRUE        ' x = 1
y = FALSE       ' y = 0
IF x = TRUE THEN PRINT "yes"
```

---

### 2. DO...LOOP Structure

Five variants implemented:

#### 2.1 DO WHILE...LOOP (Pre-test, continues while true)
```basic
x = 0
DO WHILE x < 5
  PRINT x
  x = x + 1
LOOP
' Prints: 0, 1, 2, 3, 4
```

#### 2.2 DO UNTIL...LOOP (Pre-test, continues until true)
```basic
x = 0
DO UNTIL x >= 5
  PRINT x
  x = x + 1
LOOP
' Prints: 0, 1, 2, 3, 4
```

#### 2.3 DO...LOOP (Infinite loop)
```basic
x = 0
DO
  PRINT x
  x = x + 1
  IF x >= 5 THEN BREAK
LOOP
' Prints: 0, 1, 2, 3, 4
```

#### 2.4 DO...LOOP WHILE (Post-test, continues while true)
```basic
x = 0
DO
  PRINT x
  x = x + 1
LOOP WHILE x < 5
' Prints: 0, 1, 2, 3, 4
```

#### 2.5 DO...LOOP UNTIL (Post-test, continues until true)
```basic
x = 0
DO
  PRINT x
  x = x + 1
LOOP UNTIL x >= 5
' Prints: 0, 1, 2, 3, 4
```

---

## Implementation Details

### Lexer Changes (lexer.pas)
- New tokens: `btkDo`, `btkLoop`, `btkTrue`, `btkFalse`
- Hash codes: DO=147, LOOP=314, TRUE=320, FALSE=363

### Parser Changes (parser.pas)
- `doCnt` counter for nesting tracking
- `ParseDo()` - handles DO, DO WHILE, DO UNTIL
- `ParseLoop()` - handles LOOP, LOOP WHILE, LOOP UNTIL
- `AssignDo()` - compiler pass to transform intermediate code
- BREAK/CONTINUE support extended for DO/LOOP
- Emits NOT instruction for UNTIL/LOOP WHILE to invert logic

### Exec Changes (exec.pas)
- New ASM tokens: `atkDoStart`, `atkDoWhile`, `atkDoUntil`, `atkLoopEnd`, `atkLoopWhile`, `atkLoopUntil`
- Hash codes for token recognition

### Intermediate Code Flow

**DO WHILE condition ... LOOP:**
```
expr → NOT (if UNTIL) → DO_WHILE n → body → LOOP_END n
        ↓                    ↓              ↓
     (inverts)         POPNJUMP exit    JUMP start
```

**DO ... LOOP WHILE condition:**
```
DO_START n → body → expr → NOT (if WHILE) → LOOP_WHILE n
     ↓                          ↓               ↓
  comment                   (inverts)     POPNJUMP start
```

---

## Files Modified

1. **lexer.pas** - Token definitions and recognition
2. **parser.pas** - Parsing logic and compiler pass
3. **exec.pas** - VM token definitions

---

## Testing Recommendations

```basic
' Test TRUE/FALSE
PRINT TRUE       ' Should print 1
PRINT FALSE      ' Should print 0
PRINT TRUE AND FALSE  ' Should print 0
PRINT TRUE OR FALSE   ' Should print 1

' Test DO WHILE
x = 1
DO WHILE x <= 3
  PRINT "WHILE:"; x
  x = x + 1
LOOP

' Test DO UNTIL  
x = 1
DO UNTIL x > 3
  PRINT "UNTIL:"; x
  x = x + 1
LOOP

' Test LOOP WHILE (post-test)
x = 1
DO
  PRINT "LOOP WHILE:"; x
  x = x + 1
LOOP WHILE x <= 3

' Test LOOP UNTIL (post-test)
x = 1
DO
  PRINT "LOOP UNTIL:"; x
  x = x + 1
LOOP UNTIL x > 3

' Test BREAK in DO loop
x = 1
DO
  IF x > 3 THEN BREAK
  PRINT "BREAK:"; x
  x = x + 1
LOOP

' Test CONTINUE in DO loop
x = 0
DO WHILE x < 5
  x = x + 1
  IF x = 3 THEN CONTINUE
  PRINT "CONTINUE:"; x
LOOP
' Should print 1, 2, 4, 5 (skips 3)

' Test nested DO loops
FOR i = 1 TO 2
  j = 1
  DO WHILE j <= 2
    PRINT i; ","; j
    j = j + 1
  LOOP
NEXT
```
