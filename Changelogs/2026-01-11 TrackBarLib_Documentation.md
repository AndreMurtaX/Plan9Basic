# TrackBarLib - Plan9Basic Track Bar/Slider Control Library

## Overview

TrackBarLib allows Plan9Basic programs to create and manage slider controls for user input of numeric values within a defined range.

**Version:** 1.0.0  
**Function Count:** 90+ functions  

## Quick Start

```basic
' Create a simple volume slider
let frm# = form#("Volume Control", 400, 150)

let lbl# = label#(frm#)
label_move#(lbl#, 20, 20)
label_text#(lbl#, "Volume:")

let tb# = trackbar#(frm#)
trackbar_move#(tb#, 20, 50)
trackbar_size#(tb#, 350, 45)
trackbar_min#(tb#, 0)
trackbar_max#(tb#, 100)
trackbar_value#(tb#, 50)
trackbar_onchange#(tb#, "OnVolumeChange")

form_show(frm#)

function OnVolumeChange(sender#) local vol
  vol = trackbar_value(sender#)
  label_text#(lbl#, "Volume: " + str$(vol) + "%")
endfunction
```

## Function Reference

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `trackbar#(parent#)` | Creates a new track bar on the specified parent control |
| `trackbar_free#(tb#)` | Destroys the track bar and releases resources |

### Value and Range Properties

| Function | Description |
|----------|-------------|
| `trackbar_value(tb#)` | Gets the current value |
| `trackbar_value#(tb#, value)` | Sets the current value |
| `trackbar_min(tb#)` | Gets the minimum value |
| `trackbar_min#(tb#, value)` | Sets the minimum value (default: 0) |
| `trackbar_max(tb#)` | Gets the maximum value |
| `trackbar_max#(tb#, value)` | Sets the maximum value (default: 100) |
| `trackbar_frequency(tb#)` | Gets the tick mark frequency |
| `trackbar_frequency#(tb#, freq)` | Sets tick mark frequency (default: 1) |

### Orientation

| Function | Description |
|----------|-------------|
| `trackbar_orientation(tb#)` | Gets orientation (0=horizontal, 1=vertical) |
| `trackbar_orientation#(tb#, orient)` | Sets orientation |

**Orientation Values:**
- `0` = Horizontal (default)
- `1` = Vertical

### Position and Size

| Function | Description |
|----------|-------------|
| `trackbar_left(tb#)` | Gets X position |
| `trackbar_left#(tb#, x)` | Sets X position |
| `trackbar_top(tb#)` | Gets Y position |
| `trackbar_top#(tb#, y)` | Sets Y position |
| `trackbar_width(tb#)` | Gets width |
| `trackbar_width#(tb#, w)` | Sets width |
| `trackbar_height(tb#)` | Gets height |
| `trackbar_height#(tb#, h)` | Sets height |
| `trackbar_move#(tb#, x, y)` | Sets position (X, Y) |
| `trackbar_size#(tb#, w, h)` | Sets size (width, height) |
| `trackbar_bounds#(tb#, x, y, w, h)` | Sets position and size at once |

### Alignment

| Function | Description |
|----------|-------------|
| `trackbar_align(tb#)` | Gets alignment mode |
| `trackbar_align#(tb#, align)` | Sets alignment mode |

**Alignment Values:**
- `0` = None (manual positioning)
- `1` = Top
- `2` = Left
- `3` = Right
- `4` = Bottom
- `5` = Client
- `6` = Contents
- `7` = Center
- `8` = Horizontal
- `9` = Vertical
- `10` = Fit Left
- `11` = Fit Right

### Margins

| Function | Description |
|----------|-------------|
| `trackbar_marginleft(tb#)` | Gets left margin |
| `trackbar_marginleft#(tb#, m)` | Sets left margin |
| `trackbar_margintop(tb#)` | Gets top margin |
| `trackbar_margintop#(tb#, m)` | Sets top margin |
| `trackbar_marginright(tb#)` | Gets right margin |
| `trackbar_marginright#(tb#, m)` | Sets right margin |
| `trackbar_marginbottom(tb#)` | Gets bottom margin |
| `trackbar_marginbottom#(tb#, m)` | Sets bottom margin |
| `trackbar_margins#(tb#, l, t, r, b)` | Sets all margins at once |

