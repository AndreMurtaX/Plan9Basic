' ============================================================================
' Tier 6 Transition Effects Test Applet
' Tests all 17 new transition effects added in Tier 6
' ============================================================================

let frmMain# = Pointer#(0)
let imgSource# = Pointer#(0)
let lblStatus# = Pointer#(0)
let lblEffect# = Pointer#(0)
let btnPrev# = Pointer#(0)
let btnNext# = Pointer#(0)
let btnAnimate# = Pointer#(0)
let trkProgress# = Pointer#(0)
let lblProgress# = Pointer#(0)

' Current effect pointer
let currentEffect# = Pointer#(0)
let currentIndex = 0
let effectCount = 17

' ============================================================================
' Main Program
' ============================================================================

frmMain# = form#("Tier 6 Transition Effects Test", 700, 500)

' Title
let lblTitle# = label#(frmMain#, "Tier 6 Transition Effects Gallery", 20, 10)

' Source image
imgSource# = image#(frmMain#, 20, 40, 400, 300)
image_load#(imgSource#, "https://picsum.photos/id/15/400/300")

' Effect name label
lblEffect# = label#(frmMain#, "Current: BandedSwirl", 20, 350)

' Status label
lblStatus# = label#(frmMain#, "Use Next/Prev to browse effects", 20, 375)

' Progress trackbar
let lblProg# = label#(frmMain#, "Progress:", 20, 410)
trkProgress# = trackbar#(frmMain#, 90, 405, 280, 30)
trackbar_max#(trkProgress#, 100)
trackbar_value#(trkProgress#, 0)
trackbar_onchange#(trkProgress#, "OnProgressChange")

lblProgress# = label#(frmMain#, "0%", 380, 410)

' Navigation buttons
btnPrev# = button#(frmMain#, "< Prev", 20, 450, 80, 35)
button_onclick#(btnPrev#, "OnPrevClick")

btnNext# = button#(frmMain#, "Next >", 110, 450, 80, 35)
button_onclick#(btnNext#, "OnNextClick")

btnAnimate# = button#(frmMain#, "Animate", 200, 450, 80, 35)
button_onclick#(btnAnimate#, "OnAnimateClick")

' Effect list
let lblList# = label#(frmMain#, "Effects: 1.BandedSwirl 2.Blood 3.Blur 4.Bright", 440, 40)
let lblList2# = label#(frmMain#, "5.Crumple 6.Drop 7.Line 8.Magnify 9.Pixelate", 440, 60)
let lblList3# = label#(frmMain#, "10.Ripple 11.RotCrumple 12.Saturate 13.Shape", 440, 80)
let lblList4# = label#(frmMain#, "14.Swirl 15.Water 16.Wave 17.Wiggle", 440, 100)

' Initialize first effect
CreateEffect(0)

