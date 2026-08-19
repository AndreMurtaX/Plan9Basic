' ============================================================
'  WHACK-A-MOLE - A Classic Arcade Game
'  Written in Plan9Basic
' ============================================================
'
'  Controls (Desktop):
'    Mouse Click  -  Whack the mole!
'    Up Arrow     -  Start game / Restart
'
'  Controls (Mobile / Touch):
'    Tap          -  Whack / Start / Restart
'
'  Scoring:
'    Regular mole (brown) =  10 points
'    Golden mole  (gold)  =  25 points
'    Miss penalty          =  -2 points
'
'  Objective:
'    Click/tap on moles when they pop up from their holes.
'    Golden moles are rare and worth more - don't miss them!
'    You have 30 seconds. Get the highest score!
'
' ============================================================

randomize()

' --- Platform Detection ---
let PLATFORM$ = os_name$()
let IS_MOBILE = 0
if PLATFORM$ = "Android" or PLATFORM$ = "iOS" then IS_MOBILE = 1
if instr(PLATFORM$, "Android") >= 0 or instr(PLATFORM$, "iOS") >= 0 then IS_MOBILE = 1

' --- Game Area Constants ---
let GAME_W = 600
let GAME_H = 520
let TOP_BAR = 50

if IS_MOBILE = 1 then
  let GAME_W = form_screenwidth()
  let GAME_H = form_screenheight()
  let TOP_BAR = 55
end if

' --- Grid Constants ---
let GRID_COLS = 3
let GRID_ROWS = 3
let TOTAL_HOLES = GRID_COLS * GRID_ROWS
let HOLE_W = 120
let HOLE_H = 70
let MOLE_W = 80
let MOLE_H = 55

if IS_MOBILE = 1 then
  let HOLE_W = cint(GAME_W / 3.8)
  let HOLE_H = cint(HOLE_W * 0.58)
  let MOLE_W = cint(HOLE_W * 0.67)
  let MOLE_H = cint(HOLE_H * 0.78)
end if

' --- Mole Face Part Sizes ---
let EYE_W = cint(MOLE_W * 0.2)
if EYE_W < 8 then EYE_W = 8
let EYE_H = cint(MOLE_H * 0.22)
if EYE_H < 8 then EYE_H = 8
let NOSE_W = cint(MOLE_W * 0.18)
if NOSE_W < 6 then NOSE_W = 6
let NOSE_H = cint(MOLE_H * 0.16)
if NOSE_H < 6 then NOSE_H = 6

' --- Timing Constants ---
let GAME_TIME = 30
let MOLE_UP_MIN = 80
let MOLE_UP_MAX = 160
let WHACK_FLASH = 12
let GOLDEN_CHANCE = 15

' --- Game State ---
let score = 0
let highScore = 0
let timeLeft = 30
let running = 0
let gameOver = 0
let spawnTimer = 0
let spawnDelay = 55
let molesWhacked = 0
let popupTimer = 0
let popupY = 0

' --- Object Pointers ---
let frm# = pointer#(0)
let topBar# = pointer#(0)
let gameArea# = pointer#(0)
let lblScore# = pointer#(0)
let lblHigh# = pointer#(0)
let lblTime# = pointer#(0)
let lblMsg# = pointer#(0)
let lblMsg2# = pointer#(0)
let lblPopup# = pointer#(0)
let tmr# = pointer#(0)
let secTimer# = pointer#(0)

' --- Hole Arrays ---
let holeX# = pointer#(0)
let holeY# = pointer#(0)
let holeRect# = pointer#(0)
let moundRect# = pointer#(0)

' --- Mole Arrays ---
' moleState: 0=hidden, 1=up(normal), 2=up(golden), 3=whacked(flashing)
let moleState# = pointer#(0)
let moleTimer# = pointer#(0)
let moleBody# = pointer#(0)
let moleEyeL# = pointer#(0)
let moleEyeR# = pointer#(0)
let moleNose# = pointer#(0)

