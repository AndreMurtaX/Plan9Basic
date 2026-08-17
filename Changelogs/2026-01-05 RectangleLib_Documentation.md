# RectangleLib - Rectangle Visual Control Library for Plan9Basic

**Version:** 1.0.0  
**Function Count:** 98 functions  
**Dependencies:** FormLib or LayoutLib (for parent containers)

## Overview

RectangleLib provides complete rectangle visual control functionality for creating and managing rectangle shapes in Plan9Basic programs. A Rectangle is the primary visual shape control with fill, stroke (border), and corner rounding capabilities.

Rectangles are fundamental building blocks for creating visual user interfaces. They can be used for:
- Colored backgrounds and panels
- Buttons (with click events)
- Cards and containers with visual styling
- Progress indicators
- Decorative elements
- Custom-drawn components

## Cross-Platform Support

RectangleLib works on all platforms supported by Plan9Basic:
- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

---

## Quick Start

### Basic Rectangle

```basic
' Create a form
let frm# = form#("Rectangle Demo", 800, 600)

' Create a blue rectangle
let r# = rectangle#(frm#, 50, 50, 200, 100)
rectangle_fill#(r#, "blue")

form_show(frm#)
```

### Styled Rectangle with Rounded Corners

```basic
let frm# = form#("Styled Rectangle", 800, 600)

let card# = rectangle#(frm#, 50, 50, 300, 200)
rectangle_fill#(card#, "#3498db")         ' Nice blue fill
rectangle_stroke#(card#, "#2980b9")       ' Darker blue border
rectangle_strokethickness#(card#, 2)      ' 2px border
rectangle_corners#(card#, 15, 15)         ' Rounded corners

form_show(frm#)
```

### Interactive Rectangle (Button-like)

```basic
let frm# = form#("Clickable Rectangle", 800, 600)

let btn# = rectangle#(frm#, 50, 50, 150, 50)
rectangle_fill#(btn#, "#27ae60")
rectangle_corners#(btn#, 8, 8)
rectangle_onclick#(btn#, "OnButtonClick")

form_show(frm#)

function OnButtonClick(sender#)
  println "Button clicked!"
  rectangle_fill#(sender#, "#2ecc71")  ' Lighten on click
endfunction
```

---

## Color Format

Colors can be specified in several formats:

### Named Colors
```basic
rectangle_fill#(r#, "red")
rectangle_fill#(r#, "blue")
rectangle_fill#(r#, "green")
rectangle_fill#(r#, "transparent")
```

**Available named colors:** black, white, red, green, blue, yellow, cyan, magenta, gray/grey, silver, maroon, olive, navy, purple, teal, orange, pink, brown, lime, aqua, fuchsia, transparent, null

### Hex RGB Format
```basic
rectangle_fill#(r#, "#FF5500")     ' Orange
rectangle_fill#(r#, "#3498db")     ' Nice blue
```

### Hex ARGB Format (with transparency)
```basic
rectangle_fill#(r#, "#80FF5500")   ' Semi-transparent orange (50% alpha)
rectangle_fill#(r#, "#40000000")   ' Very transparent black overlay
```

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `rectangle_error()` | Returns last error code (0 = no error) |
| `rectangle_errormsg$()` | Returns last error message |
| `rectangle_strerror$(code)` | Returns description for error code |
| `rectangle_clearerror()` | Clears error state |

**Error Codes:**
| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Invalid or nil rectangle |
| 2 | Invalid parent control |
| 3 | Invalid value |
| 4 | Rectangle creation failed |
| 5 | Invalid callback function |
| 6 | Invalid color value |

---

### Rectangle Creation and Destruction

#### rectangle#(parent#)
Creates a new rectangle as a child of the specified parent (100x100 default size).

```basic
let r# = rectangle#(parentForm#)
```

#### rectangle#(parent#, width, height)
Creates a rectangle with specified size at position (0,0).

```basic
let r# = rectangle#(parentForm#, 200, 100)
```

#### rectangle#(parent#, x, y, width, height)
Creates a rectangle with specified position and size.

