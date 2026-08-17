# BevelEffectLib Documentation

## Overview

BevelEffectLib provides FireMonkey TBevelEffect wrapper functionality for creating 3D bevel/emboss effects on visual controls in Plan9Basic programs. This effect creates raised or sunken appearances with adjustable light direction.

**Version:** 1.0.0  
**Function Count:** 18 functions  
**Effect Type:** Static (properties apply immediately)

## Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Direction | 0 - 360 | 45 | Light source angle in degrees |
| Size | 0 - 10 | 1 | Bevel edge size in pixels |
| Enabled | 0/1 | 1 | Turn effect on/off |
| Trigger | String | "" | Conditional activation expression |

## Direction Values (Light Source Position)

| Angle | Position | Effect |
|-------|----------|--------|
| 0/360 | Right | Light from right side |
| 45 | Top-right | Default, classic emboss |
| 90 | Top | Light from above |
| 135 | Top-left | Alternate raised look |
| 180 | Left | Light from left side |
| 225 | Bottom-left | Inset/sunken appearance |
| 270 | Bottom | Light from below |
| 315 | Bottom-right | Alternate sunken look |

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `bevel_error@` | Returns last error code (0 = no error) |
| `bevel_errormsg$@` | Returns last error message |
| `bevel_strerror$@n` | Converts error code to description |
| `bevel_clearerror@` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `bevel#(parent#)` | Creates bevel effect on parent control |
| `bevel_free(effect#)` | Removes and destroys the effect |

### Direction Property

| Function | Description |
|----------|-------------|
| `bevel_direction#(effect#, degrees)` | Sets light source direction (0-360) |
| `bevel_direction(effect#)` | Gets current direction in degrees |

### Size Property

| Function | Description |
|----------|-------------|
| `bevel_size#(effect#, pixels)` | Sets bevel edge size (0-10) |
| `bevel_size(effect#)` | Gets current size in pixels |

### Enabled Property

| Function | Description |
|----------|-------------|
| `bevel_enabled#(effect#, value)` | Enables (1) or disables (0) the effect |
| `bevel_enabled(effect#)` | Returns 1 if enabled, 0 if disabled |

### Trigger Property

| Function | Description |
|----------|-------------|
| `bevel_trigger#(effect#, trigger$)` | Sets conditional activation trigger |
| `bevel_trigger$(effect#)` | Gets current trigger string |

## Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_NIL_EFFECT | Effect pointer is nil |
| 2 | ERR_INVALID_EFFECT | Not a valid bevel effect |
| 3 | ERR_INVALID_VALUE | Invalid property value |
| 4 | ERR_NIL_PARENT | Parent pointer is nil |
| 5 | ERR_INVALID_PARENT | Invalid parent object |

## Examples

### Example 1: Basic Bevel Effect

```basic
' Create a button with 3D bevel
let frm# = Pointer#(0)
let btn# = Pointer#(0)
let bvl# = Pointer#(0)

frm# = form#("Bevel Demo", 400, 300)

btn# = button#(frm#, "Beveled Button")
button_bounds#(btn#, 100, 80, 180, 60)

bvl# = bevel#(btn#)
bevel_direction#(bvl#, 45)
bevel_size#(bvl#, 2)

form_show(frm#)
```

### Example 2: Raised vs Sunken

```basic
' Compare raised and sunken bevel effects
let frm# = Pointer#(0)
let raisedBtn# = Pointer#(0)
let sunkenBtn# = Pointer#(0)
let bvlRaised# = Pointer#(0)
let bvlSunken# = Pointer#(0)

frm# = form#("Raised vs Sunken", 450, 300)

' Raised button (light from top-right)
raisedBtn# = button#(frm#, "Raised")
button_bounds#(raisedBtn#, 50, 80, 150, 60)
bvlRaised# = bevel#(raisedBtn#)
bevel_direction#(bvlRaised#, 45)
bevel_size#(bvlRaised#, 3)

' Sunken button (light from bottom-left)
sunkenBtn# = button#(frm#, "Sunken")
button_bounds#(sunkenBtn#, 230, 80, 150, 60)
bvlSunken# = bevel#(sunkenBtn#)
bevel_direction#(bvlSunken#, 225)
bevel_size#(bvlSunken#, 3)

form_show(frm#)
```

### Example 3: Direction Control

```basic
' Interactive direction control
let frm# = Pointer#(0)
let targetBtn# = Pointer#(0)
let bvl# = Pointer#(0)
let statusLbl# = Pointer#(0)

frm# = form#("Direction Control", 500, 350)

targetBtn# = button#(frm#, "Target Button")
button_bounds#(targetBtn#, 150, 50, 180, 60)

bvl# = bevel#(targetBtn#)
bevel_direction#(bvl#, 45)
bevel_size#(bvl#, 3)

' Direction buttons
let btn# = Pointer#(0)

btn# = button#(frm#, "45 (TR)")
button_bounds#(btn#, 50, 150, 80, 30)
button_onclick#(btn#, "SetDir45")

btn# = button#(frm#, "90 (Top)")
button_bounds#(btn#, 140, 150, 80, 30)
button_onclick#(btn#, "SetDir90")

btn# = button#(frm#, "135 (TL)")
button_bounds#(btn#, 230, 150, 80, 30)
button_onclick#(btn#, "SetDir135")

btn# = button#(frm#, "225 (BL)")
button_bounds#(btn#, 320, 150, 80, 30)
button_onclick#(btn#, "SetDir225")

statusLbl# = label#(frm#, "Direction: 45 degrees (Top-Right)", 120, 220)

form_show(frm#)

function SetDir45(sender#)
  bevel_direction#(bvl#, 45)
  label_text#(statusLbl#, "Direction: 45 degrees (Top-Right)")
endfunction

function SetDir90(sender#)
  bevel_direction#(bvl#, 90)
  label_text#(statusLbl#, "Direction: 90 degrees (Top)")
endfunction

function SetDir135(sender#)
  bevel_direction#(bvl#, 135)
  label_text#(statusLbl#, "Direction: 135 degrees (Top-Left)")
endfunction

function SetDir225(sender#)
  bevel_direction#(bvl#, 225)
  label_text#(statusLbl#, "Direction: 225 degrees (Bottom-Left)")
endfunction
```

