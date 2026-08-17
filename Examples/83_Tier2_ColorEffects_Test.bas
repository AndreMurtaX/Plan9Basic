' ============================================================================
' Tier-2 Color Effects Test and Demo
' Version: 1.0.0
' 
' Tests and demonstrates all Tier-2 color adjustment effects:
' - ContrastEffect
' - HueAdjustEffect
' - SepiaEffect
' - InvertEffect
' ============================================================================

' Module-level variables
let frm# = Pointer#(0)
let statusLbl# = Pointer#(0)

' Target rectangles for each effect
let contrastRect# = Pointer#(0)
let hueRect# = Pointer#(0)
let sepiaRect# = Pointer#(0)
let invertRect# = Pointer#(0)

' Effect references
let contrastFx# = Pointer#(0)
let hueFx# = Pointer#(0)
let sepiaFx# = Pointer#(0)
let invertFx# = Pointer#(0)

' Test counters
let testCount = 0
let passCount = 0

' ============================================================================
' Main Program
' ============================================================================

println "Tier-2 Color Effects Demo"
println "========================="
println ""

frm# = form#("Tier-2 Color Effects Demo", 650, 520)

' Create 4 target rectangles in a row
CreateTargetRectangles()

' Contrast controls
let lbl# = label#(frm#, "CONTRAST", 30, 145)
let btn# = button#(frm#, "Low")
button_bounds#(btn#, 20, 165, 50, 25)
button_onclick#(btn#, "ContrastLow")

btn# = button#(frm#, "Norm")
button_bounds#(btn#, 72, 165, 50, 25)
button_onclick#(btn#, "ContrastNorm")

btn# = button#(frm#, "High")
button_bounds#(btn#, 124, 165, 50, 25)
button_onclick#(btn#, "ContrastHigh")

' Hue controls
lbl# = label#(frm#, "HUE ADJUST", 200, 145)
btn# = button#(frm#, "-0.5")
button_bounds#(btn#, 185, 165, 50, 25)
button_onclick#(btn#, "HueNeg")

btn# = button#(frm#, "0")
button_bounds#(btn#, 237, 165, 40, 25)
button_onclick#(btn#, "HueZero")

btn# = button#(frm#, "+0.5")
button_bounds#(btn#, 279, 165, 50, 25)
button_onclick#(btn#, "HuePos")

' Sepia controls
lbl# = label#(frm#, "SEPIA", 375, 145)
btn# = button#(frm#, "Off")
button_bounds#(btn#, 355, 165, 50, 25)
button_onclick#(btn#, "SepiaOff")

btn# = button#(frm#, "50%")
button_bounds#(btn#, 407, 165, 50, 25)
button_onclick#(btn#, "SepiaHalf")

btn# = button#(frm#, "Full")
button_bounds#(btn#, 459, 165, 50, 25)
button_onclick#(btn#, "SepiaFull")

' Invert controls
lbl# = label#(frm#, "INVERT", 545, 145)
btn# = button#(frm#, "Off")
button_bounds#(btn#, 525, 165, 55, 25)
button_onclick#(btn#, "InvertOff")

btn# = button#(frm#, "On")
button_bounds#(btn#, 582, 165, 55, 25)
button_onclick#(btn#, "InvertOn")

' Global action buttons
btn# = button#(frm#, "Reset All")
button_bounds#(btn#, 50, 210, 100, 35)
button_onclick#(btn#, "ResetAll")

btn# = button#(frm#, "Animate All")
button_bounds#(btn#, 160, 210, 100, 35)
button_onclick#(btn#, "AnimateAll")

btn# = button#(frm#, "Run Tests")
button_bounds#(btn#, 270, 210, 100, 35)
button_onclick#(btn#, "RunTests")

' Comparison galleries
lbl# = label#(frm#, "Contrast Gallery (0.0 to 2.0):", 30, 270)
CreateContrastGallery()

lbl# = label#(frm#, "Hue Gallery (-1.0 to 1.0):", 30, 350)
CreateHueGallery()

lbl# = label#(frm#, "Sepia Gallery (0.0 to 1.0):", 30, 430)
CreateSepiaGallery()

' Status bar
statusLbl# = label#(frm#, "Tier-2 Color Effects - adjust using buttons above", 30, 485)

