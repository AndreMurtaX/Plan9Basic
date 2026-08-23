# LayoutLib - Layout Container Library for Plan9Basic

**Version:** 1.0.0  
**Function Count:** 78 functions  
**Dependencies:** FormLib (for parent forms)

## Overview

LayoutLib provides complete FireMonkey TLayout wrapper functionality for creating and managing container controls in Plan9Basic programs. TLayout is a non-visual container that helps organize child controls with alignment and positioning capabilities.

Layouts are essential building blocks for creating structured user interfaces. They act as invisible containers that can:
- Group related controls together
- Apply alignment rules to position children automatically
- Define padding and margins for spacing
- Clip children that extend beyond boundaries
- Handle mouse and drag-drop events

## Cross-Platform Support

LayoutLib works on all platforms supported by FireMonkey:
- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

All layouts are created at runtime with dynamic parent assignment, ensuring proper cross-platform behavior.

---

## Quick Start

### Basic Layout Creation

```basic
' Create a form first
let frm# = form#("My Application", 800, 600)

' Create a layout that fills the entire form
let mainLayout# = layout#(frm#)
layout_align#(mainLayout#, 9)  ' 9 = Client (fill remaining space)

' Show the form
form_show(frm#)

pause(3)

form_close(frm#) 'close the form
form_free(frm#) 'release memory
```

### Creating a Header-Content-Footer Structure

```basic
' Create form
let frm# = form#("Layout Demo", 800, 600)

' Main container
let main# = layout#(frm#)
layout_align#(main#, 9)  ' Client fill

' Header (50px tall, aligned to top)
let header# = layout#(main#)
layout_align#(header#, 1)    ' Top
layout_height#(header#, 50)

' Footer (40px tall, aligned to bottom)
let footer# = layout#(main#)
layout_align#(footer#, 4)    ' Bottom
layout_height#(footer#, 40)

' Content (fills remaining space)
let content# = layout#(main#)
layout_align#(content#, 9)   ' Client

form_show(frm#)

pause(3)

form_close(frm#) 'close the form
form_free(frm#) 'release memory
```

---

## Alignment Values

Layouts can be automatically positioned using alignment values:

| Value | Constant | Description |
|-------|----------|-------------|
| 0 | None | No alignment (manual positioning) |
| 1 | Top | Align to top of parent |
| 2 | Left | Align to left of parent |
| 3 | Right | Align to right of parent |
| 4 | Bottom | Align to bottom of parent |
| 5 | MostTop | Align to very top (above Top) |
| 6 | MostBottom | Align to very bottom (below Bottom) |
| 7 | MostLeft | Align to very left (before Left) |
| 8 | MostRight | Align to very right (after Right) |
| 9 | Client | Fill remaining client area |
| 10 | Contents | Fit to contents size |
| 11 | Center | Center in parent (both axes) |
| 12 | VertCenter | Center vertically only |
| 13 | HorzCenter | Center horizontally only |
| 14 | Horizontal | Stretch horizontally |
| 15 | Vertical | Stretch vertically |
| 16 | Scale | Scale proportionally |
| 17 | Fit | Fit within parent bounds |
| 18 | FitLeft | Fit and align left |
| 19 | FitRight | Fit and align right |

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `layout_error()` | Returns last error code (0 = no error) |
| `layout_errormsg$()` | Returns last error message |
| `layout_strerror$(code)` | Returns description for error code |
| `layout_clearerror()` | Clears error state |

**Error Codes:**
| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Invalid or nil layout |
| 2 | Invalid parent control |
| 3 | Invalid value |
| 4 | Layout creation failed |
| 5 | Invalid callback function |
| 6 | Invalid control |

---

### Layout Creation and Destruction

#### layout#(parent#)
Creates a new layout as a child of the specified parent.

```basic
let myLayout# = layout#(parentForm#)
```

#### layout#(parent#, width, height)
Creates a layout with specified size.

```basic
let myLayout# = layout#(parentForm#, 200, 100)
```

#### layout#(parent#, x, y, width, height)
Creates a layout with specified position and size.

