# SepiaEffectLib

Applies a sepia tone effect to an image, creating a warm, vintage or antique photograph appearance. Adjustable intensity allows control from subtle toning to full sepia conversion.

## Functions

| Function | Description |
|----------|-------------|
| `sepia#(parent#)` | Creates sepia effect on control |
| `sepia_free(effect#)` | Destroys the effect |
| `sepia_amount#(effect#, value)` | Sets sepia intensity (0.0-1.0) |
| `sepia_amount(effect#)` | Gets sepia amount |
| `sepia_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `sepia_enabled(effect#)` | Gets enabled state |
| `sepia_trigger#(effect#, trigger$)` | Sets trigger string |
| `sepia_trigger$(effect#)` | Gets trigger string |
| `sepia_error()` | Returns last error code |
| `sepia_errormsg$()` | Returns last error message |
| `sepia_strerror$(code)` | Converts error code to text |
| `sepia_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Amount | 0.0 - 1.0 | 1.0 | Sepia intensity (0=none, 1=full) |

## Example 1: Basic Sepia Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let sepia# = Pointer#(0)

frm# = form#("Sepia Effect Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Apply sepia effect
sepia# = sepia#(img#)
sepia_amount#(sepia#, 1)

form_show(frm#)
```

## Example 2: Adjustable Sepia Intensity

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let sepia# = Pointer#(0)
let trkAmt# = Pointer#(0)
let lblAmt# = Pointer#(0)

frm# = form#("Sepia Control", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

sepia# = sepia#(img#)
sepia_amount#(sepia#, 0.5)

' Amount slider
lblAmt# = label#(frm#, "Sepia Amount: 0.50", 50, 200)
trkAmt# = trackbar#(frm#)
trackbar_bounds#(trkAmt#, 50, 230, 350, 30)
trackbar_max#(trkAmt#, 100)
trackbar_value#(trkAmt#, 50)
trackbar_onchange#(trkAmt#, "OnAmount")

form_show(frm#)

function OnAmount(sender#) local a
  let a = trackbar_value(trkAmt#) / 100
  sepia_amount#(sepia#, a)
  label_text#(lblAmt#, "Sepia Amount: " + stri$(a, 2))
endfunction
```

## Example 3: Before/After Comparison

```basic
let frm# = Pointer#(0)
let img1# = Pointer#(0)
let img2# = Pointer#(0)
let sepia# = Pointer#(0)
let lbl1# = Pointer#(0)
let lbl2# = Pointer#(0)

frm# = form#("Sepia Comparison", 500, 300)

' Original image
img1# = image#(frm#)
image_bounds#(img1#, 50, 30, 180, 135)
image_load#(img1#, "https://picsum.photos/180/135")
lbl1# = label#(frm#, "Original", 110, 175)

' Sepia image
img2# = image#(frm#)
image_bounds#(img2#, 270, 30, 180, 135)
image_load#(img2#, "https://picsum.photos/180/135")
sepia# = sepia#(img2#)
sepia_amount#(sepia#, 1)
lbl2# = label#(frm#, "Sepia", 335, 175)

form_show(frm#)
```

## Notes

- Amount 0 = no sepia (original colors)
- Amount 1 = full sepia tone
- Values in between create partial sepia toning
- Great for vintage or nostalgic photo effects
- Works well combined with other effects

## See Also

- MonochromeEffectLib - Black and white conversion
- HueAdjustEffectLib - Hue/color adjustment
- ContrastEffectLib - Contrast adjustment
