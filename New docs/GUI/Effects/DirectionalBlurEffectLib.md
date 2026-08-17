# DirectionalBlurEffectLib

Applies a directional (motion) blur effect to visual controls. The blur occurs along a specified angle, creating a sense of movement or speed.

## Functions

| Function | Description |
|----------|-------------|
| `dirblur#(parent#)` | Creates directional blur effect on control |
| `dirblur_free(effect#)` | Destroys the effect |
| `dirblur_bluramount#(effect#, value)` | Sets blur intensity (0-10) |
| `dirblur_bluramount(effect#)` | Gets blur amount |
| `dirblur_angle#(effect#, value)` | Sets blur direction in degrees (0-360) |
| `dirblur_angle(effect#)` | Gets angle |
| `dirblur_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `dirblur_enabled(effect#)` | Gets enabled state |
| `dirblur_trigger#(effect#, trigger$)` | Sets trigger string |
| `dirblur_trigger$(effect#)` | Gets trigger string |
| `dirblur_error()` | Returns last error code |
| `dirblur_errormsg$()` | Returns last error message |
| `dirblur_strerror$(code)` | Converts error code to text |
| `dirblur_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| BlurAmount | 0 - 10 | 0.1 | Blur intensity |
| Angle | 0 - 360 | 0 | Blur direction in degrees |

## Angle Reference

| Angle | Direction |
|-------|-----------|
| 0° | Right (horizontal) |
| 45° | Down-Right (diagonal) |
| 90° | Down (vertical) |
| 135° | Down-Left (diagonal) |
| 180° | Left (horizontal) |
| 270° | Up (vertical) |

## Example 1: Basic Directional Blur

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blur# = Pointer#(0)

frm# = form#("Directional Blur Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Create directional blur (horizontal motion)
blur# = dirblur#(img#)
dirblur_bluramount#(blur#, 3)
dirblur_angle#(blur#, 0)

form_show(frm#)
```

## Example 2: Adjustable Blur and Angle

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blur# = Pointer#(0)
let trkBlur# = Pointer#(0)
let trkAngle# = Pointer#(0)
let lblBlur# = Pointer#(0)
let lblAngle# = Pointer#(0)

frm# = form#("Motion Blur Control", 500, 420)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

blur# = dirblur#(img#)
dirblur_bluramount#(blur#, 2)
dirblur_angle#(blur#, 0)

' Blur amount slider (0-10)
lblBlur# = label#(frm#, "Blur: 2.0", 30, 190)
trkBlur# = trackbar#(frm#)
trackbar_bounds#(trkBlur#, 30, 215, 440, 25)
trackbar_max#(trkBlur#, 100)
trackbar_value#(trkBlur#, 20)
trackbar_onchange#(trkBlur#, "OnBlurChange")

' Angle slider (0-360)
lblAngle# = label#(frm#, "Angle: 0", 30, 260)
trkAngle# = trackbar#(frm#)
trackbar_bounds#(trkAngle#, 30, 285, 440, 25)
trackbar_max#(trkAngle#, 360)
trackbar_value#(trkAngle#, 0)
trackbar_onchange#(trkAngle#, "OnAngleChange")

form_show(frm#)

function OnBlurChange(sender#) local b
  let b = trackbar_value(trkBlur#) / 10
  dirblur_bluramount#(blur#, b)
  label_text#(lblBlur#, "Blur: " + stri$(b, 1))
endfunction

function OnAngleChange(sender#) local a
  let a = trackbar_value(trkAngle#)
  dirblur_angle#(blur#, a)
  label_text#(lblAngle#, "Angle: " + str$(a))
endfunction
```

## Example 3: Rotating Motion Blur Animation

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blur# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let lblAngle# = Pointer#(0)
let angle = 0
let running = 0

frm# = form#("Rotating Blur", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

blur# = dirblur#(img#)
dirblur_bluramount#(blur#, 4)
dirblur_angle#(blur#, 0)

lblAngle# = label#(frm#, "Angle: 0", 160, 195)

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Rotate")

btn# = button#(frm#, "Start Rotation")
button_bounds#(btn#, 140, 230, 120, 30)
button_onclick#(btn#, "ToggleRotation")

form_show(frm#)

function ToggleRotation(sender#)
  if running = 0 then
    running = 1
    timer_enabled#(tmr#, 1)
    button_text#(btn#, "Stop Rotation")
  else
    running = 0
    timer_enabled#(tmr#, 0)
    button_text#(btn#, "Start Rotation")
  endif
endfunction

function Rotate(sender#)
  angle = angle + 3
  if angle >= 360 then
    angle = angle - 360
  endif
  dirblur_angle#(blur#, angle)
  label_text#(lblAngle#, "Angle: " + str$(angle))
endfunction
```

## Notes

- BlurAmount range is 0-10 (not 0-1)
- Values 1-3 create subtle motion blur
- Values 4-7 create strong motion blur
- Angle rotates the blur direction
- Creates a sense of movement or speed
- Use images for visible results (blur needs pixel variation)

## See Also

- BoxBlurEffectLib - Simple box blur
- GaussianBlurEffectLib - Smooth Gaussian blur
- RadialBlurEffectLib - Radial/zoom blur effect