```basic
let myLayout# = layout#(parentForm#, 10, 10, 200, 100)
```

#### layout_free(layout#)
Frees a layout and removes it from its parent.

```basic
layout_free(myLayout#)
```

---

### Parent/Child Management

| Function | Description |
|----------|-------------|
| `layout_parent#(layout#)` | Get the parent of the layout |
| `layout_parent#(layout#, newParent#)` | Set the parent of the layout |
| `layout_childcount(layout#)` | Get number of child controls |
| `layout_child#(layout#, index)` | Get child control by index (0-based) |
| `layout_bringtofront#(layout#)` | Bring layout to front of siblings |
| `layout_sendtoback#(layout#)` | Send layout to back of siblings |

```basic
' Reparent a layout
let parent1# = layout#(frm#)
let parent2# = layout#(frm#)
let child# = layout#(parent1#)

' Move child to parent2
layout_parent#(child#, parent2#)

' Get child count
let count = layout_childcount(parent1#)
println "Parent1 now has " + stri$(count) + " children"
```

---

### Position and Size

| Function | Description |
|----------|-------------|
| `layout_x(layout#)` | Get X position |
| `layout_x#(layout#, value)` | Set X position |
| `layout_y(layout#)` | Get Y position |
| `layout_y#(layout#, value)` | Set Y position |
| `layout_width(layout#)` | Get width |
| `layout_width#(layout#, value)` | Set width |
| `layout_height(layout#)` | Get height |
| `layout_height#(layout#, value)` | Set height |
| `layout_bounds#(layout#, x, y, w, h)` | Set all bounds at once |
| `layout_size#(layout#, w, h)` | Set size only |
| `layout_move#(layout#, x, y)` | Set position only |

```basic
' Position a layout manually
layout_align#(myLayout#, 0)  ' None - enable manual positioning
layout_move#(myLayout#, 50, 50)
layout_size#(myLayout#, 200, 150)

' Or set all at once
layout_bounds#(myLayout#, 50, 50, 200, 150)
```

---

### Alignment

| Function | Description |
|----------|-------------|
| `layout_align(layout#)` | Get current alignment value |
| `layout_align#(layout#, value)` | Set alignment value (0-19) |

```basic
' Create a sidebar layout
let sidebar# = layout#(frm#)
layout_align#(sidebar#, 2)   ' Left alignment
layout_width#(sidebar#, 200) ' Fixed width of 200px
```

---

### Margins (space outside the layout)

| Function | Description |
|----------|-------------|
| `layout_marginleft(layout#)` | Get left margin |
| `layout_marginleft#(layout#, value)` | Set left margin |
| `layout_margintop(layout#)` | Get top margin |
| `layout_margintop#(layout#, value)` | Set top margin |
| `layout_marginright(layout#)` | Get right margin |
| `layout_marginright#(layout#, value)` | Set right margin |
| `layout_marginbottom(layout#)` | Get bottom margin |
| `layout_marginbottom#(layout#, value)` | Set bottom margin |
| `layout_margins#(layout#, l, t, r, b)` | Set all margins |
| `layout_margin#(layout#, value)` | Set uniform margin |

```basic
' Add spacing around a layout
layout_margin#(myLayout#, 10)  ' 10px on all sides

' Or different margins per side
layout_margins#(myLayout#, 5, 10, 5, 10)
```

---

### Padding (space inside the layout)

| Function | Description |
|----------|-------------|
| `layout_paddingleft(layout#)` | Get left padding |
| `layout_paddingleft#(layout#, value)` | Set left padding |
| `layout_paddingtop(layout#)` | Get top padding |
| `layout_paddingtop#(layout#, value)` | Set top padding |
| `layout_paddingright(layout#)` | Get right padding |
| `layout_paddingright#(layout#, value)` | Set right padding |
| `layout_paddingbottom(layout#)` | Get bottom padding |
| `layout_paddingbottom#(layout#, value)` | Set bottom padding |
| `layout_paddings#(layout#, l, t, r, b)` | Set all padding |
| `layout_padding#(layout#, value)` | Set uniform padding |

