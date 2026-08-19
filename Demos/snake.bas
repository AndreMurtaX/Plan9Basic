' ============================================================
'  SNAKE - A Classic Arcade Game
'  Written in Plan9Basic
' ============================================================
'
'  Controls (Desktop):
'    Arrow Keys  -  Change direction
'    Up Arrow    -  Start game / Restart (when not running)
'
'  Controls (Mobile / Touch):
'    Swipe       -  Change direction (swipe on play area)
'    D-Pad       -  Change direction (arrow buttons)
'    Tap         -  Start / Restart (when not running)
'
'  Objective:
'    Eat the red food to grow longer and score points.
'    Don't hit the walls or your own tail!
'
' ============================================================
randomize()
' --- Platform Detection ---
let PLATFORM$ = os_name$()
let IS_MOBILE = 0
if PLATFORM$ = "Android" or PLATFORM$ = "iOS" then IS_MOBILE = 1
if instr(PLATFORM$, "Android") >= 0 or instr(PLATFORM$, "iOS") >= 0 then IS_MOBILE = 1
' --- Audio Format Detection ---
'     Windows → WAV  (Win32 native, hardware-accelerated)
'     Linux   → OGG  (GStreamer native, open-source royalty-free)
'     Android → OGG  (Google-recommended for mobile game audio)
'     macOS   → MP3  (CoreAudio universal support)
'     iOS     → MP3  (AVFoundation universal support)
let SOUND_BASE$ = "https://plan9basic.com/assets/sounds/snake/"
let SOUND_EXT$ = "mp3"
if instr(PLATFORM$, "Windows") >= 0 then SOUND_EXT$ = "wav"
if instr(PLATFORM$, "Linux") >= 0 then SOUND_EXT$ = "ogg"
if instr(PLATFORM$, "Android") >= 0 then SOUND_EXT$ = "ogg"
' --- Label Text Alignment Constants ---
let TEXT_ALIGN_CENTER = 0
let TEXT_ALIGN_LEADING = 1
let TEXT_ALIGN_TRAILING = 2
' --- Initial Window Size ---
let GAME_W = 640
let GAME_H = 480
let TOP_BAR = 40
let CTRL_H = 0
' --- Platform Dependent Values ---
if IS_MOBILE = 1 then
  let GAME_W = form_screenwidth()
  let GAME_H = form_screenheight()
  let TOP_BAR = 50
  let CTRL_H = 180
end if
' --- Snake Constants ---
let MAX_LENGTH = 600
let START_LENGTH = 4
let BASE_SPEED = 8
' --- Game State ---
let score = 0
let highScore = 0
let running = 0
let gameOver = 0
let snakeLen = 0
let headX = 0
let headY = 0
let dirX = 1
let dirY = 0
let nextDirX = 1
let nextDirY = 0
let foodX = 0
let foodY = 0
let moveTimer = 0
let moveDelay = 8
' --- Touch Swipe State ---
let touchStartX = 0
let touchStartY = 0
let touchActive = 0
let SWIPE_THRESHOLD = 20
' --- Object Pointers ---
let frm# = pointer#(0)
let lblScore# = pointer#(0)
let lblHigh# = pointer#(0)
let lblMsg# = pointer#(0)
let food# = pointer#(0)
let tmr# = pointer#(0)
' --- Sound Players ---
let sndEat#   = pointer#(0)
let sndDie#   = pointer#(0)
let sndStart# = pointer#(0)
let soundInitDone = 0  ' set to 1 after InitSounds() on first GameLoop tick
let border# = pointer#(0)
let touchArea# = pointer#(0)
let btnUp# = pointer#(0)
let btnDown# = pointer#(0)
let btnLeft# = pointer#(0)
let btnRight# = pointer#(0)
let lblUp# = pointer#(0)
let lblDown# = pointer#(0)
let lblLeft# = pointer#(0)
let lblRight# = pointer#(0)
' --- Snake Body Arrays ---
let snakeX# = pointer#(0)
let snakeY# = pointer#(0)
let snakeRect# = pointer#(0)
' ============================================================
'  CREATE THE GAME WINDOW (before layout calculation)
' ============================================================
if IS_MOBILE = 1 then
  let frm# = form#("Snake", GAME_W, GAME_H)
