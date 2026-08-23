# CalloutRectangleLib - Callout Rectangle Visual Control Library

## Overview

CalloutRectangleLib enables the creation and management of callout rectangles (speech bubbles) with a triangular pointer, full support for fill and stroke styling, corner rounding, positioning, and event callbacks.

**Version:** 1.0.0  
**Function Count:** 90 functions

### What is a Callout Rectangle?

A callout rectangle is a rectangular shape with a triangular "pointer" extending from one of its sides, commonly used for:

- Speech bubbles in comics or chat interfaces
- Tooltips and info boxes
- Annotations and callouts in diagrams
- UI elements that point to specific content

## Quick Start

```basic
' Create a form
let frm# = form#("Callout Demo", 800, 600)

' Create a speech bubble pointing down
let bubble# = callout#(frm#, 50, 50, 200, 100)
callout_fill#(bubble#, "#3498db")
callout_stroke#(bubble#, "#2980b9")
callout_strokethickness#(bubble#, 2)
callout_calloutposition#(bubble#, 2)  ' Bottom pointer
callout_calloutlength#(bubble#, 20)
callout_calloutwidth#(bubble#, 30)
callout_corners#(bubble#, 10, 10)  ' Rounded corners

' Show the form
form_show(frm#)
```

## Callout Position

The `CalloutPosition` property determines which side the triangular pointer extends from:

| Value | Name   | Description                              |
|-------|--------|------------------------------------------|
| 0     | Top    | Pointer extends upward from top edge     |
| 1     | Left   | Pointer extends leftward from left edge  |
| 2     | Bottom | Pointer extends downward from bottom edge|
| 3     | Right  | Pointer extends rightward from right edge|

### Callout Properties

| Property | Description |
|----------|-------------|
| CalloutPosition | Which side the pointer appears on (0-3) |
| CalloutLength | How far the pointer extends from the rectangle |
| CalloutWidth | Width of the pointer's base |
| CalloutOffset | Position offset from center of the side (negative = left/up, positive = right/down) |

### Usage Example

```basic
' Create callouts pointing in different directions
let topBubble# = callout#(frm#, 50, 100, 150, 80)
callout_calloutposition#(topBubble#, 0)  ' Points up
callout_calloutlength#(topBubble#, 25)
callout_calloutwidth#(topBubble#, 40)

let leftBubble# = callout#(frm#, 250, 100, 150, 80)
callout_calloutposition#(leftBubble#, 1)  ' Points left
callout_calloutlength#(leftBubble#, 25)

let bottomBubble# = callout#(frm#, 450, 100, 150, 80)
callout_calloutposition#(bottomBubble#, 2)  ' Points down
callout_calloutlength#(bottomBubble#, 25)

let rightBubble# = callout#(frm#, 650, 100, 150, 80)
callout_calloutposition#(rightBubble#, 3)  ' Points right
callout_calloutlength#(rightBubble#, 25)

' Offset the pointer to the left
callout_calloutoffset#(bottomBubble#, -40)
```

## Stroke Styles

### Dash Styles

| Value | Name        | Description                    |
|-------|-------------|--------------------------------|
| 0     | Solid       | Continuous line (default)      |
| 1     | Dash        | Dashed line                    |
| 2     | Dot         | Dotted line                    |
| 3     | DashDot     | Alternating dash and dot       |
| 4     | DashDotDot  | Dash followed by two dots      |

### Cap Styles

| Value | Name  | Description                        |
|-------|-------|------------------------------------|
| 0     | Flat  | Square line endings (default)      |
| 1     | Round | Rounded line endings               |

### Join Styles

| Value | Name  | Description                        |
|-------|-------|------------------------------------|
| 0     | Miter | Sharp corners (default)            |
| 1     | Round | Rounded corners                    |
| 2     | Bevel | Beveled (cut) corners              |

## Color Format

Colors can be specified as:

- **Named colors**: `"red"`, `"blue"`, `"green"`, `"white"`, `"black"`, etc.
- **Hex RGB**: `"#RRGGBB"` (e.g., `"#FF5500"`)
- **Hex ARGB**: `"#AARRGGBB"` (e.g., `"#80FF5500"` for semi-transparent)

### Supported Named Colors

