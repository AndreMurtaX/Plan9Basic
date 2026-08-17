# FormLib - Form Management Library for Plan9Basic

## Overview

FormLib provides complete functionality for creating and managing application windows in Plan9Basic programs.

**Version:** 1.2.0
**Function Count:** 105 functions

## Cross-Platform Support

FormLib is designed for full cross-platform compatibility:

| Platform | Status | Notes |
|----------|--------|-------|
| **Windows** | Full Support | Win32/Win64 |
| **macOS** | Full Support | Intel/ARM (Apple Silicon) |
| **Linux** | Full Support | GTK-based |
| **Android** | Full Support | Mobile-optimized |
| **iOS** | Full Support | iPhone/iPad |

---

## Features

- **Form Lifecycle Management**: Create, show, hide, and destroy forms
- **Comprehensive Properties**: Position, size, colors, borders, constraints
- **Modal Support**: Both modal and non-modal display modes
- **Complete Event System**: 11 events with BASIC callback integration
- **Cross-Platform**: Works on Windows, macOS, Linux, Android, iOS

---

## Numeric Values Reference

Plan9Basic does not have built-in constants. The following tables document the numeric values accepted by various functions.

**Optional: Define your own named values:**
```basic
' Position modes
let POS_SCREEN_CENTER = 4

' Border styles
let BORDER_NONE = 0
let BORDER_SIZEABLE = 2

' Close actions
let ACTION_HIDE = 1
let ACTION_FREE = 2
```

### Position Modes (for form_position#)

| Value | Description |
|-------|-------------|
| 0 | Use design-time position |
| 4 | Center on screen |
| 5 | Center on desktop |
| 6 | Center on main form |

### Border Styles (for form_borderstyle#)

| Value | Description |
|-------|-------------|
| 0 | No border |
| 1 | Single-line border (non-resizable) |
| 2 | Standard resizable border |
| 3 | Tool window style |
| 4 | Resizable tool window |

### Close Actions (for form_closeaction#)

| Value | Description |
|-------|-------------|
| 0 | No action (form stays open) |
| 1 | Hide the form |
| 2 | Free/destroy the form |
| 3 | Minimize the form |

### Window States (for form_windowstate#)

| Value | Description |
|-------|-------------|
| 0 | Normal window state |
| 1 | Minimized to taskbar |
| 2 | Maximized to fill screen |

---

## Quick Start

```basic
' Create a simple window (event-driven pattern)
let frm# = form#("Hello World", 400, 300)
form_position#(frm#, 4)
form_fill#(frm#, "#F0F0F0")
form_show(frm#)

' Main loop - keeps application running
while form_visible(frm#) = 1
  processmessages()
end while

form_free(frm#)
```

---

## Error Handling

| Function | Description |
|----------|-------------|
| `form_error()` | Returns last error code (0 = no error) |
| `form_errormsg$()` | Returns last error message |
| `form_strerror$(code)` | Returns description for error code |
| `form_clearerror()` | Clears error state |

**Error Codes:**
- 0 = No error
- 1 = Invalid or nil form
- 2 = Invalid property
- 3 = Invalid value
- 4 = Form creation failed
- 5 = Invalid callback function

---

## Form Creation and Destruction

| Function | Description |
|----------|-------------|
| `form#()` | Create form with defaults (640x480, centered) |
| `form#(caption$)` | Create form with caption |
| `form#(caption$, width, height)` | Create form with caption and size |
| `form_free(frm#)` | Destroy and release form |
| `form_close(frm#)` | Close form (triggers events) |

---

## Form Display

| Function | Description |
|----------|-------------|
| `form_show(frm#)` | Show form non-modally |
| `form_showmodal(frm#)` | Show modally (desktop only) |
| `form_showex#(frm#, callback$)` | Show with close callback |
| `form_hide(frm#)` | Hide form |
| `form_visible(frm#)` | Get visibility (0/1) |
| `form_visible#(frm#, value)` | Set visibility |

**Example - Cross-platform dialog:**
```basic
function OnDialogClosed(sender#, result)
  if result = 1 then
    println "User clicked OK"
  endif
endfunction

let dlg# = form#("Confirm", 300, 150)
form_showex#(dlg#, "OnDialogClosed")
```

