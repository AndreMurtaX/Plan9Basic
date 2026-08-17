# ShadowEffectLib - Shadow Effect Library

## Overview

The ShadowEffectLib provides GPU-accelerated drop shadow effects for any visual control in Plan9Basic. Drop shadows add depth and visual hierarchy to UI elements.

**Function Count**: 24 functions

## Platform Support

- ✅ Windows (Win32/Win64)
- ✅ macOS (Intel/ARM)
- ✅ Linux
- ✅ Android
- ✅ iOS

---

## Quick Start

```basic
' Create a form with a button
let frm# = form#("Shadow Demo", 400, 300)
let btn# = button#(frm#, "Click Me")
button_bounds#(btn#, 100, 100, 120, 40)

' Add drop shadow
let shadow# = shadow#(btn#)
shadow_distance#(shadow#, 5)
shadow_direction#(shadow#, 45)
shadow_softness#(shadow#, 0.4)

form_show(frm#)
```

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `shadow_error@` | Returns the last error code (0 = no error) |
| `shadow_errormsg$@` | Returns the last error message |
| `shadow_strerror$@n` | Converts error code to description |
| `shadow_clearerror@` | Clears the error state |

**Error Codes:**

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_NIL_EFFECT | Effect pointer is nil |
| 2 | ERR_INVALID_EFFECT | Not a valid shadow effect |
| 3 | ERR_INVALID_VALUE | Invalid parameter value |
| 4 | ERR_NIL_PARENT | Parent control is nil |
| 5 | ERR_INVALID_PARENT | Parent is not a valid control |
| 6 | ERR_INVALID_COLOR | Invalid color value |

---

### Creation and Destruction

#### shadow#(parent#)
Creates a new shadow effect attached to the specified parent control.

**Parameters:**
- `parent#` - The visual control to apply the shadow effect to

**Returns:** Pointer to the new shadow effect

**Default Values:**
- Distance: 3
- Direction: 45 degrees
- Softness: 0.3
- Opacity: 0.6
- ShadowColor: Black

**Example:**
```basic
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 150, 100)
let shadow# = shadow#(rect#)
```

---

#### shadow_free(effect#)
Destroys a shadow effect and releases its resources.

**Parameters:**
- `effect#` - The shadow effect to destroy

**Returns:** 1 on success, 0 on failure

---

### Properties

#### shadow_distance#(effect#, value) / shadow_distance(effect#)
Sets or gets the shadow offset distance from the parent control.

**Parameters:**
- `effect#` - The shadow effect
- `value` - Distance in pixels (0 to 50)

**Value Range:**
- `0-5` - Subtle, close shadow
- `5-15` - Normal drop shadow
- `15-30` - Distant shadow (elevated look)
- `30-50` - Very distant shadow

**Example:**
```basic
shadow_distance#(shadow#, 8)
let d = shadow_distance(shadow#)
```

---

#### shadow_direction#(effect#, value) / shadow_direction(effect#)
Sets or gets the angle of the shadow in degrees.

**Parameters:**
- `effect#` - The shadow effect
- `value` - Angle in degrees (0 to 360)

**Common Directions:**
- `45` - Bottom-right (default, natural lighting)
- `135` - Bottom-left
- `225` - Top-left
- `315` - Top-right
- `90` - Directly below
- `270` - Directly above

**Example:**
```basic
shadow_direction#(shadow#, 45)
```

---

#### shadow_softness#(effect#, value) / shadow_softness(effect#)
Sets or gets the blur/spread of the shadow.

**Parameters:**
- `effect#` - The shadow effect
- `value` - Softness (0.0 to 1.0)

**Value Range:**
- `0.0-0.2` - Sharp shadow edge
- `0.2-0.5` - Normal soft shadow
- `0.5-1.0` - Very diffuse shadow

**Example:**
```basic
shadow_softness#(shadow#, 0.4)
```

---

#### shadow_opacity#(effect#, value) / shadow_opacity(effect#)
Sets or gets the transparency of the shadow.

**Parameters:**
- `effect#` - The shadow effect
- `value` - Opacity (0.0 to 1.0)

**Value Range:**
- `0.0` - Invisible
- `0.3-0.5` - Subtle shadow
- `0.5-0.8` - Normal shadow
- `1.0` - Fully opaque (harsh)

**Example:**
```basic
shadow_opacity#(shadow#, 0.6)
```

---

#### shadow_color#(effect#, color$) / shadow_color(effect#)
Sets or gets the shadow color.

**Parameters:**
- `effect#` - The shadow effect
- `color$` - Color name or hex value

**Supported Colors:**
- Named: `"Black"`, `"Gray"`, `"Navy"`, etc.
- Hex: `"#000000"`, `"#404040"`

**Example:**
```basic
shadow_color#(shadow#, "Gray")
shadow_color#(shadow#, "#404040")
```

---

#### shadow_enabled#(effect#, value) / shadow_enabled(effect#)
Enables or disables the shadow effect.

**Example:**
```basic
shadow_enabled#(shadow#, 0)  ' Hide shadow
shadow_enabled#(shadow#, 1)  ' Show shadow
```

---

#### shadow_trigger#(effect#, trigger$) / shadow_trigger$(effect#)
Sets or gets the trigger string for automatic effect activation.

**Example:**
```basic
' Show shadow only on hover
shadow_trigger#(shadow#, "IsMouseOver=true")
```

---

## Examples

### Example 1: Card with Drop Shadow

