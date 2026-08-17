# StrListLib - String List Library

## Overview

StrListLib provides a wrapper around Delphi's `TStringList` class for Plan9Basic, enabling programs to work with dynamic string collections, file I/O, key-value pairs, sorted lists, and event-driven programming.

**Version:** 1.2.0  
**Function Count:** 55 functions

## Key Features

- **Dynamic String Collections** - Add, insert, delete, and manipulate strings
- **File I/O** - Load and save with encoding support (UTF-8 default)
- **Key-Value Pairs** - INI-style `Name=Value` support
- **Sorted Lists** - Automatic sorting with duplicate handling
- **Delimited Text** - CSV and custom delimiter parsing
- **Event Handling** - OnChange/OnChanging callbacks to BASIC functions
- **Batch Updates** - BeginUpdate/EndUpdate for performance optimization

## Registration

Unlike other Plan9Basic libraries, StrListLib requires engine and output references for event callback support:

```pascal
// In your Delphi host application
StrListLib.RegisterStringsFuncs(FBasic.Functions, FBasic, MemoOutput.Lines);
```

## Quick Start

### Creating and Using a String List

```basic
' Create a string list
sl# = strings#()

' Add items
strings_add(sl#, "Apple")
strings_add(sl#, "Banana")
strings_add(sl#, "Cherry")

' Get count
println "Items: "; strings_count(sl#)

' Access by index (0-based)
println "First: "; strings_strings$(sl#, 0)

' Find an item
idx = strings_indexof(sl#, "Banana")
if idx >= 0 then
    println "Banana found at index: "; idx
endif

' Free when done
strings_free(sl#)
```

### Loading and Saving Files

```basic
sl# = strings#()

' Load a text file (UTF-8 by default)
strings_load(sl#, "data.txt")

' Process lines
for i = 0 to strings_count(sl#) - 1
    println strings_strings$(sl#, i)
next

' Save to file
strings_save(sl#, "output.txt")

' With explicit encoding
strings_loadfromfile(sl#, "legacy.txt", "ansi")
strings_savetofile(sl#, "unicode.txt", "utf-16")

strings_free(sl#)
```

### Working with Key-Value Pairs

```basic
sl# = strings#()

' Add key-value pairs
strings_add(sl#, "name=John Doe")
strings_add(sl#, "age=30")
strings_add(sl#, "city=New York")

' Get value by key
println "Name: "; strings_values$(sl#, "name")
println "Age: "; strings_values$(sl#, "age")

' Set value by key
strings_values(sl#, "age", "31")

' Find index by key name
idx = strings_indexofname(sl#, "city")
if idx >= 0 then
    println "City key at index: "; idx
    println "City value: "; strings_valuefromindex$(sl#, idx)
endif

strings_free(sl#)
```

### Parsing CSV Data

```basic
sl# = strings#()

' Configure for CSV parsing
strings_delimiter(sl#, ",")
strings_strictdelimiter(sl#, 1)
strings_quotechar(sl#, "\"")

' Parse a CSV line
strings_delimitedtext(sl#, "John,Doe,30,\"New York, NY\"")

' Access fields
println "First name: "; strings_strings$(sl#, 0)
println "Last name: "; strings_strings$(sl#, 1)
println "Age: "; strings_strings$(sl#, 2)
println "City: "; strings_strings$(sl#, 3)

strings_free(sl#)
```

### Sorted Lists with Duplicate Handling

```basic
sl# = strings#()

' Enable sorting
strings_sorted(sl#, 1)

' Set duplicate handling: "ignore", "accept", or "error"
strings_duplicates(sl#, "ignore")

' Add items (automatically sorted, duplicates ignored)
strings_add(sl#, "Banana")
strings_add(sl#, "Apple")
strings_add(sl#, "Cherry")
strings_add(sl#, "Apple")  ' Ignored (duplicate)

' Binary search (fast for sorted lists)
idx = strings_find(sl#, "Cherry")
println "Cherry at index: "; idx

' Print sorted list
for i = 0 to strings_count(sl#) - 1
    println strings_strings$(sl#, i)
next

strings_free(sl#)
```

### Event-Driven Programming

