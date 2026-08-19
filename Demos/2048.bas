' ============================================================
'  2048 - The Addictive Puzzle Game
'  Written in Plan9Basic
' ============================================================
'
'  Controls (Desktop):
'    Arrow Keys  -  Slide tiles (Up/Down/Left/Right)
'    R Key       -  Restart game
'
'  Controls (Mobile / Touch):
'    Swipe       -  Slide tiles in swipe direction
'    Tap         -  Restart (when game over)
'
'  Objective:
'    Slide numbered tiles on the grid. When two tiles with
'    the same number collide, they merge into one with their
'    sum. Reach the 2048 tile to win!
'
' ============================================================

randomize()

' --- Platform Detection ---
let PLATFORM$ = os_name$()
let IS_MOBILE = 0
if PLATFORM$ = "Android" or PLATFORM$ = "iOS" then IS_MOBILE = 1
if instr(PLATFORM$, "Android") >= 0 or instr(PLATFORM$, "iOS") >= 0 then IS_MOBILE = 1

' --- Game Area Constants ---
let GAME_W = 450
let GAME_H = 570
let TOP_BAR = 80

if IS_MOBILE = 1 then
  let GAME_W = form_screenwidth()
  let GAME_H = form_screenheight()
  let TOP_BAR = 90
end if

' --- Grid Constants ---
let GRID_SIZE = 4
let TILE_GAP = 10
let GRID_PAD = 15
let TOTAL_TILES = GRID_SIZE * GRID_SIZE

if IS_MOBILE = 1 then
  let TILE_GAP = cint(GAME_W * 0.02)
  if TILE_GAP < 6 then
    let TILE_GAP = 6
  end if
  let GRID_PAD = cint(GAME_W * 0.03)
end if

' Calculate tile size to fit screen
let TILE_SIZE = cint((GAME_W - GRID_PAD * 2 - (GRID_SIZE + 1) * TILE_GAP) / GRID_SIZE)

' --- Touch Swipe State ---
let touchStartX = 0
let touchStartY = 0
let touchActive = 0
let SWIPE_THRESHOLD = 30

' --- Game State ---
let score = 0
let bestScore = 0
let running = 1
let gameWon = 0
let gameOver = 0

' --- Object Pointers ---
let frm# = pointer#(0)
let gridBg# = pointer#(0)
let touchArea# = pointer#(0)
let lblTitle# = pointer#(0)
let lblScore# = pointer#(0)
let lblBest# = pointer#(0)
let lblMsg# = pointer#(0)
let tmr# = pointer#(0)

' --- Tile Arrays (1-16 for 4x4 grid) ---
let tileVal# = pointer#(0)
let tileRect# = pointer#(0)
let tileLbl# = pointer#(0)

' --- Temp arrays for move logic ---
let tempVal# = pointer#(0)
let merged# = pointer#(0)

' --- Tile Colors ---
let tileColors# = pointer#(0)
let tileTextColors# = pointer#(0)

' ============================================================
'  CREATE THE GAME WINDOW
' ============================================================

if IS_MOBILE = 1 then
  let frm# = form#("2048", GAME_W, GAME_H)
else
  let frm# = form#("2048", GAME_W, GAME_H)
  form_position#(frm#, 4)
end if
form_fill#(frm#, "#faf8ef")

' --- Title ---
let lblTitle# = label#(frm#, "2048", 15, 15)
label_fontsize#(lblTitle#, 40)
label_fontcolor#(lblTitle#, "#776e65")
label_bold#(lblTitle#, 1)
label_size#(lblTitle#, 120, 50)

' --- Score box ---
let scoreBoxX = GAME_W - 220
let scoreBox# = rectangle#(frm#, scoreBoxX, 10, 100, 55)
rectangle_fill#(scoreBox#, "#bbada0")
rectangle_strokenone#(scoreBox#)
rectangle_corners#(scoreBox#, 5, 5)
rectangle_hittest#(scoreBox#, 0)

