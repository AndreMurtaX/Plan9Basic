# CircleTransitionEffectLib

A transition effect that reveals the target image through an expanding or contracting circle. Creates a classic "iris wipe" transition commonly seen in video editing.

## Functions

| Function | Description |
|----------|-------------|
| `circletrans#(parent#)` | Creates circle transition effect on control |
| `circletrans_free(effect#)` | Destroys the effect |
| `circletrans_progress#(effect#, value)` | Sets transition progress (0.0-1.0) |
| `circletrans_progress(effect#)` | Gets progress |
| `circletrans_target#(effect#, bitmap#)` | Sets target bitmap |
| `circletrans_target#(effect#)` | Gets target bitmap |
| `circletrans_loadtarget#(effect#, url$)` | Loads target from URL or file |
| `circletrans_targetfromimage#(effect#, image#)` | Copies target from TImage control |
| `circletrans_fuzzy#(effect#, value)` | Sets edge softness (0-1) |
| `circletrans_fuzzy(effect#)` | Gets fuzzy amount |
| `circletrans_circlesize#(effect#, value)` | Sets circle size factor (0-2) |
| `circletrans_circlesize(effect#)` | Gets circle size |
| `circletrans_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `circletrans_enabled(effect#)` | Gets enabled state |
| `circletrans_trigger#(effect#, trigger$)` | Sets trigger expression |
| `circletrans_trigger$(effect#)` | Gets trigger expression |
| `circletrans_error()` | Returns last error code |
| `circletrans_errormsg$()` | Returns last error message |
| `circletrans_strerror$(code)` | Converts error code to text |
| `circletrans_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source, 1=target) |
| FuzzyAmount | 0.0 - 1.0 | 0.1 | Edge softness (0=hard, 1=very soft) |
| CircleSize | 0.0 - 2.0 | 1.0 | Circle size multiplier |

## Example 1: Basic Circle Transition

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let lblProg# = Pointer#(0)

frm# = form#("Circle Transition", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

' Create circle transition effect
trans# = circletrans#(img#)
circletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

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
  circletrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction
```

## Example 2: Animated Circle Wipe

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let progress = 0

frm# = form#("Circle Wipe Animation", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = circletrans#(img#)
circletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")
circletrans_fuzzy#(trans#, 0.05)

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Start Wipe")
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
  circletrans_progress#(trans#, progress)
  
  if progress >= 1 then
    timer_enabled#(tmr#, 0)
    button_enabled#(btn#, 1)
  endif
endfunction
```

## Example 3: Adjustable Circle Parameters

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let trans# = Pointer#(0)
let trkProg# = Pointer#(0)
let trkFuzzy# = Pointer#(0)
let trkSize# = Pointer#(0)
let lblProg# = Pointer#(0)
let lblFuzzy# = Pointer#(0)
let lblSize# = Pointer#(0)

frm# = form#("Circle Parameters", 500, 450)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150?random=1")

trans# = circletrans#(img#)
circletrans_loadtarget#(trans#, "https://picsum.photos/200/150?random=2")

' Progress control
lblProg# = label#(frm#, "Progress: 0.50", 30, 190)
trkProg# = trackbar#(frm#)
trackbar_bounds#(trkProg#, 30, 215, 440, 25)
trackbar_max#(trkProg#, 100)
trackbar_value#(trkProg#, 50)
trackbar_onchange#(trkProg#, "OnProgress")

' Fuzzy control
lblFuzzy# = label#(frm#, "Fuzzy: 0.10", 30, 255)
trkFuzzy# = trackbar#(frm#)
trackbar_bounds#(trkFuzzy#, 30, 280, 440, 25)
trackbar_max#(trkFuzzy#, 100)
trackbar_value#(trkFuzzy#, 10)
trackbar_onchange#(trkFuzzy#, "OnFuzzy")

' Circle size control
lblSize# = label#(frm#, "Size: 1.00", 30, 320)
trkSize# = trackbar#(frm#)
trackbar_bounds#(trkSize#, 30, 345, 440, 25)
trackbar_max#(trkSize#, 200)
trackbar_value#(trkSize#, 100)
trackbar_onchange#(trkSize#, "OnSize")

' Set initial progress
circletrans_progress#(trans#, 0.5)

form_show(frm#)

function OnProgress(sender#) local p
  let p = trackbar_value(trkProg#) / 100
  circletrans_progress#(trans#, p)
  label_text#(lblProg#, "Progress: " + stri$(p, 2))
endfunction

function OnFuzzy(sender#) local f
  let f = trackbar_value(trkFuzzy#) / 100
  circletrans_fuzzy#(trans#, f)
  label_text#(lblFuzzy#, "Fuzzy: " + stri$(f, 2))
endfunction

function OnSize(sender#) local s
  let s = trackbar_value(trkSize#) / 100
  circletrans_circlesize#(trans#, s)
  label_text#(lblSize#, "Size: " + stri$(s, 2))
endfunction
```

## Notes

- Transition effects require a TARGET image to work properly
- Without a target, the effect transitions to transparent
- FuzzyAmount controls edge softness (0=sharp, 1=very soft)
- CircleSize > 1 makes the circle larger, < 1 makes it smaller
- Classic "iris wipe" effect used in old movies and cartoons

## See Also

- DissolveTransitionEffectLib - Pixel dissolve transition
- BlindTransitionEffectLib - Blinds/venetian effect
- FadeTransitionEffectLib - Simple fade transition
