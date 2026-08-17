# DissolveTransitionEffectLib

A transition effect that dissolves the source image into the target image by randomly revealing pixels. Creates a classic film dissolve or "noise" transition effect.

## Functions

| Function | Description |
|----------|-------------|
| `dissolvetrans#(parent#)` | Creates dissolve transition effect on control |
| `dissolvetrans_free(effect#)` | Destroys the effect |
| `dissolvetrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `dissolvetrans_progress(effect#)` | Gets progress |
| `dissolvetrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `dissolvetrans_target#(effect#)` | Gets target bitmap |
| `dissolvetrans_loadtarget#(effect#, url$)` | Loads target from URL or file |
| `dissolvetrans_targetfromimage#(effect#, image#)` | Copies target from TImage control |
| `dissolvetrans_seed#(effect#, value)` | Sets random seed (0-1) |
| `dissolvetrans_seed(effect#)` | Gets random seed |
| `dissolvetrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `dissolvetrans_enabled(effect#)` | Gets enabled state |
| `dissolvetrans_trigger#(effect#, trigger$)` | Sets trigger expression |
| `dissolvetrans_trigger$(effect#)` | Gets trigger expression |
| `dissolvetrans_error()` | Returns last error code |
| `dissolvetrans_errormsg$()` | Returns last error message |
| `dissolvetrans_strerror$(code)` | Converts error code to text |
| `dissolvetrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |
| RandomSeed | 0.0 - 1.0 | 0.0 | Seed for dissolve pattern randomization |

## Example 1: Basic Dissolve Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Dissolve Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create dissolve transition effect
trans# = dissolvetrans#(img#)
dissolvetrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  dissolvetrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Dissolve

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Animated Dissolve", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = dissolvetrans#(img#)
dissolvetrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Dissolve!")
button_bounds#(btn#, 150, 210, 100, 30)
button_onclick#(btn#, "StartDissolve")

form_show(frm#)

function StartDissolve(sender#)
  progress = 0
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#)
  progress = progress + 0.02
  dissolvetrans_progress#(trans#, progress)
  
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

frm# = form#("Dissolve Patterns", 500, 420)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = dissolvetrans#(img#)
dissolvetrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
dissolvetrans_progress#(trans#, 0.5)

form_show(frm#)

function OnProgress(sender#) local p
  let p = trackbar_value(trkProg#) / 100
  dissolvetrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction

function OnSeed(sender#) local s
  let s = trackbar_value(trkSeed#) / 100
  dissolvetrans_seed#(trans#, s)
  label_text#(lblSeed#, "Random Seed: " + stri$(s, 2))
endfunction
```

## Notes

- Transition effects require a TARGET image to work properly
- Without a target, the effect dissolves to transparent
- RandomSeed changes the pattern of pixel reveal
- Different seeds produce different dissolve patterns
- Classic "film grain" style transition effect

## See Also

- FadeTransitionEffectLib - Simple fade transition
- CircleTransitionEffectLib - Circular wipe transition
- BlurTransitionEffectLib - Blur-based transition
