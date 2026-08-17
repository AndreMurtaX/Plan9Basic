# RoundRectLib - Rounded Rectangle Shape Library for Plan9Basic

## Overview

RoundRectLib provides functionality for creating and managing rounded rectangle shapes in Plan9Basic programs. RoundRect offers a simpler corner control compared to Rectangle, with a single corner radius for all corners.

**Version:** 1.0.0
**Function Count:** 83 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("RoundRect Demo", 400, 300)
form_position#(frm#, 4)

' Simple rounded rectangle
let rr# = roundrect#(frm#, 50, 50, 150, 100)
roundrect_fill#(rr#, "#9b59b6")
roundrect_stroke#(rr#, "#8e44ad")
roundrect_strokethickness#(rr#, 2)
roundrect_corners#(rr#, 15)

' Pill shape (high corner radius)
let pill# = roundrect#(frm#, 220, 70, 150, 50)
roundrect_fill#(pill#, "#1abc9c")
roundrect_corners#(pill#, 25)

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
| `roundrect_error()` | Returns last error code (0 = no error) |
| `roundrect_errormsg$()` | Returns last error message |
| `roundrect_strerror$(code)` | Converts error code to message |
| `roundrect_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `roundrect#(parent#)` | Create with default size |
| `roundrect#(parent#, w, h)` | Create with size |
| `roundrect#(parent#, x, y, w, h)` | Create with position and size |
| `roundrect_free(rr#)` | Destroy rounded rectangle |

### Corner Radius

| Function | Description |
|----------|-------------|
| `roundrect_corners(rr#)` | Get corner radius |
| `roundrect_corners#(rr#, radius)` | Set corner radius (all corners) |

### Fill (Background)

| Function | Description |
|----------|-------------|
| `roundrect_fill$(rr#)` | Get fill color |
| `roundrect_fill#(rr#, color$)` | Set fill color |
| `roundrect_fillnone#(rr#)` | Remove fill (transparent) |

### Stroke (Border)

| Function | Description |
|----------|-------------|
| `roundrect_stroke$(rr#)` | Get stroke color |
| `roundrect_stroke#(rr#, color$)` | Set stroke color |
| `roundrect_strokenone#(rr#)` | Remove stroke |
| `roundrect_strokethickness(rr#)` | Get stroke thickness |
| `roundrect_strokethickness#(rr#, value)` | Set stroke thickness |
| `roundrect_strokedash(rr#)` | Get dash style |
| `roundrect_strokedash#(rr#, value)` | Set dash style (0-4) |
| `roundrect_strokecap(rr#)` | Get cap style |
| `roundrect_strokecap#(rr#, value)` | Set cap style (0-1) |
| `roundrect_strokejoin(rr#)` | Get join style |
| `roundrect_strokejoin#(rr#, value)` | Set join style (0-2) |

### Position and Size

| Function | Description |
|----------|-------------|
| `roundrect_x(rr#)` / `roundrect_x#(rr#, x)` | Get/set X position |
| `roundrect_y(rr#)` / `roundrect_y#(rr#, y)` | Get/set Y position |
| `roundrect_width(rr#)` / `roundrect_width#(rr#, w)` | Get/set width |
| `roundrect_height(rr#)` / `roundrect_height#(rr#, h)` | Get/set height |
| `roundrect_bounds#(rr#, x, y, w, h)` | Set position and size |
| `roundrect_size#(rr#, w, h)` | Set size only |
| `roundrect_move#(rr#, x, y)` | Set position only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `roundrect_align(rr#)` / `roundrect_align#(rr#, value)` | Get/set alignment |
| `roundrect_marginleft(rr#)` / `roundrect_marginleft#(rr#, value)` | Get/set left margin |
| `roundrect_margintop(rr#)` / `roundrect_margintop#(rr#, value)` | Get/set top margin |
| `roundrect_marginright(rr#)` / `roundrect_marginright#(rr#, value)` | Get/set right margin |
| `roundrect_marginbottom(rr#)` / `roundrect_marginbottom#(rr#, value)` | Get/set bottom margin |
| `roundrect_margins#(rr#, l, t, r, b)` | Set all margins |
| `roundrect_margin#(rr#, value)` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `roundrect_visible(rr#)` / `roundrect_visible#(rr#, value)` | Get/set visibility (0/1) |
| `roundrect_enabled(rr#)` / `roundrect_enabled#(rr#, value)` | Get/set enabled state (0/1) |
| `roundrect_opacity(rr#)` / `roundrect_opacity#(rr#, value)` | Get/set opacity (0.0-1.0) |
| `roundrect_hittest(rr#)` / `roundrect_hittest#(rr#, value)` | Get/set hit test (0/1) |

