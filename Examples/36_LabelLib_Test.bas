' ============================================================================
' LabelLib Test Suite for Plan9Basic
' Version: 1.0.0
' ============================================================================
' This test suite validates all LabelLib functions including:
' - Error handling
' - Label creation/destruction
' - Text content
' - Font properties
' - Text alignment
' - Word wrap and auto size
' - Position and size
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
  END IF
END FUNCTION
' ============================================================================
' Test: Error Handling Functions
' ============================================================================
FUNCTION TestErrorHandling() LOCAL err, msg$, passed, dummy
  PRINTLN ""
  PRINTLN "=== Testing Error Handling ==="
  ' Test 1: Initial error state should be 0
  err = label_error()
  IF err = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_error initial value is 0", passed)
  ' Test 2: Error message should be empty
  msg$ = label_errormsg$()
  IF msg$ = "" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_errormsg$ initial is empty", passed)
  ' Test 3: Test strerror for known codes
  msg$ = label_strerror$(0)
  IF msg$ = "No error" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_strerror$(0) = 'No error'", passed)
  msg$ = label_strerror$(1)
  IF msg$ = "Invalid or nil label" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_strerror$(1) = 'Invalid or nil label'", passed)
  ' Test 4: Invalid label should set error
  dummy = label_width(Pointer#(0))
  err = label_error()
  IF err = 1 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("Invalid label sets error code", passed)
  ' Test 5: Clear error
  label_clearerror()
  err = label_error()
  IF err = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_clearerror resets error", passed)
END FUNCTION
' ============================================================================
' Test: Label Creation and Destruction
' ============================================================================
FUNCTION TestLabelCreation() LOCAL frm#, lbl1#, lbl2#, lbl3#, lbl4#, badLabel#, passed, err, txt$
  PRINTLN ""
  PRINTLN "=== Testing Label Creation ==="
  ' Create parent form
  frm# = form#("Test Form", 800, 600)
  IF PntToNum(frm#) <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("form# created successfully", passed)
  ' Test 1: Create basic label
  lbl1# = label#(frm#)
  IF PntToNum(lbl1#) <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label#(parent#) creates label", passed)
  ' Test 2: Create label with text
  lbl2# = label#(frm#, "Hello World")
  IF PntToNum(lbl2#) <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label#(parent#, text$) creates label", passed)
  txt$ = label_text$(lbl2#)
  IF txt$ = "Hello World" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label text is 'Hello World'", passed)
  ' Test 3: Create label with position
  lbl3# = label#(frm#, "Positioned", 100, 150)
  IF PntToNum(lbl3#) <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label#(parent#, text$, x, y) creates label", passed)
  IF label_x(lbl3#) = 100 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label x is 100", passed)
  IF label_y(lbl3#) = 150 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label y is 150", passed)
  ' Test 4: Create label with full params
  lbl4# = label#(frm#, "Full", 50, 60, 200, 30)
  IF PntToNum(lbl4#) <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label#(parent#, text$, x, y, w, h) creates label", passed)
  IF label_width(lbl4#) = 200 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label width is 200", passed)
  IF label_height(lbl4#) = 30 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label height is 30", passed)
  ' Test 5: Free label
  label_free(lbl4#)
  err = label_error()
  IF err = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_free executes without error", passed)
  ' Test 6: Invalid parent should fail
  label_clearerror()
  badLabel# = label#(Pointer#(0))
  err = label_error()
  IF err <> 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label# with nil parent fails", passed)
  ' Cleanup
  label_free(lbl3#)
  label_free(lbl2#)
  label_free(lbl1#)
  form_free(frm#)
END FUNCTION
' ============================================================================
' Test: Text Content
' ============================================================================
FUNCTION TestTextContent() LOCAL frm#, lbl#, passed, txt$
  PRINTLN ""
  PRINTLN "=== Testing Text Content ==="
  frm# = form#("Text Test", 800, 600)
  lbl# = label#(frm#)
  ' Set text
  label_text#(lbl#, "Test Text")
  txt$ = label_text$(lbl#)
  IF txt$ = "Test Text" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_text# sets text", passed)
  ' Change text
  label_text#(lbl#, "New Text")
  txt$ = label_text$(lbl#)
  IF txt$ = "New Text" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_text# updates text", passed)
  ' Empty text
  label_text#(lbl#, "")
  txt$ = label_text$(lbl#)
  IF txt$ = "" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_text# clears text", passed)
  ' Cleanup
  label_free(lbl#)
  form_free(frm#)
END FUNCTION
' ============================================================================
' Test: Font Properties
' ============================================================================
FUNCTION TestFontProperties() LOCAL frm#, lbl#, passed, size, family$, color$
  PRINTLN ""
  PRINTLN "=== Testing Font Properties ==="
  frm# = form#("Font Test", 800, 600)
  lbl# = label#(frm#, "Font Test")
  ' Test font size
  label_fontsize#(lbl#, 24)
  size = label_fontsize(lbl#)
  IF size = 24 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_fontsize# sets size to 24", passed)
  ' Test font family
  label_fontfamily#(lbl#, "Arial")
  family$ = label_fontfamily$(lbl#)
  IF family$ = "Arial" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_fontfamily# sets Arial", passed)
  ' Test font color
  label_fontcolor#(lbl#, "#FF0000")
  color$ = label_fontcolor$(lbl#)
  IF color$ = "#FFFF0000" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_fontcolor# sets red color", passed)
  ' Test bold
  label_bold#(lbl#, 1)
  IF label_bold(lbl#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_bold#(1) enables bold", passed)
  label_bold#(lbl#, 0)
  IF label_bold(lbl#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_bold#(0) disables bold", passed)
  ' Test italic
  label_italic#(lbl#, 1)
  IF label_italic(lbl#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_italic#(1) enables italic", passed)
  label_italic#(lbl#, 0)
  IF label_italic(lbl#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_italic#(0) disables italic", passed)
  ' Test underline
  label_underline#(lbl#, 1)
  IF label_underline(lbl#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_underline#(1) enables underline", passed)
  label_underline#(lbl#, 0)
  IF label_underline(lbl#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_underline#(0) disables underline", passed)
  ' Test strikeout
  label_strikeout#(lbl#, 1)
  IF label_strikeout(lbl#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_strikeout#(1) enables strikeout", passed)
  label_strikeout#(lbl#, 0)
  IF label_strikeout(lbl#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_strikeout#(0) disables strikeout", passed)
  ' Cleanup
  label_free(lbl#)
  form_free(frm#)
END FUNCTION
' ============================================================================
' Test: Text Alignment
' ============================================================================
FUNCTION TestTextAlignment() LOCAL frm#, lbl#, passed
  PRINTLN ""
  PRINTLN "=== Testing Text Alignment ==="
  frm# = form#("Alignment Test", 800, 600)
  lbl# = label#(frm#, "Alignment Test", 50, 50, 200, 50)
  label_autosize#(lbl#, 0)
  ' Test horizontal alignment - Center (0)
  label_textalign#(lbl#, 0)
  IF label_textalign(lbl#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_textalign#(0) = Center", passed)
  ' Test horizontal alignment - Leading (1)
  label_textalign#(lbl#, 1)
  IF label_textalign(lbl#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_textalign#(1) = Leading", passed)
  ' Test horizontal alignment - Trailing (2)
  label_textalign#(lbl#, 2)
  IF label_textalign(lbl#) = 2 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_textalign#(2) = Trailing", passed)
  ' Test vertical alignment - Center (0)
  label_vertalign#(lbl#, 0)
  IF label_vertalign(lbl#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_vertalign#(0) = Center", passed)
  ' Test vertical alignment - Leading (1)
  label_vertalign#(lbl#, 1)
  IF label_vertalign(lbl#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_vertalign#(1) = Leading", passed)
  ' Test vertical alignment - Trailing (2)
  label_vertalign#(lbl#, 2)
  IF label_vertalign(lbl#) = 2 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_vertalign#(2) = Trailing", passed)
  ' Cleanup
  label_free(lbl#)
  form_free(frm#)
END FUNCTION
' ============================================================================
' Test: Word Wrap and Auto Size
' ============================================================================
FUNCTION TestWordWrapAutoSize() LOCAL frm#, lbl#, passed
  PRINTLN ""
  PRINTLN "=== Testing Word Wrap and Auto Size ==="
  frm# = form#("Wrap Test", 800, 600)
  lbl# = label#(frm#, "Test", 50, 50, 200, 50)
  ' Test autosize - default is true for simple label
  IF label_autosize(lbl#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("Full creation sets autosize off", passed)
  label_autosize#(lbl#, 1)
  IF label_autosize(lbl#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_autosize#(1) enables autosize", passed)
  label_autosize#(lbl#, 0)
  IF label_autosize(lbl#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_autosize#(0) disables autosize", passed)
  ' Test word wrap
  label_wordwrap#(lbl#, 1)
  IF label_wordwrap(lbl#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_wordwrap#(1) enables wordwrap", passed)
  label_wordwrap#(lbl#, 0)
  IF label_wordwrap(lbl#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_wordwrap#(0) disables wordwrap", passed)
  ' Cleanup
  label_free(lbl#)
  form_free(frm#)
END FUNCTION
' ============================================================================
' Test: Position and Size
' ============================================================================
FUNCTION TestPositionSize() LOCAL frm#, lbl#, passed
  PRINTLN ""
  PRINTLN "=== Testing Position and Size ==="
  frm# = form#("Position Test", 800, 600)
  lbl# = label#(frm#, "Test", 0, 0, 100, 30)
  ' Test X position
  label_x#(lbl#, 100)
  IF label_x(lbl#) = 100 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_x# sets X position", passed)
  ' Test Y position
  label_y#(lbl#, 150)
  IF label_y(lbl#) = 150 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_y# sets Y position", passed)
  ' Test Width
  label_width#(lbl#, 250)
  IF label_width(lbl#) = 250 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_width# sets width", passed)
  ' Test Height
  label_height#(lbl#, 40)
  IF label_height(lbl#) = 40 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_height# sets height", passed)
  ' Test move
  label_move#(lbl#, 200, 200)
  IF label_x(lbl#) = 200 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_move# sets X", passed)
  IF label_y(lbl#) = 200 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_move# sets Y", passed)
  ' Test size
  label_size#(lbl#, 300, 50)
  IF label_width(lbl#) = 300 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_size# sets width", passed)
  IF label_height(lbl#) = 50 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_size# sets height", passed)
  ' Test bounds
  label_bounds#(lbl#, 50, 60, 400, 60)
  IF label_x(lbl#) = 50 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_bounds# sets X", passed)
  IF label_y(lbl#) = 60 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_bounds# sets Y", passed)
  IF label_width(lbl#) = 400 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_bounds# sets width", passed)
  IF label_height(lbl#) = 60 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_bounds# sets height", passed)
  ' Cleanup
  label_free(lbl#)
  form_free(frm#)
END FUNCTION
' ============================================================================
' Test: Visibility and Behavior
' ============================================================================
FUNCTION TestVisibilityBehavior() LOCAL frm#, lbl#, passed
  PRINTLN ""
  PRINTLN "=== Testing Visibility and Behavior ==="
  frm# = form#("Visibility Test", 800, 600)
  lbl# = label#(frm#, "Test")
  ' Test visible
  label_visible#(lbl#, 1)
  IF label_visible(lbl#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_visible#(1) sets visible", passed)
  label_visible#(lbl#, 0)
  IF label_visible(lbl#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_visible#(0) hides label", passed)
  label_visible#(lbl#, 1)
  ' Test enabled
  label_enabled#(lbl#, 0)
  IF label_enabled(lbl#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_enabled#(0) disables label", passed)
  label_enabled#(lbl#, 1)
  IF label_enabled(lbl#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_enabled#(1) enables label", passed)
  ' Test opacity
  label_opacity#(lbl#, 0.5)
  IF label_opacity(lbl#) = 0.5 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_opacity#(0.5) sets opacity", passed)
  ' Test hittest
  label_hittest#(lbl#, 0)
  IF label_hittest(lbl#) = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_hittest#(0) disables hit test", passed)
  label_hittest#(lbl#, 1)
  IF label_hittest(lbl#) = 1 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_hittest#(1) enables hit test", passed)
  ' Cleanup
  label_free(lbl#)
  form_free(frm#)
END FUNCTION
' ============================================================================
' Test: Tag and Rotation
' ============================================================================
FUNCTION TestTagRotation() LOCAL frm#, lbl#, passed
  PRINTLN ""
  PRINTLN "=== Testing Tag and Rotation ==="
  frm# = form#("Tag Test", 800, 600)
  lbl# = label#(frm#, "Test")
  ' Test tag
  label_tag#(lbl#, 42)
  IF label_tag(lbl#) = 42 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_tag#(42) sets tag", passed)
  label_tag#(lbl#, 999)
  IF label_tag(lbl#) = 999 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_tag#(999) updates tag", passed)
  ' Test rotation
  label_rotation#(lbl#, 45)
  IF label_rotation(lbl#) = 45 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_rotation#(45) sets rotation", passed)
  label_rotation#(lbl#, 90)
  IF label_rotation(lbl#) = 90 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_rotation#(90) updates rotation", passed)
  ' Cleanup
  label_free(lbl#)
  form_free(frm#)
END FUNCTION
' ============================================================================
' Test: Parent and Z-Order
' ============================================================================
FUNCTION TestParentZOrder() LOCAL frm#, lbl#, parent#, passed
  PRINTLN ""
  PRINTLN "=== Testing Parent and Z-Order ==="
  frm# = form#("Parent Test", 800, 600)
  lbl# = label#(frm#, "Test")
  ' Test get parent
  parent# = label_parent#(lbl#)
  IF PntToNum(parent#) = PntToNum(frm#) THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_parent# returns correct parent", passed)
  ' Test bring to front (should not error)
  label_bringtofront#(lbl#)
  IF label_error() = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_bringtofront# executes", passed)
  ' Test send to back
  label_sendtoback#(lbl#)
  IF label_error() = 0 THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_sendtoback# executes", passed)
  ' Cleanup
  label_free(lbl#)
  form_free(frm#)
END FUNCTION
' ============================================================================
' Test: Event Callbacks
' ============================================================================
FUNCTION TestEventCallbacks() LOCAL frm#, lbl#, funcName$, passed
  PRINTLN ""
  PRINTLN "=== Testing Event Callbacks ==="
  frm# = form#("Callback Test", 800, 600)
  lbl# = label#(frm#, "Test")
  ' Test onclick
  label_onclick#(lbl#, "MyClickHandler")
  funcName$ = label_onclick$(lbl#)
  IF funcName$ = "MyClickHandler" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_onclick# sets handler", passed)
  ' Test ondblclick
  label_ondblclick#(lbl#, "MyDblClickHandler")
  funcName$ = label_ondblclick$(lbl#)
  IF funcName$ = "MyDblClickHandler" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_ondblclick# sets handler", passed)
  ' Test onmousedown
  label_onmousedown#(lbl#, "MyMouseDownHandler")
  funcName$ = label_onmousedown$(lbl#)
  IF funcName$ = "MyMouseDownHandler" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_onmousedown# sets handler", passed)
  ' Test onmouseup
  label_onmouseup#(lbl#, "MyMouseUpHandler")
  funcName$ = label_onmouseup$(lbl#)
  IF funcName$ = "MyMouseUpHandler" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_onmouseup# sets handler", passed)
  ' Test onmousemove
  label_onmousemove#(lbl#, "MyMouseMoveHandler")
  funcName$ = label_onmousemove$(lbl#)
  IF funcName$ = "MyMouseMoveHandler" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_onmousemove# sets handler", passed)
  ' Test onmouseenter
  label_onmouseenter#(lbl#, "MyMouseEnterHandler")
  funcName$ = label_onmouseenter$(lbl#)
  IF funcName$ = "MyMouseEnterHandler" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_onmouseenter# sets handler", passed)
  ' Test onmouseleave
  label_onmouseleave#(lbl#, "MyMouseLeaveHandler")
  funcName$ = label_onmouseleave$(lbl#)
  IF funcName$ = "MyMouseLeaveHandler" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_onmouseleave# sets handler", passed)
  ' Test onresize
  label_onresize#(lbl#, "MyResizeHandler")
  funcName$ = label_onresize$(lbl#)
  IF funcName$ = "MyResizeHandler" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_onresize# sets handler", passed)
  ' Test clearcallbacks
  label_clearcallbacks#(lbl#)
  funcName$ = label_onclick$(lbl#)
  IF funcName$ = "" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_clearcallbacks# clears onclick", passed)
  funcName$ = label_onresize$(lbl#)
  IF funcName$ = "" THEN
    passed = 1
  ELSE
    passed = 0
  END IF
  TestResult("label_clearcallbacks# clears onresize", passed)
  ' Cleanup
  label_free(lbl#)
  form_free(frm#)
END FUNCTION
' ============================================================================
' Main Test Runner
' ============================================================================
PRINTLN "============================================"
PRINTLN "LabelLib Test Suite"
PRINTLN "============================================"
TestErrorHandling()
TestLabelCreation()
TestTextContent()
TestFontProperties()
TestTextAlignment()
TestWordWrapAutoSize()
TestPositionSize()
TestVisibilityBehavior()
TestTagRotation()
TestParentZOrder()
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
END IF
LET passRate = (passedTests / totalTests) * 100
PRINTLN "Pass Rate:   " + stri$(passRate) + "%"
PRINTLN "============================================"
