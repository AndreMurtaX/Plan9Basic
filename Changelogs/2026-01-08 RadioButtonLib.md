# RadioButtonLib - RadioButton Control Library for Plan9Basic

## Overview

RadioButtonLib provides complete FireMonkey TRadioButton wrapper functionality for creating and managing radio button controls in Plan9Basic programs. Radio buttons are used for single-selection choices within a group of options.

**Version:** 1.0.0  
**Function Count:** 90+ functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Key Features

- RadioButton creation and lifecycle management
- IsChecked state control (checked/unchecked)
- **GroupName property for mutual exclusion groups**
- Text content with font styling (family, size, bold, italic, etc.)
- Complete positioning and alignment
- Full event support with BASIC callback integration
- Drag and drop support

## GroupName Functionality

The `GroupName` property is the key feature that distinguishes radio buttons from checkboxes. Radio buttons with the **same GroupName** are mutually exclusive - selecting one automatically deselects all others in the same group.

```basic
' Create a group of radio buttons
let rb1# = radiobutton#(frm#, "Option A")
radiobutton_groupname#(rb1#, "mygroup")

let rb2# = radiobutton#(frm#, "Option B")
radiobutton_groupname#(rb2#, "mygroup")

let rb3# = radiobutton#(frm#, "Option C")
radiobutton_groupname#(rb3#, "mygroup")

' Only one can be selected at a time within "mygroup"
```

Radio buttons with **different GroupNames** or **empty GroupName** operate independently.

---

## Function Reference

### Error Handling Functions

| Function | Description |
|----------|-------------|
| `radiobutton_error@` | Returns the last error code (0 = no error) |
| `radiobutton_errormsg$@` | Returns the last error message |
| `radiobutton_strerror$@n` | Converts error code to description |
| `radiobutton_clearerror@` | Clears the last error |

**Error Codes:**
- 0 = No error
- 1 = Invalid radio button pointer
- 2 = Invalid parent pointer
- 3 = Invalid value
- 4 = Failed to create radio button
- 5 = Index out of range

---

### Creation and Destruction Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton#@#` | parent# | Creates a radio button with default settings |
| `radiobutton#@#$` | parent#, text$ | Creates a radio button with text |
| `radiobutton#@#nnnn` | parent#, x, y, w, h | Creates a radio button with position/size |
| `radiobutton#@#$nnnn` | parent#, text$, x, y, w, h | Creates a radio button with text and position/size |
| `radiobutton_free@#` | rb# | Destroys a radio button |

**Example:**
```basic
let frm# = form#("RadioButton Demo", 400, 300)
let rb# = radiobutton#(frm#, "Select me")
radiobutton_move#(rb#, 50, 50)
```

---

### Checked State Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_ischecked@#` | rb# | Returns 1 if checked, 0 if not |
| `radiobutton_ischecked#@#n` | rb#, value | Sets checked state (0/1), returns pointer |

**Example:**
```basic
radiobutton_ischecked#(rb#, 1)  ' Select this radio button
let isSelected = radiobutton_ischecked(rb#)
```

---

### GroupName Functions (IMPORTANT)

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_groupname$@#` | rb# | Gets the group name |
| `radiobutton_groupname#@#$` | rb#, name$ | Sets the group name, returns pointer |

**Example:**
```basic
' Create mutually exclusive options
let rbSmall# = radiobutton#(frm#, "Small")
radiobutton_groupname#(rbSmall#, "size")

let rbMedium# = radiobutton#(frm#, "Medium")
radiobutton_groupname#(rbMedium#, "size")

let rbLarge# = radiobutton#(frm#, "Large")
radiobutton_groupname#(rbLarge#, "size")

' Pre-select Medium
radiobutton_ischecked#(rbMedium#, 1)
```

---

### Text Content Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_text$@#` | rb# | Gets the text |
| `radiobutton_text#@#$` | rb#, text$ | Sets the text, returns pointer |

---

