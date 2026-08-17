# BlindTransitionEffectLib

A transition effect that reveals the target image through vertical blinds, like window blinds opening. Animate Progress to transition between images.

## Functions

| Function | Description |
|----------|-------------|
| `blindtrans#(parent#)` | Creates blind transition effect on control |
| `blindtrans_free(effect#)` | Destroys the effect |
| `blindtrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `blindtrans_progress(effect#)` | Gets progress |
| `blindtrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `blindtrans_target#(effect#)` | Gets target bitmap |
| `blindtrans_loadtarget#(effect#, url$)` | Loads target from URL |
| `blindtrans_targetfromimage#(effect#, image#)` | Sets target from TImage control |
| `blindtrans_numblinds#(effect#, value)` | Sets number of blinds (2-100) |
| `blindtrans_numblinds(effect#)` | Gets number of blinds |
| `blindtrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `blindtrans_enabled(effect#)` | Gets enabled state |
| `blindtrans_trigger#(effect#, trigger$)` | Sets trigger string |
| `blindtrans_trigger$(effect#)` | Gets trigger string |
| `blindtrans_error()` | Returns last error code |
| `blindtrans_errormsg$()` | Returns last error message |
| `blindtrans_strerror$(code)` | Converts error code to text |
| `blindtrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |
| NumberOfBlinds | 2 - 100 | 5 | Number of vertical blinds |

## Example 1: Basic Blind Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Blind Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create blind transition effect
trans# = blindtrans#(img#)
blindtrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
blindtrans_numblinds#(trans#, 8)

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
  blindtrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Transition with Timer

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0
let direction = 1

frm# = form#("Animated Blinds", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = blindtrans#(img#)
blindtrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
blindtrans_numblinds#(trans#, 10)

' Timer for animation
tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Start Transition")
button_bounds#(btn#, 130, 210, 140, 30)
button_onclick#(btn#, "StartAnim")

form_show(frm#)

function StartAnim(sender#)
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#)
  progress = progress + (direction * 0.02)
  blindtrans_progress#(trans#, progress)
  
  if progress >= 1 then
    direction = -1
  endif
  if progress <= 0 then
    direction = 1
    timer_enabled#(tmr#, 0)
    button_enabled#(btn#, 1)
  endif
endfunction
```

## Example 3: Adjustable Number of Blinds

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkBlinds# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblBlinds# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Blinds Control", 450, 450)

img# = image#(frm#)
image_bounds#(img#, 125, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = blindtrans#(img#)
blindtrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
blindtrans_numblinds#(trans#, 5)

' Number of blinds slider
lblBlinds# = label#(frm#, "Blinds: 5", 50, 190)
trkBlinds# = trackbar#(frm#)
trackbar_bounds#(trkBlinds#, 50, 220, 350, 30)
trackbar_max#(trkBlinds#, 98)
trackbar_value#(trkBlinds#, 3)
trackbar_onchange#(trkBlinds#, "OnBlindsChange")

' Progress slider
lblProg# = label#(frm#, "Progress: 0.00", 50, 270)
trkProg# = trackbar#(frm#)
trackbar_bounds#(trkProg#, 50, 300, 350, 30)
trackbar_max#(trkProg#, 100)
trackbar_value#(trkProg#, 0)
trackbar_onchange#(trkProg#, "OnProgress")

form_show(frm#)

function OnBlindsChange(sender#) local b
  let b = trackbar_value(trkBlinds#) + 2
  blindtrans_numblinds#(trans#, b)
  label_text#(lblBlinds#, "Blinds: " + str$(b))
endfunction

function OnProgress(sender#) local p
  let p = trackbar_value(trkProg#) / 100
  blindtrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Notes

- Set the target image before animating progress
- Progress 0.0 shows the original image, 1.0 shows the target
- More blinds create a finer transition effect
- Minimum 2 blinds, maximum 100 blinds

## See Also

- SlideTransitionEffectLib - Slide transition effect
- FadeTransitionEffectLib - Fade transition effect
- DissolveTransitionEffectLib - Dissolve transition effect
