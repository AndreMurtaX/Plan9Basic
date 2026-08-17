# RoundRectLib - Rounded Rectangle Library for Plan9Basic

## Overview

RoundRectLib provides the creation and manipulation of rounded rectangle visual shapes in Plan9Basic applications. Rounded rectangles are commonly used for buttons, cards, panels, and decorative UI elements.

**Total Functions:** 78

## Key Features

- Create rounded rectangles with customizable corner radius
- Control which corners are rounded (selective rounding)
- Fill and stroke styling (colors, thickness, dash patterns)
- Complete positioning, sizing, and alignment
- Full event callback support for interactivity
- Garbage collector integration for automatic memory management

---

## Function Reference

### Error Handling

| Function | Signature | Description |
|----------|-----------|-------------|
| `roundrect_error()` | `@` → number | Get last error code |
| `roundrect_errormsg$()` | `@` → string | Get last error message |
| `roundrect_strerror$(code)` | `@n` → string | Get error description for code |
| `roundrect_clearerror()` | `@` → number | Clear error state |

**Error Codes:**
| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Invalid roundrect |
| 2 | Invalid parent |
| 3 | Invalid value |
| 4 | Creation failed |
| 5 | Invalid callback |
| 6 | Invalid color |

---

### Creation and Destruction

| Function | Signature | Description |
|----------|-----------|-------------|
| `roundrect#(parent#)` | `@#` → pointer | Create with parent only |
| `roundrect#(parent#, w, h)` | `@#nn` → pointer | Create with size |
| `roundrect#(parent#, x, y, w, h)` | `@#nnnn` → pointer | Create with position and size |
| `roundrect_free(rr#)` | `@#` → number | Explicitly free roundrect |

**Example:**
```basic
let frm# = form#("Demo", 800, 600)
let rr# = roundrect#(frm#, 50, 50, 200, 100)
```

---

### Corner Radius

| Function | Signature | Description |
|----------|-----------|-------------|
| `roundrect_xradius(rr#)` | `@#` → number | Get X radius |
| `roundrect_xradius#(rr#, value)` | `@#n` → pointer | Set X radius |
| `roundrect_yradius(rr#)` | `@#` → number | Get Y radius |
| `roundrect_yradius#(rr#, value)` | `@#n` → pointer | Set Y radius |
| `roundrect_radius#(rr#, value)` | `@#n` → pointer | Set both X and Y radius |
| `roundrect_corners(rr#)` | `@#` → number | Get corner flags |
| `roundrect_corners#(rr#, flags)` | `@#n` → pointer | Set which corners are rounded |

**Corner Flags (combine with addition):**
| Flag | Value | Description |
|------|-------|-------------|
| Top-Left | 1 | Round top-left corner |
| Top-Right | 2 | Round top-right corner |
| Bottom-Left | 4 | Round bottom-left corner |
| Bottom-Right | 8 | Round bottom-right corner |
| All | 15 | Round all corners (default) |

**Example:**
```basic
' Create a rectangle with 15px corner radius
roundrect_radius#(rr#, 15)

' Only round top corners (1 + 2 = 3)
roundrect_corners#(rr#, 3)

' Only round left corners (1 + 4 = 5)
roundrect_corners#(rr#, 5)
```

---

### Fill Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `roundrect_fill$(rr#)` | `@#` → string | Get fill color |
| `roundrect_fill#(rr#, color$)` | `@#$` → pointer | Set fill color |
| `roundrect_fillnone#(rr#)` | `@#` → pointer | Remove fill (transparent) |

**Color Formats:**
- Named colors: `"red"`, `"blue"`, `"green"`, `"white"`, `"black"`, `"yellow"`, `"cyan"`, `"magenta"`, `"gray"`, `"silver"`, `"maroon"`, `"olive"`, `"navy"`, `"purple"`, `"teal"`, `"orange"`, `"pink"`, `"brown"`, `"lime"`, `"aqua"`, `"fuchsia"`, `"transparent"`
- Hex RGB: `"#RRGGBB"` (e.g., `"#FF5500"`)
- Hex ARGB: `"#AARRGGBB"` (e.g., `"#80FF5500"` for semi-transparent)

---

