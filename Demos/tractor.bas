' ============================================================
'  Tractor - Plan9Basic
' ============================================================
'
'  A fixed shooter in the 1981 arcade tradition: enemies fly in
'  along curved paths rather than appearing in place, settle into
'  a formation that breathes, and peel off to dive at you. The
'  green leaders carry a capture beam.
'
'  ORIGINAL CODE. The mechanics below are the genre's -- formation
'  entries, diving attacks, a capture beam and the doubled fighter
'  that follows a rescue -- and mechanics are not anybody's to own.
'  Nothing here is derived from another implementation: no sprite
'  was traced, no path table copied, no sound sampled. Every shape
'  on screen is a rectangle# or an ellipse# drawn by this file.
'
'  Controls
'    LEFT / RIGHT   move
'    SPACE or UP    fire
'    P              pause
'    R              restart, once it is over
'
'  On a phone: three buttons at the foot of the screen, and a tap
'  anywhere on the play area to start again once it is over.
'
'  HOW A CAPTURE WORKS, because it is the part worth playing for:
'  a leader dives, stops above you and opens a beam. Sit in it and
'  your fighter is taken -- you lose a life and the fighter joins
'  the leader's formation slot. Shoot that leader while it dives
'  and the fighter comes back alongside you: two ships, two shots
'  a volley, twice the width to get hit in.
'
'  THREE THINGS ABOUT THE DIALECT, all of them measured while
'  writing this rather than assumed:
'
'    * dim# and pdim# arrays are 1-BASED, which is the opposite of
'      instr and mid$. And an element of a POINTER array is written
'      with two hashes -- eRect##[i], not eRect#[i] -- while a
'      numeric one takes one. Getting that wrong answers "Value
'      expected" at the assignment.
'
'    * Square root is sqr(), not sqrt -- and it took a look at the
'      documentation to find, after grepping the registration
'      tables came up empty. The docs are checked against the code
'      by tools/check-docs.py, so they are the surface to search.
'      Distances here are still compared SQUARED, which avoids the
'      call altogether and is the faster comparison. There is no pi
'      constant, so one is declared below.
'
'    * A function answering a POINTER carries # on its own name,
'      as a variable does. Without it the function is numeric and
'      the assignment answers "Pointer expected", which reads like
'      a fault at the call rather than in the declaration.
'
' ============================================================

randomize()

' --- Platform -------------------------------------------------
' A phone has no arrow keys and no space bar, so on mobile the bottom of the
' screen becomes a control strip and the play area shrinks to fit above it.
' Every other game in this folder does the same; this one did not, and would
' have opened on Android and been unplayable.
let PLATFORM$ = os_name$()
let IS_MOBILE = 0
if PLATFORM$ = "Android" then IS_MOBILE = 1
if PLATFORM$ = "iOS" then IS_MOBILE = 1
if instr(PLATFORM$, "Android") >= 0 then IS_MOBILE = 1
if instr(PLATFORM$, "iOS") >= 0 then IS_MOBILE = 1

' --- Geometry -------------------------------------------------
let GAME_W = 560
let GAME_H = 780
let CTRL_H = 0
if IS_MOBILE = 1 then
  let GAME_W = form_screenwidth()
  let GAME_H = form_screenheight()
  let CTRL_H = 120
end if

' A desktop window does not draw on all of the height it was given: the title
' bar and borders take some. Measured on 2026-08-27, a form asked for 780 had
' 741 to paint on, so 40 is the allowance. On a phone the screen size already IS
' the drawable area and nothing is taken.
let CHROME_H = 40
if IS_MOBILE = 1 then let CHROME_H = 0

' SYSTEM BARS. An app targeting Android 16 draws under the status bar and the
' navigation bar, and there is no opting out at that target -- it is the
' platform, not the phone. Nothing in this engine can ask where those bars are,
' so the only honest thing an applet can do is keep clear of them.
'
' These are proportions rather than pixels because a bar's size in pixels
' depends on the screen's density, and a fraction of the height travels between
' devices where a constant does not. They are a guess, and a generous one: it
' is better to leave a band of stars unused than to put the fire button under
' the navigation bar, which is what happened without them.
let SAFE_TOP = 0
let SAFE_BOTTOM = 0
if IS_MOBILE = 1 then
  let SAFE_TOP = cint(GAME_H * 0.055)
  let SAFE_BOTTOM = cint(GAME_H * 0.055)
end if

' Everything that flies lives above the control strip, so the play area is what
' the game measures against -- not the window.
let PLAY_H = GAME_H - CTRL_H - CHROME_H - SAFE_BOTTOM
let HUD_H = 44 + SAFE_TOP

let PI = 3.14159265358979

' --- Player ---------------------------------------------------
let SHIP_W = 26
let SHIP_H = 20
let SHIP_Y = PLAY_H - 60
let SHIP_SPEED = 5
let SHIP_GAP = 4          ' between the two hulls of a doubled fighter

' --- Shots ----------------------------------------------------
let MAX_SHOT = 6
let SHOT_W = 3
let SHOT_H = 12
let SHOT_SPEED = 11
let MAX_EBOMB = 14
let EBOMB_W = 4
let EBOMB_H = 10
let EBOMB_SPEED = 4

' --- The formation --------------------------------------------
let ROWS = 5
let COLS = 8
let MAX_ENEMY = 40        ' ROWS * COLS
let CELL_W = 46
let CELL_H = 38
' Eight columns of 46 is 368 pixels, which is wider than a narrow phone. On
' mobile the cell shrinks to whatever the screen affords.
if IS_MOBILE = 1 then
  let CELL_W = cint((GAME_W - 24) / COLS)
  let CELL_H = cint(CELL_W * 0.82)
end if
let FORM_TOP = HUD_H + 40
let FORM_LEFT = (GAME_W - COLS * CELL_W) / 2 + 8
let ENEMY_W = 24
let ENEMY_H = 20

' --- Enemy states ---------------------------------------------
let ST_DEAD = 0
let ST_ENTER = 1          ' flying the entry arc
let ST_FORM = 2           ' sitting in the formation
let ST_DIVE = 3           ' peeled off, attacking
let ST_BEAM = 4           ' hovering with the capture beam open
let ST_RETURN = 5         ' re-entering from the top after a dive

