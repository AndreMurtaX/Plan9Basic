' ============================================================
'  MISSILE COMMAND - A Classic Arcade Game
'  Written in Plan9Basic
' ============================================================
'
'  Controls (Desktop):
'    Mouse Move   -  Aim crosshair
'    Left Click   -  Fire missile from nearest base
'    Up Arrow     -  Start game / Next wave / Restart
'
'  Controls (Mobile / Touch):
'    Tap          -  Aim + fire at touched location
'    Tap          -  Start / Next wave / Restart (when idle)
'
'  Scoring:
'    Enemy destroyed = 25 points
'    City bonus      = 100 points per surviving city per wave
'
'  Objective:
'    Defend your cities from incoming enemy missiles!
'    Click/tap to fire counter-missiles that explode at target.
'    Explosions destroy any enemy missiles they touch.
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
let SOUND_BASE$ = "https://plan9basic.com/assets/sounds/missile/"
let SOUND_EXT$ = "mp3"
if instr(PLATFORM$, "Windows") >= 0 then SOUND_EXT$ = "wav"
if instr(PLATFORM$, "Linux") >= 0 then SOUND_EXT$ = "ogg"
if instr(PLATFORM$, "Android") >= 0 then SOUND_EXT$ = "ogg"

' --- Game Area Constants ---
let GAME_W = 800
let GAME_H = 600
let GROUND_Y = 520
let SKY_TOP = 40

if IS_MOBILE = 1 then
  let GAME_W = form_screenwidth()
  let GAME_H = form_screenheight()
  let SKY_TOP = 50
  let GROUND_Y = GAME_H - 80
end if

' --- City Constants ---
let NUM_CITIES = 6
let CITY_W = 50
let CITY_H = 35

if IS_MOBILE = 1 then
  let CITY_W = cint(GAME_W * 0.07)
  let CITY_H = 30
end if

' --- Base Constants ---
let NUM_BASES = 3
let BASE_W = 40
let BASE_H = 20
let MAX_AMMO = 10

if IS_MOBILE = 1 then
  let BASE_W = cint(GAME_W * 0.06)
end if

' --- Missile Constants ---
let MAX_ENEMY = 20
let MAX_PLAYER = 10
let ENEMY_BASE_SPD = 0.6
let ENEMY_SPD_INC = 0.15
let ENEMY_MAX_SPD = 3.0
let enemySpeed = 0.6
let PLAYER_SPD = 8

' --- Explosion Constants ---
let MAX_EXPLODE = 15
let EXP_MAX_R = 50
let EXP_GROW = 2.0
let EXP_SHRINK = 1.5

if IS_MOBILE = 1 then
  let EXP_MAX_R = 55
end if

' --- Game State ---
let score = 0
let wave = 0
let running = 0
let gameOver = 0
let mouseX = GAME_W / 2
let mouseY = GAME_H / 2
let enemiesToSpawn = 0
let spawnTimer = 0
let spawnDelay = 90

' --- Object Pointers ---
let frm# = pointer#(0)
let gameArea# = pointer#(0)
let ground# = pointer#(0)
let crossH# = pointer#(0)
let crossV# = pointer#(0)
let lblScore# = pointer#(0)
let lblWave# = pointer#(0)
let lblAmmo# = pointer#(0)
let lblMsg# = pointer#(0)
let lblMsg2# = pointer#(0)
let tmr# = pointer#(0)

' --- Sound Players ---
'     sndExplode# is a pdim pointer array [1..3] — a pool of 3 players
'     so multiple detonations can overlap without cutting each other off.
let sndLaunch#   = pointer#(0)
let sndExplode#  = pointer#(0)
let sndCityHit#  = pointer#(0)
let sndWaveStart# = pointer#(0)
let sndWaveClear# = pointer#(0)
let sndGameOver# = pointer#(0)
let explodeIdx   = 0   ' cycles 1-3 through the explosion pool
let soundInitDone = 0  ' set to 1 after InitSounds() completes on first GameLoop tick

