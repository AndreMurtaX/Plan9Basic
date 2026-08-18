' =============================================================================
' BitmapListAnimationLib Test Suite (Fixed)
' Tests sprite sheet animations
' 
' NOTE: This test requires sprite sheet image files to work properly.
' You MUST load a sprite sheet before clicking Play!
' =============================================================================

' Module-level variables
let frm# = Pointer#(0)
let sb# = Pointer#(0)
let statusLbl# = Pointer#(0)
let sprite1# = Pointer#(0)
let sprite2# = Pointer#(0)
let sprite3# = Pointer#(0)
let ani1# = Pointer#(0)
let ani2# = Pointer#(0)
let ani3# = Pointer#(0)
let panel1# = Pointer#(0)
let panel2# = Pointer#(0)
let panel3# = Pointer#(0)
let playBtn1# = Pointer#(0)
let stopBtn1# = Pointer#(0)
let loopCount = 0

' -----------------------------------------------------------------------------
' Main Program
' -----------------------------------------------------------------------------
println "BitmapListAnimationLib Test Suite"
println "================================="
println ""
println "This test demonstrates sprite sheet animations."
println "You need sprite sheet image files for full functionality."
println ""
println "*** IMPORTANT: Load a sprite sheet BEFORE clicking Play! ***"
println ""

gosub CreateUI
gosub CreateAnimations
gosub ShowInstructions

