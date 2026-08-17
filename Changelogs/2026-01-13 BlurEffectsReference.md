# Plan9Basic Blur Effects Library Reference

## Overview

Plan9Basic provides 4 specialized blur effects beyond the basic `blur#()` effect. Each blur algorithm produces different visual results suitable for various use cases.

**Blur Effects Comparison:**

| Effect | Algorithm | Best For |
|--------|-----------|----------|
| BoxBlur | Simple averaging | Fast blur, performance-critical apps |
| GaussianBlur | Gaussian kernel | Smooth, natural-looking blur |
| DirectionalBlur | Linear motion | Motion blur, speed effects |
| RadialBlur | Radial zoom/spin | Zoom effects, focus points |

---

## 1. BoxBlurEffect (boxblur)

Box blur uses a simple averaging algorithm that's very fast but produces less smooth results than Gaussian blur.

### Functions

| Function | Description |
|----------|-------------|
| `boxblur#(parent#)` | Creates a box blur effect on the specified parent control |
| `boxblur_free(effect#)` | Destroys the effect and releases resources |
| `boxblur_bluramount#(effect#, value)` | Sets blur intensity (0-10) |
| `boxblur_bluramount(effect#)` | Gets current blur amount |
| `boxblur_enabled#(effect#, value)` | Enables (1) or disables (0) the effect |
| `boxblur_enabled(effect#)` | Gets enabled state |
| `boxblur_trigger#(effect#, trigger$)` | Sets trigger string |
| `boxblur_trigger$(effect#)` | Gets trigger string |
| `boxblur_parent#(effect#, parent#)` | Sets parent control |
| `boxblur_parent#(effect#)` | Gets parent control |
| `boxblur_error()` | Returns last error code |
| `boxblur_errormsg$()` | Returns last error message |
| `boxblur_strerror$(code)` | Converts error code to message |
| `boxblur_clearerror()` | Clears error state |

### Example

```basic
let img# = image#(form#, 10, 10, 400, 300)
image_load#(img#, "photo.jpg")

let fx# = boxblur#(img#)
boxblur_bluramount#(fx#, 3.0)  ' Medium blur
```

---

## 2. GaussianBlurEffect (gaussblur)

Gaussian blur produces smoother, more natural-looking blurs using a Gaussian kernel. It's the standard blur for most image processing applications.

### Functions

| Function | Description |
|----------|-------------|
| `gaussblur#(parent#)` | Creates a Gaussian blur effect |
| `gaussblur_free(effect#)` | Destroys the effect |
| `gaussblur_bluramount#(effect#, value)` | Sets blur intensity (0-10) |
| `gaussblur_bluramount(effect#)` | Gets current blur amount |
| `gaussblur_enabled#(effect#, value)` | Enables/disables effect |
| `gaussblur_enabled(effect#)` | Gets enabled state |
| `gaussblur_trigger#(effect#, trigger$)` | Sets trigger string |
| `gaussblur_trigger$(effect#)` | Gets trigger string |
| `gaussblur_parent#(effect#, parent#)` | Sets parent control |
| `gaussblur_parent#(effect#)` | Gets parent control |
| `gaussblur_error()` | Returns last error code |
| `gaussblur_errormsg$()` | Returns last error message |
| `gaussblur_strerror$(code)` | Converts error code to message |
| `gaussblur_clearerror()` | Clears error state |

### Example

```basic
let fx# = gaussblur#(img#)
gaussblur_bluramount#(fx#, 2.5)  ' Smooth, medium blur
```

---

## 3. DirectionalBlurEffect (dirblur)

Directional blur creates a motion blur effect along a specified angle. Perfect for simulating movement or speed.

### Properties

| Property | Range | Description |
|----------|-------|-------------|
| BlurAmount | 0-10 | Intensity of blur |
| Angle | 0-360 | Direction of blur in degrees |

### Functions

| Function | Description |
|----------|-------------|
| `dirblur#(parent#)` | Creates a directional blur effect |
| `dirblur_free(effect#)` | Destroys the effect |
| `dirblur_bluramount#(effect#, value)` | Sets blur intensity (0-10) |
| `dirblur_bluramount(effect#)` | Gets current blur amount |
| `dirblur_angle#(effect#, value)` | Sets blur angle (0-360 degrees) |
| `dirblur_angle(effect#)` | Gets current angle |
| `dirblur_enabled#(effect#, value)` | Enables/disables effect |
| `dirblur_enabled(effect#)` | Gets enabled state |
| `dirblur_trigger#(effect#, trigger$)` | Sets trigger string |
| `dirblur_trigger$(effect#)` | Gets trigger string |
| `dirblur_parent#(effect#, parent#)` | Sets parent control |
| `dirblur_parent#(effect#)` | Gets parent control |
| `dirblur_error()` | Returns last error code |
| `dirblur_errormsg$()` | Returns last error message |
| `dirblur_strerror$(code)` | Converts error code to message |
| `dirblur_clearerror()` | Clears error state |

