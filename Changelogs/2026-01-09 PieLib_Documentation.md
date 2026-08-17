# PieLib - Pie Visual Control Library

## Overview

**PieLib** provides complete functionality for creating and managing pie (wedge/slice) visual controls in Plan9Basic programs. A pie is a visual shape that draws a pie slice (filled wedge) defined by start and end angles, with lines connecting the arc endpoints to the center.

**Version:** 1.0.0  
**Total Functions:** 77 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Pie Angle Concepts

Angles are specified in degrees (0-360), following the convention:

```
         270° (Top)
            |
   180° ----+---- 0° (Right)
   (Left)   |
          90° (Bottom)
```

The pie slice is drawn clockwise from `StartAngle` to `EndAngle`.

### Angle Examples

| StartAngle | EndAngle | Result |
|------------|----------|--------|
| 0 | 90 | Quarter pie (bottom-right quadrant) |
| 0 | 180 | Half pie (bottom half) |
| 0 | 270 | Three-quarter pie |
| 0 | 360 | Full circle |
| 45 | 135 | 90° slice between positions 45° and 135° |
| 30 | 330 | "Pac-Man" style pie (mouth open) |

## Pie vs Arc

- **TPie**: Draws a pie slice (wedge) with lines from arc endpoints to center
- **TArc**: Draws only the curved arc portion of an ellipse

Use PieLib for:
- Pie charts
- Pac-Man style graphics
- Gauges and meters with filled wedges
- Progress indicators (filled style)
- Any wedge or slice shape

Use ArcLib for:
- Circular progress indicators (outline style)
- Curved lines
- Partial circle outlines

## Function Quick Reference

### Error Handling (4 functions)

| Function | Description |
|----------|-------------|
| `pie_error@` | Returns the last error code |
| `pie_errormsg$@` | Returns the last error message |
| `pie_strerror$@n` | Returns description for error code |
| `pie_clearerror@` | Clears the error state |

### Creation/Destruction (4 functions)

| Function | Description |
|----------|-------------|
| `pie#@#` | Create pie with parent |
| `pie#@#nn` | Create pie with parent and size (width, height) |
| `pie#@#nnnn` | Create pie with parent, position and size (x, y, w, h) |
| `pie_free@#` | Explicitly free a pie |

### Pie Angles (5 functions)

| Function | Description |
|----------|-------------|
| `pie_startangle@#` | Get start angle |
| `pie_startangle#@#n` | Set start angle |
| `pie_endangle@#` | Get end angle |
| `pie_endangle#@#n` | Set end angle |
| `pie_angles#@#nn` | Set both angles at once |

### Fill (3 functions)

| Function | Description |
|----------|-------------|
| `pie_fill$@#` | Get fill color |
| `pie_fill#@#$` | Set fill color |
| `pie_fillnone#@#` | Remove fill (transparent) |

### Stroke (10 functions)

| Function | Description |
|----------|-------------|
| `pie_stroke$@#` | Get stroke color |
| `pie_stroke#@#$` | Set stroke color |
| `pie_strokenone#@#` | Remove stroke |
| `pie_strokethickness@#` | Get stroke thickness |
| `pie_strokethickness#@#n` | Set stroke thickness |
| `pie_strokedash@#` | Get dash style |
| `pie_strokedash#@#n` | Set dash style |
| `pie_strokecap@#` | Get cap style |
| `pie_strokecap#@#n` | Set cap style |
| `pie_strokejoin@#` | Get join style |
| `pie_strokejoin#@#n` | Set join style |

### Position and Size (11 functions)

| Function | Description |
|----------|-------------|
| `pie_x@#` | Get X position |
| `pie_x#@#n` | Set X position |
| `pie_y@#` | Get Y position |
| `pie_y#@#n` | Set Y position |
| `pie_width@#` | Get width |
| `pie_width#@#n` | Set width |
| `pie_height@#` | Get height |
| `pie_height#@#n` | Set height |
| `pie_bounds#@#nnnn` | Set bounds (x, y, width, height) |
| `pie_size#@#nn` | Set size (width, height) |
| `pie_move#@#nn` | Set position (x, y) |

### Alignment (2 functions)

| Function | Description |
|----------|-------------|
| `pie_align@#` | Get alignment |
| `pie_align#@#n` | Set alignment |

### Margins (10 functions)

| Function | Description |
|----------|-------------|
| `pie_marginleft@#` | Get left margin |
| `pie_marginleft#@#n` | Set left margin |
| `pie_margintop@#` | Get top margin |
| `pie_margintop#@#n` | Set top margin |
| `pie_marginright@#` | Get right margin |
| `pie_marginright#@#n` | Set right margin |
| `pie_marginbottom@#` | Get bottom margin |
| `pie_marginbottom#@#n` | Set bottom margin |
| `pie_margins#@#nnnn` | Set all margins (left, top, right, bottom) |
| `pie_margin#@#n` | Set uniform margin |

