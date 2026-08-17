# LabelLib - Label Text Control Library for Plan9Basic

**Version:** 1.0.0  
**Function Count:** 82 functions  
**Dependencies:** FormLib or LayoutLib (for parent containers)

## Overview

LabelLib provides complete FireMonkey TLabel wrapper functionality for creating and managing text label controls in Plan9Basic programs. TLabel displays static or dynamic text with full font styling support.

Labels are essential for:
- Displaying titles and headings
- Form field labels
- Status messages
- Dynamic text content
- Clickable text links

## Cross-Platform Support

LabelLib works on all platforms supported by FireMonkey:
- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

---

## Quick Start

### Basic Label

```basic
' Create a form
let frm# = form#("Label Demo", 800, 600)

' Create a simple label
let lbl# = label#(frm#, "Hello, World!")
label_move#(lbl#, 50, 50)

form_show(frm#)
```

### Styled Label

```basic
let frm# = form#("Styled Label", 800, 600)

let title# = label#(frm#, "Welcome to Plan9Basic!")
label_move#(title#, 50, 50)
label_fontsize#(title#, 32)
label_fontcolor#(title#, "#3498db")
label_bold#(title#, 1)

form_show(frm#)
```

### Multi-line Label with Word Wrap

```basic
let frm# = form#("Word Wrap Demo", 800, 600)

let para# = label#(frm#, "This is a long paragraph that will wrap to multiple lines when the text exceeds the width of the label control.", 50, 50, 300, 100)
label_wordwrap#(para#, 1)
label_autosize#(para#, 0)

form_show(frm#)
```

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `label_error()` | Returns last error code (0 = no error) |
| `label_errormsg$()` | Returns last error message |
| `label_strerror$(code)` | Returns description for error code |
| `label_clearerror()` | Clears error state |

**Error Codes:**
| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Invalid or nil label |
| 2 | Invalid parent control |
| 3 | Invalid value |
| 4 | Label creation failed |
| 5 | Invalid callback function |
| 6 | Invalid color value |

---

### Label Creation and Destruction

#### label#(parent#)
Creates a new empty label.

```basic
let lbl# = label#(parentForm#)
```

#### label#(parent#, text$)
Creates a label with specified text.

```basic
let lbl# = label#(parentForm#, "Hello!")
```

#### label#(parent#, text$, x, y)
Creates a label with text and position.

```basic
let lbl# = label#(parentForm#, "Hello!", 50, 50)
```

#### label#(parent#, text$, x, y, width, height)
Creates a label with text, position, and size. AutoSize is disabled.

```basic
let lbl# = label#(parentForm#, "Hello!", 50, 50, 200, 30)
```

#### label_free(label#)
Frees a label and removes it from its parent.

```basic
label_free(myLabel#)
```

---

### Text Content

| Function | Description |
|----------|-------------|
| `label_text$(label#)` | Get label text |
| `label_text#(label#, text$)` | Set label text |

```basic
' Set text
label_text#(lbl#, "New text content")

' Get text
let text$ = label_text$(lbl#)
```

---

### Font Properties

| Function | Description |
|----------|-------------|
| `label_fontfamily$(label#)` | Get font family name |
| `label_fontfamily#(label#, family$)` | Set font family |
| `label_fontsize(label#)` | Get font size |
| `label_fontsize#(label#, size)` | Set font size |
| `label_fontcolor$(label#)` | Get font color as "#AARRGGBB" |
| `label_fontcolor#(label#, color$)` | Set font color |
| `label_bold(label#)` | Get bold state (0/1) |
| `label_bold#(label#, value)` | Set bold (0=off, 1=on) |
| `label_italic(label#)` | Get italic state (0/1) |
| `label_italic#(label#, value)` | Set italic (0=off, 1=on) |
| `label_underline(label#)` | Get underline state (0/1) |
| `label_underline#(label#, value)` | Set underline (0=off, 1=on) |
| `label_strikeout(label#)` | Get strikeout state (0/1) |
| `label_strikeout#(label#, value)` | Set strikeout (0=off, 1=on) |

```basic
' Style a label
label_fontfamily#(lbl#, "Arial")
label_fontsize#(lbl#, 18)
label_fontcolor#(lbl#, "red")
label_bold#(lbl#, 1)
label_italic#(lbl#, 1)
```

---

### Text Alignment

#### Horizontal Alignment
| Value | Alignment |
|-------|-----------|
| 0 | Center |
| 1 | Leading (Left for LTR languages) |
| 2 | Trailing (Right for LTR languages) |

