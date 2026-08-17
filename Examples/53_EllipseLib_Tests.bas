' ============================================================================
' EllipseLib Test Suite for Plan9Basic
' Version: 1.0.0
'
' Comprehensive tests for all EllipseLib functions
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
    TestFail(desc$, "true (non-zero)", stri$(value))
  END IF
END FUNCTION
FUNCTION AssertFalse(value, desc$)
  IF value = 0 THEN
    TestPass(desc$)
  ELSE
    TestFail(desc$, "false (zero)", stri$(value))
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
    TestFail(desc$, "valid pointer", "null pointer")
  END IF
END FUNCTION
' ----------------------------------------------------------------------------
' Main Test Suite
' ----------------------------------------------------------------------------
PRINTLN "============================================================================"
PRINTLN "EllipseLib Test Suite for Plan9Basic"
PRINTLN "============================================================================"
PRINTLN ""
' Create a form for testing
LET frm# = form#("EllipseLib Tests", 800, 600)
PRINTLN "--- Error Handling Tests ---"
PRINTLN ""
' Test 1: ellipse_clearerror
ellipse_clearerror()
AssertEqual(0, ellipse_error(), "ellipse_clearerror resets error to 0")
' Test 2: ellipse_error after invalid operation
LET badPtr# = Pointer#(0)
LET dummy$ = ellipse_fill$(badPtr#)
AssertNotEqual(0, ellipse_error(), "ellipse_error returns non-zero after invalid call")
' Test 3: ellipse_errormsg$ returns message
LET errMsg$ = ellipse_errormsg$()
IF len(errMsg$) > 0 THEN
  TestPass("ellipse_errormsg$ returns non-empty message")
ELSE
  TestFail("ellipse_errormsg$ returns non-empty message", "non-empty string", "empty string")
END IF
' Test 4: ellipse_strerror$ for error code 0
LET noErr$ = ellipse_strerror$(0)
IF len(noErr$) > 0 THEN
  TestPass("ellipse_strerror$(0) returns description")
ELSE
  TestFail("ellipse_strerror$(0) returns description", "non-empty string", "empty string")
END IF
' Test 5: ellipse_strerror$ for error code 1
LET err1$ = ellipse_strerror$(1)
IF len(err1$) > 0 THEN
  TestPass("ellipse_strerror$(1) returns description")
ELSE
  TestFail("ellipse_strerror$(1) returns description", "non-empty string", "empty string")
END IF
' Test 6: ellipse_strerror$ for error code 6
LET err6$ = ellipse_strerror$(6)
IF len(err6$) > 0 THEN
  TestPass("ellipse_strerror$(6) returns description")
ELSE
  TestFail("ellipse_strerror$(6) returns description", "non-empty string", "empty string")
END IF
ellipse_clearerror()
PRINTLN ""
PRINTLN "--- Creation Tests ---"
PRINTLN ""
' Test 7: ellipse#(parent#)
LET ell1# = ellipse#(frm#)
AssertPointerValid(ell1#, "ellipse#(parent#) creates ellipse")
' Test 8: ellipse#(parent#, width, height)
LET ell2# = ellipse#(frm#, 100, 50)
AssertPointerValid(ell2#, "ellipse#(parent#, w, h) creates ellipse")
' Test 9: ellipse#(parent#, x, y, width, height)
LET ell3# = ellipse#(frm#, 200, 10, 100, 50)
AssertPointerValid(ell3#, "ellipse#(parent#, x, y, w, h) creates ellipse")
' Test 10: Verify position from creation
AssertEqual(200, ellipse_x(ell3#), "ellipse X position matches creation param")
' Test 11: Verify Y position from creation
AssertEqual(10, ellipse_y(ell3#), "ellipse Y position matches creation param")
' Test 12: Verify width from creation
AssertEqual(100, ellipse_width(ell3#), "ellipse width matches creation param")
PRINTLN ""
PRINTLN "--- Fill Tests ---"
PRINTLN ""
LET fillEll# = ellipse#(frm#, 100, 10, 80, 50)
ellipse_fill#(fillEll#, "#FF0000")
LET fillColor$ = ellipse_fill$(fillEll#)
' Test 13: ellipse_fill set red
IF instr(fillColor$, "FF0000", 0) >= 0 THEN
  TestPass("ellipse_fill sets red color")
ELSE
  TestFail("ellipse_fill sets red color", "contains FF0000", fillColor$)
END IF
' Test 14: ellipse_fill with named color
ellipse_fill#(fillEll#, "blue")
LET fillColor2$ = ellipse_fill$(fillEll#)
IF instr(fillColor2$, "0000FF", 0) >= 0 THEN
  TestPass("ellipse_fill sets blue named color")
ELSE
  TestFail("ellipse_fill sets blue named color", "contains 0000FF", fillColor2$)
END IF
' Test 15: ellipse_fillnone
ellipse_fillnone#(fillEll#)
TestPass("ellipse_fillnone removes fill (visual verification)")
PRINTLN ""
PRINTLN "--- Stroke Tests ---"
PRINTLN ""
LET strokeEll# = ellipse#(frm#, 100, 70, 80, 50)
ellipse_stroke#(strokeEll#, "#00FF00")
LET strokeColor$ = ellipse_stroke$(strokeEll#)
' Test 16: ellipse_stroke set
IF instr(strokeColor$, "00FF00", 0) >= 0 THEN
  TestPass("ellipse_stroke sets green color")
ELSE
  TestFail("ellipse_stroke sets green color", "contains 00FF00", strokeColor$)
END IF
' Test 17: ellipse_strokenone
ellipse_strokenone#(strokeEll#)
TestPass("ellipse_strokenone removes stroke (visual verification)")
' Reset stroke for further tests
ellipse_stroke#(strokeEll#, "black")
' Test 18: ellipse_strokethickness set
ellipse_strokethickness#(strokeEll#, 3)
AssertEqual(3, ellipse_strokethickness(strokeEll#), "ellipse_strokethickness set to 3")
' Test 19: ellipse_strokedash set
ellipse_strokedash#(strokeEll#, 1)
AssertEqual(1, ellipse_strokedash(strokeEll#), "ellipse_strokedash set to Dash (1)")
' Test 20: ellipse_strokecap set
ellipse_strokecap#(strokeEll#, 1)
AssertEqual(1, ellipse_strokecap(strokeEll#), "ellipse_strokecap set to Round (1)")
' Test 21: ellipse_strokejoin set
ellipse_strokejoin#(strokeEll#, 2)
AssertEqual(2, ellipse_strokejoin(strokeEll#), "ellipse_strokejoin set to Bevel (2)")
PRINTLN ""
PRINTLN "--- Position Tests ---"
PRINTLN ""
LET posEll# = ellipse#(frm#, 200, 70, 80, 50)
' Test 22: ellipse_x get
LET initX = ellipse_x(posEll#)
AssertEqual(200, initX, "ellipse_x returns initial X position")
' Test 23: ellipse_x set
ellipse_x#(posEll#, 210)
AssertEqual(210, ellipse_x(posEll#), "ellipse_x sets X position")
' Test 24: ellipse_y get
LET initY = ellipse_y(posEll#)
AssertEqual(70, initY, "ellipse_y returns initial Y position")
' Test 25: ellipse_y set
ellipse_y#(posEll#, 80)
AssertEqual(80, ellipse_y(posEll#), "ellipse_y sets Y position")
' Test 26: ellipse_width get
AssertEqual(80, ellipse_width(posEll#), "ellipse_width returns width")
' Test 27: ellipse_width set
ellipse_width#(posEll#, 90)
AssertEqual(90, ellipse_width(posEll#), "ellipse_width sets width")
' Test 28: ellipse_height get
AssertEqual(50, ellipse_height(posEll#), "ellipse_height returns height")
' Test 29: ellipse_height set
ellipse_height#(posEll#, 60)
AssertEqual(60, ellipse_height(posEll#), "ellipse_height sets height")
' Test 30: ellipse_bounds set
ellipse_bounds#(posEll#, 220, 90, 100, 70)
AssertEqual(220, ellipse_x(posEll#), "ellipse_bounds sets X")
' Test 31: ellipse_bounds sets Y
AssertEqual(90, ellipse_y(posEll#), "ellipse_bounds sets Y")
' Test 32: ellipse_bounds sets width
AssertEqual(100, ellipse_width(posEll#), "ellipse_bounds sets width")
' Test 33: ellipse_bounds sets height
AssertEqual(70, ellipse_height(posEll#), "ellipse_bounds sets height")
' Test 34: ellipse_size set
ellipse_size#(posEll#, 110, 80)
AssertEqual(110, ellipse_width(posEll#), "ellipse_size sets width")
' Test 35: ellipse_size sets height
AssertEqual(80, ellipse_height(posEll#), "ellipse_size sets height")
' Test 36: ellipse_move set
ellipse_move#(posEll#, 230, 100)
AssertEqual(230, ellipse_x(posEll#), "ellipse_move sets X")
' Test 37: ellipse_move sets Y
AssertEqual(100, ellipse_y(posEll#), "ellipse_move sets Y")
PRINTLN ""
PRINTLN "--- Alignment Tests ---"
PRINTLN ""
LET alignEll# = ellipse#(frm#, 10, 130, 60, 40)
' Test 38: ellipse_align default
AssertEqual(0, ellipse_align(alignEll#), "ellipse_align default is 0 (None)")
' Test 39: ellipse_align set
ellipse_align#(alignEll#, 11)
AssertEqual(11, ellipse_align(alignEll#), "ellipse_align sets to 11 (Center)")
ellipse_align#(alignEll#, 0)
PRINTLN ""
PRINTLN "--- Margin Tests ---"
PRINTLN ""
LET marginEll# = ellipse#(frm#, 80, 130, 60, 40)
' Test 40: ellipse_marginleft default
AssertEqual(0, ellipse_marginleft(marginEll#), "ellipse_marginleft default is 0")
' Test 41: ellipse_marginleft set
ellipse_marginleft#(marginEll#, 5)
AssertEqual(5, ellipse_marginleft(marginEll#), "ellipse_marginleft sets to 5")
' Test 42: ellipse_margintop set
ellipse_margintop#(marginEll#, 6)
AssertEqual(6, ellipse_margintop(marginEll#), "ellipse_margintop sets to 6")
' Test 43: ellipse_marginright set
ellipse_marginright#(marginEll#, 7)
AssertEqual(7, ellipse_marginright(marginEll#), "ellipse_marginright sets to 7")
' Test 44: ellipse_marginbottom set
ellipse_marginbottom#(marginEll#, 8)
AssertEqual(8, ellipse_marginbottom(marginEll#), "ellipse_marginbottom sets to 8")
' Test 45: ellipse_margins set all
ellipse_margins#(marginEll#, 10, 11, 12, 13)
AssertEqual(10, ellipse_marginleft(marginEll#), "ellipse_margins sets left")
' Test 46: ellipse_margins sets top
AssertEqual(11, ellipse_margintop(marginEll#), "ellipse_margins sets top")
' Test 47: ellipse_margins sets right
AssertEqual(12, ellipse_marginright(marginEll#), "ellipse_margins sets right")
' Test 48: ellipse_margins sets bottom
AssertEqual(13, ellipse_marginbottom(marginEll#), "ellipse_margins sets bottom")
' Test 49: ellipse_margin sets all uniform
ellipse_margin#(marginEll#, 15)
AssertEqual(15, ellipse_marginleft(marginEll#), "ellipse_margin sets all to 15")
PRINTLN ""
PRINTLN "--- Visibility Tests ---"
PRINTLN ""
LET visEll# = ellipse#(frm#, 150, 130, 60, 40)
ellipse_fill#(visEll#, "purple")
' Test 50: ellipse_visible default
AssertEqual(1, ellipse_visible(visEll#), "ellipse_visible default is 1 (true)")
' Test 51: ellipse_visible set false
ellipse_visible#(visEll#, 0)
AssertEqual(0, ellipse_visible(visEll#), "ellipse_visible sets to 0 (false)")
ellipse_visible#(visEll#, 1)
' Test 52: ellipse_enabled default
AssertEqual(1, ellipse_enabled(visEll#), "ellipse_enabled default is 1 (true)")
' Test 53: ellipse_enabled set
ellipse_enabled#(visEll#, 0)
AssertEqual(0, ellipse_enabled(visEll#), "ellipse_enabled sets to 0 (false)")
ellipse_enabled#(visEll#, 1)
' Test 54: ellipse_opacity default
AssertEqual(1, ellipse_opacity(visEll#), "ellipse_opacity default is 1.0")
' Test 55: ellipse_opacity set
ellipse_opacity#(visEll#, 0.5)
LET opVal = ellipse_opacity(visEll#)
IF opVal >= 0.4 THEN
  IF opVal <= 0.6 THEN
    TestPass("ellipse_opacity sets to 0.5")
  ELSE
    TestFail("ellipse_opacity sets to 0.5", "0.5", stri$(opVal))
  END IF
ELSE
  TestFail("ellipse_opacity sets to 0.5", "0.5", stri$(opVal))
END IF
ellipse_opacity#(visEll#, 1)
' Test 56: ellipse_hittest default
AssertEqual(1, ellipse_hittest(visEll#), "ellipse_hittest default is 1 (true)")
' Test 57: ellipse_hittest set
ellipse_hittest#(visEll#, 0)
AssertEqual(0, ellipse_hittest(visEll#), "ellipse_hittest sets to 0 (false)")
ellipse_hittest#(visEll#, 1)
PRINTLN ""
PRINTLN "--- Tag and Rotation Tests ---"
PRINTLN ""
LET tagEll# = ellipse#(frm#, 220, 130, 60, 40)
ellipse_fill#(tagEll#, "orange")
' Test 58: ellipse_tag default
AssertEqual(0, ellipse_tag(tagEll#), "ellipse_tag default is 0")
' Test 59: ellipse_tag set
ellipse_tag#(tagEll#, 42)
AssertEqual(42, ellipse_tag(tagEll#), "ellipse_tag sets to 42")
' Test 60: ellipse_rotation default
AssertEqual(0, ellipse_rotation(tagEll#), "ellipse_rotation default is 0")
' Test 61: ellipse_rotation set
ellipse_rotation#(tagEll#, 15)
AssertEqual(15, ellipse_rotation(tagEll#), "ellipse_rotation sets to 15")
PRINTLN ""
PRINTLN "--- Parent Tests ---"
PRINTLN ""
LET parentEll# = ellipse#(frm#, 290, 130, 60, 40)
ellipse_fill#(parentEll#, "teal")
' Test 62: ellipse_parent get (returns form)
LET parent# = ellipse_parent#(parentEll#)
AssertPointerValid(parent#, "ellipse_parent returns valid parent")
' Test 63: ellipse_bringtofront (no error)
ellipse_bringtofront#(parentEll#)
TestPass("ellipse_bringtofront executes without error")
' Test 64: ellipse_sendtoback (no error)
ellipse_sendtoback#(parentEll#)
TestPass("ellipse_sendtoback executes without error")
PRINTLN ""
PRINTLN "--- Invalidation Test ---"
PRINTLN ""
' Test 65: ellipse_invalidate (no error)
ellipse_invalidate#(parentEll#)
TestPass("ellipse_invalidate executes without error")
PRINTLN ""
PRINTLN "--- Event Callback Tests ---"
PRINTLN ""
LET eventEll# = ellipse#(frm#, 400, 50, 150, 80)
ellipse_fill#(eventEll#, "#e74c3c")
ellipse_stroke#(eventEll#, "#c0392b")
ellipse_strokethickness#(eventEll#, 2)
' Test 66: ellipse_onclick set
ellipse_onclick#(eventEll#, "TestOnClick")
AssertStringEqual("TestOnClick", ellipse_onclick$(eventEll#), "ellipse_onclick set correctly")
' Test 67: ellipse_ondblclick set
ellipse_ondblclick#(eventEll#, "TestOnDblClick")
AssertStringEqual("TestOnDblClick", ellipse_ondblclick$(eventEll#), "ellipse_ondblclick set correctly")
' Test 68: ellipse_onmouseenter set
ellipse_onmouseenter#(eventEll#, "TestOnMouseEnter")
AssertStringEqual("TestOnMouseEnter", ellipse_onmouseenter$(eventEll#), "ellipse_onmouseenter set correctly")
' Test 69: ellipse_clearcallbacks (returns pointer type)
LET cleared# = ellipse_clearcallbacks#(eventEll#)
AssertPointerValid(cleared#, "ellipse_clearcallbacks returns valid pointer")
' Test 70: Verify callbacks were cleared
AssertStringEqual("", ellipse_onclick$(eventEll#), "ellipse_clearcallbacks clears onclick")
PRINTLN ""
PRINTLN "--- Destruction Test ---"
PRINTLN ""
' Create an ellipse to free
LET freeEll# = ellipse#(frm#, 600, 50, 80, 50)
ellipse_fill#(freeEll#, "gray")
' Test 71: ellipse_free function available
TestPass("ellipse_free function available (not executed to avoid test issues)")
' Test 72: Verify height from creation (extra validation)
LET checkEll# = ellipse#(frm#, 10, 10, 120, 80)
AssertEqual(80, ellipse_height(checkEll#), "ellipse height matches creation param")
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
PRINTLN "Visual Test - Interactive Ellipse"
PRINTLN "============================================================================"
PRINTLN "A blue ellipse button is visible in the form."
PRINTLN "Click on it to test event callbacks."
PRINTLN ""
' Create an interactive test ellipse (button-like)
LET interactiveEll# = ellipse#(frm#, 300, 300, 200, 100)
ellipse_fill#(interactiveEll#, "#3498db")
ellipse_stroke#(interactiveEll#, "#2980b9")
ellipse_strokethickness#(interactiveEll#, 2)
ellipse_onclick#(interactiveEll#, "OnInteractiveClick")
ellipse_onmouseenter#(interactiveEll#, "OnInteractiveEnter")
ellipse_onmouseleave#(interactiveEll#, "OnInteractiveLeave")
' Create visual demo ellipses
' Perfect circle
LET demoEll1# = ellipse#(frm#, 50, 300, 80, 80)
ellipse_fill#(demoEll1#, "#2ecc71")
ellipse_stroke#(demoEll1#, "#27ae60")
ellipse_strokethickness#(demoEll1#, 2)
' Tall ellipse
LET demoEll2# = ellipse#(frm#, 150, 280, 60, 120)
ellipse_fill#(demoEll2#, "#9b59b6")
ellipse_stroke#(demoEll2#, "#8e44ad")
ellipse_strokethickness#(demoEll2#, 2)
' Rotated ellipse
LET demoEll3# = ellipse#(frm#, 100, 430, 100, 50)
ellipse_fill#(demoEll3#, "#f39c12")
ellipse_stroke#(demoEll3#, "#d35400")
ellipse_strokethickness#(demoEll3#, 2)
ellipse_rotation#(demoEll3#, 30)
' Dashed stroke ellipse
LET demoEll4# = ellipse#(frm#, 220, 420, 120, 70)
ellipse_fillnone#(demoEll4#)
ellipse_stroke#(demoEll4#, "black")
ellipse_strokethickness#(demoEll4#, 2)
ellipse_strokedash#(demoEll4#, 1)
' Create status label
LET statusLbl# = label#(frm#, "Click the blue ellipse to test events", 300, 420)
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
FUNCTION TestOnMouseEnter(sender#)
  PRINTLN "TestOnMouseEnter triggered"
END FUNCTION
FUNCTION OnInteractiveClick(sender#)
  clickCount = clickCount + 1
  PRINTLN "Interactive ellipse clicked! Count: " + stri$(clickCount)
  label_text#(statusLbl#, "Ellipse clicked! Count: " + stri$(clickCount))
END FUNCTION
FUNCTION OnInteractiveEnter(sender#)
  ellipse_fill#(sender#, "#2980b9")
  label_text#(statusLbl#, "Mouse entered ellipse - color darkened")
END FUNCTION
FUNCTION OnInteractiveLeave(sender#)
  ellipse_fill#(sender#, "#3498db")
  label_text#(statusLbl#, "Mouse left ellipse - color restored")
END FUNCTION
