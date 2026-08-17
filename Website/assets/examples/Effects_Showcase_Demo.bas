' ============================================================================
' Effects Showcase Demo (Simple Version)
' Version: 1.0.1
' 
' Demonstrates FireMonkey effects using basic controls only.
' Uses: form, panel, button, label (no rectangle/circle dependencies)
' ============================================================================

' Module-level variables
let frm# = Pointer#(0)
let statusLbl# = Pointer#(0)

' Panel references for show/hide
let blurPanel# = Pointer#(0)
let shadowPanel# = Pointer#(0)
let glowPanel# = Pointer#(0)

' Effect references for demos
let blur1# = Pointer#(0)
let shadow1# = Pointer#(0)
let glow1# = Pointer#(0)
let pulseAni# = Pointer#(0)

' Demo control references
let demoBtn1# = Pointer#(0)
let shadowBtn# = Pointer#(0)
let glowBtn# = Pointer#(0)

' ============================================================================
' Main Program
' ============================================================================

println "Effects Showcase Demo (Simple)"
println "=============================="
println ""

frm# = form#("Plan9Basic Effects Showcase", 700, 550)

' Create navigation tabs
CreateNavigation()

' Create demo panels
CreateBlurDemo()
CreateShadowDemo()
CreateGlowDemo()

' Status bar
statusLbl# = label#(frm#, "Click buttons to see effects in action", 20, 520)

' Show blur panel by default
panel_visible#(blurPanel#, 1)

