# SwitchLib - Switch Control Library

The SwitchLib provides functions to create and manage toggle switch controls in Plan9Basic applications. A switch is a visual on/off control that displays as a sliding toggle, commonly used for settings and preferences.

## Overview

Switches provide a modern, touch-friendly way to toggle between two states (on/off). Unlike checkboxes, switches are specifically designed for binary choices and are visually distinct, making them ideal for settings screens and mobile applications.

## Creating Switches

### switch#(parent#)
Creates a new switch control with default size.

**Parameters:**
- `parent#` - Parent control (form or container)

**Returns:** Pointer to the new switch

**Example:**
```basic
let frm# = form#("Settings", 400, 300)
let sw# = switch#(frm#)
switch_move#(sw#, 100, 50)
form_show(frm#)
```

### switch#(parent#, x, y, width, height)
Creates a new switch control with specified position and size.

**Parameters:**
- `parent#` - Parent control (form or container)
- `x` - X position
- `y` - Y position
- `width` - Width in pixels
- `height` - Height in pixels

**Returns:** Pointer to the new switch

**Example:**
```basic
let frm# = form#("Settings", 400, 300)
let sw# = switch#(frm#, 100, 50, 60, 24)
form_show(frm#)
```

### switch_free(switch#)
Destroys a switch control and releases its resources.

**Parameters:**
- `switch#` - Pointer to the switch

**Example:**
```basic
switch_free(sw#)
```

## Switch State

### switch_ischecked(switch#)
Gets the current state of the switch.

**Parameters:**
- `switch#` - Pointer to the switch

**Returns:** 1 if on, 0 if off

**Example:**
```basic
let state = switch_ischecked(sw#)
if state = 1 then
  println "Switch is ON"
else
  println "Switch is OFF"
endif
```

### switch_ischecked#(switch#, value)
Sets the state of the switch.

**Parameters:**
- `switch#` - Pointer to the switch
- `value` - 1 for on, 0 for off

**Returns:** Pointer to the switch (for chaining)

**Example:**
```basic
switch_ischecked#(sw#, 1)  ' Turn on
switch_ischecked#(sw#, 0)  ' Turn off
```

### switch_toggle#(switch#)
Toggles the switch state (on becomes off, off becomes on).

**Parameters:**
- `switch#` - Pointer to the switch

**Returns:** Pointer to the switch (for chaining)

**Example:**
```basic
switch_toggle#(sw#)
```

## Position and Size

### switch_x(switch#) / switch_x#(switch#, value)
Gets or sets the X position.

### switch_y(switch#) / switch_y#(switch#, value)
Gets or sets the Y position.

### switch_width(switch#) / switch_width#(switch#, value)
Gets or sets the width.

### switch_height(switch#) / switch_height#(switch#, value)
Gets or sets the height.

### switch_move#(switch#, x, y)
Sets both X and Y position at once.

**Example:**
```basic
switch_move#(sw#, 100, 50)
```

### switch_size#(switch#, width, height)
Sets both width and height at once.

**Example:**
```basic
switch_size#(sw#, 60, 24)
```

### switch_bounds#(switch#, x, y, width, height)
Sets position and size in a single call.

**Example:**
```basic
switch_bounds#(sw#, 100, 50, 60, 24)
```

## Alignment

### switch_align(switch#)
Gets the alignment mode.

**Returns:** Alignment value (see constants below)

### switch_align#(switch#, align)
Sets the alignment mode.

**Alignment Constants:**
- `0` - None (manual positioning)
- `1` - Top
- `2` - Left
- `3` - Right
- `4` - Bottom
- `9` - Client (fills parent)
- `11` - Center

**Example:**
```basic
switch_align#(sw#, 1)  ' Align to top
```

## Margins

### switch_marginleft(switch#) / switch_marginleft#(switch#, value)
Gets or sets the left margin.

### switch_margintop(switch#) / switch_margintop#(switch#, value)
Gets or sets the top margin.

### switch_marginright(switch#) / switch_marginright#(switch#, value)
Gets or sets the right margin.

### switch_marginbottom(switch#) / switch_marginbottom#(switch#, value)
Gets or sets the bottom margin.

### switch_margins#(switch#, left, top, right, bottom)
Sets all four margins at once.

**Example:**
```basic
switch_margins#(sw#, 10, 5, 10, 5)
```

### switch_margin#(switch#, value)
Sets all four margins to the same value.

**Example:**
```basic
switch_margin#(sw#, 10)  ' 10 pixels on all sides
```

