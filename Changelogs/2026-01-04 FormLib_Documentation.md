# FormLib - Form Management Library for Plan9Basic

## Overview

FormLib provides complete functionality for creating and managing application windows in Plan9Basic programs.

**Version:** 1.1.0  
**Function Count:** 105 functions

## Cross-Platform Support

FormLib is designed for full cross-platform compatibility using FireMonkey:

| Platform | Status | Notes |
|----------|--------|-------|
| **Windows** | ✅ Full Support | Win32/Win64 |
| **macOS** | ✅ Full Support | Intel/ARM (Apple Silicon) |
| **Linux** | ✅ Full Support | GTK-based |
| **Android** | ✅ Full Support | Mobile-optimized |
| **iOS** | ✅ Full Support | iPhone/iPad |

## Table of Contents

1. [Features](#features)
2. [Numeric Values Reference](#numeric-values-reference)
3. [Quick Start](#quick-start)
4. [Error Handling](#error-handling)
5. [Form Creation and Destruction](#form-creation-and-destruction)
6. [Form Display](#form-display)
7. [Caption Property](#caption-property)
8. [Position and Size](#position-and-size)
9. [Size Constraints](#size-constraints)
10. [Position Mode](#position-mode)
11. [Window State](#window-state)
12. [Border Style](#border-style)
13. [Form Style Flags](#form-style-flags)
14. [Fill/Background Color](#fillbackground-color)
15. [Focus and Activation](#focus-and-activation)
16. [Close Behavior](#close-behavior)
17. [Modal Operations](#modal-operations)
18. [Client Area](#client-area)
19. [Events](#events)
20. [Complete Examples](#complete-examples)

---

## Features

- **Form Lifecycle Management**: Create, show, hide, and destroy forms
- **Comprehensive Properties**: Position, size, colors, borders, constraints
- **Modal Support**: Both modal and non-modal display modes
- **Complete Event System**: 15+ events with BASIC callback integration
- **Cross-Platform**: Works on Windows, macOS, Linux, Android, iOS

---

## Numeric Values Reference

Plan9Basic does not have built-in constants. The following tables document the numeric values accepted by various functions. You can either use the numbers directly or define your own variables for readability.

**Optional: Define your own named values at the start of your applet:**
```basic
' Position modes
let POS_DESIGNED = 0
let POS_SCREEN_CENTER = 4

' Border styles  
let BORDER_NONE = 0
let BORDER_SIZEABLE = 2

' Close actions
let ACTION_HIDE = 1
let ACTION_FREE = 2

' Window states
let STATE_NORMAL = 0
let STATE_MAXIMIZED = 2
```

### Position Modes (for form_position#)

| Value | Description |
|-------|-------------|
| 0 | Use design-time position |
| 1 | Default position |
| 2 | Default position only |
| 3 | Default size only |
| 4 | Center on screen |
| 5 | Center on desktop |
| 6 | Center on main form |
| 7 | Center on owner form |

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

### Form Styles (for form_formstyle#)

| Value | Description |
|-------|-------------|
| 0 | Normal |
| 1 | Popup |
| 2 | Stay on top |

### Screen Orientations (returned by form_screenorientation)

| Value | Description |
|-------|-------------|
| 0 | Portrait |
| 1 | Landscape |
| 2 | Inverted Portrait |
| 3 | Inverted Landscape |

---

## Quick Start

```basic
' Create a simple window
let frm# = form#("Hello World", 400, 300)
form_position#(frm#, 4)      ' 4 = Center on screen
form_fill#(frm#, "#F0F0F0")  ' Light gray background
processmessages()
form_show(frm#)

' Wait 5 seconds for user interaction
pause(5)

' Clean up
form_close() 'close form
form_free(frm#) 'force memory release
```

---

## Error Handling

### form_error@
Returns the last error code.

**Syntax:** `form_error()`  
**Returns:** Number - Error code (0 = no error)

### form_errormsg$@
Returns the last error message.

**Syntax:** `form_errormsg$()`  
**Returns:** String - Error description

### form_strerror$@n
Returns description for a specific error code.

**Syntax:** `form_strerror$(code)`  
**Parameters:**
- `code` - Error code number

**Returns:** String - Error description

**Error Codes:**
| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Invalid or nil form |
| 2 | Invalid property |
| 3 | Invalid value |
| 4 | Form creation failed |
| 5 | Invalid callback function |

### form_clearerror@
Clears the error state.

**Syntax:** `form_clearerror()`

**Example:**
```basic
let frm# = form#()
if form_error() <> 0 then
  println "Error: "; form_errormsg$()
end if
```

---

## Form Creation and Destruction

### form#@
Creates a new form with default settings.

**Syntax:** `form#()`  
**Returns:** Pointer - Form handle

**Defaults:**
- Caption: "Plan9Basic Form"
- Size: 640x480
- Position: Screen center

### form#@$
Creates a new form with specified caption.

**Syntax:** `form#(caption$)`  
**Parameters:**
- `caption$` - Window title

**Returns:** Pointer - Form handle

### form#@$nn
Creates a new form with caption and size.

**Syntax:** `form#(caption$, width, height)`  
**Parameters:**
- `caption$` - Window title
- `width` - Initial width in pixels
- `height` - Initial height in pixels

**Returns:** Pointer - Form handle

### form_free@#
Destroys and releases a form.

**Syntax:** `form_free(frm#)`  
**Parameters:**
- `frm#` - Form handle

**Returns:** Number - 1 on success, 0 on failure

### form_close@#
Closes the form (triggers OnCloseQuery and OnClose events).

**Syntax:** `form_close(frm#)`  
**Parameters:**
- `frm#` - Form handle

**Example:**
```basic
let frm# = form#("My Application", 800, 600)
form_show(frm#)
' ... later ...
form_close(frm#)
```

---

## Form Display

### Cross-Platform Considerations

**Important:** Mobile platforms (Android, iOS) are asynchronous by nature. Embarcadero recommends against using `ShowModal` on these platforms as it can cause Application Not Responding (ANR) errors.

| Function | Desktop | Mobile | Recommendation |
|----------|---------|--------|----------------|
| `form_show` | ✅ Works | ✅ Works | **Use this** |
| `form_showmodal` | ✅ Works | ⚠️ Falls back to Show | Desktop only |
| `form_showex#` | ✅ Works | ✅ Works | **Best for cross-platform** |

**For cross-platform code, use the event-driven approach with `form_showex#` or `form_onclose#`.**

### form_show@#
Shows the form non-modally (program continues executing).

**Syntax:** `form_show(frm#)`  
**Parameters:**
- `frm#` - Form handle

**Returns:** Number - 1 on success

### form_showmodal@# (Desktop Only)
Shows the form modally (blocks until form is closed).

**Syntax:** `form_showmodal(frm#)`  
**Parameters:**
- `frm#` - Form handle

**Returns:** Number - Modal result value (desktop) or 0 (mobile)

**Platform Behavior:**
- **Desktop (Windows, macOS, Linux):** Works normally, blocks until closed
- **Mobile (Android, iOS):** Shows form non-modally, returns 0 immediately

**Modal Result Values:**
| Value | Meaning |
|-------|---------|
| 0 | None |
| 1 | OK |
| 2 | Cancel |
| 3 | Abort |
| 4 | Retry |
| 5 | Ignore |
| 6 | Yes |
| 7 | No |

### form_showex#@#$ (Cross-Platform Recommended)
Shows the form with a close callback - the recommended approach for cross-platform "modal-like" behavior.

**Syntax:** `form_showex#(frm#, onCloseCallback$)`  
**Parameters:**
- `frm#` - Form handle
- `onCloseCallback$` - Name of BASIC function to call when form closes

**Returns:** Pointer - Form handle

**Callback Signature:** `function OnFormClose(sender#, action)`

This function works identically on all platforms and provides a clean pattern for handling form results asynchronously.

**Example:**
```basic
function OnDialogClose(sender#, action)
  let result = form_modalresult(sender#)
  if result = 1 then
    println "User clicked OK"
  else
    println "User cancelled"
  end if
end function

let dlg# = form#("Confirm Action", 300, 150)
form_showex#(dlg#, "OnDialogClose")
```

### form_hide@#
Hides the form without destroying it.

**Syntax:** `form_hide(frm#)`  
**Parameters:**
- `frm#` - Form handle

### form_visible@#
Gets the form's visibility state.

**Syntax:** `form_visible(frm#)`  
**Returns:** Number - 1 if visible, 0 if hidden

### form_visible#@#n
Sets the form's visibility state.

**Syntax:** `form_visible#(frm#, visible)`  
**Parameters:**
- `frm#` - Form handle
- `visible` - 1 to show, 0 to hide

**Returns:** Pointer - Form handle (for chaining)

**Example:**
```basic
let frm# = form#("Toggle Window")
form_show(frm#)
pause 2000
form_hide(frm#)
println "Form hidden"
pause 2000
form_visible#(frm#, 1)
println "Form visible again"
```

---

## Caption Property

### form_caption$@#
Gets the form's caption (title).

**Syntax:** `form_caption$(frm#)`  
**Returns:** String - Current caption

### form_caption#@#$
Sets the form's caption.

**Syntax:** `form_caption#(frm#, caption$)`  
**Parameters:**
- `frm#` - Form handle
- `caption$` - New caption text

**Returns:** Pointer - Form handle

**Example:**
```basic
let frm# = form#()
form_caption#(frm#, "Document - Untitled")
form_show(frm#)

' Update caption later
form_caption#(frm#, "Document - MyFile.txt")
```

---

## Position and Size

### form_left@# / form_left#@#n
Gets/sets the left position.

**Get Syntax:** `form_left(frm#)`  
**Set Syntax:** `form_left#(frm#, value)`

### form_top@# / form_top#@#n
Gets/sets the top position.

**Get Syntax:** `form_top(frm#)`  
**Set Syntax:** `form_top#(frm#, value)`

### form_width@# / form_width#@#n
Gets/sets the width.

**Get Syntax:** `form_width(frm#)`  
**Set Syntax:** `form_width#(frm#, value)`

### form_height@# / form_height#@#n
Gets/sets the height.

**Get Syntax:** `form_height(frm#)`  
**Set Syntax:** `form_height#(frm#, value)`

### form_bounds#@#nnnn
Sets all bounds at once (most efficient).

**Syntax:** `form_bounds#(frm#, left, top, width, height)`  
**Returns:** Pointer - Form handle

### form_size#@#nn
Sets width and height together.

**Syntax:** `form_size#(frm#, width, height)`  
**Returns:** Pointer - Form handle

### form_move#@#nn
Sets left and top position together.

**Syntax:** `form_move#(frm#, left, top)`  
**Returns:** Pointer - Form handle

### form_center#@#
Centers the form on the screen.

**Syntax:** `form_center#(frm#)`  
**Returns:** Pointer - Form handle

**Example:**
```basic
let frm# = form#("Position Demo")

' Position at specific location
form_bounds#(frm#, 100, 100, 640, 480)
form_show(frm#)

' Or use individual setters
form_left#(frm#, 200)
form_top#(frm#, 150)

' Get current position
println "Position: "; form_left(frm#); ", "; form_top(frm#)
println "Size: "; form_width(frm#); " x "; form_height(frm#)
```

---

## Size Constraints

### form_minwidth@# / form_minwidth#@#n
Gets/sets minimum width constraint.

### form_minheight@# / form_minheight#@#n
Gets/sets minimum height constraint.

### form_maxwidth@# / form_maxwidth#@#n
Gets/sets maximum width constraint.

### form_maxheight@# / form_maxheight#@#n
Gets/sets maximum height constraint.

### form_constraints#@#nnnn
Sets all constraints at once.

**Syntax:** `form_constraints#(frm#, minW, minH, maxW, maxH)`

**Example:**
```basic
let frm# = form#("Constrained Window", 400, 300)

' Prevent resizing below 200x150 or above 800x600
form_constraints#(frm#, 200, 150, 800, 600)

' Or set individually
form_minwidth#(frm#, 200)
form_minheight#(frm#, 150)

form_show(frm#)
```

---

## Position Mode

### form_position@#
Gets the position mode.

**Syntax:** `form_position(frm#)`  
**Returns:** Number - Position mode value (0-7)

### form_position#@#n
Sets the position mode.

**Syntax:** `form_position#(frm#, mode)`  
**Parameters:**
- `mode` - Position mode (0-7, see Numeric Values Reference)

**Example:**
```basic
let frm# = form#("Centered Window")

' Center on screen
form_position#(frm#, 4)  ' 4 = Center on screen

form_show(frm#)
```

---

## Window State

### form_windowstate@#
Gets the current window state.

**Syntax:** `form_windowstate(frm#)`  
**Returns:** Number - State value (0=Normal, 1=Minimized, 2=Maximized)

### form_windowstate#@#n
Sets the window state.

**Syntax:** `form_windowstate#(frm#, state)`

### form_maximize#@#
Maximizes the form.

**Syntax:** `form_maximize#(frm#)`

### form_minimize#@#
Minimizes the form.

**Syntax:** `form_minimize#(frm#)`

### form_restore#@#
Restores the form to normal state.

**Syntax:** `form_restore#(frm#)`

**Example:**
```basic
let frm# = form#("Window State Demo")
form_show(frm#)

pause 2000
form_maximize#(frm#)
println "Maximized"

pause 2000
form_minimize#(frm#)
println "Minimized"

pause 2000
form_restore#(frm#)
println "Restored"
```

---

## Border Style

### form_borderstyle@#
Gets the border style.

**Syntax:** `form_borderstyle(frm#)`  
**Returns:** Number - Border style value (0-4)

### form_borderstyle#@#n
Sets the border style.

**Syntax:** `form_borderstyle#(frm#, style)`

**Values:** 0=None, 1=Single, 2=Sizeable, 3=ToolWindow, 4=SizeToolWin

**Example:**
```basic
' Create a non-resizable dialog-style window
let frm# = form#("Dialog", 300, 200)
form_borderstyle#(frm#, 1)  ' 1 = Single border (non-resizable)
form_position#(frm#, 4)     ' 4 = Center on screen
form_show(frm#)
```

---

## Form Style Flags

### form_fullscreen@# / form_fullscreen#@#n
Gets/sets fullscreen mode.

### form_stayontop@# / form_stayontop#@#n
Gets/sets always-on-top behavior.

### form_showfullscreenicon@# / form_showfullscreenicon#@#n
Gets/sets whether to show fullscreen icon (macOS).

**Example:**
```basic
let frm# = form#("Fullscreen Demo")
form_fullscreen#(frm#, 1)
form_show(frm#)
```

---

## Fill/Background Color

### form_fill$@#
Gets the fill color as a hex string.

**Syntax:** `form_fill$(frm#)`  
**Returns:** String - Color in #AARRGGBB format

### form_fill#@#$
Sets the fill color.

**Syntax:** `form_fill#(frm#, color$)`  
**Parameters:**
- `color$` - Color as hex (#RRGGBB or #AARRGGBB) or named color

**Named Colors:** black, white, red, green, blue, yellow, cyan, magenta, gray, silver, maroon, olive, navy, purple, teal, orange, pink, brown

**Example:**
```basic
let frm# = form#("Color Demo")

' Using hex color
form_fill#(frm#, "#336699")

' Using named color
form_fill#(frm#, "navy")

' With alpha transparency
form_fill#(frm#, "#80FF0000")  ' Semi-transparent red

form_show(frm#)
```

---

## Focus and Activation

### form_active@#
Checks if the form is currently active.

**Syntax:** `form_active(frm#)`  
**Returns:** Number - 1 if active, 0 otherwise

### form_bringtofront#@#
Brings the form to the front of the Z-order.

**Syntax:** `form_bringtofront#(frm#)`

### form_sendtoback#@#
Sends the form to the back of the Z-order.

**Syntax:** `form_sendtoback#(frm#)`

### form_setfocus#@#
Sets input focus to the form.

**Syntax:** `form_setfocus#(frm#)`

**Example:**
```basic
let frm1# = form#("Window 1")
let frm2# = form#("Window 2")
form_show(frm1#)
form_show(frm2#)

pause 2000
form_bringtofront#(frm1#)
form_setfocus#(frm1#)
```

---

## Close Behavior

### form_closeaction@# / form_closeaction#@#n
Gets/sets what happens when the form is closed.

**Actions:**
- 0 = None (form stays open)
- 1 = Hide
- 2 = Free (destroy)
- 3 = Minimize

### form_allowclose@# / form_allowclose#@#n
Gets/sets whether closing is allowed (used by OnCloseQuery).

**Example:**
```basic
let frm# = form#("Close Demo")

' Hide instead of destroying when closed
form_closeaction#(frm#, 1)  ' 1 = Hide

' Or prevent closing entirely
form_allowclose#(frm#, 0)

form_show(frm#)
```

---

## Modal Operations

### form_modalresult@#
Gets the modal result value.

**Syntax:** `form_modalresult(frm#)`

### form_modalresult#@#n
Sets the modal result (closes modal dialog).

**Syntax:** `form_modalresult#(frm#, result)`

**Example:**
```basic
' This would typically be called from a button click handler
function OnOKClick(sender#)
  form_modalresult#(myDialog#, 1)  ' mrOK
end function

function OnCancelClick(sender#)
  form_modalresult#(myDialog#, 2)  ' mrCancel
end function
```

---

## Client Area

### form_clientwidth@#
Gets the client area width (excluding borders).

**Syntax:** `form_clientwidth(frm#)`

### form_clientheight@#
Gets the client area height (excluding title bar and borders).

**Syntax:** `form_clientheight(frm#)`

### form_invalidate#@#
Forces a repaint of the form.

**Syntax:** `form_invalidate#(frm#)`

**Example:**
```basic
let frm# = form#("Client Area Demo", 400, 300)
form_show(frm#)

println "Total size: "; form_width(frm#); " x "; form_height(frm#)
println "Client area: "; form_clientwidth(frm#); " x "; form_clientheight(frm#)
```

---

## Events

FormLib provides a comprehensive event system that allows BASIC functions to be called when specific form events occur.

### Event Registration Pattern

All events follow the same pattern:
- **Set callback:** `form_on<event>#(frm#, "FunctionName")`
- **Get callback:** `form_on<event>$(frm#)`
- **Clear all:** `form_clearcallbacks#(frm#)`

### Available Events

| Event | Callback Signature | Description |
|-------|-------------------|-------------|
| OnShow | `func(sender#)` | Form is about to be shown |
| OnHide | `func(sender#)` | Form is about to be hidden |
| OnClose | `func(sender#, action) -> action` | Form is closing (can modify action) |
| OnCloseQuery | `func(sender#) -> canClose` | Query if form can close |
| OnActivate | `func(sender#)` | Form gained focus |
| OnDeactivate | `func(sender#)` | Form lost focus |
| OnResize | `func(sender#, width, height)` | Form was resized |
| OnPaint | `func(sender#, left, top, right, bottom)` | Form needs repainting |
| OnKeyDown | `func(sender#, keyCode, keyChar$, shift$)` | Key was pressed |
| OnKeyUp | `func(sender#, keyCode, keyChar$, shift$)` | Key was released |
| OnFocusChanged | `func(sender#)` | Focus changed within form |

### Shift State String

The `shift$` parameter in key events contains characters indicating modifier keys:
- `S` = Shift key
- `C` = Ctrl key
- `A` = Alt key
- `M` = Command key (macOS)

### Event Examples

#### OnShow / OnHide

```basic
function OnFormShow(sender#)
  println "Form is now visible!"
end function

function OnFormHide(sender#)
  println "Form was hidden"
end function

let frm# = form#("Event Demo")
form_onshow#(frm#, "OnFormShow")
form_onhide#(frm#, "OnFormHide")
form_show(frm#)
```

#### OnCloseQuery (Preventing Close)

```basic
let hasUnsavedChanges = 1

function OnFormCloseQuery(sender#)
  if hasUnsavedChanges = 1 then
    println "Cannot close: unsaved changes!"
    return 0  ' Prevent close
  end if
  return 1  ' Allow close
end function

let frm# = form#("Close Query Demo")
form_onclosequery#(frm#, "OnFormCloseQuery")
form_show(frm#)
```

#### OnResize

```basic
function OnFormResize(sender#, w, h)
  println "New size: "; w; " x "; h
end function

let frm# = form#("Resize Demo", 400, 300)
form_onresize#(frm#, "OnFormResize")
form_show(frm#)
```

#### OnKeyDown

```basic
function OnFormKeyDown(sender#, keyCode, keyChar$, shift$)
  println "Key pressed: "; keyCode; " ("; keyChar$; ")"
  if instr(1, shift$, "C") > 0 then
    println "  Ctrl was held"
  end if
end function

let frm# = form#("Keyboard Demo")
form_onkeydown#(frm#, "OnFormKeyDown")
form_show(frm#)
```

### Clearing Callbacks

```basic
' Remove all event handlers
form_clearcallbacks#(frm#)

' Or remove individual handlers
form_onshow#(frm#, "")
form_onresize#(frm#, "")
```

---

## Complete Examples

### Example 1: Simple Window

```basic
' Create and show a basic window
let frm# = form#("My First Window", 640, 480)
form_fill#(frm#, "#E8E8E8")
form_position#(frm#, 4)  ' Center on screen
form_show(frm#)

println "Window created! Press any key to close..."
pause 5000
form_free(frm#)
```

### Example 2: Modal Dialog (Desktop Only)

```basic
let result = 0

function ShowAboutDialog
  local dlg#
  
  dlg# = form#("About", 300, 200)
  form_borderstyle#(dlg#, 1)  ' 1 = Single border (non-resizable)
  form_position#(dlg#, 4)     ' 4 = Center on screen
  form_fill#(dlg#, "white")
  
  result = form_showmodal(dlg#)
  
  form_free(dlg#)
end function

ShowAboutDialog
println "Dialog result: "; result
```

### Example 3: Cross-Platform Dialog (Recommended)

This example works identically on all platforms (Windows, macOS, Linux, Android, iOS):

```basic
let dialogResult = 0
let mainForm#

' Callback when dialog closes
function OnConfirmDialogClose(sender#, action)
  dialogResult = form_modalresult(sender#)
  
  if dialogResult = 1 then
    println "User confirmed the action"
    ' Perform the confirmed action here
  else
    println "User cancelled"
  end if
  
  ' Clean up dialog
  form_free(sender#)
end function

' Helper function to check if mobile platform
function IsMobile
  let p$ = os_name$()
  if p$ = "Android" or p$ = "iOS" then
    return 1
  end if
  return 0
end function

' Function to show confirmation dialog
function ShowConfirmDialog(message$)
  local dlg#
  
  dlg# = form#("Confirm", 350, 150)
  
  ' Adjust for platform
  if IsMobile() = 1 then
    form_fullscreen#(dlg#, 0)
    form_position#(dlg#, 4)   ' 4 = Center on screen
  else
    form_borderstyle#(dlg#, 1) ' 1 = Single border
    form_position#(dlg#, 4)   ' 4 = Center on screen
  end if
  
  form_fill#(dlg#, "#F8F8F8")
  form_closeaction#(dlg#, 1)  ' 1 = Hide on close
  
  ' Show with callback (cross-platform approach)
  form_showex#(dlg#, "OnConfirmDialogClose")
end function

' Main application
mainForm# = form#("My Application", 640, 480)

let platform$ = os_name$()
if IsMobile() = 1 then
  println "Running on mobile: "; platform$
else
  println "Running on desktop: "; platform$
end if

form_show(mainForm#)

' Show a confirmation dialog
ShowConfirmDialog("Are you sure you want to proceed?")
```

### Example 4: Event-Driven Application

```basic
let running = 1

function OnMainFormShow(sender#)
  println "Application started"
end function

function OnMainFormCloseQuery(sender#)
  println "Are you sure you want to exit?"
  return 1  ' Allow close
end function

function OnMainFormClose(sender#, action)
  println "Application closing..."
  running = 0
  return 2  ' 2 = Free/destroy
end function

function OnMainFormResize(sender#, w, h)
  println "Window resized to "; w; " x "; h
end function

function OnMainFormKeyDown(sender#, keyCode, keyChar$, shift$)
  if keyCode = 27 then  ' Escape key
    println "Escape pressed!"
  end if
end function

' Create main form
let mainForm# = form#("Event-Driven App", 800, 600)
form_position#(frm#, 4)
form_fill#(mainForm#, "#F5F5F5")

' Set up all events
form_onshow#(mainForm#, "OnMainFormShow")
form_onclosequery#(mainForm#, "OnMainFormCloseQuery")
form_onclose#(mainForm#, "OnMainFormClose")
form_onresize#(mainForm#, "OnMainFormResize")
form_onkeydown#(mainForm#, "OnMainFormKeyDown")

' Constraints
form_constraints#(mainForm#, 400, 300, 1920, 1080)

' Show the form
form_show(mainForm#)

' Main loop
while running = 1
  pause 100
wend

println "Application terminated"
```

### Example 5: Multiple Windows

```basic
let window1#, window2#

function OnWindow1Activate(sender#)
  form_caption#(window1#, "Window 1 (ACTIVE)")
  form_caption#(window2#, "Window 2")
end function

function OnWindow2Activate(sender#)
  form_caption#(window1#, "Window 1")
  form_caption#(window2#, "Window 2 (ACTIVE)")
end function

' Create two windows
window1# = form#("Window 1", 400, 300)
window2# = form#("Window 2", 400, 300)

' Position them side by side
form_bounds#(window1#, 100, 100, 400, 300)
form_bounds#(window2#, 520, 100, 400, 300)

' Set up activation events
form_onactivate#(window1#, "OnWindow1Activate")
form_onactivate#(window2#, "OnWindow2Activate")

' Show both
form_show(window1#)
form_show(window2#)

pause 10000

' Clean up
form_free(window1#)
form_free(window2#)
```

---

## Function Reference (Quick List)

### Error Handling
- `form_error()` - Get error code
- `form_errormsg$()` - Get error message
- `form_strerror$(code)` - Get error description
- `form_clearerror()` - Clear error

### Creation/Destruction
- `form#()` - Create form
- `form#(caption$)` - Create with caption
- `form#(caption$, w, h)` - Create with size
- `form_free(frm#)` - Destroy form
- `form_close(frm#)` - Close form

### Display
- `form_show(frm#)` - Show non-modal
- `form_showmodal(frm#)` - Show modal (desktop only)
- `form_showex#(frm#, callback$)` - Show with close callback (cross-platform)
- `form_hide(frm#)` - Hide
- `form_visible(frm#)` / `form_visible#(frm#, v)` - Visibility

### Properties (Get/Set)
- `form_caption$(frm#)` / `form_caption#(frm#, s$)` - Title
- `form_left/top/width/height` - Position/size
- `form_bounds#(frm#, l, t, w, h)` - All bounds
- `form_size#(frm#, w, h)` - Size only
- `form_move#(frm#, l, t)` - Position only
- `form_center#(frm#)` - Center on screen
- `form_min/max width/height` - Constraints
- `form_position(frm#)` / `form_position#(frm#, n)` - Mode
- `form_windowstate(frm#)` / `form_windowstate#(frm#, n)` - State
- `form_maximize#/minimize#/restore#(frm#)` - State shortcuts
- `form_borderstyle(frm#)` / `form_borderstyle#(frm#, n)` - Border
- `form_formstyle(frm#)` / `form_formstyle#(frm#, n)` - Form style
- `form_fullscreen(frm#)` / `form_fullscreen#(frm#, n)` - Fullscreen
- `form_stayontop(frm#)` / `form_stayontop#(frm#, n)` - Always on top
- `form_fill$(frm#)` / `form_fill#(frm#, c$)` - Background color
- `form_transparency(frm#)` / `form_transparency#(frm#, n)` - Transparency
- `form_tag(frm#)` / `form_tag#(frm#, n)` - User data

### Focus/Activation
- `form_active(frm#)` - Is active
- `form_bringtofront#(frm#)` - Bring to front
- `form_sendtoback#(frm#)` - Send to back
- `form_setfocus#(frm#)` - Set focus

### Close Behavior
- `form_closeaction(frm#)` / `form_closeaction#(frm#, n)` - Action
- `form_allowclose(frm#)` / `form_allowclose#(frm#, n)` - Allow

### Modal
- `form_modalresult(frm#)` / `form_modalresult#(frm#, n)` - Result

### Client Area
- `form_clientwidth(frm#)` - Client width
- `form_clientheight(frm#)` - Client height
- `form_invalidate#(frm#)` - Force repaint

### Screen Information (Cross-Platform)
- `form_screenwidth()` - Screen width
- `form_screenheight()` - Screen height
- `form_screenscale()` - Scale factor (HiDPI)
- `form_screenorientation()` - Orientation (mobile)

### Platform Detection (use PlatformInfoLib)
- `os_name$()` - Platform name ("Windows", "Android", etc.)
- `os_platform$()` - Full platform string
- `os_architecture$()` - CPU architecture

### Events
- `form_onshow#(frm#, func$)` / `form_onshow$(frm#)` - OnShow
- `form_onhide#(frm#, func$)` / `form_onhide$(frm#)` - OnHide
- `form_onclose#(frm#, func$)` / `form_onclose$(frm#)` - OnClose
- `form_onclosequery#(frm#, func$)` / `form_onclosequery$(frm#)` - OnCloseQuery
- `form_onactivate#(frm#, func$)` / `form_onactivate$(frm#)` - OnActivate
- `form_ondeactivate#(frm#, func$)` / `form_ondeactivate$(frm#)` - OnDeactivate
- `form_onresize#(frm#, func$)` / `form_onresize$(frm#)` - OnResize
- `form_onpaint#(frm#, func$)` / `form_onpaint$(frm#)` - OnPaint
- `form_onkeydown#(frm#, func$)` / `form_onkeydown$(frm#)` - OnKeyDown
- `form_onkeyup#(frm#, func$)` / `form_onkeyup$(frm#)` - OnKeyUp
- `form_onfocuschanged#(frm#, func$)` / `form_onfocuschanged$(frm#)` - OnFocusChanged
- `form_clearcallbacks#(frm#)` - Clear all callbacks

---

## Notes

1. **Memory Management**: Forms are automatically registered with the garbage collector. Call `form_free()` explicitly for deterministic cleanup.

2. **Event Callbacks**: Function names are stored in lowercase. The callback signature must match exactly (e.g., `OnResize@#nn` requires a function with pointer and two number parameters).

3. **Cross-Platform**: All functions work across all supported platforms. Desktop-only functions like `form_showmodal` fall back to non-modal behavior on mobile.

4. **Thread Safety**: Form operations should be performed on the main thread.

5. **Runtime Creation**: All forms use `TForm.CreateNew` internally - no DFM resources required.

6. **Platform Detection**: Use **PlatformInfoLib** for platform detection:
   - `os_name$()` returns "Windows", "macOS", "Linux", "Android", or "iOS"
   - `os_platform$()` returns full platform string
   - `os_architecture$()` returns CPU architecture

---

## Screen Information Functions

These functions provide cross-platform access to screen/display information.

### form_screenwidth@
Returns the screen width in pixels.

**Syntax:** `form_screenwidth()`  
**Returns:** Number - Screen width

### form_screenheight@
Returns the screen height in pixels.

**Syntax:** `form_screenheight()`  
**Returns:** Number - Screen height

### form_screenscale@
Returns the screen scale factor (for HiDPI/Retina displays).

**Syntax:** `form_screenscale()`  
**Returns:** Number - Scale factor (1.0 = standard, 2.0 = Retina/HiDPI)

### form_screenorientation@
Returns the current screen orientation (primarily for mobile).

**Syntax:** `form_screenorientation()`  
**Returns:** Number - Orientation code

| Value | Orientation |
|-------|-------------|
| 0 | Portrait |
| 1 | Landscape |
| 2 | Inverted Portrait |
| 3 | Inverted Landscape |

**Example:**
```basic
println "Screen: "; form_screenwidth(); " x "; form_screenheight()
println "Scale factor: "; form_screenscale()

' Use PlatformInfoLib for platform detection
let platform$ = os_name$()
if platform$ = "Android" or platform$ = "iOS" then
  let orient = form_screenorientation()
  if orient = 0 then
    println "Portrait mode"
  else
    println "Landscape mode"
  end if
end if
```

---

## Platform Detection (via PlatformInfoLib)

For platform detection, use the functions from **PlatformInfoLib**:

| Function | Description | Example Return |
|----------|-------------|----------------|
| `os_name$()` | OS name | "Windows", "Android", "iOS" |
| `os_platform$()` | Full platform string | "Windows 11 (Version 23H2...)" |
| `os_architecture$()` | CPU architecture | "X64", "ARM64" |
| `os_major()` | OS major version | 11 |
| `os_minor()` | OS minor version | 0 |

**Example - Platform-Adaptive Code:**
```basic
let platform$ = os_name$()

if platform$ = "Android" or platform$ = "iOS" then
  ' Mobile: use fullscreen, event-driven dialogs
  form_fullscreen#(frm#, 1)
  form_showex#(dlg#, "OnDialogClose")
else
  ' Desktop: can use modal dialogs
  form_size#(frm#, 800, 600)
  form_center#(frm#)
  let result = form_showmodal(dlg#)
end if
```

---

## Form Style Property

### form_formstyle@# / form_formstyle#@#n
Gets/sets the form style.

**Get Syntax:** `form_formstyle(frm#)`  
**Set Syntax:** `form_formstyle#(frm#, style)`

| Value | Style | Description |
|-------|-------|-------------|
| 0 | Normal | Standard form |
| 1 | Popup | Popup window |
| 2 | StayOnTop | Always on top |

**Example:**
```basic
let frm# = form#("Always On Top")
form_formstyle#(frm#, 2)  ' StayOnTop
form_show(frm#)
```

---

*FormLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
