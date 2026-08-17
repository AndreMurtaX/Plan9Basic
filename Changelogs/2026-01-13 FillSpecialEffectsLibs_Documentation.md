# Fill & Special Effects Libraries - Technical Documentation

## Overview

The Fill & Special Effects libraries provide color manipulation and advanced distortion effects for Plan9Basic applets. These effects include solid color fills, RGB tinting, alpha channel manipulation, magnification lenses, pinch/bulge distortions, swirl effects, and image blending.

**Libraries Included:**
- FillEffectLib - Solid color fill overlay
- FillRGBEffectLib - RGB tint preserving transparency
- MaskToAlphaEffectLib - Grayscale to alpha conversion
- SmoothMagnifyEffectLib - Smooth magnifying lens
- PinchEffectLib - Pinch/bulge distortion
- BandedSwirlEffectLib - Banded swirl distortion
- NormalBlendEffectLib - Normal alpha blending of two images

---

## FillEffectLib

### Description

Fills the entire visual control with a solid color. The fill completely covers the original content. Useful for color overlays, placeholder backgrounds, or masking effects.

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Color | TAlphaColor | White | Fill color (ARGB format) |
| Enabled | Boolean | True | Enable/disable effect |
| Trigger | String | "" | Conditional activation |

### Function Reference

| Function | Signature | Description |
|----------|-----------|-------------|
| `fill_error@` | `fill_error()` | Returns last error code |
| `fill_errormsg$@` | `fill_errormsg$()` | Returns last error message |
| `fill_strerror$@n` | `fill_strerror$(code)` | Converts error code to string |
| `fill_clearerror@` | `fill_clearerror()` | Clears error state |
| `fill#@#` | `fill#(parent#)` | Creates effect on parent control |
| `fill_free@#` | `fill_free(effect#)` | Destroys effect |
| `fill_color#@#n` | `fill_color#(effect#, color)` | Sets fill color |
| `fill_color@#` | `fill_color(effect#)` | Gets fill color |
| `fill_enabled#@#n` | `fill_enabled#(effect#, value)` | Sets enabled state |
| `fill_enabled@#` | `fill_enabled(effect#)` | Gets enabled state |
| `fill_trigger#@#$` | `fill_trigger#(effect#, trigger$)` | Sets trigger string |
| `fill_trigger$@#` | `fill_trigger$(effect#)` | Gets trigger string |

### Usage Example

```basic
' Create a red overlay on an image
let img# = image#(form#, 10, 10, 200, 200)
image_load#(img#, "photo.jpg")

' Create fill effect with semi-transparent red
let fx# = fill#(img#)
let red = 4294901760  ' ARGB: FF FF 00 00
fill_color#(fx#, red)

' Clean up
fill_free(fx#)
```

### Color Helper Function

```basic
' Helper to create ARGB color from components
function MakeColor(r, g, b) local c
  ' Alpha = 255 (fully opaque)
  c = 4278190080 + r * 65536 + g * 256 + b
  return c
end function

' Usage:
fill_color#(fx#, MakeColor(255, 0, 0))  ' Red
fill_color#(fx#, MakeColor(0, 255, 0))  ' Green
fill_color#(fx#, MakeColor(0, 0, 255))  ' Blue
```

---

## FillRGBEffectLib

### Description

Tints non-transparent pixels with the specified RGB color. Unlike FillEffect, this preserves the original alpha channel, only affecting visible pixels. Useful for color grading, mood effects, or highlighting.

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Color | TAlphaColor | White | Tint color (ARGB format) |
| Enabled | Boolean | True | Enable/disable effect |
| Trigger | String | "" | Conditional activation |

### Function Reference

