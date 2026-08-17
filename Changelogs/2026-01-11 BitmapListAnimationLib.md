# BitmapListAnimationLib - Sprite Sheet Animation Library

## Overview

BitmapListAnimationLib provides sprite sheet animation functionality for Plan9Basic, allowing Image controls to display animated sequences from a single sprite sheet image. This is ideal for game development, animated icons, character animations, and other frame-based animations.

## Features

- Sprite sheet based animation (single image with multiple frames)
- Configurable frame count and row layout
- Multiple interpolation types for timing control
- Loop and auto-reverse capabilities
- Event callbacks for animation completion and progress
- Cross-platform support (Windows, macOS, Linux, Android, iOS)

## Important: Load Sprite Sheet First!

> **⚠️ You MUST load a sprite sheet before calling `bmplistani_start`!**
>
> Attempting to start the animation without a loaded sprite sheet will result in an error.

```basic
' CORRECT order:
let ani# = bmplistani#(sprite#)
bmplistani_loadspritesheet#(ani#, "mysprites.png")  ' Load FIRST!
bmplistani_animationcount#(ani#, 8)
bmplistani_animationrowcount#(ani#, 2)
bmplistani_start(ani#)  ' Start AFTER loading
```

## How Sprite Sheets Work

A sprite sheet is a single bitmap image containing all animation frames arranged in a grid:

```
+---+---+---+---+
| 1 | 2 | 3 | 4 |  <- Row 1 (frames 1-4)
+---+---+---+---+
| 5 | 6 | 7 | 8 |  <- Row 2 (frames 5-8)
+---+---+---+---+

AnimationCount = 8 (total frames)
AnimationRowCount = 2 (number of rows)
Columns calculated automatically: 8 / 2 = 4
```

The animation automatically calculates frame size based on:
- Frame Width = Sprite Sheet Width / Columns
- Frame Height = Sprite Sheet Height / Rows

## Animation Types

| Type | Description |
|------|-------------|
| `"In"` | Acceleration at start |
| `"Out"` | Deceleration at end |
| `"InOut"` | Acceleration then deceleration |

## Interpolation Types

| Type | Description |
|------|-------------|
| `"Linear"` | Constant frame rate |
| `"Quadratic"` | Smooth acceleration |
| `"Cubic"` | More pronounced acceleration |
| `"Quartic"` | Even more pronounced |
| `"Quintic"` | Maximum smoothness |
| `"Sinusoidal"` | Sine wave timing |
| `"Exponential"` | Exponential curve |
| `"Circular"` | Circular timing |
| `"Elastic"` | Elastic effect |
| `"Back"` | Overshoot effect |
| `"Bounce"` | Bouncing effect |

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `bmplistani_error@` | Get last error code |
| `bmplistani_errormsg$@` | Get last error message |
| `bmplistani_strerror$@n` | Get error description for code |
| `bmplistani_clearerror@` | Clear error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `bmplistani#@#` | Create animation on Image control |
| `bmplistani#@#$` | Create named animation |
| `bmplistani_free@#` | Destroy animation |

### Animation Control

| Function | Description |
|----------|-------------|
| `bmplistani_start@#` | Start the animation (requires loaded sprite sheet!) |
| `bmplistani_stop@#` | Stop and reset animation |
| `bmplistani_stopatcurrent@#` | Stop at current frame |

### Sprite Sheet Configuration

| Function | Description |
|----------|-------------|
| `bmplistani_loadspritesheet#@#$` | Load sprite sheet from file |
| `bmplistani_animationbitmap#@##` | Set sprite sheet from Image control |
| `bmplistani_animationbitmap#@#` | Get sprite sheet pointer |
| `bmplistani_animationcount#@#n` | Set total frame count |
| `bmplistani_animationcount@#` | Get total frame count |
| `bmplistani_animationrowcount#@#n` | Set number of rows |
| `bmplistani_animationrowcount@#` | Get number of rows |

### Duration and Delay