```basic
' Define callback function (must return pointer, take pointer parameter)
function on_list_change#(sender#)
    println "List changed! Count: "; strings_count(sender#)
    return sender#
endfunction

function on_list_changing#(sender#)
    println "List is about to change..."
    return sender#
endfunction

' Create list and attach events
sl# = strings#()
strings_onchange(sl#, "on_list_change")
strings_onchanging(sl#, "on_list_changing")

' These operations trigger the callbacks
strings_add(sl#, "First")   ' Triggers: changing, then changed
strings_add(sl#, "Second")  ' Triggers: changing, then changed
strings_clear(sl#)          ' Triggers: changing, then changed

' Remove event handler
strings_onchange(sl#, "")

strings_free(sl#)
```

### Batch Updates for Performance

```basic
sl# = strings#()
strings_onchange(sl#, "on_change")

' Without batch update: triggers event for each add
strings_add(sl#, "Item 1")  ' Event fires
strings_add(sl#, "Item 2")  ' Event fires
strings_add(sl#, "Item 3")  ' Event fires

' With batch update: single event at the end
strings_beginupdate(sl#)
for i = 1 to 1000
    strings_add(sl#, "Item " + str$(i))
next
strings_endupdate(sl#)  ' Single event fires here

strings_free(sl#)
```

---

## Function Reference

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `strings#()` | Create a new string list, returns pointer |
| `strings_free(sl#)` | Free a string list |

### Properties - Text Content

| Function | Description |
|----------|-------------|
| `strings_text(sl#, s$)` | Set entire text content |
| `strings_text$(sl#)` | Get entire text content |
| `strings_commatext(sl#, s$)` | Set comma-separated text |
| `strings_commatext$(sl#)` | Get comma-separated text |
| `strings_delimitedtext(sl#, s$)` | Set delimited text |
| `strings_delimitedtext$(sl#)` | Get delimited text |

### Properties - Item Access

| Function | Description |
|----------|-------------|
| `strings_strings(sl#, index, s$)` | Set string at index |
| `strings_strings$(sl#, index)` | Get string at index |
| `strings_count(sl#)` | Get number of items |
| `strings_capacity(sl#, n)` | Set capacity |
| `strings_capacity(sl#)` | Get capacity |

### Properties - Delimiters and Formatting

| Function | Description |
|----------|-------------|
| `strings_delimiter(sl#, c$)` | Set delimiter character |
| `strings_delimiter$(sl#)` | Get delimiter character |
| `strings_quotechar(sl#, c$)` | Set quote character |
| `strings_quotechar$(sl#)` | Get quote character |
| `strings_strictdelimiter(sl#, n)` | Set strict delimiter mode (0/1) |
| `strings_strictdelimiter(sl#)` | Get strict delimiter mode |
| `strings_linebreak(sl#, s$)` | Set line break string |
| `strings_linebreak$(sl#)` | Get line break string |
| `strings_trailinglinebreak(sl#, n)` | Set trailing line break (0/1) |
| `strings_trailinglinebreak(sl#)` | Get trailing line break setting |

### Properties - Name=Value Pairs

| Function | Description |
|----------|-------------|
| `strings_values(sl#, key$, value$)` | Set value by key name |
| `strings_values$(sl#, key$)` | Get value by key name |
| `strings_names$(sl#, index)` | Get name part at index |
| `strings_keynames$(sl#, index)` | Get key name at index |
| `strings_valuefromindex(sl#, index, s$)` | Set value at index |
| `strings_valuefromindex$(sl#, index)` | Get value at index |
| `strings_namevalueseparator(sl#, c$)` | Set separator (default "=") |
| `strings_namevalueseparator$(sl#)` | Get separator character |

### Properties - Sorting and Duplicates

| Function | Description |
|----------|-------------|
| `strings_sorted(sl#, n)` | Enable/disable sorting (0/1) |
| `strings_sorted(sl#)` | Get sorted mode |
| `strings_duplicates(sl#, mode$)` | Set mode: "ignore", "accept", "error" |
| `strings_duplicates$(sl#)` | Get duplicate mode |
| `strings_casesensitive(sl#, n)` | Set case sensitivity (0/1) |
| `strings_casesensitive(sl#)` | Get case sensitivity |

### Properties - Encoding

| Function | Description |
|----------|-------------|
| `strings_defaultencoding(sl#, enc$)` | Set default encoding |
| `strings_defaultencoding$(sl#)` | Get default encoding |
| `strings_encoding$(sl#)` | Get current encoding (read-only) |
| `strings_writebom(sl#, n)` | Set write BOM flag (0/1) |
| `strings_writebom(sl#)` | Get write BOM flag |

