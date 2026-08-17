# PathAnimationLib

Animates a control along a path defined using SVG-like path syntax. Perfect for creating complex motion paths, following curves, and orbital animations.

## Functions

| Function | Description |
|----------|-------------|
| `pathani#(parent#)` | Creates a path animation attached to parent control |
| `pathani#(parent#, name$)` | Creates a named path animation |
| `pathani_free(ani#)` | Frees the animation object |
| `pathani_start(ani#)` | Starts the animation |
| `pathani_stop(ani#)` | Stops the animation and resets to start |
| `pathani_stopatcurrent(ani#)` | Stops at current position on path |
| `pathani_path#(ani#, pathdata$)` | Sets the SVG path data string |
| `pathani_path$(ani#)` | Gets the path data string |
| `pathani_clearpath#(ani#)` | Clears the path data |
| `pathani_rotate#(ani#, flag)` | If 1, control rotates to follow path tangent |
| `pathani_rotate(ani#)` | Gets rotate flag |
| `pathani_duration#(ani#, seconds)` | Sets duration in seconds |
| `pathani_duration(ani#)` | Gets duration |
| `pathani_delay#(ani#, seconds)` | Sets delay before start |
| `pathani_delay(ani#)` | Gets delay |
| `pathani_animationtype#(ani#, type$)` | Sets easing type: "In", "Out", "InOut" |
| `pathani_animationtype$(ani#)` | Gets animation type |
| `pathani_interpolation#(ani#, type$)` | Sets interpolation curve |
| `pathani_interpolation$(ani#)` | Gets interpolation type |
| `pathani_autoreverse#(ani#, flag)` | If 1, reverses after completing |
| `pathani_autoreverse(ani#)` | Gets autoreverse flag |
| `pathani_inverse#(ani#, flag)` | If 1, plays in reverse |
| `pathani_inverse(ani#)` | Gets inverse flag |
| `pathani_loop#(ani#, flag)` | If 1, loops indefinitely |
| `pathani_loop(ani#)` | Gets loop flag |
| `pathani_enabled#(ani#, flag)` | Enables/disables animation |
| `pathani_enabled(ani#)` | Gets enabled state |
| `pathani_running(ani#)` | Returns 1 if animation is running |
| `pathani_normalizedtime(ani#)` | Returns progress 0.0-1.0 |
| `pathani_name$(ani#)` | Gets the animation name |
| `pathani_trigger#(ani#, expr$)` | Sets trigger expression |
| `pathani_trigger$(ani#)` | Gets trigger expression |
| `pathani_triggerinverse#(ani#, expr$)` | Sets inverse trigger |
| `pathani_triggerinverse$(ani#)` | Gets inverse trigger |
| `pathani_onfinish#(ani#, callback$)` | Sets finish callback function |
| `pathani_onfinish$(ani#)` | Gets finish callback name |
| `pathani_onprocess#(ani#, callback$)` | Sets per-frame callback |
| `pathani_onprocess$(ani#)` | Gets process callback name |
| `pathani_clearcallbacks#(ani#)` | Removes all callbacks |
| `pathani_error()` | Returns last error code |
| `pathani_errormsg$()` | Returns last error message |
| `pathani_strerror$(code)` | Converts error code to message |
| `pathani_clearerror()` | Clears the error state |

## Path Commands (SVG Syntax)

| Command | Parameters | Description |
|---------|------------|-------------|
| `M` | x,y | Move to absolute position |
| `m` | dx,dy | Move to relative position |
| `L` | x,y | Line to absolute position |
| `l` | dx,dy | Line to relative position |
| `H` | x | Horizontal line to absolute X |
| `h` | dx | Horizontal line relative |
| `V` | y | Vertical line to absolute Y |
| `v` | dy | Vertical line relative |
| `C` | x1,y1 x2,y2 x,y | Cubic Bézier curve (absolute) |
| `c` | dx1,dy1 dx2,dy2 dx,dy | Cubic Bézier curve (relative) |
| `S` | x2,y2 x,y | Smooth cubic Bézier (absolute) |
| `s` | dx2,dy2 dx,dy | Smooth cubic Bézier (relative) |
| `Q` | x1,y1 x,y | Quadratic Bézier curve (absolute) |
| `q` | dx1,dy1 dx,dy | Quadratic Bézier curve (relative) |
| `T` | x,y | Smooth quadratic Bézier (absolute) |
| `t` | dx,dy | Smooth quadratic Bézier (relative) |
| `A` | rx,ry rot large,sweep x,y | Arc (absolute) |
| `a` | rx,ry rot large,sweep dx,dy | Arc (relative) |
| `Z` or `z` | - | Close path (return to start) |

## Animation Types

| Type | Description |
|------|-------------|
| `"In"` | Acceleration at start |
| `"Out"` | Deceleration at end |
| `"InOut"` | Accelerate then decelerate |

## Interpolation Types

| Type | Description |
|------|-------------|
| `"Linear"` | Constant speed along path |
| `"Quadratic"` | Smooth acceleration |
| `"Cubic"` | More pronounced curve |
| `"Sinusoidal"` | Sine-based easing |
| `"Elastic"` | Bouncy effect |
| `"Bounce"` | Bouncing effect |

## Error Codes

| Code | Meaning |
|------|---------|
| 0 | No error |
| 1 | Animation is nil |
| 2 | Invalid path data |
| 3 | Invalid value |
| 4 | Animation is running |

## Example: Simple Line Path