```basic
let r# = rectangle#(parentForm#, 50, 50, 200, 100)
```

#### rectangle_free(rect#)
Frees a rectangle and removes it from its parent.

```basic
rectangle_free(myRect#)
```

---

### Fill (Background Color)

| Function | Description |
|----------|-------------|
| `rectangle_fill$(rect#)` | Get fill color as "#AARRGGBB" string |
| `rectangle_fill#(rect#, color$)` | Set fill color |
| `rectangle_fillnone#(rect#)` | Set fill to transparent (no fill) |

```basic
' Set fill color
rectangle_fill#(r#, "#3498db")

' Get current fill
let color$ = rectangle_fill$(r#)

' Remove fill (transparent)
rectangle_fillnone#(r#)
```

---

### Stroke (Border)

| Function | Description |
|----------|-------------|
| `rectangle_stroke$(rect#)` | Get stroke color |
| `rectangle_stroke#(rect#, color$)` | Set stroke color |
| `rectangle_strokenone#(rect#)` | Remove stroke (no border) |
| `rectangle_strokethickness(rect#)` | Get stroke thickness |
| `rectangle_strokethickness#(rect#, value)` | Set stroke thickness |
| `rectangle_strokedash(rect#)` | Get dash style (0-4) |
| `rectangle_strokedash#(rect#, value)` | Set dash style |
| `rectangle_strokecap(rect#)` | Get cap style (0-1) |
| `rectangle_strokecap#(rect#, value)` | Set cap style |
| `rectangle_strokejoin(rect#)` | Get join style (0-2) |
| `rectangle_strokejoin#(rect#, value)` | Set join style |

#### Stroke Dash Styles
| Value | Style |
|-------|-------|
| 0 | Solid (default) |
| 1 | Dash |
| 2 | Dot |
| 3 | DashDot |
| 4 | DashDotDot |

#### Stroke Cap Styles
| Value | Style |
|-------|-------|
| 0 | Flat (default) |
| 1 | Round |

#### Stroke Join Styles
| Value | Style |
|-------|-------|
| 0 | Miter (default) |
| 1 | Round |
| 2 | Bevel |

```basic
' Create a dashed border
rectangle_stroke#(r#, "red")
rectangle_strokethickness#(r#, 3)
rectangle_strokedash#(r#, 1)  ' Dashed line
```

---

### Corner Radius (Rounded Corners)

| Function | Description |
|----------|-------------|
| `rectangle_xradius(rect#)` | Get X radius |
| `rectangle_xradius#(rect#, value)` | Set X radius |
| `rectangle_yradius(rect#)` | Get Y radius |
| `rectangle_yradius#(rect#, value)` | Set Y radius |
| `rectangle_corners#(rect#, xrad, yrad)` | Set both radii at once |

```basic
' Create pill-shaped rectangle
rectangle_corners#(r#, 25, 25)

' Create oval corners (different X and Y)
rectangle_xradius#(r#, 20)
rectangle_yradius#(r#, 10)
```

---

### Sides and Corners Selection

Control which sides are drawn and which corners are rounded using bitmask flags.

#### Sides Flags
| Flag | Side |
|------|------|
| 1 | Top |
| 2 | Left |
| 4 | Bottom |
| 8 | Right |
| 15 | All sides (default) |

#### Corners Flags
| Flag | Corner |
|------|--------|
| 1 | TopLeft |
| 2 | TopRight |
| 4 | BottomLeft |
| 8 | BottomRight |
| 15 | All corners (default) |

| Function | Description |
|----------|-------------|
| `rectangle_sides(rect#)` | Get sides flags |
| `rectangle_sides#(rect#, value)` | Set sides flags |
| `rectangle_cornersflags(rect#)` | Get corners flags |
| `rectangle_cornersflags#(rect#, value)` | Set corners flags |

```basic
' Only draw top and bottom borders
rectangle_sides#(r#, 1 + 4)  ' Top (1) + Bottom (4) = 5

' Only round top corners
rectangle_cornersflags#(r#, 1 + 2)  ' TopLeft (1) + TopRight (2) = 3
rectangle_corners#(r#, 10, 10)
```

