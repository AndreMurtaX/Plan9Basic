# FloatAnimationLib

Animates numeric (float) properties of any visual control. This is the most versatile animation type in Plan9Basic, capable of animating position, size, opacity, rotation, and any other numeric property.

## Functions

| Function | Description |
|----------|-------------|
| `floatani#(parent#)` | Creates a float animation attached to parent control |
| `floatani#(parent#, name$)` | Creates a named float animation |
| `floatani_free(ani#)` | Frees the animation object |
| `floatani_start(ani#)` | Starts the animation |
| `floatani_stop(ani#)` | Stops the animation and resets to start |
| `floatani_stopatcurrent(ani#)` | Stops at current position |
| `floatani_propertyname#(ani#, name$)` | Sets property to animate (e.g., "Opacity") |
| `floatani_propertyname$(ani#)` | Gets the property name |
| `floatani_startvalue#(ani#, value)` | Sets the starting value |
| `floatani_startvalue(ani#)` | Gets the starting value |
| `floatani_stopvalue#(ani#, value)` | Sets the ending value |
| `floatani_stopvalue(ani#)` | Gets the ending value |
| `floatani_duration#(ani#, seconds)` | Sets duration in seconds |
| `floatani_duration(ani#)` | Gets duration |
| `floatani_delay#(ani#, seconds)` | Sets delay before start |
| `floatani_delay(ani#)` | Gets delay |
| `floatani_animationtype#(ani#, type$)` | Sets easing type: "In", "Out", "InOut" |
| `floatani_animationtype$(ani#)` | Gets animation type |
| `floatani_interpolation#(ani#, type$)` | Sets interpolation curve |
| `floatani_interpolation$(ani#)` | Gets interpolation type |
| `floatani_autoreverse#(ani#, flag)` | If 1, reverses after completing |
| `floatani_autoreverse(ani#)` | Gets autoreverse flag |
| `floatani_inverse#(ani#, flag)` | If 1, plays in reverse |
| `floatani_inverse(ani#)` | Gets inverse flag |
| `floatani_loop#(ani#, flag)` | If 1, loops indefinitely |
| `floatani_loop(ani#)` | Gets loop flag |
| `floatani_enabled#(ani#, flag)` | Enables/disables animation |
| `floatani_enabled(ani#)` | Gets enabled state |
| `floatani_startfromcurrent#(ani#, flag)` | If 1, starts from current property value |
| `floatani_startfromcurrent(ani#)` | Gets startfromcurrent flag |
| `floatani_running(ani#)` | Returns 1 if animation is running |
| `floatani_normalizedtime(ani#)` | Returns progress 0.0-1.0 |
| `floatani_name$(ani#)` | Gets the animation name |
| `floatani_trigger#(ani#, expr$)` | Sets trigger expression |
| `floatani_trigger$(ani#)` | Gets trigger expression |
| `floatani_triggerinverse#(ani#, expr$)` | Sets inverse trigger |
| `floatani_triggerinverse$(ani#)` | Gets inverse trigger |
| `floatani_onfinish#(ani#, callback$)` | Sets finish callback function |
| `floatani_onfinish$(ani#)` | Gets finish callback name |
| `floatani_onprocess#(ani#, callback$)` | Sets per-frame callback |
| `floatani_onprocess$(ani#)` | Gets process callback name |
| `floatani_clearcallbacks#(ani#)` | Removes all callbacks |
| `floatani_error()` | Returns last error code |
| `floatani_errormsg$()` | Returns last error message |
| `floatani_strerror$(code)` | Converts error code to message |
| `floatani_clearerror()` | Clears the error state |

## Animatable Properties

Common properties you can animate:

| Property | Description |
|----------|-------------|
| `Position.X` | Horizontal position |
| `Position.Y` | Vertical position |
| `Width` | Control width |
| `Height` | Control height |
| `Opacity` | Transparency (0.0-1.0) |
| `RotationAngle` | Rotation in degrees |
| `Scale.X` | Horizontal scale |
| `Scale.Y` | Vertical scale |

## Animation Types

| Type | Description |
|------|-------------|
| `"In"` | Acceleration at start |
| `"Out"` | Deceleration at end |
| `"InOut"` | Accelerate then decelerate |

## Interpolation Types

| Type | Description |
|------|-------------|
| `"Linear"` | Constant speed |
| `"Quadratic"` | Smooth acceleration |
| `"Cubic"` | More pronounced curve |
| `"Quartic"` | Even more pronounced |
| `"Quintic"` | Very pronounced |
| `"Sinusoidal"` | Sine-based easing |
| `"Exponential"` | Exponential curve |
| `"Circular"` | Circular curve |
| `"Elastic"` | Bouncy/springy effect |
| `"Back"` | Overshoots then returns |
| `"Bounce"` | Bouncing effect |