' --- Enemy kinds ----------------------------------------------
let K_WASP = 1            ' bottom rows, 50 points
let K_ESCORT = 2          ' middle rows, 80 points
let K_LEADER = 3          ' top row, 150, and the only one that captures

' --- Game states ----------------------------------------------
let G_READY = 0
let G_PLAY = 1
let G_DYING = 2
let G_OVER = 3
let G_CLEAR = 4

' --- Palette --------------------------------------------------
let BG$ = "#05060f"
let INK$ = "#e8ecff"
let DIM$ = "#7d8ab8"
let SHIP_C$ = "#8fe3ff"
let SHOT_C$ = "#ffffff"
let WASP_C$ = "#4fc3f7"
let ESC_C$ = "#ff7043"
let LEAD_C$ = "#69f0ae"
let BEAM_C$ = "#b388ff"
let BOMB_C$ = "#ffd54f"
let STAR_C$ = "#5b6690"

' ============================================================
'  STATE
' ============================================================

let gstate = G_READY
let score = 0
let best = 0
let lives = 3
let wave = 1
let challenge = 0         ' 1 while a challenge stage is running
let paused = 0
let tick = 0
let dyingUntil = 0
let clearUntil = 0

let shipX = GAME_W / 2 - SHIP_W / 2
let dual = 0              ' 1 once a captured fighter has been rescued
let moveL = 0
let moveR = 0
let firing = 0
let fireCool = 0

let captiveIdx = 0        ' which enemy is holding a captured fighter
let beamIdx = 0           ' which enemy has its beam open
let beamFrames = 0
let enteredCount = 0
let aliveCount = 0
let formPhase = 0         ' drives the formation's side-to-side breathing

' Arrays are 1-based here, which is the opposite of instr and mid$.
let eX# = pointer#(0)
let eY# = pointer#(0)
let eKind# = pointer#(0)
let eState# = pointer#(0)
let eRow# = pointer#(0)
let eCol# = pointer#(0)
let eT# = pointer#(0)        ' 0..1 along whatever path it is flying
let eSpeed# = pointer#(0)
let eDelay# = pointer#(0)    ' ticks to wait before entering
let eSide# = pointer#(0)     ' which side the entry arc comes from
let eDiveX# = pointer#(0)    ' where the dive was aimed
let eShown# = pointer#(0)
let eRect# = pointer#(0)

let sX# = pointer#(0)
let sY# = pointer#(0)
let sOn# = pointer#(0)
let sRect# = pointer#(0)

let bX# = pointer#(0)
let bY# = pointer#(0)
let bOn# = pointer#(0)
let bRect# = pointer#(0)

let starX# = pointer#(0)
let starY# = pointer#(0)
let starV# = pointer#(0)
let starR# = pointer#(0)
' Sixty stars cost sixty control moves a frame for decoration. Twenty-four
' moved on alternate frames reads the same and costs a fifth as much.
let NUM_STARS = 24

' ============================================================
'  THE WINDOW
' ============================================================

frm# = form#("Tractor", GAME_W, GAME_H)
form_fill#(frm#, BG$)

' DO NOT ASK THE FORM FOR ITS CLIENT SIZE HERE. A form that has not been shown
' has not been laid out either, and answers a size belonging to no window:
' measured on 2026-08-27, a form created at 560x780 reported a client area of
' 624x441 before form_show and 544x741 after. Laying out against the first pair
' put the fighter in the middle of the screen and ran the HUD off the right
' edge, which is what a screenshot showed and no check here could.
'
' So the layout stays with the size that was ASKED FOR, and the HUD is inset far
' enough from the edge that the frame it loses cannot clip it.

' --- Starfield, drawn first so everything else sits over it ---
let starX# = dim#(NUM_STARS)
let starY# = dim#(NUM_STARS)
let starV# = dim#(NUM_STARS)
let starR# = pdim#(NUM_STARS)
for i = 1 to NUM_STARS
  starX#[i] = cint(rnd() * GAME_W)
  starY#[i] = cint(rnd() * PLAY_H)
  starV#[i] = 1 + cint(rnd() * 2)
  let st# = rectangle#(frm#, starX#[i], starY#[i], 2, 2)
  rectangle_fill#(st#, STAR_C$)
  rectangle_strokenone#(st#)
  starR##[i] = st#
next i

' --- HUD ------------------------------------------------------
lblScore# = label#(frm#, "", 16, 10, 240, 26)
label_fontsize#(lblScore#, 16)
label_bold#(lblScore#, 1)
label_fontcolor#(lblScore#, INK$)

lblWave# = label#(frm#, "", GAME_W / 2 - 90, 10, 180, 26)
label_fontsize#(lblWave#, 16)
label_bold#(lblWave#, 1)
label_textalign#(lblWave#, 0)
label_fontcolor#(lblWave#, LEAD_C$)

lblLives# = label#(frm#, "", GAME_W - 250, 10, 220, 26)
label_fontsize#(lblLives#, 16)
label_bold#(lblLives#, 1)
label_textalign#(lblLives#, 2)
label_fontcolor#(lblLives#, SHIP_C$)


