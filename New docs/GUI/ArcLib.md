# ArcLib - Arc Shape Library for Plan9Basic

## Overview

ArcLib provides functionality for creating and managing arc shapes in Plan9Basic programs. Arcs are curved segments of an ellipse defined by start and end angles, useful for creating gauges, progress indicators, pie chart segments, and decorative curved elements.

**Function Count:** 86 functions

> **Note:** Arcs are `TShape` descendants and do not support anchors, padding, drag events, cursor, or scale properties.

## Quick Start

```basic
' Create a simple arc (quarter circle)
let frm# = form#("Arc Demo", 400, 300)
let arc# = arc#(frm#, 50, 50, 200, 200)
arc_startangle#(arc#, 0)
arc_endangle#(arc#, 90)
arc_fill#(arc#, "#3498db")
arc_stroke#(arc#, "#2c3e50")
arc_strokethickness#(arc#, 2)
form_show(frm#)
```

## Function Reference

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `arc#(parent#)` | Create arc with parent only |
| `arc#(parent#, width, height)` | Create with size |
| `arc#(parent#, x, y, width, height)` | Create with position and size |
| `arc_free(arc#)` | Free arc (returns 1 on success) |

### Arc-Specific Properties

| Function | Description |
|----------|-------------|
| `arc_startangle(arc#)` / `arc_startangle#(arc#, value)` | Get/set start angle in degrees |
| `arc_endangle(arc#)` / `arc_endangle#(arc#, value)` | Get/set end angle in degrees |
| `arc_angles#(arc#, start, end)` | Set both angles at once |

### Fill Properties

| Function | Description |
|----------|-------------|
| `arc_fill$(arc#)` | Get fill color as string |
| `arc_fill#(arc#, color$)` | Set fill color (hex: "#RRGGBB" or "#AARRGGBB") |
| `arc_fillnone#(arc#)` | Remove fill (transparent) |

### Stroke Properties

| Function | Description |
|----------|-------------|
| `arc_stroke$(arc#)` | Get stroke color |
| `arc_stroke#(arc#, color$)` | Set stroke color |
| `arc_strokenone#(arc#)` | Remove stroke |
| `arc_strokethickness(arc#)` / `arc_strokethickness#(arc#, value)` | Get/set stroke thickness |
| `arc_strokedash(arc#)` / `arc_strokedash#(arc#, value)` | Get/set dash style (0=Solid, 1=Dash, 2=Dot, 3=DashDot, 4=DashDotDot) |
| `arc_strokecap(arc#)` / `arc_strokecap#(arc#, value)` | Get/set cap style (0=Flat, 1=Round) |
| `arc_strokejoin(arc#)` / `arc_strokejoin#(arc#, value)` | Get/set join style (0=Miter, 1=Round, 2=Bevel) |

### Position and Size

| Function | Description |
|----------|-------------|
| `arc_x(arc#)` / `arc_x#(arc#, value)` | Get/set X position |
| `arc_y(arc#)` / `arc_y#(arc#, value)` | Get/set Y position |
| `arc_width(arc#)` / `arc_width#(arc#, value)` | Get/set width |
| `arc_height(arc#)` / `arc_height#(arc#, value)` | Get/set height |
| `arc_bounds#(arc#, x, y, w, h)` | Set position and size at once |
| `arc_size#(arc#, width, height)` | Set width and height |
| `arc_move#(arc#, x, y)` | Set X and Y position |

### Visual Properties

| Function | Description |
|----------|-------------|
| `arc_visible(arc#)` / `arc_visible#(arc#, value)` | Get/set visibility (0/1) |
| `arc_enabled(arc#)` / `arc_enabled#(arc#, value)` | Get/set enabled state |
| `arc_opacity(arc#)` / `arc_opacity#(arc#, value)` | Get/set opacity (0.0-1.0) |
| `arc_hittest(arc#)` / `arc_hittest#(arc#, value)` | Get/set hit testing (0/1) |
| `arc_rotation(arc#)` / `arc_rotation#(arc#, angle)` | Get/set rotation angle in degrees |

### Alignment

| Function | Description |
|----------|-------------|
| `arc_align(arc#)` / `arc_align#(arc#, value)` | Get/set alignment (0=None, 1=Top, 2=Left, 3=Right, 4=Bottom, 5=MostTop, 6=MostBottom, 7=MostLeft, 8=MostRight, 9=Client, 10=Contents, 11=Center, 12=VertCenter, 13=HorzCenter, 14=Fit, 15=FitLeft, 16=FitRight) |

### Margins

| Function | Description |
|----------|-------------|
| `arc_margins#(arc#, left, top, right, bottom)` | Set all margins |
| `arc_marginleft(arc#)` / `arc_marginleft#(arc#, value)` | Get/set left margin |
| `arc_margintop(arc#)` / `arc_margintop#(arc#, value)` | Get/set top margin |
| `arc_marginright(arc#)` / `arc_marginright#(arc#, value)` | Get/set right margin |
| `arc_marginbottom(arc#)` / `arc_marginbottom#(arc#, value)` | Get/set bottom margin |
| `arc_margin#(arc#, value)` | Set uniform margin (all sides equal) |