form_show(frm#)

' ============================================================================
' Target Rectangles Creation
' ============================================================================

function CreateTargetRectangles()
  ' All rectangles use orange as base color for visual comparison
  
  ' Contrast target
  contrastRect# = rectangle#(frm#)
  rectangle_bounds#(contrastRect#, 20, 30, 140, 100)
  rectangle_fill#(contrastRect#, "Orange")
  rectangle_stroke#(contrastRect#, "DarkOrange")
  rectangle_strokethickness#(contrastRect#, 2)
  contrastFx# = contrast#(contrastRect#)
  
  ' Hue target
  hueRect# = rectangle#(frm#)
  rectangle_bounds#(hueRect#, 180, 30, 140, 100)
  rectangle_fill#(hueRect#, "Orange")
  rectangle_stroke#(hueRect#, "DarkOrange")
  rectangle_strokethickness#(hueRect#, 2)
  hueFx# = hueadjust#(hueRect#)
  
  ' Sepia target
  sepiaRect# = rectangle#(frm#)
  rectangle_bounds#(sepiaRect#, 340, 30, 140, 100)
  rectangle_fill#(sepiaRect#, "Orange")
  rectangle_stroke#(sepiaRect#, "DarkOrange")
  rectangle_strokethickness#(sepiaRect#, 2)
  sepiaFx# = sepia#(sepiaRect#)
  sepia_amount#(sepiaFx#, 0)
  
  ' Invert target
  invertRect# = rectangle#(frm#)
  rectangle_bounds#(invertRect#, 500, 30, 140, 100)
  rectangle_fill#(invertRect#, "Orange")
  rectangle_stroke#(invertRect#, "DarkOrange")
  rectangle_strokethickness#(invertRect#, 2)
  invertFx# = invert#(invertRect#)
  invert_enabled#(invertFx#, 0)
endfunction

' ============================================================================
' Gallery Creation
' ============================================================================

function CreateContrastGallery() local i, rect#, fx#, val
  i = 0
  while i < 5
    rect# = rectangle#(frm#)
    rectangle_bounds#(rect#, 30 + i * 120, 295, 110, 40)
    rectangle_fill#(rect#, "DodgerBlue")
    
    fx# = contrast#(rect#)
    val = i * 0.5
    contrast_contrast#(fx#, val)
    
    i = i + 1
  endwhile
endfunction

function CreateHueGallery() local i, rect#, fx#, val
  i = 0
  while i < 5
    rect# = rectangle#(frm#)
    rectangle_bounds#(rect#, 30 + i * 120, 375, 110, 40)
    rectangle_fill#(rect#, "Red")
    
    fx# = hueadjust#(rect#)
    val = -1.0 + i * 0.5
    hueadjust_hue#(fx#, val)
    
    i = i + 1
  endwhile
endfunction

function CreateSepiaGallery() local i, rect#, fx#, val
  i = 0
  while i < 5
    rect# = rectangle#(frm#)
    rectangle_bounds#(rect#, 30 + i * 120, 455, 110, 25)
    rectangle_fill#(rect#, "LightBlue")
    
    fx# = sepia#(rect#)
    val = i * 0.25
    sepia_amount#(fx#, val)
    
    i = i + 1
  endwhile
endfunction

' ============================================================================
' Contrast Controls
' ============================================================================

function ContrastLow(sender#)
  contrast_contrast#(contrastFx#, 0.5)
  label_text#(statusLbl#, "Contrast: 0.5 (low)")
endfunction

function ContrastNorm(sender#)
  contrast_contrast#(contrastFx#, 1.0)
  label_text#(statusLbl#, "Contrast: 1.0 (normal)")
endfunction

function ContrastHigh(sender#)
  contrast_contrast#(contrastFx#, 2.0)
  label_text#(statusLbl#, "Contrast: 2.0 (high)")
endfunction

' ============================================================================
' Hue Controls
' ============================================================================

function HueNeg(sender#)
  hueadjust_hue#(hueFx#, -0.5)
  label_text#(statusLbl#, "Hue: -0.5 (shift 90 deg)")
endfunction

function HueZero(sender#)
  hueadjust_hue#(hueFx#, 0.0)
  label_text#(statusLbl#, "Hue: 0.0 (original)")
endfunction

function HuePos(sender#)
  hueadjust_hue#(hueFx#, 0.5)
  label_text#(statusLbl#, "Hue: +0.5 (shift 90 deg)")
endfunction

' ============================================================================
' Sepia Controls
' ============================================================================

function SepiaOff(sender#)
  sepia_amount#(sepiaFx#, 0.0)
  label_text#(statusLbl#, "Sepia: 0.0 (off)")
endfunction

function SepiaHalf(sender#)
  sepia_amount#(sepiaFx#, 0.5)
  label_text#(statusLbl#, "Sepia: 0.5 (partial)")
endfunction

function SepiaFull(sender#)
  sepia_amount#(sepiaFx#, 1.0)
  label_text#(statusLbl#, "Sepia: 1.0 (full vintage)")
endfunction

' ============================================================================
' Invert Controls
' ============================================================================

function InvertOff(sender#)
  invert_enabled#(invertFx#, 0)
  label_text#(statusLbl#, "Invert: Off (original colors)")
endfunction

function InvertOn(sender#)
  invert_enabled#(invertFx#, 1)
  label_text#(statusLbl#, "Invert: On (negative)")
endfunction

' ============================================================================
' Global Actions
' ============================================================================

function ResetAll(sender#)
  contrast_contrast#(contrastFx#, 1.0)
  contrast_brightness#(contrastFx#, 0.0)
  hueadjust_hue#(hueFx#, 0.0)
  sepia_amount#(sepiaFx#, 0.0)
  invert_enabled#(invertFx#, 0)
  label_text#(statusLbl#, "All effects reset to defaults")
endfunction

function AnimateAll(sender#) local ani#
  ' Animate contrast
  ani# = floatani#(contrastFx#)
  floatani_propertyname#(ani#, "Contrast")
  floatani_startvalue#(ani#, 0.5)
  floatani_stopvalue#(ani#, 2.0)
  floatani_duration#(ani#, 2.0)
  floatani_autoreverse#(ani#, 1)
  floatani_loop#(ani#, 1)
  floatani_start(ani#)
  
  ' Animate hue (rainbow effect)
  ani# = floatani#(hueFx#)
  floatani_propertyname#(ani#, "Hue")
  floatani_startvalue#(ani#, -1.0)
  floatani_stopvalue#(ani#, 1.0)
  floatani_duration#(ani#, 4.0)
  floatani_loop#(ani#, 1)
  floatani_start(ani#)
  
  ' Animate sepia
  ani# = floatani#(sepiaFx#)
  floatani_propertyname#(ani#, "Amount")
  floatani_startvalue#(ani#, 0.0)
  floatani_stopvalue#(ani#, 1.0)
  floatani_duration#(ani#, 2.5)
  floatani_autoreverse#(ani#, 1)
  floatani_loop#(ani#, 1)
  floatani_start(ani#)
  
  label_text#(statusLbl#, "Animating all effects...")
endfunction

' ============================================================================
' Test Functions
' ============================================================================

function RunTests(sender#)
  testCount = 0
  passCount = 0
  
  println ""
  println "=== Tier-2 Color Effects Tests ==="
  println ""
  
  TestContrast()
  TestHueAdjust()
  TestSepia()
  TestInvert()
  
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

function TestContrast() local val, passed
  println "Testing ContrastEffect..."
  
  contrast_contrast#(contrastFx#, 1.5)
  val = contrast_contrast(contrastFx#)
  passed = 0
  if val >= 1.4 then
    if val <= 1.6 then
      passed = 1
    endif
  endif
  LogTest("Contrast: set/get value", passed)
  
  contrast_brightness#(contrastFx#, 0.3)
  val = contrast_brightness(contrastFx#)
  passed = 0
  if val >= 0.25 then
    if val <= 0.35 then
      passed = 1
    endif
  endif
  LogTest("Contrast: brightness property", passed)
  
  contrast_contrast#(contrastFx#, 1.0)
  contrast_brightness#(contrastFx#, 0.0)
endfunction

function TestHueAdjust() local val, passed
  println "Testing HueAdjustEffect..."
  
  hueadjust_hue#(hueFx#, 0.5)
  val = hueadjust_hue(hueFx#)
  passed = 0
  if val >= 0.45 then
    if val <= 0.55 then
      passed = 1
    endif
  endif
  LogTest("HueAdjust: set/get value", passed)
  
  hueadjust_hue#(hueFx#, 0.0)
endfunction

function TestSepia() local val, passed
  println "Testing SepiaEffect..."
  
  sepia_amount#(sepiaFx#, 0.6)
  val = sepia_amount(sepiaFx#)
  passed = 0
  if val >= 0.55 then
    if val <= 0.65 then
      passed = 1
    endif
  endif
  LogTest("Sepia: set/get amount", passed)
  
  sepia_amount#(sepiaFx#, 0.0)
endfunction

function TestInvert() local val, passed
  println "Testing InvertEffect..."
  
  invert_enabled#(invertFx#, 1)
  val = invert_enabled(invertFx#)
  passed = 0
  if val = 1 then
    passed = 1
  endif
  LogTest("Invert: enable effect", passed)
  
  invert_enabled#(invertFx#, 0)
  val = invert_enabled(invertFx#)
  passed = 0
  if val = 0 then
    passed = 1
  endif
  LogTest("Invert: disable effect", passed)
endfunction
