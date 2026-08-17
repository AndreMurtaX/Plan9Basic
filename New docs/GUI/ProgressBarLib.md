# ProgressBarLib - Progress Bar Control Library for Plan9Basic

## Overview

ProgressBarLib provides functionality for creating and managing progress bar controls in Plan9Basic programs. Progress bars display task completion status, download progress, or any value within a range.

**Version:** 1.0.0  
**Function Count:** 75+ functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("Progress Demo", 400, 200)
form_position#(frm#, 4)

let pb# = progressbar#(frm#, 50, 50, 300, 25)
progressbar_min#(pb#, 0)
progressbar_max#(pb#, 100)
progressbar_value#(pb#, 0)

let btnStart# = button#(frm#, "Start", 150, 100, 100, 35)
button_onclick#(btnStart#, "OnStart")

let tmr# = timer#()
timer_interval#(tmr#, 50)
timer_ontimer#(tmr#, "OnTimer")

form_show(frm#)

function OnStart(sender#)
  progressbar_value#(pb#, 0)
  timer_start#(tmr#)
endfunction

function OnTimer(sender#) local val
  val = progressbar_value(pb#)
  if val >= 100 then
    timer_stop#(tmr#)
    println "Complete!"
  else
    progressbar_value#(pb#, val + 1)
  endif
endfunction
```

## Numeric Values Reference

### Alignment Values

| Value | Description |
|-------|-------------|
| 0 | None (absolute positioning) |
| 1 | Top |
| 2 | Left |
| 3 | Right |
| 4 | Bottom |
| 9 | Client (fill parent) |

### Orientation Values

| Value | Description |
|-------|-------------|
| 0 | Horizontal |
| 1 | Vertical |

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `progressbar_error()` | Returns last error code (0 = no error) |
| `progressbar_errormsg$()` | Returns last error message |
| `progressbar_strerror$(code)` | Converts error code to message |
| `progressbar_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `progressbar#(parent#)` | Create with default size |
| `progressbar#(parent#, x, y, w, h)` | Create with position and size |
| `progressbar_free(pb#)` | Destroy progress bar |

### Value Properties

| Function | Description |
|----------|-------------|
| `progressbar_value(pb#)` | Get current value |
| `progressbar_value#(pb#, value)` | Set current value |
| `progressbar_min(pb#)` | Get minimum value |
| `progressbar_min#(pb#, value)` | Set minimum value |
| `progressbar_max(pb#)` | Get maximum value |
| `progressbar_max#(pb#, value)` | Set maximum value |

### Orientation

| Function | Description |
|----------|-------------|
| `progressbar_orientation(pb#)` | Get orientation (0=horizontal, 1=vertical) |
| `progressbar_orientation#(pb#, value)` | Set orientation |

### Position and Size

| Function | Description |
|----------|-------------|
| `progressbar_x(pb#)` / `progressbar_x#(pb#, x)` | Get/set X position |
| `progressbar_y(pb#)` / `progressbar_y#(pb#, y)` | Get/set Y position |
| `progressbar_width(pb#)` / `progressbar_width#(pb#, w)` | Get/set width |
| `progressbar_height(pb#)` / `progressbar_height#(pb#, h)` | Get/set height |
| `progressbar_bounds#(pb#, x, y, w, h)` | Set position and size |
| `progressbar_move#(pb#, x, y)` | Set position only |
| `progressbar_size#(pb#, w, h)` | Set size only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `progressbar_align(pb#)` / `progressbar_align#(pb#, value)` | Get/set alignment |
| `progressbar_marginleft(pb#)` / `progressbar_marginleft#(pb#, value)` | Get/set left margin |
| `progressbar_margintop(pb#)` / `progressbar_margintop#(pb#, value)` | Get/set top margin |
| `progressbar_marginright(pb#)` / `progressbar_marginright#(pb#, value)` | Get/set right margin |
| `progressbar_marginbottom(pb#)` / `progressbar_marginbottom#(pb#, value)` | Get/set bottom margin |
| `progressbar_margins#(pb#, l, t, r, b)` | Set all margins |
| `progressbar_margin#(pb#, value)` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `progressbar_visible(pb#)` / `progressbar_visible#(pb#, value)` | Get/set visibility (0/1) |
| `progressbar_enabled(pb#)` / `progressbar_enabled#(pb#, value)` | Get/set enabled state (0/1) |
| `progressbar_opacity(pb#)` / `progressbar_opacity#(pb#, value)` | Get/set opacity (0.0-1.0) |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `progressbar_tag(pb#)` / `progressbar_tag#(pb#, value)` | Get/set tag value |
| `progressbar_parent#(pb#)` | Get parent |
| `progressbar_parent#(pb#, parent#)` | Set parent |
| `progressbar_bringtofront#(pb#)` | Bring to front |
| `progressbar_sendtoback#(pb#)` | Send to back |

### Hit Testing and Drag

| Function | Description |
|----------|-------------|
| `progressbar_hittest(pb#)` / `progressbar_hittest#(pb#, value)` | Get/set hit test (0/1) |
| `progressbar_dragmode(pb#)` / `progressbar_dragmode#(pb#, value)` | Get/set drag mode |

---

## Event Callbacks

### Mouse Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `progressbar_onclick#(pb#, func$)` | `progressbar_onclick$(pb#)` | `function(sender#)` |
| OnDblClick | `progressbar_ondblclick#(pb#, func$)` | `progressbar_ondblclick$(pb#)` | `function(sender#)` |
| OnMouseDown | `progressbar_onmousedown#(pb#, func$)` | `progressbar_onmousedown$(pb#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `progressbar_onmouseup#(pb#, func$)` | `progressbar_onmouseup$(pb#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `progressbar_onmousemove#(pb#, func$)` | `progressbar_onmousemove$(pb#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `progressbar_onmouseenter#(pb#, func$)` | `progressbar_onmouseenter$(pb#)` | `function(sender#)` |
| OnMouseLeave | `progressbar_onmouseleave#(pb#, func$)` | `progressbar_onmouseleave$(pb#)` | `function(sender#)` |
| OnResize | `progressbar_onresize#(pb#, func$)` | `progressbar_onresize$(pb#)` | `function(sender#)` |

### Drag Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnDragEnter | `progressbar_ondragenter#(pb#, func$)` | `progressbar_ondragenter$(pb#)` | `function(sender#, x, y)` |
| OnDragOver | `progressbar_ondragover#(pb#, func$)` | `progressbar_ondragover$(pb#)` | `function(sender#, x, y)` |
| OnDragDrop | `progressbar_ondragdrop#(pb#, func$)` | `progressbar_ondragdrop$(pb#)` | `function(sender#, x, y)` |
| OnDragLeave | `progressbar_ondragleave#(pb#, func$)` | `progressbar_ondragleave$(pb#)` | `function(sender#)` |

### Utility

| Function | Description |
|----------|-------------|
| `progressbar_clearcallbacks#(pb#)` | Disconnect all event callbacks |



---

## Complete Examples

### File Download Simulation

```basic
let frm# = form#("Download Progress", 450, 180)
form_position#(frm#, 4)

let lblFile# = label#(frm#, "Downloading: large_file.zip")
label_move#(lblFile#, 20, 20)

let pb# = progressbar#(frm#, 20, 50, 410, 25)
progressbar_min#(pb#, 0)
progressbar_max#(pb#, 100)

let lblPercent# = label#(frm#, "0%")
label_move#(lblPercent#, 200, 85)

let btnDownload# = button#(frm#, "Start Download", 160, 120, 130, 35)
button_onclick#(btnDownload#, "OnDownload")

let tmr# = timer#()
timer_interval#(tmr#, 100)
timer_ontimer#(tmr#, "OnProgress")

form_show(frm#)

function OnDownload(sender#)
  progressbar_value#(pb#, 0)
  button_enabled#(btnDownload#, 0)
  timer_start#(tmr#)
endfunction

function OnProgress(sender#) local val, pct$
  val = progressbar_value(pb#) + rnd(5) + 1
  if val > 100 then val = 100
  
  progressbar_value#(pb#, val)
  pct$ = str$(int(val)) + "%"
  label_text#(lblPercent#, pct$)
  
  if val >= 100 then
    timer_stop#(tmr#)
    label_text#(lblFile#, "Download complete!")
    button_enabled#(btnDownload#, 1)
  endif
endfunction
```

### Multi-Step Process

```basic
let frm# = form#("Installation", 400, 200)
form_position#(frm#, 4)

let lblStep# = label#(frm#, "Ready to install")
label_move#(lblStep#, 20, 20)

let pb# = progressbar#(frm#, 20, 55, 360, 20)
progressbar_max#(pb#, 4)

let btnInstall# = button#(frm#, "Install", 150, 100, 100, 35)
button_onclick#(btnInstall#, "OnInstall")

form_show(frm#)

function OnInstall(sender#)
  button_enabled#(btnInstall#, 0)
  
  ' Step 1
  label_text#(lblStep#, "Step 1: Copying files...")
  progressbar_value#(pb#, 1)
  pause(1)
  
  ' Step 2
  label_text#(lblStep#, "Step 2: Configuring...")
  progressbar_value#(pb#, 2)
  pause(1)
  
  ' Step 3
  label_text#(lblStep#, "Step 3: Installing components...")
  progressbar_value#(pb#, 3)
  pause(1)
  
  ' Step 4
  label_text#(lblStep#, "Step 4: Finalizing...")
  progressbar_value#(pb#, 4)
  pause(1)
  
  label_text#(lblStep#, "Installation complete!")
  button_text#(btnInstall#, "Close")
  button_enabled#(btnInstall#, 1)
endfunction
```

### Vertical Progress Bars

```basic
let frm# = form#("Levels", 300, 250)
form_position#(frm#, 4)

' Create vertical progress bars
let pb1# = progressbar#(frm#, 50, 30, 30, 150)
progressbar_orientation#(pb1#, 1)
progressbar_max#(pb1#, 100)
progressbar_value#(pb1#, 75)

let pb2# = progressbar#(frm#, 120, 30, 30, 150)
progressbar_orientation#(pb2#, 1)
progressbar_max#(pb2#, 100)
progressbar_value#(pb2#, 50)

let pb3# = progressbar#(frm#, 190, 30, 30, 150)
progressbar_orientation#(pb3#, 1)
progressbar_max#(pb3#, 100)
progressbar_value#(pb3#, 25)

' Labels
let lbl1# = label#(frm#, "CPU")
label_move#(lbl1#, 50, 190)

let lbl2# = label#(frm#, "MEM")
label_move#(lbl2#, 117, 190)

let lbl3# = label#(frm#, "DISK")
label_move#(lbl3#, 183, 190)

form_show(frm#)
```

### Progress with Percentage Display

```basic
let frm# = form#("Task Progress", 400, 150)
form_position#(frm#, 4)

let pb# = progressbar#(frm#, 20, 30, 360, 25)
progressbar_max#(pb#, 100)

let lblPct# = label#(frm#, "0%")
label_bounds#(lblPct#, 180, 65, 40, 20)
label_textalign#(lblPct#, 0)

let btnRun# = button#(frm#, "Run Task", 150, 95, 100, 35)
button_onclick#(btnRun#, "OnRun")

let tmr# = timer#()
timer_interval#(tmr#, 30)
timer_ontimer#(tmr#, "OnTick")

form_show(frm#)

function OnRun(sender#)
  progressbar_value#(pb#, 0)
  timer_start#(tmr#)
endfunction

function OnTick(sender#) local val
  val = progressbar_value(pb#) + 1
  progressbar_value#(pb#, val)
  label_text#(lblPct#, str$(val) + "%")
  
  if val >= 100 then
    timer_stop#(tmr#)
  endif
endfunction
```

---

## Tips and Best Practices

1. **Set min and max first** - Always set the range before setting values
2. **Use timers for animation** - Don't block UI with loops; use timer events
3. **Vertical orientation for levels** - Use `progressbar_orientation#(pb#, 1)` for vertical bars
4. **Show percentage** - Pair progress bars with labels showing numeric progress
5. **Disable buttons during processing** - Prevent multiple clicks while task runs
6. **Use appropriate intervals** - 30-100ms timer intervals for smooth animation

---

## See Also

- **TimerLib** - Timer controls for animations
- **LabelLib** - Labels for progress text
- **ButtonLib** - Buttons to start/stop tasks

---

*ProgressBarLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