### Visibility and Behavior (8 functions)

| Function | Description |
|----------|-------------|
| `pie_visible@#` | Get visibility state |
| `pie_visible#@#n` | Set visibility (0=hidden, 1=visible) |
| `pie_enabled@#` | Get enabled state |
| `pie_enabled#@#n` | Set enabled state |
| `pie_opacity@#` | Get opacity (0.0-1.0) |
| `pie_opacity#@#n` | Set opacity |
| `pie_hittest@#` | Get hit test state |
| `pie_hittest#@#n` | Set hit test state |

### Tag and Rotation (4 functions)

| Function | Description |
|----------|-------------|
| `pie_tag@#` | Get tag value |
| `pie_tag#@#n` | Set tag value |
| `pie_rotation@#` | Get control rotation |
| `pie_rotation#@#n` | Set control rotation |

**Note:** `pie_rotation` rotates the entire control, not the pie slice itself. Use `pie_startangle` and `pie_endangle` to control which portion of the pie is visible.

### Parent and Z-Order (4 functions)

| Function | Description |
|----------|-------------|
| `pie_parent#@#` | Get parent control |
| `pie_parent#@##` | Set parent control |
| `pie_bringtofront#@#` | Bring to front |
| `pie_sendtoback#@#` | Send to back |

### Invalidation (1 function)

| Function | Description |
|----------|-------------|
| `pie_invalidate#@#` | Trigger repaint |

### Event Callbacks (21 functions)

| Function | Description |
|----------|-------------|
| `pie_onclick#@#$` | Set onclick callback |
| `pie_onclick$@#` | Get onclick callback name |
| `pie_ondblclick#@#$` | Set ondblclick callback |
| `pie_ondblclick$@#` | Get ondblclick callback name |
| `pie_onmousedown#@#$` | Set onmousedown callback |
| `pie_onmousedown$@#` | Get onmousedown callback name |
| `pie_onmouseup#@#$` | Set onmouseup callback |
| `pie_onmouseup$@#` | Get onmouseup callback name |
| `pie_onmousemove#@#$` | Set onmousemove callback |
| `pie_onmousemove$@#` | Get onmousemove callback name |
| `pie_onmouseenter#@#$` | Set onmouseenter callback |
| `pie_onmouseenter$@#` | Get onmouseenter callback name |
| `pie_onmouseleave#@#$` | Set onmouseleave callback |
| `pie_onmouseleave$@#` | Get onmouseleave callback name |
| `pie_onmousewheel#@#$` | Set onmousewheel callback |
| `pie_onmousewheel$@#` | Get onmousewheel callback name |
| `pie_onresize#@#$` | Set onresize callback |
| `pie_onresize$@#` | Get onresize callback name |
| `pie_clearcallbacks#@#` | Clear all callbacks |

## Constants

### Error Codes

| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Invalid pie |
| 2 | Invalid parent |
| 3 | Invalid value |
| 4 | Creation failed |
| 5 | Invalid callback |
| 6 | Invalid color |

### Alignment Values

| Value | Name | Description |
|-------|------|-------------|
| 0 | None | No alignment |
| 1 | Top | Align to top |
| 2 | Left | Align to left |
| 3 | Right | Align to right |
| 4 | Bottom | Align to bottom |
| 9 | Client | Fill client area |
| 11 | Center | Centered |

### Stroke Dash Styles

| Value | Name | Description |
|-------|------|-------------|
| 0 | Solid | Solid line (default) |
| 1 | Dash | Dashed |
| 2 | Dot | Dotted |
| 3 | DashDot | Dash-dot |
| 4 | DashDotDot | Dash-dot-dot |

### Stroke Cap Styles

| Value | Name | Description |
|-------|------|-------------|
| 0 | Flat | Flat (default) |
| 1 | Round | Rounded |

### Stroke Join Styles

| Value | Name | Description |
|-------|------|-------------|
| 0 | Miter | Sharp corner (default) |
| 1 | Round | Rounded |
| 2 | Bevel | Beveled |

## Color Format

Colors can be specified in two formats:

### Named Colors
```basic
pie_fill#(p#, "red")
pie_fill#(p#, "blue")
pie_fill#(p#, "transparent")
```

Available colors: black, white, red, green, blue, yellow, cyan, magenta, gray, silver, maroon, olive, navy, purple, teal, orange, pink, brown, lime, aqua, fuchsia, transparent, null

