# BitmapListAnimationLib

Animates through a sequence of images (sprite sheet animation). Essential for creating animated sprites, loading indicators, character animations, and any frame-by-frame animation in Plan9Basic applications.

## Functions

| Function | Description |
|----------|-------------|
| `bmplistani#(parent#)` | Creates a bitmap list animation attached to parent Image control |
| `bmplistani#(parent#, name$)` | Creates a named bitmap list animation |
| `bmplistani_free(ani#)` | Frees the animation object |
| `bmplistani_start(ani#)` | Starts the animation |
| `bmplistani_stop(ani#)` | Stops the animation and resets to first frame |
| `bmplistani_stopatcurrent(ani#)` | Stops at current frame |
| `bmplistani_propertyname#(ani#, name$)` | Sets the property to animate |
| `bmplistani_propertyname$(ani#)` | Gets the property name |
| `bmplistani_animationbitmap#(ani#, sourceImage#)` | Sets the sprite sheet from an Image control's bitmap |
| `bmplistani_animationbitmap#(ani#)` | Gets the sprite sheet bitmap pointer |
| `bmplistani_animationcount#(ani#, count)` | Sets total number of frames in sprite sheet |
| `bmplistani_animationcount(ani#)` | Gets frame count |
| `bmplistani_animationrowcount#(ani#, rows)` | Sets number of rows in sprite sheet grid |
| `bmplistani_animationrowcount(ani#)` | Gets row count |
| `bmplistani_loadspritesheet#(ani#, filename$)` | Loads sprite sheet from local file and sets bitmap |
| `bmplistani_duration#(ani#, seconds)` | Sets total animation duration |
| `bmplistani_duration(ani#)` | Gets duration |
| `bmplistani_delay#(ani#, seconds)` | Sets delay before start |
| `bmplistani_delay(ani#)` | Gets delay |
| `bmplistani_animationtype#(ani#, type$)` | Sets easing type |
| `bmplistani_animationtype$(ani#)` | Gets animation type |
| `bmplistani_interpolation#(ani#, type$)` | Sets interpolation curve |
| `bmplistani_interpolation$(ani#)` | Gets interpolation type |
| `bmplistani_autoreverse#(ani#, flag)` | If 1, plays backward after forward |
| `bmplistani_autoreverse(ani#)` | Gets autoreverse flag |
| `bmplistani_inverse#(ani#, flag)` | If 1, plays in reverse |
| `bmplistani_inverse(ani#)` | Gets inverse flag |
| `bmplistani_loop#(ani#, flag)` | If 1, loops indefinitely |
| `bmplistani_loop(ani#)` | Gets loop flag |
| `bmplistani_enabled#(ani#, flag)` | Enables/disables animation |
| `bmplistani_enabled(ani#)` | Gets enabled state |
| `bmplistani_running(ani#)` | Returns 1 if animation is running |
| `bmplistani_normalizedtime(ani#)` | Returns progress 0.0-1.0 |
| `bmplistani_name$(ani#)` | Gets the animation name |
| `bmplistani_trigger#(ani#, expr$)` | Sets trigger expression |
| `bmplistani_trigger$(ani#)` | Gets trigger expression |
| `bmplistani_triggerinverse#(ani#, expr$)` | Sets inverse trigger |
| `bmplistani_triggerinverse$(ani#)` | Gets inverse trigger |
| `bmplistani_onfinish#(ani#, callback$)` | Sets finish callback function |
| `bmplistani_onfinish$(ani#)` | Gets finish callback name |
| `bmplistani_onprocess#(ani#, callback$)` | Sets per-frame callback |
| `bmplistani_onprocess$(ani#)` | Gets process callback name |
| `bmplistani_clearcallbacks#(ani#)` | Removes all callbacks |
| `bmplistani_error()` | Returns last error code |
| `bmplistani_errormsg$()` | Returns last error message |
| `bmplistani_strerror$(code)` | Converts error code to message |
| `bmplistani_clearerror()` | Clears the error state |

