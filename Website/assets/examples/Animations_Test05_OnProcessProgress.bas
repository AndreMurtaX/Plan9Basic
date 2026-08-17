' =============================================================================
' Test 5: OnProcess Callback and Progress Demo
' =============================================================================
' This test demonstrates:
' - Using OnProcess callback to track animation progress
' - Updating UI elements during animation
' - Progress bar simulation
' =============================================================================

let frm# = form#("Animation Progress Demo", 500, 350)

' Status label
let lblStatus# = label#(frm#, "Click 'Start' to begin animation with progress tracking")
label_move#(lblStatus#, 10, 10)
label_autosize#(lblStatus#, 1)

' Progress percentage label
let lblPercent# = label#(frm#, "Progress: 0%")
label_move#(lblPercent#, 10, 40)
label_autosize#(lblPercent#, 1)

' Create a progress bar background
let progressBg# = rectangle#(frm#)
rectangle_bounds#(progressBg#, 20, 80, 460, 30)
rectangle_fill#(progressBg#, "Silver")
rectangle_corners#(progressBg#, 5, 5)

' Create a progress bar fill
let progressFill# = rectangle#(frm#)
rectangle_bounds#(progressFill#, 22, 82, 0, 26)
rectangle_fill#(progressFill#, "Green")
rectangle_corners#(progressFill#, 3, 3)

' Create an animated circle that moves across
let circle# = circle#(frm#)
circle_bounds#(circle#, 20, 140, 50, 50)
circle_fill#(circle#, "Blue")

' Store the animation pointer for OnProcess access
let progressAni# = Pointer#(0)
let maxProgressWidth = 456

' -----------------------------------------------------------------------------
' Button: Start Animation
' -----------------------------------------------------------------------------
let btnStart# = button#(frm#, "Start")
button_bounds#(btnStart#, 150, 280, 100, 35)
button_onclick#(btnStart#, "OnStart")

function OnStart(sender#)
  label_text#(lblStatus#, "Animation running...")
  label_text#(lblPercent#, "Progress: 0%")
  rectangle_width#(progressFill#, 0)
  circle_move#(circle#, 20, 140)
  
  ' Create and start animation
  progressAni# = floatani#(circle#)
  floatani_propertyname#(progressAni#, "Position.X")
  floatani_startvalue#(progressAni#, 20)
  floatani_stopvalue#(progressAni#, 430)
  floatani_duration#(progressAni#, 5.0)
  floatani_interpolation#(progressAni#, "Linear")
  floatani_onprocess#(progressAni#, "OnAnimProgress")
  floatani_onfinish#(progressAni#, "OnAnimComplete")
  floatani_start(progressAni#)
  
  button_enabled#(btnStart#, 0)
endfunction

function OnAnimProgress(sender#) local progress, percent, barWidth
  ' Get normalized time (0.0 to 1.0)
  progress = floatani_normalizedtime(sender#)
  
  ' Calculate percentage
  percent = int(progress * 100)
  
  ' Update percentage label
  label_text#(lblPercent#, "Progress: " + str$(percent) + "%")
  
  ' Update progress bar width
  barWidth = progress * maxProgressWidth
  rectangle_width#(progressFill#, barWidth)
endfunction

function OnAnimComplete(sender#)
  label_text#(lblStatus#, "Animation complete!")
  label_text#(lblPercent#, "Progress: 100%")
  rectangle_width#(progressFill#, maxProgressWidth)
  button_enabled#(btnStart#, 1)
endfunction

' -----------------------------------------------------------------------------
' Button: Reset
' -----------------------------------------------------------------------------
let btnReset# = button#(frm#, "Reset")
button_bounds#(btnReset#, 260, 280, 100, 35)
button_onclick#(btnReset#, "OnReset")

function OnReset(sender#)
  ' Stop animation if running
  if PntToNum(progressAni#) <> 0 then
    if floatani_running(progressAni#) <> 0 then
      floatani_stop(progressAni#)
    endif
  endif
  
  ' Reset UI
  circle_move#(circle#, 20, 140)
  rectangle_width#(progressFill#, 0)
  label_text#(lblStatus#, "Reset complete!")
  label_text#(lblPercent#, "Progress: 0%")
  button_enabled#(btnStart#, 1)
endfunction

' -----------------------------------------------------------------------------
' Section 2: Color Progress Demo
' -----------------------------------------------------------------------------
let lblSection2# = label#(frm#, "Color Animation Progress:")
label_move#(lblSection2#, 10, 210)

let colorRect# = rectangle#(frm#)
rectangle_bounds#(colorRect#, 20, 235, 150, 30)
rectangle_fill#(colorRect#, "Blue")
rectangle_corners#(colorRect#, 5, 5)

let lblColorProgress# = label#(frm#, "0%")
label_move#(lblColorProgress#, 180, 240)

let colorAni# = Pointer#(0)

let btnColorStart# = button#(frm#, "Color Progress")
button_bounds#(btnColorStart#, 250, 235, 110, 30)
button_onclick#(btnColorStart#, "OnColorStart")

function OnColorStart(sender#)
  rectangle_fill#(colorRect#, "Blue")
  label_text#(lblColorProgress#, "0%")
  
  colorAni# = colorani#(colorRect#)
  colorani_propertyname#(colorAni#, "Fill.Color")
  colorani_startvalue#(colorAni#, colortoalphacolor("Blue"))
  colorani_stopvalue#(colorAni#, colortoalphacolor("Red"))
  colorani_duration#(colorAni#, 3.0)
  colorani_onprocess#(colorAni#, "OnColorProgress")
  colorani_onfinish#(colorAni#, "OnColorComplete")
  colorani_start(colorAni#)
endfunction

function OnColorProgress(sender#) local progress, percent
  progress = colorani_normalizedtime(sender#)
  percent = int(progress * 100)
  label_text#(lblColorProgress#, str$(percent) + "%")
endfunction

function OnColorComplete(sender#)
  label_text#(lblColorProgress#, "100% - Done!")
endfunction

' Show the form
form_show(frm#)
