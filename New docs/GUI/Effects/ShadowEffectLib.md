# ShadowEffectLib

Creates drop shadow effects for visual controls, adding depth and visual hierarchy to UI elements.

## Functions

| Function | Description |
|----------|-------------|
| `shadow#(parent#)` | Creates shadow effect on control |
| `shadow_free(effect#)` | Destroys the effect |
| `shadow_distance#(effect#, value)` | Sets shadow offset (0-50 pixels) |
| `shadow_distance(effect#)` | Gets distance value |
| `shadow_direction#(effect#, degrees)` | Sets light angle (0-360) |
| `shadow_direction(effect#)` | Gets direction value |
| `shadow_softness#(effect#, value)` | Sets blur (0.0-1.0) |
| `shadow_softness(effect#)` | Gets softness value |
| `shadow_opacity#(effect#, value)` | Sets opacity (0.0-1.0) |
| `shadow_opacity(effect#)` | Gets opacity value |
| `shadow_color#(effect#, color$)` | Sets shadow color |
| `shadow_color(effect#)` | Gets shadow color as number |
| `shadow_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `shadow_enabled(effect#)` | Gets enabled state |
| `shadow_trigger#(effect#, trigger$)` | Sets trigger string |
| `shadow_trigger$(effect#)` | Gets trigger string |
| `shadow_error()` | Returns last error code |
| `shadow_errormsg$()` | Returns last error message |
| `shadow_strerror$(code)` | Converts error code to text |
| `shadow_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Distance | 0 - 50 | 3 | Shadow offset in pixels |
| Direction | 0 - 360 | 45 | Light source angle |
| Softness | 0.0 - 1.0 | 0.3 | Shadow blur amount |
| Opacity | 0.0 - 1.0 | 0.6 | Shadow transparency |
| Color | Color name/hex | Black | Shadow color |

## Direction Values

| Angle | Light Position |
|-------|----------------|
| 45 | Top-right (default) |
| 90 | Top |
| 135 | Top-left |
| 180 | Left |
| 225 | Bottom-left |
| 270 | Bottom |
| 315 | Bottom-right |

## Example 1: Basic Shadow

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let sh# = Pointer#(0)

frm# = form#("Shadow Demo", 400, 300)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 80, 200, 120)
rectangle_fill#(rect#, "White")

sh# = shadow#(rect#)
shadow_distance#(sh#, 5)
shadow_direction#(sh#, 45)
shadow_softness#(sh#, 0.4)
shadow_opacity#(sh#, 0.5)

form_show(frm#)
```

## Example 2: Adjustable Shadow

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let sh# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Shadow Controls", 450, 320)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 125, 40, 200, 100)
rectangle_fill#(rect#, "SteelBlue")

sh# = shadow#(rect#)
shadow_distance#(sh#, 5)
shadow_softness#(sh#, 0.3)

lbl# = label#(frm#, "Distance: 5", 175, 160)

let btn1# = button#(frm#, "Near")
button_bounds#(btn1#, 60, 200, 100, 30)
button_onclick#(btn1#, "SetNear")

let btn2# = button#(frm#, "Medium")
button_bounds#(btn2#, 170, 200, 100, 30)
button_onclick#(btn2#, "SetMedium")

let btn3# = button#(frm#, "Far")
button_bounds#(btn3#, 280, 200, 100, 30)
button_onclick#(btn3#, "SetFar")

form_show(frm#)

function SetNear(sender#)
  shadow_distance#(sh#, 3)
  shadow_softness#(sh#, 0.2)
  label_text#(lbl#, "Distance: 3")
endfunction

function SetMedium(sender#)
  shadow_distance#(sh#, 8)
  shadow_softness#(sh#, 0.4)
  label_text#(lbl#, "Distance: 8")
endfunction

function SetFar(sender#)
  shadow_distance#(sh#, 15)
  shadow_softness#(sh#, 0.6)
  label_text#(lbl#, "Distance: 15")
endfunction
```

## Example 3: Shadow Directions

```basic
let frm# = Pointer#(0)
let rect1# = Pointer#(0)
let rect2# = Pointer#(0)
let sh1# = Pointer#(0)
let sh2# = Pointer#(0)

frm# = form#("Shadow Directions", 450, 250)

' Top-right light (raised look)
rect1# = rectangle#(frm#)
rectangle_bounds#(rect1#, 50, 70, 150, 100)
rectangle_fill#(rect1#, "White")
sh1# = shadow#(rect1#)
shadow_distance#(sh1#, 8)
shadow_direction#(sh1#, 45)
shadow_softness#(sh1#, 0.4)
let lbl1# = label#(frm#, "45 deg (SE)", 80, 180)

' Bottom-left light
rect2# = rectangle#(frm#)
rectangle_bounds#(rect2#, 250, 70, 150, 100)
rectangle_fill#(rect2#, "White")
sh2# = shadow#(rect2#)
shadow_distance#(sh2#, 8)
shadow_direction#(sh2#, 225)
shadow_softness#(sh2#, 0.4)
let lbl2# = label#(frm#, "225 deg (NW)", 275, 180)

form_show(frm#)
```

## Important Notes

- Shadow effects may block mouse events on the parent control
- For interactive controls, consider using outer glow instead
- Works best on shapes (rectangle, circle, etc.) and images

## See Also

- GlowEffectLib - Outer glow effects
- BevelEffectLib - 3D bevel effects
