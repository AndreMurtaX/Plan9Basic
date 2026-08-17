# InnerGlowEffectLib Documentation

## Overview

InnerGlowEffectLib provides FireMonkey TInnerGlowEffect wrapper functionality for creating inner glow effects inside visual controls. Unlike GlowEffect (which creates an outer glow), this effect creates a glow that appears inside the control's boundaries.

**Version:** 1.0.0  
**Function Count:** 18 functions  
**Effect Type:** Static (properties apply immediately)

## Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| GlowColor | Color string | "Gold" | Color of the inner glow |
| Softness | 0.0 - 9.0 | 4.0 | Spread/blur of the glow |
| Opacity | 0.0 - 1.0 | 0.9 | Transparency of the glow |
| Enabled | 0/1 | 1 | Turn effect on/off |
| Trigger | String | "" | Conditional activation expression |

## Inner Glow vs Outer Glow

| Feature | Inner Glow | Outer Glow |
|---------|------------|------------|
| Position | Inside control boundary | Outside control boundary |
| Use case | Selection, focus, inset effects | Highlighting, neon effects |
| Function | `innerglow#()` | `glow#()` |

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `innerglow_error@` | Returns last error code (0 = no error) |
| `innerglow_errormsg$@` | Returns last error message |
| `innerglow_strerror$@n` | Converts error code to description |
| `innerglow_clearerror@` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `innerglow#(parent#)` | Creates inner glow effect on parent control |
| `innerglow_free(effect#)` | Removes and destroys the effect |

### GlowColor Property

| Function | Description |
|----------|-------------|
| `innerglow_color#(effect#, color$)` | Sets glow color |
| `innerglow_color$(effect#)` | Gets current glow color |

### Softness Property

| Function | Description |
|----------|-------------|
| `innerglow_softness#(effect#, value)` | Sets glow spread (0.0-9.0) |
| `innerglow_softness(effect#)` | Gets current softness value |

### Opacity Property

| Function | Description |
|----------|-------------|
| `innerglow_opacity#(effect#, value)` | Sets glow opacity (0.0-1.0) |
| `innerglow_opacity(effect#)` | Gets current opacity value |

### Enabled Property

| Function | Description |
|----------|-------------|
| `innerglow_enabled#(effect#, value)` | Enables (1) or disables (0) the effect |
| `innerglow_enabled(effect#)` | Returns 1 if enabled, 0 if disabled |

### Trigger Property

| Function | Description |
|----------|-------------|
| `innerglow_trigger#(effect#, trigger$)` | Sets conditional activation trigger |
| `innerglow_trigger$(effect#)` | Gets current trigger string |

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_NIL_EFFECT | Effect pointer is nil |
| 2 | ERR_INVALID_EFFECT | Not a valid inner glow effect |
| 3 | ERR_INVALID_VALUE | Invalid property value |
| 4 | ERR_NIL_PARENT | Parent pointer is nil |
| 5 | ERR_INVALID_PARENT | Invalid parent object |
| 6 | ERR_INVALID_COLOR | Invalid color value |

## Examples

### Example 1: Basic Inner Glow

```basic
' Create a button with inner glow
let frm# = Pointer#(0)
let btn# = Pointer#(0)
let ig# = Pointer#(0)

frm# = form#("Inner Glow Demo", 400, 300)

btn# = button#(frm#, "Glowing Inside")
button_bounds#(btn#, 100, 80, 180, 60)

ig# = innerglow#(btn#)
innerglow_color#(ig#, "Gold")
innerglow_softness#(ig#, 3)
innerglow_opacity#(ig#, 0.8)

form_show(frm#)
```

### Example 2: Focus Indicator

```basic
' Inner glow appears on focus/selection
let frm# = Pointer#(0)
let btn# = Pointer#(0)
let ig# = Pointer#(0)

frm# = form#("Focus Indicator Demo", 400, 300)

btn# = button#(frm#, "Click to Focus")
button_bounds#(btn#, 100, 80, 180, 60)

ig# = innerglow#(btn#)
innerglow_color#(ig#, "DodgerBlue")
innerglow_softness#(ig#, 4)
innerglow_trigger#(ig#, "IsFocused=true")

form_show(frm#)
```

### Example 3: Color Selection

