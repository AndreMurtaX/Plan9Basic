' ============================================================
'  LUNAR LANDER - A Classic Simulation Game
'  Written in Plan9Basic
' ============================================================
'
'  Controls (Desktop):
'    Up Arrow     -  Main thruster (decelerate descent)
'    Left Arrow   -  Rotate left (counter-clockwise)
'    Right Arrow  -  Rotate right (clockwise)
'    Down Arrow   -  Start game / Restart
'
'  Controls (Android / Touch):
'    Left Button   -  Rotate left
'    THRUST Button -  Main thruster
'    Right Button  -  Rotate right
'    Tap any button - Start / Restart
'
'  Landing Rules:
'    Vertical speed must be < 8.0 m/s
'    Horizontal speed must be < 5.0 m/s
'    Angle must be within 25 degrees of vertical
'    Must land on the landing pad
'
'  Scoring:
'    Base score = 1000
'    + Remaining fuel bonus
'    - Penalty for speed at landing
'    - Penalty for angle at landing
'
'  Sound Effects (hosted at https://plan9basic.com/assets/sounds/lunar/):
'    thrust.{wav|mp3|ogg}   - Engine burn loop (~2s, loops while firing)
'    land.{wav|mp3|ogg}     - Successful landing chime
'    crash.{wav|mp3|ogg}    - Explosion on impact
'    lowfuel.{wav|mp3|ogg}  - Warning beep (triggers once below 30% fuel)
'    start.{wav|mp3|ogg}    - Level start jingle
'
'  Audio format per platform:
'    Windows → WAV  (native Win32 audio, zero-latency for SFX)
'    Linux   → OGG  (GStreamer native, royalty-free open format)
'    Android → OGG  (Google-recommended format for mobile game audio)
'    macOS   → MP3  (universally supported via CoreAudio)
'    iOS     → MP3  (universally supported via AVFoundation)
'
' ============================================================
randomize()
' --- Platform Detection ---
LET PLATFORM$ = os_name$()
LET IS_MOBILE = 0
IF (PLATFORM$ = "Android") OR (PLATFORM$ = "iOS") THEN IS_MOBILE = 1
' --- Audio Format Detection ---
'     Each platform uses its native best-supported format for game SFX:
'       Windows → WAV  (Win32 native, hardware-accelerated, zero decode latency)
'       Linux   → OGG  (GStreamer native, open-source royalty-free)
'       Android → OGG  (Preferred by Android SoundPool / MediaPlayer for games)
'       macOS   → MP3  (CoreAudio universal support)
'       iOS     → MP3  (AVFoundation universal support)
LET SOUND_BASE$ = "https://plan9basic.com/assets/sounds/lunar/"
LET SOUND_EXT$ = "mp3"
PRINTLN "Current platform: "; PLATFORM$
IF InStr(PLATFORM$, "Windows") <> 0 THEN SOUND_EXT$ = "wav"
PRINTLN "Testing Windows: "; InStr(PLATFORM$, "Windows")
IF InStr(PLATFORM$, "Linux") <> 0 THEN SOUND_EXT$ = "ogg"
PRINTLN "Testing Linux: "; InStr(PLATFORM$, "Linux")
IF InStr(PLATFORM$, "Android") <> 0 THEN SOUND_EXT$ = "ogg"
PRINTLN "Testing Android: "; InStr(PLATFORM$, "Android")
' --- Game Area Constants ---
LET GAME_W = 480
LET GAME_H = 700
LET CTRL_H = 0
IF IS_MOBILE = 1 THEN
  LET GAME_W = form_screenwidth()
  LET GAME_H = form_screenheight()
  LET CTRL_H = 140
END IF
LET PLAY_H = GAME_H - CTRL_H
LET PI = 3.14159265
' --- Physics Constants ---
LET GRAVITY = 0.015
LET THRUST_POWER = 0.07
LET ROTATE_SPD = 2.5
LET FUEL_USE = 0.2
LET MAX_SAFE_VY = 8.0
LET MAX_SAFE_VX = 5.0
LET MAX_SAFE_ANGLE = 25
' --- Terrain Constants ---
LET NUM_TERRAIN = 20
LET NUM_TERR_PTS = 21
LET PAD_WIDTH = 60
LET TERRAIN_BASE = PLAY_H - 30
' --- Lander Constants ---
LET LANDER_W = 24
LET LANDER_H = 28
' --- Star Constants ---
LET NUM_STARS = 40
' --- Game State ---
LET score = 0
LET highScore = 0
LET fuel = 100
LET landerX = 0
LET landerY = 0
LET velX = 0
LET velY = 0
LET angle = 0
LET thrustOn = 0
LET rotateL = 0
LET rotateR = 0
LET running = 0
LET gameOver = 0
LET landed = 0
LET crashed = 0
LET level = 1
LET padIdx = 0
LET padCenterX = 0
LET beaconTimer = 0
LET beaconOn = 1
LET segW = GAME_W / NUM_TERRAIN
' --- Object Pointers ---
LET frm# = pointer#(0)
LET tmr# = pointer#(0)
' --- Lander visuals ---
LET landerBody# = pointer#(0)
LET landerTop# = pointer#(0)
LET landerLegL# = pointer#(0)
LET landerLegR# = pointer#(0)
LET thrustFlame# = pointer#(0)
' --- HUD Labels ---
LET lblFuel# = pointer#(0)
LET lblAlt# = pointer#(0)
LET lblVelX# = pointer#(0)
LET lblVelY# = pointer#(0)
LET lblAngle# = pointer#(0)
LET lblScore# = pointer#(0)
LET lblMsg# = pointer#(0)
LET lblMsg2# = pointer#(0)
LET lblLevel# = pointer#(0)
' --- Terrain Arrays ---
LET terrX# = pointer#(0)
LET terrY# = pointer#(0)
LET terrRect# = pointer#(0)
' --- Star Arrays ---
LET starRect# = pointer#(0)
' --- Landing Pad ---
LET padRect# = pointer#(0)
LET padBeacon1# = pointer#(0)
LET padBeacon2# = pointer#(0)
' --- Sound Players ---
LET sndThrust# = pointer#(0)
LET sndLand# = pointer#(0)
LET sndCrash# = pointer#(0)
LET sndLowFuel# = pointer#(0)
LET sndStart# = pointer#(0)
LET thrustWasOn = 0
LET lowFuelWarned = 0
LET soundInitDone = 0
' --- Touch Control Buttons (mobile) ---
LET btnLeft# = pointer#(0)
LET btnThrust# = pointer#(0)
LET btnRight# = pointer#(0)
LET lblBtnL# = pointer#(0)
LET lblBtnT# = pointer#(0)
LET lblBtnR# = pointer#(0)
LET ctrlPanel# = pointer#(0)
' ============================================================
'  CREATE THE GAME WINDOW
' ============================================================
IF IS_MOBILE = 1 THEN
  LET frm# = form#("Lunar Lander", GAME_W, GAME_H)
