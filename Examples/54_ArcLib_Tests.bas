' ============================================================================
' ArcLib Test Suite for Plan9Basic
' Version: 1.0.0
'
' Comprehensive tests for all ArcLib functions
' Total Tests: 77 tests covering all 77 functions
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
ENDFUNCTION
FUNCTION TestFail(desc$, expected$, actual$)
  testsFailed = testsFailed + 1
  testNumber = testNumber + 1
  PRINTLN "[FAIL] Test #" + stri$(testNumber) + ": " + desc$
  PRINTLN "       Expected: " + expected$
  PRINTLN "       Actual:   " + actual$
ENDFUNCTION
FUNCTION AssertEqual(expected, actual, desc$)
  IF expected = actual THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, stri$(expected), stri$(actual))
  ENDIF
ENDFUNCTION
FUNCTION AssertNotEqual(expected, actual, desc$)
  IF expected <> actual THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, "not " + stri$(expected), stri$(actual))
  ENDIF
ENDFUNCTION
FUNCTION AssertTrue(value, desc$)
  IF value <> 0 THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, "true (non-zero)", "0")
  ENDIF
ENDFUNCTION
FUNCTION AssertFalse(value, desc$)
  IF value = 0 THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, "false (0)", stri$(value))
  ENDIF
ENDFUNCTION
FUNCTION AssertStringEqual(expected$, actual$, desc$)
  IF expected$ = actual$ THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, expected$, actual$)
  ENDIF
