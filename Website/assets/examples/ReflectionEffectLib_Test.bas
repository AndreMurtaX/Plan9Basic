' ============================================================================
' ReflectionEffectLib Test and Demo
' Version: 1.0.0
' 
' Tests and demonstrates the Reflection Effect Library.
' Uses: form, panel, button, label (no rectangle dependencies)
' ============================================================================

' Module-level variables
let frm# = Pointer#(0)
let statusLbl# = Pointer#(0)

' Target control and effect references
let targetBtn# = Pointer#(0)
let refl1# = Pointer#(0)

' Test counters
let testCount = 0
let passCount = 0

' ============================================================================
' Main Program
' ============================================================================

println "ReflectionEffectLib Test and Demo"
println "================================="
println ""

frm# = form#("Reflection Effect Demo", 650, 500)

' Create target button for reflection
targetBtn# = button#(frm#, "Button with Reflection")
button_bounds#(targetBtn#, 220, 40, 200, 70)

' Apply reflection effect
refl1# = reflection#(targetBtn#)
reflection_length#(refl1#, 0.5)
reflection_opacity#(refl1#, 0.4)
reflection_offset#(refl1#, 2)

' Info section
let infoLbl# = label#(frm#, "Reflection creates a mirror effect below controls", 150, 140)

' Length controls
let lbl# = label#(frm#, "Length:", 50, 180)

let btn# = button#(frm#, "25%")
button_bounds#(btn#, 110, 175, 50, 28)
button_onclick#(btn#, "SetLen25")

btn# = button#(frm#, "50%")
button_bounds#(btn#, 165, 175, 50, 28)
button_onclick#(btn#, "SetLen50")

btn# = button#(frm#, "75%")
button_bounds#(btn#, 220, 175, 50, 28)
button_onclick#(btn#, "SetLen75")

btn# = button#(frm#, "100%")
button_bounds#(btn#, 275, 175, 50, 28)
button_onclick#(btn#, "SetLen100")

' Opacity controls
lbl# = label#(frm#, "Opacity:", 50, 220)

btn# = button#(frm#, "20%")
button_bounds#(btn#, 110, 215, 50, 28)
button_onclick#(btn#, "SetOp20")

btn# = button#(frm#, "40%")
button_bounds#(btn#, 165, 215, 50, 28)
button_onclick#(btn#, "SetOp40")

btn# = button#(frm#, "60%")
button_bounds#(btn#, 220, 215, 50, 28)
button_onclick#(btn#, "SetOp60")

btn# = button#(frm#, "80%")
button_bounds#(btn#, 275, 215, 50, 28)
button_onclick#(btn#, "SetOp80")

' Offset controls
lbl# = label#(frm#, "Offset:", 50, 260)

btn# = button#(frm#, "0px")
button_bounds#(btn#, 110, 255, 50, 28)
button_onclick#(btn#, "SetOff0")

btn# = button#(frm#, "4px")
button_bounds#(btn#, 165, 255, 50, 28)
button_onclick#(btn#, "SetOff4")

btn# = button#(frm#, "8px")
button_bounds#(btn#, 220, 255, 50, 28)
button_onclick#(btn#, "SetOff8")

btn# = button#(frm#, "16px")
button_bounds#(btn#, 275, 255, 50, 28)
button_onclick#(btn#, "SetOff16")

' Enable/Disable
btn# = button#(frm#, "Toggle Effect")
button_bounds#(btn#, 50, 300, 120, 30)
button_onclick#(btn#, "ToggleEffect")

' Animation
btn# = button#(frm#, "Animate Opacity")
button_bounds#(btn#, 180, 300, 120, 30)
button_onclick#(btn#, "AnimateOpacity")

' Run tests
btn# = button#(frm#, "Run Tests")
button_bounds#(btn#, 310, 300, 100, 30)
button_onclick#(btn#, "RunTests")

' Gallery section
lbl# = label#(frm#, "Gallery with varying reflections:", 50, 360)
CreateGallery()

