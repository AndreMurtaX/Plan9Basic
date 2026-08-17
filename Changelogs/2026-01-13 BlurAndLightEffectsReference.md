# Plan9Basic Effects Reference - Blur & Light Effects

## Overview

This document covers the Blur Effects (Tier 7) and Light Effects libraries for Plan9Basic. These effects provide image manipulation capabilities through FireMonkey's filter effects system.

---

## Blur Effects

Blur effects soften images by averaging pixel colors with their neighbors. Plan9Basic provides four blur algorithms, each with distinct visual characteristics.

### Blur Algorithm Comparison

| Effect | Algorithm | Speed | Quality | Best For |
|--------|-----------|-------|---------|----------|
| BoxBlur | Box averaging | ⭐⭐⭐ Fast | Good | UI elements, real-time |
| GaussianBlur | Gaussian kernel | ⭐⭐ Medium | Excellent | Photos, smooth results |
| DirectionalBlur | Linear motion | ⭐⭐ Medium | Good | Motion effects, speed lines |
| RadialBlur | Radial/zoom | ⭐ Slower | Excellent | Zoom effects, focus points |

---

## BoxBlurEffectLib

Fast box blur using simple pixel averaging. Best for performance-critical applications.

### Functions (12)

| Function | Description |
|----------|-------------|
| `boxblur#(parent#)` | Create box blur effect on parent control |
| `boxblur_free(effect#)` | Destroy effect and free resources |
| `boxblur_bluramount#(effect#, value)` | Set blur amount (0-10) |
| `boxblur_bluramount(effect#)` | Get current blur amount |
| `boxblur_enabled#(effect#, value)` | Enable (1) or disable (0) effect |
| `boxblur_enabled(effect#)` | Get enabled state |
| `boxblur_trigger#(effect#, trigger$)` | Set trigger property |
| `boxblur_trigger$(effect#)` | Get trigger property |
| `boxblur_error()` | Get last error code |
| `boxblur_errormsg$()` | Get last error message |
| `boxblur_strerror$(code)` | Convert error code to message |
| `boxblur_clearerror()` | Clear error state |

### Properties

| Property | Type | Range | Default | Description |
|----------|------|-------|---------|-------------|
| BlurAmount | Float | 0-10 | 0.1 | Blur intensity |
| Enabled | Boolean | 0/1 | 1 | Effect active state |
| Trigger | String | - | "" | Animation trigger |

### Example

```basic
' Apply box blur to an image
let img# = image#(frm#, 10, 10, 200, 150)
image_load#(img#, "photo.png")

let blur# = boxblur#(img#)
boxblur_bluramount#(blur#, 3.0)

' Animate blur amount
let ani# = floatani#(blur#)
floatani_propertyname#(ani#, "BlurAmount")
floatani_startvalue#(ani#, 0)
floatani_stopvalue#(ani#, 5)
floatani_duration#(ani#, 2.0)
floatani_start(ani#)
```

---

## GaussianBlurEffectLib

Smooth Gaussian blur using weighted kernel. Produces higher quality results than box blur.

### Functions (12)

| Function | Description |
|----------|-------------|
| `gaussblur#(parent#)` | Create Gaussian blur effect |
| `gaussblur_free(effect#)` | Destroy effect |
| `gaussblur_bluramount#(effect#, value)` | Set blur amount (0-10) |
| `gaussblur_bluramount(effect#)` | Get blur amount |
| `gaussblur_enabled#(effect#, value)` | Enable/disable effect |
| `gaussblur_enabled(effect#)` | Get enabled state |
| `gaussblur_trigger#(effect#, trigger$)` | Set trigger |
| `gaussblur_trigger$(effect#)` | Get trigger |
| `gaussblur_error()` | Get last error code |
| `gaussblur_errormsg$()` | Get last error message |
| `gaussblur_strerror$(code)` | Convert error code to message |
| `gaussblur_clearerror()` | Clear error state |

