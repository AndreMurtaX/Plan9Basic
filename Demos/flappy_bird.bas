' ============================================================
'  FLAPPY BIRD - A Modern Classic
'  Written in Plan9Basic
' ============================================================
'
'  Controls (Desktop):
'    Up Arrow / Space  -  Flap (jump)
'    Up Arrow          -  Start game / Restart
'
'  Controls (Mobile / Touch):
'    Tap anywhere       -  Flap / Start / Restart
'
'  Objective:
'    Fly through the gaps between pipes without hitting them
'    or falling to the ground. How far can you go?
'
' ============================================================

randomize()

' --- Platform Detection ---
let PLATFORM$ = os_name$()
let IS_MOBILE = 0
if (PLATFORM$ = "Android") or (PLATFORM$ = "iOS") then IS_MOBILE = 1
' Also check with instr in case os_name$ returns "Android 14" etc.
if instr(PLATFORM$, "Android") >= 0 or instr(PLATFORM$, "iOS") >= 0 then IS_MOBILE = 1

' --- Game Area Constants ---
let GAME_W = 400
let GAME_H = 600
let GROUND_H = 80

if IS_MOBILE = 1 then
  let GAME_W = form_screenwidth()
  let GAME_H = form_screenheight()
  let GROUND_H = 100
end if

let GROUND_Y = GAME_H - GROUND_H

' --- Bird Constants ---
let BIRD_X = 80
let BIRD_W = 34
let BIRD_H = 24
let GRAVITY = 0.4
let FLAP_POWER = -8
let MAX_FALL = 10

if IS_MOBILE = 1 then
  let BIRD_X = cint(GAME_W * 0.2)
  let BIRD_W = 40
  let BIRD_H = 28
end if

' --- Pipe Constants ---
let PIPE_W = 52
let PIPE_GAP = 150
let PIPE_SPD = 3
let MAX_PIPES = 4
let PIPE_SPAWN_X = GAME_W + 50

if IS_MOBILE = 1 then
  let PIPE_W = 60
  let PIPE_GAP = 180
  let PIPE_SPD = 4
end if

' --- Game State ---
let score = 0
let highScore = 0
let running = 0
let gameOver = 0
let birdY = 250
let birdVel = 0
let pipeTimer = 0
let pipeDelay = 100

' --- Object Pointers ---
let frm# = pointer#(0)
let birdLayout# = pointer#(0)
let birdBody# = pointer#(0)
let birdWing# = pointer#(0)
let birdTail# = pointer#(0)
let birdEye# = pointer#(0)
let birdPupil# = pointer#(0)
let birdBeak# = pointer#(0)
let birdBeakTip# = pointer#(0)
let wingAni# = pointer#(0)
let ground# = pointer#(0)
let groundLine# = pointer#(0)
let sky# = pointer#(0)
let lblScore# = pointer#(0)
let lblHigh# = pointer#(0)
let lblMsg# = pointer#(0)
let tmr# = pointer#(0)
let touchArea# = pointer#(0)

' --- Pipe Arrays ---
let pipeX# = pointer#(0)
let pipeGapY# = pointer#(0)
let pipeActive# = pointer#(0)
let pipeScored# = pointer#(0)
let pipeTop# = pointer#(0)
let pipeBot# = pointer#(0)

' ============================================================
'  CREATE THE GAME WINDOW
' ============================================================

if IS_MOBILE = 1 then
  let frm# = form#("Flappy Bird", GAME_W, GAME_H)
else
  ' Add window frame compensation: ~16px for borders, ~39px for title bar
  let frm# = form#("Flappy Bird", GAME_W + 16, GAME_H + 39)
  form_position#(frm#, 4)
end if
form_fill#(frm#, "#70c5ce")

' --- Sky background ---
let sky# = rectangle#(frm#, 0, 0, GAME_W, GROUND_Y)
rectangle_fill#(sky#, "#70c5ce")
rectangle_strokenone#(sky#)
rectangle_hittest#(sky#, 0)

