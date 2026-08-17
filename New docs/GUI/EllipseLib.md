# EllipseLib - Ellipse Shape Library for Plan9Basic

## Overview

EllipseLib provides functionality for creating and managing ellipse shapes in Plan9Basic programs. Ellipses are oval shapes defined by width and height dimensions, useful for creating circular UI elements, indicators, decorative graphics, and data visualizations.

**Function Count:** 81 functions

> **Note:** Ellipses are `TShape` descendants and do not support anchors, padding, drag events, cursor, or scale properties.

## Quick Start

```basic
' Create a simple ellipse
let frm# = form#("Ellipse Demo", 400, 300)
let ell# = ellipse#(frm#, 50, 50, 200, 100)
ellipse_fill#(ell#, "#3498db")
ellipse_stroke#(ell#, "#2c3e50")
ellipse_strokethickness#(ell#, 2)
form_show(frm#)
```

## Function Reference

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `ellipse#(parent#)` | Create ellipse with parent only |
| `ellipse#(parent#, width, height)` | Create with size |
| `ellipse#(parent#, x, y, width, height)` | Create with position and size |
| `ellipse_free(ell#)` | Free ellipse (returns 1 on success) |

### Fill Properties

| Function | Description |
|----------|-------------|
| `ellipse_fill$(ell#)` | Get fill color as string |
| `ellipse_fill#(ell#, color$)` | Set fill color (hex: "#RRGGBB" or "#AARRGGBB") |
| `ellipse_fillnone#(ell#)` | Remove fill (transparent) |

### Stroke Properties

| Function | Description |
|----------|-------------|
| `ellipse_stroke$(ell#)` | Get stroke color |
| `ellipse_stroke#(ell#, color$)` | Set stroke color |
| `ellipse_strokenone#(ell#)` | Remove stroke |
| `ellipse_strokethickness(ell#)` / `ellipse_strokethickness#(ell#, value)` | Get/set stroke thickness |
| `ellipse_strokedash(ell#)` / `ellipse_strokedash#(ell#, value)` | Get/set dash style (0=Solid, 1=Dash, 2=Dot, 3=DashDot, 4=DashDotDot) |
| `ellipse_strokecap(ell#)` / `ellipse_strokecap#(ell#, value)` | Get/set cap style (0=Flat, 1=Round) |
| `ellipse_strokejoin(ell#)` / `ellipse_strokejoin#(ell#, value)` | Get/set join style (0=Miter, 1=Round, 2=Bevel) |

### Position and Size

| Function | Description |
|----------|-------------|
| `ellipse_x(ell#)` / `ellipse_x#(ell#, value)` | Get/set X position |
| `ellipse_y(ell#)` / `ellipse_y#(ell#, value)` | Get/set Y position |
| `ellipse_width(ell#)` / `ellipse_width#(ell#, value)` | Get/set width |
| `ellipse_height(ell#)` / `ellipse_height#(ell#, value)` | Get/set height |
| `ellipse_bounds#(ell#, x, y, w, h)` | Set position and size at once |
| `ellipse_size#(ell#, width, height)` | Set width and height |
| `ellipse_move#(ell#, x, y)` | Set X and Y position |

### Visual Properties

| Function | Description |
|----------|-------------|
| `ellipse_visible(ell#)` / `ellipse_visible#(ell#, value)` | Get/set visibility (0/1) |
| `ellipse_enabled(ell#)` / `ellipse_enabled#(ell#, value)` | Get/set enabled state |
| `ellipse_opacity(ell#)` / `ellipse_opacity#(ell#, value)` | Get/set opacity (0.0-1.0) |
| `ellipse_hittest(ell#)` / `ellipse_hittest#(ell#, value)` | Get/set hit testing (0/1) |
| `ellipse_rotation(ell#)` / `ellipse_rotation#(ell#, angle)` | Get/set rotation angle in degrees |

### Alignment

| Function | Description |
|----------|-------------|
| `ellipse_align(ell#)` / `ellipse_align#(ell#, value)` | Get/set alignment (0=None, 1=Top, 2=Left, 3=Right, 4=Bottom, 5=MostTop, 6=MostBottom, 7=MostLeft, 8=MostRight, 9=Client, 10=Contents, 11=Center, 12=VertCenter, 13=HorzCenter, 14=Fit, 15=FitLeft, 16=FitRight) |

### Margins

