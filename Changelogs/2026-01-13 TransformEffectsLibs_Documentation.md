# Transform Effects Libraries - Technical Documentation

## Overview

The Transform Effects libraries provide geometric transformation capabilities for Plan9Basic applets. These effects modify the spatial arrangement of visual controls through scaling, rotation, perspective warping, cropping, and tiling operations.

**Libraries Included:**
- AffineTransformEffectLib - Scale, rotate, and position transformations
- PerspectiveTransformEffectLib - 3D perspective corner warping
- CropEffectLib - Rectangle masking/cropping
- TilerEffectLib - Tile repetition patterns

---

## AffineTransformEffectLib

### Description

Applies affine transformations (scale, rotate) to visual controls while preserving parallel lines. Useful for 2D transformations like zoom effects, rotation animations, and repositioning.

### Properties

| Property | Type | Range | Default | Description |
|----------|------|-------|---------|-------------|
| Center | TPointF | 0.0-1.0 | (0.5, 0.5) | Transformation center point (normalized) |
| Scale | Single | Any | 1.0 | Uniform scale factor |
| Rotation | Single | Any | 0 | Rotation angle in degrees |
| Enabled | Boolean | 0/1 | 1 | Enable/disable effect |
| Trigger | String | - | "" | Conditional activation |

### Function Reference

#### Error Handling

| Function | Signature | Description |
|----------|-----------|-------------|
| `affine_error@` | `affine_error()` | Returns last error code |
| `affine_errormsg$@` | `affine_errormsg$()` | Returns last error message |
| `affine_strerror$@n` | `affine_strerror$(code)` | Converts error code to string |
| `affine_clearerror@` | `affine_clearerror()` | Clears error state |

#### Creation/Destruction

| Function | Signature | Description |
|----------|-----------|-------------|
| `affine#@#` | `affine#(parent#)` | Creates effect on parent control |
| `affine_free@#` | `affine_free(effect#)` | Destroys effect and releases resources |

#### Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `affine_centerx#@#n` | `affine_centerx#(effect#, value)` | Sets center X (0.0-1.0) |
| `affine_centerx@#` | `affine_centerx(effect#)` | Gets center X |
| `affine_centery#@#n` | `affine_centery#(effect#, value)` | Sets center Y (0.0-1.0) |
| `affine_centery@#` | `affine_centery(effect#)` | Gets center Y |
| `affine_rotation#@#n` | `affine_rotation#(effect#, degrees)` | Sets rotation angle |
| `affine_rotation@#` | `affine_rotation(effect#)` | Gets rotation angle |
| `affine_scale#@#n` | `affine_scale#(effect#, factor)` | Sets uniform scale |
| `affine_scale@#` | `affine_scale(effect#)` | Gets scale factor |
| `affine_enabled#@#n` | `affine_enabled#(effect#, value)` | Sets enabled state |
| `affine_enabled@#` | `affine_enabled(effect#)` | Gets enabled state |
| `affine_trigger#@#$` | `affine_trigger#(effect#, trigger$)` | Sets trigger string |
| `affine_trigger$@#` | `affine_trigger$(effect#)` | Gets trigger string |

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_NIL_EFFECT | Effect pointer is nil |
| 2 | ERR_INVALID_EFFECT | Invalid effect object |
| 3 | ERR_INVALID_VALUE | Invalid parameter value |
| 4 | ERR_NIL_PARENT | Parent pointer is nil |
| 5 | ERR_INVALID_PARENT | Invalid parent object |

### Usage Example

```basic
' Create an image and apply affine transform
let img# = image#(form#, 10, 10, 200, 200)
image_load#(img#, "photo.jpg")

' Apply affine transform effect
let fx# = affine#(img#)
affine_rotation#(fx#, 45)      ' Rotate 45 degrees
affine_scale#(fx#, 1.5)        ' Scale 150%
affine_centerx#(fx#, 0.5)      ' Center horizontally
affine_centery#(fx#, 0.5)      ' Center vertically

' Animate rotation
for angle = 0 to 360
  affine_rotation#(fx#, angle)
  sleep(10)
next angle

' Clean up
affine_free(fx#)
```

---

## PerspectiveTransformEffectLib

### Description

