# RegexLib - Regular Expression Library for Plan9Basic

## Overview

RegexLib provides comprehensive regular expression support for Plan9Basic, enabling pattern matching, searching, replacing, and splitting operations on strings. The library uses Delphi's `System.RegularExpressions` unit internally.

**Function Count:** 28 functions

## Constants

### Regex Options

Options can be combined using the `+` operator. Plan9Basic does not have predefined constants, so you can either use the numeric values directly or define your own variables:

| Option Name | Value | Description |
|-------------|-------|-------------|
| REGEX_IGNORECASE | 1 | Case-insensitive matching |
| REGEX_MULTILINE | 2 | `^` and `$` match line boundaries |
| REGEX_SINGLELINE | 4 | `.` matches newlines |
| REGEX_EXPLICITCAPTURE | 8 | Only named/numbered groups capture |

**Using numeric values directly:**
```basic
' Case-insensitive and multiline (1 + 2 = 3)
found = regex_match("[a-z]+", text$, 3)
```

**Defining your own constants:**
```basic
' Define at the start of your program
let REGEX_IGNORECASE = 1
let REGEX_MULTILINE = 2
let REGEX_SINGLELINE = 4
let REGEX_EXPLICITCAPTURE = 8

' Then use them
opts = REGEX_IGNORECASE + REGEX_MULTILINE
found = regex_match("[a-z]+", text$, opts)
```

## Function Reference

### Validation Functions

#### regex_isvalid(pattern$)
Check if a pattern is a valid regular expression.

**Parameters:**
- `pattern$` - The regex pattern to validate

**Returns:** `1` if valid, `0` if invalid

**Example:**
```basic
if regex_isvalid("[a-z]+") = 1 then
  println "Valid pattern"
endif
```

---

#### regex_error$(pattern$)
Get the error message for an invalid pattern.

**Parameters:**
- `pattern$` - The regex pattern to check

**Returns:** Empty string if valid, error message if invalid

**Example:**
```basic
err$ = regex_error$("[invalid")
if err$ <> "" then
  println "Error: " + err$
endif
```

---

### Basic Matching Functions

#### regex_match(pattern$, text$)
#### regex_match(pattern$, text$, options)
Check if pattern matches anywhere in text.

**Parameters:**
- `pattern$` - Regex pattern
- `text$` - Text to search
- `options` - (Optional) Regex options

**Returns:** `1` if match found, `0` if not

**Example:**
```basic
' Check for digits
if regex_match("\d+", "abc123def") = 1 then
  println "Contains numbers"
endif

' Case-insensitive match (option 1 = ignore case)
if regex_match("hello", "HELLO WORLD", 1) = 1 then
  println "Found hello"
endif
```

---

#### regex_matchfull(pattern$, text$)
#### regex_matchfull(pattern$, text$, options)
Check if pattern matches the entire text (not just a substring).

**Parameters:**
- `pattern$` - Regex pattern
- `text$` - Text to match
- `options` - (Optional) Regex options

**Returns:** `1` if full match, `0` if not

**Example:**
```basic
' Validate email format
email$ = "user@example.com"
if regex_matchfull("^[\w.-]+@[\w.-]+\.\w+$", email$) = 1 then
  println "Valid email format"
endif
```

---

### Find/Search Functions

#### regex_find$(pattern$, text$)
#### regex_find$(pattern$, text$, options)
Find the first match in text.

**Parameters:**
- `pattern$` - Regex pattern
- `text$` - Text to search
- `options` - (Optional) Regex options

**Returns:** Matched string, or empty string if no match

**Example:**
```basic
' Extract first number
num$ = regex_find$("\d+", "Price: $42.99")
println "Found: " + num$  ' Output: Found: 42
```

---

#### regex_findpos(pattern$, text$)
#### regex_findpos(pattern$, text$, options)
Find the position of the first match.

**Parameters:**
- `pattern$` - Regex pattern
- `text$` - Text to search
- `options` - (Optional) Regex options

**Returns:** 1-based position, or `0` if no match

**Example:**
```basic
pos = regex_findpos("\d", "abc123")
println "First digit at position: " + str$(pos)  ' Output: 4
```

---

#### regex_findlen(pattern$, text$)
#### regex_findlen(pattern$, text$, options)
Find the length of the first match.

**Parameters:**
- `pattern$` - Regex pattern
- `text$` - Text to search
- `options` - (Optional) Regex options

**Returns:** Length of match, or `0` if no match

**Example:**
```basic
len = regex_findlen("\d+", "abc123def")
println "Match length: " + str$(len)  ' Output: 3
```

---

### Find All Functions

#### regex_findall#(pattern$, text$)
#### regex_findall#(pattern$, text$, options)
Find all matches in text.

**Parameters:**
- `pattern$` - Regex pattern
- `text$` - Text to search
- `options` - (Optional) Regex options

**Returns:** TStringList pointer containing all matches (0-based indexing)

**Example:**
```basic
' Find all words
matches# = regex_findall#("\w+", "Hello World Test")
n = strings_count(matches#)
for i = 0 to n - 1
  println strings_strings$(matches#, i)
next
' Output:
' Hello
' World
' Test
```