### Font Properties Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_fontfamily$@#` | rb# | Gets font family |
| `radiobutton_fontfamily#@#$` | rb#, family$ | Sets font family |
| `radiobutton_fontsize@#` | rb# | Gets font size |
| `radiobutton_fontsize#@#n` | rb#, size | Sets font size |
| `radiobutton_fontcolor$@#` | rb# | Gets font color (#RRGGBB) |
| `radiobutton_fontcolor#@#$` | rb#, color$ | Sets font color (#RRGGBB) |
| `radiobutton_bold@#` | rb# | Gets bold state (0/1) |
| `radiobutton_bold#@#n` | rb#, value | Sets bold state |
| `radiobutton_italic@#` | rb# | Gets italic state (0/1) |
| `radiobutton_italic#@#n` | rb#, value | Sets italic state |
| `radiobutton_underline@#` | rb# | Gets underline state (0/1) |
| `radiobutton_underline#@#n` | rb#, value | Sets underline state |
| `radiobutton_strikeout@#` | rb# | Gets strikeout state (0/1) |
| `radiobutton_strikeout#@#n` | rb#, value | Sets strikeout state |

**Example:**
```basic
radiobutton_fontfamily#(rb#, "Arial")
radiobutton_fontsize#(rb#, 14)
radiobutton_fontcolor#(rb#, "#0000FF")
radiobutton_bold#(rb#, 1)
```

---

### Position and Size Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_x@#` | rb# | Gets X position |
| `radiobutton_x#@#n` | rb#, x | Sets X position |
| `radiobutton_y@#` | rb# | Gets Y position |
| `radiobutton_y#@#n` | rb#, y | Sets Y position |
| `radiobutton_width@#` | rb# | Gets width |
| `radiobutton_width#@#n` | rb#, w | Sets width |
| `radiobutton_height@#` | rb# | Gets height |
| `radiobutton_height#@#n` | rb#, h | Sets height |
| `radiobutton_bounds#@#nnnn` | rb#, x, y, w, h | Sets all bounds at once |
| `radiobutton_move#@#nn` | rb#, x, y | Sets position |
| `radiobutton_size#@#nn` | rb#, w, h | Sets size |

---

### Alignment Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_align@#` | rb# | Gets alignment |
| `radiobutton_align#@#n` | rb#, align | Sets alignment |

**Alignment Constants:**
- 0 = None
- 1 = Top
- 2 = Left
- 3 = Right
- 4 = Bottom
- 9 = Client
- 11 = Center

---

### Margin Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_marginleft@#` | rb# | Gets left margin |
| `radiobutton_marginleft#@#n` | rb#, value | Sets left margin |
| `radiobutton_margintop@#` | rb# | Gets top margin |
| `radiobutton_margintop#@#n` | rb#, value | Sets top margin |
| `radiobutton_marginright@#` | rb# | Gets right margin |
| `radiobutton_marginright#@#n` | rb#, value | Sets right margin |
| `radiobutton_marginbottom@#` | rb# | Gets bottom margin |
| `radiobutton_marginbottom#@#n` | rb#, value | Sets bottom margin |
| `radiobutton_margins#@#nnnn` | rb#, l, t, r, b | Sets all margins |
| `radiobutton_margin#@#n` | rb#, value | Sets all margins to same value |

---

### Visibility and State Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_visible@#` | rb# | Gets visibility (0/1) |
| `radiobutton_visible#@#n` | rb#, value | Sets visibility |
| `radiobutton_enabled@#` | rb# | Gets enabled state (0/1) |
| `radiobutton_enabled#@#n` | rb#, value | Sets enabled state |
| `radiobutton_opacity@#` | rb# | Gets opacity (0.0-1.0) |
| `radiobutton_opacity#@#n` | rb#, value | Sets opacity |

---

### Focus Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_isfocused@#` | rb# | Returns 1 if focused |
| `radiobutton_setfocus#@#` | rb# | Sets focus to radio button |
| `radiobutton_resetfocus#@#` | rb# | Removes focus |
| `radiobutton_taborder@#` | rb# | Gets tab order |
| `radiobutton_taborder#@#n` | rb#, order | Sets tab order |
| `radiobutton_canfocus@#` | rb# | Gets can focus state |
| `radiobutton_canfocus#@#n` | rb#, value | Sets can focus state |

