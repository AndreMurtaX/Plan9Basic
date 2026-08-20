rem ---------------------------------------------------------------
rem The six animation libraries, in the part that can be asked here:
rem the object.
rem
rem NOT THE MOVEMENT. A FireMonkey animation advances on the interface
rem clock, and this runner has no interface turning -- measured rather
rem than assumed: floatani_start followed by floatani_running answers
rem 0, and the normalized time stays at zero. A test that waited for a
rem frame would wait for ever.
rem
rem So what is pinned is what a program can set up before anything
rem moves, and that every verb is reachable and leaves no error. The
rem motion itself belongs to the applets, where a window is running.
rem
rem The sprite-sheet animation is the one that loads a picture, and it
rem takes a url as readily as a path -- that is covered in
rem 18_image_targets.bas rather than repeated here.
rem ---------------------------------------------------------------

f# = form#("animation host", 400, 300)
r# = rectangle#(f#, 10, 10, 100, 100)

test_case("animation/float")
fa# = floatani#(r#)
assert_true(pnttonum(fa#), "floatani# answers a handle")
assert_true(len(floatani_name$(fa#)) + 1, "floatani_name$ is readable")
assert_false(floatani_running(fa#), "a new animation is not running")

floatani_clearerror()
floatani_start(fa#)
assert_false(floatani_running(fa#), "and does not start turning without an interface clock")
floatani_stop(fa#)
floatani_stopatcurrent(fa#)
assert_eq(floatani_normalizedtime(fa#), 0, "and its normalized time stays at the beginning -- unlike the path and rectangle ones, which jump to the end on stop")
floatani_clearcallbacks#(fa#)
assert_eq(floatani_error(), 0, "every verb is reachable")

test_case("animation/int")
ia# = intani#(r#)
assert_true(len(intani_name$(ia#)) + 1, "intani_name$ is readable")
assert_false(intani_running(ia#), "a new one is not running")
intani_clearerror()
intani_start(ia#)
intani_stop(ia#)
intani_stopatcurrent(ia#)
assert_eq(intani_normalizedtime(ia#), 0, "and stays at the beginning")
intani_clearcallbacks#(ia#)
assert_eq(intani_error(), 0, "with every verb reachable")

test_case("animation/colour")
ca# = colorani#(r#)
assert_true(len(colorani_name$(ca#)) + 1, "colorani_name$ is readable")
assert_false(colorani_running(ca#), "a new one is not running")
colorani_clearerror()
colorani_start(ca#)
colorani_stop(ca#)
colorani_stopatcurrent(ca#)
assert_eq(colorani_normalizedtime(ca#), 0, "and stays at the beginning")
colorani_clearcallbacks#(ca#)
assert_eq(colorani_error(), 0, "with every verb reachable")

test_case("animation/colour-helpers")
rem Three conversions that belong to the colour animation because that
rem is what it animates between. They are pure functions and need no
rem animation at all.
assert_true(rgb(255, 128, 0), "rgb makes a colour from three parts")
assert_true(rgba(255, 128, 0, 255), "rgba from four")
rem colortoalphacolor takes a NAME and answers the number, which is the
rem opposite way round from what the pair of names suggests -- and
rem alphacolortostring$ is the one that goes back the other way.
assert_true(colortoalphacolor("Red"), "colortoalphacolor turns a name into a number")
assert_true(len(alphacolortostring$(colortoalphacolor("Red"))), "and alphacolortostring$ turns it back into a name")

test_case("animation/path")
pa# = pathani#(r#)
assert_true(len(pathani_name$(pa#)) + 1, "pathani_name$ is readable")
assert_false(pathani_running(pa#), "a new one is not running")
pathani_clearerror()
pathani_clearpath#(pa#)
rem STOP IS NOT CANCEL for this one. FireMonkey's Stop completes the
rem animation -- it applies the final value and marks the time as 1 --
rem while StopAtCurrent is the verb that leaves things where they are.
rem Two of the six behave this way even though nothing ever moved, and
rem four stay at the beginning. Measured, not assumed.
pathani_start(pa#)
assert_eq(pathani_normalizedtime(pa#), 0, "starting alone moves nothing")
pathani_stop(pa#)
assert_eq(pathani_normalizedtime(pa#), 1, "but stopping jumps it to the end")
pathani_stopatcurrent(pa#)
assert_eq(pathani_normalizedtime(pa#), 1, "and stopatcurrent leaves it there")
pathani_clearcallbacks#(pa#)
assert_eq(pathani_error(), 0, "with every verb reachable, clearpath# included")

test_case("animation/rectangle")
rem The rectangle animation is the one with real state to set: where
rem the shape starts and where it ends, as four numbers each or as a
rem whole rectangle at once. None of it needs the animation to run.
ra# = rectani#(r#)
assert_true(len(rectani_name$(ra#)) + 1, "rectani_name$ is readable")
assert_false(rectani_running(ra#), "a new one is not running")

rectani_startbounds#(ra#, 0, 0, 50, 40)
assert_eq(rectani_startx(ra#), 0, "rectani_startbounds# sets the starting x")
assert_eq(rectani_starty(ra#), 0, "the starting y")
assert_eq(rectani_startwidth(ra#), 50, "the starting width")
assert_eq(rectani_startheight(ra#), 40, "and the starting height")

rectani_stopbounds#(ra#, 100, 80, 150, 120)
assert_eq(rectani_stopx(ra#), 100, "rectani_stopbounds# sets the ending x")
assert_eq(rectani_stopy(ra#), 80, "the ending y")
assert_eq(rectani_stopwidth(ra#), 150, "the ending width")
assert_eq(rectani_stopheight(ra#), 120, "and the ending height")

rectani_clearerror()
rectani_start(ra#)
assert_eq(rectani_normalizedtime(ra#), 0, "starting alone moves nothing")
rectani_stop(ra#)
assert_eq(rectani_normalizedtime(ra#), 1, "and this one jumps to the end on stop as well")
rectani_stopatcurrent(ra#)
assert_eq(rectani_normalizedtime(ra#), 1, "which stopatcurrent then leaves alone")
rectani_clearcallbacks#(ra#)
assert_eq(rectani_error(), 0, "with every verb reachable")

test_case("animation/sprite-sheet")
ba# = bmplistani#(r#)
assert_true(len(bmplistani_name$(ba#)) + 1, "bmplistani_name$ is readable")
assert_false(bmplistani_running(ba#), "a new one is not running")
assert_true(pnttonum(bmplistani_animationbitmap#(ba#)), "bmplistani_animationbitmap# answers the strip it walks")
bmplistani_clearerror()
assert_eq(bmplistani_normalizedtime(ba#), 0, "its normalized time starts at the beginning")
bmplistani_clearcallbacks#(ba#)
assert_eq(bmplistani_error(), 0, "with every verb reachable")

form_free(f#)
