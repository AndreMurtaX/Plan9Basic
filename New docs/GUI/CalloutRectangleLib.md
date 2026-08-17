# CalloutRectangleLib - Callout/Speech Bubble Shape Library for Plan9Basic

## Overview

CalloutRectangleLib provides functionality for creating and managing callout rectangle shapes in Plan9Basic programs. Callouts are rectangular shapes with a pointer (tail) extending from one side, commonly used for speech bubbles, tooltips, annotations, and informational popups.

**Function Count:** 94 functions

> **Note:** Callout rectangles are `TShape` descendants and do not support anchors, padding, drag events, cursor, or scale properties.

## Quick Start

```basic
' Create a simple speech bubble
let frm# = form#("Callout Demo", 400, 300)
let cal# = callout#(frm#, 50, 50, 250, 100)
callout_fill#(cal#, "#ecf0f1")
callout_stroke#(cal#, "#bdc3c7")
callout_strokethickness#(cal#, 2)
callout_calloutposition#(cal#, 2)
callout_calloutlength#(cal#, 20)
form_show(frm#)
```

## Function Reference

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `callout#(parent#)` | Create callout with parent only |
| `callout#(parent#, width, height)` | Create with size |
| `callout#(parent#, x, y, width, height)` | Create with position and size |
| `callout_free(callout#)` | Free callout (returns 1 on success) |

### Callout-Specific Properties

| Function | Description |
|----------|-------------|
| `callout_calloutlength(cal#)` / `callout_calloutlength#(cal#, value)` | Get/set pointer length (how far it extends) |
| `callout_calloutwidth(cal#)` / `callout_calloutwidth#(cal#, value)` | Get/set pointer base width |
| `callout_calloutposition(cal#)` / `callout_calloutposition#(cal#, value)` | Get/set pointer side (0=Top, 1=Left, 2=Bottom, 3=Right) |
| `callout_calloutoffset(cal#)` / `callout_calloutoffset#(cal#, value)` | Get/set pointer position along the edge |

### Rounded Corners

| Function | Description |
|----------|-------------|
| `callout_xradius(cal#)` / `callout_xradius#(cal#, value)` | Get/set X corner radius |
| `callout_yradius(cal#)` / `callout_yradius#(cal#, value)` | Get/set Y corner radius |
| `callout_corners#(cal#, xr, yr)` | Set both radii at once |

### Fill Properties

| Function | Description |
|----------|-------------|
| `callout_fill$(cal#)` | Get fill color as string |
| `callout_fill#(cal#, color$)` | Set fill color (hex: "#RRGGBB" or "#AARRGGBB") |
| `callout_fillnone#(cal#)` | Remove fill (transparent) |

### Stroke Properties

| Function | Description |
|----------|-------------|
| `callout_stroke$(cal#)` | Get stroke color |
| `callout_stroke#(cal#, color$)` | Set stroke color |
| `callout_strokenone#(cal#)` | Remove stroke |
| `callout_strokethickness(cal#)` / `callout_strokethickness#(cal#, value)` | Get/set stroke thickness |
| `callout_strokedash(cal#)` / `callout_strokedash#(cal#, value)` | Get/set dash style (0=Solid, 1=Dash, 2=Dot, 3=DashDot, 4=DashDotDot) |
| `callout_strokecap(cal#)` / `callout_strokecap#(cal#, value)` | Get/set cap style (0=Flat, 1=Round) |
| `callout_strokejoin(cal#)` / `callout_strokejoin#(cal#, value)` | Get/set join style (0=Miter, 1=Round, 2=Bevel) |

### Position and Size

| Function | Description |
|----------|-------------|
| `callout_x(cal#)` / `callout_x#(cal#, value)` | Get/set X position |
| `callout_y(cal#)` / `callout_y#(cal#, value)` | Get/set Y position |
| `callout_width(cal#)` / `callout_width#(cal#, value)` | Get/set width |
| `callout_height(cal#)` / `callout_height#(cal#, value)` | Get/set height |
| `callout_bounds#(cal#, x, y, w, h)` | Set position and size at once |
| `callout_size#(cal#, width, height)` | Set width and height |
| `callout_move#(cal#, x, y)` | Set X and Y position |

### Visual Properties

