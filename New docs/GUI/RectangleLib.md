# RectangleLib - Rectangle Shape Library for Plan9Basic

## Overview

RectangleLib provides functionality for creating and managing rectangle shapes in Plan9Basic programs. Rectangles can be used for drawing, backgrounds, borders, color displays, and visual containers.

**Version:** 1.0.0
**Function Count:** 90 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("Rectangle Demo", 400, 300)
form_position#(frm#, 4)

' Simple colored rectangle
let rect# = rectangle#(frm#, 50, 50, 150, 100)
rectangle_fill#(rect#, "#3498db")
rectangle_stroke#(rect#, "#2980b9")
rectangle_strokethickness#(rect#, 2)

' Rounded rectangle
let rounded# = rectangle#(frm#, 220, 50, 150, 100)
rectangle_fill#(rounded#, "#e74c3c")
rectangle_corners#(rounded#, 15, 15)

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

### Sides Flags (bitmask)

| Value | Description |
|-------|-------------|
| 1 | Top |
| 2 | Left |
| 4 | Bottom |
| 8 | Right |
| 15 | All sides |

### Corners Flags (bitmask)

| Value | Description |
|-------|-------------|
| 1 | Top-Left |
| 2 | Top-Right |
| 4 | Bottom-Left |
| 8 | Bottom-Right |
| 15 | All corners |

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `rectangle_error()` | Returns last error code (0 = no error) |
| `rectangle_errormsg$()` | Returns last error message |
| `rectangle_strerror$(code)` | Converts error code to message |
| `rectangle_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `rectangle#(parent#)` | Create with default size |
| `rectangle#(parent#, w, h)` | Create with size |
| `rectangle#(parent#, x, y, w, h)` | Create with position and size |
| `rectangle_free(rect#)` | Destroy rectangle |

### Fill (Background)

| Function | Description |
|----------|-------------|
| `rectangle_fill$(rect#)` | Get fill color |
| `rectangle_fill#(rect#, color$)` | Set fill color (e.g., "#FF0000", "red") |
| `rectangle_fillnone#(rect#)` | Remove fill (transparent) |

### Stroke (Border)

| Function | Description |
|----------|-------------|
| `rectangle_stroke$(rect#)` | Get stroke color |
| `rectangle_stroke#(rect#, color$)` | Set stroke color |
| `rectangle_strokenone#(rect#)` | Remove stroke |
| `rectangle_strokethickness(rect#)` | Get stroke thickness |
| `rectangle_strokethickness#(rect#, value)` | Set stroke thickness |
| `rectangle_strokedash(rect#)` | Get dash style |
| `rectangle_strokedash#(rect#, value)` | Set dash style (0-4) |
| `rectangle_strokecap(rect#)` | Get cap style |
| `rectangle_strokecap#(rect#, value)` | Set cap style (0-1) |
| `rectangle_strokejoin(rect#)` | Get join style |
| `rectangle_strokejoin#(rect#, value)` | Set join style (0-2) |

### Corner Radius

| Function | Description |
|----------|-------------|
| `rectangle_xradius(rect#)` | Get X corner radius |
| `rectangle_xradius#(rect#, value)` | Set X corner radius |
| `rectangle_yradius(rect#)` | Get Y corner radius |
| `rectangle_yradius#(rect#, value)` | Set Y corner radius |
| `rectangle_corners#(rect#, xRadius, yRadius)` | Set both corner radii |

### Sides and Corners Selection

| Function | Description |
|----------|-------------|
| `rectangle_sides(rect#)` | Get sides flags |
| `rectangle_sides#(rect#, flags)` | Set which sides to draw (bitmask) |
| `rectangle_cornersflags(rect#)` | Get corners flags |
| `rectangle_cornersflags#(rect#, flags)` | Set which corners are rounded (bitmask) |

### Position and Size

| Function | Description |
|----------|-------------|
| `rectangle_x(rect#)` / `rectangle_x#(rect#, x)` | Get/set X position |
| `rectangle_y(rect#)` / `rectangle_y#(rect#, y)` | Get/set Y position |
| `rectangle_width(rect#)` / `rectangle_width#(rect#, w)` | Get/set width |
| `rectangle_height(rect#)` / `rectangle_height#(rect#, h)` | Get/set height |
| `rectangle_bounds#(rect#, x, y, w, h)` | Set position and size |
| `rectangle_size#(rect#, w, h)` | Set size only |
| `rectangle_move#(rect#, x, y)` | Set position only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `rectangle_align(rect#)` / `rectangle_align#(rect#, value)` | Get/set alignment |
| `rectangle_marginleft(rect#)` / `rectangle_marginleft#(rect#, value)` | Get/set left margin |
| `rectangle_margintop(rect#)` / `rectangle_margintop#(rect#, value)` | Get/set top margin |
| `rectangle_marginright(rect#)` / `rectangle_marginright#(rect#, value)` | Get/set right margin |
| `rectangle_marginbottom(rect#)` / `rectangle_marginbottom#(rect#, value)` | Get/set bottom margin |
| `rectangle_margins#(rect#, l, t, r, b)` | Set all margins |
| `rectangle_margin#(rect#, value)` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `rectangle_visible(rect#)` / `rectangle_visible#(rect#, value)` | Get/set visibility (0/1) |
| `rectangle_enabled(rect#)` / `rectangle_enabled#(rect#, value)` | Get/set enabled state (0/1) |
| `rectangle_opacity(rect#)` / `rectangle_opacity#(rect#, value)` | Get/set opacity (0.0-1.0) |
| `rectangle_hittest(rect#)` / `rectangle_hittest#(rect#, value)` | Get/set hit test (0/1) |

