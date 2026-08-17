# Base64Lib - BASE64 Encoding/Decoding Library for Plan9Basic

## Overview

Base64Lib provides encoding and decoding of data using BASE64 format, the standard way to represent binary data as ASCII text. BASE64 is widely used in JSON payloads, XML, email attachments, data URIs, and HTTP authentication.

**Version:** 1.0
**Function Count:** 8 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
' Encode a string
encoded$ = b64encode$("Hello, World!")
println encoded$   ' SGVsbG8sIFdvcmxkIQ==

' Decode it back
original$ = b64decode$(encoded$)
println original$  ' Hello, World!
```

## Error Codes

| Code | Meaning |
|------|---------|
| 0 | No error |
| 1 | Invalid BASE64 string |
| 2 | Invalid argument (empty input where not allowed) |
| 3 | File error (read/write failure) |

---

## Function Reference

### Error Handling

#### b64error()

Returns the error code from the last Base64Lib operation.

**Syntax:** `b64error()`
**Returns:** Number (error code — see Error Codes table)

**Example:**
```basic
result$ = b64decode$("not!valid!base64")
if b64error() = 1 then
    println "Invalid BASE64 input"
endif
```

---

### Core Encoding / Decoding

#### b64encode$(data$)

Encodes a string to standard BASE64.

**Syntax:** `b64encode$(string$)`
**Parameters:**
- `string$` — The string to encode (UTF-8)

**Returns:** BASE64-encoded string (uses `+`, `/`, `=` padding)

**Example:**
```basic
msg$ = "Plan9Basic is great!"
encoded$ = b64encode$(msg$)
println encoded$   ' UGxhbjlCYXNpYyBpcyBncmVhdCE=
```

---

#### b64decode$(encoded$)

Decodes a standard BASE64 string back to the original string.

**Syntax:** `b64decode$(base64$)`
**Parameters:**
- `base64$` — The BASE64-encoded string to decode

**Returns:** Decoded string (UTF-8), or empty string on error

**Example:**
```basic
encoded$ = "UGxhbjlCYXNpYyBpcyBncmVhdCE="
original$ = b64decode$(encoded$)
println original$  ' Plan9Basic is great!
```

---

### URL-Safe BASE64

Standard BASE64 uses `+` and `/` characters which are special in URLs. URL-safe BASE64 replaces these with `-` and `_`, and removes `=` padding — making the result safe to embed directly in URLs and filenames.

#### b64urlencode$(data$)

Encodes a string to URL-safe BASE64 (no `+`, `/`, or `=`).

**Syntax:** `b64urlencode$(string$)`
**Parameters:**
- `string$` — The string to encode

**Returns:** URL-safe BASE64 string (uses `-`, `_`, no padding)

**Example:**
```basic
token$ = b64urlencode$("user:password")
url$ = "https://api.example.com/auth?token=" + token$
```

---

#### b64urldecode$(encoded$)

Decodes a URL-safe BASE64 string back to the original string.

**Syntax:** `b64urldecode$(urlBase64$)`
**Parameters:**
- `urlBase64$` — URL-safe BASE64 string (with `-` and `_`)

**Returns:** Decoded string (UTF-8), or empty string on error

**Example:**
```basic
token$ = "dXNlcjpwYXNzd29yZA"  ' URL-safe (no padding)
credentials$ = b64urldecode$(token$)
println credentials$  ' user:password
```

---

### Validation

#### b64valid(str$)

Checks whether a string is valid standard BASE64.

**Syntax:** `b64valid(string$)`
**Parameters:**
- `string$` — The string to validate

**Returns:** 1 if valid BASE64, 0 if invalid

Validates character set (A-Z, a-z, 0-9, +, /, =), length (multiple of 4), and padding position.

**Example:**
```basic
if b64valid("SGVsbG8=") = 1 then
    result$ = b64decode$("SGVsbG8=")
    println "Decoded: "; result$
else
    println "Not valid BASE64"
