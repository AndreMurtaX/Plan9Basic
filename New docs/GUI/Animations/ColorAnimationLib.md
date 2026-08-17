# ColorAnimationLib

Animates color properties of visual controls. Essential for color transitions, hover effects, and visual feedback in Plan9Basic applications.

## Functions

| Function | Description |
|----------|-------------|
| `colorani#(parent#)` | Creates a color animation attached to parent control |
| `colorani#(parent#, name$)` | Creates a named color animation |
| `colorani_free(ani#)` | Frees the animation object |
| `colorani_start(ani#)` | Starts the animation |
| `colorani_stop(ani#)` | Stops the animation and resets to start |
| `colorani_stopatcurrent(ani#)` | Stops at current color |
| `colorani_propertyname#(ani#, name$)` | Sets color property to animate |
| `colorani_propertyname$(ani#)` | Gets the property name |
| `colorani_startvalue#(ani#, color)` | Sets the starting color (as integer) |
| `colorani_startvalue(ani#)` | Gets the starting color |
| `colorani_stopvalue#(ani#, color)` | Sets the ending color (as integer) |
| `colorani_stopvalue(ani#)` | Gets the ending color |
| `colorani_duration#(ani#, seconds)` | Sets duration in seconds |
| `colorani_duration(ani#)` | Gets duration |
| `colorani_delay#(ani#, seconds)` | Sets delay before start |
| `colorani_delay(ani#)` | Gets delay |
| `colorani_animationtype#(ani#, type$)` | Sets easing type |
| `colorani_animationtype$(ani#)` | Gets animation type |
| `colorani_interpolation#(ani#, type$)` | Sets interpolation curve |
| `colorani_interpolation$(ani#)` | Gets interpolation type |
| `colorani_autoreverse#(ani#, flag)` | If 1, reverses after completing |
| `colorani_autoreverse(ani#)` | Gets autoreverse flag |
| `colorani_inverse#(ani#, flag)` | If 1, plays in reverse |
| `colorani_inverse(ani#)` | Gets inverse flag |
| `colorani_loop#(ani#, flag)` | If 1, loops indefinitely |
| `colorani_loop(ani#)` | Gets loop flag |
| `colorani_enabled#(ani#, flag)` | Enables/disables animation |
| `colorani_enabled(ani#)` | Gets enabled state |
| `colorani_startfromcurrent#(ani#, flag)` | If 1, starts from current color |
| `colorani_startfromcurrent(ani#)` | Gets startfromcurrent flag |
| `colorani_running(ani#)` | Returns 1 if animation is running |
| `colorani_normalizedtime(ani#)` | Returns progress 0.0-1.0 |
| `colorani_name$(ani#)` | Gets the animation name |
| `colorani_trigger#(ani#, expr$)` | Sets trigger expression |
| `colorani_trigger$(ani#)` | Gets trigger expression |
| `colorani_triggerinverse#(ani#, expr$)` | Sets inverse trigger |
| `colorani_triggerinverse$(ani#)` | Gets inverse trigger |
| `colorani_onfinish#(ani#, callback$)` | Sets finish callback function |
| `colorani_onfinish$(ani#)` | Gets finish callback name |
| `colorani_onprocess#(ani#, callback$)` | Sets per-frame callback |
| `colorani_onprocess$(ani#)` | Gets process callback name |
| `colorani_clearcallbacks#(ani#)` | Removes all callbacks |
| `colorani_error()` | Returns last error code |
| `colorani_errormsg$()` | Returns last error message |
| `colorani_strerror$(code)` | Converts error code to message |
| `colorani_clearerror()` | Clears the error state |

## Color Utility Functions

| Function | Description |
|----------|-------------|
| `colortoalphacolor(name$)` | Converts color name to integer (e.g., "Red" → 4294901760) |
| `alphacolortostring$(color)` | Converts color integer to hex string |
| `rgb(r, g, b)` | Creates opaque color from RGB values (0-255) |
| `rgba(r, g, b, a)` | Creates color with alpha from RGBA values (0-255) |

**Important:** These functions return **numeric** color values for use with `colorani_startvalue#` and `colorani_stopvalue#`. Shape fill functions like `rectangle_fill#` take **string** color names instead.

## Animatable Color Properties

| Property | Description |
|----------|-------------|
| `Fill.Color` | Shape fill color |
| `Stroke.Color` | Shape stroke/border color |
| `TextSettings.FontColor` | Text color |

## Supported Color Names

Black, White, Red, Green, Blue, Yellow, Cyan, Magenta, Gray, Grey, Silver, Navy, Maroon, Purple, Orange, Lime, Aqua, Teal, Olive, Fuchsia, Pink

