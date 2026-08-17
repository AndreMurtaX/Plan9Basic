# LineTransitionEffectLib

A transition effect that reveals the target image along a line that sweeps across the source image. The line can originate from any direction, creating various wipe effects.

## Functions

| Function | Description |
|----------|-------------|
| `linetrans#(parent#)` | Creates line transition effect on control |
| `linetrans_free(effect#)` | Destroys the effect |
| `linetrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `linetrans_progress(effect#)` | Gets progress |
| `linetrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `linetrans_target#(effect#)` | Gets target bitmap |
| `linetrans_loadtarget#(effect#, url$)` | Loads target from URL or file |
| `linetrans_fuzzyamount#(effect#, value)` | Sets edge softness (0-1) |
| `linetrans_fuzzyamount(effect#)` | Gets fuzzy amount |
| `linetrans_originx#(effect#, value)` | Sets X origin point (0-1) |
| `linetrans_originx(effect#)` | Gets X origin |
| `linetrans_originy#(effect#, value)` | Sets Y origin point (0-1) |
| `linetrans_originy(effect#)` | Gets Y origin |
| `linetrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `linetrans_enabled(effect#)` | Gets enabled state |
| `linetrans_error()` | Returns last error code |
| `linetrans_errormsg$()` | Returns last error message |
| `linetrans_strerror$(code)` | Converts error code to text |
| `linetrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |
| FuzzyAmount | 0.0 - 1.0 | 0.0 | Edge softness (0=hard, 1=soft) |
| OriginX | 0.0 - 1.0 | 0.0 | X origin of line sweep |
| OriginY | 0.0 - 1.0 | 0.0 | Y origin of line sweep |

## Origin Values

| OriginX | OriginY | Wipe Direction |
|---------|---------|----------------|
| 0.0 | 0.0 | From top-left corner |
| 1.0 | 0.0 | From top-right corner |
| 0.0 | 1.0 | From bottom-left corner |
| 1.0 | 1.0 | From bottom-right corner |
| 0.5 | 0.0 | From top center (horizontal) |
| 0.0 | 0.5 | From left center (vertical) |

## Example 1: Basic Line Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Line Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create line transition effect
trans# = linetrans#(img#)
linetrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

' Progress slider
lblProg# = label#(frm#, "Progress: 0.00", 50, 200)
trkProg# = trackbar#(frm#)
trackbar_bounds#(trkProg#, 50, 230, 350, 30)
trackbar_max#(trkProg#, 100)
trackbar_value#(trkProg#, 0)
trackbar_onchange#(trkProg#, "OnProgress")

form_show(frm#)

function OnProgress(sender#) local p
  let p = trackbar_value(trkProg#) / 100
  linetrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Line Wipe

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Animated Line Wipe", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = linetrans#(img#)
linetrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
linetrans_fuzzyamount#(trans#, 0.1)

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Wipe!")
button_bounds#(btn#, 150, 210, 100, 30)
button_onclick#(btn#, "StartWipe")

form_show(frm#)

function StartWipe(sender#)
  progress = 0
  timer_enabled#(tmr#, 1)
  button_enabled#(btn#, 0)
endfunction

function Animate(sender#)
  progress = progress + 0.02
  linetrans_progress#(trans#, progress)
  
  if progress >= 1 then
    timer_enabled#(tmr#, 0)
    button_enabled#(btn#, 1)
  endif
endfunction
```

## Example 3: Different Wipe Directions

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)
let lblDir# = Pointer#(0)

frm# = form#("Wipe Directions", 500, 450)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = linetrans#(img#)
linetrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
linetrans_fuzzyamount#(trans#, 0.05)

' Progress control
lblProg# = label#(frm#, "Progress: 0.50", 30, 190)
trkProg# = trackbar#(frm#)
trackbar_bounds#(trkProg#, 30, 215, 440, 25)
trackbar_max#(trkProg#, 100)
trackbar_value#(trkProg#, 50)
trackbar_onchange#(trkProg#, "OnProgress")

lblDir# = label#(frm#, "Direction: Top-Left", 30, 260)

' Direction buttons
let btn1# = button#(frm#, "Top-Left")
button_bounds#(btn1#, 30, 290, 100, 30)
button_onclick#(btn1#, "DirTopLeft")

let btn2# = button#(frm#, "Top-Right")
button_bounds#(btn2#, 140, 290, 100, 30)
button_onclick#(btn2#, "DirTopRight")

let btn3# = button#(frm#, "Bottom-Left")
button_bounds#(btn3#, 250, 290, 100, 30)
button_onclick#(btn3#, "DirBottomLeft")

let btn4# = button#(frm#, "Bottom-Right")
button_bounds#(btn4#, 360, 290, 100, 30)
button_onclick#(btn4#, "DirBottomRight")

' Set initial progress
linetrans_progress#(trans#, 0.5)

form_show(frm#)

function OnProgress(sender#) local p
  let p = trackbar_value(trkProg#) / 100
  linetrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction

function DirTopLeft(sender#)
  linetrans_originx#(trans#, 0)
  linetrans_originy#(trans#, 0)
  label_text#(lblDir#, "Direction: Top-Left")
endfunction

function DirTopRight(sender#)
  linetrans_originx#(trans#, 1)
  linetrans_originy#(trans#, 0)
  label_text#(lblDir#, "Direction: Top-Right")
endfunction

function DirBottomLeft(sender#)
  linetrans_originx#(trans#, 0)
  linetrans_originy#(trans#, 1)
  label_text#(lblDir#, "Direction: Bottom-Left")
endfunction

function DirBottomRight(sender#)
  linetrans_originx#(trans#, 1)
  linetrans_originy#(trans#, 1)
  label_text#(lblDir#, "Direction: Bottom-Right")
endfunction
```

## Notes

- Transition effects require a TARGET image to work properly
- OriginX and OriginY control the direction of the wipe
- FuzzyAmount creates a soft edge on the transition line
- Classic "wipe" effect used in video editing

## See Also

- BlindTransitionEffectLib - Venetian blinds effect
- SlideTransitionEffectLib - Sliding transition
- CircleTransitionEffectLib - Circular wipe transition
