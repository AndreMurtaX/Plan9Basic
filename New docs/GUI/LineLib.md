# LineLib - Line Shape Library for Plan9Basic

## Overview

LineLib provides functionality for creating and managing line shapes in Plan9Basic programs. Lines connect two points and can be styled with different colors, thicknesses, dash patterns, and end caps. Useful for diagrams, connectors, separators, and decorative elements.

**Function Count:** 80 functions

> **Note:** Lines are `TShape` descendants and do not support anchors, padding, drag events, cursor, or scale properties.

## Quick Start

```basic
' Create a simple diagonal line
let frm# = form#("Line Demo", 400, 300)
let ln# = line#(frm#, 50, 50, 150, 100)
line_stroke#(ln#, "#e74c3c")
line_strokethickness#(ln#, 3)
form_show(frm#)
```

## Function Reference

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `line#(parent#)` | Create line with parent only |
| `line#(parent#, width, height)` | Create with size (diagonal from 0,0 to width,height) |
| `line#(parent#, x, y, width, height)` | Create with position and size |
| `line_free(line#)` | Free line (returns 1 on success) |

### Line-Specific Properties

| Function | Description |
|----------|-------------|
| `line_linetype(line#)` / `line_linetype#(line#, value)` | Get/set line type (0=Diagonal, 1=Top, 2=Left) |

**Line Types:**
- **0 = Diagonal**: Line runs from top-left to bottom-right of bounding box
- **1 = Top**: Line runs along the top edge (horizontal)
- **2 = Left**: Line runs along the left edge (vertical)

### Stroke Properties

| Function | Description |
|----------|-------------|
| `line_stroke$(line#)` | Get stroke color |
| `line_stroke#(line#, color$)` | Set stroke color (hex: "#RRGGBB" or "#AARRGGBB") |
| `line_strokenone#(line#)` | Remove stroke (invisible line) |
| `line_strokethickness(line#)` / `line_strokethickness#(line#, value)` | Get/set stroke thickness |
| `line_strokedash(line#)` / `line_strokedash#(line#, value)` | Get/set dash style (0=Solid, 1=Dash, 2=Dot, 3=DashDot, 4=DashDotDot) |
| `line_strokecap(line#)` / `line_strokecap#(line#, value)` | Get/set cap style (0=Flat, 1=Round) |
| `line_strokejoin(line#)` / `line_strokejoin#(line#, value)` | Get/set join style (0=Miter, 1=Round, 2=Bevel) |

### Position and Size

| Function | Description |
|----------|-------------|
| `line_x(line#)` / `line_x#(line#, value)` | Get/set X position |
| `line_y(line#)` / `line_y#(line#, value)` | Get/set Y position |
| `line_width(line#)` / `line_width#(line#, value)` | Get/set width (horizontal extent) |
| `line_height(line#)` / `line_height#(line#, value)` | Get/set height (vertical extent) |
| `line_bounds#(line#, x, y, w, h)` | Set position and size at once |
| `line_size#(line#, width, height)` | Set width and height |
| `line_move#(line#, x, y)` | Set X and Y position |

### Visual Properties

| Function | Description |
|----------|-------------|
| `line_visible(line#)` / `line_visible#(line#, value)` | Get/set visibility (0/1) |
| `line_enabled(line#)` / `line_enabled#(line#, value)` | Get/set enabled state |
| `line_opacity(line#)` / `line_opacity#(line#, value)` | Get/set opacity (0.0-1.0) |
| `line_hittest(line#)` / `line_hittest#(line#, value)` | Get/set hit testing (0/1) |
| `line_rotation(line#)` / `line_rotation#(line#, angle)` | Get/set rotation angle in degrees |

### Alignment

| Function | Description |
|----------|-------------|
| `line_align(line#)` / `line_align#(line#, value)` | Get/set alignment (0=None, 1=Top, 2=Left, 3=Right, 4=Bottom, 5=MostTop, 6=MostBottom, 7=MostLeft, 8=MostRight, 9=Client, 10=Contents, 11=Center, 12=VertCenter, 13=HorzCenter, 14=Fit, 15=FitLeft, 16=FitRight) |

### Margins

| Function | Description |
|----------|-------------|
| `line_margins#(line#, left, top, right, bottom)` | Set all margins |
| `line_marginleft(line#)` / `line_marginleft#(line#, value)` | Get/set left margin |
| `line_margintop(line#)` / `line_margintop#(line#, value)` | Get/set top margin |
| `line_marginright(line#)` / `line_marginright#(line#, value)` | Get/set right margin |
| `line_marginbottom(line#)` / `line_marginbottom#(line#, value)` | Get/set bottom margin |
| `line_margin#(line#, value)` | Set uniform margin (all sides equal) |

### Tag Property

| Function | Description |
|----------|-------------|
| `line_tag(line#)` / `line_tag#(line#, value)` | Get/set numeric tag |

