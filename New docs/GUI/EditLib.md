# EditLib - Text Edit Control Library for Plan9Basic

## Overview

EditLib provides complete functionality for creating and managing single-line text input controls in Plan9Basic programs. Edit is the primary text entry control.

**Version:** 1.0.0  
**Function Count:** 133 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("Edit Demo", 400, 300)
form_position#(frm#, 4)

let edt# = edit#(frm#, 20, 20, 360, 30)
edit_prompt#(edt#, "Enter your name...")
edit_onchange#(edt#, "OnTextChanged")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnTextChanged(sender#)
  println "Text: " + edit_text$(sender#)
endfunction
```

## Numeric Values Reference

### Alignment Values (Control)

| Value | Description |
|-------|-------------|
| 0 | None (absolute positioning) |
| 1 | Top |
| 2 | Left |
| 3 | Right |
| 4 | Bottom |
| 9 | Client (fill parent) |

### Text Alignment Values

| Value | Description |
|-------|-------------|
| 0 | Left |
| 1 | Center |
| 2 | Right |

### Keyboard Types (Mobile)

| Value | Description |
|-------|-------------|
| 0 | Default |
| 1 | Numbers and Punctuation |
| 2 | Number Pad |
| 3 | Phone Pad |
| 7 | Email |

### Return Key Types (Mobile)

| Value | Description |
|-------|-------------|
| 0 | Default |
| 1 | Done |
| 2 | Go |
| 3 | Next |
| 4 | Search |

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `edit_error()` | Returns last error code |
| `edit_errormsg$()` | Returns last error message |
| `edit_strerror$(code)` | Returns description for error code |
| `edit_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `edit#(parent#)` | Create edit with parent only |
| `edit#(parent#, x, y, w, h)` | Create with position and size |
| `edit#(parent#, x, y, w, h, text$)` | Create with position, size, and text |
| `edit_free(edt#)` | Free edit control |

### Text Content

| Function | Description |
|----------|-------------|
| `edit_text$(edt#)` | Get text content |
| `edit_text#(edt#, text$)` | Set text content |
| `edit_prompt$(edt#)` | Get placeholder text |
| `edit_prompt#(edt#, text$)` | Set placeholder text |
| `edit_maxlength(edt#)` | Get maximum length (0=unlimited) |
| `edit_maxlength#(edt#, len)` | Set maximum length |
| `edit_textlength(edt#)` | Get current text length |

### Password and Read-Only

| Function | Description |
|----------|-------------|
| `edit_password(edt#)` | Get password mode (0/1) |
| `edit_password#(edt#, value)` | Set password mode |
| `edit_readonly(edt#)` | Get read-only mode (0/1) |
| `edit_readonly#(edt#, value)` | Set read-only mode |

### Font Properties

| Function | Description |
|----------|-------------|
| `edit_fontfamily$(edt#)` / `edit_fontfamily#(edt#, family$)` | Get/set font family |
| `edit_fontsize(edt#)` / `edit_fontsize#(edt#, size)` | Get/set font size |
| `edit_fontcolor$(edt#)` / `edit_fontcolor#(edt#, color$)` | Get/set font color |
| `edit_bold(edt#)` / `edit_bold#(edt#, value)` | Get/set bold (0/1) |
| `edit_italic(edt#)` / `edit_italic#(edt#, value)` | Get/set italic (0/1) |
| `edit_underline(edt#)` / `edit_underline#(edt#, value)` | Get/set underline (0/1) |
| `edit_strikeout(edt#)` / `edit_strikeout#(edt#, value)` | Get/set strikeout (0/1) |

### Text Alignment

| Function | Description |
|----------|-------------|
| `edit_textalign(edt#)` | Get text alignment |
| `edit_textalign#(edt#, align)` | Set text alignment (0=left, 1=center, 2=right) |

### Selection

| Function | Description |
|----------|-------------|
| `edit_selstart(edt#)` | Get selection start position |
| `edit_selstart#(edt#, pos)` | Set selection start position |
| `edit_sellength(edt#)` | Get selection length |
| `edit_sellength#(edt#, len)` | Set selection length |
| `edit_seltext$(edt#)` | Get selected text |
| `edit_selectall#(edt#)` | Select all text |
| `edit_clearselection#(edt#)` | Clear selection |

### Caret Control

| Function | Description |
|----------|-------------|
| `edit_caretposition(edt#)` | Get caret position |
| `edit_caretposition#(edt#, pos)` | Set caret position |
| `edit_gotoend#(edt#)` | Move caret to end |
| `edit_gotobegin#(edt#)` | Move caret to beginning |

### Clipboard

| Function | Description |
|----------|-------------|
| `edit_copy#(edt#)` | Copy selection to clipboard |
| `edit_cut#(edt#)` | Cut selection to clipboard |
| `edit_paste#(edt#)` | Paste from clipboard |
| `edit_clear#(edt#)` | Delete selection |

### Mobile Features

| Function | Description |
|----------|-------------|
| `edit_keyboardtype(edt#)` / `edit_keyboardtype#(edt#, type)` | Get/set keyboard type |
| `edit_returnkeytype(edt#)` / `edit_returnkeytype#(edt#, type)` | Get/set return key type |
| `edit_checkspelling(edt#)` / `edit_checkspelling#(edt#, value)` | Get/set spell checking (0/1) |
| `edit_filterchar$(edt#)` / `edit_filterchar#(edt#, chars$)` | Get/set allowed characters filter |

### Position and Size

| Function | Description |
|----------|-------------|
| `edit_x(edt#)` / `edit_x#(edt#, x)` | Get/set X position |
| `edit_y(edt#)` / `edit_y#(edt#, y)` | Get/set Y position |
| `edit_width(edt#)` / `edit_width#(edt#, w)` | Get/set width |
| `edit_height(edt#)` / `edit_height#(edt#, h)` | Get/set height |
| `edit_bounds#(edt#, x, y, w, h)` | Set bounds |
| `edit_move#(edt#, x, y)` | Set position |
| `edit_size#(edt#, w, h)` | Set size |

### Alignment

| Function | Description |
|----------|-------------|
| `edit_align(edt#)` / `edit_align#(edt#, value)` | Get/set alignment (0=None, 1=Top, 2=Left, 3=Right, 4=Bottom, 9=Client) |

### Margins

| Function | Description |
|----------|-------------|
| `edit_marginleft(edt#)` / `edit_marginleft#(edt#, value)` | Get/set left margin |
| `edit_margintop(edt#)` / `edit_margintop#(edt#, value)` | Get/set top margin |
| `edit_margins#(edt#, l, t, r, b)` | Set all margins at once |
| `edit_margin#(edt#, value)` | Set uniform margin (all sides equal) |

### Visibility and State

| Function | Description |
|----------|-------------|
| `edit_visible(edt#)` / `edit_visible#(edt#, value)` | Get/set visibility (0/1) |
| `edit_enabled(edt#)` / `edit_enabled#(edt#, value)` | Get/set enabled state (0/1) |
| `edit_opacity(edt#)` / `edit_opacity#(edt#, value)` | Get/set opacity (0.0-1.0) |

### Focus

| Function | Description |
|----------|-------------|
| `edit_isfocused(edt#)` | Check if focused |
| `edit_setfocus#(edt#)` | Set focus |
| `edit_resetfocus#(edt#)` | Remove focus |
| `edit_taborder(edt#)` / `edit_taborder#(edt#, value)` | Get/set tab order |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `edit_tag(edt#)` / `edit_tag#(edt#, value)` | Get/set tag |
| `edit_parent#(edt#)` | Get parent |
| `edit_parent#(edt#, parent#)` | Set parent |
| `edit_bringtofront#(edt#)` | Bring to front |
| `edit_sendtoback#(edt#)` | Send to back |
| `edit_clearcallbacks#(edt#)` | Disconnects all event callbacks |

---

## Event Callbacks

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnChange | `edit_onchange#(edt#, func$)` | `edit_onchange$(edt#)` | `function(sender#)` |
| OnChangeTracking | `edit_onchangetracking#(edt#, func$)` | `edit_onchangetracking$(edt#)` | `function(sender#)` |
| OnTyping | `edit_ontyping#(edt#, func$)` | `edit_ontyping$(edt#)` | `function(sender#)` |
| OnEnter | `edit_onenter#(edt#, func$)` | `edit_onenter$(edt#)` | `function(sender#)` |
| OnExit | `edit_onexit#(edt#, func$)` | `edit_onexit$(edt#)` | `function(sender#)` |
| OnKeyDown | `edit_onkeydown#(edt#, func$)` | `edit_onkeydown$(edt#)` | `function(sender#, key, keychar$, shift$)` |
| OnKeyUp | `edit_onkeyup#(edt#, func$)` | `edit_onkeyup$(edt#)` | `function(sender#, key, keychar$, shift$)` |
| OnClick | `edit_onclick#(edt#, func$)` | `edit_onclick$(edt#)` | `function(sender#)` |
| OnDblClick | `edit_ondblclick#(edt#, func$)` | `edit_ondblclick$(edt#)` | `function(sender#)` |
| OnMouseDown | `edit_onmousedown#(edt#, func$)` | `edit_onmousedown$(edt#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `edit_onmouseup#(edt#, func$)` | `edit_onmouseup$(edt#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `edit_onmousemove#(edt#, func$)` | `edit_onmousemove$(edt#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `edit_onmouseenter#(edt#, func$)` | `edit_onmouseenter$(edt#)` | `function(sender#)` |
| OnMouseLeave | `edit_onmouseleave#(edt#, func$)` | `edit_onmouseleave$(edt#)` | `function(sender#)` |
| OnResize | `edit_onresize#(edt#, func$)` | `edit_onresize$(edt#)` | `function(sender#)` |

### Drag Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnDragEnter | `edit_ondragenter#(edt#, func$)` | `edit_ondragenter$(edt#)` | `function(sender#, x, y)` |
| OnDragOver | `edit_ondragover#(edt#, func$)` | `edit_ondragover$(edt#)` | `function(sender#, x, y)` |
| OnDragDrop | `edit_ondragdrop#(edt#, func$)` | `edit_ondragdrop$(edt#)` | `function(sender#, x, y)` |
| OnDragLeave | `edit_ondragleave#(edt#, func$)` | `edit_ondragleave$(edt#)` | `function(sender#)` |

Use `edit_clearcallbacks#(edt#)` to disconnect all events.

### OnChange vs OnChangeTracking

- **OnChange** - Fires when editing is complete (focus lost or Enter)
- **OnChangeTracking** - Fires on every keystroke (real-time)

---

## Complete Examples

### Login Form

```basic
let frm# = form#("Login", 300, 200)
form_position#(frm#, 4)

' Username
label#(frm#, "Username:", 20, 20)
let edtUser# = edit#(frm#, 20, 45, 260, 30)
edit_prompt#(edtUser#, "Enter username...")

' Password
label#(frm#, "Password:", 20, 90)
let edtPass# = edit#(frm#, 20, 115, 260, 30)
edit_password#(edtPass#, 1)
edit_prompt#(edtPass#, "Enter password...")

' Login button
let btnLogin# = button#(frm#, "Login", 100, 160, 100, 30)
button_onclick#(btnLogin#, "OnLogin")

' Tab order
edit_taborder#(edtUser#, 1)
edit_taborder#(edtPass#, 2)
button_taborder#(btnLogin#, 3)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnLogin(sender#) local user$, pass$
  user$ = edit_text$(edtUser#)
  pass$ = edit_text$(edtPass#)
  println "Login: " + user$
endfunction
```

### Number-Only Input

```basic
let frm# = form#("Number Input", 300, 150)
form_position#(frm#, 4)

label#(frm#, "Enter amount:", 20, 20)
let edtAmount# = edit#(frm#, 20, 45, 200, 30)
edit_filterchar#(edtAmount#, "0123456789.")
edit_keyboardtype#(edtAmount#, 2)
edit_prompt#(edtAmount#, "0.00")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

### Real-Time Search

```basic
let frm# = form#("Search", 400, 200)
form_position#(frm#, 4)

let edtSearch# = edit#(frm#, 20, 20, 360, 30)
edit_prompt#(edtSearch#, "Type to search...")
edit_onchangetracking#(edtSearch#, "OnSearch")

let lblResult# = label#(frm#, "Type at least 3 characters")
label_move#(lblResult#, 20, 70)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnSearch(sender#) local txt$, len
  txt$ = edit_text$(sender#)
  len = edit_textlength(sender#)
  
  if len >= 3 then
    label_text#(lblResult#, "Searching for: " + txt$)
  else
    label_text#(lblResult#, "Type at least 3 characters")
  endif
endfunction
```

### Keyboard Events

```basic
let frm# = form#("Keys", 400, 200)
form_position#(frm#, 4)

let edt# = edit#(frm#, 20, 20, 360, 30)
edit_onkeydown#(edt#, "OnKeyDown")

let lblKey# = label#(frm#, "Press a key...")
label_move#(lblKey#, 20, 70)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnKeyDown(sender#, key, keychar$, shift$)
  if key = 13 then
    label_text#(lblKey#, "Enter pressed!")
  elseif key = 27 then
    label_text#(lblKey#, "Escape pressed!")
  else
    label_text#(lblKey#, "Key: " + str$(key) + " Char: " + keychar$)
  endif
endfunction
```

### Contact Form

```basic
let frm# = form#("Contact", 400, 280)
form_position#(frm#, 4)

' Name
label#(frm#, "Name:", 20, 20)
let edtName# = edit#(frm#, 20, 42, 360, 28)
edit_maxlength#(edtName#, 50)

' Email
label#(frm#, "Email:", 20, 80)
let edtEmail# = edit#(frm#, 20, 102, 360, 28)
edit_keyboardtype#(edtEmail#, 7)

' Phone
label#(frm#, "Phone:", 20, 140)
let edtPhone# = edit#(frm#, 20, 162, 360, 28)
edit_filterchar#(edtPhone#, "0123456789-+()")
edit_keyboardtype#(edtPhone#, 3)

' Submit
let btnSubmit# = button#(frm#, "Submit", 150, 220, 100, 35)

' Tab order
edit_taborder#(edtName#, 1)
edit_taborder#(edtEmail#, 2)
edit_taborder#(edtPhone#, 3)
button_taborder#(btnSubmit#, 4)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

---

## Important Notes

### Pointer Initialization

```basic
let edt# = Pointer#(0)
edt# = edit#(frm#, 20, 20, 200, 30)
```

### Local Variables

```basic
function OnChange(sender#) local txt$
  txt$ = edit_text$(sender#)
  println txt$
endfunction
```

---

## Tips and Best Practices

1. **Use OnChange for validation** - Fires when editing is complete
2. **Use OnChangeTracking sparingly** - Fires on every keystroke
3. **Set maxlength** - Prevents excessive data entry
4. **Use filterchar** - Restricts input to specified characters
5. **Set keyboard type on mobile** - Improves user experience
6. **Provide placeholder text** - Guides users on expected input
7. **Set tab order** - Enables keyboard navigation

---

## See Also

- **FormLib** - Form management
- **LabelLib** - Text labels
- **MemoLib** - Multi-line text input
- **ButtonLib** - Button controls

---

*EditLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