ELSE
  ' Add window frame compensation: ~16px for borders, ~39px for title bar
  LET frm# = form#("Lunar Lander", GAME_W + 16, GAME_H + 39)
  form_position#(frm#, 4)
END IF
form_fill#(frm#, "#000011")
' ============================================================
'  CREATE STARFIELD
' ============================================================
LET starRect# = pdim#(NUM_STARS)
FOR i = 1 TO NUM_STARS
  LET sx = rnd() * GAME_W
  LET sy = rnd() * (PLAY_H - 80)
  LET ss = 1 + rnd() * 2
  LET star# = ellipse#(frm#, sx, sy, ss, ss)
  LET starPick = cint(rnd() * 4)
  IF starPick = 0 THEN
    ellipse_fill#(star#, "#aaaaaa")
  ELSE IF starPick = 1 THEN
    ellipse_fill#(star#, "#cccccc")
  ELSE IF starPick = 2 THEN
    ellipse_fill#(star#, "#ffffff")
  ELSE IF starPick = 3 THEN
    ellipse_fill#(star#, "#888888")
  ELSE
    ellipse_fill#(star#, "#dddddd")
  END IF
  ellipse_strokenone#(star#)
  ellipse_hittest#(star#, 0)
  starRect##[i] = star#
NEXT
' ============================================================
'  CREATE TERRAIN
' ============================================================
LET terrX# = dim#(NUM_TERR_PTS)
LET terrY# = dim#(NUM_TERR_PTS)
LET terrRect# = pdim#(NUM_TERRAIN)
' Choose landing pad position (avoid edges)
LET padIdx = 4 + cint(rnd() * (NUM_TERRAIN - 8))
' Generate terrain heights
FOR i = 1 TO NUM_TERR_PTS
  LET tx = (i - 1) * segW
  terrX#[i] = tx
  IF i = padIdx THEN
    terrY#[i] = TERRAIN_BASE - 40 - rnd() * 50
  ELSE IF i = padIdx + 1 THEN
    terrY#[i] = terrY#[padIdx]
  ELSE
    terrY#[i] = TERRAIN_BASE - 10 - rnd() * 120
  END IF
NEXT
' Create terrain visual rectangles
FOR i = 1 TO NUM_TERRAIN
  LET minY = terrY#[i]
  IF terrY#[i + 1] < minY THEN
    LET minY = terrY#[i + 1]
  END IF
  LET t# = rectangle#(frm#, terrX#[i], minY, segW + 1, PLAY_H - minY)
  rectangle_fill#(t#, "#444444")
  rectangle_stroke#(t#, "#555555")
  rectangle_strokethickness#(t#, 1)
  rectangle_hittest#(t#, 0)
  terrRect##[i] = t#