form_show(frm#)

println ""
println "Test applet running. Close the window to exit."
end

' -----------------------------------------------------------------------------
' Create User Interface
' -----------------------------------------------------------------------------
CreateUI:
  frm# = form#("BitmapListAnimationLib Test Suite", 800, 600)
  sb# = scrollbox#(frm#)

  ' Status label at top
  statusLbl# = label#(sb#, "Load a sprite sheet before clicking Play", 10, 10, 780, 25)

  ' Panel 1: Basic looping animation
  panel1# = panel#(sb#, 10, 45, 250, 320)
  let lbl1# = label#(panel1#, "1. Looping Animation", 5, 5, 240, 20)
  
  ' Create image for sprite display
  sprite1# = image#(panel1#, 75, 40, 100, 100)
  image_wrapmode#(sprite1#, 1)  ' Fit mode
  
  ' Control buttons
  playBtn1# = button#(panel1#, "Play", 10, 150, 70, 30)
  button_onclick#(playBtn1#, "OnPlay1Click")
  
  stopBtn1# = button#(panel1#, "Stop", 90, 150, 70, 30)
  button_onclick#(stopBtn1#, "OnStop1Click")
  
  let loadBtn1# = button#(panel1#, "Load...", 170, 150, 70, 30)
  button_onclick#(loadBtn1#, "OnLoad1Click")
  
  ' Settings
  let lblFrames1# = label#(panel1#, "Frames: 8", 10, 190, 80, 20)
  let lblRows1# = label#(panel1#, "Rows: 2", 100, 190, 80, 20)
  let lblDur1# = label#(panel1#, "Duration: 1.0s", 10, 215, 150, 20)
  let loopLbl1# = label#(panel1#, "Loop count: 0", 10, 240, 200, 20)
  
  ' Instructions in panel
  let instLbl1# = label#(panel1#, "Click Load FIRST, then Play!", 10, 270, 230, 45)
  
  ' Panel 2: AutoReverse animation
  panel2# = panel#(sb#, 270, 45, 250, 320)
  let lbl2# = label#(panel2#, "2. AutoReverse (Ping-Pong)", 5, 5, 240, 20)
  
  sprite2# = image#(panel2#, 75, 40, 100, 100)
  image_wrapmode#(sprite2#, 1)
  
  let playBtn2# = button#(panel2#, "Play", 10, 150, 70, 30)
  button_onclick#(playBtn2#, "OnPlay2Click")
  
  let stopBtn2# = button#(panel2#, "Stop", 90, 150, 70, 30)
  button_onclick#(stopBtn2#, "OnStop2Click")
  
  let loadBtn2# = button#(panel2#, "Load...", 170, 150, 70, 30)
  button_onclick#(loadBtn2#, "OnLoad2Click")
  
  let instLbl2# = label#(panel2#, "Plays forward then backward. Load sprite sheet first!", 10, 190, 230, 60)
  
  ' Panel 3: Single play (no loop)
  panel3# = panel#(sb#, 530, 45, 250, 320)
  let lbl3# = label#(panel3#, "3. Play Once (Explosion)", 5, 5, 240, 20)
  
  sprite3# = image#(panel3#, 75, 40, 100, 100)
  image_wrapmode#(sprite3#, 1)
  
  let playBtn3# = button#(panel3#, "Play", 10, 150, 70, 30)
  button_onclick#(playBtn3#, "OnPlay3Click")
  
  let resetBtn3# = button#(panel3#, "Reset", 90, 150, 70, 30)
  button_onclick#(resetBtn3#, "OnReset3Click")
  
  let loadBtn3# = button#(panel3#, "Load...", 170, 150, 70, 30)
  button_onclick#(loadBtn3#, "OnLoad3Click")
  
  let instLbl3# = label#(panel3#, "Plays once then stops. Load sprite sheet first!", 10, 190, 230, 60)
  
  ' Info panel at bottom
  let infoPanel# = panel#(sb#, 10, 375, 770, 180)
  let infoLbl# = label#(infoPanel#, "SPRITE SHEET FORMAT: Single image with all frames in a grid (left-to-right, top-to-bottom). Example: 8 frames in 2 rows = 4 columns. Use PNG format. You MUST load a sprite sheet before animations will work!", 10, 10, 750, 160)
return

' -----------------------------------------------------------------------------
' Create Animations
' -----------------------------------------------------------------------------
CreateAnimations:
  ' Animation 1: Basic looping
  ani1# = bmplistani#(sprite1#)
  bmplistani_animationcount#(ani1#, 8)
  bmplistani_animationrowcount#(ani1#, 2)
  bmplistani_duration#(ani1#, 1.0)
  bmplistani_loop#(ani1#, 1)
  bmplistani_onfinish#(ani1#, "OnAni1Finish")
  
  println "Animation 1 created: Basic looping"
  println "  Frames: 8, Rows: 2, Duration: 1.0s"
  
  ' Animation 2: AutoReverse (ping-pong)
  ani2# = bmplistani#(sprite2#)
  bmplistani_animationcount#(ani2#, 8)
  bmplistani_animationrowcount#(ani2#, 2)
  bmplistani_duration#(ani2#, 1.5)
  bmplistani_loop#(ani2#, 1)
  bmplistani_autoreverse#(ani2#, 1)
  
  println ""
  println "Animation 2 created: AutoReverse"
  println "  Frames: 8, Rows: 2, Duration: 1.5s, AutoReverse: On"
  
  ' Animation 3: Play once
  ani3# = bmplistani#(sprite3#)
  bmplistani_animationcount#(ani3#, 12)
  bmplistani_animationrowcount#(ani3#, 3)
  bmplistani_duration#(ani3#, 0.5)
  bmplistani_loop#(ani3#, 0)
  bmplistani_onfinish#(ani3#, "OnAni3Finish")
  
  println ""
  println "Animation 3 created: Play Once"
  println "  Frames: 12, Rows: 3, Duration: 0.5s, Loop: Off"
return

' -----------------------------------------------------------------------------
' Show Instructions in Console
' -----------------------------------------------------------------------------
ShowInstructions:
  println ""
  println "=== HOW TO USE ==="
  println ""
  println "1. Create sprite sheet images using tools like:"
  println "   - Aseprite (pixel art)"
  println "   - TexturePacker"
  println "   - Piskel (free online)"
  println "   - GIMP/Photoshop"
  println ""
  println "2. Export as PNG with frames in a grid layout"
  println ""
  println "3. Copy your PNG sprite sheet files to:"
  println "   " + documentspath$()
  println "   Expected filenames: walk_cycle.png, character_idle.png, explosion.png"
  println ""
  println "4. Click 'Load...' button FIRST to load your sprite sheet"
  println ""
  println "5. THEN click 'Play' to start the animation"
return

' -----------------------------------------------------------------------------
' Button Handlers - Animation 1
' -----------------------------------------------------------------------------
function OnPlay1Click(sender#) local errCode
  bmplistani_start(ani1#)
  errCode = bmplistani_error()
  if errCode <> 0 then
    label_text#(statusLbl#, "ERROR: " + bmplistani_errormsg$())
    println "Start error: " + bmplistani_errormsg$()
  else
    label_text#(statusLbl#, "Animation 1 playing...")
  endif
endfunction

function OnStop1Click(sender#)
  bmplistani_stop(ani1#)
  label_text#(statusLbl#, "Animation 1 stopped")
endfunction

function OnLoad1Click(sender#) local filePath$
  ' In a real app, you would use a file dialog
  ' For now, we'll use a hardcoded test path
  filePath$ = documentspath$() + "walk_cycle.png"

  println "Attempting to load: " + filePath$
  bmplistani_loadspritesheet#(ani1#, filePath$)

  if bmplistani_error() = 0 then
    label_text#(statusLbl#, "Loaded: walk_cycle.png - Ready to Play!")
    println "Sprite sheet loaded successfully"
  else
    label_text#(statusLbl#, "Load error: " + bmplistani_errormsg$())
    println "Load error: " + bmplistani_errormsg$()
    println "Please copy walk_cycle.png to: " + documentspath$()
  endif
endfunction

function OnAni1Finish(sender#) local msg$
  loopCount = loopCount + 1
  msg$ = "Animation 1 completed loop #" + str$(loopCount)
  label_text#(statusLbl#, msg$)
endfunction

' -----------------------------------------------------------------------------
' Button Handlers - Animation 2
' -----------------------------------------------------------------------------
function OnPlay2Click(sender#) local errCode
  bmplistani_start(ani2#)
  errCode = bmplistani_error()
  if errCode <> 0 then
    label_text#(statusLbl#, "ERROR: " + bmplistani_errormsg$())
    println "Start error: " + bmplistani_errormsg$()
  else
    label_text#(statusLbl#, "Animation 2 playing (ping-pong)...")
  endif
endfunction

function OnStop2Click(sender#)
  bmplistani_stop(ani2#)
  label_text#(statusLbl#, "Animation 2 stopped")
endfunction

function OnLoad2Click(sender#) local filePath$
  filePath$ = documentspath$() + "character_idle.png"

  println "Attempting to load: " + filePath$
  bmplistani_loadspritesheet#(ani2#, filePath$)

  if bmplistani_error() = 0 then
    label_text#(statusLbl#, "Loaded: character_idle.png - Ready to Play!")
  else
    label_text#(statusLbl#, "Load error: " + bmplistani_errormsg$())
    println "Load error: " + bmplistani_errormsg$()
    println "Please copy character_idle.png to: " + documentspath$()
  endif
endfunction

' -----------------------------------------------------------------------------
' Button Handlers - Animation 3
' -----------------------------------------------------------------------------
function OnPlay3Click(sender#) local errCode
  image_visible#(sprite3#, 1)
  bmplistani_start(ani3#)
  errCode = bmplistani_error()
  if errCode <> 0 then
    label_text#(statusLbl#, "ERROR: " + bmplistani_errormsg$())
    println "Start error: " + bmplistani_errormsg$()
  else
    label_text#(statusLbl#, "Animation 3 playing (once)...")
  endif
endfunction

function OnReset3Click(sender#)
  bmplistani_stop(ani3#)
  image_visible#(sprite3#, 1)
  label_text#(statusLbl#, "Animation 3 reset")
endfunction

function OnLoad3Click(sender#) local filePath$
  filePath$ = documentspath$() + "explosion.png"

  println "Attempting to load: " + filePath$
  bmplistani_loadspritesheet#(ani3#, filePath$)

  if bmplistani_error() = 0 then
    label_text#(statusLbl#, "Loaded: explosion.png - Ready to Play!")
  else
    label_text#(statusLbl#, "Load error: " + bmplistani_errormsg$())
    println "Load error: " + bmplistani_errormsg$()
    println "Please copy explosion.png to: " + documentspath$()
  endif
endfunction

function OnAni3Finish(sender#)
  label_text#(statusLbl#, "Animation 3 finished - sprite stays on last frame")
  println "Play-once animation completed"
endfunction