endif
```

---

### File Operations

#### b64encodefile$(filepath$)

Reads a binary file and returns its contents as a BASE64-encoded string. Useful for embedding images or binary data in JSON/XML.

**Syntax:** `b64encodefile$(filePath$)`
**Parameters:**
- `filePath$` — Path to the source file

**Returns:** BASE64-encoded file contents, or empty string on error

**Example:**
```basic
' Encode an image for use in a data URI
imageData$ = b64encodefile$("C:\Images\logo.png")
if b64error() = 0 then
    dataUri$ = "data:image/png;base64," + imageData$
    println "Data URI length: "; len(dataUri$)
else
    println "File error: "; b64error()
endif
```

---

#### b64decodefile(base64$, filepath$)

Decodes a BASE64 string and saves the binary result to a file.

**Syntax:** `b64decodefile(base64$, destPath$)`
**Parameters:**
- `base64$` — The BASE64-encoded data
- `destPath$` — Path for the output file

**Returns:** 1 on success, 0 on failure

**Example:**
```basic
' Save a BASE64-encoded image to disk
encoded$ = b64encodefile$("original.png")
result = b64decodefile(encoded$, "copy.png")
if result = 1 then
    println "File saved successfully"
else
    println "Save failed, error: "; b64error()
endif
```

---

## Complete Examples

### Example 1: Encode and Decode Round-Trip

```basic
original$ = "The quick brown fox jumps over the lazy dog"
println "Original:  "; original$
println "Length:    "; len(original$)

encoded$ = b64encode$(original$)
println "Encoded:   "; encoded$
println "Enc length:"; len(encoded$)

decoded$ = b64decode$(encoded$)
println "Decoded:   "; decoded$

if original$ = decoded$ then
    println "Round-trip OK!"
endif
```

### Example 2: Validate Before Decoding

```basic
sub SafeDecode$(input$)
    if b64valid(input$) = 0 then
        println "Invalid BASE64 — skipping"
        SafeDecode$ = ""
        exit sub
    endif
    SafeDecode$ = b64decode$(input$)
    if b64error() <> 0 then
        println "Decode error: "; b64error()
        SafeDecode$ = ""
    endif
end sub

println SafeDecode$("SGVsbG8gV29ybGQ=")  ' Hello World
println SafeDecode$("not##valid!!")       ' shows error
```

### Example 3: URL-Safe Tokens

```basic
' Create a URL-safe authentication token
username$ = "alice"
timestamp$ = str$(now())
payload$   = username$ + ":" + timestamp$

token$  = b64urlencode$(payload$)
authUrl$ = "https://api.example.com/login?auth=" + token$
println "Auth URL: "; authUrl$

' Decode on the receiving side
decoded$ = b64urldecode$(token$)
println "Payload: "; decoded$
```

### Example 4: File Encode/Decode

```basic
let docs$ = documentspath$() + dirseparator$() + "test.bin"
let copy$ = documentspath$() + dirseparator$() + "test_copy.bin"

' Encode file to BASE64
encoded$ = b64encodefile$(docs$)
if b64error() <> 0 then
    println "Read error: "; b64error()
    end
endif
println "File encoded to "; len(encoded$); " BASE64 chars"

' Decode back to a new file
ok = b64decodefile(encoded$, copy$)
if ok = 1 then
    println "File restored to: "; copy$
else
    println "Write error: "; b64error()
endif
```

## Notes

- `b64encode$` / `b64decode$` work with standard BASE64 (RFC 4648, uses `+`, `/`, `=`)
- `b64urlencode$` / `b64urldecode$` produce URL-safe BASE64 (RFC 4648 §5, uses `-`, `_`, no padding)
- Strings are treated as UTF-8 during encode/decode
- `b64valid` only validates **standard** BASE64; URL-safe strings will fail its check
- Empty strings are valid inputs — they encode/decode to empty strings

## See Also

- GzipLib — Compress strings or files before encoding
- HttpLib — Send BASE64-encoded data in HTTP requests
- IOUtilsLib — File path helpers for file encode/decode operations