else
  ' Add window frame compensation: ~16px for borders, ~39px for title bar
  let frm# = form#("Snake", GAME_W + 16, GAME_H + 39)
  form_position#(frm#, 4)
end if
form_fill#(frm#, "#1a1a2e")
' ============================================================
'  CALCULATE GRID LAYOUT
' ============================================================
let CELL_SIZE = 20
let GRID_W = 30
let GRID_H = 20
let GRID_OFF_X = 20
let GRID_OFF_Y = 50
if IS_MOBILE = 1 then
  ' Calculate cell size to fill available width
  let PLAY_H = GAME_H - TOP_BAR - CTRL_H - 20
  let CELL_SIZE = cint(GAME_W / 22)
  if CELL_SIZE < 16 then CELL_SIZE = 16
  let GRID_W = cint((GAME_W - 20) / CELL_SIZE)
  let GRID_H = cint(PLAY_H / CELL_SIZE)
  ' Center the grid horizontally
  let GRID_OFF_X = cint((GAME_W - GRID_W * CELL_SIZE) / 2)
  let GRID_OFF_Y = TOP_BAR + 5
else
  ' Desktop: with frame compensation, GAME_W/GAME_H is the full client area
  let GRID_H = 20
  let GRID_W = 30
  ' Center the grid horizontally
  let GRID_OFF_X = cint((GAME_W - GRID_W * CELL_SIZE) / 2)
end if
' ============================================================
'  CREATE VISUAL ELEMENTS
' ============================================================
' --- Game border (created first so it's behind everything) ---
let border# = rectangle#(frm#, GRID_OFF_X - 2, GRID_OFF_Y - 2, GRID_W * CELL_SIZE + 4, GRID_H * CELL_SIZE + 4)
rectangle_fill#(border#, "#0f0f23")
rectangle_stroke#(border#, "#4444aa")
rectangle_strokethickness#(border#, 2)
rectangle_hittest#(border#, 0)
' --- Touch area (transparent, covers play area for swipe detection) ---
let touchArea# = rectangle#(frm#, 0, 0, GAME_W, GAME_H - CTRL_H)
rectangle_fill#(touchArea#, "#00000000")
rectangle_strokenone#(touchArea#)
rectangle_hittest#(touchArea#, 1)
rectangle_onmousedown#(touchArea#, "OnTouchDown")
rectangle_onmousemove#(touchArea#, "OnTouchMove")
' --- Score label ---
let lblScore# = label#(frm#, "SCORE: 0", 15, 10)
label_autosize#(lblScore#, 0)
label_fontsize#(lblScore#, 16)
label_fontcolor#(lblScore#, "#00ff00")
label_bold#(lblScore#, 1)
label_size#(lblScore#, 180, 25)
' --- High Score label ---
let lblHigh# = label#(frm#, "HIGH: 0")
label_autosize#(lblHigh#, 0)
label_move#(lblHigh#, GAME_W - 150, 10)
label_fontsize#(lblHigh#, 16)
label_fontcolor#(lblHigh#, "#ffff00")
label_bold#(lblHigh#, 1)
label_size#(lblHigh#, 140, 25)
label_textalign#(lblHigh#, 2)
if IS_MOBILE = 1 then
  label_fontsize#(lblScore#, 17)
  label_fontsize#(lblHigh#, 17)