' --- On-screen controls, mobile only --------------------------
' The buttons set exactly the same three variables the keyboard sets, so
' everything downstream is unaware of how the player is holding the machine.
if IS_MOBILE = 1 then
  let btnW = cint(GAME_W / 3) - 10
  let btnH = CTRL_H - 24
  let btnY = PLAY_H + 10

  let padL# = rectangle#(frm#, 8, btnY, btnW, btnH)
  rectangle_fill#(padL#, "#111a33")
  rectangle_stroke#(padL#, "#3f5aa6")
  rectangle_strokethickness#(padL#, 2)
  rectangle_corners#(padL#, 12, 12)
  rectangle_onmousedown#(padL#, "PadLeftDown")
  rectangle_onmouseup#(padL#, "PadLeftUp")
  let capL# = label#(frm#, "<")
  label_autosize#(capL#, 0)
  label_move#(capL#, 8, btnY)
  label_size#(capL#, btnW, btnH)
  label_fontsize#(capL#, 30)
  label_bold#(capL#, 1)
  label_fontcolor#(capL#, "#8fa4e0")
  label_textalign#(capL#, 0)
  label_vertalign#(capL#, 0)
  label_hittest#(capL#, 0)

  let padF# = rectangle#(frm#, cint(GAME_W / 3) + 2, btnY, btnW + 4, btnH)
  rectangle_fill#(padF#, "#2a1204")
  rectangle_stroke#(padF#, "#ff7043")
  rectangle_strokethickness#(padF#, 3)
  rectangle_corners#(padF#, 12, 12)
  rectangle_onmousedown#(padF#, "PadFireDown")
  rectangle_onmouseup#(padF#, "PadFireUp")
  let capF# = label#(frm#, "FIRE")
  label_autosize#(capF#, 0)
  label_move#(capF#, cint(GAME_W / 3) + 2, btnY)
  label_size#(capF#, btnW + 4, btnH)
  label_fontsize#(capF#, 20)
  label_bold#(capF#, 1)
  label_fontcolor#(capF#, "#ff8a65")
  label_textalign#(capF#, 0)
  label_vertalign#(capF#, 0)
  label_hittest#(capF#, 0)

  let padR# = rectangle#(frm#, GAME_W - btnW - 8, btnY, btnW, btnH)
  rectangle_fill#(padR#, "#111a33")
  rectangle_stroke#(padR#, "#3f5aa6")
  rectangle_strokethickness#(padR#, 2)
  rectangle_corners#(padR#, 12, 12)
  rectangle_onmousedown#(padR#, "PadRightDown")
  rectangle_onmouseup#(padR#, "PadRightUp")
  let capR# = label#(frm#, ">")
  label_autosize#(capR#, 0)
  label_move#(capR#, GAME_W - btnW - 8, btnY)
  label_size#(capR#, btnW, btnH)
  label_fontsize#(capR#, 30)
  label_bold#(capR#, 1)
  label_fontcolor#(capR#, "#8fa4e0")
  label_textalign#(capR#, 0)
  label_vertalign#(capR#, 0)
  label_hittest#(capR#, 0)

  ' A tap anywhere on the play area restarts once it is over, because there is
  ' no R key to press.
  let tapArea# = rectangle#(frm#, 0, HUD_H, GAME_W, PLAY_H - HUD_H)
  rectangle_fill#(tapArea#, "#00000000")
  rectangle_strokenone#(tapArea#)
  rectangle_sendtoback#(tapArea#)
  rectangle_onmousedown#(tapArea#, "PadTap")
end if

