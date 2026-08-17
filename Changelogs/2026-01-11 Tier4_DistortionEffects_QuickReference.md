# Plan9Basic Tier-4 Distortion Effects Quick Reference

## Overview

Tier-4 effects provide spatial distortions. All effects are GPU-accelerated and animatable.

## Effect Summary

| Effect | Key Properties | Description |
|--------|---------------|-------------|
| Wave | wavesize, time | Wave distortion |
| Swirl | strength, centerX/Y | Vortex/spiral |
| Ripple | amplitude, frequency, phase | Water ripple |
| Magnify | magnification, radius | Magnifying glass |
| Bands | density, intensity | Horizontal bands |
| Wrap | leftStart, leftCtrl1/2, leftEnd | Bezier warp |

## Quick Usage

### WaveEffect
```basic
let fx# = wave#(ctrl#)
wave_wavesize#(fx#, 64)    ' Wave size (32-256, higher = smaller waves)
wave_time#(fx#, 0)         ' Animate this for motion!
```

### SwirlEffect
```basic
let fx# = swirl#(ctrl#)
swirl_strength#(fx#, 2.0)  ' -10 to 10 (neg=counter-clockwise)
swirl_centerx#(fx#, 0.5)   ' 0-1 horizontal center
swirl_centery#(fx#, 0.5)   ' 0-1 vertical center
```

### RippleEffect
```basic
let fx# = ripple#(ctrl#)
ripple_amplitude#(fx#, 0.1)    ' Height (0-1)
ripple_frequency#(fx#, 70)     ' Ripple count (0-100)
ripple_phase#(fx#, 0)          ' Animate for water effect
ripple_aspectratio#(fx#, 1.5)  ' Shape (0.5-2.0)
ripple_centerx#(fx#, 0.5)
ripple_centery#(fx#, 0.5)
```

### MagnifyEffect
```basic
let fx# = magnify#(ctrl#)
magnify_magnification#(fx#, 2.0)  ' Zoom level (1-5)
magnify_radius#(fx#, 100)         ' Lens size (0-200)
magnify_centerx#(fx#, 0.5)
magnify_centery#(fx#, 0.5)
```

### BandsEffect
```basic
let fx# = bands#(ctrl#)
bands_density#(fx#, 50)     ' Number of bands (0-100)
bands_intensity#(fx#, 0.5)  ' Effect strength (0-1)
```

### WrapEffect
```basic
let fx# = wrap#(ctrl#)
' Left edge bezier curve
wrap_leftstart#(fx#, 0.2)
wrap_leftctrl1#(fx#, 0.3)
wrap_leftctrl2#(fx#, 0.3)
wrap_leftend#(fx#, 0.2)
```

## Animation Examples

### Animated Wave
```basic
let ani# = floatani#(fx#)
floatani_propertyname#(ani#, "Time")
floatani_startvalue#(ani#, 0)
floatani_stopvalue#(ani#, 10)
floatani_duration#(ani#, 2.0)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

### Water Ripple Animation
```basic
let ani# = floatani#(rippleFx#)
floatani_propertyname#(ani#, "Phase")
floatani_startvalue#(ani#, 0)
floatani_stopvalue#(ani#, 100)
floatani_duration#(ani#, 3.0)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

### Swirl Vortex Animation
```basic
let ani# = floatani#(swirlFx#)
floatani_propertyname#(ani#, "Strength")
floatani_startvalue#(ani#, -5)
floatani_stopvalue#(ani#, 5)
floatani_duration#(ani#, 4.0)
floatani_autoreverse#(ani#, 1)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

### Moving Magnifier
```basic
' Animate CenterX to move lens horizontally
let ani# = floatani#(magnifyFx#)
floatani_propertyname#(ani#, "Center.X")
floatani_startvalue#(ani#, 0.2)
floatani_stopvalue#(ani#, 0.8)
floatani_duration#(ani#, 3.0)
floatani_autoreverse#(ani#, 1)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

## Common Functions (All Effects)

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

## Effect Visual Guide

| Effect | Visual Result |
|--------|---------------|
| Wave | Wavy/undulating distortion |
| Swirl | Spiral vortex from center |
| Ripple | Concentric water ripples |
| Magnify | Magnifying glass lens |
| Bands | Horizontal stripe distortion |
| Wrap | Bezier curve warping |

## Files Included

### Pascal Libraries
- WaveEffectLib.pas (14 functions)
- SwirlEffectLib.pas (16 functions)
- RippleEffectLib.pas (18 functions)
- MagnifyEffectLib.pas (16 functions)
- BandsEffectLib.pas (14 functions)
- WrapEffectLib.pas (16 functions)

### Test Demo
- Tier4_DistortionEffects_Test.bas

## Registration

```pascal
uses
  WaveEffectLib, SwirlEffectLib, RippleEffectLib,
  MagnifyEffectLib, BandsEffectLib, WrapEffectLib;

// In initialization
RegisterWaveEffectFuncs(Lib);
RegisterSwirlEffectFuncs(Lib);
RegisterRippleEffectFuncs(Lib);
RegisterMagnifyEffectFuncs(Lib);
RegisterBandsEffectFuncs(Lib);
RegisterWrapEffectFuncs(Lib);
```