end if
' --- Food ---
let food# = rectangle#(frm#, 0, 0, CELL_SIZE - 2, CELL_SIZE - 2)
rectangle_fill#(food#, "#ff4444")
rectangle_strokenone#(food#)
rectangle_corners#(food#, 4, 4)
rectangle_hittest#(food#, 0)
rectangle_visible#(food#, 0)
' ============================================================
'  CREATE D-PAD (Mobile only)
' ============================================================
if IS_MOBILE = 1 then
  ' D-Pad layout: centered at bottom, cross pattern
  '        [UP]
  '  [LEFT][  ][RIGHT]
  '       [DOWN]
  let dpadTop = GAME_H - CTRL_H + 5
  let btnSize = cint(CTRL_H / 3) - 4
  let dpadCenterX = cint(GAME_W / 2)
  let dpadCenterY = dpadTop + cint(CTRL_H / 2) - 5
  ' UP button
  let btnUp# = rectangle#(frm#, dpadCenterX - btnSize / 2, dpadCenterY - btnSize - btnSize / 2 - 4, btnSize, btnSize)
  rectangle_fill#(btnUp#, "#1a3a5a")
  rectangle_stroke#(btnUp#, "#3388cc")
  rectangle_strokethickness#(btnUp#, 2)
  rectangle_corners#(btnUp#, 6, 6)
  rectangle_hittest#(btnUp#, 1)
  rectangle_onmousedown#(btnUp#, "OnBtnUpDown")
  rectangle_onmouseup#(btnUp#, "OnBtnUpUp")
  let lblUp# = label#(frm#, "^")
  label_autosize#(lblUp#, 0)
  label_move#(lblUp#, dpadCenterX - btnSize / 2, dpadCenterY - btnSize - btnSize / 2 - 4)
  label_size#(lblUp#, btnSize, btnSize)
  label_fontsize#(lblUp#, 28)
  label_fontcolor#(lblUp#, "#44aaff")
  label_bold#(lblUp#, 1)
  label_textalign#(lblUp#, 0)
  label_vertalign#(lblUp#, 0)
  label_hittest#(lblUp#, 0)
  ' DOWN button
  let btnDown# = rectangle#(frm#, dpadCenterX - btnSize / 2, dpadCenterY + btnSize / 2 + 4, btnSize, btnSize)
  rectangle_fill#(btnDown#, "#1a3a5a")
  rectangle_stroke#(btnDown#, "#3388cc")
  rectangle_strokethickness#(btnDown#, 2)
  rectangle_corners#(btnDown#, 6, 6)
  rectangle_hittest#(btnDown#, 1)
  rectangle_onmousedown#(btnDown#, "OnBtnDownDown")
  rectangle_onmouseup#(btnDown#, "OnBtnDownUp")
  let lblDown# = label#(frm#, "v")
  label_autosize#(lblDown#, 0)
  label_move#(lblDown#, dpadCenterX - btnSize / 2, dpadCenterY + btnSize / 2 + 4)
  label_size#(lblDown#, btnSize, btnSize)
  label_fontsize#(lblDown#, 28)
  label_fontcolor#(lblDown#, "#44aaff")
  label_bold#(lblDown#, 1)
  label_textalign#(lblDown#, 0)
  label_vertalign#(lblDown#, 0)
  label_hittest#(lblDown#, 0)
  ' LEFT button
  let btnLeft# = rectangle#(frm#, dpadCenterX - btnSize - btnSize / 2 - 4, dpadCenterY - btnSize / 2, btnSize, btnSize)
  rectangle_fill#(btnLeft#, "#1a3a5a")
  rectangle_stroke#(btnLeft#, "#3388cc")
  rectangle_strokethickness#(btnLeft#, 2)
  rectangle_corners#(btnLeft#, 6, 6)
  rectangle_hittest#(btnLeft#, 1)
  rectangle_onmousedown#(btnLeft#, "OnBtnLeftDown")
  rectangle_onmouseup#(btnLeft#, "OnBtnLeftUp")
  let lblLeft# = label#(frm#, "<")
  label_autosize#(lblLeft#, 0)
  label_move#(lblLeft#, dpadCenterX - btnSize - btnSize / 2 - 4, dpadCenterY - btnSize / 2)
  label_size#(lblLeft#, btnSize, btnSize)
  label_fontsize#(lblLeft#, 28)
  label_fontcolor#(lblLeft#, "#44aaff")
  label_bold#(lblLeft#, 1)
  label_textalign#(lblLeft#, 0)
  label_vertalign#(lblLeft#, 0)
  label_hittest#(lblLeft#, 0)
  ' RIGHT button
  let btnRight# = rectangle#(frm#, dpadCenterX + btnSize / 2 + 4, dpadCenterY - btnSize / 2, btnSize, btnSize)
  rectangle_fill#(btnRight#, "#1a3a5a")
  rectangle_stroke#(btnRight#, "#3388cc")
  rectangle_strokethickness#(btnRight#, 2)
  rectangle_corners#(btnRight#, 6, 6)
  rectangle_hittest#(btnRight#, 1)
  rectangle_onmousedown#(btnRight#, "OnBtnRightDown")
  rectangle_onmouseup#(btnRight#, "OnBtnRightUp")
  let lblRight# = label#(frm#, ">")
  label_autosize#(lblRight#, 0)
  label_move#(lblRight#, dpadCenterX + btnSize / 2 + 4, dpadCenterY - btnSize / 2)
  label_size#(lblRight#, btnSize, btnSize)
  label_fontsize#(lblRight#, 28)
  label_fontcolor#(lblRight#, "#44aaff")
  label_bold#(lblRight#, 1)
  label_textalign#(lblRight#, 0)
  label_vertalign#(lblRight#, 0)
  label_hittest#(lblRight#, 0)
