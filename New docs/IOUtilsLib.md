# IOUtilsLib - I/O Utilities Library for Plan9Basic

## Overview

The IOUtilsLib provides comprehensive file and directory operations for Plan9Basic, based on Delphi's `System.IOUtils` unit. It exposes functionality from the `TFile`, `TDirectory`, and `TPath` records.

**This library is fully cross-platform** and works on Windows, macOS, Linux, Android, and iOS.

## Error Handling

All functions in this library set an error code that can be retrieved using `ioerror()` and a descriptive message using `iostrerror$()`.

### Error Codes

| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | File not found |
| 2 | Directory not found |
| 3 | Access denied |
| 4 | Path too long |
| 5 | Invalid path |
| 6 | I/O error |
| 7 | File already exists |
| 8 | Directory not empty |
| 9 | Invalid argument |
| 10 | Unknown error |

### Error Functions

| Function | Description |
|----------|-------------|
| `ioerror()` | Returns the last error code (number) |
| `iostrerror$()` | Returns descriptive error message (string) |

**Example:**
```basic
let content$ = file_readalltext$("missing.txt")
if ioerror() <> 0 then
    println "Error: "; iostrerror$()
endif
```

---

## TFile Functions - File Operations

### Reading Files

| Function | Description |
|----------|-------------|
| `file_readalltext$(path$)` | Read entire file as UTF-8 text |
| `file_readalltext$(path$, encoding$)` | Read file with specified encoding |
| `file_readallbytes#(path$)` | Read file as byte stream (TMemoryStream) |

**Supported encodings:** utf-8, utf-7, ansi, ascii, unicode (utf-16le), utf-16be

**Example:**
```basic
' Read UTF-8 file (default)
let content$ = file_readalltext$("data.txt")
if ioerror() <> 0 then
    println "Read error: "; iostrerror$()
endif

' Read with specific encoding
let latin$ = file_readalltext$("latin.txt", "ansi")

' Read binary file
let stream# = file_readallbytes#("image.png")
```

### Writing Files

| Function | Description |
|----------|-------------|
| `file_writealltext(path$, content$)` | Write text to file (UTF-8) |
| `file_writealltext(path$, content$, encoding$)` | Write with encoding |
| `file_appendalltext(path$, content$)` | Append text to file (UTF-8) |
| `file_appendalltext(path$, content$, encoding$)` | Append with encoding |
| `file_writeallbytes(path$, stream#)` | Write byte stream to file |
| `file_createempty(path$)` | Create empty file or update timestamp |

**Example:**
```basic
' Write text file
let result = file_writealltext("output.txt", "Hello, World!")

' Append to log
let logline$ = formatdatetime$("yyyy-mm-dd hh:nn:ss", now()) + " - Event"
let result = file_appendalltext("log.txt", logline$ + chr$(13) + chr$(10))

' Write with specific encoding
let result = file_writealltext("data.csv", "Name;Value", "ansi")
```

### File Operations

| Function | Description |
|----------|-------------|
| `file_copy(source$, dest$)` | Copy file (fails if dest exists) |
| `file_copy(source$, dest$, overwrite)` | Copy with overwrite option |
| `file_move(source$, dest$)` | Move or rename file |
| `file_delete(path$)` | Delete file |
| `file_exists(path$)` | Check if file exists (returns 1/0) |
| `file_getsize(path$)` | Get file size in bytes |

**Example:**
```basic
let result = 0

' Copy file (check existence first)
if file_exists("source.txt") <> 0 then
    let result = file_copy("source.txt", "backup.txt", 1)
endif

' Move/rename
let result = file_move("old.txt", "new.txt")

' Delete
let result = file_delete("temp.txt")
if ioerror() <> 0 then
    println "Could not delete: "; iostrerror$()
endif
```

### File Timestamps

