# PathLib - Vector Path Shape Library for Plan9Basic

## Overview

PathLib provides functionality for creating and managing vector path shapes in Plan9Basic programs. Paths are complex shapes defined by a series of drawing commands (move, line, curve, arc) using SVG-like path data syntax. Ideal for custom shapes, icons, logos, and complex graphics.

**Function Count:** 107 functions

> **Note:** Paths are `TShape` descendants and do not support anchors, padding, drag events, cursor, or scale properties. Note that `path_scale#`, `path_translate#`, and `path_rotate#` transform the **path geometry data**, not the visual control — use `path_rotation#` to rotate the rendered shape.

## Quick Start

```basic
' Create a simple triangle path
let frm# = form#("Path Demo", 400, 300)
let pth# = path#(frm#, 50, 50, 200, 200)
path_data#(pth#, "M 0,100 L 100,0 L 200,100 Z")
path_fill#(pth#, "#3498db")
path_stroke#(pth#, "#2c3e50")
path_strokethickness#(pth#, 2)
form_show(frm#)
```

## Function Reference

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `path#(parent#)` | Create path with parent only |
| `path#(parent#, width, height)` | Create with size |
| `path#(parent#, x, y, width, height)` | Create with position and size |
| `path_free(path#)` | Free path (returns 1 on success) |

### Path Data (String-Based)

| Function | Description |
|----------|-------------|
| `path_data$(path#)` | Get path data as SVG string |
| `path_data#(path#, data$)` | Set path data from SVG string |

### Path Drawing Commands (Programmatic)

| Function | Description |
|----------|-------------|
| `path_moveto#(path#, x, y)` | Move to point (M command) |
| `path_lineto#(path#, x, y)` | Draw line to point (L command) |
| `path_hlineto#(path#, x)` | Draw horizontal line (H command) |
| `path_vlineto#(path#, y)` | Draw vertical line (V command) |
| `path_curveto#(path#, x1, y1, x2, y2, x, y)` | Cubic bezier curve (C command) |
| `path_smoothcurveto#(path#, x2, y2, x, y)` | Smooth cubic bezier (S command) |
| `path_quadcurveto#(path#, x1, y1, x, y)` | Quadratic bezier curve (Q command) |
| `path_closepath#(path#)` | Close path (Z command) |
| `path_clear#(path#)` | Clear all path data |

### Predefined Shapes

| Function | Description |
|----------|-------------|
| `path_addrectangle#(path#, x, y, w, h, rx, ry)` | Add rounded rectangle (rx, ry = corner radii) |
| `path_addellipse#(path#, x, y, w, h)` | Add ellipse |
| `path_addarc#(path#, x, y, w, h, start, sweep)` | Add arc (start/sweep in degrees) |

### Path Transformations

These functions transform the **path geometry data** (not the visual control position):

| Function | Description |
|----------|-------------|
| `path_scale#(path#, scaleX, scaleY)` | Scale path data |
| `path_translate#(path#, dx, dy)` | Translate path data |
| `path_rotate#(path#, angle)` | Rotate path data (degrees) |

### Path Information

| Function | Description |
|----------|-------------|
| `path_pointcount(path#)` | Get number of points in path |
| `path_lastx(path#)` | Get X of last point |
| `path_lasty(path#)` | Get Y of last point |
| `path_boundsx(path#)` | Get X of path bounds |
| `path_boundsy(path#)` | Get Y of path bounds |
| `path_boundswidth(path#)` | Get width of path bounds |
| `path_boundsheight(path#)` | Get height of path bounds |

### Fill Properties

| Function | Description |
|----------|-------------|
| `path_fill$(path#)` | Get fill color as string |
| `path_fill#(path#, color$)` | Set fill color (hex: "#RRGGBB" or "#AARRGGBB") |
| `path_fillnone#(path#)` | Remove fill (transparent) |
| `path_wrapmode(path#)` / `path_wrapmode#(path#, value)` | Get/set fill wrap mode (0=Tile, 1=TileOriginal, 2=TileStretch) |

### Stroke Properties

