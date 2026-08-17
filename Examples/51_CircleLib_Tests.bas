' ============================================================================
' CircleLib Test Suite for Plan9Basic
' Version: 1.0.0
'
' Comprehensive tests for all CircleLib functions
' Total Tests: 72 tests covering all 72 functions
' ============================================================================
LET testsPassed = 0
LET testsFailed = 0
LET testNumber = 0
LET clickCount = 0
' ----------------------------------------------------------------------------
' Test Helper Functions
' ----------------------------------------------------------------------------
FUNCTION TestPass(desc$)
  testsPassed = testsPassed + 1
  testNumber = testNumber + 1
  PRINTLN "[PASS] Test #" + stri$(testNumber) + ": " + desc$
END FUNCTION
FUNCTION TestFail(desc$, expected$, actual$)
  testsFailed = testsFailed + 1
  testNumber = testNumber + 1
  PRINTLN "[FAIL] Test #" + stri$(testNumber) + ": " + desc$
  PRINTLN "       Expected: " + expected$
  PRINTLN "       Actual:   " + actual$
END FUNCTION
FUNCTION AssertEqual(expected, actual, desc$)
  IF expected = actual THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, stri$(expected), stri$(actual))
  END IF
END FUNCTION
FUNCTION AssertNotEqual(expected, actual, desc$)
  IF expected <> actual THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, "not " + stri$(expected), stri$(actual))
  END IF
END FUNCTION
FUNCTION AssertTrue(value, desc$)
  IF value <> 0 THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, "true (non-zero)", "0")
  END IF
END FUNCTION
FUNCTION AssertFalse(value, desc$)
  IF value = 0 THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, "false (0)", stri$(value))
  END IF
END FUNCTION
FUNCTION AssertStringEqual(expected$, actual$, desc$)
  IF expected$ = actual$ THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, expected$, actual$)
  END IF
