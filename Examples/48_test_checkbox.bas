' =============================================================================
' test_checkbox.bas - Test Suite for CheckBoxLib
' =============================================================================
' For curiosity's sake...
' This example was created before the development and addition of debug
' commands to the Plan9Basic language and environment.
' That's why the ASRT function (which was originally ASSERT) was created here.
' =============================================================================
LET testsPassed = 0
LET testsFailed = 0
LET frm# = Pointer#(0)
PRINTLN "=== CheckBox Library Test Suite ==="
PRINTLN ""
frm# = form#("CheckBox Test Form", 500, 400)
TestCheckBoxCreation()
TestCheckBoxState()
TestCheckBoxText()
TestCheckBoxProperties()
TestCheckBoxFont()
TestCheckBoxPosition()
TestCheckBoxAlignment()
TestCheckBoxMargins()
TestCheckBoxVisibility()
TestCheckBoxFocus()
TestCheckBoxEvents()
TestCheckBoxDragDrop()
TestErrorHandling()
PRINTLN ""
PRINTLN "=== Test Results ==="
PRINTLN "Passed: " + str$(testsPassed)
PRINTLN "Failed: " + str$(testsFailed)
PRINTLN "Total:  " + str$(testsPassed + testsFailed)
form_close(frm#)
FUNCTION ASRT(condition, testName$)
  IF condition = 1 THEN
    PRINTLN "[PASS] " + testName$
    testsPassed = testsPassed + 1
  ELSE
    PRINTLN "[FAIL] " + testName$
    testsFailed = testsFailed + 1
  END IF
END FUNCTION
FUNCTION TestCheckBoxCreation() LOCAL chk#, chk2#, chk3#, chk4#
  PRINTLN ""
  PRINTLN "--- CheckBox Creation Tests ---"
  ' Basic creation
  chk# = checkbox#(frm#)
  IF PntToNum(chk#) <> 0 THEN
    ASRT(1, "CheckBox basic creation")
  ELSE
    ASRT(0, "CheckBox basic creation")
  END IF
  ' Creation with text
  chk2# = checkbox#(frm#, "Test Label")
  IF PntToNum(chk2#) <> 0 THEN
    ASRT(1, "CheckBox creation with text")
  ELSE
    ASRT(0, "CheckBox creation with text")
  END IF
  IF checkbox_text$(chk2#) = "Test Label" THEN
    ASRT(1, "CheckBox text set on creation")
  ELSE
    ASRT(0, "CheckBox text set on creation")
  END IF
  ' Creation with position
  chk3# = checkbox#(frm#, 10, 20, 150, 25)
  IF PntToNum(chk3#) <> 0 THEN
    ASRT(1, "CheckBox with position/size")
  ELSE
    ASRT(0, "CheckBox with position/size")
  END IF
  IF checkbox_x(chk3#) = 10 THEN
    ASRT(1, "CheckBox initial X position")
  ELSE
    ASRT(0, "CheckBox initial X position")
  END IF
  IF checkbox_y(chk3#) = 20 THEN
    ASRT(1, "CheckBox initial Y position")
  ELSE
    ASRT(0, "CheckBox initial Y position")
  END IF
  IF checkbox_width(chk3#) = 150 THEN
    ASRT(1, "CheckBox initial width")
  ELSE
    ASRT(0, "CheckBox initial width")
  END IF
  IF checkbox_height(chk3#) = 25 THEN
    ASRT(1, "CheckBox initial height")
  ELSE
    ASRT(0, "CheckBox initial height")
  END IF
  ' Full creation
  chk4# = checkbox#(frm#, "Full Test", 50, 60, 200, 30)
  IF PntToNum(chk4#) <> 0 THEN
    ASRT(1, "CheckBox full creation")
  ELSE
    ASRT(0, "CheckBox full creation")
  END IF
  IF checkbox_text$(chk4#) = "Full Test" THEN
    ASRT(1, "CheckBox full creation text")
  ELSE
    ASRT(0, "CheckBox full creation text")
  END IF
  IF checkbox_x(chk4#) = 50 THEN
    ASRT(1, "CheckBox full creation X")
  ELSE
    ASRT(0, "CheckBox full creation X")
  END IF
  checkbox_free(chk#)
  checkbox_free(chk2#)
  checkbox_free(chk3#)
  checkbox_free(chk4#)
END FUNCTION
FUNCTION TestCheckBoxState() LOCAL chk#
  PRINTLN ""
  PRINTLN "--- CheckBox State Tests ---"
  chk# = checkbox#(frm#, "State Test")
  ' Default state should be unchecked
  IF checkbox_ischecked(chk#) = 0 THEN
    ASRT(1, "Default state is unchecked")
  ELSE
    ASRT(0, "Default state is unchecked")
  END IF
  ' Set to checked
  checkbox_ischecked#(chk#, 1)
  IF checkbox_ischecked(chk#) = 1 THEN
    ASRT(1, "Set checkbox to checked")
  ELSE
    ASRT(0, "Set checkbox to checked")
  END IF
  ' Set back to unchecked
  checkbox_ischecked#(chk#, 0)
  IF checkbox_ischecked(chk#) = 0 THEN
    ASRT(1, "Set checkbox to unchecked")
  ELSE
    ASRT(0, "Set checkbox to unchecked")
  END IF
  checkbox_free(chk#)
END FUNCTION
FUNCTION TestCheckBoxText() LOCAL chk#
  PRINTLN ""
  PRINTLN "--- CheckBox Text Tests ---"
  chk# = checkbox#(frm#)
  ' Set text
  checkbox_text#(chk#, "My Checkbox")
  IF checkbox_text$(chk#) = "My Checkbox" THEN
    ASRT(1, "Set/get checkbox text")
  ELSE
    ASRT(0, "Set/get checkbox text")
  END IF
  ' Change text
  checkbox_text#(chk#, "Changed Text")
  IF checkbox_text$(chk#) = "Changed Text" THEN
    ASRT(1, "Change checkbox text")
  ELSE
    ASRT(0, "Change checkbox text")
  END IF
  ' Empty text
  checkbox_text#(chk#, "")
  IF checkbox_text$(chk#) = "" THEN
    ASRT(1, "Empty checkbox text")
  ELSE
    ASRT(0, "Empty checkbox text")
  END IF
  checkbox_free(chk#)
END FUNCTION
FUNCTION TestCheckBoxProperties() LOCAL chk#
  PRINTLN ""
  PRINTLN "--- CheckBox Properties Tests ---"
  chk# = checkbox#(frm#)
  ' Tag
  checkbox_tag#(chk#, 42)
  IF checkbox_tag(chk#) = 42 THEN
    ASRT(1, "Set/get tag")
  ELSE
    ASRT(0, "Set/get tag")
  END IF
  ' HitTest
  checkbox_hittest#(chk#, 1)
  IF checkbox_hittest(chk#) = 1 THEN
    ASRT(1, "HitTest enabled")
  ELSE
    ASRT(0, "HitTest enabled")
  END IF
  checkbox_hittest#(chk#, 0)
  IF checkbox_hittest(chk#) = 0 THEN
    ASRT(1, "HitTest disabled")
  ELSE
    ASRT(0, "HitTest disabled")
  END IF
  ' DragMode
  checkbox_dragmode#(chk#, 1)
  IF checkbox_dragmode(chk#) = 1 THEN
    ASRT(1, "Set drag mode")
  ELSE
    ASRT(0, "Set drag mode")
  END IF
  checkbox_free(chk#)
END FUNCTION
FUNCTION TestCheckBoxFont() LOCAL chk#
  PRINTLN ""
  PRINTLN "--- CheckBox Font Tests ---"
  chk# = checkbox#(frm#, "Font Test")
  ' Font size
  checkbox_fontsize#(chk#, 14)
  IF checkbox_fontsize(chk#) = 14 THEN
    ASRT(1, "Set/get font size")
  ELSE
    ASRT(0, "Set/get font size")
  END IF
  ' Font family
  checkbox_fontfamily#(chk#, "Arial")
  IF checkbox_fontfamily$(chk#) = "Arial" THEN
    ASRT(1, "Set/get font family")
  ELSE
    ASRT(0, "Set/get font family")
  END IF
  ' Bold
  checkbox_bold#(chk#, 1)
  IF checkbox_bold(chk#) = 1 THEN
    ASRT(1, "Set bold")
  ELSE
    ASRT(0, "Set bold")
  END IF
  checkbox_bold#(chk#, 0)
  IF checkbox_bold(chk#) = 0 THEN
    ASRT(1, "Unset bold")
  ELSE
    ASRT(0, "Unset bold")
  END IF
  ' Italic
  checkbox_italic#(chk#, 1)
  IF checkbox_italic(chk#) = 1 THEN
    ASRT(1, "Set italic")
  ELSE
    ASRT(0, "Set italic")
  END IF
  checkbox_italic#(chk#, 0)
  IF checkbox_italic(chk#) = 0 THEN
    ASRT(1, "Unset italic")
  ELSE
    ASRT(0, "Unset italic")
  END IF
  ' Underline
  checkbox_underline#(chk#, 1)
  IF checkbox_underline(chk#) = 1 THEN
    ASRT(1, "Set underline")
  ELSE
    ASRT(0, "Set underline")
  END IF
  checkbox_underline#(chk#, 0)
  IF checkbox_underline(chk#) = 0 THEN
    ASRT(1, "Unset underline")
  ELSE
    ASRT(0, "Unset underline")
  END IF
  ' Strikeout
  checkbox_strikeout#(chk#, 1)
  IF checkbox_strikeout(chk#) = 1 THEN
    ASRT(1, "Set strikeout")
  ELSE
    ASRT(0, "Set strikeout")
  END IF
  checkbox_strikeout#(chk#, 0)
  IF checkbox_strikeout(chk#) = 0 THEN
    ASRT(1, "Unset strikeout")
  ELSE
    ASRT(0, "Unset strikeout")
  END IF
  checkbox_free(chk#)
END FUNCTION
FUNCTION TestCheckBoxPosition() LOCAL chk#
  PRINTLN ""
  PRINTLN "--- CheckBox Position Tests ---"
  chk# = checkbox#(frm#)
  ' Move
  checkbox_move#(chk#, 100, 150)
  IF checkbox_x(chk#) = 100 THEN
    ASRT(1, "Move X")
  ELSE
    ASRT(0, "Move X")
  END IF
  IF checkbox_y(chk#) = 150 THEN
    ASRT(1, "Move Y")
  ELSE
    ASRT(0, "Move Y")
  END IF
  ' Size
  checkbox_size#(chk#, 180, 28)
  IF checkbox_width(chk#) = 180 THEN
    ASRT(1, "Size width")
  ELSE
    ASRT(0, "Size width")
  END IF
  IF checkbox_height(chk#) = 28 THEN
    ASRT(1, "Size height")
  ELSE
    ASRT(0, "Size height")
  END IF
  ' Bounds
  checkbox_bounds#(chk#, 10, 20, 200, 30)
  IF checkbox_x(chk#) = 10 THEN
    ASRT(1, "Bounds X")
  ELSE
    ASRT(0, "Bounds X")
  END IF
  IF checkbox_y(chk#) = 20 THEN
    ASRT(1, "Bounds Y")
  ELSE
    ASRT(0, "Bounds Y")
  END IF
  IF checkbox_width(chk#) = 200 THEN
    ASRT(1, "Bounds width")
  ELSE
    ASRT(0, "Bounds width")
  END IF
  IF checkbox_height(chk#) = 30 THEN
    ASRT(1, "Bounds height")
  ELSE
    ASRT(0, "Bounds height")
  END IF
  ' Individual setters
  checkbox_x#(chk#, 50)
  IF checkbox_x(chk#) = 50 THEN
    ASRT(1, "Set X individually")
  ELSE
    ASRT(0, "Set X individually")
  END IF
  checkbox_y#(chk#, 60)
  IF checkbox_y(chk#) = 60 THEN
    ASRT(1, "Set Y individually")
  ELSE
    ASRT(0, "Set Y individually")
  END IF
  checkbox_width#(chk#, 150)
  IF checkbox_width(chk#) = 150 THEN
    ASRT(1, "Set width individually")
  ELSE
    ASRT(0, "Set width individually")
  END IF
  checkbox_height#(chk#, 25)
  IF checkbox_height(chk#) = 25 THEN
    ASRT(1, "Set height individually")
  ELSE
    ASRT(0, "Set height individually")
  END IF
  checkbox_free(chk#)
END FUNCTION
FUNCTION TestCheckBoxAlignment() LOCAL chk#
  PRINTLN ""
  PRINTLN "--- CheckBox Alignment Tests ---"
  chk# = checkbox#(frm#)
  ' Default alignment
  IF checkbox_align(chk#) = 0 THEN
    ASRT(1, "Default alignment is None")
  ELSE
    ASRT(0, "Default alignment is None")
  END IF
  ' Set Top alignment
  checkbox_align#(chk#, 1)
  IF checkbox_align(chk#) = 1 THEN
    ASRT(1, "Set Top alignment")
  ELSE
    ASRT(0, "Set Top alignment")
  END IF
  ' Set Left alignment
  checkbox_align#(chk#, 2)
  IF checkbox_align(chk#) = 2 THEN
    ASRT(1, "Set Left alignment")
  ELSE
    ASRT(0, "Set Left alignment")
  END IF
  ' Set None alignment
  checkbox_align#(chk#, 0)
  IF checkbox_align(chk#) = 0 THEN
    ASRT(1, "Reset to None alignment")
  ELSE
    ASRT(0, "Reset to None alignment")
  END IF
  checkbox_free(chk#)
END FUNCTION
FUNCTION TestCheckBoxMargins() LOCAL chk#
  PRINTLN ""
  PRINTLN "--- CheckBox Margins Tests ---"
  chk# = checkbox#(frm#)
  ' Set individual margins
  checkbox_marginleft#(chk#, 5)
  IF checkbox_marginleft(chk#) = 5 THEN
    ASRT(1, "Set margin left")
  ELSE
    ASRT(0, "Set margin left")
  END IF
  checkbox_margintop#(chk#, 10)
  IF checkbox_margintop(chk#) = 10 THEN
    ASRT(1, "Set margin top")
  ELSE
    ASRT(0, "Set margin top")
  END IF
  checkbox_marginright#(chk#, 15)
  IF checkbox_marginright(chk#) = 15 THEN
    ASRT(1, "Set margin right")
  ELSE
    ASRT(0, "Set margin right")
  END IF
  checkbox_marginbottom#(chk#, 20)
  IF checkbox_marginbottom(chk#) = 20 THEN
    ASRT(1, "Set margin bottom")
  ELSE
    ASRT(0, "Set margin bottom")
  END IF
  ' Set all margins
  checkbox_margins#(chk#, 1, 2, 3, 4)
  IF checkbox_marginleft(chk#) = 1 THEN
    ASRT(1, "Set all margins - left")
  ELSE
    ASRT(0, "Set all margins - left")
  END IF
  IF checkbox_margintop(chk#) = 2 THEN
    ASRT(1, "Set all margins - top")
  ELSE
    ASRT(0, "Set all margins - top")
  END IF
  IF checkbox_marginright(chk#) = 3 THEN
    ASRT(1, "Set all margins - right")
  ELSE
    ASRT(0, "Set all margins - right")
  END IF
  IF checkbox_marginbottom(chk#) = 4 THEN
    ASRT(1, "Set all margins - bottom")
  ELSE
    ASRT(0, "Set all margins - bottom")
  END IF
  ' Set uniform margin
  checkbox_margin#(chk#, 8)
  IF checkbox_marginleft(chk#) = 8 THEN
    ASRT(1, "Set uniform margin")
  ELSE
    ASRT(0, "Set uniform margin")
  END IF
  checkbox_free(chk#)
END FUNCTION
FUNCTION TestCheckBoxVisibility() LOCAL chk#
  PRINTLN ""
  PRINTLN "--- CheckBox Visibility Tests ---"
  chk# = checkbox#(frm#)
  ' Default visible
  IF checkbox_visible(chk#) = 1 THEN
    ASRT(1, "Default is visible")
  ELSE
    ASRT(0, "Default is visible")
  END IF
  ' Set invisible
  checkbox_visible#(chk#, 0)
  IF checkbox_visible(chk#) = 0 THEN
    ASRT(1, "Set invisible")
  ELSE
    ASRT(0, "Set invisible")
  END IF
  ' Set visible
  checkbox_visible#(chk#, 1)
  IF checkbox_visible(chk#) = 1 THEN
    ASRT(1, "Set visible")
  ELSE
    ASRT(0, "Set visible")
  END IF
  ' Enabled
  IF checkbox_enabled(chk#) = 1 THEN
    ASRT(1, "Default is enabled")
  ELSE
    ASRT(0, "Default is enabled")
  END IF
  checkbox_enabled#(chk#, 0)
  IF checkbox_enabled(chk#) = 0 THEN
    ASRT(1, "Set disabled")
  ELSE
    ASRT(0, "Set disabled")
  END IF
  checkbox_enabled#(chk#, 1)
  IF checkbox_enabled(chk#) = 1 THEN
    ASRT(1, "Set enabled")
  ELSE
    ASRT(0, "Set enabled")
  END IF
  ' Opacity
  checkbox_opacity#(chk#, 0.5)
  IF checkbox_opacity(chk#) >= 0.49 THEN
    IF checkbox_opacity(chk#) <= 0.51 THEN
      ASRT(1, "Set opacity")
    ELSE
      ASRT(0, "Set opacity")
    END IF
  ELSE
    ASRT(0, "Set opacity")
  END IF
  checkbox_opacity#(chk#, 1)
  checkbox_free(chk#)
END FUNCTION
FUNCTION TestCheckBoxFocus() LOCAL chk#
  PRINTLN ""
  PRINTLN "--- CheckBox Focus Tests ---"
  chk# = checkbox#(frm#)
  ' CanFocus
  IF checkbox_canfocus(chk#) = 1 THEN
    ASRT(1, "Default can focus")
  ELSE
    ASRT(0, "Default can focus")
  END IF
  checkbox_canfocus#(chk#, 0)
  IF checkbox_canfocus(chk#) = 0 THEN
    ASRT(1, "Disable can focus")
  ELSE
    ASRT(0, "Disable can focus")
  END IF
  checkbox_canfocus#(chk#, 1)
  IF checkbox_canfocus(chk#) = 1 THEN
    ASRT(1, "Enable can focus")
  ELSE
    ASRT(0, "Enable can focus")
  END IF
  ' TabOrder
  checkbox_taborder#(chk#, 5)
  IF checkbox_taborder(chk#) = 5 THEN
    ASRT(1, "Set tab order")
  ELSE
    ASRT(0, "Set tab order")
  END IF
  checkbox_free(chk#)
END FUNCTION
FUNCTION TestCheckBoxEvents() LOCAL chk#
  PRINTLN ""
  PRINTLN "--- CheckBox Events Tests ---"
  chk# = checkbox#(frm#)
  ' OnChange
  checkbox_onchange#(chk#, "TestOnChange")
  IF checkbox_onchange$(chk#) = "TestOnChange" THEN
    ASRT(1, "Set OnChange callback")
  ELSE
    ASRT(0, "Set OnChange callback")
  END IF
  ' OnClick
  checkbox_onclick#(chk#, "TestOnClick")
  IF checkbox_onclick$(chk#) = "TestOnClick" THEN
    ASRT(1, "Set OnClick callback")
  ELSE
    ASRT(0, "Set OnClick callback")
  END IF
  ' OnDblClick
  checkbox_ondblclick#(chk#, "TestOnDblClick")
  IF checkbox_ondblclick$(chk#) = "TestOnDblClick" THEN
    ASRT(1, "Set OnDblClick callback")
  ELSE
    ASRT(0, "Set OnDblClick callback")
  END IF
  ' OnEnter
  checkbox_onenter#(chk#, "TestOnEnter")
  IF checkbox_onenter$(chk#) = "TestOnEnter" THEN
    ASRT(1, "Set OnEnter callback")
  ELSE
    ASRT(0, "Set OnEnter callback")
  END IF
  ' OnExit
  checkbox_onexit#(chk#, "TestOnExit")
  IF checkbox_onexit$(chk#) = "TestOnExit" THEN
    ASRT(1, "Set OnExit callback")
  ELSE
    ASRT(0, "Set OnExit callback")
  END IF
  ' OnKeyDown
  checkbox_onkeydown#(chk#, "TestOnKeyDown")
  IF checkbox_onkeydown$(chk#) = "TestOnKeyDown" THEN
    ASRT(1, "Set OnKeyDown callback")
  ELSE
    ASRT(0, "Set OnKeyDown callback")
  END IF
  ' OnKeyUp
  checkbox_onkeyup#(chk#, "TestOnKeyUp")
  IF checkbox_onkeyup$(chk#) = "TestOnKeyUp" THEN
    ASRT(1, "Set OnKeyUp callback")
  ELSE
    ASRT(0, "Set OnKeyUp callback")
  END IF
  ' OnMouseDown
  checkbox_onmousedown#(chk#, "TestOnMouseDown")
  IF checkbox_onmousedown$(chk#) = "TestOnMouseDown" THEN
    ASRT(1, "Set OnMouseDown callback")
  ELSE
    ASRT(0, "Set OnMouseDown callback")
  END IF
  ' OnMouseUp
  checkbox_onmouseup#(chk#, "TestOnMouseUp")
  IF checkbox_onmouseup$(chk#) = "TestOnMouseUp" THEN
    ASRT(1, "Set OnMouseUp callback")
  ELSE
    ASRT(0, "Set OnMouseUp callback")
  END IF
  ' OnMouseMove
  checkbox_onmousemove#(chk#, "TestOnMouseMove")
  IF checkbox_onmousemove$(chk#) = "TestOnMouseMove" THEN
    ASRT(1, "Set OnMouseMove callback")
  ELSE
    ASRT(0, "Set OnMouseMove callback")
  END IF
  ' OnMouseEnter
  checkbox_onmouseenter#(chk#, "TestOnMouseEnter")
  IF checkbox_onmouseenter$(chk#) = "TestOnMouseEnter" THEN
    ASRT(1, "Set OnMouseEnter callback")
  ELSE
    ASRT(0, "Set OnMouseEnter callback")
  END IF
  ' OnMouseLeave
  checkbox_onmouseleave#(chk#, "TestOnMouseLeave")
  IF checkbox_onmouseleave$(chk#) = "TestOnMouseLeave" THEN
    ASRT(1, "Set OnMouseLeave callback")
  ELSE
    ASRT(0, "Set OnMouseLeave callback")
  END IF
  ' OnResize
  checkbox_onresize#(chk#, "TestOnResize")
  IF checkbox_onresize$(chk#) = "TestOnResize" THEN
    ASRT(1, "Set OnResize callback")
  ELSE
    ASRT(0, "Set OnResize callback")
  END IF
  ' Clear callbacks
  checkbox_clearcallbacks#(chk#)
  IF checkbox_onchange$(chk#) = "" THEN
    ASRT(1, "Clear callbacks")
  ELSE
    ASRT(0, "Clear callbacks")
  END IF
  checkbox_free(chk#)
END FUNCTION
FUNCTION TestCheckBoxDragDrop() LOCAL chk#
  PRINTLN ""
  PRINTLN "--- CheckBox Drag & Drop Tests ---"
  chk# = checkbox#(frm#)
  ' OnDragEnter
  checkbox_ondragenter#(chk#, "TestOnDragEnter")
  IF checkbox_ondragenter$(chk#) = "TestOnDragEnter" THEN
    ASRT(1, "Set OnDragEnter callback")
  ELSE
    ASRT(0, "Set OnDragEnter callback")
  END IF
  ' OnDragOver
  checkbox_ondragover#(chk#, "TestOnDragOver")
  IF checkbox_ondragover$(chk#) = "TestOnDragOver" THEN
    ASRT(1, "Set OnDragOver callback")
  ELSE
    ASRT(0, "Set OnDragOver callback")
  END IF
  ' OnDragDrop
  checkbox_ondragdrop#(chk#, "TestOnDragDrop")
  IF checkbox_ondragdrop$(chk#) = "TestOnDragDrop" THEN
    ASRT(1, "Set OnDragDrop callback")
  ELSE
    ASRT(0, "Set OnDragDrop callback")
  END IF
  ' OnDragLeave
  checkbox_ondragleave#(chk#, "TestOnDragLeave")
  IF checkbox_ondragleave$(chk#) = "TestOnDragLeave" THEN
    ASRT(1, "Set OnDragLeave callback")
  ELSE
    ASRT(0, "Set OnDragLeave callback")
  END IF
  checkbox_free(chk#)
END FUNCTION
FUNCTION TestErrorHandling() LOCAL chk#, dummy$
  PRINTLN ""
  PRINTLN "--- Error Handling Tests ---"
  ' Test with nil pointer
  checkbox_clearerror()
  dummy$ = checkbox_text$(Pointer#(0))
  IF checkbox_error() = 1 THEN
    ASRT(1, "Nil pointer error detected")
  ELSE
    ASRT(0, "Nil pointer error detected")
  END IF
  ' Error messages
  IF checkbox_strerror$(0) = "No error" THEN
    ASRT(1, "Strerror for code 0")
  ELSE
    ASRT(0, "Strerror for code 0")
  END IF
  IF checkbox_strerror$(1) = "Invalid checkbox pointer" THEN
    ASRT(1, "Strerror for code 1")
  ELSE
    ASRT(0, "Strerror for code 1")
  END IF
  IF checkbox_strerror$(2) = "Invalid parent pointer" THEN
    ASRT(1, "Strerror for code 2")
  ELSE
    ASRT(0, "Strerror for code 2")
  END IF
  ' Error message retrieval
  checkbox_clearerror()
  dummy$ = checkbox_text$(Pointer#(0))
  IF instr(checkbox_errormsg$(), "Nil pointer", 0) >= 0 THEN
    ASRT(1, "Error message contains details")
  ELSE
    ASRT(0, "Error message contains details")
  END IF
  ' Clear error
  checkbox_clearerror()
  IF checkbox_error() = 0 THEN
    ASRT(1, "Clear error")
  ELSE
    ASRT(0, "Clear error")
  END IF
END FUNCTION
' Dummy handlers for event tests (not actually called in this test)
FUNCTION TestOnChange(sender#)
END FUNCTION
FUNCTION TestOnClick(sender#)
END FUNCTION
FUNCTION TestOnDblClick(sender#)
END FUNCTION
FUNCTION TestOnEnter(sender#)
END FUNCTION
FUNCTION TestOnExit(sender#)
END FUNCTION
FUNCTION TestOnKeyDown(sender#, key, keychar$, shift$)
END FUNCTION
FUNCTION TestOnKeyUp(sender#, key, keychar$, shift$)
END FUNCTION
FUNCTION TestOnMouseDown(sender#, button, shift$, x, y)
END FUNCTION
FUNCTION TestOnMouseUp(sender#, button, shift$, x, y)
END FUNCTION
FUNCTION TestOnMouseMove(sender#, shift$, x, y)
END FUNCTION
FUNCTION TestOnMouseEnter(sender#)
END FUNCTION
FUNCTION TestOnMouseLeave(sender#)
END FUNCTION
FUNCTION TestOnResize(sender#)
END FUNCTION
FUNCTION TestOnDragEnter(sender#, x, y)
END FUNCTION
FUNCTION TestOnDragOver(sender#, x, y)
  RETURN 1
END FUNCTION
FUNCTION TestOnDragDrop(sender#, x, y)
END FUNCTION
FUNCTION TestOnDragLeave(sender#)
END FUNCTION
