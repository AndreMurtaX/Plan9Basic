# SmoothMagnifyEffectLib

Creates a smooth magnifying glass effect with adjustable inner and outer radii for a gradual transition between magnified and normal areas. More refined than basic magnification with smoother edges.

## Important: Understanding the Properties

All values use **normalized coordinates** (0-1 relative to image size):

- **Center (X, Y)**: Position of magnifier center (0.5, 0.5 = image center)
- **InnerRadius**: Radius of full magnification zone
- **OuterRadius**: Radius where magnification fades to normal
- **Magnification**: Zoom level (1 = no zoom)

OuterRadius must be larger than InnerRadius for the effect to work properly.

## Functions

| Function | Description |
|----------|-------------|
| `smag#(parent#)` | Creates smooth magnify effect on control |
| `smag_free(effect#)` | Destroys the effect |
| `smag_centerx#(effect#, value)` | Sets X center (0-1) |
| `smag_centerx(effect#)` | Gets X center |
| `smag_centery#(effect#, value)` | Sets Y center (0-1) |
| `smag_centery(effect#)` | Gets Y center |
| `smag_mag#(effect#, value)` | Sets magnification level |
| `smag_mag(effect#)` | Gets magnification |
| `smag_inner#(effect#, value)` | Sets inner radius (full magnification zone) |
| `smag_inner(effect#)` | Gets inner radius |
| `smag_outer#(effect#, value)` | Sets outer radius (transition zone end) |
| `smag_outer(effect#)` | Gets outer radius |
| `smag_aspect#(effect#, value)` | Sets aspect ratio |
| `smag_aspect(effect#)` | Gets aspect ratio |
| `smag_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `smag_enabled(effect#)` | Gets enabled state |
| `smag_trigger#(effect#, trigger$)` | Sets trigger string |
| `smag_trigger$(effect#)` | Gets trigger string |
| `smag_error()` | Returns last error code |
| `smag_errormsg$()` | Returns last error message |
| `smag_strerror$(code)` | Converts error code to text |
| `smag_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| CenterX | 0.0 - 1.0 | 0.5 | Horizontal center position (normalized) |
| CenterY | 0.0 - 1.0 | 0.5 | Vertical center position (normalized) |
| Magnification | 1.0+ | 2.0 | Zoom level (1=none) |
| InnerRadius | 0.0 - 1.0 | 0.1 | Full magnification zone radius |
| OuterRadius | 0.0 - 1.0 | 0.2 | Transition zone outer edge |
| AspectRatio | 0.0+ | 1.0 | Shape aspect ratio |

## Inner vs Outer Radius

- **InnerRadius**: Area of full magnification (constant zoom)
- **OuterRadius**: Where magnification transitions back to normal
- The area between inner and outer has a smooth gradient transition
- **OuterRadius MUST be larger than InnerRadius**

## Example 1: Basic Smooth Magnify

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let eff# = Pointer#(0)

frm# = form#("Smooth Magnify Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Apply smooth magnification effect
eff# = smag#(img#)
smag_mag#(eff#, 3)
smag_inner#(eff#, 0.2)
smag_outer#(eff#, 0.5)

form_show(frm#)
```

## Example 2: Adjustable Magnification

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let eff# = Pointer#(0)
let trkMag# = Pointer#(0)
let trkInner# = Pointer#(0)
let trkOuter# = Pointer#(0)
let lblMag# = Pointer#(0)
let lblInner# = Pointer#(0)
let lblOuter# = Pointer#(0)

frm# = form#("Smooth Magnify Control", 500, 520)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

eff# = smag#(img#)
smag_mag#(eff#, 3)
smag_inner#(eff#, 0.2)
smag_outer#(eff#, 0.5)

' Magnification slider (1 to 10)
lblMag# = label#(frm#, "Magnification: 3.0", 30, 190)
trkMag# = trackbar#(frm#)
trackbar_bounds#(trkMag#, 30, 215, 440, 25)
trackbar_max#(trkMag#, 100)
trackbar_value#(trkMag#, 20)
trackbar_onchange#(trkMag#, "OnMagnification")

' Inner radius slider (0 to 1.0)
lblInner# = label#(frm#, "Inner Radius: 0.20", 30, 260)
trkInner# = trackbar#(frm#)
trackbar_bounds#(trkInner#, 30, 285, 440, 25)
trackbar_max#(trkInner#, 100)
trackbar_value#(trkInner#, 20)
trackbar_onchange#(trkInner#, "OnInner")

' Outer radius slider (0 to 1.0)
lblOuter# = label#(frm#, "Outer Radius: 0.50", 30, 330)
trkOuter# = trackbar#(frm#)
trackbar_bounds#(trkOuter#, 30, 355, 440, 25)
trackbar_max#(trkOuter#, 100)
trackbar_value#(trkOuter#, 50)
trackbar_onchange#(trkOuter#, "OnOuter")

form_show(frm#)

function OnMagnification(sender#) local m
  let m = 1 + trackbar_value(trkMag#) / 10
  smag_mag#(eff#, m)
  label_text#(lblMag#, "Magnification: " + stri$(m, 1))
endfunction

function OnInner(sender#) local i
  let i = trackbar_value(trkInner#) / 100
  smag_inner#(eff#, i)
  label_text#(lblInner#, "Inner Radius: " + stri$(i, 2))
endfunction

function OnOuter(sender#) local o
  let o = trackbar_value(trkOuter#) / 100
  smag_outer#(eff#, o)
  label_text#(lblOuter#, "Outer Radius: " + stri$(o, 2))
endfunction
```

## Notes

- All coordinates are **normalized** (0-1 relative to image dimensions)
- InnerRadius should be smaller than OuterRadius
- Smooth transition between inner (full zoom) and outer (no zoom)
- More refined edges than basic MagnifyEffectLib
- AspectRatio > 1 creates horizontal oval, < 1 creates vertical oval

## See Also

- MagnifyEffectLib - Basic magnification effect
- PinchEffectLib - Pinch/bulge distortion
- RippleEffectLib - Water ripple effect
