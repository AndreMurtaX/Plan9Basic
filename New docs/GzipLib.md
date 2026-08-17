# GzipLib - GZIP/Deflate Compression Library

## Overview

GzipLib provides functions to compress and decompress data using the GZIP/deflate algorithm. GZIP is ideal for compressing single data streams (strings or single files) and is widely used in web protocols, file storage, and data transmission.

**Version:** 1.0  
**Function Count:** 10 functions

## Features

- Compress strings to GZIP format (Base64-encoded for easy handling)
- Decompress GZIP data back to original strings
- Compress files to .gz format
- Decompress .gz files
- Multiple compression levels (1-9)
- Compression ratio calculation

## Error Codes

Use `gziperror()` to retrieve the error code from the last operation:

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_COMPRESSION | Compression failed |
| 2 | ERR_DECOMPRESSION | Decompression failed |
| 3 | ERR_INVALID_ARGUMENT | Invalid argument (empty input where not allowed) |
| 4 | ERR_FILE_ERROR | File read/write error |
| 5 | ERR_INVALID_LEVEL | Invalid compression level (must be 1-9) |

## Function Reference

### Error Handling

#### gziperror()
Returns the error code from the last GzipLib operation.

**Syntax:** `gziperror()`  
**Returns:** Number (error code)

**Example:**
```basic
compressed$ = gzip$("Hello World")
if gziperror() <> 0 then
    println "Compression failed with error: "; gziperror()
endif
```

### String Compression

#### gzip$(data$)
Compresses a string using GZIP with default compression level (6).

**Syntax:** `gzip$(string$)`  
**Parameters:**
- `string$` - The string to compress

**Returns:** Base64-encoded compressed data

**Example:**
```basic
original$ = "Hello World! This is a test string that will be compressed."
compressed$ = gzip$(original$)
println "Original length: "; len(original$)
println "Compressed (Base64): "; len(compressed$)
```

#### gzipex$(data$, level)
Compresses a string with a specified compression level.

**Syntax:** `gzipex$(string$, level)`  
**Parameters:**
- `string$` - The string to compress
- `level` - Compression level (1-9): 1=fastest, 9=best compression

**Returns:** Base64-encoded compressed data

**Example:**
```basic
data$ = "Lorem ipsum dolor sit amet, consectetur adipiscing elit..."

' Fast compression
fast$ = gzipex$(data$, 1)
println "Fast compression: "; len(fast$); " bytes"

' Maximum compression  
best$ = gzipex$(data$, 9)
println "Best compression: "; len(best$); " bytes"
```

#### gunzip$(compressed$)
Decompresses GZIP data (Base64-encoded) back to the original string.

**Syntax:** `gunzip$(compressed$)`  
**Parameters:**
- `compressed$` - Base64-encoded compressed data

**Returns:** Original decompressed string

**Example:**
```basic
original$ = "Hello World!"
compressed$ = gzip$(original$)
restored$ = gunzip$(compressed$)

if original$ = restored$ then
    println "Compression/decompression successful!"
endif
```

### File Compression

#### gzipfile(source$, dest$)
Compresses a file to .gz format using default compression level.

**Syntax:** `gzipfile(source$, destination$)`  
**Parameters:**
- `source$` - Path to the source file
- `destination$` - Path for the compressed .gz file

**Returns:** 1 on success, 0 on failure

**Example:**
```basic
if gzipfile("document.txt", "document.txt.gz") = 1 then
    println "File compressed successfully!"
else
    println "Compression failed. Error: "; gziperror()
endif
```

#### gzipfileex(source$, dest$, level)
Compresses a file with a specified compression level.

**Syntax:** `gzipfileex(source$, destination$, level)`  
**Parameters:**
- `source$` - Path to the source file
- `destination$` - Path for the compressed .gz file
- `level` - Compression level (1-9)

**Returns:** 1 on success, 0 on failure

**Example:**
```basic
' Maximum compression for archival
result = gzipfileex("largefile.dat", "largefile.dat.gz", 9)
if result = 1 then
    println "File compressed with maximum compression"
endif
```

#### gunzipfile(source$, dest$)
Decompresses a .gz file.

**Syntax:** `gunzipfile(source$, destination$)`  
**Parameters:**
- `source$` - Path to the .gz file
- `destination$` - Path for the decompressed file

**Returns:** 1 on success, 0 on failure

**Example:**
```basic
if gunzipfile("archive.txt.gz", "archive.txt") = 1 then
    println "File decompressed successfully!"
else
    println "Decompression failed. Error: "; gziperror()
endif
```

### Utility Functions

#### gzipratio(original$, compressed$)
Calculates the compression ratio between original and compressed data.

**Syntax:** `gzipratio(original$, compressed$)`  
**Parameters:**
- `original$` - The original string
- `compressed$` - Base64-encoded compressed data

**Returns:** Compression ratio (compressed/original). Values less than 1.0 indicate compression, greater than 1.0 indicates expansion.

**Example:**
```basic
text$ = "This is some text that will be compressed..."
compressed$ = gzip$(text$)
ratio = gzipratio(text$, compressed$)
println "Compression ratio: "; ratio
println "Space saved: "; (1 - ratio) * 100; "%"
```

#### gzipsize(data$)
Gets the size in bytes of a string when UTF-8 encoded.

**Syntax:** `gzipsize(string$)`  
**Parameters:**
- `string$` - The string to measure

**Returns:** Size in bytes

