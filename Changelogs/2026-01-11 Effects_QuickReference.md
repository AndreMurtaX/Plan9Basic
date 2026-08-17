# Plan9Basic Effects - Quick Reference Card

## Phase 1 Effects (Implemented)

### BlurEffectLib (12 functions)

```
blur#(parent#)              - Create blur effect
blur_softness#(fx#, n)      - Set blur (0.0-3.0)
blur_softness(fx#)          - Get blur
blur_enabled#(fx#, n)       - Enable (1) / Disable (0)
blur_enabled(fx#)           - Get enabled state
blur_trigger#(fx#, s$)      - Set trigger string
blur_trigger$(fx#)          - Get trigger string
blur_free(fx#)              - Destroy effect

blur_error@                 - Get last error code
blur_errormsg$@             - Get error message
blur_strerror$@n            - Error code to string
blur_clearerror@            - Clear error state
```

### ShadowEffectLib (24 functions)

```
shadow#(parent#)            - Create shadow effect
shadow_distance#(fx#, n)    - Set offset (0-50)
shadow_distance(fx#)        - Get offset
shadow_direction#(fx#, n)   - Set angle (0-360)
shadow_direction(fx#)       - Get angle
shadow_softness#(fx#, n)    - Set blur (0.0-1.0)
shadow_softness(fx#)        - Get blur
shadow_opacity#(fx#, n)     - Set transparency (0.0-1.0)
shadow_opacity(fx#)         - Get transparency
shadow_color#(fx#, s$)      - Set color ("Black", "#404040")
shadow_color(fx#)           - Get color as number
shadow_enabled#(fx#, n)     - Enable (1) / Disable (0)
shadow_enabled(fx#)         - Get enabled state
shadow_trigger#(fx#, s$)    - Set trigger string
shadow_trigger$(fx#)        - Get trigger string
shadow_free(fx#)            - Destroy effect

shadow_error@               - Get last error code
shadow_errormsg$@           - Get error message
shadow_strerror$@n          - Error code to string
shadow_clearerror@          - Clear error state
```

### GlowEffectLib (18 functions)

```
glow#(parent#)              - Create glow effect
glow_softness#(fx#, n)      - Set spread (0.0-9.0)
glow_softness(fx#)          - Get spread
glow_color#(fx#, s$)        - Set color ("Cyan", "#00FFFF")
glow_color(fx#)             - Get color as number
glow_opacity#(fx#, n)       - Set intensity (0.0-1.0)
glow_opacity(fx#)           - Get intensity
glow_enabled#(fx#, n)       - Enable (1) / Disable (0)
glow_enabled(fx#)           - Get enabled state
glow_trigger#(fx#, s$)      - Set trigger string
glow_trigger$(fx#)          - Get trigger string
glow_free(fx#)              - Destroy effect

glow_error@                 - Get last error code
glow_errormsg$@             - Get error message
glow_strerror$@n            - Error code to string
glow_clearerror@            - Clear error state
```

---

## Common Patterns

### Basic Effect Application
```basic
let rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 50, 50, 100, 100)
rectangle_fill#(rect#, "Blue")

let shadow# = shadow#(rect#)
shadow_distance#(shadow#, 5)
shadow_softness#(shadow#, 0.4)
```

### Animated Effect
```basic
let blur# = blur#(img#)
blur_softness#(blur#, 0.0)

let ani# = floatani#(blur#)
floatani_propertyname#(ani#, "Softness")
floatani_startvalue#(ani#, 0.0)
floatani_stopvalue#(ani#, 3.0)
floatani_duration#(ani#, 2.0)
floatani_start(ani#)
```

### Trigger-Based Effect (Hover)
```basic
let glow# = glow#(btn#)
glow_color#(glow#, "Cyan")
glow_softness#(glow#, 4.0)
glow_trigger#(glow#, "IsMouseOver=true")
```

### Combined Effects
```basic
' Card with shadow and hover glow
let card# = rectangle#(frm#)
rectangle_bounds#(card#, 50, 50, 200, 120)
rectangle_fill#(card#, "White")

let shadow# = shadow#(card#)
shadow_distance#(shadow#, 4)

let glow# = glow#(card#)
glow_color#(glow#, "Blue")
glow_trigger#(glow#, "IsMouseOver=true")
```

### Pulsing Glow Animation
```basic
let glow# = glow#(circle#)
glow_color#(glow#, "Cyan")
glow_softness#(glow#, 3.0)

let ani# = floatani#(glow#)
floatani_propertyname#(ani#, "Softness")
floatani_startvalue#(ani#, 2.0)
floatani_stopvalue#(ani#, 8.0)
floatani_duration#(ani#, 0.8)
floatani_autoreverse#(ani#, 1)
floatani_loop#(ani#, 1)
floatani_start(ani#)
```

---

## Supported Colors (GlowEffectLib)

**Named Colors:**
- Basic: `Black`, `White`, `Red`, `Green`, `Blue`, `Yellow`
- Extended: `Cyan`, `Magenta`, `Gray`, `Grey`, `Silver`
- Web: `Maroon`, `Olive`, `Navy`, `Purple`, `Teal`
- Bright: `Orange`, `Pink`, `Brown`, `Lime`, `Aqua`, `Fuchsia`
- Special: `Transparent`, `Null`

**Hex Format:**
- `#RRGGBB` - e.g., `#FF0000` for red
- `#AARRGGBB` - with alpha, e.g., `#80FF0000` for 50% transparent red

---

## Trigger Strings

| Trigger | Description |
|---------|-------------|
| `IsMouseOver=true` | When mouse hovers |
| `IsMouseOver=false` | When mouse leaves |
| `IsFocused=true` | When control has focus |
| `IsPressed=true` | When pressed/clicked |

---

## Animatable Properties

| Effect | Property | Range |
|--------|----------|-------|
| Blur | Softness | 0.0-3.0 |
| Shadow | Distance | 0-50 |
| Shadow | Direction | 0-360 |
| Shadow | Softness | 0.0-1.0 |
| Shadow | Opacity | 0.0-1.0 |
| Glow | Softness | 0.0-9.0 |
| Glow | Opacity | 0.0-1.0 |

---

## Error Handling

```basic
' Check for errors after operations
if blur_error() <> 0 then
  println "Error: " + blur_errormsg$()
endif

' Get error description from code
let desc$ = blur_strerror$(errorCode)

' Clear error state before new operations
blur_clearerror()
```

| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Effect is nil |
| 2 | Invalid effect object |
| 3 | Invalid value |
| 4 | Parent is nil |
| 5 | Invalid parent |
| 6 | Invalid color |

---

## Default Values

| Effect | Property | Default |
|--------|----------|---------|
| Blur | Softness | 0.4 |
| Shadow | Distance | 3 |
| Shadow | Direction | 45 |
| Shadow | Softness | 0.3 |
| Shadow | Opacity | 0.6 |
| Shadow | Color | Black |
| Glow | Softness | 4.0 |
| Glow | Color | Yellow |
| Glow | Opacity | 0.9 |

---

## Performance Tips

1. Effects are GPU-accelerated and efficient on modern hardware
2. On mobile, use moderate values (blur < 2.0, glow softness < 7.0)
3. Minimize effect stacking on same control
4. Use triggers instead of animation for simple hover states
5. Animation via FloatAnimationLib is GPU-optimized