| Function | Signature | Description |
|----------|-----------|-------------|
| `fillrgb_error@` | `fillrgb_error()` | Returns last error code |
| `fillrgb_errormsg$@` | `fillrgb_errormsg$()` | Returns last error message |
| `fillrgb_strerror$@n` | `fillrgb_strerror$(code)` | Converts error code to string |
| `fillrgb_clearerror@` | `fillrgb_clearerror()` | Clears error state |
| `fillrgb#@#` | `fillrgb#(parent#)` | Creates effect on parent control |
| `fillrgb_free@#` | `fillrgb_free(effect#)` | Destroys effect |
| `fillrgb_color#@#n` | `fillrgb_color#(effect#, color)` | Sets tint color |
| `fillrgb_color@#` | `fillrgb_color(effect#)` | Gets tint color |
| `fillrgb_enabled#@#n` | `fillrgb_enabled#(effect#, value)` | Sets enabled state |
| `fillrgb_enabled@#` | `fillrgb_enabled(effect#)` | Gets enabled state |
| `fillrgb_trigger#@#$` | `fillrgb_trigger#(effect#, trigger$)` | Sets trigger string |
| `fillrgb_trigger$@#` | `fillrgb_trigger$(effect#)` | Gets trigger string |

### Usage Example

```basic
' Apply sepia-like tint to image
let img# = image#(form#, 10, 10, 200, 200)
image_load#(img#, "photo.png")

let fx# = fillrgb#(img#)
' Warm sepia tone
fillrgb_color#(fx#, MakeColor(210, 180, 140))

' Clean up
fillrgb_free(fx#)
```

### Difference from FillEffect

| Aspect | FillEffect | FillRGBEffect |
|--------|------------|---------------|
| Transparency | Covers everything | Preserves alpha |
| Use case | Solid overlay | Color tinting |
| Original visible | No | Yes (tinted) |

---

## MaskToAlphaEffectLib

### Description

Converts the grayscale luminance values of the image to alpha channel values. White pixels become fully opaque, black pixels become fully transparent, and gray values become semi-transparent. Useful for creating masks from grayscale images.

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Enabled | Boolean | True | Enable/disable effect |
| Trigger | String | "" | Conditional activation |

### Function Reference

| Function | Signature | Description |
|----------|-----------|-------------|
| `mask2a_error@` | `mask2a_error()` | Returns last error code |
| `mask2a_errormsg$@` | `mask2a_errormsg$()` | Returns last error message |
| `mask2a_strerror$@n` | `mask2a_strerror$(code)` | Converts error code to string |
| `mask2a_clearerror@` | `mask2a_clearerror()` | Clears error state |
| `mask2a#@#` | `mask2a#(parent#)` | Creates effect on parent control |
| `mask2a_free@#` | `mask2a_free(effect#)` | Destroys effect |
| `mask2a_enabled#@#n` | `mask2a_enabled#(effect#, value)` | Sets enabled state |
| `mask2a_enabled@#` | `mask2a_enabled(effect#)` | Gets enabled state |
| `mask2a_trigger#@#$` | `mask2a_trigger#(effect#, trigger$)` | Sets trigger string |
| `mask2a_trigger$@#` | `mask2a_trigger$(effect#)` | Gets trigger string |

### Usage Example

```basic
' Convert grayscale mask to alpha
let img# = image#(form#, 10, 10, 200, 200)
image_load#(img#, "grayscale_mask.png")

let fx# = mask2a#(img#)
' Effect is automatic - no properties to adjust

' Clean up
mask2a_free(fx#)
```

### Conversion Table

| Grayscale Value | Alpha Result |
|-----------------|--------------|
| 0 (Black) | 0 (Transparent) |
| 128 (Gray) | 128 (50% opaque) |
| 255 (White) | 255 (Opaque) |

---

## SmoothMagnifyEffectLib

### Description

Creates a smooth magnifying lens effect at a specified location. The magnification has configurable inner and outer radii for smooth falloff, and supports aspect ratio adjustment for elliptical lenses.

### Properties

