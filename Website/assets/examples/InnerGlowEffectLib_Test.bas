' ============================================================================
' InnerGlowEffectLib Test and Demo
' Version: 1.0.0
' 
' Tests and demonstrates the Inner Glow Effect Library.
' Uses: form, panel, button, label (no rectangle dependencies)
' ============================================================================

' Module-level variables
let frm# = Pointer#(0)
let statusLbl# = Pointer#(0)

' Target control and effect references
let targetBtn# = Pointer#(0)
let ig1# = Pointer#(0)

' Test counters
let testCount = 0
let passCount = 0

' ============================================================================
' Main Program
' ============================================================================

println "InnerGlowEffectLib Test and Demo"
println "================================"
println ""

frm# = form#("Inner Glow Effect Demo", 650, 500)

' Create target button
targetBtn# = button#(frm#, "Button with Inner Glow")
button_bounds#(targetBtn#, 200, 30, 220, 70)

' Apply inner glow effect
ig1# = innerglow#(targetBtn#)
innerglow_color#(ig1#, "Gold")
innerglow_softness#(ig1#, 4)
innerglow_opacity#(ig1#, 0.8)

' Info section
let infoLbl# = label#(frm#, "Inner glow creates a glow inside the control boundary", 130, 120)

' Color controls
let lbl# = label#(frm#, "Color:", 50, 160)

let btn# = button#(frm#, "Gold")
button_bounds#(btn#, 100, 155, 60, 28)
button_onclick#(btn#, "SetColorGold")

btn# = button#(frm#, "Red")
button_bounds#(btn#, 165, 155, 60, 28)
button_onclick#(btn#, "SetColorRed")

btn# = button#(frm#, "Cyan")
button_bounds#(btn#, 230, 155, 60, 28)
button_onclick#(btn#, "SetColorCyan")

btn# = button#(frm#, "Purple")
button_bounds#(btn#, 295, 155, 60, 28)
button_onclick#(btn#, "SetColorPurple")

btn# = button#(frm#, "Lime")
button_bounds#(btn#, 360, 155, 60, 28)
button_onclick#(btn#, "SetColorLime")

' Softness controls
lbl# = label#(frm#, "Softness:", 50, 200)

btn# = button#(frm#, "1")
button_bounds#(btn#, 120, 195, 40, 28)
button_onclick#(btn#, "SetSoft1")

btn# = button#(frm#, "3")
button_bounds#(btn#, 165, 195, 40, 28)
button_onclick#(btn#, "SetSoft3")

btn# = button#(frm#, "5")
button_bounds#(btn#, 210, 195, 40, 28)
button_onclick#(btn#, "SetSoft5")

btn# = button#(frm#, "7")
button_bounds#(btn#, 255, 195, 40, 28)
button_onclick#(btn#, "SetSoft7")

btn# = button#(frm#, "9")
button_bounds#(btn#, 300, 195, 40, 28)
button_onclick#(btn#, "SetSoft9")

' Opacity controls
lbl# = label#(frm#, "Opacity:", 50, 240)

btn# = button#(frm#, "20%")
button_bounds#(btn#, 120, 235, 50, 28)
button_onclick#(btn#, "SetOp20")

btn# = button#(frm#, "50%")
button_bounds#(btn#, 175, 235, 50, 28)
button_onclick#(btn#, "SetOp50")

btn# = button#(frm#, "80%")
button_bounds#(btn#, 230, 235, 50, 28)
button_onclick#(btn#, "SetOp80")

btn# = button#(frm#, "100%")
button_bounds#(btn#, 285, 235, 50, 28)
button_onclick#(btn#, "SetOp100")

' Action buttons
btn# = button#(frm#, "Toggle Effect")
button_bounds#(btn#, 50, 285, 110, 35)
button_onclick#(btn#, "ToggleEffect")

btn# = button#(frm#, "Pulse Animation")
button_bounds#(btn#, 170, 285, 120, 35)
button_onclick#(btn#, "AnimatePulse")

btn# = button#(frm#, "Run Tests")
button_bounds#(btn#, 300, 285, 100, 35)
button_onclick#(btn#, "RunTests")

' Gallery section
lbl# = label#(frm#, "Gallery with different colors:", 50, 350)
CreateGallery()

' Hover example
lbl# = label#(frm#, "Focus-triggered:", 420, 350)
CreateFocusDemo()

' Status bar
statusLbl# = label#(frm#, "Adjust inner glow properties using the controls above", 50, 460)

