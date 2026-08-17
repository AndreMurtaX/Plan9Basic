' ==============================================================================
' StringGrid Demo - Plan9Basic Example Applet
' ==============================================================================
' This applet demonstrates the StringGrid control with various column types
' including String, Check, Currency, Progress, and Popup columns.
' ==============================================================================
' Global variables for controls
LET frm# = Pointer#(0)
LET grid# = Pointer#(0)
LET lblInfo# = Pointer#(0)
LET btnAddRow# = Pointer#(0)
LET btnDelRow# = Pointer#(0)
LET btnClearAll# = Pointer#(0)
' Column type constants
LET COL_STRING = 0
LET COL_CHECK = 1
LET COL_CURRENCY = 2
LET COL_DATE = 3
LET COL_GLYPH = 4
LET COL_IMAGE = 5
LET COL_POPUP = 6
LET COL_PROGRESS = 7
LET COL_TIME = 8
' Main program
GOSUB CreateForm
GOSUB CreateGrid
GOSUB CreateButtons
GOSUB PopulateData
form_show(frm#)
END 'Main applet ending
' ==============================================================================
' Create the main form
' ==============================================================================
CreateForm:
frm# = form#("StringGrid Demo - Product Inventory", 900, 680)
form_position#(frm#, 1)  ' Center on screen
RETURN
' ==============================================================================
' Create and configure the StringGrid
' ==============================================================================
CreateGrid:
grid# = stringgrid#(frm#, 20, 20, 860, 500)
' Add columns with different types
' Column 0: Product Name (String)
stringgrid_addcolumn#(grid#, "Product Name", COL_STRING, 180)
' Column 1: Category (Popup)
stringgrid_addcolumn#(grid#, "Category", COL_POPUP, 120)
stringgrid_popupadd(grid#, 1, "Electronics")
stringgrid_popupadd(grid#, 1, "Clothing")
stringgrid_popupadd(grid#, 1, "Food")
stringgrid_popupadd(grid#, 1, "Books")
stringgrid_popupadd(grid#, 1, "Tools")
' Column 2: Price (Currency)
stringgrid_addcolumn#(grid#, "Price", COL_CURRENCY, 100)
' Column 3: In Stock (Checkbox)
stringgrid_addcolumn#(grid#, "In Stock", COL_CHECK, 80)
' Column 4: Quantity (String, used as number)
stringgrid_addcolumn#(grid#, "Quantity", COL_STRING, 80)
' Column 5: Sales Progress (Progress bar)
stringgrid_addcolumn#(grid#, "Sales Progress", COL_PROGRESS, 140)
' Column 6: Last Updated (Date)
stringgrid_addcolumn#(grid#, "Last Updated", COL_DATE, 120)
' Configure grid options
stringgrid_editing#(grid#, 1)        ' Enable editing
stringgrid_showhdr#(grid#, 1)        ' Show headers
stringgrid_altcolors#(grid#, 1)      ' Alternating row colors
stringgrid_colresize#(grid#, 1)      ' Allow column resize
stringgrid_rowheight#(grid#, 28)     ' Row height
' Set up events
stringgrid_oncellclick#(grid#, "OnCellClick")
stringgrid_onheaderclick#(grid#, "OnHeaderClick")
stringgrid_oneditingdone#(grid#, "OnEditingDone")
stringgrid_onselchanged#(grid#, "OnSelChanged")
' Create info label
lblInfo# = label#(frm#, "Click a cell or header to see information", 20, 530, 500, 25)
'label_text#(lblInfo#, "Click a cell or header to see information")
RETURN
' ==============================================================================
' Create action buttons
' ==============================================================================
CreateButtons:
' Add Row button
btnAddRow# = button#(frm#, 600, 540, 120, 35)
button_text#(btnAddRow#, "Add Row")
button_onclick#(btnAddRow#, "OnAddRow")
' Delete Row button
btnDelRow# = button#(frm#, 730, 540, 120, 35)
button_text#(btnDelRow#, "Delete Row")
button_onclick#(btnDelRow#, "OnDelRow")
' Clear All button
btnClearAll# = button#(frm#, 600, 585, 250, 35)
button_text#(btnClearAll#, "Clear All Data")
button_onclick#(btnClearAll#, "OnClearAll")
RETURN
' ==============================================================================
' Populate grid with sample data
' ==============================================================================
PopulateData:
stringgrid_rowcount#(grid#, 8)
' Row 0
stringgrid_cell#(grid#, 0, 0, "Laptop Pro 15")
stringgrid_cell#(grid#, 1, 0, "Electronics")
stringgrid_cellnum#(grid#, 2, 0, 1299.99)
stringgrid_cellcheck#(grid#, 3, 0, 1)
stringgrid_cell#(grid#, 4, 0, "25")
stringgrid_cellprogress#(grid#, 5, 0, 78)
stringgrid_cell#(grid#, 6, 0, "2025-01-10")
' Row 1
stringgrid_cell#(grid#, 0, 1, "Wireless Mouse")
stringgrid_cell#(grid#, 1, 1, "Electronics")
stringgrid_cellnum#(grid#, 2, 1, 49.99)
stringgrid_cellcheck#(grid#, 3, 1, 1)
stringgrid_cell#(grid#, 4, 1, "150")
stringgrid_cellprogress#(grid#, 5, 1, 92)
stringgrid_cell#(grid#, 6, 1, "2025-01-09")
' Row 2
stringgrid_cell#(grid#, 0, 2, "Cotton T-Shirt")
stringgrid_cell#(grid#, 1, 2, "Clothing")
stringgrid_cellnum#(grid#, 2, 2, 24.99)
stringgrid_cellcheck#(grid#, 3, 2, 1)
stringgrid_cell#(grid#, 4, 2, "200")
stringgrid_cellprogress#(grid#, 5, 2, 45)
stringgrid_cell#(grid#, 6, 2, "2025-01-08")
' Row 3
stringgrid_cell#(grid#, 0, 3, "Programming Guide")
stringgrid_cell#(grid#, 1, 3, "Books")
stringgrid_cellnum#(grid#, 2, 3, 59.99)
stringgrid_cellcheck#(grid#, 3, 3, 0)
stringgrid_cell#(grid#, 4, 3, "0")
stringgrid_cellprogress#(grid#, 5, 3, 100)
stringgrid_cell#(grid#, 6, 3, "2025-01-05")
' Row 4
stringgrid_cell#(grid#, 0, 4, "Power Drill")
stringgrid_cell#(grid#, 1, 4, "Tools")
stringgrid_cellnum#(grid#, 2, 4, 89.99)
stringgrid_cellcheck#(grid#, 3, 4, 1)
stringgrid_cell#(grid#, 4, 4, "35")
stringgrid_cellprogress#(grid#, 5, 4, 55)
stringgrid_cell#(grid#, 6, 4, "2025-01-07")
' Row 5
stringgrid_cell#(grid#, 0, 5, "Organic Coffee")
stringgrid_cell#(grid#, 1, 5, "Food")
stringgrid_cellnum#(grid#, 2, 5, 15.99)
stringgrid_cellcheck#(grid#, 3, 5, 1)
stringgrid_cell#(grid#, 4, 5, "500")
stringgrid_cellprogress#(grid#, 5, 5, 88)
stringgrid_cell#(grid#, 6, 5, "2025-01-10")
' Row 6
stringgrid_cell#(grid#, 0, 6, "USB-C Hub")
stringgrid_cell#(grid#, 1, 6, "Electronics")
stringgrid_cellnum#(grid#, 2, 6, 79.99)
stringgrid_cellcheck#(grid#, 3, 6, 1)
stringgrid_cell#(grid#, 4, 6, "45")
stringgrid_cellprogress#(grid#, 5, 6, 62)
stringgrid_cell#(grid#, 6, 6, "2025-01-06")
' Row 7
stringgrid_cell#(grid#, 0, 7, "Winter Jacket")
stringgrid_cell#(grid#, 1, 7, "Clothing")
stringgrid_cellnum#(grid#, 2, 7, 149.99)
stringgrid_cellcheck#(grid#, 3, 7, 0)
stringgrid_cell#(grid#, 4, 7, "0")
stringgrid_cellprogress#(grid#, 5, 7, 100)
stringgrid_cell#(grid#, 6, 7, "2024-12-20")
RETURN
' ==============================================================================
' Event Handlers
' ==============================================================================
FUNCTION OnCellClick(sender#, col, row) LOCAL info$, value$, colName$
  colName$ = stringgrid_columnheader$(sender#, col)
  value$ = stringgrid_cell$(sender#, col, row)
  info$ = "Cell clicked: Column '" + colName$ + "' ("+str$(col)+"), Row " + str$(row) + " = '" + value$ + "'"
  label_text#(lblInfo#, info$)
END FUNCTION
FUNCTION OnHeaderClick(sender#, col) LOCAL colName$, info$
  colName$ = stringgrid_columnheader$(sender#, col)
  info$ = "Header clicked: '" + colName$ + "' (Column " + str$(col) + ")"
  label_text#(lblInfo#, info$)
  PRINTLN "Column header '" + colName$ + "' clicked - you could implement sorting here!"
END FUNCTION
FUNCTION OnEditingDone(sender#, col, row) LOCAL value$, colName$
  colName$ = stringgrid_columnheader$(sender#, col)
  value$ = stringgrid_cell$(sender#, col, row)
  PRINTLN "Editing completed: " + colName$ + "[" + str$(row) + "] = '" + value$ + "'"
  label_text#(lblInfo#, "Cell edited: " + colName$ + " = '" + value$ + "'")
END FUNCTION
FUNCTION OnSelChanged(sender#) LOCAL col, row, info$
  col = stringgrid_col(sender#)
  row = stringgrid_row(sender#)
  info$ = "Selection changed to: Column " + str$(col) + ", Row " + str$(row)
  label_text#(lblInfo#, info$)
END FUNCTION
FUNCTION OnAddRow(sender#) LOCAL newRow, rowCount
  rowCount = stringgrid_rowcount(grid#)
  stringgrid_rowcount#(grid#, rowCount + 1)
  newRow = rowCount
  ' Set default values for new row
  stringgrid_cell#(grid#, 0, newRow, "New Product")
  stringgrid_cell#(grid#, 1, newRow, "Electronics")
  stringgrid_cellnum#(grid#, 2, newRow, 0)
  stringgrid_cellcheck#(grid#, 3, newRow, 0)
  stringgrid_cell#(grid#, 4, newRow, "0")
  stringgrid_cellprogress#(grid#, 5, newRow, 0)
  stringgrid_cell#(grid#, 6, newRow, "2025-01-11")
  ' Scroll to new row and select it
  stringgrid_scrolltorow(grid#, newRow)
  stringgrid_selectcell#(grid#, 0, newRow)
  label_text#(lblInfo#, "Added new row " + str$(newRow))
  PRINTLN "New row added at index " + str$(newRow)
END FUNCTION
FUNCTION OnDelRow(sender#) LOCAL row, rowCount
  rowCount = stringgrid_rowcount(grid#)
  row = stringgrid_row(grid#)
  IF rowCount > 0 THEN
    IF row >= 0 THEN
      ' Delete selected row by setting row count -1 and shifting data
      ' Note: For simplicity, we just reduce count (deletes last row)
      stringgrid_rowcount#(grid#, rowCount - 1)
      label_text#(lblInfo#, "Deleted last row. Rows remaining: " + str$(rowCount - 1))
      PRINTLN "Row deleted. Total rows: " + str$(rowCount - 1)
    ELSE
      label_text#(lblInfo#, "No row selected")
    END IF
  ELSE
    label_text#(lblInfo#, "No rows to delete")
  END IF
END FUNCTION
FUNCTION OnClearAll(sender#)
  stringgrid_clearrows(grid#)
  label_text#(lblInfo#, "All data cleared")
  PRINTLN "All rows cleared from grid"
END FUNCTION
