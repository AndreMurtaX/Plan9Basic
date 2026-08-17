# ConfigLib - Cross-Platform Configuration Library

## Overview

ConfigLib provides persistent key/value storage for Plan9Basic applications using INI files. It works identically across all platforms (Windows, Linux, macOS, Android, iOS), making it ideal for storing user preferences, application settings, high scores, and other persistent data.

## Key Features

- **Cross-platform**: Same API works on all platforms
- **Section support**: Organize settings into logical groups
- **Multiple data types**: String, numeric, and boolean values
- **Auto-save option**: Automatic or manual save control
- **Default values**: Safe retrieval with fallback defaults
- **Multiple config files**: Open as many config files as needed

## Platform Storage Locations

| Platform | Config Directory |
|----------|-----------------|
| Windows | `Documents\Plan9Basic\Config\` |
| Linux | `~/.config/Plan9Basic/` |
| macOS | `~/Library/Application Support/Plan9Basic/` |
| Android | App Documents/Config/ |
| iOS | App Documents/Config/ |

---

## Function Reference

### Config File Creation

| Function | Description |
|----------|-------------|
| `cfg_open#(filename$)` | Open/create config file (manual save) |
| `cfg_open_auto#(filename$)` | Open/create config file (auto-save) |

### String Operations

| Function | Description |
|----------|-------------|
| `cfg_set#(cfg#, section$, key$, value$)` | Set string value in section |
| `cfg_get$(cfg#, section$, key$, default$)` | Get string value from section |
| `cfg_sets#(cfg#, key$, value$)` | Set string in default section |
| `cfg_gets$(cfg#, key$, default$)` | Get string from default section |

### Numeric Operations

| Function | Description |
|----------|-------------|
| `cfg_setn#(cfg#, section$, key$, value)` | Set numeric value in section |
| `cfg_getn(cfg#, section$, key$, default)` | Get numeric value from section |
| `cfg_setns#(cfg#, key$, value)` | Set numeric in default section |
| `cfg_getns(cfg#, key$, default)` | Get numeric from default section |

### Boolean Operations

| Function | Description |
|----------|-------------|
| `cfg_setb#(cfg#, section$, key$, value)` | Set boolean value in section |
| `cfg_getb(cfg#, section$, key$, default)` | Get boolean value from section |
| `cfg_setbs#(cfg#, key$, value)` | Set boolean in default section |
| `cfg_getbs(cfg#, key$, default)` | Get boolean from default section |

### Key/Section Query

| Function | Description |
|----------|-------------|
| `cfg_exists(cfg#, section$, key$)` | Check if key exists in section |
| `cfg_haskey(cfg#, key$)` | Check if key exists in default section |
| `cfg_section_exists(cfg#, section$)` | Check if section exists |

### Key/Section Management

| Function | Description |
|----------|-------------|
| `cfg_delete#(cfg#, section$, key$)` | Delete key from section |
| `cfg_deletekey#(cfg#, key$)` | Delete key from default section |
| `cfg_section_delete#(cfg#, section$)` | Delete entire section |
| `cfg_clear#(cfg#)` | Clear all data |

### Enumeration

| Function | Description |
|----------|-------------|
| `cfg_sections$(cfg#)` | Get all section names (newline separated) |
| `cfg_keys$(cfg#, section$)` | Get all keys in section (newline separated) |
| `cfg_keycount(cfg#, section$)` | Count keys in section |
| `cfg_sectioncount(cfg#)` | Count sections |

### File Operations

| Function | Description |
|----------|-------------|
| `cfg_save(cfg#)` | Save changes to disk (returns 1=success, 0=fail) |
| `cfg_reload#(cfg#)` | Reload from disk, discarding changes |
| `cfg_filename$(cfg#)` | Get full file path |
| `cfg_modified(cfg#)` | Check for unsaved changes (1=yes, 0=no) |
| `cfg_autosave#(cfg#, enabled)` | Enable/disable auto-save |

### Utility

| Function | Description |
|----------|-------------|
| `cfg_path$()` | Get config directory path |

---

## Detailed Function Reference

### cfg_open#(filename$)

Opens or creates a configuration file with manual save mode.

**Syntax:**
```basic
config# = cfg_open#(filename$)
```

**Parameters:**
- `filename$` - Config file name (with or without path)

**Returns:** Pointer to config object

**Notes:**
- If filename has no path, file is created in config directory
- If filename has no extension, `.ini` is added automatically
- Changes are NOT saved until `cfg_save()` is called

