' =============================================================================
' ButtonLib Test Suite - Basic Tests
' Tests: Creation, Text, Position, Size, Visibility, Enable/Disable
' =============================================================================
PRINTLN "========================================="
PRINTLN "ButtonLib Test Suite - Basic Tests"
PRINTLN "========================================="
PRINTLN ""
LET testsPassed = 0
LET testsFailed = 0
' -----------------------------------------------------------------------------
' Helper function to report test results
' -----------------------------------------------------------------------------
FUNCTION ReportTest(testName$, passed) LOCAL result$
  IF passed <> 0 THEN
    result$ = "PASS"
    testsPassed = testsPassed + 1
  ELSE
    result$ = "FAIL"
    testsFailed = testsFailed + 1
  END IF
  PRINTLN "[" + result$ + "] " + testName$
END FUNCTION
' -----------------------------------------------------------------------------
' TEST 1: Create form and basic button
' -----------------------------------------------------------------------------
PRINTLN "--- Test Group: Creation ---"
LET frm# = form#("ButtonLib Test", 600, 500)
LET sb# = scrollbox#(frm#)
LET passed = 0
IF PntToNum(frm#) <> 0 THEN
  passed = 1
END IF
ReportTest("Create form", passed)
' Test button#(parent#)
LET btn1# = button#(sb#)
passed = 0
IF PntToNum(btn1#) <> 0 THEN
  passed = 1
END IF
ReportTest("button#(parent#) - basic creation", passed)
' Test default text
LET txt$ = button_text$(btn1#)
passed = 0
IF txt$ = "Button" THEN
  passed = 1
END IF
ReportTest("Default text is 'Button'", passed)
' Test button#(parent#, text$)
LET btn2# = button#(sb#, "Save")
txt$ = button_text$(btn2#)
passed = 0
IF txt$ = "Save" THEN
  passed = 1
END IF
ReportTest("button#(parent#, text$) - with text", passed)
' Test button#(parent#, x, y, w, h)
LET btn3# = button#(sb#, 100, 50, 120, 35)
passed = 0
IF PntToNum(btn3#) <> 0 THEN
  LET x = button_x(btn3#)
  LET y = button_y(btn3#)
  LET w = button_width(btn3#)
  LET h = button_height(btn3#)
  IF x = 100 AND y = 50 AND w = 120 AND h = 35 THEN
    passed = 1
  END IF
END IF
ReportTest("button#(parent#, x, y, w, h) - with position/size", passed)
' Test button#(parent#, text$, x, y, w, h)
LET btn4# = button#(sb#, "Cancel", 230, 50, 120, 35)
passed = 0
IF PntToNum(btn4#) <> 0 THEN
  txt$ = button_text$(btn4#)
  x = button_x(btn4#)
  IF txt$ = "Cancel" AND x = 230 THEN
    passed = 1
  END IF
END IF
ReportTest("button#(parent#, text$, x, y, w, h) - full creation", passed)
' -----------------------------------------------------------------------------
' TEST 2: Text Content
' -----------------------------------------------------------------------------
PRINTLN ""
PRINTLN "--- Test Group: Text Content ---"
button_text#(btn1#, "New Text")
txt$ = button_text$(btn1#)
passed = 0
IF txt$ = "New Text" THEN
  passed = 1
END IF
ReportTest("Set/Get text", passed)
button_text#(btn1#, "")
txt$ = button_text$(btn1#)
passed = 0
IF txt$ = "" THEN
  passed = 1
END IF
ReportTest("Empty text", passed)
button_text#(btn1#, "Special: !@#$%^&*()")
txt$ = button_text$(btn1#)
passed = 0
IF txt$ = "Special: !@#$%^&*()" THEN
  passed = 1
END IF
ReportTest("Special characters in text", passed)
button_text#(btn1#, "Test Button 1")
' -----------------------------------------------------------------------------
' TEST 3: Position and Size
' -----------------------------------------------------------------------------
PRINTLN ""
PRINTLN "--- Test Group: Position and Size ---"
button_x#(btn1#, 50)
passed = 0
IF button_x(btn1#) = 50 THEN
  passed = 1
END IF
ReportTest("Set/Get X position", passed)
button_y#(btn1#, 100)
passed = 0
IF button_y(btn1#) = 100 THEN
  passed = 1
END IF
ReportTest("Set/Get Y position", passed)
button_width#(btn1#, 150)
passed = 0
IF button_width(btn1#) = 150 THEN
  passed = 1
END IF
ReportTest("Set/Get width", passed)
button_height#(btn1#, 45)
passed = 0
IF button_height(btn1#) = 45 THEN
  passed = 1
END IF
ReportTest("Set/Get height", passed)
button_move#(btn2#, 220, 100)
passed = 0
IF button_x(btn2#) = 220 AND button_y(btn2#) = 100 THEN
  passed = 1
END IF
ReportTest("button_move# sets position", passed)
button_size#(btn2#, 130, 45)
passed = 0
IF button_width(btn2#) = 130 AND button_height(btn2#) = 45 THEN
  passed = 1
END IF
ReportTest("button_size# sets dimensions", passed)
button_bounds#(btn3#, 50, 160, 140, 40)
passed = 0
x = button_x(btn3#)
y = button_y(btn3#)
w = button_width(btn3#)
h = button_height(btn3#)
IF x = 50 AND y = 160 AND w = 140 AND h = 40 THEN
  passed = 1
END IF
ReportTest("button_bounds# sets all at once", passed)
' -----------------------------------------------------------------------------
' TEST 4: Visibility and State
' -----------------------------------------------------------------------------
PRINTLN ""
PRINTLN "--- Test Group: Visibility and State ---"
button_move#(btn4#, 220, 160)
button_size#(btn4#, 130, 40)
' Visible
passed = 0
IF button_visible(btn1#) = 1 THEN
  passed = 1
END IF
ReportTest("Default visible = 1", passed)
button_visible#(btn1#, 0)
passed = 0
IF button_visible(btn1#) = 0 THEN
  passed = 1
END IF
ReportTest("Set visible to 0", passed)
button_visible#(btn1#, 1)
passed = 0
IF button_visible(btn1#) = 1 THEN
  passed = 1
END IF
ReportTest("Set visible to 1", passed)
' Enabled
passed = 0
IF button_enabled(btn1#) = 1 THEN
  passed = 1
END IF
ReportTest("Default enabled = 1", passed)
button_enabled#(btn1#, 0)
passed = 0
IF button_enabled(btn1#) = 0 THEN
  passed = 1
END IF
ReportTest("Set enabled to 0 (disabled)", passed)
button_enabled#(btn1#, 1)
passed = 0
IF button_enabled(btn1#) = 1 THEN
  passed = 1
END IF
ReportTest("Set enabled to 1 (enabled)", passed)
' Opacity
button_opacity#(btn2#, 0.5)
passed = 0
LET op = button_opacity(btn2#)
IF op >= 0.49 AND op <= 0.51 THEN
  passed = 1
END IF
ReportTest("Set/Get opacity", passed)
button_opacity#(btn2#, 1.0)
' -----------------------------------------------------------------------------
' TEST 5: Tag
' -----------------------------------------------------------------------------
PRINTLN ""
PRINTLN "--- Test Group: Tag ---"
button_tag#(btn1#, 100)
passed = 0
IF button_tag(btn1#) = 100 THEN
  passed = 1
END IF
ReportTest("Set/Get tag", passed)
button_tag#(btn2#, 200)
button_tag#(btn3#, 300)
button_tag#(btn4#, 400)
' -----------------------------------------------------------------------------
' TEST 6: TabOrder
' -----------------------------------------------------------------------------
PRINTLN ""
PRINTLN "--- Test Group: Tab Order ---"
button_taborder#(btn1#, 0)
button_taborder#(btn2#, 1)
button_taborder#(btn3#, 2)
button_taborder#(btn4#, 3)
passed = 0
IF button_taborder(btn1#) = 0 THEN
  passed = 1
END IF
ReportTest("Set/Get tab order", passed)
' -----------------------------------------------------------------------------
' TEST 7: CanFocus
' -----------------------------------------------------------------------------
PRINTLN ""
PRINTLN "--- Test Group: Focus ---"
passed = 0
IF button_canfocus(btn1#) = 1 THEN
  passed = 1
END IF
ReportTest("Default canfocus = 1", passed)
button_canfocus#(btn1#, 0)
passed = 0
IF button_canfocus(btn1#) = 0 THEN
  passed = 1
END IF
ReportTest("Set canfocus to 0", passed)
button_canfocus#(btn1#, 1)
' -----------------------------------------------------------------------------
' TEST 8: HitTest
' -----------------------------------------------------------------------------
PRINTLN ""
PRINTLN "--- Test Group: HitTest ---"
passed = 0
IF button_hittest(btn1#) = 1 THEN
  passed = 1
END IF
ReportTest("Default hittest = 1", passed)
button_hittest#(btn1#, 0)
passed = 0
IF button_hittest(btn1#) = 0 THEN
  passed = 1
END IF
ReportTest("Set hittest to 0", passed)
button_hittest#(btn1#, 1)
' -----------------------------------------------------------------------------
' TEST 9: Alignment
' -----------------------------------------------------------------------------
PRINTLN ""
PRINTLN "--- Test Group: Alignment ---"
' Create a new button for alignment tests
LET btnAlign# = button#(sb#, "Aligned Button")
button_size#(btnAlign#, 150, 35)
passed = 0
IF button_align(btnAlign#) = 0 THEN
  passed = 1
END IF
ReportTest("Default align = 0 (None)", passed)
button_align#(btnAlign#, 1)
passed = 0
IF button_align(btnAlign#) = 1 THEN
  passed = 1
END IF
ReportTest("Set align to 1 (Top)", passed)
button_align#(btnAlign#, 0)
button_move#(btnAlign#, 50, 220)
' -----------------------------------------------------------------------------
' TEST 10: Margins
' -----------------------------------------------------------------------------
PRINTLN ""
PRINTLN "--- Test Group: Margins ---"
button_marginleft#(btn1#, 5)
passed = 0
IF button_marginleft(btn1#) = 5 THEN
  passed = 1
END IF
ReportTest("Set/Get margin left", passed)
button_margintop#(btn1#, 10)
passed = 0
IF button_margintop(btn1#) = 10 THEN
  passed = 1
END IF
ReportTest("Set/Get margin top", passed)
button_marginright#(btn1#, 15)
passed = 0
IF button_marginright(btn1#) = 15 THEN
  passed = 1
END IF
ReportTest("Set/Get margin right", passed)
button_marginbottom#(btn1#, 20)
passed = 0
IF button_marginbottom(btn1#) = 20 THEN
  passed = 1
END IF
ReportTest("Set/Get margin bottom", passed)
button_margins#(btn1#, 0, 0, 0, 0)
passed = 0
IF button_marginleft(btn1#) = 0 AND button_margintop(btn1#) = 0 THEN
  passed = 1
END IF
ReportTest("Set all margins at once", passed)
button_margin#(btn2#, 8)
passed = 0
IF button_marginleft(btn2#) = 8 AND button_marginright(btn2#) = 8 THEN
  passed = 1
END IF
ReportTest("Set uniform margin", passed)
button_margin#(btn2#, 0)
' -----------------------------------------------------------------------------
' TEST 11: Parent and Z-Order
' -----------------------------------------------------------------------------
PRINTLN ""
PRINTLN "--- Test Group: Parent and Z-Order ---"
passed = 0
LET parent# = button_parent#(btn1#)
IF PntToNum(parent#) = PntToNum(sb#) THEN
  passed = 1
END IF
ReportTest("Get parent", passed)
' BringToFront/SendToBack
button_bringtofront#(btn1#)
passed = 1  ' No error means success
ReportTest("BringToFront", passed)
button_sendtoback#(btn1#)
passed = 1  ' No error means success
ReportTest("SendToBack", passed)
' -----------------------------------------------------------------------------
' TEST 12: Error Handling
' -----------------------------------------------------------------------------
PRINTLN ""
PRINTLN "--- Test Group: Error Handling ---"
button_clearerror()
passed = 0
IF button_error() = 0 THEN
  passed = 1
END IF
ReportTest("Clear error", passed)
' Test with nil pointer
LET nilResult$ = button_text$(Pointer#(0))
passed = 0
IF button_error() = 1 THEN
  passed = 1
END IF
ReportTest("Error on nil pointer", passed)
LET errMsg$ = button_errormsg$()
passed = 0
IF len(errMsg$) > 0 THEN
  passed = 1
END IF
ReportTest("Error message not empty", passed)
LET errStr$ = button_strerror$(1)
passed = 0
IF errStr$ = "Invalid button" THEN
  passed = 1
END IF
ReportTest("button_strerror$ returns correct message", passed)
button_clearerror()
' -----------------------------------------------------------------------------
' TEST 13: button_free
' -----------------------------------------------------------------------------
PRINTLN ""
PRINTLN "--- Test Group: Free ---"
LET btnTemp# = button#(sb#, "Temporary")
button_move#(btnTemp#, 400, 100)
button_size#(btnTemp#, 100, 30)
passed = 0
IF PntToNum(btnTemp#) <> 0 THEN
  passed = 1
END IF
ReportTest("Create temporary button", passed)
LET freeResult = button_free(btnTemp#)
passed = 0
IF freeResult = 1 THEN
  passed = 1
END IF
ReportTest("Free button returns 1", passed)
' -----------------------------------------------------------------------------
' Final Summary
' -----------------------------------------------------------------------------
PRINTLN ""
PRINTLN "========================================="
PRINTLN "Test Summary"
PRINTLN "========================================="
PRINTLN "Passed: " + str$(testsPassed)
PRINTLN "Failed: " + str$(testsFailed)
PRINTLN "Total:  " + str$(testsPassed + testsFailed)
PRINTLN ""
IF testsFailed = 0 THEN
  PRINTLN "All basic tests PASSED!"
ELSE
  PRINTLN "Some tests FAILED. Please review."
END IF
' Show the form to verify visuals
form_show(frm#)
PRINTLN ""
PRINTLN "Form displayed. Press Ctrl+C to exit."