Hex format: `"#RRGGBB"` or `"#AARRGGBB"`

## Error Codes

| Code | Meaning |
|------|---------|
| 0 | No error |
| 1 | Animation is nil |
| 2 | Invalid property |
| 3 | Invalid value |
| 4 | Animation is running |

## Example: Color Transition

```basic
' Rectangle that transitions from Blue to Red
let frm# = form#("Color Demo", 400, 300)
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 100, 200, 100)
rectangle_fill#(rect#, "Blue")

' Create color transition animation
let colorAni# = colorani#(rect#)
colorani_propertyname#(colorAni#, "Fill.Color")
colorani_startvalue#(colorAni#, colortoalphacolor("Blue"))
colorani_stopvalue#(colorAni#, colortoalphacolor("Red"))
colorani_duration#(colorAni#, 2.0)
colorani_autoreverse#(colorAni#, 1)
colorani_loop#(colorAni#, 1)
colorani_start(colorAni#)

form_show(frm#)
```

## Example: Rainbow Cycle

```basic
' Cycling through colors continuously
let frm# = form#("Rainbow Demo", 400, 300)
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 300, 200)
rectangle_fill#(rect#, "Red")

let colorAni# = colorani#(rect#)
colorani_propertyname#(colorAni#, "Fill.Color")
colorani_startvalue#(colorAni#, colortoalphacolor("Red"))
colorani_stopvalue#(colorAni#, colortoalphacolor("Blue"))
colorani_duration#(colorAni#, 3.0)
colorani_autoreverse#(colorAni#, 1)
colorani_loop#(colorAni#, 1)
colorani_start(colorAni#)

form_show(frm#)
```

## Example: Using RGB Function

```basic
' Custom colors using rgb() function
let frm# = form#("RGB Demo", 400, 300)
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 100, 200, 100)

' Define custom colors as numeric values
' Coral color (RGB: 255, 127, 80)
let coral = rgb(255, 127, 80)
' Teal color (RGB: 0, 128, 128)
let teal = rgb(0, 128, 128)

' Note: rectangle_fill# takes a string, so we set initial color with hex string
' The animation will handle the transition using numeric color values
rectangle_fill#(rect#, "#FF7F50")

let colorAni# = colorani#(rect#)
colorani_propertyname#(colorAni#, "Fill.Color")
colorani_startvalue#(colorAni#, coral)
colorani_stopvalue#(colorAni#, teal)
colorani_duration#(colorAni#, 2.0)
colorani_loop#(colorAni#, 1)
colorani_autoreverse#(colorAni#, 1)
colorani_start(colorAni#)

form_show(frm#)
```

## Example: Text Color Animation

```basic
' Animate label text color
let frm# = form#("Text Color Demo", 400, 200)
let lbl# = label#(frm#, "Hello World!")
label_move#(lbl#, 100, 80)
label_fontsize#(lbl#, 24)

let colorAni# = colorani#(lbl#)
colorani_propertyname#(colorAni#, "TextSettings.FontColor")
colorani_startvalue#(colorAni#, colortoalphacolor("Grey"))
colorani_stopvalue#(colorAni#, colortoalphacolor("Red"))
colorani_duration#(colorAni#, 1.5)
colorani_autoreverse#(colorAni#, 1)
colorani_loop#(colorAni#, 1)
colorani_start(colorAni#)

form_show(frm#)
```

## Example: Border Color Animation

```basic
' Animate the stroke/border color
let frm# = form#("Border Demo", 400, 300)
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 75, 200, 150)
rectangle_fill#(rect#, "White")
rectangle_stroke#(rect#, "Blue")
rectangle_strokethickness#(rect#, 4)

let colorAni# = colorani#(rect#)
colorani_propertyname#(colorAni#, "Stroke.Color")
colorani_startvalue#(colorAni#, colortoalphacolor("Blue"))
colorani_stopvalue#(colorAni#, colortoalphacolor("Orange"))
colorani_duration#(colorAni#, 1.0)
colorani_autoreverse#(colorAni#, 1)
colorani_loop#(colorAni#, 1)
colorani_start(colorAni#)

form_show(frm#)
```

## Notes

- Color utility functions (`rgb`, `rgba`, `colortoalphacolor`) return **numeric** values
- Shape properties like `rectangle_fill#` accept **string** color names or hex values
- Use `colortoalphacolor()` with named colors: "Red", "Blue", "#FF5500", etc.
- Use `rgb(r, g, b)` for custom colors with RGB components (0-255)
- Use `rgba(r, g, b, a)` for colors with transparency (alpha 0-255)