| Function | Description |
|----------|-------------|
| `ellipse_margins#(ell#, left, top, right, bottom)` | Set all margins |
| `ellipse_marginleft(ell#)` / `ellipse_marginleft#(ell#, value)` | Get/set left margin |
| `ellipse_margintop(ell#)` / `ellipse_margintop#(ell#, value)` | Get/set top margin |
| `ellipse_marginright(ell#)` / `ellipse_marginright#(ell#, value)` | Get/set right margin |
| `ellipse_marginbottom(ell#)` / `ellipse_marginbottom#(ell#, value)` | Get/set bottom margin |
| `ellipse_margin#(ell#, value)` | Set uniform margin (all sides) |

### Tag Property

| Function | Description |
|----------|-------------|
| `ellipse_tag(ell#)` / `ellipse_tag#(ell#, value)` | Get/set numeric tag |

### Event Handlers

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `ellipse_onclick#(ell#, callback$)` | `ellipse_onclick$(ell#)` | `function(sender#)` |
| OnDblClick | `ellipse_ondblclick#(ell#, callback$)` | `ellipse_ondblclick$(ell#)` | `function(sender#)` |
| OnMouseDown | `ellipse_onmousedown#(ell#, callback$)` | `ellipse_onmousedown$(ell#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `ellipse_onmouseup#(ell#, callback$)` | `ellipse_onmouseup$(ell#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `ellipse_onmousemove#(ell#, callback$)` | `ellipse_onmousemove$(ell#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `ellipse_onmouseenter#(ell#, callback$)` | `ellipse_onmouseenter$(ell#)` | `function(sender#)` |
| OnMouseLeave | `ellipse_onmouseleave#(ell#, callback$)` | `ellipse_onmouseleave$(ell#)` | `function(sender#)` |
| OnMouseWheel | `ellipse_onmousewheel#(ell#, callback$)` | `ellipse_onmousewheel$(ell#)` | `function(sender#, delta)` |
| OnResize | `ellipse_onresize#(ell#, callback$)` | `ellipse_onresize$(ell#)` | `function(sender#)` |

Use `ellipse_clearcallbacks#(ell#)` to disconnect all event handlers.

### Hierarchy

| Function | Description |
|----------|-------------|
| `ellipse_parent#(ell#)` | Get parent control |
| `ellipse_parent#(ell#, parent#)` | Set parent control |
| `ellipse_bringtofront#(ell#)` | Bring ellipse to front |
| `ellipse_sendtoback#(ell#)` | Send ellipse to back |
| `ellipse_invalidate#(ell#)` | Force redraw of the ellipse |
| `ellipse_clearcallbacks#(ell#)` | Disconnects all event callbacks |

### Error Handling

| Function | Description |
|----------|-------------|
| `ellipse_error()` | Get last error code |
| `ellipse_errormsg$()` | Get last error message |
| `ellipse_strerror$(code)` | Get error description for code |
| `ellipse_clearerror()` | Clear error state |

## Examples

### Example 1: Basic Ellipse

```basic
' Create a simple colored ellipse
let frm# = form#("Basic Ellipse", 300, 250)
let ell# = ellipse#(frm#, 50, 50, 200, 120)
ellipse_fill#(ell#, "#e74c3c")
ellipse_stroke#(ell#, "#c0392b")
ellipse_strokethickness#(ell#, 3)
form_show(frm#)
```

### Example 2: Circle (Equal Width and Height)

```basic
' Create a perfect circle
let frm# = form#("Circle", 300, 300)
let circ# = ellipse#(frm#, 50, 50, 150, 150)
ellipse_fill#(circ#, "#3498db")
ellipse_stroke#(circ#, "#2980b9")
ellipse_strokethickness#(circ#, 2)
form_show(frm#)
```

### Example 3: Interactive Ellipse with Events

```basic
let frm# = form#("Interactive Ellipse", 400, 300)
let ell# = ellipse#(frm#, 100, 75, 200, 150)
ellipse_fill#(ell#, "#9b59b6")
ellipse_stroke#(ell#, "#8e44ad")
ellipse_hittest#(ell#, 1)

ellipse_onclick#(ell#, "OnEllipseClick")
ellipse_onmouseenter#(ell#, "OnMouseEnter")
ellipse_onmouseleave#(ell#, "OnMouseLeave")

form_show(frm#)

function OnEllipseClick(sender#)
  ellipse_fill#(sender#, "#e74c3c")
endfunction

function OnMouseEnter(sender#)
  ellipse_opacity#(sender#, 0.7)
endfunction

function OnMouseLeave(sender#)
  ellipse_opacity#(sender#, 1.0)
endfunction
```

## Notes

- Use equal width and height values to create a perfect circle
- Set `hittest` to 1 to enable mouse events
- Stroke dash styles work best with thicker strokes
- Opacity affects both fill and stroke
- Ellipses support rotation via `ellipse_rotation#()`

---

*EllipseLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
