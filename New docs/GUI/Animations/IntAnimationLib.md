# IntAnimationLib

Animates integer properties of visual controls. The `Tag` property is commonly used since it's available on all controls. Use the `onprocess` callback to respond to animation progress.

**Important:** You MUST set `intani_propertyname#()` for the animation to run!

## Functions

| Function | Description |
|----------|-------------|
| `intani#(parent#)` | Creates an integer animation attached to parent control |
| `intani#(parent#, name$)` | Creates a named integer animation |
| `intani_free(ani#)` | Frees the animation object |
| `intani_start(ani#)` | Starts the animation |
| `intani_stop(ani#)` | Stops the animation and resets to start |
| `intani_stopatcurrent(ani#)` | Stops at current value |
| `intani_propertyname#(ani#, name$)` | **REQUIRED** - Sets property to animate |
| `intani_propertyname$(ani#)` | Gets the property name |
| `intani_startvalue#(ani#, value)` | Sets the starting integer value |
| `intani_startvalue(ani#)` | Gets the starting value |
| `intani_stopvalue#(ani#, value)` | Sets the ending integer value |
| `intani_stopvalue(ani#)` | Gets the ending value |
| `intani_duration#(ani#, seconds)` | Sets duration in seconds |
| `intani_duration(ani#)` | Gets duration |
| `intani_delay#(ani#, seconds)` | Sets delay before start |
| `intani_delay(ani#)` | Gets delay |
| `intani_animationtype#(ani#, type$)` | Sets easing type: "In", "Out", "InOut" |
| `intani_animationtype$(ani#)` | Gets animation type |
| `intani_interpolation#(ani#, type$)` | Sets interpolation curve |
| `intani_interpolation$(ani#)` | Gets interpolation type |
| `intani_autoreverse#(ani#, flag)` | If 1, reverses after completing |
| `intani_autoreverse(ani#)` | Gets autoreverse flag |
| `intani_inverse#(ani#, flag)` | If 1, plays in reverse |
| `intani_inverse(ani#)` | Gets inverse flag |
| `intani_loop#(ani#, flag)` | If 1, loops indefinitely |
| `intani_loop(ani#)` | Gets loop flag |
| `intani_enabled#(ani#, flag)` | Enables/disables animation |
| `intani_enabled(ani#)` | Gets enabled state |
| `intani_startfromcurrent#(ani#, flag)` | If 1, starts from current property value |
| `intani_startfromcurrent(ani#)` | Gets startfromcurrent flag |
| `intani_running(ani#)` | Returns 1 if animation is running |
| `intani_normalizedtime(ani#)` | Returns progress 0.0-1.0 |
| `intani_name$(ani#)` | Gets the animation name |
| `intani_trigger#(ani#, expr$)` | Sets trigger expression |
| `intani_trigger$(ani#)` | Gets trigger expression |
| `intani_triggerinverse#(ani#, expr$)` | Sets inverse trigger |
| `intani_triggerinverse$(ani#)` | Gets inverse trigger |
| `intani_onfinish#(ani#, callback$)` | Sets finish callback function |
| `intani_onfinish$(ani#)` | Gets finish callback name |
| `intani_onprocess#(ani#, callback$)` | Sets per-frame callback |
| `intani_onprocess$(ani#)` | Gets process callback name |
| `intani_clearcallbacks#(ani#)` | Removes all callbacks |
| `intani_error()` | Returns last error code |
| `intani_errormsg$()` | Returns last error message |
| `intani_strerror$(code)` | Converts error code to message |
| `intani_clearerror()` | Clears the error state |

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

## Example: Counter Animation (0 to 100)

```basic
' Animate a counter from 0 to 100
let frm# = form#("Counter Demo", 400, 200)
let lbl# = label#(frm#, "Count: 0")
label_move#(lbl#, 130, 80)
label_fontsize#(lbl#, 28)

' Create animation attached to label
let intAni# = intani#(lbl#)
intani_propertyname#(intAni#, "Tag")
intani_startvalue#(intAni#, 0)
intani_stopvalue#(intAni#, 100)
intani_duration#(intAni#, 5.0)
intani_interpolation#(intAni#, "Linear")
intani_onprocess#(intAni#, "updatecount")
intani_start(intAni#)

form_show(frm#)

function updatecount(sender#) local tagval
    tagval = label_tag(lbl#)
    label_text#(lbl#, "Count: " + str$(tagval))
end function
```

