# MaskToAlphaEffectLib

Converts the luminosity (brightness) of an image to alpha (transparency). Darker pixels become more transparent, lighter pixels become more opaque. Useful for creating masks from grayscale images.

## Functions

| Function | Description |
|----------|-------------|
| `mask2a#(parent#)` | Creates mask-to-alpha effect on control |
| `mask2a_free(effect#)` | Destroys the effect |
| `mask2a_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `mask2a_enabled(effect#)` | Gets enabled state |
| `mask2a_trigger#(effect#, trigger$)` | Sets trigger string |
| `mask2a_trigger$(effect#)` | Gets trigger string |
| `mask2a_error()` | Returns last error code |
| `mask2a_errormsg$()` | Returns last error message |
| `mask2a_strerror$(code)` | Converts error code to text |
| `mask2a_clearerror()` | Clears error state |

## Properties

This effect has no configurable properties beyond Enabled and Trigger.

## How It Works

The effect converts pixel brightness to transparency:
- **White pixels (255)** → Fully opaque
- **Black pixels (0)** → Fully transparent
- **Gray pixels** → Partially transparent (proportional to brightness)

## Example 1: Basic Mask to Alpha

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let mask# = Pointer#(0)

frm# = form#("Mask to Alpha Demo", 400, 350)
form_fill#(frm#, "LightBlue")

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Apply mask-to-alpha effect
mask# = mask2a#(img#)

form_show(frm#)
```

## Example 2: Toggle Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let mask# = Pointer#(0)
let btn# = Pointer#(0)
let isOn = 1

frm# = form#("Toggle Mask Effect", 400, 350)
form_fill#(frm#, "Coral")

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

mask# = mask2a#(img#)

btn# = button#(frm#, "Disable Effect")
button_bounds#(btn#, 140, 210, 120, 30)
button_onclick#(btn#, "Toggle")

form_show(frm#)

function Toggle(sender#)
  if isOn = 1 then
    mask2a_enabled#(mask#, 0)
    isOn = 0
    button_text#(btn#, "Enable Effect")
  else
    mask2a_enabled#(mask#, 1)
    isOn = 1
    button_text#(btn#, "Disable Effect")
  endif
endfunction
```

## Example 3: Compare With/Without Effect

```basic
let frm# = Pointer#(0)
let img1# = Pointer#(0)
let img2# = Pointer#(0)
let mask# = Pointer#(0)
let lbl1# = Pointer#(0)
let lbl2# = Pointer#(0)

frm# = form#("Mask Comparison", 500, 350)
form_fill#(frm#, "Orange")

' Original image
img1# = image#(frm#)
image_bounds#(img1#, 50, 30, 180, 135)
image_load#(img1#, "https://picsum.photos/180/135")
lbl1# = label#(frm#, "Original", 110, 175)

' With mask-to-alpha
img2# = image#(frm#)
image_bounds#(img2#, 270, 30, 180, 135)
image_load#(img2#, "https://picsum.photos/180/135")
mask# = mask2a#(img2#)
lbl2# = label#(frm#, "Mask to Alpha", 310, 175)

form_show(frm#)
```

## Notes

- Works best with grayscale or high-contrast images
- Dark areas become transparent, revealing what's behind
- Light areas remain visible
- Use a colored form background to see the transparency effect
- No adjustable parameters - effect is automatic

## See Also

- ColorKeyAlphaEffectLib - Make specific colors transparent
- InvertEffectLib - Invert colors
- MonochromeEffectLib - Convert to grayscale
