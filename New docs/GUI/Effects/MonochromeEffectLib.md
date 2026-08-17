# MonochromeEffectLib Documentation

## Overview

MonochromeEffectLib provides FireMonkey TMonochromeEffect wrapper functionality for converting visual controls to grayscale/monochrome appearance in Plan9Basic programs. This is a simple but powerful effect for creating artistic effects, photo filters, or visual state indication.

**Version:** 1.0.0  
**Function Count:** 10 functions  
**Effect Type:** Static (binary on/off, no gradual properties)

## Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Important: Control Compatibility

TMonochromeEffect is a `TImageFXEffect`-based filter that operates on **textures and bitmaps**. It works on controls that render with textures but **does NOT work on styled controls**.

| Control Type | Works? | Notes |
|-------------|--------|-------|
| TImage | ✓ Yes | Best results with loaded pictures |
| TRectangle | ✓ Yes | Converts fill color to gray |
| TCircle | ✓ Yes | Converts fill color to gray |
| TEllipse | ✓ Yes | Converts fill color to gray |
| TRoundRect | ✓ Yes | Converts fill color to gray |
| TPath | ✓ Yes | Converts fill color to gray |
| TPanel | ✓ Partial | May affect background |
| TButton | ✗ No | Styled control - not affected |
| TCheckBox | ✗ No | Styled control - not affected |
| TEdit | ✗ No | Styled control - not affected |
| TLabel | ✗ No | Styled control - not affected |

**Recommendation:** For grayscale effects, use TImage for photos or TRectangle/shape controls for UI elements.

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Enabled | Boolean (0/1) | 1 | Turn effect on/off |
| Trigger | String | "" | Conditional activation expression |

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `monochrome_error()` | Returns last error code (0 = no error) |
| `monochrome_errormsg$()` | Returns last error message |
| `monochrome_strerror$(code)` | Converts error code to description |
| `monochrome_clearerror()` | Clears error state |

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

### Example 1: Grayscale Image

```basic
' Convert a photo to grayscale
let frm# = Pointer#(0)
let img# = Pointer#(0)
let mono# = Pointer#(0)

frm# = form#("Grayscale Photo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 50, 50, 300, 200)
image_load#(img#, "https://picsum.photos/300/200")

' Apply monochrome effect
mono# = monochrome#(img#)

let lbl# = label#(frm#, "Photo converted to grayscale", 100, 270)

form_show(frm#)
```

### Example 2: Toggle Color/Grayscale

```basic
' Interactive toggle between color and grayscale
let frm# = Pointer#(0)
let img# = Pointer#(0)
let mono# = Pointer#(0)
let statusLbl# = Pointer#(0)

frm# = form#("Toggle Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 50, 50, 300, 180)
image_loadurl#(img#, "https://picsum.photos/300/180")

mono# = monochrome#(img#)
monochrome_enabled#(mono#, 0)  ' Start with color

let toggleBtn# = button#(frm#, "Toggle Grayscale")
button_bounds#(toggleBtn#, 125, 250, 150, 40)
button_onclick#(toggleBtn#, "ToggleMono")

statusLbl# = label#(frm#, "Currently: Color", 150, 300)

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

### Example 3: Grayscale Shape Controls

```basic
' Apply monochrome to colored shapes
let frm# = Pointer#(0)
let rect# = Pointer#(0)
let circle# = Pointer#(0)
let mono1# = Pointer#(0)
let mono2# = Pointer#(0)

frm# = form#("Grayscale Shapes", 450, 250)

' Colored rectangle with monochrome
rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 150, 100)
rectangle_fill#(rect#, "Orange")
rectangle_stroke#(rect#, "Blue")
rectangle_strokethickness#(rect#, 3)
mono1# = monochrome#(rect#)

' Colored circle with monochrome  
circle# = circle#(frm#)
circle_bounds#(circle#, 250, 50, 100, 100)
circle_fill#(circle#, "Red")
circle_stroke#(circle#, "Green")
circle_strokethickness#(circle#, 2)
mono2# = monochrome#(circle#)

let lbl# = label#(frm#, "Shapes converted to grayscale", 100, 180)