**Example:**
```basic
cfg# = cfg_open#("myapp")        ' Creates myapp.ini in config dir
cfg# = cfg_open#("settings.cfg") ' Creates settings.cfg in config dir
cfg# = cfg_open#("C:\data\app.ini") ' Uses exact path (Windows)
```

---

### cfg_open_auto#(filename$)

Opens or creates a configuration file with auto-save enabled.

**Syntax:**
```basic
config# = cfg_open_auto#(filename$)
```

**Notes:**
- Every change is automatically saved to disk
- Convenient but may be slower for many rapid changes

---

### cfg_set# / cfg_get$

Set and get string values with section support.

**Syntax:**
```basic
cfg_set#(cfg#, section$, key$, value$)
result$ = cfg_get$(cfg#, section$, key$, default$)
```

**Parameters:**
- `cfg#` - Config object pointer
- `section$` - Section name (use "" for default "General" section)
- `key$` - Key name
- `value$` - Value to set
- `default$` - Default value if key doesn't exist

**Example:**
```basic
cfg# = cfg_open#("game")

' Set values in different sections
cfg_set#(cfg#, "Player", "name", "John")
cfg_set#(cfg#, "Player", "class", "Warrior")
cfg_set#(cfg#, "Graphics", "resolution", "1920x1080")

' Get values
name$ = cfg_get$(cfg#, "Player", "name", "Unknown")
res$ = cfg_get$(cfg#, "Graphics", "resolution", "1024x768")

cfg_save(cfg#)
```

---

### cfg_sets# / cfg_gets$

Simplified string operations using default section.

**Syntax:**
```basic
cfg_sets#(cfg#, key$, value$)
result$ = cfg_gets$(cfg#, key$, default$)
```

**Example:**
```basic
cfg# = cfg_open#("prefs")

cfg_sets#(cfg#, "username", "player1")
cfg_sets#(cfg#, "language", "en")

user$ = cfg_gets$(cfg#, "username", "guest")
lang$ = cfg_gets$(cfg#, "language", "en")

cfg_save(cfg#)
```

---

### cfg_setn# / cfg_getn

Set and get numeric values with section support.

**Syntax:**
```basic
cfg_setn#(cfg#, section$, key$, value)
result = cfg_getn(cfg#, section$, key$, default)
```

**Example:**
```basic
cfg# = cfg_open#("settings")

cfg_setn#(cfg#, "Audio", "volume", 75)
cfg_setn#(cfg#, "Audio", "bass", 50)
cfg_setn#(cfg#, "Window", "width", 800)
cfg_setn#(cfg#, "Window", "height", 600)

vol = cfg_getn(cfg#, "Audio", "volume", 100)
width = cfg_getn(cfg#, "Window", "width", 640)

cfg_save(cfg#)
```

---

### cfg_setns# / cfg_getns

Simplified numeric operations using default section.

**Syntax:**
```basic
cfg_setns#(cfg#, key$, value)
result = cfg_getns(cfg#, key$, default)
```

**Example:**
```basic
cfg# = cfg_open#("game")

cfg_setns#(cfg#, "highscore", 15000)
cfg_setns#(cfg#, "level", 5)

score = cfg_getns(cfg#, "highscore", 0)
level = cfg_getns(cfg#, "level", 1)

cfg_save(cfg#)
```

---

### cfg_setb# / cfg_getb

Set and get boolean values (stored as 0 or 1).

**Syntax:**
```basic
cfg_setb#(cfg#, section$, key$, value)
result = cfg_getb(cfg#, section$, key$, default)
```

**Example:**
```basic
cfg# = cfg_open#("options")

cfg_setb#(cfg#, "Features", "sound", 1)
cfg_setb#(cfg#, "Features", "music", 1)
cfg_setb#(cfg#, "Features", "fullscreen", 0)

if cfg_getb(cfg#, "Features", "sound", 1) = 1 then
    println "Sound is enabled"
endif

cfg_save(cfg#)
```

---

### cfg_setbs# / cfg_getbs

Simplified boolean operations using default section.

**Syntax:**
```basic
cfg_setbs#(cfg#, key$, value)
result = cfg_getbs(cfg#, key$, default)
```

---

### cfg_exists / cfg_haskey / cfg_section_exists

Check if keys or sections exist.

**Syntax:**
```basic
result = cfg_exists(cfg#, section$, key$)
result = cfg_haskey(cfg#, key$)
result = cfg_section_exists(cfg#, section$)
```