**Example:**
```basic
text$ = "Hello World!"
println "String size: "; gzipsize(text$); " bytes"
```

#### gzipcsize(compressed$)
Gets the actual compressed size from Base64-encoded compressed data.

**Syntax:** `gzipcsize(compressed$)`  
**Parameters:**
- `compressed$` - Base64-encoded compressed data

**Returns:** Size in bytes of the actual compressed data (before Base64 encoding)

**Example:**
```basic
text$ = "Hello World!"
compressed$ = gzip$(text$)
println "Original size: "; gzipsize(text$); " bytes"
println "Compressed size: "; gzipcsize(compressed$); " bytes"
```

## Complete Examples

### Example 1: Basic String Compression

```basic
' Basic string compression example
println "=== GZIP String Compression ==="
println ""

original$ = "The quick brown fox jumps over the lazy dog. "
original$ = original$ + original$ + original$ + original$

println "Original text length: "; len(original$)

' Compress the string
compressed$ = gzip$(original$)
if gziperror() <> 0 then
    println "Error compressing: "; gziperror()
    end
endif

println "Compressed (Base64) length: "; len(compressed$)
println "Actual compressed bytes: "; gzipcsize(compressed$)

' Calculate ratio
ratio = gzipratio(original$, compressed$)
println "Compression ratio: "; ratio
println "Space saved: "; int((1 - ratio) * 100); "%"

' Decompress and verify
restored$ = gunzip$(compressed$)
if original$ = restored$ then
    println ""
    println "Verification: SUCCESS - Data matches!"
else
    println ""
    println "Verification: FAILED - Data mismatch!"
endif
```

### Example 2: File Compression Utility

```basic
' File compression utility
' Note: INPUT is asynchronous and uses callbacks

LET filename$ = ""

function onFilename$(result$)
    if result$ = "" then
        println "No filename provided."
        return ""
    endif
    
    if fileexists(result$, 0) = 0 then
        println "File not found: "; result$
        return ""
    endif
    
    ' Store filename and ask for compression level
    filename$ = result$
    input "Compression", "Level (1-9, default 6):", "6", onLevel$
    return ""
endfunction

function onLevel$(result$) local level, outfile$
    if result$ = "" then
        level = 6
    else
        level = val(result$)
        if level < 1 or level > 9 then
            level = 6
        endif
    endif
    
    outfile$ = filename$ + ".gz"
    
    println ""
    println "Compressing "; filename$; " -> "; outfile$
    println "Compression level: "; level
    
    if gzipfileex(filename$, outfile$, level) = 1 then
        println "Compression successful!"
    else
        println "Compression failed. Error code: "; gziperror()
    endif
    return ""
endfunction

' Main program
println "=== File Compression Utility ==="
println ""
input "Compress File", "Enter file to compress:", "", onFilename$
```

### Example 3: Compress JSON Data

```basic
' Compressing JSON data for storage/transmission
println "=== Compress JSON Data ==="
println ""

' Create a JSON object
json# = json_object#()
json_sets#(json#, "name", "John Doe")
json_setn#(json#, "age", 30)
json_sets#(json#, "email", "john@example.com")
json_sets#(json#, "city", "New York")

' Convert to string
jsonStr$ = json_stringify$(json#)

println "JSON data:"
println jsonStr$
println ""

' Compress the JSON
compressed$ = gzip$(jsonStr$)

println "Original size: "; gzipsize(jsonStr$); " bytes"
println "Compressed size: "; gzipcsize(compressed$); " bytes"
println ""

' For transmission, the compressed$ is already Base64-encoded
println "Ready for transmission (Base64):"
println compressed$
```

### Example 4: Batch File Compression

```basic
' Compress multiple files
println "=== Batch File Compression ==="
println ""

files# = sdim#(5)
files#$[1] = "readme.txt"
files#$[2] = "data.csv"
files#$[3] = "config.ini"
files#$[4] = "log.txt"
files#$[5] = "notes.md"

successCount = 0
failCount = 0

for i = 1 to 5
    filename$ = files#$[i]
    if fileexists(filename$, 0) = 1 then
        outfile$ = filename$ + ".gz"
        if gzipfile(filename$, outfile$) = 1 then
            println "OK: "; filename$
            successCount = successCount + 1
        else
            println "FAIL: "; filename$; " (Error: "; gziperror(); ")"
            failCount = failCount + 1
        endif
    else
        println "SKIP: "; filename$; " (not found)"
    endif
next

println ""
println "Completed: "; successCount; " compressed, "; failCount; " failed"
```

## Technical Notes

1. **Base64 Encoding**: String compression functions return Base64-encoded data for easy handling in text-based formats (JSON, XML, databases). The actual compressed data is smaller than the Base64 representation.

2. **Compression Levels**:
   - Level 1: Fastest compression, largest output
   - Level 6: Default, balanced speed and compression
   - Level 9: Best compression, slowest speed

3. **Memory Usage**: Large strings or files may require significant memory during compression/decompression.

4. **File Format**: The `gzipfile` and `gunzipfile` functions create/read ZLib-compressed files, which are compatible with most GZIP utilities.

5. **UTF-8 Encoding**: String functions use UTF-8 encoding, which properly handles international characters.

## See Also

- [Base64Lib](Base64Lib.md) - Base64 encoding/decoding
- [ZipLib](ZipLib.md) - ZIP archive operations
- [JsonLib](JsonLib.md) - JSON data handling