### Event Handlers

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `line_onclick#(line#, callback$)` | `line_onclick$(line#)` | `function(sender#)` |
| OnDblClick | `line_ondblclick#(line#, callback$)` | `line_ondblclick$(line#)` | `function(sender#)` |
| OnMouseDown | `line_onmousedown#(line#, callback$)` | `line_onmousedown$(line#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `line_onmouseup#(line#, callback$)` | `line_onmouseup$(line#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `line_onmousemove#(line#, callback$)` | `line_onmousemove$(line#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `line_onmouseenter#(line#, callback$)` | `line_onmouseenter$(line#)` | `function(sender#)` |
| OnMouseLeave | `line_onmouseleave#(line#, callback$)` | `line_onmouseleave$(line#)` | `function(sender#)` |
| OnMouseWheel | `line_onmousewheel#(line#, callback$)` | `line_onmousewheel$(line#)` | `function(sender#, delta)` |
| OnResize | `line_onresize#(line#, callback$)` | `line_onresize$(line#)` | `function(sender#)` |

Use `line_clearcallbacks#(line#)` to disconnect all event handlers.

### Hierarchy

| Function | Description |
|----------|-------------|
| `line_parent#(line#)` | Get parent control |
| `line_parent#(line#, parent#)` | Set parent control |
| `line_bringtofront#(line#)` | Bring line to front |
| `line_sendtoback#(line#)` | Send line to back |
| `line_invalidate#(line#)` | Force redraw of the line |
| `line_clearcallbacks#(line#)` | Disconnects all event callbacks |

### Error Handling

| Function | Description |
|----------|-------------|
| `line_error()` | Get last error code |
| `line_errormsg$()` | Get last error message |
| `line_strerror$(code)` | Get error description for code |
| `line_clearerror()` | Clear error state |

## Examples

### Example 1: Diagonal Line

```basic
' Create a diagonal line
let frm# = form#("Diagonal Line", 300, 300)
let ln# = line#(frm#, 50, 50, 200, 150)
line_stroke#(ln#, "#3498db")
line_strokethickness#(ln#, 3)
form_show(frm#)
```

### Example 2: Horizontal Separator

```basic
' Create a horizontal separator line
let frm# = form#("Separator", 400, 200)

let lbl1# = label#(frm#, "Section 1", 20, 30)
let sep# = line#(frm#, 20, 70, 360, 1)
line_linetype#(sep#, 1)
line_stroke#(sep#, "#bdc3c7")
line_strokethickness#(sep#, 1)
let lbl2# = label#(frm#, "Section 2", 20, 90)

form_show(frm#)
```

### Example 3: Dashed Lines

```basic
' Create lines with different dash styles
let frm# = form#("Dash Styles", 400, 300)

' Solid line
let ln1# = line#(frm#, 50, 50, 300, 1)
line_linetype#(ln1#, 1)
line_stroke#(ln1#, "#2c3e50")
line_strokethickness#(ln1#, 2)
line_strokedash#(ln1#, 0)

' Dashed line
let ln2# = line#(frm#, 50, 100, 300, 1)
line_linetype#(ln2#, 1)
line_stroke#(ln2#, "#2c3e50")
line_strokethickness#(ln2#, 2)
line_strokedash#(ln2#, 1)

' Dotted line
let ln3# = line#(frm#, 50, 150, 300, 1)
line_linetype#(ln3#, 1)
line_stroke#(ln3#, "#2c3e50")
line_strokethickness#(ln3#, 2)
line_strokedash#(ln3#, 2)

' Dash-Dot line
let ln4# = line#(frm#, 50, 200, 300, 1)
line_linetype#(ln4#, 1)
line_stroke#(ln4#, "#2c3e50")
line_strokethickness#(ln4#, 2)
line_strokedash#(ln4#, 3)

form_show(frm#)
```

### Example 4: Crosshairs

```basic
' Create centered crosshairs
let frm# = form#("Crosshairs", 300, 300)

' Horizontal line
let hLine# = line#(frm#, 0, 150, 300, 1)
line_linetype#(hLine#, 1)
line_stroke#(hLine#, "#e74c3c")
line_strokethickness#(hLine#, 1)

' Vertical line
let vLine# = line#(frm#, 150, 0, 1, 300)
line_stroke#(vLine#, "#e74c3c")
line_strokethickness#(vLine#, 1)

form_show(frm#)
```

## Notes

- Lines have no fill property — use stroke only
- Line type determines how the line is drawn within its bounding box
- For horizontal lines, use `line_linetype#(ln#, 1)` with small height
- For vertical lines, use `line_linetype#(ln#, 2)` or use small width with default line type
- Diagonal lines connect opposite corners of the bounding rectangle
- Set `hittest` to 1 for clickable lines (useful for interactive diagrams)
- Round stroke caps look better on thicker lines

---

*LineLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
