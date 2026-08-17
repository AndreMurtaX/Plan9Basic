# SaturationEffectLib - Plan9Basic Reference

## Overview

The Saturation Effect adjusts the color intensity of any visual control. Use it to make colors more vivid or create grayscale effects.

## Creating a Saturation Effect

```basic
let fx# = Pointer#(0)
let ctrl# = Pointer#(0)

ctrl# = rectangle#(frm#)
rectangle_fill#(ctrl#, "Red")
fx# = saturation#(ctrl#)
```

## Properties

### saturation_saturation# / saturation_saturation
Adjusts the color saturation level.

| Value | Effect |
|-------|--------|
| -1.0 | Completely desaturated (grayscale) |
| 0.0 | Normal saturation (default) |
| 1.0 | Maximum saturation (vivid colors) |

```basic
' Make colors more vivid
saturation_saturation#(fx#, 0.5)

' Convert to grayscale
saturation_saturation#(fx#, -1.0)

' Get current value
let s = saturation_saturation(fx#)
```

### saturation_enabled# / saturation_enabled
Turns the effect on or off.

```basic
' Disable effect
saturation_enabled#(fx#, 0)

' Enable effect
saturation_enabled#(fx#, 1)

' Check if enabled
let e = saturation_enabled(fx#)
```

### saturation_trigger# / saturation_trigger$
Sets a conditional trigger for automatic activation.

```basic
' Activate on hover
saturation_trigger#(fx#, "IsMouseOver=true")

' Get current trigger
let t$ = saturation_trigger$(fx#)
```

## Error Handling

```basic
let err = saturation_error()
if err <> 0 then
  println "Error: " + saturation_strerror$(err)
endif

saturation_clearerror()
```

## Cleanup

```basic
saturation_free(fx#)
```

## Complete Example

```basic
' Saturation adjustment demo
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let fx# = Pointer#(0)

frm# = form#("Saturation Demo", 400, 300)

' Create a colorful rectangle
rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 200, 150)
rectangle_fill#(rect#, "Orange")

' Apply saturation effect
fx# = saturation#(rect#)
saturation_saturation#(fx#, 0.5)  ' More vivid

' Control buttons
let btn# = button#(frm#, "Grayscale")
button_bounds#(btn#, 50, 220, 100, 30)
button_onclick#(btn#, "MakeGray")

btn# = button#(frm#, "Vivid")
button_bounds#(btn#, 160, 220, 100, 30)
button_onclick#(btn#, "MakeVivid")

form_show(frm#)

function MakeGray(sender#)
  saturation_saturation#(fx#, -1.0)
endfunction

function MakeVivid(sender#)
  saturation_saturation#(fx#, 1.0)
endfunction
```

## Animation

Saturation can be animated for smooth transitions:

```basic
let ani# = Pointer#(0)
ani# = floatani#(fx#)
floatani_propertyname#(ani#, "Saturation")
floatani_startvalue#(ani#, -1.0)
floatani_stopvalue#(ani#, 1.0)
floatani_duration#(ani#, 2.0)
floatani_autoreverse#(ani#, 1)
floatani_start(ani#)
```

## Function Summary

| Function | Description |
|----------|-------------|
| `saturation#(parent#)` | Create effect on control |
| `saturation_free(fx#)` | Remove and destroy effect |
| `saturation_saturation#(fx#, n)` | Set saturation (-1 to 1) |
| `saturation_saturation(fx#)` | Get saturation value |
| `saturation_enabled#(fx#, n)` | Enable (1) or disable (0) |
| `saturation_enabled(fx#)` | Get enabled state |
| `saturation_trigger#(fx#, s$)` | Set trigger string |
| `saturation_trigger$(fx#)` | Get trigger string |
| `saturation_error()` | Get last error code |
| `saturation_errormsg$()` | Get last error message |
| `saturation_strerror$(n)` | Convert error code to text |
| `saturation_clearerror()` | Clear error state |
