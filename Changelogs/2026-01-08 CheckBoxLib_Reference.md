# CheckBoxLib - Plan9Basic CheckBox Control Library

## Overview

CheckBoxLib provides complete support for CheckBox control in Plan9Basic, enabling the creation and management of checkbox controls in graphical applications. Checkboxes are binary toggle controls that allow users to select or deselect options.

**Version:** 1.0.0  
**Function Count:** 90+ functions  
**GC Tag:** `BASIC_CHECKBOX`

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Integration

Add to your Delphi project:

```pascal
uses CheckBoxLib;

// In your initialization code:
RegisterCheckBoxFuncs(FunctionsDict, BasicEngine, ConsoleOutput);
```

## Quick Start

```basic
' Create a simple checkbox
let frm# = form#("My App", 400, 300)
let chk# = checkbox#(frm#, "Enable feature")
checkbox_move#(chk#, 20, 50)
checkbox_onchange#(chk#, "OnCheckChanged")
form_show(frm#)

function OnCheckChanged(sender#) local isChecked
  isChecked = checkbox_ischecked(sender#)
  if isChecked = 1 then
    println "Feature enabled"
  else
    println "Feature disabled"
  endif
endfunction
```

## Function Reference

### Error Handling Functions

| Function | Description |
|----------|-------------|
| `checkbox_error()` | Get last error code (0 = no error) |
| `checkbox_errormsg$()` | Get last error message |
| `checkbox_strerror$(code)` | Convert error code to description |
| `checkbox_clearerror()` | Clear error state |

**Error Codes:**
- 0: No error
- 1: Invalid checkbox pointer
- 2: Invalid parent pointer
- 3: Invalid value
- 4: Failed to create checkbox
- 5: Index out of range

### Creation Functions

| Function | Description |
|----------|-------------|
| `checkbox#(parent#)` | Create checkbox with default settings |
| `checkbox#(parent#, text$)` | Create checkbox with text |
| `checkbox#(parent#, x, y, w, h)` | Create checkbox at position |
| `checkbox#(parent#, text$, x, y, w, h)` | Create checkbox with all parameters |
| `checkbox_free(chk#)` | Free checkbox and remove from GC |

### Checked State Functions

| Function | Description |
|----------|-------------|
| `checkbox_ischecked(chk#)` | Get checked state (0=unchecked, 1=checked) |
| `checkbox_ischecked#(chk#, value)` | Set checked state |

### Text Content Functions

| Function | Description |
|----------|-------------|
| `checkbox_text$(chk#)` | Get checkbox text |
| `checkbox_text#(chk#, text$)` | Set checkbox text |

### Font Properties Functions

