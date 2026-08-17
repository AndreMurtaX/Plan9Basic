# ProgressBarLib - Plan9Basic Progress Bar Control Library

## Overview

ProgressBarLib allows Plan9Basic programs to create and manage progress bar controls for displaying task progress, loading indicators, and value visualization.

**Version:** 1.0.0  
**Function Count:** 70+ functions  

## Quick Start

```basic
' Create a simple progress bar
let frm# = form#("Progress Demo", 400, 200)

let pb# = progressbar#(frm#)
progressbar_move#(pb#, 50, 80)
progressbar_size#(pb#, 300, 25)
progressbar_min#(pb#, 0)
progressbar_max#(pb#, 100)
progressbar_value#(pb#, 0)

form_show(frm#)
```

## Function Reference

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `progressbar#(parent#)` | Creates a new progress bar on the specified parent control |
| `progressbar_free#(pb#)` | Destroys the progress bar and releases resources |

### Value and Range Properties

| Function | Description |
|----------|-------------|
| `progressbar_value(pb#)` | Gets the current value |
| `progressbar_value#(pb#, value)` | Sets the current value |
| `progressbar_min(pb#)` | Gets the minimum value |
| `progressbar_min#(pb#, value)` | Sets the minimum value (default: 0) |
| `progressbar_max(pb#)` | Gets the maximum value |
| `progressbar_max#(pb#, value)` | Sets the maximum value (default: 100) |

### Orientation

| Function | Description |
|----------|-------------|
| `progressbar_orientation(pb#)` | Gets orientation (0=horizontal, 1=vertical) |
| `progressbar_orientation#(pb#, orient)` | Sets orientation |

**Orientation Values:**
- `0` = Horizontal (default)
- `1` = Vertical

### Position and Size

| Function | Description |
|----------|-------------|
| `progressbar_left(pb#)` | Gets X position |
| `progressbar_left#(pb#, x)` | Sets X position |
| `progressbar_top(pb#)` | Gets Y position |
| `progressbar_top#(pb#, y)` | Sets Y position |
| `progressbar_width(pb#)` | Gets width |
| `progressbar_width#(pb#, w)` | Sets width |
| `progressbar_height(pb#)` | Gets height |
| `progressbar_height#(pb#, h)` | Sets height |
| `progressbar_move#(pb#, x, y)` | Sets position (X, Y) |
| `progressbar_size#(pb#, w, h)` | Sets size (width, height) |
| `progressbar_bounds#(pb#, x, y, w, h)` | Sets position and size at once |

### Alignment

| Function | Description |
|----------|-------------|
| `progressbar_align(pb#)` | Gets alignment mode |
| `progressbar_align#(pb#, align)` | Sets alignment mode |

**Alignment Values:**
- `0` = None (manual positioning)
- `1` = Top (fill top edge)
- `2` = Left (fill left edge)
- `3` = Right (fill right edge)
- `4` = Bottom (fill bottom edge)
- `5` = Client (fill entire parent)
- `6` = Contents (fit to content)
- `7` = Center (center in parent)
- `8` = Horizontal (center horizontally)
- `9` = Vertical (center vertically)
- `10` = Fit Left (proportional left)
- `11` = Fit Right (proportional right)

### Margins

| Function | Description |
|----------|-------------|
| `progressbar_marginleft(pb#)` | Gets left margin |
| `progressbar_marginleft#(pb#, m)` | Sets left margin |
| `progressbar_margintop(pb#)` | Gets top margin |
| `progressbar_margintop#(pb#, m)` | Sets top margin |
| `progressbar_marginright(pb#)` | Gets right margin |
| `progressbar_marginright#(pb#, m)` | Sets right margin |
| `progressbar_marginbottom(pb#)` | Gets bottom margin |
| `progressbar_marginbottom#(pb#, m)` | Sets bottom margin |
| `progressbar_margins#(pb#, l, t, r, b)` | Sets all margins at once |

### Padding

| Function | Description |
|----------|-------------|
| `progressbar_paddingleft(pb#)` | Gets left padding |
| `progressbar_paddingleft#(pb#, p)` | Sets left padding |
| `progressbar_paddingtop(pb#)` | Gets top padding |
| `progressbar_paddingtop#(pb#, p)` | Sets top padding |
| `progressbar_paddingright(pb#)` | Gets right padding |
| `progressbar_paddingright#(pb#, p)` | Sets right padding |
| `progressbar_paddingbottom(pb#)` | Gets bottom padding |
| `progressbar_paddingbottom#(pb#, p)` | Sets bottom padding |
| `progressbar_padding#(pb#, l, t, r, b)` | Sets all padding at once |

### Visibility and State

| Function | Description |
|----------|-------------|
| `progressbar_visible(pb#)` | Gets visibility (0/1) |
| `progressbar_visible#(pb#, vis)` | Sets visibility |
| `progressbar_enabled(pb#)` | Gets enabled state (0/1) |
| `progressbar_enabled#(pb#, en)` | Sets enabled state |
| `progressbar_opacity(pb#)` | Gets opacity (0.0-1.0) |
| `progressbar_opacity#(pb#, op)` | Sets opacity |

