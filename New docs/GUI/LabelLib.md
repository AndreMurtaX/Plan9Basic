# LabelLib - Label Control Library for Plan9Basic

## Overview

LabelLib provides complete functionality for creating and managing text label controls in Plan9Basic programs. Labels display static or dynamic text with full font styling support.

**Version:** 1.1.0
**Function Count:** 89 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("Label Demo", 400, 300)
form_position#(frm#, 4)

let lbl# = label#(frm#, "Hello, World!")
label_move#(lbl#, 50, 50)
label_fontsize#(lbl#, 24)
label_fontcolor#(lbl#, "blue")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

## Numeric Values Reference

### Text Horizontal Alignment

| Value | Description |
|-------|-------------|
| 0 | Center |
| 1 | Leading (Left for LTR languages) |
| 2 | Trailing (Right for LTR languages) |

### Text Vertical Alignment

| Value | Description |
|-------|-------------|
| 0 | Center |
| 1 | Leading (Top) |
| 2 | Trailing (Bottom) |

### Control Alignment

| Value | Description |
|-------|-------------|
| 0 | None (absolute positioning) |
| 1 | Top |
| 2 | Left |
| 3 | Right |
| 4 | Bottom |
| 9 | Client (fill parent) |
| 11 | Center |

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `label_error()` | Returns last error code (0 = no error) |
| `label_errormsg$()` | Returns last error message |
| `label_strerror$(code)` | Converts error code to message |
| `label_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `label#(parent#)` | Create empty label |
| `label#(parent#, text$)` | Create with text |
| `label#(parent#, text$, x, y)` | Create with text and position |
| `label#(parent#, text$, x, y, w, h)` | Create with text, position, and size |
| `label_free(lbl#)` | Destroy label |

**Important:** Text is always the second parameter when provided.

### Text Content

| Function | Description |
|----------|-------------|
| `label_text$(lbl#)` | Get label text |
| `label_text#(lbl#, text$)` | Set label text |

### Font Properties

| Function | Description |
|----------|-------------|
| `label_fontfamily$(lbl#)` | Get font family |
| `label_fontfamily#(lbl#, family$)` | Set font family |
| `label_fontsize(lbl#)` | Get font size |
| `label_fontsize#(lbl#, size)` | Set font size |
| `label_fontcolor$(lbl#)` | Get font color |
| `label_fontcolor#(lbl#, color$)` | Set font color |
| `label_bold(lbl#)` / `label_bold#(lbl#, value)` | Get/set bold (0/1) |
| `label_italic(lbl#)` / `label_italic#(lbl#, value)` | Get/set italic (0/1) |
| `label_underline(lbl#)` / `label_underline#(lbl#, value)` | Get/set underline (0/1) |
| `label_strikeout(lbl#)` / `label_strikeout#(lbl#, value)` | Get/set strikeout (0/1) |

### Text Alignment

| Function | Description |
|----------|-------------|
| `label_textalign(lbl#)` | Get horizontal alignment |
| `label_textalign#(lbl#, align)` | Set horizontal alignment (0=center, 1=left, 2=right) |
| `label_vertalign(lbl#)` | Get vertical alignment |
| `label_vertalign#(lbl#, align)` | Set vertical alignment (0=center, 1=top, 2=bottom) |

### Word Wrap and Auto Size

| Function | Description |
|----------|-------------|
| `label_wordwrap(lbl#)` | Get word wrap state |
| `label_wordwrap#(lbl#, value)` | Set word wrap (0/1) |
| `label_autosize(lbl#)` | Get auto size state |
| `label_autosize#(lbl#, value)` | Set auto size (0/1) |

### Position and Size

| Function | Description |
|----------|-------------|
| `label_x(lbl#)` / `label_x#(lbl#, x)` | Get/set X position |
| `label_y(lbl#)` / `label_y#(lbl#, y)` | Get/set Y position |
| `label_width(lbl#)` / `label_width#(lbl#, w)` | Get/set width |
| `label_height(lbl#)` / `label_height#(lbl#, h)` | Get/set height |
| `label_bounds#(lbl#, x, y, w, h)` | Set position and size |
| `label_move#(lbl#, x, y)` | Set position only |
| `label_size#(lbl#, w, h)` | Set size only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `label_align(lbl#)` / `label_align#(lbl#, value)` | Get/set control alignment |
| `label_marginleft(lbl#)` / `label_marginleft#(lbl#, value)` | Get/set left margin |
| `label_margintop(lbl#)` / `label_margintop#(lbl#, value)` | Get/set top margin |
| `label_marginright(lbl#)` / `label_marginright#(lbl#, value)` | Get/set right margin |
| `label_marginbottom(lbl#)` / `label_marginbottom#(lbl#, value)` | Get/set bottom margin |
| `label_margins#(lbl#, l, t, r, b)` | Set all margins |
| `label_margin#(lbl#, value)` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `label_visible(lbl#)` / `label_visible#(lbl#, value)` | Get/set visibility (0/1) |
| `label_enabled(lbl#)` / `label_enabled#(lbl#, value)` | Get/set enabled state (0/1) |
| `label_opacity(lbl#)` / `label_opacity#(lbl#, value)` | Get/set opacity (0.0-1.0) |
| `label_hittest(lbl#)` / `label_hittest#(lbl#, value)` | Get/set hit test (0/1) |

### Tag and Rotation

