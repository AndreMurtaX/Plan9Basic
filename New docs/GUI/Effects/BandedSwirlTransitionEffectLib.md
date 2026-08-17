# BandedSwirlTransitionEffectLib

A transition effect that uses a banded swirl pattern to blend between two images. Animate the Progress property to transition from source to target.

## Functions

| Function | Description |
|----------|-------------|
| `bandedswirltr#(parent#)` | Creates transition effect on control |
| `bandedswirltr_free(effect#)` | Destroys the effect |
| `bandedswirltr_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `bandedswirltr_progress(effect#)` | Gets progress |
| `bandedswirltr_target#(effect#, bitmap#)` | Sets target bitmap |
| `bandedswirltr_target#(effect#)` | Gets target bitmap |
| `bandedswirltr_loadtarget#(effect#, url$)` | Loads target from URL |
| `bandedswirltr_strength#(effect#, value)` | Sets swirl strength |
| `bandedswirltr_strength(effect#)` | Gets strength |
| `bandedswirltr_frequency#(effect#, value)` | Sets band frequency |
| `bandedswirltr_frequency(effect#)` | Gets frequency |
| `bandedswirltr_centerx#(effect#, value)` | Sets center X |
| `bandedswirltr_centerx(effect#)` | Gets center X |
| `bandedswirltr_centery#(effect#, value)` | Sets center Y |
| `bandedswirltr_centery(effect#)` | Gets center Y |
| `bandedswirltr_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `bandedswirltr_enabled(effect#)` | Gets enabled state |
| `bandedswirltr_error()` | Returns last error code |
| `bandedswirltr_errormsg$()` | Returns last error message |
| `bandedswirltr_strerror$(code)` | Converts error code to text |
| `bandedswirltr_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |
| Strength | any | 1.0 | Intensity of swirl distortion |
| Frequency | any | 20 | Number of swirl bands |
| CenterX | 0.0 - 1.0 | 0.5 | Horizontal center of swirl |
| CenterY | 0.0 - 1.0 | 0.5 | Vertical center of swirl |

## Example 1: Basic Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Banded Swirl Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create transition effect
trans# = bandedswirltr#(img#)
bandedswirltr_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
bandedswirltr_strength#(trans#, 1.5)
bandedswirltr_frequency#(trans#, 15)

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
  bandedswirltr_progress#(trans#, p)
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

frm# = form#("Animated Transition", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = bandedswirltr#(img#)
bandedswirltr_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
bandedswirltr_strength#(trans#, 1.0)

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
  bandedswirltr_progress#(trans#, progress)
  
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

## Notes

- Set the target image before animating progress
- Progress 0.0 shows the original image, 1.0 shows the target
- The swirl creates a visually interesting blend between images

## See Also

- SwirlTransitionEffectLib - Simple swirl transition
- BlindTransitionEffectLib - Blinds transition effect
- DissolveTransitionEffectLib - Dissolve transition
