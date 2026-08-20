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
rem trackbar_onchange is deliberately NOT asserted. Its value does move --
rem 0 to 42, inside a 0..100 range -- and the handler still does not run,
rem and from BASIC there is no way to tell a nil engine from an event FMX
rem never raises: CallbackCore exits on either without a word. Asserting
rem it would be claiming an answer this cannot obtain. Left as an open
rem question in ANALYSIS 45 rather than as a green assertion.

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
