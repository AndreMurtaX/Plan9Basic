# ColorKeyAlphaEffectLib Documentation

## Overview

ColorKeyAlphaEffectLib provides FireMonkey TColorKeyAlphaEffect wrapper functionality for making specific colors transparent in visual controls. This is essential for green-screen style effects, background removal, and creating cutout effects in Plan9Basic programs.

**Version:** 1.0.0  
**Function Count:** 16 functions  
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
| ColorKey | Color string | "Lime" | Color to make transparent |
| Tolerance | 0.0 - 1.0 | 0.0 | How similar colors must be to match |
| Enabled | 0/1 | 1 | Turn effect on/off |
| Trigger | String | "" | Conditional activation expression |

## Color Format

Colors can be specified as:
- **Named colors**: "Red", "Green", "Blue", "Lime", "White", "Black", etc.
- **Hex RGB**: "#RRGGBB" (e.g., "#00FF00" for green)
- **Hex ARGB**: "#AARRGGBB" (e.g., "#FF00FF00")

### Supported Named Colors

Black, White, Red, Green, Blue, Yellow, Cyan, Magenta, Lime, Gray/Grey, Silver, Maroon, Olive, Navy, Purple, Teal, Orange, Pink, Brown, Aqua, Fuchsia, Transparent, Null

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `colorkey_error@` | Returns last error code (0 = no error) |
| `colorkey_errormsg$@` | Returns last error message |
| `colorkey_strerror$@n` | Converts error code to description |
| `colorkey_clearerror@` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `colorkey#(parent#)` | Creates colorkey effect on parent control |
| `colorkey_free(effect#)` | Removes and destroys the effect |

### ColorKey Property

| Function | Description |
|----------|-------------|
| `colorkey_color#(effect#, color$)` | Sets color to make transparent |
| `colorkey_color$(effect#)` | Gets current colorkey color |

### Tolerance Property

| Function | Description |
|----------|-------------|
| `colorkey_tolerance#(effect#, value)` | Sets color matching tolerance (0.0-1.0) |
| `colorkey_tolerance(effect#)` | Gets current tolerance value |

### Enabled Property

| Function | Description |
|----------|-------------|
| `colorkey_enabled#(effect#, value)` | Enables (1) or disables (0) the effect |
| `colorkey_enabled(effect#)` | Returns 1 if enabled, 0 if disabled |

### Trigger Property

| Function | Description |
|----------|-------------|
| `colorkey_trigger#(effect#, trigger$)` | Sets conditional activation trigger |
| `colorkey_trigger$(effect#)` | Gets current trigger string |

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_NIL_EFFECT | Effect pointer is nil |
| 2 | ERR_INVALID_EFFECT | Not a valid colorkey effect |
| 3 | ERR_INVALID_VALUE | Invalid property value |
| 4 | ERR_NIL_PARENT | Parent pointer is nil |
| 5 | ERR_INVALID_PARENT | Invalid parent object |
| 6 | ERR_INVALID_COLOR | Invalid color value |

## Examples

### Example 1: Basic Green Screen Removal

```basic
' Remove lime/green background from an image
let frm# = Pointer#(0)
let img# = Pointer#(0)
let ck# = Pointer#(0)

frm# = form#("Green Screen Demo", 500, 400)

' Create image (would load image with green background)
img# = image#(frm#)
image_bounds#(img#, 50, 50, 300, 250)
' image_load#(img#, "greenscreen_photo.png")

' Apply colorkey to remove green
ck# = colorkey#(img#)
colorkey_color#(ck#, "Lime")
colorkey_tolerance#(ck#, 0.1)

form_show(frm#)
```

### Example 2: Remove White Background

```basic
' Remove white background from an image
let frm# = Pointer#(0)
let img# = Pointer#(0)
let ck# = Pointer#(0)

frm# = form#("White Background Removal", 500, 400)

img# = image#(frm#)
image_bounds#(img#, 50, 50, 300, 250)

ck# = colorkey#(img#)
colorkey_color#(ck#, "White")
colorkey_tolerance#(ck#, 0.05)  ' Tight tolerance for white

form_show(frm#)
```

### Example 3: Interactive Color Selection

