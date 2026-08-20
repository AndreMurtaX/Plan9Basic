rem ---------------------------------------------------------------
rem The focus family across every control that has one, and EditLib's
rem editing surface -- the selection, the clipboard, the margins.
rem
rem Focus belongs to the form rather than to the desktop, so a control
rem on a form that was never shown can still be given it. That is what
rem makes this assertable here at all, and it was found by asserting
rem the opposite in 15_stringgrid.bas.
rem
rem The clipboard verbs reach the system clipboard, so what comes back
rem belongs to the machine. They are exercised for reachability; what
rem is asserted about the text is only what cut and delete do to it.
rem ---------------------------------------------------------------

f# = form#("focus host", 500, 400)

test_case("controls/parents")
rem Six more controls that had no test asking who their parent is. The
rem engine finds the interpreter by walking this chain, so a control
rem answering the wrong one is a control whose events never fire.
bt# = button#(f#, 10, 10, 80, 30)
cb# = checkbox#(f#, 100, 10, 80, 30)
rb# = radiobutton#(f#, 190, 10, 80, 30)
sw# = switch#(f#, 280, 10, 60, 30)
tb# = trackbar#(f#, 10, 50, 120, 30)
sp# = speedbutton#(f#, 140, 50, 80, 30)
lb# = label#(f#, "caption", 230, 50, 80, 30)
pb# = progressbar#(f#, 320, 50, 120, 20)
ed# = edit#(f#, 10, 90, 200, 30)

