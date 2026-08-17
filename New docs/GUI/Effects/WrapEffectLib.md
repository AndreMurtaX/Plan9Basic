# WrapEffectLib

Applies a wrap/warp distortion effect using bezier curve control points. Allows bending and warping images along a curved path.

## Functions

| Function | Description |
|----------|-------------|
| `wrap#(parent#)` | Creates wrap effect on control |
| `wrap_free(effect#)` | Destroys the effect |
| `wrap_leftstart#(effect#, value)` | Sets left edge start point |
| `wrap_leftstart(effect#)` | Gets left start value |
| `wrap_leftctrl1#(effect#, value)` | Sets first control point |
| `wrap_leftctrl1(effect#)` | Gets control 1 value |
| `wrap_leftctrl2#(effect#, value)` | Sets second control point |
| `wrap_leftctrl2(effect#)` | Gets control 2 value |
| `wrap_leftend#(effect#, value)` | Sets left edge end point |
| `wrap_leftend(effect#)` | Gets left end value |
| `wrap_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `wrap_enabled(effect#)` | Gets enabled state |
| `wrap_trigger#(effect#, trigger$)` | Sets trigger string |
| `wrap_trigger$(effect#)` | Gets trigger string |
| `wrap_error()` | Returns last error code |
| `wrap_errormsg$()` | Returns last error message |
| `wrap_strerror$(code)` | Converts error code to text |
| `wrap_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| LeftStart | 0.0 - 1.0 | 0.0 | Bezier start point |
| LeftControl1 | 0.0 - 1.0 | 0.33 | First bezier control point |
| LeftControl2 | 0.0 - 1.0 | 0.66 | Second bezier control point |
| LeftEnd | 0.0 - 1.0 | 1.0 | Bezier end point |

## Example 1: Basic Wrap Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let wrap# = Pointer#(0)

frm# = form#("Wrap Effect Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Apply wrap effect
wrap# = wrap#(img#)
wrap_leftstart#(wrap#, 0)
wrap_leftctrl1#(wrap#, 0.2)
wrap_leftctrl2#(wrap#, 0.8)
wrap_leftend#(wrap#, 1)

form_show(frm#)
```

## Example 2: Adjustable Wrap Curve

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let wrap# = Pointer#(0)
let trkC1# = Pointer#(0)
let trkC2# = Pointer#(0)
let lblC1# = Pointer#(0)
let lblC2# = Pointer#(0)

frm# = form#("Wrap Control", 500, 450)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

wrap# = wrap#(img#)

' Control 1 slider
lblC1# = label#(frm#, "Control 1: 0.33", 30, 190)
trkC1# = trackbar#(frm#)
trackbar_bounds#(trkC1#, 30, 215, 440, 25)
trackbar_max#(trkC1#, 100)
trackbar_value#(trkC1#, 33)
trackbar_onchange#(trkC1#, "OnControl1")

' Control 2 slider
lblC2# = label#(frm#, "Control 2: 0.66", 30, 260)
trkC2# = trackbar#(frm#)
trackbar_bounds#(trkC2#, 30, 285, 440, 25)
trackbar_max#(trkC2#, 100)
trackbar_value#(trkC2#, 66)
trackbar_onchange#(trkC2#, "OnControl2")

form_show(frm#)

function OnControl1(sender#) local c
  let c = trackbar_value(trkC1#) / 100
  wrap_leftctrl1#(wrap#, c)
  label_text#(lblC1#, "Control 1: " + stri$(c, 2))
endfunction

function OnControl2(sender#) local c
  let c = trackbar_value(trkC2#) / 100
  wrap_leftctrl2#(wrap#, c)
  label_text#(lblC2#, "Control 2: " + stri$(c, 2))
endfunction
```

## Example 3: Toggle Wrap Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let wrap# = Pointer#(0)
let btn# = Pointer#(0)
let isOn = 1

frm# = form#("Toggle Wrap", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

wrap# = wrap#(img#)
wrap_leftctrl1#(wrap#, 0.1)
wrap_leftctrl2#(wrap#, 0.9)

btn# = button#(frm#, "Disable Effect")
button_bounds#(btn#, 130, 210, 140, 30)
button_onclick#(btn#, "Toggle")

form_show(frm#)

function Toggle(sender#)
  if isOn = 1 then
    wrap_enabled#(wrap#, 0)
    isOn = 0
    button_text#(btn#, "Enable Effect")
  else
    wrap_enabled#(wrap#, 1)
    isOn = 1
    button_text#(btn#, "Disable Effect")
  endif
endfunction
```

## Notes

- Control points define a bezier curve for warping
- Values are normalized 0.0 to 1.0
- Adjusting control points creates different bend shapes
- Good for creating page curl or wave-like distortions

## See Also

- PinchEffectLib - Pinch/bulge distortion
- SwirlEffectLib - Swirl distortion
- WaveEffectLib - Wave distortion
