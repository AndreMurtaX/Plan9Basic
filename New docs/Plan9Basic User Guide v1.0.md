# Plan9Basic User Guide
## Version 1.0 - Complete Reference

---

## Introduction

**Plan9Basic** is a small and simple programming language inspired by classic BASIC, designed for creating small applications called *applets*. It combines the simplicity and accessibility of traditional BASIC with modern structured programming features and a powerful cross-platform graphical interface.

Plan9Basic is ideal for:
- Learning programming concepts
- Creating simple utilities, games, and tools
- Building interactive graphical applications
- Rapid prototyping

### Design Philosophy

Plan9Basic stays true to the spirit of classic 8-bit BASIC interpreters while adding modern structured programming capabilities. Key design decisions include:
- **No boolean type** — conditional logic is handled directly by control structures
- **Case-insensitive** — `COUNT`, `Count`, and `count` all refer to the same variable
- **Simple and intuitive** — easy to learn, yet powerful enough for real applications
- **Modern expressions** — full support for parentheses in logical expressions for complex condition grouping

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
11. [DATA, READ, and RESTORE](#data-read-and-restore)
12. [Debugging Features](#debugging-features)
13. [Advanced Features](#advanced-features)
14. [Complete Examples](#complete-examples)
15. [Quick Reference](#quick-reference)
16. [Tips and Best Practices](#tips-and-best-practices)

---

## Getting Started

### Your First Program

```basic
' My first Plan9Basic program
PRINTLN "Hello, World!"
```

This simple program displays "Hello, World!" on the output screen. Let's break it down:
- The apostrophe (`'`) starts a comment — text that the interpreter ignores
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

Plan9Basic supports three fundamental data types. Like classic 8-bit BASIC interpreters, **there is no boolean type** — conditional logic is handled directly by control structures.

### Numbers

Numbers can be integers or floating-point values:

```basic
count = 42           ' Integer
pi = 3.14159         ' Floating-point
big = 1.5e10         ' Scientific notation (1.5 × 10¹⁰)
small = .5           ' Can omit leading zero (equals 0.5)
negative = -273.15   ' Negative numbers
```

**Note:** Values are stored internally as extended precision floating-point. Integer values up to 2,147,483,647 are preserved exactly.

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
| `\t` | Horizontal tab |
| `\0` | Null character |
| `\b` | Backspace |
| `\f` | Form feed |
| `\v` | Vertical tab |
| `\a` | Alert/bell |

```basic
quote$ = "She said \"Hello!\""
path$ = "C:\\Users\\Documents"
multiline$ = "Line 1\nLine 2"
```

### Pointers

Pointers reference complex objects like arrays, identified by the `#` suffix:

```basic
myArray# = dim#(10)      ' Create a numeric array of 10 elements
myDict# = dict_new#(0)   ' Create a dictionary
```

---

## Variables

### Naming Rules

Variable names must:
- Start with a letter (A-Z, a-z) or underscore (_)
- Contain only letters, numbers, and underscores
- End with `$` for strings or `#` for pointers
- Not be a reserved word

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

### Case Insensitivity

**Important:** Plan9Basic does not differentiate between uppercase and lowercase characters when forming variables or reserved words.

```basic
' The lines below refer to the same variable
count = 0      ' count = 0
Count = 10     ' count = 10
COUNT = 20     ' count = 20

' Both syntaxes for the FOR command are valid
for i = 1 to 10
FOR i = 1 TO 10   ' Equivalent to the syntax above
```

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
| `NOT` | Logical NOT | `IF NOT (x = 0) THEN` |

**Operator Precedence:** `NOT` has the highest precedence, followed by `AND`, then `OR`. Use parentheses to control evaluation order in complex expressions.

```basic
x = 5
y = 10
z = 0

' Simple conditions
IF x > 0 AND y > 0 THEN
  PRINTLN "Both positive"
ENDIF

IF x = 0 OR y = 0 THEN
  PRINTLN "At least one is zero"
ENDIF

' Using NOT with parentheses
IF NOT (x = y) THEN
  PRINTLN "x and y are different"
ENDIF

' Grouping with parentheses for complex conditions
IF (x > 0 AND y > 0) OR z = 0 THEN
  PRINTLN "Either both x and y are positive, or z is zero"
ENDIF

' Nested parentheses for clarity
IF NOT (x = 0 OR y = 0) THEN
  PRINTLN "Neither x nor y is zero"
ENDIF

' Complex condition with multiple groups
IF (x > 0 AND y > 0) AND NOT (z < 0) THEN
  PRINTLN "Complex condition met"
ENDIF
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
short$ = word$ - 7
PRINTLN short$      ' Prog
```

---

## Control Structures

### IF...THEN...ELSE...ENDIF

Basic conditional execution:

```basic
' Single line IF
IF x > 0 THEN PRINTLN "Positive"

' Multi-line IF
IF x > 0 THEN
  PRINTLN "x is positive"
ENDIF

' IF...ELSE
IF x > 0 THEN
  PRINTLN "Positive"
ELSE
  PRINTLN "Not positive"
ENDIF

' IF...ELSE IF...ELSE
IF x > 0 THEN
  PRINTLN "Positive"
ELSE IF x < 0 THEN
  PRINTLN "Negative"
ELSE
  PRINTLN "Zero"
ENDIF

' END IF with space is also valid
IF x > 0 THEN
  PRINTLN "Positive"
END IF
```

### FOR...NEXT (or FOR...ENDFOR)

Counted loops:

```basic
' Basic FOR loop
FOR i = 1 TO 10
  PRINTLN i
NEXT

' NEXT with optional control variable (for clarity)
FOR i = 1 TO 10
  PRINTLN i
NEXT i

' ENDFOR as alternative to NEXT
FOR i = 1 TO 10
  PRINTLN i
ENDFOR

' END FOR with space
FOR i = 1 TO 10
  PRINTLN i
END FOR

' Using STEP
FOR i = 10 TO 1 STEP -1
  PRINTLN i
NEXT

FOR i = 0 TO 100 STEP 10
  PRINTLN i
NEXT
```

### WHILE...ENDWHILE (or WHILE...WEND)

Pre-test loops:

```basic
' Basic WHILE loop
x = 0
WHILE x < 10
  PRINTLN x
  x = x + 1
ENDWHILE

' WEND as alternative to ENDWHILE
x = 0
WHILE x < 10
  PRINTLN x
  x = x + 1
WEND

' END WHILE with space
x = 0
WHILE x < 10
  PRINTLN x
  x = x + 1
END WHILE
```

### REPEAT...UNTIL

Post-test loops (executes at least once):

```basic
x = 0
REPEAT
  PRINTLN x
  x = x + 1
UNTIL x >= 10
```

### DO...LOOP

Flexible loop construct with multiple forms:

```basic
' DO WHILE...LOOP (pre-test)
x = 0
DO WHILE x < 10
  PRINTLN x
  x = x + 1
LOOP

' DO UNTIL...LOOP (pre-test, exits when true)
x = 0
DO UNTIL x >= 10
  PRINTLN x
  x = x + 1
LOOP

' DO...LOOP WHILE (post-test)
x = 0
DO
  PRINTLN x
  x = x + 1
LOOP WHILE x < 10

' DO...LOOP UNTIL (post-test, exits when true)
x = 0
DO
  PRINTLN x
  x = x + 1
LOOP UNTIL x >= 10

' DO...LOOP (infinite until BREAK)
x = 0
DO
  PRINTLN x
  x = x + 1
  IF x >= 10 THEN BREAK
LOOP
```

### SELECT CASE...END SELECT

Multiple-choice branching:

```basic
' Numeric SELECT
SELECT CASE score
  CASE 10
    PRINTLN "Perfect!"
  CASE 9
    PRINTLN "Excellent!"
  CASE 7, 8
    PRINTLN "Good"
  CASE ELSE
    PRINTLN "Keep practicing"
END SELECT

' String SELECT
SELECT CASE command$
  CASE "HELP"
    PRINTLN "Available commands: HELP, QUIT"
  CASE "QUIT"
    END
  CASE ELSE
    PRINTLN "Unknown command"
END SELECT

' ENDSELECT (without space) is also valid
SELECT CASE x
  CASE 1
    PRINTLN "One"
ENDSELECT
```

### BREAK and CONTINUE

Loop control statements:

```basic
' BREAK exits the loop immediately
FOR i = 1 TO 100
  IF i > 10 THEN BREAK
  PRINTLN i
NEXT

' CONTINUE skips to the next iteration
FOR i = 1 TO 10
  IF i MOD 2 = 0 THEN CONTINUE
  PRINTLN i   ' Only prints odd numbers
NEXT
```

### GOTO and GOSUB

Branching and subroutines (use sparingly):

```basic
' GOTO with numeric label
GOTO 100
PRINTLN "Skipped"
100 PRINTLN "Jumped here"

' GOTO with named label
GOTO finish
PRINTLN "Skipped"
finish:
PRINTLN "Jumped here"

' GOSUB/RETURN for subroutines
PRINTLN "Before subroutine"
GOSUB mySubroutine
PRINTLN "After subroutine"
END

mySubroutine:
  PRINTLN "Inside subroutine"
  RETURN
```

### ON...GOTO and ON...GOSUB

Computed branching:

```basic
' ON...GOTO jumps based on value
option = 2
ON option GOTO option1, option2, option3
PRINTLN "Invalid option"
END

option1:
PRINTLN "Option 1 selected"
END

option2:
PRINTLN "Option 2 selected"
END

option3:
PRINTLN "Option 3 selected"
END

' ON...GOSUB calls subroutine based on value
choice = 1
ON choice GOSUB handleYes, handleNo, handleCancel
END

handleYes:
  PRINTLN "You chose Yes"
  RETURN

handleNo:
  PRINTLN "You chose No"
  RETURN

handleCancel:
  PRINTLN "You chose Cancel"
  RETURN
```

---

## Functions and Subroutines

### Defining Functions

Functions are defined with `FUNCTION` and `ENDFUNCTION`:

```basic
' Function with no parameters
FUNCTION greet()
  PRINTLN "Hello!"
ENDFUNCTION

' Function with parameters
FUNCTION add(a, b)
  RETURN a + b
ENDFUNCTION

' Function with local variables
FUNCTION calculate(x, y) LOCAL temp, result
  temp = x * y
  result = temp + 10
  RETURN result
ENDFUNCTION

' END FUNCTION with space is also valid
FUNCTION multiply(a, b)
  RETURN a * b
END FUNCTION
```

### Function Return Types

The function name suffix indicates the return type:

```basic
' Numeric function (no suffix)
FUNCTION square(x)
  RETURN x * x
ENDFUNCTION

' String function ($ suffix)
FUNCTION greeting$(name$)
  RETURN "Hello, " + name$ + "!"
ENDFUNCTION

' Pointer function (# suffix)
FUNCTION createArray#(size)
  RETURN dim#(size)
ENDFUNCTION
```

### Calling Functions

```basic
' Calling functions and using return values
result = add(5, 3)
PRINTLN result          ' 8

msg$ = greeting$("Alice")
PRINTLN msg$            ' Hello, Alice!

arr# = createArray#(10)

' Discarding return value (just call the function)
processData(x, y)
```

### Function Parameters

Parameters can be of any type:

```basic
FUNCTION process(num, text$, data#)
  PRINTLN "Number: "; num
  PRINTLN "Text: "; text$
  ' Process data#...
ENDFUNCTION
```

### Limitations

- Functions cannot be nested (no function inside another function)
- `GOTO` and `GOSUB` cannot be used inside functions
- Maximum of 256 parameters and local variables combined per function

---

## Arrays

### Numeric Arrays

Create with `dim#()`:

```basic
' One-dimensional array (10 elements, indices 1-10)
arr# = dim#(10)

' Set values (1-based indexing)
arr#[1] = 100
arr#[5] = 500

' Get values
PRINTLN arr#[1]    ' 100
PRINTLN arr#[5]    ' 500

' Multi-dimensional array (3x3 matrix)
matrix# = dim#(3, 3)
matrix#[1, 1] = 1
matrix#[2, 2] = 5
matrix#[3, 3] = 9

' Array utility functions
PRINTLN ndims(arr#)           ' 1 (number of dimensions)
PRINTLN ubound(arr#, 1)       ' 10 (upper bound of dimension 1)
PRINTLN lbound(arr#, 1)       ' 1 (lower bound, always 1)
PRINTLN arraysize(arr#)       ' 10 (total elements)
PRINTLN arraytypename$(arr#)  ' "numeric"
```

### String Arrays

Create with `sdim#()`:

```basic
' Array of strings
names# = sdim#(5)
names#$[1] = "Alice"
names#$[2] = "Bob"
names#$[3] = "Carol"

' Access string elements (note the $ before [)
PRINTLN names#$[1]    ' Alice
```

### Pointer Arrays

Create with `pdim#()`:

```basic
' Array of pointers (for nested structures)
containers# = pdim#(3)
containers##[1] = dim#(10)
containers##[2] = dim#(20)
containers##[3] = dim#(30)

' Access nested array (use intermediate pointer)
temp# = containers##[1]
temp#[1] = 42
```

### Array Indexing Rules

| Array Type | Function | Index Base | Access Syntax |
|------------|----------|------------|---------------|
| Numeric | `dim#()` | 1-based | `arr#[1]` |
| String | `sdim#()` | 1-based | `arr#$[1]` |
| Pointer | `pdim#()` | 1-based | `arr##[1]` |

### Array Utility Functions

| Function | Description | Example |
|----------|-------------|---------|
| `ndims(arr#)` | Get number of dimensions | `ndims(matrix#)` → `2` |
| `ubound(arr#, dim)` | Get upper bound of dimension | `ubound(arr#, 1)` → `10` |
| `lbound(arr#, dim)` | Get lower bound of dimension (always 1) | `lbound(arr#, 1)` → `1` |
| `arraysize(arr#)` | Get total number of elements | `arraysize(arr#)` → `10` |
| `arraytype(arr#)` | Get array type (0=numeric, 1=string, 2=pointer) | `arraytype(arr#)` → `0` |
| `arraytypename$(arr#)` | Get array type name as string | `arraytypename$(arr#)` → `"numeric"` |

**Note:** Arrays support 1 to 10 dimensions.

**Important:** Chained access like `arr##[1][2]` is NOT supported. Use intermediate pointers instead:

```basic
' WRONG - chained access not supported
' value = containers##[1][2]

' CORRECT - use intermediate pointer
temp# = containers##[1]
value = temp#[2]
```

---

## String Operations

### String Indexing

Strings support line-based and character-based indexing (both 0-based):

```basic
text$ = "Line 1\nLine 2\nLine 3"

' Line indexing with $[n] (0-based)
PRINTLN text$[0]    ' Line 1
PRINTLN text$[1]    ' Line 2

' Character indexing with $[[n]] (0-based)
word$ = "Hello"
PRINTLN word$[[0]]  ' H
PRINTLN word$[[4]]  ' o
```

### Built-in String Functions

| Function | Description | Example |
|----------|-------------|---------|
| `len(s$)` | Length of string | `len("Hello")` → `5` |
| `left$(s$, n)` | First n characters | `left$("Hello", 3)` → `"Hel"` |
| `right$(s$, n)` | Last n characters | `right$("Hello", 2)` → `"lo"` |
| `mid$(s$, start, len)` | Substring (1-based) | `mid$("Hello", 2, 3)` → `"ell"` |
| `ucase$(s$)` | Convert to uppercase | `ucase$("Hello")` → `"HELLO"` |
| `lcase$(s$)` | Convert to lowercase | `lcase$("Hello")` → `"hello"` |
| `trim$(s$)` | Remove leading/trailing spaces | `trim$("  Hi  ")` → `"Hi"` |
| `ltrim$(s$)` | Remove leading spaces | `ltrim$("  Hi")` → `"Hi"` |
| `rtrim$(s$)` | Remove trailing spaces | `rtrim$("Hi  ")` → `"Hi"` |
| `instr(s$, find$)` | Find substring position | `instr("Hello", "ll")` → `3` |
| `str$(n)` | Number to string | `str$(42)` → `"42"` |
| `val(s$)` | String to number | `val("42")` → `42` |
| `chr$(n)` | ASCII code to character | `chr$(65)` → `"A"` |
| `asc(s$)` | Character to ASCII code | `asc("A")` → `65` |
| `space$(n)` | String of n spaces | `space$(5)` → `"     "` |
| `string$(n, code)` | Repeat one character n times, by ASCII code | `string$(3, 65)` → `"AAA"` |
| `replacestr$(s$, old$, new$)` | Replace occurrences, case sensitive | `replacestr$("Hello", "l", "L")` → `"HeLLo"` |
| `replacetext$(s$, old$, new$)` | Replace occurrences, ignoring case | `replacetext$("Hello", "L", "X")` → `"HeXXo"` |

```basic
' String manipulation examples
text$ = "  Hello World  "
PRINTLN len(text$)           ' 15
PRINTLN trim$(text$)         ' "Hello World"
PRINTLN ucase$(text$)        ' "  HELLO WORLD  "
PRINTLN left$(trim$(text$), 5)  ' "Hello"

' String searching
sentence$ = "The quick brown fox"
pos = instr(sentence$, "quick")
PRINTLN pos                  ' 5

' Conversion
number = 42
text$ = "The answer is " + str$(number)
PRINTLN text$                ' The answer is 42

value = val("123.45")
PRINTLN value * 2            ' 246.9
```

---

## Input and Output

### PRINT and PRINTLN

Display output to the screen:

```basic
' PRINTLN adds a newline after output
PRINTLN "Hello, World!"
PRINTLN

' PRINT does not add a newline
PRINT "Enter your name: "

' Multiple items with semicolon (no space between)
PRINTLN "Value: "; 42

' Multiple items with comma (adds comma separator)
PRINTLN "A", "B", "C"    ' A,B,C
```

### CLS

Clear the screen:

```basic
CLS
PRINTLN "Fresh screen!"
```

### INPUT

Get input from the user (asynchronous with callback):

```basic
' Numeric input
INPUT "Calculator", "Enter a number:", 0, processNumber

FUNCTION processNumber(value)
  PRINTLN "You entered: "; value
  PRINTLN "Doubled: "; value * 2
ENDFUNCTION

' String input
INPUT "Name Entry", "What is your name:", "", processName$

FUNCTION processName$(name$)
  PRINTLN "Hello, " + name$ + "!"
ENDFUNCTION
```

The INPUT syntax is: `INPUT caption$, prompt$, default_value, callback_function`

---

## DATA, READ, and RESTORE

Store and retrieve predefined data:

### DATA

Define data values anywhere in your program:

```basic
DATA 100, 200, 300
DATA "Alice", "Bob", "Carol"
```

### READ

Retrieve the next data value:

```basic
DATA 100, 200, 300

READ a
READ b
READ c

PRINTLN a   ' 100
PRINTLN b   ' 200
PRINTLN c   ' 300
```

### RESTORE

Reset the data pointer to the beginning:

```basic
DATA 1, 2, 3

READ x : PRINTLN x   ' 1
READ x : PRINTLN x   ' 2
RESTORE
READ x : PRINTLN x   ' 1 (back to start)
```

### Complete DATA Example

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

**Note:** DATA statements cannot appear inside functions.

---

## Debugging Features

Plan9Basic provides a comprehensive set of debugging tools to help you find and fix errors in your programs. All debugging features are controlled by a "master switch" — when tracing is disabled, all debug commands are ignored with zero overhead.

### The Master Switch: TRACE

Before any debugging command will work, you need to enable tracing:

```basic
TRACEON         ' Turn on debugging (level 1)
TRACEOFF        ' Turn off debugging

' Or use TRACE with a specific level
TRACE 0         ' Off - no debugging output
TRACE 1         ' Basic - show line numbers
TRACE 2         ' Standard - show line numbers and function names
TRACE 3         ' Verbose - show lines, functions, and watched variables
```

**Example: Basic Tracing**

```basic
TRACEON
x = 10
y = 20
z = x + y
PRINTLN z
TRACEOFF
```

**Output:**
```
[TRACE] Trace level 1 (basic)
[TRACE] Line 2
[TRACE] Line 3
[TRACE] Line 4
[TRACE] Line 5
30
[TRACE] Line 6
[TRACE] Trace disabled
```

**Tip: Easy Production Mode**

When your program is ready for users, just comment out TRACEON:

```basic
' TRACEON        ' <-- Add apostrophe to disable ALL debugging
x = 10
ASSERT x > 0, "this won't run now"
DUMP "this won't show either"
```

### ASSERT - Validate Your Assumptions

ASSERT checks if a condition is true. If false, the program stops with an error message:

```basic
TRACEON
x = 10
ASSERT x > 0, "x must be positive"
PRINTLN "x is valid!"
TRACEOFF
```

**Check before dividing:**

```basic
TRACEON
divisor = 0
ASSERT divisor <> 0, "Cannot divide by zero!"
result = 100 / divisor    ' This line won't execute
TRACEOFF
```

**Use with logical operators:**

```basic
TRACEON
age = 25
salary = 3000
ASSERT age >= 18 AND salary > 0, "Invalid employee data"
PRINTLN "Employee data is valid"
TRACEOFF
```

### DUMP - See All Your Variables

DUMP displays all global variables and their current values:

```basic
TRACEON

playerName$ = "John"
playerScore = 1500
playerLevel = 7
isAlive = 1

DUMP "Player Status"

TRACEOFF
```

**Output:**
```
[DUMP] Player Status (Line 8)
  playername$ = "John"
  playerscore = 1500
  playerlevel = 7
  isalive = 1
```

### WATCH - Monitor Variables in Real-Time

WATCH lets you monitor specific variables. With TRACE 3, you'll see values update on every line:

```basic
TRACE 3
WATCH x, y, total

x = 10
y = 20
total = x + y

UNWATCH
TRACE 0
```

**Output:**
```
[TRACE] Trace level 3 (verbose)
[WATCH] Added 3 variable(s) to watch list
[TRACE] Line 4 | x=NAN, y=NAN, total=NAN
[TRACE] Line 5 | x=10, y=NAN, total=NAN
[TRACE] Line 6 | x=10, y=20, total=NAN
[TRACE] Line 7 | x=10, y=20, total=30
[UNWATCH] Cleared all watched variables
[TRACE] Trace disabled
```

**Selective UNWATCH:**

```basic
WATCH x, y, z
' ... code ...
UNWATCH x       ' Stop watching x only
' ... more code ...
UNWATCH         ' Clear all watched variables
```

### BREAKPOINT - Pause and Inspect

BREAKPOINT pauses your program and shows a dialog:

```basic
TRACEON

x = 100
y = 50

BREAKPOINT "Before calculation", x, y

result = x / y

BREAKPOINT "After calculation", result

PRINTLN "Result: "; result

TRACEOFF
```

When the program reaches each BREAKPOINT:
1. A dialog box appears showing the message and variable values
2. Click "Yes" to continue running
3. Click "No" to stop the program

### Debugging Quick Reference

| Command | Description |
|---------|-------------|
| `TRACEON` | Enable debugging (level 1) |
| `TRACEOFF` | Disable debugging |
| `TRACE 0` | Disable debugging |
| `TRACE 1` | Line numbers only |
| `TRACE 2` | Line numbers + function names |
| `TRACE 3` | Line numbers + function names + watched variables |
| `ASSERT cond, msg$` | Stop if condition is false |
| `DUMP` | Show all global variables |
| `DUMP "label"` | Show all variables with label |
| `WATCH var1, var2` | Monitor specific variables |
| `UNWATCH` | Stop monitoring all variables |
| `UNWATCH var1` | Stop monitoring specific variable |
| `BREAKPOINT` | Simple pause |
| `BREAKPOINT "msg"` | Pause with message |
| `BREAKPOINT "msg", x, y` | Pause and show variables |

---

## Advanced Features

### Indirect Function Calls

Call functions by name at runtime using the `&` operator:

**Numeric result:**

```basic
operation$ = "sin"
angle = 90
result = &(operation$ + "@n", angle)
PRINTLN result
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
- `sin@n` — sin function taking one number
- `left$@$n` — left$ taking string and number
- `dim#@nnn` — dim# taking three numbers

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

### JSON Literals

Plan9Basic supports JSON array and object literals:

```basic
' JSON array literal
myArray# = [1, 2, 3, 4, 5]

' JSON object literal
myObject# = {"name": "Alice", "age": 25}

' Nested structures
data# = {
  "users": [
    {"name": "Alice", "score": 100},
    {"name": "Bob", "score": 85}
  ]
}
```

---

## Complete Examples

### Example 1: Number Guessing Game

```basic
' Number Guessing Game
CLS
PRINTLN "=== Number Guessing Game ==="
PRINTLN ""

randomize()
secretNumber = int(rnd() * 100) + 1

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
  arr#[i] = int(rnd() * 100)
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
  NEXT j
NEXT i

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

### Example 5: Debugging Demo

```basic
' Debugging Features Demo
CLS
PRINTLN "=== Debugging Demo ==="
PRINTLN ""

TRACE 3
WATCH counter, total

total = 0
FOR counter = 1 TO 5
  total = total + counter
NEXT

ASSERT total = 15, "Sum should be 15"
DUMP "Final state"

PRINTLN "Sum of 1 to 5: "; total

UNWATCH
TRACE 0
```

---

## Quick Reference

### Keywords

| Category | Keywords |
|----------|----------|
| Control | `IF`, `THEN`, `ELSE`, `ENDIF`, `END IF`, `FOR`, `TO`, `STEP`, `NEXT`, `ENDFOR`, `END FOR`, `WHILE`, `ENDWHILE`, `WEND`, `END WHILE`, `REPEAT`, `UNTIL`, `DO`, `LOOP`, `SELECT`, `CASE`, `ENDSELECT`, `END SELECT` |
| Branching | `GOTO`, `GOSUB`, `RETURN`, `ON`, `BREAK`, `CONTINUE`, `END` |
| Functions | `FUNCTION`, `ENDFUNCTION`, `END FUNCTION`, `LOCAL` |
| I/O | `PRINT`, `PRINTLN`, `INPUT`, `CLS` |
| Data | `DATA`, `READ`, `RESTORE`, `LET` |
| Operators | `AND`, `OR`, `NOT`, `MOD` |
| Debugging | `TRACE`, `TRACEON`, `TRACEOFF`, `ASSERT`, `DUMP`, `WATCH`, `UNWATCH`, `BREAKPOINT` |
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

### Array Indexing

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

8. **Comparisons only in conditionals**: You cannot use comparisons as values; they only work inside `IF`, `WHILE`, `UNTIL`, etc.

9. **Use intermediate pointers for nested arrays**: Chained access like `arr##[1][2]` is not supported. Instead, use `temp# = arr##[1]` then `temp#[2]`

10. **Use TRACE for debugging**: Enable tracing to find problems, disable it for production

11. **Use ASSERT liberally**: Validate assumptions at the start of functions

12. **Remember case insensitivity**: `Count`, `count`, and `COUNT` are the same variable

13. **NEXT can include the control variable**: `NEXT i` helps document which loop is ending

---

## Error Codes Reference

When using library functions, errors are typically indicated by return values:

| Code | Meaning |
|------|---------|
| 0 | No error (success) |
| 1 | Index out of bounds |
| 2 | Invalid argument |
| 3 | Empty string |
| 4 | File error |
| 5 | Clipboard error |

Check specific library documentation for additional error codes.

---

## Version History

### Version 1.0
- Complete language implementation with lexer, parser, and virtual machine
- Three data types: numbers, strings, and pointers
- Modern control structures: IF/ELSE, FOR/NEXT, WHILE/WEND, REPEAT/UNTIL, DO/LOOP, SELECT CASE
- User-defined functions with local variables
- Comprehensive debugging system: TRACE, ASSERT, DUMP, WATCH, BREAKPOINT
- Extensive standard library
- Cross-platform GUI capabilities
- JSON literal support with multi-line formatting
- Parentheses support in logical expressions for complex condition grouping
- Enhanced error messages for JSON parsing

---

*Plan9Basic User Guide - Version 1.0*