' --- City Arrays (1-based) ---
let cityX# = pointer#(0)
let cityAlive# = pointer#(0)
let cityRect# = pointer#(0)

' --- Base Arrays (1-based) ---
let baseX# = pointer#(0)
let baseAmmo# = pointer#(0)
let baseRect# = pointer#(0)

' --- Enemy Missile Arrays (1-based) ---
let emX# = pointer#(0)
let emY# = pointer#(0)
let emDX# = pointer#(0)
let emDY# = pointer#(0)
let emActive# = pointer#(0)
let emHead# = pointer#(0)
let emTrailX# = pointer#(0)
let emTrailY# = pointer#(0)

' --- Player Missile Arrays (1-based) ---
let pmX# = pointer#(0)
let pmY# = pointer#(0)
let pmDX# = pointer#(0)
let pmDY# = pointer#(0)
let pmTargetX# = pointer#(0)
let pmTargetY# = pointer#(0)
let pmActive# = pointer#(0)
let pmHead# = pointer#(0)

' --- Explosion Arrays (1-based) ---
let expX# = pointer#(0)
let expY# = pointer#(0)
let expR# = pointer#(0)
let expGrow# = pointer#(0)
let expActive# = pointer#(0)
let expCircle# = pointer#(0)

' ============================================================
'  CREATE THE GAME WINDOW
' ============================================================

if IS_MOBILE = 1 then
  let frm# = form#("Missile Command", GAME_W, GAME_H)
else
  ' Add window frame compensation: ~16px for borders, ~39px for title bar
  let frm# = form#("Missile Command", GAME_W + 16, GAME_H + 39)
  form_position#(frm#, 4)
end if
form_fill#(frm#, "#000033")

' --- Clickable game area for mouse/touch tracking ---
let gameArea# = rectangle#(frm#, 0, 0, GAME_W, GAME_H)
rectangle_fill#(gameArea#, "#000022")
rectangle_strokenone#(gameArea#)
rectangle_hittest#(gameArea#, 1)
rectangle_onmousemove#(gameArea#, "OnMouseMove")
rectangle_onmousedown#(gameArea#, "OnMouseDown")

' --- Ground ---
let ground# = rectangle#(frm#, 0, GROUND_Y, GAME_W, GAME_H - GROUND_Y)
rectangle_fill#(ground#, "#553311")
rectangle_strokenone#(ground#)
rectangle_hittest#(ground#, 0)

' --- Score label ---
let lblScore# = label#(frm#, "SCORE: 0", 10, 8)
label_autosize#(lblScore#, 0)
label_fontsize#(lblScore#, 16)
label_fontcolor#(lblScore#, "#00ff00")
label_bold#(lblScore#, 1)
label_size#(lblScore#, 200, 25)

' --- Wave label ---
let lblWave# = label#(frm#, "WAVE: 0")
label_autosize#(lblWave#, 0)
label_move#(lblWave#, GAME_W / 2 - 50, 8)
label_fontsize#(lblWave#, 16)
label_fontcolor#(lblWave#, "#ffff00")
label_bold#(lblWave#, 1)
label_size#(lblWave#, 120, 25)

' --- Ammo label ---
let lblAmmo# = label#(frm#, "AMMO: 30")
label_autosize#(lblAmmo#, 0)
label_move#(lblAmmo#, GAME_W - 150, 8)
label_fontsize#(lblAmmo#, 16)
label_fontcolor#(lblAmmo#, "#ff8800")
label_bold#(lblAmmo#, 1)
label_size#(lblAmmo#, 140, 25)
label_textalign#(lblAmmo#, 2)

if IS_MOBILE = 1 then
  label_fontsize#(lblScore#, 17)
  label_fontsize#(lblWave#, 17)
  label_fontsize#(lblAmmo#, 17)
end if

