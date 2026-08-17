# RectAnimationLib

Animates the bounds (position and size) of visual controls as a single composite animation. RectAnimationLib animates Position.X, Position.Y, Width, and Height simultaneously, making it ideal for smooth resize and reposition effects.

## Functions

| Function | Description |
|----------|-------------|
| `rectani#(parent#)` | Creates a rect animation attached to parent control |
| `rectani#(parent#, name$)` | Creates a named rect animation |
| `rectani_free(ani#)` | Frees the animation object |
| `rectani_start(ani#)` | Starts the animation |
| `rectani_stop(ani#)` | Stops the animation and resets to start |
| `rectani_stopatcurrent(ani#)` | Stops at current bounds |
| `rectani_startbounds#(ani#, x, y, w, h)` | Sets starting bounds (x, y, width, height) |
| `rectani_startx(ani#)` | Gets starting X position |
| `rectani_starty(ani#)` | Gets starting Y position |
| `rectani_startwidth(ani#)` | Gets starting width |
| `rectani_startheight(ani#)` | Gets starting height |
| `rectani_stopbounds#(ani#, x, y, w, h)` | Sets ending bounds (x, y, width, height) |
| `rectani_stopx(ani#)` | Gets ending X position |
| `rectani_stopy(ani#)` | Gets ending Y position |
| `rectani_stopwidth(ani#)` | Gets ending width |
| `rectani_stopheight(ani#)` | Gets ending height |
| `rectani_duration#(ani#, seconds)` | Sets duration in seconds |
| `rectani_duration(ani#)` | Gets duration |
| `rectani_delay#(ani#, seconds)` | Sets delay before start |
| `rectani_delay(ani#)` | Gets delay |
| `rectani_animationtype#(ani#, type$)` | Sets easing type: "In", "Out", "InOut" |
| `rectani_animationtype$(ani#)` | Gets animation type |
| `rectani_interpolation#(ani#, type$)` | Sets interpolation curve |
| `rectani_interpolation$(ani#)` | Gets interpolation type |
| `rectani_autoreverse#(ani#, flag)` | If 1, reverses after completing |
| `rectani_autoreverse(ani#)` | Gets autoreverse flag |
| `rectani_inverse#(ani#, flag)` | If 1, plays in reverse |
| `rectani_inverse(ani#)` | Gets inverse flag |
| `rectani_loop#(ani#, flag)` | If 1, loops indefinitely |
| `rectani_loop(ani#)` | Gets loop flag |
| `rectani_enabled#(ani#, flag)` | Enables/disables animation |
| `rectani_enabled(ani#)` | Gets enabled state |
| `rectani_running(ani#)` | Returns 1 if animation is running |
| `rectani_normalizedtime(ani#)` | Returns progress 0.0-1.0 |
| `rectani_name$(ani#)` | Gets the animation name |
| `rectani_onfinish#(ani#, callback$)` | Sets finish callback function |
| `rectani_onfinish$(ani#)` | Gets finish callback name |
| `rectani_onprocess#(ani#, callback$)` | Sets per-frame callback |
| `rectani_onprocess$(ani#)` | Gets process callback name |
| `rectani_clearcallbacks#(ani#)` | Removes all callbacks |
| `rectani_error()` | Returns last error code |
| `rectani_errormsg$()` | Returns last error message |
| `rectani_strerror$(code)` | Converts error code to message |
| `rectani_clearerror()` | Clears the error state |

**Note:** RectAnimationLib does not have a `propertyname` function because it always animates all four bounds properties together.

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

## Example: Expand/Collapse Animation

```basic
' Rectangle that expands and collapses
let frm# = form#("Expand Demo", 400, 400)
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 150, 150, 100, 100)
rectangle_fill#(rect#, "Blue")

' Animate from small centered to large
let rectAni# = rectani#(rect#)
rectani_startbounds#(rectAni#, 150, 150, 100, 100)
rectani_stopbounds#(rectAni#, 50, 50, 300, 300)
rectani_duration#(rectAni#, 1.5)
rectani_interpolation#(rectAni#, "Elastic")
rectani_animationtype#(rectAni#, "Out")
rectani_autoreverse#(rectAni#, 1)
rectani_loop#(rectAni#, 1)
rectani_start(rectAni#)

form_show(frm#)
```

## Example: Move and Resize Image

