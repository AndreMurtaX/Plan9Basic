' ============================================================================
' Light Effects Test Applet
' Tests: BloomEffect, GloomEffect
' ============================================================================

let frmMain# = Pointer#(0)
let imgSource# = Pointer#(0)
let lblStatus# = Pointer#(0)
let lblEffect# = Pointer#(0)
let btnPrev# = Pointer#(0)
let btnNext# = Pointer#(0)
let trkIntensity# = Pointer#(0)
let trkBaseInt# = Pointer#(0)
let trkSaturation# = Pointer#(0)
let lblIntensity# = Pointer#(0)
let lblBaseInt# = Pointer#(0)
let lblSaturation# = Pointer#(0)

' Current effect pointer
let currentEffect# = Pointer#(0)
let currentIndex = 0
let effectCount = 2

' ============================================================================
' Main Program
' ============================================================================

frmMain# = form#("Light Effects Test", 750, 550)

' Title
let lblTitle# = label#(frmMain#, "Light Effects: Bloom & Gloom", 20, 10)

' Source image
imgSource# = image#(frmMain#, 20, 40, 400, 300)
image_load#(imgSource#, "https://picsum.photos/id/28/400/300")

' Effect name label
lblEffect# = label#(frmMain#, "Current: Bloom", 20, 350)

' Status label
lblStatus# = label#(frmMain#, "Use Next/Prev to switch effects", 20, 375)

' Intensity trackbar (BloomIntensity or GloomIntensity)
let lblInt# = label#(frmMain#, "Effect Intensity:", 20, 410)
trkIntensity# = trackbar#(frmMain#, 140, 405, 200, 30)
trackbar_max#(trkIntensity#, 100)
trackbar_value#(trkIntensity#, 50)
trackbar_onchange#(trkIntensity#, "OnIntensityChange")
lblIntensity# = label#(frmMain#, "0.50", 350, 410)

' Base Intensity trackbar
let lblBase# = label#(frmMain#, "Base Intensity:", 20, 445)
trkBaseInt# = trackbar#(frmMain#, 140, 440, 200, 30)
trackbar_max#(trkBaseInt#, 100)
trackbar_value#(trkBaseInt#, 100)
trackbar_onchange#(trkBaseInt#, "OnBaseIntChange")
lblBaseInt# = label#(frmMain#, "1.00", 350, 445)

' Saturation trackbar
let lblSat# = label#(frmMain#, "Saturation:", 20, 480)
trkSaturation# = trackbar#(frmMain#, 140, 475, 200, 30)
trackbar_max#(trkSaturation#, 100)
trackbar_value#(trkSaturation#, 100)
trackbar_onchange#(trkSaturation#, "OnSaturationChange")
lblSaturation# = label#(frmMain#, "1.00", 350, 480)

' Navigation buttons
btnPrev# = button#(frmMain#, "< Prev", 20, 515, 80, 30)
button_onclick#(btnPrev#, "OnPrevClick")

btnNext# = button#(frmMain#, "Next >", 110, 515, 80, 30)
button_onclick#(btnNext#, "OnNextClick")

let btnReset# = button#(frmMain#, "Reset", 200, 515, 80, 30)
button_onclick#(btnReset#, "OnResetClick")

' Effect info panel
let lblInfo# = label#(frmMain#, "Light Effects:", 450, 40)
let lblInfo1# = label#(frmMain#, "1. Bloom - Glow around bright areas", 460, 70)
let lblInfo2# = label#(frmMain#, "2. Gloom - Darken shadow areas", 460, 95)

let lblProps# = label#(frmMain#, "Properties:", 450, 140)
let lblProp1# = label#(frmMain#, "- BloomIntensity / GloomIntensity", 460, 165)
let lblProp2# = label#(frmMain#, "- BaseIntensity (base image)", 460, 190)
let lblProp3# = label#(frmMain#, "- BloomSaturation / GloomSaturation", 460, 215)
let lblProp4# = label#(frmMain#, "- BaseSaturation (base image)", 460, 240)

let lblUsage# = label#(frmMain#, "Usage Tips:", 450, 285)
let lblTip1# = label#(frmMain#, "- Bloom: Creates dreamy/ethereal look", 460, 310)
let lblTip2# = label#(frmMain#, "- Gloom: Creates moody/dark atmosphere", 460, 335)
let lblTip3# = label#(frmMain#, "- Combine with other effects!", 460, 360)

' Initialize first effect
CreateEffect(0)

