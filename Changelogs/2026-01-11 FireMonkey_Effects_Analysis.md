# FireMonkey Effects Analysis for Plan9Basic Integration

## Executive Summary

After analyzing the 37+ FireMonkey effects against Plan9Basic's philosophy and existing architecture, I recommend a **phased integration** approach focusing on effects that provide the most value for simple applets with the least complexity.

---

## Analysis Criteria

I evaluated each effect based on:

1. **Usefulness for Simple Applets** - Does it enhance typical Plan9Basic use cases?
2. **Implementation Complexity** - How many properties need to be exposed?
3. **Cross-Platform Reliability** - Does it work consistently on all platforms?
4. **Interaction with Existing Features** - Does it complement animations?
5. **Educational Value** - Can beginners understand and use it?

---

## TIER 1: HIGH PRIORITY (Recommended for Immediate Integration)

These effects are highly useful, simple to implement, and work reliably across all platforms.

### 1. TShadowEffect ⭐⭐⭐⭐⭐
**Recommendation: INTEGRATE**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Distance | Single | 0-50 | Shadow offset distance |
| Direction | Single | 0-360 | Angle of shadow |
| Softness | Single | 0.0-1.0 | Blur amount |
| Opacity | Single | 0.0-1.0 | Transparency |
| ShadowColor | TAlphaColor | - | Shadow color |

**Why it matters**: Drop shadows are essential for modern UI design. They add depth and visual hierarchy to buttons, panels, and images. Extremely common in professional applications.

**Plan9Basic Value**: Beginners can create polished, professional-looking interfaces with minimal code.

---

### 2. TGlowEffect ⭐⭐⭐⭐⭐
**Recommendation: INTEGRATE**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Softness | Single | 0.0-9.0 | Glow spread |
| GlowColor | TAlphaColor | - | Color of glow |
| Opacity | Single | 0.0-1.0 | Intensity |

**Why it matters**: Glow effects are perfect for highlighting active elements, creating "selected" states, and sci-fi/neon aesthetics. Combined with animations, creates pulsing/breathing effects.

**Plan9Basic Value**: Great for games, interactive tutorials, and visual feedback.

---

### 3. TBlurEffect ⭐⭐⭐⭐⭐
**Recommendation: INTEGRATE**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Softness | Single | 0.0-3.0 | Blur intensity |

**Why it matters**: The simplest effect with only ONE property. Essential for: background blur, depth-of-field effects, disabled/inactive states, loading overlays.

**Plan9Basic Value**: Minimal API surface, maximum visual impact.

---

### 4. TReflectionEffect ⭐⭐⭐⭐
**Recommendation: INTEGRATE**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Length | Single | 0.0-1.0 | Reflection height |
| Opacity | Single | 0.0-1.0 | Reflection intensity |
| Offset | Integer | - | Vertical offset |

**Why it matters**: Instant "glossy" professional appearance. Common in cover-flow interfaces, product displays, and modern dashboards.

**Plan9Basic Value**: High visual impact with only 3 properties.

---

### 5. TContrastEffect ⭐⭐⭐⭐
**Recommendation: INTEGRATE**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Brightness | Single | -1.0 to 1.0 | Lightness adjustment |
| Contrast | Single | 0.0 to 2.0 | Contrast level |

**Why it matters**: Basic image manipulation that every image editor needs. Useful for: hover effects (brighten), disabled states (reduce contrast), photo editing applets.

**Plan9Basic Value**: Fundamental effect that combines well with other features.

---

### 6. TMonochromeEffect ⭐⭐⭐⭐
**Recommendation: INTEGRATE**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| (none) | - | - | No parameters needed |

**Why it matters**: Zero-parameter effect! Perfect for: disabled states, artistic effects, photo filters. Easiest possible implementation.

**Plan9Basic Value**: Simplest possible API - just add the effect.

---

### 7. TSepiaEffect ⭐⭐⭐⭐
**Recommendation: INTEGRATE**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Amount | Single | 0.0-1.0 | Effect intensity |

**Why it matters**: Classic vintage/retro appearance. Popular for: photo filters, flashback scenes, artistic styling.

**Plan9Basic Value**: Single parameter, high visual impact.

---

### 8. TInvertEffect ⭐⭐⭐
**Recommendation: INTEGRATE**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| (none) | - | - | No parameters needed |

**Why it matters**: Zero-parameter effect. Useful for: dark mode toggles, artistic effects, accessibility features, games.

**Plan9Basic Value**: Extremely simple to implement and understand.

---

## TIER 2: MEDIUM PRIORITY (Recommended for Phase 2)

These effects are useful but more specialized or complex.

