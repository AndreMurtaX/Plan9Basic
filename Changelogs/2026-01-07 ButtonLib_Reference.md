# ButtonLib - Button Control Library for Plan9Basic

## Overview

ButtonLib provides complete functionality for creating and managing button controls in Plan9Basic programs. Buttons provides the standard clickable button interface with full event support.

**Version:** 1.0.0  
**Function Count:** 92 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Event Connection Model

Events are connected/disconnected individually when callbacks are set:
- Setting a non-empty callback name connects ONLY that specific event
- Setting an empty callback name (`""`) disconnects ONLY that specific event
- No events are connected by default in the constructor

## Quick Start

```basic
' Create a simple button
let frm# = form#("Button Demo", 400, 300)
let btn# = button#(frm#, "Click Me!")
button_move#(btn#, 50, 50)
button_size#(btn#, 120, 40)
button_onclick#(btn#, "OnButtonClick")
form_show(frm#)

function OnButtonClick(sender#)
  println "Button was clicked!"
endfunction
```

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `button_error()` | Returns the last error code (0 = no error) |
| `button_errormsg$()` | Returns the last error message |
| `button_strerror$(code)` | Converts error code to human-readable message |
| `button_clearerror()` | Clears the last error |

**Error Codes:**
- 0 = No error
- 1 = Invalid button
- 2 = Invalid parent
- 3 = Invalid value
- 4 = Create failed

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `button#(parent#)` | Creates a button with default text "Button" |
| `button#(parent#, text$)` | Creates a button with specified text |
| `button#(parent#, x, y, w, h)` | Creates a button at position with size |
| `button#(parent#, text$, x, y, w, h)` | Creates a button with text, position, and size |
| `button_free(btn#)` | Destroys the button and releases resources |

**Example:**
```basic
' Different creation methods
let btn1# = button#(frm#)                        ' Default button
let btn2# = button#(frm#, "Save")                ' With text
let btn3# = button#(frm#, 10, 10, 100, 30)       ' With position/size
let btn4# = button#(frm#, "Cancel", 10, 50, 100, 30) ' Full creation
```

### Text Content

| Function | Description |
|----------|-------------|
| `button_text$(btn#)` | Gets the button text (caption) |
| `button_text#(btn#, text$)` | Sets the button text |

**Example:**
```basic
button_text#(btn#, "Save Document")
let caption$ = button_text$(btn#)
println "Button says: " + caption$
```

### Font Properties

| Function | Description |
|----------|-------------|
| `button_fontfamily$(btn#)` | Gets the font family name |
| `button_fontfamily#(btn#, family$)` | Sets the font family |
| `button_fontsize(btn#)` | Gets the font size |
| `button_fontsize#(btn#, size)` | Sets the font size |
| `button_fontcolor$(btn#)` | Gets the font color as hex string |
| `button_fontcolor#(btn#, color$)` | Sets the font color |
| `button_bold(btn#)` | Gets bold state (0/1) |
| `button_bold#(btn#, state)` | Sets bold state |
| `button_italic(btn#)` | Gets italic state (0/1) |
| `button_italic#(btn#, state)` | Sets italic state |
| `button_underline(btn#)` | Gets underline state (0/1) |
| `button_underline#(btn#, state)` | Sets underline state |
| `button_strikeout(btn#)` | Gets strikeout state (0/1) |
| `button_strikeout#(btn#, state)` | Sets strikeout state |

**Color Formats:**
- Hex with alpha: `"#FFFF0000"` (red, fully opaque)
- Hex without alpha: `"#FF0000"` (red)
- Named colors: `"black"`, `"white"`, `"red"`, `"green"`, `"blue"`, `"yellow"`, `"gray"`, `"silver"`, `"navy"`, `"maroon"`, `"purple"`, `"orange"`

**Example:**
```basic
button_fontfamily#(btn#, "Arial")
button_fontsize#(btn#, 14)
button_fontcolor#(btn#, "blue")
button_bold#(btn#, 1)
```

### Button-Specific Properties

| Function | Description |
|----------|-------------|
| `button_modalresult(btn#)` | Gets the modal result value |
| `button_modalresult#(btn#, value)` | Sets the modal result value |
| `button_default(btn#)` | Gets if button is the default button (0/1) |
| `button_default#(btn#, state)` | Sets as default button (responds to Enter key) |
| `button_cancel(btn#)` | Gets if button is the cancel button (0/1) |
| `button_cancel#(btn#, state)` | Sets as cancel button (responds to Escape key) |

**Modal Result Values:**
| Value | Constant |
|-------|----------|
| 0 | mrNone |
| 1 | mrOk |
| 2 | mrCancel |
| 3 | mrAbort |
| 4 | mrRetry |
| 5 | mrIgnore |
| 6 | mrYes |
| 7 | mrNo |
| 8 | mrClose |
| 9 | mrHelp |
| 10 | mrTryAgain |
| 11 | mrContinue |
| 12 | mrAll |
| 13 | mrNoToAll |
| 14 | mrYesToAll |