---

## Position and Size

| Function | Description |
|----------|-------------|
| `form_left(frm#)` / `form_left#(frm#, x)` | Get/set X position |
| `form_top(frm#)` / `form_top#(frm#, y)` | Get/set Y position |
| `form_width(frm#)` / `form_width#(frm#, w)` | Get/set width |
| `form_height(frm#)` / `form_height#(frm#, h)` | Get/set height |
| `form_bounds#(frm#, x, y, w, h)` | Set position and size |
| `form_move#(frm#, x, y)` | Set position only |
| `form_size#(frm#, w, h)` | Set size only |
| `form_center#(frm#)` | Center on screen |
| `form_clientwidth(frm#)` | Get client area width |
| `form_clientheight(frm#)` | Get client area height |

---

## Size Constraints

| Function | Description |
|----------|-------------|
| `form_minwidth(frm#)` / `form_minwidth#(frm#, w)` | Get/set minimum width |
| `form_minheight(frm#)` / `form_minheight#(frm#, h)` | Get/set minimum height |
| `form_maxwidth(frm#)` / `form_maxwidth#(frm#, w)` | Get/set maximum width |
| `form_maxheight(frm#)` / `form_maxheight#(frm#, h)` | Get/set maximum height |
| `form_constraints#(frm#, minW, minH, maxW, maxH)` | Set all constraints at once |

---

## Window State and Style

| Function | Description |
|----------|-------------|
| `form_windowstate(frm#)` / `form_windowstate#(frm#, n)` | Get/set state (0=normal, 1=min, 2=max) |
| `form_maximize#(frm#)` | Maximize |
| `form_minimize#(frm#)` | Minimize |
| `form_restore#(frm#)` | Restore |
| `form_borderstyle(frm#)` / `form_borderstyle#(frm#, n)` | Get/set border style |
| `form_stayontop(frm#)` / `form_stayontop#(frm#, n)` | Get/set always on top |
| `form_fullscreen(frm#)` / `form_fullscreen#(frm#, n)` | Get/set fullscreen mode |
| `form_showfullscreenicon(frm#)` / `form_showfullscreenicon#(frm#, n)` | Get/set fullscreen icon visibility |
| `form_formstyle(frm#)` / `form_formstyle#(frm#, n)` | Get/set form style |

---

## Appearance

| Function | Description |
|----------|-------------|
| `form_caption$(frm#)` / `form_caption#(frm#, s$)` | Get/set title |
| `form_fill$(frm#)` / `form_fill#(frm#, color$)` | Get/set background color |
| `form_transparency(frm#)` / `form_transparency#(frm#, value)` | Get/set transparency (0.0-1.0) |

**Color Formats:**
- Hex: `"#RRGGBB"` or `"#AARRGGBB"`
- Named: `"red"`, `"blue"`, `"white"`, etc.

---

## Close Behavior

| Function | Description |
|----------|-------------|
| `form_closeaction(frm#)` / `form_closeaction#(frm#, n)` | Get/set close action (0=none, 1=hide, 2=free) |
| `form_allowclose(frm#)` / `form_allowclose#(frm#, n)` | Get/set allow closing |
| `form_modalresult(frm#)` / `form_modalresult#(frm#, n)` | Get/set modal result |

---

## Focus and Z-Order

| Function | Description |
|----------|-------------|
| `form_active(frm#)` | Get active state (0/1) |
| `form_bringtofront#(frm#)` | Bring form to front |
| `form_sendtoback#(frm#)` | Send form to back |
| `form_setfocus#(frm#)` | Set input focus to form |
| `form_invalidate#(frm#)` | Force repaint |
| `form_clearcallbacks#(frm#)` | Disconnects all event callbacks |
| `form_handle(frm#)` | Get native window handle |

---

## Padding

| Function | Description |
|----------|-------------|
| `form_padding(frm#)` / `form_padding#(frm#, n)` | Get/set uniform padding |
| `form_paddings#(frm#, l, t, r, b)` | Set individual padding values |

---

## Tag

| Function | Description |
|----------|-------------|
| `form_tag(frm#)` / `form_tag#(frm#, n)` | Get/set tag value |

---

## Position Mode

