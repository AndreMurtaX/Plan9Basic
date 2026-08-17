# ShapeTransitionEffectLib

A transition effect that uses geometric shapes to reveal the target image through the source image. Creates a dynamic, pattern-based transition.

## Functions

| Function | Description |
|----------|-------------|
| `shapetrans#(parent#)` | Creates shape transition on control |
| `shapetrans_free(effect#)` | Destroys the effect |
| `shapetrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `shapetrans_progress(effect#)` | Gets progress |
| `shapetrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `shapetrans_target#(effect#)` | Gets target bitmap |
| `shapetrans_loadtarget#(effect#, url$)` | Loads target from URL or file |
| `shapetrans_randomseed#(effect#, value)` | Sets random seed for pattern |
| `shapetrans_randomseed(effect#)` | Gets random seed |
| `shapetrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `shapetrans_enabled(effect#)` | Gets enabled state |
| `shapetrans_error()` | Returns last error code |
| `shapetrans_errormsg$()` | Returns last error message |
| `shapetrans_strerror$(code)` | Converts error code to text |
| `shapetrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |
| RandomSeed | 0.0+ | 0.0 | Random seed for shape pattern |

## Example 1: Basic Shape Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Shape Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create shape transition effect
trans# = shapetrans#(img#)
shapetrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  shapetrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Shape Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Animated Shape Transition", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = shapetrans#(img#)
shapetrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Transition!")
button_bounds#(btn#, 140, 210, 120, 30)
button_onclick#(btn#, "StartTransition")

form_show(frm#)

function StartTransition(sender#)
  progress = 0
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#)
  progress = progress + 0.02
  shapetrans_progress#(trans#, progress)
  
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

frm# = form#("Shape Pattern Variation", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = shapetrans#(img#)
shapetrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
shapetrans_progress#(trans#, 0.5)

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
  shapetrans_randomseed#(trans#, s)
  label_text#(lblSeed#, "Random Seed: " + str$(s))
endfunction
```

## Notes

- Transition effects require a TARGET image to work properly
- At progress 0, source image is shown
- At progress 1, target image is shown
- RandomSeed changes the shape pattern variation
- Shapes expand/contract to reveal target image
- Great for presentation-style transitions

## See Also

- CircleTransitionEffectLib - Circle-based transition
- BlindTransitionEffectLib - Blind/stripe transition
- DissolveTransitionEffectLib - Random pixel dissolve