### Tag, Rotation, and Parent

| Function | Description |
|----------|-------------|
| `roundrect_tag(rr#)` / `roundrect_tag#(rr#, value)` | Get/set tag value |
| `roundrect_rotation(rr#)` / `roundrect_rotation#(rr#, value)` | Get/set rotation (degrees) |
| `roundrect_parent#(rr#)` | Get parent |
| `roundrect_parent#(rr#, parent#)` | Set parent |
| `roundrect_bringtofront#(rr#)` | Bring to front |
| `roundrect_sendtoback#(rr#)` | Send to back |

### Rendering

| Function | Description |
|----------|-------------|
| `roundrect_invalidate#(rr#)` | Force redraw |
| `roundrect_clearcallbacks#(rr#)` | Disconnects all event callbacks |

---

## Event Callbacks

### Mouse Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `roundrect_onclick#(rr#, func$)` | `roundrect_onclick$(rr#)` | `function(sender#)` |
| OnDblClick | `roundrect_ondblclick#(rr#, func$)` | `roundrect_ondblclick$(rr#)` | `function(sender#)` |
| OnMouseDown | `roundrect_onmousedown#(rr#, func$)` | `roundrect_onmousedown$(rr#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `roundrect_onmouseup#(rr#, func$)` | `roundrect_onmouseup$(rr#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `roundrect_onmousemove#(rr#, func$)` | `roundrect_onmousemove$(rr#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `roundrect_onmouseenter#(rr#, func$)` | `roundrect_onmouseenter$(rr#)` | `function(sender#)` |
| OnMouseLeave | `roundrect_onmouseleave#(rr#, func$)` | `roundrect_onmouseleave$(rr#)` | `function(sender#)` |
| OnMouseWheel | `roundrect_onmousewheel#(rr#, func$)` | `roundrect_onmousewheel$(rr#)` | `function(sender#, delta)` |
| OnResize | `roundrect_onresize#(rr#, func$)` | `roundrect_onresize$(rr#)` | `function(sender#)` |

Use `roundrect_clearcallbacks#(rr#)` to disconnect all events.

---

## Complete Examples

### Button-Like Cards

```basic
let frm# = form#("Cards", 450, 200)
form_position#(frm#, 4)

' Card 1
let card1# = roundrect#(frm#, 20, 30, 120, 80)
roundrect_fill#(card1#, "#3498db")
roundrect_corners#(card1#, 10)
roundrect_strokenone#(card1#)
roundrect_tag#(card1#, 1)
roundrect_onclick#(card1#, "OnCardClick")
roundrect_onmouseenter#(card1#, "OnCardEnter")
roundrect_onmouseleave#(card1#, "OnCardLeave")

let lbl1# = label#(frm#, "Option A")
label_bounds#(lbl1#, 20, 60, 120, 20)
label_textalign#(lbl1#, 0)
label_fontcolor#(lbl1#, "#ffffff")

' Card 2
let card2# = roundrect#(frm#, 160, 30, 120, 80)
roundrect_fill#(card2#, "#2ecc71")
roundrect_corners#(card2#, 10)
roundrect_strokenone#(card2#)
roundrect_tag#(card2#, 2)
roundrect_onclick#(card2#, "OnCardClick")
roundrect_onmouseenter#(card2#, "OnCardEnter")
roundrect_onmouseleave#(card2#, "OnCardLeave")

let lbl2# = label#(frm#, "Option B")
label_bounds#(lbl2#, 160, 60, 120, 20)
label_textalign#(lbl2#, 0)
label_fontcolor#(lbl2#, "#ffffff")

' Card 3
let card3# = roundrect#(frm#, 300, 30, 120, 80)
roundrect_fill#(card3#, "#e74c3c")
roundrect_corners#(card3#, 10)
roundrect_strokenone#(card3#)
roundrect_tag#(card3#, 3)
roundrect_onclick#(card3#, "OnCardClick")
roundrect_onmouseenter#(card3#, "OnCardEnter")
roundrect_onmouseleave#(card3#, "OnCardLeave")

let lbl3# = label#(frm#, "Option C")
label_bounds#(lbl3#, 300, 60, 120, 20)
label_textalign#(lbl3#, 0)
label_fontcolor#(lbl3#, "#ffffff")

let lblStatus# = label#(frm#, "Click a card")
label_move#(lblStatus#, 20, 140)

form_show(frm#)

function OnCardClick(sender#)
  label_text#(lblStatus#, "Selected card: " + str$(roundrect_tag(sender#)))
endfunction

function OnCardEnter(sender#)
  roundrect_opacity#(sender#, 0.8)
endfunction

function OnCardLeave(sender#)
  roundrect_opacity#(sender#, 1.0)
endfunction
```