### Padding

| Function | Description |
|----------|-------------|
| `trackbar_paddingleft(tb#)` | Gets left padding |
| `trackbar_paddingleft#(tb#, p)` | Sets left padding |
| `trackbar_paddingtop(tb#)` | Gets top padding |
| `trackbar_paddingtop#(tb#, p)` | Sets top padding |
| `trackbar_paddingright(tb#)` | Gets right padding |
| `trackbar_paddingright#(tb#, p)` | Sets right padding |
| `trackbar_paddingbottom(tb#)` | Gets bottom padding |
| `trackbar_paddingbottom#(tb#, p)` | Sets bottom padding |
| `trackbar_padding#(tb#, l, t, r, b)` | Sets all padding at once |

### Visibility and State

| Function | Description |
|----------|-------------|
| `trackbar_visible(tb#)` | Gets visibility (0/1) |
| `trackbar_visible#(tb#, vis)` | Sets visibility |
| `trackbar_enabled(tb#)` | Gets enabled state (0/1) |
| `trackbar_enabled#(tb#, en)` | Sets enabled state |
| `trackbar_opacity(tb#)` | Gets opacity (0.0-1.0) |
| `trackbar_opacity#(tb#, op)` | Sets opacity |

### Focus Management

| Function | Description |
|----------|-------------|
| `trackbar_isfocused(tb#)` | Returns 1 if focused, 0 otherwise |
| `trackbar_setfocus#(tb#)` | Sets focus to the track bar |
| `trackbar_resetfocus#(tb#)` | Removes focus from track bar |
| `trackbar_canfocus(tb#)` | Gets whether control can receive focus |
| `trackbar_canfocus#(tb#, can)` | Sets whether control can receive focus |
| `trackbar_taborder(tb#)` | Gets tab order position |
| `trackbar_taborder#(tb#, order)` | Sets tab order position |

### Z-Order and Parent

| Function | Description |
|----------|-------------|
| `trackbar_bringtofront#(tb#)` | Brings to front of z-order |
| `trackbar_sendtoback#(tb#)` | Sends to back of z-order |
| `trackbar_parent#(tb#)` | Gets current parent control |
| `trackbar_parent#(tb#, newParent#)` | Sets new parent control |

### Rotation and Scaling

| Function | Description |
|----------|-------------|
| `trackbar_rotationangle(tb#)` | Gets rotation in degrees |
| `trackbar_rotationangle#(tb#, angle)` | Sets rotation angle |
| `trackbar_scalex(tb#)` | Gets horizontal scale factor |
| `trackbar_scalex#(tb#, sx)` | Sets horizontal scale |
| `trackbar_scaley(tb#)` | Gets vertical scale factor |
| `trackbar_scaley#(tb#, sy)` | Sets vertical scale |
| `trackbar_scale#(tb#, sx, sy)` | Sets both scale factors |

### Tag Property

| Function | Description |
|----------|-------------|
| `trackbar_tag(tb#)` | Gets numeric tag value |
| `trackbar_tag#(tb#, tagValue)` | Sets numeric tag value |

### Hit Testing and Drag

| Function | Description |
|----------|-------------|
| `trackbar_hittest(tb#)` | Gets hit test state (0/1) |
| `trackbar_hittest#(tb#, ht)` | Sets hit test state |
| `trackbar_dragmode(tb#)` | Gets drag mode (0=manual, 1=automatic) |
| `trackbar_dragmode#(tb#, mode)` | Sets drag mode |

### Event Callbacks

