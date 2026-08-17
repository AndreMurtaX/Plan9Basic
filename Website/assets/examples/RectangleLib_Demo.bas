' ============================================================================
' RectangleLib Visual Demo for Plan9Basic
' Version: 1.0.0
' ============================================================================
' This demo showcases various rectangle properties visually:
' - Fill colors (solid, named, hex, transparent)
' - Stroke styles (solid, dashed, dotted)
' - Corner rounding
' - Opacity
' - Rotation
' - Interactive hover and click effects
' ============================================================================

' ============================================================================
' Create Main Form
' ============================================================================
let frm# = form#("RectangleLib Visual Demo", 900, 700)
let sb# = scrollbox#(frm#)

' ============================================================================
' Section 1: Basic Colors (Row 1)
' ============================================================================
let lblColors# = rectangle#(sb#, 20, 10, 200, 25)
rectangle_fillnone#(lblColors#)
rectangle_strokenone#(lblColors#)

' Red rectangle
let r1# = rectangle#(sb#, 20, 40, 80, 60)
rectangle_fill#(r1#, "red")
rectangle_stroke#(r1#, "#800000")
rectangle_strokethickness#(r1#, 2)

' Green rectangle
let r2# = rectangle#(sb#, 110, 40, 80, 60)
rectangle_fill#(r2#, "green")
rectangle_stroke#(r2#, "#006400")
rectangle_strokethickness#(r2#, 2)

' Blue rectangle
let r3# = rectangle#(sb#, 200, 40, 80, 60)
rectangle_fill#(r3#, "blue")
rectangle_stroke#(r3#, "#000080")
rectangle_strokethickness#(r3#, 2)

' Yellow rectangle
let r4# = rectangle#(sb#, 290, 40, 80, 60)
rectangle_fill#(r4#, "yellow")
rectangle_stroke#(r4#, "#808000")
rectangle_strokethickness#(r4#, 2)

' Hex color rectangle
let r5# = rectangle#(sb#, 380, 40, 80, 60)
rectangle_fill#(r5#, "#9b59b6")
rectangle_stroke#(r5#, "#8e44ad")
rectangle_strokethickness#(r5#, 2)

' Gradient-like (using semi-transparent overlay concept)
let r6# = rectangle#(sb#, 470, 40, 80, 60)
rectangle_fill#(r6#, "#1abc9c")
rectangle_stroke#(r6#, "#16a085")
rectangle_strokethickness#(r6#, 2)

println "Section 1: Basic fill colors created"

' ============================================================================
' Section 2: Corner Rounding (Row 2)
' ============================================================================
let lblCorners# = rectangle#(sb#, 20, 110, 200, 25)
rectangle_fillnone#(lblCorners#)
rectangle_strokenone#(lblCorners#)

' No rounding
let c1# = rectangle#(sb#, 20, 140, 80, 60)
rectangle_fill#(c1#, "#3498db")
rectangle_stroke#(c1#, "#2980b9")
rectangle_strokethickness#(c1#, 2)
' corners = 0 (default)

' Small rounding
let c2# = rectangle#(sb#, 110, 140, 80, 60)
rectangle_fill#(c2#, "#3498db")
rectangle_stroke#(c2#, "#2980b9")
rectangle_strokethickness#(c2#, 2)
rectangle_corners#(c2#, 5, 5)

' Medium rounding
let c3# = rectangle#(sb#, 200, 140, 80, 60)
rectangle_fill#(c3#, "#3498db")
rectangle_stroke#(c3#, "#2980b9")
rectangle_strokethickness#(c3#, 2)
rectangle_corners#(c3#, 10, 10)

' Large rounding
let c4# = rectangle#(sb#, 290, 140, 80, 60)
rectangle_fill#(c4#, "#3498db")
rectangle_stroke#(c4#, "#2980b9")
rectangle_strokethickness#(c4#, 2)
rectangle_corners#(c4#, 20, 20)

' Pill shape (half height)
let c5# = rectangle#(sb#, 380, 140, 120, 60)
rectangle_fill#(c5#, "#3498db")
rectangle_stroke#(c5#, "#2980b9")
rectangle_strokethickness#(c2#, 2)
rectangle_corners#(c5#, 30, 30)

