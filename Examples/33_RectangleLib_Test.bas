' ============================================================================
' RectangleLib Test Suite for Plan9Basic
' Version: 1.0.0
' ============================================================================
' This test suite validates all RectangleLib functions including:
' - Error handling
' - Rectangle creation/destruction
' - Fill and stroke styling
' - Corner radius
' - Sides and corners flags
' - Position and size
' - Alignment and margins
' - Visibility and behavior
' - Event callbacks
' ============================================================================
LET totalTests = 0
LET passedTests = 0
LET failedTests = 0
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
FUNCTION TestErrorHandling() LOCAL err, msg$, passed, dummy
  PRINTLN ""
  PRINTLN "=== Testing Error Handling ==="
  ' Test 1: Initial error state should be 0
  err = rectangle_error()
  IF err = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_error initial value is 0", passed)
  ' Test 2: Error message should be empty
  msg$ = rectangle_errormsg$()
  IF msg$ = "" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_errormsg$ initial is empty", passed)
  ' Test 3: Test strerror for known codes
  msg$ = rectangle_strerror$(0)
  IF msg$ = "No error" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_strerror$(0) = 'No error'", passed)
  msg$ = rectangle_strerror$(1)
  IF msg$ = "Invalid or nil rectangle" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_strerror$(1) = 'Invalid or nil rectangle'", passed)
  ' Test 4: Invalid rect should set error
  dummy = rectangle_width(Pointer#(0))
  err = rectangle_error()
  IF err = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("Invalid rect sets error code", passed)
  ' Test 5: Clear error
  rectangle_clearerror()
  err = rectangle_error()
  IF err = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_clearerror resets error", passed)
ENDFUNCTION
' ============================================================================
' Test: Rectangle Creation and Destruction
' ============================================================================
FUNCTION TestRectCreation() LOCAL frm#, r1#, r2#, r3#, badRect#, passed, err
  PRINTLN ""
  PRINTLN "=== Testing Rectangle Creation ==="
  ' Create parent form
  frm# = form#("Test Form", 800, 600)
  IF PntToNum(frm#) <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("form# created successfully", passed)
  ' Test 1: Create basic rectangle
  r1# = rectangle#(frm#)
  IF PntToNum(r1#) <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle#(parent#) creates rectangle", passed)
  ' Test 2: Create rectangle with size
  r2# = rectangle#(frm#, 200, 100)
  IF PntToNum(r2#) <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle#(parent#, w, h) creates rectangle", passed)
  IF rectangle_width(r2#) = 200 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rect width is 200", passed)
  IF rectangle_height(r2#) = 100 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rect height is 100", passed)
  ' Test 3: Create rectangle with position and size
  r3# = rectangle#(frm#, 50, 60, 150, 75)
  IF PntToNum(r3#) <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle#(parent#, x, y, w, h) creates rectangle", passed)
  IF rectangle_x(r3#) = 50 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rect x is 50", passed)
  IF rectangle_y(r3#) = 60 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rect y is 60", passed)
  ' Test 4: Free rectangle
  rectangle_free(r3#)
  err = rectangle_error()
  IF err = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_free executes without error", passed)
  ' Test 5: Invalid parent should fail
  rectangle_clearerror()
  badrect# = rectangle#(Pointer#(0))
  err = rectangle_error()
  IF err <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle# with nil parent fails", passed)
  ' Cleanup
  rectangle_free(r2#)
  rectangle_free(r1#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Fill and Stroke
' ============================================================================
FUNCTION TestFillStroke() LOCAL frm#, r#, passed, color$, thickness
  PRINTLN ""
  PRINTLN "=== Testing Fill and Stroke ==="
  frm# = form#("Fill Test", 800, 600)
  r# = rectangle#(frm#, 50, 50, 100, 100)
  ' Test fill color
  rectangle_fill#(r#, "#FF0000")
  color$ = rectangle_fill$(r#)
  IF color$ = "#FFFF0000" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_fill# sets red color", passed)
  rectangle_fill#(r#, "blue")
  color$ = rectangle_fill$(r#)
  IF color$ = "#FF0000FF" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_fill# sets blue by name", passed)
  ' Test stroke color
  rectangle_stroke#(r#, "#00FF00")
  color$ = rectangle_stroke$(r#)
  IF color$ = "#FF00FF00" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_stroke# sets green color", passed)
  ' Test stroke thickness
  rectangle_strokethickness#(r#, 5)
  thickness = rectangle_strokethickness(r#)
  IF thickness = 5 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_strokethickness# sets thickness", passed)
  ' Test stroke dash
  rectangle_strokedash#(r#, 1)
  IF rectangle_strokedash(r#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_strokedash# sets dash style", passed)
  ' Test stroke cap
  rectangle_strokecap#(r#, 1)
  IF rectangle_strokecap(r#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_strokecap# sets cap style", passed)
  ' Test stroke join
  rectangle_strokejoin#(r#, 2)
  IF rectangle_strokejoin(r#) = 2 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_strokejoin# sets join style", passed)
  ' Cleanup
  rectangle_free(r#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Corner Radius
' ============================================================================
FUNCTION TestCornerRadius() LOCAL frm#, r#, passed
  PRINTLN ""
  PRINTLN "=== Testing Corner Radius ==="
  frm# = form#("Corner Test", 800, 600)
  r# = rectangle#(frm#, 50, 50, 100, 100)
  ' Test X radius
  rectangle_xradius#(r#, 10)
  IF rectangle_xradius(r#) = 10 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_xradius# sets X radius", passed)
  ' Test Y radius
  rectangle_yradius#(r#, 15)
  IF rectangle_yradius(r#) = 15 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_yradius# sets Y radius", passed)
  ' Test corners (both at once)
  rectangle_corners#(r#, 20, 25)
  IF rectangle_xradius(r#) = 20 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_corners# sets X radius", passed)
  IF rectangle_yradius(r#) = 25 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_corners# sets Y radius", passed)
  ' Cleanup
  rectangle_free(r#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Sides and Corners Flags
' ============================================================================
FUNCTION TestSidesCorners() LOCAL frm#, r#, passed
  PRINTLN ""
  PRINTLN "=== Testing Sides and Corners Flags ==="
  frm# = form#("Sides Test", 800, 600)
  r# = rectangle#(frm#, 50, 50, 100, 100)
  ' Test sides - all (15)
  IF rectangle_sides(r#) = 15 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("Default sides is 15 (all)", passed)
  ' Set only top and bottom (1 + 4 = 5)
  rectangle_sides#(r#, 5)
  IF rectangle_sides(r#) = 5 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_sides# sets top+bottom (5)", passed)
  ' Test corners - all (15)
  IF rectangle_cornersflags(r#) = 15 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("Default corners is 15 (all)", passed)
  ' Set only top corners (1 + 2 = 3)
  rectangle_cornersflags#(r#, 3)
  IF rectangle_cornersflags(r#) = 3 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_cornersflags# sets top corners (3)", passed)
  ' Cleanup
  rectangle_free(r#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Position and Size
' ============================================================================
FUNCTION TestPositionSize() LOCAL frm#, r#, passed
  PRINTLN ""
  PRINTLN "=== Testing Position and Size ==="
  frm# = form#("Position Test", 800, 600)
  r# = rectangle#(frm#)
  rectangle_align#(r#, 0)  ' None - enable manual positioning
  ' Test X position
  rectangle_x#(r#, 100)
  IF rectangle_x(r#) = 100 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_x# sets X position", passed)
  ' Test Y position
  rectangle_y#(r#, 150)
  IF rectangle_y(r#) = 150 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_y# sets Y position", passed)
  ' Test Width
  rectangle_width#(r#, 250)
  IF rectangle_width(r#) = 250 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_width# sets width", passed)
  ' Test Height
  rectangle_height#(r#, 175)
  IF rectangle_height(r#) = 175 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_height# sets height", passed)
  ' Test move
  rectangle_move#(r#, 200, 200)
  IF rectangle_x(r#) = 200 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_move# sets X", passed)
  IF rectangle_y(r#) = 200 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_move# sets Y", passed)
  ' Test size
  rectangle_size#(r#, 300, 250)
  IF rectangle_width(r#) = 300 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_size# sets width", passed)
  IF rectangle_height(r#) = 250 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_size# sets height", passed)
  ' Test bounds
  rectangle_bounds#(r#, 50, 60, 400, 350)
  IF rectangle_x(r#) = 50 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_bounds# sets X", passed)
  IF rectangle_y(r#) = 60 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_bounds# sets Y", passed)
  IF rectangle_width(r#) = 400 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_bounds# sets width", passed)
  IF rectangle_height(r#) = 350 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_bounds# sets height", passed)
  ' Cleanup
  rectangle_free(r#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Alignment
' ============================================================================
FUNCTION TestAlignment() LOCAL frm#, r#, passed
  PRINTLN ""
  PRINTLN "=== Testing Alignment ==="
  frm# = form#("Alignment Test", 800, 600)
  r# = rectangle#(frm#)
  ' Test default alignment (should be None = 0)
  IF rectangle_align(r#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("Default alignment is None (0)", passed)
  ' Test setting Top alignment
  rectangle_align#(r#, 1)
  IF rectangle_align(r#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_align#(r#, 1) = Top", passed)
  ' Test setting Client alignment
  rectangle_align#(r#, 9)
  IF rectangle_align(r#) = 9 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_align#(r#, 9) = Client", passed)
  ' Cleanup
  rectangle_free(r#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Margins
' ============================================================================
FUNCTION TestMargins() LOCAL frm#, r#, passed
  PRINTLN ""
  PRINTLN "=== Testing Margins ==="
  frm# = form#("Margins Test", 800, 600)
  r# = rectangle#(frm#)
  ' Test individual margins
  rectangle_marginleft#(r#, 10)
  IF rectangle_marginleft(r#) = 10 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_marginleft# sets left margin", passed)
  rectangle_margintop#(r#, 20)
  IF rectangle_margintop(r#) = 20 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_margintop# sets top margin", passed)
  rectangle_marginright#(r#, 15)
  IF rectangle_marginright(r#) = 15 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_marginright# sets right margin", passed)
  rectangle_marginbottom#(r#, 25)
  IF rectangle_marginbottom(r#) = 25 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_marginbottom# sets bottom margin", passed)
  ' Test margins (all at once)
  rectangle_margins#(r#, 5, 10, 15, 20)
  IF rectangle_marginleft(r#) = 5 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_margins# sets left", passed)
  IF rectangle_margintop(r#) = 10 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_margins# sets top", passed)
  ' Test uniform margin
  rectangle_margin#(r#, 12)
  IF rectangle_marginleft(r#) = 12 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_margin# sets uniform margin", passed)
  ' Cleanup
  rectangle_free(r#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Visibility and Behavior
' ============================================================================
FUNCTION TestVisibilityBehavior() LOCAL frm#, r#, passed
  PRINTLN ""
  PRINTLN "=== Testing Visibility and Behavior ==="
  frm# = form#("Visibility Test", 800, 600)
  r# = rectangle#(frm#)
  ' Test visible
  rectangle_visible#(r#, 1)
  IF rectangle_visible(r#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_visible#(1) sets visible", passed)
  rectangle_visible#(r#, 0)
  IF rectangle_visible(r#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_visible#(0) hides rect", passed)
  rectangle_visible#(r#, 1)
  ' Test enabled
  rectangle_enabled#(r#, 0)
  IF rectangle_enabled(r#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_enabled#(0) disables rect", passed)
  rectangle_enabled#(r#, 1)
  IF rectangle_enabled(r#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_enabled#(1) enables rect", passed)
  ' Test opacity
  rectangle_opacity#(r#, 0.5)
  IF rectangle_opacity(r#) = 0.5 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_opacity#(0.5) sets opacity", passed)
  ' Test hittest
  rectangle_hittest#(r#, 0)
  IF rectangle_hittest(r#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_hittest#(0) disables hit test", passed)
  rectangle_hittest#(r#, 1)
  IF rectangle_hittest(r#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_hittest#(1) enables hit test", passed)
  ' Cleanup
  rectangle_free(r#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Tag and Rotation
' ============================================================================
FUNCTION TestTagRotation() LOCAL frm#, r#, passed
  PRINTLN ""
  PRINTLN "=== Testing Tag and Rotation ==="
  frm# = form#("Tag Test", 800, 600)
  r# = rectangle#(frm#)
  ' Test tag
  rectangle_tag#(r#, 42)
  IF rectangle_tag(r#) = 42 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_tag#(42) sets tag", passed)
  rectangle_tag#(r#, 999)
  IF rectangle_tag(r#) = 999 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_tag#(999) updates tag", passed)
  ' Test rotation
  rectangle_rotation#(r#, 45)
  IF rectangle_rotation(r#) = 45 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_rotation#(45) sets rotation", passed)
  rectangle_rotation#(r#, 90)
  IF rectangle_rotation(r#) = 90 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_rotation#(90) updates rotation", passed)
  ' Cleanup
  rectangle_free(r#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Parent and Z-Order
' ============================================================================
FUNCTION TestParentZOrder() LOCAL frm#, r#, parent#, passed
  PRINTLN ""
  PRINTLN "=== Testing Parent and Z-Order ==="
  frm# = form#("Parent Test", 800, 600)
  r# = rectangle#(frm#)
  ' Test get parent
  parent# = rectangle_parent#(r#)
  IF PntToNum(parent#) = PntToNum(frm#) THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_parent# returns correct parent", passed)
  ' Test bring to front (should not error)
  rectangle_bringtofront#(r#)
  IF rectangle_error() = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_bringtofront# executes", passed)
  ' Test send to back
  rectangle_sendtoback#(r#)
  IF rectangle_error() = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_sendtoback# executes", passed)
  ' Cleanup
  rectangle_free(r#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Invalidation
' ============================================================================
FUNCTION TestInvalidation() LOCAL frm#, r#, passed
  PRINTLN ""
  PRINTLN "=== Testing Invalidation ==="
  frm# = form#("Invalidation Test", 800, 600)
  r# = rectangle#(frm#)
  rectangle_invalidate#(r#)
  IF rectangle_error() = 0 THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_invalidate# executes without error", passed)
  ' Cleanup
  rectangle_free(r#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Test: Event Callbacks
' ============================================================================
FUNCTION TestEventCallbacks() LOCAL frm#, r#, funcName$, passed
  PRINTLN ""
  PRINTLN "=== Testing Event Callbacks ==="
  frm# = form#("Callback Test", 800, 600)
  r# = rectangle#(frm#)
  ' Test onclick
  rectangle_onclick#(r#, "MyClickHandler")
  funcName$ = rectangle_onclick$(r#)
  IF funcName$ = "MyClickHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_onclick# sets handler", passed)
  ' Test ondblclick
  rectangle_ondblclick#(r#, "MyDblClickHandler")
  funcName$ = rectangle_ondblclick$(r#)
  IF funcName$ = "MyDblClickHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_ondblclick# sets handler", passed)
  ' Test onmousedown
  rectangle_onmousedown#(r#, "MyMouseDownHandler")
  funcName$ = rectangle_onmousedown$(r#)
  IF funcName$ = "MyMouseDownHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_onmousedown# sets handler", passed)
  ' Test onmouseup
  rectangle_onmouseup#(r#, "MyMouseUpHandler")
  funcName$ = rectangle_onmouseup$(r#)
  IF funcName$ = "MyMouseUpHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_onmouseup# sets handler", passed)
  ' Test onmousemove
  rectangle_onmousemove#(r#, "MyMouseMoveHandler")
  funcName$ = rectangle_onmousemove$(r#)
  IF funcName$ = "MyMouseMoveHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_onmousemove# sets handler", passed)
  ' Test onmouseenter
  rectangle_onmouseenter#(r#, "MyMouseEnterHandler")
  funcName$ = rectangle_onmouseenter$(r#)
  IF funcName$ = "MyMouseEnterHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_onmouseenter# sets handler", passed)
  ' Test onmouseleave
  rectangle_onmouseleave#(r#, "MyMouseLeaveHandler")
  funcName$ = rectangle_onmouseleave$(r#)
  IF funcName$ = "MyMouseLeaveHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_onmouseleave# sets handler", passed)
  ' Test onmousewheel
  rectangle_onmousewheel#(r#, "MyMouseWheelHandler")
  funcName$ = rectangle_onmousewheel$(r#)
  IF funcName$ = "MyMouseWheelHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_onmousewheel# sets handler", passed)
  ' Test onresize
  rectangle_onresize#(r#, "MyResizeHandler")
  funcName$ = rectangle_onresize$(r#)
  IF funcName$ = "MyResizeHandler" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_onresize# sets handler", passed)
  ' Test clearcallbacks
  rectangle_clearcallbacks#(r#)
  funcName$ = rectangle_onclick$(r#)
  IF funcName$ = "" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_clearcallbacks# clears onclick", passed)
  funcName$ = rectangle_onresize$(r#)
  IF funcName$ = "" THEN
    passed = 1
  ELSE
    passed = 0
  ENDIF
  TestResult("rectangle_clearcallbacks# clears onresize", passed)
  ' Cleanup
  rectangle_free(r#)
  form_free(frm#)
ENDFUNCTION
' ============================================================================
' Main Test Runner
' ============================================================================
PRINTLN "============================================"
PRINTLN "RectangleLib Test Suite"
PRINTLN "============================================"
TestErrorHandling()
TestRectCreation()
TestFillStroke()
TestCornerRadius()
TestSidesCorners()
TestPositionSize()
TestAlignment()
TestMargins()
TestVisibilityBehavior()
TestTagRotation()
TestParentZOrder()
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
