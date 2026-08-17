# ListBoxLib - ListBox Control Library for Plan9Basic

## Overview

ListBoxLib provides complete functionality for creating and managing list box controls in Plan9Basic programs. ListBox displays a scrollable list of items that users can select.

**Version:** 1.0.0
**Function Count:** 126 functions (121 listbox + 5 listboxitem)

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("ListBox Demo", 400, 300)
form_position#(frm#, 4)

let lst# = listbox#(frm#, 50, 50, 200, 180)

listbox_add(lst#, "Apple")
listbox_add(lst#, "Banana")
listbox_add(lst#, "Cherry")
listbox_add(lst#, "Date")

listbox_onchange#(lst#, "OnSelectionChange")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnSelectionChange(sender#) local idx
  idx = listbox_itemindex(sender#)
  if idx >= 0 then
    println "Selected: " + listbox_item$(sender#, idx)
  endif
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
| `listbox_error()` | Returns last error code (0 = no error) |
| `listbox_errormsg$()` | Returns last error message |
| `listbox_strerror$(code)` | Converts error code to message |
| `listbox_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `listbox#(parent#)` | Create with default size |
| `listbox#(parent#, x, y, w, h)` | Create with position and size |
| `listbox_free(lst#)` | Destroy listbox |

### Item Management

| Function | Description |
|----------|-------------|
| `listbox_add(lst#, item$)` | Add item to end, returns index |
| `listbox_additem#(lst#, item$)` | Add item, returns item pointer |
| `listbox_insert(lst#, index, item$)` | Insert item at index |
| `listbox_delete(lst#, index)` | Delete item at index |
| `listbox_clear(lst#)` | Remove all items |
| `listbox_count(lst#)` | Get number of items |

### Item Access

| Function | Description |
|----------|-------------|
| `listbox_item$(lst#, index)` | Get item text at index |
| `listbox_item#(lst#, index, text$)` | Set item text at index |
| `listbox_itemat#(lst#, index)` | Get item object pointer at index |

### Selection

| Function | Description |
|----------|-------------|
| `listbox_itemindex(lst#)` | Get selected index (-1 if none) |
| `listbox_itemindex#(lst#, index)` | Set selected index |
| `listbox_selected$(lst#)` | Get selected item text |
| `listbox_indexof(lst#, text$)` | Find index of item by text (-1 if not found) |

### Multi-Select

| Function | Description |
|----------|-------------|
| `listbox_multiselect(lst#)` | Get multi-select mode (0/1) |
| `listbox_multiselect#(lst#, value)` | Set multi-select mode |
| `listbox_isselected(lst#, index)` | Check if item is selected (0/1) |
| `listbox_selectitem#(lst#, index, selected)` | Set item selection state |
| `listbox_selectall(lst#)` | Select all items |
| `listbox_clearselection(lst#)` | Deselect all items |
| `listbox_selcount(lst#)` | Get number of selected items |

### Position and Size

| Function | Description |
|----------|-------------|
| `listbox_x(lst#)` / `listbox_x#(lst#, x)` | Get/set X position |
| `listbox_y(lst#)` / `listbox_y#(lst#, y)` | Get/set Y position |
| `listbox_width(lst#)` / `listbox_width#(lst#, w)` | Get/set width |
| `listbox_height(lst#)` / `listbox_height#(lst#, h)` | Get/set height |
| `listbox_bounds#(lst#, x, y, w, h)` | Set position and size |
| `listbox_move#(lst#, x, y)` | Set position only |
| `listbox_size#(lst#, w, h)` | Set size only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `listbox_align(lst#)` / `listbox_align#(lst#, value)` | Get/set alignment |
| `listbox_marginleft(lst#)` / `listbox_marginleft#(lst#, value)` | Get/set left margin |
| `listbox_margintop(lst#)` / `listbox_margintop#(lst#, value)` | Get/set top margin |
| `listbox_marginright(lst#)` / `listbox_marginright#(lst#, value)` | Get/set right margin |
| `listbox_marginbottom(lst#)` / `listbox_marginbottom#(lst#, value)` | Get/set bottom margin |
| `listbox_margins#(lst#, l, t, r, b)` | Set all margins |
| `listbox_margin#(lst#, value)` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `listbox_visible(lst#)` / `listbox_visible#(lst#, value)` | Get/set visibility (0/1) |
| `listbox_enabled(lst#)` / `listbox_enabled#(lst#, value)` | Get/set enabled state (0/1) |
| `listbox_opacity(lst#)` / `listbox_opacity#(lst#, value)` | Get/set opacity (0.0-1.0) |
| `listbox_hittest(lst#)` / `listbox_hittest#(lst#, value)` | Get/set hit test (0/1) |
| `listbox_dragmode(lst#)` / `listbox_dragmode#(lst#, value)` | Get/set drag mode (0/1) |

### Focus

| Function | Description |
|----------|-------------|
| `listbox_focus(lst#)` | Set focus to listbox |
| `listbox_isfocused(lst#)` | Check if focused (0/1) |
| `listbox_taborder(lst#)` / `listbox_taborder#(lst#, value)` | Get/set tab order |
| `listbox_canfocus(lst#)` / `listbox_canfocus#(lst#, value)` | Get/set can focus (0/1) |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `listbox_tag(lst#)` / `listbox_tag#(lst#, value)` | Get/set tag value |
| `listbox_parent#(lst#)` | Get parent |
| `listbox_parent#(lst#, parent#)` | Set parent |

---

## Event Callbacks

### Basic Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnChange | `listbox_onchange#(lst#, func$)` | `listbox_onchange$(lst#)` | `function(sender#)` |
| OnItemClick | `listbox_onitemclick#(lst#, func$)` | `listbox_onitemclick$(lst#)` | `function(sender#, item#)` |
| OnClick | `listbox_onclick#(lst#, func$)` | `listbox_onclick$(lst#)` | `function(sender#)` |
| OnDblClick | `listbox_ondblclick#(lst#, func$)` | `listbox_ondblclick$(lst#)` | `function(sender#)` |
| OnEnter | `listbox_onenter#(lst#, func$)` | `listbox_onenter$(lst#)` | `function(sender#)` |
| OnExit | `listbox_onexit#(lst#, func$)` | `listbox_onexit$(lst#)` | `function(sender#)` |

### Keyboard Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnKeyDown | `listbox_onkeydown#(lst#, func$)` | `listbox_onkeydown$(lst#)` | `function(sender#, key, keychar$, shift$)` |
| OnKeyUp | `listbox_onkeyup#(lst#, func$)` | `listbox_onkeyup$(lst#)` | `function(sender#, key, keychar$, shift$)` |

### Mouse Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnMouseDown | `listbox_onmousedown#(lst#, func$)` | `listbox_onmousedown$(lst#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `listbox_onmouseup#(lst#, func$)` | `listbox_onmouseup$(lst#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `listbox_onmousemove#(lst#, func$)` | `listbox_onmousemove$(lst#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `listbox_onmouseenter#(lst#, func$)` | `listbox_onmouseenter$(lst#)` | `function(sender#)` |
| OnMouseLeave | `listbox_onmouseleave#(lst#, func$)` | `listbox_onmouseleave$(lst#)` | `function(sender#)` |
| OnResize | `listbox_onresize#(lst#, func$)` | `listbox_onresize$(lst#)` | `function(sender#)` |

### Drag Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnDragEnter | `listbox_ondragenter#(lst#, func$)` | `listbox_ondragenter$(lst#)` | `function(sender#, x, y)` |
| OnDragOver | `listbox_ondragover#(lst#, func$)` | `listbox_ondragover$(lst#)` | `function(sender#, x, y)` |
| OnDragDrop | `listbox_ondragdrop#(lst#, func$)` | `listbox_ondragdrop$(lst#)` | `function(sender#, x, y)` |
| OnDragLeave | `listbox_ondragleave#(lst#, func$)` | `listbox_ondragleave$(lst#)` | `function(sender#)` |

### Utility

| Function | Description |
|----------|-------------|
| `listbox_clearcallbacks#(lst#)` | Disconnect all event callbacks |

---

## Font Styling

These functions apply text styling to all current items in the list. Because `TListBox` is a `TStyledControl` without its own `TextSettings`, styling is applied per item — each `TListBoxItem` is a `TTextControl` and supports the same `TextSettings` mechanism used by buttons, labels, and edits.

> **Important:** Font functions apply only to items already in the list at the time of the call. The correct pattern is to populate all items first with `listbox_add`, then call the styling functions.

| Function | Description |
|----------|-------------|
| `listbox_fontcolor$(lst#)` | Get text colour of items (reads from first item) |
| `listbox_fontcolor#(lst#, color$)` | Set text colour of all items (hex, e.g. `"#ffffff"`) |
| `listbox_fontsize(lst#)` | Get font size (reads from first item) |
| `listbox_fontsize#(lst#, size)` | Set font size of all items |
| `listbox_fontfamily$(lst#)` | Get font family (reads from first item) |
| `listbox_fontfamily#(lst#, family$)` | Set font family of all items |
| `listbox_bold(lst#)` | Get bold state (0/1, reads from first item) |
| `listbox_bold#(lst#, value)` | Set bold state of all items (0/1) |
| `listbox_italic(lst#)` | Get italic state (0/1, reads from first item) |
| `listbox_italic#(lst#, value)` | Set italic state of all items (0/1) |
| `listbox_underline(lst#)` | Get underline state (0/1, reads from first item) |
| `listbox_underline#(lst#, value)` | Set underline state of all items (0/1) |
| `listbox_strikeout(lst#)` | Get strikeout state (0/1, reads from first item) |
| `listbox_strikeout#(lst#, value)` | Set strikeout state of all items (0/1) |

### Custom Dark-Theme Dropdown (Edit + ListBox pattern)

Because `TListBox` background cannot be set directly (TStyledControl limitation), use a `rectangle#` placed immediately before the listbox in creation order as a background — FMX natural z-order places the listbox on top automatically.

```basic
' Readonly edit shows selected value
let edt# = edit#(frm#, 10, 10, 160, 30)
edit_readonly#(edt#, 1)
edit_text#(edt#, "random")
edit_fontcolor#(edt#, "#ffffff")

' Arrow button toggles the popup
let btnArrow# = button#(frm#, 170, 10, 30, 30)
button_text#(btnArrow#, "▼")
button_onclick#(btnArrow#, "OnToggle")

' Background rectangle — created before listbox for z-order
let lstBg# = rectangle#(frm#, 10, 42, 190, 150)
rectangle_fill#(lstBg#, "#0f3460")
rectangle_stroke#(lstBg#, "#e94560")
rectangle_visible#(lstBg#, 0)

' Popup listbox — created LAST for z-order
let lst# = listbox#(frm#, 10, 42, 190, 150)
listbox_add(lst#, "random")
listbox_add(lst#, "dev")
listbox_add(lst#, "science")
listbox_fontcolor#(lst#, "#ffffff")   ' style AFTER populating
listbox_visible#(lst#, 0)
listbox_onchange#(lst#, "OnSelected")

let dropOpen = 0

function OnToggle(sender#)
  if dropOpen = 0 then
    listbox_visible#(lst#, 1)
    rectangle_visible#(lstBg#, 1)
    dropOpen = 1
  else
    listbox_visible#(lst#, 0)
    rectangle_visible#(lstBg#, 0)
    dropOpen = 0
  endif
endfunction

function OnSelected(sender#) local sel$
  sel$ = listbox_selected$(sender#)
  edit_text#(edt#, sel$)
  listbox_visible#(lst#, 0)
  rectangle_visible#(lstBg#, 0)
  dropOpen = 0
endfunction
```

---

## ListBoxItem Functions

When you have an item pointer (from `listbox_itemat#` or `listbox_additem#`):

| Function | Description |
|----------|-------------|
| `listboxitem_text$(item#)` | Get item text |
| `listboxitem_text#(item#, text$)` | Set item text |
| `listboxitem_index(item#)` | Get item index in list |
| `listboxitem_isselected(item#)` | Check if item is selected (0/1) |
| `listboxitem_isselected#(item#, value)` | Set item selected state |

---

## Complete Examples

### Simple Selection List

```basic
let frm# = form#("Fruit Selector", 400, 300)
form_position#(frm#, 4)

let lst# = listbox#(frm#, 50, 50, 150, 180)

listbox_add(lst#, "Apple")
listbox_add(lst#, "Banana")
listbox_add(lst#, "Cherry")
listbox_add(lst#, "Date")
listbox_add(lst#, "Elderberry")

let lblSelected# = label#(frm#, "Selected: none")
label_move#(lblSelected#, 220, 100)

listbox_onchange#(lst#, "OnChange")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnChange(sender#) local idx, txt$
  idx = listbox_itemindex(sender#)
  if idx >= 0 then
    txt$ = listbox_item$(sender#, idx)
    label_text#(lblSelected#, "Selected: " + txt$)
  endif
endfunction
```

### Add and Remove Items

```basic
let frm# = form#("List Manager", 500, 350)
form_position#(frm#, 4)

let lst# = listbox#(frm#, 50, 50, 200, 200)

let edt# = edit#(frm#, 50, 270, 200, 28)
edit_prompt#(edt#, "Enter item text...")

let btnAdd# = button#(frm#, "Add", 270, 50, 80, 30)
let btnRemove# = button#(frm#, "Remove", 270, 90, 80, 30)
let btnClear# = button#(frm#, "Clear All", 270, 130, 80, 30)

let lblCount# = label#(frm#, "Items: 0")
label_move#(lblCount#, 270, 180)

button_onclick#(btnAdd#, "OnAdd")
button_onclick#(btnRemove#, "OnRemove")
button_onclick#(btnClear#, "OnClear")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function UpdateCount()
  label_text#(lblCount#, "Items: " + str$(listbox_count(lst#)))
endfunction

function OnAdd(sender#) local txt$
  txt$ = edit_text$(edt#)
  if txt$ <> "" then
    listbox_add(lst#, txt$)
    edit_text#(edt#, "")
    UpdateCount()
  endif
endfunction

function OnRemove(sender#) local idx
  idx = listbox_itemindex(lst#)
  if idx >= 0 then
    listbox_delete(lst#, idx)
    UpdateCount()
  endif
endfunction

function OnClear(sender#)
  listbox_clear(lst#)
  UpdateCount()
endfunction
```

### Search in List

```basic
let frm# = form#("Search Demo", 400, 350)
form_position#(frm#, 4)

let lst# = listbox#(frm#, 50, 50, 200, 200)

listbox_add(lst#, "Apple")
listbox_add(lst#, "Apricot")
listbox_add(lst#, "Banana")
listbox_add(lst#, "Blueberry")
listbox_add(lst#, "Cherry")

let edtSearch# = edit#(frm#, 50, 270, 150, 28)
edit_prompt#(edtSearch#, "Search...")

let btnFind# = button#(frm#, "Find", 210, 270, 60, 28)

let lblResult# = label#(frm#, "")
label_move#(lblResult#, 50, 310)

button_onclick#(btnFind#, "OnFind")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnFind(sender#) local txt$, idx
  txt$ = edit_text$(edtSearch#)
  idx = listbox_indexof(lst#, txt$)
  
  if idx >= 0 then
    listbox_itemindex#(lst#, idx)
    label_text#(lblResult#, "Found at index: " + str$(idx))
  else
    label_text#(lblResult#, "Not found")
  endif
endfunction
```

### Two-List Transfer

```basic
let frm# = form#("List Transfer", 550, 350)
form_position#(frm#, 4)

' Available items
let lblAvail# = label#(frm#, "Available:")
label_move#(lblAvail#, 50, 20)
let lstAvail# = listbox#(frm#, 50, 45, 180, 200)

' Selected items
let lblSel# = label#(frm#, "Selected:")
label_move#(lblSel#, 320, 20)
let lstSel# = listbox#(frm#, 320, 45, 180, 200)

' Transfer buttons
let btnAdd# = button#(frm#, ">>", 245, 100, 60, 30)
let btnRemove# = button#(frm#, "<<", 245, 140, 60, 30)

' Populate available
listbox_add(lstAvail#, "Item A")
listbox_add(lstAvail#, "Item B")
listbox_add(lstAvail#, "Item C")
listbox_add(lstAvail#, "Item D")
listbox_add(lstAvail#, "Item E")

button_onclick#(btnAdd#, "OnAddToSelected")
button_onclick#(btnRemove#, "OnRemoveFromSelected")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnAddToSelected(sender#) local idx, txt$
  idx = listbox_itemindex(lstAvail#)
  if idx >= 0 then
    txt$ = listbox_item$(lstAvail#, idx)
    listbox_add(lstSel#, txt$)
    listbox_delete(lstAvail#, idx)
  endif
endfunction

function OnRemoveFromSelected(sender#) local idx, txt$
  idx = listbox_itemindex(lstSel#)
  if idx >= 0 then
    txt$ = listbox_item$(lstSel#, idx)
    listbox_add(lstAvail#, txt$)
    listbox_delete(lstSel#, idx)
  endif
endfunction
```

### Multi-Select Example

```basic
let frm# = form#("Multi-Select Demo", 450, 350)
form_position#(frm#, 4)

let lst# = listbox#(frm#, 50, 50, 200, 200)
listbox_multiselect#(lst#, 1)

listbox_add(lst#, "Option 1")
listbox_add(lst#, "Option 2")
listbox_add(lst#, "Option 3")
listbox_add(lst#, "Option 4")
listbox_add(lst#, "Option 5")

let btnSelectAll# = button#(frm#, "Select All", 270, 50, 100, 30)
let btnClearSel# = button#(frm#, "Clear Selection", 270, 90, 100, 30)
let btnShowSel# = button#(frm#, "Show Selected", 270, 130, 100, 30)

let lblCount# = label#(frm#, "Selected: 0")
label_move#(lblCount#, 270, 180)

button_onclick#(btnSelectAll#, "OnSelectAll")
button_onclick#(btnClearSel#, "OnClearSel")
button_onclick#(btnShowSel#, "OnShowSel")

listbox_onchange#(lst#, "OnListChange")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnListChange(sender#)
  label_text#(lblCount#, "Selected: " + str$(listbox_selcount(sender#)))
endfunction

function OnSelectAll(sender#)
  listbox_selectall(lst#)
  OnListChange(lst#)
endfunction

function OnClearSel(sender#)
  listbox_clearselection(lst#)
  OnListChange(lst#)
endfunction

function OnShowSel(sender#) local i, cnt
  cnt = listbox_count(lst#)
  println "Selected items:"
  for i = 0 to cnt - 1
    if listbox_isselected(lst#, i) = 1 then
      println "  " + listbox_item$(lst#, i)
    endif
  next
endfunction
```

### Using Item Pointers

```basic
let frm# = form#("Item Pointer Demo", 400, 300)
form_position#(frm#, 4)

let lst# = listbox#(frm#, 50, 50, 200, 180)

' Add items and keep pointer to first one
let item1# = listbox_additem#(lst#, "First Item")
listbox_add(lst#, "Second Item")
listbox_add(lst#, "Third Item")

let btnModify# = button#(frm#, "Modify First", 270, 50, 100, 30)
button_onclick#(btnModify#, "OnModify")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnModify(sender#) local txt$
  txt$ = listboxitem_text$(item1#)
  listboxitem_text#(item1#, txt$ + " [modified]")
endfunction
```

---

## Tips and Best Practices

1. **Check index before use** - `listbox_itemindex()` returns -1 when nothing selected
2. **Prefer OnChange for most selection handling** - Single-pointer callback `(sender#)`, use `listbox_selected$(sender#)` to get the text
3. **Use OnItemClick when you need the item pointer directly** - Two-pointer callback `(sender#, item#)`, gives access to `listboxitem_text$`, `listboxitem_index`, `listboxitem_isselected`
4. **Use listbox_add for simple cases** - Returns index
5. **Use listbox_additem# when you need item pointer** - Returns pointer
6. **Populate items BEFORE applying font styling** - Font functions apply only to items already in the list
7. **Clear before repopulating** - Use `listbox_clear()` when refreshing data
8. **Use listbox_indexof to find items** - Returns -1 if not found
9. **Enable multiselect for multiple choices** - Use `listbox_multiselect#(lst#, 1)`

---

## See Also

- **FormLib** - Form management
- **ComboBoxLib** - Dropdown selection
- **EditLib** - Text input
- **ButtonLib** - Button controls

---

*ListBoxLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
