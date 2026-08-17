' ============================================================================
' BlurEffectLib Test Suite (Simple Version)
' Version: 1.0.1
' 
' Comprehensive test program for the Blur Effect Library.
' Uses: form, panel, button, label, memo (no rectangle dependencies)
' ============================================================================

' Module-level variables
let frm# = Pointer#(0)
let testPanel# = Pointer#(0)
let resultMemo# = Pointer#(0)
let testCount = 0
let passCount = 0

' Test subject variables
let testBtn# = Pointer#(0)
let testBlur# = Pointer#(0)

' UI element references
let statusLbl# = Pointer#(0)

' ============================================================================
' Main Program
' ============================================================================

println "BlurEffectLib Test Suite"
println "========================"
println ""

' Create test form
frm# = form#("BlurEffectLib Tests", 800, 600)

' Create result display area
resultMemo# = memo#(frm#)
memo_bounds#(resultMemo#, 10, 10, 380, 580)
memo_readonly#(resultMemo#, 1)

' Create visual test area
testPanel# = panel#(frm#)
panel_bounds#(testPanel#, 400, 10, 390, 400)

' Create test button (instead of rectangle)
testBtn# = button#(testPanel#, "Test Button for Blur")
button_bounds#(testBtn#, 50, 50, 200, 100)

' Control buttons
let btnRunAll# = button#(frm#, "Run All Tests")
button_bounds#(btnRunAll#, 410, 430, 120, 30)
button_onclick#(btnRunAll#, "RunAllTests")

let btnClear# = button#(frm#, "Clear Results")
button_bounds#(btnClear#, 540, 430, 120, 30)
button_onclick#(btnClear#, "ClearResults")

let btnInteractive# = button#(frm#, "Cycle Blur")
button_bounds#(btnInteractive#, 410, 470, 120, 30)
button_onclick#(btnInteractive#, "InteractiveDemo")

let btnAnimate# = button#(frm#, "Animate Blur")
button_bounds#(btnAnimate#, 540, 470, 120, 30)
button_onclick#(btnAnimate#, "AnimateBlur")

' Status label
statusLbl# = label#(frm#, "Ready - Click 'Run All Tests' to start", 410, 520)

