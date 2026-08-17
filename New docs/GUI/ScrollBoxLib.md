# ScrollBoxLib - Vertical Scroll Box Container Library for Plan9Basic

## Overview

ScrollBoxLib provides a vertically-scrolling container control. Child controls added to a scroll box can exceed the visible area and be scrolled into view. Based on FireMonkey `TVertScrollBox`.

**Version:** 1.0.0
**Function Count:** 25 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Quick Start

```basic
let frm# = form#("Scroll Demo", 400, 500)

' Create a scroll box filling the form
let sb# = scrollbox#(frm#)
scrollbox_align#(sb#, 9)  ' Client fill

' Add many child controls - they scroll automatically
let i = 0
while i < 30
  let lbl# = label#(sb#, "Item " + str$(i+1), 10, 10 + (i * 30))
  i = i + 1
wend

form_show(frm#)
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
| 5 | MostTop |
| 6 | MostBottom |
| 7 | MostLeft |
| 8 | MostRight |
| 9 | Client (fill available space) |
| 10 | Contents |
| 11 | Center |
| 12 | VertCenter |
| 13 | HorzCenter |
| 14 | Horizontal |
| 15 | Vertical |
| 16 | Scale |
| 17 | Fit |
| 18 | FitLeft |
| 19 | FitRight |

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `scrollbox_error()` | Returns last error code (0 = no error) |
| `scrollbox_clearerror()` | Clears error state |
| `scrollbox_strerror$(code)` | Converts error code to message |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `scrollbox#(parent#)` | Creates scroll box filling parent (Client align) |
| `scrollbox#(parent#, x, y, w, h)` | Creates scroll box at specific bounds |
| `scrollbox_free(sb#)` | Destroys the scroll box |

### Position and Size

| Function | Description |
|----------|-------------|
| `scrollbox_x(sb#)` | Gets X position |
| `scrollbox_y(sb#)` | Gets Y position |
| `scrollbox_move#(sb#, x, y)` | Sets position |
| `scrollbox_width(sb#)` | Gets width |
| `scrollbox_width#(sb#, w)` | Sets width |
| `scrollbox_height(sb#)` | Gets height |
| `scrollbox_height#(sb#, h)` | Sets height |

### Alignment

| Function | Description |
|----------|-------------|
| `scrollbox_align(sb#)` | Gets alignment value |
| `scrollbox_align#(sb#, value)` | Sets alignment (see Alignment Values) |

### Visibility and Opacity

| Function | Description |
|----------|-------------|
| `scrollbox_visible(sb#)` | Gets visibility (1=visible, 0=hidden) |
| `scrollbox_visible#(sb#, value)` | Sets visibility |
| `scrollbox_opacity(sb#)` | Gets opacity (0.0-1.0) |
| `scrollbox_opacity#(sb#, value)` | Sets opacity |

### Tag

| Function | Description |
|----------|-------------|
| `scrollbox_tag(sb#)` | Gets integer tag value |
| `scrollbox_tag#(sb#, value)` | Sets integer tag value |

### Scroll Box Properties

| Function | Description |
|----------|-------------|
| `scrollbox_showscrollbars(sb#)` | Gets scroll bar visibility (1=shown) |
| `scrollbox_showscrollbars#(sb#, value)` | Shows (1) or hides (0) scroll bars |
| `scrollbox_contentwidth(sb#)` | Gets scrollable content width |
| `scrollbox_contentheight(sb#)` | Gets scrollable content height |

---

## Complete Examples

### Example 1: Simple Scrolling List

```basic
let frm# = form#("Scrolling List", 300, 400)

let sb# = scrollbox#(frm#)
scrollbox_align#(sb#, 9)  ' Client fill

' Add 50 labels - only some will be visible at once
let i = 0
while i < 50
  let lbl# = label#(sb#, "Row " + str$(i+1), 10, 10 + (i * 28))
  i = i + 1
wend

form_show(frm#)
```

### Example 2: Partial Area Scroll Box

```basic
let frm# = form#("Partial Scroll", 500, 500)

' Static header
let hdr# = label#(frm#, "Header (does not scroll)", 10, 10)

' Scroll box takes up lower portion of form
let sb# = scrollbox#(frm#, 10, 50, 480, 420)
scrollbox_showscrollbars#(sb#, 1)

let i = 0
while i < 40
  let lbl# = label#(sb#, "Scrollable item " + str$(i+1), 10, 10 + (i * 25))
  i = i + 1
wend

form_show(frm#)
```

### Example 3: Content Dimension Query

```basic
let frm# = form#("Content Size", 400, 300)

let sb# = scrollbox#(frm#, 10, 10, 380, 200)

let i = 0
while i < 20
  let lbl# = label#(sb#, "Item " + str$(i+1), 10, 5 + (i * 30))
  i = i + 1
wend

let infoLbl# = label#(frm#, "", 10, 230)

form_show(frm#)

' Query actual content dimensions after layout
let cw = scrollbox_contentwidth(sb#)
let ch = scrollbox_contentheight(sb#)
label_text#(infoLbl#, "Content: " + str$(cw) + " x " + str$(ch))
```

## Notes

- Child controls added to a scroll box scroll vertically with the box
- Use `scrollbox_align#(sb#, 9)` (Client) to fill the parent container
- `scrollbox_contentwidth` and `scrollbox_contentwidth` return the actual scrollable area dimensions
- The scroll box only scrolls **vertically** (TVertScrollBox)
- Scroll bars are shown by default; use `scrollbox_showscrollbars#` to hide them

## See Also

- LayoutLib - Non-scrolling layout container
- PanelLib - Panel container with border and background
- FormLib - Top-level window
