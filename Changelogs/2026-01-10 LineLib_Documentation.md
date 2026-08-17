# LineLib - Line Visual Control Library

## Overview

LineLib enables the creation and management of line shapes with full support for stroke styling, positioning, and event callbacks.

**Version:** 1.0.0  
**Function Count:** 72 functions

### Key Difference from Other Shape Controls

Unlike other shape controls (Rectangle, Circle, Ellipse, Arc, Pie), lines are rendered using only Stroke properties.

## Quick Start

```basic
' Create a form
let frm# = form#("Line Demo", 800, 600)

' Create a diagonal line
let ln# = line#(frm#, 50, 50, 200, 100)
line_stroke#(ln#, "#3498db")
line_strokethickness#(ln#, 2)

' Create a horizontal line
let hln# = line#(frm#, 50, 200, 200, 1)
line_linetype#(hln#, 1)  ' 1 = Top (horizontal)
line_stroke#(hln#, "red")
line_strokethickness#(hln#, 3)

' Show the form
form_show(frm#)
```

## Line Type

The `LineType` property determines how the line is drawn within its bounding rectangle:

| Value | Name     | Description                                       |
|-------|----------|---------------------------------------------------|
| 0     | Diagonal | Line from top-left to bottom-right (default)      |
| 1     | Top      | Horizontal line at the top edge                   |
| 2     | Left     | Vertical line at the left edge                    |

### Usage Example

```basic
' Create lines with different types
let diagLine# = line#(frm#, 10, 10, 100, 100)
line_linetype#(diagLine#, 0)  ' Diagonal (default)

let horizLine# = line#(frm#, 10, 120, 100, 20)
line_linetype#(horizLine#, 1)  ' Horizontal

let vertLine# = line#(frm#, 120, 10, 20, 100)
line_linetype#(vertLine#, 2)  ' Vertical
```

## Stroke Styles

### Dash Styles

| Value | Name        | Description                    |
|-------|-------------|--------------------------------|
| 0     | Solid       | Continuous line (default)      |
| 1     | Dash        | Dashed line                    |
| 2     | Dot         | Dotted line                    |
| 3     | DashDot     | Alternating dash and dot       |
| 4     | DashDotDot  | Dash followed by two dots      |

### Cap Styles

| Value | Name  | Description                        |
|-------|-------|------------------------------------|
| 0     | Flat  | Square line endings (default)      |
| 1     | Round | Rounded line endings               |

### Join Styles

| Value | Name  | Description                        |
|-------|-------|------------------------------------|
| 0     | Miter | Sharp corners (default)            |
| 1     | Round | Rounded corners                    |
| 2     | Bevel | Beveled (cut) corners              |

## Color Format

Colors can be specified as:

- **Named colors**: `"red"`, `"blue"`, `"green"`, `"white"`, `"black"`, etc.
- **Hex RGB**: `"#RRGGBB"` (e.g., `"#FF5500"`)
- **Hex ARGB**: `"#AARRGGBB"` (e.g., `"#80FF5500"` for semi-transparent)

### Supported Named Colors

red, green, blue, white, black, yellow, orange, purple, cyan, magenta, gray/grey, silver, maroon, navy, olive, teal, lime, aqua, fuchsia, pink, brown, gold, coral, crimson, indigo, ivory, khaki, lavender, salmon, skyblue, tan, tomato, turquoise, violet, wheat, transparent

## Alignment Constants

| Value | Name         | Description                |
|-------|--------------|----------------------------|
| 0     | None         | No alignment (default)     |
| 1     | Top          | Align to top               |
| 2     | Left         | Align to left              |
| 3     | Right        | Align to right             |
| 4     | Bottom       | Align to bottom            |
| 9     | Client       | Fill parent area           |
| 11    | Center       | Center in parent           |

## Function Reference

### Error Handling

| Function | Signature | Description |
|----------|-----------|-------------|
| `line_error()` | `→ number` | Get last error code |
| `line_errormsg$()` | `→ string` | Get last error message |
| `line_strerror$(code)` | `number → string` | Convert error code to message |
| `line_clearerror()` | `→ number` | Clear error state |

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_INVALID_LINE | Invalid line pointer |
| 2 | ERR_INVALID_PARENT | Invalid parent control |
| 3 | ERR_INVALID_VALUE | Invalid parameter value |
| 4 | ERR_CREATE_FAILED | Line creation failed |
| 5 | ERR_INVALID_CALLBACK | Invalid callback function |
| 6 | ERR_INVALID_COLOR | Invalid color value |

