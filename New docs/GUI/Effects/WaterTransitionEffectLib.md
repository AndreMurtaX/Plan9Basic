# WaterTransitionEffectLib

A transition effect that simulates a water-drop or splash effect when transitioning between the source and target images. Creates a liquid/water distortion during the transition.

## Functions

| Function | Description |
|----------|-------------|
| `watertrans#(parent#)` | Creates water transition on control |
| `watertrans_free(effect#)` | Destroys the effect |
| `watertrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `watertrans_progress(effect#)` | Gets progress |
| `watertrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `watertrans_target#(effect#)` | Gets target bitmap |
| `watertrans_loadtarget#(effect#, url$)` | Loads target from URL or file |
| `watertrans_randomseed#(effect#, value)` | Sets random seed for pattern |
| `watertrans_randomseed(effect#)` | Gets random seed |
| `watertrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `watertrans_enabled(effect#)` | Gets enabled state |
| `watertrans_error()` | Returns last error code |
| `watertrans_errormsg$()` | Returns last error message |
| `watertrans_strerror$(code)` | Converts error code to text |
| `watertrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |
| RandomSeed | 0.0+ | 0.0 | Random seed for water pattern |

## Example 1: Basic Water Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Water Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create water transition effect
trans# = watertrans#(img#)
watertrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  watertrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Water Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Animated Water", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = watertrans#(img#)
watertrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Splash!")
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
  watertrans_progress#(trans#, progress)
  
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

frm# = form#("Water Pattern Variation", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = watertrans#(img#)
watertrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
watertrans_progress#(trans#, 0.5)

' Random seed slider
lblSeed# = label#(frm#, "Random Seed: 0", 50, 200)
trkSeed# = trackbar#(frm#)
trackbar_bounds#(trkSeed#, 50, 230, 350, 30)
trackbar_max#(trkSeed#, 0.99)
trackbar_value#(trkSeed#, 0)
trackbar_onchange#(trkSeed#, "OnSeed")

form_show(frm#)

function OnSeed(sender#) local s
  let s = trackbar_value(trkSeed#)
  watertrans_randomseed#(trans#, s)
  label_text#(lblSeed#, "Random Seed: " + str$(s))
endfunction
```

## Notes

- Transition effects require a TARGET image to work properly
- At progress 0, source image is shown
- At progress 1, target image is shown
- RandomSeed changes the water/splash pattern variation
- Creates a liquid/water splash style transition
- Great for nature or fluid-themed presentations

## See Also

- RippleTransitionEffectLib - Ripple-based transition
- WaveTransitionEffectLib - Wave-based transition
- DropTransitionEffectLib - Drop/drip transition
