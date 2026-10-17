' ============================================================
'  Girder - Plan9Basic
' ============================================================
'
'  A climbing game in the 1981 arcade tradition. A demolition
'  robot at the top of an unfinished building rolls oil drums down
'  the sloping girders. You are the welder at the bottom, and the
'  crane operator is stranded on the roof.
'
'  ORIGINAL CODE. Climbing ladders, jumping barrels, a hammer that
'  smashes them and someone to rescue at the top are the genre's,
'  and mechanics are not anybody's to own. Nothing here comes from
'  another implementation: no sprite was traced, no level copied,
'  no sound sampled. Every shape on screen is a rectangle# or an
'  ellipse# drawn by this file, and every sound was synthesised from
'  plain oscillators by tools/make-game-sounds.py.
'
'  Controls
'    LEFT / RIGHT   walk
'    UP / DOWN      climb a ladder
'    SPACE          jump
'    P              pause
'    R              restart, once it is over
'
'  On a phone: five buttons at the foot of the screen, and a tap on
'  the play area to start.
'
'  Points: 100 for each drum jumped, 300 for each drum smashed with
'  a hammer, and whatever is left of the bonus when you reach the
'  roof. A hammer swings on its own for a few seconds, but while it
'  is in your hands you can neither climb nor jump.
'
'  Broken ladders, the ones with a gap in the middle, cannot be
'  climbed. The drums do not care, and roll down those too.
'
'  HOW THE BUILDING IS DESCRIBED, because everything else hangs on
'  it: a girder is a straight line from (xl, yl) to (xr, yr) in a
'  560 x 700 world, and YAt(k, x) answers where its top surface is
'  at x. The drawing cuts each one into short flat segments, which
'  is what gives the steps; the physics walks the line itself.
'  The world is scaled into whatever the window or screen offers.
'
' ============================================================

randomize()

' --- Platform -------------------------------------------------
let PLATFORM$ = os_name$()
let IS_MOBILE = 0
if PLATFORM$ = "Android" then IS_MOBILE = 1
if PLATFORM$ = "iOS" then IS_MOBILE = 1
if instr(PLATFORM$, "Android") >= 0 then IS_MOBILE = 1
if instr(PLATFORM$, "iOS") >= 0 then IS_MOBILE = 1

' --- Sound ----------------------------------------------------
' Each platform gets the format it plays natively, as in the other games with
' sound: WAV on Windows, OGG on Linux and Android, MP3 anywhere else. The
' effects were synthesised by tools/make-game-sounds.py, which is where they
' can be changed.
let SOUND_BASE$ = "https://plan9basic.com/assets/sounds/girder/"
let SOUND_EXT$ = "mp3"
if instr(PLATFORM$, "Windows") >= 0 then SOUND_EXT$ = "wav"
if instr(PLATFORM$, "Linux") >= 0 then SOUND_EXT$ = "ogg"
if instr(PLATFORM$, "Android") >= 0 then SOUND_EXT$ = "ogg"

' --- Geometry -------------------------------------------------
let GAME_W = 560
let GAME_H = 780
let CTRL_H = 0
if IS_MOBILE = 1 then
  let GAME_W = form_screenwidth()
  let GAME_H = form_screenheight()
  let CTRL_H = 120
end if

' The title bar and borders take some of the height a desktop window asks for;
' tractor.bas measured 40. A phone's screen size is already the drawable area.
let CHROME_H = 40
if IS_MOBILE = 1 then let CHROME_H = 0

' And the borders take some of the WIDTH. Measured on 2026-10-17 with this file:
' a window asked for 560 wide had 544 to paint on, and the right-hand ends of
' three girders were simply not on screen. Everything is laid out in VIEW_W.
let CHROME_W = 16
if IS_MOBILE = 1 then let CHROME_W = 0
let VIEW_W = GAME_W - CHROME_W

' Proportions rather than pixels, for the same reason tractor.bas gives: a bar's
' size in pixels depends on the screen's density.
let SAFE_TOP = 0
let SAFE_BOTTOM = 0
if IS_MOBILE = 1 then
  let SAFE_TOP = cint(GAME_H * 0.055)
  let SAFE_BOTTOM = cint(GAME_H * 0.055)
end if

let PLAY_H = GAME_H - CTRL_H - CHROME_H - SAFE_BOTTOM
let HUD_H = 40 + SAFE_TOP

' The world is 560 x 700 and is scaled uniformly into the play area, then
' centred, so the building keeps its shape on any screen.
let WORLD_W = 560
let WORLD_H = 700
let SCALE = VIEW_W / WORLD_W
let SCALE_V = (PLAY_H - HUD_H) / WORLD_H
if SCALE_V < SCALE then SCALE = SCALE_V
let OFF_X = (VIEW_W - WORLD_W * SCALE) / 2

' --- The welder (world units) ---------------------------------
let PLR_W = 14
let PLR_H = 22
let WALK_SPD = 1.8
let CLIMB_SPD = 1.3
let JUMP_V = 4.2
let GRAV = 0.3
let HAMMER_TICKS = 420

' --- Drums ----------------------------------------------------
let DRUM_R = 7
let MAX_DRUM = 10

' --- The building ---------------------------------------------
let NUM_G = 7             ' six girders and the roof
let NUM_L = 11
let NUM_H = 2
let BOT_X = 8             ' the robot's box on the top girder
let BOT_W = 64
let BOT_H = 56
let DRUM_START_X = 84
let OIL_X = 36            ' a drum on the bottom girder left of this is in the drum

' --- States ---------------------------------------------------
let G_READY = 0
let G_PLAY = 1
let G_DYING = 2
let G_OVER = 3
let G_CLEAR = 4

let P_WALK = 1
let P_JUMP = 2
let P_CLIMB = 3

let D_OFF = 0
let D_ROLL = 1
let D_FALL = 2
let D_LADDER = 3

