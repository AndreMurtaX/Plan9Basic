# BandedSwirlEffectLib

Creates a swirl distortion effect with concentric bands. Pixels rotate around a center point with alternating band patterns.

## Functions

| Function | Description |
|----------|-------------|
| `bswirl#(parent#)` | Creates banded swirl effect on control |
| `bswirl_free(effect#)` | Destroys the effect |
| `bswirl_centerx#(effect#, value)` | Sets center X (0.0-1.0) |
| `bswirl_centerx(effect#)` | Gets center X |
| `bswirl_centery#(effect#, value)` | Sets center Y (0.0-1.0) |
| `bswirl_centery(effect#)` | Gets center Y |
| `bswirl_bands#(effect#, value)` | Sets number of bands |
| `bswirl_bands(effect#)` | Gets number of bands |
| `bswirl_strength#(effect#, value)` | Sets swirl strength |
| `bswirl_strength(effect#)` | Gets strength |
| `bswirl_aspect#(effect#, value)` | Sets aspect ratio |
| `bswirl_aspect(effect#)` | Gets aspect ratio |
| `bswirl_enabled#(effect#, value)` | Enables (1) or disables (0) |
| `bswirl_enabled(effect#)` | Gets enabled state |
| `bswirl_trigger#(effect#, trigger$)` | Sets trigger string |
| `bswirl_trigger$(effect#)` | Gets trigger string |
| `bswirl_error()` | Returns last error code |
| `bswirl_errormsg$()` | Returns last error message |
| `bswirl_strerror$(code)` | Converts error code to text |
| `bswirl_clearerror()` | Clears error state |

## Properties

| Property | Range | Default | Description |
|----------|-------|---------|-------------|
| CenterX | 0.0 - 1.0 | 0.5 | Horizontal center of swirl |
| CenterY | 0.0 - 1.0 | 0.5 | Vertical center of swirl |
| Bands | 1+ | 10 | Number of swirl bands |
| Strength | any | 0.5 | Intensity of swirl distortion |
| AspectRatio | any | 1.0 | Aspect ratio adjustment |

## Example 1: Basic Banded Swirl

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let bsw# = Pointer#(0)

frm# = form#("Banded Swirl Demo", 400, 350)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

' Create banded swirl effect
bsw# = bswirl#(img#)
bswirl_bands#(bsw#, 5)
bswirl_strength#(bsw#, 0.8)

form_show(frm#)
```

## Example 2: Interactive Strength Control

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let bsw# = Pointer#(0)
let trkStr# = Pointer#(0)
let lblStr# = Pointer#(0)

frm# = form#("Swirl Strength", 450, 400)

img# = image#(frm#)
image_bounds#(img#, 125, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

bsw# = bswirl#(img#)
bswirl_bands#(bsw#, 8)
bswirl_strength#(bsw#, 0)

' Strength slider
lblStr# = label#(frm#, "Strength: 0.00", 50, 200)
trkStr# = trackbar#(frm#)
trackbar_bounds#(trkStr#, 50, 230, 350, 30)
trackbar_max#(trkStr#, 100)
trackbar_value#(trkStr#, 0)
trackbar_onchange#(trkStr#, "OnStrChange")

form_show(frm#)

function OnStrChange(sender#) local s
  let s = trackbar_value(trkStr#) / 50
  bswirl_strength#(bsw#, s)
  label_text#(lblStr#, "Strength: " + stri$(s, 2))
endfunction
```

## Example 3: Toggle Effect

```basic
let frm# = Pointer#(0)
let img# = Pointer#(0)
let bsw# = Pointer#(0)
let btn# = Pointer#(0)
let isOn = 1

frm# = form#("Toggle Banded Swirl", 400, 300)

img# = image#(frm#)
image_bounds#(img#, 100, 30, 200, 150)
image_load#(img#, "https://picsum.photos/200/150")

bsw# = bswirl#(img#)
bswirl_bands#(bsw#, 6)
bswirl_strength#(bsw#, 1.2)

btn# = button#(frm#, "Disable Effect")
button_bounds#(btn#, 140, 210, 120, 30)
button_onclick#(btn#, "Toggle")

form_show(frm#)

function Toggle(sender#)
  if isOn = 1 then
    bswirl_enabled#(bsw#, 0)
    isOn = 0
    button_text#(btn#, "Enable Effect")
  else
    bswirl_enabled#(bsw#, 1)
    isOn = 1
    button_text#(btn#, "Disable Effect")
  endif
endfunction
```

## See Also

- SwirlEffectLib - Simple swirl effect
- RippleEffectLib - Ripple distortion effect
- PinchEffectLib - Pinch distortion effect