---

### Tag Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_tag@#` | rb# | Gets tag value |
| `radiobutton_tag#@#n` | rb#, value | Sets tag value |

---

### HitTest Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_hittest@#` | rb# | Gets hit test state (0/1) |
| `radiobutton_hittest#@#n` | rb#, value | Sets hit test state |

---

### DragMode Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_dragmode@#` | rb# | Gets drag mode |
| `radiobutton_dragmode#@#n` | rb#, mode | Sets drag mode (0=Manual, 1=Automatic) |

---

### Parent Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_parent#@#` | rb# | Gets parent |
| `radiobutton_parent#@##` | rb#, parent# | Sets parent |
| `radiobutton_bringtofront#@#` | rb# | Brings to front of z-order |
| `radiobutton_sendtoback#@#` | rb# | Sends to back of z-order |

---

### Event Callback Functions

All event setters return the radio button pointer for method chaining.

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_onchange#@#$` | rb#, func$ | Sets OnChange callback |
| `radiobutton_onchange$@#` | rb# | Gets OnChange callback name |
| `radiobutton_onclick#@#$` | rb#, func$ | Sets OnClick callback |
| `radiobutton_onclick$@#` | rb# | Gets OnClick callback name |
| `radiobutton_ondblclick#@#$` | rb#, func$ | Sets OnDblClick callback |
| `radiobutton_ondblclick$@#` | rb# | Gets OnDblClick callback name |
| `radiobutton_onenter#@#$` | rb#, func$ | Sets OnEnter callback |
| `radiobutton_onenter$@#` | rb# | Gets OnEnter callback name |
| `radiobutton_onexit#@#$` | rb#, func$ | Sets OnExit callback |
| `radiobutton_onexit$@#` | rb# | Gets OnExit callback name |
| `radiobutton_onkeydown#@#$` | rb#, func$ | Sets OnKeyDown callback |
| `radiobutton_onkeydown$@#` | rb# | Gets OnKeyDown callback name |
| `radiobutton_onkeyup#@#$` | rb#, func$ | Sets OnKeyUp callback |
| `radiobutton_onkeyup$@#` | rb# | Gets OnKeyUp callback name |
| `radiobutton_onmousedown#@#$` | rb#, func$ | Sets OnMouseDown callback |
| `radiobutton_onmousedown$@#` | rb# | Gets OnMouseDown callback name |
| `radiobutton_onmouseup#@#$` | rb#, func$ | Sets OnMouseUp callback |
| `radiobutton_onmouseup$@#` | rb# | Gets OnMouseUp callback name |
| `radiobutton_onmousemove#@#$` | rb#, func$ | Sets OnMouseMove callback |
| `radiobutton_onmousemove$@#` | rb# | Gets OnMouseMove callback name |
| `radiobutton_onmouseenter#@#$` | rb#, func$ | Sets OnMouseEnter callback |
| `radiobutton_onmouseenter$@#` | rb# | Gets OnMouseEnter callback name |
| `radiobutton_onmouseleave#@#$` | rb#, func$ | Sets OnMouseLeave callback |
| `radiobutton_onmouseleave$@#` | rb# | Gets OnMouseLeave callback name |
| `radiobutton_onresize#@#$` | rb#, func$ | Sets OnResize callback |
| `radiobutton_onresize$@#` | rb# | Gets OnResize callback name |

### Drag & Drop Event Callbacks

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_ondragenter#@#$` | rb#, func$ | Sets OnDragEnter callback |
| `radiobutton_ondragenter$@#` | rb# | Gets OnDragEnter callback name |
| `radiobutton_ondragover#@#$` | rb#, func$ | Sets OnDragOver callback |
| `radiobutton_ondragover$@#` | rb# | Gets OnDragOver callback name |
| `radiobutton_ondragdrop#@#$` | rb#, func$ | Sets OnDragDrop callback |
| `radiobutton_ondragdrop$@#` | rb# | Gets OnDragDrop callback name |
| `radiobutton_ondragleave#@#$` | rb#, func$ | Sets OnDragLeave callback |
| `radiobutton_ondragleave$@#` | rb# | Gets OnDragLeave callback name |

