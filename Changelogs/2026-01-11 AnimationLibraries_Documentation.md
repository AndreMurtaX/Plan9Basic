# Plan9Basic Animation Libraries

## User Guide - Version 1.0

---

## Table of Contents

1. [Introduction](#introduction)
2. [Animation Concepts](#animation-concepts)
3. [FloatAnimationLib](#floatanimationlib)
4. [ColorAnimationLib](#coloranimationlib)
5. [IntAnimationLib](#intanimationlib)
6. [Animation Types and Interpolation](#animation-types-and-interpolation)
7. [Event Callbacks](#event-callbacks)
8. [Common Patterns](#common-patterns)
9. [Function Reference](#function-reference)
10. [Error Handling](#error-handling)

---

## Introduction

Plan9Basic provides three animation libraries that allow you to create smooth, professional animations for your applets:

| Library | Purpose | Use Cases |
|---------|---------|-----------|
| **FloatAnimationLib** | Animate numeric properties | Position, size, opacity, rotation |
| **ColorAnimationLib** | Animate color properties | Color transitions, highlights, fades |
| **IntAnimationLib** | Animate integer properties | Counters, discrete values |

Animations work by smoothly changing a property value from a start value to an end value over a specified duration. The animation system handles all the intermediate calculations automatically.

---

## Animation Concepts

### How Animations Work

1. **Create** an animation object attached to a visual control
2. **Configure** the target property, start/end values, and duration
3. **Start** the animation
4. **Respond** to completion via callbacks (optional)

### Key Terms

| Term | Description |
|------|-------------|
| **PropertyName** | The name of the property to animate (e.g., "Opacity", "Position.X") |
| **StartValue** | The initial value when animation begins |
| **StopValue** | The final value when animation ends |
| **Duration** | Time in seconds for the animation to complete |
| **Delay** | Time in seconds to wait before starting |
| **Loop** | Whether to repeat the animation continuously |
| **AutoReverse** | Whether to play backwards after completing |

### Parent-Child Relationship

Animations are attached to controls as children. When you create an animation with `floatani#(control#)`, the animation becomes a child of that control and will animate its properties.

---

## FloatAnimationLib

The most versatile animation library. Use it to animate any numeric property.

### Creating a Float Animation

```basic
' Basic creation - attach to a control
let ani# = floatani#(myControl#)

' Creation with a name (useful for debugging)
let ani# = floatani#(myControl#, "FadeAnimation")
```

### Animatable Properties

| Property Path | Description | Example Values |
|---------------|-------------|----------------|
| `Opacity` | Transparency (0.0 = invisible, 1.0 = visible) | 0.0 to 1.0 |
| `Position.X` | Horizontal position | Any number |
| `Position.Y` | Vertical position | Any number |
| `Width` | Control width | Positive numbers |
| `Height` | Control height | Positive numbers |
| `RotationAngle` | Rotation in degrees | 0 to 360 |
| `Scale.X` | Horizontal scale | 0.0 to any |
| `Scale.Y` | Vertical scale | 0.0 to any |

### Basic Example: Fade Out

```basic
' Create a rectangle and fade it out
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 200, 100)
rectangle_fill#(rect#, "Blue")

' Create fade animation
let fadeAni# = floatani#(rect#)
floatani_propertyname#(fadeAni#, "Opacity")
floatani_startvalue#(fadeAni#, 1.0)
floatani_stopvalue#(fadeAni#, 0.0)
floatani_duration#(fadeAni#, 2.0)
floatani_start(fadeAni#)
```

### Movement Animation

```basic
' Move a button from left to right
let btn# = button#(frm#, "Moving Button")
button_bounds#(btn#, 10, 100, 100, 30)

let moveAni# = floatani#(btn#)
floatani_propertyname#(moveAni#, "Position.X")
floatani_startvalue#(moveAni#, 10)
floatani_stopvalue#(moveAni#, 300)
floatani_duration#(moveAni#, 3.0)
floatani_start(moveAni#)
```

### Pulsing Animation (Loop + AutoReverse)

```basic
' Create a pulsing effect
let pulseAni# = floatani#(rect#)
floatani_propertyname#(pulseAni#, "Opacity")
floatani_startvalue#(pulseAni#, 1.0)
floatani_stopvalue#(pulseAni#, 0.3)
floatani_duration#(pulseAni#, 0.8)
floatani_loop#(pulseAni#, 1)
floatani_autoreverse#(pulseAni#, 1)
floatani_start(pulseAni#)
```

---

## ColorAnimationLib

Animate color properties for smooth color transitions.

### Creating a Color Animation

```basic
let colorAni# = colorani#(myControl#)
let colorAni# = colorani#(myControl#, "HighlightAnimation")
```

### Color Utility Functions

ColorAnimationLib provides utility functions for working with colors:

| Function | Description | Example |
|----------|-------------|---------|
| `colortoalphacolor(name$)` | Convert color name or hex to number | `colortoalphacolor("Blue")` |
| `alphacolortostring$(color)` | Convert color number to hex string | `alphacolortostring$(color)` → "#FF0000FF" |
| `rgb(r, g, b)` | Create color from RGB (0-255) | `rgb(255, 0, 0)` → Red |
| `rgba(r, g, b, a)` | Create color from RGBA (0-255) | `rgba(255, 0, 0, 128)` → Semi-transparent red |

### Working with Colors

Colors in Plan9Basic animations are numeric values (TAlphaColor format). Use the utility functions:

```basic
' Convert named color to number
let blueColor = colortoalphacolor("Blue")
let redColor = colortoalphacolor("Red")

' Use hex format
let customColor = colortoalphacolor("#FF5500")

' Use RGB values
let orangeColor = rgb(255, 165, 0)

' Use RGBA for transparency
let semiTransparent = rgba(0, 0, 255, 128)
```

### Common Color Names

`Black`, `White`, `Red`, `Green`, `Blue`, `Yellow`, `Orange`, `Purple`, `Gray`, `Silver`, `Navy`, `Maroon`

### Animatable Color Properties

| Property Path | Description |
|---------------|-------------|
| `Fill.Color` | Shape fill color |
| `Stroke.Color` | Shape border color |
| `TextSettings.FontColor` | Text color |

### Basic Example: Color Transition

```basic
' Change rectangle from blue to red
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 200, 100)
rectangle_fill#(rect#, "Blue")

let colorAni# = colorani#(rect#)
colorani_propertyname#(colorAni#, "Fill.Color")
colorani_startvalue#(colorAni#, colortoalphacolor("Blue"))
colorani_stopvalue#(colorAni#, colortoalphacolor("Red"))
colorani_duration#(colorAni#, 2.0)
colorani_start(colorAni#)
```

### Highlight Effect

```basic
' Flash a control yellow then back to white
let highlightAni# = colorani#(panel#)
colorani_propertyname#(highlightAni#, "Fill.Color")
colorani_startvalue#(highlightAni#, colortoalphacolor("Yellow"))
colorani_stopvalue#(highlightAni#, colortoalphacolor("White"))
colorani_duration#(highlightAni#, 0.5)
colorani_start(highlightAni#)
```

---

## IntAnimationLib

Animate integer properties. Less commonly used than FloatAnimation, but useful for specific scenarios.

### Creating an Integer Animation

```basic
let intAni# = intani#(myControl#)
let intAni# = intani#(myControl#, "CounterAnimation")
```

### Use Cases

- Animating the `Tag` property for custom tracking
- Animating discrete values like grid column counts
- Creating counter displays (with OnProcess callback)

### Counter Example

```basic
' Animate a counter from 0 to 100
let lbl# = label#(frm#, "0")
label_move#(lbl#, 50, 50)

let counterAni# = intani#(lbl#)
intani_propertyname#(counterAni#, "Tag")
intani_startvalue#(counterAni#, 0)
intani_stopvalue#(counterAni#, 100)
intani_duration#(counterAni#, 5.0)
intani_onprocess#(counterAni#, "UpdateCounter")
intani_start(counterAni#)

function UpdateCounter(sender#) local tagVal
  tagVal = label_tag(label#)
  label_text#(label#, str$(tagVal))
endfunction
```

---

## Animation Types and Interpolation

### Animation Types

Control how the animation accelerates/decelerates:

| Type | Description | Best For |
|------|-------------|----------|
| `In` | Starts slow, ends fast | Building momentum |
| `Out` | Starts fast, ends slow | Natural stopping |
| `InOut` | Slow start, fast middle, slow end | Smooth transitions |

```basic
floatani_animationtype#(ani#, "Out")
```

### Interpolation Types

Control the mathematical curve of the animation:

| Interpolation | Description | Visual Effect |
|---------------|-------------|---------------|
| `Linear` | Constant speed | Mechanical, robotic |
| `Quadratic` | Gentle curve | Smooth, natural |
| `Cubic` | More pronounced curve | Snappy |
| `Quartic` | Even more pronounced | Very snappy |
| `Quintic` | Extreme curve | Dramatic |
| `Sinusoidal` | Sine wave based | Gentle, wave-like |
| `Exponential` | Exponential curve | Explosive start/end |
| `Circular` | Circular curve | Round motion feel |
| `Elastic` | Springy overshoot | Bouncy, playful |
| `Back` | Overshoots then returns | Anticipation effect |
| `Bounce` | Bouncing effect | Ball-like bouncing |

```basic
floatani_interpolation#(ani#, "Elastic")
```

### Recommended Combinations

| Effect | AnimationType | Interpolation |
|--------|---------------|---------------|
| Smooth fade | `InOut` | `Quadratic` |
| Button press | `Out` | `Cubic` |
| Bounce in | `Out` | `Bounce` |
| Elastic snap | `Out` | `Elastic` |
| Linear motion | (any) | `Linear` |

---

## Event Callbacks

### OnFinish

Called when the animation completes. If looping, only called when the animation is stopped.

```basic
floatani_onfinish#(ani#, "AnimationDone")

function AnimationDone(sender#)
  println "Animation completed!"
endfunction
```

### OnProcess

Called on every animation frame. **Use sparingly** - this fires many times per second!

```basic
floatani_onprocess#(ani#, "AnimationProgress")

function AnimationProgress(sender#) local progress
  progress = floatani_normalizedtime(sender#)
  ' progress is 0.0 to 1.0
endfunction
```

### Clearing Callbacks

```basic
' Remove a specific callback
floatani_onfinish#(ani#, "")

' Remove all callbacks
floatani_clearcallbacks#(ani#)
```

---

## Common Patterns

### Sequential Animations

Chain animations using OnFinish:

```basic
let ani1# = floatani#(rect#)
' ... configure ani1 ...
floatani_onfinish#(ani1#, "StartSecondAnimation")
floatani_start(ani1#)

function StartSecondAnimation(sender#)
  floatani_propertyname#(ani2#, "Position.Y")
  floatani_startvalue#(ani2#, 0)
  floatani_stopvalue#(ani2#, 200)
  floatani_duration#(ani2#, 1.0)
  floatani_start(ani2#)
endfunction
```

### Parallel Animations

Start multiple animations at once:

```basic
' Animate both X and Y simultaneously
let aniX# = floatani#(rect#)
floatani_propertyname#(aniX#, "Position.X")
floatani_startvalue#(aniX#, 0)
floatani_stopvalue#(aniX#, 300)
floatani_duration#(aniX#, 2.0)

let aniY# = floatani#(rect#)
floatani_propertyname#(aniY#, "Position.Y")
floatani_startvalue#(aniY#, 0)
floatani_stopvalue#(aniY#, 200)
floatani_duration#(aniY#, 2.0)

' Start both at the same time
floatani_start(aniX#)
floatani_start(aniY#)
```

### Start From Current Value

Use `StartFromCurrent` to animate from whatever the current value is:

```basic
floatani_startfromcurrent#(ani#, 1)
floatani_stopvalue#(ani#, 0)
floatani_start(ani#)  ' Starts from current opacity
```

### Delayed Animation

```basic
floatani_delay#(ani#, 1.5)  ' Wait 1.5 seconds before starting
floatani_start(ani#)
```

### Stopping Animations

```basic
' Stop immediately (jumps to current position)
floatani_stopatcurrent(ani#)

' Stop and reset
floatani_stop(ani#)
```

---

## Function Reference

### FloatAnimationLib Functions

#### Creation and Destruction
| Function | Description |
|----------|-------------|
| `floatani#(parent#)` | Create animation attached to parent |
| `floatani#(parent#, name$)` | Create named animation |
| `floatani_free(ani#)` | Destroy animation |

#### Core Properties
| Function | Description |
|----------|-------------|
| `floatani_propertyname#(ani#, name$)` | Set property to animate |
| `floatani_propertyname$(ani#)` | Get property name |
| `floatani_startvalue#(ani#, value)` | Set start value |
| `floatani_startvalue(ani#)` | Get start value |
| `floatani_stopvalue#(ani#, value)` | Set end value |
| `floatani_stopvalue(ani#)` | Get end value |
| `floatani_duration#(ani#, seconds)` | Set duration |
| `floatani_duration(ani#)` | Get duration |
| `floatani_delay#(ani#, seconds)` | Set delay before start |
| `floatani_delay(ani#)` | Get delay |

#### Behavior
| Function | Description |
|----------|-------------|
| `floatani_animationtype#(ani#, type$)` | Set type: "In", "Out", "InOut" |
| `floatani_animationtype$(ani#)` | Get animation type |
| `floatani_interpolation#(ani#, type$)` | Set interpolation curve |
| `floatani_interpolation$(ani#)` | Get interpolation |
| `floatani_loop#(ani#, value)` | Set looping (0/1) |
| `floatani_loop(ani#)` | Get loop state |
| `floatani_autoreverse#(ani#, value)` | Set auto-reverse (0/1) |
| `floatani_autoreverse(ani#)` | Get auto-reverse state |
| `floatani_inverse#(ani#, value)` | Play in reverse (0/1) |
| `floatani_inverse(ani#)` | Get inverse state |
| `floatani_startfromcurrent#(ani#, value)` | Use current value as start (0/1) |
| `floatani_startfromcurrent(ani#)` | Get start-from-current state |
| `floatani_enabled#(ani#, value)` | Enable/disable (0/1) |
| `floatani_enabled(ani#)` | Get enabled state |

#### Control
| Function | Description |
|----------|-------------|
| `floatani_start(ani#)` | Start the animation |
| `floatani_stop(ani#)` | Stop the animation |
| `floatani_stopatcurrent(ani#)` | Stop at current position |

#### State
| Function | Description |
|----------|-------------|
| `floatani_running(ani#)` | Check if running (0/1) |
| `floatani_normalizedtime(ani#)` | Get progress (0.0 to 1.0) |
| `floatani_name$(ani#)` | Get animation name |

#### Events
| Function | Description |
|----------|-------------|
| `floatani_onfinish#(ani#, callback$)` | Set finish callback |
| `floatani_onfinish$(ani#)` | Get finish callback name |
| `floatani_onprocess#(ani#, callback$)` | Set process callback |
| `floatani_onprocess$(ani#)` | Get process callback name |
| `floatani_clearcallbacks#(ani#)` | Clear all callbacks |

#### Triggers (Advanced)
| Function | Description |
|----------|-------------|
| `floatani_trigger#(ani#, trigger$)` | Set trigger condition |
| `floatani_trigger$(ani#)` | Get trigger |
| `floatani_triggerinverse#(ani#, trigger$)` | Set inverse trigger |
| `floatani_triggerinverse$(ani#)` | Get inverse trigger |

#### Error Handling
| Function | Description |
|----------|-------------|
| `floatani_error()` | Get last error code |
| `floatani_errormsg$()` | Get last error message |
| `floatani_strerror$(code)` | Convert error code to message |
| `floatani_clearerror()` | Clear error state |

### ColorAnimationLib Functions

Same pattern as FloatAnimationLib, with `colorani_` prefix.

**Note:** `StartValue` and `StopValue` expect color values as numbers (use `colortoalphacolor()` to convert).

#### Color Utility Functions
| Function | Description |
|----------|-------------|
| `colortoalphacolor(name$)` | Convert color name or "#RRGGBB" to number |
| `alphacolortostring$(color)` | Convert color number to "#AARRGGBB" string |
| `rgb(r, g, b)` | Create opaque color from RGB (0-255) |
| `rgba(r, g, b, a)` | Create color from RGBA (0-255) |

**Supported color names:** Black, White, Red, Green, Blue, Yellow, Cyan, Magenta, Gray/Grey, Silver, Navy, Maroon, Purple, Orange, Lime, Aqua, Teal, Olive, Fuchsia, Pink

### IntAnimationLib Functions

Same pattern as FloatAnimationLib, with `intani_` prefix.

**Note:** `StartValue` and `StopValue` are truncated to integers.

---

## Error Handling

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_NIL_ANIMATION | Animation pointer is nil |
| 2 | ERR_INVALID_PROPERTY | Invalid property name or object |
| 3 | ERR_INVALID_VALUE | Invalid value provided |
| 4 | ERR_ANIMATION_RUNNING | Cannot modify while running |

### Checking for Errors

```basic
floatani_propertyname#(ani#, "InvalidProperty")
if floatani_error() <> 0 then
  println "Error: " + floatani_errormsg$()
  floatani_clearerror()
endif
```

---

## Tips and Best Practices

1. **Choose the right animation type**: Use `FloatAnimationLib` for most visual animations. `ColorAnimationLib` only for colors. `IntAnimationLib` rarely needed.

2. **Avoid OnProcess when possible**: It fires every frame and can slow down your applet. Use OnFinish instead.

3. **Use meaningful durations**: 0.2-0.5 seconds for quick feedback, 1-2 seconds for transitions, 3+ seconds for dramatic effects.

4. **Combine animations**: Use parallel animations for complex effects (e.g., move + fade simultaneously).

5. **Clean up**: Call `floatani_free()` when animations are no longer needed, especially in long-running applets.

6. **Test interpolations**: Different interpolation types can dramatically change the feel of your animation. Experiment!

---

## Version History

- **1.0.0** - Initial release with FloatAnimationLib, ColorAnimationLib, and IntAnimationLib

---

*Plan9Basic Animation Libraries Documentation - Copyright (c) 2024-2025 Plan9Basic Project*
