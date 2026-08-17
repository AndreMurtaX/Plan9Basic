# SharpenEffectLib

Increases edge contrast to make images and controls appear sharper and more defined.

## Functions

| Function | Description |
|----------|-------------|
| `sharpen#(parent#)` | Creates sharpen effect on control |
| `sharpen_free(effect#)` | Destroys the effect |
| `sharpen_amount#(effect#, value)` | Sets sharpening intensity (0.0-2.0) |
| `sharpen_amount(effect#)` | Gets amount value |
| `sharpen_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `sharpen_enabled(effect#)` | Gets enabled state |
| `sharpen_trigger#(effect#, trigger$)` | Sets trigger string |
| `sharpen_trigger$(effect#)` | Gets trigger string |
| `sharpen_error()` | Returns last error code |
| `sharpen_errormsg$()` | Returns last error message |
| `sharpen_strerror$(code)` | Converts error code to text |
| `sharpen_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Amount | 0.0 - 2.0 | 1.0 | Sharpening intensity |

## Example 1: Basic Sharpen

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let shp# = Pointer#(0)

frm# = form#("Sharpen Demo", 400, 300)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 80, 200, 120)
rectangle_fill#(rect#, "SteelBlue")

shp# = sharpen#(rect#)
sharpen_amount#(shp#, 1.5)

form_show(frm#)
```

## Example 2: Sharpen Control

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let shp# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Sharpen Control", 450, 320)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 125, 40, 200, 100)
rectangle_fill#(rect#, "DodgerBlue")

shp# = sharpen#(rect#)
sharpen_amount#(shp#, 0)

lbl# = label#(frm#, "Amount: 0 (Normal)", 145, 160)

let btn1# = button#(frm#, "Normal")
button_bounds#(btn1#, 50, 200, 80, 30)
button_onclick#(btn1#, "SetNormal")

let btn2# = button#(frm#, "Light")
button_bounds#(btn2#, 140, 200, 80, 30)
button_onclick#(btn2#, "SetLight")

let btn3# = button#(frm#, "Medium")
button_bounds#(btn3#, 230, 200, 80, 30)
button_onclick#(btn3#, "SetMedium")

let btn4# = button#(frm#, "Strong")
button_bounds#(btn4#, 320, 200, 80, 30)
button_onclick#(btn4#, "SetStrong")

form_show(frm#)

function SetNormal(sender#)
  sharpen_amount#(shp#, 0)
  label_text#(lbl#, "Amount: 0 (Normal)")
endfunction

function SetLight(sender#)
  sharpen_amount#(shp#, 0.5)
  label_text#(lbl#, "Amount: 0.5 (Light)")
endfunction

function SetMedium(sender#)
  sharpen_amount#(shp#, 1.0)
  label_text#(lbl#, "Amount: 1.0 (Medium)")
endfunction

function SetStrong(sender#)
  sharpen_amount#(shp#, 2.0)
  label_text#(lbl#, "Amount: 2.0 (Strong)")
endfunction
```

## Example 3: Toggle Sharpen

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let shp# = Pointer#(0)

frm# = form#("Toggle Sharpen", 400, 280)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 50, 200, 120)
rectangle_fill#(rect#, "Coral")

shp# = sharpen#(rect#)
sharpen_amount#(shp#, 1.5)

let btn# = button#(frm#, "Toggle Sharpen")
button_bounds#(btn#, 120, 200, 140, 35)
button_onclick#(btn#, "OnToggle")

form_show(frm#)

function OnToggle(sender#)
  if sharpen_enabled(shp#) = 1 then
    sharpen_enabled#(shp#, 0)
  else
    sharpen_enabled#(shp#, 1)
  endif
endfunction
```

## Notes

- Works best on images and detailed graphics
- High values (>1.5) can create harsh edges
- Use moderate values (0.5-1.0) for subtle sharpening

## See Also

- BlurEffectLib - Opposite effect (softening)
- EmbossEffectLib - Edge enhancement
