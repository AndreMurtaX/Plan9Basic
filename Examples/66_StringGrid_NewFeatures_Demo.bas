' ============================================================================
' StringGridLib 1.1.0 - New Features Demo
' Demonstrates: Row operations, Sorting, Clipboard, CSV import/export
' ============================================================================
LET form# = Pointer#(0)
LET grid# = Pointer#(0)
LET lblStatus# = Pointer#(0)
LET btnInsert# = Pointer#(0)
LET btnDelete# = Pointer#(0)
LET btnMoveUp# = Pointer#(0)
LET btnMoveDown# = Pointer#(0)
LET btnSortAsc# = Pointer#(0)
LET btnSortDesc# = Pointer#(0)
LET btnSortNumAsc# = Pointer#(0)
LET btnSortNumDesc# = Pointer#(0)
LET btnCopy# = Pointer#(0)
LET btnPaste# = Pointer#(0)
LET btnCopyCell# = Pointer#(0)
LET btnPasteCell# = Pointer#(0)
LET btnExportCSV# = Pointer#(0)
LET btnImportCSV# = Pointer#(0)
LET btnToCSV# = Pointer#(0)
LET btnFromCSV# = Pointer#(0)
LET btnAlignLeft# = Pointer#(0)
LET btnAlignCenter# = Pointer#(0)
LET btnAlignRight# = Pointer#(0)
LET txtCSV# = Pointer#(0)
' Column type constants
LET COL_STRING = 0
LET COL_CHECK = 1
LET COL_PROGRESS = 7
' Text alignment constants
LET ALIGN_CENTER = 0
LET ALIGN_LEFT = 1
LET ALIGN_RIGHT = 2
' ============================================================================
' Main Program
' ============================================================================
form# = form#("StringGrid 1.1.0 - New Features Demo", 1000, 700)
' Create StringGrid
grid# = stringgrid#(form#, 10, 10, 600, 400)
' Add columns
stringgrid_addcolumn#(grid#, "ID", COL_STRING, 50)
stringgrid_addcolumn#(grid#, "Name", COL_STRING, 150)
stringgrid_addcolumn#(grid#, "Value", COL_STRING, 80)
stringgrid_addcolumn#(grid#, "Active", COL_CHECK, 60)
stringgrid_addcolumn#(grid#, "Progress", COL_PROGRESS, 100)
' Configure grid
stringgrid_showhdr#(grid#, 1)
stringgrid_editing#(grid#, 1)
stringgrid_altcolors#(grid#, 1)
' Add sample data
GOSUB LoadSampleData
' Create Row Operations buttons
label#(form#, "Row Operations:", 620, 10, 150, 20)
btnInsert# = button#(form#, "Insert Row", 620, 35, 100, 30)
btnDelete# = button#(form#, "Delete Row", 730, 35, 100, 30)
btnMoveUp# = button#(form#, "Move Up", 620, 70, 100, 30)
btnMoveDown# = button#(form#, "Move Down", 730, 70, 100, 30)
' Create Sorting buttons
label#(form#, "Sorting (by Name column):", 620, 110, 200, 20)
btnSortAsc# = button#(form#, "Sort A-Z", 620, 135, 100, 30)
btnSortDesc# = button#(form#, "Sort Z-A", 730, 135, 100, 30)
label#(form#, "Sorting (by Value column):", 620, 175, 200, 20)
btnSortNumAsc# = button#(form#, "Sort 0-9", 620, 200, 100, 30)
btnSortNumDesc# = button#(form#, "Sort 9-0", 730, 200, 100, 30)
' Create Clipboard buttons
label#(form#, "Clipboard:", 620, 240, 150, 20)
btnCopy# = button#(form#, "Copy All", 620, 265, 100, 30)
btnPaste# = button#(form#, "Paste", 730, 265, 100, 30)
btnCopyCell# = button#(form#, "Copy Cell", 620, 300, 100, 30)
btnPasteCell# = button#(form#, "Paste Cell", 730, 300, 100, 30)
' Create Column Alignment buttons
label#(form#, "Name Column Alignment:", 620, 340, 200, 20)
btnAlignLeft# = button#(form#, "Left", 620, 365, 65, 30)
btnAlignCenter# = button#(form#, "Center", 690, 365, 65, 30)
btnAlignRight# = button#(form#, "Right", 760, 365, 65, 30)
' Create CSV buttons
label#(form#, "CSV Operations:", 620, 405, 150, 20)
btnExportCSV# = button#(form#, "Export CSV", 620, 430, 100, 30)
btnImportCSV# = button#(form#, "Import CSV", 730, 430, 100, 30)
btnToCSV# = button#(form#, "To String", 620, 465, 100, 30)
btnFromCSV# = button#(form#, "From String", 730, 465, 100, 30)
' CSV text display
label#(form#, "CSV Preview:", 10, 420, 100, 20)
txtCSV# = memo#(form#, 10, 445, 600, 200)
memo_readonly#(txtCSV#, 0)
' Status label
lblStatus# = label#(form#, "Ready. Select a row and try the operations.", 10, 655, 980, 25)
' Set up event handlers
button_onclick#(btnInsert#, "OnInsertRow")
button_onclick#(btnDelete#, "OnDeleteRow")
button_onclick#(btnMoveUp#, "OnMoveUp")
button_onclick#(btnMoveDown#, "OnMoveDown")
button_onclick#(btnSortAsc#, "OnSortAsc")
button_onclick#(btnSortDesc#, "OnSortDesc")
button_onclick#(btnSortNumAsc#, "OnSortNumAsc")
button_onclick#(btnSortNumDesc#, "OnSortNumDesc")
button_onclick#(btnCopy#, "OnCopyAll")
button_onclick#(btnPaste#, "OnPaste")
button_onclick#(btnCopyCell#, "OnCopyCell")
button_onclick#(btnPasteCell#, "OnPasteCell")
button_onclick#(btnAlignLeft#, "OnAlignLeft")
button_onclick#(btnAlignCenter#, "OnAlignCenter")
button_onclick#(btnAlignRight#, "OnAlignRight")
button_onclick#(btnExportCSV#, "OnExportCSV")
button_onclick#(btnImportCSV#, "OnImportCSV")
button_onclick#(btnToCSV#, "OnToCSV")
button_onclick#(btnFromCSV#, "OnFromCSV")
stringgrid_oncellclick#(grid#, "OnCellClick")
form_show(form#)
END
' ============================================================================
' Load Sample Data
' ============================================================================
LoadSampleData:
stringgrid_rowcount#(grid#, 8)
' Row 0
stringgrid_cell#(grid#, 0, 0, "1")
stringgrid_cell#(grid#, 1, 0, "Alpha")
stringgrid_cell#(grid#, 2, 0, "100")
stringgrid_cellcheck#(grid#, 3, 0, 1)
stringgrid_cellprogress#(grid#, 4, 0, 75)
' Row 1
stringgrid_cell#(grid#, 0, 1, "2")
stringgrid_cell#(grid#, 1, 1, "Delta")
stringgrid_cell#(grid#, 2, 1, "250")
stringgrid_cellcheck#(grid#, 3, 1, 0)
stringgrid_cellprogress#(grid#, 4, 1, 30)
' Row 2
stringgrid_cell#(grid#, 0, 2, "3")
stringgrid_cell#(grid#, 1, 2, "Beta")
stringgrid_cell#(grid#, 2, 2, "50")
stringgrid_cellcheck#(grid#, 3, 2, 1)
stringgrid_cellprogress#(grid#, 4, 2, 100)
' Row 3
stringgrid_cell#(grid#, 0, 3, "4")
stringgrid_cell#(grid#, 1, 3, "Gamma")
stringgrid_cell#(grid#, 2, 3, "175")
stringgrid_cellcheck#(grid#, 3, 3, 1)
stringgrid_cellprogress#(grid#, 4, 3, 60)
' Row 4
stringgrid_cell#(grid#, 0, 4, "5")
stringgrid_cell#(grid#, 1, 4, "Zeta")
stringgrid_cell#(grid#, 2, 4, "300")
stringgrid_cellcheck#(grid#, 3, 4, 0)
stringgrid_cellprogress#(grid#, 4, 4, 15)
' Row 5
stringgrid_cell#(grid#, 0, 5, "6")
stringgrid_cell#(grid#, 1, 5, "Epsilon")
stringgrid_cell#(grid#, 2, 5, "80")
stringgrid_cellcheck#(grid#, 3, 5, 1)
stringgrid_cellprogress#(grid#, 4, 5, 90)
' Row 6
stringgrid_cell#(grid#, 0, 6, "7")
stringgrid_cell#(grid#, 1, 6, "Theta")
stringgrid_cell#(grid#, 2, 6, "425")
stringgrid_cellcheck#(grid#, 3, 6, 0)
stringgrid_cellprogress#(grid#, 4, 6, 45)
' Row 7
stringgrid_cell#(grid#, 0, 7, "8")
stringgrid_cell#(grid#, 1, 7, "Omega")
stringgrid_cell#(grid#, 2, 7, "999")
stringgrid_cellcheck#(grid#, 3, 7, 1)
stringgrid_cellprogress#(grid#, 4, 7, 100)
RETURN
' ============================================================================
' Event Handlers - Row Operations
' ============================================================================
FUNCTION OnInsertRow(sender#) LOCAL row
  LET row = stringgrid_row(grid#)
  IF row < 0 THEN row = 0
  stringgrid_insertrow(grid#, row)
  label_text#(lblStatus#, "Inserted new row at position " + stri$(row))
END FUNCTION
FUNCTION OnDeleteRow(sender#) LOCAL row
  LET row = stringgrid_row(grid#)
  IF row < 0 THEN
    label_text#(lblStatus#, "Select a row first")
    RETURN 0
  END IF
  stringgrid_deleterow(grid#, row)
  label_text#(lblStatus#, "Deleted row " + stri$(row))
END FUNCTION
FUNCTION OnMoveUp(sender#) LOCAL row
  LET row = stringgrid_row(grid#)
  IF row <= 0 THEN
    label_text#(lblStatus#, "Cannot move up - at top or no selection")
    RETURN 0
  END IF
  stringgrid_swaprows(grid#, row, row - 1)
  stringgrid_row#(grid#, row - 1)
  label_text#(lblStatus#, "Moved row " + stri$(row) + " up")
END FUNCTION
FUNCTION OnMoveDown(sender#) LOCAL row, maxRow
  LET row = stringgrid_row(grid#)
  LET maxRow = stringgrid_rowcount(grid#) - 1
  IF row < 0 THEN
    label_text#(lblStatus#, "Select a row first")
    RETURN 0
  END IF
  IF row >= maxRow THEN
    label_text#(lblStatus#, "Cannot move down - at bottom")
    RETURN 0
  END IF
  stringgrid_swaprows(grid#, row, row + 1)
  stringgrid_row#(grid#, row + 1)
  label_text#(lblStatus#, "Moved row " + stri$(row) + " down")
END FUNCTION
' ============================================================================
' Event Handlers - Sorting
' ============================================================================
FUNCTION OnSortAsc(sender#)
  stringgrid_sort(grid#, 1, 0)  ' Column 1 (Name), Ascending
  label_text#(lblStatus#, "Sorted by Name (A-Z)")
END FUNCTION
FUNCTION OnSortDesc(sender#)
  stringgrid_sort(grid#, 1, 1)  ' Column 1 (Name), Descending
  label_text#(lblStatus#, "Sorted by Name (Z-A)")
END FUNCTION
FUNCTION OnSortNumAsc(sender#)
  stringgrid_sortnum(grid#, 2, 0)  ' Column 2 (Value), Ascending
  label_text#(lblStatus#, "Sorted by Value (0-9)")
END FUNCTION
FUNCTION OnSortNumDesc(sender#)
  stringgrid_sortnum(grid#, 2, 1)  ' Column 2 (Value), Descending
  label_text#(lblStatus#, "Sorted by Value (9-0)")
END FUNCTION
' ============================================================================
' Event Handlers - Clipboard
' ============================================================================
FUNCTION OnCopyAll(sender#) LOCAL result
  LET result = stringgrid_copy(grid#)
  IF result = 1 THEN
    label_text#(lblStatus#, "Copied entire grid to clipboard (tab-separated)")
  ELSE
    label_text#(lblStatus#, "Failed to copy: " + stringgrid_errormsg$())
  END IF
END FUNCTION
FUNCTION OnPaste(sender#) LOCAL result
  LET result = stringgrid_paste(grid#)
  IF result = 1 THEN
    label_text#(lblStatus#, "Pasted from clipboard")
  ELSE
    label_text#(lblStatus#, "Failed to paste: " + stringgrid_errormsg$())
  END IF
END FUNCTION
FUNCTION OnCopyCell(sender#) LOCAL col, row, result
  LET col = stringgrid_col(grid#)
  LET row = stringgrid_row(grid#)
  IF col < 0 THEN
    label_text#(lblStatus#, "Select a cell first")
    RETURN 0
  END IF
  IF row < 0 THEN
    label_text#(lblStatus#, "Select a cell first")
    RETURN 0
  END IF
  LET result = stringgrid_copycell(grid#, col, row)
  IF result = 1 THEN
    label_text#(lblStatus#, "Copied cell [" + stri$(col) + "," + stri$(row) + "] to clipboard")
  ELSE
    label_text#(lblStatus#, "Failed to copy cell")
  END IF
END FUNCTION
FUNCTION OnPasteCell(sender#) LOCAL col, row, result
  LET col = stringgrid_col(grid#)
  LET row = stringgrid_row(grid#)
  IF col < 0 THEN
    label_text#(lblStatus#, "Select a cell first")
    RETURN 0
  END IF
  IF row < 0 THEN
    label_text#(lblStatus#, "Select a cell first")
    RETURN 0
  END IF
  LET result = stringgrid_pastecell(grid#, col, row)
  IF result = 1 THEN
    label_text#(lblStatus#, "Pasted to cell [" + stri$(col) + "," + stri$(row) + "]")
  ELSE
    label_text#(lblStatus#, "Failed to paste to cell")
  END IF
END FUNCTION
' ============================================================================
' Event Handlers - Column Alignment
' ============================================================================
FUNCTION OnAlignLeft(sender#)
  stringgrid_columnalign#(grid#, 1, 1)  ' Column 1, Leading (Left)
  label_text#(lblStatus#, "Name column aligned left")
END FUNCTION
FUNCTION OnAlignCenter(sender#)
  stringgrid_columnalign#(grid#, 1, 0)  ' Column 1, Center
  label_text#(lblStatus#, "Name column aligned center")
END FUNCTION
FUNCTION OnAlignRight(sender#)
  stringgrid_columnalign#(grid#, 1, 2)  ' Column 1, Trailing (Right)
  label_text#(lblStatus#, "Name column aligned right")
END FUNCTION
' ============================================================================
' Event Handlers - CSV
' ============================================================================
FUNCTION OnExportCSV(sender#) LOCAL filename$, result
  LET filename$ = "grid_export.csv"
  LET result = stringgrid_exportcsv(grid#, filename$, ",", 1)
  IF result = 1 THEN
    label_text#(lblStatus#, "Exported to " + filename$)
  ELSE
    label_text#(lblStatus#, "Export failed: " + stringgrid_errormsg$())
  END IF
END FUNCTION
FUNCTION OnImportCSV(sender#) LOCAL filename$, result
  LET filename$ = "grid_export.csv"
  LET result = stringgrid_importcsv(grid#, filename$, ",", 1)
  IF result = 1 THEN
    label_text#(lblStatus#, "Imported from " + filename$)
  ELSE
    label_text#(lblStatus#, "Import failed: " + stringgrid_errormsg$())
  END IF
END FUNCTION
FUNCTION OnToCSV(sender#) LOCAL csv$
  LET csv$ = stringgrid_tocsv$(grid#, ",", 1)
  memo_text#(txtCSV#, csv$)
  label_text#(lblStatus#, "Grid converted to CSV string (shown below)")
END FUNCTION
FUNCTION OnFromCSV(sender#) LOCAL csv$, result
  LET csv$ = memo_text$(txtCSV#)
  IF len(csv$) = 0 THEN
    label_text#(lblStatus#, "Enter CSV data in the text area first")
    RETURN 0
  END IF
  LET result = stringgrid_fromcsv(grid#, csv$, ",", 1)
  IF result = 1 THEN
    label_text#(lblStatus#, "Loaded data from CSV string")
  ELSE
    label_text#(lblStatus#, "Failed to parse CSV: " + stringgrid_errormsg$())
  END IF
END FUNCTION
' ============================================================================
' Cell Click Handler
' ============================================================================
FUNCTION OnCellClick(sender#, col, row) LOCAL value$, header$
  LET value$ = stringgrid_cell$(grid#, col, row)
  LET header$ = stringgrid_columnheader$(grid#, col)
  label_text#(lblStatus#, "Selected: " + header$ + "[" + stri$(row) + "] = '" + value$ + "'")
END FUNCTION