| Function | Description |
|----------|-------------|
| `file_getcreationtime(path$)` | Get creation time as TDateTime |
| `file_getlastaccesstime(path$)` | Get last access time |
| `file_getlastwritetime(path$)` | Get last modification time |
| `file_setcreationtime(path$, datetime)` | Set creation time |
| `file_setlastaccesstime(path$, datetime)` | Set last access time |
| `file_setlastwritetime(path$, datetime)` | Set modification time |

**Example:**
```basic
' Get modification time
let modified = file_getlastwritetime("document.txt")
println "Last modified: "; formatdatetime$("yyyy-mm-dd hh:nn:ss", modified)

' Update modification time to now
let result = file_setlastwritetime("document.txt", now())
```

---

## TDirectory Functions - Directory Operations

### Basic Operations

| Function | Description |
|----------|-------------|
| `dir_create(path$)` | Create directory |
| `dir_delete(path$)` | Delete empty directory |
| `dir_delete(path$, recursive)` | Delete with recursive option |
| `dir_exists(path$)` | Check if directory exists |
| `dir_move(source$, dest$)` | Move or rename directory |
| `dir_copy(source$, dest$)` | Copy directory recursively |
| `dir_isempty(path$)` | Check if directory is empty |

**Example:**
```basic
let result = 0

' Create directory
let result = dir_create("myproject")

' Create nested directories (use forcedirectories from SysLib)
let result = forcedirectories("myproject/src/modules")

' Check existence
if dir_exists("backup") = 0 then
    let result = dir_create("backup")
endif

' Delete directory tree (1 = recursive)
let result = dir_delete("temp", 1)
```

### Listing Contents

| Function | Description |
|----------|-------------|
| `dir_getfiles$(path$)` | Get all files (CRLF-separated) |
| `dir_getfiles$(path$, pattern$)` | Get files matching pattern |
| `dir_getfiles$(path$, pattern$, recursive)` | Get files with recursion |
| `dir_getdirectories$(path$)` | Get all subdirectories |
| `dir_getdirectories$(path$, pattern$)` | Get directories matching pattern |
| `dir_getdirectories$(path$, pattern$, recursive)` | Get directories with recursion |
| `dir_getentries$(path$)` | Get all files and directories |
| `dir_getentries$(path$, pattern$)` | Get entries matching pattern |

**Note:** Results are returned as a single string with entries separated by CRLF.

**Example:**
```basic
let files$ = ""
let linecount = 0
let i = 0

' List all files in directory
let files$ = dir_getfiles$(documentspath$())
let linecount = count(files$)
for i = 0 to linecount - 1
    println line$(files$, i)
next

' Find all .txt files recursively (1 = recursive)
let txtfiles$ = dir_getfiles$(homepath$(), "*.txt", 1)

' List subdirectories
let subdirs$ = dir_getdirectories$(homepath$())
```

### Directory Timestamps

| Function | Description |
|----------|-------------|
| `dir_getcreationtime(path$)` | Get creation time |
| `dir_getlastaccesstime(path$)` | Get last access time |
| `dir_getlastwritetime(path$)` | Get last modification time |
| `dir_setcreationtime(path$, datetime)` | Set creation time |
| `dir_setlastaccesstime(path$, datetime)` | Set last access time |
| `dir_setlastwritetime(path$, datetime)` | Set modification time |

### Working Directory

| Function | Description |
|----------|-------------|
| `dir_getcurrent$()` | Get current working directory |
| `dir_setcurrent(path$)` | Set current working directory |
| `dir_getparent$(path$)` | Get parent directory path |
| `dir_isrelativepath(path$)` | Check if path is relative |

**Example:**
```basic
let original$ = ""
let parent$ = ""
let result = 0

' Save and change directory
let original$ = dir_getcurrent$()
let result = dir_setcurrent(documentspath$())

' Do work...
println "Working in: "; dir_getcurrent$()

' Restore original
let result = dir_setcurrent(original$)

' Get parent
let parent$ = dir_getparent$(homepath$())
println parent$
```

