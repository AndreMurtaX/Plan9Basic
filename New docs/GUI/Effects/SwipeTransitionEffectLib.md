# SwipeTransitionEffectLib

A transition effect that creates a page-fold/swipe style transition. The page corner is "pulled" to a position, creating a fold that reveals the target image underneath.

## Important: Pixel Coordinates

MousePoint uses **PIXEL coordinates**, not normalized 0-1 values. For a 200x150 image:
- MouseX range: 0 to 200+ (pixels from left)
- MouseY range: 0 to 150+ (pixels from top)
- Deep range: 0 to 100 (fold intensity)

## Functions

| Function | Description |
|----------|-------------|
| `swipetrans#(parent#)` | Creates swipe transition on control |
| `swipetrans_free(effect#)` | Destroys the effect |
| `swipetrans_mousex#(effect#, value)` | Sets mouse X position (pixels) |
| `swipetrans_mousex(effect#)` | Gets mouse X |
| `swipetrans_mousey#(effect#, value)` | Sets mouse Y position (pixels) |
| `swipetrans_mousey(effect#)` | Gets mouse Y |
| `swipetrans_deep#(effect#, value)` | Sets fold depth (0-100) |
| `swipetrans_deep(effect#)` | Gets depth |
| `swipetrans_target#(effect#, bitmap#)` | Sets target bitmap (revealed under fold) |
| `swipetrans_target#(effect#)` | Gets target bitmap |
| `swipetrans_loadtarget#(effect#, url$)` | Loads target from URL or file |
| `swipetrans_targetfromimage#(effect#, img#)` | Sets target from image control |
| `swipetrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `swipetrans_enabled(effect#)` | Gets enabled state |
| `swipetrans_trigger#(effect#, trigger$)` | Sets trigger string |
| `swipetrans_trigger$(effect#)` | Gets trigger string |
| `swipetrans_error()` | Returns last error code |
| `swipetrans_errormsg$()` | Returns last error message |
| `swipetrans_strerror$(code)` | Converts error code to text |
| `swipetrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| MousePointX | 0 - width+ | 5 | X pixel position where corner is pulled |
| MousePointY | 0 - height+ | 5 | Y pixel position where corner is pulled |
| Deep | 0 - 100 | 20 | Fold intensity/depth |

## How It Works

- The page folds from the top-left corner (default)
- MousePoint is where the corner is "pulled" to
- Moving MousePoint away from corner creates the fold
- Target image is revealed UNDER the lifted page
- Deep controls how curved/folded the page appears

## Example 1: Basic Page Fold

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let swipe# = Pointer#(0)

let imgW = 200
let imgH = 150

frm# = form#("Swipe Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, imgW, imgH)
image_load#(img#, "https://picsum.photos/200/150?random=1")

swipe# = swipetrans#(img#)
swipetrans_loadtarget#(swipe#, "https://picsum.photos/200/150?random=2")

' Pull corner to middle of image (pixel coordinates)
swipetrans_mousex#(swipe#, 100)
swipetrans_mousey#(swipe#, 75)
swipetrans_deep#(swipe#, 30)

form_show(frm#)
```

## Example 2: Interactive Swipe Control

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let swipe# = Pointer#(0)
let trkX# = Pointer#(0)
let trkY# = Pointer#(0)
let trkDeep# = Pointer#(0)
let lblX# = Pointer#(0)
let lblY# = Pointer#(0)
let lblDeep# = Pointer#(0)

let imgW = 200
let imgH = 150

frm# = form#("Swipe Control", 500, 500)

img# = image#(frm#)
image_bounds#(img#, 150, 20, imgW, imgH)
image_load#(img#, "https://picsum.photos/200/150?random=1")

swipe# = swipetrans#(img#)
swipetrans_loadtarget#(swipe#, "https://picsum.photos/200/150?random=2")

' X slider (0 to image width)
lblX# = label#(frm#, "Mouse X: 100", 30, 190)
trkX# = trackbar#(frm#)
trackbar_bounds#(trkX#, 30, 215, 440, 25)
trackbar_max#(trkX#, imgW)
trackbar_value#(trkX#, 100)
trackbar_onchange#(trkX#, "OnX")

' Y slider (0 to image height)
lblY# = label#(frm#, "Mouse Y: 75", 30, 260)
trkY# = trackbar#(frm#)
trackbar_bounds#(trkY#, 30, 285, 440, 25)
trackbar_max#(trkY#, imgH)
trackbar_value#(trkY#, 75)
trackbar_onchange#(trkY#, "OnY")

' Deep slider (0 to 100)
lblDeep# = label#(frm#, "Deep: 30", 30, 330)
trkDeep# = trackbar#(frm#)
trackbar_bounds#(trkDeep#, 30, 355, 440, 25)
trackbar_max#(trkDeep#, 100)
trackbar_value#(trkDeep#, 30)
trackbar_onchange#(trkDeep#, "OnDeep")

' Initialize effect
swipetrans_mousex#(swipe#, 100)
swipetrans_mousey#(swipe#, 75)
swipetrans_deep#(swipe#, 30)

form_show(frm#)

function OnX(sender#) local v
  let v = trackbar_value(trkX#)
  swipetrans_mousex#(swipe#, v)
  label_text#(lblX#, "Mouse X: " + str$(v))
endfunction

function OnY(sender#) local v
  let v = trackbar_value(trkY#)
  swipetrans_mousey#(swipe#, v)
  label_text#(lblY#, "Mouse Y: " + str$(v))
endfunction

function OnDeep(sender#) local v
  let v = trackbar_value(trkDeep#)
  swipetrans_deep#(swipe#, v)
  label_text#(lblDeep#, "Deep: " + str$(v))
endfunction
```

## Example 3: Animated Page Turn

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let swipe# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

let imgW = 200
let imgH = 150

frm# = form#("Page Turn Animation", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, imgW, imgH)
image_load#(img#, "https://picsum.photos/200/150?random=1")

swipe# = swipetrans#(img#)
swipetrans_loadtarget#(swipe#, "https://picsum.photos/200/150?random=2")
swipetrans_mousex#(swipe#, 0)
swipetrans_mousey#(swipe#, 0)
swipetrans_deep#(swipe#, 30)

tmr# = timer#(frm#)
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Turn Page")
button_bounds#(btn#, 140, 210, 120, 30)
button_onclick#(btn#, "StartTurn")

form_show(frm#)

function StartTurn(sender#)
  progress = 0
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#) local x, y
  progress = progress + 0.03
  
  ' Animate corner from top-left to bottom-right
  let x = progress * imgW
  let y = progress * imgH
  
  swipetrans_mousex#(swipe#, x)
  swipetrans_mousey#(swipe#, y)
  
  if progress >= 1 then
    timer_enabled#(tmr#, 0)
    button_enabled#(btn#, 1)
  endif
endfunction
```

## Notes

- **MousePoint is in PIXELS**, not normalized 0-1 values
- Default corner is top-left (0,0)
- Move MousePoint diagonally away from corner for best effect
- Deep 20-40 gives natural page curl
- Target image shows what's "underneath" the page
- Animate MousePoint for page-turn effect

## See Also

- SlideTransitionEffectLib - Slide transition
- FadeTransitionEffectLib - Cross-fade transition
- DropTransitionEffectLib - Drop transition
