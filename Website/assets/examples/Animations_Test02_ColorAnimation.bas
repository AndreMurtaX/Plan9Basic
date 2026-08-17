' =============================================================================
' Test 2: Color Animation Demo
' =============================================================================
' This test demonstrates color animations:
' - Color transitions on Fill.Color
' - Color cycling with loop and autoreverse
' - Multiple color animations
' =============================================================================

let frm# = form#("Color Animation Demo", 500, 450)

' Status label
let lblStatus# = label#(frm#, "Click a button to start a color animation")
label_move#(lblStatus#, 10, 10)
label_autosize#(lblStatus#, 1)

' Create rectangles to animate
let rect1# = rectangle#(frm#)
rectangle_bounds#(rect1#, 30, 60, 120, 80)
rectangle_fill#(rect1#, "Blue")
rectangle_corners#(rect1#, 10, 10)

let rect2# = rectangle#(frm#)
rectangle_bounds#(rect2#, 180, 60, 120, 80)
rectangle_fill#(rect2#, "Red")
rectangle_corners#(rect2#, 10, 10)

let rect3# = rectangle#(frm#)
rectangle_bounds#(rect3#, 330, 60, 120, 80)
rectangle_fill#(rect3#, "Green")
rectangle_corners#(rect3#, 10, 10)

' Labels for rectangles
let lbl1# = label#(frm#, "Rectangle 1")
label_move#(lbl1#, 50, 145)

let lbl2# = label#(frm#, "Rectangle 2")
label_move#(lbl2#, 200, 145)

let lbl3# = label#(frm#, "Rectangle 3")
label_move#(lbl3#, 350, 145)

' -----------------------------------------------------------------------------
' Button 1: Blue to Red transition
' -----------------------------------------------------------------------------
let btnBlueRed# = button#(frm#, "Blue -> Red")
button_bounds#(btnBlueRed#, 10, 180, 100, 30)
button_onclick#(btnBlueRed#, "OnBlueToRed")

