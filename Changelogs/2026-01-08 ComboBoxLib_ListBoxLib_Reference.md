# Plan9Basic ComboBox and ListBox Libraries Reference

## ComboBoxLib - Dropdown List Control

ComboBoxLib provides a complete ComboBox control, enabling dropdown selection lists in Plan9Basic applications.

### Features
- 105+ functions
- Full event support with 17 events including Drag & Drop
- Items management (add, insert, delete, clear)
- Selection tracking
- GC integration

### Creation Functions

| Function | Description |
|----------|-------------|
| `combobox#(parent#)` | Create combobox at (0,0) with default size |
| `combobox#(parent#, x, y, w, h)` | Create combobox with position and size |
| `combobox_free(cb#)` | Free combobox and remove from GC |

### Items Management

| Function | Description |
|----------|-------------|
| `combobox_add(cb#, text$)` | Add item, returns index |
| `combobox_insert(cb#, index, text$)` | Insert item at index |
| `combobox_delete(cb#, index)` | Delete item at index |
| `combobox_clear(cb#)` | Remove all items |
| `combobox_count(cb#)` | Get number of items |
| `combobox_item$(cb#, index)` | Get item text at index |
| `combobox_item#(cb#, index, text$)` | Set item text at index |
| `combobox_itemindex(cb#)` | Get selected index (-1 if none) |
| `combobox_itemindex#(cb#, index)` | Set selected index |
| `combobox_selected$(cb#)` | Get selected item text |
| `combobox_indexof(cb#, text$)` | Find item by text, returns index |
| `combobox_dropdowncount(cb#)` | Get max visible items in dropdown |
| `combobox_dropdowncount#(cb#, count)` | Set max visible items |

### Position and Size

| Function | Description |
|----------|-------------|
| `combobox_x(cb#)` / `combobox_x#(cb#, val)` | Get/set X position |
| `combobox_y(cb#)` / `combobox_y#(cb#, val)` | Get/set Y position |
| `combobox_width(cb#)` / `combobox_width#(cb#, val)` | Get/set width |
| `combobox_height(cb#)` / `combobox_height#(cb#, val)` | Get/set height |
| `combobox_bounds#(cb#, x, y, w, h)` | Set all bounds at once |
| `combobox_move#(cb#, x, y)` | Set position |
| `combobox_size#(cb#, w, h)` | Set size |
| `combobox_align(cb#)` / `combobox_align#(cb#, val)` | Get/set alignment |

### Visibility and State

| Function | Description |
|----------|-------------|
| `combobox_visible(cb#)` / `combobox_visible#(cb#, val)` | Get/set visibility (0/1) |
| `combobox_enabled(cb#)` / `combobox_enabled#(cb#, val)` | Get/set enabled state |
| `combobox_opacity(cb#)` / `combobox_opacity#(cb#, val)` | Get/set opacity (0.0-1.0) |
| `combobox_tag(cb#)` / `combobox_tag#(cb#, val)` | Get/set tag value |

### Event Callbacks

| Event | Signature | Description |
|-------|-----------|-------------|
| `combobox_onchange#(cb#, func$)` | `function name(sender#)` | Selection changed |
| `combobox_onclick#(cb#, func$)` | `function name(sender#)` | Click event |
| `combobox_ondblclick#(cb#, func$)` | `function name(sender#)` | Double-click |
| `combobox_onenter#(cb#, func$)` | `function name(sender#)` | Focus gained |
| `combobox_onexit#(cb#, func$)` | `function name(sender#)` | Focus lost |
| `combobox_onkeydown#(cb#, func$)` | `function name(sender#, key, keychar$, shift$)` | Key pressed |
| `combobox_onkeyup#(cb#, func$)` | `function name(sender#, key, keychar$, shift$)` | Key released |
| `combobox_onmousedown#(cb#, func$)` | `function name(sender#, btn, x, y, shift$)` | Mouse button down |
| `combobox_onmouseup#(cb#, func$)` | `function name(sender#, btn, x, y, shift$)` | Mouse button up |
| `combobox_onmousemove#(cb#, func$)` | `function name(sender#, x, y, shift$)` | Mouse moved |
| `combobox_ondragover#(cb#, func$)` | `function name(sender#, x, y)` | Drag over (return 1 to accept) |
| `combobox_ondragdrop#(cb#, func$)` | `function name(sender#, x, y)` | Item dropped |