```basic
' Image that moves and resizes simultaneously
let frm# = form#("Move Resize Demo", 500, 400)
let img# = image#(frm#, 20, 20, 100, 100)
image_load#(img#, "https://picsum.photos/200")

' Start small in corner, end large in center
let rectAni# = rectani#(img#)
rectani_startbounds#(rectAni#, 20, 20, 100, 100)
rectani_stopbounds#(rectAni#, 100, 50, 300, 300)
rectani_duration#(rectAni#, 2.0)
rectani_interpolation#(rectAni#, "Cubic")
rectani_animationtype#(rectAni#, "InOut")
rectani_autoreverse#(rectAni#, 1)
rectani_loop#(rectAni#, 1)
rectani_start(rectAni#)

form_show(frm#)
```

## Example: Card Flip Effect (Simulated)

```basic
' Simulate card flip by animating width to 0 and back
let frm# = form#("Card Flip Demo", 400, 300)

let card# = rectangle#(frm#)
rectangle_bounds#(card#, 100, 50, 200, 200)
rectangle_fill#(card#, "Red")
rectangle_corners#(card#, 10, 10)

' Animate width to 0 (collapse horizontally) keeping center
let rectAni# = rectani#(card#)
rectani_startbounds#(rectAni#, 100, 50, 200, 200)
rectani_stopbounds#(rectAni#, 200, 50, 0, 200)
rectani_duration#(rectAni#, 0.5)
rectani_interpolation#(rectAni#, "Sinusoidal")
rectani_animationtype#(rectAni#, "InOut")
rectani_autoreverse#(rectAni#, 1)
rectani_loop#(rectAni#, 1)
rectani_start(rectAni#)

form_show(frm#)
```

## Example: Thumbnail to Full Size

```basic
' Click thumbnail to expand to full size
let frm# = form#("Thumbnail Demo", 500, 400)
let img# = image#(frm#, 20, 20, 80, 80)
image_load#(img#, "https://picsum.photos/400/300")

let rectAni# = rectani#(img#)
rectani_startbounds#(rectAni#, 20, 20, 80, 80)
rectani_stopbounds#(rectAni#, 50, 50, 400, 300)
rectani_duration#(rectAni#, 0.8)
rectani_interpolation#(rectAni#, "Back")
rectani_animationtype#(rectAni#, "Out")

let btn# = button#(frm#, "Expand", 20, 320, 100, 40)
button_onclick#(btn#, "togglesize")

let expanded = 0

form_show(frm#)

function togglesize(sender#)
    if expanded = 0 then
        rectani_inverse#(rectAni#, 0)
        rectani_start(rectAni#)
        expanded = 1
        button_text#(btn#, "Collapse")
    else
        rectani_inverse#(rectAni#, 1)
        rectani_start(rectAni#)
        expanded = 0
        button_text#(btn#, "Expand")
    end if
end function
```

## Example: Animated Panel Slide

```basic
' Sliding panel from side
let frm# = form#("Panel Slide Demo", 500, 400)

' Main content
let content# = rectangle#(frm#)
rectangle_bounds#(content#, 0, 0, 500, 400)
rectangle_fill#(content#, "LightGray")

' Side panel (starts off-screen)
let panel# = rectangle#(frm#)
rectangle_bounds#(panel#, -200, 0, 200, 400)
rectangle_fill#(panel#, "Navy")

' Slide animation
let slideAni# = rectani#(panel#)
rectani_startbounds#(slideAni#, -200, 0, 200, 400)
rectani_stopbounds#(slideAni#, 0, 0, 200, 400)
rectani_duration#(slideAni#, 0.4)
rectani_interpolation#(slideAni#, "Cubic")
rectani_animationtype#(slideAni#, "Out")

let btn# = button#(frm#, "Toggle Panel", 250, 180, 120, 40)
button_onclick#(btn#, "togglepanel")

let panelOpen = 0

form_show(frm#)

function togglepanel(sender#)
    println "Ok."
    if panelOpen = 0 then
        rectani_inverse#(slideAni#, 0)
        rectani_start(slideAni#)
        panelOpen = 1
    else
        rectani_inverse#(slideAni#, 1)
        rectani_start(slideAni#)
        panelOpen = 0
    end if
end function
```

## RectAnimationLib vs FloatAnimationLib

| Scenario | Recommended |
|----------|-------------|
| Animate position only | FloatAnimationLib (Position.X, Position.Y) |
| Animate size only | FloatAnimationLib (Width, Height) |
| Animate position AND size together | RectAnimationLib |
| Center-based scaling | RectAnimationLib (adjust all 4 values) |
| Complex multi-property animation | RectAnimationLib |
