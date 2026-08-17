# StringGridLib 1.1.0 - New Features Documentation

## Overview

StringGridLib version 1.1.0 adds the following new features to the Plan9Basic StringGrid library:

- **Row Operations** - Insert, delete, move, swap, clear, and copy rows
- **Column Sorting** - Sort by column (text or numeric)
- **Cell Text Alignment** - Set horizontal alignment per column
- **Clipboard Support** - Copy/paste entire grid, selection, or individual cells
- **CSV Import/Export** - Save to/load from CSV files or strings

---

## New Constants

### Text Alignment
| Constant | Value | Description |
|----------|-------|-------------|
| TEXTALIGN_CENTER | 0 | Center aligned |
| TEXTALIGN_LEADING | 1 | Left aligned (for LTR languages) |
| TEXTALIGN_TRAILING | 2 | Right aligned (for LTR languages) |

### Sort Order
| Constant | Value | Description |
|----------|-------|-------------|
| SORT_ASCENDING | 0 | A-Z or 0-9 |
| SORT_DESCENDING | 1 | Z-A or 9-0 |

### New Error Codes
| Code | Constant | Description |
|------|----------|-------------|
| 8 | ERR_FILE_ERROR | File operation failed |
| 9 | ERR_CLIPBOARD_ERROR | Clipboard operation failed |
| 10 | ERR_CSV_ERROR | CSV parsing error |

---

## Row Operations

### stringgrid_insertrow(grid#, index)
Inserts a new empty row at the specified index, shifting existing rows down.

```basic
' Insert row at position 0 (top)
stringgrid_insertrow(grid#, 0)

' Insert row at current selection
let row = stringgrid_row@(grid#)
stringgrid_insertrow(grid#, row)
```

### stringgrid_deleterow(grid#, index)
Deletes the row at the specified index, shifting rows up.

```basic
' Delete row 3
stringgrid_deleterow(grid#, 3)
```

### stringgrid_moverow(grid#, fromIndex, toIndex)
Moves a row from one position to another.

```basic
' Move row 0 to position 5
stringgrid_moverow(grid#, 0, 5)
```

### stringgrid_swaprows(grid#, row1, row2)
Swaps two rows in place.

```basic
' Swap rows 2 and 4
stringgrid_swaprows(grid#, 2, 4)
```

### stringgrid_clearrow(grid#, index)
Clears all cell values in the specified row (sets to empty strings).

```basic
' Clear row 1
stringgrid_clearrow(grid#, 1)
```

### stringgrid_copyrow(grid#, fromRow, toRow)
Copies all cell values from one row to another.

```basic
' Copy row 0 to row 5
stringgrid_copyrow(grid#, 0, 5)
```

---

## Sorting

### stringgrid_sort(grid#, colIndex, order)
Sorts all rows by the specified column using text comparison (case-insensitive).

- `colIndex` - Column index to sort by (0-based)
- `order` - 0 = Ascending (A-Z), 1 = Descending (Z-A)

```basic
' Sort by column 1 (Name), ascending
stringgrid_sort(grid#, 1, 0)

' Sort by column 1, descending
stringgrid_sort(grid#, 1, 1)
```

### stringgrid_sortnum(grid#, colIndex, order)
Sorts all rows by the specified column using numeric comparison.

```basic
' Sort by column 2 (Price) numerically, ascending (0 to 9)
stringgrid_sortnum(grid#, 2, 0)

' Sort descending (9 to 0)
stringgrid_sortnum(grid#, 2, 1)
```

---

## Column Text Alignment

### stringgrid_columnalign(grid#, colIndex) : number
Gets the horizontal text alignment of a column.

Returns: 0 = Center, 1 = Leading (Left), 2 = Trailing (Right)

### stringgrid_columnalign#(grid#, colIndex, alignment)
Sets the horizontal text alignment of a column.

```basic
' Set column 1 to left-aligned
stringgrid_columnalign#(grid#, 1, 1)

' Set column 2 to right-aligned (good for numbers)
stringgrid_columnalign#(grid#, 2, 2)

' Set column 3 to center-aligned
stringgrid_columnalign#(grid#, 3, 0)
```

---

## Clipboard Operations

### stringgrid_copy(grid#) : number
Copies the entire grid (including headers) to the clipboard as tab-separated text.

Returns: 1 = success, 0 = failure

```basic
if stringgrid_copy@(grid#) = 1 then
  println "Grid copied to clipboard"
endif
```

### stringgrid_copysel(grid#) : number
Copies only the currently selected cell value to the clipboard.

```basic
stringgrid_copysel(grid#)
```

