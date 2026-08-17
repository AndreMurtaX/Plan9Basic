' ============================================================
'  BREAKOUT - A Classic Arcade Game
'  Written in Plan9Basic
' ============================================================
'
'  Controls (Desktop):
'    Left / Right Arrow Keys  -  Move paddle
'    Up                       -  Launch ball / Restart game
'
'  Controls (Mobile / Touch):
'    Drag finger              -  Paddle follows your finger
'    Tap screen               -  Launch ball / Restart game
'
'  Scoring:
'    Top row (red)     = 50 points
'    Row 2 (orange)    = 40 points
'    Row 3 (teal)      = 30 points
'    Row 4 (blue)      = 20 points
'    Bottom row (purple)= 10 points
'
' ============================================================

' Seed the random number generator
randomize()

' --- Platform Detection ---
let PLATFORM$ = os_name$()
let IS_MOBILE = 0
if (PLATFORM$ = "Android") or (PLATFORM$ = "iOS") then IS_MOBILE = 1

' --- Game Area Constants ---
let GAME_W = 640
let GAME_H = 520
let WALL = 5
let TOP_BAR = 40

if IS_MOBILE = 1 then
  let GAME_W = form_screenwidth()
  let GAME_H = form_screenheight()
  let TOP_BAR = 50
end if

' --- Paddle Constants ---
let PAD_W = 90
let PAD_H = 12
let PAD_Y = GAME_H - 40
let PAD_SPD = 8

if IS_MOBILE = 1 then
  let PAD_W = cint(GAME_W * 0.22)
  let PAD_H = 16
end if

' --- Ball Constants ---
let BALL_SZ = 14
let BALL_SPD = 4

if IS_MOBILE = 1 then
  let BALL_SZ = 16
  let BALL_SPD = 5
end if

' --- Brick Grid Constants ---
let COLS = 10
let ROWS = 5
let BGAP = 4
let BOFF_X = 11
let BOFF_Y = TOP_BAR + 15
let BW = cint((GAME_W - 2 * BOFF_X - (COLS - 1) * BGAP) / COLS)
let BH = 20
let TOTAL = COLS * ROWS

if IS_MOBILE = 1 then
  let BOFF_X = 8
  let BGAP = 3
  let BW = cint((GAME_W - 2 * BOFF_X - (COLS - 1) * BGAP) / COLS)
  let BH = 24
end if

' --- Game State Variables ---
let ballX = 0
let ballY = 0
let ballDX = 0
let ballDY = 0
let padX = 0
let score = 0
let lives = 3
let running = 0
let bricksLeft = TOTAL
let moveL = 0
let moveR = 0
let touchActive = 0

' --- Object Pointers ---
let frm# = pointer#(0)
let pad# = pointer#(0)
let ball# = pointer#(0)
let lblScore# = pointer#(0)
let lblLives# = pointer#(0)
let lblMsg# = pointer#(0)
let tmr# = pointer#(0)
let bricks# = pointer#(0)
let alive# = pointer#(0)
let colors# = pointer#(0)
let divider# = pointer#(0)
let wallL# = pointer#(0)
let wallR# = pointer#(0)
let wallT# = pointer#(0)
let touchArea# = pointer#(0)

' ============================================================
'  CREATE THE GAME WINDOW
' ============================================================

if IS_MOBILE = 1 then
  let frm# = form#("Breakout!", GAME_W, GAME_H)
else
  ' Add chrome compensation: ~16px for side borders, ~39px for title bar
  let frm# = form#("Breakout!", GAME_W + 16, GAME_H + 39)
  form_position#(frm#, 4)
end if
form_fill#(frm#, "#0f0f23")

' --- Decorative walls (visual only) ---
let wallL# = rectangle#(frm#, 0, TOP_BAR, WALL, GAME_H - TOP_BAR)
rectangle_fill#(wallL#, "#1a1a3e")
rectangle_strokenone#(wallL#)
rectangle_hittest#(wallL#, 0)

let wallR# = rectangle#(frm#, GAME_W - WALL, TOP_BAR, WALL, GAME_H - TOP_BAR)
rectangle_fill#(wallR#, "#1a1a3e")
rectangle_strokenone#(wallR#)
rectangle_hittest#(wallR#, 0)

let wallT# = rectangle#(frm#, 0, TOP_BAR, GAME_W, WALL)
rectangle_fill#(wallT#, "#1a1a3e")
rectangle_strokenone#(wallT#)
rectangle_hittest#(wallT#, 0)