```basic
' Let user choose which color to remove
let frm# = Pointer#(0)
let targetPanel# = Pointer#(0)
let ck# = Pointer#(0)
let statusLbl# = Pointer#(0)

frm# = form#("Color Selection Demo", 500, 400)

' Target panel with colored background
targetPanel# = panel#(frm#)
panel_bounds#(targetPanel#, 100, 50, 280, 150)

ck# = colorkey#(targetPanel#)
colorkey_enabled#(ck#, 0)  ' Start disabled

' Color selection buttons
let btn# = Pointer#(0)

btn# = button#(frm#, "Remove Red")
button_bounds#(btn#, 50, 230, 100, 30)
button_onclick#(btn#, "RemoveRed")

btn# = button#(frm#, "Remove Green")
button_bounds#(btn#, 160, 230, 100, 30)
button_onclick#(btn#, "RemoveGreen")

btn# = button#(frm#, "Remove Blue")
button_bounds#(btn#, 270, 230, 100, 30)
button_onclick#(btn#, "RemoveBlue")

btn# = button#(frm#, "Reset")
button_bounds#(btn#, 160, 280, 100, 30)
button_onclick#(btn#, "ResetEffect")

statusLbl# = label#(frm#, "Select a color to remove", 150, 330)

form_show(frm#)

function RemoveRed(sender#)
  colorkey_color#(ck#, "Red")
  colorkey_tolerance#(ck#, 0.15)
  colorkey_enabled#(ck#, 1)
  label_text#(statusLbl#, "Removing: Red")
endfunction

function RemoveGreen(sender#)
  colorkey_color#(ck#, "Green")
  colorkey_tolerance#(ck#, 0.15)
  colorkey_enabled#(ck#, 1)
  label_text#(statusLbl#, "Removing: Green")
endfunction

function RemoveBlue(sender#)
  colorkey_color#(ck#, "Blue")
  colorkey_tolerance#(ck#, 0.15)
  colorkey_enabled#(ck#, 1)
  label_text#(statusLbl#, "Removing: Blue")
endfunction

function ResetEffect(sender#)
  colorkey_enabled#(ck#, 0)
  label_text#(statusLbl#, "Effect disabled")
endfunction
```

### Example 4: Tolerance Comparison

```basic
' Show different tolerance values
let frm# = Pointer#(0)
let i = 0

frm# = form#("Tolerance Demo", 600, 300)

let lbl# = label#(frm#, "Same color, different tolerances:", 50, 20)

while i < 4
  let panel# = Pointer#(0)
  let ck# = Pointer#(0)
  let tolLbl# = Pointer#(0)
  let tolerance = 0.0
  
  panel# = panel#(frm#)
  panel_bounds#(panel#, 50 + i * 130, 60, 110, 110)
  
  ck# = colorkey#(panel#)
  colorkey_color#(ck#, "Lime")
  
  tolerance = i * 0.1
  colorkey_tolerance#(ck#, tolerance)
  
  tolLbl# = label#(frm#, "Tol: " + stri$(tolerance), 70 + i * 130, 180)
  
  i = i + 1
endwhile

form_show(frm#)
```

## Tolerance Guidelines

| Tolerance | Effect | Use Case |
|-----------|--------|----------|
| 0.0 | Exact match only | Solid color backgrounds |
| 0.05-0.1 | Very tight | Clean edges, minimal bleed |
| 0.1-0.2 | Moderate | Good balance for most uses |
| 0.2-0.4 | Loose | Rough edges, includes variations |
| 0.5+ | Very loose | Aggressive removal, may affect other colors |

## Animation Support

ColorKey properties can be animated using FloatAnimationLib:

```basic
' Animate tolerance for reveal effect
let ani# = Pointer#(0)
ani# = floatani#(ck#)
floatani_propertyname#(ani#, "Tolerance")
floatani_startvalue#(ani#, 0.0)
floatani_stopvalue#(ani#, 0.5)
floatani_duration#(ani#, 2.0)
floatani_start(ani#)
```

### Animatable Properties

| Property | Description |
|----------|-------------|
| Tolerance | Animate color matching range |

## Common Use Cases

### Green Screen / Chroma Key
```basic
ck# = colorkey#(videoControl#)
colorkey_color#(ck#, "Lime")
colorkey_tolerance#(ck#, 0.15)
```

### Remove White Background
```basic
ck# = colorkey#(img#)
colorkey_color#(ck#, "White")
colorkey_tolerance#(ck#, 0.05)
```

### Remove Black Background
```basic
ck# = colorkey#(img#)
colorkey_color#(ck#, "Black")
colorkey_tolerance#(ck#, 0.1)
```

### Custom Color Removal
```basic
ck# = colorkey#(control#)
colorkey_color#(ck#, "#FF6B00")  ' Orange
colorkey_tolerance#(ck#, 0.12)
```

## Performance Notes

- ColorKey effect is GPU-accelerated
- Minimal performance impact on modern devices
- Works best on images with solid color backgrounds
- Higher tolerance values may affect more pixels

## Best Practices

1. Start with low tolerance (0.05-0.1) and increase if needed
2. Use exact color values when possible (#RRGGBB)
3. Test with your specific images/content
4. Consider edge quality vs. coverage tradeoff
5. Combine with blur for smoother edges if needed

## See Also

- MonochromeEffectLib - Grayscale effects
- BlurEffectLib - Blur visual effects
- GlowEffectLib - Outer glow effects
- FloatAnimationLib - Property animation
