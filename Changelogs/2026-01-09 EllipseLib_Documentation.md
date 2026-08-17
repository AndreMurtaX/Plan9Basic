# EllipseLib - Ellipse Visual Control Library for Plan9Basic

## Overview

**EllipseLib** provides complete FireMonkey TEllipse wrapper functionality for creating and managing ellipse visual controls in Plan9Basic programs. TEllipse is a visual shape control with fill and stroke properties.

**Version:** 1.0.0  
**Function Count:** 72 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

All ellipses are created at RUNTIME using TEllipse.Create with dynamic parent assignment. This ensures proper dynamic creation across all platforms.

## Features

- Ellipse creation and lifecycle management
- Fill color and style (solid, gradient support via color)
- Stroke (border) color, thickness, and style
- Complete positioning and alignment
- Full event support with BASIC callback integration

## TEllipse vs TCircle

TEllipse and TCircle are similar but separate controls in FireMonkey. Both support elliptical shapes (when width != height). Use EllipseLib when you specifically need the TEllipse control type for compatibility or semantic clarity.

## Color Format

Colors are specified as strings in the following formats:

| Format | Example | Description |
|--------|---------|-------------|
| Named colors | `"red"`, `"blue"`, `"green"` | Predefined colors |
| Hex RGB | `"#RRGGBB"` | e.g., `"#FF5500"` |
| Hex ARGB | `"#AARRGGBB"` | e.g., `"#80FF5500"` (semi-transparent) |

### Available Named Colors

`black`, `white`, `red`, `green`, `blue`, `yellow`, `cyan`, `magenta`, `gray`/`grey`, `silver`, `maroon`, `olive`, `navy`, `purple`, `teal`, `orange`, `pink`, `brown`, `lime`, `aqua`, `fuchsia`, `transparent`, `null`, `darkred`, `darkgreen`, `darkblue`, `gold`, `coral`, `crimson`, `indigo`, `ivory`, `chocolate`, `tomato`, `skyblue`

## Stroke Styles

### Dash Styles

| Value | Constant | Description |
|-------|----------|-------------|
| 0 | DASH_SOLID | Solid (default) |
| 1 | DASH_DASH | Dashed |
| 2 | DASH_DOT | Dotted |
| 3 | DASH_DASHDOT | Dash-dot |
| 4 | DASH_DASHDOTDOT | Dash-dot-dot |

### Cap Styles

| Value | Constant | Description |
|-------|----------|-------------|
| 0 | CAP_FLAT | Flat (default) |
| 1 | CAP_ROUND | Round |

### Join Styles

| Value | Constant | Description |
|-------|----------|-------------|
| 0 | JOIN_MITER | Miter (default) |
| 1 | JOIN_ROUND | Round |
| 2 | JOIN_BEVEL | Bevel |

## Alignment Values

| Value | Constant | Description |
|-------|----------|-------------|
| 0 | None | No alignment (manual positioning) |
| 1 | Top | Align to top |
| 2 | Left | Align to left |
| 3 | Right | Align to right |
| 4 | Bottom | Align to bottom |
| 5 | MostTop | Align to absolute top |
| 6 | MostBottom | Align to absolute bottom |
| 7 | MostLeft | Align to absolute left |
| 8 | MostRight | Align to absolute right |
| 9 | Client | Fill client area |
| 10 | Contents | Fit to contents |
| 11 | Center | Center in parent |
| 12 | VertCenter | Center vertically |
| 13 | HorzCenter | Center horizontally |
| 14 | Horizontal | Stretch horizontally |
| 15 | Vertical | Stretch vertically |
| 16 | Scale | Scale proportionally |
| 17 | Fit | Fit within parent |
| 18 | FitLeft | Fit and align left |
| 19 | FitRight | Fit and align right |

---

## Function Reference

### Error Handling

| Function | Signature | Description |
|----------|-----------|-------------|
| `ellipse_error()` | `@` → number | Get last error code |
| `ellipse_errormsg$()` | `@` → string | Get last error message |
| `ellipse_strerror$(code)` | `@n` → string | Get error description for code |
| `ellipse_clearerror()` | `@` → number | Clear error state |

**Error Codes:**
| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Invalid ellipse |
| 2 | Invalid parent |
| 3 | Invalid value |
| 4 | Creation failed |
| 5 | Invalid callback |
| 6 | Invalid color |

