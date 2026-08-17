# RippleEffectLib

Creates a water ripple distortion effect emanating from a center point. Simulates the appearance of ripples on water, with controllable amplitude, frequency, and phase.

## Functions

| Function | Description |
|----------|-------------|
| `ripple#(parent#)` | Creates ripple effect on control |
| `ripple_free(effect#)` | Destroys the effect |
| `ripple_amplitude#(effect#, value)` | Sets wave height |
| `ripple_amplitude(effect#)` | Gets amplitude |
| `ripple_frequency#(effect#, value)` | Sets wave count |
| `ripple_frequency(effect#)` | Gets frequency |
| `ripple_phase#(effect#, value)` | Sets wave phase (for animation) |
| `ripple_phase(effect#)` | Gets phase |
| `ripple_aspectratio#(effect#, value)` | Sets wave aspect ratio |
| `ripple_aspectratio(effect#)` | Gets aspect ratio |
| `ripple_centerx#(effect#, value)` | Sets X center (0-1) |
| `ripple_centerx(effect#)` | Gets X center |
| `ripple_centery#(effect#, value)` | Sets Y center (0-1) |
| `ripple_centery(effect#)` | Gets Y center |
| `ripple_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `ripple_enabled(effect#)` | Gets enabled state |
| `ripple_trigger#(effect#, trigger$)` | Sets trigger string |
| `ripple_trigger$(effect#)` | Gets trigger string |
| `ripple_error()` | Returns last error code |
| `ripple_errormsg$()` | Returns last error message |
| `ripple_strerror$(code)` | Converts error code to text |
| `ripple_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| Amplitude | 0.0+ | 0.1 | Wave height/strength |
| Frequency | 0.0+ | 70 | Number of ripples |
| Phase | 0.0+ | 0 | Wave phase offset (animate this) |
| AspectRatio | 0.0+ | 1.0 | Width/height ratio of ripples |
| CenterX | 0.0 - 1.0 | 0.5 | Horizontal center |
| CenterY | 0.0 - 1.0 | 0.5 | Vertical center |

## Example 1: Basic Ripple Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let ripple# = Pointer#(0)

frm# = form#("Ripple Effect Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Apply ripple effect
ripple# = ripple#(img#)
ripple_amplitude#(ripple#, 0.05)
ripple_frequency#(ripple#, 50)

form_show(frm#)
```

## Example 2: Animated Water Ripple

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let ripple# = Pointer#(0)
let tmr# = Pointer#(0)
let btn# = Pointer#(0)
let phase = 0
let running = 0

frm# = form#("Animated Ripple", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

ripple# = ripple#(img#)
ripple_amplitude#(ripple#, 0.03)
ripple_frequency#(ripple#, 40)

tmr# = timer#()
timer_interval#(tmr#, 30)
timer_enabled#(tmr#, 0)
timer_ontimer#(tmr#, "Animate")

btn# = button#(frm#, "Start Animation")
button_bounds#(btn#, 130, 210, 140, 30)
button_onclick#(btn#, "ToggleAnimation")

form_show(frm#)

function ToggleAnimation(sender#)
  if running = 0 then
    running = 1
    timer_enabled#(tmr#, 1)
    button_text#(btn#, "Stop Animation")
  else
    running = 0
    timer_enabled#(tmr#, 0)
    button_text#(btn#, "Start Animation")
  endif
endfunction

function Animate(sender#)
  phase = phase + 1
  ripple_phase#(ripple#, phase)
endfunction
```

## Example 3: Adjustable Ripple Parameters

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let ripple# = Pointer#(0)
let trkAmp# = Pointer#(0)
let trkFreq# = Pointer#(0)
let lblAmp# = Pointer#(0)
let lblFreq# = Pointer#(0)

frm# = form#("Ripple Control", 500, 450)

img# = image#(frm#)
image_bounds#(img#, 150, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

ripple# = ripple#(img#)
ripple_amplitude#(ripple#, 0.05)
ripple_frequency#(ripple#, 50)

' Amplitude slider
lblAmp# = label#(frm#, "Amplitude: 0.05", 30, 190)
trkAmp# = trackbar#(frm#)
trackbar_bounds#(trkAmp#, 30, 215, 440, 25)
trackbar_max#(trkAmp#, 100)
trackbar_value#(trkAmp#, 5)
trackbar_onchange#(trkAmp#, "OnAmplitude")

' Frequency slider
lblFreq# = label#(frm#, "Frequency: 50", 30, 260)
trkFreq# = trackbar#(frm#)
trackbar_bounds#(trkFreq#, 30, 285, 440, 25)
trackbar_max#(trkFreq#, 100)
trackbar_value#(trkFreq#, 50)
trackbar_onchange#(trkFreq#, "OnFrequency")

form_show(frm#)

function OnAmplitude(sender#) local a
  let a = trackbar_value(trkAmp#) / 100
  ripple_amplitude#(ripple#, a)
  label_text#(lblAmp#, "Amplitude: " + stri$(a, 2))
endfunction

function OnFrequency(sender#) local f
  let f = trackbar_value(trkFreq#)
  ripple_frequency#(ripple#, f)
  label_text#(lblFreq#, "Frequency: " + str$(f))
endfunction
```

## Notes

- Animate the Phase property for moving ripples
- Higher amplitude = more distortion
- Higher frequency = more ripple rings
- Center values are normalized (0-1)
- Great for water reflection effects
- Combine with timer for animated water

## See Also

- RippleTransitionEffectLib - Ripple transition effect
- SwirlEffectLib - Swirl/twist distortion
- WaveTransitionEffectLib - Wave-based transition