| Property | Type | Range | Default | Description |
|----------|------|-------|---------|-------------|
| CenterX | Single | 0.0-1.0 | 0.5 | Lens center X (normalized) |
| CenterY | Single | 0.0-1.0 | 0.5 | Lens center Y (normalized) |
| Magnification | Single | >0 | 2.0 | Zoom factor |
| InnerRadius | Single | 0.0-1.0 | 0.1 | Full magnification radius |
| OuterRadius | Single | 0.0-1.0 | 0.2 | Falloff end radius |
| AspectRatio | Single | >0 | 1.0 | Lens shape (1.0 = circle) |
| Enabled | Boolean | - | True | Enable/disable effect |
| Trigger | String | - | "" | Conditional activation |

### Function Reference

| Function | Signature | Description |
|----------|-----------|-------------|
| `smag_error@` | `smag_error()` | Returns last error code |
| `smag_errormsg$@` | `smag_errormsg$()` | Returns last error message |
| `smag_strerror$@n` | `smag_strerror$(code)` | Converts error code to string |
| `smag_clearerror@` | `smag_clearerror()` | Clears error state |
| `smag#@#` | `smag#(parent#)` | Creates effect on parent control |
| `smag_free@#` | `smag_free(effect#)` | Destroys effect |
| `smag_centerx#@#n` | `smag_centerx#(effect#, value)` | Sets center X |
| `smag_centerx@#` | `smag_centerx(effect#)` | Gets center X |
| `smag_centery#@#n` | `smag_centery#(effect#, value)` | Sets center Y |
| `smag_centery@#` | `smag_centery(effect#)` | Gets center Y |
| `smag_mag#@#n` | `smag_mag#(effect#, value)` | Sets magnification |
| `smag_mag@#` | `smag_mag(effect#)` | Gets magnification |
| `smag_inner#@#n` | `smag_inner#(effect#, value)` | Sets inner radius |
| `smag_inner@#` | `smag_inner(effect#)` | Gets inner radius |
| `smag_outer#@#n` | `smag_outer#(effect#, value)` | Sets outer radius |
| `smag_outer@#` | `smag_outer(effect#)` | Gets outer radius |
| `smag_aspect#@#n` | `smag_aspect#(effect#, value)` | Sets aspect ratio |
| `smag_aspect@#` | `smag_aspect(effect#)` | Gets aspect ratio |
| `smag_enabled#@#n` | `smag_enabled#(effect#, value)` | Sets enabled state |
| `smag_enabled@#` | `smag_enabled(effect#)` | Gets enabled state |
| `smag_trigger#@#$` | `smag_trigger#(effect#, trigger$)` | Sets trigger string |
| `smag_trigger$@#` | `smag_trigger$(effect#)` | Gets trigger string |

### Usage Example

```basic
' Create interactive magnifying glass
let img# = image#(form#, 10, 10, 400, 300)
image_load#(img#, "document.jpg")

let fx# = smag#(img#)
smag_mag#(fx#, 3.0)        ' 3x magnification
smag_inner#(fx#, 0.05)     ' Small full-mag area
smag_outer#(fx#, 0.15)     ' Smooth falloff

' Move lens with mouse (in mouse handler)
smag_centerx#(fx#, mouseX / 400)
smag_centery#(fx#, mouseY / 300)

' Clean up
smag_free(fx#)
```

---

## PinchEffectLib

### Description

Creates a pinch or bulge distortion effect at a specified location. Positive strength values create an inward pinch, negative values create an outward bulge. Useful for fun photo effects or UI emphasis.

### Properties

| Property | Type | Range | Default | Description |
|----------|------|-------|---------|-------------|
| CenterX | Single | 0.0-1.0 | 0.5 | Effect center X (normalized) |
| CenterY | Single | 0.0-1.0 | 0.5 | Effect center Y (normalized) |
| Radius | Single | 0.0-1.0 | 0.25 | Effect radius |
| Strength | Single | -1.0 to 1.0 | 0.5 | Pinch (+) or bulge (-) |
| AspectRatio | Single | >0 | 1.0 | Effect shape |
| Enabled | Boolean | - | True | Enable/disable effect |
| Trigger | String | - | "" | Conditional activation |

### Function Reference