### Tag Property

| Function | Description |
|----------|-------------|
| `arc_tag(arc#)` / `arc_tag#(arc#, value)` | Get/set numeric tag |

### Event Handlers

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `arc_onclick#(arc#, callback$)` | `arc_onclick$(arc#)` | `function(sender#)` |
| OnDblClick | `arc_ondblclick#(arc#, callback$)` | `arc_ondblclick$(arc#)` | `function(sender#)` |
| OnMouseDown | `arc_onmousedown#(arc#, callback$)` | `arc_onmousedown$(arc#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `arc_onmouseup#(arc#, callback$)` | `arc_onmouseup$(arc#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `arc_onmousemove#(arc#, callback$)` | `arc_onmousemove$(arc#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `arc_onmouseenter#(arc#, callback$)` | `arc_onmouseenter$(arc#)` | `function(sender#)` |
| OnMouseLeave | `arc_onmouseleave#(arc#, callback$)` | `arc_onmouseleave$(arc#)` | `function(sender#)` |
| OnMouseWheel | `arc_onmousewheel#(arc#, callback$)` | `arc_onmousewheel$(arc#)` | `function(sender#, delta)` |
| OnResize | `arc_onresize#(arc#, callback$)` | `arc_onresize$(arc#)` | `function(sender#)` |

Use `arc_clearcallbacks#(arc#)` to disconnect all event handlers.

### Hierarchy

| Function | Description |
|----------|-------------|
| `arc_parent#(arc#)` | Get parent control |
| `arc_parent#(arc#, parent#)` | Set parent control |
| `arc_bringtofront#(arc#)` | Bring arc to front |
| `arc_sendtoback#(arc#)` | Send arc to back |
| `arc_invalidate#(arc#)` | Force redraw of the arc |
| `arc_clearcallbacks#(arc#)` | Disconnects all event callbacks |

### Error Handling

| Function | Description |
|----------|-------------|
| `arc_error()` | Get last error code |
| `arc_errormsg$()` | Get last error message |
| `arc_strerror$(code)` | Get error description for code |
| `arc_clearerror()` | Clear error state |

## Angle System

Angles are measured in degrees:
- **0°** = Right (3 o'clock position)
- **90°** = Bottom (6 o'clock position)
- **180°** = Left (9 o'clock position)
- **270°** = Top (12 o'clock position)
- **360°** = Full circle (back to right)

The arc is drawn clockwise from start angle to end angle.

## Examples

### Example 1: Quarter Circle Arc

```basic
' Create a 90-degree arc (quarter circle)
let frm# = form#("Quarter Arc", 300, 300)
let arc# = arc#(frm#, 50, 50, 200, 200)
arc_startangle#(arc#, 0)
arc_endangle#(arc#, 90)
arc_fill#(arc#, "#2ecc71")
arc_stroke#(arc#, "#27ae60")
arc_strokethickness#(arc#, 2)
form_show(frm#)
```

### Example 2: Progress Gauge

```basic
' Create a progress gauge showing 75%
let frm# = form#("Progress Gauge", 300, 300)

' Background arc (full semi-circle)
let bgArc# = arc#(frm#, 50, 75, 200, 200)
arc_startangle#(bgArc#, 180)
arc_endangle#(bgArc#, 360)
arc_fill#(bgArc#, "#ecf0f1")
arc_stroke#(bgArc#, "#bdc3c7")
arc_strokethickness#(bgArc#, 2)

' Progress arc (75% of semi-circle = 135 degrees)
let progArc# = arc#(frm#, 50, 75, 200, 200)
arc_startangle#(progArc#, 180)
arc_endangle#(progArc#, 315)
arc_fill#(progArc#, "#3498db")
arc_stroke#(progArc#, "#2980b9")
arc_strokethickness#(progArc#, 2)

form_show(frm#)
```

### Example 3: Animated Loading Arc

```basic
let frm# = form#("Loading Animation", 300, 300)
let arc# = arc#(frm#, 75, 75, 150, 150)
arc_fillnone#(arc#)
arc_stroke#(arc#, "#e74c3c")
arc_strokethickness#(arc#, 8)
arc_strokecap#(arc#, 1)
arc_startangle#(arc#, 0)
arc_endangle#(arc#, 90)

let tmr# = timer#(frm#, 50)
timer_ontimer#(tmr#, "OnTimer")
timer_start(tmr#)

form_show(frm#)

let angle = 0

function OnTimer(sender#)
  angle = angle + 10
  if angle >= 360 then angle = 0
  arc_startangle#(arc#, angle)
  arc_endangle#(arc#, angle + 90)
endfunction
```

## Notes

- Arcs are segments of an ellipse, not circular arcs (unless width = height)
- Use equal width and height for circular arcs
- Start angle must be less than end angle for visible arc
- Use `arc_fillnone#()` for stroke-only arcs (outlines)
- Round stroke caps (`arc_strokecap#(arc#, 1)`) look better on thick strokes
- Set `hittest` to 1 to enable mouse events on the arc

---

*ArcLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