' --- Touch area (transparent, covers game area for touch/mouse input) ---
' All other elements have hittest=0, so this captures all touches.
let touchArea# = rectangle#(frm#, 0, TOP_BAR, GAME_W, GAME_H - TOP_BAR)
rectangle_fill#(touchArea#, "#00000000")
rectangle_strokenone#(touchArea#)
rectangle_hittest#(touchArea#, 1)
rectangle_onmousedown#(touchArea#, "OnTouchDown")
rectangle_onmouseup#(touchArea#, "OnTouchUp")
rectangle_onmousemove#(touchArea#, "OnTouchMove")

' --- Score label (top left) ---
let lblScore# = label#(frm#, "SCORE: 0", 15, 8)
label_autosize#(lblScore#, 0)
label_fontsize#(lblScore#, 15)
label_fontcolor#(lblScore#, "#e94560")
label_bold#(lblScore#, 1)
label_size#(lblScore#, 250, 28)

if IS_MOBILE = 1 then
  label_fontsize#(lblScore#, 17)
end if

' --- Lives label (top right) ---
let lblLives# = label#(frm#, "LIVES: 3")
label_autosize#(lblLives#, 0)
label_move#(lblLives#, GAME_W - 160, 8)
label_fontsize#(lblLives#, 15)
label_fontcolor#(lblLives#, "#4fc3f7")
label_bold#(lblLives#, 1)
label_size#(lblLives#, 145, 28)
label_textalign#(lblLives#, 2)

if IS_MOBILE = 1 then
  label_fontsize#(lblLives#, 17)
end if

' --- Divider line below top bar ---
let divider# = rectangle#(frm#, 0, TOP_BAR - 1, GAME_W, 1)
rectangle_fill#(divider#, "#2c3e6e")
rectangle_strokenone#(divider#)
rectangle_hittest#(divider#, 0)

' ============================================================
'  CREATE THE BRICKS
' ============================================================

' Row colors (top to bottom)
let colors# = sdim#(ROWS)
colors#$[1] = "#e94560"
colors#$[2] = "#f59e42"
colors#$[3] = "#48d1cc"
colors#$[4] = "#5dade2"
colors#$[5] = "#a569bd"

' Brick pointer array and alive-status array
let bricks# = pdim#(TOTAL)
let alive# = dim#(TOTAL)

for row = 0 to ROWS - 1
  for col = 0 to COLS - 1
    let idx = row * COLS + col + 1
    let bx = BOFF_X + col * (BW + BGAP)
    let by = BOFF_Y + row * (BH + BGAP)
    let brk# = rectangle#(frm#, bx, by, BW, BH)
    rectangle_fill#(brk#, sarr_get$(colors#, row + 1))
    rectangle_strokenone#(brk#)
    rectangle_corners#(brk#, 4, 4)
    rectangle_hittest#(brk#, 0)
    bricks##[idx] = brk#
    alive#[idx] = 1
  next
next

' ============================================================
'  CREATE PADDLE AND BALL
' ============================================================

' Paddle (centered horizontally)
let padX = cint((GAME_W - PAD_W) / 2)
let pad# = rectangle#(frm#, padX, PAD_Y, PAD_W, PAD_H)
rectangle_fill#(pad#, "#e94560")
rectangle_strokenone#(pad#)
rectangle_corners#(pad#, 6, 6)
rectangle_hittest#(pad#, 0)

' Ball (resting on paddle)
let ballX = padX + PAD_W / 2 - BALL_SZ / 2
let ballY = PAD_Y - BALL_SZ - 2
let ball# = ellipse#(frm#, ballX, ballY, BALL_SZ, BALL_SZ)
ellipse_fill#(ball#, "#ffffff")
ellipse_strokenone#(ball#)
ellipse_hittest#(ball#, 0)

' --- Center message label (created LAST for Z-order, on top of everything) ---
let lblMsg# = label#(frm#, "")
label_autosize#(lblMsg#, 0)
label_fontsize#(lblMsg#, 22)
label_fontcolor#(lblMsg#, "#ffffff")
label_bold#(lblMsg#, 1)
label_align#(lblMsg#, 14)
label_height#(lblMsg#, 40)
label_y#(lblMsg#, cint(GAME_H / 2 + 20))
label_textalign#(lblMsg#, 0)
if IS_MOBILE = 1 then
  label_text#(lblMsg#, "Tap to Start")
  label_fontsize#(lblMsg#, 24)
