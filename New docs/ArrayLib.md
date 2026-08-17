# Plan9Basic - ArrayLib Documentation

## Array Library Reference Manual

**Version:** 2.0 Refactored  
**Date:** January 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Key Characteristics](#key-characteristics)
3. [Array Types](#array-types)
4. [Array Creation Functions](#array-creation-functions)
5. [Array Access Syntax](#array-access-syntax)
6. [Array Utility Functions](#array-utility-functions)
7. [Error Handling](#error-handling)
8. [Complete Examples](#complete-examples)
9. [Technical Notes](#technical-notes)

---

## Overview

The ArrayLib library provides comprehensive support for multi-dimensional arrays in Plan9Basic. It implements dynamic arrays that can hold numeric values, strings, or pointers, with support for up to 10 dimensions.

Arrays in Plan9Basic are **objects** stored as pointers (indicated by the `#` suffix in variable names). This design allows arrays to be passed to functions and returned from functions efficiently.

---

## Key Characteristics

| Feature | Description |
|---------|-------------|
| **Indexing** | **1-based** (traditional BASIC style) |
| **Dimensions** | 1 to 10 dimensions supported |
| **Data Types** | Numeric, String, and Pointer arrays |
| **Memory Management** | Automatic garbage collection |
| **Bounds Checking** | Runtime validation with descriptive error messages |
| **Type Safety** | Runtime type checking prevents mixing array types |

### Important: 1-Based Indexing

Unlike many modern languages that use 0-based indexing, Plan9Basic arrays use **1-based indexing** to maintain compatibility with traditional BASIC:

```basic
arr# = dim#(5)        ' Creates a numeric array with indices 1, 2, 3, 4, 5
arr#[1] = 10          ' First element
arr#[5] = 50          ' Last element
arr#[0] = 99          ' ERROR: Index out of bounds!
```

---

## Array Types

Plan9Basic supports three distinct array types:

### 1. Numeric Arrays

Store floating-point numbers (Extended precision).

```basic
' Created with dim#()
numbers# = dim#(10)
numbers#[1] = 3.14159
numbers#[2] = -42.5
```

### 2. String Arrays

Store text strings of any length.

```basic
' Created with sdim#()
names# = sdim#(5)
names#$[1] = "Alice"
names#$[2] = "Bob"
```

### 3. Pointer Arrays

Store references to other objects (other arrays, dictionaries, etc.).

```basic
' Created with pdim#()
objects# = pdim#(3)
objects##[1] = dim#(10)      ' Store a numeric array
objects##[2] = sdim#(5)      ' Store a string array
```

---

## Array Creation Functions

### dim#() - Create Numeric Array

Creates a new numeric array with the specified dimensions.

**Syntax:**
```basic
arrayPointer# = dim#(size1 [, size2, ..., size10])
```

**Parameters:**
- `size1` to `size10`: The size of each dimension (must be ≥ 1)

**Returns:**
- A pointer to the newly created numeric array

**Initial Values:**
- All elements are initialized to `0`

**Examples:**

```basic
' 1-dimensional array (vector) with 10 elements
vector# = dim#(10)

' 2-dimensional array (matrix) 3x4
matrix# = dim#(3, 4)

' 3-dimensional array 2x3x4
cube# = dim#(2, 3, 4)

' Maximum 10 dimensions
hypercube# = dim#(2, 2, 2, 2, 2, 2, 2, 2, 2, 2)
```

---

### sdim#() - Create String Array

Creates a new string array with the specified dimensions.

**Syntax:**
```basic
arrayPointer# = sdim#(size1 [, size2, ..., size10])
```

**Parameters:**
- `size1` to `size10`: The size of each dimension (must be ≥ 1)

**Returns:**
- A pointer to the newly created string array

**Initial Values:**
- All elements are initialized to empty string `""`

**Examples:**

```basic
' 1-dimensional string array with 5 elements
names# = sdim#(5)

' 2-dimensional string array (grid of strings) 10x10
grid# = sdim#(10, 10)

' Store a table of data (3 columns, 100 rows)
table# = sdim#(100, 3)
```

---

### pdim#() - Create Pointer Array

Creates a new pointer array with the specified dimensions. This is useful for creating arrays of arrays (jagged arrays) or arrays of other objects.

**Syntax:**
```basic
arrayPointer# = pdim#(size1 [, size2, ..., size10])
```

**Parameters:**
- `size1` to `size10`: The size of each dimension (must be ≥ 1)

**Returns:**
- A pointer to the newly created pointer array

**Initial Values:**
- All elements are initialized to `nil` (null pointer)

**Examples:**

```basic
' Array to hold 5 objects
containers# = pdim#(5)

' Store different arrays in each slot
containers##[1] = dim#(100)       ' A numeric array
containers##[2] = sdim#(50)       ' A string array
containers##[3] = pdim#(10)       ' Another pointer array

' Jagged array (array of arrays with different sizes)
jagged# = pdim#(3)
jagged##[1] = dim#(10)            ' First row has 10 elements
jagged##[2] = dim#(20)            ' Second row has 20 elements
jagged##[3] = dim#(5)             ' Third row has 5 elements
```

---

## Array Access Syntax

Plan9Basic provides intuitive syntax for accessing array elements using square brackets `[ ]`.

### Numeric Array Access

**Reading values:**
```basic
arr# = dim#(5, 5)
value = arr#[2, 3]        ' Read element at row 2, column 3
```

**Writing values:**
```basic
arr# = dim#(5, 5)
arr#[2, 3] = 42           ' Set element at row 2, column 3 to 42
```

**Internal function calls:**
- Reading: `arr#[i, j]` → internally calls `narr_get(arr#, i, j)`
- Writing: `arr#[i, j] = v` → internally calls `narr_set#(arr#, i, j, v)`

---

### String Array Access

String arrays use the `#$` suffix notation:

**Reading values:**
```basic
names# = sdim#(10)
name$ = names#$[3]        ' Read string at index 3
```

**Writing values:**
```basic
names# = sdim#(10)
names#$[3] = "Charlie"    ' Set string at index 3
```

**Internal function calls:**
- Reading: `arr#$[i]` → internally calls `sarr_get$(arr#, i)`
- Writing: `arr#$[i] = s$` → internally calls `sarr_set#(arr#, i, s$)`

---

### Pointer Array Access

Pointer arrays use the `##` suffix notation:

**Reading values:**
```basic
objects# = pdim#(5)
obj# = objects##[2]       ' Read pointer at index 2
```

**Writing values:**
```basic
objects# = pdim#(5)
objects##[2] = somePtr#   ' Set pointer at index 2
```

**Internal function calls:**
- Reading: `arr##[i]` → internally calls `parr_get#(arr#, i)`
- Writing: `arr##[i] = p#` → internally calls `parr_set#(arr#, i, p#)`

---

## Array Utility Functions

### ndims() - Get Number of Dimensions

Returns the number of dimensions of an array.

**Syntax:**
```basic
count = ndims(arrayPointer#)
```

**Parameters:**
- `arrayPointer#`: Pointer to any array type

**Returns:**
- Number of dimensions (1 to 10)

**Example:**
```basic
vector# = dim#(10)
matrix# = dim#(5, 5)
cube# = dim#(3, 4, 5)

print ndims(vector#)    ' Output: 1
print ndims(matrix#)    ' Output: 2
print ndims(cube#)      ' Output: 3
```

---

### ubound() - Get Upper Bound of Dimension

Returns the upper bound (maximum valid index) for a specified dimension.

**Syntax:**
```basic
upperBound = ubound(arrayPointer#, dimension)
```

**Parameters:**
- `arrayPointer#`: Pointer to any array type
- `dimension`: The dimension number (1-based)

**Returns:**
- The size of the specified dimension

**Example:**
```basic
matrix# = dim#(10, 20)

print ubound(matrix#, 1)    ' Output: 10 (rows)
print ubound(matrix#, 2)    ' Output: 20 (columns)
```

---

### lbound() - Get Lower Bound of Dimension

Returns the lower bound (minimum valid index) for a specified dimension. In Plan9Basic, this is **always 1** due to 1-based indexing.

**Syntax:**
```basic
lowerBound = lbound(arrayPointer#, dimension)
```

**Parameters:**
- `arrayPointer#`: Pointer to any array type
- `dimension`: The dimension number (1-based)

**Returns:**
- Always returns `1`

**Example:**
```basic
arr# = dim#(10, 20)

print lbound(arr#, 1)    ' Output: 1
print lbound(arr#, 2)    ' Output: 1
```

**Note:** While `lbound()` always returns 1 in Plan9Basic, it's included for compatibility with BASIC conventions and for writing portable code patterns.

---

### arraysize() - Get Total Number of Elements

Returns the total number of elements in an array (product of all dimensions).

**Syntax:**
```basic
totalElements = arraysize(arrayPointer#)
```

**Parameters:**
- `arrayPointer#`: Pointer to any array type

**Returns:**
- Total number of elements

**Example:**
```basic
vector# = dim#(10)
matrix# = dim#(5, 4)
cube# = dim#(2, 3, 4)

print arraysize(vector#)    ' Output: 10
print arraysize(matrix#)    ' Output: 20 (5 × 4)
print arraysize(cube#)      ' Output: 24 (2 × 3 × 4)
```

---

### arraytype() - Get Array Type Code

Returns a numeric code indicating the type of array.

**Syntax:**
```basic
typeCode = arraytype(arrayPointer#)
```

**Parameters:**
- `arrayPointer#`: Pointer to any array type

**Returns:**
- `0` = Numeric array
- `1` = String array
- `2` = Pointer array

**Example:**
```basic
numArr# = dim#(10)
strArr# = sdim#(10)
ptrArr# = pdim#(10)

print arraytype(numArr#)    ' Output: 0
print arraytype(strArr#)    ' Output: 1
print arraytype(ptrArr#)    ' Output: 2
```

---

### arr_free() - Free Array

Explicitly frees an array and removes it from the garbage collector. Useful to immediately release large arrays when they are no longer needed.

**Syntax:**
```basic
result = arr_free(arrayPointer#)
```

**Returns:** 1 on success, 0 if array was nil or invalid.

**Note:** Arrays are automatically garbage-collected by Plan9Basic, so calling `arr_free()` is optional. It is useful when you want to immediately release memory from a large array rather than waiting for the next GC cycle.

**Example:**
```basic
data# = dim#(1000000)
' ... work with data ...
let freed = arr_free(data#)   ' Release memory immediately
```

---

### arraytypename$() - Get Array Type Name

Returns a human-readable string describing the array type.

**Syntax:**
```basic
typeName$ = arraytypename$(arrayPointer#)
```

**Parameters:**
- `arrayPointer#`: Pointer to any array type

**Returns:**
- `"numeric"` for numeric arrays
- `"string"` for string arrays
- `"pointer"` for pointer arrays

**Example:**
```basic
numArr# = dim#(10)
strArr# = sdim#(10)
ptrArr# = pdim#(10)

print arraytypename$(numArr#)    ' Output: numeric
print arraytypename$(strArr#)    ' Output: string
print arraytypename$(ptrArr#)    ' Output: pointer
```

---

## Error Handling

The ArrayLib functions perform comprehensive validation and provide descriptive error messages:

### Dimension Errors

```basic
' Error: Dimension must be >= 1
arr# = dim#(0)           ' ERROR: Dimension 1 must be >= 1, got 0

' Error: Too many dimensions
arr# = dim#(1,1,1,1,1,1,1,1,1,1,1)  ' ERROR: dim# supports maximum 10 dimensions
```

### Index Errors

```basic
arr# = dim#(5)

arr#[0] = 10             ' ERROR: Index 1 out of bounds: 0 (valid: 1..5)
arr#[6] = 10             ' ERROR: Index 1 out of bounds: 6 (valid: 1..5)
```

### Dimension Mismatch Errors

```basic
matrix# = dim#(3, 4)

' Accessing with wrong number of indices
value = matrix#[1]       ' ERROR: Dimension mismatch: array has 2 dimensions, got 1 indices
value = matrix#[1,2,3]   ' ERROR: Dimension mismatch: array has 2 dimensions, got 3 indices
```

### Type Mismatch Errors

```basic
strArr# = sdim#(10)

' Trying to read as numeric array
value = strArr#[1]       ' ERROR: Expected numeric array, got string array
```

### Null Pointer Errors

```basic
arr# = 0   ' null pointer

value = arr#[1]          ' ERROR: Null array pointer
```

---

## Complete Examples

### Example 1: Simple Vector Operations

```basic
' Create a vector of 10 numbers
vector# = dim#(10)

' Fill with squares
for i = 1 to 10
    vector#[i] = i * i
next

' Print all values
print "Squares from 1 to 10:"
for i = 1 to 10
    print i; " squared = "; vector#[i]
next

' Calculate sum
sum = 0
for i = 1 to ubound(vector#, 1)
    sum = sum + vector#[i]
next
print "Sum of squares: "; sum
```

### Example 2: 2D Matrix Operations

```basic
' Create a 3x3 matrix
rows = 3
cols = 3
matrix# = dim#(rows, cols)

' Fill with multiplication table
for r = 1 to rows
    for c = 1 to cols
        matrix#[r, c] = r * c
    next
next

' Print the matrix
print "Multiplication Table:"
for r = 1 to rows
    for c = 1 to cols
        print matrix#[r, c]; " ";
    next
    print   ' New line
next
```

### Example 3: String Array - Name List

```basic
' Create a list of names
names# = sdim#(5)

' Populate
names#$[1] = "Alice"
names#$[2] = "Bob"
names#$[3] = "Charlie"
names#$[4] = "Diana"
names#$[5] = "Eve"

' Print with numbering
print "Name List:"
for i = 1 to ubound(names#, 1)
    print i; ". "; names#$[i]
next
```

### Example 4: Pointer Array - Array of Arrays (Jagged Array)

```basic
' Create a jagged array (triangle pattern)
triangle# = pdim#(5)

' Each row has increasing number of elements
for row = 1 to 5
    triangle##[row] = dim#(row)
    
    ' Fill each row
    rowArray# = triangle##[row]
    for col = 1 to row
        rowArray#[col] = row * 10 + col
    next
next

' Print the triangle
print "Triangle Array:"
for row = 1 to 5
    rowArray# = triangle##[row]
    for col = 1 to ubound(rowArray#, 1)
        print rowArray#[col]; " ";
    next
    print   ' New line
next
```

### Example 5: Array Information Function

```basic
' Function to display array information
function showArrayInfo(arr#) local d
    println "Array Information:"
    println "  Type: "; arraytypename$(arr#)
    println "  Dimensions: "; ndims(arr#)
    println "  Total elements: "; arraysize(arr#)
    
    println "  Dimension sizes:"
    for d = 1 to ndims(arr#)
        println "    Dimension "; d; ": "; lbound(arr#, d); " to "; ubound(arr#, d)
    next
endfunction

' Test with different arrays
numArr# = dim#(10, 20, 30)
showArrayInfo(numArr#)

println ""

strArr# = sdim#(5, 5)
showArrayInfo(strArr#)
```

### Example 6: 3D Array - RGB Color Cube

```basic
' Create a 256x256x3 array for RGB image data
' (simplified example with smaller dimensions)
width = 10
height = 10
channels = 3    ' R, G, B

image# = dim#(width, height, channels)

' Fill with gradient pattern
for x = 1 to width
    for y = 1 to height
        ' Red channel increases with x
        image#[x, y, 1] = (x - 1) * 25
        ' Green channel increases with y
        image#[x, y, 2] = (y - 1) * 25
        ' Blue channel is constant
        image#[x, y, 3] = 128
    next
next

' Print pixel at center
cx = 5
cy = 5
print "Pixel at ("; cx; ","; cy; "):"
print "  R="; image#[cx, cy, 1]
print "  G="; image#[cx, cy, 2]
print "  B="; image#[cx, cy, 3]
```

---

## Technical Notes

### Memory Management

Arrays are automatically managed by Plan9Basic's garbage collector. You don't need to manually free arrays - they will be collected when no longer referenced.

```basic
' Arrays are automatically garbage collected
function createTempArray() local temp#
    temp# = dim#(1000)
    ' ... use temp# ...
    return 0
endfunction
' After function returns, temp# is eligible for garbage collection
```

### Internal Function Signatures

For advanced users, here are the internal function signatures registered in the library:

| Function | Signature Pattern | Description |
|----------|-------------------|-------------|
| `dim#` | `dim#@n`, `dim#@nn`, ... `dim#@nnnnnnnnnn` | Create numeric array |
| `sdim#` | `sdim#@n`, `sdim#@nn`, ... | Create string array |
| `pdim#` | `pdim#@n`, `pdim#@nn`, ... | Create pointer array |
| `narr_get` | `narr_get@#n`, `narr_get@#nn`, ... | Get from numeric array |
| `narr_set#` | `narr_set#@#nn`, `narr_set#@#nnn`, ... | Set in numeric array |
| `sarr_get$` | `sarr_get$@#n`, `sarr_get$@#nn`, ... | Get from string array |
| `sarr_set#` | `sarr_set#@#n$`, `sarr_set#@#nn$`, ... | Set in string array |
| `parr_get#` | `parr_get#@#n`, `parr_get#@#nn`, ... | Get from pointer array |
| `parr_set#` | `parr_set#@#n#`, `parr_set#@#nn#`, ... | Set in pointer array |
| `ndims` | `ndims@#` | Get dimension count |
| `ubound` | `ubound@#n` | Get upper bound |
| `lbound` | `lbound@#n` | Get lower bound |
| `arraysize` | `arraysize@#` | Get total size |
| `arraytype` | `arraytype@#` | Get type code |
| `arraytypename$` | `arraytypename$@#` | Get type name |
| `arr_free` | `arr_free@#` | Explicitly free array |

### Performance Considerations

1. **Multi-dimensional vs. Single-dimensional**: Accessing elements in multi-dimensional arrays requires index calculation. For maximum performance in tight loops, consider using a single-dimensional array with manual index calculation.
2. **Array Reuse**: Instead of creating new arrays repeatedly, consider reusing existing arrays when possible.
3. **Dimension Limits**: While 10 dimensions are supported, most practical applications use 1-3 dimensions. Higher dimensions have proportionally more index calculation overhead.

---

## Quick Reference Card

### Array Creation
```basic
numArray#  = dim#(size1, size2, ...)      ' Numeric array
strArray#  = sdim#(size1, size2, ...)     ' String array
ptrArray#  = pdim#(size1, size2, ...)     ' Pointer array
```

### Array Access
```basic
value     = arr#[i, j, ...]               ' Get numeric
arr#[i, j, ...] = value                   ' Set numeric

text$     = arr#$[i, j, ...]              ' Get string
arr#$[i, j, ...] = text$                  ' Set string

ptr#      = arr##[i, j, ...]              ' Get pointer
arr##[i, j, ...] = ptr#                   ' Set pointer
```

### Array Information
```basic
dims      = ndims(arr#)                   ' Number of dimensions
upper     = ubound(arr#, dim)             ' Upper bound of dimension
lower     = lbound(arr#, dim)             ' Lower bound (always 1)
total     = arraysize(arr#)               ' Total elements
typeCode  = arraytype(arr#)               ' Type: 0=num, 1=str, 2=ptr
typeName$ = arraytypename$(arr#)          ' "numeric", "string", "pointer"
freed     = arr_free(arr#)               ' Explicitly free (1=success)
```

---

*End of ArrayLib Documentation*