---

### Creation and Destruction

| Function | Signature | Description |
|----------|-----------|-------------|
| `ellipse#(parent#)` | `@#` → pointer | Create with parent only |
| `ellipse#(parent#, w, h)` | `@#nn` → pointer | Create with size |
| `ellipse#(parent#, x, y, w, h)` | `@#nnnn` → pointer | Create with position and size |
| `ellipse_free(ell#)` | `@#` → number | Explicitly free ellipse |

**Example:**
```basic
let frm# = form#("Demo", 800, 600)
let ell# = ellipse#(frm#, 50, 50, 150, 100)
```

---

### Fill Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `ellipse_fill$(ell#)` | `@#` → string | Get fill color |
| `ellipse_fill#(ell#, color$)` | `@#$` → pointer | Set fill color |
| `ellipse_fillnone#(ell#)` | `@#` → pointer | Remove fill (transparent) |

---

### Stroke Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `ellipse_stroke$(ell#)` | `@#` → string | Get stroke color |
| `ellipse_stroke#(ell#, color$)` | `@#$` → pointer | Set stroke color |
| `ellipse_strokenone#(ell#)` | `@#` → pointer | Remove stroke |
| `ellipse_strokethickness(ell#)` | `@#` → number | Get stroke thickness |
| `ellipse_strokethickness#(ell#, value)` | `@#n` → pointer | Set stroke thickness |
| `ellipse_strokedash(ell#)` | `@#` → number | Get dash style |
| `ellipse_strokedash#(ell#, style)` | `@#n` → pointer | Set dash style |
| `ellipse_strokecap(ell#)` | `@#` → number | Get cap style |
| `ellipse_strokecap#(ell#, style)` | `@#n` → pointer | Set cap style |
| `ellipse_strokejoin(ell#)` | `@#` → number | Get join style |
| `ellipse_strokejoin#(ell#, style)` | `@#n` → pointer | Set join style |

---

### Position and Size

| Function | Signature | Description |
|----------|-----------|-------------|
| `ellipse_x(ell#)` | `@#` → number | Get X position |
| `ellipse_x#(ell#, value)` | `@#n` → pointer | Set X position |
| `ellipse_y(ell#)` | `@#` → number | Get Y position |
| `ellipse_y#(ell#, value)` | `@#n` → pointer | Set Y position |
| `ellipse_width(ell#)` | `@#` → number | Get width |
| `ellipse_width#(ell#, value)` | `@#n` → pointer | Set width |
| `ellipse_height(ell#)` | `@#` → number | Get height |
| `ellipse_height#(ell#, value)` | `@#n` → pointer | Set height |
| `ellipse_bounds#(ell#, x, y, w, h)` | `@#nnnn` → pointer | Set position and size |
| `ellipse_size#(ell#, w, h)` | `@#nn` → pointer | Set size only |
| `ellipse_move#(ell#, x, y)` | `@#nn` → pointer | Set position only |

---

### Alignment

| Function | Signature | Description |
|----------|-----------|-------------|
| `ellipse_align(ell#)` | `@#` → number | Get alignment |
| `ellipse_align#(ell#, value)` | `@#n` → pointer | Set alignment |

---

### Margins

| Function | Signature | Description |
|----------|-----------|-------------|
| `ellipse_marginleft(ell#)` | `@#` → number | Get left margin |
| `ellipse_marginleft#(ell#, value)` | `@#n` → pointer | Set left margin |
| `ellipse_margintop(ell#)` | `@#` → number | Get top margin |
| `ellipse_margintop#(ell#, value)` | `@#n` → pointer | Set top margin |
| `ellipse_marginright(ell#)` | `@#` → number | Get right margin |
| `ellipse_marginright#(ell#, value)` | `@#n` → pointer | Set right margin |
| `ellipse_marginbottom(ell#)` | `@#` → number | Get bottom margin |
| `ellipse_marginbottom#(ell#, value)` | `@#n` → pointer | Set bottom margin |
| `ellipse_margins#(ell#, l, t, r, b)` | `@#nnnn` → pointer | Set all margins |
| `ellipse_margin#(ell#, value)` | `@#n` → pointer | Set uniform margin |

---

### Visibility and Behavior

