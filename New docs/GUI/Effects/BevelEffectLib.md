# BevelEffectLib

Creates 3D bevel/emboss effects on visual controls, making them appear raised or sunken.

## Functions

| Function | Description |
|----------|-------------|
| `bevel#(parent#)` | Creates bevel effect on control |
| `bevel_free(effect#)` | Destroys the effect |
| `bevel_direction#(effect#, degrees)` | Sets light angle (0-360) |
| `bevel_direction(effect#)` | Gets direction value |
| `bevel_size#(effect#, pixels)` | Sets bevel edge size (0-10) |
| `bevel_size(effect#)` | Gets size value |
| `bevel_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `bevel_enabled(effect#)` | Gets enabled state |
| `bevel_trigger#(effect#, trigger$)` | Sets trigger string |
| `bevel_trigger$(effect#)` | Gets trigger string |
| `bevel_error()` | Returns last error code |
| `bevel_errormsg$()` | Returns last error message |
| `bevel_strerror$(code)` | Converts error code to text |
| `bevel_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Direction | 0 - 360 | 45 | Light source angle |
| Size | 0 - 10 | 1 | Bevel edge thickness |

## Direction Values

| Angle | Light Position | Effect |
|-------|----------------|--------|
| 45 | Top-right | Raised look (default) |
| 90 | Top | Light from above |
| 135 | Top-left | Alternate raised |
| 225 | Bottom-left | Sunken look |
| 315 | Bottom-right | Alternate sunken |

## Example 1: Basic Bevel

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let bvl# = Pointer#(0)

frm# = form#("Bevel Demo", 400, 300)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 80, 200, 120)
rectangle_fill#(rect#, "Gray")

bvl# = bevel#(rect#)
bevel_direction#(bvl#, 45)
bevel_size#(bvl#, 3)

form_show(frm#)
```

## Example 2: Raised vs Sunken

```basic
let frm# = Pointer#(0)
let rect1# = Pointer#(0)
let rect2# = Pointer#(0)
let bvl1# = Pointer#(0)
let bvl2# = Pointer#(0)

frm# = form#("Raised vs Sunken", 450, 250)

' Raised (light from top-right)
rect1# = rectangle#(frm#)
rectangle_bounds#(rect1#, 50, 70, 150, 100)
rectangle_fill#(rect1#, "Silver")
bvl1# = bevel#(rect1#)
bevel_direction#(bvl1#, 45)
bevel_size#(bvl1#, 3)
let lbl1# = label#(frm#, "Raised (45)", 85, 180)

' Sunken (light from bottom-left)
rect2# = rectangle#(frm#)
rectangle_bounds#(rect2#, 250, 70, 150, 100)
rectangle_fill#(rect2#, "Silver")
bvl2# = bevel#(rect2#)
bevel_direction#(bvl2#, 225)
bevel_size#(bvl2#, 3)
let lbl2# = label#(frm#, "Sunken (225)", 280, 180)

form_show(frm#)
```

## Example 3: Direction Control

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let bvl# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Bevel Direction", 450, 320)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 125, 40, 200, 100)
rectangle_fill#(rect#, "Silver")

bvl# = bevel#(rect#)
bevel_direction#(bvl#, 45)
bevel_size#(bvl#, 4)

lbl# = label#(frm#, "Direction: 45", 170, 160)

let btn1# = button#(frm#, "45 (TR)")
button_bounds#(btn1#, 40, 200, 80, 30)
button_onclick#(btn1#, "SetDir45")

let btn2# = button#(frm#, "135 (TL)")
button_bounds#(btn2#, 130, 200, 80, 30)
button_onclick#(btn2#, "SetDir135")

let btn3# = button#(frm#, "225 (BL)")
button_bounds#(btn3#, 220, 200, 80, 30)
button_onclick#(btn3#, "SetDir225")

let btn4# = button#(frm#, "315 (BR)")
button_bounds#(btn4#, 310, 200, 80, 30)
button_onclick#(btn4#, "SetDir315")

form_show(frm#)

function SetDir45(sender#)
  bevel_direction#(bvl#, 45)
  label_text#(lbl#, "Direction: 45 (Raised)")
endfunction

function SetDir135(sender#)
  bevel_direction#(bvl#, 135)
  label_text#(lbl#, "Direction: 135")
endfunction

function SetDir225(sender#)
  bevel_direction#(bvl#, 225)
  label_text#(lbl#, "Direction: 225 (Sunken)")
endfunction

function SetDir315(sender#)
  bevel_direction#(bvl#, 315)
  label_text#(lbl#, "Direction: 315")
endfunction
```

## Design Tips

- Use direction 45 for raised/button appearance
- Use direction 225 for sunken/pressed appearance
- Keep size between 1-4 for subtle effects
- Works best on gray or neutral-colored controls

## See Also

- ShadowEffectLib - Drop shadow effects
- GlowEffectLib - Outer glow effects
