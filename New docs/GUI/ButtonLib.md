# ButtonLib - Button Control Library for Plan9Basic

## Overview

ButtonLib provides complete functionality for creating and managing button controls in Plan9Basic programs. Buttons are the standard clickable interface element for triggering actions.

**Version:** 1.0.0  
**Function Count:** 108 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
' Create a simple button
let frm# = form#("Button Demo", 400, 300)
form_position#(frm#, 4)

let btn# = button#(frm#, "Click Me!")
button_move#(btn#, 50, 50)
button_size#(btn#, 120, 40)
button_onclick#(btn#, "OnButtonClick")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnButtonClick(sender#)
  println "Button was clicked!"
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
| 11 | Center |

### Modal Result Values

| Value | Meaning |
|-------|---------|
| 0 | None |
| 1 | OK |
| 2 | Cancel |
| 6 | Yes |
| 7 | No |

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `button_error()` | Returns last error code (0 = no error) |
| `button_errormsg$()` | Returns last error message |
| `button_strerror$(code)` | Converts error code to message |
| `button_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `button#(parent#)` | Create with default text "Button" |
| `button#(parent#, text$)` | Create with specified text |
| `button#(parent#, x, y, w, h)` | Create at position with size |
| `button#(parent#, text$, x, y, w, h)` | Create with text, position, and size |
| `button_free(btn#)` | Destroy button |

### Text Content

| Function | Description |
|----------|-------------|
| `button_text$(btn#)` | Get button text |
| `button_text#(btn#, text$)` | Set button text |

### Font Properties

| Function | Description |
|----------|-------------|
| `button_fontfamily$(btn#)` / `button_fontfamily#(btn#, family$)` | Get/set font family |
| `button_fontsize(btn#)` / `button_fontsize#(btn#, size)` | Get/set font size |
| `button_fontcolor$(btn#)` / `button_fontcolor#(btn#, color$)` | Get/set font color |
| `button_bold(btn#)` / `button_bold#(btn#, value)` | Get/set bold (0/1) |
| `button_italic(btn#)` / `button_italic#(btn#, value)` | Get/set italic (0/1) |
| `button_underline(btn#)` / `button_underline#(btn#, value)` | Get/set underline (0/1) |
| `button_strikeout(btn#)` / `button_strikeout#(btn#, value)` | Get/set strikeout (0/1) |

### Button-Specific Properties

| Function | Description |
|----------|-------------|
| `button_modalresult(btn#)` / `button_modalresult#(btn#, value)` | Get/set modal result value |
| `button_default(btn#)` / `button_default#(btn#, value)` | Get/set as default button (responds to Enter) |
| `button_cancel(btn#)` / `button_cancel#(btn#, value)` | Get/set as cancel button (responds to Escape) |

### Position and Size

| Function | Description |
|----------|-------------|
| `button_x(btn#)` / `button_x#(btn#, x)` | Get/set X position |
| `button_y(btn#)` / `button_y#(btn#, y)` | Get/set Y position |
| `button_width(btn#)` / `button_width#(btn#, w)` | Get/set width |
| `button_height(btn#)` / `button_height#(btn#, h)` | Get/set height |
| `button_bounds#(btn#, x, y, w, h)` | Set position and size |
| `button_move#(btn#, x, y)` | Set position only |
| `button_size#(btn#, w, h)` | Set size only |

### Alignment

| Function | Description |
|----------|-------------|
| `button_align(btn#)` / `button_align#(btn#, value)` | Get/set alignment (0=None, 1=Top, 2=Left, 3=Right, 4=Bottom, 9=Client, 11=Center) |

### Margins

| Function | Description |
|----------|-------------|
| `button_marginleft(btn#)` / `button_marginleft#(btn#, value)` | Get/set left margin |
| `button_margintop(btn#)` / `button_margintop#(btn#, value)` | Get/set top margin |
| `button_marginright(btn#)` / `button_marginright#(btn#, value)` | Get/set right margin |
| `button_marginbottom(btn#)` / `button_marginbottom#(btn#, value)` | Get/set bottom margin |
| `button_margins#(btn#, l, t, r, b)` | Set all margins at once |
| `button_margin#(btn#, value)` | Set uniform margin (all sides equal) |

### Visibility and State

| Function | Description |
|----------|-------------|
| `button_visible(btn#)` / `button_visible#(btn#, value)` | Get/set visibility (0/1) |
| `button_enabled(btn#)` / `button_enabled#(btn#, value)` | Get/set enabled state (0/1) |
| `button_opacity(btn#)` / `button_opacity#(btn#, value)` | Get/set opacity (0.0-1.0) |

### Focus

| Function | Description |
|----------|-------------|
| `button_isfocused(btn#)` | Get focus state |
| `button_setfocus#(btn#)` | Give focus to button |
| `button_resetfocus#(btn#)` | Remove focus from button |
| `button_taborder(btn#)` / `button_taborder#(btn#, value)` | Get/set tab order |
| `button_canfocus(btn#)` / `button_canfocus#(btn#, value)` | Get/set whether button can receive focus |

### Hit Testing and Drag Mode