form_show(frm#)

' ============================================================================
' Navigation
' ============================================================================

function CreateNavigation() local navPanel#, btn1#, btn2#, btn3#
  navPanel# = panel#(frm#)
  panel_bounds#(navPanel#, 0, 0, 700, 50)
  
  btn1# = button#(navPanel#, "Blur Effects")
  button_bounds#(btn1#, 10, 10, 100, 30)
  button_onclick#(btn1#, "ShowBlurDemo")
  
  btn2# = button#(navPanel#, "Shadow Effects")
  button_bounds#(btn2#, 120, 10, 110, 30)
  button_onclick#(btn2#, "ShowShadowDemo")
  
  btn3# = button#(navPanel#, "Glow Effects")
  button_bounds#(btn3#, 240, 10, 100, 30)
  button_onclick#(btn3#, "ShowGlowDemo")
endfunction

' ============================================================================
' Blur Demo
' ============================================================================

function CreateBlurDemo() local lbl#, btn#, hoverBtn#, hoverBlur#
  blurPanel# = panel#(frm#)
  panel_bounds#(blurPanel#, 0, 50, 700, 470)
  
  lbl# = label#(blurPanel#, "BLUR EFFECT DEMO", 20, 20)
  
  ' Target button for blur demo
  demoBtn1# = button#(blurPanel#, "Blur This Button!")
  button_bounds#(demoBtn1#, 50, 70, 200, 80)
  
  ' Apply blur effect
  blur1# = blur#(demoBtn1#)
  blur_softness#(blur1#, 0)
  
  ' Info text
  lbl# = label#(blurPanel#, "Blur softens the appearance of controls.", 300, 70)
  lbl# = label#(blurPanel#, "Range: 0.0 (sharp) to 3.0 (maximum blur)", 300, 90)
  
  ' Control buttons
  btn# = button#(blurPanel#, "No Blur")
  button_bounds#(btn#, 50, 170, 80, 30)
  button_onclick#(btn#, "SetBlur0")
  
  btn# = button#(blurPanel#, "Light")
  button_bounds#(btn#, 140, 170, 80, 30)
  button_onclick#(btn#, "SetBlur1")
  
  btn# = button#(blurPanel#, "Medium")
  button_bounds#(btn#, 230, 170, 80, 30)
  button_onclick#(btn#, "SetBlur2")
  
  btn# = button#(blurPanel#, "Heavy")
  button_bounds#(btn#, 320, 170, 80, 30)
  button_onclick#(btn#, "SetBlur3")
  
  btn# = button#(blurPanel#, "Animate Blur")
  button_bounds#(btn#, 50, 220, 120, 30)
  button_onclick#(btn#, "AnimateBlur1")
  
  ' Second example: Blur on hover
  lbl# = label#(blurPanel#, "Trigger-based blur (hover over button):", 50, 280)
  
  hoverBtn# = button#(blurPanel#, "Hover Me for Blur!")
  button_bounds#(hoverBtn#, 50, 310, 200, 50)
  
  hoverBlur# = blur#(hoverBtn#)
  blur_softness#(hoverBlur#, 2.0)
  blur_trigger#(hoverBlur#, "IsMouseOver=true")
  
  panel_visible#(blurPanel#, 0)
endfunction

function SetBlur0(sender#)
  blur_softness#(blur1#, 0.0)
  label_text#(statusLbl#, "Blur: 0.0 (no blur)")
endfunction

function SetBlur1(sender#)
  blur_softness#(blur1#, 1.0)
  label_text#(statusLbl#, "Blur: 1.0 (light)")
endfunction

function SetBlur2(sender#)
  blur_softness#(blur1#, 2.0)
  label_text#(statusLbl#, "Blur: 2.0 (medium)")
endfunction

function SetBlur3(sender#)
  blur_softness#(blur1#, 3.0)
  label_text#(statusLbl#, "Blur: 3.0 (heavy)")
endfunction

function AnimateBlur1(sender#) local ani#
  blur_softness#(blur1#, 0.0)
  
  ani# = floatani#(blur1#)
  floatani_propertyname#(ani#, "Softness")
  floatani_startvalue#(ani#, 0.0)
  floatani_stopvalue#(ani#, 3.0)
  floatani_duration#(ani#, 2.0)
  floatani_autoreverse#(ani#, 1)
  floatani_start(ani#)
  
  label_text#(statusLbl#, "Animating blur 0 -> 3 -> 0...")
endfunction

' ============================================================================
' Shadow Demo
' ============================================================================

function CreateShadowDemo() local lbl#, btn#, i, galleryBtn#, galleryShd#
  shadowPanel# = panel#(frm#)
  panel_bounds#(shadowPanel#, 0, 50, 700, 470)
  
  lbl# = label#(shadowPanel#, "SHADOW EFFECT DEMO", 20, 20)
  
  ' Target button for shadow demo
  shadowBtn# = button#(shadowPanel#, "Button with Shadow")
  button_bounds#(shadowBtn#, 80, 70, 180, 60)
  
  ' Apply shadow effect
  shadow1# = shadow#(shadowBtn#)
  shadow_distance#(shadow1#, 5)
  shadow_direction#(shadow1#, 45)
  shadow_softness#(shadow1#, 0.4)
  shadow_opacity#(shadow1#, 0.5)
  
  ' Info
  lbl# = label#(shadowPanel#, "Shadows add depth and visual hierarchy.", 320, 70)
  lbl# = label#(shadowPanel#, "Properties: Distance, Direction, Softness, Opacity", 320, 90)
  
  ' Control buttons - Distance
  lbl# = label#(shadowPanel#, "Distance:", 50, 160)
  
  btn# = button#(shadowPanel#, "2")
  button_bounds#(btn#, 120, 155, 40, 25)
  button_onclick#(btn#, "SetShadowDist2")
  
  btn# = button#(shadowPanel#, "5")
  button_bounds#(btn#, 165, 155, 40, 25)
  button_onclick#(btn#, "SetShadowDist5")
  
  btn# = button#(shadowPanel#, "10")
  button_bounds#(btn#, 210, 155, 40, 25)
  button_onclick#(btn#, "SetShadowDist10")
  
  btn# = button#(shadowPanel#, "20")
  button_bounds#(btn#, 255, 155, 40, 25)
  button_onclick#(btn#, "SetShadowDist20")
  
  ' Control buttons - Direction
  lbl# = label#(shadowPanel#, "Direction:", 50, 195)
  
  btn# = button#(shadowPanel#, "45")
  button_bounds#(btn#, 120, 190, 45, 25)
  button_onclick#(btn#, "SetShadowDir45")
  
  btn# = button#(shadowPanel#, "135")
  button_bounds#(btn#, 170, 190, 45, 25)
  button_onclick#(btn#, "SetShadowDir135")
  
  btn# = button#(shadowPanel#, "225")
  button_bounds#(btn#, 220, 190, 45, 25)
  button_onclick#(btn#, "SetShadowDir225")
  
  btn# = button#(shadowPanel#, "315")
  button_bounds#(btn#, 270, 190, 45, 25)
  button_onclick#(btn#, "SetShadowDir315")
  
  ' Animate button
  btn# = button#(shadowPanel#, "Animate Lift Effect")
  button_bounds#(btn#, 50, 240, 150, 30)
  button_onclick#(btn#, "AnimateLift")
  
  ' Multiple shadows example
  lbl# = label#(shadowPanel#, "Button Gallery with Increasing Shadow Distance:", 50, 300)
  
  ' Create button gallery
  i = 0
  while i < 4
    galleryBtn# = button#(shadowPanel#, "Btn " + str$(i + 1))
    button_bounds#(galleryBtn#, 50 + i * 100, 330, 80, 40)
    
    galleryShd# = shadow#(galleryBtn#)
    shadow_distance#(galleryShd#, 3 + i * 3)
    shadow_softness#(galleryShd#, 0.3)
    
    i = i + 1
  endwhile
  
  panel_visible#(shadowPanel#, 0)
endfunction

function SetShadowDist2(sender#)
  shadow_distance#(shadow1#, 2)
  label_text#(statusLbl#, "Shadow distance: 2")
endfunction

function SetShadowDist5(sender#)
  shadow_distance#(shadow1#, 5)
  label_text#(statusLbl#, "Shadow distance: 5")
endfunction

function SetShadowDist10(sender#)
  shadow_distance#(shadow1#, 10)
  label_text#(statusLbl#, "Shadow distance: 10")
endfunction

function SetShadowDist20(sender#)
  shadow_distance#(shadow1#, 20)
  label_text#(statusLbl#, "Shadow distance: 20")
endfunction

function SetShadowDir45(sender#)
  shadow_direction#(shadow1#, 45)
  label_text#(statusLbl#, "Shadow direction: 45 deg (SE)")
endfunction

function SetShadowDir135(sender#)
  shadow_direction#(shadow1#, 135)
  label_text#(statusLbl#, "Shadow direction: 135 deg (SW)")
endfunction

function SetShadowDir225(sender#)
  shadow_direction#(shadow1#, 225)
  label_text#(statusLbl#, "Shadow direction: 225 deg (NW)")
endfunction

function SetShadowDir315(sender#)
  shadow_direction#(shadow1#, 315)
  label_text#(statusLbl#, "Shadow direction: 315 deg (NE)")
endfunction

function AnimateLift(sender#) local ani#
  ani# = floatani#(shadow1#)
  floatani_propertyname#(ani#, "Distance")
  floatani_startvalue#(ani#, 3)
  floatani_stopvalue#(ani#, 15)
  floatani_duration#(ani#, 0.5)
  floatani_autoreverse#(ani#, 1)
  floatani_start(ani#)
  
  label_text#(statusLbl#, "Animating shadow distance (lift effect)...")
endfunction

' ============================================================================
' Glow Demo
' ============================================================================

function CreateGlowDemo() local lbl#, btn#, neonBtn#, neonGlow#
  glowPanel# = panel#(frm#)
  panel_bounds#(glowPanel#, 0, 50, 700, 470)
  
  lbl# = label#(glowPanel#, "GLOW EFFECT DEMO", 20, 20)
  
  ' Target button for glow demo
  glowBtn# = button#(glowPanel#, "Glowing Button")
  button_bounds#(glowBtn#, 80, 70, 150, 60)
  
  ' Apply glow effect
  glow1# = glow#(glowBtn#)
  glow_softness#(glow1#, 4)
  glow_color#(glow1#, "Cyan")
  glow_opacity#(glow1#, 0.9)
  
  ' Info
  lbl# = label#(glowPanel#, "Glow creates an outer aura around controls.", 280, 70)
  lbl# = label#(glowPanel#, "Great for highlighting and visual feedback.", 280, 90)
  
  ' Color buttons
  lbl# = label#(glowPanel#, "Glow Color:", 50, 160)
  
  btn# = button#(glowPanel#, "Cyan")
  button_bounds#(btn#, 130, 155, 60, 25)
  button_onclick#(btn#, "SetGlowCyan")
  
  btn# = button#(glowPanel#, "Red")
  button_bounds#(btn#, 195, 155, 60, 25)
  button_onclick#(btn#, "SetGlowRed")
  
  btn# = button#(glowPanel#, "Green")
  button_bounds#(btn#, 260, 155, 60, 25)
  button_onclick#(btn#, "SetGlowGreen")
  
  btn# = button#(glowPanel#, "Yellow")
  button_bounds#(btn#, 325, 155, 60, 25)
  button_onclick#(btn#, "SetGlowYellow")
  
  ' Softness buttons
  lbl# = label#(glowPanel#, "Softness:", 50, 195)
  
  btn# = button#(glowPanel#, "2")
  button_bounds#(btn#, 130, 190, 40, 25)
  button_onclick#(btn#, "SetGlowSoft2")
  
  btn# = button#(glowPanel#, "4")
  button_bounds#(btn#, 175, 190, 40, 25)
  button_onclick#(btn#, "SetGlowSoft4")
  
  btn# = button#(glowPanel#, "6")
  button_bounds#(btn#, 220, 190, 40, 25)
  button_onclick#(btn#, "SetGlowSoft6")
  
  btn# = button#(glowPanel#, "9")
  button_bounds#(btn#, 265, 190, 40, 25)
  button_onclick#(btn#, "SetGlowSoft9")
  
  ' Pulse animation
  btn# = button#(glowPanel#, "Start Pulse")
  button_bounds#(btn#, 50, 240, 100, 30)
  button_onclick#(btn#, "StartPulse")
  
  btn# = button#(glowPanel#, "Stop Pulse")
  button_bounds#(btn#, 160, 240, 100, 30)
  button_onclick#(btn#, "StopPulse")
  
  ' Neon button gallery
  lbl# = label#(glowPanel#, "Colored Glow Gallery:", 50, 300)
  
  CreateGlowingButton(glowPanel#, 50, 330, "Play", "Lime")
  CreateGlowingButton(glowPanel#, 160, 330, "Stop", "Red")
  CreateGlowingButton(glowPanel#, 270, 330, "Info", "Cyan")
  CreateGlowingButton(glowPanel#, 380, 330, "Alert", "Orange")
  
  panel_visible#(glowPanel#, 0)
endfunction

function CreateGlowingButton(parent#, x, y, text$, color$) local btn#, glw#
  btn# = button#(parent#, text$)
  button_bounds#(btn#, x, y, 90, 35)
  
  glw# = glow#(btn#)
  glow_color#(glw#, color$)
  glow_softness#(glw#, 4)
  glow_opacity#(glw#, 0.8)
endfunction

function SetGlowCyan(sender#)
  glow_color#(glow1#, "Cyan")
  label_text#(statusLbl#, "Glow color: Cyan")
endfunction

function SetGlowRed(sender#)
  glow_color#(glow1#, "Red")
  label_text#(statusLbl#, "Glow color: Red")
endfunction

function SetGlowGreen(sender#)
  glow_color#(glow1#, "Lime")
  label_text#(statusLbl#, "Glow color: Lime")
endfunction

function SetGlowYellow(sender#)
  glow_color#(glow1#, "Yellow")
  label_text#(statusLbl#, "Glow color: Yellow")
endfunction

function SetGlowSoft2(sender#)
  glow_softness#(glow1#, 2)
  label_text#(statusLbl#, "Glow softness: 2 (tight)")
endfunction

function SetGlowSoft4(sender#)
  glow_softness#(glow1#, 4)
  label_text#(statusLbl#, "Glow softness: 4 (medium)")
endfunction

function SetGlowSoft6(sender#)
  glow_softness#(glow1#, 6)
  label_text#(statusLbl#, "Glow softness: 6 (spread)")
endfunction

function SetGlowSoft9(sender#)
  glow_softness#(glow1#, 9)
  label_text#(statusLbl#, "Glow softness: 9 (maximum)")
endfunction

function StartPulse(sender#)
  pulseAni# = floatani#(glow1#)
  floatani_propertyname#(pulseAni#, "Softness")
  floatani_startvalue#(pulseAni#, 2)
  floatani_stopvalue#(pulseAni#, 8)
  floatani_duration#(pulseAni#, 0.8)
  floatani_autoreverse#(pulseAni#, 1)
  floatani_loop#(pulseAni#, 1)
  floatani_start(pulseAni#)
  
  label_text#(statusLbl#, "Pulsing glow started")
endfunction

function StopPulse(sender#) local p
  p = PntToNum(pulseAni#)
  if p <> 0 then
    floatani_stop(pulseAni#)
  endif
  glow_softness#(glow1#, 4)
  label_text#(statusLbl#, "Pulse stopped")
endfunction

' ============================================================================
' Panel Visibility Control
' ============================================================================

function ShowBlurDemo(sender#)
  panel_visible#(blurPanel#, 1)
  panel_visible#(shadowPanel#, 0)
  panel_visible#(glowPanel#, 0)
  label_text#(statusLbl#, "Viewing: Blur Effects")
endfunction

function ShowShadowDemo(sender#)
  panel_visible#(blurPanel#, 0)
  panel_visible#(shadowPanel#, 1)
  panel_visible#(glowPanel#, 0)
  label_text#(statusLbl#, "Viewing: Shadow Effects")
endfunction

function ShowGlowDemo(sender#)
  panel_visible#(blurPanel#, 0)
  panel_visible#(shadowPanel#, 0)
  panel_visible#(glowPanel#, 1)
  label_text#(statusLbl#, "Viewing: Glow Effects")
endfunction