## Sprite Sheet Layout

Sprite sheets are organized as grids of frames:

```
+-------+-------+-------+-------+
| Frame | Frame | Frame | Frame |  <- Row 1
|   0   |   1   |   2   |   3   |
+-------+-------+-------+-------+
| Frame | Frame | Frame | Frame |  <- Row 2
|   4   |   5   |   6   |   7   |
+-------+-------+-------+-------+
```

- **AnimationCount**: Total number of frames (e.g., 8)
- **AnimationRowCount**: Number of rows in the grid (e.g., 2)
- Frames are numbered left-to-right, top-to-bottom starting from 0

## Animation Types

| Type | Description |
|------|-------------|
| `"In"` | Acceleration at start |
| `"Out"` | Deceleration at end |
| `"InOut"` | Accelerate then decelerate |

## Interpolation Types

For sprite animations, `"Linear"` is typically preferred for consistent frame timing.

| Type | Description |
|------|-------------|
| `"Linear"` | Even frame timing (recommended) |
| `"Quadratic"` | Accelerating frame rate |
| `"Cubic"` | More pronounced acceleration |

## Error Codes

| Code | Meaning |
|------|---------|
| 0 | No error |
| 1 | Animation is nil |
| 2 | Invalid bitmap |
| 3 | Invalid value |
| 4 | Animation is running |
| 5 | File not found or load error |

## Getting Sprite Sheets

Before running the examples, you'll need sprite sheet images. Here are some free resources:

1. **OpenGameArt.org** - CC0 licensed game assets
   - Search for "sprite sheet" or "animation"
   - Example: https://opengameart.org/content/coin-animation
   
2. **Kenney.nl** - Free CC0 game assets
   - Includes characters, effects, and UI elements
   
3. **itch.io** - Many free sprite packs
   - Search "free sprite sheet"

Save the sprite sheet PNG file to your project folder and reference it by local path.

## Example: Simple Sprite Animation from Local File

```basic
' Animate through frames of a sprite sheet
' Download any 4-frame sprite sheet and save as "spritesheet.png"
' The sprite sheet should have 4 equal-sized frames in a single row
let frm# = form#("Sprite Demo", 400, 300)

' Create image control to display sprite
let sprite# = image#(frm#, 150, 100, 100, 100)

' Create bitmap list animation
let spriteAni# = bmplistani#(sprite#)

' Load sprite sheet from local file (replace with your sprite sheet path)
' Example: "C:\MyProject\coin_spritesheet.png" on Windows
'          "/Users/me/MyProject/coin_spritesheet.png" on macOS
let path$ = "spritesheet.png"
bmplistani_loadspritesheet#(spriteAni#, path$)
bmplistani_animationcount#(spriteAni#, 4)
bmplistani_animationrowcount#(spriteAni#, 1)
bmplistani_duration#(spriteAni#, 0.5)
bmplistani_interpolation#(spriteAni#, "Linear")
bmplistani_loop#(spriteAni#, 1)

' Check for load errors
if bmplistani_error() <> 0 then
    print "Error loading sprite sheet: " + bmplistani_errormsg$()
else
    bmplistani_start(spriteAni#)
end if

form_show(frm#)
```

## Example: Loading Spinner Animation

```basic
' Create a spinner/loading animation
' Use an 8-frame spinner sprite sheet (frames arranged horizontally)
let frm# = form#("Loading Demo", 300, 200)

let lbl# = label#(frm#, "Loading...")
label_move#(lbl#, 110, 150)

' Image for the spinner
let spinner# = image#(frm#, 100, 40, 100, 100)

' Create animation
let spinAni# = bmplistani#(spinner#)

' Load spinner sprite sheet (8 frames in single row)
' You can create this using a tool like Piskel (piskelapp.com)
' or download from OpenGameArt (search "loading spinner sprite")
bmplistani_loadspritesheet#(spinAni#, "spinner.png")
bmplistani_animationcount#(spinAni#, 8)
bmplistani_animationrowcount#(spinAni#, 1)
bmplistani_duration#(spinAni#, 1.0)
bmplistani_interpolation#(spinAni#, "Linear")
bmplistani_loop#(spinAni#, 1)
bmplistani_start(spinAni#)

form_show(frm#)
```