### Stroke Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `roundrect_stroke$(rr#)` | `@#` → string | Get stroke color |
| `roundrect_stroke#(rr#, color$)` | `@#$` → pointer | Set stroke color |
| `roundrect_strokenone#(rr#)` | `@#` → pointer | Remove stroke |
| `roundrect_strokethickness(rr#)` | `@#` → number | Get stroke thickness |
| `roundrect_strokethickness#(rr#, value)` | `@#n` → pointer | Set stroke thickness |
| `roundrect_strokedash(rr#)` | `@#` → number | Get dash style |
| `roundrect_strokedash#(rr#, style)` | `@#n` → pointer | Set dash style |
| `roundrect_strokecap(rr#)` | `@#` → number | Get cap style |
| `roundrect_strokecap#(rr#, style)` | `@#n` → pointer | Set cap style |
| `roundrect_strokejoin(rr#)` | `@#` → number | Get join style |
| `roundrect_strokejoin#(rr#, style)` | `@#n` → pointer | Set join style |

**Stroke Dash Styles:**
| Value | Style |
|-------|-------|
| 0 | Solid (default) |
| 1 | Dash |
| 2 | Dot |
| 3 | DashDot |
| 4 | DashDotDot |

**Stroke Cap Styles:**
| Value | Style |
|-------|-------|
| 0 | Flat (default) |
| 1 | Round |

**Stroke Join Styles:**
| Value | Style |
|-------|-------|
| 0 | Miter (default) |
| 1 | Round |
| 2 | Bevel |

---

### Position and Size

| Function | Signature | Description |
|----------|-----------|-------------|
| `roundrect_x(rr#)` | `@#` → number | Get X position |
| `roundrect_x#(rr#, value)` | `@#n` → pointer | Set X position |
| `roundrect_y(rr#)` | `@#` → number | Get Y position |
| `roundrect_y#(rr#, value)` | `@#n` → pointer | Set Y position |
| `roundrect_width(rr#)` | `@#` → number | Get width |
| `roundrect_width#(rr#, value)` | `@#n` → pointer | Set width |
| `roundrect_height(rr#)` | `@#` → number | Get height |
| `roundrect_height#(rr#, value)` | `@#n` → pointer | Set height |
| `roundrect_bounds#(rr#, x, y, w, h)` | `@#nnnn` → pointer | Set position and size |
| `roundrect_size#(rr#, w, h)` | `@#nn` → pointer | Set width and height |
| `roundrect_move#(rr#, x, y)` | `@#nn` → pointer | Set position |

---

### Alignment

| Function | Signature | Description |
|----------|-----------|-------------|
| `roundrect_align(rr#)` | `@#` → number | Get alignment |
| `roundrect_align#(rr#, value)` | `@#n` → pointer | Set alignment |

**Alignment Values:**
| Value | Alignment |
|-------|-----------|
| 0 | None |
| 1 | Top |
| 2 | Left |
| 3 | Right |
| 4 | Bottom |
| 9 | Client (fill parent) |
| 11 | Center |
| 12 | VertCenter |
| 13 | HorzCenter |

---

### Margins

| Function | Signature | Description |
|----------|-----------|-------------|
| `roundrect_marginleft(rr#)` | `@#` → number | Get left margin |
| `roundrect_marginleft#(rr#, value)` | `@#n` → pointer | Set left margin |
| `roundrect_margintop(rr#)` | `@#` → number | Get top margin |
| `roundrect_margintop#(rr#, value)` | `@#n` → pointer | Set top margin |
| `roundrect_marginright(rr#)` | `@#` → number | Get right margin |
| `roundrect_marginright#(rr#, value)` | `@#n` → pointer | Set right margin |
| `roundrect_marginbottom(rr#)` | `@#` → number | Get bottom margin |
| `roundrect_marginbottom#(rr#, value)` | `@#n` → pointer | Set bottom margin |
| `roundrect_margins#(rr#, l, t, r, b)` | `@#nnnn` → pointer | Set all margins |
| `roundrect_margin#(rr#, value)` | `@#n` → pointer | Set uniform margin |

---

### Visibility and Behavior

| Function | Signature | Description |
|----------|-----------|-------------|
| `roundrect_visible(rr#)` | `@#` → number | Get visibility (0/1) |
| `roundrect_visible#(rr#, value)` | `@#n` → pointer | Set visibility |
| `roundrect_enabled(rr#)` | `@#` → number | Get enabled state (0/1) |
| `roundrect_enabled#(rr#, value)` | `@#n` → pointer | Set enabled state |
| `roundrect_opacity(rr#)` | `@#` → number | Get opacity (0.0-1.0) |
| `roundrect_opacity#(rr#, value)` | `@#n` → pointer | Set opacity |
| `roundrect_hittest(rr#)` | `@#` → number | Get hit test state (0/1) |
| `roundrect_hittest#(rr#, value)` | `@#n` → pointer | Set hit test state |