end if
' ============================================================
'  CREATE SNAKE SEGMENTS
' ============================================================
let snakeX# = dim#(MAX_LENGTH)
let snakeY# = dim#(MAX_LENGTH)
let snakeRect# = pdim#(MAX_LENGTH)
for i = 1 to MAX_LENGTH
  snakeX#[i] = 0
  snakeY#[i] = 0
  let seg# = rectangle#(frm#, 0, 0, CELL_SIZE - 2, CELL_SIZE - 2)
  rectangle_fill#(seg#, "#00ff00")
  rectangle_strokenone#(seg#)
  rectangle_corners#(seg#, 3, 3)
  rectangle_hittest#(seg#, 0)
  rectangle_visible#(seg#, 0)
  snakeRect##[i] = seg#
next
' --- Center message (created LAST for Z-order, on top of everything) ---
let lblMsg# = label#(frm#, "")
label_autosize#(lblMsg#, 0)
label_fontsize#(lblMsg#, 24)
label_fontcolor#(lblMsg#, "#ffffff")
label_bold#(lblMsg#, 1)
label_align#(lblMsg#, 14)
label_height#(lblMsg#, 40)
label_y#(lblMsg#, cint(GRID_OFF_Y + GRID_H * CELL_SIZE / 2 - 20))
label_textalign#(lblMsg#, TEXT_ALIGN_CENTER)
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
function OnKeyDown(sender#, keyCode, keyChar$, shiftState$)
  ' Arrow keys: Up=38, Down=40, Left=37, Right=39
  if running = 1 then
    ' Prevent 180-degree turns
    if keyCode = 38 then
      if dirY = 0 then
        let nextDirX = 0
        let nextDirY = -1
      end if
    end if
    if keyCode = 40 then
      if dirY = 0 then
        let nextDirX = 0
        let nextDirY = 1
      end if
    end if
    if keyCode = 37 then
      if dirX = 0 then
        let nextDirX = -1
        let nextDirY = 0
      end if
    end if
    if keyCode = 39 then
      if dirX = 0 then
        let nextDirX = 1
        let nextDirY = 0
      end if
    end if
  else
    ' Start game with Up arrow
    if keyCode = 38 then
      if gameOver = 1 then
        ResetGame()
      end if
      StartGame()
    end if
  end if
end function
' ============================================================
'  TOUCH / SWIPE EVENT HANDLERS
' ============================================================
' onmousedown: function(sender#, btn, mx, my, shift$)
function OnTouchDown(sender#, btn, mx, my, shift$)
  if running = 0 then
    if gameOver = 1 then
      ResetGame()
    end if
    StartGame()
    return 0
  end if
  ' Record swipe start position
  let touchStartX = mx
  let touchStartY = my
  let touchActive = 1
end function
' onmousemove: function(sender#, mx, my, shift$)
function OnTouchMove(sender#, mx, my, shift$) local dx, dy, adx, ady
  if touchActive = 0 then return 0
  if running = 0 then return 0
  dx = mx - touchStartX
  dy = my - touchStartY
  adx = abs(dx)
  ady = abs(dy)
  ' Only process if swipe exceeds threshold
  if adx < SWIPE_THRESHOLD then
    if ady < SWIPE_THRESHOLD then return 0
  end if
  ' Determine swipe direction (largest axis wins)
  if adx > ady then
    ' Horizontal swipe
    if dx > 0 then
      ' Swipe right - prevent 180 turn
      if dirX = 0 then
        let nextDirX = 1
        let nextDirY = 0
      end if
    else
      ' Swipe left
      if dirX = 0 then
        let nextDirX = -1
        let nextDirY = 0
      end if
    end if
  else
    ' Vertical swipe
    if dy > 0 then
      ' Swipe down
      if dirY = 0 then
        let nextDirX = 0
        let nextDirY = 1
      end if
    else
      ' Swipe up
      if dirY = 0 then
        let nextDirX = 0
        let nextDirY = -1
      end if
    end if
  end if
  ' Reset start for continuous swiping
  let touchStartX = mx
  let touchStartY = my
end function
' ============================================================
'  D-PAD BUTTON HANDLERS (Mobile only)
' ============================================================
' onmousedown: function(sender#, btn, mx, my, shift$)
function OnBtnUpDown(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnUp#, "#2a5a8a")
  if running = 0 then
    if gameOver = 1 then ResetGame()
    StartGame()
    return 0
  end if
  if dirY = 0 then
    let nextDirX = 0
    let nextDirY = -1
  end if
end function
' onmouseup: function(sender#, btn, mx, my, shift$)
function OnBtnUpUp(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnUp#, "#1a3a5a")
end function
function OnBtnDownDown(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnDown#, "#2a5a8a")
  if running = 0 then
    if gameOver = 1 then ResetGame()
    StartGame()
    return 0
  end if
  if dirY = 0 then
    let nextDirX = 0
    let nextDirY = 1
  end if
end function
function OnBtnDownUp(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnDown#, "#1a3a5a")
end function
function OnBtnLeftDown(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnLeft#, "#2a5a8a")
  if running = 0 then
    if gameOver = 1 then ResetGame()
    StartGame()
    return 0
  end if
  if dirX = 0 then
    let nextDirX = -1
    let nextDirY = 0
  end if
end function
function OnBtnLeftUp(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnLeft#, "#1a3a5a")
end function
function OnBtnRightDown(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnRight#, "#2a5a8a")
  if running = 0 then
    if gameOver = 1 then ResetGame()
    StartGame()
    return 0
  end if
  if dirX = 0 then
    let nextDirX = 1
    let nextDirY = 0
  end if
end function
function OnBtnRightUp(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnRight#, "#1a3a5a")
end function
' ============================================================
'  GAME FUNCTIONS
' ============================================================
function ResetGame()
  let score = 0
  let gameOver = 0
  label_text#(lblScore#, "SCORE: 0")
end function
function StartGame() local i, seg#
  let running = 1
  let snakeLen = START_LENGTH
  let dirX = 1
  let dirY = 0
  let nextDirX = 1
  let nextDirY = 0
  let moveTimer = 0
  let moveDelay = BASE_SPEED
  let touchActive = 0
  ' Position snake in center (cint ensures integer grid coords)
  let headX = cint(GRID_W / 2)
  let headY = cint(GRID_H / 2)
  for i = 1 to snakeLen
    snakeX#[i] = headX - i + 1
    snakeY#[i] = headY
    seg# = snakeRect##[i]
    rectangle_move#(seg#, GRID_OFF_X + snakeX#[i] * CELL_SIZE + 1, GRID_OFF_Y + snakeY#[i] * CELL_SIZE + 1)
    rectangle_visible#(seg#, 1)
    ' Head is brighter
    if i = 1 then
      rectangle_fill#(seg#, "#44ff44")
    else
      rectangle_fill#(seg#, "#00cc00")
    end if
  next
  ' Hide unused segments
  for i = snakeLen + 1 to MAX_LENGTH
    seg# = snakeRect##[i]
    rectangle_visible#(seg#, 0)
  next
  SpawnFood()
  label_text#(lblMsg#, "")
  ' Sound: game start jingle
  if soundInitDone = 1 then
    media_stop(sndStart#)
    media_play(sndStart#)
  end if
end function
function SpawnFood() local fx, fy, valid, i
  ' Find a spot not occupied by snake
  valid = 0
  while valid = 0
    fx = cint(rnd() * (GRID_W - 1))
    fy = cint(rnd() * (GRID_H - 1))
    valid = 1
    for i = 1 to snakeLen
      if snakeX#[i] = fx then
        if snakeY#[i] = fy then valid = 0
      end if
    next
  end while
  let foodX = fx
  let foodY = fy
  rectangle_move#(food#, GRID_OFF_X + fx * CELL_SIZE + 1, GRID_OFF_Y + fy * CELL_SIZE + 1)
  rectangle_visible#(food#, 1)
end function
function MoveSnake() local i, newX, newY, seg#, ate
  ' Apply direction change
  let dirX = nextDirX
  let dirY = nextDirY
  ' Calculate new head position
  newX = snakeX#[1] + dirX
  newY = snakeY#[1] + dirY
  ' Check wall collision
  if newX < 0 then
    GameOver()
    return 0
  end if
  if newX >= GRID_W then
    GameOver()
    return 0
  end if
  if newY < 0 then
    GameOver()
    return 0
  end if
  if newY >= GRID_H then
    GameOver()
    return 0
  end if
  ' Check self collision
  for i = 1 to snakeLen
    if snakeX#[i] = newX then
      if snakeY#[i] = newY then
        GameOver()
        return 0
      end if
    end if
  next
  ' Check food collision
  ate = 0
  if newX = foodX then
    if newY = foodY then
      ate = 1
      let score = score + 10
      label_text#(lblScore#, "SCORE: " + stri$(score))
      if score > highScore then
        let highScore = score
        label_text#(lblHigh#, "HIGH: " + stri$(highScore))
      end if
      ' Speed up slightly
      let moveDelay = moveDelay - 0.2
      if moveDelay < 3 then moveDelay = 3
    end if
  end if
  ' Move body (shift all segments)
  if ate = 1 then
    ' Grow: add new segment
    let snakeLen = snakeLen + 1
    if snakeLen > MAX_LENGTH then snakeLen = MAX_LENGTH
  end if
  ' Shift body backwards
  for i = snakeLen to 2 step -1
    snakeX#[i] = snakeX#[i - 1]
    snakeY#[i] = snakeY#[i - 1]
  next
  ' Set new head position
  snakeX#[1] = newX
  snakeY#[1] = newY
  ' Update visuals
  for i = 1 to snakeLen
    seg# = snakeRect##[i]
    rectangle_move#(seg#, GRID_OFF_X + snakeX#[i] * CELL_SIZE + 1, GRID_OFF_Y + snakeY#[i] * CELL_SIZE + 1)
    rectangle_visible#(seg#, 1)
    if i = 1 then
      rectangle_fill#(seg#, "#44ff44")
    else
      rectangle_fill#(seg#, "#00cc00")
    end if
  next
  ' Spawn new food if eaten
  if ate = 1 then
    SpawnFood()
    ' Sound: food eaten
    media_stop(sndEat#)
    media_play(sndEat#)
  end if
end function
function GameOver() local i, seg#
  let running = 0
  let gameOver = 1
  let touchActive = 0
  ' Turn snake red
  for i = 1 to snakeLen
    seg# = snakeRect##[i]
    rectangle_fill#(seg#, "#ff4444")
  next
  ' Sound: collision / death
  media_stop(sndDie#)
  media_play(sndDie#)
  if IS_MOBILE = 1 then
    label_text#(lblMsg#, "GAME OVER! Tap to Retry")
  else
    label_text#(lblMsg#, "GAME OVER! Press UP")
  end if
end function
' ============================================================
'  SOUND FUNCTIONS
' ============================================================
'
'  Required audio files at https://plan9basic.com/assets/sounds/snake/ :
'    eat.wav  / eat.mp3  / eat.ogg   (~0.1s chomp / pop)
'    die.wav  / die.mp3  / die.ogg   (~0.5s crunch / collision thud)
'    start.wav / start.mp3 / start.ogg (~0.4s short start jingle)

function InitSounds()
  sndEat# = media_player#()
  media_load#(sndEat#, SOUND_BASE$ + "eat." + SOUND_EXT$)
  media_volume#(sndEat#, 0.80)

  sndDie# = media_player#()
  media_load#(sndDie#, SOUND_BASE$ + "die." + SOUND_EXT$)
  media_volume#(sndDie#, 0.90)

  sndStart# = media_player#()
  media_load#(sndStart#, SOUND_BASE$ + "start." + SOUND_EXT$)
  media_volume#(sndStart#, 0.75)
end function

' ============================================================
'  MAIN GAME LOOP
' ============================================================
function GameLoop(sender#)
  ' On the very first tick the Android event loop (Looper) is guaranteed to be
  ' running, which is required for TMediaPlayer to work correctly on Android.
  if soundInitDone = 0 then
    let soundInitDone = 1
    InitSounds()
    return 0
  end if
  if running = 0 then
    return 0
  end if
  moveTimer = moveTimer + 1
  if moveTimer >= moveDelay then
    moveTimer = 0
    MoveSnake()
  end if
end function
