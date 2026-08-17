# TrackBarLib - TrackBar (Slider) Control Library for Plan9Basic

## Overview

TrackBarLib provides functionality for creating and managing trackbar (slider) controls in Plan9Basic programs. TrackBars allow users to select a value from a range by dragging a thumb along a track.

**Version:** 1.0.0  
**Function Count:** 100+ functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("TrackBar Demo", 400, 200)
form_position#(frm#, 4)

let lbl# = label#(frm#, "Volume: 50")
label_move#(lbl#, 50, 30)

let tb# = trackbar#(frm#, 50, 60, 300, 30)
trackbar_min#(tb#, 0)
trackbar_max#(tb#, 100)
trackbar_value#(tb#, 50)

trackbar_onchange#(tb#, "OnValueChange")

form_show(frm#)


function OnValueChange(sender#) local val
  val = trackbar_value(sender#)
  label_text#(lbl#, "Volume: " + str$(int(val)))
endfunction
```

## Numeric Values Reference

### Orientation Values

| Value | Description |
|-------|-------------|
| 0 | Horizontal |
| 1 | Vertical |

### Alignment Values

| Value | Description |
|-------|-------------|
| 0 | None (absolute positioning) |
| 1 | Top |
| 2 | Left |
| 3 | Right |
| 4 | Bottom |
| 9 | Client (fill parent) |

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `trackbar_error()` | Returns last error code (0 = no error) |
| `trackbar_errormsg$()` | Returns last error message |
| `trackbar_strerror$(code)` | Converts error code to message |
| `trackbar_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `trackbar#(parent#)` | Create with default size |
| `trackbar#(parent#, x, y, w, h)` | Create with position and size |
| `trackbar_free(tb#)` | Destroy trackbar |

### Value Properties

| Function | Description |
|----------|-------------|
| `trackbar_value(tb#)` | Get current value |
| `trackbar_value#(tb#, value)` | Set current value |
| `trackbar_min(tb#)` | Get minimum value |
| `trackbar_min#(tb#, value)` | Set minimum value |
| `trackbar_max(tb#)` | Get maximum value |
| `trackbar_max#(tb#, value)` | Set maximum value |
| `trackbar_frequency(tb#)` | Get tick frequency |
| `trackbar_frequency#(tb#, value)` | Set tick frequency |

### Orientation

| Function | Description |
|----------|-------------|
| `trackbar_orientation(tb#)` | Get orientation (0=horizontal, 1=vertical) |
| `trackbar_orientation#(tb#, value)` | Set orientation |

### Position and Size

| Function | Description |
|----------|-------------|
| `trackbar_x(tb#)` / `trackbar_x#(tb#, x)` | Get/set X position |
| `trackbar_y(tb#)` / `trackbar_y#(tb#, y)` | Get/set Y position |
| `trackbar_width(tb#)` / `trackbar_width#(tb#, w)` | Get/set width |
| `trackbar_height(tb#)` / `trackbar_height#(tb#, h)` | Get/set height |
| `trackbar_bounds#(tb#, x, y, w, h)` | Set position and size |
| `trackbar_move#(tb#, x, y)` | Set position only |
| `trackbar_size#(tb#, w, h)` | Set size only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `trackbar_align(tb#)` / `trackbar_align#(tb#, value)` | Get/set alignment |
| `trackbar_marginleft(tb#)` / `trackbar_marginleft#(tb#, value)` | Get/set left margin |
| `trackbar_margintop(tb#)` / `trackbar_margintop#(tb#, value)` | Get/set top margin |
| `trackbar_marginright(tb#)` / `trackbar_marginright#(tb#, value)` | Get/set right margin |
| `trackbar_marginbottom(tb#)` / `trackbar_marginbottom#(tb#, value)` | Get/set bottom margin |
| `trackbar_margins#(tb#, l, t, r, b)` | Set all margins |
| `trackbar_margin#(tb#, value)` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `trackbar_visible(tb#)` / `trackbar_visible#(tb#, value)` | Get/set visibility (0/1) |
| `trackbar_enabled(tb#)` / `trackbar_enabled#(tb#, value)` | Get/set enabled state (0/1) |
| `trackbar_opacity(tb#)` / `trackbar_opacity#(tb#, value)` | Get/set opacity (0.0-1.0) |
| `trackbar_hittest(tb#)` / `trackbar_hittest#(tb#, value)` | Get/set hit test (0/1) |
| `trackbar_dragmode(tb#)` / `trackbar_dragmode#(tb#, value)` | Get/set drag mode (0/1) |

### Focus

| Function | Description |
|----------|-------------|
| `trackbar_isfocused(tb#)` | Check if focused (0/1) |
| `trackbar_setfocus#(tb#)` | Set focus to trackbar |
| `trackbar_resetfocus#(tb#)` | Remove focus from trackbar |
| `trackbar_taborder(tb#)` / `trackbar_taborder#(tb#, value)` | Get/set tab order |
| `trackbar_canfocus(tb#)` / `trackbar_canfocus#(tb#, value)` | Get/set can focus (0/1) |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `trackbar_tag(tb#)` / `trackbar_tag#(tb#, value)` | Get/set tag value |
| `trackbar_parent#(tb#)` | Get parent |
| `trackbar_parent#(tb#, parent#)` | Set parent |
| `trackbar_bringtofront#(tb#)` | Bring to front |
| `trackbar_sendtoback#(tb#)` | Send to back |

---

## Event Callbacks

### Basic Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnChange | `trackbar_onchange#(tb#, func$)` | `trackbar_onchange$(tb#)` | `function(sender#)` |
| OnTracking | `trackbar_ontracking#(tb#, func$)` | `trackbar_ontracking$(tb#)` | `function(sender#)` |
| OnClick | `trackbar_onclick#(tb#, func$)` | `trackbar_onclick$(tb#)` | `function(sender#)` |
| OnDblClick | `trackbar_ondblclick#(tb#, func$)` | `trackbar_ondblclick$(tb#)` | `function(sender#)` |
| OnEnter | `trackbar_onenter#(tb#, func$)` | `trackbar_onenter$(tb#)` | `function(sender#)` |
| OnExit | `trackbar_onexit#(tb#, func$)` | `trackbar_onexit$(tb#)` | `function(sender#)` |
| OnResize | `trackbar_onresize#(tb#, func$)` | `trackbar_onresize$(tb#)` | `function(sender#)` |

### Keyboard Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnKeyDown | `trackbar_onkeydown#(tb#, func$)` | `trackbar_onkeydown$(tb#)` | `function(sender#, key, keychar$, shift$)` |
| OnKeyUp | `trackbar_onkeyup#(tb#, func$)` | `trackbar_onkeyup$(tb#)` | `function(sender#, key, keychar$, shift$)` |

### Mouse Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnMouseDown | `trackbar_onmousedown#(tb#, func$)` | `trackbar_onmousedown$(tb#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `trackbar_onmouseup#(tb#, func$)` | `trackbar_onmouseup$(tb#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `trackbar_onmousemove#(tb#, func$)` | `trackbar_onmousemove$(tb#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `trackbar_onmouseenter#(tb#, func$)` | `trackbar_onmouseenter$(tb#)` | `function(sender#)` |
| OnMouseLeave | `trackbar_onmouseleave#(tb#, func$)` | `trackbar_onmouseleave$(tb#)` | `function(sender#)` |

### Drag Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnDragEnter | `trackbar_ondragenter#(tb#, func$)` | `trackbar_ondragenter$(tb#)` | `function(sender#, x, y)` |
| OnDragOver | `trackbar_ondragover#(tb#, func$)` | `trackbar_ondragover$(tb#)` | `function(sender#, x, y)` |
| OnDragDrop | `trackbar_ondragdrop#(tb#, func$)` | `trackbar_ondragdrop$(tb#)` | `function(sender#, x, y)` |
| OnDragLeave | `trackbar_ondragleave#(tb#, func$)` | `trackbar_ondragleave$(tb#)` | `function(sender#)` |

### Utility

| Function | Description |
|----------|-------------|
| `trackbar_clearcallbacks#(tb#)` | Disconnect all event callbacks |



### OnChange vs OnTracking

- **OnChange** - Fires when dragging stops and value is finalized
- **OnTracking** - Fires continuously while dragging (real-time updates)

---

## Complete Examples

### Volume Control

```basic
let frm# = form#("Volume Control", 400, 150)
form_position#(frm#, 4)

let lblVol# = label#(frm#, "Volume: 50%")
label_bounds#(lblVol#, 50, 20, 150, 25)
label_fontsize#(lblVol#, 14)

let tbVol# = trackbar#(frm#, 50, 50, 300, 30)
trackbar_min#(tbVol#, 0)
trackbar_max#(tbVol#, 100)
trackbar_value#(tbVol#, 50)

let btnMute# = button#(frm#, "Mute", 50, 90, 80, 30)

let savedVol = 50

trackbar_ontracking#(tbVol#, "OnVolChange")
trackbar_onchange#(tbVol#, "OnVolChange")
button_onclick#(btnMute#, "OnMute")

form_show(frm#)


function OnVolChange(sender#) local vol
  vol = int(trackbar_value(sender#))
  label_text#(lblVol#, "Volume: " + str$(vol) + "%")
endfunction

function OnMute(sender#) local vol
  vol = trackbar_value(tbVol#)
  if vol > 0 then
    savedVol = vol
    trackbar_value#(tbVol#, 0)
    button_text#(btnMute#, "Unmute")
  else
    trackbar_value#(tbVol#, savedVol)
    button_text#(btnMute#, "Mute")
  endif
  OnVolChange(tbVol#)
endfunction
```

### RGB Color Mixer

```basic
let frm# = form#("RGB Color Mixer", 450, 300)
form_position#(frm#, 4)

' Color preview (using rectangle for color display)
let rectColor# = rectangle#(frm#, 300, 30, 120, 120)
rectangle_fill#(rectColor#, "#808080")

' Red slider
let lblR# = label#(frm#, "R: 128")
label_move#(lblR#, 20, 30)
let tbR# = trackbar#(frm#, 70, 25, 200, 30)
trackbar_min#(tbR#, 0)
trackbar_max#(tbR#, 255)
trackbar_value#(tbR#, 128)
trackbar_tag#(tbR#, 1)

' Green slider
let lblG# = label#(frm#, "G: 128")
label_move#(lblG#, 20, 80)
let tbG# = trackbar#(frm#, 70, 75, 200, 30)
trackbar_min#(tbG#, 0)
trackbar_max#(tbG#, 255)
trackbar_value#(tbG#, 128)
trackbar_tag#(tbG#, 2)

' Blue slider
let lblB# = label#(frm#, "B: 128")
label_move#(lblB#, 20, 130)
let tbB# = trackbar#(frm#, 70, 125, 200, 30)
trackbar_min#(tbB#, 0)
trackbar_max#(tbB#, 255)
trackbar_value#(tbB#, 128)
trackbar_tag#(tbB#, 3)

' Hex display
let lblHex# = label#(frm#, "#808080")
label_bounds#(lblHex#, 300, 170, 120, 25)
label_textalign#(lblHex#, 0)

trackbar_ontracking#(tbR#, "OnColorChange")
trackbar_ontracking#(tbG#, "OnColorChange")
trackbar_ontracking#(tbB#, "OnColorChange")

form_show(frm#)

function ToHex$(val) local h$
  h$ = hex$(val)
  if len(h$) = 1 then h$ = "0" + h$
  return h$
endfunction

function OnColorChange(sender#) local r, g, b, color$, tag
  tag = trackbar_tag(sender#)
  
  r = int(trackbar_value(tbR#))
  g = int(trackbar_value(tbG#))
  b = int(trackbar_value(tbB#))
  
  ' Update label for changed slider
  if tag = 1 then label_text#(lblR#, "R: " + str$(r))
  if tag = 2 then label_text#(lblG#, "G: " + str$(g))
  if tag = 3 then label_text#(lblB#, "B: " + str$(b))
  
  color$ = "#" + ToHex$(r) + ToHex$(g) + ToHex$(b)
  
  rectangle_fill#(rectColor#, color$)
  label_text#(lblHex#, color$)
endfunction
```

### Image Zoom Control

```basic
let frm# = form#("Zoom Control", 400, 300)
form_position#(frm#, 4)

let img# = image#(frm#, 50, 50, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

let lblZoom# = label#(frm#, "Zoom: 100%")
label_move#(lblZoom#, 50, 220)

let tbZoom# = trackbar#(frm#, 50, 250, 300, 30)
trackbar_min#(tbZoom#, 50)
trackbar_max#(tbZoom#, 200)
trackbar_value#(tbZoom#, 100)

let baseW = 200
let baseH = 150

trackbar_ontracking#(tbZoom#, "OnZoom")

form_show(frm#)

function OnZoom(sender#) local zoom, newW, newH
  zoom = trackbar_value(sender#)
  
  newW = int(baseW * zoom / 100)
  newH = int(baseH * zoom / 100)
  
  image_size#(img#, newW, newH)
  label_text#(lblZoom#, "Zoom: " + str$(int(zoom)) + "%")
endfunction
```

### Vertical Sliders Panel

```basic
let frm# = form#("Equalizer", 400, 300)
form_position#(frm#, 4)

' Create vertical sliders
let tb1# = trackbar#(frm#, 50, 50, 30, 180)
trackbar_orientation#(tb1#, 1)
trackbar_min#(tb1#, 0)
trackbar_max#(tb1#, 100)
trackbar_value#(tb1#, 50)

let tb2# = trackbar#(frm#, 100, 50, 30, 180)
trackbar_orientation#(tb2#, 1)
trackbar_min#(tb2#, 0)
trackbar_max#(tb2#, 100)
trackbar_value#(tb2#, 60)

let tb3# = trackbar#(frm#, 150, 50, 30, 180)
trackbar_orientation#(tb3#, 1)
trackbar_min#(tb3#, 0)
trackbar_max#(tb3#, 100)
trackbar_value#(tb3#, 70)

let tb4# = trackbar#(frm#, 200, 50, 30, 180)
trackbar_orientation#(tb4#, 1)
trackbar_min#(tb4#, 0)
trackbar_max#(tb4#, 100)
trackbar_value#(tb4#, 55)

let tb5# = trackbar#(frm#, 250, 50, 30, 180)
trackbar_orientation#(tb5#, 1)
trackbar_min#(tb5#, 0)
trackbar_max#(tb5#, 100)
trackbar_value#(tb5#, 45)

' Labels
let lbl1# = label#(frm#, "60Hz")
label_move#(lbl1#, 40, 240)

let lbl2# = label#(frm#, "250Hz")
label_move#(lbl2#, 85, 240)

let lbl3# = label#(frm#, "1kHz")
label_move#(lbl3#, 140, 240)

let lbl4# = label#(frm#, "4kHz")
label_move#(lbl4#, 190, 240)

let lbl5# = label#(frm#, "16kHz")
label_move#(lbl5#, 235, 240)

let btnReset# = button#(frm#, "Reset", 300, 120, 80, 35)
button_onclick#(btnReset#, "OnReset")

form_show(frm#)

function OnReset(sender#)
  trackbar_value#(tb1#, 50)
  trackbar_value#(tb2#, 50)
  trackbar_value#(tb3#, 50)
  trackbar_value#(tb4#, 50)
  trackbar_value#(tb5#, 50)
endfunction
```

### Range Indicator

```basic
let frm# = form#("Temperature Control", 400, 200)
form_position#(frm#, 4)

let lblTemp# = label#(frm#, "Temperature: 20°C")
label_bounds#(lblTemp#, 50, 20, 200, 30)
label_fontsize#(lblTemp#, 16)

let lblRange# = label#(frm#, "Comfortable")
label_bounds#(lblRange#, 50, 130, 200, 25)
label_fontcolor#(lblRange#, "#00AA00")

let tbTemp# = trackbar#(frm#, 50, 60, 300, 40)
trackbar_min#(tbTemp#, 10)
trackbar_max#(tbTemp#, 35)
trackbar_value#(tbTemp#, 20)

trackbar_ontracking#(tbTemp#, "OnTempChange")

form_show(frm#)

function OnTempChange(sender#) local temp, status$, color$
  temp = int(trackbar_value(sender#))
  label_text#(lblTemp#, "Temperature: " + str$(temp) + "°C")
  
  if temp < 16 then
    status$ = "Too Cold"
    color$ = "#0000FF"
  else if temp < 18 then
    status$ = "Cool"
    color$ = "#00AAFF"
  else if temp <= 24 then
    status$ = "Comfortable"
    color$ = "#00AA00"
  else if temp <= 28 then
    status$ = "Warm"
    color$ = "#FFAA00"
  else
    status$ = "Too Hot"
    color$ = "#FF0000"
  endif
  
  label_text#(lblRange#, status$)
  label_fontcolor#(lblRange#, color$)
endfunction
```

---

## Tips and Best Practices

1. **Set min/max before value** - Define range before setting initial value
2. **Use OnTracking for real-time feedback** - Updates while dragging
3. **Use OnChange for final values** - Fires when user releases the slider
4. **Vertical sliders need swapped dimensions** - Set height > width for vertical
5. **Use frequency for tick marks** - Set `trackbar_frequency#` for visual ticks
6. **Use tag for identification** - Distinguish multiple trackbars in shared callbacks
7. **Integer conversion** - Use `int` when displaying values as whole numbers

---

## See Also

- **ProgressBarLib** - Read-only progress display
- **EditLib** - Numeric text input
- **LabelLib** - Display slider values

---

*TrackBarLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