form_show(frm#)

' ============================================================================
' Gallery Creation
' ============================================================================

function CreateGallery() local i, galleryBtn#, galleryIg#, color$
  i = 0
  while i < 4
    galleryBtn# = button#(frm#, "G" + str$(i + 1))
    button_bounds#(galleryBtn#, 50 + i * 90, 380, 80, 50)
    
    galleryIg# = innerglow#(galleryBtn#)
    
    if i = 0 then
      color$ = "Gold"
    endif
    if i = 1 then
      color$ = "Red"
    endif
    if i = 2 then
      color$ = "Cyan"
    endif
    if i = 3 then
      color$ = "Lime"
    endif
    
    innerglow_color#(galleryIg#, color$)
    innerglow_softness#(galleryIg#, 3)
    innerglow_opacity#(galleryIg#, 0.8)
    
    i = i + 1
  endwhile
endfunction

' ============================================================================
' Focus Demo
' ============================================================================

function CreateFocusDemo() local focusBtn#, focusIg#
  focusBtn# = button#(frm#, "Click Me!")
  button_bounds#(focusBtn#, 420, 380, 120, 50)
  
  focusIg# = innerglow#(focusBtn#)
  innerglow_color#(focusIg#, "Orange")
  innerglow_softness#(focusIg#, 5)
  innerglow_trigger#(focusIg#, "IsFocused=true")
endfunction

' ============================================================================
' Color Control Functions
' ============================================================================

function SetColorGold(sender#)
  innerglow_color#(ig1#, "Gold")
  label_text#(statusLbl#, "Color: Gold")
endfunction

function SetColorRed(sender#)
  innerglow_color#(ig1#, "Red")
  label_text#(statusLbl#, "Color: Red")
endfunction

function SetColorCyan(sender#)
  innerglow_color#(ig1#, "Cyan")
  label_text#(statusLbl#, "Color: Cyan")
endfunction

function SetColorPurple(sender#)
  innerglow_color#(ig1#, "Purple")
  label_text#(statusLbl#, "Color: Purple")
endfunction

function SetColorLime(sender#)
  innerglow_color#(ig1#, "Lime")
  label_text#(statusLbl#, "Color: Lime")
endfunction

' ============================================================================
' Softness Control Functions
' ============================================================================

function SetSoft1(sender#)
  innerglow_softness#(ig1#, 1)
  label_text#(statusLbl#, "Softness: 1 (tight)")
endfunction

function SetSoft3(sender#)
  innerglow_softness#(ig1#, 3)
  label_text#(statusLbl#, "Softness: 3")
endfunction

function SetSoft5(sender#)
  innerglow_softness#(ig1#, 5)
  label_text#(statusLbl#, "Softness: 5")
endfunction

function SetSoft7(sender#)
  innerglow_softness#(ig1#, 7)
  label_text#(statusLbl#, "Softness: 7")
endfunction

function SetSoft9(sender#)
  innerglow_softness#(ig1#, 9)
  label_text#(statusLbl#, "Softness: 9 (spread)")
endfunction

' ============================================================================
' Opacity Control Functions
' ============================================================================

function SetOp20(sender#)
  innerglow_opacity#(ig1#, 0.2)
  label_text#(statusLbl#, "Opacity: 20%")
endfunction

function SetOp50(sender#)
  innerglow_opacity#(ig1#, 0.5)
  label_text#(statusLbl#, "Opacity: 50%")
endfunction

function SetOp80(sender#)
  innerglow_opacity#(ig1#, 0.8)
  label_text#(statusLbl#, "Opacity: 80%")
endfunction

function SetOp100(sender#)
  innerglow_opacity#(ig1#, 1.0)
  label_text#(statusLbl#, "Opacity: 100%")
endfunction

' ============================================================================
' Toggle and Animation
' ============================================================================

function ToggleEffect(sender#) local enabled
  enabled = innerglow_enabled(ig1#)
  if enabled = 1 then
    innerglow_enabled#(ig1#, 0)
    label_text#(statusLbl#, "Effect disabled")
  else
    innerglow_enabled#(ig1#, 1)
    label_text#(statusLbl#, "Effect enabled")
  endif
endfunction

function AnimatePulse(sender#) local ani#
  ani# = floatani#(ig1#)
  floatani_propertyname#(ani#, "Softness")
  floatani_startvalue#(ani#, 1)
  floatani_stopvalue#(ani#, 8)
  floatani_duration#(ani#, 0.6)
  floatani_autoreverse#(ani#, 1)
  floatani_loop#(ani#, 1)
  floatani_start(ani#)
  
  label_text#(statusLbl#, "Pulsing animation started...")
endfunction

' ============================================================================
' Test Functions
' ============================================================================

function RunTests(sender#)
  testCount = 0
  passCount = 0
  
  println ""
  println "=== InnerGlowEffectLib Tests ==="
  println ""
  
  TestCreation()
  TestColorProperty()
  TestSoftnessProperty()
  TestOpacityProperty()
  TestEnabledProperty()
  TestTriggerProperty()
  TestErrorHandling()
  
  println ""
  println "=== Summary ==="
  println "Total: " + str$(testCount) + " tests"
  println "Passed: " + str$(passCount)
  println "Failed: " + str$(testCount - passCount)
  
  if passCount = testCount then
    println "ALL TESTS PASSED!"
    label_text#(statusLbl#, "All " + str$(testCount) + " tests passed!")
  else
    label_text#(statusLbl#, str$(passCount) + "/" + str$(testCount) + " tests passed")
  endif
endfunction

function LogTest(name$, passed)
  testCount = testCount + 1
  if passed = 1 then
    passCount = passCount + 1
    println "[PASS] " + name$
  else
    println "[FAIL] " + name$
  endif
endfunction

function TestCreation() local fx#, p
  println "Testing creation..."
  
  fx# = innerglow#(targetBtn#)
  p = PntToNum(fx#)
  if p <> 0 then
    LogTest("Create inner glow effect", 1)
    innerglow_free(fx#)
  else
    LogTest("Create inner glow effect", 0)
  endif
  
  if innerglow_error() = 0 then
    LogTest("No error after creation", 1)
  else
    LogTest("No error after creation", 0)
  endif
endfunction

function TestColorProperty() local color$, passed
  println "Testing Color property..."
  
  innerglow_color#(ig1#, "Red")
  color$ = innerglow_color$(ig1#)
  passed = 0
  if len(color$) > 0 then
    passed = 1
  endif
  LogTest("Set color to Red", passed)
  
  innerglow_color#(ig1#, "#FF00FF")
  color$ = innerglow_color$(ig1#)
  passed = 0
  if len(color$) > 0 then
    passed = 1
  endif
  LogTest("Set color with hex", passed)
  
  innerglow_color#(ig1#, "Gold")
endfunction

function TestSoftnessProperty() local val, passed
  println "Testing Softness property..."
  
  innerglow_softness#(ig1#, 5.0)
  val = innerglow_softness(ig1#)
  passed = 0
  if val >= 4.5 then
    if val <= 5.5 then
      passed = 1
    endif
  endif
  LogTest("Set softness to 5.0", passed)
  
  ' Test clamping
  innerglow_softness#(ig1#, 15.0)
  val = innerglow_softness(ig1#)
  passed = 0
  if val <= 9.1 then
    passed = 1
  endif
  LogTest("Clamp softness > 9.0", passed)
  
  innerglow_softness#(ig1#, -2.0)
  val = innerglow_softness(ig1#)
  passed = 0
  if val >= 0.0 then
    passed = 1
  endif
  LogTest("Clamp softness < 0.0", passed)
  
  innerglow_softness#(ig1#, 4.0)
endfunction

function TestOpacityProperty() local val, passed
  println "Testing Opacity property..."
  
  innerglow_opacity#(ig1#, 0.6)
  val = innerglow_opacity(ig1#)
  passed = 0
  if val >= 0.55 then
    if val <= 0.65 then
      passed = 1
    endif
  endif
  LogTest("Set opacity to 0.6", passed)
  
  innerglow_opacity#(ig1#, 0.8)
endfunction

function TestEnabledProperty() local val, passed
  println "Testing Enabled property..."
  
  innerglow_enabled#(ig1#, 0)
  val = innerglow_enabled(ig1#)
  passed = 0
  if val = 0 then
    passed = 1
  endif
  LogTest("Disable effect", passed)
  
  innerglow_enabled#(ig1#, 1)
  val = innerglow_enabled(ig1#)
  passed = 0
  if val = 1 then
    passed = 1
  endif
  LogTest("Enable effect", passed)
endfunction

function TestTriggerProperty() local t$, passed
  println "Testing Trigger property..."
  
  innerglow_trigger#(ig1#, "IsMouseOver=true")
  t$ = innerglow_trigger$(ig1#)
  passed = 0
  if t$ = "IsMouseOver=true" then
    passed = 1
  endif
  LogTest("Set trigger string", passed)
  
  innerglow_trigger#(ig1#, "")
  t$ = innerglow_trigger$(ig1#)
  passed = 0
  if t$ = "" then
    passed = 1
  endif
  LogTest("Clear trigger string", passed)
endfunction

function TestErrorHandling() local errCode, errStr$, passed
  println "Testing error handling..."
  
  innerglow_clearerror()
  errCode = innerglow_error()
  passed = 0
  if errCode = 0 then
    passed = 1
  endif
  LogTest("Clear error state", passed)
  
  errStr$ = innerglow_strerror$(0)
  passed = 0
  if instr(errStr$, "No error", 0) >= 0 then
    passed = 1
  endif
  LogTest("Error code 0 message", passed)
  
  errStr$ = innerglow_strerror$(1)
  passed = 0
  if instr(errStr$, "nil", 0) >= 0 then
    passed = 1
  endif
  LogTest("Error code 1 message", passed)
endfunction
