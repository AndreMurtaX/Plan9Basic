# RadialBlurEffectLib

Applies a radial (zoom) blur effect emanating from a center point. Creates a motion blur effect as if zooming in or out, commonly used for speed or focus effects.

## Functions

| Function | Description |
|----------|-------------|
| `radblur#(parent#)` | Creates radial blur effect on control |
| `radblur_free(effect#)` | Destroys the effect |
| `radblur_bluramount#(effect#, value)` | Sets blur intensity (0-10) |
| `radblur_bluramount(effect#)` | Gets blur amount |
| `radblur_centerx#(effect#, value)` | Sets X center (0-1) |
| `radblur_centerx(effect#)` | Gets X center |
| `radblur_centery#(effect#, value)` | Sets Y center (0-1) |
| `radblur_centery(effect#)` | Gets Y center |
| `radblur_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `radblur_enabled(effect#)` | Gets enabled state |
| `radblur_trigger#(effect#, trigger$)` | Sets trigger string |
| `radblur_trigger$(effect#)` | Gets trigger string |
| `radblur_error()` | Returns last error code |
| `radblur_errormsg$()` | Returns last error message |
| `radblur_strerror$(code)` | Converts error code to text |
| `radblur_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| BlurAmount | 0 - 10 | 0.1 | Blur intensity |
| CenterX | 0.0 - 1.0 | 0.5 | Horizontal center position |
| CenterY | 0.0 - 1.0 | 0.5 | Vertical center position |

## Example 1: Basic Radial Blur

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blur# = Pointer#(0)

frm# = form#("Radial Blur Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Apply radial (zoom) blur
blur# = radblur#(img#)
radblur_bluramount#(blur#, 2)

form_show(frm#)
```

## Example 2: Adjustable Radial Blur

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blur# = Pointer#(0)
let trkBlur# = Pointer#(0)
let lblBlur# = Pointer#(0)

frm# = form#("Radial Blur Control", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

blur# = radblur#(img#)
radblur_bluramount#(blur#, 0)

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
  radblur_bluramount#(blur#, b)
  label_text#(lblBlur#, "Blur: " + stri$(b, 1))
endfunction
```

## Example 3: Move Blur Center

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let blur# = Pointer#(0)
let trkX# = Pointer#(0)
let trkY# = Pointer#(0)
let lblX# = Pointer#(0)
let lblY# = Pointer#(0)

frm# = form#("Radial Blur Center", 500, 470)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

blur# = radblur#(img#)
radblur_bluramount#(blur#, 3)

' X center slider
lblX# = label#(frm#, "Center X: 0.50", 30, 190)
trkX# = trackbar#(frm#)
trackbar_bounds#(trkX#, 30, 215, 440, 25)
trackbar_max#(trkX#, 100)
trackbar_value#(trkX#, 50)
trackbar_onchange#(trkX#, "OnCenterX")

' Y center slider
lblY# = label#(frm#, "Center Y: 0.50", 30, 260)
trkY# = trackbar#(frm#)
trackbar_bounds#(trkY#, 30, 285, 440, 25)
trackbar_max#(trkY#, 100)
trackbar_value#(trkY#, 50)
trackbar_onchange#(trkY#, "OnCenterY")

form_show(frm#)

function OnCenterX(sender#) local x
  let x = trackbar_value(trkX#) / 100
  radblur_centerx#(blur#, x)
  label_text#(lblX#, "Center X: " + stri$(x, 2))
endfunction

function OnCenterY(sender#) local y
  let y = trackbar_value(trkY#) / 100
  radblur_centery#(blur#, y)
  label_text#(lblY#, "Center Y: " + stri$(y, 2))
endfunction
```

## Notes

- BlurAmount range is 0-10 (not 0-1)
- Values 1-3 create subtle zoom blur
- Values 4-7 create medium intensity
- Values 8-10 create strong zoom effect
- Center values are normalized (0-1)
- Creates a "zooming in/out" motion blur effect
- Great for speed or focus effects

## See Also

- DirectionalBlurEffectLib - Linear motion blur
- GaussianBlurEffectLib - Smooth general blur
- BoxBlurEffectLib - Fast box blur
