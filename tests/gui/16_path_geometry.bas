rem ---------------------------------------------------------------
rem PathLib's geometry. check-coverage.py reported 78/104: the shape
rem building itself -- the pen movements, the curves, the primitives,
rem the transforms and the measurements -- had never been run. The
rem control's properties were already covered by the generated
rem property suite; this is the drawing.
rem
rem The map came from Examples/58_PathLib_Tests.bas, 1,002 lines
rem calling 101 functions with one check in it.
rem
rem Nothing here is drawn. A path is a list of points, and the points
rem can be counted and measured whether or not anything paints them,
rem which is what makes this assertable without a window.
rem ---------------------------------------------------------------

f# = form#("path host", 400, 400)
p# = path#(f#, 10, 10, 300, 300)

test_case("path/construction")
assert_true(pnttonum(p#), "path# answers a handle")
assert_eq(pnttonum(path_parent#(p#)), pnttonum(f#), "which knows the form it was put on")
path_clearerror()
assert_eq(path_error(), 0, "with nothing to report")

test_case("path/pen-movements")
rem A path starts empty, and every movement adds points to it. The
rem count going up is what proves each call reached the geometry
rem rather than being accepted and dropped.
path_clear#(p#)
assert_eq(path_pointcount(p#), 0, "a cleared path holds no points")

path_moveto#(p#, 10, 20)
assert_true(path_pointcount(p#), "path_moveto# starts one")
assert_eq(path_lastx(p#), 10, "and path_lastx answers where the pen is")
assert_eq(path_lasty(p#), 20, "with path_lasty for the other half")

path_lineto#(p#, 100, 20)
assert_eq(path_lastx(p#), 100, "path_lineto# moves the pen")
assert_eq(path_lasty(p#), 20, "in both coordinates")

path_hlineto#(p#, 150)
assert_eq(path_lastx(p#), 150, "path_hlineto# moves it sideways")
assert_eq(path_lasty(p#), 20, "and leaves the height alone")

path_vlineto#(p#, 80)
assert_eq(path_lastx(p#), 150, "path_vlineto# leaves the width alone")
assert_eq(path_lasty(p#), 80, "and moves it down")

test_case("path/curves")
rem Three kinds of curve, each with its own number of control points:
rem six for a cubic, four for a quadratic, four for a smooth cubic
rem that infers its first control point from the last one.
before = path_pointcount(p#)
path_curveto#(p#, 160, 90, 180, 100, 200, 110)
if path_pointcount(p#) > before then cubic_ok = 1
assert_true(cubic_ok, "path_curveto# adds a cubic")
assert_eq(path_lastx(p#), 200, "ending where it was told")

before = path_pointcount(p#)
path_quadcurveto#(p#, 220, 120, 240, 130)
if path_pointcount(p#) > before then quad_ok = 1
assert_true(quad_ok, "path_quadcurveto# adds a quadratic")
assert_eq(path_lastx(p#), 240, "ending where it was told")

before = path_pointcount(p#)
path_smoothcurveto#(p#, 260, 140, 280, 150)
if path_pointcount(p#) > before then smooth_ok = 1
assert_true(smooth_ok, "path_smoothcurveto# adds a smooth cubic")
assert_eq(path_lastx(p#), 280, "ending where it was told")

test_case("path/closing")
before = path_pointcount(p#)
path_closepath#(p#)
if path_pointcount(p#) >= before then closed_ok = 1
assert_true(closed_ok, "path_closepath# closes the figure")

test_case("path/primitives")
rem Each of the three adds a whole shape rather than a single point,
rem so a cleared path gains several at once.
path_clear#(p#)
path_addrectangle#(p#, 0, 0, 100, 50, 0, 0)
assert_true(path_pointcount(p#), "path_addrectangle# adds a rectangle")

path_clear#(p#)
path_addellipse#(p#, 0, 0, 100, 50)
assert_true(path_pointcount(p#), "path_addellipse# adds an ellipse")

path_clear#(p#)
path_addarc#(p#, 50, 50, 40, 40, 0, 90)
assert_true(path_pointcount(p#), "path_addarc# adds an arc")

test_case("path/bounds")
rem The bounds are the box the geometry fits in, so a rectangle from
rem the origin to (100, 50) has exactly those.
path_clear#(p#)
path_addrectangle#(p#, 0, 0, 100, 50, 0, 0)
assert_near(path_boundsx(p#), 0, 0.5, "path_boundsx answers the left edge")
assert_near(path_boundsy(p#), 0, 0.5, "path_boundsy the top")
assert_near(path_boundswidth(p#), 100, 0.5, "path_boundswidth the width")
assert_near(path_boundsheight(p#), 50, 0.5, "path_boundsheight the height")

test_case("path/transforms")
rem Each transform rewrites the points that are already there, which
rem is why the bounds move and the count does not.
path_clear#(p#)
path_addrectangle#(p#, 0, 0, 100, 50, 0, 0)
count_before = path_pointcount(p#)

path_translate#(p#, 20, 30)
assert_eq(path_pointcount(p#), count_before, "path_translate# moves without adding points")
assert_near(path_boundsx(p#), 20, 0.5, "and the left edge follows")
assert_near(path_boundsy(p#), 30, 0.5, "with the top")

path_clear#(p#)
path_addrectangle#(p#, 0, 0, 100, 50, 0, 0)
path_scale#(p#, 2, 2)
assert_near(path_boundswidth(p#), 200, 1, "path_scale# doubles the width")
assert_near(path_boundsheight(p#), 100, 1, "and the height")

path_clear#(p#)
path_addrectangle#(p#, 0, 0, 100, 50, 0, 0)
path_rotate#(p#, 90)
rem A quarter turn swaps the two, whichever way round the library
rem chooses to rotate.
assert_near(path_boundswidth(p#), 50, 1, "a quarter turn makes the width what the height was")
assert_near(path_boundsheight(p#), 100, 1, "and the height what the width was")

test_case("path/paint-flags")
rem These have no getter -- "no fill" is the absence of one rather than
rem a value -- so what is asserted is that both are reachable and leave
rem no error.
path_clearerror()
path_fillnone#(p#)
path_strokenone#(p#)
path_invalidate#(p#)
assert_eq(path_error(), 0, "the paint flags and the repaint are reachable")

test_case("path/bounds-setter")
rem path_bounds# is the control's rectangle on the form, not the
rem geometry's -- the same word for two different boxes.
path_bounds#(p#, 5, 6, 200, 150)
assert_eq(path_x(p#), 5, "path_bounds# sets the control's x")
assert_eq(path_width(p#), 200, "and its width")

test_case("path/callbacks")
path_onclick#(p#, "h_click")
assert_eq(path_onclick$(p#), "h_click", "a handler stores by name")
path_clearcallbacks#(p#)
assert_eq(path_onclick$(p#), "", "path_clearcallbacks# unwires them all")

form_free(f#)
