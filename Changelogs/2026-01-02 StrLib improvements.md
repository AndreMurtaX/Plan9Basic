# StrLib Improvements Summary

## Overview

This document describes the improvements made to `StrLib.pas` for Plan9Basic.

---

## Error Handling System

### New Global Error Tracking

Added a `lastError` variable and `strerror@` function to check the result of the last operation:

| Error Code | Constant | Meaning |
|------------|----------|---------|
| 0 | `ERR_NONE` | Success |
| 1 | `ERR_INDEX_OUT_OF_BOUNDS` | Array/string index out of range |
| 2 | `ERR_INVALID_ARGUMENT` | Invalid parameter value |
| 3 | `ERR_STRING_EMPTY` | Operation on empty string |
| 4 | `ERR_FILE_ERROR` | File read/write error |
| 5 | `ERR_CLIPBOARD_ERROR` | Clipboard operation failed |

**Usage in BASIC:**
```basic
result$ = mid$("hello", 100, 5)
if strerror() <> 0 then
  println "Error occurred!"
endif
```

---

## New Functions Added

| Function | Signature | Description |
|----------|-----------|-------------|
| `trim$` | `trim$@$` | Trim whitespace from both ends |
| `hex$` | `hex$@nn` | Hex with minimum digit count |
| `str$` | `str$@nn` | Number to string with decimal places |
| `left$` | `left$@$` | Get first character |
| `right$` | `right$@$` | Get last character |
| `space$` | `space$@n` | Create string of n spaces |
| `string$` | `string$@nn` | Create string of n chars with ASCII code |
| `instr` | `instr@$$` | Find substring position (0-based, -1 if not found) |
| `instr` | `instr@$$n` | Find substring starting from position |
| `strerror` | `strerror@` | Get last error code |

---

## Improvements to Existing Functions

### Bounds Checking Added

| Function | Improvement |
|----------|-------------|
| `chr$@n` | Validates ASCII/Unicode range (0-65535) |
| `chr$@$n` | Checks index bounds, handles empty string |
| `chr$@$n$` | Checks index bounds and replacement string |
| `mid$@$n` / `mid$@$nn` | Clamps indices to valid range |
| `left$@$n` / `right$@$n` | Clamps count to string length |
| `s_ltab`, `s_rtab`, etc. | Ensures non-negative padding |
| `stuffstring$` | Try/except block, validates indices |
| `line$@$n$` | Fixed memory leak (proper try/finally) |

### Negative Number Handling

| Function | Improvement |
|----------|-------------|
| `hex$@n` | Handles negative numbers with `-` prefix |
| `oct$@n` | Handles negative numbers, fixed zero case |
| `bin$@n` | Handles negative numbers, fixed zero case |

### Helper Functions Added

```pascal
// Clamp Extended to Integer safely
function ClampToInt(Value: Extended): Integer;

// Get encoding from string name (DRY principle)
function GetEncoding(const EncName: String): TEncoding;
```

---

## Function Count

| Category | Original | Improved |
|----------|----------|----------|
| String functions | 35 | 45 |
| New functions | - | 10 |

---

## Breaking Changes

**None.** All existing function signatures remain compatible.

---

## Usage Examples

### New trim$
```basic
s$ = "  hello world  "
println trim$(s$)        ' Output: "hello world"
```

### New instr
```basic
s$ = "hello world"
pos = instr(s$, "world")  ' pos = 6 (0-based)
pos = instr(s$, "xyz")    ' pos = -1 (not found)
pos = instr(s$, "o", 5)   ' pos = 7 (search from position 5)
```

### New str$ with decimals
```basic
pi = 3.14159265
println str$(pi, 2)       ' Output: "3.14"
println str$(pi, 4)       ' Output: "3.1416"
```

### New hex$ with digits
```basic
println hex$(255, 4)      ' Output: "00FF"
println hex$(15, 8)       ' Output: "0000000F"
```

### New space$ and string$
```basic
println "|" + space$(10) + "|"     ' Output: "|          |"
println string$(5, 42)              ' Output: "*****" (42 = '*')
```

### Error checking
```basic
result$ = opentext$("nonexistent.txt", "utf-8")
if strerror() = 4 then
  println "File error occurred"
endif
```

---

## Recommendations for Future

1. **Add `split$` when arrays are available** - Split string into array by delimiter
2. **Add `join$` when arrays are available** - Join array elements into string
3. **Consider regex support** - For pattern matching operations
4. **Add `format$`** - Printf-style string formatting

