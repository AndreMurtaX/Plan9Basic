# PanelLib - Panel Container Library for Plan9Basic

## Overview

PanelLib provides visible container controls for organizing and grouping other controls in Plan9Basic programs. Panels have a background and can be styled, unlike the invisible Layout control.

**Version:** 1.0.0  
**Function Count:** 91 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("Panel Demo", 600, 400)
form_position#(frm#, 4)

' Create a panel with background
let pnl# = panel#(frm#, 50, 50, 500, 300)

' Add controls to the panel
let lbl# = label#(pnl#, "This is inside a panel")
label_move#(lbl#, 20, 20)

let btn# = button#(pnl#, "Click Me", 20, 60, 100, 35)

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
| `panel_error()` | Returns last error code (0 = no error) |
| `panel_errormsg$()` | Returns last error message |
| `panel_strerror$(code)` | Converts error code to message |
| `panel_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `panel#(parent#)` | Create with default size (100x100) |
| `panel#(parent#, w, h)` | Create with specified size |
| `panel#(parent#, x, y, w, h)` | Create with position and size |
| `panel_free(pnl#)` | Destroy panel and its children |

### Position and Size

| Function | Description |
|----------|-------------|
| `panel_x(pnl#)` / `panel_x#(pnl#, x)` | Get/set X position |
| `panel_y(pnl#)` / `panel_y#(pnl#, y)` | Get/set Y position |
| `panel_width(pnl#)` / `panel_width#(pnl#, w)` | Get/set width |
| `panel_height(pnl#)` / `panel_height#(pnl#, h)` | Get/set height |
| `panel_bounds#(pnl#, x, y, w, h)` | Set position and size |
| `panel_move#(pnl#, x, y)` | Set position only |
| `panel_size#(pnl#, w, h)` | Set size only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `panel_align(pnl#)` / `panel_align#(pnl#, value)` | Get/set alignment |
| `panel_marginleft(pnl#)` / `panel_marginleft#(pnl#, value)` | Get/set left margin |
| `panel_margintop(pnl#)` / `panel_margintop#(pnl#, value)` | Get/set top margin |
| `panel_marginright(pnl#)` / `panel_marginright#(pnl#, value)` | Get/set right margin |
| `panel_marginbottom(pnl#)` / `panel_marginbottom#(pnl#, value)` | Get/set bottom margin |
| `panel_margins#(pnl#, l, t, r, b)` | Set all margins |
| `panel_margin#(pnl#, value)` | Set uniform margin |

### Padding

| Function | Description |
|----------|-------------|
| `panel_paddingleft(pnl#)` / `panel_paddingleft#(pnl#, value)` | Get/set left padding |
| `panel_paddingtop(pnl#)` / `panel_paddingtop#(pnl#, value)` | Get/set top padding |
| `panel_paddingright(pnl#)` / `panel_paddingright#(pnl#, value)` | Get/set right padding |
| `panel_paddingbottom(pnl#)` / `panel_paddingbottom#(pnl#, value)` | Get/set bottom padding |
| `panel_paddings#(pnl#, l, t, r, b)` | Set all padding |
| `panel_padding#(pnl#, value)` | Set uniform padding (all sides equal) |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `panel_visible(pnl#)` / `panel_visible#(pnl#, value)` | Get/set visibility (0/1) |
| `panel_enabled(pnl#)` / `panel_enabled#(pnl#, value)` | Get/set enabled state (0/1) |
| `panel_opacity(pnl#)` / `panel_opacity#(pnl#, value)` | Get/set opacity (0.0-1.0) |
| `panel_hittest(pnl#)` / `panel_hittest#(pnl#, value)` | Get/set hit test (0/1) |
| `panel_clipchildren(pnl#)` / `panel_clipchildren#(pnl#, value)` | Get/set clip children (0/1) |
| `panel_locked(pnl#)` / `panel_locked#(pnl#, value)` | Get/set locked state (0/1) |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `panel_tag(pnl#)` / `panel_tag#(pnl#, value)` | Get/set tag value |
| `panel_parent#(pnl#)` | Get parent |
| `panel_parent#(pnl#, parent#)` | Set parent |
| `panel_bringtofront#(pnl#)` | Bring to front |
| `panel_sendtoback#(pnl#)` | Send to back |
| `panel_invalidate#(pnl#)` | Force redraw of the panel |
| `panel_clearcallbacks#(pnl#)` | Disconnects all event callbacks |

