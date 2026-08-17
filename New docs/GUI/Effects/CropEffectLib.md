# CropEffectLib

Crops a rectangular area from the texture of visual controls. Uses **pixel coordinates** to define the crop region. The cropped area is scaled to fit the control boundaries.

**Important:** This effect works on bitmap/texture data only. It does NOT work on vector shapes like rectangles or circles. Use with TImage controls.

## Functions

| Function | Description |
|----------|-------------|
| `crop#(parent#)` | Creates crop effect on control |
| `crop_free(effect#)` | Destroys the effect |
| `crop_lefttopx#(effect#, value)` | Sets left edge (pixels) |
| `crop_lefttopx(effect#)` | Gets left edge |
| `crop_lefttopy#(effect#, value)` | Sets top edge (pixels) |
| `crop_lefttopy(effect#)` | Gets top edge |
| `crop_rightbottomx#(effect#, value)` | Sets right edge (pixels) |
| `crop_rightbottomx(effect#)` | Gets right edge |
| `crop_rightbottomy#(effect#, value)` | Sets bottom edge (pixels) |
| `crop_rightbottomy(effect#)` | Gets bottom edge |
| `crop_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `crop_enabled(effect#)` | Gets enabled state |
| `crop_trigger#(effect#, trigger$)` | Sets trigger string |
| `crop_trigger$(effect#)` | Gets trigger string |
| `crop_error()` | Returns last error code |
| `crop_errormsg$()` | Returns last error message |
| `crop_strerror$(code)` | Converts error code to text |
| `crop_clearerror()` | Clears error state |

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| LeftTopX | pixels | 0 | Left edge of crop area |
| LeftTopY | pixels | 0 | Top edge of crop area |
| RightBottomX | pixels | 10000 | Right edge of crop area |
| RightBottomY | pixels | 10000 | Bottom edge of crop area |

## Coordinate System

Coordinates are in **pixels** relative to the image:
- (0, 0) = Top-left corner of image
- Coordinates refer to the original image size

## Example 1: Basic Crop

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let crp# = Pointer#(0)

frm# = form#("Crop Demo", 400, 350)

' Image is 200x150 pixels
img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

crp# = crop#(img#)
crop_enabled#(crp#, 0)  ' Start disabled until image loads

let btn1# = button#(frm#, "Crop Left Half")
button_bounds#(btn1#, 50, 210, 120, 30)
button_onclick#(btn1#, "CropLeft")

let btn2# = button#(frm#, "Crop Center")
button_bounds#(btn2#, 180, 210, 120, 30)
button_onclick#(btn2#, "CropCenter")

let btn3# = button#(frm#, "Reset")
button_bounds#(btn3#, 115, 250, 120, 30)
button_onclick#(btn3#, "CropReset")

form_show(frm#)

function CropLeft(sender#)
  ' Crop left half: x=0 to 100, full height
  crop_lefttopx#(crp#, 0)
  crop_lefttopy#(crp#, 0)
  crop_rightbottomx#(crp#, 100)
  crop_rightbottomy#(crp#, 150)
  crop_enabled#(crp#, 1)
endfunction

function CropCenter(sender#)
  ' Crop center 50%: x=50-150, y=37-112
  crop_lefttopx#(crp#, 50)
  crop_lefttopy#(crp#, 37)
  crop_rightbottomx#(crp#, 150)
  crop_rightbottomy#(crp#, 112)
  crop_enabled#(crp#, 1)
endfunction

function CropReset(sender#)
  crop_enabled#(crp#, 0)
endfunction
```

## Example 2: Quadrant Selector

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let crp# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Quadrant Crop", 450, 380)

' Image is 200x150 pixels
img# = image#(frm#)
image_bounds#(img#, 125, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

crp# = crop#(img#)
crop_enabled#(crp#, 0)

lbl# = label#(frm#, "Click button after image loads", 115, 185)

let btn1# = button#(frm#, "Full")
button_bounds#(btn1#, 40, 220, 80, 30)
button_onclick#(btn1#, "SetFull")

let btn2# = button#(frm#, "Top-Left")
button_bounds#(btn2#, 130, 220, 80, 30)
button_onclick#(btn2#, "SetTL")

let btn3# = button#(frm#, "Top-Right")
button_bounds#(btn3#, 220, 220, 80, 30)
button_onclick#(btn3#, "SetTR")

let btn4# = button#(frm#, "Bottom-L")
button_bounds#(btn4#, 130, 260, 80, 30)
button_onclick#(btn4#, "SetBL")

let btn5# = button#(frm#, "Bottom-R")
button_bounds#(btn5#, 220, 260, 80, 30)
button_onclick#(btn5#, "SetBR")

form_show(frm#)

function SetFull(sender#)
  crop_enabled#(crp#, 0)
  label_text#(lbl#, "Showing: Full Image")
endfunction

function SetTL(sender#)
  ' Top-left quadrant: 0-100, 0-75
  crop_lefttopx#(crp#, 0)
  crop_lefttopy#(crp#, 0)
  crop_rightbottomx#(crp#, 100)
  crop_rightbottomy#(crp#, 75)
  crop_enabled#(crp#, 1)
  label_text#(lbl#, "Showing: Top-Left Quadrant")
endfunction

function SetTR(sender#)
  ' Top-right quadrant: 100-200, 0-75
  crop_lefttopx#(crp#, 100)
  crop_lefttopy#(crp#, 0)
  crop_rightbottomx#(crp#, 200)
  crop_rightbottomy#(crp#, 75)
  crop_enabled#(crp#, 1)
  label_text#(lbl#, "Showing: Top-Right Quadrant")
endfunction

function SetBL(sender#)
  ' Bottom-left quadrant: 0-100, 75-150
  crop_lefttopx#(crp#, 0)
  crop_lefttopy#(crp#, 75)
  crop_rightbottomx#(crp#, 100)
  crop_rightbottomy#(crp#, 150)
  crop_enabled#(crp#, 1)
  label_text#(lbl#, "Showing: Bottom-Left Quadrant")
endfunction

function SetBR(sender#)
  ' Bottom-right quadrant: 100-200, 75-150
  crop_lefttopx#(crp#, 100)
  crop_lefttopy#(crp#, 75)
  crop_rightbottomx#(crp#, 200)
  crop_rightbottomy#(crp#, 150)
  crop_enabled#(crp#, 1)
  label_text#(lbl#, "Showing: Bottom-Right Quadrant")
endfunction
```

## Important Notes

- Coordinates are in **pixels**, not percentages
- Only works with images (TImage), NOT shapes
- Keep effect disabled until image finishes loading
- Cropped area is scaled to fill the control

## See Also

- MagnifyEffectLib - Zoom into areas
- PixelateEffectLib - Pixelation effect