' --- Ground ---
let ground# = rectangle#(frm#, 0, GROUND_Y, GAME_W, GROUND_H)
rectangle_fill#(ground#, "#ded895")
rectangle_strokenone#(ground#)
rectangle_hittest#(ground#, 0)

' --- Ground top line ---
let groundLine# = rectangle#(frm#, 0, GROUND_Y, GAME_W, 4)
rectangle_fill#(groundLine#, "#54b435")
rectangle_strokenone#(groundLine#)
rectangle_hittest#(groundLine#, 0)

' --- Touch area (transparent, covers entire screen for tap input) ---
let touchArea# = rectangle#(frm#, 0, 0, GAME_W, GAME_H)
rectangle_fill#(touchArea#, "#00000000")
rectangle_strokenone#(touchArea#)
rectangle_hittest#(touchArea#, 1)
rectangle_onmousedown#(touchArea#, "OnTouchDown")

' ============================================================
'  CREATE PIPES
' ============================================================

let pipeX# = dim#(MAX_PIPES)
let pipeGapY# = dim#(MAX_PIPES)
let pipeActive# = dim#(MAX_PIPES)
let pipeScored# = dim#(MAX_PIPES)
let pipeTop# = pdim#(MAX_PIPES)
let pipeBot# = pdim#(MAX_PIPES)

for i = 1 to MAX_PIPES
  pipeActive#[i] = 0
  pipeScored#[i] = 0
  
  ' Top pipe
  let pt# = rectangle#(frm#, 0, 0, PIPE_W, 300)
  rectangle_fill#(pt#, "#73bf2e")
  rectangle_stroke#(pt#, "#54a41e")
  rectangle_strokethickness#(pt#, 3)
  rectangle_corners#(pt#, 4, 4)
  rectangle_hittest#(pt#, 0)
  rectangle_visible#(pt#, 0)
  pipeTop##[i] = pt#
  
  ' Bottom pipe
  let pb# = rectangle#(frm#, 0, 0, PIPE_W, 300)
  rectangle_fill#(pb#, "#73bf2e")
  rectangle_stroke#(pb#, "#54a41e")
  rectangle_strokethickness#(pb#, 3)
  rectangle_corners#(pb#, 4, 4)
  rectangle_hittest#(pb#, 0)
  rectangle_visible#(pb#, 0)
  pipeBot##[i] = pb#
next

' ============================================================
'  CREATE BIRD (multi-part with flapping wing animation)
'  Created after pipes for Z-order
' ============================================================

let birdY = cint(GROUND_Y * 0.45)

' --- Bird part sizes (proportional to BIRD_W/BIRD_H) ---
let WING_W = cint(BIRD_W * 0.55)
let WING_H = cint(BIRD_H * 0.45)
let EYE_SZ = cint(BIRD_H * 0.34)
if EYE_SZ < 8 then EYE_SZ = 8
let PUPIL_SZ = cint(EYE_SZ * 0.5)
if PUPIL_SZ < 4 then PUPIL_SZ = 4
let BEAK_W = cint(BIRD_W * 0.32)
let BEAK_H = cint(BIRD_H * 0.28)
let BEAK_TIP_W = cint(BEAK_W * 0.55)
let BEAK_TIP_H = cint(BEAK_H * 0.7)
let TAIL_W = cint(BIRD_W * 0.22)
let TAIL_H = cint(BIRD_H * 0.35)

' --- Rectangle container (move/rotate this = move/rotate entire bird) ---
let birdLayout# = rectangle#(frm#, BIRD_X, birdY, BIRD_W, BIRD_H)
rectangle_fill#(birdLayout#, "#00000000")
rectangle_strokenone#(birdLayout#)
rectangle_hittest#(birdLayout#, 0)

' --- Tail feathers (behind body, slight rotation) ---
let birdTail# = rectangle#(birdLayout#, 0 - TAIL_W + 4, cint(BIRD_H * 0.25), TAIL_W, TAIL_H)
rectangle_fill#(birdTail#, "#d4950d")
rectangle_strokenone#(birdTail#)
rectangle_corners#(birdTail#, 3, 3)
rectangle_rotation#(birdTail#, -15)
rectangle_hittest#(birdTail#, 0)