**Returns:** 1 if exists, 0 if not

**Example:**
```basic
cfg# = cfg_open#("app")

if cfg_haskey(cfg#, "username") = 1 then
    user$ = cfg_gets$(cfg#, "username", "")
else
    println "Please enter username:"
    ' ... get input ...
endif

if cfg_section_exists(cfg#, "Advanced") = 1 then
    ' Load advanced settings
endif
```

---

### cfg_delete# / cfg_deletekey# / cfg_section_delete#

Delete keys or sections.

**Syntax:**
```basic
cfg_delete#(cfg#, section$, key$)
cfg_deletekey#(cfg#, key$)
cfg_section_delete#(cfg#, section$)
```

**Example:**
```basic
cfg# = cfg_open#("temp")

' Delete single key
cfg_deletekey#(cfg#, "tempvalue")

' Delete key from specific section
cfg_delete#(cfg#, "Cache", "lastfile")

' Delete entire section
cfg_section_delete#(cfg#, "TempData")

cfg_save(cfg#)
```

---

### cfg_sections$ / cfg_keys$

Get section and key names for enumeration.

**Syntax:**
```basic
sections$ = cfg_sections$(cfg#)
keys$ = cfg_keys$(cfg#, section$)
```

**Returns:** Names separated by newlines (use line$() to parse)

**Example:**
```basic
cfg# = cfg_open#("data")

' List all sections
sections$ = cfg_sections$(cfg#)
n = count(sections$)
for i = 0 to n - 1
    println "Section: "; line$(sections$, i)
next

' List all keys in a section
keys$ = cfg_keys$(cfg#, "Settings")
n = count(keys$)
for i = 0 to n - 1
    key$ = line$(keys$, i)
    val$ = cfg_get$(cfg#, "Settings", key$, "")
    println key$; " = "; val$
next
```

---

### cfg_save / cfg_reload#

Control file saving and reloading.

**Syntax:**
```basic
success = cfg_save(cfg#)
cfg_reload#(cfg#)
```

**Example:**
```basic
cfg# = cfg_open#("data")

cfg_sets#(cfg#, "test", "value1")

' Save changes
if cfg_save(cfg#) = 1 then
    println "Saved successfully"
else
    println "Save failed!"
endif

' Discard changes and reload from disk
cfg_reload#(cfg#)
```

---

### cfg_path$()

Get the platform-specific config directory path.

**Syntax:**
```basic
path$ = cfg_path$()
```

**Example:**
```basic
println "Config files are stored in: "; cfg_path$()
' Windows: C:\Users\Name\Documents\Plan9Basic\Config
' Linux:   /home/name/.config/Plan9Basic
' macOS:   /Users/name/Library/Application Support/Plan9Basic
```

---

## Complete Examples

### Example 1: User Preferences

```basic
' Simple user preferences manager

cfg# = cfg_open#("preferences")

' Check if first run
if cfg_haskey(cfg#, "first_run") = 0 then
    println "Welcome! Setting up defaults..."
    cfg_sets#(cfg#, "username", "Player")
    cfg_setns#(cfg#, "volume", 80)
    cfg_setbs#(cfg#, "music", 1)
    cfg_setbs#(cfg#, "first_run", 1)
    cfg_save(cfg#)
endif

' Load preferences
user$ = cfg_gets$(cfg#, "username", "Guest")
vol = cfg_getns(cfg#, "volume", 100)
music = cfg_getbs(cfg#, "music", 1)

println "Hello, "; user$; "!"
println "Volume: "; vol
if music = 1 then
    println "Music: ON"
else
    println "Music: OFF"
end if
```

### Example 2: High Score System

```basic
' High score manager with multiple players

cfg# = cfg_open#("highscores")

' Add some scores
cfg_setn#(cfg#, "Scores", "Alice", 15000)
cfg_setn#(cfg#, "Scores", "Bob", 12500)
cfg_setn#(cfg#, "Scores", "Charlie", 18000)

' Display all scores
println "=== HIGH SCORES ==="
keys$ = cfg_keys$(cfg#, "Scores")
n = count(keys$)
for i = 0 to n - 1
    player$ = line$(keys$, i)
    score = cfg_getn(cfg#, "Scores", player$, 0)
    println player$; ": "; score
next

cfg_save(cfg#)
```

### Example 3: Game Settings with Sections

