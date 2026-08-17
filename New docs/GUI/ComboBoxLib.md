# ComboBoxLib - Selection Control for Plan9Basic

## Overview

This document covers the selection control:

- **ComboBox** - A dropdown list showing one item with expandable list

---

# ComboBoxLib - Dropdown List Control

**Version:** 1.0.0
**Function Count:** 101 functions

## Quick Start

```basic
let frm# = form#("ComboBox Demo", 400, 300)
form_position#(frm#, 4)

let cb# = combobox#(frm#, 50, 50, 200, 30)

combobox_add(cb#, "Apple")
combobox_add(cb#, "Banana")
combobox_add(cb#, "Cherry")

combobox_itemindex#(cb#, 0)  ' Select first item
combobox_onchange#(cb#, "OnSelectionChanged")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnSelectionChanged(sender#) local text$
  text$ = combobox_selected$(sender#)
  println "Selected: " + text$
endfunction
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

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `combobox_error()` | Get last error code (0 = no error) |
| `combobox_errormsg$()` | Get last error message |
| `combobox_strerror$(code)` | Convert error code to message |
| `combobox_clearerror()` | Clear error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `combobox#(parent#)` | Create at (0,0) with default size |
| `combobox#(parent#, x, y, w, h)` | Create with position and size |
| `combobox_free(cb#)` | Destroy combobox |

### Items Management

| Function | Description |
|----------|-------------|
| `combobox_add(cb#, text$)` | Add item to end, returns index |
| `combobox_insert(cb#, index, text$)` | Insert at index |
| `combobox_delete(cb#, index)` | Delete at index |
| `combobox_clear(cb#)` | Remove all items |
| `combobox_count(cb#)` | Get item count |
| `combobox_item$(cb#, index)` | Get item text at index |
| `combobox_item#(cb#, index, text$)` | Set item text at index |
| `combobox_indexof(cb#, text$)` | Find by text, returns index (-1 if not found) |

### Selection

| Function | Description |
|----------|-------------|
| `combobox_itemindex(cb#)` | Get selected index (-1 if none) |
| `combobox_itemindex#(cb#, index)` | Set selected index |
| `combobox_selected$(cb#)` | Get selected text |
| `combobox_dropdowncount(cb#)` | Get number of visible items in dropdown |
| `combobox_dropdowncount#(cb#, count)` | Set number of visible items in dropdown |

### Position and Size

| Function | Description |
|----------|-------------|
| `combobox_x(cb#)` / `combobox_x#(cb#, x)` | Get/set X position |
| `combobox_y(cb#)` / `combobox_y#(cb#, y)` | Get/set Y position |
| `combobox_width(cb#)` / `combobox_width#(cb#, w)` | Get/set width |
| `combobox_height(cb#)` / `combobox_height#(cb#, h)` | Get/set height |
| `combobox_bounds#(cb#, x, y, w, h)` | Set position and size |
| `combobox_move#(cb#, x, y)` | Set position only |
| `combobox_size#(cb#, w, h)` | Set size only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `combobox_align(cb#)` / `combobox_align#(cb#, value)` | Get/set alignment |
| `combobox_marginleft(cb#)` / `combobox_marginleft#(cb#, value)` | Get/set left margin |
| `combobox_margintop(cb#)` / `combobox_margintop#(cb#, value)` | Get/set top margin |
| `combobox_marginright(cb#)` / `combobox_marginright#(cb#, value)` | Get/set right margin |
| `combobox_marginbottom(cb#)` / `combobox_marginbottom#(cb#, value)` | Get/set bottom margin |
| `combobox_margins#(cb#, l, t, r, b)` | Set all margins |
| `combobox_margin#(cb#, value)` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `combobox_visible(cb#)` / `combobox_visible#(cb#, value)` | Get/set visibility (0/1) |
| `combobox_enabled(cb#)` / `combobox_enabled#(cb#, value)` | Get/set enabled state (0/1) |
| `combobox_opacity(cb#)` / `combobox_opacity#(cb#, value)` | Get/set opacity (0.0-1.0) |
| `combobox_hittest(cb#)` / `combobox_hittest#(cb#, value)` | Get/set hit test (0/1) |
| `combobox_dragmode(cb#)` / `combobox_dragmode#(cb#, value)` | Get/set drag mode (0/1) |

### Focus

| Function | Description |
|----------|-------------|
| `combobox_isfocused(cb#)` | Check if focused (0/1) |
| `combobox_setfocus#(cb#)` | Set focus to combobox |
| `combobox_resetfocus#(cb#)` | Remove focus from combobox |
| `combobox_taborder(cb#)` / `combobox_taborder#(cb#, value)` | Get/set tab order |
| `combobox_canfocus(cb#)` / `combobox_canfocus#(cb#, value)` | Get/set can focus (0/1) |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `combobox_tag(cb#)` / `combobox_tag#(cb#, value)` | Get/set tag value |
| `combobox_parent#(cb#)` | Get parent |
| `combobox_parent#(cb#, parent#)` | Set parent |
| `combobox_bringtofront#(cb#)` | Bring to front of z-order |
| `combobox_sendtoback#(cb#)` | Send to back of z-order |

