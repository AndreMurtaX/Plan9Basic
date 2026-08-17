# PathLib - Path Visual Control Library

## Overview

PathLib enables the creation and management of arbitrary vector path shapes with full support for SVG-like path syntax, programmatic path construction, curves, transformations, fill and stroke styling, and event callbacks.

**Version:** 1.0.0  
**Function Count:** 105 functions

### What is a Path?

A Path is the most versatile shape control in Plan9Basic. Unlike fixed shapes (Circle, Rectangle, etc.), a Path can represent **any shape** defined through:

- **SVG-like path strings** - Compact notation for complex shapes
- **Programmatic construction** - Build shapes step-by-step with MoveTo, LineTo, CurveTo, etc.
- **Helper functions** - Add predefined shapes like rectangles, ellipses, and arcs

Paths are ideal for:
- Custom game sprites and shapes
- Complex UI elements
- Icons and symbols
- Animated graphics
- Data visualizations

## Quick Start

### Using SVG Path String

```basic
let frm# = form#("Path Demo", 800, 600)

' Create a triangle using SVG path syntax
let triangle# = path#(frm#, 50, 50, 100, 100)
path_data#(triangle#, "M 50,10 L 90,90 L 10,90 Z")
path_fill#(triangle#, "#3498db")
path_stroke#(triangle#, "#2980b9")
path_strokethickness#(triangle#, 2)

form_show(frm#)
```

### Using Programmatic Construction

```basic
let frm# = form#("Path Demo", 800, 600)

' Create a triangle programmatically
let triangle# = path#(frm#, 50, 50, 100, 100)
path_moveto#(triangle#, 50, 10)
path_lineto#(triangle#, 90, 90)
path_lineto#(triangle#, 10, 90)
path_closepath#(triangle#)
path_fill#(triangle#, "#e74c3c")

form_show(frm#)
```

## Path Data String Syntax

The path data string uses SVG-like commands. Each command is a letter followed by coordinates.

### Commands Reference

| Command | Name | Parameters | Description |
|---------|------|------------|-------------|
| `M` | MoveTo | x,y | Move pen to point (start new subpath) |
| `L` | LineTo | x,y | Draw line to point |
| `H` | HLineTo | x | Draw horizontal line to x |
| `V` | VLineTo | y | Draw vertical line to y |
| `C` | CurveTo | x1,y1 x2,y2 x,y | Cubic Bézier curve |
| `S` | SmoothCurveTo | x2,y2 x,y | Smooth cubic Bézier (continues previous curve) |
| `Q` | QuadCurveTo | x1,y1 x,y | Quadratic Bézier curve |
| `T` | SmoothQuadTo | x,y | Smooth quadratic Bézier |
| `A` | Arc | rx,ry rot large sweep x,y | Elliptical arc |
| `Z` | ClosePath | (none) | Close path back to start |

### Examples

```basic
' Square
path_data#(p#, "M 10,10 L 90,10 L 90,90 L 10,90 Z")

' Triangle
path_data#(p#, "M 50,10 L 90,90 L 10,90 Z")

' Heart shape
path_data#(p#, "M 50,30 C 20,0 0,30 50,80 C 100,30 80,0 50,30 Z")

' Star (5-pointed)
path_data#(p#, "M 50,5 L 61,40 L 98,40 L 68,62 L 79,97 L 50,75 L 21,97 L 32,62 L 2,40 L 39,40 Z")
```

## Curve Types

PathLib supports all major curve types for smooth, professional graphics.

### Cubic Bézier Curve (CurveTo)

A cubic Bézier curve uses two control points for maximum flexibility.

```basic
' Programmatic
path_moveto#(p#, 10, 50)
path_curveto#(p#, 30, 10, 70, 90, 90, 50)
' Parameters: cp1x, cp1y, cp2x, cp2y, endX, endY

' SVG string
path_data#(p#, "M 10,50 C 30,10 70,90 90,50")
```

### Smooth Cubic Bézier (SmoothCurveTo)

Continues a previous curve smoothly by mirroring the last control point.

```basic
path_moveto#(p#, 10, 50)
path_curveto#(p#, 20, 10, 40, 10, 50, 50)
path_smoothcurveto#(p#, 80, 90, 90, 50)
' Parameters: cp2x, cp2y, endX, endY
```

### Quadratic Bézier Curve (QuadCurveTo)

