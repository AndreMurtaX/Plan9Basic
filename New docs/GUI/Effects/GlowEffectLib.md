# GlowEffectLib - Glow Effect Library

## Overview

The GlowEffectLib provides GPU-accelerated outer glow effects for any visual control in Plan9Basic. Glow effects create a luminous aura around controls, perfect for highlighting, sci-fi aesthetics, and visual feedback.

**Function Count**: 18 functions

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
let frm# = form#("Glow Demo", 400, 300)
let btn# = button#(frm#, "Glowing Button")
button_bounds#(btn#, 100, 100, 150, 40)

' Add outer glow
let glow# = glow#(btn#)
glow_color#(glow#, "Cyan")
glow_softness#(glow#, 4.0)
glow_opacity#(glow#, 0.8)

form_show(frm#)
```

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `glow_error()` | Returns the last error code (0 = no error) |
| `glow_errormsg$()` | Returns the last error message |
| `glow_strerror$(code)` | Converts error code to description |
| `glow_clearerror()` | Clears the error state |

**Error Codes:**

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_NIL_EFFECT | Effect pointer is nil |
| 2 | ERR_INVALID_EFFECT | Not a valid glow effect |
| 3 | ERR_INVALID_VALUE | Invalid parameter value |
| 4 | ERR_NIL_PARENT | Parent control is nil |
| 5 | ERR_INVALID_PARENT | Parent is not a valid control |
| 6 | ERR_INVALID_COLOR | Invalid color value |

---

### Creation and Destruction

#### glow#(parent#)
Creates a new glow effect attached to the specified parent control.

**Parameters:**
- `parent#` - The visual control to apply the glow effect to

**Returns:** Pointer to the new glow effect

**Default Values:**
- Softness: 4.0
- GlowColor: Yellow
- Opacity: 0.9

**Example:**
```basic
let circle# = circle#(frm#)
circle_bounds#(circle#, 50, 50, 80, 80)
let glow# = glow#(circle#)
```

---

#### glow_free(effect#)
Destroys a glow effect and releases its resources.

**Parameters:**
- `effect#` - The glow effect to destroy

**Returns:** 1 on success, 0 on failure

---

### Properties

#### glow_softness#(effect#, value) / glow_softness(effect#)
Sets or gets the glow spread/blur radius.

**Parameters:**
- `effect#` - The glow effect
- `value` - Softness (0.0 to 9.0)

**Value Range:**
- `0.0-2.0` - Tight glow, close to edge
- `2.0-5.0` - Normal glow spread
- `5.0-9.0` - Wide, diffuse glow

**Example:**
```basic
glow_softness#(glow#, 5.0)
let s = glow_softness(glow#)
```

---

#### glow_color#(effect#, color$) / glow_color(effect#)
Sets or gets the glow color.

**Parameters:**
- `effect#` - The glow effect
- `color$` - Color name or hex value

**Supported Named Colors:**
- Basic: `Black`, `White`, `Red`, `Green`, `Blue`, `Yellow`
- Extended: `Cyan`, `Magenta`, `Gray`, `Grey`, `Silver`
- Web: `Maroon`, `Olive`, `Navy`, `Purple`, `Teal`
- Bright: `Orange`, `Pink`, `Brown`, `Lime`, `Aqua`, `Fuchsia`
- Special: `Transparent`, `Null`

**Hex Format:**
- `#RRGGBB` - e.g., `#FF0000` for red
- `#AARRGGBB` - with alpha, e.g., `#80FF0000` for 50% transparent red

**Example:**
```basic
glow_color#(glow#, "Cyan")
glow_color#(glow#, "#00FFFF")
glow_color#(glow#, "#8000FF00")  ' 50% transparent green
```

---

#### glow_opacity#(effect#, value) / glow_opacity(effect#)
Sets or gets the glow intensity/transparency.

**Parameters:**
- `effect#` - The glow effect
- `value` - Opacity (0.0 to 1.0)

**Value Range:**
- `0.0` - Invisible
- `0.3-0.5` - Subtle glow
- `0.6-0.8` - Normal glow
- `0.9-1.0` - Intense glow

**Example:**
```basic
glow_opacity#(glow#, 0.8)
```

---

#### glow_enabled#(effect#, value) / glow_enabled(effect#)
Enables or disables the glow effect.

**Example:**
```basic
glow_enabled#(glow#, 0)  ' Hide glow
glow_enabled#(glow#, 1)  ' Show glow
```

---

#### glow_trigger#(effect#, trigger$) / glow_trigger$(effect#)
Sets or gets the trigger string for automatic effect activation.

**Example:**
```basic
' Show glow only on hover
glow_trigger#(glow#, "IsMouseOver=true")
```

---

## Examples

### Example 1: Neon Button

```basic
let frm# = form#("Neon Button", 400, 250)

' Dark background
let bg# = rectangle#(frm#)
rectangle_bounds#(bg#, 0, 0, 400, 250)
rectangle_fill#(bg#, "#1a1a2e")

' Neon button
let btn# = rectangle#(bg#)
rectangle_bounds#(btn#, 125, 90, 150, 50)
rectangle_fill#(btn#, "#1a1a2e")
rectangle_stroke#(btn#, "Cyan")
rectangle_strokethickness#(btn#, 2)
rectangle_corners#(btn#, 8, 8)

let lbl# = label#(btn#, "NEON", 55, 15)
label_fontcolor#(lbl#, "White")

' Cyan glow
let glow# = glow#(btn#)
glow_color#(glow#, "Cyan")
glow_softness#(glow#, 5.0)
glow_opacity#(glow#, 0.9)

form_show(frm#)
```

---

### Example 2: Neon Button Gallery

```basic
let frm# = form#("Neon Gallery", 500, 200)

let bg# = rectangle#(frm#)
rectangle_bounds#(bg#, 0, 0, 500, 200)
rectangle_fill#(bg#, "#0d0d0d")

' Create neon buttons
CreateNeonBtn(bg#, 30, 70, "PLAY", "Lime")
CreateNeonBtn(bg#, 140, 70, "STOP", "Red")
CreateNeonBtn(bg#, 250, 70, "INFO", "Cyan")
CreateNeonBtn(bg#, 360, 70, "WARN", "Orange")

form_show(frm#)

function CreateNeonBtn(parent#, x, y, text$, color$) local btn#, lbl#, glow#
  btn# = rectangle#(parent#)
  rectangle_bounds#(btn#, x, y, 90, 40)
  rectangle_fill#(btn#, "#0d0d0d")
  rectangle_stroke#(btn#, color$)
  rectangle_strokethickness#(btn#, 2)
  rectangle_corners#(btn#, 5, 5)
  
  lbl# = label#(btn#, text$, 25, 10)
  label_fontcolor#(lbl#, "White")
  
  glow# = glow#(btn#)
  glow_color#(glow#, color$)
  glow_softness#(glow#, 4.0)
  glow_opacity#(glow#, 0.8)
endfunction
```

---

### Example 3: Pulsing Glow Animation

```basic
let frm# = form#("Pulsing Glow", 400, 300)

let bg# = rectangle#(frm#)
rectangle_bounds#(bg#, 0, 0, 400, 300)
rectangle_fill#(bg#, "#1e1e1e")

let circle# = circle#(bg#)
circle_bounds#(circle#, 150, 100, 100, 100)
circle_fill#(circle#, "DodgerBlue")

let glow# = glow#(circle#)
glow_color#(glow#, "Cyan")
glow_softness#(glow#, 3.0)
glow_opacity#(glow#, 0.9)

let btnStart# = button#(frm#, "Start Pulse")
button_bounds#(btnStart#, 100, 230, 90, 30)
button_onclick#(btnStart#, "OnStart")

let btnStop# = button#(frm#, "Stop")
button_bounds#(btnStop#, 200, 230, 90, 30)
button_onclick#(btnStop#, "OnStop")

let pulseAni# = Pointer#(0)

form_show(frm#)

function OnStart(sender#)
  pulseAni# = floatani#(glow#)
  floatani_propertyname#(pulseAni#, "Softness")
  floatani_startvalue#(pulseAni#, 2.0)
  floatani_stopvalue#(pulseAni#, 8.0)
  floatani_duration#(pulseAni#, 0.8)
  floatani_autoreverse#(pulseAni#, 1)
  floatani_loop#(pulseAni#, 1)
  floatani_interpolation#(pulseAni#, "Sinusoidal")
  floatani_animationtype#(pulseAni#, "InOut")
  floatani_start(pulseAni#)
endfunction

function OnStop(sender#) local p
  p = PntToNum(pulseAni#)
  if p <> 0 then
    floatani_stop(pulseAni#)
  endif
  glow_softness#(glow#, 3.0)
endfunction
```

---

### Example 4: Hover Glow with Trigger

```basic
' Working hover glow cards (no shadow)
let frm# = Pointer#(0)
let card1# = Pointer#(0)
let card2# = Pointer#(0)
let glow1# = Pointer#(0)
let glow2# = Pointer#(0)

frm# = form#("Hover Glow Cards", 450, 250)

let info# = label#(frm#, "Hover over the cards to see glow effect:", 30, 20)

' Card 1
card1# = rectangle#(frm#)
rectangle_bounds#(card1#, 50, 70, 150, 100)
rectangle_fill#(card1#, "White")
rectangle_corners#(card1#, 8, 8)

glow1# = glow#(card1#)
glow_color#(glow1#, "DodgerBlue")
glow_softness#(glow1#, 5.0)
glow_enabled#(glow1#, 0)

rectangle_onmouseenter#(card1#, "Card1Enter")
rectangle_onmouseleave#(card1#, "Card1Leave")

let lbl1# = label#(card1#, "Card 1", 50, 40)
label_hittest#(lbl1#, 0)

' Card 2
card2# = rectangle#(frm#)
rectangle_bounds#(card2#, 250, 70, 150, 100)
rectangle_fill#(card2#, "White")
rectangle_corners#(card2#, 8, 8)

glow2# = glow#(card2#)
glow_color#(glow2#, "LimeGreen")
glow_softness#(glow2#, 5.0)
glow_enabled#(glow2#, 0)

rectangle_onmouseenter#(card2#, "Card2Enter")
rectangle_onmouseleave#(card2#, "Card2Leave")

let lbl2# = label#(card2#, "Card 2", 50, 40)
label_hittest#(lbl2#, 0)

form_show(frm#)

function Card1Enter(sender#)
  glow_enabled#(glow1#, 1)
endfunction

function Card1Leave(sender#)
  glow_enabled#(glow1#, 0)
endfunction

function Card2Enter(sender#)
  glow_enabled#(glow2#, 1)
endfunction

function Card2Leave(sender#)
  glow_enabled#(glow2#, 0)
endfunction
```

---

### Example 5: Selection Indicator

```basic
' Selection Glow - Full version with ClearSelection
let frm# = Pointer#(0)
let item0# = Pointer#(0)
let item1# = Pointer#(0)
let item2# = Pointer#(0)
let item3# = Pointer#(0)
let glow0# = Pointer#(0)
let glow1# = Pointer#(0)
let glow2# = Pointer#(0)
let glow3# = Pointer#(0)
let selected = -1

frm# = form#("Selection Glow", 400, 350)

' Item 0
item0# = rectangle#(frm#)
rectangle_bounds#(item0#, 100, 50, 200, 55)
rectangle_fill#(item0#, "SteelBlue")
rectangle_corners#(item0#, 6, 6)
let lbl0# = label#(item0#, "Item 1", 75, 17)
label_hittest#(lbl0#, 0)
glow0# = glow#(item0#)
glow_color#(glow0#, "Gold")
glow_softness#(glow0#, 5.0)
glow_enabled#(glow0#, 0)
rectangle_onclick#(item0#, "SelectItem0")

' Item 1
item1# = rectangle#(frm#)
rectangle_bounds#(item1#, 100, 120, 200, 55)
rectangle_fill#(item1#, "SteelBlue")
rectangle_corners#(item1#, 6, 6)
let lbl1# = label#(item1#, "Item 2", 75, 17)
label_hittest#(lbl1#, 0)
glow1# = glow#(item1#)
glow_color#(glow1#, "Gold")
glow_softness#(glow1#, 5.0)
glow_enabled#(glow1#, 0)
rectangle_onclick#(item1#, "SelectItem1")

' Item 2
item2# = rectangle#(frm#)
rectangle_bounds#(item2#, 100, 190, 200, 55)
rectangle_fill#(item2#, "SteelBlue")
rectangle_corners#(item2#, 6, 6)
let lbl2# = label#(item2#, "Item 3", 75, 17)
label_hittest#(lbl2#, 0)
glow2# = glow#(item2#)
glow_color#(glow2#, "Gold")
glow_softness#(glow2#, 5.0)
glow_enabled#(glow2#, 0)
rectangle_onclick#(item2#, "SelectItem2")

' Item 3
item3# = rectangle#(frm#)
rectangle_bounds#(item3#, 100, 260, 200, 55)
rectangle_fill#(item3#, "SteelBlue")
rectangle_corners#(item3#, 6, 6)
let lbl3# = label#(item3#, "Item 4", 75, 17)
label_hittest#(lbl3#, 0)
glow3# = glow#(item3#)
glow_color#(glow3#, "Gold")
glow_softness#(glow3#, 5.0)
glow_enabled#(glow3#, 0)
rectangle_onclick#(item3#, "SelectItem3")

let info# = label#(frm#, "Click an item to select it", 115, 325)

form_show(frm#)

function ClearSelection()
  glow_enabled#(glow0#, 0)
  glow_enabled#(glow1#, 0)
  glow_enabled#(glow2#, 0)
  glow_enabled#(glow3#, 0)
endfunction

function SelectItem0(sender#)
  ClearSelection()
  glow_enabled#(glow0#, 1)
  selected = 0
endfunction

function SelectItem1(sender#)
  ClearSelection()
  glow_enabled#(glow1#, 1)
  selected = 1
endfunction

function SelectItem2(sender#)
  ClearSelection()
  glow_enabled#(glow2#, 1)
  selected = 2
endfunction

function SelectItem3(sender#)
  ClearSelection()
  glow_enabled#(glow3#, 1)
  selected = 3
endfunction
```

---

## Animatable Properties

| Property | Type | Range |
|----------|------|-------|
| Softness | Single | 0.0-9.0 |
| Opacity | Single | 0.0-1.0 |

Both properties can be animated using FloatAnimationLib:

```basic
' Pulsing glow
let ani# = floatani#(glow#)
floatani_propertyname#(ani#, "Softness")
floatani_startvalue#(ani#, 2.0)
floatani_stopvalue#(ani#, 7.0)
floatani_duration#(ani#, 1.0)
floatani_autoreverse#(ani#, 1)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

---

## Common Use Cases

1. **Selection Highlighting**: Show which item is selected
2. **Hover Feedback**: Visual response to mouse interaction
3. **Neon/Sci-Fi UI**: Create futuristic interfaces
4. **Alert Indicators**: Pulsing glow for notifications
5. **Focus States**: Indicate active input fields

---

## Performance Notes

1. **GPU Accelerated**: Glow effects use GPU shaders efficiently.

2. **Large Softness**: Very high softness values (>7) may impact performance on mobile devices.

3. **Opacity**: Lower opacity values render faster than full opacity.

---

## See Also

- `BlurEffectLib` - Blur effects
- `ShadowEffectLib` - Drop shadow effects  
- `FloatAnimationLib` - Animate effect properties
