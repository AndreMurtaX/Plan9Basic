# StringGridLib - Plan9Basic Reference

## Overview

StringGridLib provides a tabular data display control for Plan9Basic applications. It allows you to create spreadsheet-like grids with multiple column types, making it ideal for displaying and editing structured data.

## Column Types

The library supports 9 different column types, each suited for specific data:

| Type | Value | Description |
|------|-------|-------------|
| String | 0 | Default text column for general text data |
| Check | 1 | Checkbox column for boolean values (checked/unchecked) |
| Currency | 2 | Currency formatted numbers |
| Date | 3 | Date values |
| Glyph | 4 | Small bitmap icons |
| Image | 5 | Image display column |
| Popup | 6 | Dropdown/combo selection list |
| Progress | 7 | Progress bar display (0-100) |
| Time | 8 | Time values |

## Creating a StringGrid

### Basic Creation

```basic
' Create a grid on a form
let grid# = stringgrid#(parent#)

' Create with position and size
let grid# = stringgrid#(parent#, x, y, width, height)
```

### Complete Example

```basic
let frm# = form#("Product Inventory", 800, 600)

let grid# = stringgrid#(frm#, 20, 20, 760, 500)

' Add columns with different types
stringgrid_addcolumn#(grid#, "Product Name", 0, 200)  ' String
stringgrid_addcolumn#(grid#, "In Stock", 1, 80)       ' Checkbox
stringgrid_addcolumn#(grid#, "Price", 2, 100)         ' Currency
stringgrid_addcolumn#(grid#, "Progress", 7, 120)      ' Progress bar

' Set number of rows
stringgrid_rowcount#(grid#, 5)

' Enable editing
stringgrid_editing#(grid#, 1)

form_show(frm#)
```

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `stringgrid_error()` | Returns the last error code (0 = no error) |
| `stringgrid_errormsg$()` | Returns the last error message |
| `stringgrid_strerror$(code)` | Returns description for an error code |
| `stringgrid_clearerror()` | Clears any error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `stringgrid#(parent#)` | Creates a new grid with default size |
| `stringgrid#(parent#, x, y, w, h)` | Creates a grid with specified bounds |
| `stringgrid_free(grid#)` | Destroys the grid and releases resources |

### Row and Column Count

| Function | Description |
|----------|-------------|
| `stringgrid_rowcount(grid#)` | Gets the number of rows |
| `stringgrid_rowcount#(grid#, count)` | Sets the number of rows |
| `stringgrid_colcount(grid#)` | Gets the number of columns |

### Column Management

| Function | Description |
|----------|-------------|
| `stringgrid_addcolumn#(grid#, header$, type, width)` | Adds a column |
| `stringgrid_deletecolumn(grid#, index)` | Deletes a column by index |
| `stringgrid_clearcolumns(grid#)` | Removes all columns |
| `stringgrid_column#(grid#, index)` | Gets a column pointer by index |

### Column Properties

| Function | Description |
|----------|-------------|
| `stringgrid_columnheader$(grid#, col)` | Gets column header text |
| `stringgrid_columnheader#(grid#, col, text$)` | Sets column header text |
| `stringgrid_columnwidth(grid#, col)` | Gets column width |
| `stringgrid_columnwidth#(grid#, col, width)` | Sets column width |
| `stringgrid_columnvisible(grid#, col)` | Gets column visibility (0/1) |
| `stringgrid_columnvisible#(grid#, col, visible)` | Sets column visibility |
| `stringgrid_columnreadonly(grid#, col)` | Gets column read-only state |
| `stringgrid_columnreadonly#(grid#, col, readonly)` | Sets column read-only |
| `stringgrid_columntype(grid#, col)` | Gets column type (0-8) |

### Cell Access

| Function | Description |
|----------|-------------|
| `stringgrid_cell$(grid#, col, row)` | Gets cell text value |
| `stringgrid_cell#(grid#, col, row, value$)` | Sets cell text value |
| `stringgrid_cellcheck(grid#, col, row)` | Gets checkbox state (0/1) |
| `stringgrid_cellcheck#(grid#, col, row, checked)` | Sets checkbox state |
| `stringgrid_cellnum(grid#, col, row)` | Gets cell numeric value |
| `stringgrid_cellnum#(grid#, col, row, value)` | Sets cell numeric value |
| `stringgrid_cellprogress(grid#, col, row)` | Gets progress value (0-100) |
| `stringgrid_cellprogress#(grid#, col, row, value)` | Sets progress value |

