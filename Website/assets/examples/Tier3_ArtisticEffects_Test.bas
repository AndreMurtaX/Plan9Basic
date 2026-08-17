' ============================================================================
' Tier-3 Artistic Effects Test and Demo (with Web Images)
' Version: 1.1.0
' 
' Tests and demonstrates all Tier-3 artistic effects using real images
' loaded from Lorem Picsum (https://picsum.photos)
'
' Effects demonstrated:
' - EmbossEffect
' - PixelateEffect
' - ToonEffect
' - SharpenEffect
' - PaperSketchEffect
' - PencilStrokeEffect
' ============================================================================

' Module-level variables
let frm# = Pointer#(0)
let statusLbl# = Pointer#(0)

' Target images (instead of rectangles)
let embossImg# = Pointer#(0)
let pixelImg# = Pointer#(0)
let toonImg# = Pointer#(0)
let sharpenImg# = Pointer#(0)
let sketchImg# = Pointer#(0)
let pencilImg# = Pointer#(0)

' Effect references
let embossFx# = Pointer#(0)
let pixelFx# = Pointer#(0)
let toonFx# = Pointer#(0)
let sharpenFx# = Pointer#(0)
let sketchFx# = Pointer#(0)
let pencilFx# = Pointer#(0)

' Test counters
let testCount = 0
let passCount = 0

' ============================================================================
' Main Program
' ============================================================================

println "Tier-3 Artistic Effects Demo (Web Images)"
println "=========================================="
println ""
println "Loading images from Lorem Picsum..."

frm# = form#("Tier-3 Artistic Effects Demo", 720, 520)

' Create target images with effects
CreateTargetImages()

' Emboss controls
let lbl# = label#(frm#, "EMBOSS", 30, 125)
let btn# = button#(frm#, "0.3")
button_bounds#(btn#, 20, 145, 40, 25)
button_onclick#(btn#, "EmbossLow")

btn# = button#(frm#, "0.6")
button_bounds#(btn#, 62, 145, 40, 25)
button_onclick#(btn#, "EmbossMed")

btn# = button#(frm#, "1.0")
button_bounds#(btn#, 104, 145, 40, 25)
button_onclick#(btn#, "EmbossHigh")

' Pixelate controls
lbl# = label#(frm#, "PIXELATE", 155, 125)
btn# = button#(frm#, "5")
button_bounds#(btn#, 155, 145, 35, 25)
button_onclick#(btn#, "PixelLow")

btn# = button#(frm#, "20")
button_bounds#(btn#, 192, 145, 35, 25)
button_onclick#(btn#, "PixelMed")

btn# = button#(frm#, "50")
button_bounds#(btn#, 229, 145, 35, 25)
button_onclick#(btn#, "PixelHigh")

' Toon controls
lbl# = label#(frm#, "TOON", 285, 125)
btn# = button#(frm#, "3")
button_bounds#(btn#, 275, 145, 35, 25)
button_onclick#(btn#, "ToonLow")

btn# = button#(frm#, "8")
button_bounds#(btn#, 312, 145, 35, 25)
button_onclick#(btn#, "ToonMed")

btn# = button#(frm#, "20")
button_bounds#(btn#, 349, 145, 35, 25)
button_onclick#(btn#, "ToonHigh")

' Sharpen controls
lbl# = label#(frm#, "SHARPEN", 405, 125)
btn# = button#(frm#, "0.5")
button_bounds#(btn#, 395, 145, 40, 25)
button_onclick#(btn#, "SharpenLow")

btn# = button#(frm#, "1.0")
button_bounds#(btn#, 437, 145, 40, 25)
button_onclick#(btn#, "SharpenMed")

btn# = button#(frm#, "2.0")
button_bounds#(btn#, 479, 145, 40, 25)
button_onclick#(btn#, "SharpenHigh")

' Sketch controls
lbl# = label#(frm#, "SKETCH", 540, 125)
btn# = button#(frm#, "1")
button_bounds#(btn#, 530, 145, 35, 25)
button_onclick#(btn#, "SketchLow")

btn# = button#(frm#, "3")
button_bounds#(btn#, 567, 145, 35, 25)
button_onclick#(btn#, "SketchMed")

btn# = button#(frm#, "6")
button_bounds#(btn#, 604, 145, 35, 25)
button_onclick#(btn#, "SketchHigh")

' Pencil controls
lbl# = label#(frm#, "PENCIL", 655, 125)
btn# = button#(frm#, "1")
button_bounds#(btn#, 650, 145, 35, 25)
button_onclick#(btn#, "PencilLow")

btn# = button#(frm#, "3")
button_bounds#(btn#, 687, 145, 35, 25)
button_onclick#(btn#, "PencilHigh")

