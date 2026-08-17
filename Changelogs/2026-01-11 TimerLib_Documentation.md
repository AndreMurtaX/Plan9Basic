# TimerLib - Plan9Basic Timer Control Library

## Overview

TimerLib allows Plan9Basic programs to create timers that fire events at specified intervals. Timers are essential for animations, periodic updates, background tasks, and any time-based functionality in GUI applications.

**Version:** 1.0.0  
**Function Count:** 15 functions  

## Quick Start

```basic
' Create a timer that fires every second
let tmr# = timer#()
timer_interval#(tmr#, 1000)     ' 1000ms = 1 second
timer_ontimer#(tmr#, "OnTick")
timer_enabled#(tmr#, 1)         ' Start the timer

function OnTick(sender#)
  println "Timer fired!"
endfunction
```

## Important Notes

- **Interval is in milliseconds**: 1000 = 1 second, 500 = half second, 50 = 50ms
- **Timer starts disabled**: You must call `timer_enabled#(tmr#, 1)` or `timer_start#(tmr#)` to start it
- **Timer continues firing**: Until you disable it or free it
- **Minimum practical interval**: ~10-15ms depending on system load

## Function Reference

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `timer#()` | Creates a new timer (starts disabled, 1000ms default interval) |
| `timer_free#(tmr#)` | Destroys the timer and releases resources |

### Enabled Property

| Function | Description |
|----------|-------------|
| `timer_enabled(tmr#)` | Gets whether timer is running (0=stopped, 1=running) |
| `timer_enabled#(tmr#, enabled)` | Sets whether timer is running |

### Interval Property

| Function | Description |
|----------|-------------|
| `timer_interval(tmr#)` | Gets the interval in milliseconds |
| `timer_interval#(tmr#, ms)` | Sets the interval in milliseconds (minimum 1) |

### Convenience Functions

| Function | Description |
|----------|-------------|
| `timer_start#(tmr#)` | Starts the timer (same as `timer_enabled#(tmr#, 1)`) |
| `timer_stop#(tmr#)` | Stops the timer (same as `timer_enabled#(tmr#, 0)`) |
| `timer_restart#(tmr#)` | Restarts timer (resets the interval countdown) |

### Tag Property

| Function | Description |
|----------|-------------|
| `timer_tag(tmr#)` | Gets numeric tag value (for user data) |
| `timer_tag#(tmr#, value)` | Sets numeric tag value |

### Event Callback

| Function | Description |
|----------|-------------|
| `timer_ontimer#(tmr#, funcName$)` | Sets the OnTimer callback function |
| `timer_ontimer$(tmr#)` | Gets the OnTimer callback function name |

### Error Handling

| Function | Description |
|----------|-------------|
| `timer_error()` | Returns the last error code |
| `timer_error$()` | Returns the last error message |

### Callback Signature

```basic
' OnTimer callback - fires when interval elapses
function OnTick(sender#)
  ' sender# is the timer that fired
  println "Timer event!"
endfunction
```

## Error Codes

| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Invalid timer pointer |
| 2 | Invalid value (e.g., interval < 1) |
| 3 | Timer creation failed |

## Complete Examples

### Example 1: Download Progress Simulation

```basic
' Simulate a file download with progress bar
let frm# = form#("Download Progress", 450, 180)

let lblStatus# = label#(frm#)
label_move#(lblStatus#, 20, 20)
label_size#(lblStatus#, 410, 25)
label_text#(lblStatus#, "Click Start to begin download")

let pb# = progressbar#(frm#)
progressbar_move#(pb#, 20, 55)
progressbar_size#(pb#, 410, 30)
progressbar_min#(pb#, 0)
progressbar_max#(pb#, 100)
progressbar_value#(pb#, 0)

let lblPercent# = label#(frm#)
label_move#(lblPercent#, 20, 95)
label_size#(lblPercent#, 100, 25)
label_text#(lblPercent#, "0%")

let btnStart# = button#(frm#)
button_move#(btnStart#, 170, 120)
button_size#(btnStart#, 110, 35)
button_text#(btnStart#, "Start Download")
button_onclick#(btnStart#, "StartDownload")

let progress = 0

' Create a timer for the download simulation
let tmr# = timer#()
timer_interval#(tmr#, 50)       ' 50ms intervals for smooth animation
timer_ontimer#(tmr#, "OnTimer")
' Timer starts disabled

form_show(frm#)

function StartDownload(sender#)
  progress = 0
  progressbar_value#(pb#, 0)
  label_text#(lblPercent#, "0%")
  button_enabled#(btnStart#, 0)
  label_text#(lblStatus#, "Downloading file...")
  timer_start#(tmr#)            ' Start the timer
endfunction

function OnTimer(sender#)
  progress = progress + 1
  progressbar_value#(pb#, progress)
  label_text#(lblPercent#, str$(progress) + "%")
  
  if progress >= 100 then
    timer_stop#(tmr#)           ' Stop the timer
    button_enabled#(btnStart#, 1)
    label_text#(lblStatus#, "Download complete!")
  endif
endfunction
```

