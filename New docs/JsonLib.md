# Plan9Basic - JsonLib Documentation

## JSON Library Reference Manual

**Version:** 1.0  
**Date:** January 2026  
**Total Functions:** 50 (with overloads: 57 registered signatures)

---

## Table of Contents

1. [Overview](#overview)
2. [JSON Type System](#json-type-system)
3. [Creation Functions](#creation-functions)
4. [Serialization Functions](#serialization-functions)
5. [Type Checking Functions](#type-checking-functions)
6. [Object Access Functions](#object-access-functions)
7. [Object Modification Functions](#object-modification-functions)
8. [Array Functions](#array-functions)
9. [Path Navigation Functions](#path-navigation-functions)
10. [Utility Functions](#utility-functions)
11. [Complete Examples](#complete-examples)
12. [Quick Reference](#quick-reference)

---

## Overview

The JsonLib library provides comprehensive JSON manipulation functions for Plan9Basic programs. It enables parsing, creating, modifying, and serializing JSON data structures, making it easy to work with web APIs, configuration files, and data interchange formats.

### Key Features

| Feature | Description |
|---------|-------------|
| **Full JSON Support** | Objects, arrays, strings, numbers, booleans, and null |
| **Path Navigation** | Access nested values with dot notation (e.g., `user.profile.name`) |
| **Automatic Memory Management** | All JSON values are tracked by the garbage collector |
| **Type-Safe Access** | Dedicated functions for each value type with optional defaults |
| **Fluent API** | Modification functions return the object for chaining |

### Function Naming Convention

| Suffix | Returns | Example |
|--------|---------|---------|
| `#` | Pointer (JSON value) | `json_object#()` |
| `$` | String | `json_stringify$()` |
| (none) | Number | `json_len()` |

### Memory Management

All JSON values created by JsonLib are automatically tracked by Plan9Basic's garbage collector. You don't need to manually free JSON objects - they will be cleaned up automatically when no longer referenced.

---

## JSON Type System

### Type Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | `JSON_TYPE_NULL` | Null value |
| 1 | `JSON_TYPE_OBJECT` | Object (key-value pairs) |
| 2 | `JSON_TYPE_ARRAY` | Array (ordered list) |
| 3 | `JSON_TYPE_STRING` | String value |
| 4 | `JSON_TYPE_NUMBER` | Numeric value |
| 5 | `JSON_TYPE_BOOLEAN` | Boolean (true/false) |

### Type Names

The `json_typename$()` function returns these strings:
- `"null"`, `"object"`, `"array"`, `"string"`, `"number"`, `"boolean"`

---

## Creation Functions

### json_object#()

Creates an empty JSON object.

**Signature:** `json_object#@`

**Syntax:**
```basic
obj# = json_object#()
```

**Returns:** Pointer to new empty JSON object

**Example:**
```basic
obj# = json_object#()
json_sets#(obj#, "name", "John")
json_setn#(obj#, "age", 30)
println json_stringify$(obj#)    ' Output: {"name":"John","age":30}
```

---

### json_array#()

Creates an empty JSON array.

**Signature:** `json_array#@`

**Syntax:**
```basic
arr# = json_array#()
```

**Returns:** Pointer to new empty JSON array

**Example:**
```basic
arr# = json_array#()
json_pushn#(arr#, 1)
json_pushn#(arr#, 2)
json_pushn#(arr#, 3)
println json_stringify$(arr#)    ' Output: [1,2,3]
```

---

### json_parse#()

Parses a JSON string into a JSON value.

**Signature:** `json_parse#@$`

**Syntax:**
```basic
json# = json_parse#(jsonString$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `jsonString$` | String | Valid JSON text |

**Returns:** Pointer to parsed JSON value, or nil if parsing fails

**Example:**
```basic
json$ = "{\"name\":\"Alice\",\"scores\":[95,87,92]}"
data# = json_parse#(json$)

if isnil(data#) = 1 then
    println "Name: "; json_gets$(data#, "name")
    println "First score: "; json_pathn(data#, "scores[0]")
else
    println "Parse error"
endif
```

---

### json_null#()

Creates a JSON null value.

**Signature:** `json_null#@`

**Syntax:**
```basic
nullVal# = json_null#()
```

**Example:**
```basic
obj# = json_object#()
json_set#(obj#, "data", json_null#())
println json_stringify$(obj#)    ' Output: {"data":null}
```

---

### json_bool#()

Creates a JSON boolean value.

**Signature:** `json_bool#@n`

**Syntax:**
```basic
boolVal# = json_bool#(value)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `value` | Number | 0 = false, non-zero = true |

**Example:**
```basic
trueVal# = json_bool#(1)
falseVal# = json_bool#(0)

obj# = json_object#()
json_set#(obj#, "active", json_bool#(1))
json_set#(obj#, "deleted", json_bool#(0))
println json_stringify$(obj#)    ' Output: {"active":true,"deleted":false}
```

---

### json_number#()

Creates a JSON number value.

**Signature:** `json_number#@n`

**Syntax:**
```basic
numVal# = json_number#(value)
```

**Example:**
```basic
pi# = json_number#(3.14159)
arr# = json_array#()
json_push#(arr#, json_number#(100))
json_push#(arr#, json_number#(200))
```

---

### json_string#()

Creates a JSON string value.

**Signature:** `json_string#@$`

**Syntax:**
```basic
strVal# = json_string#(value$)
```

**Example:**
```basic
name# = json_string#("Plan9Basic")
arr# = json_array#()
json_push#(arr#, json_string#("apple"))
json_push#(arr#, json_string#("banana"))
println json_stringify$(arr#)    ' Output: ["apple","banana"]
```

---

## Serialization Functions

### json_stringify$()

Converts a JSON value to a compact string representation.

**Signature:** `json_stringify$@#`

**Syntax:**
```basic
result$ = json_stringify$(json#)
```

**Returns:** JSON string without extra whitespace

**Example:**
```basic
obj# = json_object#()
json_sets#(obj#, "name", "Test")
json_setn#(obj#, "value", 42)

println json_stringify$(obj#)
' Output: {"name":"Test","value":42}
```

---

### json_pretty$()

Converts a JSON value to a formatted string with indentation.

**Signature:** `json_pretty$@#` or `json_pretty$@#n`

**Syntax:**
```basic
result$ = json_pretty$(json#)
result$ = json_pretty$(json#, indentSpaces)
```

**Parameters:**
| Parameter | Type | Range | Description |
|-----------|------|-------|-------------|
| `json#` | Pointer | - | JSON value to format |
| `indentSpaces` | Number | 0-8 | Spaces per indent level (default: 2) |

**Example:**
```basic
obj# = json_object#()
json_sets#(obj#, "name", "Test")
json_setn#(obj#, "value", 42)

println json_pretty$(obj#)
' Output:
' {
'   "name": "Test",
'   "value": 42
' }

println json_pretty$(obj#, 4)
' Output:
' {
'     "name": "Test",
'     "value": 42
' }
```

---

## Type Checking Functions

### json_type()

Returns the type code of a JSON value.

**Signature:** `json_type@#`

**Syntax:**
```basic
typeCode = json_type(json#)
```

**Returns:** Type code (0-5, see [Type Codes](#type-codes))

**Example:**
```basic
obj# = json_object#()
arr# = json_array#()
str# = json_string#("hello")

println json_type(obj#)    ' Output: 1 (object)
println json_type(arr#)    ' Output: 2 (array)
println json_type(str#)    ' Output: 3 (string)
```

---

### json_typename$()

Returns the type name of a JSON value as a string.

**Signature:** `json_typename$@#`

**Syntax:**
```basic
typeName$ = json_typename$(json#)
```

**Returns:** `"null"`, `"object"`, `"array"`, `"string"`, `"number"`, or `"boolean"`

**Example:**
```basic
data# = json_parse#("{\"count\":42}")
println json_typename$(data#)                        ' Output: object
println json_typename$(json_get#(data#, "count"))   ' Output: number
```

---

### json_isobj()

Checks if a JSON value is an object.

**Signature:** `json_isobj@#`

**Returns:** 1 if object, 0 otherwise

**Example:**
```basic
obj# = json_object#()
arr# = json_array#()

println json_isobj(obj#)    ' Output: 1
println json_isobj(arr#)    ' Output: 0
```

---

### json_isarr()

Checks if a JSON value is an array.

**Signature:** `json_isarr@#`

**Returns:** 1 if array, 0 otherwise

---

### json_isstr()

Checks if a JSON value is a string.

**Signature:** `json_isstr@#`

**Returns:** 1 if string, 0 otherwise

---

### json_isnum()

Checks if a JSON value is a number.

**Signature:** `json_isnum@#`

**Returns:** 1 if number, 0 otherwise

---

### json_isbool()

Checks if a JSON value is a boolean.

**Signature:** `json_isbool@#`

**Returns:** 1 if boolean (true or false), 0 otherwise

---

### json_isnull()

Checks if a JSON value is null.

**Signature:** `json_isnull@#`

**Returns:** 1 if null or nil pointer, 0 otherwise

**Example:**
```basic
data# = json_parse#("{\"name\":\"John\",\"address\":null}")

println json_isnull(json_get#(data#, "name"))      ' Output: 0
println json_isnull(json_get#(data#, "address"))   ' Output: 1
println json_isnull(json_get#(data#, "missing"))   ' Output: 1 (key doesn't exist)
```

---

## Object Access Functions

### json_get#()

Gets a value from an object by key.

**Signature:** `json_get#@#$`

**Syntax:**
```basic
value# = json_get#(obj#, key$)
```

**Returns:** Pointer to the value, or nil if key doesn't exist

**Example:**
```basic
data# = json_parse#("{\"user\":{\"name\":\"Alice\",\"age\":25}}")
user# = json_get#(data#, "user")
name# = json_get#(user#, "name")
println json_value$(name#)    ' Output: Alice
```

---

### json_getn()

Gets a numeric value from an object by key.

**Signature:** `json_getn@#$` or `json_getn@#$n`

**Syntax:**
```basic
value = json_getn(obj#, key$)
value = json_getn(obj#, key$, defaultValue)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `obj#` | Pointer | JSON object |
| `key$` | String | Key name |
| `defaultValue` | Number | (Optional) Value if key missing or wrong type |

**Returns:** Numeric value (0 if not found/wrong type and no default)

**Example:**
```basic
data# = json_parse#("{\"count\":42,\"active\":true}")

println json_getn(data#, "count")           ' Output: 42
println json_getn(data#, "active")          ' Output: 1 (true = 1)
println json_getn(data#, "missing")         ' Output: 0
println json_getn(data#, "missing", -1)     ' Output: -1 (default)
```

---

### json_gets$()

Gets a string value from an object by key.

**Signature:** `json_gets$@#$` or `json_gets$@#$$`

**Syntax:**
```basic
value$ = json_gets$(obj#, key$)
value$ = json_gets$(obj#, key$, defaultValue$)
```

**Returns:** String value (empty if not found and no default)

**Example:**
```basic
data# = json_parse#("{\"name\":\"John\",\"age\":30}")

println json_gets$(data#, "name")                    ' Output: John
println json_gets$(data#, "age")                     ' Output: 30 (converted)
println json_gets$(data#, "missing", "N/A")          ' Output: N/A
```

---

### json_getb()

Gets a boolean value from an object by key.

**Signature:** `json_getb@#$`

**Syntax:**
```basic
value = json_getb(obj#, key$)
```

**Returns:** 1 if true or non-zero number, 0 otherwise

**Example:**
```basic
data# = json_parse#("{\"active\":true,\"count\":5,\"disabled\":false}")

println json_getb(data#, "active")      ' Output: 1
println json_getb(data#, "count")       ' Output: 1 (5 is truthy)
println json_getb(data#, "disabled")    ' Output: 0
```

---

### json_has()

Checks if a key exists in an object.

**Signature:** `json_has@#$`

**Syntax:**
```basic
exists = json_has(obj#, key$)
```

**Returns:** 1 if key exists, 0 otherwise

**Example:**
```basic
data# = json_parse#("{\"name\":\"John\",\"age\":30}")

println json_has(data#, "name")      ' Output: 1
println json_has(data#, "email")     ' Output: 0

if json_has(data#, "email") = 1 then
    println "Email: "; json_gets$(data#, "email")
else
    println "No email provided"
endif
```

---

## Object Modification Functions

### json_set#()

Sets a JSON value in an object by key.

**Signature:** `json_set#@#$#`

**Syntax:**
```basic
obj# = json_set#(obj#, key$, value#)
```

**Returns:** The same object (for chaining)

**Note:** The value is deep-cloned when added to avoid ownership issues.

**Example:**
```basic
obj# = json_object#()
nested# = json_object#()
json_sets#(nested#, "city", "New York")

json_set#(obj#, "address", nested#)
println json_stringify$(obj#)
' Output: {"address":{"city":"New York"}}
```

---

### json_setn#()

Sets a numeric value in an object by key.

**Signature:** `json_setn#@#$n`

**Syntax:**
```basic
obj# = json_setn#(obj#, key$, value)
```

**Returns:** The same object (for chaining)

**Example:**
```basic
obj# = json_object#()
json_setn#(obj#, "x", 100)
json_setn#(obj#, "y", 200)
json_setn#(obj#, "pi", 3.14159)
```

---

### json_sets#()

Sets a string value in an object by key.

**Signature:** `json_sets#@#$$`

**Syntax:**
```basic
obj# = json_sets#(obj#, key$, value$)
```

**Returns:** The same object (for chaining)

**Example:**
```basic
obj# = json_object#()
json_sets#(obj#, "firstName", "John")
json_sets#(obj#, "lastName", "Doe")
```

---

### json_setb#()

Sets a boolean value in an object by key.

**Signature:** `json_setb#@#$n`

**Syntax:**
```basic
obj# = json_setb#(obj#, key$, value)
```

**Parameters:**
- `value`: 0 = false, non-zero = true

**Returns:** The same object (for chaining)

**Example:**
```basic
obj# = json_object#()
json_setb#(obj#, "active", 1)
json_setb#(obj#, "deleted", 0)
println json_stringify$(obj#)    ' Output: {"active":true,"deleted":false}
```

---

### json_setnull#()

Sets a null value in an object by key.

**Signature:** `json_setnull#@#$`

**Syntax:**
```basic
obj# = json_setnull#(obj#, key$)
```

**Returns:** The same object (for chaining)

**Example:**
```basic
obj# = json_object#()
json_sets#(obj#, "name", "John")
json_setnull#(obj#, "middleName")
println json_stringify$(obj#)    ' Output: {"name":"John","middleName":null}
```

---

### json_remove#()

Removes a key from an object.

**Signature:** `json_remove#@#$`

**Syntax:**
```basic
obj# = json_remove#(obj#, key$)
```

**Returns:** The same object (for chaining)

**Example:**
```basic
obj# = json_parse#("{\"a\":1,\"b\":2,\"c\":3}")
json_remove#(obj#, "b")
println json_stringify$(obj#)    ' Output: {"a":1,"c":3}
```

---

### json_keys#()

Gets all keys from an object as a JSON array.

**Signature:** `json_keys#@#`

**Syntax:**
```basic
keysArr# = json_keys#(obj#)
```

**Returns:** JSON array containing all keys as strings

**Example:**
```basic
obj# = json_parse#("{\"name\":\"John\",\"age\":30,\"city\":\"NYC\"}")
keys# = json_keys#(obj#)

println "Keys: "; json_stringify$(keys#)
' Output: Keys: ["name","age","city"]

' Iterate through keys
for i = 0 to json_len(keys#) - 1
    key$ = json_items$(keys#, i)
    println key$; " = "; json_gets$(obj#, key$)
next
```

---

### json_count()

Gets the number of keys in an object.

**Signature:** `json_count@#`

**Syntax:**
```basic
count = json_count(obj#)
```

**Returns:** Number of key-value pairs in the object

**Example:**
```basic
obj# = json_parse#("{\"a\":1,\"b\":2,\"c\":3}")
println json_count(obj#)    ' Output: 3
```

---

### json_merge#()

Merges two objects, with source values overwriting target values.

**Signature:** `json_merge#@##`

**Syntax:**
```basic
target# = json_merge#(target#, source#)
```

**Returns:** The target object (modified in place)

**Example:**
```basic
defaults# = json_parse#("{\"color\":\"blue\",\"size\":10,\"visible\":true}")
custom# = json_parse#("{\"color\":\"red\",\"opacity\":0.5}")

json_merge#(defaults#, custom#)
println json_pretty$(defaults#)
' Output:
' {
'   "color": "red",
'   "size": 10,
'   "visible": true,
'   "opacity": 0.5
' }
```

---

## Array Functions

### json_len()

Gets the length of an array (or count of object keys, or string length).

**Signature:** `json_len@#`

**Syntax:**
```basic
length = json_len(json#)
```

**Returns:** 
- For arrays: number of elements
- For objects: number of keys
- For strings: character count

**Example:**
```basic
arr# = json_parse#("[1,2,3,4,5]")
println json_len(arr#)    ' Output: 5

obj# = json_parse#("{\"a\":1,\"b\":2}")
println json_len(obj#)    ' Output: 2
```

---

### json_item#()

Gets an array element by index as a pointer.

**Signature:** `json_item#@#n`

**Syntax:**
```basic
item# = json_item#(arr#, index)
```

**Parameters:**
- `index`: Zero-based array index

**Returns:** Pointer to the element, or nil if out of bounds

**Example:**
```basic
arr# = json_parse#("[{\"name\":\"A\"},{\"name\":\"B\"},{\"name\":\"C\"}]")

item# = json_item#(arr#, 1)
println json_gets$(item#, "name")    ' Output: B
```

---

### json_itemn()

Gets an array element as a number.

**Signature:** `json_itemn@#n` or `json_itemn@#nn`

**Syntax:**
```basic
value = json_itemn(arr#, index)
value = json_itemn(arr#, index, defaultValue)
```

**Example:**
```basic
arr# = json_parse#("[10, 20, 30, 40, 50]")

println json_itemn(arr#, 0)          ' Output: 10
println json_itemn(arr#, 2)          ' Output: 30
println json_itemn(arr#, 99)         ' Output: 0 (out of bounds)
println json_itemn(arr#, 99, -1)     ' Output: -1 (default)
```

---

### json_items$()

Gets an array element as a string.

**Signature:** `json_items$@#n` or `json_items$@#n$`

**Syntax:**
```basic
value$ = json_items$(arr#, index)
value$ = json_items$(arr#, index, defaultValue$)
```

**Example:**
```basic
arr# = json_parse#("[\"apple\", \"banana\", \"cherry\"]")

println json_items$(arr#, 0)              ' Output: apple
println json_items$(arr#, 1)              ' Output: banana
println json_items$(arr#, 99, "unknown")  ' Output: unknown
```

---

### json_itemb()

Gets an array element as a boolean.

**Signature:** `json_itemb@#n`

**Syntax:**
```basic
value = json_itemb(arr#, index)
```

**Returns:** 1 if true or truthy, 0 otherwise

---

### json_push#()

Appends a JSON value to an array.

**Signature:** `json_push#@##`

**Syntax:**
```basic
arr# = json_push#(arr#, value#)
```

**Returns:** The same array (for chaining)

**Note:** The value is deep-cloned when added.

**Example:**
```basic
arr# = json_array#()
obj# = json_object#()
json_sets#(obj#, "id", "item1")

json_push#(arr#, obj#)
json_push#(arr#, json_string#("text"))
json_push#(arr#, json_number#(42))
```

---

### json_pushn#()

Appends a number to an array.

**Signature:** `json_pushn#@#n`

**Syntax:**
```basic
arr# = json_pushn#(arr#, value)
```

**Returns:** The same array (for chaining)

**Example:**
```basic
arr# = json_array#()
for i = 1 to 5
    json_pushn#(arr#, i * 10)
next
println json_stringify$(arr#)    ' Output: [10,20,30,40,50]
```

---

### json_pushs#()

Appends a string to an array.

**Signature:** `json_pushs#@#$`

**Syntax:**
```basic
arr# = json_pushs#(arr#, value$)
```

**Returns:** The same array (for chaining)

**Example:**
```basic
arr# = json_array#()
json_pushs#(arr#, "first")
json_pushs#(arr#, "second")
json_pushs#(arr#, "third")
```

---

### json_pushb#()

Appends a boolean to an array.

**Signature:** `json_pushb#@#n`

**Syntax:**
```basic
arr# = json_pushb#(arr#, value)
```

**Parameters:**
- `value`: 0 = false, non-zero = true

**Example:**
```basic
arr# = json_array#()
json_pushb#(arr#, 1)
json_pushb#(arr#, 0)
println json_stringify$(arr#)    ' Output: [true,false]
```

---

### json_pushnull#()

Appends a null value to an array.

**Signature:** `json_pushnull#@#`

**Syntax:**
```basic
arr# = json_pushnull#(arr#)
```

**Example:**
```basic
arr# = json_array#()
json_pushs#(arr#, "value")
json_pushnull#(arr#)
json_pushn#(arr#, 42)
println json_stringify$(arr#)    ' Output: ["value",null,42]
```

---

### json_pop#()

Removes and returns the last element of an array.

**Signature:** `json_pop#@#`

**Syntax:**
```basic
lastItem# = json_pop#(arr#)
```

**Returns:** The removed element (cloned), or nil if array is empty

**Example:**
```basic
arr# = json_parse#("[1, 2, 3]")

item# = json_pop#(arr#)
println json_value(item#)            ' Output: 3
println json_stringify$(arr#)        ' Output: [1,2]
```

---

### json_removeat#()

Removes an element at a specific index.

**Signature:** `json_removeat#@#n`

**Syntax:**
```basic
arr# = json_removeat#(arr#, index)
```

**Returns:** The same array (modified)

**Example:**
```basic
arr# = json_parse#("[\"a\", \"b\", \"c\", \"d\"]")
json_removeat#(arr#, 1)
println json_stringify$(arr#)    ' Output: ["a","c","d"]
```

---

## Path Navigation Functions

Path navigation allows accessing nested values using dot notation and array indices.

### Path Syntax

| Pattern | Description | Example |
|---------|-------------|---------|
| `key` | Object key | `"name"` |
| `key.subkey` | Nested key | `"user.profile"` |
| `[n]` | Array index | `"[0]"` |
| `key[n]` | Key then index | `"items[0]"` |
| `key.subkey[n].prop` | Combined | `"users[0].name"` |

---

### json_path#()

Navigates to a value by path.

**Signature:** `json_path#@#$`

**Syntax:**
```basic
value# = json_path#(json#, path$)
```

**Returns:** Pointer to the value at path, or nil if not found

**Example:**
```basic
data# = json_parse#("{\"users\":[{\"name\":\"Alice\",\"age\":30},{\"name\":\"Bob\",\"age\":25}]}")

' Navigate to nested values
users# = json_path#(data#, "users")
firstUser# = json_path#(data#, "users[0]")
firstName# = json_path#(data#, "users[0].name")

println json_value$(firstName#)    ' Output: Alice
```

---

### json_pathn()

Gets a numeric value at a path.

**Signature:** `json_pathn@#$` or `json_pathn@#$n`

**Syntax:**
```basic
value = json_pathn(json#, path$)
value = json_pathn(json#, path$, defaultValue)
```

**Example:**
```basic
data# = json_parse#("{\"config\":{\"width\":800,\"height\":600}}")

println json_pathn(data#, "config.width")           ' Output: 800
println json_pathn(data#, "config.height")          ' Output: 600
println json_pathn(data#, "config.depth", 100)      ' Output: 100 (default)
```

---

### json_paths$()

Gets a string value at a path.

**Signature:** `json_paths$@#$` or `json_paths$@#$$`

**Syntax:**
```basic
value$ = json_paths$(json#, path$)
value$ = json_paths$(json#, path$, defaultValue$)
```

**Example:**
```basic
data# = json_parse#("{\"user\":{\"profile\":{\"email\":\"test@example.com\"}}}")

println json_paths$(data#, "user.profile.email")
' Output: test@example.com

println json_paths$(data#, "user.profile.phone", "N/A")
' Output: N/A
```

---

### json_pathb()

Gets a boolean value at a path.

**Signature:** `json_pathb@#$`

**Syntax:**
```basic
value = json_pathb(json#, path$)
```

**Returns:** 1 if true or truthy, 0 otherwise

**Example:**
```basic
data# = json_parse#("{\"settings\":{\"notifications\":{\"email\":true,\"sms\":false}}}")

println json_pathb(data#, "settings.notifications.email")    ' Output: 1
println json_pathb(data#, "settings.notifications.sms")      ' Output: 0
```

---

## Utility Functions

### json_clone#()

Creates a deep copy of a JSON value.

**Signature:** `json_clone#@#`

**Syntax:**
```basic
copy# = json_clone#(json#)
```

**Returns:** New independent copy of the JSON value

**Example:**
```basic
original# = json_parse#("{\"name\":\"John\",\"scores\":[1,2,3]}")
copy# = json_clone#(original#)

' Modify the copy without affecting original
json_sets#(copy#, "name", "Jane")

println json_gets$(original#, "name")    ' Output: John
println json_gets$(copy#, "name")        ' Output: Jane
```

---

### json_value()

Gets the numeric value of a JSON primitive.

**Signature:** `json_value@#`

**Syntax:**
```basic
num = json_value(json#)
```

**Returns:**
- Number → the numeric value
- Boolean true → 1
- Boolean false → 0
- Other types → 0

**Example:**
```basic
num# = json_number#(42)
bool# = json_bool#(1)

println json_value(num#)     ' Output: 42
println json_value(bool#)    ' Output: 1
```

---

### json_value$()

Gets the string value of a JSON primitive.

**Signature:** `json_value$@#`

**Syntax:**
```basic
str$ = json_value$(json#)
```

**Returns:**
- String → the string value
- Null → empty string
- Other types → JSON representation

**Example:**
```basic
str# = json_string#("Hello")
num# = json_number#(42)

println json_value$(str#)    ' Output: Hello
println json_value$(num#)    ' Output: 42
```

---

## Complete Examples

### Example 1: Building JSON from Scratch

```basic
' Create a person object with nested data
println "=== Building JSON ==="
println ""

person# = json_object#()
json_sets#(person#, "firstName", "John")
json_sets#(person#, "lastName", "Doe")
json_setn#(person#, "age", 35)
json_setb#(person#, "employed", 1)

' Add address object
address# = json_object#()
json_sets#(address#, "street", "123 Main St")
json_sets#(address#, "city", "New York")
json_sets#(address#, "zip", "10001")
json_set#(person#, "address", address#)

' Add array of hobbies
hobbies# = json_array#()
json_pushs#(hobbies#, "reading")
json_pushs#(hobbies#, "gaming")
json_pushs#(hobbies#, "hiking")
json_set#(person#, "hobbies", hobbies#)

println json_pretty$(person#)
```

---

### Example 2: Parsing and Querying JSON

```basic
' Parse JSON and extract values using paths
println "=== Parsing JSON ==="
println ""

json$ = "{\"company\":\"Acme Inc\",\"employees\":[{\"name\":\"Alice\",\"dept\":\"Engineering\"},{\"name\":\"Bob\",\"dept\":\"Sales\"}],\"active\":true}"

data# = json_parse#(json$)

if isnil(data#) = 1 then
    println "Company: "; json_gets$(data#, "company")
    println "Active: "; json_getb(data#, "active")
    println ""
    
    println "Employees:"
    empCount = json_len(json_get#(data#, "employees"))
    
    for i = 0 to empCount - 1
        path$ = "employees[" + stri$(i, 0) + "]"
        println "  "; json_paths$(data#, path$ + ".name"); " - "; json_paths$(data#, path$ + ".dept")
    next
else
    println "Failed to parse JSON"
endif
```

---

### Example 3: Modifying Existing JSON

```basic
' Load, modify, and save JSON configuration
println "=== Modifying JSON ==="
println ""

config$ = "{\"version\":1,\"debug\":false,\"maxConnections\":10}"
config# = json_parse#(config$)

println "Before:"
println json_pretty$(config#)
println ""

' Update values
json_setn#(config#, "version", 2)
json_setb#(config#, "debug", 1)
json_setn#(config#, "maxConnections", 50)
json_sets#(config#, "server", "localhost")

println "After:"
println json_pretty$(config#)
```

---

### Example 4: Working with Arrays

```basic
' Array manipulation example
println "=== Array Operations ==="
println ""

' Create array of scores
scores# = json_array#()
json_pushn#(scores#, 85)
json_pushn#(scores#, 92)
json_pushn#(scores#, 78)
json_pushn#(scores#, 95)
json_pushn#(scores#, 88)

println "Scores: "; json_stringify$(scores#)
println "Count: "; json_len(scores#)
println ""

' Calculate average
total = 0
for i = 0 to json_len(scores#) - 1
    total = total + json_itemn(scores#, i)
next
average = total / json_len(scores#)
println "Average: "; average
println ""

' Remove lowest score
json_removeat#(scores#, 2)  ' Remove 78
println "After removing lowest: "; json_stringify$(scores#)
```

---

### Example 5: API Response Handling

```basic
' Simulating API response processing
println "=== API Response Processing ==="
println ""

apiResponse$ = "{\"status\":\"success\",\"data\":{\"users\":[{\"id\":1,\"name\":\"Alice\",\"email\":\"alice@example.com\"},{\"id\":2,\"name\":\"Bob\",\"email\":\"bob@example.com\"}],\"total\":2},\"timestamp\":\"2025-01-15T10:30:00Z\"}"

response# = json_parse#(apiResponse$)

' Check status
if json_gets$(response#, "status") = "success" then
    println "Request successful!"
    println "Timestamp: "; json_gets$(response#, "timestamp")
    println ""
    
    total = json_pathn(response#, "data.total")
    println "Total users: "; total
    println ""
    
    println "User list:"
    for i = 0 to total - 1
        basePath$ = "data.users[" + stri$(i, 0) + "]"
        println "  ID: "; json_pathn(response#, basePath$ + ".id")
        println "  Name: "; json_paths$(response#, basePath$ + ".name")
        println "  Email: "; json_paths$(response#, basePath$ + ".email")
        println ""
    next
else
    println "Request failed!"
endif
```

---

### Example 6: Object Key Iteration

```basic
' Iterate through all keys in an object
println "=== Key Iteration ==="
println ""

data# = json_parse#("{\"name\":\"Product A\",\"price\":29.99,\"stock\":150,\"category\":\"Electronics\",\"active\":true}")

keys# = json_keys#(data#)
println "Object has "; json_len(keys#); " properties:"
println ""

for i = 0 to json_len(keys#) - 1
    key$ = json_items$(keys#, i)
    value# = json_get#(data#, key$)
    typeName$ = json_typename$(value#)
    
    print "  "; key$; " ("; typeName$; "): "
    
    if typeName$ = "string" then
        println json_gets$(data#, key$)
    else if typeName$ = "number" then
        println json_getn(data#, key$)
    else if typeName$ = "boolean" then
        if json_getb(data#, key$) = 1 then
            println "true"
        else
            println "false"
        endif
    else
        println json_stringify$(value#)
    endif
next
```

---

## Quick Reference

### Creation Functions
```basic
json_object#()              ' Create empty object
json_array#()               ' Create empty array
json_parse#(str$)           ' Parse JSON string
json_null#()                ' Create null value
json_bool#(n)               ' Create boolean (0=false)
json_number#(n)             ' Create number
json_string#(str$)          ' Create string
```

### Serialization
```basic
json_stringify$(json#)      ' To compact string
json_pretty$(json#)         ' To formatted string (2 spaces)
json_pretty$(json#, n)      ' To formatted string (n spaces)
```

### Type Checking
```basic
json_type(json#)            ' Get type code (0-5)
json_typename$(json#)       ' Get type name string
json_isobj(json#)           ' Is object? (1/0)
json_isarr(json#)           ' Is array? (1/0)
json_isstr(json#)           ' Is string? (1/0)
json_isnum(json#)           ' Is number? (1/0)
json_isbool(json#)          ' Is boolean? (1/0)
json_isnull(json#)          ' Is null? (1/0)
```

### Object Access
```basic
json_get#(obj#, key$)           ' Get value as pointer
json_getn(obj#, key$)           ' Get as number
json_getn(obj#, key$, def)      ' Get as number with default
json_gets$(obj#, key$)          ' Get as string
json_gets$(obj#, key$, def$)    ' Get as string with default
json_getb(obj#, key$)           ' Get as boolean
json_has(obj#, key$)            ' Check if key exists
```

### Object Modification
```basic
json_set#(obj#, key$, val#)     ' Set pointer value
json_setn#(obj#, key$, n)       ' Set number
json_sets#(obj#, key$, str$)    ' Set string
json_setb#(obj#, key$, n)       ' Set boolean
json_setnull#(obj#, key$)       ' Set null
json_remove#(obj#, key$)        ' Remove key
json_keys#(obj#)                ' Get all keys as array
json_count(obj#)                ' Get key count
json_merge#(target#, source#)   ' Merge objects
```

### Array Functions
```basic
json_len(json#)                 ' Get length
json_item#(arr#, idx)           ' Get item as pointer
json_itemn(arr#, idx)           ' Get item as number
json_itemn(arr#, idx, def)      ' Get with default
json_items$(arr#, idx)          ' Get item as string
json_items$(arr#, idx, def$)    ' Get with default
json_itemb(arr#, idx)           ' Get item as boolean
json_push#(arr#, val#)          ' Push pointer
json_pushn#(arr#, n)            ' Push number
json_pushs#(arr#, str$)         ' Push string
json_pushb#(arr#, n)            ' Push boolean
json_pushnull#(arr#)            ' Push null
json_pop#(arr#)                 ' Pop last item
json_removeat#(arr#, idx)       ' Remove at index
```

### Path Navigation
```basic
json_path#(json#, path$)        ' Navigate to pointer
json_pathn(json#, path$)        ' Get number at path
json_pathn(json#, path$, def)   ' Get with default
json_paths$(json#, path$)       ' Get string at path
json_paths$(json#, path$, def$) ' Get with default
json_pathb(json#, path$)        ' Get boolean at path
```

### Utility
```basic
json_clone#(json#)              ' Deep copy
json_value(json#)               ' Get numeric value
json_value$(json#)              ' Get string value
```

---

### All Registered Functions (Alphabetical)

| Function | Signature | Description |
|----------|-----------|-------------|
| `json_array#` | `json_array#@` | Create empty array |
| `json_bool#` | `json_bool#@n` | Create boolean |
| `json_clone#` | `json_clone#@#` | Deep copy JSON |
| `json_count` | `json_count@#` | Count object keys |
| `json_get#` | `json_get#@#$` | Get value by key |
| `json_getb` | `json_getb@#$` | Get boolean by key |
| `json_getn` | `json_getn@#$` | Get number by key |
| `json_getn` | `json_getn@#$n` | Get number with default |
| `json_gets$` | `json_gets$@#$` | Get string by key |
| `json_gets$` | `json_gets$@#$$` | Get string with default |
| `json_has` | `json_has@#$` | Check if key exists |
| `json_isarr` | `json_isarr@#` | Is array? |
| `json_isbool` | `json_isbool@#` | Is boolean? |
| `json_isnull` | `json_isnull@#` | Is null? |
| `json_isnum` | `json_isnum@#` | Is number? |
| `json_isobj` | `json_isobj@#` | Is object? |
| `json_isstr` | `json_isstr@#` | Is string? |
| `json_item#` | `json_item#@#n` | Get array item |
| `json_itemb` | `json_itemb@#n` | Get array item as boolean |
| `json_itemn` | `json_itemn@#n` | Get array item as number |
| `json_itemn` | `json_itemn@#nn` | Get with default |
| `json_items$` | `json_items$@#n` | Get array item as string |
| `json_items$` | `json_items$@#n$` | Get with default |
| `json_keys#` | `json_keys#@#` | Get all keys |
| `json_len` | `json_len@#` | Get length |
| `json_merge#` | `json_merge#@##` | Merge objects |
| `json_null#` | `json_null#@` | Create null |
| `json_number#` | `json_number#@n` | Create number |
| `json_object#` | `json_object#@` | Create empty object |
| `json_parse#` | `json_parse#@$` | Parse JSON string |
| `json_path#` | `json_path#@#$` | Navigate by path |
| `json_pathb` | `json_pathb@#$` | Get boolean at path |
| `json_pathn` | `json_pathn@#$` | Get number at path |
| `json_pathn` | `json_pathn@#$n` | Get with default |
| `json_paths$` | `json_paths$@#$` | Get string at path |
| `json_paths$` | `json_paths$@#$$` | Get with default |
| `json_pop#` | `json_pop#@#` | Pop last item |
| `json_pretty$` | `json_pretty$@#` | Format JSON (2 spaces) |
| `json_pretty$` | `json_pretty$@#n` | Format with custom indent |
| `json_push#` | `json_push#@##` | Push value |
| `json_pushb#` | `json_pushb#@#n` | Push boolean |
| `json_pushn#` | `json_pushn#@#n` | Push number |
| `json_pushnull#` | `json_pushnull#@#` | Push null |
| `json_pushs#` | `json_pushs#@#$` | Push string |
| `json_remove#` | `json_remove#@#$` | Remove key |
| `json_removeat#` | `json_removeat#@#n` | Remove at index |
| `json_set#` | `json_set#@#$#` | Set value |
| `json_setb#` | `json_setb#@#$n` | Set boolean |
| `json_setn#` | `json_setn#@#$n` | Set number |
| `json_setnull#` | `json_setnull#@#$` | Set null |
| `json_sets#` | `json_sets#@#$$` | Set string |
| `json_string#` | `json_string#@$` | Create string |
| `json_stringify$` | `json_stringify$@#` | To compact string |
| `json_type` | `json_type@#` | Get type code |
| `json_typename$` | `json_typename$@#` | Get type name |
| `json_value` | `json_value@#` | Get numeric value |
| `json_value$` | `json_value$@#` | Get string value |

---

## Notes and Best Practices

### Memory Management

All JSON values are automatically tracked by the garbage collector. You don't need to free them manually:

```basic
' This is fine - GC handles cleanup
obj# = json_object#()
json_sets#(obj#, "temp", "data")
' obj# will be cleaned up when no longer referenced
```

### Null Safety

Always check for nil when parsing untrusted JSON:

```basic
data# = json_parse#(userInput$)
if isnil(data#) = 1 then
    ' Safe to use
else
    println "Invalid JSON"
endif
```

### Using Default Values

Use default values to simplify code and avoid nil checks:

```basic
' Instead of:
if json_has(config#, "timeout") = 1 then
    timeout = json_getn(config#, "timeout")
else
    timeout = 30
endif

' Use:
timeout = json_getn(config#, "timeout", 30)
```

### Path Navigation vs Direct Access

Use paths for deeply nested data, direct access for shallow:

```basic
' Good for deep nesting
email$ = json_paths$(data#, "user.profile.contact.email")

' Good for shallow access
name$ = json_gets$(user#, "name")
```

### Building JSON Programmatically

For complex structures, build incrementally:

```basic
root# = json_object#()

' Build nested structure
profile# = json_object#()
json_sets#(profile#, "bio", "Developer")
json_set#(root#, "profile", profile#)

' Build array
tags# = json_array#()
json_pushs#(tags#, "coding")
json_pushs#(tags#, "music")
json_set#(root#, "tags", tags#)
```

---

*End of JsonLib Documentation*
