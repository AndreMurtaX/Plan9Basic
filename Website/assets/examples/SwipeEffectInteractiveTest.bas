' ============================================================================
' Swipe Effect Interactive Test - Plan9Basic
' Tests TSwipeTransitionEffect with mouse interaction
' MousePoint uses PIXEL coordinates (not normalized 0-1)
' ============================================================================

' Module-level variables
let frm# = Pointer#(0)
let img# = Pointer#(0)
let fxSwipe# = Pointer#(0)
let lblMouseX# = Pointer#(0)
let lblMouseY# = Pointer#(0)
let lblDeep# = Pointer#(0)

' Image dimensions (for reference)
let imgWidth = 400
let imgHeight = 280

' ----------------------------------------------------------------------------
' Main Program
' ----------------------------------------------------------------------------

' Create main form
frm# = form#("Swipe Effect Interactive Test", 550, 520)

' Title and instructions
label#(frm#, "Swipe Effect - Interactive Mouse Control", 20, 15)
label#(frm#, "Move mouse over image to pull page corner", 20, 40)

' Create source image (this is what folds)
img# = image#(frm#, 20, 70, imgWidth, imgHeight)
image_load#(img#, "https://picsum.photos/seed/swipesource/400/280")

' Set up mouse events on the image
image_onmousemove#(img#, "OnImageMouseMove")
image_onmouseleave#(img#, "OnImageMouseLeave")

' Create the swipe effect
fxSwipe# = swipetrans#(img#)

' Load target image (what shows UNDER the fold)
swipetrans_loadtarget#(fxSwipe#, "https://picsum.photos/seed/swipetarget/400/280")

' Initial position - at corner (no fold visible)
' MousePoint is in PIXELS - start at (0,0) which is at the corner
swipetrans_mousex#(fxSwipe#, 0)
swipetrans_mousey#(fxSwipe#, 0)
swipetrans_deep#(fxSwipe#, 50)

' ----------------------------------------------------------------------------
' Status Labels
' ----------------------------------------------------------------------------
label#(frm#, "Mouse X:", 440, 70)
lblMouseX# = label#(frm#, "0 px", 440, 90)

label#(frm#, "Mouse Y:", 440, 120)
lblMouseY# = label#(frm#, "0 px", 440, 140)

label#(frm#, "Deep:", 440, 180)
lblDeep# = label#(frm#, "50", 440, 200)

label#(frm#, "Image:", 440, 240)
label#(frm#, "400x280 px", 440, 260)

' ----------------------------------------------------------------------------
' Deep Control (fold intensity)
' ----------------------------------------------------------------------------
label#(frm#, "Fold Depth:", 20, 365)

let btnDeep20# = button#(frm#, "20", 100, 360, 50, 35)
button_onclick#(btnDeep20#, "OnDeep20")

let btnDeep50# = button#(frm#, "50", 155, 360, 50, 35)
button_onclick#(btnDeep50#, "OnDeep50")

let btnDeep80# = button#(frm#, "80", 210, 360, 50, 35)
button_onclick#(btnDeep80#, "OnDeep80")

let btnDeep100# = button#(frm#, "100", 265, 360, 50, 35)
button_onclick#(btnDeep100#, "OnDeep100")

' ----------------------------------------------------------------------------
' Preset Positions (in pixels)
' ----------------------------------------------------------------------------
label#(frm#, "Preset Positions:", 20, 410)

let btnCorner# = button#(frm#, "Corner", 20, 435, 70, 35)
button_onclick#(btnCorner#, "OnCorner")

let btnQuarter# = button#(frm#, "Quarter", 95, 435, 70, 35)
button_onclick#(btnQuarter#, "OnQuarter")

let btnHalf# = button#(frm#, "Half", 170, 435, 70, 35)
button_onclick#(btnHalf#, "OnHalf")

let btnThreeQ# = button#(frm#, "3/4", 245, 435, 70, 35)
button_onclick#(btnThreeQ#, "OnThreeQuarter")

