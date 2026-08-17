' =============================================================================
' Test 1: Basic Float Animation Demo
' =============================================================================
' This test demonstrates basic float animations:
' - Fade in/out (Opacity)
' - Movement (Position.X, Position.Y)
' - Resize (Width, Height)
' =============================================================================

let frm# = form#("Float Animation Demo", 500, 400)

' Create a label for status
let lblStatus# = label#(frm#, "Click a button to start an animation")
label_move#(lblStatus#, 10, 10)
label_autosize#(lblStatus#, 1)

' Create a rectangle to animate
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 80, 150, 100)
rectangle_fill#(rect#, "Blue")
rectangle_stroke#(rect#, "Navy")
rectangle_strokethickness#(rect#, 2)

' -----------------------------------------------------------------------------
' Button 1: Fade Out Animation
' -----------------------------------------------------------------------------
let btnFadeOut# = button#(frm#, "Fade Out")
button_bounds#(btnFadeOut#, 10, 320, 90, 30)
button_onclick#(btnFadeOut#, "OnFadeOut")

function OnFadeOut(sender#) local ani#
  label_text#(lblStatus#, "Fading out...")
  
  ani# = floatani#(rect#)
  floatani_propertyname#(ani#, "Opacity")
  floatani_startvalue#(ani#, 1.0)
  floatani_stopvalue#(ani#, 0.0)
  floatani_duration#(ani#, 2.0)
  floatani_interpolation#(ani#, "Quadratic")
  floatani_animationtype#(ani#, "Out")
  floatani_onfinish#(ani#, "OnFadeOutDone")
  floatani_start(ani#)
endfunction

function OnFadeOutDone(sender#)
  label_text#(lblStatus#, "Fade out complete!")
endfunction

' -----------------------------------------------------------------------------
' Button 2: Fade In Animation
' -----------------------------------------------------------------------------
let btnFadeIn# = button#(frm#, "Fade In")
button_bounds#(btnFadeIn#, 110, 320, 90, 30)
button_onclick#(btnFadeIn#, "OnFadeIn")

function OnFadeIn(sender#) local ani#
  label_text#(lblStatus#, "Fading in...")
  
  ani# = floatani#(rect#)
  floatani_propertyname#(ani#, "Opacity")
  floatani_startvalue#(ani#, 0.0)
  floatani_stopvalue#(ani#, 1.0)
  floatani_duration#(ani#, 2.0)
  floatani_interpolation#(ani#, "Quadratic")
  floatani_animationtype#(ani#, "Out")
  floatani_onfinish#(ani#, "OnFadeInDone")
  floatani_start(ani#)
endfunction

function OnFadeInDone(sender#)
  label_text#(lblStatus#, "Fade in complete!")
endfunction

' -----------------------------------------------------------------------------
' Button 3: Move Right Animation
' -----------------------------------------------------------------------------
let btnMoveRight# = button#(frm#, "Move Right")
button_bounds#(btnMoveRight#, 210, 320, 90, 30)
button_onclick#(btnMoveRight#, "OnMoveRight")

function OnMoveRight(sender#) local ani#
  label_text#(lblStatus#, "Moving right...")
  
  ani# = floatani#(rect#)
  floatani_propertyname#(ani#, "Position.X")
  floatani_startvalue#(ani#, 50)
  floatani_stopvalue#(ani#, 300)
  floatani_duration#(ani#, 1.5)
  floatani_interpolation#(ani#, "Cubic")
  floatani_animationtype#(ani#, "InOut")
  floatani_onfinish#(ani#, "OnMoveRightDone")
  floatani_start(ani#)
endfunction

function OnMoveRightDone(sender#)
  label_text#(lblStatus#, "Move right complete!")
endfunction

' -----------------------------------------------------------------------------
' Button 4: Move Left Animation
' -----------------------------------------------------------------------------
let btnMoveLeft# = button#(frm#, "Move Left")
button_bounds#(btnMoveLeft#, 310, 320, 90, 30)
button_onclick#(btnMoveLeft#, "OnMoveLeft")

function OnMoveLeft(sender#) local ani#
  label_text#(lblStatus#, "Moving left...")
  
  ani# = floatani#(rect#)
  floatani_propertyname#(ani#, "Position.X")
  floatani_startvalue#(ani#, 300)
  floatani_stopvalue#(ani#, 50)
  floatani_duration#(ani#, 1.5)
  floatani_interpolation#(ani#, "Cubic")
  floatani_animationtype#(ani#, "InOut")
  floatani_onfinish#(ani#, "OnMoveLeftDone")
  floatani_start(ani#)
endfunction

function OnMoveLeftDone(sender#)
  label_text#(lblStatus#, "Move left complete!")
endfunction

' -----------------------------------------------------------------------------
' Button 5: Grow Animation
' -----------------------------------------------------------------------------
let btnGrow# = button#(frm#, "Grow")
button_bounds#(btnGrow#, 410, 320, 70, 30)
button_onclick#(btnGrow#, "OnGrow")

function OnGrow(sender#) local aniW#, aniH#
  label_text#(lblStatus#, "Growing...")
  
  ' Animate width
  aniW# = floatani#(rect#)
  floatani_propertyname#(aniW#, "Width")
  floatani_startvalue#(aniW#, 150)
  floatani_stopvalue#(aniW#, 250)
  floatani_duration#(aniW#, 1.0)
  floatani_interpolation#(aniW#, "Elastic")
  floatani_animationtype#(aniW#, "Out")
  floatani_start(aniW#)
  
  ' Animate height simultaneously
  aniH# = floatani#(rect#)
  floatani_propertyname#(aniH#, "Height")
  floatani_startvalue#(aniH#, 100)
  floatani_stopvalue#(aniH#, 180)
  floatani_duration#(aniH#, 1.0)
  floatani_interpolation#(aniH#, "Elastic")
  floatani_animationtype#(aniH#, "Out")
  floatani_onfinish#(aniH#, "OnGrowDone")
  floatani_start(aniH#)
endfunction

function OnGrowDone(sender#)
  label_text#(lblStatus#, "Grow complete!")
endfunction

' -----------------------------------------------------------------------------
' Button 6: Reset
' -----------------------------------------------------------------------------
let btnReset# = button#(frm#, "Reset")
button_bounds#(btnReset#, 10, 360, 90, 30)
button_onclick#(btnReset#, "OnReset")

function OnReset(sender#)
  rectangle_bounds#(rect#, 50, 80, 150, 100)
  rectangle_opacity#(rect#, 1.0)
  label_text#(lblStatus#, "Reset complete!")
endfunction

' Show the form
form_show(frm#)
