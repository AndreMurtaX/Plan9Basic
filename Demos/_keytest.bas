' ============================================================
'  Minimal keyboard test.
'
'  Run it, click once on the window, then press keys.
'  The counter moves for every key the form receives.
'
'  Everything from the form to the BASIC handler is now covered
'  by tests/gui/11_form_events.bas, which runs headlessly. What
'  no test here can reach is the last step: a real key, from a
'  real keyboard, into a real window. That is what this is for.
' ============================================================

let hits = 0
let frm# = form#("Key test", 460, 220)
let lbl# = label#(frm#, "Press a key. Count: 0", 20, 40)
label_autosize#(lbl#, 0)
label_fontsize#(lbl#, 20)
label_size#(lbl#, 420, 40)

let lbl2# = label#(frm#, "last key code: -", 20, 100)
label_autosize#(lbl2#, 0)
label_fontsize#(lbl2#, 16)
label_size#(lbl2#, 420, 30)

let lbl3# = label#(frm#, "click here too: mouse count 0", 20, 150)
label_autosize#(lbl3#, 0)
label_fontsize#(lbl3#, 16)
label_size#(lbl3#, 420, 30)

' A transparent rectangle over the whole window, which is how
' flappy_bird takes a tap. It was dead for the same reason the
' keyboard was, so it is worth watching in the same run.
let mice = 0
let touch# = rectangle#(frm#, 0, 0, 460, 220)
rectangle_fill#(touch#, "#00000000")
rectangle_strokenone#(touch#)
rectangle_hittest#(touch#, 1)
rectangle_onmousedown#(touch#, "OnTouch")

form_onkeydown#(frm#, "OnKey")
form_show(frm#)

function OnKey(sender#, keyCode, keyChar$, shiftState$)
  let hits = hits + 1
  label_text#(lbl#, "Press a key. Count: " + stri$(hits))
  label_text#(lbl2#, "last key code: " + stri$(keyCode) + "  char: [" + keyChar$ + "]")
end function

function OnTouch(sender#, btn, mx, my, shift$)
  let mice = mice + 1
  label_text#(lbl3#, "click here too: mouse count " + stri$(mice))
end function