| Function | Description |
|----------|-------------|
| `callout_visible(cal#)` / `callout_visible#(cal#, value)` | Get/set visibility (0/1) |
| `callout_enabled(cal#)` / `callout_enabled#(cal#, value)` | Get/set enabled state |
| `callout_opacity(cal#)` / `callout_opacity#(cal#, value)` | Get/set opacity (0.0-1.0) |
| `callout_hittest(cal#)` / `callout_hittest#(cal#, value)` | Get/set hit testing (0/1) |
| `callout_rotation(cal#)` / `callout_rotation#(cal#, angle)` | Get/set rotation angle in degrees |

### Alignment

| Function | Description |
|----------|-------------|
| `callout_align(cal#)` / `callout_align#(cal#, value)` | Get/set alignment (0=None, 1=Top, 2=Left, 3=Right, 4=Bottom, 5=MostTop, 6=MostBottom, 7=MostLeft, 8=MostRight, 9=Client, 10=Contents, 11=Center, 12=VertCenter, 13=HorzCenter, 14=Fit, 15=FitLeft, 16=FitRight) |

### Margins

| Function | Description |
|----------|-------------|
| `callout_margins#(cal#, left, top, right, bottom)` | Set all margins |
| `callout_marginleft(cal#)` / `callout_marginleft#(cal#, value)` | Get/set left margin |
| `callout_margintop(cal#)` / `callout_margintop#(cal#, value)` | Get/set top margin |
| `callout_marginright(cal#)` / `callout_marginright#(cal#, value)` | Get/set right margin |
| `callout_marginbottom(cal#)` / `callout_marginbottom#(cal#, value)` | Get/set bottom margin |
| `callout_margin#(cal#, value)` | Set uniform margin (all sides equal) |

### Tag Property

| Function | Description |
|----------|-------------|
| `callout_tag(cal#)` / `callout_tag#(cal#, value)` | Get/set numeric tag |

### Event Handlers

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `callout_onclick#(cal#, callback$)` | `callout_onclick$(cal#)` | `function(sender#)` |
| OnDblClick | `callout_ondblclick#(cal#, callback$)` | `callout_ondblclick$(cal#)` | `function(sender#)` |
| OnMouseDown | `callout_onmousedown#(cal#, callback$)` | `callout_onmousedown$(cal#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `callout_onmouseup#(cal#, callback$)` | `callout_onmouseup$(cal#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `callout_onmousemove#(cal#, callback$)` | `callout_onmousemove$(cal#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `callout_onmouseenter#(cal#, callback$)` | `callout_onmouseenter$(cal#)` | `function(sender#)` |
| OnMouseLeave | `callout_onmouseleave#(cal#, callback$)` | `callout_onmouseleave$(cal#)` | `function(sender#)` |
| OnMouseWheel | `callout_onmousewheel#(cal#, callback$)` | `callout_onmousewheel$(cal#)` | `function(sender#, delta)` |
| OnResize | `callout_onresize#(cal#, callback$)` | `callout_onresize$(cal#)` | `function(sender#)` |

Use `callout_clearcallbacks#(cal#)` to disconnect all event handlers.

### Hierarchy

| Function | Description |
|----------|-------------|
| `callout_parent#(cal#)` | Get parent control |
| `callout_parent#(cal#, parent#)` | Set parent control |
| `callout_bringtofront#(cal#)` | Bring callout to front |
| `callout_sendtoback#(cal#)` | Send callout to back |
| `callout_invalidate#(cal#)` | Force redraw of the callout |
| `callout_clearcallbacks#(cal#)` | Disconnects all event callbacks |

### Error Handling

| Function | Description |
|----------|-------------|
| `callout_error()` | Get last error code |
| `callout_errormsg$()` | Get last error message |
| `callout_strerror$(code)` | Get error description for code |
| `callout_clearerror()` | Clear error state |

## Callout Position Values

The `callout_calloutposition#()` function controls which side the pointer appears:

| Value | Position | Description |
|-------|----------|-------------|
| 0 | Top | Pointer points upward from top edge |
| 1 | Left | Pointer points left from left edge |
| 2 | Bottom | Pointer points downward from bottom edge |
| 3 | Right | Pointer points right from right edge |

## Examples

### Example 1: Simple Speech Bubble