#### Vertical Alignment
| Value | Alignment |
|-------|-----------|
| 0 | Center |
| 1 | Leading (Top) |
| 2 | Trailing (Bottom) |

| Function | Description |
|----------|-------------|
| `label_textalign(label#)` | Get horizontal text alignment |
| `label_textalign#(label#, value)` | Set horizontal text alignment |
| `label_vertalign(label#)` | Get vertical text alignment |
| `label_vertalign#(label#, value)` | Set vertical text alignment |

```basic
' Left-aligned text at top
label_textalign#(lbl#, 1)   ' Leading (left)
label_vertalign#(lbl#, 1)   ' Leading (top)

' Right-aligned text at bottom
label_textalign#(lbl#, 2)   ' Trailing (right)
label_vertalign#(lbl#, 2)   ' Trailing (bottom)

' Centered text (default)
label_textalign#(lbl#, 0)   ' Center
label_vertalign#(lbl#, 0)   ' Center
```

---

### Word Wrap and Auto Size

| Function | Description |
|----------|-------------|
| `label_wordwrap(label#)` | Get word wrap state (0/1) |
| `label_wordwrap#(label#, value)` | Set word wrap (0=off, 1=on) |
| `label_autosize(label#)` | Get auto size state (0/1) |
| `label_autosize#(label#, value)` | Set auto size (0=off, 1=on) |

```basic
' Enable word wrap for multi-line text
label_wordwrap#(lbl#, 1)
label_autosize#(lbl#, 0)  ' Disable auto-size when using word wrap
label_width#(lbl#, 300)   ' Set fixed width
```

**Note:** When `AutoSize` is enabled (default), the label automatically adjusts its size to fit the text. Disable `AutoSize` when you want to control the label dimensions manually, especially for word-wrapped text.

---

### Position and Size

| Function | Description |
|----------|-------------|
| `label_x(label#)` | Get X position |
| `label_x#(label#, value)` | Set X position |
| `label_y(label#)` | Get Y position |
| `label_y#(label#, value)` | Set Y position |
| `label_width(label#)` | Get width |
| `label_width#(label#, value)` | Set width |
| `label_height(label#)` | Get height |
| `label_height#(label#, value)` | Set height |
| `label_bounds#(label#, x, y, w, h)` | Set all bounds at once |
| `label_move#(label#, x, y)` | Set position only |
| `label_size#(label#, w, h)` | Set size only |

```basic
' Position and size
label_move#(lbl#, 100, 100)
label_size#(lbl#, 200, 30)

' Or all at once
label_bounds#(lbl#, 100, 100, 200, 30)
```

---

### Control Alignment

| Function | Description |
|----------|-------------|
| `label_align(label#)` | Get alignment value (0-19) |
| `label_align#(label#, value)` | Set alignment value |

See LayoutLib documentation for full alignment values.

```basic
' Align label to top of parent
label_align#(lbl#, 1)  ' Top
```

---

### Margins

| Function | Description |
|----------|-------------|
| `label_marginleft(label#)` | Get left margin |
| `label_marginleft#(label#, value)` | Set left margin |
| `label_margintop(label#)` | Get top margin |
| `label_margintop#(label#, value)` | Set top margin |
| `label_marginright(label#)` | Get right margin |
| `label_marginright#(label#, value)` | Set right margin |
| `label_marginbottom(label#)` | Get bottom margin |
| `label_marginbottom#(label#, value)` | Set bottom margin |
| `label_margins#(label#, l, t, r, b)` | Set all margins |
| `label_margin#(label#, value)` | Set uniform margin |

---

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `label_visible(label#)` | Get visibility (0/1) |
| `label_visible#(label#, value)` | Set visibility |
| `label_enabled(label#)` | Get enabled state (0/1) |
| `label_enabled#(label#, value)` | Set enabled state |
| `label_opacity(label#)` | Get opacity (0.0-1.0) |
| `label_opacity#(label#, value)` | Set opacity |
| `label_hittest(label#)` | Get hit test flag (0/1) |
| `label_hittest#(label#, value)` | Set hit test flag |

---

### Tag and Rotation

| Function | Description |
|----------|-------------|
| `label_tag(label#)` | Get tag value |
| `label_tag#(label#, value)` | Set tag value |
| `label_rotation(label#)` | Get rotation angle (degrees) |
| `label_rotation#(label#, value)` | Set rotation angle |

---

### Parent and Z-Order

