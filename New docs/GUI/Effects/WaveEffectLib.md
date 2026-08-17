# WaveEffectLib

Creates a wave distortion effect on visual controls, simulating a rippling water surface. The Time property allows animation.

## Functions

| Function | Description |
|----------|-------------|
| `wave#(parent#)` | Creates wave effect on control |
| `wave_free(effect#)` | Destroys the effect |
| `wave_wavesize#(effect#, value)` | Sets wave size (32-256) |
| `wave_wavesize(effect#)` | Gets wave size |
| `wave_time#(effect#, value)` | Sets animation time |
| `wave_time(effect#)` | Gets time value |
| `wave_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `wave_enabled(effect#)` | Gets enabled state |
| `wave_trigger#(effect#, trigger$)` | Sets trigger string |
| `wave_trigger$(effect#)` | Gets trigger string |
| `wave_error()` | Returns last error code |
| `wave_errormsg$()` | Returns last error message |
| `wave_strerror$(code)` | Converts error code to text |
| `wave_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| WaveSize | 32 - 256 | 64 | Size of wave distortion |
| Time | 0+ | 0 | Animation phase |

## Wave Size Values

| Value | Effect |
|-------|--------|
| 32-50 | Small, tight waves |
| 64-100 | Medium waves |
| 128-200 | Large, smooth waves |
| 200+ | Very large distortion |

## Example 1: Basic Wave

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let wav# = Pointer#(0)

frm# = form#("Wave Demo", 400, 320)

img# = image#(frm#)
image_bounds#(img#, 100, 40, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

wav# = wave#(img#)
wave_wavesize#(wav#, 80)
wave_time#(wav#, 0)

form_show(frm#)
```

## Example 2: Wave Size Control

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let wav# = Pointer#(0)
let lbl# = Pointer#(0)

frm# = form#("Wave Size Control", 450, 380)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

wav# = wave#(img#)
wave_wavesize#(wav#, 64)

lbl# = label#(frm#, "Wave Size: 64", 165, 200)

let btn1# = button#(frm#, "Small")
button_bounds#(btn1#, 50, 240, 80, 30)
button_onclick#(btn1#, "SetSmall")

let btn2# = button#(frm#, "Medium")
button_bounds#(btn2#, 140, 240, 80, 30)
button_onclick#(btn2#, "SetMedium")

let btn3# = button#(frm#, "Large")
button_bounds#(btn3#, 230, 240, 80, 30)
button_onclick#(btn3#, "SetLarge")

let btn4# = button#(frm#, "Off")
button_bounds#(btn4#, 320, 240, 80, 30)
button_onclick#(btn4#, "SetOff")

form_show(frm#)

function SetSmall(sender#)
  wave_wavesize#(wav#, 40)
  wave_enabled#(wav#, 1)
  label_text#(lbl#, "Wave Size: 40 (Small)")
endfunction

function SetMedium(sender#)
  wave_wavesize#(wav#, 80)
  wave_enabled#(wav#, 1)
  label_text#(lbl#, "Wave Size: 80 (Medium)")
endfunction

function SetLarge(sender#)
  wave_wavesize#(wav#, 150)
  wave_enabled#(wav#, 1)
  label_text#(lbl#, "Wave Size: 150 (Large)")
endfunction

function SetOff(sender#)
  wave_enabled#(wav#, 0)
  label_text#(lbl#, "Wave: Off")
endfunction
```

## Example 3: Animated Wave

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let wav# = Pointer#(0)
let tmr# = Pointer#(0)
let waveTime = 0

frm# = form#("Animated Wave", 400, 340)

img# = image#(frm#)
image_bounds#(img#, 100, 40, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

wav# = wave#(img#)
wave_wavesize#(wav#, 64)

tmr# = timer#()
timer_interval#(tmr#, 50)
timer_ontimer#(tmr#, "OnTimer")

let btn1# = button#(frm#, "Start")
button_bounds#(btn1#, 80, 220, 100, 35)
button_onclick#(btn1#, "StartAnim")

let btn2# = button#(frm#, "Stop")
button_bounds#(btn2#, 200, 220, 100, 35)
button_onclick#(btn2#, "StopAnim")

form_show(frm#)

function OnTimer(sender#)
  waveTime = waveTime + 0.1
  wave_time#(wav#, waveTime)
endfunction

function StartAnim(sender#)
  timer_enabled#(tmr#, 1)
endfunction

function StopAnim(sender#)
  timer_enabled#(tmr#, 0)
endfunction
```

## Notes

- Increment Time property to animate the wave
- Works best on images with varying content
- Use with Timer for smooth animation
- Larger wave size = more distortion

## See Also

- RippleEffectLib - Circular ripple effect
- SwirlEffectLib - Swirl distortion
