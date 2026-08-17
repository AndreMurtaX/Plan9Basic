' ============================================================================
' Tier-4 Distortion Effects Test and Demo (with Web Images)
' Version: 1.0.1
' 
' Tests and demonstrates all Tier-4 distortion effects using real images
' loaded from Lorem Picsum (https://picsum.photos)
'
' Effects demonstrated:
' - WaveEffect
' - SwirlEffect
' - RippleEffect
' - MagnifyEffect
' - BandsEffect
' - WrapEffect
' ============================================================================

' Module-level variables
let frm# = Pointer#(0)
let statusLbl# = Pointer#(0)

' Target images
let waveImg# = Pointer#(0)
let swirlImg# = Pointer#(0)
let rippleImg# = Pointer#(0)
let magnifyImg# = Pointer#(0)
let bandsImg# = Pointer#(0)
let wrapImg# = Pointer#(0)

' Effect references
let waveFx# = Pointer#(0)
let swirlFx# = Pointer#(0)
let rippleFx# = Pointer#(0)
let magnifyFx# = Pointer#(0)
let bandsFx# = Pointer#(0)
let wrapFx# = Pointer#(0)

' Test counters
let testCount = 0
let passCount = 0

' ============================================================================
' Main Program
' ============================================================================

println "Tier-4 Distortion Effects Demo (Web Images)"
println "============================================"
println ""
println "Loading images from Lorem Picsum..."

frm# = form#("Tier-4 Distortion Effects Demo", 720, 520)

' Create target images with effects
CreateTargetImages()

' Wave controls
let lbl# = label#(frm#, "WAVE", 35, 125)
let btn# = button#(frm#, "256")
button_bounds#(btn#, 20, 145, 40, 25)
button_onclick#(btn#, "WaveLow")

btn# = button#(frm#, "128")
button_bounds#(btn#, 62, 145, 40, 25)
button_onclick#(btn#, "WaveMed")

btn# = button#(frm#, "64")
button_bounds#(btn#, 104, 145, 40, 25)
button_onclick#(btn#, "WaveHigh")

' Swirl controls
lbl# = label#(frm#, "SWIRL", 165, 125)
btn# = button#(frm#, "-3")
button_bounds#(btn#, 155, 145, 35, 25)
button_onclick#(btn#, "SwirlNeg")

btn# = button#(frm#, "0")
button_bounds#(btn#, 192, 145, 35, 25)
button_onclick#(btn#, "SwirlZero")

btn# = button#(frm#, "+3")
button_bounds#(btn#, 229, 145, 35, 25)
button_onclick#(btn#, "SwirlPos")

' Ripple controls
lbl# = label#(frm#, "RIPPLE", 280, 125)
btn# = button#(frm#, "0.05")
button_bounds#(btn#, 275, 145, 45, 25)
button_onclick#(btn#, "RippleLow")

btn# = button#(frm#, "0.1")
button_bounds#(btn#, 322, 145, 40, 25)
button_onclick#(btn#, "RippleMed")

btn# = button#(frm#, "0.2")
button_bounds#(btn#, 364, 145, 40, 25)
button_onclick#(btn#, "RippleHigh")

' Magnify controls
lbl# = label#(frm#, "MAGNIFY", 420, 125)
btn# = button#(frm#, "1.5x")
button_bounds#(btn#, 415, 145, 45, 25)
button_onclick#(btn#, "MagLow")

btn# = button#(frm#, "2x")
button_bounds#(btn#, 462, 145, 35, 25)
button_onclick#(btn#, "MagMed")

btn# = button#(frm#, "3x")
button_bounds#(btn#, 499, 145, 35, 25)
button_onclick#(btn#, "MagHigh")

' Bands controls
lbl# = label#(frm#, "BANDS", 555, 125)
btn# = button#(frm#, "20")
button_bounds#(btn#, 545, 145, 35, 25)
button_onclick#(btn#, "BandsLow")

btn# = button#(frm#, "50")
button_bounds#(btn#, 582, 145, 35, 25)
button_onclick#(btn#, "BandsMed")

btn# = button#(frm#, "80")
button_bounds#(btn#, 619, 145, 35, 25)
button_onclick#(btn#, "BandsHigh")

' Wrap controls
lbl# = label#(frm#, "WRAP", 675, 125)
btn# = button#(frm#, "W")
button_bounds#(btn#, 665, 145, 35, 25)
button_onclick#(btn#, "WrapDemo")