let lblScoreTitle# = label#(frm#, "SCORE")
label_autosize#(lblScoreTitle#, 0)
label_move#(lblScoreTitle#, scoreBoxX, 15)
label_fontsize#(lblScoreTitle#, 11)
label_fontcolor#(lblScoreTitle#, "#eee4da")
label_bold#(lblScoreTitle#, 1)
label_size#(lblScoreTitle#, 100, 18)
label_textalign#(lblScoreTitle#, 0)

let lblScore# = label#(frm#, "0")
label_autosize#(lblScore#, 0)
label_move#(lblScore#, scoreBoxX, 32)
label_fontsize#(lblScore#, 20)
label_fontcolor#(lblScore#, "#ffffff")
label_bold#(lblScore#, 1)
label_size#(lblScore#, 100, 30)
label_textalign#(lblScore#, 0)

' --- Best box ---
let bestBoxX = GAME_W - 110
let bestBox# = rectangle#(frm#, bestBoxX, 10, 100, 55)
rectangle_fill#(bestBox#, "#bbada0")
rectangle_strokenone#(bestBox#)
rectangle_corners#(bestBox#, 5, 5)
rectangle_hittest#(bestBox#, 0)

let lblBestTitle# = label#(frm#, "BEST")
label_autosize#(lblBestTitle#, 0)
label_move#(lblBestTitle#, bestBoxX, 15)
label_fontsize#(lblBestTitle#, 11)
label_fontcolor#(lblBestTitle#, "#eee4da")
label_bold#(lblBestTitle#, 1)
label_size#(lblBestTitle#, 100, 18)
label_textalign#(lblBestTitle#, 0)

let lblBest# = label#(frm#, "0")
label_autosize#(lblBest#, 0)
label_move#(lblBest#, bestBoxX, 32)
label_fontsize#(lblBest#, 20)
label_fontcolor#(lblBest#, "#ffffff")
label_bold#(lblBest#, 1)
label_size#(lblBest#, 100, 30)
label_textalign#(lblBest#, 0)

' --- Grid background ---
let gridX = (GAME_W - (GRID_SIZE * TILE_SIZE + (GRID_SIZE + 1) * TILE_GAP)) / 2
let gridY = TOP_BAR + 20
let gridW = GRID_SIZE * TILE_SIZE + (GRID_SIZE + 1) * TILE_GAP
let gridH = gridW

let gridBg# = rectangle#(frm#, gridX, gridY, gridW, gridH)
rectangle_fill#(gridBg#, "#bbada0")
rectangle_strokenone#(gridBg#)
rectangle_corners#(gridBg#, 6, 6)
rectangle_hittest#(gridBg#, 0)

' --- Touch area (transparent, covers full screen for swipe) ---
let touchArea# = rectangle#(frm#, 0, 0, GAME_W, GAME_H)
rectangle_fill#(touchArea#, "#00000000")
rectangle_strokenone#(touchArea#)
rectangle_hittest#(touchArea#, 1)
rectangle_onmousedown#(touchArea#, "OnTouchDown")
rectangle_onmousemove#(touchArea#, "OnTouchMove")

' ============================================================
'  SETUP TILE COLORS
' ============================================================

let tileColors# = sdim#(15)
tileColors#$[1] = "#cdc1b4"
tileColors#$[2] = "#eee4da"
tileColors#$[3] = "#ede0c8"
tileColors#$[4] = "#f2b179"
tileColors#$[5] = "#f59563"
tileColors#$[6] = "#f67c5f"
tileColors#$[7] = "#f65e3b"
tileColors#$[8] = "#edcf72"
tileColors#$[9] = "#edcc61"
tileColors#$[10] = "#edc850"
tileColors#$[11] = "#edc53f"
tileColors#$[12] = "#edc22e"
tileColors#$[13] = "#3c3a32"
tileColors#$[14] = "#3c3a32"
tileColors#$[15] = "#3c3a32"