---

## ListBoxLib - Multi-Item List Control

ListBoxLib provides a complete ListBox control, supporting single and multi-select lists.

### Features
- 120+ functions
- Full event support with 18 events including OnItemClick and Drag & Drop
- Multi-select support
- Direct item pointer access
- ListBoxItem helper functions
- GC integration

### Creation Functions

| Function | Description |
|----------|-------------|
| `listbox#(parent#)` | Create listbox at (0,0) with default size |
| `listbox#(parent#, x, y, w, h)` | Create listbox with position and size |
| `listbox_free(lb#)` | Free listbox and remove from GC |

### Items Management

| Function | Description |
|----------|-------------|
| `listbox_add(lb#, text$)` | Add item, returns index |
| `listbox_additem#(lb#, text$)` | Add item, returns item pointer |
| `listbox_insert(lb#, index, text$)` | Insert item at index |
| `listbox_delete(lb#, index)` | Delete item at index |
| `listbox_clear(lb#)` | Remove all items |
| `listbox_count(lb#)` | Get number of items |
| `listbox_item$(lb#, index)` | Get item text at index |
| `listbox_item#(lb#, index, text$)` | Set item text at index |
| `listbox_itemat#(lb#, index)` | Get item pointer at index |
| `listbox_itemindex(lb#)` | Get selected index (-1 if none) |
| `listbox_itemindex#(lb#, index)` | Set selected index |
| `listbox_selected$(lb#)` | Get selected item text |
| `listbox_indexof(lb#, text$)` | Find item by text |

### Multi-Select Functions

| Function | Description |
|----------|-------------|
| `listbox_multiselect(lb#)` | Get multi-select mode (0/1) |
| `listbox_multiselect#(lb#, val)` | Enable/disable multi-select |
| `listbox_isselected(lb#, index)` | Check if item is selected |
| `listbox_selectitem#(lb#, index, val)` | Select/deselect item |
| `listbox_selectall(lb#)` | Select all items |
| `listbox_clearselection(lb#)` | Clear all selections |
| `listbox_selcount(lb#)` | Get number of selected items |

### ListBoxItem Helper Functions

| Function | Description |
|----------|-------------|
| `listboxitem_text$(item#)` | Get item text |
| `listboxitem_text#(item#, text$)` | Set item text |
| `listboxitem_index(item#)` | Get item index |
| `listboxitem_isselected(item#)` | Check if selected |
| `listboxitem_isselected#(item#, val)` | Set selection state |

### Event Callbacks

| Event | Signature | Description |
|-------|-----------|-------------|
| `listbox_onchange#(lb#, func$)` | `function name(sender#)` | Selection changed |
| `listbox_onitemclick#(lb#, func$)` | `function name(sender#, item#)` | Item clicked |
| `listbox_onclick#(lb#, func$)` | `function name(sender#)` | Click event |
| `listbox_ondblclick#(lb#, func$)` | `function name(sender#)` | Double-click |
| `listbox_ondragover#(lb#, func$)` | `function name(sender#, x, y)` | Drag over (return 1 to accept) |
| `listbox_ondragdrop#(lb#, func$)` | `function name(sender#, x, y)` | Item dropped |

---

## Alignment Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `ALIGN_NONE` | 0 | No alignment |
| `ALIGN_TOP` | 1 | Align to top |
| `ALIGN_LEFT` | 2 | Align to left |
| `ALIGN_RIGHT` | 3 | Align to right |
| `ALIGN_BOTTOM` | 4 | Align to bottom |
| `ALIGN_CLIENT` | 9 | Fill parent |
| `ALIGN_CENTER` | 11 | Center in parent |

## DragMode Constants

| Value | Description |
|-------|-------------|
| 0 | dmManual - Manual drag initiation |
| 1 | dmAutomatic - Automatic drag on mouse down |

## Error Codes

| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Invalid control |
| 2 | Invalid parent |
| 3 | Invalid value |
| 4 | Create failed |
| 5 | Index out of range |

## Integration

Add to your Delphi project:
```pascal
uses ComboBoxLib, ListBoxLib;

// In initialization:
RegisterComboBoxFuncs(FunctionsDict, BasicEngine, ConsoleOutput);
RegisterListBoxFuncs(FunctionsDict, BasicEngine, ConsoleOutput);
```
