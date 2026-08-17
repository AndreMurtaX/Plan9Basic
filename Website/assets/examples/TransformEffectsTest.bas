' ============================================================================
' Transform Effects Test Applet
' Tests: AffineTransform, PerspectiveTransform, Crop, Tiler
' ============================================================================

let frmMain# = Pointer#(0)
let imgSource# = Pointer#(0)
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

' Current effect pointer
let currentEffect# = Pointer#(0)
let currentIndex = 0
let effectCount = 4

' ============================================================================
' Main Program
' ============================================================================

frmMain# = form#("Transform Effects Test", 800, 600)

' Title
let lblTitle# = label#(frmMain#, "Transform Effects Gallery", 20, 10)

' Source image
imgSource# = image#(frmMain#, 20, 40, 400, 300)
image_load#(imgSource#, "https://picsum.photos/id/42/400/300")

' Effect name label
lblEffect# = label#(frmMain#, "Current: Affine Transform", 20, 350)

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
btnPrev# = button#(frmMain#, "< Prev", 20, 555, 80, 30)
button_onclick#(btnPrev#, "OnPrevClick")

btnNext# = button#(frmMain#, "Next >", 110, 555, 80, 30)
button_onclick#(btnNext#, "OnNextClick")

let btnReset# = button#(frmMain#, "Reset", 200, 555, 80, 30)
button_onclick#(btnReset#, "OnResetClick")

' Effect info panel
let lblInfo# = label#(frmMain#, "Transform Effects:", 450, 40)
let lblInfo1# = label#(frmMain#, "1. Affine - Scale, rotate", 460, 70)
let lblInfo2# = label#(frmMain#, "2. Perspective - 3D corner warp", 460, 95)
let lblInfo3# = label#(frmMain#, "3. Crop - Rectangle mask", 460, 120)
let lblInfo4# = label#(frmMain#, "4. Tiler - Tile repetition", 460, 145)

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
  if index = 0 then name$ = "Affine Transform"
  if index = 1 then name$ = "Perspective Transform"
  if index = 2 then name$ = "Crop"
  if index = 3 then name$ = "Tiler"
  return name$
end function

function UpdatePropertyLabels()
  if currentIndex = 0 then
    ' Affine: Rotation, Scale, CenterX, CenterY
    label_text#(lbl1#, "Rotation:")
    label_text#(lbl2#, "Scale:")
    label_text#(lbl3#, "CenterX:")
    label_text#(lbl4#, "CenterY:")
  end if
  if currentIndex = 1 then
    ' Perspective
    label_text#(lbl1#, "TopLeft X:")
    label_text#(lbl2#, "TopRight X:")
    label_text#(lbl3#, "BotLeft X:")
    label_text#(lbl4#, "BotRight X:")
  end if
  if currentIndex = 2 then
    ' Crop
    label_text#(lbl1#, "Left:")
    label_text#(lbl2#, "Top:")
    label_text#(lbl3#, "Right:")
    label_text#(lbl4#, "Bottom:")
  end if
  if currentIndex = 3 then
    ' Tiler
    label_text#(lbl1#, "H Tiles:")
    label_text#(lbl2#, "V Tiles:")
    label_text#(lbl3#, "(unused):")
    label_text#(lbl4#, "(unused):")
  end if
end function