---

## Event Callbacks

### Basic Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnChange | `combobox_onchange#(cb#, func$)` | `combobox_onchange$(cb#)` | `function(sender#)` |
| OnClick | `combobox_onclick#(cb#, func$)` | `combobox_onclick$(cb#)` | `function(sender#)` |
| OnDblClick | `combobox_ondblclick#(cb#, func$)` | `combobox_ondblclick$(cb#)` | `function(sender#)` |
| OnEnter | `combobox_onenter#(cb#, func$)` | `combobox_onenter$(cb#)` | `function(sender#)` |
| OnExit | `combobox_onexit#(cb#, func$)` | `combobox_onexit$(cb#)` | `function(sender#)` |

### Keyboard Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnKeyDown | `combobox_onkeydown#(cb#, func$)` | `combobox_onkeydown$(cb#)` | `function(sender#, key, keychar$, shift$)` |
| OnKeyUp | `combobox_onkeyup#(cb#, func$)` | `combobox_onkeyup$(cb#)` | `function(sender#, key, keychar$, shift$)` |

### Mouse Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnMouseDown | `combobox_onmousedown#(cb#, func$)` | `combobox_onmousedown$(cb#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `combobox_onmouseup#(cb#, func$)` | `combobox_onmouseup$(cb#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `combobox_onmousemove#(cb#, func$)` | `combobox_onmousemove$(cb#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `combobox_onmouseenter#(cb#, func$)` | `combobox_onmouseenter$(cb#)` | `function(sender#)` |
| OnMouseLeave | `combobox_onmouseleave#(cb#, func$)` | `combobox_onmouseleave$(cb#)` | `function(sender#)` |
| OnResize | `combobox_onresize#(cb#, func$)` | `combobox_onresize$(cb#)` | `function(sender#)` |

### Drag Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnDragEnter | `combobox_ondragenter#(cb#, func$)` | `combobox_ondragenter$(cb#)` | `function(sender#, x, y)` |
| OnDragOver | `combobox_ondragover#(cb#, func$)` | `combobox_ondragover$(cb#)` | `function(sender#, x, y)` |
| OnDragDrop | `combobox_ondragdrop#(cb#, func$)` | `combobox_ondragdrop$(cb#)` | `function(sender#, x, y)` |
| OnDragLeave | `combobox_ondragleave#(cb#, func$)` | `combobox_ondragleave$(cb#)` | `function(sender#)` |

### Utility

| Function | Description |
|----------|-------------|
| `combobox_clearcallbacks#(cb#)` | Disconnect all event callbacks |

---

## ComboBox Examples

### Country Selection

```basic
let frm# = form#("Country Selector", 400, 200)
form_position#(frm#, 4)

let lblCountry# = label#(frm#, "Select your country:")
label_move#(lblCountry#, 50, 30)

let cbCountry# = combobox#(frm#, 50, 55, 200, 30)
combobox_add(cbCountry#, "United States")
combobox_add(cbCountry#, "United Kingdom")
combobox_add(cbCountry#, "Canada")
combobox_add(cbCountry#, "Australia")
combobox_add(cbCountry#, "Germany")
combobox_add(cbCountry#, "Brazil")

combobox_dropdowncount#(cbCountry#, 6)
combobox_onchange#(cbCountry#, "OnCountrySelected")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnCountrySelected(sender#)
  println "You selected: " + combobox_selected$(sender#)
endfunction
```

### Linked ComboBoxes (Country → City)

```basic
let cbCountry# = Pointer#(0)
let cbCity# = Pointer#(0)

let frm# = form#("Location", 400, 200)
form_position#(frm#, 4)

label#(frm#, "Country:", 50, 20)
cbCountry# = combobox#(frm#, 50, 45, 200, 30)
combobox_add(cbCountry#, "USA")
combobox_add(cbCountry#, "UK")
combobox_add(cbCountry#, "Brazil")
combobox_onchange#(cbCountry#, "OnCountryChanged")

label#(frm#, "City:", 50, 90)
cbCity# = combobox#(frm#, 50, 115, 200, 30)
combobox_enabled#(cbCity#, 0)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnCountryChanged(sender#) local country$
  country$ = combobox_selected$(sender#)
  combobox_clear(cbCity#)

  if country$ = "USA" then
    combobox_add(cbCity#, "New York")
    combobox_add(cbCity#, "Los Angeles")
    combobox_add(cbCity#, "Chicago")
  elseif country$ = "UK" then
    combobox_add(cbCity#, "London")
    combobox_add(cbCity#, "Manchester")
  elseif country$ = "Brazil" then
    combobox_add(cbCity#, "São Paulo")
    combobox_add(cbCity#, "Rio de Janeiro")
  endif

  combobox_enabled#(cbCity#, 1)
  combobox_itemindex#(cbCity#, 0)
endfunction
```

---

## See Also

- **FormLib** - Form management
- **ListBoxLib** - Scrollable list selection
- **EditLib** - Text input
- **ButtonLib** - Button controls

---

*ComboBoxLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