' Global action buttons
btn# = button#(frm#, "Reset All")
button_bounds#(btn#, 50, 190, 100, 35)
button_onclick#(btn#, "ResetAll")

btn# = button#(frm#, "Toggle All")
button_bounds#(btn#, 160, 190, 100, 35)
button_onclick#(btn#, "ToggleAll")

btn# = button#(frm#, "Reload Images")
button_bounds#(btn#, 270, 190, 110, 35)
button_onclick#(btn#, "ReloadImages")

btn# = button#(frm#, "Run Tests")
button_bounds#(btn#, 390, 190, 100, 35)
button_onclick#(btn#, "RunTests")

' Comparison galleries
lbl# = label#(frm#, "Pixelate Gallery (5 to 80 blocks):", 30, 250)
CreatePixelateGallery()

lbl# = label#(frm#, "Toon Gallery (3 to 20 levels):", 30, 350)
CreateToonGallery()

lbl# = label#(frm#, "Emboss Gallery:", 420, 350)
CreateEmbossGallery()

' Status bar
statusLbl# = label#(frm#, "Loading images from web... please wait", 30, 475)

form_show(frm#)

println ""
println "Images loaded! Effects applied."

label_text#(statusLbl#, "Tier-3 Artistic Effects - Images from Lorem Picsum (picsum.photos)")

' ============================================================================
' Target Images Creation
' ============================================================================

function CreateTargetImages()
  println "Creating image 1 (Emboss - nature)..."
  embossImg# = image#(frm#, 20, 20, 110, 90)
  image_wrapmode#(embossImg#, 1)
  image_load#(embossImg#, "https://picsum.photos/seed/nature/110/90")
  embossFx# = emboss#(embossImg#)
  emboss_amount#(embossFx#, 0.5)
  
  println "Creating image 2 (Pixelate - city)..."
  pixelImg# = image#(frm#, 140, 20, 110, 90)
  image_wrapmode#(pixelImg#, 1)
  image_load#(pixelImg#, "https://picsum.photos/seed/city/110/90")
  pixelFx# = pixelate#(pixelImg#)
  pixelate_blockcount#(pixelFx#, 20)
  
  println "Creating image 3 (Toon - ocean)..."
  toonImg# = image#(frm#, 260, 20, 110, 90)
  image_wrapmode#(toonImg#, 1)
  image_load#(toonImg#, "https://picsum.photos/seed/ocean/110/90")
  toonFx# = toon#(toonImg#)
  toon_levels#(toonFx#, 5)
  
  println "Creating image 4 (Sharpen - forest)..."
  sharpenImg# = image#(frm#, 380, 20, 110, 90)
  image_wrapmode#(sharpenImg#, 1)
  image_load#(sharpenImg#, "https://picsum.photos/seed/forest/110/90")
  sharpenFx# = sharpen#(sharpenImg#)
  sharpen_amount#(sharpenFx#, 1.0)
  
  println "Creating image 5 (PaperSketch - mountain)..."
  sketchImg# = image#(frm#, 500, 20, 110, 90)
  image_wrapmode#(sketchImg#, 1)
  image_load#(sketchImg#, "https://picsum.photos/seed/mountain/110/90")
  sketchFx# = papersketch#(sketchImg#)
  papersketch_brushsize#(sketchFx#, 1.0)
  
  println "Creating image 6 (PencilStroke - sunset)..."
  pencilImg# = image#(frm#, 620, 20, 110, 90)
  image_wrapmode#(pencilImg#, 1)
  image_load#(pencilImg#, "https://picsum.photos/seed/sunset/110/90")
  pencilFx# = pencilstroke#(pencilImg#)
  pencilstroke_brushsize#(pencilFx#, 1.0)
endfunction

' ============================================================================
' Gallery Creation
' ============================================================================

function CreatePixelateGallery() local i, img#, fx#, val
  i = 0
  while i < 5
    img# = image#(frm#, 30 + i * 75, 275, 65, 55)
    image_wrapmode#(img#, 1)
    image_load#(img#, "https://picsum.photos/seed/gallery1/65/55")
    
    fx# = pixelate#(img#)
    val = 5 + i * 18
    pixelate_blockcount#(fx#, val)
    
    i = i + 1
  endwhile
endfunction

function CreateToonGallery() local i, img#, fx#, val
  i = 0
  while i < 5
    img# = image#(frm#, 30 + i * 75, 375, 65, 55)
    image_wrapmode#(img#, 1)
    image_load#(img#, "https://picsum.photos/seed/gallery2/65/55")
    
    fx# = toon#(img#)
    val = 3 + i * 4
    toon_levels#(fx#, val)
    
    i = i + 1
  endwhile
endfunction

function CreateEmbossGallery() local i, img#, fx#, val
  i = 0
  while i < 4
    img# = image#(frm#, 420 + i * 70, 375, 60, 55)
    image_wrapmode#(img#, 1)
    image_load#(img#, "https://picsum.photos/seed/gallery3/60/55")
    
    fx# = emboss#(img#)
    val = 0.25 + i * 0.25
    emboss_amount#(fx#, val)
    
    i = i + 1
  endwhile
endfunction

' ============================================================================
' Emboss Controls
' ============================================================================

function EmbossLow(sender#)
  emboss_amount#(embossFx#, 0.3)
  label_text#(statusLbl#, "Emboss: 0.3 (light)")
endfunction

function EmbossMed(sender#)
  emboss_amount#(embossFx#, 0.6)
  label_text#(statusLbl#, "Emboss: 0.6 (medium)")
endfunction

function EmbossHigh(sender#)
  emboss_amount#(embossFx#, 1.0)
  label_text#(statusLbl#, "Emboss: 1.0 (strong)")
endfunction

' ============================================================================
' Pixelate Controls
' ============================================================================

function PixelLow(sender#)
  pixelate_blockcount#(pixelFx#, 5)
  label_text#(statusLbl#, "Pixelate: 5 blocks (very blocky)")
endfunction

function PixelMed(sender#)
  pixelate_blockcount#(pixelFx#, 20)
  label_text#(statusLbl#, "Pixelate: 20 blocks (medium)")
endfunction

function PixelHigh(sender#)
  pixelate_blockcount#(pixelFx#, 50)
  label_text#(statusLbl#, "Pixelate: 50 blocks (detailed)")
endfunction

' ============================================================================
' Toon Controls
' ============================================================================

function ToonLow(sender#)
  toon_levels#(toonFx#, 3)
  label_text#(statusLbl#, "Toon: 3 levels (very cartoon)")
endfunction

function ToonMed(sender#)
  toon_levels#(toonFx#, 8)
  label_text#(statusLbl#, "Toon: 8 levels (cartoon)")
endfunction

function ToonHigh(sender#)
  toon_levels#(toonFx#, 20)
  label_text#(statusLbl#, "Toon: 20 levels (subtle)")
endfunction

' ============================================================================
' Sharpen Controls
' ============================================================================

function SharpenLow(sender#)
  sharpen_amount#(sharpenFx#, 0.5)
  label_text#(statusLbl#, "Sharpen: 0.5 (light)")
endfunction

function SharpenMed(sender#)
  sharpen_amount#(sharpenFx#, 1.0)
  label_text#(statusLbl#, "Sharpen: 1.0 (normal)")
endfunction

function SharpenHigh(sender#)
  sharpen_amount#(sharpenFx#, 2.0)
  label_text#(statusLbl#, "Sharpen: 2.0 (strong)")
endfunction

' ============================================================================
' Sketch Controls
' ============================================================================

function SketchLow(sender#)
  papersketch_brushsize#(sketchFx#, 1.0)
  label_text#(statusLbl#, "PaperSketch: brush 1.0 (fine)")
endfunction

function SketchMed(sender#)
  papersketch_brushsize#(sketchFx#, 3.0)
  label_text#(statusLbl#, "PaperSketch: brush 3.0 (medium)")
endfunction

function SketchHigh(sender#)
  papersketch_brushsize#(sketchFx#, 6.0)
  label_text#(statusLbl#, "PaperSketch: brush 6.0 (thick)")
endfunction

' ============================================================================
' Pencil Controls
' ============================================================================

function PencilLow(sender#)
  pencilstroke_brushsize#(pencilFx#, 1.0)
  label_text#(statusLbl#, "PencilStroke: brush 1.0 (fine)")
endfunction

function PencilHigh(sender#)
  pencilstroke_brushsize#(pencilFx#, 3.0)
  label_text#(statusLbl#, "PencilStroke: brush 3.0 (thick)")
endfunction

' ============================================================================
' Global Actions
' ============================================================================

function ResetAll(sender#)
  emboss_amount#(embossFx#, 0.5)
  emboss_width#(embossFx#, 1.0)
  pixelate_blockcount#(pixelFx#, 20)
  toon_levels#(toonFx#, 5)
  sharpen_amount#(sharpenFx#, 1.0)
  papersketch_brushsize#(sketchFx#, 1.0)
  pencilstroke_brushsize#(pencilFx#, 1.0)
  
  emboss_enabled#(embossFx#, 1)
  pixelate_enabled#(pixelFx#, 1)
  toon_enabled#(toonFx#, 1)
  sharpen_enabled#(sharpenFx#, 1)
  papersketch_enabled#(sketchFx#, 1)
  pencilstroke_enabled#(pencilFx#, 1)
  
  label_text#(statusLbl#, "All effects reset to defaults")
endfunction

function ToggleAll(sender#) local e
  e = emboss_enabled(embossFx#)
  if e = 1 then
    emboss_enabled#(embossFx#, 0)
    pixelate_enabled#(pixelFx#, 0)
    toon_enabled#(toonFx#, 0)
    sharpen_enabled#(sharpenFx#, 0)
    papersketch_enabled#(sketchFx#, 0)
    pencilstroke_enabled#(pencilFx#, 0)
    label_text#(statusLbl#, "All effects DISABLED - showing original images")
  else
    emboss_enabled#(embossFx#, 1)
    pixelate_enabled#(pixelFx#, 1)
    toon_enabled#(toonFx#, 1)
    sharpen_enabled#(sharpenFx#, 1)
    papersketch_enabled#(sketchFx#, 1)
    pencilstroke_enabled#(pencilFx#, 1)
    label_text#(statusLbl#, "All effects ENABLED")
  endif
endfunction

function ReloadImages(sender#)
  label_text#(statusLbl#, "Reloading images from web...")
  
  image_load#(embossImg#, "https://picsum.photos/seed/nature2/110/90")
  image_load#(pixelImg#, "https://picsum.photos/seed/city2/110/90")
  image_load#(toonImg#, "https://picsum.photos/seed/ocean2/110/90")
  image_load#(sharpenImg#, "https://picsum.photos/seed/forest2/110/90")
  image_load#(sketchImg#, "https://picsum.photos/seed/mountain2/110/90")
  image_load#(pencilImg#, "https://picsum.photos/seed/sunset2/110/90")
  
  label_text#(statusLbl#, "New images loaded!")
endfunction

' ============================================================================
' Test Functions
' ============================================================================

function RunTests(sender#)
  testCount = 0
  passCount = 0
  
  println ""
  println "=== Tier-3 Artistic Effects Tests ==="
  println ""
  
  TestEmboss()
  TestPixelate()
  TestToon()
  TestSharpen()
  TestPaperSketch()
  TestPencilStroke()
  
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

function TestEmboss() local val, passed
  println "Testing EmbossEffect..."
  
  emboss_amount#(embossFx#, 0.7)
  val = emboss_amount(embossFx#)
  passed = 0
  if val >= 0.65 then
    if val <= 0.75 then
      passed = 1
    endif
  endif
  LogTest("Emboss: amount property", passed)
  
  emboss_width#(embossFx#, 3.0)
  val = emboss_width(embossFx#)
  passed = 0
  if val >= 2.9 then
    if val <= 3.1 then
      passed = 1
    endif
  endif
  LogTest("Emboss: width property", passed)
  
  emboss_amount#(embossFx#, 0.5)
  emboss_width#(embossFx#, 1.0)
endfunction

function TestPixelate() local val, passed
  println "Testing PixelateEffect..."
  
  pixelate_blockcount#(pixelFx#, 30)
  val = pixelate_blockcount(pixelFx#)
  passed = 0
  if val >= 29 then
    if val <= 31 then
      passed = 1
    endif
  endif
  LogTest("Pixelate: blockcount property", passed)
  
  pixelate_blockcount#(pixelFx#, 20)
endfunction

function TestToon() local val, passed
  println "Testing ToonEffect..."
  
  toon_levels#(toonFx#, 10)
  val = toon_levels(toonFx#)
  passed = 0
  if val >= 9 then
    if val <= 11 then
      passed = 1
    endif
  endif
  LogTest("Toon: levels property", passed)
  
  toon_levels#(toonFx#, 5)
endfunction

function TestSharpen() local val, passed
  println "Testing SharpenEffect..."
  
  sharpen_amount#(sharpenFx#, 1.5)
  val = sharpen_amount(sharpenFx#)
  passed = 0
  if val >= 1.4 then
    if val <= 1.6 then
      passed = 1
    endif
  endif
  LogTest("Sharpen: amount property", passed)
  
  sharpen_amount#(sharpenFx#, 1.0)
endfunction

function TestPaperSketch() local val, passed
  println "Testing PaperSketchEffect..."
  
  papersketch_brushsize#(sketchFx#, 4.0)
  val = papersketch_brushsize(sketchFx#)
  passed = 0
  if val >= 3.9 then
    if val <= 4.1 then
      passed = 1
    endif
  endif
  LogTest("PaperSketch: brushsize property", passed)
  
  papersketch_brushsize#(sketchFx#, 1.0)
endfunction

function TestPencilStroke() local val, passed
  println "Testing PencilStrokeEffect..."
  
  pencilstroke_brushsize#(pencilFx#, 2.5)
  val = pencilstroke_brushsize(pencilFx#)
  passed = 0
  if val >= 2.4 then
    if val <= 2.6 then
      passed = 1
    endif
  endif
  LogTest("PencilStroke: brushsize property", passed)
  
  pencilstroke_brushsize#(pencilFx#, 1.0)
endfunction
