# Plan9Basic - StrLib Documentation

## String Library Reference Manual

**Version:** 1.0  
**Date:** January 2026

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
10. [Search Functions](#search-functions)
11. [String Manipulation Functions](#string-manipulation-functions)
12. [Multi-line String Functions](#multi-line-string-functions)
13. [Delimited String Functions](#delimited-string-functions)
14. [File Operations](#file-operations)
15. [Clipboard Operations](#clipboard-operations)
16. [Complete Examples](#complete-examples)
17. [Quick Reference](#quick-reference)

---

## Overview

The StrLib library provides comprehensive string manipulation functions for Plan9Basic programs. With over 50 functions organized into 15 categories, this library covers:

- Case conversion and trimming
- Character-level operations
- Number/string conversions with locale support
- Substring extraction and manipulation
- String searching and pattern matching
- Padding and formatting
- Multi-line string handling
- Delimited string parsing (CSV, paths, etc.)
- File I/O and clipboard operations

### Key Characteristics

- **Zero-based indexing**: Most position-based functions use 0-based indexing
- **Error handling**: Functions set an error code retrievable via `strerror()`
- **Unicode support**: Full support for Unicode characters (0-65535)
- **Safe operations**: Functions handle edge cases gracefully without crashes

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_INDEX_OUT_OF_BOUNDS | Index outside valid range |
| 2 | ERR_INVALID_ARGUMENT | Invalid parameter value |
| 3 | ERR_STRING_EMPTY | Operation on empty string |
| 4 | ERR_FILE_ERROR | File operation failed |
| 5 | ERR_CLIPBOARD_ERROR | Clipboard operation failed |

---

## Error Handling

### strerror()

Returns the error code from the last string operation.

**Syntax:**
```basic
errorCode = strerror()
```

**Returns:** Error code (0 = success, non-zero = error)

**Example:**
```basic
result$ = chr$(65536)  ' Invalid character code
if strerror() <> 0 then
    println "Error occurred: "; strerror()
endif
```

---

## Case Conversion Functions

### lcase$()

Converts a string to lowercase.

**Syntax:**
```basic
result$ = lcase$(string$)
```

**Example:**
```basic
println lcase$("Hello World")    ' Output: hello world
println lcase$("ABC123")         ' Output: abc123
```

---

### ucase$()

Converts a string to uppercase.

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

**Syntax:**
```basic
result$ = alcase$(string$)
```

**Example:**
```basic
println alcase$("CAFÉ")          ' Output: café
```

---

### aucase$()

Converts a string to uppercase using ANSI locale rules.

**Syntax:**
```basic
result$ = aucase$(string$)
```

**Example:**
```basic
println aucase$("café")          ' Output: CAFÉ
```

---

## Trimming Functions

### trim$()

Removes whitespace from both sides of a string.

**Syntax:**
```basic
result$ = trim$(string$)
```

**Example:**
```basic
println "["; trim$("  Hello  "); "]"    ' Output: [Hello]
```

---

### ltrim$()

Removes whitespace from the left (beginning) of a string.

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

### chr$() - Create Character

Creates a single-character string from an ASCII/Unicode code.

**Syntax:**
```basic
result$ = chr$(charCode)
```

**Parameters:**
- `charCode`: Integer from 0 to 65535

**Example:**
```basic
println chr$(65)     ' Output: A
println chr$(8364)   ' Output: € (Euro sign)
println chr$(10)     ' Output: (newline)
```

---

### chr$() - Get Character at Position

Gets the character at a specific position in a string.

**Syntax:**
```basic
result$ = chr$(string$, position)
```

**Parameters:**
- `string$`: Source string
- `position`: Zero-based index

**Example:**
```basic
text$ = "Hello"
println chr$(text$, 0)    ' Output: H
println chr$(text$, 4)    ' Output: o
```

---

### chr$() - Set Character at Position

Replaces the character at a specific position.

**Syntax:**
```basic
result$ = chr$(string$, position, newChar$)
```

**Parameters:**
- `string$`: Source string
- `position`: Zero-based index
- `newChar$`: Replacement character (first character used if longer)

**Returns:** Modified string

**Example:**
```basic
text$ = "Hello"
println chr$(text$, 0, "J")    ' Output: Jello
println chr$(text$, 4, "a")    ' Output: Hella
```

---

## Number to String Conversion

### str$() - Basic Conversion

Converts a number to a string using locale settings.

**Syntax:**
```basic
result$ = str$(number)
```

**Example:**
```basic
println str$(3.14159)    ' Output: 3.14159 (or 3,14159 depending on locale)
println str$(1000)       ' Output: 1000
```

---

### str$() - With Decimal Places

Converts a number to a string with a fixed number of decimal places.

**Syntax:**
```basic
result$ = str$(number, decimals)
```

**Parameters:**
- `number`: Value to convert
- `decimals`: Number of decimal places (0-18)

**Example:**
```basic
println str$(3.14159, 2)    ' Output: 3.14
println str$(42, 3)         ' Output: 42.000
```

---

### stri$() - Invariant Conversion

Converts a number to a string always using period (.) as decimal separator, regardless of locale.

**Syntax:**
```basic
result$ = stri$(number)
result$ = stri$(number, decimals)
```

**Example:**
```basic
' These always output with period, even on European systems
println stri$(3.14159)      ' Output: 3.14159
println stri$(3.14159, 2)   ' Output: 3.14
```

**Use Case:** Essential for generating data files, JSON, CSV, or code that must use period as decimal separator.

---

### hex$()

Converts a number to hexadecimal string.

**Syntax:**
```basic
result$ = hex$(number)
result$ = hex$(number, minDigits)
```

**Parameters:**
- `number`: Integer value
- `minDigits`: Minimum digits (padded with zeros, 1-16)

**Example:**
```basic
println hex$(255)        ' Output: FF
println hex$(255, 4)     ' Output: 00FF
println hex$(16, 2)      ' Output: 10
println hex$(-1)         ' Output: -1
```

---

### oct$()

Converts a number to octal string.

**Syntax:**
```basic
result$ = oct$(number)
```

**Example:**
```basic
println oct$(8)      ' Output: 10
println oct$(64)     ' Output: 100
println oct$(255)    ' Output: 377
```

---

### bin$()

Converts a number to binary string.

**Syntax:**
```basic
result$ = bin$(number)
```

**Example:**
```basic
println bin$(5)      ' Output: 101
println bin$(255)    ' Output: 11111111
println bin$(256)    ' Output: 100000000
```

---

## Substring Operations

### mid$() - From Position to End

Extracts a substring from a starting position to the end.

**Syntax:**
```basic
result$ = mid$(string$, startPosition)
```

**Parameters:**
- `string$`: Source string
- `startPosition`: Zero-based starting index

**Example:**
```basic
text$ = "Hello World"
println mid$(text$, 0)     ' Output: Hello World
println mid$(text$, 6)     ' Output: World
println mid$(text$, 10)    ' Output: d
```

---

### mid$() - With Length

Extracts a substring with specified length.

**Syntax:**
```basic
result$ = mid$(string$, startPosition, length)
```

**Example:**
```basic
text$ = "Hello World"
println mid$(text$, 0, 5)     ' Output: Hello
println mid$(text$, 6, 5)     ' Output: World
println mid$(text$, 3, 4)     ' Output: lo W
```

---

### left$()

Extracts characters from the left (beginning) of a string.

**Syntax:**
```basic
result$ = left$(string$, count)
result$ = left$(string$)          ' First character only
```

**Example:**
```basic
text$ = "Hello"
println left$(text$, 3)    ' Output: Hel
println left$(text$)       ' Output: H
```

---

### right$()

Extracts characters from the right (end) of a string.

**Syntax:**
```basic
result$ = right$(string$, count)
result$ = right$(string$)         ' Last character only
```

**Example:**
```basic
text$ = "Hello"
println right$(text$, 3)   ' Output: llo
println right$(text$)      ' Output: o
```

---

## Padding and Filling Functions

### ltab$()

Left-pads a string with spaces to reach a total width (right-aligns content).

**Syntax:**
```basic
result$ = ltab$(string$, totalWidth)
```

**Example:**
```basic
println "["; ltab$("42", 6); "]"      ' Output: [    42]
println "["; ltab$("Hello", 10); "]"  ' Output: [     Hello]
```

---

### rtab$()

Right-pads a string with spaces to reach a total width (left-aligns content).

**Syntax:**
```basic
result$ = rtab$(string$, totalWidth)
```

**Example:**
```basic
println "["; rtab$("42", 6); "]"      ' Output: [42    ]
println "["; rtab$("Hello", 10); "]"  ' Output: [Hello     ]
```

---

### lfill$()

Left-fills a string with a specified character.

**Syntax:**
```basic
result$ = lfill$(string$, totalWidth, charCode)
```

**Parameters:**
- `string$`: String to pad
- `totalWidth`: Desired total width
- `charCode`: ASCII code of fill character

**Example:**
```basic
println lfill$("42", 6, 48)     ' Output: 000042 (48 = '0')
println lfill$("Hi", 10, 45)    ' Output: --------Hi (45 = '-')
```

---

### rfill$()

Right-fills a string with a specified character.

**Syntax:**
```basic
result$ = rfill$(string$, totalWidth, charCode)
```

**Example:**
```basic
println rfill$("42", 6, 48)     ' Output: 420000
println rfill$("Hi", 10, 46)    ' Output: Hi........ (46 = '.')
```

---

### space$()

Creates a string of spaces.

**Syntax:**
```basic
result$ = space$(count)
```

**Example:**
```basic
println "["; space$(5); "]"    ' Output: [     ]
indent$ = space$(4)
println indent$; "Indented text"
```

---

### string$()

Creates a string by repeating a character.

**Syntax:**
```basic
result$ = string$(count, charCode)
```

**Parameters:**
- `count`: Number of characters
- `charCode`: ASCII code of character to repeat

**Example:**
```basic
println string$(10, 42)    ' Output: ********** (42 = '*')
println string$(5, 61)     ' Output: ===== (61 = '=')
line$ = string$(40, 45)    ' Create line of 40 dashes
```

---

## String Information Functions

### len()

Returns the length of a string.

**Syntax:**
```basic
length = len(string$)
```

**Example:**
```basic
println len("Hello")       ' Output: 5
println len("")            ' Output: 0
println len("Café")        ' Output: 4
```

---

### asc()

Returns the ASCII/Unicode code of the first character.

**Syntax:**
```basic
code = asc(string$)
```

**Example:**
```basic
println asc("A")       ' Output: 65
println asc("Hello")   ' Output: 72 (code for 'H')
println asc("€")       ' Output: 8364
```

**Note:** Returns 0 and sets error if string is empty.

---

### val()

Converts a string to a number.

**Syntax:**
```basic
number = val(string$)
```

**Example:**
```basic
println val("42")          ' Output: 42
println val("3.14")        ' Output: 3.14
println val("-100")        ' Output: -100
println val("1.5e10")      ' Output: 15000000000
```

**Note:** Use `valcode()` to check for conversion errors.

---

### valcode()

Returns the error position from the last `val()` call.

**Syntax:**
```basic
errorPos = valcode()
```

**Returns:**
- `0`: Conversion successful
- Non-zero: Position where parsing failed (1-based)

**Example:**
```basic
x = val("123abc")
if valcode() <> 0 then
    println "Conversion failed at position: "; valcode()
endif
```

---

## Search Functions

### instr()

Finds the position of a substring within a string.

**Syntax:**
```basic
position = instr(string$, searchFor$)
position = instr(string$, searchFor$, startPosition)
```

**Returns:** Zero-based position, or -1 if not found

**Example:**
```basic
text$ = "Hello World"
println instr(text$, "World")      ' Output: 6
println instr(text$, "o")          ' Output: 4
println instr(text$, "o", 5)       ' Output: 7 (starting from position 5)
println instr(text$, "xyz")        ' Output: -1
```

---

### containsstr()

Tests if a string contains a substring (case-sensitive).

**Syntax:**
```basic
result = containsstr(string$, searchFor$)
```

**Returns:** 1 if found, 0 if not found

**Example:**
```basic
text$ = "Hello World"
println containsstr(text$, "World")    ' Output: 1
println containsstr(text$, "world")    ' Output: 0 (case-sensitive)
```

---

### containstext()

Tests if a string contains a substring (case-insensitive).

**Syntax:**
```basic
result = containstext(string$, searchFor$)
```

**Returns:** 1 if found, 0 if not found

**Example:**
```basic
text$ = "Hello World"
println containstext(text$, "WORLD")   ' Output: 1
println containstext(text$, "world")   ' Output: 1
```

---

### startsstr()

Tests if a string starts with a prefix (case-sensitive).

**Syntax:**
```basic
result = startsstr(prefix$, string$)
```

**Returns:** 1 if string starts with prefix, 0 otherwise

**Example:**
```basic
println startsstr("Hello", "Hello World")    ' Output: 1
println startsstr("hello", "Hello World")    ' Output: 0
```

---

### startstext()

Tests if a string starts with a prefix (case-insensitive).

**Syntax:**
```basic
result = startstext(prefix$, string$)
```

**Example:**
```basic
println startstext("HELLO", "Hello World")   ' Output: 1
```

---

### endsstr()

Tests if a string ends with a suffix (case-sensitive).

**Syntax:**
```basic
result = endsstr(suffix$, string$)
```

**Returns:** 1 if string ends with suffix, 0 otherwise

**Example:**
```basic
println endsstr("World", "Hello World")      ' Output: 1
println endsstr(".txt", "document.txt")      ' Output: 1
```

---

### endstext()

Tests if a string ends with a suffix (case-insensitive).

**Syntax:**
```basic
result = endstext(suffix$, string$)
```

**Example:**
```basic
println endstext(".TXT", "document.txt")     ' Output: 1
```

---

## String Manipulation Functions

### mulstring$()

Repeats a string a specified number of times.

**Syntax:**
```basic
result$ = mulstring$(string$, count)
```

**Example:**
```basic
println mulstring$("Ha", 3)      ' Output: HaHaHa
println mulstring$("-=", 5)      ' Output: -=-=-=-=-=
```

---

### replacestr$()

Replaces all occurrences of a substring (case-sensitive).

**Syntax:**
```basic
result$ = replacestr$(string$, find$, replace$)
```

**Example:**
```basic
text$ = "Hello World"
println replacestr$(text$, "World", "Universe")   ' Output: Hello Universe
println replacestr$(text$, "l", "L")              ' Output: HeLLo WorLd
```

---

### replacetext$()

Replaces all occurrences of a substring (case-insensitive).

**Syntax:**
```basic
result$ = replacetext$(string$, find$, replace$)
```

**Example:**
```basic
text$ = "Hello World"
println replacetext$(text$, "WORLD", "Universe")  ' Output: Hello Universe
```

---

### reverse$()

Reverses a string.

**Syntax:**
```basic
result$ = reverse$(string$)
```

**Example:**
```basic
println reverse$("Hello")     ' Output: olleH
println reverse$("12345")     ' Output: 54321
```

---

### stuffstring$()

Inserts, deletes, or replaces characters at a specified position.

**Syntax:**
```basic
result$ = stuffstring$(string$, position, deleteCount, insertString$)
```

**Parameters:**
- `string$`: Original string
- `position`: 1-based position to start (not 0-based!)
- `deleteCount`: Number of characters to delete
- `insertString$`: String to insert

**Example:**
```basic
text$ = "Hello World"

' Insert (delete 0 characters)
println stuffstring$(text$, 6, 0, " Beautiful")    ' Output: Hello Beautiful World

' Delete (insert empty string)
println stuffstring$(text$, 6, 6, "")              ' Output: Hello

' Replace (delete and insert)
println stuffstring$(text$, 7, 5, "Universe")      ' Output: Hello Universe
```

**Note:** Unlike most other functions, `stuffstring$()` uses 1-based indexing.

---

## Multi-line String Functions

### count()

Counts the number of lines in a multi-line string.

**Syntax:**
```basic
lineCount = count(string$)
```

**Example:**
```basic
text$ = "Line 1" + chr$(10) + "Line 2" + chr$(10) + "Line 3"
println count(text$)    ' Output: 3
```

---

### line$() - Get Line

Gets a specific line from a multi-line string.

**Syntax:**
```basic
result$ = line$(string$, lineIndex)
```

**Parameters:**
- `string$`: Multi-line string
- `lineIndex`: Zero-based line index

**Example:**
```basic
text$ = "First" + chr$(10) + "Second" + chr$(10) + "Third"
println line$(text$, 0)    ' Output: First
println line$(text$, 1)    ' Output: Second
println line$(text$, 2)    ' Output: Third
```

---

### line$() - Set Line

Replaces a specific line in a multi-line string.

**Syntax:**
```basic
result$ = line$(string$, lineIndex, newLine$)
```

**Returns:** Modified multi-line string

**Example:**
```basic
text$ = "Line 1" + chr$(10) + "Line 2" + chr$(10) + "Line 3"
text$ = line$(text$, 1, "Modified Line")
println text$
' Output:
' Line 1
' Modified Line
' Line 3
```

---

## Delimited String Functions

Functions for working with strings containing delimited data such as CSV, paths, or any custom-delimited format.

### word$()

Extracts a word (token) at a specific position from a delimited string.

**Syntax:**
```basic
result$ = word$(string$, position, delimiter$)
```

**Parameters:**
- `string$`: Source string containing delimited values
- `position`: Which word to extract (1-based index, first word is 1)
- `delimiter$`: Character(s) that separate words

**Returns:** The word at the specified position, or empty string if position is out of bounds

**Example:**
```basic
' Extract from comma-separated list
fruits$ = "apple,banana,cherry,date,elderberry"

println word$(fruits$, 1, ",")    ' Output: apple
println word$(fruits$, 2, ",")    ' Output: banana
println word$(fruits$, 3, ",")    ' Output: cherry
println word$(fruits$, 5, ",")    ' Output: elderberry
println word$(fruits$, 10, ",")   ' Output: (empty - out of bounds)

' Extract from file path (Windows)
path$ = "C:/Users/Andre/Documents/Plan9Basic"
println word$(path$, 3, "/")      ' Output: Andre
println word$(path$, 5, "/")      ' Output: Plan9Basic

' Extract from sentence
sentence$ = "The quick brown fox"
println word$(sentence$, 2, " ")  ' Output: quick

' Multi-character delimiter
data$ = "one<=>two<=>three"
println word$(data$, 2, "<=>")    ' Output: two
```

**Notes:**
- Position is 1-based (first word is at position 1)
- Returns empty string and sets error code if position is invalid
- Empty delimiter returns the entire string at position 1
- Adjacent delimiters create empty words

---

### wordcount()

Counts the number of words (tokens) in a delimited string.

**Syntax:**
```basic
count = wordcount(string$, delimiter$)
```

**Parameters:**
- `string$`: Source string containing delimited values
- `delimiter$`: Character(s) that separate words

**Returns:** Number of words in the string

**Example:**
```basic
fruits$ = "apple,banana,cherry,date"
println wordcount(fruits$, ",")       ' Output: 4

path$ = "C:\Users\Andre\Documents"
println wordcount(path$, "\")         ' Output: 4

sentence$ = "The quick brown fox"
println wordcount(sentence$, " ")     ' Output: 4

' Empty string has 0 words
println wordcount("", ",")            ' Output: 0

' String without delimiter has 1 word
println wordcount("single", ",")      ' Output: 1

' Multi-character delimiter
data$ = "a<=>b<=>c<=>d"
println wordcount(data$, "<=>")       ' Output: 4
```

**Notes:**
- Empty string returns 0
- String with no delimiter occurrences returns 1
- Empty delimiter returns 1 (entire string is one word)

---

## File Operations

### opentext$()

Reads a text file into a string.

**Syntax:**
```basic
content$ = opentext$(filename$, encoding$)
```

**Parameters:**
- `filename$`: Path to the file
- `encoding$`: Text encoding (see table below)

**Supported Encodings:**
| Encoding Name | Description |
|---------------|-------------|
| `"utf-8"` | UTF-8 (recommended) |
| `"utf-7"` | UTF-7 |
| `"ansi"` | ANSI (system default) |
| `"ascii"` | ASCII |
| `"unicode"` | UTF-16 Little Endian |
| `"big endian unicode"` | UTF-16 Big Endian |
| `""` (empty) | System default |

**Example:**
```basic
content$ = opentext$("myfile.txt", "utf-8")
if strerror() = 0 then
    println "File content:"
    println content$
else
    println "Error reading file"
endif
```

---

### savetext$()

Saves a string to a text file.

**Syntax:**
```basic
result$ = savetext$(filename$, encoding$, content$)
```

**Returns:** Filename if successful, empty string on error

**Example:**
```basic
content$ = "Hello, World!" + chr$(10) + "This is a test."
result$ = savetext$("output.txt", "utf-8", content$)
if strerror() = 0 then
    println "File saved successfully"
else
    println "Error saving file"
endif
```

---

## Clipboard Operations

### copytext$()

Copies text to the system clipboard.

**Syntax:**
```basic
result$ = copytext$(text$)
```

**Returns:** The copied text if successful, empty string on error

**Example:**
```basic
copytext$("Text to copy")
if strerror() = 0 then
    println "Copied to clipboard"
endif
```

---

### pastetext$()

Retrieves text from the system clipboard.

**Syntax:**
```basic
result$ = pastetext$()
```

**Returns:** Clipboard content, or empty string on error

**Example:**
```basic
clipboard$ = pastetext$()
if strerror() = 0 then
    println "Clipboard contains: "; clipboard$
else
    println "Could not access clipboard"
endif
```

---

## Complete Examples

### Example 1: String Validation and Cleaning

```basic
' Clean and validate user input
function cleanInput$(input$) local result$
    ' Remove leading/trailing whitespace
    result$ = trim$(input$)
    
    ' Check if empty after trimming
    if len(result$) = 0 then
        return ""
    endif
    
    return result$
endfunction

function isValidEmail$(email$) local atPos, dotPos
    email$ = cleanInput$(email$)
    if len(email$) = 0 then
        return 0
    endif
    
    ' Check for @ symbol
    atPos = instr(email$, "@")
    if atPos < 1 then
        return 0
    endif
    
    ' Check for . after @
    dotPos = instr(email$, ".", atPos)
    if dotPos < 0 then
        return 0
    endif
    
    return 1
endfunction

println "=== Email Validator ==="
println ""

test1$ = "user@example.com"
test2$ = "invalid-email"
test3$ = "  spaced@test.org  "

println test1$; " - Valid: "; isValidEmail$(test1$)
println test2$; " - Valid: "; isValidEmail$(test2$)
println test3$; " - Valid: "; isValidEmail$(test3$)
```

---

### Example 2: Formatted Table Output

```basic
' Create a formatted table
println "=== Product Price List ==="
println ""

' Header
println rtab$("Product", 20); ltab$("Price", 10); ltab$("Qty", 8)
println string$(38, 45)   ' Line of dashes

' Data rows
println rtab$("Widget", 20); ltab$(str$(19.99, 2), 10); ltab$("100", 8)
println rtab$("Gadget", 20); ltab$(str$(49.99, 2), 10); ltab$("50", 8)
println rtab$("Gizmo", 20); ltab$(str$(9.99, 2), 10); ltab$("200", 8)
println rtab$("Thingamajig", 20); ltab$(str$(149.99, 2), 10); ltab$("25", 8)

println string$(38, 45)   ' Line of dashes
```

---

### Example 3: Number Base Converter

```basic
' Convert numbers between bases
function showBases(n) local dummy
    println "Decimal: "; n
    println "Hexadecimal: "; hex$(n)
    println "Octal: "; oct$(n)
    println "Binary: "; bin$(n)
    return 0
endfunction

println "=== Number Base Converter ==="
println ""

println "Number: 255"
showBases(255)

println ""
println "Number: 42"
showBases(42)

println ""
println "Number: 1000"
showBases(1000)
```

---

### Example 4: Text Search and Replace

```basic
' Search and replace demonstration
function countOccurrences(text$, search$) local count, pos, startPos
    count = 0
    startPos = 0
    
    pos = instr(text$, search$, startPos)
    while pos >= 0
        count = count + 1
        startPos = pos + 1
        pos = instr(text$, search$, startPos)
    wend
    
    return count
endfunction

println "=== Text Search Demo ==="
println ""

text$ = "The quick brown fox jumps over the lazy dog. The fox is quick."

println "Original text:"
println text$
println ""

println "Occurrences of 'the' (case-sensitive): "; countOccurrences(text$, "the")
println "Contains 'fox': "; containsstr(text$, "fox")
println "Starts with 'The': "; startsstr("The", text$)
println "Ends with 'quick.': "; endsstr("quick.", text$)
println ""

println "After replacing 'fox' with 'cat':"
println replacestr$(text$, "fox", "cat")
```

---

### Example 5: CSV and Delimited Data Parser

```basic
' Parsing delimited data with word$() and wordcount()
println "=== Delimited Data Parser Demo ==="
println ""

' CSV data example
csvLine$ = "John,Doe,35,Engineer,New York"

println "CSV Line: "; csvLine$
println "Field count: "; wordcount(csvLine$, ",")
println ""

println "Extracting fields:"
println "  Field 1 (First Name): "; word$(csvLine$, 1, ",")
println "  Field 2 (Last Name):  "; word$(csvLine$, 2, ",")
println "  Field 3 (Age):        "; word$(csvLine$, 3, ",")
println "  Field 4 (Job):        "; word$(csvLine$, 4, ",")
println "  Field 5 (City):       "; word$(csvLine$, 5, ",")
println ""

' Iterating through all fields
println "All fields via loop:"
let fieldCount = wordcount(csvLine$, ",")
let i = 1
while i <= fieldCount
    println "  ["; i; "] "; word$(csvLine$, i, ",")
    i = i + 1
wend
println ""

' File path parsing example
println "=== Path Parsing ==="
path$ = "C:\Users\Andre\Documents\Project\file.txt"
println "Path: "; path$
println "Components: "; wordcount(path$, "\")
println "  Drive:  "; word$(path$, 1, "\")
println "  Folder: "; word$(path$, 2, "\")
println "  User:   "; word$(path$, 3, "\")
println "  File:   "; word$(path$, 6, "\")
println ""

' Semicolon-delimited data
println "=== Database Record ==="
record$ = "101;Product A;29.99;150;Electronics"
println "Record: "; record$
println "  ID:       "; word$(record$, 1, ";")
println "  Name:     "; word$(record$, 2, ";")
println "  Price:    "; word$(record$, 3, ";")
println "  Stock:    "; word$(record$, 4, ";")
println "  Category: "; word$(record$, 5, ";")
```

---

### Example 6: Text File Processing

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

### Example 7: Password Strength Checker

```basic
' Check password strength
function checkPassword$(password$) local score, i, c$, hasUpper, hasLower, hasDigit, hasSpecial
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
    
    ' Check character types
    for i = 0 to len(password$) - 1
        c$ = chr$(password$, i)
        
        if asc(c$) >= 65 and asc(c$) <= 90 then
            hasUpper = 1
        endif
        if asc(c$) >= 97 and asc(c$) <= 122 then
            hasLower = 1
        endif
        if asc(c$) >= 48 and asc(c$) <= 57 then
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

## Quick Reference

### Case Conversion
```basic
lcase$(s$)               ' To lowercase
ucase$(s$)               ' To uppercase
alcase$(s$)              ' ANSI lowercase
aucase$(s$)              ' ANSI uppercase
```

### Trimming
```basic
trim$(s$)                ' Trim both sides
ltrim$(s$)               ' Trim left
rtrim$(s$)               ' Trim right
```

### Character Operations
```basic
chr$(code)               ' Code to character
chr$(s$, pos)            ' Get char at position (0-based)
chr$(s$, pos, c$)        ' Set char at position
```

### Number/String Conversion
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

### Substring
```basic
mid$(s$, start)          ' From position to end (0-based)
mid$(s$, start, len)     ' From position with length
left$(s$, n)             ' First n characters
left$(s$)                ' First character
right$(s$, n)            ' Last n characters
right$(s$)               ' Last character
```

### Padding/Filling
```basic
ltab$(s$, width)         ' Left-pad with spaces
rtab$(s$, width)         ' Right-pad with spaces
lfill$(s$, width, chr)   ' Left-fill with character
rfill$(s$, width, chr)   ' Right-fill with character
space$(n)                ' String of n spaces
string$(n, chr)          ' String of n characters
```

### String Info
```basic
len(s$)                  ' String length
asc(s$)                  ' ASCII code of first char
```

### Search
```basic
instr(s$, find$)         ' Find position (0-based, -1 if not found)
instr(s$, find$, start)  ' Find from position
containsstr(s$, find$)   ' Contains? (case-sensitive)
containstext(s$, find$)  ' Contains? (case-insensitive)
startsstr(pre$, s$)      ' Starts with? (case-sensitive)
startstext(pre$, s$)     ' Starts with? (case-insensitive)
endsstr(suf$, s$)        ' Ends with? (case-sensitive)
endstext(suf$, s$)       ' Ends with? (case-insensitive)
```

### Manipulation
```basic
mulstring$(s$, n)        ' Repeat string n times
replacestr$(s$, f$, r$)  ' Replace (case-sensitive)
replacetext$(s$, f$, r$) ' Replace (case-insensitive)
reverse$(s$)             ' Reverse string
stuffstring$(s$, p, d, i$)  ' Insert/delete/replace (1-based!)
```

### Multi-line
```basic
count(s$)                ' Count lines
line$(s$, idx)           ' Get line (0-based)
line$(s$, idx, new$)     ' Set line
```

### Delimited Strings
```basic
word$(s$, pos, delim$)   ' Get word at position (1-based)
wordcount(s$, delim$)    ' Count words in delimited string
```

### File Operations
```basic
opentext$(file$, enc$)   ' Read file
savetext$(file$, enc$, content$)  ' Write file
```

### Clipboard
```basic
copytext$(s$)            ' Copy to clipboard
pastetext$()             ' Paste from clipboard
```

### Error Handling
```basic
strerror()               ' Get last error code
```

---

## Important Notes

### Indexing Conventions

- **Most functions use 0-based indexing** (first character/line is at position 0)
- **Exceptions using 1-based indexing:**
  - `stuffstring$()` - first character is at position 1
  - `word$()` - first word is at position 1

### Locale Considerations

- `str$()` respects system locale settings for decimal separator
- `stri$()` always uses period (.) as decimal separator
- Use `stri$()` when generating data for other systems or file formats

### Parameter Order for Search Functions

Note the parameter order for search functions:

```basic
' These search IN the second parameter
startsstr(prefix$, string$)    ' Does string$ start with prefix$?
endsstr(suffix$, string$)      ' Does string$ end with suffix$?

' This searches IN the first parameter
instr(string$, searchFor$)     ' Find searchFor$ in string$
containsstr(string$, searchFor$)
```

---

*End of StrLib Documentation*