---

### Tag and Rotation

| Function | Signature | Description |
|----------|-----------|-------------|
| `roundrect_tag(rr#)` | `@#` → number | Get tag value |
| `roundrect_tag#(rr#, value)` | `@#n` → pointer | Set tag value |
| `roundrect_rotation(rr#)` | `@#` → number | Get rotation angle (degrees) |
| `roundrect_rotation#(rr#, value)` | `@#n` → pointer | Set rotation angle |

---

### Parent Control

| Function | Signature | Description |
|----------|-----------|-------------|
| `roundrect_parent#(rr#)` | `@#` → pointer | Get parent |
| `roundrect_parent#(rr#, parent#)` | `@##` → pointer | Set parent |
| `roundrect_bringtofront#(rr#)` | `@#` → pointer | Bring to front |
| `roundrect_sendtoback#(rr#)` | `@#` → pointer | Send to back |
| `roundrect_invalidate#(rr#)` | `@#` → pointer | Force repaint |

---

### Event Callbacks

| Function | Signature | Description |
|----------|-----------|-------------|
| `roundrect_onclick#(rr#, func$)` | `@#$` → pointer | Set click handler |
| `roundrect_onclick$(rr#)` | `@#` → string | Get click handler name |
| `roundrect_ondblclick#(rr#, func$)` | `@#$` → pointer | Set double-click handler |
| `roundrect_ondblclick$(rr#)` | `@#` → string | Get double-click handler name |
| `roundrect_onmousedown#(rr#, func$)` | `@#$` → pointer | Set mouse down handler |
| `roundrect_onmousedown$(rr#)` | `@#` → string | Get mouse down handler name |
| `roundrect_onmouseup#(rr#, func$)` | `@#$` → pointer | Set mouse up handler |
| `roundrect_onmouseup$(rr#)` | `@#` → string | Get mouse up handler name |
| `roundrect_onmousemove#(rr#, func$)` | `@#$` → pointer | Set mouse move handler |
| `roundrect_onmousemove$(rr#)` | `@#` → string | Get mouse move handler name |
| `roundrect_onmouseenter#(rr#, func$)` | `@#$` → pointer | Set mouse enter handler |
| `roundrect_onmouseenter$(rr#)` | `@#` → string | Get mouse enter handler name |
| `roundrect_onmouseleave#(rr#, func$)` | `@#$` → pointer | Set mouse leave handler |
| `roundrect_onmouseleave$(rr#)` | `@#` → string | Get mouse leave handler name |
| `roundrect_onmousewheel#(rr#, func$)` | `@#$` → pointer | Set mouse wheel handler |
| `roundrect_onmousewheel$(rr#)` | `@#` → string | Get mouse wheel handler name |
| `roundrect_onresize#(rr#, func$)` | `@#$` → pointer | Set resize handler |
| `roundrect_onresize$(rr#)` | `@#` → string | Get resize handler name |
| `roundrect_clearcallbacks#(rr#)` | `@#` → pointer | Clear all callbacks |

**Callback Signatures:**

```basic
' OnClick, OnDblClick, OnMouseEnter, OnMouseLeave
function OnClick(sender#)
  println "Clicked!"
endfunction

' OnMouseDown, OnMouseUp: sender#, button, x, y, shift$
function OnMouseDown(sender#, button, x, y, shift$)
  println "Button " + stri$(button) + " at " + stri$(x) + "," + stri$(y)
endfunction

' OnMouseMove: sender#, x, y, shift$
function OnMouseMove(sender#, x, y, shift$)
  println "Moving at " + stri$(x) + "," + stri$(y)
endfunction

' OnMouseWheel: sender#, delta, shift$
function OnMouseWheel(sender#, delta, shift$)
  println "Wheel delta: " + stri$(delta)
endfunction

' OnResize: sender#, width, height
function OnResize(sender#, w, h)
  println "Resized to " + stri$(w) + "x" + stri$(h)
endfunction
```

**Shift String Characters:**
| Char | Meaning |
|------|---------|
| S | Shift key |
| C | Ctrl key |
| A | Alt key |
| M | Command key (macOS) |
| L | Left mouse button |
| R | Right mouse button |
| X | Middle mouse button |

---

## Examples

### Example 1: Basic Rounded Rectangle

