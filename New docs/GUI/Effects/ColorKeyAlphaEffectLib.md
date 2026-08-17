# ColorKeyAlphaEffectLib

Makes pixels of a specific color transparent. Works on image textures.

**Important:** Tolerance must be greater than 0 for any colors to become transparent!

## Functions

| Function | Description |
|----------|-------------|
| `colorkey#(parent#)` | Creates color key effect on control |
| `colorkey_free(effect#)` | Destroys the effect |
| `colorkey_color#(effect#, color$)` | Sets color to make transparent |
| `colorkey_color$(effect#)` | Gets the color |
| `colorkey_tolerance#(effect#, value)` | Sets tolerance (0.0-1.0) |
| `colorkey_tolerance(effect#)` | Gets tolerance |
| `colorkey_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `colorkey_enabled(effect#)` | Gets enabled state |
| `colorkey_trigger#(effect#, trigger$)` | Sets trigger string |
| `colorkey_trigger$(effect#)` | Gets trigger string |
| `colorkey_error()` | Returns last error code |
| `colorkey_errormsg$()` | Returns last error message |
| `colorkey_strerror$(code)` | Converts error code to text |
| `colorkey_clearerror()` | Clears error state |

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| Color | color name | - | Color to make transparent |
| Tolerance | 0.0 - 1.0 | 0.0 | Color matching tolerance |

## Color Values

Colors can be specified as:
- Named colors: "Red", "Green", "Blue", "Lime", "White", "Black", "Yellow", "Cyan", "Magenta"
- Hex RGB: "#RRGGBB" (e.g., "#00FF00" for green)
- Hex ARGB: "#AARRGGBB" (e.g., "#FF00FF00")

## Important Notes

- **Tolerance=0 means NO colors become transparent** - you must set Tolerance > 0
- As Tolerance increases, more similar colors become transparent
- This effect works on **textures/images**, not vector shapes
- Common use: green screen removal with "Lime" or "#00FF00"

## Example 1: Adjustable Tolerance

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let ck# = Pointer#(0)
let trkTol# = Pointer#(0)
let lblTol# = Pointer#(0)

frm# = form#("ColorKey Control", 450, 380)

img# = image#(frm#)
image_bounds#(img#, 125, 20, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

ck# = colorkey#(img#)
colorkey_color#(ck#, "Green")
colorkey_tolerance#(ck#, 0.2)

' Tolerance control
lblTol# = label#(frm#, "Tolerance: 0.20", 50, 190)
trkTol# = trackbar#(frm#)
trackbar_bounds#(trkTol#, 50, 220, 350, 30)
trackbar_max#(trkTol#, 100)
trackbar_value#(trkTol#, 20)
trackbar_onchange#(trkTol#, "OnTolChange")

form_show(frm#)

function OnTolChange(sender#) local v
  let v = trackbar_value(trkTol#) / 100
  colorkey_tolerance#(ck#, v)
  label_text#(lblTol#, "Tolerance: " + stri$(v, 2))
endfunction
```

## Example 2: Toggle Effect

```basic
' Working ColorKey Demo - uses image with SOLID lime background
let frm# = Pointer#(0)
let img# = Pointer#(0)
let ck# = Pointer#(0)
let btn# = Pointer#(0)
let isOn = 0

frm# = form#("ChromaKey Demo", 400, 300)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
' Need an image with actual solid green background for this to work
image_load#(img#, "https://picsum.photos/200/150")

ck# = colorkey#(img#)
colorkey_enabled#(ck#, 0)
colorkey_color#(ck#, "Lime")
colorkey_tolerance#(ck#, 0.1)

btn# = button#(frm#, "Enable Effect")
button_bounds#(btn#, 140, 210, 120, 30)
button_onclick#(btn#, "Toggle")

form_show(frm#)

function Toggle(sender#)
  if isOn = 0 then
    colorkey_enabled#(ck#, 1)
    isOn = 1
    button_text#(btn#, "Disable Effect")
  else
    colorkey_enabled#(ck#, 0)
    isOn = 0
    button_text#(btn#, "Enable Effect")
  endif
endfunction
```

## See Also

- MonochromeEffectLib - Convert to grayscale
- InvertEffectLib - Invert colors
- HueAdjustEffectLib - Adjust hue values