**Example:**
```basic
' Create OK and Cancel buttons for a dialog
let btnOK# = button#(frm#, "OK")
button_modalresult#(btnOK#, 1)  ' mrOk
button_default#(btnOK#, 1)      ' Responds to Enter

let btnCancel# = button#(frm#, "Cancel")
button_modalresult#(btnCancel#, 2)  ' mrCancel
button_cancel#(btnCancel#, 1)       ' Responds to Escape
```

### Position and Size

| Function | Description |
|----------|-------------|
| `button_x(btn#)` | Gets X position |
| `button_x#(btn#, x)` | Sets X position |
| `button_y(btn#)` | Gets Y position |
| `button_y#(btn#, y)` | Sets Y position |
| `button_width(btn#)` | Gets width |
| `button_width#(btn#, w)` | Sets width |
| `button_height(btn#)` | Gets height |
| `button_height#(btn#, h)` | Sets height |
| `button_bounds#(btn#, x, y, w, h)` | Sets position and size at once |
| `button_move#(btn#, x, y)` | Sets position only |
| `button_size#(btn#, w, h)` | Sets size only |

**Example:**
```basic
button_move#(btn#, 100, 50)
button_size#(btn#, 120, 35)
' Or all at once:
button_bounds#(btn#, 100, 50, 120, 35)
```

### Alignment

| Function | Description |
|----------|-------------|
| `button_align(btn#)` | Gets alignment |
| `button_align#(btn#, align)` | Sets alignment |

**Alignment Values:**
| Value | Alignment |
|-------|-----------|
| 0 | None (absolute positioning) |
| 1 | Top |
| 2 | Left |
| 3 | Right |
| 4 | Bottom |
| 9 | Client (fill parent) |
| 11 | Center |

### Margins

| Function | Description |
|----------|-------------|
| `button_marginleft(btn#)` | Gets left margin |
| `button_marginleft#(btn#, value)` | Sets left margin |
| `button_margintop(btn#)` | Gets top margin |
| `button_margintop#(btn#, value)` | Sets top margin |
| `button_marginright(btn#)` | Gets right margin |
| `button_marginright#(btn#, value)` | Sets right margin |
| `button_marginbottom(btn#)` | Gets bottom margin |
| `button_marginbottom#(btn#, value)` | Sets bottom margin |
| `button_margins#(btn#, l, t, r, b)` | Sets all four margins |
| `button_margin#(btn#, value)` | Sets all margins to same value |

**Example:**
```basic
button_align#(btn#, 1)  ' Align to top
button_margins#(btn#, 10, 10, 10, 0)  ' With margins
```

### Visibility and State

| Function | Description |
|----------|-------------|
| `button_visible(btn#)` | Gets visibility (0/1) |
| `button_visible#(btn#, state)` | Sets visibility |
| `button_enabled(btn#)` | Gets enabled state (0/1) |
| `button_enabled#(btn#, state)` | Sets enabled state |
| `button_opacity(btn#)` | Gets opacity (0.0 to 1.0) |
| `button_opacity#(btn#, value)` | Sets opacity |

**Example:**
```basic
button_enabled#(btn#, 0)  ' Disable button (grayed out)
button_opacity#(btn#, 0.5)  ' 50% transparent
```

### Focus

| Function | Description |
|----------|-------------|
| `button_isfocused(btn#)` | Gets if button has focus (0/1) |
| `button_setfocus#(btn#)` | Sets focus to the button |
| `button_resetfocus#(btn#)` | Removes focus from the button |
| `button_taborder(btn#)` | Gets tab order |
| `button_taborder#(btn#, order)` | Sets tab order |
| `button_canfocus(btn#)` | Gets if button can receive focus (0/1) |
| `button_canfocus#(btn#, state)` | Sets if button can receive focus |

### Other Properties

| Function | Description |
|----------|-------------|
| `button_tag(btn#)` | Gets the tag value (user-defined integer) |
| `button_tag#(btn#, value)` | Sets the tag value |
| `button_hittest(btn#)` | Gets hit test state (0/1) |
| `button_hittest#(btn#, state)` | Sets hit test (required for some mouse events) |
| `button_dragmode(btn#)` | Gets drag mode (0=manual, 1=automatic) |
| `button_dragmode#(btn#, mode)` | Sets drag mode |

### Parent and Z-Order

| Function | Description |
|----------|-------------|
| `button_parent#(btn#)` | Gets the parent control |
| `button_parent#(btn#, parent#)` | Sets the parent control |
| `button_bringtofront#(btn#)` | Brings button to front of z-order |
| `button_sendtoback#(btn#)` | Sends button to back of z-order |

---

## Event Callbacks

### Setting and Getting Callbacks

