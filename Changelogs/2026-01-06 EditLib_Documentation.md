# EditLib - Text Edit Control Library for Plan9Basic

## Overview

EditLib provides complete functionality for creating and managing single-line text input controls in Plan9Basic programs. An Edit is the primary text entry control with full editing capabilities.

**Version:** 1.0.0  
**Function Count:** 115 functions  
**Cross-Platform:** Windows, macOS, Linux, Android, iOS

## Features

- Edit creation and lifecycle management
- Text content with full font styling (family, size, bold, italic, etc.)
- Text color and prompt (placeholder) text
- Text alignment (left, center, right)
- Maximum length restriction
- Password mode
- Read-only mode
- Selection control (start, length, selected text)
- Caret position control
- Clipboard operations (copy, cut, paste)
- Mobile-specific features (keyboard type, return key type, spell check)
- Complete positioning and alignment
- Full event support with BASIC callback integration

## Quick Start

```basic
' Create a form with a text input
let frm# = form#("Edit Demo", 400, 300)
form_position#(frm#, 4)

' Create a simple text input
let edt# = edit#(frm#, 20, 20, 360, 30)
edit_prompt#(edt#, "Enter your name...")
edit_fontsize#(edt#, 14)
edit_onchange#(edt#, "OnTextChanged")

form_show(frm#)

function OnTextChanged(sender#)
  println "Text: " + edit_text$(sender#)
endfunction
```

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `edit_error@` | Returns the last error code |
| `edit_errormsg$@` | Returns the last error message |
| `edit_strerror$@n` | Returns description for error code |
| `edit_clearerror@` | Clears the last error |

**Error Codes:**
- 0 = No error
- 1 = Invalid edit control
- 2 = Invalid parent control
- 3 = Invalid value
- 4 = Failed to create edit

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `edit#@#` | Create edit with parent only |
| `edit#@#nnnn` | Create edit with parent, x, y, width, height |
| `edit#@#nnnn$` | Create edit with parent, x, y, width, height, text |
| `edit_free@#` | Free edit control |

### Text Content

| Function | Description |
|----------|-------------|
| `edit_text$@#` | Get text content |
| `edit_text#@#$` | Set text content |
| `edit_prompt$@#` | Get placeholder text |
| `edit_prompt#@#$` | Set placeholder text |
| `edit_maxlength@#` | Get maximum text length (0=unlimited) |
| `edit_maxlength#@#n` | Set maximum text length |
| `edit_textlength@#` | Get current text length |

### Password and Read-Only Mode

| Function | Description |
|----------|-------------|
| `edit_password@#` | Get password mode (0/1) |
| `edit_password#@#n` | Set password mode |
| `edit_readonly@#` | Get read-only mode (0/1) |
| `edit_readonly#@#n` | Set read-only mode |

### Font Properties

| Function | Description |
|----------|-------------|
| `edit_fontfamily$@#` | Get font family name |
| `edit_fontfamily#@#$` | Set font family name |
| `edit_fontsize@#` | Get font size |
| `edit_fontsize#@#n` | Set font size |
| `edit_fontcolor$@#` | Get font color |
| `edit_fontcolor#@#$` | Set font color |
| `edit_bold@#` | Get bold style (0/1) |
| `edit_bold#@#n` | Set bold style |
| `edit_italic@#` | Get italic style (0/1) |
| `edit_italic#@#n` | Set italic style |

### Text Alignment

| Function | Description |
|----------|-------------|
| `edit_textalign@#` | Get text alignment |
| `edit_textalign#@#n` | Set text alignment |

**Alignment Values:**
- 0 = Leading (Left)
- 1 = Center
- 2 = Trailing (Right)

### Selection

| Function | Description |
|----------|-------------|
| `edit_selstart@#` | Get selection start position |
| `edit_selstart#@#n` | Set selection start position |
| `edit_sellength@#` | Get selection length |
| `edit_sellength#@#n` | Set selection length |
| `edit_seltext$@#` | Get selected text |
| `edit_selectall#@#` | Select all text |
| `edit_clearselection#@#` | Clear selection |

### Caret Control

