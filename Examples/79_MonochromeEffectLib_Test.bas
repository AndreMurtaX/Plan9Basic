' ============================================================================
' MonochromeEffectLib Test and Demo
' Version: 1.0.0
' 
' Tests and demonstrates the Monochrome Effect Library.
' Uses: form, panel, button, label (no rectangle dependencies)
' ============================================================================

' Module-level variables
let frm# = Pointer#(0)
let statusLbl# = Pointer#(0)

' Target control and effect references
let targetBtn# = Pointer#(0)
let mono1# = Pointer#(0)

' Test counters
let testCount = 0
let passCount = 0

' ============================================================================
' Main Program
' ============================================================================

println "MonochromeEffectLib Test and Demo"
println "================================="
println ""

frm# = form#("Monochrome Effect Demo", 600, 450)

' Create target button
targetBtn# = button#(frm#, "Target Button (Colorful)")
button_bounds#(targetBtn#, 180, 40, 220, 60)

' Apply monochrome effect (starts disabled)
mono1# = monochrome#(targetBtn#)
monochrome_enabled#(mono1#, 0)

' Info section
let infoLbl# = label#(frm#, "Monochrome converts controls to grayscale", 150, 120)

' Control buttons
let btn# = button#(frm#, "Enable Grayscale")
button_bounds#(btn#, 80, 160, 140, 35)
button_onclick#(btn#, "EnableMono")

btn# = button#(frm#, "Disable Grayscale")
button_bounds#(btn#, 230, 160, 140, 35)
button_onclick#(btn#, "DisableMono")

btn# = button#(frm#, "Toggle Effect")
button_bounds#(btn#, 380, 160, 120, 35)
button_onclick#(btn#, "ToggleMono")

' Run tests button
btn# = button#(frm#, "Run Tests")
button_bounds#(btn#, 80, 210, 100, 35)
button_onclick#(btn#, "RunTests")

' Example sections
let lbl# = label#(frm#, "Disabled State Simulation:", 50, 270)
CreateDisabledDemo()

lbl# = label#(frm#, "Hover-Based (Inverse):", 320, 270)
CreateHoverDemo()

lbl# = label#(frm#, "Gallery (Alternating):", 50, 360)
CreateGallery()

' Status bar
statusLbl# = label#(frm#, "Use controls above to toggle monochrome effect", 50, 420)

form_show(frm#)

' ============================================================================
' Demo Sections
' ============================================================================

function CreateDisabledDemo() local activeBtn#, disabledBtn#, disabledMono#
  activeBtn# = button#(frm#, "Active")
  button_bounds#(activeBtn#, 50, 295, 100, 35)
  
  disabledBtn# = button#(frm#, "Disabled Look")
  button_bounds#(disabledBtn#, 160, 295, 120, 35)
  disabledMono# = monochrome#(disabledBtn#)
endfunction

function CreateHoverDemo() local hoverBtn#, hoverMono#
  hoverBtn# = button#(frm#, "Hover for Color!")
  button_bounds#(hoverBtn#, 320, 295, 150, 35)
  
  ' Grayscale when NOT hovered (inverse)
  hoverMono# = monochrome#(hoverBtn#)
  monochrome_trigger#(hoverMono#, "IsMouseOver=false")
endfunction

function CreateGallery() local i, galleryBtn#, galleryMono#, remainder
  i = 0
  while i < 5
    galleryBtn# = button#(frm#, "G" + str$(i + 1))
    button_bounds#(galleryBtn#, 50 + i * 70, 385, 60, 30)
    
    ' Alternate: items 1, 3, 5 are grayscale
    remainder = i - (i / 2) * 2
    if remainder = 0 then
      galleryMono# = monochrome#(galleryBtn#)
    endif
    
    i = i + 1
  endwhile
endfunction

' ============================================================================
' Control Functions
' ============================================================================

function EnableMono(sender#)
  monochrome_enabled#(mono1#, 1)
  button_text#(targetBtn#, "Target Button (Grayscale)")
  label_text#(statusLbl#, "Monochrome enabled - button is grayscale")
endfunction

function DisableMono(sender#)
  monochrome_enabled#(mono1#, 0)
  button_text#(targetBtn#, "Target Button (Colorful)")
  label_text#(statusLbl#, "Monochrome disabled - button shows color")
endfunction

function ToggleMono(sender#) local enabled
  enabled = monochrome_enabled(mono1#)
  if enabled = 1 then
    monochrome_enabled#(mono1#, 0)
    button_text#(targetBtn#, "Target Button (Colorful)")
    label_text#(statusLbl#, "Toggled to: Color")
  else
    monochrome_enabled#(mono1#, 1)
    button_text#(targetBtn#, "Target Button (Grayscale)")
    label_text#(statusLbl#, "Toggled to: Grayscale")
  endif
endfunction

' ============================================================================
' Test Functions
' ============================================================================

function RunTests(sender#)
  testCount = 0
  passCount = 0
  
  println ""
  println "=== MonochromeEffectLib Tests ==="
  println ""
  
  TestCreation()
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
  
  fx# = monochrome#(targetBtn#)
  p = PntToNum(fx#)
  if p <> 0 then
    LogTest("Create monochrome effect", 1)
    monochrome_free(fx#)
  else
    LogTest("Create monochrome effect", 0)
  endif
  
  if monochrome_error() = 0 then
    LogTest("No error after creation", 1)
  else
    LogTest("No error after creation", 0)
  endif
endfunction

function TestEnabledProperty() local val, passed
  println "Testing Enabled property..."
  
  monochrome_enabled#(mono1#, 0)
  val = monochrome_enabled(mono1#)
  passed = 0
  if val = 0 then
    passed = 1
  endif
  LogTest("Disable effect", passed)
  
  monochrome_enabled#(mono1#, 1)
  val = monochrome_enabled(mono1#)
  passed = 0
  if val = 1 then
    passed = 1
  endif
  LogTest("Enable effect", passed)
  
  ' Reset to disabled for demo
  monochrome_enabled#(mono1#, 0)
  button_text#(targetBtn#, "Target Button (Colorful)")
endfunction

function TestTriggerProperty() local t$, passed
  println "Testing Trigger property..."
  
  monochrome_trigger#(mono1#, "IsMouseOver=true")
  t$ = monochrome_trigger$(mono1#)
  passed = 0
  if t$ = "IsMouseOver=true" then
    passed = 1
  endif
  LogTest("Set trigger string", passed)
  
  monochrome_trigger#(mono1#, "")
  t$ = monochrome_trigger$(mono1#)
  passed = 0
  if t$ = "" then
    passed = 1
  endif
  LogTest("Clear trigger string", passed)
endfunction

function TestErrorHandling() local errCode, errStr$, passed
  println "Testing error handling..."
  
  monochrome_clearerror()
  errCode = monochrome_error()
  passed = 0
  if errCode = 0 then
    passed = 1
  endif
  LogTest("Clear error state", passed)
  
  errStr$ = monochrome_strerror$(0)
  passed = 0
  if instr(errStr$, "No error", 0) >= 0 then
    passed = 1
  endif
  LogTest("Error code 0 message", passed)
  
  errStr$ = monochrome_strerror$(1)
  passed = 0
  if instr(errStr$, "nil", 0) >= 0 then
    passed = 1
  endif
  LogTest("Error code 1 message", passed)
endfunction