```basic
' Create a speech bubble pointing down
let frm# = form#("Speech Bubble", 400, 300)
let cal# = callout#(frm#, 50, 30, 250, 80)
callout_fill#(cal#, "#ffffff")
callout_stroke#(cal#, "#2c3e50")
callout_strokethickness#(cal#, 2)
callout_xradius#(cal#, 10)
callout_yradius#(cal#, 10)
callout_calloutposition#(cal#, 2)
callout_calloutlength#(cal#, 20)
callout_calloutwidth#(cal#, 15)
callout_calloutoffset#(cal#, 30)

' Add a label inside
let lbl# = label#(cal#, "Hello World!", 20, 25)

form_show(frm#)
```

### Example 2: Tooltip Style

```basic
' Create a tooltip pointing up
let frm# = form#("Tooltip", 400, 300)

' Target element
let btn# = button#(frm#, "Hover Me", 150, 150, 100, 40)

' Tooltip callout
let tip# = callout#(frm#, 100, 50, 200, 60)
callout_fill#(tip#, "#34495e")
callout_strokenone#(tip#)
callout_xradius#(tip#, 5)
callout_yradius#(tip#, 5)
callout_calloutposition#(tip#, 2)
callout_calloutlength#(tip#, 10)
callout_calloutwidth#(tip#, 12)
callout_calloutoffset#(tip#, 100)
callout_visible#(tip#, 0)

let lbl# = label#(tip#, "Click to perform action", 15, 18)
label_fontcolor#(lbl#, "#ffffff")

button_onmouseenter#(btn#, "ShowTip")
button_onmouseleave#(btn#, "HideTip")

form_show(frm#)

function ShowTip(sender#)
  callout_visible#(tip#, 1)
endfunction

function HideTip(sender#)
  callout_visible#(tip#, 0)
endfunction
```

### Example 3: Comic Dialog

```basic
' Create comic-style dialog bubbles
let frm# = form#("Comic Dialog", 500, 400)

' First character speech
let bubble1# = callout#(frm#, 50, 30, 200, 80)
callout_fill#(bubble1#, "#ffffff")
callout_stroke#(bubble1#, "#000000")
callout_strokethickness#(bubble1#, 2)
callout_xradius#(bubble1#, 20)
callout_yradius#(bubble1#, 20)
callout_calloutposition#(bubble1#, 2)
callout_calloutlength#(bubble1#, 25)
callout_calloutoffset#(bubble1#, 40)
let lbl1# = label#(bubble1#, "Hi there!", 60, 30)

' Second character speech
let bubble2# = callout#(frm#, 250, 150, 200, 80)
callout_fill#(bubble2#, "#ffffff")
callout_stroke#(bubble2#, "#000000")
callout_strokethickness#(bubble2#, 2)
callout_xradius#(bubble2#, 20)
callout_yradius#(bubble2#, 20)
callout_calloutposition#(bubble2#, 0)
callout_calloutlength#(bubble2#, 25)
callout_calloutoffset#(bubble2#, 150)
let lbl2# = label#(bubble2#, "Hello!", 70, 30)

form_show(frm#)
```

### Example 4: Annotation

```basic
' Create an annotation callout
let frm# = form#("Annotation", 400, 350)

' Content area
let rect# = rectangle#(frm#, 50, 100, 300, 200)
rectangle_fill#(rect#, "#ecf0f1")
rectangle_stroke#(rect#, "#bdc3c7")

' Annotation pointing to content
let ann# = callout#(frm#, 250, 20, 130, 60)
callout_fill#(ann#, "#f1c40f")
callout_stroke#(ann#, "#f39c12")
callout_strokethickness#(ann#, 2)
callout_xradius#(ann#, 5)
callout_yradius#(ann#, 5)
callout_calloutposition#(ann#, 1)
callout_calloutlength#(ann#, 15)
callout_calloutoffset#(ann#, 30)

let lbl# = label#(ann#, "Note!", 45, 20)
label_fontsize#(lbl#, 14)
label_bold#(lbl#, 1)

form_show(frm#)
```

## Notes

- Callout pointer extends beyond the bounding box dimensions
- Adjust `calloutoffset` to position the pointer along the edge
- Larger `calloutwidth` creates a wider pointer base
- Use `xradius` and `yradius` for rounded corners
- Set `hittest` to 1 for interactive callouts
- Consider extra space for pointer when positioning near form edges
- Callouts work well as children of other controls for tooltips
- Use `callout_visible#()` to show/hide tooltips dynamically

---

*CalloutRectangleLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