| Function | Description |
|----------|-------------|
| `bmplistani_duration#@#n` | Set animation cycle duration (seconds) |
| `bmplistani_duration@#` | Get duration |
| `bmplistani_delay#@#n` | Set delay before start |
| `bmplistani_delay@#` | Get delay |

### Animation Behavior

| Function | Description |
|----------|-------------|
| `bmplistani_animationtype#@#$` | Set animation type |
| `bmplistani_animationtype$@#` | Get animation type |
| `bmplistani_interpolation#@#$` | Set interpolation type |
| `bmplistani_interpolation$@#` | Get interpolation type |
| `bmplistani_loop#@#n` | Set loop mode (0=off, 1=on) |
| `bmplistani_loop@#` | Get loop mode |
| `bmplistani_autoreverse#@#n` | Set auto-reverse (0=off, 1=on) |
| `bmplistani_autoreverse@#` | Get auto-reverse |
| `bmplistani_inverse#@#n` | Set inverse mode |
| `bmplistani_inverse@#` | Get inverse mode |
| `bmplistani_enabled#@#n` | Set enabled state |
| `bmplistani_enabled@#` | Get enabled state |

### State Queries

| Function | Description |
|----------|-------------|
| `bmplistani_running@#` | Check if animation is running |
| `bmplistani_normalizedtime@#` | Get progress (0.0 to 1.0) |
| `bmplistani_name$@#` | Get animation name |

### Property Name

| Function | Description |
|----------|-------------|
| `bmplistani_propertyname#@#$` | Set property (default: "Bitmap") |
| `bmplistani_propertyname$@#` | Get property name |

### Triggers

| Function | Description |
|----------|-------------|
| `bmplistani_trigger#@#$` | Set trigger string |
| `bmplistani_trigger$@#` | Get trigger string |
| `bmplistani_triggerinverse#@#$` | Set inverse trigger |
| `bmplistani_triggerinverse$@#` | Get inverse trigger |

### Event Callbacks

| Function | Description |
|----------|-------------|
| `bmplistani_onfinish#@#$` | Set OnFinish callback |
| `bmplistani_onfinish$@#` | Get OnFinish callback name |
| `bmplistani_onprocess#@#$` | Set OnProcess callback |
| `bmplistani_onprocess$@#` | Get OnProcess callback name |
| `bmplistani_clearcallbacks#@#` | Clear all callbacks |

**Callback Signatures:**
```basic
function OnFinish(sender#) local ...
function OnProcess(sender#) local ...
```

## Usage Examples

### Basic Sprite Animation

```basic
let frm# = form#("Sprite Animation", 400, 400)

' Create image control for displaying the sprite
let sprite# = image#(frm#, 100, 100, 64, 64)

' Create animation
let ani# = bmplistani#(sprite#)

' Load sprite sheet FIRST!
bmplistani_loadspritesheet#(ani#, "character_walk.png")

' Check for load errors
if bmplistani_error() <> 0 then
  println "Error loading sprite sheet: " + bmplistani_errormsg$()
else
  ' Configure animation (8 frames, 2 rows)
  bmplistani_animationcount#(ani#, 8)
  bmplistani_animationrowcount#(ani#, 2)
  bmplistani_duration#(ani#, 1.0)  ' 1 second per cycle
  bmplistani_loop#(ani#, 1)
  
  ' Start animation
  bmplistani_start(ani#)
endif

form_show(frm#)
```

### Using Image Control as Source

```basic
' Load sprite sheet into a hidden image
let sheetImg# = image#(frm#, 0, 0, 256, 128)
image_load#(sheetImg#, "explosion.png")
image_visible#(sheetImg#, 0)  ' Hide source image

' Create animation
let ani# = bmplistani#(displayImg#)
bmplistani_animationbitmap#(ani#, sheetImg#)
bmplistani_animationcount#(ani#, 16)
bmplistani_animationrowcount#(ani#, 4)
bmplistani_duration#(ani#, 0.5)
bmplistani_start(ani#)
```

### Play Once (No Loop)

