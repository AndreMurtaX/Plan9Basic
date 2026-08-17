# ZipLib - ZIP Archive Library

## Overview

ZipLib provides functions to create, read, and manipulate ZIP archives. ZIP format supports multiple files in a single archive with individual compression and is widely used for file distribution, backup, and data exchange.

**Version:** 1.0  
**Function Count:** 15 functions

## Features

- Create new ZIP archives
- Open and read existing ZIP archives
- Add files to archives
- Add strings as files to archives
- Extract files from archives
- Extract all files from archives
- List archive contents
- Read file contents directly from archives
- Quick compress/extract convenience functions

## Error Codes

Use `ziperror()` to retrieve the error code from the last operation:

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_INVALID_HANDLE | Archive not open or invalid handle |
| 2 | ERR_FILE_NOT_FOUND | File not found in archive |
| 3 | ERR_FILE_ERROR | File system error (read/write failure) |
| 4 | ERR_INVALID_ARGUMENT | Invalid argument provided |
| 5 | ERR_COMPRESSION | Compression error |
| 6 | ERR_ARCHIVE_EXISTS | Archive already exists (when creating) |
| 7 | ERR_ENTRY_EXISTS | Entry already exists in archive |

## Function Reference

### Error Handling

#### ziperror()
Returns the error code from the last ZipLib operation.

**Syntax:** `ziperror()`  
**Returns:** Number (error code)

**Example:**
```basic
handle# = zipcreate#("test.zip")
if PntToNum(handle#) = 0 then
    println "Failed to create archive. Error: "; ziperror()
endif
```

### Archive Creation and Opening

#### zipcreate#(file$)
Creates a new ZIP archive for writing.

**Syntax:** `zipcreate#(archivePath$)`  
**Parameters:**
- `archivePath$` - Path for the new ZIP archive

**Returns:** Handle (pointer) to the archive, or 0 on failure

**Example:**
```basic
handle# = zipcreate#("myarchive.zip")
if PntToNUm(handle#) <> 0 then
    println "Archive created successfully"
    ' Add files here...
    zipclose(handle#)
endif
```

#### zipopen#(file$)
Opens an existing ZIP archive for reading.

**Syntax:** `zipopen#(archivePath$)`  
**Parameters:**
- `archivePath$` - Path to the existing ZIP archive

**Returns:** Handle (pointer) to the archive, or 0 on failure

**Example:**
```basic
handle# = zipopen#("existing.zip")
if PntToNum(handle#) <> 0 then
    println "Archive opened successfully"
    println "Contains "; zipcount(handle#); " files"
    zipclose(handle#)
endif
```

#### zipclose(zip#)
Closes a ZIP archive and releases the handle.

**Syntax:** `zipclose(handle#)`  
**Parameters:**
- `handle#` - Archive handle from zipcreate# or zipopen#

**Returns:** 1 on success, 0 on failure

**Important:** Always close archives when done to ensure data is written properly.

**Example:**
```basic
handle# = zipcreate#("test.zip")
' ... work with archive ...
if zipclose(handle#) = 1 then
    println "Archive closed successfully"
endif
```

### Adding Files to Archives

#### zipadd(zip#, source$, entry$)
Adds a file to a ZIP archive.

