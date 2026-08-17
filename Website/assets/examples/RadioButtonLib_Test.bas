' ============================================================================
' RadioButtonLib Test Applet
' Version: 1.0.0
'
' Comprehensive test suite for validating RadioButton control functionalities
' Tests: Creation, GroupName, Events, Styling, Positioning, State Management
' ============================================================================
' --- Global Variables ---
LET frm# = Pointer#(0)
LET lblStatus# = Pointer#(0)
LET lblGroupA# = Pointer#(0)
LET lblGroupB# = Pointer#(0)
LET testsPassed = 0
LET testsFailed = 0
LET currentTest$ = ""
' --- Group A: Color Selection ---
LET rbRed# = Pointer#(0)
LET rbGreen# = Pointer#(0)
LET rbBlue# = Pointer#(0)
' --- Group B: Size Selection ---
LET rbSmall# = Pointer#(0)
LET rbMedium# = Pointer#(0)
LET rbLarge# = Pointer#(0)
' --- Independent RadioButtons (no group) ---
LET rbIndep1# = Pointer#(0)
LET rbIndep2# = Pointer#(0)
' --- Test Control Buttons ---
LET btnRunTests# = Pointer#(0)
LET btnClearCallbacks# = Pointer#(0)
LET btnToggleEnabled# = Pointer#(0)
LET btnReset# = Pointer#(0)
' --- Memo for test output ---
LET memoLog# = Pointer#(0)
' ============================================================================
' Main Program
' ============================================================================
' Create main form
frm# = form#("RadioButtonLib Test Suite", 700, 600)
form_position#(frm#, 1) ' Center on screen
sb# = scrollbox#(frm#)
' Create status label at top
lblStatus# = label#(sb#, "RadioButtonLib Test Suite - Ready")
label_bounds#(lblStatus#, 10, 10, 680, 25)
label_fontsize#(lblStatus#, 14)
label_fontcolor#(lblStatus#, "Blue") ' Blue
label_bold#(lblStatus#, 1)
' --- Group A: Color Selection ---
lblGroupA# = label#(sb#, "Group A - Color Selection (GroupName: 'colors')")
label_bounds#(lblGroupA#, 10, 50, 300, 20)
label_bold#(lblGroupA#, 1)
rbRed# = radiobutton#(sb#, "Red")
radiobutton_bounds#(rbRed#, 20, 75, 120, 22)
radiobutton_groupname#(rbRed#, "colors")
radiobutton_tag#(rbRed#, 1)
radiobutton_onchange#(rbRed#, "OnColorChanged")
rbGreen# = radiobutton#(sb#, "Green")
radiobutton_bounds#(rbGreen#, 20, 100, 120, 22)
radiobutton_groupname#(rbGreen#, "colors")
radiobutton_tag#(rbGreen#, 2)
radiobutton_onchange#(rbGreen#, "OnColorChanged")
rbBlue# = radiobutton#(sb#, "Blue")
radiobutton_bounds#(rbBlue#, 20, 125, 120, 22)
radiobutton_groupname#(rbBlue#, "colors")
radiobutton_tag#(rbBlue#, 3)
radiobutton_onchange#(rbBlue#, "OnColorChanged")
' --- Group B: Size Selection ---
lblGroupB# = label#(sb#, "Group B - Size Selection (GroupName: 'sizes')")
label_bounds#(lblGroupB#, 10, 160, 300, 20)
label_bold#(lblGroupB#, 1)
rbSmall# = radiobutton#(sb#, "Small (10pt)")
radiobutton_bounds#(rbSmall#, 20, 185, 150, 22)
radiobutton_groupname#(rbSmall#, "sizes")
radiobutton_tag#(rbSmall#, 10)
radiobutton_onchange#(rbSmall#, "OnSizeChanged")
rbMedium# = radiobutton#(sb#, "Medium (14pt)")
radiobutton_bounds#(rbMedium#, 20, 210, 150, 22)
radiobutton_groupname#(rbMedium#, "sizes")
radiobutton_tag#(rbMedium#, 14)
radiobutton_onchange#(rbMedium#, "OnSizeChanged")
rbLarge# = radiobutton#(sb#, "Large (18pt)")
radiobutton_bounds#(rbLarge#, 20, 235, 150, 22)
radiobutton_groupname#(rbLarge#, "sizes")
radiobutton_tag#(rbLarge#, 18)
radiobutton_onchange#(rbLarge#, "OnSizeChanged")
' --- Independent RadioButtons (no GroupName - should work independently) ---
LET lblIndep# = label#(sb#, "Independent RadioButtons (no GroupName)")
label_bounds#(lblIndep#, 10, 275, 300, 20)
label_bold#(lblIndep#, 1)
' --- Independent RadioButtons (unique GroupNames for true independence) ---
rbIndep1# = radiobutton#(sb#, "Independent Option 1")
radiobutton_bounds#(rbIndep1#, 20, 300, 180, 22)
radiobutton_groupname#(rbIndep1#, "indep1")  ' Unique group
radiobutton_onchange#(rbIndep1#, "OnIndependentChanged")
rbIndep2# = radiobutton#(sb#, "Independent Option 2")
radiobutton_bounds#(rbIndep2#, 20, 325, 180, 22)
radiobutton_groupname#(rbIndep2#, "indep2")  ' Different unique group
radiobutton_onchange#(rbIndep2#, "OnIndependentChanged")
' --- Test Control Buttons ---
btnRunTests# = button#(sb#, "Run All Tests")
button_bounds#(btnRunTests#, 350, 75, 150, 35)
button_onclick#(btnRunTests#, "OnRunTests")
btnClearCallbacks# = button#(sb#, "Clear Callbacks")
button_bounds#(btnClearCallbacks#, 350, 120, 150, 35)
button_onclick#(btnClearCallbacks#, "OnClearCallbacks")
btnToggleEnabled# = button#(sb#, "Toggle Enabled")
button_bounds#(btnToggleEnabled#, 350, 165, 150, 35)
button_onclick#(btnToggleEnabled#, "OnToggleEnabled")
btnReset# = button#(sb#, "Reset All")
button_bounds#(btnReset#, 350, 210, 150, 35)
button_onclick#(btnReset#, "OnReset")
' --- Font Style Test Buttons ---
LET btnTestBold# = button#(sb#, "Toggle Bold")
button_bounds#(btnTestBold#, 510, 75, 120, 35)
button_onclick#(btnTestBold#, "OnToggleBold")
LET btnTestItalic# = button#(sb#, "Toggle Italic")
button_bounds#(btnTestItalic#, 510, 120, 120, 35)
button_onclick#(btnTestItalic#, "OnToggleItalic")
LET btnTestColor# = button#(sb#, "Cycle Color")
button_bounds#(btnTestColor#, 510, 165, 120, 35)
button_onclick#(btnTestColor#, "OnCycleColor")
' --- Log Memo ---
LET lblLog# = label#(sb#, "Test Log:")
label_bounds#(lblLog#, 10, 360, 100, 20)
label_bold#(lblLog#, 1)
memoLog# = memo#(sb#)
memo_bounds#(memoLog#, 10, 385, 680, 200)
memo_readonly#(memoLog#, 1)
memo_wordwrap#(memoLog#, 1)
' Show form
form_show(frm#)
LogMessage("RadioButtonLib Test Suite initialized")
LogMessage("Click 'Run All Tests' to execute automated tests")
LogMessage("Or interact with controls to test manually")
LogMessage("")
END
' ============================================================================
' Event Handlers
' ============================================================================
FUNCTION OnColorChanged(sender#) LOCAL tagVal, colorName$, checked
  checked = radiobutton_ischecked(sender#)
  IF checked = 1 THEN
    tagVal = radiobutton_tag(sender#)
    IF tagVal = 1 THEN
      colorName$ = "Red"
    ELSE IF tagVal = 2 THEN
      colorName$ = "Green"
    ELSE IF tagVal = 3 THEN
      colorName$ = "Blue"
    END IF
    LogMessage("Color Group: Selected '" + colorName$ + "'")
    UpdateStatus("Color selected: " + colorName$)
  END IF
END FUNCTION
FUNCTION OnSizeChanged(sender#) LOCAL tagVal, checked
  checked = radiobutton_ischecked(sender#)
  IF checked = 1 THEN
    tagVal = radiobutton_tag(sender#)
    LogMessage("Size Group: Selected " + stri$(tagVal) + "pt")
    UpdateStatus("Size selected: " + stri$(tagVal) + "pt")
  END IF
END FUNCTION
FUNCTION OnIndependentChanged(sender#) LOCAL txt$, checked
  checked = radiobutton_ischecked(sender#)
  txt$ = radiobutton_text$(sender#)
  IF checked = 1 THEN
    LogMessage("Independent: '" + txt$ + "' checked")
  ELSE
    LogMessage("Independent: '" + txt$ + "' unchecked")
  ENDIF
ENDFUNCTION
FUNCTION OnRunTests(sender#)
  LogMessage("")
  LogMessage("========================================")
  LogMessage("Starting Automated Test Suite...")
  LogMessage("========================================")
  testsPassed = 0
  testsFailed = 0
  TestCreation()
  TestGroupName()
  TestIsChecked()
  TestText()
  TestPosition()
  TestSize()
  TestVisibility()
  TestEnabled()
  TestFontProperties()
  TestTag()
  TestErrorHandling()
  TestMutualExclusion()
  LogMessage("")
  LogMessage("========================================")
  LogMessage("Test Results: " + stri$(testsPassed) + " passed, " + stri$(testsFailed) + " failed")
  LogMessage("========================================")
  UpdateStatus("Tests complete: " + stri$(testsPassed) + " passed, " + stri$(testsFailed) + " failed")
ENDFUNCTION
FUNCTION OnClearCallbacks(sender#)
  radiobutton_clearcallbacks#(rbRed#)
  radiobutton_clearcallbacks#(rbGreen#)
  radiobutton_clearcallbacks#(rbBlue#)
  radiobutton_clearcallbacks#(rbSmall#)
  radiobutton_clearcallbacks#(rbMedium#)
  radiobutton_clearcallbacks#(rbLarge#)
  radiobutton_clearcallbacks#(rbIndep1#)
  radiobutton_clearcallbacks#(rbIndep2#)
  LogMessage("All callbacks cleared - events will no longer fire")
  UpdateStatus("Callbacks cleared")
ENDFUNCTION
FUNCTION OnToggleEnabled(sender#) LOCAL isEnabled
  isEnabled = radiobutton_enabled(rbRed#)
  IF isEnabled = 1 THEN
    radiobutton_enabled#(rbRed#, 0)
    radiobutton_enabled#(rbGreen#, 0)
    radiobutton_enabled#(rbBlue#, 0)
    LogMessage("Color group disabled")
  ELSE
    radiobutton_enabled#(rbRed#, 1)
    radiobutton_enabled#(rbGreen#, 1)
    radiobutton_enabled#(rbBlue#, 1)
    LogMessage("Color group enabled")
  ENDIF
ENDFUNCTION
FUNCTION OnReset(sender#)
  ' Reset all radio buttons
  radiobutton_ischecked#(rbRed#, 0)
  radiobutton_ischecked#(rbGreen#, 0)
  radiobutton_ischecked#(rbBlue#, 0)
  radiobutton_ischecked#(rbSmall#, 0)
  radiobutton_ischecked#(rbMedium#, 0)
  radiobutton_ischecked#(rbLarge#, 0)
  radiobutton_ischecked#(rbIndep1#, 0)
  radiobutton_ischecked#(rbIndep2#, 0)
  ' Re-enable all
  radiobutton_enabled#(rbRed#, 1)
  radiobutton_enabled#(rbGreen#, 1)
  radiobutton_enabled#(rbBlue#, 1)
  ' Restore callbacks
  radiobutton_onchange#(rbRed#, "OnColorChanged")
  radiobutton_onchange#(rbGreen#, "OnColorChanged")
  radiobutton_onchange#(rbBlue#, "OnColorChanged")
  radiobutton_onchange#(rbSmall#, "OnSizeChanged")
  radiobutton_onchange#(rbMedium#, "OnSizeChanged")
  radiobutton_onchange#(rbLarge#, "OnSizeChanged")
  radiobutton_onchange#(rbIndep1#, "OnIndependentChanged")
  radiobutton_onchange#(rbIndep2#, "OnIndependentChanged")
  ' Reset font styles
  radiobutton_bold#(rbRed#, 0)
  radiobutton_italic#(rbRed#, 0)
  radiobutton_fontcolor#(rbRed#, "Red")
  LogMessage("All radio buttons reset to default state")
  UpdateStatus("Reset complete")
ENDFUNCTION
FUNCTION OnToggleBold(sender#) LOCAL isBold
  isBold = radiobutton_bold(rbRed#)
  IF isBold = 1 THEN
    radiobutton_bold#(rbRed#, 0)
    radiobutton_bold#(rbGreen#, 0)
    radiobutton_bold#(rbBlue#, 0)
    LogMessage("Font bold: OFF")
  ELSE
    radiobutton_bold#(rbRed#, 1)
    radiobutton_bold#(rbGreen#, 1)
    radiobutton_bold#(rbBlue#, 1)
    LogMessage("Font bold: ON")
  ENDIF
ENDFUNCTION
FUNCTION OnToggleItalic(sender#) LOCAL isItalic
  isItalic = radiobutton_italic(rbRed#)
  IF isItalic = 1 THEN
    radiobutton_italic#(rbRed#, 0)
    radiobutton_italic#(rbGreen#, 0)
    radiobutton_italic#(rbBlue#, 0)
    LogMessage("Font italic: OFF")
  ELSE
    radiobutton_italic#(rbRed#, 1)
    radiobutton_italic#(rbGreen#, 1)
    radiobutton_italic#(rbBlue#, 1)
    LogMessage("Font italic: ON")
  ENDIF
ENDFUNCTION
LET colorIndex = 0
FUNCTION OnCycleColor(sender#) LOCAL clr, clr$
  colorIndex = colorIndex + 1
  IF colorIndex > 3 THEN
    colorIndex = 0
  END IF
  IF colorIndex = 0 THEN
    clr = 0 ' Black
    clr$ = "Black"
  ELSE IF colorIndex = 1 THEN
    clr = 16711680 ' Red (BGR format)
    clr$ = "Red"
  ELSE IF colorIndex = 2 THEN
    clr = 32768 ' Green
    clr$ = "Green"
  ELSE IF colorIndex = 3 THEN
    clr = 255 ' Blue
    clr$ = "Blue"
  END IF
  radiobutton_fontcolor#(rbRed#, clr$)
  radiobutton_fontcolor#(rbGreen#, clr$)
  radiobutton_fontcolor#(rbBlue#, clr$)
  LogMessage("Font color changed (index: " + stri$(colorIndex) + ")")
END FUNCTION
' ============================================================================
' Test Functions
' ============================================================================
FUNCTION TestCreation() LOCAL testRb#, pnt
  currentTest$ = "Creation"
  LogMessage("--- Testing Creation ---")
  ' Test basic creation
  testRb# = radiobutton#(sb#, "Test RadioButton")
  pnt = PntToNum(testRb#)
  IF pnt <> 0 THEN
    PassTest("radiobutton#(parent, text) creates valid control")
  ELSE
    FailTest("radiobutton#(parent, text) failed to create control")
  ENDIF
  ' Clean up
  radiobutton_free(testRb#)
  ' Test creation with bounds
  testRb# = radiobutton#(sb#, "Bounded RB", 100, 100, 150, 25)
  pnt = PntToNum(testRb#)
  IF pnt <> 0 THEN
    PassTest("radiobutton#(parent, text, x, y, w, h) creates valid control")
  ELSE
    FailTest("radiobutton#(parent, text, x, y, w, h) failed")
  ENDIF
  radiobutton_free(testRb#)
ENDFUNCTION
FUNCTION TestGroupName() LOCAL gn$
  currentTest$ = "GroupName"
  LogMessage("--- Testing GroupName ---")
  ' Test getting group name
  gn$ = radiobutton_groupname$(rbRed#)
  IF gn$ = "colors" THEN
    PassTest("radiobutton_groupname$ returns correct group name")
  ELSE
    FailTest("radiobutton_groupname$ returned '" + gn$ + "' instead of 'colors'")
  ENDIF
  ' Test setting group name
  radiobutton_groupname#(rbRed#, "testgroup")
  gn$ = radiobutton_groupname$(rbRed#)
  IF gn$ = "testgroup" THEN
    PassTest("radiobutton_groupname# sets group name correctly")
  ELSE
    FailTest("radiobutton_groupname# failed to set group name")
  ENDIF
  ' Restore original
  radiobutton_groupname#(rbRed#, "colors")
ENDFUNCTION
FUNCTION TestIsChecked() LOCAL chk
  currentTest$ = "IsChecked"
  LogMessage("--- Testing IsChecked ---")
  ' Clear first
  radiobutton_ischecked#(rbRed#, 0)
  ' Test unchecked state
  chk = radiobutton_ischecked(rbRed#)
  IF chk = 0 THEN
    PassTest("radiobutton_ischecked returns 0 when unchecked")
  ELSE
    FailTest("radiobutton_ischecked returned " + stri$(chk) + " instead of 0")
  ENDIF
  ' Test setting checked
  radiobutton_ischecked#(rbRed#, 1)
  chk = radiobutton_ischecked(rbRed#)
  IF chk = 1 THEN
    PassTest("radiobutton_ischecked# sets checked state correctly")
  ELSE
    FailTest("radiobutton_ischecked# failed to set checked state")
  ENDIF
  ' Reset
  radiobutton_ischecked#(rbRed#, 0)
ENDFUNCTION
FUNCTION TestText() LOCAL txt$
  currentTest$ = "Text"
  LogMessage("--- Testing Text ---")
  ' Test getting text
  txt$ = radiobutton_text$(rbRed#)
  IF txt$ = "Red" THEN
    PassTest("radiobutton_text$ returns correct text")
  ELSE
    FailTest("radiobutton_text$ returned '" + txt$ + "' instead of 'Red'")
  ENDIF
  ' Test setting text
  radiobutton_text#(rbRed#, "Test Red")
  txt$ = radiobutton_text$(rbRed#)
  IF txt$ = "Test Red" THEN
    PassTest("radiobutton_text# sets text correctly")
  ELSE
    FailTest("radiobutton_text# failed to set text")
  ENDIF
  ' Restore original
  radiobutton_text#(rbRed#, "Red")
ENDFUNCTION
FUNCTION TestPosition() LOCAL x, y
  currentTest$ = "Position"
  LogMessage("--- Testing Position ---")
  ' Test getting position
  x = radiobutton_x(rbRed#)
  y = radiobutton_y(rbRed#)
  IF x = 20 THEN
    PassTest("radiobutton_x returns correct X position")
  ELSE
    FailTest("radiobutton_x returned " + stri$(x) + " instead of 20")
  ENDIF
  IF y = 75 THEN
    PassTest("radiobutton_y returns correct Y position")
  ELSE
    FailTest("radiobutton_y returned " + stri$(y) + " instead of 75")
  ENDIF
  ' Test move
  radiobutton_move#(rbRed#, 25, 80)
  x = radiobutton_x(rbRed#)
  y = radiobutton_y(rbRed#)
  IF x = 25 THEN
    PassTest("radiobutton_move# changes X correctly")
  ELSE
    FailTest("radiobutton_move# X failed")
  ENDIF
  ' Restore
  radiobutton_move#(rbRed#, 20, 75)
ENDFUNCTION
FUNCTION TestSize() LOCAL w, h
  currentTest$ = "Size"
  LogMessage("--- Testing Size ---")
  ' Test getting size
  w = radiobutton_width(rbRed#)
  h = radiobutton_height(rbRed#)
  IF w = 120 THEN
    PassTest("radiobutton_width returns correct width")
  ELSE
    FailTest("radiobutton_width returned " + stri$(w) + " instead of 120")
  ENDIF
  IF h = 22 THEN
    PassTest("radiobutton_height returns correct height")
  ELSE
    FailTest("radiobutton_height returned " + stri$(h) + " instead of 22")
  ENDIF
ENDFUNCTION
FUNCTION TestVisibility() LOCAL vis
  currentTest$ = "Visibility"
  LogMessage("--- Testing Visibility ---")
  ' Test getting visibility
  vis = radiobutton_visible(rbRed#)
  IF vis = 1 THEN
    PassTest("radiobutton_visible returns 1 when visible")
  ELSE
    FailTest("radiobutton_visible returned " + stri$(vis))
  ENDIF
  ' Test hiding
  radiobutton_visible#(rbRed#, 0)
  vis = radiobutton_visible(rbRed#)
  IF vis = 0 THEN
    PassTest("radiobutton_visible# hides control correctly")
  ELSE
    FailTest("radiobutton_visible# failed to hide control")
  ENDIF
  ' Restore
  radiobutton_visible#(rbRed#, 1)
ENDFUNCTION
FUNCTION TestEnabled() LOCAL en
  currentTest$ = "Enabled"
  LogMessage("--- Testing Enabled ---")
  ' Test getting enabled state
  en = radiobutton_enabled(rbRed#)
  IF en = 1 THEN
    PassTest("radiobutton_enabled returns 1 when enabled")
  ELSE
    FailTest("radiobutton_enabled returned " + stri$(en))
  ENDIF
  ' Test disabling
  radiobutton_enabled#(rbRed#, 0)
  en = radiobutton_enabled(rbRed#)
  IF en = 0 THEN
    PassTest("radiobutton_enabled# disables control correctly")
  ELSE
    FailTest("radiobutton_enabled# failed to disable control")
  ENDIF
  ' Restore
  radiobutton_enabled#(rbRed#, 1)
ENDFUNCTION
FUNCTION TestFontProperties() LOCAL sz, bold
  currentTest$ = "Font Properties"
  LogMessage("--- Testing Font Properties ---")
  ' Test font size
  radiobutton_fontsize#(rbRed#, 14)
  sz = radiobutton_fontsize(rbRed#)
  IF sz = 14 THEN
    PassTest("radiobutton_fontsize# sets font size correctly")
  ELSE
    FailTest("radiobutton_fontsize returned " + stri$(sz))
  ENDIF
  ' Restore default size
  radiobutton_fontsize#(rbRed#, 12)
  ' Test bold
  radiobutton_bold#(rbRed#, 1)
  bold = radiobutton_bold(rbRed#)
  IF bold = 1 THEN
    PassTest("radiobutton_bold# sets bold correctly")
  ELSE
    FailTest("radiobutton_bold returned " + stri$(bold))
  ENDIF
  ' Restore
  radiobutton_bold#(rbRed#, 0)
ENDFUNCTION
FUNCTION TestTag() LOCAL tg
  currentTest$ = "Tag"
  LogMessage("--- Testing Tag ---")
  ' Test getting tag
  tg = radiobutton_tag(rbRed#)
  IF tg = 1 THEN
    PassTest("radiobutton_tag returns correct tag value")
  ELSE
    FailTest("radiobutton_tag returned " + stri$(tg) + " instead of 1")
  ENDIF
  ' Test setting tag
  radiobutton_tag#(rbRed#, 999)
  tg = radiobutton_tag(rbRed#)
  IF tg = 999 THEN
    PassTest("radiobutton_tag# sets tag correctly")
  ELSE
    FailTest("radiobutton_tag# failed to set tag")
  ENDIF
  ' Restore
  radiobutton_tag#(rbRed#, 1)
ENDFUNCTION
FUNCTION TestErrorHandling() LOCAL err, msg$
  currentTest$ = "Error Handling"
  LogMessage("--- Testing Error Handling ---")
  ' Clear any previous error
  radiobutton_clearerror()
  err = radiobutton_error()
  IF err = 0 THEN
    PassTest("radiobutton_clearerror clears error state")
  ELSE
    FailTest("radiobutton_clearerror failed")
  ENDIF
  ' Test error message for code 0
  msg$ = radiobutton_strerror$(0)
  IF len(msg$) > 0 THEN
    PassTest("radiobutton_strerror$ returns message for code 0")
  ELSE
    FailTest("radiobutton_strerror$ returned empty string")
  ENDIF
  ' Test invalid pointer error
  radiobutton_text$(Pointer#(0))
  err = radiobutton_error()
  IF err = 1 THEN
    PassTest("Invalid pointer generates error code 1")
  ELSE
    FailTest("Invalid pointer did not generate expected error")
  ENDIF
  radiobutton_clearerror()
ENDFUNCTION
FUNCTION TestMutualExclusion() LOCAL chk1, chk2, chk3
  currentTest$ = "Mutual Exclusion"
  LogMessage("--- Testing Mutual Exclusion (GroupName) ---")
  ' Clear all first
  radiobutton_ischecked#(rbRed#, 0)
  radiobutton_ischecked#(rbGreen#, 0)
  radiobutton_ischecked#(rbBlue#, 0)
  ' Select Red
  radiobutton_ischecked#(rbRed#, 1)
  chk1 = radiobutton_ischecked(rbRed#)
  IF chk1 = 1 THEN
    PassTest("First selection in group works")
  ELSE
    FailTest("First selection failed")
  ENDIF
  ' Select Green - should deselect Red
  radiobutton_ischecked#(rbGreen#, 1)
  chk1 = radiobutton_ischecked(rbRed#)
  chk2 = radiobutton_ischecked(rbGreen#)
  IF chk2 = 1 THEN
    PassTest("Second selection in group selects new item")
  ELSE
    FailTest("Second selection did not select new item")
  ENDIF
  IF chk1 = 0 THEN
    PassTest("Mutual exclusion: previous selection deselected")
  ELSE
    FailTest("Mutual exclusion failed: previous item still selected")
  ENDIF
  ' Test independent radio buttons can both be selected
  radiobutton_ischecked#(rbIndep1#, 1)
  radiobutton_ischecked#(rbIndep2#, 1)
  chk1 = radiobutton_ischecked(rbIndep1#)
  chk2 = radiobutton_ischecked(rbIndep2#)
  IF chk1 = 1 THEN
    PassTest("Independent radiobutton 1 can be checked")
  ELSE
    FailTest("Independent radiobutton 1 was unexpectedly unchecked")
  ENDIF
  IF chk2 = 1 THEN
    PassTest("Independent radiobutton 2 can be checked simultaneously")
  ELSE
    FailTest("Independent radiobutton 2 failed")
  ENDIF
  ' Reset
  radiobutton_ischecked#(rbRed#, 0)
  radiobutton_ischecked#(rbGreen#, 0)
  radiobutton_ischecked#(rbIndep1#, 0)
  radiobutton_ischecked#(rbIndep2#, 0)
ENDFUNCTION
' ============================================================================
' Helper Functions
' ============================================================================
FUNCTION LogMessage(msg$)
  memo_addline#(memoLog#, msg$)
  ' Scroll to bottom
  memo_selstart#(memoLog#, len(memo_text$(memoLog#)))
ENDFUNCTION
FUNCTION UpdateStatus(msg$)
  label_text#(lblStatus#, msg$)
ENDFUNCTION
FUNCTION PassTest(description$)
  testsPassed = testsPassed + 1
  LogMessage("  [PASS] " + description$)
ENDFUNCTION
FUNCTION FailTest(description$)
  testsFailed = testsFailed + 1
  LogMessage("  [FAIL] " + description$)
ENDFUNCTION