### 9. TGaussianBlurEffect ⭐⭐⭐
**Recommendation: INTEGRATE (Phase 2)**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| BlurAmount | Single | 0.0-10.0 | Blur intensity |

**Why it matters**: Higher quality blur than TBlurEffect. Better for backgrounds and professional-looking blur.

**Trade-off**: More GPU-intensive than simple blur.

---

### 10. TInnerGlowEffect ⭐⭐⭐
**Recommendation: INTEGRATE (Phase 2)**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Softness | Single | 0.0-9.0 | Glow spread |
| GlowColor | TAlphaColor | - | Color of glow |
| Opacity | Single | 0.0-1.0 | Intensity |

**Why it matters**: Complements TGlowEffect. Inner glow creates different visual effects - good for buttons, text effects, and inset appearances.

---

### 11. THueAdjustEffect ⭐⭐⭐
**Recommendation: INTEGRATE (Phase 2)**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Hue | Single | -1.0 to 1.0 | Hue rotation |

**Why it matters**: Color manipulation without changing brightness. Great for: team colors, themes, photo editing.

---

### 12. TBevelEffect ⭐⭐⭐
**Recommendation: INTEGRATE (Phase 2)**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Direction | Single | 0-360 | Light direction |
| Size | Integer | 0-20 | Bevel depth |

**Why it matters**: Classic 3D embossed appearance. Useful for buttons, panels, classic UI styles.

---

### 13. TPixelateEffect ⭐⭐⭐
**Recommendation: INTEGRATE (Phase 2)**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| BlockCount | Integer | 1-100 | Pixel block count |

**Why it matters**: Retro/8-bit aesthetic, censorship effect, artistic styling. Popular for games and nostalgic interfaces.

---

### 14. TFadeTransitionEffect ⭐⭐⭐⭐
**Recommendation: INTEGRATE (Phase 2)**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Progress | Single | 0.0-1.0 | Transition progress |
| Target | TBitmap | - | Image to transition to |

**Why it matters**: THE fundamental transition effect. Cross-fade between images. When combined with FloatAnimation on Progress property, creates smooth image transitions.

**Plan9Basic Value**: Essential for slideshows, tutorials, game state changes.

---

## TIER 3: SPECIALIZED (Optional/Future)

These effects are more complex or have limited use cases.

### 15. TRippleEffect ⭐⭐
**Recommendation: CONSIDER (Phase 3)**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Amplitude | Single | 0-100 | Wave height |
| AspectRatio | Single | - | Width/height ratio |
| Center | TPointF | - | Ripple origin |
| Frequency | Single | 0-100 | Wave count |
| Phase | Single | 0-360 | Animation phase |

**Why it matters**: Water ripple effect. Interactive when animating Phase property. Good for: water surfaces, click feedback, sci-fi effects.

**Complexity**: 5 properties, requires understanding TPointF.

---

### 16. TSwirlEffect ⭐⭐
**Recommendation: CONSIDER (Phase 3)**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Center | TPointF | - | Swirl center |
| Strength | Single | -2.0 to 2.0 | Swirl intensity |
| AspectRatio | Single | - | Shape ratio |

**Why it matters**: Spiral/vortex distortion. Fun for games, transitions, artistic effects.

---

### 17. TWaveEffect ⭐⭐
**Recommendation: CONSIDER (Phase 3)**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Size | Integer | - | Wave amplitude |
| Time | Single | - | Animation time |

**Why it matters**: Undulating wave effect. Good for water, flags, organic movement.

---

### 18. TDirectionalBlurEffect ⭐⭐
**Recommendation: CONSIDER (Phase 3)**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| BlurAmount | Single | 0.0-10.0 | Blur intensity |
| Angle | Single | 0-360 | Motion direction |

**Why it matters**: Motion blur effect. Good for speed effects, movement indication.

---

### 19. TMagnifyEffect ⭐⭐
**Recommendation: CONSIDER (Phase 3)**

| Property | Type | Range | Purpose |
|----------|------|-------|---------|
| Center | TPointF | - | Lens center |
| Radius | Single | - | Magnification area |
| AspectRatio | Single | - | Shape ratio |
| Magnification | Single | - | Zoom level |

**Why it matters**: Magnifying glass effect. Good for: image viewers, detail zoom, interactive exploration.

---

## TIER 4: NOT RECOMMENDED

These effects are too complex or have limited value for Plan9Basic.

### TBloomEffect / TGloomEffect
**Recommendation: SKIP**
- Complex parameter interactions
- Difficult to use correctly
- Niche use cases

### TEmbossEffect / TPencilEffect / TToonEffect
**Recommendation: SKIP**
- Artistic filters with limited practical use
- Results often disappointing without fine-tuning

