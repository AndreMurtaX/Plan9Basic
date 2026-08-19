' ============================================================
'  SPACE INVADERS - A Classic Arcade Game
'  Written in Plan9Basic
' ============================================================
'
'  Controls (Desktop):
'    Left / Right Arrow  -  Move ship
'    Up Arrow            -  Fire / Start game / Restart
'
'  Controls (Mobile / Touch):
'    Drag left/right     -  Move ship to finger position
'    Tap FIRE button     -  Fire laser
'    Tap screen          -  Start / Restart game
'
'  Scoring:
'    Squid aliens (top)    = 30 points
'    Crab aliens (middle)  = 20 points
'    Octopus aliens (bottom) = 10 points
'
'  Objective:
'    Destroy all the alien invaders before they reach the
'    bottom or destroy all your ships!
'
' ============================================================

randomize()

' --- Platform Detection ---
let PLATFORM$ = os_name$()
let IS_MOBILE = 0
if (PLATFORM$ = "Android") or (PLATFORM$ = "iOS") then IS_MOBILE = 1
if instr(PLATFORM$, "Android") >= 0 or instr(PLATFORM$, "iOS") >= 0 then IS_MOBILE = 1

' --- Audio Format Detection ---
'     Windows → WAV  (Win32 native, hardware-accelerated)
'     Linux   → OGG  (GStreamer native, open-source royalty-free)
'     Android → OGG  (Google-recommended for mobile game audio)
'     macOS   → MP3  (CoreAudio universal support)
'     iOS     → MP3  (AVFoundation universal support)
let SOUND_BASE$ = "https://plan9basic.com/assets/sounds/invaders/"
let SOUND_EXT$ = "mp3"
if instr(PLATFORM$, "Windows") >= 0 then SOUND_EXT$ = "wav"
if instr(PLATFORM$, "Linux") >= 0 then SOUND_EXT$ = "ogg"
if instr(PLATFORM$, "Android") >= 0 then SOUND_EXT$ = "ogg"

' --- Game Area Constants ---
let GAME_W = 640
let GAME_H = 580
let TOP_BAR = 40
let CTRL_H = 0

if IS_MOBILE = 1 then
  let GAME_W = form_screenwidth()
  let GAME_H = form_screenheight()
  let TOP_BAR = 50
  let CTRL_H = 120
end if

let PLAY_H = GAME_H - CTRL_H

' --- Player Constants ---
let SHIP_W = 40
let SHIP_H = 20
let SHIP_Y = PLAY_H - 50
let SHIP_SPD = 6
let TURRET_W = 6
let TURRET_H = 12

if IS_MOBILE = 1 then
  let SHIP_W = 48
  let SHIP_H = 24
  let TURRET_W = 8
  let TURRET_H = 14
end if

' --- Alien Grid Constants ---
let ALIEN_COLS = 11
let ALIEN_ROWS = 5
let ALIEN_W = 32
let ALIEN_H = 24
let ALIEN_GAP_X = 12
let ALIEN_GAP_Y = 10
let TOTAL_ALIENS = ALIEN_COLS * ALIEN_ROWS

if IS_MOBILE = 1 then
  let ALIEN_GAP_X = cint((GAME_W - 80 - ALIEN_COLS * ALIEN_W) / (ALIEN_COLS - 1))
  if ALIEN_GAP_X < 4 then
    let ALIEN_GAP_X = 4
    let ALIEN_W = cint((GAME_W - 80 - (ALIEN_COLS - 1) * ALIEN_GAP_X) / ALIEN_COLS)
  end if
end if

' --- Alien Sub-part Sizes (proportional) ---
let EYE_SZ = cint(ALIEN_H * 0.22)
if EYE_SZ < 4 then EYE_SZ = 4
let PUPIL_SZ = cint(EYE_SZ * 0.6)
if PUPIL_SZ < 2 then PUPIL_SZ = 2

' --- Bullet Constants ---
let MAX_PLAYER_BULLETS = 1
let MAX_ALIEN_BULLETS = 10
let PLAYER_BULLET_SPD = 10
let ALIEN_BULLET_SPD = 4

if IS_MOBILE = 1 then ALIEN_BULLET_SPD = 5

' --- Shield Constants ---
let NUM_SHIELDS = 4
let SHIELD_W = 60
let SHIELD_H = 40
let SHIELD_Y = SHIP_Y - 80

if IS_MOBILE = 1 then
  let SHIELD_W = cint(GAME_W * 0.12)
  let SHIELD_H = 36
end if

' --- Explosion Constants ---
let MAX_EXPLOSIONS = 6
let EXPLODE_TIME = 10

' --- Star Constants ---
let NUM_STARS = 40

' --- Game State ---
let score = 0
let lives = 3
let wave = 0
let running = 0
let gameOver = 0
let shipX = 300
let moveL = 0
let moveR = 0
let touchActive = 0

' --- Alien Movement State ---
let alienBaseX = 40
let alienBaseY = 80
let alienDirX = 1
let alienSpeed = 1.0
let alienMoveTimer = 0
let alienMoveDelay = 30
let aliensAlive = 0
let alienShootTimer = 0
let alienShootDelay = 60

' --- Object Pointers ---
let frm# = pointer#(0)
let shipCont# = pointer#(0)
let shipHull# = pointer#(0)
let shipTurret# = pointer#(0)
let shipCockpit# = pointer#(0)
let lblScore# = pointer#(0)
let lblLives# = pointer#(0)
let lblWave# = pointer#(0)
let lblMsg# = pointer#(0)
let lblMsg2# = pointer#(0)
let tmr# = pointer#(0)
' --- Sound Players ---
'     sndExplode# is a pdim pointer array [1..3] — a pool of 3 players
'     so multiple alien destructions can overlap without cutting each other off.
let sndShoot#     = pointer#(0)
let sndExplode#   = pointer#(0)
let sndPlayerHit# = pointer#(0)
let sndGameOver#  = pointer#(0)
let sndWaveClear# = pointer#(0)
let sndMarch#     = pointer#(0)
let explodeSndIdx = 0   ' cycles 1-3 through the explosion pool
let soundInitDone = 0   ' set to 1 after InitSounds() on first GameLoop tick
let gnd# = pointer#(0)
let touchArea# = pointer#(0)

' --- Alien Arrays ---
let alienX# = pointer#(0)
let alienY# = pointer#(0)
let alienAlive# = pointer#(0)
let alienRect# = pointer#(0)
let alienPoints# = pointer#(0)