### Hexadecimal Format

```basic
' RGB
pie_fill#(p#, "#FF0000")      ' Red

' ARGB (with alpha)
pie_fill#(p#, "#80FF0000")    ' Semi-transparent red
```

## Event Callback Signatures

### OnClick / OnDblClick
```basic
function OnPieClick(sender#)
  println "Pie clicked!"
endfunction
```

### OnMouseDown / OnMouseUp
```basic
function OnPieMouseDown(sender#, button, x, y, shift$)
  ' button: 0=left, 1=right, 2=middle
  ' shift$: combination of S=Shift, C=Ctrl, A=Alt, M=Command
  println "Mouse button: " + stri$(button)
endfunction
```

### OnMouseMove
```basic
function OnPieMouseMove(sender#, x, y, shift$)
  println "Mouse at: " + stri$(x) + ", " + stri$(y)
endfunction
```

### OnMouseEnter / OnMouseLeave
```basic
function OnPieMouseEnter(sender#)
  pie_fill#(sender#, "#FFA500")  ' Orange on hover
endfunction

function OnPieMouseLeave(sender#)
  pie_fill#(sender#, "#3498db")  ' Restore original color
endfunction
```

### OnMouseWheel
```basic
function OnPieMouseWheel(sender#, delta, shift$)
  println "Wheel rotation: " + stri$(delta)
endfunction
```

### OnResize
```basic
function OnPieResize(sender#)
  println "Pie resized"
endfunction
```

## Usage Examples

### Basic Example - Creating a Pie Slice

```basic
let frm# = form#("Pie Demo", 800, 600)

' Create a quarter-pie slice
let p# = pie#(frm#, 50, 50, 100, 100)
pie_angles#(p#, 0, 90)
pie_fill#(p#, "#3498db")
pie_stroke#(p#, "#2980b9")
pie_strokethickness#(p#, 2)

form_show(frm#)
```

### Example - Animated Pac-Man

```basic
let frm# = form#("Pac-Man", 400, 400)

' Create Pac-Man
let pacman# = pie#(frm#, 150, 150, 100, 100)
pie_angles#(pacman#, 30, 330)
pie_fill#(pacman#, "#f1c40f")
pie_stroke#(pacman#, "#f39c12")
pie_strokethickness#(pacman#, 2)
pie_onclick#(pacman#, "AnimateMouth")

let mouthOpen = 1

form_show(frm#)

function AnimateMouth(sender#)
  if mouthOpen = 1 then
    pie_angles#(sender#, 5, 355)
    let mouthOpen = 0
  else
    pie_angles#(sender#, 30, 330)
    let mouthOpen = 1
  endif
endfunction
```

### Example - Circular Progress Indicator (Filled Style)

```basic
let frm# = form#("Progress", 300, 300)

' Background circle (full)
let bgPie# = pie#(frm#, 75, 75, 150, 150)
pie_angles#(bgPie#, 0, 360)
pie_fill#(bgPie#, "#ecf0f1")
pie_strokenone#(bgPie#)

' Progress pie
let progressPie# = pie#(frm#, 75, 75, 150, 150)
pie_angles#(progressPie#, 270, 270)  ' Starts at top
pie_fill#(progressPie#, "#3498db")
pie_strokenone#(progressPie#)

let lblPercent# = label#(frm#, "0%", 130, 140)

form_show(frm#)

' Function to update progress (0-100)
function UpdateProgress(percent)
  ' Convert percentage to angle (270° = top)
  let endAngle = 270 + (percent * 3.6)
  if endAngle > 360 then
    let endAngle = endAngle - 360
  endif
  pie_angles#(progressPie#, 270, endAngle)
  label_text#(lblPercent#, stri$(percent) + "%")
endfunction
```

### Example - Simple Pie Chart

```basic
let frm# = form#("Pie Chart", 400, 400)

' Data: 40%, 25%, 20%, 15%
let centerX = 100
let centerY = 100
let size = 200

' Slice 1: 40% (0 to 144°)
let slice1# = pie#(frm#, centerX, centerY, size, size)
pie_angles#(slice1#, 0, 144)
pie_fill#(slice1#, "#3498db")
pie_stroke#(slice1#, "white")
pie_strokethickness#(slice1#, 2)

' Slice 2: 25% (144 to 234°)
let slice2# = pie#(frm#, centerX, centerY, size, size)
pie_angles#(slice2#, 144, 234)
pie_fill#(slice2#, "#2ecc71")
pie_stroke#(slice2#, "white")
pie_strokethickness#(slice2#, 2)

' Slice 3: 20% (234 to 306°)
let slice3# = pie#(frm#, centerX, centerY, size, size)
pie_angles#(slice3#, 234, 306)
pie_fill#(slice3#, "#f1c40f")
pie_stroke#(slice3#, "white")
pie_strokethickness#(slice3#, 2)

' Slice 4: 15% (306 to 360°)
let slice4# = pie#(frm#, centerX, centerY, size, size)
pie_angles#(slice4#, 306, 360)
pie_fill#(slice4#, "#e74c3c")
pie_stroke#(slice4#, "white")
pie_strokethickness#(slice4#, 2)

form_show(frm#)
```

