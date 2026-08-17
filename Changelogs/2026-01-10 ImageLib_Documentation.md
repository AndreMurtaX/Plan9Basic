# ImageLib - Image Control Library

Display bitmap images in your Plan9Basic applications with full control over scaling, positioning, and interactivity.

## Overview

ImageLib provides a complete image display control for Plan9Basic. Load images from local files or directly from the web via HTTP/HTTPS, control how they scale and position within the control bounds, and respond to user interactions through event callbacks.

**Function Count:** 85 functions

## Supported Image Formats

- PNG (recommended for transparency)
- JPEG / JPG
- BMP
- GIF

## Image Sources

Images can be loaded from two sources using the same `image_load#` function:

- **Local files:** `image_load#(img#, "photo.png")`
- **Web URLs:** `image_load#(img#, "https://picsum.photos/400/300")`

The function automatically detects URLs (starting with `http://` or `https://`) and downloads the image.

## Quick Start

```basic
' Create a form and display an image
let frm# = form#("Image Viewer", 800, 600)

' Create image control and load a picture from the web
let img# = image#(frm#, 50, 50, 400, 300)
image_load#(img#, "https://picsum.photos/400/300")

' Set scaling mode to fit while keeping aspect ratio
image_wrapmode#(img#, 1)

form_show(frm#)
```

## Free Image Sources for Testing