| Function | Description |
|----------|-------------|
| `label_tag(lbl#)` / `label_tag#(lbl#, value)` | Get/set tag value |
| `label_rotation(lbl#)` / `label_rotation#(lbl#, angle)` | Get/set rotation (degrees) |

### Parent and Z-Order

| Function | Description |
|----------|-------------|
| `label_parent#(lbl#)` | Get parent |
| `label_parent#(lbl#, parent#)` | Set parent |
| `label_bringtofront#(lbl#)` | Bring to front |
| `label_sendtoback#(lbl#)` | Send to back |
| `label_clearcallbacks#(lbl#)` | Disconnects all event callbacks |

---

## Event Callbacks

**Important:** Labels require `label_hittest#(lbl#, 1)` to receive mouse events.

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `label_onclick#(lbl#, func$)` | `label_onclick$(lbl#)` | `function(sender#)` |
| OnDblClick | `label_ondblclick#(lbl#, func$)` | `label_ondblclick$(lbl#)` | `function(sender#)` |
| OnMouseDown | `label_onmousedown#(lbl#, func$)` | `label_onmousedown$(lbl#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `label_onmouseup#(lbl#, func$)` | `label_onmouseup$(lbl#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `label_onmousemove#(lbl#, func$)` | `label_onmousemove$(lbl#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `label_onmouseenter#(lbl#, func$)` | `label_onmouseenter$(lbl#)` | `function(sender#)` |
| OnMouseLeave | `label_onmouseleave#(lbl#, func$)` | `label_onmouseleave$(lbl#)` | `function(sender#)` |
| OnResize | `label_onresize#(lbl#, func$)` | `label_onresize$(lbl#)` | `function(sender#)` |

Use `label_clearcallbacks#(lbl#)` to disconnect all events.

---

## Complete Examples

### Styled Labels

```basic
let frm# = form#("Styled Labels", 400, 300)
form_position#(frm#, 4)

' Title label
let lblTitle# = label#(frm#, "Welcome to Plan9Basic")
label_move#(lblTitle#, 50, 30)
label_fontsize#(lblTitle#, 24)
label_fontcolor#(lblTitle#, "#0066CC")
label_bold#(lblTitle#, 1)

' Subtitle
let lblSub# = label#(frm#, "A modern BASIC interpreter")
label_move#(lblSub#, 50, 70)
label_fontsize#(lblSub#, 14)
label_italic#(lblSub#, 1)
label_fontcolor#(lblSub#, "gray")

' Description with word wrap
let lblDesc# = label#(frm#, "Create cross-platform applications easily.")
label_bounds#(lblDesc#, 50, 120, 300, 100)
label_wordwrap#(lblDesc#, 1)
label_autosize#(lblDesc#, 0)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

### Clickable Label

```basic
let frm# = form#("Clickable Label", 400, 200)
form_position#(frm#, 4)

let lbl# = label#(frm#, "Click me!")
label_move#(lbl#, 150, 80)
label_fontsize#(lbl#, 18)
label_fontcolor#(lbl#, "blue")
label_underline#(lbl#, 1)

' Enable hit test for mouse events
label_hittest#(lbl#, 1)
label_onclick#(lbl#, "OnLabelClick")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnLabelClick(sender#)
  label_text#(sender#, "Clicked!")
  label_fontcolor#(sender#, "red")
endfunction
```

### Dynamic Status Label

```basic
let frm# = form#("Status Demo", 400, 200)
form_position#(frm#, 4)

let lblStatus# = label#(frm#, "Ready")
label_move#(lblStatus#, 150, 30)
label_fontsize#(lblStatus#, 16)

let btnStart# = button#(frm#, "Start", 100, 100, 80, 30)
let btnStop# = button#(frm#, "Stop", 220, 100, 80, 30)

button_onclick#(btnStart#, "OnStart")
button_onclick#(btnStop#, "OnStop")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnStart(sender#)
  label_text#(lblStatus#, "Running...")
  label_fontcolor#(lblStatus#, "green")
endfunction

function OnStop(sender#)
  label_text#(lblStatus#, "Stopped")
  label_fontcolor#(lblStatus#, "red")
endfunction
```

### Label with Alignment

```basic
let frm# = form#("Alignment Demo", 500, 300)
form_position#(frm#, 4)

' Left aligned
let lbl1# = label#(frm#, "Left aligned text")
label_bounds#(lbl1#, 50, 50, 400, 30)
label_textalign#(lbl1#, 1)

' Center aligned
let lbl2# = label#(frm#, "Center aligned text")
label_bounds#(lbl2#, 50, 100, 400, 30)
label_textalign#(lbl2#, 0)

' Right aligned
let lbl3# = label#(frm#, "Right aligned text")
label_bounds#(lbl3#, 50, 150, 400, 30)
label_textalign#(lbl3#, 2)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

---

## Tips and Best Practices

1. **Enable HitTest for mouse events** - Labels don't receive mouse events by default
2. **Use AutoSize for dynamic text** - Label resizes to fit content
3. **Disable AutoSize for fixed layouts** - Set size manually with `label_bounds#()`
4. **Use WordWrap for long text** - Requires AutoSize=0 and fixed width
5. **Use Tags for identification** - Identify labels in shared callbacks

---

## See Also

- **FormLib** - Form management
- **ButtonLib** - Button controls
- **EditLib** - Text input
- **PanelLib** - Container controls

---

*LabelLib Version 1.1.0 - Part of the Plan9Basic GUI Library System*
