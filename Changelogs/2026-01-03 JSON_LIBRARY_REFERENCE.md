# Plan9Basic JSON Library Reference

## Overview

The JSON Library provides comprehensive support for creating, parsing, and manipulating JSON data in Plan9Basic.

**Important:** JSON arrays use **0-based indexing** (standard JSON convention), while Plan9Basic arrays use 1-based indexing.

## Constants

| Constant | Value | Description |
|----------|-------|-------------|
| JSON_TYPE_NULL | 0 | Null value |
| JSON_TYPE_OBJECT | 1 | JSON object {...} |
| JSON_TYPE_ARRAY | 2 | JSON array [...] |
| JSON_TYPE_STRING | 3 | String value |
| JSON_TYPE_NUMBER | 4 | Numeric value |
| JSON_TYPE_BOOLEAN | 5 | Boolean (true/false) |

---

## JSON Literal Syntax

Plan9Basic supports native JSON literal syntax for creating JSON values directly in code.

### Array Literals

```basic
' Simple arrays
LET arr# = [1, 2, 3]
LET names# = ["Alice", "Bob", "Carol"]

' Mixed types
LET mixed# = [10, "text", 3.14]

' With variables
LET name$ = "John"
LET age = 30
LET data# = [name$, age]

' Boolean and null values
LET flags# = [true, false, null]

' Nested arrays
LET matrix# = [[1, 2], [3, 4]]
```

### Object Literals

```basic
' Simple object
LET person# = {"name": "John", "age": 30}

' With variables
LET userName$ = "Alice"
LET userAge = 25
LET user# = {"name": userName$, "age": userAge}

' Nested objects
LET data# = {"user": {"name": "John", "email": "john@example.com"}}

' Objects with arrays
LET record# = {"name": "John", "scores": [95, 87, 92]}

' Arrays with objects
LET users# = [{"name": "Alice"}, {"name": "Bob"}]
```

---

## Creation Functions

### json_object#()
Creates an empty JSON object.

```basic
LET obj# = json_object#()
println json_stringify$(obj#)  ' Output: {}
```

### json_array#()
Creates an empty JSON array.

```basic
LET arr# = json_array#()
println json_stringify$(arr#)  ' Output: []
```

### json_parse#(jsonString$)
Parses a JSON string into a JSON value.

```basic
LET json$ = "{\"name\": \"John\", \"age\": 30}"
LET obj# = json_parse#(json$)
println json_gets$(obj#, "name")  ' Output: John
```

### json_null#()
Creates a JSON null value.

```basic
LET n# = json_null#()
println json_stringify$(n#)  ' Output: null
```

### json_bool#(value)
Creates a JSON boolean. Non-zero = true, zero = false.

```basic
LET t# = json_bool#(1)
LET f# = json_bool#(0)
println json_stringify$(t#)  ' Output: true
println json_stringify$(f#)  ' Output: false
```

### json_number#(value)
Creates a JSON number.

```basic
LET num# = json_number#(42.5)
println json_stringify$(num#)  ' Output: 42.5
```

### json_string#(value$)
Creates a JSON string.

```basic
LET str# = json_string#("Hello")
println json_stringify$(str#)  ' Output: "Hello"
```

---

## Serialization Functions

### json_stringify$(json#)
Converts JSON value to a compact string.

```basic
LET obj# = {"name": "John", "age": 30}
println json_stringify$(obj#)
' Output: {"name":"John","age":30}
```

### json_pretty$(json#)
Converts JSON value to formatted string with 2-space indentation.

```basic
LET obj# = {"name": "John", "age": 30}
println json_pretty$(obj#)
```

### json_pretty$(json#, indent)
Converts JSON value to formatted string with custom indentation (0-8 spaces).

```basic
LET obj# = {"name": "John"}
println json_pretty$(obj#, 4)  ' 4-space indentation
```

---

## Type Checking Functions

### json_type(json#)
Returns the type code of a JSON value.

```basic
LET obj# = {"test": 1}
LET arr# = [1, 2, 3]
LET num# = json_number#(42)

println json_type(obj#)  ' Output: 1 (object)
println json_type(arr#)  ' Output: 2 (array)
println json_type(num#)  ' Output: 4 (number)
```

### json_typename$(json#)
Returns the type name as a string.

```basic
LET obj# = {"test": 1}
println json_typename$(obj#)  ' Output: object
```

### Type Check Functions
All return 1 (true) or 0 (false):

