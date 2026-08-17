# SepiaEffectLib - Plan9Basic Reference

## Overview

The Sepia Effect applies a warm, brownish tint to any visual control, creating a vintage/antique photograph look.

## Creating a Sepia Effect

```basic
let fx# = Pointer#(0)
let ctrl# = Pointer#(0)

ctrl# = rectangle#(frm#)
rectangle_fill#(ctrl#, "Blue")
fx# = sepia#(ctrl#)
```

## Properties

### sepia_amount# / sepia_amount
Controls the intensity of the sepia effect.

| Value | Effect |
|-------|--------|
| 0.0 | No effect (original colors) |
| 0.5 | Partial sepia (blended) |
| 1.0 | Full sepia (default) |

```basic
' Full vintage look
sepia_amount#(fx#, 1.0)

' Subtle sepia tint
sepia_amount#(fx#, 0.3)

' Get current value
let a = sepia_amount(fx#)
```

### sepia_enabled# / sepia_enabled
Turns the effect on or off.

```basic
sepia_enabled#(fx#, 0)  ' Disable
sepia_enabled#(fx#, 1)  ' Enable
let e = sepia_enabled(fx#)
```

### sepia_trigger# / sepia_trigger$
Sets a conditional trigger.

```basic
sepia_trigger#(fx#, "IsMouseOver=true")
let t$ = sepia_trigger$(fx#)
```

## Error Handling

```basic
let err = sepia_error()
if err <> 0 then
  println sepia_strerror$(err)
endif
sepia_clearerror()
```

## Complete Example

```basic
' Vintage photo effect demo
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let fx# = Pointer#(0)

frm# = form#("Sepia Demo", 400, 300)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 200, 120)
rectangle_fill#(rect#, "LightBlue")

fx# = sepia#(rect#)
sepia_amount#(fx#, 0.8)

' Controls
let btn# = button#(frm#, "Full Sepia")
button_bounds#(btn#, 50, 200, 100, 30)
button_onclick#(btn#, "FullSepia")

btn# = button#(frm#, "No Effect")
button_bounds#(btn#, 160, 200, 100, 30)
button_onclick#(btn#, "NoSepia")

form_show(frm#)

function FullSepia(sender#)
  sepia_amount#(fx#, 1.0)
endfunction

function NoSepia(sender#)
  sepia_amount#(fx#, 0.0)
endfunction
```

## Animation

Amount can be animated for fade-in vintage effect:

```basic
let ani# = Pointer#(0)
ani# = floatani#(fx#)
floatani_propertyname#(ani#, "Amount")
floatani_startvalue#(ani#, 0.0)
floatani_stopvalue#(ani#, 1.0)
floatani_duration#(ani#, 2.0)
floatani_start(ani#)
```

## Function Summary

| Function | Description |
|----------|-------------|
| `sepia#(parent#)` | Create effect on control |
| `sepia_free(fx#)` | Remove and destroy effect |
| `sepia_amount#(fx#, n)` | Set amount (0-1) |
| `sepia_amount(fx#)` | Get amount value |
| `sepia_enabled#(fx#, n)` | Enable (1) or disable (0) |
| `sepia_enabled(fx#)` | Get enabled state |
| `sepia_trigger#(fx#, s$)` | Set trigger string |
| `sepia_trigger$(fx#)` | Get trigger string |
| `sepia_error()` | Get last error code |
| `sepia_errormsg$()` | Get last error message |
| `sepia_strerror$(n)` | Convert error code to text |
| `sepia_clearerror()` | Clear error state |
