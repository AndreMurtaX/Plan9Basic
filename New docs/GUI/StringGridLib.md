# StringGridLib - String Grid Control Library for Plan9Basic

## Overview

StringGridLib provides comprehensive functionality for creating and managing data grid controls in Plan9Basic programs. StringGrid displays tabular data with support for multiple column types, sorting, editing, and CSV import/export.

**Version:** 1.0.0  
**Function Count:** 112 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
' Column type constants
let COL_STRING = 0

let frm# = form#("StringGrid Demo", 600, 400)
form_position#(frm#, 4)

let grid# = stringgrid#(frm#, 10, 10, 580, 350)

' Add columns: header$, type, width
stringgrid_addcolumn#(grid#, "Name", COL_STRING, 150)
stringgrid_addcolumn#(grid#, "Age", COL_STRING, 60)
stringgrid_addcolumn#(grid#, "City", COL_STRING, 120)

' Add rows
stringgrid_rowcount#(grid#, 3)

' Set cell values
stringgrid_cell#(grid#, 0, 0, "Alice")
stringgrid_cell#(grid#, 1, 0, "30")
stringgrid_cell#(grid#, 2, 0, "New York")

stringgrid_cell#(grid#, 0, 1, "Bob")
stringgrid_cell#(grid#, 1, 1, "25")
stringgrid_cell#(grid#, 2, 1, "London")

stringgrid_cell#(grid#, 0, 2, "Carol")
stringgrid_cell#(grid#, 1, 2, "35")
stringgrid_cell#(grid#, 2, 2, "Paris")

