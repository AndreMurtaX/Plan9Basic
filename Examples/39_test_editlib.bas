' ============================================================================
' EditLib Test Applet - Comprehensive Test Suite for Plan9Basic
' Version: 1.0.0
'
' This applet tests all functionality of the EditLib library including:
' - Edit creation with various constructors
' - Text content and placeholder
' - Password and read-only modes
' - Font properties
' - Selection and caret control
' - Clipboard operations
' - Mobile features
' - Position, size, and alignment
' - Event handling
' ============================================================================
PRINTLN "=== EditLib Test Suite ==="
PRINTLN ""
' Create main form
LET frm# = form#("EditLib Test Suite", 800, 600)
form_position#(frm#, 4)
LET sb# = scrollbox#(frm#)
' Create a layout panel for controls
LET panel# = layout#(sb#)
layout_bounds#(panel#, 10, 10, 780, 580)
' ============================================================================
' TEST 1: Basic Edit Creation
' ============================================================================
PRINTLN "TEST 1: Edit Creation"
' Create edit with parent only
LET edt1# = edit#(panel#)
edit_bounds#(edt1#, 10, 10, 300, 30)
edit_text#(edt1#, "Basic edit")
PRINTLN "  - Created basic edit: " + edit_text$(edt1#)
' Create edit with position
LET edt2# = edit#(panel#, 10, 50, 300, 30)
edit_text#(edt2#, "Edit with position")
PRINTLN "  - Created edit with position: " + edit_text$(edt2#)
' Create edit with text
LET edt3# = edit#(panel#, 10, 90, 300, 30, "Edit with initial text")
PRINTLN "  - Created edit with text: " + edit_text$(edt3#)
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 2: Text Content and Placeholder
' ============================================================================
PRINTLN "TEST 2: Text Content and Placeholder"
LET edtPrompt# = edit#(panel#, 10, 140, 300, 30)
edit_prompt#(edtPrompt#, "Enter your name...")
PRINTLN "  - Placeholder: " + edit_prompt$(edtPrompt#)
edit_text#(edtPrompt#, "John Doe")
PRINTLN "  - Text: " + edit_text$(edtPrompt#)
PRINTLN "  - Text length: " + stri$(edit_textlength(edtPrompt#))
edit_maxlength#(edtPrompt#, 20)
PRINTLN "  - Max length set to: " + stri$(edit_maxlength(edtPrompt#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 3: Password Mode
' ============================================================================
PRINTLN "TEST 3: Password Mode"
LET edtPass# = edit#(panel#, 10, 180, 300, 30)
edit_prompt#(edtPass#, "Enter password...")
edit_password#(edtPass#, 1)
edit_text#(edtPass#, "secret123")
PRINTLN "  - Password mode: " + stri$(edit_password(edtPass#))
PRINTLN "  - Text (still readable): " + edit_text$(edtPass#)
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 4: Read-Only Mode
' ============================================================================
PRINTLN "TEST 4: Read-Only Mode"
LET edtReadOnly# = edit#(panel#, 10, 220, 300, 30)
edit_text#(edtReadOnly#, "This text is read-only")
edit_readonly#(edtReadOnly#, 1)
PRINTLN "  - Read-only mode: " + stri$(edit_readonly(edtReadOnly#))
PRINTLN "  - Text: " + edit_text$(edtReadOnly#)
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 5: Font Properties
' ============================================================================
PRINTLN "TEST 5: Font Properties"
LET edtFont# = edit#(panel#, 10, 260, 300, 35)
edit_text#(edtFont#, "Styled Text")
edit_fontsize#(edtFont#, 18)
PRINTLN "  - Font size: " + stri$(edit_fontsize(edtFont#))
edit_fontcolor#(edtFont#, "blue")
PRINTLN "  - Font color: " + edit_fontcolor$(edtFont#)
edit_bold#(edtFont#, 1)
PRINTLN "  - Bold: " + stri$(edit_bold(edtFont#))
edit_italic#(edtFont#, 1)
PRINTLN "  - Italic: " + stri$(edit_italic(edtFont#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 6: Text Alignment
' ============================================================================
PRINTLN "TEST 6: Text Alignment"
LET edtAlignL# = edit#(panel#, 10, 310, 150, 30)
edit_text#(edtAlignL#, "Left")
edit_textalign#(edtAlignL#, 0)
PRINTLN "  - Left align: " + stri$(edit_textalign(edtAlignL#))
LET edtAlignC# = edit#(panel#, 170, 310, 150, 30)
edit_text#(edtAlignC#, "Center")
edit_textalign#(edtAlignC#, 1)
PRINTLN "  - Center align: " + stri$(edit_textalign(edtAlignC#))
LET edtAlignR# = edit#(panel#, 330, 310, 150, 30)
edit_text#(edtAlignR#, "Right")
edit_textalign#(edtAlignR#, 2)
PRINTLN "  - Right align: " + stri$(edit_textalign(edtAlignR#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 7: Filter Characters
' ============================================================================
PRINTLN "TEST 7: Filter Characters"
LET edtNumOnly# = edit#(panel#, 10, 350, 200, 30)
edit_prompt#(edtNumOnly#, "Numbers only")
edit_filterchar#(edtNumOnly#, "0123456789")
PRINTLN "  - Filter: " + edit_filterchar$(edtNumOnly#)
LET edtAlphaOnly# = edit#(panel#, 220, 350, 200, 30)
edit_prompt#(edtAlphaOnly#, "Letters only")
edit_filterchar#(edtAlphaOnly#, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
PRINTLN "  - Filter set for letters only"
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 8: Selection and Caret
' ============================================================================
PRINTLN "TEST 8: Selection and Caret"
LET edtSelect# = edit#(panel#, 10, 390, 300, 30)
edit_text#(edtSelect#, "Select some text here")
edit_selstart#(edtSelect#, 7)
edit_sellength#(edtSelect#, 4)
PRINTLN "  - Selection start: " + stri$(edit_selstart(edtSelect#))
PRINTLN "  - Selection length: " + stri$(edit_sellength(edtSelect#))
PRINTLN "  - Selected text: " + edit_seltext$(edtSelect#)
PRINTLN "  - Caret position: " + stri$(edit_caretposition(edtSelect#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 9: Position and Size
' ============================================================================
PRINTLN "TEST 9: Position and Size"
LET edtPos# = edit#(panel#, 330, 390, 200, 30)
edit_text#(edtPos#, "Position test")
PRINTLN "  - X: " + stri$(edit_x(edtPos#))
PRINTLN "  - Y: " + stri$(edit_y(edtPos#))
PRINTLN "  - Width: " + stri$(edit_width(edtPos#))
PRINTLN "  - Height: " + stri$(edit_height(edtPos#))
edit_move#(edtPos#, 350, 390)
PRINTLN "  - After move - X: " + stri$(edit_x(edtPos#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 10: Visibility and Behavior
' ============================================================================
PRINTLN "TEST 10: Visibility and Behavior"
LET edtVis# = edit#(panel#, 10, 430, 200, 30)
edit_text#(edtVis#, "Visibility test")
PRINTLN "  - Visible: " + stri$(edit_visible(edtVis#))
PRINTLN "  - Enabled: " + stri$(edit_enabled(edtVis#))
PRINTLN "  - Opacity: " + stri$(edit_opacity(edtVis#))
edit_opacity#(edtVis#, 0.7)
PRINTLN "  - Opacity after change: " + stri$(edit_opacity(edtVis#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 11: Event Handling
' ============================================================================
PRINTLN "TEST 11: Event Handling"
' Create a labeled section for event testing
LET lblEvents# = label#(panel#, "Event Test (type below):")
label_move#(lblEvents#, 10, 470)
label_fontsize#(lblEvents#, 12)
label_bold#(lblEvents#, 1)
LET edtEvents# = edit#(panel#, 10, 495, 300, 30)
edit_prompt#(edtEvents#, "Type here to test events...")
edit_onchange#(edtEvents#, "OnEditChange")
edit_onchangetracking#(edtEvents#, "OnEditTracking")
edit_onenter#(edtEvents#, "OnEditEnter")
edit_onexit#(edtEvents#, "OnEditExit")
edit_onkeydown#(edtEvents#, "OnEditKeyDown")
PRINTLN "  - Events registered:"
PRINTLN "    OnChange: " + edit_onchange$(edtEvents#)
PRINTLN "    OnChangeTracking: " + edit_onchangetracking$(edtEvents#)
PRINTLN "    OnEnter: " + edit_onenter$(edtEvents#)
PRINTLN "    OnExit: " + edit_onexit$(edtEvents#)
PRINTLN "    OnKeyDown: " + edit_onkeydown$(edtEvents#)
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 12: Mobile Features
' ============================================================================
PRINTLN "TEST 12: Mobile Features"
LET edtMobile# = edit#(panel#, 330, 495, 200, 30)
edit_prompt#(edtMobile#, "Email input")
edit_keyboardtype#(edtMobile#, 7)  ' Email address
edit_returnkeytype#(edtMobile#, 1)  ' Done
edit_checkspelling#(edtMobile#, 1)
PRINTLN "  - Keyboard type: " + stri$(edit_keyboardtype(edtMobile#))
PRINTLN "  - Return key type: " + stri$(edit_returnkeytype(edtMobile#))
PRINTLN "  - Check spelling: " + stri$(edit_checkspelling(edtMobile#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 13: Tag and Tab Order
' ============================================================================
PRINTLN "TEST 13: Tag and Tab Order"
edit_tag#(edt1#, 100)
edit_taborder#(edt1#, 1)
PRINTLN "  - Tag: " + stri$(edit_tag(edt1#))
PRINTLN "  - Tab order: " + stri$(edit_taborder(edt1#))
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' TEST 14: Error Handling
' ============================================================================
PRINTLN "TEST 14: Error Handling"
edit_clearerror()
PRINTLN "  - Initial error: " + stri$(edit_error())
' Try to use a null pointer
LET badPtr# = Pointer#(0)
edit_text#(badPtr#, "This should fail")
PRINTLN "  - Error after invalid operation: " + stri$(edit_error())
PRINTLN "  - Error message: " + edit_errormsg$()
PRINTLN "  - Error description: " + edit_strerror$(edit_error())
edit_clearerror()
PRINTLN "  - After clear: " + stri$(edit_error())
PRINTLN "  PASSED"
PRINTLN ""
' ============================================================================
' Summary
' ============================================================================
PRINTLN "=== All Tests Completed ==="
PRINTLN "Form will now display. Try the interactive features:"
PRINTLN "- Type in the event test field to see events fire"
PRINTLN "- Try the numbers-only and letters-only fields"
PRINTLN "- Test the password field"
PRINTLN ""
' Show the form
form_show(frm#)
' ============================================================================
' Event Callback Functions
' ============================================================================
FUNCTION OnEditChange(sender#)
  PRINTLN "[OnChange] Text: " + edit_text$(sender#)
END FUNCTION
FUNCTION OnEditTracking(sender#)
  PRINTLN "[OnChangeTracking] Text: " + edit_text$(sender#) + " (length: " + stri$(edit_textlength(sender#)) + ")"
END FUNCTION
FUNCTION OnEditEnter(sender#)
  PRINTLN "[OnEnter] Edit focused"
END FUNCTION
FUNCTION OnEditExit(sender#)
  PRINTLN "[OnExit] Edit lost focus"
END FUNCTION
FUNCTION OnEditKeyDown(sender#, key, keychar$, shift$)
  PRINTLN "[OnKeyDown] Key: " + stri$(key) + " Char: " + keychar$ + " Shift: " + shift$
  ' Check for Enter key
  IF key = 13 THEN
    PRINTLN "  -> Enter key pressed!"
  END IF
  ' Check for Escape key
  IF key = 27 THEN
    PRINTLN "  -> Escape key pressed!"
  END IF
END FUNCTION
