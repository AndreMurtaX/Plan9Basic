# SpeedButtonLib - Speed Button Control Library for Plan9Basic

## Overview

SpeedButtonLib provides complete functionality for creating and managing speed button controls in Plan9Basic programs. A speedButton is a flat, toolbar-style button that supports grouping and toggle behavior.

**Version:** 1.0.0  
**Function Count:** 85 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Key Differences from TButton

| Feature | TButton | TSpeedButton |
|---------|---------|--------------|
| Appearance | Standard 3D button | Flat, toolbar-style |
| GroupIndex | No | Yes (custom, see below) |
| StaysPressed | No | Yes (toggle behavior) |
| Down property | No | Yes (pressed state) |
| Keyboard focus | Yes | No (by default) |
| ModalResult | Yes | No |
| Default/Cancel | Yes | No |
| OnEnter/OnExit | Yes | No |
| OnKeyDown/OnKeyUp | Yes | No |

## GroupIndex Behavior (Manual Implementation Required)

**Important:** Unlike VCL TSpeedButton, FireMonkey's TSpeedButton does **not** have built-in radio-button grouping. SpeedButtonLib provides a custom `GroupIndex` property for logical grouping, but you must implement the radio-button behavior manually in your BASIC code.

- **GroupIndex = 0**: Button acts independently (default)
- **GroupIndex > 0**: Use same value to logically group buttons
  - **No automatic radio behavior** - you must toggle other buttons manually
  - Combined with StaysPressed for toggle behavior

### Example: Manual Radio-Button Behavior

```basic
' Store button references in a global array for easy access
dim alignButtons#(3)

' In OnClick handler, manually toggle other buttons in the group
function OnAlignClick(sender#)
  let i = 0
  while i < 3
    if alignButtons#(i) <> sender# then
      if speedbutton_groupindex(alignButtons#(i)) = speedbutton_groupindex(sender#) then
        speedbutton_down#(alignButtons#(i), 0)
      endif
    endif
    i = i + 1
  wend
endfunction
```

## Event Connection Model

Events are connected/disconnected individually when callbacks are set:
- Setting a non-empty callback name connects ONLY that specific event
- Setting an empty callback name (`""`) disconnects ONLY that specific event
- No events are connected by default in the constructor

## Quick Start

```basic
' Create a simple toolbar with toggle buttons
let frm# = form#("SpeedButton Demo", 400, 300)

' Create format buttons (grouped for radio-button behavior)
let btnBold# = speedbutton#(frm#, "B")
speedbutton_move#(btnBold#, 10, 10)
speedbutton_size#(btnBold#, 40, 30)
speedbutton_groupindex#(btnBold#, 1)
speedbutton_stayspressed#(btnBold#, 1)
speedbutton_bold#(btnBold#, 1)
speedbutton_onclick#(btnBold#, "OnFormatClick")

let btnItalic# = speedbutton#(frm#, "I")
speedbutton_move#(btnItalic#, 55, 10)
speedbutton_size#(btnItalic#, 40, 30)
speedbutton_groupindex#(btnItalic#, 1)
speedbutton_stayspressed#(btnItalic#, 1)
speedbutton_italic#(btnItalic#, 1)
speedbutton_onclick#(btnItalic#, "OnFormatClick")

form_show(frm#)

function OnFormatClick(sender#)
  if speedbutton_down(sender#) = 1 then
    println speedbutton_text$(sender#) + " is now pressed"
  else
    println speedbutton_text$(sender#) + " is now released"
  endif
endfunction
```

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `speedbutton_error()` | Returns the last error code (0 = no error) |
| `speedbutton_errormsg$()` | Returns the last error message |
| `speedbutton_strerror$(code)` | Converts error code to human-readable message |
| `speedbutton_clearerror()` | Clears the last error |

**Error Codes:**
- 0 = No error
- 1 = Invalid speed button
- 2 = Invalid parent
- 3 = Invalid value
- 4 = Create failed

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `speedbutton#(parent#)` | Creates a speed button with default text "SpeedButton" |
| `speedbutton#(parent#, text$)` | Creates a speed button with specified text |
| `speedbutton#(parent#, x, y, w, h)` | Creates a speed button at position with size |
| `speedbutton#(parent#, text$, x, y, w, h)` | Creates a speed button with text, position, and size |
| `speedbutton_free(sb#)` | Destroys the speed button and releases resources |