## Example: Character Walk Cycle

```basic
' Character walking animation with 8 frames (2 rows x 4 columns)
' Download a walk cycle sprite sheet from OpenGameArt or Kenney.nl
let frm# = form#("Walk Cycle Demo", 400, 300)

let bg# = rectangle#(frm#)
rectangle_bounds#(bg#, 0, 0, 400, 300)
rectangle_fill#(bg#, "#87CEEB")  ' Sky blue background

' Character sprite
let character# = image#(frm#, 160, 150, 80, 100)

' Walk animation
let walkAni# = bmplistani#(character#)

' Sprite sheet layout (example: 8 frames, 2 rows):
' Row 1: Frames 0-3 (first half of walk cycle)
' Row 2: Frames 4-7 (second half of walk cycle)
bmplistani_loadspritesheet#(walkAni#, "character_walk.png")
bmplistani_animationcount#(walkAni#, 8)
bmplistani_animationrowcount#(walkAni#, 2)
bmplistani_duration#(walkAni#, 0.8)
bmplistani_interpolation#(walkAni#, "Linear")
bmplistani_loop#(walkAni#, 1)
bmplistani_start(walkAni#)

form_show(frm#)
```

## Example: Explosion Effect with Callback

```basic
' Explosion animation that plays once then hides
' Get a free explosion sprite sheet from OpenGameArt:
' https://opengameart.org/content/explosion-sheet (CC0 license)
let frm# = form#("Explosion Demo", 400, 300)

let bg# = rectangle#(frm#)
rectangle_bounds#(bg#, 0, 0, 400, 300)
rectangle_fill#(bg#, "#1a1a2e")  ' Dark background

let explosion# = image#(frm#, 100, 30, 200, 200)

let explodeAni# = bmplistani#(explosion#)

' Load explosion sprite sheet (example: 16 frames, 4x4 grid)
bmplistani_loadspritesheet#(explodeAni#, "explosion.png")
bmplistani_animationcount#(explodeAni#, 16)
bmplistani_animationrowcount#(explodeAni#, 4)
bmplistani_duration#(explodeAni#, 1.0)
bmplistani_interpolation#(explodeAni#, "Linear")
bmplistani_loop#(explodeAni#, 0)  ' Don't loop - play once
bmplistani_onfinish#(explodeAni#, "hideexplosion")

let btn# = button#(frm#, "Explode!", 150, 250, 100, 35)
button_onclick#(btn#, "startexplosion")

image_visible#(explosion#, 0)  ' Initially hidden

form_show(frm#)

function startexplosion(sender#)
    image_visible#(explosion#, 1)
    bmplistani_start(explodeAni#)
end function

function hideexplosion(sender#)
    image_visible#(explosion#, 0)
end function
```

## Example: Using Image Control as Sprite Sheet Source

```basic
' Alternative method: load sprite sheet into an Image control first
' Useful when you need to manipulate the sprite sheet image
let frm# = form#("Image Source Demo", 400, 300)

' Hidden Image control to hold the sprite sheet
let sheetImg# = image#(frm#, 0, 0, 128, 32)
image_load#(sheetImg#, "coin.png")
image_visible#(sheetImg#, 0)  ' Hide the source image

' Visible sprite for animation
let coin# = image#(frm#, 175, 125, 50, 50)

' Create animation and use the hidden image as source
let coinAni# = bmplistani#(coin#)
bmplistani_animationbitmap#(coinAni#, sheetImg#)
bmplistani_animationcount#(coinAni#, 4)
bmplistani_animationrowcount#(coinAni#, 1)
bmplistani_duration#(coinAni#, 0.4)
bmplistani_interpolation#(coinAni#, "Linear")
bmplistani_loop#(coinAni#, 1)
bmplistani_start(coinAni#)

form_show(frm#)
```