---

### Position and Size

| Function | Description |
|----------|-------------|
| `rectangle_x(rect#)` | Get X position |
| `rectangle_x#(rect#, value)` | Set X position |
| `rectangle_y(rect#)` | Get Y position |
| `rectangle_y#(rect#, value)` | Set Y position |
| `rectangle_width(rect#)` | Get width |
| `rectangle_width#(rect#, value)` | Set width |
| `rectangle_height(rect#)` | Get height |
| `rectangle_height#(rect#, value)` | Set height |
| `rectangle_bounds#(rect#, x, y, w, h)` | Set all bounds at once |
| `rectangle_size#(rect#, w, h)` | Set size only |
| `rectangle_move#(rect#, x, y)` | Set position only |

```basic
' Position and size
rectangle_move#(r#, 100, 100)
rectangle_size#(r#, 200, 150)

' Or all at once
rectangle_bounds#(r#, 100, 100, 200, 150)
```

---

### Alignment

| Function | Description |
|----------|-------------|
| `rectangle_align(rect#)` | Get alignment value (0-19) |
| `rectangle_align#(rect#, value)` | Set alignment value |

See LayoutLib documentation for full alignment values (0=None through 19=FitRight).

```basic
' Fill parent width at top
rectangle_align#(r#, 1)  ' Top
rectangle_height#(r#, 50)
```

---

### Margins

| Function | Description |
|----------|-------------|
| `rectangle_marginleft(rect#)` | Get left margin |
| `rectangle_marginleft#(rect#, value)` | Set left margin |
| `rectangle_margintop(rect#)` | Get top margin |
| `rectangle_margintop#(rect#, value)` | Set top margin |
| `rectangle_marginright(rect#)` | Get right margin |
| `rectangle_marginright#(rect#, value)` | Set right margin |
| `rectangle_marginbottom(rect#)` | Get bottom margin |
| `rectangle_marginbottom#(rect#, value)` | Set bottom margin |
| `rectangle_margins#(rect#, l, t, r, b)` | Set all margins |
| `rectangle_margin#(rect#, value)` | Set uniform margin |

```basic
' Add 10px margin on all sides
rectangle_margin#(r#, 10)
```

---

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `rectangle_visible(rect#)` | Get visibility (0/1) |
| `rectangle_visible#(rect#, value)` | Set visibility |
| `rectangle_enabled(rect#)` | Get enabled state (0/1) |
| `rectangle_enabled#(rect#, value)` | Set enabled state |
| `rectangle_opacity(rect#)` | Get opacity (0.0-1.0) |
| `rectangle_opacity#(rect#, value)` | Set opacity |
| `rectangle_hittest(rect#)` | Get hit test flag (0/1) |
| `rectangle_hittest#(rect#, value)` | Set hit test flag |

```basic
' Make semi-transparent
rectangle_opacity#(r#, 0.5)

' Hide rectangle
rectangle_visible#(r#, 0)

' Disable mouse interaction
rectangle_hittest#(r#, 0)
```

---

### Tag and Rotation

| Function | Description |
|----------|-------------|
| `rectangle_tag(rect#)` | Get tag value |
| `rectangle_tag#(rect#, value)` | Set tag value |
| `rectangle_rotation(rect#)` | Get rotation angle (degrees) |
| `rectangle_rotation#(rect#, value)` | Set rotation angle |

```basic
' Store custom ID
rectangle_tag#(r#, 42)

' Rotate 45 degrees
rectangle_rotation#(r#, 45)
```

---

### Parent and Z-Order

| Function | Description |
|----------|-------------|
| `rectangle_parent#(rect#)` | Get parent control |
| `rectangle_parent#(rect#, newParent#)` | Set parent control |
| `rectangle_bringtofront#(rect#)` | Bring to front of siblings |
| `rectangle_sendtoback#(rect#)` | Send to back of siblings |

---

### Invalidation