' --- Crosshair (horizontal) ---
let crossH# = rectangle#(frm#, GAME_W / 2 - 15, GAME_H / 2 - 1, 30, 2)
rectangle_fill#(crossH#, "#00ffff")
rectangle_strokenone#(crossH#)
rectangle_hittest#(crossH#, 0)
rectangle_visible#(crossH#, 0)

' --- Crosshair (vertical) ---
let crossV# = rectangle#(frm#, GAME_W / 2 - 1, GAME_H / 2 - 15, 2, 30)
rectangle_fill#(crossV#, "#00ffff")
rectangle_strokenone#(crossV#)
rectangle_hittest#(crossV#, 0)
rectangle_visible#(crossV#, 0)

' ============================================================
'  CREATE CITIES
' ============================================================

let cityX# = dim#(NUM_CITIES)
let cityAlive# = dim#(NUM_CITIES)
let cityRect# = pdim#(NUM_CITIES)

' City positions: 3 left of center base, 3 right of center base
' Spread proportionally across the screen width
let cSpacing = cint(GAME_W / 8)
cityX#[1] = cSpacing - CITY_W / 2
cityX#[2] = cSpacing * 2 - CITY_W / 2
cityX#[3] = cSpacing * 3 - CITY_W / 2
cityX#[4] = cSpacing * 5 - CITY_W / 2
cityX#[5] = cSpacing * 6 - CITY_W / 2
cityX#[6] = cSpacing * 7 - CITY_W / 2

for i = 1 to NUM_CITIES
  cityAlive#[i] = 1
  let cx = cityX#[i]
  let c# = rectangle#(frm#, cx, GROUND_Y - CITY_H, CITY_W, CITY_H)
  rectangle_fill#(c#, "#4488ff")
  rectangle_stroke#(c#, "#6699ff")
  rectangle_strokethickness#(c#, 1)
  rectangle_corners#(c#, 3, 3)
  rectangle_hittest#(c#, 0)
  cityRect##[i] = c#
next

' ============================================================
'  CREATE MISSILE BASES
' ============================================================

let baseX# = dim#(NUM_BASES)
let baseAmmo# = dim#(NUM_BASES)
let baseRect# = pdim#(NUM_BASES)

' Base positions: left, center, right (between city groups)
baseX#[1] = cint(GAME_W * 0.125)
baseX#[2] = cint(GAME_W * 0.5)
baseX#[3] = cint(GAME_W * 0.875)

for i = 1 to NUM_BASES
  baseAmmo#[i] = MAX_AMMO
  let bx = baseX#[i]
  let b# = rectangle#(frm#, bx - BASE_W / 2, GROUND_Y - BASE_H, BASE_W, BASE_H)
  rectangle_fill#(b#, "#00cc00")
  rectangle_stroke#(b#, "#00ff00")
  rectangle_strokethickness#(b#, 2)
  rectangle_corners#(b#, 4, 4)
  rectangle_hittest#(b#, 0)
  baseRect##[i] = b#
next

' ============================================================
'  INITIALIZE ENEMY MISSILE ARRAYS
' ============================================================

let emX# = dim#(MAX_ENEMY)
let emY# = dim#(MAX_ENEMY)
let emDX# = dim#(MAX_ENEMY)
let emDY# = dim#(MAX_ENEMY)
let emActive# = dim#(MAX_ENEMY)
let emHead# = pdim#(MAX_ENEMY)
let emTrailX# = dim#(MAX_ENEMY)
let emTrailY# = dim#(MAX_ENEMY)

for i = 1 to MAX_ENEMY
  emActive#[i] = 0
  let eh# = ellipse#(frm#, 0, 0, 6, 6)
  ellipse_fill#(eh#, "#ff0000")
  ellipse_strokenone#(eh#)
  ellipse_hittest#(eh#, 0)
  ellipse_visible#(eh#, 0)
  emHead##[i] = eh#
next

' ============================================================
'  INITIALIZE PLAYER MISSILE ARRAYS
' ============================================================

