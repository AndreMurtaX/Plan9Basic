# Plan9Basic User Guide

## Introduction

**Plan9Basic** is a small and simple programming language inspired by classic BASIC, designed for creating small applications called *applets*. It combines the simplicity and accessibility of traditional BASIC with modern structured programming features.

Plan9Basic is ideal for:
- Learning programming concepts
- Creating simple utilities, games and tools
- Building interactive applications
- Rapid prototyping

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Program Structure](#program-structure)
3. [Data Types](#data-types)
4. [Variables](#variables)
5. [Operators](#operators)
6. [Control Structures](#control-structures)
7. [Functions and Subroutines](#functions-and-subroutines)
8. [Arrays](#arrays)
9. [String Operations](#string-operations)
10. [Input and Output](#input-and-output)
11. [Advanced Features](#advanced-features)
12. [Complete Examples](#complete-examples)

---

## Getting Started

### Your First Program

```basic
' My first Plan9Basic program
PRINTLN "Hello, World!"
```

This simple program displays "Hello, World!" on the output screen. Let's break it down:
- The apostrophe (`'`) starts a comment - text that the language parser ignores
- `PRINTLN` displays text and moves to the next line
- Text inside double quotes is called a *string*

### A More Interactive Example

```basic
' A simple greeting program
name$ = "User"
PRINTLN "Welcome to Plan9Basic, " + name$ + "!"
PRINTLN "Let's do some math:"
PRINTLN "2 + 2 = "; 2 + 2
PRINTLN "10 * 5 = "; 10 * 5
```

---

## Program Structure

### Lines and Statements

Plan9Basic programs are composed of statements. You can write one statement per line:

```basic
x = 10
y = 20
PRINTLN x + y
```

Or multiple statements on the same line, separated by colons (`:`):

```basic
x = 10 : y = 20 : PRINTLN x + y
```

### Comments

Comments help document your code. They are ignored during execution.

```basic
' This is a comment (single quote)
REM This is also a comment (REM keyword)

x = 10  ' Comments can appear after statements
```

### Labels

Labels mark positions in your code for use with `GOTO` and `GOSUB`:

```basic
' Numeric labels (traditional BASIC style)
10 PRINTLN "Line 10"
20 PRINTLN "Line 20"

' Named labels (more readable)
start:
  PRINTLN "Beginning of program"
  
finish:
  PRINTLN "End of program"
```

### Program Termination

Use `END` to explicitly terminate your program:

```basic
PRINTLN "This will be displayed"
END
PRINTLN "This will never be displayed"
```

---

## Data Types

Plan9Basic supports three fundamental data types. Note that, like classic 8-bit BASIC interpreters, **there is no boolean type** — conditional logic is handled directly by control structures.

### Numbers

Numbers can be integers or floating-point values:

```basic
count = 42           ' Integer
pi = 3.14159         ' Floating-point
big = 1.5e10         ' Scientific notation (1.5 × 10¹⁰)
small = .5           ' Can omit leading zero (equals 0.5)
negative = -273.15   ' Negative numbers
```

### Strings

Strings are sequences of characters, identified by the `$` suffix:

```basic
name$ = "Alice"
greeting$ = "Hello, World!"
empty$ = ""
```

**Escape Sequences** allow special characters in strings:

| Sequence | Meaning |
|----------|---------|
| `\"` | Double quote |
| `\\` | Backslash |
| `\n` | New line (LF) |
| `\r` | Carriage return (CR) |
| `\t` | Tab |
| `\0` | Null character |

```basic
quote$ = "She said \"Hello!\""
path$ = "C:\\Users\\Documents"
multiline$ = "Line 1\nLine 2"
```

### Pointers

Pointers reference complex objects like arrays, identified by the `#` suffix:

```basic
myArray# = dim#(10)      ' Create an array of 10 elements
myDict# = dict_new#(0)   ' Create a dictionary (if available)
```

---

## Variables

### Naming Rules

Variable names must:
- Start with a letter (A-Z, a-z) or underscore (_)
- Contain only letters, numbers, and underscores
- End with `$` for strings or `#` for pointers
- Must not be a reserved word

```basic
' Valid variable names
count = 0
userName$ = "John"
myArray# = dim#(5)
_temp = 100
player1Score = 0

' Invalid variable names (these would cause errors)
' 1stPlace = 0     ' Cannot start with number
' my-var = 0       ' Cannot contain hyphen
' for = 10         ' Cannot use reserved words
```

### Variable Types

The suffix determines the variable type:

| Suffix | Type | Example |
|--------|------|---------|
| (none) | Number | `count`, `total`, `x` |
| `$` | String | `name$`, `text$`, `msg$` |
| `#` | Pointer | `arr#`, `obj#`, `data#` |

### Global vs Local Variables

By default, all variables are **global** (accessible everywhere):

```basic
x = 10

FUNCTION showX()
  PRINTLN x    ' Can access global x
ENDFUNCTION

showX()        ' Displays: 10
```

Use `LOCAL` to declare **local variables** inside functions:

```basic
FUNCTION calculate(a, b) LOCAL temp, result
  temp = a + b
  result = temp * 2
  RETURN result
ENDFUNCTION
```

**Important:** Unlike other well-known programming languages, Plan9Basic does not differentiate between uppercase and lowercase characters when forming variables or reserved words.

' The lines below refer to the same variable.
```basic
count = 0 ' count = 0
Count = 10 ' count = 10
COUNT = 20 ' count = 20
userName$ = "John" ' username$ = John
UserName$ = "John" ' username$ = John
USERNAME$ = "John" ' username$ = John

' Both syntaxes for the FOR command are valid.
for i = 1 to 10
...
FOR i = 1 TO 10 ' It is equivalent of the syntax above.
...
```

---

## Operators

### Arithmetic Operators

| Operator | Description | Example | Result |
|----------|-------------|---------|--------|
| `+` | Addition | `5 + 3` | `8` |
| `-` | Subtraction | `5 - 3` | `2` |
| `*` | Multiplication | `5 * 3` | `15` |
| `/` | Division | `15 / 3` | `5` |
| `MOD` | Modulo (remainder) | `17 MOD 5` | `2` |
| `^` | Power (exponentiation) | `2 ^ 3` | `8` |
| `?>` | Maximum | `5 ?> 3` | `5` |
| `?<` | Minimum | `5 ?< 3` | `3` |

```basic
' Arithmetic examples
sum = 10 + 5           ' 15
difference = 10 - 5    ' 5
product = 10 * 5       ' 50
quotient = 10 / 4      ' 2.5
remainder = 10 MOD 3   ' 1
power = 2 ^ 10         ' 1024
bigger = 7 ?> 12       ' 12
smaller = 7 ?< 12      ' 7
```

### Comparison Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `=` | Equal to | `IF x = 5 THEN` |
| `<>` | Not equal to | `IF x <> 5 THEN` |
| `<` | Less than | `IF x < 5 THEN` |
| `>` | Greater than | `IF x > 5 THEN` |
| `<=` | Less than or equal | `IF x <= 5 THEN` |
| `>=` | Greater than or equal | `IF x >= 5 THEN` |

**Important:** Comparison operators can only be used within conditional statements (`IF`, `WHILE`, `UNTIL`, etc.). Unlike some languages, you cannot use comparisons as standalone expressions:

```basic
' INVALID - comparisons cannot be used outside conditionals
' result = (5 = 5)     ' This does NOT work
' PRINTLN 5 > 3        ' This does NOT work

' VALID - comparisons inside conditionals
IF 5 = 5 THEN PRINTLN "Equal"
IF 5 > 3 THEN PRINTLN "Greater"
```

### Logical Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `AND` | Logical AND | `IF a > 0 AND b > 0 THEN` |
| `OR` | Logical OR | `IF a = 0 OR b = 0 THEN` |
| `NOT` | Logical NOT | `IF NOT x = 0 THEN` |

**Important:** Parentheses can only be used in arithmetic expressions, NOT in logical expressions. This is similar to classic 8-bit BASIC interpreters.

```basic
x = 5
y = 10

IF x > 0 AND y > 0 THEN
  PRINTLN "Both positive"
ENDIF

IF x = 0 OR y = 0 THEN
  PRINTLN "At least one is zero"
ENDIF

' Correct way to use NOT:
IF NOT x = y THEN
  PRINTLN "x and y are different"
ENDIF

' INVALID - parentheses not allowed in logical expressions:
' IF NOT (x = y) THEN     ' This does NOT work!
' IF (x > 0) AND (y > 0) THEN   ' This does NOT work!
```

### String Operators

| Operator | Description | Example | Result |
|----------|-------------|---------|--------|
| `+` | Concatenation | `"Hello" + " World"` | `"Hello World"` |
| `/` | Concatenate with newline | `"Line1" / "Line2"` | `"Line1\nLine2"` |
| `-` | Remove characters from end | `"Hello" - 2` | `"Hel"` |

```basic
first$ = "Hello"
second$ = "World"

combined$ = first$ + ", " + second$ + "!"
PRINTLN combined$   ' Hello, World!

' Multi-line string
poem$ = "Roses are red" / "Violets are blue"
PRINTLN poem$
' Output:
' Roses are red
' Violets are blue

' Truncate string
word$ = "Programming"
short$ = word$ - 4
PRINTLN short$   ' Program
```

### Operator Precedence

From highest to lowest:
1. `^` (power)
2. `*`, `/`, `MOD`
3. `+`, `-`, `?>`, `?<`
4. `=`, `<>`, `<`, `>`, `<=`, `>=`
5. `NOT`
6. `AND`
7. `OR`

Use parentheses to control evaluation order in **arithmetic expressions only**:

```basic
result = 2 + 3 * 4      ' 14 (multiplication first)
result = (2 + 3) * 4    ' 20 (parentheses first)

' In logical expressions, parentheses are NOT allowed
' The order is determined by operator precedence
IF x > 0 AND y > 0 OR z > 0 THEN   ' AND is evaluated before OR
```

---

## Control Structures

### IF...THEN...ELSE...ENDIF

**Single-line IF:**

```basic
IF score >= 60 THEN PRINTLN "Passed!"
```

**Multi-line IF:**

```basic
IF score >= 60 THEN
  PRINTLN "Passed!"
ENDIF
```

**IF with ELSE:**

```basic
IF score >= 60 THEN
  PRINTLN "Passed!"
ELSE
  PRINTLN "Failed."
ENDIF
```

**IF with ELSE IF:**

```basic
IF score >= 90 THEN
  PRINTLN "Grade: A"
ELSE IF score >= 80 THEN
  PRINTLN "Grade: B"
ELSE IF score >= 70 THEN
  PRINTLN "Grade: C"
ELSE IF score >= 60 THEN
  PRINTLN "Grade: D"
ELSE
  PRINTLN "Grade: F"
ENDIF
```

**Inline GOTO with IF:**

```basic
IF x < 0 THEN 100    ' Jump to label 100 if x is negative

PRINTLN "x is non-negative"
GOTO 200

100 PRINTLN "x is negative"
200 PRINTLN "Done"
```

### FOR...NEXT

The FOR loop repeats a block a specific number of times:

```basic
' Count from 1 to 10
FOR i = 1 TO 10
  PRINTLN i
NEXT

' Count by twos
FOR i = 0 TO 20 STEP 2
  PRINTLN i   ' 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20
NEXT

' Count backwards
FOR i = 10 TO 1 STEP -1
  PRINTLN i   ' 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
NEXT
```

You can also use `ENDFOR` or `END FOR` instead of `NEXT`:

```basic
FOR i = 1 TO 5
  PRINTLN "Iteration "; i
ENDFOR
```

### WHILE...ENDWHILE

The WHILE loop repeats while a condition is true:

```basic
count = 0
WHILE count < 5
  PRINTLN count
  count = count + 1
END WHILE
```

### REPEAT...UNTIL

The REPEAT loop executes at least once and repeats until a condition is true:

```basic
count = 0
REPEAT
  PRINTLN count
  count = count + 1
UNTIL count >= 5
```

### DO...LOOP

The DO loop offers flexible loop control:

**Infinite loop (use BREAK to exit):**

```basic
DO
  PRINTLN "This repeats forever"
  IF someCondition THEN BREAK
LOOP

' The code below works
LET i = 0
DO
  PRINTLN i
  IF i >= 10 THEN break
  LET i = i + 1
LOOP
```

**Pre-tested with WHILE:**

```basic
count = 0
DO WHILE count < 5
  PRINTLN count
  count = count + 1
LOOP
```

**Pre-tested with UNTIL:**

```basic
count = 0
DO UNTIL count >= 5
  PRINTLN count
  count = count + 1
LOOP
```

**Post-tested with WHILE:**

```basic
count = 0
DO
  PRINTLN count
  count = count + 1
LOOP WHILE count < 5
```

**Post-tested with UNTIL:**

```basic
count = 0
DO
  PRINTLN count
  count = count + 1
LOOP UNTIL count >= 5
```

### SELECT CASE

SELECT CASE provides multi-way branching:

```basic
grade$ = "B"

SELECT CASE grade$
  CASE "A"
    PRINTLN "Excellent!"
  CASE "B"
    PRINTLN "Good job!"
  CASE "C"
    PRINTLN "Satisfactory"
  CASE "D", "F"
    PRINTLN "Needs improvement"
  CASE ELSE
    PRINTLN "Invalid grade"
ENDSELECT
```

Works with numbers too:

```basic
day = 3

SELECT CASE day
  CASE 1
    PRINTLN "Monday"
  CASE 2
    PRINTLN "Tuesday"
  CASE 3
    PRINTLN "Wednesday"
  CASE 4
    PRINTLN "Thursday"
  CASE 5
    PRINTLN "Friday"
  CASE 6, 7
    PRINTLN "Weekend!"
  CASE ELSE
    PRINTLN "Invalid day"
ENDSELECT
```

### BREAK and CONTINUE

**BREAK** exits a loop immediately:

```basic
FOR i = 1 TO 100
  IF i > 10 THEN BREAK
  PRINTLN i
NEXT
' Only prints 1 through 10
```

**CONTINUE** skips to the next iteration:

```basic
FOR i = 1 TO 10
  IF i MOD 2 = 0 THEN CONTINUE
  PRINTLN i
NEXT
' Prints only odd numbers: 1, 3, 5, 7, 9
```

### GOTO and GOSUB

**GOTO** jumps to a label unconditionally:

```basic
PRINTLN "Start"
GOTO skip
PRINTLN "This is skipped"
skip:
PRINTLN "End"
```

**GOSUB** calls a subroutine and RETURN comes back:

```basic
PRINTLN "Main program start"
GOSUB greet
PRINTLN "Main program end"
END

greet:
  PRINTLN "Hello from subroutine!"
  RETURN
```

### ON...GOTO and ON...GOSUB

Branch based on a numeric value:

```basic
choice = 2

ON choice GOTO 100, 200, 300
PRINTLN "Choice was not 1, 2, or 3"
GOTO done

100 PRINTLN "You chose 1" : GOTO done
200 PRINTLN "You chose 2" : GOTO done
300 PRINTLN "You chose 3" : GOTO done

done:
PRINTLN "Done"
```

Named labels also work:

```basic
choice = 2
ON choice GOTO first, second, third
GOTO done

first:
  PRINTLN "You chose 1"
  GOTO done
second:
  PRINTLN "You chose 2"
  GOTO done
third:
  PRINTLN "You chose 3"
  GOTO done

done:
PRINTLN "Done"
```

```basic
menuChoice = 2
ON menuChoice GOSUB option1, option2, option3
END

option1:
  PRINTLN "Option 1 selected"
  RETURN

option2:
  PRINTLN "Option 2 selected"
  RETURN

option3:
  PRINTLN "Option 3 selected"
  RETURN
```

You can also use numeric labels:

```basic
menuChoice = 2
ON menuChoice GOSUB 100, 200, 300
END

100 PRINTLN "Option 1 selected" : RETURN
200 PRINTLN "Option 2 selected" : RETURN
300 PRINTLN "Option 3 selected" : RETURN
```

---

## Functions (Subroutines)

### Defining Functions

Functions encapsulate reusable code and can return values:

**Numeric function:**

```basic
FUNCTION square(n)
  RETURN n * n
ENDFUNCTION

result = square(5)
PRINTLN result   ' 25
```

**String function (suffix `$`):**

```basic
FUNCTION greet$(name$)
  RETURN "Hello, " + name$ + "!"
ENDFUNCTION

message$ = greet$("World")
PRINTLN message$   ' Hello, World!
```

**Pointer function (suffix `#`):**

```basic
CLS
FUNCTION createArray#(size)
  RETURN dim#(size)
ENDFUNCTION

myArr# = createArray#(10)
myArr#[1] = 10
myArr#[2] = 20
myArr#[3] = 30
myArr#[4] = 40
myArr#[5] = 50
myArr#[6] = 60
myArr#[7] = 70
myArr#[8] = 80
myArr#[9] = 90
myArr#[10] = 100

PRINTLN myArr#[8]
END
```

### Parameters

Functions can accept multiple parameters:

```basic
FUNCTION add(a, b)
  RETURN a + b
ENDFUNCTION

FUNCTION fullName$(first$, last$)
  RETURN first$ + " " + last$
ENDFUNCTION

PRINTLN add(3, 4)                    ' 7
PRINTLN fullName$("John", "Doe")     ' John Doe
```

### Local Variables

Use `LOCAL` to declare variables that exist only within the function:

```basic
FUNCTION calculate(x, y) LOCAL temp, sum
  temp = x * 2
  sum = temp + y
  RETURN sum
ENDFUNCTION

result = calculate(5, 3)   ' 13
' temp and sum do not exist here
```

### Calling Functions

Functions are called by name with parentheses:

```basic
' As part of an expression
total = square(3) + square(4)

' In a PRINT statement
PRINTLN "The answer is "; factorial(5)

' Standalone (result discarded)
logMessage("Application started")
```

### Recursion

Functions can call themselves:

```basic
FUNCTION factorial(n)
  IF n <= 1 THEN RETURN 1
  RETURN n * factorial(n - 1)
ENDFUNCTION

PRINTLN factorial(5)   ' 120
```

```basic
FUNCTION fibonacci(n)
  IF n <= 1 THEN RETURN n
  RETURN fibonacci(n - 1) + fibonacci(n - 2)
END FUNCTION

FOR i = 0 TO 10
  PRINT fibonacci(i); " ";
NEXT
' Output: 0 1 1 2 3 5 8 13 21 34 55
```

---

## Arrays

### Creating Arrays

Use `dim#()` to create numeric arrays with 1 to 10 dimensions:

```basic
' 1D array with 10 elements
numbers# = dim#(10)

' 2D array (5 rows × 3 columns)
matrix# = dim#(5, 3)

' 3D array
cube# = dim#(4, 4, 4)
```

For string arrays, use `sdim#()`:

```basic
names# = sdim#(5)   ' Array of 5 strings
```

For pointer arrays, use `pdim#()`:

```basic
objects# = pdim#(3)   ' Array of 3 pointers
```

### Accessing Array Elements

Arrays use **1-based indexing** (first element is at index 1):

```basic
arr# = dim#(5)

' Set values
arr#[1] = 100
arr#[2] = 200
arr#[3] = 300

' Get values
PRINTLN arr#[1]   ' 100
PRINTLN arr#[2]   ' 200
```

**Multi-dimensional arrays:**

```basic
matrix# = dim#(3, 3)

' Set values
matrix#[1, 1] = 1
matrix#[1, 2] = 2
matrix#[2, 1] = 3
matrix#[2, 2] = 4

' Get values
PRINTLN matrix#[1, 1]   ' 1
PRINTLN matrix#[2, 2]   ' 4
```

**String arrays:**

```basic
names# = sdim#(3)

names#$[1] = "Alice"
names#$[2] = "Bob"
names#$[3] = "Carol"

PRINTLN names#$[2]   ' Bob
```

**Pointer arrays (arrays of arrays):**

Note: Plan9Basic does not support chained array access like `arrays##[1][1]`. Use intermediate pointer variables instead:

```basic
arrays# = pdim#(2)
arrays##[1] = dim#(5)
arrays##[2] = dim#(10)

' Access nested arrays via intermediate pointers
item1# = arrays##[1]
item1#[1] = 100
item1#[2] = 200
item1#[3] = 300
item1#[4] = 400
item1#[5] = 500

item2# = arrays##[2]
item2#[1] = 10
item2#[2] = 20
item2#[3] = 30
item2#[4] = 40
item2#[5] = 50
item2#[6] = 60
item2#[7] = 70
item2#[8] = 80
item2#[9] = 90
item2#[10] = 100

PRINTLN item1#[1]   ' 100
PRINTLN item1#[2]   ' 200
PRINTLN item1#[3]   ' 300
PRINTLN item1#[4]   ' 400
PRINTLN item1#[5]   ' 500
PRINTLN item2#[1]   ' 10
PRINTLN item2#[2]   ' 20
PRINTLN item2#[3]   ' 30
PRINTLN item2#[4]   ' 40
PRINTLN item2#[5]   ' 50
```

### Array Example

```basic
' Create and fill an array
scores# = dim#(5)

scores#[1] = 85
scores#[2] = 92
scores#[3] = 78
scores#[4] = 95
scores#[5] = 88

' Calculate average
total = 0
FOR i = 1 TO 5
  total = total + scores#[i]
NEXT

average = total / 5
PRINTLN "Average score: "; average
```

---

## String Operations

### String Functions

Common string functions (availability may vary by implementation):

| Function | Description | Example |
|----------|-------------|---------|
| `len(s$)` | Length of string | `len("Hello")` → `5` |
| `left$(s$, n)` | First n characters | `left$("Hello", 3)` → `"Hel"` |
| `right$(s$, n)` | Last n characters | `right$("Hello", 2)` → `"lo"` |
| `mid$(s$, start, len)` | Substring | `mid$("Hello", 2, 3)` → `"ell"` |
| `ucase$(s$)` | Uppercase | `ucase$("Hello")` → `"HELLO"` |
| `lcase$(s$)` | Lowercase | `lcase$("Hello")` → `"hello"` |
| `trim$(s$)` | Remove whitespace | `trim$("  Hi  ")` → `"Hi"` |
| `str$(n)` | Number to string | `str$(42)` → `"42"` |
| `val(s$)` | String to number | `val("42")` → `42` |
| `chr$(n)` | ASCII code to character | `chr$(65)` → `"A"` |
| `asc(s$)` | Character to ASCII code | `asc("A")` → `65` |
| `instr(s$, find$)` | Find substring | `instr("Hello", "ll")` → `3` |

### Line Access

Access individual lines in a multi-line string with `[n]`. **Line indexing is 0-based:**

```basic
text$ = "Line 1" / "Line 2" / "Line 3"

PRINTLN text$[0]   ' Line 1
PRINTLN text$[1]   ' Line 2
PRINTLN text$[2]   ' Line 3
```

Assign to a specific line:

```basic
text$[2] = "Modified index 2"
PRINTLN text$[2]   ' Modified index 2
```

### Character Access

Access individual characters with `[[n]]`. **Character indexing is 0-based:**

```basic
word$ = "Hello"

PRINTLN word$[[0]]   ' H
PRINTLN word$[[1]]   ' e
PRINTLN word$[[4]]   ' o
```

Assign to a specific character:

```basic
word$[[0]] = "J"
PRINTLN word$   ' Jello
```

> **Note:** String indexing (`$[n]` and `$[[n]]`) is **0-based**, while numeric and pointer arrays (`dim#`, `sdim#`, `pdim#`) are **1-based**.

---

## Input and Output

### PRINT and PRINTLN

**PRINT** displays values without a newline:

```basic
PRINT "Hello "
PRINT "World"
' Output: Hello World (on same line)
```

**PRINTLN** displays values and adds a newline:

```basic
PRINTLN "Hello"
PRINTLN "World"
' Output:
' Hello
' World
```

**Displaying multiple values:**

Use semicolon (`;`) for compact output:

```basic
PRINTLN "The value is "; 42
' Output: The value is 42
```

Use comma (`,`) for tabbed columns:

```basic
PRINTLN "Name", "Age", "City"
PRINTLN "Alice", 25, "New York"
PRINTLN "Bob", 30, "Boston"
```

### CLS

Clear the output screen:

```basic
CLS
PRINTLN "Fresh start!"
```

### INPUT

Get input from the user (asynchronous with callback):

```basic
' Numeric input
INPUT "Calculator", "Enter a number:", 0, handleNumber

FUNCTION handleNumber(value)
  PRINTLN "You entered: "; value
  PRINTLN "Doubled: "; value * 2
ENDFUNCTION
```

```basic
' String input
INPUT "Greeting", "What is your name?", "", handleName$

FUNCTION handleName$(name$)
  PRINTLN "Hello, " + name$ + "!"
ENDFUNCTION
```

**INPUT and INPUT$** They are asynchronous; script execution is not interrupted by these calls; the callback function is executed when the user confirms the action; if several INPUT (or INPUT$) commands are called in sequence, a "stacking" of the data entry windows will occur.

### DATA, READ, and RESTORE

**DATA** stores constant values in your program:

```basic
DATA 10, 20, 30, 40, 50
DATA "Alice", "Bob", "Carol"
```

**READ** retrieves the next value:

```basic
DATA 100, 200, 300

READ a
READ b
READ c

PRINTLN a   ' 100
PRINTLN b   ' 200
PRINTLN c   ' 300
```

**RESTORE** resets reading to the beginning:

```basic
DATA 1, 2, 3

READ x : PRINTLN x   ' 1
READ x : PRINTLN x   ' 2
RESTORE
READ x : PRINTLN x   ' 1 (back to start)
```

**Complete DATA example:**

```basic
' Store student data
DATA "Alice", 85
DATA "Bob", 92
DATA "Carol", 78

' Read and display
FOR i = 1 TO 3
  READ name$
  READ score
  PRINTLN name$ + ": " + str$(score)
NEXT
```

---

## Advanced Features

### Indirect Function Calls

Call functions by name at runtime using the `&` operator:

**Numeric result:**

```basic
operation$ = "sin"
angle = 90
result = &(operation$ + "@n", angle)
PRINTLN result   ' 0.8939966636006
```

**String result:**

```basic
func$ = "ucase$"
text$ = "hello"
result$ = &$(func$ + "@$", text$)
PRINTLN result$   ' HELLO
```

**Pointer result:**

```basic
result# = &#("dim#@n", 10)
```

### Function Signatures

The signature format is: `name@parameters`

- `n` = numeric parameter
- `$` = string parameter
- `#` = pointer parameter

Examples:
- `sin@n` - sin function taking one number
- `left$@$n` - left$ function taking string and number
- `dim#@nnn` - dim# function taking three numbers

### The THIS# Pointer

Inside callbacks and event handlers, `THIS#` refers to the host application object:

```basic
' Access host application features
obj# = THIS#
```

### LET Statement

`LET` is optional for assignments (for classic BASIC compatibility):

```basic
LET x = 10       ' Same as: x = 10
LET name$ = "Hi" ' Same as: name$ = "Hi"
```

---

## Complete Examples

### Example 1: Number Guessing Game

```basic
' Number Guessing Game
CLS
PRINTLN "=== Number Guessing Game ==="
PRINTLN ""

randomize()   ' Seed the random number generator!
secretNumber = int(rnd() * 100) + 1   ' rnd() with no args returns 0 <= X < 1

attempts = 0
maxAttempts = 7

PRINTLN "I'm thinking of a number between 1 and 100."
PRINTLN "You have " + str$(maxAttempts) + " attempts."
PRINTLN ""

INPUT "Guess", "Enter your guess:", 50, checkGuess

FUNCTION checkGuess(guess)
  attempts = attempts + 1
  
  IF guess = secretNumber THEN
    PRINTLN "Congratulations! You got it in " + str$(attempts) + " attempts!"
  ELSE IF guess < secretNumber THEN
    PRINTLN "Too low!"
    IF attempts < maxAttempts THEN
      INPUT "Guess", "Try again:", guess, checkGuess
    ELSE
      PRINTLN "Game over! The number was " + str$(secretNumber)
    ENDIF
  ELSE
    PRINTLN "Too high!"
    IF attempts < maxAttempts THEN
      INPUT "Guess", "Try again:", guess, checkGuess
    ELSE
      PRINTLN "Game over! The number was " + str$(secretNumber)
    ENDIF
  ENDIF
ENDFUNCTION
```

### Example 2: Simple Calculator

```basic
' Simple Calculator
CLS
PRINTLN "=== Simple Calculator ==="
PRINTLN ""

FUNCTION add(a, b)
  RETURN a + b
ENDFUNCTION

FUNCTION subtract(a, b)
  RETURN a - b
ENDFUNCTION

FUNCTION multiply(a, b)
  RETURN a * b
ENDFUNCTION

FUNCTION divide(a, b)
  IF b = 0 THEN
    PRINTLN "Error: Division by zero!"
    RETURN 0
  ENDIF
  RETURN a / b
ENDFUNCTION

' Test calculations
PRINTLN "10 + 5 = "; add(10, 5)
PRINTLN "10 - 5 = "; subtract(10, 5)
PRINTLN "10 * 5 = "; multiply(10, 5)
PRINTLN "10 / 5 = "; divide(10, 5)
PRINTLN "10 / 0 = "; divide(10, 0)
```

### Example 3: Array Sorting (Bubble Sort)

```basic
' Bubble Sort Example
CLS
PRINTLN "=== Bubble Sort ==="
PRINTLN ""

' Create array with random values
size = 10
arr# = dim#(size)
randomize()

PRINTLN "Original array:"
FOR i = 1 TO size
  arr#[i] = int(rnd(10) * 100)
  PRINT arr#[i]; " ";
NEXT
PRINTLN ""

' Bubble sort
FOR i = 1 TO size - 1
  FOR j = 1 TO size - i
    IF arr#[j] > arr#[j + 1] THEN
      ' Swap elements
      temp = arr#[j]
      arr#[j] = arr#[j + 1]
      arr#[j + 1] = temp
    ENDIF
  NEXT
NEXT

PRINTLN "Sorted array:"
FOR i = 1 TO size
  PRINT arr#[i]; " ";
NEXT
PRINTLN ""
```

### Example 4: Working with Strings

```basic
' String Manipulation Demo
CLS
PRINTLN "=== String Demo ==="
PRINTLN ""

text$ = "The quick brown fox jumps over the lazy dog"

PRINTLN "Original: " + text$
PRINTLN "Length: "; len(text$)
PRINTLN "Uppercase: " + ucase$(text$)
PRINTLN "First 10 chars: " + left$(text$, 10)
PRINTLN "Last 8 chars: " + right$(text$, 8)
PRINTLN ""

' Count vowels (character indexing is 0-based)
vowels = 0
FOR i = 0 TO len(text$) - 1
  char$ = lcase$(text$[[i]])
  IF char$ = "a" OR char$ = "e" OR char$ = "i" OR char$ = "o" OR char$ = "u" THEN
    vowels = vowels + 1
  ENDIF
NEXT
PRINTLN "Number of vowels: "; vowels
```

### Example 5: Menu System with SELECT CASE

```basic
' Menu System Example
CLS

PRINTLN ""
PRINTLN "=== Main Menu ==="
PRINTLN "1. Say Hello"
PRINTLN "2. Show Date"
PRINTLN "3. Calculate"
PRINTLN "4. Exit"
PRINTLN ""
  
INPUT "Menu", "Choose option (1-4):", 1, handleChoice

FUNCTION handleChoice(choice)
  IF choice = 1 THEN
      PRINTLN "Hello, World!"
  ELSE IF choice = 2 THEN
      PRINTLN "Today is a beautiful day!"
  ELSE IF choice = 3 THEN
      PRINTLN "2 + 2 = "; 2 + 2
  ELSE IF choice = 4 THEN
      PRINTLN "Goodbye!"
  ELSE
      PRINTLN "Invalid option!"
  END IF
END FUNCTION
```

---

## Quick Reference Card

### Keywords

| Category | Keywords |
|----------|----------|
| Control | `IF`, `THEN`, `ELSE`, `ENDIF`, `FOR`, `TO`, `STEP`, `NEXT`, `WHILE`, `ENDWHILE`, `REPEAT`, `UNTIL`, `DO`, `LOOP`, `SELECT`, `CASE`, `ENDSELECT` |
| Branching | `GOTO`, `GOSUB`, `RETURN`, `ON`, `BREAK`, `CONTINUE`, `END` |
| Functions | `FUNCTION`, `ENDFUNCTION`, `LOCAL` |
| I/O | `PRINT`, `PRINTLN`, `INPUT`, `CLS` |
| Data | `DATA`, `READ`, `RESTORE`, `LET` |
| Operators | `AND`, `OR`, `NOT`, `MOD` |
| Comments | `REM`, `'` |

### Operators Quick Reference

| Type | Operators |
|------|-----------|
| Arithmetic | `+`, `-`, `*`, `/`, `MOD`, `^`, `?>`, `?<` |
| Comparison | `=`, `<>`, `<`, `>`, `<=`, `>=` |
| Logical | `AND`, `OR`, `NOT` |
| String | `+` (concat), `/` (with newline), `-` (truncate) |

### Type Suffixes

| Suffix | Type | Example |
|--------|------|---------|
| (none) | Number | `x`, `count` |
| `$` | String | `name$`, `text$` |
| `#` | Pointer | `arr#`, `obj#` |

### Indexing

| Type | Base | Example |
|------|------|---------|
| Numeric arrays (`dim#`) | **1-based** | `arr#[1]` is first element |
| String arrays (`sdim#`) | **1-based** | `names#$[1]` is first element |
| Pointer arrays (`pdim#`) | **1-based** | `ptrs##[1]` is first element |
| String lines (`$[n]`) | **0-based** | `text$[0]` is first line |
| String chars (`$[[n]]`) | **0-based** | `word$[[0]]` is first char |

---

## Tips and Best Practices

1. **Use meaningful variable names**: `playerScore` is better than `x`
2. **Comment your code**: Explain complex logic for future reference
3. **Use functions**: Break complex programs into smaller, reusable pieces
4. **Initialize variables**: Set initial values before using variables
5. **Avoid GOTO when possible**: Use structured loops and functions instead
6. **Test incrementally**: Build and test your program in small steps
7. **Handle edge cases**: Check for division by zero, empty strings, etc.
8. **Remember: no parentheses in logical expressions**: Write `IF NOT x = y THEN` not `IF NOT (x = y) THEN`
9. **Comparisons only in conditionals**: You cannot use comparisons as values; they only work inside `IF`, `WHILE`, `UNTIL`, etc.
10. **Use intermediate pointers for nested arrays**: Chained access like `arr##[1][2]` is not supported. Instead, use `temp# = arr##[1]` then `temp#[2]`

---

*Plan9Basic User Guide - First Draft*
