# BloomEffectLib

Creates a bloom (glow/halo) effect on bright areas of visual controls. Simulates camera overexposure or light bleeding. Works best on images and controls with varying colors.

## Functions

| Function | Description |
|----------|-------------|
| `bloom#(parent#)` | Creates bloom effect on control |
| `bloom_free(effect#)` | Destroys the effect |
| `bloom_bloomintensity#(effect#, value)` | Sets bloom glow intensity (0-1) |
| `bloom_bloomintensity(effect#)` | Gets bloom intensity |
| `bloom_baseintensity#(effect#, value)` | Sets base image intensity (0-1) |
| `bloom_baseintensity(effect#)` | Gets base intensity |
| `bloom_bloomsaturation#(effect#, value)` | Sets bloom color saturation (0-1) |
| `bloom_bloomsaturation(effect#)` | Gets bloom saturation |
| `bloom_basesaturation#(effect#, value)` | Sets base color saturation (0-1) |
| `bloom_basesaturation(effect#)` | Gets base saturation |
| `bloom_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `bloom_enabled(effect#)` | Gets enabled state |
| `bloom_trigger#(effect#, trigger$)` | Sets trigger string |
| `bloom_trigger$(effect#)` | Gets trigger string |
| `bloom_error()` | Returns last error code |
| `bloom_errormsg$()` | Returns last error message |
| `bloom_strerror$(code)` | Converts error code to text |
| `bloom_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| BloomIntensity | 0 - 1 | 0.5 | Glow effect strength |
| BaseIntensity | 0 - 1 | 1.0 | Original image strength |
| BloomSaturation | 0 - 1 | 1.0 | Glow color saturation |
| BaseSaturation | 0 - 1 | 1.0 | Original color saturation |

## Example 1: Basic Bloom on Image

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blm# = Pointer#(0)

frm# = form#("Bloom Demo", 400, 320)

img# = image#(frm#)
image_bounds#(img#, 100, 40, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

blm# = bloom#(img#)
bloom_bloomintensity#(blm#, 0.6)

form_show(frm#)
```

## Example 2: Bloom Intensity Control

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blm# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Bloom Control", 450, 380)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

blm# = bloom#(img#)
bloom_bloomintensity#(blm#, 0)

lbl# = label#(frm#, "Bloom: Off", 180, 200)

let btn1# = button#(frm#, "Off")
button_bounds#(btn1#, 50, 240, 80, 30)
button_onclick#(btn1#, "SetOff")

let btn2# = button#(frm#, "Low")
button_bounds#(btn2#, 140, 240, 80, 30)
button_onclick#(btn2#, "SetLow")

let btn3# = button#(frm#, "Medium")
button_bounds#(btn3#, 230, 240, 80, 30)
button_onclick#(btn3#, "SetMedium")

let btn4# = button#(frm#, "High")
button_bounds#(btn4#, 320, 240, 80, 30)
button_onclick#(btn4#, "SetHigh")

form_show(frm#)

function SetOff(sender#)
  bloom_bloomintensity#(blm#, 0)
  label_text#(lbl#, "Bloom: Off")
endfunction

function SetLow(sender#)
  bloom_bloomintensity#(blm#, 0.3)
  label_text#(lbl#, "Bloom: 30%")
endfunction

function SetMedium(sender#)
  bloom_bloomintensity#(blm#, 0.5)
  label_text#(lbl#, "Bloom: 50%")
endfunction

function SetHigh(sender#)
  bloom_bloomintensity#(blm#, 0.8)
  label_text#(lbl#, "Bloom: 80%")
endfunction
```

## Example 3: Saturation Effects

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blm# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Saturation Control", 450, 380)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

blm# = bloom#(img#)
bloom_bloomintensity#(blm#, 0.6)
bloom_bloomsaturation#(blm#, 1.0)

lbl# = label#(frm#, "Saturation: 100%", 155, 200)

let btn1# = button#(frm#, "0%")
button_bounds#(btn1#, 80, 240, 80, 30)
button_onclick#(btn1#, "SetSat0")

let btn2# = button#(frm#, "50%")
button_bounds#(btn2#, 180, 240, 80, 30)
button_onclick#(btn2#, "SetSat50")

let btn3# = button#(frm#, "100%")
button_bounds#(btn3#, 280, 240, 80, 30)
button_onclick#(btn3#, "SetSat100")

form_show(frm#)

function SetSat0(sender#)
  bloom_bloomsaturation#(blm#, 0)
  label_text#(lbl#, "Saturation: 0% (White glow)")
endfunction

function SetSat50(sender#)
  bloom_bloomsaturation#(blm#, 0.5)
  label_text#(lbl#, "Saturation: 50%")
endfunction

function SetSat100(sender#)
  bloom_bloomsaturation#(blm#, 1.0)
  label_text#(lbl#, "Saturation: 100% (Full color)")
endfunction
```

## Notes

- Works best on images with varying colors and bright areas
- Solid color shapes won't show visible effect
- Use BloomSaturation = 0 for white glow
- Use BloomSaturation = 1 for colored glow

## See Also

- GloomEffectLib - Opposite effect (darkening)
- GlowEffectLib - Outer glow effects