**Example:**
```basic
' Different creation methods
let sb1# = speedbutton#(frm#)
let sb2# = speedbutton#(frm#, "Save")
let sb3# = speedbutton#(frm#, 10, 10, 60, 30)
let sb4# = speedbutton#(frm#, "Cancel", 80, 10, 60, 30)
```

### Text Content

| Function | Description |
|----------|-------------|
| `speedbutton_text$(sb#)` | Gets the button text |
| `speedbutton_text#(sb#, text$)` | Sets the button text |

**Example:**
```basic
speedbutton_text#(sb#, "Bold")
let caption$ = speedbutton_text$(sb#)
println "Button says: " + caption$
```

### Font Properties

| Function | Description |
|----------|-------------|
| `speedbutton_fontfamily$(sb#)` | Gets the font family name |
| `speedbutton_fontfamily#(sb#, family$)` | Sets the font family |
| `speedbutton_fontsize(sb#)` | Gets the font size |
| `speedbutton_fontsize#(sb#, size)` | Sets the font size |
| `speedbutton_fontcolor$(sb#)` | Gets the font color as hex string |
| `speedbutton_fontcolor#(sb#, color$)` | Sets the font color |
| `speedbutton_bold(sb#)` | Gets bold state (0/1) |
| `speedbutton_bold#(sb#, state)` | Sets bold state |
| `speedbutton_italic(sb#)` | Gets italic state (0/1) |
| `speedbutton_italic#(sb#, state)` | Sets italic state |
| `speedbutton_underline(sb#)` | Gets underline state (0/1) |
| `speedbutton_underline#(sb#, state)` | Sets underline state |
| `speedbutton_strikeout(sb#)` | Gets strikeout state (0/1) |
| `speedbutton_strikeout#(sb#, state)` | Sets strikeout state |

**Example:**
```basic
speedbutton_fontfamily#(sb#, "Arial")
speedbutton_fontsize#(sb#, 12)
speedbutton_bold#(sb#, 1)
speedbutton_fontcolor#(sb#, "#FF0000")
```

**Note:** Setting font properties automatically clears the corresponding StyledSettings flag to allow programmatic control.

### SpeedButton-Specific Properties

| Function | Description |
|----------|-------------|
| `speedbutton_groupindex(sb#)` | Gets the group index (0 = no group) |
| `speedbutton_groupindex#(sb#, index)` | Sets the group index |
| `speedbutton_stayspressed(sb#)` | Gets StaysPressed state (0/1) |
| `speedbutton_stayspressed#(sb#, state)` | Sets StaysPressed state |
| `speedbutton_down(sb#)` | Gets the pressed/down state (0/1) |
| `speedbutton_down#(sb#, state)` | Sets the pressed/down state |

**Example - Toggle Buttons:**
```basic
' Create independent toggle buttons (each can be toggled independently)
let sbBold# = speedbutton#(frm#, "B")
speedbutton_stayspressed#(sbBold#, 1)
speedbutton_groupindex#(sbBold#, 0)

let sbItalic# = speedbutton#(frm#, "I")
speedbutton_stayspressed#(sbItalic#, 1)
speedbutton_groupindex#(sbItalic#, 0)
```

**Example - Radio Buttons:**
```basic
' Create mutually exclusive buttons (only one can be pressed at a time)
let sbLeft# = speedbutton#(frm#, "Left")
speedbutton_stayspressed#(sbLeft#, 1)
speedbutton_groupindex#(sbLeft#, 1)
speedbutton_down#(sbLeft#, 1)

let sbCenter# = speedbutton#(frm#, "Center")
speedbutton_stayspressed#(sbCenter#, 1)
speedbutton_groupindex#(sbCenter#, 1)

let sbRight# = speedbutton#(frm#, "Right")
speedbutton_stayspressed#(sbRight#, 1)
speedbutton_groupindex#(sbRight#, 1)
```

### Position and Size

