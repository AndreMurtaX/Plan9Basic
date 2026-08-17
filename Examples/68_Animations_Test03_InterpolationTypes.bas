' =============================================================================
' Test 3: Interpolation Types Demo
' =============================================================================
' This test demonstrates different interpolation types:
' - Linear, Quadratic, Cubic, Elastic, Bounce, Back
' Each ball moves from left to right with a different interpolation
' =============================================================================

let frm# = form#("Interpolation Types Demo", 600, 500)

' Status label
let lblStatus# = label#(frm#, "Click 'Start All' to compare interpolation types")
label_move#(lblStatus#, 10, 10)
label_autosize#(lblStatus#, 1)

' Define Y positions for each row
let startX = 50
let endX = 500
let ballSize = 30

' Create circles for each interpolation type
' Row 1: Linear
let lblLinear# = label#(frm#, "Linear:")
label_move#(lblLinear#, 10, 55)
let circLinear# = circle#(frm#)
circle_bounds#(circLinear#, startX, 50, ballSize, ballSize)
circle_fill#(circLinear#, "Red")

' Row 2: Quadratic
let lblQuadratic# = label#(frm#, "Quadratic:")
label_move#(lblQuadratic#, 10, 105)
let circQuadratic# = circle#(frm#)
circle_bounds#(circQuadratic#, startX, 100, ballSize, ballSize)
circle_fill#(circQuadratic#, "Orange")

' Row 3: Cubic
let lblCubic# = label#(frm#, "Cubic:")
label_move#(lblCubic#, 10, 155)
let circCubic# = circle#(frm#)
circle_bounds#(circCubic#, startX, 150, ballSize, ballSize)
circle_fill#(circCubic#, "Yellow")

' Row 4: Sinusoidal
let lblSinusoidal# = label#(frm#, "Sinusoidal:")
label_move#(lblSinusoidal#, 10, 205)
let circSinusoidal# = circle#(frm#)
circle_bounds#(circSinusoidal#, startX, 200, ballSize, ballSize)
circle_fill#(circSinusoidal#, "Green")

' Row 5: Elastic
let lblElastic# = label#(frm#, "Elastic:")
label_move#(lblElastic#, 10, 255)
let circElastic# = circle#(frm#)
circle_bounds#(circElastic#, startX, 250, ballSize, ballSize)
circle_fill#(circElastic#, "Blue")

' Row 6: Back
let lblBack# = label#(frm#, "Back:")
label_move#(lblBack#, 10, 305)
let circBack# = circle#(frm#)
circle_bounds#(circBack#, startX, 300, ballSize, ballSize)
circle_fill#(circBack#, "Purple")

' Row 7: Bounce
let lblBounce# = label#(frm#, "Bounce:")
label_move#(lblBounce#, 10, 355)
let circBounce# = circle#(frm#)
circle_bounds#(circBounce#, startX, 350, ballSize, ballSize)
circle_fill#(circBounce#, "Navy")

' Row 8: Exponential
let lblExponential# = label#(frm#, "Exponential:")
label_move#(lblExponential#, 10, 405)
let circExponential# = circle#(frm#)
circle_bounds#(circExponential#, startX, 400, ballSize, ballSize)
circle_fill#(circExponential#, "Maroon")

' -----------------------------------------------------------------------------
' Button: Start All Animations
' -----------------------------------------------------------------------------
let btnStartAll# = button#(frm#, "Start All")
button_bounds#(btnStartAll#, 250, 450, 100, 35)
button_onclick#(btnStartAll#, "OnStartAll")

