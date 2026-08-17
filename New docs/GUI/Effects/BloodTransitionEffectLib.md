# BloodTransitionEffectLib

A dramatic transition effect that reveals the target image through a dripping "blood" pattern. The transition creates an eerie, horror-style visual effect.

## Functions

| Function | Description |
|----------|-------------|
| `bloodtrans#(parent#)` | Creates blood transition effect on control |
| `bloodtrans_free(effect#)` | Destroys the effect |
| `bloodtrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `bloodtrans_progress(effect#)` | Gets progress |
| `bloodtrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `bloodtrans_target#(effect#)` | Gets target bitmap |
| `bloodtrans_loadtarget#(effect#, url$)` | Loads target from URL |
| `bloodtrans_randomseed#(effect#, value)` | Sets random seed for pattern |
| `bloodtrans_randomseed(effect#)` | Gets random seed |
| `bloodtrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `bloodtrans_enabled(effect#)` | Gets enabled state |
| `bloodtrans_error()` | Returns last error code |
| `bloodtrans_errormsg$()` | Returns last error message |
| `bloodtrans_strerror$(code)` | Converts error code to text |
| `bloodtrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |
| RandomSeed | 0.0 - 1.0 | 0.0 | Seed for drip pattern randomization |

## Example 1: Basic Blood Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Blood Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create blood transition effect
trans# = bloodtrans#(img#)
bloodtrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
bloodtrans_randomseed#(trans#, 0.5)

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
  bloodtrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Horror Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Horror Transition", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = bloodtrans#(img#)
bloodtrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
bloodtrans_randomseed#(trans#, 0.3)

' Timer for animation
tmr# = timer#()
timer_interval#(tmr#, 50)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Start Drip")
button_bounds#(btn#, 140, 210, 120, 30)
button_onclick#(btn#, "StartAnim")

form_show(frm#)

function StartAnim(sender#)
  progress = 0
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#)
  progress = progress + 0.015
  bloodtrans_progress#(trans#, progress)
  
  if progress >= 1 then
    timer_enabled#(tmr#, 0)
    button_enabled#(btn#, 1)
  endif
endfunction
```

## Notes

- The RandomSeed creates different drip patterns for variety
- Slower animation (lower timer frequency) creates a creepier effect
- Perfect for Halloween or horror-themed applications

## See Also

- DissolveTransitionEffectLib - Dissolve transition effect
- FadeTransitionEffectLib - Fade transition effect
- WaterTransitionEffectLib - Water ripple transition