**Lorem Picsum** (https://picsum.photos) provides beautiful free stock photos:

| URL Pattern | Description |
|-------------|-------------|
| `https://picsum.photos/400/300` | Random image 400x300 |
| `https://picsum.photos/id/10/400/300` | Specific image by ID |
| `https://picsum.photos/seed/hello/400/300` | Consistent image from seed |
| `https://picsum.photos/400/300?grayscale` | Grayscale image |
| `https://picsum.photos/400/300?blur=5` | Blurred image (1-10) |

```basic
' Load different images from Lorem Picsum
image_load#(img1#, "https://picsum.photos/300/200")           ' Random
image_load#(img2#, "https://picsum.photos/id/237/300/200")    ' Cute dog
image_load#(img3#, "https://picsum.photos/seed/plan9/300/200") ' Consistent
image_load#(img4#, "https://picsum.photos/300/200?grayscale")  ' Grayscale
```

## Wrap Modes (Scaling)

Control how images are displayed within the control bounds:

| Value | Mode | Description |
|-------|------|-------------|
| 0 | Original | Display at original size, top-left aligned |
| 1 | Fit | Scale to fit while keeping aspect ratio (default) |
| 2 | Stretch | Stretch to fill entire control (may distort) |
| 3 | Tile | Repeat image to fill control |
| 4 | Center | Center image without resizing |
| 5 | Place | Fit if larger, center if smaller |

### Wrap Mode Examples

```basic
' Original - no scaling, top-left corner
image_wrapmode#(img#, 0)

' Fit - scale down/up to fit, keep proportions
image_wrapmode#(img#, 1)

' Stretch - fill entire control
image_wrapmode#(img#, 2)

' Tile - repeat pattern
image_wrapmode#(img#, 3)

' Center - center without resize
image_wrapmode#(img#, 4)

' Place - smart fit (shrink if needed, center if fits)
image_wrapmode#(img#, 5)
```

## Function Reference

### Error Handling

| Function | Description |
|----------|-------------|
| `image_error()` | Returns last error code (0 = no error) |
| `image_errormsg$()` | Returns last error message |
| `image_strerror$(code)` | Returns description for error code |
| `image_clearerror()` | Clears error state |

**Error Codes:**
- 0 = No error
- 1 = Invalid image
- 2 = Invalid parent
- 3 = Invalid value
- 4 = Create failed
- 5 = Invalid callback
- 6 = File not found
- 7 = Load failed
- 8 = Save failed

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
| `image_load(img#, path$)` | Load image from file or URL, returns 1 on success |
| `image_load#(img#, path$)` | Load image from file or URL, returns image pointer |
| `image_save(img#, filepath$)` | Save image to file, returns 1 on success |
| `image_save#(img#, filepath$)` | Save image, returns image pointer |

**Note:** `image_load` automatically detects web URLs (http:// or https://) and downloads the image. Local file paths are loaded directly from disk.

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
| `image_x(img#)` | Get X position |
| `image_x#(img#, x)` | Set X position |
| `image_y(img#)` | Get Y position |
| `image_y#(img#, y)` | Set Y position |
| `image_width(img#)` | Get control width |
| `image_width#(img#, w)` | Set control width |
| `image_height(img#)` | Get control height |
| `image_height#(img#, h)` | Set control height |
| `image_bounds#(img#, x, y, w, h)` | Set position and size |
| `image_size#(img#, w, h)` | Set size only |
| `image_move#(img#, x, y)` | Set position only |

### Alignment

| Function | Description |
|----------|-------------|
| `image_align(img#)` | Get alignment mode |
| `image_align#(img#, mode)` | Set alignment mode |

**Alignment Values:**
- 0 = None (manual positioning)
- 1 = Top
- 2 = Left
- 3 = Right
- 4 = Bottom
- 9 = Client (fill parent)
- 11 = Center

### Margins

| Function | Description |
|----------|-------------|
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
| `image_visible(img#)` | Get visibility (1=visible) |
| `image_visible#(img#, v)` | Set visibility |
| `image_enabled(img#)` | Get enabled state |
| `image_enabled#(img#, v)` | Set enabled state |
| `image_opacity(img#)` | Get opacity (0.0-1.0) |
| `image_opacity#(img#, v)` | Set opacity |
| `image_hittest(img#)` | Get hit test enabled |
| `image_hittest#(img#, v)` | Set hit test enabled |

### Tag and Rotation

| Function | Description |
|----------|-------------|
| `image_tag(img#)` | Get user tag value |
| `image_tag#(img#, v)` | Set user tag value |
| `image_rotation(img#)` | Get rotation angle (degrees) |
| `image_rotation#(img#, angle)` | Set rotation angle |

### Parent and Z-Order

| Function | Description |
|----------|-------------|
| `image_parent#(img#)` | Get parent control |
| `image_parent#(img#, parent#)` | Set parent control |
| `image_bringtofront#(img#)` | Bring to front of z-order |
| `image_sendtoback#(img#)` | Send to back of z-order |

### Invalidation

| Function | Description |
|----------|-------------|
| `image_invalidate#(img#)` | Force redraw |

### Event Callbacks

| Function | Description |
|----------|-------------|
| `image_onclick#(img#, func$)` | Set click handler |
| `image_onclick$(img#)` | Get click handler name |
| `image_ondblclick#(img#, func$)` | Set double-click handler |
| `image_ondblclick$(img#)` | Get double-click handler name |
| `image_onmousedown#(img#, func$)` | Set mouse down handler |
| `image_onmousedown$(img#)` | Get mouse down handler name |
| `image_onmouseup#(img#, func$)` | Set mouse up handler |
| `image_onmouseup$(img#)` | Get mouse up handler name |
| `image_onmousemove#(img#, func$)` | Set mouse move handler |
| `image_onmousemove$(img#)` | Get mouse move handler name |
| `image_onmouseenter#(img#, func$)` | Set mouse enter handler |
| `image_onmouseenter$(img#)` | Get mouse enter handler name |
| `image_onmouseleave#(img#, func$)` | Set mouse leave handler |
| `image_onmouseleave$(img#)` | Get mouse leave handler name |
| `image_onmousewheel#(img#, func$)` | Set mouse wheel handler |
| `image_onmousewheel$(img#)` | Get mouse wheel handler name |
| `image_onresize#(img#, func$)` | Set resize handler |
| `image_onresize$(img#)` | Get resize handler name |
| `image_clearcallbacks#(img#)` | Clear all callbacks |

## Event Callback Signatures

```basic
' Click event - called when image is clicked
function OnImageClick(sender#)
  println "Image clicked!"
end function

' Double-click event
function OnImageDblClick(sender#)
  println "Image double-clicked!"
end function

' Mouse down event
' button: 0=left, 1=right, 2=middle
' shift$: combination of S(hift), C(trl), A(lt), M(eta), L(eft), R(ight)
function OnImageMouseDown(sender#, button, x, y, shift$)
  println "Mouse down at: " + stri$(x) + ", " + stri$(y)
end function

' Mouse up event
function OnImageMouseUp(sender#, button, x, y, shift$)
  println "Mouse up"
end function

' Mouse move event
function OnImageMouseMove(sender#, x, y, shift$)
  println "Mouse at: " + stri$(x) + ", " + stri$(y)
end function

' Mouse enter event
function OnImageEnter(sender#)
  println "Mouse entered image"
end function

' Mouse leave event
function OnImageLeave(sender#)
  println "Mouse left image"
end function

' Mouse wheel event
function OnImageWheel(sender#, delta, shift$)
  if delta > 0 then
    println "Wheel up"
  else
    println "Wheel down"
  end if
end function

' Resize event
function OnImageResize(sender#)
  println "Image resized"
end function
```

## Complete Examples

### Web Image Gallery

```basic
' Web image gallery using Lorem Picsum
let frm# = form#("Web Image Gallery", 900, 700)

' Title
let lblTitle# = label#(frm#, "Web Image Gallery - Lorem Picsum", 20, 10)

' Create grid of images
let img1# = image#(frm#, 20, 50, 280, 200)
let img2# = image#(frm#, 310, 50, 280, 200)
let img3# = image#(frm#, 600, 50, 280, 200)
let img4# = image#(frm#, 20, 260, 280, 200)
let img5# = image#(frm#, 310, 260, 280, 200)
let img6# = image#(frm#, 600, 260, 280, 200)

' Set all to Fit mode
image_wrapmode#(img1#, 1)
image_wrapmode#(img2#, 1)
image_wrapmode#(img3#, 1)
image_wrapmode#(img4#, 1)
image_wrapmode#(img5#, 1)
image_wrapmode#(img6#, 1)

' Load images from web using consistent seeds
image_load#(img1#, "https://picsum.photos/seed/nature/280/200")
image_load#(img2#, "https://picsum.photos/seed/city/280/200")
image_load#(img3#, "https://picsum.photos/seed/ocean/280/200")
image_load#(img4#, "https://picsum.photos/seed/forest/280/200")
image_load#(img5#, "https://picsum.photos/seed/mountain/280/200")
image_load#(img6#, "https://picsum.photos/seed/sunset/280/200")

' Main display for selected image
let imgMain# = image#(frm#, 20, 480, 860, 200)
image_wrapmode#(imgMain#, 1)

' Make thumbnails clickable
image_tag#(img1#, 1)
image_tag#(img2#, 2)
image_tag#(img3#, 3)
image_tag#(img4#, 4)
image_tag#(img5#, 5)
image_tag#(img6#, 6)

image_onclick#(img1#, "OnThumbClick")
image_onclick#(img2#, "OnThumbClick")
image_onclick#(img3#, "OnThumbClick")
image_onclick#(img4#, "OnThumbClick")
image_onclick#(img5#, "OnThumbClick")
image_onclick#(img6#, "OnThumbClick")

' Status label
let lblStatus# = label#(frm#, "Click a thumbnail to view larger", 20, 690)

form_show(frm#)

function OnThumbClick(sender#) local tag, url$, seeds$
  tag = image_tag(sender#)
  seeds$ = "nature,city,ocean,forest,mountain,sunset"
  url$ = "https://picsum.photos/seed/" + word$(seeds$, tag, ",") + "/860/200"
  image_load#(imgMain#, url$)
  label_text#(lblStatus#, "Loaded: " + url$)
end function
```

### Simple Image Viewer

```basic
' Simple image viewer with wrap mode selector
let frm# = form#("Image Viewer", 800, 600)

' Create image display
let img# = image#(frm#, 10, 50, 780, 500)
image_wrapmode#(img#, 1)  ' Fit mode

' Create wrap mode buttons
let btnOriginal# = button#(frm#, "Original", 10, 10, 80, 30)
let btnFit# = button#(frm#, "Fit", 100, 10, 80, 30)
let btnStretch# = button#(frm#, "Stretch", 190, 10, 80, 30)
let btnTile# = button#(frm#, "Tile", 280, 10, 80, 30)
let btnCenter# = button#(frm#, "Center", 370, 10, 80, 30)

' Load button
let btnLoad# = button#(frm#, "Load Image", 700, 10, 90, 30)

' Status label
let lblStatus# = label#(frm#, "No image loaded", 10, 560)

' Set callbacks
button_onclick#(btnOriginal#, "SetOriginal")
button_onclick#(btnFit#, "SetFit")
button_onclick#(btnStretch#, "SetStretch")
button_onclick#(btnTile#, "SetTile")
button_onclick#(btnCenter#, "SetCenter")
button_onclick#(btnLoad#, "LoadImage")

form_show(frm#)

function SetOriginal(sender#)
  image_wrapmode#(img#, 0)
  label_text#(lblStatus#, "Mode: Original")
end function

function SetFit(sender#)
  image_wrapmode#(img#, 1)
  label_text#(lblStatus#, "Mode: Fit")
end function

function SetStretch(sender#)
  image_wrapmode#(img#, 2)
  label_text#(lblStatus#, "Mode: Stretch")
end function

function SetTile(sender#)
  image_wrapmode#(img#, 3)
  label_text#(lblStatus#, "Mode: Tile")
end function

function SetCenter(sender#)
  image_wrapmode#(img#, 4)
  label_text#(lblStatus#, "Mode: Center")
end function

function LoadImage(sender#)
  ' In real app, use file dialog
  image_load#(img#, "sample.png")
  let empty = image_isempty(img#)
  if empty = 0 then
    let w = image_bitmapwidth(img#)
    let h = image_bitmapheight(img#)
    label_text#(lblStatus#, "Loaded: " + stri$(w) + "x" + stri$(h) + " pixels")
  else
    label_text#(lblStatus#, "Failed to load image")
  end if
end function
```

### Interactive Image Gallery

```basic
' Image gallery with thumbnails
let frm# = form#("Image Gallery", 900, 600)

' Main display area
let mainImg# = image#(frm#, 200, 10, 690, 580)
image_wrapmode#(mainImg#, 1)

' Thumbnail panel
let panel# = panel#(frm#, 10, 10, 180, 580)

' Create thumbnail images
let thumb1# = image#(panel#, 10, 10, 160, 120)
let thumb2# = image#(panel#, 10, 140, 160, 120)
let thumb3# = image#(panel#, 10, 270, 160, 120)
let thumb4# = image#(panel#, 10, 400, 160, 120)

' Set thumbnails to fit mode
image_wrapmode#(thumb1#, 1)
image_wrapmode#(thumb2#, 1)
image_wrapmode#(thumb3#, 1)
image_wrapmode#(thumb4#, 1)

' Store image paths in tags (using index)
image_tag#(thumb1#, 1)
image_tag#(thumb2#, 2)
image_tag#(thumb3#, 3)
image_tag#(thumb4#, 4)

' Set click handlers
image_onclick#(thumb1#, "OnThumbClick")
image_onclick#(thumb2#, "OnThumbClick")
image_onclick#(thumb3#, "OnThumbClick")
image_onclick#(thumb4#, "OnThumbClick")

' Load thumbnails
image_load#(thumb1#, "image1.jpg")
image_load#(thumb2#, "image2.jpg")
image_load#(thumb3#, "image3.jpg")
image_load#(thumb4#, "image4.jpg")

' Show first image in main display
image_load#(mainImg#, "image1.jpg")

form_show(frm#)

function OnThumbClick(sender#) local idx, path$
  idx = image_tag(sender#)
  path$ = "image" + stri$(idx) + ".jpg"
  image_load#(mainImg#, path$)
end function
```

### Image with Zoom (Mouse Wheel)

```basic
' Zoomable image viewer
let frm# = form#("Zoomable Image", 800, 600)

let img# = image#(frm#, 0, 30, 800, 570)
image_wrapmode#(img#, 0)  ' Original mode for zoom
image_load#(img#, "photo.jpg")

let lblZoom# = label#(frm#, "Zoom: 100%", 10, 5)

let zoomLevel = 100

image_onmousewheel#(img#, "OnZoom")

form_show(frm#)

function OnZoom(sender#, delta, shift$) local w, h, origW, origH
  origW = image_bitmapwidth(sender#)
  origH = image_bitmapheight(sender#)
  
  if delta > 0 then
    zoomLevel = zoomLevel + 10
    if zoomLevel > 400 then
      zoomLevel = 400
    end if
  else
    zoomLevel = zoomLevel - 10
    if zoomLevel < 10 then
      zoomLevel = 10
    end if
  end if
  
  w = origW * zoomLevel / 100
  h = origH * zoomLevel / 100
  
  image_size#(sender#, w, h)
  label_text#(lblZoom#, "Zoom: " + stri$(zoomLevel) + "%")
end function
```

### Rotating Image

```basic
' Image with rotation control
let frm# = form#("Rotating Image", 600, 600)

let img# = image#(frm#, 150, 150, 300, 300)
image_load#(img#, "logo.png")
image_wrapmode#(img#, 1)

let lblAngle# = label#(frm#, "Angle: 0°", 250, 10)

let btnLeft# = button#(frm#, "Rotate Left", 150, 500, 120, 40)
let btnRight# = button#(frm#, "Rotate Right", 330, 500, 120, 40)

button_onclick#(btnLeft#, "RotateLeft")
button_onclick#(btnRight#, "RotateRight")

form_show(frm#)

function RotateLeft(sender#) local angle
  angle = image_rotation(img#)
  angle = angle - 15
  if angle < 0 then
    angle = angle + 360
  end if
  image_rotation#(img#, angle)
  label_text#(lblAngle#, "Angle: " + stri$(angle) + "°")
end function

function RotateRight(sender#) local angle
  angle = image_rotation(img#)
  angle = angle + 15
  if angle >= 360 then
    angle = angle - 360
  end if
  image_rotation#(img#, angle)
  label_text#(lblAngle#, "Angle: " + stri$(angle) + "°")
end function
```

### Opacity Fade Effect

```basic
' Fade between two images
let frm# = form#("Image Fade", 800, 600)

' Background image
let imgBack# = image#(frm#, 100, 100, 600, 400)
image_load#(imgBack#, "image_a.jpg")
image_wrapmode#(imgBack#, 2)

' Foreground image (will fade)
let imgFront# = image#(frm#, 100, 100, 600, 400)
image_load#(imgFront#, "image_b.jpg")
image_wrapmode#(imgFront#, 2)
image_opacity#(imgFront#, 1.0)

let opacity = 1.0

let btnFade# = button#(frm#, "Toggle Fade", 350, 520, 100, 40)
button_onclick#(btnFade#, "ToggleFade")

let lblOpacity# = label#(frm#, "Opacity: 100%", 360, 560)

form_show(frm#)

function ToggleFade(sender#) local pct
  if opacity > 0.5 then
    opacity = 0.0
  else
    opacity = 1.0
  end if
  image_opacity#(imgFront#, opacity)
  pct = opacity * 100
  label_text#(lblOpacity#, "Opacity: " + stri$(pct) + "%")
end function
```

## Tips and Best Practices

1. **Use Fit mode for photos** - Mode 1 (Fit) preserves aspect ratio and is best for displaying photographs.

2. **Use Stretch for backgrounds** - Mode 2 (Stretch) fills the entire control, good for background images where distortion is acceptable.

3. **Use Tile for patterns** - Mode 3 (Tile) repeats the image, perfect for texture backgrounds.

4. **Check if image loaded successfully:**
   ```basic
   image_load#(img#, "https://picsum.photos/400/300")
   let empty = image_isempty(img#)
   if empty = 1 then
     println "Failed to load image"
   end if
   ```

5. **Get original image dimensions:**
   ```basic
   let w = image_bitmapwidth(img#)
   let h = image_bitmapheight(img#)
   println "Image size: " + stri$(w) + "x" + stri$(h)
   ```

6. **Use PNG for transparency** - PNG images with alpha channels display correctly with transparent backgrounds.

7. **Control vs Bitmap size** - Remember that `image_width` and `image_height` refer to the control size, while `image_bitmapwidth` and `image_bitmapheight` refer to the actual loaded image dimensions.

8. **For clickable images** - HitTest is enabled by default, so images respond to mouse events. Set `image_hittest#(img#, 0)` if you want clicks to pass through.

9. **Web images are blocking** - When loading from URLs, the download blocks the UI briefly. For large images or slow connections, consider showing a "Loading..." message first.

10. **Use seed for consistent web images** - Lorem Picsum's seed parameter ensures you get the same image every time:
    ```basic
    ' Always returns the same image
    image_load#(img#, "https://picsum.photos/seed/myapp/400/300")
    ```

11. **Request appropriate sizes** - When using Lorem Picsum, request images close to your display size to minimize download time and memory usage.

## See Also

- FormLib - Window and form management
- ButtonLib - Button controls
- LabelLib - Text display
- PanelLib - Container controls
- RectangleLib - Rectangle shapes