| Function | Description |
|----------|-------------|
| `json_isobj(json#)` | Is object? |
| `json_isarr(json#)` | Is array? |
| `json_isstr(json#)` | Is string? |
| `json_isnum(json#)` | Is number? |
| `json_isbool(json#)` | Is boolean? |
| `json_isnull(json#)` | Is null? |

```basic
LET obj# = {"name": "John"}
LET arr# = [1, 2, 3]

IF json_isobj(obj#) = 1 THEN println "It is an object"
IF json_isarr(arr#) = 1 THEN println "It is an array"
```

---

## Object Access Functions

### json_get#(obj#, key$)
Gets a value by key (returns pointer).

```basic
LET obj# = {"user": {"name": "John"}}
LET user# = json_get#(obj#, "user")
println json_gets$(user#, "name")  ' Output: John
```

### json_getn(obj#, key$)
Gets a numeric value by key.

```basic
LET obj# = {"age": 30, "score": 95.5}
println json_getn(obj#, "age")    ' Output: 30
println json_getn(obj#, "score")  ' Output: 95.5
```

### json_getn(obj#, key$, default)
Gets a numeric value with default if key doesn't exist.

```basic
LET obj# = {"age": 30}
println json_getn(obj#, "age", 0)     ' Output: 30
println json_getn(obj#, "height", 0)  ' Output: 0 (default)
```

### json_gets$(obj#, key$)
Gets a string value by key.

```basic
LET obj# = {"name": "John", "city": "NYC"}
println json_gets$(obj#, "name")  ' Output: John
```

### json_gets$(obj#, key$, default$)
Gets a string value with default if key doesn't exist.

```basic
LET obj# = {"name": "John"}
println json_gets$(obj#, "name", "Unknown")   ' Output: John
println json_gets$(obj#, "email", "N/A")      ' Output: N/A
```

### json_getb(obj#, key$)
Gets a boolean value (returns 1 or 0).

```basic
LET obj# = {"active": true, "verified": false}
println json_getb(obj#, "active")    ' Output: 1
println json_getb(obj#, "verified")  ' Output: 0
```

### json_has(obj#, key$)
Checks if a key exists (returns 1 or 0).

```basic
LET obj# = {"name": "John"}
IF json_has(obj#, "name") = 1 THEN println "Has name"
IF json_has(obj#, "age") = 0 THEN println "No age"
```

---

## Object Modification Functions

### json_set#(obj#, key$, value#)
Sets a pointer value in an object.

```basic
LET obj# = json_object#()
LET inner# = {"x": 10}
LET obj# = json_set#(obj#, "data", inner#)
println json_stringify$(obj#)  ' Output: {"data":{"x":10}}
```

### json_setn#(obj#, key$, value)
Sets a numeric value.

```basic
LET obj# = json_object#()
LET obj# = json_setn#(obj#, "age", 30)
LET obj# = json_setn#(obj#, "score", 95.5)
println json_stringify$(obj#)  ' Output: {"age":30,"score":95.5}
```

### json_sets#(obj#, key$, value$)
Sets a string value.

```basic
LET obj# = json_object#()
LET obj# = json_sets#(obj#, "name", "John")
println json_stringify$(obj#)  ' Output: {"name":"John"}
```

### json_setb#(obj#, key$, value)
Sets a boolean value (non-zero = true).

```basic
LET obj# = json_object#()
LET obj# = json_setb#(obj#, "active", 1)
LET obj# = json_setb#(obj#, "deleted", 0)
println json_stringify$(obj#)  ' Output: {"active":true,"deleted":false}
```

### json_setnull#(obj#, key$)
Sets a null value.

```basic
LET obj# = json_object#()
LET obj# = json_setnull#(obj#, "data")
println json_stringify$(obj#)  ' Output: {"data":null}
```

### json_remove#(obj#, key$)
Removes a key from an object.

```basic
LET obj# = {"name": "John", "age": 30}
LET obj# = json_remove#(obj#, "age")
println json_stringify$(obj#)  ' Output: {"name":"John"}
```

### json_keys#(obj#)
Gets an array of all keys in an object.

```basic
LET obj# = {"name": "John", "age": 30}
LET keys# = json_keys#(obj#)
println json_stringify$(keys#)  ' Output: ["name","age"]
```

### json_count(obj#)
Gets the number of keys in an object.

```basic
LET obj# = {"name": "John", "age": 30}
println json_count(obj#)  ' Output: 2
```

### json_merge#(target#, source#)
Merges source object into target object.