form_show(frmMain#)

end

' ============================================================================
' Event Handlers
' ============================================================================

function OnProgressChange(sender#) local val
  val = trackbar_value(trkProgress#)
  label_text#(lblProgress#, stri$(val) + "%")
  UpdateEffectProgress(val / 100)
end function

function OnPrevClick(sender#)
  RemoveCurrentEffect()
  currentIndex = currentIndex - 1
  if currentIndex < 0 then
    currentIndex = effectCount - 1
  end if
  CreateEffect(currentIndex)
  trackbar_value#(trkProgress#, 0)
  label_text#(lblProgress#, "0%")
end function

function OnNextClick(sender#)
  RemoveCurrentEffect()
  currentIndex = currentIndex + 1
  if currentIndex >= effectCount then
    currentIndex = 0
  end if
  CreateEffect(currentIndex)
  trackbar_value#(trkProgress#, 0)
  label_text#(lblProgress#, "0%")
end function

function OnAnimateClick(sender#)
  AnimateTransition()
end function

' ============================================================================
' Helper Functions
' ============================================================================

function GetEffectName$(index) local name$
  if index = 0 then
    name$ = "BandedSwirl"
  end if
  if index = 1 then
    name$ = "Blood"
  end if
  if index = 2 then
    name$ = "Blur"
  end if
  if index = 3 then
    name$ = "Bright"
  end if
  if index = 4 then
    name$ = "Crumple"
  end if
  if index = 5 then
    name$ = "Drop"
  end if
  if index = 6 then
    name$ = "Line"
  end if
  if index = 7 then
    name$ = "Magnify"
  end if
  if index = 8 then
    name$ = "Pixelate"
  end if
  if index = 9 then
    name$ = "Ripple"
  end if
  if index = 10 then
    name$ = "RotateCrumple"
  end if
  if index = 11 then
    name$ = "Saturate"
  end if
  if index = 12 then
    name$ = "Shape"
  end if
  if index = 13 then
    name$ = "Swirl"
  end if
  if index = 14 then
    name$ = "Water"
  end if
  if index = 15 then
    name$ = "Wave"
  end if
  if index = 16 then
    name$ = "Wiggle"
  end if
  return name$
end function

function RemoveCurrentEffect()
  if PntToNum(currentEffect#) = 0 then
    return 0 
  end if
  
  if currentIndex = 0 then
    bandedswirltr_free(currentEffect#)
  end if
  if currentIndex = 1 then
    bloodtrans_free(currentEffect#)
  end if
  if currentIndex = 2 then
    blurtrans_free(currentEffect#)
  end if
  if currentIndex = 3 then
    brighttrans_free(currentEffect#)
  end if
  if currentIndex = 4 then
    crumpletrans_free(currentEffect#)
  end if
  if currentIndex = 5 then
    droptrans_free(currentEffect#)
  end if
  if currentIndex = 6 then
    linetrans_free(currentEffect#)
  end if
  if currentIndex = 7 then
    magnifytrans_free(currentEffect#)
  end if
  if currentIndex = 8 then
    pixelatetrans_free(currentEffect#)
  end if
  if currentIndex = 9 then
    rippletrans_free(currentEffect#)
  end if
  if currentIndex = 10 then
    rotcrumpletrans_free(currentEffect#)
  end if
  if currentIndex = 11 then
    saturatrans_free(currentEffect#)
  end if
  if currentIndex = 12 then
    shapetrans_free(currentEffect#)
  end if
  if currentIndex = 13 then
    swirltrans_free(currentEffect#)
  end if
  if currentIndex = 14 then
    watertrans_free(currentEffect#)
  end if
  if currentIndex = 15 then
    wavetrans_free(currentEffect#)
  end if
  if currentIndex = 16 then
    wiggletrans_free(currentEffect#)
  end if
  
  currentEffect# = Pointer#(0)
end function

function CreateEffect(index)
  label_text#(lblEffect#, "Current: " + GetEffectName$(index))
  label_text#(lblStatus#, "Effect " + stri$(index + 1) + " of " + stri$(effectCount))
  
  if index = 0 then
    CreateBandedSwirl()
  end if
  if index = 1 then
    CreateBlood()
  end if
  if index = 2 then
    CreateBlur()
  end if
  if index = 3 then
    CreateBright()
  end if
  if index = 4 then
    CreateCrumple()
  end if
  if index = 5 then
    CreateDrop()
  end if
  if index = 6 then
    CreateLine()
  end if
  if index = 7 then
    CreateMagnify()
  end if
  if index = 8 then
    CreatePixelate()
  end if
  if index = 9 then
    CreateRipple()
  end if
  if index = 10 then
    CreateRotateCrumple()
  end if
  if index = 11 then
    CreateSaturate()
  end if
  if index = 12 then
    CreateShape()
  end if
  if index = 13 then
    CreateSwirl()
  end if
  if index = 14 then
    CreateWater()
  end if
  if index = 15 then
    CreateWave()
  end if
  if index = 16 then
    CreateWiggle()
  end if
end function

function UpdateEffectProgress(val)
  if PntToNum(currentEffect#) = 0 then
    return 0
  end if
  
  if currentIndex = 0 then
    bandedswirltr_progress#(currentEffect#, val)
  end if
  if currentIndex = 1 then
    bloodtrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 2 then
    blurtrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 3 then
    brighttrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 4 then
    crumpletrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 5 then
    droptrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 6 then
    linetrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 7 then
    magnifytrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 8 then
    pixelatetrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 9 then
    rippletrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 10 then
    rotcrumpletrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 11 then
    saturatrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 12 then
    shapetrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 13 then
    swirltrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 14 then
    watertrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 15 then
    wavetrans_progress#(currentEffect#, val)
  end if
  if currentIndex = 16 then
    wiggletrans_progress#(currentEffect#, val)
  end if
end function

function AnimateTransition() local p
  for p = 0 to 100 step 2
    trackbar_value#(trkProgress#, p)
    label_text#(lblProgress#, stri$(p) + "%")
    UpdateEffectProgress(p / 100)
    pause(0.03)
  next
end function

' ============================================================================
' Effect Creation Functions
' ============================================================================

function CreateBandedSwirl()
  currentEffect# = bandedswirltr#(imgSource#)
  bandedswirltr_loadtarget#(currentEffect#, "https://picsum.photos/id/20/400/300")
  bandedswirltr_strength#(currentEffect#, 1.0)
  bandedswirltr_frequency#(currentEffect#, 20)
end function

function CreateBlood()
  currentEffect# = bloodtrans#(imgSource#)
  bloodtrans_loadtarget#(currentEffect#, "https://picsum.photos/id/25/400/300")
  bloodtrans_randomseed#(currentEffect#, 0.5)
end function

function CreateBlur()
  currentEffect# = blurtrans#(imgSource#)
  blurtrans_loadtarget#(currentEffect#, "https://picsum.photos/id/30/400/300")
end function

function CreateBright()
  currentEffect# = brighttrans#(imgSource#)
  brighttrans_loadtarget#(currentEffect#, "https://picsum.photos/id/35/400/300")
end function

function CreateCrumple()
  currentEffect# = crumpletrans#(imgSource#)
  crumpletrans_loadtarget#(currentEffect#, "https://picsum.photos/id/40/400/300")
  crumpletrans_randomseed#(currentEffect#, 0.5)
end function

function CreateDrop()
  currentEffect# = droptrans#(imgSource#)
  droptrans_loadtarget#(currentEffect#, "https://picsum.photos/id/45/400/300")
  droptrans_randomseed#(currentEffect#, 0.5)
end function

function CreateLine()
  currentEffect# = linetrans#(imgSource#)
  linetrans_loadtarget#(currentEffect#, "https://picsum.photos/id/50/400/300")
  linetrans_fuzzyamount#(currentEffect#, 0.1)
end function

function CreateMagnify()
  currentEffect# = magnifytrans#(imgSource#)
  magnifytrans_loadtarget#(currentEffect#, "https://picsum.photos/id/55/400/300")
  magnifytrans_centerx#(currentEffect#, 0.5)
  magnifytrans_centery#(currentEffect#, 0.5)
end function

function CreatePixelate()
  currentEffect# = pixelatetrans#(imgSource#)
  pixelatetrans_loadtarget#(currentEffect#, "https://picsum.photos/id/60/400/300")
end function

function CreateRipple()
  currentEffect# = rippletrans#(imgSource#)
  rippletrans_loadtarget#(currentEffect#, "https://picsum.photos/id/65/400/300")
end function

function CreateRotateCrumple()
  currentEffect# = rotcrumpletrans#(imgSource#)
  rotcrumpletrans_loadtarget#(currentEffect#, "https://picsum.photos/id/70/400/300")
  rotcrumpletrans_randomseed#(currentEffect#, 0.5)
end function

function CreateSaturate()
  currentEffect# = saturatrans#(imgSource#)
  saturatrans_loadtarget#(currentEffect#, "https://picsum.photos/id/75/400/300")
end function

function CreateShape()
  currentEffect# = shapetrans#(imgSource#)
  shapetrans_loadtarget#(currentEffect#, "https://picsum.photos/id/80/400/300")
  shapetrans_randomseed#(currentEffect#, 0.5)
end function

function CreateSwirl()
  currentEffect# = swirltrans#(imgSource#)
  swirltrans_loadtarget#(currentEffect#, "https://picsum.photos/id/85/400/300")
  swirltrans_strength#(currentEffect#, 1.0)
end function

function CreateWater()
  currentEffect# = watertrans#(imgSource#)
  watertrans_loadtarget#(currentEffect#, "https://picsum.photos/id/90/400/300")
  watertrans_randomseed#(currentEffect#, 0.5)
end function

function CreateWave()
  currentEffect# = wavetrans#(imgSource#)
  wavetrans_loadtarget#(currentEffect#, "https://picsum.photos/id/95/400/300")
end function

function CreateWiggle()
  currentEffect# = wiggletrans#(imgSource#)
  wiggletrans_loadtarget#(currentEffect#, "https://picsum.photos/id/100/400/300")
  wiggletrans_randomseed#(currentEffect#, 0.5)
end function
