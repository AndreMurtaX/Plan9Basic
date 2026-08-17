# CircleLib - Circle Visual Control Library for Plan9Basic

## Overview

**CircleLib** provides complete functionality for creating and managing circle/ellipse visual controls in Plan9Basic programs. A Circle is a visual shape control with fill and stroke properties.

**Version:** 1.0.0  
**Function Count:** 72 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Features

- Circle creation and lifecycle management
- Fill color and style (solid, gradient support via color)
- Stroke (border) color, thickness, and style
- Complete positioning and alignment
- Full event support with BASIC callback integration

## Color Format

Colors are specified as strings in the following formats:

| Format | Example | Description |
|--------|---------|-------------|
| Named colors | `"red"`, `"blue"`, `"green"` | Predefined colors |
| Hex RGB | `"#RRGGBB"` | e.g., `"#FF5500"` |
| Hex ARGB | `"#AARRGGBB"` | e.g., `"#80FF5500"` (semi-transparent) |

### Available Named Colors

`black`, `white`, `red`, `green`, `blue`, `yellow`, `cyan`, `magenta`, `gray`/`grey`, `silver`, `maroon`, `olive`, `navy`, `purple`, `teal`, `orange`, `pink`, `brown`, `lime`, `aqua`, `fuchsia`, `transparent`, `null`

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

#### circle_error@
Returns the last error code.

**Syntax:**
```basic
let err = circle_error()
```

**Returns:** Number - Error code (0 = no error)

---

#### circle_errormsg$@
Returns the last error message.

**Syntax:**
```basic
let msg$ = circle_errormsg$()
```

**Returns:** String - Descriptive error message

---

#### circle_strerror$@n
Returns the description of a specific error code.

**Syntax:**
```basic
let desc$ = circle_strerror$(code)
```

**Parameters:**
- `code` - Error code

**Error Codes:**
| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Invalid circle |
| 2 | Invalid parent |
| 3 | Invalid value |
| 4 | Creation failed |
| 5 | Invalid callback |
| 6 | Invalid color |

---

#### circle_clearerror@
Clears the error state.

**Syntax:**
```basic
circle_clearerror()
```

---

### Creation and Destruction

#### circle#@#
Creates a new circle with parent only.

**Syntax:**
```basic
let circ# = circle#(parent#)
```

**Parameters:**
- `parent#` - Pointer to the parent control (form, panel, layout, etc.)

**Returns:** Pointer to the created circle

---

#### circle#@#nn
Creates a circle with parent and size.

**Syntax:**
```basic
let circ# = circle#(parent#, width, height)
```

**Parameters:**
- `parent#` - Pointer to the parent control
- `width` - Circle width
- `height` - Circle height

**Returns:** Pointer to the created circle

---

#### circle#@#nnnn
Creates a circle with parent, position, and size.

**Syntax:**
```basic
let circ# = circle#(parent#, x, y, width, height)
```

**Parameters:**
- `parent#` - Pointer to the parent control
- `x` - X position
- `y` - Y position
- `width` - Circle width
- `height` - Circle height

**Returns:** Pointer to the created circle

---

#### circle_free@#
Explicitly frees a circle from memory.

**Syntax:**
```basic
circle_free(circ#)
```

**Parameters:**
- `circ#` - Pointer to the circle

**Returns:** 1 if successful, 0 otherwise

---

### Fill

#### circle_fill$@#
Gets the fill color.

**Syntax:**
```basic
let color$ = circle_fill$(circ#)
```

**Returns:** String - Color in #AARRGGBB format

---

#### circle_fill#@#$
Sets the fill color.

**Syntax:**
```basic
circle_fill#(circ#, color$)
```

**Parameters:**
- `circ#` - Pointer to the circle
- `color$` - Color (name or hex)

**Returns:** Pointer to the circle (allows chaining)

---

#### circle_fillnone#@#
Removes the fill (transparent).

**Syntax:**
```basic
circle_fillnone#(circ#)
```

**Returns:** Pointer to the circle

---

### Stroke

#### circle_stroke$@#
Gets the stroke color.