---

### Clear Callbacks Function

| Function | Parameters | Description |
|----------|------------|-------------|
| `radiobutton_clearcallbacks#@#` | rb# | Clears all callbacks, **returns pointer** |

**Example:**
```basic
' Clear all event handlers and chain other operations
radiobutton_clearcallbacks#(rb#)
radiobutton_onchange#(rb#, "NewHandler")
```

---

## Event Callback Signatures

### OnChange / OnClick / OnDblClick / OnEnter / OnExit / OnMouseEnter / OnMouseLeave / OnResize / OnDragLeave
```basic
function CallbackName(sender#)
  ' sender# is the radio button pointer
endfunction
```

### OnKeyDown / OnKeyUp
```basic
function CallbackName(sender#, key, keychar$, shift$)
  ' key = virtual key code
  ' keychar$ = character pressed
  ' shift$ = "S"=Shift, "A"=Alt, "C"=Ctrl, "M"=Command
endfunction
```

### OnMouseDown / OnMouseUp
```basic
function CallbackName(sender#, button, shift$, x, y)
  ' button = 1=Left, 2=Right, 3=Middle
  ' shift$ = modifier keys
  ' x, y = mouse position
endfunction
```

### OnMouseMove
```basic
function CallbackName(sender#, shift$, x, y)
  ' shift$ = modifier keys
  ' x, y = mouse position
endfunction
```

### OnDragEnter / OnDragDrop
```basic
function CallbackName(sender#, x, y)
  ' x, y = drop position
endfunction
```

### OnDragOver (must return value)
```basic
function CallbackName(sender#, x, y)
  ' Return non-zero to accept the drag
  return 1
endfunction
```

---

## Complete Example: Survey Form