## Example: Countdown Timer (10 to 0)

```basic
' Countdown from 10 to 0 using normalizedtime
let frm# = form#("Countdown Demo", 300, 200)
let lbl# = label#(frm#, "10")
label_move#(lbl#, 120, 70)
label_fontsize#(lbl#, 48)

let intAni# = intani#(lbl#)
intani_propertyname#(intAni#, "Tag")
intani_startvalue#(intAni#, 10)
intani_stopvalue#(intAni#, 0)
intani_duration#(intAni#, 10.0)
intani_interpolation#(intAni#, "Linear")
intani_onprocess#(intAni#, "showcountdown")
intani_onfinish#(intAni#, "countdone")
intani_start(intAni#)

form_show(frm#)

function showcountdown(sender#) local progress, current
    progress = intani_normalizedtime(intAni#)
    current = int(10 - 10 * progress)
    label_text#(lbl#, str$(current))
    println current
end function

function countdone(sender#)
    label_text#(lbl#, "Done!")
end function
```

## Example: Progress Bar

```basic
' Animated progress bar 0% to 100%
let frm# = form#("Progress Demo", 400, 150)

let progressBg# = rectangle#(frm#)
rectangle_bounds#(progressBg#, 50, 50, 300, 30)
rectangle_fill#(progressBg#, "LightGray")

let progressBar# = rectangle#(frm#)
rectangle_bounds#(progressBar#, 50, 50, 0, 30)
rectangle_fill#(progressBar#, "Green")

let lbl# = label#(frm#, "0%")
label_move#(lbl#, 180, 90)

' Animate the progress bar's Tag to track percentage
let intAni# = intani#(progressBar#)
intani_propertyname#(intAni#, "Tag")
intani_startvalue#(intAni#, 0)
intani_stopvalue#(intAni#, 100)
intani_duration#(intAni#, 3.0)
intani_interpolation#(intAni#, "Quadratic")
intani_animationtype#(intAni#, "Out")
intani_onprocess#(intAni#, "updateprogress")
intani_start(intAni#)

form_show(frm#)

function updateprogress(sender#) local pct, progress
    progress = intani_normalizedtime(intAni#)
    pct = int(100 - 100 * progress)
    label_text#(lbl#, str$(pct) + "%")
    rectangle_width#(progressBar#, pct * 3)
end function
```

## Example: Score with Bounce Effect

```basic
' Score increases with bounce easing
let frm# = form#("Score Demo", 400, 200)
let lbl# = label#(frm#, "Score: 0")
label_move#(lbl#, 120, 80)
label_fontsize#(lbl#, 24)

let intAni# = intani#(lbl#)
intani_propertyname#(intAni#, "Tag")
intani_startvalue#(intAni#, 0)
intani_stopvalue#(intAni#, 1000)
intani_duration#(intAni#, 2.0)
intani_interpolation#(intAni#, "Bounce")
intani_animationtype#(intAni#, "Out")
intani_onprocess#(intAni#, "updatescore")
intani_start(intAni#)

form_show(frm#)

function updatescore(sender#) local score
    score = intani_normalizedtime(intAni#)
    label_text#(lbl#, "Score: " + str$(score))
end function
```

## Critical Requirements

1. **PropertyName is REQUIRED** - The animation won't run without `intani_propertyname#(ani#, "Tag")`
2. **Local variables** - Declare on the same line as function: `function name(sender#) local var1, var2`
3. **Parent control** - The animation must be attached to a visual control

## Notes

- The `Tag` property is an integer available on all visual controls
- Use `onprocess` callback to update UI based on the animated Tag value
- For visual animations (opacity, position, size), use FloatAnimationLib instead