' Hover example
lbl# = label#(frm#, "Hover-triggered reflection:", 400, 360)
CreateHoverExample()

' Status bar
statusLbl# = label#(frm#, "Adjust reflection properties using the controls above", 50, 460)

form_show(frm#)

' ============================================================================
' Gallery Creation
' ============================================================================

function CreateGallery() local i, galleryBtn#, galleryRefl#
  i = 0
  while i < 4
    galleryBtn# = button#(frm#, "G" + str$(i + 1))
    button_bounds#(galleryBtn#, 50 + i * 85, 390, 75, 40)
    
    galleryRefl# = reflection#(galleryBtn#)
    reflection_length#(galleryRefl#, 0.25 + i * 0.2)
    reflection_opacity#(galleryRefl#, 0.3)
    reflection_offset#(galleryRefl#, 2)
    
    i = i + 1
  endwhile
endfunction

' ============================================================================
' Hover Example
' ============================================================================

function CreateHoverExample() local hoverBtn#, hoverRefl#
  hoverBtn# = button#(frm#, "Hover Me!")
  button_bounds#(hoverBtn#, 420, 390, 120, 40)
  
  hoverRefl# = reflection#(hoverBtn#)
  reflection_length#(hoverRefl#, 0.5)
  reflection_opacity#(hoverRefl#, 0.5)
  reflection_trigger#(hoverRefl#, "IsMouseOver=true")
endfunction

' ============================================================================
' Length Control Functions
' ============================================================================

function SetLen25(sender#)
  reflection_length#(refl1#, 0.25)
  label_text#(statusLbl#, "Length: 25%")
endfunction

function SetLen50(sender#)
  reflection_length#(refl1#, 0.50)
  label_text#(statusLbl#, "Length: 50%")
endfunction

function SetLen75(sender#)
  reflection_length#(refl1#, 0.75)
  label_text#(statusLbl#, "Length: 75%")
endfunction

function SetLen100(sender#)
  reflection_length#(refl1#, 1.0)
  label_text#(statusLbl#, "Length: 100%")
endfunction

' ============================================================================
' Opacity Control Functions
' ============================================================================

function SetOp20(sender#)
  reflection_opacity#(refl1#, 0.20)
  label_text#(statusLbl#, "Opacity: 20%")
endfunction

function SetOp40(sender#)
  reflection_opacity#(refl1#, 0.40)
  label_text#(statusLbl#, "Opacity: 40%")
endfunction

function SetOp60(sender#)
  reflection_opacity#(refl1#, 0.60)
  label_text#(statusLbl#, "Opacity: 60%")
endfunction

function SetOp80(sender#)
  reflection_opacity#(refl1#, 0.80)
  label_text#(statusLbl#, "Opacity: 80%")
endfunction

' ============================================================================
' Offset Control Functions
' ============================================================================

function SetOff0(sender#)
  reflection_offset#(refl1#, 0)
  label_text#(statusLbl#, "Offset: 0 pixels")
endfunction

function SetOff4(sender#)
  reflection_offset#(refl1#, 4)
  label_text#(statusLbl#, "Offset: 4 pixels")
endfunction

function SetOff8(sender#)
  reflection_offset#(refl1#, 8)
  label_text#(statusLbl#, "Offset: 8 pixels")
endfunction

function SetOff16(sender#)
  reflection_offset#(refl1#, 16)
  label_text#(statusLbl#, "Offset: 16 pixels")
endfunction

' ============================================================================
' Toggle and Animation
' ============================================================================

function ToggleEffect(sender#) local enabled
  enabled = reflection_enabled(refl1#)
  if enabled = 1 then
    reflection_enabled#(refl1#, 0)
    label_text#(statusLbl#, "Effect disabled")
  else
    reflection_enabled#(refl1#, 1)
    label_text#(statusLbl#, "Effect enabled")
  endif
endfunction

function AnimateOpacity(sender#) local ani#
  ani# = floatani#(refl1#)
  floatani_propertyname#(ani#, "Opacity")
  floatani_startvalue#(ani#, 0.1)
  floatani_stopvalue#(ani#, 0.8)
  floatani_duration#(ani#, 1.5)
  floatani_autoreverse#(ani#, 1)
  floatani_start(ani#)
  
  label_text#(statusLbl#, "Animating opacity...")
endfunction

' ============================================================================
' Test Functions
' ============================================================================

function RunTests(sender#)
  testCount = 0
  passCount = 0
  
  println ""
  println "=== ReflectionEffectLib Tests ==="
  println ""
  
  TestCreation()
  TestLengthProperty()
  TestOpacityProperty()
  TestOffsetProperty()
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
  
  fx# = reflection#(targetBtn#)
  p = PntToNum(fx#)
  if p <> 0 then
    LogTest("Create reflection effect", 1)
    reflection_free(fx#)
  else
    LogTest("Create reflection effect", 0)
  endif
  
  if reflection_error() = 0 then
    LogTest("No error after creation", 1)
  else
    LogTest("No error after creation", 0)
  endif
endfunction

function TestLengthProperty() local val, passed
  println "Testing Length property..."
  
  reflection_length#(refl1#, 0.6)
  val = reflection_length(refl1#)
  passed = 0
  if val >= 0.55 then
    if val <= 0.65 then
      passed = 1
    endif
  endif
  LogTest("Set length to 0.6", passed)
  
  ' Test clamping
  reflection_length#(refl1#, 1.5)
  val = reflection_length(refl1#)
  passed = 0
  if val <= 1.01 then
    passed = 1
  endif
  LogTest("Clamp length > 1.0", passed)
  
  reflection_length#(refl1#, -0.5)
  val = reflection_length(refl1#)
  passed = 0
  if val >= 0.0 then
    passed = 1
  endif
  LogTest("Clamp length < 0.0", passed)
  
  reflection_length#(refl1#, 0.5)
endfunction

function TestOpacityProperty() local val, passed
  println "Testing Opacity property..."
  
  reflection_opacity#(refl1#, 0.7)
  val = reflection_opacity(refl1#)
  passed = 0
  if val >= 0.65 then
    if val <= 0.75 then
      passed = 1
    endif
  endif
  LogTest("Set opacity to 0.7", passed)
  
  reflection_opacity#(refl1#, 0.4)
endfunction

function TestOffsetProperty() local val, passed
  println "Testing Offset property..."
  
  reflection_offset#(refl1#, 10)
  val = reflection_offset(refl1#)
  passed = 0
  if val = 10 then
    passed = 1
  endif
  LogTest("Set offset to 10", passed)
  
  reflection_offset#(refl1#, 2)
endfunction

function TestEnabledProperty() local val, passed
  println "Testing Enabled property..."
  
  reflection_enabled#(refl1#, 0)
  val = reflection_enabled(refl1#)
  passed = 0
  if val = 0 then
    passed = 1
  endif
  LogTest("Disable effect", passed)
  
  reflection_enabled#(refl1#, 1)
  val = reflection_enabled(refl1#)
  passed = 0
  if val = 1 then
    passed = 1
  endif
  LogTest("Enable effect", passed)
endfunction

function TestTriggerProperty() local t$, passed
  println "Testing Trigger property..."
  
  reflection_trigger#(refl1#, "IsMouseOver=true")
  t$ = reflection_trigger$(refl1#)
  passed = 0
  if t$ = "IsMouseOver=true" then
    passed = 1
  endif
  LogTest("Set trigger string", passed)
  
  reflection_trigger#(refl1#, "")
endfunction

function TestErrorHandling() local errCode, errStr$, passed
  println "Testing error handling..."
  
  reflection_clearerror()
  errCode = reflection_error()
  passed = 0
  if errCode = 0 then
    passed = 1
  endif
  LogTest("Clear error state", passed)
  
  errStr$ = reflection_strerror$(0)
  passed = 0
  if instr(errStr$, "No error", 0) >= 0 then
    passed = 1
  endif
  LogTest("Error code 0 message", passed)
endfunction
