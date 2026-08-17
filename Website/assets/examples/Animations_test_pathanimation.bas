' =============================================================================
' PathAnimationLib Test Suite
' Tests path-based animations with various curves and effects
' =============================================================================

' Module-level variables
let frm# = Pointer#(0)
let statusLbl# = Pointer#(0)
let ball1# = Pointer#(0)
let ball2# = Pointer#(0)
let ball3# = Pointer#(0)
let arrow# = Pointer#(0)
let ani1# = Pointer#(0)
let ani2# = Pointer#(0)
let ani3# = Pointer#(0)
let aniArrow# = Pointer#(0)
let loopCount1 = 0
let loopCount2 = 0
let panel1# = Pointer#(0)
let panel2# = Pointer#(0)
let panel3# = Pointer#(0)
let panel4# = Pointer#(0)

' -----------------------------------------------------------------------------
' Main Program
' -----------------------------------------------------------------------------
println "PathAnimationLib Test Suite"
println "==========================="
println ""

gosub CreateUI
gosub CreateAnimations
gosub StartAnimations

form_show(frm#)

println ""
println "Test applet running. Close the window to exit."
end

' -----------------------------------------------------------------------------
' Create User Interface
' -----------------------------------------------------------------------------
CreateUI:
  frm# = form#("PathAnimationLib Test Suite", 800, 600)
  
  ' Status label at top (text, x, y, width, height)
  statusLbl# = label#(frm#, "Path Animation Tests - Watch the objects move along their paths", 10, 10, 780, 25)
  
  ' Panel 1: S-Curve path
  panel1# = panel#(frm#, 10, 45, 385, 250)
  let lbl1# = label#(panel1#, "1. S-Curve Path (Looping)", 5, 5, 375, 20)
  
  ball1# = circle#(panel1#)
  circle_bounds#(ball1#, 0, 0, 24, 24)
  circle_fill#(ball1#, "Red")
  circle_stroke#(ball1#, "DarkRed")
  circle_strokethickness#(ball1#, 2)
  
  ' Panel 2: Figure-8 path
  panel2# = panel#(frm#, 405, 45, 385, 250)
  let lbl2# = label#(panel2#, "2. Figure-8 Path (AutoReverse)", 5, 5, 375, 20)
  
  ball2# = circle#(panel2#)
  circle_bounds#(ball2#, 0, 0, 20, 20)
  circle_fill#(ball2#, "Blue")
  circle_stroke#(ball2#, "DarkBlue")
  circle_strokethickness#(ball2#, 2)
  
  ' Panel 3: Square path with bounce
  panel3# = panel#(frm#, 10, 305, 385, 250)
  let lbl3# = label#(panel3#, "3. Square Path (Bounce Interpolation)", 5, 5, 375, 20)
  
  ball3# = ellipse#(panel3#)
  ellipse_bounds#(ball3#, 0, 0, 30, 20)
  ellipse_fill#(ball3#, "Green")
  ellipse_stroke#(ball3#, "DarkGreen")
  ellipse_strokethickness#(ball3#, 2)
  
  ' Panel 4: Arrow with rotation
  panel4# = panel#(frm#, 405, 305, 385, 250)
  let lbl4# = label#(panel4#, "4. Curved Path with Rotation (Arrow follows path)", 5, 5, 375, 20)
  
  ' Create arrow using a path shape
  arrow# = path#(panel4#)
  path_bounds#(arrow#, 0, 0, 30, 20)
  path_data#(arrow#, "M 0,10 L 20,10 L 20,5 L 30,10 L 20,15 L 20,10")
  path_fill#(arrow#, "Orange")
  path_stroke#(arrow#, "DarkOrange")
  path_strokethickness#(arrow#, 1)
  
  ' Info labels showing loop counts
  let infoLbl1# = label#(panel1#, "Loops: 0", 5, 225, 200, 20)
  let infoLbl2# = label#(panel2#, "Cycles: 0", 5, 225, 200, 20)
return

' -----------------------------------------------------------------------------
' Create Animations
' -----------------------------------------------------------------------------
CreateAnimations:
  loopCount1 = 0
  loopCount2 = 0
  
  ' Animation 1: S-Curve
  ' Path goes from left, curves up, then down, then to right
  ani1# = pathani#(ball1#)
  pathani_path#(ani1#, "M 20,120 C 80,30 150,210 190,120 C 230,30 300,210 360,120")
  pathani_duration#(ani1#, 3.0)
  pathani_loop#(ani1#, 1)
  pathani_interpolation#(ani1#, "Linear")
  pathani_onfinish#(ani1#, "OnAni1Finish")
  
  println "Animation 1 created: S-Curve path"
  println "  Path: M 20,120 C 80,30 150,210 190,120 C 230,30 300,210 360,120"
  println "  Duration: 3.0s, Loop: On"
  
  ' Animation 2: Figure-8
  ani2# = pathani#(ball2#)
  pathani_path#(ani2#, "M 190,60 Q 100,120 190,180 Q 280,120 190,60")
  pathani_duration#(ani2#, 2.5)
  pathani_loop#(ani2#, 1)
  pathani_autoreverse#(ani2#, 1)
  pathani_interpolation#(ani2#, "Sinusoidal")
  pathani_animationtype#(ani2#, "InOut")
  pathani_onfinish#(ani2#, "OnAni2Finish")
  
  println ""
  println "Animation 2 created: Figure-8 path"
  println "  Duration: 2.5s, Loop: On, AutoReverse: On"
  println "  Interpolation: Sinusoidal, Type: InOut"
  
  ' Animation 3: Square path with bounce
  ani3# = pathani#(ball3#)
  pathani_path#(ani3#, "M 30,50 L 330,50 L 330,200 L 30,200 Z")
  pathani_duration#(ani3#, 4.0)
  pathani_loop#(ani3#, 1)
  pathani_interpolation#(ani3#, "Bounce")
  pathani_animationtype#(ani3#, "Out")
  
  println ""
  println "Animation 3 created: Square path"
  println "  Duration: 4.0s, Loop: On"
  println "  Interpolation: Bounce, Type: Out"
  
  ' Animation 4: Curved path with rotation
  aniArrow# = pathani#(arrow#)
  pathani_path#(aniArrow#, "M 30,200 Q 190,30 350,120 Q 190,210 30,120 Q 190,30 350,200")
  pathani_duration#(aniArrow#, 5.0)
  pathani_loop#(aniArrow#, 1)
  pathani_rotate#(aniArrow#, 1)
  pathani_interpolation#(aniArrow#, "Linear")
  
  println ""
  println "Animation 4 created: Curved path with rotation"
  println "  Duration: 5.0s, Loop: On, Rotate: On"
  println "  The arrow will turn to follow the path direction"
return

' -----------------------------------------------------------------------------
' Start Animations
' -----------------------------------------------------------------------------
StartAnimations:
  println ""
  println "Starting all animations..."
  
  pathani_start(ani1#)
  pathani_start(ani2#)
  pathani_start(ani3#)
  pathani_start(aniArrow#)
  
  println "All animations started!"
return

' -----------------------------------------------------------------------------
' Callback Functions
' -----------------------------------------------------------------------------
function OnAni1Finish(sender#) local msg$
  loopCount1 = loopCount1 + 1
  msg$ = "S-Curve completed loop #" + str$(loopCount1)
  label_text#(statusLbl#, msg$)
endfunction

function OnAni2Finish(sender#) local msg$
  loopCount2 = loopCount2 + 1
  msg$ = "Figure-8 completed cycle #" + str$(loopCount2)
  label_text#(statusLbl#, msg$)
endfunction
