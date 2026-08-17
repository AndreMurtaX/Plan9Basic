# ImageLib - Image Control Library for Plan9Basic

## Overview

Display bitmap images in your Plan9Basic applications with full control over scaling, positioning, and interactivity. Load images from local files or directly from the web via HTTP/HTTPS.

**Version:** 1.0.0  
**Function Count:** 78 functions

## Cross-Platform Support

- Windows (Win32/Win64)
- macOS (Intel/ARM)
- Linux
- Android
- iOS

## Supported Image Formats

- PNG (recommended for transparency)
- JPEG / JPG
- BMP
- GIF

## Quick Start

```basic
let frm# = form#("Image Viewer", 800, 600)
form_position#(frm#, 4)

let img# = image#(frm#, 50, 50, 400, 300)
image_load#(img#, "https://picsum.photos/400/300")
image_wrapmode#(img#, 1)

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while
```

## Numeric Values Reference

### Wrap Modes (Scaling)

| Value | Mode | Description |
|-------|------|-------------|
| 0 | Original | Display at original size, top-left aligned |
| 1 | Fit | Scale to fit while keeping aspect ratio (default) |
| 2 | Stretch | Stretch to fill control (may distort) |
| 3 | Tile | Repeat image to fill control |
| 4 | Center | Center without resizing |
| 5 | Place | Fit if larger, center if smaller |

### Alignment Values

| Value | Description |
|-------|-------------|
| 0 | None |
| 1 | Top |
| 2 | Left |
| 3 | Right |
| 4 | Bottom |
| 9 | Client (fill parent) |
| 11 | Center |

---

## Free Image Sources for Testing

