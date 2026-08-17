# MagnifyEffectLib

Creates a magnifying glass effect on visual controls. A circular area around the center point is enlarged, simulating looking through a magnifying lens.

## Functions

| Function | Description |
|----------|-------------|
| `magnify#(parent#)` | Creates magnify effect on control |
| `magnify_free(effect#)` | Destroys the effect |
| `magnify_magnification#(effect#, value)` | Sets zoom level |
| `magnify_magnification(effect#)` | Gets magnification |
| `magnify_radius#(effect#, value)` | Sets lens radius in pixels |
| `magnify_radius(effect#)` | Gets radius |
| `magnify_centerx#(effect#, value)` | Sets X center (0-1) |
| `magnify_centerx(effect#)` | Gets X center |
| `magnify_centery#(effect#, value)` | Sets Y center (0-1) |
| `magnify_centery(effect#)` | Gets Y center |
| `magnify_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `magnify_enabled(effect#)` | Gets enabled state |
| `magnify_trigger#(effect#, trigger$)` | Sets trigger string |
| `magnify_trigger$(effect#)` | Gets trigger string |
| `magnify_error()` | Returns last error code |
| `magnify_errormsg$()` | Returns last error message |
| `magnify_strerror$(code)` | Converts error code to text |
| `magnify_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Magnification | 0.0+ | 2.0 | Zoom level (1=no zoom, 2=2x zoom) |
| Radius | 0+ | 100 | Lens radius in pixels |
| CenterX | 0.0 - 1.0 | 0.5 | Horizontal center position |
| CenterY | 0.0 - 1.0 | 0.5 | Vertical center position |

## Example 1: Basic Magnify Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let mag# = Pointer#(0)

frm# = form#("Magnify Effect Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Create magnify effect
mag# = magnify#(img#)
magnify_magnification#(mag#, 2)
magnify_radius#(mag#, 50)

form_show(frm#)
```

## Example 2: Adjustable Magnification

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let mag# = Pointer#(0)
let trkZoom# = Pointer#(0)
let trkRadius# = Pointer#(0)
let lblZoom# = Pointer#(0)
let lblRadius# = Pointer#(0)

frm# = form#("Magnify Control", 500, 450)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

mag# = magnify#(img#)
magnify_magnification#(mag#, 2)
magnify_radius#(mag#, 40)

' Magnification slider (1-5x)
lblZoom# = label#(frm#, "Zoom: 2.0x", 30, 190)
trkZoom# = trackbar#(frm#)
trackbar_bounds#(trkZoom#, 30, 215, 440, 25)
trackbar_max#(trkZoom#, 50)
trackbar_value#(trkZoom#, 20)
trackbar_onchange#(trkZoom#, "OnZoom")

' Radius slider (10-100)
lblRadius# = label#(frm#, "Radius: 40", 30, 260)
trkRadius# = trackbar#(frm#)
trackbar_bounds#(trkRadius#, 30, 285, 440, 25)
trackbar_max#(trkRadius#, 100)
trackbar_value#(trkRadius#, 40)
trackbar_onchange#(trkRadius#, "OnRadius")

form_show(frm#)

function OnZoom(sender#) local z
  let z = trackbar_value(trkZoom#) / 10
  if z < 1 then
    z = 1
  endif
  magnify_magnification#(mag#, z)
  label_text#(lblZoom#, "Zoom: " + stri$(z, 1) + "x")
endfunction

function OnRadius(sender#) local r
  let r = trackbar_value(trkRadius#)
  if r < 10 then
    r = 10
  endif
  magnify_radius#(mag#, r)
  label_text#(lblRadius#, "Radius: " + str$(r))
endfunction
```

## Example 3: Move Magnifier Position

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let mag# = Pointer#(0)
let trkX# = Pointer#(0)
let trkY# = Pointer#(0)
let lblX# = Pointer#(0)
let lblY# = Pointer#(0)

frm# = form#("Move Magnifier", 500, 470)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

mag# = magnify#(img#)
magnify_magnification#(mag#, 2.5)
magnify_radius#(mag#, 35)

' X position slider
lblX# = label#(frm#, "Center X: 0.50", 30, 190)
trkX# = trackbar#(frm#)
trackbar_bounds#(trkX#, 30, 215, 440, 25)
trackbar_max#(trkX#, 100)
trackbar_value#(trkX#, 50)
trackbar_onchange#(trkX#, "OnMoveX")

' Y position slider
lblY# = label#(frm#, "Center Y: 0.50", 30, 260)
trkY# = trackbar#(frm#)
trackbar_bounds#(trkY#, 30, 285, 440, 25)
trackbar_max#(trkY#, 100)
trackbar_value#(trkY#, 50)
trackbar_onchange#(trkY#, "OnMoveY")

form_show(frm#)

function OnMoveX(sender#) local x
  let x = trackbar_value(trkX#) / 100
  magnify_centerx#(mag#, x)
  label_text#(lblX#, "Center X: " + stri$(x, 2))
endfunction

function OnMoveY(sender#) local y
  let y = trackbar_value(trkY#) / 100
  magnify_centery#(mag#, y)
  label_text#(lblY#, "Center Y: " + stri$(y, 2))
endfunction
```

## Notes

- Center values are normalized (0-1), not pixel coordinates
- CenterX 0 = left edge, 1 = right edge
- CenterY 0 = top edge, 1 = bottom edge
- Magnification < 1 creates shrinking effect
- Use images for visible results (needs pixel detail)

## See Also

- SmoothMagnifyEffectLib - Smooth edge magnification
- MagnifyTransitionEffectLib - Magnify transition effect
- PinchEffectLib - Pinch/distortion effect
