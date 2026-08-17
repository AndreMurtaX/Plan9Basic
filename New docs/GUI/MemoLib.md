# MemoLib - Multi-Line Text Control Library for Plan9Basic

## Overview

MemoLib provides complete functionality for creating and managing multi-line text edit controls in Plan9Basic programs. Memo is ideal for text areas, notes, code editors, and any multi-line text input.

**Version:** 1.0.0  
**Function Count:** 139 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("Memo Demo", 500, 400)
form_position#(frm#, 4)

let mem# = memo#(frm#, 20, 20, 460, 300)
memo_text#(mem#, "Enter your text here...")
memo_wordwrap#(mem#, 1)

let btnSave# = button#(frm#, "Save", 200, 340, 100, 35)
button_onclick#(btnSave#, "OnSave")

form_show(frm#)

function OnSave(sender#) local txt$
  txt$ = memo_text$(mem#)
  println "Text saved: " + str$(len(txt$)) + " characters"
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

### Text Alignment Values

| Value | Description |
|-------|-------------|
| 0 | Center |
| 1 | Leading (Left for LTR) |
| 2 | Trailing (Right for LTR) |

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `memo_error()` | Returns last error code (0 = no error) |
| `memo_errormsg$()` | Returns last error message |
| `memo_strerror$(code)` | Converts error code to message |
| `memo_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `memo#(parent#)` | Create with default size |
| `memo#(parent#, x, y, w, h)` | Create with position and size |
| `memo#(parent#, x, y, w, h, text$)` | Create with position, size, and text |
| `memo_free(mem#)` | Destroy memo |

### Text Content

| Function | Description |
|----------|-------------|
| `memo_text$(mem#)` | Get all text |
| `memo_text#(mem#, text$)` | Set all text |
| `memo_textlength(mem#)` | Get text length in characters |
| `memo_clear#(mem#)` | Clear all text |

### Lines

| Function | Description |
|----------|-------------|
| `memo_linecount(mem#)` | Get number of lines |
| `memo_line$(mem#, index)` | Get line text (0-based) |
| `memo_line#(mem#, index, text$)` | Set line text |
| `memo_addline#(mem#, text$)` | Add line at end |
| `memo_insertline#(mem#, index, text$)` | Insert line at index |
| `memo_deleteline#(mem#, index)` | Delete line at index |
| `memo_lines$(mem#)` | Get all lines as single string |
| `memo_lines#(mem#, text$)` | Set all lines from string |

### Word Wrap and Scrollbars

| Function | Description |
|----------|-------------|
| `memo_wordwrap(mem#)` | Get word wrap state (0/1) |
| `memo_wordwrap#(mem#, value)` | Set word wrap |
| `memo_showscrollbars(mem#)` | Get scrollbars visibility (0/1) |
| `memo_showscrollbars#(mem#, value)` | Set scrollbars visibility |

### Read-Only

| Function | Description |
|----------|-------------|
| `memo_readonly(mem#)` | Get read-only state (0/1) |
| `memo_readonly#(mem#, value)` | Set read-only |

### Font Properties

| Function | Description |
|----------|-------------|
| `memo_fontfamily$(mem#)` | Get font family |
| `memo_fontfamily#(mem#, family$)` | Set font family |
| `memo_fontsize(mem#)` | Get font size |
| `memo_fontsize#(mem#, size)` | Set font size |
| `memo_fontcolor$(mem#)` | Get font color |
| `memo_fontcolor#(mem#, color$)` | Set font color |
| `memo_bold(mem#)` / `memo_bold#(mem#, value)` | Get/set bold (0/1) |
| `memo_italic(mem#)` / `memo_italic#(mem#, value)` | Get/set italic (0/1) |
| `memo_underline(mem#)` / `memo_underline#(mem#, value)` | Get/set underline (0/1) |
| `memo_strikeout(mem#)` / `memo_strikeout#(mem#, value)` | Get/set strikeout (0/1) |

### Text Alignment

| Function | Description |
|----------|-------------|
| `memo_textalign(mem#)` | Get text alignment |
| `memo_textalign#(mem#, value)` | Set text alignment (0=center, 1=left, 2=right) |

### Selection

| Function | Description |
|----------|-------------|
| `memo_selstart(mem#)` | Get selection start position |
| `memo_selstart#(mem#, pos)` | Set selection start position |
| `memo_sellength(mem#)` | Get selection length |
| `memo_sellength#(mem#, len)` | Set selection length |
| `memo_seltext$(mem#)` | Get selected text |
| `memo_selectall#(mem#)` | Select all text |
| `memo_clearselection#(mem#)` | Clear selection |

### Caret/Cursor Control

| Function | Description |
|----------|-------------|
| `memo_caretpositionline(mem#)` | Get caret line number |
| `memo_caretpositionline#(mem#, line)` | Set caret to line |
| `memo_caretpositionpos(mem#)` | Get caret position in text |
| `memo_caretpositionpos#(mem#, pos)` | Set caret position in text |
| `memo_gotoend#(mem#)` | Move caret to end of text |
| `memo_gotobegin#(mem#)` | Move caret to beginning |

### Clipboard

| Function | Description |
|----------|-------------|
| `memo_copy#(mem#)` | Copy selection to clipboard |
| `memo_cut#(mem#)` | Cut selection to clipboard |
| `memo_paste#(mem#)` | Paste from clipboard |
| `memo_deleteselection#(mem#)` | Delete selected text |

### Position and Size

| Function | Description |
|----------|-------------|
| `memo_x(mem#)` / `memo_x#(mem#, x)` | Get/set X position |
| `memo_y(mem#)` / `memo_y#(mem#, y)` | Get/set Y position |
| `memo_width(mem#)` / `memo_width#(mem#, w)` | Get/set width |
| `memo_height(mem#)` / `memo_height#(mem#, h)` | Get/set height |
| `memo_bounds#(mem#, x, y, w, h)` | Set position and size |
| `memo_move#(mem#, x, y)` | Set position only |
| `memo_size#(mem#, w, h)` | Set size only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `memo_align(mem#)` / `memo_align#(mem#, value)` | Get/set control alignment |
| `memo_marginleft(mem#)` / `memo_marginleft#(mem#, value)` | Get/set left margin |
| `memo_margintop(mem#)` / `memo_margintop#(mem#, value)` | Get/set top margin |
| `memo_marginright(mem#)` / `memo_marginright#(mem#, value)` | Get/set right margin |
| `memo_marginbottom(mem#)` / `memo_marginbottom#(mem#, value)` | Get/set bottom margin |
| `memo_margins#(mem#, l, t, r, b)` | Set all margins |
| `memo_margin#(mem#, value)` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `memo_visible(mem#)` / `memo_visible#(mem#, value)` | Get/set visibility (0/1) |
| `memo_enabled(mem#)` / `memo_enabled#(mem#, value)` | Get/set enabled state (0/1) |
| `memo_opacity(mem#)` / `memo_opacity#(mem#, value)` | Get/set opacity (0.0-1.0) |

### Focus

| Function | Description |
|----------|-------------|
| `memo_isfocused(mem#)` | Check if focused (0/1) |
| `memo_setfocus#(mem#)` | Set focus to memo |
| `memo_resetfocus#(mem#)` | Remove focus from memo |
| `memo_taborder(mem#)` / `memo_taborder#(mem#, value)` | Get/set tab order |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `memo_tag(mem#)` / `memo_tag#(mem#, value)` | Get/set tag value |
| `memo_parent#(mem#)` | Get parent |
| `memo_parent#(mem#, parent#)` | Set parent |
| `memo_bringtofront#(mem#)` | Bring to front |
| `memo_sendtoback#(mem#)` | Send to back |
| `memo_clearcallbacks#(mem#)` | Disconnects all event callbacks |

### Scroll Control

| Function | Description |
|----------|-------------|
| `memo_scrolltop(mem#)` | Get scroll position |
| `memo_scrolltop#(mem#, value)` | Set scroll position |
| `memo_scrolltoend#(mem#)` | Scroll to end of text |

---

## Event Callbacks

### Basic Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnChange | `memo_onchange#(mem#, func$)` | `memo_onchange$(mem#)` | `function(sender#)` |
| OnChangeTracking | `memo_onchangetracking#(mem#, func$)` | `memo_onchangetracking$(mem#)` | `function(sender#)` |
| OnEnter | `memo_onenter#(mem#, func$)` | `memo_onenter$(mem#)` | `function(sender#)` |
| OnExit | `memo_onexit#(mem#, func$)` | `memo_onexit$(mem#)` | `function(sender#)` |
| OnClick | `memo_onclick#(mem#, func$)` | `memo_onclick$(mem#)` | `function(sender#)` |
| OnDblClick | `memo_ondblclick#(mem#, func$)` | `memo_ondblclick$(mem#)` | `function(sender#)` |

### Keyboard Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnKeyDown | `memo_onkeydown#(mem#, func$)` | `memo_onkeydown$(mem#)` | `function(sender#, key, keychar$, shift$)` |
| OnKeyUp | `memo_onkeyup#(mem#, func$)` | `memo_onkeyup$(mem#)` | `function(sender#, key, keychar$, shift$)` |

### Mouse Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnMouseDown | `memo_onmousedown#(mem#, func$)` | `memo_onmousedown$(mem#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `memo_onmouseup#(mem#, func$)` | `memo_onmouseup$(mem#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `memo_onmousemove#(mem#, func$)` | `memo_onmousemove$(mem#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `memo_onmouseenter#(mem#, func$)` | `memo_onmouseenter$(mem#)` | `function(sender#)` |
| OnMouseLeave | `memo_onmouseleave#(mem#, func$)` | `memo_onmouseleave$(mem#)` | `function(sender#)` |
| OnResize | `memo_onresize#(mem#, func$)` | `memo_onresize$(mem#)` | `function(sender#)` |

### Drag Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnDragEnter | `memo_ondragenter#(mem#, func$)` | `memo_ondragenter$(mem#)` | `function(sender#, x, y)` |
| OnDragOver | `memo_ondragover#(mem#, func$)` | `memo_ondragover$(mem#)` | `function(sender#, x, y)` |
| OnDragDrop | `memo_ondragdrop#(mem#, func$)` | `memo_ondragdrop$(mem#)` | `function(sender#, x, y)` |
| OnDragLeave | `memo_ondragleave#(mem#, func$)` | `memo_ondragleave$(mem#)` | `function(sender#)` |

Use `memo_clearcallbacks#(mem#)` to disconnect all events.

### OnChange vs OnChangeTracking

- **OnChange** - Fires when editing is complete (focus lost)
- **OnChangeTracking** - Fires on every keystroke (real-time)

---

## Complete Examples

### Simple Text Editor

```basic
let frm# = form#("Text Editor", 600, 450)
form_position#(frm#, 4)

let mem# = memo#(frm#, 10, 50, 580, 340)
memo_wordwrap#(mem#, 1)
memo_fontfamily#(mem#, "Consolas")
memo_fontsize#(mem#, 12)

let btnNew# = button#(frm#, "New", 10, 10, 70, 30)
let btnCopy# = button#(frm#, "Copy", 90, 10, 70, 30)
let btnPaste# = button#(frm#, "Paste", 170, 10, 70, 30)
let btnSelectAll# = button#(frm#, "Select All", 250, 10, 80, 30)

let lblStatus# = label#(frm#, "Ready")
label_move#(lblStatus#, 10, 400)

button_onclick#(btnNew#, "OnNew")
button_onclick#(btnCopy#, "OnCopy")
button_onclick#(btnPaste#, "OnPaste")
button_onclick#(btnSelectAll#, "OnSelectAll")

memo_onchangetracking#(mem#, "OnTextChange")

form_show(frm#)


function OnNew(sender#)
  memo_clear#(mem#)
  label_text#(lblStatus#, "New document")
endfunction

function OnCopy(sender#)
  memo_copy#(mem#)
  label_text#(lblStatus#, "Copied to clipboard")
endfunction

function OnPaste(sender#)
  memo_paste#(mem#)
  label_text#(lblStatus#, "Pasted from clipboard")
endfunction

function OnSelectAll(sender#)
  memo_selectall#(mem#)
  label_text#(lblStatus#, "All text selected")
endfunction

function OnTextChange(sender#) local lines, chars
  lines = memo_linecount(sender#)
  chars = memo_textlength(sender#)
  label_text#(lblStatus#, "Lines: " + str$(lines) + " | Chars: " + str$(chars))
endfunction
```

### Log Viewer (Read-Only)

```basic
let frm# = form#("Log Viewer", 600, 400)
form_position#(frm#, 4)

let mem# = memo#(frm#, 10, 10, 580, 340)
memo_readonly#(mem#, 1)
memo_wordwrap#(mem#, 0)
memo_fontfamily#(mem#, "Courier New")
memo_fontsize#(mem#, 10)

let btnAdd# = button#(frm#, "Add Log Entry", 10, 360, 120, 30)
let btnClear# = button#(frm#, "Clear", 140, 360, 80, 30)

button_onclick#(btnAdd#, "OnAddLog")
button_onclick#(btnClear#, "OnClear")

form_show(frm#)


function OnAddLog(sender#) local ts$
  ts$ = formatdatetime$("yyyy-mm-dd hh:nn:ss", now())
  memo_addline#(mem#, "[" + ts$ + "] Log entry added")
  memo_scrolltoend#(mem#)
endfunction

function OnClear(sender#)
  memo_clear#(mem#)
endfunction
```

### Notes with Statistics

```basic
let frm# = form#("Notes", 500, 380)
form_position#(frm#, 4)

let mem# = memo#(frm#, 10, 10, 480, 300)
memo_wordwrap#(mem#, 1)

let lblLines# = label#(frm#, "Lines: 1")
label_move#(lblLines#, 10, 320)

let lblChars# = label#(frm#, "Characters: 0")
label_move#(lblChars#, 10, 345)

memo_onchangetracking#(mem#, "UpdateStats")

form_show(frm#)

function UpdateStats(sender#) local lines, chars
  lines = memo_linecount(sender#)
  chars = memo_textlength(sender#)
  label_text#(lblLines#, "Lines: " + str$(lines))
  label_text#(lblChars#, "Characters: " + str$(chars))
endfunction
```

### Code Editor Style

```basic
let frm# = form#("Code Editor", 700, 500)
form_position#(frm#, 4)

let mem# = memo#(frm#, 10, 50, 680, 400)
memo_wordwrap#(mem#, 0)
memo_fontfamily#(mem#, "Consolas")
memo_fontsize#(mem#, 13)
memo_showscrollbars#(mem#, 1)

' Sample code
memo_addline#(mem#, "' Plan9Basic Sample")
memo_addline#(mem#, "let x = 10")
memo_addline#(mem#, "let y = 20")
memo_addline#(mem#, "")
memo_addline#(mem#, "function Add(a, b)")
memo_addline#(mem#, "  return a + b")
memo_addline#(mem#, "endfunction")
memo_addline#(mem#, "")
memo_addline#(mem#, "println Add(x, y)")

let lblLine# = label#(frm#, "Line: 1")
label_move#(lblLine#, 10, 460)

memo_onclick#(mem#, "OnMemoClick")

form_show(frm#)

function OnMemoClick(sender#) local line
  line = memo_caretpositionline(sender#)
  label_text#(lblLine#, "Line: " + str$(line + 1))
endfunction
```

### Working with Lines

```basic
let frm# = form#("Line Operations", 500, 400)
form_position#(frm#, 4)

let mem# = memo#(frm#, 10, 10, 350, 300)

memo_addline#(mem#, "Line 1")
memo_addline#(mem#, "Line 2")
memo_addline#(mem#, "Line 3")

let btnInsert# = button#(frm#, "Insert at 1", 370, 10, 120, 30)
let btnDelete# = button#(frm#, "Delete Line 0", 370, 50, 120, 30)
let btnGetLine# = button#(frm#, "Get Line 0", 370, 90, 120, 30)
let btnSetLine# = button#(frm#, "Set Line 0", 370, 130, 120, 30)

let lblResult# = label#(frm#, "")
label_bounds#(lblResult#, 10, 320, 480, 60)
label_wordwrap#(lblResult#, 1)

button_onclick#(btnInsert#, "OnInsert")
button_onclick#(btnDelete#, "OnDelete")
button_onclick#(btnGetLine#, "OnGetLine")
button_onclick#(btnSetLine#, "OnSetLine")

form_show(frm#)


function OnInsert(sender#)
  memo_insertline#(mem#, 1, "Inserted Line")
  label_text#(lblResult#, "Inserted new line at index 1")
endfunction

function OnDelete(sender#)
  if memo_linecount(mem#) > 0 then
    memo_deleteline#(mem#, 0)
    label_text#(lblResult#, "Deleted line at index 0")
  endif
endfunction

function OnGetLine(sender#) local txt$
  if memo_linecount(mem#) > 0 then
    txt$ = memo_line$(mem#, 0)
    label_text#(lblResult#, "Line 0: " + txt$)
  endif
endfunction

function OnSetLine(sender#)
  if memo_linecount(mem#) > 0 then
    memo_line#(mem#, 0, "Modified Line")
    label_text#(lblResult#, "Line 0 modified")
  endif
endfunction
```

### Selection and Clipboard

```basic
let frm# = form#("Selection Demo", 500, 400)
form_position#(frm#, 4)

let mem# = memo#(frm#, 10, 10, 350, 300)
memo_text#(mem#, "Select some text in this memo and use the buttons to manipulate the selection.")

let btnGetSel# = button#(frm#, "Get Selection", 370, 10, 120, 30)
let btnCopy# = button#(frm#, "Copy", 370, 50, 120, 30)
let btnCut# = button#(frm#, "Cut", 370, 90, 120, 30)
let btnPaste# = button#(frm#, "Paste", 370, 130, 120, 30)
let btnDeleteSel# = button#(frm#, "Delete Sel", 370, 170, 120, 30)

let lblInfo# = label#(frm#, "")
label_bounds#(lblInfo#, 10, 320, 480, 60)
label_wordwrap#(lblInfo#, 1)

button_onclick#(btnGetSel#, "OnGetSel")
button_onclick#(btnCopy#, "OnCopy")
button_onclick#(btnCut#, "OnCut")
button_onclick#(btnPaste#, "OnPaste")
button_onclick#(btnDeleteSel#, "OnDeleteSel")

form_show(frm#)

function OnGetSel(sender#) local start, length, txt$
  start = memo_selstart(mem#)
  length = memo_sellength(mem#)
  txt$ = memo_seltext$(mem#)
  label_text#(lblInfo#, "Start: " + str$(start) + ", Length: " + str$(length) + ", Text: " + txt$)
endfunction

function OnCopy(sender#)
  memo_copy#(mem#)
  label_text#(lblInfo#, "Copied to clipboard")
endfunction

function OnCut(sender#)
  memo_cut#(mem#)
  label_text#(lblInfo#, "Cut to clipboard")
endfunction

function OnPaste(sender#)
  memo_paste#(mem#)
  label_text#(lblInfo#, "Pasted from clipboard")
endfunction

function OnDeleteSel(sender#)
  memo_deleteselection#(mem#)
  label_text#(lblInfo#, "Selection deleted")
endfunction
```

---

## Tips and Best Practices

1. **Use WordWrap for prose** - Enable for notes, disable for code
2. **Use ReadOnly for logs** - Prevent user editing of output
3. **Use monospace fonts for code** - Consolas, Courier New
4. **Use OnChangeTracking sparingly** - Fires on every keystroke
5. **Use memo_scrolltoend# after adding lines** - Keeps latest content visible
6. **Use Lines for structured data** - Access by line number with memo_line$
7. **Use memo_lines$ / memo_lines#** - Get/set all text preserving line structure

---

## See Also

- **FormLib** - Form management
- **EditLib** - Single-line text input
- **LabelLib** - Text labels
- **ButtonLib** - Button controls

---

*MemoLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