### Pill Badges

```basic
let frm# = form#("Badges", 400, 150)
form_position#(frm#, 4)

' Success badge
let badge1# = roundrect#(frm#, 20, 30, 80, 30)
roundrect_fill#(badge1#, "#27ae60")
roundrect_corners#(badge1#, 15)
roundrect_strokenone#(badge1#)

let txt1# = label#(frm#, "Success")
label_bounds#(txt1#, 20, 35, 80, 20)
label_textalign#(txt1#, 0)
label_fontcolor#(txt1#, "#ffffff")

' Warning badge
let badge2# = roundrect#(frm#, 120, 30, 80, 30)
roundrect_fill#(badge2#, "#f39c12")
roundrect_corners#(badge2#, 15)
roundrect_strokenone#(badge2#)

let txt2# = label#(frm#, "Warning")
label_bounds#(txt2#, 120, 35, 80, 20)
label_textalign#(txt2#, 0)
label_fontcolor#(txt2#, "#ffffff")

' Error badge
let badge3# = roundrect#(frm#, 220, 30, 80, 30)
roundrect_fill#(badge3#, "#c0392b")
roundrect_corners#(badge3#, 15)
roundrect_strokenone#(badge3#)

let txt3# = label#(frm#, "Error")
label_bounds#(txt3#, 220, 35, 80, 20)
label_textalign#(txt3#, 0)
label_fontcolor#(txt3#, "#ffffff")

' Info badge
let badge4# = roundrect#(frm#, 320, 30, 60, 30)
roundrect_fill#(badge4#, "#2980b9")
roundrect_corners#(badge4#, 15)
roundrect_strokenone#(badge4#)

let txt4# = label#(frm#, "Info")
label_bounds#(txt4#, 320, 35, 60, 20)
label_textalign#(txt4#, 0)
label_fontcolor#(txt4#, "#ffffff")

form_show(frm#)
```

### Toggle Switch Visual

```basic
let frm# = form#("Toggle", 200, 120)
form_position#(frm#, 4)

let isOn = 0

' Track (background)
let track# = roundrect#(frm#, 60, 40, 80, 40)
roundrect_corners#(track#, 20)
roundrect_fill#(track#, "#bdc3c7")
roundrect_strokenone#(track#)
roundrect_onclick#(track#, "OnToggle")

' Thumb (circle)
let thumb# = roundrect#(frm#, 62, 42, 36, 36)
roundrect_corners#(thumb#, 18)
roundrect_fill#(thumb#, "#ffffff")
roundrect_stroke#(thumb#, "#95a5a6")
roundrect_strokethickness#(thumb#, 1)

form_show(frm#)

function OnToggle(sender#)
  if isOn = 0 then
    isOn = 1
    roundrect_fill#(track#, "#27ae60")
    roundrect_x#(thumb#, 102)
  else
    isOn = 0
    roundrect_fill#(track#, "#bdc3c7")
    roundrect_x#(thumb#, 62)
  endif
endfunction
```

---

## Tips and Best Practices

1. **Use high corner radius for pills** - Set corner radius to half the height for pill shapes
2. **Simpler than Rectangle** - Use RoundRect when you need uniform corners on all sides
3. **Great for cards and badges** - Modern UI card designs with rounded corners
4. **Combine with labels** - Overlay labels on RoundRects for button-like elements
5. **Opacity for hover effects** - Change opacity on mouse enter/leave for interaction feedback

---

## RoundRect vs Rectangle

| Feature | RoundRect | Rectangle |
|---------|-----------|-----------|
| Corner radius | Single value (all corners) | X and Y radius separately |
| Corner selection | No (all corners same) | Yes (bitmask for individual corners) |
| Side selection | No | Yes (bitmask for individual sides) |
| Use case | Simple rounded shapes | Complex corner/side configurations |

---

## See Also

- **RectangleLib** - Rectangles with advanced corner control
- **CircleLib** - Circle shapes
- **EllipseLib** - Ellipse shapes

---

*RoundRectLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