form_show(frm#)
```

### Example 4: Photo Gallery with Hover Effect

```basic
' Images turn grayscale when NOT hovered
let frm# = Pointer#(0)

frm# = form#("Photo Gallery", 550, 250)

let i = 0
while i < 3
  let img# = Pointer#(0)
  let mono# = Pointer#(0)
  
  img# = image#(frm#)
  image_bounds#(img#, 30 + i * 170, 50, 150, 100)
  image_load#(img#, "https://picsum.photos/150/100?random=" + str$(i))
  
  ' Grayscale when not hovered (color on hover)
  mono# = monochrome#(img#)
  monochrome_trigger#(mono#, "IsMouseOver=false")
  
  i = i + 1
endwhile

let lbl# = label#(frm#, "Hover over images to see color", 150, 180)

form_show(frm#)
```

### Example 5: Before/After Comparison

```basic
' Side by side color vs grayscale comparison
let frm# = Pointer#(0)
let imgColor# = Pointer#(0)
let imgGray# = Pointer#(0)
let mono# = Pointer#(0)

frm# = form#("Before / After", 500, 300)

' Original (color)
let lblBefore# = label#(frm#, "Original:", 70, 30)
imgColor# = image#(frm#)
image_bounds#(imgColor#, 30, 60, 200, 150)
image_load#(imgColor#, "https://picsum.photos/200/150")

' Grayscale version
let lblAfter# = label#(frm#, "Grayscale:", 320, 30)
imgGray# = image#(frm#)
image_bounds#(imgGray#, 270, 60, 200, 150)
image_load#(imgGray#, "https://picsum.photos/200/150")
mono# = monochrome#(imgGray#)

form_show(frm#)
```

### Example 6: Card Selection Effect

```basic
' Cards appear grayscale until selected
let frm# = Pointer#(0)
let card1# = Pointer#(0)
let card2# = Pointer#(0)
let card3# = Pointer#(0)
let mono1# = Pointer#(0)
let mono2# = Pointer#(0)
let mono3# = Pointer#(0)

frm# = form#("Card Selection", 500, 300)

' Create card-like rectangles
card1# = rectangle#(frm#)
rectangle_bounds#(card1#, 30, 50, 130, 150)
rectangle_fill#(card1#, "Blue")
rectangle_corners#(card1#, 8, 8)
mono1# = monochrome#(card1#)

card2# = rectangle#(frm#)
rectangle_bounds#(card2#, 180, 50, 130, 150)
rectangle_fill#(card2#, "Red")
rectangle_corners#(card2#, 8, 8)
mono2# = monochrome#(card2#)

card3# = rectangle#(frm#)
rectangle_bounds#(card3#, 330, 50, 130, 150)
rectangle_fill#(card3#, "Green")
rectangle_corners#(card3#, 8, 8)
mono3# = monochrome#(card3#)

' Selection buttons
let btn1# = button#(frm#, "Select 1")
button_bounds#(btn1#, 45, 220, 100, 30)
button_onclick#(btn1#, "Select1")

let btn2# = button#(frm#, "Select 2")
button_bounds#(btn2#, 195, 220, 100, 30)
button_onclick#(btn2#, "Select2")

let btn3# = button#(frm#, "Select 3")
button_bounds#(btn3#, 345, 220, 100, 30)
button_onclick#(btn3#, "Select3")

form_show(frm#)

function Select1(sender#)
  monochrome_enabled#(mono1#, 0)
  monochrome_enabled#(mono2#, 1)
  monochrome_enabled#(mono3#, 1)
endfunction

function Select2(sender#)
  monochrome_enabled#(mono1#, 1)
  monochrome_enabled#(mono2#, 0)
  monochrome_enabled#(mono3#, 1)
endfunction

function Select3(sender#)
  monochrome_enabled#(mono1#, 1)
  monochrome_enabled#(mono2#, 1)
  monochrome_enabled#(mono3#, 0)
endfunction
```

## Common Trigger Strings

| Trigger | Description |
|---------|-------------|
| `IsMouseOver=true` | Activates when mouse hovers |
| `IsMouseOver=false` | Activates when mouse NOT hovering |
| `IsFocused=true` | Activates when control has focus |
| `IsFocused=false` | Activates when control lacks focus |

## Combining with Other Effects

Monochrome can be combined with other effects on compatible controls:

```basic
' Grayscale image with shadow
let img# = image#(frm#)
image_bounds#(img#, 50, 50, 200, 150)
image_loadurl#(img#, "https://picsum.photos/200/150")

let mono# = monochrome#(img#)
let shd# = shadow#(img#)
shadow_distance#(shd#, 5)
shadow_opacity#(shd#, 0.4)
```

```basic
' Grayscale rectangle with glow on hover
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 150, 100)
rectangle_fill#(rect#, "Purple")

let mono# = monochrome#(rect#)
let glow# = glow#(rect#)
glow_color#(glow#, "Cyan")
glow_trigger#(glow#, "IsMouseOver=true")
```

## Performance Notes

- Monochrome effect is GPU-accelerated
- Very lightweight - minimal performance impact
- Safe to use on many controls simultaneously
- Binary effect (no gradual properties to animate)

## Best Practices

1. Use TImage for photo/image grayscale effects
2. Use shape controls (TRectangle, TCircle) for UI element effects
3. Avoid applying to styled controls (TButton, TEdit) - they won't show the effect
4. Use inverse triggers (`IsMouseOver=false`) for "color on hover" gallery effects
5. Combine with shadow or glow for enhanced visual feedback

## See Also

- InvertEffectLib - Color inversion effects
- SepiaEffectLib - Vintage sepia tone effects
- ContrastEffectLib - Contrast/brightness adjustment
- HueAdjustEffectLib - Color hue shifting
- BlurEffectLib - Blur visual effects
- ShadowEffectLib - Drop shadow effects