```basic
' Move along a straight line
let frm# = form#("Line Path Demo", 400, 300)
let ball# = circle#(frm#)
circle_bounds#(ball#, 0, 125, 50, 50)
circle_fill#(ball#, "Red")

' Path: Move to start, line to end
let pathAni# = pathani#(ball#)
pathani_path#(pathAni#, "M 0,125 L 350,125")
pathani_duration#(pathAni#, 2.0)
pathani_interpolation#(pathAni#, "Sinusoidal")
pathani_animationtype#(pathAni#, "InOut")
pathani_autoreverse#(pathAni#, 1)
pathani_loop#(pathAni#, 1)
pathani_start(pathAni#)

form_show(frm#)
```

## Example: Square Path

```basic
' Move in a square pattern
let frm# = form#("Square Path Demo", 400, 400)
let ball# = circle#(frm#)
circle_bounds#(ball#, 50, 50, 40, 40)
circle_fill#(ball#, "Blue")

' Path: Square shape
let pathAni# = pathani#(ball#)
pathani_path#(pathAni#, "M 50,50 L 310,50 L 310,310 L 50,310 Z")
pathani_duration#(pathAni#, 4.0)
pathani_interpolation#(pathAni#, "Linear")
pathani_loop#(pathAni#, 1)
pathani_start(pathAni#)

form_show(frm#)
```

## Example: Circular Orbit

```basic
' Object orbiting in a circle using arcs
let frm# = form#("Orbit Demo", 400, 400)

' Center point (visual reference)
let center# = circle#(frm#)
circle_bounds#(center#, 190, 190, 20, 20)
circle_fill#(center#, "Gray")

' Orbiting object
let planet# = circle#(frm#)
circle_bounds#(planet#, 50, 175, 50, 50)
circle_fill#(planet#, "Orange")

' Circular path using two arcs
let pathAni# = pathani#(planet#)
pathani_path#(pathAni#, "M 50,175 A 150,150 0 1,1 350,175 A 150,150 0 1,1 50,175")
pathani_duration#(pathAni#, 3.0)
pathani_interpolation#(pathAni#, "Linear")
pathani_loop#(pathAni#, 1)
pathani_start(pathAni#)

form_show(frm#)
```

## Example: Curved Path with Rotation

```basic
' Object follows curved path and rotates to follow direction
let frm# = form#("Curve Path Demo", 500, 400)

' Arrow-like shape (triangle)
let arrow# = path#(frm#)
path_data#(arrow#, "M 0,-15 L 30,0 L 0,15 Z")
path_fill#(arrow#, "Green")
path_move#(arrow#, 50, 200)

' S-curve path with rotation enabled
let pathAni# = pathani#(arrow#)
pathani_path#(pathAni#, "M 50,200 C 150,50 200,350 300,200 S 400,50 450,200")
pathani_duration#(pathAni#, 4.0)
pathani_rotate#(pathAni#, 1)  ' Enable rotation to follow path
pathani_interpolation#(pathAni#, "Linear")
pathani_loop#(pathAni#, 1)
pathani_start(pathAni#)

form_show(frm#)
```

## Example: Figure-8 Path

```basic
' Object moves in a figure-8 pattern
let frm# = form#("Figure-8 Demo", 500, 400)
let ball# = circle#(frm#)
circle_bounds#(ball#, 50, 175, 50, 50)
circle_fill#(ball#, "Purple")

' Figure-8 using cubic Bezier curves
let pathAni# = pathani#(ball#)
pathani_path#(pathAni#, "M 50,175 C 50,50 200,50 250,175 C 300,300 450,300 450,175 C 450,50 300,50 250,175 C 200,300 50,300 50,175")
pathani_duration#(pathAni#, 5.0)
pathani_interpolation#(pathAni#, "Linear")
pathani_loop#(pathAni#, 1)
pathani_start(pathAni#)

form_show(frm#)
```

## Example: Bouncing Ball Path

```basic
' Ball bouncing across screen
let frm# = form#("Bounce Path Demo", 500, 400)
let ball# = circle#(frm#)
circle_bounds#(ball#, 25, 300, 50, 50)
circle_fill#(ball#, "Red")

' Bouncing path using quadratic curves
let pathAni# = pathani#(ball#)
pathani_path#(pathAni#, "M 25,300 Q 100,50 175,300 Q 250,100 325,300 Q 400,150 425,300")
pathani_duration#(pathAni#, 3.0)
pathani_interpolation#(pathAni#, "Linear")
pathani_autoreverse#(pathAni#, 1)
pathani_loop#(pathAni#, 1)
pathani_start(pathAni#)

form_show(frm#)
```

## Example: Image Following Path

```basic
' Image follows a wave path
let frm# = form#("Image Path Demo", 600, 300)
let img# = image#(frm#, 0, 100, 80, 80)
image_load#(img#, "https://picsum.photos/80")

' Wave pattern
let pathAni# = pathani#(img#)
pathani_path#(pathAni#, "M 0,100 Q 75,50 150,100 T 300,100 T 450,100 T 520,100")
pathani_duration#(pathAni#, 4.0)
pathani_interpolation#(pathAni#, "Linear")
pathani_autoreverse#(pathAni#, 1)
pathani_loop#(pathAni#, 1)
pathani_start(pathAni#)

form_show(frm#)
```

## Path Tips

1. **Start with M**: Always begin your path with a Move command (M x,y)
2. **Uppercase = Absolute**: Uppercase commands use absolute coordinates
3. **Lowercase = Relative**: Lowercase commands use relative offsets from current position
4. **Close with Z**: Use Z to close the path back to the starting point
5. **Rotate**: Enable `pathani_rotate#` for objects that should face their direction of travel
6. **Smooth curves**: Use S/s after C/c for smooth continuation, T/t after Q/q
