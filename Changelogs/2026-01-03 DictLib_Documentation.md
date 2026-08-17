# DictLib - Dictionary Library Reference

## Overview

The **DictLib** library provides key/value storage functionality for Plan9Basic programs. Dictionaries (also known as associative arrays or maps) allow you to store and retrieve values using string keys instead of numeric indices.

Plan9Basic dictionaries support three value types:
- **Numeric dictionaries**: Store numeric values (Extended precision)
- **String dictionaries**: Store string values
- **Pointer dictionaries**: Store pointer values (for storing objects)

All dictionary functions use string keys for accessing values.

---

## Dictionary Creation

### dict#()

Creates a new empty numeric dictionary.

**Syntax:**
```basic
dict# = dict#()
```

**Returns:** Pointer to the newly created numeric dictionary.

**Example:**
```basic
' Create a numeric dictionary for ages
ages# = dict#()
dict_set#(ages#, "John", 25)
dict_set#(ages#, "Mary", 30)
println "John's age:", dict_get(ages#, "John")
```

---

### sdict#()

Creates a new empty string dictionary.

**Syntax:**
```basic
dict# = sdict#()
```

**Returns:** Pointer to the newly created string dictionary.

**Example:**
```basic
' Create a string dictionary for capitals
capitals# = sdict#()
sdict_set#(capitals#, "France", "Paris")
sdict_set#(capitals#, "Germany", "Berlin")
println "Capital of France:", sdict_get$(capitals#, "France")
```

---

### pdict#()

Creates a new empty pointer dictionary.

**Syntax:**
```basic
dict# = pdict#()
```

**Returns:** Pointer to the newly created pointer dictionary.

**Example:**
```basic
' Create a pointer dictionary for objects
objects# = pdict#()
arr1# = dim#(10)
arr2# = dim#(20)
pdict_set#(objects#, "first", arr1#)
pdict_set#(objects#, "second", arr2#)
```

---

## Numeric Dictionary Operations

### dict_set#(dict#, key$, value)

Sets a numeric value in a numeric dictionary.

