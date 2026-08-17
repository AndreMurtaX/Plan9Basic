# FillRGBEffectLib

Fills a visual control with a solid color overlay using an ARGB color value. Similar to FillEffectLib but uses numeric color values.

## Functions

| Function | Description |
|----------|-------------|
| `fillrgb#(parent#)` | Creates fill RGB effect on control |
| `fillrgb_free(effect#)` | Destroys the effect |
| `fillrgb_color#(effect#, color)` | Sets fill color (ARGB number) |
| `fillrgb_color(effect#)` | Gets fill color |
| `fillrgb_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `fillrgb_enabled(effect#)` | Gets enabled state |
| `fillrgb_trigger#(effect#, trigger$)` | Sets trigger string |
| `fillrgb_trigger$(effect#)` | Gets trigger string |
| `fillrgb_error()` | Returns last error code |
| `fillrgb_errormsg$()` | Returns last error message |
| `fillrgb_strerror$(code)` | Converts error code to text |
| `fillrgb_clearerror()` | Clears error state |

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Color | Number (ARGB) | White | Fill color as ARGB value |

## Color Values (ARGB)

Colors are specified as ARGB numbers:
- White: 4294967295 ($FFFFFFFF)
- Black: 4278190080 ($FF000000)
- Red: 4294901760 ($FFFF0000)
- Green: 4278255360 ($FF00FF00)
- Blue: 4278190335 ($FF0000FF)
- Yellow: 4294967040 ($FFFFFF00)
- Cyan: 4278255615 ($FF00FFFF)
- Magenta: 4294902015 ($FFFF00FF)

## Example 1: Basic Fill RGB

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let fl# = Pointer#(0)

frm# = form#("Fill RGB Demo", 400, 320)

img# = image#(frm#)
image_bounds#(img#, 100, 40, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

fl# = fillrgb#(img#)
fillrgb_color#(fl#, 4294901760)  ' Red

form_show(frm#)
```

## Example 2: Color Switcher

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let fl# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Fill RGB Colors", 450, 380)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

fl# = fillrgb#(img#)
fillrgb_enabled#(fl#, 0)

lbl# = label#(frm#, "Fill: Off", 180, 200)

let btn1# = button#(frm#, "Off")
button_bounds#(btn1#, 40, 240, 80, 30)
button_onclick#(btn1#, "SetOff")

let btn2# = button#(frm#, "Red")
button_bounds#(btn2#, 130, 240, 80, 30)
button_onclick#(btn2#, "SetRed")

let btn3# = button#(frm#, "Green")
button_bounds#(btn3#, 220, 240, 80, 30)
button_onclick#(btn3#, "SetGreen")

let btn4# = button#(frm#, "Blue")
button_bounds#(btn4#, 310, 240, 80, 30)
button_onclick#(btn4#, "SetBlue")

form_show(frm#)

function SetOff(sender#)
  fillrgb_enabled#(fl#, 0)
  label_text#(lbl#, "Fill: Off")
endfunction

function SetRed(sender#)
  fillrgb_color#(fl#, 4294901760)
  fillrgb_enabled#(fl#, 1)
  label_text#(lbl#, "Fill: Red")
endfunction

function SetGreen(sender#)
  fillrgb_color#(fl#, 4278255360)
  fillrgb_enabled#(fl#, 1)
  label_text#(lbl#, "Fill: Green")
endfunction

function SetBlue(sender#)
  fillrgb_color#(fl#, 4278190335)
  fillrgb_enabled#(fl#, 1)
  label_text#(lbl#, "Fill: Blue")
endfunction
```

## Example 3: Toggle Fill

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let fl# = Pointer#(0)

frm# = form#("Toggle Fill", 400, 320)

img# = image#(frm#)
image_bounds#(img#, 100, 40, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

fl# = fillrgb#(img#)
fillrgb_color#(fl#, 4294967040)  ' Yellow
fillrgb_enabled#(fl#, 0)

let btn# = button#(frm#, "Toggle Fill")
button_bounds#(btn#, 130, 220, 120, 35)
button_onclick#(btn#, "OnToggle")

form_show(frm#)

function OnToggle(sender#)
  if fillrgb_enabled(fl#) = 1 then
    fillrgb_enabled#(fl#, 0)
  else
    fillrgb_enabled#(fl#, 1)
  endif
endfunction
```

## Notes

- Replaces all pixels with the specified color
- Use enabled property to toggle effect on/off
- Color is specified as ARGB number

## See Also

- FillEffectLib - Similar fill effect
- MonochromeEffectLib - Convert to single color