| Function | Description |
|----------|-------------|
| `trackbar_onchange#(tb#, funcName$)` | Sets OnChange callback (fires when user releases) |
| `trackbar_onchange$(tb#)` | Gets OnChange callback name |
| `trackbar_ontracking#(tb#, funcName$)` | Sets OnTracking callback (fires while dragging) |
| `trackbar_ontracking$(tb#)` | Gets OnTracking callback name |
| `trackbar_onclick#(tb#, funcName$)` | Sets OnClick callback |
| `trackbar_onclick$(tb#)` | Gets OnClick callback name |
| `trackbar_ondblclick#(tb#, funcName$)` | Sets OnDblClick callback |
| `trackbar_ondblclick$(tb#)` | Gets OnDblClick callback name |
| `trackbar_onenter#(tb#, funcName$)` | Sets OnEnter (focus gained) callback |
| `trackbar_onenter$(tb#)` | Gets OnEnter callback name |
| `trackbar_onexit#(tb#, funcName$)` | Sets OnExit (focus lost) callback |
| `trackbar_onexit$(tb#)` | Gets OnExit callback name |
| `trackbar_onkeydown#(tb#, funcName$)` | Sets OnKeyDown callback |
| `trackbar_onkeydown$(tb#)` | Gets OnKeyDown callback name |
| `trackbar_onkeyup#(tb#, funcName$)` | Sets OnKeyUp callback |
| `trackbar_onkeyup$(tb#)` | Gets OnKeyUp callback name |
| `trackbar_onmousedown#(tb#, funcName$)` | Sets OnMouseDown callback |
| `trackbar_onmousedown$(tb#)` | Gets OnMouseDown callback name |
| `trackbar_onmouseup#(tb#, funcName$)` | Sets OnMouseUp callback |
| `trackbar_onmouseup$(tb#)` | Gets OnMouseUp callback name |
| `trackbar_onmousemove#(tb#, funcName$)` | Sets OnMouseMove callback |
| `trackbar_onmousemove$(tb#)` | Gets OnMouseMove callback name |
| `trackbar_onmouseenter#(tb#, funcName$)` | Sets OnMouseEnter callback |
| `trackbar_onmouseenter$(tb#)` | Gets OnMouseEnter callback name |
| `trackbar_onmouseleave#(tb#, funcName$)` | Sets OnMouseLeave callback |
| `trackbar_onmouseleave$(tb#)` | Gets OnMouseLeave callback name |
| `trackbar_onresize#(tb#, funcName$)` | Sets OnResize callback |
| `trackbar_onresize$(tb#)` | Gets OnResize callback name |
| `trackbar_ondragenter#(tb#, funcName$)` | Sets OnDragEnter callback |
| `trackbar_ondragenter$(tb#)` | Gets OnDragEnter callback name |
| `trackbar_ondragover#(tb#, funcName$)` | Sets OnDragOver callback |
| `trackbar_ondragover$(tb#)` | Gets OnDragOver callback name |
| `trackbar_ondragdrop#(tb#, funcName$)` | Sets OnDragDrop callback |
| `trackbar_ondragdrop$(tb#)` | Gets OnDragDrop callback name |
| `trackbar_ondragleave#(tb#, funcName$)` | Sets OnDragLeave callback |
| `trackbar_ondragleave$(tb#)` | Gets OnDragLeave callback name |
| `trackbar_clearcallbacks#(tb#)` | Clears all callbacks |

### Callback Signatures

```basic
' OnChange callback - fires when user releases the thumb
function OnValueChanged(sender#) local val
  val = trackbar_value(sender#)
  println "Final value: " + str$(val)
endfunction

' OnTracking callback - fires continuously while dragging
function OnTracking(sender#) local val
  val = trackbar_value(sender#)
  println "Current value: " + str$(val)
endfunction

' OnClick / OnDblClick callback
function OnClick(sender#)
  println "TrackBar clicked"
endfunction

' OnEnter / OnExit callback (focus)
function OnEnter(sender#)
  println "TrackBar focused"
endfunction

' OnKeyDown / OnKeyUp callback
' key: virtual key code
' keyChar$: character pressed (if printable)
' shift$: modifier keys string (S=Shift, A=Alt, C=Ctrl, M=Command)
function OnKeyDown(sender#, key, keyChar$, shift$)
  println "Key pressed: " + str$(key)
endfunction

' OnMouseDown / OnMouseUp callback
' button: 0=left, 1=right, 2=middle
function OnMouseDown(sender#, button, x, y, shift$)
  println "Mouse button " + str$(button) + " at " + str$(x) + "," + str$(y)
endfunction

' OnMouseMove callback
function OnMouseMove(sender#, x, y, shift$)
  println "Mouse at: " + str$(x) + ", " + str$(y)
endfunction
```

## OnChange vs OnTracking

TrackBar provides two value-change events:

- **OnChange**: Fires **once** when the user releases the thumb after dragging. Use this for actions that should only happen when the user has finished adjusting the value.

- **OnTracking**: Fires **continuously** while the user is dragging the thumb. Use this for real-time feedback during adjustment.