### Creation and Destruction

| Function | Signature | Description |
|----------|-----------|-------------|
| `line#(parent#)` | `pointer → pointer` | Create line with parent |
| `line#(parent#, w, h)` | `pointer, num, num → pointer` | Create with size |
| `line#(parent#, x, y, w, h)` | `pointer, num, num, num, num → pointer` | Create with position and size |
| `line_free(ln#)` | `pointer → number` | Free line control |

### Line Type

| Function | Signature | Description |
|----------|-----------|-------------|
| `line_linetype(ln#)` | `pointer → number` | Get line type (0=Diagonal, 1=Top, 2=Left) |
| `line_linetype#(ln#, type)` | `pointer, number → pointer` | Set line type |

### Stroke Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `line_stroke$(ln#)` | `pointer → string` | Get stroke color |
| `line_stroke#(ln#, color$)` | `pointer, string → pointer` | Set stroke color |
| `line_strokenone#(ln#)` | `pointer → pointer` | Remove stroke |
| `line_strokethickness(ln#)` | `pointer → number` | Get stroke thickness |
| `line_strokethickness#(ln#, val)` | `pointer, number → pointer` | Set stroke thickness |
| `line_strokedash(ln#)` | `pointer → number` | Get dash style |
| `line_strokedash#(ln#, style)` | `pointer, number → pointer` | Set dash style |
| `line_strokecap(ln#)` | `pointer → number` | Get cap style |
| `line_strokecap#(ln#, style)` | `pointer, number → pointer` | Set cap style |
| `line_strokejoin(ln#)` | `pointer → number` | Get join style |
| `line_strokejoin#(ln#, style)` | `pointer, number → pointer` | Set join style |

### Position and Size

| Function | Signature | Description |
|----------|-----------|-------------|
| `line_x(ln#)` | `pointer → number` | Get X position |
| `line_x#(ln#, val)` | `pointer, number → pointer` | Set X position |
| `line_y(ln#)` | `pointer → number` | Get Y position |
| `line_y#(ln#, val)` | `pointer, number → pointer` | Set Y position |
| `line_width(ln#)` | `pointer → number` | Get width |
| `line_width#(ln#, val)` | `pointer, number → pointer` | Set width |
| `line_height(ln#)` | `pointer → number` | Get height |
| `line_height#(ln#, val)` | `pointer, number → pointer` | Set height |
| `line_bounds#(ln#, x, y, w, h)` | `pointer, num, num, num, num → pointer` | Set all bounds |
| `line_size#(ln#, w, h)` | `pointer, num, num → pointer` | Set size only |
| `line_move#(ln#, x, y)` | `pointer, num, num → pointer` | Set position only |

### Alignment

| Function | Signature | Description |
|----------|-----------|-------------|
| `line_align(ln#)` | `pointer → number` | Get alignment |
| `line_align#(ln#, align)` | `pointer, number → pointer` | Set alignment |

### Margins

| Function | Signature | Description |
|----------|-----------|-------------|
| `line_marginleft(ln#)` | `pointer → number` | Get left margin |
| `line_marginleft#(ln#, val)` | `pointer, number → pointer` | Set left margin |
| `line_margintop(ln#)` | `pointer → number` | Get top margin |
| `line_margintop#(ln#, val)` | `pointer, number → pointer` | Set top margin |
| `line_marginright(ln#)` | `pointer → number` | Get right margin |
| `line_marginright#(ln#, val)` | `pointer, number → pointer` | Set right margin |
| `line_marginbottom(ln#)` | `pointer → number` | Get bottom margin |
| `line_marginbottom#(ln#, val)` | `pointer, number → pointer` | Set bottom margin |
| `line_margins#(ln#, l, t, r, b)` | `pointer, num, num, num, num → pointer` | Set all margins |
| `line_margin#(ln#, val)` | `pointer, number → pointer` | Set uniform margin |

### Visibility and Behavior

