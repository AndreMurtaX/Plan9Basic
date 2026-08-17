# MemoLib - Multi-line Text Memo Control Library for Plan9Basic

## Overview

MemoLib provides complete FireMonkey TMemo wrapper functionality for creating and managing multi-line text input controls in Plan9Basic programs. TMemo is the primary multi-line text entry control with full editing capabilities, word wrap, and scroll support.

**Version:** 1.0.0  
**Function Count:** 130+ functions  
**Cross-Platform:** Windows, macOS, Linux, Android, iOS

## Features

- Memo creation and lifecycle management
- Multi-line text content with line-based operations
- Word wrap and scroll bar control
- Full font styling (family, size, bold, italic, color)
- Text alignment
- Selection and caret control
- Clipboard operations (copy, cut, paste)
- Scroll position control
- Complete positioning and alignment
- Full event support with BASIC callback integration

## Quick Start

```basic
' Create a form with a multi-line text memo
let frm# = form#("Memo Demo", 500, 400)
form_position#(frm#, 4)

' Create a memo control
let mem# = memo#(frm#, 20, 20, 460, 300)
memo_wordwrap#(mem#, 1)
memo_fontsize#(mem#, 12)

' Add some lines
memo_addline#(mem#, "Line 1: Hello World")
memo_addline#(mem#, "Line 2: This is a memo")
memo_addline#(mem#, "Line 3: Multi-line text!")

' Set up change tracking
memo_onchangetracking#(mem#, "OnMemoChange")

form_show(frm#)

function OnMemoChange(sender#)
  println "Lines: " + stri$(memo_linecount(sender#))
endfunction
```

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `memo_error@` | Returns the last error code |
| `memo_errormsg$@` | Returns the last error message |
| `memo_strerror$@n` | Returns description for error code |
| `memo_clearerror@` | Clears the last error |

**Error Codes:**
- 0 = No error
- 1 = Invalid memo control
- 2 = Invalid parent control
- 3 = Invalid value
- 4 = Failed to create memo
- 5 = Index out of bounds

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `memo#@#` | Create memo with parent only |
| `memo#@#nnnn` | Create memo with parent, x, y, width, height |
| `memo#@#nnnn$` | Create memo with parent, x, y, width, height, text |
| `memo_free@#` | Free memo control |

### Text Content

| Function | Description |
|----------|-------------|
| `memo_text$@#` | Get all text content |
| `memo_text#@#$` | Set all text content |
| `memo_textlength@#` | Get total text length |
| `memo_clear#@#` | Clear all text |

### Line-Based Operations

| Function | Description |
|----------|-------------|
| `memo_linecount@#` | Get number of lines |
| `memo_line$@#n` | Get text of line at index (0-based) |
| `memo_line#@#n$` | Set text of line at index |
| `memo_addline#@#$` | Add a new line at end |
| `memo_insertline#@#n$` | Insert line at index |
| `memo_deleteline#@#n` | Delete line at index |
| `memo_lines$@#` | Get all lines as single string |
| `memo_lines#@#$` | Set all lines from string |

### Word Wrap and Scroll

| Function | Description |
|----------|-------------|
| `memo_wordwrap@#` | Get word wrap state (0/1) |
| `memo_wordwrap#@#n` | Enable/disable word wrap |
| `memo_showscrollbars@#` | Get scroll bars visibility (0/1) |
| `memo_showscrollbars#@#n` | Show/hide scroll bars |
| `memo_scrolltop@#` | Get vertical scroll position |
| `memo_scrolltop#@#n` | Set vertical scroll position |
| `memo_scrolltoend#@#` | Scroll to end of text |

### Read-Only Mode

| Function | Description |
|----------|-------------|
| `memo_readonly@#` | Get read-only mode (0/1) |
| `memo_readonly#@#n` | Set read-only mode |

### Font Properties

| Function | Description |
|----------|-------------|
| `memo_fontfamily$@#` | Get font family name |
| `memo_fontfamily#@#$` | Set font family name |
| `memo_fontsize@#` | Get font size |
| `memo_fontsize#@#n` | Set font size |
| `memo_fontcolor$@#` | Get font color |
| `memo_fontcolor#@#$` | Set font color |
| `memo_bold@#` | Get bold style (0/1) |
| `memo_bold#@#n` | Set bold style |
| `memo_italic@#` | Get italic style (0/1) |
| `memo_italic#@#n` | Set italic style |

