' ============================================================================
' ColorKeyAlphaEffectLib Test and Demo (Revised)
' Version: 1.0.1
' 
' Tests and demonstrates the ColorKey Alpha Effect Library.
' Uses RectangleLib to show actual color transparency effects.
' ============================================================================

' Module-level variables
let frm# = Pointer#(0)
let statusLbl# = Pointer#(0)

' Target control and effect references
let targetRect# = Pointer#(0)
let ck1# = Pointer#(0)

' Test counters
let testCount = 0
let passCount = 0

' ============================================================================
' Main Program
' ============================================================================

println "ColorKeyAlphaEffectLib Test and Demo"
println "===================================="
println ""

frm# = form#("ColorKey Alpha Effect Demo", 700, 550)

' Create a background panel to show transparency
let bgPanel# = panel#(frm#)
panel_bounds#(bgPanel#, 180, 20, 320, 120)

' Create target rectangle with Lime fill (green screen color)
targetRect# = rectangle#(bgPanel#)
rectangle_bounds#(targetRect#, 10, 10, 300, 100)
rectangle_fill#(targetRect#, "Lime")
rectangle_stroke#(targetRect#, "Black")
rectangle_strokethickness#(targetRect#, 2)

' Apply colorkey effect (starts disabled)
ck1# = colorkey#(targetRect#)
colorkey_color#(ck1#, "Lime")
colorkey_tolerance#(ck1#, 0.1)
colorkey_enabled#(ck1#, 0)

' Info section
let infoLbl# = label#(frm#, "ColorKey makes pixels of a specific color transparent (green screen effect)", 100, 150)

' Color selection section
let lbl# = label#(frm#, "Target Color to Remove:", 50, 190)

let btn# = button#(frm#, "Lime")
button_bounds#(btn#, 210, 185, 70, 28)
button_onclick#(btn#, "SetColorLime")

btn# = button#(frm#, "Red")
button_bounds#(btn#, 285, 185, 70, 28)
button_onclick#(btn#, "SetColorRed")

btn# = button#(frm#, "Blue")
button_bounds#(btn#, 360, 185, 70, 28)
button_onclick#(btn#, "SetColorBlue")

btn# = button#(frm#, "White")
button_bounds#(btn#, 435, 185, 70, 28)
button_onclick#(btn#, "SetColorWhite")

' Tolerance section
lbl# = label#(frm#, "Tolerance:", 50, 230)

btn# = button#(frm#, "0.0")
button_bounds#(btn#, 130, 225, 50, 28)
button_onclick#(btn#, "SetTol0")

btn# = button#(frm#, "0.1")
button_bounds#(btn#, 185, 225, 50, 28)
button_onclick#(btn#, "SetTol1")

btn# = button#(frm#, "0.2")
button_bounds#(btn#, 240, 225, 50, 28)
button_onclick#(btn#, "SetTol2")

btn# = button#(frm#, "0.3")
button_bounds#(btn#, 295, 225, 50, 28)
button_onclick#(btn#, "SetTol3")

btn# = button#(frm#, "0.5")
button_bounds#(btn#, 350, 225, 50, 28)
button_onclick#(btn#, "SetTol5")

' Enable/Disable section
btn# = button#(frm#, "Enable Effect")
button_bounds#(btn#, 50, 275, 120, 35)
button_onclick#(btn#, "EnableEffect")

btn# = button#(frm#, "Disable Effect")
button_bounds#(btn#, 180, 275, 120, 35)
button_onclick#(btn#, "DisableEffect")

btn# = button#(frm#, "Run Tests")
button_bounds#(btn#, 310, 275, 100, 35)
button_onclick#(btn#, "RunTests")

' Change rectangle color section
lbl# = label#(frm#, "Change Rectangle Fill Color:", 50, 330)

btn# = button#(frm#, "Lime")
button_bounds#(btn#, 220, 325, 60, 28)
button_onclick#(btn#, "FillLime")

btn# = button#(frm#, "Red")
button_bounds#(btn#, 285, 325, 60, 28)
button_onclick#(btn#, "FillRed")

btn# = button#(frm#, "Blue")
button_bounds#(btn#, 350, 325, 60, 28)
button_onclick#(btn#, "FillBlue")

btn# = button#(frm#, "Yellow")
button_bounds#(btn#, 415, 325, 60, 28)
button_onclick#(btn#, "FillYellow")

