# Plan9Basic Tier-3 Artistic Effects Quick Reference

## Overview

Tier-3 effects provide artistic/stylized transformations. All effects are GPU-accelerated.

## Effect Summary

| Effect | Property | Range | Description |
|--------|----------|-------|-------------|
| Emboss | amount | 0.0-1.0 | Emboss intensity |
| Emboss | width | 0.0-10.0 | Edge width |
| Pixelate | blockcount | 1-100 | Number of pixel blocks |
| Toon | levels | 2-255 | Color quantization levels |
| Sharpen | amount | 0.0-2.0 | Sharpening intensity |
| PaperSketch | brushsize | 0.0-10.0 | Sketch stroke size |
| PencilStroke | brushsize | 0.0-10.0 | Pencil stroke size |

## Quick Usage

### EmbossEffect
```basic
let fx# = emboss#(ctrl#)
emboss_amount#(fx#, 0.5)    ' 0=none, 1=max
emboss_width#(fx#, 2.0)     ' Edge width in pixels
```

### PixelateEffect
```basic
let fx# = pixelate#(ctrl#)
pixelate_blockcount#(fx#, 10)  ' Lower = bigger pixels
```

### ToonEffect
```basic
let fx# = toon#(ctrl#)
toon_levels#(fx#, 4)          ' 2=very cartoon, 255=normal
```

### SharpenEffect
```basic
let fx# = sharpen#(ctrl#)
sharpen_amount#(fx#, 1.5)     ' 0=none, 2=max
```

### PaperSketchEffect
```basic
let fx# = papersketch#(ctrl#)
papersketch_brushsize#(fx#, 2.0)
```

### PencilStrokeEffect
```basic
let fx# = pencilstroke#(ctrl#)
pencilstroke_brushsize#(fx#, 2.0)
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

## Animation Examples

### Pixelate Animation (Reveal Effect)
```basic
let ani# = floatani#(fx#)
floatani_propertyname#(ani#, "BlockCount")
floatani_startvalue#(ani#, 5)
floatani_stopvalue#(ani#, 100)
floatani_duration#(ani#, 2.0)
floatani_start(ani#)
```

### Emboss Pulsing
```basic
let ani# = floatani#(fx#)
floatani_propertyname#(ani#, "Amount")
floatani_startvalue#(ani#, 0.2)
floatani_stopvalue#(ani#, 1.0)
floatani_duration#(ani#, 1.0)
floatani_autoreverse#(ani#, 1)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

## Combining Effects

Create artistic compositions:

```basic
' Sketch + Sepia for vintage drawing
let ctrl# = rectangle#(frm#)
rectangle_fill#(ctrl#, "Blue")

let sketch# = papersketch#(ctrl#)
papersketch_brushsize#(sketch#, 2.0)

let sep# = sepia#(ctrl#)
sepia_amount#(sep#, 0.6)
```

## Effect Visual Guide

| Effect | Visual Result |
|--------|---------------|
| Emboss | 3D raised/carved appearance |
| Pixelate | Mosaic/blocky pixels |
| Toon | Flat cartoon colors |
| Sharpen | Crisp enhanced edges |
| PaperSketch | Pencil drawing on paper |
| PencilStroke | Cross-hatched pencil lines |

## Files Included

### Pascal Libraries
- EmbossEffectLib.pas (14 functions)
- PixelateEffectLib.pas (12 functions)
- ToonEffectLib.pas (12 functions)
- SharpenEffectLib.pas (12 functions)
- PaperSketchEffectLib.pas (12 functions)
- PencilStrokeEffectLib.pas (12 functions)

### Test Demo
- Tier3_ArtisticEffects_Test.bas

## Registration

```pascal
uses
  EmbossEffectLib, PixelateEffectLib, ToonEffectLib,
  SharpenEffectLib, PaperSketchEffectLib, PencilStrokeEffectLib;

// In initialization
RegisterEmbossEffectFuncs(Lib);
RegisterPixelateEffectFuncs(Lib);
RegisterToonEffectFuncs(Lib);
RegisterSharpenEffectFuncs(Lib);
RegisterPaperSketchEffectFuncs(Lib);
RegisterPencilStrokeEffectFuncs(Lib);
```