### Tag, Rotation, and Parent

| Function | Description |
|----------|-------------|
| `rectangle_tag(rect#)` / `rectangle_tag#(rect#, value)` | Get/set tag value |
| `rectangle_rotation(rect#)` / `rectangle_rotation#(rect#, value)` | Get/set rotation (degrees) |
| `rectangle_parent#(rect#)` | Get parent |
| `rectangle_parent#(rect#, parent#)` | Set parent |
| `rectangle_bringtofront#(rect#)` | Bring to front |
| `rectangle_sendtoback#(rect#)` | Send to back |

### Rendering

| Function | Description |
|----------|-------------|
| `rectangle_invalidate#(rect#)` | Force redraw |
| `rectangle_clearcallbacks#(rect#)` | Disconnects all event callbacks |

---

## Event Callbacks

### Mouse Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `rectangle_onclick#(rect#, func$)` | `rectangle_onclick$(rect#)` | `function(sender#)` |
| OnDblClick | `rectangle_ondblclick#(rect#, func$)` | `rectangle_ondblclick$(rect#)` | `function(sender#)` |
| OnMouseDown | `rectangle_onmousedown#(rect#, func$)` | `rectangle_onmousedown$(rect#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `rectangle_onmouseup#(rect#, func$)` | `rectangle_onmouseup$(rect#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `rectangle_onmousemove#(rect#, func$)` | `rectangle_onmousemove$(rect#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `rectangle_onmouseenter#(rect#, func$)` | `rectangle_onmouseenter$(rect#)` | `function(sender#)` |
| OnMouseLeave | `rectangle_onmouseleave#(rect#, func$)` | `rectangle_onmouseleave$(rect#)` | `function(sender#)` |
| OnMouseWheel | `rectangle_onmousewheel#(rect#, func$)` | `rectangle_onmousewheel$(rect#)` | `function(sender#, delta)` |
| OnResize | `rectangle_onresize#(rect#, func$)` | `rectangle_onresize$(rect#)` | `function(sender#)` |

Use `rectangle_clearcallbacks#(rect#)` to disconnect all events.

---

## Complete Examples

### Color Palette

```basic
let frm# = form#("Color Palette", 400, 300)
form_position#(frm#, 4)

colors# = sdim#(6)
let colors#$[1] = "#e74c3c"
let colors#$[2] = "#3498db"
let colors#$[3] = "#2ecc71"
let colors#$[4] = "#f1c40f"
let colors#$[5] = "#9b59b6"
let colors#$[6] = "#1abc9c"

let x = 20
let y = 20
let i = 0

for i = 1 to 6
  let rect# = rectangle#(frm#, x, y, 80, 80)
  rectangle_fill#(rect#, colors#$[i])
  rectangle_stroke#(rect#, "#333333")
  rectangle_strokethickness#(rect#, 2)
  rectangle_corners#(rect#, 8, 8)
  rectangle_tag#(rect#, i)
  rectangle_onclick#(rect#, "OnColorClick")
  
  x = x + 100
  if x > 300 then
    x = 20
    y = y + 100
  endif
next

let lblSelected# = label#(frm#, "Click a color")
label_move#(lblSelected#, 20, 230)

form_show(frm#)

function OnColorClick(sender#) local idx
  idx = rectangle_tag(sender#)
  label_text#(lblSelected#, "Selected: " + colors#$[idx])
endfunction
```

### Progress Indicator