Applies perspective transformation by mapping the four corners of the image to new positions. Creates 3D-like warping effects useful for simulating depth, creating book page turns, or perspective corrections.

### Properties

| Property | Type | Range | Default | Description |
|----------|------|-------|---------|-------------|
| TopLeft | TPointF | 0.0-1.0 | (0, 0) | Top-left corner position |
| TopRight | TPointF | 0.0-1.0 | (1, 0) | Top-right corner position |
| BottomLeft | TPointF | 0.0-1.0 | (0, 1) | Bottom-left corner position |
| BottomRight | TPointF | 0.0-1.0 | (1, 1) | Bottom-right corner position |
| Enabled | Boolean | 0/1 | 1 | Enable/disable effect |
| Trigger | String | - | "" | Conditional activation |

### Function Reference

#### Error Handling

| Function | Signature | Description |
|----------|-----------|-------------|
| `persp_error@` | `persp_error()` | Returns last error code |
| `persp_errormsg$@` | `persp_errormsg$()` | Returns last error message |
| `persp_strerror$@n` | `persp_strerror$(code)` | Converts error code to string |
| `persp_clearerror@` | `persp_clearerror()` | Clears error state |

#### Creation/Destruction

| Function | Signature | Description |
|----------|-----------|-------------|
| `persp#@#` | `persp#(parent#)` | Creates effect on parent control |
| `persp_free@#` | `persp_free(effect#)` | Destroys effect |

#### Corner Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `persp_topleftx#@#n` | `persp_topleftx#(effect#, value)` | Sets top-left X |
| `persp_topleftx@#` | `persp_topleftx(effect#)` | Gets top-left X |
| `persp_toplefty#@#n` | `persp_toplefty#(effect#, value)` | Sets top-left Y |
| `persp_toplefty@#` | `persp_toplefty(effect#)` | Gets top-left Y |
| `persp_toprightx#@#n` | `persp_toprightx#(effect#, value)` | Sets top-right X |
| `persp_toprightx@#` | `persp_toprightx(effect#)` | Gets top-right X |
| `persp_toprighty#@#n` | `persp_toprighty#(effect#, value)` | Sets top-right Y |
| `persp_toprighty@#` | `persp_toprighty(effect#)` | Gets top-right Y |
| `persp_bottomleftx#@#n` | `persp_bottomleftx#(effect#, value)` | Sets bottom-left X |
| `persp_bottomleftx@#` | `persp_bottomleftx(effect#)` | Gets bottom-left X |
| `persp_bottomlefty#@#n` | `persp_bottomlefty#(effect#, value)` | Sets bottom-left Y |
| `persp_bottomlefty@#` | `persp_bottomlefty(effect#)` | Gets bottom-left Y |
| `persp_bottomrightx#@#n` | `persp_bottomrightx#(effect#, value)` | Sets bottom-right X |
| `persp_bottomrightx@#` | `persp_bottomrightx(effect#)` | Gets bottom-right X |
| `persp_bottomrighty#@#n` | `persp_bottomrighty#(effect#, value)` | Sets bottom-right Y |
| `persp_bottomrighty@#` | `persp_bottomrighty(effect#)` | Gets bottom-right Y |

#### Other Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `persp_enabled#@#n` | `persp_enabled#(effect#, value)` | Sets enabled state |
| `persp_enabled@#` | `persp_enabled(effect#)` | Gets enabled state |
| `persp_trigger#@#$` | `persp_trigger#(effect#, trigger$)` | Sets trigger string |
| `persp_trigger$@#` | `persp_trigger$(effect#)` | Gets trigger string |

### Usage Example

```basic
' Create perspective effect for 3D look
let img# = image#(form#, 10, 10, 300, 200)
image_load#(img#, "card.jpg")

let fx# = persp#(img#)

' Create trapezoid effect (narrower at top)
persp_topleftx#(fx#, 0.1)      ' Move top-left inward
persp_toplefty#(fx#, 0)
persp_toprightx#(fx#, 0.9)     ' Move top-right inward
persp_toprighty#(fx#, 0)
persp_bottomleftx#(fx#, 0)     ' Bottom corners stay at edges
persp_bottomlefty#(fx#, 1)
persp_bottomrightx#(fx#, 1)
persp_bottomrighty#(fx#, 1)

' Clean up
persp_free(fx#)
```