**Supported Encodings:** `utf-8`, `utf-7`, `utf-16`, `utf-16le`, `utf-16be`, `ansi`, `ascii`

### Methods - Adding and Removing

| Function | Description | Returns |
|----------|-------------|---------|
| `strings_add(sl#, s$)` | Add string to end | Index of added item |
| `strings_append(sl#, s$)` | Append string | New count |
| `strings_insert(sl#, index, s$)` | Insert at index | New count |
| `strings_delete(sl#, index)` | Delete at index | New count |
| `strings_clear(sl#)` | Remove all items | 1 |

### Methods - Searching

| Function | Description | Returns |
|----------|-------------|---------|
| `strings_indexof(sl#, s$)` | Find string | Index or -1 |
| `strings_find(sl#, s$)` | Binary search (sorted only) | Index or -1 |
| `strings_indexofname(sl#, name$)` | Find by key name | Index or -1 |

### Methods - Manipulation

| Function | Description |
|----------|-------------|
| `strings_exchange(sl#, idx1, idx2)` | Swap two items |
| `strings_move(sl#, curIdx, newIdx)` | Move item to new position |
| `strings_sort(sl#)` | Sort the list |
| `strings_equals(sl1#, sl2#)` | Compare two lists (returns 0/1) |

### Methods - Batch Updates

| Function | Description |
|----------|-------------|
| `strings_beginupdate(sl#)` | Begin batch update (suppress events) |
| `strings_endupdate(sl#)` | End batch update (fire single event) |

### Methods - File I/O

| Function | Description | Returns |
|----------|-------------|---------|
| `strings_load(sl#, filename$)` | Load file (UTF-8) | Line count |
| `strings_save(sl#, filename$)` | Save file (UTF-8) | Line count |
| `strings_loadfromfile(sl#, filename$, encoding$)` | Load with encoding | Line count |
| `strings_savetofile(sl#, filename$, encoding$)` | Save with encoding | Line count |

### Methods - Stream I/O

| Function | Description | Returns |
|----------|-------------|---------|
| `strings_loadfromstream(sl#, stream#, encoding$)` | Load from stream | Line count |
| `strings_savetostream(sl#, stream#, encoding$)` | Save to stream | Line count |

### Events

| Function | Description |
|----------|-------------|
| `strings_onchange(sl#, funcname$)` | Set OnChange handler |
| `strings_onchange$(sl#)` | Get OnChange handler name |
| `strings_onchanging(sl#, funcname$)` | Set OnChanging handler |
| `strings_onchanging$(sl#)` | Get OnChanging handler name |

**Event Handler Signature:**
```basic
function handler#(sender#)
    ' sender# is the string list that triggered the event
    return sender#
endfunction
```

---

## Event Handling Architecture

StrListLib demonstrates the **Host to BASIC Callback** pattern:

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  Host Event     │───►│  Bridge Method   │───►│  BASIC Function │
│  (OnChange)     │    │  (InternalOn...) │    │  (User-defined) │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

1. **Host Event** - Native host OnChange fires
2. **Bridge Method** - InternalOnChange receives the event
3. **ExecuteCallback** - Calls ExecuteUserFunction with the function signature
4. **BASIC Function** - User-defined function executes

This pattern is reusable for:
- GUI control events (buttons, forms, etc.)
- Timer events
- Network callbacks
- File system notifications

---

## Practical Examples

### Example 1: Configuration File Handler

```basic
' Simple INI-like configuration handler

function config_load#(filename$) local cfg#
    cfg# = strings#()
    strings_namevalueseparator(cfg#, "=")
    
    ' Try to load, exception if file do not exists
    strings_load(cfg#, filename$)
    
    return cfg#
endfunction

function config_get$(cfg#, key$, default$) local value$
    value$ = strings_values$(cfg#, key$)
    if value$ = "" then
        return default$
    endif
    return value$
endfunction

function config_set#(cfg#, key$, value$)
    strings_values(cfg#, key$, value$)
    return cfg#
endfunction

function config_save#(cfg#, filename$)
    strings_save(cfg#, filename$)
    return cfg#
endfunction

' Usage
cfg# = config_load#("settings.ini")
theme$ = config_get$(cfg#, "theme", "dark")
config_set#(cfg#, "last_run", date$())
config_save#(cfg#, "settings.ini")
strings_free(cfg#)
```