### Text Alignment

| Function | Description |
|----------|-------------|
| `memo_textalign@#` | Get text alignment |
| `memo_textalign#@#n` | Set text alignment |

**Alignment Values:**
- 0 = Leading (Left)
- 1 = Center
- 2 = Trailing (Right)

### Selection

| Function | Description |
|----------|-------------|
| `memo_selstart@#` | Get selection start position |
| `memo_selstart#@#n` | Set selection start position |
| `memo_sellength@#` | Get selection length |
| `memo_sellength#@#n` | Set selection length |
| `memo_seltext$@#` | Get selected text |
| `memo_selectall#@#` | Select all text |
| `memo_clearselection#@#` | Clear selection |

### Caret Control

| Function | Description |
|----------|-------------|
| `memo_caretpositionline@#` | Get caret line (0-based) |
| `memo_caretpositionpos@#` | Get caret position in line |
| `memo_caretpositionline#@#n` | Set caret line |
| `memo_caretpositionpos#@#n` | Set caret position in line |
| `memo_gotoend#@#` | Move caret to end |
| `memo_gotobegin#@#` | Move caret to beginning |

### Clipboard Operations

| Function | Description |
|----------|-------------|
| `memo_copy#@#` | Copy selection to clipboard |
| `memo_cut#@#` | Cut selection to clipboard |
| `memo_paste#@#` | Paste from clipboard |
| `memo_deleteselection#@#` | Delete selected text |

### Position and Size

| Function | Description |
|----------|-------------|
| `memo_x@#` | Get X position |
| `memo_x#@#n` | Set X position |
| `memo_y@#` | Get Y position |
| `memo_y#@#n` | Set Y position |
| `memo_width@#` | Get width |
| `memo_width#@#n` | Set width |
| `memo_height@#` | Get height |
| `memo_height#@#n` | Set height |
| `memo_bounds#@#nnnn` | Set bounds (x, y, width, height) |
| `memo_move#@#nn` | Set position (x, y) |
| `memo_size#@#nn` | Set size (width, height) |

### Alignment

| Function | Description |
|----------|-------------|
| `memo_align@#` | Get alignment within parent |
| `memo_align#@#n` | Set alignment within parent |

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
| `memo_marginleft@#` | Get left margin |
| `memo_marginleft#@#n` | Set left margin |
| `memo_margintop@#` | Get top margin |
| `memo_margintop#@#n` | Set top margin |
| `memo_marginright@#` | Get right margin |
| `memo_marginright#@#n` | Set right margin |
| `memo_marginbottom@#` | Get bottom margin |
| `memo_marginbottom#@#n` | Set bottom margin |
| `memo_margins#@#nnnn` | Set all margins (l, t, r, b) |
| `memo_margin#@#n` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `memo_visible@#` | Get visibility (0/1) |
| `memo_visible#@#n` | Set visibility |
| `memo_enabled@#` | Get enabled state (0/1) |
| `memo_enabled#@#n` | Set enabled state |
| `memo_opacity@#` | Get opacity (0.0-1.0) |
| `memo_opacity#@#n` | Set opacity |

### Focus Control

| Function | Description |
|----------|-------------|
| `memo_isfocused@#` | Check if focused (0/1) |
| `memo_setfocus#@#` | Set focus to memo |
| `memo_resetfocus#@#` | Remove focus |
| `memo_taborder@#` | Get tab order |
| `memo_taborder#@#n` | Set tab order |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `memo_tag@#` | Get tag value |
| `memo_tag#@#n` | Set tag value |
| `memo_parent#@#` | Get parent |
| `memo_parent#@##` | Set parent |
| `memo_bringtofront#@#` | Bring to front |
| `memo_sendtoback#@#` | Send to back |

### Events

