# SwirlTransitionEffectLib

A transition effect that uses a swirling/spinning animation to transition between the source and target images. Creates a dynamic vortex-like transition.

## Functions

| Function | Description |
|----------|-------------|
| `swirltrans#(parent#)` | Creates swirl transition on control |
| `swirltrans_free(effect#)` | Destroys the effect |
| `swirltrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `swirltrans_progress(effect#)` | Gets progress |
| `swirltrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `swirltrans_target#(effect#)` | Gets target bitmap |
| `swirltrans_loadtarget#(effect#, url$)` | Loads target from URL or file |
| `swirltrans_strength#(effect#, value)` | Sets swirl intensity |
| `swirltrans_strength(effect#)` | Gets strength |
| `swirltrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `swirltrans_enabled(effect#)` | Gets enabled state |
| `swirltrans_error()` | Returns last error code |
| `swirltrans_errormsg$()` | Returns last error message |
| `swirltrans_strerror$(code)` | Converts error code to text |
| `swirltrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |
| Strength | 0.0+ | 10 | Swirl intensity during transition |

## Example 1: Basic Swirl Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Swirl Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create swirl transition effect
trans# = swirltrans#(img#)
swirltrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  swirltrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Swirl Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Animated Swirl Transition", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = swirltrans#(img#)
swirltrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
swirltrans_strength#(trans#, 15)

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Swirl!")
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
  swirltrans_progress#(trans#, progress)
  
  if progress >= 1 then
    timer_enabled#(tmr#, 0)
    button_enabled#(btn#, 1)
  endif
endfunction
```

## Example 3: Adjust Swirl Strength

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkStr# = Pointer#(0)
let lblStr# = Pointer#(0)

frm# = form#("Swirl Strength Control", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = swirltrans#(img#)
swirltrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
swirltrans_progress#(trans#, 0.5)

' Strength slider
lblStr# = label#(frm#, "Strength: 10", 50, 200)
trkStr# = trackbar#(frm#)
trackbar_bounds#(trkStr#, 50, 230, 350, 30)
trackbar_max#(trkStr#, 30)
trackbar_value#(trkStr#, 10)
trackbar_onchange#(trkStr#, "OnStrength")

form_show(frm#)

function OnStrength(sender#) local s
  let s = trackbar_value(trkStr#)
  swirltrans_strength#(trans#, s)
  label_text#(lblStr#, "Strength: " + str$(s))
endfunction
```

## Notes

- Transition effects require a TARGET image to work properly
- At progress 0, source image is shown
- At progress 1, target image is shown
- Higher strength values create more dramatic swirls
- Creates a vortex/spinning transition effect
- Great for dramatic or magical transitions

## See Also

- SwirlEffectLib - Static swirl effect
- RippleTransitionEffectLib - Ripple-based transition
- RotateCrumpleTransitionEffectLib - Rotate/crumple transition