### Properties

| Property | Type | Range | Default | Description |
|----------|------|-------|---------|-------------|
| BlurAmount | Float | 0-10 | 0.1 | Blur intensity |
| Enabled | Boolean | 0/1 | 1 | Effect active state |
| Trigger | String | - | "" | Animation trigger |

### Example

```basic
' Smooth photo blur
let blur# = gaussblur#(img#)
gaussblur_bluramount#(blur#, 2.5)

' Toggle blur on button click
function OnBlurToggle(sender#)
  if gaussblur_enabled(blur#) = 1 then
    gaussblur_enabled#(blur#, 0)
  else
    gaussblur_enabled#(blur#, 1)
  end if
end function
```

---

## DirectionalBlurEffectLib

Motion blur in a specified direction. Creates the illusion of movement.

### Functions (14)

| Function | Description |
|----------|-------------|
| `dirblur#(parent#)` | Create directional blur effect |
| `dirblur_free(effect#)` | Destroy effect |
| `dirblur_bluramount#(effect#, value)` | Set blur amount (0-10) |
| `dirblur_bluramount(effect#)` | Get blur amount |
| `dirblur_angle#(effect#, value)` | Set blur angle in degrees (0-360) |
| `dirblur_angle(effect#)` | Get blur angle |
| `dirblur_enabled#(effect#, value)` | Enable/disable effect |
| `dirblur_enabled(effect#)` | Get enabled state |
| `dirblur_trigger#(effect#, trigger$)` | Set trigger |
| `dirblur_trigger$(effect#)` | Get trigger |
| `dirblur_error()` | Get last error code |
| `dirblur_errormsg$()` | Get last error message |
| `dirblur_strerror$(code)` | Convert error code to message |
| `dirblur_clearerror()` | Clear error state |

### Properties

| Property | Type | Range | Default | Description |
|----------|------|-------|---------|-------------|
| BlurAmount | Float | 0-10 | 0.1 | Blur intensity |
| Angle | Float | 0-360 | 0 | Blur direction in degrees |
| Enabled | Boolean | 0/1 | 1 | Effect active state |
| Trigger | String | - | "" | Animation trigger |

### Angle Reference

```
        270° (Up)
           |
180° ------+------ 0° (Right)
 (Left)    |
        90° (Down)
```

| Angle | Direction |
|-------|-----------|
| 0° | Right (horizontal) |
| 45° | Down-right (diagonal) |
| 90° | Down (vertical) |
| 135° | Down-left (diagonal) |
| 180° | Left (horizontal) |
| 225° | Up-left (diagonal) |
| 270° | Up (vertical) |
| 315° | Up-right (diagonal) |

### Example

```basic
' Horizontal motion blur
let blur# = dirblur#(img#)
dirblur_bluramount#(blur#, 4.0)
dirblur_angle#(blur#, 0)  ' Right direction

' Rotating motion blur animation
let ani# = floatani#(blur#)
floatani_propertyname#(ani#, "Angle")
floatani_startvalue#(ani#, 0)
floatani_stopvalue#(ani#, 360)
floatani_duration#(ani#, 3.0)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

---

## RadialBlurEffectLib

Zoom/spin blur radiating from a center point. Creates dramatic focus effects.

### Functions (16)

| Function | Description |
|----------|-------------|
| `radblur#(parent#)` | Create radial blur effect |
| `radblur_free(effect#)` | Destroy effect |
| `radblur_bluramount#(effect#, value)` | Set blur amount (0-100) |
| `radblur_bluramount(effect#)` | Get blur amount |
| `radblur_centerx#(effect#, value)` | Set center X (0.0-1.0) |
| `radblur_centerx(effect#)` | Get center X |
| `radblur_centery#(effect#, value)` | Set center Y (0.0-1.0) |
| `radblur_centery(effect#)` | Get center Y |
| `radblur_enabled#(effect#, value)` | Enable/disable effect |
| `radblur_enabled(effect#)` | Get enabled state |
| `radblur_trigger#(effect#, trigger$)` | Set trigger |
| `radblur_trigger$(effect#)` | Get trigger |
| `radblur_error()` | Get last error code |
| `radblur_errormsg$()` | Get last error message |
| `radblur_strerror$(code)` | Convert error code to message |
| `radblur_clearerror()` | Clear error state |

