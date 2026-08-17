' ============================================================
'  ASTEROIDS - A Classic Arcade Game
'  Written in Plan9Basic
' ============================================================
'
'  Controls (Desktop):
'    Left / Right  -  Rotate ship
'    Up Arrow      -  Thrust forward
'    Down Arrow    -  Fire / Start game
'
'  Controls (Mobile / Touch):
'    D-Pad Left/Right  -  Rotate ship
'    D-Pad Up          -  Thrust forward
'    D-Pad Down        -  Fire / Start game
'    Tap play area     -  Start / Restart (when not running)
'
'  Scoring:
'    Large asteroid  = 20 points
'    Medium asteroid = 50 points
'    Small asteroid  = 100 points
'
'  Objective:
'    Destroy all asteroids without getting hit!
'    Large asteroids split into medium, medium into small.
'
' ============================================================

randomize()

' --- Platform Detection ---
let PLATFORM$ = os_name$()
let IS_MOBILE = 0
if PLATFORM$ = "Android" or PLATFORM$ = "iOS" then IS_MOBILE = 1
if instr(PLATFORM$, "Android") > 0 or instr(PLATFORM$, "iOS") > 0 then IS_MOBILE = 1

' --- Game Area Constants ---
let GAME_W = 800
let GAME_H = 600
let TOP_BAR = 35
let CTRL_H = 0
let PI = 3.14159265

if IS_MOBILE = 1 then
  let GAME_W = form_screenwidth()
  let GAME_H = form_screenheight()
  let TOP_BAR = 45
  let CTRL_H = 180
end if

' PLAY_H = vertical play area (excludes D-pad on mobile)
let PLAY_H = GAME_H - CTRL_H

' --- Ship Constants ---
let SHIP_SIZE = 15
let ROTATE_SPD = 5
let THRUST = 0.15
let FRICTION = 0.99
let MAX_VEL = 6

' --- Bullet Constants ---
let MAX_BULLETS = 8
let BULLET_SPD = 8
let BULLET_LIFE = 60

' --- Asteroid Constants ---
let MAX_ASTEROIDS = 24
let AST_LARGE = 35
let AST_MEDIUM = 20
let AST_SMALL = 10

if IS_MOBILE = 1 then
  ' Scale sizes for mobile screens
  let AST_LARGE = cint(GAME_W * 0.05)
  if AST_LARGE < 25 then AST_LARGE = 25
  let AST_MEDIUM = cint(AST_LARGE * 0.57)
  let AST_SMALL = cint(AST_LARGE * 0.29)
  let SHIP_SIZE = cint(GAME_W * 0.025)
  if SHIP_SIZE < 12 then SHIP_SIZE = 12
end if

' --- Game State ---
let score = 0
let lives = 3
let wave = 0
let running = 0
let gameOver = 0
let shipX = GAME_W / 2
let shipY = PLAY_H / 2
let shipAngle = 270
let shipVX = 0
let shipVY = 0
let rotateL = 0
let rotateR = 0
let thrusting = 0
let asteroidsLeft = 0
let respawnTimer = 0
let respawnDelay = 90
let invincible = 0
let invincibleTimer = 0

' --- Touch State ---
let touchStartX = 0
let touchStartY = 0
let touchActive = 0

' --- Object Pointers ---
let frm# = pointer#(0)
let lblScore# = pointer#(0)
let lblLives# = pointer#(0)
let lblWave# = pointer#(0)
let lblMsg# = pointer#(0)
let tmr# = pointer#(0)
let touchArea# = pointer#(0)

' --- D-Pad Pointers (Mobile) ---
let btnUp# = pointer#(0)
let btnDown# = pointer#(0)
let btnLeft# = pointer#(0)
let btnRight# = pointer#(0)
let lblUp# = pointer#(0)
let lblDown# = pointer#(0)
let lblLeft# = pointer#(0)
let lblRight# = pointer#(0)

' --- Ship visual ---
let shipLine1# = pointer#(0)
let shipLine2# = pointer#(0)
let shipLine3# = pointer#(0)

' --- Bullet Arrays ---
let bulX# = pointer#(0)
let bulY# = pointer#(0)
let bulVX# = pointer#(0)
let bulVY# = pointer#(0)
let bulLife# = pointer#(0)
let bulActive# = pointer#(0)
let bulRect# = pointer#(0)