```basic
let frm# = form#("RoundRect Demo", 400, 300)

' Create a simple rounded rectangle
let rr# = roundrect#(frm#, 50, 50, 200, 100)
roundrect_fill#(rr#, "#3498db")
roundrect_stroke#(rr#, "#2980b9")
roundrect_strokethickness#(rr#, 2)
roundrect_radius#(rr#, 15)

form_show(frm#)
```

### Example 2: Button-Style Rectangle

```basic
let frm# = form#("Button Demo", 400, 300)

' Create a button-like rounded rectangle
let btn# = roundrect#(frm#, 100, 100, 200, 50)
roundrect_fill#(btn#, "#2ecc71")
roundrect_stroke#(btn#, "#27ae60")
roundrect_strokethickness#(btn#, 2)
roundrect_radius#(rr#, 25)  ' Pill shape with height/2 radius

roundrect_onclick#(btn#, "OnButtonClick")
roundrect_onmouseenter#(btn#, "OnButtonEnter")
roundrect_onmouseleave#(btn#, "OnButtonLeave")

form_show(frm#)

function OnButtonClick(sender#)
  println "Button clicked!"
endfunction

function OnButtonEnter(sender#)
  roundrect_fill#(sender#, "#27ae60")
endfunction

function OnButtonLeave(sender#)
  roundrect_fill#(sender#, "#2ecc71")
endfunction
```

### Example 3: Card with Top-Only Rounded Corners

```basic
let frm# = form#("Card Demo", 400, 400)

' Header with only top corners rounded
let header# = roundrect#(frm#, 50, 50, 300, 50)
roundrect_fill#(header#, "#34495e")
roundrect_strokenone#(header#)
roundrect_xradius#(header#, 10)
roundrect_yradius#(header#, 10)
roundrect_corners#(header#, 3)  ' Top-left (1) + Top-right (2)

' Body with bottom corners rounded
let body# = roundrect#(frm#, 50, 100, 300, 150)
roundrect_fill#(body#, "#ecf0f1")
roundrect_strokenone#(body#)
roundrect_xradius#(body#, 10)
roundrect_yradius#(body#, 10)
roundrect_corners#(body#, 12)  ' Bottom-left (4) + Bottom-right (8)

form_show(frm#)
```

### Example 4: Semi-Transparent Overlapping Rectangles

```basic
let frm# = form#("Transparency Demo", 400, 300)

' Create overlapping semi-transparent rectangles
let r1# = roundrect#(frm#, 50, 50, 150, 150)
roundrect_fill#(r1#, "#80e74c3c")  ' 50% transparent red
roundrect_strokenone#(r1#)
roundrect_radius#(r1#, 20)

let r2# = roundrect#(frm#, 100, 80, 150, 150)
roundrect_fill#(r2#, "#803498db")  ' 50% transparent blue
roundrect_strokenone#(r2#)
roundrect_radius#(r2#, 20)

let r3# = roundrect#(frm#, 150, 110, 150, 150)
roundrect_fill#(r3#, "#802ecc71")  ' 50% transparent green
roundrect_strokenone#(r3#)
roundrect_radius#(r3#, 20)

form_show(frm#)
```

### Example 5: Rotated Rectangle

```basic
let frm# = form#("Rotation Demo", 400, 400)

let rr# = roundrect#(frm#, 150, 150, 100, 100)
roundrect_fill#(rr#, "#9b59b6")
roundrect_stroke#(rr#, "#8e44ad")
roundrect_strokethickness#(rr#, 3)
roundrect_radius#(rr#, 10)
roundrect_rotation#(rr#, 45)

form_show(frm#)
```

---

## Important Notes

1. **HitTest**: Enabled by default for rounded rectangles, allowing mouse events. Disable with `roundrect_hittest#(rr#, 0)` if you want clicks to pass through.

2. **Corner Radius**: The radius values are independent for X and Y. Use `roundrect_radius#()` to set both at once for uniform corners.

3. **Corner Selection**: The `roundrect_corners#()` function uses a bitmask. Combine values with addition: Top-Left (1) + Top-Right (2) + Bottom-Left (4) + Bottom-Right (8).

4. **Memory Management**: Rounded rectangles are automatically managed by the garbage collector. Use `roundrect_free()` only when you need explicit cleanup.

5. **Method Chaining**: Most setter functions return the roundrect pointer, enabling chaining in future versions.

6. **Transparent Fill**: Use `roundrect_fillnone#()` for a transparent fill, or use ARGB colors like `"#80FFFFFF"` for semi-transparency.

---

## Version History

- **1.0.0** - Initial release with 78 functions