### Z-Order and Parent

| Function | Description |
|----------|-------------|
| `progressbar_bringtofront#(pb#)` | Brings to front of z-order |
| `progressbar_sendtoback#(pb#)` | Sends to back of z-order |
| `progressbar_parent#(pb#)` | Gets current parent control |
| `progressbar_parent#(pb#, newParent#)` | Sets new parent control |

### Rotation and Scaling

| Function | Description |
|----------|-------------|
| `progressbar_rotationangle(pb#)` | Gets rotation in degrees |
| `progressbar_rotationangle#(pb#, angle)` | Sets rotation angle |
| `progressbar_scalex(pb#)` | Gets horizontal scale factor |
| `progressbar_scalex#(pb#, sx)` | Sets horizontal scale |
| `progressbar_scaley(pb#)` | Gets vertical scale factor |
| `progressbar_scaley#(pb#, sy)` | Sets vertical scale |
| `progressbar_scale#(pb#, sx, sy)` | Sets both scale factors |

### Tag Property

| Function | Description |
|----------|-------------|
| `progressbar_tag(pb#)` | Gets numeric tag value |
| `progressbar_tag#(pb#, tagValue)` | Sets numeric tag value |

### Hit Testing and Drag

| Function | Description |
|----------|-------------|
| `progressbar_hittest(pb#)` | Gets hit test state (0/1) |
| `progressbar_hittest#(pb#, ht)` | Sets hit test state |
| `progressbar_dragmode(pb#)` | Gets drag mode (0=manual, 1=automatic) |
| `progressbar_dragmode#(pb#, mode)` | Sets drag mode |

### Event Callbacks

| Function | Description |
|----------|-------------|
| `progressbar_onclick#(pb#, funcName$)` | Sets OnClick callback |
| `progressbar_onclick$(pb#)` | Gets OnClick callback name |
| `progressbar_ondblclick#(pb#, funcName$)` | Sets OnDblClick callback |
| `progressbar_ondblclick$(pb#)` | Gets OnDblClick callback name |
| `progressbar_onmousedown#(pb#, funcName$)` | Sets OnMouseDown callback |
| `progressbar_onmousedown$(pb#)` | Gets OnMouseDown callback name |
| `progressbar_onmouseup#(pb#, funcName$)` | Sets OnMouseUp callback |
| `progressbar_onmouseup$(pb#)` | Gets OnMouseUp callback name |
| `progressbar_onmousemove#(pb#, funcName$)` | Sets OnMouseMove callback |
| `progressbar_onmousemove$(pb#)` | Gets OnMouseMove callback name |
| `progressbar_onmouseenter#(pb#, funcName$)` | Sets OnMouseEnter callback |
| `progressbar_onmouseenter$(pb#)` | Gets OnMouseEnter callback name |
| `progressbar_onmouseleave#(pb#, funcName$)` | Sets OnMouseLeave callback |
| `progressbar_onmouseleave$(pb#)` | Gets OnMouseLeave callback name |
| `progressbar_onresize#(pb#, funcName$)` | Sets OnResize callback |
| `progressbar_onresize$(pb#)` | Gets OnResize callback name |
| `progressbar_ondragenter#(pb#, funcName$)` | Sets OnDragEnter callback |
| `progressbar_ondragenter$(pb#)` | Gets OnDragEnter callback name |
| `progressbar_ondragover#(pb#, funcName$)` | Sets OnDragOver callback |
| `progressbar_ondragover$(pb#)` | Gets OnDragOver callback name |
| `progressbar_ondragdrop#(pb#, funcName$)` | Sets OnDragDrop callback |
| `progressbar_ondragdrop$(pb#)` | Gets OnDragDrop callback name |
| `progressbar_ondragleave#(pb#, funcName$)` | Sets OnDragLeave callback |
| `progressbar_ondragleave$(pb#)` | Gets OnDragLeave callback name |
| `progressbar_clearcallbacks#(pb#)` | Clears all callbacks |

### Callback Signatures

```basic
' OnClick / OnDblClick callback
function OnClick(sender#)
  println "ProgressBar clicked"
endfunction

' OnMouseDown / OnMouseUp callback
' button: 0=left, 1=right, 2=middle
' shift$: keyboard modifiers string (S=Shift, A=Alt, C=Ctrl, M=Command)
function OnMouseDown(sender#, button, x, y, shift$)
  println "Mouse down at: " + str$(x) + ", " + str$(y)
endfunction

' OnMouseMove callback
function OnMouseMove(sender#, x, y, shift$)
  println "Mouse at: " + str$(x) + ", " + str$(y)
endfunction

' OnMouseEnter / OnMouseLeave callback
function OnMouseEnter(sender#)
  println "Mouse entered progress bar"
endfunction

' OnResize callback
function OnResize(sender#)
  println "ProgressBar resized"
endfunction
```

## Error Handling

The library uses a global error code system:

| Error Code | Description |
|------------|-------------|
| 0 | No error |
| 1 | Invalid control pointer (nil or wrong type) |
| 2 | Invalid parent pointer |
| 3 | Invalid argument value |
| 4 | Operation failed |
| 5 | Memory allocation error |

