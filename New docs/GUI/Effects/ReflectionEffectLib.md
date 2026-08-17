# ReflectionEffectLib

Creates mirror-like reflections below visual controls, similar to iOS-style glossy effects.

## Functions

| Function | Description |
|----------|-------------|
| `reflection#(parent#)` | Creates reflection effect on control |
| `reflection_free(effect#)` | Destroys the effect |
| `reflection_length#(effect#, value)` | Sets reflection height (0.0-1.0) |
| `reflection_length(effect#)` | Gets length value |
| `reflection_opacity#(effect#, value)` | Sets opacity (0.0-1.0) |
| `reflection_opacity(effect#)` | Gets opacity value |
| `reflection_offset#(effect#, pixels)` | Sets gap from control |
| `reflection_offset(effect#)` | Gets offset value |
| `reflection_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `reflection_enabled(effect#)` | Gets enabled state |
| `reflection_trigger#(effect#, trigger$)` | Sets trigger string |
| `reflection_trigger$(effect#)` | Gets trigger string |
| `reflection_error()` | Returns last error code |
| `reflection_errormsg$()` | Returns last error message |
| `reflection_strerror$(code)` | Converts error code to text |
| `reflection_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Length | 0.0 - 1.0 | 0.5 | Portion of control reflected |
| Opacity | 0.0 - 1.0 | 0.5 | Reflection transparency |
| Offset | 0+ pixels | 0 | Gap between control and reflection |

## Example 1: Basic Reflection

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let refl# = Pointer#(0)

frm# = form#("Reflection Demo", 400, 350)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 50, 200, 100)
rectangle_fill#(rect#, "SteelBlue")

refl# = reflection#(rect#)
reflection_length#(refl#, 0.5)
reflection_opacity#(refl#, 0.4)
reflection_offset#(refl#, 2)

form_show(frm#)
```

## Example 2: Reflection Controls

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let refl# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Reflection Controls", 450, 380)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 125, 40, 200, 100)
rectangle_fill#(rect#, "Navy")

refl# = reflection#(rect#)
reflection_length#(refl#, 0.5)
reflection_opacity#(refl#, 0.5)

lbl# = label#(frm#, "Length: 50%  Opacity: 50%", 120, 220)

' Length buttons
let btn1# = button#(frm#, "Len 25%")
button_bounds#(btn1#, 40, 260, 80, 30)
button_onclick#(btn1#, "SetLen25")

let btn2# = button#(frm#, "Len 50%")
button_bounds#(btn2#, 130, 260, 80, 30)
button_onclick#(btn2#, "SetLen50")

let btn3# = button#(frm#, "Len 75%")
button_bounds#(btn3#, 220, 260, 80, 30)
button_onclick#(btn3#, "SetLen75")

' Opacity buttons
let btn4# = button#(frm#, "Op 30%")
button_bounds#(btn4#, 40, 300, 80, 30)
button_onclick#(btn4#, "SetOp30")

let btn5# = button#(frm#, "Op 60%")
button_bounds#(btn5#, 130, 300, 80, 30)
button_onclick#(btn5#, "SetOp60")

let btn6# = button#(frm#, "Toggle")
button_bounds#(btn6#, 220, 300, 80, 30)
button_onclick#(btn6#, "Toggle")

form_show(frm#)

function SetLen25(sender#)
  reflection_length#(refl#, 0.25)
  label_text#(lbl#, "Length: 25%")
endfunction

function SetLen50(sender#)
  reflection_length#(refl#, 0.50)
  label_text#(lbl#, "Length: 50%")
endfunction

function SetLen75(sender#)
  reflection_length#(refl#, 0.75)
  label_text#(lbl#, "Length: 75%")
endfunction

function SetOp30(sender#)
  reflection_opacity#(refl#, 0.30)
  label_text#(lbl#, "Opacity: 30%")
endfunction

function SetOp60(sender#)
  reflection_opacity#(refl#, 0.60)
  label_text#(lbl#, "Opacity: 60%")
endfunction

function Toggle(sender#)
  if reflection_enabled(refl#) = 1 then
    reflection_enabled#(refl#, 0)
    label_text#(lbl#, "Reflection: OFF")
  else
    reflection_enabled#(refl#, 1)
    label_text#(lbl#, "Reflection: ON")
  endif
endfunction
```

## Example 3: Gallery with Reflections

```basic
let frm# = Pointer#(0)

frm# = form#("Reflection Gallery", 500, 350)

' Create 3 items with reflections
let rect1# = rectangle#(frm#)
rectangle_bounds#(rect1#, 50, 50, 120, 80)
rectangle_fill#(rect1#, "Red")
let refl1# = reflection#(rect1#)
reflection_length#(refl1#, 0.4)
reflection_opacity#(refl1#, 0.3)

let rect2# = rectangle#(frm#)
rectangle_bounds#(rect2#, 190, 50, 120, 80)
rectangle_fill#(rect2#, "Green")
let refl2# = reflection#(rect2#)
reflection_length#(refl2#, 0.4)
reflection_opacity#(refl2#, 0.3)

let rect3# = rectangle#(frm#)
rectangle_bounds#(rect3#, 330, 50, 120, 80)
rectangle_fill#(rect3#, "Blue")
let refl3# = reflection#(rect3#)
reflection_length#(refl3#, 0.4)
reflection_opacity#(refl3#, 0.3)

form_show(frm#)
```

## Tips

- Use subtle opacity (0.2-0.4) for professional appearance
- Keep length moderate (0.3-0.5) for realistic look
- Add small offset (2-4 pixels) for visual separation
- Works best on solid colored shapes

## See Also

- ShadowEffectLib - Drop shadow effects
- GlowEffectLib - Outer glow effects