let btnFull# = button#(frm#, "Full", 320, 435, 70, 35)
button_onclick#(btnFull#, "OnFull")

let btnReset# = button#(frm#, "Reset", 395, 435, 70, 35)
button_onclick#(btnReset#, "OnReset")

' Info label
label#(frm#, "MousePoint uses PIXELS. CornerPoint=(0,0) = top-left corner.", 20, 485)

' Show the form
form_show(frm#)
end

' ============================================================================
' Mouse Event Callbacks
' ============================================================================

function OnImageMouseMove(sender#, x, y, shift$)
  ' x and y are already in pixel coordinates!
  ' Apply directly to swipe effect
  swipetrans_mousex#(fxSwipe#, x)
  swipetrans_mousey#(fxSwipe#, y)
  
  ' Update labels
  label_text#(lblMouseX#, str$(int(x)) + " px")
  label_text#(lblMouseY#, str$(int(y)) + " px")
endfunction

function OnImageMouseLeave(sender#)
  ' Reset to corner when mouse leaves
  swipetrans_mousex#(fxSwipe#, 0)
  swipetrans_mousey#(fxSwipe#, 0)
  label_text#(lblMouseX#, "0 px")
  label_text#(lblMouseY#, "0 px")
endfunction

' ============================================================================
' Deep Control Callbacks
' ============================================================================

function OnDeep20(sender#)
  swipetrans_deep#(fxSwipe#, 20)
  label_text#(lblDeep#, "20")
endfunction

function OnDeep50(sender#)
  swipetrans_deep#(fxSwipe#, 50)
  label_text#(lblDeep#, "50")
endfunction

function OnDeep80(sender#)
  swipetrans_deep#(fxSwipe#, 80)
  label_text#(lblDeep#, "80")
endfunction

function OnDeep100(sender#)
  swipetrans_deep#(fxSwipe#, 100)
  label_text#(lblDeep#, "100")
endfunction

' ============================================================================
' Preset Position Callbacks (using pixel values)
' ============================================================================

function OnCorner(sender#)
  ' At corner - minimal/no fold
  swipetrans_mousex#(fxSwipe#, 0)
  swipetrans_mousey#(fxSwipe#, 0)
  label_text#(lblMouseX#, "0 px")
  label_text#(lblMouseY#, "0 px")
endfunction

function OnQuarter(sender#)
  ' Quarter way across (100, 70)
  swipetrans_mousex#(fxSwipe#, 100)
  swipetrans_mousey#(fxSwipe#, 70)
  label_text#(lblMouseX#, "100 px")
  label_text#(lblMouseY#, "70 px")
endfunction

function OnHalf(sender#)
  ' Half way across (200, 140)
  swipetrans_mousex#(fxSwipe#, 200)
  swipetrans_mousey#(fxSwipe#, 140)
  label_text#(lblMouseX#, "200 px")
  label_text#(lblMouseY#, "140 px")
endfunction

function OnThreeQuarter(sender#)
  ' Three quarters across (300, 210)
  swipetrans_mousex#(fxSwipe#, 300)
  swipetrans_mousey#(fxSwipe#, 210)
  label_text#(lblMouseX#, "300 px")
  label_text#(lblMouseY#, "210 px")
endfunction

function OnFull(sender#)
  ' Full page turn (400, 280) - opposite corner
  swipetrans_mousex#(fxSwipe#, 400)
  swipetrans_mousey#(fxSwipe#, 280)
  label_text#(lblMouseX#, "400 px")
  label_text#(lblMouseY#, "280 px")
endfunction

function OnReset(sender#)
  swipetrans_mousex#(fxSwipe#, 0)
  swipetrans_mousey#(fxSwipe#, 0)
  swipetrans_deep#(fxSwipe#, 50)
  label_text#(lblMouseX#, "0 px")
  label_text#(lblMouseY#, "0 px")
  label_text#(lblDeep#, "50")
endfunction
