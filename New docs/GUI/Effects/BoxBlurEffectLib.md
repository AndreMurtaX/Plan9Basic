# BoxBlurEffectLib

Applies a box blur effect to visual controls. Box blur averages pixels in a square region, creating a simple and fast blur effect. Less smooth than Gaussian blur but computationally faster.

## Functions

| Function | Description |
|----------|-------------|
| `boxblur#(parent#)` | Creates box blur effect on control |
| `boxblur_free(effect#)` | Destroys the effect |
| `boxblur_bluramount#(effect#, value)` | Sets blur amount (0-10) |
| `boxblur_bluramount(effect#)` | Gets blur amount |
| `boxblur_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `boxblur_enabled(effect#)` | Gets enabled state |
| `boxblur_trigger#(effect#, trigger$)` | Sets trigger string |
| `boxblur_trigger$(effect#)` | Gets trigger string |
| `boxblur_error()` | Returns last error code |
| `boxblur_errormsg$()` | Returns last error message |
| `boxblur_strerror$(code)` | Converts error code to text |
| `boxblur_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| BlurAmount | 0 - 10 | 0.1 | Intensity of the blur effect |

## Example 1: Basic Box Blur

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blur# = Pointer#(0)

frm# = form#("Box Blur Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Create box blur effect with visible amount
blur# = boxblur#(img#)
boxblur_bluramount#(blur#, 3)

form_show(frm#)
```

## Example 2: Adjustable Blur Control

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blur# = Pointer#(0)
let trkBlur# = Pointer#(0)
let lblBlur# = Pointer#(0)

frm# = form#("Blur Control", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

blur# = boxblur#(img#)
boxblur_bluramount#(blur#, 0)

' Blur amount slider (0-10 range)
lblBlur# = label#(frm#, "Blur: 0", 180, 200)
trkBlur# = trackbar#(frm#)
trackbar_bounds#(trkBlur#, 50, 230, 350, 30)
trackbar_max#(trkBlur#, 100)
trackbar_value#(trkBlur#, 0)
trackbar_onchange#(trkBlur#, "OnBlurChange")

form_show(frm#)

function OnBlurChange(sender#) local b
  let b = trackbar_value(trkBlur#) / 10
  boxblur_bluramount#(blur#, b)
  label_text#(lblBlur#, "Blur: " + stri$(b, 1))
endfunction
```

## Example 3: Toggle Blur Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blur# = Pointer#(0)
let btn# = Pointer#(0)
let isOn = 1

frm# = form#("Toggle Box Blur", 400, 300)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

blur# = boxblur#(img#)
boxblur_bluramount#(blur#, 4)

btn# = button#(frm#, "Disable Effect")
button_bounds#(btn#, 140, 210, 120, 30)
button_onclick#(btn#, "Toggle")

form_show(frm#)

function Toggle(sender#)
  if isOn = 1 then
    boxblur_enabled#(blur#, 0)
    isOn = 0
    button_text#(btn#, "Enable Effect")
  else
    boxblur_enabled#(blur#, 1)
    isOn = 1
    button_text#(btn#, "Disable Effect")
  endif
endfunction
```

## Notes

- BlurAmount range is 0-10, not 0-1
- Values 1-3 create subtle blur
- Values 4-6 create medium blur
- Values 7-10 create heavy blur
- Box blur is faster than Gaussian blur but less smooth

## See Also

- BlurEffectLib - Standard blur effect
- GaussianBlurEffectLib - Smooth Gaussian blur
- DirectionalBlurEffectLib - Motion blur effect