---

#### regex_count(pattern$, text$)
#### regex_count(pattern$, text$, options)
Count the number of matches.

**Parameters:**
- `pattern$` - Regex pattern
- `text$` - Text to search
- `options` - (Optional) Regex options

**Returns:** Number of matches

**Example:**
```basic
' Count vowels (option 1 = ignore case)
cnt = regex_count("[aeiou]", "Hello World", 1)
println "Vowel count: " + str$(cnt)  ' Output: 3
```

---

### Replace Functions

#### regex_replace$(pattern$, text$, replacement$)
#### regex_replace$(pattern$, text$, replacement$, options)
Replace all matches with replacement string.

**Parameters:**
- `pattern$` - Regex pattern
- `text$` - Original text
- `replacement$` - Replacement string
- `options` - (Optional) Regex options

**Returns:** Text with all matches replaced

**Notes:** Use `$1`, `$2`, etc. for backreferences to capture groups.

**Example:**
```basic
' Replace all digits with X
result$ = regex_replace$("\d", "abc123def", "X")
println result$  ' Output: abcXXXdef

' Swap first and last name using capture groups
name$ = "John Smith"
result$ = regex_replace$("(\w+) (\w+)", name$, "$2, $1")
println result$  ' Output: Smith, John
```

---

#### regex_replacefirst$(pattern$, text$, replacement$)
#### regex_replacefirst$(pattern$, text$, replacement$, options)
Replace only the first match.

**Parameters:**
- `pattern$` - Regex pattern
- `text$` - Original text
- `replacement$` - Replacement string
- `options` - (Optional) Regex options

**Returns:** Text with first match replaced

**Example:**
```basic
result$ = regex_replacefirst$("\d", "a1b2c3", "X")
println result$  ' Output: aXb2c3
```

---

### Split Functions

#### regex_split#(pattern$, text$)
#### regex_split#(pattern$, text$, options)
Split string by pattern.

**Parameters:**
- `pattern$` - Regex pattern (the delimiter)
- `text$` - Text to split
- `options` - (Optional) Regex options

**Returns:** TStringList pointer containing split parts (0-based indexing)

**Example:**
```basic
' Split by multiple delimiters (comma, semicolon, or space)
parts# = regex_split#("[,;\s]+", "apple,banana;cherry orange")
for i = 0 to strings_count(parts#) - 1
  println strings_strings$(parts#, i)
next
' Output:
' apple
' banana
' cherry
' orange
```

---

### Group/Capture Functions

#### regex_groups#(pattern$, text$)
#### regex_groups#(pattern$, text$, options)
Get all capture groups from the first match.

**Parameters:**
- `pattern$` - Regex pattern with capture groups
- `text$` - Text to search
- `options` - (Optional) Regex options

**Returns:** TStringList pointer containing groups (index 0 = full match, 1+ = capture groups)

**Example:**
```basic
' Parse date: capture year, month, day
groups# = regex_groups#("(\d{4})-(\d{2})-(\d{2})", "Date: 2025-01-03")
if strings_count(groups#) > 0 then
  println "Full match: " + strings_strings$(groups#, 0)  ' 2025-01-03
  println "Year: " + strings_strings$(groups#, 1)        ' 2025
  println "Month: " + strings_strings$(groups#, 2)       ' 01
  println "Day: " + strings_strings$(groups#, 3)         ' 03
endif
```

---

#### regex_group$(pattern$, text$, index)
#### regex_group$(pattern$, text$, index, options)
Get a specific capture group from the first match.

**Parameters:**
- `pattern$` - Regex pattern with capture groups
- `text$` - Text to search
- `index` - Group index (0 = full match, 1+ = capture groups)
- `options` - (Optional) Regex options

**Returns:** Group value, or empty string if not found

**Example:**
```basic
' Extract just the domain from email
domain$ = regex_group$("@([\w.-]+)", "user@example.com", 1)
println "Domain: " + domain$  ' Output: example.com
```

---

#### regex_groupcount(pattern$, text$)
Count the number of groups in the first match.

**Parameters:**
- `pattern$` - Regex pattern
- `text$` - Text to search

**Returns:** Number of groups (including full match at index 0)

**Example:**
```basic
cnt = regex_groupcount("(\w+)-(\w+)-(\w+)", "abc-def-ghi")
println "Groups: " + str$(cnt)  ' Output: 4 (full match + 3 captures)
```

---

### Utility Functions

#### regex_escape$(text$)
Escape special regex characters in a string.

**Parameters:**
- `text$` - Text to escape

**Returns:** Escaped string safe for use in patterns

**Example:**
```basic
' Make user input safe for regex
userInput$ = "What is (2+2)?"
safePattern$ = regex_escape$(userInput$)
' safePattern$ = "What is \(2\+2\)\?"

if regex_match(safePattern$, userInput$) = 1 then
  println "Found exact text"
endif
```

---

## Complete Example Programs

### Email Validator