### Children Management

| Function | Description |
|----------|-------------|
| `panel_childcount(pnl#)` | Get number of children |
| `panel_child#(pnl#, index)` | Get child at index (0-based) |

---

## Event Callbacks

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `panel_onclick#(pnl#, func$)` | `panel_onclick$(pnl#)` | `function(sender#)` |
| OnDblClick | `panel_ondblclick#(pnl#, func$)` | `panel_ondblclick$(pnl#)` | `function(sender#)` |
| OnMouseDown | `panel_onmousedown#(pnl#, func$)` | `panel_onmousedown$(pnl#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `panel_onmouseup#(pnl#, func$)` | `panel_onmouseup$(pnl#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `panel_onmousemove#(pnl#, func$)` | `panel_onmousemove$(pnl#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `panel_onmouseenter#(pnl#, func$)` | `panel_onmouseenter$(pnl#)` | `function(sender#)` |
| OnMouseLeave | `panel_onmouseleave#(pnl#, func$)` | `panel_onmouseleave$(pnl#)` | `function(sender#)` |
| OnMouseWheel | `panel_onmousewheel#(pnl#, func$)` | `panel_onmousewheel$(pnl#)` | `function(sender#, delta)` |
| OnResize | `panel_onresize#(pnl#, func$)` | `panel_onresize$(pnl#)` | `function(sender#)` |
| OnResized | `panel_onresized#(pnl#, func$)` | `panel_onresized$(pnl#)` | `function(sender#)` |

### Drag Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnDragEnter | `panel_ondragenter#(pnl#, func$)` | `panel_ondragenter$(pnl#)` | `function(sender#, x, y)` |
| OnDragOver | `panel_ondragover#(pnl#, func$)` | `panel_ondragover$(pnl#)` | `function(sender#, x, y)` |
| OnDragDrop | `panel_ondragdrop#(pnl#, func$)` | `panel_ondragdrop$(pnl#)` | `function(sender#, x, y)` |
| OnDragLeave | `panel_ondragleave#(pnl#, func$)` | `panel_ondragleave$(pnl#)` | `function(sender#)` |

Use `panel_clearcallbacks#(pnl#)` to disconnect all events.

---

## Complete Examples

### Header Panel

```basic
let frm# = form#("Header Demo", 600, 400)
form_position#(frm#, 4)

' Header panel at top
let header# = panel#(frm#, 600, 60)
panel_align#(header#, 1)  ' Top alignment

let lblTitle# = label#(header#, "My Application")
label_move#(lblTitle#, 20, 20)
label_fontsize#(lblTitle#, 18)
label_bold#(lblTitle#, 1)

' Content area
let content# = panel#(frm#, 600, 340)
panel_align#(content#, 9)  ' Client fill

let lblContent# = label#(content#, "Main content goes here")
label_move#(lblContent#, 200, 150)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

### Sidebar Navigation

```basic
let frm# = form#("Sidebar Demo", 800, 500)
form_position#(frm#, 4)

' Sidebar panel
let sidebar# = panel#(frm#, 200, 500)
panel_align#(sidebar#, 2)  ' Left alignment

let btn1# = button#(sidebar#, "Dashboard", 10, 20, 180, 40)
let btn2# = button#(sidebar#, "Settings", 10, 70, 180, 40)
let btn3# = button#(sidebar#, "Reports", 10, 120, 180, 40)
let btn4# = button#(sidebar#, "Help", 10, 170, 180, 40)

button_tag#(btn1#, 1)
button_tag#(btn2#, 2)
button_tag#(btn3#, 3)
button_tag#(btn4#, 4)

button_onclick#(btn1#, "OnNav")
button_onclick#(btn2#, "OnNav")
button_onclick#(btn3#, "OnNav")
button_onclick#(btn4#, "OnNav")

' Main content
let main# = panel#(frm#, 600, 500)
panel_align#(main#, 9)  ' Client