### Example 2: CSV Parser

```basic
function parse_csv#(line$) local fields#
    fields# = strings#()
    strings_delimiter(fields#, ",")
    strings_strictdelimiter(fields#, 1)
    strings_quotechar(fields#, "\"")
    strings_delimitedtext(fields#, line$)
    return fields#
endfunction

function csv_get$(fields#, index)
    if index < 0 or index >= strings_count(fields#) then
        return ""
    endif
    return strings_strings$(fields#, index)
endfunction

' Usage
row# = parse_csv#("John,Doe,30,\"San Francisco, CA\"")
println "Name: "; csv_get$(row#, 0); " "; csv_get$(row#, 1)
println "Age: "; csv_get$(row#, 2)
println "City: "; csv_get$(row#, 3)
strings_free(row#)
```

### Example 3: Unique Sorted Collection

```basic
' Create a collection that maintains unique, sorted items

function unique_collection#() local coll#
    coll# = strings#()
    strings_sorted(coll#, 1)
    strings_duplicates(coll#, "ignore")
    return coll#
endfunction

function collection_add#(coll#, item$)
    strings_add(coll#, item$)
    return coll#
endfunction

function collection_contains(coll#, item$)
    if strings_find(coll#, item$) >= 0 then
        return 1
    else
        return 0
    end if
end function

function collection_print#(coll#) local i
    for i = 0 to strings_count(coll#) - 1
        println strings_strings$(coll#, i)
    next
    return coll#
endfunction

' Usage
tags# = unique_collection#()
collection_add#(tags#, "programming")
collection_add#(tags#, "basic")
collection_add#(tags#, "programming")  ' Ignored (duplicate)
collection_add#(tags#, "delphi")

if collection_contains(tags#, "basic") = 1 then
    println "Has 'basic' tag"
endif

collection_print#(tags#)
strings_free(tags#)
```

### Example 4: Change Tracker with Events

```basic
' Track all changes to a string list

changeLog$ = ""

function track_change#(sender#)
    changeLog$ = changeLog$ + "Changed: " + str$(strings_count(sender#)) + " items\n"
    return sender#
endfunction

' Setup
sl# = strings#()
strings_onchange(sl#, "track_change")

' Operations
strings_add(sl#, "First")
strings_add(sl#, "Second")
strings_delete(sl#, 0)
strings_clear(sl#)

' Show log
println "Change History:"
println changeLog$

strings_free(sl#)
```

---

## Error Handling

All functions validate their inputs and raise descriptive exceptions:

| Error | Description |
|-------|-------------|
| `Undefined or nil string list` | Pointer is nil |
| `Index out of bounds: N (count: M)` | Index N is invalid for a list with M items |
| `Empty string provided where character expected` | Delimiter/quote char is empty |
| `Invalid callback function name: X` | Function name is not a valid identifier |

---

## Comparison with StrLib

| Feature | StrLib | StrListLib |
|---------|--------|------------|
| Purpose | String manipulation | String collections |
| Data Type | Single string | List of strings |
| File I/O | No | Yes |
| Sorting | No | Yes |
| Events | No | Yes |
| Key-Value | No | Yes |

**When to use StrListLib:**
- Managing collections of strings
- Reading/writing text files
- Parsing CSV or delimited data
- Configuration files (INI-style)
- Maintaining sorted, unique lists
- Event-driven list monitoring

**When to use StrLib:**
- String manipulation (trim, case, split, join)
- Character-level operations
- Pattern matching
- String formatting

---

## Version History

### Version 1.2.0
- Removed unnecessary `name` parameter from constructor
- Fixed 64-bit pointer compatibility (Integer → NativeInt)
- Added bounds checking for all index-based operations
- Added empty string validation for character properties
- Refactored encoding parsing into helper functions
- Added `strings_load` and `strings_save` with UTF-8 default
- Added function signature validation for events
- Improved error messages with operation context
- Updated callback signature to `functionname#@#`

### Version 1.1.0
- Initial public release
- 57 functions wrapping TStringList

---

## See Also

- **StrLib** - String manipulation functions
- **ArrayLib** - Numeric and pointer arrays
- **DictLib** - Dictionary/hash map operations
- **ConfigLib** - INI file configuration handling