' Circle (equal width/height with max radius)
let c6# = rectangle#(sb#, 510, 140, 60, 60)
rectangle_fill#(c6#, "#3498db")
rectangle_stroke#(c6#, "#2980b9")
rectangle_strokethickness#(c6#, 2)
rectangle_corners#(c6#, 30, 30)

println "Section 2: Corner rounding variations created"

' ============================================================================
' Section 3: Stroke Styles (Row 3)
' ============================================================================
let lblStrokes# = rectangle#(sb#, 20, 210, 200, 25)
rectangle_fillnone#(lblStrokes#)
rectangle_strokenone#(lblStrokes#)

' Solid stroke
let s1# = rectangle#(sb#, 20, 240, 80, 60)
rectangle_fill#(s1#, "#ecf0f1")
rectangle_stroke#(s1#, "#e74c3c")
rectangle_strokethickness#(s1#, 3)
rectangle_strokedash#(s1#, 0)

' Dashed stroke
let s2# = rectangle#(sb#, 110, 240, 80, 60)
rectangle_fill#(s2#, "#ecf0f1")
rectangle_stroke#(s2#, "#e74c3c")
rectangle_strokethickness#(s2#, 3)
rectangle_strokedash#(s2#, 1)

' Dotted stroke
let s3# = rectangle#(sb#, 200, 240, 80, 60)
rectangle_fill#(s3#, "#ecf0f1")
rectangle_stroke#(s3#, "#e74c3c")
rectangle_strokethickness#(s3#, 3)
rectangle_strokedash#(s3#, 2)

' DashDot stroke
let s4# = rectangle#(sb#, 290, 240, 80, 60)
rectangle_fill#(s4#, "#ecf0f1")
rectangle_stroke#(s4#, "#e74c3c")
rectangle_strokethickness#(s4#, 3)
rectangle_strokedash#(s4#, 3)

' DashDotDot stroke
let s5# = rectangle#(sb#, 380, 240, 80, 60)
rectangle_fill#(s5#, "#ecf0f1")
rectangle_stroke#(s5#, "#e74c3c")
rectangle_strokethickness#(s5#, 3)
rectangle_strokedash#(s5#, 4)

' Thick stroke
let s6# = rectangle#(sb#, 470, 240, 80, 60)
rectangle_fill#(s6#, "#ecf0f1")
rectangle_stroke#(s6#, "#e74c3c")
rectangle_strokethickness#(s6#, 8)

println "Section 3: Stroke styles created"

' ============================================================================
' Section 4: Opacity Levels (Row 4)
' ============================================================================
let lblOpacity# = rectangle#(sb#, 20, 310, 200, 25)
rectangle_fillnone#(lblOpacity#)
rectangle_strokenone#(lblOpacity#)

' Background for opacity demo
let opacityBg# = rectangle#(sb#, 20, 340, 530, 60)
rectangle_fill#(opacityBg#, "#2c3e50")
rectangle_strokenone#(opacityBg#)

' Opacity 100%
let o1# = rectangle#(sb#, 30, 350, 80, 40)
rectangle_fill#(o1#, "#f39c12")
rectangle_strokenone#(o1#)
rectangle_opacity#(o1#, 1.0)

' Opacity 80%
let o2# = rectangle#(sb#, 120, 350, 80, 40)
rectangle_fill#(o2#, "#f39c12")
rectangle_strokenone#(o2#)
rectangle_opacity#(o2#, 0.8)

' Opacity 60%
let o3# = rectangle#(sb#, 210, 350, 80, 40)
rectangle_fill#(o3#, "#f39c12")
rectangle_strokenone#(o3#)
rectangle_opacity#(o3#, 0.6)

' Opacity 40%
let o4# = rectangle#(sb#, 300, 350, 80, 40)
rectangle_fill#(o4#, "#f39c12")
rectangle_strokenone#(o4#)
rectangle_opacity#(o4#, 0.4)

' Opacity 20%
let o5# = rectangle#(sb#, 390, 350, 80, 40)
rectangle_fill#(o5#, "#f39c12")
rectangle_strokenone#(o5#)
rectangle_opacity#(o5#, 0.2)

println "Section 4: Opacity levels created"

' ============================================================================
' Section 5: Rotation (Row 5)
' ============================================================================
let lblRotation# = rectangle#(sb#, 20, 410, 200, 25)
rectangle_fillnone#(lblRotation#)
rectangle_strokenone#(lblRotation#)

