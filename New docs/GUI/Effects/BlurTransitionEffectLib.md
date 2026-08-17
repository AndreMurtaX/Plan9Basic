# BlurTransitionEffectLib

A transition effect that blurs the source image while transitioning to the target image. Creates a smooth, dreamy transition between two images.

## Functions

| Function | Description |
|----------|-------------|
| `blurtrans#(parent#)` | Creates blur transition effect on control |
| `blurtrans_free(effect#)` | Destroys the effect |
| `blurtrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `blurtrans_progress(effect#)` | Gets progress |
| `blurtrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `blurtrans_target#(effect#)` | Gets target bitmap |
| `blurtrans_loadtarget#(effect#, url$)` | Loads target from URL |
| `blurtrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `blurtrans_enabled(effect#)` | Gets enabled state |
| `blurtrans_error()` | Returns last error code |
| `blurtrans_errormsg$()` | Returns last error message |
| `blurtrans_strerror$(code)` | Converts error code to text |
| `blurtrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |

## Example 1: Basic Blur Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Blur Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create blur transition effect
trans# = blurtrans#(img#)
blurtrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  blurtrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Blur Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0
let direction = 1

frm# = form#("Animated Blur", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = blurtrans#(img#)
blurtrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

' Timer for animation
tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Start Transition")
button_bounds#(btn#, 130, 210, 140, 30)
button_onclick#(btn#, "StartAnim")

form_show(frm#)

function StartAnim(sender#)
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#)
  progress = progress + (direction * 0.02)
  blurtrans_progress#(trans#, progress)
  
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

## Example 3: Toggle Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let btn# = Pointer#(0)
let isOn = 1

frm# = form#("Toggle Blur Trans", 400, 300)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = blurtrans#(img#)
blurtrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
blurtrans_progress#(trans#, 0.5)

btn# = button#(frm#, "Disable Effect")
button_bounds#(btn#, 140, 210, 120, 30)
button_onclick#(btn#, "Toggle")

form_show(frm#)

function Toggle(sender#)
  if isOn = 1 then
    blurtrans_enabled#(trans#, 0)
    isOn = 0
    button_text#(btn#, "Enable Effect")
  else
    blurtrans_enabled#(trans#, 1)
    isOn = 1
    button_text#(btn#, "Disable Effect")
  endif
endfunction
```

## Notes

- The transition blurs during the midpoint and sharpens at both ends
- Creates a soft, professional-looking transition
- Useful for photo slideshows and presentations

## See Also

- FadeTransitionEffectLib - Simple fade transition
- DissolveTransitionEffectLib - Dissolve transition
- BrightTransitionEffectLib - Brightness-based transition
