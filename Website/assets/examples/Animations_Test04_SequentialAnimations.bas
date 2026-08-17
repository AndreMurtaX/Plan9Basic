' =============================================================================
' Test 4: Sequential and Chained Animations
' =============================================================================
' This test demonstrates:
' - Chaining animations using OnFinish callbacks
' - Creating animation sequences
' - Complex multi-step animations
' =============================================================================

let frm# = form#("Sequential Animations Demo", 500, 400)

' Status label
let lblStatus# = label#(frm#, "Click a button to start an animation sequence")
label_move#(lblStatus#, 10, 10)
label_autosize#(lblStatus#, 1)

' Step counter label
let lblStep# = label#(frm#, "Step: -")
label_move#(lblStep#, 10, 35)
label_autosize#(lblStep#, 1)

' Create the main animated rectangle
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 100, 80, 80)
rectangle_fill#(rect#, "Blue")
rectangle_corners#(rect#, 10, 10)

' Variables for animation state
let currentStep = 0

' -----------------------------------------------------------------------------
' Button 1: Square Path Animation (4 steps)
' -----------------------------------------------------------------------------
let btnSquare# = button#(frm#, "Square Path")
button_bounds#(btnSquare#, 10, 320, 100, 30)
button_onclick#(btnSquare#, "OnSquarePath")