let SND_START = 1
let SND_JUMP = 2
let SND_SCORE = 3
let SND_HAMMER = 4
let SND_SMASH = 5
let SND_THROW = 6
let SND_DIE = 7
let SND_CLEAR = 8
let SND_OVER = 9
let NUM_SND = 10          ' the tenth is a second smash, so two can overlap

' --- Palette --------------------------------------------------
let BG$ = "#0b0a16"
let STAR_C$ = "#3a3760"
let INK$ = "#f4f1ff"
let DIM$ = "#8f8ab0"
let GIRDER_C$ = "#d6453d"
let GIRDER_E$ = "#7e1f1c"
let LADDER_C$ = "#58d3e8"
let DRUM_C$ = "#b8692a"
let DRUM_BAND$ = "#5a2c0b"
let HAT_C$ = "#ffd23f"
let SKIN_C$ = "#f2c49b"
let VEST_C$ = "#ff7f11"
let JEANS_C$ = "#3f6fd8"
let BOT_C$ = "#8d99ae"
let BOT_DARK$ = "#4a5568"
let VISOR_C$ = "#ff3b30"
let HAMMER_C$ = "#c9a26b"
let STEEL_C$ = "#cfd8e3"
let OPER_C$ = "#ff6fae"
let FLAME_C$ = "#ffb000"

' ============================================================
'  STATE
' ============================================================

let gstate = G_READY
let score = 0
let best = 0
let lives = 3
let level = 1
let bonus = 5000
let paused = 0
let tick = 0
let stateUntil = 0

let moveL = 0
let moveR = 0
let moveU = 0
let moveD = 0
let jumpReq = 0
let jumpHeld = 0

let px = 0                ' left edge of the welder
let py = 0                ' his feet
let pk = 1                ' the girder he is on
let pstate = P_WALK
let pvx = 0
let pvy = 0
let pLad = 0              ' the ladder he is on, while climbing
let hammerUntil = 0
let hamPose = -1          ' which hammer sprite is showing, -1 for none
let legPhase = 0

let snd# = pdim#(NUM_SND)
let soundInitDone = 0     ' set on the first tick of the loop, see GameLoop
let smashFlip = 0

let throwAt = 0
let armUp = 0
let popUntil = 0
let flick = 0

' Girders: the top surface runs from (gxl, gyl) to (gxr, gyr).
let gxl# = dim#(NUM_G)
let gxr# = dim#(NUM_G)
let gyl# = dim#(NUM_G)
let gyr# = dim#(NUM_G)

' Ladders: centre x, the girder at the foot, and whether it is broken.
let lx# = dim#(NUM_L)
let lk# = dim#(NUM_L)
let lbr# = dim#(NUM_L)

' Hammers lying on a girder.
let hx# = dim#(NUM_H)
let hk# = dim#(NUM_H)
let hOn# = dim#(NUM_H)
let hRect# = pdim#(NUM_H)

' Drums. dx/dy is the centre.
let dx# = dim#(MAX_DRUM)
let dy# = dim#(MAX_DRUM)
let dk# = dim#(MAX_DRUM)
let ds# = dim#(MAX_DRUM)
let dvy# = dim#(MAX_DRUM)
let dChk# = dim#(MAX_DRUM)     ' last ladder looked at, so it is asked once
let dScored# = dim#(MAX_DRUM)  ' jumped already
let dAng# = dim#(MAX_DRUM)
let dRect# = pdim#(MAX_DRUM)

' ============================================================
'  THE BUILDING
'
'  Every other girder slopes the other way, so a drum rolls down
'  one, falls off its low end onto the next and comes back. The
'  ladders zig-zag in the opposite sense, so the way up crosses
'  the drums' path on every floor.
' ============================================================

function SetGirder(k, xl, xr, yl, yr)
  gxl#[k] = xl
  gxr#[k] = xr
  gyl#[k] = yl
  gyr#[k] = yr
  return 0
end function

function SetLadder(i, x, k, broken)
  lx#[i] = x
  lk#[i] = k
  lbr#[i] = broken
  return 0
end function

SetGirder(1, 0, 560, 680, 668)
SetGirder(2, 0, 520, 566, 578)
SetGirder(3, 40, 560, 476, 464)
SetGirder(4, 0, 520, 362, 374)
SetGirder(5, 40, 560, 272, 260)
SetGirder(6, 0, 400, 162, 170)
SetGirder(7, 170, 310, 70, 70)

SetLadder(1, 440, 1, 0)
SetLadder(2, 240, 1, 1)
SetLadder(3, 100, 2, 0)
SetLadder(4, 300, 2, 1)
SetLadder(5, 480, 3, 0)
SetLadder(6, 200, 3, 1)
SetLadder(7, 110, 4, 0)
SetLadder(8, 330, 4, 0)
SetLadder(9, 360, 5, 0)
SetLadder(10, 170, 5, 1)
SetLadder(11, 240, 6, 0)

hx#[1] = 60
hk#[1] = 2
hx#[2] = 470
hk#[2] = 4

' Where the top surface of girder k is at x.
function YAt(k, x)
  return gyl#[k] + (gyr#[k] - gyl#[k]) * (x - gxl#[k]) / (gxr#[k] - gxl#[k])
end function

' Which way is downhill on girder k: -1 left, 1 right.
function Slope(k)
  if gyl#[k] > gyr#[k] then return -1
  return 1
end function

function ScrX(wx)
  return OFF_X + wx * SCALE
end function

function ScrY(wy)
  return HUD_H + wy * SCALE
end function

function Modn(a, b)
  return a - int(a / b) * b
end function

' ============================================================
'  DRAWING HELPERS
'
'  Two functions that answer a POINTER, so both carry # on their
'  own names. Every part has hittest off, so nothing on screen
'  swallows a click meant for the form or a button.
' ============================================================

function Part#(par#, x, y, w, h, c$) local r#
  r# = rectangle#(par#, cint(x), cint(y), max(1, cint(w)), max(1, cint(h)))
  rectangle_fill#(r#, c$)
  rectangle_strokenone#(r#)
  rectangle_hittest#(r#, 0)
  return r#