| Function | Description |
|----------|-------------|
| `speedbutton_x(sb#)` | Gets X position |
| `speedbutton_x#(sb#, x)` | Sets X position |
| `speedbutton_y(sb#)` | Gets Y position |
| `speedbutton_y#(sb#, y)` | Sets Y position |
| `speedbutton_width(sb#)` | Gets width |
| `speedbutton_width#(sb#, w)` | Sets width |
| `speedbutton_height(sb#)` | Gets height |
| `speedbutton_height#(sb#, h)` | Sets height |
| `speedbutton_bounds#(sb#, x, y, w, h)` | Sets position and size at once |
| `speedbutton_move#(sb#, x, y)` | Sets position |
| `speedbutton_size#(sb#, w, h)` | Sets size |

### Alignment

| Function | Description |
|----------|-------------|
| `speedbutton_align(sb#)` | Gets the alignment value |
| `speedbutton_align#(sb#, align)` | Sets the alignment |

**Alignment Values:**
- 0 = None (manual positioning)
- 1 = Top
- 2 = Left
- 3 = Right
- 4 = Bottom
- 9 = Client (fill parent)
- 11 = Center

### Margins

| Function | Description |
|----------|-------------|
| `speedbutton_marginleft(sb#)` | Gets left margin |
| `speedbutton_marginleft#(sb#, m)` | Sets left margin |
| `speedbutton_margintop(sb#)` | Gets top margin |
| `speedbutton_margintop#(sb#, m)` | Sets top margin |
| `speedbutton_marginright(sb#)` | Gets right margin |
| `speedbutton_marginright#(sb#, m)` | Sets right margin |
| `speedbutton_marginbottom(sb#)` | Gets bottom margin |
| `speedbutton_marginbottom#(sb#, m)` | Sets bottom margin |
| `speedbutton_margins#(sb#, l, t, r, b)` | Sets all margins at once |
| `speedbutton_margin#(sb#, m)` | Sets all margins to same value |

### Visibility and State

| Function | Description |
|----------|-------------|
| `speedbutton_visible(sb#)` | Gets visibility (0/1) |
| `speedbutton_visible#(sb#, state)` | Sets visibility |
| `speedbutton_enabled(sb#)` | Gets enabled state (0/1) |
| `speedbutton_enabled#(sb#, state)` | Sets enabled state |
| `speedbutton_opacity(sb#)` | Gets opacity (0.0 to 1.0) |
| `speedbutton_opacity#(sb#, value)` | Sets opacity |

### Tag

| Function | Description |
|----------|-------------|
| `speedbutton_tag(sb#)` | Gets the tag value |
| `speedbutton_tag#(sb#, value)` | Sets the tag value |

### HitTest

| Function | Description |
|----------|-------------|
| `speedbutton_hittest(sb#)` | Gets HitTest state (0/1) |
| `speedbutton_hittest#(sb#, state)` | Sets HitTest state |

**Note:** HitTest must be enabled (1) for the button to receive mouse events.

### DragMode

| Function | Description |
|----------|-------------|
| `speedbutton_dragmode(sb#)` | Gets drag mode (0=manual, 1=automatic) |
| `speedbutton_dragmode#(sb#, mode)` | Sets drag mode |

### Parent and Z-Order

| Function | Description |
|----------|-------------|
| `speedbutton_parent#(sb#)` | Gets the parent control |
| `speedbutton_parent#(sb#, parent#)` | Sets the parent control |
| `speedbutton_bringtofront#(sb#)` | Brings speed button to front of z-order |
| `speedbutton_sendtoback#(sb#)` | Sends speed button to back of z-order |

### Event Callbacks

| Function | Description |
|----------|-------------|
| `speedbutton_onclick#(sb#, callback$)` | Sets OnClick callback |
| `speedbutton_onclick$(sb#)` | Gets OnClick callback name |
| `speedbutton_onmousedown#(sb#, callback$)` | Sets OnMouseDown callback |
| `speedbutton_onmousedown$(sb#)` | Gets OnMouseDown callback name |
| `speedbutton_onmouseup#(sb#, callback$)` | Sets OnMouseUp callback |
| `speedbutton_onmouseup$(sb#)` | Gets OnMouseUp callback name |
| `speedbutton_onmousemove#(sb#, callback$)` | Sets OnMouseMove callback |
| `speedbutton_onmousemove$(sb#)` | Gets OnMouseMove callback name |
| `speedbutton_onmouseenter#(sb#, callback$)` | Sets OnMouseEnter callback |
| `speedbutton_onmouseenter$(sb#)` | Gets OnMouseEnter callback name |
| `speedbutton_onmouseleave#(sb#, callback$)` | Sets OnMouseLeave callback |
| `speedbutton_onmouseleave$(sb#)` | Gets OnMouseLeave callback name |
| `speedbutton_onresize#(sb#, callback$)` | Sets OnResize callback |
| `speedbutton_onresize$(sb#)` | Gets OnResize callback name |
| `speedbutton_clearcallbacks#(sb#)` | Clears all event callbacks |