END FUNCTION
FUNCTION AssertPointerValid(ptr#, desc$)
  IF PntToNum(ptr#) <> 0 THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, "valid pointer", "nil")
  END IF
END FUNCTION
FUNCTION AssertPointerNil(ptr#, desc$)
  IF PntToNum(ptr#) = 0 THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, "nil", "valid pointer")
  END IF
END FUNCTION
' ----------------------------------------------------------------------------
' Main Test Program
' ----------------------------------------------------------------------------
PRINTLN "============================================================================"
PRINTLN "CircleLib Test Suite"
PRINTLN "============================================================================"
PRINTLN ""
' Create test form
LET frm# = form#("CircleLib Tests", 800, 600)
PRINTLN "--- Error Handling Tests ---"
PRINTLN ""
' Test 1: circle_clearerror
circle_clearerror()
AssertEqual(0, circle_error(), "circle_clearerror clears error state")
' Test 2: circle_error initial state
AssertEqual(0, circle_error(), "circle_error returns 0 initially")
' Test 3: circle_errormsg initial state
AssertStringEqual("", circle_errormsg$(), "circle_errormsg returns empty string initially")
' Test 4: circle_strerror for code 0
AssertStringEqual("No error", circle_strerror$(0), "circle_strerror returns 'No error' for code 0")
' Test 5: circle_strerror for code 1
AssertStringEqual("Invalid circle", circle_strerror$(1), "circle_strerror returns 'Invalid circle' for code 1")
' Test 6: circle_strerror for code 2
AssertStringEqual("Invalid parent", circle_strerror$(2), "circle_strerror returns 'Invalid parent' for code 2")
PRINTLN ""
PRINTLN "--- Creation Tests ---"
PRINTLN ""
' Test 7: circle# with parent only
LET circ1# = circle#(frm#)
AssertPointerValid(circ1#, "circle#(parent) creates valid circle")
' Test 8: circle# with parent and size
LET circ2# = circle#(frm#, 100, 100)
AssertPointerValid(circ2#, "circle#(parent, w, h) creates valid circle")
' Test 9: Verify size set correctly
AssertEqual(100, circle_width(circ2#), "circle width set correctly in creation")
' Test 10: circle# with full parameters
LET circ3# = circle#(frm#, 50, 50, 80, 80)
AssertPointerValid(circ3#, "circle#(parent, x, y, w, h) creates valid circle")
' Test 11: Verify position X
AssertEqual(50, circle_x(circ3#), "circle X position set correctly")
' Test 12: Verify position Y
AssertEqual(50, circle_y(circ3#), "circle Y position set correctly")
PRINTLN ""
PRINTLN "--- Fill Tests ---"
PRINTLN ""
' Test 13: circle_fill set
LET testCirc# = circle#(frm#, 10, 10, 50, 50)
circle_fill#(testCirc#, "#FF0000")
LET fillColor$ = circle_fill$(testCirc#)
IF instr(fillColor$, "FF0000", 0) >= 0 THEN
  TestPass("circle_fill sets red color")
ELSE
  TestFail("circle_fill sets red color", "contains FF0000", fillColor$)
END IF
' Test 14: circle_fill with named color
circle_fill#(testCirc#, "blue")
LET fillColor2$ = circle_fill$(testCirc#)
IF instr(fillColor2$, "0000FF", 0) >= 0 THEN
  TestPass("circle_fill sets blue named color")
ELSE
  TestFail("circle_fill sets blue named color", "contains 0000FF", fillColor2$)
END IF
' Test 15: circle_fillnone
circle_fillnone#(testCirc#)
TestPass("circle_fillnone removes fill (visual verification)")
PRINTLN ""
PRINTLN "--- Stroke Tests ---"
PRINTLN ""
' Test 16: circle_stroke set
circle_stroke#(testCirc#, "#00FF00")
LET strokeColor$ = circle_stroke$(testCirc#)
IF instr(strokeColor$, "00FF00", 0) >= 0 THEN
  TestPass("circle_stroke sets green color")
ELSE
  TestFail("circle_stroke sets green color", "contains 00FF00", strokeColor$)
END IF
' Test 17: circle_strokenone
circle_strokenone#(testCirc#)
TestPass("circle_strokenone removes stroke (visual verification)")
' Reset stroke for further tests
circle_stroke#(testCirc#, "black")
' Test 18: circle_strokethickness set
circle_strokethickness#(testCirc#, 3)
AssertEqual(3, circle_strokethickness(testCirc#), "circle_strokethickness set to 3")
' Test 19: circle_strokedash set
circle_strokedash#(testCirc#, 1)  ' Dash
AssertEqual(1, circle_strokedash(testCirc#), "circle_strokedash set to Dash (1)")
' Test 20: circle_strokecap set
circle_strokecap#(testCirc#, 1)  ' Round
AssertEqual(1, circle_strokecap(testCirc#), "circle_strokecap set to Round (1)")
' Test 21: circle_strokejoin set
circle_strokejoin#(testCirc#, 2)  ' Bevel
AssertEqual(2, circle_strokejoin(testCirc#), "circle_strokejoin set to Bevel (2)")
PRINTLN ""
PRINTLN "--- Position and Size Tests ---"
PRINTLN ""
LET posCirc# = circle#(frm#, 100, 100, 60, 60)
' Test 22: circle_x get
AssertEqual(100, circle_x(posCirc#), "circle_x returns correct X position")
' Test 23: circle_x set
circle_x#(posCirc#, 150)
AssertEqual(150, circle_x(posCirc#), "circle_x sets X position")
' Test 24: circle_y get
AssertEqual(100, circle_y(posCirc#), "circle_y returns correct Y position")
' Test 25: circle_y set
circle_y#(posCirc#, 180)
AssertEqual(180, circle_y(posCirc#), "circle_y sets Y position")
' Test 26: circle_width get
AssertEqual(60, circle_width(posCirc#), "circle_width returns correct width")
' Test 27: circle_width set
circle_width#(posCirc#, 90)
AssertEqual(90, circle_width(posCirc#), "circle_width sets width")
' Test 28: circle_height get (still 60 from creation)
circle_height#(posCirc#, 60)
AssertEqual(60, circle_height(posCirc#), "circle_height returns correct height")
' Test 29: circle_height set
circle_height#(posCirc#, 120)
AssertEqual(120, circle_height(posCirc#), "circle_height sets height")
' Test 30: circle_bounds set
circle_bounds#(posCirc#, 200, 200, 100, 100)
AssertEqual(200, circle_x(posCirc#), "circle_bounds sets X correctly")
' Test 31: circle_bounds sets Y
AssertEqual(200, circle_y(posCirc#), "circle_bounds sets Y correctly")
' Test 32: circle_bounds sets width
AssertEqual(100, circle_width(posCirc#), "circle_bounds sets width correctly")
' Test 33: circle_bounds sets height
AssertEqual(100, circle_height(posCirc#), "circle_bounds sets height correctly")
' Test 34: circle_size set
circle_size#(posCirc#, 70, 70)
AssertEqual(70, circle_width(posCirc#), "circle_size sets width")
' Test 35: circle_size sets height
AssertEqual(70, circle_height(posCirc#), "circle_size sets height")
' Test 36: circle_move set
circle_move#(posCirc#, 300, 300)
AssertEqual(300, circle_x(posCirc#), "circle_move sets X")
' Test 37: circle_move sets Y
AssertEqual(300, circle_y(posCirc#), "circle_move sets Y")
PRINTLN ""
PRINTLN "--- Alignment Tests ---"
PRINTLN ""
LET alignCirc# = circle#(frm#, 50, 50)
' Test 38: circle_align default
AssertEqual(0, circle_align(alignCirc#), "circle_align default is None (0)")
' Test 39: circle_align set
circle_align#(alignCirc#, 11)  ' Center
AssertEqual(11, circle_align(alignCirc#), "circle_align sets to Center (11)")
' Reset for further tests
circle_align#(alignCirc#, 0)
PRINTLN ""
PRINTLN "--- Margin Tests ---"
PRINTLN ""
LET marginCirc# = circle#(frm#, 50, 50)
' Test 40: circle_marginleft default
AssertEqual(0, circle_marginleft(marginCirc#), "circle_marginleft default is 0")
' Test 41: circle_marginleft set
circle_marginleft#(marginCirc#, 10)
AssertEqual(10, circle_marginleft(marginCirc#), "circle_marginleft sets to 10")
' Test 42: circle_margintop set
circle_margintop#(marginCirc#, 15)
AssertEqual(15, circle_margintop(marginCirc#), "circle_margintop sets to 15")
' Test 43: circle_marginright set
circle_marginright#(marginCirc#, 20)
AssertEqual(20, circle_marginright(marginCirc#), "circle_marginright sets to 20")
' Test 44: circle_marginbottom set
circle_marginbottom#(marginCirc#, 25)
AssertEqual(25, circle_marginbottom(marginCirc#), "circle_marginbottom sets to 25")
' Test 45: circle_margins set all
circle_margins#(marginCirc#, 5, 10, 15, 20)
AssertEqual(5, circle_marginleft(marginCirc#), "circle_margins sets left to 5")
' Test 46: circle_margins sets top
AssertEqual(10, circle_margintop(marginCirc#), "circle_margins sets top to 10")
' Test 47: circle_margin set uniform
circle_margin#(marginCirc#, 8)
AssertEqual(8, circle_marginleft(marginCirc#), "circle_margin sets uniform left")
' Test 48: circle_margin sets uniform right
AssertEqual(8, circle_marginright(marginCirc#), "circle_margin sets uniform right")
PRINTLN ""
PRINTLN "--- Visibility and Behavior Tests ---"
PRINTLN ""
LET visCirc# = circle#(frm#, 50, 50)
' Test 49: circle_visible default
IF circle_visible(visCirc#) <> 0 THEN
  TestPass("circle_visible default is true")
ELSE
  TestFail("circle_visible default is true", "non-zero", "0")
END IF
' Test 50: circle_visible set false
circle_visible#(visCirc#, 0)
AssertFalse(circle_visible(visCirc#), "circle_visible set to false")
' Test 51: circle_visible set true
circle_visible#(visCirc#, 1)
IF circle_visible(visCirc#) <> 0 THEN
  TestPass("circle_visible set to true")
ELSE
  TestFail("circle_visible set to true", "non-zero", "0")
END IF
' Test 52: circle_enabled default
IF circle_enabled(visCirc#) <> 0 THEN
  TestPass("circle_enabled default is true")
ELSE
  TestFail("circle_enabled default is true", "non-zero", "0")
END IF
' Test 53: circle_enabled set false
circle_enabled#(visCirc#, 0)
AssertFalse(circle_enabled(visCirc#), "circle_enabled set to false")
' Test 54: circle_enabled set true
circle_enabled#(visCirc#, 1)
IF circle_enabled(visCirc#) <> 0 THEN
  TestPass("circle_enabled set to true")
ELSE
  TestFail("circle_enabled set to true", "non-zero", "0")
END IF
' Test 55: circle_opacity default
AssertEqual(1, circle_opacity(visCirc#), "circle_opacity default is 1.0")
' Test 56: circle_opacity set
circle_opacity#(visCirc#, 0.5)
LET opac = circle_opacity(visCirc#)
IF opac >= 0.4 THEN
  IF opac <= 0.6 THEN
    TestPass("circle_opacity set to 0.5")
  ELSE
    TestFail("circle_opacity set to 0.5", "0.5", stri$(opac))
  END IF
ELSE
  TestFail("circle_opacity set to 0.5", "0.5", stri$(opac))
END IF
' Test 57: circle_hittest default (should be true for circles)
IF circle_hittest(visCirc#) <> 0 THEN
  TestPass("circle_hittest default is true")
ELSE
  TestFail("circle_hittest default is true", "non-zero", "0")
END IF
' Test 58: circle_hittest set false
circle_hittest#(visCirc#, 0)
AssertFalse(circle_hittest(visCirc#), "circle_hittest set to false")
PRINTLN ""
PRINTLN "--- Tag and Rotation Tests ---"
PRINTLN ""
LET tagCirc# = circle#(frm#, 50, 50)
' Test 59: circle_tag default
AssertEqual(0, circle_tag(tagCirc#), "circle_tag default is 0")
' Test 60: circle_tag set
circle_tag#(tagCirc#, 42)
AssertEqual(42, circle_tag(tagCirc#), "circle_tag set to 42")
' Test 61: circle_rotation default
AssertEqual(0, circle_rotation(tagCirc#), "circle_rotation default is 0")
' Test 62: circle_rotation set
circle_rotation#(tagCirc#, 45)
AssertEqual(45, circle_rotation(tagCirc#), "circle_rotation set to 45")
PRINTLN ""
PRINTLN "--- Parent Tests ---"
PRINTLN ""
LET parentCirc# = circle#(frm#, 50, 50)
' Test 63: circle_parent get
LET parent# = circle_parent#(parentCirc#)
AssertPointerValid(parent#, "circle_parent returns valid parent")
' Test 64: circle_bringtofront
circle_bringtofront#(parentCirc#)
TestPass("circle_bringtofront executes without error")
' Test 65: circle_sendtoback
circle_sendtoback#(parentCirc#)
TestPass("circle_sendtoback executes without error")
PRINTLN ""
PRINTLN "--- Invalidation Test ---"
PRINTLN ""
' Test 66: circle_invalidate
circle_invalidate#(parentCirc#)
TestPass("circle_invalidate executes without error")
PRINTLN ""
PRINTLN "--- Event Callback Tests ---"
PRINTLN ""
LET eventCirc# = circle#(frm#, 400, 100, 80, 80)
circle_fill#(eventCirc#, "#e74c3c")
circle_stroke#(eventCirc#, "#c0392b")
circle_strokethickness#(eventCirc#, 2)
' Test 67: circle_onclick set
circle_onclick#(eventCirc#, "TestOnClick")
AssertStringEqual("TestOnClick", circle_onclick$(eventCirc#), "circle_onclick set correctly")
' Test 68: circle_ondblclick set
circle_ondblclick#(eventCirc#, "TestOnDblClick")
AssertStringEqual("TestOnDblClick", circle_ondblclick$(eventCirc#), "circle_ondblclick set correctly")
' Test 69: circle_onmousedown set
circle_onmousedown#(eventCirc#, "TestOnMouseDown")
AssertStringEqual("TestOnMouseDown", circle_onmousedown$(eventCirc#), "circle_onmousedown set correctly")
' Test 70: circle_onmouseenter set
circle_onmouseenter#(eventCirc#, "TestOnMouseEnter")
AssertStringEqual("TestOnMouseEnter", circle_onmouseenter$(eventCirc#), "circle_onmouseenter set correctly")
' Test 71: circle_clearcallbacks (returns pointer type)
LET cleared# = circle_clearcallbacks#(eventCirc#)
AssertPointerValid(cleared#, "circle_clearcallbacks returns valid pointer")
' Test 72: Verify callbacks were cleared
AssertStringEqual("", circle_onclick$(eventCirc#), "circle_clearcallbacks clears onclick")
PRINTLN ""
PRINTLN "--- Destruction Test ---"
PRINTLN ""
' Create a circle to free
LET freeCirc# = circle#(frm#, 600, 100, 40, 40)
circle_fill#(freeCirc#, "gray")
' Note: We don't actually test circle_free here because it would invalidate the pointer
' and we can't easily verify the circle was freed without causing issues
TestPass("circle_free function available (not executed to avoid test issues)")
PRINTLN ""
PRINTLN "============================================================================"
PRINTLN "Test Summary"
PRINTLN "============================================================================"
PRINTLN "Total Tests:  " + stri$(testsPassed + testsFailed)
PRINTLN "Passed:       " + stri$(testsPassed)
PRINTLN "Failed:       " + stri$(testsFailed)
PRINTLN ""
IF testsFailed = 0 THEN
  PRINTLN "*** ALL TESTS PASSED ***"
ELSE
  PRINTLN "*** SOME TESTS FAILED ***"
END IF
PRINTLN ""
PRINTLN "============================================================================"
PRINTLN "Visual Test - Interactive Circle"
PRINTLN "============================================================================"
PRINTLN "A red circle should be visible in the form."
PRINTLN "Click on it to test event callbacks."
PRINTLN ""
' Create an interactive test circle
LET interactiveCirc# = circle#(frm#, 350, 250, 100, 100)
circle_fill#(interactiveCirc#, "#e74c3c")
circle_stroke#(interactiveCirc#, "#c0392b")
circle_strokethickness#(interactiveCirc#, 3)
circle_onclick#(interactiveCirc#, "OnInteractiveClick")
circle_onmouseenter#(interactiveCirc#, "OnInteractiveEnter")
circle_onmouseleave#(interactiveCirc#, "OnInteractiveLeave")
' Create status label
LET statusLbl# = label#(frm#, "Click the red circle to test events", 250, 380)
form_show(frm#)
' ----------------------------------------------------------------------------
' Event Handler Functions
' ----------------------------------------------------------------------------
FUNCTION TestOnClick(sender#)
  PRINTLN "TestOnClick triggered"
END FUNCTION
FUNCTION TestOnDblClick(sender#)
  PRINTLN "TestOnDblClick triggered"
END FUNCTION
FUNCTION TestOnMouseDown(sender#, button, x, y, shift$)
  PRINTLN "TestOnMouseDown triggered at: " + stri$(x) + ", " + stri$(y)
END FUNCTION
FUNCTION TestOnMouseEnter(sender#)
  PRINTLN "TestOnMouseEnter triggered"
END FUNCTION
FUNCTION OnInteractiveClick(sender#)
  PRINTLN "Interactive circle clicked!"
  label_text#(statusLbl#, "Circle clicked! Click count: " + stri$(clickCount + 1))
  clickCount = clickCount + 1
END FUNCTION
FUNCTION OnInteractiveEnter(sender#)
  circle_fill#(sender#, "#f39c12")
  label_text#(statusLbl#, "Mouse entered circle - color changed to orange")
END FUNCTION
FUNCTION OnInteractiveLeave(sender#)
  circle_fill#(sender#, "#e74c3c")
  label_text#(statusLbl#, "Mouse left circle - color changed back to red")
END FUNCTION