| Function | Description |
|----------|-------------|
| `label_parent#(label#)` | Get parent control |
| `label_parent#(label#, newParent#)` | Set parent control |
| `label_bringtofront#(label#)` | Bring to front of siblings |
| `label_sendtoback#(label#)` | Send to back of siblings |

---

## Event Callbacks

### Available Events

| Event | Callback Signature | Description |
|-------|-------------------|-------------|
| OnClick | `funcname(sender#)` | Label was clicked |
| OnDblClick | `funcname(sender#)` | Label was double-clicked |
| OnMouseDown | `funcname(sender#, button, x, y, shift$)` | Mouse button pressed |
| OnMouseUp | `funcname(sender#, button, x, y, shift$)` | Mouse button released |
| OnMouseMove | `funcname(sender#, x, y, shift$)` | Mouse moved over label |
| OnMouseEnter | `funcname(sender#)` | Mouse entered label |
| OnMouseLeave | `funcname(sender#)` | Mouse left label |
| OnResize | `funcname(sender#, width, height)` | Label was resized |

### Setting Event Handlers

| Function | Description |
|----------|-------------|
| `label_onclick#(label#, funcname$)` | Set OnClick handler |
| `label_onclick$(label#)` | Get OnClick handler name |
| `label_ondblclick#(label#, funcname$)` | Set OnDblClick handler |
| `label_ondblclick$(label#)` | Get OnDblClick handler name |
| `label_onmousedown#(label#, funcname$)` | Set OnMouseDown handler |
| `label_onmousedown$(label#)` | Get OnMouseDown handler name |
| `label_onmouseup#(label#, funcname$)` | Set OnMouseUp handler |
| `label_onmouseup$(label#)` | Get OnMouseUp handler name |
| `label_onmousemove#(label#, funcname$)` | Set OnMouseMove handler |
| `label_onmousemove$(label#)` | Get OnMouseMove handler name |
| `label_onmouseenter#(label#, funcname$)` | Set OnMouseEnter handler |
| `label_onmouseenter$(label#)` | Get OnMouseEnter handler name |
| `label_onmouseleave#(label#, funcname$)` | Set OnMouseLeave handler |
| `label_onmouseleave$(label#)` | Get OnMouseLeave handler name |
| `label_onresize#(label#, funcname$)` | Set OnResize handler |
| `label_onresize$(label#)` | Get OnResize handler name |
| `label_clearcallbacks#(label#)` | Clear all event handlers |

---

## Complete Examples

### Example 1: Form with Title and Subtitle

```basic
let frm# = form#("Title Demo", 600, 400)

' Main title
let title# = label#(frm#, "Welcome to Plan9Basic", 50, 30)
label_fontsize#(title#, 28)
label_fontcolor#(title#, "#2c3e50")
label_bold#(title#, 1)

' Subtitle
let subtitle# = label#(frm#, "Create amazing applets with ease", 50, 70)
label_fontsize#(subtitle#, 16)
label_fontcolor#(subtitle#, "#7f8c8d")
label_italic#(subtitle#, 1)

form_show(frm#)
```

### Example 2: Clickable Link

```basic
let frm# = form#("Link Demo", 600, 400)

let link# = label#(frm#, "Click here for more info", 50, 50)
label_fontcolor#(link#, "blue")
label_underline#(link#, 1)
label_onclick#(link#, "OnLinkClick")
label_onmouseenter#(link#, "OnLinkEnter")
label_onmouseleave#(link#, "OnLinkLeave")

form_show(frm#)

function OnLinkClick(sender#)
  println "Link clicked!"
endfunction

function OnLinkEnter(sender#)
  label_fontcolor#(sender#, "#3498db")
endfunction

function OnLinkLeave(sender#)
  label_fontcolor#(sender#, "blue")
endfunction
```

### Example 3: Counter Display

```basic
let frm# = form#("Counter", 400, 200)

let counter = 0

let countLabel# = label#(frm#, "0", 150, 50)
label_fontsize#(countLabel#, 72)
label_fontcolor#(countLabel#, "#27ae60")
label_bold#(countLabel#, 1)

' Increment button (using rectangle as button)
let btn# = rect#(frm#, 140, 130, 120, 40)
rect_fill#(btn#, "#3498db")
rect_corners#(btn#, 5, 5)
rect_onclick#(btn#, "OnIncrement")

let btnLabel# = label#(frm#, "Increment")
label_move#(btnLabel#, 165, 140)
label_fontcolor#(btnLabel#, "white")
label_hittest#(btnLabel#, 0)  ' Let clicks pass through to button

form_show(frm#)

function OnIncrement(sender#)
  counter = counter + 1
  label_text#(countLabel#, stri$(counter))
endfunction
```

