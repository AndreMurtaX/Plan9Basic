# RotateCrumpleTransitionEffectLib

A transition effect that combines rotation and crumpling animations to transition between the source and target images. Creates a dynamic, paper-like crumpling effect with rotation.

## Functions

| Function | Description |
|----------|-------------|
| `rotcrumpletrans#(parent#)` | Creates rotate crumple transition on control |
| `rotcrumpletrans_free(effect#)` | Destroys the effect |
| `rotcrumpletrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `rotcrumpletrans_progress(effect#)` | Gets progress |
| `rotcrumpletrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `rotcrumpletrans_target#(effect#)` | Gets target bitmap |
| `rotcrumpletrans_loadtarget#(effect#, url$)` | Loads target from URL or file |
| `rotcrumpletrans_randomseed#(effect#, value)` | Sets random seed for pattern |
| `rotcrumpletrans_randomseed(effect#)` | Gets random seed |
| `rotcrumpletrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `rotcrumpletrans_enabled(effect#)` | Gets enabled state |
| `rotcrumpletrans_error()` | Returns last error code |
| `rotcrumpletrans_errormsg$()` | Returns last error message |
| `rotcrumpletrans_strerror$(code)` | Converts error code to text |
| `rotcrumpletrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |
| RandomSeed | 0.0+ | 0.0 | Random seed for crumple pattern |

## Example 1: Basic Rotate Crumple Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Rotate Crumple Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create rotate crumple transition effect
trans# = rotcrumpletrans#(img#)
rotcrumpletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  rotcrumpletrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Rotate Crumple

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Animated Rotate Crumple", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = rotcrumpletrans#(img#)
rotcrumpletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Crumple!")
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
  rotcrumpletrans_progress#(trans#, progress)
  
  if progress >= 1 then
    timer_enabled#(tmr#, 0)
    button_enabled#(btn#, 1)
  endif
endfunction
```

## Example 3: Random Seed Variation

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkSeed# = Pointer#(0)
let lblSeed# = Pointer#(0)

frm# = form#("Crumple Pattern Variation", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = rotcrumpletrans#(img#)
rotcrumpletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
rotcrumpletrans_progress#(trans#, 0.5)

' Random seed slider
lblSeed# = label#(frm#, "Random Seed: 0", 50, 200)
trkSeed# = trackbar#(frm#)
trackbar_bounds#(trkSeed#, 50, 230, 350, 30)
trackbar_max#(trkSeed#, 100)
trackbar_value#(trkSeed#, 0)
trackbar_onchange#(trkSeed#, "OnSeed")

form_show(frm#)

function OnSeed(sender#) local s
  let s = trackbar_value(trkSeed#)
  rotcrumpletrans_randomseed#(trans#, s)
  label_text#(lblSeed#, "Random Seed: " + str$(s))
endfunction
```

## Notes

- Transition effects require a TARGET image to work properly
- At progress 0, source image is shown
- At progress 1, target image is shown
- RandomSeed changes the crumple pattern variation
- Combines rotation and crumpling for dynamic effect
- Great for dramatic slide transitions

## See Also

- CrumpleTransitionEffectLib - Basic crumple transition
- RotateTransitionEffectLib - Rotation-only transition
- BloodTransitionEffectLib - Dramatic drip transition