' --- Asteroid Arrays ---
let astX# = pointer#(0)
let astY# = pointer#(0)
let astVX# = pointer#(0)
let astVY# = pointer#(0)
let astSize# = pointer#(0)
let astActive# = pointer#(0)
let astRect# = pointer#(0)

' ============================================================
'  CREATE THE GAME WINDOW
' ============================================================

if IS_MOBILE = 1 then
  let frm# = form#("Asteroids", GAME_W, GAME_H)
else
  let frm# = form#("Asteroids", GAME_W, GAME_H)
  form_position#(frm#, 4)
end if
form_fill#(frm#, "#000000")

' --- Score label ---
let lblScore# = label#(frm#, "SCORE: 0", 15, 10)
label_autosize#(lblScore#, 0)
label_fontsize#(lblScore#, 16)
label_fontcolor#(lblScore#, "#ffffff")
label_bold#(lblScore#, 1)
label_size#(lblScore#, 200, 25)

' --- Lives label ---
let lblLives# = label#(frm#, "LIVES: 3")
label_autosize#(lblLives#, 0)
label_move#(lblLives#, cint(GAME_W / 2 - 60), 10)
label_fontsize#(lblLives#, 16)
label_fontcolor#(lblLives#, "#00ff00")
label_bold#(lblLives#, 1)
label_size#(lblLives#, 120, 25)
label_textalign#(lblLives#, 0)

' --- Wave label ---
let lblWave# = label#(frm#, "WAVE: 1")
label_autosize#(lblWave#, 0)
label_move#(lblWave#, GAME_W - 160, 10)
label_fontsize#(lblWave#, 16)
label_fontcolor#(lblWave#, "#ffff00")
label_bold#(lblWave#, 1)
label_size#(lblWave#, 120, 25)
label_textalign#(lblWave#, 2)

if IS_MOBILE = 1 then
  label_fontsize#(lblScore#, 17)
  label_fontsize#(lblLives#, 17)
  label_fontsize#(lblWave#, 17)
end if

' --- Touch area (transparent, covers play area for tap detection) ---
let touchArea# = rectangle#(frm#, 0, 0, GAME_W, PLAY_H)
rectangle_fill#(touchArea#, "#00000000")
rectangle_strokenone#(touchArea#)
rectangle_hittest#(touchArea#, 1)
rectangle_onmousedown#(touchArea#, "OnTouchDown")

' ============================================================
'  CREATE SHIP (represented as a filled circle + direction dot)
' ============================================================

' Ship body
let shipLine1# = rectangle#(frm#, 400, 300, SHIP_SIZE * 2, SHIP_SIZE * 2)
rectangle_fill#(shipLine1#, "#00ffff")
rectangle_strokenone#(shipLine1#)
rectangle_corners#(shipLine1#, SHIP_SIZE, SHIP_SIZE)
rectangle_hittest#(shipLine1#, 0)
rectangle_visible#(shipLine1#, 0)

' Direction indicator
let shipLine2# = rectangle#(frm#, 400, 300, 8, 8)
rectangle_fill#(shipLine2#, "#ffffff")
rectangle_strokenone#(shipLine2#)
rectangle_corners#(shipLine2#, 4, 4)
rectangle_hittest#(shipLine2#, 0)
rectangle_visible#(shipLine2#, 0)

' Thrust indicator
let shipLine3# = rectangle#(frm#, 400, 300, 6, 6)
rectangle_fill#(shipLine3#, "#ff8800")
rectangle_strokenone#(shipLine3#)
rectangle_corners#(shipLine3#, 3, 3)
rectangle_hittest#(shipLine3#, 0)
rectangle_visible#(shipLine3#, 0)

' ============================================================
'  CREATE BULLETS
' ============================================================

let bulX# = dim#(MAX_BULLETS)
let bulY# = dim#(MAX_BULLETS)
let bulVX# = dim#(MAX_BULLETS)
let bulVY# = dim#(MAX_BULLETS)
let bulLife# = dim#(MAX_BULLETS)
let bulActive# = dim#(MAX_BULLETS)
let bulRect# = pdim#(MAX_BULLETS)

for i = 1 to MAX_BULLETS
  bulActive#[i] = 0
  let b# = rectangle#(frm#, 0, 0, 4, 4)
  rectangle_fill#(b#, "#ffffff")
  rectangle_strokenone#(b#)
  rectangle_corners#(b#, 2, 2)
  rectangle_hittest#(b#, 0)
  rectangle_visible#(b#, 0)
  bulRect##[i] = b#