---

## CropEffectLib

### Description

Crops/masks a rectangular region of the visual control. Only the area within the specified rectangle is visible; everything outside is hidden. Useful for creating reveal animations, image thumbnails, or focus effects.

### Properties

| Property | Type | Range | Default | Description |
|----------|------|-------|---------|-------------|
| LeftTop | TPointF | 0.0-1.0 | (0, 0) | Top-left corner of crop region |
| RightBottom | TPointF | 0.0-1.0 | (1, 1) | Bottom-right corner of crop region |
| Enabled | Boolean | 0/1 | 1 | Enable/disable effect |
| Trigger | String | - | "" | Conditional activation |

### Function Reference

#### Error Handling

| Function | Signature | Description |
|----------|-----------|-------------|
| `crop_error@` | `crop_error()` | Returns last error code |
| `crop_errormsg$@` | `crop_errormsg$()` | Returns last error message |
| `crop_strerror$@n` | `crop_strerror$(code)` | Converts error code to string |
| `crop_clearerror@` | `crop_clearerror()` | Clears error state |

#### Creation/Destruction

| Function | Signature | Description |
|----------|-----------|-------------|
| `crop#@#` | `crop#(parent#)` | Creates effect on parent control |
| `crop_free@#` | `crop_free(effect#)` | Destroys effect |

#### Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `crop_lefttopx#@#n` | `crop_lefttopx#(effect#, value)` | Sets left edge (0.0-1.0) |
| `crop_lefttopx@#` | `crop_lefttopx(effect#)` | Gets left edge |
| `crop_lefttopy#@#n` | `crop_lefttopy#(effect#, value)` | Sets top edge (0.0-1.0) |
| `crop_lefttopy@#` | `crop_lefttopy(effect#)` | Gets top edge |
| `crop_rightbottomx#@#n` | `crop_rightbottomx#(effect#, value)` | Sets right edge (0.0-1.0) |
| `crop_rightbottomx@#` | `crop_rightbottomx(effect#)` | Gets right edge |
| `crop_rightbottomy#@#n` | `crop_rightbottomy#(effect#, value)` | Sets bottom edge (0.0-1.0) |
| `crop_rightbottomy@#` | `crop_rightbottomy(effect#)` | Gets bottom edge |
| `crop_enabled#@#n` | `crop_enabled#(effect#, value)` | Sets enabled state |
| `crop_enabled@#` | `crop_enabled(effect#)` | Gets enabled state |
| `crop_trigger#@#$` | `crop_trigger#(effect#, trigger$)` | Sets trigger string |
| `crop_trigger$@#` | `crop_trigger$(effect#)` | Gets trigger string |

### Usage Example

```basic
' Create crop effect for reveal animation
let img# = image#(form#, 10, 10, 300, 200)
image_load#(img#, "photo.jpg")

let fx# = crop#(img#)

' Start with nothing visible
crop_lefttopx#(fx#, 0.5)
crop_lefttopy#(fx#, 0.5)
crop_rightbottomx#(fx#, 0.5)
crop_rightbottomy#(fx#, 0.5)

' Animate reveal from center
for i = 0 to 50
  let expand = i / 100
  crop_lefttopx#(fx#, 0.5 - expand)
  crop_lefttopy#(fx#, 0.5 - expand)
  crop_rightbottomx#(fx#, 0.5 + expand)
  crop_rightbottomy#(fx#, 0.5 + expand)
  sleep(20)
next i

' Clean up
crop_free(fx#)
```

---

## TilerEffectLib

### Description

Tiles/repeats the visual control in a grid pattern. Creates mosaic effects, pattern backgrounds, or kaleidoscope-like displays by repeating the image horizontally and vertically.

### Properties

| Property | Type | Range | Default | Description |
|----------|------|-------|---------|-------------|
| HorizontalTileCount | Single | ≥1 | 1 | Number of horizontal tiles |
| VerticalTileCount | Single | ≥1 | 1 | Number of vertical tiles |
| Enabled | Boolean | 0/1 | 1 | Enable/disable effect |
| Trigger | String | - | "" | Conditional activation |

