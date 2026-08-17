# ArcLib - Arc Visual Control Library

## Overview

**ArcLib** provides complete functionality for creating and managing arc visual controls in Plan9Basic programs. An arc is a visual shape that draws a portion of an ellipse defined by start and end angles.

**Version:** 1.0.0  
**Total Functions:** 77 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Arc Angle Concepts

Angles are specified in degrees (0-360), following the convention:

```
         270° (Top)
            |
   180° ----+---- 0° (Right)
   (Left)   |
          90° (Bottom)
```

The arc is drawn clockwise from `StartAngle` to `EndAngle`.

### Angle Examples

| StartAngle | EndAngle | Result |
|------------|----------|--------|
| 0 | 90 | Quarter circle (bottom-right quadrant) |
| 0 | 180 | Semicircle (bottom half) |
| 0 | 270 | Three-quarter circle |
| 0 | 360 | Full circle |
| 45 | 135 | 90° arc between positions 45° and 135° |
| 30 | 330 | "Pac-Man" style arc |

## Arc vs Pie

- **TArc**: Draws only the curved arc portion of an ellipse
- **TPie**: Draws a pie slice (wedge) with lines from arc endpoints to center

Use ArcLib for:
- Progress indicators (circular)
- Gauges and meters
- Decorative curved lines
- Partial circle outlines

Use PieLib for:
- Pie charts
- Pac-Man style graphics
- Filled wedge shapes

## Function Quick Reference

### Error Handling (4 functions)

| Function | Description |
|----------|-------------|
| `arc_error@` | Returns the last error code |
| `arc_errormsg$@` | Returns the last error message |
| `arc_strerror$@n` | Returns description for error code |
| `arc_clearerror@` | Clears the error state |

### Creation/Destruction (4 functions)

| Function | Description |
|----------|-------------|
| `arc#@#` | Create arc with parent |
| `arc#@#nn` | Create arc with parent and size (width, height) |
| `arc#@#nnnn` | Create arc with parent, position and size (x, y, w, h) |
| `arc_free@#` | Explicitly free an arc |

### Arc Angles (5 functions)

| Function | Description |
|----------|-------------|
| `arc_startangle@#` | Get start angle |
| `arc_startangle#@#n` | Set start angle |
| `arc_endangle@#` | Get end angle |
| `arc_endangle#@#n` | Set end angle |
| `arc_angles#@#nn` | Set both angles at once |

### Fill (3 functions)

| Function | Description |
|----------|-------------|
| `arc_fill$@#` | Get fill color |
| `arc_fill#@#$` | Set fill color |
| `arc_fillnone#@#` | Remove fill (transparent) |

### Stroke (10 functions)

| Function | Description |
|----------|-------------|
| `arc_stroke$@#` | Get stroke color |
| `arc_stroke#@#$` | Set stroke color |
| `arc_strokenone#@#` | Remove stroke |
| `arc_strokethickness@#` | Get stroke thickness |
| `arc_strokethickness#@#n` | Set stroke thickness |
| `arc_strokedash@#` | Get dash style |
| `arc_strokedash#@#n` | Set dash style |
| `arc_strokecap@#` | Get cap style |
| `arc_strokecap#@#n` | Set cap style |
| `arc_strokejoin@#` | Get join style |
| `arc_strokejoin#@#n` | Set join style |

### Position and Size (11 functions)

| Function | Description |
|----------|-------------|
| `arc_x@#` | Get X position |
| `arc_x#@#n` | Set X position |
| `arc_y@#` | Get Y position |
| `arc_y#@#n` | Set Y position |
| `arc_width@#` | Get width |
| `arc_width#@#n` | Set width |
| `arc_height@#` | Get height |
| `arc_height#@#n` | Set height |
| `arc_bounds#@#nnnn` | Set bounds (x, y, width, height) |
| `arc_size#@#nn` | Set size (width, height) |
| `arc_move#@#nn` | Set position (x, y) |

### Alignment (2 functions)

| Function | Description |
|----------|-------------|
| `arc_align@#` | Get alignment |
| `arc_align#@#n` | Set alignment |

### Margins (10 functions)

| Function | Description |
|----------|-------------|
| `arc_marginleft@#` | Get left margin |
| `arc_marginleft#@#n` | Set left margin |
| `arc_margintop@#` | Get top margin |
| `arc_margintop#@#n` | Set top margin |
| `arc_marginright@#` | Get right margin |
| `arc_marginright#@#n` | Set right margin |
| `arc_marginbottom@#` | Get bottom margin |
| `arc_marginbottom#@#n` | Set bottom margin |
| `arc_margins#@#nnnn` | Set all margins (left, top, right, bottom) |
| `arc_margin#@#n` | Set uniform margin |

### Visibility and Behavior (8 functions)

| Function | Description |
|----------|-------------|
| `arc_visible@#` | Get visibility state |
| `arc_visible#@#n` | Set visibility (0=hidden, 1=visible) |
| `arc_enabled@#` | Get enabled state |
| `arc_enabled#@#n` | Set enabled state |
| `arc_opacity@#` | Get opacity (0.0-1.0) |
| `arc_opacity#@#n` | Set opacity |
| `arc_hittest@#` | Get hit test state |
| `arc_hittest#@#n` | Set hit test state |

