# CheckBoxLib - CheckBox Control Library for Plan9Basic

## Overview

CheckBoxLib provides complete support for checkbox controls in Plan9Basic. Checkboxes are binary toggle controls that allow users to select or deselect options.

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
' Create a simple checkbox
let frm# = form#("My App", 400, 300)
form_position#(frm#, 4)

let chk# = checkbox#(frm#, "Enable feature")
checkbox_move#(chk#, 20, 50)
checkbox_onchange#(chk#, "OnCheckChanged")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnCheckChanged(sender#) local isChecked
  isChecked = checkbox_ischecked(sender#)
  if isChecked = 1 then
    println "Feature enabled"
  else
    println "Feature disabled"
  endif
endfunction
```

## Numeric Values Reference

### Alignment Values

| Value | Description |
|-------|-------------|
| 0 | None (manual positioning) |
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
| `checkbox_error()` | Get last error code (0 = no error) |
| `checkbox_errormsg$()` | Get last error message |
| `checkbox_strerror$(code)` | Convert error code to description |
| `checkbox_clearerror()` | Clear error state |

**Error Codes:** 0=None, 1=Invalid checkbox, 2=Invalid parent, 3=Invalid value, 4=Create failed

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `checkbox#(parent#)` | Create checkbox with default settings |
| `checkbox#(parent#, text$)` | Create checkbox with text |
| `checkbox#(parent#, x, y, w, h)` | Create checkbox at position |
| `checkbox#(parent#, text$, x, y, w, h)` | Create with all parameters |
| `checkbox_free(chk#)` | Free checkbox |

### Checked State

| Function | Description |
|----------|-------------|
| `checkbox_ischecked(chk#)` | Get checked state (0/1) |
| `checkbox_ischecked#(chk#, value)` | Set checked state |

### Text and Font

| Function | Description |
|----------|-------------|
| `checkbox_text$(chk#)` / `checkbox_text#(chk#, text$)` | Get/set text |
| `checkbox_fontfamily$(chk#)` / `checkbox_fontfamily#(chk#, family$)` | Get/set font family |
| `checkbox_fontsize(chk#)` / `checkbox_fontsize#(chk#, size)` | Get/set font size |
| `checkbox_fontcolor$(chk#)` / `checkbox_fontcolor#(chk#, color$)` | Get/set font color |
| `checkbox_bold(chk#)` / `checkbox_bold#(chk#, value)` | Get/set bold (0/1) |
| `checkbox_italic(chk#)` / `checkbox_italic#(chk#, value)` | Get/set italic (0/1) |
| `checkbox_underline(chk#)` / `checkbox_underline#(chk#, value)` | Get/set underline (0/1) |
| `checkbox_strikeout(chk#)` / `checkbox_strikeout#(chk#, value)` | Get/set strikeout (0/1) |

### Position and Size

| Function | Description |
|----------|-------------|
| `checkbox_x(chk#)` / `checkbox_x#(chk#, value)` | Get/set X |
| `checkbox_y(chk#)` / `checkbox_y#(chk#, value)` | Get/set Y |
| `checkbox_width(chk#)` / `checkbox_width#(chk#, value)` | Get/set width |
| `checkbox_height(chk#)` / `checkbox_height#(chk#, value)` | Get/set height |
| `checkbox_bounds#(chk#, x, y, w, h)` | Set all bounds |
| `checkbox_move#(chk#, x, y)` | Set position |
| `checkbox_size#(chk#, w, h)` | Set size |

### Alignment

| Function | Description |
|----------|-------------|
| `checkbox_align(chk#)` / `checkbox_align#(chk#, value)` | Get/set alignment (0=None, 1=Top, 2=Left, 3=Right, 4=Bottom, 9=Client, 11=Center) |

### Margins

| Function | Description |
|----------|-------------|
| `checkbox_marginleft(chk#)` / `checkbox_marginleft#(chk#, value)` | Get/set left margin |
| `checkbox_margintop(chk#)` / `checkbox_margintop#(chk#, value)` | Get/set top margin |
| `checkbox_marginright(chk#)` / `checkbox_marginright#(chk#, value)` | Get/set right margin |
| `checkbox_marginbottom(chk#)` / `checkbox_marginbottom#(chk#, value)` | Get/set bottom margin |
| `checkbox_margins#(chk#, l, t, r, b)` | Set all margins at once |
| `checkbox_margin#(chk#, value)` | Set uniform margin (all sides equal) |

### Visibility and State

| Function | Description |
|----------|-------------|
| `checkbox_visible(chk#)` / `checkbox_visible#(chk#, value)` | Get/set visibility (0/1) |
| `checkbox_enabled(chk#)` / `checkbox_enabled#(chk#, value)` | Get/set enabled state (0/1) |
| `checkbox_opacity(chk#)` / `checkbox_opacity#(chk#, value)` | Get/set opacity (0.0-1.0) |

### Focus

| Function | Description |
|----------|-------------|
| `checkbox_isfocused(chk#)` | Get focus state |
| `checkbox_setfocus#(chk#)` | Give focus |
| `checkbox_resetfocus#(chk#)` | Remove focus |
| `checkbox_taborder(chk#)` / `checkbox_taborder#(chk#, value)` | Get/set tab order |
| `checkbox_canfocus(chk#)` / `checkbox_canfocus#(chk#, value)` | Get/set whether checkbox can receive focus |

### Hit Testing and Drag Mode

| Function | Description |
|----------|-------------|
| `checkbox_hittest(chk#)` / `checkbox_hittest#(chk#, value)` | Get/set hit testing (0/1) |
| `checkbox_dragmode(chk#)` / `checkbox_dragmode#(chk#, value)` | Get/set drag mode (0=Manual, 1=Automatic) |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `checkbox_tag(chk#)` / `checkbox_tag#(chk#, value)` | Get/set tag |
| `checkbox_parent#(chk#)` | Get parent |
| `checkbox_parent#(chk#, parent#)` | Set parent |
| `checkbox_bringtofront#(chk#)` | Bring to front |
| `checkbox_sendtoback#(chk#)` | Send to back |
| `checkbox_clearcallbacks#(chk#)` | Disconnects all event callbacks |

---

## Event Callbacks

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnChange | `checkbox_onchange#(chk#, func$)` | `checkbox_onchange$(chk#)` | `function(sender#)` |
| OnClick | `checkbox_onclick#(chk#, func$)` | `checkbox_onclick$(chk#)` | `function(sender#)` |
| OnDblClick | `checkbox_ondblclick#(chk#, func$)` | `checkbox_ondblclick$(chk#)` | `function(sender#)` |
| OnEnter | `checkbox_onenter#(chk#, func$)` | `checkbox_onenter$(chk#)` | `function(sender#)` |
| OnExit | `checkbox_onexit#(chk#, func$)` | `checkbox_onexit$(chk#)` | `function(sender#)` |
| OnKeyDown | `checkbox_onkeydown#(chk#, func$)` | `checkbox_onkeydown$(chk#)` | `function(sender#, key, keychar$, shift$)` |
| OnKeyUp | `checkbox_onkeyup#(chk#, func$)` | `checkbox_onkeyup$(chk#)` | `function(sender#, key, keychar$, shift$)` |
| OnMouseDown | `checkbox_onmousedown#(chk#, func$)` | `checkbox_onmousedown$(chk#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `checkbox_onmouseup#(chk#, func$)` | `checkbox_onmouseup$(chk#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `checkbox_onmousemove#(chk#, func$)` | `checkbox_onmousemove$(chk#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `checkbox_onmouseenter#(chk#, func$)` | `checkbox_onmouseenter$(chk#)` | `function(sender#)` |
| OnMouseLeave | `checkbox_onmouseleave#(chk#, func$)` | `checkbox_onmouseleave$(chk#)` | `function(sender#)` |
| OnResize | `checkbox_onresize#(chk#, func$)` | `checkbox_onresize$(chk#)` | `function(sender#)` |

### Drag Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnDragEnter | `checkbox_ondragenter#(chk#, func$)` | `checkbox_ondragenter$(chk#)` | `function(sender#, x, y)` |
| OnDragOver | `checkbox_ondragover#(chk#, func$)` | `checkbox_ondragover$(chk#)` | `function(sender#, x, y)` |
| OnDragDrop | `checkbox_ondragdrop#(chk#, func$)` | `checkbox_ondragdrop$(chk#)` | `function(sender#, x, y)` |
| OnDragLeave | `checkbox_ondragleave#(chk#, func$)` | `checkbox_ondragleave$(chk#)` | `function(sender#)` |

Use `checkbox_clearcallbacks#(chk#)` to disconnect all events.

---

## Common Usage Patterns

### Settings Panel

```basic
let frm# = form#("Settings", 400, 300)
form_position#(frm#, 4)

let chkAutoSave# = checkbox#(frm#, "Auto-save documents")
checkbox_bounds#(chkAutoSave#, 20, 20, 200, 22)
checkbox_onchange#(chkAutoSave#, "OnAutoSaveChanged")

let chkSpellCheck# = checkbox#(frm#, "Enable spell check")
checkbox_bounds#(chkSpellCheck#, 20, 50, 200, 22)

let chkDarkMode# = checkbox#(frm#, "Dark mode")
checkbox_bounds#(chkDarkMode#, 20, 80, 200, 22)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnAutoSaveChanged(sender#)
  if checkbox_ischecked(sender#) = 1 then
    println "Auto-save enabled"
  else
    println "Auto-save disabled"
  endif
endfunction
```

### Select All Pattern

```basic
let chkSelectAll# = Pointer#(0)
let chkItem1# = Pointer#(0)
let chkItem2# = Pointer#(0)
let chkItem3# = Pointer#(0)

let frm# = form#("Select Items", 300, 200)
form_position#(frm#, 4)

' Master checkbox
chkSelectAll# = checkbox#(frm#, "Select All")
checkbox_bounds#(chkSelectAll#, 20, 20, 150, 22)
checkbox_bold#(chkSelectAll#, 1)
checkbox_onchange#(chkSelectAll#, "OnSelectAllChanged")

' Child checkboxes (indented)
chkItem1# = checkbox#(frm#, "Item 1")
checkbox_bounds#(chkItem1#, 40, 50, 130, 22)

chkItem2# = checkbox#(frm#, "Item 2")
checkbox_bounds#(chkItem2#, 40, 80, 130, 22)

chkItem3# = checkbox#(frm#, "Item 3")
checkbox_bounds#(chkItem3#, 40, 110, 130, 22)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnSelectAllChanged(sender#) local checked
  checked = checkbox_ischecked(chkSelectAll#)
  checkbox_ischecked#(chkItem1#, checked)
  checkbox_ischecked#(chkItem2#, checked)
  checkbox_ischecked#(chkItem3#, checked)
endfunction
```

### Using Tag for Identification

```basic
let chk1# = checkbox#(frm#, "Red")
checkbox_tag#(chk1#, 1)
checkbox_onchange#(chk1#, "OnColorChanged")

let chk2# = checkbox#(frm#, "Green")
checkbox_tag#(chk2#, 2)
checkbox_onchange#(chk2#, "OnColorChanged")

let chk3# = checkbox#(frm#, "Blue")
checkbox_tag#(chk3#, 3)
checkbox_onchange#(chk3#, "OnColorChanged")

function OnColorChanged(sender#) local tag, checked
  tag = checkbox_tag(sender#)
  checked = checkbox_ischecked(sender#)
  
  if tag = 1 then
    println "Red: " + str$(checked)
  elseif tag = 2 then
    println "Green: " + str$(checked)
  elseif tag = 3 then
    println "Blue: " + str$(checked)
  endif
endfunction
```

---

## Important Notes

### Pointer Initialization

```basic
let chk# = Pointer#(0)  ' Initialize pointer variable
chk# = checkbox#(frm#, "Option")
```

### Local Variables

Local variables must be declared on the function line:

```basic
' Correct
function MyFunc(param#) local var1, var2$
  ' function body
endfunction
```

### Event Connection

Events connect when callback is set, disconnect with empty string:

```basic
checkbox_onchange#(chk#, "MyHandler")  ' Connect
checkbox_onchange#(chk#, "")           ' Disconnect
checkbox_clearcallbacks#(chk#)         ' Disconnect all
```

---

## Tips and Best Practices

1. **Use OnChange for state tracking** - Primary event for checkboxes
2. **Use meaningful text** - Clearly describe what the option does
3. **Group related checkboxes** - Consider "Select All" for groups
4. **Set Tab Order** - Use `checkbox_taborder#()` for keyboard navigation
5. **Use Tags** - Identify checkboxes when using shared callbacks

---

## See Also

- **FormLib** - Form management
- **ButtonLib** - Button controls
- **RadioButtonLib** - Single selection controls
- **SwitchLib** - Toggle switch controls

---

*CheckBoxLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