| Function | Description |
|----------|-------------|
| `rectangle_invalidate#(rect#)` | Force rectangle to repaint |

---

## Event Callbacks

### Available Events

| Event | Callback Signature | Description |
|-------|-------------------|-------------|
| OnClick | `funcname(sender#)` | Rectangle was clicked |
| OnDblClick | `funcname(sender#)` | Rectangle was double-clicked |
| OnMouseDown | `funcname(sender#, button, x, y, shift$)` | Mouse button pressed |
| OnMouseUp | `funcname(sender#, button, x, y, shift$)` | Mouse button released |
| OnMouseMove | `funcname(sender#, x, y, shift$)` | Mouse moved over rectangle |
| OnMouseEnter | `funcname(sender#)` | Mouse entered rectangle |
| OnMouseLeave | `funcname(sender#)` | Mouse left rectangle |
| OnMouseWheel | `funcname(sender#, delta, shift$)` | Mouse wheel (return 1 to handle) |
| OnResize | `funcname(sender#, width, height)` | Rectangle is being resized |

### Setting Event Handlers

| Function | Description |
|----------|-------------|
| `rectangle_onclick#(rect#, funcname$)` | Set OnClick handler |
| `rectangle_onclick$(rect#)` | Get OnClick handler name |
| `rectangle_ondblclick#(rect#, funcname$)` | Set OnDblClick handler |
| `rectangle_ondblclick$(rect#)` | Get OnDblClick handler name |
| `rectangle_onmousedown#(rect#, funcname$)` | Set OnMouseDown handler |
| `rectangle_onmousedown$(rect#)` | Get OnMouseDown handler name |
| `rectangle_onmouseup#(rect#, funcname$)` | Set OnMouseUp handler |
| `rectangle_onmouseup$(rect#)` | Get OnMouseUp handler name |
| `rectangle_onmousemove#(rect#, funcname$)` | Set OnMouseMove handler |
| `rectangle_onmousemove$(rect#)` | Get OnMouseMove handler name |
| `rectangle_onmouseenter#(rect#, funcname$)` | Set OnMouseEnter handler |
| `rectangle_onmouseenter$(rect#)` | Get OnMouseEnter handler name |
| `rectangle_onmouseleave#(rect#, funcname$)` | Set OnMouseLeave handler |
| `rectangle_onmouseleave$(rect#)` | Get OnMouseLeave handler name |
| `rectangle_onmousewheel#(rect#, funcname$)` | Set OnMouseWheel handler |
| `rectangle_onmousewheel$(rect#)` | Get OnMouseWheel handler name |
| `rectangle_onresize#(rect#, funcname$)` | Set OnResize handler |
| `rectangle_onresize$(rect#)` | Get OnResize handler name |
| `rectangle_clearcallbacks#(rect#)` | Clear all event handlers |

---

## Complete Examples

### Example 1: Color Palette

```basic
' Create a color palette with clickable swatches

let frm# = form#("Color Palette", 400, 300)

let colors$(6)
colors$(1) = "#e74c3c"  ' Red
colors$(2) = "#3498db"  ' Blue
colors$(3) = "#2ecc71"  ' Green
colors$(4) = "#f39c12"  ' Orange
colors$(5) = "#9b59b6"  ' Purple
colors$(6) = "#1abc9c"  ' Teal

for i = 1 to 6
  let x = ((i - 1) mod 3) * 120 + 20
  let y = ((i - 1) / 3) * 120 + 20
  
  let swatch# = rectangle#(frm#, x, y, 100, 100)
  rectangle_fill#(swatch#, colors$(i))
  rectangle_corners#(swatch#, 10, 10)
  rectangle_tag#(swatch#, i)
  rectangle_onclick#(swatch#, "OnSwatchClick")
next

form_show(frm#)

function OnSwatchClick(sender#) local idx
  idx = rectangle_tag(sender#)
  println "Selected color index: " + stri$(idx)
  println "Color: " + rectangle_fill$(sender#)
endfunction
```

### Example 2: Hover Effect

