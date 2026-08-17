# FadeTransitionEffectLib

A classic cross-fade transition effect that smoothly blends between the source and target images. The most common transition effect used in presentations and slideshows.

## Functions

| Function | Description |
|----------|-------------|
| `fadetrans#(parent#)` | Creates fade transition effect on control |
| `fadetrans_free(effect#)` | Destroys the effect |
| `fadetrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `fadetrans_progress(effect#)` | Gets progress |
| `fadetrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `fadetrans_target#(effect#)` | Gets target bitmap |
| `fadetrans_loadtarget#(effect#, url$)` | Loads target from URL or file |
| `fadetrans_targetfromimage#(effect#, image#)` | Copies target from TImage control |
| `fadetrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `fadetrans_enabled(effect#)` | Gets enabled state |
| `fadetrans_trigger#(effect#, trigger$)` | Sets trigger expression |
| `fadetrans_trigger$(effect#)` | Gets trigger expression |
| `fadetrans_error()` | Returns last error code |
| `fadetrans_errormsg$()` | Returns last error message |
| `fadetrans_strerror$(code)` | Converts error code to text |
| `fadetrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |

## Example 1: Basic Fade Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Fade Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create fade transition effect
trans# = fadetrans#(img#)
fadetrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  fadetrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Cross-Fade

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Animated Fade", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = fadetrans#(img#)
fadetrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Fade")
button_bounds#(btn#, 150, 210, 100, 30)
button_onclick#(btn#, "StartFade")

form_show(frm#)

function StartFade(sender#)
  progress = 0
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#)
  progress = progress + 0.02
  fadetrans_progress#(trans#, progress)
  
  if progress >= 1 then
    timer_enabled#(tmr#, 0)
    button_enabled#(btn#, 1)
  endif
endfunction
```

## Example 3: Bi-directional Fade Loop

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0
let direction = 1

frm# = form#("Fade Loop", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = fadetrans#(img#)
fadetrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Start Loop")
button_bounds#(btn#, 140, 210, 120, 30)
button_onclick#(btn#, "StartLoop")

form_show(frm#)

function StartLoop(sender#)
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#)
  progress = progress + (direction * 0.02)
  fadetrans_progress#(trans#, progress)
  
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

- The most common and natural-looking transition effect
- Progress 0 = 100% source image
- Progress 1 = 100% target image
- Progress 0.5 = 50% blend of both images
- Requires a TARGET image to transition to

## See Also

- DissolveTransitionEffectLib - Random pixel dissolve
- BlurTransitionEffectLib - Blur-based transition
- BrightTransitionEffectLib - Brightness flash transition