### Example 2: Digital Clock

```basic
' Simple digital clock display
let frm# = form#("Digital Clock", 300, 150)

let lblTime# = label#(frm#)
label_move#(lblTime#, 20, 40)
label_size#(lblTime#, 260, 60)
label_text#(lblTime#, time$())

' Create timer to update every second
let tmr# = timer#()
timer_interval#(tmr#, 1000)
timer_ontimer#(tmr#, "UpdateClock")
timer_start#(tmr#)

form_show(frm#)

function UpdateClock(sender#)
  label_text#(lblTime#, time$())
endfunction
```

### Example 3: Countdown Timer

```basic
' Countdown timer with start/stop controls
let frm# = form#("Countdown Timer", 350, 200)

let lblSeconds# = label#(frm#)
label_move#(lblSeconds#, 100, 30)
label_size#(lblSeconds#, 150, 50)
label_text#(lblSeconds#, "60")

let tbSeconds# = trackbar#(frm#)
trackbar_move#(tbSeconds#, 25, 90)
trackbar_size#(tbSeconds#, 300, 45)
trackbar_min#(tbSeconds#, 1)
trackbar_max#(tbSeconds#, 120)
trackbar_value#(tbSeconds#, 60)
trackbar_onchange#(tbSeconds#, "OnSliderChange")

let btnStart# = button#(frm#)
button_move#(btnStart#, 70, 150)
button_size#(btnStart#, 100, 35)
button_text#(btnStart#, "Start")
button_onclick#(btnStart#, "StartCountdown")

let btnStop# = button#(frm#)
button_move#(btnStop#, 180, 150)
button_size#(btnStop#, 100, 35)
button_text#(btnStop#, "Reset")
button_onclick#(btnStop#, "ResetCountdown")

let remaining = 60
let counting = 0

let tmr# = timer#()
timer_interval#(tmr#, 1000)
timer_ontimer#(tmr#, "OnCountdown")

form_show(frm#)

function OnSliderChange(sender#)
  if counting = 0 then
    remaining = trackbar_value(tbSeconds#)
    label_text#(lblSeconds#, str$(remaining))
  endif
endfunction

function StartCountdown(sender#)
  if counting = 0 then
    counting = 1
    trackbar_enabled#(tbSeconds#, 0)
    button_text#(btnStart#, "Pause")
    timer_start#(tmr#)
  else
    counting = 0
    button_text#(btnStart#, "Resume")
    timer_stop#(tmr#)
  endif
endfunction

function ResetCountdown(sender#)
  counting = 0
  timer_stop#(tmr#)
  remaining = trackbar_value(tbSeconds#)
  label_text#(lblSeconds#, str$(remaining))
  trackbar_enabled#(tbSeconds#, 1)
  button_text#(btnStart#, "Start")
endfunction

function OnCountdown(sender#)
  remaining = remaining - 1
  label_text#(lblSeconds#, str$(remaining))
  
  if remaining <= 0 then
    timer_stop#(tmr#)
    counting = 0
    trackbar_enabled#(tbSeconds#, 1)
    button_text#(btnStart#, "Start")
    label_text#(lblSeconds#, "Done!")
  endif
endfunction
```

### Example 4: Animation (Moving Object)