### Example 4: Size Comparison Gallery

```basic
' Gallery showing different bevel sizes
let frm# = Pointer#(0)
let i = 0

frm# = form#("Bevel Size Gallery", 600, 250)

let lbl# = label#(frm#, "Bevel sizes 1-5:", 50, 20)

while i < 5
  let galleryBtn# = Pointer#(0)
  let galleryBvl# = Pointer#(0)
  let sizeLbl# = Pointer#(0)
  let size = 0
  
  galleryBtn# = button#(frm#, "Size " + str$(i + 1))
  button_bounds#(galleryBtn#, 40 + i * 110, 60, 100, 60)
  
  galleryBvl# = bevel#(galleryBtn#)
  size = i + 1
  bevel_direction#(galleryBvl#, 45)
  bevel_size#(galleryBvl#, size)
  
  sizeLbl# = label#(frm#, "Size: " + str$(size), 60 + i * 110, 130)
  
  i = i + 1
endwhile

form_show(frm#)
```

### Example 5: Animated Light Direction

```basic
' Rotating light source animation
let frm# = Pointer#(0)
let btn# = Pointer#(0)
let bvl# = Pointer#(0)

frm# = form#("Animated Bevel", 400, 300)

btn# = button#(frm#, "Rotating Light")
button_bounds#(btn#, 100, 50, 180, 80)

bvl# = bevel#(btn#)
bevel_size#(bvl#, 4)

let startBtn# = button#(frm#, "Start Animation")
button_bounds#(startBtn#, 100, 160, 180, 40)
button_onclick#(startBtn#, "StartAni")

form_show(frm#)

function StartAni(sender#) local ani#
  ani# = floatani#(bvl#)
  floatani_propertyname#(ani#, "Direction")
  floatani_startvalue#(ani#, 0)
  floatani_stopvalue#(ani#, 360)
  floatani_duration#(ani#, 3)
  floatani_loop#(ani#, 1)
  floatani_start(ani#)
endfunction
```

### Example 6: Press Effect (Raised to Sunken)

```basic
' Button that appears to press down
let frm# = Pointer#(0)
let btn# = Pointer#(0)
let bvl# = Pointer#(0)

frm# = form#("Press Effect", 400, 300)

btn# = button#(frm#, "Press Me!")
button_bounds#(btn#, 100, 80, 180, 60)
button_onclick#(btn#, "OnPress")

bvl# = bevel#(btn#)
bevel_direction#(bvl#, 45)  ' Raised
bevel_size#(bvl#, 3)

form_show(frm#)

function OnPress(sender#) local currentDir
  currentDir = bevel_direction(bvl#)
  if currentDir < 180 then
    bevel_direction#(bvl#, 225)  ' Sunken
  else
    bevel_direction#(bvl#, 45)   ' Raised
  endif
endfunction
```

## Animation Support

Bevel properties can be animated using FloatAnimationLib:

```basic
' Animate direction for rotating light effect
let ani# = Pointer#(0)
ani# = floatani#(bvl#)
floatani_propertyname#(ani#, "Direction")
floatani_startvalue#(ani#, 0)
floatani_stopvalue#(ani#, 360)
floatani_duration#(ani#, 2.0)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

### Animatable Properties

| Property | Description |
|----------|-------------|
| Direction | Animate light source rotation |
| Size | Animate bevel intensity |

## Common Trigger Strings

| Trigger | Description |
|---------|-------------|
| `IsMouseOver=true` | Activates when mouse hovers |
| `IsFocused=true` | Activates when control has focus |
| `IsPressed=true` | Activates when pressed |

## Design Tips

### Creating Raised Appearance
```basic
bevel_direction#(bvl#, 45)   ' Light from top-right
bevel_size#(bvl#, 2)
```

### Creating Sunken/Inset Appearance
```basic
bevel_direction#(bvl#, 225)  ' Light from bottom-left
bevel_size#(bvl#, 2)
```

### Press/Release Effect
Change direction on click:
- Normal (raised): 45 degrees
- Pressed (sunken): 225 degrees

## Performance Notes

- Bevel effect is GPU-accelerated
- Minimal performance impact
- Safe to use on multiple controls
- Direction animation is smooth

## Best Practices

1. Use consistent light direction across UI (typically 45°)
2. Keep size moderate (1-3) for subtle effects
3. Use sunken appearance for pressed states
4. Combine with shadow for enhanced depth
5. Test visibility on different backgrounds

## See Also

- ShadowEffectLib - Drop shadow effects
- GlowEffectLib - Outer glow effects
- InnerGlowEffectLib - Inner glow effects
- FloatAnimationLib - Property animation