```basic
' Game settings organized by category

cfg# = cfg_open#("game_settings")

' Graphics settings
cfg_set#(cfg#, "Graphics", "resolution", "1920x1080")
cfg_setb#(cfg#, "Graphics", "fullscreen", 0)
cfg_setb#(cfg#, "Graphics", "vsync", 1)
cfg_setn#(cfg#, "Graphics", "quality", 3)

' Audio settings
cfg_setn#(cfg#, "Audio", "master", 100)
cfg_setn#(cfg#, "Audio", "music", 80)
cfg_setn#(cfg#, "Audio", "sfx", 90)
cfg_setb#(cfg#, "Audio", "mute", 0)

' Controls
cfg_set#(cfg#, "Controls", "jump", "SPACE")
cfg_set#(cfg#, "Controls", "shoot", "CTRL")
cfg_setn#(cfg#, "Controls", "sensitivity", 50)

' Display all settings
println "=== GAME SETTINGS ==="
sections$ = cfg_sections$(cfg#)
sectionCount = count(sections$)

for s = 0 to sectionCount - 1
    section$ = line$(sections$, s)
    println ""
    println "["; section$; "]"
    
    keys$ = cfg_keys$(cfg#, section$)
    keyCount = count(keys$)
    
    for k = 0 to keyCount - 1
        key$ = line$(keys$, k)
        val$ = cfg_get$(cfg#, section$, key$, "")
        println "  "; key$; " = "; val$
    next
next

cfg_save(cfg#)
```

### Example 4: Auto-Save Mode

```basic
' Counter that persists between runs

cfg# = cfg_open_auto#("counter")

' Get current count (default 0 if first run)
count = cfg_getns(cfg#, "value", 0)
println "Previous count: "; count

' Increment
count = count + 1
cfg_setns#(cfg#, "value", count)

println "New count: "; count
println "Changes saved automatically!"

' No need to call cfg_save() - auto-save is enabled
```

### Example 5: Multiple Config Files

```basic
' Using multiple config files for different purposes

' User settings
userCfg# = cfg_open#("user")
cfg_sets#(userCfg#, "name", "John")
cfg_sets#(userCfg#, "email", "john@example.com")

' Application cache
cacheCfg# = cfg_open#("cache")
cfg_sets#(cacheCfg#, "lastFile", "document.txt")
cfg_setns#(cacheCfg#, "windowX", 100)
cfg_setns#(cacheCfg#, "windowY", 200)

' License info
licenseCfg# = cfg_open#("license")
cfg_sets#(licenseCfg#, "key", "XXXX-YYYY-ZZZZ")
cfg_setbs#(licenseCfg#, "activated", 1)

' Save all
cfg_save(userCfg#)
cfg_save(cacheCfg#)
cfg_save(licenseCfg#)

println "All config files saved!"
println "Location: "; cfg_path$()
```
```

---

## INI File Format

ConfigLib creates standard INI files that can be edited with any text editor:

```ini
[General]
username=player1
language=en

[Graphics]
resolution=1920x1080
fullscreen=0
vsync=1

[Audio]
volume=80
music=1
```

---

## Error Handling

All functions validate their inputs and raise descriptive errors:

- Null config pointer → "function_name: Null config pointer"
- Invalid object type → "function_name: Invalid config object"
- Empty filename → "cfg_open#: Filename cannot be empty"

---

## Memory Management

- Config objects are automatically registered with the garbage collector
- Objects are freed when the program ends
- Use multiple configs freely without memory concerns

---

## Function Summary

| Category | Count | Functions |
|----------|-------|-----------|
| Creation | 2 | cfg_open#, cfg_open_auto# |
| String ops | 4 | cfg_set#, cfg_get$, cfg_sets#, cfg_gets$ |
| Numeric ops | 4 | cfg_setn#, cfg_getn, cfg_setns#, cfg_getns |
| Boolean ops | 4 | cfg_setb#, cfg_getb, cfg_setbs#, cfg_getbs |
| Query | 3 | cfg_exists, cfg_haskey, cfg_section_exists |
| Management | 4 | cfg_delete#, cfg_deletekey#, cfg_section_delete#, cfg_clear# |
| Enumeration | 4 | cfg_sections$, cfg_keys$, cfg_keycount, cfg_sectioncount |
| File ops | 5 | cfg_save, cfg_reload#, cfg_filename$, cfg_modified, cfg_autosave# |
| Utility | 1 | cfg_path$ |
| **Total** | **31** | |

---

## Version History

- **1.0** (January 2026) - Initial release
  - Cross-platform INI file support
  - String, numeric, and boolean values
  - Section support
  - Auto-save option
  - Full enumeration support
