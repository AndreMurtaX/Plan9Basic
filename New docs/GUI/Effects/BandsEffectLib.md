# BandsEffectLib

Creates a visual effect that adds horizontal bands/stripes over the image, similar to scan lines or CRT monitor effects.

## Functions

| Function | Description |
|----------|-------------|
| `bands#(parent#)` | Creates bands effect on control |
| `bands_free(effect#)` | Destroys the effect |
| `bands_density#(effect#, value)` | Sets band density (lines count) |
| `bands_density(effect#)` | Gets density |
| `bands_intensity#(effect#, value)` | Sets band intensity (0.0-1.0) |
| `bands_intensity(effect#)` | Gets intensity |
| `bands_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `bands_enabled(effect#)` | Gets enabled state |
| `bands_trigger#(effect#, trigger$)` | Sets trigger string |
| `bands_trigger$(effect#)` | Gets trigger string |
| `bands_error()` | Returns last error code |
| `bands_errormsg$()` | Returns last error message |
| `bands_strerror$(code)` | Converts error code to text |
| `bands_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Density | 0+ | 50 | Number of horizontal bands |
| Intensity | 0.0 - 1.0 | 0.5 | Visibility of bands (0=invisible, 1=solid) |

## Example 1: CRT Scanline Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let bnd# = Pointer#(0)

frm# = form#("Scanline Effect", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Create bands effect - CRT style
bnd# = bands#(img#)
bands_density#(bnd#, 75)
bands_intensity#(bnd#, 0.3)

form_show(frm#)
```

## Example 2: Interactive Controls

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let bnd# = Pointer#(0)
let trkDens# = Pointer#(0)
let trkInt# = Pointer#(0)
let lblDens# = Pointer#(0)
let lblInt# = Pointer#(0)

frm# = form#("Bands Control", 450, 420)

img# = image#(frm#)
image_bounds#(img#, 125, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

bnd# = bands#(img#)
bands_density#(bnd#, 50)
bands_intensity#(bnd#, 0.5)

' Density slider
lblDens# = label#(frm#, "Density: 50", 50, 190)
trkDens# = trackbar#(frm#)
trackbar_bounds#(trkDens#, 50, 220, 350, 30)
trackbar_max#(trkDens#, 200)
trackbar_value#(trkDens#, 50)
trackbar_onchange#(trkDens#, "OnDensChange")

' Intensity slider
lblInt# = label#(frm#, "Intensity: 0.50", 50, 270)
trkInt# = trackbar#(frm#)
trackbar_bounds#(trkInt#, 50, 300, 350, 30)
trackbar_max#(trkInt#, 100)
trackbar_value#(trkInt#, 50)
trackbar_onchange#(trkInt#, "OnIntChange")

form_show(frm#)

function OnDensChange(sender#) local d
  let d = trackbar_value(trkDens#)
  bands_density#(bnd#, d)
  label_text#(lblDens#, "Density: " + str$(d))
endfunction

function OnIntChange(sender#) local i
  let i = trackbar_value(trkInt#) / 100
  bands_intensity#(bnd#, i)
  label_text#(lblInt#, "Intensity: " + stri$(i, 2))
endfunction
```

## Example 3: Toggle Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let bnd# = Pointer#(0)
let btn# = Pointer#(0)
let isOn = 1

frm# = form#("Toggle Bands", 400, 300)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

bnd# = bands#(img#)
bands_density#(bnd#, 100)
bands_intensity#(bnd#, 0.4)

btn# = button#(frm#, "Disable Effect")
button_bounds#(btn#, 140, 210, 120, 30)
button_onclick#(btn#, "Toggle")

form_show(frm#)

function Toggle(sender#)
  if isOn = 1 then
    bands_enabled#(bnd#, 0)
    isOn = 0
    button_text#(btn#, "Enable Effect")
  else
    bands_enabled#(bnd#, 1)
    isOn = 1
    button_text#(btn#, "Disable Effect")
  endif
endfunction
```

## Notes

- Higher density creates finer, closer scan lines
- Lower intensity makes bands more subtle/transparent
- Useful for retro/vintage visual effects

## See Also

- PixelateEffectLib - Pixelation effect
- SepiaEffectLib - Sepia tone effect
- MonochromeEffectLib - Monochrome effect
