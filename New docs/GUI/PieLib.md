# PieLib - Pie/Wedge Shape Library for Plan9Basic

## Overview

PieLib provides functionality for creating and managing pie (wedge) shapes in Plan9Basic programs. Pies are filled sectors of an ellipse defined by start and end angles, useful for pie charts, gauges, circular menus, and decorative elements. Unlike arcs, pies include the center point, creating a filled wedge shape.

**Function Count:** 86 functions

> **Note:** Pies are `TShape` descendants and do not support anchors, padding, drag events, cursor, or scale properties.

## Quick Start

```basic
' Create a simple pie wedge (quarter circle)
let frm# = form#("Pie Demo", 400, 300)
let pie# = pie#(frm#, 50, 50, 200, 200)
pie_startangle#(pie#, 0)
pie_endangle#(pie#, 90)
pie_fill#(pie#, "#e74c3c")
pie_stroke#(pie#, "#c0392b")
pie_strokethickness#(pie#, 2)
form_show(frm#)
```

## Function Reference

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `pie#(parent#)` | Create pie with parent only |
| `pie#(parent#, width, height)` | Create with size |
| `pie#(parent#, x, y, width, height)` | Create with position and size |
| `pie_free(pie#)` | Free pie (returns 1 on success) |

### Pie-Specific Properties

| Function | Description |
|----------|-------------|
| `pie_startangle(pie#)` / `pie_startangle#(pie#, value)` | Get/set start angle in degrees |
| `pie_endangle(pie#)` / `pie_endangle#(pie#, value)` | Get/set end angle in degrees |
| `pie_angles#(pie#, start, end)` | Set both angles at once |

### Fill Properties

| Function | Description |
|----------|-------------|
| `pie_fill$(pie#)` | Get fill color as string |
| `pie_fill#(pie#, color$)` | Set fill color (hex: "#RRGGBB" or "#AARRGGBB") |
| `pie_fillnone#(pie#)` | Remove fill (transparent) |

### Stroke Properties

| Function | Description |
|----------|-------------|
| `pie_stroke$(pie#)` | Get stroke color |
| `pie_stroke#(pie#, color$)` | Set stroke color |
| `pie_strokenone#(pie#)` | Remove stroke |
| `pie_strokethickness(pie#)` / `pie_strokethickness#(pie#, value)` | Get/set stroke thickness |
| `pie_strokedash(pie#)` / `pie_strokedash#(pie#, value)` | Get/set dash style (0=Solid, 1=Dash, 2=Dot, 3=DashDot, 4=DashDotDot) |
| `pie_strokecap(pie#)` / `pie_strokecap#(pie#, value)` | Get/set cap style (0=Flat, 1=Round) |
| `pie_strokejoin(pie#)` / `pie_strokejoin#(pie#, value)` | Get/set join style (0=Miter, 1=Round, 2=Bevel) |

### Position and Size

| Function | Description |
|----------|-------------|
| `pie_x(pie#)` / `pie_x#(pie#, value)` | Get/set X position |
| `pie_y(pie#)` / `pie_y#(pie#, value)` | Get/set Y position |
| `pie_width(pie#)` / `pie_width#(pie#, value)` | Get/set width |
| `pie_height(pie#)` / `pie_height#(pie#, value)` | Get/set height |
| `pie_bounds#(pie#, x, y, w, h)` | Set position and size at once |
| `pie_size#(pie#, width, height)` | Set width and height |
| `pie_move#(pie#, x, y)` | Set X and Y position |

### Visual Properties

| Function | Description |
|----------|-------------|
| `pie_visible(pie#)` / `pie_visible#(pie#, value)` | Get/set visibility (0/1) |
| `pie_enabled(pie#)` / `pie_enabled#(pie#, value)` | Get/set enabled state |
| `pie_opacity(pie#)` / `pie_opacity#(pie#, value)` | Get/set opacity (0.0-1.0) |
| `pie_hittest(pie#)` / `pie_hittest#(pie#, value)` | Get/set hit testing (0/1) |
| `pie_rotation(pie#)` / `pie_rotation#(pie#, angle)` | Get/set rotation angle in degrees |