| Function | Signature | Description |
|----------|-----------|-------------|
| `line_visible(ln#)` | `pointer → number` | Get visibility (0/1) |
| `line_visible#(ln#, val)` | `pointer, number → pointer` | Set visibility |
| `line_enabled(ln#)` | `pointer → number` | Get enabled state (0/1) |
| `line_enabled#(ln#, val)` | `pointer, number → pointer` | Set enabled state |
| `line_opacity(ln#)` | `pointer → number` | Get opacity (0.0-1.0) |
| `line_opacity#(ln#, val)` | `pointer, number → pointer` | Set opacity |
| `line_hittest(ln#)` | `pointer → number` | Get hit test enabled (0/1) |
| `line_hittest#(ln#, val)` | `pointer, number → pointer` | Set hit test enabled |

### Tag and Rotation

| Function | Signature | Description |
|----------|-----------|-------------|
| `line_tag(ln#)` | `pointer → number` | Get tag value |
| `line_tag#(ln#, val)` | `pointer, number → pointer` | Set tag value |
| `line_rotation(ln#)` | `pointer → number` | Get rotation angle |
| `line_rotation#(ln#, angle)` | `pointer, number → pointer` | Set rotation angle |

### Parent and Z-Order

| Function | Signature | Description |
|----------|-----------|-------------|
| `line_parent#(ln#)` | `pointer → pointer` | Get parent control |
| `line_parent#(ln#, parent#)` | `pointer, pointer → pointer` | Set parent control |
| `line_bringtofront#(ln#)` | `pointer → pointer` | Bring to front of Z-order |
| `line_sendtoback#(ln#)` | `pointer → pointer` | Send to back of Z-order |

### Invalidation

| Function | Signature | Description |
|----------|-----------|-------------|
| `line_invalidate#(ln#)` | `pointer → pointer` | Force repaint |

### Event Callbacks

| Function | Signature | Description |
|----------|-----------|-------------|
| `line_onclick#(ln#, func$)` | `pointer, string → pointer` | Set click handler |
| `line_onclick$(ln#)` | `pointer → string` | Get click handler name |
| `line_ondblclick#(ln#, func$)` | `pointer, string → pointer` | Set double-click handler |
| `line_ondblclick$(ln#)` | `pointer → string` | Get double-click handler name |
| `line_onmousedown#(ln#, func$)` | `pointer, string → pointer` | Set mouse down handler |
| `line_onmousedown$(ln#)` | `pointer → string` | Get mouse down handler name |
| `line_onmouseup#(ln#, func$)` | `pointer, string → pointer` | Set mouse up handler |
| `line_onmouseup$(ln#)` | `pointer → string` | Get mouse up handler name |
| `line_onmousemove#(ln#, func$)` | `pointer, string → pointer` | Set mouse move handler |
| `line_onmousemove$(ln#)` | `pointer → string` | Get mouse move handler name |
| `line_onmouseenter#(ln#, func$)` | `pointer, string → pointer` | Set mouse enter handler |
| `line_onmouseenter$(ln#)` | `pointer → string` | Get mouse enter handler name |
| `line_onmouseleave#(ln#, func$)` | `pointer, string → pointer` | Set mouse leave handler |
| `line_onmouseleave$(ln#)` | `pointer → string` | Get mouse leave handler name |
| `line_onmousewheel#(ln#, func$)` | `pointer, string → pointer` | Set mouse wheel handler |
| `line_onmousewheel$(ln#)` | `pointer → string` | Get mouse wheel handler name |
| `line_onresize#(ln#, func$)` | `pointer, string → pointer` | Set resize handler |
| `line_onresize$(ln#)` | `pointer → string` | Get resize handler name |
| `line_clearcallbacks#(ln#)` | `pointer → pointer` | Clear all event callbacks |

## Event Callback Signatures

### OnClick / OnDblClick / OnMouseEnter / OnMouseLeave / OnResize

```basic
function MyHandler(sender#)
  ' sender# is the line that triggered the event
  println "Event triggered!"
endfunction
```

### OnMouseDown / OnMouseUp

```basic
function MyMouseHandler(sender#, button, x, y, shift$)
  ' button: 0=Left, 1=Right, 2=Middle
  ' x, y: Mouse coordinates
  ' shift$: "Shift,Ctrl,Alt,Left,Right,Middle,Double" (comma-separated)
  println "Mouse at: " + stri$(x) + ", " + stri$(y)
endfunction
```

### OnMouseMove

```basic
function MyMoveHandler(sender#, x, y, shift$)
  ' x, y: Mouse coordinates
  ' shift$: Modifier keys string
  println "Moving at: " + stri$(x) + ", " + stri$(y)
endfunction
```

### OnMouseWheel