end function

function Oval#(par#, x, y, w, h, c$) local e#
  e# = ellipse#(par#, cint(x), cint(y), max(1, cint(w)), max(1, cint(h)))
  ellipse_fill#(e#, c$)
  ellipse_strokenone#(e#)
  ellipse_hittest#(e#, 0)
  return e#
end function

' ============================================================
'  THE WINDOW
' ============================================================

frm# = form#("Girder", GAME_W, GAME_H)
form_fill#(frm#, BG$)

' Do not ask the form for its client size before it is shown: tractor.bas
' measured a size belonging to no window. Everything below lays out against
' the size that was asked for.

' --- A few stars over the site, drawn first -------------------
function DrawStars() local i, t#
  for i = 1 to 26
    t# = Part#(frm#, rnd() * VIEW_W, HUD_H + rnd() * (PLAY_H - HUD_H) * 0.6, 2, 2, STAR_C$)
  next i
  return 0
end function

' --- Ladders, drawn before the girders so the girders sit over them
function DrawLadder(i) local x, y1, y2, len, yy, gapA, gapB, t#, rw
  x = lx#[i]
  y1 = YAt(lk#[i] + 1, x) + 4
  y2 = YAt(lk#[i], x)
  len = y2 - y1
  rw = 2 * SCALE
  if lbr#[i] = 0 then
    t# = Part#(frm#, ScrX(x - 8), ScrY(y1), rw, len * SCALE, LADDER_C$)
    t# = Part#(frm#, ScrX(x + 6), ScrY(y1), rw, len * SCALE, LADDER_C$)
    gapA = y2 + 1
    gapB = y2 + 1
  else
    ' A broken ladder keeps a stub at each end and nothing between.
    gapA = y1 + len * 0.3
    gapB = y2 - len * 0.3
    t# = Part#(frm#, ScrX(x - 8), ScrY(y1), rw, (gapA - y1) * SCALE, LADDER_C$)
    t# = Part#(frm#, ScrX(x + 6), ScrY(y1), rw, (gapA - y1) * SCALE, LADDER_C$)
    t# = Part#(frm#, ScrX(x - 8), ScrY(gapB), rw, (y2 - gapB) * SCALE, LADDER_C$)
    t# = Part#(frm#, ScrX(x + 6), ScrY(gapB), rw, (y2 - gapB) * SCALE, LADDER_C$)
  end if
  yy = y1 + 6
  do while yy < y2 - 2
    if yy < gapA OR yy > gapB then
      t# = Part#(frm#, ScrX(x - 8), ScrY(yy), 16 * SCALE, rw, LADDER_C$)
    end if
    yy = yy + 9
  loop
  return 0
end function

' --- Girders, cut into flat segments ---------------------------
function DrawGirder(k) local x0, w, y, r#
  x0 = gxl#[k]
  do while x0 < gxr#[k]
    w = min(40, gxr#[k] - x0)
    y = YAt(k, x0 + w / 2)
    r# = Part#(frm#, ScrX(x0), ScrY(y), w * SCALE + 1, 8 * SCALE, GIRDER_C$)
    rectangle_stroke#(r#, GIRDER_E$)
    rectangle_strokethickness#(r#, 1)
    x0 = x0 + 40
  loop
  return 0
end function

DrawStars()
for i = 1 to NUM_L
  DrawLadder(i)
next i
for i = 1 to NUM_G
  DrawGirder(i)
next i

' --- The oil drum the drums end in ------------------------------
let oilY = YAt(1, 20)
oil# = Part#(frm#, ScrX(6), ScrY(oilY - 30), 30 * SCALE, 30 * SCALE, "#2f3b52")
rectangle_corners#(oil#, 3, 3)
t# = Part#(oil#, 0, 6 * SCALE, 30 * SCALE, 3 * SCALE, STEEL_C$)
t# = Part#(oil#, 0, 21 * SCALE, 30 * SCALE, 3 * SCALE, STEEL_C$)
flame# = Oval#(frm#, ScrX(9), ScrY(oilY - 44), 24 * SCALE, 16 * SCALE, FLAME_C$)

' --- The demolition robot ---------------------------------------
let BOT_Y = YAt(6, BOT_X + BOT_W / 2) - BOT_H
bot# = Part#(frm#, ScrX(BOT_X), ScrY(BOT_Y), BOT_W * SCALE, BOT_H * SCALE, "#00000000")
t# = Part#(bot#, 6 * SCALE, 48 * SCALE, 52 * SCALE, 8 * SCALE, BOT_DARK$)
t# = Part#(bot#, 10 * SCALE, 18 * SCALE, 44 * SCALE, 32 * SCALE, BOT_C$)
rectangle_corners#(t#, 4, 4)
t# = Part#(bot#, 18 * SCALE, 26 * SCALE, 28 * SCALE, 10 * SCALE, BOT_DARK$)
t# = Part#(bot#, 16 * SCALE, 0, 32 * SCALE, 20 * SCALE, BOT_DARK$)
rectangle_corners#(t#, 3, 3)
t# = Part#(bot#, 20 * SCALE, 7 * SCALE, 24 * SCALE, 6 * SCALE, VISOR_C$)
armL# = Part#(bot#, 0, 20 * SCALE, 10 * SCALE, 26 * SCALE, BOT_C$)
armR# = Part#(bot#, 54 * SCALE, 20 * SCALE, 10 * SCALE, 26 * SCALE, BOT_C$)

' --- The crane operator on the roof -----------------------------
let OP_X = 282
let opY = YAt(7, OP_X)
oper# = Part#(frm#, ScrX(OP_X), ScrY(opY - PLR_H), PLR_W * SCALE, PLR_H * SCALE, "#00000000")
t# = Part#(oper#, 1 * SCALE, 9 * SCALE, 12 * SCALE, 13 * SCALE, OPER_C$)
t# = Oval#(oper#, 3 * SCALE, 2 * SCALE, 8 * SCALE, 8 * SCALE, SKIN_C$)
t# = Part#(oper#, 2 * SCALE, 0, 10 * SCALE, 3 * SCALE, HAT_C$)
lblHelp# = label#(frm#, "HELP!", cint(ScrX(OP_X - 20)), cint(ScrY(opY - 44)), cint(60 * SCALE), 20)
label_fontsize#(lblHelp#, 13)
label_bold#(lblHelp#, 1)
label_fontcolor#(lblHelp#, OPER_C$)

' --- Hammers lying about -----------------------------------------
for i = 1 to NUM_H
  let hy = YAt(hk#[i], hx#[i])
  r# = Part#(frm#, ScrX(hx#[i] - 6), ScrY(hy - 16), 12 * SCALE, 16 * SCALE, "#00000000")
  t# = Part#(r#, 5 * SCALE, 4 * SCALE, 2 * SCALE, 12 * SCALE, HAMMER_C$)
  t# = Part#(r#, 0, 0, 12 * SCALE, 5 * SCALE, STEEL_C$)
  hRect##[i] = r#
next i

' --- Drums --------------------------------------------------------
for i = 1 to MAX_DRUM
  ds#[i] = D_OFF
  r# = Part#(frm#, 0, 0, DRUM_R * 2 * SCALE, DRUM_R * 2 * SCALE, "#00000000")
  t# = Oval#(r#, 0, 0, DRUM_R * 2 * SCALE, DRUM_R * 2 * SCALE, DRUM_C$)
  t# = Part#(r#, (DRUM_R - 1) * SCALE, 1 * SCALE, 2 * SCALE, (DRUM_R * 2 - 2) * SCALE, DRUM_BAND$)
  t# = Part#(r#, 2 * SCALE, (DRUM_R - 1) * SCALE, (DRUM_R * 2 - 4) * SCALE, 2 * SCALE, DRUM_BAND$)
  rectangle_visible#(r#, 0)
  dRect##[i] = r#
next i

' --- The welder ---------------------------------------------------
' Built last of the moving things, so he is drawn over the drums.
let SW = PLR_W * SCALE
let SH = PLR_H * SCALE
player# = Part#(frm#, 0, 0, SW, SH, "#00000000")
legL# = Part#(player#, SW * 0.16, SH * 0.68, SW * 0.28, SH * 0.32, JEANS_C$)
legR# = Part#(player#, SW * 0.56, SH * 0.68, SW * 0.28, SH * 0.32, JEANS_C$)
t# = Part#(player#, SW * 0.1, SH * 0.36, SW * 0.8, SH * 0.36, VEST_C$)
rectangle_corners#(t#, 2, 2)
t# = Oval#(player#, SW * 0.22, SH * 0.12, SW * 0.56, SH * 0.27, SKIN_C$)
t# = Part#(player#, SW * 0.08, 0, SW * 0.84, SH * 0.17, HAT_C$)
rectangle_corners#(t#, 3, 3)

' The hammer has two poses, raised and down in front, and swings
' between them on its own.
hamUp# = Part#(player#, 0, 0, SW, SH, "#00000000")
t# = Part#(hamUp#, SW * 0.82, 0 - SH * 0.55, SW * 0.18, SH * 0.62, HAMMER_C$)
t# = Part#(hamUp#, SW * 0.55, 0 - SH * 0.78, SW * 0.72, SH * 0.3, STEEL_C$)
rectangle_visible#(hamUp#, 0)
hamDn# = Part#(player#, 0, 0, SW, SH, "#00000000")
t# = Part#(hamDn#, SW * 0.9, SH * 0.36, SW * 0.7, SH * 0.14, HAMMER_C$)
t# = Part#(hamDn#, SW * 1.45, SH * 0.12, SW * 0.32, SH * 0.6, STEEL_C$)
rectangle_visible#(hamDn#, 0)

' --- HUD and messages ----------------------------------------------
lblScore# = label#(frm#, "", 12, 8 + SAFE_TOP, cint(VIEW_W * 0.38), 24)
label_fontsize#(lblScore#, 15)
label_bold#(lblScore#, 1)
label_fontcolor#(lblScore#, INK$)

lblLevel# = label#(frm#, "", cint(VIEW_W * 0.38), 8 + SAFE_TOP, cint(VIEW_W * 0.24), 24)
label_fontsize#(lblLevel#, 15)
label_bold#(lblLevel#, 1)
label_textalign#(lblLevel#, 0)
label_fontcolor#(lblLevel#, HAT_C$)

lblBonus# = label#(frm#, "", cint(VIEW_W * 0.62), 8 + SAFE_TOP, cint(VIEW_W * 0.38) - 14, 24)
label_fontsize#(lblBonus#, 15)
label_bold#(lblBonus#, 1)
label_textalign#(lblBonus#, 2)
label_fontcolor#(lblBonus#, LADDER_C$)

lblBig# = label#(frm#, "", 0, cint(PLAY_H * 0.42), VIEW_W, 44)
label_fontsize#(lblBig#, 30)
label_bold#(lblBig#, 1)
label_textalign#(lblBig#, 0)
label_fontcolor#(lblBig#, INK$)

lblSmall# = label#(frm#, "", 0, cint(PLAY_H * 0.42) + 46, VIEW_W, 28)
label_fontsize#(lblSmall#, 15)
label_textalign#(lblSmall#, 0)
label_fontcolor#(lblSmall#, DIM$)

lblPop# = label#(frm#, "", 0, 0, 60, 20)
label_fontsize#(lblPop#, 13)
label_bold#(lblPop#, 1)
label_fontcolor#(lblPop#, HAT_C$)
label_visible#(lblPop#, 0)

' --- On-screen controls, mobile only -------------------------------
' Five buttons that set exactly the variables the keyboard sets.
function Pad#(x, w, cap$, down$, up$) local r#, c#, y, h
  y = PLAY_H + SAFE_BOTTOM * 0 + 10
  h = CTRL_H - 24
  r# = rectangle#(frm#, cint(x), cint(y), cint(w), cint(h))
  rectangle_fill#(r#, "#151a33")
  rectangle_stroke#(r#, "#4b5fb0")
  rectangle_strokethickness#(r#, 2)
  rectangle_corners#(r#, 12, 12)
  rectangle_onmousedown#(r#, down$)
  rectangle_onmouseup#(r#, up$)
  c# = label#(frm#, cap$)
  label_autosize#(c#, 0)
  label_move#(c#, cint(x), cint(y))
  label_size#(c#, cint(w), cint(h))
  label_fontsize#(c#, 22)
  label_bold#(c#, 1)
  label_fontcolor#(c#, "#a9b8f0")
  label_textalign#(c#, 0)
  label_vertalign#(c#, 0)
  label_hittest#(c#, 0)
  return r#
end function

if IS_MOBILE = 1 then
  let padW = cint(VIEW_W / 5) - 8
  p1# = Pad#(4, padW, "<", "PadLDown", "PadLUp")
  p2# = Pad#(4 + (padW + 8), padW, ">", "PadRDown", "PadRUp")
  p3# = Pad#(4 + (padW + 8) * 2, padW, "JUMP", "PadJDown", "PadJUp")
  p4# = Pad#(4 + (padW + 8) * 3, padW, "^", "PadUDown", "PadUUp")
  p5# = Pad#(4 + (padW + 8) * 4, padW, "v", "PadDDown", "PadDUp")

  tapArea# = rectangle#(frm#, 0, HUD_H, VIEW_W, PLAY_H - HUD_H)
  rectangle_fill#(tapArea#, "#00000000")
  rectangle_strokenone#(tapArea#)
  rectangle_sendtoback#(tapArea#)
  rectangle_onmousedown#(tapArea#, "PadTap")
end if

' ============================================================
'  SCREEN
' ============================================================

function Hud()
  label_text#(lblScore#, "SCORE " + str$(cint(score)))
  label_text#(lblLevel#, "LEVEL " + str$(cint(level)))
  label_text#(lblBonus#, "BONUS " + str$(cint(bonus)) + "   x" + str$(cint(lives)))
  return 0
end function

function Message(big$, small$)
  label_text#(lblBig#, big$)
  label_text#(lblSmall#, small$)
  return 0
end function

function Pop(t$, wx, wy)
  label_text#(lblPop#, t$)
  label_move#(lblPop#, cint(ScrX(wx) - 16), cint(ScrY(wy) - 24))
  label_visible#(lblPop#, 1)
  popUntil = tick + 40
  return 0
end function

' The hammer sprite showing: -1 none, 0 raised, 1 down. Written only on change.
function HammerPose(want)
  if want = hamPose then return 0
  rectangle_visible#(hamUp#, 0)
  rectangle_visible#(hamDn#, 0)
  if want = 0 then rectangle_visible#(hamUp#, 1)
  if want = 1 then rectangle_visible#(hamDn#, 1)
  hamPose = want
  return 0
end function

function PlacePlayer() local moving, lift, base
  rectangle_move#(player#, cint(ScrX(px)), cint(ScrY(py - PLR_H)))

  if hammerUntil > 0 then
    HammerPose(Modn(int(tick / 9), 2))
  else
    HammerPose(-1)
  end if

  ' Legs step only while something is moving him, and only every
  ' sixth frame, so this is two writes a step and none standing still.
  moving = 0
  if pstate = P_WALK AND moveL + moveR = 1 then moving = 1
  if pstate = P_CLIMB AND moveU + moveD = 1 then moving = 1
  if moving = 1 AND Modn(tick, 6) = 0 then
    legPhase = 1 - legPhase
    lift = 3 * SCALE
    base = SH * 0.68
    rectangle_move#(legL#, cint(SW * 0.16), cint(base - lift * legPhase))
    rectangle_move#(legR#, cint(SW * 0.56), cint(base - lift * (1 - legPhase)))
  end if
  return 0
end function

function PlaceDrum(i) local rd
  rectangle_move#(dRect##[i], cint(ScrX(dx#[i] - DRUM_R)), cint(ScrY(dy#[i] - DRUM_R)))
  if ds#[i] = D_ROLL AND Modn(tick, 3) = 0 then
    rd = Slope(dk#[i])
    dAng#[i] = dAng#[i] + 30 * rd
    rectangle_rotation#(dRect##[i], dAng#[i])
  end if
  return 0
end function

' The oil fire and the operator's call for help, blinking. They run in every
' state, paused included, because they are scenery.
function Flicker()
  if Modn(tick, 14) <> 0 then return 0
  flick = 1 - flick
  if flick = 1 then
    ellipse_fill#(flame#, FLAME_C$)
    label_visible#(lblHelp#, 1)
  else
    ellipse_fill#(flame#, "#ff5a1f")
    label_visible#(lblHelp#, 0)
  end if
  return 0
end function

' ============================================================
'  LEVELS
' ============================================================

function DrumSpeed() local v
  v = 1.6 + level * 0.25
  if v > 3.1 then v = 3.1
  return v
end function

' How likely a drum is to take a ladder down when it rolls over one.
'
' Per ladder, and a drum crosses about nine on the way down, so this compounds:
' 0.28 a ladder meant every one of thirty test drums took at least one, and the
' first level was chaos. 0.14 leaves about a quarter rolling all the way.
function LadderOdds() local v
  v = 0.10 + level * 0.04
  if v > 0.40 then v = 0.40
  return v
end function

function ThrowGap() local v
  v = 190 - level * 20
  if v < 80 then v = 80
  return v + cint(rnd() * 50)
end function

function ClearDrums() local i
  for i = 1 to MAX_DRUM
    ds#[i] = D_OFF
    rectangle_visible#(dRect##[i], 0)
  next i
  return 0
end function

function ResetLevel() local i
  ClearDrums()
  pk = 1
  px = 44
  py = YAt(1, px + PLR_W / 2)
  pstate = P_WALK
  pvx = 0
  pvy = 0
  hammerUntil = 0
  bonus = 5000
  throwAt = tick + 90
  armUp = 0
  rectangle_move#(armR#, cint(54 * SCALE), cint(20 * SCALE))
  rectangle_opacity#(player#, 1)
  for i = 1 to NUM_H
    hOn#[i] = 1
    rectangle_visible#(hRect##[i], 1)
  next i
  label_visible#(lblPop#, 0)
  PlacePlayer()
  Hud()
  return 0
end function

' ============================================================
'  SOUND
'
'  One player per effect, loaded on the first tick of the loop
'  rather than at start: Android's media player needs the event
'  loop running, and space_invaders.bas found that out first.
'  Until then Sfx() does nothing, which is also what keeps the
'  test runner, whose timers never fire, silent.
' ============================================================

function LoadSound#(name$, vol) local p#
  p# = media_player#()
  media_load#(p#, SOUND_BASE$ + name$ + "." + SOUND_EXT$)
  media_volume#(p#, vol)
  return p#
end function

function InitSounds()
  snd##[SND_START] = LoadSound#("start", 0.7)
  snd##[SND_JUMP] = LoadSound#("jump", 0.6)
  snd##[SND_SCORE] = LoadSound#("score", 0.7)
  snd##[SND_HAMMER] = LoadSound#("hammer", 0.7)
  snd##[SND_SMASH] = LoadSound#("smash", 0.8)
  snd##[SND_THROW] = LoadSound#("throw", 0.5)
  snd##[SND_DIE] = LoadSound#("die", 0.8)
  snd##[SND_CLEAR] = LoadSound#("clear", 0.8)
  snd##[SND_OVER] = LoadSound#("over", 0.8)
  snd##[NUM_SND] = LoadSound#("smash", 0.8)
  return 0
end function

function Sfx(n)
  if soundInitDone = 0 then return 0
  ' Two drums smashed a few frames apart should both be heard, so smashes
  ' take turns between two players.
  if n = SND_SMASH then
    smashFlip = 1 - smashFlip
    if smashFlip = 1 then n = NUM_SND
  end if
  media_stop(snd##[n])
  media_play(snd##[n])
  return 0
end function

function NewGame()
  Sfx(SND_START)
  score = 0
  lives = 3
  level = 1
  ResetLevel()
  Message("", "")
  gstate = G_PLAY
  Hud()
  return 0
end function

function NextLevel()
  level = level + 1
  ResetLevel()
  Message("", "")
  gstate = G_PLAY
  return 0
end function

function LevelClear()
  score = score + bonus
  Sfx(SND_CLEAR)
  gstate = G_CLEAR
  stateUntil = tick + 150
  Message("RESCUED!", "bonus " + str$(cint(bonus)))
  Hud()
  return 0
end function

function Die(big$)
  lives = lives - 1
  hammerUntil = 0
  rectangle_opacity#(player#, 0.35)
  Hud()
  if lives < 1 then
    Sfx(SND_OVER)
    gstate = G_OVER
    if score > best then best = score
    Message("GAME OVER", "R to play again   -   best " + str$(cint(best)))
    return 0
  end if
  Sfx(SND_DIE)
  gstate = G_DYING
  stateUntil = tick + 90
  Message(big$, "")
  return 0
end function

function AfterDeath()
  ResetLevel()
  Message("", "")
  gstate = G_PLAY
  return 0
end function

' ============================================================
'  THE WELDER
' ============================================================

' A ladder he can climb UP from girder k, standing at cx. Broken ones do not count.
function LadderUp(k, cx) local i
  for i = 1 to NUM_L
    if lk#[i] = k AND lbr#[i] = 0 AND abs(cx - lx#[i]) <= 6 then return i
  next i
  return 0
end function

' A ladder he can climb DOWN from girder k.
function LadderDown(k, cx) local i
  for i = 1 to NUM_L
    if lk#[i] = k - 1 AND lbr#[i] = 0 AND abs(cx - lx#[i]) <= 6 then return i
  next i
  return 0
end function

function StartClimb(li)
  pstate = P_CLIMB
  pLad = li
  px = lx#[li] - PLR_W / 2
  return 0
end function

function KeepOnGirder()
  if px < gxl#[pk] then px = gxl#[pk]
  if px + PLR_W > gxr#[pk] then px = gxr#[pk] - PLR_W
  return 0
end function

function StepWalk() local dxp, cx, li
  dxp = 0
  if moveL = 1 then dxp = dxp - WALK_SPD
  if moveR = 1 then dxp = dxp + WALK_SPD
  px = px + dxp
  KeepOnGirder()
  cx = px + PLR_W / 2
  py = YAt(pk, cx)

  if hammerUntil = 0 then
    if jumpReq = 1 then
      pstate = P_JUMP
      pvy = 0 - JUMP_V
      pvx = dxp
      Sfx(SND_JUMP)
      return 0
    end if
    if moveU = 1 then
      li = LadderUp(pk, cx)
      if li > 0 then StartClimb(li)
    end if
    if moveD = 1 AND pstate = P_WALK then
      li = LadderDown(pk, cx)
      if li > 0 then StartClimb(li)
    end if
  end if

  if pstate = P_WALK then PickHammer()
  return 0
end function

function StepJump() local cx, gy
  px = px + pvx
  KeepOnGirder()
  cx = px + PLR_W / 2
  py = py + pvy
  pvy = pvy + GRAV
  JumpScore(cx)
  gy = YAt(pk, cx)
  if pvy > 0 AND py >= gy then
    py = gy
    pstate = P_WALK
  end if
  return 0
end function

function StepClimb() local topY, footY
  topY = YAt(lk#[pLad] + 1, lx#[pLad])
  footY = YAt(lk#[pLad], lx#[pLad])
  if moveU = 1 then py = py - CLIMB_SPD
  if moveD = 1 then py = py + CLIMB_SPD
  ' Off the ladder only at an end, and only moving that way, so starting
  ' down from the top does not count as having arrived at it.
  if moveD = 1 AND py >= footY then
    py = footY
    pk = lk#[pLad]
    pstate = P_WALK
    return 0
  end if
  if moveU = 1 AND py <= topY then
    py = topY
    pk = lk#[pLad] + 1
    pstate = P_WALK
    if pk = NUM_G then LevelClear()
    return 0
  end if
  if py > footY then py = footY
  if py < topY then py = topY
  return 0
end function

function PickHammer() local i
  for i = 1 to NUM_H
    if hOn#[i] = 1 AND hk#[i] = pk AND abs(px + PLR_W / 2 - hx#[i]) < 10 then
      hOn#[i] = 0
      rectangle_visible#(hRect##[i], 0)
      hammerUntil = tick + HAMMER_TICKS
      Sfx(SND_HAMMER)
    end if
  next i
  return 0
end function

' A drum passing underneath him in the air, once per drum.
function JumpScore(cx) local i
  for i = 1 to MAX_DRUM
    if ds#[i] = D_ROLL AND dk#[i] = pk AND dScored#[i] = 0 then
      if abs(dx#[i] - cx) < 12 AND py < dy#[i] - DRUM_R + 2 then
        dScored#[i] = 1
        score = score + 100
        Sfx(SND_SCORE)
        Pop("100", dx#[i], dy#[i] - 20)
        Hud()
      end if
    end if
  next i
  return 0
end function

function StepPlayer()
  if hammerUntil > 0 AND tick > hammerUntil then hammerUntil = 0
  if pstate = P_WALK then
    StepWalk()
  elseif pstate = P_JUMP then
    StepJump()
  else
    StepClimb()
  end if
  jumpReq = 0
  if gstate = G_PLAY then PlacePlayer()
  return 0
end function

' ============================================================
'  THE ROBOT AND THE DRUMS
' ============================================================

function StepRobot()
  ' The arm comes up a little before each throw, which is the
  ' warning, and drops as the drum leaves.
  if armUp = 0 AND tick >= throwAt - 26 then
    armUp = 1
    rectangle_move#(armR#, cint(54 * SCALE), 0)
  end if
  if tick >= throwAt then
    SpawnDrum()
    Sfx(SND_THROW)
    armUp = 0
    rectangle_move#(armR#, cint(54 * SCALE), cint(20 * SCALE))
    throwAt = tick + ThrowGap()
  end if
  return 0
end function

function SpawnDrum() local i
  for i = 1 to MAX_DRUM
    if ds#[i] = D_OFF then
      ds#[i] = D_ROLL
      dk#[i] = 6
      dx#[i] = DRUM_START_X
      dy#[i] = YAt(6, DRUM_START_X) - DRUM_R
      dvy#[i] = 0
      dChk#[i] = 0
      dScored#[i] = 0
      rectangle_visible#(dRect##[i], 1)
      PlaceDrum(i)
      return 0
    end if
  next i
  return 0
end function

function KillDrum(i)
  ds#[i] = D_OFF
  rectangle_visible#(dRect##[i], 0)
  return 0
end function

' A ladder going DOWN from girder k under the drum. Broken ones count: a drum
' fits through the gap that a welder cannot climb.
function LadderBelow(k, x, spd) local i
  for i = 1 to NUM_L
    if lk#[i] = k - 1 AND abs(x - lx#[i]) < spd then return i
  next i
  return 0
end function

function RollDrum(i, spd) local k, x, li
  k = dk#[i]
  x = dx#[i] + spd * Slope(k)
  dx#[i] = x
  if k = 1 AND x < OIL_X then
    KillDrum(i)
    return 0
  end if
  if x < gxl#[k] OR x > gxr#[k] then
    ds#[i] = D_FALL
    dvy#[i] = 0.5
    return 0
  end if
  dy#[i] = YAt(k, x) - DRUM_R
  if k > 1 then
    li = LadderBelow(k, x, spd)
    if li > 0 AND dChk#[i] <> li then
      dChk#[i] = li
      if rnd() < LadderOdds() then
        ds#[i] = D_LADDER
        dx#[i] = lx#[li]
      end if
    end if
  end if
  return 0
end function

function FallDrum(i) local k, nk, x
  k = dk#[i]
  dx#[i] = dx#[i] + Slope(k) * 0.8
  dy#[i] = dy#[i] + dvy#[i]
  dvy#[i] = dvy#[i] + 0.3
  if k > 1 then
    nk = k - 1
    x = dx#[i]
    if x >= gxl#[nk] AND x <= gxr#[nk] AND dy#[i] + DRUM_R >= YAt(nk, x) then
      dk#[i] = nk
      ds#[i] = D_ROLL
      dy#[i] = YAt(nk, x) - DRUM_R
      dChk#[i] = 0
    end if
  end if
  if dy#[i] > WORLD_H + 20 then KillDrum(i)
  return 0
end function

function LadderDrum(i) local k
  dy#[i] = dy#[i] + 1.4 + level * 0.15
  k = dk#[i] - 1
  if dy#[i] + DRUM_R >= YAt(k, dx#[i]) then
    dk#[i] = k
    ds#[i] = D_ROLL
    dy#[i] = YAt(k, dx#[i]) - DRUM_R
    dChk#[i] = 0
  end if
  return 0
end function

function StepDrums() local i, st, spd
  spd = DrumSpeed()
  for i = 1 to MAX_DRUM
    st = ds#[i]
    if st = D_ROLL then RollDrum(i, spd)
    if st = D_FALL then FallDrum(i)
    if st = D_LADDER then LadderDrum(i)
    if ds#[i] <> D_OFF then PlaceDrum(i)
  next i
  return 0
end function

' ============================================================
'  COLLISIONS
' ============================================================

function Overlap(ax, ay, aw, ah, bx, by, bw, bh)
  if ax + aw < bx then return 0
  if bx + bw < ax then return 0
  if ay + ah < by then return 0
  if by + bh < ay then return 0
  return 1
end function

function Collide() local i, x0, y0, sz, bx0, by0
  ' His box, a little smaller than the sprite, so a graze is a near miss.
  bx0 = px + 2
  by0 = py - PLR_H + 3
  if Overlap(bx0, by0, PLR_W - 4, PLR_H - 4, BOT_X, BOT_Y, BOT_W, BOT_H) = 1 then
    Die("FLATTENED")
    return 0
  end if
  for i = 1 to MAX_DRUM
    if ds#[i] <> D_OFF then
      x0 = dx#[i] - DRUM_R + 2
      y0 = dy#[i] - DRUM_R + 2
      sz = DRUM_R * 2 - 4
      if hammerUntil > 0 then
        if Overlap(px - 20, py - PLR_H - 18, PLR_W + 40, PLR_H + 18, x0, y0, sz, sz) = 1 then
          KillDrum(i)
          score = score + 300
          Sfx(SND_SMASH)
          Pop("300", dx#[i], dy#[i])
          Hud()
        end if
      end if
      if ds#[i] <> D_OFF then
        if Overlap(bx0, by0, PLR_W - 4, PLR_H - 4, x0, y0, sz, sz) = 1 then
          Die("CRUSHED")
          return 0
        end if
      end if
    end if
  next i
  return 0
end function

function StepBonus()
  if Modn(tick, 120) <> 0 then return 0
  bonus = bonus - 100
  if bonus <= 0 then
    bonus = 0
    Hud()
    Die("OUT OF TIME")
    return 0
  end if
  Hud()
  return 0
end function

' ============================================================
'  THE LOOP
' ============================================================

function GameLoop(sender#)
  if soundInitDone = 0 then
    soundInitDone = 1
    InitSounds()
    return 0
  end if
  tick = tick + 1
  Flicker()
  if paused = 1 then return 0

  if gstate = G_PLAY then
    StepPlayer()
    if gstate = G_PLAY then StepRobot()
    if gstate = G_PLAY then StepDrums()
    if gstate = G_PLAY then Collide()
    if gstate = G_PLAY then StepBonus()
  end if

  if popUntil > 0 AND tick > popUntil then
    popUntil = 0
    label_visible#(lblPop#, 0)
  end if

  if gstate = G_DYING AND tick > stateUntil then AfterDeath()
  if gstate = G_CLEAR AND tick > stateUntil then NextLevel()
  return 0
end function

' ============================================================
'  INPUT
'
'  Space arrives as the CHARACTER with the code left at zero, and
'  the arrows as codes with no character; tractor.bas found that
'  out the hard way. Both forms are accepted for the jump.
'
'  A jump is taken on the press, not while the key is held, so
'  the keyboard's auto-repeat cannot turn one press into a string
'  of hops.
' ============================================================

function JumpPress()
  if gstate = G_READY then
    NewGame()
    return 0
  end if
  if jumpHeld = 0 then jumpReq = 1
  jumpHeld = 1
  return 0
end function

function OnKeyDown(sender#, keyCode, keyChar$, shiftState$)
  if keyChar$ = "p" OR keyChar$ = "P" then TogglePause()
  if keyChar$ = "r" OR keyChar$ = "R" then MaybeRestart()
  if keyCode = 37 then moveL = 1
  if keyCode = 39 then moveR = 1
  if keyCode = 38 then moveU = 1
  if keyCode = 40 then moveD = 1
  if keyChar$ = " " OR keyCode = 32 then JumpPress()
  return 0
end function

function OnKeyUp(sender#, keyCode, keyChar$, shiftState$)
  if keyCode = 37 then moveL = 0
  if keyCode = 39 then moveR = 0
  if keyCode = 38 then moveU = 0
  if keyCode = 40 then moveD = 0
  if keyChar$ = " " OR keyCode = 32 then jumpHeld = 0
  return 0
end function

' A mouse handler is (sender#, button, x, y, shift$), shift last. The engine
' matches handlers by their exact signature, so any other order is never called.
function PadLDown(sender#, button, x, y, shift$)
  moveL = 1
  return 0
end function
function PadLUp(sender#, button, x, y, shift$)
  moveL = 0
  return 0
end function
function PadRDown(sender#, button, x, y, shift$)
  moveR = 1
  return 0
end function
function PadRUp(sender#, button, x, y, shift$)
  moveR = 0
  return 0
end function
function PadUDown(sender#, button, x, y, shift$)
  moveU = 1
  return 0
end function
function PadUUp(sender#, button, x, y, shift$)
  moveU = 0
  return 0
end function
function PadDDown(sender#, button, x, y, shift$)
  moveD = 1
  return 0
end function
function PadDUp(sender#, button, x, y, shift$)
  moveD = 0
  return 0
end function
function PadJDown(sender#, button, x, y, shift$)
  JumpPress()
  return 0
end function
function PadJUp(sender#, button, x, y, shift$)
  jumpHeld = 0
  return 0
end function
function PadTap(sender#, button, x, y, shift$)
  if gstate = G_READY then NewGame()
  MaybeRestart()
  return 0
end function

function TogglePause()
  if gstate <> G_PLAY then return 0
  if paused = 1 then
    paused = 0
    Message("", "")
  else
    paused = 1
    Message("PAUSED", "P to carry on")
  end if
  return 0
end function

function MaybeRestart()
  if gstate = G_OVER then NewGame()
  return 0
end function

' ============================================================
'  GO
' ============================================================

form_onkeydown#(frm#, "OnKeyDown")
form_onkeyup#(frm#, "OnKeyUp")

tmr# = timer#()
timer_interval#(tmr#, 16)
timer_ontimer#(tmr#, "GameLoop")
timer_start#(tmr#)

form_show(frm#)

ResetLevel()
if IS_MOBILE = 1 then
  Message("GIRDER", "tap to start")
else
  Message("GIRDER", "space to start   -   arrows to walk and climb")
end if