```basic
' Rectangle that changes color on hover

let frm# = form#("Hover Demo", 400, 300)

let btn# = rectangle#(frm#, 100, 100, 200, 60)
rectangle_fill#(btn#, "#3498db")
rectangle_corners#(btn#, 8, 8)
rectangle_onmouseenter#(btn#, "OnBtnEnter")
rectangle_onmouseleave#(btn#, "OnBtnLeave")
rectangle_onclick#(btn#, "OnBtnClick")

form_show(frm#)

function OnBtnEnter(sender#)
  rectangle_fill#(sender#, "#2980b9")  ' Darker on hover
endfunction

function OnBtnLeave(sender#)
  rectangle_fill#(sender#, "#3498db")  ' Original color
endfunction

function OnBtnClick(sender#)
  println "Button clicked!"
endfunction
```

### Example 3: Progress Bar

```basic
' Simple progress bar using rectangles

let frm# = form#("Progress Bar", 400, 150)

' Background
let bg# = rectangle#(frm#, 50, 50, 300, 30)
rectangle_fill#(bg#, "#ecf0f1")
rectangle_stroke#(bg#, "#bdc3c7")
rectangle_corners#(bg#, 5, 5)

' Progress fill
let progress# = rectangle#(frm#, 50, 50, 0, 30)
rectangle_fill#(progress#, "#27ae60")
rectangle_strokenone#(progress#)
rectangle_corners#(progress#, 5, 5)

form_show(frm#)

' Animate progress
for p = 0 to 100
  rectangle_width#(progress#, p * 3)
  pause(0.02)
next

println "Complete!"
```

### Example 4: Card with Shadow Effect

```basic
' Create a card with shadow using layered rectangles

let frm# = form#("Card Demo", 500, 400)

' Shadow (offset and darker)
let shadow# = rectangle#(frm#, 54, 54, 300, 200)
rectangle_fill#(shadow#, "#40000000")  ' Semi-transparent black
rectangle_strokenone#(shadow#)
rectangle_corners#(shadow#, 12, 12)

' Card
let card# = rectangle#(frm#, 50, 50, 300, 200)
rectangle_fill#(card#, "white")
rectangle_stroke#(card#, "#e0e0e0")
rectangle_strokethickness#(card#, 1)
rectangle_corners#(card#, 10, 10)

form_show(frm#)
```

### Example 5: Rotating Rectangle

```basic
' Rectangle that rotates on click

let frm# = form#("Rotation Demo", 400, 400)

let r# = rectangle#(frm#, 150, 150, 100, 100)
rectangle_fill#(r#, "#e74c3c")
rectangle_onclick#(r#, "OnRotate")

let angle = 0

form_show(frm#)

function OnRotate(sender#)
  angle = angle + 45
  if angle >= 360 then
    angle = 0
  endif
  rectangle_rotation#(sender#, angle)
  println "Rotated to: " + stri$(angle) + " degrees"
endfunction
```

---

## Best Practices

### 1. Use Meaningful Colors
Use hex colors for precise control, named colors for quick prototyping.

### 2. Corner Radius Guidelines
- Small buttons: 4-8px
- Cards: 8-12px
- Pills/badges: 15-25px or half the height

### 3. Border Thickness
- Subtle borders: 1px
- Emphasized borders: 2-3px
- Decorative: 4px+

### 4. Layer Order
Create background elements first, foreground elements last. Use `rectangle_bringtofront#` and `rectangle_sendtoback#` to adjust.

### 5. Performance
For many rectangles, disable hit testing on decorative ones:
```basic
rectangle_hittest#(decorativeRect#, 0)
```

---

## Related Libraries

- **FormLib** - Form/window management (parent container)
- **LayoutLib** - Layout containers for organizing rectangles
- **LabelLib** - Text labels (coming soon)
- **ButtonLib** - Button controls (coming soon)

---

## Version History

### 1.0.0 (Current)
- Initial release
- 98 functions for rectangle management
- Complete fill and stroke styling
- Corner rounding with selective corners
- Full event support
- Rotation support

---

*Copyright (c) 2024-2025 Plan9Basic Project*
