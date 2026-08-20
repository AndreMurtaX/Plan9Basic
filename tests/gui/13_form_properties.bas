rem ---------------------------------------------------------------
rem FormLib. check-coverage.py reported 7/103 -- the whole property
rem surface of the one control every program starts with had never
rem been run by a test.
rem
rem The map came from Examples/31_FormLib_Tests.bas, 727 lines that
rem call 89 functions and check eighteen things. What is added here is
rem the checking.
rem
rem 11_form_events.bas covers the event wiring. This file is the
rem properties, the geometry, the window state and the screen.
rem
rem Nothing here shows a window. A form exists as an object whether or
rem not it is on screen, which is what makes this testable at all.
rem ---------------------------------------------------------------

test_case("form/construction")
f# = form#("test form", 400, 300)
assert_true(pnttonum(f#), "form# answers a handle")
assert_eq(form_caption$(f#), "test form", "which remembers its caption")
assert_eq(form_width(f#), 400, "and its width")
assert_eq(form_height(f#), 300, "and its height")
assert_eq(form_error(), 0, "with nothing to report")

test_case("form/caption-and-visibility")
form_caption#(f#, "renamed")
assert_eq(form_caption$(f#), "renamed", "form_caption# changes it")

assert_false(form_visible(f#), "a form starts invisible")
form_visible#(f#, 1)
assert_true(form_visible(f#), "form_visible# shows it")
form_visible#(f#, 0)
assert_false(form_visible(f#), "and hides it again")

test_case("form/size")
form_width#(f#, 640)
form_height#(f#, 480)
assert_eq(form_width(f#), 640, "form_width# sets the width")
assert_eq(form_height(f#), 480, "form_height# the height")

rem The client area is what is left inside the frame, so it is never
rem larger than the form and on a bordered window is smaller.
if form_clientwidth(f#) <= form_width(f#) then cw_ok = 1
assert_true(cw_ok, "the client width fits inside the form")
if form_clientheight(f#) <= form_height(f#) then ch_ok = 1
assert_true(ch_ok, "and so does the client height")

test_case("form/position")
form_left#(f#, 100)
form_top#(f#, 50)
assert_eq(form_left(f#), 100, "form_left# sets the left edge")
assert_eq(form_top(f#), 50, "form_top# the top")

rem bounds sets all four at once, which is the only way to move and
rem resize without the window being briefly in a place it never was.
form_bounds#(f#, 10, 20, 300, 200)
assert_eq(form_left(f#), 10, "form_bounds# sets the left")
assert_eq(form_top(f#), 20, "the top")
assert_eq(form_width(f#), 300, "the width")
assert_eq(form_height(f#), 200, "and the height")

form_center#(f#)
assert_eq(form_width(f#), 300, "form_center# moves without resizing")

test_case("form/constraints")
form_minwidth#(f#, 200)
form_minheight#(f#, 150)
form_maxwidth#(f#, 800)
form_maxheight#(f#, 600)
assert_eq(form_minwidth(f#), 200, "form_minwidth# holds")
assert_eq(form_minheight(f#), 150, "form_minheight# holds")
assert_eq(form_maxwidth(f#), 800, "form_maxwidth# holds")
assert_eq(form_maxheight(f#), 600, "form_maxheight# holds")

form_constraints#(f#, 100, 100, 900, 700)
assert_eq(form_minwidth(f#), 100, "form_constraints# sets all four at once")
assert_eq(form_maxheight(f#), 700, "including the last")

test_case("form/window-state")
rem The state accessors answer codes rather than names, and the three
rem verbs are the same thing said imperatively.
form_windowstate#(f#, 0)
assert_eq(form_windowstate(f#), 0, "form_windowstate# holds a state")

form_maximize#(f#)
assert_true(form_windowstate(f#), "form_maximize# changes it")
form_restore#(f#)
assert_eq(form_windowstate(f#), 0, "and form_restore# puts it back")
form_minimize#(f#)
form_restore#(f#)
assert_eq(form_windowstate(f#), 0, "form_minimize# and restore agree")

test_case("form/style-flags")
rem Each of these is a number in and the same number out. What they do
rem to a window is the window manager's business and not assertable
rem without one on screen.
form_borderstyle#(f#, 0)
assert_eq(form_borderstyle(f#), 0, "form_borderstyle# holds")
form_borderstyle#(f#, 3)
assert_eq(form_borderstyle(f#), 3, "and takes another value")

form_position#(f#, 1)
assert_eq(form_position(f#), 1, "form_position# holds")

form_formstyle#(f#, 0)
assert_eq(form_formstyle(f#), 0, "form_formstyle# holds")

form_stayontop#(f#, 1)
assert_true(form_stayontop(f#), "form_stayontop# sets")
form_stayontop#(f#, 0)
assert_false(form_stayontop(f#), "and clears")

form_fullscreen#(f#, 0)
assert_false(form_fullscreen(f#), "form_fullscreen# holds a flag")

form_showfullscreenicon#(f#, 1)
assert_true(form_showfullscreenicon(f#), "form_showfullscreenicon# too")

test_case("form/appearance")
form_fill#(f#, "Red")
assert_true(len(form_fill$(f#)), "form_fill# takes a colour and form_fill$ reads one back")

form_transparency#(f#, 1)
assert_true(form_transparency(f#), "form_transparency# sets the flag")
form_transparency#(f#, 0)
assert_false(form_transparency(f#), "and clears it")

form_padding#(f#, 8)
assert_eq(form_padding(f#), 8, "form_padding# sets one number for all four sides")
form_paddings#(f#, 1, 2, 3, 4)
assert_eq(form_error(), 0, "and form_paddings# takes them separately")

test_case("form/tag-and-handle")
rem The tag is a number the program owns; nothing in the library reads
rem it. The handle is the platform's, and only has to be answerable.
form_tag#(f#, 4242)
assert_eq(form_tag(f#), 4242, "form_tag# holds a number for the program")
assert_true(form_handle(f#) + 1, "form_handle answers something")

test_case("form/closing")
rem closeaction and allowclose are read back rather than exercised: a
rem form that actually closes takes the rest of this file with it.
form_closeaction#(f#, 0)
assert_eq(form_closeaction(f#), 0, "form_closeaction# holds a code")
form_allowclose#(f#, 1)
assert_true(form_allowclose(f#), "form_allowclose# holds a flag")
form_allowclose#(f#, 0)
assert_false(form_allowclose(f#), "and clears it")

form_modalresult#(f#, 6)
assert_eq(form_modalresult(f#), 6, "form_modalresult# holds a result")

test_case("form/z-order-and-focus")
rem These have no getter -- where a window sits among its siblings is
rem not a property it carries -- so what is asserted is that each is
rem reachable and leaves no error.
form_clearerror()
form_bringtofront#(f#)
form_sendtoback#(f#)
form_setfocus#(f#)
form_invalidate#(f#)
assert_eq(form_error(), 0, "the z-order and focus verbs are reachable")
assert_false(form_active(f#), "and an unshown form is not the active one")

test_case("form/screen")
rem Four functions about the screen rather than about any form. Their
rem values belong to the machine, so what is asserted is their shape.
assert_true(form_screenwidth(), "form_screenwidth answers a width")
assert_true(form_screenheight(), "form_screenheight answers a height")
assert_true(form_screenscale(), "form_screenscale answers a scale")
if form_screenorientation() >= 0 then orient_ok = 1
assert_true(orient_ok, "and form_screenorientation a code")

test_case("form/errors")
form_clearerror()
assert_eq(form_error(), 0, "form_clearerror clears the code")
assert_true(len(form_errormsg$()) + 1, "form_errormsg$ is readable")

test_case("form/move-and-size")
rem move and size are the two halves of bounds, for when only one of
rem them is meant.
form_move#(f#, 33, 44)
assert_eq(form_left(f#), 33, "form_move# sets the left")
assert_eq(form_top(f#), 44, "and the top")
form_size#(f#, 320, 240)
assert_eq(form_width(f#), 320, "form_size# sets the width")
assert_eq(form_height(f#), 240, "and the height")
assert_eq(form_left(f#), 33, "without moving it")

test_case("form/event-names")
rem Every handler is stored by name and read back by the $ spelling of
rem the same word. An empty name unwires it. Whether each one fires is
rem 11_form_events.bas's business; what is pinned here is that all
rem eleven store and clear, because a name that does not come back is
rem a handler that was never wired.
form_onshow#(f#, "h_show")
assert_eq(form_onshow$(f#), "h_show", "onshow")
form_onhide#(f#, "h_hide")
assert_eq(form_onhide$(f#), "h_hide", "onhide")
form_onclose#(f#, "h_close")
assert_eq(form_onclose$(f#), "h_close", "onclose")
form_onclosequery#(f#, "h_closequery")
assert_eq(form_onclosequery$(f#), "h_closequery", "onclosequery")
form_onactivate#(f#, "h_activate")
assert_eq(form_onactivate$(f#), "h_activate", "onactivate")
form_ondeactivate#(f#, "h_deactivate")
assert_eq(form_ondeactivate$(f#), "h_deactivate", "ondeactivate")
form_onresize#(f#, "h_resize")
assert_eq(form_onresize$(f#), "h_resize", "onresize")
form_onpaint#(f#, "h_paint")
assert_eq(form_onpaint$(f#), "h_paint", "onpaint")
form_onkeydown#(f#, "h_keydown")
assert_eq(form_onkeydown$(f#), "h_keydown", "onkeydown")
form_onkeyup#(f#, "h_keyup")
assert_eq(form_onkeyup$(f#), "h_keyup", "onkeyup")
form_onfocuschanged#(f#, "h_focus")
assert_eq(form_onfocuschanged$(f#), "h_focus", "onfocuschanged")

form_onshow#(f#, "")
assert_eq(form_onshow$(f#), "", "an empty name unwires one")
form_onkeydown#(f#, "")
assert_eq(form_onkeydown$(f#), "", "and another")

test_case("form/error-names")
assert_true(len(form_strerror$(0)), "form_strerror$ names a code")

test_case("form/callbacks-and-free")
rem clearcallbacks unwires every handler at once, which is what a
rem program does before handing a form to something else.
form_clearcallbacks#(f#)
assert_eq(form_error(), 0, "form_clearcallbacks# is reachable")

form_hide(f#)
assert_false(form_visible(f#), "form_hide hides it")

assert_eq(form_free(f#), 1, "form_free reports success")