let tileTextColors# = sdim#(15)
tileTextColors#$[1] = "#776e65"
tileTextColors#$[2] = "#776e65"
tileTextColors#$[3] = "#776e65"
tileTextColors#$[4] = "#f9f6f2"
tileTextColors#$[5] = "#f9f6f2"
tileTextColors#$[6] = "#f9f6f2"
tileTextColors#$[7] = "#f9f6f2"
tileTextColors#$[8] = "#f9f6f2"
tileTextColors#$[9] = "#f9f6f2"
tileTextColors#$[10] = "#f9f6f2"
tileTextColors#$[11] = "#f9f6f2"
tileTextColors#$[12] = "#f9f6f2"
tileTextColors#$[13] = "#f9f6f2"
tileTextColors#$[14] = "#f9f6f2"
tileTextColors#$[15] = "#f9f6f2"

' ============================================================
'  CREATE TILES
' ============================================================

let tileVal# = dim#(TOTAL_TILES)
let tileRect# = pdim#(TOTAL_TILES)
let tileLbl# = pdim#(TOTAL_TILES)
let tempVal# = dim#(TOTAL_TILES)
let merged# = dim#(TOTAL_TILES)

' Calculate font sizes based on tile size
let fontLarge = cint(TILE_SIZE * 0.36)
let fontMedium = cint(TILE_SIZE * 0.31)
let fontSmall = cint(TILE_SIZE * 0.27)

for row = 0 to GRID_SIZE - 1
  for col = 0 to GRID_SIZE - 1
    let idx = row * GRID_SIZE + col + 1
    let tx = gridX + TILE_GAP + col * (TILE_SIZE + TILE_GAP)
    let ty = gridY + TILE_GAP + row * (TILE_SIZE + TILE_GAP)
    
    tileVal#[idx] = 0
    
    ' Tile background
    let tr# = rectangle#(frm#, tx, ty, TILE_SIZE, TILE_SIZE)
    rectangle_fill#(tr#, "#cdc1b4")
    rectangle_strokenone#(tr#)
    rectangle_corners#(tr#, 5, 5)
    rectangle_hittest#(tr#, 0)
    tileRect##[idx] = tr#
    
    ' Tile label (6-param constructor sets AutoSize=False, covers full tile)
    let tl# = label#(frm#, "", tx, ty, TILE_SIZE, TILE_SIZE)
    label_fontsize#(tl#, fontLarge)
    label_fontcolor#(tl#, "#776e65")
    label_bold#(tl#, 1)
    label_textalign#(tl#, 0)
    label_vertalign#(tl#, 0)
    tileLbl##[idx] = tl#
  next
next

' --- Message label (created after tiles so it renders on top) ---
let lblMsg# = label#(frm#, "")
label_autosize#(lblMsg#, 0)
label_fontsize#(lblMsg#, 28)
label_fontcolor#(lblMsg#, "#776e65")
label_bold#(lblMsg#, 1)
label_align#(lblMsg#, 14)
label_height#(lblMsg#, 40)
label_y#(lblMsg#, cint(gridY + gridH / 2 - 20))
label_textalign#(lblMsg#, 0)

' ============================================================
'  SETUP EVENTS
' ============================================================