' --- The two hulls of the fighter -----------------------------
ship# = rectangle#(frm#, shipX, SHIP_Y, SHIP_W, SHIP_H)
rectangle_fill#(ship#, "#00000000")
rectangle_strokenone#(ship#)
rectangle_hittest#(ship#, 0)
ShipParts(ship#, SHIP_W, SHIP_H)

' The second hull, shown only after a rescue.
ship2# = rectangle#(frm#, 0, SHIP_Y, SHIP_W, SHIP_H)
rectangle_fill#(ship2#, "#00000000")
rectangle_strokenone#(ship2#)
rectangle_hittest#(ship2#, 0)
rectangle_visible#(ship2#, 0)
ShipParts(ship2#, SHIP_W, SHIP_H)

' --- The capture beam -----------------------------------------
' A cone would be prettier; a rectangle is what tells the player
' truthfully where the danger is, and that matters more.
beam# = rectangle#(frm#, 0, 0, 70, 200)
rectangle_fill#(beam#, BEAM_C$)
rectangle_strokenone#(beam#)
rectangle_opacity#(beam#, 0.35)
rectangle_visible#(beam#, 0)

' --- Shots ----------------------------------------------------
let sX# = dim#(MAX_SHOT)
let sY# = dim#(MAX_SHOT)
let sOn# = dim#(MAX_SHOT)
let sRect# = pdim#(MAX_SHOT)
for i = 1 to MAX_SHOT
  sOn#[i] = 0
  let r# = rectangle#(frm#, 0, 0, SHOT_W, SHOT_H)
  rectangle_fill#(r#, SHOT_C$)
  rectangle_strokenone#(r#)
  rectangle_visible#(r#, 0)
  sRect##[i] = r#
next i

let bX# = dim#(MAX_EBOMB)
let bY# = dim#(MAX_EBOMB)
let bOn# = dim#(MAX_EBOMB)
let bRect# = pdim#(MAX_EBOMB)
for i = 1 to MAX_EBOMB
  bOn#[i] = 0
  let r# = rectangle#(frm#, 0, 0, EBOMB_W, EBOMB_H)
  rectangle_fill#(r#, BOMB_C$)
  rectangle_strokenone#(r#)
  rectangle_visible#(r#, 0)
  bRect##[i] = r#
next i

' --- Enemies --------------------------------------------------
let eX# = dim#(MAX_ENEMY)
let eY# = dim#(MAX_ENEMY)
let eKind# = dim#(MAX_ENEMY)
let eState# = dim#(MAX_ENEMY)
let eRow# = dim#(MAX_ENEMY)
let eCol# = dim#(MAX_ENEMY)
let eT# = dim#(MAX_ENEMY)
let eSpeed# = dim#(MAX_ENEMY)
let eDelay# = dim#(MAX_ENEMY)
let eSide# = dim#(MAX_ENEMY)
let eDiveX# = dim#(MAX_ENEMY)
let eShown# = dim#(MAX_ENEMY)
let eRect# = pdim#(MAX_ENEMY)
' Each enemy is a TRANSPARENT CONTAINER with its parts inside, the technique
' space_invaders.bas uses: children sit at coordinates relative to the
' container, so moving the one moves the lot, and a redraw is a single
' rectangle_move# rather than a part-by-part shuffle.
'
' The kind of a slot never changes between waves -- it falls out of the row and
' column -- so the parts are built once here instead of being torn down and
' rebuilt forty times a wave.
for i = 1 to MAX_ENEMY
  eState#[i] = ST_DEAD
  eShown#[i] = 0
  let row = cint((i - 1) / COLS) + 1
  let col = i - (row - 1) * COLS
  let r# = rectangle#(frm#, 0, 0, ENEMY_W, ENEMY_H)
  rectangle_fill#(r#, "#00000000")
  rectangle_strokenone#(r#)
  rectangle_hittest#(r#, 0)
  rectangle_visible#(r#, 0)
  eRect##[i] = r#
  let k = KindFor(row, col)
  if k = K_LEADER then LeaderParts(r#, ENEMY_W, ENEMY_H)
  if k = K_ESCORT then EscortParts(r#, ENEMY_W, ENEMY_H)
  if k = K_WASP then WaspParts(r#, ENEMY_W, ENEMY_H)
next i

' --- Messages -------------------------------------------------
lblBig# = label#(frm#, "", 0, PLAY_H / 2 - 60, GAME_W, 44)
label_fontsize#(lblBig#, 30)
label_bold#(lblBig#, 1)
label_textalign#(lblBig#, 0)
label_fontcolor#(lblBig#, INK$)

lblSmall# = label#(frm#, "", 0, PLAY_H / 2 - 12, GAME_W, 30)
label_fontsize#(lblSmall#, 15)
label_textalign#(lblSmall#, 0)
label_fontcolor#(lblSmall#, DIM$)

' ============================================================
'  SPRITES
'
'  Every shape here is drawn by this file: a transparent container,
'  then rectangles and ellipses parented into it at coordinates
'  relative to it. rectangle_corners# rounds a hull and
'  rectangle_rotation# angles a wing. hittest is off on every part,
'  so a sprite never swallows a click meant for the form.
'
'  This is the technique space_invaders.bas and flappy_bird.bas
'  use. Its point is not prettiness: moving one container moves the
'  whole ship, so a frame costs one rectangle_move# per enemy
'  rather than one per part.
' ============================================================

' Which enemy belongs in a slot. Only four leaders, at the corners of the top
' row: a row of eight capture beams is not a game, it is a wall.
function KindFor(row, col)
  if row = 1 then
    if col < 3 then return K_LEADER
    if col > COLS - 2 then return K_LEADER
    return K_ESCORT
  end if
  if row = 2 then return K_ESCORT
  if row = 3 then return K_ESCORT
  return K_WASP
end function

' The wasp: a small dart with swept wings. These are the ones you see twenty
' of at a time, so it stays simple and reads at a glance.
function WaspParts(cont#, w, h) local b#, l#, r#
  let l# = rectangle#(cont#, 0, cint(h * 0.45), cint(w * 0.34), cint(h * 0.3))
  rectangle_fill#(l#, "#1d7fb0")
  rectangle_strokenone#(l#)
  rectangle_rotation#(l#, -18)
  rectangle_hittest#(l#, 0)

  let r# = rectangle#(cont#, cint(w * 0.66), cint(h * 0.45), cint(w * 0.34), cint(h * 0.3))
  rectangle_fill#(r#, "#1d7fb0")
  rectangle_strokenone#(r#)
  rectangle_rotation#(r#, 18)
  rectangle_hittest#(r#, 0)

  let b# = rectangle#(cont#, cint(w * 0.32), cint(h * 0.15), cint(w * 0.36), cint(h * 0.7))
  rectangle_fill#(b#, "#4fc3f7")
  rectangle_corners#(b#, 4, 4)
  rectangle_strokenone#(b#)
  rectangle_hittest#(b#, 0)

  return 0
end function

' The escort: a broader hull, two eyes, a pair of side fins.
function EscortParts(cont#, w, h) local b#, l#, r#, e1#
  let l# = rectangle#(cont#, 0, cint(h * 0.3), cint(w * 0.2), cint(h * 0.44))
  rectangle_fill#(l#, "#ffab91")
  rectangle_strokenone#(l#)
  rectangle_corners#(l#, 3, 3)
  rectangle_rotation#(l#, -14)
  rectangle_hittest#(l#, 0)

  let r# = rectangle#(cont#, cint(w * 0.8), cint(h * 0.3), cint(w * 0.2), cint(h * 0.44))
  rectangle_fill#(r#, "#ffab91")
  rectangle_strokenone#(r#)
  rectangle_corners#(r#, 3, 3)
  rectangle_rotation#(r#, 14)
  rectangle_hittest#(r#, 0)

  let b# = rectangle#(cont#, cint(w * 0.18), cint(h * 0.2), cint(w * 0.64), cint(h * 0.62))
  rectangle_fill#(b#, "#ff7043")
  rectangle_stroke#(b#, "#c1401d")
  rectangle_strokethickness#(b#, 1)
  rectangle_corners#(b#, 6, 6)
  rectangle_hittest#(b#, 0)

  ' One visor rather than two eyes and two pupils. Four controls became one,
  ' twenty times over, and at this size the face reads the same.
  let e1# = ellipse#(cont#, cint(w * 0.3), cint(h * 0.34), cint(w * 0.4), cint(h * 0.2))
  ellipse_fill#(e1#, "#ffffff")
  ellipse_strokenone#(e1#)
  ellipse_hittest#(e1#, 0)
  return 0
end function

' The leader: the only one that can take your fighter, so it is the one that
' has to be recognisable in a crowd. Bigger hull, two antennae, and the violet
' emitter the beam comes out of.
function LeaderParts(cont#, w, h) local b#, a1#, a2#, e1#, c#, l#, r#
  let l# = rectangle#(cont#, 0, cint(h * 0.38), cint(w * 0.22), cint(h * 0.4))
  rectangle_fill#(l#, "#1b8f5a")
  rectangle_strokenone#(l#)
  rectangle_corners#(l#, 3, 3)
  rectangle_rotation#(l#, -20)
  rectangle_hittest#(l#, 0)

  let r# = rectangle#(cont#, cint(w * 0.78), cint(h * 0.38), cint(w * 0.22), cint(h * 0.4))
  rectangle_fill#(r#, "#1b8f5a")
  rectangle_strokenone#(r#)
  rectangle_corners#(r#, 3, 3)
  rectangle_rotation#(r#, 20)
  rectangle_hittest#(r#, 0)

  let a1# = rectangle#(cont#, cint(w * 0.26), 0, 2, cint(h * 0.3))
  rectangle_fill#(a1#, "#b9f6ca")
  rectangle_strokenone#(a1#)
  rectangle_rotation#(a1#, -22)
  rectangle_hittest#(a1#, 0)
  let a2# = rectangle#(cont#, cint(w * 0.72), 0, 2, cint(h * 0.3))
  rectangle_fill#(a2#, "#b9f6ca")
  rectangle_strokenone#(a2#)
  rectangle_rotation#(a2#, 22)
  rectangle_hittest#(a2#, 0)

  let b# = rectangle#(cont#, cint(w * 0.14), cint(h * 0.22), cint(w * 0.72), cint(h * 0.64))
  rectangle_fill#(b#, "#69f0ae")
  rectangle_stroke#(b#, "#1b8f5a")
  rectangle_strokethickness#(b#, 1)
  rectangle_corners#(b#, 7, 7)
  rectangle_hittest#(b#, 0)

  let c# = rectangle#(cont#, cint(w * 0.36), cint(h * 0.7), cint(w * 0.28), cint(h * 0.16))
  rectangle_fill#(c#, "#b388ff")
  rectangle_strokenone#(c#)
  rectangle_corners#(c#, 2, 2)
  rectangle_hittest#(c#, 0)

  ' The antennae and the violet emitter are what tell a leader from an escort
  ' across a crowded screen. The eyes did not, so they are gone.
  let e1# = ellipse#(cont#, cint(w * 0.28), cint(h * 0.34), cint(w * 0.44), cint(h * 0.2))
  ellipse_fill#(e1#, "#05321f")
  ellipse_strokenone#(e1#)
  ellipse_hittest#(e1#, 0)
  return 0
end function

' The fighter: a nose, a hull, two wings and an engine that shows.
function ShipParts(cont#, w, h) local n#, b#, l#, r#, g#
  let l# = rectangle#(cont#, 0, cint(h * 0.5), cint(w * 0.3), cint(h * 0.34))
  rectangle_fill#(l#, "#2f7fa8")
  rectangle_strokenone#(l#)
  rectangle_rotation#(l#, -12)
  rectangle_hittest#(l#, 0)
  let r# = rectangle#(cont#, cint(w * 0.7), cint(h * 0.5), cint(w * 0.3), cint(h * 0.34))
  rectangle_fill#(r#, "#2f7fa8")
  rectangle_strokenone#(r#)
  rectangle_rotation#(r#, 12)
  rectangle_hittest#(r#, 0)

  let n# = rectangle#(cont#, cint(w * 0.42), 0, cint(w * 0.16), cint(h * 0.42))
  rectangle_fill#(n#, "#e8f7ff")
  rectangle_strokenone#(n#)
  rectangle_corners#(n#, 2, 2)
  rectangle_hittest#(n#, 0)

  let b# = rectangle#(cont#, cint(w * 0.28), cint(h * 0.3), cint(w * 0.44), cint(h * 0.6))
  rectangle_fill#(b#, "#8fe3ff")
  rectangle_stroke#(b#, "#2f7fa8")
  rectangle_strokethickness#(b#, 1)
  rectangle_corners#(b#, 5, 5)
  rectangle_hittest#(b#, 0)

  let g# = rectangle#(cont#, cint(w * 0.4), cint(h * 0.86), cint(w * 0.2), cint(h * 0.14))
  rectangle_fill#(g#, "#ffd54f")
  rectangle_strokenone#(g#)
  rectangle_corners#(g#, 2, 2)
  rectangle_hittest#(g#, 0)
  return 0
end function

' ============================================================
'  PATHS
'
'  An entry is a loop followed by a run to the slot, which is what
'  makes these games read as flying rather than sliding. Both
'  halves are parametric in t, so an enemy only ever stores how
'  far along it is.
' ============================================================

' Where the entry arc puts an enemy at time t, 0..1. Answers the x.
function EntryX(idx, t) local side, cx, ang, sx, tx, k
  side = eSide#[idx]
  cx = GAME_W / 2
  if t < 0.62 then
    ' The loop. Half a turn, opening from whichever side it came in.
    ang = PI * (t / 0.62)
    k = 150
    if side = 1 then return cx - 210 + k * sin(ang)
    return cx + 210 - k * sin(ang)
  end if
  ' The run to the slot, eased so it does not arrive at full speed.
  sx = SlotX(idx)
  if side = 1 then tx = cx - 210
  if side <> 1 then tx = cx + 210
  k = (t - 0.62) / 0.38
  return tx + (sx - tx) * k * (2 - k)
end function

function EntryY(idx, t) local ang, k, sy
  if t < 0.62 then
    ang = PI * (t / 0.62)
    return FORM_TOP - 120 + 130 * (1 - cos(ang)) / 2 + 90 * sin(ang * 0.5)
  end if
  sy = SlotY(idx)
  k = (t - 0.62) / 0.38
  return (FORM_TOP - 120 + 130) + (sy - (FORM_TOP - 120 + 130)) * k * (2 - k)
end function

' The slot an enemy belongs to, with the formation's breathing
' folded in so a sitting enemy and an arriving one agree.
function SlotX(idx)
  return FORM_LEFT + (eCol#[idx] - 1) * CELL_W + 22 * sin(formPhase)
end function

function SlotY(idx)
  return FORM_TOP + (eRow#[idx] - 1) * CELL_H
end function

' A dive: down and across in an S, aimed at where the player was
' when it launched, then off the bottom of the screen.
function DiveX(idx, t) local sx, tx
  sx = eDiveX#[idx]
  tx = SlotX(idx)
  return tx + (sx - tx) * t + 60 * sin(t * PI * 2) * (1 - t)
end function

function DiveY(idx, t)
  return SlotY(idx) + (PLAY_H + 60 - SlotY(idx)) * t * t
end function

' ============================================================
'  DRAWING
' ============================================================

' One move for the whole sprite: the parts ride the container.
'
' Visibility is only written when it CHANGES. Setting a property to what it
' already holds still crosses into the control and can still invalidate it, and
' this ran forty times a frame for no effect at all.
function PlaceEnemy(idx) local r#
  r# = eRect##[idx]
  if eState#[idx] = ST_DEAD then
    if eShown#[idx] = 1 then
      rectangle_visible#(r#, 0)
      eShown#[idx] = 0
    end if
    return 0
  end if
  rectangle_move#(r#, cint(eX#[idx]), cint(eY#[idx]))
  if eShown#[idx] = 0 then
    rectangle_visible#(r#, 1)
    eShown#[idx] = 1
  end if
  return 0
end function

function PlaceShip()
  rectangle_move#(ship#, cint(shipX), SHIP_Y)
  if dual = 1 then
    rectangle_move#(ship2#, cint(shipX + SHIP_W + SHIP_GAP), SHIP_Y)
    rectangle_visible#(ship2#, 1)
  else
    rectangle_visible#(ship2#, 0)
  end if
  return 0
end function

function Hud() local t$
  label_text#(lblScore#, "SCORE " + str$(cint(score)))
  if challenge = 1 then
    label_text#(lblWave#, "CHALLENGE")
  else
    label_text#(lblWave#, "WAVE " + str$(cint(wave)))
  end if
  t$ = "SHIPS " + str$(cint(lives))
  if dual = 1 then t$ = t$ + "  DUAL"
  label_text#(lblLives#, t$)
  return 0
end function

function Message(big$, small$)
  label_text#(lblBig#, big$)
  label_text#(lblSmall#, small$)
  return 0
end function

' ============================================================
'  THE WAVE
' ============================================================

' Total width of the fighter, which is what a collision has to use
' -- a doubled fighter is twice the target.
function ShipWidth()
  if dual = 1 then return SHIP_W * 2 + SHIP_GAP
  return SHIP_W
end function

function BuildWave() local i, row, col, idx, kind
  enteredCount = 0
  aliveCount = 0
  beamIdx = 0
  beamFrames = 0
  captiveIdx = 0
  rectangle_visible#(beam#, 0)

  for row = 1 to ROWS
    for col = 1 to COLS
      idx = (row - 1) * COLS + col
      kind = KindFor(row, col)
      eKind#[idx] = kind
      eRow#[idx] = row
      eCol#[idx] = col
      eState#[idx] = ST_ENTER
      eT#[idx] = 0
      eSpeed#[idx] = 0.011 + rnd() * 0.004 + wave * 0.0006
      eDelay#[idx] = (row - 1) * 7 + (col - 1) * 4 + cint(rnd() * 6)
      eSide#[idx] = 1
      if col > COLS / 2 then eSide#[idx] = 2
      eX#[idx] = -100
      eY#[idx] = -100
      aliveCount = aliveCount + 1
      PlaceEnemy(idx)
    next col
  next row
  return 0
end function

function ClearShots() local i
  for i = 1 to MAX_SHOT
    sOn#[i] = 0
    rectangle_visible#(sRect##[i], 0)
  next i
  for i = 1 to MAX_EBOMB
    bOn#[i] = 0
    rectangle_visible#(bRect##[i], 0)
  next i
  return 0
end function

function NewGame()
  score = 0
  lives = 3
  wave = 1
  dual = 0
  challenge = 0
  shipX = GAME_W / 2 - SHIP_W / 2
  ClearShots()
  BuildWave()
  Message("", "")
  gstate = G_PLAY
  Hud()
  PlaceShip()
  return 0
end function

function NextWave()
  wave = wave + 1
  challenge = 0
  ' Every third wave is flown without a single enemy bomb: pure
  ' formation, pure shooting, bonus for clearing it.
  if wave - (cint(wave / 3) * 3) = 0 then challenge = 1
  ClearShots()
  BuildWave()
  Message("", "")
  gstate = G_PLAY
  Hud()
  return 0
end function

' ============================================================
'  INPUT
' ============================================================

' SPACE DOES NOT ARRIVE AS keyCode 32. FireMonkey hands a printable key over
' as the CHARACTER, with the code left at zero, and reserves the code for keys
' that have no character -- the arrows, the function keys. The first draft of
' this file tested "keyCode = 32" and the fire button simply did nothing; the
' only two occurrences of that test anywhere in this repository were both in
' here, and flappy_bird.bas carries a comment saying so in one line.
'
' Both forms are accepted below, because which one a platform sends is not
' something this file should have to know. The up arrow fires as well: it is
' what the other games in this folder use, and it is a key that reports through
' the code path rather than the character one, so it works even where the
' character never turns up.
function OnKeyDown(sender#, keyCode, keyChar$, shiftState$)
  if keyChar$ = "p" then TogglePause()
  if keyChar$ = "P" then TogglePause()
  if keyChar$ = "r" then MaybeRestart()
  if keyChar$ = "R" then MaybeRestart()
  if keyCode = 37 then moveL = 1
  if keyCode = 39 then moveR = 1
  if keyChar$ = " " then firing = 1
  if keyCode = 32 then firing = 1
  if keyCode = 38 then firing = 1
  return 0
end function

function OnKeyUp(sender#, keyCode, keyChar$, shiftState$)
  if keyCode = 37 then moveL = 0
  if keyCode = 39 then moveR = 0
  ' Cleared on any of the three, so a release reported through a different
  ' channel from the press cannot leave the trigger stuck down.
  if keyChar$ = " " then firing = 0
  if keyCode = 32 then firing = 0
  if keyCode = 38 then firing = 0
  return 0
end function

' --- Touch handlers -------------------------------------------
' Seven one-line functions rather than one with a parameter, because a control
' event carries only the sender and asking which rectangle it was would be more
' code than this.
'
' THE ORDER OF THE ARGUMENTS IS NOT OPTIONAL. A mouse handler is
' (sender#, button, x, y, shift$) -- the shift state comes LAST. The engine
' matches a handler by its exact signature, so putting shift$ in the middle
' does not raise an error: the function is simply never called, and the button
' does nothing. That is the same failure the fire key had, one layer along, and
' the documentation is where both answers were.
function PadLeftDown(sender#, button, x, y, shift$)
  moveL = 1
  return 0
end function
function PadLeftUp(sender#, button, x, y, shift$)
  moveL = 0
  return 0
end function
function PadRightDown(sender#, button, x, y, shift$)
  moveR = 1
  return 0
end function
function PadRightUp(sender#, button, x, y, shift$)
  moveR = 0
  return 0
end function
function PadFireDown(sender#, button, x, y, shift$)
  firing = 1
  return 0
end function
function PadFireUp(sender#, button, x, y, shift$)
  firing = 0
  return 0
end function
function PadTap(sender#, button, x, y, shift$)
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
'  FIRING
' ============================================================

function Fire() local i, n, x
  if fireCool > 0 then return 0
  n = 1
  if dual = 1 then n = 2
  for i = 1 to MAX_SHOT
    if n = 0 then return 0
    if sOn#[i] = 0 then
      x = shipX + SHIP_W / 2 - SHOT_W / 2
      if n = 1 then
        if dual = 1 then x = shipX + SHIP_W + SHIP_GAP + SHIP_W / 2 - SHOT_W / 2
      end if
      sOn#[i] = 1
      sX#[i] = x
      sY#[i] = SHIP_Y - SHOT_H
      rectangle_visible#(sRect##[i], 1)
      n = n - 1
    end if
  next i
  fireCool = 9
  return 0
end function

function DropBomb(idx) local i
  if challenge = 1 then return 0
  for i = 1 to MAX_EBOMB
    if bOn#[i] = 0 then
      bOn#[i] = 1
      bX#[i] = eX#[idx] + ENEMY_W / 2 - EBOMB_W / 2
      bY#[i] = eY#[idx] + ENEMY_H
      rectangle_visible#(bRect##[i], 1)
      return 0
    end if
  next i
  return 0
end function

' ============================================================
'  THE LOOP
' ============================================================

function GameLoop(sender#) local i
  tick = tick + 1
  Stars()
  if paused = 1 then return 0

  if gstate = G_PLAY then
    MoveShip()
    MoveShots()
    MoveEnemies()
    Collisions()
    LaunchDives()
    if aliveCount = 0 then
      gstate = G_CLEAR
      clearUntil = tick + 90
      if challenge = 1 then
        score = score + 1000
        Message("PERFECT", "challenge cleared, 1000")
      else
        Message("WAVE CLEARED", "")
      end if
      Hud()
    end if
  end if

  if gstate = G_DYING then
    MoveShots()
    MoveEnemies()
    if tick > dyingUntil then Respawn()
  end if

  if gstate = G_CLEAR then
    MoveEnemies()
    if tick > clearUntil then NextWave()
  end if

  return 0
end function

function Stars() local i, y
  ' Every other frame. At these speeds nobody can tell, and it halves the cost
  ' of the one thing on screen that is not part of the game.
  if tick - (cint(tick / 2) * 2) <> 0 then return 0
  for i = 1 to NUM_STARS
    y = starY#[i] + starV#[i]
    if y > PLAY_H then
      y = -2
      starX#[i] = cint(rnd() * GAME_W)
    end if
    starY#[i] = y
    rectangle_move#(starR##[i], cint(starX#[i]), cint(y))
  next i
  return 0
end function

function MoveShip() local w
  if fireCool > 0 then fireCool = fireCool - 1
  w = ShipWidth()
  if moveL = 1 then shipX = shipX - SHIP_SPEED
  if moveR = 1 then shipX = shipX + SHIP_SPEED
  if shipX < 4 then shipX = 4
  if shipX > GAME_W - w - 4 then shipX = GAME_W - w - 4
  if firing = 1 then Fire()
  PlaceShip()
  return 0
end function

function MoveShots() local i, y
  for i = 1 to MAX_SHOT
    if sOn#[i] = 1 then
      y = sY#[i] - SHOT_SPEED
      sY#[i] = y
      if y < HUD_H then
        sOn#[i] = 0
        rectangle_visible#(sRect##[i], 0)
      else
        rectangle_move#(sRect##[i], cint(sX#[i]), cint(y))
      end if
    end if
  next i
  for i = 1 to MAX_EBOMB
    if bOn#[i] = 1 then
      y = bY#[i] + EBOMB_SPEED
      bY#[i] = y
      if y > PLAY_H then
        bOn#[i] = 0
        rectangle_visible#(bRect##[i], 0)
      else
        rectangle_move#(bRect##[i], cint(bX#[i]), cint(y))
      end if
    end if
  next i
  return 0
end function

function MoveEnemies() local i, s, slow
  ' A sitting enemy only drifts with the formation's breathing, which is slow
  ' enough that repositioning it on alternate frames is invisible -- and that is
  ' up to forty control moves a frame that no longer happen. The phase steps
  ' twice as far when it does step, so the drift keeps its speed.
  slow = 0
  if tick - (cint(tick / 2) * 2) = 0 then slow = 1
  if slow = 1 then formPhase = formPhase + 0.024

  for i = 1 to MAX_ENEMY
    s = eState#[i]
    if s <> ST_DEAD then
      if s = ST_FORM then
        if slow = 1 then
          StepForm(i)
          PlaceEnemy(i)
        end if
      else
        if s = ST_ENTER then StepEnter(i)
        if s = ST_DIVE then StepDive(i)
        if s = ST_BEAM then StepBeam(i)
        if s = ST_RETURN then StepReturn(i)
        PlaceEnemy(i)
      end if
    end if
  next i
  return 0
end function

function StepEnter(idx) local t
  if eDelay#[idx] > 0 then
    eDelay#[idx] = eDelay#[idx] - 1
    return 0
  end if
  t = eT#[idx] + eSpeed#[idx]
  if t >= 1 then
    eT#[idx] = 0
    eState#[idx] = ST_FORM
    enteredCount = enteredCount + 1
    return 0
  end if
  eT#[idx] = t
  eX#[idx] = EntryX(idx, t)
  eY#[idx] = EntryY(idx, t)
  return 0
end function

function StepForm(idx)
  eX#[idx] = SlotX(idx)
  eY#[idx] = SlotY(idx)
  return 0
end function

function StepDive(idx) local t
  t = eT#[idx] + 0.010 + wave * 0.0004
  if t >= 1 then
    ' Off the bottom. Come back in from the top and rejoin.
    eT#[idx] = 0
    eState#[idx] = ST_RETURN
    eY#[idx] = -ENEMY_H
    eX#[idx] = SlotX(idx)
    return 0
  end if
  eT#[idx] = t
  eX#[idx] = DiveX(idx, t)
  eY#[idx] = DiveY(idx, t)
  ' A bomb on the way down, roughly a third of the way in.
  if t > 0.28 then
    if t < 0.32 then DropBomb(idx)
  end if
  return 0
end function

function StepReturn(idx) local t, sy
  t = eT#[idx] + 0.02
  sy = SlotY(idx)
  if t >= 1 then
    eT#[idx] = 0
    eState#[idx] = ST_FORM
    return 0
  end if
  eT#[idx] = t
  eX#[idx] = SlotX(idx)
  eY#[idx] = -ENEMY_H + (sy + ENEMY_H) * t
  return 0
end function

' The beam: hover above the player, hold it open, and take the
' fighter if it is still underneath when the beam closes.
function StepBeam(idx) local hy, bx, w, sw
  hy = SHIP_Y - 230
  if eY#[idx] < hy then
    eY#[idx] = eY#[idx] + 3
    eX#[idx] = eX#[idx] + (eDiveX#[idx] - eX#[idx]) * 0.06
    return 0
  end if

  beamFrames = beamFrames + 1
  bx = eX#[idx] + ENEMY_W / 2 - 35
  rectangle_move#(beam#, cint(bx), cint(eY#[idx] + ENEMY_H))
  rectangle_visible#(beam#, 1)

  if beamFrames > 110 then
    w = 70
    sw = ShipWidth()
    ' Caught, if any part of the fighter is inside the beam.
    if shipX + sw > bx then
      if shipX < bx + w then
        Captured(idx)
        return 0
      end if
    end if
    rectangle_visible#(beam#, 0)
    beamIdx = 0
    beamFrames = 0
    eState#[idx] = ST_DIVE
    eT#[idx] = 0.5
  end if
  return 0
end function

function Captured(idx)
  rectangle_visible#(beam#, 0)
  beamIdx = 0
  beamFrames = 0
  captiveIdx = idx
  eState#[idx] = ST_RETURN
  eT#[idx] = 0
  dual = 0
  LoseLife("CAPTURED", "shoot that leader on its next dive")
  return 0
end function

function LaunchDives() local i, n, pick, k
  if gstate <> G_PLAY then return 0
  if enteredCount < 8 then return 0
  ' A dive every so often, more often as the waves go on.
  n = 74 - wave * 5
  if n < 24 then n = 24
  if tick - (cint(tick / n) * n) <> 0 then return 0

  pick = 0
  for i = 1 to MAX_ENEMY
    if eState#[i] = ST_FORM then
      if pick = 0 then pick = i
      if rnd() < 0.12 then pick = i
    end if
  next i
  if pick = 0 then return 0

  eDiveX#[pick] = shipX + ShipWidth() / 2
  eT#[pick] = 0
  k = eKind#[pick]
  ' Only a leader opens a beam, only when it is not holding a
  ' fighter already, and not during a challenge stage.
  if k = K_LEADER then
    if beamIdx = 0 then
      if captiveIdx = 0 then
        if challenge = 0 then
          if rnd() < 0.5 then
            eState#[pick] = ST_BEAM
            beamIdx = pick
            beamFrames = 0
            return 0
          end if
        end if
      end if
    end if
  end if
  eState#[pick] = ST_DIVE
  return 0
end function

' ============================================================
'  COLLISIONS
'
'  Distances are compared SQUARED throughout: this dialect has no
'  sqrt, and a squared comparison is the faster one anyway.
' ============================================================

function Overlap(ax, ay, aw, ah, bx, by, bw, bh)
  if ax + aw < bx then return 0
  if bx + bw < ax then return 0
  if ay + ah < by then return 0
  if by + bh < ay then return 0
  return 1
end function

function Points(k)
  if k = K_LEADER then return 150
  if k = K_ESCORT then return 80
  return 50
end function

function Collisions() local i, j, sw
  ' Shots against enemies.
  for i = 1 to MAX_SHOT
    if sOn#[i] = 1 then
      for j = 1 to MAX_ENEMY
        if sOn#[i] = 1 then
          if eState#[j] <> ST_DEAD then
            if Overlap(sX#[i], sY#[i], SHOT_W, SHOT_H, eX#[j], eY#[j], ENEMY_W, ENEMY_H) = 1 then
              sOn#[i] = 0
              rectangle_visible#(sRect##[i], 0)
              KillEnemy(j)
            end if
          end if
        end if
      next j
    end if
  next i

  if gstate <> G_PLAY then return 0
  sw = ShipWidth()

  ' Bombs against the fighter.
  for i = 1 to MAX_EBOMB
    if bOn#[i] = 1 then
      if Overlap(bX#[i], bY#[i], EBOMB_W, EBOMB_H, shipX, SHIP_Y, sw, SHIP_H) = 1 then
        bOn#[i] = 0
        rectangle_visible#(bRect##[i], 0)
        LoseLife("HIT", "")
        return 0
      end if
    end if
  next i

  ' A diving enemy against the fighter.
  for i = 1 to MAX_ENEMY
    if eState#[i] = ST_DIVE then
      if Overlap(eX#[i], eY#[i], ENEMY_W, ENEMY_H, shipX, SHIP_Y, sw, SHIP_H) = 1 then
        KillEnemy(i)
        LoseLife("RAMMED", "")
        return 0
      end if
    end if
  next i
  return 0
end function

function KillEnemy(idx) local wasCaptive
  wasCaptive = 0
  if idx = captiveIdx then wasCaptive = 1
  if idx = beamIdx then
    beamIdx = 0
    beamFrames = 0
    rectangle_visible#(beam#, 0)
  end if
  eState#[idx] = ST_DEAD
  rectangle_visible#(eRect##[idx], 0)
  aliveCount = aliveCount - 1
  score = score + Points(eKind#[idx])

  ' The rescue. Shooting the leader that holds your fighter gives
  ' it back -- but only if it was diving, which is the whole point
  ' of the risk. Shot in formation, the captive is lost with it.
  if wasCaptive = 1 then
    captiveIdx = 0
    if eState#[idx] = ST_DEAD then
      dual = 1
      score = score + 1000
      Message("RESCUED", "dual fighter")
    end if
  end if
  Hud()
  return 0
end function

function LoseLife(big$, small$)
  lives = lives - 1
  dual = 0
  ClearShots()
  rectangle_visible#(beam#, 0)
  beamIdx = 0
  beamFrames = 0
  Hud()
  if lives < 1 then
    gstate = G_OVER
    if score > best then best = score
    Message("GAME OVER", "R to play again   -   best " + str$(cint(best)))
    return 0
  end if
  gstate = G_DYING
  dyingUntil = tick + 70
  Message(big$, small$)
  return 0
end function

function Respawn()
  shipX = GAME_W / 2 - SHIP_W / 2
  Message("", "")
  gstate = G_PLAY
  PlaceShip()
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

Message("TRACTOR", "arrows to move, space to fire")
Hud()
PlaceShip()
NewGame()
