# PathAnimationLib - Path Animation Library

## Overview

PathAnimationLib provides path-based animation functionality for Plan9Basic, allowing controls to move smoothly along complex curves and trajectories defined by SVG-like path data. This enables creating sophisticated motion effects like objects following curved paths, orbiting, figure-8 patterns, and more.

## Features

- SVG-like path data syntax for defining trajectories
- Smooth animation along lines, curves, and arcs
- Optional rotation to follow path tangent
- Multiple interpolation types for timing control
- Loop and auto-reverse capabilities
- Event callbacks for animation completion and progress
- Cross-platform support (Windows, macOS, Linux, Android, iOS)

## Path Data Syntax

The path is defined using SVG-like commands:

| Command | Syntax | Description |
|---------|--------|-------------|
| M | `M x,y` | MoveTo - Set starting point |
| L | `L x,y` | LineTo - Draw line to point |
| H | `H x` | HLineTo - Horizontal line to x |
| V | `V y` | VLineTo - Vertical line to y |
| C | `C x1,y1 x2,y2 x,y` | CurveTo - Cubic Bézier curve |
| S | `S x2,y2 x,y` | SmoothCurveTo - Smooth cubic Bézier |
| Q | `Q x1,y1 x,y` | QuadCurveTo - Quadratic Bézier curve |
| T | `T x,y` | SmoothQuadTo - Smooth quadratic Bézier |
| A | `A rx,ry rot large sweep x,y` | Arc |
| Z | `Z` | ClosePath - Close current subpath |

### Path Examples

```
' Square path
"M 0,0 L 200,0 L 200,200 L 0,200 Z"

' Figure-8 curve
"M 100,0 Q 200,100 100,200 Q 0,100 100,0"

' S-curve
"M 0,100 C 50,0 150,200 200,100"

' Elliptical orbit
"M 200,100 C 200,155 155,200 100,200 C 45,200 0,155 0,100 C 0,45 45,0 100,0 C 155,0 200,45 200,100"
```

## Animation Types

| Type | Description |
|------|-------------|
| `"In"` | Acceleration at start |
| `"Out"` | Deceleration at end |
| `"InOut"` | Acceleration then deceleration |

## Interpolation Types

| Type | Description |
|------|-------------|
| `"Linear"` | Constant speed |
| `"Quadratic"` | Smooth acceleration |
| `"Cubic"` | More pronounced acceleration |
| `"Quartic"` | Even more pronounced |
| `"Quintic"` | Maximum smoothness |
| `"Sinusoidal"` | Sine wave timing |
| `"Exponential"` | Exponential curve |
| `"Circular"` | Circular timing |
| `"Elastic"` | Elastic bounce effect |
| `"Back"` | Overshoot effect |
| `"Bounce"` | Bouncing effect |

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `pathani_error@` | Get last error code |
| `pathani_errormsg$@` | Get last error message |
| `pathani_strerror$@n` | Get error description for code |
| `pathani_clearerror@` | Clear error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `pathani#@#` | Create path animation on control |
| `pathani#@#$` | Create named path animation |
| `pathani_free@#` | Destroy animation |

### Animation Control

| Function | Description |
|----------|-------------|
| `pathani_start@#` | Start the animation |
| `pathani_stop@#` | Stop and reset animation |
| `pathani_stopatcurrent@#` | Stop at current position |

### Path Property

| Function | Description |
|----------|-------------|
| `pathani_path#@#$` | Set path data string |
| `pathani_path$@#` | Get path data string |
| `pathani_clearpath#@#` | Clear path data |

### Rotation

| Function | Description |
|----------|-------------|
| `pathani_rotate#@#n` | Set rotate mode (0=off, 1=on) |
| `pathani_rotate@#` | Get rotate mode |

When rotate is enabled, the control rotates to follow the path tangent direction.

### Duration and Delay

| Function | Description |
|----------|-------------|
| `pathani_duration#@#n` | Set duration in seconds |
| `pathani_duration@#` | Get duration |
| `pathani_delay#@#n` | Set delay before start |
| `pathani_delay@#` | Get delay |

### Animation Behavior

