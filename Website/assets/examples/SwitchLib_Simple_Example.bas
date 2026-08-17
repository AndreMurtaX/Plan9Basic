' =============================================================================
' SwitchLib Simple Example - Basic Switch Usage
' =============================================================================
' This example demonstrates basic switch control usage.
' =============================================================================
' Create form and switch
LET frm# = form#("Switch Demo", 300, 200)
' Add a label
LET lbl# = label#(frm#, "Feature Status: OFF")
label_move#(lbl#, 50, 30)
label_width#(lbl#, 200)
label_fontsize#(lbl#, 14)
' Create the switch
LET sw# = switch#(frm#)
switch_move#(sw#, 100, 80)
switch_onswitch#(sw#, "OnSwitched")
' Show the form
form_show(frm#)
END 'Main applet ending
' Callback when switch state changes
FUNCTION OnSwitched(sender#) LOCAL state
  state = switch_ischecked(sender#)
  IF state = 1 THEN
    label_text#(lbl#, "Feature Status: ON")
    PRINTLN "Switch turned ON"
  ELSE
    label_text#(lbl#, "Feature Status: OFF")
    PRINTLN "Switch turned OFF"
  END IF
END FUNCTION
