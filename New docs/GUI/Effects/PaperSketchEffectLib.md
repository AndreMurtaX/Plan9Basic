# PaperSketchEffectLib

Transforms an image to look like a pencil sketch on paper. Creates an artistic effect that mimics hand-drawn sketches with adjustable brush size.

## Functions

| Function | Description |
|----------|-------------|
| `papersketch#(parent#)` | Creates paper sketch effect on control |
| `papersketch_free(effect#)` | Destroys the effect |
| `papersketch_brushsize#(effect#, value)` | Sets brush/stroke size |
| `papersketch_brushsize(effect#)` | Gets brush size |
| `papersketch_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `papersketch_enabled(effect#)` | Gets enabled state |
| `papersketch_trigger#(effect#, trigger$)` | Sets trigger string |
| `papersketch_trigger$(effect#)` | Gets trigger string |
| `papersketch_error()` | Returns last error code |
| `papersketch_errormsg$()` | Returns last error message |
| `papersketch_strerror$(code)` | Converts error code to text |
| `papersketch_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| BrushSize | 0.0+ | 1.0 | Size of sketch strokes |

## Example 1: Basic Paper Sketch

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let sketch# = Pointer#(0)

frm# = form#("Paper Sketch Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Apply paper sketch effect
sketch# = papersketch#(img#)
papersketch_brushsize#(sketch#, 1)

form_show(frm#)
```

## Example 2: Adjustable Brush Size

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let sketch# = Pointer#(0)
let trkBrush# = Pointer#(0)
let lblBrush# = Pointer#(0)

frm# = form#("Sketch Brush Control", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

sketch# = papersketch#(img#)
papersketch_brushsize#(sketch#, 1)

' Brush size slider
lblBrush# = label#(frm#, "Brush Size: 1.0", 160, 200)
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
  papersketch_brushsize#(sketch#, b)
  label_text#(lblBrush#, "Brush Size: " + stri$(b, 1))
endfunction
```

## Example 3: Compare Original and Sketch

```basic
let frm# = Pointer#(0)
let img1# = Pointer#(0)
let img2# = Pointer#(0)
let sketch# = Pointer#(0)
let lbl1# = Pointer#(0)
let lbl2# = Pointer#(0)

frm# = form#("Sketch Comparison", 500, 350)

' Original image
img1# = image#(frm#)
image_bounds#(img1#, 50, 30, 180, 135)
image_load#(img1#, "https://picsum.photos/180/135")
lbl1# = label#(frm#, "Original", 110, 175)

' With paper sketch effect
img2# = image#(frm#)
image_bounds#(img2#, 270, 30, 180, 135)
image_load#(img2#, "https://picsum.photos/180/135")
sketch# = papersketch#(img2#)
papersketch_brushsize#(sketch#, 1.5)
lbl2# = label#(frm#, "Paper Sketch", 310, 175)

form_show(frm#)
```

## Notes

- Creates an artistic pencil-on-paper look
- BrushSize affects stroke thickness
- Smaller values = finer detail
- Larger values = bolder strokes
- Works best with images that have clear edges

## See Also

- PencilStrokeEffectLib - Similar pencil effect
- EmbossEffectLib - 3D embossed look
- MonochromeEffectLib - Grayscale conversion