## Visibility and State

### switch_visible(switch#) / switch_visible#(switch#, value)
Gets or sets visibility (1 = visible, 0 = hidden).

**Example:**
```basic
switch_visible#(sw#, 0)  ' Hide the switch
switch_visible#(sw#, 1)  ' Show the switch
```

### switch_enabled(switch#) / switch_enabled#(switch#, value)
Gets or sets enabled state (1 = enabled, 0 = disabled).

**Example:**
```basic
switch_enabled#(sw#, 0)  ' Disable the switch
switch_enabled#(sw#, 1)  ' Enable the switch
```

### switch_opacity(switch#) / switch_opacity#(switch#, value)
Gets or sets opacity (0.0 = transparent, 1.0 = opaque).

**Example:**
```basic
switch_opacity#(sw#, 0.5)  ' 50% transparent
```

## Focus Management

### switch_isfocused(switch#)
Returns 1 if the switch has keyboard focus, 0 otherwise.

### switch_setfocus#(switch#)
Gives keyboard focus to the switch.

### switch_resetfocus#(switch#)
Removes keyboard focus from the switch.

### switch_taborder(switch#) / switch_taborder#(switch#, value)
Gets or sets the tab order index.

### switch_canfocus(switch#) / switch_canfocus#(switch#, value)
Gets or sets whether the switch can receive focus.

## Tag Property

### switch_tag(switch#) / switch_tag#(switch#, value)
Gets or sets a numeric tag value for custom use.

**Example:**
```basic
switch_tag#(sw#, 42)
let t = switch_tag(sw#)
println "Tag: " + str$(t)
```

## Hit Test

### switch_hittest(switch#) / switch_hittest#(switch#, value)
Gets or sets whether the switch responds to mouse/touch input.

## Drag Mode

### switch_dragmode(switch#) / switch_dragmode#(switch#, value)
Gets or sets drag mode (0 = manual, 1 = automatic).

## Parent Control

### switch_parent#(switch#)
Gets the parent control of the switch.

### switch_parent#(switch#, parent#)
Sets the parent control of the switch.

### switch_bringtofront#(switch#)
Brings the switch to the front of its siblings.

### switch_sendtoback#(switch#)
Sends the switch to the back of its siblings.

## Events

### switch_onswitch#(switch#, callbackName$)
Sets the callback for when the switch state changes.

**Callback Signature:** `function callbackName(sender#)`

This is the primary event for responding to switch changes.

**Example:**
```basic
switch_onswitch#(sw#, "OnSwitchChanged")

function OnSwitchChanged(sender#) local state
  state = switch_ischecked(sender#)
  if state = 1 then
    println "Feature enabled"
  else
    println "Feature disabled"
  endif
endfunction
```

### switch_onclick#(switch#, callbackName$)
Sets the callback for click events.

**Callback Signature:** `function callbackName(sender#)`

### switch_ondblclick#(switch#, callbackName$)
Sets the callback for double-click events.

**Callback Signature:** `function callbackName(sender#)`

### switch_onenter#(switch#, callbackName$)
Sets the callback for when the switch receives focus.

**Callback Signature:** `function callbackName(sender#)`

### switch_onexit#(switch#, callbackName$)
Sets the callback for when the switch loses focus.

**Callback Signature:** `function callbackName(sender#)`

### switch_onkeydown#(switch#, callbackName$)
Sets the callback for key press events.

**Callback Signature:** `function callbackName(sender#, key, keychar$, shift$)`

**Parameters:**
- `sender#` - The switch that triggered the event
- `key` - Virtual key code
- `keychar$` - Character representation of the key
- `shift$` - Modifier keys string ("S" = Shift, "C" = Ctrl, "A" = Alt, "M" = Command)

### switch_onkeyup#(switch#, callbackName$)
Sets the callback for key release events.

**Callback Signature:** `function callbackName(sender#, key, keychar$, shift$)`

### switch_onmousedown#(switch#, callbackName$)
Sets the callback for mouse button press events.

**Callback Signature:** `function callbackName(sender#, button, shift$, x, y)`

**Parameters:**
- `sender#` - The switch that triggered the event
- `button` - Mouse button (1 = left, 2 = right, 3 = middle)
- `shift$` - Modifier keys string
- `x`, `y` - Mouse position within the switch

### switch_onmouseup#(switch#, callbackName$)
Sets the callback for mouse button release events.

**Callback Signature:** `function callbackName(sender#, button, shift$, x, y)`