### TFillRGBEffect
**Recommendation: SKIP**
- Can be achieved more simply with other methods
- Limited practical use

### TBandsEffect / TTilerEffect / TWrapEffect
**Recommendation: SKIP**
- Highly specialized
- Confusing parameters
- Rarely used in practice

### All Complex Transition Effects
**Recommendation: SKIP (except TFadeTransitionEffect)**
- TSlideTransitionEffect - Slide can be achieved with animations
- TBlurTransitionEffect - Niche
- TSwipeTransitionEffect - Complex parameters
- TSwirlTransitionEffect - Niche
- TWiggleTransitionEffect - Niche
- TWaterTransitionEffect - Niche
- TBandedSwirlTransitionEffect - Niche
- TRippleTransitionEffect - Niche

---

## Recommended Integration Order

### Phase 1: Core Effects (8 effects)
1. TBlurEffect (simplest)
2. TMonochromeEffect (no parameters)
3. TInvertEffect (no parameters)
4. TSepiaEffect (1 parameter)
5. TContrastEffect (2 parameters)
6. TShadowEffect (5 parameters - high value)
7. TGlowEffect (3 parameters)
8. TReflectionEffect (3 parameters)

### Phase 2: Enhanced Effects (5 effects)
9. TGaussianBlurEffect
10. TInnerGlowEffect
11. THueAdjustEffect
12. TBevelEffect
13. TPixelateEffect

### Phase 3: Transition & Distortion (2+ effects)
14. TFadeTransitionEffect
15. TRippleEffect (optional)
16. Others as requested

---

## Implementation Architecture

### Naming Convention
Following the animation library pattern:
- `blur#(parent#)` - Create blur effect
- `blur_softness#(effect#, value)` - Set softness
- `blur_softness(effect#)` - Get softness
- `blur_enabled#(effect#, value)` - Enable/disable
- `blur_free(effect#)` - Destroy effect

### Common Functions for ALL Effects
Every effect library should include:
```
effect_error@           - Get last error code
effect_errormsg$@       - Get error message
effect_strerror$@n      - Error code to string
effect_clearerror@      - Clear error state

effect#@#               - Create effect on parent
effect_free@#           - Destroy effect
effect_enabled#@#n      - Enable/disable
effect_enabled@#        - Get enabled state
effect_trigger#@#$      - Set trigger string
effect_trigger$@#       - Get trigger string
```

### Wrapper Class Pattern
```pascal
TBasBlurEffect = class(TBlurEffect)
private
  // No callbacks needed for effects (unlike animations)
public
  constructor Create(AOwner: TComponent); override;
  destructor Destroy(); override;
end;
```

### Key Difference from Animations
Effects are simpler than animations:
- **No callbacks** (OnFinish, OnProcess) - effects are static
- **No temporal properties** (Duration, Delay, Loop)
- **Fewer functions** per effect
- **Instant application** - no Start/Stop methods

Effects ARE animatable via FloatAnimationLib:
```basic
' Animate blur softness from 0 to 3 over 2 seconds
let blur# = blur#(myImage#)
let ani# = floatani#(blur#)
floatani_propertyname#(ani#, "Softness")
floatani_startvalue#(ani#, 0.0)
floatani_stopvalue#(ani#, 3.0)
floatani_duration#(ani#, 2.0)
floatani_start(ani#)
```

---

## Estimated Implementation Effort

| Effect | Properties | Functions | Est. Lines | Effort |
|--------|------------|-----------|------------|--------|
| TBlurEffect | 1 | ~12 | ~350 | Low |
| TMonochromeEffect | 0 | ~8 | ~250 | Very Low |
| TInvertEffect | 0 | ~8 | ~250 | Very Low |
| TSepiaEffect | 1 | ~12 | ~350 | Low |
| TContrastEffect | 2 | ~16 | ~450 | Low |
| TShadowEffect | 5 | ~28 | ~700 | Medium |
| TGlowEffect | 3 | ~20 | ~500 | Low |
| TReflectionEffect | 3 | ~20 | ~500 | Low |

**Total Phase 1**: ~3,350 lines across 8 libraries

---

## Questions for Consideration

1. **Should effects be combinable?** Multiple effects can be added to a single control. Should we document/test this?

2. **Effect order matters**: When multiple effects are applied, order affects result. Should we expose Parent property to allow reordering?

3. **Performance warnings**: Should we warn users about GPU-intensive effects on mobile?

4. **Animation integration**: Should we create helper functions like `blur_animate#(effect#, prop$, from, to, duration)` for common animation patterns?