```basic
' Interactive color selection for inner glow
let frm# = Pointer#(0)
let targetBtn# = Pointer#(0)
let ig# = Pointer#(0)
let statusLbl# = Pointer#(0)

frm# = form#("Color Selection Demo", 500, 350)

targetBtn# = button#(frm#, "Target Button")
button_bounds#(targetBtn#, 150, 50, 180, 60)

ig# = innerglow#(targetBtn#)
innerglow_color#(ig#, "Gold")
innerglow_softness#(ig#, 4)

' Color buttons
let btn# = Pointer#(0)

btn# = button#(frm#, "Gold")
button_bounds#(btn#, 50, 150, 80, 30)
button_onclick#(btn#, "SetGold")

btn# = button#(frm#, "Red")
button_bounds#(btn#, 140, 150, 80, 30)
button_onclick#(btn#, "SetRed")

btn# = button#(frm#, "Cyan")
button_bounds#(btn#, 230, 150, 80, 30)
button_onclick#(btn#, "SetCyan")

btn# = button#(frm#, "Purple")
button_bounds#(btn#, 320, 150, 80, 30)
button_onclick#(btn#, "SetPurple")

statusLbl# = label#(frm#, "Select a glow color", 150, 220)

form_show(frm#)

function SetGold(sender#)
  innerglow_color#(ig#, "Gold")
  label_text#(statusLbl#, "Color: Gold")
endfunction

function SetRed(sender#)
  innerglow_color#(ig#, "Red")
  label_text#(statusLbl#, "Color: Red")
endfunction

function SetCyan(sender#)
  innerglow_color#(ig#, "Cyan")
  label_text#(statusLbl#, "Color: Cyan")
endfunction

function SetPurple(sender#)
  innerglow_color#(ig#, "Purple")
  label_text#(statusLbl#, "Color: Purple")
endfunction
```

### Example 4: Pulsing Inner Glow

```basic
' Animated pulsing inner glow effect
let frm# = Pointer#(0)
let btn# = Pointer#(0)
let ig# = Pointer#(0)

frm# = form#("Pulsing Demo", 400, 300)

btn# = button#(frm#, "Pulsing Glow")
button_bounds#(btn#, 100, 50, 180, 60)

ig# = innerglow#(btn#)
innerglow_color#(ig#, "Orange")
innerglow_softness#(ig#, 2)

let startBtn# = button#(frm#, "Start Pulse")
button_bounds#(startBtn#, 100, 140, 180, 40)
button_onclick#(startBtn#, "StartPulse")

form_show(frm#)

function StartPulse(sender#) local ani#
  ani# = floatani#(ig#)
  floatani_propertyname#(ani#, "Softness")
  floatani_startvalue#(ani#, 1)
  floatani_stopvalue#(ani#, 6)
  floatani_duration#(ani#, 0.8)
  floatani_autoreverse#(ani#, 1)
  floatani_loop#(ani#, 1)
  floatani_start(ani#)
endfunction
```

### Example 5: Gallery with Inner Glows

```basic
' Multiple buttons with different inner glow colors
let frm# = Pointer#(0)
let colors$ = Pointer#(0)
let i = 0

frm# = form#("Inner Glow Gallery", 550, 250)

' Create buttons with different glow colors
while i < 4
  let btn# = Pointer#(0)
  let ig# = Pointer#(0)
  let color$ = ""
  
  btn# = button#(frm#, "Button " + str$(i + 1))
  button_bounds#(btn#, 40 + i * 125, 70, 110, 50)
  
  ig# = innerglow#(btn#)
  
  if i = 0 then
    color$ = "Gold"
  endif
  if i = 1 then
    color$ = "Red"
  endif
  if i = 2 then
    color$ = "Cyan"
  endif
  if i = 3 then
    color$ = "Lime"
  endif
  
  innerglow_color#(ig#, color$)
  innerglow_softness#(ig#, 3)
  innerglow_opacity#(ig#, 0.8)
  
  i = i + 1
endwhile

form_show(frm#)
```

## Animation Support

Inner glow properties can be animated using FloatAnimationLib:

```basic
' Animate softness for breathing effect
let ani# = Pointer#(0)
ani# = floatani#(ig#)
floatani_propertyname#(ani#, "Softness")
floatani_startvalue#(ani#, 2)
floatani_stopvalue#(ani#, 7)
floatani_duration#(ani#, 1.0)
floatani_autoreverse#(ani#, 1)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

### Animatable Properties

| Property | Description |
|----------|-------------|
| Softness | Animate glow spread |
| Opacity | Fade glow in/out |

## Common Trigger Strings

| Trigger | Description |
|---------|-------------|
| `IsMouseOver=true` | Activates when mouse hovers |
| `IsFocused=true` | Activates when control has focus |
| `IsPressed=true` | Activates when pressed |

## Supported Colors

Black, White, Red, Green, Blue, Yellow, Cyan, Magenta, Lime, Gold, Orange, Pink, Purple, Gray/Grey, Silver, Navy, Teal, Aqua, Fuchsia, Maroon, Olive, Brown

Plus hex formats: #RRGGBB and #AARRGGBB

## Performance Notes

- Inner glow effect is GPU-accelerated
- Minimal performance impact on modern devices
- Higher softness values may impact older mobile devices
- Safe to combine with other effects

## Best Practices

1. Use for selection/focus indicators
2. Combine with outer glow for dramatic effects
3. Keep softness moderate (2-5) for subtle effects
4. Use triggers for interactive feedback
5. Consider contrast with control background

## See Also

- GlowEffectLib - Outer glow effects
- BlurEffectLib - Blur visual effects
- ShadowEffectLib - Drop shadow effects
- FloatAnimationLib - Property animation