```basic
let frm# = form#("Loading", 300, 150)
form_position#(frm#, 4)

' Background bar
let bgRect# = rectangle#(frm#, 30, 50, 240, 30)
rectangle_fill#(bgRect#, "#ecf0f1")
rectangle_corners#(bgRect#, 5, 5)

' Progress bar (foreground)
let fgRect# = rectangle#(frm#, 30, 50, 0, 30)
rectangle_fill#(fgRect#, "#3498db")
rectangle_corners#(fgRect#, 5, 5)

let lblPct# = label#(frm#, "0%")
label_bounds#(lblPct#, 130, 90, 40, 20)
label_textalign#(lblPct#, 0)

let tmr# = timer#()
timer_interval#(tmr#, 50)
timer_ontimer#(tmr#, "OnTick")
timer_start#(tmr#)

form_show(frm#)

function OnTick(sender#) local w, pct
  w = rectangle_width(fgRect#) + 2
  if w > 240 then
    timer_stop#(tmr#)
    label_text#(lblPct#, "Done!")
  else
    rectangle_width#(fgRect#, w)
    pct = int(w / 240 * 100)
    label_text#(lblPct#, str$(pct) + "%")
  endif
endfunction
```

### Interactive Hover Effect

```basic
let frm# = form#("Hover Demo", 350, 200)
form_position#(frm#, 4)

let rect# = rectangle#(frm#, 100, 50, 150, 100)
rectangle_fill#(rect#, "#3498db")
rectangle_stroke#(rect#, "#2980b9")
rectangle_strokethickness#(rect#, 2)
rectangle_corners#(rect#, 10, 10)

rectangle_onmouseenter#(rect#, "OnEnter")
rectangle_onmouseleave#(rect#, "OnLeave")

let lbl# = label#(frm#, "Hover over the rectangle")
label_move#(lbl#, 80, 170)

form_show(frm#)

function OnEnter(sender#)
  rectangle_fill#(sender#, "#2980b9")
  rectangle_strokethickness#(sender#, 4)
endfunction

function OnLeave(sender#)
  rectangle_fill#(sender#, "#3498db")
  rectangle_strokethickness#(sender#, 2)
endfunction
```

### Checkerboard Pattern

```basic
let frm# = form#("Checkerboard", 340, 340)
form_position#(frm#, 4)

let row = 0
let col = 0
let size = 40

for row = 0 to 7
  for col = 0 to 7
    let rect# = rectangle#(frm#, col * size + 10, row * size + 10, size, size)
    rectangle_strokenone#(rect#)
    
    let isWhite = (row + col) mod 2
    if isWhite = 0 then
      rectangle_fill#(rect#, "#8B4513")
    else
      rectangle_fill#(rect#, "#DEB887")
    endif
  next
next

form_show(frm#)
```

### Border Styles Demo

```basic
let frm# = form#("Border Styles", 450, 200)
form_position#(frm#, 4)

' Solid
let r1# = rectangle#(frm#, 20, 50, 80, 60)
rectangle_fill#(r1#, "#ffffff")
rectangle_stroke#(r1#, "#333333")
rectangle_strokethickness#(r1#, 2)
rectangle_strokedash#(r1#, 0)

let lbl1# = label#(frm#, "Solid")
label_move#(lbl1#, 40, 120)

' Dash
let r2# = rectangle#(frm#, 120, 50, 80, 60)
rectangle_fill#(r2#, "#ffffff")
rectangle_stroke#(r2#, "#333333")
rectangle_strokethickness#(r2#, 2)
rectangle_strokedash#(r2#, 1)

let lbl2# = label#(frm#, "Dash")
label_move#(lbl2#, 142, 120)

' Dot
let r3# = rectangle#(frm#, 220, 50, 80, 60)
rectangle_fill#(r3#, "#ffffff")
rectangle_stroke#(r3#, "#333333")
rectangle_strokethickness#(r3#, 2)
rectangle_strokedash#(r3#, 2)

let lbl3# = label#(frm#, "Dot")
label_move#(lbl3#, 248, 120)

' DashDot
let r4# = rectangle#(frm#, 320, 50, 80, 60)
rectangle_fill#(r4#, "#ffffff")
rectangle_stroke#(r4#, "#333333")
rectangle_strokethickness#(r4#, 2)
rectangle_strokedash#(r4#, 3)

let lbl4# = label#(frm#, "DashDot")
label_move#(lbl4#, 330, 120)

form_show(frm#)
```

---

## Tips and Best Practices

1. **Use for color displays** - Rectangles are ideal for showing selected colors (like in TrackBarLib RGB mixer example)
2. **Set hittest for interactivity** - Enable `rectangle_hittest#(rect#, 1)` to receive mouse events
3. **Combine fill and stroke** - Use both for bordered shapes, or `fillnone`/`strokenone` for one or the other
4. **Corner radius for rounded look** - Use `rectangle_corners#(rect#, r, r)` for uniform rounded corners
5. **Rotation transforms** - Use `rectangle_rotation#` for rotated rectangles
6. **Opacity for overlays** - Set opacity < 1.0 for transparent overlays

---

## See Also

- **RoundRectLib** - Rectangles with advanced corner control
- **CircleLib** - Circle shapes
- **EllipseLib** - Ellipse shapes
- **LineLib** - Line shapes

---

*RectangleLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
