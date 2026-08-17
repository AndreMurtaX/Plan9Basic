# Plan9Basic Tier-5 Transition Effects Quick Reference

## Overview

Tier-5 effects provide visual transitions between states. Most use a **Progress** property (0.0 to 1.0) that you animate to perform the transition.

## Effect Summary

| Effect | Key Properties | Description |
|--------|---------------|-------------|
| BlindTrans | progress, numblinds | Venetian blind strips |
| CircleTrans | progress, fuzzy, circlesize | Circular wipe |
| DissolveTrans | progress, seed | Random dissolve |
| SlideTrans | progress, amountX/Y | Slide in direction |
| SwipeTrans | mouseX/Y, deep | Page fold/swipe |
| FadeTrans | progress | Simple fade |

## Quick Usage

### BlindTransitionEffect
```basic
let fx# = blindtrans#(ctrl#)
blindtrans_numblinds#(fx#, 10)   ' Number of blind strips
blindtrans_progress#(fx#, 0.5)   ' 0=start, 1=complete
```

### CircleTransitionEffect
```basic
let fx# = circletrans#(ctrl#)
circletrans_circlesize#(fx#, 1.0)  ' Circle size (0-2)
circletrans_fuzzy#(fx#, 0.1)       ' Edge softness (0-1)
circletrans_progress#(fx#, 0.5)
```

### DissolveTransitionEffect
```basic
let fx# = dissolvetrans#(ctrl#)
dissolvetrans_seed#(fx#, 0.5)    ' Random pattern seed
dissolvetrans_progress#(fx#, 0.5)
```

### SlideTransitionEffect
```basic
let fx# = slidetrans#(ctrl#)
slidetrans_amountx#(fx#, 100)    ' Horizontal slide distance
slidetrans_amounty#(fx#, 0)      ' Vertical slide distance
slidetrans_progress#(fx#, 0.5)
```

### SwipeTransitionEffect
```basic
let fx# = swipetrans#(ctrl#)
swipetrans_mousex#(fx#, 50)      ' Fold point X coordinate
swipetrans_mousey#(fx#, 50)      ' Fold point Y coordinate
swipetrans_deep#(fx#, 20)        ' Amount of folding (0-100)
```

### FadeTransitionEffect
```basic
let fx# = fadetrans#(ctrl#)
fadetrans_progress#(fx#, 0.5)    ' 0=fully visible, 1=faded
```

## Animation Examples

### Animated Blind Transition
```basic
let ani# = floatani#(fx#)
floatani_propertyname#(ani#, "Progress")
floatani_startvalue#(ani#, 0)
floatani_stopvalue#(ani#, 1)
floatani_duration#(ani#, 1.5)
floatani_start(ani#)
```

### Circle Reveal Animation
```basic
let ani# = floatani#(circleFx#)
floatani_propertyname#(ani#, "Progress")
floatani_startvalue#(ani#, 0)
floatani_stopvalue#(ani#, 1)
floatani_duration#(ani#, 2.0)
floatani_start(ani#)
```

### Swipe Page Fold Animation
```basic
' Animate MousePoint.X for page fold effect
let ani# = floatani#(swipeFx#)
floatani_propertyname#(ani#, "MousePoint.X")
floatani_startvalue#(ani#, 5)
floatani_stopvalue#(ani#, 150)
floatani_duration#(ani#, 2.0)
floatani_start(ani#)
```

### Looping Dissolve
```basic
let ani# = floatani#(dissolveFx#)
floatani_propertyname#(ani#, "Progress")
floatani_startvalue#(ani#, 0)
floatani_stopvalue#(ani#, 1)
floatani_duration#(ani#, 3.0)
floatani_autoreverse#(ani#, 1)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

## Common Functions (All Transitions)

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

## Visual Guide

| Effect | Animation Result |
|--------|-----------------|
| BlindTrans | Venetian blind strips reveal |
| CircleTrans | Circle grows/shrinks to reveal |
| DissolveTrans | Random pixel dissolve |
| SlideTrans | Content slides in direction |
| SwipeTrans | Page fold/turn effect |
| FadeTrans | Opacity fade |

## Important Notes

1. **Progress Property**: Most transitions use Progress (0.0 to 1.0)
   - 0 = Initial state (no transition)
   - 1 = Complete transition

2. **SwipeTransition**: Uses MousePoint instead of Progress
   - Animate MousePoint.X and MousePoint.Y for the swipe effect
   - Creates a page-fold visual like turning a book page

3. **Target Bitmap**: Transition effects can have a Target bitmap
   - Without Target: Transitions to transparent
   - With Target: Transitions between two images

4. **GPU Accelerated**: All effects are hardware accelerated

### Test Demo
- Tier5_TransitionEffects_Test.bas