### Properties

| Property | Type | Range | Default | Description |
|----------|------|-------|---------|-------------|
| BlurAmount | Float | 0-100 | 10 | Blur intensity |
| CenterX | Float | 0.0-1.0 | 0.5 | Horizontal center (normalized) |
| CenterY | Float | 0.0-1.0 | 0.5 | Vertical center (normalized) |
| Enabled | Boolean | 0/1 | 1 | Effect active state |
| Trigger | String | - | "" | Animation trigger |

### Center Point Reference

```
(0,0)-----(0.5,0)-----(1,0)
  |          |          |
  |    (0.5,0.5)        |
  |      CENTER         |
  |          |          |
(0,1)-----(0.5,1)-----(1,1)
```

| Position | CenterX | CenterY |
|----------|---------|---------|
| Top-left | 0.0 | 0.0 |
| Top-center | 0.5 | 0.0 |
| Top-right | 1.0 | 0.0 |
| Center-left | 0.0 | 0.5 |
| Center | 0.5 | 0.5 |
| Center-right | 1.0 | 0.5 |
| Bottom-left | 0.0 | 1.0 |
| Bottom-center | 0.5 | 1.0 |
| Bottom-right | 1.0 | 1.0 |

### Example

```basic
' Zoom blur from center
let blur# = radblur#(img#)
radblur_bluramount#(blur#, 20)
radblur_centerx#(blur#, 0.5)
radblur_centery#(blur#, 0.5)

' Zoom burst effect
let ani# = floatani#(blur#)
floatani_propertyname#(ani#, "BlurAmount")
floatani_startvalue#(ani#, 0)
floatani_stopvalue#(ani#, 50)
floatani_duration#(ani#, 0.5)
floatani_start(ani#)

' Wandering center point
function AnimateCenter()
  let aniX# = floatani#(blur#)
  floatani_propertyname#(aniX#, "Center.X")
  floatani_startvalue#(aniX#, 0.2)
  floatani_stopvalue#(aniX#, 0.8)
  floatani_duration#(aniX#, 2.0)
  floatani_autoreverse#(aniX#, 1)
  floatani_loop#(aniX#, 1)
  floatani_start(aniX#)
end function
```

---

## Light Effects

Light effects manipulate the brightness and glow characteristics of images. Bloom adds glow to bright areas while Gloom darkens shadow regions.

### Effect Comparison

| Effect | Purpose | Visual Result |
|--------|---------|---------------|
| Bloom | Brightens bright areas | Dreamy, ethereal, glowing |
| Gloom | Darkens dark areas | Moody, atmospheric, dramatic |

---

## BloomEffectLib

Creates a glow effect around bright areas of an image. Perfect for dreamy, ethereal visuals.

### Functions (18)

| Function | Description |
|----------|-------------|
| `bloom#(parent#)` | Create bloom effect |
| `bloom_free(effect#)` | Destroy effect |
| `bloom_bloomintensity#(effect#, value)` | Set bloom glow intensity (0-1) |
| `bloom_bloomintensity(effect#)` | Get bloom intensity |
| `bloom_baseintensity#(effect#, value)` | Set base image brightness (0-1) |
| `bloom_baseintensity(effect#)` | Get base intensity |
| `bloom_bloomsaturation#(effect#, value)` | Set bloom color saturation (0-1) |
| `bloom_bloomsaturation(effect#)` | Get bloom saturation |
| `bloom_basesaturation#(effect#, value)` | Set base image saturation (0-1) |
| `bloom_basesaturation(effect#)` | Get base saturation |
| `bloom_enabled#(effect#, value)` | Enable/disable effect |
| `bloom_enabled(effect#)` | Get enabled state |
| `bloom_trigger#(effect#, trigger$)` | Set trigger |
| `bloom_trigger$(effect#)` | Get trigger |
| `bloom_error()` | Get last error code |
| `bloom_errormsg$()` | Get last error message |
| `bloom_strerror$(code)` | Convert error code to message |
| `bloom_clearerror()` | Clear error state |