let pmX# = dim#(MAX_PLAYER)
let pmY# = dim#(MAX_PLAYER)
let pmDX# = dim#(MAX_PLAYER)
let pmDY# = dim#(MAX_PLAYER)
let pmTargetX# = dim#(MAX_PLAYER)
let pmTargetY# = dim#(MAX_PLAYER)
let pmActive# = dim#(MAX_PLAYER)
let pmHead# = pdim#(MAX_PLAYER)

for i = 1 to MAX_PLAYER
  pmActive#[i] = 0
  let ph# = ellipse#(frm#, 0, 0, 8, 8)
  ellipse_fill#(ph#, "#00ff00")
  ellipse_strokenone#(ph#)
  ellipse_hittest#(ph#, 0)
  ellipse_visible#(ph#, 0)
  pmHead##[i] = ph#
next

' ============================================================
'  INITIALIZE EXPLOSION ARRAYS
' ============================================================

let expX# = dim#(MAX_EXPLODE)
let expY# = dim#(MAX_EXPLODE)
let expR# = dim#(MAX_EXPLODE)
let expGrow# = dim#(MAX_EXPLODE)
let expActive# = dim#(MAX_EXPLODE)
let expCircle# = pdim#(MAX_EXPLODE)

for i = 1 to MAX_EXPLODE
  expActive#[i] = 0
  let ec# = ellipse#(frm#, 0, 0, 20, 20)
  ellipse_fill#(ec#, "#ff8800")
  ellipse_strokenone#(ec#)
  ellipse_hittest#(ec#, 0)
  ellipse_visible#(ec#, 0)
  expCircle##[i] = ec#
next

' --- Center message line 1 (created LAST for Z-order) ---
let lblMsg# = label#(frm#, "")
label_autosize#(lblMsg#, 0)
label_fontsize#(lblMsg#, 24)
label_fontcolor#(lblMsg#, "#ffffff")
label_bold#(lblMsg#, 1)
label_align#(lblMsg#, 14)
label_height#(lblMsg#, 40)
label_y#(lblMsg#, cint(GROUND_Y / 2 - 20))
label_textalign#(lblMsg#, 0)

' --- Center message line 2 (sub-message / instruction) ---
let lblMsg2# = label#(frm#, "")
label_autosize#(lblMsg2#, 0)
label_fontsize#(lblMsg2#, 20)
label_fontcolor#(lblMsg2#, "#ffffff")
label_bold#(lblMsg2#, 1)
label_align#(lblMsg2#, 14)
label_height#(lblMsg2#, 36)
label_y#(lblMsg2#, cint(GROUND_Y / 2 + 20))
label_textalign#(lblMsg2#, 0)

if IS_MOBILE = 1 then
  label_text#(lblMsg#, "Tap to Start")
  label_fontsize#(lblMsg#, 26)
else
  label_text#(lblMsg#, "Press UP ARROW to Start")
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
'  EVENT HANDLERS
' ============================================================

