' ============================================================================
' BlindTransitionEffect Test Applet
' Tests the BlindTransitionEffectLib v1.3.0 with Target property
' ============================================================================

' Module-level variables
let frm# = Pointer#(0)
let img# = Pointer#(0)
let fx# = Pointer#(0)
let lblProgress# = Pointer#(0)
let btn0# = Pointer#(0)
let btn25# = Pointer#(0)
let btn50# = Pointer#(0)
let btn75# = Pointer#(0)
let btn100# = Pointer#(0)

' ----------------------------------------------------------------------------
' Main Program
' ----------------------------------------------------------------------------

' Create main form
frm# = form#("Blind Transition Effect Test", 500, 450)

' Create source image
img# = image#(frm#, 20, 20, 300, 200)
image_load#(img#, "https://picsum.photos/seed/source123/300/200")

' Create the blind transition effect on the image
fx# = blindtrans#(img#)

' Load target image into the effect (CRITICAL!)
blindtrans_loadtarget#(fx#, "https://picsum.photos/seed/target456/300/200")

' Set initial progress to 0 (show source)
blindtrans_progress#(fx#, 0)

' Set number of blinds
blindtrans_numblinds#(fx#, 10)

' Create progress label
lblProgress# = label#(frm#, "Progress: 0%", 340, 20)

' Create title label
label#(frm#, "Click buttons to change progress:", 20, 240)

' Create progress buttons and set callbacks
btn0# = button#(frm#, "0%", 20, 270, 80, 35)
button_onclick#(btn0#, "OnClick0")

btn25# = button#(frm#, "25%", 110, 270, 80, 35)
button_onclick#(btn25#, "OnClick25")

btn50# = button#(frm#, "50%", 200, 270, 80, 35)
button_onclick#(btn50#, "OnClick50")

btn75# = button#(frm#, "75%", 290, 270, 80, 35)
button_onclick#(btn75#, "OnClick75")

btn100# = button#(frm#, "100%", 380, 270, 80, 35)
button_onclick#(btn100#, "OnClick100")

' Create blind count label
label#(frm#, "Number of Blinds:", 20, 320)

' Create blind count buttons
let btnB5# = button#(frm#, "5", 20, 345, 60, 35)
button_onclick#(btnB5#, "OnBlinds5")

let btnB10# = button#(frm#, "10", 90, 345, 60, 35)
button_onclick#(btnB10#, "OnBlinds10")

let btnB20# = button#(frm#, "20", 160, 345, 60, 35)
button_onclick#(btnB20#, "OnBlinds20")

' Info labels
label#(frm#, "Source: picsum/source123", 20, 400)
label#(frm#, "Target: picsum/target456", 20, 420)

' Show the form
form_show(frm#)
end

' ----------------------------------------------------------------------------
' Progress Button Callbacks
' ----------------------------------------------------------------------------

function OnClick0(sender#)
  blindtrans_progress#(fx#, 0)
  label_text#(lblProgress#, "Progress: 0%")
endfunction

function OnClick25(sender#)
  blindtrans_progress#(fx#, 0.25)
  label_text#(lblProgress#, "Progress: 25%")
endfunction

function OnClick50(sender#)
  blindtrans_progress#(fx#, 0.5)
  label_text#(lblProgress#, "Progress: 50%")
endfunction

function OnClick75(sender#)
  blindtrans_progress#(fx#, 0.75)
  label_text#(lblProgress#, "Progress: 75%")
endfunction

function OnClick100(sender#)
  blindtrans_progress#(fx#, 1.0)
  label_text#(lblProgress#, "Progress: 100%")
endfunction

' ----------------------------------------------------------------------------
' Blinds Count Callbacks
' ----------------------------------------------------------------------------

function OnBlinds5(sender#)
  blindtrans_numblinds#(fx#, 5)
endfunction

function OnBlinds10(sender#)
  blindtrans_numblinds#(fx#, 10)
endfunction

function OnBlinds20(sender#)
  blindtrans_numblinds#(fx#, 20)
endfunction