A simpler curve with one control point.

```basic
path_moveto#(p#, 10, 90)
path_quadcurveto#(p#, 50, 10, 90, 90)
' Parameters: cpX, cpY, endX, endY

' SVG string
path_data#(p#, "M 10,90 Q 50,10 90,90")
```

## WrapMode

The `WrapMode` property controls how the path scales within its bounds.

| Value | Name | Description |
|-------|------|-------------|
| 0 | Original | Path drawn at original size, positioned at top-left |
| 1 | Fit | Scale to fit while maintaining aspect ratio |
| 2 | Stretch | Stretch to fill entire bounds (default) |
| 3 | Tile | Repeat path to fill area |

```basic
' Set wrapmode to Fit (maintains aspect ratio)
path_wrapmode#(p#, 1)
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
| `path_error()` | `→ number` | Get last error code |
| `path_errormsg$()` | `→ string` | Get last error message |
| `path_strerror$(code)` | `number → string` | Convert error code to message |
| `path_clearerror()` | `→ number` | Clear error state |

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_INVALID_PATH | Invalid path pointer |
| 2 | ERR_INVALID_PARENT | Invalid parent control |
| 3 | ERR_INVALID_VALUE | Invalid parameter value |
| 4 | ERR_CREATE_FAILED | Path creation failed |
| 5 | ERR_INVALID_CALLBACK | Invalid callback function |
| 6 | ERR_INVALID_COLOR | Invalid color value |
| 7 | ERR_INVALID_DATA | Invalid path data string |

### Creation and Destruction

| Function | Signature | Description |
|----------|-----------|-------------|
| `path#(parent#)` | `pointer → pointer` | Create path with parent |
| `path#(parent#, w, h)` | `pointer, num, num → pointer` | Create with size |
| `path#(parent#, x, y, w, h)` | `pointer, num, num, num, num → pointer` | Create with position and size |
| `path_free(p#)` | `pointer → number` | Free path control |