NEXT
' Create landing pad
LET padPx = terrX#[padIdx]
LET padPy = terrY#[padIdx]
LET padRect# = rectangle#(frm#, padPx + 2, padPy - 4, segW - 4, 6)
rectangle_fill#(padRect#, "#00cc00")
rectangle_strokenone#(padRect#)
rectangle_hittest#(padRect#, 0)
LET padBeacon1# = ellipse#(frm#, padPx - 2, padPy - 10, 8, 8)
ellipse_fill#(padBeacon1#, "#00ff00")
ellipse_strokenone#(padBeacon1#)
ellipse_hittest#(padBeacon1#, 0)
LET padBeacon2# = ellipse#(frm#, padPx + segW - 6, padPy - 10, 8, 8)
ellipse_fill#(padBeacon2#, "#00ff00")
ellipse_strokenone#(padBeacon2#)
ellipse_hittest#(padBeacon2#, 0)
' ============================================================
'  CREATE LANDER
' ============================================================
LET landerBody# = rectangle#(frm#, 0, 0, LANDER_W, LANDER_H - 8)
rectangle_fill#(landerBody#, "#cccccc")
rectangle_stroke#(landerBody#, "#ffffff")
rectangle_strokethickness#(landerBody#, 1)
rectangle_corners#(landerBody#, 3, 3)
rectangle_hittest#(landerBody#, 0)
rectangle_visible#(landerBody#, 0)
LET landerTop# = ellipse#(frm#, 0, 0, LANDER_W - 4, 14)
ellipse_fill#(landerTop#, "#4488ff")
ellipse_stroke#(landerTop#, "#6699ff")
ellipse_strokethickness#(landerTop#, 1)
ellipse_hittest#(landerTop#, 0)
ellipse_visible#(landerTop#, 0)
LET landerLegL# = rectangle#(frm#, 0, 0, 4, 10)
rectangle_fill#(landerLegL#, "#aaaaaa")
rectangle_strokenone#(landerLegL#)
rectangle_hittest#(landerLegL#, 0)
rectangle_visible#(landerLegL#, 0)
LET landerLegR# = rectangle#(frm#, 0, 0, 4, 10)
rectangle_fill#(landerLegR#, "#aaaaaa")
rectangle_strokenone#(landerLegR#)
rectangle_hittest#(landerLegR#, 0)
rectangle_visible#(landerLegR#, 0)
LET thrustFlame# = ellipse#(frm#, 0, 0, 12, 22)
ellipse_fill#(thrustFlame#, "#ff6600")
ellipse_strokenone#(thrustFlame#)
ellipse_hittest#(thrustFlame#, 0)
ellipse_visible#(thrustFlame#, 0)
' ============================================================
'  CREATE HUD
' ============================================================
LET lblFuel# = label#(frm#, "FUEL: 150", 10, 8)
label_autosize#(lblFuel#, 0)
label_fontsize#(lblFuel#, 13)
label_fontcolor#(lblFuel#, "#00ff00")
label_bold#(lblFuel#, 1)
label_size#(lblFuel#, 130, 20)
LET lblAlt# = label#(frm#, "ALT: 0")
label_autosize#(lblAlt#, 0)
label_move#(lblAlt#, 10, 28)
label_fontsize#(lblAlt#, 13)
label_fontcolor#(lblAlt#, "#00ccff")
label_bold#(lblAlt#, 1)
label_size#(lblAlt#, 130, 20)
LET lblVelX# = label#(frm#, "H.SPD: 0.0")
label_autosize#(lblVelX#, 0)
label_move#(lblVelX#, GAME_W - 140, 8)
label_fontsize#(lblVelX#, 13)
label_fontcolor#(lblVelX#, "#ffcc00")
label_bold#(lblVelX#, 1)
label_size#(lblVelX#, 130, 20)
label_textalign#(lblVelX#, 2)
LET lblVelY# = label#(frm#, "V.SPD: 0.0")
label_autosize#(lblVelY#, 0)
label_move#(lblVelY#, GAME_W - 140, 28)
label_fontsize#(lblVelY#, 13)
label_fontcolor#(lblVelY#, "#ffcc00")
label_bold#(lblVelY#, 1)
label_size#(lblVelY#, 130, 20)
label_textalign#(lblVelY#, 2)
LET lblAngle# = label#(frm#, "ANG: 0")
label_autosize#(lblAngle#, 0)
label_move#(lblAngle#, GAME_W / 2 - 50, 8)
label_fontsize#(lblAngle#, 13)
label_fontcolor#(lblAngle#, "#ff88ff")
label_bold#(lblAngle#, 1)
label_size#(lblAngle#, 100, 20)
label_textalign#(lblAngle#, 0)
LET lblScore# = label#(frm#, "SCORE: 0")
label_autosize#(lblScore#, 0)
label_move#(lblScore#, GAME_W / 2 - 50, 28)
label_fontsize#(lblScore#, 13)
label_fontcolor#(lblScore#, "#ffffff")
label_bold#(lblScore#, 1)
label_size#(lblScore#, 100, 20)
label_textalign#(lblScore#, 0)
LET lblLevel# = label#(frm#, "LV: 1")
label_autosize#(lblLevel#, 0)
label_move#(lblLevel#, GAME_W / 2 + 60, 8)
label_fontsize#(lblLevel#, 13)
label_fontcolor#(lblLevel#, "#ff8800")
label_bold#(lblLevel#, 1)
label_size#(lblLevel#, 60, 20)
' --- Mobile HUD repositioning (4-column layout to avoid cramping) ---
IF IS_MOBILE = 1 THEN
  LET colW = cint(GAME_W / 4)
  ' Row 1: FUEL | ANG | LV | H.SPD
  label_move#(lblFuel#, 10, 8)
  label_size#(lblFuel#, colW - 10, 20)
  label_move#(lblAngle#, colW, 8)
  label_size#(lblAngle#, colW, 20)
  label_textalign#(lblAngle#, 0)
  label_move#(lblLevel#, colW * 2, 8)
  label_size#(lblLevel#, colW, 20)
  label_textalign#(lblLevel#, 0)
  label_move#(lblVelX#, colW * 3, 8)
  label_size#(lblVelX#, colW - 10, 20)
  label_textalign#(lblVelX#, 2)
  ' Row 2: ALT | SCORE | (empty) | V.SPD
  label_move#(lblAlt#, 10, 28)
  label_size#(lblAlt#, colW - 10, 20)
  label_move#(lblScore#, colW, 28)
  label_size#(lblScore#, colW * 2, 20)
  label_textalign#(lblScore#, 0)
  label_move#(lblVelY#, colW * 3, 28)
  label_size#(lblVelY#, colW - 10, 20)
  label_textalign#(lblVelY#, 2)