| Function | Signature | Description |
|----------|-----------|-------------|
| `pinch_error@` | `pinch_error()` | Returns last error code |
| `pinch_errormsg$@` | `pinch_errormsg$()` | Returns last error message |
| `pinch_strerror$@n` | `pinch_strerror$(code)` | Converts error code to string |
| `pinch_clearerror@` | `pinch_clearerror()` | Clears error state |
| `pinch#@#` | `pinch#(parent#)` | Creates effect on parent control |
| `pinch_free@#` | `pinch_free(effect#)` | Destroys effect |
| `pinch_centerx#@#n` | `pinch_centerx#(effect#, value)` | Sets center X |
| `pinch_centerx@#` | `pinch_centerx(effect#)` | Gets center X |
| `pinch_centery#@#n` | `pinch_centery#(effect#, value)` | Sets center Y |
| `pinch_centery@#` | `pinch_centery(effect#)` | Gets center Y |
| `pinch_radius#@#n` | `pinch_radius#(effect#, value)` | Sets radius |
| `pinch_radius@#` | `pinch_radius(effect#)` | Gets radius |
| `pinch_strength#@#n` | `pinch_strength#(effect#, value)` | Sets strength |
| `pinch_strength@#` | `pinch_strength(effect#)` | Gets strength |
| `pinch_aspect#@#n` | `pinch_aspect#(effect#, value)` | Sets aspect ratio |
| `pinch_aspect@#` | `pinch_aspect(effect#)` | Gets aspect ratio |
| `pinch_enabled#@#n` | `pinch_enabled#(effect#, value)` | Sets enabled state |
| `pinch_enabled@#` | `pinch_enabled(effect#)` | Gets enabled state |
| `pinch_trigger#@#$` | `pinch_trigger#(effect#, trigger$)` | Sets trigger string |
| `pinch_trigger$@#` | `pinch_trigger$(effect#)` | Gets trigger string |

### Usage Example

```basic
' Create bulge effect on face
let img# = image#(form#, 10, 10, 300, 300)
image_load#(img#, "portrait.jpg")

let fx# = pinch#(img#)
pinch_centerx#(fx#, 0.5)
pinch_centery#(fx#, 0.4)   ' Nose area
pinch_radius#(fx#, 0.2)
pinch_strength#(fx#, -0.5) ' Bulge outward

' Animate strength for pulsing effect
for i = 0 to 100
  pinch_strength#(fx#, sin(i / 10) * 0.5)
  sleep(50)
next i

' Clean up
pinch_free(fx#)
```

### Strength Values

| Strength | Effect |
|----------|--------|
| +1.0 | Maximum pinch (inward) |
| +0.5 | Moderate pinch |
| 0.0 | No effect |
| -0.5 | Moderate bulge |
| -1.0 | Maximum bulge (outward) |

---

## BandedSwirlEffectLib

### Description

Creates a swirl distortion effect with concentric bands. The swirl rotates pixels around a center point, with alternating bands creating a hypnotic spiral pattern. Great for psychedelic effects or transitions.

### Properties

| Property | Type | Range | Default | Description |
|----------|------|-------|---------|-------------|
| CenterX | Single | 0.0-1.0 | 0.5 | Swirl center X (normalized) |
| CenterY | Single | 0.0-1.0 | 0.5 | Swirl center Y (normalized) |
| Bands | Single | ≥1 | 3.0 | Number of concentric bands |
| Strength | Single | -1.0 to 1.0 | 0.5 | Swirl intensity and direction |
| AspectRatio | Single | >0 | 1.0 | Effect shape |
| Enabled | Boolean | - | True | Enable/disable effect |
| Trigger | String | - | "" | Conditional activation |

### Function Reference