**Syntax:**
```basic
let color$ = circle_stroke$(circ#)
```

**Returns:** String - Color in #AARRGGBB format

---

#### circle_stroke#@#$
Sets the stroke color.

**Syntax:**
```basic
circle_stroke#(circ#, color$)
```

**Returns:** Pointer to the circle

---

#### circle_strokenone#@#
Removes the stroke.

**Syntax:**
```basic
circle_strokenone#(circ#)
```

**Returns:** Pointer to the circle

---

#### circle_strokethickness@# / circle_strokethickness#@#n
Gets/sets the stroke thickness.

**Syntax:**
```basic
let thickness = circle_strokethickness(circ#)
circle_strokethickness#(circ#, thickness)
```

---

#### circle_strokedash@# / circle_strokedash#@#n
Gets/sets the stroke dash style.

**Syntax:**
```basic
let style = circle_strokedash(circ#)
circle_strokedash#(circ#, style)
```

---

#### circle_strokecap@# / circle_strokecap#@#n
Gets/sets the stroke cap style.

**Syntax:**
```basic
let style = circle_strokecap(circ#)
circle_strokecap#(circ#, style)
```

---

#### circle_strokejoin@# / circle_strokejoin#@#n
Gets/sets the stroke join style.

**Syntax:**
```basic
let style = circle_strokejoin(circ#)
circle_strokejoin#(circ#, style)
```

---

### Position and Size

#### circle_x@# / circle_x#@#n
Gets/sets the X position.

**Syntax:**
```basic
let x = circle_x(circ#)
circle_x#(circ#, newX)
```

---

#### circle_y@# / circle_y#@#n
Gets/sets the Y position.

**Syntax:**
```basic
let y = circle_y(circ#)
circle_y#(circ#, newY)
```

---

#### circle_width@# / circle_width#@#n
Gets/sets the width.

**Syntax:**
```basic
let w = circle_width(circ#)
circle_width#(circ#, newWidth)
```

---

#### circle_height@# / circle_height#@#n
Gets/sets the height.

**Syntax:**
```basic
let h = circle_height(circ#)
circle_height#(circ#, newHeight)
```

---

#### circle_bounds#@#nnnn
Sets position and size at once.

**Syntax:**
```basic
circle_bounds#(circ#, x, y, width, height)
```

---

#### circle_size#@#nn
Sets width and height at once.

**Syntax:**
```basic
circle_size#(circ#, width, height)
```

---

#### circle_move#@#nn
Sets X and Y position at once.

**Syntax:**
```basic
circle_move#(circ#, x, y)
```

---

### Alignment

#### circle_align@# / circle_align#@#n
Gets/sets the alignment.

**Syntax:**
```basic
let align = circle_align(circ#)
circle_align#(circ#, alignValue)
```

---

### Margins

#### circle_marginleft@# / circle_marginleft#@#n
Gets/sets the left margin.

#### circle_margintop@# / circle_margintop#@#n
Gets/sets the top margin.

#### circle_marginright@# / circle_marginright#@#n
Gets/sets the right margin.

#### circle_marginbottom@# / circle_marginbottom#@#n
Gets/sets the bottom margin.

#### circle_margins#@#nnnn
Sets all margins at once.

**Syntax:**
```basic
circle_margins#(circ#, left, top, right, bottom)
```

#### circle_margin#@#n
Sets all margins to the same value.

**Syntax:**
```basic
circle_margin#(circ#, value)
```

---

### Visibility and Behavior

#### circle_visible@# / circle_visible#@#n
Gets/sets the visibility state.

**Syntax:**
```basic
let vis = circle_visible(circ#)
circle_visible#(circ#, 1)  ' Visible
circle_visible#(circ#, 0)  ' Hidden
```

---

#### circle_enabled@# / circle_enabled#@#n
Gets/sets the enabled state.

---

#### circle_opacity@# / circle_opacity#@#n
Gets/sets the opacity (0.0 to 1.0).

**Syntax:**
```basic
let op = circle_opacity(circ#)
circle_opacity#(circ#, 0.5)  ' 50% transparent
```

---