next

' ============================================================
'  CREATE ASTEROIDS
' ============================================================

let astX# = dim#(MAX_ASTEROIDS)
let astY# = dim#(MAX_ASTEROIDS)
let astVX# = dim#(MAX_ASTEROIDS)
let astVY# = dim#(MAX_ASTEROIDS)
let astSize# = dim#(MAX_ASTEROIDS)
let astActive# = dim#(MAX_ASTEROIDS)
let astRect# = pdim#(MAX_ASTEROIDS)

for i = 1 to MAX_ASTEROIDS
  astActive#[i] = 0
  let a# = ellipse#(frm#, 0, 0, 50, 50)
  ellipse_fill#(a#, "#333333")
  ellipse_stroke#(a#, "#888888")
  ellipse_strokethickness#(a#, 2)
  ellipse_hittest#(a#, 0)
  ellipse_visible#(a#, 0)
  astRect##[i] = a#
next

' ============================================================
'  CREATE D-PAD (Mobile only)
' ============================================================

if IS_MOBILE = 1 then
  ' D-Pad layout: centered at bottom, cross pattern
  '        [THRUST]
  '  [LEFT][      ][RIGHT]
  '        [FIRE  ]
  let dpadTop = GAME_H - CTRL_H + 5
  let btnSize = cint(CTRL_H / 3) - 4
  let dpadCenterX = cint(GAME_W / 2)
  let dpadCenterY = dpadTop + cint(CTRL_H / 2) - 5
  ' THRUST button (Up)
  let btnUp# = rectangle#(frm#, dpadCenterX - btnSize / 2, dpadCenterY - btnSize - btnSize / 2 - 4, btnSize, btnSize)
  rectangle_fill#(btnUp#, "#1a3a5a")
  rectangle_stroke#(btnUp#, "#3388cc")
  rectangle_strokethickness#(btnUp#, 2)
  rectangle_corners#(btnUp#, 6, 6)
  rectangle_hittest#(btnUp#, 1)
  rectangle_onmousedown#(btnUp#, "OnBtnUpDown")
  rectangle_onmouseup#(btnUp#, "OnBtnUpUp")
  let lblUp# = label#(frm#, "^")
  label_move#(lblUp#, dpadCenterX - btnSize / 2, dpadCenterY - btnSize - btnSize / 2 - 4)
  label_size#(lblUp#, btnSize, btnSize)
  label_fontsize#(lblUp#, 28)
  label_fontcolor#(lblUp#, "#44aaff")
  label_bold#(lblUp#, 1)
  label_textalign#(lblUp#, 0)
  ' FIRE button (Down) - red to distinguish from movement
  let btnDown# = rectangle#(frm#, dpadCenterX - btnSize / 2, dpadCenterY + btnSize / 2 + 4, btnSize, btnSize)
  rectangle_fill#(btnDown#, "#5a1a1a")
  rectangle_stroke#(btnDown#, "#cc4444")
  rectangle_strokethickness#(btnDown#, 2)
  rectangle_corners#(btnDown#, 6, 6)
  rectangle_hittest#(btnDown#, 1)
  rectangle_onmousedown#(btnDown#, "OnBtnDownDown")
  rectangle_onmouseup#(btnDown#, "OnBtnDownUp")
  let lblDown# = label#(frm#, "FIRE")
  label_autosize#(lblDown#, 0)
  label_move#(lblDown#, dpadCenterX - btnSize / 2, dpadCenterY + btnSize / 2 + 4)
  label_size#(lblDown#, btnSize, btnSize)
  label_fontsize#(lblDown#, 16)
  label_fontcolor#(lblDown#, "#ff6666")
  label_bold#(lblDown#, 1)
  label_textalign#(lblDown#, 0)
  label_vertalign#(lblDown#, 0)
  ' ROTATE LEFT button
  let btnLeft# = rectangle#(frm#, dpadCenterX - btnSize - btnSize / 2 - 4, dpadCenterY - btnSize / 2, btnSize, btnSize)
  rectangle_fill#(btnLeft#, "#1a3a5a")
  rectangle_stroke#(btnLeft#, "#3388cc")
  rectangle_strokethickness#(btnLeft#, 2)
  rectangle_corners#(btnLeft#, 6, 6)
  rectangle_hittest#(btnLeft#, 1)
  rectangle_onmousedown#(btnLeft#, "OnBtnLeftDown")
  rectangle_onmouseup#(btnLeft#, "OnBtnLeftUp")
  let lblLeft# = label#(frm#, "<")
  label_move#(lblLeft#, dpadCenterX - btnSize - btnSize / 2 - 4, dpadCenterY - btnSize / 2)
  label_size#(lblLeft#, btnSize, btnSize)
  label_fontsize#(lblLeft#, 28)
  label_fontcolor#(lblLeft#, "#44aaff")
  label_bold#(lblLeft#, 1)
  label_textalign#(lblLeft#, 0)
  ' ROTATE RIGHT button
  let btnRight# = rectangle#(frm#, dpadCenterX + btnSize / 2 + 4, dpadCenterY - btnSize / 2, btnSize, btnSize)
  rectangle_fill#(btnRight#, "#1a3a5a")
  rectangle_stroke#(btnRight#, "#3388cc")
  rectangle_strokethickness#(btnRight#, 2)
  rectangle_corners#(btnRight#, 6, 6)
  rectangle_hittest#(btnRight#, 1)
  rectangle_onmousedown#(btnRight#, "OnBtnRightDown")
  rectangle_onmouseup#(btnRight#, "OnBtnRightUp")
  let lblRight# = label#(frm#, ">")
  label_move#(lblRight#, dpadCenterX + btnSize / 2 + 4, dpadCenterY - btnSize / 2)
  label_size#(lblRight#, btnSize, btnSize)
  label_fontsize#(lblRight#, 28)
  label_fontcolor#(lblRight#, "#44aaff")
  label_bold#(lblRight#, 1)
  label_textalign#(lblRight#, 0)
