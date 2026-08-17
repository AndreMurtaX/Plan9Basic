' ============================================================================
' SpeedButton Demo - Text Editor Toolbar
' Demonstrates practical use of SpeedButtons in a toolbar-style interface
'
' NOTE: FMX TSpeedButton does NOT have automatic radio-button grouping.
' GroupIndex is a custom property for logical grouping only.
' This demo shows how to manually implement radio-button behavior.
' ============================================================================
PRINTLN "SpeedButton Demo - Text Editor Toolbar"
PRINTLN "======================================"
PRINTLN ""
' Create main form
LET frm# = form#("Text Editor Demo", 600, 450)
' Create toolbar layout at top
LET toolbar# = layout#(frm#)
layout_align#(toolbar#, 1)
layout_height#(toolbar#, 45)
' Create a memo for text editing
LET memo# = memo#(frm#)
memo_align#(memo#, 9)
memo_margin#(memo#, 5)
memo_text#(memo#, "Type some text here...")
memo_fontsize#(memo#, 12)
' ============================================================================
' Text Formatting Buttons (Independent Toggles - GroupIndex = 0)
' Each can be toggled independently
' ============================================================================
LET sbBold# = speedbutton#(toolbar#, "B")
speedbutton_move#(sbBold#, 5, 7)
speedbutton_size#(sbBold#, 32, 32)
speedbutton_bold#(sbBold#, 1)
speedbutton_fontsize#(sbBold#, 14)
speedbutton_stayspressed#(sbBold#, 1)
speedbutton_groupindex#(sbBold#, 0)
speedbutton_tag#(sbBold#, 1)
speedbutton_onclick#(sbBold#, "OnFormatClick")
LET sbItalic# = speedbutton#(toolbar#, "I")
speedbutton_move#(sbItalic#, 42, 7)
speedbutton_size#(sbItalic#, 32, 32)
speedbutton_italic#(sbItalic#, 1)
speedbutton_fontsize#(sbItalic#, 14)
speedbutton_stayspressed#(sbItalic#, 1)
speedbutton_groupindex#(sbItalic#, 0)
speedbutton_tag#(sbItalic#, 2)
speedbutton_onclick#(sbItalic#, "OnFormatClick")
LET sbUnder# = speedbutton#(toolbar#, "U")
speedbutton_move#(sbUnder#, 79, 7)
speedbutton_size#(sbUnder#, 32, 32)
speedbutton_underline#(sbUnder#, 1)
speedbutton_fontsize#(sbUnder#, 14)
speedbutton_stayspressed#(sbUnder#, 1)
speedbutton_groupindex#(sbUnder#, 0)
speedbutton_tag#(sbUnder#, 3)
speedbutton_onclick#(sbUnder#, "OnFormatClick")
' Note: TMemo doesn't support underline, button is visual only
' ============================================================================
' Text Alignment Buttons (Mutually Exclusive - GroupIndex = 1)
' Only one can be selected at a time
' ============================================================================
LET sbAlignL# = speedbutton#(toolbar#, "")
speedbutton_move#(sbAlignL#, 130, 7)
speedbutton_size#(sbAlignL#, 32, 32)
speedbutton_text#(sbAlignL#, chr$(8676))
speedbutton_stayspressed#(sbAlignL#, 1)
speedbutton_groupindex#(sbAlignL#, 1)
speedbutton_down#(sbAlignL#, 1)
speedbutton_tag#(sbAlignL#, 10)
speedbutton_onclick#(sbAlignL#, "OnAlignClick")
LET sbAlignC# = speedbutton#(toolbar#, "")
speedbutton_move#(sbAlignC#, 167, 7)
speedbutton_size#(sbAlignC#, 32, 32)
speedbutton_text#(sbAlignC#, chr$(9644))
speedbutton_stayspressed#(sbAlignC#, 1)
speedbutton_groupindex#(sbAlignC#, 1)
speedbutton_tag#(sbAlignC#, 11)
speedbutton_onclick#(sbAlignC#, "OnAlignClick")
LET sbAlignR# = speedbutton#(toolbar#, "")
speedbutton_move#(sbAlignR#, 204, 7)
speedbutton_size#(sbAlignR#, 32, 32)
speedbutton_text#(sbAlignR#, chr$(8677))
speedbutton_stayspressed#(sbAlignR#, 1)
speedbutton_groupindex#(sbAlignR#, 1)
speedbutton_tag#(sbAlignR#, 12)
speedbutton_onclick#(sbAlignR#, "OnAlignClick")
' ============================================================================
' Font Size Buttons (Mutually Exclusive - GroupIndex = 2)
' ============================================================================
LET sbSmall# = speedbutton#(toolbar#, "S")
speedbutton_move#(sbSmall#, 255, 7)
speedbutton_size#(sbSmall#, 32, 32)
speedbutton_fontsize#(sbSmall#, 10)
speedbutton_stayspressed#(sbSmall#, 1)
speedbutton_groupindex#(sbSmall#, 2)
speedbutton_tag#(sbSmall#, 20)
speedbutton_onclick#(sbSmall#, "OnSizeClick")
LET sbMedium# = speedbutton#(toolbar#, "M")
speedbutton_move#(sbMedium#, 292, 7)
speedbutton_size#(sbMedium#, 32, 32)
speedbutton_fontsize#(sbMedium#, 12)
speedbutton_stayspressed#(sbMedium#, 1)
speedbutton_groupindex#(sbMedium#, 2)
speedbutton_down#(sbMedium#, 1)
speedbutton_tag#(sbMedium#, 21)
speedbutton_onclick#(sbMedium#, "OnSizeClick")
LET sbLarge# = speedbutton#(toolbar#, "L")
speedbutton_move#(sbLarge#, 329, 7)
speedbutton_size#(sbLarge#, 32, 32)
speedbutton_fontsize#(sbLarge#, 14)
speedbutton_stayspressed#(sbLarge#, 1)
speedbutton_groupindex#(sbLarge#, 2)
speedbutton_tag#(sbLarge#, 22)
speedbutton_onclick#(sbLarge#, "OnSizeClick")
' ============================================================================
' Action Buttons (Non-toggle - GroupIndex = 0, StaysPressed = 0)
' ============================================================================
LET sbClear# = speedbutton#(toolbar#, "Clear")
speedbutton_move#(sbClear#, 380, 7)
speedbutton_size#(sbClear#, 50, 32)
speedbutton_stayspressed#(sbClear#, 0)
speedbutton_groupindex#(sbClear#, 0)
speedbutton_onclick#(sbClear#, "OnClearClick")
LET sbInfo# = speedbutton#(toolbar#, "Info")
speedbutton_move#(sbInfo#, 435, 7)
speedbutton_size#(sbInfo#, 50, 32)
speedbutton_stayspressed#(sbInfo#, 0)
speedbutton_groupindex#(sbInfo#, 0)
speedbutton_onclick#(sbInfo#, "OnInfoClick")
' ============================================================================
' Status label
' ============================================================================
LET lblStatus# = label#(toolbar#, "Ready")
label_move#(lblStatus#, 500, 15)
label_autosize#(lblStatus#, 1)
label_fontcolor#(lblStatus#, "#FF666666")
' Show form
form_show(frm#)
PRINTLN "Toolbar created with:"
PRINTLN "  - B/I/U: Independent format toggles"
PRINTLN "  - Alignment buttons: Mutually exclusive"
PRINTLN "  - S/M/L: Font size options"
PRINTLN "  - Clear/Info: Action buttons"
PRINTLN ""
' ============================================================================
' Event Handlers
' ============================================================================
FUNCTION OnFormatClick(sender#) LOCAL tagVal, state, style$
  LET tagVal = speedbutton_tag(sender#)
  LET state = speedbutton_down(sender#)
  ' Update memo formatting based on tag
  IF tagVal = 1 THEN
    LET style$ = "Bold"
    memo_bold#(memo#, state)
  END IF
  IF tagVal = 2 THEN
    LET style$ = "Italic"
    memo_italic#(memo#, state)
  END IF
  IF tagVal = 3 THEN
    LET style$ = "Underline"
    ' Note: TMemo doesn't support underline style
    ' Button toggles visually but doesn't affect memo
  END IF
  ' Update status
  IF state = 1 THEN
    IF tagVal = 3 THEN
      label_text#(lblStatus#, style$ + ": ON (visual)")
    ELSE
      label_text#(lblStatus#, style$ + ": ON")
    END IF
  ELSE
    IF tagVal = 3 THEN
      label_text#(lblStatus#, style$ + ": OFF (visual)")
    ELSE
      label_text#(lblStatus#, style$ + ": OFF")
    END IF
  END IF
  PRINTLN style$ + " = " + str$(state)
END FUNCTION
FUNCTION OnAlignClick(sender#) LOCAL tagVal
  LET tagVal = speedbutton_tag(sender#)
  ' Manual radio-button behavior: turn off other buttons in same group
  ' (FMX TSpeedButton doesn't have automatic radio grouping)
  speedbutton_down#(sbAlignL#, 0)
  speedbutton_down#(sbAlignC#, 0)
  speedbutton_down#(sbAlignR#, 0)
  speedbutton_down#(sender#, 1)
  IF tagVal = 10 THEN
    label_text#(lblStatus#, "Align: Left")
    PRINTLN "Alignment: Left"
  END IF
  IF tagVal = 11 THEN
    label_text#(lblStatus#, "Align: Center")
    PRINTLN "Alignment: Center"
  END IF
  IF tagVal = 12 THEN
    label_text#(lblStatus#, "Align: Right")
    PRINTLN "Alignment: Right"
  END IF
END FUNCTION
FUNCTION OnSizeClick(sender#) LOCAL tagVal, fontSize
  LET tagVal = speedbutton_tag(sender#)
  ' Manual radio-button behavior: turn off other buttons in same group
  speedbutton_down#(sbSmall#, 0)
  speedbutton_down#(sbMedium#, 0)
  speedbutton_down#(sbLarge#, 0)
  speedbutton_down#(sender#, 1)
  IF tagVal = 20 THEN
    LET fontSize = 10
    label_text#(lblStatus#, "Size: Small")
  END IF
  IF tagVal = 21 THEN
    LET fontSize = 12
    label_text#(lblStatus#, "Size: Medium")
  END IF
  IF tagVal = 22 THEN
    LET fontSize = 16
    label_text#(lblStatus#, "Size: Large")
  END IF
  memo_fontsize#(memo#, fontSize)
  PRINTLN "Font size: " + str$(fontSize)
END FUNCTION
FUNCTION OnClearClick(sender#)
  memo_text#(memo#, "")
  label_text#(lblStatus#, "Cleared")
  PRINTLN "Text cleared"
END FUNCTION
FUNCTION OnInfoClick(sender#) LOCAL text$, length
  LET text$ = memo_text$(memo#)
  LET length = len(text$)
  label_text#(lblStatus#, "Chars: " + str$(length))
  PRINTLN "Text length: " + str$(length) + " characters"
END FUNCTION
