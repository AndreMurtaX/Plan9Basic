# Plan9Basic Transition Effects Library Reference

## Overview

Plan9Basic provides 23 transition effects for creating smooth visual transitions between two images. All transition effects share a common pattern: they transform a source image (the control they're attached to) into a target image based on a progress value from 0.0 to 1.0.

**Common Concepts:**
- **Progress**: A value from 0.0 (source image fully visible) to 1.0 (target image fully visible)
- **Target**: The destination image that will be revealed during the transition
- **Parent**: The visual control (typically an image#) to which the effect is applied

---

## Table of Contents

1. [BlindTransitionEffect](#1-blindtransitioneffect)
2. [CircleTransitionEffect](#2-circletransitioneffect)
3. [DissolveTransitionEffect](#3-dissolvetransitioneffect)
4. [FadeTransitionEffect](#4-fadetransitioneffect)
5. [SlideTransitionEffect](#5-slidetransitioneffect)
6. [SwipeTransitionEffect](#6-swipetransitioneffect)
7. [BandedSwirlTransitionEffect](#7-bandedswirltr)
8. [BloodTransitionEffect](#8-bloodtrans)
9. [BlurTransitionEffect](#9-blurtrans)
10. [BrightTransitionEffect](#10-brighttrans)
11. [CrumpleTransitionEffect](#11-crumpletrans)
12. [DropTransitionEffect](#12-droptrans)
13. [LineTransitionEffect](#13-linetrans)
14. [MagnifyTransitionEffect](#14-magnifytrans)
15. [PixelateTransitionEffect](#15-pixelatetrans)
16. [RippleTransitionEffect](#16-rippletrans)
17. [RotateCrumpleTransitionEffect](#17-rotcrumpletrans)
18. [SaturateTransitionEffect](#18-saturatrans)
19. [ShapeTransitionEffect](#19-shapetrans)
20. [SwirlTransitionEffect](#20-swirltrans)
21. [WaterTransitionEffect](#21-watertrans)
22. [WaveTransitionEffect](#22-wavetrans)
23. [WiggleTransitionEffect](#23-wiggletrans)

---

## 1. BlindTransitionEffect

Creates a venetian blind effect that reveals the target image through horizontal or vertical slats.

### Functions

| Function | Description |
|----------|-------------|
| `blindtrans#(parent#)` | Creates a blind transition effect on the specified parent control |
| `blindtrans_free(effect#)` | Destroys the effect and releases resources |
| `blindtrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `blindtrans_progress(effect#)` | Gets current progress value |
| `blindtrans_target#(effect#, bitmap#)` | Sets target bitmap from another bitmap object |
| `blindtrans_target#(effect#)` | Gets target bitmap pointer |
| `blindtrans_loadtarget#(effect#, path$)` | Loads target from file path or URL |
| `blindtrans_numbands#(effect#, value)` | Sets number of blind slats (default 50) |
| `blindtrans_numbands(effect#)` | Gets number of blind slats |
| `blindtrans_enabled#(effect#, value)` | Enables (1) or disables (0) the effect |
| `blindtrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let img# = image#(form#, 10, 10, 400, 300)
image_load#(img#, "photo1.jpg")

let fx# = blindtrans#(img#)
blindtrans_loadtarget#(fx#, "photo2.jpg")
blindtrans_numbands#(fx#, 20)
blindtrans_progress#(fx#, 0.5)  ' 50% transition
```

---

## 2. CircleTransitionEffect

Creates a circular wipe that expands from a center point to reveal the target image.

### Functions

| Function | Description |
|----------|-------------|
| `circletrans#(parent#)` | Creates a circle transition effect |
| `circletrans_free(effect#)` | Destroys the effect |
| `circletrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `circletrans_progress(effect#)` | Gets current progress |
| `circletrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `circletrans_target#(effect#)` | Gets target bitmap |
| `circletrans_loadtarget#(effect#, path$)` | Loads target from file/URL |
| `circletrans_centerx#(effect#, value)` | Sets center X (0.0-1.0, normalized) |
| `circletrans_centerx(effect#)` | Gets center X |
| `circletrans_centery#(effect#, value)` | Sets center Y (0.0-1.0, normalized) |
| `circletrans_centery(effect#)` | Gets center Y |
| `circletrans_fuzzyamount#(effect#, value)` | Sets edge softness (0.0-1.0) |
| `circletrans_fuzzyamount(effect#)` | Gets edge softness |
| `circletrans_size#(effect#, value)` | Sets circle size |
| `circletrans_size(effect#)` | Gets circle size |
| `circletrans_enabled#(effect#, value)` | Enables/disables effect |
| `circletrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = circletrans#(img#)
circletrans_loadtarget#(fx#, "photo2.jpg")
circletrans_centerx#(fx#, 0.5)
circletrans_centery#(fx#, 0.5)
circletrans_fuzzyamount#(fx#, 0.1)
circletrans_progress#(fx#, 0.7)
```

---

## 3. DissolveTransitionEffect

Creates a random pixel dissolve effect between source and target images.

### Functions

| Function | Description |
|----------|-------------|
| `dissolvetrans#(parent#)` | Creates a dissolve transition effect |
| `dissolvetrans_free(effect#)` | Destroys the effect |
| `dissolvetrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `dissolvetrans_progress(effect#)` | Gets current progress |
| `dissolvetrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `dissolvetrans_target#(effect#)` | Gets target bitmap |
| `dissolvetrans_loadtarget#(effect#, path$)` | Loads target from file/URL |
| `dissolvetrans_randomseed#(effect#, value)` | Sets random seed for pattern |
| `dissolvetrans_randomseed(effect#)` | Gets random seed |
| `dissolvetrans_enabled#(effect#, value)` | Enables/disables effect |
| `dissolvetrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = dissolvetrans#(img#)
dissolvetrans_loadtarget#(fx#, "photo2.jpg")
dissolvetrans_randomseed#(fx#, 0.5)
dissolvetrans_progress#(fx#, 0.5)
```

---

## 4. FadeTransitionEffect

Creates a simple crossfade between source and target images.

### Functions

| Function | Description |
|----------|-------------|
| `fadetrans#(parent#)` | Creates a fade transition effect |
| `fadetrans_free(effect#)` | Destroys the effect |
| `fadetrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `fadetrans_progress(effect#)` | Gets current progress |
| `fadetrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `fadetrans_target#(effect#)` | Gets target bitmap |
| `fadetrans_loadtarget#(effect#, path$)` | Loads target from file/URL |
| `fadetrans_enabled#(effect#, value)` | Enables/disables effect |
| `fadetrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = fadetrans#(img#)
fadetrans_loadtarget#(fx#, "photo2.jpg")
fadetrans_progress#(fx#, 0.5)  ' 50% blend
```

---

## 5. SlideTransitionEffect

Creates a sliding wipe effect where the target image slides in from a specified direction.

### Functions

| Function | Description |
|----------|-------------|
| `slidetrans#(parent#)` | Creates a slide transition effect |
| `slidetrans_free(effect#)` | Destroys the effect |
| `slidetrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `slidetrans_progress(effect#)` | Gets current progress |
| `slidetrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `slidetrans_target#(effect#)` | Gets target bitmap |
| `slidetrans_loadtarget#(effect#, path$)` | Loads target from file/URL |
| `slidetrans_slideamountx#(effect#, value)` | Sets horizontal slide direction (-1.0 to 1.0) |
| `slidetrans_slideamountx(effect#)` | Gets horizontal slide amount |
| `slidetrans_slideamounty#(effect#, value)` | Sets vertical slide direction (-1.0 to 1.0) |
| `slidetrans_slideamounty(effect#)` | Gets vertical slide amount |
| `slidetrans_enabled#(effect#, value)` | Enables/disables effect |
| `slidetrans_enabled(effect#)` | Gets enabled state |

### Slide Direction Values

| SlideAmountX | SlideAmountY | Effect |
|--------------|--------------|--------|
| 1.0 | 0.0 | Slide from left to right |
| -1.0 | 0.0 | Slide from right to left |
| 0.0 | 1.0 | Slide from top to bottom |
| 0.0 | -1.0 | Slide from bottom to top |
| 0.7 | 0.7 | Diagonal slide |

### Example

```basic
let fx# = slidetrans#(img#)
slidetrans_loadtarget#(fx#, "photo2.jpg")

' Slide from left to right
slidetrans_slideamountx#(fx#, 1.0)
slidetrans_slideamounty#(fx#, 0.0)

' Animate
for p = 0 to 100
  slidetrans_progress#(fx#, p / 100)
  pause(0.02)
next
```

---

## 6. SwipeTransitionEffect

Creates a page-turn/swipe effect like turning a book page. The source image "folds" away to reveal the target image underneath.

### Functions

| Function | Description |
|----------|-------------|
| `swipetrans#(parent#)` | Creates a swipe transition effect |
| `swipetrans_free(effect#)` | Destroys the effect |
| `swipetrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `swipetrans_progress(effect#)` | Gets current progress |
| `swipetrans_target#(effect#, bitmap#)` | Sets target bitmap (image revealed UNDER the fold) |
| `swipetrans_target#(effect#)` | Gets target bitmap |
| `swipetrans_loadtarget#(effect#, path$)` | Loads target from file/URL |
| `swipetrans_back#(effect#, bitmap#)` | Sets back of page bitmap (optional) |
| `swipetrans_back#(effect#)` | Gets back bitmap |
| `swipetrans_loadback#(effect#, path$)` | Loads back image from file/URL |
| `swipetrans_mousex#(effect#, value)` | Sets X position in PIXELS where page is pulled |
| `swipetrans_mousex(effect#)` | Gets X position |
| `swipetrans_mousey#(effect#, value)` | Sets Y position in PIXELS where page is pulled |
| `swipetrans_mousey(effect#)` | Gets Y position |
| `swipetrans_deep#(effect#, value)` | Sets fold depth (0-100) |
| `swipetrans_deep(effect#)` | Gets fold depth |
| `swipetrans_cornerpointx#(effect#, value)` | Sets which corner folds (X: 0=left, 1=right) |
| `swipetrans_cornerpointx(effect#)` | Gets corner X |
| `swipetrans_cornerpointy#(effect#, value)` | Sets which corner folds (Y: 0=top, 1=bottom) |
| `swipetrans_cornerpointy(effect#)` | Gets corner Y |
| `swipetrans_enabled#(effect#, value)` | Enables/disables effect |
| `swipetrans_enabled(effect#)` | Gets enabled state |

### Understanding MousePoint Coordinates

**IMPORTANT**: MouseX and MouseY use PIXEL coordinates, not normalized 0-1 values!

- MousePoint specifies where the page corner is "pulled" to
- The fold occurs between CornerPoint and MousePoint
- Default MousePoint is approximately (210, 60) pixels

### Example: Interactive Page Turn

```basic
let img# = image#(form#, 10, 10, 400, 300)
image_load#(img#, "page1.jpg")

let fx# = swipetrans#(img#)
swipetrans_loadtarget#(fx#, "page2.jpg")
swipetrans_deep#(fx#, 50)

' Set corner to fold from (top-left)
swipetrans_cornerpointx#(fx#, 0)
swipetrans_cornerpointy#(fx#, 0)

' Set where page is pulled to (in pixels)
swipetrans_mousex#(fx#, 200)
swipetrans_mousey#(fx#, 150)

' Mouse tracking callback
image_onmousemove#(img#, "OnMouseMove")

function OnMouseMove(sender#, x, y, shift$)
  swipetrans_mousex#(fx#, x)
  swipetrans_mousey#(fx#, y)
endfunction
```

### Preset Page Turn Positions

```basic
' For a 400x300 image:
' Small corner fold
swipetrans_mousex#(fx#, 50)
swipetrans_mousey#(fx#, 50)

' Half page turn
swipetrans_mousex#(fx#, 200)
swipetrans_mousey#(fx#, 150)

' Full page turn
swipetrans_mousex#(fx#, 400)
swipetrans_mousey#(fx#, 300)
```

---

## 7. BandedSwirlTransitionEffect (bandedswirltr)

Creates a swirling band pattern that transitions between images.

### Functions

| Function | Description |
|----------|-------------|
| `bandedswirltr#(parent#)` | Creates effect |
| `bandedswirltr_free(effect#)` | Destroys effect |
| `bandedswirltr_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `bandedswirltr_progress(effect#)` | Gets progress |
| `bandedswirltr_loadtarget#(effect#, path$)` | Loads target image |
| `bandedswirltr_target#(effect#, bitmap#)` | Sets target bitmap |
| `bandedswirltr_target#(effect#)` | Gets target bitmap |
| `bandedswirltr_strength#(effect#, value)` | Sets swirl strength (default 0.5) |
| `bandedswirltr_strength(effect#)` | Gets swirl strength |
| `bandedswirltr_frequency#(effect#, value)` | Sets number of bands (default 20) |
| `bandedswirltr_frequency(effect#)` | Gets band count |
| `bandedswirltr_centerx#(effect#, value)` | Sets swirl center X |
| `bandedswirltr_centerx(effect#)` | Gets center X |
| `bandedswirltr_centery#(effect#, value)` | Sets swirl center Y |
| `bandedswirltr_centery(effect#)` | Gets center Y |
| `bandedswirltr_enabled#(effect#, value)` | Enables/disables |
| `bandedswirltr_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = bandedswirltr#(img#)
bandedswirltr_loadtarget#(fx#, "photo2.jpg")
bandedswirltr_strength#(fx#, 1.0)
bandedswirltr_frequency#(fx#, 30)
bandedswirltr_progress#(fx#, 0.5)
```

---

## 8. BloodTransitionEffect (bloodtrans)

Creates a dripping blood-like reveal effect.

### Functions

| Function | Description |
|----------|-------------|
| `bloodtrans#(parent#)` | Creates effect |
| `bloodtrans_free(effect#)` | Destroys effect |
| `bloodtrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `bloodtrans_progress(effect#)` | Gets progress |
| `bloodtrans_loadtarget#(effect#, path$)` | Loads target image |
| `bloodtrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `bloodtrans_target#(effect#)` | Gets target bitmap |
| `bloodtrans_randomseed#(effect#, value)` | Sets drip pattern seed |
| `bloodtrans_randomseed(effect#)` | Gets random seed |
| `bloodtrans_enabled#(effect#, value)` | Enables/disables |
| `bloodtrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = bloodtrans#(img#)
bloodtrans_loadtarget#(fx#, "photo2.jpg")
bloodtrans_randomseed#(fx#, 0.7)
bloodtrans_progress#(fx#, 0.5)
```

---

## 9. BlurTransitionEffect (blurtrans)

Creates a blur-based transition where the source blurs out as target blurs in.

### Functions

| Function | Description |
|----------|-------------|
| `blurtrans#(parent#)` | Creates effect |
| `blurtrans_free(effect#)` | Destroys effect |
| `blurtrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `blurtrans_progress(effect#)` | Gets progress |
| `blurtrans_loadtarget#(effect#, path$)` | Loads target image |
| `blurtrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `blurtrans_target#(effect#)` | Gets target bitmap |
| `blurtrans_enabled#(effect#, value)` | Enables/disables |
| `blurtrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = blurtrans#(img#)
blurtrans_loadtarget#(fx#, "photo2.jpg")
blurtrans_progress#(fx#, 0.5)
```

---

## 10. BrightTransitionEffect (brighttrans)

Creates a brightness-based transition (flash to white and back).

### Functions

| Function | Description |
|----------|-------------|
| `brighttrans#(parent#)` | Creates effect |
| `brighttrans_free(effect#)` | Destroys effect |
| `brighttrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `brighttrans_progress(effect#)` | Gets progress |
| `brighttrans_loadtarget#(effect#, path$)` | Loads target image |
| `brighttrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `brighttrans_target#(effect#)` | Gets target bitmap |
| `brighttrans_enabled#(effect#, value)` | Enables/disables |
| `brighttrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = brighttrans#(img#)
brighttrans_loadtarget#(fx#, "photo2.jpg")
brighttrans_progress#(fx#, 0.5)
```

---

## 11. CrumpleTransitionEffect (crumpletrans)

Creates a paper crumple effect.

### Functions

| Function | Description |
|----------|-------------|
| `crumpletrans#(parent#)` | Creates effect |
| `crumpletrans_free(effect#)` | Destroys effect |
| `crumpletrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `crumpletrans_progress(effect#)` | Gets progress |
| `crumpletrans_loadtarget#(effect#, path$)` | Loads target image |
| `crumpletrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `crumpletrans_target#(effect#)` | Gets target bitmap |
| `crumpletrans_randomseed#(effect#, value)` | Sets crumple pattern |
| `crumpletrans_randomseed(effect#)` | Gets random seed |
| `crumpletrans_enabled#(effect#, value)` | Enables/disables |
| `crumpletrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = crumpletrans#(img#)
crumpletrans_loadtarget#(fx#, "photo2.jpg")
crumpletrans_randomseed#(fx#, 0.5)
crumpletrans_progress#(fx#, 0.5)
```

---

## 12. DropTransitionEffect (droptrans)

Creates a dropping columns effect.

### Functions

| Function | Description |
|----------|-------------|
| `droptrans#(parent#)` | Creates effect |
| `droptrans_free(effect#)` | Destroys effect |
| `droptrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `droptrans_progress(effect#)` | Gets progress |
| `droptrans_loadtarget#(effect#, path$)` | Loads target image |
| `droptrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `droptrans_target#(effect#)` | Gets target bitmap |
| `droptrans_randomseed#(effect#, value)` | Sets drop pattern |
| `droptrans_randomseed(effect#)` | Gets random seed |
| `droptrans_enabled#(effect#, value)` | Enables/disables |
| `droptrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = droptrans#(img#)
droptrans_loadtarget#(fx#, "photo2.jpg")
droptrans_randomseed#(fx#, 0.5)
droptrans_progress#(fx#, 0.5)
```

---

## 13. LineTransitionEffect (linetrans)

Creates a line wipe transition with customizable orientation.

### Functions

| Function | Description |
|----------|-------------|
| `linetrans#(parent#)` | Creates effect |
| `linetrans_free(effect#)` | Destroys effect |
| `linetrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `linetrans_progress(effect#)` | Gets progress |
| `linetrans_loadtarget#(effect#, path$)` | Loads target image |
| `linetrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `linetrans_target#(effect#)` | Gets target bitmap |
| `linetrans_fuzzyamount#(effect#, value)` | Sets edge softness |
| `linetrans_fuzzyamount(effect#)` | Gets edge softness |
| `linetrans_originx#(effect#, value)` | Sets line origin X |
| `linetrans_originx(effect#)` | Gets origin X |
| `linetrans_originy#(effect#, value)` | Sets line origin Y |
| `linetrans_originy(effect#)` | Gets origin Y |
| `linetrans_enabled#(effect#, value)` | Enables/disables |
| `linetrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = linetrans#(img#)
linetrans_loadtarget#(fx#, "photo2.jpg")
linetrans_fuzzyamount#(fx#, 0.1)
linetrans_progress#(fx#, 0.5)
```

---

## 14. MagnifyTransitionEffect (magnifytrans)

Creates a magnifying zoom reveal effect.

### Functions

| Function | Description |
|----------|-------------|
| `magnifytrans#(parent#)` | Creates effect |
| `magnifytrans_free(effect#)` | Destroys effect |
| `magnifytrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `magnifytrans_progress(effect#)` | Gets progress |
| `magnifytrans_loadtarget#(effect#, path$)` | Loads target image |
| `magnifytrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `magnifytrans_target#(effect#)` | Gets target bitmap |
| `magnifytrans_centerx#(effect#, value)` | Sets zoom center X |
| `magnifytrans_centerx(effect#)` | Gets center X |
| `magnifytrans_centery#(effect#, value)` | Sets zoom center Y |
| `magnifytrans_centery(effect#)` | Gets center Y |
| `magnifytrans_enabled#(effect#, value)` | Enables/disables |
| `magnifytrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = magnifytrans#(img#)
magnifytrans_loadtarget#(fx#, "photo2.jpg")
magnifytrans_centerx#(fx#, 0.5)
magnifytrans_centery#(fx#, 0.5)
magnifytrans_progress#(fx#, 0.5)
```

---

## 15. PixelateTransitionEffect (pixelatetrans)

Creates a pixelation transition effect.

### Functions

| Function | Description |
|----------|-------------|
| `pixelatetrans#(parent#)` | Creates effect |
| `pixelatetrans_free(effect#)` | Destroys effect |
| `pixelatetrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `pixelatetrans_progress(effect#)` | Gets progress |
| `pixelatetrans_loadtarget#(effect#, path$)` | Loads target image |
| `pixelatetrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `pixelatetrans_target#(effect#)` | Gets target bitmap |
| `pixelatetrans_enabled#(effect#, value)` | Enables/disables |
| `pixelatetrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = pixelatetrans#(img#)
pixelatetrans_loadtarget#(fx#, "photo2.jpg")
pixelatetrans_progress#(fx#, 0.5)
```

---

## 16. RippleTransitionEffect (rippletrans)

Creates a water ripple reveal effect.

### Functions

| Function | Description |
|----------|-------------|
| `rippletrans#(parent#)` | Creates effect |
| `rippletrans_free(effect#)` | Destroys effect |
| `rippletrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `rippletrans_progress(effect#)` | Gets progress |
| `rippletrans_loadtarget#(effect#, path$)` | Loads target image |
| `rippletrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `rippletrans_target#(effect#)` | Gets target bitmap |
| `rippletrans_enabled#(effect#, value)` | Enables/disables |
| `rippletrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = rippletrans#(img#)
rippletrans_loadtarget#(fx#, "photo2.jpg")
rippletrans_progress#(fx#, 0.5)
```

---

## 17. RotateCrumpleTransitionEffect (rotcrumpletrans)

Creates a rotating crumple effect.

### Functions

| Function | Description |
|----------|-------------|
| `rotcrumpletrans#(parent#)` | Creates effect |
| `rotcrumpletrans_free(effect#)` | Destroys effect |
| `rotcrumpletrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `rotcrumpletrans_progress(effect#)` | Gets progress |
| `rotcrumpletrans_loadtarget#(effect#, path$)` | Loads target image |
| `rotcrumpletrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `rotcrumpletrans_target#(effect#)` | Gets target bitmap |
| `rotcrumpletrans_randomseed#(effect#, value)` | Sets pattern seed |
| `rotcrumpletrans_randomseed(effect#)` | Gets random seed |
| `rotcrumpletrans_enabled#(effect#, value)` | Enables/disables |
| `rotcrumpletrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = rotcrumpletrans#(img#)
rotcrumpletrans_loadtarget#(fx#, "photo2.jpg")
rotcrumpletrans_randomseed#(fx#, 0.5)
rotcrumpletrans_progress#(fx#, 0.5)
```

---

## 18. SaturateTransitionEffect (saturatrans)

Creates a saturation-based transition.

### Functions

| Function | Description |
|----------|-------------|
| `saturatrans#(parent#)` | Creates effect |
| `saturatrans_free(effect#)` | Destroys effect |
| `saturatrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `saturatrans_progress(effect#)` | Gets progress |
| `saturatrans_loadtarget#(effect#, path$)` | Loads target image |
| `saturatrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `saturatrans_target#(effect#)` | Gets target bitmap |
| `saturatrans_enabled#(effect#, value)` | Enables/disables |
| `saturatrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = saturatrans#(img#)
saturatrans_loadtarget#(fx#, "photo2.jpg")
saturatrans_progress#(fx#, 0.5)
```

---

## 19. ShapeTransitionEffect (shapetrans)

Creates a shape-masked reveal transition.

### Functions

| Function | Description |
|----------|-------------|
| `shapetrans#(parent#)` | Creates effect |
| `shapetrans_free(effect#)` | Destroys effect |
| `shapetrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `shapetrans_progress(effect#)` | Gets progress |
| `shapetrans_loadtarget#(effect#, path$)` | Loads target image |
| `shapetrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `shapetrans_target#(effect#)` | Gets target bitmap |
| `shapetrans_randomseed#(effect#, value)` | Sets shape pattern |
| `shapetrans_randomseed(effect#)` | Gets random seed |
| `shapetrans_enabled#(effect#, value)` | Enables/disables |
| `shapetrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = shapetrans#(img#)
shapetrans_loadtarget#(fx#, "photo2.jpg")
shapetrans_randomseed#(fx#, 0.5)
shapetrans_progress#(fx#, 0.5)
```

---

## 20. SwirlTransitionEffect (swirltrans)

Creates a swirl vortex transition.

### Functions

| Function | Description |
|----------|-------------|
| `swirltrans#(parent#)` | Creates effect |
| `swirltrans_free(effect#)` | Destroys effect |
| `swirltrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `swirltrans_progress(effect#)` | Gets progress |
| `swirltrans_loadtarget#(effect#, path$)` | Loads target image |
| `swirltrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `swirltrans_target#(effect#)` | Gets target bitmap |
| `swirltrans_strength#(effect#, value)` | Sets swirl intensity |
| `swirltrans_strength(effect#)` | Gets strength |
| `swirltrans_enabled#(effect#, value)` | Enables/disables |
| `swirltrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = swirltrans#(img#)
swirltrans_loadtarget#(fx#, "photo2.jpg")
swirltrans_strength#(fx#, 1.5)
swirltrans_progress#(fx#, 0.5)
```

---

## 21. WaterTransitionEffect (watertrans)

Creates a water distortion transition.

### Functions

| Function | Description |
|----------|-------------|
| `watertrans#(parent#)` | Creates effect |
| `watertrans_free(effect#)` | Destroys effect |
| `watertrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `watertrans_progress(effect#)` | Gets progress |
| `watertrans_loadtarget#(effect#, path$)` | Loads target image |
| `watertrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `watertrans_target#(effect#)` | Gets target bitmap |
| `watertrans_randomseed#(effect#, value)` | Sets water pattern |
| `watertrans_randomseed(effect#)` | Gets random seed |
| `watertrans_enabled#(effect#, value)` | Enables/disables |
| `watertrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = watertrans#(img#)
watertrans_loadtarget#(fx#, "photo2.jpg")
watertrans_randomseed#(fx#, 0.5)
watertrans_progress#(fx#, 0.5)
```

---

## 22. WaveTransitionEffect (wavetrans)

Creates a wave transition effect.

### Functions

| Function | Description |
|----------|-------------|
| `wavetrans#(parent#)` | Creates effect |
| `wavetrans_free(effect#)` | Destroys effect |
| `wavetrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `wavetrans_progress(effect#)` | Gets progress |
| `wavetrans_loadtarget#(effect#, path$)` | Loads target image |
| `wavetrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `wavetrans_target#(effect#)` | Gets target bitmap |
| `wavetrans_enabled#(effect#, value)` | Enables/disables |
| `wavetrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = wavetrans#(img#)
wavetrans_loadtarget#(fx#, "photo2.jpg")
wavetrans_progress#(fx#, 0.5)
```

---

## 23. WiggleTransitionEffect (wiggletrans)

Creates a wiggle/jiggle transition effect.

### Functions

| Function | Description |
|----------|-------------|
| `wiggletrans#(parent#)` | Creates effect |
| `wiggletrans_free(effect#)` | Destroys effect |
| `wiggletrans_progress#(effect#, value)` | Sets progress (0.0-1.0) |
| `wiggletrans_progress(effect#)` | Gets progress |
| `wiggletrans_loadtarget#(effect#, path$)` | Loads target image |
| `wiggletrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `wiggletrans_target#(effect#)` | Gets target bitmap |
| `wiggletrans_randomseed#(effect#, value)` | Sets wiggle pattern |
| `wiggletrans_randomseed(effect#)` | Gets random seed |
| `wiggletrans_enabled#(effect#, value)` | Enables/disables |
| `wiggletrans_enabled(effect#)` | Gets enabled state |

### Example

```basic
let fx# = wiggletrans#(img#)
wiggletrans_loadtarget#(fx#, "photo2.jpg")
wiggletrans_randomseed#(fx#, 0.5)
wiggletrans_progress#(fx#, 0.5)
```

---

## Common Animation Pattern

All transition effects can be animated using a simple loop:

```basic
' Animate any transition effect
for progress = 0 to 100
  xxxxtrans_progress#(fx#, progress / 100)
  pause(0.02)  ' 20ms delay = ~50 FPS
next
```

Or using a timer callback:

```basic
let animProgress = 0

function OnTimer(sender#)
  animProgress = animProgress + 2
  if animProgress <= 100 then
    xxxxtrans_progress#(fx#, animProgress / 100)
  endif
endfunction
```

---

## Error Handling

All transition effect libraries provide error handling functions:

| Function | Description |
|----------|-------------|
| `xxxxtrans_error()` | Returns last error code (0 = no error) |
| `xxxxtrans_errormsg$()` | Returns last error message |
| `xxxxtrans_strerror$(code)` | Returns description for error code |
| `xxxxtrans_clearerror()` | Clears the last error |

### Error Codes

| Code | Meaning |
|------|---------|
| 0 | No error |
| 1 | Effect is nil |
| 2 | Invalid effect type |
| 3 | Invalid value |
| 4 | Parent is nil |
| 5 | Invalid parent type |
| 6 | Failed to load image |
| 7 | Bitmap is nil |

### Example

```basic
let fx# = fadetrans#(img#)
fadetrans_loadtarget#(fx#, "nonexistent.jpg")

if fadetrans_error() <> 0 then
  println "Error: " + fadetrans_errormsg$()
endif
```

---

## Quick Reference Table

| Effect | Prefix | Special Properties |
|--------|--------|-------------------|
| Blind | `blindtrans_` | numbands |
| Circle | `circletrans_` | centerx, centery, fuzzyamount, size |
| Dissolve | `dissolvetrans_` | randomseed |
| Fade | `fadetrans_` | - |
| Slide | `slidetrans_` | slideamountx, slideamounty |
| Swipe | `swipetrans_` | mousex, mousey, deep, cornerpointx, cornerpointy, back |
| BandedSwirl | `bandedswirltr_` | strength, frequency, centerx, centery |
| Blood | `bloodtrans_` | randomseed |
| Blur | `blurtrans_` | - |
| Bright | `brighttrans_` | - |
| Crumple | `crumpletrans_` | randomseed |
| Drop | `droptrans_` | randomseed |
| Line | `linetrans_` | fuzzyamount, originx, originy |
| Magnify | `magnifytrans_` | centerx, centery |
| Pixelate | `pixelatetrans_` | - |
| Ripple | `rippletrans_` | - |
| RotateCrumple | `rotcrumpletrans_` | randomseed |
| Saturate | `saturatrans_` | - |
| Shape | `shapetrans_` | randomseed |
| Swirl | `swirltrans_` | strength |
| Water | `watertrans_` | randomseed |
| Wave | `wavetrans_` | - |
| Wiggle | `wiggletrans_` | randomseed |

---

*Plan9Basic Transition Effects Library Reference - Version 1.0*