| Function | Signature | Description |
|----------|-----------|-------------|
| `bswirl_error@` | `bswirl_error()` | Returns last error code |
| `bswirl_errormsg$@` | `bswirl_errormsg$()` | Returns last error message |
| `bswirl_strerror$@n` | `bswirl_strerror$(code)` | Converts error code to string |
| `bswirl_clearerror@` | `bswirl_clearerror()` | Clears error state |
| `bswirl#@#` | `bswirl#(parent#)` | Creates effect on parent control |
| `bswirl_free@#` | `bswirl_free(effect#)` | Destroys effect |
| `bswirl_centerx#@#n` | `bswirl_centerx#(effect#, value)` | Sets center X |
| `bswirl_centerx@#` | `bswirl_centerx(effect#)` | Gets center X |
| `bswirl_centery#@#n` | `bswirl_centery#(effect#, value)` | Sets center Y |
| `bswirl_centery@#` | `bswirl_centery(effect#)` | Gets center Y |
| `bswirl_bands#@#n` | `bswirl_bands#(effect#, value)` | Sets band count |
| `bswirl_bands@#` | `bswirl_bands(effect#)` | Gets band count |
| `bswirl_strength#@#n` | `bswirl_strength#(effect#, value)` | Sets strength |
| `bswirl_strength@#` | `bswirl_strength(effect#)` | Gets strength |
| `bswirl_aspect#@#n` | `bswirl_aspect#(effect#, value)` | Sets aspect ratio |
| `bswirl_aspect@#` | `bswirl_aspect(effect#)` | Gets aspect ratio |
| `bswirl_enabled#@#n` | `bswirl_enabled#(effect#, value)` | Sets enabled state |
| `bswirl_enabled@#` | `bswirl_enabled(effect#)` | Gets enabled state |
| `bswirl_trigger#@#$` | `bswirl_trigger#(effect#, trigger$)` | Sets trigger string |
| `bswirl_trigger$@#` | `bswirl_trigger$(effect#)` | Gets trigger string |

### Usage Example

```basic
' Create hypnotic swirl animation
let img# = image#(form#, 10, 10, 300, 300)
image_load#(img#, "pattern.jpg")

let fx# = bswirl#(img#)
bswirl_bands#(fx#, 5)

' Animate the swirl
for angle = 0 to 360
  bswirl_strength#(fx#, sin(angle * 3.14159 / 180) * 0.8)
  sleep(30)
next angle

' Clean up
bswirl_free(fx#)
```

---

## NormalBlendEffectLib

### Description

Blends two images using normal (alpha) blending mode. The effect applies a target bitmap over the source control using standard alpha compositing. If the target has transparent areas, the source shows through; if fully opaque, the target covers the source completely.

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Target | TBitmap | nil | Second image to blend (from TImage) |
| Enabled | Boolean | True | Enable/disable effect |
| Trigger | String | "" | Conditional activation |

### Function Reference

| Function | Signature | Description |
|----------|-----------|-------------|
| `blend_error@` | `blend_error()` | Returns last error code |
| `blend_errormsg$@` | `blend_errormsg$()` | Returns last error message |
| `blend_strerror$@n` | `blend_strerror$(code)` | Converts error code to string |
| `blend_clearerror@` | `blend_clearerror()` | Clears error state |
| `blend#@#` | `blend#(parent#)` | Creates effect on parent control |
| `blend_free@#` | `blend_free(effect#)` | Destroys effect |
| `blend_target#@##` | `blend_target#(effect#, image#)` | Sets target from TImage |
| `blend_enabled#@#n` | `blend_enabled#(effect#, value)` | Sets enabled state |
| `blend_enabled@#` | `blend_enabled(effect#)` | Gets enabled state |
| `blend_trigger#@#$` | `blend_trigger#(effect#, trigger$)` | Sets trigger string |
| `blend_trigger$@#` | `blend_trigger$(effect#)` | Gets trigger string |

### Usage Example

```basic
' Blend two images together
let imgBase# = image#(form#, 10, 10, 300, 200)
image_load#(imgBase#, "background.jpg")

let imgOverlay# = image#(form#, 400, 10, 150, 100)
image_load#(imgOverlay#, "overlay.png")  ' Should have transparency

' Wait for images to load
sleep(2000)

' Apply blend effect
let fx# = blend#(imgBase#)
blend_target#(fx#, imgOverlay#)

' Clean up
blend_free(fx#)
```

### Important Notes

