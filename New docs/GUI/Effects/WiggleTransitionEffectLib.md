# WiggleTransitionEffectLib

A transition effect that creates a wiggle/jiggle distortion while transitioning between the source and target images. Creates a shaky, vibrating animation during the transition.

## Functions

| Function | Description |
|----------|-------------|
| `wiggletrans#(parent#)` | Creates wiggle transition on control |
| `wiggletrans_free(effect#)` | Destroys the effect |
| `wiggletrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `wiggletrans_progress(effect#)` | Gets progress |
| `wiggletrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `wiggletrans_target#(effect#)` | Gets target bitmap |
| `wiggletrans_loadtarget#(effect#, url$)` | Loads target from URL or file |
| `wiggletrans_randomseed#(effect#, value)` | Sets random seed for wiggle pattern |
| `wiggletrans_randomseed(effect#)` | Gets random seed |
| `wiggletrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `wiggletrans_enabled(effect#)` | Gets enabled state |
| `wiggletrans_error()` | Returns last error code |
| `wiggletrans_errormsg$()` | Returns last error message |
| `wiggletrans_strerror$(code)` | Converts error code to text |
| `wiggletrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |
| RandomSeed | 0.0+ | 0.0 | Random seed for wiggle pattern |

## Example 1: Basic Wiggle Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Wiggle Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create wiggle transition effect
trans# = wiggletrans#(img#)
wiggletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  wiggletrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Wiggle Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Animated Wiggle", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = wiggletrans#(img#)
wiggletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Wiggle!")
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
  wiggletrans_progress#(trans#, progress)
  
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

frm# = form#("Wiggle Pattern Variation", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = wiggletrans#(img#)
wiggletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
wiggletrans_progress#(trans#, 0.5)

' Random seed slider
lblSeed# = label#(frm#, "Random Seed: 0", 50, 200)
trkSeed# = trackbar#(frm#)
trackbar_bounds#(trkSeed#, 50, 230, 350, 30)
trackbar_max#(trkSeed#, 0.100)
trackbar_value#(trkSeed#, 0)
trackbar_onchange#(trkSeed#, "OnSeed")

form_show(frm#)

function OnSeed(sender#) local s
  let s = trackbar_value(trkSeed#)
  wiggletrans_randomseed#(trans#, s)
  label_text#(lblSeed#, "Random Seed: " + str$(s))
endfunction
```

## Notes

- Transition effects require a TARGET image to work properly
- At progress 0, source image is shown
- At progress 1, target image is shown
- RandomSeed changes the wiggle/jiggle pattern
- Creates a shaky, vibrating distortion during transition
- Good for playful or comedic transitions

## See Also

- RippleTransitionEffectLib - Ripple-based transition
- WaveTransitionEffectLib - Wave-based transition
- CrumpleTransitionEffectLib - Crumple transition