```basic
let frm# = form#("Card Shadow", 400, 300)

' Create card
let card# = rectangle#(frm#)
rectangle_bounds#(card#, 100, 80, 200, 140)
rectangle_fill#(card#, "White")
rectangle_cornerradius#(card#, 8, 8)

' Card content
let title# = label#(card#, "Card Title", 20, 20)
let text# = label#(card#, "Some content here", 20, 50)

' Add shadow
let shadow# = shadow#(card#)
shadow_distance#(shadow#, 4)
shadow_direction#(shadow#, 45)
shadow_softness#(shadow#, 0.35)
shadow_opacity#(shadow#, 0.5)

form_show(frm#)
```

---

### Example 2: Button Gallery with Shadows

```basic
let frm# = form#("Button Gallery", 500, 200)

let colors$ = "Red,Green,Blue,Orange"
let i = 0

while i < 4
  let btn# = rectangle#(frm#)
  rectangle_bounds#(btn#, 30 + i * 115, 70, 100, 60)
  rectangle_cornerradius#(btn#, 6, 6)
  
  ' Alternate colors
  if i = 0 then
    rectangle_fill#(btn#, "DodgerBlue")
  endif
  if i = 1 then
    rectangle_fill#(btn#, "Coral")
  endif
  if i = 2 then
    rectangle_fill#(btn#, "MediumSeaGreen")
  endif
  if i = 3 then
    rectangle_fill#(btn#, "Orchid")
  endif
  
  ' Add shadow with increasing distance
  let sh# = shadow#(btn#)
  shadow_distance#(sh#, 3 + i * 3)
  shadow_softness#(sh#, 0.3)
  shadow_opacity#(sh#, 0.5)
  
  let lbl# = label#(btn#, "Button " + str$(i + 1), 22, 20)
  
  i = i + 1
endwhile

form_show(frm#)
```

---

### Example 3: Animated Lift Effect

```basic
let frm# = form#("Lift Effect", 400, 300)

let card# = rectangle#(frm#)
rectangle_bounds#(card#, 125, 100, 150, 100)
rectangle_fill#(card#, "White")
rectangle_cornerradius#(card#, 8, 8)

let cardLbl# = label#(card#, "Hover Me", 40, 35)

let shadow# = shadow#(card#)
shadow_distance#(shadow#, 4)
shadow_softness#(shadow#, 0.3)
shadow_opacity#(shadow#, 0.4)

let btnLift# = button#(frm#, "Lift Up")
button_bounds#(btnLift#, 100, 230, 80, 30)
button_onclick#(btnLift#, "OnLift")

let btnDrop# = button#(frm#, "Drop Down")
button_bounds#(btnDrop#, 200, 230, 80, 30)
button_onclick#(btnDrop#, "OnDrop")

form_show(frm#)

function OnLift(sender#) local ani#
  ' Animate distance to create "lift" effect
  ani# = floatani#(shadow#)
  floatani_propertyname#(ani#, "Distance")
  floatani_startvalue#(ani#, 4)
  floatani_stopvalue#(ani#, 15)
  floatani_duration#(ani#, 0.3)
  floatani_interpolation#(ani#, "Quadratic")
  floatani_animationtype#(ani#, "Out")
  floatani_start(ani#)
endfunction

function OnDrop(sender#) local ani#
  ani# = floatani#(shadow#)
  floatani_propertyname#(ani#, "Distance")
  floatani_startfromcurrent#(ani#, 1)
  floatani_stopvalue#(ani#, 4)
  floatani_duration#(ani#, 0.2)
  floatani_start(ani#)
endfunction
```

---

### Example 4: Shadow Direction Demo

```basic
let frm# = form#("Shadow Directions", 500, 400)

let angles$ = "45,135,225,315"
let labels$ = "SE,SW,NW,NE"

let i = 0
while i < 4
  let x = 80 + (i mod 2) * 200
  let y = 80 + int(i / 2) * 160
  
  let rect# = rectangle#(frm#)
  rectangle_bounds#(rect#, x, y, 120, 80)
  rectangle_fill#(rect#, "SteelBlue")
  rectangle_cornerradius#(rect#, 6, 6)
  
  let sh# = shadow#(rect#)
  shadow_distance#(sh#, 10)
  shadow_softness#(sh#, 0.4)
  
  ' Set direction based on index
  if i = 0 then
    shadow_direction#(sh#, 45)
    let lbl# = label#(rect#, "45 deg (SE)", 15, 30)
  endif
  if i = 1 then
    shadow_direction#(sh#, 135)
    let lbl# = label#(rect#, "135 deg (SW)", 10, 30)
  endif
  if i = 2 then
    shadow_direction#(sh#, 225)
    let lbl# = label#(rect#, "225 deg (NW)", 10, 30)
  endif
  if i = 3 then
    shadow_direction#(sh#, 315)
    let lbl# = label#(rect#, "315 deg (NE)", 10, 30)
  endif
  
  i = i + 1
endwhile

form_show(frm#)
```

---

## Animatable Properties

| Property | Type | Range |
|----------|------|-------|
| Distance | Single | 0-50 |
| Direction | Single | 0-360 |
| Softness | Single | 0.0-1.0 |
| Opacity | Single | 0.0-1.0 |

All properties can be animated using FloatAnimationLib:

```basic
let ani# = floatani#(shadow#)
floatani_propertyname#(ani#, "Distance")
floatani_startvalue#(ani#, 4)
floatani_stopvalue#(ani#, 12)
floatani_duration#(ani#, 0.3)
floatani_start(ani#)
```

---

## Performance Notes

1. **GPU Accelerated**: Shadow effects use GPU shaders efficiently.

2. **Large Shadows**: Very large distance values (>30) with high softness may impact performance on mobile.

3. **Multiple Shadows**: Each shadow effect has minimal overhead, but avoid excessive use.

---

## See Also

- `BlurEffectLib` - Blur effects
- `GlowEffectLib` - Outer glow effects  
- `FloatAnimationLib` - Animate effect properties