| Function | Description |
|----------|-------------|
| `pathani_animationtype#@#$` | Set animation type |
| `pathani_animationtype$@#` | Get animation type |
| `pathani_interpolation#@#$` | Set interpolation type |
| `pathani_interpolation$@#` | Get interpolation type |
| `pathani_loop#@#n` | Set loop mode (0=off, 1=on) |
| `pathani_loop@#` | Get loop mode |
| `pathani_autoreverse#@#n` | Set auto-reverse (0=off, 1=on) |
| `pathani_autoreverse@#` | Get auto-reverse |
| `pathani_inverse#@#n` | Set inverse mode |
| `pathani_inverse@#` | Get inverse mode |
| `pathani_enabled#@#n` | Set enabled state |
| `pathani_enabled@#` | Get enabled state |

### State Queries

| Function | Description |
|----------|-------------|
| `pathani_running@#` | Check if animation is running |
| `pathani_normalizedtime@#` | Get progress (0.0 to 1.0) |
| `pathani_name$@#` | Get animation name |

### Triggers

| Function | Description |
|----------|-------------|
| `pathani_trigger#@#$` | Set trigger string |
| `pathani_trigger$@#` | Get trigger string |
| `pathani_triggerinverse#@#$` | Set inverse trigger |
| `pathani_triggerinverse$@#` | Get inverse trigger |

### Event Callbacks

| Function | Description |
|----------|-------------|
| `pathani_onfinish#@#$` | Set OnFinish callback |
| `pathani_onfinish$@#` | Get OnFinish callback name |
| `pathani_onprocess#@#$` | Set OnProcess callback |
| `pathani_onprocess$@#` | Get OnProcess callback name |
| `pathani_clearcallbacks#@#` | Clear all callbacks |

**Callback Signatures:**
```basic
function OnFinish(sender#) local ...
function OnProcess(sender#) local ...
```

## Usage Examples

### Basic Path Animation

```basic
' Create a circle that moves along a curved path
let frm# = form#("Path Animation", 400, 400)

let ball# = circle#(frm#)
circle_bounds#(ball#, 0, 0, 30, 30)
circle_fill#(ball#, "Red")

let ani# = pathani#(ball#)
pathani_path#(ani#, "M 50,200 C 100,50 300,50 350,200")
pathani_duration#(ani#, 2.0)
pathani_start(ani#)

form_show(frm#)
```

### Looping Orbit

```basic
' Orbiting animation
let ani# = pathani#(planet#)
pathani_path#(ani#, "M 200,50 C 350,50 350,250 200,250 C 50,250 50,50 200,50")
pathani_duration#(ani#, 4.0)
pathani_loop#(ani#, 1)
pathani_start(ani#)
```

### Following with Rotation

```basic
' Arrow that points in direction of movement
let ani# = pathani#(arrow#)
pathani_path#(ani#, "M 0,150 Q 150,0 300,150 Q 150,300 0,150")
pathani_rotate#(ani#, 1)  ' Enable rotation
pathani_duration#(ani#, 3.0)
pathani_loop#(ani#, 1)
pathani_start(ani#)
```

### With Callbacks

```basic
let loopCount = 0

function OnAnimFinished(sender#) local msg$
  loopCount = loopCount + 1
  msg$ = "Animation completed " + str$(loopCount) + " times"
  label_text#(statusLbl#, msg$)
endfunction

' Setup
pathani_onfinish#(ani#, "OnAnimFinished")
pathani_loop#(ani#, 1)
pathani_start(ani#)
```

## Error Codes

| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Animation is nil |
| 2 | Invalid property or object |
| 3 | Invalid value |
| 4 | Cannot modify while running |

## Tips and Best Practices

1. **Path Coordinates**: Path coordinates are relative to the parent container. Design paths considering the control's parent size.

2. **Performance**: Complex paths with many curves may impact performance. Use simpler paths when possible.

3. **Rotate Mode**: Enable rotate for directional objects like arrows, vehicles, or characters that should face their movement direction.

4. **Combining Animations**: Path animations can be combined with other animations (color, opacity) for rich effects.

5. **Testing Paths**: Use online SVG path editors to design and test paths before using in Plan9Basic.

## See Also

- FloatAnimationLib - Animate numeric properties
- ColorAnimationLib - Animate colors
- RectAnimationLib - Animate bounds/size
- BitmapListAnimationLib - Sprite sheet animations
