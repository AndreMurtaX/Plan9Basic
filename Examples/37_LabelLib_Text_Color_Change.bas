' Quick test: Dynamic label color change
LET frm# = form#("Color Change Test", 400, 300)
LET lbl# = label#(frm#, "Click me to change color!", 50, 50)
label_fontsize#(lbl#, 24)
label_fontcolor#(lbl#, "red")
label_hittest#(lbl#, 1)
label_onclick#(lbl#, "OnChangeColor")
LET colorIndex = 0
form_show(frm#)
FUNCTION OnChangeColor(sender#)
  colorIndex = colorIndex + 1
  IF colorIndex > 5 THEN
    colorIndex = 0
  END IF
  IF colorIndex = 0 THEN
    label_fontcolor#(sender#, "red")
  END IF
  IF colorIndex = 1 THEN
    label_fontcolor#(sender#, "orange")
  END IF
  IF colorIndex = 2 THEN
    label_fontcolor#(sender#, "green")
  END IF
  IF colorIndex = 3 THEN
    label_fontcolor#(sender#, "blue")
  END IF
  IF colorIndex = 4 THEN
    label_fontcolor#(sender#, "purple")
  END IF
  IF colorIndex = 5 THEN
    label_fontcolor#(sender#, "#e91e63")
  END IF
  PRINTLN "Color changed to index: " + stri$(colorIndex)
END FUNCTION
