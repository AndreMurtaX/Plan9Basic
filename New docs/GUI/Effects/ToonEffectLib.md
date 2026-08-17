# ToonEffectLib

Applies a cartoon/posterization effect to an image, reducing the number of color levels to create a stylized, comic-book look.

## Functions

| Function | Description |
|----------|-------------|
| `toon#(parent#)` | Creates toon effect on control |
| `toon_free(effect#)` | Destroys the effect |
| `toon_levels#(effect#, value)` | Sets number of color levels |
| `toon_levels(effect#)` | Gets levels |
| `toon_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `toon_enabled(effect#)` | Gets enabled state |
| `toon_trigger#(effect#, trigger$)` | Sets trigger string |
| `toon_trigger$(effect#)` | Gets trigger string |
| `toon_error()` | Returns last error code |
| `toon_errormsg$()` | Returns last error message |
| `toon_strerror$(code)` | Converts error code to text |
| `toon_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Levels | 2+ | 5 | Number of color levels (lower = more cartoon-like) |

## Example 1: Basic Toon Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let toon# = Pointer#(0)

frm# = form#("Toon Effect Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Apply toon/cartoon effect
toon# = toon#(img#)
toon_levels#(toon#, 5)

form_show(frm#)
```

## Example 2: Adjustable Color Levels

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let toon# = Pointer#(0)
let trkLvl# = Pointer#(0)
let lblLvl# = Pointer#(0)

frm# = form#("Toon Control", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

toon# = toon#(img#)
toon_levels#(toon#, 5)

' Levels slider
lblLvl# = label#(frm#, "Levels: 5", 180, 200)
trkLvl# = trackbar#(frm#)
trackbar_bounds#(trkLvl#, 50, 230, 350, 30)
trackbar_max#(trkLvl#, 20)
trackbar_value#(trkLvl#, 5)
trackbar_onchange#(trkLvl#, "OnLevels")

form_show(frm#)

function OnLevels(sender#) local l
  let l = trackbar_value(trkLvl#)
  if l < 2 then
    l = 2
  endif
  toon_levels#(toon#, l)
  label_text#(lblLvl#, "Levels: " + str$(l))
endfunction
```

## Example 3: Before/After Comparison

```basic
let frm# = Pointer#(0)
let img1# = Pointer#(0)
let img2# = Pointer#(0)
let toon# = Pointer#(0)

frm# = form#("Toon Comparison", 500, 300)

' Original
img1# = image#(frm#)
image_bounds#(img1#, 50, 30, 180, 135)
image_load#(img1#, "https://picsum.photos/180/135")
let lbl1# = label#(frm#, "Original", 110, 175)

' Toon effect
img2# = image#(frm#)
image_bounds#(img2#, 270, 30, 180, 135)
image_load#(img2#, "https://picsum.photos/180/135")
toon# = toon#(img2#)
toon_levels#(toon#, 4)
let lbl2# = label#(frm#, "Toon (4 levels)", 310, 175)

form_show(frm#)
```

## Notes

- Lower levels = stronger cartoon effect
- Minimum practical value is 2
- Higher values (10+) approach original image
- Values 3-6 create typical cartoon look
- Combines well with edge detection effects

## See Also

- PosterizeEffectLib - Color posterization
- PaperSketchEffectLib - Sketch effect
- PencilStrokeEffectLib - Pencil drawing effect