## Example: Interactive Frame Display with Progress

```basic
' Show current frame number and progress during animation
let frm# = form#("Frame Counter Demo", 400, 350)

let sprite# = image#(frm#, 100, 30, 200, 150)

let frameLbl# = label#(frm#, "Frame: 0")
label_move#(frameLbl#, 160, 200)
label_fontsize#(frameLbl#, 16)

let progressLbl# = label#(frm#, "Progress: 0%")
label_move#(progressLbl#, 145, 230)
label_fontsize#(progressLbl#, 14)

let spriteAni# = bmplistani#(sprite#)

' Load any sprite sheet with 12 frames (3 rows x 4 columns)
bmplistani_loadspritesheet#(spriteAni#, "animation_12frames.png")
bmplistani_animationcount#(spriteAni#, 12)
bmplistani_animationrowcount#(spriteAni#, 3)
bmplistani_duration#(spriteAni#, 2.0)
bmplistani_interpolation#(spriteAni#, "Linear")
bmplistani_loop#(spriteAni#, 1)
bmplistani_onprocess#(spriteAni#, "showframe")

let btnStart# = button#(frm#, "Start", 100, 280, 80, 35)
button_onclick#(btnStart#, "startan")

let btnStop# = button#(frm#, "Stop", 220, 280, 80, 35)
button_onclick#(btnStop#, "stopan")

form_show(frm#)

function startan(sender#)
    bmplistani_start(spriteAni#)
end function

function stopan(sender#)
    bmplistani_stop(spriteAni#)
end function

function showframe(sender#) local frame, progress
    progress = bmplistani_normalizedtime(spriteAni#)
    frame = int(progress * 12)
    label_text#(frameLbl#, "Frame: " + str$(frame))
    label_text#(progressLbl#, "Progress: " + stri$(progress * 100, 1) + "%")
end function
```

## Example: Speed Control

```basic
' Adjust animation speed dynamically with buttons
let frm# = form#("Speed Control Demo", 400, 380)

let sprite# = image#(frm#, 125, 30, 150, 150)

let spriteAni# = bmplistani#(sprite#)

' Load an 8-frame running or walking sprite sheet
bmplistani_loadspritesheet#(spriteAni#, "running.png")
bmplistani_animationcount#(spriteAni#, 8)
bmplistani_animationrowcount#(spriteAni#, 1)
bmplistani_duration#(spriteAni#, 1.0)
bmplistani_interpolation#(spriteAni#, "Linear")
bmplistani_loop#(spriteAni#, 1)
bmplistani_start(spriteAni#)

let speedLbl# = label#(frm#, "Duration: 1.0s")
label_move#(speedLbl#, 145, 200)
label_fontsize#(speedLbl#, 14)

let fpsLbl# = label#(frm#, "(8 FPS)")
label_move#(fpsLbl#, 165, 225)
label_fontsize#(fpsLbl#, 12)

let btnSlower# = button#(frm#, "Slower", 80, 270, 100, 40)
button_onclick#(btnSlower#, "slower")

let btnFaster# = button#(frm#, "Faster", 220, 270, 100, 40)
button_onclick#(btnFaster#, "faster")

let btnReset# = button#(frm#, "Reset (1.0s)", 130, 320, 140, 35)
button_onclick#(btnReset#, "resetspeed")

let currentSpeed = 1.0

form_show(frm#)

function updatespeedlabels() local fps
    fps = 8 / currentSpeed
    label_text#(speedLbl#, "Duration: " + stri$(currentSpeed, 2) + "s")
    label_text#(fpsLbl#, "(" + stri$(fps, 1) + " FPS)")
end function

function slower(sender#)
    currentSpeed = currentSpeed + 0.25
    if currentSpeed > 4.0 then currentSpeed = 4.0
    bmplistani_stop(spriteAni#)
    bmplistani_duration#(spriteAni#, currentSpeed)
    bmplistani_start(spriteAni#)
    updatespeedlabels()
end function

function faster(sender#)
    currentSpeed = currentSpeed - 0.25
    if currentSpeed < 0.25 then currentSpeed = 0.25
    bmplistani_stop(spriteAni#)
    bmplistani_duration#(spriteAni#, currentSpeed)
    bmplistani_start(spriteAni#)
    updatespeedlabels()
end function

function resetspeed(sender#)
    currentSpeed = 1.0
    bmplistani_stop(spriteAni#)
    bmplistani_duration#(spriteAni#, currentSpeed)
    bmplistani_start(spriteAni#)
    updatespeedlabels()
end function
```

