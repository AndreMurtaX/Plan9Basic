# GloomEffectLib

Creates a gloom (darkening) effect on visual controls. The opposite of bloom - reduces brightness and creates a moody atmosphere. Works best on images and controls with varying colors.

## Functions

| Function | Description |
|----------|-------------|
| `gloom#(parent#)` | Creates gloom effect on control |
| `gloom_free(effect#)` | Destroys the effect |
| `gloom_gloomintensity#(effect#, value)` | Sets darkening intensity (0-1) |
| `gloom_gloomintensity(effect#)` | Gets gloom intensity |
| `gloom_baseintensity#(effect#, value)` | Sets base image intensity (0-1) |
| `gloom_baseintensity(effect#)` | Gets base intensity |
| `gloom_gloomsaturation#(effect#, value)` | Sets gloom color saturation (0-1) |
| `gloom_gloomsaturation(effect#)` | Gets gloom saturation |
| `gloom_basesaturation#(effect#, value)` | Sets base color saturation (0-1) |
| `gloom_basesaturation(effect#)` | Gets base saturation |
| `gloom_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `gloom_enabled(effect#)` | Gets enabled state |
| `gloom_trigger#(effect#, trigger$)` | Sets trigger string |
| `gloom_trigger$(effect#)` | Gets trigger string |
| `gloom_error()` | Returns last error code |
| `gloom_errormsg$()` | Returns last error message |
| `gloom_strerror$(code)` | Converts error code to text |
| `gloom_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| GloomIntensity | 0 - 1 | 0.5 | Darkening effect strength |
| BaseIntensity | 0 - 1 | 1.0 | Original image strength |
| GloomSaturation | 0 - 1 | 1.0 | Gloom color saturation |
| BaseSaturation | 0 - 1 | 1.0 | Original color saturation |

## Example 1: Basic Gloom on Image

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let glm# = Pointer#(0)

frm# = form#("Gloom Demo", 400, 320)

img# = image#(frm#)
image_bounds#(img#, 100, 40, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

glm# = gloom#(img#)
gloom_gloomintensity#(glm#, 0.5)

form_show(frm#)
```

## Example 2: Gloom Intensity Control

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let glm# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Gloom Control", 450, 380)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

glm# = gloom#(img#)
gloom_gloomintensity#(glm#, 0)

lbl# = label#(frm#, "Gloom: Off", 175, 200)

let btn1# = button#(frm#, "Off")
button_bounds#(btn1#, 50, 240, 80, 30)
button_onclick#(btn1#, "SetOff")

let btn2# = button#(frm#, "Light")
button_bounds#(btn2#, 140, 240, 80, 30)
button_onclick#(btn2#, "SetLight")

let btn3# = button#(frm#, "Medium")
button_bounds#(btn3#, 230, 240, 80, 30)
button_onclick#(btn3#, "SetMedium")

let btn4# = button#(frm#, "Dark")
button_bounds#(btn4#, 320, 240, 80, 30)
button_onclick#(btn4#, "SetDark")

form_show(frm#)

function SetOff(sender#)
  gloom_gloomintensity#(glm#, 0)
  label_text#(lbl#, "Gloom: Off")
endfunction

function SetLight(sender#)
  gloom_gloomintensity#(glm#, 0.3)
  label_text#(lbl#, "Gloom: 30%")
endfunction

function SetMedium(sender#)
  gloom_gloomintensity#(glm#, 0.5)
  label_text#(lbl#, "Gloom: 50%")
endfunction

function SetDark(sender#)
  gloom_gloomintensity#(glm#, 0.8)
  label_text#(lbl#, "Gloom: 80%")
endfunction
```

## Example 3: Saturation Control

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let glm# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Saturation Control", 450, 380)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

glm# = gloom#(img#)
gloom_gloomintensity#(glm#, 0.4)
gloom_basesaturation#(glm#, 1.0)

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
  gloom_basesaturation#(glm#, 0)
  label_text#(lbl#, "Saturation: 0% (Grayscale)")
endfunction

function SetSat50(sender#)
  gloom_basesaturation#(glm#, 0.5)
  label_text#(lbl#, "Saturation: 50%")
endfunction

function SetSat100(sender#)
  gloom_basesaturation#(glm#, 1.0)
  label_text#(lbl#, "Saturation: 100%")
endfunction
```

## Notes

- Works best on images with varying colors and details
- Solid color shapes won't show visible effect
- Opposite of BloomEffectLib
- Use for moody, dark UI themes
- BaseSaturation = 0 creates grayscale effect

## See Also

- BloomEffectLib - Opposite effect (brightening)
- ContrastEffectLib - Contrast adjustment
