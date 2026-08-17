' =============================================================================
' demo_checkbox.bas - Interactive Demo for CheckBoxLib
' =============================================================================
' This demo showcases checkbox functionality in Plan9Basic:
' - Multiple checkboxes with different states
' - OnChange event handling
' - Dynamic state display
' - Enable/disable dependent controls
' =============================================================================
LET frm# = Pointer#(0)
LET lblStatus# = Pointer#(0)
LET lblOptions# = Pointer#(0)
' Option checkboxes
LET chkBold# = Pointer#(0)
LET chkItalic# = Pointer#(0)
LET chkUnderline# = Pointer#(0)
' Feature checkboxes
LET chkFeature1# = Pointer#(0)
LET chkFeature2# = Pointer#(0)
LET chkFeature3# = Pointer#(0)
' Master enable checkbox
LET chkEnableAll# = Pointer#(0)
' Sample text label
LET lblSample# = Pointer#(0)
LET lblFormat# = Pointer#(0)
LET lblFeatures# = Pointer#(0)
' Buttons
LET btnShowState# = Pointer#(0)
LET btnReset# = Pointer#(0)
LET btnClose# = Pointer#(0)
' Initialize the demo
InitDemo()
FUNCTION InitDemo()
  frm# = form#("CheckBox Demo", 500, 420)
  ' === Text Formatting Section ===
  LET lblFormat# = label#(frm#, "Text Formatting Options:")
  label_bounds#(lblFormat#, 20, 20, 200, 22)
  label_bold#(lblFormat#, 1)
  ' Bold checkbox
  chkBold# = checkbox#(frm#, "Bold")
  checkbox_bounds#(chkBold#, 30, 50, 100, 22)
  checkbox_onchange#(chkBold#, "OnFormatChanged")
  ' Italic checkbox
  chkItalic# = checkbox#(frm#, "Italic")
  checkbox_bounds#(chkItalic#, 30, 80, 100, 22)
  checkbox_onchange#(chkItalic#, "OnFormatChanged")
  ' Underline checkbox
  chkUnderline# = checkbox#(frm#, "Underline")
  checkbox_bounds#(chkUnderline#, 30, 110, 100, 22)
  checkbox_onchange#(chkUnderline#, "OnFormatChanged")
  ' Sample text label
  lblSample# = label#(frm#, "Sample Text Preview")
  label_bounds#(lblSample#, 180, 50, 200, 80)
  label_fontsize#(lblSample#, 18)
  ' === Feature Section ===
  LET lblFeatures# = label#(frm#, "Available Features:")
  label_bounds#(lblFeatures#, 20, 160, 200, 22)
  label_bold#(lblFeatures#, 1)
  ' Master checkbox
  chkEnableAll# = checkbox#(frm#, "Enable All Features")
  checkbox_bounds#(chkEnableAll#, 30, 190, 180, 22)
  checkbox_bold#(chkEnableAll#, 1)
  checkbox_onchange#(chkEnableAll#, "OnEnableAllChanged")
  ' Feature checkboxes
  chkFeature1# = checkbox#(frm#, "Auto-save documents")
  checkbox_bounds#(chkFeature1#, 50, 220, 200, 22)
  checkbox_onchange#(chkFeature1#, "OnFeatureChanged")
  chkFeature2# = checkbox#(frm#, "Spell checking")
  checkbox_bounds#(chkFeature2#, 50, 250, 200, 22)
  checkbox_onchange#(chkFeature2#, "OnFeatureChanged")
  chkFeature3# = checkbox#(frm#, "Dark mode")
  checkbox_bounds#(chkFeature3#, 50, 280, 200, 22)
  checkbox_onchange#(chkFeature3#, "OnFeatureChanged")
  ' === Status Section ===
  lblOptions# = label#(frm#, "Options:")
  label_bounds#(lblOptions#, 280, 160, 200, 22)
  label_bold#(lblOptions#, 1)
  lblStatus# = label#(frm#, "No features selected")
  label_bounds#(lblStatus#, 280, 190, 200, 120)
  label_fontcolor#(lblStatus#, "#0000FF")
  ' === Buttons ===
  btnShowState# = button#(frm#, "Show State")
  button_bounds#(btnShowState#, 20, 330, 120, 35)
  button_onclick#(btnShowState#, "OnShowState")
  btnReset# = button#(frm#, "Reset All")
  button_bounds#(btnReset#, 160, 330, 120, 35)
  button_onclick#(btnReset#, "OnReset")
  LET btnClose# = button#(frm#, "Close")
  button_bounds#(btnClose#, 360, 330, 100, 35)
  button_onclick#(btnClose#, "OnClose")
  form_show(frm#)
END FUNCTION
FUNCTION OnFormatChanged(sender#) LOCAL boldVal, italicVal, underVal
  ' Update the sample text formatting based on checkbox states
  boldVal = checkbox_ischecked(chkBold#)
  italicVal = checkbox_ischecked(chkItalic#)
  underVal = checkbox_ischecked(chkUnderline#)
  label_bold#(lblSample#, boldVal)
  label_italic#(lblSample#, italicVal)
  label_underline#(lblSample#, underVal)
  ' Log to console
  PRINTLN "Format changed - Bold: " + str$(boldVal) + ", Italic: " + str$(italicVal) + ", Underline: " + str$(underVal)
END FUNCTION
FUNCTION OnEnableAllChanged(sender#) LOCAL isEnabled
  ' Enable or disable all feature checkboxes
  isEnabled = checkbox_ischecked(chkEnableAll#)
  IF isEnabled = 1 THEN
    ' Enable all features
    checkbox_ischecked#(chkFeature1#, 1)
    checkbox_ischecked#(chkFeature2#, 1)
    checkbox_ischecked#(chkFeature3#, 1)
    PRINTLN "All features enabled"
  ELSE
    ' Disable all features
    checkbox_ischecked#(chkFeature1#, 0)
    checkbox_ischecked#(chkFeature2#, 0)
    checkbox_ischecked#(chkFeature3#, 0)
    PRINTLN "All features disabled"
  END IF
  UpdateStatus()
END FUNCTION
FUNCTION OnFeatureChanged(sender#) LOCAL f1, f2, f3, allChecked
  ' Check if all features are enabled to sync the master checkbox
  f1 = checkbox_ischecked(chkFeature1#)
  f2 = checkbox_ischecked(chkFeature2#)
  f3 = checkbox_ischecked(chkFeature3#)
  ' Determine if all are checked
  IF f1 = 1 THEN
    IF f2 = 1 THEN
      IF f3 = 1 THEN
        allChecked = 1
      ELSE
        allChecked = 0
      END IF
    ELSE
      allChecked = 0
    END IF
  ELSE
    allChecked = 0
  END IF
  ' Update master checkbox without triggering its OnChange
  checkbox_onchange#(chkEnableAll#, "")
  checkbox_ischecked#(chkEnableAll#, allChecked)
  checkbox_onchange#(chkEnableAll#, "OnEnableAllChanged")
  UpdateStatus()
END FUNCTION
FUNCTION UpdateStatus() LOCAL status$, count
  ' Build status string based on selected features
  status$ = ""
  count = 0
  IF checkbox_ischecked(chkFeature1#) = 1 THEN
    status$ = status$ + "- Auto-save" + chr$(10)
    count = count + 1
  END IF
  IF checkbox_ischecked(chkFeature2#) = 1 THEN
    status$ = status$ + "- Spell check" + chr$(10)
    count = count + 1
  END IF
  IF checkbox_ischecked(chkFeature3#) = 1 THEN
    status$ = status$ + "- Dark mode" + chr$(10)
    count = count + 1
  END IF
  IF count = 0 THEN
    label_text#(lblStatus#, "No features selected")
    label_fontcolor#(lblStatus#, "#808080")
  ELSE
    label_text#(lblStatus#, "Active (" + str$(count) + "):" + chr$(10) + status$)
    label_fontcolor#(lblStatus#, "#008000")
  END IF
END FUNCTION
FUNCTION OnShowState(sender#) LOCAL msg$
  ' Display current state of all checkboxes
  PRINTLN ""
  PRINTLN "=== Current Checkbox States ==="
  PRINTLN "Text Formatting:"
  PRINTLN "  Bold:      " + IIF$(checkbox_ischecked(chkBold#), "ON", "OFF")
  PRINTLN "  Italic:    " + IIF$(checkbox_ischecked(chkItalic#), "ON", "OFF")
  PRINTLN "  Underline: " + IIF$(checkbox_ischecked(chkUnderline#), "ON", "OFF")
  PRINTLN ""
  PRINTLN "Features:"
  PRINTLN "  Enable All: " + IIF$(checkbox_ischecked(chkEnableAll#), "ON", "OFF")
  PRINTLN "  Auto-save:  " + IIF$(checkbox_ischecked(chkFeature1#), "ON", "OFF")
  PRINTLN "  Spell check:" + IIF$(checkbox_ischecked(chkFeature2#), "ON", "OFF")
  PRINTLN "  Dark mode:  " + IIF$(checkbox_ischecked(chkFeature3#), "ON", "OFF")
  PRINTLN "================================"
END FUNCTION
FUNCTION IIF$(condition, trueVal$, falseVal$)
  IF condition = 1 THEN
    RETURN trueVal$
  ELSE
    RETURN falseVal$
  END IF
END FUNCTION
FUNCTION OnReset(sender#)
  ' Reset all checkboxes to unchecked
  ' Temporarily disable OnChange to avoid cascading events
  checkbox_onchange#(chkBold#, "")
  checkbox_onchange#(chkItalic#, "")
  checkbox_onchange#(chkUnderline#, "")
  checkbox_onchange#(chkEnableAll#, "")
  checkbox_onchange#(chkFeature1#, "")
  checkbox_onchange#(chkFeature2#, "")
  checkbox_onchange#(chkFeature3#, "")
  ' Reset states
  checkbox_ischecked#(chkBold#, 0)
  checkbox_ischecked#(chkItalic#, 0)
  checkbox_ischecked#(chkUnderline#, 0)
  checkbox_ischecked#(chkEnableAll#, 0)
  checkbox_ischecked#(chkFeature1#, 0)
  checkbox_ischecked#(chkFeature2#, 0)
  checkbox_ischecked#(chkFeature3#, 0)
  ' Reset sample text formatting
  label_bold#(lblSample#, 0)
  label_italic#(lblSample#, 0)
  label_underline#(lblSample#, 0)
  ' Re-enable OnChange callbacks
  checkbox_onchange#(chkBold#, "OnFormatChanged")
  checkbox_onchange#(chkItalic#, "OnFormatChanged")
  checkbox_onchange#(chkUnderline#, "OnFormatChanged")
  checkbox_onchange#(chkEnableAll#, "OnEnableAllChanged")
  checkbox_onchange#(chkFeature1#, "OnFeatureChanged")
  checkbox_onchange#(chkFeature2#, "OnFeatureChanged")
  checkbox_onchange#(chkFeature3#, "OnFeatureChanged")
  UpdateStatus()
  PRINTLN "All checkboxes reset"
END FUNCTION
FUNCTION OnClose(sender#)
  form_close(frm#)
END FUNCTION