### Selection

| Function | Description |
|----------|-------------|
| `stringgrid_col(grid#)` | Gets selected column index |
| `stringgrid_col#(grid#, index)` | Sets selected column |
| `stringgrid_row(grid#)` | Gets selected row index |
| `stringgrid_row#(grid#, index)` | Sets selected row |
| `stringgrid_selectcell#(grid#, col, row)` | Selects a specific cell |

### Grid Options

| Function | Description |
|----------|-------------|
| `stringgrid_showhdr(grid#)` | Gets header visibility |
| `stringgrid_showhdr#(grid#, show)` | Shows/hides column headers |
| `stringgrid_editing(grid#)` | Gets editing enabled state |
| `stringgrid_editing#(grid#, enable)` | Enables/disables cell editing |
| `stringgrid_altcolors(grid#)` | Gets alternating row colors state |
| `stringgrid_altcolors#(grid#, enable)` | Enables alternating row colors |
| `stringgrid_colresize(grid#)` | Gets column resize state |
| `stringgrid_colresize#(grid#, enable)` | Allows user to resize columns |
| `stringgrid_rowselect(grid#)` | Gets row select mode |
| `stringgrid_rowselect#(grid#, enable)` | Enables full row selection |

### Popup Column Items

| Function | Description |
|----------|-------------|
| `stringgrid_popupadd(grid#, col, item$)` | Adds item to popup column |
| `stringgrid_popupclear(grid#, col)` | Clears popup column items |
| `stringgrid_popupcount(grid#, col)` | Gets popup item count |

### Row Operations

| Function | Description |
|----------|-------------|
| `stringgrid_rowheight(grid#)` | Gets row height |
| `stringgrid_rowheight#(grid#, height)` | Sets row height |
| `stringgrid_clearrows(grid#)` | Removes all rows |
| `stringgrid_scrolltorow(grid#, row)` | Scrolls to make row visible |

### Position and Size

| Function | Description |
|----------|-------------|
| `stringgrid_x(grid#)` | Gets X position |
| `stringgrid_x#(grid#, x)` | Sets X position |
| `stringgrid_y(grid#)` | Gets Y position |
| `stringgrid_y#(grid#, y)` | Sets Y position |
| `stringgrid_width(grid#)` | Gets width |
| `stringgrid_width#(grid#, width)` | Sets width |
| `stringgrid_height(grid#)` | Gets height |
| `stringgrid_height#(grid#, height)` | Sets height |
| `stringgrid_bounds#(grid#, x, y, w, h)` | Sets all bounds at once |

### Alignment

| Function | Description |
|----------|-------------|
| `stringgrid_align(grid#)` | Gets alignment mode |
| `stringgrid_align#(grid#, align)` | Sets alignment mode |

Alignment values: 0=None, 1=Top, 2=Left, 3=Right, 4=Bottom, 9=Client, 11=Center

### Visibility and State

| Function | Description |
|----------|-------------|
| `stringgrid_visible(grid#)` | Gets visibility |
| `stringgrid_visible#(grid#, visible)` | Sets visibility |
| `stringgrid_enabled(grid#)` | Gets enabled state |
| `stringgrid_enabled#(grid#, enabled)` | Sets enabled state |
| `stringgrid_opacity(grid#)` | Gets opacity (0.0-1.0) |
| `stringgrid_opacity#(grid#, opacity)` | Sets opacity |

### Focus

| Function | Description |
|----------|-------------|
| `stringgrid_focus(grid#)` | Sets focus to the grid |
| `stringgrid_isfocused(grid#)` | Returns 1 if grid has focus |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `stringgrid_tag(grid#)` | Gets tag value |
| `stringgrid_tag#(grid#, tag)` | Sets tag value |
| `stringgrid_parent#(grid#)` | Gets parent control |
| `stringgrid_parent#(grid#, parent#)` | Sets parent control |

## Events

### Event Callback Functions