```basic
' ============================================
' Survey Form Example - RadioButtonLib Demo
' ============================================

let frm# = form#("Customer Survey", 450, 400)

' --- Satisfaction Section ---
let lblSat# = label#(frm#, "How satisfied are you?")
label_move#(lblSat#, 20, 20)
label_fontsize#(lblSat#, 12)
label_bold#(lblSat#, 1)

let rbVerySat# = radiobutton#(frm#, "Very Satisfied")
radiobutton_move#(rbVerySat#, 30, 50)
radiobutton_groupname#(rbVerySat#, "satisfaction")
radiobutton_tag#(rbVerySat#, 5)

let rbSat# = radiobutton#(frm#, "Satisfied")
radiobutton_move#(rbSat#, 30, 75)
radiobutton_groupname#(rbSat#, "satisfaction")
radiobutton_tag#(rbSat#, 4)

let rbNeutral# = radiobutton#(frm#, "Neutral")
radiobutton_move#(rbNeutral#, 30, 100)
radiobutton_groupname#(rbNeutral#, "satisfaction")
radiobutton_tag#(rbNeutral#, 3)

let rbDissat# = radiobutton#(frm#, "Dissatisfied")
radiobutton_move#(rbDissat#, 30, 125)
radiobutton_groupname#(rbDissat#, "satisfaction")
radiobutton_tag#(rbDissat#, 2)

let rbVeryDissat# = radiobutton#(frm#, "Very Dissatisfied")
radiobutton_move#(rbVeryDissat#, 30, 150)
radiobutton_groupname#(rbVeryDissat#, "satisfaction")
radiobutton_tag#(rbVeryDissat#, 1)

' --- Recommendation Section ---
let lblRec# = label#(frm#, "Would you recommend us?")
label_move#(lblRec#, 20, 190)
label_fontsize#(lblRec#, 12)
label_bold#(lblRec#, 1)

let rbYes# = radiobutton#(frm#, "Yes, definitely")
radiobutton_move#(rbYes#, 30, 220)
radiobutton_groupname#(rbYes#, "recommend")

let rbMaybe# = radiobutton#(frm#, "Maybe")
radiobutton_move#(rbMaybe#, 30, 245)
radiobutton_groupname#(rbMaybe#, "recommend")

let rbNo# = radiobutton#(frm#, "No")
radiobutton_move#(rbNo#, 30, 270)
radiobutton_groupname#(rbNo#, "recommend")

' --- Submit Button ---
let btnSubmit# = button#(frm#, "Submit Survey")
button_move#(btnSubmit#, 150, 320)
button_size#(btnSubmit#, 150, 35)
button_onclick#(btnSubmit#, "OnSubmit")

' --- Result Label ---
let lblResult# = label#(frm#, "")
label_move#(lblResult#, 20, 360)
label_fontcolor#(lblResult#, "#006600")

form_show(frm#)

' Submit callback
function OnSubmit(sender#) local score, rec$
  score = 0
  rec$ = ""
  
  ' Check satisfaction selection
  if radiobutton_ischecked(rbVerySat#) = 1 then
    score = 5
  endif
  if radiobutton_ischecked(rbSat#) = 1 then
    score = 4
  endif
  if radiobutton_ischecked(rbNeutral#) = 1 then
    score = 3
  endif
  if radiobutton_ischecked(rbDissat#) = 1 then
    score = 2
  endif
  if radiobutton_ischecked(rbVeryDissat#) = 1 then
    score = 1
  endif
  
  ' Check recommendation selection
  if radiobutton_ischecked(rbYes#) = 1 then
    rec$ = "Yes"
  endif
  if radiobutton_ischecked(rbMaybe#) = 1 then
    rec$ = "Maybe"
  endif
  if radiobutton_ischecked(rbNo#) = 1 then
    rec$ = "No"
  endif
  
  if score = 0 then
    label_text#(lblResult#, "Please select satisfaction level")
    label_fontcolor#(lblResult#, "#CC0000")
  else
    if rec$ = "" then
      label_text#(lblResult#, "Please select recommendation option")
      label_fontcolor#(lblResult#, "#CC0000")
    else
      label_text#(lblResult#, "Score: " + str$(score) + "/5, Recommend: " + rec$)
      label_fontcolor#(lblResult#, "#006600")
    endif
  endif
endfunction
```

---

## Complete Example: Settings Panel