red, green, blue, white, black, yellow, orange, purple, cyan, magenta, gray/grey, silver, maroon, navy, olive, teal, lime, aqua, fuchsia, pink, brown, gold, coral, crimson, indigo, ivory, khaki, lavender, salmon, skyblue, tan, tomato, turquoise, violet, wheat, transparent

## Alignment Constants

| Value | Name         | Description                |
|-------|--------------|----------------------------|
| 0     | None         | No alignment (default)     |
| 1     | Top          | Align to top               |
| 2     | Left         | Align to left              |
| 3     | Right        | Align to right             |
| 4     | Bottom       | Align to bottom            |
| 9     | Client       | Fill parent area           |
| 11    | Center       | Center in parent           |

## Function Reference

### Error Handling

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout_error()` | `→ number` | Get last error code |
| `callout_errormsg$()` | `→ string` | Get last error message |
| `callout_strerror$(code)` | `number → string` | Convert error code to message |
| `callout_clearerror()` | `→ number` | Clear error state |

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | ERR_NONE | No error |
| 1 | ERR_INVALID_CALLOUT | Invalid callout pointer |
| 2 | ERR_INVALID_PARENT | Invalid parent control |
| 3 | ERR_INVALID_VALUE | Invalid parameter value |
| 4 | ERR_CREATE_FAILED | Callout creation failed |
| 5 | ERR_INVALID_CALLBACK | Invalid callback function |
| 6 | ERR_INVALID_COLOR | Invalid color value |

### Creation and Destruction

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout#(parent#)` | `pointer → pointer` | Create callout with parent |
| `callout#(parent#, w, h)` | `pointer, num, num → pointer` | Create with size |
| `callout#(parent#, x, y, w, h)` | `pointer, num, num, num, num → pointer` | Create with position and size |
| `callout_free(cb#)` | `pointer → number` | Free callout control |

### Callout-Specific Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout_calloutlength(cb#)` | `pointer → number` | Get callout pointer length |
| `callout_calloutlength#(cb#, val)` | `pointer, number → pointer` | Set callout pointer length |
| `callout_calloutwidth(cb#)` | `pointer → number` | Get callout pointer width |
| `callout_calloutwidth#(cb#, val)` | `pointer, number → pointer` | Set callout pointer width |
| `callout_calloutposition(cb#)` | `pointer → number` | Get callout position (0-3) |
| `callout_calloutposition#(cb#, pos)` | `pointer, number → pointer` | Set callout position |
| `callout_calloutoffset(cb#)` | `pointer → number` | Get callout offset from center |
| `callout_calloutoffset#(cb#, val)` | `pointer, number → pointer` | Set callout offset |

### Fill Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout_fill$(cb#)` | `pointer → string` | Get fill color |
| `callout_fill#(cb#, color$)` | `pointer, string → pointer` | Set fill color |
| `callout_fillnone#(cb#)` | `pointer → pointer` | Remove fill (transparent) |

