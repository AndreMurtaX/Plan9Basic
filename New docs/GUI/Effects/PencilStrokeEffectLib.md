# PencilStrokeEffectLib

Transforms an image to look like it was drawn with pencil strokes. Creates an artistic hand-drawn effect with adjustable stroke size.

## Functions

| Function | Description |
|----------|-------------|
| `pencilstroke#(parent#)` | Creates pencil stroke effect on control |
| `pencilstroke_free(effect#)` | Destroys the effect |
| `pencilstroke_brushsize#(effect#, value)` | Sets stroke size |
| `pencilstroke_brushsize(effect#)` | Gets brush size |
| `pencilstroke_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `pencilstroke_enabled(effect#)` | Gets enabled state |
| `pencilstroke_trigger#(effect#, trigger$)` | Sets trigger string |
| `pencilstroke_trigger$(effect#)` | Gets trigger string |
| `pencilstroke_error()` | Returns last error code |
| `pencilstroke_errormsg$()` | Returns last error message |
| `pencilstroke_strerror$(code)` | Converts error code to text |
| `pencilstroke_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| BrushSize | 0.0+ | 1.0 | Size of pencil strokes |

## Example 1: Basic Pencil Stroke

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let pencil# = Pointer#(0)

frm# = form#("Pencil Stroke Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Apply pencil stroke effect
pencil# = pencilstroke#(img#)
pencilstroke_brushsize#(pencil#, 1)

form_show(frm#)
```

## Example 2: Adjustable Stroke Size

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let pencil# = Pointer#(0)
let trkBrush# = Pointer#(0)
let lblBrush# = Pointer#(0)

frm# = form#("Pencil Stroke Control", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

pencil# = pencilstroke#(img#)
pencilstroke_brushsize#(pencil#, 1)

' Stroke size slider
lblBrush# = label#(frm#, "Stroke Size: 1.0", 160, 200)
trkBrush# = trackbar#(frm#)
trackbar_bounds#(trkBrush#, 50, 230, 350, 30)
trackbar_max#(trkBrush#, 50)
trackbar_value#(trkBrush#, 10)
trackbar_onchange#(trkBrush#, "OnBrushChange")

form_show(frm#)

function OnBrushChange(sender#) local b
  let b = trackbar_value(trkBrush#) / 10
  if b < 0.1 then
    b = 0.1
  endif
  pencilstroke_brushsize#(pencil#, b)
  label_text#(lblBrush#, "Stroke Size: " + stri$(b, 1))
endfunction
```

## Example 3: Compare Pencil Stroke Sizes

```basic
let frm# = Pointer#(0)
let img1# = Pointer#(0)
let img2# = Pointer#(0)
let img3# = Pointer#(0)
let p1# = Pointer#(0)
let p2# = Pointer#(0)
let p3# = Pointer#(0)

frm# = form#("Stroke Size Comparison", 550, 350)

' Fine strokes
img1# = image#(frm#)
image_bounds#(img1#, 30, 30, 150, 112)
image_load#(img1#, "https://picsum.photos/150/112")
p1# = pencilstroke#(img1#)
pencilstroke_brushsize#(p1#, 0.5)
let lbl1# = label#(frm#, "Size: 0.5", 75, 150)

' Medium strokes
img2# = image#(frm#)
image_bounds#(img2#, 200, 30, 150, 112)
image_load#(img2#, "https://picsum.photos/150/112")
p2# = pencilstroke#(img2#)
pencilstroke_brushsize#(p2#, 1.5)
let lbl2# = label#(frm#, "Size: 1.5", 245, 150)

' Bold strokes
img3# = image#(frm#)
image_bounds#(img3#, 370, 30, 150, 112)
image_load#(img3#, "https://picsum.photos/150/112")
p3# = pencilstroke#(img3#)
pencilstroke_brushsize#(p3#, 3.0)
let lbl3# = label#(frm#, "Size: 3.0", 415, 150)

form_show(frm#)
```

## Notes

- Similar to PaperSketchEffect but with different visual style
- BrushSize affects stroke thickness
- Smaller values = finer, more detailed strokes
- Larger values = bolder, more pronounced strokes
- Works best with images that have clear edges and contrast

## See Also

- PaperSketchEffectLib - Similar sketch effect
- EmbossEffectLib - 3D embossed look
- ToonEffectLib - Cartoon/cel-shaded effect