### Properties

| Property | Type | Range | Default | Description |
|----------|------|-------|---------|-------------|
| BloomIntensity | Float | 0-1 | 0.5 | Glow brightness |
| BaseIntensity | Float | 0-1 | 1.0 | Base image brightness |
| BloomSaturation | Float | 0-1 | 1.0 | Glow color saturation |
| BaseSaturation | Float | 0-1 | 1.0 | Base color saturation |
| Enabled | Boolean | 0/1 | 1 | Effect active state |
| Trigger | String | - | "" | Animation trigger |

### Property Effects

| BloomIntensity | BaseIntensity | Result |
|----------------|---------------|--------|
| 0.0 | 1.0 | No bloom, normal image |
| 0.5 | 1.0 | Moderate glow |
| 1.0 | 1.0 | Strong glow |
| 1.0 | 0.5 | Strong glow, dimmed base |
| 1.0 | 0.0 | Only bloom glow visible |

### Example

```basic
' Dreamy photo effect
let fx# = bloom#(img#)
bloom_bloomintensity#(fx#, 0.7)
bloom_baseintensity#(fx#, 0.9)
bloom_bloomsaturation#(fx#, 0.8)

' Pulsing glow animation
let ani# = floatani#(fx#)
floatani_propertyname#(ani#, "BloomIntensity")
floatani_startvalue#(ani#, 0.3)
floatani_stopvalue#(ani#, 0.9)
floatani_duration#(ani#, 1.5)
floatani_autoreverse#(ani#, 1)
floatani_loop#(ani#, 1)
floatani_start(ani#)

' Desaturated bloom (soft white glow)
bloom_bloomsaturation#(fx#, 0.0)
bloom_basesaturation#(fx#, 1.0)
```

---

## GloomEffectLib

Darkens shadow areas of an image. Creates moody, atmospheric visuals.

### Functions (18)

| Function | Description |
|----------|-------------|
| `gloom#(parent#)` | Create gloom effect |
| `gloom_free(effect#)` | Destroy effect |
| `gloom_gloomintensity#(effect#, value)` | Set gloom darkness intensity (0-1) |
| `gloom_gloomintensity(effect#)` | Get gloom intensity |
| `gloom_baseintensity#(effect#, value)` | Set base image brightness (0-1) |
| `gloom_baseintensity(effect#)` | Get base intensity |
| `gloom_gloomsaturation#(effect#, value)` | Set gloom color saturation (0-1) |
| `gloom_gloomsaturation(effect#)` | Get gloom saturation |
| `gloom_basesaturation#(effect#, value)` | Set base image saturation (0-1) |
| `gloom_basesaturation(effect#)` | Get base saturation |
| `gloom_enabled#(effect#, value)` | Enable/disable effect |
| `gloom_enabled(effect#)` | Get enabled state |
| `gloom_trigger#(effect#, trigger$)` | Set trigger |
| `gloom_trigger$(effect#)` | Get trigger |
| `gloom_error()` | Get last error code |
| `gloom_errormsg$()` | Get last error message |
| `gloom_strerror$(code)` | Convert error code to message |
| `gloom_clearerror()` | Clear error state |

### Properties

| Property | Type | Range | Default | Description |
|----------|------|-------|---------|-------------|
| GloomIntensity | Float | 0-1 | 0.5 | Darkness intensity |
| BaseIntensity | Float | 0-1 | 1.0 | Base image brightness |
| GloomSaturation | Float | 0-1 | 1.0 | Gloom color saturation |
| BaseSaturation | Float | 0-1 | 1.0 | Base color saturation |
| Enabled | Boolean | 0/1 | 1 | Effect active state |
| Trigger | String | - | "" | Animation trigger |