## Error Codes

| Code | Meaning |
|------|---------|
| 0 | No error |
| 1 | Animation is nil |
| 2 | Invalid property |
| 3 | Invalid value |
| 4 | Animation is running |

## Example: Fade Animation

```basic
' Create a form with an image that fades in and out
let frm# = form#("Fade Demo", 400, 300)
let img# = image#(frm#, 50, 50, 300, 200)
image_load#(img#, "https://picsum.photos/300/200")

' Create fade animation
let fadeAni# = floatani#(img#)
floatani_propertyname#(fadeAni#, "Opacity")
floatani_startvalue#(fadeAni#, 1.0)
floatani_stopvalue#(fadeAni#, 0.2)
floatani_duration#(fadeAni#, 2.0)
floatani_interpolation#(fadeAni#, "Linear")
floatani_autoreverse#(fadeAni#, 1)
floatani_loop#(fadeAni#, 1)
floatani_start(fadeAni#)

form_show(frm#)
```

## Example: Move Animation with Bounce

```basic
' Create a bouncing ball effect
let frm# = form#("Bounce Demo", 400, 400)
let ball# = circle#(frm#)
circle_bounds#(ball#, 175, 50, 50, 50)
circle_fill#(ball#, "Red")

' Animate Y position with bounce
let bounceAni# = floatani#(ball#)
floatani_propertyname#(bounceAni#, "Position.Y")
floatani_startvalue#(bounceAni#, 50)
floatani_stopvalue#(bounceAni#, 300)
floatani_duration#(bounceAni#, 1.5)
floatani_interpolation#(bounceAni#, "Bounce")
floatani_animationtype#(bounceAni#, "Out")
floatani_autoreverse#(bounceAni#, 1)
floatani_loop#(bounceAni#, 1)
floatani_start(bounceAni#)

form_show(frm#)
```

## Example: Rotation Animation

```basic
' Spinning rectangle
let frm# = form#("Spin Demo", 400, 400)
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 150, 150, 100, 100)
rectangle_fill#(rect#, "Green")

let spinAni# = floatani#(rect#)
floatani_propertyname#(spinAni#, "RotationAngle")
floatani_startvalue#(spinAni#, 0)
floatani_stopvalue#(spinAni#, 360)
floatani_duration#(spinAni#, 2.0)
floatani_interpolation#(spinAni#, "Linear")
floatani_loop#(spinAni#, 1)
floatani_start(spinAni#)

form_show(frm#)
```

## Example: Scale Pulsing Animation

```basic
' Pulsing scale effect on an image
let frm# = form#("Pulse Demo", 400, 400)
let img# = image#(frm#, 100, 100, 200, 200)
image_load#(img#, "https://picsum.photos/200")

let scaleAni# = floatani#(img#)
floatani_propertyname#(scaleAni#, "Scale.X")
floatani_startvalue#(scaleAni#, 1.0)
floatani_stopvalue#(scaleAni#, 1.2)
floatani_duration#(scaleAni#, 0.5)
floatani_interpolation#(scaleAni#, "Sinusoidal")
floatani_animationtype#(scaleAni#, "InOut")
floatani_autoreverse#(scaleAni#, 1)
floatani_loop#(scaleAni#, 1)
floatani_start(scaleAni#)

' Also animate Y scale
let scaleAniY# = floatani#(img#)
floatani_propertyname#(scaleAniY#, "Scale.Y")
floatani_startvalue#(scaleAniY#, 1.0)
floatani_stopvalue#(scaleAniY#, 1.2)
floatani_duration#(scaleAniY#, 0.5)
floatani_interpolation#(scaleAniY#, "Sinusoidal")
floatani_animationtype#(scaleAniY#, "InOut")
floatani_autoreverse#(scaleAniY#, 1)
floatani_loop#(scaleAniY#, 1)
floatani_start(scaleAniY#)

form_show(frm#)
```

## Example: Horizontal Slide Animation

```basic
' Image slides across the screen
let frm# = form#("Slide Demo", 500, 300)
let img# = image#(frm#, 0, 75, 150, 150)
image_load#(img#, "https://picsum.photos/150")

let slideAni# = floatani#(img#)
floatani_propertyname#(slideAni#, "Position.X")
floatani_startvalue#(slideAni#, 0)
floatani_stopvalue#(slideAni#, 350)
floatani_duration#(slideAni#, 3.0)
floatani_interpolation#(slideAni#, "Cubic")
floatani_animationtype#(slideAni#, "InOut")
floatani_autoreverse#(slideAni#, 1)
floatani_loop#(slideAni#, 1)
floatani_start(slideAni#)

form_show(frm#)
```