## Example: Auto-Reverse Animation (Ping-Pong)

```basic
' Animation that plays forward then backward continuously
let frm# = form#("Auto-Reverse Demo", 350, 300)

let sprite# = image#(frm#, 125, 50, 100, 100)

let spriteAni# = bmplistani#(sprite#)

' Any sprite sheet will work - the animation will ping-pong
bmplistani_loadspritesheet#(spriteAni#, "character.png")
bmplistani_animationcount#(spriteAni#, 6)
bmplistani_animationrowcount#(spriteAni#, 1)
bmplistani_duration#(spriteAni#, 1.5)
bmplistani_interpolation#(spriteAni#, "Linear")
bmplistani_autoreverse#(spriteAni#, 1)  ' Enable ping-pong
bmplistani_loop#(spriteAni#, 1)
bmplistani_start(spriteAni#)

let lbl# = label#(frm#, "Auto-reverse enabled: animation plays")
label_move#(lbl#, 30, 180)

let lbl2# = label#(frm#, "forward then backward continuously")
label_move#(lbl2#, 40, 200)

let btnToggle# = button#(frm#, "Toggle Auto-Reverse", 95, 240, 160, 35)
button_onclick#(btnToggle#, "toggle")

form_show(frm#)

function toggle(sender#) local current
    bmplistani_stop(spriteAni#)
    current = bmplistani_autoreverse(spriteAni#)
    if current = 1 then
        bmplistani_autoreverse#(spriteAni#, 0)
        label_text#(lbl#, "Auto-reverse disabled: animation plays")
        label_text#(lbl2#, "forward only, then restarts")
    else
        bmplistani_autoreverse#(spriteAni#, 1)
        label_text#(lbl#, "Auto-reverse enabled: animation plays")
        label_text#(lbl2#, "forward then backward continuously")
    end if
    bmplistani_start(spriteAni#)
end function
```

## Example: Multiple Animations