function OnBlueToRed(sender#) local ani#
  label_text#(lblStatus#, "Animating Blue to Red...")
  
  ani# = colorani#(rect1#)
  colorani_propertyname#(ani#, "Fill.Color")
  colorani_startvalue#(ani#, colortoalphacolor("Blue"))
  colorani_stopvalue#(ani#, colortoalphacolor("Red"))
  colorani_duration#(ani#, 2.0)
  colorani_interpolation#(ani#, "Linear")
  colorani_onfinish#(ani#, "OnBlueToRedDone")
  colorani_start(ani#)
endfunction

function OnBlueToRedDone(sender#)
  label_text#(lblStatus#, "Blue to Red complete!")
endfunction

' -----------------------------------------------------------------------------
' Button 2: Red to Green transition
' -----------------------------------------------------------------------------
let btnRedGreen# = button#(frm#, "Red -> Green")
button_bounds#(btnRedGreen#, 120, 180, 100, 30)
button_onclick#(btnRedGreen#, "OnRedToGreen")

function OnRedToGreen(sender#) local ani#
  label_text#(lblStatus#, "Animating Red to Green...")
  
  ani# = colorani#(rect2#)
  colorani_propertyname#(ani#, "Fill.Color")
  colorani_startvalue#(ani#, colortoalphacolor("Red"))
  colorani_stopvalue#(ani#, colortoalphacolor("Green"))
  colorani_duration#(ani#, 2.0)
  colorani_interpolation#(ani#, "Linear")
  colorani_onfinish#(ani#, "OnRedToGreenDone")
  colorani_start(ani#)
endfunction

function OnRedToGreenDone(sender#)
  label_text#(lblStatus#, "Red to Green complete!")
endfunction

' -----------------------------------------------------------------------------
' Button 3: Green to Yellow transition
' -----------------------------------------------------------------------------
let btnGreenYellow# = button#(frm#, "Green -> Yellow")
button_bounds#(btnGreenYellow#, 230, 180, 110, 30)
button_onclick#(btnGreenYellow#, "OnGreenToYellow")

function OnGreenToYellow(sender#) local ani#
  label_text#(lblStatus#, "Animating Green to Yellow...")
  
  ani# = colorani#(rect3#)
  colorani_propertyname#(ani#, "Fill.Color")
  colorani_startvalue#(ani#, colortoalphacolor("Green"))
  colorani_stopvalue#(ani#, colortoalphacolor("Yellow"))
  colorani_duration#(ani#, 2.0)
  colorani_interpolation#(ani#, "Linear")
  colorani_onfinish#(ani#, "OnGreenToYellowDone")
  colorani_start(ani#)
endfunction

function OnGreenToYellowDone(sender#)
  label_text#(lblStatus#, "Green to Yellow complete!")
endfunction

' -----------------------------------------------------------------------------
' Button 4: Pulsing color (Loop + AutoReverse)
' -----------------------------------------------------------------------------
let pulseAni# = Pointer#(0)

let btnPulse# = button#(frm#, "Start Pulse")
button_bounds#(btnPulse#, 10, 230, 100, 30)
button_onclick#(btnPulse#, "OnStartPulse")

function OnStartPulse(sender#)
  label_text#(lblStatus#, "Pulsing color (loop + autoreverse)...")
  
  pulseAni# = colorani#(rect1#)
  colorani_propertyname#(pulseAni#, "Fill.Color")
  colorani_startvalue#(pulseAni#, colortoalphacolor("Blue"))
  colorani_stopvalue#(pulseAni#, colortoalphacolor("White"))
  colorani_duration#(pulseAni#, 0.8)
  colorani_loop#(pulseAni#, 1)
  colorani_autoreverse#(pulseAni#, 1)
  colorani_start(pulseAni#)
  
  button_text#(btnPulse#, "Stop Pulse")
  button_onclick#(btnPulse#, "OnStopPulse")
endfunction

function OnStopPulse(sender#)
  if PntToNum(pulseAni#) <> 0 then
    colorani_stop(pulseAni#)
  endif
  rectangle_fill#(rect1#, "Blue")
  label_text#(lblStatus#, "Pulse stopped")
  
  button_text#(btnPulse#, "Start Pulse")
  button_onclick#(btnPulse#, "OnStartPulse")
endfunction

' -----------------------------------------------------------------------------
' Button 5: All colors simultaneously
' -----------------------------------------------------------------------------
let btnAllColors# = button#(frm#, "Animate All")
button_bounds#(btnAllColors#, 120, 230, 100, 30)
button_onclick#(btnAllColors#, "OnAnimateAll")

function OnAnimateAll(sender#) local ani1#, ani2#, ani3#
  label_text#(lblStatus#, "Animating all rectangles...")
  
  ' First rectangle: Blue -> Orange
  ani1# = colorani#(rect1#)
  colorani_propertyname#(ani1#, "Fill.Color")
  colorani_startvalue#(ani1#, colortoalphacolor("Blue"))
  colorani_stopvalue#(ani1#, colortoalphacolor("Orange"))
  colorani_duration#(ani1#, 1.5)
  colorani_start(ani1#)
  
  ' Second rectangle: Red -> Purple
  ani2# = colorani#(rect2#)
  colorani_propertyname#(ani2#, "Fill.Color")
  colorani_startvalue#(ani2#, colortoalphacolor("Red"))
  colorani_stopvalue#(ani2#, colortoalphacolor("Purple"))
  colorani_duration#(ani2#, 1.5)
  colorani_start(ani2#)
  
  ' Third rectangle: Green -> Navy
  ani3# = colorani#(rect3#)
  colorani_propertyname#(ani3#, "Fill.Color")
  colorani_startvalue#(ani3#, colortoalphacolor("Green"))
  colorani_stopvalue#(ani3#, colortoalphacolor("Navy"))
  colorani_duration#(ani3#, 1.5)
  colorani_onfinish#(ani3#, "OnAnimateAllDone")
  colorani_start(ani3#)
endfunction

function OnAnimateAllDone(sender#)
  label_text#(lblStatus#, "All color animations complete!")
endfunction

' -----------------------------------------------------------------------------
' Button 6: Reset colors
' -----------------------------------------------------------------------------
let btnResetColors# = button#(frm#, "Reset Colors")
button_bounds#(btnResetColors#, 230, 230, 100, 30)
button_onclick#(btnResetColors#, "OnResetColors")

function OnResetColors(sender#)
  rectangle_fill#(rect1#, "Blue")
  rectangle_fill#(rect2#, "Red")
  rectangle_fill#(rect3#, "Green")
  label_text#(lblStatus#, "Colors reset!")
endfunction

' -----------------------------------------------------------------------------
' Create a large demo rectangle for stroke color animation
' -----------------------------------------------------------------------------
let lblStroke# = label#(frm#, "Stroke Color Animation:")
label_move#(lblStroke#, 10, 290)

let rectStroke# = rectangle#(frm#)
rectangle_bounds#(rectStroke#, 30, 320, 200, 80)
rectangle_fill#(rectStroke#, "White")
rectangle_stroke#(rectStroke#, "Black")
rectangle_strokethickness#(rectStroke#, 5)
rectangle_corners#(rectStroke#, 15, 15)

let btnStrokeAni# = button#(frm#, "Animate Stroke")
button_bounds#(btnStrokeAni#, 250, 340, 110, 30)
button_onclick#(btnStrokeAni#, "OnAnimateStroke")

function OnAnimateStroke(sender#) local ani#
  label_text#(lblStatus#, "Animating stroke color...")
  
  ani# = colorani#(rectStroke#)
  colorani_propertyname#(ani#, "Stroke.Color")
  colorani_startvalue#(ani#, colortoalphacolor("Black"))
  colorani_stopvalue#(ani#, colortoalphacolor("Red"))
  colorani_duration#(ani#, 2.0)
  colorani_autoreverse#(ani#, 1)
  colorani_onfinish#(ani#, "OnStrokeAnimDone")
  colorani_start(ani#)
endfunction

function OnStrokeAnimDone(sender#)
  label_text#(lblStatus#, "Stroke animation complete!")
endfunction

' Show the form
form_show(frm#)