### Drag & Drop Event Callbacks

| Function | Description |
|----------|-------------|
| `speedbutton_ondragenter#(sb#, callback$)` | Sets OnDragEnter callback |
| `speedbutton_ondragenter$(sb#)` | Gets OnDragEnter callback name |
| `speedbutton_ondragover#(sb#, callback$)` | Sets OnDragOver callback |
| `speedbutton_ondragover$(sb#)` | Gets OnDragOver callback name |
| `speedbutton_ondragdrop#(sb#, callback$)` | Sets OnDragDrop callback |
| `speedbutton_ondragdrop$(sb#)` | Gets OnDragDrop callback name |
| `speedbutton_ondragleave#(sb#, callback$)` | Sets OnDragLeave callback |
| `speedbutton_ondragleave$(sb#)` | Gets OnDragLeave callback name |

---

## Event Callback Signatures

### OnClick
```basic
function OnClick(sender#)
  ' sender# = the speed button that was clicked
endfunction
```

### OnMouseDown / OnMouseUp
```basic
function OnMouseDown(sender#, btn, x, y, shift$)
  ' sender# = the speed button
  ' btn = mouse button (0=left, 1=right, 2=middle)
  ' x, y = mouse position relative to button
  ' shift$ = modifier keys ("S"=Shift, "C"=Ctrl, "A"=Alt)
endfunction
```

### OnMouseMove
```basic
function OnMouseMove(sender#, x, y, shift$)
  ' sender# = the speed button
  ' x, y = mouse position relative to button
  ' shift$ = modifier keys
endfunction
```

### OnMouseEnter / OnMouseLeave
```basic
function OnMouseEnter(sender#)
  ' sender# = the speed button
endfunction
```

### OnResize
```basic
function OnResize(sender#)
  ' sender# = the speed button that was resized
endfunction
```

### OnDragEnter / OnDragDrop / OnDragLeave
```basic
function OnDragEnter(sender#, x, y)
  ' sender# = the speed button
  ' x, y = drag position
endfunction
```

### OnDragOver (with return value)
```basic
function OnDragOver(sender#, x, y)
  ' Return non-zero to accept the drop
  return 1
endfunction
```

---

## Color Formats

Colors can be specified in the following formats:
- **Hex with alpha:** `"#AARRGGBB"` (e.g., `"#FF0000FF"` for opaque blue)
- **Hex without alpha:** `"#RRGGBB"` (e.g., `"#FF0000"` for red, alpha defaults to FF)
- **Named colors:** `"black"`, `"white"`, `"red"`, `"green"`, `"blue"`, `"yellow"`, `"gray"`, `"silver"`, `"navy"`, `"maroon"`, `"purple"`, `"orange"`

---

## Complete Example: Toolbar with Toggle Buttons