### Example

```basic
' Moody atmosphere effect
let fx# = gloom#(img#)
gloom_gloomintensity#(fx#, 0.6)
gloom_baseintensity#(fx#, 0.8)

' Horror game darkness pulse
let ani# = floatani#(fx#)
floatani_propertyname#(ani#, "GloomIntensity")
floatani_startvalue#(ani#, 0.4)
floatani_stopvalue#(ani#, 0.8)
floatani_duration#(ani#, 2.0)
floatani_autoreverse#(ani#, 1)
floatani_loop#(ani#, 1)
floatani_start(ani#)

' Desaturated gloom (film noir look)
gloom_gloomsaturation#(fx#, 0.2)
gloom_basesaturation#(fx#, 0.3)
```

---

## Error Handling

All effect libraries share a consistent error handling pattern.

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_NIL_EFFECT | Effect pointer is nil |
| 2 | ERR_INVALID_EFFECT | Invalid effect object type |
| 3 | ERR_INVALID_VALUE | Invalid property value |
| 4 | ERR_NIL_PARENT | Parent control is nil |
| 5 | ERR_INVALID_PARENT | Invalid parent object type |

### Error Handling Example

```basic
function SafeCreateBlur(parent#) local fx#, err
  fx# = boxblur#(parent#)
  err = boxblur_error()
  
  if err <> 0 then
    print "Error: " + boxblur_errormsg$()
    return Pointer#(0)
  end if
  
  return fx#
end function
```

---

## Combining Effects

Multiple effects can be applied to the same control for complex visual results.

### Example: Dreamy Motion

```basic
' Create image
let img# = image#(frm#, 10, 10, 300, 200)
image_load#(img#, "landscape.png")

' Apply Gaussian blur for softness
let blur# = gaussblur#(img#)
gaussblur_bluramount#(blur#, 1.5)

' Add bloom for glow
let bloom# = bloom#(img#)
bloom_bloomintensity#(bloom#, 0.4)
bloom_bloomsaturation#(bloom#, 0.7)
```

### Example: Dramatic Focus

```basic
' Radial blur with gloom for intensity
let radial# = radblur#(img#)
radblur_bluramount#(radial#, 15)
radblur_centerx#(radial#, 0.5)
radblur_centery#(radial#, 0.4)

let gloom# = gloom#(img#)
gloom_gloomintensity#(gloom#, 0.5)
```

---

## Performance Notes

1. **BoxBlur** is fastest - use for real-time effects
2. **GaussianBlur** is slower but smoother - use for static images
3. **RadialBlur** is most expensive - use sparingly on mobile
4. **Bloom/Gloom** have moderate cost - safe for most uses
5. Disable effects when not visible to save GPU resources
6. Lower blur amounts render faster than higher values

---

## Integration Reference

### Uses Clause

```pascal
uses
  BoxBlurEffectLib, GaussianBlurEffectLib,
  DirectionalBlurEffectLib, RadialBlurEffectLib,
  BloomEffectLib, GloomEffectLib;
```

### Registration

```pascal
RegisterBoxBlurEffectFuncs(Lib);
RegisterGaussianBlurEffectFuncs(Lib);
RegisterDirectionalBlurEffectFuncs(Lib);
RegisterRadialBlurEffectFuncs(Lib);
RegisterBloomEffectFuncs(Lib);
RegisterGloomEffectFuncs(Lib);
```

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01 | Initial release of all 6 effect libraries |

---

## See Also

- FloatAnimationLib - For animating effect properties
- BlurEffectLib - Original blur effect (Softness-based)
- ShadowEffectLib - Drop shadow effects
- GlowEffectLib - Outer glow effects