```basic
LET obj1# = {"name": "John"}
LET obj2# = {"age": 30, "city": "NYC"}
LET obj1# = json_merge#(obj1#, obj2#)
println json_stringify$(obj1#)  ' Output: {"name":"John","age":30,"city":"NYC"}
```

---

## Array Functions

### json_len(json#)
Gets length of array (or key count for objects, string length for strings).

```basic
LET arr# = [1, 2, 3, 4, 5]
println json_len(arr#)  ' Output: 5
```

### json_item#(arr#, index)
Gets array item as pointer (0-based index).

```basic
LET arr# = [{"name": "Alice"}, {"name": "Bob"}]
LET first# = json_item#(arr#, 0)
println json_gets$(first#, "name")  ' Output: Alice
```

### json_itemn(arr#, index)
Gets array item as number.

```basic
LET arr# = [10, 20, 30]
println json_itemn(arr#, 0)  ' Output: 10
println json_itemn(arr#, 2)  ' Output: 30
```

### json_itemn(arr#, index, default)
Gets array item as number with default.

```basic
LET arr# = [10, 20]
println json_itemn(arr#, 0, 0)   ' Output: 10
println json_itemn(arr#, 99, 0)  ' Output: 0 (default)
```

### json_items$(arr#, index)
Gets array item as string.

```basic
LET arr# = ["apple", "banana", "cherry"]
println json_items$(arr#, 1)  ' Output: banana
```

### json_items$(arr#, index, default$)
Gets array item as string with default.

```basic
LET arr# = ["apple", "banana"]
println json_items$(arr#, 0, "none")   ' Output: apple
println json_items$(arr#, 99, "none")  ' Output: none
```

### json_itemb(arr#, index)
Gets array item as boolean.

```basic
LET arr# = [true, false, true]
println json_itemb(arr#, 0)  ' Output: 1
println json_itemb(arr#, 1)  ' Output: 0
```

### json_push#(arr#, value#)
Pushes a pointer value to the end of array.

```basic
LET arr# = json_array#()
LET item# = {"id": 1}
LET arr# = json_push#(arr#, item#)
println json_stringify$(arr#)  ' Output: [{"id":1}]
```

### json_pushn#(arr#, value)
Pushes a number to the array.

```basic
LET arr# = json_array#()
LET arr# = json_pushn#(arr#, 10)
LET arr# = json_pushn#(arr#, 20)
println json_stringify$(arr#)  ' Output: [10,20]
```

### json_pushs#(arr#, value$)
Pushes a string to the array.

```basic
LET arr# = json_array#()
LET arr# = json_pushs#(arr#, "hello")
LET arr# = json_pushs#(arr#, "world")
println json_stringify$(arr#)  ' Output: ["hello","world"]
```

### json_pushb#(arr#, value)
Pushes a boolean to the array.

```basic
LET arr# = json_array#()
LET arr# = json_pushb#(arr#, 1)
LET arr# = json_pushb#(arr#, 0)
println json_stringify$(arr#)  ' Output: [true,false]
```

### json_pushnull#(arr#)
Pushes null to the array.

```basic
LET arr# = [1, 2]
LET arr# = json_pushnull#(arr#)
println json_stringify$(arr#)  ' Output: [1,2,null]
```

### json_pop#(arr#)
Removes and returns the last element.

```basic
LET arr# = [1, 2, 3]
LET last# = json_pop#(arr#)
println json_value(last#)       ' Output: 3
println json_stringify$(arr#)   ' Output: [1,2]
```

### json_removeat#(arr#, index)
Removes element at specified index.

```basic
LET arr# = ["a", "b", "c"]
LET arr# = json_removeat#(arr#, 1)
println json_stringify$(arr#)  ' Output: ["a","c"]
```

---

## Path Navigation Functions

Path syntax supports dot notation and array indexing:
- `user.name` - Access object property
- `items[0]` - Access array element (0-based)
- `users[0].name` - Combined access

### json_path#(json#, path$)
Navigates to a value by path (returns pointer).

```basic
LET data# = {"user": {"profile": {"name": "John"}}}
LET name# = json_path#(data#, "user.profile.name")
println json_value$(name#)  ' Output: John
```

### json_pathn(json#, path$)
Gets number at path.

```basic
LET data# = {"scores": [95, 87, 92]}
println json_pathn(data#, "scores[0]")  ' Output: 95
```

### json_pathn(json#, path$, default)
Gets number at path with default.

