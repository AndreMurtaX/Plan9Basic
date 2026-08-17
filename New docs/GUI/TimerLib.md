# TimerLib - Timer Control Library for Plan9Basic

## Overview

TimerLib provides functionality for creating and managing timer controls in Plan9Basic programs. Timers execute callback functions at regular intervals, enabling animations, periodic updates, background tasks, and time-based events.

**Version:** 1.0.0  
**Function Count:** 15 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("Timer Demo", 400, 200)
form_position#(frm#, 4)

let lbl# = label#(frm#, "0")
label_bounds#(lbl#, 150, 50, 100, 40)
label_fontsize#(lbl#, 32)
label_textalign#(lbl#, 0)

let counter = 0

let tmr# = timer#()
timer_interval#(tmr#, 1000)
timer_ontimer#(tmr#, "OnTimer")
timer_start#(tmr#)

form_show(frm#)

function OnTimer(sender#)
  counter = counter + 1
  label_text#(lbl#, str$(counter))
endfunction
```

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `timer_error()` | Returns last error code (0 = no error) |
| `timer_error$()` | Returns last error message |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `timer#()` | Create a new timer (disabled by default) |
| `timer_free#(tmr#)` | Destroy timer |

### Properties

| Function | Description |
|----------|-------------|
| `timer_enabled(tmr#)` | Get enabled state (0=stopped, 1=running) |
| `timer_enabled#(tmr#, value)` | Set enabled state |
| `timer_interval(tmr#)` | Get interval in milliseconds |
| `timer_interval#(tmr#, ms)` | Set interval in milliseconds |
| `timer_tag(tmr#)` | Get tag value |
| `timer_tag#(tmr#, value)` | Set tag value |

### Control

| Function | Description |
|----------|-------------|
| `timer_start#(tmr#)` | Start the timer (same as `timer_enabled#(tmr#, 1)`) |
| `timer_stop#(tmr#)` | Stop the timer (same as `timer_enabled#(tmr#, 0)`) |
| `timer_restart#(tmr#)` | Stop and restart the timer |

### Event Callback

| Function | Description |
|----------|-------------|
| `timer_ontimer#(tmr#, func$)` | Set OnTimer callback function |
| `timer_ontimer$(tmr#)` | Get OnTimer callback function name |

---

## Event Callback Signature

### OnTimer

```basic
function OnTimer(sender#)
  ' Called every time the interval elapses
endfunction
```

The `sender#` parameter is the timer pointer that triggered the event.

---

## Complete Examples

### Simple Countdown Timer

```basic
let frm# = form#("Countdown", 300, 200)
form_position#(frm#, 4)

let timeLeft = 10
let running = 0

let lblTime# = label#(frm#, str$(timeLeft))
label_bounds#(lblTime#, 100, 40, 100, 50)
label_fontsize#(lblTime#, 36)
label_textalign#(lblTime#, 0)

let btnStart# = button#(frm#, "Start", 60, 120, 80, 35)
let btnReset# = button#(frm#, "Reset", 160, 120, 80, 35)

let tmr# = timer#()
timer_interval#(tmr#, 1000)
timer_ontimer#(tmr#, "OnTick")

button_onclick#(btnStart#, "OnStart")
button_onclick#(btnReset#, "OnReset")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnTick(sender#)
  timeLeft = timeLeft - 1
  label_text#(lblTime#, str$(timeLeft))
  
  if timeLeft <= 0 then
    timer_stop#(tmr#)
    label_text#(lblTime#, "Done!")
    running = 0
  endif
endfunction

function OnStart(sender#)
  if running = 0 then
    if timeLeft > 0 then
      running = 1
      timer_start#(tmr#)
    endif
  else
    running = 0
    timer_stop#(tmr#)
  endif
endfunction

function OnReset(sender#)
  timer_stop#(tmr#)
  running = 0
  timeLeft = 10
  label_text#(lblTime#, str$(timeLeft))
endfunction
```

### Digital Clock

```basic
let frm# = form#("Digital Clock", 300, 150)
form_position#(frm#, 4)

let lblClock# = label#(frm#, "")
label_bounds#(lblClock#, 20, 40, 260, 50)
label_fontsize#(lblClock#, 36)
label_fontfamily#(lblClock#, "Consolas")
label_textalign#(lblClock#, 0)

let tmr# = timer#()
timer_interval#(tmr#, 1000)
timer_ontimer#(tmr#, "UpdateClock")
timer_start#(tmr#)

' Initial update
UpdateClock(tmr#)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function UpdateClock(sender#) local t$
  t$ = formatdatetime$("hh:nn:ss", now())
  label_text#(lblClock#, t$)
endfunction
```

### Animation with Timer

```basic
let frm# = form#("Animation", 400, 300)
form_position#(frm#, 4)

let ball# = circle#(frm#, 50, 130, 40, 40)
circle_fillcolor#(ball#, "#FF0000")

let posX = 50
let direction = 1
let speed = 5

let tmr# = timer#()
timer_interval#(tmr#, 16)
timer_ontimer#(tmr#, "Animate")
timer_start#(tmr#)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function Animate(sender#)
  posX = posX + (speed * direction)
  
  ' Bounce at edges
  if posX >= 350 then
    direction = -1
  else if posX <= 10 then
    direction = 1
  endif
  
  circle_x#(ball#, posX)
endfunction
```

### Stopwatch

```basic
let frm# = form#("Stopwatch", 350, 200)
form_position#(frm#, 4)

let elapsed = 0
let running = 0

let lblTime# = label#(frm#, "00:00.0")
label_bounds#(lblTime#, 75, 30, 200, 50)
label_fontsize#(lblTime#, 36)
label_fontfamily#(lblTime#, "Consolas")
label_textalign#(lblTime#, 0)

let btnStartStop# = button#(frm#, "Start", 50, 110, 80, 35)
let btnReset# = button#(frm#, "Reset", 140, 110, 80, 35)
let btnLap# = button#(frm#, "Lap", 230, 110, 80, 35)

let tmr# = timer#()
timer_interval#(tmr#, 100)
timer_ontimer#(tmr#, "OnTick")

button_onclick#(btnStartStop#, "OnStartStop")
button_onclick#(btnReset#, "OnReset")
button_onclick#(btnLap#, "OnLap")

form_show(frm#)

function FormatTime$(ms) local mins, secs, tenths
  mins = int(ms / 60000)
  secs = int((ms mod 60000) / 1000)
  tenths = int((ms mod 1000) / 100)
  return right$("0" + str$(mins), 2) + ":" + right$("0" + str$(secs), 2) + "." + str$(tenths)
endfunction

function OnTick(sender#)
  elapsed = elapsed + 100
  label_text#(lblTime#, FormatTime$(elapsed))
endfunction

function OnStartStop(sender#)
  if running = 0 then
    running = 1
    timer_start#(tmr#)
    button_text#(btnStartStop#, "Stop")
  else
    running = 0
    timer_stop#(tmr#)
    button_text#(btnStartStop#, "Start")
  endif
endfunction

function OnReset(sender#)
  timer_stop#(tmr#)
  running = 0
  elapsed = 0
  label_text#(lblTime#, "00:00.0")
  button_text#(btnStartStop#, "Start")
endfunction

function OnLap(sender#)
  if running = 1 then
    println "Lap: " + FormatTime$(elapsed)
  endif
endfunction
```

### Multiple Timers

```basic
let frm# = form#("Multiple Timers", 400, 250)
form_position#(frm#, 4)

let counter1 = 0
let counter2 = 0

let lbl1# = label#(frm#, "Timer 1: 0")
label_bounds#(lbl1#, 50, 30, 150, 30)

let lbl2# = label#(frm#, "Timer 2: 0")
label_bounds#(lbl2#, 50, 70, 150, 30)

' Fast timer (100ms)
let tmr1# = timer#()
timer_interval#(tmr1#, 100)
timer_tag#(tmr1#, 1)
timer_ontimer#(tmr1#, "OnTimer")

' Slow timer (500ms)
let tmr2# = timer#()
timer_interval#(tmr2#, 500)
timer_tag#(tmr2#, 2)
timer_ontimer#(tmr2#, "OnTimer")

let btnStart# = button#(frm#, "Start All", 50, 130, 100, 35)
let btnStop# = button#(frm#, "Stop All", 160, 130, 100, 35)

button_onclick#(btnStart#, "OnStart")
button_onclick#(btnStop#, "OnStop")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnTimer(sender#) local tag
  tag = timer_tag(sender#)
  
  if tag = 1 then
    counter1 = counter1 + 1
    label_text#(lbl1#, "Timer 1: " + str$(counter1))
  else if tag = 2 then
    counter2 = counter2 + 1
    label_text#(lbl2#, "Timer 2: " + str$(counter2))
  endif
endfunction

function OnStart(sender#)
  timer_start#(tmr1#)
  timer_start#(tmr2#)
endfunction

function OnStop(sender#)
  timer_stop#(tmr1#)
  timer_stop#(tmr2#)
endfunction
```

### Auto-Save Feature

```basic
let frm# = form#("Auto-Save Demo", 400, 300)
form_position#(frm#, 4)

let mem# = memo#(frm#, 10, 10, 380, 220)
memo_text#(mem#, "Type something here...")

let lblStatus# = label#(frm#, "Auto-save: Waiting...")
label_bounds#(lblStatus#, 10, 240, 200, 25)

let dirty = 0

' Auto-save timer (5 seconds)
let tmrSave# = timer#()
timer_interval#(tmrSave#, 5000)
timer_ontimer#(tmrSave#, "OnAutoSave")
timer_start#(tmrSave#)

memo_onchangetracking#(mem#, "OnTextChange")

form_show(frm#)

function OnTextChange(sender#)
  dirty = 1
  label_text#(lblStatus#, "Auto-save: Modified...")
endfunction

function OnAutoSave(sender#)
  if dirty = 1 then
    ' Simulate save operation
    label_text#(lblStatus#, "Auto-save: Saving...")
    processmessages()
    
    ' In real app, save to file here
    println "Auto-saved at " + formatdatetime$("hh:nn:ss", now())
    
    dirty = 0
    label_text#(lblStatus#, "Auto-save: Saved!")
  else
    label_text#(lblStatus#, "Auto-save: No changes")
  endif
endfunction
```

---

## Tips and Best Practices

1. **Start with timer disabled** - Timers are disabled by default; call `timer_start#` to begin
2. **Use appropriate intervals** - 16ms for 60fps animation, 100-1000ms for UI updates
3. **Stop timers when not needed** - Reduce CPU usage by stopping inactive timers
4. **Use restart for resetting** - `timer_restart#` stops and restarts cleanly
5. **Use tag for identification** - Set tag to distinguish between multiple timers in shared callbacks
6. **Keep callbacks fast** - Long-running timer callbacks can freeze the UI
7. **Clean up timers** - Call `timer_free#` when done with a timer

---

## See Also

- **FormLib** - Form management
- **LabelLib** - For displaying timer output
- **ProgressBarLib** - Progress indication

---

*TimerLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
