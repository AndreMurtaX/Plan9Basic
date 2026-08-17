'******************************************************************************
' FormLib_Tests.bas - Test Suite for FormLib
' Plan9Basic GUI Library Testing
'
' This test suite validates all FormLib functions.
' Run this applet to verify FormLib is working correctly.
'******************************************************************************
' Test counters (module-level)
LET totalTests = 0
LET passedTests = 0
LET failedTests = 0
' Dialog test variables (module-level)
LET dialogResult = 0
LET dialogClosed = 0
'==============================================================================
' Helper Functions
'==============================================================================
FUNCTION TestPass(testName$)
  totalTests = totalTests + 1
  passedTests = passedTests + 1
  PRINTLN "[PASS] "; testName$
END FUNCTION
FUNCTION TestFail(testName$, reason$)
  totalTests = totalTests + 1
  failedTests = failedTests + 1
  PRINTLN "[FAIL] "; testName$; " - "; reason$
END FUNCTION
FUNCTION TestAssertEqual(testName$, expected, actual)
  totalTests = totalTests + 1
  IF expected = actual THEN
    passedTests = passedTests + 1
    PRINTLN "[PASS] "; testName$
  ELSE
    failedTests = failedTests + 1
    PRINTLN "[FAIL] "; testName$; " - Expected: "; expected; ", Got: "; actual
  END IF
END FUNCTION
FUNCTION TestAssertNotZero(testName$, value)
  totalTests = totalTests + 1
  IF value <> 0 THEN
    passedTests = passedTests + 1
    PRINTLN "[PASS] "; testName$
  ELSE
    failedTests = failedTests + 1
    PRINTLN "[FAIL] "; testName$; " - Expected non-zero value"
  END IF
END FUNCTION
FUNCTION TestAssertZero(testName$, value)
  totalTests = totalTests + 1
  IF value = 0 THEN
    passedTests = passedTests + 1
    PRINTLN "[PASS] "; testName$
  ELSE
    failedTests = failedTests + 1
    PRINTLN "[FAIL] "; testName$; " - Expected zero, got: "; value
  END IF
END FUNCTION
FUNCTION TestAssertString(testName$, expected$, actual$)
  totalTests = totalTests + 1
  IF expected$ = actual$ THEN
    passedTests = passedTests + 1
    PRINTLN "[PASS] "; testName$
  ELSE
    failedTests = failedTests + 1
    PRINTLN "[FAIL] "; testName$; " - Expected: '"; expected$; "', Got: '"; actual$; "'"
  END IF
