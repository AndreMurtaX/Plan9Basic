# InvertEffectLib - Plan9Basic Reference

## Overview

The Invert Effect creates a photographic negative by inverting all colors in a visual control. Black becomes white, red becomes cyan, etc.

## Creating an Invert Effect

```basic
let fx# = Pointer#(0)
let ctrl# = Pointer#(0)

ctrl# = rectangle#(frm#)
rectangle_fill#(ctrl#, "Red")
fx# = invert#(ctrl#)
' Red rectangle now appears cyan
```

## Properties

### invert_enabled# / invert_enabled
Turns the effect on or off. This is a simple binary effect with no intensity control.

```basic
' Disable (show original colors)
invert_enabled#(fx#, 0)

' Enable (show inverted colors)
invert_enabled#(fx#, 1)

' Check state
let e = invert_enabled(fx#)
```

### invert_trigger# / invert_trigger$
Sets a conditional trigger.

```basic
' Invert on hover
invert_trigger#(fx#, "IsMouseOver=true")

' Get current trigger
let t$ = invert_trigger$(fx#)
```

## Color Inversions

When enabled, colors are inverted:

| Original | Inverted |
|----------|----------|
| Black | White |
| White | Black |
| Red | Cyan |
| Green | Magenta |
| Blue | Yellow |
| Orange | Blue |

## Error Handling

```basic
let err = invert_error()
if err <> 0 then
  println invert_strerror$(err)
endif
invert_clearerror()
```

## Complete Example

```basic
' Color inversion demo
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let fx# = Pointer#(0)

frm# = form#("Invert Demo", 400, 300)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 200, 100)
rectangle_fill#(rect#, "Red")

fx# = invert#(rect#)
invert_enabled#(fx#, 0)  ' Start with original colors

let btn# = button#(frm#, "Toggle Invert")
button_bounds#(btn#, 50, 180, 120, 30)
button_onclick#(btn#, "ToggleInvert")

form_show(frm#)

function ToggleInvert(sender#) local e
  e = invert_enabled(fx#)
  if e = 1 then
    invert_enabled#(fx#, 0)
  else
    invert_enabled#(fx#, 1)
  endif
endfunction
```

## Hover-Based Inversion

```basic
' Rectangle inverts when mouse hovers
let rect# = rectangle#(frm#)
rectangle_fill#(rect#, "Blue")

let fx# = invert#(rect#)
invert_trigger#(fx#, "IsMouseOver=true")
```

## Function Summary

| Function | Description |
|----------|-------------|
| `invert#(parent#)` | Create effect on control |
| `invert_free(fx#)` | Remove and destroy effect |
| `invert_enabled#(fx#, n)` | Enable (1) or disable (0) |
| `invert_enabled(fx#)` | Get enabled state |
| `invert_trigger#(fx#, s$)` | Set trigger string |
| `invert_trigger$(fx#)` | Get trigger string |
| `invert_error()` | Get last error code |
| `invert_errormsg$()` | Get last error message |
| `invert_strerror$(n)` | Convert error code to text |
| `invert_clearerror()` | Clear error state |

## Notes

- This is a binary effect (on/off only)
- No amount/intensity parameter - colors are either inverted or not
- Useful for creating negative image effects
- Can be combined with other effects