```basic
' ============================================
' Settings Panel Example - Multiple Groups
' ============================================

let frm# = form#("Application Settings", 400, 350)

' --- Theme Selection ---
let lblTheme# = label#(frm#, "Theme:")
label_move#(lblTheme#, 20, 20)
label_bold#(lblTheme#, 1)

let rbLight# = radiobutton#(frm#, "Light")
radiobutton_move#(rbLight#, 30, 45)
radiobutton_groupname#(rbLight#, "theme")
radiobutton_ischecked#(rbLight#, 1)
radiobutton_onchange#(rbLight#, "OnThemeChange")

let rbDark# = radiobutton#(frm#, "Dark")
radiobutton_move#(rbDark#, 30, 70)
radiobutton_groupname#(rbDark#, "theme")
radiobutton_onchange#(rbDark#, "OnThemeChange")

let rbSystem# = radiobutton#(frm#, "System Default")
radiobutton_move#(rbSystem#, 30, 95)
radiobutton_groupname#(rbSystem#, "theme")
radiobutton_onchange#(rbSystem#, "OnThemeChange")

' --- Language Selection ---
let lblLang# = label#(frm#, "Language:")
label_move#(lblLang#, 200, 20)
label_bold#(lblLang#, 1)

let rbEnglish# = radiobutton#(frm#, "English")
radiobutton_move#(rbEnglish#, 210, 45)
radiobutton_groupname#(rbEnglish#, "language")
radiobutton_ischecked#(rbEnglish#, 1)

let rbPortuguese# = radiobutton#(frm#, "Portuguese")
radiobutton_move#(rbPortuguese#, 210, 70)
radiobutton_groupname#(rbPortuguese#, "language")

let rbSpanish# = radiobutton#(frm#, "Spanish")
radiobutton_move#(rbSpanish#, 210, 95)
radiobutton_groupname#(rbSpanish#, "language")

' --- Font Size Selection ---
let lblSize# = label#(frm#, "Font Size:")
label_move#(lblSize#, 20, 140)
label_bold#(lblSize#, 1)

let rbSmall# = radiobutton#(frm#, "Small (10pt)")
radiobutton_move#(rbSmall#, 30, 165)
radiobutton_groupname#(rbSmall#, "fontsize")
radiobutton_fontsize#(rbSmall#, 10)

let rbMedium# = radiobutton#(frm#, "Medium (12pt)")
radiobutton_move#(rbMedium#, 30, 190)
radiobutton_groupname#(rbMedium#, "fontsize")
radiobutton_fontsize#(rbMedium#, 12)
radiobutton_ischecked#(rbMedium#, 1)

let rbLarge# = radiobutton#(frm#, "Large (14pt)")
radiobutton_move#(rbLarge#, 30, 215)
radiobutton_groupname#(rbLarge#, "fontsize")
radiobutton_fontsize#(rbLarge#, 14)

let rbXLarge# = radiobutton#(frm#, "Extra Large (16pt)")
radiobutton_move#(rbXLarge#, 30, 240)
radiobutton_groupname#(rbXLarge#, "fontsize")
radiobutton_fontsize#(rbXLarge#, 16)

' --- Status Label ---
let lblStatus# = label#(frm#, "Theme: Light")
label_move#(lblStatus#, 20, 290)
label_fontcolor#(lblStatus#, "#0066CC")

form_show(frm#)

function OnThemeChange(sender#) local theme$
  if radiobutton_ischecked(rbLight#) = 1 then
    theme$ = "Light"
  endif
  if radiobutton_ischecked(rbDark#) = 1 then
    theme$ = "Dark"
  endif
  if radiobutton_ischecked(rbSystem#) = 1 then
    theme$ = "System Default"
  endif
  label_text#(lblStatus#, "Theme: " + theme$)
endfunction
```

---

## Event Connection Model

Events are connected/disconnected individually when callbacks are set:

- Setting a non-empty callback name connects **ONLY** that specific event
- Setting an empty callback name ("") disconnects **ONLY** that specific event
- No events are connected by default in the constructor

This granular approach ensures optimal performance by connecting only the events actually needed.

```basic
' Connect only the OnChange event
radiobutton_onchange#(rb#, "OnSelectionChanged")

' Later, disconnect it
radiobutton_onchange#(rb#, "")

' Or clear all callbacks at once
radiobutton_clearcallbacks#(rb#)
```

---

## Method Chaining

All setter functions that return a pointer (`#` suffix) enable method chaining:

```basic
' Traditional approach
radiobutton_text#(rb#, "Option A")
radiobutton_groupname#(rb#, "options")
radiobutton_fontsize#(rb#, 12)
radiobutton_bold#(rb#, 1)
radiobutton_move#(rb#, 50, 100)

' With chaining (each function returns the pointer)
let rb# = radiobutton#(frm#, "Option A")
radiobutton_groupname#(radiobutton_fontsize#(radiobutton_bold#(rb#, 1), 12), "options")
```

---

## Notes

1. **GroupName is essential** for proper radio button behavior - always set it for mutually exclusive options
2. Radio buttons with empty or different GroupNames can be selected independently
3. The `clearcallbacks#` function returns the pointer for chaining
4. Use `Tag` property to store additional data (like numeric values for each option)
5. OnChange is the primary event for detecting selection changes
6. All controls are registered with garbage collection for automatic cleanup

---

## See Also

- CheckBoxLib - For multiple selection options
- ButtonLib - For action buttons
- LabelLib - For text labels
- FormLib - For container forms
