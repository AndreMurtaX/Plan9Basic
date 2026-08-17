' =============================================================================
' Test 6: Comprehensive Animation Demo
' =============================================================================
' A practical demonstration combining multiple animation types:
' - Button hover effects
' - Form transitions
' - Loading indicators
' - Notification animations
' =============================================================================

let frm# = form#("Comprehensive Animation Demo", 550, 450)

' Title
let lblTitle# = label#(frm#, "Animation Effects Gallery")
label_move#(lblTitle#, 10, 10)
label_fontsize#(lblTitle#, 16)

' =============================================================================
' Section 1: Animated Button (Hover Effect Simulation)
' =============================================================================
let lblSection1# = label#(frm#, "1. Button Press Animation:")
label_move#(lblSection1#, 10, 50)

let animatedBtn# = button#(frm#, "Click Me!")
button_bounds#(animatedBtn#, 20, 75, 120, 35)
button_onclick#(animatedBtn#, "OnAnimatedBtnClick")

function OnAnimatedBtnClick(sender#) local aniScale#
  ' Simulate button press with scale animation
  aniScale# = floatani#(animatedBtn#)
  floatani_propertyname#(aniScale#, "Scale.X")
  floatani_startvalue#(aniScale#, 1.0)
  floatani_stopvalue#(aniScale#, 0.95)
  floatani_duration#(aniScale#, 0.1)
  floatani_autoreverse#(aniScale#, 1)
  floatani_start(aniScale#)
  
  aniScale# = floatani#(animatedBtn#)
  floatani_propertyname#(aniScale#, "Scale.Y")
  floatani_startvalue#(aniScale#, 1.0)
  floatani_stopvalue#(aniScale#, 0.95)
  floatani_duration#(aniScale#, 0.1)
  floatani_autoreverse#(aniScale#, 1)
  floatani_start(aniScale#)
endfunction

' =============================================================================
' Section 2: Loading Spinner
' =============================================================================
let lblSection2# = label#(frm#, "2. Loading Animation:")
label_move#(lblSection2#, 200, 50)

let loadingCircle# = circle#(frm#)
circle_bounds#(loadingCircle#, 210, 75, 30, 30)
circle_fill#(loadingCircle#, "Blue")

let loadingAni# = Pointer#(0)
let isLoading = 0

let btnLoading# = button#(frm#, "Start Loading")
button_bounds#(btnLoading#, 250, 78, 100, 25)
button_onclick#(btnLoading#, "OnToggleLoading")

function OnToggleLoading(sender#)
  if isLoading = 0 then
    ' Start loading animation (pulsing opacity)
    isLoading = 1
    button_text#(btnLoading#, "Stop Loading")
    
    loadingAni# = floatani#(loadingCircle#)
    floatani_propertyname#(loadingAni#, "Opacity")
    floatani_startvalue#(loadingAni#, 1.0)
    floatani_stopvalue#(loadingAni#, 0.3)
    floatani_duration#(loadingAni#, 0.6)
    floatani_loop#(loadingAni#, 1)
    floatani_autoreverse#(loadingAni#, 1)
    floatani_start(loadingAni#)
  else
    ' Stop loading
    isLoading = 0
    button_text#(btnLoading#, "Start Loading")
    
    if PntToNum(loadingAni#) <> 0 then
      floatani_stop(loadingAni#)
    endif
    circle_opacity#(loadingCircle#, 1.0)
  endif
endfunction

' =============================================================================
' Section 3: Notification Toast
' =============================================================================
let lblSection3# = label#(frm#, "3. Notification Toast:")
label_move#(lblSection3#, 10, 130)

' Toast panel (initially hidden)
let toastPanel# = rectangle#(frm#)
rectangle_bounds#(toastPanel#, 20, 155, 200, 40)
rectangle_fill#(toastPanel#, "Green")
rectangle_corners#(toastPanel#, 8, 8)
rectangle_opacity#(toastPanel#, 0)

let toastLabel# = label#(toastPanel#, "Success! Operation completed.")
label_move#(toastLabel#, 10, 10)
label_fontcolor#(toastLabel#, "White")

let btnToast# = button#(frm#, "Show Toast")
button_bounds#(btnToast#, 230, 165, 100, 25)
button_onclick#(btnToast#, "OnShowToast")

function OnShowToast(sender#) local aniIn#
  ' Fade in the toast
  aniIn# = floatani#(toastPanel#)
  floatani_propertyname#(aniIn#, "Opacity")
  floatani_startvalue#(aniIn#, 0)
  floatani_stopvalue#(aniIn#, 1.0)
  floatani_duration#(aniIn#, 0.3)
  floatani_interpolation#(aniIn#, "Quadratic")
  floatani_animationtype#(aniIn#, "Out")
  floatani_onfinish#(aniIn#, "OnToastShown")
  floatani_start(aniIn#)
endfunction

function OnToastShown(sender#) local aniOut#
  ' Wait a moment, then fade out (using delay)
  aniOut# = floatani#(toastPanel#)
  floatani_propertyname#(aniOut#, "Opacity")
  floatani_startvalue#(aniOut#, 1.0)
  floatani_stopvalue#(aniOut#, 0)
  floatani_delay#(aniOut#, 2.0)
  floatani_duration#(aniOut#, 0.5)
  floatani_interpolation#(aniOut#, "Quadratic")
  floatani_animationtype#(aniOut#, "In")
  floatani_start(aniOut#)
endfunction

' =============================================================================
' Section 4: Sliding Panel
' =============================================================================
let lblSection4# = label#(frm#, "4. Sliding Panel:")
label_move#(lblSection4#, 10, 210)

let slidePanel# = rectangle#(frm#)
rectangle_bounds#(slidePanel#, -180, 235, 180, 80)
rectangle_fill#(slidePanel#, "Navy")
rectangle_corners#(slidePanel#, 0, 0)

let slidePanelLabel# = label#(slidePanel#, "Slide-in Panel")
label_move#(slidePanelLabel#, 10, 30)
label_fontcolor#(slidePanelLabel#, "White")

let isPanelOpen = 0

let btnSlide# = button#(frm#, "Toggle Panel")
button_bounds#(btnSlide#, 10, 320, 100, 25)
button_onclick#(btnSlide#, "OnTogglePanel")

function OnTogglePanel(sender#) local ani#
  ani# = floatani#(slidePanel#)
  floatani_propertyname#(ani#, "Position.X")
  floatani_duration#(ani#, 0.4)
  floatani_interpolation#(ani#, "Cubic")
  floatani_animationtype#(ani#, "Out")
  
  if isPanelOpen = 0 then
    ' Slide in
    floatani_startvalue#(ani#, -180)
    floatani_stopvalue#(ani#, 0)
    isPanelOpen = 1
  else
    ' Slide out
    floatani_startvalue#(ani#, 0)
    floatani_stopvalue#(ani#, -180)
    isPanelOpen = 0
  endif
  
  floatani_start(ani#)
endfunction

' =============================================================================
' Section 5: Color Cycling
' =============================================================================
let lblSection5# = label#(frm#, "5. Color Cycling:")
label_move#(lblSection5#, 350, 130)

let colorCycleRect# = rectangle#(frm#)
rectangle_bounds#(colorCycleRect#, 360, 155, 80, 80)
rectangle_fill#(colorCycleRect#, "Red")
rectangle_corners#(colorCycleRect#, 40, 40)

let colorCycleAni# = Pointer#(0)
let isCycling = 0
let cyclePhase = 0

let btnCycle# = button#(frm#, "Start Cycle")
button_bounds#(btnCycle#, 450, 180, 90, 25)
button_onclick#(btnCycle#, "OnToggleCycle")

function OnToggleCycle(sender#)
  if isCycling = 0 then
    isCycling = 1
    button_text#(btnCycle#, "Stop Cycle")
    cyclePhase = 0
    StartNextColorCycle()
  else
    isCycling = 0
    button_text#(btnCycle#, "Start Cycle")
  endif
endfunction

function StartNextColorCycle() local ani#, startColor$, endColor$
  if isCycling = 0 then
    return 0
  endif
  
  ' Determine colors based on phase
  if cyclePhase = 0 then
    startColor$ = "Red"
    endColor$ = "Yellow"
  else if cyclePhase = 1 then
    startColor$ = "Yellow"
    endColor$ = "Green"
  else if cyclePhase = 2 then
    startColor$ = "Green"
    endColor$ = "Blue"
  else
    startColor$ = "Blue"
    endColor$ = "Red"
  endif
  
  ani# = colorani#(colorCycleRect#)
  colorani_propertyname#(ani#, "Fill.Color")
  colorani_startvalue#(ani#, colortoalphacolor(startColor$))
  colorani_stopvalue#(ani#, colortoalphacolor(endColor$))
  colorani_duration#(ani#, 1.0)
  colorani_onfinish#(ani#, "OnColorCyclePhase")
  colorani_start(ani#)
endfunction

function OnColorCyclePhase(sender#)
  cyclePhase = cyclePhase + 1
  if cyclePhase > 3 then
    cyclePhase = 0
  endif
  StartNextColorCycle()
endfunction

' =============================================================================
' Section 6: Bouncing Ball
' =============================================================================
let lblSection6# = label#(frm#, "6. Bouncing Ball:")
label_move#(lblSection6#, 350, 250)

let bounceBall# = circle#(frm#)
circle_bounds#(bounceBall#, 380, 275, 40, 40)
circle_fill#(bounceBall#, "Orange")

let isBouncing = 0

let btnBounce# = button#(frm#, "Start Bounce")
button_bounds#(btnBounce#, 450, 285, 90, 25)
button_onclick#(btnBounce#, "OnToggleBounce")

function OnToggleBounce(sender#) local ani#
  if isBouncing = 0 then
    isBouncing = 1
    button_text#(btnBounce#, "Stop Bounce")
    
    ani# = floatani#(bounceBall#)
    floatani_propertyname#(ani#, "Position.Y")
    floatani_startvalue#(ani#, 275)
    floatani_stopvalue#(ani#, 380)
    floatani_duration#(ani#, 0.5)
    floatani_interpolation#(ani#, "Bounce")
    floatani_animationtype#(ani#, "Out")
    floatani_loop#(ani#, 1)
    floatani_autoreverse#(ani#, 1)
    floatani_start(ani#)
  else
    isBouncing = 0
    button_text#(btnBounce#, "Start Bounce")
    circle_move#(bounceBall#, 380, 275)
  endif
endfunction

' =============================================================================
' Reset All Button
' =============================================================================
let btnResetAll# = button#(frm#, "Reset All")
button_bounds#(btnResetAll#, 430, 410, 100, 30)
button_onclick#(btnResetAll#, "OnResetAll")

function OnResetAll(sender#)
  ' Reset all states
  isLoading = 0
  isPanelOpen = 0
  isCycling = 0
  isBouncing = 0
  
  ' Reset UI elements
  circle_opacity#(loadingCircle#, 1.0)
  rectangle_opacity#(toastPanel#, 0)
  rectangle_move#(slidePanel#, -180, 235)
  rectangle_fill#(colorCycleRect#, "Red")
  circle_move#(bounceBall#, 380, 275)
  
  ' Reset button texts
  button_text#(btnLoading#, "Start Loading")
  button_text#(btnCycle#, "Start Cycle")
  button_text#(btnBounce#, "Start Bounce")
endfunction

' Show the form
form_show(frm#)