```basic
function MyWheelHandler(sender#, delta, shift$)
  ' delta: Wheel movement (positive=up, negative=down)
  ' shift$: Modifier keys string
  if delta > 0 then
    println "Wheel up"
  else
    println "Wheel down"
  endif
endfunction
```

## Complete Example

```basic
' ============================================================================
' LineLib Demo - Drawing with Lines
' ============================================================================

let frm# = form#("Line Drawing Demo", 800, 600)

' Draw a simple house shape with lines

' Roof - diagonal lines forming a triangle
let roof1# = line#(frm#, 200, 150, 200, 100)
line_stroke#(roof1#, "#8B4513")  ' Brown
line_strokethickness#(roof1#, 4)

let roof2# = line#(frm#, 400, 250, 200, 100)
line_stroke#(roof2#, "#8B4513")
line_strokethickness#(roof2#, 4)
line_rotation#(roof2#, 180)

' Walls - horizontal and vertical lines
let leftWall# = line#(frm#, 200, 250, 5, 150)
line_stroke#(leftWall#, "#A0522D")
line_strokethickness#(leftWall#, 4)
line_linetype#(leftWall#, 2)  ' Left (vertical)

let rightWall# = line#(frm#, 400, 250, 5, 150)
line_stroke#(rightWall#, "#A0522D")
line_strokethickness#(rightWall#, 4)
line_linetype#(rightWall#, 2)

let bottomWall# = line#(frm#, 200, 395, 205, 5)
line_stroke#(bottomWall#, "#A0522D")
line_strokethickness#(bottomWall#, 4)
line_linetype#(bottomWall#, 1)  ' Top (horizontal)

' Door frame
let doorLeft# = line#(frm#, 280, 300, 3, 95)
line_stroke#(doorLeft#, "#654321")
line_strokethickness#(doorLeft#, 3)
line_linetype#(doorLeft#, 2)

let doorRight# = line#(frm#, 320, 300, 3, 95)
line_stroke#(doorRight#, "#654321")
line_strokethickness#(doorRight#, 3)
line_linetype#(doorRight#, 2)

let doorTop# = line#(frm#, 280, 300, 43, 3)
line_stroke#(doorTop#, "#654321")
line_strokethickness#(doorTop#, 3)
line_linetype#(doorTop#, 1)

' Ground line
let ground# = line#(frm#, 100, 400, 400, 3)
line_stroke#(ground#, "#228B22")  ' Forest green
line_strokethickness#(ground#, 5)
line_linetype#(ground#, 1)

' Sun rays (dashed lines)
let i = 0
for i = 0 to 7
  let ray# = line#(frm#, 600, 100, 80, 2)
  line_stroke#(ray#, "#FFD700")  ' Gold
  line_strokethickness#(ray#, 2)
  line_strokedash#(ray#, 1)  ' Dashed
  line_linetype#(ray#, 1)
  line_rotation#(ray#, i * 45)
next i

' Interactive line with events
let interactiveLine# = line#(frm#, 500, 350, 150, 80)
line_stroke#(interactiveLine#, "#e74c3c")
line_strokethickness#(interactiveLine#, 6)
line_onclick#(interactiveLine#, "OnLineClick")
line_onmouseenter#(interactiveLine#, "OnLineEnter")
line_onmouseleave#(interactiveLine#, "OnLineLeave")

' Info label
let infoLbl# = label#(frm#, "Click the red diagonal line!", 480, 450)

form_show(frm#)

' Event handlers
function OnLineClick(sender#)
  println "Line clicked!"
  ' Toggle thickness
  let thick = line_strokethickness(sender#)
  if thick > 6 then
    line_strokethickness#(sender#, 4)
  else
    line_strokethickness#(sender#, 10)
  endif
endfunction

function OnLineEnter(sender#)
  line_stroke#(sender#, "#f39c12")
endfunction

function OnLineLeave(sender#)
  line_stroke#(sender#, "#e74c3c")
endfunction
```

## Platform Support

LineLib supports all platforms through FireMonkey:

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## See Also

- **CircleLib** - Circle/ellipse shapes
- **RectangleLib** - Rectangle shapes with corner rounding
- **EllipseLib** - Ellipse shapes
- **ArcLib** - Arc (partial ellipse) shapes
- **PieLib** - Pie (wedge) shapes
- **RoundRectLib** - Rounded rectangle shapes

---

*Copyright © 2024-2025 Plan9Basic Project*
