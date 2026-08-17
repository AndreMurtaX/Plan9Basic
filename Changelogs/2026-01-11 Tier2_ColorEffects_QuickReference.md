# Plan9Basic Tier-2 Color Effects Quick Reference

## Overview

Tier-2 effects focus on color adjustments and image processing. All effects are GPU-accelerated.

## Effect Summary

| Effect | Property | Range | Description |
|--------|----------|-------|-------------|
| Contrast | contrast | 0.0-2.0 | Adjusts light/dark difference |
| Contrast | brightness | -1.0-1.0 | Adjusts overall brightness |
| HueAdjust | hue | -1.0-1.0 | Rotates color wheel |
| Sepia | amount | 0.0-1.0 | Vintage brown tint |
| Invert | (enabled) | on/off | Inverts all colors |

## Quick Usage

### ContrastEffect
```basic
let fx# = contrast#(ctrl#)
contrast_contrast#(fx#, 1.5)      ' 0=gray, 1=normal, 2=max
contrast_brightness#(fx#, 0.2)    ' -1=dark, 0=normal, 1=bright
```

### HueAdjustEffect
```basic
let fx# = hueadjust#(ctrl#)
hueadjust_hue#(fx#, 0.5)          ' -1 to 1 (rotates color wheel)
```

### SepiaEffect
```basic
let fx# = sepia#(ctrl#)
sepia_amount#(fx#, 0.8)           ' 0=off, 1=full vintage
```

### InvertEffect
```basic
let fx# = invert#(ctrl#)
invert_enabled#(fx#, 1)           ' 0=normal, 1=inverted
```

## Common Functions (All Effects)

Each effect provides these standard functions:

```basic
' Error handling
{effect}_error()           ' Get error code
{effect}_errormsg$()       ' Get error message
{effect}_strerror$(n)      ' Code to text
{effect}_clearerror()      ' Clear errors

' Lifecycle
{effect}#(parent#)         ' Create effect
{effect}_free(fx#)         ' Destroy effect

' Common properties
{effect}_enabled#(fx#, n)  ' Enable/disable
{effect}_enabled(fx#)      ' Get enabled state
{effect}_trigger#(fx#, s$) ' Set trigger
{effect}_trigger$(fx#)     ' Get trigger
```

## Pointer Initialization

Always initialize pointers:
```basic
let fx# = Pointer#(0)
let ctrl# = Pointer#(0)
```

## Animation Examples

### Contrast Animation
```basic
let ani# = floatani#(fx#)
floatani_propertyname#(ani#, "Contrast")
floatani_startvalue#(ani#, 0.5)
floatani_stopvalue#(ani#, 2.0)
floatani_duration#(ani#, 2.0)
floatani_autoreverse#(ani#, 1)
floatani_start(ani#)
```

### Rainbow Effect (Hue)
```basic
let ani# = floatani#(fx#)
floatani_propertyname#(ani#, "Hue")
floatani_startvalue#(ani#, -1.0)
floatani_stopvalue#(ani#, 1.0)
floatani_duration#(ani#, 5.0)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

### Fade to Vintage (Sepia)
```basic
let ani# = floatani#(fx#)
floatani_propertyname#(ani#, "Amount")
floatani_startvalue#(ani#, 0.0)
floatani_stopvalue#(ani#, 1.0)
floatani_duration#(ani#, 3.0)
floatani_start(ani#)
```

## Combining Effects

Effects can be stacked on the same control:

```basic
' Vintage photo look
let ctrl# = rectangle#(frm#)
rectangle_fill#(ctrl#, "Orange")

let sep# = sepia#(ctrl#)
sepia_amount#(sep#, 0.7)

let con# = contrast#(ctrl#)
contrast_contrast#(con#, 1.2)
contrast_brightness#(con#, -0.1)
```

## Files Included

### Pascal Libraries
- ContrastEffectLib.pas (16 functions)
- HueAdjustEffectLib.pas (12 functions)
- SepiaEffectLib.pas (12 functions)
- InvertEffectLib.pas (10 functions)

### Documentation
- ContrastEffectLib_Documentation.md
- HueAdjustEffectLib_Documentation.md
- SepiaEffectLib_Documentation.md
- InvertEffectLib_Documentation.md

### Test Demo
- Tier2_ColorEffects_Test.bas

## Registration

```pascal
uses
  ContrastEffectLib, HueAdjustEffectLib, SepiaEffectLib, InvertEffectLib;

// In initialization
RegisterContrastEffectFuncs(Lib);
RegisterHueAdjustEffectFuncs(Lib);
RegisterSepiaEffectFuncs(Lib);
RegisterInvertEffectFuncs(Lib);
```

## Note on Grayscale/Desaturation

For grayscale effects, use **MonochromeEffectLib** from Tier-1.