```basic
LET data# = {"user": {"age": 30}}
println json_pathn(data#, "user.age", 0)     ' Output: 30
println json_pathn(data#, "user.height", 0)  ' Output: 0
```

### json_paths$(json#, path$)
Gets string at path.

```basic
LET data# = {"user": {"name": "John"}}
println json_paths$(data#, "user.name")  ' Output: John
```

### json_paths$(json#, path$, default$)
Gets string at path with default.

```basic
LET data# = {"user": {"name": "John"}}
println json_paths$(data#, "user.name", "Unknown")   ' Output: John
println json_paths$(data#, "user.email", "N/A")      ' Output: N/A
```

### json_pathb(json#, path$)
Gets boolean at path.

```basic
LET data# = {"settings": {"darkMode": true}}
println json_pathb(data#, "settings.darkMode")  ' Output: 1
```

---

## Utility Functions

### json_clone#(json#)
Creates a deep copy of a JSON value.

```basic
LET original# = {"name": "John", "scores": [1, 2, 3]}
LET copy# = json_clone#(original#)

' Modify copy without affecting original
LET copy# = json_sets#(copy#, "name", "Jane")

println json_gets$(original#, "name")  ' Output: John
println json_gets$(copy#, "name")      ' Output: Jane
```

### json_value(json#)
Gets primitive value as number.

```basic
LET num# = json_number#(42)
LET bool# = json_bool#(1)

println json_value(num#)   ' Output: 42
println json_value(bool#)  ' Output: 1
```

### json_value$(json#)
Gets primitive value as string.

```basic
LET str# = json_string#("Hello")
LET num# = json_number#(42)

println json_value$(str#)  ' Output: Hello
println json_value$(num#)  ' Output: 42
```

---

## Complete Examples

### Example 1: Building a User Profile

```basic
' Create user object using literal syntax
LET user# = {"name": "John Doe", "age": 30, "active": true}

' Add more properties
LET user# = json_sets#(user#, "email", "john@example.com")
LET user# = json_setn#(user#, "loginCount", 42)

' Add nested address
LET address# = {"street": "123 Main St", "city": "New York", "zip": "10001"}
LET user# = json_set#(user#, "address", address#)

' Add skills array
LET skills# = ["Python", "JavaScript", "SQL"]
LET user# = json_set#(user#, "skills", skills#)

' Output formatted JSON
println json_pretty$(user#)
```

### Example 2: Processing an Array of Records

```basic
' Create array of products
LET products# = [{"name": "Apple", "price": 1.50, "inStock": true}, {"name": "Banana", "price": 0.75, "inStock": true}, {"name": "Cherry", "price": 3.00, "inStock": false}]

' Calculate total value of in-stock items
LET total = 0
LET i = 0
WHILE i < json_len(products#)
  LET product# = json_item#(products#, i)
  IF json_getb(product#, "inStock") = 1 THEN
    LET total = total + json_getn(product#, "price")
  ENDIF
  LET i = i + 1
ENDWHILE

println "Total in-stock value: " + stri$(total)
```

### Example 3: Configuration File Handling

```basic
' Simulate loading config (normally from file)
LET configJson$ = "{\"appName\": \"MyApp\", \"version\": \"1.0\", \"settings\": {\"theme\": \"dark\", \"fontSize\": 14}}"
LET config# = json_parse#(configJson$)

' Read settings with defaults
LET appName$ = json_gets$(config#, "appName", "Unknown App")
LET theme$ = json_paths$(config#, "settings.theme", "light")
LET fontSize = json_pathn(config#, "settings.fontSize", 12)

println "App: " + appName$
println "Theme: " + theme$
println "Font Size: " + stri$(fontSize)

' Update a setting
LET settings# = json_get#(config#, "settings")
LET settings# = json_setn#(settings#, "fontSize", 16)

println json_pretty$(config#)
```

### Example 4: Building JSON for API Request

```basic
' Build request body
LET request# = json_object#()
LET request# = json_sets#(request#, "action", "createUser")
LET request# = json_setn#(request#, "timestamp", 1699900000)

' Add user data
LET userData# = json_object#()
LET userData# = json_sets#(userData#, "username", "johndoe")
LET userData# = json_sets#(userData#, "email", "john@example.com")
LET userData# = json_setb#(userData#, "newsletter", 1)

' Add tags array
LET tags# = json_array#()
LET tags# = json_pushs#(tags#, "new")
LET tags# = json_pushs#(tags#, "verified")
LET userData# = json_set#(userData#, "tags", tags#)

LET request# = json_set#(request#, "data", userData#)

' Output compact JSON (for API)
println json_stringify$(request#)
```