' ============================================================
'  CREATE THE GAME WINDOW
' ============================================================

if IS_MOBILE = 1 then
  let frm# = form#("Whack-a-Mole", GAME_W, GAME_H)
else
  ' Window frame compensation: ~16px borders, ~39px title bar
  let frm# = form#("Whack-a-Mole", GAME_W + 16, GAME_H + 39)
  form_position#(frm#, 4)
end if
form_fill#(frm#, "#4a8c38")

' --- Top bar background ---
let topBar# = rectangle#(frm#, 0, 0, GAME_W, TOP_BAR)
rectangle_fill#(topBar#, "#2d5a1e")
rectangle_strokenone#(topBar#)
rectangle_hittest#(topBar#, 0)

' --- Clickable game area (covers play area) ---
let gameArea# = rectangle#(frm#, 0, TOP_BAR, GAME_W, GAME_H - TOP_BAR)
rectangle_fill#(gameArea#, "#4a8c38")
rectangle_strokenone#(gameArea#)
rectangle_hittest#(gameArea#, 1)
rectangle_onmousedown#(gameArea#, "OnGameClick")

' ============================================================
'  CREATE HOLES AND MOLES
' ============================================================

let holeX# = dim#(TOTAL_HOLES)
let holeY# = dim#(TOTAL_HOLES)
let holeRect# = pdim#(TOTAL_HOLES)
let moundRect# = pdim#(TOTAL_HOLES)
let moleState# = dim#(TOTAL_HOLES)
let moleTimer# = dim#(TOTAL_HOLES)
let moleBody# = pdim#(TOTAL_HOLES)
let moleEyeL# = pdim#(TOTAL_HOLES)
let moleEyeR# = pdim#(TOTAL_HOLES)
let moleNose# = pdim#(TOTAL_HOLES)

' Calculate grid spacing
let holeGapX = cint((GAME_W - GRID_COLS * HOLE_W) / (GRID_COLS + 1))
let holeGapY = cint(HOLE_H * 0.9)
let startX = holeGapX
' Center grid vertically in play area
let gridTotalH = GRID_ROWS * (HOLE_H + holeGapY) - holeGapY
let startY = TOP_BAR + cint((GAME_H - TOP_BAR - gridTotalH) / 2)