form_show(frm#)

' ============================================================================
' Test Helper Functions
' ============================================================================

function LogResult(testName$, passed, details$)
  testCount = testCount + 1
  if passed = 1 then
    passCount = passCount + 1
    memo_addline#(resultMemo#, "[PASS] " + testName$)
  else
    memo_addline#(resultMemo#, "[FAIL] " + testName$ + " - " + details$)
  endif
endfunction

function LogInfo(msg$)
  memo_addline#(resultMemo#, "       " + msg$)
endfunction

function UpdateStatus()
  label_text#(statusLbl#, "Tests: " + str$(passCount) + "/" + str$(testCount) + " passed")
endfunction

' ============================================================================
' Test Functions
' ============================================================================

function TestCreation() local blur#, p
  LogInfo("Testing blur effect creation...")
  
  ' Test: Create blur effect
  blur# = blur#(testBtn#)
  p = PntToNum(blur#)
  if p <> 0 then
    LogResult("Create blur effect", 1, "")
    testBlur# = blur#
  else
    LogResult("Create blur effect", 0, "Returned nil pointer")
  endif
  
  ' Test: Error check after creation
  if blur_error() = 0 then
    LogResult("No error after creation", 1, "")
  else
    LogResult("No error after creation", 0, blur_errormsg$())
  endif
endfunction

function TestSoftnessProperty() local val, passed
  LogInfo("Testing Softness property...")
  
  ' Test: Set softness to valid value
  blur_softness#(testBlur#, 1.5)
  val = blur_softness(testBlur#)
  passed = 0
  if val >= 1.4 then
    if val <= 1.6 then
      passed = 1
    endif
  endif
  LogResult("Set softness to 1.5", passed, "Value: " + stri$(val))
  
  ' Test: Set softness to 0 (minimum)
  blur_softness#(testBlur#, 0.0)
  val = blur_softness(testBlur#)
  passed = 0
  if val >= 0.0 then
    if val <= 0.1 then
      passed = 1
    endif
  endif
  LogResult("Set softness to 0.0 (min)", passed, "Value: " + stri$(val))
  
  ' Test: Set softness to 3.0 (maximum)
  blur_softness#(testBlur#, 3.0)
  val = blur_softness(testBlur#)
  passed = 0
  if val >= 2.9 then
    if val <= 3.1 then
      passed = 1
    endif
  endif
  LogResult("Set softness to 3.0 (max)", passed, "Value: " + stri$(val))
  
  ' Test: Set softness beyond range (should clamp)
  blur_softness#(testBlur#, 5.0)
  val = blur_softness(testBlur#)
  passed = 0
  if val <= 3.1 then
    passed = 1
    LogInfo("Clamped to: " + stri$(val))
  endif
  LogResult("Clamp softness > 3.0", passed, "Value: " + stri$(val))
  
  ' Test: Set softness below range (should clamp)
  blur_softness#(testBlur#, -1.0)
  val = blur_softness(testBlur#)
  passed = 0
  if val >= 0.0 then
    passed = 1
    LogInfo("Clamped to: " + stri$(val))
  endif
  LogResult("Clamp softness < 0.0", passed, "Value: " + stri$(val))
  
  ' Reset to visible value for visual testing
  blur_softness#(testBlur#, 1.0)
endfunction

function TestEnabledProperty() local val, passed
  LogInfo("Testing Enabled property...")
  
  ' Test: Disable effect
  blur_enabled#(testBlur#, 0)
  val = blur_enabled(testBlur#)
  passed = 0
  if val = 0 then
    passed = 1
  endif
  LogResult("Disable blur effect", passed, "Value: " + str$(val))
  
  ' Test: Enable effect
  blur_enabled#(testBlur#, 1)
  val = blur_enabled(testBlur#)
  passed = 0
  if val = 1 then
    passed = 1
  endif
  LogResult("Enable blur effect", passed, "Value: " + str$(val))
endfunction

function TestTriggerProperty() local t$, passed
  LogInfo("Testing Trigger property...")
  
  ' Test: Set trigger
  blur_trigger#(testBlur#, "IsMouseOver=true")
  t$ = blur_trigger$(testBlur#)
  passed = 0
  if t$ = "IsMouseOver=true" then
    passed = 1
  endif
  LogResult("Set trigger string", passed, "Got: " + t$)
  
  ' Test: Clear trigger
  blur_trigger#(testBlur#, "")
  t$ = blur_trigger$(testBlur#)
  passed = 0
  if t$ = "" then
    passed = 1
  endif
  LogResult("Clear trigger string", passed, "Got: " + t$)
endfunction

function TestErrorHandling() local errCode, errStr$, passed
  LogInfo("Testing error handling...")
  
  ' Test: Error functions work
  blur_clearerror()
  errCode = blur_error()
  passed = 0
  if errCode = 0 then
    passed = 1
  endif
  LogResult("Clear error state", passed, "Error code: " + str$(errCode))
  
  ' Test: Error message conversion
  errStr$ = blur_strerror$(0)
  passed = 0
  if instr(errStr$, "No error", 0) >= 0 then
    passed = 1
  endif
  LogResult("Error code 0 message", passed, "Got: " + errStr$)
  
  errStr$ = blur_strerror$(1)
  passed = 0
  if instr(errStr$, "nil", 0) >= 0 then
    passed = 1
  endif
  LogResult("Error code 1 message", passed, "Got: " + errStr$)
endfunction

function TestNilHandling() local val, errCode, passed
  LogInfo("Testing nil pointer handling...")
  
  ' Test: Get softness with nil pointer
  blur_clearerror()
  val = blur_softness(Pointer#(0))
  errCode = blur_error()
  passed = 0
  if errCode <> 0 then
    passed = 1
    LogInfo("Error: " + blur_errormsg$())
  endif
  LogResult("Nil pointer detection (get)", passed, "No error set")
  
  ' Test: Set softness with nil pointer
  blur_clearerror()
  blur_softness#(Pointer#(0), 1.0)
  errCode = blur_error()
  passed = 0
  if errCode <> 0 then
    passed = 1
  endif
  LogResult("Nil pointer detection (set)", passed, "No error set")
  
  blur_clearerror()
endfunction

function TestMultipleEffects() local blur1#, blur2#, p1, p2, passed
  LogInfo("Testing multiple effects on same control...")
  
  ' Create second blur effect on same control
  blur1# = testBlur#
  blur2# = blur#(testBtn#)
  
  p1 = PntToNum(blur1#)
  p2 = PntToNum(blur2#)
  
  passed = 0
  if p2 <> 0 then
    passed = 1
  endif
  LogResult("Create second blur effect", passed, "Returned nil")
  
  passed = 0
  if p1 <> p2 then
    passed = 1
  endif
  LogResult("Effects are distinct objects", passed, "Same pointer")
  
  ' Set different values
  blur_softness#(blur1#, 0.5)
  blur_softness#(blur2#, 2.5)
  
  passed = 0
  if blur_softness(blur1#) < 1.0 then
    if blur_softness(blur2#) > 2.0 then
      passed = 1
    endif
  endif
  LogResult("Independent property values", passed, "Values not independent")
  
  ' Cleanup second effect
  blur_free(blur2#)
  LogInfo("Cleaned up second effect")
endfunction

' ============================================================================
' Test Runner
' ============================================================================

function RunAllTests(sender#)
  testCount = 0
  passCount = 0
  
  memo_clear#(resultMemo#)
  memo_addline#(resultMemo#, "=== BlurEffectLib Test Suite ===")
  memo_addline#(resultMemo#, "")
  
  TestCreation()
  memo_addline#(resultMemo#, "")
  
  TestSoftnessProperty()
  memo_addline#(resultMemo#, "")
  
  TestEnabledProperty()
  memo_addline#(resultMemo#, "")
  
  TestTriggerProperty()
  memo_addline#(resultMemo#, "")
  
  TestErrorHandling()
  memo_addline#(resultMemo#, "")
  
  TestNilHandling()
  memo_addline#(resultMemo#, "")
  
  TestMultipleEffects()
  memo_addline#(resultMemo#, "")
  
  memo_addline#(resultMemo#, "=== Summary ===")
  memo_addline#(resultMemo#, "Total tests: " + str$(testCount))
  memo_addline#(resultMemo#, "Passed: " + str$(passCount))
  memo_addline#(resultMemo#, "Failed: " + str$(testCount - passCount))
  
  if passCount = testCount then
    memo_addline#(resultMemo#, "")
    memo_addline#(resultMemo#, "ALL TESTS PASSED!")
  endif
  
  UpdateStatus()
endfunction

function ClearResults(sender#)
  memo_clear#(resultMemo#)
  label_text#(statusLbl#, "Ready")
endfunction

' ============================================================================
' Interactive Demo
' ============================================================================

function InteractiveDemo(sender#) local p, current
  p = PntToNum(testBlur#)
  if p = 0 then
    testBlur# = blur#(testBtn#)
  endif
  
  ' Cycle through softness values
  current = blur_softness(testBlur#)
  current = current + 0.5
  if current > 3.0 then
    current = 0.0
  endif
  blur_softness#(testBlur#, current)
  
  label_text#(statusLbl#, "Softness: " + stri$(current))
endfunction

' ============================================================================
' Animation Demo
' ============================================================================

function AnimateBlur(sender#) local ani#, p
  p = PntToNum(testBlur#)
  if p = 0 then
    testBlur# = blur#(testBtn#)
  endif
  
  blur_softness#(testBlur#, 0.0)
  
  ' Create animation
  ani# = floatani#(testBlur#)
  floatani_propertyname#(ani#, "Softness")
  floatani_startvalue#(ani#, 0.0)
  floatani_stopvalue#(ani#, 3.0)
  floatani_duration#(ani#, 2.0)
  floatani_autoreverse#(ani#, 1)
  floatani_onfinish#(ani#, "OnAnimationDone")
  floatani_start(ani#)
  
  label_text#(statusLbl#, "Animating blur...")
endfunction

function OnAnimationDone(sender#)
  label_text#(statusLbl#, "Animation complete")
endfunction
