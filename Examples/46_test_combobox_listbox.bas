' =============================================================================
' test_combobox_listbox.bas - Test Suite for ComboBoxLib and ListBoxLib
' =============================================================================
' For curiosity's sake...
' This example was created before the development and addition of debug
' commands to the Plan9Basic language and environment.
' That's why the ASRT function (which was originally ASSERT) was created here.
' =============================================================================
LET testsPassed = 0
LET testsFailed = 0
LET frm# = Pointer#(0)
PRINTLN "=== ComboBox and ListBox Library Test Suite ==="
PRINTLN ""
frm# = form#("Test Form", 400, 400)
TestComboBoxCreation()
TestComboBoxItems()
TestComboBoxProperties()
TestComboBoxEvents()
TestListBoxCreation()
TestListBoxItems()
TestListBoxMultiSelect()
TestListBoxProperties()
TestListBoxEvents()
TestListBoxItemHelpers()
TestErrorHandling()
PRINTLN ""
PRINTLN "=== Test Results ==="
PRINTLN "Passed: " + str$(testsPassed)
PRINTLN "Failed: " + str$(testsFailed)
PRINTLN "Total:  " + str$(testsPassed + testsFailed)
form_close(frm#)
FUNCTION ASRT(condition, testName$)
  IF condition = 1 THEN
    PRINTLN "[PASS] " + testName$
    testsPassed = testsPassed + 1
  ELSE
    PRINTLN "[FAIL] " + testName$
    testsFailed = testsFailed + 1
  END IF
END FUNCTION
FUNCTION TestComboBoxCreation() LOCAL cb#, cb2#
  PRINTLN ""
  PRINTLN "--- ComboBox Creation Tests ---"
  cb# = combobox#(frm#)
  IF PntToNum(cb#) <> 0 THEN
    ASRT(1, "ComboBox basic creation")
  ELSE
    ASRT(0, "ComboBox basic creation")
  END IF
  cb2# = combobox#(frm#, 10, 20, 150, 25)
  IF PntToNum(cb2#) <> 0 THEN
    ASRT(1, "ComboBox with position/size")
  ELSE
    ASRT(0, "ComboBox with position/size")
  END IF
  IF combobox_x(cb2#) = 10 THEN
    ASRT(1, "ComboBox initial X position")
  ELSE
    ASRT(0, "ComboBox initial X position")
  END IF
  IF combobox_y(cb2#) = 20 THEN
    ASRT(1, "ComboBox initial Y position")
  ELSE
    ASRT(0, "ComboBox initial Y position")
  END IF
  IF combobox_width(cb2#) = 150 THEN
    ASRT(1, "ComboBox initial width")
  ELSE
    ASRT(0, "ComboBox initial width")
  END IF
  IF combobox_height(cb2#) = 25 THEN
    ASRT(1, "ComboBox initial height")
  ELSE
    ASRT(0, "ComboBox initial height")
  END IF
  combobox_free(cb#)
  combobox_free(cb2#)
END FUNCTION
FUNCTION TestComboBoxItems() LOCAL cb#, idx
  PRINTLN ""
  PRINTLN "--- ComboBox Items Tests ---"
  cb# = combobox#(frm#)
  idx = combobox_add(cb#, "Item 1")
  IF idx = 0 THEN
    ASRT(1, "Add first item returns 0")
  ELSE
    ASRT(0, "Add first item returns 0")
  END IF
  idx = combobox_add(cb#, "Item 2")
  IF idx = 1 THEN
    ASRT(1, "Add second item returns 1")
  ELSE
    ASRT(0, "Add second item returns 1")
  END IF
  combobox_add(cb#, "Item 3")
  IF combobox_count(cb#) = 3 THEN
    ASRT(1, "Count after adding 3 items")
  ELSE
    ASRT(0, "Count after adding 3 items")
  END IF
  IF combobox_item$(cb#, 0) = "Item 1" THEN
    ASRT(1, "Get item at index 0")
  ELSE
    ASRT(0, "Get item at index 0")
  END IF
  IF combobox_item$(cb#, 1) = "Item 2" THEN
    ASRT(1, "Get item at index 1")
  ELSE
    ASRT(0, "Get item at index 1")
  END IF
  combobox_item#(cb#, 1, "Modified")
  IF combobox_item$(cb#, 1) = "Modified" THEN
    ASRT(1, "Set item text")
  ELSE
    ASRT(0, "Set item text")
  END IF
  combobox_insert(cb#, 1, "Inserted")
  IF combobox_item$(cb#, 1) = "Inserted" THEN
    ASRT(1, "Insert item")
  ELSE
    ASRT(0, "Insert item")
  END IF
  IF combobox_count(cb#) = 4 THEN
    ASRT(1, "Count after insert")
  ELSE
    ASRT(0, "Count after insert")
  END IF
  combobox_delete(cb#, 1)
  IF combobox_count(cb#) = 3 THEN
    ASRT(1, "Count after delete")
  ELSE
    ASRT(0, "Count after delete")
  END IF
  combobox_itemindex#(cb#, 0)
  IF combobox_itemindex(cb#) = 0 THEN
    ASRT(1, "Set/get item index")
  ELSE
    ASRT(0, "Set/get item index")
  END IF
  IF combobox_selected$(cb#) = "Item 1" THEN
    ASRT(1, "Get selected text")
  ELSE
    ASRT(0, "Get selected text")
  END IF
  idx = combobox_indexof(cb#, "Modified")
  IF idx = 1 THEN
    ASRT(1, "Index of existing item")
  ELSE
    ASRT(0, "Index of existing item")
  END IF
  idx = combobox_indexof(cb#, "NotExists")
  IF idx = -1 THEN
    ASRT(1, "Index of non-existing item")
  ELSE
    ASRT(0, "Index of non-existing item")
  END IF
  combobox_clear(cb#)
  IF combobox_count(cb#) = 0 THEN
    ASRT(1, "Clear all items")
  ELSE
    ASRT(0, "Clear all items")
  END IF
  combobox_free(cb#)
END FUNCTION
FUNCTION TestComboBoxProperties() LOCAL cb#
  PRINTLN ""
  PRINTLN "--- ComboBox Properties Tests ---"
  cb# = combobox#(frm#)
  combobox_move#(cb#, 50, 60)
  IF combobox_x(cb#) = 50 THEN
    ASRT(1, "Move X")
  ELSE
    ASRT(0, "Move X")
  END IF
  IF combobox_y(cb#) = 60 THEN
    ASRT(1, "Move Y")
  ELSE
    ASRT(0, "Move Y")
  END IF
  combobox_size#(cb#, 200, 30)
  IF combobox_width(cb#) = 200 THEN
    ASRT(1, "Size width")
  ELSE
    ASRT(0, "Size width")
  END IF
  IF combobox_height(cb#) = 30 THEN
    ASRT(1, "Size height")
  ELSE
    ASRT(0, "Size height")
  END IF
  combobox_visible#(cb#, 0)
  IF combobox_visible(cb#) = 0 THEN
    ASRT(1, "Set invisible")
  ELSE
    ASRT(0, "Set invisible")
  END IF
  combobox_visible#(cb#, 1)
  IF combobox_visible(cb#) = 1 THEN
    ASRT(1, "Set visible")
  ELSE
    ASRT(0, "Set visible")
  END IF
  combobox_enabled#(cb#, 0)
  IF combobox_enabled(cb#) = 0 THEN
    ASRT(1, "Set disabled")
  ELSE
    ASRT(0, "Set disabled")
  END IF
  combobox_enabled#(cb#, 1)
  IF combobox_enabled(cb#) = 1 THEN
    ASRT(1, "Set enabled")
  ELSE
    ASRT(0, "Set enabled")
  END IF
  combobox_tag#(cb#, 42)
  IF combobox_tag(cb#) = 42 THEN
    ASRT(1, "Set/get tag")
  ELSE
    ASRT(0, "Set/get tag")
  END IF
  combobox_dropdowncount#(cb#, 10)
  IF combobox_dropdowncount(cb#) = 10 THEN
    ASRT(1, "Set/get dropdown count")
  ELSE
    ASRT(0, "Set/get dropdown count")
  END IF
  combobox_free(cb#)
END FUNCTION
FUNCTION TestComboBoxEvents() LOCAL cb#
  PRINTLN ""
  PRINTLN "--- ComboBox Events Tests ---"
  cb# = combobox#(frm#)
  combobox_onchange#(cb#, "TestHandler")
  IF combobox_onchange$(cb#) = "TestHandler" THEN
    ASRT(1, "Set OnChange callback")
  ELSE
    ASRT(0, "Set OnChange callback")
  END IF
  combobox_onclick#(cb#, "ClickHandler")
  IF combobox_onclick$(cb#) = "ClickHandler" THEN
    ASRT(1, "Set OnClick callback")
  ELSE
    ASRT(0, "Set OnClick callback")
  END IF
  combobox_ondragover#(cb#, "DragHandler")
  IF combobox_ondragover$(cb#) = "DragHandler" THEN
    ASRT(1, "Set OnDragOver callback")
  ELSE
    ASRT(0, "Set OnDragOver callback")
  END IF
  combobox_clearcallbacks#(cb#)
  IF combobox_onchange$(cb#) = "" THEN
    ASRT(1, "Clear callbacks")
  ELSE
    ASRT(0, "Clear callbacks")
  END IF
  combobox_free(cb#)
END FUNCTION
FUNCTION TestListBoxCreation() LOCAL lb#, lb2#
  PRINTLN ""
  PRINTLN "--- ListBox Creation Tests ---"
  lb# = listbox#(frm#)
  IF PntToNum(lb#) <> 0 THEN
    ASRT(1, "ListBox basic creation")
  ELSE
    ASRT(0, "ListBox basic creation")
  END IF
  lb2# = listbox#(frm#, 10, 20, 150, 200)
  IF PntToNum(lb2#) <> 0 THEN
    ASRT(1, "ListBox with position/size")
  ELSE
    ASRT(0, "ListBox with position/size")
  END IF
  IF listbox_x(lb2#) = 10 THEN
    ASRT(1, "ListBox initial X position")
  ELSE
    ASRT(0, "ListBox initial X position")
  END IF
  IF listbox_y(lb2#) = 20 THEN
    ASRT(1, "ListBox initial Y position")
  ELSE
    ASRT(0, "ListBox initial Y position")
  END IF
  IF listbox_width(lb2#) = 150 THEN
    ASRT(1, "ListBox initial width")
  ELSE
    ASRT(0, "ListBox initial width")
  END IF
  IF listbox_height(lb2#) = 200 THEN
    ASRT(1, "ListBox initial height")
  ELSE
    ASRT(0, "ListBox initial height")
  END IF
  listbox_free(lb#)
  listbox_free(lb2#)
END FUNCTION
FUNCTION TestListBoxItems() LOCAL lb#, idx, item#
  PRINTLN ""
  PRINTLN "--- ListBox Items Tests ---"
  lb# = listbox#(frm#)
  idx = listbox_add(lb#, "Item 1")
  IF idx = 0 THEN
    ASRT(1, "Add first item returns 0")
  ELSE
    ASRT(0, "Add first item returns 0")
  END IF
  idx = listbox_add(lb#, "Item 2")
  IF idx = 1 THEN
    ASRT(1, "Add second item returns 1")
  ELSE
    ASRT(0, "Add second item returns 1")
  END IF
  listbox_add(lb#, "Item 3")
  IF listbox_count(lb#) = 3 THEN
    ASRT(1, "Count after adding 3 items")
  ELSE
    ASRT(0, "Count after adding 3 items")
  END IF
  IF listbox_item$(lb#, 0) = "Item 1" THEN
    ASRT(1, "Get item at index 0")
  ELSE
    ASRT(0, "Get item at index 0")
  END IF
  IF listbox_item$(lb#, 1) = "Item 2" THEN
    ASRT(1, "Get item at index 1")
  ELSE
    ASRT(0, "Get item at index 1")
  END IF
  listbox_item#(lb#, 1, "Modified")
  IF listbox_item$(lb#, 1) = "Modified" THEN
    ASRT(1, "Set item text")
  ELSE
    ASRT(0, "Set item text")
  END IF
  item# = listbox_additem#(lb#, "With Pointer")
  IF PntToNum(item#) <> 0 THEN
    ASRT(1, "Add item returns pointer")
  ELSE
    ASRT(0, "Add item returns pointer")
  END IF
  item# = listbox_itemat#(lb#, 0)
  IF PntToNum(item#) <> 0 THEN
    ASRT(1, "Get item pointer at index")
  ELSE
    ASRT(0, "Get item pointer at index")
  END IF
  listbox_insert(lb#, 1, "Inserted")
  IF listbox_item$(lb#, 1) = "Inserted" THEN
    ASRT(1, "Insert item")
  ELSE
    ASRT(0, "Insert item")
  END IF
  listbox_delete(lb#, 1)
  IF listbox_item$(lb#, 1) = "Modified" THEN
    ASRT(1, "Delete shifts items")
  ELSE
    ASRT(0, "Delete shifts items")
  END IF
  listbox_itemindex#(lb#, 0)
  IF listbox_itemindex(lb#) = 0 THEN
    ASRT(1, "Set/get item index")
  ELSE
    ASRT(0, "Set/get item index")
  END IF
  IF listbox_selected$(lb#) = "Item 1" THEN
    ASRT(1, "Get selected text")
  ELSE
    ASRT(0, "Get selected text")
  END IF
  idx = listbox_indexof(lb#, "Modified")
  IF idx = 1 THEN
    ASRT(1, "Index of existing item")
  ELSE
    ASRT(0, "Index of existing item")
  END IF
  listbox_clear(lb#)
  IF listbox_count(lb#) = 0 THEN
    ASRT(1, "Clear all items")
  ELSE
    ASRT(0, "Clear all items")
  END IF
  listbox_free(lb#)
END FUNCTION
FUNCTION TestListBoxMultiSelect() LOCAL lb#
  PRINTLN ""
  PRINTLN "--- ListBox Multi-Select Tests ---"
  lb# = listbox#(frm#)
  listbox_add(lb#, "Item 1")
  listbox_add(lb#, "Item 2")
  listbox_add(lb#, "Item 3")
  listbox_add(lb#, "Item 4")
  IF listbox_multiselect(lb#) = 0 THEN
    ASRT(1, "Default is single-select")
  ELSE
    ASRT(0, "Default is single-select")
  END IF
  listbox_multiselect#(lb#, 1)
  IF listbox_multiselect(lb#) = 1 THEN
    ASRT(1, "Enable multi-select")
  ELSE
    ASRT(0, "Enable multi-select")
  END IF
  listbox_selectitem#(lb#, 0, 1)
  listbox_selectitem#(lb#, 2, 1)
  IF listbox_isselected(lb#, 0) = 1 THEN
    ASRT(1, "Item 0 selected")
  ELSE
    ASRT(0, "Item 0 selected")
  END IF
  IF listbox_isselected(lb#, 1) = 0 THEN
    ASRT(1, "Item 1 not selected")
  ELSE
    ASRT(0, "Item 1 not selected")
  END IF
  IF listbox_isselected(lb#, 2) = 1 THEN
    ASRT(1, "Item 2 selected")
  ELSE
    ASRT(0, "Item 2 selected")
  END IF
  IF listbox_selcount(lb#) = 2 THEN
    ASRT(1, "Selection count is 2")
  ELSE
    ASRT(0, "Selection count is 2")
  END IF
  listbox_selectall(lb#)
  IF listbox_selcount(lb#) = 4 THEN
    ASRT(1, "Select all")
  ELSE
    ASRT(0, "Select all")
  END IF
  listbox_clearselection(lb#)
  IF listbox_selcount(lb#) = 0 THEN
    ASRT(1, "Clear selection")
  ELSE
    ASRT(0, "Clear selection")
  END IF
  listbox_free(lb#)
END FUNCTION
FUNCTION TestListBoxProperties() LOCAL lb#
  PRINTLN ""
  PRINTLN "--- ListBox Properties Tests ---"
  lb# = listbox#(frm#)
  listbox_move#(lb#, 50, 60)
  IF listbox_x(lb#) = 50 THEN
    ASRT(1, "Move X")
  ELSE
    ASRT(0, "Move X")
  END IF
  IF listbox_y(lb#) = 60 THEN
    ASRT(1, "Move Y")
  ELSE
    ASRT(0, "Move Y")
  END IF
  listbox_size#(lb#, 200, 300)
  IF listbox_width(lb#) = 200 THEN
    ASRT(1, "Size width")
  ELSE
    ASRT(0, "Size width")
  END IF
  IF listbox_height(lb#) = 300 THEN
    ASRT(1, "Size height")
  ELSE
    ASRT(0, "Size height")
  END IF
  listbox_visible#(lb#, 0)
  IF listbox_visible(lb#) = 0 THEN
    ASRT(1, "Set invisible")
  ELSE
    ASRT(0, "Set invisible")
  END IF
  listbox_visible#(lb#, 1)
  IF listbox_visible(lb#) = 1 THEN
    ASRT(1, "Set visible")
  ELSE
    ASRT(0, "Set visible")
  END IF
  listbox_enabled#(lb#, 0)
  IF listbox_enabled(lb#) = 0 THEN
    ASRT(1, "Set disabled")
  ELSE
    ASRT(0, "Set disabled")
  END IF
  listbox_enabled#(lb#, 1)
  IF listbox_enabled(lb#) = 1 THEN
    ASRT(1, "Set enabled")
  ELSE
    ASRT(0, "Set enabled")
  END IF
  listbox_tag#(lb#, 99)
  IF listbox_tag(lb#) = 99 THEN
    ASRT(1, "Set/get tag")
  ELSE
    ASRT(0, "Set/get tag")
  END IF
  listbox_free(lb#)
END FUNCTION
FUNCTION TestListBoxEvents() LOCAL lb#
  PRINTLN ""
  PRINTLN "--- ListBox Events Tests ---"
  lb# = listbox#(frm#)
  listbox_onchange#(lb#, "TestHandler")
  IF listbox_onchange$(lb#) = "TestHandler" THEN
    ASRT(1, "Set OnChange callback")
  ELSE
    ASRT(0, "Set OnChange callback")
  END IF
  listbox_onitemclick#(lb#, "ItemHandler")
  IF listbox_onitemclick$(lb#) = "ItemHandler" THEN
    ASRT(1, "Set OnItemClick callback")
  ELSE
    ASRT(0, "Set OnItemClick callback")
  END IF
  listbox_ondragover#(lb#, "DragHandler")
  IF listbox_ondragover$(lb#) = "DragHandler" THEN
    ASRT(1, "Set OnDragOver callback")
  ELSE
    ASRT(0, "Set OnDragOver callback")
  END IF
  listbox_clearcallbacks#(lb#)
  IF listbox_onchange$(lb#) = "" THEN
    ASRT(1, "Clear callbacks")
  ELSE
    ASRT(0, "Clear callbacks")
  END IF
  listbox_free(lb#)
END FUNCTION
FUNCTION TestListBoxItemHelpers() LOCAL lb#, item#
  PRINTLN ""
  PRINTLN "--- ListBoxItem Helper Tests ---"
  lb# = listbox#(frm#)
  listbox_add(lb#, "Test Item")
  item# = listbox_itemat#(lb#, 0)
  IF listboxitem_text$(item#) = "Test Item" THEN
    ASRT(1, "Get item text")
  ELSE
    ASRT(0, "Get item text")
  END IF
  listboxitem_text#(item#, "Changed")
  IF listboxitem_text$(item#) = "Changed" THEN
    ASRT(1, "Set item text")
  ELSE
    ASRT(0, "Set item text")
  END IF
  IF listboxitem_index(item#) = 0 THEN
    ASRT(1, "Get item index")
  ELSE
    ASRT(0, "Get item index")
  END IF
  listbox_multiselect#(lb#, 1)
  listboxitem_isselected#(item#, 1)
  IF listboxitem_isselected(item#) = 1 THEN
    ASRT(1, "Set item selected")
  ELSE
    ASRT(0, "Set item selected")
  END IF
  listboxitem_isselected#(item#, 0)
  IF listboxitem_isselected(item#) = 0 THEN
    ASRT(1, "Set item unselected")
  ELSE
    ASRT(0, "Set item unselected")
  END IF
  listbox_free(lb#)
END FUNCTION
FUNCTION TestErrorHandling() LOCAL cb#, lb#, dummy$
  PRINTLN ""
  PRINTLN "--- Error Handling Tests ---"
  ' Test with nil pointer
  combobox_clearerror()
  dummy$ = combobox_item$(Pointer#(0), 0)
  IF combobox_error() = 1 THEN
    ASRT(1, "ComboBox nil pointer error")
  ELSE
    ASRT(0, "ComboBox nil pointer error")
  END IF
  listbox_clearerror()
  dummy$ = listbox_item$(Pointer#(0), 0)
  IF listbox_error() = 1 THEN
    ASRT(1, "ListBox nil pointer error")
  ELSE
    ASRT(0, "ListBox nil pointer error")
  END IF
  ' Test index out of range
  cb# = combobox#(frm#)
  combobox_add(cb#, "One")
  combobox_clearerror()
  dummy$ = combobox_item$(cb#, 10)
  IF combobox_error() = 5 THEN
    ASRT(1, "ComboBox index out of range")
  ELSE
    ASRT(0, "ComboBox index out of range")
  END IF
  combobox_free(cb#)
  lb# = listbox#(frm#)
  listbox_add(lb#, "One")
  listbox_clearerror()
  dummy$ = listbox_item$(lb#, 10)
  IF listbox_error() = 5 THEN
    ASRT(1, "ListBox index out of range")
  ELSE
    ASRT(0, "ListBox index out of range")
  END IF
  listbox_free(lb#)
  ' Test error messages
  IF combobox_strerror$(0) = "No error" THEN
    ASRT(1, "ComboBox strerror 0")
  ELSE
    ASRT(0, "ComboBox strerror 0")
  END IF
  IF combobox_strerror$(5) = "Index out of range" THEN
    ASRT(1, "ComboBox strerror 5")
  ELSE
    ASRT(0, "ComboBox strerror 5")
  END IF
  IF listbox_strerror$(0) = "No error" THEN
    ASRT(1, "ListBox strerror 0")
  ELSE
    ASRT(0, "ListBox strerror 0")
  END IF
  IF listbox_strerror$(5) = "Index out of range" THEN
    ASRT(1, "ListBox strerror 5")
  ELSE
    ASRT(0, "ListBox strerror 5")
  END IF
END FUNCTION
' Dummy handler for event tests (not actually called in this test)
FUNCTION TestHandler(sender#)
END FUNCTION
FUNCTION ClickHandler(sender#)
END FUNCTION
FUNCTION DragHandler(sender#, x, y)
  RETURN 1
END FUNCTION
FUNCTION ItemHandler(sender#, item#)
END FUNCTION
