' ============================================================================
' SpeedButtonLib Test Suite
' Tests all basic functions of the SpeedButton control library
' ============================================================================
PRINTLN "=============================================="
PRINTLN "SpeedButtonLib Test Suite"
PRINTLN "=============================================="
PRINTLN ""
LET testsPassed = 0
LET testsFailed = 0
' Helper function to report test results
FUNCTION AssertEqual(testName$, actual$, expected$)
  IF actual$ = expected$ THEN
    PRINTLN "[PASS] " + testName$
    LET testsPassed = testsPassed + 1
  ELSE
    PRINTLN "[FAIL] " + testName$
    PRINTLN "       Expected: " + expected$
    PRINTLN "       Actual:   " + actual$
    LET testsFailed = testsFailed + 1
  END IF
END FUNCTION
FUNCTION AssertEqualNum(testName$, actual, expected)
  IF actual = expected THEN
    PRINTLN "[PASS] " + testName$
    LET testsPassed = testsPassed + 1
  ELSE
    PRINTLN "[FAIL] " + testName$
    PRINTLN "       Expected: " + str$(expected)
    PRINTLN "       Actual:   " + str$(actual)
    LET testsFailed = testsFailed + 1
  END IF
END FUNCTION
FUNCTION AssertNotNil(testName$, ptr#)
  IF PntToNum(ptr#) <> 0 THEN
    PRINTLN "[PASS] " + testName$
    LET testsPassed = testsPassed + 1
  ELSE
    PRINTLN "[FAIL] " + testName$ + " (pointer is nil)"
    LET testsFailed = testsFailed + 1
  END IF
END FUNCTION
FUNCTION AssertRange(testName$, actual, minVal, maxVal)
  IF actual >= minVal THEN
    IF actual <= maxVal THEN
      PRINTLN "[PASS] " + testName$
      LET testsPassed = testsPassed + 1
    ELSE
      PRINTLN "[FAIL] " + testName$ + " (out of range)"
      LET testsFailed = testsFailed + 1
    END IF
  ELSE
    PRINTLN "[FAIL] " + testName$ + " (out of range)"
    LET testsFailed = testsFailed + 1
  END IF
END FUNCTION
' ============================================================================
' Test 1: Error Functions
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 1: Error Functions ---"
LET err = speedbutton_error()
AssertEqualNum("Initial error code", err, 0)
LET errMsg$ = speedbutton_errormsg$()
AssertEqual("Initial error message", errMsg$, "")
LET errStr$ = speedbutton_strerror$(0)
AssertEqual("Error string for code 0", errStr$, "No error")
LET errStr$ = speedbutton_strerror$(1)
AssertEqual("Error string for code 1", errStr$, "Invalid speed button")
LET errStr$ = speedbutton_strerror$(2)
AssertEqual("Error string for code 2", errStr$, "Invalid parent")
LET errStr$ = speedbutton_strerror$(99)
AssertEqual("Error string for unknown code", errStr$, "Unknown error")
speedbutton_clearerror()
LET err = speedbutton_error()
AssertEqualNum("Error cleared", err, 0)
' ============================================================================
' Test 2: Creation and Basic Properties
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 2: Creation and Basic Properties ---"
LET frm# = form#("SpeedButton Test", 800, 600)
AssertNotNil("Form created", frm#)
LET scrlbx# = scrollbox#(frm#)
' Test basic creation
LET sb1# = speedbutton#(scrlbx#)
AssertNotNil("SpeedButton created (default)", sb1#)
LET txt$ = speedbutton_text$(sb1#)
AssertEqual("Default text", txt$, "SpeedButton")
' Test creation with text
LET sb2# = speedbutton#(scrlbx#, "Test Button")
AssertNotNil("SpeedButton created (with text)", sb2#)
LET txt$ = speedbutton_text$(sb2#)
AssertEqual("Text from creation", txt$, "Test Button")
' Test creation with position and size
LET sb3# = speedbutton#(scrlbx#, 10, 50, 100, 30)
AssertNotNil("SpeedButton created (with pos/size)", sb3#)
LET x = speedbutton_x(sb3#)
AssertEqualNum("X position", x, 10)
LET y = speedbutton_y(sb3#)
AssertEqualNum("Y position", y, 50)
LET w = speedbutton_width(sb3#)
AssertEqualNum("Width", w, 100)
LET h = speedbutton_height(sb3#)
AssertEqualNum("Height", h, 30)
' Test full creation
LET sb4# = speedbutton#(scrlbx#, "Full Creation", 10, 90, 120, 35)
AssertNotNil("SpeedButton created (full)", sb4#)
LET txt$ = speedbutton_text$(sb4#)
AssertEqual("Text from full creation", txt$, "Full Creation")
' ============================================================================
' Test 3: Text Content
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 3: Text Content ---"
speedbutton_text#(sb1#, "New Text")
LET txt$ = speedbutton_text$(sb1#)
AssertEqual("Text set and get", txt$, "New Text")
speedbutton_text#(sb1#, "")
LET txt$ = speedbutton_text$(sb1#)
AssertEqual("Empty text", txt$, "")
speedbutton_text#(sb1#, "Special: áéíóú çã")
LET txt$ = speedbutton_text$(sb1#)
AssertEqual("Unicode text", txt$, "Special: áéíóú çã")
' ============================================================================
' Test 4: Font Properties
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 4: Font Properties ---"
speedbutton_fontfamily#(sb1#, "Arial")
LET family$ = speedbutton_fontfamily$(sb1#)
AssertEqual("Font family", family$, "Arial")
speedbutton_fontsize#(sb1#, 14)
LET size = speedbutton_fontsize(sb1#)
AssertEqualNum("Font size", size, 14)
speedbutton_bold#(sb1#, 1)
LET bold = speedbutton_bold(sb1#)
AssertEqualNum("Bold enabled", bold, 1)
speedbutton_bold#(sb1#, 0)
LET bold = speedbutton_bold(sb1#)
AssertEqualNum("Bold disabled", bold, 0)
speedbutton_italic#(sb1#, 1)
LET italic = speedbutton_italic(sb1#)
AssertEqualNum("Italic enabled", italic, 1)
speedbutton_underline#(sb1#, 1)
LET underline = speedbutton_underline(sb1#)
AssertEqualNum("Underline enabled", underline, 1)
speedbutton_strikeout#(sb1#, 1)
LET strikeout = speedbutton_strikeout(sb1#)
AssertEqualNum("Strikeout enabled", strikeout, 1)
speedbutton_fontcolor#(sb1#, "#FF0000")
LET color$ = speedbutton_fontcolor$(sb1#)
AssertEqual("Font color (red)", color$, "#FFFF0000")
' ============================================================================
' Test 5: SpeedButton-Specific Properties
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 5: SpeedButton-Specific Properties ---"
' GroupIndex
speedbutton_groupindex#(sb1#, 0)
LET gi = speedbutton_groupindex(sb1#)
AssertEqualNum("GroupIndex = 0", gi, 0)
speedbutton_groupindex#(sb1#, 5)
LET gi = speedbutton_groupindex(sb1#)
AssertEqualNum("GroupIndex = 5", gi, 5)
' StaysPressed
speedbutton_stayspressed#(sb1#, 0)
LET sp = speedbutton_stayspressed(sb1#)
AssertEqualNum("StaysPressed = 0", sp, 0)
speedbutton_stayspressed#(sb1#, 1)
LET sp = speedbutton_stayspressed(sb1#)
AssertEqualNum("StaysPressed = 1", sp, 1)
' Down (IsPressed)
speedbutton_down#(sb1#, 0)
LET dn = speedbutton_down(sb1#)
AssertEqualNum("Down = 0", dn, 0)
speedbutton_down#(sb1#, 1)
LET dn = speedbutton_down(sb1#)
AssertEqualNum("Down = 1", dn, 1)
' ============================================================================
' Test 6: Position and Size
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 6: Position and Size ---"
speedbutton_x#(sb1#, 50)
LET x = speedbutton_x(sb1#)
AssertEqualNum("X position set", x, 50)
speedbutton_y#(sb1#, 100)
LET y = speedbutton_y(sb1#)
AssertEqualNum("Y position set", y, 100)
speedbutton_width#(sb1#, 150)
LET w = speedbutton_width(sb1#)
AssertEqualNum("Width set", w, 150)
speedbutton_height#(sb1#, 40)
LET h = speedbutton_height(sb1#)
AssertEqualNum("Height set", h, 40)
speedbutton_move#(sb1#, 200, 150)
LET x = speedbutton_x(sb1#)
LET y = speedbutton_y(sb1#)
AssertEqualNum("Move X", x, 200)
AssertEqualNum("Move Y", y, 150)
speedbutton_size#(sb1#, 180, 45)
LET w = speedbutton_width(sb1#)
LET h = speedbutton_height(sb1#)
AssertEqualNum("Size W", w, 180)
AssertEqualNum("Size H", h, 45)
speedbutton_bounds#(sb1#, 10, 200, 200, 50)
LET x = speedbutton_x(sb1#)
LET y = speedbutton_y(sb1#)
LET w = speedbutton_width(sb1#)
LET h = speedbutton_height(sb1#)
AssertEqualNum("Bounds X", x, 10)
AssertEqualNum("Bounds Y", y, 200)
AssertEqualNum("Bounds W", w, 200)
AssertEqualNum("Bounds H", h, 50)
' ============================================================================
' Test 7: Visibility and State
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 7: Visibility and State ---"
speedbutton_visible#(sb1#, 1)
LET vis = speedbutton_visible(sb1#)
AssertEqualNum("Visible true", vis, 1)
speedbutton_visible#(sb1#, 0)
LET vis = speedbutton_visible(sb1#)
AssertEqualNum("Visible false", vis, 0)
speedbutton_visible#(sb1#, 1)
speedbutton_enabled#(sb1#, 1)
LET en = speedbutton_enabled(sb1#)
AssertEqualNum("Enabled true", en, 1)
speedbutton_enabled#(sb1#, 0)
LET en = speedbutton_enabled(sb1#)
AssertEqualNum("Enabled false", en, 0)
speedbutton_enabled#(sb1#, 1)
speedbutton_opacity#(sb1#, 0.5)
LET op = speedbutton_opacity(sb1#)
AssertRange("Opacity 0.5", op, 0.49, 0.51)
speedbutton_opacity#(sb1#, 1.0)
' ============================================================================
' Test 8: Tag
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 8: Tag ---"
speedbutton_tag#(sb1#, 0)
LET tag = speedbutton_tag(sb1#)
AssertEqualNum("Tag = 0", tag, 0)
speedbutton_tag#(sb1#, 12345)
LET tag = speedbutton_tag(sb1#)
AssertEqualNum("Tag = 12345", tag, 12345)
speedbutton_tag#(sb1#, -100)
LET tag = speedbutton_tag(sb1#)
AssertEqualNum("Tag = -100", tag, -100)
' ============================================================================
' Test 9: Alignment
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 9: Alignment ---"
speedbutton_align#(sb1#, 0)
LET al = speedbutton_align(sb1#)
AssertEqualNum("Align None", al, 0)
speedbutton_align#(sb1#, 1)
LET al = speedbutton_align(sb1#)
AssertEqualNum("Align Top", al, 1)
speedbutton_align#(sb1#, 2)
LET al = speedbutton_align(sb1#)
AssertEqualNum("Align Left", al, 2)
speedbutton_align#(sb1#, 0)
' ============================================================================
' Test 10: Margins
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 10: Margins ---"
speedbutton_marginleft#(sb1#, 5)
LET ml = speedbutton_marginleft(sb1#)
AssertEqualNum("Margin left", ml, 5)
speedbutton_margintop#(sb1#, 10)
LET mt = speedbutton_margintop(sb1#)
AssertEqualNum("Margin top", mt, 10)
speedbutton_marginright#(sb1#, 15)
LET mr = speedbutton_marginright(sb1#)
AssertEqualNum("Margin right", mr, 15)
speedbutton_marginbottom#(sb1#, 20)
LET mb = speedbutton_marginbottom(sb1#)
AssertEqualNum("Margin bottom", mb, 20)
speedbutton_margins#(sb1#, 1, 2, 3, 4)
LET ml = speedbutton_marginleft(sb1#)
LET mt = speedbutton_margintop(sb1#)
LET mr = speedbutton_marginright(sb1#)
LET mb = speedbutton_marginbottom(sb1#)
AssertEqualNum("Margins all - left", ml, 1)
AssertEqualNum("Margins all - top", mt, 2)
AssertEqualNum("Margins all - right", mr, 3)
AssertEqualNum("Margins all - bottom", mb, 4)
speedbutton_margin#(sb1#, 8)
LET ml = speedbutton_marginleft(sb1#)
LET mt = speedbutton_margintop(sb1#)
LET mr = speedbutton_marginright(sb1#)
LET mb = speedbutton_marginbottom(sb1#)
AssertEqualNum("Margin uniform - left", ml, 8)
AssertEqualNum("Margin uniform - top", mt, 8)
AssertEqualNum("Margin uniform - right", mr, 8)
AssertEqualNum("Margin uniform - bottom", mb, 8)
' ============================================================================
' Test 11: HitTest and DragMode
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 11: HitTest and DragMode ---"
speedbutton_hittest#(sb1#, 1)
LET ht = speedbutton_hittest(sb1#)
AssertEqualNum("HitTest enabled", ht, 1)
speedbutton_hittest#(sb1#, 0)
LET ht = speedbutton_hittest(sb1#)
AssertEqualNum("HitTest disabled", ht, 0)
speedbutton_hittest#(sb1#, 1)
speedbutton_dragmode#(sb1#, 0)
LET dm = speedbutton_dragmode(sb1#)
AssertEqualNum("DragMode manual", dm, 0)
speedbutton_dragmode#(sb1#, 1)
LET dm = speedbutton_dragmode(sb1#)
AssertEqualNum("DragMode automatic", dm, 1)
speedbutton_dragmode#(sb1#, 0)
' ============================================================================
' Test 12: Parent and Z-Order
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 12: Parent and Z-Order ---"
LET parent# = speedbutton_parent#(sb1#)
AssertNotNil("Get parent", parent#)
speedbutton_bringtofront#(sb1#)
PRINTLN "[PASS] BringToFront executed"
LET testsPassed = testsPassed + 1
speedbutton_sendtoback#(sb1#)
PRINTLN "[PASS] SendToBack executed"
LET testsPassed = testsPassed + 1
' ============================================================================
' Test 13: Event Callbacks
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 13: Event Callbacks ---"
speedbutton_onclick#(sb1#, "TestOnClick")
LET cb$ = speedbutton_onclick$(sb1#)
AssertEqual("OnClick callback set", cb$, "TestOnClick")
speedbutton_onclick#(sb1#, "")
LET cb$ = speedbutton_onclick$(sb1#)
AssertEqual("OnClick callback cleared", cb$, "")
speedbutton_onmousedown#(sb1#, "TestMouseDown")
LET cb$ = speedbutton_onmousedown$(sb1#)
AssertEqual("OnMouseDown callback set", cb$, "TestMouseDown")
speedbutton_onmouseup#(sb1#, "TestMouseUp")
LET cb$ = speedbutton_onmouseup$(sb1#)
AssertEqual("OnMouseUp callback set", cb$, "TestMouseUp")
speedbutton_onmousemove#(sb1#, "TestMouseMove")
LET cb$ = speedbutton_onmousemove$(sb1#)
AssertEqual("OnMouseMove callback set", cb$, "TestMouseMove")
speedbutton_onmouseenter#(sb1#, "TestMouseEnter")
LET cb$ = speedbutton_onmouseenter$(sb1#)
AssertEqual("OnMouseEnter callback set", cb$, "TestMouseEnter")
speedbutton_onmouseleave#(sb1#, "TestMouseLeave")
LET cb$ = speedbutton_onmouseleave$(sb1#)
AssertEqual("OnMouseLeave callback set", cb$, "TestMouseLeave")
speedbutton_onresize#(sb1#, "TestResize")
LET cb$ = speedbutton_onresize$(sb1#)
AssertEqual("OnResize callback set", cb$, "TestResize")
' Drag & Drop callbacks
speedbutton_ondragenter#(sb1#, "TestDragEnter")
LET cb$ = speedbutton_ondragenter$(sb1#)
AssertEqual("OnDragEnter callback set", cb$, "TestDragEnter")
speedbutton_ondragover#(sb1#, "TestDragOver")
LET cb$ = speedbutton_ondragover$(sb1#)
AssertEqual("OnDragOver callback set", cb$, "TestDragOver")
speedbutton_ondragdrop#(sb1#, "TestDragDrop")
LET cb$ = speedbutton_ondragdrop$(sb1#)
AssertEqual("OnDragDrop callback set", cb$, "TestDragDrop")
speedbutton_ondragleave#(sb1#, "TestDragLeave")
LET cb$ = speedbutton_ondragleave$(sb1#)
AssertEqual("OnDragLeave callback set", cb$, "TestDragLeave")
' Clear all callbacks
speedbutton_clearcallbacks#(sb1#)
LET cb$ = speedbutton_onclick$(sb1#)
AssertEqual("Callbacks cleared - onclick", cb$, "")
LET cb$ = speedbutton_onmousedown$(sb1#)
AssertEqual("Callbacks cleared - mousedown", cb$, "")
' ============================================================================
' Test 14: GroupIndex Storage Test
' NOTE: FMX TSpeedButton does NOT have automatic radio-button behavior.
' GroupIndex is a custom property for logical grouping only.
' Radio behavior must be implemented manually in your click handlers.
' ============================================================================
PRINTLN ""
PRINTLN "--- Test 14: GroupIndex Storage Test ---"
' Create buttons with same GroupIndex (logical grouping)
LET grpBtn1# = speedbutton#(scrlbx#, "Opt1")
speedbutton_move#(grpBtn1#, 10, 300)
speedbutton_size#(grpBtn1#, 60, 30)
speedbutton_groupindex#(grpBtn1#, 10)
speedbutton_stayspressed#(grpBtn1#, 1)
LET grpBtn2# = speedbutton#(scrlbx#, "Opt2")
speedbutton_move#(grpBtn2#, 75, 300)
speedbutton_size#(grpBtn2#, 60, 30)
speedbutton_groupindex#(grpBtn2#, 10)
speedbutton_stayspressed#(grpBtn2#, 1)
LET grpBtn3# = speedbutton#(scrlbx#, "Opt3")
speedbutton_move#(grpBtn3#, 140, 300)
speedbutton_size#(grpBtn3#, 60, 30)
speedbutton_groupindex#(grpBtn3#, 10)
speedbutton_stayspressed#(grpBtn3#, 1)
' Set first button as down
speedbutton_down#(grpBtn1#, 1)
LET d1 = speedbutton_down(grpBtn1#)
AssertEqualNum("GroupIndex btn1 down", d1, 1)
' Verify GroupIndex is stored correctly
LET gi1 = speedbutton_groupindex(grpBtn1#)
LET gi2 = speedbutton_groupindex(grpBtn2#)
AssertEqualNum("GroupIndex stored correctly", gi1, 10)
AssertEqualNum("GroupIndex same for group", gi2, 10)
PRINTLN "[INFO] GroupIndex is for logical grouping only"
PRINTLN "[INFO] Manual radio behavior required in click handlers"
' ============================================================================
' Summary
' ============================================================================
PRINTLN ""
PRINTLN "=============================================="
PRINTLN "Test Summary"
PRINTLN "=============================================="
PRINTLN "Tests Passed: " + str$(testsPassed)
PRINTLN "Tests Failed: " + str$(testsFailed)
PRINTLN "Total Tests:  " + str$(testsPassed + testsFailed)
PRINTLN ""
IF testsFailed = 0 THEN
  PRINTLN "All tests PASSED!"
ELSE
  PRINTLN "Some tests FAILED. Please review."
END IF
' Show the form to verify visuals
form_show(frm#)
PRINTLN ""
PRINTLN "Form displayed. Check visual appearance of buttons."
PRINTLN "Press Ctrl+C to exit."