| Function | Description |
|----------|-------------|
| `checkbox_fontfamily$(chk#)` | Get font family |
| `checkbox_fontfamily#(chk#, family$)` | Set font family |
| `checkbox_fontsize(chk#)` | Get font size |
| `checkbox_fontsize#(chk#, size)` | Set font size |
| `checkbox_fontcolor$(chk#)` | Get font color (hex format) |
| `checkbox_fontcolor#(chk#, color$)` | Set font color (#RRGGBB or #AARRGGBB) |
| `checkbox_bold(chk#)` | Get bold state (0/1) |
| `checkbox_bold#(chk#, value)` | Set bold state |
| `checkbox_italic(chk#)` | Get italic state (0/1) |
| `checkbox_italic#(chk#, value)` | Set italic state |
| `checkbox_underline(chk#)` | Get underline state (0/1) |
| `checkbox_underline#(chk#, value)` | Set underline state |
| `checkbox_strikeout(chk#)` | Get strikeout state (0/1) |
| `checkbox_strikeout#(chk#, value)` | Set strikeout state |

### Position and Size Functions

| Function | Description |
|----------|-------------|
| `checkbox_x(chk#)` | Get X position |
| `checkbox_x#(chk#, value)` | Set X position |
| `checkbox_y(chk#)` | Get Y position |
| `checkbox_y#(chk#, value)` | Set Y position |
| `checkbox_width(chk#)` | Get width |
| `checkbox_width#(chk#, value)` | Set width |
| `checkbox_height(chk#)` | Get height |
| `checkbox_height#(chk#, value)` | Set height |
| `checkbox_bounds#(chk#, x, y, w, h)` | Set all bounds |
| `checkbox_move#(chk#, x, y)` | Set position |
| `checkbox_size#(chk#, w, h)` | Set size |

### Alignment Functions

| Function | Description |
|----------|-------------|
| `checkbox_align(chk#)` | Get alignment value |
| `checkbox_align#(chk#, value)` | Set alignment value |

**Alignment Values:**
- 0: None (manual positioning)
- 1: Top
- 2: Left
- 3: Right
- 4: Bottom
- 9: Client (fill parent)
- 11: Center

### Margins Functions

| Function | Description |
|----------|-------------|
| `checkbox_marginleft(chk#)` | Get left margin |
| `checkbox_marginleft#(chk#, value)` | Set left margin |
| `checkbox_margintop(chk#)` | Get top margin |
| `checkbox_margintop#(chk#, value)` | Set top margin |
| `checkbox_marginright(chk#)` | Get right margin |
| `checkbox_marginright#(chk#, value)` | Set right margin |
| `checkbox_marginbottom(chk#)` | Get bottom margin |
| `checkbox_marginbottom#(chk#, value)` | Set bottom margin |
| `checkbox_margins#(chk#, l, t, r, b)` | Set all margins |
| `checkbox_margin#(chk#, value)` | Set uniform margin |

### Visibility and State Functions

| Function | Description |
|----------|-------------|
| `checkbox_visible(chk#)` | Get visibility (0/1) |
| `checkbox_visible#(chk#, value)` | Set visibility |
| `checkbox_enabled(chk#)` | Get enabled state (0/1) |
| `checkbox_enabled#(chk#, value)` | Set enabled state |
| `checkbox_opacity(chk#)` | Get opacity (0.0-1.0) |
| `checkbox_opacity#(chk#, value)` | Set opacity |

### Focus Functions

| Function | Description |
|----------|-------------|
| `checkbox_isfocused(chk#)` | Get focus state (0/1) |
| `checkbox_setfocus#(chk#)` | Give focus to checkbox |
| `checkbox_resetfocus#(chk#)` | Remove focus from checkbox |
| `checkbox_taborder(chk#)` | Get tab order |
| `checkbox_taborder#(chk#, value)` | Set tab order |
| `checkbox_canfocus(chk#)` | Get can focus state (0/1) |
| `checkbox_canfocus#(chk#, value)` | Set can focus state |

### Tag and HitTest Functions

| Function | Description |
|----------|-------------|
| `checkbox_tag(chk#)` | Get tag value |
| `checkbox_tag#(chk#, value)` | Set tag value |
| `checkbox_hittest(chk#)` | Get hit test state (0/1) |
| `checkbox_hittest#(chk#, value)` | Set hit test state |
| `checkbox_dragmode(chk#)` | Get drag mode (0=manual, 1=automatic) |
| `checkbox_dragmode#(chk#, value)` | Set drag mode |

### Parent Functions

| Function | Description |
|----------|-------------|
| `checkbox_parent#(chk#)` | Get parent control |
| `checkbox_parent#(chk#, parent#)` | Set parent control |
| `checkbox_bringtofront#(chk#)` | Bring checkbox to front |
| `checkbox_sendtoback#(chk#)` | Send checkbox to back |

### Event Callback Functions

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnChange | `checkbox_onchange#(chk#, func$)` | `checkbox_onchange$(chk#)` | `function name(sender#)` |
| OnClick | `checkbox_onclick#(chk#, func$)` | `checkbox_onclick$(chk#)` | `function name(sender#)` |
| OnDblClick | `checkbox_ondblclick#(chk#, func$)` | `checkbox_ondblclick$(chk#)` | `function name(sender#)` |
| OnEnter | `checkbox_onenter#(chk#, func$)` | `checkbox_onenter$(chk#)` | `function name(sender#)` |
| OnExit | `checkbox_onexit#(chk#, func$)` | `checkbox_onexit$(chk#)` | `function name(sender#)` |
| OnKeyDown | `checkbox_onkeydown#(chk#, func$)` | `checkbox_onkeydown$(chk#)` | `function name(sender#, key, keychar$, shift$)` |
| OnKeyUp | `checkbox_onkeyup#(chk#, func$)` | `checkbox_onkeyup$(chk#)` | `function name(sender#, key, keychar$, shift$)` |
| OnMouseDown | `checkbox_onmousedown#(chk#, func$)` | `checkbox_onmousedown$(chk#)` | `function name(sender#, button, shift$, x, y)` |
| OnMouseUp | `checkbox_onmouseup#(chk#, func$)` | `checkbox_onmouseup$(chk#)` | `function name(sender#, button, shift$, x, y)` |
| OnMouseMove | `checkbox_onmousemove#(chk#, func$)` | `checkbox_onmousemove$(chk#)` | `function name(sender#, shift$, x, y)` |
| OnMouseEnter | `checkbox_onmouseenter#(chk#, func$)` | `checkbox_onmouseenter$(chk#)` | `function name(sender#)` |
| OnMouseLeave | `checkbox_onmouseleave#(chk#, func$)` | `checkbox_onmouseleave$(chk#)` | `function name(sender#)` |
| OnResize | `checkbox_onresize#(chk#, func$)` | `checkbox_onresize$(chk#)` | `function name(sender#)` |

### Drag & Drop Event Functions

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnDragEnter | `checkbox_ondragenter#(chk#, func$)` | `checkbox_ondragenter$(chk#)` | `function name(sender#, x, y)` |
| OnDragOver | `checkbox_ondragover#(chk#, func$)` | `checkbox_ondragover$(chk#)` | `function name(sender#, x, y)` → return 1 to accept |
| OnDragDrop | `checkbox_ondragdrop#(chk#, func$)` | `checkbox_ondragdrop$(chk#)` | `function name(sender#, x, y)` |
| OnDragLeave | `checkbox_ondragleave#(chk#, func$)` | `checkbox_ondragleave$(chk#)` | `function name(sender#)` |

### Clear Callbacks Function

| Function | Description |
|----------|-------------|
| `checkbox_clearcallbacks#(chk#)` | Clear all event callbacks |

## Event Callback Examples

### OnChange Event (Primary Checkbox Event)

```basic
function OnCheckChanged(sender#) local isChecked
  isChecked = checkbox_ischecked(sender#)
  if isChecked = 1 then
    println "Checkbox is now checked"
  else
    println "Checkbox is now unchecked"
  endif
endfunction
```

### OnKeyDown Event

```basic
function OnCheckKeyDown(sender#, key, keychar$, shift$)
  println "Key: " + str$(key) + ", Char: " + keychar$ + ", Shift: " + shift$
endfunction
```

### OnMouseDown Event

```basic
function OnCheckMouseDown(sender#, button, shift$, x, y)
  println "Mouse button " + str$(button) + " pressed at " + str$(x) + "," + str$(y)
endfunction
```

### OnDragOver Event (with return value)

```basic
function OnCheckDragOver(sender#, x, y)
  ' Return 1 to accept the drop, 0 to reject
  return 1
endfunction
```

## Common Usage Patterns

### Creating a Settings Panel

```basic
let frm# = form#("Settings", 400, 300)

' Create option checkboxes
let chkAutoSave# = checkbox#(frm#, "Auto-save documents")
checkbox_bounds#(chkAutoSave#, 20, 20, 200, 22)
checkbox_onchange#(chkAutoSave#, "OnAutoSaveChanged")

let chkSpellCheck# = checkbox#(frm#, "Enable spell check")
checkbox_bounds#(chkSpellCheck#, 20, 50, 200, 22)

let chkDarkMode# = checkbox#(frm#, "Dark mode")
checkbox_bounds#(chkDarkMode#, 20, 80, 200, 22)

form_show(frm#)

function OnAutoSaveChanged(sender#)
  if checkbox_ischecked(sender#) = 1 then
    println "Auto-save enabled"
  else
    println "Auto-save disabled"
  endif
endfunction
```

### Master/Detail Checkbox Pattern

```basic
let chkSelectAll# = Pointer#(0)
let chkItem1# = Pointer#(0)
let chkItem2# = Pointer#(0)
let chkItem3# = Pointer#(0)

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

function OnSelectAllChanged(sender#) local checked
  checked = checkbox_ischecked(chkSelectAll#)
  checkbox_ischecked#(chkItem1#, checked)
  checkbox_ischecked#(chkItem2#, checked)
  checkbox_ischecked#(chkItem3#, checked)
endfunction
```

### Reading Checkbox State

```basic
function GetSelectedOptions() local options$
  options$ = ""
  
  if checkbox_ischecked(chkOption1#) = 1 then
    options$ = options$ + "Option1,"
  endif
  
  if checkbox_ischecked(chkOption2#) = 1 then
    options$ = options$ + "Option2,"
  endif
  
  if checkbox_ischecked(chkOption3#) = 1 then
    options$ = options$ + "Option3,"
  endif
  
  return options$
endfunction
```

## Important Notes

### Pointer Comparison

Plan9Basic does not support direct pointer comparison. Use `PntToNum()`:

```basic
' Correct way to check for null pointer
if PntToNum(chk#) <> 0 then
  ' Checkbox is valid
endif
```

### Local Variables

Local variables must be declared on the same line as the function header:

```basic
' Correct
function MyFunc(param#) local var1, var2$, var3#
  ' function body
endfunction

' Incorrect - will cause errors
function MyFunc(param#)
  local var1, var2$, var3#  ' Wrong!
endfunction
```

### Event Model

Events are connected granularly - only when a callback is set. Setting an empty string disconnects the event:

```basic
' Connect event
checkbox_onchange#(chk#, "MyHandler")

' Disconnect event
checkbox_onchange#(chk#, "")
```

### Garbage Collection

Checkboxes are automatically tracked by the garbage collector with the `BASIC_CHECKBOX` tag. Use `checkbox_free()` for explicit cleanup when needed.

## Version History

### 1.0.0
- Initial release
- Full TCheckBox wrapper implementation
- 90+ functions
- Complete event support including drag & drop
- Cross-platform compatibility
