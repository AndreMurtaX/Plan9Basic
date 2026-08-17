' ============================================================================
' Fill & Special Effects Test Applet (Tier 9)
' Tests: Fill, FillRGB, MaskToAlpha, SmoothMagnify, Pinch, BandedSwirl, Blend
' ============================================================================

let frmMain# = Pointer#(0)
let imgSource# = Pointer#(0)
let imgBlend# = Pointer#(0)
let lblStatus# = Pointer#(0)
let lblEffect# = Pointer#(0)
let btnPrev# = Pointer#(0)
let btnNext# = Pointer#(0)

' Trackbars for properties
let trk1# = Pointer#(0)
let trk2# = Pointer#(0)
let trk3# = Pointer#(0)
let trk4# = Pointer#(0)
let lbl1# = Pointer#(0)
let lbl2# = Pointer#(0)
let lbl3# = Pointer#(0)
let lbl4# = Pointer#(0)
let lblVal1# = Pointer#(0)
let lblVal2# = Pointer#(0)
let lblVal3# = Pointer#(0)
let lblVal4# = Pointer#(0)

' Apply blend button
let btnApplyBlend# = Pointer#(0)

' Current effect pointer
let currentEffect# = Pointer#(0)
let currentIndex = 0
let effectCount = 7

' ============================================================================
' Main Program
' ============================================================================

frmMain# = form#("Fill & Special Effects Test", 850, 620)

' Title
let lblTitle# = label#(frmMain#, "Fill & Special Effects Gallery", 20, 10)

' Source image
imgSource# = image#(frmMain#, 20, 40, 400, 300)
image_load#(imgSource#, "https://picsum.photos/id/15/400/300")

' Blend target image (visible so user can see what will blend)
let lblBlendImg# = label#(frmMain#, "Blend Target:", 440, 40)
imgBlend# = image#(frmMain#, 440, 60, 150, 100)
image_load#(imgBlend#, "https://picsum.photos/id/20/150/100")

' Effect name label
lblEffect# = label#(frmMain#, "Current: Fill", 20, 350)

' Status label
lblStatus# = label#(frmMain#, "Use Next/Prev to switch effects", 20, 375)

' Property controls - Row 1
lbl1# = label#(frmMain#, "Property 1:", 20, 410)
trk1# = trackbar#(frmMain#, 120, 405, 180, 30)
trackbar_max#(trk1#, 100)
trackbar_value#(trk1#, 50)
trackbar_onchange#(trk1#, "OnTrack1Change")
lblVal1# = label#(frmMain#, "50", 310, 410)

' Property controls - Row 2
lbl2# = label#(frmMain#, "Property 2:", 20, 445)
trk2# = trackbar#(frmMain#, 120, 440, 180, 30)
trackbar_max#(trk2#, 100)
trackbar_value#(trk2#, 50)
trackbar_onchange#(trk2#, "OnTrack2Change")
lblVal2# = label#(frmMain#, "50", 310, 445)

' Property controls - Row 3
lbl3# = label#(frmMain#, "Property 3:", 20, 480)
trk3# = trackbar#(frmMain#, 120, 475, 180, 30)
trackbar_max#(trk3#, 100)
trackbar_value#(trk3#, 50)
trackbar_onchange#(trk3#, "OnTrack3Change")
lblVal3# = label#(frmMain#, "50", 310, 480)

' Property controls - Row 4
lbl4# = label#(frmMain#, "Property 4:", 20, 515)
trk4# = trackbar#(frmMain#, 120, 510, 180, 30)
trackbar_max#(trk4#, 100)
trackbar_value#(trk4#, 50)
trackbar_onchange#(trk4#, "OnTrack4Change")
lblVal4# = label#(frmMain#, "50", 310, 515)

' Navigation buttons
btnPrev# = button#(frmMain#, "< Prev", 20, 565, 80, 30)
button_onclick#(btnPrev#, "OnPrevClick")

btnNext# = button#(frmMain#, "Next >", 110, 565, 80, 30)
button_onclick#(btnNext#, "OnNextClick")