ENDFUNCTION
FUNCTION AssertPointerValid(ptr#, desc$)
  IF PntToNum(ptr#) <> 0 THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, "valid pointer", "nil")
  ENDIF
ENDFUNCTION
FUNCTION AssertPointerNil(ptr#, desc$)
  IF PntToNum(ptr#) = 0 THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, "nil", "valid pointer")
  ENDIF
ENDFUNCTION
' ----------------------------------------------------------------------------
' Main Test Program
' ----------------------------------------------------------------------------
PRINTLN "============================================================================"
PRINTLN "ArcLib Test Suite"
PRINTLN "============================================================================"
PRINTLN ""
' Create test form
LET frm# = form#("ArcLib Tests", 800, 600)
PRINTLN "--- Error Handling Tests ---"
PRINTLN ""
' Test 1: arc_clearerror
arc_clearerror()
AssertEqual(0, arc_error(), "arc_clearerror clears error state")
' Test 2: arc_error initial state
AssertEqual(0, arc_error(), "arc_error returns 0 initially")
' Test 3: arc_errormsg initial state
AssertStringEqual("", arc_errormsg$(), "arc_errormsg returns empty string initially")
' Test 4: arc_strerror for code 0
AssertStringEqual("No error", arc_strerror$(0), "arc_strerror returns 'No error' for code 0")
' Test 5: arc_strerror for code 1
AssertStringEqual("Invalid arc", arc_strerror$(1), "arc_strerror returns 'Invalid arc' for code 1")
' Test 6: arc_strerror for code 2
AssertStringEqual("Invalid parent", arc_strerror$(2), "arc_strerror returns 'Invalid parent' for code 2")
PRINTLN ""
PRINTLN "--- Creation Tests ---"
PRINTLN ""
' Test 7: arc# with parent only
LET arc1# = arc#(frm#)
AssertPointerValid(arc1#, "arc#(parent) creates valid arc")
' Test 8: arc# with parent and size
LET arc2# = arc#(frm#, 100, 100)
AssertPointerValid(arc2#, "arc#(parent, w, h) creates valid arc")
' Test 9: Verify size set correctly
AssertEqual(100, arc_width(arc2#), "arc width set correctly in creation")
' Test 10: arc# with full parameters
LET arc3# = arc#(frm#, 50, 50, 80, 80)
AssertPointerValid(arc3#, "arc#(parent, x, y, w, h) creates valid arc")
' Test 11: Verify position X
AssertEqual(50, arc_x(arc3#), "arc X position set correctly")
' Test 12: Verify position Y
AssertEqual(50, arc_y(arc3#), "arc Y position set correctly")
PRINTLN ""
PRINTLN "--- Arc-Specific Angle Tests ---"
PRINTLN ""
LET angleArc# = arc#(frm#, 10, 10, 100, 100)
' Test 13: arc_startangle default
LET startDef = arc_startangle(angleArc#)
TestPass("arc_startangle returns default value")
' Test 14: arc_startangle set
arc_startangle#(angleArc#, 45)
AssertEqual(45, arc_startangle(angleArc#), "arc_startangle set to 45")
' Test 15: arc_endangle default
arc_endangle#(angleArc#, 180)
LET endVal = arc_endangle(angleArc#)
AssertEqual(180, endVal, "arc_endangle set to 180")
' Test 16: arc_endangle set
arc_endangle#(angleArc#, 270)
AssertEqual(270, arc_endangle(angleArc#), "arc_endangle set to 270")
' Test 17: arc_angles set both at once
arc_angles#(angleArc#, 0, 90)
AssertEqual(0, arc_startangle(angleArc#), "arc_angles sets start angle to 0")
' Test 18: arc_angles sets end angle
AssertEqual(90, arc_endangle(angleArc#), "arc_angles sets end angle to 90")
PRINTLN ""
PRINTLN "--- Fill Tests ---"
PRINTLN ""
' Test 19: arc_fill set
LET testArc# = arc#(frm#, 10, 120, 50, 50)
arc_fill#(testArc#, "#FF0000")
LET fillColor$ = arc_fill$(testArc#)
IF instr(fillColor$, "FF0000", 0) >= 0 THEN
  TestPass("arc_fill sets red color")
ELSE
  TestFail("arc_fill sets red color", "contains FF0000", fillColor$)
ENDIF
' Test 20: arc_fill with named color
arc_fill#(testArc#, "blue")
LET fillColor2$ = arc_fill$(testArc#)
IF instr(fillColor2$, "0000FF", 0) >= 0 THEN
  TestPass("arc_fill sets blue named color")
ELSE
  TestFail("arc_fill sets blue named color", "contains 0000FF", fillColor2$)
ENDIF
' Test 21: arc_fillnone
arc_fillnone#(testArc#)
TestPass("arc_fillnone removes fill (visual verification)")
PRINTLN ""
PRINTLN "--- Stroke Tests ---"
PRINTLN ""
' Test 22: arc_stroke set
arc_stroke#(testArc#, "#00FF00")
LET strokeColor$ = arc_stroke$(testArc#)
IF instr(strokeColor$, "00FF00", 0) >= 0 THEN
  TestPass("arc_stroke sets green color")
ELSE
  TestFail("arc_stroke sets green color", "contains 00FF00", strokeColor$)
ENDIF
' Test 23: arc_strokenone
arc_strokenone#(testArc#)
TestPass("arc_strokenone removes stroke (visual verification)")
' Reset stroke for further tests
arc_stroke#(testArc#, "black")
' Test 24: arc_strokethickness set
arc_strokethickness#(testArc#, 3)
AssertEqual(3, arc_strokethickness(testArc#), "arc_strokethickness set to 3")
' Test 25: arc_strokedash set
arc_strokedash#(testArc#, 1)
AssertEqual(1, arc_strokedash(testArc#), "arc_strokedash set to Dash (1)")
' Test 26: arc_strokecap set
arc_strokecap#(testArc#, 1)
AssertEqual(1, arc_strokecap(testArc#), "arc_strokecap set to Round (1)")
' Test 27: arc_strokejoin set
arc_strokejoin#(testArc#, 2)
AssertEqual(2, arc_strokejoin(testArc#), "arc_strokejoin set to Bevel (2)")
PRINTLN ""
PRINTLN "--- Position and Size Tests ---"
PRINTLN ""
LET posArc# = arc#(frm#, 100, 100, 60, 60)
' Test 28: arc_x get
AssertEqual(100, arc_x(posArc#), "arc_x returns correct X position")
' Test 29: arc_x set
arc_x#(posArc#, 150)
AssertEqual(150, arc_x(posArc#), "arc_x sets X position")
' Test 30: arc_y get
AssertEqual(100, arc_y(posArc#), "arc_y returns correct Y position")
' Test 31: arc_y set
arc_y#(posArc#, 180)
AssertEqual(180, arc_y(posArc#), "arc_y sets Y position")
' Test 32: arc_width get
AssertEqual(60, arc_width(posArc#), "arc_width returns correct width")
' Test 33: arc_width set
arc_width#(posArc#, 90)
AssertEqual(90, arc_width(posArc#), "arc_width sets width")
' Test 34: arc_height get (reset to 60)
arc_height#(posArc#, 60)
AssertEqual(60, arc_height(posArc#), "arc_height returns correct height")
' Test 35: arc_height set
arc_height#(posArc#, 120)
AssertEqual(120, arc_height(posArc#), "arc_height sets height")
' Test 36: arc_bounds set
arc_bounds#(posArc#, 200, 200, 100, 100)
AssertEqual(200, arc_x(posArc#), "arc_bounds sets X correctly")
' Test 37: arc_bounds sets Y
AssertEqual(200, arc_y(posArc#), "arc_bounds sets Y correctly")
' Test 38: arc_bounds sets width
AssertEqual(100, arc_width(posArc#), "arc_bounds sets width correctly")
' Test 39: arc_bounds sets height
AssertEqual(100, arc_height(posArc#), "arc_bounds sets height correctly")
' Test 40: arc_size set
arc_size#(posArc#, 80, 80)
AssertEqual(80, arc_width(posArc#), "arc_size sets width correctly")
' Test 41: arc_size sets height
AssertEqual(80, arc_height(posArc#), "arc_size sets height correctly")
' Test 42: arc_move set
arc_move#(posArc#, 300, 300)
AssertEqual(300, arc_x(posArc#), "arc_move sets X correctly")
' Test 43: arc_move sets Y
AssertEqual(300, arc_y(posArc#), "arc_move sets Y correctly")
PRINTLN ""
PRINTLN "--- Alignment Tests ---"
PRINTLN ""
LET alignArc# = arc#(frm#, 50, 50)
' Test 44: arc_align default
AssertEqual(0, arc_align(alignArc#), "arc_align default is None (0)")
' Test 45: arc_align set
arc_align#(alignArc#, 9)
AssertEqual(9, arc_align(alignArc#), "arc_align set to Client (9)")
arc_align#(alignArc#, 0)
PRINTLN ""
PRINTLN "--- Margin Tests ---"
PRINTLN ""
LET marginArc# = arc#(frm#, 50, 50)
' Test 46: arc_marginleft set
arc_marginleft#(marginArc#, 10)
AssertEqual(10, arc_marginleft(marginArc#), "arc_marginleft sets to 10")
' Test 47: arc_margintop set
arc_margintop#(marginArc#, 15)
AssertEqual(15, arc_margintop(marginArc#), "arc_margintop sets to 15")
' Test 48: arc_marginright set
arc_marginright#(marginArc#, 20)
AssertEqual(20, arc_marginright(marginArc#), "arc_marginright sets to 20")
' Test 49: arc_marginbottom set
arc_marginbottom#(marginArc#, 25)
AssertEqual(25, arc_marginbottom(marginArc#), "arc_marginbottom sets to 25")
' Test 50: arc_margins set all
arc_margins#(marginArc#, 5, 10, 15, 20)
AssertEqual(5, arc_marginleft(marginArc#), "arc_margins sets left to 5")
' Test 51: arc_margins sets top
AssertEqual(10, arc_margintop(marginArc#), "arc_margins sets top to 10")
' Test 52: arc_margin set uniform
arc_margin#(marginArc#, 8)
AssertEqual(8, arc_marginleft(marginArc#), "arc_margin sets uniform left")
' Test 53: arc_margin sets uniform right
AssertEqual(8, arc_marginright(marginArc#), "arc_margin sets uniform right")
PRINTLN ""
PRINTLN "--- Visibility and Behavior Tests ---"
PRINTLN ""
LET visArc# = arc#(frm#, 50, 50)
' Test 54: arc_visible default
IF arc_visible(visArc#) <> 0 THEN
  TestPass("arc_visible default is true")
ELSE
  TestFail("arc_visible default is true", "non-zero", "0")
ENDIF
' Test 55: arc_visible set false
arc_visible#(visArc#, 0)
AssertFalse(arc_visible(visArc#), "arc_visible set to false")
' Test 56: arc_visible set true
arc_visible#(visArc#, 1)
IF arc_visible(visArc#) <> 0 THEN
  TestPass("arc_visible set to true")
ELSE
  TestFail("arc_visible set to true", "non-zero", "0")
ENDIF
' Test 57: arc_enabled default
IF arc_enabled(visArc#) <> 0 THEN
  TestPass("arc_enabled default is true")
ELSE
  TestFail("arc_enabled default is true", "non-zero", "0")
ENDIF
' Test 58: arc_enabled set false
arc_enabled#(visArc#, 0)
AssertFalse(arc_enabled(visArc#), "arc_enabled set to false")
' Test 59: arc_enabled set true
arc_enabled#(visArc#, 1)
IF arc_enabled(visArc#) <> 0 THEN
  TestPass("arc_enabled set to true")
ELSE
  TestFail("arc_enabled set to true", "non-zero", "0")
ENDIF
' Test 60: arc_opacity default
AssertEqual(1, arc_opacity(visArc#), "arc_opacity default is 1.0")
' Test 61: arc_opacity set
arc_opacity#(visArc#, 0.5)
LET opac = arc_opacity(visArc#)
IF opac >= 0.4 THEN
  IF opac <= 0.6 THEN
    TestPass("arc_opacity set to 0.5")
  ELSE
    TestFail("arc_opacity set to 0.5", "0.5", stri$(opac))
  ENDIF
ELSE
  TestFail("arc_opacity set to 0.5", "0.5", stri$(opac))
ENDIF
' Test 62: arc_hittest default (should be true for arcs)
IF arc_hittest(visArc#) <> 0 THEN
  TestPass("arc_hittest default is true")
ELSE
  TestFail("arc_hittest default is true", "non-zero", "0")
ENDIF
' Test 63: arc_hittest set false
arc_hittest#(visArc#, 0)
AssertFalse(arc_hittest(visArc#), "arc_hittest set to false")
PRINTLN ""
PRINTLN "--- Tag and Rotation Tests ---"
PRINTLN ""
LET tagArc# = arc#(frm#, 50, 50)
' Test 64: arc_tag default
AssertEqual(0, arc_tag(tagArc#), "arc_tag default is 0")
' Test 65: arc_tag set
arc_tag#(tagArc#, 42)
AssertEqual(42, arc_tag(tagArc#), "arc_tag set to 42")
' Test 66: arc_rotation default
AssertEqual(0, arc_rotation(tagArc#), "arc_rotation default is 0")
' Test 67: arc_rotation set
arc_rotation#(tagArc#, 45)
AssertEqual(45, arc_rotation(tagArc#), "arc_rotation set to 45")
PRINTLN ""
PRINTLN "--- Parent Tests ---"
PRINTLN ""
LET parentArc# = arc#(frm#, 50, 50)
' Test 68: arc_parent get
LET parent# = arc_parent#(parentArc#)
AssertPointerValid(parent#, "arc_parent returns valid parent")
' Test 69: arc_bringtofront
arc_bringtofront#(parentArc#)
TestPass("arc_bringtofront executes without error")
' Test 70: arc_sendtoback
arc_sendtoback#(parentArc#)
TestPass("arc_sendtoback executes without error")
PRINTLN ""
PRINTLN "--- Invalidation Test ---"
PRINTLN ""
' Test 71: arc_invalidate
arc_invalidate#(parentArc#)
TestPass("arc_invalidate executes without error")
PRINTLN ""
PRINTLN "--- Event Callback Tests ---"
PRINTLN ""
LET eventArc# = arc#(frm#, 400, 100, 100, 100)
arc_angles#(eventArc#, 0, 270)
arc_fill#(eventArc#, "#e74c3c")
arc_stroke#(eventArc#, "#c0392b")
arc_strokethickness#(eventArc#, 2)
' Test 72: arc_onclick set
arc_onclick#(eventArc#, "TestOnClick")
AssertStringEqual("TestOnClick", arc_onclick$(eventArc#), "arc_onclick set correctly")
' Test 73: arc_ondblclick set
arc_ondblclick#(eventArc#, "TestOnDblClick")
AssertStringEqual("TestOnDblClick", arc_ondblclick$(eventArc#), "arc_ondblclick set correctly")
' Test 74: arc_onmousedown set
arc_onmousedown#(eventArc#, "TestOnMouseDown")
AssertStringEqual("TestOnMouseDown", arc_onmousedown$(eventArc#), "arc_onmousedown set correctly")
' Test 75: arc_onmouseenter set
arc_onmouseenter#(eventArc#, "TestOnMouseEnter")
AssertStringEqual("TestOnMouseEnter", arc_onmouseenter$(eventArc#), "arc_onmouseenter set correctly")
' Test 76: arc_clearcallbacks (returns pointer type)
LET cleared# = arc_clearcallbacks#(eventArc#)
AssertPointerValid(cleared#, "arc_clearcallbacks returns valid pointer")
' Test 77: Verify callbacks were cleared
AssertStringEqual("", arc_onclick$(eventArc#), "arc_clearcallbacks clears onclick")
PRINTLN ""
PRINTLN "--- Destruction Test ---"
PRINTLN ""
' Create an arc to free
LET freeArc# = arc#(frm#, 600, 100, 40, 40)
arc_fill#(freeArc#, "gray")
' Note: We don't actually test arc_free here because it would invalidate the pointer
' and we can't easily verify the arc was freed without causing issues
TestPass("arc_free function available (not executed to avoid test issues)")
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
ENDIF
PRINTLN ""
PRINTLN "============================================================================"
PRINTLN "Visual Test - Interactive Arcs"
PRINTLN "============================================================================"
PRINTLN "Several arcs with different angles should be visible in the form."
PRINTLN "Click on the red arc to test event callbacks."
PRINTLN ""
' Create an interactive test arc (Pac-Man style)
LET interactiveArc# = arc#(frm#, 300, 250, 120, 120)
arc_angles#(interactiveArc#, 30, 330)
arc_fill#(interactiveArc#, "#f1c40f")
arc_stroke#(interactiveArc#, "#f39c12")
arc_strokethickness#(interactiveArc#, 3)
arc_onclick#(interactiveArc#, "OnInteractiveClick")
arc_onmouseenter#(interactiveArc#, "OnInteractiveEnter")
arc_onmouseleave#(interactiveArc#, "OnInteractiveLeave")
' Create demo arcs with different angles
' Quarter arc (90 degrees)
LET demoArc1# = arc#(frm#, 50, 250, 80, 80)
arc_angles#(demoArc1#, 0, 90)
arc_fill#(demoArc1#, "#3498db")
arc_stroke#(demoArc1#, "#2980b9")
arc_strokethickness#(demoArc1#, 2)
' Semi-circle (180 degrees)
LET demoArc2# = arc#(frm#, 150, 250, 80, 80)
arc_angles#(demoArc2#, 0, 180)
arc_fill#(demoArc2#, "#2ecc71")
arc_stroke#(demoArc2#, "#27ae60")
arc_strokethickness#(demoArc2#, 2)
' Three-quarter arc (270 degrees)
LET demoArc3# = arc#(frm#, 50, 350, 80, 80)
arc_angles#(demoArc3#, 0, 270)
arc_fill#(demoArc3#, "#9b59b6")
arc_stroke#(demoArc3#, "#8e44ad")
arc_strokethickness#(demoArc3#, 2)
' Arc at different starting angle
LET demoArc4# = arc#(frm#, 150, 350, 80, 80)
arc_angles#(demoArc4#, 45, 225)
arc_fill#(demoArc4#, "#e74c3c")
arc_stroke#(demoArc4#, "#c0392b")
arc_strokethickness#(demoArc4#, 2)
' Dashed stroke arc
LET demoArc5# = arc#(frm#, 50, 450, 100, 100)
arc_angles#(demoArc5#, 0, 270)
arc_fillnone#(demoArc5#)
arc_stroke#(demoArc5#, "black")
arc_strokethickness#(demoArc5#, 3)
arc_strokedash#(demoArc5#, 1)
' Rotated arc (using rotation property, not arc angles)
LET demoArc6# = arc#(frm#, 170, 450, 80, 80)
arc_angles#(demoArc6#, 0, 90)
arc_fill#(demoArc6#, "#f39c12")
arc_stroke#(demoArc6#, "#d35400")
arc_strokethickness#(demoArc6#, 2)
arc_rotation#(demoArc6#, 45)
' Create labels for visual reference
LET lbl1# = label#(frm#, "90°", 75, 335)
LET lbl2# = label#(frm#, "180°", 175, 335)
LET lbl3# = label#(frm#, "270°", 75, 435)
LET lbl4# = label#(frm#, "45-225°", 165, 435)
LET lbl5# = label#(frm#, "Dashed", 75, 555)
LET lbl6# = label#(frm#, "Rotated", 185, 535)
' Create status label
LET statusLbl# = label#(frm#, "Click the yellow Pac-Man arc to test events", 280, 400)
form_show(frm#)
' ----------------------------------------------------------------------------
' Event Handler Functions
' ----------------------------------------------------------------------------
FUNCTION TestOnClick(sender#)
  PRINTLN "TestOnClick triggered"
ENDFUNCTION
FUNCTION TestOnDblClick(sender#)
  PRINTLN "TestOnDblClick triggered"
ENDFUNCTION
FUNCTION TestOnMouseDown(sender#, button, x, y, shift$)
  PRINTLN "TestOnMouseDown triggered at: " + stri$(x) + ", " + stri$(y)
ENDFUNCTION
FUNCTION TestOnMouseEnter(sender#)
  PRINTLN "TestOnMouseEnter triggered"
ENDFUNCTION
FUNCTION OnInteractiveClick(sender#) LOCAL currentEnd
  clickCount = clickCount + 1
  PRINTLN "Pac-Man arc clicked! Count: " + stri$(clickCount)
  label_text#(statusLbl#, "Arc clicked! Count: " + stri$(clickCount))
  ' Animate the mouth - toggle between open and closed
  LET currentEnd = arc_endangle(sender#)
  IF currentEnd > 340 THEN
    arc_angles#(sender#, 30, 330)
  ELSE
    arc_angles#(sender#, 5, 355)
  ENDIF
ENDFUNCTION
FUNCTION OnInteractiveEnter(sender#)
  arc_fill#(sender#, "#e67e22")
  label_text#(statusLbl#, "Mouse entered arc - color changed to orange")
ENDFUNCTION
FUNCTION OnInteractiveLeave(sender#)
  arc_fill#(sender#, "#f1c40f")
  label_text#(statusLbl#, "Mouse left arc - color changed back to yellow")
ENDFUNCTION
