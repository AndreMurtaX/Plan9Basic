# NormalBlendEffectLib

Composites a target image on top of the source image using standard alpha blending. The target image is drawn over the source based on the target's **alpha (transparency) values**.

## Important Limitation

This effect performs **alpha compositing**, not a crossfade transition. The target image overlays the source based on the target's transparency:

- **Opaque target pixels** → Completely replace source pixels
- **Transparent target pixels** → Source shows through
- **Semi-transparent target pixels** → Partial blend

**If the target image is fully opaque (no transparency), it will completely cover the source image.** This effect is best suited for overlaying graphics that have transparent regions (like watermarks, logos, or PNG images with alpha channels).

For smooth transitions between two opaque images, use **FadeTransitionEffectLib** instead.

## Functions

| Function | Description |
|----------|-------------|
| `blend#(parent#)` | Creates normal blend effect on control |
| `blend_free(effect#)` | Destroys the effect |
| `blend_target#(effect#, image#)` | Sets target image to overlay |
| `blend_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `blend_enabled(effect#)` | Gets enabled state |
| `blend_trigger#(effect#, trigger$)` | Sets trigger string |
| `blend_trigger$(effect#)` | Gets trigger string |
| `blend_error()` | Returns last error code |
| `blend_errormsg$()` | Returns last error message |
| `blend_strerror$(code)` | Converts error code to text |
| `blend_clearerror()` | Clears error state |

## Properties

| Property | Description |
|----------|-------------|
| Target | The image to overlay on top of source (should have transparency) |

## Use Cases

- Overlaying watermarks or logos
- Adding transparent PNG overlays
- Compositing images with alpha channels
- Layering graphics with transparent regions

## Example 1: Toggle Overlay Effect

```basic
let frm# = Pointer#(0)
let img1# = Pointer#(0)
let img2# = Pointer#(0)
let blend# = Pointer#(0)
let btn# = Pointer#(0)
let isOn = 1

frm# = form#("Blend Overlay Demo", 400, 350)

' Source image (base layer)
img1# = image#(frm#)
image_bounds#(img1#, 100, 30, 200, 150)
image_load#(img1#, "https://picsum.photos/200/150?random=1")

' Target image (overlay - works best with transparent PNG)
img2# = image#(frm#)
image_bounds#(img2#, 0, 0, 200, 150)
image_visible#(img2#, 0)
image_load#(img2#, "https://picsum.photos/200/150?random=2")

' Create blend effect
blend# = blend#(img1#)
blend_target#(blend#, img2#)

btn# = button#(frm#, "Disable Overlay")
button_bounds#(btn#, 130, 210, 140, 30)
button_onclick#(btn#, "Toggle")

form_show(frm#)

function Toggle(sender#)
  if isOn = 1 then
    blend_enabled#(blend#, 0)
    isOn = 0
    button_text#(btn#, "Enable Overlay")
  else
    blend_enabled#(blend#, 1)
    isOn = 1
    button_text#(btn#, "Disable Overlay")
  endif
endfunction
```

## Example 2: Compare With and Without Overlay

```basic
let frm# = Pointer#(0)
let img1# = Pointer#(0)
let img2# = Pointer#(0)
let img3# = Pointer#(0)
let blend# = Pointer#(0)
let lbl1# = Pointer#(0)
let lbl2# = Pointer#(0)

frm# = form#("Overlay Comparison", 500, 350)

' Source only
img1# = image#(frm#)
image_bounds#(img1#, 50, 30, 180, 135)
image_load#(img1#, "https://picsum.photos/180/135?random=1")
lbl1# = label#(frm#, "Source Only", 100, 175)

' With overlay
img2# = image#(frm#)
image_bounds#(img2#, 270, 30, 180, 135)
image_load#(img2#, "https://picsum.photos/180/135?random=1")

' Hidden target image for overlay
img3# = image#(frm#)
image_bounds#(img3#, 0, 0, 180, 135)
image_visible#(img3#, 0)
image_load#(img3#, "https://picsum.photos/180/135?random=2")

blend# = blend#(img2#)
blend_target#(blend#, img3#)
lbl2# = label#(frm#, "With Overlay", 315, 175)

form_show(frm#)
```

## Notes

- Target image can be hidden (visible=0) - only its bitmap is used
- **Target must have transparency** for blending to be visible
- Opaque targets completely replace the source (no blending visible)
- No opacity/blend amount control - uses target's alpha values directly
- For crossfade transitions, use FadeTransitionEffectLib instead

## See Also

- FadeTransitionEffectLib - Smooth crossfade between two opaque images
- MaskToAlphaEffectLib - Convert brightness to transparency
- ColorKeyAlphaEffectLib - Make specific colors transparent