```basic
' Multiple animated sprites on the same form
let frm# = form#("Multiple Animations", 500, 350)

let bg# = rectangle#(frm#)
rectangle_bounds#(bg#, 0, 0, 500, 350)
rectangle_fill#(bg#, "#2d2d44")

' First sprite - coin
let coin# = image#(frm#, 50, 100, 64, 64)
let coinAni# = bmplistani#(coin#)
bmplistani_loadspritesheet#(coinAni#, "coin.png")
bmplistani_animationcount#(coinAni#, 6)
bmplistani_animationrowcount#(coinAni#, 1)
bmplistani_duration#(coinAni#, 0.5)
bmplistani_interpolation#(coinAni#, "Linear")
bmplistani_loop#(coinAni#, 1)

let coinLbl# = label#(frm#, "Coin (0.5s)")
label_move#(coinLbl#, 45, 170)
label_fontcolor#(coinLbl#, "#ffffff")

' Second sprite - explosion
let explos# = image#(frm#, 175, 80, 80, 100)
let explosAni# = bmplistani#(explos#)
bmplistani_loadspritesheet#(explosAni#, "Explosion.png")
bmplistani_animationcount#(explosAni#, 8)
bmplistani_animationrowcount#(explosAni#, 2)
bmplistani_duration#(explosAni#, 0.8)
bmplistani_interpolation#(explosAni#, "Linear")
bmplistani_loop#(explosAni#, 1)

let explosLbl# = label#(frm#, "Explosion (0.8s)")
label_move#(explosLbl#, 170, 185)
label_fontcolor#(explosLbl#, "#ffffff")

' Third sprite - character
let char# = image#(frm#, 320, 90, 100, 100)
let charAni# = bmplistani#(char#)
bmplistani_loadspritesheet#(charAni#, "character_idle.png")
bmplistani_animationcount#(charAni#, 4)
bmplistani_animationrowcount#(charAni#, 1)
bmplistani_duration#(charAni#, 1.2)
bmplistani_interpolation#(charAni#, "Linear")
bmplistani_loop#(charAni#, 1)

let charLbl# = label#(frm#, "Character (1.2s)")
label_move#(charLbl#, 315, 195)
label_fontcolor#(charLbl#, "#ffffff")

' Start all button
let btnStartAll# = button#(frm#, "Start All", 120, 270, 120, 40)
button_onclick#(btnStartAll#, "startall")

' Stop all button  
let btnStopAll# = button#(frm#, "Stop All", 260, 270, 120, 40)
button_onclick#(btnStopAll#, "stopall")

form_show(frm#)

function startall(sender#)
    bmplistani_start(coinAni#)
    bmplistani_start(explosAni#)
    bmplistani_start(charAni#)
end function

function stopall(sender#)
    bmplistani_stop(coinAni#)
    bmplistani_stop(explosAni#)
    bmplistani_stop(charAni#)
end function
```

## Creating Your Own Sprite Sheets

### Using Piskel (Free Online Tool)

1. Go to https://www.piskelapp.com/
2. Create frames of your animation
3. Export as PNG sprite sheet (horizontal strip)
4. Save to your project folder

### Using TexturePacker

1. Create individual frame images
2. Use TexturePacker to combine them into a single sprite sheet
3. Export as PNG with uniform frame sizes

### Manual Creation (Any Image Editor)

1. Determine frame size (e.g., 64x64 pixels)
2. Create a new image with width = frame_width × frame_count
3. For multiple rows: height = frame_height × row_count
4. Draw each frame in sequence, left-to-right, top-to-bottom
5. Save as PNG with transparency if needed

### Sprite Sheet Requirements

- All frames must have **identical dimensions**
- Frames arranged in a grid: left-to-right, top-to-bottom
- No gaps or spacing between frames
- PNG format recommended for transparency support

## Tips for Sprite Sheets

1. **Consistent frame size**: All frames must be the same dimensions
2. **Power of 2**: For best performance, use power-of-2 dimensions (64, 128, 256, etc.)
3. **No gaps**: Frames should be tightly packed with no spacing
4. **Frame order**: Frames are read left-to-right, top-to-bottom
5. **Transparency**: Use PNG format with alpha channel for transparent backgrounds
6. **Linear interpolation**: Use "Linear" for consistent frame timing in most animations
7. **Duration calculation**: Duration / AnimationCount = time per frame
8. **Error checking**: Always check `bmplistani_error()` after loading sprite sheets

## Troubleshooting

### Common Issues

**"File not found" error:**
- Use full absolute path or ensure file is in the application's working directory
- Check file extension and spelling

**Animation not visible:**
- Verify the Image control is visible and has proper dimensions
- Check that the sprite sheet loaded successfully
- Ensure `bmplistani_start()` was called

**Animation appears wrong:**
- Verify `animationcount` matches the actual frame count
- Verify `animationrowcount` matches the sprite sheet layout
- Check that frame dimensions are uniform in the sprite sheet