| Function | Description |
|----------|-------------|
| `edit_caretposition@#` | Get caret position |
| `edit_caretposition#@#n` | Set caret position |
| `edit_gotoend#@#` | Move caret to end |
| `edit_gotobegin#@#` | Move caret to beginning |

### Clipboard Operations

| Function | Description |
|----------|-------------|
| `edit_copy#@#` | Copy selection to clipboard |
| `edit_cut#@#` | Cut selection to clipboard |
| `edit_paste#@#` | Paste from clipboard |
| `edit_clear#@#` | Delete selection |

### Mobile-Specific Features

| Function | Description |
|----------|-------------|
| `edit_keyboardtype@#` | Get virtual keyboard type |
| `edit_keyboardtype#@#n` | Set virtual keyboard type |
| `edit_returnkeytype@#` | Get return key type |
| `edit_returnkeytype#@#n` | Set return key type |
| `edit_checkspelling@#` | Get spell checking state |
| `edit_checkspelling#@#n` | Enable/disable spell checking |
| `edit_filterchar$@#` | Get allowed characters filter |
| `edit_filterchar#@#$` | Set allowed characters filter |

**Keyboard Types:**
- 0 = Default
- 1 = Numbers and Punctuation
- 2 = Number Pad
- 3 = Phone Pad
- 7 = Email Address

**Return Key Types:**
- 0 = Default
- 1 = Done
- 2 = Go
- 3 = Next
- 4 = Search

### Position and Size

| Function | Description |
|----------|-------------|
| `edit_x@#` | Get X position |
| `edit_x#@#n` | Set X position |
| `edit_y@#` | Get Y position |
| `edit_y#@#n` | Set Y position |
| `edit_width@#` | Get width |
| `edit_width#@#n` | Set width |
| `edit_height@#` | Get height |
| `edit_height#@#n` | Set height |
| `edit_bounds#@#nnnn` | Set bounds (x, y, width, height) |
| `edit_move#@#nn` | Set position (x, y) |
| `edit_size#@#nn` | Set size (width, height) |

### Alignment

| Function | Description |
|----------|-------------|
| `edit_align@#` | Get alignment within parent |
| `edit_align#@#n` | Set alignment within parent |

**Alignment Values:**
- 0 = None
- 1 = Top
- 2 = Left
- 3 = Right
- 4 = Bottom
- 9 = Client (fill parent)
- 11 = Center

### Margins

| Function | Description |
|----------|-------------|
| `edit_marginleft@#` | Get left margin |
| `edit_marginleft#@#n` | Set left margin |
| `edit_margintop@#` | Get top margin |
| `edit_margintop#@#n` | Set top margin |
| `edit_margins#@#nnnn` | Set all margins (l, t, r, b) |
| `edit_margin#@#n` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `edit_visible@#` | Get visibility (0/1) |
| `edit_visible#@#n` | Set visibility |
| `edit_enabled@#` | Get enabled state (0/1) |
| `edit_enabled#@#n` | Set enabled state |
| `edit_opacity@#` | Get opacity (0.0-1.0) |
| `edit_opacity#@#n` | Set opacity |

### Focus Control

| Function | Description |
|----------|-------------|
| `edit_isfocused@#` | Check if focused (0/1) |
| `edit_setfocus#@#` | Set focus to edit |
| `edit_resetfocus#@#` | Remove focus |
| `edit_taborder@#` | Get tab order |
| `edit_taborder#@#n` | Set tab order |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `edit_tag@#` | Get tag value |
| `edit_tag#@#n` | Set tag value |
| `edit_parent#@#` | Get parent |
| `edit_parent#@##` | Set parent |
| `edit_bringtofront#@#` | Bring to front |
| `edit_sendtoback#@#` | Send to back |

### Events