else
  label_text#(lblMsg#, "Press Up to Start")
end if

' ============================================================
'  SETUP TIMER AND EVENTS
' ============================================================

' Game loop timer (~60 FPS)
let tmr# = timer#()
timer_interval#(tmr#, 16)
timer_ontimer#(tmr#, "GameLoop")
timer_start#(tmr#)

' Keyboard events (desktop)
form_onkeydown#(frm#, "OnKeyDown")
form_onkeyup#(frm#, "OnKeyUp")

' Show the game window
form_show(frm#)

' ============================================================
'  KEYBOARD EVENT HANDLERS (Desktop)
' ============================================================

function OnKeyDown(sender#, keyCode, keyChar$)
  ' Left arrow = 37, Right arrow = 39, Up arrow = 38
  if keyCode = 37 then
    let moveL = 1
  end if
  if keyCode = 39 then
    let moveR = 1
  end if
  if keyCode = 38 then
    LaunchOrRestart()
  end if
end function

function OnKeyUp(sender#, keyCode, keyChar$)
  if keyCode = 37 then
    let moveL = 0
  end if
  if keyCode = 39 then
    let moveR = 0
  end if
end function

' ============================================================
'  TOUCH EVENT HANDLERS (Mobile + Desktop mouse)
' ============================================================

' onmousedown signature: function(sender#, btn, mx, my, shift$)
function OnTouchDown(sender#, btn, mx, my, shift$)
  let touchActive = 1
  ' Move paddle center to finger X position
  MovePaddleTo(mx)
  ' Tap also launches ball or restarts
  LaunchOrRestart()
end function

' onmouseup signature: function(sender#, btn, mx, my, shift$)
function OnTouchUp(sender#, btn, mx, my, shift$)
  let touchActive = 0
end function

' onmousemove signature: function(sender#, mx, my, shift$)
function OnTouchMove(sender#, mx, my, shift$)
  if touchActive = 1 then
    MovePaddleTo(mx)
  end if
end function

' ============================================================
'  SHARED GAME FUNCTIONS
' ============================================================

function MovePaddleTo(targetX) local newX
  newX = cint(targetX - PAD_W / 2)
  if newX < WALL then
    newX = WALL
  end if
  if newX > GAME_W - PAD_W - WALL then
    newX = GAME_W - PAD_W - WALL
  end if
  let padX = newX
  rectangle_x#(pad#, padX)
end function

function LaunchOrRestart() local i, b#
  if running = 0 then
    if lives <= 0 then
      ' --- Full game reset ---
      let score = 0
      let lives = 3
      let bricksLeft = TOTAL
      label_text#(lblScore#, "SCORE: 0")
      label_text#(lblLives#, "LIVES: 3")
      ' Restore all bricks
      for i = 1 to TOTAL
        b# = bricks##[i]
        rectangle_visible#(b#, 1)
        alive#[i] = 1
      next
    end if
    ' --- Launch ball with slight random angle ---
    let running = 1
    let ballDX = rnd() * 4 - 2
    if abs(ballDX) < 1 then
      let ballDX = 1.5
    end if
    let ballDY = 0 - BALL_SPD
    label_text#(lblMsg#, "")
  end if
end function

' ============================================================
'  MAIN GAME LOOP (called by timer ~60x per second)
' ============================================================

function GameLoop(sender#) local hitPos, i, hit, r, c, bx, by, b#, overL, overR, overT, overB, minX, minY
  ' ==========================
  '  PADDLE MOVEMENT (keyboard)
  ' ==========================
  if moveL = 1 then
    let padX = padX - PAD_SPD
    if padX < WALL then
      let padX = WALL
    end if
    rectangle_x#(pad#, padX)
  end if
  if moveR = 1 then
    let padX = padX + PAD_SPD
    if padX > GAME_W - PAD_W - WALL then
      let padX = GAME_W - PAD_W - WALL
    end if
    rectangle_x#(pad#, padX)
  end if

  ' ==========================
  '  BALL ON PADDLE (waiting)
  ' ==========================
  if running = 0 then
    let ballX = padX + PAD_W / 2 - BALL_SZ / 2
    let ballY = PAD_Y - BALL_SZ - 2
    ellipse_move#(ball#, ballX, ballY)
    return 0
  end if

  ' ==========================
  '  MOVE BALL
  ' ==========================
  let ballX = ballX + ballDX
  let ballY = ballY + ballDY

  ' ==========================
  '  WALL COLLISIONS
  ' ==========================
  ' Left wall
  if ballX < WALL then
    let ballX = WALL
    let ballDX = abs(ballDX)
  end if
  ' Right wall
  if ballX > GAME_W - BALL_SZ - WALL then
    let ballX = GAME_W - BALL_SZ - WALL
    let ballDX = 0 - abs(ballDX)
  end if
  ' Top wall
  if ballY < TOP_BAR + WALL then
    let ballY = TOP_BAR + WALL
    let ballDY = abs(ballDY)
  end if

  ' ==========================
  '  BOTTOM: LOSE A LIFE
  ' ==========================
  if ballY > GAME_H then
    let lives = lives - 1
    label_text#(lblLives#, "LIVES: " + stri$(lives))
    let running = 0
    if lives > 0 then
      if IS_MOBILE = 1 then
        label_text#(lblMsg#, "Tap to Continue")
      else
        label_text#(lblMsg#, "Press Up to Continue")
      end if
    else
      if IS_MOBILE = 1 then
        label_text#(lblMsg#, "GAME OVER! Tap to Retry")
      else
        label_text#(lblMsg#, "GAME OVER! Press Up")
      end if
    end if
    return 0
  end if

  ' ==========================
  '  PADDLE COLLISION
  ' ==========================
  if ballDY > 0 then
    if ballY + BALL_SZ >= PAD_Y then
      if ballY < PAD_Y + PAD_H then
        if ballX + BALL_SZ > padX then
          if ballX < padX + PAD_W then
            ' Hit position: 0.0 (left edge) to 1.0 (right edge)
            hitPos = (ballX + BALL_SZ / 2 - padX) / PAD_W
            ' Map to horizontal speed: negative=left, positive=right
            let ballDX = (hitPos - 0.5) * BALL_SPD * 2.5
            ' Clamp horizontal speed
            if ballDX > BALL_SPD * 1.5 then
              let ballDX = BALL_SPD * 1.5
            end if
            if ballDX < 0 - BALL_SPD * 1.5 then
              let ballDX = 0 - BALL_SPD * 1.5
            end if
            ' Always bounce upward
            let ballDY = 0 - BALL_SPD
            let ballY = PAD_Y - BALL_SZ
          end if
        end if
      end if
    end if
  end if

  ' ==========================
  '  BRICK COLLISIONS
  ' ==========================
  hit = 0
  for i = 1 to TOTAL
    if hit = 0 then
      if alive#[i] = 1 then
        ' Calculate brick position from index
        r = cint((i - 1) / COLS)
        c = (i - 1) - r * COLS
        bx = BOFF_X + c * (BW + BGAP)
        by = BOFF_Y + r * (BH + BGAP)
        ' Check AABB overlap (ball vs brick)
        if ballX + BALL_SZ > bx then
          if ballX < bx + BW then
            if ballY + BALL_SZ > by then
              if ballY < by + BH then
                ' === BRICK HIT! ===
                ' Destroy the brick
                alive#[i] = 0
                b# = bricks##[i]
                rectangle_visible#(b#, 0)
                ' Award points (top rows worth more)
                let score = score + (ROWS - r) * 10
                label_text#(lblScore#, "SCORE: " + stri$(score))
                let bricksLeft = bricksLeft - 1
                ' Determine bounce direction
                overL = ballX + BALL_SZ - bx
                overR = bx + BW - ballX
                overT = ballY + BALL_SZ - by
                overB = by + BH - ballY
                minX = min(overL, overR)
                minY = min(overT, overB)
                if minX < minY then
                  ' Side collision: reverse horizontal
                  let ballDX = 0 - ballDX
                else
                  ' Top/bottom collision: reverse vertical
                  let ballDY = 0 - ballDY
                end if
                ' Only one brick per frame
                let hit = 1
                ' Check win condition
                if bricksLeft <= 0 then
                  let running = 0
                  if IS_MOBILE = 1 then
                    label_text#(lblMsg#, "YOU WIN! Tap to Play Again")
                  else
                    label_text#(lblMsg#, "YOU WIN! Press Up")
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  next

  ' ==========================
  '  UPDATE BALL POSITION
  ' ==========================
  ellipse_move#(ball#, ballX, ballY)
end function
