# ReflectionEffectLib Documentation

## Overview

ReflectionEffectLib provides FireMonkey TReflectionEffect wrapper functionality for creating mirror-like reflections below visual controls in Plan9Basic programs. This effect creates professional UI elements similar to iOS-style reflections.

**Version:** 1.0.0  
**Function Count:** 18 functions  
**Effect Type:** Static (no events, properties apply immediately)

## Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Length | 0.0 - 1.0 | 0.5 | Portion of control height that is reflected |
| Opacity | 0.0 - 1.0 | 0.5 | Transparency of the reflection |
| Offset | 0+ pixels | 0 | Gap between control and its reflection |
| Enabled | 0/1 | 1 | Turn effect on/off |
| Trigger | String | "" | Conditional activation expression |

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `reflection_error@` | Returns last error code (0 = no error) |
| `reflection_errormsg$@` | Returns last error message |
| `reflection_strerror$@n` | Converts error code to description |
| `reflection_clearerror@` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `reflection#(parent#)` | Creates reflection effect on parent control |
| `reflection_free(effect#)` | Removes and destroys the effect |

### Length Property

| Function | Description |
|----------|-------------|
| `reflection_length#(effect#, value)` | Sets reflection length (0.0-1.0) |
| `reflection_length(effect#)` | Gets current reflection length |

### Opacity Property

| Function | Description |
|----------|-------------|
| `reflection_opacity#(effect#, value)` | Sets reflection opacity (0.0-1.0) |
| `reflection_opacity(effect#)` | Gets current reflection opacity |

### Offset Property

| Function | Description |
|----------|-------------|
| `reflection_offset#(effect#, pixels)` | Sets gap between control and reflection |
| `reflection_offset(effect#)` | Gets current offset in pixels |

### Enabled Property

| Function | Description |
|----------|-------------|
| `reflection_enabled#(effect#, value)` | Enables (1) or disables (0) the effect |
| `reflection_enabled(effect#)` | Returns 1 if enabled, 0 if disabled |

### Trigger Property

| Function | Description |
|----------|-------------|
| `reflection_trigger#(effect#, trigger$)` | Sets conditional activation trigger |
| `reflection_trigger$(effect#)` | Gets current trigger string |

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_NIL_EFFECT | Effect pointer is nil |
| 2 | ERR_INVALID_EFFECT | Not a valid reflection effect |
| 3 | ERR_INVALID_VALUE | Invalid property value |
| 4 | ERR_NIL_PARENT | Parent pointer is nil |
| 5 | ERR_INVALID_PARENT | Invalid parent object |

## Examples

### Example 1: Basic Reflection

```basic
' Create a button with reflection
let frm# = Pointer#(0)
let btn# = Pointer#(0)
let refl# = Pointer#(0)

frm# = form#("Reflection Demo", 400, 300)

btn# = button#(frm#, "Reflected Button")
button_bounds#(btn#, 100, 50, 150, 50)

' Add reflection effect
refl# = reflection#(btn#)
reflection_length#(refl#, 0.4)
reflection_opacity#(refl#, 0.3)

form_show(frm#)
```

### Example 2: Adjustable Reflection

