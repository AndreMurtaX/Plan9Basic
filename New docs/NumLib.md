# Plan9Basic - NumLib Documentation

## Numeric and Math Library Reference Manual

**Version:** 1.0  
**Date:** January 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Rounding and Truncation Functions](#rounding-and-truncation-functions)
3. [Basic Math Functions](#basic-math-functions)
4. [Trigonometric Functions](#trigonometric-functions)
5. [Inverse Trigonometric Functions](#inverse-trigonometric-functions)
6. [Hyperbolic Functions](#hyperbolic-functions)
7. [Inverse Hyperbolic Functions](#inverse-hyperbolic-functions)
8. [Angle Conversion](#angle-conversion)
9. [Comparison Functions](#comparison-functions)
10. [Random Number Generation](#random-number-generation)
11. [Complete Examples](#complete-examples)
12. [Quick Reference](#quick-reference)

---

## Overview

The NumLib library provides essential mathematical functions for Plan9Basic programs. It includes:

- Rounding and truncation operations
- Basic mathematical functions (absolute value, square root, logarithms, exponentials)
- Trigonometric functions (sin, cos, tan) and their inverses
- Hyperbolic functions and their inverses
- Angle conversion between degrees and radians
- Comparison utilities
- Random number generation

### Important Notes

- **Trigonometric functions use radians**, not degrees. Use `degtorad()` and `radtodeg()` for conversion.
- All functions return numeric values (Extended precision floating-point).
- Plan9Basic does not have a built-in constant for π. Use `acos(-1)` or `atan(1) * 4` to calculate it.

---

## Rounding and Truncation Functions

### cint()

Converts a number to an integer by truncating toward zero (removes the fractional part).

**Syntax:**
```basic
result = cint(number)
```

**Parameters:**
- `number`: Any numeric value

**Returns:** Integer portion of the number (truncated toward zero)

**Example:**
```basic
println cint(3.7)     ' Output: 3
println cint(-3.7)    ' Output: -3
println cint(5.9)     ' Output: 5
```

---

### fix()

Returns the integer part of a number by truncating toward zero. Identical to `cint()`.

**Syntax:**
```basic
result = fix(number)
```

**Parameters:**
- `number`: Any numeric value

**Returns:** Integer portion of the number

**Example:**
```basic
println fix(7.8)      ' Output: 7
println fix(-7.8)     ' Output: -7
```

---

### int()

Returns the largest integer less than or equal to the number (floor function). For negative numbers, this rounds away from zero.

**Syntax:**
```basic
result = int(number)
```

**Parameters:**
- `number`: Any numeric value

**Returns:** Floor of the number

**Example:**
```basic
println int(3.7)      ' Output: 3
println int(-3.7)     ' Output: -4  (note: different from cint!)
println int(5.0)      ' Output: 5
```

**Note:** The difference between `cint()` and `int()` is important for negative numbers:
- `cint(-3.7)` returns `-3` (truncates toward zero)
- `int(-3.7)` returns `-4` (floor, rounds toward negative infinity)

---

### round()

Rounds a number to the nearest integer using banker's rounding (round half to even).

**Syntax:**
```basic
result = round(number)
```

**Parameters:**
- `number`: Any numeric value

**Returns:** Nearest integer

**Example:**
```basic
println round(3.4)    ' Output: 3
println round(3.5)    ' Output: 4
println round(3.6)    ' Output: 4
println round(-2.5)   ' Output: -2
```

---

### frac()

Returns the fractional part of a number.

**Syntax:**
```basic
result = frac(number)
```

**Parameters:**
- `number`: Any numeric value

**Returns:** Fractional portion (number - int(number))

**Example:**
```basic
println frac(3.75)    ' Output: 0.75
println frac(-3.75)   ' Output: -0.75
println frac(5.0)     ' Output: 0
```

---

## Basic Math Functions

### abs()

Returns the absolute value of a number.

**Syntax:**
```basic
result = abs(number)
```

**Parameters:**
- `number`: Any numeric value

**Returns:** Absolute value (always non-negative)

**Example:**
```basic
println abs(5)        ' Output: 5
println abs(-5)       ' Output: 5
println abs(-3.14)    ' Output: 3.14
```

---

### sgn()

Returns the sign of a number.

**Syntax:**
```basic
result = sgn(number)
```

**Parameters:**
- `number`: Any numeric value

**Returns:**
- `1` if number > 0
- `0` if number = 0
- `-1` if number < 0

**Example:**
```basic
println sgn(42)       ' Output: 1
println sgn(0)        ' Output: 0
println sgn(-17)      ' Output: -1
```

---

### sqr()

Returns the square root of a number.

**Syntax:**
```basic
result = sqr(number)
```

**Parameters:**
- `number`: Non-negative numeric value

**Returns:** Square root of the number

**Example:**
```basic
println sqr(16)       ' Output: 4
println sqr(2)        ' Output: 1.41421356...
println sqr(0)        ' Output: 0
```

**Note:** Passing a negative number will result in an error or NaN.

---

### exp()

Returns e raised to the specified power (exponential function).

**Syntax:**
```basic
result = exp(number)
```

**Parameters:**
- `number`: The exponent value

**Returns:** e^number (approximately 2.71828^number)

**Example:**
```basic
println exp(0)        ' Output: 1
println exp(1)        ' Output: 2.71828...
println exp(2)        ' Output: 7.38905...
```

---

### ln()

Returns the natural logarithm (base e) of a number.

**Syntax:**
```basic
result = ln(number)
```

**Parameters:**
- `number`: Positive numeric value

**Returns:** Natural logarithm of the number

**Example:**
```basic
println ln(1)              ' Output: 0
println ln(2.71828)        ' Output: ~1
println ln(10)             ' Output: 2.302585...
```

**Note:** The argument must be positive. `ln(0)` is undefined (negative infinity).

---

### log2()

Returns the base-2 logarithm of a number.

**Syntax:**
```basic
result = log2(number)
```

**Parameters:**
- `number`: Positive numeric value

**Returns:** Base-2 logarithm of the number

**Example:**
```basic
println log2(1)       ' Output: 0
println log2(2)       ' Output: 1
println log2(8)       ' Output: 3
println log2(1024)    ' Output: 10
```

---

### log10()

Returns the base-10 logarithm (common logarithm) of a number.

**Syntax:**
```basic
result = log10(number)
```

**Parameters:**
- `number`: Positive numeric value

**Returns:** Base-10 logarithm of the number

**Example:**
```basic
println log10(1)      ' Output: 0
println log10(10)     ' Output: 1
println log10(100)    ' Output: 2
println log10(1000)   ' Output: 3
```

---

## Trigonometric Functions

**Important:** All trigonometric functions work with **radians**, not degrees. Use `degtorad()` to convert degrees to radians before calling these functions.

### sin()

Returns the sine of an angle in radians.

**Syntax:**
```basic
result = sin(radians)
```

**Parameters:**
- `radians`: Angle in radians

**Returns:** Sine of the angle (range: -1 to 1)

**Example:**
```basic
pi = acos(-1)
println sin(0)            ' Output: 0
println sin(pi / 2)       ' Output: 1
println sin(pi)           ' Output: 0 (or very small number)

' Using degrees
println sin(degtorad(30)) ' Output: 0.5
println sin(degtorad(90)) ' Output: 1
```

---

### cos()

Returns the cosine of an angle in radians.

**Syntax:**
```basic
result = cos(radians)
```

**Parameters:**
- `radians`: Angle in radians

**Returns:** Cosine of the angle (range: -1 to 1)

**Example:**
```basic
pi = acos(-1)
println cos(0)            ' Output: 1
println cos(pi / 2)       ' Output: 0 (or very small number)
println cos(pi)           ' Output: -1

' Using degrees
println cos(degtorad(60)) ' Output: 0.5
println cos(degtorad(0))  ' Output: 1
```

---

### tan()

Returns the tangent of an angle in radians.

**Syntax:**
```basic
result = tan(radians)
```

**Parameters:**
- `radians`: Angle in radians

**Returns:** Tangent of the angle

**Example:**
```basic
pi = acos(-1)
println tan(0)            ' Output: 0
println tan(pi / 4)       ' Output: 1

' Using degrees
println tan(degtorad(45)) ' Output: 1
```

**Note:** `tan()` is undefined at π/2, 3π/2, etc. (90°, 270°, ...).

---

## Inverse Trigonometric Functions

### asin()

Returns the arc sine (inverse sine) of a number in radians.

**Syntax:**
```basic
result = asin(value)
```

**Parameters:**
- `value`: Number in the range -1 to 1

**Returns:** Angle in radians (range: -π/2 to π/2)

**Example:**
```basic
println asin(0)           ' Output: 0
println asin(1)           ' Output: 1.5707... (π/2)
println asin(0.5)         ' Output: 0.5235... (π/6, i.e., 30°)

' Convert to degrees
println radtodeg(asin(0.5))   ' Output: 30
```

---

### acos()

Returns the arc cosine (inverse cosine) of a number in radians.

**Syntax:**
```basic
result = acos(value)
```

**Parameters:**
- `value`: Number in the range -1 to 1

**Returns:** Angle in radians (range: 0 to π)

**Example:**
```basic
println acos(1)           ' Output: 0
println acos(0)           ' Output: 1.5707... (π/2)
println acos(-1)          ' Output: 3.1415... (π)

' Use acos(-1) to get π
pi = acos(-1)
println pi                ' Output: 3.14159265...
```

---

### atan()

Returns the arc tangent (inverse tangent) of a number in radians.

**Syntax:**
```basic
result = atan(value)
```

**Parameters:**
- `value`: Any numeric value

**Returns:** Angle in radians (range: -π/2 to π/2)

**Example:**
```basic
println atan(0)           ' Output: 0
println atan(1)           ' Output: 0.7853... (π/4, i.e., 45°)

' Use atan(1) * 4 to get π
pi = atan(1) * 4
println pi                ' Output: 3.14159265...
```

---

### atan2()

Returns the arc tangent of y/x, using the signs of both arguments to determine the quadrant of the result. This provides a full 360° range.

**Syntax:**
```basic
result = atan2(y, x)
```

**Parameters:**
- `y`: Y-coordinate (numerator)
- `x`: X-coordinate (denominator)

**Returns:** Angle in radians (range: -π to π)

**Example:**
```basic
pi = acos(-1)

' Point (1, 1) is at 45°
println radtodeg(atan2(1, 1))      ' Output: 45

' Point (-1, 1) is at 135°
println radtodeg(atan2(1, -1))     ' Output: 135

' Point (-1, -1) is at -135° (or 225°)
println radtodeg(atan2(-1, -1))    ' Output: -135

' Point (1, -1) is at -45° (or 315°)
println radtodeg(atan2(-1, 1))     ' Output: -45
```

**Note:** `atan2()` is preferred over `atan(y/x)` because it handles all quadrants correctly and avoids division by zero when x=0.

---

## Hyperbolic Functions

### sinh()

Returns the hyperbolic sine of a number.

**Syntax:**
```basic
result = sinh(number)
```

**Parameters:**
- `number`: Any numeric value

**Returns:** Hyperbolic sine: (e^x - e^(-x)) / 2

**Example:**
```basic
println sinh(0)       ' Output: 0
println sinh(1)       ' Output: 1.1752...
println sinh(-1)      ' Output: -1.1752...
```

---

### cosh()

Returns the hyperbolic cosine of a number.

**Syntax:**
```basic
result = cosh(number)
```

**Parameters:**
- `number`: Any numeric value

**Returns:** Hyperbolic cosine: (e^x + e^(-x)) / 2

**Example:**
```basic
println cosh(0)       ' Output: 1
println cosh(1)       ' Output: 1.5430...
println cosh(-1)      ' Output: 1.5430... (same as cosh(1))
```

---

### tanh()

Returns the hyperbolic tangent of a number.

**Syntax:**
```basic
result = tanh(number)
```

**Parameters:**
- `number`: Any numeric value

**Returns:** Hyperbolic tangent: sinh(x) / cosh(x), range: -1 to 1

**Example:**
```basic
println tanh(0)       ' Output: 0
println tanh(1)       ' Output: 0.7615...
println tanh(10)      ' Output: 0.9999... (approaches 1)
```

---

## Inverse Hyperbolic Functions

### asinh()

Returns the inverse hyperbolic sine of a number.

**Syntax:**
```basic
result = asinh(number)
```

**Parameters:**
- `number`: Any numeric value

**Returns:** Inverse hyperbolic sine

**Example:**
```basic
println asinh(0)      ' Output: 0
println asinh(1)      ' Output: 0.8813...
```

---

### acosh()

Returns the inverse hyperbolic cosine of a number.

**Syntax:**
```basic
result = acosh(number)
```

**Parameters:**
- `number`: Value >= 1

**Returns:** Inverse hyperbolic cosine

**Example:**
```basic
println acosh(1)      ' Output: 0
println acosh(2)      ' Output: 1.3169...
```

**Note:** The argument must be >= 1.

---

### atanh()

Returns the inverse hyperbolic tangent of a number.

**Syntax:**
```basic
result = atanh(number)
```

**Parameters:**
- `number`: Value in the range -1 < number < 1

**Returns:** Inverse hyperbolic tangent

**Example:**
```basic
println atanh(0)      ' Output: 0
println atanh(0.5)    ' Output: 0.5493...
```

**Note:** The argument must be strictly between -1 and 1.

---

## Angle Conversion

### degtorad()

Converts an angle from degrees to radians.

**Syntax:**
```basic
radians = degtorad(degrees)
```

**Parameters:**
- `degrees`: Angle in degrees

**Returns:** Angle in radians

**Formula:** radians = degrees × π / 180

**Example:**
```basic
println degtorad(0)       ' Output: 0
println degtorad(90)      ' Output: 1.5707... (π/2)
println degtorad(180)     ' Output: 3.1415... (π)
println degtorad(360)     ' Output: 6.2831... (2π)

' Use with trigonometric functions
println sin(degtorad(30)) ' Output: 0.5
println cos(degtorad(60)) ' Output: 0.5
```

---

### radtodeg()

Converts an angle from radians to degrees.

**Syntax:**
```basic
degrees = radtodeg(radians)
```

**Parameters:**
- `radians`: Angle in radians

**Returns:** Angle in degrees

**Formula:** degrees = radians × 180 / π

**Example:**
```basic
pi = acos(-1)
println radtodeg(0)       ' Output: 0
println radtodeg(pi/2)    ' Output: 90
println radtodeg(pi)      ' Output: 180
println radtodeg(2*pi)    ' Output: 360

' Convert result of inverse trig functions
angle = asin(0.5)
println radtodeg(angle)   ' Output: 30
```

---

## Comparison Functions

### max()

Returns the larger of two numbers.

**Syntax:**
```basic
result = max(number1, number2)
```

**Parameters:**
- `number1`: First numeric value
- `number2`: Second numeric value

**Returns:** The larger of the two values

**Example:**
```basic
println max(5, 10)        ' Output: 10
println max(-3, -7)       ' Output: -3
println max(3.14, 2.71)   ' Output: 3.14
```

**Note:** For comparing more than two values, nest the calls: `max(max(a, b), c)`

---

### min()

Returns the smaller of two numbers.

**Syntax:**
```basic
result = min(number1, number2)
```

**Parameters:**
- `number1`: First numeric value
- `number2`: Second numeric value

**Returns:** The smaller of the two values

**Example:**
```basic
println min(5, 10)        ' Output: 5
println min(-3, -7)       ' Output: -7
println min(3.14, 2.71)   ' Output: 2.71
```

---

### cmpval()

Compares two numeric values and returns the relationship.

**Syntax:**
```basic
result = cmpval(number1, number2)
result = cmpval(number1, number2, epsilon)
```

**Parameters:**
- `number1`: First numeric value
- `number2`: Second numeric value
- `epsilon` (optional): Tolerance for floating-point comparison

**Returns:**
- `-1` if number1 < number2
- `0` if number1 = number2 (within epsilon tolerance if provided)
- `1` if number1 > number2

**Example:**
```basic
println cmpval(5, 10)         ' Output: -1
println cmpval(10, 10)        ' Output: 0
println cmpval(15, 10)        ' Output: 1

' With epsilon tolerance (useful for floating-point)
a = 0.1 + 0.2
b = 0.3
println cmpval(a, b, 0.0001)  ' Output: 0 (considered equal)
```

---

## Random Number Generation

### randomize()

Initializes the random number generator with a seed based on the current time. Call this once at the start of your program to ensure different random sequences each run.

**Syntax:**
```basic
randomize()
```

**Returns:** 1 (always)

**Example:**
```basic
randomize()   ' Initialize random seed
println rnd() ' Now generates unpredictable values
```

---

### rnd()

Returns a random floating-point number between 0 (inclusive) and 1 (exclusive).

**Syntax:**
```basic
result = rnd()
```

**Returns:** Random number in the range [0, 1)

**Example:**
```basic
randomize()
for i = 1 to 5
    println rnd()
next
' Output: Five random numbers like 0.123, 0.876, 0.445, etc.
```

---

### rnd() with argument

Returns a random integer from 0 to (max - 1).

**Syntax:**
```basic
result = rnd(max)
```

**Parameters:**
- `max`: Upper bound (exclusive)

**Returns:** Random integer in the range [0, max - 1]

**Example:**
```basic
randomize()

' Simulate a die roll (1 to 6)
die = rnd(6) + 1
println "Die roll: "; die

' Random number from 0 to 99
println rnd(100)

' Random number from 1 to 10
println rnd(10) + 1
```

---

## Complete Examples

### Example 1: Calculating π

```basic
' Different ways to calculate π
println "=== Calculating Pi ==="

' Method 1: Using acos
pi1 = acos(-1)
println "acos(-1) = "; pi1

' Method 2: Using atan
pi2 = atan(1) * 4
println "atan(1) * 4 = "; pi2

' Method 3: Using asin
pi3 = asin(1) * 2
println "asin(1) * 2 = "; pi3
```

---

### Example 2: Distance Calculator (2D and 3D)

```basic
' Calculate distance between points
function distance2D(x1, y1, x2, y2) local dx, dy
    dx = x2 - x1
    dy = y2 - y1
    return sqr(dx * dx + dy * dy)
endfunction

function distance3D(x1, y1, z1, x2, y2, z2) local dx, dy, dz
    dx = x2 - x1
    dy = y2 - y1
    dz = z2 - z1
    return sqr(dx * dx + dy * dy + dz * dz)
endfunction

println "=== Distance Calculator ==="

' 2D distance from (0,0) to (3,4)
d1 = distance2D(0, 0, 3, 4)
println "Distance (0,0) to (3,4): "; d1

' 3D distance from origin to (1,2,2)
d2 = distance3D(0, 0, 0, 1, 2, 2)
println "Distance (0,0,0) to (1,2,2): "; d2
```

---

### Example 3: Trigonometry - Right Triangle Solver

```basic
' Right Triangle Solver
' Given two sides, find the third and all angles

println "=== Right Triangle Solver ==="
println "Given: a = 3, b = 4 (legs)"

a = 3
b = 4

' Find hypotenuse using Pythagorean theorem
c = sqr(a * a + b * b)
println "Hypotenuse c = "; c

' Find angles
angleA = radtodeg(atan(a / b))
angleB = radtodeg(atan(b / a))
angleC = 90

println ""
println "Angles:"
println "  Angle A (opposite to a): "; angleA; " degrees"
println "  Angle B (opposite to b): "; angleB; " degrees"
println "  Angle C (right angle): "; angleC; " degrees"
println "  Sum of angles: "; angleA + angleB + angleC
```

---

### Example 4: Dice Roller

```basic
' Dice Roller Simulation
println "=== Dice Roller ==="

randomize()

' Roll multiple dice
numDice = 5
println "Rolling "; numDice; " dice:"

total = 0
for i = 1 to numDice
    roll = rnd(6) + 1
    println "  Die "; i; ": "; roll
    total = total + roll
next

println ""
println "Total: "; total
println "Average: "; total / numDice
```

---

### Example 5: Quadratic Equation Solver

```basic
' Quadratic Equation Solver: ax² + bx + c = 0
function solveQuadratic(a, b, c) local discriminant, sqrtD, x1, x2
    println "Equation: "; a; "x² + "; b; "x + "; c; " = 0"
    
    discriminant = b * b - 4 * a * c
    
    if discriminant < 0 then
        println "No real solutions (discriminant < 0)"
        return 0
    endif
    
    if discriminant = 0 then
        x1 = -b / (2 * a)
        println "One solution: x = "; x1
        return 1
    endif
    
    sqrtD = sqr(discriminant)
    x1 = (-b + sqrtD) / (2 * a)
    x2 = (-b - sqrtD) / (2 * a)
    println "Two solutions: x1 = "; x1; ", x2 = "; x2
    return 2
endfunction

println "=== Quadratic Equation Solver ==="
println ""

' Example 1: x² - 5x + 6 = 0 (solutions: 2, 3)
solveQuadratic(1, -5, 6)
println ""

' Example 2: x² - 4x + 4 = 0 (one solution: 2)
solveQuadratic(1, -4, 4)
println ""

' Example 3: x² + x + 1 = 0 (no real solutions)
solveQuadratic(1, 1, 1)
```

---

### Example 6: Circle Calculations

```basic
' Circle Calculator
println "=== Circle Calculator ==="

pi = acos(-1)
radius = 5

println "Radius: "; radius
println ""

' Area = π × r²
area = pi * radius * radius
println "Area: "; area

' Circumference = 2 × π × r
circumference = 2 * pi * radius
println "Circumference: "; circumference

' Diameter
diameter = 2 * radius
println "Diameter: "; diameter

println ""
println "Points on the circle (every 45 degrees):"
for angle = 0 to 315 step 45
    rad = degtorad(angle)
    x = radius * cos(rad)
    y = radius * sin(rad)
    println "  "; angle; "°: ("; round(x * 100) / 100; ", "; round(y * 100) / 100; ")"
next
```

---

### Example 7: Monte Carlo Pi Estimation

```basic
' Estimate π using Monte Carlo method
println "=== Monte Carlo Pi Estimation ==="

randomize()

iterations = 1000
insideCircle = 0

for i = 1 to iterations
    x = rnd() * 2 - 1  ' Random x from -1 to 1
    y = rnd() * 2 - 1  ' Random y from -1 to 1
    
    ' Check if point is inside unit circle
    distance = sqr(x * x + y * y)
    if distance <= 1 then
        insideCircle = insideCircle + 1
    endif
next

' π ≈ 4 × (points inside circle / total points)
estimatedPi = 4 * insideCircle / iterations

println "Iterations: "; iterations
println "Points inside circle: "; insideCircle
println "Estimated π: "; estimatedPi
println "Actual π: "; acos(-1)
println "Error: "; abs(estimatedPi - acos(-1))
```

---

## Quick Reference

### Rounding & Truncation
```basic
cint(n)       ' Truncate toward zero (remove fraction)
fix(n)        ' Same as cint
int(n)        ' Floor (largest integer <= n)
round(n)      ' Round to nearest integer
frac(n)       ' Fractional part only
```

### Basic Math
```basic
abs(n)        ' Absolute value
sgn(n)        ' Sign: -1, 0, or 1
sqr(n)        ' Square root
exp(n)        ' e^n (exponential)
ln(n)         ' Natural logarithm (base e)
log2(n)       ' Logarithm base 2
log10(n)      ' Logarithm base 10
```

### Trigonometric (radians)
```basic
sin(r)        ' Sine
cos(r)        ' Cosine
tan(r)        ' Tangent
```

### Inverse Trigonometric
```basic
asin(n)       ' Arc sine (returns radians)
acos(n)       ' Arc cosine (returns radians)
atan(n)       ' Arc tangent (returns radians)
atan2(y, x)   ' Arc tangent of y/x (full quadrant)
```

### Hyperbolic
```basic
sinh(n)       ' Hyperbolic sine
cosh(n)       ' Hyperbolic cosine
tanh(n)       ' Hyperbolic tangent
```

### Inverse Hyperbolic
```basic
asinh(n)      ' Inverse hyperbolic sine
acosh(n)      ' Inverse hyperbolic cosine (n >= 1)
atanh(n)      ' Inverse hyperbolic tangent (-1 < n < 1)
```

### Angle Conversion
```basic
degtorad(d)   ' Degrees → Radians
radtodeg(r)   ' Radians → Degrees
```

### Comparison
```basic
max(a, b)         ' Larger of two values
min(a, b)         ' Smaller of two values
cmpval(a, b)      ' Compare: -1, 0, or 1
cmpval(a, b, eps) ' Compare with tolerance
```

### Random Numbers
```basic
randomize()   ' Initialize random seed
rnd()         ' Random float [0, 1)
rnd(n)        ' Random integer [0, n-1]
```

### Useful Constants (calculated)
```basic
pi = acos(-1)         ' 3.14159265...
e = exp(1)            ' 2.71828182...
```

---

*End of NumLib Documentation*
