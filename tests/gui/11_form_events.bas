rem ---------------------------------------------------------------
rem Events reach their handlers.
rem
rem Phase 2.2 gave every GUI library one way of finding its engine:
rem walk up the parent chain to the form that owns one. Two things
rem went wrong with that, and neither was visible from BASIC because
rem a dispatcher whose engine is nil exits on its first line and
rem reports nothing.
rem
rem   1. A form is the ROOT of that chain. EngineOf had nothing to
rem      walk up to, so every form event was dead -- onshow, onclose,
rem      onkeydown, in all nine shipped games.
rem
rem   2. Seven control libraries called EngineOf BEFORE assigning the
rem      parent, so the walk started from an orphan and found nothing
rem      either: label, layout, panel, progressbar, rectangle and
rem      trackbar. rectangle_onmousedown was among them, which is why
rem      flappy_bird did not answer a tap any more than a key.
rem
rem tools/check-callbacks.py proves the shapes agree, and they did.
rem Delivery was never asked about, which is what this file asks.
rem
rem The events used here are the ones that fire without any input:
rem form_show, and a property change on a control. onresize is NOT
rem one of them -- a programmatic resize does not raise it -- which
rem cost a wrong conclusion before a working baseline was found.
rem ---------------------------------------------------------------

test_case("events/a form reaches its handler")
let shown = 0
let sameForm = 0
let f# = form#("event probe", 300, 200)
form_onshow#(f#, "OnShown")
form_show(f#)
assert_eq(shown, 1, "form_show reached OnShow")
assert_eq(sameForm, 1, "and handed the handler the form it belongs to")

test_case("events/clearing the name unwires it")
let shown = 0
form_onshow#(f#, "")
form_show(f#)
assert_eq(shown, 0, "an empty name stops the event")

test_case("events/a control reaches its handler")
rem edit and checkbox were never broken; trackbar was, and the three
rem are here together so the file says which side of the line each is
rem on rather than only that things work.
let hitEdit = 0
let hitCheck = 0
let e# = edit#(f#, 0, 0, 100, 24)
let c# = checkbox#(f#, 0, 40, 100, 24)
edit_onchange#(e#, "OnEdit")
checkbox_onchange#(c#, "OnCheck")
edit_text#(e#, "abc")
checkbox_ischecked#(c#, 1)
assert_eq(hitEdit, 1, "edit_onchange fired")
assert_eq(hitCheck, 1, "checkbox_onchange fired")

rem The trackbar was the one that stayed silent after the first repair, and
rem the reason was the repair itself: an automated move put its engine
rem lookup inside the else branch, so it ran only when the parent was not a
rem form. Both of its events answer now, and asserting both is the point --
rem ontracking is what a programmatic write raises first, and onchange
rem follows through the after-change path.
let hitTrack = 0
let hitTrackChange = 0
let t# = trackbar#(f#, 0, 80, 100, 24)
trackbar_ontracking#(t#, "OnTrack")
trackbar_onchange#(t#, "OnTrackChange")
trackbar_value#(t#, 42)
assert_eq(trackbar_value(t#), 42, "the value moved")
assert_eq(hitTrack, 1, "trackbar_ontracking fired")
assert_eq(hitTrackChange, 1, "and trackbar_onchange followed")

function OnShown(sender#)
  let shown = shown + 1
  if PntToNum(sender#) = PntToNum(f#) then sameForm = 1
end function

function OnEdit(sender#)
  let hitEdit = 1
end function

function OnCheck(sender#)
  let hitCheck = 1
end function

function OnTrack(sender#)
  let hitTrack = 1
end function

function OnTrackChange(sender#)
  let hitTrackChange = 1
end function