```basic
' Add internal spacing for child controls
layout_padding#(container#, 15)
```

---

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `layout_visible(layout#)` | Get visibility (0/1) |
| `layout_visible#(layout#, value)` | Set visibility |
| `layout_enabled(layout#)` | Get enabled state (0/1) |
| `layout_enabled#(layout#, value)` | Set enabled state |
| `layout_opacity(layout#)` | Get opacity (0.0-1.0) |
| `layout_opacity#(layout#, value)` | Set opacity |
| `layout_clipchildren(layout#)` | Get clip children flag (0/1) |
| `layout_clipchildren#(layout#, value)` | Set clip children flag |
| `layout_hittest(layout#)` | Get hit test flag (0/1) |
| `layout_hittest#(layout#, value)` | Set hit test flag |
| `layout_locked(layout#)` | Get locked state (0/1) |
| `layout_locked#(layout#, value)` | Set locked state |

```basic
' Make a layout semi-transparent
layout_opacity#(overlay#, 0.5)

' Clip children that extend beyond bounds
layout_clipchildren#(scrollContent#, 1)

' Disable hit testing (mouse events pass through)
layout_hittest#(decorativeLayer#, 0)
```

---

### Tag

| Function | Description |
|----------|-------------|
| `layout_tag(layout#)` | Get tag value |
| `layout_tag#(layout#, value)` | Set tag value |

```basic
' Store custom data in tag
layout_tag#(item#, 42)

' Retrieve later
let id = layout_tag(item#)
```

---

### Invalidation

| Function | Description |
|----------|-------------|
| `layout_invalidate#(layout#)` | Force layout to repaint |

```basic
' After changing visual properties, force repaint
layout_invalidate#(myLayout#)
```

---

## Event Callbacks

### Available Events

| Event | Callback Signature | Description |
|-------|-------------------|-------------|
| OnClick | `funcname(sender#)` | Layout was clicked |
| OnDblClick | `funcname(sender#)` | Layout was double-clicked |
| OnMouseDown | `funcname(sender#, button, x, y, shift$)` | Mouse button pressed |
| OnMouseUp | `funcname(sender#, button, x, y, shift$)` | Mouse button released |
| OnMouseMove | `funcname(sender#, x, y, shift$)` | Mouse moved over layout |
| OnMouseEnter | `funcname(sender#)` | Mouse entered layout |
| OnMouseLeave | `funcname(sender#)` | Mouse left layout |
| OnMouseWheel | `funcname(sender#, delta, shift$)` | Mouse wheel scrolled (return 1 to handle) |
| OnResize | `funcname(sender#, width, height)` | Layout is being resized |
| OnResized | `funcname(sender#, width, height)` | Layout resize completed |
| OnPaint | `funcname(sender#, left, top, right, bottom)` | Layout needs repainting |

### Mouse Button Values
- 0 = Left button
- 1 = Right button
- 2 = Middle button

### Shift State String
The shift$ parameter contains modifier key flags:
- `S` = Shift key pressed
- `C` = Ctrl key pressed
- `A` = Alt key pressed
- `M` = Command key pressed (macOS)
- `L` = Left mouse button down
- `R` = Right mouse button down
- `X` = Middle mouse button down

### Setting Event Handlers

