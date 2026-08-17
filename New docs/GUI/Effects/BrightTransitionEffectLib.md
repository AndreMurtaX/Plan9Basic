# BrightTransitionEffectLib

A transition effect that transitions between images by increasing brightness to white, then revealing the target image as brightness decreases. Creates a "flash" or "white-out" transition effect.

## Functions

| Function | Description |
|----------|-------------|
| `brighttrans#(parent#)` | Creates bright transition effect on control |
| `brighttrans_free(effect#)` | Destroys the effect |
| `brighttrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `brighttrans_progress(effect#)` | Gets progress |
| `brighttrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `brighttrans_target#(effect#)` | Gets target bitmap |
| `brighttrans_loadtarget#(effect#, url$)` | Loads target from URL |
| `brighttrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `brighttrans_enabled(effect#)` | Gets enabled state |
| `brighttrans_error()` | Returns last error code |
| `brighttrans_errormsg$()` | Returns last error message |
| `brighttrans_strerror$(code)` | Converts error code to text |
| `brighttrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |

## Example 1: Basic Bright Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Bright Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create bright transition effect
trans# = brighttrans#(img#)
brighttrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  brighttrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Flash Transition Animation

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Flash Transition", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = brighttrans#(img#)
brighttrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

' Timer for animation
tmr# = timer#()
timer_interval#(tmr#, 25)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Flash!")
button_bounds#(btn#, 150, 210, 100, 30)
button_onclick#(btn#, "StartFlash")

form_show(frm#)

function StartFlash(sender#)
  progress = 0
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#)
  progress = progress + 0.03
  brighttrans_progress#(trans#, progress)
  
  if progress >= 1 then
    timer_enabled#(tmr#, 0)
    button_enabled#(btn#, 1)
  endif
endfunction
```

## Example 3: Bi-directional Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0
let direction = 1

frm# = form#("Bright Loop", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = brighttrans#(img#)
brighttrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  brighttrans_progress#(trans#, progress)
  
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

- At progress 0.5, the image is fully white (flash point)
- Creates a dramatic "camera flash" effect
- Faster animation creates a snappy flash effect
- Slower animation creates a gradual fade-through-white

## See Also

- FadeTransitionEffectLib - Fade to black transition
- BlurTransitionEffectLib - Blur-based transition
- DissolveTransitionEffectLib - Dissolve transition
