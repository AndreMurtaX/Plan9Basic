# LayoutLib - Layout Container Library for Plan9Basic

## Overview

LayoutLib provides container controls for organizing and grouping other controls in Plan9Basic programs. Layouts are invisible containers that help structure your user interface.

**Version:** 1.0.0  
**Function Count:** 85 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("Layout Demo", 600, 400)
form_position#(frm#, 4)

' Create a layout container
let lay# = layout#(frm#, 50, 50, 500, 300)

' Add controls to the layout
let btn1# = button#(lay#, "Button 1", 10, 10, 100, 30)
let btn2# = button#(lay#, "Button 2", 10, 50, 100, 30)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
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
| 9 | Client (fill parent) |
| 11 | Center |

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `layout_error()` | Returns last error code (0 = no error) |
| `layout_errormsg$()` | Returns last error message |
| `layout_strerror$(code)` | Converts error code to message |
| `layout_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `layout#(parent#)` | Create layout with default size (100x100) |
| `layout#(parent#, w, h)` | Create with specified size |
| `layout#(parent#, x, y, w, h)` | Create with position and size |
| `layout_free(lay#)` | Destroy layout and its children |

### Position and Size

| Function | Description |
|----------|-------------|
| `layout_x(lay#)` / `layout_x#(lay#, x)` | Get/set X position |
| `layout_y(lay#)` / `layout_y#(lay#, y)` | Get/set Y position |
| `layout_width(lay#)` / `layout_width#(lay#, w)` | Get/set width |
| `layout_height(lay#)` / `layout_height#(lay#, h)` | Get/set height |
| `layout_bounds#(lay#, x, y, w, h)` | Set position and size |
| `layout_move#(lay#, x, y)` | Set position only |
| `layout_size#(lay#, w, h)` | Set size only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `layout_align(lay#)` / `layout_align#(lay#, value)` | Get/set alignment |
| `layout_marginleft(lay#)` / `layout_marginleft#(lay#, value)` | Get/set left margin |
| `layout_margintop(lay#)` / `layout_margintop#(lay#, value)` | Get/set top margin |
| `layout_marginright(lay#)` / `layout_marginright#(lay#, value)` | Get/set right margin |
| `layout_marginbottom(lay#)` / `layout_marginbottom#(lay#, value)` | Get/set bottom margin |
| `layout_margins#(lay#, l, t, r, b)` | Set all margins |
| `layout_margin#(lay#, value)` | Set uniform margin |

### Padding

| Function | Description |
|----------|-------------|
| `layout_paddingleft(lay#)` / `layout_paddingleft#(lay#, value)` | Get/set left padding |
| `layout_paddingtop(lay#)` / `layout_paddingtop#(lay#, value)` | Get/set top padding |
| `layout_paddingright(lay#)` / `layout_paddingright#(lay#, value)` | Get/set right padding |
| `layout_paddingbottom(lay#)` / `layout_paddingbottom#(lay#, value)` | Get/set bottom padding |
| `layout_paddings#(lay#, l, t, r, b)` | Set all padding at once |
| `layout_padding#(lay#, value)` | Set uniform padding (all sides equal) |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `layout_visible(lay#)` / `layout_visible#(lay#, value)` | Get/set visibility (0/1) |
| `layout_enabled(lay#)` / `layout_enabled#(lay#, value)` | Get/set enabled state (0/1) |
| `layout_opacity(lay#)` / `layout_opacity#(lay#, value)` | Get/set opacity (0.0-1.0) |
| `layout_hittest(lay#)` / `layout_hittest#(lay#, value)` | Get/set hit test (0/1) |
| `layout_clipchildren(lay#)` / `layout_clipchildren#(lay#, value)` | Get/set clip children (0/1) |
| `layout_locked(lay#)` / `layout_locked#(lay#, value)` | Get/set locked state (0/1) |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `layout_tag(lay#)` / `layout_tag#(lay#, value)` | Get/set tag value |
| `layout_parent#(lay#)` | Get parent |
| `layout_parent#(lay#, parent#)` | Set parent |
| `layout_bringtofront#(lay#)` | Bring to front |
| `layout_sendtoback#(lay#)` | Send to back |
| `layout_invalidate#(lay#)` | Force redraw of the layout |
| `layout_clearcallbacks#(lay#)` | Disconnects all event callbacks |

### Children Management

| Function | Description |
|----------|-------------|
| `layout_childcount(lay#)` | Get number of children |
| `layout_child#(lay#, index)` | Get child at index (0-based) |

---