| Function | Description | Callback Signature |
|----------|-------------|-------------------|
| `edit_onchange#@#$` | Text changed event | `function(sender#)` |
| `edit_onchangetracking#@#$` | Real-time text tracking | `function(sender#)` |
| `edit_ontyping#@#$` | User typing event | `function(sender#)` |
| `edit_onenter#@#$` | Focus gained | `function(sender#)` |
| `edit_onexit#@#$` | Focus lost | `function(sender#)` |
| `edit_onkeydown#@#$` | Key pressed | `function(sender#, key, keychar$, shift$)` |
| `edit_onkeyup#@#$` | Key released | `function(sender#, key, keychar$, shift$)` |
| `edit_onclick#@#$` | Click event | `function(sender#)` |
| `edit_ondblclick#@#$` | Double-click event | `function(sender#)` |
| `edit_onmousedown#@#$` | Mouse button pressed | `function(sender#, button, x, y, shift$)` |
| `edit_onmouseup#@#$` | Mouse button released | `function(sender#, button, x, y, shift$)` |
| `edit_onmousemove#@#$` | Mouse moved | `function(sender#, x, y, shift$)` |
| `edit_onmouseenter#@#$` | Mouse entered | `function(sender#)` |
| `edit_onmouseleave#@#$` | Mouse left | `function(sender#)` |
| `edit_onresize#@#$` | Edit resized | `function(sender#)` |
| `edit_clearcallbacks#@#` | Clear all callbacks | N/A |

## Event Callback Examples

### OnChange vs OnChangeTracking

```basic
' OnChange fires when editing is complete (focus lost or Enter pressed)
edit_onchange#(edt#, "OnEditComplete")

' OnChangeTracking fires on every keystroke (real-time)
edit_onchangetracking#(edt#, "OnTextTracking")

function OnEditComplete(sender#)
  println "Editing complete: " + edit_text$(sender#)
endfunction

function OnTextTracking(sender#)
  println "Current text: " + edit_text$(sender#)
endfunction
```

### Keyboard Events

```basic
edit_onkeydown#(edt#, "OnKeyDown")

function OnKeyDown(sender#, key, keychar$, shift$)
  ' key = virtual key code
  ' keychar$ = character pressed
  ' shift$ = modifier keys (S=Shift, C=Ctrl, A=Alt)
  
  if key = 13 then
    println "Enter pressed!"
  endif
  
  if instr(shift$, "C", 0) >= 0 then
    println "Ctrl key is down"
  endif
endfunction
```

## Common Use Cases

### Login Form

```basic
let frm# = form#("Login", 300, 200)
form_position#(frm#, 4)

' Username
let lblUser# = label#(frm#, "Username:")
label_move#(lblUser#, 20, 20)

let edtUser# = edit#(frm#, 20, 45, 260, 30)
edit_prompt#(edtUser#, "Enter username...")

' Password
let lblPass# = label#(frm#, "Password:")
label_move#(lblPass#, 20, 90)

let edtPass# = edit#(frm#, 20, 115, 260, 30)
edit_password#(edtPass#, 1)
edit_prompt#(edtPass#, "Enter password...")

form_show(frm#)
```

### Number-Only Input

```basic
let edtNumber# = edit#(frm#, 20, 20, 200, 30)
edit_filterchar#(edtNumber#, "0123456789")
edit_keyboardtype#(edtNumber#, 2)  ' Number pad on mobile
edit_prompt#(edtNumber#, "Enter number...")
```

### Search Box with Validation

```basic
let edtSearch# = edit#(frm#, 20, 20, 300, 30)
edit_prompt#(edtSearch#, "Search...")
edit_onchangetracking#(edtSearch#, "OnSearchChange")

function OnSearchChange(sender#)
  let txt$ = edit_text$(sender#)
  let len = edit_textlength(sender#)
  
  if len >= 3 then
    println "Searching for: " + txt$
  endif
endfunction
```

## Color Format

Colors are specified as strings:
- Named colors: "red", "blue", "green", "black", "white", etc.
- Hex RGB: "#RRGGBB" (e.g., "#FF5500")
- Hex ARGB: "#AARRGGBB" (e.g., "#80FF5500" for semi-transparent)

## Best Practices

1. **Use OnChange for validation** - Fires when editing is complete
2. **Use OnChangeTracking sparingly** - Fires on every keystroke
3. **Set maxlength for constrained inputs** - Prevents excessive data entry
4. **Use filterchar for restricted input** - Only allows specified characters
5. **Set appropriate keyboard type on mobile** - Improves user experience
6. **Provide placeholder text** - Guides users on expected input

## See Also

- FormLib - Form management
- LabelLib - Text labels
- LayoutLib - Container layouts
- RectangleLib - Visual shapes
