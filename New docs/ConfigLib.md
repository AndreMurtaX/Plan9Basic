# Plan9Basic - ConfigLib Documentation

## Configuration Library Reference Manual

**Version:** 1.0  
**Date:** January 2026  
**Total Functions:** 31

---

## Table of Contents

1. [Overview](#overview)
2. [Storage Locations](#storage-locations)
3. [INI File Format](#ini-file-format)
4. [Config File Functions](#config-file-functions)
5. [String Operations](#string-operations)
6. [Numeric Operations](#numeric-operations)
7. [Boolean Operations](#boolean-operations)
8. [Key and Section Query](#key-and-section-query)
9. [Key and Section Management](#key-and-section-management)
10. [Enumeration Functions](#enumeration-functions)
11. [File Operations](#file-operations)
12. [Utility Functions](#utility-functions)
13. [Complete Examples](#complete-examples)
14. [Quick Reference](#quick-reference)

---

## Overview

The ConfigLib library provides persistent key/value storage for Plan9Basic applications. It uses the INI file format to store configuration data that persists between program executions, making it ideal for saving user preferences, application settings, game progress, and other persistent data.

### Key Features

| Feature | Description |
|---------|-------------|
| **Cross-Platform** | Works on Windows, Linux, macOS, Android, and iOS |
| **INI File Format** | Human-readable text files with sections and key/value pairs |
| **Multiple Data Types** | Support for strings, numbers, and booleans |
| **Section Support** | Organize settings into logical groups |
| **Auto-Save Mode** | Optional automatic saving after each change |
| **Multiple Config Files** | Work with multiple configuration files simultaneously |
| **Default Values** | All get functions accept default values for missing keys |

### Function Naming Convention

| Suffix | Returns | Example |
|--------|---------|---------|
| `#` | Pointer (config object) | `cfg_open#()` |
| `$` | String | `cfg_get$()` |
| (none) | Number | `cfg_getn()` |

### Default Section

When you pass an empty string `""` as the section parameter, the library uses the default section named `"General"`. This simplifies usage for applications that don't need multiple sections.

---

## Storage Locations

ConfigLib automatically stores configuration files in platform-appropriate locations:

| Platform | Storage Path |
|----------|--------------|
| **Windows** | `Documents\Plan9Basic\Config\` |
| **Linux** | `~/.config/Plan9Basic/` |
| **macOS** | `~/Library/Application Support/Plan9Basic/` |
| **Android** | App's documents directory `/Config/` |
| **iOS** | App's documents directory `/Config/` |

### File Path Resolution

When opening a config file:
- **Simple filename** (e.g., `"myapp"`) → Stored in the platform config directory
- **Full path** (e.g., `"/home/user/settings.ini"`) → Used as-is
- **No extension** → `.ini` extension is added automatically

**Examples:**
```basic
' These are equivalent on Windows:
cfg1# = cfg_open#("settings")           ' → Documents\Plan9Basic\Config\settings.ini
cfg2# = cfg_open#("settings.ini")       ' → Documents\Plan9Basic\Config\settings.ini

' Full path is used as-is:
cfg3# = cfg_open#("C:\\MyApp\\config.ini") ' → C:\MyApp\config.ini
```

---

## INI File Format

Configuration files use the standard INI format:

```ini
[General]
username=John
theme=dark

[Window]
width=800
height=600
maximized=0

[Recent]
file1=C:\Documents\report.txt
file2=C:\Documents\notes.txt
```

### Format Rules

- **Sections** are enclosed in square brackets: `[SectionName]`
- **Keys** and **values** are separated by `=`
- **Comments** are not supported in the file
- **Encoding** is UTF-8

---

## Config File Functions

### cfg_open#()

Opens or creates a configuration file with manual save control.

**Signature:** `cfg_open#@$`

**Syntax:**
```basic
cfg# = cfg_open#(filename$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `filename$` | String | Filename or full path |

**Returns:** Pointer to configuration object

**Notes:**
- If the file doesn't exist, it will be created when saved
- Changes are only written to disk when `cfg_save()` is called
- The config is automatically saved when the program ends if there are unsaved changes

**Example:**
```basic
cfg# = cfg_open#("myapp")
cfg_sets#(cfg#, "username", "John")
cfg_setns#(cfg#, "volume", 75)
cfg_save(cfg#)  ' Must call save to write to disk
```

---

### cfg_open_auto#()

Opens or creates a configuration file with automatic saving enabled.

**Signature:** `cfg_open_auto#@$`

**Syntax:**
```basic
cfg# = cfg_open_auto#(filename$)
```

**Returns:** Pointer to configuration object with auto-save enabled

**Notes:**
- Every change is immediately written to disk
- More convenient but may be slower for many rapid changes
- Ideal for critical settings that must not be lost

**Example:**
```basic
cfg# = cfg_open_auto#("critical_settings")
cfg_sets#(cfg#, "lastSave", "2025-01-21")  ' Automatically saved
cfg_setns#(cfg#, "counter", 42)             ' Automatically saved
' No need to call cfg_save()
```

---

## String Operations

### cfg_set#() - With Section

Sets a string value in a specified section.

**Signature:** `cfg_set#@#$$$`

**Syntax:**
```basic
cfg# = cfg_set#(cfg#, section$, key$, value$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `cfg#` | Pointer | Configuration object |
| `section$` | String | Section name (empty for default) |
| `key$` | String | Key name |
| `value$` | String | Value to store |

**Returns:** The same config object (for chaining)

**Example:**
```basic
cfg# = cfg_open#("settings")
cfg_set#(cfg#, "User", "name", "Alice")
cfg_set#(cfg#, "User", "email", "alice@example.com")
cfg_set#(cfg#, "Display", "theme", "dark")
cfg_save(cfg#)
```

---

### cfg_get$() - With Section

Gets a string value from a specified section.

**Signature:** `cfg_get$@#$$$`

**Syntax:**
```basic
value$ = cfg_get$(cfg#, section$, key$, default$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `cfg#` | Pointer | Configuration object |
| `section$` | String | Section name (empty for default) |
| `key$` | String | Key name |
| `default$` | String | Default value if key doesn't exist |

**Returns:** The stored value or the default

**Example:**
```basic
cfg# = cfg_open#("settings")
name$ = cfg_get$(cfg#, "User", "name", "Guest")
theme$ = cfg_get$(cfg#, "Display", "theme", "light")
println "Welcome, "; name$
```

---

### cfg_sets#() - Default Section

Sets a string value in the default section ("General").

**Signature:** `cfg_sets#@#$$`

**Syntax:**
```basic
cfg# = cfg_sets#(cfg#, key$, value$)
```

**Example:**
```basic
cfg# = cfg_open#("myapp")
cfg_sets#(cfg#, "language", "en")
cfg_sets#(cfg#, "lastUser", "Bob")
cfg_save(cfg#)
```

---

### cfg_gets$() - Default Section

Gets a string value from the default section.

**Signature:** `cfg_gets$@#$$`

**Syntax:**
```basic
value$ = cfg_gets$(cfg#, key$, default$)
```

**Example:**
```basic
cfg# = cfg_open#("myapp")
lang$ = cfg_gets$(cfg#, "language", "en")
user$ = cfg_gets$(cfg#, "lastUser", "Anonymous")
```

---

## Numeric Operations

### cfg_setn#() - With Section

Sets a numeric value in a specified section.

**Signature:** `cfg_setn#@#$$n`

**Syntax:**
```basic
cfg# = cfg_setn#(cfg#, section$, key$, value)
```

**Example:**
```basic
cfg# = cfg_open#("game")
cfg_setn#(cfg#, "Window", "width", 1024)
cfg_setn#(cfg#, "Window", "height", 768)
cfg_setn#(cfg#, "Audio", "volume", 0.8)
cfg_save(cfg#)
```

---

### cfg_getn() - With Section

Gets a numeric value from a specified section.

**Signature:** `cfg_getn@#$$n`

**Syntax:**
```basic
value = cfg_getn(cfg#, section$, key$, default)
```

**Example:**
```basic
cfg# = cfg_open#("game")
width = cfg_getn(cfg#, "Window", "width", 800)
height = cfg_getn(cfg#, "Window", "height", 600)
volume = cfg_getn(cfg#, "Audio", "volume", 1.0)
```

---

### cfg_setns#() - Default Section

Sets a numeric value in the default section.

**Signature:** `cfg_setns#@#$n`

**Syntax:**
```basic
cfg# = cfg_setns#(cfg#, key$, value)
```

**Example:**
```basic
cfg# = cfg_open#("counter")
cfg_setns#(cfg#, "runCount", 42)
cfg_setns#(cfg#, "highScore", 15000)
cfg_save(cfg#)
```

---

### cfg_getns() - Default Section

Gets a numeric value from the default section.

**Signature:** `cfg_getns@#$n`

**Syntax:**
```basic
value = cfg_getns(cfg#, key$, default)
```

**Example:**
```basic
cfg# = cfg_open#("counter")
runs = cfg_getns(cfg#, "runCount", 0)
best = cfg_getns(cfg#, "highScore", 0)
println "This program has been run "; runs; " times"
```

---

## Boolean Operations

Boolean values are stored as `0` (false) or `1` (true) in the INI file.

### cfg_setb#() - With Section

Sets a boolean value in a specified section.

**Signature:** `cfg_setb#@#$$n`

**Syntax:**
```basic
cfg# = cfg_setb#(cfg#, section$, key$, value)
```

**Parameters:**
- `value`: 0 = false, non-zero = true

**Example:**
```basic
cfg# = cfg_open#("prefs")
cfg_setb#(cfg#, "Features", "darkMode", 1)
cfg_setb#(cfg#, "Features", "notifications", 0)
cfg_setb#(cfg#, "Features", "autoUpdate", 1)
cfg_save(cfg#)
```

---

### cfg_getb() - With Section

Gets a boolean value from a specified section.

**Signature:** `cfg_getb@#$$n`

**Syntax:**
```basic
value = cfg_getb(cfg#, section$, key$, default)
```

**Returns:** 1 for true, 0 for false

**Example:**
```basic
cfg# = cfg_open#("prefs")
darkMode = cfg_getb(cfg#, "Features", "darkMode", 0)
if darkMode = 1 then
    println "Dark mode enabled"
endif
```

---

### cfg_setbs#() - Default Section

Sets a boolean value in the default section.

**Signature:** `cfg_setbs#@#$n`

**Syntax:**
```basic
cfg# = cfg_setbs#(cfg#, key$, value)
```

---

### cfg_getbs() - Default Section

Gets a boolean value from the default section.

**Signature:** `cfg_getbs@#$n`

**Syntax:**
```basic
value = cfg_getbs(cfg#, key$, default)
```

**Example:**
```basic
cfg# = cfg_open#("app")
firstRun = cfg_getbs(cfg#, "firstRun", 1)
if firstRun = 1 then
    println "Welcome! This is your first time running the app."
    cfg_setbs#(cfg#, "firstRun", 0)
    cfg_save(cfg#)
endif
```

---

## Key and Section Query

### cfg_exists()

Checks if a key exists in a specified section.

**Signature:** `cfg_exists@#$$`

**Syntax:**
```basic
exists = cfg_exists(cfg#, section$, key$)
```

**Returns:** 1 if the key exists, 0 otherwise

**Example:**
```basic
cfg# = cfg_open#("settings")
if cfg_exists(cfg#, "User", "email") = 1 then
    email$ = cfg_get$(cfg#, "User", "email", "")
    println "Email: "; email$
else
    println "No email configured"
endif
```

---

### cfg_haskey()

Checks if a key exists in the default section.

**Signature:** `cfg_haskey@#$`

**Syntax:**
```basic
exists = cfg_haskey(cfg#, key$)
```

**Returns:** 1 if the key exists, 0 otherwise

**Example:**
```basic
cfg# = cfg_open#("app")
if cfg_haskey(cfg#, "license") = 1 then
    println "Licensed version"
else
    println "Trial version"
endif
```

---

### cfg_section_exists()

Checks if a section exists.

**Signature:** `cfg_section_exists@#$`

**Syntax:**
```basic
exists = cfg_section_exists(cfg#, section$)
```

**Returns:** 1 if the section exists, 0 otherwise

**Example:**
```basic
cfg# = cfg_open#("game")
if cfg_section_exists(cfg#, "SaveGame") = 1 then
    println "Save game found!"
else
    println "No save game - starting new game"
endif
```

---

## Key and Section Management

### cfg_delete#()

Deletes a key from a specified section.

**Signature:** `cfg_delete#@#$$`

**Syntax:**
```basic
cfg# = cfg_delete#(cfg#, section$, key$)
```

**Returns:** The same config object (for chaining)

**Example:**
```basic
cfg# = cfg_open#("settings")
cfg_delete#(cfg#, "User", "temporaryToken")
cfg_save(cfg#)
```

---

### cfg_deletekey#()

Deletes a key from the default section.

**Signature:** `cfg_deletekey#@#$`

**Syntax:**
```basic
cfg# = cfg_deletekey#(cfg#, key$)
```

**Example:**
```basic
cfg# = cfg_open#("app")
cfg_deletekey#(cfg#, "tempData")
cfg_save(cfg#)
```

---

### cfg_section_delete#()

Deletes an entire section and all its keys.

**Signature:** `cfg_section_delete#@#$`

**Syntax:**
```basic
cfg# = cfg_section_delete#(cfg#, section$)
```

**Example:**
```basic
cfg# = cfg_open#("game")
' Clear the save game
cfg_section_delete#(cfg#, "SaveGame")
cfg_save(cfg#)
println "Save game deleted"
```

---

### cfg_clear#()

Clears all sections and keys from the configuration.

**Signature:** `cfg_clear#@#`

**Syntax:**
```basic
cfg# = cfg_clear#(cfg#)
```

**Example:**
```basic
cfg# = cfg_open#("settings")
' Reset all settings
cfg_clear#(cfg#)
' Set defaults
cfg_sets#(cfg#, "language", "en")
cfg_setns#(cfg#, "volume", 100)
cfg_save(cfg#)
println "Settings reset to defaults"
```

---

## Enumeration Functions

### cfg_sections$()

Gets a comma-separated list of all section names.

**Signature:** `cfg_sections$@#`

**Syntax:**
```basic
sections$ = cfg_sections$(cfg#)
```

**Returns:** Comma-separated list of section names

**Example:**
```basic
cfg# = cfg_open#("settings")
sections$ = cfg_sections$(cfg#)
println "Sections: "; sections$
' Output: Sections: General,User,Window,Audio
```

---

### cfg_keys$()

Gets a comma-separated list of all keys in a section.

**Signature:** `cfg_keys$@#$`

**Syntax:**
```basic
keys$ = cfg_keys$(cfg#, section$)
```

**Returns:** Comma-separated list of key names

**Example:**
```basic
cfg# = cfg_open#("settings")
keys$ = cfg_keys$(cfg#, "Window")
println "Window keys: "; keys$
' Output: Window keys: width,height,x,y,maximized
```

---

### cfg_keycount()

Counts the number of keys in a section.

**Signature:** `cfg_keycount@#$`

**Syntax:**
```basic
count = cfg_keycount(cfg#, section$)
```

**Example:**
```basic
cfg# = cfg_open#("settings")
count = cfg_keycount(cfg#, "User")
println "User section has "; count; " settings"
```

---

### cfg_sectioncount()

Counts the number of sections.

**Signature:** `cfg_sectioncount@#`

**Syntax:**
```basic
count = cfg_sectioncount(cfg#)
```

**Example:**
```basic
cfg# = cfg_open#("settings")
count = cfg_sectioncount(cfg#)
println "Config has "; count; " sections"
```

---

## File Operations

### cfg_save()

Saves all changes to disk.

**Signature:** `cfg_save@#`

**Syntax:**
```basic
success = cfg_save(cfg#)
```

**Returns:** 1 on success, 0 on failure

**Example:**
```basic
cfg# = cfg_open#("settings")
cfg_sets#(cfg#, "theme", "dark")
if cfg_save(cfg#) = 1 then
    println "Settings saved"
else
    println "Error saving settings"
endif
```

---

### cfg_reload#()

Reloads the configuration from disk, discarding unsaved changes.

**Signature:** `cfg_reload#@#`

**Syntax:**
```basic
cfg# = cfg_reload#(cfg#)
```

**Returns:** The same config object

**Example:**
```basic
cfg# = cfg_open#("settings")
cfg_sets#(cfg#, "theme", "experimental")

' User cancels - discard changes
cfg_reload#(cfg#)
println "Changes discarded"
```

---

### cfg_filename$()

Gets the full file path of the configuration file.

**Signature:** `cfg_filename$@#`

**Syntax:**
```basic
path$ = cfg_filename$(cfg#)
```

**Example:**
```basic
cfg# = cfg_open#("myapp")
path$ = cfg_filename$(cfg#)
println "Config stored at: "; path$
' Windows output: Config stored at: C:\Users\John\Documents\Plan9Basic\Config\myapp.ini
```

---

### cfg_modified()

Checks if there are unsaved changes.

**Signature:** `cfg_modified@#`

**Syntax:**
```basic
modified = cfg_modified(cfg#)
```

**Returns:** 1 if there are unsaved changes, 0 otherwise

**Example:**
```basic
cfg# = cfg_open#("settings")
cfg_sets#(cfg#, "test", "value")

if cfg_modified(cfg#) = 1 then
    println "You have unsaved changes. Save? (Y/N)"
endif
```

---

### cfg_autosave#()

Enables or disables auto-save mode.

**Signature:** `cfg_autosave#@#n`

**Syntax:**
```basic
cfg# = cfg_autosave#(cfg#, enabled)
```

**Parameters:**
- `enabled`: 0 = disable auto-save, non-zero = enable auto-save

**Returns:** The same config object

**Example:**
```basic
cfg# = cfg_open#("settings")

' Enable auto-save for critical updates
cfg_autosave#(cfg#, 1)
cfg_sets#(cfg#, "critical", "data")  ' Saved immediately

' Disable for batch updates
cfg_autosave#(cfg#, 0)
cfg_sets#(cfg#, "key1", "value1")
cfg_sets#(cfg#, "key2", "value2")
cfg_sets#(cfg#, "key3", "value3")
cfg_save(cfg#)  ' Save all at once
```

---

## Utility Functions

### cfg_path$()

Gets the platform-specific configuration directory path.

**Signature:** `cfg_path$@`

**Syntax:**
```basic
path$ = cfg_path$()
```

**Returns:** The configuration directory path for the current platform

**Example:**
```basic
path$ = cfg_path$()
println "Config directory: "; path$
' Windows: Config directory: C:\Users\John\Documents\Plan9Basic\Config
' Linux:   Config directory: /home/john/.config/Plan9Basic
' macOS:   Config directory: /Users/john/Library/Application Support/Plan9Basic
```

---

## Complete Examples

### Example 1: Application Settings

```basic
' Simple application settings manager
println "=== Application Settings ==="
println ""

' Open config with auto-save for convenience
cfg# = cfg_open_auto#("myapp")

' Check if first run
if cfg_haskey(cfg#, "initialized") = 0 then
    println "First run - setting defaults..."
    cfg_sets#(cfg#, "initialized", "yes")
    cfg_sets#(cfg#, "language", "en")
    cfg_setns#(cfg#, "volume", 80)
    cfg_setbs#(cfg#, "fullscreen", 0)
endif

' Display current settings
println "Language: "; cfg_gets$(cfg#, "language", "en")
println "Volume: "; cfg_getns(cfg#, "volume", 80)
println "Fullscreen: "; cfg_getbs(cfg#, "fullscreen", 0)
println ""
println "Config file: "; cfg_filename$(cfg#)
```

---

### Example 2: Game Save System

```basic
' Game save system using sections
println "=== Game Save System ==="
println ""

cfg# = cfg_open#("savegame")

' Check for existing save
if cfg_section_exists(cfg#, "Player") = 1 then
    println "Loading saved game..."
    name$ = cfg_get$(cfg#, "Player", "name", "Hero")
    level = cfg_getn(cfg#, "Player", "level", 1)
    gold = cfg_getn(cfg#, "Player", "gold", 0)
    health = cfg_getn(cfg#, "Player", "health", 100)
    
    println "Player: "; name$
    println "Level: "; level
    println "Gold: "; gold
    println "Health: "; health
else
    println "Starting new game..."
    name$ = "Hero"
    level = 1
    gold = 100
    health = 100
endif

' Simulate gameplay
println ""
println "Playing..."
gold = gold + 50
level = level + 1
health = health - 10

' Save game
println "Saving game..."
cfg_set#(cfg#, "Player", "name", name$)
cfg_setn#(cfg#, "Player", "level", level)
cfg_setn#(cfg#, "Player", "gold", gold)
cfg_setn#(cfg#, "Player", "health", health)
cfg_save(cfg#)
println "Game saved!"
```

---

### Example 3: Window Position Memory

```basic
' Remember window position and size
println "=== Window Position Manager ==="
println ""

cfg# = cfg_open#("window")

' Load saved position or use defaults
x = cfg_getn(cfg#, "Position", "x", 100)
y = cfg_getn(cfg#, "Position", "y", 100)
w = cfg_getn(cfg#, "Position", "width", 800)
h = cfg_getn(cfg#, "Position", "height", 600)
maximized = cfg_getb(cfg#, "Position", "maximized", 0)

println "Window position: "; x; ", "; y
println "Window size: "; w; " x "; h
println "Maximized: "; maximized
println ""

' Simulate window movement
x = x + 50
y = y + 30

' Save new position
cfg_setn#(cfg#, "Position", "x", x)
cfg_setn#(cfg#, "Position", "y", y)
cfg_setn#(cfg#, "Position", "width", w)
cfg_setn#(cfg#, "Position", "height", h)
cfg_setb#(cfg#, "Position", "maximized", maximized)
cfg_save(cfg#)
println "Position saved!"
```

---

### Example 4: Recent Files List

```basic
' Manage a list of recently opened files
println "=== Recent Files Manager ==="
println ""

cfg# = cfg_open#("recent")

' Display current recent files
println "Current recent files:"
for i = 1 to 5
    key$ = "file" + stri$(i, 0)
    if cfg_exists(cfg#, "Recent", key$) = 1 then
        file$ = cfg_get$(cfg#, "Recent", key$, "")
        println "  "; i; ". "; file$
    endif
next
println ""

' Add a new recent file (shift others down)
newFile$ = "C:\\Documents\\report_2025.txt"
println "Adding: "; newFile$

' Shift existing files
for i = 4 to 1 step -1
    keyFrom$ = "file" + stri$(i, 0)
    keyTo$ = "file" + stri$(i + 1, 0)
    if cfg_exists(cfg#, "Recent", keyFrom$) = 1 then
        file$ = cfg_get$(cfg#, "Recent", keyFrom$, "")
        cfg_set#(cfg#, "Recent", keyTo$, file$)
    endif
next

' Add new file at position 1
cfg_set#(cfg#, "Recent", "file1", newFile$)
cfg_save(cfg#)

println ""
println "Updated recent files:"
for i = 1 to 5
    key$ = "file" + stri$(i, 0)
    if cfg_exists(cfg#, "Recent", key$) = 1 then
        file$ = cfg_get$(cfg#, "Recent", key$, "")
        println "  "; i; ". "; file$
    endif
next
```

---

### Example 5: Multi-User Profiles

```basic
' User profile management with sections
println "=== User Profile System ==="
println ""

cfg# = cfg_open#("profiles")

' List existing profiles
println "Existing profiles:"
sectionsStr$ = cfg_sections$(cfg#)
if sectionsStr$ <> "" then
    println "  "; sectionsStr$
else
    println "  (none)"
endif
println ""

' Create or update a profile
profileName$ = "Player1"
println "Setting up profile: "; profileName$

cfg_set#(cfg#, profileName$, "displayName", "John Doe")
cfg_setn#(cfg#, profileName$, "highScore", 25000)
cfg_setn#(cfg#, profileName$, "gamesPlayed", 42)
cfg_setb#(cfg#, profileName$, "soundEnabled", 1)
cfg_set#(cfg#, profileName$, "favoriteColor", "blue")

' Save
cfg_save(cfg#)

' Display profile
println ""
println "Profile '"; profileName$; "':"
println "  Display Name: "; cfg_get$(cfg#, profileName$, "displayName", "Unknown")
println "  High Score: "; cfg_getn(cfg#, profileName$, "highScore", 0)
println "  Games Played: "; cfg_getn(cfg#, profileName$, "gamesPlayed", 0)
println "  Sound: "; cfg_getb(cfg#, profileName$, "soundEnabled", 1)
println "  Favorite Color: "; cfg_get$(cfg#, profileName$, "favoriteColor", "none")
```

---

### Example 6: Configuration Dump Utility

```basic
'Clear the output area
cls
' Dump all configuration data
println "=== Configuration Dump ==="
println ""

cfg# = cfg_open#("settings")

' Add some test data if empty
if cfg_sectioncount(cfg#) = 0 then
    cfg_sets#(cfg#, "appName", "TestApp")
    cfg_setns#(cfg#, "version", 1.5)
    cfg_set#(cfg#, "Database", "host", "localhost")
    cfg_setn#(cfg#, "Database", "port", 5432)
    cfg_set#(cfg#, "Database", "name", "mydb")
    cfg_save(cfg#)
endif

println "File: "; cfg_filename$(cfg#)
println "Sections: "; cfg_sectioncount(cfg#)
println "Modified: "; cfg_modified(cfg#)
println ""
println "Sections list: "; cfg_sections$(cfg#)
```

---

## Quick Reference

### Config File Creation
```basic
cfg_open#(filename$)           ' Open with manual save
cfg_open_auto#(filename$)      ' Open with auto-save
```

### String Operations
```basic
cfg_set#(cfg#, section$, key$, value$)    ' Set string (with section)
cfg_get$(cfg#, section$, key$, default$)  ' Get string (with section)
cfg_sets#(cfg#, key$, value$)             ' Set string (default section)
cfg_gets$(cfg#, key$, default$)           ' Get string (default section)
```

### Numeric Operations
```basic
cfg_setn#(cfg#, section$, key$, value)    ' Set number (with section)
cfg_getn(cfg#, section$, key$, default)   ' Get number (with section)
cfg_setns#(cfg#, key$, value)             ' Set number (default section)
cfg_getns(cfg#, key$, default)            ' Get number (default section)
```

### Boolean Operations
```basic
cfg_setb#(cfg#, section$, key$, value)    ' Set boolean (with section)
cfg_getb(cfg#, section$, key$, default)   ' Get boolean (with section)
cfg_setbs#(cfg#, key$, value)             ' Set boolean (default section)
cfg_getbs(cfg#, key$, default)            ' Get boolean (default section)
```

### Key/Section Query
```basic
cfg_exists(cfg#, section$, key$)          ' Check key exists (with section)
cfg_haskey(cfg#, key$)                    ' Check key exists (default section)
cfg_section_exists(cfg#, section$)        ' Check section exists
```

### Key/Section Management
```basic
cfg_delete#(cfg#, section$, key$)         ' Delete key (with section)
cfg_deletekey#(cfg#, key$)                ' Delete key (default section)
cfg_section_delete#(cfg#, section$)       ' Delete entire section
cfg_clear#(cfg#)                          ' Clear all data
```

### Enumeration
```basic
cfg_sections$(cfg#)                       ' List all sections
cfg_keys$(cfg#, section$)                 ' List keys in section
cfg_sectioncount(cfg#)                    ' Count sections
cfg_keycount(cfg#, section$)              ' Count keys in section
```

### File Operations
```basic
cfg_save(cfg#)                            ' Save to disk
cfg_reload#(cfg#)                         ' Reload from disk
cfg_filename$(cfg#)                       ' Get file path
cfg_modified(cfg#)                        ' Check for unsaved changes
cfg_autosave#(cfg#, enabled)              ' Set auto-save mode
```

### Utility
```basic
cfg_path$()                               ' Get config directory path
```

---

### All Registered Functions (Alphabetical)

| Function | Signature | Description |
|----------|-----------|-------------|
| `cfg_autosave#` | `cfg_autosave#@#n` | Enable/disable auto-save |
| `cfg_clear#` | `cfg_clear#@#` | Clear all sections and keys |
| `cfg_delete#` | `cfg_delete#@#$$` | Delete key from section |
| `cfg_deletekey#` | `cfg_deletekey#@#$` | Delete key from default section |
| `cfg_exists` | `cfg_exists@#$$` | Check if key exists in section |
| `cfg_filename$` | `cfg_filename$@#` | Get config file path |
| `cfg_get$` | `cfg_get$@#$$$` | Get string from section |
| `cfg_getb` | `cfg_getb@#$$n` | Get boolean from section |
| `cfg_getbs` | `cfg_getbs@#$n` | Get boolean from default section |
| `cfg_getn` | `cfg_getn@#$$n` | Get number from section |
| `cfg_getns` | `cfg_getns@#$n` | Get number from default section |
| `cfg_gets$` | `cfg_gets$@#$$` | Get string from default section |
| `cfg_haskey` | `cfg_haskey@#$` | Check if key exists in default section |
| `cfg_keycount` | `cfg_keycount@#$` | Count keys in section |
| `cfg_keys$` | `cfg_keys$@#$` | List keys in section |
| `cfg_modified` | `cfg_modified@#` | Check for unsaved changes |
| `cfg_open#` | `cfg_open#@$` | Open config file (manual save) |
| `cfg_open_auto#` | `cfg_open_auto#@$` | Open config file (auto-save) |
| `cfg_path$` | `cfg_path$@` | Get config directory path |
| `cfg_reload#` | `cfg_reload#@#` | Reload from disk |
| `cfg_save` | `cfg_save@#` | Save to disk |
| `cfg_section_delete#` | `cfg_section_delete#@#$` | Delete entire section |
| `cfg_section_exists` | `cfg_section_exists@#$` | Check if section exists |
| `cfg_sectioncount` | `cfg_sectioncount@#` | Count sections |
| `cfg_sections$` | `cfg_sections$@#` | List all sections |
| `cfg_set#` | `cfg_set#@#$$$` | Set string in section |
| `cfg_setb#` | `cfg_setb#@#$$n` | Set boolean in section |
| `cfg_setbs#` | `cfg_setbs#@#$n` | Set boolean in default section |
| `cfg_setn#` | `cfg_setn#@#$$n` | Set number in section |
| `cfg_setns#` | `cfg_setns#@#$n` | Set number in default section |
| `cfg_sets#` | `cfg_sets#@#$$` | Set string in default section |

---

## Notes and Best Practices

### When to Use Auto-Save

**Use auto-save (`cfg_open_auto#`) for:**
- Critical settings that must not be lost
- Simple applications with few settings
- Settings that change infrequently

**Use manual save (`cfg_open#`) for:**
- Applications with many rapid setting changes
- When you want to implement "Save" and "Cancel" buttons
- Batch updates to multiple settings

### Default Section Usage

For simple applications, you can use the default section functions (`cfg_sets#`, `cfg_gets$`, etc.) to avoid specifying section names:

```basic
' Simple approach - default section only
cfg# = cfg_open#("myapp")
cfg_sets#(cfg#, "theme", "dark")
cfg_setns#(cfg#, "volume", 75)
cfg_save(cfg#)
```

### Organizing with Sections

For complex applications, organize related settings into sections:

```basic
' Organized approach - multiple sections
cfg# = cfg_open#("myapp")

' User preferences
cfg_set#(cfg#, "User", "name", "John")
cfg_set#(cfg#, "User", "email", "john@example.com")

' Window settings
cfg_setn#(cfg#, "Window", "width", 1024)
cfg_setn#(cfg#, "Window", "height", 768)

' Audio settings
cfg_setn#(cfg#, "Audio", "volume", 75)
cfg_setb#(cfg#, "Audio", "muted", 0)

cfg_save(cfg#)
```

### Error Handling

Always provide sensible defaults when reading values:

```basic
' Good - provides defaults
volume = cfg_getns(cfg#, "volume", 100)
theme$ = cfg_gets$(cfg#, "theme", "light")

' Check save success
if cfg_save(cfg#) = 0 then
    println "Warning: Could not save settings"
endif
```

### Memory Management

Configuration objects are automatically managed by the garbage collector. You don't need to manually close or free config files - they will be cleaned up automatically and any unsaved changes will be saved when the object is destroyed.

---

*End of ConfigLib Documentation*