## Event Callbacks

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `layout_onclick#(lay#, func$)` | `layout_onclick$(lay#)` | `function(sender#)` |
| OnDblClick | `layout_ondblclick#(lay#, func$)` | `layout_ondblclick$(lay#)` | `function(sender#)` |
| OnMouseDown | `layout_onmousedown#(lay#, func$)` | `layout_onmousedown$(lay#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `layout_onmouseup#(lay#, func$)` | `layout_onmouseup$(lay#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `layout_onmousemove#(lay#, func$)` | `layout_onmousemove$(lay#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `layout_onmouseenter#(lay#, func$)` | `layout_onmouseenter$(lay#)` | `function(sender#)` |
| OnMouseLeave | `layout_onmouseleave#(lay#, func$)` | `layout_onmouseleave$(lay#)` | `function(sender#)` |
| OnMouseWheel | `layout_onmousewheel#(lay#, func$)` | `layout_onmousewheel$(lay#)` | `function(sender#, delta)` |
| OnResize | `layout_onresize#(lay#, func$)` | `layout_onresize$(lay#)` | `function(sender#)` |
| OnResized | `layout_onresized#(lay#, func$)` | `layout_onresized$(lay#)` | `function(sender#)` |
| OnPaint | `layout_onpaint#(lay#, func$)` | `layout_onpaint$(lay#)` | `function(sender#, canvas#)` |

Use `layout_clearcallbacks#(lay#)` to disconnect all events.

---

## Complete Examples

### Toolbar Layout

```basic
let frm# = form#("Toolbar Demo", 600, 400)
form_position#(frm#, 4)

' Toolbar at top
let toolbar# = layout#(frm#, 600, 40)
layout_align#(toolbar#, 1)  ' Top alignment

let btnNew# = button#(toolbar#, "New", 5, 5, 60, 30)
let btnOpen# = button#(toolbar#, "Open", 70, 5, 60, 30)
let btnSave# = button#(toolbar#, "Save", 135, 5, 60, 30)

' Content area
let content# = layout#(frm#, 600, 360)
layout_align#(content#, 9)  ' Client fill

let lblContent# = label#(content#, "Content area")
label_move#(lblContent#, 250, 150)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

### Sidebar Layout

```basic
let frm# = form#("Sidebar Demo", 800, 500)
form_position#(frm#, 4)

' Left sidebar
let sidebar# = layout#(frm#, 200, 500)
layout_align#(sidebar#, 2)  ' Left alignment

let btn1# = button#(sidebar#, "Menu 1", 10, 20, 180, 35)
let btn2# = button#(sidebar#, "Menu 2", 10, 60, 180, 35)
let btn3# = button#(sidebar#, "Menu 3", 10, 100, 180, 35)

' Main content
let main# = layout#(frm#, 600, 500)
layout_align#(main#, 9)  ' Client fill

let lblMain# = label#(main#, "Main Content Area")
label_move#(lblMain#, 200, 200)
label_fontsize#(lblMain#, 20)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

### Nested Layouts

```basic
let frm# = form#("Nested Layouts", 600, 400)
form_position#(frm#, 4)

' Outer container
let outer# = layout#(frm#, 20, 20, 560, 360)

' Top section
let top# = layout#(outer#, 0, 0, 560, 100)
let lblTop# = label#(top#, "Header Section")
label_move#(lblTop#, 220, 40)
label_fontsize#(lblTop#, 18)

' Bottom section with two columns
let bottom# = layout#(outer#, 0, 110, 560, 250)

' Left column
let leftCol# = layout#(bottom#, 0, 0, 275, 250)
let lblLeft# = label#(leftCol#, "Left Column")
label_move#(lblLeft#, 100, 100)

' Right column
let rightCol# = layout#(bottom#, 285, 0, 275, 250)
let lblRight# = label#(rightCol#, "Right Column")
label_move#(lblRight#, 100, 100)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

### Clipping Demo

```basic
let frm# = form#("Clipping Demo", 400, 300)
form_position#(frm#, 4)

' Layout with clipping enabled
let lay# = layout#(frm#, 50, 50, 200, 150)
layout_clipchildren#(lay#, 1)

' Large label that extends beyond layout bounds
let lbl# = label#(lay#, "This is a very long text that will be clipped")
label_bounds#(lbl#, 10, 60, 300, 30)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

---

## Tips and Best Practices

1. **Use Align for responsive layouts** - Controls resize with parent
2. **Enable Clipping** - Prevents children from drawing outside bounds
3. **Nest layouts** - Create complex structures with simple containers
4. **Use Padding** - Add space between layout edge and children
5. **Use Margins** - Add space between layout and siblings
6. **Layouts are invisible** - Use Panel if you need a visible container

---

## See Also

- **FormLib** - Form management
- **PanelLib** - Visible container with background
- **LabelLib** - Text labels
- **ButtonLib** - Button controls

---

*LayoutLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
