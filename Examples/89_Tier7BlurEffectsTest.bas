' ============================================================================
' Tier 7 Blur Effects Test Applet
' Tests: BoxBlur, GaussianBlur, DirectionalBlur, RadialBlur
' ============================================================================

let frmMain# = Pointer#(0)
let imgSource# = Pointer#(0)
let lblStatus# = Pointer#(0)
let lblEffect# = Pointer#(0)
let btnPrev# = Pointer#(0)
let btnNext# = Pointer#(0)
let btnAnimate# = Pointer#(0)
let trkAmount# = Pointer#(0)
let lblAmount# = Pointer#(0)

' Current effect pointer
let currentEffect# = Pointer#(0)
let currentIndex = 0
let effectCount = 4

' ============================================================================
' Main Program
' ============================================================================

frmMain# = form#("Tier 7 Blur Effects Test", 700, 500)

' Title
let lblTitle# = label#(frmMain#, "Tier 7 Blur Effects Gallery", 20, 10)

' Source image
imgSource# = image#(frmMain#, 20, 40, 400, 300)
image_load#(imgSource#, "https://picsum.photos/id/15/400/300")

' Effect name label
lblEffect# = label#(frmMain#, "Current: BoxBlur", 20, 350)

' Status label
lblStatus# = label#(frmMain#, "Use Next/Prev to browse effects", 20, 375)

' Amount trackbar
let lblAmt# = label#(frmMain#, "Blur Amount:", 20, 410)
trkAmount# = trackbar#(frmMain#, 120, 405, 250, 30)
trackbar_max#(trkAmount#, 100)
trackbar_value#(trkAmount#, 20)
trackbar_onchange#(trkAmount#, "OnAmountChange")

lblAmount# = label#(frmMain#, "2.0", 380, 410)

' Navigation buttons
btnPrev# = button#(frmMain#, "< Prev", 20, 450, 80, 35)
button_onclick#(btnPrev#, "OnPrevClick")

btnNext# = button#(frmMain#, "Next >", 110, 450, 80, 35)
button_onclick#(btnNext#, "OnNextClick")

btnAnimate# = button#(frmMain#, "Animate", 200, 450, 80, 35)
button_onclick#(btnAnimate#, "OnAnimateClick")

' Effect list
let lblList# = label#(frmMain#, "Blur Effects:", 440, 40)
let lblList1# = label#(frmMain#, "1. BoxBlur - Fast box averaging", 450, 70)
let lblList2# = label#(frmMain#, "2. GaussianBlur - Smooth blur", 450, 95)
let lblList3# = label#(frmMain#, "3. DirectionalBlur - Motion blur", 450, 120)
let lblList4# = label#(frmMain#, "4. RadialBlur - Zoom/spin blur", 450, 145)

' Property info
let lblProps# = label#(frmMain#, "Properties:", 440, 190)
let lblInfo1# = label#(frmMain#, "- BlurAmount (all effects)", 450, 215)
let lblInfo2# = label#(frmMain#, "- Angle (DirectionalBlur only)", 450, 240)
let lblInfo3# = label#(frmMain#, "- CenterX/Y (RadialBlur only)", 450, 265)

' Initialize first effect
CreateEffect(0)

form_show(frmMain#)

end

' ============================================================================
' Event Handlers
' ============================================================================

function OnAmountChange(sender#) local val
  val = trackbar_value(trkAmount#) / 10
  label_text#(lblAmount#, stri$(val))
  UpdateEffectAmount(val)
end function

function OnPrevClick(sender#)
  RemoveCurrentEffect()
  currentIndex = currentIndex - 1
  if currentIndex < 0 then
    currentIndex = effectCount - 1
  end if
  CreateEffect(currentIndex)
  trackbar_value#(trkAmount#, 20)
  label_text#(lblAmount#, "2.0")
end function

function OnNextClick(sender#)
  RemoveCurrentEffect()
  currentIndex = currentIndex + 1
  if currentIndex >= effectCount then
    currentIndex = 0
  end if
  CreateEffect(currentIndex)
  trackbar_value#(trkAmount#, 20)
  label_text#(lblAmount#, "2.0")
end function

function OnAnimateClick(sender#)
  AnimateBlur()
end function

' ============================================================================
' Helper Functions
' ============================================================================

function GetEffectName$(index) local name$
  if index = 0 then
    name$ = "BoxBlur"
  end if
  if index = 1 then
    name$ = "GaussianBlur"
  end if
  if index = 2 then
    name$ = "DirectionalBlur"
  end if
  if index = 3 then
    name$ = "RadialBlur"
  end if
  return name$
end function

function RemoveCurrentEffect()
  if PntToNum(currentEffect#) = 0 then
    return 0
  end if
  
  if currentIndex = 0 then
    boxblur_free(currentEffect#)
  end if
  if currentIndex = 1 then
    gaussblur_free(currentEffect#)
  end if
  if currentIndex = 2 then
    dirblur_free(currentEffect#)
  end if
  if currentIndex = 3 then
    radblur_free(currentEffect#)
  end if
  
  currentEffect# = Pointer#(0)
end function

function CreateEffect(index)
  label_text#(lblEffect#, "Current: " + GetEffectName$(index))
  label_text#(lblStatus#, "Effect " + stri$(index + 1) + " of " + stri$(effectCount))
  
  if index = 0 then
    CreateBoxBlur()
  end if
  if index = 1 then
    CreateGaussianBlur()
  end if
  if index = 2 then
    CreateDirectionalBlur()
  end if
  if index = 3 then
    CreateRadialBlur()
  end if
end function

function UpdateEffectAmount(val)
  if PntToNum(currentEffect#) = 0 then
    return 0
  end if
  
  if currentIndex = 0 then
    boxblur_bluramount#(currentEffect#, val)
  end if
  if currentIndex = 1 then
    gaussblur_bluramount#(currentEffect#, val)
  end if
  if currentIndex = 2 then
    dirblur_bluramount#(currentEffect#, val)
  end if
  if currentIndex = 3 then
    radblur_bluramount#(currentEffect#, val)
  end if
end function

function AnimateBlur() local p
  for p = 0 to 100 step 5
    trackbar_value#(trkAmount#, p)
    label_text#(lblAmount#, stri$(p / 10))
    UpdateEffectAmount(p / 10)
    pause(0.05)
  next
  for p = 100 to 0 step -5
    trackbar_value#(trkAmount#, p)
    label_text#(lblAmount#, stri$(p / 10))
    UpdateEffectAmount(p / 10)
    pause(0.05)
  next
end function

' ============================================================================
' Effect Creation Functions
' ============================================================================

function CreateBoxBlur()
  currentEffect# = boxblur#(imgSource#)
  boxblur_bluramount#(currentEffect#, 2.0)
end function

function CreateGaussianBlur()
  currentEffect# = gaussblur#(imgSource#)
  gaussblur_bluramount#(currentEffect#, 2.0)
end function

function CreateDirectionalBlur()
  currentEffect# = dirblur#(imgSource#)
  dirblur_bluramount#(currentEffect#, 2.0)
  dirblur_angle#(currentEffect#, 45)
end function

function CreateRadialBlur()
  currentEffect# = radblur#(imgSource#)
  radblur_bluramount#(currentEffect#, 20)
  radblur_centerx#(currentEffect#, 0.5)
  radblur_centery#(currentEffect#, 0.5)
end function
