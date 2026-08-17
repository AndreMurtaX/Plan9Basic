# PixelateEffectLib

Creates a pixelation (mosaic) effect on visual controls, reducing detail by grouping pixels into larger blocks. Works best on images.

## Functions

| Function | Description |
|----------|-------------|
| `pixelate#(parent#)` | Creates pixelate effect on control |
| `pixelate_free(effect#)` | Destroys the effect |
| `pixelate_blockcount#(effect#, value)` | Sets block count (1-100) |
| `pixelate_blockcount(effect#)` | Gets block count |
| `pixelate_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `pixelate_enabled(effect#)` | Gets enabled state |
| `pixelate_trigger#(effect#, trigger$)` | Sets trigger string |
| `pixelate_trigger$(effect#)` | Gets trigger string |
| `pixelate_error()` | Returns last error code |
| `pixelate_errormsg$()` | Returns last error message |
| `pixelate_strerror$(code)` | Converts error code to text |
| `pixelate_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| BlockCount | 1 - 100 | 20 | Number of pixel blocks |

## Block Count Values

| Value | Effect |
|-------|--------|
| 5-10 | Very pixelated (large blocks) |
| 20-30 | Moderately pixelated |
| 50-70 | Slightly pixelated |
| 80-100 | Nearly original detail |

Lower values = larger blocks = more pixelated

## Example 1: Basic Pixelate

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let pix# = Pointer#(0)

frm# = form#("Pixelate Demo", 400, 320)

img# = image#(frm#)
image_bounds#(img#, 100, 40, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

pix# = pixelate#(img#)
pixelate_blockcount#(pix#, 15)

form_show(frm#)
```

## Example 2: Pixelation Control

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let pix# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Pixelation Control", 450, 380)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

pix# = pixelate#(img#)
pixelate_blockcount#(pix#, 50)

lbl# = label#(frm#, "Blocks: 50", 180, 200)

let btn1# = button#(frm#, "5")
button_bounds#(btn1#, 50, 240, 70, 30)
button_onclick#(btn1#, "SetBlocks5")

let btn2# = button#(frm#, "15")
button_bounds#(btn2#, 130, 240, 70, 30)
button_onclick#(btn2#, "SetBlocks15")

let btn3# = button#(frm#, "30")
button_bounds#(btn3#, 210, 240, 70, 30)
button_onclick#(btn3#, "SetBlocks30")

let btn4# = button#(frm#, "50")
button_bounds#(btn4#, 290, 240, 70, 30)
button_onclick#(btn4#, "SetBlocks50")

form_show(frm#)

function SetBlocks5(sender#)
  pixelate_blockcount#(pix#, 5)
  label_text#(lbl#, "Blocks: 5 (Very pixelated)")
endfunction

function SetBlocks15(sender#)
  pixelate_blockcount#(pix#, 15)
  label_text#(lbl#, "Blocks: 15 (Pixelated)")
endfunction

function SetBlocks30(sender#)
  pixelate_blockcount#(pix#, 30)
  label_text#(lbl#, "Blocks: 30 (Moderate)")
endfunction

function SetBlocks50(sender#)
  pixelate_blockcount#(pix#, 50)
  label_text#(lbl#, "Blocks: 50 (Light)")
endfunction
```

## Example 3: Toggle Pixelation

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let pix# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Toggle Pixelate", 400, 340)

img# = image#(frm#)
image_bounds#(img#, 100, 40, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

pix# = pixelate#(img#)
pixelate_blockcount#(pix#, 10)

lbl# = label#(frm#, "Pixelation: ON", 150, 210)

let btn# = button#(frm#, "Toggle Pixelate")
button_bounds#(btn#, 120, 250, 140, 35)
button_onclick#(btn#, "OnToggle")

form_show(frm#)

function OnToggle(sender#)
  if pixelate_enabled(pix#) = 1 then
    pixelate_enabled#(pix#, 0)
    label_text#(lbl#, "Pixelation: OFF")
  else
    pixelate_enabled#(pix#, 1)
    label_text#(lbl#, "Pixelation: ON")
  endif
endfunction
```

## Notes

- Works best on images with details
- Solid color shapes won't show visible change
- Use for censoring, retro effects, or transitions
- Lower block count = more pixelation

## See Also

- BlurEffectLib - Blur effects
- CropEffectLib - Crop/mask effects
