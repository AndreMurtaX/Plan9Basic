# Plan9Basic - SysLib Documentation

## System Library Reference Manual

**Version:** 1.0  
**Date:** January 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Command-Line Functions](#command-line-functions)
3. [File Operations](#file-operations)
4. [Directory Operations](#directory-operations)
5. [Path Manipulation Functions](#path-manipulation-functions)
6. [System Path Functions](#system-path-functions)
7. [File Name Generation](#file-name-generation)
8. [Path Separator Functions](#path-separator-functions)
9. [Environment Variables](#environment-variables)
10. [Color Functions](#color-functions)
11. [Complete Examples](#complete-examples)
12. [Quick Reference](#quick-reference)
13. [Platform Notes](#platform-notes)

---

## Overview

The SysLib library provides system-level functions for Plan9Basic programs, enabling interaction with the operating system, file system, and environment. This library is essential for creating cross-platform applications that need to:

- Access command-line arguments
- Perform file and directory operations
- Navigate the file system using platform-appropriate paths
- Work with environment variables
- Handle color values

### Key Characteristics

- **Cross-platform**: Functions work on Windows, macOS, Linux, iOS, and Android
- **Platform-aware paths**: System path functions return appropriate locations for each platform
- **Safe operations**: File operations return success/failure indicators

---

## Command-Line Functions

### paramcount()

Returns the number of command-line parameters passed to the program.

**Syntax:**
```basic
count = paramcount()
```

**Returns:** Number of parameters (excluding the program name)

**Example:**
```basic
println "Number of arguments: "; paramcount()
```

---

### paramstr$()

Returns a specific command-line parameter.

**Syntax:**
```basic
param$ = paramstr$(index)
```

**Parameters:**
- `index`: Parameter index (0 = program path, 1+ = arguments)

**Returns:** The parameter string at the specified index

**Example:**
```basic
' If program was called: myapp.exe file.txt -verbose

println "Program: "; paramstr$(0)    ' Full path to executable
println "Arg 1: "; paramstr$(1)      ' "file.txt"
println "Arg 2: "; paramstr$(2)      ' "-verbose"
```

---

## File Operations

### fileexists()

Checks if a file exists.

**Syntax:**
```basic
result = fileexists(filename$, followLinks)
```

**Parameters:**
- `filename$`: Path to the file
- `followLinks`: Whether to follow symbolic links (0 = no, non-zero = yes)

**Returns:** 1 if file exists, 0 if not

**Example:**
```basic
if fileexists("config.txt", 0) = 1 then
    println "Config file found"
else
    println "Config file not found"
endif

' Follow symbolic links
if fileexists("link_to_file", 1) = 1 then
    println "Target file exists"
endif
```

---

### kill()

Deletes a file.

**Syntax:**
```basic
result = kill(filename$)
```

**Parameters:**
- `filename$`: Path to the file to delete

**Returns:** 1 if successful, 0 if failed

**Example:**
```basic
if kill("temp.dat") = 1 then
    println "File deleted successfully"
else
    println "Failed to delete file"
endif
```

**Warning:** This operation is permanent. The file is not sent to the Recycle Bin/Trash.

---

## Directory Operations

### chdir()

Changes the current working directory.

**Syntax:**
```basic
result = chdir(path$)
```

**Parameters:**
- `path$`: Path to the new directory

**Returns:** 1 (always)

**Example:**
```basic
chdir("C:\Projects")           ' Windows
chdir("/home/user/projects")   ' Linux/macOS
chdir(documentspath$())        ' Cross-platform
```

---

### mkdir()

Creates a new directory.

**Syntax:**
```basic
result = mkdir(path$)
```

**Parameters:**
- `path$`: Path of the directory to create

**Returns:** 1 (always)

**Example:**
```basic
mkdir("NewFolder")
mkdir(documentspath$() + dirseparator$() + "MyApp")
```

**Note:** Parent directories must exist. Use `forcedirectories()` to create the entire path.

---

### forcedirectories()

Creates a directory and all necessary parent directories.

**Syntax:**
```basic
result = forcedirectories(path$)
```

**Parameters:**
- `path$`: Full path to create

**Returns:** 1 if successful, 0 if failed

**Example:**
```basic
' Creates "Projects", "MyApp", and "Data" as needed
path$ = documentspath$() + dirseparator$() + "Projects" + dirseparator$() + "MyApp" + dirseparator$() + "Data"

if forcedirectories(path$) = 1 then
    println "Directory structure created"
else
    println "Failed to create directories"
endif
```

---

### rmdir()

Removes an empty directory.

**Syntax:**
```basic
result = rmdir(path$)
```

**Parameters:**
- `path$`: Path of the directory to remove

**Returns:** 1 (always)

**Example:**
```basic
rmdir("EmptyFolder")
```

**Note:** The directory must be empty. Files must be deleted first.

---

## Path Manipulation Functions

### extractfilename$()

Extracts the file name (with extension) from a full path.

**Syntax:**
```basic
name$ = extractfilename$(fullPath$)
```

**Example:**
```basic
path$ = "C:\Documents\report.pdf"
println extractfilename$(path$)    ' Output: report.pdf

path$ = "/home/user/data.txt"
println extractfilename$(path$)    ' Output: data.txt
```

---

### extractfilepath$()

Extracts the directory path from a full path.

**Syntax:**
```basic
dir$ = extractfilepath$(fullPath$)
```

**Example:**
```basic
path$ = "C:\Documents\report.pdf"
println extractfilepath$(path$)    ' Output: C:\Documents\

path$ = "/home/user/data.txt"
println extractfilepath$(path$)    ' Output: /home/user/
```

---

### extractfileext$()

Extracts the file extension (including the dot).

**Syntax:**
```basic
ext$ = extractfileext$(filename$)
```

**Example:**
```basic
println extractfileext$("document.pdf")    ' Output: .pdf
println extractfileext$("archive.tar.gz")  ' Output: .gz
println extractfileext$("README")          ' Output: (empty)
```

---

### changefileext$()

Changes the extension of a file name.

**Syntax:**
```basic
newName$ = changefileext$(filename$, newExtension$)
```

**Parameters:**
- `filename$`: Original file name or path
- `newExtension$`: New extension (should include the dot)

**Example:**
```basic
println changefileext$("document.txt", ".pdf")     ' Output: document.pdf
println changefileext$("image.jpg", ".png")        ' Output: image.png
println changefileext$("C:\data\file.old", ".new") ' Output: C:\data\file.new
```

---

## System Path Functions

Plan9Basic provides functions to get platform-specific standard directories. These return appropriate paths on each operating system.

### Common Paths

#### homepath$()

Returns the user's home directory.

**Syntax:**
```basic
path$ = homepath$()
```

**Platform Results:**
| Platform | Example Path |
|----------|--------------|
| Windows | `C:\Users\Username` |
| macOS | `/Users/Username` |
| Linux | `/home/username` |
| iOS | `/var/mobile/Containers/Data/Application/...` |
| Android | `/data/user/0/com.app/files` |

---

#### documentspath$()

Returns the user's documents folder.

**Syntax:**
```basic
path$ = documentspath$()
```

**Platform Results:**
| Platform | Example Path |
|----------|--------------|
| Windows | `C:\Users\Username\Documents` |
| macOS | `/Users/Username/Documents` |
| Linux | `/home/username/Documents` |
| iOS | App sandbox documents |
| Android | App-specific documents |

---

#### shareddocumentspath$()

Returns the shared documents folder accessible to all users.

**Syntax:**
```basic
path$ = shareddocumentspath$()
```

---

#### temppath$()

Returns the system's temporary files directory.

**Syntax:**
```basic
path$ = temppath$()
```

**Example:**
```basic
tempDir$ = temppath$()
println "Temp directory: "; tempDir$
```

---

#### cachepath$()

Returns the application's cache directory.

**Syntax:**
```basic
path$ = cachepath$()
```

**Use for:** Temporary data that can be regenerated if deleted.

---

#### publicpath$()

Returns the public/shared storage path.

**Syntax:**
```basic
path$ = publicpath$()
```

---

#### librarypath$()

Returns the application library/support path.

**Syntax:**
```basic
path$ = librarypath$()
```

**Use for:** Application support files, preferences, etc.

---

### Media Paths

#### picturespath$() / sharedpicturespath$()

Returns the pictures folder (user-specific or shared).

**Syntax:**
```basic
path$ = picturespath$()
path$ = sharedpicturespath$()
```

---

#### musicpath$() / sharedmusicpath$()

Returns the music folder (user-specific or shared).

**Syntax:**
```basic
path$ = musicpath$()
path$ = sharedmusicpath$()
```

---

#### moviespath$() / sharedmoviespath$()

Returns the movies/videos folder (user-specific or shared).

**Syntax:**
```basic
path$ = moviespath$()
path$ = sharedmoviespath$()
```

---

#### camerapath$() / sharedcamerapath$()

Returns the camera roll/photos folder (user-specific or shared).

**Syntax:**
```basic
path$ = camerapath$()
path$ = sharedcamerapath$()
```

**Note:** Primarily useful on mobile platforms (iOS/Android).

---

#### downloadspath$() / shareddownloadspath$()

Returns the downloads folder (user-specific or shared).

**Syntax:**
```basic
path$ = downloadspath$()
path$ = shareddownloadspath$()
```

---

### Mobile-Specific Paths

These paths are primarily useful on mobile platforms:

#### alarmspath$() / sharedalarmspath$()

Returns the alarms sound folder.

**Syntax:**
```basic
path$ = alarmspath$()
path$ = sharedalarmspath$()
```

---

#### ringtonespath$() / sharedringtonespath$()

Returns the ringtones folder.

**Syntax:**
```basic
path$ = ringtonespath$()
path$ = sharedringtonespath$()
```

---

## File Name Generation

### randomfilename$()

Generates a random file name (without path).

**Syntax:**
```basic
name$ = randomfilename$()
```

**Returns:** A random string suitable for use as a file name (typically 8.3 format)

**Example:**
```basic
println randomfilename$()    ' Output: something like "tmpA1B2C.tmp"
```

---

### guidfilename$()

Generates a GUID-based unique file name.

**Syntax:**
```basic
name$ = guidfilename$(useSeparators)
```

**Parameters:**
- `useSeparators`: Include hyphens in GUID (0 = no, non-zero = yes)

**Returns:** A GUID string

**Example:**
```basic
println guidfilename$(1)    ' Output: {A1B2C3D4-E5F6-7890-ABCD-EF1234567890}
println guidfilename$(0)    ' Output: {A1B2C3D4E5F67890ABCDEF1234567890}
```

---

### tempfilename$()

Creates a unique temporary file and returns its path.

**Syntax:**
```basic
path$ = tempfilename$()
```

**Returns:** Full path to a newly created temporary file

**Example:**
```basic
tempFile$ = tempfilename$()
println "Temp file created: "; tempFile$

' Use the file...

' Clean up when done
kill(tempFile$)
```

**Note:** This actually creates the file; remember to delete it when done.

---

## Path Separator Functions

### dirseparator$()

Returns the directory separator character for the current platform.

**Syntax:**
```basic
sep$ = dirseparator$()
```

**Returns:**
- Windows: `\`
- macOS/Linux/iOS/Android: `/`

**Example:**
```basic
path$ = documentspath$() + dirseparator$() + "MyApp" + dirseparator$() + "data.txt"
println path$
```

---

### altseparator$()

Returns the alternate directory separator character.

**Syntax:**
```basic
sep$ = altseparator$()
```

**Returns:**
- Windows: `/` (also accepted)
- Other platforms: same as `dirseparator$()`

---

### pathseparator$()

Returns the path list separator (used in PATH environment variable, etc.).

**Syntax:**
```basic
sep$ = pathseparator$()
```

**Returns:**
- Windows: `;`
- macOS/Linux: `:`

**Example:**
```basic
pathEnv$ = environ$("PATH")
println "PATH separator: "; pathseparator$()
' Use to split PATH into individual directories
```

---

## Environment Variables

### environ$()

Retrieves the value of an environment variable.

**Syntax:**
```basic
value$ = environ$(variableName$)
```

**Parameters:**
- `variableName$`: Name of the environment variable

**Returns:** Value of the variable, or empty string if not found

**Example:**
```basic
println "User: "; environ$("USERNAME")       ' Windows
println "User: "; environ$("USER")           ' Linux/macOS
println "Home: "; environ$("HOME")
println "Path: "; environ$("PATH")
```

**Common Environment Variables:**
| Variable | Platform | Description |
|----------|----------|-------------|
| `USERNAME` | Windows | Current user name |
| `USER` | Linux/macOS | Current user name |
| `HOME` | Linux/macOS | Home directory |
| `USERPROFILE` | Windows | User profile directory |
| `PATH` | All | Executable search paths |
| `TEMP` / `TMP` | Windows | Temporary directory |
| `TMPDIR` | macOS/Linux | Temporary directory |

---

## Color Functions

### color()

Converts a color name or hex string to a numeric color value.

**Syntax:**
```basic
colorValue = color(colorString$)
```

**Parameters:**
- `colorString$`: Color name or hex value

**Supported Color Names:**
`Black`, `Maroon`, `Green`, `Olive`, `Navy`, `Purple`, `Teal`, `Gray`, `Silver`, `Red`, `Lime`, `Yellow`, `Blue`, `Fuchsia`, `Aqua`, `White`, and many more.

**Example:**
```basic
c = color("Red")
c = color("clBlue")
c = color("$FF0000")     ' Hex format
```

---

### alphacolor()

Converts a color string to an alpha color value (includes transparency).

**Syntax:**
```basic
colorValue = alphacolor(colorString$)
```

**Parameters:**
- `colorString$`: Color name or hex value with alpha

**Example:**
```basic
c = alphacolor("Red")
c = alphacolor("#FF0000")
c = alphacolor("#80FF0000")  ' Semi-transparent red
```

---

### colortostr$()

Converts a numeric color value back to a string representation.

**Syntax:**
```basic
colorString$ = colortostr$(colorValue)
```

**Example:**
```basic
c = color("Blue")
println colortostr$(c)    ' Output: clBlue (or similar)
```

---

## Complete Examples

### Example 1: Cross-Platform Path Builder

```basic
' Build paths that work on any platform
function buildPath$(base$, parts$) local result$, sep$
    sep$ = dirseparator$()
    result$ = base$
    
    ' Ensure base doesn't end with separator
    if right$(result$) = sep$ then
        result$ = left$(result$, len(result$) - 1)
    endif
    
    ' Add the parts
    result$ = result$ + sep$ + parts$
    
    return result$
endfunction

println "=== Cross-Platform Path Demo ==="
println ""

println "Home: "; homepath$()
println "Documents: "; documentspath$()
println "Temp: "; temppath$()
println "Downloads: "; downloadspath$()
println ""

' Build a path to an app data folder
appData$ = buildPath$(documentspath$(), "MyApp")
println "App data path: "; appData$

configFile$ = buildPath$(appData$, "config.txt")
println "Config file: "; configFile$
```

---

### Example 2: Command-Line Argument Processor

```basic
' Process command-line arguments
println "=== Command Line Arguments ==="
println ""

println "Program: "; paramstr$(0)
println "Argument count: "; paramcount()
println ""

if paramcount() > 0 then
    println "Arguments:"
    for i = 1 to paramcount()
        arg$ = paramstr$(i)
        print "  ["; i; "] "; arg$
        
        ' Check for flag arguments
        if left$(arg$) = "-" then
            println " (flag)"
        else
            println ""
        endif
    next
else
    println "No arguments provided."
    println ""
    println "Usage: program [options] [files...]"
    println "  -h    Show help"
    println "  -v    Verbose mode"
endif
```

---

### Example 3: File Manager Operations

```basic
' File management utilities
function createAppFolder$() local path$
    path$ = documentspath$() + dirseparator$() + "Plan9BasicApp"
    
    if forcedirectories(path$) = 1 then
        return path$
    else
        return ""
    endif
endfunction

function fileInfo$(filename$) local info$
    info$ = "File: " + extractfilename$(filename$) + chr$(10)
    info$ = info$ + "Path: " + extractfilepath$(filename$) + chr$(10)
    info$ = info$ + "Extension: " + extractfileext$(filename$) + chr$(10)
    info$ = info$ + "Exists: " + str$(fileexists(filename$, 0))
    return info$
endfunction

println "=== File Manager Demo ==="
println ""

' Create app folder
appFolder$ = createAppFolder$()
if len(appFolder$) > 0 then
    println "App folder created: "; appFolder$
else
    println "Failed to create app folder"
endif

println ""

' Analyze a file path
testPath$ = documentspath$() + dirseparator$() + "test.txt"
println "Analyzing: "; testPath$
println ""
println fileInfo$(testPath$)

println ""

' Change extension
newPath$ = changefileext$(testPath$, ".bak")
println "With .bak extension: "; newPath$
```

---

### Example 4: Temporary File Handling

```basic
' Working with temporary files
println "=== Temporary File Demo ==="
println ""

println "Temp directory: "; temppath$()
println ""

' Generate random file names
println "Random file names:"
for i = 1 to 3
    println "  "; randomfilename$()
next

println ""

' Generate GUID file names
println "GUID file names:"
println "  With separators: "; guidfilename$(1)
println "  Without separators: "; guidfilename$(0)

println ""

' Create an actual temp file
tempFile$ = tempfilename$()
println "Created temp file: "; tempFile$

' Check it exists
if fileexists(tempFile$, 0) = 1 then
    println "File exists: Yes"
    
    ' Clean up
    if kill(tempFile$) = 1 then
        println "File deleted successfully"
    endif
else
    println "File exists: No (unexpected)"
endif
```

---

### Example 5: Environment Information

```basic
' Display system environment information
println "=== Environment Information ==="
println ""

' Try different user name variables
user$ = environ$("USERNAME")
if len(user$) = 0 then
    user$ = environ$("USER")
endif
println "User: "; user$

' Home directory
home$ = environ$("HOME")
if len(home$) = 0 then
    home$ = environ$("USERPROFILE")
endif
println "Home (env): "; home$
println "Home (func): "; homepath$()

println ""

' Path information
println "Directory separator: ["; dirseparator$(); "]"
println "Path separator: ["; pathseparator$(); "]"

println ""

' System paths
println "System Paths:"
println "  Documents: "; documentspath$()
println "  Pictures: "; picturespath$()
println "  Music: "; musicpath$()
println "  Downloads: "; downloadspath$()
println "  Temp: "; temppath$()
println "  Cache: "; cachepath$()
```

---

### Example 6: Color Conversion Utility

```basic
' Color conversion demonstrations
println "=== Color Utilities ==="
println ""

' Convert named colors
println "Named colors:"
println "  Red = "; color("Red")
println "  Blue = "; color("Blue")
println "  Green = "; color("Green")

println ""

' Alpha colors
println "Alpha colors:"
println "  Red (alpha) = "; alphacolor("Red")
println "  #FF0000 = "; alphacolor("#FF0000")

println ""

' Convert back to string
c = color("Navy")
println "Navy as number: "; c
println "Back to string: "; colortostr$(c)
```

---

## Quick Reference

### Command Line
```basic
paramcount()             ' Number of arguments
paramstr$(n)             ' Get argument n (0=program)
```

### File Operations
```basic
fileexists(file$, followLinks)  ' Check if file exists (1/0)
kill(file$)                      ' Delete file (1=success)
```

### Directory Operations
```basic
chdir(path$)              ' Change directory
mkdir(path$)              ' Create directory
rmdir(path$)              ' Remove empty directory
forcedirectories(path$)   ' Create full path (1=success)
```

### Path Manipulation
```basic
extractfilename$(path$)   ' Get filename from path
extractfilepath$(path$)   ' Get directory from path
extractfileext$(file$)    ' Get extension (with dot)
changefileext$(file$, ext$)  ' Change extension
```

### System Paths
```basic
homepath$()               ' User home directory
documentspath$()          ' Documents folder
shareddocumentspath$()    ' Shared documents
temppath$()               ' Temporary folder
cachepath$()              ' Cache folder
publicpath$()             ' Public folder
librarypath$()            ' Library/support folder
```

### Media Paths
```basic
picturespath$()           ' Pictures folder
sharedpicturespath$()     ' Shared pictures
musicpath$()              ' Music folder
sharedmusicpath$()        ' Shared music
moviespath$()             ' Movies folder
sharedmoviespath$()       ' Shared movies
downloadspath$()          ' Downloads folder
shareddownloadspath$()    ' Shared downloads
camerapath$()             ' Camera folder
sharedcamerapath$()       ' Shared camera
```

### Mobile Paths
```basic
alarmspath$()             ' Alarms folder
sharedalarmspath$()       ' Shared alarms
ringtonespath$()          ' Ringtones folder
sharedringtonespath$()    ' Shared ringtones
```

### File Name Generation
```basic
randomfilename$()         ' Random file name
guidfilename$(useSep)     ' GUID-based name
tempfilename$()           ' Create temp file, return path
```

### Path Separators
```basic
dirseparator$()           ' Directory separator (\ or /)
altseparator$()           ' Alternate separator
pathseparator$()          ' PATH list separator (; or :)
```

### Environment
```basic
environ$(name$)           ' Get environment variable
```

### Colors
```basic
color(name$)              ' Color name/hex to number
alphacolor(name$)         ' Color with alpha to number
colortostr$(n)            ' Number to color string
```

---

## Platform Notes

### Windows

- Directory separator: `\`
- Path separator: `;`
- User environment: `USERNAME`, `USERPROFILE`
- Standard paths typically under `C:\Users\Username\`

### macOS

- Directory separator: `/`
- Path separator: `:`
- User environment: `USER`, `HOME`
- Standard paths under `/Users/Username/`
- Library path is `~/Library/`

### Linux

- Directory separator: `/`
- Path separator: `:`
- User environment: `USER`, `HOME`
- Standard paths under `/home/username/`
- Follows XDG Base Directory Specification where applicable

### iOS

- Directory separator: `/`
- Apps run in sandboxed containers
- Standard paths point to app-specific locations
- Limited file system access due to sandboxing

### Android

- Directory separator: `/`
- Apps have private storage areas
- Shared paths require appropriate permissions
- External storage paths may vary by device

### Cross-Platform Tips

1. **Always use `dirseparator$()`** when building paths
2. **Use system path functions** instead of hardcoded paths
3. **Check `fileexists()`** before file operations
4. **Use `forcedirectories()`** to create nested folders
5. **Clean up temporary files** created with `tempfilename$()`

---

*End of SysLib Documentation*
