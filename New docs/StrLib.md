# Plan9Basic - StrLib Documentation

## String Library Reference Manual

**Version:** 1.2  
**Date:** January 2026  
**Total Functions:** 63 (with overloads: 75 registered signatures)

---

## Table of Contents

1. [Overview](#overview)
2. [Error Handling](#error-handling)
3. [Case Conversion Functions](#case-conversion-functions)
4. [Trimming Functions](#trimming-functions)
5. [Character Operations](#character-operations)
6. [Number to String Conversion](#number-to-string-conversion)
7. [Substring Operations](#substring-operations)
8. [Padding and Filling Functions](#padding-and-filling-functions)
9. [String Information Functions](#string-information-functions)
10. [String Validation Functions](#string-validation-functions)
11. [Search Functions](#search-functions)
12. [String Comparison Functions](#string-comparison-functions)
13. [String Manipulation Functions](#string-manipulation-functions)
14. [Multi-line String Functions](#multi-line-string-functions)
15. [Delimited String Functions](#delimited-string-functions)
16. [File Operations](#file-operations)
17. [Clipboard Operations](#clipboard-operations)
18. [Complete Examples](#complete-examples)
19. [Quick Reference](#quick-reference)
20. [Internal Implementation Notes](#internal-implementation-notes)

---

## Overview

The StrLib library provides comprehensive string manipulation functions for Plan9Basic programs. With 63 functions (75 registered signatures including overloads) organized into 17 categories, this library covers:

- Case conversion and trimming
- Character-level operations
- Number/string conversions with locale support
- Substring extraction and manipulation
- String searching and pattern matching
- String validation and character classification
- String comparison (case-sensitive and case-insensitive)
- Padding and formatting
- Multi-line string handling
- Delimited string parsing (CSV, paths, etc.)
- File I/O and clipboard operations

### Key Characteristics

| Characteristic | Description |
|----------------|-------------|
| **Indexing** | Zero-based for most functions (see exceptions below) |
| **Error Handling** | Functions set error code retrievable via `strerror()` |
| **Unicode Support** | Full support for Unicode characters (0-65535) |
| **Safe Operations** | Functions handle edge cases gracefully without crashes |
| **Locale Awareness** | `str$()` uses system locale; `stri$()` always uses period |

### Indexing Exceptions (1-based)

- `stuffstring$()` - first character is at position 1
- `word$()` - first word is at position 1

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | `ERR_NONE` | No error - operation succeeded |
| 1 | `ERR_INDEX_OUT_OF_BOUNDS` | Index outside valid range |
| 2 | `ERR_INVALID_ARGUMENT` | Invalid parameter value |
| 3 | `ERR_STRING_EMPTY` | Operation on empty string |
| 4 | `ERR_FILE_ERROR` | File operation failed |
| 5 | `ERR_CLIPBOARD_ERROR` | Clipboard operation failed |

---

## Error Handling

### strerror()

Returns the error code from the last string operation.

**Signature:** `strerror@`

**Syntax:**
```basic
errorCode = strerror()
```

**Returns:** Error code (0 = success, non-zero = error)

**Example:**
```basic
result$ = chr$(65536)  ' Invalid character code (max is 65535)
if strerror() <> 0 then
    println "Error occurred: "; strerror()
endif

' Safe pattern for file operations
content$ = opentext$("data.txt", "utf-8")
if strerror() = 4 then
    println "File error occurred"
else if strerror() = 0 then
    println "File loaded successfully"
endif
```

---

## Case Conversion Functions

### lcase$()

Converts a string to lowercase using standard rules.

**Signature:** `lcase$@$`

**Syntax:**
```basic
result$ = lcase$(string$)
```

**Example:**
```basic
println lcase$("Hello World")    ' Output: hello world
println lcase$("ABC123")         ' Output: abc123
println lcase$("CAFÉ")           ' Output: cafÉ (É may not convert)
```

---

### ucase$()

Converts a string to uppercase using standard rules.

**Signature:** `ucase$@$`

**Syntax:**
```basic
result$ = ucase$(string$)
```

**Example:**
```basic
println ucase$("Hello World")    ' Output: HELLO WORLD
println ucase$("abc123")         ' Output: ABC123
```

---

### alcase$()

Converts a string to lowercase using ANSI locale rules. Provides better support for accented characters in some locales.

**Signature:** `alcase$@$`

**Syntax:**
```basic
result$ = alcase$(string$)
```

**Example:**
```basic
println alcase$("CAFÉ")          ' Output: café
println alcase$("MÜNCHEN")       ' Output: münchen
```

---

### aucase$()

Converts a string to uppercase using ANSI locale rules. Provides better support for accented characters in some locales.

**Signature:** `aucase$@$`

**Syntax:**
```basic
result$ = aucase$(string$)
```

**Example:**
```basic
println aucase$("café")          ' Output: CAFÉ
println aucase$("münchen")       ' Output: MÜNCHEN
```

---

### proper$()

Converts a string to title case (capitalizes the first letter of each word).

**Signature:** `proper$@$`

**Syntax:**
```basic
result$ = proper$(string$)
```

**Description:** Converts the first character of each word to uppercase and the rest to lowercase. Word boundaries include spaces, hyphens, and apostrophes.

**Example:**
```basic
println proper$("hello world")           ' Output: Hello World
println proper$("JOHN DOE")              ' Output: John Doe
println proper$("mary-jane watson")      ' Output: Mary-Jane Watson
println proper$("it's a test")           ' Output: It's A Test
println proper$("café münCHEN")          ' Output: Café München
```

---

### swapcase$()

Swaps uppercase characters to lowercase and vice versa.

**Signature:** `swapcase$@$`

**Syntax:**
```basic
result$ = swapcase$(string$)
```

**Description:** Every uppercase letter becomes lowercase, and every lowercase letter becomes uppercase. Non-letter characters remain unchanged.

**Example:**
```basic
println swapcase$("Hello World")    ' Output: hELLO wORLD
println swapcase$("ABC123xyz")      ' Output: abc123XYZ
println swapcase$("PyThOn")         ' Output: pYtHoN
```

---

## Trimming Functions

### trim$()

Removes whitespace from both sides of a string.

**Signature:** `trim$@$`

**Syntax:**
```basic
result$ = trim$(string$)
```

**Example:**
```basic
println "["; trim$("  Hello World  "); "]"    ' Output: [Hello World]
println "["; trim$("   "); "]"                 ' Output: []
println trim$("  line1  " + chr$(10) + "  line2  ")  ' Trims outer spaces only
```

---

### ltrim$()

Removes whitespace from the left (beginning) of a string.

**Signature:** `ltrim$@$`

**Syntax:**
```basic
result$ = ltrim$(string$)
```

**Example:**
```basic
println "["; ltrim$("  Hello  "); "]"   ' Output: [Hello  ]
```

---

### rtrim$()

Removes whitespace from the right (end) of a string.

**Signature:** `rtrim$@$`

**Syntax:**
```basic
result$ = rtrim$(string$)
```

**Example:**
```basic
println "["; rtrim$("  Hello  "); "]"   ' Output: [  Hello]
```

---

## Character Operations

### chr$() - Create Character from Code

Creates a single-character string from an ASCII/Unicode code.

**Signature:** `chr$@n`

**Syntax:**
```basic
result$ = chr$(charCode)
```

**Parameters:**
| Parameter | Type | Range | Description |
|-----------|------|-------|-------------|
| `charCode` | Number | 0-65535 | Unicode code point |

**Error Conditions:**
- Sets `ERR_INVALID_ARGUMENT` if charCode is outside 0-65535

**Example:**
```basic
println chr$(65)      ' Output: A
println chr$(8364)    ' Output: € (Euro sign)
println chr$(10)      ' Output: (newline)
println chr$(233)     ' Output: é

' Error handling
result$ = chr$(-1)
if strerror() <> 0 then
    println "Invalid character code"
endif
```

---

### chr$() - Get Character at Position

Gets the character at a specific position in a string.

**Signature:** `chr$@$n`

**Syntax:**
```basic
result$ = chr$(string$, position)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | Source string |
| `position` | Number | Zero-based index |

**Error Conditions:**
- Sets `ERR_STRING_EMPTY` if string is empty
- Sets `ERR_INDEX_OUT_OF_BOUNDS` if position is invalid

**Example:**
```basic
text$ = "Hello"
println chr$(text$, 0)    ' Output: H
println chr$(text$, 4)    ' Output: o

' Error handling
result$ = chr$("", 0)
if strerror() = 3 then println "String is empty"

result$ = chr$("Hi", 10)
if strerror() = 1 then println "Index out of bounds"
```

---

### chr$() - Set Character at Position

Replaces the character at a specific position. Returns a new string with the modification.

**Signature:** `chr$@$n$`

**Syntax:**
```basic
result$ = chr$(string$, position, newChar$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | Source string |
| `position` | Number | Zero-based index |
| `newChar$` | String | Replacement (first character used if longer) |

**Error Conditions:**
- Sets `ERR_STRING_EMPTY` if source string is empty
- Sets `ERR_INDEX_OUT_OF_BOUNDS` if position is invalid
- Sets `ERR_INVALID_ARGUMENT` if replacement string is empty

**Example:**
```basic
text$ = "Hello"
println chr$(text$, 0, "J")    ' Output: Jello
println chr$(text$, 4, "a")    ' Output: Hella
println chr$(text$, 1, "XYZ")  ' Output: HXllo (only first char used)
```

---

## Number to String Conversion

### str$() - Basic Conversion

Converts a number to a string using system locale settings.

**Signature:** `str$@n`

**Syntax:**
```basic
result$ = str$(number)
```

**Note:** Uses system locale for decimal separator (period in US/UK, comma in Brazil/Europe).

**Example:**
```basic
println str$(3.14159)    ' Output: 3.14159 or 3,14159 (locale dependent)
println str$(1000)       ' Output: 1000
println str$(-42.5)      ' Output: -42.5 or -42,5
```

---

### str$() - With Decimal Places

Converts a number to a string with a fixed number of decimal places using system locale.

**Signature:** `str$@nn`

**Syntax:**
```basic
result$ = str$(number, decimals)
```

**Parameters:**
| Parameter | Type | Range | Description |
|-----------|------|-------|-------------|
| `number` | Number | Any | Value to convert |
| `decimals` | Number | 0-18 | Number of decimal places |

**Example:**
```basic
println str$(3.14159, 2)    ' Output: 3.14 or 3,14 (locale dependent)
println str$(42, 3)         ' Output: 42.000 or 42,000
println str$(1.5, 0)        ' Output: 2 (rounded)
```

---

### stri$() - Invariant Conversion

Converts a number to a string always using period (.) as decimal separator, regardless of system locale.

**Signature:** `stri$@n`

**Syntax:**
```basic
result$ = stri$(number)
```

**Use Cases:**
- Generating JSON, CSV, or data files
- Writing code or configuration files
- Ensuring consistent output across systems

**Example:**
```basic
' These always output with period, even on European/Brazilian systems
println stri$(3.14159)      ' Output: 3.14159 (always period)
println stri$(1000.5)       ' Output: 1000.5
```

---

### stri$() - Invariant with Decimal Places

Converts a number to a string with fixed decimal places, always using period.

**Signature:** `stri$@nn`

**Syntax:**
```basic
result$ = stri$(number, decimals)
```

**Example:**
```basic
println stri$(3.14159, 2)   ' Output: 3.14 (always period)
println stri$(42, 3)        ' Output: 42.000
```

---

### hex$() - Basic Hexadecimal

Converts a number to hexadecimal string.

**Signature:** `hex$@n`

**Syntax:**
```basic
result$ = hex$(number)
```

**Example:**
```basic
println hex$(255)       ' Output: FF
println hex$(16)        ' Output: 10
println hex$(0)         ' Output: 0
println hex$(-255)      ' Output: -FF (handles negatives)
```

---

### hex$() - With Minimum Digits

Converts a number to hexadecimal with zero-padding.

**Signature:** `hex$@nn`

**Syntax:**
```basic
result$ = hex$(number, minDigits)
```

**Parameters:**
| Parameter | Type | Range | Description |
|-----------|------|-------|-------------|
| `number` | Number | Any integer | Value to convert |
| `minDigits` | Number | 1-16 | Minimum digits (padded with zeros) |

**Example:**
```basic
println hex$(255, 4)     ' Output: 00FF
println hex$(15, 8)      ' Output: 0000000F
println hex$(4095, 2)    ' Output: FFF (not truncated)
println hex$(-255, 4)    ' Output: -00FF
```

---

### oct$()

Converts a number to octal string.

**Signature:** `oct$@n`

**Syntax:**
```basic
result$ = oct$(number)
```

**Example:**
```basic
println oct$(8)         ' Output: 10
println oct$(64)        ' Output: 100
println oct$(0)         ' Output: 0
println oct$(-64)       ' Output: -100 (handles negatives)
```

---

### bin$()

Converts a number to binary string.

**Signature:** `bin$@n`

**Syntax:**
```basic
result$ = bin$(number)
```

**Example:**
```basic
println bin$(5)         ' Output: 101
println bin$(255)       ' Output: 11111111
println bin$(0)         ' Output: 0
println bin$(-5)        ' Output: -101 (handles negatives)
```

---

## Substring Operations

### mid$() - From Position to End

Extracts a substring from a starting position to the end.

**Signature:** `mid$@$n`

**Syntax:**
```basic
result$ = mid$(string$, start)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | Source string |
| `start` | Number | Zero-based starting position |

**Bounds Behavior:** Position is clamped to valid range (no error set).

**Example:**
```basic
println mid$("Hello World", 6)    ' Output: World
println mid$("ABCDEF", 0)         ' Output: ABCDEF
println mid$("ABCDEF", 3)         ' Output: DEF
println mid$("Hello", 100)        ' Output: (empty - clamped)
```

---

### mid$() - With Length

Extracts a substring from a starting position with specified length.

**Signature:** `mid$@$nn`

**Syntax:**
```basic
result$ = mid$(string$, start, length)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | Source string |
| `start` | Number | Zero-based starting position |
| `length` | Number | Number of characters to extract |

**Bounds Behavior:** Both position and length are clamped to valid ranges.

**Example:**
```basic
println mid$("Hello World", 0, 5)     ' Output: Hello
println mid$("Hello World", 6, 5)     ' Output: World
println mid$("Hello", 2, 100)         ' Output: llo (clamped to available)
```

---

### left$() - First N Characters

Gets the first N characters of a string.

**Signature:** `left$@$n`

**Syntax:**
```basic
result$ = left$(string$, count)
```

**Bounds Behavior:** Count is clamped to string length.

**Example:**
```basic
println left$("Hello World", 5)    ' Output: Hello
println left$("Hi", 10)            ' Output: Hi (clamped)
println left$("Test", 0)           ' Output: (empty)
```

---

### left$() - First Character

Gets the first character of a string.

**Signature:** `left$@$`

**Syntax:**
```basic
result$ = left$(string$)
```

**Example:**
```basic
println left$("Hello")    ' Output: H
println left$("A")        ' Output: A
println left$("")         ' Output: (empty)
```

---

### right$() - Last N Characters

Gets the last N characters of a string.

**Signature:** `right$@$n`

**Syntax:**
```basic
result$ = right$(string$, count)
```

**Bounds Behavior:** Count is clamped to string length.

**Example:**
```basic
println right$("Hello World", 5)   ' Output: World
println right$("Hi", 10)           ' Output: Hi (clamped)
println right$("Test", 1)          ' Output: t
```

---

### right$() - Last Character

Gets the last character of a string.

**Signature:** `right$@$`

**Syntax:**
```basic
result$ = right$(string$)
```

**Example:**
```basic
println right$("Hello")   ' Output: o
println right$("A")       ' Output: A
println right$("")        ' Output: (empty)
```

---

### insert$()

Inserts a string at a specified position.

**Signature:** `insert$@$$n`

**Syntax:**
```basic
result$ = insert$(original$, insertString$, position)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `original$` | String | The original string |
| `insertString$` | String | The string to insert |
| `position` | Number | 0-based position where to insert |

**Returns:** New string with insertString$ inserted at the specified position

**Bounds Behavior:** Position is clamped to valid range.

**Example:**
```basic
println insert$("Hello World", "Beautiful ", 6)   ' Output: Hello Beautiful World
println insert$("AC", "B", 1)                     ' Output: ABC
println insert$("Test", "Pre", 0)                 ' Output: PreTest
println insert$("Test", "Post", 4)                ' Output: TestPost
println insert$("Test", "X", 100)                 ' Output: TestX (clamped to end)
```

---

### delete$()

Deletes characters from a string at a specified position.

**Signature:** `delete$@$nn`

**Syntax:**
```basic
result$ = delete$(string$, position, count)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | The original string |
| `position` | Number | 0-based starting position |
| `count` | Number | Number of characters to delete |

**Returns:** New string with the specified characters removed

**Bounds Behavior:** Position and count are handled gracefully.

**Example:**
```basic
println delete$("Hello World", 5, 6)    ' Output: Hello
println delete$("ABCDEF", 2, 2)         ' Output: ABEF
println delete$("Test", 0, 2)           ' Output: st
println delete$("Test", 0, 100)         ' Output: (empty - deleted all)
println delete$("Test", 10, 5)          ' Output: Test (position out of range)
```

---

## Padding and Filling Functions

### ltab$()

Left-pads a string with spaces to reach a specified width.

**Signature:** `ltab$@$n`

**Syntax:**
```basic
result$ = ltab$(string$, width)
```

**Behavior:** If string is already longer than width, returns original string unchanged.

**Example:**
```basic
println "["; ltab$("Hi", 10); "]"      ' Output: [        Hi]
println "["; ltab$("Hello", 3); "]"    ' Output: [Hello] (unchanged)
```

---

### rtab$()

Right-pads a string with spaces to reach a specified width.

**Signature:** `rtab$@$n`

**Syntax:**
```basic
result$ = rtab$(string$, width)
```

**Example:**
```basic
println "["; rtab$("Hi", 10); "]"      ' Output: [Hi        ]
println "["; rtab$("Hello", 3); "]"    ' Output: [Hello] (unchanged)
```

---

### lfill$()

Left-fills a string with a specified character to reach a specified width.

**Signature:** `lfill$@$nn`

**Syntax:**
```basic
result$ = lfill$(string$, width, charCode)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | Source string |
| `width` | Number | Target width |
| `charCode` | Number | ASCII/Unicode code of fill character |

**Example:**
```basic
println lfill$("42", 5, 48)        ' Output: 00042 (48 = '0')
println lfill$("Hi", 8, 45)        ' Output: ------Hi (45 = '-')
println lfill$("Test", 10, 42)     ' Output: ******Test (42 = '*')
```

---

### rfill$()

Right-fills a string with a specified character to reach a specified width.

**Signature:** `rfill$@$nn`

**Syntax:**
```basic
result$ = rfill$(string$, width, charCode)
```

**Example:**
```basic
println rfill$("Item", 10, 46)     ' Output: Item...... (46 = '.')
println rfill$("Price", 15, 32)    ' Output: Price           (32 = space)
```

---

### center$() - With Spaces

Centers a string within a field of specified width using spaces.

**Signature:** `center$@$n`

**Syntax:**
```basic
result$ = center$(string$, width)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | The string to center |
| `width` | Number | Total width of the result |

**Returns:** String padded on both sides to reach the specified width. If the string is already >= width, returns the original string unchanged.

**Example:**
```basic
println "["; center$("Hello", 11); "]"        ' Output: [   Hello   ]
println "["; center$("Hi", 10); "]"           ' Output: [    Hi    ]
println "["; center$("Test", 4); "]"          ' Output: [Test] (no padding needed)
println "["; center$("X", 5); "]"             ' Output: [  X  ]
```

---

### center$() - With Fill Character

Centers a string within a field of specified width using a custom fill character.

**Signature:** `center$@$nn`

**Syntax:**
```basic
result$ = center$(string$, width, fillChar)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | The string to center |
| `width` | Number | Total width of the result |
| `fillChar` | Number | ASCII code of fill character |

**Example:**
```basic
println center$("Title", 11, 45)              ' Output: ---Title--- (45 = hyphen)
println center$("*", 5, 61)                   ' Output: ==*== (61 = equals sign)
println center$("Menu", 20, 42)               ' Output: ********Menu******** (42 = '*')
```

---

### space$()

Creates a string of N space characters.

**Signature:** `space$@n`

**Syntax:**
```basic
result$ = space$(count)
```

**Parameters:**
| Parameter | Type | Range | Description |
|-----------|------|-------|-------------|
| `count` | Number | 0-1000000 | Number of spaces |

**Example:**
```basic
println "|"; space$(10); "|"       ' Output: |          |
indent$ = space$(4)
println indent$ + "Indented text"
```

---

### string$()

Creates a string of N characters with specified ASCII/Unicode code.

**Signature:** `string$@nn`

**Syntax:**
```basic
result$ = string$(count, charCode)
```

**Parameters:**
| Parameter | Type | Range | Description |
|-----------|------|-------|-------------|
| `count` | Number | 0-1000000 | Number of characters |
| `charCode` | Number | 0-65535 | ASCII/Unicode code |

**Example:**
```basic
println string$(5, 42)             ' Output: ***** (42 = '*')
println string$(10, 61)            ' Output: ========== (61 = '=')
println string$(3, 9829)           ' Output: ♥♥♥ (heart symbol)

' Create a separator line
separator$ = string$(40, 45)       ' 40 dashes
println separator$
```

---

## String Information Functions

### len()

Returns the length (number of characters) of a string.

**Signature:** `len@$`

**Syntax:**
```basic
length = len(string$)
```

**Example:**
```basic
println len("Hello")       ' Output: 5
println len("")            ' Output: 0
println len("Olá")         ' Output: 3 (Unicode-aware)
```

---

### asc()

Returns the ASCII/Unicode code of the first character in a string.

**Signature:** `asc@$`

**Syntax:**
```basic
code = asc(string$)
```

**Example:**
```basic
println asc("A")           ' Output: 65
println asc("Hello")       ' Output: 72 (code of 'H')
println asc("€")           ' Output: 8364
println asc("")            ' Output: 0
```

---

### val()

Converts a string to a number.

**Signature:** `val@$`

**Syntax:**
```basic
number = val(string$)
```

**Example:**
```basic
x = val("123")             ' x = 123
y = val("3.14")            ' y = 3.14
z = val("-42.5")           ' z = -42.5
w = val("abc")             ' w = 0 (invalid, check valcode())
```

---

### valcode()

Returns the position where number conversion stopped (0 = success, >0 = error position).

**Signature:** `valcode@`

**Syntax:**
```basic
errorPos = valcode()
```

**Example:**
```basic
x = val("123abc")
println "Value: "; x           ' Output: 123
println "Error at: "; valcode() ' Output: Error at: 4

y = val("456")
println valcode()              ' Output: 0 (no error)
```

---

## String Validation Functions

### isnumeric()

Checks if a string represents a valid number.

**Signature:** `isnumeric@$`

**Syntax:**
```basic
result = isnumeric(string$)
```

**Returns:** 1 if the string can be converted to a number, 0 otherwise

**Example:**
```basic
println isnumeric("123")        ' Output: 1
println isnumeric("-45.67")     ' Output: 1
println isnumeric("3.14e10")    ' Output: 1
println isnumeric("12.34.56")   ' Output: 0
println isnumeric("abc")        ' Output: 0
println isnumeric("  42  ")     ' Output: 1 (whitespace trimmed)
println isnumeric("")           ' Output: 0
```

---

### isalpha()

Checks if a string contains only alphabetic characters (letters).

**Signature:** `isalpha@$`

**Syntax:**
```basic
result = isalpha(string$)
```

**Returns:** 1 if all characters are letters (A-Z, a-z, plus Unicode letters), 0 otherwise

**Example:**
```basic
println isalpha("Hello")        ' Output: 1
println isalpha("café")         ' Output: 1 (accented letters count)
println isalpha("Hello123")     ' Output: 0 (contains digits)
println isalpha("Hello World")  ' Output: 0 (contains space)
println isalpha("")             ' Output: 0
```

---

### isalnum()

Checks if a string contains only alphanumeric characters (letters and digits).

**Signature:** `isalnum@$`

**Syntax:**
```basic
result = isalnum(string$)
```

**Returns:** 1 if all characters are letters or digits, 0 otherwise

**Example:**
```basic
println isalnum("Hello123")     ' Output: 1
println isalnum("ABC")          ' Output: 1
println isalnum("123")          ' Output: 1
println isalnum("Hello World")  ' Output: 0 (contains space)
println isalnum("test@123")     ' Output: 0 (contains @)
println isalnum("")             ' Output: 0
```

---

### isdigits()

Checks if a string contains only digit characters (0-9).

**Signature:** `isdigits@$`

**Syntax:**
```basic
result = isdigits(string$)
```

**Returns:** 1 if all characters are digits, 0 otherwise

**Note:** Unlike `isnumeric()`, this does NOT accept decimal points, negative signs, or scientific notation.

**Example:**
```basic
println isdigits("12345")       ' Output: 1
println isdigits("007")         ' Output: 1
println isdigits("123.45")      ' Output: 0 (decimal point)
println isdigits("-123")        ' Output: 0 (negative sign)
println isdigits("12 34")       ' Output: 0 (space)
println isdigits("")            ' Output: 0
```

---

### isspace()

Checks if a string contains only whitespace characters.

**Signature:** `isspace@$`

**Syntax:**
```basic
result = isspace(string$)
```

**Returns:** 1 if all characters are whitespace (space, tab, newline, etc.), 0 otherwise

**Example:**
```basic
println isspace("   ")          ' Output: 1
println isspace(" " + chr$(9))  ' Output: 1 (space + tab)
println isspace(chr$(10))       ' Output: 1 (newline)
println isspace("  a  ")        ' Output: 0 (contains letter)
println isspace("")             ' Output: 0
```

---

### islower()

Checks if all alphabetic characters in a string are lowercase.

**Signature:** `islower@$`

**Syntax:**
```basic
result = islower(string$)
```

**Returns:** 1 if the string contains at least one letter AND all letters are lowercase, 0 otherwise

**Example:**
```basic
println islower("hello")        ' Output: 1
println islower("hello123")     ' Output: 1 (digits are ignored)
println islower("hello world")  ' Output: 1 (spaces are ignored)
println islower("Hello")        ' Output: 0 (contains uppercase)
println islower("123")          ' Output: 0 (no letters)
println islower("")             ' Output: 0
```

---

### isupper()

Checks if all alphabetic characters in a string are uppercase.

**Signature:** `isupper@$`

**Syntax:**
```basic
result = isupper(string$)
```

**Returns:** 1 if the string contains at least one letter AND all letters are uppercase, 0 otherwise

**Example:**
```basic
println isupper("HELLO")        ' Output: 1
println isupper("HELLO123")     ' Output: 1 (digits are ignored)
println isupper("HELLO WORLD")  ' Output: 1 (spaces are ignored)
println isupper("Hello")        ' Output: 0 (contains lowercase)
println isupper("123")          ' Output: 0 (no letters)
println isupper("")             ' Output: 0
```

---

## Search Functions

### instr() - Find Substring

Finds the position of a substring within a string.

**Signature:** `instr@$$`

**Syntax:**
```basic
position = instr(string$, search$)
```

**Returns:** Zero-based position, or -1 if not found.

**Example:**
```basic
pos = instr("Hello World", "World")    ' pos = 6
pos = instr("Hello World", "xyz")      ' pos = -1
pos = instr("banana", "an")            ' pos = 1 (first occurrence)
```

---

### instr() - Find from Position

Finds a substring starting from a specified position.

**Signature:** `instr@$$n`

**Syntax:**
```basic
position = instr(string$, search$, startPos)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | String to search in |
| `search$` | String | Substring to find |
| `startPos` | Number | Zero-based starting position |

**Example:**
```basic
text$ = "banana"
pos = instr(text$, "an", 0)     ' pos = 1
pos = instr(text$, "an", 2)     ' pos = 3 (second occurrence)
pos = instr(text$, "an", 4)     ' pos = -1 (not found after position 4)
```

---

### instrrev() - Find Last Occurrence

Finds the LAST occurrence of a substring within a string.

**Signature:** `instrrev@$$`

**Syntax:**
```basic
position = instrrev(string$, find$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | The string to search in |
| `find$` | String | The substring to find |

**Returns:** 0-based position of the last occurrence, or -1 if not found

**Example:**
```basic
s$ = "apple,banana,apple,cherry"

println instrrev(s$, "apple")       ' Output: 13 (last "apple")
println instrrev(s$, ",")           ' Output: 19 (last comma)
println instrrev(s$, "grape")       ' Output: -1 (not found)
```

---

### instrrev() - Find Last from Position

Finds the last occurrence of a substring, searching backwards from a specified position.

**Signature:** `instrrev@$$n`

**Syntax:**
```basic
position = instrrev(string$, find$, startPosition)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | The string to search in |
| `find$` | String | The substring to find |
| `startPosition` | Number | Start searching backwards from this position (0-based) |

**Example:**
```basic
s$ = "apple,banana,apple,cherry"

' Search backwards from position 12
println instrrev(s$, "apple", 12)   ' Output: 0 (first "apple")
println instrrev(s$, ",", 15)       ' Output: 12 (comma before "apple")
```

---

### countstr()

Counts the number of occurrences of a substring within a string.

**Signature:** `countstr@$$`

**Syntax:**
```basic
count = countstr(string$, find$)
```

**Returns:** Number of non-overlapping occurrences of find$ in string$

**Example:**
```basic
println countstr("banana", "a")           ' Output: 3
println countstr("banana", "na")          ' Output: 2
println countstr("banana", "x")           ' Output: 0
println countstr("aaa", "aa")             ' Output: 1 (non-overlapping)
println countstr("hello world", " ")      ' Output: 1
println countstr("a,b,c,d,e", ",")        ' Output: 4
```

---

### containsstr()

Checks if a string contains a substring (case-sensitive).

**Signature:** `containsstr@$$`

**Syntax:**
```basic
result = containsstr(string$, search$)
```

**Returns:** 1 if found, 0 if not found.

**Example:**
```basic
println containsstr("Hello World", "World")    ' Output: 1
println containsstr("Hello World", "world")    ' Output: 0 (case-sensitive)
println containsstr("Hello World", "xyz")      ' Output: 0
```

---

### containstext()

Checks if a string contains a substring (case-insensitive).

**Signature:** `containstext@$$`

**Syntax:**
```basic
result = containstext(string$, search$)
```

**Returns:** 1 if found, 0 if not found.

**Example:**
```basic
println containstext("Hello World", "WORLD")   ' Output: 1
println containstext("Hello World", "world")   ' Output: 1
println containstext("Hello World", "xyz")     ' Output: 0
```

---

### startsstr()

Checks if a string starts with a prefix (case-sensitive).

**Signature:** `startsstr@$$`

**Syntax:**
```basic
result = startsstr(prefix$, string$)
```

**Note:** Parameter order: prefix first, then the string to check.

**Returns:** 1 if matches, 0 otherwise.

**Example:**
```basic
println startsstr("Hello", "Hello World")      ' Output: 1
println startsstr("hello", "Hello World")      ' Output: 0 (case-sensitive)
println startsstr("Hi", "Hello World")         ' Output: 0
```

---

### startstext()

Checks if a string starts with a prefix (case-insensitive).

**Signature:** `startstext@$$`

**Syntax:**
```basic
result = startstext(prefix$, string$)
```

**Example:**
```basic
println startstext("HELLO", "Hello World")     ' Output: 1
println startstext("hello", "Hello World")     ' Output: 1
```

---

### endsstr()

Checks if a string ends with a suffix (case-sensitive).

**Signature:** `endsstr@$$`

**Syntax:**
```basic
result = endsstr(suffix$, string$)
```

**Note:** Parameter order: suffix first, then the string to check.

**Returns:** 1 if matches, 0 otherwise.

**Example:**
```basic
println endsstr("World", "Hello World")        ' Output: 1
println endsstr("world", "Hello World")        ' Output: 0 (case-sensitive)
println endsstr(".txt", "document.txt")        ' Output: 1
```

---

### endstext()

Checks if a string ends with a suffix (case-insensitive).

**Signature:** `endstext@$$`

**Syntax:**
```basic
result = endstext(suffix$, string$)
```

**Example:**
```basic
println endstext("WORLD", "Hello World")       ' Output: 1
println endstext(".TXT", "document.txt")       ' Output: 1
```

---

## String Comparison Functions

### strcmp()

Compares two strings lexicographically (case-sensitive).

**Signature:** `strcmp@$$`

**Syntax:**
```basic
result = strcmp(string1$, string2$)
```

**Returns:**
| Value | Meaning |
|-------|---------|
| -1 | string1$ comes before string2$ |
| 0 | strings are equal |
| 1 | string1$ comes after string2$ |

**Example:**
```basic
println strcmp("apple", "banana")   ' Output: -1 (a < b)
println strcmp("hello", "hello")    ' Output: 0  (equal)
println strcmp("zebra", "apple")    ' Output: 1  (z > a)
println strcmp("ABC", "abc")        ' Output: -1 (A < a in ASCII)
println strcmp("", "a")             ' Output: -1 (empty < any)
```

---

### strcmpi()

Compares two strings lexicographically (case-insensitive).

**Signature:** `strcmpi@$$`

**Syntax:**
```basic
result = strcmpi(string1$, string2$)
```

**Returns:** -1, 0, or 1 (same as strcmp but ignoring case)

**Example:**
```basic
println strcmpi("Hello", "hello")   ' Output: 0  (equal, ignoring case)
println strcmpi("ABC", "abc")       ' Output: 0  (equal)
println strcmpi("Apple", "BANANA")  ' Output: -1 (a < b)
println strcmpi("ZEBRA", "apple")   ' Output: 1  (z > a)
```

---

## String Manipulation Functions

### mulstring$()

Repeats a string a specified number of times.

**Signature:** `mulstring$@$n`

**Syntax:**
```basic
result$ = mulstring$(string$, count)
```

**Example:**
```basic
println mulstring$("Ha", 3)        ' Output: HaHaHa
println mulstring$("-=", 5)        ' Output: -=-=-==-==-=
println mulstring$("*", 10)        ' Output: **********
```

---

### replacestr$()

Replaces all occurrences of a substring (case-sensitive).

**Signature:** `replacestr$@$$$`

**Syntax:**
```basic
result$ = replacestr$(string$, find$, replace$)
```

**Example:**
```basic
println replacestr$("Hello World", "World", "BASIC")
' Output: Hello BASIC

println replacestr$("aaa", "a", "bb")
' Output: bbbbbb

println replacestr$("Hello World", "world", "BASIC")
' Output: Hello World (case-sensitive, no match)
```

---

### replacetext$()

Replaces all occurrences of a substring (case-insensitive).

**Signature:** `replacetext$@$$$`

**Syntax:**
```basic
result$ = replacetext$(string$, find$, replace$)
```

**Example:**
```basic
println replacetext$("Hello World", "WORLD", "BASIC")
' Output: Hello BASIC

println replacetext$("The THE the", "the", "a")
' Output: a a a
```

---

### reverse$()

Reverses a string.

**Signature:** `reverse$@$`

**Syntax:**
```basic
result$ = reverse$(string$)
```

**Example:**
```basic
println reverse$("Hello")          ' Output: olleH
println reverse$("12345")          ' Output: 54321
println reverse$("A")              ' Output: A
```

---

### stuffstring$()

Inserts, deletes, or replaces characters at a specified position.

**Signature:** `stuffstring$@$nn$`

**Syntax:**
```basic
result$ = stuffstring$(string$, position, deleteCount, insert$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | Source string |
| `position` | Number | **1-based** starting position |
| `deleteCount` | Number | Characters to delete |
| `insert$` | String | String to insert |

**⚠️ Note:** This function uses **1-based indexing** (unlike most other functions).

**Example:**
```basic
' Insert (delete 0 characters)
println stuffstring$("Hello", 6, 0, " World")      ' Output: Hello World

' Delete (insert empty string)
println stuffstring$("Hello World", 6, 6, "")      ' Output: Hello

' Replace (delete and insert)
println stuffstring$("Hello World", 7, 5, "BASIC") ' Output: Hello BASIC

' Insert at beginning
println stuffstring$("World", 1, 0, "Hello ")      ' Output: Hello World
```

---

## Multi-line String Functions

### count()

Counts the number of lines in a multi-line string.

**Signature:** `count@$`

**Syntax:**
```basic
lineCount = count(string$)
```

**Note:** Lines are separated by newline characters (LF, CR, or CRLF).

**Example:**
```basic
text$ = "Line 1" + chr$(10) + "Line 2" + chr$(10) + "Line 3"
println count(text$)               ' Output: 3

println count("Single line")       ' Output: 1
println count("")                  ' Output: 0
```

---

### line$() - Get Line

Gets a specific line from a multi-line string.

**Signature:** `line$@$n`

**Syntax:**
```basic
result$ = line$(string$, index)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | Multi-line string |
| `index` | Number | Zero-based line index |

**Example:**
```basic
text$ = "Apple" + chr$(10) + "Banana" + chr$(10) + "Cherry"
println line$(text$, 0)            ' Output: Apple
println line$(text$, 1)            ' Output: Banana
println line$(text$, 2)            ' Output: Cherry
```

---

### line$() - Set Line

Sets (replaces) a specific line in a multi-line string.

**Signature:** `line$@$n$`

**Syntax:**
```basic
result$ = line$(string$, index, newLine$)
```

**Returns:** New string with the specified line replaced.

**Example:**
```basic
text$ = "Apple" + chr$(10) + "Banana" + chr$(10) + "Cherry"
text$ = line$(text$, 1, "Orange")
' text$ is now: Apple + newline + Orange + newline + Cherry

println line$(text$, 1)            ' Output: Orange
```

---

## Delimited String Functions

### word$()

Extracts a word at a specified position from a delimited string.

**Signature:** `word$@$n$`

**Syntax:**
```basic
result$ = word$(string$, position, delimiter$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `string$` | String | Delimited string |
| `position` | Number | **1-based** word position |
| `delimiter$` | String | Delimiter string (can be multi-character) |

**⚠️ Note:** This function uses **1-based indexing**.

**Error Conditions:**
- Sets `ERR_INDEX_OUT_OF_BOUNDS` if position is invalid

**Example:**
```basic
csv$ = "John,Doe,35,Engineer"
println word$(csv$, 1, ",")        ' Output: John
println word$(csv$, 2, ",")        ' Output: Doe
println word$(csv$, 3, ",")        ' Output: 35
println word$(csv$, 4, ",")        ' Output: Engineer

' Path parsing
path$ = "C:\Users\Andre\Documents"
println word$(path$, 3, "\")       ' Output: Andre

' Tab-delimited
data$ = "ID" + chr$(9) + "Name" + chr$(9) + "Value"
println word$(data$, 2, chr$(9))   ' Output: Name
```

---

### wordcount()

Counts the number of words in a delimited string.

**Signature:** `wordcount@$$`

**Syntax:**
```basic
count = wordcount(string$, delimiter$)
```

**Example:**
```basic
csv$ = "John,Doe,35,Engineer"
println wordcount(csv$, ",")       ' Output: 4

path$ = "C:\Users\Andre\Documents"
println wordcount(path$, "\")      ' Output: 4

println wordcount("", ",")         ' Output: 0
println wordcount("single", ",")   ' Output: 1
```

---

## File Operations

### opentext$()

Reads the entire contents of a text file.

**Signature:** `opentext$@$$`

**Syntax:**
```basic
content$ = opentext$(filename$, encoding$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `filename$` | String | Path to the file |
| `encoding$` | String | Text encoding (see below) |

**Supported Encodings:**
| Encoding | Aliases |
|----------|---------|
| UTF-8 | `utf8`, `utf-8` |
| UTF-7 | `utf7`, `utf-7` |
| UTF-16 LE | `unicode`, `utf-16`, `utf-16le` |
| UTF-16 BE | `utf-16be`, `big endian unicode` |
| ANSI | `ansi` |
| ASCII | `ascii` |

**Error Conditions:**
- Sets `ERR_FILE_ERROR` if file cannot be read

**Example:**
```basic
content$ = opentext$("data.txt", "utf-8")
if strerror() = 0 then
    println "File loaded: "; len(content$); " characters"
    println "Lines: "; count(content$)
else
    println "Error reading file"
endif
```

---

### savetext$()

Saves a string to a text file.

**Signature:** `savetext$@$$$`

**Syntax:**
```basic
result$ = savetext$(filename$, encoding$, content$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `filename$` | String | Path to the file |
| `encoding$` | String | Text encoding |
| `content$` | String | Content to save |

**Returns:** The content that was saved (for chaining).

**Error Conditions:**
- Sets `ERR_FILE_ERROR` if file cannot be written

**Example:**
```basic
content$ = "Hello World" + chr$(10) + "Line 2"
savetext$("output.txt", "utf-8", content$)

if strerror() = 0 then
    println "File saved successfully"
else
    println "Error saving file"
endif
```

---

## Clipboard Operations

### copytext$()

Copies a string to the system clipboard.

**Signature:** `copytext$@$`

**Syntax:**
```basic
result$ = copytext$(string$)
```

**Returns:** The string that was copied.

**Error Conditions:**
- Sets `ERR_CLIPBOARD_ERROR` if clipboard operation fails

**Example:**
```basic
copytext$("Hello from Plan9Basic!")
if strerror() = 0 then
    println "Text copied to clipboard"
else
    println "Clipboard error"
endif
```

---

### pastetext$()

Retrieves text from the system clipboard.

**Signature:** `pastetext$@`

**Syntax:**
```basic
content$ = pastetext$()
```

**Returns:** The clipboard contents as a string.

**Error Conditions:**
- Sets `ERR_CLIPBOARD_ERROR` if clipboard operation fails

**Example:**
```basic
clipContent$ = pastetext$()
if strerror() = 0 then
    println "Clipboard contains: "; clipContent$
else
    println "Clipboard error or empty"
endif
```

---

## Complete Examples

### Example 1: String Case Manipulation

```basic
' Demonstrate case conversion functions
println "=== Case Conversion Demo ==="
println ""

text$ = "Hello, World! Olá, Mundo!"

println "Original:      "; text$
println "Lowercase:     "; lcase$(text$)
println "Uppercase:     "; ucase$(text$)
println "ANSI Lower:    "; alcase$(text$)
println "ANSI Upper:    "; aucase$(text$)
println "Title Case:    "; proper$(text$)
println "Swap Case:     "; swapcase$(text$)
```

---

### Example 2: Number Formatting Utility

```basic
' Format numbers with various bases and precisions
println "=== Number Formatting Demo ==="
println ""

num = 255

println "Decimal:     "; str$(num)
println "Hex:         "; hex$(num)
println "Hex (4 dig): "; hex$(num, 4)
println "Octal:       "; oct$(num)
println "Binary:      "; bin$(num)
println ""

pi = 3.14159265358979
println "Pi (full):   "; stri$(pi)
println "Pi (2 dec):  "; stri$(pi, 2)
println "Pi (4 dec):  "; stri$(pi, 4)
println "Pi (6 dec):  "; stri$(pi, 6)
```

---

### Example 3: Text Search and Replace

```basic
' Search and replace demonstration using countstr()
println "=== Text Search Demo ==="
println ""

text$ = "The quick brown fox jumps over the lazy dog. The fox is quick."

println "Original text:"
println text$
println ""

println "Occurrences of 'the' (case-sensitive): "; countstr(text$, "the")
println "Occurrences of 'fox': "; countstr(text$, "fox")
println "Contains 'fox': "; containsstr(text$, "fox")
println "Starts with 'The': "; startsstr("The", text$)
println "Ends with 'quick.': "; endsstr("quick.", text$)
println ""

println "Last occurrence of 'fox': "; instrrev(text$, "fox")
println ""

println "After replacing 'fox' with 'cat':"
println replacestr$(text$, "fox", "cat")
```

---

### Example 4: CSV Data Parser

```basic
' Parsing delimited data with word$() and wordcount()
println "=== CSV Parser Demo ==="
println ""

csvLine$ = "John,Doe,35,Engineer,New York"

println "CSV Line: "; csvLine$
println "Field count: "; wordcount(csvLine$, ",")
println ""

println "Extracting fields:"
println "  First Name: "; word$(csvLine$, 1, ",")
println "  Last Name:  "; word$(csvLine$, 2, ",")
println "  Age:        "; word$(csvLine$, 3, ",")
println "  Job:        "; word$(csvLine$, 4, ",")
println "  City:       "; word$(csvLine$, 5, ",")
println ""

' Iterating through all fields
println "All fields via loop:"
fieldCount = wordcount(csvLine$, ",")
for i = 1 to fieldCount
    println "  ["; i; "] "; word$(csvLine$, i, ",")
next
```

---

### Example 5: File Processing

```basic
' Read, process, and save a text file
println "=== File Processing Demo ==="
println ""

' Create sample content
content$ = "Line 1: Hello World" + chr$(10)
content$ = content$ + "Line 2: Plan9Basic is fun" + chr$(10)
content$ = content$ + "Line 3: String processing demo"

' Save to file
savetext$("sample.txt", "utf-8", content$)
if strerror() = 0 then
    println "File saved successfully"
else
    println "Error saving file"
endif

' Read back
loaded$ = opentext$("sample.txt", "utf-8")
if strerror() = 0 then
    println "File loaded successfully"
    println ""
    println "Content:"
    println loaded$
    println ""
    println "Line count: "; count(loaded$)
else
    println "Error loading file"
endif
```

---

### Example 6: Password Strength Checker

```basic
' Check password strength using validation functions
function checkPassword$(password$) local score, hasUpper, hasLower, hasDigit, hasSpecial
    score = 0
    hasUpper = 0
    hasLower = 0
    hasDigit = 0
    hasSpecial = 0
    
    ' Check length
    if len(password$) >= 8 then
        score = score + 1
    endif
    if len(password$) >= 12 then
        score = score + 1
    endif
    
    ' Check character types using validation functions
    for i = 0 to len(password$) - 1
        c$ = chr$(password$, i)
        
        if isupper(c$) = 1 then
            hasUpper = 1
        endif
        if islower(c$) = 1 then
            hasLower = 1
        endif
        if isdigits(c$) = 1 then
            hasDigit = 1
        endif
        if containsstr("!@#$%^&*()_+-=[]{}|;:,.<>?", c$) = 1 then
            hasSpecial = 1
        endif
    next
    
    score = score + hasUpper + hasLower + hasDigit + hasSpecial
    
    if score <= 2 then
        return "Weak"
    else if score <= 4 then
        return "Medium"
    else
        return "Strong"
    endif
endfunction

println "=== Password Strength Checker ==="
println ""

println "password: "; checkPassword$("password")
println "Pass123: "; checkPassword$("Pass123")
println "MyP@ssw0rd!: "; checkPassword$("MyP@ssw0rd!")
println "Str0ng&Secure#2024: "; checkPassword$("Str0ng&Secure#2024")
```

---

### Example 7: Table Formatter

```basic
' Create formatted table output using center$()
println "=== Table Formatter Demo ==="
println ""

' Define column widths
col1 = 15
col2 = 10
col3 = 12

' Header with centered titles
println string$(col1 + col2 + col3 + 8, 45)
println "| "; center$("Name", col1); " | "; center$("Age", col2); " | "; center$("City", col3); " |"
println "|"; string$(col1 + 2, 45); "|"; string$(col2 + 2, 45); "|"; string$(col3 + 2, 45); "|"

' Data rows
println "| "; rtab$("John Doe", col1); " | "; ltab$(str$(35), col2); " | "; rtab$("New York", col3); " |"
println "| "; rtab$("Jane Smith", col1); " | "; ltab$(str$(28), col2); " | "; rtab$("London", col3); " |"
println "| "; rtab$("Bob Wilson", col1); " | "; ltab$(str$(42), col2); " | "; rtab$("Sydney", col3); " |"
println string$(col1 + col2 + col3 + 8, 45)
```

---

### Example 8: Input Validation

```basic
' Validate user input using string validation functions
println "=== Input Validation Demo ==="
println ""

function validateInput$(input$, inputType$) local result$
    result$ = "Invalid"
    
    if inputType$ = "number" then
        if isnumeric(input$) = 1 then
            result$ = "Valid number"
        endif
    else if inputType$ = "alpha" then
        if isalpha(input$) = 1 then
            result$ = "Valid alphabetic"
        endif
    else if inputType$ = "alnum" then
        if isalnum(input$) = 1 then
            result$ = "Valid alphanumeric"
        endif
    else if inputType$ = "digits" then
        if isdigits(input$) = 1 then
            result$ = "Valid digits only"
        endif
    endif
    
    return result$
endfunction

' Test various inputs
println "Testing '12345' as number: "; validateInput$("12345", "number")
println "Testing '-3.14' as number: "; validateInput$("-3.14", "number")
println "Testing 'Hello' as alpha: "; validateInput$("Hello", "alpha")
println "Testing 'Test123' as alnum: "; validateInput$("Test123", "alnum")
println "Testing '00123' as digits: "; validateInput$("00123", "digits")
println "Testing '12.34' as digits: "; validateInput$("12.34", "digits")
```

---

### Example 9: String Sorting with Comparison

```basic
' Simple bubble sort using strcmp()
println "=== String Sorting Demo ==="
println ""

' Store names in a multi-line string
names$ = "Zebra" + chr$(10) + "Apple" + chr$(10) + "Mango" + chr$(10) + "Banana" + chr$(10) + "Cherry"

println "Original order:"
for i = 0 to count(names$) - 1
    println "  "; line$(names$, i)
next
println ""

' Bubble sort
n = count(names$)
for i = 0 to n - 2
    for j = 0 to n - 2 - i
        if strcmp(line$(names$, j), line$(names$, j + 1)) > 0 then
            ' Swap
            temp$ = line$(names$, j)
            names$ = line$(names$, j, line$(names$, j + 1))
            names$ = line$(names$, j + 1, temp$)
        endif
    next
next

println "Sorted order:"
for i = 0 to count(names$) - 1
    println "  "; line$(names$, i)
next
```

---

## Quick Reference

### By Category

#### Error Handling
```basic
strerror()               ' Get last error code (0 = success)
```

#### Case Conversion
```basic
lcase$(s$)               ' To lowercase
ucase$(s$)               ' To uppercase
alcase$(s$)              ' ANSI lowercase (better for accents)
aucase$(s$)              ' ANSI uppercase (better for accents)
proper$(s$)              ' Title case (capitalize words)
swapcase$(s$)            ' Swap upper/lower case
```

#### Trimming
```basic
trim$(s$)                ' Trim both sides
ltrim$(s$)               ' Trim left
rtrim$(s$)               ' Trim right
```

#### Character Operations
```basic
chr$(code)               ' Code to character (0-65535)
chr$(s$, pos)            ' Get char at position (0-based)
chr$(s$, pos, c$)        ' Set char at position
```

#### Number/String Conversion
```basic
str$(n)                  ' Number to string (locale)
str$(n, dec)             ' With decimal places
stri$(n)                 ' Number to string (always period)
stri$(n, dec)            ' With decimal places (period)
hex$(n)                  ' To hexadecimal
hex$(n, digits)          ' Hex with min digits
oct$(n)                  ' To octal
bin$(n)                  ' To binary
val(s$)                  ' String to number
valcode()                ' Conversion error position
```

#### Substring
```basic
mid$(s$, start)          ' From position to end (0-based)
mid$(s$, start, len)     ' From position with length
left$(s$, n)             ' First n characters
left$(s$)                ' First character
right$(s$, n)            ' Last n characters
right$(s$)               ' Last character
insert$(s$, ins$, pos)   ' Insert at position (0-based)
delete$(s$, pos, cnt)    ' Delete at position (0-based)
```

#### Padding/Filling
```basic
ltab$(s$, width)         ' Left-pad with spaces
rtab$(s$, width)         ' Right-pad with spaces
lfill$(s$, width, chr)   ' Left-fill with character
rfill$(s$, width, chr)   ' Right-fill with character
center$(s$, width)       ' Center with spaces
center$(s$, width, chr)  ' Center with fill character
space$(n)                ' String of n spaces
string$(n, chr)          ' String of n characters
```

#### String Info
```basic
len(s$)                  ' String length
asc(s$)                  ' ASCII code of first char
```

#### String Validation
```basic
isnumeric(s$)            ' Check if valid number
isalpha(s$)              ' Check if all letters
isalnum(s$)              ' Check if alphanumeric
isdigits(s$)             ' Check if all digits (0-9)
isspace(s$)              ' Check if all whitespace
islower(s$)              ' Check if all lowercase
isupper(s$)              ' Check if all uppercase
```

#### Search
```basic
instr(s$, find$)         ' Find position (0-based, -1 if not found)
instr(s$, find$, start)  ' Find from position
instrrev(s$, find$)      ' Find last occurrence
instrrev(s$, find$, pos) ' Find last from position
countstr(s$, find$)      ' Count occurrences
containsstr(s$, find$)   ' Contains? (case-sensitive)
containstext(s$, find$)  ' Contains? (case-insensitive)
startsstr(pre$, s$)      ' Starts with? (case-sensitive)
startstext(pre$, s$)     ' Starts with? (case-insensitive)
endsstr(suf$, s$)        ' Ends with? (case-sensitive)
endstext(suf$, s$)       ' Ends with? (case-insensitive)
```

#### Comparison
```basic
strcmp(s1$, s2$)         ' Compare (case-sensitive): -1, 0, 1
strcmpi(s1$, s2$)        ' Compare (case-insensitive): -1, 0, 1
```

#### Manipulation
```basic
mulstring$(s$, n)        ' Repeat string n times
replacestr$(s$, f$, r$)  ' Replace (case-sensitive)
replacetext$(s$, f$, r$) ' Replace (case-insensitive)
reverse$(s$)             ' Reverse string
stuffstring$(s$, p, d, i$)  ' Insert/delete/replace (1-based!)
```

#### Multi-line
```basic
count(s$)                ' Count lines
line$(s$, idx)           ' Get line (0-based)
line$(s$, idx, new$)     ' Set line
```

#### Delimited Strings
```basic
word$(s$, pos, delim$)   ' Get word at position (1-based!)
wordcount(s$, delim$)    ' Count words
```

#### File Operations
```basic
opentext$(file$, enc$)   ' Read file
savetext$(file$, enc$, content$)  ' Write file
```

#### Clipboard
```basic
copytext$(s$)            ' Copy to clipboard
pastetext$()             ' Paste from clipboard
```

---

### All Registered Functions (Alphabetical)

| Function | Signature | Description |
|----------|-----------|-------------|
| `alcase$` | `alcase$@$` | ANSI lowercase |
| `asc` | `asc@$` | ASCII code of first character |
| `aucase$` | `aucase$@$` | ANSI uppercase |
| `bin$` | `bin$@n` | Number to binary |
| `center$` | `center$@$n` | Center with spaces |
| `center$` | `center$@$nn` | Center with fill character |
| `chr$` | `chr$@n` | Code to character |
| `chr$` | `chr$@$n` | Get character at position |
| `chr$` | `chr$@$n$` | Set character at position |
| `containsstr` | `containsstr@$$` | Contains (case-sensitive) |
| `containstext` | `containstext@$$` | Contains (case-insensitive) |
| `copytext$` | `copytext$@$` | Copy to clipboard |
| `count` | `count@$` | Count lines |
| `countstr` | `countstr@$$` | Count occurrences |
| `delete$` | `delete$@$nn` | Delete at position (0-based) |
| `endsstr` | `endsstr@$$` | Ends with (case-sensitive) |
| `endstext` | `endstext@$$` | Ends with (case-insensitive) |
| `hex$` | `hex$@n` | Number to hexadecimal |
| `hex$` | `hex$@nn` | Hex with minimum digits |
| `insert$` | `insert$@$$n` | Insert at position (0-based) |
| `instr` | `instr@$$` | Find substring position |
| `instr` | `instr@$$n` | Find from position |
| `instrrev` | `instrrev@$$` | Find last occurrence |
| `instrrev` | `instrrev@$$n` | Find last from position |
| `isalnum` | `isalnum@$` | Check if alphanumeric |
| `isalpha` | `isalpha@$` | Check if all letters |
| `isdigits` | `isdigits@$` | Check if all digits (0-9) |
| `islower` | `islower@$` | Check if all lowercase |
| `isnumeric` | `isnumeric@$` | Check if valid number |
| `isspace` | `isspace@$` | Check if all whitespace |
| `isupper` | `isupper@$` | Check if all uppercase |
| `lcase$` | `lcase$@$` | Lowercase |
| `left$` | `left$@$` | First character |
| `left$` | `left$@$n` | First N characters |
| `len` | `len@$` | String length |
| `lfill$` | `lfill$@$nn` | Left-fill with character |
| `line$` | `line$@$n` | Get line |
| `line$` | `line$@$n$` | Set line |
| `ltab$` | `ltab$@$n` | Left-pad with spaces |
| `ltrim$` | `ltrim$@$` | Trim left |
| `mid$` | `mid$@$n` | Substring from position |
| `mid$` | `mid$@$nn` | Substring with length |
| `mulstring$` | `mulstring$@$n` | Repeat string |
| `oct$` | `oct$@n` | Number to octal |
| `opentext$` | `opentext$@$$` | Read text file |
| `pastetext$` | `pastetext$@` | Paste from clipboard |
| `proper$` | `proper$@$` | Title case (capitalize words) |
| `replacestr$` | `replacestr$@$$$` | Replace (case-sensitive) |
| `replacetext$` | `replacetext$@$$$` | Replace (case-insensitive) |
| `reverse$` | `reverse$@$` | Reverse string |
| `rfill$` | `rfill$@$nn` | Right-fill with character |
| `right$` | `right$@$` | Last character |
| `right$` | `right$@$n` | Last N characters |
| `rtab$` | `rtab$@$n` | Right-pad with spaces |
| `rtrim$` | `rtrim$@$` | Trim right |
| `savetext$` | `savetext$@$$$` | Save text file |
| `space$` | `space$@n` | String of spaces |
| `startsstr` | `startsstr@$$` | Starts with (case-sensitive) |
| `startstext` | `startstext@$$` | Starts with (case-insensitive) |
| `str$` | `str$@n` | Number to string (locale) |
| `str$` | `str$@nn` | With decimal places |
| `strcmp` | `strcmp@$$` | Compare (case-sensitive) |
| `strcmpi` | `strcmpi@$$` | Compare (case-insensitive) |
| `strerror` | `strerror@` | Get last error code |
| `stri$` | `stri$@n` | Number to string (invariant) |
| `stri$` | `stri$@nn` | Invariant with decimals |
| `string$` | `string$@nn` | String of characters |
| `stuffstring$` | `stuffstring$@$nn$` | Insert/delete/replace |
| `swapcase$` | `swapcase$@$` | Swap upper/lower case |
| `trim$` | `trim$@$` | Trim both sides |
| `ucase$` | `ucase$@$` | Uppercase |
| `val` | `val@$` | String to number |
| `valcode` | `valcode@` | Conversion error position |
| `word$` | `word$@$n$` | Extract word from delimited string |
| `wordcount` | `wordcount@$$` | Count words in delimited string |

---

## Internal Implementation Notes

### Function Registration Pattern

All StrLib functions follow the standard Plan9Basic function signature format:
- `name$@params` for string-returning functions
- `name@params` for number-returning functions
- Parameter types: `n` = number, `$` = string, `#` = pointer

### Helper Functions (Internal)

| Function | Purpose |
|----------|---------|
| `ParseEncoding()` | Converts encoding name to TEncoding |
| `GetEncodingName()` | Converts TEncoding to standardized name |
| `ClampToInt()` | Safely converts Extended to Integer |

### Bounds Handling Philosophy

- Most functions **clamp** values to valid ranges rather than returning errors
- Error codes are set for cases that could indicate programmer mistakes
- Empty strings are handled gracefully (often returning empty string)

### Locale Considerations

| Function | Behavior |
|----------|----------|
| `str$()` | Uses system locale (comma in BR, period in US) |
| `stri$()` | Always uses period (.) - for data interchange |
| `val()` | Attempts to parse with system locale rules |

**Best Practice:** Use `stri$()` when generating JSON, CSV, configuration files, or any data that will be exchanged between systems.

---

*End of StrLib Documentation*