| Function | Description |
|----------|-------------|
| `path_stroke$(path#)` | Get stroke color |
| `path_stroke#(path#, color$)` | Set stroke color |
| `path_strokenone#(path#)` | Remove stroke |
| `path_strokethickness(path#)` / `path_strokethickness#(path#, value)` | Get/set stroke thickness |
| `path_strokedash(path#)` / `path_strokedash#(path#, value)` | Get/set dash style (0=Solid, 1=Dash, 2=Dot, 3=DashDot, 4=DashDotDot) |
| `path_strokecap(path#)` / `path_strokecap#(path#, value)` | Get/set cap style (0=Flat, 1=Round) |
| `path_strokejoin(path#)` / `path_strokejoin#(path#, value)` | Get/set join style (0=Miter, 1=Round, 2=Bevel) |

### Position and Size

| Function | Description |
|----------|-------------|
| `path_x(path#)` / `path_x#(path#, value)` | Get/set X position |
| `path_y(path#)` / `path_y#(path#, value)` | Get/set Y position |
| `path_width(path#)` / `path_width#(path#, value)` | Get/set width |
| `path_height(path#)` / `path_height#(path#, value)` | Get/set height |
| `path_bounds#(path#, x, y, w, h)` | Set position and size at once |
| `path_size#(path#, width, height)` | Set width and height |
| `path_move#(path#, x, y)` | Set X and Y position |

### Visual Properties

| Function | Description |
|----------|-------------|
| `path_visible(path#)` / `path_visible#(path#, value)` | Get/set visibility (0/1) |
| `path_enabled(path#)` / `path_enabled#(path#, value)` | Get/set enabled state |
| `path_opacity(path#)` / `path_opacity#(path#, value)` | Get/set opacity (0.0-1.0) |
| `path_hittest(path#)` / `path_hittest#(path#, value)` | Get/set hit testing (0/1) |
| `path_rotation(path#)` / `path_rotation#(path#, value)` | Get/set rotation angle in degrees (rotates the visual control) |

### Alignment

| Function | Description |
|----------|-------------|
| `path_align(path#)` / `path_align#(path#, value)` | Get/set alignment (0=None, 1=Top, 2=Left, 3=Right, 4=Bottom, 5=MostTop, 6=MostBottom, 7=MostLeft, 8=MostRight, 9=Client, 10=Contents, 11=Center, 12=VertCenter, 13=HorzCenter, 14=Fit, 15=FitLeft, 16=FitRight) |

### Margins

| Function | Description |
|----------|-------------|
| `path_margins#(path#, left, top, right, bottom)` | Set all margins |
| `path_marginleft(path#)` / `path_marginleft#(path#, value)` | Get/set left margin |
| `path_margintop(path#)` / `path_margintop#(path#, value)` | Get/set top margin |
| `path_marginright(path#)` / `path_marginright#(path#, value)` | Get/set right margin |
| `path_marginbottom(path#)` / `path_marginbottom#(path#, value)` | Get/set bottom margin |
| `path_margin#(path#, value)` | Set uniform margin (all sides equal) |

### Tag Property

| Function | Description |
|----------|-------------|
| `path_tag(path#)` / `path_tag#(path#, value)` | Get/set numeric tag |

### Event Handlers

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `path_onclick#(path#, callback$)` | `path_onclick$(path#)` | `function(sender#)` |
| OnDblClick | `path_ondblclick#(path#, callback$)` | `path_ondblclick$(path#)` | `function(sender#)` |
| OnMouseDown | `path_onmousedown#(path#, callback$)` | `path_onmousedown$(path#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `path_onmouseup#(path#, callback$)` | `path_onmouseup$(path#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `path_onmousemove#(path#, callback$)` | `path_onmousemove$(path#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `path_onmouseenter#(path#, callback$)` | `path_onmouseenter$(path#)` | `function(sender#)` |
| OnMouseLeave | `path_onmouseleave#(path#, callback$)` | `path_onmouseleave$(path#)` | `function(sender#)` |
| OnMouseWheel | `path_onmousewheel#(path#, callback$)` | `path_onmousewheel$(path#)` | `function(sender#, delta)` |
| OnResize | `path_onresize#(path#, callback$)` | `path_onresize$(path#)` | `function(sender#)` |

Use `path_clearcallbacks#(path#)` to disconnect all event handlers.

### Hierarchy

| Function | Description |
|----------|-------------|
| `path_parent#(path#)` | Get parent control |
| `path_parent#(path#, parent#)` | Set parent control |
| `path_bringtofront#(path#)` | Bring path to front |
| `path_sendtoback#(path#)` | Send path to back |
| `path_invalidate#(path#)` | Force redraw of the path |
| `path_clearcallbacks#(path#)` | Disconnects all event callbacks |