### Example 4: Font Styles Showcase

```basic
let frm# = form#("Font Styles", 600, 400)

let y = 30

' Normal
let lbl1# = label#(frm#, "Normal Text", 50, y)
label_fontsize#(lbl1#, 18)

y = y + 40

' Bold
let lbl2# = label#(frm#, "Bold Text", 50, y)
label_fontsize#(lbl2#, 18)
label_bold#(lbl2#, 1)

y = y + 40

' Italic
let lbl3# = label#(frm#, "Italic Text", 50, y)
label_fontsize#(lbl3#, 18)
label_italic#(lbl3#, 1)

y = y + 40

' Bold + Italic
let lbl4# = label#(frm#, "Bold Italic Text", 50, y)
label_fontsize#(lbl4#, 18)
label_bold#(lbl4#, 1)
label_italic#(lbl4#, 1)

y = y + 40

' Underline
let lbl5# = label#(frm#, "Underlined Text", 50, y)
label_fontsize#(lbl5#, 18)
label_underline#(lbl5#, 1)

y = y + 40

' Strikeout
let lbl6# = label#(frm#, "Strikeout Text", 50, y)
label_fontsize#(lbl6#, 18)
label_strikeout#(lbl6#, 1)

form_show(frm#)
```

### Example 5: Colored Labels

```basic
let frm# = form#("Color Demo", 600, 400)

let colors$(6)
colors$(1) = "#e74c3c"
colors$(2) = "#f39c12"
colors$(3) = "#f1c40f"
colors$(4) = "#2ecc71"
colors$(5) = "#3498db"
colors$(6) = "#9b59b6"

let names$(6)
names$(1) = "Red"
names$(2) = "Orange"
names$(3) = "Yellow"
names$(4) = "Green"
names$(5) = "Blue"
names$(6) = "Purple"

for i = 1 to 6
  let lbl# = label#(frm#, names$(i), 50, 20 + (i - 1) * 50)
  label_fontsize#(lbl#, 24)
  label_fontcolor#(lbl#, colors$(i))
  label_bold#(lbl#, 1)
next

form_show(frm#)
```

### Example 6: Dynamic Text Update

```basic
let frm# = form#("Dynamic Text", 500, 200)

let timeLabel# = label#(frm#, "", 50, 50)
label_fontsize#(timeLabel#, 36)
label_fontcolor#(timeLabel#, "#2c3e50")

form_show(frm#)

' Update every second for 60 seconds
for sec = 0 to 59
  let mins = sec / 60
  let secs = sec mod 60
  let timeStr$ = stri$(mins) + ":" + right$("0" + stri$(secs), 2)
  label_text#(timeLabel#, "Elapsed: " + timeStr$)
  pause(1)
next

label_text#(timeLabel#, "Done!")
```

---

## Best Practices

### 1. Use AutoSize for Simple Labels
Leave AutoSize enabled (default) for single-line labels that should fit their content.

### 2. Disable AutoSize for Fixed-Width Labels
When you need word wrap or a specific label size, disable AutoSize first:
```basic
label_autosize#(lbl#, 0)
label_size#(lbl#, 300, 100)
label_wordwrap#(lbl#, 1)
```

### 3. Disable HitTest for Overlay Labels
When placing labels over interactive controls:
```basic
label_hittest#(lbl#, 0)  ' Clicks pass through to control below
```

### 4. Use Tags for Identification
Store identifiers in tags when handling events for multiple labels:
```basic
label_tag#(lbl#, 1)

function OnLabelClick(sender#) local id
  id = label_tag(sender#)
  println "Label " + stri$(id) + " clicked"
endfunction
```

### 5. Font Size Guidelines
- Headings: 24-36pt
- Body text: 12-16pt
- Captions: 10-12pt

---

## Related Libraries

- **FormLib** - Form/window management (parent container)
- **LayoutLib** - Layout containers for organizing labels
- **RectangleLib** - Visual rectangles (backgrounds, buttons)
- **ButtonLib** - Button controls (coming soon)

---

## Version History

### 1.0.0 (Current)
- Initial release
- 82 functions for label management
- Complete font styling (family, size, color, bold, italic, underline, strikeout)
- Text alignment (horizontal and vertical)
- Word wrap and auto-sizing
- Full event support
- Rotation support

---

*Copyright (c) 2024-2025 Plan9Basic Project*