### Path Data (String-Based)

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_data$(p#)` | `pointer → string` | Get SVG path string |
| `path_data#(p#, data$)` | `pointer, string → pointer` | Set from SVG path string |

### Path Data (Programmatic Construction)

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_moveto#(p#, x, y)` | `pointer, num, num → pointer` | Move pen to point |
| `path_lineto#(p#, x, y)` | `pointer, num, num → pointer` | Draw line to point |
| `path_hlineto#(p#, x)` | `pointer, num → pointer` | Horizontal line to x |
| `path_vlineto#(p#, y)` | `pointer, num → pointer` | Vertical line to y |
| `path_curveto#(p#, cp1x, cp1y, cp2x, cp2y, x, y)` | `pointer, num×6 → pointer` | Cubic Bézier curve |
| `path_smoothcurveto#(p#, cp2x, cp2y, x, y)` | `pointer, num×4 → pointer` | Smooth cubic Bézier |
| `path_quadcurveto#(p#, cpx, cpy, x, y)` | `pointer, num×4 → pointer` | Quadratic Bézier curve |
| `path_closepath#(p#)` | `pointer → pointer` | Close current subpath |
| `path_clear#(p#)` | `pointer → pointer` | Clear all path data |

### Helper Shape Functions

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_addrectangle#(p#, x, y, w, h, xr, yr)` | `pointer, num×6 → pointer` | Add rounded rectangle |
| `path_addellipse#(p#, x, y, w, h)` | `pointer, num×4 → pointer` | Add ellipse |
| `path_addarc#(p#, cx, cy, rx, ry, start, sweep)` | `pointer, num×6 → pointer` | Add arc |

### Path Transformation

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_scale#(p#, sx, sy)` | `pointer, num, num → pointer` | Scale path data |
| `path_translate#(p#, dx, dy)` | `pointer, num, num → pointer` | Translate path data |
| `path_rotate#(p#, angle)` | `pointer, num → pointer` | Rotate path data (degrees) |

### Path Query

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_pointcount(p#)` | `pointer → number` | Number of points in path |
| `path_lastx(p#)` | `pointer → number` | Last point X coordinate |
| `path_lasty(p#)` | `pointer → number` | Last point Y coordinate |
| `path_boundsx(p#)` | `pointer → number` | Path bounds left |
| `path_boundsy(p#)` | `pointer → number` | Path bounds top |
| `path_boundswidth(p#)` | `pointer → number` | Path bounds width |
| `path_boundsheight(p#)` | `pointer → number` | Path bounds height |

### WrapMode

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_wrapmode(p#)` | `pointer → number` | Get wrap mode (0-3) |
| `path_wrapmode#(p#, mode)` | `pointer, number → pointer` | Set wrap mode |

### Fill Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_fill$(p#)` | `pointer → string` | Get fill color |
| `path_fill#(p#, color$)` | `pointer, string → pointer` | Set fill color |
| `path_fillnone#(p#)` | `pointer → pointer` | Remove fill (transparent) |

### Stroke Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_stroke$(p#)` | `pointer → string` | Get stroke color |
| `path_stroke#(p#, color$)` | `pointer, string → pointer` | Set stroke color |
| `path_strokenone#(p#)` | `pointer → pointer` | Remove stroke |
| `path_strokethickness(p#)` | `pointer → number` | Get stroke thickness |
| `path_strokethickness#(p#, val)` | `pointer, number → pointer` | Set stroke thickness |
| `path_strokedash(p#)` | `pointer → number` | Get dash style |
| `path_strokedash#(p#, style)` | `pointer, number → pointer` | Set dash style |
| `path_strokecap(p#)` | `pointer → number` | Get cap style |
| `path_strokecap#(p#, style)` | `pointer, number → pointer` | Set cap style |
| `path_strokejoin(p#)` | `pointer → number` | Get join style |
| `path_strokejoin#(p#, style)` | `pointer, number → pointer` | Set join style |

### Position and Size

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_x(p#)` | `pointer → number` | Get X position |
| `path_x#(p#, val)` | `pointer, number → pointer` | Set X position |
| `path_y(p#)` | `pointer → number` | Get Y position |
| `path_y#(p#, val)` | `pointer, number → pointer` | Set Y position |
| `path_width(p#)` | `pointer → number` | Get width |
| `path_width#(p#, val)` | `pointer, number → pointer` | Set width |
| `path_height(p#)` | `pointer → number` | Get height |
| `path_height#(p#, val)` | `pointer, number → pointer` | Set height |
| `path_bounds#(p#, x, y, w, h)` | `pointer, num×4 → pointer` | Set all bounds |
| `path_size#(p#, w, h)` | `pointer, num, num → pointer` | Set size only |
| `path_move#(p#, x, y)` | `pointer, num, num → pointer` | Set position only |

### Alignment

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_align(p#)` | `pointer → number` | Get alignment |
| `path_align#(p#, align)` | `pointer, number → pointer` | Set alignment |

### Margins

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_marginleft(p#)` | `pointer → number` | Get left margin |
| `path_marginleft#(p#, val)` | `pointer, number → pointer` | Set left margin |
| `path_margintop(p#)` | `pointer → number` | Get top margin |
| `path_margintop#(p#, val)` | `pointer, number → pointer` | Set top margin |
| `path_marginright(p#)` | `pointer → number` | Get right margin |
| `path_marginright#(p#, val)` | `pointer, number → pointer` | Set right margin |
| `path_marginbottom(p#)` | `pointer → number` | Get bottom margin |
| `path_marginbottom#(p#, val)` | `pointer, number → pointer` | Set bottom margin |
| `path_margins#(p#, l, t, r, b)` | `pointer, num×4 → pointer` | Set all margins |
| `path_margin#(p#, val)` | `pointer, number → pointer` | Set uniform margin |

### Visibility and Behavior

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_visible(p#)` | `pointer → number` | Get visibility (0/1) |
| `path_visible#(p#, val)` | `pointer, number → pointer` | Set visibility |
| `path_enabled(p#)` | `pointer → number` | Get enabled state (0/1) |
| `path_enabled#(p#, val)` | `pointer, number → pointer` | Set enabled state |
| `path_opacity(p#)` | `pointer → number` | Get opacity (0.0-1.0) |
| `path_opacity#(p#, val)` | `pointer, number → pointer` | Set opacity |
| `path_hittest(p#)` | `pointer → number` | Get hit test enabled (0/1) |
| `path_hittest#(p#, val)` | `pointer, number → pointer` | Set hit test enabled |

### Tag and Rotation

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_tag(p#)` | `pointer → number` | Get tag value |
| `path_tag#(p#, val)` | `pointer, number → pointer` | Set tag value |
| `path_rotation(p#)` | `pointer → number` | Get rotation angle (control rotation) |
| `path_rotation#(p#, angle)` | `pointer, number → pointer` | Set rotation angle |

### Parent and Z-Order

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_parent#(p#)` | `pointer → pointer` | Get parent control |
| `path_parent#(p#, parent#)` | `pointer, pointer → pointer` | Set parent control |
| `path_bringtofront#(p#)` | `pointer → pointer` | Bring to front of Z-order |
| `path_sendtoback#(p#)` | `pointer → pointer` | Send to back of Z-order |

### Invalidation

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_invalidate#(p#)` | `pointer → pointer` | Force repaint |

### Event Callbacks

| Function | Signature | Description |
|----------|-----------|-------------|
| `path_onclick#(p#, func$)` | `pointer, string → pointer` | Set click handler |
| `path_onclick$(p#)` | `pointer → string` | Get click handler name |
| `path_ondblclick#(p#, func$)` | `pointer, string → pointer` | Set double-click handler |
| `path_ondblclick$(p#)` | `pointer → string` | Get double-click handler name |
| `path_onmousedown#(p#, func$)` | `pointer, string → pointer` | Set mouse down handler |
| `path_onmousedown$(p#)` | `pointer → string` | Get mouse down handler name |
| `path_onmouseup#(p#, func$)` | `pointer, string → pointer` | Set mouse up handler |
| `path_onmouseup$(p#)` | `pointer → string` | Get mouse up handler name |
| `path_onmousemove#(p#, func$)` | `pointer, string → pointer` | Set mouse move handler |
| `path_onmousemove$(p#)` | `pointer → string` | Get mouse move handler name |
| `path_onmouseenter#(p#, func$)` | `pointer, string → pointer` | Set mouse enter handler |
| `path_onmouseenter$(p#)` | `pointer → string` | Get mouse enter handler name |
| `path_onmouseleave#(p#, func$)` | `pointer, string → pointer` | Set mouse leave handler |
| `path_onmouseleave$(p#)` | `pointer → string` | Get mouse leave handler name |
| `path_onmousewheel#(p#, func$)` | `pointer, string → pointer` | Set mouse wheel handler |
| `path_onmousewheel$(p#)` | `pointer → string` | Get mouse wheel handler name |
| `path_onresize#(p#, func$)` | `pointer, string → pointer` | Set resize handler |
| `path_onresize$(p#)` | `pointer → string` | Get resize handler name |
| `path_clearcallbacks#(p#)` | `pointer → pointer` | Clear all event callbacks |

## Event Callback Signatures

### OnClick / OnDblClick / OnMouseEnter / OnMouseLeave / OnResize

```basic
function MyHandler(sender#)
  ' sender# is the path that triggered the event
  println "Event triggered!"
end function
```

### OnMouseDown / OnMouseUp

```basic
function MyMouseHandler(sender#, button, x, y, shift$)
  ' button: 0=Left, 1=Right, 2=Middle
  ' x, y: Mouse coordinates
  ' shift$: Modifier keys string
  println "Mouse at: " + stri$(x) + ", " + stri$(y)
end function
```

### OnMouseMove

```basic
function MyMoveHandler(sender#, x, y, shift$)
  ' x, y: Mouse coordinates
  ' shift$: Modifier keys string
  println "Moving at: " + stri$(x) + ", " + stri$(y)
end function
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
  end if
end function
```

## Complete Example: Space Shooter Game Sprite

```basic
' ============================================================================
' PathLib Demo - Space Shooter Sprites
' ============================================================================

let frm# = form#("Space Shooter Sprites", 800, 600)

' Player spaceship (arrow shape)
let ship# = path#(frm#, 375, 500, 50, 60)
path_data#(ship#, "M 25,0 L 50,60 L 25,45 L 0,60 Z")
path_fill#(ship#, "#3498db")
path_stroke#(ship#, "#2980b9")
path_strokethickness#(ship#, 2)
path_onclick#(ship#, "OnShipClick")
path_onmouseenter#(ship#, "OnShipEnter")
path_onmouseleave#(ship#, "OnShipLeave")

' Enemy UFO (programmatic construction)
let ufo# = path#(frm#, 100, 100, 80, 50)
path_addellipse#(ufo#, 10, 20, 60, 25)  ' Body
path_addellipse#(ufo#, 25, 5, 30, 20)   ' Dome
path_fill#(ufo#, "#e74c3c")
path_stroke#(ufo#, "#c0392b")
path_strokethickness#(ufo#, 2)

' Star (5-pointed)
let star# = path#(frm#, 700, 50, 60, 60)
path_data#(star#, "M 30,0 L 36,22 L 60,22 L 42,36 L 48,58 L 30,44 L 12,58 L 18,36 L 0,22 L 24,22 Z")
path_fill#(star#, "#f1c40f")
path_stroke#(star#, "#d4ac0d")
path_strokethickness#(star#, 1)

' Asteroid (irregular polygon)
let asteroid# = path#(frm#, 300, 200, 80, 80)
path_moveto#(asteroid#, 40, 5)
path_lineto#(asteroid#, 65, 15)
path_lineto#(asteroid#, 75, 35)
path_lineto#(asteroid#, 70, 55)
path_lineto#(asteroid#, 50, 75)
path_lineto#(asteroid#, 25, 70)
path_lineto#(asteroid#, 10, 50)
path_lineto#(asteroid#, 5, 30)
path_lineto#(asteroid#, 20, 10)
path_closepath#(asteroid#)
path_fill#(asteroid#, "#7f8c8d")
path_stroke#(asteroid#, "#596066")
path_strokethickness#(asteroid#, 2)

' Power-up (heart shape using curves)
let heart# = path#(frm#, 500, 300, 60, 60)
path_data#(heart#, "M 30,15 C 15,0 0,15 30,55 C 60,15 45,0 30,15 Z")
path_fill#(heart#, "#e91e63")
path_stroke#(heart#, "#c2185b")
path_strokethickness#(heart#, 2)

' Laser beam
let laser# = path#(frm#, 395, 450, 10, 40)
path_addrectangle#(laser#, 0, 0, 10, 40, 2, 2)
path_fill#(laser#, "#00ff00")
path_strokenone#(laser#)
path_opacity#(laser#, 0.8)

' Shield (arc)
let shield# = path#(frm#, 350, 480, 100, 40)
path_addarc#(shield#, 50, 40, 45, 35, 180, 180)
path_fillnone#(shield#)
path_stroke#(shield#, "#00ffff")
path_strokethickness#(shield#, 3)
path_opacity#(shield#, 0.6)

' Instructions
let lbl# = label#(frm#, "Click and hover over the spaceship!", 280, 570)

form_show(frm#)

' Ship rotation angle
let shipAngle = 0

function OnShipClick(sender#)
  ' Rotate ship on click
  shipAngle = shipAngle + 15
  if shipAngle >= 360 then
    shipAngle = 0
  end if
  path_rotation#(sender#, shipAngle)
  label_text#(lbl#, "Ship rotation: " + stri$(shipAngle) + " degrees")
end function

function OnShipEnter(sender#)
  ' Highlight ship
  path_fill#(sender#, "#2ecc71")
  path_stroke#(sender#, "#27ae60")
end function

function OnShipLeave(sender#)
  ' Reset ship color
  path_fill#(sender#, "#3498db")
  path_stroke#(sender#, "#2980b9")
end function
```

## Tips and Best Practices

### Coordinate System

Path coordinates are relative to the path's bounds, not the form. The path is then scaled/positioned according to WrapMode.

### Performance

- Use `path_data#` with SVG strings for complex static shapes
- Use programmatic construction when building shapes dynamically
- Clear paths with `path_clear#` before rebuilding

### Transformations

- `path_scale#`, `path_translate#`, `path_rotate#` modify the **path data itself**
- `path_rotation#` rotates the **control** (like other controls)
- For animated rotation, use `path_rotation#` (doesn't modify path data)

### WrapMode Selection

- Use **Stretch** (2) for UI elements that should fill their bounds
- Use **Fit** (1) for icons/sprites that should maintain aspect ratio
- Use **Original** (0) when you need pixel-perfect positioning
- Use **Tile** (3) for patterns and backgrounds

## Platform Support

PathLib supports all platforms:

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## See Also

- **CircleLib** - Circle/ellipse shapes
- **RectangleLib** - Rectangle shapes
- **LineLib** - Line shapes
- **ArcLib** - Arc shapes
- **PieLib** - Pie/wedge shapes
- **CalloutRectangleLib** - Speech bubble shapes

---

*Copyright © 2024-2025 Plan9Basic Project*