' 0 degrees
let rot1# = rectangle#(sb#, 50, 450, 50, 50)
rectangle_fill#(rot1#, "#27ae60")
rectangle_stroke#(rot1#, "#1e8449")
rectangle_strokethickness#(rot1#, 2)
rectangle_rotation#(rot1#, 0)

' 15 degrees
let rot2# = rectangle#(sb#, 140, 450, 50, 50)
rectangle_fill#(rot2#, "#27ae60")
rectangle_stroke#(rot2#, "#1e8449")
rectangle_strokethickness#(rot2#, 2)
rectangle_rotation#(rot2#, 15)

' 30 degrees
let rot3# = rectangle#(sb#, 230, 450, 50, 50)
rectangle_fill#(rot3#, "#27ae60")
rectangle_stroke#(rot3#, "#1e8449")
rectangle_strokethickness#(rot3#, 2)
rectangle_rotation#(rot3#, 30)

' 45 degrees
let rot4# = rectangle#(sb#, 320, 450, 50, 50)
rectangle_fill#(rot4#, "#27ae60")
rectangle_stroke#(rot4#, "#1e8449")
rectangle_strokethickness#(rot4#, 2)
rectangle_rotation#(rot4#, 45)

' 60 degrees
let rot5# = rectangle#(sb#, 410, 450, 50, 50)
rectangle_fill#(rot5#, "#27ae60")
rectangle_stroke#(rot5#, "#1e8449")
rectangle_strokethickness#(rot5#, 2)
rectangle_rotation#(rot5#, 60)

' 90 degrees
let rot6# = rectangle#(sb#, 500, 450, 50, 50)
rectangle_fill#(rot6#, "#27ae60")
rectangle_stroke#(rot6#, "#1e8449")
rectangle_strokethickness#(rot6#, 2)
rectangle_rotation#(rot6#, 90)

println "Section 5: Rotated rectangles created"

' ============================================================================
' Section 6: Interactive Buttons (Row 6)
' ============================================================================
let lblInteractive# = rectangle#(sb#, 20, 520, 300, 25)
rectangle_fillnone#(lblInteractive#)
rectangle_strokenone#(lblInteractive#)

' Interactive button 1 - Changes color on hover
let btn1# = rectangle#(sb#, 20, 550, 120, 45)
rectangle_fill#(btn1#, "#3498db")
rectangle_stroke#(btn1#, "#2980b9")
rectangle_strokethickness#(btn1#, 2)
rectangle_corners#(btn1#, 8, 8)
rectangle_tag#(btn1#, 1)
rectangle_onmouseenter#(btn1#, "OnButtonEnter")
rectangle_onmouseleave#(btn1#, "OnButtonLeave")
rectangle_onclick#(btn1#, "OnButtonClick")

' Interactive button 2
let btn2# = rectangle#(sb#, 150, 550, 120, 45)
rectangle_fill#(btn2#, "#e74c3c")
rectangle_stroke#(btn2#, "#c0392b")
rectangle_strokethickness#(btn2#, 2)
rectangle_corners#(btn2#, 8, 8)
rectangle_tag#(btn2#, 2)
rectangle_onmouseenter#(btn2#, "OnButtonEnter")
rectangle_onmouseleave#(btn2#, "OnButtonLeave")
rectangle_onclick#(btn2#, "OnButtonClick")

' Interactive button 3
let btn3# = rectangle#(sb#, 280, 550, 120, 45)
rectangle_fill#(btn3#, "#27ae60")
rectangle_stroke#(btn3#, "#1e8449")
rectangle_strokethickness#(btn3#, 2)
rectangle_corners#(btn3#, 8, 8)
rectangle_tag#(btn3#, 3)
rectangle_onmouseenter#(btn3#, "OnButtonEnter")
rectangle_onmouseleave#(btn3#, "OnButtonLeave")
rectangle_onclick#(btn3#, "OnButtonClick")