### Alignment

| Function | Description |
|----------|-------------|
| `pie_align(pie#)` / `pie_align#(pie#, value)` | Get/set alignment (0=None, 1=Top, 2=Left, 3=Right, 4=Bottom, 5=MostTop, 6=MostBottom, 7=MostLeft, 8=MostRight, 9=Client, 10=Contents, 11=Center, 12=VertCenter, 13=HorzCenter, 14=Fit, 15=FitLeft, 16=FitRight) |

### Margins

| Function | Description |
|----------|-------------|
| `pie_margins#(pie#, left, top, right, bottom)` | Set all margins |
| `pie_marginleft(pie#)` / `pie_marginleft#(pie#, value)` | Get/set left margin |
| `pie_margintop(pie#)` / `pie_margintop#(pie#, value)` | Get/set top margin |
| `pie_marginright(pie#)` / `pie_marginright#(pie#, value)` | Get/set right margin |
| `pie_marginbottom(pie#)` / `pie_marginbottom#(pie#, value)` | Get/set bottom margin |
| `pie_margin#(pie#, value)` | Set uniform margin (all sides equal) |

### Tag Property

| Function | Description |
|----------|-------------|
| `pie_tag(pie#)` / `pie_tag#(pie#, value)` | Get/set numeric tag |

### Event Handlers

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `pie_onclick#(pie#, callback$)` | `pie_onclick$(pie#)` | `function(sender#)` |
| OnDblClick | `pie_ondblclick#(pie#, callback$)` | `pie_ondblclick$(pie#)` | `function(sender#)` |
| OnMouseDown | `pie_onmousedown#(pie#, callback$)` | `pie_onmousedown$(pie#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `pie_onmouseup#(pie#, callback$)` | `pie_onmouseup$(pie#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `pie_onmousemove#(pie#, callback$)` | `pie_onmousemove$(pie#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `pie_onmouseenter#(pie#, callback$)` | `pie_onmouseenter$(pie#)` | `function(sender#)` |
| OnMouseLeave | `pie_onmouseleave#(pie#, callback$)` | `pie_onmouseleave$(pie#)` | `function(sender#)` |
| OnMouseWheel | `pie_onmousewheel#(pie#, callback$)` | `pie_onmousewheel$(pie#)` | `function(sender#, delta)` |
| OnResize | `pie_onresize#(pie#, callback$)` | `pie_onresize$(pie#)` | `function(sender#)` |

Use `pie_clearcallbacks#(pie#)` to disconnect all event handlers.

### Hierarchy

| Function | Description |
|----------|-------------|
| `pie_parent#(pie#)` | Get parent control |
| `pie_parent#(pie#, parent#)` | Set parent control |
| `pie_bringtofront#(pie#)` | Bring pie to front |
| `pie_sendtoback#(pie#)` | Send pie to back |
| `pie_invalidate#(pie#)` | Force redraw of the pie |
| `pie_clearcallbacks#(pie#)` | Disconnects all event callbacks |

### Error Handling

| Function | Description |
|----------|-------------|
| `pie_error()` | Get last error code |
| `pie_errormsg$()` | Get last error message |
| `pie_strerror$(code)` | Get error description for code |
| `pie_clearerror()` | Clear error state |

## Angle System