### Tag and Rotation (4 functions)

| Function | Description |
|----------|-------------|
| `arc_tag@#` | Get tag value |
| `arc_tag#@#n` | Set tag value |
| `arc_rotation@#` | Get control rotation |
| `arc_rotation#@#n` | Set control rotation |

**Note:** `arc_rotation` rotates the entire control, not the arc itself. Use `arc_startangle` and `arc_endangle` to control which portion of the arc is visible.

### Parent and Z-Order (4 functions)

| Function | Description |
|----------|-------------|
| `arc_parent#@#` | Get parent control |
| `arc_parent#@##` | Set parent control |
| `arc_bringtofront#@#` | Bring to front |
| `arc_sendtoback#@#` | Send to back |

### Invalidation (1 function)

| Function | Description |
|----------|-------------|
| `arc_invalidate#@#` | Trigger repaint |

### Event Callbacks (21 functions)

| Function | Description |
|----------|-------------|
| `arc_onclick#@#$` | Set onclick callback |
| `arc_onclick$@#` | Get onclick callback name |
| `arc_ondblclick#@#$` | Set ondblclick callback |
| `arc_ondblclick$@#` | Get ondblclick callback name |
| `arc_onmousedown#@#$` | Set onmousedown callback |
| `arc_onmousedown$@#` | Get onmousedown callback name |
| `arc_onmouseup#@#$` | Set onmouseup callback |
| `arc_onmouseup$@#` | Get onmouseup callback name |
| `arc_onmousemove#@#$` | Set onmousemove callback |
| `arc_onmousemove$@#` | Get onmousemove callback name |
| `arc_onmouseenter#@#$` | Set onmouseenter callback |
| `arc_onmouseenter$@#` | Get onmouseenter callback name |
| `arc_onmouseleave#@#$` | Set onmouseleave callback |
| `arc_onmouseleave$@#` | Get onmouseleave callback name |
| `arc_onmousewheel#@#$` | Set onmousewheel callback |
| `arc_onmousewheel$@#` | Get onmousewheel callback name |
| `arc_onresize#@#$` | Set onresize callback |
| `arc_onresize$@#` | Get onresize callback name |
| `arc_clearcallbacks#@#` | Clear all callbacks |

## Constants

### Error Codes

| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Invalid arc |
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
arc_fill#(a#, "red")
arc_fill#(a#, "blue")
arc_fill#(a#, "transparent")
```

Available colors: black, white, red, green, blue, yellow, cyan, magenta, gray, silver, maroon, olive, navy, purple, teal, orange, pink, brown, lime, aqua, fuchsia, transparent, null

### Hexadecimal Format

```basic
' RGB
arc_fill#(a#, "#FF0000")      ' Red

