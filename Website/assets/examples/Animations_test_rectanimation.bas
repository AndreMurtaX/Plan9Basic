' =============================================================================
' RectAnimationLib Test Suite (v2)
' Tests bounds-based animations (position + size)
' NOTE: rectani_propertyname# removed in v2 - not needed
' =============================================================================

' Module-level variables
let frm# = Pointer#(0)
let statusLbl# = Pointer#(0)
let rect1# = Pointer#(0)
let rect2# = Pointer#(0)
let rect3# = Pointer#(0)
let rect4# = Pointer#(0)
let ani1# = Pointer#(0)
let ani2# = Pointer#(0)
let ani3# = Pointer#(0)
let ani4# = Pointer#(0)
let panel1# = Pointer#(0)
let panel2# = Pointer#(0)
let panel3# = Pointer#(0)
let panel4# = Pointer#(0)
let btn1# = Pointer#(0)
let btn2# = Pointer#(0)
let btn3# = Pointer#(0)
let expandState = 0

' -----------------------------------------------------------------------------
' Main Program
' -----------------------------------------------------------------------------
println "RectAnimationLib Test Suite (v2)"
println "================================="
println ""

gosub CreateUI
gosub CreateAnimations

form_show(frm#)

println ""
println "Test applet running. Close the window to exit."
end

' -----------------------------------------------------------------------------
' Create User Interface
' -----------------------------------------------------------------------------
CreateUI:
  frm# = form#("RectAnimationLib Test Suite", 800, 650)
  
  ' Status label at top
  statusLbl# = label#(frm#, "Rectangle/Bounds Animation Tests", 10, 10, 780, 25)
  
  ' Panel 1: Move and resize
  panel1# = panel#(frm#, 10, 45, 385, 250)
  let lbl1# = label#(panel1#, "1. Move + Resize (Looping AutoReverse)", 5, 5, 375, 20)
  
  rect1# = rectangle#(panel1#)
  rectangle_bounds#(rect1#, 30, 40, 60, 60)
  rectangle_fill#(rect1#, "CornflowerBlue")
  rectangle_stroke#(rect1#, "Navy")
  rectangle_strokethickness#(rect1#, 2)
  rectangle_xradius#(rect1#, 5)
  rectangle_yradius#(rect1#, 5)
  
  ' Panel 2: Bounce expansion
  panel2# = panel#(frm#, 405, 45, 385, 250)
  let lbl2# = label#(panel2#, "2. Bounce Expansion (Click button)", 5, 5, 375, 20)
  
  rect2# = rectangle#(panel2#)
  rectangle_bounds#(rect2#, 140, 80, 100, 80)
  rectangle_fill#(rect2#, "LimeGreen")
  rectangle_stroke#(rect2#, "DarkGreen")
  rectangle_strokethickness#(rect2#, 2)
  rectangle_xradius#(rect2#, 10)
  rectangle_yradius#(rect2#, 10)
  
  btn1# = button#(panel2#, "Expand/Collapse", 10, 215, 120, 30)
  button_onclick#(btn1#, "OnExpandClick")
  
  ' Panel 3: Elastic effect
  panel3# = panel#(frm#, 10, 305, 385, 250)
  let lbl3# = label#(panel3#, "3. Elastic Effect (Looping)", 5, 5, 375, 20)
  
  rect3# = ellipse#(panel3#)
  ellipse_bounds#(rect3#, 150, 100, 80, 80)
  ellipse_fill#(rect3#, "Tomato")
  ellipse_stroke#(rect3#, "DarkRed")
  ellipse_strokethickness#(rect3#, 2)
  
  ' Panel 4: Window open/close simulation
  panel4# = panel#(frm#, 405, 305, 385, 250)
  let lbl4# = label#(panel4#, "4. Window Open Effect (Click button)", 5, 5, 375, 20)
  
  rect4# = rectangle#(panel4#)
  rectangle_bounds#(rect4#, 190, 120, 0, 0)
  rectangle_fill#(rect4#, "Gold")
  rectangle_stroke#(rect4#, "DarkOrange")
  rectangle_strokethickness#(rect4#, 3)
  rectangle_xradius#(rect4#, 8)
  rectangle_yradius#(rect4#, 8)
  rectangle_visible#(rect4#, 0)
  
  btn2# = button#(panel4#, "Open", 10, 215, 80, 30)
  button_onclick#(btn2#, "OnOpenClick")
  
  btn3# = button#(panel4#, "Close", 100, 215, 80, 30)
  button_onclick#(btn3#, "OnCloseClick")
  button_enabled#(btn3#, 0)
  
  ' Control buttons at bottom
  let startAllBtn# = button#(frm#, "Start Auto Animations", 10, 565, 150, 35)
  button_onclick#(startAllBtn#, "OnStartAllClick")
  
  let stopAllBtn# = button#(frm#, "Stop All", 170, 565, 150, 35)
  button_onclick#(stopAllBtn#, "OnStopAllClick")
return

' -----------------------------------------------------------------------------
' Create Animations (v2 - no propertyname needed)
' -----------------------------------------------------------------------------
CreateAnimations:
  ' Animation 1: Move and resize with autoreverse
  ani1# = rectani#(rect1#)
  rectani_startbounds#(ani1#, 30, 40, 60, 60)
  rectani_stopbounds#(ani1#, 280, 140, 80, 80)
  rectani_duration#(ani1#, 2.0)
  rectani_loop#(ani1#, 1)
  rectani_autoreverse#(ani1#, 1)
  rectani_interpolation#(ani1#, "Quadratic")
  rectani_animationtype#(ani1#, "InOut")
  
  println "Animation 1 created: Move + Resize"
  println "  Start: (30, 40, 60x60)"
  println "  Stop:  (280, 140, 80x80)"
  println "  Duration: 2.0s, Loop: On, AutoReverse: On"
  
  ' Animation 2: Bounce expansion
  ani2# = rectani#(rect2#)
  rectani_startbounds#(ani2#, 140, 80, 100, 80)
  rectani_stopbounds#(ani2#, 40, 40, 300, 160)
  rectani_duration#(ani2#, 0.8)
  rectani_interpolation#(ani2#, "Bounce")
  rectani_animationtype#(ani2#, "Out")
  rectani_onfinish#(ani2#, "OnBounceFinish")
  
  println ""
  println "Animation 2 created: Bounce Expansion"
  println "  Start: (140, 80, 100x80)"
  println "  Stop:  (40, 40, 300x160)"
  println "  Interpolation: Bounce"
  
  ' Animation 3: Elastic pulsing
  ani3# = rectani#(rect3#)
  rectani_startbounds#(ani3#, 150, 100, 80, 80)
  rectani_stopbounds#(ani3#, 100, 60, 180, 160)
  rectani_duration#(ani3#, 1.5)
  rectani_loop#(ani3#, 1)
  rectani_autoreverse#(ani3#, 1)
  rectani_interpolation#(ani3#, "Elastic")
  rectani_animationtype#(ani3#, "Out")
  
  println ""
  println "Animation 3 created: Elastic Pulse"
  println "  Interpolation: Elastic, AutoReverse: On"
  
  ' Animation 4: Window open effect
  ani4# = rectani#(rect4#)
  rectani_startbounds#(ani4#, 190, 120, 0, 0)
  rectani_stopbounds#(ani4#, 40, 40, 300, 160)
  rectani_duration#(ani4#, 0.4)
  rectani_interpolation#(ani4#, "Back")
  rectani_animationtype#(ani4#, "Out")
  rectani_onfinish#(ani4#, "OnWindowAnimFinish")
  
  println ""
  println "Animation 4 created: Window Open"
  println "  Uses Back interpolation for overshoot effect"
return

' -----------------------------------------------------------------------------
' Button Click Handlers
' -----------------------------------------------------------------------------
function OnStartAllClick(sender#)
  rectani_start(ani1#)
  rectani_start(ani3#)
  label_text#(statusLbl#, "Auto-looping animations started")
endfunction

function OnStopAllClick(sender#)
  rectani_stop(ani1#)
  rectani_stop(ani2#)
  rectani_stop(ani3#)
  rectani_stop(ani4#)
  label_text#(statusLbl#, "All animations stopped")
endfunction

function OnExpandClick(sender#)
  if expandState = 0 then
    ' Currently collapsed, expand
    rectani_startbounds#(ani2#, 140, 80, 100, 80)
    rectani_stopbounds#(ani2#, 40, 40, 300, 160)
    expandState = 1
    label_text#(statusLbl#, "Expanding...")
  else
    ' Currently expanded, collapse
    rectani_startbounds#(ani2#, 40, 40, 300, 160)
    rectani_stopbounds#(ani2#, 140, 80, 100, 80)
    expandState = 0
    label_text#(statusLbl#, "Collapsing...")
  endif
  rectani_start(ani2#)
endfunction

function OnBounceFinish(sender#) local msg$
  if expandState = 1 then
    msg$ = "Expanded!"
  else
    msg$ = "Collapsed!"
  endif
  label_text#(statusLbl#, msg$)
endfunction

function OnOpenClick(sender#)
  rectangle_visible#(rect4#, 1)
  ' Set to open animation
  rectani_startbounds#(ani4#, 190, 120, 0, 0)
  rectani_stopbounds#(ani4#, 40, 40, 300, 160)
  rectani_start(ani4#)
  button_enabled#(btn2#, 0)
  label_text#(statusLbl#, "Opening window...")
endfunction

function OnCloseClick(sender#)
  ' Set to close animation
  rectani_startbounds#(ani4#, 40, 40, 300, 160)
  rectani_stopbounds#(ani4#, 190, 120, 0, 0)
  rectani_start(ani4#)
  button_enabled#(btn3#, 0)
  label_text#(statusLbl#, "Closing window...")
endfunction

function OnWindowAnimFinish(sender#) local stopW
  ' Check which animation just finished by looking at stop width
  stopW = rectani_stopwidth(ani4#)
  
  if stopW > 10 then
    ' Just opened
    button_enabled#(btn3#, 1)
    button_enabled#(btn2#, 0)
    label_text#(statusLbl#, "Window opened!")
  else
    ' Just closed
    rectangle_visible#(rect4#, 0)
    button_enabled#(btn2#, 1)
    button_enabled#(btn3#, 0)
    label_text#(statusLbl#, "Window closed!")
  endif
endfunction