```basic
' Interactive reflection with controls
let frm# = Pointer#(0)
let targetBtn# = Pointer#(0)
let refl# = Pointer#(0)
let statusLbl# = Pointer#(0)

frm# = form#("Reflection Controls", 500, 400)

' Target button with reflection
targetBtn# = button#(frm#, "Target Button")
button_bounds#(targetBtn#, 150, 50, 180, 60)

refl# = reflection#(targetBtn#)
reflection_length#(refl#, 0.5)
reflection_opacity#(refl#, 0.5)
reflection_offset#(refl#, 2)

' Control buttons
let btn# = Pointer#(0)

btn# = button#(frm#, "Length 25%")
button_bounds#(btn#, 50, 180, 90, 30)
button_onclick#(btn#, "SetLen25")

btn# = button#(frm#, "Length 50%")
button_bounds#(btn#, 150, 180, 90, 30)
button_onclick#(btn#, "SetLen50")

btn# = button#(frm#, "Length 75%")
button_bounds#(btn#, 250, 180, 90, 30)
button_onclick#(btn#, "SetLen75")

btn# = button#(frm#, "Opacity 30%")
button_bounds#(btn#, 50, 220, 90, 30)
button_onclick#(btn#, "SetOp30")

btn# = button#(frm#, "Opacity 60%")
button_bounds#(btn#, 150, 220, 90, 30)
button_onclick#(btn#, "SetOp60")

btn# = button#(frm#, "Opacity 90%")
button_bounds#(btn#, 250, 220, 90, 30)
button_onclick#(btn#, "SetOp90")

statusLbl# = label#(frm#, "Adjust reflection properties", 50, 280)

form_show(frm#)

function SetLen25(sender#)
  reflection_length#(refl#, 0.25)
  label_text#(statusLbl#, "Length: 25%")
endfunction

function SetLen50(sender#)
  reflection_length#(refl#, 0.50)
  label_text#(statusLbl#, "Length: 50%")
endfunction

function SetLen75(sender#)
  reflection_length#(refl#, 0.75)
  label_text#(statusLbl#, "Length: 75%")
endfunction

function SetOp30(sender#)
  reflection_opacity#(refl#, 0.30)
  label_text#(statusLbl#, "Opacity: 30%")
endfunction

function SetOp60(sender#)
  reflection_opacity#(refl#, 0.60)
  label_text#(statusLbl#, "Opacity: 60%")
endfunction

function SetOp90(sender#)
  reflection_opacity#(refl#, 0.90)
  label_text#(statusLbl#, "Opacity: 90%")
endfunction
```

### Example 3: Hover-Activated Reflection

```basic
' Reflection that appears on hover
let frm# = Pointer#(0)
let btn# = Pointer#(0)
let refl# = Pointer#(0)

frm# = form#("Hover Reflection", 400, 300)

btn# = button#(frm#, "Hover for Reflection")
button_bounds#(btn#, 100, 50, 180, 60)

' Create reflection with hover trigger
refl# = reflection#(btn#)
reflection_length#(refl#, 0.5)
reflection_opacity#(refl#, 0.4)
reflection_trigger#(refl#, "IsMouseOver=true")

form_show(frm#)
```

### Example 4: Gallery with Reflections

```basic
' Multiple buttons with reflections
let frm# = Pointer#(0)
let i = 0

frm# = form#("Reflection Gallery", 600, 300)

while i < 4
  let btn# = Pointer#(0)
  let refl# = Pointer#(0)
  
  btn# = button#(frm#, "Item " + str$(i + 1))
  button_bounds#(btn#, 50 + i * 130, 50, 110, 50)
  
  refl# = reflection#(btn#)
  reflection_length#(refl#, 0.3 + i * 0.15)
  reflection_opacity#(refl#, 0.3)
  reflection_offset#(refl#, 2)
  
  i = i + 1
endwhile

form_show(frm#)
```

## Animation Support

Reflection properties can be animated using FloatAnimationLib:

```basic
' Animate reflection opacity
let ani# = Pointer#(0)
ani# = floatani#(refl#)
floatani_propertyname#(ani#, "Opacity")
floatani_startvalue#(ani#, 0.0)
floatani_stopvalue#(ani#, 0.6)
floatani_duration#(ani#, 1.0)
floatani_start(ani#)
```

### Animatable Properties

| Property | Description |
|----------|-------------|
| Length | Animate reflection height |
| Opacity | Fade reflection in/out |
| Offset | Animate gap distance |

## Common Trigger Strings

| Trigger | Description |
|---------|-------------|
| `IsMouseOver=true` | Activates when mouse hovers |
| `IsFocused=true` | Activates when control has focus |
| `IsPressed=true` | Activates when pressed |

## Performance Notes

- Reflection effects are GPU-accelerated
- Minimal performance impact on modern devices
- Consider reducing Length on mobile for better performance
- Lower Opacity values render faster

## Best Practices

1. Use subtle opacity (0.2-0.4) for professional appearance
2. Keep length moderate (0.3-0.5) for realistic reflections
3. Add small offset (2-4 pixels) for visual separation
4. Combine with shadow effects for depth
5. Use triggers for interactive reflections

## See Also

- BlurEffectLib - Blur visual effects
- ShadowEffectLib - Drop shadow effects
- GlowEffectLib - Outer glow effects
- FloatAnimationLib - Property animation
