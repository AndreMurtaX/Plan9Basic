' MonochromeEffect Diagnostic Test
' This test verifies if monochrome effect works on different control types

let frm# = Pointer#(0)
let img# = Pointer#(0)
let rect# = Pointer#(0)
let btn# = Pointer#(0)
let mono1# = Pointer#(0)
let mono2# = Pointer#(0)
let mono3# = Pointer#(0)

frm# = form#("Monochrome Effect Test", 600, 450)

' ============================================
' TEST 1: Image with loaded picture (SHOULD WORK)
' ============================================
let lbl1# = label#(frm#, "TImage (should work):", 30, 20)
img# = image#(frm#)
image_bounds#(img#, 30, 50, 150, 100)
' Load a web image for testing
image_loadurl#(img#, "https://picsum.photos/150/100")

' Apply monochrome to image
mono1# = monochrome#(img#)
let err1 = monochrome_error()
let lbl1err# = label#(frm#, "Error: " + str$(err1), 30, 160)

' ============================================
' TEST 2: Rectangle with solid fill (MAY WORK)
' ============================================
let lbl2# = label#(frm#, "TRectangle (may work):", 220, 20)
rect# = rectangle#(frm#)
rectangle_bounds#(rect#, 220, 50, 150, 100)
rectangle_fill#(rect#, "Orange")
rectangle_stroke#(rect#, "Blue", 3)

' Apply monochrome to rectangle
mono2# = monochrome#(rect#)
let err2 = monochrome_error()
let lbl2err# = label#(frm#, "Error: " + str$(err2), 220, 160)

' ============================================
' TEST 3: Button (styled control - MAY NOT WORK)
' ============================================
let lbl3# = label#(frm#, "TButton (styled - may fail):", 410, 20)
btn# = button#(frm#, "Test Button")
button_bounds#(btn#, 410, 50, 150, 100)

' Apply monochrome to button
mono3# = monochrome#(btn#)
let err3 = monochrome_error()
let lbl3err# = label#(frm#, "Error: " + str$(err3), 410, 160)

' ============================================
' Toggle buttons to enable/disable effects
' ============================================
let tog1# = button#(frm#, "Toggle Image")
button_bounds#(tog1#, 30, 200, 150, 30)
button_onclick#(tog1#, "ToggleImg")

let tog2# = button#(frm#, "Toggle Rectangle")
button_bounds#(tog2#, 220, 200, 150, 30)
button_onclick#(tog2#, "ToggleRect")

let tog3# = button#(frm#, "Toggle Button")
button_bounds#(tog3#, 410, 200, 150, 30)
button_onclick#(tog3#, "ToggleBtn")

' Status labels
let stat1# = label#(frm#, "Enabled: 1", 30, 240)
let stat2# = label#(frm#, "Enabled: 1", 220, 240)
let stat3# = label#(frm#, "Enabled: 1", 410, 240)

' Instructions
let info# = label#(frm#, "Compare the three controls. Image should be grayscale.", 30, 300)
let info2# = label#(frm#, "Rectangle might be grayscale. Button probably won't show effect.", 30, 320)
let info3# = label#(frm#, "TImageFXEffect effects work on textures/bitmaps, not styled controls.", 30, 340)

form_show(frm#)

function ToggleImg(sender#) local en
  en = monochrome_enabled(mono1#)
  if en = 1 then
    monochrome_enabled#(mono1#, 0)
    label_text#(stat1#, "Enabled: 0")
  else
    monochrome_enabled#(mono1#, 1)
    label_text#(stat1#, "Enabled: 1")
  endif
endfunction

function ToggleRect(sender#) local en
  en = monochrome_enabled(mono2#)
  if en = 1 then
    monochrome_enabled#(mono2#, 0)
    label_text#(stat2#, "Enabled: 0")
  else
    monochrome_enabled#(mono2#, 1)
    label_text#(stat2#, "Enabled: 1")
  endif
endfunction

function ToggleBtn(sender#) local en
  en = monochrome_enabled(mono3#)
  if en = 1 then
    monochrome_enabled#(mono3#, 0)
    label_text#(stat3#, "Enabled: 0")
  else
    monochrome_enabled#(mono3#, 1)
    label_text#(stat3#, "Enabled: 1")
  endif
endfunction