' Color gallery demonstration
lbl# = label#(frm#, "Gallery - Apply ColorKey (Lime) to see which rectangles disappear:", 50, 380)
CreateColorGallery()

' Status bar
statusLbl# = label#(frm#, "Enable effect to see Lime-colored areas become transparent", 50, 510)

form_show(frm#)

' ============================================================================
' Color Gallery - Different colored rectangles with same ColorKey
' ============================================================================

function CreateColorGallery() local i, galleryRect#, galleryCk#, color$, lblColor#
  ' Create 5 rectangles with different fill colors
  ' All have ColorKey set to Lime - only Lime rectangle will disappear
  
  i = 0
  while i < 5
    galleryRect# = rectangle#(frm#)
    rectangle_bounds#(galleryRect#, 50 + i * 120, 410, 100, 70)
    rectangle_strokethickness#(galleryRect#, 1)
    rectangle_stroke#(galleryRect#, "Black")
    
    if i = 0 then
      color$ = "Lime"
    endif
    if i = 1 then
      color$ = "Red"
    endif
    if i = 2 then
      color$ = "Blue"
    endif
    if i = 3 then
      color$ = "Yellow"
    endif
    if i = 4 then
      color$ = "Lime"
    endif
    
    rectangle_fill#(galleryRect#, color$)
    
    ' Apply ColorKey effect targeting Lime
    galleryCk# = colorkey#(galleryRect#)
    colorkey_color#(galleryCk#, "Lime")
    colorkey_tolerance#(galleryCk#, 0.1)
    
    lblColor# = label#(frm#, color$, 75 + i * 120, 485)
    
    i = i + 1
  endwhile
endfunction

' ============================================================================
' Color Selection Functions (ColorKey target)
' ============================================================================

function SetColorLime(sender#)
  colorkey_color#(ck1#, "Lime")
  label_text#(statusLbl#, "ColorKey target: Lime (green screen)")
endfunction

function SetColorRed(sender#)
  colorkey_color#(ck1#, "Red")
  label_text#(statusLbl#, "ColorKey target: Red")
endfunction

function SetColorBlue(sender#)
  colorkey_color#(ck1#, "Blue")
  label_text#(statusLbl#, "ColorKey target: Blue")
endfunction

function SetColorWhite(sender#)
  colorkey_color#(ck1#, "White")
  label_text#(statusLbl#, "ColorKey target: White")
endfunction

' ============================================================================
' Rectangle Fill Functions
' ============================================================================

function FillLime(sender#)
  rectangle_fill#(targetRect#, "Lime")
  label_text#(statusLbl#, "Rectangle fill: Lime - will match Lime ColorKey")
endfunction

function FillRed(sender#)
  rectangle_fill#(targetRect#, "Red")
  label_text#(statusLbl#, "Rectangle fill: Red - won't match Lime ColorKey")
endfunction

function FillBlue(sender#)
  rectangle_fill#(targetRect#, "Blue")
  label_text#(statusLbl#, "Rectangle fill: Blue - won't match Lime ColorKey")
endfunction

function FillYellow(sender#)
  rectangle_fill#(targetRect#, "Yellow")
  label_text#(statusLbl#, "Rectangle fill: Yellow - won't match Lime ColorKey")
endfunction

' ============================================================================
' Tolerance Functions
' ============================================================================

function SetTol0(sender#)
  colorkey_tolerance#(ck1#, 0.0)
  label_text#(statusLbl#, "Tolerance: 0.0 (exact match only)")
endfunction

function SetTol1(sender#)
  colorkey_tolerance#(ck1#, 0.1)
  label_text#(statusLbl#, "Tolerance: 0.1 (tight)")
endfunction

function SetTol2(sender#)
  colorkey_tolerance#(ck1#, 0.2)
  label_text#(statusLbl#, "Tolerance: 0.2 (moderate)")
endfunction

function SetTol3(sender#)
  colorkey_tolerance#(ck1#, 0.3)
  label_text#(statusLbl#, "Tolerance: 0.3 (loose)")
endfunction

function SetTol5(sender#)
  colorkey_tolerance#(ck1#, 0.5)
  label_text#(statusLbl#, "Tolerance: 0.5 (very loose)")
endfunction

' ============================================================================
' Enable/Disable Functions
' ============================================================================

function EnableEffect(sender#)
  colorkey_enabled#(ck1#, 1)
  label_text#(statusLbl#, "Effect enabled - matching color pixels are now transparent!")
endfunction

function DisableEffect(sender#)
  colorkey_enabled#(ck1#, 0)
  label_text#(statusLbl#, "Effect disabled - rectangle shows original color")
endfunction

' ============================================================================
' Test Functions
' ============================================================================

function RunTests(sender#)
  testCount = 0
  passCount = 0
  
  println ""
  println "=== ColorKeyAlphaEffectLib Tests ==="
  println ""
  
  TestCreation()
  TestColorProperty()
  TestToleranceProperty()
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
  
  fx# = colorkey#(targetRect#)
  p = PntToNum(fx#)
  if p <> 0 then
    LogTest("Create colorkey effect", 1)
    colorkey_free(fx#)
  else
    LogTest("Create colorkey effect", 0)
  endif
  
  if colorkey_error() = 0 then
    LogTest("No error after creation", 1)
  else
    LogTest("No error after creation", 0)
  endif
endfunction

function TestColorProperty() local color$, passed
  println "Testing Color property..."
  
  colorkey_color#(ck1#, "Red")
  color$ = colorkey_color$(ck1#)
  passed = 0
  if len(color$) > 0 then
    passed = 1
  endif
  LogTest("Set color to Red", passed)
  
  colorkey_color#(ck1#, "#00FF00")
  color$ = colorkey_color$(ck1#)
  passed = 0
  if len(color$) > 0 then
    passed = 1
  endif
  LogTest("Set color with hex", passed)
  
  ' Reset to Lime
  colorkey_color#(ck1#, "Lime")
endfunction

function TestToleranceProperty() local val, passed
  println "Testing Tolerance property..."
  
  colorkey_tolerance#(ck1#, 0.25)
  val = colorkey_tolerance(ck1#)
  passed = 0
  if val >= 0.20 then
    if val <= 0.30 then
      passed = 1
    endif
  endif
  LogTest("Set tolerance to 0.25", passed)
  
  ' Test clamping
  colorkey_tolerance#(ck1#, 1.5)
  val = colorkey_tolerance(ck1#)
  passed = 0
  if val <= 1.01 then
    passed = 1
  endif
  LogTest("Clamp tolerance > 1.0", passed)
  
  colorkey_tolerance#(ck1#, -0.5)
  val = colorkey_tolerance(ck1#)
  passed = 0
  if val >= 0.0 then
    passed = 1
  endif
  LogTest("Clamp tolerance < 0.0", passed)
  
  colorkey_tolerance#(ck1#, 0.1)
endfunction

function TestEnabledProperty() local val, passed
  println "Testing Enabled property..."
  
  colorkey_enabled#(ck1#, 0)
  val = colorkey_enabled(ck1#)
  passed = 0
  if val = 0 then
    passed = 1
  endif
  LogTest("Disable effect", passed)
  
  colorkey_enabled#(ck1#, 1)
  val = colorkey_enabled(ck1#)
  passed = 0
  if val = 1 then
    passed = 1
  endif
  LogTest("Enable effect", passed)
  
  colorkey_enabled#(ck1#, 0)
endfunction

function TestTriggerProperty() local t$, passed
  println "Testing Trigger property..."
  
  colorkey_trigger#(ck1#, "IsMouseOver=true")
  t$ = colorkey_trigger$(ck1#)
  passed = 0
  if t$ = "IsMouseOver=true" then
    passed = 1
  endif
  LogTest("Set trigger string", passed)
  
  colorkey_trigger#(ck1#, "")
  t$ = colorkey_trigger$(ck1#)
  passed = 0
  if t$ = "" then
    passed = 1
  endif
  LogTest("Clear trigger string", passed)
endfunction

function TestErrorHandling() local errCode, errStr$, passed
  println "Testing error handling..."
  
  colorkey_clearerror()
  errCode = colorkey_error()
  passed = 0
  if errCode = 0 then
    passed = 1
  endif
  LogTest("Clear error state", passed)
  
  errStr$ = colorkey_strerror$(0)
  passed = 0
  if instr(errStr$, "No error", 0) >= 0 then
    passed = 1
  endif
  LogTest("Error code 0 message", passed)
  
  errStr$ = colorkey_strerror$(1)
  passed = 0
  if instr(errStr$, "nil", 0) >= 0 then
    passed = 1
  endif
  LogTest("Error code 1 message", passed)
endfunction