### Angle Reference

| Angle | Direction |
|-------|-----------|
| 0° | Right (horizontal) |
| 45° | Down-right (diagonal) |
| 90° | Down (vertical) |
| 135° | Down-left (diagonal) |
| 180° | Left (horizontal) |
| 270° | Up (vertical) |

### Example

```basic
let fx# = dirblur#(img#)
dirblur_bluramount#(fx#, 5.0)
dirblur_angle#(fx#, 45)  ' Diagonal motion blur
```

---

## 4. RadialBlurEffect (radblur)

Radial blur creates a zoom or spin blur effect radiating from a center point. Great for focus effects and dramatic visuals.

### Properties

| Property | Range | Description |
|----------|-------|-------------|
| BlurAmount | 0-100 | Intensity of blur |
| CenterX | 0.0-1.0 | Horizontal center (normalized) |
| CenterY | 0.0-1.0 | Vertical center (normalized) |

### Functions

| Function | Description |
|----------|-------------|
| `radblur#(parent#)` | Creates a radial blur effect |
| `radblur_free(effect#)` | Destroys the effect |
| `radblur_bluramount#(effect#, value)` | Sets blur intensity (0-100) |
| `radblur_bluramount(effect#)` | Gets current blur amount |
| `radblur_centerx#(effect#, value)` | Sets center X (0.0-1.0) |
| `radblur_centerx(effect#)` | Gets center X |
| `radblur_centery#(effect#, value)` | Sets center Y (0.0-1.0) |
| `radblur_centery(effect#)` | Gets center Y |
| `radblur_enabled#(effect#, value)` | Enables/disables effect |
| `radblur_enabled(effect#)` | Gets enabled state |
| `radblur_trigger#(effect#, trigger$)` | Sets trigger string |
| `radblur_trigger$(effect#)` | Gets trigger string |
| `radblur_parent#(effect#, parent#)` | Sets parent control |
| `radblur_parent#(effect#)` | Gets parent control |
| `radblur_error()` | Returns last error code |
| `radblur_errormsg$()` | Returns last error message |
| `radblur_strerror$(code)` | Converts error code to message |
| `radblur_clearerror()` | Clears error state |

### Center Point Reference

The center point uses normalized coordinates (0.0 to 1.0):

| CenterX | CenterY | Position |
|---------|---------|----------|
| 0.0 | 0.0 | Top-left corner |
| 0.5 | 0.5 | Center |
| 1.0 | 1.0 | Bottom-right corner |
| 0.5 | 0.0 | Top center |
| 0.0 | 0.5 | Left center |

### Example

```basic
let fx# = radblur#(img#)
radblur_bluramount#(fx#, 30)
radblur_centerx#(fx#, 0.5)  ' Center horizontally
radblur_centery#(fx#, 0.5)  ' Center vertically
```

---

## Animation Examples

### Pulsing Blur

```basic
function AnimatePulse() local p
  for p = 0 to 50 step 2
    boxblur_bluramount#(fx#, p / 10)
    pause(0.03)
  next
  for p = 50 to 0 step -2
    boxblur_bluramount#(fx#, p / 10)
    pause(0.03)
  next
end function
```

### Rotating Motion Blur

```basic
function AnimateRotation() local angle
  for angle = 0 to 360 step 5
    dirblur_angle#(fx#, angle)
    pause(0.02)
  next
end function
```

### Zoom Effect

```basic
function AnimateZoom() local amt
  for amt = 0 to 100 step 5
    radblur_bluramount#(fx#, amt)
    pause(0.03)
  next
end function
```

---

## Error Handling

All blur effect libraries share the same error codes:

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_NIL_EFFECT | Effect pointer is nil |
| 2 | ERR_INVALID_EFFECT | Invalid effect type |
| 3 | ERR_INVALID_VALUE | Invalid property value |
| 4 | ERR_NIL_PARENT | Parent pointer is nil |
| 5 | ERR_INVALID_PARENT | Invalid parent type |

### Example

```basic
let fx# = boxblur#(img#)
if boxblur_error() <> 0 then
  println "Error: " + boxblur_errormsg$()
end if
```

---

## Quick Reference

| Effect | Prefix | Unique Properties |
|--------|--------|-------------------|
| BoxBlur | `boxblur_` | BlurAmount |
| GaussianBlur | `gaussblur_` | BlurAmount |
| DirectionalBlur | `dirblur_` | BlurAmount, Angle |
| RadialBlur | `radblur_` | BlurAmount, CenterX, CenterY |

---

## Performance Notes

- **BoxBlur** is the fastest but produces blocky results
- **GaussianBlur** is slower but produces smoother results
- **DirectionalBlur** performance depends on blur amount
- **RadialBlur** is the most computationally intensive

For real-time effects, consider using lower blur amounts or BoxBlur.

---

*Plan9Basic Blur Effects Library Reference - Version 1.0*