Use `strerror$()` to get descriptive error messages.

## Complete Examples

### Example 1: File Download Simulation

```basic
' Simulate a file download with progress bar (using timer)
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

' Create timer for download simulation
let tmr# = timer#()
timer_interval#(tmr#, 50)       ' 50ms for smooth animation
timer_ontimer#(tmr#, "OnTimer")

form_show(frm#)

function StartDownload(sender#)
  progress = 0
  progressbar_value#(pb#, 0)
  label_text#(lblPercent#, "0%")
  button_enabled#(btnStart#, 0)
  label_text#(lblStatus#, "Downloading file...")
  timer_start#(tmr#)
endfunction

function OnTimer(sender#)
  progress = progress + 1
  progressbar_value#(pb#, progress)
  label_text#(lblPercent#, str$(progress) + "%")
  
  if progress >= 100 then
    timer_stop#(tmr#)
    button_enabled#(btnStart#, 1)
    label_text#(lblStatus#, "Download complete!")
  endif
endfunction
```

### Example 2: Multi-Progress Display

```basic
' Display multiple progress bars with simulated updates
let frm# = form#("Multi-Progress", 500, 250)

' CPU Usage
let lblCPU# = label#(frm#)
label_move#(lblCPU#, 20, 20)
label_text#(lblCPU#, "CPU Usage:")

let pbCPU# = progressbar#(frm#)
progressbar_move#(pbCPU#, 120, 20)
progressbar_size#(pbCPU#, 350, 25)
progressbar_max#(pbCPU#, 100)

' Memory Usage
let lblMem# = label#(frm#)
label_move#(lblMem#, 20, 60)
label_text#(lblMem#, "Memory:")

let pbMem# = progressbar#(frm#)
progressbar_move#(pbMem#, 120, 60)
progressbar_size#(pbMem#, 350, 25)
progressbar_max#(pbMem#, 100)

' Disk Usage
let lblDisk# = label#(frm#)
label_move#(lblDisk#, 20, 100)
label_text#(lblDisk#, "Disk Space:")

let pbDisk# = progressbar#(frm#)
progressbar_move#(pbDisk#, 120, 100)
progressbar_size#(pbDisk#, 350, 25)
progressbar_max#(pbDisk#, 100)
progressbar_value#(pbDisk#, 73)  ' Static disk usage

' Network Activity
let lblNet# = label#(frm#)
label_move#(lblNet#, 20, 140)
label_text#(lblNet#, "Network:")

let pbNet# = progressbar#(frm#)
progressbar_move#(pbNet#, 120, 140)
progressbar_size#(pbNet#, 350, 25)
progressbar_max#(pbNet#, 100)

' Timer for updating values
let tmr# = timer#()
timer_interval#(tmr#, 500)
timer_ontimer#(tmr#, "UpdateValues")
timer_start#(tmr#)

form_show(frm#)

function UpdateValues(sender#)
  progressbar_value#(pbCPU#, rnd(100))
  progressbar_value#(pbMem#, 40 + rnd(30))
  progressbar_value#(pbNet#, rnd(80))
endfunction
```

### Example 3: Vertical Progress Bar

```basic
' Vertical progress bars as level indicators
let frm# = form#("Audio Levels", 400, 300)

' Left Channel
let lblL# = label#(frm#)
label_move#(lblL#, 80, 20)
label_text#(lblL#, "L")

let pbLeft# = progressbar#(frm#)
progressbar_move#(pbLeft#, 70, 50)
progressbar_size#(pbLeft#, 40, 200)
progressbar_orientation#(pbLeft#, 1)  ' Vertical
progressbar_max#(pbLeft#, 100)

' Right Channel  
let lblR# = label#(frm#)
label_move#(lblR#, 160, 20)
label_text#(lblR#, "R")

let pbRight# = progressbar#(frm#)
progressbar_move#(pbRight#, 150, 50)
progressbar_size#(pbRight#, 40, 200)
progressbar_orientation#(pbRight#, 1)  ' Vertical
progressbar_max#(pbRight#, 100)

' Master
let lblM# = label#(frm#)
label_move#(lblM#, 280, 20)
label_text#(lblM#, "Master")

let pbMaster# = progressbar#(frm#)
progressbar_move#(pbMaster#, 270, 50)
progressbar_size#(pbMaster#, 60, 200)
progressbar_orientation#(pbMaster#, 1)  ' Vertical
progressbar_max#(pbMaster#, 100)

' Timer for simulating audio levels
let tmr# = timer#()
timer_interval#(tmr#, 100)
timer_ontimer#(tmr#, "UpdateLevels")
timer_start#(tmr#)

form_show(frm#)

function UpdateLevels(sender#)
  progressbar_value#(pbLeft#, 30 + rnd(50))
  progressbar_value#(pbRight#, 30 + rnd(50))
  progressbar_value#(pbMaster#, 60 + rnd(20))
endfunction
```

## See Also

- TimerLib - For timer-based animations and periodic updates
- TrackBarLib - For user-adjustable sliders
- LabelLib - For displaying text
- FormLib - For creating windows
