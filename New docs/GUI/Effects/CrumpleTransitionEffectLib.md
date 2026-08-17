# CrumpleTransitionEffectLib

A transition effect that simulates paper being crumpled or distorted during the transition. Creates an organic, chaotic transition between two images.

## Functions

| Function | Description |
|----------|-------------|
| `crumpletrans#(parent#)` | Creates crumple transition effect on control |
| `crumpletrans_free(effect#)` | Destroys the effect |
| `crumpletrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `crumpletrans_progress(effect#)` | Gets progress |
| `crumpletrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `crumpletrans_target#(effect#)` | Gets target bitmap |
| `crumpletrans_loadtarget#(effect#, url$)` | Loads target from URL or file |
| `crumpletrans_randomseed#(effect#, value)` | Sets random seed (0-1) |
| `crumpletrans_randomseed(effect#)` | Gets random seed |
| `crumpletrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `crumpletrans_enabled(effect#)` | Gets enabled state |
| `crumpletrans_error()` | Returns last error code |
| `crumpletrans_errormsg$()` | Returns last error message |
| `crumpletrans_strerror$(code)` | Converts error code to text |
| `crumpletrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |
| RandomSeed | 0.0 - 1.0 | 0.0 | Seed for crumple pattern randomization |

## Example 1: Basic Crumple Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Crumple Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create crumple transition effect
trans# = crumpletrans#(img#)
crumpletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  crumpletrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Crumple

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Animated Crumple", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = crumpletrans#(img#)
crumpletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Crumple!")
button_bounds#(btn#, 150, 210, 100, 30)
button_onclick#(btn#, "StartCrumple")

form_show(frm#)

function StartCrumple(sender#)
  progress = 0
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#)
  progress = progress + 0.02
  crumpletrans_progress#(trans#, progress)
  
  if progress >= 1 then
    timer_enabled#(tmr#, 0)
    button_enabled#(btn#, 1)
  endif
endfunction
```

## Example 3: Different Random Patterns

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let trkSeed# = Pointer#(0)
let lblProg# = Pointer#(0)
let lblSeed# = Pointer#(0)

frm# = form#("Crumple Patterns", 500, 420)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = crumpletrans#(img#)
crumpletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

' Progress control
lblProg# = label#(frm#, "Progress: 0.50", 30, 190)
trkProg# = trackbar#(frm#)
trackbar_bounds#(trkProg#, 30, 215, 440, 25)
trackbar_max#(trkProg#, 100)
trackbar_value#(trkProg#, 50)
trackbar_onchange#(trkProg#, "OnProgress")

' Random seed control
lblSeed# = label#(frm#, "Random Seed: 0.00", 30, 260)
trkSeed# = trackbar#(frm#)
trackbar_bounds#(trkSeed#, 30, 285, 440, 25)
trackbar_max#(trkSeed#, 100)
trackbar_value#(trkSeed#, 0)
trackbar_onchange#(trkSeed#, "OnSeed")

' Set initial progress
crumpletrans_progress#(trans#, 0.5)

form_show(frm#)

function OnProgress(sender#) local p
  let p = trackbar_value(trkProg#) / 100
  crumpletrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction

function OnSeed(sender#) local s
  let s = trackbar_value(trkSeed#) / 100
  crumpletrans_randomseed#(trans#, s)
  label_text#(lblSeed#, "Random Seed: " + stri$(s, 2))
endfunction
```

## Notes

- Transition effects require a TARGET image to work properly
- The RandomSeed property changes the crumple pattern
- Different seeds produce different distortion patterns
- Creates an organic, paper-like transition effect

## See Also

- RotateCrumpleTransitionEffectLib - Rotating crumple effect
- DissolveTransitionEffectLib - Pixel dissolve transition
- RippleTransitionEffectLib - Water ripple transition