' --- Player Bullet Arrays ---
let pbX# = pointer#(0)
let pbY# = pointer#(0)
let pbActive# = pointer#(0)
let pbRect# = pointer#(0)

' --- Alien Bullet Arrays ---
let abX# = pointer#(0)
let abY# = pointer#(0)
let abActive# = pointer#(0)
let abRect# = pointer#(0)

' --- Shield Arrays ---
let shieldX# = pointer#(0)
let shieldHealth# = pointer#(0)
let shieldRect# = pointer#(0)

' --- Explosion Arrays ---
let explTimer# = pointer#(0)
let explObj# = pointer#(0)

' --- Mobile Control Pointers ---
let ctrlPanel# = pointer#(0)
let btnLeft# = pointer#(0)
let btnFire# = pointer#(0)
let btnRight# = pointer#(0)
let lblBtnL# = pointer#(0)
let lblBtnF# = pointer#(0)
let lblBtnR# = pointer#(0)

' ============================================================
'  CREATE THE GAME WINDOW
' ============================================================

if IS_MOBILE = 1 then
  let frm# = form#("Space Invaders", GAME_W, GAME_H)
else
  let frm# = form#("Space Invaders", GAME_W + 16, GAME_H + 39)
  form_position#(frm#, 4)
end if
form_fill#(frm#, "#050510")

' ============================================================
'  CREATE STARFIELD (behind everything)
' ============================================================

for i = 1 to NUM_STARS
  let sx = 10 + cint(rnd() * (GAME_W - 20))
  let sy = TOP_BAR + cint(rnd() * (PLAY_H - TOP_BAR - 40))
  let ss = 1 + cint(rnd() * 2)
  let bright = 80 + cint(rnd() * 175)
  let star# = circle#(frm#, sx, sy, ss, ss)
  let hexBright$ = hex$(bright)
  if len(hexBright$) < 2 then hexBright$ = "0" + hexBright$
  circle_fill#(star#, "#" + hexBright$ + hexBright$ + hexBright$)
  circle_strokenone#(star#)
  circle_hittest#(star#, 0)
next

' --- Touch area (transparent, covers play area) ---
let touchArea# = rectangle#(frm#, 0, TOP_BAR, GAME_W, PLAY_H - TOP_BAR)
rectangle_fill#(touchArea#, "#00000000")
rectangle_strokenone#(touchArea#)
rectangle_hittest#(touchArea#, 1)
rectangle_onmousedown#(touchArea#, "OnTouchDown")
rectangle_onmouseup#(touchArea#, "OnTouchUp")
rectangle_onmousemove#(touchArea#, "OnTouchMove")

' ============================================================
'  CREATE HUD LABELS
' ============================================================

let lblScore# = label#(frm#, "SCORE: 0", 15, 8)
label_autosize#(lblScore#, 0)
label_fontsize#(lblScore#, 16)
label_fontcolor#(lblScore#, "#00ff00")
label_bold#(lblScore#, 1)
label_size#(lblScore#, 200, 25)

let lblLives# = label#(frm#, "LIVES: 3")
label_autosize#(lblLives#, 0)
label_move#(lblLives#, GAME_W / 2 - 50, 8)
label_fontsize#(lblLives#, 16)
label_fontcolor#(lblLives#, "#ff4444")
label_bold#(lblLives#, 1)
label_size#(lblLives#, 120, 25)

let lblWave# = label#(frm#, "WAVE: 1")
label_autosize#(lblWave#, 0)
label_move#(lblWave#, GAME_W - 130, 8)
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

' --- Ground line ---
let gnd# = rectangle#(frm#, 0, PLAY_H - 25, GAME_W, 2)
rectangle_fill#(gnd#, "#00ff00")
rectangle_strokenone#(gnd#)
rectangle_hittest#(gnd#, 0)

' ============================================================
'  CREATE SHIELDS
' ============================================================

let shieldX# = dim#(NUM_SHIELDS)
let shieldHealth# = dim#(NUM_SHIELDS)
let shieldRect# = pdim#(NUM_SHIELDS)

let shieldGap = (GAME_W - NUM_SHIELDS * SHIELD_W) / (NUM_SHIELDS + 1)
for i = 1 to NUM_SHIELDS
  let sx = shieldGap + (i - 1) * (SHIELD_W + shieldGap)
  shieldX#[i] = sx
  shieldHealth#[i] = 4
  let s# = rectangle#(frm#, sx, SHIELD_Y, SHIELD_W, SHIELD_H)
  rectangle_fill#(s#, "#00cc00")
  rectangle_strokenone#(s#)
  rectangle_corners#(s#, 8, 8)
  rectangle_hittest#(s#, 0)
  rectangle_visible#(s#, 0)
  shieldRect##[i] = s#
next

' ============================================================
'  CREATE ALIENS (multi-part with container)
' ============================================================

let alienX# = dim#(TOTAL_ALIENS)
let alienY# = dim#(TOTAL_ALIENS)
let alienAlive# = dim#(TOTAL_ALIENS)
let alienRect# = pdim#(TOTAL_ALIENS)
let alienPoints# = dim#(TOTAL_ALIENS)

let aw = ALIEN_W
let ah = ALIEN_H

