' ============================================================================
' BevelEffectLib Test and Demo
' Version: 1.0.0
' 
' Tests and demonstrates the Bevel Effect Library.
' Uses: form, panel, button, label (no rectangle dependencies)
' ============================================================================

' Module-level variables
let frm# = Pointer#(0)
let statusLbl# = Pointer#(0)

' Target control and effect references
let targetBtn# = Pointer#(0)
let bvl1# = Pointer#(0)

' Test counters
let testCount = 0
let passCount = 0

' ============================================================================
' Main Program
' ============================================================================

println "BevelEffectLib Test and Demo"
println "============================"
println ""

frm# = form#("Bevel Effect Demo", 650, 500)

' Create target button
targetBtn# = button#(frm#, "Beveled Button")
button_bounds#(targetBtn#, 210, 30, 200, 70)

' Apply bevel effect
bvl1# = bevel#(targetBtn#)
bevel_direction#(bvl1#, 45)
bevel_size#(bvl1#, 3)

' Info section
let infoLbl# = label#(frm#, "Bevel creates a 3D raised or sunken appearance", 150, 120)

' Direction controls
let lbl# = label#(frm#, "Direction:", 50, 165)

let btn# = button#(frm#, "45")
button_bounds#(btn#, 130, 160, 45, 28)
button_onclick#(btn#, "SetDir45")

btn# = button#(frm#, "90")
button_bounds#(btn#, 180, 160, 45, 28)
button_onclick#(btn#, "SetDir90")

btn# = button#(frm#, "135")
button_bounds#(btn#, 230, 160, 45, 28)
button_onclick#(btn#, "SetDir135")

btn# = button#(frm#, "180")
button_bounds#(btn#, 280, 160, 45, 28)
button_onclick#(btn#, "SetDir180")

btn# = button#(frm#, "225")
button_bounds#(btn#, 330, 160, 45, 28)
button_onclick#(btn#, "SetDir225")

btn# = button#(frm#, "270")
button_bounds#(btn#, 380, 160, 45, 28)
button_onclick#(btn#, "SetDir270")

btn# = button#(frm#, "315")
button_bounds#(btn#, 430, 160, 45, 28)
button_onclick#(btn#, "SetDir315")

' Size controls
lbl# = label#(frm#, "Size:", 50, 205)

btn# = button#(frm#, "1")
button_bounds#(btn#, 100, 200, 40, 28)
button_onclick#(btn#, "SetSize1")

btn# = button#(frm#, "2")
button_bounds#(btn#, 145, 200, 40, 28)
button_onclick#(btn#, "SetSize2")

btn# = button#(frm#, "3")
button_bounds#(btn#, 190, 200, 40, 28)
button_onclick#(btn#, "SetSize3")

btn# = button#(frm#, "5")
button_bounds#(btn#, 235, 200, 40, 28)
button_onclick#(btn#, "SetSize5")

btn# = button#(frm#, "7")
button_bounds#(btn#, 280, 200, 40, 28)
button_onclick#(btn#, "SetSize7")

btn# = button#(frm#, "10")
button_bounds#(btn#, 325, 200, 40, 28)
button_onclick#(btn#, "SetSize10")

' Action buttons
btn# = button#(frm#, "Toggle Effect")
button_bounds#(btn#, 50, 250, 110, 35)
button_onclick#(btn#, "ToggleEffect")

btn# = button#(frm#, "Rotate Light")
button_bounds#(btn#, 170, 250, 110, 35)
button_onclick#(btn#, "AnimateRotate")

btn# = button#(frm#, "Run Tests")
button_bounds#(btn#, 290, 250, 100, 35)
button_onclick#(btn#, "RunTests")

' Raised vs Sunken section
lbl# = label#(frm#, "Raised vs Sunken comparison:", 50, 310)
CreateRaisedSunkenDemo()

' Size gallery
lbl# = label#(frm#, "Size comparison gallery:", 50, 400)
CreateSizeGallery()

' Status bar
statusLbl# = label#(frm#, "Adjust bevel direction and size using the controls above", 50, 460)