```basic
' Example: OnChange for final value, OnTracking for preview
trackbar_onchange#(tb#, "ApplyFinalValue")
trackbar_ontracking#(tb#, "ShowPreview")

function ApplyFinalValue(sender#) local val
  val = trackbar_value(sender#)
  ' Apply the setting permanently
  ApplySetting(val)
endfunction

function ShowPreview(sender#) local val
  val = trackbar_value(sender#)
  ' Show a preview (e.g., update a label)
  label_text#(lblPreview#, str$(val))
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

### Example 1: RGB Color Mixer

```basic
' RGB Color Mixer with three sliders
let frm# = form#("RGB Color Mixer", 450, 350)

' Red slider
let lblR# = label#(frm#)
label_move#(lblR#, 20, 30)
label_text#(lblR#, "Red:")

let tbRed# = trackbar#(frm#)
trackbar_move#(tbRed#, 80, 25)
trackbar_size#(tbRed#, 280, 45)
trackbar_min#(tbRed#, 0)
trackbar_max#(tbRed#, 255)
trackbar_value#(tbRed#, 128)
trackbar_ontracking#(tbRed#, "UpdateColor")

let lblRVal# = label#(frm#)
label_move#(lblRVal#, 370, 30)
label_size#(lblRVal#, 50, 25)

' Green slider
let lblG# = label#(frm#)
label_move#(lblG#, 20, 90)
label_text#(lblG#, "Green:")

let tbGreen# = trackbar#(frm#)
trackbar_move#(tbGreen#, 80, 85)
trackbar_size#(tbGreen#, 280, 45)
trackbar_min#(tbGreen#, 0)
trackbar_max#(tbGreen#, 255)
trackbar_value#(tbGreen#, 128)
trackbar_ontracking#(tbGreen#, "UpdateColor")

let lblGVal# = label#(frm#)
label_move#(lblGVal#, 370, 90)
label_size#(lblGVal#, 50, 25)

' Blue slider
let lblB# = label#(frm#)
label_move#(lblB#, 20, 150)
label_text#(lblB#, "Blue:")

let tbBlue# = trackbar#(frm#)
trackbar_move#(tbBlue#, 80, 145)
trackbar_size#(tbBlue#, 280, 45)
trackbar_min#(tbBlue#, 0)
trackbar_max#(tbBlue#, 255)
trackbar_value#(tbBlue#, 128)
trackbar_ontracking#(tbBlue#, "UpdateColor")

let lblBVal# = label#(frm#)
label_move#(lblBVal#, 370, 150)
label_size#(lblBVal#, 50, 25)

' Color preview rectangle (use rectangle for fill color)
let rectColor# = rectangle#(frm#)
rectangle_move#(rectColor#, 80, 210)
rectangle_size#(rectColor#, 280, 100)
rectangle_fill#(rectColor#, "#808080")
rectangle_stroke#(rectColor#, "black")

' Hex color label
let lblHex# = label#(frm#)
label_move#(lblHex#, 170, 320)
label_size#(lblHex#, 100, 25)

' Initial values
label_text#(lblRVal#, "128")
label_text#(lblGVal#, "128")
label_text#(lblBVal#, "128")
label_text#(lblHex#, "#808080")