| Function | Signature | Description |
|----------|-----------|-------------|
| `ellipse_visible(ell#)` | `@#` → number | Get visibility (1=visible, 0=hidden) |
| `ellipse_visible#(ell#, value)` | `@#n` → pointer | Set visibility |
| `ellipse_enabled(ell#)` | `@#` → number | Get enabled state |
| `ellipse_enabled#(ell#, value)` | `@#n` → pointer | Set enabled state |
| `ellipse_opacity(ell#)` | `@#` → number | Get opacity (0.0-1.0) |
| `ellipse_opacity#(ell#, value)` | `@#n` → pointer | Set opacity |
| `ellipse_hittest(ell#)` | `@#` → number | Get hit test state |
| `ellipse_hittest#(ell#, value)` | `@#n` → pointer | Set hit test state |

---

### Tag and Rotation

| Function | Signature | Description |
|----------|-----------|-------------|
| `ellipse_tag(ell#)` | `@#` → number | Get tag value |
| `ellipse_tag#(ell#, value)` | `@#n` → pointer | Set tag value |
| `ellipse_rotation(ell#)` | `@#` → number | Get rotation angle (degrees) |
| `ellipse_rotation#(ell#, value)` | `@#n` → pointer | Set rotation angle |

---

### Parent Control

| Function | Signature | Description |
|----------|-----------|-------------|
| `ellipse_parent#(ell#)` | `@#` → pointer | Get parent control |
| `ellipse_parent#(ell#, parent#)` | `@##` → pointer | Set parent control |
| `ellipse_bringtofront#(ell#)` | `@#` → pointer | Bring to front |
| `ellipse_sendtoback#(ell#)` | `@#` → pointer | Send to back |
| `ellipse_invalidate#(ell#)` | `@#` → pointer | Force repaint |

---

### Event Callbacks

| Function | Signature | Description |
|----------|-----------|-------------|
| `ellipse_onclick#(ell#, func$)` | `@#$` → pointer | Set OnClick handler |
| `ellipse_onclick$(ell#)` | `@#` → string | Get OnClick handler |
| `ellipse_ondblclick#(ell#, func$)` | `@#$` → pointer | Set OnDblClick handler |
| `ellipse_ondblclick$(ell#)` | `@#` → string | Get OnDblClick handler |
| `ellipse_onmousedown#(ell#, func$)` | `@#$` → pointer | Set OnMouseDown handler |
| `ellipse_onmousedown$(ell#)` | `@#` → string | Get OnMouseDown handler |
| `ellipse_onmouseup#(ell#, func$)` | `@#$` → pointer | Set OnMouseUp handler |
| `ellipse_onmouseup$(ell#)` | `@#` → string | Get OnMouseUp handler |
| `ellipse_onmousemove#(ell#, func$)` | `@#$` → pointer | Set OnMouseMove handler |
| `ellipse_onmousemove$(ell#)` | `@#` → string | Get OnMouseMove handler |
| `ellipse_onmouseenter#(ell#, func$)` | `@#$` → pointer | Set OnMouseEnter handler |
| `ellipse_onmouseenter$(ell#)` | `@#` → string | Get OnMouseEnter handler |
| `ellipse_onmouseleave#(ell#, func$)` | `@#$` → pointer | Set OnMouseLeave handler |
| `ellipse_onmouseleave$(ell#)` | `@#` → string | Get OnMouseLeave handler |
| `ellipse_onmousewheel#(ell#, func$)` | `@#$` → pointer | Set OnMouseWheel handler |
| `ellipse_onmousewheel$(ell#)` | `@#` → string | Get OnMouseWheel handler |
| `ellipse_onresize#(ell#, func$)` | `@#$` → pointer | Set OnResize handler |
| `ellipse_onresize$(ell#)` | `@#` → string | Get OnResize handler |
| `ellipse_clearcallbacks#(ell#)` | `@#` → pointer | Clear all callbacks |

**Callback Signatures:**
```basic
function OnClick(sender#)
function OnDblClick(sender#)
function OnMouseDown(sender#, button, x, y, shift$)
function OnMouseUp(sender#, button, x, y, shift$)
function OnMouseMove(sender#, x, y, shift$)
function OnMouseEnter(sender#)
function OnMouseLeave(sender#)
function OnMouseWheel(sender#, delta, shift$)
function OnResize(sender#, width, height)
```

