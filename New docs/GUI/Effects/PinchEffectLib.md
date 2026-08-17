# PinchEffectLib

Creates a pinch or bulge distortion effect at a specified location. Positive strength creates a pinch (inward distortion), negative strength creates a bulge (outward distortion).

## Functions

| Function | Description |
|----------|-------------|
| `pinch#(parent#)` | Creates pinch effect on control |
| `pinch_free(effect#)` | Destroys the effect |
| `pinch_centerx#(effect#, value)` | Sets X center (0-1) |
| `pinch_centerx(effect#)` | Gets X center |
| `pinch_centery#(effect#, value)` | Sets Y center (0-1) |
| `pinch_centery(effect#)` | Gets Y center |
| `pinch_radius#(effect#, value)` | Sets effect radius |
| `pinch_radius(effect#)` | Gets radius |
| `pinch_strength#(effect#, value)` | Sets pinch/bulge strength |
| `pinch_strength(effect#)` | Gets strength |
| `pinch_aspect#(effect#, value)` | Sets aspect ratio |
| `pinch_aspect(effect#)` | Gets aspect ratio |
| `pinch_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `pinch_enabled(effect#)` | Gets enabled state |
| `pinch_trigger#(effect#, trigger$)` | Sets trigger string |
| `pinch_trigger$(effect#)` | Gets trigger string |
| `pinch_error()` | Returns last error code |
| `pinch_errormsg$()` | Returns last error message |
| `pinch_strerror$(code)` | Converts error code to text |
| `pinch_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| CenterX | 0.0 - 1.0 | 0.5 | Horizontal center position |
| CenterY | 0.0 - 1.0 | 0.5 | Vertical center position |
| Radius | 0.0+ | 50 | Effect radius in pixels |
| Strength | -1.0 to 1.0 | 0.5 | Positive=pinch, negative=bulge |
| AspectRatio | 0.0+ | 1.0 | Width/height ratio of effect |

## Example 1: Basic Pinch Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let pinch# = Pointer#(0)

frm# = form#("Pinch Effect Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Apply pinch effect (inward distortion)
pinch# = pinch#(img#)
pinch_strength#(pinch#, 0.5)
pinch_radius#(pinch#, 50)

form_show(frm#)
```

## Example 2: Pinch vs Bulge Comparison

```basic
let frm# = Pointer#(0)
let img1# = Pointer#(0)
let img2# = Pointer#(0)
let img3# = Pointer#(0)
let p1# = Pointer#(0)
let p2# = Pointer#(0)

frm# = form#("Pinch vs Bulge", 550, 300)

' Original (no effect)
img1# = image#(frm#)
image_bounds#(img1#, 30, 50, 150, 112)
image_load#(img1#, "https://picsum.photos/150/112")
let lbl1# = label#(frm#, "Original", 75, 170)

' Pinch (positive strength)
img2# = image#(frm#)
image_bounds#(img2#, 200, 50, 150, 112)
image_load#(img2#, "https://picsum.photos/150/112")
p1# = pinch#(img2#)
pinch_strength#(p1#, 0.6)
pinch_radius#(p1#, 40)
let lbl2# = label#(frm#, "Pinch (+0.6)", 235, 170)

' Bulge (negative strength)
img3# = image#(frm#)
image_bounds#(img3#, 370, 50, 150, 112)
image_load#(img3#, "https://picsum.photos/150/112")
p2# = pinch#(img3#)
pinch_strength#(p2#, -0.6)
pinch_radius#(p2#, 40)
let lbl3# = label#(frm#, "Bulge (-0.6)", 405, 170)

form_show(frm#)
```

## Example 3: Interactive Pinch Control

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let pinch# = Pointer#(0)
let trkStr# = Pointer#(0)
let trkRad# = Pointer#(0)
let lblStr# = Pointer#(0)
let lblRad# = Pointer#(0)

frm# = form#("Pinch Control", 500, 450)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

pinch# = pinch#(img#)
pinch_strength#(pinch#, 0)
pinch_radius#(pinch#, 50)

' Strength slider (-100 to +100 mapped to -1 to +1)
lblStr# = label#(frm#, "Strength: 0.00", 30, 190)
trkStr# = trackbar#(frm#)
trackbar_bounds#(trkStr#, 30, 215, 440, 25)
trackbar_max#(trkStr#, 200)
trackbar_value#(trkStr#, 100)
trackbar_onchange#(trkStr#, "OnStrength")

' Radius slider
lblRad# = label#(frm#, "Radius: 50", 30, 260)
trkRad# = trackbar#(frm#)
trackbar_bounds#(trkRad#, 30, 285, 440, 25)
trackbar_max#(trkRad#, 100)
trackbar_value#(trkRad#, 50)
trackbar_onchange#(trkRad#, "OnRadius")

form_show(frm#)

function OnStrength(sender#) local s
  let s = (trackbar_value(trkStr#) - 100) / 100
  pinch_strength#(pinch#, s)
  label_text#(lblStr#, "Strength: " + stri$(s, 2))
endfunction

function OnRadius(sender#) local r
  let r = trackbar_value(trkRad#)
  pinch_radius#(pinch#, r)
  label_text#(lblRad#, "Radius: " + str$(r))
endfunction
```

## Notes

- Center values are normalized (0-1), not pixel coordinates
- CenterX 0 = left edge, 1 = right edge
- CenterY 0 = top edge, 1 = bottom edge
- Positive strength = pinch inward (like pulling center in)
- Negative strength = bulge outward (like pushing center out)
- AspectRatio affects the shape of the distortion area

## See Also

- SwirlEffectLib - Swirl/twist distortion
- WrapEffectLib - Wrap distortion
- MagnifyEffectLib - Magnification effect
