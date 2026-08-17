# SpeedButtonLib - Speed Button Control Library for Plan9Basic

## Overview

SpeedButtonLib provides functionality for creating and managing speed button controls in Plan9Basic programs. SpeedButtons are flat, graphical buttons ideal for toolbars, toggle buttons, and grouped button sets.

**Version:** 1.0.0  
**Function Count:** 90+ functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("SpeedButton Demo", 400, 300)
form_position#(frm#, 4)

let btn1# = speedbutton#(frm#, "Bold", 10, 10, 60, 30)
let btn2# = speedbutton#(frm#, "Italic", 75, 10, 60, 30)
let btn3# = speedbutton#(frm#, "Underline", 140, 10, 80, 30)

' Enable toggle behavior
speedbutton_stayspressed#(btn1#, 1)
speedbutton_stayspressed#(btn2#, 1)
speedbutton_stayspressed#(btn3#, 1)

' Group buttons (only one can be pressed)
speedbutton_groupindex#(btn1#, 1)
speedbutton_groupindex#(btn2#, 1)
speedbutton_groupindex#(btn3#, 1)

speedbutton_onclick#(btn1#, "OnButtonClick")
speedbutton_onclick#(btn2#, "OnButtonClick")
speedbutton_onclick#(btn3#, "OnButtonClick")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnButtonClick(sender#) local txt$
  txt$ = speedbutton_text$(sender#)
  if speedbutton_down(sender#) = 1 then
    println txt$ + " is ON"
  else
    println txt$ + " is OFF"
  endif
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

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `speedbutton_error()` | Returns last error code (0 = no error) |
| `speedbutton_errormsg$()` | Returns last error message |
| `speedbutton_strerror$(code)` | Converts error code to message |
| `speedbutton_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `speedbutton#(parent#)` | Create with default size |
| `speedbutton#(parent#, text$)` | Create with text |
| `speedbutton#(parent#, x, y, w, h)` | Create with position and size |
| `speedbutton#(parent#, text$, x, y, w, h)` | Create with text, position, and size |
| `speedbutton_free(btn#)` | Destroy speedbutton |

### Text

| Function | Description |
|----------|-------------|
| `speedbutton_text$(btn#)` | Get button text |
| `speedbutton_text#(btn#, text$)` | Set button text |

### Font Properties

| Function | Description |
|----------|-------------|
| `speedbutton_fontfamily$(btn#)` | Get font family |
| `speedbutton_fontfamily#(btn#, family$)` | Set font family |
| `speedbutton_fontsize(btn#)` | Get font size |
| `speedbutton_fontsize#(btn#, size)` | Set font size |
| `speedbutton_fontcolor$(btn#)` | Get font color |
| `speedbutton_fontcolor#(btn#, color$)` | Set font color |
| `speedbutton_bold(btn#)` / `speedbutton_bold#(btn#, value)` | Get/set bold (0/1) |
| `speedbutton_italic(btn#)` / `speedbutton_italic#(btn#, value)` | Get/set italic (0/1) |
| `speedbutton_underline(btn#)` / `speedbutton_underline#(btn#, value)` | Get/set underline (0/1) |
| `speedbutton_strikeout(btn#)` / `speedbutton_strikeout#(btn#, value)` | Get/set strikeout (0/1) |

### SpeedButton-Specific Properties

| Function | Description |
|----------|-------------|
| `speedbutton_groupindex(btn#)` | Get group index (0 = no group) |
| `speedbutton_groupindex#(btn#, value)` | Set group index |
| `speedbutton_stayspressed(btn#)` | Get toggle mode (0/1) |
| `speedbutton_stayspressed#(btn#, value)` | Set toggle mode |
| `speedbutton_down(btn#)` | Get pressed state (0/1) |
| `speedbutton_down#(btn#, value)` | Set pressed state |

### Position and Size

| Function | Description |
|----------|-------------|
| `speedbutton_x(btn#)` / `speedbutton_x#(btn#, x)` | Get/set X position |
| `speedbutton_y(btn#)` / `speedbutton_y#(btn#, y)` | Get/set Y position |
| `speedbutton_width(btn#)` / `speedbutton_width#(btn#, w)` | Get/set width |
| `speedbutton_height(btn#)` / `speedbutton_height#(btn#, h)` | Get/set height |
| `speedbutton_bounds#(btn#, x, y, w, h)` | Set position and size |
| `speedbutton_move#(btn#, x, y)` | Set position only |
| `speedbutton_size#(btn#, w, h)` | Set size only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `speedbutton_align(btn#)` / `speedbutton_align#(btn#, value)` | Get/set alignment |
| `speedbutton_marginleft(btn#)` / `speedbutton_marginleft#(btn#, value)` | Get/set left margin |
| `speedbutton_margintop(btn#)` / `speedbutton_margintop#(btn#, value)` | Get/set top margin |
| `speedbutton_marginright(btn#)` / `speedbutton_marginright#(btn#, value)` | Get/set right margin |
| `speedbutton_marginbottom(btn#)` / `speedbutton_marginbottom#(btn#, value)` | Get/set bottom margin |
| `speedbutton_margins#(btn#, l, t, r, b)` | Set all margins |
| `speedbutton_margin#(btn#, value)` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `speedbutton_visible(btn#)` / `speedbutton_visible#(btn#, value)` | Get/set visibility (0/1) |
| `speedbutton_enabled(btn#)` / `speedbutton_enabled#(btn#, value)` | Get/set enabled state (0/1) |
| `speedbutton_opacity(btn#)` / `speedbutton_opacity#(btn#, value)` | Get/set opacity (0.0-1.0) |
| `speedbutton_hittest(btn#)` / `speedbutton_hittest#(btn#, value)` | Get/set hit test (0/1) |
| `speedbutton_dragmode(btn#)` / `speedbutton_dragmode#(btn#, value)` | Get/set drag mode (0/1) |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `speedbutton_tag(btn#)` / `speedbutton_tag#(btn#, value)` | Get/set tag value |
| `speedbutton_parent#(btn#)` | Get parent |
| `speedbutton_parent#(btn#, parent#)` | Set parent |
| `speedbutton_bringtofront#(btn#)` | Bring to front |
| `speedbutton_sendtoback#(btn#)` | Send to back |

---

## Event Callbacks

### Basic Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `speedbutton_onclick#(btn#, func$)` | `speedbutton_onclick$(btn#)` | `function(sender#)` |
| OnResize | `speedbutton_onresize#(btn#, func$)` | `speedbutton_onresize$(btn#)` | `function(sender#)` |

### Mouse Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnMouseDown | `speedbutton_onmousedown#(btn#, func$)` | `speedbutton_onmousedown$(btn#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `speedbutton_onmouseup#(btn#, func$)` | `speedbutton_onmouseup$(btn#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `speedbutton_onmousemove#(btn#, func$)` | `speedbutton_onmousemove$(btn#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `speedbutton_onmouseenter#(btn#, func$)` | `speedbutton_onmouseenter$(btn#)` | `function(sender#)` |
| OnMouseLeave | `speedbutton_onmouseleave#(btn#, func$)` | `speedbutton_onmouseleave$(btn#)` | `function(sender#)` |

### Drag Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnDragEnter | `speedbutton_ondragenter#(btn#, func$)` | `speedbutton_ondragenter$(btn#)` | `function(sender#, x, y)` |
| OnDragOver | `speedbutton_ondragover#(btn#, func$)` | `speedbutton_ondragover$(btn#)` | `function(sender#, x, y)` |
| OnDragDrop | `speedbutton_ondragdrop#(btn#, func$)` | `speedbutton_ondragdrop$(btn#)` | `function(sender#, x, y)` |
| OnDragLeave | `speedbutton_ondragleave#(btn#, func$)` | `speedbutton_ondragleave$(btn#)` | `function(sender#)` |

### Utility

| Function | Description |
|----------|-------------|
| `speedbutton_clearcallbacks#(btn#)` | Disconnect all event callbacks |



---

## Complete Examples

### Toolbar with Toggle Buttons

```basic
let frm# = form#("Toolbar Demo", 500, 350)
form_position#(frm#, 4)

' Create toolbar panel
let toolbar# = panel#(frm#, 0, 0, 500, 40)
panel_align#(toolbar#, 1)

' Create formatting buttons
let btnBold# = speedbutton#(toolbar#, "B", 5, 5, 30, 30)
let btnItalic# = speedbutton#(toolbar#, "I", 40, 5, 30, 30)
let btnUnder# = speedbutton#(toolbar#, "U", 75, 5, 30, 30)

' Style the buttons
speedbutton_bold#(btnBold#, 1)
speedbutton_italic#(btnItalic#, 1)
speedbutton_underline#(btnUnder#, 1)

' Enable toggle behavior (independent toggles)
speedbutton_stayspressed#(btnBold#, 1)
speedbutton_stayspressed#(btnItalic#, 1)
speedbutton_stayspressed#(btnUnder#, 1)

' Text area
let mem# = memo#(frm#, 10, 50, 480, 290)
memo_align#(mem#, 9)
memo_margin#(mem#, 10)

speedbutton_onclick#(btnBold#, "UpdateStyle")
speedbutton_onclick#(btnItalic#, "UpdateStyle")
speedbutton_onclick#(btnUnder#, "UpdateStyle")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function UpdateStyle(sender#)
  memo_bold#(mem#, speedbutton_down(btnBold#))
  memo_italic#(mem#, speedbutton_down(btnItalic#))
  memo_underline#(mem#, speedbutton_down(btnUnder#))
endfunction
```

### Radio Button Group

```basic
let frm# = form#("Alignment Options", 300, 200)
form_position#(frm#, 4)

let lbl# = label#(frm#, "Select Alignment:")
label_move#(lbl#, 20, 20)

' Create mutually exclusive button group
let btnLeft# = speedbutton#(frm#, "Left", 20, 50, 80, 30)
let btnCenter# = speedbutton#(frm#, "Center", 105, 50, 80, 30)
let btnRight# = speedbutton#(frm#, "Right", 190, 50, 80, 30)

' Same group index = mutually exclusive
speedbutton_groupindex#(btnLeft#, 1)
speedbutton_groupindex#(btnCenter#, 1)
speedbutton_groupindex#(btnRight#, 1)

' Start with Left selected
speedbutton_down#(btnLeft#, 1)

let lblResult# = label#(frm#, "Current: Left")
label_move#(lblResult#, 20, 100)

speedbutton_onclick#(btnLeft#, "OnAlign")
speedbutton_onclick#(btnCenter#, "OnAlign")
speedbutton_onclick#(btnRight#, "OnAlign")

form_show(frm#)

function OnAlign(sender#) local txt$
  txt$ = speedbutton_text$(sender#)
  label_text#(lblResult#, "Current: " + txt$)
endfunction
```

### Tool Palette

```basic
let frm# = form#("Tool Palette", 200, 300)
form_position#(frm#, 4)

' Tool buttons - mutually exclusive
let btnSelect# = speedbutton#(frm#, "Select", 10, 10, 80, 30)
let btnPen# = speedbutton#(frm#, "Pen", 10, 45, 80, 30)
let btnBrush# = speedbutton#(frm#, "Brush", 10, 80, 80, 30)
let btnEraser# = speedbutton#(frm#, "Eraser", 10, 115, 80, 30)
let btnFill# = speedbutton#(frm#, "Fill", 10, 150, 80, 30)

' Configure all as toggle buttons in same group
let i = 0
let btns# = Pointer#(0)

'speedbutton_stayspressed#(btnSelect#, 1)
'speedbutton_stayspressed#(btnPen#, 1)
'speedbutton_stayspressed#(btnBrush#, 1)
'speedbutton_stayspressed#(btnEraser#, 1)
'speedbutton_stayspressed#(btnFill#, 1)

'speedbutton_groupindex#(btnSelect#, 1)
'speedbutton_groupindex#(btnPen#, 1)
'speedbutton_groupindex#(btnBrush#, 1)
'speedbutton_groupindex#(btnEraser#, 1)
'speedbutton_groupindex#(btnFill#, 1)

' Select tool by default
speedbutton_down#(btnSelect#, 1)

let lblTool# = label#(frm#, "Tool: Select")
label_move#(lblTool#, 10, 200)

speedbutton_onclick#(btnSelect#, "OnTool")
speedbutton_onclick#(btnPen#, "OnTool")
speedbutton_onclick#(btnBrush#, "OnTool")
speedbutton_onclick#(btnEraser#, "OnTool")
speedbutton_onclick#(btnFill#, "OnTool")

form_show(frm#)

function OnTool(sender#)
  label_text#(lblTool#, "Tool: " + speedbutton_text$(sender#))
endfunction
```

---

## Tips and Best Practices

1. **Use GroupIndex for mutual exclusion** - Buttons with same GroupIndex (> 0) act like radio buttons
2. **GroupIndex 0 means independent** - Button operates without affecting others
3. **StaysPressed enables toggle** - Without it, button only shows pressed while clicking
4. **Check Down state for toggle status** - Use `speedbutton_down()` to check if toggled on
5. **Ideal for toolbars** - Flat appearance works well in toolbar layouts
6. **Combine with panels** - Place in Panel controls for organized toolbar layout

---

## See Also

- **ButtonLib** - Standard push buttons
- **CheckBoxLib** - Checkbox controls
- **RadioButtonLib** - Radio button controls
- **PanelLib** - Container for toolbars

---

*SpeedButtonLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