' --- Body (main yellow ellipse) ---
let birdBody# = ellipse#(birdLayout#, 0, 0, BIRD_W, BIRD_H)
ellipse_fill#(birdBody#, "#f7dc6f")
ellipse_stroke#(birdBody#, "#d4ac0d")
ellipse_strokethickness#(birdBody#, 2)
ellipse_hittest#(birdBody#, 0)

' --- Wing (animated flapping, sits on top-back of body) ---
let birdWing# = ellipse#(birdLayout#, cint(BIRD_W * 0.08), cint(BIRD_H * 0.05), WING_W, WING_H)
ellipse_fill#(birdWing#, "#e8c84a")
ellipse_stroke#(birdWing#, "#c9a020")
ellipse_strokethickness#(birdWing#, 1)
ellipse_hittest#(birdWing#, 0)

' --- Eye (white circle on right side of body) ---
let birdEye# = ellipse#(birdLayout#, cint(BIRD_W * 0.6), cint(BIRD_H * 0.12), EYE_SZ, EYE_SZ)
ellipse_fill#(birdEye#, "#ffffff")
ellipse_stroke#(birdEye#, "#666666")
ellipse_strokethickness#(birdEye#, 1)
ellipse_hittest#(birdEye#, 0)

' --- Pupil (black dot inside eye) ---
let pupilOff = cint((EYE_SZ - PUPIL_SZ) / 2) + 1
let birdPupil# = ellipse#(birdLayout#, cint(BIRD_W * 0.6) + pupilOff + 1, cint(BIRD_H * 0.12) + pupilOff, PUPIL_SZ, PUPIL_SZ)
ellipse_fill#(birdPupil#, "#000000")
ellipse_strokenone#(birdPupil#)
ellipse_hittest#(birdPupil#, 0)

' --- Beak base (orange, protruding from front of body) ---
let birdBeak# = rectangle#(birdLayout#, BIRD_W - cint(BEAK_W * 0.3), cint(BIRD_H * 0.4), BEAK_W, BEAK_H)
rectangle_fill#(birdBeak#, "#ff6600")
rectangle_strokenone#(birdBeak#)
rectangle_corners#(birdBeak#, 3, 3)
rectangle_hittest#(birdBeak#, 0)

' --- Beak tip (darker orange, smaller) ---
let birdBeakTip# = rectangle#(birdLayout#, BIRD_W + cint(BEAK_W * 0.15), cint(BIRD_H * 0.45), BEAK_TIP_W, BEAK_TIP_H)
rectangle_fill#(birdBeakTip#, "#cc4400")
rectangle_strokenone#(birdBeakTip#)
rectangle_corners#(birdBeakTip#, 2, 2)
rectangle_hittest#(birdBeakTip#, 0)

