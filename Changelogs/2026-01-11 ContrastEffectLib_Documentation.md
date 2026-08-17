# ContrastEffectLib - Plan9Basic Reference

## Overview

The Contrast Effect adjusts the contrast and brightness of any visual control. Use it to make images and UI elements appear more vivid or washed out.

## Creating a Contrast Effect

```basic
let fx# = Pointer#(0)
let ctrl# = Pointer#(0)

ctrl# = button#(frm#, "My Button")
fx# = contrast#(ctrl#)
```

## Properties

### contrast_contrast# / contrast_contrast
Adjusts the contrast level.

| Value | Effect |
|-------|--------|
| 0.0 | No contrast (flat gray) |
| 1.0 | Normal (default) |
| 2.0 | Maximum contrast |

```basic
' Set high contrast
contrast_contrast#(fx#, 1.5)

' Get current value
let c = contrast_contrast(fx#)
```

### contrast_brightness# / contrast_brightness
Adjusts the brightness level.

| Value | Effect |
|-------|--------|
| -1.0 | Completely dark |
| 0.0 | Normal (default) |
| 1.0 | Completely bright |

```basic
' Increase brightness
contrast_brightness#(fx#, 0.3)

' Get current value
let b = contrast_brightness(fx#)
```

### contrast_enabled# / contrast_enabled
Turns the effect on or off.

```basic
' Disable effect
contrast_enabled#(fx#, 0)

' Enable effect
contrast_enabled#(fx#, 1)

' Check if enabled
let e = contrast_enabled(fx#)
```

### contrast_trigger# / contrast_trigger$
Sets a conditional trigger for automatic activation.

```basic
' Activate on hover
contrast_trigger#(fx#, "IsMouseOver=true")

' Get current trigger
let t$ = contrast_trigger$(fx#)

' Clear trigger
contrast_trigger#(fx#, "")
```

## Error Handling

```basic
' Check for errors after operations
let err = contrast_error()
if err <> 0 then
  println "Error: " + contrast_strerror$(err)
endif

' Clear error state
contrast_clearerror()

' Get detailed error message
let msg$ = contrast_errormsg$()
```

## Cleanup

```basic
' Remove and destroy effect
contrast_free(fx#)
```

## Complete Example

```basic
' Contrast adjustment demo
let frm# = Pointer#(0)
let img# = Pointer#(0)
let fx# = Pointer#(0)

frm# = form#("Contrast Demo", 400, 300)

' Create an image or colored rectangle
img# = rectangle#(frm#)
rectangle_bounds#(img#, 50, 50, 200, 150)
rectangle_fill#(img#, "Blue")

' Apply contrast effect
fx# = contrast#(img#)
contrast_contrast#(fx#, 1.3)
contrast_brightness#(fx#, 0.1)

' Button to toggle
let btn# = button#(frm#, "Toggle Effect")
button_bounds#(btn#, 50, 220, 120, 30)
button_onclick#(btn#, "ToggleFx")

form_show(frm#)

function ToggleFx(sender#) local e
  e = contrast_enabled(fx#)
  if e = 1 then
    contrast_enabled#(fx#, 0)
  else
    contrast_enabled#(fx#, 1)
  endif
endfunction
```

## Animation

Contrast properties can be animated:

```basic
let ani# = Pointer#(0)
ani# = floatani#(fx#)
floatani_propertyname#(ani#, "Contrast")
floatani_startvalue#(ani#, 1.0)
floatani_stopvalue#(ani#, 2.0)
floatani_duration#(ani#, 1.0)
floatani_autoreverse#(ani#, 1)
floatani_start(ani#)
```

## Function Summary

| Function | Description |
|----------|-------------|
| `contrast#(parent#)` | Create effect on control |
| `contrast_free(fx#)` | Remove and destroy effect |
| `contrast_contrast#(fx#, n)` | Set contrast (0-2) |
| `contrast_contrast(fx#)` | Get contrast value |
| `contrast_brightness#(fx#, n)` | Set brightness (-1 to 1) |
| `contrast_brightness(fx#)` | Get brightness value |
| `contrast_enabled#(fx#, n)` | Enable (1) or disable (0) |
| `contrast_enabled(fx#)` | Get enabled state |
| `contrast_trigger#(fx#, s$)` | Set trigger string |
| `contrast_trigger$(fx#)` | Get trigger string |
| `contrast_error()` | Get last error code |
| `contrast_errormsg$()` | Get last error message |
| `contrast_strerror$(n)` | Convert error code to text |
| `contrast_clearerror()` | Clear error state |