| Function | Description |
|----------|-------------|
| `button_onclick#(btn#, funcname$)` | Sets OnClick handler |
| `button_onclick$(btn#)` | Gets OnClick handler name |
| `button_onenter#(btn#, funcname$)` | Sets OnEnter (focus gained) handler |
| `button_onenter$(btn#)` | Gets OnEnter handler name |
| `button_onexit#(btn#, funcname$)` | Sets OnExit (focus lost) handler |
| `button_onexit$(btn#)` | Gets OnExit handler name |
| `button_onkeydown#(btn#, funcname$)` | Sets OnKeyDown handler |
| `button_onkeydown$(btn#)` | Gets OnKeyDown handler name |
| `button_onkeyup#(btn#, funcname$)` | Sets OnKeyUp handler |
| `button_onkeyup$(btn#)` | Gets OnKeyUp handler name |
| `button_onmousedown#(btn#, funcname$)` | Sets OnMouseDown handler |
| `button_onmousedown$(btn#)` | Gets OnMouseDown handler name |
| `button_onmouseup#(btn#, funcname$)` | Sets OnMouseUp handler |
| `button_onmouseup$(btn#)` | Gets OnMouseUp handler name |
| `button_onmousemove#(btn#, funcname$)` | Sets OnMouseMove handler |
| `button_onmousemove$(btn#)` | Gets OnMouseMove handler name |
| `button_onmouseenter#(btn#, funcname$)` | Sets OnMouseEnter handler |
| `button_onmouseenter$(btn#)` | Gets OnMouseEnter handler name |
| `button_onmouseleave#(btn#, funcname$)` | Sets OnMouseLeave handler |
| `button_onmouseleave$(btn#)` | Gets OnMouseLeave handler name |
| `button_onresize#(btn#, funcname$)` | Sets OnResize handler |
| `button_onresize$(btn#)` | Gets OnResize handler name |
| `button_clearcallbacks#(btn#)` | Clears all event handlers |

### Drag & Drop Event Callbacks

| Function | Description |
|----------|-------------|
| `button_ondragenter#(btn#, funcname$)` | Sets OnDragEnter handler |
| `button_ondragenter$(btn#)` | Gets OnDragEnter handler name |
| `button_ondragover#(btn#, funcname$)` | Sets OnDragOver handler |
| `button_ondragover$(btn#)` | Gets OnDragOver handler name |
| `button_ondragdrop#(btn#, funcname$)` | Sets OnDragDrop handler |
| `button_ondragdrop$(btn#)` | Gets OnDragDrop handler name |
| `button_ondragleave#(btn#, funcname$)` | Sets OnDragLeave handler |
| `button_ondragleave$(btn#)` | Gets OnDragLeave handler name |

### Event Callback Signatures

| Event | Signature | Parameters |
|-------|-----------|------------|
| OnClick | `function(sender#)` | sender# = button pointer |
| OnEnter | `function(sender#)` | sender# = button pointer |
| OnExit | `function(sender#)` | sender# = button pointer |
| OnKeyDown | `function(sender#, key, keychar$, shift$)` | key = virtual key code, keychar$ = character, shift$ = modifier keys |
| OnKeyUp | `function(sender#, key, keychar$, shift$)` | key = virtual key code, keychar$ = character, shift$ = modifier keys |
| OnMouseDown | `function(sender#, button, x, y, shift$)` | button = 0/1/2 (left/right/middle), x/y = position, shift$ = modifier keys |
| OnMouseUp | `function(sender#, button, x, y, shift$)` | button = 0/1/2 (left/right/middle), x/y = position, shift$ = modifier keys |
| OnMouseMove | `function(sender#, x, y, shift$)` | x/y = position, shift$ = modifier keys |
| OnMouseEnter | `function(sender#)` | sender# = button pointer |
| OnMouseLeave | `function(sender#)` | sender# = button pointer |
| OnResize | `function(sender#)` | sender# = button pointer |
| OnDragEnter | `function(sender#, x, y)` | x/y = position |
| OnDragOver | `function(sender#, x, y)` | x/y = position; return non-zero to accept drop |
| OnDragDrop | `function(sender#, x, y)` | x/y = position |
| OnDragLeave | `function(sender#)` | sender# = button pointer |

**Shift String Values:**
- `"S"` = Shift key held
- `"C"` = Control key held
- `"A"` = Alt key held
- Combinations: `"SC"` = Shift+Control, `"SCA"` = All three, etc.

---

## Best Practices

1. **Always set an OnClick handler** - Buttons without click handlers serve little purpose.

2. **Use meaningful button text** - Button text should clearly indicate the action.

3. **Set Default/Cancel for dialogs** - Improves keyboard navigation.

4. **Clear callbacks before freeing** - Use `button_clearcallbacks#()` before `button_free()`.

5. **Use Tag for identification** - When handling multiple buttons with one callback, use Tag to identify them.

6. **Consider tab order** - Set logical tab order for keyboard navigation.

---

## Version History

### 1.0.0 (2025)
- Initial release
- 92 functions
- Full event support including drag & drop
- Granular event connection model
- Cross-platform support