### Example - Gauge with Colored Zones

```basic
let frm# = form#("Gauge", 400, 300)

' Green zone (0-60%)
let greenZone# = pie#(frm#, 100, 50, 200, 200)
pie_angles#(greenZone#, 180, 288)  ' 60% of 180°
pie_fill#(greenZone#, "#2ecc71")
pie_stroke#(greenZone#, "#27ae60")
pie_strokethickness#(greenZone#, 1)

' Yellow zone (60-80%)
let yellowZone# = pie#(frm#, 100, 50, 200, 200)
pie_angles#(yellowZone#, 288, 324)  ' 20% of 180°
pie_fill#(yellowZone#, "#f1c40f")
pie_stroke#(yellowZone#, "#f39c12")
pie_strokethickness#(yellowZone#, 1)

' Red zone (80-100%)
let redZone# = pie#(frm#, 100, 50, 200, 200)
pie_angles#(redZone#, 324, 360)  ' 20% of 180°
pie_fill#(redZone#, "#e74c3c")
pie_stroke#(redZone#, "#c0392b")
pie_strokethickness#(redZone#, 1)

' Center cover (to create donut effect)
let center# = circle#(frm#, 150, 100, 100, 100)
circle_fill#(center#, "white")
circle_strokenone#(center#)

form_show(frm#)
```

### Example - Interactive Pie with Click Events

```basic
let frm# = form#("Interactive Pie", 400, 400)
let clickCount = 0

let pie1# = pie#(frm#, 150, 150, 100, 100)
pie_angles#(pie1#, 30, 330)
pie_fill#(pie1#, "#f1c40f")
pie_stroke#(pie1#, "#f39c12")
pie_strokethickness#(pie1#, 3)

' Set up event callbacks
pie_onclick#(pie1#, "OnClick")
pie_onmouseenter#(pie1#, "OnEnter")
pie_onmouseleave#(pie1#, "OnLeave")

let lblStatus# = label#(frm#, "Click the Pac-Man!", 130, 280)

form_show(frm#)

function OnClick(sender#)
  let clickCount = clickCount + 1
  label_text#(lblStatus#, "Clicked " + stri$(clickCount) + " times!")
endfunction

function OnEnter(sender#)
  pie_fill#(sender#, "#e67e22")  ' Darker orange
endfunction

function OnLeave(sender#)
  pie_fill#(sender#, "#f1c40f")  ' Restore yellow
endfunction
```

## Important Notes

1. **HitTest**: By default, HitTest is enabled for pies, allowing mouse events. Set `pie_hittest#(p#, 0)` to disable.

2. **Rotation vs. Angles**: Use `pie_rotation` to rotate the entire control. Use `pie_startangle` and `pie_endangle` to control which portion of the pie slice is visible.

3. **Garbage Collection**: Pies are automatically registered with the Plan9Basic GC system with the tag 'BASIC_PIE'.

4. **Performance**: For animations, use `pie_angles#` to set both angles at once, rather than separate calls to `pie_startangle#` and `pie_endangle#`.

5. **Pie vs. Arc**: TPie draws a filled wedge with lines to center. If you only need the curved outline without the center lines, use TArc from ArcLib.

6. **Pie vs. Circle**: If you need a full circle (360°), consider using `circle#` from CircleLib for better performance.

7. **Z-Order for Charts**: When creating pie charts, slices are drawn in creation order. Use `pie_bringtofront#` or `pie_sendtoback#` to adjust layering if needed.

## Version History

### v1.0.0
- Initial release
- 77 functions implemented
- Full event support
- StartAngle and EndAngle properties
- GC system integration

## See Also

- [ArcLib](ArcLib_Documentation.md) - For arc outlines without center lines
- [CircleLib](CircleLib_Documentation.md) - For complete circles
- [EllipseLib](EllipseLib_Documentation.md) - For ellipses
- [RectangleLib](RectangleLib_Documentation.md) - For rectangles
- [RoundRectLib](RoundRectLib_Documentation.md) - For rounded rectangles