' Interactive button 4 - Rotation on click
let btn4# = rectangle#(sb#, 410, 550, 120, 45)
rectangle_fill#(btn4#, "#9b59b6")
rectangle_stroke#(btn4#, "#8e44ad")
rectangle_strokethickness#(btn4#, 2)
rectangle_corners#(btn4#, 8, 8)
rectangle_tag#(btn4#, 4)
rectangle_onmouseenter#(btn4#, "OnButtonEnter")
rectangle_onmouseleave#(btn4#, "OnButtonLeave")
rectangle_onclick#(btn4#, "OnRotateClick")

println "Section 6: Interactive buttons created"

' ============================================================================
' Section 7: Selective Sides Demo (Right side)
' ============================================================================
let lblSides# = rectangle#(sb#, 600, 10, 200, 25)
rectangle_fillnone#(lblSides#)
rectangle_strokenone#(lblSides#)

' All sides (default)
let side1# = rectangle#(sb#, 600, 40, 80, 50)
rectangle_fill#(side1#, "#ecf0f1")
rectangle_stroke#(side1#, "#34495e")
rectangle_strokethickness#(side1#, 3)
rectangle_sides#(side1#, 15)

' Top only
let side2# = rectangle#(sb#, 700, 40, 80, 50)
rectangle_fill#(side2#, "#ecf0f1")
rectangle_stroke#(side2#, "#34495e")
rectangle_strokethickness#(side2#, 3)
rectangle_sides#(side2#, 1)

' Top and Bottom
let side3# = rectangle#(sb#, 600, 100, 80, 50)
rectangle_fill#(side3#, "#ecf0f1")
rectangle_stroke#(side3#, "#34495e")
rectangle_strokethickness#(side3#, 3)
rectangle_sides#(side3#, 5)

' Left and Right
let side4# = rectangle#(sb#, 700, 100, 80, 50)
rectangle_fill#(side4#, "#ecf0f1")
rectangle_stroke#(side4#, "#34495e")
rectangle_strokethickness#(side4#, 3)
rectangle_sides#(side4#, 10)

println "Section 7: Selective sides created"

' ============================================================================
' Section 8: Selective Corners Demo
' ============================================================================
let lblCornerSel# = rectangle#(sb#, 600, 160, 200, 25)
rectangle_fillnone#(lblCornerSel#)
rectangle_strokenone#(lblCornerSel#)

' All corners rounded
let corner1# = rectangle#(sb#, 600, 190, 80, 50)
rectangle_fill#(corner1#, "#1abc9c")
rectangle_stroke#(corner1#, "#16a085")
rectangle_strokethickness#(corner1#, 2)
rectangle_corners#(corner1#, 15, 15)
rectangle_cornersflags#(corner1#, 15)

' Top corners only
let corner2# = rectangle#(sb#, 700, 190, 80, 50)
rectangle_fill#(corner2#, "#1abc9c")
rectangle_stroke#(corner2#, "#16a085")
rectangle_strokethickness#(corner2#, 2)
rectangle_corners#(corner2#, 15, 15)
rectangle_cornersflags#(corner2#, 3)

' Bottom corners only
let corner3# = rectangle#(sb#, 600, 250, 80, 50)
rectangle_fill#(corner3#, "#1abc9c")
rectangle_stroke#(corner3#, "#16a085")
rectangle_strokethickness#(corner3#, 2)
rectangle_corners#(corner3#, 15, 15)
rectangle_cornersflags#(corner3#, 12)

' Diagonal corners
let corner4# = rectangle#(sb#, 700, 250, 80, 50)
rectangle_fill#(corner4#, "#1abc9c")
rectangle_stroke#(corner4#, "#16a085")
rectangle_strokethickness#(corner4#, 2)
rectangle_corners#(corner4#, 15, 15)
rectangle_cornersflags#(corner4#, 9)

println "Section 8: Selective corners created"

' ============================================================================
' Section 9: Card with Shadow Effect
' ============================================================================
let lblCard# = rectangle#(sb#, 600, 310, 200, 25)
rectangle_fillnone#(lblCard#)
rectangle_strokenone#(lblCard#)

' Shadow
let shadow# = rectangle#(sb#, 607, 347, 180, 100)
rectangle_fill#(shadow#, "#40000000")
rectangle_strokenone#(shadow#)
rectangle_corners#(shadow#, 12, 12)

' Card
let card# = rectangle#(sb#, 600, 340, 180, 100)
rectangle_fill#(card#, "white")
rectangle_stroke#(card#, "#e0e0e0")
rectangle_strokethickness#(card#, 1)
rectangle_corners#(card#, 10, 10)