let lblPage# = label#(main#, "Dashboard")
label_move#(lblPage#, 250, 200)
label_fontsize#(lblPage#, 24)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnNav(sender#) local tag, page$
  tag = button_tag(sender#)
  
  if tag = 1 then
    page$ = "Dashboard"
  else if tag = 2 then
    page$ = "Settings"
  else if tag = 3 then
    page$ = "Reports"
  else if tag = 4 then
    page$ = "Help"
  endif
  
  label_text#(lblPage#, page$)
endfunction
```

### Card Layout

```basic
let frm# = form#("Card Layout", 700, 400)
form_position#(frm#, 4)

' Create three "cards" using panels
let card1# = panel#(frm#, 30, 50, 200, 280)
let card2# = panel#(frm#, 250, 50, 200, 280)
let card3# = panel#(frm#, 470, 50, 200, 280)

' Card 1 content
let lbl1# = label#(card1#, "Card 1")
label_move#(lbl1#, 70, 20)
label_fontsize#(lbl1#, 16)
label_bold#(lbl1#, 1)

let txt1# = label#(card1#, "Description for card one goes here.")
label_bounds#(txt1#, 10, 60, 180, 150)
label_wordwrap#(txt1#, 1)

let btn1# = button#(card1#, "View", 50, 230, 100, 35)

' Card 2 content
let lbl2# = label#(card2#, "Card 2")
label_move#(lbl2#, 70, 20)
label_fontsize#(lbl2#, 16)
label_bold#(lbl2#, 1)

let txt2# = label#(card2#, "Description for card two goes here.")
label_bounds#(txt2#, 10, 60, 180, 150)
label_wordwrap#(txt2#, 1)

let btn2# = button#(card2#, "View", 50, 230, 100, 35)

' Card 3 content
let lbl3# = label#(card3#, "Card 3")
label_move#(lbl3#, 70, 20)
label_fontsize#(lbl3#, 16)
label_bold#(lbl3#, 1)

let txt3# = label#(card3#, "Description for card three goes here.")
label_bounds#(txt3#, 10, 60, 180, 150)
label_wordwrap#(txt3#, 1)

let btn3# = button#(card3#, "View", 50, 230, 100, 35)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

### Collapsible Panel

```basic
let frm# = form#("Collapsible Panel", 500, 400)
form_position#(frm#, 4)

let btnToggle# = button#(frm#, "Toggle Panel", 20, 20, 120, 35)

let pnl# = panel#(frm#, 20, 70, 460, 200)

let lbl# = label#(pnl#, "This content can be hidden")
label_move#(lbl#, 150, 90)

let expanded = 1

button_onclick#(btnToggle#, "OnToggle")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnToggle(sender#)
  if expanded = 1 then
    panel_visible#(pnl#, 0)
    button_text#(btnToggle#, "Show Panel")
    expanded = 0
  else
    panel_visible#(pnl#, 1)
    button_text#(btnToggle#, "Hide Panel")
    expanded = 1
  endif
endfunction
```

### Status Bar

```basic
let frm# = form#("Status Bar Demo", 600, 400)
form_position#(frm#, 4)

' Main content area
let main# = panel#(frm#, 600, 370)
panel_align#(main#, 9)  ' Client

let lbl# = label#(main#, "Main Application Area")
label_move#(lbl#, 220, 170)

' Status bar at bottom
let status# = panel#(frm#, 600, 30)
panel_align#(status#, 4)  ' Bottom alignment

let lblStatus# = label#(status#, "Ready")
label_move#(lblStatus#, 10, 5)

let lblTime# = label#(status#, "")
label_move#(lblTime#, 500, 5)

' Update time
let ts$ = formatdatetime$("hh:nn:ss", now())
label_text#(lblTime#, ts$)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

---

## Layout vs Panel

| Feature | Layout | Panel |
|---------|--------|-------|
| Visible | No (transparent) | Yes (has background) |
| Background | None | Platform default |
| Use case | Invisible grouping | Visible sections |
| Performance | Lighter | Slightly heavier |

Use **Layout** when you need invisible organization.  
Use **Panel** when you need visible separation or sections.

---

## Tips and Best Practices

1. **Use Align for responsive layouts** - Panels resize with parent
2. **Enable Clipping** - Prevents children from drawing outside bounds
3. **Use Panels for visual sections** - Header, footer, sidebar, cards
4. **Nest panels** - Create complex multi-section layouts
5. **Use Margins for spacing** - Between panel and siblings
6. **Use Padding for content** - Between panel edge and children

---

## See Also

- **FormLib** - Form management
- **LayoutLib** - Invisible container
- **LabelLib** - Text labels
- **ButtonLib** - Button controls

---

*PanelLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