```basic
' SpeedButton Toolbar Demo
' Demonstrates toggle buttons and grouped buttons

let frm# = form#("SpeedButton Toolbar Demo", 500, 400)

' Create a layout for the toolbar
let toolbar# = layout#(frm#)
layout_align#(toolbar#, 1)
layout_height#(toolbar#, 40)

' Text formatting buttons (independent toggles - GroupIndex = 0)
let sbBold# = speedbutton#(toolbar#, "B")
speedbutton_move#(sbBold#, 5, 5)
speedbutton_size#(sbBold#, 30, 30)
speedbutton_bold#(sbBold#, 1)
speedbutton_stayspressed#(sbBold#, 1)
speedbutton_onclick#(sbBold#, "OnFormatToggle")
speedbutton_tag#(sbBold#, 1)

let sbItalic# = speedbutton#(toolbar#, "I")
speedbutton_move#(sbItalic#, 40, 5)
speedbutton_size#(sbItalic#, 30, 30)
speedbutton_italic#(sbItalic#, 1)
speedbutton_stayspressed#(sbItalic#, 1)
speedbutton_onclick#(sbItalic#, "OnFormatToggle")
speedbutton_tag#(sbItalic#, 2)

let sbUnderline# = speedbutton#(toolbar#, "U")
speedbutton_move#(sbUnderline#, 75, 5)
speedbutton_size#(sbUnderline#, 30, 30)
speedbutton_underline#(sbUnderline#, 1)
speedbutton_stayspressed#(sbUnderline#, 1)
speedbutton_onclick#(sbUnderline#, "OnFormatToggle")
speedbutton_tag#(sbUnderline#, 3)

' Alignment buttons (mutually exclusive - GroupIndex = 1)
let sbLeft# = speedbutton#(toolbar#, "L")
speedbutton_move#(sbLeft#, 120, 5)
speedbutton_size#(sbLeft#, 30, 30)
speedbutton_groupindex#(sbLeft#, 1)
speedbutton_stayspressed#(sbLeft#, 1)
speedbutton_down#(sbLeft#, 1)
speedbutton_onclick#(sbLeft#, "OnAlignChange")
speedbutton_tag#(sbLeft#, 10)

let sbCenter# = speedbutton#(toolbar#, "C")
speedbutton_move#(sbCenter#, 155, 5)
speedbutton_size#(sbCenter#, 30, 30)
speedbutton_groupindex#(sbCenter#, 1)
speedbutton_stayspressed#(sbCenter#, 1)
speedbutton_onclick#(sbCenter#, "OnAlignChange")
speedbutton_tag#(sbCenter#, 11)

let sbRight# = speedbutton#(toolbar#, "R")
speedbutton_move#(sbRight#, 190, 5)
speedbutton_size#(sbRight#, 30, 30)
speedbutton_groupindex#(sbRight#, 1)
speedbutton_stayspressed#(sbRight#, 1)
speedbutton_onclick#(sbRight#, "OnAlignChange")
speedbutton_tag#(sbRight#, 12)

form_show(frm#)
println "Toolbar created. Click buttons to toggle."

' Event handler for format toggles
function OnFormatToggle(sender#)
  local tagVal, state
  let tagVal = speedbutton_tag(sender#)
  let state = speedbutton_down(sender#)
  
  if tagVal = 1 then
    if state = 1 then
      println "Bold: ON"
    else
      println "Bold: OFF"
    endif
  endif
  
  if tagVal = 2 then
    if state = 1 then
      println "Italic: ON"
    else
      println "Italic: OFF"
    endif
  endif
  
  if tagVal = 3 then
    if state = 1 then
      println "Underline: ON"
    else
      println "Underline: OFF"
    endif
  endif
endfunction

' Event handler for alignment changes
function OnAlignChange(sender#)
  local tagVal
  let tagVal = speedbutton_tag(sender#)
  
  if tagVal = 10 then
    println "Alignment: LEFT"
  endif
  
  if tagVal = 11 then
    println "Alignment: CENTER"
  endif
  
  if tagVal = 12 then
    println "Alignment: RIGHT"
  endif
endfunction
```

---

## Integration Steps

1. Add `SpeedButtonLib.pas` to your Delphi project
2. Add `SpeedButtonLib` to the uses clause in your main unit
3. Call `RegisterSpeedButtonFuncs(FunctionsDict, BasicEngine, ConsoleOutput)` during initialization
4. Run test applet to verify everything works

---

## Best Practices

1. **Use GroupIndex for Radio-Button Behavior**: Set the same GroupIndex > 0 for buttons that should be mutually exclusive
2. **Enable StaysPressed for Toggles**: Without StaysPressed, buttons return to unpressed state immediately
3. **Set Initial State**: Use `speedbutton_down#()` to set the initial pressed state for toggle buttons
4. **Use Tags for Identification**: Assign unique tag values to identify buttons in shared event handlers
5. **Clear Callbacks on Cleanup**: Call `speedbutton_clearcallbacks#()` before freeing if events are active