```basic
' Simple animation - bouncing ball
let frm# = form#("Bouncing Ball", 400, 300)

let ball# = circle#(frm#)
circle_move#(ball#, 50, 50)
circle_size#(ball#, 30, 30)

let ballX = 50
let ballY = 50
let speedX = 5
let speedY = 3

let tmr# = timer#()
timer_interval#(tmr#, 16)       ' ~60 FPS (1000/60 ≈ 16ms)
timer_ontimer#(tmr#, "Animate")
timer_start#(tmr#)

form_show(frm#)

function Animate(sender#)
  ' Update position
  ballX = ballX + speedX
  ballY = ballY + speedY
  
  ' Bounce off walls
  if ballX <= 0 then
    ballX = 0
    speedX = 0 - speedX
  endif
  if ballX >= 370 then
    ballX = 370
    speedX = 0 - speedX
  endif
  if ballY <= 0 then
    ballY = 0
    speedY = 0 - speedY
  endif
  if ballY >= 270 then
    ballY = 270
    speedY = 0 - speedY
  endif
  
  ' Move the ball
  circle_move#(ball#, ballX, ballY)
endfunction
```

### Example 5: Multiple Timers

```basic
' Using multiple timers for different tasks
let frm# = form#("Multi-Timer Demo", 400, 250)

let lblFast# = label#(frm#)
label_move#(lblFast#, 20, 30)
label_text#(lblFast#, "Fast (100ms): 0")

let lblMedium# = label#(frm#)
label_move#(lblMedium#, 20, 70)
label_text#(lblMedium#, "Medium (500ms): 0")

let lblSlow# = label#(frm#)
label_move#(lblSlow#, 20, 110)
label_text#(lblSlow#, "Slow (2000ms): 0")

let countFast = 0
let countMedium = 0
let countSlow = 0

' Fast timer - 100ms
let tmrFast# = timer#()
timer_interval#(tmrFast#, 100)
timer_tag#(tmrFast#, 1)
timer_ontimer#(tmrFast#, "OnFastTimer")
timer_start#(tmrFast#)

' Medium timer - 500ms
let tmrMedium# = timer#()
timer_interval#(tmrMedium#, 500)
timer_tag#(tmrMedium#, 2)
timer_ontimer#(tmrMedium#, "OnMediumTimer")
timer_start#(tmrMedium#)

' Slow timer - 2 seconds
let tmrSlow# = timer#()
timer_interval#(tmrSlow#, 2000)
timer_tag#(tmrSlow#, 3)
timer_ontimer#(tmrSlow#, "OnSlowTimer")
timer_start#(tmrSlow#)

let btnToggle# = button#(frm#)
button_move#(btnToggle#, 150, 180)
button_size#(btnToggle#, 100, 35)
button_text#(btnToggle#, "Pause All")
button_onclick#(btnToggle#, "ToggleTimers")

let paused = 0

form_show(frm#)

function OnFastTimer(sender#)
  countFast = countFast + 1
  label_text#(lblFast#, "Fast (100ms): " + str$(countFast))
endfunction

function OnMediumTimer(sender#)
  countMedium = countMedium + 1
  label_text#(lblMedium#, "Medium (500ms): " + str$(countMedium))
endfunction

function OnSlowTimer(sender#)
  countSlow = countSlow + 1
  label_text#(lblSlow#, "Slow (2000ms): " + str$(countSlow))
endfunction

function ToggleTimers(sender#)
  if paused = 0 then
    paused = 1
    timer_stop#(tmrFast#)
    timer_stop#(tmrMedium#)
    timer_stop#(tmrSlow#)
    button_text#(btnToggle#, "Resume All")
  else
    paused = 0
    timer_start#(tmrFast#)
    timer_start#(tmrMedium#)
    timer_start#(tmrSlow#)
    button_text#(btnToggle#, "Pause All")
  endif
endfunction
```

## Common Interval Values

| Interval | Milliseconds | Use Case |
|----------|--------------|----------|
| ~60 FPS | 16 | Smooth animations |
| ~30 FPS | 33 | Standard animations |
| 10x/sec | 100 | Fast updates |
| 2x/sec | 500 | Medium updates |
| 1x/sec | 1000 | Clock displays, counters |
| 1x/min | 60000 | Infrequent updates |

## Best Practices

1. **Always stop timers when done**: Call `timer_stop#()` or `timer_free#()` when the timer is no longer needed
2. **Use appropriate intervals**: Don't use very small intervals (< 16ms) unless necessary
3. **Keep callbacks fast**: Timer callbacks should execute quickly to avoid blocking
4. **Clean up on form close**: Stop and free timers when closing forms

## See Also

- ProgressBarLib - For displaying progress
- TrackBarLib - For user input sliders
- FormLib - For creating windows