let btnReset# = button#(frmMain#, "Reset", 200, 565, 80, 30)
button_onclick#(btnReset#, "OnResetClick")

' Apply Blend button (for Blend effect)
btnApplyBlend# = button#(frmMain#, "Apply Blend", 290, 565, 100, 30)
button_onclick#(btnApplyBlend#, "OnApplyBlendClick")

' Effect info panel
let lblInfo# = label#(frmMain#, "Effects (Tier 9):", 450, 175)
let lblInfo1# = label#(frmMain#, "1. Fill - Solid color fill", 460, 200)
let lblInfo2# = label#(frmMain#, "2. FillRGB - RGB tint", 460, 220)
let lblInfo3# = label#(frmMain#, "3. MaskToAlpha - Grayscale to alpha", 460, 240)
let lblInfo4# = label#(frmMain#, "4. SmoothMagnify - Magnify lens", 460, 260)
let lblInfo5# = label#(frmMain#, "5. Pinch - Pinch/bulge", 460, 280)
let lblInfo6# = label#(frmMain#, "6. BandedSwirl - Banded swirl", 460, 300)
let lblInfo7# = label#(frmMain#, "7. Blend - Click Apply Blend btn", 460, 320)

' Initialize first effect
CreateEffect(0)
UpdatePropertyLabels()

