# CircleLib - Circle Shape Library for Plan9Basic

## Overview

CircleLib provides functionality for creating and managing circle shapes in Plan9Basic programs. Circles are perfect for indicators, avatars, buttons, decorations, and data visualization.

**Version:** 1.0.0
**Function Count:** 81 functions

> **Note:** Circles are `TShape` descendants and do not support anchors, padding, drag events, cursor, or scale properties.

## Quick Start

```basic
let frm# = form#("Circle Demo", 400, 300)
form_position#(frm#, 4)

' Simple filled circle
let c1# = circle#(frm#, 50, 50, 100, 100)
circle_fill#(c1#, "#e74c3c")
circle_strokenone#(c1#)

' Circle with border
let c2# = circle#(frm#, 180, 50, 100, 100)
circle_fill#(c2#, "#3498db")
circle_stroke#(c2#, "#2980b9")
circle_strokethickness#(c2#, 3)

' Ring (no fill)
let c3# = circle#(frm#, 310, 50, 100, 100)
circle_fillnone#(c3#)
circle_stroke#(c3#, "#27ae60")
circle_strokethickness#(c3#, 5)

form_show(frm#)
```

## Numeric Values Reference

### Alignment Values

| Value | Description |
|-------|-------------|
| 0 | None (absolute positioning) |
| 1 | Top |
| 2 | Left |
| 3 | Right |
| 4 | Bottom |
| 5 | MostTop |
| 6 | MostBottom |
| 7 | MostLeft |
| 8 | MostRight |
| 9 | Client (fill parent) |
| 10 | Contents |
| 11 | Center |
| 12 | VertCenter |
| 13 | HorzCenter |
| 14 | Fit |
| 15 | FitLeft |
| 16 | FitRight |

### Stroke Dash Styles

| Value | Description |
|-------|-------------|
| 0 | Solid |
| 1 | Dash |
| 2 | Dot |
| 3 | DashDot |
| 4 | DashDotDot |

### Stroke Cap Styles

| Value | Description |
|-------|-------------|
| 0 | Flat |
| 1 | Round |

### Stroke Join Styles

| Value | Description |
|-------|-------------|
| 0 | Miter |
| 1 | Round |
| 2 | Bevel |

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `circle_error()` | Returns last error code (0 = no error) |
| `circle_errormsg$()` | Returns last error message |
| `circle_strerror$(code)` | Converts error code to message |
| `circle_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `circle#(parent#)` | Create with default size |
| `circle#(parent#, w, h)` | Create with size (equal w/h for true circle) |
| `circle#(parent#, x, y, w, h)` | Create with position and size |
| `circle_free(c#)` | Destroy circle |

### Fill (Background)

| Function | Description |
|----------|-------------|
| `circle_fill$(c#)` | Get fill color |
| `circle_fill#(c#, color$)` | Set fill color |
| `circle_fillnone#(c#)` | Remove fill (transparent) |

### Stroke (Border)

| Function | Description |
|----------|-------------|
| `circle_stroke$(c#)` | Get stroke color |
| `circle_stroke#(c#, color$)` | Set stroke color |
| `circle_strokenone#(c#)` | Remove stroke |
| `circle_strokethickness(c#)` | Get stroke thickness |
| `circle_strokethickness#(c#, value)` | Set stroke thickness |
| `circle_strokedash(c#)` | Get dash style |
| `circle_strokedash#(c#, value)` | Set dash style (0-4) |
| `circle_strokecap(c#)` | Get cap style |
| `circle_strokecap#(c#, value)` | Set cap style (0-1) |
| `circle_strokejoin(c#)` | Get join style |
| `circle_strokejoin#(c#, value)` | Set join style (0-2) |

### Position and Size