### Example 5: Iterating Over Object Keys

```basic
LET person# = {"name": "Alice", "age": 28, "city": "Boston"}

LET keys# = json_keys#(person#)
LET i = 0

println "Person properties:"
WHILE i < json_len(keys#)
  LET key$ = json_items$(keys#, i)
  LET value$ = json_gets$(person#, key$, "")
  println "  " + key$ + ": " + value$
  LET i = i + 1
ENDWHILE
```

---

## Function Quick Reference

### Creation
| Function | Returns | Description |
|----------|---------|-------------|
| `json_object#()` | # | Empty object |
| `json_array#()` | # | Empty array |
| `json_parse#($)` | # | Parse JSON string |
| `json_null#()` | # | Null value |
| `json_bool#(n)` | # | Boolean value |
| `json_number#(n)` | # | Number value |
| `json_string#($)` | # | String value |

### Serialization
| Function | Returns | Description |
|----------|---------|-------------|
| `json_stringify$(#)` | $ | Compact JSON string |
| `json_pretty$(#)` | $ | Formatted JSON (2 spaces) |
| `json_pretty$(#, n)` | $ | Formatted JSON (n spaces) |

### Type Checking
| Function | Returns | Description |
|----------|---------|-------------|
| `json_type(#)` | n | Type code (0-5) |
| `json_typename$(#)` | $ | Type name |
| `json_isobj(#)` | n | Is object? |
| `json_isarr(#)` | n | Is array? |
| `json_isstr(#)` | n | Is string? |
| `json_isnum(#)` | n | Is number? |
| `json_isbool(#)` | n | Is boolean? |
| `json_isnull(#)` | n | Is null? |

### Object Access
| Function | Returns | Description |
|----------|---------|-------------|
| `json_get#(#, $)` | # | Get value by key |
| `json_getn(#, $)` | n | Get number by key |
| `json_getn(#, $, n)` | n | Get number with default |
| `json_gets$(#, $)` | $ | Get string by key |
| `json_gets$(#, $, $)` | $ | Get string with default |
| `json_getb(#, $)` | n | Get boolean by key |
| `json_has(#, $)` | n | Key exists? |

### Object Modification
| Function | Returns | Description |
|----------|---------|-------------|
| `json_set#(#, $, #)` | # | Set pointer value |
| `json_setn#(#, $, n)` | # | Set number value |
| `json_sets#(#, $, $)` | # | Set string value |
| `json_setb#(#, $, n)` | # | Set boolean value |
| `json_setnull#(#, $)` | # | Set null value |
| `json_remove#(#, $)` | # | Remove key |
| `json_keys#(#)` | # | Get all keys |
| `json_count(#)` | n | Count keys |
| `json_merge#(#, #)` | # | Merge objects |

### Array Access
| Function | Returns | Description |
|----------|---------|-------------|
| `json_len(#)` | n | Array length |
| `json_item#(#, n)` | # | Get item as pointer |
| `json_itemn(#, n)` | n | Get item as number |
| `json_itemn(#, n, n)` | n | Get item with default |
| `json_items$(#, n)` | $ | Get item as string |
| `json_items$(#, n, $)` | $ | Get item with default |
| `json_itemb(#, n)` | n | Get item as boolean |

### Array Modification
| Function | Returns | Description |
|----------|---------|-------------|
| `json_push#(#, #)` | # | Push pointer |
| `json_pushn#(#, n)` | # | Push number |
| `json_pushs#(#, $)` | # | Push string |
| `json_pushb#(#, n)` | # | Push boolean |
| `json_pushnull#(#)` | # | Push null |
| `json_pop#(#)` | # | Pop last element |
| `json_removeat#(#, n)` | # | Remove at index |

### Path Navigation
| Function | Returns | Description |
|----------|---------|-------------|
| `json_path#(#, $)` | # | Navigate by path |
| `json_pathn(#, $)` | n | Get number at path |
| `json_pathn(#, $, n)` | n | Get number with default |
| `json_paths$(#, $)` | $ | Get string at path |
| `json_paths$(#, $, $)` | $ | Get string with default |
| `json_pathb(#, $)` | n | Get boolean at path |

### Utilities
| Function | Returns | Description |
|----------|---------|-------------|
| `json_clone#(#)` | # | Deep copy |
| `json_value(#)` | n | Get as number |
| `json_value$(#)` | $ | Get as string |