end if

' --- Center message (created LAST for Z-order, on top of everything) ---
let lblMsg# = label#(frm#, "")
label_autosize#(lblMsg#, 0)
label_fontsize#(lblMsg#, 24)
label_fontcolor#(lblMsg#, "#ffffff")
label_bold#(lblMsg#, 1)
label_align#(lblMsg#, 14)
label_height#(lblMsg#, 40)
label_y#(lblMsg#, cint(PLAY_H / 2 - 20))
label_textalign#(lblMsg#, 0)
if IS_MOBILE = 1 then
  label_text#(lblMsg#, "Tap to Start")
  label_fontsize#(lblMsg#, 26)
else
  label_text#(lblMsg#, "Press DOWN to Start")
end if

' ============================================================
'  SETUP TIMER AND EVENTS
' ============================================================

let tmr# = timer#()
timer_interval#(tmr#, 16)
timer_ontimer#(tmr#, "GameLoop")
timer_start#(tmr#)

form_onkeydown#(frm#, "OnKeyDown")
form_onkeyup#(frm#, "OnKeyUp")
form_show(frm#)

' ============================================================
'  KEYBOARD EVENT HANDLERS (Desktop)
' ============================================================

function OnKeyDown(sender#, keyCode, keyChar$)
  ' Left=37, Right=39, Up=38, Down=40
  if keyCode = 37 then
    let rotateL = 1
  end if
  if keyCode = 39 then
    let rotateR = 1
  end if
  if keyCode = 38 then
    let thrusting = 1
  end if
  if keyCode = 40 then
    if running = 0 then
      if gameOver = 1 then
        ResetGame()
      end if
      StartWave()
    else
      FireBullet()
    end if
  end if
end function

function OnKeyUp(sender#, keyCode, keyChar$)
  if keyCode = 37 then
    let rotateL = 0
  end if
  if keyCode = 39 then
    let rotateR = 0
  end if
  if keyCode = 38 then
    let thrusting = 0
  end if
end function

' ============================================================
'  TOUCH EVENT HANDLER (Tap on play area to start/restart)
' ============================================================

' onmousedown: function(sender#, btn, mx, my, shift$)
function OnTouchDown(sender#, btn, mx, my, shift$)
  if running = 0 then
    if gameOver = 1 then
      ResetGame()
    end if
    StartWave()
  end if
end function

' ============================================================
'  D-PAD BUTTON HANDLERS (Mobile only)
' ============================================================

' --- THRUST (Up) - hold to thrust ---
' onmousedown: function(sender#, btn, mx, my, shift$)
function OnBtnUpDown(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnUp#, "#2a5a8a")
  if running = 0 then
    if gameOver = 1 then ResetGame()
    StartWave()
    return 0
  end if
  let thrusting = 1
end function
' onmouseup: function(sender#, btn, mx, my, shift$)
function OnBtnUpUp(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnUp#, "#1a3a5a")
  let thrusting = 0
end function

' --- FIRE (Down) - tap to fire ---
function OnBtnDownDown(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnDown#, "#8a2a2a")
  if running = 0 then
    if gameOver = 1 then ResetGame()
    StartWave()
    return 0
  end if
  FireBullet()
end function
function OnBtnDownUp(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnDown#, "#5a1a1a")
end function

' --- ROTATE LEFT - hold to rotate ---
function OnBtnLeftDown(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnLeft#, "#2a5a8a")
  if running = 0 then
    if gameOver = 1 then ResetGame()
    StartWave()
    return 0
  end if
  let rotateL = 1
end function
function OnBtnLeftUp(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnLeft#, "#1a3a5a")
  let rotateL = 0
end function

' --- ROTATE RIGHT - hold to rotate ---
function OnBtnRightDown(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnRight#, "#2a5a8a")
  if running = 0 then
    if gameOver = 1 then ResetGame()
    StartWave()
    return 0
  end if
  let rotateR = 1
end function
function OnBtnRightUp(sender#, btn, mx, my, shift$)
  rectangle_fill#(btnRight#, "#1a3a5a")
  let rotateR = 0
end function

' ============================================================
'  GAME FUNCTIONS
' ============================================================

function ResetGame() local i, a#
  let score = 0
  let lives = 3
  let wave = 0
  let gameOver = 0
  label_text#(lblScore#, "SCORE: 0")
  label_text#(lblLives#, "LIVES: 3")
  ' Clear asteroids
  for i = 1 to MAX_ASTEROIDS
    astActive#[i] = 0
    a# = astRect##[i]
    ellipse_visible#(a#, 0)
  next
end function

function StartWave() local numAsteroids, i
  let wave = wave + 1
  let running = 1
  let respawnTimer = 0
  let rotateL = 0
  let rotateR = 0
  let thrusting = 0
  
  ' Reset ship position
  let shipX = GAME_W / 2
  let shipY = PLAY_H / 2
  let shipAngle = 270
  let shipVX = 0
  let shipVY = 0
  let invincible = 1
  let invincibleTimer = 90
  
  rectangle_visible#(shipLine1#, 1)
  rectangle_visible#(shipLine2#, 1)
  
  ' Spawn asteroids (more each wave)
  numAsteroids = 3 + wave
  if numAsteroids > 8 then
    numAsteroids = 8
  end if
  
  let asteroidsLeft = numAsteroids
  
  for i = 1 to numAsteroids
    SpawnAsteroid(AST_LARGE, 0, 0, 1)
  next
  
  label_text#(lblWave#, "WAVE: " + stri$(wave))
  label_text#(lblMsg#, "")
end function

function SpawnAsteroid(size, atX, atY, randomPos) local i, ax, ay, angle, spd, a#
  ' Find free slot
  for i = 1 to MAX_ASTEROIDS
    if astActive#[i] = 0 then
      if randomPos = 1 then
        ' Spawn at random edge, away from ship
        if rnd() > 0.5 then
          ax = rnd() * GAME_W
          if rnd() > 0.5 then
            ay = 0
          else
            ay = PLAY_H
          end if
        else
          if rnd() > 0.5 then
            ax = 0
          else
            ax = GAME_W
          end if
          ay = rnd() * PLAY_H
        end if
      else
        ax = atX
        ay = atY
      end if
      
      astX#[i] = ax
      astY#[i] = ay
      astSize#[i] = size
      
      ' Random velocity
      angle = rnd() * 2 * PI
      spd = 1 + rnd() * 2
      astVX#[i] = cos(angle) * spd
      astVY#[i] = sin(angle) * spd
      
      astActive#[i] = 1
      
      a# = astRect##[i]
      ellipse_move#(a#, ax - size, ay - size)
      ellipse_size#(a#, size * 2, size * 2)
      ellipse_visible#(a#, 1)
      
      return 0
    end if
  next
end function

function FireBullet() local i, rad, b#
  for i = 1 to MAX_BULLETS
    if bulActive#[i] = 0 then
      rad = degtorad(shipAngle)
      bulX#[i] = shipX + cos(rad) * SHIP_SIZE
      bulY#[i] = shipY + sin(rad) * SHIP_SIZE
      bulVX#[i] = cos(rad) * BULLET_SPD + shipVX * 0.5
      bulVY#[i] = sin(rad) * BULLET_SPD + shipVY * 0.5
      bulLife#[i] = BULLET_LIFE
      bulActive#[i] = 1
      b# = bulRect##[i]
      rectangle_move#(b#, bulX#[i] - 2, bulY#[i] - 2)
      rectangle_visible#(b#, 1)
      return 0
    end if
  next
end function

function WrapX(val)
  if val < 0 then
    return val + GAME_W
  end if
  if val > GAME_W then
    return val - GAME_W
  end if
  return val
end function

function WrapY(val)
  if val < 0 then
    return val + PLAY_H
  end if
  if val > PLAY_H then
    return val - PLAY_H
  end if
  return val
end function

function UpdateShip() local rad, ax, ay, vel
  ' Rotation
  if rotateL = 1 then
    let shipAngle = shipAngle - ROTATE_SPD
  end if
  if rotateR = 1 then
    let shipAngle = shipAngle + ROTATE_SPD
  end if
  
  ' Keep angle in 0-360 range
  if shipAngle < 0 then
    let shipAngle = shipAngle + 360
  end if
  if shipAngle >= 360 then
    let shipAngle = shipAngle - 360
  end if
  
  ' Thrust
  rad = degtorad(shipAngle)
  if thrusting = 1 then
    ax = cos(rad) * THRUST
    ay = sin(rad) * THRUST
    let shipVX = shipVX + ax
    let shipVY = shipVY + ay
    rectangle_visible#(shipLine3#, 1)
  else
    rectangle_visible#(shipLine3#, 0)
  end if
  
  ' Apply friction
  let shipVX = shipVX * FRICTION
  let shipVY = shipVY * FRICTION
  
  ' Limit velocity
  vel = sqr(shipVX * shipVX + shipVY * shipVY)
  if vel > MAX_VEL then
    let shipVX = shipVX / vel * MAX_VEL
    let shipVY = shipVY / vel * MAX_VEL
  end if
  
  ' Move ship
  let shipX = shipX + shipVX
  let shipY = shipY + shipVY
  
  ' Wrap around screen
  let shipX = WrapX(shipX)
  let shipY = WrapY(shipY)
  
  ' Update ship visuals
  rectangle_move#(shipLine1#, shipX - SHIP_SIZE, shipY - SHIP_SIZE)
  
  ' Direction indicator
  rectangle_move#(shipLine2#, shipX + cos(rad) * SHIP_SIZE - 4, shipY + sin(rad) * SHIP_SIZE - 4)
  
  ' Thrust flame (behind ship)
  rectangle_move#(shipLine3#, shipX - cos(rad) * SHIP_SIZE * 1.3 - 3, shipY - sin(rad) * SHIP_SIZE * 1.3 - 3)
  
  ' Invincibility flashing
  if invincible = 1 then
    let invincibleTimer = invincibleTimer - 1
    if invincibleTimer <= 0 then
      let invincible = 0
      rectangle_opacity#(shipLine1#, 1)
      rectangle_opacity#(shipLine2#, 1)
    else
      if cint(invincibleTimer / 5) mod 2 = 0 then
        rectangle_opacity#(shipLine1#, 0.3)
        rectangle_opacity#(shipLine2#, 0.3)
      else
        rectangle_opacity#(shipLine1#, 1)
        rectangle_opacity#(shipLine2#, 1)
      end if
    end if
  end if
end function

function ShipHit() local i, b#
  let lives = lives - 1
  label_text#(lblLives#, "LIVES: " + stri$(lives))
  
  ' Clear bullets
  for i = 1 to MAX_BULLETS
    bulActive#[i] = 0
    b# = bulRect##[i]
    rectangle_visible#(b#, 0)
  next
  
  if lives <= 0 then
    let running = 0
    let gameOver = 1
    rectangle_visible#(shipLine1#, 0)
    rectangle_visible#(shipLine2#, 0)
    rectangle_visible#(shipLine3#, 0)
    if IS_MOBILE = 1 then
      label_text#(lblMsg#, "GAME OVER - Tap to Retry")
    else
      label_text#(lblMsg#, "GAME OVER - Press DOWN")
    end if
  else
    ' Respawn ship
    let shipX = GAME_W / 2
    let shipY = PLAY_H / 2
    let shipVX = 0
    let shipVY = 0
    let shipAngle = 270
    let invincible = 1
    let invincibleTimer = 120
  end if
end function

function SplitAsteroid(idx) local ax, ay, size, newSize, pts
  ax = astX#[idx]
  ay = astY#[idx]
  size = astSize#[idx]
  
  ' Points based on size
  if size = AST_LARGE then
    pts = 20
    newSize = AST_MEDIUM
  else if size = AST_MEDIUM then
    pts = 50
    newSize = AST_SMALL
  else
    pts = 100
    newSize = 0
  end if
  
  let score = score + pts
  label_text#(lblScore#, "SCORE: " + stri$(score))
  
  ' Destroy original
  astActive#[idx] = 0
  let a# = astRect##[idx]
  ellipse_visible#(a#, 0)
  
  ' Spawn two smaller (if not smallest)
  if newSize > 0 then
    SpawnAsteroid(newSize, ax, ay, 0)
    SpawnAsteroid(newSize, ax, ay, 0)
    let asteroidsLeft = asteroidsLeft + 1
  else
    let asteroidsLeft = asteroidsLeft - 1
  end if
end function

' ============================================================
'  MAIN GAME LOOP
' ============================================================

function GameLoop(sender#) local i, j, bx, by, ax, ay, asize, dx, dy, dist, b#, a#
  if running = 0 then
    return 0
  end if
  
  ' ========================
  '  UPDATE SHIP
  ' ========================
  UpdateShip()
  
  ' ========================
  '  UPDATE BULLETS
  ' ========================
  for i = 1 to MAX_BULLETS
    if bulActive#[i] = 1 then
      bulX#[i] = bulX#[i] + bulVX#[i]
      bulY#[i] = bulY#[i] + bulVY#[i]
      bulLife#[i] = bulLife#[i] - 1
      
      ' Wrap around
      bulX#[i] = WrapX(bulX#[i])
      bulY#[i] = WrapY(bulY#[i])
      
      b# = bulRect##[i]
      rectangle_move#(b#, bulX#[i] - 2, bulY#[i] - 2)
      
      ' Expire
      if bulLife#[i] <= 0 then
        bulActive#[i] = 0
        rectangle_visible#(b#, 0)
      end if
    end if
  next
  
  ' ========================
  '  UPDATE ASTEROIDS
  ' ========================
  for i = 1 to MAX_ASTEROIDS
    if astActive#[i] = 1 then
      astX#[i] = astX#[i] + astVX#[i]
      astY#[i] = astY#[i] + astVY#[i]
      
      ' Wrap around
      astX#[i] = WrapX(astX#[i])
      astY#[i] = WrapY(astY#[i])
      
      a# = astRect##[i]
      ellipse_move#(a#, astX#[i] - astSize#[i], astY#[i] - astSize#[i])
    end if
  next
  
  ' ========================
  '  BULLET-ASTEROID COLLISION
  ' ========================
  for i = 1 to MAX_BULLETS
    if bulActive#[i] = 1 then
      bx = bulX#[i]
      by = bulY#[i]
      
      for j = 1 to MAX_ASTEROIDS
        if astActive#[j] = 1 then
          ax = astX#[j]
          ay = astY#[j]
          asize = astSize#[j]
          
          dx = bx - ax
          dy = by - ay
          dist = sqr(dx * dx + dy * dy)
          
          if dist < asize then
            ' Hit!
            bulActive#[i] = 0
            b# = bulRect##[i]
            rectangle_visible#(b#, 0)
            SplitAsteroid(j)
          end if
        end if
      next
    end if
  next
  
  ' ========================
  '  SHIP-ASTEROID COLLISION
  ' ========================
  if invincible = 0 then
    for i = 1 to MAX_ASTEROIDS
      if astActive#[i] = 1 then
        dx = shipX - astX#[i]
        dy = shipY - astY#[i]
        dist = sqr(dx * dx + dy * dy)
        
        if dist < astSize#[i] + SHIP_SIZE * 0.7 then
          ShipHit()
          return 0
        end if
      end if
    next
  end if
  
  ' ========================
  '  CHECK WAVE COMPLETE
  ' ========================
  if asteroidsLeft <= 0 then
    let running = 0
    if IS_MOBILE = 1 then
      label_text#(lblMsg#, "WAVE CLEAR! Tap to Continue")
    else
      label_text#(lblMsg#, "WAVE CLEAR! Press DOWN")
    end if
  end if
end function
