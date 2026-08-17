' =============================================================================
' SwitchLib Diagnostic Test
' =============================================================================
' Test 1: Switch with NO event callback (should still toggle)
' Test 2: Switch with event callback
' =============================================================================
LET frm# = form#("Switch Diagnostic", 350, 250)
' Test 1: Switch WITHOUT any callback
LET lbl1# = label#(frm#, "Test 1: No callback (click to toggle)")
label_move#(lbl1#, 20, 20)
label_width#(lbl1#, 250)
LET sw1# = switch#(frm#)
switch_parent#(sw1#, frm#)
switch_move#(sw1#, 20, 50)
switch_size#(sw1#, 70, 30)
' NO callback connected - switch should still work!
' Test 2: Switch WITH callback
LET lbl2# = label#(frm#, "Test 2: With callback")
label_move#(lbl2#, 20, 100)
label_width#(lbl2#, 250)
LET sw2# = switch#(frm#)
switch_move#(sw2#, 20, 130)
switch_size#(sw2#, 70, 30)
switch_onswitch#(sw2#, "OnSwitch2")
' Status label
LET lblStatus# = label#(frm#, "Click on switches to test...")
label_move#(lblStatus#, 20, 190)
label_width#(lblStatus#, 300)
form_show(frm#)
END
FUNCTION OnSwitch2(sender#) LOCAL state
  state = switch_ischecked(sender#)
  IF state = 1 THEN
    label_text#(lblStatus#, "Switch 2 is now ON")
    PRINTLN "Switch 2 turned ON"
  ELSE
    label_text#(lblStatus#, "Switch 2 is now OFF")
    PRINTLN "Switch 2 turned OFF"
  ENDIF
ENDFUNCTION
