# Plan9Basic - StdLib Documentation

## Standard Library Reference Manual

**Version:** 1.0  
**Date:** January 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Program Control Functions](#program-control-functions)
3. [Type Checking Functions](#type-checking-functions)
4. [Type Conversion Functions](#type-conversion-functions)
5. [Object Information Functions](#object-information-functions)
6. [Format Settings Functions](#format-settings-functions)
7. [Complete Examples](#complete-examples)
8. [Quick Reference](#quick-reference)

---

## Overview

The StdLib library provides essential utility functions for Plan9Basic programs. These are core functions that support:

- Program flow control (pausing, message processing)
- Type checking (detecting invalid or special values)
- Type conversion between pointers and numbers
- Object introspection
- Regional format settings configuration

This library contains functions that are fundamental to many Plan9Basic programs and work across all supported platforms.

---

## Program Control Functions

### pause()

Pauses program execution for a specified number of seconds.

**Syntax:**
```basic
pause(seconds)
```

**Parameters:**
- `seconds`: Duration to pause in **whole seconds** (integer value)

**Returns:** 0

**Example:**
```basic
println "Starting..."
pause(2)              ' Pause for 2 seconds
println "2 seconds later..."

pause(1)              ' Pause for 1 second
println "Done!"
```

**Important:** The `pause()` function only accepts whole seconds. Fractional values (like `0.5`) are truncated to zero and will not produce any delay. For sub-second timing, consider using Timer controls from the GUI library.

**Note:** During a pause, the program is blocked and will not respond to events. For responsive applications, use shorter pauses combined with `processmessages()`.

---

### processmessages()

Processes all pending system messages, allowing the application to remain responsive during long operations.

**Syntax:**
```basic
processmessages()
```

**Returns:** 1

**Example:**
```basic
' Long operation with responsive UI
for i = 1 to 1000000
    ' Do some work...
    
    ' Process messages every 1000 iterations
    if i mod 1000 = 0 then
        processmessages()
    endif
next
```

**Use Cases:**
- Keep the UI responsive during long calculations
- Allow button clicks to be processed during loops
- Prevent "application not responding" states

---

### handlemessage()

Processes a single pending system message from the message queue.

**Syntax:**
```basic
handlemessage()
```

**Returns:** 1

**Example:**
```basic
' Process one message at a time for finer control
handlemessage()
```

**Note:** `processmessages()` is generally preferred as it processes all pending messages. Use `handlemessage()` when you need more granular control over message processing.

---

## Type Checking Functions

### isnan()

Tests whether a numeric value is "Not a Number" (NaN).

**Syntax:**
```basic
result = isnan(number)
```

**Parameters:**
- `number`: Numeric value to test

**Returns:**
- `1` if the value is NaN
- `0` if the value is a valid number

**Example:**
```basic
a = 0 / 0              ' This might produce NaN
b = sqr(-1)            ' Square root of negative number

if isnan(a) = 1 then
    println "a is not a number"
endif

' Safe calculation with NaN check
value = someCalculation()
if isnan(value) = 1 then
    println "Calculation resulted in an invalid value"
    value = 0          ' Use default
endif
```

**Common NaN Sources:**
- Division of 0 by 0
- Square root of negative numbers
- Logarithm of negative numbers
- Invalid mathematical operations

---

### isinfinite()

Tests whether a numeric value represents infinity (positive or negative).

**Syntax:**
```basic
result = isinfinite(number)
```

**Parameters:**
- `number`: Numeric value to test

**Returns:**
- `1` if the value is positive or negative infinity
- `0` if the value is finite

**Example:**
```basic
a = 1 / 0              ' Division by zero produces infinity
b = -1 / 0             ' Negative infinity

if isinfinite(a) = 1 then
    println "a is infinite"
endif

' Validate calculation results
result = someCalculation()
if isinfinite(result) = 1 then
    println "Result overflow - value is infinite"
endif
```

---

### isnull()

Tests whether a string is null (empty or contains only the null character).

**Syntax:**
```basic
result = isnull(stringValue$)
```

**Parameters:**
- `stringValue$`: String to test

**Returns:**
- `1` if the string is null or contains only the null character (#0)
- `0` if the string has content

**Example:**
```basic
a$ = ""
b$ = "Hello"

if isnull(a$) = 1 then
    println "a$ is null or empty"
endif

if isnull(b$) = 0 then
    println "b$ has content: "; b$
endif
```

---

### isassigned()

Tests whether a pointer is assigned (not nil).

**Syntax:**
```basic
result = isassigned(pointerValue#)
```

**Parameters:**
- `pointerValue#`: Pointer to test

**Returns:**
- `1` if the pointer IS assigned (not nil)
- `0` if the pointer is nil

**Example:**
```basic
obj# = createSomeObject()

if isassigned(obj#) = 1 then
    println "Object was created successfully"
else
    println "Object creation failed (nil pointer)"
endif
```

---

### sign()

Returns the sign of a number.

**Syntax:**
```basic
result = sign(number)
```

**Parameters:**
- `number`: Any numeric value

**Returns:**
- `1` if number > 0
- `0` if number = 0
- `-1` if number < 0

**Example:**
```basic
println sign(42)       ' Output: 1
println sign(0)        ' Output: 0
println sign(-17)      ' Output: -1

' Use sign to determine direction
velocity = -5
direction = sign(velocity)
if direction = 1 then
    println "Moving forward"
else if direction = -1 then
    println "Moving backward"
else
    println "Stationary"
endif
```

**Note:** This function is similar to `sgn` in NumLib.

---

## Type Conversion Functions

### number()

Converts a pointer value to its numeric (integer) representation.

**Syntax:**
```basic
numericValue = number(pointerValue#)
```

**Parameters:**
- `pointerValue#`: Pointer to convert

**Returns:** Integer representation of the pointer address

**Example:**
```basic
obj# = createSomeObject()
addr = number(obj#)
println "Object address: "; addr
```

---

### pointer#()

Converts a numeric value to a pointer.

**Syntax:**
```basic
pointerValue# = pointer#(numericValue)
```

**Parameters:**
- `numericValue`: Integer value representing a memory address

**Returns:** Pointer to the specified address

**Example:**
```basic
' Store a pointer as a number and restore it
obj# = createSomeObject()
addr = number(obj#)

' Later, restore the pointer
restored# = pointer#(addr)
```

**Warning:** Use this function with extreme caution. Creating pointers from arbitrary numbers can cause crashes or undefined behavior if the address is invalid.

---

### pnttonum()

Converts a pointer to a numeric value, with nil checking.

**Syntax:**
```basic
numericValue = pnttonum(pointerValue#)
```

**Parameters:**
- `pointerValue#`: Pointer to convert

**Returns:** 
- Integer representation of the pointer address
- `0` if the pointer is nil

**Example:**
```basic
obj# = createSomeObject()
addr = pnttonum(obj#)

if addr = 0 then
    println "Pointer is nil"
else
    println "Pointer address: "; addr
endif
```

**Note:** This is safer than `number()` because it handles nil pointers gracefully.

---

## Object Information Functions

### classname$()

Returns the class name of an object referenced by a pointer.

**Syntax:**
```basic
name$ = classname$(objectPointer#)
```

**Parameters:**
- `objectPointer#`: Pointer to an object

**Returns:** String containing the class name

**Example:**
```basic
button# = createButton()
println "Object type: "; classname$(button#)
' Output might be: "TButton"

' Use for type checking
obj# = getUnknownObject()
if classname$(obj#) = "TStringList" then
    println "It's a string list"
endif
```

---

## Format Settings Functions

Plan9Basic uses the system's regional settings for formatting dates, times, and numbers. These functions allow you to customize these settings.

### formatsettings() - Set

Sets a format setting value.

**Syntax:**
```basic
result = formatsettings(settingName$, settingValue$)
```

**Parameters:**
- `settingName$`: Name of the setting (case-insensitive)
- `settingValue$`: New value for the setting

**Returns:**
- `1` if successful
- `0` if the setting name is not recognized

### formatsettings$() - Get

Gets the current value of a format setting.

**Syntax:**
```basic
value$ = formatsettings$(settingName$)
```

**Parameters:**
- `settingName$`: Name of the setting (case-insensitive)

**Returns:** Current value of the setting (empty string if not recognized)

### Available Settings

| Setting Name | Type | Description | Example |
|--------------|------|-------------|---------|
| `dateseparator` | Char | Character separating date parts | `/`, `-`, `.` |
| `timeseparator` | Char | Character separating time parts | `:`, `.` |
| `decimalseparator` | Char | Decimal point character | `.`, `,` |
| `shortdateformat` | String | Short date format pattern | `MM/dd/yyyy` |
| `longdateformat` | String | Long date format pattern | `MMMM d, yyyy` |
| `shorttimeformat` | String | Short time format pattern | `HH:mm` |
| `longtimeformat` | String | Long time format pattern | `HH:mm:ss` |
| `timeamstring` | String | AM indicator | `AM`, `am` |
| `timepmstring` | String | PM indicator | `PM`, `pm` |

**Example:**
```basic
' Get current settings
println "Date separator: "; formatsettings$("dateseparator")
println "Decimal separator: "; formatsettings$("decimalseparator")
println "Short date format: "; formatsettings$("shortdateformat")

' Change to European format
formatsettings("dateseparator", ".")
formatsettings("decimalseparator", ",")
formatsettings("shortdateformat", "dd.MM.yyyy")

println "New date separator: "; formatsettings$("dateseparator")
```

---

## Complete Examples

### Example 1: Safe Calculation with Validation

```basic
' Perform calculations with proper error checking
function safeDivide(a, b) local result
    if b = 0 then
        println "Warning: Division by zero"
        return 0
    endif
    
    result = a / b
    
    if isnan(result) = 1 then
        println "Warning: Result is NaN"
        return 0
    endif
    
    if isinfinite(result) = 1 then
        println "Warning: Result is infinite"
        return 0
    endif
    
    return result
endfunction

function safeSqrt(n) local result
    if n < 0 then
        println "Warning: Cannot take square root of negative number"
        return 0
    endif
    
    result = sqr(n)
    
    if isnan(result) = 1 then
        return 0
    endif
    
    return result
endfunction

println "=== Safe Calculation Demo ==="
println ""

println "10 / 2 = "; safeDivide(10, 2)
println "10 / 0 = "; safeDivide(10, 0)
println "sqrt(16) = "; safeSqrt(16)
println "sqrt(-4) = "; safeSqrt(-4)
```

---

### Example 2: Progress Indicator with Responsive UI

```basic
' Simulate a long operation with progress updates
println "=== Processing with Progress ==="
println ""

total = 100
for i = 1 to total
    ' Simulate work (processmessages keeps UI responsive)
    processmessages()
    
    ' Update progress every 10%
    if i mod 10 = 0 then
        println "Progress: "; i; "%"
        pause(1)  ' Brief pause to see the progress
    endif
next

println ""
println "Processing complete!"
```

---

### Example 3: Regional Format Configuration

```basic
' Configure and display format settings
println "=== Format Settings Demo ==="
println ""

' Display current settings
println "Current Settings:"
println "  Date separator: "; formatsettings$("dateseparator")
println "  Time separator: "; formatsettings$("timeseparator")
println "  Decimal separator: "; formatsettings$("decimalseparator")
println "  Short date format: "; formatsettings$("shortdateformat")
println "  AM string: "; formatsettings$("timeamstring")
println "  PM string: "; formatsettings$("timepmstring")
println ""

' Switch to European format
println "Switching to European format..."
formatsettings("dateseparator", ".")
formatsettings("shortdateformat", "dd.MM.yyyy")
formatsettings("decimalseparator", ",")

println ""
println "New Settings:"
println "  Date separator: "; formatsettings$("dateseparator")
println "  Short date format: "; formatsettings$("shortdateformat")
println "  Decimal separator: "; formatsettings$("decimalseparator")
```

---

### Example 4: Value Validation Utility

```basic
' Comprehensive value validation
function validateNumber(value) local valid
    valid = 1
    
    if isnan(value) = 1 then
        println "  - Value is NaN"
        valid = 0
    endif
    
    if isinfinite(value) = 1 then
        println "  - Value is infinite"
        valid = 0
    endif
    
    return valid
endfunction

function validateString(value$) local valid
    valid = 1
    
    if isnull(value$) = 1 then
        println "  - String is null or empty"
        valid = 0
    endif
    
    return valid
endfunction

function validatePointer(value#) local valid
    valid = 1
    
    if isassigned(value#) = 0 then
        println "  - Pointer is nil"
        valid = 0
    endif
    
    return valid
endfunction

println "=== Value Validation Demo ==="
println ""

' Test numeric validation
println "Validating 42:"
validateNumber(42)

println "Validating 0/0:"
validateNumber(0/0)

println ""

' Test string validation
println "Validating 'Hello':"
validateString("Hello")

println "Validating '':"
validateString("")
```

---

### Example 5: Countdown Timer

```basic
' Simple countdown timer
function countdown(seconds) local i
    println "Countdown starting from "; seconds; " seconds..."
    println ""
    
    for i = seconds to 1 step -1
        println i; "..."
        pause(1)
        processmessages()
    next
    
    println ""
    println "Time's up!"
    return 0
endfunction

countdown(5)
```

---

### Example 6: Number Sign Analysis

```basic
' Analyze the sign of numbers
println "=== Number Sign Analysis ==="
println ""

for i = -3 to 3
    s = sign(i)
    
    print i; " is ";
    
    if s = 1 then
        println "positive"
    else if s = -1 then
        println "negative"
    else
        println "zero"
    endif
next
```

---

## Quick Reference

### Program Control
```basic
pause(seconds)        ' Pause execution (whole seconds only)
processmessages()     ' Process all pending system messages
handlemessage()       ' Process single system message
```

### Type Checking
```basic
isnan(n)              ' Is Not-a-Number? (1=yes, 0=no)
isinfinite(n)         ' Is infinite? (1=yes, 0=no)
isnull(s$)            ' Is string null/empty? (1=yes, 0=no)
isassigned(p#)             ' Is pointer assigned? (1=assigned, 0=nil)
sign(n)               ' Sign of number: -1, 0, or 1
```

### Type Conversion
```basic
number(p#)            ' Pointer → numeric address
pointer#(n)           ' Numeric address → pointer
pnttonum(p#)          ' Pointer → numeric (nil-safe, returns 0 for nil)
```

### Object Information
```basic
classname$(p#)        ' Get class name of object
```

### Format Settings
```basic
formatsettings(name$, value$)   ' Set format setting (returns 1/0)
formatsettings$(name$)          ' Get format setting value
```

### Format Setting Names
```basic
"dateseparator"       ' Date separator character
"timeseparator"       ' Time separator character
"decimalseparator"    ' Decimal point character
"shortdateformat"     ' Short date format string
"longdateformat"      ' Long date format string
"shorttimeformat"     ' Short time format string
"longtimeformat"      ' Long time format string
"timeamstring"        ' AM indicator string
"timepmstring"        ' PM indicator string
```

---

## Notes and Best Practices

### Pause Limitations

The `pause()` function only accepts **whole seconds**. Fractional values are truncated:
- `pause(1)` → pauses for 1 second ✓
- `pause(2)` → pauses for 2 seconds ✓
- `pause(0.5)` → truncated to 0, no pause ✗
- `pause(1.9)` → truncated to 1 second

For sub-second timing or animations, use Timer controls from the GUI library instead.

### Pause and Responsiveness

When using `pause()` for extended periods, consider breaking it into smaller chunks with `processmessages()`:

```basic
' Instead of:
pause(10)  ' UI frozen for 10 seconds

' Use:
for i = 1 to 10
    pause(1)
    processmessages()
next
```

### Checking for Invalid Values

Always validate calculation results that might produce special values:

```basic
result = someCalculation()
if isnan(result) = 1 or isinfinite(result) = 1 then
    ' Handle error
    result = 0
endif
```

### Pointer Safety

When working with pointers, always check for nil before using:

```basic
obj# = getObject()
if isassigned(obj#) = 1 then
    ' Safe to use obj#
    println classname$(obj#)
else
    println "Object is nil"
endif
```

---

*End of StdLib Documentation*
