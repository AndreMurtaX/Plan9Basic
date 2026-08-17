# EmbossEffectLib

Creates an emboss (raised) effect on visual controls, simulating a 3D pressed appearance.

## Functions

| Function | Description |
|----------|-------------|
| `emboss#(parent#)` | Creates emboss effect on control |
| `emboss_free(effect#)` | Destroys the effect |
| `emboss_amount#(effect#, value)` | Sets emboss intensity (0.0-1.0) |
| `emboss_amount(effect#)` | Gets amount value |
| `emboss_width#(effect#, value)` | Sets edge width (0.0-10.0) |
| `emboss_width(effect#)` | Gets width value |
| `emboss_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `emboss_enabled(effect#)` | Gets enabled state |
| `emboss_trigger#(effect#, trigger$)` | Sets trigger string |
| `emboss_trigger$(effect#)` | Gets trigger string |
| `emboss_error()` | Returns last error code |
| `emboss_errormsg$()` | Returns last error message |
| `emboss_strerror$(code)` | Converts error code to text |
| `emboss_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Amount | 0.0 - 1.0 | 0.5 | Emboss intensity |
| Width | 0.0 - 10.0 | 1.0 | Edge thickness |

## Example 1: Basic Emboss

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let emb# = Pointer#(0)

frm# = form#("Emboss Demo", 400, 300)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 80, 200, 120)
rectangle_fill#(rect#, "Silver")

emb# = emboss#(rect#)
emboss_amount#(emb#, 0.5)
emboss_width#(emb#, 2)

form_show(frm#)
```

## Example 2: Emboss Intensity Control

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let emb# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Emboss Control", 450, 320)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 125, 40, 200, 100)
rectangle_fill#(rect#, "Gray")

emb# = emboss#(rect#)
emboss_amount#(emb#, 0.5)
emboss_width#(emb#, 2)

lbl# = label#(frm#, "Amount: 0.5", 170, 160)

let btn1# = button#(frm#, "Light")
button_bounds#(btn1#, 60, 200, 100, 30)
button_onclick#(btn1#, "SetLight")

let btn2# = button#(frm#, "Medium")
button_bounds#(btn2#, 170, 200, 100, 30)
button_onclick#(btn2#, "SetMedium")

let btn3# = button#(frm#, "Strong")
button_bounds#(btn3#, 280, 200, 100, 30)
button_onclick#(btn3#, "SetStrong")

form_show(frm#)

function SetLight(sender#)
  emboss_amount#(emb#, 0.2)
  label_text#(lbl#, "Amount: 0.2")
endfunction

function SetMedium(sender#)
  emboss_amount#(emb#, 0.5)
  label_text#(lbl#, "Amount: 0.5")
endfunction

function SetStrong(sender#)
  emboss_amount#(emb#, 0.9)
  label_text#(lbl#, "Amount: 0.9")
endfunction
```

## Example 3: Width Comparison

```basic
let frm# = Pointer#(0)
let rect1# = Pointer#(0)
let rect2# = Pointer#(0)
let rect3# = Pointer#(0)
let emb1# = Pointer#(0)
let emb2# = Pointer#(0)
let emb3# = Pointer#(0)

frm# = form#("Emboss Width", 500, 280)

' Thin width
rect1# = rectangle#(frm#)
rectangle_bounds#(rect1#, 40, 60, 120, 100)
rectangle_fill#(rect1#, "Silver")
emb1# = emboss#(rect1#)
emboss_amount#(emb1#, 0.5)
emboss_width#(emb1#, 1)
let lbl1# = label#(frm#, "Width: 1", 70, 170)

' Medium width
rect2# = rectangle#(frm#)
rectangle_bounds#(rect2#, 190, 60, 120, 100)
rectangle_fill#(rect2#, "Silver")
emb2# = emboss#(rect2#)
emboss_amount#(emb2#, 0.5)
emboss_width#(emb2#, 3)
let lbl2# = label#(frm#, "Width: 3", 220, 170)

' Wide width
rect3# = rectangle#(frm#)
rectangle_bounds#(rect3#, 340, 60, 120, 100)
rectangle_fill#(rect3#, "Silver")
emb3# = emboss#(rect3#)
emboss_amount#(emb3#, 0.5)
emboss_width#(emb3#, 6)
let lbl3# = label#(frm#, "Width: 6", 370, 170)

form_show(frm#)
```

## Notes

- Works best on gray or neutral-colored controls
- Combines well with bevel effects
- Use moderate values for subtle 3D appearance

## See Also

- BevelEffectLib - 3D bevel effects
- SharpenEffectLib - Edge sharpening
