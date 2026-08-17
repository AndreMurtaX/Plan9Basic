# HueAdjustEffectLib - Plan9Basic Reference

## Overview

The Hue Adjust Effect shifts the hue of any visual control, rotating colors around the color wheel. Use it to change the overall color scheme of images or UI elements.

## Creating a Hue Adjust Effect

```basic
let fx# = Pointer#(0)
let ctrl# = Pointer#(0)

ctrl# = rectangle#(frm#)
rectangle_fill#(ctrl#, "Red")
fx# = hueadjust#(ctrl#)
```

## Properties

### hueadjust_hue# / hueadjust_hue
Shifts the hue around the color wheel.

| Value | Effect |
|-------|--------|
| -1.0 | Shift 180° (opposite colors) |
| -0.5 | Shift 90° counter-clockwise |
| 0.0 | No shift (default) |
| 0.5 | Shift 90° clockwise |
| 1.0 | Shift 180° (opposite colors) |

Note: -1.0 and 1.0 produce the same result (complementary colors).

**Color wheel relationships:**
- Red → Cyan (at ±1.0)
- Green → Magenta (at ±1.0)
- Blue → Yellow (at ±1.0)

```basic
' Shift to complementary colors
hueadjust_hue#(fx#, 1.0)

' Slight shift
hueadjust_hue#(fx#, 0.2)

' Get current value
let h = hueadjust_hue(fx#)
```

### hueadjust_enabled# / hueadjust_enabled
Turns the effect on or off.

```basic
hueadjust_enabled#(fx#, 0)  ' Disable
hueadjust_enabled#(fx#, 1)  ' Enable
let e = hueadjust_enabled(fx#)
```

### hueadjust_trigger# / hueadjust_trigger$
Sets a conditional trigger.

```basic
hueadjust_trigger#(fx#, "IsMouseOver=true")
let t$ = hueadjust_trigger$(fx#)
```

## Error Handling

```basic
let err = hueadjust_error()
if err <> 0 then
  println hueadjust_strerror$(err)
endif
hueadjust_clearerror()
```

## Complete Example

```basic
' Hue rotation demo
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let fx# = Pointer#(0)

frm# = form#("Hue Adjust Demo", 400, 300)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 200, 100)
rectangle_fill#(rect#, "Red")

fx# = hueadjust#(rect#)

' Button for rainbow animation
let btn# = button#(frm#, "Rainbow")
button_bounds#(btn#, 50, 180, 100, 30)
button_onclick#(btn#, "StartRainbow")

form_show(frm#)

function StartRainbow(sender#) local ani#
  ani# = floatani#(fx#)
  floatani_propertyname#(ani#, "Hue")
  floatani_startvalue#(ani#, -1.0)
  floatani_stopvalue#(ani#, 1.0)
  floatani_duration#(ani#, 3.0)
  floatani_loop#(ani#, 1)
  floatani_start(ani#)
endfunction
```

## Animation

Hue can be animated for rainbow/color cycling effects:

```basic
let ani# = Pointer#(0)
ani# = floatani#(fx#)
floatani_propertyname#(ani#, "Hue")
floatani_startvalue#(ani#, -1.0)
floatani_stopvalue#(ani#, 1.0)
floatani_duration#(ani#, 5.0)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

## Function Summary

| Function | Description |
|----------|-------------|
| `hueadjust#(parent#)` | Create effect on control |
| `hueadjust_free(fx#)` | Remove and destroy effect |
| `hueadjust_hue#(fx#, n)` | Set hue shift (-1 to 1) |
| `hueadjust_hue(fx#)` | Get hue value |
| `hueadjust_enabled#(fx#, n)` | Enable (1) or disable (0) |
| `hueadjust_enabled(fx#)` | Get enabled state |
| `hueadjust_trigger#(fx#, s$)` | Set trigger string |
| `hueadjust_trigger$(fx#)` | Get trigger string |
| `hueadjust_error()` | Get last error code |
| `hueadjust_errormsg$()` | Get last error message |
| `hueadjust_strerror$(n)` | Convert error code to text |
| `hueadjust_clearerror()` | Clear error state |