| Function | Description |
|----------|-------------|
| `form_position(frm#)` / `form_position#(frm#, n)` | Get/set position mode |

---

## Screen Information

| Function | Description |
|----------|-------------|
| `form_screenwidth()` | Screen width in pixels |
| `form_screenheight()` | Screen height in pixels |
| `form_screenscale()` | Scale factor (1.0 = standard) |
| `form_screenorientation()` | Orientation (0=portrait, 1=landscape) |

---

## Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnShow | `form_onshow#(frm#, func$)` | `form_onshow$(frm#)` | `function(sender#)` |
| OnHide | `form_onhide#(frm#, func$)` | `form_onhide$(frm#)` | `function(sender#)` |
| OnClose | `form_onclose#(frm#, func$)` | `form_onclose$(frm#)` | `function(sender#, action)` |
| OnCloseQuery | `form_onclosequery#(frm#, func$)` | `form_onclosequery$(frm#)` | `function(sender#)` → return 0/1 |
| OnActivate | `form_onactivate#(frm#, func$)` | `form_onactivate$(frm#)` | `function(sender#)` |
| OnDeactivate | `form_ondeactivate#(frm#, func$)` | `form_ondeactivate$(frm#)` | `function(sender#)` |
| OnResize | `form_onresize#(frm#, func$)` | `form_onresize$(frm#)` | `function(sender#, width, height)` |
| OnPaint | `form_onpaint#(frm#, func$)` | `form_onpaint$(frm#)` | `function(sender#)` |
| OnKeyDown | `form_onkeydown#(frm#, func$)` | `form_onkeydown$(frm#)` | `function(sender#, key, keychar$, shift$)` |
| OnKeyUp | `form_onkeyup#(frm#, func$)` | `form_onkeyup$(frm#)` | `function(sender#, key, keychar$, shift$)` |
| OnFocusChanged | `form_onfocuschanged#(frm#, func$)` | `form_onfocuschanged$(frm#)` | `function(sender#)` |

Use `form_clearcallbacks#(frm#)` to disconnect all callbacks.

---

## Complete Examples

### Example 1: Simple Application

```basic
let frm# = form#("My App", 640, 480)
form_position#(frm#, 4)
form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

form_free(frm#)
```

### Example 2: Event-Driven with Keyboard

```basic
function OnKeyDown(sender#, key, keychar$, shift$)
  if key = 27 then
    form_close(sender#)
  endif
endfunction

function OnClose(sender#, action)
  println "Goodbye!"
  return 2
endfunction

let frm# = form#("Press ESC to close", 400, 300)
form_position#(frm#, 4)
form_onkeydown#(frm#, "OnKeyDown")
form_onclose#(frm#, "OnClose")
form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

### Example 3: Resizable with Constraints

```basic
function OnResize(sender#, w, h)
  form_caption#(sender#, "Size: " + str$(w) + " x " + str$(h))
endfunction

let frm# = form#("Resize Me", 600, 400)
form_position#(frm#, 4)
form_constraints#(frm#, 400, 300, 1200, 800)
form_onresize#(frm#, "OnResize")
form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

### Example 4: Dialog with Buttons

```basic
let dlg# = Pointer#(0)

function OnOK(sender#)
  form_modalresult#(dlg#, 1)
  form_close(dlg#)
endfunction

function OnCancel(sender#)
  form_modalresult#(dlg#, 2)
  form_close(dlg#)
endfunction

function OnDialogClose(sender#, result)
  if result = 1 then
    println "OK clicked"
  else
    println "Cancelled"
  endif
endfunction

dlg# = form#("Confirm", 300, 150)
form_position#(dlg#, 4)

let btnOK# = button#(dlg#, "OK", 50, 100, 80, 30)
let btnCancel# = button#(dlg#, "Cancel", 170, 100, 80, 30)

button_onclick#(btnOK#, "OnOK")
button_onclick#(btnCancel#, "OnCancel")

form_showex#(dlg#, "OnDialogClose")
```

---

## See Also

- **ButtonLib** - Button controls
- **LabelLib** - Text labels
- **EditLib** - Text input
- **PanelLib** - Container panels
- **PlatformInfoLib** - Platform detection

---

*FormLib Version 1.2.0 - Part of the Plan9Basic GUI Library System*
