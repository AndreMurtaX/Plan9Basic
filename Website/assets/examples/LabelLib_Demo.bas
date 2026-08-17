' ============================================================================
' LabelLib Visual Demo for Plan9Basic
' Version: 1.0.0
' ============================================================================
' This demo showcases various label properties visually:
' - Font sizes
' - Font styles (bold, italic, underline, strikeout)
' - Text colors
' - Text alignment
' - Word wrap
' - Interactive labels (clickable links)
' - Rotated labels
' ============================================================================
' ATTENTION!!!
' This applet will make a series of tests before the window form presentation
' finishes to draw itself. It will be normal to take some time until the
' window actually complete to present itself, when you choose the RUN option.
' ============================================================================
' Create Main Form
' ============================================================================
LET frm# = form#("LabelLib Visual Demo", 900, 700)
LET sb# = scrollbox#(frm#)
' ============================================================================
' Section 1: Font Sizes
' ============================================================================
LET sec1Bg# = rectangle#(sb#, 15, 10, 420, 110)
rectangle_fill#(sec1Bg#, "#f8f9fa")
rectangle_stroke#(sec1Bg#, "#dee2e6")
rectangle_corners#(sec1Bg#, 5, 5)
LET sec1Title# = label#(sb#, "Font Sizes", 25, 15)
label_fontsize#(sec1Title#, 12)
label_fontcolor#(sec1Title#, "#6c757d")
LET size1# = label#(sb#, "Size 10", 25, 40)
label_fontsize#(size1#, 10)
LET size2# = label#(sb#, "Size 14", 85, 40)
label_fontsize#(size2#, 14)
LET size3# = label#(sb#, "Size 18", 160, 40)
label_fontsize#(size3#, 18)
LET size4# = label#(sb#, "Size 24", 250, 40)
label_fontsize#(size4#, 24)
LET size5# = label#(sb#, "Size 32", 25, 75)
label_fontsize#(size5#, 32)
LET size6# = label#(sb#, "Size 48", 160, 65)
label_fontsize#(size6#, 48)
PRINTLN "Section 1: Font sizes created"
' ============================================================================
' Section 2: Font Styles
' ============================================================================
LET sec2Bg# = rectangle#(sb#, 15, 130, 420, 110)
rectangle_fill#(sec2Bg#, "#f8f9fa")
rectangle_stroke#(sec2Bg#, "#dee2e6")
rectangle_corners#(sec2Bg#, 5, 5)
LET sec2Title# = label#(sb#, "Font Styles", 25, 135)
label_fontsize#(sec2Title#, 12)
label_fontcolor#(sec2Title#, "#6c757d")
LET style1# = label#(sb#, "Normal", 25, 160)
label_fontsize#(style1#, 18)
LET style2# = label#(sb#, "Bold", 100, 160)
label_fontsize#(style2#, 18)
label_bold#(style2#, 1)
LET style3# = label#(sb#, "Italic", 160, 160)
label_fontsize#(style3#, 18)
label_italic#(style3#, 1)
LET style4# = label#(sb#, "Bold Italic", 230, 160)
label_fontsize#(style4#, 18)
label_bold#(style4#, 1)
label_italic#(style4#, 1)
LET style5# = label#(sb#, "Underlined", 25, 195)
label_fontsize#(style5#, 18)
label_underline#(style5#, 1)
LET style6# = label#(sb#, "Strikeout", 145, 195)
label_fontsize#(style6#, 18)
label_strikeout#(style6#, 1)
LET style7# = label#(sb#, "All Styles", 260, 195)
label_fontsize#(style7#, 18)
label_bold#(style7#, 1)
label_italic#(style7#, 1)
label_underline#(style7#, 1)
PRINTLN "Section 2: Font styles created"
' ============================================================================
' Section 3: Text Colors
' ============================================================================
LET sec3Bg# = rectangle#(sb#, 15, 250, 420, 80)
rectangle_fill#(sec3Bg#, "#f8f9fa")
rectangle_stroke#(sec3Bg#, "#dee2e6")
rectangle_corners#(sec3Bg#, 5, 5)
LET sec3Title# = label#(sb#, "Text Colors", 25, 255)
label_fontsize#(sec3Title#, 12)
label_fontcolor#(sec3Title#, "#6c757d")
LET color1# = label#(sb#, "Red", 25, 280)
label_fontsize#(color1#, 16)
label_fontcolor#(color1#, "#e74c3c")
label_bold#(color1#, 1)
LET color2# = label#(sb#, "Orange", 70, 280)
label_fontsize#(color2#, 16)
label_fontcolor#(color2#, "#f39c12")
label_bold#(color2#, 1)
LET color3# = label#(sb#, "Green", 145, 280)
label_fontsize#(color3#, 16)
label_fontcolor#(color3#, "#27ae60")
label_bold#(color3#, 1)
LET color4# = label#(sb#, "Blue", 215, 280)
label_fontsize#(color4#, 16)
label_fontcolor#(color4#, "#3498db")
label_bold#(color4#, 1)
LET color5# = label#(sb#, "Purple", 270, 280)
label_fontsize#(color5#, 16)
label_fontcolor#(color5#, "#9b59b6")
label_bold#(color5#, 1)
LET color6# = label#(sb#, "Teal", 345, 280)
label_fontsize#(color6#, 16)
label_fontcolor#(color6#, "#1abc9c")
label_bold#(color6#, 1)
PRINTLN "Section 3: Text colors created"
' ============================================================================
' Section 4: Text Alignment (in a fixed box)
' ============================================================================
LET sec4Bg# = rectangle#(sb#, 15, 340, 420, 140)
rectangle_fill#(sec4Bg#, "#f8f9fa")
rectangle_stroke#(sec4Bg#, "#dee2e6")
rectangle_corners#(sec4Bg#, 5, 5)
LET sec4Title# = label#(sb#, "Text Alignment", 25, 345)
label_fontsize#(sec4Title#, 12)
label_fontcolor#(sec4Title#, "#6c757d")
' Alignment boxes
LET alignBox1# = rectangle#(sb#, 25, 370, 120, 50)
rectangle_fill#(alignBox1#, "white")
rectangle_stroke#(alignBox1#, "#adb5bd")
LET align1# = label#(sb#, "Left Top", 25, 370, 120, 50)
label_autosize#(align1#, 0)
label_textalign#(align1#, 1)
label_vertalign#(align1#, 1)
label_fontsize#(align1#, 12)
LET alignBox2# = rectangle#(sb#, 155, 370, 120, 50)
rectangle_fill#(alignBox2#, "white")
rectangle_stroke#(alignBox2#, "#adb5bd")
LET align2# = label#(sb#, "Center", 155, 370, 120, 50)
label_autosize#(align2#, 0)
label_textalign#(align2#, 0)
label_vertalign#(align2#, 0)
label_fontsize#(align2#, 12)
LET alignBox3# = rectangle#(sb#, 285, 370, 120, 50)
rectangle_fill#(alignBox3#, "white")
rectangle_stroke#(alignBox3#, "#adb5bd")
LET align3# = label#(sb#, "Right Bottom", 285, 370, 120, 50)
label_autosize#(align3#, 0)
label_textalign#(align3#, 2)
label_vertalign#(align3#, 2)
label_fontsize#(align3#, 12)
' Word wrap demo
LET wrapBox# = rectangle#(sb#, 25, 430, 380, 40)
rectangle_fill#(wrapBox#, "white")
rectangle_stroke#(wrapBox#, "#adb5bd")
LET wrapLabel# = label#(sb#, "This is a longer text that demonstrates word wrapping. The text will automatically wrap to fit within the label bounds.", 25, 430, 380, 40)
label_autosize#(wrapLabel#, 0)
label_wordwrap#(wrapLabel#, 1)
label_fontsize#(wrapLabel#, 11)
label_textalign#(wrapLabel#, 1)
label_vertalign#(wrapLabel#, 1)
PRINTLN "Section 4: Text alignment created"
' ============================================================================
' Section 5: Interactive Labels (Right Column)
' ============================================================================
LET sec5Bg# = rectangle#(sb#, 455, 10, 420, 110)
rectangle_fill#(sec5Bg#, "#f8f9fa")
rectangle_stroke#(sec5Bg#, "#dee2e6")
rectangle_corners#(sec5Bg#, 5, 5)
LET sec5Title# = label#(sb#, "Interactive Labels (Click Me!)", 465, 15)
label_fontsize#(sec5Title#, 12)
label_fontcolor#(sec5Title#, "#6c757d")
' Clickable link style labels
LET link1# = label#(sb#, "Click for Blue", 465, 45)
label_fontsize#(link1#, 16)
label_fontcolor#(link1#, "#3498db")
label_underline#(link1#, 1)
label_tag#(link1#, 1)
label_onclick#(link1#, "OnLinkClick")
label_onmouseenter#(link1#, "OnLinkEnter")
label_onmouseleave#(link1#, "OnLinkLeave")
LET link2# = label#(sb#, "Click for Red", 600, 45)
label_fontsize#(link2#, 16)
label_fontcolor#(link2#, "#e74c3c")
label_underline#(link2#, 1)
label_tag#(link2#, 2)
label_onclick#(link2#, "OnLinkClick")
label_onmouseenter#(link2#, "OnLinkEnter")
label_onmouseleave#(link2#, "OnLinkLeave")
LET link3# = label#(sb#, "Click for Green", 730, 45)
label_fontsize#(link3#, 16)
label_fontcolor#(link3#, "#27ae60")
label_underline#(link3#, 1)
label_tag#(link3#, 3)
label_onclick#(link3#, "OnLinkClick")
label_onmouseenter#(link3#, "OnLinkEnter")
label_onmouseleave#(link3#, "OnLinkLeave")
' Result display
LET resultBg# = rectangle#(sb#, 465, 75, 400, 35)
rectangle_fill#(resultBg#, "#2c3e50")
rectangle_corners#(resultBg#, 5, 5)
LET resultLabel# = label#(sb#, "Click a link above!", 475, 82)
label_fontsize#(resultLabel#, 18)
label_fontcolor#(resultLabel#, "white")
PRINTLN "Section 5: Interactive labels created"
' ============================================================================
' Section 6: Rotated Labels
' ============================================================================
LET sec6Bg# = rectangle#(sb#, 455, 130, 420, 110)
rectangle_fill#(sec6Bg#, "#f8f9fa")
rectangle_stroke#(sec6Bg#, "#dee2e6")
rectangle_corners#(sec6Bg#, 5, 5)
LET sec6Title# = label#(sb#, "Rotated Labels", 465, 135)
label_fontsize#(sec6Title#, 12)
label_fontcolor#(sec6Title#, "#6c757d")
LET rot1# = label#(sb#, "0°", 490, 180)
label_fontsize#(rot1#, 16)
label_fontcolor#(rot1#, "#e74c3c")
label_rotation#(rot1#, 0)
LET rot2# = label#(sb#, "15°", 540, 180)
label_fontsize#(rot2#, 16)
label_fontcolor#(rot2#, "#f39c12")
label_rotation#(rot2#, 15)
LET rot3# = label#(sb#, "30°", 600, 180)
label_fontsize#(rot3#, 16)
label_fontcolor#(rot3#, "#f1c40f")
label_rotation#(rot3#, 30)
LET rot4# = label#(sb#, "45°", 660, 180)
label_fontsize#(rot4#, 16)
label_fontcolor#(rot4#, "#2ecc71")
label_rotation#(rot4#, 45)
LET rot5# = label#(sb#, "60°", 720, 180)
label_fontsize#(rot5#, 16)
label_fontcolor#(rot5#, "#3498db")
label_rotation#(rot5#, 60)
LET rot6# = label#(sb#, "90°", 780, 190)
label_fontsize#(rot6#, 16)
label_fontcolor#(rot6#, "#9b59b6")
label_rotation#(rot6#, 90)
PRINTLN "Section 6: Rotated labels created"
' ============================================================================
' Section 7: Opacity Levels
' ============================================================================
LET sec7Bg# = rectangle#(sb#, 455, 250, 420, 80)
rectangle_fill#(sec7Bg#, "#2c3e50")
rectangle_stroke#(sec7Bg#, "#dee2e6")
rectangle_corners#(sec7Bg#, 5, 5)
LET sec7Title# = label#(sb#, "Opacity Levels", 465, 255)
label_fontsize#(sec7Title#, 12)
label_fontcolor#(sec7Title#, "#adb5bd")
LET op1# = label#(sb#, "100%", 475, 285)
label_fontsize#(op1#, 18)
label_fontcolor#(op1#, "white")
label_opacity#(op1#, 1.0)
LET op2# = label#(sb#, "80%", 535, 285)
label_fontsize#(op2#, 18)
label_fontcolor#(op2#, "white")
label_opacity#(op2#, 0.8)
LET op3# = label#(sb#, "60%", 590, 285)
label_fontsize#(op3#, 18)
label_fontcolor#(op3#, "white")
label_opacity#(op3#, 0.6)
LET op4# = label#(sb#, "40%", 645, 285)
label_fontsize#(op4#, 18)
label_fontcolor#(op4#, "white")
label_opacity#(op4#, 0.4)
LET op5# = label#(sb#, "20%", 700, 285)
label_fontsize#(op5#, 18)
label_fontcolor#(op5#, "white")
label_opacity#(op5#, 0.2)
PRINTLN "Section 7: Opacity levels created"
' ============================================================================
' Section 8: Labeled Buttons (Rectangle + Label)
' ============================================================================
LET sec8Bg# = rectangle#(sb#, 455, 340, 420, 140)
rectangle_fill#(sec8Bg#, "#f8f9fa")
rectangle_stroke#(sec8Bg#, "#dee2e6")
rectangle_corners#(sec8Bg#, 5, 5)
LET sec8Title# = label#(sb#, "Labeled Buttons (Rectangle + Label)", 465, 345)
label_fontsize#(sec8Title#, 12)
label_fontcolor#(sec8Title#, "#6c757d")
' Button 1 - Primary
LET btn1Bg# = rectangle#(sb#, 475, 375, 120, 40)
rectangle_fill#(btn1Bg#, "#3498db")
rectangle_corners#(btn1Bg#, 5, 5)
rectangle_tag#(btn1Bg#, 1)
rectangle_onclick#(btn1Bg#, "OnButtonClick")
rectangle_onmouseenter#(btn1Bg#, "OnBtnEnter")
rectangle_onmouseleave#(btn1Bg#, "OnBtnLeave")
LET btn1Lbl# = label#(sb#, "Primary", 475, 375, 120, 40)
label_autosize#(btn1Lbl#, 0)
label_textalign#(btn1Lbl#, 0)
label_vertalign#(btn1Lbl#, 0)
label_fontcolor#(btn1Lbl#, "white")
label_fontsize#(btn1Lbl#, 14)
label_hittest#(btn1Lbl#, 0)
' Button 2 - Success
LET btn2Bg# = rectangle#(sb#, 605, 375, 120, 40)
rectangle_fill#(btn2Bg#, "#27ae60")
rectangle_corners#(btn2Bg#, 5, 5)
rectangle_tag#(btn2Bg#, 2)
rectangle_onclick#(btn2Bg#, "OnButtonClick")
rectangle_onmouseenter#(btn2Bg#, "OnBtnEnter")
rectangle_onmouseleave#(btn2Bg#, "OnBtnLeave")
LET btn2Lbl# = label#(sb#, "Success", 605, 375, 120, 40)
label_autosize#(btn2Lbl#, 0)
label_textalign#(btn2Lbl#, 0)
label_vertalign#(btn2Lbl#, 0)
label_fontcolor#(btn2Lbl#, "white")
label_fontsize#(btn2Lbl#, 14)
label_hittest#(btn2Lbl#, 0)
' Button 3 - Danger
LET btn3Bg# = rectangle#(sb#, 735, 375, 120, 40)
rectangle_fill#(btn3Bg#, "#e74c3c")
rectangle_corners#(btn3Bg#, 5, 5)
rectangle_tag#(btn3Bg#, 3)
rectangle_onclick#(btn3Bg#, "OnButtonClick")
rectangle_onmouseenter#(btn3Bg#, "OnBtnEnter")
rectangle_onmouseleave#(btn3Bg#, "OnBtnLeave")
LET btn3Lbl# = label#(sb#, "Danger", 735, 375, 120, 40)
label_autosize#(btn3Lbl#, 0)
label_textalign#(btn3Lbl#, 0)
label_vertalign#(btn3Lbl#, 0)
label_fontcolor#(btn3Lbl#, "white")
label_fontsize#(btn3Lbl#, 14)
label_hittest#(btn3Lbl#, 0)
' Button 4 - Outlined
LET btn4Bg# = rectangle#(sb#, 475, 425, 120, 40)
rectangle_fill#(btn4Bg#, "white")
rectangle_stroke#(btn4Bg#, "#3498db")
rectangle_strokethickness#(btn4Bg#, 2)
rectangle_corners#(btn4Bg#, 5, 5)
rectangle_tag#(btn4Bg#, 4)
rectangle_onclick#(btn4Bg#, "OnButtonClick")
LET btn4Lbl# = label#(sb#, "Outlined", 475, 425, 120, 40)
label_autosize#(btn4Lbl#, 0)
label_textalign#(btn4Lbl#, 0)
label_vertalign#(btn4Lbl#, 0)
label_fontcolor#(btn4Lbl#, "#3498db")
label_fontsize#(btn4Lbl#, 14)
label_hittest#(btn4Lbl#, 0)
' Click counter
LET clickCount = 0
LET counterLabel# = label#(sb#, "Clicks: 0", 620, 435)
label_fontsize#(counterLabel#, 16)
label_fontcolor#(counterLabel#, "#2c3e50")
PRINTLN "Section 8: Labeled buttons created"
' ============================================================================
' Section 9: Dynamic Counter
' ============================================================================
LET sec9Bg# = rectangle#(sb#, 15, 490, 860, 90)
rectangle_fill#(sec9Bg#, "#f8f9fa")
rectangle_stroke#(sec9Bg#, "#dee2e6")
rectangle_corners#(sec9Bg#, 5, 5)
LET sec9Title# = label#(sb#, "Dynamic Counter (Watch the numbers animate!)", 25, 495)
label_fontsize#(sec9Title#, 12)
label_fontcolor#(sec9Title#, "#6c757d")
LET counterDisplay# = label#(sb#, "0", 400, 520)
label_fontsize#(counterDisplay#, 48)
label_fontcolor#(counterDisplay#, "#2c3e50")
label_bold#(counterDisplay#, 1)
PRINTLN "Section 9: Dynamic counter created"
' ============================================================================
' Footer
' ============================================================================
LET footerBg# = rectangle#(sb#, 15, 590, 860, 60)
rectangle_fill#(footerBg#, "#2c3e50")
rectangle_corners#(footerBg#, 5, 5)
LET footerLabel# = label#(sb#, "LabelLib Visual Demo - Plan9Basic", 15, 590, 860, 30)
label_autosize#(footerLabel#, 0)
label_textalign#(footerLabel#, 0)
label_vertalign#(footerLabel#, 0)
label_fontcolor#(footerLabel#, "white")
label_fontsize#(footerLabel#, 16)
LET footerSub# = label#(sb#, "82 functions for complete text label management", 15, 620, 860, 25)
label_autosize#(footerSub#, 0)
label_textalign#(footerSub#, 0)
label_vertalign#(footerSub#, 0)
label_fontcolor#(footerSub#, "#adb5bd")
label_fontsize#(footerSub#, 12)
PRINTLN ""
PRINTLN "All sections created successfully!"
PRINTLN "Demo is now interactive - try clicking the links and buttons!"
' ============================================================================
' Show the form
' ============================================================================
form_show(frm#)
' ============================================================================
' Animate the counter
' ============================================================================
FOR i = 0 TO 100
  label_text#(counterDisplay#, stri$(i))
  pause(0.03)
NEXT
PRINTLN "Counter animation complete!"
' ============================================================================
' Event Handlers
' ============================================================================
' Link colors
LET link1Color$ = "#3498db"
LET link2Color$ = "#e74c3c"
LET link3Color$ = "#27ae60"
LET link1Hover$ = "#2980b9"
LET link2Hover$ = "#c0392b"
LET link3Hover$ = "#1e8449"
FUNCTION OnLinkClick(sender#) LOCAL tag, msg$
  tag = label_tag(sender#)
  IF tag = 1 THEN
    msg$ = "You clicked BLUE link!"
    label_fontcolor#(resultLabel#, "#3498db")
  ENDIF
  IF tag = 2 THEN
    msg$ = "You clicked RED link!"
    label_fontcolor#(resultLabel#, "#e74c3c")
  ENDIF
  IF tag = 3 THEN
    msg$ = "You clicked GREEN link!"
    label_fontcolor#(resultLabel#, "#27ae60")
  ENDIF
  label_text#(resultLabel#, msg$)
  PRINTLN msg$
ENDFUNCTION
FUNCTION OnLinkEnter(sender#) LOCAL tag
  tag = label_tag(sender#)
  IF tag = 1 THEN
    label_fontcolor#(sender#, link1Hover$)
  ENDIF
  IF tag = 2 THEN
    label_fontcolor#(sender#, link2Hover$)
  ENDIF
  IF tag = 3 THEN
    label_fontcolor#(sender#, link3Hover$)
  ENDIF
ENDFUNCTION
FUNCTION OnLinkLeave(sender#) LOCAL tag
  tag = label_tag(sender#)
  IF tag = 1 THEN
    label_fontcolor#(sender#, link1Color$)
  ENDIF
  IF tag = 2 THEN
    label_fontcolor#(sender#, link2Color$)
  ENDIF
  IF tag = 3 THEN
    label_fontcolor#(sender#, link3Color$)
  ENDIF
ENDFUNCTION
' Button colors
LET btn1Color$ = "#3498db"
LET btn2Color$ = "#27ae60"
LET btn3Color$ = "#e74c3c"
LET btn1Hover$ = "#2980b9"
LET btn2Hover$ = "#1e8449"
LET btn3Hover$ = "#c0392b"
FUNCTION OnButtonClick(sender#) LOCAL tag
  tag = rectangle_tag(sender#)
  clickCount = clickCount + 1
  label_text#(counterLabel#, "Clicks: " + stri$(clickCount))
  PRINTLN "Button " + stri$(tag) + " clicked! Total: " + stri$(clickCount)
ENDFUNCTION
FUNCTION OnBtnEnter(sender#) LOCAL tag
  tag = rectangle_tag(sender#)
  IF tag = 1 THEN
    rectangle_fill#(sender#, btn1Hover$)
  ENDIF
  IF tag = 2 THEN
    rectangle_fill#(sender#, btn2Hover$)
  ENDIF
  IF tag = 3 THEN
    rectangle_fill#(sender#, btn3Hover$)
  ENDIF
ENDFUNCTION
FUNCTION OnBtnLeave(sender#) LOCAL tag
  tag = rectangle_tag(sender#)
  IF tag = 1 THEN
    rectangle_fill#(sender#, btn1Color$)
  ENDIF
  IF tag = 2 THEN
    rectangle_fill#(sender#, btn2Color$)
  ENDIF
  IF tag = 3 THEN
    rectangle_fill#(sender#, btn3Color$)
  ENDIF
ENDFUNCTION
