# Plan9Basic Tier-1 Effects Quick Reference

## Overview

This document provides a quick reference for all 8 tier-1 visual effects in Plan9Basic. All effects are GPU-accelerated and work across all supported platforms.

## Library Summary

| Library | Effect | Key Properties | Functions |
|---------|--------|----------------|-----------|
| BlurEffectLib | Gaussian blur | Softness (0-3) | 14 |
| ShadowEffectLib | Drop shadow | Distance, Direction, Color, Softness, Opacity | 24 |
| GlowEffectLib | Outer glow | Color, Softness (0-9), Opacity | 18 |
| ReflectionEffectLib | Mirror reflection | Length, Opacity, Offset | 18 |
| ColorKeyAlphaEffectLib | Color transparency | ColorKey, Tolerance | 16 |
| MonochromeEffectLib | Grayscale | Enabled only | 12 |
| InnerGlowEffectLib | Inner glow | Color, Softness (0-9), Opacity | 18 |
| BevelEffectLib | 3D bevel/emboss | Direction (0-360), Size (0-10) | 18 |

## Quick Usage Patterns

### BlurEffect
```basic
let blur# = blur#(control#)
blur_softness#(blur#, 2.0)           ' 0-3
blur_trigger#(blur#, "IsMouseOver=true")
```

### ShadowEffect
```basic
let shd# = shadow#(control#)
shadow_distance#(shd#, 5)
shadow_direction#(shd#, 315)          ' 0-360 degrees
shadow_color#(shd#, "Black")
shadow_softness#(shd#, 3)             ' 0-3
shadow_opacity#(shd#, 0.6)            ' 0-1
```

### GlowEffect
```basic
let glow# = glow#(control#)
glow_color#(glow#, "Cyan")
glow_softness#(glow#, 4)              ' 0-9
glow_opacity#(glow#, 0.9)             ' 0-1
```

### ReflectionEffect
```basic
let refl# = reflection#(control#)
reflection_length#(refl#, 0.4)        ' 0-1
reflection_opacity#(refl#, 0.3)       ' 0-1
reflection_offset#(refl#, 2)          ' pixels
```

### ColorKeyAlphaEffect
```basic
let ck# = colorkey#(control#)
colorkey_color#(ck#, "Lime")          ' Green screen
colorkey_tolerance#(ck#, 0.1)         ' 0-1
```

### MonochromeEffect
```basic
let mono# = monochrome#(control#)
' Binary on/off - no additional properties
monochrome_enabled#(mono#, 1)
```

### InnerGlowEffect
```basic
let ig# = innerglow#(control#)
innerglow_color#(ig#, "Gold")
innerglow_softness#(ig#, 4)           ' 0-9
innerglow_opacity#(ig#, 0.8)          ' 0-1
```

### BevelEffect
```basic
let bvl# = bevel#(control#)
bevel_direction#(bvl#, 45)            ' 0-360 (45=raised, 225=sunken)
bevel_size#(bvl#, 3)                  ' 0-10 pixels
```

## Common Functions (All Libraries)

Each library provides these standard functions:

| Function Pattern | Description |
|-----------------|-------------|
| `{effect}_error@` | Get last error code |
| `{effect}_errormsg$@` | Get last error message |
| `{effect}_strerror$@n` | Convert code to description |
| `{effect}_clearerror@` | Clear error state |
| `{effect}#(parent#)` | Create effect on control |
| `{effect}_free(effect#)` | Remove and destroy effect |
| `{effect}_enabled#(effect#, n)` | Enable/disable |
| `{effect}_enabled(effect#)` | Get enabled state |
| `{effect}_trigger#(effect#, s$)` | Set trigger string |
| `{effect}_trigger$(effect#)` | Get trigger string |

## Common Trigger Strings

| Trigger | Description |
|---------|-------------|
| `IsMouseOver=true` | Mouse hovering over control |
| `IsMouseOver=false` | Mouse NOT hovering |
| `IsFocused=true` | Control has keyboard focus |
| `IsFocused=false` | Control lacks focus |
| `IsPressed=true` | Control being pressed |

## Animation Support

All numeric properties can be animated with FloatAnimationLib:

