' =============================================================================
' demo_combobox_listbox.bas - ComboBox and ListBox Demo for Plan9Basic
' =============================================================================
' Global variables
LET frm# = Pointer#(0)
LET cbColors# = Pointer#(0)
LET cbSizes# = Pointer#(0)
LET lbItems# = Pointer#(0)
LET lbSelected# = Pointer#(0)
LET btnAdd# = Pointer#(0)
LET btnRemove# = Pointer#(0)
LET btnMoveRight# = Pointer#(0)
LET btnMoveLeft# = Pointer#(0)
LET lblStatus# = Pointer#(0)
' Create main form
frm# = form#("ComboBox & ListBox Demo", 700, 500)
form_position#(frm#, 1)
' Create labels
LET lbl1# = label#(frm#, "Color:")
label_move#(lbl1#, 20, 20)
LET lbl2# = label#(frm#, "Size:")
label_move#(lbl2#, 20, 60)
LET lbl3# = label#(frm#, "Available Items:")
label_move#(lbl3#, 20, 110)
LET lbl4# = label#(frm#, "Selected Items:")
label_move#(lbl4#, 400, 110)
' Create Color ComboBox
cbColors# = combobox#(frm#, 100, 15, 150, 25)
combobox_add(cbColors#, "Red")
combobox_add(cbColors#, "Green")
combobox_add(cbColors#, "Blue")
combobox_add(cbColors#, "Yellow")
combobox_add(cbColors#, "Purple")
combobox_add(cbColors#, "Orange")
combobox_itemindex#(cbColors#, 0)
combobox_onchange#(cbColors#, "OnColorChange")
' Create Size ComboBox
cbSizes# = combobox#(frm#, 100, 55, 150, 25)
combobox_add(cbSizes#, "Small")
combobox_add(cbSizes#, "Medium")
combobox_add(cbSizes#, "Large")
combobox_add(cbSizes#, "Extra Large")
combobox_itemindex#(cbSizes#, 1)
combobox_onchange#(cbSizes#, "OnSizeChange")
' Create Available Items ListBox
lbItems# = listbox#(frm#, 20, 130, 200, 250)
listbox_multiselect#(lbItems#, 1)
listbox_add(lbItems#, "Apple")
listbox_add(lbItems#, "Banana")
listbox_add(lbItems#, "Cherry")
listbox_add(lbItems#, "Date")
listbox_add(lbItems#, "Elderberry")
listbox_add(lbItems#, "Fig")
listbox_add(lbItems#, "Grape")
listbox_add(lbItems#, "Honeydew")
listbox_onchange#(lbItems#, "OnItemsChange")
listbox_onitemclick#(lbItems#, "OnItemClick")
' Create Selected Items ListBox
lbSelected# = listbox#(frm#, 400, 130, 200, 250)
listbox_multiselect#(lbSelected#, 1)
listbox_onchange#(lbSelected#, "OnSelectedChange")
' Create transfer buttons
btnMoveRight# = button#(frm#, ">>")
button_bounds#(btnMoveRight#, 250, 200, 60, 30)
button_onclick#(btnMoveRight#, "OnMoveRight")
btnMoveLeft# = button#(frm#, "<<")
button_bounds#(btnMoveLeft#, 320, 200, 60, 30)
button_onclick#(btnMoveLeft#, "OnMoveLeft")
btnAdd# = button#(frm#, "Add New")
button_bounds#(btnAdd#, 250, 250, 130, 30)
button_onclick#(btnAdd#, "OnAddNew")
btnRemove# = button#(frm#, "Remove Sel")
button_bounds#(btnRemove#, 250, 290, 130, 30)
button_onclick#(btnRemove#, "OnRemove")
' Status label
lblStatus# = label#(frm#, "Ready - Select items and use buttons to transfer")
label_bounds#(lblStatus#, 20, 400, 660, 80)
label_wordwrap#(lblStatus#, 1)
' Show the form
form_show(frm#)
FUNCTION OnColorChange(sender#) LOCAL idx, txt$
  idx = combobox_itemindex(sender#)
  IF idx >= 0 THEN
    txt$ = combobox_item$(sender#, idx)
    UpdateStatus("Color changed to: " + txt$)
  END IF
END FUNCTION
FUNCTION OnSizeChange(sender#) LOCAL idx, txt$
  idx = combobox_itemindex(sender#)
  IF idx >= 0 THEN
    txt$ = combobox_item$(sender#, idx)
    UpdateStatus("Size changed to: " + txt$)
  END IF
END FUNCTION
FUNCTION OnItemsChange(sender#) LOCAL cnt
  cnt = listbox_selcount(sender#)
  UpdateStatus("Available items: " + str$(cnt) + " selected")
ENDFUNCTION
FUNCTION OnSelectedChange(sender#) LOCAL cnt
  cnt = listbox_selcount(sender#)
  UpdateStatus("Selected items: " + str$(cnt) + " marked")
END FUNCTION
FUNCTION OnItemClick(sender#, item#) LOCAL txt$
  txt$ = listboxitem_text$(item#)
  UpdateStatus("Clicked: " + txt$)
END FUNCTION
FUNCTION OnMoveRight(sender#) LOCAL i, cnt, txt$
  cnt = listbox_count(lbItems#)
  i = cnt - 1
  WHILE i >= 0
    IF listbox_isselected(lbItems#, i) = 1 THEN
      txt$ = listbox_item$(lbItems#, i)
      listbox_add(lbSelected#, txt$)
      listbox_delete(lbItems#, i)
    END IF
    i = i - 1
  END WHILE
  UpdateStatus("Moved items to selected list")
END FUNCTION
FUNCTION OnMoveLeft(sender#) LOCAL i, cnt, txt$
  cnt = listbox_count(lbSelected#)
  i = cnt - 1
  WHILE i >= 0
    IF listbox_isselected(lbSelected#, i) = 1 THEN
      txt$ = listbox_item$(lbSelected#, i)
      listbox_add(lbItems#, txt$)
      listbox_delete(lbSelected#, i)
    END IF
    i = i - 1
  END WHILE
  UpdateStatus("Moved items back to available list")
END FUNCTION
FUNCTION OnAddNew(sender#) LOCAL newItem$, cnt
  cnt = listbox_count(lbItems#) + listbox_count(lbSelected#)
  newItem$ = "New Item " + str$(cnt + 1)
  listbox_add(lbItems#, newItem$)
  UpdateStatus("Added: " + newItem$)
END FUNCTION
FUNCTION OnRemove(sender#) LOCAL i, cnt, removed
  removed = 0
  ' Remove from selected list
  cnt = listbox_count(lbSelected#)
  i = cnt - 1
  WHILE i >= 0
    IF listbox_isselected(lbSelected#, i) = 1 THEN
      listbox_delete(lbSelected#, i)
      removed = removed + 1
    END IF
    i = i - 1
  END WHILE
  ' Remove from available list
  cnt = listbox_count(lbItems#)
  i = cnt - 1
  WHILE i >= 0
    IF listbox_isselected(lbItems#, i) = 1 THEN
      listbox_delete(lbItems#, i)
      removed = removed + 1
    END IF
    i = i - 1
  END WHILE
  UpdateStatus("Removed " + str$(removed) + " item(s)")
END FUNCTION
FUNCTION UpdateStatus(msg$) LOCAL color$, size$, idx
  LET color$ = ""
  LET size$ = ""
  LET idx = 0
  idx = combobox_itemindex(cbColors#)
  IF idx >= 0 THEN
    color$ = combobox_item$(cbColors#, idx)
  END IF
  idx = combobox_itemindex(cbSizes#)
  IF idx >= 0 THEN
    size$ = combobox_item$(cbSizes#, idx)
  END IF
  label_text#(lblStatus#, msg$ + chr$(13) + chr$(10) + "Current: " + color$ + ", " + size$)
END FUNCTION
