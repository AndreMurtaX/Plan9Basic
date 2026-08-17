# AffineTransformEffectLib

Applies affine transformations (rotation, scale) to visual controls. Works on images and shapes.

## Functions

| Function | Description |
|----------|-------------|
| `affine#(parent#)` | Creates affine transform effect on control |
| `affine_free(effect#)` | Destroys the effect |
| `affine_centerx#(effect#, value)` | Sets center X (0.0-1.0) |
| `affine_centerx(effect#)` | Gets center X |
| `affine_centery#(effect#, value)` | Sets center Y (0.0-1.0) |
| `affine_centery(effect#)` | Gets center Y |
| `affine_rotation#(effect#, degrees)` | Sets rotation in degrees |
| `affine_rotation(effect#)` | Gets rotation |
| `affine_scale#(effect#, value)` | Sets uniform scale factor |
| `affine_scale(effect#)` | Gets scale |
| `affine_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `affine_enabled(effect#)` | Gets enabled state |
| `affine_trigger#(effect#, trigger$)` | Sets trigger string |
| `affine_trigger$(effect#)` | Gets trigger string |
| `affine_error()` | Returns last error code |
| `affine_errormsg$()` | Returns last error message |
| `affine_strerror$(code)` | Converts error code to text |
| `affine_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| CenterX | 0.0 - 1.0 | 0.5 | Horizontal center of transformation |
| CenterY | 0.0 - 1.0 | 0.5 | Vertical center of transformation |
| Rotation | any | 0 | Rotation angle in degrees |
| Scale | any | 1.0 | Uniform scale factor |

## Example 1: Rotate an Image

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let aff# = Pointer#(0)

frm# = form#("Affine Transform Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Create affine transform effect
aff# = affine#(img#)
affine_rotation#(aff#, 15)   ' Rotate 15 degrees
affine_scale#(aff#, 0.9)     ' Scale down slightly

form_show(frm#)
```

## Example 2: Interactive Rotation Control

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let aff# = Pointer#(0)
let trkRot# = Pointer#(0)
let lblRot# = Pointer#(0)

frm# = form#("Rotation Control", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

aff# = affine#(img#)
affine_rotation#(aff#, 0)

' Rotation slider (-180 to 180)
lblRot# = label#(frm#, "Rotation: 0", 50, 200)
trkRot# = trackbar#(frm#)
trackbar_bounds#(trkRot#, 50, 230, 350, 30)
trackbar_max#(trkRot#, 360)
trackbar_value#(trkRot#, 180)
trackbar_onchange#(trkRot#, "OnRotChange")

form_show(frm#)

function OnRotChange(sender#) local deg
  let deg = trackbar_value(trkRot#) - 180
  affine_rotation#(aff#, deg)
  label_text#(lblRot#, "Rotation: " + str$(deg))
endfunction
```

## Example 3: Scale and Rotate Combined

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let aff# = Pointer#(0)
let trkScale# = Pointer#(0)
let lblScale# = Pointer#(0)

frm# = form#("Scale Control", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

aff# = affine#(img#)
affine_rotation#(aff#, 10)
affine_scale#(aff#, 1.0)

' Scale slider (0.5 to 2.0)
lblScale# = label#(frm#, "Scale: 1.00", 50, 200)
trkScale# = trackbar#(frm#)
trackbar_bounds#(trkScale#, 50, 230, 350, 30)
trackbar_max#(trkScale#, 150)
trackbar_value#(trkScale#, 50)
trackbar_onchange#(trkScale#, "OnScaleChange")

form_show(frm#)

function OnScaleChange(sender#) local s
  let s = 0.5 + (trackbar_value(trkScale#) / 100)
  affine_scale#(aff#, s)
  label_text#(lblScale#, "Scale: " + stri$(s, 2))
endfunction
```

## See Also

- PerspectiveTransformEffectLib - 3D perspective transforms
- MagnifyEffectLib - Magnifying glass effect
