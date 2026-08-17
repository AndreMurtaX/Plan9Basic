# FillEffectLib

Fills a visual control with a solid color overlay. Useful for color tinting or masking effects.

## Functions

| Function | Description |
|----------|-------------|
| `fill#(parent#)` | Creates fill effect on control |
| `fill_free(effect#)` | Destroys the effect |
| `fill_color#(effect#, color)` | Sets fill color (as number) |
| `fill_color(effect#)` | Gets fill color |
| `fill_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `fill_enabled(effect#)` | Gets enabled state |
| `fill_trigger#(effect#, trigger$)` | Sets trigger string |
| `fill_trigger$(effect#)` | Gets trigger string |
| `fill_error()` | Returns last error code |
| `fill_errormsg$()` | Returns last error message |
| `fill_strerror$(code)` | Converts error code to text |
| `fill_clearerror()` | Clears error state |

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Color | Number (TAlphaColor) | White | Fill color as ARGB value |

## Color Values

Colors are specified as ARGB numbers. Common values:
- White: 4294967295 ($FFFFFFFF)
- Black: 4278190080 ($FF000000)
- Red: 4294901760 ($FFFF0000)
- Green: 4278255360 ($FF00FF00)
- Blue: 4278190335 ($FF0000FF)

## Example 1: Basic Fill

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let fl# = Pointer#(0)

frm# = form#("Fill Demo", 400, 300)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 80, 200, 120)
rectangle_fill#(rect#, "SteelBlue")

fl# = fill#(rect#)
fill_color#(fl#, 4294901760)  ' Red

form_show(frm#)
```

## Example 2: Color Toggle

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let fl# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Fill Colors", 450, 320)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 125, 40, 200, 100)
rectangle_fill#(rect#, "Gray")

fl# = fill#(rect#)
fill_enabled#(fl#, 0)

lbl# = label#(frm#, "Fill: Off", 180, 160)

let btn1# = button#(frm#, "Off")
button_bounds#(btn1#, 40, 200, 80, 30)
button_onclick#(btn1#, "SetOff")

let btn2# = button#(frm#, "Red")
button_bounds#(btn2#, 130, 200, 80, 30)
button_onclick#(btn2#, "SetRed")

let btn3# = button#(frm#, "Green")
button_bounds#(btn3#, 220, 200, 80, 30)
button_onclick#(btn3#, "SetGreen")

let btn4# = button#(frm#, "Blue")
button_bounds#(btn4#, 310, 200, 80, 30)
button_onclick#(btn4#, "SetBlue")

form_show(frm#)

function SetOff(sender#)
  fill_enabled#(fl#, 0)
  label_text#(lbl#, "Fill: Off")
endfunction

function SetRed(sender#)
  fill_color#(fl#, 4294901760)
  fill_enabled#(fl#, 1)
  label_text#(lbl#, "Fill: Red")
endfunction

function SetGreen(sender#)
  fill_color#(fl#, 4278255360)
  fill_enabled#(fl#, 1)
  label_text#(lbl#, "Fill: Green")
endfunction

function SetBlue(sender#)
  fill_color#(fl#, 4278190335)
  fill_enabled#(fl#, 1)
  label_text#(lbl#, "Fill: Blue")
endfunction
```

## Example 3: Fill Gallery

```basic
let frm# = Pointer#(0)
let rect1# = Pointer#(0)
let rect2# = Pointer#(0)
let rect3# = Pointer#(0)
let fl1# = Pointer#(0)
let fl2# = Pointer#(0)
let fl3# = Pointer#(0)

frm# = form#("Fill Gallery", 500, 280)

' Red fill
rect1# = rectangle#(frm#)
rectangle_bounds#(rect1#, 40, 60, 120, 100)
rectangle_fill#(rect1#, "Gray")
fl1# = fill#(rect1#)
fill_color#(fl1#, 4294901760)
let lbl1# = label#(frm#, "Red Fill", 70, 170)

' Green fill
rect2# = rectangle#(frm#)
rectangle_bounds#(rect2#, 190, 60, 120, 100)
rectangle_fill#(rect2#, "Gray")
fl2# = fill#(rect2#)
fill_color#(fl2#, 4278255360)
let lbl2# = label#(frm#, "Green Fill", 215, 170)

' Blue fill
rect3# = rectangle#(frm#)
rectangle_bounds#(rect3#, 340, 60, 120, 100)
rectangle_fill#(rect3#, "Gray")
fl3# = fill#(rect3#)
fill_color#(fl3#, 4278190335)
let lbl3# = label#(frm#, "Blue Fill", 365, 170)

form_show(frm#)
```

## Notes

- Fill replaces all pixels with the specified color
- Use enabled property to toggle effect on/off
- Color is specified as ARGB number, not color name
- For color tinting, consider using other effects instead

## See Also

- FillRGBEffectLib - Fill with RGB components
- MonochromeEffectLib - Convert to single color