form_show(frm#)

function UpdateColor(sender#) local r, g, b, hexColor$
  r = int(trackbar_value(tbRed#))
  g = int(trackbar_value(tbGreen#))
  b = int(trackbar_value(tbBlue#))
  
  label_text#(lblRVal#, str$(r))
  label_text#(lblGVal#, str$(g))
  label_text#(lblBVal#, str$(b))
  
  hexColor$ = "#" + right$("0" + hex$(r), 2) + right$("0" + hex$(g), 2) + right$("0" + hex$(b), 2)
  label_text#(lblHex#, hexColor$)
  rectangle_fill#(rectColor#, hexColor$)
endfunction
```

### Example 2: Audio Equalizer

```basic
' 5-Band Equalizer
let frm# = form#("5-Band Equalizer", 500, 350)

let bands = 5
let freqs$ = "60Hz,250Hz,1kHz,4kHz,16kHz"
dim bandLabels#(bands)
dim bandSliders#(bands)
dim bandValues#(bands)

' Create vertical sliders for each band
let xPos = 50
let i = 1

while i <= bands
  ' Frequency label
  let lbl# = label#(frm#)
  label_move#(lbl#, xPos - 10, 20)
  label_size#(lbl#, 70, 20)
  label_text#(lbl#, word$(freqs$, i, ","))
  bandLabels#[i] = lbl#
  
  ' Vertical slider
  let tb# = trackbar#(frm#)
  trackbar_move#(tb#, xPos, 50)
  trackbar_size#(tb#, 50, 200)
  trackbar_orientation#(tb#, 1)  ' Vertical
  trackbar_min#(tb#, -12)        ' -12 dB
  trackbar_max#(tb#, 12)         ' +12 dB
  trackbar_value#(tb#, 0)        ' 0 dB (flat)
  trackbar_tag#(tb#, i)          ' Store band index
  trackbar_ontracking#(tb#, "OnBandChange")
  bandSliders#[i] = tb#
  
  ' Value label
  let valLbl# = label#(frm#)
  label_move#(valLbl#, xPos, 260)
  label_size#(valLbl#, 50, 20)
  label_text#(valLbl#, "0 dB")
  bandValues#[i] = valLbl#
  
  xPos = xPos + 90
  i = i + 1
endwhile

' Reset button
let btnReset# = button#(frm#)
button_move#(btnReset#, 200, 300)
button_size#(btnReset#, 100, 35)
button_text#(btnReset#, "Flat")
button_onclick#(btnReset#, "ResetEQ")

form_show(frm#)

function OnBandChange(sender#) local band, val, sign$
  band = trackbar_tag(sender#)
  val = trackbar_value(sender#)
  
  if val >= 0 then
    sign$ = "+"
  else
    sign$ = ""
  endif
  
  label_text#(bandValues#[band], sign$ + str$(val) + " dB")
endfunction

function ResetEQ(sender#) local i
  i = 1
  while i <= bands
    trackbar_value#(bandSliders#[i], 0)
    label_text#(bandValues#[i], "0 dB")
    i = i + 1
  endwhile
endfunction
```

### Example 3: Settings Panel with Multiple Sliders

```basic
' Application Settings Panel
let frm# = form#("Settings", 450, 320)

' Volume
let lblVol# = label#(frm#)
label_move#(lblVol#, 20, 30)
label_text#(lblVol#, "Volume:")
label_size#(lblVol#, 80, 25)

let tbVol# = trackbar#(frm#)
trackbar_move#(tbVol#, 110, 25)
trackbar_size#(tbVol#, 250, 45)
trackbar_min#(tbVol#, 0)
trackbar_max#(tbVol#, 100)
trackbar_value#(tbVol#, 75)
trackbar_onchange#(tbVol#, "OnVolChange")

let lblVolVal# = label#(frm#)
label_move#(lblVolVal#, 370, 30)
label_text#(lblVolVal#, "75%")

' Brightness
let lblBright# = label#(frm#)
label_move#(lblBright#, 20, 90)
label_text#(lblBright#, "Brightness:")
label_size#(lblBright#, 80, 25)

let tbBright# = trackbar#(frm#)
trackbar_move#(tbBright#, 110, 85)
trackbar_size#(tbBright#, 250, 45)
trackbar_min#(tbBright#, 0)
trackbar_max#(tbBright#, 100)
trackbar_value#(tbBright#, 80)
trackbar_onchange#(tbBright#, "OnBrightChange")

let lblBrightVal# = label#(frm#)
label_move#(lblBrightVal#, 370, 90)
label_text#(lblBrightVal#, "80%")

' Speed (with discrete steps)
let lblSpeed# = label#(frm#)
label_move#(lblSpeed#, 20, 150)
label_text#(lblSpeed#, "Speed:")
label_size#(lblSpeed#, 80, 25)

let tbSpeed# = trackbar#(frm#)
trackbar_move#(tbSpeed#, 110, 145)
trackbar_size#(tbSpeed#, 250, 45)
trackbar_min#(tbSpeed#, 1)
trackbar_max#(tbSpeed#, 5)
trackbar_value#(tbSpeed#, 3)
trackbar_frequency#(tbSpeed#, 1)  ' Tick marks at each step
trackbar_onchange#(tbSpeed#, "OnSpeedChange")

let lblSpeedVal# = label#(frm#)
label_move#(lblSpeedVal#, 370, 150)
label_text#(lblSpeedVal#, "Normal")

' Zoom
let lblZoom# = label#(frm#)
label_move#(lblZoom#, 20, 210)
label_text#(lblZoom#, "Zoom:")
label_size#(lblZoom#, 80, 25)

let tbZoom# = trackbar#(frm#)
trackbar_move#(tbZoom#, 110, 205)
trackbar_size#(tbZoom#, 250, 45)
trackbar_min#(tbZoom#, 25)
trackbar_max#(tbZoom#, 400)
trackbar_value#(tbZoom#, 100)
trackbar_onchange#(tbZoom#, "OnZoomChange")

let lblZoomVal# = label#(frm#)
label_move#(lblZoomVal#, 370, 210)
label_text#(lblZoomVal#, "100%")

' Apply button
let btnApply# = button#(frm#)
button_move#(btnApply#, 175, 270)
button_size#(btnApply#, 100, 35)
button_text#(btnApply#, "Apply")
button_onclick#(btnApply#, "ApplySettings")

form_show(frm#)

function OnVolChange(sender#) local val
  val = trackbar_value(sender#)
  label_text#(lblVolVal#, str$(val) + "%")
endfunction

function OnBrightChange(sender#) local val
  val = trackbar_value(sender#)
  label_text#(lblBrightVal#, str$(val) + "%")
endfunction

function OnSpeedChange(sender#) local val, name$
  val = trackbar_value(sender#)
  select case val
    case 1: name$ = "Slowest"
    case 2: name$ = "Slow"
    case 3: name$ = "Normal"
    case 4: name$ = "Fast"
    case 5: name$ = "Fastest"
  endselect
  label_text#(lblSpeedVal#, name$)
endfunction

function OnZoomChange(sender#) local val
  val = trackbar_value(sender#)
  label_text#(lblZoomVal#, str$(val) + "%")
endfunction

function ApplySettings(sender#) local vol, bright, speed, zoom
  vol = trackbar_value(tbVol#)
  bright = trackbar_value(tbBright#)
  speed = trackbar_value(tbSpeed#)
  zoom = trackbar_value(tbZoom#)
  
  println "Settings applied:"
  println "  Volume: " + str$(vol) + "%"
  println "  Brightness: " + str$(bright) + "%"
  println "  Speed: " + str$(speed)
  println "  Zoom: " + str$(zoom) + "%"
endfunction
```

### Example 4: Keyboard Navigation

```basic
' TrackBar with keyboard control
let frm# = form#("Keyboard Control Demo", 400, 200)

let lbl# = label#(frm#)
label_move#(lbl#, 20, 20)
label_text#(lbl#, "Use arrow keys to adjust (focus the slider first):")

let tb# = trackbar#(frm#)
trackbar_move#(tb#, 20, 60)
trackbar_size#(tb#, 360, 45)
trackbar_min#(tb#, 0)
trackbar_max#(tb#, 100)
trackbar_value#(tb#, 50)
trackbar_onchange#(tb#, "OnChange")
trackbar_onenter#(tb#, "OnFocus")
trackbar_onexit#(tb#, "OnBlur")
trackbar_onkeydown#(tb#, "OnKey")

let lblVal# = label#(frm#)
label_move#(lblVal#, 180, 110)
label_text#(lblVal#, "50")

let lblFocus# = label#(frm#)
label_move#(lblFocus#, 20, 150)
label_text#(lblFocus#, "Click slider to focus")

' Set initial focus
trackbar_setfocus#(tb#)

form_show(frm#)

function OnChange(sender#) local val
  val = trackbar_value(sender#)
  label_text#(lblVal#, str$(val))
endfunction

function OnFocus(sender#)
  label_text#(lblFocus#, "Slider focused - use Left/Right arrows")
endfunction

function OnBlur(sender#)
  label_text#(lblFocus#, "Slider lost focus")
endfunction

function OnKey(sender#, key, keyChar$, shift$)
  println "Key: " + str$(key) + " Shift: " + shift$
endfunction
```

## See Also

- TimerLib - For timer-based animations and periodic updates
- ProgressBarLib - For display-only progress indication
- EditLib - For text input
- LabelLib - For displaying values
- FormLib - For creating windows