| Function | Description |
|----------|-------------|
| `circle_x(c#)` / `circle_x#(c#, x)` | Get/set X position |
| `circle_y(c#)` / `circle_y#(c#, y)` | Get/set Y position |
| `circle_width(c#)` / `circle_width#(c#, w)` | Get/set width |
| `circle_height(c#)` / `circle_height#(c#, h)` | Get/set height |
| `circle_bounds#(c#, x, y, w, h)` | Set position and size |
| `circle_size#(c#, w, h)` | Set size only |
| `circle_move#(c#, x, y)` | Set position only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `circle_align(c#)` / `circle_align#(c#, value)` | Get/set alignment |
| `circle_marginleft(c#)` / `circle_marginleft#(c#, value)` | Get/set left margin |
| `circle_margintop(c#)` / `circle_margintop#(c#, value)` | Get/set top margin |
| `circle_marginright(c#)` / `circle_marginright#(c#, value)` | Get/set right margin |
| `circle_marginbottom(c#)` / `circle_marginbottom#(c#, value)` | Get/set bottom margin |
| `circle_margins#(c#, l, t, r, b)` | Set all margins |
| `circle_margin#(c#, value)` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `circle_visible(c#)` / `circle_visible#(c#, value)` | Get/set visibility (0/1) |
| `circle_enabled(c#)` / `circle_enabled#(c#, value)` | Get/set enabled state (0/1) |
| `circle_opacity(c#)` / `circle_opacity#(c#, value)` | Get/set opacity (0.0-1.0) |
| `circle_hittest(c#)` / `circle_hittest#(c#, value)` | Get/set hit test (0/1) |

### Tag, Rotation, and Parent

| Function | Description |
|----------|-------------|
| `circle_tag(c#)` / `circle_tag#(c#, value)` | Get/set tag value |
| `circle_rotation(c#)` / `circle_rotation#(c#, value)` | Get/set rotation (degrees) |
| `circle_parent#(c#)` | Get parent |
| `circle_parent#(c#, parent#)` | Set parent |
| `circle_bringtofront#(c#)` | Bring to front |
| `circle_sendtoback#(c#)` | Send to back |

### Rendering

| Function | Description |
|----------|-------------|
| `circle_invalidate#(c#)` | Force redraw |
| `circle_clearcallbacks#(c#)` | Disconnects all event callbacks |

---

## Event Callbacks

### Mouse Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `circle_onclick#(c#, func$)` | `circle_onclick$(c#)` | `function(sender#)` |
| OnDblClick | `circle_ondblclick#(c#, func$)` | `circle_ondblclick$(c#)` | `function(sender#)` |
| OnMouseDown | `circle_onmousedown#(c#, func$)` | `circle_onmousedown$(c#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `circle_onmouseup#(c#, func$)` | `circle_onmouseup$(c#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `circle_onmousemove#(c#, func$)` | `circle_onmousemove$(c#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `circle_onmouseenter#(c#, func$)` | `circle_onmouseenter$(c#)` | `function(sender#)` |
| OnMouseLeave | `circle_onmouseleave#(c#, func$)` | `circle_onmouseleave$(c#)` | `function(sender#)` |
| OnMouseWheel | `circle_onmousewheel#(c#, func$)` | `circle_onmousewheel$(c#)` | `function(sender#, delta)` |
| OnResize | `circle_onresize#(c#, func$)` | `circle_onresize$(c#)` | `function(sender#)` |

Use `circle_clearcallbacks#(c#)` to disconnect all events.

---

## Complete Examples

### Status Indicators

```basic
let frm# = form#("Status", 300, 150)
form_position#(frm#, 4)

' Online indicator (green)
let indOnline# = circle#(frm#, 30, 30, 20, 20)
circle_fill#(indOnline#, "#27ae60")
circle_strokenone#(indOnline#)

let lblOnline# = label#(frm#, "Online")
label_move#(lblOnline#, 60, 33)

' Away indicator (yellow)
let indAway# = circle#(frm#, 30, 60, 20, 20)
circle_fill#(indAway#, "#f1c40f")
circle_strokenone#(indAway#)

let lblAway# = label#(frm#, "Away")
label_move#(lblAway#, 60, 63)

' Offline indicator (gray)
let indOffline# = circle#(frm#, 30, 90, 20, 20)
circle_fill#(indOffline#, "#95a5a6")
circle_strokenone#(indOffline#)

let lblOffline# = label#(frm#, "Offline")
label_move#(lblOffline#, 60, 93)

form_show(frm#)
```

### Traffic Light