for row = 0 to ALIEN_ROWS - 1
  for col = 0 to ALIEN_COLS - 1
    let idx = row * ALIEN_COLS + col + 1
    let ax = alienBaseX + col * (aw + ALIEN_GAP_X)
    let ay = alienBaseY + row * (ah + ALIEN_GAP_Y)
    alienX#[idx] = ax
    alienY#[idx] = ay
    alienAlive#[idx] = 1

    if row < 1 then
      alienPoints#[idx] = 30
    else if row < 3 then
      alienPoints#[idx] = 20
    else
      alienPoints#[idx] = 10
    end if

    ' --- Container (transparent rectangle) ---
    let cont# = rectangle#(frm#, ax, ay, aw, ah)
    rectangle_fill#(cont#, "#00000000")
    rectangle_strokenone#(cont#)
    rectangle_hittest#(cont#, 0)
    rectangle_visible#(cont#, 0)
    alienRect##[idx] = cont#

    ' --- Create alien type parts as children ---
    if row = 0 then
      CreateSquidParts(cont#, aw, ah)
    else if row < 3 then
      CreateCrabParts(cont#, aw, ah)
    else
      CreateOctoParts(cont#, aw, ah)
    end if
  next
next

' ============================================================
'  CREATE EXPLOSION POOL
' ============================================================

let explTimer# = dim#(MAX_EXPLOSIONS)
let explObj# = pdim#(MAX_EXPLOSIONS)

for i = 1 to MAX_EXPLOSIONS
  explTimer#[i] = 0
  let ex# = ellipse#(frm#, 0, 0, aw, ah)
  ellipse_fill#(ex#, "#ffff66")
  ellipse_stroke#(ex#, "#ff8800")
  ellipse_strokethickness#(ex#, 2)
  ellipse_hittest#(ex#, 0)
  ellipse_visible#(ex#, 0)
  explObj##[i] = ex#
next

' ============================================================
'  CREATE PLAYER SHIP (multi-part with container)
' ============================================================

let shipX = (GAME_W - SHIP_W) / 2

let shipCont# = rectangle#(frm#, shipX, SHIP_Y, SHIP_W, SHIP_H)
rectangle_fill#(shipCont#, "#00000000")
rectangle_strokenone#(shipCont#)
rectangle_hittest#(shipCont#, 0)

' --- Hull ---
let shipHull# = rectangle#(shipCont#, 0, 4, SHIP_W, SHIP_H - 4)
rectangle_fill#(shipHull#, "#00dd00")
rectangle_strokenone#(shipHull#)
rectangle_corners#(shipHull#, 4, 4)
rectangle_hittest#(shipHull#, 0)

' --- Turret ---
let shipTurret# = rectangle#(shipCont#, cint(SHIP_W / 2 - TURRET_W / 2), -cint(TURRET_H * 0.6), TURRET_W, TURRET_H)
rectangle_fill#(shipTurret#, "#00ff00")
rectangle_strokenone#(shipTurret#)
rectangle_corners#(shipTurret#, 2, 2)
rectangle_hittest#(shipTurret#, 0)

' --- Cockpit ---
let cpW = cint(SHIP_W * 0.25)
let cpH = cint(SHIP_H * 0.3)
let shipCockpit# = ellipse#(shipCont#, cint(SHIP_W / 2 - cpW / 2), cint(SHIP_H * 0.35), cpW, cpH)
ellipse_fill#(shipCockpit#, "#66ccff")
ellipse_strokenone#(shipCockpit#)
ellipse_hittest#(shipCockpit#, 0)

' ============================================================
'  CREATE PLAYER BULLETS
' ============================================================

let pbX# = dim#(MAX_PLAYER_BULLETS)
let pbY# = dim#(MAX_PLAYER_BULLETS)
let pbActive# = dim#(MAX_PLAYER_BULLETS)
let pbRect# = pdim#(MAX_PLAYER_BULLETS)

for i = 1 to MAX_PLAYER_BULLETS
  pbActive#[i] = 0
  let pb# = rectangle#(frm#, 0, 0, 4, 14)
  rectangle_fill#(pb#, "#66ffaa")
  rectangle_strokenone#(pb#)
  rectangle_hittest#(pb#, 0)
  rectangle_visible#(pb#, 0)
  pbRect##[i] = pb#
next

' ============================================================
'  CREATE ALIEN BULLETS
' ============================================================

let abX# = dim#(MAX_ALIEN_BULLETS)
let abY# = dim#(MAX_ALIEN_BULLETS)
let abActive# = dim#(MAX_ALIEN_BULLETS)
let abRect# = pdim#(MAX_ALIEN_BULLETS)

for i = 1 to MAX_ALIEN_BULLETS
  abActive#[i] = 0
  let ab# = rectangle#(frm#, 0, 0, 4, 10)
  rectangle_fill#(ab#, "#ff4444")
  rectangle_strokenone#(ab#)
  rectangle_hittest#(ab#, 0)
  rectangle_visible#(ab#, 0)
  abRect##[i] = ab#
next

' ============================================================
'  CREATE MOBILE CONTROLS
' ============================================================

if IS_MOBILE = 1 then
  let ctrlPanel# = rectangle#(frm#, 0, PLAY_H, GAME_W, CTRL_H)
  rectangle_fill#(ctrlPanel#, "#0a0a1a")
  rectangle_stroke#(ctrlPanel#, "#222244")
  rectangle_strokethickness#(ctrlPanel#, 1)
  rectangle_hittest#(ctrlPanel#, 0)

  let btnW = GAME_W / 3 - 12
  let btnH = CTRL_H - 24
  let btnY = PLAY_H + 12

  let btnLeft# = rectangle#(frm#, 8, btnY, btnW, btnH)
  rectangle_fill#(btnLeft#, "#1a2a3a")
  rectangle_stroke#(btnLeft#, "#3366aa")
  rectangle_strokethickness#(btnLeft#, 2)
  rectangle_corners#(btnLeft#, 10, 10)
  rectangle_hittest#(btnLeft#, 1)
  rectangle_onmousedown#(btnLeft#, "OnBtnLeftDown")
  rectangle_onmouseup#(btnLeft#, "OnBtnLeftUp")

  let lblBtnL# = label#(frm#, "< LEFT")
  label_autosize#(lblBtnL#, 0)
  label_move#(lblBtnL#, 8, btnY)
  label_fontsize#(lblBtnL#, 16)
  label_fontcolor#(lblBtnL#, "#6699cc")
  label_bold#(lblBtnL#, 1)
  label_size#(lblBtnL#, btnW, btnH)
  label_textalign#(lblBtnL#, 0)
  label_vertalign#(lblBtnL#, 0)
  label_hittest#(lblBtnL#, 0)

  let btnFire# = rectangle#(frm#, GAME_W / 3 + 2, btnY, btnW + 8, btnH)
  rectangle_fill#(btnFire#, "#331100")
  rectangle_stroke#(btnFire#, "#ff4400")
  rectangle_strokethickness#(btnFire#, 3)
  rectangle_corners#(btnFire#, 10, 10)
  rectangle_hittest#(btnFire#, 1)
  rectangle_onmousedown#(btnFire#, "OnBtnFireDown")
  rectangle_onmouseup#(btnFire#, "OnBtnFireUp")

  let lblBtnF# = label#(frm#, "FIRE!")
  label_autosize#(lblBtnF#, 0)
  label_move#(lblBtnF#, GAME_W / 3 + 2, btnY)
  label_fontsize#(lblBtnF#, 20)
  label_fontcolor#(lblBtnF#, "#ff4400")
  label_bold#(lblBtnF#, 1)
  label_size#(lblBtnF#, btnW + 8, btnH)
  label_textalign#(lblBtnF#, 0)
  label_vertalign#(lblBtnF#, 0)
  label_hittest#(lblBtnF#, 0)

  let btnRight# = rectangle#(frm#, GAME_W - btnW - 8, btnY, btnW, btnH)
  rectangle_fill#(btnRight#, "#1a2a3a")
  rectangle_stroke#(btnRight#, "#3366aa")
  rectangle_strokethickness#(btnRight#, 2)
  rectangle_corners#(btnRight#, 10, 10)
  rectangle_hittest#(btnRight#, 1)
  rectangle_onmousedown#(btnRight#, "OnBtnRightDown")
  rectangle_onmouseup#(btnRight#, "OnBtnRightUp")

  let lblBtnR# = label#(frm#, "RIGHT >")
  label_autosize#(lblBtnR#, 0)
  label_move#(lblBtnR#, GAME_W - btnW - 8, btnY)
  label_fontsize#(lblBtnR#, 16)
  label_fontcolor#(lblBtnR#, "#6699cc")
  label_bold#(lblBtnR#, 1)
  label_size#(lblBtnR#, btnW, btnH)
  label_textalign#(lblBtnR#, 0)
  label_vertalign#(lblBtnR#, 0)
  label_hittest#(lblBtnR#, 0)
end if

' --- Center message line 1 (created LAST for Z-order) ---
let lblMsg# = label#(frm#, "")
label_autosize#(lblMsg#, 0)
label_fontsize#(lblMsg#, 24)
label_fontcolor#(lblMsg#, "#ffffff")
label_bold#(lblMsg#, 1)
label_align#(lblMsg#, 14)
label_height#(lblMsg#, 40)
label_y#(lblMsg#, cint(PLAY_H / 2 - 20))
label_textalign#(lblMsg#, 0)

let lblMsg2# = label#(frm#, "")
label_autosize#(lblMsg2#, 0)
label_fontsize#(lblMsg2#, 20)
label_fontcolor#(lblMsg2#, "#ffffff")
label_bold#(lblMsg2#, 1)
label_align#(lblMsg2#, 14)
label_height#(lblMsg2#, 36)
label_y#(lblMsg2#, cint(PLAY_H / 2 + 20))
label_textalign#(lblMsg2#, 0)

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
form_onkeyup#(frm#, "OnKeyUp")
form_show(frm#)

' ============================================================
'  ALIEN PART CREATION FUNCTIONS
'  Each creates child shapes inside the container.
'  Positions are relative to the container origin.
' ============================================================

function CreateSquidParts(cont#, aw, ah) local b#, el#, er#, pl#, pr#, al#, ar#, bw, bh, bx, by, ex, ey, ex2, antW, antH
  ' --- Body: tall narrow ellipse (magenta/red) ---
  bw = cint(aw * 0.65)
  bh = cint(ah * 0.75)
  bx = cint((aw - bw) / 2)
  by = cint(ah - bh) + 2
  let b# = ellipse#(cont#, bx, by, bw, bh)
  ellipse_fill#(b#, "#ff2266")
  ellipse_stroke#(b#, "#cc1144")
  ellipse_strokethickness#(b#, 1)
  ellipse_hittest#(b#, 0)

  ' --- Left eye ---
  ex = bx + cint(bw * 0.2)
  ey = by + cint(bh * 0.2)
  let el# = ellipse#(cont#, ex, ey, EYE_SZ, EYE_SZ)
  ellipse_fill#(el#, "#ffffff")
  ellipse_strokenone#(el#)
  ellipse_hittest#(el#, 0)
  let pl# = ellipse#(cont#, ex + cint(EYE_SZ * 0.35), ey + cint(EYE_SZ * 0.2), PUPIL_SZ, PUPIL_SZ)
  ellipse_fill#(pl#, "#000000")
  ellipse_strokenone#(pl#)
  ellipse_hittest#(pl#, 0)

  ' --- Right eye ---
  ex2 = bx + cint(bw * 0.8) - EYE_SZ
  let er# = ellipse#(cont#, ex2, ey, EYE_SZ, EYE_SZ)
  ellipse_fill#(er#, "#ffffff")
  ellipse_strokenone#(er#)
  ellipse_hittest#(er#, 0)
  let pr# = ellipse#(cont#, ex2 + cint(EYE_SZ * 0.35), ey + cint(EYE_SZ * 0.2), PUPIL_SZ, PUPIL_SZ)
  ellipse_fill#(pr#, "#000000")
  ellipse_strokenone#(pr#)
  ellipse_hittest#(pr#, 0)

  ' --- Left antenna ---
  antW = cint(aw * 0.08)
  if antW < 2 then antW = 2
  antH = cint(ah * 0.35)
  let al# = rectangle#(cont#, bx + cint(bw * 0.25), -cint(antH * 0.5), antW, antH)
  rectangle_fill#(al#, "#ff4488")
  rectangle_strokenone#(al#)
  rectangle_corners#(al#, 2, 2)
  rectangle_rotation#(al#, -15)
  rectangle_hittest#(al#, 0)

  ' --- Right antenna ---
  let ar# = rectangle#(cont#, bx + cint(bw * 0.75) - antW, -cint(antH * 0.5), antW, antH)
  rectangle_fill#(ar#, "#ff4488")
  rectangle_strokenone#(ar#)
  rectangle_corners#(ar#, 2, 2)
  rectangle_rotation#(ar#, 15)
  rectangle_hittest#(ar#, 0)
end function

function CreateCrabParts(cont#, aw, ah) local b#, el#, er#, pl#, pr#, cl#, cr#, bw, bh, bx, by, ex, ey, ex2, clawW, clawH
  ' --- Body: wide rounded rectangle (orange) ---
  bw = cint(aw * 0.75)
  bh = cint(ah * 0.7)
  bx = cint((aw - bw) / 2)
  by = cint((ah - bh) / 2) + 2
  let b# = rectangle#(cont#, bx, by, bw, bh)
  rectangle_fill#(b#, "#ff8800")
  rectangle_stroke#(b#, "#cc6600")
  rectangle_strokethickness#(b#, 1)
  rectangle_corners#(b#, cint(bh * 0.35), cint(bh * 0.35))
  rectangle_hittest#(b#, 0)

  ' --- Left eye ---
  ex = bx + cint(bw * 0.18)
  ey = by + cint(bh * 0.15)
  let el# = ellipse#(cont#, ex, ey, EYE_SZ, EYE_SZ)
  ellipse_fill#(el#, "#ffffff")
  ellipse_strokenone#(el#)
  ellipse_hittest#(el#, 0)
  let pl# = ellipse#(cont#, ex + cint(EYE_SZ * 0.35), ey + cint(EYE_SZ * 0.2), PUPIL_SZ, PUPIL_SZ)
  ellipse_fill#(pl#, "#000000")
  ellipse_strokenone#(pl#)
  ellipse_hittest#(pl#, 0)

  ' --- Right eye ---
  ex2 = bx + cint(bw * 0.82) - EYE_SZ
  let er# = ellipse#(cont#, ex2, ey, EYE_SZ, EYE_SZ)
  ellipse_fill#(er#, "#ffffff")
  ellipse_strokenone#(er#)
  ellipse_hittest#(er#, 0)
  let pr# = ellipse#(cont#, ex2 + cint(EYE_SZ * 0.35), ey + cint(EYE_SZ * 0.2), PUPIL_SZ, PUPIL_SZ)
  ellipse_fill#(pr#, "#000000")
  ellipse_strokenone#(pr#)
  ellipse_hittest#(pr#, 0)

  ' --- Left claw ---
  clawW = cint(aw * 0.18)
  clawH = cint(ah * 0.4)
  let cl# = rectangle#(cont#, -cint(clawW * 0.4), by + cint(bh * 0.2), clawW, clawH)
  rectangle_fill#(cl#, "#ffaa33")
  rectangle_strokenone#(cl#)
  rectangle_corners#(cl#, 3, 3)
  rectangle_rotation#(cl#, -10)
  rectangle_hittest#(cl#, 0)

  ' --- Right claw ---
  let cr# = rectangle#(cont#, aw - cint(clawW * 0.6), by + cint(bh * 0.2), clawW, clawH)
  rectangle_fill#(cr#, "#ffaa33")
  rectangle_strokenone#(cr#)
  rectangle_corners#(cr#, 3, 3)
  rectangle_rotation#(cr#, 10)
  rectangle_hittest#(cr#, 0)
end function

function CreateOctoParts(cont#, aw, ah) local b#, el#, er#, pl#, pr#, t1#, t2#, t3#, bw, bh, bx, by, ex, ey, ex2, tentW, tentH, tentY
  ' --- Body: wide round ellipse (cyan/teal) ---
  bw = cint(aw * 0.82)
  bh = cint(ah * 0.65)
  bx = cint((aw - bw) / 2)
  by = 2
  let b# = ellipse#(cont#, bx, by, bw, bh)
  ellipse_fill#(b#, "#00ccbb")
  ellipse_stroke#(b#, "#009988")
  ellipse_strokethickness#(b#, 1)
  ellipse_hittest#(b#, 0)

  ' --- Left eye ---
  ex = bx + cint(bw * 0.2)
  ey = by + cint(bh * 0.2)
  let el# = ellipse#(cont#, ex, ey, EYE_SZ, EYE_SZ)
  ellipse_fill#(el#, "#ffffff")
  ellipse_strokenone#(el#)
  ellipse_hittest#(el#, 0)
  let pl# = ellipse#(cont#, ex + cint(EYE_SZ * 0.35), ey + cint(EYE_SZ * 0.2), PUPIL_SZ, PUPIL_SZ)
  ellipse_fill#(pl#, "#000000")
  ellipse_strokenone#(pl#)
  ellipse_hittest#(pl#, 0)

  ' --- Right eye ---
  ex2 = bx + cint(bw * 0.8) - EYE_SZ
  let er# = ellipse#(cont#, ex2, ey, EYE_SZ, EYE_SZ)
  ellipse_fill#(er#, "#ffffff")
  ellipse_strokenone#(er#)
  ellipse_hittest#(er#, 0)
  let pr# = ellipse#(cont#, ex2 + cint(EYE_SZ * 0.35), ey + cint(EYE_SZ * 0.2), PUPIL_SZ, PUPIL_SZ)
  ellipse_fill#(pr#, "#000000")
  ellipse_strokenone#(pr#)
  ellipse_hittest#(pr#, 0)

  ' --- Tentacle stubs (3 small rects below body) ---
  tentW = cint(aw * 0.12)
  if tentW < 3 then tentW = 3
  tentH = cint(ah * 0.35)
  tentY = by + bh - 3

  let t1# = rectangle#(cont#, cint(aw * 0.2), tentY, tentW, tentH)
  rectangle_fill#(t1#, "#00aa99")
  rectangle_strokenone#(t1#)
  rectangle_corners#(t1#, 2, 2)
  rectangle_hittest#(t1#, 0)

  let t2# = rectangle#(cont#, cint(aw * 0.5 - tentW / 2), tentY, tentW, tentH)
  rectangle_fill#(t2#, "#00aa99")
  rectangle_strokenone#(t2#)
  rectangle_corners#(t2#, 2, 2)
  rectangle_hittest#(t2#, 0)

  let t3# = rectangle#(cont#, cint(aw * 0.8 - tentW), tentY, tentW, tentH)
  rectangle_fill#(t3#, "#00aa99")
  rectangle_strokenone#(t3#)
  rectangle_corners#(t3#, 2, 2)
  rectangle_hittest#(t3#, 0)
end function

' ============================================================
'  KEYBOARD EVENT HANDLERS (Desktop)
' ============================================================

function OnKeyDown(sender#, keyCode, keyChar$, shiftState$)
  if keyCode = 37 then
    let moveL = 1
  end if
  if keyCode = 39 then
    let moveR = 1
  end if
  if keyCode = 38 then
    if running = 0 then
      if gameOver = 1 then
        ResetGame()
      end if
      StartWave()
    else
      FirePlayerBullet()
    end if
  end if
end function

function OnKeyUp(sender#, keyCode, keyChar$, shiftState$)
  if keyCode = 37 then
    let moveL = 0
  end if
  if keyCode = 39 then
    let moveR = 0
  end if
end function

' ============================================================
'  TOUCH EVENT HANDLERS
' ============================================================

function OnTouchDown(sender#, btn, mx, my, shift$)
  let touchActive = 1
  MoveShipTo(mx)
  if running = 0 then
    if gameOver = 1 then
      ResetGame()
    end if
    StartWave()
  end if
end function

function OnTouchUp(sender#, btn, mx, my, shift$)
  let touchActive = 0
end function

function OnTouchMove(sender#, mx, my, shift$)
  if touchActive = 1 then
    MoveShipTo(mx)
  end if
end function

' ============================================================
'  MOBILE BUTTON EVENT HANDLERS
' ============================================================

function OnBtnLeftDown(sender#, btn, mx, my, shift$)
  let moveL = 1
  if IS_MOBILE = 1 then
    rectangle_fill#(btnLeft#, "#2a4a6a")
  end if
  if running = 0 then
    if gameOver = 1 then ResetGame()
    StartWave()
  end if
end function

function OnBtnLeftUp(sender#, btn, mx, my, shift$)
  let moveL = 0
  if IS_MOBILE = 1 then rectangle_fill#(btnLeft#, "#1a2a3a")
end function

function OnBtnFireDown(sender#, btn, mx, my, shift$)
  if IS_MOBILE = 1 then rectangle_fill#(btnFire#, "#662200")
  if running = 0 then
    if gameOver = 1 then ResetGame()
    StartWave()
  else
    FirePlayerBullet()
  end if
end function

function OnBtnFireUp(sender#, btn, mx, my, shift$)
  if IS_MOBILE = 1 then rectangle_fill#(btnFire#, "#331100")
end function

function OnBtnRightDown(sender#, btn, mx, my, shift$)
  let moveR = 1
  if IS_MOBILE = 1 then rectangle_fill#(btnRight#, "#2a4a6a")
  if running = 0 then
    if gameOver = 1 then ResetGame()
    StartWave()
  end if
end function

function OnBtnRightUp(sender#, btn, mx, my, shift$)
  let moveR = 0
  if IS_MOBILE = 1 then rectangle_fill#(btnRight#, "#1a2a3a")
end function

' ============================================================
'  GAME FUNCTIONS
' ============================================================

function MoveShipTo(targetX) local newX
  newX = cint(targetX - SHIP_W / 2)
  if newX < 10 then newX = 10
  if newX > GAME_W - SHIP_W - 10 then newX = GAME_W - SHIP_W - 10
  let shipX = newX
  rectangle_x#(shipCont#, shipX)
end function

function ResetGame() local i, s#, ex#
  let score = 0
  let lives = 3
  let wave = 0
  let gameOver = 0
  label_text#(lblScore#, "SCORE: 0")
  label_text#(lblLives#, "LIVES: 3")
  for i = 1 to NUM_SHIELDS
    shieldHealth#[i] = 4
    s# = shieldRect##[i]
    rectangle_fill#(s#, "#00cc00")
    rectangle_visible#(s#, 0)
  next
  for i = 1 to MAX_EXPLOSIONS
    explTimer#[i] = 0
    ex# = explObj##[i]
    ellipse_visible#(ex#, 0)
  next
  ' Sound: silence any residual end-game audio when restarting
  if soundInitDone = 1 then
    media_stop(sndGameOver#)
    media_stop(sndWaveClear#)
  end if
end function

function StartWave() local i, a#, s#, ax, ay, row, col, idx
  let wave = wave + 1
  let running = 1
  let alienBaseX = 40
  let alienBaseY = TOP_BAR + 40 + (wave - 1) * 20
  if alienBaseY > TOP_BAR + 140 then alienBaseY = TOP_BAR + 140
  let alienDirX = 1
  let alienMoveTimer = 0
  let alienShootTimer = 0

  let alienMoveDelay = 64 - wave * 3
  if alienMoveDelay < 8 then alienMoveDelay = 8
  let alienShootDelay = 70 - wave * 5
  if alienShootDelay < 25 then alienShootDelay = 25

  let aliensAlive = TOTAL_ALIENS
  for row = 0 to ALIEN_ROWS - 1
    for col = 0 to ALIEN_COLS - 1
      idx = row * ALIEN_COLS + col + 1
      ax = alienBaseX + col * (ALIEN_W + ALIEN_GAP_X)
      ay = alienBaseY + row * (ALIEN_H + ALIEN_GAP_Y)
      alienX#[idx] = ax
      alienY#[idx] = ay
      alienAlive#[idx] = 1
      a# = alienRect##[idx]
      rectangle_move#(a#, ax, ay)
      rectangle_visible#(a#, 1)
    next
  next

  for i = 1 to NUM_SHIELDS
    s# = shieldRect##[i]
    rectangle_visible#(s#, 1)
  next

  label_text#(lblWave#, "WAVE: " + stri$(wave))
  label_text#(lblMsg#, "")
  label_text#(lblMsg2#, "")
  label_fontcolor#(lblMsg#, "#ffffff")
  label_fontcolor#(lblMsg2#, "#ffffff")
end function

function FirePlayerBullet() local pb#
  if pbActive#[1] = 1 then return 0
  pbX#[1] = shipX + SHIP_W / 2 - 2
  pbY#[1] = SHIP_Y - TURRET_H
  pbActive#[1] = 1
  pb# = pbRect##[1]
  rectangle_move#(pb#, pbX#[1], pbY#[1])
  rectangle_visible#(pb#, 1)
  ' Sound: player laser zap
  if soundInitDone = 1 then
    media_stop(sndShoot#)
    media_play(sndShoot#)
  end if
end function

function FireAlienBullet() local i, idx, ax, ay, ab#, attempts, found
  attempts = 0
  found = 0
  while attempts < 20
    idx = 1 + cint(rnd() * TOTAL_ALIENS)
    if idx > TOTAL_ALIENS then idx = TOTAL_ALIENS
    if alienAlive#[idx] = 1 then
      found = 1
      attempts = 100
    end if
    attempts = attempts + 1
  end while
  if found = 0 then return 0

  ax = alienX#[idx] + ALIEN_W / 2 - 2
  ay = alienY#[idx] + ALIEN_H

  for i = 1 to MAX_ALIEN_BULLETS
    if abActive#[i] = 0 then
      abX#[i] = ax
      abY#[i] = ay
      abActive#[i] = 1
      ab# = abRect##[i]
      rectangle_move#(ab#, ax, ay)
      rectangle_visible#(ab#, 1)
      return 0
    end if
  next
end function

function TriggerExplosion(ex, ey) local i, e#
  for i = 1 to MAX_EXPLOSIONS
    if explTimer#[i] = 0 then
      explTimer#[i] = EXPLODE_TIME
      e# = explObj##[i]
      ellipse_move#(e#, ex, ey)
      ellipse_visible#(e#, 1)
      ' Sound: cycle explosion pool so rapid kills can overlap
      if soundInitDone = 1 then
        let explodeSndIdx = explodeSndIdx + 1
        if explodeSndIdx > 3 then let explodeSndIdx = 1
        media_stop(sndExplode##[explodeSndIdx])
        media_play(sndExplode##[explodeSndIdx])
      end if
      return 0
    end if
  next
end function

function UpdateShieldColor(idx) local h, s#, col$
  h = shieldHealth#[idx]
  s# = shieldRect##[idx]
  if h = 4 then
    col$ = "#00cc00"
  else if h = 3 then
    col$ = "#88aa00"
  else if h = 2 then
    col$ = "#aa6600"
  else if h = 1 then
    col$ = "#aa3300"
  else
    col$ = "#000000"
    rectangle_visible#(s#, 0)
  end if
  rectangle_fill#(s#, col$)
end function

function GetLeftmostAlien() local i, minX
  minX = 9999
  for i = 1 to TOTAL_ALIENS
    if alienAlive#[i] = 1 then
      if alienX#[i] < minX then minX = alienX#[i]
    end if
  next
  return minX
end function

function GetRightmostAlien() local i, maxX
  maxX = 0
  for i = 1 to TOTAL_ALIENS
    if alienAlive#[i] = 1 then
      if alienX#[i] + ALIEN_W > maxX then maxX = alienX#[i] + ALIEN_W
    end if
  next
  return maxX
end function

function GetLowestAlien() local i, maxY
  maxY = 0
  for i = 1 to TOTAL_ALIENS
    if alienAlive#[i] = 1 then
      if alienY#[i] + ALIEN_H > maxY then maxY = alienY#[i] + ALIEN_H
    end if
  next
  return maxY
end function

' ============================================================
'  SOUND FUNCTIONS
' ============================================================
'
'  Required audio files at https://plan9basic.com/assets/sounds/invaders/ :
'    shoot.wav      / .mp3 / .ogg  (~0.2s laser zap)
'    explode.wav    / .mp3 / .ogg  (~0.3s alien destruction pop)
'    player_hit.wav / .mp3 / .ogg  (~0.5s ship damage / death)
'    game_over.wav  / .mp3 / .ogg  (~1.5s defeat sting)
'    wave_clear.wav / .mp3 / .ogg  (~1.5s triumphant fanfare)
'    march.wav      / .mp3 / .ogg  (~0.1s short percussive click — the iconic beat)
'
'  Explosion pool: 3 players loaded with the same clip are cycled in round-robin
'  order so rapid successive alien destructions can overlap.

function InitSounds() local i
  ' --- Player laser ---
  sndShoot# = media_player#()
  media_load#(sndShoot#, SOUND_BASE$ + "shoot." + SOUND_EXT$)
  media_volume#(sndShoot#, 0.70)

  ' --- Alien explosion pool: 3 players with the same clip ---
  sndExplode# = pdim#(3)
  for i = 1 to 3
    sndExplode##[i] = media_player#()
    media_load#(sndExplode##[i], SOUND_BASE$ + "explode." + SOUND_EXT$)
    media_volume#(sndExplode##[i], 0.80)
  next

  ' --- Player ship hit ---
  sndPlayerHit# = media_player#()
  media_load#(sndPlayerHit#, SOUND_BASE$ + "player_hit." + SOUND_EXT$)
  media_volume#(sndPlayerHit#, 0.90)

  ' --- Game over sting ---
  sndGameOver# = media_player#()
  media_load#(sndGameOver#, SOUND_BASE$ + "game_over." + SOUND_EXT$)
  media_volume#(sndGameOver#, 0.90)

  ' --- Wave cleared fanfare ---
  sndWaveClear# = media_player#()
  media_load#(sndWaveClear#, SOUND_BASE$ + "wave_clear." + SOUND_EXT$)
  media_volume#(sndWaveClear#, 0.80)

  ' --- Iconic alien march beat (very short click, re-triggered each step) ---
  sndMarch# = media_player#()
  media_load#(sndMarch#, SOUND_BASE$ + "march." + SOUND_EXT$)
  media_volume#(sndMarch#, 0.60)
end function

function PlayerHit() local i, pb#, ab#
  let lives = lives - 1
  label_text#(lblLives#, "LIVES: " + stri$(lives))
  ' Sound: ship hit
  if soundInitDone = 1 then
    media_stop(sndPlayerHit#)
    media_play(sndPlayerHit#)
  end if

  for i = 1 to MAX_PLAYER_BULLETS
    pbActive#[i] = 0
    pb# = pbRect##[i]
    rectangle_visible#(pb#, 0)
  next
  for i = 1 to MAX_ALIEN_BULLETS
    abActive#[i] = 0
    ab# = abRect##[i]
    rectangle_visible#(ab#, 0)
  next

  let shipX = (GAME_W - SHIP_W) / 2
  rectangle_move#(shipCont#, shipX, SHIP_Y)

  if lives <= 0 then
    let running = 0
    let gameOver = 1
    ' Sound: defeat sting
    if soundInitDone = 1 then
      media_stop(sndGameOver#)
      media_play(sndGameOver#)
    end if
    label_text#(lblMsg#, "GAME OVER")
    label_fontcolor#(lblMsg#, "#ff3300")
    if IS_MOBILE = 1 then
      label_text#(lblMsg2#, "Tap to Retry")
    else
      label_text#(lblMsg2#, "Press UP to Retry")
    end if
    label_fontcolor#(lblMsg2#, "#ff3300")
  end if
end function

' ============================================================
'  MAIN GAME LOOP
' ============================================================

function GameLoop(sender#) local i, j, bx, by, ax, ay, sx, needDrop, pb#, ab#, a#, lowestY, e#
  ' On the very first tick the Android event loop (Looper) is guaranteed to be
  ' running, which is required for TMediaPlayer to work correctly on Android.
  if soundInitDone = 0 then
    let soundInitDone = 1
    InitSounds()
    return 0
  end if
  if running = 0 then return 0

  ' ========================
  '  PLAYER MOVEMENT
  ' ========================
  if moveL = 1 then
    let shipX = shipX - SHIP_SPD
    if shipX < 10 then shipX = 10
    rectangle_x#(shipCont#, shipX)
  end if
  if moveR = 1 then
    let shipX = shipX + SHIP_SPD
    if shipX > GAME_W - SHIP_W - 10 then shipX = GAME_W - SHIP_W - 10
    rectangle_x#(shipCont#, shipX)
  end if

  ' ========================
  '  ALIEN MOVEMENT
  ' ========================
  alienMoveTimer = alienMoveTimer + 1
  if alienMoveTimer >= alienMoveDelay then
    alienMoveTimer = 0

    needDrop = 0
    if alienDirX > 0 then
      if GetRightmostAlien() >= GAME_W - 20 then needDrop = 1
    else
      if GetLeftmostAlien() <= 20 then needDrop = 1
    end if

    for i = 1 to TOTAL_ALIENS
      if alienAlive#[i] = 1 then
        if needDrop = 1 then
          alienY#[i] = alienY#[i] + 15
        else
          alienX#[i] = alienX#[i] + alienDirX * 10
        end if
        a# = alienRect##[i]
        rectangle_move#(a#, alienX#[i], alienY#[i])
      end if
    next

    if needDrop = 1 then let alienDirX = 0 - alienDirX
    ' Sound: iconic alien march step
    if soundInitDone = 1 then
      media_stop(sndMarch#)
      media_play(sndMarch#)
    end if
  end if

  ' ========================
  '  ALIEN SHOOTING
  ' ========================
  alienShootTimer = alienShootTimer + 1
  if alienShootTimer >= alienShootDelay then
    alienShootTimer = 0
    FireAlienBullet()
  end if

  ' ========================
  '  UPDATE EXPLOSIONS
  ' ========================
  for i = 1 to MAX_EXPLOSIONS
    if explTimer#[i] > 0 then
      explTimer#[i] = explTimer#[i] - 1
      if explTimer#[i] = 0 then
        e# = explObj##[i]
        ellipse_visible#(e#, 0)
      end if
    end if
  next

  ' ========================
  '  UPDATE PLAYER BULLETS
  ' ========================
  for i = 1 to MAX_PLAYER_BULLETS
    if pbActive#[i] = 1 then
      pbY#[i] = pbY#[i] - PLAYER_BULLET_SPD
      bx = pbX#[i]
      by = pbY#[i]

      if by < TOP_BAR then
        pbActive#[i] = 0
        pb# = pbRect##[i]
        rectangle_visible#(pb#, 0)
      else
        pb# = pbRect##[i]
        rectangle_y#(pb#, by)

        ' Check hit aliens
        for j = 1 to TOTAL_ALIENS
          if alienAlive#[j] = 1 then
            ax = alienX#[j]
            ay = alienY#[j]
            if bx + 4 > ax then
              if bx < ax + ALIEN_W then
                if by < ay + ALIEN_H then
                  if by + 14 > ay then
                    alienAlive#[j] = 0
                    let aliensAlive = aliensAlive - 1
                    let score = score + alienPoints#[j]
                    label_text#(lblScore#, "SCORE: " + stri$(score))
                    a# = alienRect##[j]
                    rectangle_visible#(a#, 0)
                    pbActive#[i] = 0
                    rectangle_visible#(pb#, 0)
                    TriggerExplosion(ax, ay)
                    if aliensAlive > 0 then
                      let alienMoveDelay = alienMoveDelay - 1
                      if alienMoveDelay < 3 then alienMoveDelay = 3
                    end if
                  end if
                end if
              end if
            end if
          end if
        next

        ' Check hit shields
        for j = 1 to NUM_SHIELDS
          if shieldHealth#[j] > 0 then
            sx = shieldX#[j]
            if bx + 4 > sx then
              if bx < sx + SHIELD_W then
                if by < SHIELD_Y + SHIELD_H then
                  if by + 14 > SHIELD_Y then
                    shieldHealth#[j] = shieldHealth#[j] - 1
                    UpdateShieldColor(j)
                    pbActive#[i] = 0
                    pb# = pbRect##[i]
                    rectangle_visible#(pb#, 0)
                  end if
                end if
              end if
            end if
          end if
        next
      end if
    end if
  next

  ' ========================
  '  UPDATE ALIEN BULLETS
  ' ========================
  for i = 1 to MAX_ALIEN_BULLETS
    if abActive#[i] = 1 then
      abY#[i] = abY#[i] + ALIEN_BULLET_SPD
      bx = abX#[i]
      by = abY#[i]

      if by > PLAY_H then
        abActive#[i] = 0
        ab# = abRect##[i]
        rectangle_visible#(ab#, 0)
      else
        ab# = abRect##[i]
        rectangle_y#(ab#, by)

        if by + 10 > SHIP_Y then
          if by < SHIP_Y + SHIP_H then
            if bx + 4 > shipX then
              if bx < shipX + SHIP_W then
                abActive#[i] = 0
                rectangle_visible#(ab#, 0)
                PlayerHit()
                return 0
              end if
            end if
          end if
        end if

        for j = 1 to NUM_SHIELDS
          if shieldHealth#[j] > 0 then
            sx = shieldX#[j]
            if bx + 4 > sx then
              if bx < sx + SHIELD_W then
                if by + 10 > SHIELD_Y then
                  if by < SHIELD_Y + SHIELD_H then
                    shieldHealth#[j] = shieldHealth#[j] - 1
                    UpdateShieldColor(j)
                    abActive#[i] = 0
                    ab# = abRect##[i]
                    rectangle_visible#(ab#, 0)
                  end if
                end if
              end if
            end if
          end if
        next
      end if
    end if
  next

  ' ========================
  '  CHECK WIN/LOSE
  ' ========================
  lowestY = GetLowestAlien()
  if lowestY >= SHIP_Y - 10 then
    let running = 0
    let gameOver = 1
    ' Sound: game over sting (aliens reached the ground)
    if soundInitDone = 1 then
      media_stop(sndGameOver#)
      media_play(sndGameOver#)
    end if
    label_text#(lblMsg#, "INVADED! GAME OVER")
    label_fontcolor#(lblMsg#, "#ff3300")
    if IS_MOBILE = 1 then
      label_text#(lblMsg2#, "Tap to Retry")
    else
      label_text#(lblMsg2#, "Press UP to Retry")
    end if
    label_fontcolor#(lblMsg2#, "#ff3300")
    return 0
  end if

  if aliensAlive <= 0 then
    let running = 0
    ' Sound: wave cleared fanfare
    if soundInitDone = 1 then
      media_stop(sndWaveClear#)
      media_play(sndWaveClear#)
    end if
    label_text#(lblMsg#, "WAVE CLEAR!")
    label_fontcolor#(lblMsg#, "#00ff00")
    if IS_MOBILE = 1 then
      label_text#(lblMsg2#, "Tap for Next Wave")
    else
      label_text#(lblMsg2#, "Press UP for Next Wave")
    end if
    label_fontcolor#(lblMsg2#, "#00ff00")
  end if
end function
