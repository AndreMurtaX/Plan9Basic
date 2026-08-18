# BlurEffectLib - Blur Effect Library

## Overview

The BlurEffectLib provides GPU-accelerated blur effects for any visual control in Plan9Basic. The blur effect softens the appearance of the parent control by averaging neighboring pixels.

**Function Count**: 12 functions

## Platform Support

- ✅ Windows (Win32/Win64)
- ✅ macOS (Intel/ARM)
- ✅ Linux
- ✅ Android
- ✅ iOS

---

## Quick Start

```basic
' Create a form with a rectangle
let frm# = form#("Blur Demo", 400, 300)
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 200, 150)
rectangle_fill#(rect#, "Blue")

' Add blur effect
let blur# = blur#(rect#)
blur_softness#(blur#, 1.5)

form_show(frm#)
```

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `blur_error()` | Returns the last error code (0 = no error) |
| `blur_errormsg$()` | Returns the last error message |
| `blur_strerror$(code)` | Converts error code to description |
| `blur_clearerror()` | Clears the error state |

**Error Codes:**

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_NIL_EFFECT | Effect pointer is nil |
| 2 | ERR_INVALID_EFFECT | Not a valid blur effect |
| 3 | ERR_INVALID_VALUE | Invalid parameter value |
| 4 | ERR_NIL_PARENT | Parent control is nil |
| 5 | ERR_INVALID_PARENT | Parent is not a valid control |

---

### Creation and Destruction

#### blur#(parent#)
Creates a new blur effect attached to the specified parent control.

**Parameters:**
- `parent#` - The visual control to apply the blur effect to

**Returns:** Pointer to the new blur effect

**Example:**
```basic
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 0, 0, 200, 150)
let blur# = blur#(rect#)
```

---

#### blur_free(effect#)
Destroys a blur effect and releases its resources.

**Parameters:**
- `effect#` - The blur effect to destroy

**Returns:** 1 on success, 0 on failure

**Example:**
```basic
blur_free(blur#)
```

---

### Properties

#### blur_softness#(effect#, value) / blur_softness(effect#)
Sets or gets the blur intensity.

**Parameters:**
- `effect#` - The blur effect
- `value` - Blur intensity (0.0 to 3.0)

**Value Range:**
- `0.0` - No blur (sharp)
- `0.4` - Default value (slight blur)
- `1.0` - Moderate blur
- `2.0` - Heavy blur
- `3.0` - Maximum blur

**Example:**
```basic
blur_softness#(blur#, 2.0)  ' Set strong blur
let s = blur_softness(blur#) ' Get current value
println "Softness: " + stri$(s)
```

---

#### blur_enabled#(effect#, value) / blur_enabled(effect#)
Enables or disables the blur effect.

**Parameters:**
- `effect#` - The blur effect
- `value` - 1 to enable, 0 to disable

**Example:**
```basic
blur_enabled#(blur#, 0)  ' Disable blur
blur_enabled#(blur#, 1)  ' Enable blur
```

---

#### blur_trigger#(effect#, trigger$) / blur_trigger$(effect#)
Sets or gets the trigger string for automatic effect activation.

**Parameters:**
- `effect#` - The blur effect
- `trigger$` - Trigger condition string

**Common Triggers:**
- `"IsMouseOver=true"` - Apply when mouse hovers
- `"IsFocused=true"` - Apply when control has focus
- `"IsPressed=true"` - Apply when pressed

**Example:**
```basic
' Apply blur when mouse hovers over the control
blur_trigger#(blur#, "IsMouseOver=true")
```

---

## Examples

### Example 1: Simple Blur on Rectangle

```basic
let frm# = form#("Simple Blur", 400, 300)

let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 75, 200, 150)
rectangle_fill#(rect#, "DodgerBlue")
rectangle_corners#(rect#, 10, 10)

' Add label inside
let lbl# = label#(rect#, "Blurred Box", 50, 60)

' Apply blur
let blur# = blur#(rect#)
blur_softness#(blur#, 1.5)

form_show(frm#)
```

---

### Example 2: Toggle Blur with Button

```basic
let frm# = form#("Toggle Blur", 400, 350)

let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 100, 50, 200, 150)
rectangle_fill#(rect#, "Green")

let blur# = blur#(rect#)
blur_softness#(blur#, 2.0)
blur_enabled#(blur#, 0)  ' Start disabled

let btn# = button#(frm#, "Enable Blur")
button_bounds#(btn#, 150, 230, 100, 30)
button_onclick#(btn#, "OnToggle")

form_show(frm#)

function OnToggle(sender#) local isOn
  isOn = blur_enabled(blur#)
  if isOn = 1 then
    blur_enabled#(blur#, 0)
    button_text#(btn#, "Enable Blur")
  else
    blur_enabled#(blur#, 1)
    button_text#(btn#, "Disable Blur")
  end if
end function
```

---

### Example 3: Animated Blur

```basic
let frm# = form#("Animated Blur", 400, 300)

let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 300, 150)
rectangle_fill#(rect#, "Purple")

' Create blur starting at 0
let blur# = blur#(rect#)
blur_softness#(blur#, 0.0)

let btnBlur# = button#(frm#, "Blur In")
button_bounds#(btnBlur#, 50, 220, 80, 30)
button_onclick#(btnBlur#, "OnBlurIn")

let btnClear# = button#(frm#, "Blur Out")
button_bounds#(btnClear#, 140, 220, 80, 30)
button_onclick#(btnClear#, "OnBlurOut")

form_show(frm#)

function OnBlurIn(sender#) local ani#
  ani# = floatani#(blur#)
  floatani_propertyname#(ani#, "Softness")
  floatani_startvalue#(ani#, 0.0)
  floatani_stopvalue#(ani#, 3.0)
  floatani_duration#(ani#, 1.0)
  floatani_start(ani#)
end function

function OnBlurOut(sender#) local ani#
  ani# = floatani#(blur#)
  floatani_propertyname#(ani#, "Softness")
  floatani_startfromcurrent#(ani#, 1)
  floatani_stopvalue#(ani#, 0.0)
  floatani_duration#(ani#, 1.0)
  floatani_start(ani#)
end function
```

---

### Example 4: Hover Blur Using Trigger

```basic
let frm# = form#("Hover Blur", 500, 300)

' Rectangle that blurs on hover
let rect1# = rectangle#(frm#)
rectangle_bounds#(rect1#, 50, 80, 180, 120)
rectangle_fill#(rect1#, "Red")

let lbl1# = label#(rect1#, "Hover = Blur", 40, 45)

let blur1# = blur#(rect1#)
blur_softness#(blur1#, 2.5)
blur_trigger#(blur1#, "IsMouseOver=true")

' Second rectangle - always sharp
let rect2# = rectangle#(frm#)
rectangle_bounds#(rect2#, 270, 80, 180, 120)
rectangle_fill#(rect2#, "Blue")

let lbl2# = label#(rect2#, "No Trigger", 45, 45)

let info# = label#(frm#, "Move mouse over red box to see blur trigger", 50, 230)

form_show(frm#)
```

---

## Performance Notes

1. **GPU Accelerated**: Blur effects use GPU shaders and are efficient on modern hardware.

2. **Mobile Considerations**: On older mobile devices, heavy blur (Softness > 2.0) may impact frame rate.

3. **Effect Stacking**: Multiple effects on the same control are processed sequentially.

4. **Animation**: When animating blur properties via FloatAnimationLib, the GPU handles interpolation efficiently.

---

## See Also

- `ShadowEffectLib` - Drop shadow effects
- `GlowEffectLib` - Outer glow effects  
- `FloatAnimationLib` - Animate effect properties