function RemoveCurrentEffect()
  if PntToNum(currentEffect#) = 0 then
    return 0
  end if
  
  if currentIndex = 0 then affine_free(currentEffect#)
  if currentIndex = 1 then persp_free(currentEffect#)
  if currentIndex = 2 then crop_free(currentEffect#)
  if currentIndex = 3 then tiler_free(currentEffect#)
  
  currentEffect# = Pointer#(0)
end function

function CreateEffect(index)
  label_text#(lblEffect#, "Current: " + GetEffectName$(index))
  label_text#(lblStatus#, "Effect " + stri$(index + 1) + " of " + stri$(effectCount))
  
  if index = 0 then CreateAffine()
  if index = 1 then CreatePerspective()
  if index = 2 then CreateCrop()
  if index = 3 then CreateTiler()
end function

' ============================================================================
' Effect Property Updates
' ============================================================================

function UpdateEffect1() local val
  val = trackbar_value(trk1#)
  label_text#(lblVal1#, stri$(val))
  
  if PntToNum(currentEffect#) = 0 then return 0
  
  if currentIndex = 0 then
    ' Affine: Rotation 0-360
    affine_rotation#(currentEffect#, val * 3.6)
  end if
  if currentIndex = 1 then
    ' Perspective: TopLeft X 0-0.5
    persp_topleftx#(currentEffect#, val / 200)
  end if
  if currentIndex = 2 then
    ' Crop: Left 0-0.5
    crop_lefttopx#(currentEffect#, val / 200)
  end if
  if currentIndex = 3 then
    ' Tiler: H Tiles 1-10
    tiler_htiles#(currentEffect#, 1 + val / 10)
  end if
end function

function UpdateEffect2() local val
  val = trackbar_value(trk2#)
  label_text#(lblVal2#, stri$(val))
  
  if PntToNum(currentEffect#) = 0 then return 0
  
  if currentIndex = 0 then
    ' Affine: Scale 0.5-2.0
    affine_scale#(currentEffect#, 0.5 + val / 67)
  end if
  if currentIndex = 1 then
    ' Perspective: TopRight X 0.5-1.0
    persp_toprightx#(currentEffect#, 0.5 + val / 200)
  end if
  if currentIndex = 2 then
    ' Crop: Top 0-0.5
    crop_lefttopy#(currentEffect#, val / 200)
  end if
  if currentIndex = 3 then
    ' Tiler: V Tiles 1-10
    tiler_vtiles#(currentEffect#, 1 + val / 10)
  end if
end function

function UpdateEffect3() local val
  val = trackbar_value(trk3#)
  label_text#(lblVal3#, stri$(val))
  
  if PntToNum(currentEffect#) = 0 then return 0
  
  if currentIndex = 0 then
    ' Affine: CenterX 0-1
    affine_centerx#(currentEffect#, val / 100)
  end if
  if currentIndex = 1 then
    ' Perspective: BottomLeft X 0-0.5
    persp_bottomleftx#(currentEffect#, val / 200)
  end if
  if currentIndex = 2 then
    ' Crop: Right 0.5-1.0
    crop_rightbottomx#(currentEffect#, 0.5 + val / 200)
  end if
  ' Tiler has no property for slider 3
end function

function UpdateEffect4() local val
  val = trackbar_value(trk4#)
  label_text#(lblVal4#, stri$(val))
  
  if PntToNum(currentEffect#) = 0 then return 0
  
  if currentIndex = 0 then
    ' Affine: CenterY 0-1
    affine_centery#(currentEffect#, val / 100)
  end if
  if currentIndex = 1 then
    ' Perspective: BottomRight X 0.5-1.0
    persp_bottomrightx#(currentEffect#, 0.5 + val / 200)
  end if
  if currentIndex = 2 then
    ' Crop: Bottom 0.5-1.0
    crop_rightbottomy#(currentEffect#, 0.5 + val / 200)
  end if
  ' Tiler has no property for slider 4
end function

' ============================================================================
' Effect Creation Functions
' ============================================================================

function CreateAffine()
  currentEffect# = affine#(imgSource#)
  affine_rotation#(currentEffect#, 0)
  affine_scale#(currentEffect#, 1.0)
  affine_centerx#(currentEffect#, 0.5)
  affine_centery#(currentEffect#, 0.5)
end function

function CreatePerspective()
  currentEffect# = persp#(imgSource#)
  persp_topleftx#(currentEffect#, 0)
  persp_toplefty#(currentEffect#, 0)
  persp_toprightx#(currentEffect#, 1)
  persp_toprighty#(currentEffect#, 0)
  persp_bottomleftx#(currentEffect#, 0)
  persp_bottomlefty#(currentEffect#, 1)
  persp_bottomrightx#(currentEffect#, 1)
  persp_bottomrighty#(currentEffect#, 1)
end function

function CreateCrop()
  currentEffect# = crop#(imgSource#)
  crop_lefttopx#(currentEffect#, 0)
  crop_lefttopy#(currentEffect#, 0)
  crop_rightbottomx#(currentEffect#, 1)
  crop_rightbottomy#(currentEffect#, 1)
end function

function CreateTiler()
  currentEffect# = tiler#(imgSource#)
  tiler_htiles#(currentEffect#, 2)
  tiler_vtiles#(currentEffect#, 2)
end function
