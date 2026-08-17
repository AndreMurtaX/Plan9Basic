# RadioButtonLib - Radio Button Control Library for Plan9Basic

## Overview

RadioButtonLib provides functionality for creating and managing radio button controls in Plan9Basic programs. Radio buttons allow users to select one option from a mutually exclusive group of choices.

**Version:** 1.0.0  
**Function Count:** 110 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("Radio Button Demo", 300, 200)
form_position#(frm#, 4)

let lblChoice# = label#(frm#, "Select a color:")
label_move#(lblChoice#, 20, 20)

let rbRed# = radiobutton#(frm#, "Red", 20, 50, 100, 22)
let rbGreen# = radiobutton#(frm#, "Green", 20, 80, 100, 22)
let rbBlue# = radiobutton#(frm#, "Blue", 20, 110, 100, 22)

radiobutton_ischecked#(rbRed#, 1)

radiobutton_onchange#(rbRed#, "OnColorChange")
radiobutton_onchange#(rbGreen#, "OnColorChange")
radiobutton_onchange#(rbBlue#, "OnColorChange")

form_show(frm#)

function OnColorChange(sender#)
  if radiobutton_ischecked(rbRed#) = 1 then
    println "Red selected"
  else if radiobutton_ischecked(rbGreen#) = 1 then
    println "Green selected"
  else if radiobutton_ischecked(rbBlue#) = 1 then
    println "Blue selected"
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
| `radiobutton_error()` | Returns last error code (0 = no error) |
| `radiobutton_errormsg$()` | Returns last error message |
| `radiobutton_strerror$(code)` | Converts error code to message |
| `radiobutton_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `radiobutton#(parent#)` | Create with default size |
| `radiobutton#(parent#, text$)` | Create with text |
| `radiobutton#(parent#, x, y, w, h)` | Create with position and size |
| `radiobutton#(parent#, text$, x, y, w, h)` | Create with text, position, and size |
| `radiobutton_free(rb#)` | Destroy radio button |

### Checked State

| Function | Description |
|----------|-------------|
| `radiobutton_ischecked(rb#)` | Get checked state (0/1) |
| `radiobutton_ischecked#(rb#, value)` | Set checked state |

### Group Name

| Function | Description |
|----------|-------------|
| `radiobutton_groupname$(rb#)` | Get group name |
| `radiobutton_groupname#(rb#, name$)` | Set group name |

Radio buttons with the same GroupName are mutually exclusive within their parent container. By default, all radio buttons on the same parent form are in one group.

### Text

| Function | Description |
|----------|-------------|
| `radiobutton_text$(rb#)` | Get button text |
| `radiobutton_text#(rb#, text$)` | Set button text |

### Font Properties

| Function | Description |
|----------|-------------|
| `radiobutton_fontfamily$(rb#)` | Get font family |
| `radiobutton_fontfamily#(rb#, family$)` | Set font family |
| `radiobutton_fontsize(rb#)` | Get font size |
| `radiobutton_fontsize#(rb#, size)` | Set font size |
| `radiobutton_fontcolor$(rb#)` | Get font color |
| `radiobutton_fontcolor#(rb#, color$)` | Set font color |
| `radiobutton_bold(rb#)` / `radiobutton_bold#(rb#, value)` | Get/set bold (0/1) |
| `radiobutton_italic(rb#)` / `radiobutton_italic#(rb#, value)` | Get/set italic (0/1) |
| `radiobutton_underline(rb#)` / `radiobutton_underline#(rb#, value)` | Get/set underline (0/1) |
| `radiobutton_strikeout(rb#)` / `radiobutton_strikeout#(rb#, value)` | Get/set strikeout (0/1) |

### Position and Size

| Function | Description |
|----------|-------------|
| `radiobutton_x(rb#)` / `radiobutton_x#(rb#, x)` | Get/set X position |
| `radiobutton_y(rb#)` / `radiobutton_y#(rb#, y)` | Get/set Y position |
| `radiobutton_width(rb#)` / `radiobutton_width#(rb#, w)` | Get/set width |
| `radiobutton_height(rb#)` / `radiobutton_height#(rb#, h)` | Get/set height |
| `radiobutton_bounds#(rb#, x, y, w, h)` | Set position and size |
| `radiobutton_move#(rb#, x, y)` | Set position only |
| `radiobutton_size#(rb#, w, h)` | Set size only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `radiobutton_align(rb#)` / `radiobutton_align#(rb#, value)` | Get/set alignment |
| `radiobutton_marginleft(rb#)` / `radiobutton_marginleft#(rb#, value)` | Get/set left margin |
| `radiobutton_margintop(rb#)` / `radiobutton_margintop#(rb#, value)` | Get/set top margin |
| `radiobutton_marginright(rb#)` / `radiobutton_marginright#(rb#, value)` | Get/set right margin |
| `radiobutton_marginbottom(rb#)` / `radiobutton_marginbottom#(rb#, value)` | Get/set bottom margin |
| `radiobutton_margins#(rb#, l, t, r, b)` | Set all margins |
| `radiobutton_margin#(rb#, value)` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `radiobutton_visible(rb#)` / `radiobutton_visible#(rb#, value)` | Get/set visibility (0/1) |
| `radiobutton_enabled(rb#)` / `radiobutton_enabled#(rb#, value)` | Get/set enabled state (0/1) |
| `radiobutton_opacity(rb#)` / `radiobutton_opacity#(rb#, value)` | Get/set opacity (0.0-1.0) |

### Focus

| Function | Description |
|----------|-------------|
| `radiobutton_isfocused(rb#)` | Check if focused (0/1) |
| `radiobutton_setfocus#(rb#)` | Set focus to button |
| `radiobutton_resetfocus#(rb#)` | Remove focus from button |
| `radiobutton_taborder(rb#)` / `radiobutton_taborder#(rb#, value)` | Get/set tab order |
| `radiobutton_canfocus(rb#)` / `radiobutton_canfocus#(rb#, value)` | Get/set whether button can receive focus (0/1) |

### Tag and Parent

| Function | Description |
|----------|-------------|
| `radiobutton_tag(rb#)` / `radiobutton_tag#(rb#, value)` | Get/set tag value |
| `radiobutton_parent#(rb#)` | Get parent |
| `radiobutton_parent#(rb#, parent#)` | Set parent |
| `radiobutton_bringtofront#(rb#)` | Bring to front |
| `radiobutton_sendtoback#(rb#)` | Send to back |

### Hit Testing and Drag

| Function | Description |
|----------|-------------|
| `radiobutton_hittest(rb#)` / `radiobutton_hittest#(rb#, value)` | Get/set hit test (0/1) |
| `radiobutton_dragmode(rb#)` / `radiobutton_dragmode#(rb#, value)` | Get/set drag mode |

---

## Event Callbacks

### Basic Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnChange | `radiobutton_onchange#(rb#, func$)` | `radiobutton_onchange$(rb#)` | `function(sender#)` |
| OnClick | `radiobutton_onclick#(rb#, func$)` | `radiobutton_onclick$(rb#)` | `function(sender#)` |
| OnDblClick | `radiobutton_ondblclick#(rb#, func$)` | `radiobutton_ondblclick$(rb#)` | `function(sender#)` |
| OnEnter | `radiobutton_onenter#(rb#, func$)` | `radiobutton_onenter$(rb#)` | `function(sender#)` |
| OnExit | `radiobutton_onexit#(rb#, func$)` | `radiobutton_onexit$(rb#)` | `function(sender#)` |
| OnResize | `radiobutton_onresize#(rb#, func$)` | `radiobutton_onresize$(rb#)` | `function(sender#)` |

### Keyboard Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnKeyDown | `radiobutton_onkeydown#(rb#, func$)` | `radiobutton_onkeydown$(rb#)` | `function(sender#, key, keychar$, shift$)` |
| OnKeyUp | `radiobutton_onkeyup#(rb#, func$)` | `radiobutton_onkeyup$(rb#)` | `function(sender#, key, keychar$, shift$)` |

### Mouse Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnMouseDown | `radiobutton_onmousedown#(rb#, func$)` | `radiobutton_onmousedown$(rb#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `radiobutton_onmouseup#(rb#, func$)` | `radiobutton_onmouseup$(rb#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `radiobutton_onmousemove#(rb#, func$)` | `radiobutton_onmousemove$(rb#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `radiobutton_onmouseenter#(rb#, func$)` | `radiobutton_onmouseenter$(rb#)` | `function(sender#)` |
| OnMouseLeave | `radiobutton_onmouseleave#(rb#, func$)` | `radiobutton_onmouseleave$(rb#)` | `function(sender#)` |

### Drag Events

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnDragEnter | `radiobutton_ondragenter#(rb#, func$)` | `radiobutton_ondragenter$(rb#)` | `function(sender#, x, y)` |
| OnDragOver | `radiobutton_ondragover#(rb#, func$)` | `radiobutton_ondragover$(rb#)` | `function(sender#, x, y)` |
| OnDragDrop | `radiobutton_ondragdrop#(rb#, func$)` | `radiobutton_ondragdrop$(rb#)` | `function(sender#, x, y)` |
| OnDragLeave | `radiobutton_ondragleave#(rb#, func$)` | `radiobutton_ondragleave$(rb#)` | `function(sender#)` |

### Utility

| Function | Description |
|----------|-------------|
| `radiobutton_clearcallbacks#(rb#)` | Disconnect all event callbacks |



---

## Complete Examples

### Survey Form

```basic
let frm# = form#("Customer Survey", 350, 300)
form_position#(frm#, 4)

' Question 1: Age group
let lblAge# = label#(frm#, "Your age group:")
label_move#(lblAge#, 20, 20)
label_bold#(lblAge#, 1)

let rbAge1# = radiobutton#(frm#, "Under 18", 20, 45, 120, 22)
let rbAge2# = radiobutton#(frm#, "18-35", 20, 70, 120, 22)
let rbAge3# = radiobutton#(frm#, "36-55", 20, 95, 120, 22)
let rbAge4# = radiobutton#(frm#, "Over 55", 20, 120, 120, 22)

radiobutton_groupname#(rbAge1#, "age")
radiobutton_groupname#(rbAge2#, "age")
radiobutton_groupname#(rbAge3#, "age")
radiobutton_groupname#(rbAge4#, "age")

' Question 2: Satisfaction
let lblSat# = label#(frm#, "Satisfaction level:")
label_move#(lblSat#, 180, 20)
label_bold#(lblSat#, 1)

let rbSat1# = radiobutton#(frm#, "Very satisfied", 180, 45, 150, 22)
let rbSat2# = radiobutton#(frm#, "Satisfied", 180, 70, 150, 22)
let rbSat3# = radiobutton#(frm#, "Neutral", 180, 95, 150, 22)
let rbSat4# = radiobutton#(frm#, "Dissatisfied", 180, 120, 150, 22)

radiobutton_groupname#(rbSat1#, "satisfaction")
radiobutton_groupname#(rbSat2#, "satisfaction")
radiobutton_groupname#(rbSat3#, "satisfaction")
radiobutton_groupname#(rbSat4#, "satisfaction")

let btnSubmit# = button#(frm#, "Submit", 125, 200, 100, 35)
button_onclick#(btnSubmit#, "OnSubmit")

let lblResult# = label#(frm#, "")
label_bounds#(lblResult#, 20, 250, 310, 40)

form_show(frm#)

function OnSubmit(sender#) local age$, sat$
  ' Get age selection
  age$ = "Not selected"
  if radiobutton_ischecked(rbAge1#) = 1 then age$ = "Under 18"
  if radiobutton_ischecked(rbAge2#) = 1 then age$ = "18-35"
  if radiobutton_ischecked(rbAge3#) = 1 then age$ = "36-55"
  if radiobutton_ischecked(rbAge4#) = 1 then age$ = "Over 55"
  
  ' Get satisfaction selection
  sat$ = "Not selected"
  if radiobutton_ischecked(rbSat1#) = 1 then sat$ = "Very satisfied"
  if radiobutton_ischecked(rbSat2#) = 1 then sat$ = "Satisfied"
  if radiobutton_ischecked(rbSat3#) = 1 then sat$ = "Neutral"
  if radiobutton_ischecked(rbSat4#) = 1 then sat$ = "Dissatisfied"
  
  label_text#(lblResult#, "Age: " + age$ + " | Satisfaction: " + sat$)
endfunction
```

### Theme Selector

```basic
let frm# = form#("Theme Settings", 280, 200)
form_position#(frm#, 4)

let lblTheme# = label#(frm#, "Select theme:")
label_move#(lblTheme#, 20, 20)

let rbLight# = radiobutton#(frm#, "Light", 20, 50, 100, 22)
let rbDark# = radiobutton#(frm#, "Dark", 20, 80, 100, 22)
let rbSystem# = radiobutton#(frm#, "System Default", 20, 110, 150, 22)

radiobutton_ischecked#(rbLight#, 1)

radiobutton_onchange#(rbLight#, "OnThemeChange")
radiobutton_onchange#(rbDark#, "OnThemeChange")
radiobutton_onchange#(rbSystem#, "OnThemeChange")

let lblPreview# = label#(frm#, "Preview: Light theme")
label_move#(lblPreview#, 20, 150)
label_fontsize#(lblPreview#, 12)

form_show(frm#)

function OnThemeChange(sender#)
  if radiobutton_ischecked(rbLight#) = 1 then
    label_text#(lblPreview#, "Preview: Light theme")
  else if radiobutton_ischecked(rbDark#) = 1 then
    label_text#(lblPreview#, "Preview: Dark theme")
  else if radiobutton_ischecked(rbSystem#) = 1 then
    label_text#(lblPreview#, "Preview: System default")
  endif
endfunction
```

### Payment Method Selection

```basic
let frm# = form#("Payment", 300, 220)
form_position#(frm#, 4)

let lblPay# = label#(frm#, "Payment method:")
label_move#(lblPay#, 20, 20)
label_bold#(lblPay#, 1)

let rbCard# = radiobutton#(frm#, "Credit Card", 20, 50, 150, 22)
let rbPaypal# = radiobutton#(frm#, "PayPal", 20, 80, 150, 22)
let rbBank# = radiobutton#(frm#, "Bank Transfer", 20, 110, 150, 22)
let rbCash# = radiobutton#(frm#, "Cash on Delivery", 20, 140, 150, 22)

radiobutton_ischecked#(rbCard#, 1)

let btnContinue# = button#(frm#, "Continue", 100, 175, 100, 35)
button_onclick#(btnContinue#, "OnContinue")

form_show(frm#)

function OnContinue(sender#) local method$
  method$ = ""
  if radiobutton_ischecked(rbCard#) = 1 then method$ = "Credit Card"
  if radiobutton_ischecked(rbPaypal#) = 1 then method$ = "PayPal"
  if radiobutton_ischecked(rbBank#) = 1 then method$ = "Bank Transfer"
  if radiobutton_ischecked(rbCash#) = 1 then method$ = "Cash on Delivery"
  
  println "Selected payment: " + method$
endfunction
```

### Quiz with Multiple Questions

```basic
let frm# = form#("Quiz", 400, 350)
form_position#(frm#, 4)

' Question 1
let lblQ1# = label#(frm#, "1. What is the capital of France?")
label_move#(lblQ1#, 20, 20)
label_bold#(lblQ1#, 1)

let rbQ1A# = radiobutton#(frm#, "London", 30, 45, 150, 22)
let rbQ1B# = radiobutton#(frm#, "Paris", 30, 70, 150, 22)
let rbQ1C# = radiobutton#(frm#, "Berlin", 30, 95, 150, 22)
radiobutton_groupname#(rbQ1A#, "q1")
radiobutton_groupname#(rbQ1B#, "q1")
radiobutton_groupname#(rbQ1C#, "q1")

' Question 2
let lblQ2# = label#(frm#, "2. What is 7 x 8?")
label_move#(lblQ2#, 20, 130)
label_bold#(lblQ2#, 1)

let rbQ2A# = radiobutton#(frm#, "54", 30, 155, 150, 22)
let rbQ2B# = radiobutton#(frm#, "56", 30, 180, 150, 22)
let rbQ2C# = radiobutton#(frm#, "58", 30, 205, 150, 22)
radiobutton_groupname#(rbQ2A#, "q2")
radiobutton_groupname#(rbQ2B#, "q2")
radiobutton_groupname#(rbQ2C#, "q2")

let btnCheck# = button#(frm#, "Check Answers", 140, 250, 120, 35)
button_onclick#(btnCheck#, "OnCheck")

let lblScore# = label#(frm#, "")
label_move#(lblScore#, 20, 300)
label_fontsize#(lblScore#, 14)

form_show(frm#)

function OnCheck(sender#) local score
  score = 0
  
  ' Check Q1 (correct: Paris)
  if radiobutton_ischecked(rbQ1B#) = 1 then
    score = score + 1
  endif
  
  ' Check Q2 (correct: 56)
  if radiobutton_ischecked(rbQ2B#) = 1 then
    score = score + 1
  endif
  
  label_text#(lblScore#, "Score: " + str$(score) + " / 2")
endfunction
```

---

## Tips and Best Practices

1. **Use GroupName for multiple groups** - Use `radiobutton_groupname#` to create independent radio button groups on the same form
2. **Set a default selection** - Always select one radio button initially with `radiobutton_ischecked#(rb#, 1)`
3. **Use OnChange event** - OnChange fires only when the selection changes, not on every click
4. **Check width for text** - Ensure radio button width is enough to display the full text
5. **Use consistent spacing** - Keep 25-30 pixels vertical spacing between options
6. **Group related options visually** - Use labels and spacing to separate question groups

---

## See Also

- **CheckBoxLib** - For non-exclusive multi-selection
- **ComboBoxLib** - For dropdown selection
- **ButtonLib** - Standard buttons
- **LabelLib** - Text labels

---

*RadioButtonLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
