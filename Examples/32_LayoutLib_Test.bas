' ============================================================================
' LayoutLib Test Suite for Plan9Basic
' Version: 1.0.1 (Fixed)
' ============================================================================
' This test suite validates all LayoutLib functions including:
' - Error handling
' - Layout creation/destruction
' - Parent/child management
' - Position and size
' - Alignment
' - Margins and padding
' - Visibility and behavior
' - Event callbacks
' ============================================================================
LET totalTests = 0
LET passedTests = 0
LET failedTests = 0
LET dummy = 0
' Helper function to report test results
FUNCTION TestResult(testName$, passed)
  totalTests = totalTests + 1
  IF passed = 1 THEN
    passedTests = passedTests + 1
    PRINTLN "[PASS] " + testName$
  ELSE
    failedTests = failedTests + 1
    PRINTLN "[FAIL] " + testName$
  ENDIF
ENDFUNCTION
' ============================================================================
' Test: Error Handling Functions
' ============================================================================
FUNCTION TestErrorHandling() LOCAL err, msg$, passed
  PRINTLN ""
  PRINTLN "=== Testing Error Handling ==="
  ' Test 1: Initial error state should be 0
  err = layout_error()
  IF err = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_error initial value is 0", passed)
  ' Test 2: Error message should be empty
  msg$ = layout_errormsg$()
  IF msg$ = "" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_errormsg$ initial is empty", passed)
  ' Test 3: Test strerror for known codes
  msg$ = layout_strerror$(0)
  IF msg$ = "No error" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_strerror$(0) = 'No error'", passed)
  msg$ = layout_strerror$(1)
  IF msg$ = "Invalid or nil layout" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_strerror$(1) = 'Invalid or nil layout'", passed)
  ' Test 4: Invalid layout should set error
  LET dummy = layout_width(Pointer#(0))
  err = layout_error()
  IF err = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("Invalid layout sets error code", passed)
  ' Test 5: Clear error
  layout_clearerror()
  err = layout_error()
  IF err = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_clearerror resets error", passed)
ENDFUNCTION
' ============================================================================
' Test: Layout Creation and Destruction
' ============================================================================
FUNCTION TestLayoutCreation() LOCAL frm#, lay1#, lay2#, lay3#, badLayout#, passed, err
  PRINTLN ""
  PRINTLN "=== Testing Layout Creation ==="
  ' Create parent form
  frm# = form#("Test Form", 800, 600)
  IF PntToNum(frm#) <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("form# created successfully", passed)
  ' Test 1: Create basic layout
  lay1# = layout#(frm#)
  IF PntToNum(lay1#) <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout#(parent#) creates layout", passed)
  ' Test 2: Create layout with size
  lay2# = layout#(frm#, 200, 100)
  IF PntToNum(lay2#) <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout#(parent#, w, h) creates layout", passed)
  IF layout_width(lay2#) = 200 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout width is 200", passed)
  IF layout_height(lay2#) = 100 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout height is 100", passed)
  ' Test 3: Create layout with position and size
  lay3# = layout#(frm#, 50, 50, 150, 75)
  IF PntToNum(lay3#) <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout#(parent#, x, y, w, h) creates layout", passed)
  IF layout_x(lay3#) = 50 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout x is 50", passed)
  IF layout_y(lay3#) = 50 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout y is 50", passed)
  IF layout_width(lay3#) = 150 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout width is 150", passed)
  IF layout_height(lay3#) = 75 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout height is 75", passed)
  ' Test 4: Free layout
  layout_free(lay3#)
  err = layout_error()
  IF err = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_free executes without error", passed)
  ' Test 5: Invalid parent should fail
  layout_clearerror()
  badLayout# = layout#(Pointer#(0))
  err = layout_error()
  IF err <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout# with nil parent fails", passed)
  ' Cleanup
  layout_free(lay2#)
  layout_free(lay1#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Parent/Child Management
' ============================================================================
FUNCTION TestParentChild() LOCAL frm#, parent1#, parent2#, child#, actualParent#, retrievedChild#, count, passed
  PRINTLN ""
  PRINTLN "=== Testing Parent/Child Management ==="
  frm# = form#("Parent Test", 800, 600)
  parent1# = layout#(frm#)
  parent2# = layout#(frm#)
  child# = layout#(parent1#)
  ' Test 1: Child has correct parent
  actualParent# = layout_parent#(child#)
  IF PntToNum(actualParent#) = PntToNum(parent1#) THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_parent# returns correct parent", passed)
  ' Test 2: Parent1 has 1 child
  count = layout_childcount(parent1#)
  IF count = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("parent1 has 1 child", passed)
  ' Test 3: Parent2 has 0 children
  count = layout_childcount(parent2#)
  IF count = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("parent2 has 0 children", passed)
  ' Test 4: Get child by index
  retrievedChild# = layout_child#(parent1#, 0)
  IF PntToNum(retrievedChild#) = PntToNum(child#) THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_child#(parent, 0) returns child", passed)
  ' Test 5: Reparent child
  layout_parent#(child#, parent2#)
  count = layout_childcount(parent1#)
  IF count = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("After reparent, parent1 has 0 children", passed)
  count = layout_childcount(parent2#)
  IF count = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("After reparent, parent2 has 1 child", passed)
  ' Test 6: BringToFront and SendToBack (should not error)
  layout_bringtofront#(child#)
  IF layout_error() = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_bringtofront# executes", passed)
  layout_sendtoback#(child#)
  IF layout_error() = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_sendtoback# executes", passed)
  ' Cleanup
  layout_free(child#)
  layout_free(parent2#)
  layout_free(parent1#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Position and Size
' ============================================================================
FUNCTION TestPositionSize() LOCAL frm#, lay#, passed
  PRINTLN ""
  PRINTLN "=== Testing Position and Size ==="
  frm# = form#("Position Test", 800, 600)
  lay# = layout#(frm#)
  layout_align#(lay#, 0)  ' None - enable manual positioning
  ' Test X position
  layout_x#(lay#, 100)
  IF layout_x(lay#) = 100 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_x# sets X position", passed)
  ' Test Y position
  layout_y#(lay#, 150)
  IF layout_y(lay#) = 150 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_y# sets Y position", passed)
  ' Test Width
  layout_width#(lay#, 250)
  IF layout_width(lay#) = 250 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_width# sets width", passed)
  ' Test Height
  layout_height#(lay#, 175)
  IF layout_height(lay#) = 175 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_height# sets height", passed)
  ' Test move
  layout_move#(lay#, 200, 200)
  IF layout_x(lay#) = 200 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_move# sets X", passed)
  IF layout_y(lay#) = 200 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_move# sets Y", passed)
  ' Test size
  layout_size#(lay#, 300, 250)
  IF layout_width(lay#) = 300 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_size# sets width", passed)
  IF layout_height(lay#) = 250 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_size# sets height", passed)
  ' Test bounds
  layout_bounds#(lay#, 50, 60, 400, 350)
  IF layout_x(lay#) = 50 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_bounds# sets X", passed)
  IF layout_y(lay#) = 60 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_bounds# sets Y", passed)
  IF layout_width(lay#) = 400 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_bounds# sets width", passed)
  IF layout_height(lay#) = 350 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_bounds# sets height", passed)
  ' Cleanup
  layout_free(lay#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Alignment
' ============================================================================
FUNCTION TestAlignment() LOCAL frm#, lay#, passed
  PRINTLN ""
  PRINTLN "=== Testing Alignment ==="
  frm# = form#("Alignment Test", 800, 600)
  lay# = layout#(frm#)
  ' Test default alignment (should be None = 0)
  IF layout_align(lay#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("Default alignment is None (0)", passed)
  ' Test setting Top alignment
  layout_align#(lay#, 1)
  IF layout_align(lay#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_align#(lay#, 1) = Top", passed)
  ' Test setting Client alignment
  layout_align#(lay#, 9)
  IF layout_align(lay#) = 9 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_align#(lay#, 9) = Client", passed)
  ' Test setting Center alignment
  layout_align#(lay#, 11)
  IF layout_align(lay#) = 11 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_align#(lay#, 11) = Center", passed)
  ' Cleanup
  layout_free(lay#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Margins
' ============================================================================
FUNCTION TestMargins() LOCAL frm#, lay#, passed
  PRINTLN ""
  PRINTLN "=== Testing Margins ==="
  frm# = form#("Margins Test", 800, 600)
  lay# = layout#(frm#)
  ' Test individual margins
  layout_marginleft#(lay#, 10)
  IF layout_marginleft(lay#) = 10 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_marginleft# sets left margin", passed)
  layout_margintop#(lay#, 20)
  IF layout_margintop(lay#) = 20 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_margintop# sets top margin", passed)
  layout_marginright#(lay#, 15)
  IF layout_marginright(lay#) = 15 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_marginright# sets right margin", passed)
  layout_marginbottom#(lay#, 25)
  IF layout_marginbottom(lay#) = 25 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_marginbottom# sets bottom margin", passed)
  ' Test margins (all at once)
  layout_margins#(lay#, 5, 10, 15, 20)
  IF layout_marginleft(lay#) = 5 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_margins# sets left", passed)
  IF layout_margintop(lay#) = 10 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_margins# sets top", passed)
  IF layout_marginright(lay#) = 15 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_margins# sets right", passed)
  IF layout_marginbottom(lay#) = 20 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_margins# sets bottom", passed)
  ' Test uniform margin
  layout_margin#(lay#, 12)
  IF layout_marginleft(lay#) = 12 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_margin# sets left uniform", passed)
  IF layout_margintop(lay#) = 12 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_margin# sets top uniform", passed)
  IF layout_marginright(lay#) = 12 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_margin# sets right uniform", passed)
  IF layout_marginbottom(lay#) = 12 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_margin# sets bottom uniform", passed)
  ' Cleanup
  layout_free(lay#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Padding
' ============================================================================
FUNCTION TestPadding() LOCAL frm#, lay#, passed
  PRINTLN ""
  PRINTLN "=== Testing Padding ==="
  frm# = form#("Padding Test", 800, 600)
  lay# = layout#(frm#)
  ' Test individual padding
  layout_paddingleft#(lay#, 8)
  IF layout_paddingleft(lay#) = 8 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_paddingleft# sets left padding", passed)
  layout_paddingtop#(lay#, 12)
  IF layout_paddingtop(lay#) = 12 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_paddingtop# sets top padding", passed)
  layout_paddingright#(lay#, 16)
  IF layout_paddingright(lay#) = 16 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_paddingright# sets right padding", passed)
  layout_paddingbottom#(lay#, 20)
  IF layout_paddingbottom(lay#) = 20 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_paddingbottom# sets bottom padding", passed)
  ' Test paddings (all at once)
  layout_paddings#(lay#, 4, 8, 12, 16)
  IF layout_paddingleft(lay#) = 4 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_paddings# sets left", passed)
  IF layout_paddingtop(lay#) = 8 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_paddings# sets top", passed)
  IF layout_paddingright(lay#) = 12 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_paddings# sets right", passed)
  IF layout_paddingbottom(lay#) = 16 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_paddings# sets bottom", passed)
  ' Test uniform padding
  layout_padding#(lay#, 10)
  IF layout_paddingleft(lay#) = 10 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_padding# sets left uniform", passed)
  IF layout_paddingtop(lay#) = 10 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_padding# sets top uniform", passed)
  IF layout_paddingright(lay#) = 10 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_padding# sets right uniform", passed)
  IF layout_paddingbottom(lay#) = 10 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_padding# sets bottom uniform", passed)
  ' Cleanup
  layout_free(lay#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Visibility and Behavior
' ============================================================================
FUNCTION TestVisibilityBehavior() LOCAL frm#, lay#, passed
  PRINTLN ""
  PRINTLN "=== Testing Visibility and Behavior ==="
  frm# = form#("Visibility Test", 800, 600)
  lay# = layout#(frm#)
  ' Test visible
  layout_visible#(lay#, 1)
  IF layout_visible(lay#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_visible#(1) sets visible", passed)
  layout_visible#(lay#, 0)
  IF layout_visible(lay#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_visible#(0) hides layout", passed)
  layout_visible#(lay#, 1)
  ' Test enabled
  layout_enabled#(lay#, 0)
  IF layout_enabled(lay#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_enabled#(0) disables layout", passed)
  layout_enabled#(lay#, 1)
  IF layout_enabled(lay#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_enabled#(1) enables layout", passed)
  ' Test opacity
  layout_opacity#(lay#, 0.5)
  IF layout_opacity(lay#) = 0.5 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_opacity#(0.5) sets opacity", passed)
  layout_opacity#(lay#, 1.0)
  IF layout_opacity(lay#) = 1.0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_opacity#(1.0) sets full opacity", passed)
  ' Test clipchildren
  layout_clipchildren#(lay#, 1)
  IF layout_clipchildren(lay#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_clipchildren#(1) enables clipping", passed)
  layout_clipchildren#(lay#, 0)
  IF layout_clipchildren(lay#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_clipchildren#(0) disables clipping", passed)
  ' Test hittest
  layout_hittest#(lay#, 0)
  IF layout_hittest(lay#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_hittest#(0) disables hit test", passed)
  layout_hittest#(lay#, 1)
  IF layout_hittest(lay#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_hittest#(1) enables hit test", passed)
  ' Test locked
  layout_locked#(lay#, 1)
  IF layout_locked(lay#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_locked#(1) locks layout", passed)
  layout_locked#(lay#, 0)
  IF layout_locked(lay#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_locked#(0) unlocks layout", passed)
  ' Cleanup
  layout_free(lay#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Tag
' ============================================================================
FUNCTION TestTag() LOCAL frm#, lay#, passed
  PRINTLN ""
  PRINTLN "=== Testing Tag ==="
  frm# = form#("Tag Test", 800, 600)
  lay# = layout#(frm#)
  ' Test tag
  layout_tag#(lay#, 42)
  IF layout_tag(lay#) = 42 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_tag#(42) sets tag", passed)
  layout_tag#(lay#, 999)
  IF layout_tag(lay#) = 999 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_tag#(999) updates tag", passed)
  layout_tag#(lay#, 0)
  IF layout_tag(lay#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_tag#(0) clears tag", passed)
  ' Cleanup
  layout_free(lay#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Invalidation
' ============================================================================
FUNCTION TestInvalidation() LOCAL frm#, lay#, passed
  PRINTLN ""
  PRINTLN "=== Testing Invalidation ==="
  frm# = form#("Invalidation Test", 800, 600)
  lay# = layout#(frm#)
  layout_invalidate#(lay#)
  IF layout_error() = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_invalidate# executes without error", passed)
  ' Cleanup
  layout_free(lay#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Event Callbacks
' ============================================================================
FUNCTION TestEventCallbacks() LOCAL frm#, lay#, funcName$, passed
  PRINTLN ""
  PRINTLN "=== Testing Event Callbacks ==="
  frm# = form#("Callback Test", 800, 600)
  lay# = layout#(frm#)
  ' Test onclick
  layout_onclick#(lay#, "MyClickHandler")
  funcName$ = layout_onclick$(lay#)
  IF funcName$ = "MyClickHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_onclick# sets handler", passed)
  ' Test ondblclick
  layout_ondblclick#(lay#, "MyDblClickHandler")
  funcName$ = layout_ondblclick$(lay#)
  IF funcName$ = "MyDblClickHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_ondblclick# sets handler", passed)
  ' Test onmousedown
  layout_onmousedown#(lay#, "MyMouseDownHandler")
  funcName$ = layout_onmousedown$(lay#)
  IF funcName$ = "MyMouseDownHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_onmousedown# sets handler", passed)
  ' Test onmouseup
  layout_onmouseup#(lay#, "MyMouseUpHandler")
  funcName$ = layout_onmouseup$(lay#)
  IF funcName$ = "MyMouseUpHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_onmouseup# sets handler", passed)
  ' Test onmousemove
  layout_onmousemove#(lay#, "MyMouseMoveHandler")
  funcName$ = layout_onmousemove$(lay#)
  IF funcName$ = "MyMouseMoveHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_onmousemove# sets handler", passed)
  ' Test onmouseenter
  layout_onmouseenter#(lay#, "MyMouseEnterHandler")
  funcName$ = layout_onmouseenter$(lay#)
  IF funcName$ = "MyMouseEnterHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_onmouseenter# sets handler", passed)
  ' Test onmouseleave
  layout_onmouseleave#(lay#, "MyMouseLeaveHandler")
  funcName$ = layout_onmouseleave$(lay#)
  IF funcName$ = "MyMouseLeaveHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_onmouseleave# sets handler", passed)
  ' Test onmousewheel
  layout_onmousewheel#(lay#, "MyMouseWheelHandler")
  funcName$ = layout_onmousewheel$(lay#)
  IF funcName$ = "MyMouseWheelHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_onmousewheel# sets handler", passed)
  ' Test onresize
  layout_onresize#(lay#, "MyResizeHandler")
  funcName$ = layout_onresize$(lay#)
  IF funcName$ = "MyResizeHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_onresize# sets handler", passed)
  ' Test onresized
  layout_onresized#(lay#, "MyResizedHandler")
  funcName$ = layout_onresized$(lay#)
  IF funcName$ = "MyResizedHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_onresized# sets handler", passed)
  ' Test onpaint
  layout_onpaint#(lay#, "MyPaintHandler")
  funcName$ = layout_onpaint$(lay#)
  IF funcName$ = "MyPaintHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_onpaint# sets handler", passed)
  ' Test clearcallbacks
  layout_clearcallbacks#(lay#)
  funcName$ = layout_onclick$(lay#)
  IF funcName$ = "" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_clearcallbacks# clears onclick", passed)
  funcName$ = layout_onresize$(lay#)
  IF funcName$ = "" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("layout_clearcallbacks# clears onresize", passed)
  ' Cleanup
  layout_free(lay#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Main Test Runner
' ============================================================================
PRINTLN "============================================"
PRINTLN "LayoutLib Test Suite"
PRINTLN "============================================"
TestErrorHandling()
TestLayoutCreation()
TestParentChild()
TestPositionSize()
TestAlignment()
TestMargins()
TestPadding()
TestVisibilityBehavior()
TestTag()
TestInvalidation()
TestEventCallbacks()
PRINTLN ""
PRINTLN "============================================"
PRINTLN "Test Results Summary"
PRINTLN "============================================"
PRINTLN "Total Tests: " + stri$(totalTests)
PRINTLN "Passed:      " + stri$(passedTests)
PRINTLN "Failed:      " + stri$(failedTests)
IF failedTests = 0 THEN
  PRINTLN ""
  PRINTLN "All tests PASSED!"
ELSE
  PRINTLN ""
  PRINTLN "Some tests FAILED. Please review the results above."
ENDIF
LET passRate = (passedTests / totalTests) * 100
PRINTLN "Pass Rate:   " + stri$(passRate) + "%"
PRINTLN "============================================"