' ARGB (with alpha)
arc_fill#(a#, "#80FF0000")    ' Semi-transparent red
```

## Event Callback Signatures

### OnClick / OnDblClick
```basic
function OnArcClick(sender#)
  println "Arc clicked!"
endfunction
```

### OnMouseDown / OnMouseUp
```basic
function OnArcMouseDown(sender#, button, x, y, shift$)
  ' button: 0=left, 1=right, 2=middle
  ' shift$: combination of S=Shift, C=Ctrl, A=Alt, M=Command
  println "Mouse button: " + stri$(button)
endfunction
```

### OnMouseMove
```basic
function OnArcMouseMove(sender#, x, y, shift$)
  println "Mouse at: " + stri$(x) + ", " + stri$(y)
endfunction
```

### OnMouseEnter / OnMouseLeave
```basic
function OnArcMouseEnter(sender#)
  arc_fill#(sender#, "#FFA500")  ' Orange on hover
endfunction

function OnArcMouseLeave(sender#)
  arc_fill#(sender#, "#3498db")  ' Restore original color
endfunction
```

### OnMouseWheel
```basic
function OnArcMouseWheel(sender#, delta, shift$)
  println "Wheel rotation: " + stri$(delta)
endfunction
```

### OnResize
```basic
function OnArcResize(sender#)
  println "Arc resized"
endfunction
```

## Usage Examples

### Basic Example - Creating an Arc

```basic
let frm# = form#("Arc Demo", 800, 600)

' Create a quarter circle arc
let a# = arc#(frm#, 50, 50, 100, 100)
arc_angles#(a#, 0, 90)
arc_fill#(a#, "#3498db")
arc_stroke#(a#, "#2980b9")
arc_strokethickness#(a#, 2)

form_show(frm#)
```

### Example - Circular Progress Indicator

```basic
let frm# = form#("Progress", 300, 300)

' Background arc (full circle)
let bgArc# = arc#(frm#, 75, 75, 150, 150)
arc_angles#(bgArc#, 0, 360)
arc_fillnone#(bgArc#)
arc_stroke#(bgArc#, "#ecf0f1")
arc_strokethickness#(bgArc#, 10)

' Progress arc
let progressArc# = arc#(frm#, 75, 75, 150, 150)
arc_angles#(progressArc#, 270, 270)  ' Starts at top
arc_fillnone#(progressArc#)
arc_stroke#(progressArc#, "#3498db")
arc_strokethickness#(progressArc#, 10)
arc_strokecap#(progressArc#, 1)  ' Rounded caps

let lblPercent# = label#(frm#, "0%", 130, 140)

form_show(frm#)

' Function to update progress (0-100)
function UpdateProgress(percent)
  ' Convert percentage to angle (270° = top)
  let endAngle = 270 + (percent * 3.6)
  if endAngle > 360 then
    let endAngle = endAngle - 360
  endif
  arc_angles#(progressArc#, 270, endAngle)
  label_text#(lblPercent#, stri$(percent) + "%")
endfunction
```

### Example - Gauge with Colored Zones

```basic
let frm# = form#("Gauge", 400, 300)

' Green zone (0-60%)
let greenZone# = arc#(frm#, 100, 75, 200, 200)
arc_angles#(greenZone#, 180, 288)  ' 60% of 180°
arc_fillnone#(greenZone#)
arc_stroke#(greenZone#, "#2ecc71")
arc_strokethickness#(greenZone#, 20)

' Yellow zone (60-80%)
let yellowZone# = arc#(frm#, 100, 75, 200, 200)
arc_angles#(yellowZone#, 288, 324)  ' 20% of 180°
arc_fillnone#(yellowZone#)
arc_stroke#(yellowZone#, "#f1c40f")
arc_strokethickness#(yellowZone#, 20)

' Red zone (80-100%)
let redZone# = arc#(frm#, 100, 75, 200, 200)
arc_angles#(redZone#, 324, 360)  ' 20% of 180°
arc_fillnone#(redZone#)
arc_stroke#(redZone#, "#e74c3c")
arc_strokethickness#(redZone#, 20)

form_show(frm#)
```

### Example - Loading Spinner Animation

```basic
let frm# = form#("Loading", 200, 200)

' Create spinner arc
let spinner# = arc#(frm#, 50, 50, 100, 100)
arc_angles#(spinner#, 0, 90)
arc_fillnone#(spinner#)
arc_stroke#(spinner#, "#3498db")
arc_strokethickness#(spinner#, 5)
arc_strokecap#(spinner#, 1)  ' Rounded caps

let angle = 0

form_show(frm#)

' Timer callback to animate
function AnimateSpinner()
  let angle = angle + 10
  if angle >= 360 then
    let angle = 0
  endif
  arc_angles#(spinner#, angle, angle + 90)
endfunction
```

### Example - Interactive Arc with Mouse Events

```basic
let frm# = form#("Interactive Arc", 400, 400)

let arc1# = arc#(frm#, 150, 150, 100, 100)
arc_angles#(arc1#, 0, 270)
arc_fill#(arc1#, "#3498db")
arc_stroke#(arc1#, "#2980b9")
arc_strokethickness#(arc1#, 3)

' Set up event callbacks
arc_onclick#(arc1#, "OnClick")
arc_onmouseenter#(arc1#, "OnEnter")
arc_onmouseleave#(arc1#, "OnLeave")

form_show(frm#)

function OnClick(sender#)
  println "Arc clicked!"
endfunction

function OnEnter(sender#)
  arc_fill#(sender#, "#e74c3c")  ' Change to red
endfunction

function OnLeave(sender#)
  arc_fill#(sender#, "#3498db")  ' Restore blue
endfunction
```

## Important Notes

1. **HitTest**: By default, HitTest is enabled for arcs, allowing mouse events. Set `arc_hittest#(a#, 0)` to disable.

2. **Rotation vs. Angles**: Use `arc_rotation` to rotate the entire control. Use `arc_startangle` and `arc_endangle` to control which portion of the arc is visible.

3. **Garbage Collection**: Arcs are automatically registered with the Plan9Basic GC system with the tag 'BASIC_ARC'.

4. **Performance**: For animations, use `arc_angles#` to set both angles at once, rather than separate calls to `arc_startangle#` and `arc_endangle#`.

5. **Arc vs. Circle**: If you need a full circle (360°), consider using `circle#` from CircleLib for better performance.

6. **Arc vs. Pie**: TArc draws only the curved portion. If you need lines connecting to the center (like a pie slice), use TPie from PieLib.

## Version History

### v1.0.0
- Initial release
- 77 functions implemented
- Full event support
- StartAngle and EndAngle properties
- GC system integration

## See Also

- [PieLib](PieLib_Documentation.md) - For pie/wedge shapes with center lines
- [CircleLib](CircleLib_Documentation.md) - For complete circles
- [EllipseLib](EllipseLib_Documentation.md) - For ellipses
- [RectangleLib](RectangleLib_Documentation.md) - For rectangles
- [RoundRectLib](RoundRectLib_Documentation.md) - For rounded rectangles