```basic
let ani# = floatani#(effect#)
floatani_propertyname#(ani#, "PropertyName")
floatani_startvalue#(ani#, 0)
floatani_stopvalue#(ani#, 1)
floatani_duration#(ani#, 1.0)
floatani_autoreverse#(ani#, 1)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

### Animatable Properties by Effect

| Effect | Animatable Properties |
|--------|----------------------|
| Blur | Softness |
| Shadow | Distance, Direction, Softness, Opacity |
| Glow | Softness, Opacity |
| Reflection | Length, Opacity, Offset |
| ColorKey | Tolerance |
| Monochrome | (none - binary) |
| InnerGlow | Softness, Opacity |
| Bevel | Direction, Size |

## Color Format

All color properties accept:
- Named colors: `"Red"`, `"Blue"`, `"Cyan"`, `"Gold"`, etc.
- Hex RGB: `"#RRGGBB"` (e.g., `"#FF6600"`)
- Hex ARGB: `"#AARRGGBB"` (e.g., `"#80FF0000"`)

### Common Named Colors
Black, White, Red, Green, Blue, Yellow, Cyan, Magenta, Lime, Gold, Orange, Pink, Purple, Gray, Silver, Navy, Teal, Aqua, Fuchsia, Maroon, Olive, Brown

## Effect Combinations

Effects can be combined on the same control:

```basic
' Professional button with shadow and glow on hover
let btn# = button#(frm#, "Styled Button")
let shd# = shadow#(btn#)
shadow_distance#(shd#, 3)
shadow_opacity#(shd#, 0.3)

let glow# = glow#(btn#)
glow_color#(glow#, "Cyan")
glow_trigger#(glow#, "IsMouseOver=true")
```

## Variable Initialization Pattern

Always initialize pointer variables:

```basic
let frm# = Pointer#(0)
let btn# = Pointer#(0)
let effect# = Pointer#(0)
```

## Error Codes (Common to All)

| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Effect is nil |
| 2 | Invalid effect object |
| 3 | Invalid value |
| 4 | Parent is nil |
| 5 | Invalid parent object |
| 6 | Invalid color (where applicable) |

## Files Included

### Pascal Libraries
- BlurEffectLib.pas
- ShadowEffectLib.pas
- GlowEffectLib.pas
- ReflectionEffectLib.pas
- ColorKeyAlphaEffectLib.pas
- MonochromeEffectLib.pas
- InnerGlowEffectLib.pas
- BevelEffectLib.pas

### Documentation
- BlurEffectLib_Documentation.md
- ShadowEffectLib_Documentation.md
- GlowEffectLib_Documentation.md
- ReflectionEffectLib_Documentation.md
- ColorKeyAlphaEffectLib_Documentation.md
- MonochromeEffectLib_Documentation.md
- InnerGlowEffectLib_Documentation.md
- BevelEffectLib_Documentation.md

### Test/Demo Applets
- BlurEffectLib_Test.bas
- ShadowEffectLib_Test.bas (in Effects_Showcase_Demo.bas)
- GlowEffectLib_Test.bas (in Effects_Showcase_Demo.bas)
- ReflectionEffectLib_Test.bas
- ColorKeyAlphaEffectLib_Test.bas
- MonochromeEffectLib_Test.bas
- InnerGlowEffectLib_Test.bas
- BevelEffectLib_Test.bas

## Registration in Main Application

Add to your main unit's uses clause:
```pascal
uses
  BlurEffectLib, ShadowEffectLib, GlowEffectLib, ReflectionEffectLib,
  ColorKeyAlphaEffectLib, MonochromeEffectLib, InnerGlowEffectLib, BevelEffectLib;
```

Register during initialization:
```pascal
RegisterBlurEffectFuncs(Lib);
RegisterShadowEffectFuncs(Lib, Engine, Output);
RegisterGlowEffectFuncs(Lib);
RegisterReflectionEffectFuncs(Lib);
RegisterColorKeyAlphaEffectFuncs(Lib);
RegisterMonochromeEffectFuncs(Lib);
RegisterInnerGlowEffectFuncs(Lib);
RegisterBevelEffectFuncs(Lib);
```