### Error Handling

| Function | Description |
|----------|-------------|
| `path_error()` | Get last error code |
| `path_errormsg$()` | Get last error message |
| `path_strerror$(code)` | Get error description for code |
| `path_clearerror()` | Clear error state |

## SVG Path Data Syntax

The `path_data#()` function accepts SVG path data strings:

| Command | Parameters | Description |
|---------|------------|-------------|
| M x,y | Move to | Start new subpath at (x,y) |
| L x,y | Line to | Draw line to (x,y) |
| H x | Horizontal line | Draw horizontal line to x |
| V y | Vertical line | Draw vertical line to y |
| C x1,y1 x2,y2 x,y | Cubic bezier | Curve with control points |
| S x2,y2 x,y | Smooth cubic | Smooth continuation of previous curve |
| Q x1,y1 x,y | Quadratic bezier | Single control point curve |
| A rx,ry rot large,sweep x,y | Arc | Elliptical arc |
| Z | Close path | Close current subpath |

## Examples

### Example 1: Triangle

```basic
' Create a triangle using path data
let frm# = form#("Triangle", 300, 300)
let pth# = path#(frm#, 50, 50, 200, 200)
path_data#(pth#, "M 100,0 L 200,173 L 0,173 Z")
path_fill#(pth#, "#e74c3c")
path_stroke#(pth#, "#c0392b")
path_strokethickness#(pth#, 2)
form_show(frm#)
```

### Example 2: Star Shape

```basic
' Create a 5-pointed star
let frm# = form#("Star", 300, 300)
let pth# = path#(frm#, 50, 50, 200, 200)
path_data#(pth#, "M 100,0 L 130,70 L 200,70 L 145,115 L 165,190 L 100,145 L 35,190 L 55,115 L 0,70 L 70,70 Z")
path_fill#(pth#, "#f1c40f")
path_stroke#(pth#, "#f39c12")
path_strokethickness#(pth#, 2)
form_show(frm#)
```

### Example 3: Programmatic Path Building

```basic
' Build a path programmatically
let frm# = form#("Custom Path", 400, 300)
let pth# = path#(frm#, 50, 50, 300, 200)

' Build a house shape
path_moveto#(pth#, 150, 0)
path_lineto#(pth#, 300, 100)
path_lineto#(pth#, 300, 200)
path_lineto#(pth#, 0, 200)
path_lineto#(pth#, 0, 100)
path_closepath#(pth#)

path_fill#(pth#, "#3498db")
path_stroke#(pth#, "#2980b9")
path_strokethickness#(pth#, 3)
form_show(frm#)
```

### Example 4: Bezier Curves

```basic
' Create smooth curves with bezier commands
let frm# = form#("Bezier Curve", 400, 300)
let pth# = path#(frm#, 50, 50, 300, 200)
path_data#(pth#, "M 0,100 C 50,0 100,0 150,100 S 250,200 300,100")
path_fillnone#(pth#)
path_stroke#(pth#, "#9b59b6")
path_strokethickness#(pth#, 4)
path_strokecap#(pth#, 1)
form_show(frm#)
```

### Example 5: Combined Shapes

```basic
' Combine multiple shapes in one path
let frm# = form#("Combined", 400, 300)
let pth# = path#(frm#, 20, 20, 360, 260)

' Add rectangle with rounded corners
path_addrectangle#(pth#, 0, 0, 150, 100, 10, 10)

' Add ellipse
path_addellipse#(pth#, 200, 0, 100, 80)

' Add custom triangle
path_moveto#(pth#, 50, 150)
path_lineto#(pth#, 150, 150)
path_lineto#(pth#, 100, 230)
path_closepath#(pth#)

path_fill#(pth#, "#2ecc71")
path_stroke#(pth#, "#27ae60")
path_strokethickness#(pth#, 2)
form_show(frm#)
```

## Notes

- Path coordinates are relative to the path's bounding box
- Use `path_clear#()` to reset path data before building a new shape
- Programmatic commands append to existing path data
- Set `hittest` to 1 for clickable paths
- Paths with complex shapes may have performance implications
- Use `path_fillnone#()` for stroke-only outlines
- Round stroke joins look better on paths with sharp angles
- `path_rotate#()` transforms path geometry; `path_rotation#()` rotates the rendered control

---

*PathLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