form_show(frm#)

' ============================================================================
' Demo Sections
' ============================================================================

function CreateRaisedSunkenDemo() local raisedBtn#, sunkenBtn#, bvlR#, bvlS#, lblR#, lblS#
  raisedBtn# = button#(frm#, "Raised")
  button_bounds#(raisedBtn#, 50, 335, 120, 50)
  bvlR# = bevel#(raisedBtn#)
  bevel_direction#(bvlR#, 45)
  bevel_size#(bvlR#, 3)
  lblR# = label#(frm#, "Dir: 45", 80, 388)
  
  sunkenBtn# = button#(frm#, "Sunken")
  button_bounds#(sunkenBtn#, 200, 335, 120, 50)
  bvlS# = bevel#(sunkenBtn#)
  bevel_direction#(bvlS#, 225)
  bevel_size#(bvlS#, 3)
  lblS# = label#(frm#, "Dir: 225", 225, 388)
endfunction

function CreateSizeGallery() local i, galleryBtn#, galleryBvl#, size
  i = 0
  while i < 5
    galleryBtn# = button#(frm#, "S" + str$(i + 1))
    button_bounds#(galleryBtn#, 50 + i * 85, 425, 75, 35)
    
    galleryBvl# = bevel#(galleryBtn#)
    size = (i + 1) * 2
    bevel_direction#(galleryBvl#, 45)
    bevel_size#(galleryBvl#, size)
    
    i = i + 1
  endwhile
endfunction

' ============================================================================
' Direction Control Functions
' ============================================================================

function SetDir45(sender#)
  bevel_direction#(bvl1#, 45)
  label_text#(statusLbl#, "Direction: 45 (Top-Right, Raised)")
endfunction

function SetDir90(sender#)
  bevel_direction#(bvl1#, 90)
  label_text#(statusLbl#, "Direction: 90 (Top)")
endfunction

function SetDir135(sender#)
  bevel_direction#(bvl1#, 135)
  label_text#(statusLbl#, "Direction: 135 (Top-Left)")
endfunction

function SetDir180(sender#)
  bevel_direction#(bvl1#, 180)
  label_text#(statusLbl#, "Direction: 180 (Left)")
endfunction

function SetDir225(sender#)
  bevel_direction#(bvl1#, 225)
  label_text#(statusLbl#, "Direction: 225 (Bottom-Left, Sunken)")
endfunction

function SetDir270(sender#)
  bevel_direction#(bvl1#, 270)
  label_text#(statusLbl#, "Direction: 270 (Bottom)")
endfunction

function SetDir315(sender#)
  bevel_direction#(bvl1#, 315)
  label_text#(statusLbl#, "Direction: 315 (Bottom-Right)")
endfunction

' ============================================================================
' Size Control Functions
' ============================================================================

function SetSize1(sender#)
  bevel_size#(bvl1#, 1)
  label_text#(statusLbl#, "Size: 1 pixel (subtle)")
endfunction

function SetSize2(sender#)
  bevel_size#(bvl1#, 2)
  label_text#(statusLbl#, "Size: 2 pixels")
endfunction

function SetSize3(sender#)
  bevel_size#(bvl1#, 3)
  label_text#(statusLbl#, "Size: 3 pixels")
endfunction

function SetSize5(sender#)
  bevel_size#(bvl1#, 5)
  label_text#(statusLbl#, "Size: 5 pixels")
endfunction

function SetSize7(sender#)
  bevel_size#(bvl1#, 7)
  label_text#(statusLbl#, "Size: 7 pixels")
endfunction

function SetSize10(sender#)
  bevel_size#(bvl1#, 10)
  label_text#(statusLbl#, "Size: 10 pixels (maximum)")
endfunction

' ============================================================================
' Toggle and Animation
' ============================================================================

function ToggleEffect(sender#) local enabled
  enabled = bevel_enabled(bvl1#)
  if enabled = 1 then
    bevel_enabled#(bvl1#, 0)
    label_text#(statusLbl#, "Effect disabled")
  else
    bevel_enabled#(bvl1#, 1)
    label_text#(statusLbl#, "Effect enabled")
  endif
endfunction

function AnimateRotate(sender#) local ani#
  ani# = floatani#(bvl1#)
  floatani_propertyname#(ani#, "Direction")
  floatani_startvalue#(ani#, 0)
  floatani_stopvalue#(ani#, 360)
  floatani_duration#(ani#, 3)
  floatani_loop#(ani#, 1)
  floatani_start(ani#)
  
  label_text#(statusLbl#, "Rotating light animation started...")
endfunction

' ============================================================================
' Test Functions
' ============================================================================

function RunTests(sender#)
  testCount = 0
  passCount = 0
  
  println ""
  println "=== BevelEffectLib Tests ==="
  println ""
  
  TestCreation()
  TestDirectionProperty()
  TestSizeProperty()
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
  
  fx# = bevel#(targetBtn#)
  p = PntToNum(fx#)
  if p <> 0 then
    LogTest("Create bevel effect", 1)
    bevel_free(fx#)
  else
    LogTest("Create bevel effect", 0)
  endif
  
  if bevel_error() = 0 then
    LogTest("No error after creation", 1)
  else
    LogTest("No error after creation", 0)
  endif
endfunction

function TestDirectionProperty() local val, passed
  println "Testing Direction property..."
  
  bevel_direction#(bvl1#, 90)
  val = bevel_direction(bvl1#)
  passed = 0
  if val >= 85 then
    if val <= 95 then
      passed = 1
    endif
  endif
  LogTest("Set direction to 90", passed)
  
  ' Test normalization for values > 360
  bevel_direction#(bvl1#, 450)
  val = bevel_direction(bvl1#)
  passed = 0
  if val >= 85 then
    if val <= 95 then
      passed = 1
    endif
  endif
  LogTest("Normalize direction > 360", passed)
  
  ' Test normalization for negative values
  bevel_direction#(bvl1#, -45)
  val = bevel_direction(bvl1#)
  passed = 0
  if val >= 310 then
    if val <= 320 then
      passed = 1
    endif
  endif
  LogTest("Normalize negative direction", passed)
  
  bevel_direction#(bvl1#, 45)
endfunction

function TestSizeProperty() local val, passed
  println "Testing Size property..."
  
  bevel_size#(bvl1#, 5)
  val = bevel_size(bvl1#)
  passed = 0
  if val >= 4.5 then
    if val <= 5.5 then
      passed = 1
    endif
  endif
  LogTest("Set size to 5", passed)
  
  ' Test clamping
  bevel_size#(bvl1#, 15)
  val = bevel_size(bvl1#)
  passed = 0
  if val <= 10.1 then
    passed = 1
  endif
  LogTest("Clamp size > 10", passed)
  
  bevel_size#(bvl1#, -5)
  val = bevel_size(bvl1#)
  passed = 0
  if val >= 0 then
    passed = 1
  endif
  LogTest("Clamp size < 0", passed)
  
  bevel_size#(bvl1#, 3)
endfunction

function TestEnabledProperty() local val, passed
  println "Testing Enabled property..."
  
  bevel_enabled#(bvl1#, 0)
  val = bevel_enabled(bvl1#)
  passed = 0
  if val = 0 then
    passed = 1
  endif
  LogTest("Disable effect", passed)
  
  bevel_enabled#(bvl1#, 1)
  val = bevel_enabled(bvl1#)
  passed = 0
  if val = 1 then
    passed = 1
  endif
  LogTest("Enable effect", passed)
endfunction

function TestTriggerProperty() local t$, passed
  println "Testing Trigger property..."
  
  bevel_trigger#(bvl1#, "IsMouseOver=true")
  t$ = bevel_trigger$(bvl1#)
  passed = 0
  if t$ = "IsMouseOver=true" then
    passed = 1
  endif
  LogTest("Set trigger string", passed)
  
  bevel_trigger#(bvl1#, "")
  t$ = bevel_trigger$(bvl1#)
  passed = 0
  if t$ = "" then
    passed = 1
  endif
  LogTest("Clear trigger string", passed)
endfunction

function TestErrorHandling() local errCode, errStr$, passed
  println "Testing error handling..."
  
  bevel_clearerror()
  errCode = bevel_error()
  passed = 0
  if errCode = 0 then
    passed = 1
  endif
  LogTest("Clear error state", passed)
  
  errStr$ = bevel_strerror$(0)
  passed = 0
  if instr(errStr$, "No error", 0) >= 0 then
    passed = 1
  endif
  LogTest("Error code 0 message", passed)
  
  errStr$ = bevel_strerror$(1)
  passed = 0
  if instr(errStr$, "nil", 0) >= 0 then
    passed = 1
  endif
  LogTest("Error code 1 message", passed)
endfunction
