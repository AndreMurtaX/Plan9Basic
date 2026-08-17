# HueAdjustEffectLib

Shifts the hue (color) of visual controls around the color wheel. Use for color correction or creative color effects.

## Functions

| Function | Description |
|----------|-------------|
| `hueadjust#(parent#)` | Creates hue adjust effect on control |
| `hueadjust_free(effect#)` | Destroys the effect |
| `hueadjust_hue#(effect#, value)` | Sets hue shift (-1.0 to 1.0) |
| `hueadjust_hue(effect#)` | Gets hue value |
| `hueadjust_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `hueadjust_enabled(effect#)` | Gets enabled state |
| `hueadjust_trigger#(effect#, trigger$)` | Sets trigger string |
| `hueadjust_trigger$(effect#)` | Gets trigger string |
| `hueadjust_error()` | Returns last error code |
| `hueadjust_errormsg$()` | Returns last error message |
| `hueadjust_strerror$(code)` | Converts error code to text |
| `hueadjust_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Hue | -1.0 to 1.0 | 0.0 | Hue rotation amount |

## Hue Values

| Value | Effect |
|-------|--------|
| 0.0 | No change (original colors) |
| 0.33 | Shift by ~120 degrees (red → green → blue) |
| 0.5 | Shift by 180 degrees (complementary colors) |
| -0.33 | Shift opposite direction |
| 1.0 / -1.0 | Full rotation (same as original) |

## Example 1: Basic Hue Shift

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let hue# = Pointer#(0)

frm# = form#("Hue Adjust Demo", 400, 300)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 80, 200, 120)
rectangle_fill#(rect#, "Red")

hue# = hueadjust#(rect#)
hueadjust_hue#(hue#, 0.33)

form_show(frm#)
```

## Example 2: Hue Control

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let hue# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Hue Control", 500, 320)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 150, 40, 200, 100)
rectangle_fill#(rect#, "Red")

hue# = hueadjust#(rect#)
hueadjust_hue#(hue#, 0)

lbl# = label#(frm#, "Hue: 0 (Original)", 170, 160)

let btn1# = button#(frm#, "Original")
button_bounds#(btn1#, 30, 200, 85, 30)
button_onclick#(btn1#, "SetOriginal")

let btn2# = button#(frm#, "+0.17")
button_bounds#(btn2#, 125, 200, 85, 30)
button_onclick#(btn2#, "SetHue1")

let btn3# = button#(frm#, "+0.33")
button_bounds#(btn3#, 220, 200, 85, 30)
button_onclick#(btn3#, "SetHue2")

let btn4# = button#(frm#, "+0.5")
button_bounds#(btn4#, 315, 200, 85, 30)
button_onclick#(btn4#, "SetHue3")

let btn5# = button#(frm#, "-0.33")
button_bounds#(btn5#, 410, 200, 85, 30)
button_onclick#(btn5#, "SetHue4")

form_show(frm#)

function SetOriginal(sender#)
  hueadjust_hue#(hue#, 0)
  label_text#(lbl#, "Hue: 0 (Original)")
endfunction

function SetHue1(sender#)
  hueadjust_hue#(hue#, 0.17)
  label_text#(lbl#, "Hue: +0.17")
endfunction

function SetHue2(sender#)
  hueadjust_hue#(hue#, 0.33)
  label_text#(lbl#, "Hue: +0.33")
endfunction

function SetHue3(sender#)
  hueadjust_hue#(hue#, 0.5)
  label_text#(lbl#, "Hue: +0.5 (Complementary)")
endfunction

function SetHue4(sender#)
  hueadjust_hue#(hue#, -0.33)
  label_text#(lbl#, "Hue: -0.33")
endfunction
```

## Example 3: Color Shift Gallery

```basic
let frm# = Pointer#(0)
let rect1# = Pointer#(0)
let rect2# = Pointer#(0)
let rect3# = Pointer#(0)
let hue1# = Pointer#(0)
let hue2# = Pointer#(0)
let hue3# = Pointer#(0)

frm# = form#("Color Shift Gallery", 500, 280)

' Original
rect1# = rectangle#(frm#)
rectangle_bounds#(rect1#, 40, 60, 120, 100)
rectangle_fill#(rect1#, "Red")
let lbl1# = label#(frm#, "Original", 70, 170)

' +0.33 shift
rect2# = rectangle#(frm#)
rectangle_bounds#(rect2#, 190, 60, 120, 100)
rectangle_fill#(rect2#, "Red")
hue2# = hueadjust#(rect2#)
hueadjust_hue#(hue2#, 0.33)
let lbl2# = label#(frm#, "Hue +0.33", 215, 170)

' +0.66 shift
rect3# = rectangle#(frm#)
rectangle_bounds#(rect3#, 340, 60, 120, 100)
rectangle_fill#(rect3#, "Red")
hue3# = hueadjust#(rect3#)
hueadjust_hue#(hue3#, 0.66)
let lbl3# = label#(frm#, "Hue +0.66", 365, 170)

form_show(frm#)
```

## Notes

- Works on all colors in the control
- Value of 0.5 creates complementary colors
- Full rotation (1.0 or -1.0) returns to original color
- Use for creative color themes or corrections

## See Also

- ContrastEffectLib - Contrast adjustment
- MonochromeEffectLib - Convert to single color
