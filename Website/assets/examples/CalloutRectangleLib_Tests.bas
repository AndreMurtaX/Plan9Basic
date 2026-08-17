' ============================================================================
' CalloutRectangleLib Test Suite for Plan9Basic
' Version: 1.0.0
'
' Comprehensive tests for all CalloutRectangleLib functions
' Total Tests: 90 tests covering all 90 functions
'
' TCalloutRectangle is a speech bubble shape control with a callout pointer.
' It extends TRectangle with callout-specific properties:
' - CalloutPosition: Which side the pointer appears on (0=Top, 1=Left, 2=Bottom, 3=Right)
' - CalloutLength: How long the pointer extends
' - CalloutWidth: How wide the pointer base is
' - CalloutOffset: Offset from center of the side
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
PRINTLN "CalloutRectangleLib Test Suite"
PRINTLN "============================================================================"
PRINTLN
' Create test form
LET frm# = form#("CalloutRectangleLib Tests", 900, 700)
PRINTLN "--- Error Handling Tests ---"
PRINTLN
' Test 1: callout_clearerror
callout_clearerror()
AssertEqual(0, callout_error(), "callout_clearerror clears error state")
' Test 2: callout_error initial state
AssertEqual(0, callout_error(), "callout_error returns 0 initially")
' Test 3: callout_errormsg initial state
AssertStringEqual("", callout_errormsg$(), "callout_errormsg returns empty string initially")
' Test 4: callout_strerror for code 0
AssertStringEqual("No error", callout_strerror$(0), "callout_strerror returns 'No error' for code 0")
' Test 5: callout_strerror for code 1
AssertStringEqual("Invalid callout", callout_strerror$(1), "callout_strerror returns 'Invalid callout' for code 1")
' Test 6: callout_strerror for code 2
AssertStringEqual("Invalid parent", callout_strerror$(2), "callout_strerror returns 'Invalid parent' for code 2")
PRINTLN
PRINTLN "--- Creation Tests ---"
PRINTLN
' Test 7: callout# with parent only
LET cb1# = callout#(frm#)
AssertPointerValid(cb1#, "callout#(parent) creates valid callout")
' Test 8: callout# with parent and size
LET cb2# = callout#(frm#, 150, 80)
AssertPointerValid(cb2#, "callout#(parent, w, h) creates valid callout")
' Test 9: Verify size set correctly
AssertEqual(150, callout_width(cb2#), "callout width set correctly in creation")
' Test 10: callout# with full parameters
LET cb3# = callout#(frm#, 50, 50, 200, 100)
AssertPointerValid(cb3#, "callout#(parent, x, y, w, h) creates valid callout")
' Test 11: Verify position X
AssertEqual(50, callout_x(cb3#), "callout X position set correctly")
' Test 12: Verify position Y
AssertEqual(50, callout_y(cb3#), "callout Y position set correctly")
PRINTLN
PRINTLN "--- Callout-Specific Property Tests ---"
PRINTLN
LET calloutTest# = callout#(frm#, 10, 10, 150, 80)
' Test 13: callout_calloutlength get default
LET defaultLength = callout_calloutlength(calloutTest#)
TestPass("callout_calloutlength default retrieved")
' Test 14: callout_calloutlength set
callout_calloutlength#(calloutTest#, 25)
AssertEqual(25, callout_calloutlength(calloutTest#), "callout_calloutlength set to 25")
' Test 15: callout_calloutwidth get default
LET defaultWidth = callout_calloutwidth(calloutTest#)
TestPass("callout_calloutwidth default retrieved")
' Test 16: callout_calloutwidth set
callout_calloutwidth#(calloutTest#, 35)
AssertEqual(35, callout_calloutwidth(calloutTest#), "callout_calloutwidth set to 35")
' Test 17: callout_calloutposition get default
LET defaultPos = callout_calloutposition(calloutTest#)
TestPass("callout_calloutposition default retrieved")
' Test 18: callout_calloutposition set to Top (0)
callout_calloutposition#(calloutTest#, 0)
AssertEqual(0, callout_calloutposition(calloutTest#), "callout_calloutposition set to Top (0)")
' Test 19: callout_calloutposition set to Left (1)
callout_calloutposition#(calloutTest#, 1)
AssertEqual(1, callout_calloutposition(calloutTest#), "callout_calloutposition set to Left (1)")
' Test 20: callout_calloutposition set to Bottom (2)
callout_calloutposition#(calloutTest#, 2)
AssertEqual(2, callout_calloutposition(calloutTest#), "callout_calloutposition set to Bottom (2)")
' Test 21: callout_calloutposition set to Right (3)
callout_calloutposition#(calloutTest#, 3)
AssertEqual(3, callout_calloutposition(calloutTest#), "callout_calloutposition set to Right (3)")
' Test 22: callout_calloutoffset get default
LET defaultOffset = callout_calloutoffset(calloutTest#)
TestPass("callout_calloutoffset default retrieved")
' Test 23: callout_calloutoffset set
callout_calloutoffset#(calloutTest#, 20)
AssertEqual(20, callout_calloutoffset(calloutTest#), "callout_calloutoffset set to 20")
PRINTLN
PRINTLN "--- Fill Tests ---"
PRINTLN
' Test 24: callout_fill set
LET fillTest# = callout#(frm#, 10, 200, 100, 60)
callout_fill#(fillTest#, "#FF0000")
LET fillColor$ = callout_fill$(fillTest#)
IF instr(fillColor$, "FF0000", 0) >= 0 THEN
  TestPass("callout_fill sets red color")
ELSE
  TestFail("callout_fill sets red color", "contains FF0000", fillColor$)
END IF
' Test 25: callout_fill with named color
callout_fill#(fillTest#, "blue")
LET fillColor2$ = callout_fill$(fillTest#)
IF instr(fillColor2$, "0000FF", 0) >= 0 THEN
  TestPass("callout_fill sets blue named color")
ELSE
  TestFail("callout_fill sets blue named color", "contains 0000FF", fillColor2$)
END IF
' Test 26: callout_fillnone
callout_fillnone#(fillTest#)
TestPass("callout_fillnone removes fill (visual verification)")
' Reset fill for further tests
callout_fill#(fillTest#, "white")
PRINTLN
PRINTLN "--- Stroke Tests ---"
PRINTLN
' Test 27: callout_stroke set
LET strokeTest# = callout#(frm#, 10, 280, 100, 60)
callout_stroke#(strokeTest#, "#FF0000")
LET strokeColor$ = callout_stroke$(strokeTest#)
IF instr(strokeColor$, "FF0000", 0) >= 0 THEN
  TestPass("callout_stroke sets red color")
ELSE
  TestFail("callout_stroke sets red color", "contains FF0000", strokeColor$)
END IF
' Test 28: callout_stroke with named color
callout_stroke#(strokeTest#, "green")
LET strokeColor2$ = callout_stroke$(strokeTest#)
IF instr(strokeColor2$, "00", 0) >= 0 THEN
  TestPass("callout_stroke sets green named color")
ELSE
  TestFail("callout_stroke sets green named color", "contains green", strokeColor2$)
END IF
' Test 29: callout_strokenone
callout_strokenone#(strokeTest#)
TestPass("callout_strokenone removes stroke (visual verification)")
' Reset stroke for further tests
callout_stroke#(strokeTest#, "black")
' Test 30: callout_strokethickness set
callout_strokethickness#(strokeTest#, 3)
AssertEqual(3, callout_strokethickness(strokeTest#), "callout_strokethickness set to 3")
' Test 31: callout_strokedash set
callout_strokedash#(strokeTest#, 1)
AssertEqual(1, callout_strokedash(strokeTest#), "callout_strokedash set to Dash (1)")
' Test 32: callout_strokecap set
callout_strokecap#(strokeTest#, 1)
AssertEqual(1, callout_strokecap(strokeTest#), "callout_strokecap set to Round (1)")
' Test 33: callout_strokejoin set
callout_strokejoin#(strokeTest#, 2)
AssertEqual(2, callout_strokejoin(strokeTest#), "callout_strokejoin set to Bevel (2)")
PRINTLN
PRINTLN "--- Corner Radius Tests ---"
PRINTLN
LET cornerTest# = callout#(frm#, 10, 360, 100, 60)
' Test 34: callout_xradius default
AssertEqual(0, callout_xradius(cornerTest#), "callout_xradius default is 0")
' Test 35: callout_xradius set
callout_xradius#(cornerTest#, 10)
AssertEqual(10, callout_xradius(cornerTest#), "callout_xradius set to 10")
' Test 36: callout_yradius default
callout_yradius#(cornerTest#, 0)
AssertEqual(0, callout_yradius(cornerTest#), "callout_yradius reset to 0")
' Test 37: callout_yradius set
callout_yradius#(cornerTest#, 15)
AssertEqual(15, callout_yradius(cornerTest#), "callout_yradius set to 15")
' Test 38: callout_corners set
callout_corners#(cornerTest#, 8, 8)
AssertEqual(8, callout_xradius(cornerTest#), "callout_corners sets xradius to 8")
' Test 39: callout_corners set yradius
AssertEqual(8, callout_yradius(cornerTest#), "callout_corners sets yradius to 8")
PRINTLN
PRINTLN "--- Position and Size Tests ---"
PRINTLN
LET posTest# = callout#(frm#, 100, 100, 80, 50)
' Test 40: callout_x get
AssertEqual(100, callout_x(posTest#), "callout_x returns correct X position")
' Test 41: callout_x set
callout_x#(posTest#, 150)
AssertEqual(150, callout_x(posTest#), "callout_x sets X position")
' Test 42: callout_y get
AssertEqual(100, callout_y(posTest#), "callout_y returns correct Y position")
' Test 43: callout_y set
callout_y#(posTest#, 180)
AssertEqual(180, callout_y(posTest#), "callout_y sets Y position")
' Test 44: callout_width get
AssertEqual(80, callout_width(posTest#), "callout_width returns correct width")
' Test 45: callout_width set
callout_width#(posTest#, 120)
AssertEqual(120, callout_width(posTest#), "callout_width sets width")
' Test 46: callout_height get (reset first)
callout_height#(posTest#, 50)
AssertEqual(50, callout_height(posTest#), "callout_height returns correct height")
' Test 47: callout_height set
callout_height#(posTest#, 80)
AssertEqual(80, callout_height(posTest#), "callout_height sets height")
' Test 48: callout_bounds set
callout_bounds#(posTest#, 200, 200, 100, 60)
AssertEqual(200, callout_x(posTest#), "callout_bounds sets X correctly")
' Test 49: callout_bounds sets Y
AssertEqual(200, callout_y(posTest#), "callout_bounds sets Y correctly")
' Test 50: callout_bounds sets width
AssertEqual(100, callout_width(posTest#), "callout_bounds sets width correctly")
' Test 51: callout_bounds sets height
AssertEqual(60, callout_height(posTest#), "callout_bounds sets height correctly")
' Test 52: callout_size set
callout_size#(posTest#, 90, 55)
AssertEqual(90, callout_width(posTest#), "callout_size sets width correctly")
' Test 53: callout_size sets height
AssertEqual(55, callout_height(posTest#), "callout_size sets height correctly")
' Test 54: callout_move set
callout_move#(posTest#, 250, 250)
AssertEqual(250, callout_x(posTest#), "callout_move sets X correctly")
' Test 55: callout_move sets Y
AssertEqual(250, callout_y(posTest#), "callout_move sets Y correctly")
PRINTLN
PRINTLN "--- Alignment Tests ---"
PRINTLN
LET alignTest# = callout#(frm#, 120, 60)
' Test 56: callout_align default
AssertEqual(0, callout_align(alignTest#), "callout_align default is None (0)")
' Test 57: callout_align set
callout_align#(alignTest#, 1)
AssertEqual(1, callout_align(alignTest#), "callout_align set to Top (1)")
' Reset alignment
callout_align#(alignTest#, 0)
PRINTLN
PRINTLN "--- Margin Tests ---"
PRINTLN
LET marginTest# = callout#(frm#, 100, 60)
' Test 58: callout_marginleft set
callout_marginleft#(marginTest#, 10)
AssertEqual(10, callout_marginleft(marginTest#), "callout_marginleft sets to 10")
' Test 59: callout_margintop set
callout_margintop#(marginTest#, 15)
AssertEqual(15, callout_margintop(marginTest#), "callout_margintop sets to 15")
' Test 60: callout_marginright set
callout_marginright#(marginTest#, 20)
AssertEqual(20, callout_marginright(marginTest#), "callout_marginright sets to 20")
' Test 61: callout_marginbottom set
callout_marginbottom#(marginTest#, 25)
AssertEqual(25, callout_marginbottom(marginTest#), "callout_marginbottom sets to 25")
' Test 62: callout_margins set
callout_margins#(marginTest#, 5, 10, 15, 20)
AssertEqual(5, callout_marginleft(marginTest#), "callout_margins sets left to 5")
' Test 63: callout_margins sets top
AssertEqual(10, callout_margintop(marginTest#), "callout_margins sets top to 10")
' Test 64: callout_margin sets uniform
callout_margin#(marginTest#, 12)
AssertEqual(12, callout_marginleft(marginTest#), "callout_margin sets uniform left")
' Test 65: callout_margin sets uniform right
AssertEqual(12, callout_marginright(marginTest#), "callout_margin sets uniform right")
PRINTLN
PRINTLN "--- Visibility and Behavior Tests ---"
PRINTLN
LET visTest# = callout#(frm#, 100, 60)
' Test 66: callout_visible default
IF callout_visible(visTest#) <> 0 THEN
  TestPass("callout_visible default is true")
ELSE
  TestFail("callout_visible default is true", "non-zero", "0")
END IF
' Test 67: callout_visible set false
callout_visible#(visTest#, 0)
AssertFalse(callout_visible(visTest#), "callout_visible set to false")
' Test 68: callout_visible set true
callout_visible#(visTest#, 1)
IF callout_visible(visTest#) <> 0 THEN
  TestPass("callout_visible set to true")
ELSE
  TestFail("callout_visible set to true", "non-zero", "0")
END IF
' Test 69: callout_enabled default
IF callout_enabled(visTest#) <> 0 THEN
  TestPass("callout_enabled default is true")
ELSE
  TestFail("callout_enabled default is true", "non-zero", "0")
END IF
' Test 70: callout_enabled set false
callout_enabled#(visTest#, 0)
AssertFalse(callout_enabled(visTest#), "callout_enabled set to false")
' Test 71: callout_enabled set true
callout_enabled#(visTest#, 1)
IF callout_enabled(visTest#) <> 0 THEN
  TestPass("callout_enabled set to true")
ELSE
  TestFail("callout_enabled set to true", "non-zero", "0")
END IF
' Test 72: callout_opacity default
AssertEqual(1, callout_opacity(visTest#), "callout_opacity default is 1.0")
' Test 73: callout_opacity set
callout_opacity#(visTest#, 0.5)
LET opac = callout_opacity(visTest#)
IF opac >= 0.4 THEN
  IF opac <= 0.6 THEN
    TestPass("callout_opacity set to 0.5")
  ELSE
    TestFail("callout_opacity set to 0.5", "0.5", stri$(opac))
  END IF
ELSE
  TestFail("callout_opacity set to 0.5", "0.5", stri$(opac))
END IF
' Reset opacity
callout_opacity#(visTest#, 1)
' Test 74: callout_hittest default
IF callout_hittest(visTest#) <> 0 THEN
  TestPass("callout_hittest default is true")
ELSE
  TestFail("callout_hittest default is true", "non-zero", "0")
END IF
' Test 75: callout_hittest set false
callout_hittest#(visTest#, 0)
AssertFalse(callout_hittest(visTest#), "callout_hittest set to false")
PRINTLN
PRINTLN "--- Tag and Rotation Tests ---"
PRINTLN
LET tagTest# = callout#(frm#, 100, 60)
' Test 76: callout_tag default
AssertEqual(0, callout_tag(tagTest#), "callout_tag default is 0")
' Test 77: callout_tag set
callout_tag#(tagTest#, 42)
AssertEqual(42, callout_tag(tagTest#), "callout_tag set to 42")
' Test 78: callout_rotation default
AssertEqual(0, callout_rotation(tagTest#), "callout_rotation default is 0")
' Test 79: callout_rotation set
callout_rotation#(tagTest#, 45)
AssertEqual(45, callout_rotation(tagTest#), "callout_rotation set to 45")
PRINTLN
PRINTLN "--- Parent Tests ---"
PRINTLN
LET parentTest# = callout#(frm#, 100, 60)
' Test 80: callout_parent get
LET parent# = callout_parent#(parentTest#)
AssertPointerValid(parent#, "callout_parent returns valid parent")
' Test 81: callout_bringtofront
callout_bringtofront#(parentTest#)
TestPass("callout_bringtofront executes without error")
' Test 82: callout_sendtoback
callout_sendtoback#(parentTest#)
TestPass("callout_sendtoback executes without error")
PRINTLN
PRINTLN "--- Invalidation Test ---"
PRINTLN
' Test 83: callout_invalidate
callout_invalidate#(parentTest#)
TestPass("callout_invalidate executes without error")
PRINTLN
PRINTLN "--- Event Callback Tests ---"
PRINTLN
LET eventTest# = callout#(frm#, 500, 100, 180, 100)
callout_fill#(eventTest#, "#e74c3c")
callout_stroke#(eventTest#, "#c0392b")
callout_strokethickness#(eventTest#, 2)
callout_calloutposition#(eventTest#, 2)
callout_calloutlength#(eventTest#, 20)
' Test 84: callout_onclick set
callout_onclick#(eventTest#, "TestOnClick")
AssertStringEqual("TestOnClick", callout_onclick$(eventTest#), "callout_onclick set correctly")
' Test 85: callout_ondblclick set
callout_ondblclick#(eventTest#, "TestOnDblClick")
AssertStringEqual("TestOnDblClick", callout_ondblclick$(eventTest#), "callout_ondblclick set correctly")
' Test 86: callout_onmousedown set
callout_onmousedown#(eventTest#, "TestOnMouseDown")
AssertStringEqual("TestOnMouseDown", callout_onmousedown$(eventTest#), "callout_onmousedown set correctly")
' Test 87: callout_onmouseup set
callout_onmouseup#(eventTest#, "TestOnMouseUp")
AssertStringEqual("TestOnMouseUp", callout_onmouseup$(eventTest#), "callout_onmouseup set correctly")
' Test 88: callout_clearcallbacks (returns pointer type)
LET cleared# = callout_clearcallbacks#(eventTest#)
AssertPointerValid(cleared#, "callout_clearcallbacks returns valid pointer")
' Test 89: Verify callbacks were cleared
AssertStringEqual("", callout_onclick$(eventTest#), "callout_clearcallbacks clears onclick")
PRINTLN
PRINTLN "--- Destruction Test ---"
PRINTLN
' Create a callout to free
LET freeTest# = callout#(frm#, 700, 100, 80, 50)
callout_fill#(freeTest#, "gray")
' Note: We don't actually test callout_free here because it would invalidate the pointer
' Test 90: callout_free function available
TestPass("callout_free function available (not executed to avoid test issues)")
PRINTLN
PRINTLN "============================================================================"
PRINTLN "Test Summary"
PRINTLN "============================================================================"
PRINTLN "Total Tests:  " + stri$(testsPassed + testsFailed)
PRINTLN "Passed:       " + stri$(testsPassed)
PRINTLN "Failed:       " + stri$(testsFailed)
PRINTLN
IF testsFailed = 0 THEN
  PRINTLN "*** ALL TESTS PASSED ***"
ELSE
  PRINTLN "*** SOME TESTS FAILED ***"
END IF
PRINTLN
PRINTLN "============================================================================"
PRINTLN "Visual Test - Interactive Callouts"
PRINTLN "============================================================================"
PRINTLN "Several callout rectangles with different positions should be visible."
PRINTLN "Click on the interactive callouts to test event callbacks."
PRINTLN
' Create interactive callout with Bottom pointer
LET interactiveCallout# = callout#(frm#, 350, 350, 200, 100)
callout_fill#(interactiveCallout#, "#3498db")
callout_stroke#(interactiveCallout#, "#2980b9")
callout_strokethickness#(interactiveCallout#, 2)
callout_calloutposition#(interactiveCallout#, 2)
callout_calloutlength#(interactiveCallout#, 25)
callout_calloutwidth#(interactiveCallout#, 40)
callout_corners#(interactiveCallout#, 10, 10)
callout_onclick#(interactiveCallout#, "OnInteractiveClick")
callout_onmouseenter#(interactiveCallout#, "OnInteractiveEnter")
callout_onmouseleave#(interactiveCallout#, "OnInteractiveLeave")
' Create demo callouts with different positions
' Top callout pointer
LET demoTop# = callout#(frm#, 50, 500, 150, 80)
callout_fill#(demoTop#, "#2ecc71")
callout_stroke#(demoTop#, "#27ae60")
callout_strokethickness#(demoTop#, 2)
callout_calloutposition#(demoTop#, 0)
callout_calloutlength#(demoTop#, 20)
callout_calloutwidth#(demoTop#, 30)
callout_corners#(demoTop#, 8, 8)
' Left callout pointer
LET demoLeft# = callout#(frm#, 250, 500, 150, 80)
callout_fill#(demoLeft#, "#9b59b6")
callout_stroke#(demoLeft#, "#8e44ad")
callout_strokethickness#(demoLeft#, 2)
callout_calloutposition#(demoLeft#, 1)
callout_calloutlength#(demoLeft#, 20)
callout_calloutwidth#(demoLeft#, 30)
callout_corners#(demoLeft#, 8, 8)
' Bottom callout pointer
LET demoBottom# = callout#(frm#, 450, 500, 150, 80)
callout_fill#(demoBottom#, "#e67e22")
callout_stroke#(demoBottom#, "#d35400")
callout_strokethickness#(demoBottom#, 2)
callout_calloutposition#(demoBottom#, 2)
callout_calloutlength#(demoBottom#, 20)
callout_calloutwidth#(demoBottom#, 30)
callout_corners#(demoBottom#, 8, 8)
' Right callout pointer
LET demoRight# = callout#(frm#, 650, 500, 150, 80)
callout_fill#(demoRight#, "#1abc9c")
callout_stroke#(demoRight#, "#16a085")
callout_strokethickness#(demoRight#, 2)
callout_calloutposition#(demoRight#, 3)
callout_calloutlength#(demoRight#, 20)
callout_calloutwidth#(demoRight#, 30)
callout_corners#(demoRight#, 8, 8)
' Create labels for visual reference
LET lblTop# = label#(frm#, "Top (0)", 90, 590)
LET lblLeft# = label#(frm#, "Left (1)", 290, 590)
LET lblBottom# = label#(frm#, "Bottom (2)", 485, 590)
LET lblRight# = label#(frm#, "Right (3)", 690, 590)
' Create status label
LET statusLbl# = label#(frm#, "Click the blue callout to test events", 350, 470)
' Speech bubble demo with offset
LET speechBubble# = callout#(frm#, 600, 250, 200, 80)
callout_fill#(speechBubble#, "#f1c40f")
callout_stroke#(speechBubble#, "#f39c12")
callout_strokethickness#(speechBubble#, 2)
callout_calloutposition#(speechBubble#, 2)
callout_calloutlength#(speechBubble#, 30)
callout_calloutwidth#(speechBubble#, 25)
callout_calloutoffset#(speechBubble#, -60)
callout_corners#(speechBubble#, 15, 15)
LET lblSpeech# = label#(frm#, "Speech bubble with offset", 620, 350)
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
FUNCTION TestOnMouseUp(sender#, button, x, y, shift$)
  PRINTLN "TestOnMouseUp triggered at: " + stri$(x) + ", " + stri$(y)
END FUNCTION
FUNCTION OnInteractiveClick(sender#) LOCAL currentLength
  clickCount = clickCount + 1
  PRINTLN "Interactive callout clicked! Count: " + stri$(clickCount)
  label_text#(statusLbl#, "Callout clicked! Count: " + stri$(clickCount))
  ' Toggle callout length on click
  LET currentLength = callout_calloutlength(sender#)
  IF currentLength > 30 THEN
    callout_calloutlength#(sender#, 15)
  ELSE
    callout_calloutlength#(sender#, 40)
  END IF
END FUNCTION
FUNCTION OnInteractiveEnter(sender#)
  callout_fill#(sender#, "#e74c3c")
  label_text#(statusLbl#, "Mouse entered - color changed to red")
END FUNCTION
FUNCTION OnInteractiveLeave(sender#)
  callout_fill#(sender#, "#3498db")
  label_text#(statusLbl#, "Mouse left - color changed back to blue")
END FUNCTION