| Function | Description |
|----------|-------------|
| `button_hittest(btn#)` / `button_hittest#(btn#, value)` | Get/set hit testing (0/1) |
| `button_dragmode(btn#)` / `button_dragmode#(btn#, value)` | Get/set drag mode (0=Manual, 1=Automatic) |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `button_tag(btn#)` / `button_tag#(btn#, value)` | Get/set tag value |
| `button_parent#(btn#)` | Get parent |
| `button_parent#(btn#, parent#)` | Set parent |
| `button_bringtofront#(btn#)` | Bring to front |
| `button_sendtoback#(btn#)` | Send to back |
| `button_clearcallbacks#(btn#)` | Disconnects all event callbacks |

---

## Event Callbacks

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `button_onclick#(btn#, func$)` | `button_onclick$(btn#)` | `function(sender#)` |
| OnEnter | `button_onenter#(btn#, func$)` | `button_onenter$(btn#)` | `function(sender#)` |
| OnExit | `button_onexit#(btn#, func$)` | `button_onexit$(btn#)` | `function(sender#)` |
| OnKeyDown | `button_onkeydown#(btn#, func$)` | `button_onkeydown$(btn#)` | `function(sender#, key, keychar$, shift$)` |
| OnKeyUp | `button_onkeyup#(btn#, func$)` | `button_onkeyup$(btn#)` | `function(sender#, key, keychar$, shift$)` |
| OnMouseDown | `button_onmousedown#(btn#, func$)` | `button_onmousedown$(btn#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `button_onmouseup#(btn#, func$)` | `button_onmouseup$(btn#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `button_onmousemove#(btn#, func$)` | `button_onmousemove$(btn#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `button_onmouseenter#(btn#, func$)` | `button_onmouseenter$(btn#)` | `function(sender#)` |
| OnMouseLeave | `button_onmouseleave#(btn#, func$)` | `button_onmouseleave$(btn#)` | `function(sender#)` |
| OnResize | `button_onresize#(btn#, func$)` | `button_onresize$(btn#)` | `function(sender#)` |

### Drag Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnDragEnter | `button_ondragenter#(btn#, func$)` | `button_ondragenter$(btn#)` | `function(sender#, x, y)` |
| OnDragOver | `button_ondragover#(btn#, func$)` | `button_ondragover$(btn#)` | `function(sender#, x, y)` |
| OnDragDrop | `button_ondragdrop#(btn#, func$)` | `button_ondragdrop$(btn#)` | `function(sender#, x, y)` |
| OnDragLeave | `button_ondragleave#(btn#, func$)` | `button_ondragleave$(btn#)` | `function(sender#)` |

Use `button_clearcallbacks#(btn#)` to disconnect all events.

---

## Complete Examples

### Click Counter

```basic
let frm# = form#("Counter", 300, 200)
form_position#(frm#, 4)

let clicks = 0

let btn# = button#(frm#, "Clicks: 0", 50, 70, 200, 50)
button_fontsize#(btn#, 16)
button_onclick#(btn#, "OnClick")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnClick(sender#)
  clicks = clicks + 1
  button_text#(sender#, "Clicks: " + str$(clicks))
endfunction
```

### Dialog with OK/Cancel

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

dlg# = form#("Confirm", 300, 150)
form_position#(dlg#, 4)

let btnOK# = button#(dlg#, "OK", 50, 100, 80, 30)
button_default#(btnOK#, 1)
button_onclick#(btnOK#, "OnOK")

let btnCancel# = button#(dlg#, "Cancel", 170, 100, 80, 30)
button_cancel#(btnCancel#, 1)
button_onclick#(btnCancel#, "OnCancel")

form_show(dlg#)

while form_visible(dlg#) = 1
  processmessages()
end while
```

### Multiple Buttons with Tags

```basic
let frm# = form#("Colors", 400, 150)
form_position#(frm#, 4)

let lblResult# = label#(frm#, "Select a color", 150, 100)

let btnRed# = button#(frm#, "Red", 20, 40, 80, 40)
button_tag#(btnRed#, 1)
button_onclick#(btnRed#, "OnColorClick")

let btnGreen# = button#(frm#, "Green", 120, 40, 80, 40)
button_tag#(btnGreen#, 2)
button_onclick#(btnGreen#, "OnColorClick")

let btnBlue# = button#(frm#, "Blue", 220, 40, 80, 40)
button_tag#(btnBlue#, 3)
button_onclick#(btnBlue#, "OnColorClick")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnColorClick(sender#) local tag, color$
  tag = button_tag(sender#)
  
  if tag = 1 then
    color$ = "Red"
  elseif tag = 2 then
    color$ = "Green"
  elseif tag = 3 then
    color$ = "Blue"
  endif
  
  label_text#(lblResult#, "Selected: " + color$)
endfunction
```

---

## Important Notes

### Pointer Initialization

```basic
let btn# = Pointer#(0)
btn# = button#(frm#, "OK")
```

### Local Variables

```basic
function OnClick(sender#) local text$
  text$ = button_text$(sender#)
  println "Clicked: " + text$
endfunction
```

---

## Tips and Best Practices

1. **Always set OnClick** - Buttons without handlers serve little purpose
2. **Use meaningful text** - Button text should clearly indicate the action
3. **Set Default/Cancel** - For dialogs, improves keyboard navigation
4. **Use Tags** - Identify buttons when using shared callbacks
5. **Set Tab Order** - For logical keyboard navigation

---

## See Also

- **FormLib** - Form management
- **LabelLib** - Text labels
- **EditLib** - Text input
- **CheckBoxLib** - Checkbox controls

---

*ButtonLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