Angles are measured in degrees:
- **0°** = Right (3 o'clock position)
- **90°** = Bottom (6 o'clock position)
- **180°** = Left (9 o'clock position)
- **270°** = Top (12 o'clock position)
- **360°** = Full circle (back to right)

The pie wedge is drawn clockwise from start angle to end angle.

## Pie vs Arc

| Feature | Pie | Arc |
|---------|-----|-----|
| Shape | Filled wedge (includes center) | Curved segment only |
| Fill | Always includes center | Only the arc band |
| Use case | Pie charts, gauges | Progress rings, decorations |

## Examples

### Example 1: Simple Pie Chart

```basic
' Create a simple pie chart with 3 segments
let frm# = form#("Pie Chart", 400, 400)

' Segment 1: 40% (144 degrees)
let p1# = pie#(frm#, 100, 100, 200, 200)
pie_startangle#(p1#, 0)
pie_endangle#(p1#, 144)
pie_fill#(p1#, "#e74c3c")
pie_stroke#(p1#, "#c0392b")

' Segment 2: 35% (126 degrees)
let p2# = pie#(frm#, 100, 100, 200, 200)
pie_startangle#(p2#, 144)
pie_endangle#(p2#, 270)
pie_fill#(p2#, "#3498db")
pie_stroke#(p2#, "#2980b9")

' Segment 3: 25% (90 degrees)
let p3# = pie#(frm#, 100, 100, 200, 200)
pie_startangle#(p3#, 270)
pie_endangle#(p3#, 360)
pie_fill#(p3#, "#2ecc71")
pie_stroke#(p3#, "#27ae60")

form_show(frm#)
```

### Example 2: Interactive Pie Segment

```basic
let frm# = form#("Interactive Pie", 350, 350)
let pie# = pie#(frm#, 75, 75, 200, 200)
pie_startangle#(pie#, 0)
pie_endangle#(pie#, 120)
pie_fill#(pie#, "#9b59b6")
pie_stroke#(pie#, "#8e44ad")
pie_hittest#(pie#, 1)

pie_onclick#(pie#, "OnPieClick")
pie_onmouseenter#(pie#, "OnPieEnter")
pie_onmouseleave#(pie#, "OnPieLeave")

form_show(frm#)

function OnPieClick(sender#) local currentEnd
  currentEnd = pie_endangle(sender#)
  if currentEnd >= 360 then
    pie_endangle#(sender#, 120)
  else
    pie_endangle#(sender#, currentEnd + 30)
  end if
endfunction

function OnPieEnter(sender#)
  pie_opacity#(sender#, 0.8)
endfunction

function OnPieLeave(sender#)
  pie_opacity#(sender#, 1.0)
endfunction
```

### Example 3: Pac-Man Animation

```basic
let frm# = form#("Pac-Man", 300, 300)
let pac# = pie#(frm#, 50, 50, 200, 200)
pie_fill#(pac#, "#f1c40f")
pie_strokenone#(pac#)

let mouthOpen = 1
let tmr# = timer#(frm#, 200)
timer_ontimer#(tmr#, "OnTimer")
timer_start(tmr#)

form_show(frm#)

function OnTimer(sender#)
  if mouthOpen = 1 then
    pie_startangle#(pac#, 30)
    pie_endangle#(pac#, 330)
    mouthOpen = 0
  else
    pie_startangle#(pac#, 0)
    pie_endangle#(pac#, 360)
    mouthOpen = 1
  end if
endfunction
```

### Example 4: Progress Meter

```basic
' Pie-based progress meter showing 65%
let frm# = form#("Progress", 300, 300)

' Background (full circle)
let bg# = pie#(frm#, 50, 50, 200, 200)
pie_startangle#(bg#, 0)
pie_endangle#(bg#, 360)
pie_fill#(bg#, "#ecf0f1")
pie_strokenone#(bg#)

' Progress (65% = 234 degrees)
let prog# = pie#(frm#, 50, 50, 200, 200)
pie_startangle#(prog#, -90)
pie_endangle#(prog#, 144)
pie_fill#(prog#, "#27ae60")
pie_strokenone#(prog#)

form_show(frm#)
```

## Notes

- Use equal width and height for circular pies
- Start angle must be less than end angle for visible wedge
- Stroke outlines the entire wedge including radii lines to center
- Set `hittest` to 1 to enable mouse events on pie segments
- For donut charts, overlay a smaller circle in the center
- Negative angles are supported and can simplify positioning
- Use `pie_rotation#()` to rotate the entire control (different from angles)

---

*PieLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