### switch_onmousemove#(switch#, callbackName$)
Sets the callback for mouse movement events.

**Callback Signature:** `function callbackName(sender#, shift$, x, y)`

### switch_onmouseenter#(switch#, callbackName$)
Sets the callback for when the mouse enters the switch area.

**Callback Signature:** `function callbackName(sender#)`

### switch_onmouseleave#(switch#, callbackName$)
Sets the callback for when the mouse leaves the switch area.

**Callback Signature:** `function callbackName(sender#)`

### switch_onresize#(switch#, callbackName$)
Sets the callback for resize events.

**Callback Signature:** `function callbackName(sender#)`

### Drag and Drop Events

### switch_ondragenter#(switch#, callbackName$)
Sets the callback for drag enter events.

**Callback Signature:** `function callbackName(sender#, x, y)`

### switch_ondragover#(switch#, callbackName$)
Sets the callback for drag over events. Return non-zero to accept the drop.

**Callback Signature:** `function callbackName(sender#, x, y)`

### switch_ondragdrop#(switch#, callbackName$)
Sets the callback for drop events.

**Callback Signature:** `function callbackName(sender#, x, y)`

### switch_ondragleave#(switch#, callbackName$)
Sets the callback for drag leave events.

**Callback Signature:** `function callbackName(sender#)`

### Getting Event Callbacks

Each event setter has a corresponding getter:
- `switch_onswitch$(switch#)` - Returns the OnSwitch callback name
- `switch_onclick$(switch#)` - Returns the OnClick callback name
- etc.

### switch_clearcallbacks#(switch#)
Removes all event callbacks from the switch.

**Example:**
```basic
switch_clearcallbacks#(sw#)
```

## Error Handling

### switch_error()
Returns the last error code (0 = no error).

### switch_errormsg$()
Returns the last error message.

### switch_strerror$(code)
Returns a human-readable description for an error code.

### switch_clearerror()
Clears the last error.

**Error Codes:**
- `0` - No error
- `1` - Invalid switch pointer
- `2` - Invalid parent pointer
- `3` - Invalid value
- `4` - Failed to create switch
- `5` - Index out of range

**Example:**
```basic
let sw# = switch#(frm#)
if switch_error() <> 0 then
  println "Error: " + switch_errormsg$()
endif
```

## Complete Function Reference

### Creation and Destruction
| Function | Description |
|----------|-------------|
| `switch#(parent#)` | Create switch with default size |
| `switch#(parent#, x, y, w, h)` | Create switch with position and size |
| `switch_free(switch#)` | Destroy switch |

### State
| Function | Description |
|----------|-------------|
| `switch_ischecked(switch#)` | Get on/off state |
| `switch_ischecked#(switch#, v)` | Set on/off state |
| `switch_toggle#(switch#)` | Toggle state |

### Position and Size
| Function | Description |
|----------|-------------|
| `switch_x(switch#)` | Get X position |
| `switch_x#(switch#, v)` | Set X position |
| `switch_y(switch#)` | Get Y position |
| `switch_y#(switch#, v)` | Set Y position |
| `switch_width(switch#)` | Get width |
| `switch_width#(switch#, v)` | Set width |
| `switch_height(switch#)` | Get height |
| `switch_height#(switch#, v)` | Set height |
| `switch_move#(switch#, x, y)` | Set position |
| `switch_size#(switch#, w, h)` | Set size |
| `switch_bounds#(switch#, x, y, w, h)` | Set bounds |

### Alignment and Margins
| Function | Description |
|----------|-------------|
| `switch_align(switch#)` | Get alignment |
| `switch_align#(switch#, v)` | Set alignment |
| `switch_marginleft(switch#)` | Get left margin |
| `switch_marginleft#(switch#, v)` | Set left margin |
| `switch_margintop(switch#)` | Get top margin |
| `switch_margintop#(switch#, v)` | Set top margin |
| `switch_marginright(switch#)` | Get right margin |
| `switch_marginright#(switch#, v)` | Set right margin |
| `switch_marginbottom(switch#)` | Get bottom margin |
| `switch_marginbottom#(switch#, v)` | Set bottom margin |
| `switch_margins#(switch#, l, t, r, b)` | Set all margins |
| `switch_margin#(switch#, v)` | Set uniform margin |

### Visibility and State
| Function | Description |
|----------|-------------|
| `switch_visible(switch#)` | Get visibility |
| `switch_visible#(switch#, v)` | Set visibility |
| `switch_enabled(switch#)` | Get enabled state |
| `switch_enabled#(switch#, v)` | Set enabled state |
| `switch_opacity(switch#)` | Get opacity |
| `switch_opacity#(switch#, v)` | Set opacity |