for row = 0 to GRID_ROWS - 1
  for col = 0 to GRID_COLS - 1
    let idx = row * GRID_COLS + col + 1
    let hx = startX + col * (HOLE_W + holeGapX)
    let hy = startY + row * (HOLE_H + holeGapY)

    holeX#[idx] = hx
    holeY#[idx] = hy
    moleState#[idx] = 0
    moleTimer#[idx] = 0

    ' --- Mound rim (behind everything, gives ground depth) ---
    let mnd# = ellipse#(frm#, hx - 10, hy + cint(HOLE_H * 0.25), HOLE_W + 20, cint(HOLE_H * 0.85))
    ellipse_fill#(mnd#, "#5a7d3a")
    ellipse_strokenone#(mnd#)
    ellipse_hittest#(mnd#, 0)
    moundRect##[idx] = mnd#

    ' --- Mole body (rounded rectangle, hidden initially) ---
    let mx = hx + cint((HOLE_W - MOLE_W) / 2)
    let my = hy - cint(MOLE_H * 0.35)
    let mb# = rectangle#(frm#, mx, my, MOLE_W, MOLE_H)
    rectangle_fill#(mb#, "#8B6914")
    rectangle_strokenone#(mb#)
    rectangle_corners#(mb#, cint(MOLE_W * 0.3), cint(MOLE_H * 0.3))
    rectangle_hittest#(mb#, 0)
    rectangle_visible#(mb#, 0)
    moleBody##[idx] = mb#

    ' --- Left eye (white ellipse, hidden) ---
    let elx = mx + cint(MOLE_W * 0.24) - EYE_W / 2
    let ely = my + cint(MOLE_H * 0.2)
    let el# = ellipse#(frm#, elx, ely, EYE_W, EYE_H)
    ellipse_fill#(el#, "#ffffff")
    ellipse_stroke#(el#, "#333333")
    ellipse_strokethickness#(el#, 1)
    ellipse_hittest#(el#, 0)
    ellipse_visible#(el#, 0)
    moleEyeL##[idx] = el#

    ' --- Right eye (white ellipse, hidden) ---
    let erx = mx + cint(MOLE_W * 0.76) - EYE_W / 2
    let er# = ellipse#(frm#, erx, ely, EYE_W, EYE_H)
    ellipse_fill#(er#, "#ffffff")
    ellipse_stroke#(er#, "#333333")
    ellipse_strokethickness#(er#, 1)
    ellipse_hittest#(er#, 0)
    ellipse_visible#(er#, 0)
    moleEyeR##[idx] = er#

    ' --- Nose (pink/red ellipse, hidden) ---
    let nx = mx + cint(MOLE_W / 2) - NOSE_W / 2
    let ny = my + cint(MOLE_H * 0.55)
    let ns# = ellipse#(frm#, nx, ny, NOSE_W, NOSE_H)
    ellipse_fill#(ns#, "#ff7788")
    ellipse_strokenone#(ns#)
    ellipse_hittest#(ns#, 0)
    ellipse_visible#(ns#, 0)
    moleNose##[idx] = ns#

    ' --- Hole (dark ellipse - ON TOP of mole for "emerging" look) ---
    let hole# = ellipse#(frm#, hx, hy + cint(HOLE_H * 0.3), HOLE_W, cint(HOLE_H * 0.7))
    ellipse_fill#(hole#, "#2a1a0a")
    ellipse_stroke#(hole#, "#1a0f05")
    ellipse_strokethickness#(hole#, 3)
    ellipse_hittest#(hole#, 0)
    holeRect##[idx] = hole#
  next
next

' ============================================================
'  CREATE UI LABELS
' ============================================================

' --- Score label ---
let lblScore# = label#(frm#, "SCORE: 0", 15, 12)
label_autosize#(lblScore#, 0)
label_fontsize#(lblScore#, 18)
label_fontcolor#(lblScore#, "#ffffff")
label_bold#(lblScore#, 1)
label_size#(lblScore#, 180, 30)

' --- High Score label ---
let lblHigh# = label#(frm#, "BEST: 0")
label_autosize#(lblHigh#, 0)
label_move#(lblHigh#, GAME_W / 2 - 60, 12)
label_fontsize#(lblHigh#, 18)
label_fontcolor#(lblHigh#, "#ffff00")
label_bold#(lblHigh#, 1)
label_size#(lblHigh#, 150, 30)

' --- Time label ---
let lblTime# = label#(frm#, "TIME: 30")
label_autosize#(lblTime#, 0)
label_move#(lblTime#, GAME_W - 140, 12)
label_fontsize#(lblTime#, 18)
label_fontcolor#(lblTime#, "#ff4444")
label_bold#(lblTime#, 1)
label_size#(lblTime#, 130, 30)
label_textalign#(lblTime#, 2)

if IS_MOBILE = 1 then
  label_fontsize#(lblScore#, 17)
  label_fontsize#(lblHigh#, 17)
  label_fontsize#(lblTime#, 17)
end if

' --- Score popup (floats at hit location, e.g. "+10", "+25") ---
let lblPopup# = label#(frm#, "")
label_autosize#(lblPopup#, 0)
label_fontsize#(lblPopup#, 22)
label_fontcolor#(lblPopup#, "#ffffff")
label_bold#(lblPopup#, 1)
label_size#(lblPopup#, 80, 30)
label_textalign#(lblPopup#, 0)
label_visible#(lblPopup#, 0)

