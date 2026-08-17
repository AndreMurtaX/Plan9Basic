# MonochromeEffectLib Documentation

## Overview

MonochromeEffectLib provides FireMonkey TMonochromeEffect wrapper functionality for converting visual controls to grayscale/monochrome appearance in Plan9Basic programs. This is a simple but powerful effect for indicating disabled states, creating artistic effects, or focus highlighting.

**Version:** 1.0.0  
**Function Count:** 12 functions  
**Effect Type:** Static (binary on/off, no gradual properties)

## Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Enabled | Boolean (0/1) | 1 | Turn effect on/off |
| Trigger | String | "" | Conditional activation expression |

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `monochrome_error@` | Returns last error code (0 = no error) |
| `monochrome_errormsg$@` | Returns last error message |
| `monochrome_strerror$@n` | Converts error code to description |
| `monochrome_clearerror@` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `monochrome#(parent#)` | Creates monochrome effect on parent control |
| `monochrome_free(effect#)` | Removes and destroys the effect |

### Enabled Property

| Function | Description |
|----------|-------------|
| `monochrome_enabled#(effect#, value)` | Enables (1) or disables (0) the effect |
| `monochrome_enabled(effect#)` | Returns 1 if enabled, 0 if disabled |

### Trigger Property

| Function | Description |
|----------|-------------|
| `monochrome_trigger#(effect#, trigger$)` | Sets conditional activation trigger |
| `monochrome_trigger$(effect#)` | Gets current trigger string |

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_NIL_EFFECT | Effect pointer is nil |
| 2 | ERR_INVALID_EFFECT | Not a valid monochrome effect |
| 3 | ERR_INVALID_VALUE | Invalid property value |
| 4 | ERR_NIL_PARENT | Parent pointer is nil |
| 5 | ERR_INVALID_PARENT | Invalid parent object |

## Examples

### Example 1: Basic Grayscale Effect

```basic
' Create a button that appears in grayscale
let frm# = Pointer#(0)
let btn# = Pointer#(0)
let mono# = Pointer#(0)

frm# = form#("Monochrome Demo", 400, 300)

btn# = button#(frm#, "Grayscale Button")
button_bounds#(btn#, 100, 50, 180, 50)

' Apply monochrome effect
mono# = monochrome#(btn#)

form_show(frm#)
```

### Example 2: Disabled State Indicator

```basic
' Simulate disabled appearance with monochrome
let frm# = Pointer#(0)
let btn1# = Pointer#(0)
let btn2# = Pointer#(0)
let mono# = Pointer#(0)

frm# = form#("Disabled State Demo", 400, 300)

' Active button (no effect)
btn1# = button#(frm#, "Active Button")
button_bounds#(btn1#, 50, 50, 150, 50)

' Disabled-looking button (with monochrome)
btn2# = button#(frm#, "Disabled Button")
button_bounds#(btn2#, 50, 120, 150, 50)
mono# = monochrome#(btn2#)

form_show(frm#)
```

### Example 3: Toggle Monochrome On/Off

```basic
' Interactive toggle between color and grayscale
let frm# = Pointer#(0)
let targetBtn# = Pointer#(0)
let mono# = Pointer#(0)
let statusLbl# = Pointer#(0)

frm# = form#("Toggle Demo", 400, 300)

targetBtn# = button#(frm#, "Target Button")
button_bounds#(targetBtn#, 100, 50, 180, 50)

mono# = monochrome#(targetBtn#)
monochrome_enabled#(mono#, 0)  ' Start with color

let toggleBtn# = button#(frm#, "Toggle Monochrome")
button_bounds#(toggleBtn#, 100, 130, 180, 40)
button_onclick#(toggleBtn#, "ToggleMono")

statusLbl# = label#(frm#, "Currently: Color", 100, 190)

form_show(frm#)

function ToggleMono(sender#) local enabled
  enabled = monochrome_enabled(mono#)
  if enabled = 1 then
    monochrome_enabled#(mono#, 0)
    label_text#(statusLbl#, "Currently: Color")
  else
    monochrome_enabled#(mono#, 1)
    label_text#(statusLbl#, "Currently: Grayscale")
  endif
endfunction
```

