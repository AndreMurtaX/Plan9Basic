# SlideTransitionEffectLib

A transition effect that slides the image in a specified direction. Creates a sliding/pushing animation effect commonly used in presentations and UI transitions.

## Important: Pixel Coordinates

SlideAmount uses **PIXEL coordinates**, not normalized 0-1 values. For a 200x150 image:
- SlideAmountX: Use values like 200, 400, etc. (pixels to slide horizontally)
- SlideAmountY: Use values like 150, 300, etc. (pixels to slide vertically)
- Progress: 0.0 to 1.0 (normalized)

## Functions

| Function | Description |
|----------|-------------|
| `slidetrans#(parent#)` | Creates slide transition effect on control |
| `slidetrans_free(effect#)` | Destroys the effect |
| `slidetrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `slidetrans_progress(effect#)` | Gets progress |
| `slidetrans_amountx#(effect#, value)` | Sets horizontal slide amount (pixels) |
| `slidetrans_amountx(effect#)` | Gets X slide amount |
| `slidetrans_amounty#(effect#, value)` | Sets vertical slide amount (pixels) |
| `slidetrans_amounty(effect#)` | Gets Y slide amount |
| `slidetrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `slidetrans_enabled(effect#)` | Gets enabled state |
| `slidetrans_trigger#(effect#, trigger$)` | Sets trigger string |
| `slidetrans_trigger$(effect#)` | Gets trigger string |
| `slidetrans_error()` | Returns last error code |
| `slidetrans_errormsg$()` | Returns last error message |
| `slidetrans_strerror$(code)` | Converts error code to text |
| `slidetrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress |
| SlideAmountX | pixels | 0 | Horizontal slide distance (+ = right, - = left) |
| SlideAmountY | pixels | 0 | Vertical slide distance (+ = down, - = up) |

## Example 1: Basic Slide Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

let imgW = 200
let imgH = 150

frm# = form#("Slide Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, imgW, imgH)
image_load#(img#, "https://picsum.photos/200/150")

' Create slide transition (slide right by image width)
trans# = slidetrans#(img#)
slidetrans_amountx#(trans#, imgW)
slidetrans_amounty#(trans#, 0)

' Progress slider
lblProg# = label#(frm#, "Progress: 0.00", 50, 200)
trkProg# = trackbar#(frm#)
trackbar_bounds#(trkProg#, 50, 230, 350, 30)
trackbar_max#(trkProg#, 100)
trackbar_value#(trkProg#, 0)
trackbar_onchange#(trkProg#, "OnProgress")

form_show(frm#)

function OnProgress(sender#) local p
  let p = trackbar_value(trkProg#) / 100
  slidetrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Slide

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let lblProg# = Pointer#(0)
let progress = 0

let imgW = 200

frm# = form#("Animated Slide", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, imgW, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Slide right by image width
trans# = slidetrans#(img#)
slidetrans_amountx#(trans#, imgW)
slidetrans_amounty#(trans#, 0)

lblProg# = label#(frm#, "Progress: 0.00", 140, 250)

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Slide Right!")
button_bounds#(btn#, 140, 210, 120, 30)
button_onclick#(btn#, "StartSlide")

form_show(frm#)

function StartSlide(sender#)
  progress = 0
  slidetrans_progress#(trans#, 0)
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#)
  progress = progress + 0.03
  slidetrans_progress#(trans#, progress)
  label_text#(lblProg#, "Progress: " + stri$(progress, 2))
  
  if progress >= 1 then
    timer_enabled#(tmr#, 0)
    button_enabled#(btn#, 1)
  endif
endfunction
```

## Example 3: Direction Buttons

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)

let imgW = 200
let imgH = 150

frm# = form#("Slide Directions", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, imgW, imgH)
image_load#(img#, "https://picsum.photos/200/150")

trans# = slidetrans#(img#)
slidetrans_amountx#(trans#, imgW)
slidetrans_progress#(trans#, 0.5)

let btnL# = button#(frm#, "Left")
button_bounds#(btnL#, 50, 210, 80, 30)
button_onclick#(btnL#, "SlideLeft")

let btnR# = button#(frm#, "Right")
button_bounds#(btnR#, 140, 210, 80, 30)
button_onclick#(btnR#, "SlideRight")

let btnU# = button#(frm#, "Up")
button_bounds#(btnU#, 230, 210, 80, 30)
button_onclick#(btnU#, "SlideUp")

let btnD# = button#(frm#, "Down")
button_bounds#(btnD#, 320, 210, 80, 30)
button_onclick#(btnD#, "SlideDown")

form_show(frm#)

function SlideLeft(sender#)
  slidetrans_amountx#(trans#, 0 - imgW)
  slidetrans_amounty#(trans#, 0)
endfunction

function SlideRight(sender#)
  slidetrans_amountx#(trans#, imgW)
  slidetrans_amounty#(trans#, 0)
endfunction

function SlideUp(sender#)
  slidetrans_amountx#(trans#, 0)
  slidetrans_amounty#(trans#, 0 - imgH)
endfunction

function SlideDown(sender#)
  slidetrans_amountx#(trans#, 0)
  slidetrans_amounty#(trans#, imgH)
endfunction
```

## Notes

- **SlideAmount is in PIXELS**, not normalized 0-1 values
- SlideAmountX positive = slide right, negative = slide left
- SlideAmountY positive = slide down, negative = slide up
- At progress 0, image is in original position
- At progress 1, image is fully slid by the amount specified
- To slide entire image off-screen, use image width/height as amount
- Works on the source image only (no target image required)

## See Also

- SwipeTransitionEffectLib - Page swipe transition
- BlindTransitionEffectLib - Blind/stripe transition
- FadeTransitionEffectLib - Cross-fade transition