#### circle_hittest@# / circle_hittest#@#n
Gets/sets the hit test state (click detection).

---

### Tag and Rotation

#### circle_tag@# / circle_tag#@#n
Gets/sets the tag value (numeric identifier).

---

#### circle_rotation@# / circle_rotation#@#n
Gets/sets the rotation angle in degrees.

**Syntax:**
```basic
let angle = circle_rotation(circ#)
circle_rotation#(circ#, 45)  ' Rotate 45 degrees
```

---

### Parent Control

#### circle_parent#@#
Gets the circle's parent.

**Syntax:**
```basic
let parent# = circle_parent#(circ#)
```

---

#### circle_parent#@##
Sets the circle's parent.

**Syntax:**
```basic
circle_parent#(circ#, newParent#)
```

---

#### circle_bringtofront#@#
Brings the circle to front.

**Syntax:**
```basic
circle_bringtofront#(circ#)
```

---

#### circle_sendtoback#@#
Sends the circle to back.

**Syntax:**
```basic
circle_sendtoback#(circ#)
```

---

### Invalidation

#### circle_invalidate#@#
Forces the circle to repaint.

**Syntax:**
```basic
circle_invalidate#(circ#)
```

---

### Event Callbacks

#### circle_onclick#@#$ / circle_onclick$@#
Sets/gets the OnClick event handler.

**Syntax:**
```basic
circle_onclick#(circ#, "MyOnClick")
let handler$ = circle_onclick$(circ#)
```

**Callback Signature:**
```basic
function MyOnClick(sender#)
  println "Circle clicked!"
endfunction
```

---

#### circle_ondblclick#@#$ / circle_ondblclick$@#
Sets/gets the OnDblClick (double-click) event handler.

**Callback Signature:**
```basic
function MyOnDblClick(sender#)
  println "Circle double-clicked!"
endfunction
```

---

#### circle_onmousedown#@#$ / circle_onmousedown$@#
Sets/gets the OnMouseDown event handler.

**Callback Signature:**
```basic
function MyOnMouseDown(sender#, button, x, y, shift$)
  ' button: 0=left, 1=right, 2=middle
  ' shift$: "S"=Shift, "C"=Ctrl, "A"=Alt, "M"=Command
  println "Mouse pressed at: " + stri$(x) + ", " + stri$(y)
endfunction
```

---

#### circle_onmouseup#@#$ / circle_onmouseup$@#
Sets/gets the OnMouseUp event handler.

**Callback Signature:**
```basic
function MyOnMouseUp(sender#, button, x, y, shift$)
  println "Mouse released"
endfunction
```

---

#### circle_onmousemove#@#$ / circle_onmousemove$@#
Sets/gets the OnMouseMove event handler.

**Callback Signature:**
```basic
function MyOnMouseMove(sender#, x, y, shift$)
  println "Mouse at: " + stri$(x) + ", " + stri$(y)
endfunction
```

---

#### circle_onmouseenter#@#$ / circle_onmouseenter$@#
Sets/gets the OnMouseEnter event handler.

**Callback Signature:**
```basic
function MyOnMouseEnter(sender#)
  println "Mouse entered the circle"
endfunction
```

---

#### circle_onmouseleave#@#$ / circle_onmouseleave$@#
Sets/gets the OnMouseLeave event handler.

**Callback Signature:**
```basic
function MyOnMouseLeave(sender#)
  println "Mouse left the circle"
endfunction
```

---

#### circle_onmousewheel#@#$ / circle_onmousewheel$@#
Sets/gets the OnMouseWheel event handler.

**Callback Signature:**
```basic
function MyOnMouseWheel(sender#, delta, shift$)
  println "Mouse wheel: " + stri$(delta)
endfunction
```

---

#### circle_onresize#@#$ / circle_onresize$@#
Sets/gets the OnResize event handler.

**Callback Signature:**
```basic
function MyOnResize(sender#, width, height)
  println "Resizing: " + stri$(width) + " x " + stri$(height)
endfunction
```

---

#### circle_clearcallbacks#@#
Clears all event callbacks.

**Syntax:**
```basic
let circ# = circle_clearcallbacks#(circ#)
```

