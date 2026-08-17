# RectAnimationLib - Rectangle/Bounds Animation Library

## Overview

RectAnimationLib provides bounds-based animation functionality for Plan9Basic, allowing smooth simultaneous animation of position (X, Y) and size (Width, Height) of controls. This enables effects like windows opening/closing, controls expanding/collapsing, and smooth resize transitions.

**Version 2.0** - This library uses a composite animation approach with 4 internal float animations for reliable cross-platform operation.

## Features

- Animate X, Y, Width, Height simultaneously
- Smooth transitions between any two rectangles
- Multiple interpolation types for timing control
- Loop and auto-reverse capabilities
- Event callbacks for animation completion and progress
- Cross-platform support (Windows, macOS, Linux, Android, iOS)

## How It Works

RectAnimationLib v2 internally manages **four synchronized TFloatAnimation** objects:
- One for `Position.X`
- One for `Position.Y`
- One for `Width`
- One for `Height`

All four animations run together with the same duration, interpolation, and timing settings, creating smooth coordinated movement and resizing.

> **Note:** Unlike other animation libraries, RectAnimationLib does **NOT** use a `propertyname` function. It automatically animates position and size together.

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
| `rectani_error@` | Get last error code |
| `rectani_errormsg$@` | Get last error message |
| `rectani_strerror$@n` | Get error description for code |
| `rectani_clearerror@` | Clear error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `rectani#@#` | Create rect animation on control |
| `rectani#@#$` | Create named rect animation |
| `rectani_free@#` | Destroy animation |

### Animation Control

| Function | Description |
|----------|-------------|
| `rectani_start@#` | Start the animation |
| `rectani_stop@#` | Stop and reset animation |
| `rectani_stopatcurrent@#` | Stop at current position |

### Start Bounds

| Function | Description |
|----------|-------------|
| `rectani_startbounds#@#nnnn` | Set start rectangle (x, y, width, height) |
| `rectani_startx@#` | Get start X |
| `rectani_starty@#` | Get start Y |
| `rectani_startwidth@#` | Get start width |
| `rectani_startheight@#` | Get start height |

### Stop Bounds

| Function | Description |
|----------|-------------|
| `rectani_stopbounds#@#nnnn` | Set stop rectangle (x, y, width, height) |
| `rectani_stopx@#` | Get stop X |
| `rectani_stopy@#` | Get stop Y |
| `rectani_stopwidth@#` | Get stop width |
| `rectani_stopheight@#` | Get stop height |

### Duration and Delay

| Function | Description |
|----------|-------------|
| `rectani_duration#@#n` | Set duration in seconds |
| `rectani_duration@#` | Get duration |
| `rectani_delay#@#n` | Set delay before start |
| `rectani_delay@#` | Get delay |

### Animation Behavior

| Function | Description |
|----------|-------------|
| `rectani_animationtype#@#$` | Set animation type |
| `rectani_animationtype$@#` | Get animation type |
| `rectani_interpolation#@#$` | Set interpolation type |
| `rectani_interpolation$@#` | Get interpolation type |
| `rectani_loop#@#n` | Set loop mode (0=off, 1=on) |
| `rectani_loop@#` | Get loop mode |
| `rectani_autoreverse#@#n` | Set auto-reverse (0=off, 1=on) |
| `rectani_autoreverse@#` | Get auto-reverse |
| `rectani_inverse#@#n` | Set inverse mode |
| `rectani_inverse@#` | Get inverse mode |
| `rectani_enabled#@#n` | Set enabled state |
| `rectani_enabled@#` | Get enabled state |

### State Queries

| Function | Description |
|----------|-------------|
| `rectani_running@#` | Check if animation is running |
| `rectani_normalizedtime@#` | Get progress (0.0 to 1.0) |
| `rectani_name$@#` | Get animation name |

### Event Callbacks

| Function | Description |
|----------|-------------|
| `rectani_onfinish#@#$` | Set OnFinish callback |
| `rectani_onfinish$@#` | Get OnFinish callback name |
| `rectani_onprocess#@#$` | Set OnProcess callback |
| `rectani_onprocess$@#` | Get OnProcess callback name |
| `rectani_clearcallbacks#@#` | Clear all callbacks |

**Callback Signatures:**
```basic
function OnFinish(sender#) local ...
function OnProcess(sender#) local ...
```

## Usage Examples

### Basic Move and Resize

```basic
let frm# = form#("Rect Animation", 500, 400)

let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 100, 100)
rectangle_fill#(rect#, "Blue")

' Create animation - NO propertyname needed!
let ani# = rectani#(rect#)
rectani_startbounds#(ani#, 50, 50, 100, 100)
rectani_stopbounds#(ani#, 150, 100, 200, 200)
rectani_duration#(ani#, 2.0)
rectani_start(ani#)

form_show(frm#)
```

