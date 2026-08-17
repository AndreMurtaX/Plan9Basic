# RippleTransitionEffectLib

A transition effect that uses water-like ripples to transition between the source and target images. Creates a visually appealing "water drop" style transition.

## Functions

| Function | Description |
|----------|-------------|
| `rippletrans#(parent#)` | Creates ripple transition effect on control |
| `rippletrans_free(effect#)` | Destroys the effect |
| `rippletrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `rippletrans_progress(effect#)` | Gets progress |
| `rippletrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `rippletrans_target#(effect#)` | Gets target bitmap |
| `rippletrans_loadtarget#(effect#, url$)` | Loads target from URL or file |
| `rippletrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `rippletrans_enabled(effect#)` | Gets enabled state |
| `rippletrans_error()` | Returns last error code |
| `rippletrans_errormsg$()` | Returns last error message |
| `rippletrans_strerror$(code)` | Converts error code to text |
| `rippletrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |

## Example 1: Basic Ripple Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Ripple Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create ripple transition effect
trans# = rippletrans#(img#)
rippletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  rippletrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Ripple Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Animated Ripple Transition", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = rippletrans#(img#)
rippletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Ripple!")
button_bounds#(btn#, 150, 210, 100, 30)
button_onclick#(btn#, "StartTransition")

form_show(frm#)

function StartTransition(sender#)
  progress = 0
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#)
  progress = progress + 0.02
  rippletrans_progress#(trans#, progress)
  
  if progress >= 1 then
    timer_enabled#(tmr#, 0)
    button_enabled#(btn#, 1)
  endif
endfunction
```

## Example 3: Toggle Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let btn# = Pointer#(0)
let isOn = 1

frm# = form#("Toggle Ripple Transition", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = rippletrans#(img#)
rippletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
rippletrans_progress#(trans#, 0.5)

btn# = button#(frm#, "Disable Effect")
button_bounds#(btn#, 130, 210, 140, 30)
button_onclick#(btn#, "Toggle")

form_show(frm#)

function Toggle(sender#)
  if isOn = 1 then
    rippletrans_enabled#(trans#, 0)
    isOn = 0
    button_text#(btn#, "Enable Effect")
  else
    rippletrans_enabled#(trans#, 1)
    isOn = 1
    button_text#(btn#, "Disable Effect")
  endif
endfunction
```

## Notes

- Transition effects require a TARGET image to work properly
- At progress 0, source image is shown
- At progress 1, target image is shown
- Mid-transition shows rippling/wave distortion
- Creates a "water drop" or "pond ripple" style transition
- Very visually appealing for presentations

## See Also

- RippleEffectLib - Static/animated ripple effect
- WaveTransitionEffectLib - Wave-based transition
- WaterTransitionEffectLib - Water-drop transition