assert_eq(pnttonum(button_parent#(bt#)), pnttonum(f#), "a button knows its form")
assert_eq(pnttonum(checkbox_parent#(cb#)), pnttonum(f#), "a checkbox does")
assert_eq(pnttonum(radiobutton_parent#(rb#)), pnttonum(f#), "a radio button does")
assert_eq(pnttonum(switch_parent#(sw#)), pnttonum(f#), "a switch does")
assert_eq(pnttonum(trackbar_parent#(tb#)), pnttonum(f#), "a track bar does")
assert_eq(pnttonum(speedbutton_parent#(sp#)), pnttonum(f#), "a speed button does")
assert_eq(pnttonum(label_parent#(lb#)), pnttonum(f#), "a label does")
assert_eq(pnttonum(progressbar_parent#(pb#)), pnttonum(f#), "a progress bar does")
assert_eq(pnttonum(edit_parent#(ed#)), pnttonum(f#), "and an edit does")

test_case("controls/focus")
rem setfocus gives it, isfocused answers, resetfocus takes it away.
rem Only one control can hold it at a time, which is what the sequence
rem below is really testing.
button_setfocus#(bt#)
assert_true(button_isfocused(bt#), "a button can be given the focus")

checkbox_setfocus#(cb#)
assert_true(checkbox_isfocused(cb#), "and a checkbox")
assert_false(button_isfocused(bt#), "which takes it off the button")

radiobutton_setfocus#(rb#)
assert_true(radiobutton_isfocused(rb#), "a radio button can hold it")
switch_setfocus#(sw#)
assert_true(switch_isfocused(sw#), "a switch can")
trackbar_setfocus#(tb#)
assert_true(trackbar_isfocused(tb#), "a track bar can")
edit_setfocus#(ed#)
assert_true(edit_isfocused(ed#), "and an edit can")

edit_resetfocus#(ed#)
assert_false(edit_isfocused(ed#), "resetfocus takes it away again")

button_resetfocus#(bt#)
checkbox_resetfocus#(cb#)
radiobutton_resetfocus#(rb#)
switch_resetfocus#(sw#)
trackbar_resetfocus#(tb#)
combobox_setfocus#(combobox#(f#, 230, 90, 120, 30))
combobox_resetfocus#(combobox#(f#, 360, 90, 120, 30))
assert_eq(button_error(), 0, "and every control has the same three")

test_case("switch/toggle")
rem A switch is the one control whose whole job is two states, and
rem toggle is the verb that swaps whichever it is in.
switch_ischecked#(sw#, 0)
assert_false(switch_ischecked(sw#), "a switch starts where it was put")
switch_toggle#(sw#)
assert_true(switch_ischecked(sw#), "switch_toggle# turns it on")
switch_toggle#(sw#)
assert_false(switch_ischecked(sw#), "and off again")

test_case("edit/selection")
edit_text#(ed#, "hello world")
assert_eq(edit_text$(ed#), "hello world", "the edit holds its text")

edit_selstart#(ed#, 0)
edit_sellength#(ed#, 5)
assert_eq(edit_seltext$(ed#), "hello", "edit_seltext$ answers what is selected")

edit_selectall#(ed#)
assert_eq(edit_sellength(ed#), 11, "edit_selectall# takes the lot")
edit_clearselection#(ed#)
assert_eq(edit_sellength(ed#), 0, "edit_clearselection# lets it go")

test_case("edit/caret")
rem gotobegin and gotoend move the caret, which on an unshown control
rem is the selection start. Unlike a memo, an edit answers here.
edit_gotoend#(ed#)
edit_gotobegin#(ed#)
assert_eq(edit_selstart(ed#), 0, "edit_gotobegin# puts the caret at the start")

test_case("edit/clipboard-and-clearing")
rem copy, cut and paste reach the desktop, so only what cut does to the
rem text is asserted -- the clipboard's contents are the machine's.
edit_clearerror()
edit_text#(ed#, "abcdef")
edit_selstart#(ed#, 0)
edit_sellength#(ed#, 3)
edit_copy#(ed#)
assert_eq(edit_text$(ed#), "abcdef", "copy leaves the text alone")

edit_selstart#(ed#, 0)
edit_sellength#(ed#, 3)
edit_cut#(ed#)
assert_eq(edit_text$(ed#), "def", "cut takes the selection out of it")

edit_paste#(ed#)
assert_eq(edit_error(), 0, "paste is reachable")

rem edit_clear# does NOT empty the edit. It deletes the SELECTION --
rem the reference says "Delete the selected text" and that is exactly
rem what it does -- while edit_clearselection# is the one that only
rem deselects. Two inviting names for two different things, and the
rem inviting reading of the first is the wrong one.
edit_text#(ed#, "abcdef")
edit_selstart#(ed#, 0)
edit_sellength#(ed#, 3)
edit_clear#(ed#)
assert_eq(edit_text$(ed#), "def", "edit_clear# removes what was selected, not everything")

edit_selectall#(ed#)
edit_clearselection#(ed#)
assert_eq(edit_text$(ed#), "def", "and edit_clearselection# removes nothing at all")
assert_eq(edit_sellength(ed#), 0, "it only lets the selection go")

test_case("edit/margins")
rem One number for all four sides, or four for them separately -- the
rem same pair as a container's padding.
edit_clearerror()
edit_margin#(ed#, 4)
edit_margins#(ed#, 1, 2, 3, 4)
assert_eq(edit_marginleft(ed#), 1, "edit_margins# sets the left")
assert_eq(edit_margintop(ed#), 2, "and the top")
assert_eq(edit_error(), 0, "with nothing to report")

test_case("image/saving")
rem AN EMPTY IMAGE SAVES, AND REPORTS SUCCESS. There is no check for
rem an empty bitmap: the bitmap saves itself, and a 0x0 one produces a
rem twelve-byte file. A program that trusts the return value believes
rem it wrote a picture, and finds out later that the gallery is full of
rem blanks. The behaviour is defensible -- the save did what it was
rem asked -- and it is the return value that misleads.
p$ = "bin/p9b_img_save.png"
file_delete(p$)
im# = image#(f#, 360, 130, 60, 60)
assert_true(image_isempty(im#), "a new image holds no bitmap")

image_clearerror()
assert_true(image_save(im#, p$), "saving an empty image reports success")
assert_true(file_exists(p$), "and writes a file")
if file_getsize(p$) < 100 then tiny = 1
assert_true(tiny, "which is a few bytes of nothing")

image_clearerror()
image_save#(im#, p$)
assert_eq(image_error(), 0, "the chaining form is just as content")
file_delete(p$)

form_free(f#)