println "Section 9: Card with shadow created"

' ============================================================================
' Section 10: Animated Progress Bar
' ============================================================================
let lblProgress# = rectangle#(sb#, 600, 450, 200, 25)
rectangle_fillnone#(lblProgress#)
rectangle_strokenone#(lblProgress#)

' Progress background
let progBg# = rectangle#(sb#, 600, 480, 200, 25)
rectangle_fill#(progBg#, "#ecf0f1")
rectangle_stroke#(progBg#, "#bdc3c7")
rectangle_corners#(progBg#, 5, 5)

' Progress fill
let progFill# = rectangle#(sb#, 600, 480, 0, 25)
rectangle_fill#(progFill#, "#27ae60")
rectangle_strokenone#(progFill#)
rectangle_corners#(progFill#, 5, 5)

println "Section 10: Progress bar created"

' ============================================================================
' Status display
' ============================================================================
let statusBg# = rectangle#(sb#, 20, 620, 760, 40)
rectangle_fill#(statusBg#, "#34495e")
rectangle_strokenone#(statusBg#)
rectangle_corners#(statusBg#, 5, 5)

println ""
println "All sections created successfully!"
println "Click on the colored buttons to see interactions."
println "The progress bar will animate shortly..."

' ============================================================================
' Show the form
' ============================================================================
form_show(frm#)

' ============================================================================
' Animate progress bar
' ============================================================================
for p = 0 to 100
  rectangle_width#(progFill#, p * 2)
  pause(0.02)
next

println "Progress bar animation complete!"
println ""
println "Demo is now interactive - try hovering and clicking the buttons!"

' ============================================================================
' Event Handlers
' ============================================================================

' Store original colors for hover effect
let btn1OrigColor$ = "#3498db"
let btn2OrigColor$ = "#e74c3c"
let btn3OrigColor$ = "#27ae60"
let btn4OrigColor$ = "#9b59b6"

let btn1HoverColor$ = "#2980b9"
let btn2HoverColor$ = "#c0392b"
let btn3HoverColor$ = "#1e8449"
let btn4HoverColor$ = "#8e44ad"

let rotationAngle = 0

function OnButtonEnter(sender#) local tag
  tag = rectangle_tag(sender#)
  if tag = 1 then
    rectangle_fill#(sender#, btn1HoverColor$)
  endif
  if tag = 2 then
    rectangle_fill#(sender#, btn2HoverColor$)
  endif
  if tag = 3 then
    rectangle_fill#(sender#, btn3HoverColor$)
  endif
  if tag = 4 then
    rectangle_fill#(sender#, btn4HoverColor$)
  endif
  println "Mouse entered button " + stri$(tag)
endfunction

function OnButtonLeave(sender#) local tag
  tag = rectangle_tag(sender#)
  if tag = 1 then
    rectangle_fill#(sender#, btn1OrigColor$)
  endif
  if tag = 2 then
    rectangle_fill#(sender#, btn2OrigColor$)
  endif
  if tag = 3 then
    rectangle_fill#(sender#, btn3OrigColor$)
  endif
  if tag = 4 then
    rectangle_fill#(sender#, btn4OrigColor$)
  endif
  println "Mouse left button " + stri$(tag)
endfunction

function OnButtonClick(sender#) local tag
  tag = rectangle_tag(sender#)
  println "Button " + stri$(tag) + " clicked!"
  
  ' Brief flash effect
  rectangle_fill#(sender#, "white")
  pause(0.1)
  
  if tag = 1 then
    rectangle_fill#(sender#, btn1OrigColor$)
  endif
  if tag = 2 then
    rectangle_fill#(sender#, btn2OrigColor$)
  endif
  if tag = 3 then
    rectangle_fill#(sender#, btn3OrigColor$)
  endif
endfunction

function OnRotateClick(sender#)
  rotationAngle = rotationAngle + 15
  if rotationAngle >= 360 then
    rotationAngle = 0
  endif
  rectangle_rotation#(sender#, rotationAngle)
  println "Button 4 rotated to " + stri$(rotationAngle) + " degrees"
  
  ' Return to original color
  rectangle_fill#(sender#, btn4OrigColor$)
endfunction