### Example 4: Hover-Based Grayscale (Inverse)

```basic
' Button turns gray when NOT hovered (inverse trigger)
let frm# = Pointer#(0)
let btn# = Pointer#(0)
let mono# = Pointer#(0)

frm# = form#("Hover Focus Demo", 400, 300)

btn# = button#(frm#, "Hover for Color!")
button_bounds#(btn#, 100, 80, 180, 60)

' Grayscale when not hovered
mono# = monochrome#(btn#)
monochrome_trigger#(mono#, "IsMouseOver=false")

let lbl# = label#(frm#, "Button is gray until you hover over it", 50, 170)

form_show(frm#)
```

### Example 5: Gallery with Mixed States

```basic
' Some buttons active, some disabled-looking
let frm# = Pointer#(0)
let i = 0

frm# = form#("Gallery Demo", 500, 300)

while i < 4
  let btn# = Pointer#(0)
  
  btn# = button#(frm#, "Button " + str$(i + 1))
  button_bounds#(btn#, 50 + i * 110, 80, 100, 50)
  
  ' Make every other button grayscale
  let remainder = i - (i / 2) * 2
  if remainder = 1 then
    let mono# = Pointer#(0)
    mono# = monochrome#(btn#)
  endif
  
  i = i + 1
endwhile

let lbl# = label#(frm#, "Alternating active/disabled appearance", 80, 160)

form_show(frm#)
```

## Common Use Cases

### Disabled State Indication
```basic
' Apply to buttons that shouldn't be clickable
let mono# = monochrome#(disabledBtn#)
```

### Before/After Comparison
```basic
' Toggle between original and grayscale
function ShowBefore(sender#)
  monochrome_enabled#(mono#, 0)
endfunction

function ShowAfter(sender#)
  monochrome_enabled#(mono#, 1)
endfunction
```

### Focus Highlighting
```basic
' Keep non-focused items grayscale
monochrome_trigger#(mono#, "IsFocused=false")
```

### Selection Indicator
```basic
' Selected items are colorful, others grayscale
monochrome_trigger#(mono#, "IsSelected=false")
```

## Common Trigger Strings

| Trigger | Description |
|---------|-------------|
| `IsMouseOver=true` | Activates when mouse hovers |
| `IsMouseOver=false` | Activates when mouse NOT hovering |
| `IsFocused=true` | Activates when control has focus |
| `IsFocused=false` | Activates when control lacks focus |
| `IsPressed=true` | Activates when pressed |

## Combining with Other Effects

Monochrome can be combined with other effects:

```basic
' Grayscale + Shadow for "lifted disabled" look
let mono# = monochrome#(btn#)
let shd# = shadow#(btn#)
shadow_distance#(shd#, 3)
shadow_opacity#(shd#, 0.3)
```

```basic
' Grayscale with glow on hover
let mono# = monochrome#(btn#)
let glow# = glow#(btn#)
glow_trigger#(glow#, "IsMouseOver=true")
```

## Performance Notes

- Monochrome effect is GPU-accelerated
- Very lightweight - minimal performance impact
- Safe to use on many controls simultaneously
- Binary effect (no gradual properties to animate)

## Best Practices

1. Use for visual disabled state indication
2. Combine with reduced opacity for stronger disabled effect
3. Use inverse triggers for focus/selection highlighting
4. Apply to containers to affect all children
5. Consider accessibility - ensure sufficient contrast

## See Also

- BlurEffectLib - Blur visual effects
- ShadowEffectLib - Drop shadow effects  
- GlowEffectLib - Outer glow effects
- ReflectionEffectLib - Mirror reflections