**Syntax:** `zipadd(handle#, sourcePath$, archiveName$)`  
**Parameters:**
- `handle#` - Archive handle (must be opened with zipcreate#)
- `sourcePath$` - Path to the file to add
- `archiveName$` - Name for the file inside the archive

**Returns:** 1 on success, 0 on failure

**Example:**
```basic
handle# = zipcreate#("backup.zip")
if PntToNum(handle#) <> 0 then
    ' Add files with custom names in archive
    zipadd(handle#, "C:\docs\report.docx", "documents/report.docx")
    zipadd(handle#, "C:\data\sales.xlsx", "spreadsheets/sales.xlsx")
    zipclose(handle#)
endif
```

#### zipaddstr(zip#, content$, entry$)
Adds a string as a file to a ZIP archive.

**Syntax:** `zipaddstr(handle#, content$, archiveName$)`  
**Parameters:**
- `handle#` - Archive handle (must be opened with zipcreate#)
- `content$` - String content to add as a file
- `archiveName$` - Name for the file inside the archive

**Returns:** 1 on success, 0 on failure

**Example:**
```basic
handle# = zipopen#("test.zip")
if PntToNum(handle#) <> 0 then
    ' Add configuration as text file
    config$ = "server=localhost" + chr$(10)
    config$ = config$ + "port=8080" + chr$(10)
    config$ = config$ + "debug=false" + chr$(10)
    
    zipaddstr(handle#, config$, "config.txt")
    
    ' Add JSON data
    jsonData$ = "{\"name\":\"Test\", \"version\":\"1.0\"}"
    zipaddstr(handle#, jsonData$, "manifest.json")
    
    zipclose(handle#)
endif
```

### Extracting Files from Archives

#### zipextract(zip#, entry$, dest$)
Extracts a single file from a ZIP archive.

**Syntax:** `zipextract(handle#, archiveName$, destPath$)`  
**Parameters:**
- `handle#` - Archive handle (must be opened with zipopen#)
- `archiveName$` - Name of the file in the archive
- `destPath$` - Destination directory path

**Returns:** 1 on success, 0 on failure

**Example:**
```basic
handle# = zipopen#("archive.zip")
if PntToNum(handle#) <> 0 then
    ' Extract specific file to current directory
    if zipextract(handle#, "readme.txt", ".") = 1 then
        println "File extracted successfully"
    endif
    zipclose(handle#)
endif
```

#### zipextractall(zip#, dest$)
Extracts all files from a ZIP archive.

**Syntax:** `zipextractall(handle#, destPath$)`  
**Parameters:**
- `handle#` - Archive handle (must be opened with zipopen#)
- `destPath$` - Destination directory path

**Returns:** 1 on success, 0 on failure

**Example:**
```basic
handle# = zipopen#("package.zip")
if PntToNum(handle#) <> 0 then
    if zipextractall(handle#, "C:\extracted") = 1 then
        println "All files extracted successfully"
    else
        println "Extraction failed. Error: "; ziperror()
    endif
    zipclose(handle#)
endif
```

### Archive Information

#### ziplist$(zip#)
Lists all files in a ZIP archive (newline-separated).

**Syntax:** `ziplist$(handle#)`  
**Parameters:**
- `handle#` - Archive handle

**Returns:** Newline-separated list of file names

**Example:**
```basic
handle# = zipopen#("archive.zip")
if PntToNum(handle#) <> 0 then
    fileList$ = ziplist$(handle#)
    println "Files in archive:"
    println fileList$
    zipclose(handle#)
endif
```

#### zipcount(zip#)
Gets the number of files in a ZIP archive.

**Syntax:** `zipcount(handle#)`  
**Parameters:**
- `handle#` - Archive handle

**Returns:** Number of files in the archive

**Example:**
```basic
handle# = zipopen#("archive.zip")
if PntToNum(handle#) <> 0 then
    count = zipcount(handle#)
    println "Archive contains "; count; " files"
    zipclose(handle#)
endif
```

#### zipexists(zip#, entry$)
Checks if a file exists in a ZIP archive.

**Syntax:** `zipexists(handle#, fileName$)`  
**Parameters:**
- `handle#` - Archive handle
- `fileName$` - Name of the file to check

**Returns:** 1 if exists, 0 if not

**Example:**
```basic
handle# = zipopen#("archive.zip")
if PntToNum(handle#) <> 0 then
    if zipexists(handle#, "readme.txt") = 1 then
        println "readme.txt found in archive"
    else
        println "readme.txt not found"
    endif
    zipclose(handle#)
endif
```

#### zipread$(zip#, entry$)
Reads a file from a ZIP archive as a string.

**Syntax:** `zipread$(handle#, fileName$)`  
**Parameters:**
- `handle#` - Archive handle (must be opened with zipopen#)
- `fileName$` - Name of the file in the archive

**Returns:** File contents as string

**Example:**
```basic
handle# = zipopen#("config.zip")
if PntToNum(handle#) <> 0 then
    if zipexists(handle#, "settings.txt") = 1 then
        content$ = zipread$(handle#, "settings.txt")
        println "Settings file content:"
        println content$
    endif
    zipclose(handle#)
endif
```

#### zipfilesize(zip#, entry$)
Gets the uncompressed size of a file in the archive.

**Syntax:** `zipfilesize(handle#, fileName$)`  
**Parameters:**
- `handle#` - Archive handle
- `fileName$` - Name of the file in the archive

**Returns:** Uncompressed size in bytes, or -1 on error

**Example:**
```basic
handle# = zipopen#("archive.zip")
if PntToNum(handle#) <> 0 then
    size = zipfilesize(handle#, "document.pdf")
    if size >= 0 then
        println "File size: "; size; " bytes"
    else
        println "File not found"
    endif
    zipclose(handle#)
endif
```

### Convenience Functions

#### zipquick(source$, dest$)
Quick compress: creates a ZIP archive containing a single file.

**Syntax:** `zipquick(sourcePath$, zipPath$)`  
**Parameters:**
- `sourcePath$` - Path to the file to compress
- `zipPath$` - Path for the ZIP archive

**Returns:** 1 on success, 0 on failure

**Example:**
```basic
' Quick one-liner to compress a file
if zipquick("report.pdf", "report.zip") = 1 then
    println "File compressed successfully"
endif
```

#### unzipquick(source$, dest$)
Quick extract: extracts all files from a ZIP archive.

**Syntax:** `unzipquick(zipPath$, destPath$)`  
**Parameters:**
- `zipPath$` - Path to the ZIP archive
- `destPath$` - Destination directory

**Returns:** 1 on success, 0 on failure

**Example:**
```basic
' Quick one-liner to extract all files
if unzipquick("package.zip", "C:\extracted") = 1 then
    println "Archive extracted successfully"
endif
```

## Complete Examples

### Example 1: Create a Backup Archive

```basic
' Create a backup of important files
println "=== Creating Backup Archive ==="
println ""

backupName$ = "backup_" + format$(now(), "yyyymmdd") + ".zip"

handle# = zipcreate#(backupName$)
if PntToNum(handle#) = 0 then
    println "Failed to create archive"
    end
endif

' Add files to backup
files# = sdim#(4)
files#$[1] = "config.ini"
files#$[2] = "database.db"
files#$[3] = "settings.json"
files#$[4] = "notes.txt"

addedCount = 0
for i = 1 to 4
    filename$ = files#$[i]
    if fileexists(filename$, 0) = 1 then
        if zipadd(handle#, filename$, filename$) = 1 then
            println "Added: "; filename$
            addedCount = addedCount + 1
        else
            println "Failed to add: "; filename$
        endif
    else
        println "Skipped (not found): "; filename$
    endif
next

zipclose(handle#)

println ""
println "Backup complete: "; backupName$
println "Files added: "; addedCount
```

### Example 2: Archive Browser

```basic
' Browse contents of a ZIP archive
' Note: INPUT is asynchronous and uses callbacks

function onZipPath$(zipPath$) local handle#, count, fileList$, fileName$, size, lineNum, pos, endPos
    if zipPath$ = "" then
        println "No path provided"
        return ""
    endif
    
    handle# = zipopen#(zipPath$)
    if PntToNum(handle#) = 0 then
        println "Cannot open archive. Error: "; ziperror()
        return ""
    endif
    
    count = zipcount(handle#)
    println ""
    println "Archive: "; zipPath$
    println "Total files: "; count
    println ""
    println "Contents:"
    println "----------------------------------------"
    
    fileList$ = ziplist$(handle#)
    
    ' Parse and display each file with size
    lineNum = 1
    pos = 0
    while pos < len(fileList$)
        ' Find next newline
        endPos = instr(fileList$, chr$(10), pos)
        if endPos = -1 then
            endPos = len(fileList$)
        endif
        
        fileName$ = mid$(fileList$, pos, endPos - pos)
        if right$(fileName$, 1) = chr$(13) then
            fileName$ = left$(fileName$, len(fileName$) - 1)
        endif
        
        if fileName$ <> "" then
            size = zipfilesize(handle#, fileName$)
            println lineNum; ". "; fileName$; " ("; size; " bytes)"
            lineNum = lineNum + 1
        endif
        
        pos = endPos + 1
    wend
    
    println "----------------------------------------"
    zipclose(handle#)
    return ""
endfunction

' Main program
println "=== ZIP Archive Browser ==="
println ""
input "Open Archive", "Enter ZIP file path:", "", onZipPath$
```

### Example 3: Extract Specific Files

```basic
' Extract files matching a pattern
' Note: INPUT is asynchronous and uses callbacks
' This example uses module-level variables to pass data between callbacks

LET gZipPath$ = ""
LET gPattern$ = ""
LET gDestPath$ = ""

function onZipFile$(result$)
    gZipPath$ = result$
    input "Filter", "Extract files containing:", "", onPattern$
    return ""
endfunction

function onPattern$(result$)
    gPattern$ = result$
    input "Destination", "Destination folder:", "", onDestFolder$
    return ""
endfunction

function onDestFolder$(result$) local handle#, fileList$, extractedCount, pos, endPos, fileName$
    gDestPath$ = result$
    
    if gZipPath$ = "" or gDestPath$ = "" then
        println "Invalid input"
        return ""
    endif
    
    handle# = zipopen#(gZipPath$)
    if PntToNum(handle#) = 0 then
        println "Cannot open archive"
        return ""
    endif
    
    ' Ensure destination exists
    forcedirectories(gDestPath$)
    
    fileList$ = ziplist$(handle#)
    extractedCount = 0
    
    ' Process each file
    pos = 0
    while pos < len(fileList$)
        endPos = instr(fileList$, chr$(10), pos)
        if endPos = -1 then
            endPos = len(fileList$)
        endif
        
        fileName$ = mid$(fileList$, pos, endPos - pos)
        fileName$ = trim$(fileName$)
        
        ' Check if file matches pattern
        if fileName$ <> "" then
            if gPattern$ = "" or instr(lcase$(fileName$), lcase$(gPattern$)) >= 0 then
                if zipextract(handle#, fileName$, gDestPath$) = 1 then
                    println "Extracted: "; fileName$
                    extractedCount = extractedCount + 1
                else
                    println "Failed: "; fileName$
                endif
            endif
        endif
        
        pos = endPos + 1
    end while
    
    zipclose(handle#)
    println ""
    println "Extracted "; extractedCount; " files"
    return ""
endfunction

' Main program
println "=== Selective File Extraction ==="
println ""
input "Source", "ZIP file:", "", onZipFile$
```

### Example 4: Create Archive with Generated Content

```basic
' Create a ZIP with programmatically generated files
println "=== Generate Archive Content ==="
println ""

handle# = zipcreate#("generated.zip")
if PntToNum(handle#) = 0 then
    println "Failed to create archive"
    end
endif

' Generate a README file
readme$ = "Generated Archive" + chr$(10)
readme$ = readme$ + "=================" + chr$(10)
readme$ = readme$ + "Created: " + formatdatetime$("yyyy-mm-dd hh:nn:ss", Now()) + chr$(10)
readme$ = readme$ + chr$(10)
readme$ = readme$ + "This archive was created programmatically." + chr$(10)

zipaddstr(handle#, readme$, "README.txt")
println "Added: README.txt"

Randomize()
' Generate data files
for i = 1 to 5
    data$ = "Data File #" + str$(i) + chr$(10)
    data$ = data$ + "Generated at: " + formatdatetime$("hh:nn:ss", now()) + chr$(10)
    data$ = data$ + "Random value: " + str$(rnd() * 1000) + chr$(10)
    
    fileName$ = "data/file" + stri$(i) + ".txt"
    zipaddstr(handle#, data$, fileName$)
    println "Added: "; fileName$
next

' Generate a JSON manifest
manifest$ = "{" + chr$(10)
manifest$ = manifest$ + "  \"name\": \"Generated Archive\"," + chr$(10)
manifest$ = manifest$ + "  \"version\": \"1.0\"," + chr$(10)
manifest$ = manifest$ + "  \"files\": 6" + chr$(10)
manifest$ = manifest$ + "}" + chr$(10)

zipaddstr(handle#, manifest$, "manifest.json")
println "Added: manifest.json"

zipclose(handle#)
println ""
println "Archive created: generated.zip"
```

### Example 5: Combine GZIP and ZIP

```basic
' Compress data with GZIP, then store in ZIP
println "=== Combined Compression ==="
println ""

' Create some test data
data$ = ""
for i = 1 to 100
    data$ = data$ + "Line " + str$(i) + ": The quick brown fox jumps over the lazy dog." + chr$(10)
next

println "Original data size: "; len(data$); " chars"

' First, compress with GZIP
compressed$ = gzip$(data$)
println "GZIP compressed (Base64): "; len(compressed$); " chars"
println "GZIP actual size: "; gzipcsize(compressed$); " bytes"

' Create ZIP archive with both versions
handle# = zipcreate#("combined.zip")
if PntToNum(handle#) <> 0 then
    ' Store original
    zipaddstr(handle#, data$, "original.txt")
    println "Added original.txt"
    
    ' Store GZIP compressed version
    zipaddstr(handle#, compressed$, "compressed.gz.b64")
    println "Added compressed.gz.b64"
    
    zipclose(handle#)
    println ""
    println "Archive created: combined.zip"
endif
```

## Technical Notes

1. **Handle Management**: Always close handles with `zipclose` when done. Open handles consume system resources.

2. **Read vs Write Mode**: Archives opened with `zipcreate#` can only add files. Archives opened with `zipopen#` can only read/extract files.

3. **Path Separators**: Use forward slashes (/) in archive paths for cross-platform compatibility.

4. **Text Encoding**: `zipaddstr` and `zipread$` use UTF-8 encoding for text content.

5. **Large Files**: For very large files, use file-based functions (`zipadd`, `zipextract`) instead of string-based functions to avoid memory issues.

6. **Archive Structure**: Files can be organized in directories within the archive by including path separators in the archive name (e.g., "docs/readme.txt").

## See Also

- [GzipLib](GzipLib.md) - GZIP string/file compression
- [Base64Lib](Base64Lib.md) - Base64 encoding/decoding
- [SysLib](SysLib.md) - File system operations