function OnStartAll(sender#) local ani#, duration
  label_text#(lblStatus#, "Running all interpolation types...")
  duration = 3.0
  
  ' Linear
  ani# = floatani#(circLinear#)
  floatani_propertyname#(ani#, "Position.X")
  floatani_startvalue#(ani#, startX)
  floatani_stopvalue#(ani#, endX)
  floatani_duration#(ani#, duration)
  floatani_interpolation#(ani#, "Linear")
  floatani_animationtype#(ani#, "InOut")
  floatani_start(ani#)
  
  ' Quadratic
  ani# = floatani#(circQuadratic#)
  floatani_propertyname#(ani#, "Position.X")
  floatani_startvalue#(ani#, startX)
  floatani_stopvalue#(ani#, endX)
  floatani_duration#(ani#, duration)
  floatani_interpolation#(ani#, "Quadratic")
  floatani_animationtype#(ani#, "InOut")
  floatani_start(ani#)
  
  ' Cubic
  ani# = floatani#(circCubic#)
  floatani_propertyname#(ani#, "Position.X")
  floatani_startvalue#(ani#, startX)
  floatani_stopvalue#(ani#, endX)
  floatani_duration#(ani#, duration)
  floatani_interpolation#(ani#, "Cubic")
  floatani_animationtype#(ani#, "InOut")
  floatani_start(ani#)
  
  ' Sinusoidal
  ani# = floatani#(circSinusoidal#)
  floatani_propertyname#(ani#, "Position.X")
  floatani_startvalue#(ani#, startX)
  floatani_stopvalue#(ani#, endX)
  floatani_duration#(ani#, duration)
  floatani_interpolation#(ani#, "Sinusoidal")
  floatani_animationtype#(ani#, "InOut")
  floatani_start(ani#)
  
  ' Elastic
  ani# = floatani#(circElastic#)
  floatani_propertyname#(ani#, "Position.X")
  floatani_startvalue#(ani#, startX)
  floatani_stopvalue#(ani#, endX)
  floatani_duration#(ani#, duration)
  floatani_interpolation#(ani#, "Elastic")
  floatani_animationtype#(ani#, "Out")
  floatani_start(ani#)
  
  ' Back
  ani# = floatani#(circBack#)
  floatani_propertyname#(ani#, "Position.X")
  floatani_startvalue#(ani#, startX)
  floatani_stopvalue#(ani#, endX)
  floatani_duration#(ani#, duration)
  floatani_interpolation#(ani#, "Back")
  floatani_animationtype#(ani#, "Out")
  floatani_start(ani#)
  
  ' Bounce
  ani# = floatani#(circBounce#)
  floatani_propertyname#(ani#, "Position.X")
  floatani_startvalue#(ani#, startX)
  floatani_stopvalue#(ani#, endX)
  floatani_duration#(ani#, duration)
  floatani_interpolation#(ani#, "Bounce")
  floatani_animationtype#(ani#, "Out")
  floatani_start(ani#)
  
  ' Exponential
  ani# = floatani#(circExponential#)
  floatani_propertyname#(ani#, "Position.X")
  floatani_startvalue#(ani#, startX)
  floatani_stopvalue#(ani#, endX)
  floatani_duration#(ani#, duration)
  floatani_interpolation#(ani#, "Exponential")
  floatani_animationtype#(ani#, "InOut")
  floatani_onfinish#(ani#, "OnAllDone")
  floatani_start(ani#)
endfunction

function OnAllDone(sender#)
  label_text#(lblStatus#, "All animations complete! Click 'Reset' to try again.")
endfunction

' -----------------------------------------------------------------------------
' Button: Reset
' -----------------------------------------------------------------------------
let btnReset# = button#(frm#, "Reset")
button_bounds#(btnReset#, 360, 450, 100, 35)
button_onclick#(btnReset#, "OnReset")

function OnReset(sender#)
  circle_move#(circLinear#, startX, 50)
  circle_move#(circQuadratic#, startX, 100)
  circle_move#(circCubic#, startX, 150)
  circle_move#(circSinusoidal#, startX, 200)
  circle_move#(circElastic#, startX, 250)
  circle_move#(circBack#, startX, 300)
  circle_move#(circBounce#, startX, 350)
  circle_move#(circExponential#, startX, 400)
  label_text#(lblStatus#, "Reset complete! Click 'Start All' to run again.")
endfunction

' Show the form
form_show(frm#)
