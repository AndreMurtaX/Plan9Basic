# PerspectiveTransformEffectLib

Applies a perspective (3D) transformation to an image by manipulating its four corner points. Useful for creating perspective distortions, skewing, and 3D-like effects.

## Important: Pixel Coordinates

This effect uses **PIXEL coordinates**, not normalized 0-1 values. You must set the corners based on your actual image dimensions.

For a 200x150 pixel image, the default (undistorted) corners would be:
- TopLeft = (0, 0)
- TopRight = (200, 0)
- BottomRight = (200, 150)
- BottomLeft = (0, 150)

**Note:** The library initializes with small default values that may make images invisible. Always set all four corners explicitly based on your image size.

## Functions

| Function | Description |
|----------|-------------|
| `persp#(parent#)` | Creates perspective transform effect on control |
| `persp_free(effect#)` | Destroys the effect |
| `persp_topleftx#(effect#, value)` | Sets top-left X (pixels) |
| `persp_topleftx(effect#)` | Gets top-left X |
| `persp_toplefty#(effect#, value)` | Sets top-left Y (pixels) |
| `persp_toplefty(effect#)` | Gets top-left Y |
| `persp_toprightx#(effect#, value)` | Sets top-right X (pixels) |
| `persp_toprightx(effect#)` | Gets top-right X |
| `persp_toprighty#(effect#, value)` | Sets top-right Y (pixels) |
| `persp_toprighty(effect#)` | Gets top-right Y |
| `persp_bottomrightx#(effect#, value)` | Sets bottom-right X (pixels) |
| `persp_bottomrightx(effect#)` | Gets bottom-right X |
| `persp_bottomrighty#(effect#, value)` | Sets bottom-right Y (pixels) |
| `persp_bottomrighty(effect#)` | Gets bottom-right Y |
| `persp_bottomleftx#(effect#, value)` | Sets bottom-left X (pixels) |
| `persp_bottomleftx(effect#)` | Gets bottom-left X |
| `persp_bottomlefty#(effect#, value)` | Sets bottom-left Y (pixels) |
| `persp_bottomlefty(effect#)` | Gets bottom-left Y |
| `persp_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `persp_enabled(effect#)` | Gets enabled state |
| `persp_trigger#(effect#, trigger$)` | Sets trigger string |
| `persp_trigger$(effect#)` | Gets trigger string |
| `persp_error()` | Returns last error code |
| `persp_errormsg$()` | Returns last error message |
| `persp_strerror$(code)` | Converts error code to text |
| `persp_clearerror()` | Clears error state |

## Coordinate System (for 200x150 image)

```
(0,0) TopLeft -------- TopRight (200,0)
        |                  |
        |      IMAGE       |
        |                  |
(0,150) BottomLeft ---- BottomRight (200,150)
```

## Example 1: Basic Perspective Tilt

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let persp# = Pointer#(0)

' Image dimensions
let imgW = 200
let imgH = 150

frm# = form#("Perspective Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 50, imgW, imgH)
image_load#(img#, "https://picsum.photos/200/150")

' Apply perspective effect
persp# = persp#(img#)

' Set corners to actual image size first (undistorted)
persp_topleftx#(persp#, 0)
persp_toplefty#(persp#, 0)
persp_toprightx#(persp#, imgW)
persp_toprighty#(persp#, 0)
persp_bottomrightx#(persp#, imgW)
persp_bottomrighty#(persp#, imgH)
persp_bottomleftx#(persp#, 0)
persp_bottomlefty#(persp#, imgH)

' Now apply perspective tilt (narrower at top)
persp_topleftx#(persp#, 20)
persp_toprightx#(persp#, imgW - 20)

form_show(frm#)
```

## Example 2: Interactive Corner Control

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let persp# = Pointer#(0)
let trkTLX# = Pointer#(0)
let trkTRX# = Pointer#(0)
let lblTLX# = Pointer#(0)
let lblTRX# = Pointer#(0)

let imgW = 200
let imgH = 150

frm# = form#("Perspective Control", 500, 450)

img# = image#(frm#)
image_bounds#(img#, 150, 30, imgW, imgH)
image_load#(img#, "https://picsum.photos/200/150")

persp# = persp#(img#)

' Initialize to full image size
persp_topleftx#(persp#, 0)
persp_toplefty#(persp#, 0)
persp_toprightx#(persp#, imgW)
persp_toprighty#(persp#, 0)
persp_bottomrightx#(persp#, imgW)
persp_bottomrighty#(persp#, imgH)
persp_bottomleftx#(persp#, 0)
persp_bottomlefty#(persp#, imgH)

' Top-Left X slider (0 to 50 pixels inward)
lblTLX# = label#(frm#, "Top-Left X: 0", 30, 200)
trkTLX# = trackbar#(frm#)
trackbar_bounds#(trkTLX#, 30, 225, 200, 25)
trackbar_max#(trkTLX#, 50)
trackbar_value#(trkTLX#, 0)
trackbar_onchange#(trkTLX#, "OnTLX")

' Top-Right X slider (150 to 200)
lblTRX# = label#(frm#, "Top-Right X: 200", 260, 200)
trkTRX# = trackbar#(frm#)
trackbar_bounds#(trkTRX#, 260, 225, 200, 25)
trackbar_max#(trkTRX#, 50)
trackbar_value#(trkTRX#, 50)
trackbar_onchange#(trkTRX#, "OnTRX")

form_show(frm#)

function OnTLX(sender#) local x
  let x = trackbar_value(trkTLX#)
  persp_topleftx#(persp#, x)
  label_text#(lblTLX#, "Top-Left X: " + str$(x))
endfunction

function OnTRX(sender#) local x
  let x = 150 + trackbar_value(trkTRX#)
  persp_toprightx#(persp#, x)
  label_text#(lblTRX#, "Top-Right X: " + str$(x))
endfunction
```

## Example 3: Preset Perspective Effects

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let persp# = Pointer#(0)
let lblMode# = Pointer#(0)

let imgW = 200
let imgH = 150

frm# = form#("Perspective Presets", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, imgW, imgH)
image_load#(img#, "https://picsum.photos/200/150")

persp# = persp#(img#)

' Initialize to full size
persp_topleftx#(persp#, 0)
persp_toplefty#(persp#, 0)
persp_toprightx#(persp#, imgW)
persp_toprighty#(persp#, 0)
persp_bottomrightx#(persp#, imgW)
persp_bottomrighty#(persp#, imgH)
persp_bottomleftx#(persp#, 0)
persp_bottomlefty#(persp#, imgH)

lblMode# = label#(frm#, "Mode: Normal", 175, 200)

let btn1# = button#(frm#, "Normal")
button_bounds#(btn1#, 30, 240, 80, 30)
button_onclick#(btn1#, "ModeNormal")

let btn2# = button#(frm#, "Tilt Top")
button_bounds#(btn2#, 120, 240, 80, 30)
button_onclick#(btn2#, "ModeTiltTop")

let btn3# = button#(frm#, "Tilt Left")
button_bounds#(btn3#, 210, 240, 80, 30)
button_onclick#(btn3#, "ModeTiltLeft")

let btn4# = button#(frm#, "Skew")
button_bounds#(btn4#, 300, 240, 80, 30)
button_onclick#(btn4#, "ModeSkew")

form_show(frm#)

function ModeNormal(sender#)
  persp_topleftx#(persp#, 0)
  persp_toplefty#(persp#, 0)
  persp_toprightx#(persp#, imgW)
  persp_toprighty#(persp#, 0)
  persp_bottomrightx#(persp#, imgW)
  persp_bottomrighty#(persp#, imgH)
  persp_bottomleftx#(persp#, 0)
  persp_bottomlefty#(persp#, imgH)
  label_text#(lblMode#, "Mode: Normal")
endfunction

function ModeTiltTop(sender#)
  persp_topleftx#(persp#, 30)
  persp_toplefty#(persp#, 0)
  persp_toprightx#(persp#, imgW - 30)
  persp_toprighty#(persp#, 0)
  persp_bottomrightx#(persp#, imgW)
  persp_bottomrighty#(persp#, imgH)
  persp_bottomleftx#(persp#, 0)
  persp_bottomlefty#(persp#, imgH)
  label_text#(lblMode#, "Mode: Tilt Top")
endfunction

function ModeTiltLeft(sender#)
  persp_topleftx#(persp#, 0)
  persp_toplefty#(persp#, 15)
  persp_toprightx#(persp#, imgW)
  persp_toprighty#(persp#, 0)
  persp_bottomrightx#(persp#, imgW)
  persp_bottomrighty#(persp#, imgH)
  persp_bottomleftx#(persp#, 0)
  persp_bottomlefty#(persp#, imgH - 15)
  label_text#(lblMode#, "Mode: Tilt Left")
endfunction

function ModeSkew(sender#)
  persp_topleftx#(persp#, 20)
  persp_toplefty#(persp#, 0)
  persp_toprightx#(persp#, imgW)
  persp_toprighty#(persp#, 15)
  persp_bottomrightx#(persp#, imgW - 20)
  persp_bottomrighty#(persp#, imgH)
  persp_bottomleftx#(persp#, 0)
  persp_bottomlefty#(persp#, imgH - 15)
  label_text#(lblMode#, "Mode: Skew")
endfunction
```

## Notes

- **All coordinates are in PIXELS**, not normalized 0-1 values
- Always initialize all 8 corner values to your image dimensions
- Moving corners inward creates "receding" perspective effect
- Can create 3D-like perspective illusions
- Useful for placing images on angled surfaces

## See Also

- AffineTransformEffectLib - 2D transformations
- WrapEffectLib - Wrap/warp distortion
- PinchEffectLib - Pinch distortion