---

## TPath Functions - Path Manipulation

### Path Combining

| Function | Description |
|----------|-------------|
| `path_combine$(path1$, path2$)` | Combine two path segments |
| `path_combine$(path1$, path2$, path3$)` | Combine three path segments |

**Example:**
```basic
let fullpath$ = path_combine$(homepath$(), "Documents", "report.txt")
println fullpath$
```

### Path Components

| Function | Description |
|----------|-------------|
| `path_getdirectoryname$(path$)` | Get directory portion |
| `path_getfilename$(path$)` | Get filename with extension |
| `path_getfilenamenoext$(path$)` | Get filename without extension |
| `path_getextension$(path$)` | Get extension (with dot) |
| `path_changeextension$(path$, ext$)` | Change extension |
| `path_hasextension(path$)` | Check if has extension |
| `path_getpathroot$(path$)` | Get root portion |
| `path_getfullpath$(path$)` | Convert to absolute path |

**Example:**
```basic
let filepath$ = path_combine$(documentspath$(), "report.pdf")

println "Directory: "; path_getdirectoryname$(filepath$)
println "Filename: "; path_getfilename$(filepath$)
println "Name only: "; path_getfilenamenoext$(filepath$)
println "Extension: "; path_getextension$(filepath$)
println "As backup: "; path_changeextension$(filepath$, ".bak")

' Convert relative to absolute
let rel$ = "data/config.ini"
println path_getfullpath$(rel$)
```

### Path Validation

| Function | Description |
|----------|-------------|
| `path_ispathrooted(path$)` | Check if path is absolute |
| `path_isrelativepath(path$)` | Check if path is relative |
| `path_hasvalidpathchars(path$)` | Check for valid path characters |
| `path_hasvalidfilenamechars(name$)` | Check for valid filename characters |
| `path_matchespattern(path$, pattern$)` | Check if matches wildcard pattern |
| `path_matchespattern(path$, pattern$, casesens)` | Match with case sensitivity option |

**Example:**
```basic
' Validate user input
let userpath$ = "myfile.txt"
if path_hasvalidfilenamechars(userpath$) = 0 then
    println "Invalid filename!"
endif

' Pattern matching
if path_matchespattern("report_2024.pdf", "report_*.pdf") <> 0 then
    println "Matches pattern!"
endif
```

---

## Complete Example: File Manager

```basic
' Simple file manager example
' Demonstrates IOUtilsLib functions

let currentdir$ = ""
let dirs$ = ""
let files$ = ""
let filepath$ = ""
let dirname$ = ""
let filename$ = ""
let filesize = 0
let modified = 0
let i = 0
let dircount = 0
let filecount = 0

println "=== Simple File Manager ==="
println ""

' Get current directory
let currentdir$ = dir_getcurrent$()
println "Current directory: "; currentdir$
println ""

' List files and directories
println "Contents:"
println "==========="

' Get subdirectories
let dirs$ = dir_getdirectories$(currentdir$)
if len(dirs$) > 0 then
    let dircount = count(dirs$)
    for i = 0 to dircount - 1
        let dirname$ = path_getfilename$(line$(dirs$, i))
        println "[DIR]  "; dirname$
    next
endif

' Get files
let files$ = dir_getfiles$(currentdir$)
if len(files$) > 0 then
    let filecount = count(files$)
    for i = 0 to filecount - 1
        let filepath$ = line$(files$, i)
        let filename$ = path_getfilename$(filepath$)
        let filesize = file_getsize(filepath$)
        let modified = file_getlastwritetime(filepath$)
        println "       "; filename$; " ("; stri$(filesize); " bytes)"
    next
endif

println ""
println "=== End of listing ==="
```

---

## Summary: Function Count

| Category | Count |
|----------|-------|
| Error Handling | 2 |
| TFile Functions | 17 |
| TDirectory Functions | 19 |
| TPath Functions | 14 |
| **Total** | **52** |