### Function Reference

#### Error Handling

| Function | Signature | Description |
|----------|-----------|-------------|
| `tiler_error@` | `tiler_error()` | Returns last error code |
| `tiler_errormsg$@` | `tiler_errormsg$()` | Returns last error message |
| `tiler_strerror$@n` | `tiler_strerror$(code)` | Converts error code to string |
| `tiler_clearerror@` | `tiler_clearerror()` | Clears error state |

#### Creation/Destruction

| Function | Signature | Description |
|----------|-----------|-------------|
| `tiler#@#` | `tiler#(parent#)` | Creates effect on parent control |
| `tiler_free@#` | `tiler_free(effect#)` | Destroys effect |

#### Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `tiler_htiles#@#n` | `tiler_htiles#(effect#, count)` | Sets horizontal tile count |
| `tiler_htiles@#` | `tiler_htiles(effect#)` | Gets horizontal tile count |
| `tiler_vtiles#@#n` | `tiler_vtiles#(effect#, count)` | Sets vertical tile count |
| `tiler_vtiles@#` | `tiler_vtiles(effect#)` | Gets vertical tile count |
| `tiler_enabled#@#n` | `tiler_enabled#(effect#, value)` | Sets enabled state |
| `tiler_enabled@#` | `tiler_enabled(effect#)` | Gets enabled state |
| `tiler_trigger#@#$` | `tiler_trigger#(effect#, trigger$)` | Sets trigger string |
| `tiler_trigger$@#` | `tiler_trigger$(effect#)` | Gets trigger string |

### Usage Example

```basic
' Create tiled pattern effect
let img# = image#(form#, 10, 10, 300, 300)
image_load#(img#, "pattern.png")

let fx# = tiler#(img#)

' Create 4x4 grid of tiles
tiler_htiles#(fx#, 4)
tiler_vtiles#(fx#, 4)

' Animate tile count
for tiles = 1 to 8
  tiler_htiles#(fx#, tiles)
  tiler_vtiles#(fx#, tiles)
  sleep(500)
next tiles

' Clean up
tiler_free(fx#)
```

---

## Integration Guide

### Delphi Registration

```pascal
uses
  AffineTransformEffectLib,
  PerspectiveTransformEffectLib,
  CropEffectLib,
  TilerEffectLib;

// In initialization section:
RegisterAffineTransformEffectFuncs(Lib);
RegisterPerspectiveTransformEffectFuncs(Lib);
RegisterCropEffectFuncs(Lib);
RegisterTilerEffectFuncs(Lib);
```

### Function Count Summary

| Library | Functions |
|---------|-----------|
| AffineTransformEffectLib | 18 |
| PerspectiveTransformEffectLib | 24 |
| CropEffectLib | 16 |
| TilerEffectLib | 14 |
| **Total** | **72** |

---

## Best Practices

### Memory Management

Always free effects when no longer needed:

```basic
' Good practice
let fx# = affine#(img#)
' ... use effect ...
affine_free(fx#)
fx# = Pointer#(0)
```

### Error Handling

Check for errors after critical operations:

```basic
let fx# = affine#(img#)
if affine_error() <> 0 then
  print "Error: " + affine_errormsg$()
end if
```

### Performance Tips

1. **Disable unused effects** - Set `enabled` to 0 instead of freeing/recreating
2. **Batch property changes** - Update multiple properties before triggering redraw
3. **Use appropriate effects** - Choose simplest effect that achieves desired result:
   - Affine: Simple scale/rotate
   - Perspective: 3D warping
   - Crop: Rectangular masking
   - Tiler: Pattern repetition

### Combining Effects

Multiple effects can be applied to the same control:

```basic
let img# = image#(form#, 10, 10, 200, 200)
image_load#(img#, "photo.jpg")

' Apply multiple effects
let fxRotate# = affine#(img#)
affine_rotation#(fxRotate#, 15)

let fxCrop# = crop#(img#)
crop_lefttopx#(fxCrop#, 0.1)
crop_rightbottomx#(fxCrop#, 0.9)
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01 | Initial release |

## See Also

- Basic Effects Library Documentation
- Transition Effects Library Documentation
- Animation Libraries Documentation