| Function | Callback Signature |
|----------|-------------------|
| `stringgrid_oncellclick#(grid#, callback$)` | `function Name(sender#, col, row)` |
| `stringgrid_oncelldblclick#(grid#, callback$)` | `function Name(sender#, col, row)` |
| `stringgrid_onselectcell#(grid#, callback$)` | `function Name(sender#, col, row)` → return 1 to allow |
| `stringgrid_onselchanged#(grid#, callback$)` | `function Name(sender#)` |
| `stringgrid_oneditingdone#(grid#, callback$)` | `function Name(sender#, col, row)` |
| `stringgrid_onheaderclick#(grid#, callback$)` | `function Name(sender#, col)` |
| `stringgrid_onclick#(grid#, callback$)` | `function Name(sender#)` |
| `stringgrid_onresize#(grid#, callback$)` | `function Name(sender#)` |

### Event Example

```basic
' Set up cell click handler
stringgrid_oncellclick#(grid#, "OnCellClick")

function OnCellClick(sender#, col, row) local value$
  value$ = stringgrid_cell$(sender#, col, row)
  println "Cell [" + str$(col) + "," + str$(row) + "] = " + value$
endfunction

' Set up header click handler for sorting
stringgrid_onheaderclick#(grid#, "OnHeaderClick")

function OnHeaderClick(sender#, col) local header$
  header$ = stringgrid_columnheader$(sender#, col)
  println "Clicked column: " + header$
endfunction
```

### Clearing Events

| Function | Description |
|----------|-------------|
| `stringgrid_clearcallbacks#(grid#)` | Disconnects all event callbacks |

## Usage Examples

### Basic Product List

```basic
let frm# = form#("Products", 600, 400)
let grid# = stringgrid#(frm#, 10, 10, 580, 350)

' Add columns
stringgrid_addcolumn#(grid#, "Name", 0, 200)
stringgrid_addcolumn#(grid#, "Price", 2, 100)
stringgrid_addcolumn#(grid#, "Available", 1, 80)

' Add data
stringgrid_rowcount#(grid#, 3)
stringgrid_cell#(grid#, 0, 0, "Widget A")
stringgrid_cellnum#(grid#, 1, 0, 29.99)
stringgrid_cellcheck#(grid#, 2, 0, 1)

stringgrid_cell#(grid#, 0, 1, "Widget B")
stringgrid_cellnum#(grid#, 1, 1, 49.99)
stringgrid_cellcheck#(grid#, 2, 1, 0)

stringgrid_cell#(grid#, 0, 2, "Widget C")
stringgrid_cellnum#(grid#, 1, 2, 19.99)
stringgrid_cellcheck#(grid#, 2, 2, 1)

form_show(frm#)
```

### Progress Tracking Grid

```basic
let frm# = form#("Task Progress", 700, 400)
let grid# = stringgrid#(frm#, 10, 10, 680, 350)

stringgrid_addcolumn#(grid#, "Task", 0, 250)
stringgrid_addcolumn#(grid#, "Status", 6, 120)  ' Popup
stringgrid_addcolumn#(grid#, "Progress", 7, 150) ' Progress bar

' Add popup items for status column
stringgrid_popupadd(grid#, 1, "Not Started")
stringgrid_popupadd(grid#, 1, "In Progress")
stringgrid_popupadd(grid#, 1, "Completed")

stringgrid_rowcount#(grid#, 4)

stringgrid_cell#(grid#, 0, 0, "Design Phase")
stringgrid_cell#(grid#, 1, 0, "Completed")
stringgrid_cellprogress#(grid#, 2, 0, 100)

stringgrid_cell#(grid#, 0, 1, "Development")
stringgrid_cell#(grid#, 1, 1, "In Progress")
stringgrid_cellprogress#(grid#, 2, 1, 65)

stringgrid_cell#(grid#, 0, 2, "Testing")
stringgrid_cell#(grid#, 1, 2, "Not Started")
stringgrid_cellprogress#(grid#, 2, 2, 0)

stringgrid_cell#(grid#, 0, 3, "Deployment")
stringgrid_cell#(grid#, 1, 3, "Not Started")
stringgrid_cellprogress#(grid#, 2, 3, 0)

stringgrid_editing#(grid#, 1)
stringgrid_altcolors#(grid#, 1)

form_show(frm#)
```

## Notes

- Column and row indices are 0-based
- Progress values are automatically clamped to the 0-100 range
- Check columns interpret "true", "1", or "yes" as checked
- Use `stringgrid_editing#(grid#, 1)` to allow users to edit cells
- Events are disconnected when you set an empty callback string ("")