' onmousemove: function(sender#, mx, my, shift$)
function OnMouseMove(sender#, mx, my, shift$)
  let mouseX = mx
  let mouseY = my
  ' Update crosshair
  rectangle_move#(crossH#, mx - 15, my - 1)
  rectangle_move#(crossV#, mx - 1, my - 15)
end function

' onmousedown: function(sender#, btn, mx, my, shift$)
function OnMouseDown(sender#, btn, mx, my, shift$) local i, best, bestDist, d, bx, totalAmmo
  ' Update crosshair to tap position (essential for mobile)
  let mouseX = mx
  let mouseY = my
  rectangle_move#(crossH#, mx - 15, my - 1)
  rectangle_move#(crossV#, mx - 1, my - 15)
  
  if running = 0 then
    ' Tap/click to start or restart when not running
    if gameOver = 1 then
      ResetGame()
    end if
    StartWave()
    return 0
  end if
  
  ' Left click (btn=0) or any tap - fire from nearest base with ammo
  best = 0
  bestDist = 9999
  for i = 1 to NUM_BASES
    if baseAmmo#[i] > 0 then
      bx = baseX#[i]
      d = abs(mx - bx)
      if d < bestDist then
        bestDist = d
        best = i
      end if
    end if
  next
  if best > 0 then
    FirePlayerMissile(baseX#[best], GROUND_Y - BASE_H, mx, my)
    baseAmmo#[best] = baseAmmo#[best] - 1
    UpdateAmmoDisplay()
  end if
end function

function OnKeyDown(sender#, keyCode, keyChar$, shiftState$)
  ' Up arrow = 38
  if keyCode = 38 then
    if running = 0 then
      if gameOver = 1 then
        ResetGame()
      end if
      StartWave()
    end if
  end if
end function

' ============================================================
'  GAME FUNCTIONS
' ============================================================

function UpdateAmmoDisplay() local i, total
  total = 0
  for i = 1 to NUM_BASES
    total = total + baseAmmo#[i]
  next
  label_text#(lblAmmo#, "AMMO: " + stri$(total))
end function

function ResetGame() local i, c#
  let score = 0
  let wave = 0
  let gameOver = 0
  let enemySpeed = ENEMY_BASE_SPD
  label_text#(lblScore#, "SCORE: 0")
  label_text#(lblWave#, "WAVE: 0")
  ' Restore cities
  for i = 1 to NUM_CITIES
    cityAlive#[i] = 1
    c# = cityRect##[i]
    rectangle_visible#(c#, 1)
  next
  ' Restore ammo
  for i = 1 to NUM_BASES
    baseAmmo#[i] = MAX_AMMO
  next
  UpdateAmmoDisplay()
  ' Sound: silence any residual end-game audio when restarting
  if soundInitDone = 1 then
    media_stop(sndGameOver#)
    media_stop(sndWaveClear#)
  end if
end function

function StartWave() local i, enemyCount, a#, s#
  let wave = wave + 1
  let running = 1
  let spawnTimer = 0
  enemyCount = 4 + wave * 2
  if enemyCount > MAX_ENEMY then
    enemyCount = MAX_ENEMY
  end if
  let enemiesToSpawn = enemyCount
  let spawnDelay = 100 - wave * 8
  if spawnDelay < 25 then
    spawnDelay = 25
  end if
  ' Increase missile speed with each wave
  let enemySpeed = ENEMY_BASE_SPD + wave * ENEMY_SPD_INC
  if enemySpeed > ENEMY_MAX_SPD then
    let enemySpeed = ENEMY_MAX_SPD
  end if
  ' Add ammo for new wave
  for i = 1 to NUM_BASES
    baseAmmo#[i] = baseAmmo#[i] + 5
    if baseAmmo#[i] > MAX_AMMO then
      baseAmmo#[i] = MAX_AMMO
    end if
  next
  UpdateAmmoDisplay()
  label_text#(lblWave#, "WAVE: " + stri$(wave))
  label_text#(lblMsg#, "")
  label_text#(lblMsg2#, "")
  rectangle_visible#(crossH#, 1)
  rectangle_visible#(crossV#, 1)
  ' Sound: incoming-wave alert jingle
  if soundInitDone = 1 then
    media_stop(sndWaveStart#)
    media_play(sndWaveStart#)
  end if
end function

function FirePlayerMissile(sx, sy, tx, ty) local i, dx, dy, dist, ph#
  ' Find free slot
  for i = 1 to MAX_PLAYER
    if pmActive#[i] = 0 then
      pmX#[i] = sx
      pmY#[i] = sy
      pmTargetX#[i] = tx
      pmTargetY#[i] = ty
      dx = tx - sx
      dy = ty - sy
      dist = sqr(dx * dx + dy * dy)
      if dist < 1 then
        dist = 1
      end if
      pmDX#[i] = dx / dist * PLAYER_SPD
      pmDY#[i] = dy / dist * PLAYER_SPD
      pmActive#[i] = 1
      ph# = pmHead##[i]
      ellipse_move#(ph#, sx - 4, sy - 4)
      ellipse_visible#(ph#, 1)
      ' Sound: missile launch whoosh
      media_stop(sndLaunch#)
      media_play(sndLaunch#)
      return 0
    end if
  next
end function

function SpawnEnemy() local i, sx, tx, ty, dx, dy, dist, eh#, target
  if enemiesToSpawn <= 0 then
    return 0
  end if
  ' Find free slot
  for i = 1 to MAX_ENEMY
    if emActive#[i] = 0 then
      sx = 50 + rnd() * (GAME_W - 100)
      emTrailX#[i] = sx
      emTrailY#[i] = SKY_TOP
      emX#[i] = sx
      emY#[i] = SKY_TOP
      ' Pick target (city or base)
      target = 1 + cint(rnd() * NUM_CITIES)
      if target > NUM_CITIES then target = NUM_CITIES
      if cityAlive#[target] = 1 then
        tx = cityX#[target] + CITY_W / 2
      else
        target = 1 + cint(rnd() * NUM_BASES)
        if target > NUM_BASES then target = NUM_BASES
        tx = baseX#[target]
      end if
      ty = GROUND_Y
      dx = tx - sx
      dy = ty - SKY_TOP
      dist = sqr(dx * dx + dy * dy)
      emDX#[i] = dx / dist * enemySpeed
      emDY#[i] = dy / dist * enemySpeed
      emActive#[i] = 1
      eh# = emHead##[i]
      ellipse_move#(eh#, sx - 3, SKY_TOP - 3)
      ellipse_visible#(eh#, 1)
      let enemiesToSpawn = enemiesToSpawn - 1
      return 0
    end if
  next
end function

function CreateExplosion(ex, ey) local i, ec#
  for i = 1 to MAX_EXPLODE
    if expActive#[i] = 0 then
      expX#[i] = ex
      expY#[i] = ey
      expR#[i] = 5
      expGrow#[i] = 1
      expActive#[i] = 1
      ec# = expCircle##[i]
      ellipse_move#(ec#, ex - 5, ey - 5)
      ellipse_size#(ec#, 10, 10)
      ellipse_visible#(ec#, 1)
      ' Sound: cycle the explosion pool so rapid detonations can overlap
      let explodeIdx = explodeIdx + 1
      if explodeIdx > 3 then let explodeIdx = 1
      media_stop(sndExplode##[explodeIdx])
      media_play(sndExplode##[explodeIdx])
      return 0
    end if
  next
end function

function CountAliveCities() local i, cnt
  cnt = 0
  for i = 1 to NUM_CITIES
    if cityAlive#[i] = 1 then
      cnt = cnt + 1
    end if
  next
  return cnt
end function

function CheckWaveComplete() local i, anyActive
  if enemiesToSpawn > 0 then
    return 0
  end if
  anyActive = 0
  for i = 1 to MAX_ENEMY
    if emActive#[i] = 1 then
      anyActive = 1
    end if
  next
  for i = 1 to MAX_PLAYER
    if pmActive#[i] = 1 then
      anyActive = 1
    end if
  next
  for i = 1 to MAX_EXPLODE
    if expActive#[i] = 1 then
      anyActive = 1
    end if
  next
  if anyActive = 0 then
    return 1
  end if
  return 0
end function

' ============================================================
'  SOUND FUNCTIONS
' ============================================================
'
'  Required audio files at https://plan9basic.com/assets/sounds/missile/ :
'    launch.wav   / launch.mp3   / launch.ogg    (~0.3s missile whoosh)
'    explode.wav  / explode.mp3  / explode.ogg   (~1.0s detonation boom)
'    city_hit.wav / city_hit.mp3 / city_hit.ogg  (~1.5s heavy explosion)
'    wave_start.wav  / .mp3 / .ogg  (~1.0s incoming-alert jingle)
'    wave_clear.wav  / .mp3 / .ogg  (~2.0s triumphant fanfare)
'    game_over.wav   / .mp3 / .ogg  (~2.0s defeat sting)
'
'  Explosion pool: 3 players loaded with the same clip are cycled in round-robin
'  order so rapid successive detonations can overlap without cutting each other off.

function InitSounds() local i
  ' --- Missile launch (one-shot, restarted on each fire) ---
  sndLaunch# = media_player#()
  media_load#(sndLaunch#, SOUND_BASE$ + "launch." + SOUND_EXT$)
  media_volume#(sndLaunch#, 0.70)

  ' --- Explosion pool: 3 players with the same clip ---
  sndExplode# = pdim#(3)
  for i = 1 to 3
    sndExplode##[i] = media_player#()
    media_load#(sndExplode##[i], SOUND_BASE$ + "explode." + SOUND_EXT$)
    media_volume#(sndExplode##[i], 0.85)
  next

  ' --- City destroyed (heavier blast, distinct from player explosion) ---
  sndCityHit# = media_player#()
  media_load#(sndCityHit#, SOUND_BASE$ + "city_hit." + SOUND_EXT$)
  media_volume#(sndCityHit#, 1.00)

  ' --- Wave start alert ---
  sndWaveStart# = media_player#()
  media_load#(sndWaveStart#, SOUND_BASE$ + "wave_start." + SOUND_EXT$)
  media_volume#(sndWaveStart#, 0.75)

  ' --- Wave cleared fanfare ---
  sndWaveClear# = media_player#()
  media_load#(sndWaveClear#, SOUND_BASE$ + "wave_clear." + SOUND_EXT$)
  media_volume#(sndWaveClear#, 0.80)

  ' --- Game over sting ---
  sndGameOver# = media_player#()
  media_load#(sndGameOver#, SOUND_BASE$ + "game_over." + SOUND_EXT$)
  media_volume#(sndGameOver#, 0.90)
end function

' ============================================================
'  MAIN GAME LOOP
' ============================================================

function GameLoop(sender#) local i, j, nx, ny, dx, dy, dist, r, ex, ey, alive, ph#, eh#, ec#, c#, cx
  ' On the very first tick the Android event loop (Looper) is guaranteed to be
  ' running, which is required for TMediaPlayer.prepareAsync() to deliver its
  ' onPrepared callback correctly on Android.
  if soundInitDone = 0 then
    let soundInitDone = 1
    InitSounds()
    return 0
  end if

  if running = 0 then
    return 0
  end if
  
  ' ========================
  '  SPAWN ENEMIES
  ' ========================
  if enemiesToSpawn > 0 then
    spawnTimer = spawnTimer + 1
    if spawnTimer >= spawnDelay then
      SpawnEnemy()
      spawnTimer = 0
    end if
  end if
  
  ' ========================
  '  UPDATE PLAYER MISSILES
  ' ========================
  for i = 1 to MAX_PLAYER
    if pmActive#[i] = 1 then
      nx = pmX#[i] + pmDX#[i]
      ny = pmY#[i] + pmDY#[i]
      ' Check if reached target
      dx = pmTargetX#[i] - pmX#[i]
      dy = pmTargetY#[i] - pmY#[i]
      dist = sqr(dx * dx + dy * dy)
      if dist < PLAYER_SPD + 2 then
        ' Reached target - explode
        CreateExplosion(pmTargetX#[i], pmTargetY#[i])
        pmActive#[i] = 0
        ph# = pmHead##[i]
        ellipse_visible#(ph#, 0)
      else
        pmX#[i] = nx
        pmY#[i] = ny
        ph# = pmHead##[i]
        ellipse_move#(ph#, nx - 4, ny - 4)
      end if
    end if
  next
  
  ' ========================
  '  UPDATE ENEMY MISSILES
  ' ========================
  for i = 1 to MAX_ENEMY
    if emActive#[i] = 1 then
      nx = emX#[i] + emDX#[i]
      ny = emY#[i] + emDY#[i]
      emX#[i] = nx
      emY#[i] = ny
      eh# = emHead##[i]
      ellipse_move#(eh#, nx - 3, ny - 3)
      
      ' Check if hit ground
      if ny >= GROUND_Y then
        emActive#[i] = 0
        ellipse_visible#(eh#, 0)
        ' Check city hit
        for j = 1 to NUM_CITIES
          if cityAlive#[j] = 1 then
            cx = cityX#[j]
            if nx >= cx then
              if nx <= cx + CITY_W then
                ' City destroyed!
                cityAlive#[j] = 0
                c# = cityRect##[j]
                rectangle_visible#(c#, 0)
                ' Sound: heavy blast for city destruction
                media_stop(sndCityHit#)
                media_play(sndCityHit#)
              end if
            end if
          end if
        next
      end if
    end if
  next
  
  ' ========================
  '  UPDATE EXPLOSIONS
  ' ========================
  for i = 1 to MAX_EXPLODE
    if expActive#[i] = 1 then
      ex = expX#[i]
      ey = expY#[i]
      r = expR#[i]
      
      if expGrow#[i] = 1 then
        r = r + EXP_GROW
        if r >= EXP_MAX_R then
          r = EXP_MAX_R
          expGrow#[i] = 0
        end if
      else
        r = r - EXP_SHRINK
        if r <= 0 then
          expActive#[i] = 0
          ec# = expCircle##[i]
          ellipse_visible#(ec#, 0)
          r = 0
        end if
      end if
      
      expR#[i] = r
      
      if expActive#[i] = 1 then
        ec# = expCircle##[i]
        ellipse_move#(ec#, ex - r, ey - r)
        ellipse_size#(ec#, r * 2, r * 2)
        
        ' Check collision with enemy missiles
        for j = 1 to MAX_ENEMY
          if emActive#[j] = 1 then
            dx = emX#[j] - ex
            dy = emY#[j] - ey
            dist = sqr(dx * dx + dy * dy)
            if dist < r then
              ' Enemy destroyed!
              emActive#[j] = 0
              eh# = emHead##[j]
              ellipse_visible#(eh#, 0)
              let score = score + 25
              label_text#(lblScore#, "SCORE: " + stri$(score))
            end if
          end if
        next
      end if
    end if
  next
  
  ' ========================
  '  CHECK GAME STATE
  ' ========================
  alive = CountAliveCities()
  
  if alive = 0 then
    ' Game Over
    let running = 0
    let gameOver = 1
    rectangle_visible#(crossH#, 0)
    rectangle_visible#(crossV#, 0)
    if IS_MOBILE = 1 then
      label_text#(lblMsg#, "GAME OVER")
      label_text#(lblMsg2#, "Tap to Retry")
    else
      label_text#(lblMsg#, "GAME OVER")
      label_text#(lblMsg2#, "Press UP to Retry")
    end if
    label_fontcolor#(lblMsg#, "#ff3300")
    label_fontcolor#(lblMsg2#, "#ff3300")
    ' Sound: defeat sting
    media_stop(sndGameOver#)
    media_play(sndGameOver#)
    return 0
  end if
  
  if CheckWaveComplete() = 1 then
    ' Wave complete - bonus!
    let score = score + alive * 100
    label_text#(lblScore#, "SCORE: " + stri$(score))
    let running = 0
    rectangle_visible#(crossH#, 0)
    rectangle_visible#(crossV#, 0)
    if IS_MOBILE = 1 then
      label_text#(lblMsg#, "WAVE CLEAR! +" + stri$(alive * 100) + " bonus")
      label_text#(lblMsg2#, "Tap to Continue")
    else
      label_text#(lblMsg#, "WAVE CLEAR! +" + stri$(alive * 100) + " bonus")
      label_text#(lblMsg2#, "Press UP to Continue")
    end if
    label_fontcolor#(lblMsg#, "#00ff00")
    label_fontcolor#(lblMsg2#, "#00ff00")
    ' Sound: triumphant wave-clear fanfare
    media_stop(sndWaveClear#)
    media_play(sndWaveClear#)
  end if

end function
