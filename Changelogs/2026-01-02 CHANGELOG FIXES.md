# Plan9Basic - Bug Fixes and Improvements

## Version: Patch 1.0
## Date: January 2026

---

## Summary

This document describes all the fixes applied to the Plan9Basic interpreter source code to address critical bugs, improve stability, and ensure 64-bit compatibility.

---

## PHASE 1: CRITICAL FIXES

### 1.1 Stack Overflow Check Timing (exec.pas)
**Location:** `TExec.PushAsmData`
**Severity:** 🔴 Critical
**Issue:** The stack overflow check was performed AFTER writing to the array, which could cause buffer overrun on the last valid index.
**Fix:** Check is now performed BEFORE incrementing the stack pointer.

```pascal
// BEFORE (vulnerable)
Inc(STKP);
StackMem[STKP] := dt;
if STKP = MAXSTACK then RTError(...);

// AFTER (safe)
if STKP >= MAXSTACK - 1 then
begin
  RTError(rteStackOverflow, atkNull);
  Exit;
end;
Inc(STKP);
StackMem[STKP] := dt;
```

### 1.2 Division by Zero in fMod (exec.pas)
**Location:** `TExec.fMod`
**Severity:** 🔴 Critical
**Issue:** The modulo operation did not check for division by zero, unlike the fDiv procedure.
**Fix:** Added zero check before performing the modulo calculation.

### 1.3 Auxiliary Stack Overflow Checks (exec.pas)
**Location:** `TExec.fPushAuxStack`, `TExec.fPushAuxStackS`
**Severity:** 🔴 Critical
**Issue:** Same timing issue as the main stack - overflow check after write.
**Fix:** Check before incrementing, with rollback on type mismatch.

### 1.4 Uninitialized selType Array (parser.pas)
**Location:** `TBasicParser.Clear`
**Severity:** 🔴 Critical
**Issue:** The `selType` array was never initialized, leading to undefined behavior when accessing `selType[selectCnt-1]` in SELECT/CASE statements.
**Fix:** Added initialization loop in the Clear procedure.

### 1.5 Scientific Notation Parsing (lexer.pas)
**Location:** `TBasicLexer.BasGetToken` (number parsing)
**Severity:** 🔴 Critical
**Issue:** Scientific notation parsing had double-increment bug and didn't handle optional signs (+/-) after the exponent.
**Fix:** Completely rewrote the scientific notation handling with proper state machine logic.

---

## PHASE 2: HIGH PRIORITY FIXES

### 2.1 FOR Loop Variable Type Validation (parser.pas)
**Location:** `TBasicParser.ParseFor`
**Severity:** 🟠 High
**Issue:** FOR loop accepted string variables (e.g., `FOR name$ = 1 TO 10`), which would cause runtime errors.
**Fix:** Added explicit type checking with clear error messages for string and pointer variables.

### 2.2 64-bit Pointer Arithmetic Compatibility (exec.pas)
**Location:** Multiple procedures using Pointer/Integer casts
**Severity:** 🟠 High
**Issue:** `Pointer(Integer)` and `Integer(Pointer)` casts are problematic on 64-bit systems where pointer size differs from integer size.
**Fix:** Changed all casts to use `NativeInt` which matches pointer size on both 32-bit and 64-bit platforms.

**Affected procedures:**
- `fCallNear`
- `fRetFunction`
- `fReturn`
- `fPopNCall`
- `fIndirectCall`
- `fOnCallFar`
- `fInput`
- `fInputS`
- `ExecuteFunction`

### 2.3 Timeout Checking Optimization (exec.pas)
**Location:** `TExec.ExecuteProgram`
**Severity:** 🟠 High
**Issue:** Timeout was checked on every single instruction with Timer.Stop/Start calls, causing significant overhead.
**Fix:** Now checks only every 10,000 instructions, dramatically reducing overhead while still providing reasonable timeout detection.

### 2.4 VM State Initialization (exec.pas)
**Location:** `TExec.Clear`
**Severity:** 🟠 High
**Issue:** `BASEP` and `AuxStackIdx` were not reset in the Clear procedure, potentially causing issues when rerunning programs.
**Fix:** Added initialization of both variables to 0.

---

## FILES MODIFIED

| File | Changes |
|------|---------|
| `exec.pas` | 12 modifications |
| `parser.pas` | 2 modifications |
| `lexer.pas` | 1 modification |
| `UtilsUnit.pas` | No changes (reviewed, no critical issues) |

---

## TESTING RECOMMENDATIONS

### Test Cases for Critical Fixes:

1. **Stack Overflow Test**
```basic
' Should gracefully report stack overflow
FUNCTION recurse(n)
  RETURN recurse(n + 1)
ENDFUNCTION
PRINT recurse(1)
```

2. **Division by Zero (MOD)**
```basic
' Should report division by zero error
x = 10 MOD 0
```

3. **Scientific Notation**
```basic
' All should parse correctly
PRINT 1e10
PRINT 1E-5
PRINT 1.5e+3
PRINT .5e2
```

4. **FOR Loop Type Validation**
```basic
' Should report error: "FOR loop variable cannot be a string"
FOR name$ = 1 TO 10
  PRINT name$
NEXT
```

5. **SELECT/CASE Test**
```basic
SELECT CASE x
  CASE 1
    PRINT "One"
  CASE 2
    PRINT "Two"
  CASE ELSE
    PRINT "Other"
END SELECT
```

---

## REMAINING KNOWN ISSUES

### Architectural (Requires Design Decision):
1. **Async INPUT Race Condition** - The INPUT command uses async dialogs but the VM continues executing. This is a fundamental design issue that requires either synchronous input or a VM suspension mechanism.

### Medium Priority (Future Work):
1. Error handling unification (currently uses mix of flags, exceptions, and error strings)
2. Thread safety documentation/implementation
3. Memory management optimization
4. Comprehensive test suite

---

## COMPATIBILITY NOTES

- All changes maintain backward compatibility with existing Plan9Basic programs
- No syntax changes to the language
- No changes to the bytecode format
- Files use Windows (CRLF) line endings for Delphi compatibility

---

## CHANGE LOG

| Date | Version | Description |
|------|---------|-------------|
| 2026-01 | 1.0 | Initial critical and high-priority fixes |