' --- Center message line 1 (created LAST for Z-order) ---
let lblMsg# = label#(frm#, "")
label_autosize#(lblMsg#, 0)
label_fontsize#(lblMsg#, 26)
label_fontcolor#(lblMsg#, "#ffffff")
label_bold#(lblMsg#, 1)
label_align#(lblMsg#, 14)
label_height#(lblMsg#, 40)
label_y#(lblMsg#, cint(GAME_H / 2 - 20))
label_textalign#(lblMsg#, 0)

' --- Center message line 2 (instruction) ---
let lblMsg2# = label#(frm#, "")
label_autosize#(lblMsg2#, 0)
label_fontsize#(lblMsg2#, 20)
label_fontcolor#(lblMsg2#, "#ffffff")
label_bold#(lblMsg2#, 1)
label_align#(lblMsg2#, 14)
label_height#(lblMsg2#, 36)
label_y#(lblMsg2#, cint(GAME_H / 2 + 20))
label_textalign#(lblMsg2#, 0)

if IS_MOBILE = 1 then
  label_text#(lblMsg#, "Tap to Start!")
  label_fontsize#(lblMsg#, 28)
else
  label_text#(lblMsg#, "Press UP to Start!")
end if

' ============================================================
'  SETUP TIMERS AND EVENTS
' ============================================================

' Game loop timer (~60 FPS)
let tmr# = timer#()
timer_interval#(tmr#, 16)
timer_ontimer#(tmr#, "GameLoop")
timer_start#(tmr#)

' Second timer for countdown
let secTimer# = timer#()
timer_interval#(secTimer#, 1000)
timer_ontimer#(secTimer#, "OnSecond")