form_onkeydown#(frm#, "OnKeyDown")
form_show(frm#)

' Start with 2 random tiles
SpawnTile()
SpawnTile()

' ============================================================
'  KEYBOARD EVENT HANDLER (Desktop)
' ============================================================

function OnKeyDown(sender#, keyCode, keyChar$) local moved
  ' R = restart
  if keyChar$ = "r" then
    ResetGame()
    return 0
  end if
  if keyChar$ = "R" then
    ResetGame()
    return 0
  end if
  
  if gameOver = 1 then
    return 0
  end if
  
  moved = 0
  
  ' Up=38, Down=40, Left=37, Right=39
  if keyCode = 38 then
    moved = MoveUp()
  end if
  if keyCode = 40 then
    moved = MoveDown()
  end if
  if keyCode = 37 then
    moved = MoveLeft()
  end if
  if keyCode = 39 then
    moved = MoveRight()
  end if
  
  if moved = 1 then
    SpawnTile()
    UpdateAllTiles()
    CheckGameOver()
  end if
end function

' ============================================================
'  TOUCH / SWIPE EVENT HANDLERS
' ============================================================

' onmousedown: function(sender#, btn, mx, my, shift$)
function OnTouchDown(sender#, btn, mx, my, shift$)
  ' Tap to restart when game over
  if gameOver = 1 then
    ResetGame()
    return 0
  end if
  ' Record swipe start position
  let touchStartX = mx
  let touchStartY = my
  let touchActive = 1
end function

' onmousemove: function(sender#, mx, my, shift$)
function OnTouchMove(sender#, mx, my, shift$) local dx, dy, adx, ady, moved
  if touchActive = 0 then
    return 0
  end if
  if gameOver = 1 then
    return 0
  end if
  
  dx = mx - touchStartX
  dy = my - touchStartY
  adx = abs(dx)
  ady = abs(dy)
  
  ' Only process if swipe exceeds threshold
  if adx < SWIPE_THRESHOLD then
    if ady < SWIPE_THRESHOLD then
      return 0
    end if
  end if
  
  ' Consume this swipe (one move per touch)
  let touchActive = 0
  moved = 0
  
  ' Determine swipe direction
  if adx > ady then
    ' Horizontal swipe
    if dx > 0 then
      moved = MoveRight()
    else
      moved = MoveLeft()
    end if
  else
    ' Vertical swipe
    if dy > 0 then
      moved = MoveDown()
    else
      moved = MoveUp()
    end if
  end if
  
  if moved = 1 then
    SpawnTile()
    UpdateAllTiles()
    CheckGameOver()
  end if
end function

' ============================================================
'  GAME FUNCTIONS
' ============================================================

function ResetGame() local i
  let score = 0
  let gameWon = 0
  let gameOver = 0
  label_text#(lblScore#, "0")
  label_text#(lblMsg#, "")
  
  for i = 1 to TOTAL_TILES
    tileVal#[i] = 0
  next
  
  SpawnTile()
  SpawnTile()
  UpdateAllTiles()
end function

function GetTileColorIndex(val) local idx
  if val = 0 then
    return 1
  end if
  if val = 2 then
    return 2
  end if
  if val = 4 then
    return 3
  end if
  if val = 8 then
    return 4
  end if
  if val = 16 then
    return 5
  end if
  if val = 32 then
    return 6
  end if
  if val = 64 then
    return 7
  end if
  if val = 128 then
    return 8
  end if
  if val = 256 then
    return 9
  end if
  if val = 512 then
    return 10
  end if
  if val = 1024 then
    return 11
  end if
  if val = 2048 then
    return 12
  end if
  return 13
end function

function UpdateTile(idx) local val, colorIdx, tr#, tl#, fontSize
  val = tileVal#[idx]
  colorIdx = GetTileColorIndex(val)
  
  tr# = tileRect##[idx]
  tl# = tileLbl##[idx]
  
  rectangle_fill#(tr#, sarr_get$(tileColors#, colorIdx))
  
  if val = 0 then
    label_text#(tl#, "")
  else
    label_text#(tl#, stri$(val))
    label_fontcolor#(tl#, sarr_get$(tileTextColors#, colorIdx))
    ' Adjust font size for larger numbers
    if val >= 1000 then
      label_fontsize#(tl#, fontSmall)
    else if val >= 100 then
      label_fontsize#(tl#, fontMedium)
    else
      label_fontsize#(tl#, fontLarge)
    end if
  end if
end function

function UpdateAllTiles() local i
  for i = 1 to TOTAL_TILES
    UpdateTile(i)
  next
end function

function SpawnTile() local empty, emptyCount, i, choice, val
  ' Count empty tiles
  emptyCount = 0
  for i = 1 to TOTAL_TILES
    if tileVal#[i] = 0 then
      emptyCount = emptyCount + 1
    end if
  next
  
  if emptyCount = 0 then
    return 0
  end if
  
  ' Pick random empty tile
  choice = 1 + cint(rnd() * (emptyCount - 1))
  empty = 0
  for i = 1 to TOTAL_TILES
    if tileVal#[i] = 0 then
      empty = empty + 1
      if empty = choice then
        ' 90% chance of 2, 10% chance of 4
        if rnd() < 0.9 then
          val = 2
        else
          val = 4
        end if
        tileVal#[i] = val
        UpdateTile(i)
        return 0
      end if
    end if
  next
end function

function GetIndex(row, col)
  return row * GRID_SIZE + col + 1
end function

function MoveLeft() local row, col, idx, writeCol, i, val, moved, lastVal
  moved = 0
  
  for row = 0 to GRID_SIZE - 1
    ' Clear merged flags
    for i = 1 to GRID_SIZE
      merged#[i] = 0
    next
    
    writeCol = 0
    lastVal = 0
    
    for col = 0 to GRID_SIZE - 1
      idx = GetIndex(row, col)
      val = tileVal#[idx]
      
      if val > 0 then
        if lastVal = val then
          if merged#[writeCol] = 0 then
            ' Merge with previous
            tileVal#[GetIndex(row, writeCol - 1)] = val * 2
            merged#[writeCol] = 1
            let score = score + val * 2
            label_text#(lblScore#, stri$(score))
            if score > bestScore then
              let bestScore = score
              label_text#(lblBest#, stri$(bestScore))
            end if
            if val * 2 = 2048 then
              if gameWon = 0 then
                let gameWon = 1
                label_text#(lblMsg#, "You Win!")
              end if
            end if
            lastVal = 0
            moved = 1
          else
            tileVal#[GetIndex(row, writeCol)] = val
            if writeCol <> col then
              moved = 1
            end if
            writeCol = writeCol + 1
            lastVal = val
          end if
        else
          tileVal#[GetIndex(row, writeCol)] = val
          if writeCol <> col then
            moved = 1
          end if
          writeCol = writeCol + 1
          lastVal = val
        end if
      end if
    next
    
    ' Clear remaining
    for col = writeCol to GRID_SIZE - 1
      tileVal#[GetIndex(row, col)] = 0
    next
  next
  
  return moved
end function

function MoveRight() local row, col, idx, writeCol, i, val, moved, lastVal
  moved = 0
  
  for row = 0 to GRID_SIZE - 1
    for i = 1 to GRID_SIZE
      merged#[i] = 0
    next
    
    writeCol = GRID_SIZE - 1
    lastVal = 0
    
    for col = GRID_SIZE - 1 to 0 step -1
      idx = GetIndex(row, col)
      val = tileVal#[idx]
      
      if val > 0 then
        if lastVal = val then
          if merged#[writeCol + 2] = 0 then
            tileVal#[GetIndex(row, writeCol + 1)] = val * 2
            merged#[writeCol + 2] = 1
            let score = score + val * 2
            label_text#(lblScore#, stri$(score))
            if score > bestScore then
              let bestScore = score
              label_text#(lblBest#, stri$(bestScore))
            end if
            if val * 2 = 2048 then
              if gameWon = 0 then
                let gameWon = 1
                label_text#(lblMsg#, "You Win!")
              end if
            end if
            lastVal = 0
            moved = 1
          else
            tileVal#[GetIndex(row, writeCol)] = val
            if writeCol <> col then
              moved = 1
            end if
            writeCol = writeCol - 1
            lastVal = val
          end if
        else
          tileVal#[GetIndex(row, writeCol)] = val
          if writeCol <> col then
            moved = 1
          end if
          writeCol = writeCol - 1
          lastVal = val
        end if
      end if
    next
    
    for col = writeCol to 0 step -1
      tileVal#[GetIndex(row, col)] = 0
    next
  next
  
  return moved
end function

function MoveUp() local row, col, idx, writeRow, i, val, moved, lastVal
  moved = 0
  
  for col = 0 to GRID_SIZE - 1
    for i = 1 to GRID_SIZE
      merged#[i] = 0
    next
    
    writeRow = 0
    lastVal = 0
    
    for row = 0 to GRID_SIZE - 1
      idx = GetIndex(row, col)
      val = tileVal#[idx]
      
      if val > 0 then
        if lastVal = val then
          if merged#[writeRow] = 0 then
            tileVal#[GetIndex(writeRow - 1, col)] = val * 2
            merged#[writeRow] = 1
            let score = score + val * 2
            label_text#(lblScore#, stri$(score))
            if score > bestScore then
              let bestScore = score
              label_text#(lblBest#, stri$(bestScore))
            end if
            if val * 2 = 2048 then
              if gameWon = 0 then
                let gameWon = 1
                label_text#(lblMsg#, "You Win!")
              end if
            end if
            lastVal = 0
            moved = 1
          else
            tileVal#[GetIndex(writeRow, col)] = val
            if writeRow <> row then
              moved = 1
            end if
            writeRow = writeRow + 1
            lastVal = val
          end if
        else
          tileVal#[GetIndex(writeRow, col)] = val
          if writeRow <> row then
            moved = 1
          end if
          writeRow = writeRow + 1
          lastVal = val
        end if
      end if
    next
    
    for row = writeRow to GRID_SIZE - 1
      tileVal#[GetIndex(row, col)] = 0
    next
  next
  
  return moved
end function

function MoveDown() local row, col, idx, writeRow, i, val, moved, lastVal
  moved = 0
  
  for col = 0 to GRID_SIZE - 1
    for i = 1 to GRID_SIZE
      merged#[i] = 0
    next
    
    writeRow = GRID_SIZE - 1
    lastVal = 0
    
    for row = GRID_SIZE - 1 to 0 step -1
      idx = GetIndex(row, col)
      val = tileVal#[idx]
      
      if val > 0 then
        if lastVal = val then
          if merged#[writeRow + 2] = 0 then
            tileVal#[GetIndex(writeRow + 1, col)] = val * 2
            merged#[writeRow + 2] = 1
            let score = score + val * 2
            label_text#(lblScore#, stri$(score))
            if score > bestScore then
              let bestScore = score
              label_text#(lblBest#, stri$(bestScore))
            end if
            if val * 2 = 2048 then
              if gameWon = 0 then
                let gameWon = 1
                label_text#(lblMsg#, "You Win!")
              end if
            end if
            lastVal = 0
            moved = 1
          else
            tileVal#[GetIndex(writeRow, col)] = val
            if writeRow <> row then
              moved = 1
            end if
            writeRow = writeRow - 1
            lastVal = val
          end if
        else
          tileVal#[GetIndex(writeRow, col)] = val
          if writeRow <> row then
            moved = 1
          end if
          writeRow = writeRow - 1
          lastVal = val
        end if
      end if
    next
    
    for row = writeRow to 0 step -1
      tileVal#[GetIndex(row, col)] = 0
    next
  next
  
  return moved
end function

function CanMove() local row, col, idx, val, rightVal, downVal
  ' Check for empty tiles
  for idx = 1 to TOTAL_TILES
    if tileVal#[idx] = 0 then
      return 1
    end if
  next
  
  ' Check for possible merges
  for row = 0 to GRID_SIZE - 1
    for col = 0 to GRID_SIZE - 1
      idx = GetIndex(row, col)
      val = tileVal#[idx]
      
      ' Check right neighbor
      if col < GRID_SIZE - 1 then
        rightVal = tileVal#[GetIndex(row, col + 1)]
        if val = rightVal then
          return 1
        end if
      end if
      
      ' Check down neighbor
      if row < GRID_SIZE - 1 then
        downVal = tileVal#[GetIndex(row + 1, col)]
        if val = downVal then
          return 1
        end if
      end if
    next
  next
  
  return 0
end function

function CheckGameOver()
  if CanMove() = 0 then
    let gameOver = 1
    if IS_MOBILE = 1 then
      label_text#(lblMsg#, "Game Over! Tap to Retry")
    else
      label_text#(lblMsg#, "Game Over!")
    end if
  end if
end function