form_show(frmMain#)

end

' ============================================================================
' Event Handlers
' ============================================================================

function OnIntensityChange(sender#) local val
  val = trackbar_value(trkIntensity#) / 100
  label_text#(lblIntensity#, FormatFloat$(val))
  UpdateEffectIntensity(val)
end function

function OnBaseIntChange(sender#) local val
  val = trackbar_value(trkBaseInt#) / 100
  label_text#(lblBaseInt#, FormatFloat$(val))
  UpdateBaseIntensity(val)
end function

function OnSaturationChange(sender#) local val
  val = trackbar_value(trkSaturation#) / 100
  label_text#(lblSaturation#, FormatFloat$(val))
  UpdateSaturation(val)
end function

function OnPrevClick(sender#)
  RemoveCurrentEffect()
  currentIndex = currentIndex - 1
  if currentIndex < 0 then
    currentIndex = effectCount - 1
  end if
  CreateEffect(currentIndex)
  ResetSliders()
end function

function OnNextClick(sender#)
  RemoveCurrentEffect()
  currentIndex = currentIndex + 1
  if currentIndex >= effectCount then
    currentIndex = 0
  end if
  CreateEffect(currentIndex)
  ResetSliders()
end function

function OnResetClick(sender#)
  ResetSliders()
  UpdateEffectIntensity(0.5)
  UpdateBaseIntensity(1.0)
  UpdateSaturation(1.0)
end function

' ============================================================================
' Helper Functions
' ============================================================================

function FormatFloat$(val) local s$
  s$ = stri$(val)
  if len(s$) > 4 then
    s$ = left$(s$, 4)
  end if
  return s$
end function

function ResetSliders()
  trackbar_value#(trkIntensity#, 50)
  trackbar_value#(trkBaseInt#, 100)
  trackbar_value#(trkSaturation#, 100)
  label_text#(lblIntensity#, "0.50")
  label_text#(lblBaseInt#, "1.00")
  label_text#(lblSaturation#, "1.00")
end function

function GetEffectName$(index) local name$
  if index = 0 then
    name$ = "Bloom"
  end if
  if index = 1 then
    name$ = "Gloom"
  end if
  return name$
end function

function RemoveCurrentEffect()
  if PntToNum(currentEffect#) = 0 then
    return 0
  end if
  
  if currentIndex = 0 then
    bloom_free(currentEffect#)
  end if
  if currentIndex = 1 then
    gloom_free(currentEffect#)
  end if
  
  currentEffect# = Pointer#(0)
end function

function CreateEffect(index)
  label_text#(lblEffect#, "Current: " + GetEffectName$(index))
  label_text#(lblStatus#, "Effect " + stri$(index + 1) + " of " + stri$(effectCount))
  
  if index = 0 then
    CreateBloom()
  end if
  if index = 1 then
    CreateGloom()
  end if
end function

function UpdateEffectIntensity(val)
  if PntToNum(currentEffect#) = 0 then
    return 0
  end if
  
  if currentIndex = 0 then
    bloom_bloomintensity#(currentEffect#, val)
  end if
  if currentIndex = 1 then
    gloom_gloomintensity#(currentEffect#, val)
  end if
end function

function UpdateBaseIntensity(val)
  if PntToNum(currentEffect#) = 0 then
    return 0
  end if
  
  if currentIndex = 0 then
    bloom_baseintensity#(currentEffect#, val)
  end if
  if currentIndex = 1 then
    gloom_baseintensity#(currentEffect#, val)
  end if
end function

function UpdateSaturation(val)
  if PntToNum(currentEffect#) = 0 then
    return 0
  end if
  
  if currentIndex = 0 then
    bloom_bloomsaturation#(currentEffect#, val)
    bloom_basesaturation#(currentEffect#, val)
  end if
  if currentIndex = 1 then
    gloom_gloomsaturation#(currentEffect#, val)
    gloom_basesaturation#(currentEffect#, val)
  end if
end function

' ============================================================================
' Effect Creation Functions
' ============================================================================

function CreateBloom()
  currentEffect# = bloom#(imgSource#)
  bloom_bloomintensity#(currentEffect#, 0.5)
  bloom_baseintensity#(currentEffect#, 1.0)
  bloom_bloomsaturation#(currentEffect#, 1.0)
  bloom_basesaturation#(currentEffect#, 1.0)
end function

function CreateGloom()
  currentEffect# = gloom#(imgSource#)
  gloom_gloomintensity#(currentEffect#, 0.5)
  gloom_baseintensity#(currentEffect#, 1.0)
  gloom_gloomsaturation#(currentEffect#, 1.0)
  gloom_basesaturation#(currentEffect#, 1.0)
end function
