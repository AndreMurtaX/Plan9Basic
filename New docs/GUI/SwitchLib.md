# SwitchLib - Switch Control Library for Plan9Basic

## Overview

SwitchLib provides functionality for creating and managing switch (toggle) controls in Plan9Basic programs. Switch controls provide a modern on/off toggle interface, ideal for settings and preferences.

**Version:** 1.0.0  
**Function Count:** 90+ functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("Switch Demo", 400, 300)
form_position#(frm#, 4)

let lbl# = label#(frm#, "Enable Notifications:")
label_move#(lbl#, 20, 50)

let sw# = switch#(frm#, 180, 45, 50, 25)
switch_onswitch#(sw#, "OnSwitchChanged")

let lblStatus# = label#(frm#, "Status: OFF")
label_move#(lblStatus#, 20, 100)

form_show(frm#)

function OnSwitchChanged(sender#)
  if switch_ischecked(sender#) = 1 then
    label_text#(lblStatus#, "Status: ON")
  else
    label_text#(lblStatus#, "Status: OFF")
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

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `switch_error()` | Returns last error code (0 = no error) |
| `switch_errormsg$()` | Returns last error message |
| `switch_strerror$(code)` | Converts error code to message |
| `switch_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `switch#(parent#)` | Create with default size |
| `switch#(parent#, x, y, w, h)` | Create with position and size |
| `switch_free(sw#)` | Destroy switch |

### Checked State

| Function | Description |
|----------|-------------|
| `switch_ischecked(sw#)` | Get checked state (0=off, 1=on) |
| `switch_ischecked#(sw#, value)` | Set checked state |
| `switch_toggle#(sw#)` | Toggle current state |

### Position and Size

| Function | Description |
|----------|-------------|
| `switch_x(sw#)` / `switch_x#(sw#, x)` | Get/set X position |
| `switch_y(sw#)` / `switch_y#(sw#, y)` | Get/set Y position |
| `switch_width(sw#)` / `switch_width#(sw#, w)` | Get/set width |
| `switch_height(sw#)` / `switch_height#(sw#, h)` | Get/set height |
| `switch_bounds#(sw#, x, y, w, h)` | Set position and size |
| `switch_move#(sw#, x, y)` | Set position only |
| `switch_size#(sw#, w, h)` | Set size only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `switch_align(sw#)` / `switch_align#(sw#, value)` | Get/set alignment |
| `switch_marginleft(sw#)` / `switch_marginleft#(sw#, value)` | Get/set left margin |
| `switch_margintop(sw#)` / `switch_margintop#(sw#, value)` | Get/set top margin |
| `switch_marginright(sw#)` / `switch_marginright#(sw#, value)` | Get/set right margin |
| `switch_marginbottom(sw#)` / `switch_marginbottom#(sw#, value)` | Get/set bottom margin |
| `switch_margins#(sw#, l, t, r, b)` | Set all margins |
| `switch_margin#(sw#, value)` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `switch_visible(sw#)` / `switch_visible#(sw#, value)` | Get/set visibility (0/1) |
| `switch_enabled(sw#)` / `switch_enabled#(sw#, value)` | Get/set enabled state (0/1) |
| `switch_opacity(sw#)` / `switch_opacity#(sw#, value)` | Get/set opacity (0.0-1.0) |
| `switch_hittest(sw#)` / `switch_hittest#(sw#, value)` | Get/set hit test (0/1) |
| `switch_dragmode(sw#)` / `switch_dragmode#(sw#, value)` | Get/set drag mode (0/1) |

### Focus

| Function | Description |
|----------|-------------|
| `switch_isfocused(sw#)` | Check if focused (0/1) |
| `switch_setfocus#(sw#)` | Set focus to switch |
| `switch_resetfocus#(sw#)` | Remove focus from switch |
| `switch_taborder(sw#)` / `switch_taborder#(sw#, value)` | Get/set tab order |
| `switch_canfocus(sw#)` / `switch_canfocus#(sw#, value)` | Get/set can focus (0/1) |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `switch_tag(sw#)` / `switch_tag#(sw#, value)` | Get/set tag value |
| `switch_parent#(sw#)` | Get parent |
| `switch_parent#(sw#, parent#)` | Set parent |
| `switch_bringtofront#(sw#)` | Bring to front |
| `switch_sendtoback#(sw#)` | Send to back |

---

## Event Callbacks

### Basic Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnSwitch | `switch_onswitch#(sw#, func$)` | `switch_onswitch$(sw#)` | `function(sender#)` |
| OnClick | `switch_onclick#(sw#, func$)` | `switch_onclick$(sw#)` | `function(sender#)` |
| OnDblClick | `switch_ondblclick#(sw#, func$)` | `switch_ondblclick$(sw#)` | `function(sender#)` |
| OnEnter | `switch_onenter#(sw#, func$)` | `switch_onenter$(sw#)` | `function(sender#)` |
| OnExit | `switch_onexit#(sw#, func$)` | `switch_onexit$(sw#)` | `function(sender#)` |
| OnResize | `switch_onresize#(sw#, func$)` | `switch_onresize$(sw#)` | `function(sender#)` |

### Keyboard Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnKeyDown | `switch_onkeydown#(sw#, func$)` | `switch_onkeydown$(sw#)` | `function(sender#, key, keychar$, shift$)` |
| OnKeyUp | `switch_onkeyup#(sw#, func$)` | `switch_onkeyup$(sw#)` | `function(sender#, key, keychar$, shift$)` |

### Mouse Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnMouseDown | `switch_onmousedown#(sw#, func$)` | `switch_onmousedown$(sw#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `switch_onmouseup#(sw#, func$)` | `switch_onmouseup$(sw#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `switch_onmousemove#(sw#, func$)` | `switch_onmousemove$(sw#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `switch_onmouseenter#(sw#, func$)` | `switch_onmouseenter$(sw#)` | `function(sender#)` |
| OnMouseLeave | `switch_onmouseleave#(sw#, func$)` | `switch_onmouseleave$(sw#)` | `function(sender#)` |

### Drag Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnDragEnter | `switch_ondragenter#(sw#, func$)` | `switch_ondragenter$(sw#)` | `function(sender#, x, y)` |
| OnDragOver | `switch_ondragover#(sw#, func$)` | `switch_ondragover$(sw#)` | `function(sender#, x, y)` |
| OnDragDrop | `switch_ondragdrop#(sw#, func$)` | `switch_ondragdrop$(sw#)` | `function(sender#, x, y)` |
| OnDragLeave | `switch_ondragleave#(sw#, func$)` | `switch_ondragleave$(sw#)` | `function(sender#)` |

### Utility

| Function | Description |
|----------|-------------|
| `switch_clearcallbacks#(sw#)` | Disconnect all event callbacks |



### OnSwitch vs OnClick

- **OnSwitch** - Fires when the switch state actually changes (on to off or vice versa)
- **OnClick** - Fires on any click, regardless of state change

---

## Complete Examples

### Settings Panel

```basic
let frm# = form#("Settings", 400, 350)
form_position#(frm#, 4)

let lblTitle# = label#(frm#, "Application Settings")
label_move#(lblTitle#, 20, 15)
label_fontsize#(lblTitle#, 16)
label_bold#(lblTitle#, 1)

' Notification setting
let lblNotif# = label#(frm#, "Enable Notifications")
label_move#(lblNotif#, 20, 60)
let swNotif# = switch#(frm#, 300, 55, 50, 25)

' Sound setting
let lblSound# = label#(frm#, "Sound Effects")
label_move#(lblSound#, 20, 100)
let swSound# = switch#(frm#, 300, 95, 50, 25)

' Dark mode setting
let lblDark# = label#(frm#, "Dark Mode")
label_move#(lblDark#, 20, 140)
let swDark# = switch#(frm#, 300, 135, 50, 25)

' Auto-save setting
let lblSave# = label#(frm#, "Auto-Save")
label_move#(lblSave#, 20, 180)
let swSave# = switch#(frm#, 300, 175, 50, 25)
switch_ischecked#(swSave#, 1)

let btnApply# = button#(frm#, "Apply Settings", 140, 240, 120, 35)
button_onclick#(btnApply#, "OnApply")

form_show(frm#)

function OnApply(sender#) local settings$
  settings$ = "Settings:" + chr$(10)
  
  if switch_ischecked(swNotif#) = 1 then
    settings$ = settings$ + "Notifications: ON" + chr$(10)
  else
    settings$ = settings$ + "Notifications: OFF" + chr$(10)
  endif
  
  if switch_ischecked(swSound#) = 1 then
    settings$ = settings$ + "Sound: ON" + chr$(10)
  else
    settings$ = settings$ + "Sound: OFF" + chr$(10)
  endif
  
  if switch_ischecked(swDark#) = 1 then
    settings$ = settings$ + "Dark Mode: ON" + chr$(10)
  else
    settings$ = settings$ + "Dark Mode: OFF" + chr$(10)
  endif
  
  if switch_ischecked(swSave#) = 1 then
    settings$ = settings$ + "Auto-Save: ON"
  else
    settings$ = settings$ + "Auto-Save: OFF"
  endif
  
  println settings$
endfunction
```

### Interactive Toggle Demo

```basic
let frm# = form#("Toggle Demo", 350, 250)
form_position#(frm#, 4)

let sw# = switch#(frm#, 125, 50, 100, 40)

let lblState# = label#(frm#, "OFF")
label_move#(lblState#, 150, 110)
label_fontsize#(lblState#, 24)
label_bold#(lblState#, 1)
label_fontcolor#(lblState#, "#FF0000")

let btnToggle# = button#(frm#, "Toggle", 125, 170, 100, 35)

switch_onswitch#(sw#, "OnSwitchChange")
button_onclick#(btnToggle#, "OnToggle")

form_show(frm#)

function OnSwitchChange(sender#)
  if switch_ischecked(sender#) = 1 then
    label_text#(lblState#, "ON")
    label_fontcolor#(lblState#, "#00AA00")
  else
    label_text#(lblState#, "OFF")
    label_fontcolor#(lblState#, "#FF0000")
  endif
endfunction

function OnToggle(sender#)
  switch_toggle#(sw#)
endfunction
```

### Feature Toggles with Dependencies

```basic
let frm# = form#("Feature Toggles", 400, 300)
form_position#(frm#, 4)

' Master switch
let lblMaster# = label#(frm#, "Enable All Features")
label_move#(lblMaster#, 20, 30)
label_bold#(lblMaster#, 1)
let swMaster# = switch#(frm#, 300, 25, 50, 25)

' Feature A
let lblA# = label#(frm#, "  Feature A")
label_move#(lblA#, 20, 70)
let swA# = switch#(frm#, 300, 65, 50, 25)
switch_enabled#(swA#, 0)

' Feature B
let lblB# = label#(frm#, "  Feature B")
label_move#(lblB#, 20, 110)
let swB# = switch#(frm#, 300, 105, 50, 25)
switch_enabled#(swB#, 0)

' Feature C
let lblC# = label#(frm#, "  Feature C")
label_move#(lblC#, 20, 150)
let swC# = switch#(frm#, 300, 145, 50, 25)
switch_enabled#(swC#, 0)

switch_onswitch#(swMaster#, "OnMasterSwitch")

form_show(frm#)

function OnMasterSwitch(sender#) local enabled
  enabled = switch_ischecked(sender#)
  
  switch_enabled#(swA#, enabled)
  switch_enabled#(swB#, enabled)
  switch_enabled#(swC#, enabled)
  
  if enabled = 0 then
    ' Turn off all sub-features when master is disabled
    switch_ischecked#(swA#, 0)
    switch_ischecked#(swB#, 0)
    switch_ischecked#(swC#, 0)
  endif
endfunction
```

### Real-Time Preview

```basic
let frm# = form#("Preview Demo", 400, 300)
form_position#(frm#, 4)

' Preview area using rectangle for background
let rectPreview# = rectangle#(frm#, 150, 20, 230, 150)
rectangle_fill#(rectPreview#, "#FFFFFF")

let lblPreview# = label#(frm#, "Preview Text")
label_bounds#(lblPreview#, 160, 80, 210, 30)
label_textalign#(lblPreview#, 0)

' Toggle options
let lblBold# = label#(frm#, "Bold")
label_move#(lblBold#, 20, 30)
let swBold# = switch#(frm#, 80, 25, 50, 25)

let lblItalic# = label#(frm#, "Italic")
label_move#(lblItalic#, 20, 70)
let swItalic# = switch#(frm#, 80, 65, 50, 25)

let lblLarge# = label#(frm#, "Large")
label_move#(lblLarge#, 20, 110)
let swLarge# = switch#(frm#, 80, 105, 50, 25)

switch_onswitch#(swBold#, "UpdatePreview")
switch_onswitch#(swItalic#, "UpdatePreview")
switch_onswitch#(swLarge#, "UpdatePreview")

form_show(frm#)

function UpdatePreview(sender#)
  label_bold#(lblPreview#, switch_ischecked(swBold#))
  label_italic#(lblPreview#, switch_ischecked(swItalic#))
  
  if switch_ischecked(swLarge#) = 1 then
    label_fontsize#(lblPreview#, 20)
  else
    label_fontsize#(lblPreview#, 14)
  endif
endfunction
```

---

## Tips and Best Practices

1. **Use OnSwitch for state changes** - It only fires when the state actually changes
2. **Pair with labels** - Switch controls don't have built-in text; use a Label
3. **Use switch_toggle# for programmatic toggle** - Easier than reading and setting state
4. **Default size is small** - Consider using larger dimensions for touch interfaces
5. **Disable dependent controls** - Use `switch_enabled#` to disable sub-options
6. **Visual feedback is automatic** - Switch animates between on/off states

---

## See Also

- **CheckBoxLib** - Traditional checkbox controls
- **RadioButtonLib** - Radio button controls
- **ButtonLib** - Standard push buttons

---

*SwitchLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