form_show(frm#)
```

## Numeric Values Reference

### Column Types

| Value | Constant | Description |
|-------|----------|-------------|
| 0 | COL_STRING | Standard text column |
| 1 | COL_CHECK | Checkbox column |
| 2 | COL_CURRENCY | Currency formatted column |
| 3 | COL_DATE | Date column |
| 4 | COL_GLYPH | Glyph/icon column |
| 5 | COL_IMAGE | Image column |
| 6 | COL_POPUP | Dropdown/popup column |
| 7 | COL_PROGRESS | Progress bar column |
| 8 | COL_TIME | Time column |

### Alignment Values (Control)

| Value | Description |
|-------|-------------|
| 0 | None (absolute positioning) |
| 1 | Top |
| 2 | Left |
| 3 | Right |
| 4 | Bottom |
| 9 | Client (fill parent) |

### Column Text Alignment

| Value | Description |
|-------|-------------|
| 0 | Center |
| 1 | Leading (Left) |
| 2 | Trailing (Right) |

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `stringgrid_error()` | Returns last error code (0 = no error) |
| `stringgrid_errormsg$()` | Returns last error message |
| `stringgrid_strerror$(code)` | Converts error code to message |
| `stringgrid_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `stringgrid#(parent#)` | Create with default size |
| `stringgrid#(parent#, x, y, w, h)` | Create with position and size |
| `stringgrid_free(grid#)` | Destroy grid |

### Row and Column Count

| Function | Description |
|----------|-------------|
| `stringgrid_rowcount(grid#)` | Get number of rows |
| `stringgrid_rowcount#(grid#, count)` | Set number of rows |
| `stringgrid_colcount(grid#)` | Get number of columns |

### Column Management

| Function | Description |
|----------|-------------|
| `stringgrid_addcolumn#(grid#, header$, type, width)` | Add column (returns column pointer) |
| `stringgrid_deletecolumn(grid#, colIndex)` | Delete column |
| `stringgrid_clearcolumns(grid#)` | Remove all columns |
| `stringgrid_column#(grid#, colIndex)` | Get column object pointer |

### Column Properties

| Function | Description |
|----------|-------------|
| `stringgrid_columnheader$(grid#, col)` | Get column header text |
| `stringgrid_columnheader#(grid#, col, text$)` | Set column header text |
| `stringgrid_columnwidth(grid#, col)` | Get column width |
| `stringgrid_columnwidth#(grid#, col, width)` | Set column width |
| `stringgrid_columnvisible(grid#, col)` | Get column visibility (0/1) |
| `stringgrid_columnvisible#(grid#, col, visible)` | Set column visibility |
| `stringgrid_columnreadonly(grid#, col)` | Get column read-only state (0/1) |
| `stringgrid_columnreadonly#(grid#, col, readonly)` | Set column read-only |
| `stringgrid_columntype(grid#, col)` | Get column type |
| `stringgrid_columnalign(grid#, col)` | Get column text alignment |
| `stringgrid_columnalign#(grid#, col, align)` | Set column text alignment |

### Cell Access

| Function | Description |
|----------|-------------|
| `stringgrid_cell$(grid#, col, row)` | Get cell text |
| `stringgrid_cell#(grid#, col, row, text$)` | Set cell text |
| `stringgrid_cellcheck(grid#, col, row)` | Get checkbox state (0/1) |
| `stringgrid_cellcheck#(grid#, col, row, checked)` | Set checkbox state |
| `stringgrid_cellnum(grid#, col, row)` | Get cell numeric value |
| `stringgrid_cellnum#(grid#, col, row, value)` | Set cell numeric value |
| `stringgrid_cellprogress(grid#, col, row)` | Get progress value (0-100) |
| `stringgrid_cellprogress#(grid#, col, row, value)` | Set progress value |

### Row Operations

| Function | Description |
|----------|-------------|
| `stringgrid_rowheight(grid#)` | Get row height |
| `stringgrid_rowheight#(grid#, height)` | Set row height |
| `stringgrid_insertrow(grid#, rowIndex)` | Insert row at index |
| `stringgrid_deleterow(grid#, rowIndex)` | Delete row at index |
| `stringgrid_moverow(grid#, fromRow, toRow)` | Move row |
| `stringgrid_swaprows(grid#, row1, row2)` | Swap two rows |
| `stringgrid_clearrow(grid#, rowIndex)` | Clear row content |
| `stringgrid_copyrow(grid#, srcRow, destRow)` | Copy row content |
| `stringgrid_clearrows(grid#)` | Clear all rows |

### Sorting

| Function | Description |
|----------|-------------|
| `stringgrid_sort(grid#, col, ascending)` | Sort by column (text) |
| `stringgrid_sortnum(grid#, col, ascending)` | Sort by column (numeric) |

### Clipboard

| Function | Description |
|----------|-------------|
| `stringgrid_copy(grid#)` | Copy entire grid to clipboard |
| `stringgrid_copysel(grid#)` | Copy selection to clipboard |
| `stringgrid_paste(grid#)` | Paste from clipboard |
| `stringgrid_copycell(grid#, col, row)` | Copy cell to clipboard |
| `stringgrid_pastecell(grid#, col, row)` | Paste to cell from clipboard |

### CSV Import/Export

| Function | Description |
|----------|-------------|
| `stringgrid_exportcsv(grid#, filename$, delimiter$, includeHeaders)` | Export to CSV file |
| `stringgrid_importcsv(grid#, filename$, delimiter$, hasHeaders)` | Import from CSV file |
| `stringgrid_tocsv$(grid#, delimiter$, includeHeaders)` | Get grid as CSV string |
| `stringgrid_fromcsv(grid#, csvData$, delimiter$, hasHeaders)` | Load from CSV string |

### Selection

| Function | Description |
|----------|-------------|
| `stringgrid_col(grid#)` | Get selected column |
| `stringgrid_col#(grid#, col)` | Set selected column |
| `stringgrid_row(grid#)` | Get selected row |
| `stringgrid_row#(grid#, row)` | Set selected row |
| `stringgrid_selectcell#(grid#, col, row)` | Select specific cell |

### Grid Options

| Function | Description |
|----------|-------------|
| `stringgrid_showhdr(grid#)` | Get show headers (0/1) |
| `stringgrid_showhdr#(grid#, value)` | Set show headers |
| `stringgrid_editing(grid#)` | Get editing enabled (0/1) |
| `stringgrid_editing#(grid#, value)` | Set editing enabled |
| `stringgrid_altcolors(grid#)` | Get alternating row colors (0/1) |
| `stringgrid_altcolors#(grid#, value)` | Set alternating row colors |
| `stringgrid_colresize(grid#)` | Get column resize enabled (0/1) |
| `stringgrid_colresize#(grid#, value)` | Set column resize enabled |
| `stringgrid_rowselect(grid#)` | Get row selection mode (0/1) |
| `stringgrid_rowselect#(grid#, value)` | Set row selection mode |

### Popup Column Items

| Function | Description |
|----------|-------------|
| `stringgrid_popupadd(grid#, col, item$)` | Add item to popup column |
| `stringgrid_popupclear(grid#, col)` | Clear popup column items |
| `stringgrid_popupcount(grid#, col)` | Get popup item count |

### Position and Size

| Function | Description |
|----------|-------------|
| `stringgrid_x(grid#)` / `stringgrid_x#(grid#, x)` | Get/set X position |
| `stringgrid_y(grid#)` / `stringgrid_y#(grid#, y)` | Get/set Y position |
| `stringgrid_width(grid#)` / `stringgrid_width#(grid#, w)` | Get/set width |
| `stringgrid_height(grid#)` / `stringgrid_height#(grid#, h)` | Get/set height |
| `stringgrid_bounds#(grid#, x, y, w, h)` | Set position and size |

### Alignment and Visibility

| Function | Description |
|----------|-------------|
| `stringgrid_align(grid#)` / `stringgrid_align#(grid#, value)` | Get/set alignment |
| `stringgrid_visible(grid#)` / `stringgrid_visible#(grid#, value)` | Get/set visibility (0/1) |
| `stringgrid_enabled(grid#)` / `stringgrid_enabled#(grid#, value)` | Get/set enabled state (0/1) |
| `stringgrid_opacity(grid#)` / `stringgrid_opacity#(grid#, value)` | Get/set opacity (0.0-1.0) |

### Focus and Scrolling

| Function | Description |
|----------|-------------|
| `stringgrid_focus(grid#)` | Set focus to grid |
| `stringgrid_isfocused(grid#)` | Check if focused (0/1) |
| `stringgrid_scrolltorow(grid#, row)` | Scroll to make row visible |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `stringgrid_tag(grid#)` / `stringgrid_tag#(grid#, value)` | Get/set tag value |
| `stringgrid_parent#(grid#)` | Get parent |
| `stringgrid_parent#(grid#, parent#)` | Set parent |
| `stringgrid_clearcallbacks#(grid#)` | Disconnects all event callbacks |

---

## Event Callbacks

### Grid Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnCellClick | `stringgrid_oncellclick#(grid#, func$)` | `stringgrid_oncellclick$(grid#)` | `function(sender#, col, row)` |
| OnCellDblClick | `stringgrid_oncelldblclick#(grid#, func$)` | `stringgrid_oncelldblclick$(grid#)` | `function(sender#, col, row)` |
| OnSelectCell | `stringgrid_onselectcell#(grid#, func$)` | `stringgrid_onselectcell$(grid#)` | `function(sender#, col, row)` |
| OnSelChanged | `stringgrid_onselchanged#(grid#, func$)` | `stringgrid_onselchanged$(grid#)` | `function(sender#)` |
| OnEditingDone | `stringgrid_oneditingdone#(grid#, func$)` | `stringgrid_oneditingdone$(grid#)` | `function(sender#, col, row)` |
| OnHeaderClick | `stringgrid_onheaderclick#(grid#, func$)` | `stringgrid_onheaderclick$(grid#)` | `function(sender#, col)` |
| OnClick | `stringgrid_onclick#(grid#, func$)` | `stringgrid_onclick$(grid#)` | `function(sender#)` |
| OnResize | `stringgrid_onresize#(grid#, func$)` | `stringgrid_onresize$(grid#)` | `function(sender#)` |

Use `stringgrid_clearcallbacks#(grid#)` to disconnect all events.

---

## Complete Examples

### Data Entry Grid

```basic
' Column type constants
let COL_STRING = 0
let COL_CHECK = 1

let frm# = form#("Data Entry", 600, 400)
form_position#(frm#, 4)

let grid# = stringgrid#(frm#, 10, 10, 580, 300)
stringgrid_editing#(grid#, 1)
stringgrid_altcolors#(grid#, 1)

' Add columns: header$, type, width
stringgrid_addcolumn#(grid#, "Product", COL_STRING, 150)
stringgrid_addcolumn#(grid#, "Quantity", COL_STRING, 80)
stringgrid_addcolumn#(grid#, "Price", COL_STRING, 80)
stringgrid_addcolumn#(grid#, "In Stock", COL_CHECK, 70)

' Right-align numeric columns
stringgrid_columnalign#(grid#, 1, 2)
stringgrid_columnalign#(grid#, 2, 2)

' Add initial rows
stringgrid_rowcount#(grid#, 5)

let btnAddRow# = button#(frm#, "Add Row", 10, 320, 100, 30)
let btnDelRow# = button#(frm#, "Delete Row", 120, 320, 100, 30)

button_onclick#(btnAddRow#, "OnAddRow")
button_onclick#(btnDelRow#, "OnDelRow")

stringgrid_oneditingdone#(grid#, "OnEdit")

form_show(frm#)

function OnAddRow(sender#) local cnt
  cnt = stringgrid_rowcount(grid#)
  stringgrid_rowcount#(grid#, cnt + 1)
endfunction

function OnDelRow(sender#) local row
  row = stringgrid_row(grid#)
  if row >= 0 then
    stringgrid_deleterow(grid#, row)
  endif
endfunction

function OnEdit(sender#, col, row)
  println "Edited cell [" + str$(col) + "," + str$(row) + "]: " + stringgrid_cell$(sender#, col, row)
endfunction
```

### Sortable Table

```basic
' Column type constants
let COL_STRING = 0

let frm# = form#("Sortable Table", 500, 350)
form_position#(frm#, 4)

let grid# = stringgrid#(frm#, 10, 10, 480, 300)

' Add columns: header$, type, width
stringgrid_addcolumn#(grid#, "Name", COL_STRING, 150)
stringgrid_addcolumn#(grid#, "Age", COL_STRING, 60)
stringgrid_addcolumn#(grid#, "Score", COL_STRING, 80)

stringgrid_columnalign#(grid#, 1, 2)
stringgrid_columnalign#(grid#, 2, 2)

stringgrid_rowcount#(grid#, 5)

stringgrid_cell#(grid#, 0, 0, "Alice")
stringgrid_cell#(grid#, 1, 0, "30")
stringgrid_cell#(grid#, 2, 0, "95")

stringgrid_cell#(grid#, 0, 1, "Bob")
stringgrid_cell#(grid#, 1, 1, "25")
stringgrid_cell#(grid#, 2, 1, "87")

stringgrid_cell#(grid#, 0, 2, "Carol")
stringgrid_cell#(grid#, 1, 2, "35")
stringgrid_cell#(grid#, 2, 2, "92")

stringgrid_cell#(grid#, 0, 3, "David")
stringgrid_cell#(grid#, 1, 3, "28")
stringgrid_cell#(grid#, 2, 3, "78")

stringgrid_cell#(grid#, 0, 4, "Eve")
stringgrid_cell#(grid#, 1, 4, "32")
stringgrid_cell#(grid#, 2, 4, "99")

let sortCol = 0
let sortAsc = 1

stringgrid_onheaderclick#(grid#, "OnHeaderClick")

form_show(frm#)

function OnHeaderClick(sender#, col) local isNumeric
  if col = sortCol then
    sortAsc = 1 - sortAsc
  else
    sortCol = col
    sortAsc = 1
  endif
  
  ' Numeric sort for Age and Score columns
  isNumeric = 0
  if col = 1 then isNumeric = 1
  if col = 2 then isNumeric = 1
  
  if isNumeric = 1 then
    stringgrid_sortnum(sender#, col, sortAsc)
  else
    stringgrid_sort(sender#, col, sortAsc)
  endif
endfunction
```

### CSV Import/Export

```basic
let COL_STRING = 0

let frm# = form#("CSV Demo", 600, 400)
form_position#(frm#, 4)

let grid# = stringgrid#(frm#, 10, 50, 580, 300)
stringgrid_editing#(grid#, 1)

stringgrid_addcolumn#(grid#, "Name", COL_STRING, 150)
stringgrid_addcolumn#(grid#, "Email", COL_STRING, 200)
stringgrid_addcolumn#(grid#, "Phone", COL_STRING, 150)

let btnExport# = button#(frm#, "Export CSV", 10, 10, 100, 30)
let btnImport# = button#(frm#, "Import CSV", 120, 10, 100, 30)
let btnToString# = button#(frm#, "To String", 230, 10, 100, 30)

button_onclick#(btnExport#, "OnExport")
button_onclick#(btnImport#, "OnImport")
button_onclick#(btnToString#, "OnToString")

form_show(frm#)

function OnExport(sender#)
  stringgrid_exportcsv(grid#, "contacts.csv", ",", 1)
  println "Exported to contacts.csv"
endfunction

function OnImport(sender#)
  stringgrid_importcsv(grid#, "contacts.csv", ",", 1)
  println "Imported from contacts.csv"
endfunction

function OnToString(sender#) local csv$
  csv$ = stringgrid_tocsv$(grid#, ",", 1)
  println csv$
endfunction
```

### Checkbox and Progress Columns

```basic
' Column type constants
let COL_STRING = 0
let COL_CHECK = 1
let COL_PROGRESS = 7

let frm# = form#("Task List", 500, 350)
form_position#(frm#, 4)

let grid# = stringgrid#(frm#, 10, 10, 480, 300)

' Add columns: header$, type, width
stringgrid_addcolumn#(grid#, "Done", COL_CHECK, 50)
stringgrid_addcolumn#(grid#, "Task", COL_STRING, 200)
stringgrid_addcolumn#(grid#, "Progress", COL_PROGRESS, 100)

stringgrid_rowcount#(grid#, 4)

' Set task data
stringgrid_cell#(grid#, 1, 0, "Design UI")
stringgrid_cellprogress#(grid#, 2, 0, 100)
stringgrid_cellcheck#(grid#, 0, 0, 1)

stringgrid_cell#(grid#, 1, 1, "Implement backend")
stringgrid_cellprogress#(grid#, 2, 1, 75)

stringgrid_cell#(grid#, 1, 2, "Write tests")
stringgrid_cellprogress#(grid#, 2, 2, 30)

stringgrid_cell#(grid#, 1, 3, "Deploy")
stringgrid_cellprogress#(grid#, 2, 3, 0)

stringgrid_oncellclick#(grid#, "OnCellClick")

form_show(frm#)

function OnCellClick(sender#, col, row) local checked
  if col = 0 then
    ' Toggle checkbox
    let checked = stringgrid_cellcheck(sender#, col, row)
    stringgrid_cellcheck#(sender#, col, row, 1 - checked)
    
    ' Update progress if checked
    if checked = 0 then
      stringgrid_cellprogress#(sender#, 2, row, 100)
    endif
  endif
endfunction
```

---

## Tips and Best Practices

1. **Define column type constants** - Use named constants like `COL_STRING = 0` for readability
2. **Parameter order for addcolumn** - `stringgrid_addcolumn#(grid#, header$, type, width)`
3. **Set columns before rows** - Add columns first, then set row count
4. **Enable editing when needed** - `stringgrid_editing#(grid#, 1)` allows cell editing
5. **Right-align numeric columns** - Use `stringgrid_columnalign#(grid#, col, 2)` for numbers
6. **Use sortnum for numeric sorts** - `stringgrid_sort` for text, `stringgrid_sortnum` for numbers
7. **Check OnEditingDone for changes** - Event fires when user finishes editing a cell

---

## See Also

- **ListBoxLib** - Simple list controls
- **MemoLib** - Multi-line text
- **FormLib** - Form management

---

*StringGridLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
