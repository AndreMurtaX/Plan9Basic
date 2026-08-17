# MagnifyTransitionEffectLib

A transition effect that zooms in on a point while transitioning between two images. Creates a dramatic magnification-based reveal effect.

## Functions

| Function | Description |
|----------|-------------|
| `magnifytrans#(parent#)` | Creates magnify transition effect on control |
| `magnifytrans_free(effect#)` | Destroys the effect |
| `magnifytrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `magnifytrans_progress(effect#)` | Gets progress |
| `magnifytrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `magnifytrans_target#(effect#)` | Gets target bitmap |
| `magnifytrans_loadtarget#(effect#, url$)` | Loads target from URL or file |
| `magnifytrans_centerx#(effect#, value)` | Sets X center (0-1) |
| `magnifytrans_centerx(effect#)` | Gets X center |
| `magnifytrans_centery#(effect#, value)` | Sets Y center (0-1) |
| `magnifytrans_centery(effect#)` | Gets Y center |
| `magnifytrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `magnifytrans_enabled(effect#)` | Gets enabled state |
| `magnifytrans_error()` | Returns last error code |
| `magnifytrans_errormsg$()` | Returns last error message |
| `magnifytrans_strerror$(code)` | Converts error code to text |
| `magnifytrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |
| CenterX | 0.0 - 1.0 | 0.5 | Horizontal center of zoom |
| CenterY | 0.0 - 1.0 | 0.5 | Vertical center of zoom |

## Example 1: Basic Magnify Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Magnify Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create magnify transition effect
trans# = magnifytrans#(img#)
magnifytrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  magnifytrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Zoom Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Animated Zoom", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = magnifytrans#(img#)
magnifytrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Zoom!")
button_bounds#(btn#, 150, 210, 100, 30)
button_onclick#(btn#, "StartZoom")

form_show(frm#)

function StartZoom(sender#)
  progress = 0
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#)
  progress = progress + 0.02
  magnifytrans_progress#(trans#, progress)
  
  if progress >= 1 then
    timer_enabled#(tmr#, 0)
    button_enabled#(btn#, 1)
  endif
endfunction
```

## Example 3: Different Zoom Centers

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let trkX# = Pointer#(0)
let trkY# = Pointer#(0)
let lblProg# = Pointer#(0)
let lblX# = Pointer#(0)
let lblY# = Pointer#(0)

frm# = form#("Zoom Center Control", 500, 500)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = magnifytrans#(img#)
magnifytrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

' Progress control
lblProg# = label#(frm#, "Progress: 0.50", 30, 190)
trkProg# = trackbar#(frm#)
trackbar_bounds#(trkProg#, 30, 215, 440, 25)
trackbar_max#(trkProg#, 100)
trackbar_value#(trkProg#, 50)
trackbar_onchange#(trkProg#, "OnProgress")

' X center control
lblX# = label#(frm#, "Center X: 0.50", 30, 260)
trkX# = trackbar#(frm#)
trackbar_bounds#(trkX#, 30, 285, 440, 25)
trackbar_max#(trkX#, 100)
trackbar_value#(trkX#, 50)
trackbar_onchange#(trkX#, "OnCenterX")

' Y center control
lblY# = label#(frm#, "Center Y: 0.50", 30, 330)
trkY# = trackbar#(frm#)
trackbar_bounds#(trkY#, 30, 355, 440, 25)
trackbar_max#(trkY#, 100)
trackbar_value#(trkY#, 50)
trackbar_onchange#(trkY#, "OnCenterY")

' Set initial progress
magnifytrans_progress#(trans#, 0.5)

form_show(frm#)

function OnProgress(sender#) local p
  let p = trackbar_value(trkProg#) / 100
  magnifytrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction

function OnCenterX(sender#) local x
  let x = trackbar_value(trkX#) / 100
  magnifytrans_centerx#(trans#, x)
  label_text#(lblX#, "Center X: " + stri$(x, 2))
endfunction

function OnCenterY(sender#) local y
  let y = trackbar_value(trkY#) / 100
  magnifytrans_centery#(trans#, y)
  label_text#(lblY#, "Center Y: " + stri$(y, 2))
endfunction
```

## Notes

- Transition effects require a TARGET image to work properly
- Center values are normalized (0-1), not pixel coordinates
- Creates a dramatic "zoom into" transition effect
- Useful for dramatic reveals or focus effects

## See Also

- MagnifyEffectLib - Static magnify effect
- CircleTransitionEffectLib - Circular wipe transition
- BlurTransitionEffectLib - Blur-based transition