END IF
' ============================================================
'  CREATE TOUCH CONTROLS (for mobile)
' ============================================================
IF IS_MOBILE = 1 THEN
  LET ctrlPanel# = rectangle#(frm#, 0, PLAY_H, GAME_W, CTRL_H)
  rectangle_fill#(ctrlPanel#, "#1a1a2e")
  rectangle_stroke#(ctrlPanel#, "#333355")
  rectangle_strokethickness#(ctrlPanel#, 1)
  rectangle_hittest#(ctrlPanel#, 0)
  LET btnW = GAME_W / 3 - 12
  LET btnH = CTRL_H - 30
  LET btnY = PLAY_H + 15
  LET btnLeft# = rectangle#(frm#, 8, btnY, btnW, btnH)
  rectangle_fill#(btnLeft#, "#334455")
  rectangle_stroke#(btnLeft#, "#5577aa")
  rectangle_strokethickness#(btnLeft#, 2)
  rectangle_corners#(btnLeft#, 10, 10)
  rectangle_hittest#(btnLeft#, 1)
  rectangle_onmousedown#(btnLeft#, "OnBtnLeftDown")
  rectangle_onmouseup#(btnLeft#, "OnBtnLeftUp")
  LET lblBtnL# = label#(frm#, "< LEFT")
  label_autosize#(lblBtnL#, 0)
  label_move#(lblBtnL#, 8, btnY)
  label_fontsize#(lblBtnL#, 16)
  label_fontcolor#(lblBtnL#, "#aaccff")
  label_bold#(lblBtnL#, 1)
  label_size#(lblBtnL#, btnW, btnH)
  label_textalign#(lblBtnL#, 0)
  label_vertalign#(lblBtnL#, 0)
  label_hittest#(lblBtnL#, 0)
  LET btnThrust# = rectangle#(frm#, GAME_W / 3 + 2, btnY, btnW + 8, btnH)
  rectangle_fill#(btnThrust#, "#553300")
  rectangle_stroke#(btnThrust#, "#ff8800")
  rectangle_strokethickness#(btnThrust#, 3)
  rectangle_corners#(btnThrust#, 10, 10)
  rectangle_hittest#(btnThrust#, 1)
  rectangle_onmousedown#(btnThrust#, "OnBtnThrustDown")
  rectangle_onmouseup#(btnThrust#, "OnBtnThrustUp")
  LET lblBtnT# = label#(frm#, "THRUST")
  label_autosize#(lblBtnT#, 0)
  label_move#(lblBtnT#, GAME_W / 3 + 2, btnY)
  label_fontsize#(lblBtnT#, 18)
  label_fontcolor#(lblBtnT#, "#ff8800")
  label_bold#(lblBtnT#, 1)
  label_size#(lblBtnT#, btnW + 8, btnH)
  label_textalign#(lblBtnT#, 0)
  label_vertalign#(lblBtnT#, 0)
  label_hittest#(lblBtnT#, 0)
  LET btnRight# = rectangle#(frm#, GAME_W - btnW - 8, btnY, btnW, btnH)
  rectangle_fill#(btnRight#, "#334455")
  rectangle_stroke#(btnRight#, "#5577aa")
  rectangle_strokethickness#(btnRight#, 2)
  rectangle_corners#(btnRight#, 10, 10)
  rectangle_hittest#(btnRight#, 1)
  rectangle_onmousedown#(btnRight#, "OnBtnRightDown")
  rectangle_onmouseup#(btnRight#, "OnBtnRightUp")
  LET lblBtnR# = label#(frm#, "RIGHT >")
  label_autosize#(lblBtnR#, 0)
  label_move#(lblBtnR#, GAME_W - btnW - 8, btnY)
  label_fontsize#(lblBtnR#, 16)
  label_fontcolor#(lblBtnR#, "#aaccff")
  label_bold#(lblBtnR#, 1)
  label_size#(lblBtnR#, btnW, btnH)
  label_textalign#(lblBtnR#, 0)
  label_vertalign#(lblBtnR#, 0)
  label_hittest#(lblBtnR#, 0)
END IF
' --- Center message line 1 (created LAST for Z-order, on top of everything) ---
LET lblMsg# = label#(frm#, "")
label_autosize#(lblMsg#, 0)
label_fontsize#(lblMsg#, 20)
label_fontcolor#(lblMsg#, "#ffffff")
label_bold#(lblMsg#, 1)
label_align#(lblMsg#, 14)
label_height#(lblMsg#, 40)
label_y#(lblMsg#, cint(PLAY_H / 2 - 40))
label_textalign#(lblMsg#, 0)
' --- Center message line 2 (sub-message / instruction) ---
LET lblMsg2# = label#(frm#, "")
label_autosize#(lblMsg2#, 0)
label_fontsize#(lblMsg2#, 18)
label_fontcolor#(lblMsg2#, "#ffffff")
label_bold#(lblMsg2#, 1)
label_align#(lblMsg2#, 14)
label_height#(lblMsg2#, 36)
label_y#(lblMsg2#, cint(PLAY_H / 2))
label_textalign#(lblMsg2#, 0)
IF IS_MOBILE = 1 THEN
  label_text#(lblMsg#, "Tap THRUST to Start")
  label_fontsize#(lblMsg#, 22)
ELSE
  label_text#(lblMsg#, "Press DOWN ARROW to Start")
