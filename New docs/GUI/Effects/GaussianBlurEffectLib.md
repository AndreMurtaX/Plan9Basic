# GaussianBlurEffectLib

Applies a high-quality Gaussian blur effect to visual controls. Gaussian blur produces a smooth, natural-looking blur by weighting pixels according to a Gaussian (bell curve) distribution.

## Functions

| Function | Description |
|----------|-------------|
| `gaussblur#(parent#)` | Creates Gaussian blur effect on control |
| `gaussblur_free(effect#)` | Destroys the effect |
| `gaussblur_bluramount#(effect#, value)` | Sets blur intensity (0-10) |
| `gaussblur_bluramount(effect#)` | Gets blur amount |
| `gaussblur_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `gaussblur_enabled(effect#)` | Gets enabled state |
| `gaussblur_trigger#(effect#, trigger$)` | Sets trigger string |
| `gaussblur_trigger$(effect#)` | Gets trigger string |
| `gaussblur_error()` | Returns last error code |
| `gaussblur_errormsg$()` | Returns last error message |
| `gaussblur_strerror$(code)` | Converts error code to text |
| `gaussblur_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| BlurAmount | 0 - 10 | 0.1 | Blur intensity |

## Example 1: Basic Gaussian Blur

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blur# = Pointer#(0)

frm# = form#("Gaussian Blur Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Create Gaussian blur effect
blur# = gaussblur#(img#)
gaussblur_bluramount#(blur#, 3)

form_show(frm#)
```

## Example 2: Adjustable Blur Control

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blur# = Pointer#(0)
let trkBlur# = Pointer#(0)
let lblBlur# = Pointer#(0)

frm# = form#("Gaussian Blur Control", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

blur# = gaussblur#(img#)
gaussblur_bluramount#(blur#, 0)

' Blur amount slider (0-10 range)
lblBlur# = label#(frm#, "Blur: 0.0", 180, 200)
trkBlur# = trackbar#(frm#)
trackbar_bounds#(trkBlur#, 50, 230, 350, 30)
trackbar_max#(trkBlur#, 100)
trackbar_value#(trkBlur#, 0)
trackbar_onchange#(trkBlur#, "OnBlurChange")

form_show(frm#)

function OnBlurChange(sender#) local b
  let b = trackbar_value(trkBlur#) / 10
  gaussblur_bluramount#(blur#, b)
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

frm# = form#("Toggle Gaussian Blur", 400, 300)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

blur# = gaussblur#(img#)
gaussblur_bluramount#(blur#, 4)

btn# = button#(frm#, "Disable Effect")
button_bounds#(btn#, 140, 210, 120, 30)
button_onclick#(btn#, "Toggle")

form_show(frm#)

function Toggle(sender#)
  if isOn = 1 then
    gaussblur_enabled#(blur#, 0)
    isOn = 0
    button_text#(btn#, "Enable Effect")
  else
    gaussblur_enabled#(blur#, 1)
    isOn = 1
    button_text#(btn#, "Disable Effect")
  endif
endfunction
```

## Notes

- BlurAmount range is 0-10 (not 0-1)
- Values 1-3 create subtle softening
- Values 4-6 create medium blur
- Values 7-10 create heavy blur
- Higher quality than BoxBlur but slightly slower
- Produces smooth, natural-looking blur

## See Also

- BoxBlurEffectLib - Faster but lower quality blur
- DirectionalBlurEffectLib - Motion blur effect
- RadialBlurEffectLib - Radial/zoom blur effect