```basic
' Explosion that plays once
let ani# = bmplistani#(explosionImg#)
bmplistani_loadspritesheet#(ani#, "explosion.png")
bmplistani_animationcount#(ani#, 12)
bmplistani_animationrowcount#(ani#, 3)
bmplistani_duration#(ani#, 0.8)
bmplistani_loop#(ani#, 0)  ' Don't loop
bmplistani_onfinish#(ani#, "OnExplosionDone")
bmplistani_start(ani#)

function OnExplosionDone(sender#)
  image_visible#(explosionImg#, 0)  ' Hide when done
endfunction
```

### Ping-Pong Animation (AutoReverse)

```basic
' Character that walks back and forth
let ani# = bmplistani#(characterImg#)
bmplistani_loadspritesheet#(ani#, "walk_cycle.png")
bmplistani_animationcount#(ani#, 8)
bmplistani_animationrowcount#(ani#, 1)
bmplistani_duration#(ani#, 1.0)
bmplistani_loop#(ani#, 1)
bmplistani_autoreverse#(ani#, 1)  ' Play forward then backward
bmplistani_start(ani#)
```

### Different Speeds

```basic
' Slow idle animation
bmplistani_duration#(idleAni#, 2.0)

' Fast run animation
bmplistani_duration#(runAni#, 0.4)

' Very fast attack animation
bmplistani_duration#(attackAni#, 0.2)
```

### Safe Start with Error Checking

```basic
function StartAnimation(ani#) local errCode
  bmplistani_start(ani#)
  errCode = bmplistani_error()
  if errCode <> 0 then
    println "Animation error: " + bmplistani_errormsg$()
    return 0
  endif
  return 1
endfunction
```

## Creating Sprite Sheets

### Recommended Tools
- **Aseprite** - Pixel art and animation
- **TexturePacker** - Sprite sheet packing
- **Piskel** - Free online pixel art tool
- **GIMP/Photoshop** - Manual arrangement

### Layout Guidelines

1. **Consistent Frame Size**: All frames should be the same size
2. **Power of 2**: Image dimensions as powers of 2 (64, 128, 256) for best compatibility
3. **No Gaps**: Frames should be tightly packed
4. **Row-Major Order**: Frames read left-to-right, top-to-bottom
5. **PNG Format**: Use PNG for transparency support

### Example Layouts

**Walking Animation (8 frames, 1 row)**:
```
[Walk1][Walk2][Walk3][Walk4][Walk5][Walk6][Walk7][Walk8]
AnimationCount = 8, AnimationRowCount = 1
```

**Character States (12 frames, 3 rows)**:
```
[Idle1][Idle2][Idle3][Idle4]    <- Idle animation
[Walk1][Walk2][Walk3][Walk4]    <- Walk animation
[Jump1][Jump2][Jump3][Jump4]    <- Jump animation
AnimationCount = 12, AnimationRowCount = 3
```

## Error Codes

| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Animation is nil |
| 2 | Invalid property or object |
| 3 | Invalid value |
| 4 | Cannot modify while running |
| 5 | Image file not found |
| 6 | Failed to load image / No sprite sheet loaded |

## Tips and Best Practices

1. **Load First!**: Always call `bmplistani_loadspritesheet#` BEFORE `bmplistani_start`. Starting without a sprite sheet will cause an error.

2. **Frame Count**: Set `animationcount` AFTER loading the sprite sheet.

3. **Image Size**: Set the Image control size to match a single frame size for best display.

4. **Duration Calculation**: For specific FPS, use `duration = frameCount / fps`
   - 8 frames at 10 FPS = 0.8 second duration
   - 12 frames at 24 FPS = 0.5 second duration

5. **Memory**: Large sprite sheets consume memory. Use appropriate image sizes for your target platform.

6. **Transparency**: Use PNG format with transparency for sprites that need it.

7. **Multiple Animations**: Create multiple Image controls with different sprite sheets for different character states (idle, walk, run, jump).

8. **Error Checking**: Always check `bmplistani_error()` after loading and starting to catch problems early.

## See Also

- ImageLib - Image control functions
- FloatAnimationLib - Property animations
- PathAnimationLib - Path-based movement
- RectAnimationLib - Bounds/size animations