| Function | Description |
|----------|-------------|
| `layout_onclick#(layout#, funcname$)` | Set OnClick handler |
| `layout_onclick$(layout#)` | Get OnClick handler name |
| `layout_ondblclick#(layout#, funcname$)` | Set OnDblClick handler |
| `layout_ondblclick$(layout#)` | Get OnDblClick handler name |
| `layout_onmousedown#(layout#, funcname$)` | Set OnMouseDown handler |
| `layout_onmousedown$(layout#)` | Get OnMouseDown handler name |
| `layout_onmouseup#(layout#, funcname$)` | Set OnMouseUp handler |
| `layout_onmouseup$(layout#)` | Get OnMouseUp handler name |
| `layout_onmousemove#(layout#, funcname$)` | Set OnMouseMove handler |
| `layout_onmousemove$(layout#)` | Get OnMouseMove handler name |
| `layout_onmouseenter#(layout#, funcname$)` | Set OnMouseEnter handler |
| `layout_onmouseenter$(layout#)` | Get OnMouseEnter handler name |
| `layout_onmouseleave#(layout#, funcname$)` | Set OnMouseLeave handler |
| `layout_onmouseleave$(layout#)` | Get OnMouseLeave handler name |
| `layout_onmousewheel#(layout#, funcname$)` | Set OnMouseWheel handler |
| `layout_onmousewheel$(layout#)` | Get OnMouseWheel handler name |
| `layout_onresize#(layout#, funcname$)` | Set OnResize handler |
| `layout_onresize$(layout#)` | Get OnResize handler name |
| `layout_onresized#(layout#, funcname$)` | Set OnResized handler |
| `layout_onresized$(layout#)` | Get OnResized handler name |
| `layout_onpaint#(layout#, funcname$)` | Set OnPaint handler |
| `layout_onpaint$(layout#)` | Get OnPaint handler name |
| `layout_clearcallbacks#(layout#)` | Clear all event handlers |

---

## Complete Examples

### Example 1: Simple Layout Structure

```basic
' Simple layout structure with header, sidebar, and content

' Create main form
let frm# = form#("Layout Example", 800, 600)

' Main container (fills form)
let main# = layout#(frm#)
layout_align#(main#, 9)

' Header bar
let header# = layout#(main#)
layout_align#(header#, 1)
layout_height#(header#, 60)
layout_padding#(header#, 10)

' Sidebar
let sidebar# = layout#(main#)
layout_align#(sidebar#, 2)
layout_width#(sidebar#, 200)
layout_padding#(sidebar#, 10)

' Content area (fills remaining space)
let content# = layout#(main#)
layout_align#(content#, 9)
layout_padding#(content#, 20)

' Show form
form_show(frm#)

println "Layout structure created!"
println "Header height: " + stri$(layout_height(header#))
println "Sidebar width: " + stri$(layout_width(sidebar#))
```

### Example 2: Interactive Layout with Events

```basic
' Interactive layout with mouse tracking

let frm# = form#("Mouse Tracker", 600, 400)

let trackArea# = layout#(frm#)
layout_align#(trackArea#, 9)
layout_margin#(trackArea#, 20)
layout_hittest#(trackArea#, 1)

' Set up event handlers
layout_onclick#(trackArea#, "OnAreaClick")
layout_onmousemove#(trackArea#, "OnAreaMouseMove")
layout_onmouseenter#(trackArea#, "OnAreaEnter")
layout_onmouseleave#(trackArea#, "OnAreaLeave")

let mouseX = 0
let mouseY = 0
let isInside = 0

form_show(frm#)

' Event handlers
function OnAreaClick(sender#)
  println "Clicked at: " + stri$(mouseX) + ", " + stri$(mouseY)
endfunction

function OnAreaMouseMove(sender#, x, y, shift$)
  mouseX = x
  mouseY = y
  if shift$ <> "" then
    println "Moving at " + stri$(x) + "," + stri$(y) + " with " + shift$
  endif
endfunction

function OnAreaEnter(sender#)
  isInside = 1
  println "Mouse entered tracking area"
endfunction

function OnAreaLeave(sender#)
  isInside = 0
  println "Mouse left tracking area"
endfunction
```

### Example 3: Nested Layouts with Spacing