### Focus
| Function | Description |
|----------|-------------|
| `switch_isfocused(switch#)` | Check if focused |
| `switch_setfocus#(switch#)` | Give focus |
| `switch_resetfocus#(switch#)` | Remove focus |
| `switch_taborder(switch#)` | Get tab order |
| `switch_taborder#(switch#, v)` | Set tab order |
| `switch_canfocus(switch#)` | Get can focus |
| `switch_canfocus#(switch#, v)` | Set can focus |

### Other Properties
| Function | Description |
|----------|-------------|
| `switch_tag(switch#)` | Get tag |
| `switch_tag#(switch#, v)` | Set tag |
| `switch_hittest(switch#)` | Get hit test |
| `switch_hittest#(switch#, v)` | Set hit test |
| `switch_dragmode(switch#)` | Get drag mode |
| `switch_dragmode#(switch#, v)` | Set drag mode |

### Parent
| Function | Description |
|----------|-------------|
| `switch_parent#(switch#)` | Get parent |
| `switch_parent#(switch#, parent#)` | Set parent |
| `switch_bringtofront#(switch#)` | Bring to front |
| `switch_sendtoback#(switch#)` | Send to back |

### Events
| Function | Description |
|----------|-------------|
| `switch_onswitch#(switch#, cb$)` | Set OnSwitch callback |
| `switch_onswitch$(switch#)` | Get OnSwitch callback |
| `switch_onclick#(switch#, cb$)` | Set OnClick callback |
| `switch_onclick$(switch#)` | Get OnClick callback |
| `switch_ondblclick#(switch#, cb$)` | Set OnDblClick callback |
| `switch_ondblclick$(switch#)` | Get OnDblClick callback |
| `switch_onenter#(switch#, cb$)` | Set OnEnter callback |
| `switch_onenter$(switch#)` | Get OnEnter callback |
| `switch_onexit#(switch#, cb$)` | Set OnExit callback |
| `switch_onexit$(switch#)` | Get OnExit callback |
| `switch_onkeydown#(switch#, cb$)` | Set OnKeyDown callback |
| `switch_onkeydown$(switch#)` | Get OnKeyDown callback |
| `switch_onkeyup#(switch#, cb$)` | Set OnKeyUp callback |
| `switch_onkeyup$(switch#)` | Get OnKeyUp callback |
| `switch_onmousedown#(switch#, cb$)` | Set OnMouseDown callback |
| `switch_onmousedown$(switch#)` | Get OnMouseDown callback |
| `switch_onmouseup#(switch#, cb$)` | Set OnMouseUp callback |
| `switch_onmouseup$(switch#)` | Get OnMouseUp callback |
| `switch_onmousemove#(switch#, cb$)` | Set OnMouseMove callback |
| `switch_onmousemove$(switch#)` | Get OnMouseMove callback |
| `switch_onmouseenter#(switch#, cb$)` | Set OnMouseEnter callback |
| `switch_onmouseenter$(switch#)` | Get OnMouseEnter callback |
| `switch_onmouseleave#(switch#, cb$)` | Set OnMouseLeave callback |
| `switch_onmouseleave$(switch#)` | Get OnMouseLeave callback |
| `switch_onresize#(switch#, cb$)` | Set OnResize callback |
| `switch_onresize$(switch#)` | Get OnResize callback |
| `switch_ondragenter#(switch#, cb$)` | Set OnDragEnter callback |
| `switch_ondragenter$(switch#)` | Get OnDragEnter callback |
| `switch_ondragover#(switch#, cb$)` | Set OnDragOver callback |
| `switch_ondragover$(switch#)` | Get OnDragOver callback |
| `switch_ondragdrop#(switch#, cb$)` | Set OnDragDrop callback |
| `switch_ondragdrop$(switch#)` | Get OnDragDrop callback |
| `switch_ondragleave#(switch#, cb$)` | Set OnDragLeave callback |
| `switch_ondragleave$(switch#)` | Get OnDragLeave callback |
| `switch_clearcallbacks#(switch#)` | Clear all callbacks |

### Error Handling
| Function | Description |
|----------|-------------|
| `switch_error()` | Get last error code |
| `switch_errormsg$()` | Get last error message |
| `switch_strerror$(code)` | Error code to string |
| `switch_clearerror()` | Clear last error |