```basic
let frm# = form#("Traffic Light", 150, 350)
form_position#(frm#, 4)

' Background
let bg# = roundrect#(frm#, 35, 20, 80, 220)
roundrect_fill#(bg#, "#2c3e50")
roundrect_corners#(bg#, 10)

' Red light
let red# = circle#(frm#, 45, 30, 60, 60)
circle_fill#(red#, "#c0392b")
circle_stroke#(red#, "#922b21")
circle_strokethickness#(red#, 2)
circle_tag#(red#, 1)

' Yellow light
let yellow# = circle#(frm#, 45, 100, 60, 60)
circle_fill#(yellow#, "#7f8c8d")
circle_stroke#(yellow#, "#5d6d7e")
circle_strokethickness#(yellow#, 2)
circle_tag#(yellow#, 2)

' Green light
let green# = circle#(frm#, 45, 170, 60, 60)
circle_fill#(green#, "#7f8c8d")
circle_stroke#(green#, "#5d6d7e")
circle_strokethickness#(green#, 2)
circle_tag#(green#, 3)

let btnNext# = button#(frm#, "Next", 35, 270, 80, 30)
button_onclick#(btnNext#, "OnNext")

let state = 1

form_show(frm#)

function OnNext(sender#)
  ' Reset all to gray
  circle_fill#(red#, "#7f8c8d")
  circle_fill#(yellow#, "#7f8c8d")
  circle_fill#(green#, "#7f8c8d")
  
  state = state + 1
  if state > 3 then state = 1
  
  ' Activate current light
  if state = 1 then
    circle_fill#(red#, "#c0392b")
  else if state = 2 then
    circle_fill#(yellow#, "#f1c40f")
  else if state = 3 then
    circle_fill#(green#, "#27ae60")
  endif
endfunction
```

### Clickable Buttons

```basic
let frm# = form#("Circle Buttons", 350, 150)
form_position#(frm#, 4)

colors# = sdim#(4)
let colors#$[1] = "#e74c3c"
let colors#$[2] = "#3498db"
let colors#$[3] = "#2ecc71"
let colors#$[4] = "#9b59b6"

let i = 1
for i = 1 to 4
  let c# = circle#(frm#, 30 + i * 80, 30, 60, 60)
  circle_fill#(c#, colors#$[i])
  circle_strokenone#(c#)
  circle_tag#(c#, i)
  circle_onclick#(c#, "OnCircleClick")
  circle_onmouseenter#(c#, "OnEnter")
  circle_onmouseleave#(c#, "OnLeave")
next

let lblSelected# = label#(frm#, "Click a circle")
label_move#(lblSelected#, 20, 110)

form_show(frm#)

function OnCircleClick(sender#)
  label_text#(lblSelected#, "Clicked: " + colors#$[circle_tag(sender#)])
endfunction

function OnEnter(sender#)
  circle_opacity#(sender#, 0.7)
endfunction

function OnLeave(sender#)
  circle_opacity#(sender#, 1.0)
endfunction
```

### Animated Loading Dots

```basic
let frm# = form#("Loading", 250, 100)
form_position#(frm#, 4)

let dot1# = circle#(frm#, 70, 35, 25, 25)
circle_fill#(dot1#, "#3498db")
circle_strokenone#(dot1#)

let dot2# = circle#(frm#, 110, 35, 25, 25)
circle_fill#(dot2#, "#3498db")
circle_strokenone#(dot2#)
circle_opacity#(dot2#, 0.5)

let dot3# = circle#(frm#, 150, 35, 25, 25)
circle_fill#(dot3#, "#3498db")
circle_strokenone#(dot3#)
circle_opacity#(dot3#, 0.25)

let _step = 0

let tmr# = timer#()
timer_interval#(tmr#, 300)
timer_ontimer#(tmr#, "OnAnimate")
timer_start#(tmr#)

form_show(frm#)

function OnAnimate(sender#)
  _step = _step + 1
  if _step > 2 then _step = 0
  
  ' Reset all to low opacity
  circle_opacity#(dot1#, 0.25)
  circle_opacity#(dot2#, 0.25)
  circle_opacity#(dot3#, 0.25)
  
  ' Highlight current dot
  if _step = 0 then
    circle_opacity#(dot1#, 1.0)
  else if _step = 1 then
    circle_opacity#(dot2#, 1.0)
  else if _step = 2 then
    circle_opacity#(dot3#, 1.0)
  endif
endfunction
```

---

## Tips and Best Practices

1. **Equal width/height for true circles** - Use `circle#(parent#, x, y, 100, 100)` for a perfect circle
2. **Use fillnone for rings** - `circle_fillnone#(c#)` with stroke creates hollow circles
3. **Opacity for highlighting** - Change opacity on hover for interactive feedback
4. **Great for indicators** - Status dots, notification badges, data points
5. **Combine with labels** - Overlay text on circles for badges with counts

---

## See Also

- **EllipseLib** - Ellipse shapes (non-uniform width/height)
- **RectangleLib** - Rectangle shapes
- **ArcLib** - Arc/partial circle shapes
- **PieLib** - Pie/wedge shapes

---

*CircleLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