```basic
' Demonstrate margins and padding with nested layouts

let frm# = form#("Spacing Demo", 600, 500)

' Outer container with padding
let outer# = layout#(frm#)
layout_align#(outer#, 9)
layout_padding#(outer#, 20)

' Create 3 rows
let row1# = layout#(outer#)
layout_align#(row1#, 1)
layout_height#(row1#, 100)
layout_marginbottom#(row1#, 10)

let row2# = layout#(outer#)
layout_align#(row2#, 1)
layout_height#(row2#, 100)
layout_marginbottom#(row2#, 10)

let row3# = layout#(outer#)
layout_align#(row3#, 1)
layout_height#(row3#, 100)

' Add columns to row1
let col1# = layout#(row1#)
layout_align#(col1#, 2)
layout_width#(col1#, 150)
layout_marginright#(col1#, 10)

let col2# = layout#(row1#)
layout_align#(col2#, 9)

form_show(frm#)

println "Nested layout with spacing created"
println "Outer padding: " + stri$(layout_paddingleft(outer#))
println "Row1 bottom margin: " + stri$(layout_marginbottom(row1#))
```

### Example 4: Dynamic Layout Creation

```basic
' Create layouts dynamically based on data

let frm# = form#("Dynamic Layouts", 800, 600)

let container# = layout#(frm#)
layout_align#(container#, 9)
layout_padding#(container#, 10)

' Create 5 rows dynamically
let numRows = 5
let rowHeight = 80

for i = 1 to numRows
  let row# = layout#(container#)
  layout_align#(row#, 1)
  layout_height#(row#, rowHeight)
  layout_marginbottom#(row#, 5)
  layout_tag#(row#, i)
  
  ' Set click handler
  layout_onclick#(row#, "OnRowClick")
  layout_hittest#(row#, 1)
next

form_show(frm#)

function OnRowClick(sender#)
  local rowId
  rowId = layout_tag(sender#)
  println "Row " + stri$(rowId) + " clicked!"
endfunction
```

### Example 5: Resizable Panels

```basic
' Respond to resize events

let frm# = form#("Resizable Demo", 800, 600)

let panel# = layout#(frm#)
layout_align#(panel#, 9)
layout_margin#(panel#, 50)
layout_onresized#(panel#, "OnPanelResized")

form_show(frm#)

function OnPanelResized(sender#, w, h)
  println "Panel resized to: " + stri$(w) + " x " + stri$(h)
  
  ' Adjust child layouts based on new size
  if w < 400 then
    println "  -> Narrow mode"
  else
    println "  -> Wide mode"
  endif
endfunction
```

---

## Best Practices

### 1. Use Alignment Instead of Manual Positioning
When possible, use alignment values instead of setting X/Y coordinates manually. This ensures your layout adapts to different screen sizes and form resizing.

```basic
' Good: Uses alignment
layout_align#(sidebar#, 2)
layout_width#(sidebar#, 200)

' Avoid: Manual positioning (doesn't adapt)
layout_x#(sidebar#, 0)
layout_y#(sidebar#, 0)
layout_height#(sidebar#, 600)
```

### 2. Build Layouts Hierarchically
Create parent containers first, then add children. This makes it easier to manage complex layouts.

```basic
let main# = layout#(frm#)
let header# = layout#(main#)
let content# = layout#(main#)
let sidebar# = layout#(content#)
let mainArea# = layout#(content#)
```

### 3. Use Padding for Internal Spacing
Use padding on parent layouts to create space around child controls.

```basic
layout_padding#(container#, 15)
```

### 4. Use Margins for External Spacing
Use margins to create space between sibling layouts.

```basic
layout_marginbottom#(row#, 10)
```

### 5. Enable HitTest Only When Needed
By default, TLayout has HitTest enabled. Disable it for purely decorative or structural layouts to improve performance.

```basic
layout_hittest#(decorativeLayout#, 0)
```

### 6. Clean Up Resources
Free layouts when no longer needed, especially in dynamic applications.

```basic
layout_free(tempLayout#)
```

---

## Related Libraries

- **FormLib** - Form management (required as parent for layouts)
- **RectangleLib** - Visual rectangle controls (coming soon)
- **LabelLib** - Text labels (coming soon)
- **ButtonLib** - Button controls (coming soon)

---

## Version History

### 1.0.0 (Current)
- Initial release
- 78 functions for layout management
- Complete event support
- Cross-platform compatibility

---

*Copyright (c) 2024-2026 André Murta*