**Syntax:**
```basic
result# = dict_set#(dict#, key$, value)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | The numeric dictionary |
| key$ | String | The key to set |
| value | Numeric | The value to store |

**Returns:** The dictionary pointer (allows chaining).

**Notes:**
- If the key already exists, the value is replaced.
- If the key does not exist, it is created.

**Example:**
```basic
scores# = dict#()
dict_set#(scores#, "Player1", 100)
dict_set#(scores#, "Player2", 250)
dict_set#(scores#, "Player1", 150)  ' Updates Player1's score
```

---

### dict_get(dict#, key$)

Gets a numeric value from a numeric dictionary.

**Syntax:**
```basic
value = dict_get(dict#, key$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | The numeric dictionary |
| key$ | String | The key to retrieve |

**Returns:** The numeric value associated with the key.

**Error:** Raises an exception if the key does not exist.

**Example:**
```basic
scores# = dict#()
dict_set#(scores#, "Player1", 100)
println "Score:", dict_get(scores#, "Player1")  ' Prints: 100
```

---

### dict_getdef(dict#, key$, default)

Gets a numeric value from a dictionary, returning a default if the key doesn't exist.

**Syntax:**
```basic
value = dict_getdef(dict#, key$, default)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | The numeric dictionary |
| key$ | String | The key to retrieve |
| default | Numeric | Value to return if key not found |

**Returns:** The value if key exists, otherwise the default value.

**Example:**
```basic
scores# = dict#()
dict_set#(scores#, "Player1", 100)
println dict_getdef(scores#, "Player1", 0)   ' Prints: 100
println dict_getdef(scores#, "Player2", 0)   ' Prints: 0 (default)
```

---

## String Dictionary Operations

### sdict_set#(dict#, key$, value$)

Sets a string value in a string dictionary.

**Syntax:**
```basic
result# = sdict_set#(dict#, key$, value$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | The string dictionary |
| key$ | String | The key to set |
| value$ | String | The value to store |

**Returns:** The dictionary pointer (allows chaining).

**Example:**
```basic
config# = sdict#()
sdict_set#(config#, "username", "admin")
sdict_set#(config#, "server", "localhost")
```

---

### sdict_get$(dict#, key$)

Gets a string value from a string dictionary.

**Syntax:**
```basic
value$ = sdict_get$(dict#, key$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | The string dictionary |
| key$ | String | The key to retrieve |

**Returns:** The string value associated with the key.

**Error:** Raises an exception if the key does not exist.

**Example:**
```basic
config# = sdict#()
sdict_set#(config#, "username", "admin")
println "User:", sdict_get$(config#, "username")
```

---

### sdict_getdef$(dict#, key$, default$)

Gets a string value from a dictionary, returning a default if the key doesn't exist.

**Syntax:**
```basic
value$ = sdict_getdef$(dict#, key$, default$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | The string dictionary |
| key$ | String | The key to retrieve |
| default$ | String | Value to return if key not found |

**Returns:** The value if key exists, otherwise the default value.

**Example:**
```basic
config# = sdict#()
sdict_set#(config#, "username", "admin")
println sdict_getdef$(config#, "username", "guest")   ' Prints: admin
println sdict_getdef$(config#, "password", "none")    ' Prints: none (default)
```

---

## Pointer Dictionary Operations

### pdict_set#(dict#, key$, value#)

Sets a pointer value in a pointer dictionary.

**Syntax:**
```basic
result# = pdict_set#(dict#, key$, value#)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | The pointer dictionary |
| key$ | String | The key to set |
| value# | Pointer | The pointer value to store |

**Returns:** The dictionary pointer (allows chaining).

**Example:**
```basic
arrays# = pdict#()
data1# = dim#(100)
data2# = sdim#(50)
pdict_set#(arrays#, "numbers", data1#)
pdict_set#(arrays#, "names", data2#)
```

---

### pdict_get#(dict#, key$)

Gets a pointer value from a pointer dictionary.

**Syntax:**
```basic
value# = pdict_get#(dict#, key$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | The pointer dictionary |
| key$ | String | The key to retrieve |

**Returns:** The pointer value associated with the key.

**Error:** Raises an exception if the key does not exist.

**Example:**
```basic
arrays# = pdict#()
data# = dim#(10)
pdict_set#(arrays#, "mydata", data#)
retrieved# = pdict_get#(arrays#, "mydata")
```

---

### pdict_getdef#(dict#, key$, default#)

Gets a pointer value from a dictionary, returning a default if the key doesn't exist.

**Syntax:**
```basic
value# = pdict_getdef#(dict#, key$, default#)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | The pointer dictionary |
| key$ | String | The key to retrieve |
| default# | Pointer | Value to return if key not found |

**Returns:** The value if key exists, otherwise the default value.

---

## Generic Dictionary Operations

These functions work with any dictionary type (numeric, string, or pointer).

### dict_exists(dict#, key$)

Checks if a key exists in the dictionary.

**Syntax:**
```basic
result = dict_exists(dict#, key$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | Any dictionary type |
| key$ | String | The key to check |

**Returns:** 1 if the key exists, 0 otherwise.

**Example:**
```basic
ages# = dict#()
dict_set#(ages#, "John", 25)

if dict_exists(ages#, "John") = 1 then
    println "John is in the dictionary"
endif

if dict_exists(ages#, "Mary") = 0 then
    println "Mary is not in the dictionary"
endif
```

---

### dict_haskey(dict#, key$)

Alias for `dict_exists`. Checks if a key exists in the dictionary.

**Syntax:**
```basic
result = dict_haskey(dict#, key$)
```

---

### dict_count(dict#)

Returns the number of key/value pairs in the dictionary.

**Syntax:**
```basic
count = dict_count(dict#)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | Any dictionary type |

**Returns:** The number of entries in the dictionary.

**Example:**
```basic
ages# = dict#()
println dict_count(ages#)  ' Prints: 0

dict_set#(ages#, "John", 25)
dict_set#(ages#, "Mary", 30)
println dict_count(ages#)  ' Prints: 2
```

---

### dict_remove(dict#, key$)

Removes a key/value pair from the dictionary.

**Syntax:**
```basic
result = dict_remove(dict#, key$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | Any dictionary type |
| key$ | String | The key to remove |

**Returns:** 1 if the key was removed, 0 if it didn't exist.

**Example:**
```basic
ages# = dict#()
dict_set#(ages#, "John", 25)
dict_set#(ages#, "Mary", 30)
println dict_count(ages#)  ' Prints: 2

result = dict_remove(ages#, "John")
println "Removed:", result  ' Prints: 1
println dict_count(ages#)   ' Prints: 1

result = dict_remove(ages#, "John")
println "Removed:", result  ' Prints: 0 (already removed)
```

---

### dict_clear#(dict#)

Removes all key/value pairs from the dictionary.

**Syntax:**
```basic
result# = dict_clear#(dict#)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | Any dictionary type |

**Returns:** The dictionary pointer (allows chaining).

**Example:**
```basic
ages# = dict#()
dict_set#(ages#, "John", 25)
dict_set#(ages#, "Mary", 30)
println dict_count(ages#)  ' Prints: 2

dict_clear#(ages#)
println dict_count(ages#)  ' Prints: 0
```

---

### dict_type(dict#)

Returns the type code of the dictionary.

**Syntax:**
```basic
typeCode = dict_type(dict#)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | Any dictionary type |

**Returns:** 
- 0 = Numeric dictionary
- 1 = String dictionary
- 2 = Pointer dictionary

**Example:**
```basic
numDict# = dict#()
strDict# = sdict#()
ptrDict# = pdict#()

println dict_type(numDict#)  ' Prints: 0
println dict_type(strDict#)  ' Prints: 1
println dict_type(ptrDict#)  ' Prints: 2
```

---

### dict_typename$(dict#)

Returns the type name of the dictionary as a string.

**Syntax:**
```basic
typeName$ = dict_typename$(dict#)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | Any dictionary type |

**Returns:** "numeric", "string", or "pointer".

**Example:**
```basic
ages# = dict#()
println dict_typename$(ages#)  ' Prints: numeric
```

---

### dict_key$(dict#, index)

Returns the key at the specified index (0-based).

**Syntax:**
```basic
key$ = dict_key$(dict#, index)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| dict# | Pointer | Any dictionary type |
| index | Numeric | The 0-based index |

**Returns:** The key at the specified index.

**Error:** Raises an exception if index is out of bounds.

**Note:** The order of keys is not guaranteed to be consistent.

**Example:**
```basic
ages# = dict#()
dict_set#(ages#, "John", 25)
dict_set#(ages#, "Mary", 30)
dict_set#(ages#, "Bob", 22)

' Iterate through all keys
for i = 0 to dict_count(ages#) - 1
    key$ = dict_key$(ages#, i)
    println key$, ":", dict_get(ages#, key$)
next
```

---

## Complete Examples

### Example 1: Phone Book

```basic
' Simple phone book using string dictionary
phonebook# = sdict#()

' Add contacts
sdict_set#(phonebook#, "John Smith", "555-1234")
sdict_set#(phonebook#, "Mary Johnson", "555-5678")
sdict_set#(phonebook#, "Bob Wilson", "555-9999")

' Look up a number
name$ = "John Smith"
if dict_exists(phonebook#, name$) = 1 then
    println name$, ":", sdict_get$(phonebook#, name$)
else
    println name$, "not found"
endif

' List all contacts
println ""
println "All contacts:"
for i = 0 to dict_count(phonebook#) - 1
    name$ = dict_key$(phonebook#, i)
    println name$, "->", sdict_get$(phonebook#, name$)
next
```

### Example 2: Word Counter

```basic
' Count word occurrences
wordCount# = dict#()

' Sample words (in a real app, you'd read from a file)
data "apple", "banana", "apple", "cherry", "banana", "apple"

for i = 1 to 6
    read word$
    current = dict_getdef(wordCount#, word$, 0)
    dict_set#(wordCount#, word$, current + 1)
next

' Display results
println "Word frequencies:"
for i = 0 to dict_count(wordCount#) - 1
    word$ = dict_key$(wordCount#, i)
    println word$, ":", dict_get(wordCount#, word$)
next
```

### Example 3: Configuration Manager

```basic
' Application configuration using string dictionary
config# = sdict#()

' Set default configuration
sdict_set#(config#, "app.name", "MyApp")
sdict_set#(config#, "app.version", "1.0")
sdict_set#(config#, "db.host", "localhost")
sdict_set#(config#, "db.port", "3306")
sdict_set#(config#, "debug.enabled", "false")

' Get configuration with defaults
appName$ = sdict_get$(config#, "app.name")
timeout$ = sdict_getdef$(config#, "timeout", "30")

println "Application:", appName$
println "Timeout:", timeout$
```

### Example 4: Object Registry

```basic
' Store objects in a pointer dictionary
registry# = pdict#()

' Create and register some arrays
users# = sdim#(100)
scores# = dim#(100)
settings# = sdict#()

pdict_set#(registry#, "users", users#)
pdict_set#(registry#, "scores", scores#)
pdict_set#(registry#, "settings", settings#)

' Retrieve an object
if dict_exists(registry#, "scores") = 1 then
    myScores# = pdict_get#(registry#, "scores")
    ' Use myScores# as a numeric array
endif
```

---

## Error Codes

DictLib functions may raise the following errors:

| Error | Description |
|-------|-------------|
| Null dictionary pointer | The dictionary pointer is null |
| Invalid dictionary object | The pointer doesn't point to a valid dictionary |
| Type mismatch | Wrong dictionary type for the operation |
| Key not found | Attempted to get a non-existent key without default |
| Index out of bounds | Invalid index in dict_key$ |

---

## Memory Management

Dictionaries are automatically managed by Plan9Basic's garbage collector. When a dictionary is no longer referenced, it will be automatically freed. You don't need to manually free dictionaries in most cases.

---

## Function Summary

| Function | Description | Returns |
|----------|-------------|---------|
| `dict#()` | Create numeric dictionary | Pointer |
| `sdict#()` | Create string dictionary | Pointer |
| `pdict#()` | Create pointer dictionary | Pointer |
| `dict_set#(d#, k$, v)` | Set numeric value | Pointer |
| `dict_get(d#, k$)` | Get numeric value | Number |
| `dict_getdef(d#, k$, def)` | Get numeric with default | Number |
| `sdict_set#(d#, k$, v$)` | Set string value | Pointer |
| `sdict_get$(d#, k$)` | Get string value | String |
| `sdict_getdef$(d#, k$, def$)` | Get string with default | String |
| `pdict_set#(d#, k$, v#)` | Set pointer value | Pointer |
| `pdict_get#(d#, k$)` | Get pointer value | Pointer |
| `pdict_getdef#(d#, k$, def#)` | Get pointer with default | Pointer |
| `dict_exists(d#, k$)` | Check if key exists | Number (0/1) |
| `dict_haskey(d#, k$)` | Alias for dict_exists | Number (0/1) |
| `dict_count(d#)` | Get entry count | Number |
| `dict_remove(d#, k$)` | Remove a key | Number (0/1) |
| `dict_clear#(d#)` | Clear all entries | Pointer |
| `dict_type(d#)` | Get type code | Number |
| `dict_typename$(d#)` | Get type name | String |
| `dict_key$(d#, idx)` | Get key at index | String |
