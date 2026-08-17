# TilerEffectLib

Creates a tiling effect that repeats the image in a grid pattern. Useful for creating wallpaper-like patterns, thumbnails, or kaleidoscope-style effects.

## Functions

| Function | Description |
|----------|-------------|
| `tiler#(parent#)` | Creates tiler effect on control |
| `tiler_free(effect#)` | Destroys the effect |
| `tiler_htiles#(effect#, value)` | Sets horizontal tile count |
| `tiler_htiles(effect#)` | Gets horizontal tiles |
| `tiler_vtiles#(effect#, value)` | Sets vertical tile count |
| `tiler_vtiles(effect#)` | Gets vertical tiles |
| `tiler_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `tiler_enabled(effect#)` | Gets enabled state |
| `tiler_trigger#(effect#, trigger$)` | Sets trigger string |
| `tiler_trigger$(effect#)` | Gets trigger string |
| `tiler_error()` | Returns last error code |
| `tiler_errormsg$()` | Returns last error message |
| `tiler_strerror$(code)` | Converts error code to text |
| `tiler_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| HorizontalTileCount | 1+ | 2 | Number of horizontal tiles |
| VerticalTileCount | 1+ | 2 | Number of vertical tiles |

## Example 1: Basic Tiling Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let tiler# = Pointer#(0)

frm# = form#("Tiler Effect Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Apply tiling (2x2 grid)
tiler# = tiler#(img#)
tiler_htiles#(tiler#, 2)
tiler_vtiles#(tiler#, 2)

form_show(frm#)
```

## Example 2: Adjustable Tile Count

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let tiler# = Pointer#(0)
let trkH# = Pointer#(0)
let trkV# = Pointer#(0)
let lblH# = Pointer#(0)
let lblV# = Pointer#(0)

frm# = form#("Tiler Control", 500, 450)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

tiler# = tiler#(img#)
tiler_htiles#(tiler#, 2)
tiler_vtiles#(tiler#, 2)

' Horizontal tiles slider
lblH# = label#(frm#, "Horizontal: 2", 30, 190)
trkH# = trackbar#(frm#)
trackbar_bounds#(trkH#, 30, 215, 440, 25)
trackbar_max#(trkH#, 8)
trackbar_value#(trkH#, 2)
trackbar_onchange#(trkH#, "OnHorizontal")

' Vertical tiles slider
lblV# = label#(frm#, "Vertical: 2", 30, 260)
trkV# = trackbar#(frm#)
trackbar_bounds#(trkV#, 30, 285, 440, 25)
trackbar_max#(trkV#, 8)
trackbar_value#(trkV#, 2)
trackbar_onchange#(trkV#, "OnVertical")

form_show(frm#)

function OnHorizontal(sender#) local h
  let h = trackbar_value(trkH#)
  if h < 1 then h = 1
  tiler_htiles#(tiler#, h)
  label_text#(lblH#, "Horizontal: " + str$(h))
endfunction

function OnVertical(sender#) local v
  let v = trackbar_value(trkV#)
  if v < 1 then v = 1
  tiler_vtiles#(tiler#, v)
  label_text#(lblV#, "Vertical: " + str$(v))
endfunction
```

## Example 3: Preset Tile Patterns

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let tiler# = Pointer#(0)
let lblInfo# = Pointer#(0)

frm# = form#("Tile Patterns", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

tiler# = tiler#(img#)
lblInfo# = label#(frm#, "Pattern: 1x1 (Original)", 140, 195)

let btn1# = button#(frm#, "1x1")
button_bounds#(btn1#, 30, 230, 70, 30)
button_onclick#(btn1#, "Pattern1x1")

let btn2# = button#(frm#, "2x2")
button_bounds#(btn2#, 110, 230, 70, 30)
button_onclick#(btn2#, "Pattern2x2")

let btn3# = button#(frm#, "3x3")
button_bounds#(btn3#, 190, 230, 70, 30)
button_onclick#(btn3#, "Pattern3x3")

let btn4# = button#(frm#, "4x4")
button_bounds#(btn4#, 270, 230, 70, 30)
button_onclick#(btn4#, "Pattern4x4")

let btn5# = button#(frm#, "2x3")
button_bounds#(btn5#, 350, 230, 70, 30)
button_onclick#(btn5#, "Pattern2x3")

form_show(frm#)

function Pattern1x1(sender#)
  tiler_htiles#(tiler#, 1)
  tiler_vtiles#(tiler#, 1)
  label_text#(lblInfo#, "Pattern: 1x1 (Original)")
endfunction

function Pattern2x2(sender#)
  tiler_htiles#(tiler#, 2)
  tiler_vtiles#(tiler#, 2)
  label_text#(lblInfo#, "Pattern: 2x2")
endfunction

function Pattern3x3(sender#)
  tiler_htiles#(tiler#, 3)
  tiler_vtiles#(tiler#, 3)
  label_text#(lblInfo#, "Pattern: 3x3")
endfunction

function Pattern4x4(sender#)
  tiler_htiles#(tiler#, 4)
  tiler_vtiles#(tiler#, 4)
  label_text#(lblInfo#, "Pattern: 4x4")
endfunction

function Pattern2x3(sender#)
  tiler_htiles#(tiler#, 2)
  tiler_vtiles#(tiler#, 3)
  label_text#(lblInfo#, "Pattern: 2x3")
endfunction
```

## Notes

- Tile count of 1x1 shows the original image
- Higher tile counts make each tile smaller
- Tiles are scaled to fit within the original bounds
- Great for creating wallpaper/pattern effects
- Can create thumbnail grids or mosaic effects

## See Also

- PixelateEffectLib - Pixelation effect
- ReflectionEffectLib - Reflection effect
- WrapEffectLib - Wrap/repeat distortion