| Function | Description | Callback Signature |
|----------|-------------|-------------------|
| `memo_onchange#@#$` | Text changed event | `function(sender#)` |
| `memo_onchangetracking#@#$` | Real-time text tracking | `function(sender#)` |
| `memo_onenter#@#$` | Focus gained | `function(sender#)` |
| `memo_onexit#@#$` | Focus lost | `function(sender#)` |
| `memo_onkeydown#@#$` | Key pressed | `function(sender#, key, keychar$, shift$)` |
| `memo_onkeyup#@#$` | Key released | `function(sender#, key, keychar$, shift$)` |
| `memo_onclick#@#$` | Click event | `function(sender#)` |
| `memo_ondblclick#@#$` | Double-click event | `function(sender#)` |
| `memo_onmousedown#@#$` | Mouse button pressed | `function(sender#, button, x, y, shift$)` |
| `memo_onmouseup#@#$` | Mouse button released | `function(sender#, button, x, y, shift$)` |
| `memo_onmousemove#@#$` | Mouse moved | `function(sender#, x, y, shift$)` |
| `memo_onmouseenter#@#$` | Mouse entered | `function(sender#)` |
| `memo_onmouseleave#@#$` | Mouse left | `function(sender#)` |
| `memo_onresize#@#$` | Memo resized | `function(sender#)` |
| `memo_clearcallbacks#@#` | Clear all callbacks | N/A |

## Common Use Cases

### Simple Text Editor

```basic
let frm# = form#("Text Editor", 600, 400)
form_position#(frm#, 4)

let mem# = memo#(frm#, 10, 10, 580, 350)
memo_wordwrap#(mem#, 1)
memo_showscrollbars#(mem#, 1)
memo_fontfamily#(mem#, "Consolas")
memo_fontsize#(mem#, 11)

form_show(frm#)
```

### Log Viewer (Read-Only)

```basic
let frm# = form#("Log Viewer", 500, 300)
form_position#(frm#, 4)

let mem# = memo#(frm#, 10, 10, 480, 280)
memo_readonly#(mem#, 1)
memo_wordwrap#(mem#, 0)
memo_fontfamily#(mem#, "Courier New")
memo_fontsize#(mem#, 10)

' Add log entries
memo_addline#(mem#, "[INFO] Application started")
memo_addline#(mem#, "[DEBUG] Loading configuration...")
memo_addline#(mem#, "[INFO] Configuration loaded")
memo_scrolltoend#(mem#)

form_show(frm#)
```

### Notes Editor with Line Count

```basic
let frm# = form#("Notes", 400, 350)
form_position#(frm#, 4)

let lblStatus# = label#(frm#, "Lines: 0")
label_move#(lblStatus#, 10, 10)

let mem# = memo#(frm#, 10, 35, 380, 280)
memo_wordwrap#(mem#, 1)
memo_onchangetracking#(mem#, "UpdateStatus")

form_show(frm#)

function UpdateStatus(sender#) local cnt
  cnt = memo_linecount(sender#)
  println "Lines: " + stri$(cnt)
endfunction
```

## Color Format

Colors are specified as strings:
- Named colors: "red", "blue", "green", "black", "white", "navy", "teal", "maroon", etc.
- Hex RGB: "#RRGGBB" (e.g., "#FF5500")
- Hex ARGB: "#AARRGGBB" (e.g., "#80FF5500" for semi-transparent)

## Line Index

Line operations use **0-based indexing**:
- First line = index 0
- Last line = memo_linecount(mem#) - 1

## Best Practices

1. **Enable word wrap for prose** - Set `memo_wordwrap#(mem#, 1)` for natural text
2. **Disable word wrap for code** - Set `memo_wordwrap#(mem#, 0)` for code/logs
3. **Use monospace fonts for code** - "Consolas", "Courier New", "Monaco"
4. **Use OnChangeTracking sparingly** - Fires on every keystroke
5. **Use OnChange for validation** - Fires when editing is complete
6. **Scroll to end for logs** - Call `memo_scrolltoend#()` after adding lines

## Differences from EditLib (TEdit)

| Feature | TMemo | TEdit |
|---------|-------|-------|
| Lines | Multiple | Single |
| Word Wrap | Yes | No |
| Scroll Bars | Yes | No |
| Line Operations | Yes | No |
| Password Mode | No | Yes |
| Filter Characters | No | Yes |
| Keyboard Type | No | Yes (mobile) |

## See Also

- EditLib - Single-line text input
- FormLib - Form management
- LabelLib - Text labels
- LayoutLib - Container layouts