form_show(frmMain#)

end

' ============================================================================
' Event Handlers
' ============================================================================

function OnTrack1Change(sender#)
  UpdateEffect1()
end function

function OnTrack2Change(sender#)
  UpdateEffect2()
end function

function OnTrack3Change(sender#)
  UpdateEffect3()
end function

function OnTrack4Change(sender#)
  UpdateEffect4()
end function

function OnPrevClick(sender#)
  RemoveCurrentEffect()
  currentIndex = currentIndex - 1
  if currentIndex < 0 then
    currentIndex = effectCount - 1
  end if
  CreateEffect(currentIndex)
  ResetSliders()
  UpdatePropertyLabels()
end function

function OnNextClick(sender#)
  RemoveCurrentEffect()
  currentIndex = currentIndex + 1
  if currentIndex >= effectCount then
    currentIndex = 0
  end if
  CreateEffect(currentIndex)
  ResetSliders()
  UpdatePropertyLabels()
end function

function OnResetClick(sender#)
  ResetSliders()
  RemoveCurrentEffect()
  CreateEffect(currentIndex)
end function

function OnApplyBlendClick(sender#)
  ' Manually apply blend target (for when images are loaded)
  if currentIndex = 6 then
    if PntToNum(currentEffect#) <> 0 then
      blend_target#(currentEffect#, imgBlend#)
      label_text#(lblStatus#, "Blend target applied!")
    end if
  else
    label_text#(lblStatus#, "Switch to Blend effect first (effect 7)")
  end if
end function

' ============================================================================
' Helper Functions
' ============================================================================

function ResetSliders()
  trackbar_value#(trk1#, 50)
  trackbar_value#(trk2#, 50)
  trackbar_value#(trk3#, 50)
  trackbar_value#(trk4#, 50)
  label_text#(lblVal1#, "50")
  label_text#(lblVal2#, "50")
  label_text#(lblVal3#, "50")
  label_text#(lblVal4#, "50")
end function

function GetEffectName$(index) local name$
  if index = 0 then name$ = "Fill"
  if index = 1 then name$ = "FillRGB"
  if index = 2 then name$ = "MaskToAlpha"
  if index = 3 then name$ = "SmoothMagnify"
  if index = 4 then name$ = "Pinch"
  if index = 5 then name$ = "BandedSwirl"
  if index = 6 then name$ = "Blend"
  return name$
end function

function UpdatePropertyLabels()
  if currentIndex = 0 then
    ' Fill: Color (RGB components)
    label_text#(lbl1#, "Red:")
    label_text#(lbl2#, "Green:")
    label_text#(lbl3#, "Blue:")
    label_text#(lbl4#, "(unused):")
  end if
  if currentIndex = 1 then
    ' FillRGB: Color (RGB components)
    label_text#(lbl1#, "Red:")
    label_text#(lbl2#, "Green:")
    label_text#(lbl3#, "Blue:")
    label_text#(lbl4#, "(unused):")
  end if
  if currentIndex = 2 then
    ' MaskToAlpha: No adjustable properties
    label_text#(lbl1#, "(no props):")
    label_text#(lbl2#, "(no props):")
    label_text#(lbl3#, "(no props):")
    label_text#(lbl4#, "(no props):")
  end if
  if currentIndex = 3 then
    ' SmoothMagnify
    label_text#(lbl1#, "CenterX:")
    label_text#(lbl2#, "CenterY:")
    label_text#(lbl3#, "Magnify:")
    label_text#(lbl4#, "Radius:")
  end if
  if currentIndex = 4 then
    ' Pinch
    label_text#(lbl1#, "CenterX:")
    label_text#(lbl2#, "CenterY:")
    label_text#(lbl3#, "Radius:")
    label_text#(lbl4#, "Strength:")
  end if
  if currentIndex = 5 then
    ' BandedSwirl
    label_text#(lbl1#, "CenterX:")
    label_text#(lbl2#, "CenterY:")
    label_text#(lbl3#, "Bands:")
    label_text#(lbl4#, "Strength:")
  end if
  if currentIndex = 6 then
    ' Blend
    label_text#(lbl1#, "(click Apply):")
    label_text#(lbl2#, "(no props):")
    label_text#(lbl3#, "(no props):")
    label_text#(lbl4#, "(no props):")
  end if
end function

function RemoveCurrentEffect()
  if PntToNum(currentEffect#) = 0 then
    return 0
  end if
  
  if currentIndex = 0 then fill_free(currentEffect#)
  if currentIndex = 1 then fillrgb_free(currentEffect#)
  if currentIndex = 2 then mask2a_free(currentEffect#)
  if currentIndex = 3 then smag_free(currentEffect#)
  if currentIndex = 4 then pinch_free(currentEffect#)
  if currentIndex = 5 then bswirl_free(currentEffect#)
  if currentIndex = 6 then blend_free(currentEffect#)
  
  currentEffect# = Pointer#(0)
end function

function CreateEffect(index)
  label_text#(lblEffect#, "Current: " + GetEffectName$(index))
  label_text#(lblStatus#, "Effect " + stri$(index + 1) + " of " + stri$(effectCount))
  
  if index = 0 then CreateFill()
  if index = 1 then CreateFillRGB()
  if index = 2 then CreateMaskToAlpha()
  if index = 3 then CreateSmoothMagnify()
  if index = 4 then CreatePinch()
  if index = 5 then CreateBandedSwirl()
  if index = 6 then CreateBlend()
end function

' ============================================================================
' Effect Property Updates
' ============================================================================

function MakeColor(r, g, b) local c
  ' Create ARGB color: Alpha=255, R, G, B
  c = 4278190080 + r * 65536 + g * 256 + b
  return c
end function

function UpdateEffect1() local val
  val = trackbar_value(trk1#)
  label_text#(lblVal1#, stri$(val))
  
  if PntToNum(currentEffect#) = 0 then return 0
  
  if currentIndex = 0 then
    ' Fill: Red component
    UpdateFillColor()
  end if
  if currentIndex = 1 then
    ' FillRGB: Red component
    UpdateFillRGBColor()
  end if
  if currentIndex = 3 then
    ' SmoothMagnify: CenterX
    smag_centerx#(currentEffect#, val / 100)
  end if
  if currentIndex = 4 then
    ' Pinch: CenterX
    pinch_centerx#(currentEffect#, val / 100)
  end if
  if currentIndex = 5 then
    ' BandedSwirl: CenterX
    bswirl_centerx#(currentEffect#, val / 100)
  end if
end function

function UpdateEffect2() local val
  val = trackbar_value(trk2#)
  label_text#(lblVal2#, stri$(val))
  
  if PntToNum(currentEffect#) = 0 then return 0
  
  if currentIndex = 0 then
    UpdateFillColor()
  end if
  if currentIndex = 1 then
    UpdateFillRGBColor()
  end if
  if currentIndex = 3 then
    ' SmoothMagnify: CenterY
    smag_centery#(currentEffect#, val / 100)
  end if
  if currentIndex = 4 then
    ' Pinch: CenterY
    pinch_centery#(currentEffect#, val / 100)
  end if
  if currentIndex = 5 then
    ' BandedSwirl: CenterY
    bswirl_centery#(currentEffect#, val / 100)
  end if
end function

function UpdateEffect3() local val
  val = trackbar_value(trk3#)
  label_text#(lblVal3#, stri$(val))
  
  if PntToNum(currentEffect#) = 0 then return 0
  
  if currentIndex = 0 then
    UpdateFillColor()
  end if
  if currentIndex = 1 then
    UpdateFillRGBColor()
  end if
  if currentIndex = 3 then
    ' SmoothMagnify: Magnification 1-5
    smag_mag#(currentEffect#, 1 + val / 25)
  end if
  if currentIndex = 4 then
    ' Pinch: Radius 0-0.5
    pinch_radius#(currentEffect#, val / 200)
  end if
  if currentIndex = 5 then
    ' BandedSwirl: Bands 1-10
    bswirl_bands#(currentEffect#, 1 + val / 10)
  end if
end function

function UpdateEffect4() local val
  val = trackbar_value(trk4#)
  label_text#(lblVal4#, stri$(val))
  
  if PntToNum(currentEffect#) = 0 then return 0
  
  if currentIndex = 3 then
    ' SmoothMagnify: OuterRadius 0-0.5
    smag_outer#(currentEffect#, val / 200)
  end if
  if currentIndex = 4 then
    ' Pinch: Strength -1 to 1
    pinch_strength#(currentEffect#, (val - 50) / 50)
  end if
  if currentIndex = 5 then
    ' BandedSwirl: Strength -1 to 1
    bswirl_strength#(currentEffect#, (val - 50) / 50)
  end if
end function

function UpdateFillColor() local r, g, b, c
  r = trackbar_value(trk1#) * 2.55
  g = trackbar_value(trk2#) * 2.55
  b = trackbar_value(trk3#) * 2.55
  c = MakeColor(r, g, b)
  fill_color#(currentEffect#, c)
end function

function UpdateFillRGBColor() local r, g, b, c
  r = trackbar_value(trk1#) * 2.55
  g = trackbar_value(trk2#) * 2.55
  b = trackbar_value(trk3#) * 2.55
  c = MakeColor(r, g, b)
  fillrgb_color#(currentEffect#, c)
end function

' ============================================================================
' Effect Creation Functions
' ============================================================================

function CreateFill()
  currentEffect# = fill#(imgSource#)
  fill_color#(currentEffect#, MakeColor(128, 128, 128))
end function

function CreateFillRGB()
  currentEffect# = fillrgb#(imgSource#)
  fillrgb_color#(currentEffect#, MakeColor(128, 128, 128))
end function

function CreateMaskToAlpha()
  currentEffect# = mask2a#(imgSource#)
end function

function CreateSmoothMagnify()
  currentEffect# = smag#(imgSource#)
  smag_centerx#(currentEffect#, 0.5)
  smag_centery#(currentEffect#, 0.5)
  smag_mag#(currentEffect#, 2.0)
  smag_inner#(currentEffect#, 0.1)
  smag_outer#(currentEffect#, 0.25)
end function

function CreatePinch()
  currentEffect# = pinch#(imgSource#)
  pinch_centerx#(currentEffect#, 0.5)
  pinch_centery#(currentEffect#, 0.5)
  pinch_radius#(currentEffect#, 0.25)
  pinch_strength#(currentEffect#, 0)
end function

function CreateBandedSwirl()
  currentEffect# = bswirl#(imgSource#)
  bswirl_centerx#(currentEffect#, 0.5)
  bswirl_centery#(currentEffect#, 0.5)
  bswirl_bands#(currentEffect#, 3)
  bswirl_strength#(currentEffect#, 0)
end function

function CreateBlend()
  currentEffect# = blend#(imgSource#)
  label_text#(lblStatus#, "Blend created - click 'Apply Blend' button")
end function