### Expand/Collapse Effect

```basic
' Panel that expands and collapses
let collapsed = 1

function TogglePanel(sender#)
  if collapsed = 1 then
    ' Expand
    rectani_startbounds#(ani#, 10, 10, 200, 40)
    rectani_stopbounds#(ani#, 10, 10, 200, 300)
    collapsed = 0
  else
    ' Collapse
    rectani_startbounds#(ani#, 10, 10, 200, 300)
    rectani_stopbounds#(ani#, 10, 10, 200, 40)
    collapsed = 1
  endif
  rectani_start(ani#)
endfunction
```

### Looping Size Pulse

```basic
' Pulsing button effect
let ani# = rectani#(button#)
rectani_startbounds#(ani#, 100, 100, 80, 30)
rectani_stopbounds#(ani#, 95, 95, 90, 40)
rectani_duration#(ani#, 0.5)
rectani_loop#(ani#, 1)
rectani_autoreverse#(ani#, 1)
rectani_interpolation#(ani#, "Sinusoidal")
rectani_start(ani#)
```

### Window Open Effect

```basic
' Simulate window opening from center point
let ani# = rectani#(panel#)
rectani_startbounds#(ani#, 200, 150, 0, 0)      ' Start as point
rectani_stopbounds#(ani#, 100, 50, 200, 200)   ' End as window
rectani_duration#(ani#, 0.3)
rectani_interpolation#(ani#, "Back")
rectani_animationtype#(ani#, "Out")
rectani_start(ani#)
```

### Window Close Effect

```basic
' Close animation (reverse of open)
rectani_startbounds#(ani#, 100, 50, 200, 200)   ' Current size
rectani_stopbounds#(ani#, 200, 150, 0, 0)       ' Shrink to point
rectani_duration#(ani#, 0.3)
rectani_interpolation#(ani#, "Back")
rectani_animationtype#(ani#, "In")
rectani_onfinish#(ani#, "OnWindowClosed")
rectani_start(ani#)

function OnWindowClosed(sender#)
  panel_visible#(panel#, 0)  ' Hide when done
endfunction
```

### With Callbacks

```basic
function OnExpandComplete(sender#)
  label_text#(statusLbl#, "Expansion complete!")
  button_enabled#(expandBtn#, 1)
endfunction

' Setup
rectani_onfinish#(ani#, "OnExpandComplete")
button_enabled#(expandBtn#, 0)
rectani_start(ani#)
```

## Common Patterns

### Move Only (Keep Size)
```basic
rectani_startbounds#(ani#, 50, 50, 100, 100)
rectani_stopbounds#(ani#, 200, 150, 100, 100)  ' Same size, different position
```

### Resize Only (Keep Position)
```basic
rectani_startbounds#(ani#, 50, 50, 100, 100)
rectani_stopbounds#(ani#, 50, 50, 200, 200)  ' Same position, different size
```

### Center-Anchored Resize
```basic
' To resize while keeping center, calculate offsets
let cx = 150  ' center X
let cy = 150  ' center Y
let size1 = 50
let size2 = 100
rectani_startbounds#(ani#, cx-size1/2, cy-size1/2, size1, size1)
rectani_stopbounds#(ani#, cx-size2/2, cy-size2/2, size2, size2)
```

## Error Codes

| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Animation is nil |
| 2 | Invalid property or object |
| 3 | Invalid value |
| 4 | Cannot modify while running |

## Migration from v1

If you have code using the old RectAnimationLib v1, remove any `rectani_propertyname#` calls:

**Old code (v1):**
```basic
let ani# = rectani#(rect#)
rectani_propertyname#(ani#, "Bounds")  ' REMOVE THIS LINE
rectani_startbounds#(ani#, ...)
```

**New code (v2):**
```basic
let ani# = rectani#(rect#)
' No propertyname needed!
rectani_startbounds#(ani#, ...)
```

## Tips and Best Practices

1. **No PropertyName**: RectAnimationLib v2 does not have or need a `propertyname` function. It automatically animates position and size together.

2. **Coordinate System**: Bounds coordinates are relative to the parent container.

3. **Performance**: For simple movements where you don't need to resize, consider using separate X/Y float animations instead.

4. **Elastic/Bounce Effects**: These can cause temporary overshooting - ensure your layout accommodates this.

5. **Combining with Other Animations**: Rect animations work well combined with opacity animations for appear/disappear effects.

## See Also

- FloatAnimationLib - Animate single numeric properties
- ColorAnimationLib - Animate colors
- PathAnimationLib - Animate along paths
- BitmapListAnimationLib - Sprite sheet animations