form_onkeydown#(frm#, "OnKeyDown")
form_show(frm#)

' ============================================================
'  EVENT HANDLERS
' ============================================================

function OnKeyDown(sender#, keyCode, keyChar$, shiftState$)
  if keyCode = 38 then
    if running = 0 then
      if gameOver = 1 then
        ResetGame()
      end if
      StartGame()
    end if
  end if
end function

' onmousedown: function(sender#, btn, mx, my, shift$)
function OnGameClick(sender#, btn, mx, my, shift$) local i, hx, hy, hitTop, moleHit
  ' Tap/click to start or restart when not running
  if running = 0 then
    if gameOver = 1 then
      ResetGame()
    end if
    StartGame()
    return 0
  end if

  moleHit = 0

  ' Check if clicked on any visible mole
  ' Generous hit area: full hole width, from mole top to hole bottom
  for i = 1 to TOTAL_HOLES
    if moleState#[i] = 1 or moleState#[i] = 2 then
      hx = holeX#[i]
      hy = holeY#[i]
      hitTop = hy - cint(MOLE_H * 0.35) - 5

      if mx >= hx - 10 then
        if mx <= hx + HOLE_W + 10 then
          if my >= hitTop then
            if my <= hy + HOLE_H + 10 then
              ' Hit!
              WhackMole(i)
              moleHit = 1
            end if
          end if
        end if
      end if
    end if
  next

  ' Small penalty for missing (reduced from -5 to -2)
  if moleHit = 0 then
    let score = score - 2
    if score < 0 then
      let score = 0
    end if
    label_text#(lblScore#, "SCORE: " + stri$(score))
  end if
end function

function OnSecond(sender#)
  if running = 0 then
    return 0
  end if

  let timeLeft = timeLeft - 1
  label_text#(lblTime#, "TIME: " + stri$(timeLeft))

  ' Flash time red when running low
  if timeLeft <= 5 then
    label_fontcolor#(lblTime#, "#ff0000")
  end if

  if timeLeft <= 0 then
    EndGame()
  end if
end function

' ============================================================
'  MOLE VISUAL HELPERS
' ============================================================

function ShowMoleParts(idx) local mb#, el#, er#, ns#
  mb# = moleBody##[idx]
  el# = moleEyeL##[idx]
  er# = moleEyeR##[idx]
  ns# = moleNose##[idx]
  rectangle_visible#(mb#, 1)
  ellipse_visible#(el#, 1)
  ellipse_visible#(er#, 1)
  ellipse_visible#(ns#, 1)
end function

function HideMoleParts(idx) local mb#, el#, er#, ns#
  mb# = moleBody##[idx]
  el# = moleEyeL##[idx]
  er# = moleEyeR##[idx]
  ns# = moleNose##[idx]
  rectangle_visible#(mb#, 0)
  ellipse_visible#(el#, 0)
  ellipse_visible#(er#, 0)
  ellipse_visible#(ns#, 0)
end function

function SetMoleNormal(idx) local mb#, el#, er#, ns#
  ' Brown mole with white eyes and pink nose
  mb# = moleBody##[idx]
  el# = moleEyeL##[idx]
  er# = moleEyeR##[idx]
  ns# = moleNose##[idx]
  rectangle_fill#(mb#, "#8B6914")
  ellipse_fill#(el#, "#ffffff")
  ellipse_stroke#(el#, "#333333")
  ellipse_fill#(er#, "#ffffff")
  ellipse_stroke#(er#, "#333333")
  ellipse_fill#(ns#, "#ff7788")
end function

function SetMoleGolden(idx) local mb#, el#, er#, ns#
  ' Gold mole with white eyes and orange nose
  mb# = moleBody##[idx]
  el# = moleEyeL##[idx]
  er# = moleEyeR##[idx]
  ns# = moleNose##[idx]
  rectangle_fill#(mb#, "#FFD700")
  ellipse_fill#(el#, "#ffffff")
  ellipse_stroke#(el#, "#996600")
  ellipse_fill#(er#, "#ffffff")
  ellipse_stroke#(er#, "#996600")
  ellipse_fill#(ns#, "#ff6600")
end function

function SetMoleWhacked(idx) local mb#, el#, er#, ns#
  ' Whacked: body turns red, eyes go red, nose goes dark
  mb# = moleBody##[idx]
  el# = moleEyeL##[idx]
  er# = moleEyeR##[idx]
  ns# = moleNose##[idx]
  rectangle_fill#(mb#, "#cc2200")
  ellipse_fill#(el#, "#ff6666")
  ellipse_stroke#(el#, "#990000")
  ellipse_fill#(er#, "#ff6666")
  ellipse_stroke#(er#, "#990000")
  ellipse_fill#(ns#, "#aa0000")
end function

' ============================================================
'  GAME FUNCTIONS
' ============================================================

function ResetGame() local i
  let score = 0
  let gameOver = 0
  let molesWhacked = 0
  label_text#(lblScore#, "SCORE: 0")
  label_fontcolor#(lblTime#, "#ff4444")
  ' Hide all moles
  for i = 1 to TOTAL_HOLES
    moleState#[i] = 0
    moleTimer#[i] = 0
    HideMoleParts(i)
  next
  label_visible#(lblPopup#, 0)
end function

function StartGame()
  let running = 1
  let timeLeft = GAME_TIME
  let spawnTimer = 0
  let spawnDelay = 55
  label_text#(lblTime#, "TIME: " + stri$(timeLeft))
  label_fontcolor#(lblTime#, "#ff4444")
  label_text#(lblMsg#, "")
  label_text#(lblMsg2#, "")
  label_fontcolor#(lblMsg#, "#ffffff")
  label_fontcolor#(lblMsg2#, "#ffffff")
  timer_start#(secTimer#)
end function

function EndGame() local i
  let running = 0
  let gameOver = 1
  timer_stop#(secTimer#)
  label_visible#(lblPopup#, 0)

  ' Hide any remaining moles
  for i = 1 to TOTAL_HOLES
    if moleState#[i] > 0 then
      moleState#[i] = 0
      moleTimer#[i] = 0
      HideMoleParts(i)
    end if
  next

  if score > highScore then
    let highScore = score
    label_text#(lblHigh#, "BEST: " + stri$(highScore))
  end if

  label_text#(lblMsg#, "TIME UP!  Score: " + stri$(score))
  label_fontcolor#(lblMsg#, "#ffff00")
  if IS_MOBILE = 1 then
    label_text#(lblMsg2#, "Tap to Play Again")
  else
    label_text#(lblMsg2#, "Press UP to Play Again")
  end if
  label_fontcolor#(lblMsg2#, "#ffff00")
end function

function WhackMole(idx) local pts, hx, hy
  pts = 10
  if moleState#[idx] = 2 then
    pts = 25
  end if

  let score = score + pts
  let molesWhacked = molesWhacked + 1
  label_text#(lblScore#, "SCORE: " + stri$(score))

  ' Visual feedback: turn mole red briefly
  moleState#[idx] = 3
  moleTimer#[idx] = WHACK_FLASH
  SetMoleWhacked(idx)

  ' Show floating score popup at hit location
  hx = holeX#[idx]
  hy = holeY#[idx]
  let popupY = hy - cint(MOLE_H * 0.6)
  label_text#(lblPopup#, "+" + stri$(pts))
  label_move#(lblPopup#, hx + cint(HOLE_W / 2) - 25, popupY)
  label_visible#(lblPopup#, 1)
  if pts = 25 then
    label_fontcolor#(lblPopup#, "#FFD700")
    label_fontsize#(lblPopup#, 26)
  else
    label_fontcolor#(lblPopup#, "#ffffff")
    label_fontsize#(lblPopup#, 22)
  end if
  let popupTimer = 25
end function

function SpawnMole() local idx, attempts, isGolden, upTime
  ' Try to find an empty hole
  attempts = 0
  while attempts < 15
    idx = 1 + cint(rnd() * TOTAL_HOLES)
    if idx > TOTAL_HOLES then idx = TOTAL_HOLES
    if moleState#[idx] = 0 then
      ' Determine type: golden (15% chance) or normal
      isGolden = 0
      if cint(rnd() * 100) < GOLDEN_CHANCE then
        isGolden = 1
      end if

      if isGolden = 1 then
        moleState#[idx] = 2
        SetMoleGolden(idx)
      else
        moleState#[idx] = 1
        SetMoleNormal(idx)
      end if

      ' Moles stay up longer at start, shorter as time runs out
      upTime = MOLE_UP_MAX - (GAME_TIME - timeLeft) * 3
      if upTime < MOLE_UP_MIN then upTime = MOLE_UP_MIN
      moleTimer#[idx] = upTime + cint(rnd() * 30)

      ShowMoleParts(idx)
      return 0
    end if
    attempts = attempts + 1
  end while
end function

function HideMole(idx)
  moleState#[idx] = 0
  moleTimer#[idx] = 0
  HideMoleParts(idx)
end function

' ============================================================
'  MAIN GAME LOOP
' ============================================================

function GameLoop(sender#) local i
  if running = 0 then
    return 0
  end if

  ' ========================
  '  SPAWN MOLES
  ' ========================
  spawnTimer = spawnTimer + 1
  if spawnTimer >= spawnDelay then
    spawnTimer = 0
    SpawnMole()
    ' Gradually speed up spawning
    let spawnDelay = spawnDelay - 1
    if spawnDelay < 28 then
      let spawnDelay = 28
    end if
  end if

  ' ========================
  '  UPDATE MOLES
  ' ========================
  for i = 1 to TOTAL_HOLES
    if moleState#[i] > 0 then
      moleTimer#[i] = moleTimer#[i] - 1
      if moleTimer#[i] <= 0 then
        HideMole(i)
      end if
    end if
  next

  ' ========================
  '  UPDATE POPUP
  ' ========================
  if popupTimer > 0 then
    let popupTimer = popupTimer - 1
    let popupY = popupY - 1
    label_y#(lblPopup#, popupY)
    if popupTimer = 0 then
      label_visible#(lblPopup#, 0)
    end if
  end if

end function