' --- Wing flapping animation (continuous) ---
let wingAni# = floatani#(birdWing#)
floatani_propertyname#(wingAni#, "RotationAngle")
floatani_startvalue#(wingAni#, -30)
floatani_stopvalue#(wingAni#, 20)
floatani_duration#(wingAni#, 0.15)
floatani_autoreverse#(wingAni#, 1)
floatani_loop#(wingAni#, 1)
floatani_interpolation#(wingAni#, "Sinusoidal")
floatani_animationtype#(wingAni#, "InOut")
floatani_start(wingAni#)

' ============================================================
'  CREATE UI LABELS
' ============================================================

' --- Score (large, centered) ---
let lblScore# = label#(frm#, "0")
label_autosize#(lblScore#, 0)
label_fontsize#(lblScore#, 48)
label_fontcolor#(lblScore#, "#ffffff")
label_bold#(lblScore#, 1)
label_align#(lblScore#, 14)
label_height#(lblScore#, 60)
label_y#(lblScore#, 60)
label_textalign#(lblScore#, 0)
label_visible#(lblScore#, 0)

if IS_MOBILE = 1 then
  label_fontsize#(lblScore#, 56)
  label_y#(lblScore#, 80)
end if

' --- High Score ---
let lblHigh# = label#(frm#, "BEST: 0", 10, 10)
label_autosize#(lblHigh#, 0)
label_fontsize#(lblHigh#, 14)
label_fontcolor#(lblHigh#, "#ffffff")
label_bold#(lblHigh#, 1)
label_size#(lblHigh#, 150, 25)

if IS_MOBILE = 1 then
  label_fontsize#(lblHigh#, 16)
end if

' --- Center message (created LAST for Z-order, on top of everything) ---
let lblMsg# = label#(frm#, "")
label_autosize#(lblMsg#, 0)
label_fontsize#(lblMsg#, 22)
label_fontcolor#(lblMsg#, "#ffffff")
label_bold#(lblMsg#, 1)
label_align#(lblMsg#, 14)
label_height#(lblMsg#, 40)
label_y#(lblMsg#, cint(GROUND_Y * 0.5))
label_textalign#(lblMsg#, 0)

if IS_MOBILE = 1 then
  label_text#(lblMsg#, "Tap to Start")
  label_fontsize#(lblMsg#, 26)
else
  label_text#(lblMsg#, "Press UP to Start")
end if

' ============================================================
'  SETUP TIMER AND EVENTS
' ============================================================

let tmr# = timer#()
timer_interval#(tmr#, 16)
timer_ontimer#(tmr#, "GameLoop")
timer_start#(tmr#)

form_onkeydown#(frm#, "OnKeyDown")
form_show(frm#)

' ============================================================
'  KEYBOARD EVENT HANDLER (Desktop)
' ============================================================

function OnKeyDown(sender#, keyCode, keyChar$)
  ' Up=38, Space detected via keyChar$
  if running = 0 then
    if keyCode = 38 then
      if gameOver = 1 then ResetGame()
      StartGame()
    end if
  else
    ' Flap with Up arrow or Space
    if keyCode = 38 then Flap()
    if keyChar$ = " " then Flap()
  end if
end function

' ============================================================
'  TOUCH EVENT HANDLER (Mobile + Desktop mouse)
' ============================================================

' onmousedown: function(sender#, btn, mx, my, shift$)
function OnTouchDown(sender#, btn, mx, my, shift$)
  if running = 0 then
    if gameOver = 1 then
      ResetGame()
    end if
    StartGame()
  else
    Flap()
  end if
end function

' ============================================================
'  GAME FUNCTIONS
' ============================================================

function ResetGame() local i, pt#, pb#
  let score = 0
  let gameOver = 0
  ' Clear pipes
  for i = 1 to MAX_PIPES
    pipeActive#[i] = 0
    pipeScored#[i] = 0
    pt# = pipeTop##[i]
    pb# = pipeBot##[i]
    rectangle_visible#(pt#, 0)
    rectangle_visible#(pb#, 0)
  next
end function

function StartGame()
  let running = 1
  let birdY = cint(GROUND_Y * 0.45)
  let birdVel = 0
  let pipeTimer = 0
  let pipeDelay = 100
  rectangle_y#(birdLayout#, birdY)
  rectangle_rotation#(birdLayout#, 0)
  label_text#(lblScore#, "0")
  label_visible#(lblScore#, 1)
  label_text#(lblMsg#, "")
  ' Resume wing flapping
  floatani_start(wingAni#)
end function

function Flap()
  let birdVel = FLAP_POWER
end function

function SpawnPipe() local i, gapY, pt#, pb#, topH, botY
  ' Find free pipe slot
  for i = 1 to MAX_PIPES
    if pipeActive#[i] = 0 then
      ' Random gap position
      gapY = 120 + rnd() * (GROUND_Y - PIPE_GAP - 180)
      pipeX#[i] = PIPE_SPAWN_X
      pipeGapY#[i] = gapY
      pipeActive#[i] = 1
      pipeScored#[i] = 0
      
      ' Position top pipe
      topH = gapY
      pt# = pipeTop##[i]
      rectangle_bounds#(pt#, PIPE_SPAWN_X, 0, PIPE_W, topH)
      rectangle_visible#(pt#, 1)
      
      ' Position bottom pipe
      botY = gapY + PIPE_GAP
      pb# = pipeBot##[i]
      rectangle_bounds#(pb#, PIPE_SPAWN_X, botY, PIPE_W, GROUND_Y - botY)
      rectangle_visible#(pb#, 1)
      
      return 0
    end if
  next
end function

function GameOver()
  let running = 0
  let gameOver = 1
  ' Stop wing flapping and tilt bird nose-down
  floatani_stopatcurrent(wingAni#)
  rectangle_rotation#(birdLayout#, 45)
  if score > highScore then
    let highScore = score
    label_text#(lblHigh#, "BEST: " + stri$(highScore))
  end if
  label_visible#(lblScore#, 0)
  if IS_MOBILE = 1 then
    label_text#(lblMsg#, "Score: " + stri$(score) + " - Tap to Retry")
  else
    label_text#(lblMsg#, "GAME OVER! Score: " + stri$(score))
  end if
end function

' ============================================================
'  MAIN GAME LOOP
' ============================================================

function GameLoop(sender#) local i, px, gapY, pt#, pb#, topH, botY, birdTop, birdBot, birdRight, tilt
  if running = 0 then return 0
  
  ' ========================
  '  UPDATE BIRD
  ' ========================
  let birdVel = birdVel + GRAVITY
  if birdVel > MAX_FALL then birdVel = MAX_FALL
  let birdY = birdY + birdVel
  
  ' Check ceiling
  if birdY < 0 then
    let birdY = 0
    let birdVel = 0
  end if
  
  ' Check ground collision
  if birdY + BIRD_H >= GROUND_Y then
    let birdY = GROUND_Y - BIRD_H
    GameOver()
    return 0
  end if
  
  ' Move bird container (all parts follow)
  rectangle_y#(birdLayout#, birdY)
  
  ' Tilt entire bird based on velocity: nose up when flapping, nose down when falling
  tilt = birdVel * 4
  if tilt < -25 then tilt = -25
  if tilt > 60 then tilt = 60
  rectangle_rotation#(birdLayout#, tilt)
  
  ' ========================
  '  SPAWN PIPES
  ' ========================
  pipeTimer = pipeTimer + 1
  if pipeTimer >= pipeDelay then
    pipeTimer = 0
    SpawnPipe()
  end if
  
  ' ========================
  '  UPDATE PIPES
  ' ========================
  birdTop = birdY
  birdBot = birdY + BIRD_H
  birdRight = BIRD_X + BIRD_W
  
  for i = 1 to MAX_PIPES
    if pipeActive#[i] = 1 then
      px = pipeX#[i] - PIPE_SPD
      pipeX#[i] = px
      gapY = pipeGapY#[i]
      
      pt# = pipeTop##[i]
      pb# = pipeBot##[i]
      
      ' Move pipes
      rectangle_x#(pt#, px)
      rectangle_x#(pb#, px)
      
      ' Check if off screen
      if px + PIPE_W < 0 then
        pipeActive#[i] = 0
        rectangle_visible#(pt#, 0)
        rectangle_visible#(pb#, 0)
      else
        ' Check collision with bird
        if birdRight > px then
          if BIRD_X < px + PIPE_W then
            ' Bird is horizontally within pipe
            ' Check top pipe collision
            if birdTop < gapY then
              GameOver()
              return 0
            end if
            ' Check bottom pipe collision
            if birdBot > gapY + PIPE_GAP then
              GameOver()
              return 0
            end if
          end if
        end if
        
        ' Check if passed pipe (score)
        if pipeScored#[i] = 0 then
          if BIRD_X > px + PIPE_W then
            pipeScored#[i] = 1
            let score = score + 1
            label_text#(lblScore#, stri$(score))
          end if
        end if
      end if
    end if
  next
end function