```basic
' Email validation program
println "=== Email Validator ==="

function validateEmail$(email$) local pattern$, result$
  ' Pattern for basic email validation
  pattern$ = "^[\w.-]+@[\w.-]+\.[a-zA-Z]{2,}$"
  
  if regex_matchfull(pattern$, email$) = 1 then
    result$ = "Valid"
  else
    result$ = "Invalid"
  endif
  return result$
endfunction

' Test emails
emails$ = "user@example.com,invalid@,test@site.org,bad email"
parts# = regex_split#(",", emails$)

for i = 0 to strings_count(parts#) - 1
  email$ = strings_strings$(parts#, i)
  result$ = validateEmail$(email$)
  println email$ + " -> " + result$
next
```

### Log Parser

```basic
' Parse Apache-style log entries
println "=== Log Parser ==="

logLine$ = "192.168.1.1 - - [03/Jan/2025:10:15:30 +0000] \"GET /index.html HTTP/1.1\" 200 1234"

' Pattern to extract: IP, date, method, path, status, size
pattern$ = "^(\d+\.\d+\.\d+\.\d+).*\[([^\]]+)\].*\"(\w+) ([^ ]+).*\" (\d+) (\d+)"

groups# = regex_groups#(pattern$, logLine$)

if strings_count(groups#) >= 7 then
  println "IP Address: " + strings_strings$(groups#, 1)
  println "Date/Time:  " + strings_strings$(groups#, 2)
  println "Method:     " + strings_strings$(groups#, 3)
  println "Path:       " + strings_strings$(groups#, 4)
  println "Status:     " + strings_strings$(groups#, 5)
  println "Size:       " + strings_strings$(groups#, 6)
else
  println "Failed to parse log line"
endif
```

### Text Sanitizer

```basic
' Sanitize user input
println "=== Text Sanitizer ==="

function sanitize$(text$) local result$
  ' Remove HTML tags
  result$ = regex_replace$("<[^>]+>", text$, "")
  
  ' Replace multiple spaces with single space
  result$ = regex_replace$("\s+", result$, " ")
  
  ' Trim leading/trailing whitespace
  result$ = regex_replace$("^\s+|\s+$", result$, "")
  
  return result$
endfunction

dirty$ = "  <b>Hello</b>   <script>alert('xss')</script>   World!  "
clean$ = sanitize$(dirty$)

println "Original: [" + dirty$ + "]"
println "Cleaned:  [" + clean$ + "]"
```

### Phone Number Formatter

```basic
' Format phone numbers consistently
println "=== Phone Formatter ==="

function formatPhone$(phone$) local digits$, area$, prefix$, line$, result$
  ' Remove all non-digits
  digits$ = regex_replace$("[^\d]", phone$, "")
  
  ' Check length and format
  if len(digits$) = 10 then
    ' Format as (XXX) XXX-XXXX
    area$ = mid$(digits$, 1, 3)
    prefix$ = mid$(digits$, 4, 3)
    line$ = mid$(digits$, 7, 4)
    result$ = "(" + area$ + ") " + prefix$ + "-" + line$
  else if len(digits$) = 11 and left$(digits$, 1) = "1" then
    ' Format as +1 (XXX) XXX-XXXX
    area$ = mid$(digits$, 2, 3)
    prefix$ = mid$(digits$, 5, 3)
    line$ = mid$(digits$, 8, 4)
    result$ = "+1 (" + area$ + ") " + prefix$ + "-" + line$
  else
    result$ = phone$  ' Return original if can't format
  end if
  return result$
end function

' Test various formats
println formatPhone$("5551234567")
println formatPhone$("(555) 123-4567")
println formatPhone$("555.123.4567")
println formatPhone$("1-555-123-4567")
```

---

## Common Regex Patterns

| Pattern | Description | Example Match |
|---------|-------------|---------------|
| `\d+` | One or more digits | "123" |
| `\w+` | One or more word characters | "hello_123" |
| `[a-zA-Z]+` | One or more letters | "Hello" |
| `^\s*$` | Empty or whitespace-only line | "   " |
| `\b\w+\b` | Whole word | "word" |
| `[^,]+` | Anything except comma | "abc def" |
| `\S+@\S+\.\S+` | Simple email | "a@b.com" |
| `\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}` | IP address | "192.168.1.1" |
| `#[0-9a-fA-F]{6}` | Hex color code | "#FF5733" |

---

## Error Handling

All functions handle errors gracefully:
- Invalid patterns return `0` or empty strings
- Use `regex_isvalid()` and `regex_error$()` to validate patterns before use
- No exceptions are raised to the BASIC program

---

## Notes

1. **0-based indexing:** TStringList results use 0-based indexing
2. **Position is 1-based, and unlike `instr`:** `regex_findpos()` counts from 1 and answers 0 when the pattern does not match. `instr()` counts from 0 and answers -1, so the two disagree by one on the same match and disagree entirely on failure. This note used to say "like other BASIC string functions", which stopped being true when `instr` was corrected to return a position rather than a flag.
3. **Backreferences:** Use `$1`, `$2`, etc. in replacement strings to reference capture groups
4. **Memory:** TStringList results are managed by the garbage collector
5. **Performance:** Compile complex patterns once and reuse when possible

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025 | Initial release with 28 functions |