**Shift String Characters:**
| Character | Meaning |
|-----------|---------|
| S | Shift key |
| C | Ctrl key |
| A | Alt key |
| M | Command key (macOS) |
| L | Left mouse button |
| R | Right mouse button |
| X | Middle mouse button |

---

## Examples

### Example 1: Basic Ellipse

```basic
let frm# = form#("Ellipse Demo", 400, 300)

' Create a simple ellipse
let ell# = ellipse#(frm#, 50, 50, 200, 100)
ellipse_fill#(ell#, "#3498db")
ellipse_stroke#(ell#, "#2980b9")
ellipse_strokethickness#(ell#, 2)

form_show(frm#)
```

### Example 2: Interactive Ellipse with Events

```basic
let frm# = form#("Interactive Ellipse", 400, 300)

let ell# = ellipse#(frm#, 100, 75, 200, 150)
ellipse_fill#(ell#, "red")
ellipse_stroke#(ell#, "darkred")
ellipse_strokethickness#(ell#, 3)

' Set up events
ellipse_onclick#(ell#, "OnEllipseClick")
ellipse_onmouseenter#(ell#, "OnEllipseEnter")
ellipse_onmouseleave#(ell#, "OnEllipseLeave")

form_show(frm#)

function OnEllipseClick(sender#)
  println "Ellipse clicked!"
endfunction

function OnEllipseEnter(sender#)
  ellipse_fill#(sender#, "orange")
endfunction

function OnEllipseLeave(sender#)
  ellipse_fill#(sender#, "red")
endfunction
```

### Example 3: Perfect Circle (Width = Height)

```basic
let frm# = form#("Circle Demo", 400, 300)

' Create a perfect circle (width = height)
let circle# = ellipse#(frm#, 125, 75, 150, 150)
ellipse_fill#(circle#, "#9b59b6")
ellipse_stroke#(circle#, "#8e44ad")
ellipse_strokethickness#(circle#, 2)

form_show(frm#)
```

### Example 4: Multiple Ellipses with Rotation

```basic
let frm# = form#("Rotated Ellipses", 500, 400)

for i = 0 to 4
  let ell# = ellipse#(frm#, 100 + i * 70, 150, 60, 40)
  ellipse_fill#(ell#, "#e74c3c")
  ellipse_stroke#(ell#, "#c0392b")
  ellipse_strokethickness#(ell#, 2)
  ellipse_rotation#(ell#, i * 30)
next

form_show(frm#)
```

### Example 5: Semi-Transparent Overlapping Ellipses

```basic
let frm# = form#("Transparency Demo", 400, 300)

' Background ellipse
let ell1# = ellipse#(frm#, 50, 50, 180, 120)
ellipse_fill#(ell1#, "blue")

' Semi-transparent overlapping ellipse
let ell2# = ellipse#(frm#, 120, 80, 180, 120)
ellipse_fill#(ell2#, "#80FF0000")  ' Red with 50% opacity
ellipse_strokenone#(ell2#)

form_show(frm#)
```

### Example 6: Dashed Stroke Ellipse

```basic
let frm# = form#("Dashed Ellipse", 400, 300)

let ell# = ellipse#(frm#, 75, 75, 250, 150)
ellipse_fillnone#(ell#)
ellipse_stroke#(ell#, "black")
ellipse_strokethickness#(ell#, 2)
ellipse_strokedash#(ell#, 1)  ' Dashed

form_show(frm#)
```

---

## Important Notes

1. **HitTest**: By default, ellipses are created with `HitTest = True`, allowing mouse events. Use `ellipse_hittest#(ell#, 0)` to disable.

2. **Circle vs Ellipse**: To create a perfect circle, set width equal to height.

3. **Memory Management**: Ellipses are automatically managed by Plan9Basic's garbage collection system. Use `ellipse_free` only if you need to explicitly free memory.

4. **Chaining**: Functions that return `#` (pointer) allow method chaining.

5. **Events**: Always set up callbacks before showing the form to ensure all events are captured from the start.

6. **Rotation**: Rotation is specified in degrees. Positive values rotate clockwise.

---

## See Also

- CircleLib - Circle control (similar to TEllipse)
- RectangleLib - Rectangle control
- RoundRectLib - Rounded rectangle control
- PanelLib - Panel container control
- FormLib - Form control