1. **Target must be loaded**: The target image bitmap must be fully loaded before setting it. For URL-loaded images, add a delay or use a timer.

2. **Transparency matters**: If the target has no transparent areas, it will completely cover the source image.

3. **Target accepts TImage**: The `blend_target#` function accepts a TImage control and extracts its internal bitmap.

---

## Error Codes

All libraries share the same error code system:

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_NIL_EFFECT | Effect pointer is nil |
| 2 | ERR_INVALID_EFFECT | Invalid effect object |
| 3 | ERR_INVALID_VALUE | Invalid parameter value |
| 4 | ERR_NIL_PARENT | Parent pointer is nil |
| 5 | ERR_INVALID_PARENT | Invalid parent object |
| 6 | ERR_NIL_TARGET | Target is nil (Blend only) |
| 7 | ERR_INVALID_TARGET | Invalid target object (Blend only) |

---

## Integration Guide

### Delphi Registration

```pascal
uses
  FillEffectLib, FillRGBEffectLib, MaskToAlphaEffectLib,
  SmoothMagnifyEffectLib, PinchEffectLib, BandedSwirlEffectLib,
  NormalBlendEffectLib;

// In initialization section:
RegisterFillEffectFuncs(Lib);
RegisterFillRGBEffectFuncs(Lib);
RegisterMaskToAlphaEffectFuncs(Lib);
RegisterSmoothMagnifyEffectFuncs(Lib);
RegisterPinchEffectFuncs(Lib);
RegisterBandedSwirlEffectFuncs(Lib);
RegisterNormalBlendEffectFuncs(Lib);
```

### Function Count Summary

| Library | Functions |
|---------|-----------|
| FillEffectLib | 12 |
| FillRGBEffectLib | 12 |
| MaskToAlphaEffectLib | 10 |
| SmoothMagnifyEffectLib | 20 |
| PinchEffectLib | 18 |
| BandedSwirlEffectLib | 18 |
| NormalBlendEffectLib | 12 |
| **Total** | **102** |

---

## Best Practices

### Memory Management

Always free effects when no longer needed:

```basic
let fx# = fill#(img#)
' ... use effect ...
fill_free(fx#)
fx# = Pointer#(0)
```

### Color Handling

Use a helper function for ARGB colors:

```basic
function MakeARGB(a, r, g, b) local c
  c = a * 16777216 + r * 65536 + g * 256 + b
  return c
end function

' Fully opaque red
fill_color#(fx#, MakeARGB(255, 255, 0, 0))

' Semi-transparent blue
fill_color#(fx#, MakeARGB(128, 0, 0, 255))
```

### Async Image Loading

For effects that depend on loaded images (like Blend), use timers:

```basic
let tmr# = timer#(form#)
timer_interval#(tmr#, 2000)
timer_ontimer#(tmr#, "OnImagesLoaded")
timer_enabled#(tmr#, 1)

function OnImagesLoaded(sender#)
  timer_enabled#(tmr#, 0)
  blend_target#(fx#, imgOverlay#)
end function
```

### Animation Tips

Many effects can be animated smoothly:

```basic
' Animate pinch strength
for s = -100 to 100
  pinch_strength#(fx#, s / 100)
  sleep(20)
next s

' Animate swirl
for angle = 0 to 720
  bswirl_strength#(fx#, sin(angle * 0.0175) * 0.7)
  sleep(15)
next angle
```

---

## Complete Effects Library Summary

With Tier 9 complete, the Plan9Basic effects library suite now includes:

| Category | Libraries | Functions |
|----------|-----------|-----------|
| Animations | 6 | ~90 |
| Basic Effects | 8 | ~120 |
| Transitions | 23 | ~350 |
| Blur Variants | 4 | ~60 |
| Light Effects | 2 | ~30 |
| Transform | 4 | ~72 |
| Fill/Special | 7 | 102 |
| **TOTAL** | **54** | **~824** |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01 | Initial release |

## See Also

- Transform Effects Library Documentation
- Transition Effects Library Documentation
- Animation Libraries Documentation
- Basic Effects Library Documentation