### Stroke Properties

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout_stroke$(cb#)` | `pointer → string` | Get stroke color |
| `callout_stroke#(cb#, color$)` | `pointer, string → pointer` | Set stroke color |
| `callout_strokenone#(cb#)` | `pointer → pointer` | Remove stroke |
| `callout_strokethickness(cb#)` | `pointer → number` | Get stroke thickness |
| `callout_strokethickness#(cb#, val)` | `pointer, number → pointer` | Set stroke thickness |
| `callout_strokedash(cb#)` | `pointer → number` | Get dash style |
| `callout_strokedash#(cb#, style)` | `pointer, number → pointer` | Set dash style |
| `callout_strokecap(cb#)` | `pointer → number` | Get cap style |
| `callout_strokecap#(cb#, style)` | `pointer, number → pointer` | Set cap style |
| `callout_strokejoin(cb#)` | `pointer → number` | Get join style |
| `callout_strokejoin#(cb#, style)` | `pointer, number → pointer` | Set join style |

### Corner Radius

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout_xradius(cb#)` | `pointer → number` | Get X corner radius |
| `callout_xradius#(cb#, val)` | `pointer, number → pointer` | Set X corner radius |
| `callout_yradius(cb#)` | `pointer → number` | Get Y corner radius |
| `callout_yradius#(cb#, val)` | `pointer, number → pointer` | Set Y corner radius |
| `callout_corners#(cb#, xr, yr)` | `pointer, num, num → pointer` | Set both corner radii |

### Position and Size

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout_x(cb#)` | `pointer → number` | Get X position |
| `callout_x#(cb#, val)` | `pointer, number → pointer` | Set X position |
| `callout_y(cb#)` | `pointer → number` | Get Y position |
| `callout_y#(cb#, val)` | `pointer, number → pointer` | Set Y position |
| `callout_width(cb#)` | `pointer → number` | Get width |
| `callout_width#(cb#, val)` | `pointer, number → pointer` | Set width |
| `callout_height(cb#)` | `pointer → number` | Get height |
| `callout_height#(cb#, val)` | `pointer, number → pointer` | Set height |
| `callout_bounds#(cb#, x, y, w, h)` | `pointer, num, num, num, num → pointer` | Set all bounds |
| `callout_size#(cb#, w, h)` | `pointer, num, num → pointer` | Set size only |
| `callout_move#(cb#, x, y)` | `pointer, num, num → pointer` | Set position only |

### Alignment

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout_align(cb#)` | `pointer → number` | Get alignment |
| `callout_align#(cb#, align)` | `pointer, number → pointer` | Set alignment |

### Margins

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout_marginleft(cb#)` | `pointer → number` | Get left margin |
| `callout_marginleft#(cb#, val)` | `pointer, number → pointer` | Set left margin |
| `callout_margintop(cb#)` | `pointer → number` | Get top margin |
| `callout_margintop#(cb#, val)` | `pointer, number → pointer` | Set top margin |
| `callout_marginright(cb#)` | `pointer → number` | Get right margin |
| `callout_marginright#(cb#, val)` | `pointer, number → pointer` | Set right margin |
| `callout_marginbottom(cb#)` | `pointer → number` | Get bottom margin |
| `callout_marginbottom#(cb#, val)` | `pointer, number → pointer` | Set bottom margin |
| `callout_margins#(cb#, l, t, r, b)` | `pointer, num, num, num, num → pointer` | Set all margins |
| `callout_margin#(cb#, val)` | `pointer, number → pointer` | Set uniform margin |

### Visibility and Behavior

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout_visible(cb#)` | `pointer → number` | Get visibility (0/1) |
| `callout_visible#(cb#, val)` | `pointer, number → pointer` | Set visibility |
| `callout_enabled(cb#)` | `pointer → number` | Get enabled state (0/1) |
| `callout_enabled#(cb#, val)` | `pointer, number → pointer` | Set enabled state |
| `callout_opacity(cb#)` | `pointer → number` | Get opacity (0.0-1.0) |
| `callout_opacity#(cb#, val)` | `pointer, number → pointer` | Set opacity |
| `callout_hittest(cb#)` | `pointer → number` | Get hit test enabled (0/1) |
| `callout_hittest#(cb#, val)` | `pointer, number → pointer` | Set hit test enabled |

### Tag and Rotation

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout_tag(cb#)` | `pointer → number` | Get tag value |
| `callout_tag#(cb#, val)` | `pointer, number → pointer` | Set tag value |
| `callout_rotation(cb#)` | `pointer → number` | Get rotation angle |
| `callout_rotation#(cb#, angle)` | `pointer, number → pointer` | Set rotation angle |

### Parent and Z-Order

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout_parent#(cb#)` | `pointer → pointer` | Get parent control |
| `callout_parent#(cb#, parent#)` | `pointer, pointer → pointer` | Set parent control |
| `callout_bringtofront#(cb#)` | `pointer → pointer` | Bring to front of Z-order |
| `callout_sendtoback#(cb#)` | `pointer → pointer` | Send to back of Z-order |

### Invalidation

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout_invalidate#(cb#)` | `pointer → pointer` | Force repaint |

### Event Callbacks

| Function | Signature | Description |
|----------|-----------|-------------|
| `callout_onclick#(cb#, func$)` | `pointer, string → pointer` | Set click handler |
| `callout_onclick$(cb#)` | `pointer → string` | Get click handler name |
| `callout_ondblclick#(cb#, func$)` | `pointer, string → pointer` | Set double-click handler |
| `callout_ondblclick$(cb#)` | `pointer → string` | Get double-click handler name |
| `callout_onmousedown#(cb#, func$)` | `pointer, string → pointer` | Set mouse down handler |
| `callout_onmousedown$(cb#)` | `pointer → string` | Get mouse down handler name |
| `callout_onmouseup#(cb#, func$)` | `pointer, string → pointer` | Set mouse up handler |
| `callout_onmouseup$(cb#)` | `pointer → string` | Get mouse up handler name |
| `callout_onmousemove#(cb#, func$)` | `pointer, string → pointer` | Set mouse move handler |
| `callout_onmousemove$(cb#)` | `pointer → string` | Get mouse move handler name |
| `callout_onmouseenter#(cb#, func$)` | `pointer, string → pointer` | Set mouse enter handler |
| `callout_onmouseenter$(cb#)` | `pointer → string` | Get mouse enter handler name |
| `callout_onmouseleave#(cb#, func$)` | `pointer, string → pointer` | Set mouse leave handler |
| `callout_onmouseleave$(cb#)` | `pointer → string` | Get mouse leave handler name |
| `callout_onmousewheel#(cb#, func$)` | `pointer, string → pointer` | Set mouse wheel handler |
| `callout_onmousewheel$(cb#)` | `pointer → string` | Get mouse wheel handler name |
| `callout_onresize#(cb#, func$)` | `pointer, string → pointer` | Set resize handler |
| `callout_onresize$(cb#)` | `pointer → string` | Get resize handler name |
| `callout_clearcallbacks#(cb#)` | `pointer → pointer` | Clear all event callbacks |

## Event Callback Signatures

### OnClick / OnDblClick / OnMouseEnter / OnMouseLeave / OnResize

```basic
function MyHandler(sender#)
  ' sender# is the callout that triggered the event
  println "Event triggered!"
end function
```

### OnMouseDown / OnMouseUp

```basic
function MyMouseHandler(sender#, button, x, y, shift$)
  ' button: 0=Left, 1=Right, 2=Middle
  ' x, y: Mouse coordinates
  ' shift$: Modifier keys string
  println "Mouse at: " + stri$(x) + ", " + stri$(y)
end function
```

### OnMouseMove

```basic
function MyMoveHandler(sender#, x, y, shift$)
  ' x, y: Mouse coordinates
  ' shift$: Modifier keys string
  println "Moving at: " + stri$(x) + ", " + stri$(y)
end function
```

### OnMouseWheel

```basic
function MyWheelHandler(sender#, delta, shift$)
  ' delta: Wheel movement (positive=up, negative=down)
  ' shift$: Modifier keys string
  if delta > 0 then
    println "Wheel up"
  else
    println "Wheel down"
  end if
end function
```

## Complete Example

```basic
' ============================================================================
' CalloutRectangleLib Demo - Chat Interface
' ============================================================================

let frm# = form#("Chat Bubble Demo", 800, 600)

' Create a chat-like interface with speech bubbles

' Message from "User" (right side, pointer on right)
let userMsg1# = callout#(frm#, 400, 50, 350, 80)
callout_fill#(userMsg1#, "#DCF8C6")  ' WhatsApp green
callout_stroke#(userMsg1#, "#A8D98A")
callout_strokethickness#(userMsg1#, 1)
callout_calloutposition#(userMsg1#, 3)  ' Right pointer
callout_calloutlength#(userMsg1#, 15)
callout_calloutwidth#(userMsg1#, 20)
callout_calloutoffset#(userMsg1#, 20)   ' Near bottom
callout_corners#(userMsg1#, 12, 12)

' Message from "Other" (left side, pointer on left)
let otherMsg1# = callout#(frm#, 50, 150, 350, 100)
callout_fill#(otherMsg1#, "#FFFFFF")
callout_stroke#(otherMsg1#, "#E0E0E0")
callout_strokethickness#(otherMsg1#, 1)
callout_calloutposition#(otherMsg1#, 1)  ' Left pointer
callout_calloutlength#(otherMsg1#, 15)
callout_calloutwidth#(otherMsg1#, 20)
callout_calloutoffset#(otherMsg1#, -30)  ' Near top
callout_corners#(otherMsg1#, 12, 12)

' Another user message
let userMsg2# = callout#(frm#, 400, 280, 350, 60)
callout_fill#(userMsg2#, "#DCF8C6")
callout_stroke#(userMsg2#, "#A8D98A")
callout_strokethickness#(userMsg2#, 1)
callout_calloutposition#(userMsg2#, 3)
callout_calloutlength#(userMsg2#, 15)
callout_calloutwidth#(userMsg2#, 20)
callout_calloutoffset#(userMsg2#, 15)
callout_corners#(userMsg2#, 12, 12)

' Tooltip-style callout (pointer on top)
let tooltip# = callout#(frm#, 300, 420, 200, 60)
callout_fill#(tooltip#, "#333333")
callout_stroke#(tooltip#, "#333333")
callout_calloutposition#(tooltip#, 0)  ' Top pointer
callout_calloutlength#(tooltip#, 12)
callout_calloutwidth#(tooltip#, 20)
callout_corners#(tooltip#, 6, 6)
callout_opacity#(tooltip#, 0.9)

' Annotation callout (pointer on bottom)
let annotation# = callout#(frm#, 100, 500, 250, 70)
callout_fill#(annotation#, "#FFF3CD")  ' Warning yellow
callout_stroke#(annotation#, "#FFECB5")
callout_strokethickness#(annotation#, 2)
callout_calloutposition#(annotation#, 2)  ' Bottom pointer
callout_calloutlength#(annotation#, 25)
callout_calloutwidth#(annotation#, 35)
callout_calloutoffset#(annotation#, -50)  ' Offset to left
callout_corners#(annotation#, 8, 8)

' Interactive callout
let interactive# = callout#(frm#, 500, 450, 200, 100)
callout_fill#(interactive#, "#3498db")
callout_stroke#(interactive#, "#2980b9")
callout_strokethickness#(interactive#, 2)
callout_calloutposition#(interactive#, 2)
callout_calloutlength#(interactive#, 20)
callout_calloutwidth#(interactive#, 30)
callout_corners#(interactive#, 10, 10)
callout_onclick#(interactive#, "OnBubbleClick")
callout_onmouseenter#(interactive#, "OnBubbleEnter")
callout_onmouseleave#(interactive#, "OnBubbleLeave")

' Status label
let statusLbl# = label#(frm#, "Click the blue bubble!", 520, 560)

form_show(frm#)

' Track click count
let clickCount = 0

' Event handlers
function OnBubbleClick(sender#) local pos
  clickCount = clickCount + 1
  
  ' Cycle through callout positions
  let pos = callout_calloutposition(sender#)
  pos = pos + 1
  if pos > 3 then
    pos = 0
  end if
  callout_calloutposition#(sender#, pos)
  
  label_text#(statusLbl#, "Clicks: " + stri$(clickCount) + " - Position: " + stri$(pos))
end function

function OnBubbleEnter(sender#)
  callout_fill#(sender#, "#e74c3c")
  callout_stroke#(sender#, "#c0392b")
end function

function OnBubbleLeave(sender#)
  callout_fill#(sender#, "#3498db")
  callout_stroke#(sender#, "#2980b9")
end function
```

## Tips and Best Practices

### Creating Speech Bubbles

For realistic speech bubbles:
1. Use rounded corners (`callout_corners#`) for a softer look
2. Use `callout_calloutoffset#` to position the pointer near where the "speaker" would be
3. Keep `callout_calloutlength#` proportional to the bubble size (10-20% of width/height)

### Tooltip Style

For tooltip-style callouts:
1. Use darker fill colors with high opacity
2. Keep the pointer small (`callout_calloutlength#` around 8-12)
3. Position pointer at top (0) or bottom (2) for horizontal tooltips

### Annotation Style

For annotation/callout boxes:
1. Use lighter background colors
2. Use a slightly larger pointer for visibility
3. Use `callout_calloutoffset#` to point precisely at the annotated item

## Platform Support

CalloutRectangleLib supports all platforms:

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## See Also

- **RectangleLib** - Basic rectangle shapes
- **RoundRectLib** - Rounded rectangle shapes
- **CircleLib** - Circle/ellipse shapes
- **LabelLib** - Text labels (can be placed inside callouts)
- **PanelLib** - Container panels

---

*Copyright (c) 2024-2026 André Murta*