### stringgrid_paste(grid#) : number
Pastes tab-separated data from the clipboard, starting at the current row. Creates new rows as needed.

```basic
if stringgrid_paste@(grid#) = 1 then
  println "Data pasted from clipboard"
endif
```

### stringgrid_copycell(grid#, col, row) : number
Copies a specific cell value to the clipboard.

```basic
' Copy cell at column 1, row 3
stringgrid_copycell(grid#, 1, 3)
```

### stringgrid_pastecell(grid#, col, row) : number
Pastes clipboard content into a specific cell (first line only if multiline).

```basic
' Paste to cell at column 1, row 3
stringgrid_pastecell(grid#, 1, 3)
```

---

## CSV Operations

### stringgrid_exportcsv(grid#, filename$, delimiter$, includeHeaders) : number
Exports the grid to a CSV file.

- `filename$` - File path to save
- `delimiter$` - Delimiter character (usually "," or ";")
- `includeHeaders` - 1 = include headers, 0 = data only

Returns: 1 = success, 0 = failure

```basic
' Export with comma delimiter and headers
stringgrid_exportcsv(grid#, "data.csv", ",", 1)

' Export with semicolon delimiter, no headers
stringgrid_exportcsv(grid#, "data.csv", ";", 0)
```

### stringgrid_importcsv(grid#, filename$, delimiter$, hasHeaders) : number
Imports data from a CSV file.

- `filename$` - File path to load
- `delimiter$` - Delimiter character
- `hasHeaders` - 1 = first row is headers (updates column headers), 0 = all data

```basic
' Import CSV file
if stringgrid_importcsv@(grid#, "data.csv", ",", 1) = 1 then
  println "Data loaded successfully"
else
  println "Error: " + stringgrid_errormsg$@()
endif
```

### stringgrid_tocsv$(grid#, delimiter$, includeHeaders) : string
Converts the grid data to a CSV string (useful for previewing or sending via network).

```basic
let csv$ = stringgrid_tocsv$@(grid#, ",", 1)
println csv$
```

### stringgrid_fromcsv(grid#, csvData$, delimiter$, hasHeaders) : number
Loads data from a CSV string.

```basic
let csv$ = "Name,Value" + chr$(13) + chr$(10) + "Alpha,100" + chr$(13) + chr$(10) + "Beta,200"
stringgrid_fromcsv(grid#, csv$, ",", 1)
```

---

## Complete Example

```basic
' Create form and grid
form# = form("CSV Demo", 100, 100, 800, 600)
grid# = stringgrid#(form#, 10, 10, 780, 400)

' Add columns
stringgrid_addcolumn#(grid#, "Product", 0, 200)
stringgrid_addcolumn#(grid#, "Price", 0, 100)
stringgrid_addcolumn#(grid#, "Stock", 0, 100)

' Configure
stringgrid_showhdr#(grid#, 1)
stringgrid_editing#(grid#, 1)

' Add sample data
stringgrid_rowcount#(grid#, 3)
stringgrid_cell#(grid#, 0, 0, "Laptop")
stringgrid_cell#(grid#, 1, 0, "999.99")
stringgrid_cell#(grid#, 2, 0, "50")

stringgrid_cell#(grid#, 0, 1, "Mouse")
stringgrid_cell#(grid#, 1, 1, "29.99")
stringgrid_cell#(grid#, 2, 1, "200")

stringgrid_cell#(grid#, 0, 2, "Keyboard")
stringgrid_cell#(grid#, 1, 2, "79.99")
stringgrid_cell#(grid#, 2, 2, "75")

' Align price column to right
stringgrid_columnalign#(grid#, 1, 2)

' Sort by price (numeric, descending - highest first)
stringgrid_sortnum(grid#, 1, 1)

' Export to CSV
stringgrid_exportcsv(grid#, "products.csv", ",", 1)

' Show as CSV string
let csv$ = stringgrid_tocsv$@(grid#, ",", 1)
println csv$

form_show(form#)
```

---

## Notes

1. **CSV Escaping**: The CSV functions properly escape fields containing delimiters, quotes, or newlines according to RFC 4180.

2. **Clipboard Format**: Copy operations use tab-separated format for compatibility with Excel and other spreadsheet applications.

3. **Sort Stability**: The sorting algorithm is a simple selection sort. For very large datasets, performance may be a consideration.

4. **Cross-Platform**: Clipboard operations use FireMonkey's IFMXClipboardService, which works on Windows, macOS, and mobile platforms.

5. **UTF-8**: CSV files are saved and loaded using UTF-8 encoding for proper Unicode support.