**Returns:** Pointer to the circle (allows chaining)

**Note:** This function returns the circle pointer to allow method chaining.

---

## Usage Examples

### Example 1: Basic Circle

```basic
' Create form
let frm# = form#("Circle Demo", 400, 300)

' Create blue circle
let circ# = circle#(frm#, 50, 50, 100, 100)
circle_fill#(circ#, "#3498db")
circle_stroke#(circ#, "#2980b9")
circle_strokethickness#(circ#, 2)

' Show form
form_show(frm#)
```

### Example 2: Circle with Events

```basic
let frm# = form#("Interactive Circle", 400, 300)

let circ# = circle#(frm#, 150, 100, 80, 80)
circle_fill#(circ#, "red")
circle_stroke#(circ#, "darkred")
circle_strokethickness#(circ#, 3)

' Set up events
circle_onclick#(circ#, "OnCircleClick")
circle_onmouseenter#(circ#, "OnCircleEnter")
circle_onmouseleave#(circ#, "OnCircleLeave")

form_show(frm#)

function OnCircleClick(sender#)
  println "Circle clicked!"
endfunction

function OnCircleEnter(sender#)
  circle_fill#(sender#, "orange")
endfunction

function OnCircleLeave(sender#)
  circle_fill#(sender#, "red")
endfunction
```

### Example 3: Ellipse (Circle with Different Width and Height)

```basic
let frm# = form#("Ellipse Demo", 400, 300)

' Create ellipse (width different from height)
let ellipse# = circle#(frm#, 50, 80, 200, 100)
circle_fill#(ellipse#, "#9b59b6")
circle_stroke#(ellipse#, "#8e44ad")
circle_strokethickness#(ellipse#, 2)

form_show(frm#)
```

### Example 4: Multiple Circles with Rotation

```basic
let frm# = form#("Rotated Circles", 500, 400)

for i = 0 to 4
  let circ# = circle#(frm#, 100 + i * 70, 150, 60, 60)
  circle_fill#(circ#, "#e74c3c")
  circle_stroke#(circ#, "#c0392b")
  circle_strokethickness#(circ#, 2)
  circle_rotation#(circ#, i * 15)
next

form_show(frm#)
```

### Example 5: Semi-Transparent Circle

```basic
let frm# = form#("Transparency", 400, 300)

' Background circle
let background# = circle#(frm#, 80, 80, 150, 150)
circle_fill#(background#, "blue")

' Semi-transparent overlapping circle
let foreground# = circle#(frm#, 140, 100, 150, 150)
circle_fill#(foreground#, "#80FF0000")  ' Red with 50% opacity
circle_strokenone#(foreground#)

form_show(frm#)
```

### Example 6: Clearing Callbacks

```basic
let frm# = form#("Callbacks Demo", 400, 300)
let circ# = circle#(frm#, 50, 50, 100, 100)
circle_fill#(circ#, "green")

' Set up callbacks
circle_onclick#(circ#, "OnClick")
circle_onmouseenter#(circ#, "OnEnter")

' Clear all callbacks (returns the pointer)
let circ# = circle_clearcallbacks#(circ#)

form_show(frm#)

function OnClick(sender#)
  println "This callback was removed"
endfunction

function OnEnter(sender#)
  println "This callback was also removed"
endfunction
```

---

## Important Notes

1. **HitTest**: By default, circles are created with `HitTest = True`, allowing mouse events. Use `circle_hittest#(circ#, 0)` to disable.

2. **Circle vs Ellipse**: TCircle can be either a perfect circle (when width = height) or an ellipse (when width ≠ height).

3. **Memory Management**: Circles are automatically managed by Plan9Basic's garbage collection system. Use `circle_free` only if you need to explicitly free memory.

4. **Chaining**: Functions that return `#` (pointer) allow method chaining.

5. **Events**: Always set up callbacks before showing the form to ensure all events are captured from the start.

---

## See Also

- RectangleLib - Rectangle control
- RoundRectLib - Rounded rectangle control
- PanelLib - Panel container control
- FormLib - Form control
- LayoutLib - Layout control