**Lorem Picsum** (https://picsum.photos) provides free stock photos:

| URL Pattern | Description |
|-------------|-------------|
| `https://picsum.photos/400/300` | Random image 400x300 |
| `https://picsum.photos/id/10/400/300` | Specific image by ID |
| `https://picsum.photos/seed/hello/400/300` | Consistent image from seed |
| `https://picsum.photos/400/300?grayscale` | Grayscale image |
| `https://picsum.photos/400/300?blur=5` | Blurred image (1-10) |

---

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `image_error()` | Returns last error code (0 = no error) |
| `image_errormsg$()` | Returns last error message |
| `image_strerror$(code)` | Returns description for error code |
| `image_clearerror()` | Clears error state |

### Creation and Destruction

| Function | Description |
|----------|-------------|
| `image#(parent#)` | Create image control |
| `image#(parent#, w, h)` | Create with size |
| `image#(parent#, x, y, w, h)` | Create with position and size |
| `image_free(img#)` | Destroy image control |

### Loading and Saving

| Function | Description |
|----------|-------------|
| `image_load(img#, path$)` | Load from file or URL, returns 1 on success |
| `image_load#(img#, path$)` | Load from file or URL, returns image pointer |
| `image_save(img#, filepath$)` | Save to file, returns 1 on success |
| `image_save#(img#, filepath$)` | Save to file, returns image pointer |

### Bitmap Properties

| Function | Description |
|----------|-------------|
| `image_bitmapwidth(img#)` | Get loaded image width in pixels |
| `image_bitmapheight(img#)` | Get loaded image height in pixels |
| `image_isempty(img#)` | Returns 1 if no image loaded |
| `image_clear#(img#)` | Clear image (transparent) |
| `image_clear#(img#, color$)` | Clear image with color |

### Wrap Mode

| Function | Description |
|----------|-------------|
| `image_wrapmode(img#)` | Get current wrap mode |
| `image_wrapmode#(img#, mode)` | Set wrap mode (0-5) |

### Position and Size

| Function | Description |
|----------|-------------|
| `image_x(img#)` / `image_x#(img#, x)` | Get/set X position |
| `image_y(img#)` / `image_y#(img#, y)` | Get/set Y position |
| `image_width(img#)` / `image_width#(img#, w)` | Get/set control width |
| `image_height(img#)` / `image_height#(img#, h)` | Get/set control height |
| `image_bounds#(img#, x, y, w, h)` | Set position and size |
| `image_size#(img#, w, h)` | Set size only |
| `image_move#(img#, x, y)` | Set position only |

### Alignment and Margins

| Function | Description |
|----------|-------------|
| `image_align(img#)` | Get alignment |
| `image_align#(img#, mode)` | Set alignment |
| `image_marginleft(img#)` | Get left margin |
| `image_marginleft#(img#, v)` | Set left margin |
| `image_margintop(img#)` | Get top margin |
| `image_margintop#(img#, v)` | Set top margin |
| `image_marginright(img#)` | Get right margin |
| `image_marginright#(img#, v)` | Set right margin |
| `image_marginbottom(img#)` | Get bottom margin |
| `image_marginbottom#(img#, v)` | Set bottom margin |
| `image_margins#(img#, l, t, r, b)` | Set all margins |
| `image_margin#(img#, v)` | Set uniform margin |

### Visibility and Behavior

| Function | Description |
|----------|-------------|
| `image_visible(img#)` | Get visibility (0/1) |
| `image_visible#(img#, v)` | Set visibility (0/1) |
| `image_enabled(img#)` | Get enabled state (0/1) |
| `image_enabled#(img#, v)` | Set enabled state (0/1) |
| `image_opacity(img#)` | Get opacity (0.0-1.0) |
| `image_opacity#(img#, v)` | Set opacity (0.0-1.0) |
| `image_hittest(img#)` | Get hit test enabled (0/1) |
| `image_hittest#(img#, v)` | Set hit test enabled (0/1) |

### Tag and Rotation

| Function | Description |
|----------|-------------|
| `image_tag(img#)` / `image_tag#(img#, v)` | Get/set user tag value |
| `image_rotation(img#)` / `image_rotation#(img#, angle)` | Get/set rotation (degrees) |

### Parent and Z-Order

| Function | Description |
|----------|-------------|
| `image_parent#(img#)` | Get parent control |
| `image_parent#(img#, parent#)` | Set parent control |
| `image_bringtofront#(img#)` | Bring to front |
| `image_sendtoback#(img#)` | Send to back |
| `image_invalidate#(img#)` | Force redraw |
| `image_clearcallbacks#(img#)` | Disconnects all event callbacks |

---

## Event Callbacks

| Event | Setter | Getter | Signature |
|-------|--------|--------|-----------|
| OnClick | `image_onclick#(img#, func$)` | `image_onclick$(img#)` | `function(sender#)` |
| OnDblClick | `image_ondblclick#(img#, func$)` | `image_ondblclick$(img#)` | `function(sender#)` |
| OnMouseDown | `image_onmousedown#(img#, func$)` | `image_onmousedown$(img#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseUp | `image_onmouseup#(img#, func$)` | `image_onmouseup$(img#)` | `function(sender#, button, x, y, shift$)` |
| OnMouseMove | `image_onmousemove#(img#, func$)` | `image_onmousemove$(img#)` | `function(sender#, x, y, shift$)` |
| OnMouseEnter | `image_onmouseenter#(img#, func$)` | `image_onmouseenter$(img#)` | `function(sender#)` |
| OnMouseLeave | `image_onmouseleave#(img#, func$)` | `image_onmouseleave$(img#)` | `function(sender#)` |
| OnMouseWheel | `image_onmousewheel#(img#, func$)` | `image_onmousewheel$(img#)` | `function(sender#, delta, shift$)` |
| OnResize | `image_onresize#(img#, func$)` | `image_onresize$(img#)` | `function(sender#)` |

Use `image_clearcallbacks#(img#)` to disconnect all events.

---

## Complete Examples

### Web Image Gallery

```basic
let frm# = form#("Gallery", 700, 450)
form_position#(frm#, 4)

' Thumbnails
let img1# = image#(frm#, 20, 20, 150, 100)
let img2# = image#(frm#, 190, 20, 150, 100)
let img3# = image#(frm#, 360, 20, 150, 100)

image_wrapmode#(img1#, 1)
image_wrapmode#(img2#, 1)
image_wrapmode#(img3#, 1)

image_load#(img1#, "https://picsum.photos/seed/nature/150/100")
image_load#(img2#, "https://picsum.photos/seed/city/150/100")
image_load#(img3#, "https://picsum.photos/seed/ocean/150/100")

' Main display
let imgMain# = image#(frm#, 20, 140, 660, 290)
image_wrapmode#(imgMain#, 1)

' Set tags and click handlers
image_tag#(img1#, 1)
image_tag#(img2#, 2)
image_tag#(img3#, 3)

image_onclick#(img1#, "OnThumbClick")
image_onclick#(img2#, "OnThumbClick")
image_onclick#(img3#, "OnThumbClick")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnThumbClick(sender#) local tag, url$
  tag = image_tag(sender#)
  
  if tag = 1 then
    url$ = "https://picsum.photos/seed/nature/660/290"
  else if tag = 2 then
    url$ = "https://picsum.photos/seed/city/660/290"
  else if tag = 3 then
    url$ = "https://picsum.photos/seed/ocean/660/290"
  endif
  
  image_load#(imgMain#, url$)
endfunction
```

### Wrap Mode Selector

```basic
let frm# = form#("Wrap Modes", 600, 500)
form_position#(frm#, 4)

let img# = image#(frm#, 10, 50, 580, 400)
image_load#(img#, "https://picsum.photos/seed/demo/400/300")
image_wrapmode#(img#, 1)

let lblMode# = label#(frm#, "Mode: Fit", 10, 460)

let btnOriginal# = button#(frm#, "Original", 10, 10, 80, 30)
let btnFit# = button#(frm#, "Fit", 100, 10, 80, 30)
let btnStretch# = button#(frm#, "Stretch", 190, 10, 80, 30)
let btnTile# = button#(frm#, "Tile", 280, 10, 80, 30)
let btnCenter# = button#(frm#, "Center", 370, 10, 80, 30)

button_onclick#(btnOriginal#, "SetOriginal")
button_onclick#(btnFit#, "SetFit")
button_onclick#(btnStretch#, "SetStretch")
button_onclick#(btnTile#, "SetTile")
button_onclick#(btnCenter#, "SetCenter")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function SetOriginal(sender#)
  image_wrapmode#(img#, 0)
  label_text#(lblMode#, "Mode: Original")
endfunction

function SetFit(sender#)
  image_wrapmode#(img#, 1)
  label_text#(lblMode#, "Mode: Fit")
endfunction

function SetStretch(sender#)
  image_wrapmode#(img#, 2)
  label_text#(lblMode#, "Mode: Stretch")
endfunction

function SetTile(sender#)
  image_wrapmode#(img#, 3)
  label_text#(lblMode#, "Mode: Tile")
endfunction

function SetCenter(sender#)
  image_wrapmode#(img#, 4)
  label_text#(lblMode#, "Mode: Center")
endfunction
```

### Zoom with Mouse Wheel

```basic
let frm# = form#("Zoom", 800, 600)
form_position#(frm#, 4)

let img# = image#(frm#, 0, 40, 800, 560)
image_wrapmode#(img#, 0)
image_load#(img#, "https://picsum.photos/seed/zoom/600/400")

let lblZoom# = label#(frm#, "Zoom: 100%", 10, 10)
let zoomLevel = 100

image_onmousewheel#(img#, "OnZoom")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function OnZoom(sender#, delta, shift$) local w, h, origW, origH
  origW = image_bitmapwidth(sender#)
  origH = image_bitmapheight(sender#)
  
  if delta > 0 then
    zoomLevel = zoomLevel + 10
    if zoomLevel > 400 then
      zoomLevel = 400
    endif
  else
    zoomLevel = zoomLevel - 10
    if zoomLevel < 10 then
      zoomLevel = 10
    endif
  endif
  
  w = origW * zoomLevel / 100
  h = origH * zoomLevel / 100
  
  image_size#(sender#, w, h)
  label_text#(lblZoom#, "Zoom: " + str$(zoomLevel) + "%")
endfunction
```

### Rotate Image

```basic
let frm# = form#("Rotate", 500, 500)
form_position#(frm#, 4)

let img# = image#(frm#, 100, 50, 300, 300)
image_load#(img#, "https://picsum.photos/seed/rotate/300/300")
image_wrapmode#(img#, 1)

let lblAngle# = label#(frm#, "Angle: 0", 200, 370)

let btnLeft# = button#(frm#, "< Left", 100, 410, 120, 40)
let btnRight# = button#(frm#, "Right >", 280, 410, 120, 40)

button_onclick#(btnLeft#, "RotateLeft")
button_onclick#(btnRight#, "RotateRight")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function RotateLeft(sender#) local angle
  angle = image_rotation(img#)
  angle = angle - 15
  if angle < 0 then
    angle = angle + 360
  endif
  image_rotation#(img#, angle)
  label_text#(lblAngle#, "Angle: " + str$(angle))
endfunction

function RotateRight(sender#) local angle
  angle = image_rotation(img#)
  angle = angle + 15
  if angle >= 360 then
    angle = angle - 360
  endif
  image_rotation#(img#, angle)
  label_text#(lblAngle#, "Angle: " + str$(angle))
endfunction
```

### Opacity Toggle

```basic
let frm# = form#("Opacity", 600, 500)
form_position#(frm#, 4)

' Background
let imgBack# = image#(frm#, 50, 50, 500, 350)
image_load#(imgBack#, "https://picsum.photos/seed/back/500/350")
image_wrapmode#(imgBack#, 2)

' Foreground (will fade)
let imgFront# = image#(frm#, 50, 50, 500, 350)
image_load#(imgFront#, "https://picsum.photos/seed/front/500/350")
image_wrapmode#(imgFront#, 2)

let opacity = 1.0
let lblOpacity# = label#(frm#, "Opacity: 100%", 250, 420)

let btnFade# = button#(frm#, "Toggle", 250, 450, 100, 35)
button_onclick#(btnFade#, "ToggleFade")

form_show(frm#)

while form_visible(frm#) = 1
  processmessages()
end while

function ToggleFade(sender#) local pct
  if opacity > 0.5 then
    opacity = 0.0
  else
    opacity = 1.0
  endif
  
  image_opacity#(imgFront#, opacity)
  pct = opacity * 100
  label_text#(lblOpacity#, "Opacity: " + str$(pct) + "%")
endfunction
```

---

## Important Notes

### Pointer Initialization

```basic
let img# = Pointer#(0)
img# = image#(frm#, 0, 0, 400, 300)
```

### Local Variables

```basic
function OnClick(sender#) local w, h
  w = image_bitmapwidth(sender#)
  h = image_bitmapheight(sender#)
  println "Size: " + str$(w) + "x" + str$(h)
endfunction
```

---

## Tips and Best Practices

1. **Use Fit mode for photos** - Mode 1 preserves aspect ratio
2. **Use Stretch for backgrounds** - Mode 2 fills the control
3. **Use Tile for patterns** - Mode 3 repeats the image
4. **Check if loaded:** `if image_isempty(img#) = 1 then println "Failed" endif`
5. **Use PNG for transparency** - PNG images display transparent areas correctly
6. **Control vs Bitmap size** - `image_width` is control size, `image_bitmapwidth` is actual image size
7. **Use seed for consistent web images** - `https://picsum.photos/seed/myapp/400/300`
8. **Match sizes** - Request images at the size you'll display them

---

## See Also

- **FormLib** - Form management
- **ButtonLib** - Button controls
- **LabelLib** - Text labels
- **PanelLib** - Container controls

---

*ImageLib Version 1.0.0 - Part of the Plan9Basic GUI Library System*
