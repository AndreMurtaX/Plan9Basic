# InnerGlowEffectLib

Creates glow effects inside control boundaries. Unlike outer glow (GlowEffectLib), the inner glow appears within the control.

## Functions

| Function | Description |
|----------|-------------|
| `innerglow#(parent#)` | Creates inner glow effect on control |
| `innerglow_free(effect#)` | Destroys the effect |
| `innerglow_color#(effect#, color$)` | Sets glow color |
| `innerglow_color$(effect#)` | Gets glow color |
| `innerglow_softness#(effect#, value)` | Sets spread (0.0-9.0) |
| `innerglow_softness(effect#)` | Gets softness value |
| `innerglow_opacity#(effect#, value)` | Sets opacity (0.0-1.0) |
| `innerglow_opacity(effect#)` | Gets opacity value |
| `innerglow_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `innerglow_enabled(effect#)` | Gets enabled state |
| `innerglow_trigger#(effect#, trigger$)` | Sets trigger string |
| `innerglow_trigger$(effect#)` | Gets trigger string |
| `innerglow_error()` | Returns last error code |
| `innerglow_errormsg$()` | Returns last error message |
| `innerglow_strerror$(code)` | Converts error code to text |
| `innerglow_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Color | Color name/hex | Gold | Glow color |
| Softness | 0.0 - 9.0 | 4.0 | Spread of glow |
| Opacity | 0.0 - 1.0 | 0.9 | Transparency |
| Enabled | 0/1 | 1 | On/off state |

## Example 1: Basic Inner Glow

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let ig# = Pointer#(0)

frm# = form#("Inner Glow Demo", 400, 300)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 80, 200, 120)
rectangle_fill#(rect#, "White")

ig# = innerglow#(rect#)
innerglow_color#(ig#, "Gold")
innerglow_softness#(ig#, 4)
innerglow_opacity#(ig#, 0.8)

form_show(frm#)
```

## Example 2: Toggle Inner Glow

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let ig# = Pointer#(0)

frm# = form#("Toggle Inner Glow", 400, 300)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 50, 200, 120)
rectangle_fill#(rect#, "SteelBlue")

ig# = innerglow#(rect#)
innerglow_color#(ig#, "Cyan")
innerglow_softness#(ig#, 5)

let btn# = button#(frm#, "Toggle Glow")
button_bounds#(btn#, 130, 200, 120, 35)
button_onclick#(btn#, "OnToggle")

form_show(frm#)

function OnToggle(sender#)
  if innerglow_enabled(ig#) = 1 then
    innerglow_enabled#(ig#, 0)
  else
    innerglow_enabled#(ig#, 1)
  endif
endfunction
```

## Example 3: Color Selector

```basic
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let ig# = Pointer#(0)

frm# = form#("Glow Colors", 450, 280)

rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 125, 40, 200, 100)
rectangle_fill#(rect#, "White")

ig# = innerglow#(rect#)
innerglow_color#(ig#, "Gold")
innerglow_softness#(ig#, 4)

let btn1# = button#(frm#, "Gold")
button_bounds#(btn1#, 50, 180, 80, 30)
button_onclick#(btn1#, "SetGold")

let btn2# = button#(frm#, "Cyan")
button_bounds#(btn2#, 140, 180, 80, 30)
button_onclick#(btn2#, "SetCyan")

let btn3# = button#(frm#, "Red")
button_bounds#(btn3#, 230, 180, 80, 30)
button_onclick#(btn3#, "SetRed")

let btn4# = button#(frm#, "Lime")
button_bounds#(btn4#, 320, 180, 80, 30)
button_onclick#(btn4#, "SetLime")

form_show(frm#)

function SetGold(sender#)
  innerglow_color#(ig#, "Gold")
endfunction

function SetCyan(sender#)
  innerglow_color#(ig#, "Cyan")
endfunction

function SetRed(sender#)
  innerglow_color#(ig#, "Red")
endfunction

function SetLime(sender#)
  innerglow_color#(ig#, "Lime")
endfunction
```

## Supported Colors

Black, White, Red, Green, Blue, Yellow, Cyan, Magenta, Gray, Silver, Maroon, Olive, Navy, Purple, Teal, Orange, Pink, Brown, Lime, Aqua, Fuchsia

Hex format: `#RRGGBB` or `#AARRGGBB`

## See Also

- GlowEffectLib - Outer glow effects
- ShadowEffectLib - Drop shadow effects