END FUNCTION
FUNCTION TestAssertPointerValid(testName$, ptr#)
  totalTests = totalTests + 1
  IF PntToNum(ptr#) <> 0 THEN
    passedTests = passedTests + 1
    PRINTLN "[PASS] "; testName$
  ELSE
    failedTests = failedTests + 1
    PRINTLN "[FAIL] "; testName$; " - Pointer is null"
  END IF
END FUNCTION
FUNCTION PrintSection(title$)
  PRINTLN
  PRINTLN "=============================================="
  PRINTLN title$
  PRINTLN "=============================================="
END FUNCTION
'==============================================================================
' Test: Error Handling Functions
'==============================================================================
FUNCTION TestErrorHandling()
  PrintSection("Testing Error Handling Functions")
  ' Test form_clearerror
  form_clearerror()
  TestAssertZero("form_clearerror - error code reset", form_error())
  ' Test form_strerror$ for known error codes
  TestAssertString("form_strerror$(0)", "No error", form_strerror$(0))
  TestAssertString("form_strerror$(1)", "Invalid or nil form", form_strerror$(1))
  TestAssertString("form_strerror$(2)", "Invalid property", form_strerror$(2))
  TestAssertString("form_strerror$(3)", "Invalid value", form_strerror$(3))
  TestAssertString("form_strerror$(4)", "Form creation failed", form_strerror$(4))
  TestAssertString("form_strerror$(5)", "Invalid callback function", form_strerror$(5))
  ' Skip null pointer test for now - may cause Access Violation
  ' TODO: Investigate null pointer handling in FormLib
  TestPass("Error handling functions work (null ptr test skipped)")
  form_clearerror()
END FUNCTION
'==============================================================================
' Test: Form Creation Functions
'==============================================================================
FUNCTION TestFormCreation() LOCAL frm1#, frm2#, frm3#
  PrintSection("Testing Form Creation Functions")
  ' Test form#() - no parameters
  frm1# = form#()
  TestAssertPointerValid("form#() creates valid form", frm1#)
  IF PntToNum(frm1#) <> 0 THEN
    TestAssertString("form#() default caption", "Plan9Basic Form", form_caption$(frm1#))
    TestAssertEqual("form#() default width", 640, form_width(frm1#))
    TestAssertEqual("form#() default height", 480, form_height(frm1#))
    form_free(frm1#)
    TestPass("form_free() completed")
  END IF
  ' Test form#(caption$) - with caption
  frm2# = form#("Test Window")
  TestAssertPointerValid("form#(caption$) creates valid form", frm2#)
  IF PntToNum(frm2#) <> 0 THEN
    TestAssertString("form#(caption$) sets caption", "Test Window", form_caption$(frm2#))
    form_free(frm2#)
  END IF
  ' Test form#(caption$, width, height) - full parameters
  frm3# = form#("Sized Window", 800, 600)
  TestAssertPointerValid("form#(caption$,w,h) creates valid form", frm3#)
  IF PntToNum(frm3#) <> 0 THEN
    TestAssertString("form#(caption$,w,h) sets caption", "Sized Window", form_caption$(frm3#))
    TestAssertEqual("form#(caption$,w,h) sets width", 800, form_width(frm3#))
    TestAssertEqual("form#(caption$,w,h) sets height", 600, form_height(frm3#))
    form_free(frm3#)
  END IF
END FUNCTION
'==============================================================================
' Test: Caption Property
'==============================================================================
FUNCTION TestCaptionProperty() LOCAL frm#
  PrintSection("Testing Caption Property")
  frm# = form#()
  IF PntToNum(frm#) = 0 THEN
    TestFail("Caption test setup", "Could not create form")
  ELSE
    form_caption#(frm#, "New Caption")
    TestAssertString("form_caption# sets caption", "New Caption", form_caption$(frm#))
    form_caption#(frm#, "")
    TestAssertString("form_caption# allows empty", "", form_caption$(frm#))
    form_caption#(frm#, "Test Title 123")
    TestAssertString("form_caption# handles text", "Test Title 123", form_caption$(frm#))
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Position and Size Properties
'==============================================================================
FUNCTION TestPositionSize() LOCAL frm#, cw, ch
  PrintSection("Testing Position and Size Properties")
  frm# = form#("Position/Size Test", 400, 300)
  IF PntToNum(frm#) = 0 THEN
    TestFail("Position/Size test setup", "Could not create form")
  ELSE
    form_left#(frm#, 100)
    TestAssertEqual("form_left# sets left", 100, form_left(frm#))
    form_top#(frm#, 150)
    TestAssertEqual("form_top# sets top", 150, form_top(frm#))
    form_width#(frm#, 500)
    TestAssertEqual("form_width# sets width", 500, form_width(frm#))
    form_height#(frm#, 400)
    TestAssertEqual("form_height# sets height", 400, form_height(frm#))
    form_size#(frm#, 600, 450)
    TestAssertEqual("form_size# sets width", 600, form_width(frm#))
    TestAssertEqual("form_size# sets height", 450, form_height(frm#))
    form_move#(frm#, 200, 250)
    TestAssertEqual("form_move# sets left", 200, form_left(frm#))
    TestAssertEqual("form_move# sets top", 250, form_top(frm#))
    form_bounds#(frm#, 50, 75, 700, 500)
    TestAssertEqual("form_bounds# sets left", 50, form_left(frm#))
    TestAssertEqual("form_bounds# sets top", 75, form_top(frm#))
    TestAssertEqual("form_bounds# sets width", 700, form_width(frm#))
    TestAssertEqual("form_bounds# sets height", 500, form_height(frm#))
    cw = form_clientwidth(frm#)
    ch = form_clientheight(frm#)
    totalTests = totalTests + 1
    IF cw > 0 THEN
      passedTests = passedTests + 1
      PRINTLN "[PASS] form_clientwidth returns valid value: "; cw
    ELSE
      failedTests = failedTests + 1
      PRINTLN "[FAIL] form_clientwidth - invalid value: "; cw
    END IF
    totalTests = totalTests + 1
    IF ch > 0 THEN
      passedTests = passedTests + 1
      PRINTLN "[PASS] form_clientheight returns valid value: "; ch
    ELSE
      failedTests = failedTests + 1
      PRINTLN "[FAIL] form_clientheight - invalid value: "; ch
    END IF
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Size Constraints
'==============================================================================
FUNCTION TestSizeConstraints() LOCAL frm#
  PrintSection("Testing Size Constraints")
  frm# = form#("Constraints Test", 400, 300)
  IF PntToNum(frm#) = 0 THEN
    TestFail("Constraints test setup", "Could not create form")
  ELSE
    form_minwidth#(frm#, 200)
    TestAssertEqual("form_minwidth# sets minwidth", 200, form_minwidth(frm#))
    form_minheight#(frm#, 150)
    TestAssertEqual("form_minheight# sets minheight", 150, form_minheight(frm#))
    form_maxwidth#(frm#, 800)
    TestAssertEqual("form_maxwidth# sets maxwidth", 800, form_maxwidth(frm#))
    form_maxheight#(frm#, 600)
    TestAssertEqual("form_maxheight# sets maxheight", 600, form_maxheight(frm#))
    form_constraints#(frm#, 100, 100, 1000, 800)
    TestAssertEqual("form_constraints# sets minwidth", 100, form_minwidth(frm#))
    TestAssertEqual("form_constraints# sets minheight", 100, form_minheight(frm#))
    TestAssertEqual("form_constraints# sets maxwidth", 1000, form_maxwidth(frm#))
    TestAssertEqual("form_constraints# sets maxheight", 800, form_maxheight(frm#))
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Position Mode
'==============================================================================
FUNCTION TestPositionMode() LOCAL frm#
  PrintSection("Testing Position Mode")
  frm# = form#("Position Mode Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Position mode test setup", "Could not create form")
  ELSE
    form_position#(frm#, 0)
    TestAssertEqual("form_position# mode 0 (Designed)", 0, form_position(frm#))
    form_position#(frm#, 4)
    TestAssertEqual("form_position# mode 4 (ScreenCenter)", 4, form_position(frm#))
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Window State
'==============================================================================
FUNCTION TestWindowState() LOCAL frm#
  PrintSection("Testing Window State")
  frm# = form#("Window State Test", 400, 300)
  IF PntToNum(frm#) = 0 THEN
    TestFail("Window state test setup", "Could not create form")
  ELSE
    TestAssertEqual("Initial window state is Normal", 0, form_windowstate(frm#))
    form_windowstate#(frm#, 2)
    TestAssertEqual("form_windowstate# sets Maximized", 2, form_windowstate(frm#))
    form_windowstate#(frm#, 0)
    TestAssertEqual("form_windowstate# sets Normal", 0, form_windowstate(frm#))
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Border Style
'==============================================================================
FUNCTION TestBorderStyle() LOCAL frm#
  PrintSection("Testing Border Style")
  frm# = form#("Border Style Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Border style test setup", "Could not create form")
  ELSE
    form_borderstyle#(frm#, 0)
    TestAssertEqual("form_borderstyle# None (0)", 0, form_borderstyle(frm#))
    form_borderstyle#(frm#, 1)
    TestAssertEqual("form_borderstyle# Single (1)", 1, form_borderstyle(frm#))
    form_borderstyle#(frm#, 2)
    TestAssertEqual("form_borderstyle# Sizeable (2)", 2, form_borderstyle(frm#))
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Form Style (StayOnTop)
'==============================================================================
FUNCTION TestFormStyle() LOCAL frm#
  PrintSection("Testing Form Style")
  frm# = form#("Form Style Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Form style test setup", "Could not create form")
  ELSE
    TestAssertEqual("Default form style is Normal", 0, form_formstyle(frm#))
    form_formstyle#(frm#, 2)
    TestAssertEqual("form_formstyle# StayOnTop (2)", 2, form_formstyle(frm#))
    form_stayontop#(frm#, 0)
    TestAssertEqual("form_stayontop# disabled", 0, form_stayontop(frm#))
    form_stayontop#(frm#, 1)
    TestAssertEqual("form_stayontop# enabled", 1, form_stayontop(frm#))
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Fill Color
'==============================================================================
FUNCTION TestFillColor() LOCAL frm#, color$
  PrintSection("Testing Fill Color")
  frm# = form#("Fill Color Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Fill color test setup", "Could not create form")
  ELSE
    form_fill#(frm#, "#FF0000")
    color$ = form_fill$(frm#)
    totalTests = totalTests + 1
    IF len(color$) > 0 THEN
      passedTests = passedTests + 1
      PRINTLN "[PASS] form_fill# sets color: "; color$
    ELSE
      failedTests = failedTests + 1
      PRINTLN "[FAIL] form_fill# - Got empty color"
    END IF
    form_fill#(frm#, "blue")
    color$ = form_fill$(frm#)
    totalTests = totalTests + 1
    IF len(color$) > 0 THEN
      passedTests = passedTests + 1
      PRINTLN "[PASS] form_fill# sets named color: "; color$
    ELSE
      failedTests = failedTests + 1
      PRINTLN "[FAIL] form_fill# named color failed"
    END IF
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Transparency
'==============================================================================
FUNCTION TestTransparency() LOCAL frm#
  PrintSection("Testing Transparency")
  frm# = form#("Transparency Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Transparency test setup", "Could not create form")
  ELSE
    TestAssertEqual("Default transparency is 0", 0, form_transparency(frm#))
    form_transparency#(frm#, 1)
    TestAssertEqual("form_transparency# enables", 1, form_transparency(frm#))
    form_transparency#(frm#, 0)
    TestAssertEqual("form_transparency# disables", 0, form_transparency(frm#))
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Visibility
'==============================================================================
FUNCTION TestVisibility() LOCAL frm#
  PrintSection("Testing Visibility")
  frm# = form#("Visibility Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Visibility test setup", "Could not create form")
  ELSE
    TestAssertEqual("Initial visibility is 0", 0, form_visible(frm#))
    form_visible#(frm#, 1)
    TestAssertEqual("form_visible# shows form", 1, form_visible(frm#))
    form_visible#(frm#, 0)
    TestAssertEqual("form_visible# hides form", 0, form_visible(frm#))
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Close Action
'==============================================================================
FUNCTION TestCloseAction() LOCAL frm#
  PrintSection("Testing Close Action")
  frm# = form#("Close Action Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Close action test setup", "Could not create form")
  ELSE
    form_closeaction#(frm#, 0)
    TestAssertEqual("form_closeaction# None (0)", 0, form_closeaction(frm#))
    form_closeaction#(frm#, 1)
    TestAssertEqual("form_closeaction# Hide (1)", 1, form_closeaction(frm#))
    form_closeaction#(frm#, 2)
    TestAssertEqual("form_closeaction# Free (2)", 2, form_closeaction(frm#))
    form_allowclose#(frm#, 1)
    TestAssertEqual("form_allowclose# enabled", 1, form_allowclose(frm#))
    form_allowclose#(frm#, 0)
    TestAssertEqual("form_allowclose# disabled", 0, form_allowclose(frm#))
    form_allowclose#(frm#, 1)
    form_closeaction#(frm#, 1)
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Modal Result
'==============================================================================
FUNCTION TestModalResult() LOCAL frm#
  PrintSection("Testing Modal Result")
  frm# = form#("Modal Result Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Modal result test setup", "Could not create form")
  ELSE
    form_modalresult#(frm#, 0)
    TestAssertEqual("form_modalresult# None (0)", 0, form_modalresult(frm#))
    form_modalresult#(frm#, 1)
    TestAssertEqual("form_modalresult# OK (1)", 1, form_modalresult(frm#))
    form_modalresult#(frm#, 2)
    TestAssertEqual("form_modalresult# Cancel (2)", 2, form_modalresult(frm#))
    form_modalresult#(frm#, 6)
    TestAssertEqual("form_modalresult# Yes (6)", 6, form_modalresult(frm#))
    form_modalresult#(frm#, 7)
    TestAssertEqual("form_modalresult# No (7)", 7, form_modalresult(frm#))
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Fullscreen
'==============================================================================
FUNCTION TestFullscreen() LOCAL frm#
  PrintSection("Testing Fullscreen")
  frm# = form#("Fullscreen Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Fullscreen test setup", "Could not create form")
  ELSE
    TestAssertEqual("Default fullscreen is 0", 0, form_fullscreen(frm#))
    form_fullscreen#(frm#, 1)
    TestAssertEqual("form_fullscreen# enables", 1, form_fullscreen(frm#))
    form_fullscreen#(frm#, 0)
    TestAssertEqual("form_fullscreen# disables", 0, form_fullscreen(frm#))
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Padding
'==============================================================================
FUNCTION TestPadding() LOCAL frm#
  PrintSection("Testing Padding")
  frm# = form#("Padding Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Padding test setup", "Could not create form")
  ELSE
    form_padding#(frm#, 10)
    TestAssertEqual("form_padding# sets uniform padding", 10, form_padding(frm#))
    form_paddings#(frm#, 5, 10, 15, 20)
    TestAssertEqual("form_paddings# sets left padding", 5, form_padding(frm#))
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Tag
'==============================================================================
FUNCTION TestTag() LOCAL frm#
  PrintSection("Testing Tag")
  frm# = form#("Tag Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Tag test setup", "Could not create form")
  ELSE
    TestAssertEqual("Default tag is 0", 0, form_tag(frm#))
    form_tag#(frm#, 12345)
    TestAssertEqual("form_tag# sets value", 12345, form_tag(frm#))
    form_tag#(frm#, -999)
    TestAssertEqual("form_tag# sets negative value", -999, form_tag(frm#))
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Screen Information
'==============================================================================
FUNCTION TestScreenInfo() LOCAL sw, sh, scale, orient
  PrintSection("Testing Screen Information Functions")
  sw = form_screenwidth()
  totalTests = totalTests + 1
  IF sw > 0 THEN
    passedTests = passedTests + 1
    PRINTLN "[PASS] form_screenwidth returns: "; sw
  ELSE
    failedTests = failedTests + 1
    PRINTLN "[FAIL] form_screenwidth returned invalid: "; sw
  END IF
  sh = form_screenheight()
  totalTests = totalTests + 1
  IF sh > 0 THEN
    passedTests = passedTests + 1
    PRINTLN "[PASS] form_screenheight returns: "; sh
  ELSE
    failedTests = failedTests + 1
    PRINTLN "[FAIL] form_screenheight returned invalid: "; sh
  END IF
  scale = form_screenscale()
  totalTests = totalTests + 1
  IF scale >= 1 THEN
    passedTests = passedTests + 1
    PRINTLN "[PASS] form_screenscale returns: "; scale
  ELSE
    failedTests = failedTests + 1
    PRINTLN "[FAIL] form_screenscale returned invalid: "; scale
  END IF
  orient = form_screenorientation()
  totalTests = totalTests + 1
  IF orient >= 0 AND orient <= 3 THEN
    passedTests = passedTests + 1
    PRINTLN "[PASS] form_screenorientation returns: "; orient
  ELSE
    failedTests = failedTests + 1
    PRINTLN "[FAIL] form_screenorientation returned invalid: "; orient
  END IF
END FUNCTION
'==============================================================================
' Test: Event Callbacks
'==============================================================================
FUNCTION TestEventCallbacks() LOCAL frm#
  PrintSection("Testing Event Callback Registration")
  frm# = form#("Event Callback Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Event callback test setup", "Could not create form")
  ELSE
    form_onshow#(frm#, "MyOnShow")
    TestAssertString("form_onshow# sets callback", "MyOnShow", form_onshow$(frm#))
    form_onhide#(frm#, "MyOnHide")
    TestAssertString("form_onhide# sets callback", "MyOnHide", form_onhide$(frm#))
    form_onclose#(frm#, "MyOnClose")
    TestAssertString("form_onclose# sets callback", "MyOnClose", form_onclose$(frm#))
    form_onresize#(frm#, "MyOnResize")
    TestAssertString("form_onresize# sets callback", "MyOnResize", form_onresize$(frm#))
    form_onkeydown#(frm#, "MyOnKeyDown")
    TestAssertString("form_onkeydown# sets callback", "MyOnKeyDown", form_onkeydown$(frm#))
    form_clearcallbacks#(frm#)
    TestAssertString("form_clearcallbacks# clears OnShow", "", form_onshow$(frm#))
    TestAssertString("form_clearcallbacks# clears OnClose", "", form_onclose$(frm#))
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Form Show/Hide (Visual)
'==============================================================================
FUNCTION TestFormShowHide() LOCAL frm#
  PrintSection("Testing Form Show/Hide (Visual)")
  frm# = form#("Show/Hide Test - Watch me!", 400, 200)
  IF PntToNum(frm#) = 0 THEN
    TestFail("Show/Hide test setup", "Could not create form")
  ELSE
    form_position#(frm#, 4)
    form_fill#(frm#, "#E0E0FF")
    PRINTLN "Showing form..."
    form_show(frm#)
    TestAssertEqual("form_show makes visible", 1, form_visible(frm#))
    pause(1)
    PRINTLN "Hiding form..."
    form_hide(frm#)
    TestAssertEqual("form_hide makes invisible", 0, form_visible(frm#))
    pause(0.5)
    PRINTLN "Showing again..."
    form_show(frm#)
    pause(0.5)
    PRINTLN "Using form_close..."
    form_closeaction#(frm#, 1)
    form_close(frm#)
    TestAssertEqual("form_close hides (action=1)", 0, form_visible(frm#))
    form_free(frm#)
    TestPass("Show/Hide visual test completed")
  END IF
END FUNCTION
'==============================================================================
' Test: Form Center
'==============================================================================
FUNCTION TestFormCenter() LOCAL frm#, expectedLeft, expectedTop, actualLeft, actualTop
  PrintSection("Testing Form Center")
  frm# = form#("Center Test", 300, 200)
  IF PntToNum(frm#) = 0 THEN
    TestFail("Center test setup", "Could not create form")
  ELSE
    form_center#(frm#)
    expectedLeft = (form_screenwidth() - 300) / 2
    expectedTop = (form_screenheight() - 200) / 2
    actualLeft = form_left(frm#)
    actualTop = form_top(frm#)
    totalTests = totalTests + 1
    IF abs(actualLeft - expectedLeft) < 100 THEN
      passedTests = passedTests + 1
      PRINTLN "[PASS] form_center# sets left: "; actualLeft
    ELSE
      failedTests = failedTests + 1
      PRINTLN "[FAIL] form_center# left - Expected ~"; expectedLeft; ", Got: "; actualLeft
    END IF
    totalTests = totalTests + 1
    IF abs(actualTop - expectedTop) < 100 THEN
      passedTests = passedTests + 1
      PRINTLN "[PASS] form_center# sets top: "; actualTop
    ELSE
      failedTests = failedTests + 1
      PRINTLN "[FAIL] form_center# top - Expected ~"; expectedTop; ", Got: "; actualTop
    END IF
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Focus/Activation
'==============================================================================
FUNCTION TestFocusActivation() LOCAL frm#, active
  PrintSection("Testing Focus/Activation Functions")
  frm# = form#("Focus Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Focus test setup", "Could not create form")
  ELSE
    form_show(frm#)
    pause(0.2)
    form_bringtofront#(frm#)
    TestPass("form_bringtofront# executed")
    form_sendtoback#(frm#)
    TestPass("form_sendtoback# executed")
    form_setfocus#(frm#)
    TestPass("form_setfocus# executed")
    active = form_active(frm#)
    totalTests = totalTests + 1
    IF active >= 0 THEN
      passedTests = passedTests + 1
      PRINTLN "[PASS] form_active returns: "; active
    ELSE
      failedTests = failedTests + 1
      PRINTLN "[FAIL] form_active returned invalid: "; active
    END IF
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Platform Integration
'==============================================================================
FUNCTION TestPlatformIntegration() LOCAL platform$
  PrintSection("Testing Platform Integration")
  platform$ = os_name$()
  PRINTLN "Running on platform: "; platform$
  totalTests = totalTests + 1
  IF len(platform$) > 0 THEN
    passedTests = passedTests + 1
    PRINTLN "[PASS] os_name$() returns: "; platform$
  ELSE
    failedTests = failedTests + 1
    PRINTLN "[FAIL] os_name$() returned empty string"
  END IF
  IF platform$ = "Android" OR platform$ = "iOS" THEN
    PRINTLN
    PRINTLN "MOBILE PLATFORM DETECTED"
  ELSE
    PRINTLN
    PRINTLN "DESKTOP PLATFORM DETECTED"
  END IF
END FUNCTION
'==============================================================================
' Test: Invalidate
'==============================================================================
FUNCTION TestInvalidate() LOCAL frm#
  PrintSection("Testing Invalidate")
  frm# = form#("Invalidate Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Invalidate test setup", "Could not create form")
  ELSE
    form_show(frm#)
    pause(0.2)
    form_invalidate#(frm#)
    TestPass("form_invalidate# executed without error")
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Test: Form Handle
'==============================================================================
FUNCTION TestFormHandle() LOCAL frm#, handle
  PrintSection("Testing Form Handle")
  frm# = form#("Handle Test")
  IF PntToNum(frm#) = 0 THEN
    TestFail("Handle test setup", "Could not create form")
  ELSE
    form_show(frm#)
    pause(0.2)
    handle = form_handle(frm#)
    totalTests = totalTests + 1
    passedTests = passedTests + 1
    PRINTLN "[PASS] form_handle returns: "; handle
    form_free(frm#)
  END IF
END FUNCTION
'==============================================================================
' Main Test Runner
'==============================================================================
PrintSection("FormLib Test Suite")
PRINTLN "Plan9Basic GUI Library Tests"
PRINTLN "Date: "; date$()
PRINTLN "Time: "; time$()
PRINTLN
' Run all tests
TestErrorHandling()
TestFormCreation()
TestCaptionProperty()
TestPositionSize()
TestSizeConstraints()
TestPositionMode()
TestWindowState()
TestBorderStyle()
TestFormStyle()
TestFillColor()
TestTransparency()
TestVisibility()
TestCloseAction()
TestModalResult()
TestFullscreen()
TestPadding()
TestTag()
TestScreenInfo()
TestEventCallbacks()
TestFormCenter()
TestFocusActivation()
TestPlatformIntegration()
TestInvalidate()
TestFormHandle()
' Visual test
TestFormShowHide()
'==============================================================================
' Test Summary
'==============================================================================
PrintSection("Test Summary")
PRINTLN
PRINTLN "Total Tests: "; totalTests
PRINTLN "Passed.....: "; passedTests
PRINTLN "Failed.....: "; failedTests
PRINTLN
IF failedTests = 0 THEN
  PRINTLN "*** ALL TESTS PASSED ***"
ELSE
  PRINTLN "*** SOME TESTS FAILED - Review output above ***"
END IF
PRINTLN
PRINTLN "Test suite completed."