' Global action buttons
btn# = button#(frm#, "Reset All")
button_bounds#(btn#, 50, 190, 100, 35)
button_onclick#(btn#, "ResetAll")

btn# = button#(frm#, "Toggle All")
button_bounds#(btn#, 160, 190, 100, 35)
button_onclick#(btn#, "ToggleAll")

btn# = button#(frm#, "Animate All")
button_bounds#(btn#, 270, 190, 110, 35)
button_onclick#(btn#, "AnimateAll")

btn# = button#(frm#, "Run Tests")
button_bounds#(btn#, 390, 190, 100, 35)
button_onclick#(btn#, "RunTests")

' Galleries
lbl# = label#(frm#, "Wave Gallery (wavesize 256 to 48):", 30, 250)
CreateWaveGallery()

lbl# = label#(frm#, "Swirl Gallery (-4 to +4):", 30, 350)
CreateSwirlGallery()

lbl# = label#(frm#, "Magnify Gallery:", 420, 350)
CreateMagnifyGallery()

' Status bar
statusLbl# = label#(frm#, "Loading images from web... please wait", 30, 475)

form_show(frm#)

println ""
println "Images loaded! Effects applied."

label_text#(statusLbl#, "Tier-4 Distortion Effects - Images from Lorem Picsum (picsum.photos)")

' ============================================================================
' Target Images Creation
' ============================================================================

function CreateTargetImages()
  println "Creating image 1 (Wave - nature)..."
  waveImg# = image#(frm#, 20, 20, 110, 90)
  image_wrapmode#(waveImg#, 1)
  image_load#(waveImg#, "https://picsum.photos/seed/wave1/110/90")
  waveFx# = wave#(waveImg#)
  wave_wavesize#(waveFx#, 64)
  
  println "Creating image 2 (Swirl - city)..."
  swirlImg# = image#(frm#, 140, 20, 110, 90)
  image_wrapmode#(swirlImg#, 1)
  image_load#(swirlImg#, "https://picsum.photos/seed/swirl1/110/90")
  swirlFx# = swirl#(swirlImg#)
  swirl_strength#(swirlFx#, 2.0)
  
  println "Creating image 3 (Ripple - ocean)..."
  rippleImg# = image#(frm#, 260, 20, 110, 90)
  image_wrapmode#(rippleImg#, 1)
  image_load#(rippleImg#, "https://picsum.photos/seed/ripple1/110/90")
  rippleFx# = ripple#(rippleImg#)
  ripple_amplitude#(rippleFx#, 0.1)
  ripple_frequency#(rippleFx#, 50)
  
  println "Creating image 4 (Magnify - forest)..."
  magnifyImg# = image#(frm#, 380, 20, 110, 90)
  image_wrapmode#(magnifyImg#, 1)
  image_load#(magnifyImg#, "https://picsum.photos/seed/magnify1/110/90")
  magnifyFx# = magnify#(magnifyImg#)
  magnify_magnification#(magnifyFx#, 2.0)
  magnify_radius#(magnifyFx#, 40)
  
  println "Creating image 5 (Bands - mountain)..."
  bandsImg# = image#(frm#, 500, 20, 110, 90)
  image_wrapmode#(bandsImg#, 1)
  image_load#(bandsImg#, "https://picsum.photos/seed/bands1/110/90")
  bandsFx# = bands#(bandsImg#)
  bands_density#(bandsFx#, 50)
  bands_intensity#(bandsFx#, 0.5)
  
  println "Creating image 6 (Wrap - sunset)..."
  wrapImg# = image#(frm#, 620, 20, 110, 90)
  image_wrapmode#(wrapImg#, 1)
  image_load#(wrapImg#, "https://picsum.photos/seed/wrap1/110/90")
  wrapFx# = wrap#(wrapImg#)
  wrap_leftstart#(wrapFx#, 0.2)
  wrap_leftctrl1#(wrapFx#, 0.3)
  wrap_leftctrl2#(wrapFx#, 0.3)
  wrap_leftend#(wrapFx#, 0.2)
endfunction

' ============================================================================
' Gallery Creation
' ============================================================================

function CreateWaveGallery() local i, img#, fx#, val
  i = 0
  while i < 5
    img# = image#(frm#, 30 + i * 75, 275, 65, 55)
    image_wrapmode#(img#, 1)
    image_load#(img#, "https://picsum.photos/seed/wavegal/65/55")
    
    fx# = wave#(img#)
    ' WaveSize: higher = smaller waves, so go from 256 down to 48
    val = 256 - i * 52
    wave_wavesize#(fx#, val)
    
    i = i + 1
  endwhile
endfunction

function CreateSwirlGallery() local i, img#, fx#, val
  i = 0
  while i < 5
    img# = image#(frm#, 30 + i * 75, 375, 65, 55)
    image_wrapmode#(img#, 1)
    image_load#(img#, "https://picsum.photos/seed/swirlgal/65/55")
    
    fx# = swirl#(img#)
    val = -4 + i * 2
    swirl_strength#(fx#, val)
    
    i = i + 1
  endwhile
endfunction

function CreateMagnifyGallery() local i, img#, fx#, val
  i = 0
  while i < 4
    img# = image#(frm#, 420 + i * 70, 375, 60, 55)
    image_wrapmode#(img#, 1)
    image_load#(img#, "https://picsum.photos/seed/maggal/60/55")
    
    fx# = magnify#(img#)
    val = 1.0 + i * 0.7
    magnify_magnification#(fx#, val)
    magnify_radius#(fx#, 25)
    
    i = i + 1
  endwhile
endfunction

' ============================================================================
' Wave Controls (higher WaveSize = smaller waves)
' ============================================================================

function WaveLow(sender#)
  wave_wavesize#(waveFx#, 256)
  label_text#(statusLbl#, "Wave: wavesize 256 (small waves)")
endfunction

function WaveMed(sender#)
  wave_wavesize#(waveFx#, 128)
  label_text#(statusLbl#, "Wave: wavesize 128 (medium waves)")
endfunction

function WaveHigh(sender#)
  wave_wavesize#(waveFx#, 64)
  label_text#(statusLbl#, "Wave: wavesize 64 (large waves)")
endfunction

' ============================================================================
' Swirl Controls
' ============================================================================

function SwirlNeg(sender#)
  swirl_strength#(swirlFx#, -3)
  label_text#(statusLbl#, "Swirl: -3 (counter-clockwise)")
endfunction

function SwirlZero(sender#)
  swirl_strength#(swirlFx#, 0)
  label_text#(statusLbl#, "Swirl: 0 (no effect)")
endfunction

function SwirlPos(sender#)
  swirl_strength#(swirlFx#, 3)
  label_text#(statusLbl#, "Swirl: +3 (clockwise)")
endfunction

' ============================================================================
' Ripple Controls
' ============================================================================

function RippleLow(sender#)
  ripple_amplitude#(rippleFx#, 0.05)
  label_text#(statusLbl#, "Ripple: amplitude 0.05 (subtle)")
endfunction

function RippleMed(sender#)
  ripple_amplitude#(rippleFx#, 0.1)
  label_text#(statusLbl#, "Ripple: amplitude 0.1 (medium)")
endfunction

function RippleHigh(sender#)
  ripple_amplitude#(rippleFx#, 0.2)
  label_text#(statusLbl#, "Ripple: amplitude 0.2 (strong)")
endfunction

' ============================================================================
' Magnify Controls
' ============================================================================

function MagLow(sender#)
  magnify_magnification#(magnifyFx#, 1.5)
  label_text#(statusLbl#, "Magnify: 1.5x zoom")
endfunction

function MagMed(sender#)
  magnify_magnification#(magnifyFx#, 2.0)
  label_text#(statusLbl#, "Magnify: 2x zoom")
endfunction

function MagHigh(sender#)
  magnify_magnification#(magnifyFx#, 3.0)
  label_text#(statusLbl#, "Magnify: 3x zoom")
endfunction

' ============================================================================
' Bands Controls
' ============================================================================

function BandsLow(sender#)
  bands_density#(bandsFx#, 20)
  label_text#(statusLbl#, "Bands: density 20 (few bands)")
endfunction

function BandsMed(sender#)
  bands_density#(bandsFx#, 50)
  label_text#(statusLbl#, "Bands: density 50 (medium)")
endfunction

function BandsHigh(sender#)
  bands_density#(bandsFx#, 80)
  label_text#(statusLbl#, "Bands: density 80 (many bands)")
endfunction

' ============================================================================
' Wrap Controls
' ============================================================================

function WrapDemo(sender#)
  wrap_leftstart#(wrapFx#, 0.3)
  wrap_leftctrl1#(wrapFx#, 0.4)
  wrap_leftctrl2#(wrapFx#, 0.4)
  wrap_leftend#(wrapFx#, 0.3)
  label_text#(statusLbl#, "Wrap: curved left edge")
endfunction

' ============================================================================
' Global Actions
' ============================================================================

function ResetAll(sender#)
  wave_wavesize#(waveFx#, 64)
  wave_time#(waveFx#, 0)
  
  swirl_strength#(swirlFx#, 2.0)
  swirl_centerx#(swirlFx#, 0.5)
  swirl_centery#(swirlFx#, 0.5)
  
  ripple_amplitude#(rippleFx#, 0.1)
  ripple_frequency#(rippleFx#, 50)
  ripple_phase#(rippleFx#, 0)
  
  magnify_magnification#(magnifyFx#, 2.0)
  magnify_radius#(magnifyFx#, 40)
  
  bands_density#(bandsFx#, 50)
  bands_intensity#(bandsFx#, 0.5)
  
  wrap_leftstart#(wrapFx#, 0.2)
  wrap_leftctrl1#(wrapFx#, 0.3)
  wrap_leftctrl2#(wrapFx#, 0.3)
  wrap_leftend#(wrapFx#, 0.2)
  
  wave_enabled#(waveFx#, 1)
  swirl_enabled#(swirlFx#, 1)
  ripple_enabled#(rippleFx#, 1)
  magnify_enabled#(magnifyFx#, 1)
  bands_enabled#(bandsFx#, 1)
  wrap_enabled#(wrapFx#, 1)
  
  label_text#(statusLbl#, "All effects reset to defaults")
endfunction

function ToggleAll(sender#) local e
  e = wave_enabled(waveFx#)
  if e = 1 then
    wave_enabled#(waveFx#, 0)
    swirl_enabled#(swirlFx#, 0)
    ripple_enabled#(rippleFx#, 0)
    magnify_enabled#(magnifyFx#, 0)
    bands_enabled#(bandsFx#, 0)
    wrap_enabled#(wrapFx#, 0)
    label_text#(statusLbl#, "All effects DISABLED - showing original images")
  else
    wave_enabled#(waveFx#, 1)
    swirl_enabled#(swirlFx#, 1)
    ripple_enabled#(rippleFx#, 1)
    magnify_enabled#(magnifyFx#, 1)
    bands_enabled#(bandsFx#, 1)
    wrap_enabled#(wrapFx#, 1)
    label_text#(statusLbl#, "All effects ENABLED")
  endif
endfunction

function AnimateAll(sender#) local ani#
  ' Animate wave time
  ani# = floatani#(waveFx#)
  floatani_propertyname#(ani#, "Time")
  floatani_startvalue#(ani#, 0)
  floatani_stopvalue#(ani#, 10)
  floatani_duration#(ani#, 2.0)
  floatani_loop#(ani#, 1)
  floatani_start(ani#)
  
  ' Animate swirl strength
  ani# = floatani#(swirlFx#)
  floatani_propertyname#(ani#, "Strength")
  floatani_startvalue#(ani#, -3)
  floatani_stopvalue#(ani#, 3)
  floatani_duration#(ani#, 3.0)
  floatani_autoreverse#(ani#, 1)
  floatani_loop#(ani#, 1)
  floatani_start(ani#)
  
  ' Animate ripple phase
  ani# = floatani#(rippleFx#)
  floatani_propertyname#(ani#, "Phase")
  floatani_startvalue#(ani#, 0)
  floatani_stopvalue#(ani#, 100)
  floatani_duration#(ani#, 2.5)
  floatani_loop#(ani#, 1)
  floatani_start(ani#)
  
  ' Animate magnify magnification
  ani# = floatani#(magnifyFx#)
  floatani_propertyname#(ani#, "Magnification")
  floatani_startvalue#(ani#, 1.5)
  floatani_stopvalue#(ani#, 3.0)
  floatani_duration#(ani#, 2.0)
  floatani_autoreverse#(ani#, 1)
  floatani_loop#(ani#, 1)
  floatani_start(ani#)
  
  label_text#(statusLbl#, "Animating Wave, Swirl, Ripple, Magnify...")
endfunction

' ============================================================================
' Test Functions
' ============================================================================

function RunTests(sender#)
  testCount = 0
  passCount = 0
  
  println ""
  println "=== Tier-4 Distortion Effects Tests ==="
  println ""
  
  TestWave()
  TestSwirl()
  TestRipple()
  TestMagnify()
  TestBands()
  TestWrap()
  
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

function TestWave() local val, passed
  println "Testing WaveEffect..."
  
  wave_wavesize#(waveFx#, 100)
  val = wave_wavesize(waveFx#)
  passed = 0
  if val >= 98 then
    if val <= 102 then
      passed = 1
    endif
  endif
  LogTest("Wave: wavesize property", passed)
  
  wave_time#(waveFx#, 5.0)
  val = wave_time(waveFx#)
  passed = 0
  if val >= 4.9 then
    if val <= 5.1 then
      passed = 1
    endif
  endif
  LogTest("Wave: time property", passed)
  
  wave_wavesize#(waveFx#, 64)
  wave_time#(waveFx#, 0)
endfunction

function TestSwirl() local val, passed
  println "Testing SwirlEffect..."
  
  swirl_strength#(swirlFx#, -2.5)
  val = swirl_strength(swirlFx#)
  passed = 0
  if val >= -2.6 then
    if val <= -2.4 then
      passed = 1
    endif
  endif
  LogTest("Swirl: strength property", passed)
  
  swirl_centerx#(swirlFx#, 0.3)
  val = swirl_centerx(swirlFx#)
  passed = 0
  if val >= 0.28 then
    if val <= 0.32 then
      passed = 1
    endif
  endif
  LogTest("Swirl: centerx property", passed)
  
  swirl_strength#(swirlFx#, 2.0)
  swirl_centerx#(swirlFx#, 0.5)
endfunction

function TestRipple() local val, passed
  println "Testing RippleEffect..."
  
  ripple_amplitude#(rippleFx#, 0.15)
  val = ripple_amplitude(rippleFx#)
  passed = 0
  if val >= 0.14 then
    if val <= 0.16 then
      passed = 1
    endif
  endif
  LogTest("Ripple: amplitude property", passed)
  
  ripple_frequency#(rippleFx#, 60)
  val = ripple_frequency(rippleFx#)
  passed = 0
  if val >= 58 then
    if val <= 62 then
      passed = 1
    endif
  endif
  LogTest("Ripple: frequency property", passed)
  
  ripple_amplitude#(rippleFx#, 0.1)
  ripple_frequency#(rippleFx#, 50)
endfunction

function TestMagnify() local val, passed
  println "Testing MagnifyEffect..."
  
  magnify_magnification#(magnifyFx#, 2.5)
  val = magnify_magnification(magnifyFx#)
  passed = 0
  if val >= 2.4 then
    if val <= 2.6 then
      passed = 1
    endif
  endif
  LogTest("Magnify: magnification property", passed)
  
  magnify_radius#(magnifyFx#, 80)
  val = magnify_radius(magnifyFx#)
  passed = 0
  if val >= 78 then
    if val <= 82 then
      passed = 1
    endif
  endif
  LogTest("Magnify: radius property", passed)
  
  magnify_magnification#(magnifyFx#, 2.0)
  magnify_radius#(magnifyFx#, 40)
endfunction

function TestBands() local val, passed
  println "Testing BandsEffect..."
  
  bands_density#(bandsFx#, 70)
  val = bands_density(bandsFx#)
  passed = 0
  if val >= 68 then
    if val <= 72 then
      passed = 1
    endif
  endif
  LogTest("Bands: density property", passed)
  
  bands_intensity#(bandsFx#, 0.7)
  val = bands_intensity(bandsFx#)
  passed = 0
  if val >= 0.68 then
    if val <= 0.72 then
      passed = 1
    endif
  endif
  LogTest("Bands: intensity property", passed)
  
  bands_density#(bandsFx#, 50)
  bands_intensity#(bandsFx#, 0.5)
endfunction

function TestWrap() local val, passed
  println "Testing WrapEffect..."
  
  wrap_leftstart#(wrapFx#, 0.4)
  val = wrap_leftstart(wrapFx#)
  passed = 0
  if val >= 0.38 then
    if val <= 0.42 then
      passed = 1
    endif
  endif
  LogTest("Wrap: leftstart property", passed)
  
  wrap_leftstart#(wrapFx#, 0.2)
endfunction