function OnSquarePath(sender#) local ani#
  currentStep = 1
  label_text#(lblStatus#, "Running square path animation...")
  label_text#(lblStep#, "Step: 1 - Moving Right")
  
  ' Step 1: Move right
  let ani# = floatani#(rect#)
  floatani_propertyname#(ani#, "Position.X")
  floatani_startvalue#(ani#, 50)
  floatani_stopvalue#(ani#, 350)
  floatani_duration#(ani#, 1.0)
  floatani_interpolation#(ani#, "Quadratic")
  floatani_animationtype#(ani#, "InOut")
  floatani_onfinish#(ani#, "OnSquareStep2")
  floatani_start(ani#)
endfunction

function OnSquareStep2(sender#) local ani#
  currentStep = 2
  label_text#(lblStep#, "Step: 2 - Moving Down")
  
  ' Step 2: Move down
  ani# = floatani#(rect#)
  floatani_propertyname#(ani#, "Position.Y")
  floatani_startvalue#(ani#, 100)
  floatani_stopvalue#(ani#, 250)
  floatani_duration#(ani#, 1.0)
  floatani_interpolation#(ani#, "Quadratic")
  floatani_animationtype#(ani#, "InOut")
  floatani_onfinish#(ani#, "OnSquareStep3")
  floatani_start(ani#)
endfunction

function OnSquareStep3(sender#) local ani#
  currentStep = 3
  label_text#(lblStep#, "Step: 3 - Moving Left")
  
  ' Step 3: Move left
  ani# = floatani#(rect#)
  floatani_propertyname#(ani#, "Position.X")
  floatani_startvalue#(ani#, 350)
  floatani_stopvalue#(ani#, 50)
  floatani_duration#(ani#, 1.0)
  floatani_interpolation#(ani#, "Quadratic")
  floatani_animationtype#(ani#, "InOut")
  floatani_onfinish#(ani#, "OnSquareStep4")
  floatani_start(ani#)
endfunction

function OnSquareStep4(sender#) local ani#
  currentStep = 4
  label_text#(lblStep#, "Step: 4 - Moving Up")
  
  ' Step 4: Move up (back to start)
  ani# = floatani#(rect#)
  floatani_propertyname#(ani#, "Position.Y")
  floatani_startvalue#(ani#, 250)
  floatani_stopvalue#(ani#, 100)
  floatani_duration#(ani#, 1.0)
  floatani_interpolation#(ani#, "Quadratic")
  floatani_animationtype#(ani#, "InOut")
  floatani_onfinish#(ani#, "OnSquareComplete")
  floatani_start(ani#)
endfunction

function OnSquareComplete(sender#)
  currentStep = 0
  label_text#(lblStatus#, "Square path complete!")
  label_text#(lblStep#, "Step: Complete")
endfunction

' -----------------------------------------------------------------------------
' Button 2: Bounce Sequence (move + scale + color)
' -----------------------------------------------------------------------------
let btnBounce# = button#(frm#, "Bounce Seq")
button_bounds#(btnBounce#, 120, 320, 100, 30)
button_onclick#(btnBounce#, "OnBounceSeq")

function OnBounceSeq(sender#) local ani#
  label_text#(lblStatus#, "Running bounce sequence...")
  label_text#(lblStep#, "Step: 1 - Drop Down")
  
  ' Reset position
  rectangle_bounds#(rect#, 200, 80, 80, 80)
  
  ' Step 1: Drop down with bounce
  let ani# = floatani#(rect#)
  floatani_propertyname#(ani#, "Position.Y")
  floatani_startvalue#(ani#, 80)
  floatani_stopvalue#(ani#, 220)
  floatani_duration#(ani#, 1.0)
  floatani_interpolation#(ani#, "Bounce")
  floatani_animationtype#(ani#, "Out")
  floatani_onfinish#(ani#, "OnBounceStep2")
  floatani_start(ani#)
endfunction

function OnBounceStep2(sender#) local aniW#, aniH#
  label_text#(lblStep#, "Step: 2 - Squash")
  
  ' Step 2: Squash effect (make wider and shorter)
  aniW# = floatani#(rect#)
  floatani_propertyname#(aniW#, "Width")
  floatani_startvalue#(aniW#, 80)
  floatani_stopvalue#(aniW#, 120)
  floatani_duration#(aniW#, 0.15)
  floatani_start(aniW#)
  
  aniH# = floatani#(rect#)
  floatani_propertyname#(aniH#, "Height")
  floatani_startvalue#(aniH#, 80)
  floatani_stopvalue#(aniH#, 50)
  floatani_duration#(aniH#, 0.15)
  floatani_onfinish#(aniH#, "OnBounceStep3")
  floatani_start(aniH#)
endfunction

function OnBounceStep3(sender#) local aniW#, aniH#
  label_text#(lblStep#, "Step: 3 - Stretch")
  
  ' Step 3: Stretch back (return to normal)
  aniW# = floatani#(rect#)
  floatani_propertyname#(aniW#, "Width")
  floatani_startvalue#(aniW#, 120)
  floatani_stopvalue#(aniW#, 80)
  floatani_duration#(aniW#, 0.2)
  floatani_interpolation#(aniW#, "Elastic")
  floatani_animationtype#(aniW#, "Out")
  floatani_start(aniW#)
  
  aniH# = floatani#(rect#)
  floatani_propertyname#(aniH#, "Height")
  floatani_startvalue#(aniH#, 50)
  floatani_stopvalue#(aniH#, 80)
  floatani_duration#(aniH#, 0.2)
  floatani_interpolation#(aniH#, "Elastic")
  floatani_animationtype#(aniH#, "Out")
  floatani_onfinish#(aniH#, "OnBounceStep4")
  floatani_start(aniH#)
endfunction

function OnBounceStep4(sender#) local ani#
  label_text#(lblStep#, "Step: 4 - Color Flash")
  
  ' Step 4: Color flash
  ani# = colorani#(rect#)
  colorani_propertyname#(ani#, "Fill.Color")
  colorani_startvalue#(ani#, colortoalphacolor("Yellow"))
  colorani_stopvalue#(ani#, colortoalphacolor("Blue"))
  colorani_duration#(ani#, 0.5)
  colorani_onfinish#(ani#, "OnBounceComplete")
  colorani_start(ani#)
endfunction

function OnBounceComplete(sender#)
  label_text#(lblStatus#, "Bounce sequence complete!")
  label_text#(lblStep#, "Step: Complete")
endfunction

' -----------------------------------------------------------------------------
' Button 3: Fade and Move Sequence
' -----------------------------------------------------------------------------
let btnFadeMove# = button#(frm#, "Fade+Move")
button_bounds#(btnFadeMove#, 230, 320, 100, 30)
button_onclick#(btnFadeMove#, "OnFadeMove")

function OnFadeMove(sender#) local aniF#, aniX#
  label_text#(lblStatus#, "Running fade + move sequence...")
  label_text#(lblStep#, "Step: 1 - Fade out + Move")
  
  ' Reset
  rectangle_bounds#(rect#, 50, 100, 80, 80)
  rectangle_opacity#(rect#, 1.0)
  
  ' Fade out while moving right
  aniF# = floatani#(rect#)
  floatani_propertyname#(aniF#, "Opacity")
  floatani_startvalue#(aniF#, 1.0)
  floatani_stopvalue#(aniF#, 0.0)
  floatani_duration#(aniF#, 1.5)
  floatani_start(aniF#)
  
  aniX# = floatani#(rect#)
  floatani_propertyname#(aniX#, "Position.X")
  floatani_startvalue#(aniX#, 50)
  floatani_stopvalue#(aniX#, 350)
  floatani_duration#(aniX#, 1.5)
  floatani_onfinish#(aniX#, "OnFadeMoveStep2")
  floatani_start(aniX#)
endfunction

function OnFadeMoveStep2(sender#) local aniF#, aniX#
  label_text#(lblStep#, "Step: 2 - Fade in + Move back")
  
  ' Fade in while moving left
  aniF# = floatani#(rect#)
  floatani_propertyname#(aniF#, "Opacity")
  floatani_startvalue#(aniF#, 0.0)
  floatani_stopvalue#(aniF#, 1.0)
  floatani_duration#(aniF#, 1.5)
  floatani_start(aniF#)
  
  aniX# = floatani#(rect#)
  floatani_propertyname#(aniX#, "Position.X")
  floatani_startvalue#(aniX#, 350)
  floatani_stopvalue#(aniX#, 50)
  floatani_duration#(aniX#, 1.5)
  floatani_onfinish#(aniX#, "OnFadeMoveComplete")
  floatani_start(aniX#)
endfunction

function OnFadeMoveComplete(sender#)
  label_text#(lblStatus#, "Fade + Move sequence complete!")
  label_text#(lblStep#, "Step: Complete")
endfunction

' -----------------------------------------------------------------------------
' Button 4: Reset
' -----------------------------------------------------------------------------
let btnReset# = button#(frm#, "Reset")
button_bounds#(btnReset#, 340, 320, 100, 30)
button_onclick#(btnReset#, "OnReset")

function OnReset(sender#)
  rectangle_bounds#(rect#, 50, 100, 80, 80)
  rectangle_fill#(rect#, "Blue")
  rectangle_opacity#(rect#, 1.0)
  label_text#(lblStatus#, "Reset complete!")
  label_text#(lblStep#, "Step: -")
  currentStep = 0
endfunction

' Show the form
form_show(frm#)
