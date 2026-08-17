# SwirlEffectLib

Creates a swirl/twist distortion effect around a center point. Rotates pixels in a spiral pattern, with the rotation amount decreasing toward the edges.

## Functions

| Function | Description |
|----------|-------------|
| `swirl#(parent#)` | Creates swirl effect on control |
| `swirl_free(effect#)` | Destroys the effect |
| `swirl_strength#(effect#, value)` | Sets swirl intensity |
| `swirl_strength(effect#)` | Gets strength |
| `swirl_centerx#(effect#, value)` | Sets X center (0-1) |
| `swirl_centerx(effect#)` | Gets X center |
| `swirl_centery#(effect#, value)` | Sets Y center (0-1) |
| `swirl_centery(effect#)` | Gets Y center |
| `swirl_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `swirl_enabled(effect#)` | Gets enabled state |
| `swirl_trigger#(effect#, trigger$)` | Sets trigger string |
| `swirl_trigger$(effect#)` | Gets trigger string |
| `swirl_error()` | Returns last error code |
| `swirl_errormsg$()` | Returns last error message |
| `swirl_strerror$(code)` | Converts error code to text |
| `swirl_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Strength | -∞ to +∞ | 0.5 | Swirl intensity (positive=clockwise) |
| CenterX | 0.0 - 1.0 | 0.5 | Horizontal center position |
| CenterY | 0.0 - 1.0 | 0.5 | Vertical center position |

## Example 1: Basic Swirl Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let swirl# = Pointer#(0)

frm# = form#("Swirl Effect Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Apply swirl effect
swirl# = swirl#(img#)
swirl_strength#(swirl#, 1)

form_show(frm#)
```

## Example 2: Adjustable Swirl

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let swirl# = Pointer#(0)
let trkStr# = Pointer#(0)
let lblStr# = Pointer#(0)

frm# = form#("Swirl Control", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

swirl# = swirl#(img#)
swirl_strength#(swirl#, 0)

' Strength slider (-3 to +3)
lblStr# = label#(frm#, "Strength: 0.0", 180, 200)
trkStr# = trackbar#(frm#)
trackbar_bounds#(trkStr#, 50, 230, 350, 30)
trackbar_max#(trkStr#, 60)
trackbar_value#(trkStr#, 30)
trackbar_onchange#(trkStr#, "OnStrength")

form_show(frm#)

function OnStrength(sender#) local s
  let s = (trackbar_value(trkStr#) - 30) / 10
  swirl_strength#(swirl#, s)
  label_text#(lblStr#, "Strength: " + stri$(s, 1))
endfunction
```

## Example 3: Animated Swirl

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let swirl# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let strength = 0
let running = 0

frm# = form#("Animated Swirl", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

swirl# = swirl#(img#)
swirl_strength#(swirl#, 0)

tmr# = timer#()
timer_interval#(tmr#, 50)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Start Swirl")
button_bounds#(btn#, 140, 210, 120, 30)
button_onclick#(btn#, "ToggleAnimation")

form_show(frm#)

function ToggleAnimation(sender#)
  if running = 0 then
    running = 1
    timer_enabled#(tmr#, 1)
    button_text#(btn#, "Stop Swirl")
  else
    running = 0
    timer_enabled#(tmr#, 0)
    button_text#(btn#, "Start Swirl")
  endif
endfunction

function Animate(sender#)
  strength = strength + 0.05
  swirl_strength#(swirl#, sin(strength) * 2)
endfunction
```

## Notes

- Positive strength = clockwise rotation
- Negative strength = counter-clockwise rotation
- Center values are normalized (0-1)
- Larger strength values create more dramatic swirls
- Great for artistic/psychedelic effects
- Animate strength for hypnotic effects

## See Also

- RippleEffectLib - Water ripple distortion
- PinchEffectLib - Pinch/bulge distortion
- WaveEffectLib - Wave distortion