END IF
' ============================================================
'  SETUP TIMER AND EVENTS
' ============================================================
LET tmr# = timer#()
timer_interval#(tmr#, 16)
timer_ontimer#(tmr#, "GameLoop")
timer_start#(tmr#)
form_onkeydown#(frm#, "OnKeyDown")
form_onkeyup#(frm#, "OnKeyUp")
form_show(frm#)
' ============================================================
'  KEYBOARD EVENT HANDLERS
' ============================================================
FUNCTION OnKeyDown(sender#, keyCode, keyChar$, shiftState$)
  IF keyCode = 37 THEN
    LET rotateL = 1
  END IF
  IF keyCode = 39 THEN
    LET rotateR = 1
  END IF
  IF keyCode = 38 THEN
    LET thrustOn = 1
  END IF
  IF keyCode = 40 THEN
    IF running = 0 THEN
      StartOrRestart()
    END IF
  END IF
END FUNCTION
FUNCTION OnKeyUp(sender#, keyCode, keyChar$, shiftState$)
  IF keyCode = 37 THEN
    LET rotateL = 0
  END IF
  IF keyCode = 39 THEN
    LET rotateR = 0
  END IF
  IF keyCode = 38 THEN
    LET thrustOn = 0
  END IF
END FUNCTION
' ============================================================
'  SOUND FUNCTIONS
' ============================================================
'
'  Required audio files at https://plan9basic.com/assets/sounds/lunar/ :
'    thrust.wav / thrust.mp3 / thrust.ogg   (~2s engine burn, will loop)
'    land.wav   / land.mp3   / land.ogg     (~2s success chime)
'    crash.wav  / crash.mp3  / crash.ogg    (~2s explosion boom)
'    lowfuel.wav/ lowfuel.mp3/ lowfuel.ogg  (~1s warning beep)
'    start.wav  / start.mp3  / start.ogg    (~1s level-start jingle)
FUNCTION InitSounds()
  ' --- Thrust: short engine-burn clip, looped by OnThrustEnd callback ---
  sndThrust# = media_player#()
  media_load#(sndThrust#, SOUND_BASE$ + "thrust." + SOUND_EXT$)
  PRINTLN "Sound thrust: "+SOUND_BASE$ + "thrust." + SOUND_EXT$
  media_volume#(sndThrust#, 0.70)
  media_onend#(sndThrust#, "OnThrustEnd")
  ' --- Successful landing chime ---
  sndLand# = media_player#()
  media_load#(sndLand#, SOUND_BASE$ + "land." + SOUND_EXT$)
  media_volume#(sndLand#, 0.90)
  ' --- Crash explosion ---
  sndCrash# = media_player#()
  media_load#(sndCrash#, SOUND_BASE$ + "crash." + SOUND_EXT$)
  media_volume#(sndCrash#, 1.00)
  ' --- Low-fuel warning beep ---
  sndLowFuel# = media_player#()
  media_load#(sndLowFuel#, SOUND_BASE$ + "lowfuel." + SOUND_EXT$)
  media_volume#(sndLowFuel#, 0.80)
  ' --- Level start jingle ---
  sndStart# = media_player#()
  media_load#(sndStart#, SOUND_BASE$ + "start." + SOUND_EXT$)
  media_volume#(sndStart#, 0.60)
END FUNCTION
' Called automatically when the thrust clip ends.
' If the engine is still firing, restart the clip to create a seamless loop.
FUNCTION OnThrustEnd(sender#)
  IF thrustOn = 1 AND fuel > 0 AND running = 1 THEN
    media_play(sndThrust#)
  END IF
END FUNCTION
' ============================================================
'  TOUCH EVENT HANDLERS (Mobile)
' ============================================================
FUNCTION OnBtnLeftDown(sender#, btn, mx, my, shift$)
  LET rotateL = 1
  IF IS_MOBILE = 1 THEN
    rectangle_fill#(btnLeft#, "#556688")
  END IF
  IF running = 0 THEN
    StartOrRestart()
  END IF
END FUNCTION
FUNCTION OnBtnLeftUp(sender#, btn, mx, my, shift$)
  LET rotateL = 0
  IF IS_MOBILE = 1 THEN
    rectangle_fill#(btnLeft#, "#334455")
  END IF
END FUNCTION
FUNCTION OnBtnThrustDown(sender#, btn, mx, my, shift$)
  LET thrustOn = 1
  IF IS_MOBILE = 1 THEN
    rectangle_fill#(btnThrust#, "#885500")
  END IF
  IF running = 0 THEN
    StartOrRestart()
  END IF
END FUNCTION
FUNCTION OnBtnThrustUp(sender#, btn, mx, my, shift$)
  LET thrustOn = 0
  IF IS_MOBILE = 1 THEN
    rectangle_fill#(btnThrust#, "#553300")
  END IF
END FUNCTION
FUNCTION OnBtnRightDown(sender#, btn, mx, my, shift$)
  LET rotateR = 1
  IF IS_MOBILE = 1 THEN
    rectangle_fill#(btnRight#, "#556688")
  END IF
  IF running = 0 THEN
    StartOrRestart()
  END IF
END FUNCTION
FUNCTION OnBtnRightUp(sender#, btn, mx, my, shift$)
  LET rotateR = 0
  IF IS_MOBILE = 1 THEN
    rectangle_fill#(btnRight#, "#334455")
  END IF
END FUNCTION
' ============================================================
'  GAME FUNCTIONS
' ============================================================
FUNCTION StartOrRestart()
  IF gameOver = 1 THEN
    IF landed = 1 THEN
      NextLevel()
    ELSE
      ResetFullGame()
    END IF
  ELSE
    StartLevel()
  END IF
END FUNCTION
FUNCTION StartLevel()
  LET running = 1
  LET gameOver = 0
  LET landed = 0
  LET crashed = 0
  LET landerX = GAME_W / 2 - LANDER_W / 2 + (rnd() - 0.5) * 100
  LET landerY = 60
  LET velX = (rnd() - 0.5) * level * 0.3
  LET velY = 0
  LET angle = 0
  LET fuel = 150 - level * 5
  IF fuel < 70 THEN
    LET fuel = 70
  END IF
  rectangle_fill#(landerBody#, "#cccccc")
  ellipse_fill#(landerTop#, "#4488ff")
  rectangle_fill#(padRect#, "#00cc00")
  rectangle_visible#(landerBody#, 1)
  ellipse_visible#(landerTop#, 1)
  rectangle_visible#(landerLegL#, 1)
  rectangle_visible#(landerLegR#, 1)
  label_text#(lblMsg#, "")
  label_text#(lblMsg2#, "")
  label_text#(lblLevel#, "LV: " + stri$(level))
  label_fontcolor#(lblMsg#, "#ffffff")
  label_fontcolor#(lblMsg2#, "#ffffff")
  ' --- Sound: reset state flags, silence any residual audio, play start jingle ---
  LET thrustWasOn = 0
  LET lowFuelWarned = 0
  media_stop(sndThrust#)
  media_stop(sndCrash#)
  media_stop(sndLand#)
  media_play(sndStart#)
  UpdateHUD()
END FUNCTION
FUNCTION NextLevel() LOCAL i, minY, t#
  LET level = level + 1
  LET padIdx = 4 + cint(rnd() * (NUM_TERRAIN - 8))
  FOR i = 1 TO NUM_TERR_PTS
    terrX#[i] = (i - 1) * segW
    IF i = padIdx THEN
      terrY#[i] = TERRAIN_BASE - 40 - rnd() * 50
    ELSE IF i = padIdx + 1 THEN
      terrY#[i] = terrY#[padIdx]
    ELSE
      terrY#[i] = TERRAIN_BASE - 10 - rnd() * 120
    END IF
  NEXT
  FOR i = 1 TO NUM_TERRAIN
    minY = terrY#[i]
    IF terrY#[i + 1] < minY THEN
      minY = terrY#[i + 1]
    END IF
    t# = terrRect##[i]
    rectangle_bounds#(t#, terrX#[i], minY, segW + 1, PLAY_H - minY)
  NEXT
  LET padPx = terrX#[padIdx]
  LET padPy = terrY#[padIdx]
  rectangle_bounds#(padRect#, padPx + 2, padPy - 4, segW - 4, 6)
  ellipse_move#(padBeacon1#, padPx - 2, padPy - 10)
  ellipse_move#(padBeacon2#, padPx + segW - 6, padPy - 10)
  StartLevel()
END FUNCTION
FUNCTION ResetFullGame() LOCAL i, minY, t#
  LET score = 0
  LET level = 1
  LET gameOver = 0
  LET landed = 0
  LET crashed = 0
  label_text#(lblScore#, "SCORE: 0")
  LET padIdx = 4 + cint(rnd() * (NUM_TERRAIN - 8))
  FOR i = 1 TO NUM_TERR_PTS
    terrX#[i] = (i - 1) * segW
    IF i = padIdx THEN
      terrY#[i] = TERRAIN_BASE - 40 - rnd() * 50
    ELSE IF i = padIdx + 1 THEN
      terrY#[i] = terrY#[padIdx]
    ELSE
      terrY#[i] = TERRAIN_BASE - 10 - rnd() * 120
    END IF
  NEXT
  FOR i = 1 TO NUM_TERRAIN
    minY = terrY#[i]
    IF terrY#[i + 1] < minY THEN
      minY = terrY#[i + 1]
    END IF
    t# = terrRect##[i]
    rectangle_bounds#(t#, terrX#[i], minY, segW + 1, PLAY_H - minY)
  NEXT
  LET padPx = terrX#[padIdx]
  LET padPy = terrY#[padIdx]
  rectangle_bounds#(padRect#, padPx + 2, padPy - 4, segW - 4, 6)
  ellipse_move#(padBeacon1#, padPx - 2, padPy - 10)
  ellipse_move#(padBeacon2#, padPx + segW - 6, padPy - 10)
  StartLevel()
END FUNCTION
FUNCTION UpdateHUD() LOCAL fuelPct, fuelColor$, vyAbs, vxAbs, hSpd$, vSpd$, alt
  fuelPct = cint(fuel)
  IF fuelPct > 80 THEN
    fuelColor$ = "#00ff00"
  ELSE IF fuelPct > 40 THEN
    fuelColor$ = "#ffcc00"
  ELSE
    fuelColor$ = "#ff3300"
  END IF
  label_text#(lblFuel#, "FUEL: " + stri$(fuelPct))
  label_fontcolor#(lblFuel#, fuelColor$)
  alt = GetAltitude()
  label_text#(lblAlt#, "ALT: " + stri$(cint(alt)))
  vxAbs = abs(velX * 30)
  vyAbs = abs(velY * 30)
  hSpd$ = stri$(vxAbs, 1)
  vSpd$ = stri$(vyAbs, 1)
  label_text#(lblVelX#, "H.SPD: " + hSpd$)
  label_text#(lblVelY#, "V.SPD: " + vSpd$)
  IF vyAbs < MAX_SAFE_VY * 0.7 THEN
    label_fontcolor#(lblVelY#, "#00ff00")
  ELSE IF vyAbs < MAX_SAFE_VY THEN
    label_fontcolor#(lblVelY#, "#ffcc00")
  ELSE
    label_fontcolor#(lblVelY#, "#ff3300")
  END IF
  IF vxAbs < MAX_SAFE_VX * 0.7 THEN
    label_fontcolor#(lblVelX#, "#00ff00")
  ELSE IF vxAbs < MAX_SAFE_VX THEN
    label_fontcolor#(lblVelX#, "#ffcc00")
  ELSE
    label_fontcolor#(lblVelX#, "#ff3300")
  END IF
  label_text#(lblAngle#, "ANG: " + stri$(cint(angle)))
  IF abs(angle) < MAX_SAFE_ANGLE * 0.7 THEN
    label_fontcolor#(lblAngle#, "#00ff00")
  ELSE IF abs(angle) < MAX_SAFE_ANGLE THEN
    label_fontcolor#(lblAngle#, "#ffcc00")
  ELSE
    label_fontcolor#(lblAngle#, "#ff3300")
  END IF
END FUNCTION
FUNCTION GetAltitude() LOCAL cx, sIdx, t1, t2, frac, terrYAtX
  cx = landerX + LANDER_W / 2
  sIdx = cint(cx / segW) + 1
  IF sIdx < 1 THEN
    sIdx = 1
  END IF
  IF sIdx > NUM_TERRAIN THEN
    sIdx = NUM_TERRAIN
  END IF
  t1 = terrY#[sIdx]
  t2 = terrY#[sIdx + 1]
  frac = (cx - terrX#[sIdx]) / segW
  terrYAtX = t1 + (t2 - t1) * frac
  RETURN terrYAtX - (landerY + LANDER_H + 10)
END FUNCTION
FUNCTION GetTerrainYAt(px) LOCAL sIdx, t1, t2, frac
  sIdx = cint(px / segW) + 1
  IF sIdx < 1 THEN
    sIdx = 1
  END IF
  IF sIdx > NUM_TERRAIN THEN
    sIdx = NUM_TERRAIN
  END IF
  t1 = terrY#[sIdx]
  t2 = terrY#[sIdx + 1]
  frac = (px - terrX#[sIdx]) / segW
  RETURN t1 + (t2 - t1) * frac
END FUNCTION
FUNCTION IsOverPad() LOCAL cx, padLeft, padRight
  cx = landerX + LANDER_W / 2
  padLeft = terrX#[padIdx]
  padRight = terrX#[padIdx] + segW
  IF cx >= padLeft THEN
    IF cx <= padRight THEN
      RETURN 1
    END IF
  END IF
  RETURN 0
END FUNCTION
FUNCTION UpdateLanderVisuals() LOCAL rad, cosA, sinA, midX, midY, ox, oy, rx, ry, flameH
  ' All parts rotate around the lander CENTER point
  midX = landerX + LANDER_W / 2
  midY = landerY + LANDER_H / 2
  rad = degtorad(angle)
  cosA = cos(rad)
  sinA = sin(rad)
  ' --- Main body (24 x 20) centered at offset (0, +2) ---
  ox = 0
  oy = 2
  rx = midX + ox * cosA - oy * sinA - LANDER_W / 2
  ry = midY + ox * sinA + oy * cosA - 10
  rectangle_move#(landerBody#, rx, ry)
  rectangle_rotation#(landerBody#, angle)
  ' --- Dome (20 x 14) centered at offset (0, -9) ---
  ox = 0
  oy = -9
  rx = midX + ox * cosA - oy * sinA - 10
  ry = midY + ox * sinA + oy * cosA - 7
  ellipse_move#(landerTop#, rx, ry)
  ellipse_rotation#(landerTop#, angle)
  ' --- Left leg (4 x 10) at offset (-10, +14) ---
  ox = -10
  oy = 14
  rx = midX + ox * cosA - oy * sinA - 2
  ry = midY + ox * sinA + oy * cosA - 5
  rectangle_move#(landerLegL#, rx, ry)
  rectangle_rotation#(landerLegL#, angle - 15)
  ' --- Right leg (4 x 10) at offset (+10, +14) ---
  ox = 10
  oy = 14
  rx = midX + ox * cosA - oy * sinA - 2
  ry = midY + ox * sinA + oy * cosA - 5
  rectangle_move#(landerLegR#, rx, ry)
  rectangle_rotation#(landerLegR#, angle + 15)
  ' --- Thrust flame at offset (0, +22) ---
  IF thrustOn = 1 THEN
    IF fuel > 0 THEN
      flameH = 18 + rnd() * 12
      ellipse_size#(thrustFlame#, 10 + rnd() * 4, flameH)
      ox = 0
      oy = 22
      rx = midX + ox * cosA - oy * sinA - 7
      ry = midY + ox * sinA + oy * cosA - flameH / 2
      ellipse_move#(thrustFlame#, rx, ry)
      ellipse_rotation#(thrustFlame#, angle)
      ellipse_visible#(thrustFlame#, 1)
      IF rnd() > 0.5 THEN
        ellipse_fill#(thrustFlame#, "#ff6600")
      ELSE
        ellipse_fill#(thrustFlame#, "#ffaa00")
      END IF
    ELSE
      ellipse_visible#(thrustFlame#, 0)
    END IF
  ELSE
    ellipse_visible#(thrustFlame#, 0)
  END IF
END FUNCTION
FUNCTION CalculateScore() LOCAL baseScore, fuelBonus, spdPenalty, angPenalty, vy, vx, finalScore
  baseScore = 1000
  fuelBonus = cint(fuel * 10)
  vy = abs(velY * 30)
  vx = abs(velX * 30)
  spdPenalty = cint((vy + vx) * 50)
  angPenalty = cint(abs(angle) * 10)
  finalScore = baseScore + fuelBonus - spdPenalty - angPenalty
  IF finalScore < 100 THEN
    finalScore = 100
  END IF
  RETURN finalScore
END FUNCTION
FUNCTION DoLanding() LOCAL lvlScore
  LET running = 0
  LET gameOver = 1
  LET landed = 1
  lvlScore = CalculateScore()
  LET score = score + lvlScore
  label_text#(lblScore#, "SCORE: " + stri$(score))
  IF score > highScore THEN
    LET highScore = score
  END IF
  rectangle_fill#(padRect#, "#00ff00")
  IF IS_MOBILE = 1 THEN
    label_text#(lblMsg#, "PERFECT LANDING! +" + stri$(lvlScore))
    label_text#(lblMsg2#, "Tap for next level")
  ELSE
    label_text#(lblMsg#, "PERFECT LANDING! +" + stri$(lvlScore))
    label_text#(lblMsg2#, "Press DOWN for next")
  END IF
  label_fontcolor#(lblMsg#, "#00ff00")
  label_fontcolor#(lblMsg2#, "#00ff00")
  LET thrustOn = 0
  LET thrustWasOn = 0
  ellipse_visible#(thrustFlame#, 0)
  ' --- Sound: cut engine, play landing chime ---
  media_stop(sndThrust#)
  media_play(sndLand#)
END FUNCTION
FUNCTION DoCrash() LOCAL reason$
  LET running = 0
  LET gameOver = 1
  LET crashed = 1
  reason$ = "CRASHED!"
  IF IsOverPad() = 0 THEN
    reason$ = "MISSED THE PAD!"
  ELSE IF abs(velY * 30) >= MAX_SAFE_VY THEN
    reason$ = "TOO FAST!"
  ELSE IF abs(velX * 30) >= MAX_SAFE_VX THEN
    reason$ = "TOO MUCH DRIFT!"
  ELSE IF abs(angle) >= MAX_SAFE_ANGLE THEN
    reason$ = "BAD ANGLE!"
  END IF
  rectangle_fill#(landerBody#, "#ff3300")
  ellipse_fill#(landerTop#, "#ff0000")
  rectangle_fill#(padRect#, "#ff0000")
  IF IS_MOBILE = 1 THEN
    label_text#(lblMsg#, reason$ + " Score: " + stri$(score))
    label_text#(lblMsg2#, "Tap to retry")
  ELSE
    label_text#(lblMsg#, reason$ + " Score: " + stri$(score))
    label_text#(lblMsg2#, "Press DOWN to retry")
  END IF
  label_fontcolor#(lblMsg#, "#ff3300")
  label_fontcolor#(lblMsg2#, "#ff3300")
  LET thrustOn = 0
  LET thrustWasOn = 0
  ellipse_visible#(thrustFlame#, 0)
  ' --- Sound: cut engine, play explosion ---
  media_stop(sndThrust#)
  media_play(sndCrash#)
END FUNCTION
' ============================================================
'  MAIN GAME LOOP
' ============================================================
FUNCTION GameLoop(sender#) LOCAL rad, ax, ay, terrYBelow, cx, preVelY, preVelX
  ' On the very first tick the Android event loop (Looper) is guaranteed to be
  ' running, which is required for TMediaPlayer.prepareAsync() to deliver its
  ' onPrepared callback. Loading sounds here (rather than before form_show)
  ' ensures all five players initialise correctly on every platform.
  IF soundInitDone = 0 THEN
    LET soundInitDone = 1
    InitSounds()
    RETURN 0
  END IF
  ' Blink beacons always
  LET beaconTimer = beaconTimer + 1
  IF beaconTimer > 30 THEN
    LET beaconTimer = 0
  END IF
  IF beaconTimer > 15 THEN
    ellipse_fill#(padBeacon1#, "#00ff00")
    ellipse_fill#(padBeacon2#, "#00ff00")
  ELSE
    ellipse_fill#(padBeacon1#, "#004400")
    ellipse_fill#(padBeacon2#, "#004400")
  END IF
  IF running = 0 THEN
    RETURN 0
  END IF
  ' ========================
  '  SOUND: Thrust engine loop
  '    Start the clip on key-down (thrustWasOn 0→1).
  '    Stop it on key-up or when fuel empties (thrustWasOn 1→0).
  '    OnThrustEnd() re-triggers the clip for a seamless loop.
  ' ========================
  IF thrustOn = 1 AND fuel > 0 THEN
    IF thrustWasOn = 0 THEN
      media_play(sndThrust#)
      LET thrustWasOn = 1
    END IF
  ELSE
    IF thrustWasOn = 1 THEN
      media_stop(sndThrust#)
      LET thrustWasOn = 0
    END IF
  END IF
  ' ========================
  '  SOUND: Low-fuel warning
  '    Fires once when fuel drops below 30, never repeats mid-flight.
  ' ========================
  IF fuel < 30 AND fuel > 0 THEN
    IF lowFuelWarned = 0 THEN
      media_play(sndLowFuel#)
      LET lowFuelWarned = 1
    END IF
  END IF
  ' ========================
  '  ROTATION
  ' ========================
  IF rotateL = 1 THEN
    LET angle = angle - ROTATE_SPD
  END IF
  IF rotateR = 1 THEN
    LET angle = angle + ROTATE_SPD
  END IF
  IF angle < -90 THEN
    LET angle = -90
  END IF
  IF angle > 90 THEN
    LET angle = 90
  END IF
  ' ========================
  '  THRUST
  ' ========================
  rad = degtorad(angle)
  IF thrustOn = 1 THEN
    IF fuel > 0 THEN
      ax = sin(rad) * THRUST_POWER
      ay = cos(rad) * THRUST_POWER * -1
      LET velX = velX + ax
      LET velY = velY + ay
      LET fuel = fuel - FUEL_USE
      IF fuel < 0 THEN
        LET fuel = 0
      END IF
    END IF
  END IF
  ' Save velocity BEFORE gravity for landing evaluation
  preVelX = velX
  preVelY = velY
  ' ========================
  '  GRAVITY
  ' ========================
  LET velY = velY + GRAVITY
  ' ========================
  '  MOVE LANDER
  ' ========================
  LET landerX = landerX + velX
  LET landerY = landerY + velY
  ' ========================
  '  BOUNDARY CHECK (sides)
  ' ========================
  IF landerX < 0 THEN
    LET landerX = 0
    LET velX = velX * -0.5
  END IF
  IF landerX + LANDER_W > GAME_W THEN
    LET landerX = GAME_W - LANDER_W
    LET velX = velX * -0.5
  END IF
  ' ========================
  '  TERRAIN COLLISION
  ' ========================
  cx = landerX + LANDER_W / 2
  terrYBelow = GetTerrainYAt(cx)
  IF landerY + LANDER_H + 8 >= terrYBelow THEN
    LET landerY = terrYBelow - LANDER_H - 8
    ' Use pre-gravity velocity for fair landing evaluation
    IF IsOverPad() = 1 THEN
      IF abs(preVelY * 30) < MAX_SAFE_VY THEN
        IF abs(preVelX * 30) < MAX_SAFE_VX THEN
          IF abs(angle) < MAX_SAFE_ANGLE THEN
            LET velY = 0
            LET velX = 0
            DoLanding()
            UpdateLanderVisuals()
            RETURN 0
          END IF
        END IF
      END IF
    END IF
    ' Store pre-gravity vel for crash reason, then zero
    LET velX = preVelX
    LET velY = preVelY
    DoCrash()
    LET velX = 0
    LET velY = 0
    UpdateLanderVisuals()
    RETURN 0
  END IF
  ' ========================
  '  UPDATE VISUALS & HUD
  ' ========================
  UpdateLanderVisuals()
  UpdateHUD()
END FUNCTION
