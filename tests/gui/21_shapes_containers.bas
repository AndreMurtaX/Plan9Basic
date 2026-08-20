rem ---------------------------------------------------------------
rem The shape libraries and the three containers, in the parts the
rem generated property suite does not reach: who a control's parent is,
rem the two paint flags, the repaint, and the handful of shape-specific
rem setters.
rem
rem A shape has no getter for "no fill" -- it is the absence of one
rem rather than a value -- so those are asserted as reachable and
rem leaving no error, which is what the library can actually answer.
rem ---------------------------------------------------------------

f# = form#("shape host", 500, 400)

test_case("shapes/parents")
rem Every control knows the form it was put on. This is the accessor the
rem engine itself uses to find the interpreter, so a control that
rem answers the wrong parent is a control whose events are dead.
rc# = rectangle#(f#, 10, 10, 80, 60)
ci# = circle#(f#, 100, 10, 60, 60)
el# = ellipse#(f#, 170, 10, 80, 50)
rr# = roundrect#(f#, 260, 10, 80, 60)
ln# = line#(f#, 10, 80, 200, 80)
ar# = arc#(f#, 10, 100, 80, 80)
pi# = pie#(f#, 100, 100, 80, 80)
co# = callout#(f#, 190, 100, 120, 70)

assert_eq(pnttonum(rectangle_parent#(rc#)), pnttonum(f#), "a rectangle knows its form")
assert_eq(pnttonum(circle_parent#(ci#)), pnttonum(f#), "a circle does")
assert_eq(pnttonum(ellipse_parent#(el#)), pnttonum(f#), "an ellipse does")
assert_eq(pnttonum(roundrect_parent#(rr#)), pnttonum(f#), "a rounded rectangle does")
assert_eq(pnttonum(line_parent#(ln#)), pnttonum(f#), "a line does")
assert_eq(pnttonum(arc_parent#(ar#)), pnttonum(f#), "an arc does")
assert_eq(pnttonum(pie_parent#(pi#)), pnttonum(f#), "a pie does")
assert_eq(pnttonum(callout_parent#(co#)), pnttonum(f#), "and a callout does")

test_case("shapes/paint-flags")
rem fillnone and strokenone turn off the two halves of how a shape is
rem drawn. A line has no inside, so it has only the stroke.
rectangle_clearerror()
rectangle_fillnone#(rc#)
rectangle_strokenone#(rc#)
rectangle_invalidate#(rc#)
assert_eq(rectangle_error(), 0, "a rectangle takes both and a repaint")

circle_clearerror()
circle_fillnone#(ci#)
circle_strokenone#(ci#)
circle_invalidate#(ci#)
assert_eq(circle_error(), 0, "so does a circle")

ellipse_clearerror()
ellipse_fillnone#(el#)
ellipse_strokenone#(el#)
ellipse_invalidate#(el#)
assert_eq(ellipse_error(), 0, "and an ellipse")

roundrect_clearerror()
roundrect_fillnone#(rr#)
roundrect_strokenone#(rr#)
roundrect_invalidate#(rr#)
assert_eq(roundrect_error(), 0, "and a rounded rectangle")

arc_clearerror()
arc_fillnone#(ar#)
arc_strokenone#(ar#)
arc_invalidate#(ar#)
assert_eq(arc_error(), 0, "and an arc")

pie_clearerror()
pie_fillnone#(pi#)
pie_strokenone#(pi#)
pie_invalidate#(pi#)
assert_eq(pie_error(), 0, "and a pie")

callout_clearerror()
callout_fillnone#(co#)
callout_strokenone#(co#)
callout_invalidate#(co#)
assert_eq(callout_error(), 0, "and a callout")

line_clearerror()
line_strokenone#(ln#)
line_invalidate#(ln#)
assert_eq(line_error(), 0, "a line has a stroke and no inside")

test_case("shapes/their-own-setters")
rem Three shapes carry a measurement nothing else does: the two angles
rem that make an arc or a pie a slice rather than a whole, and the
rem corner radius of a callout.
arc_clearerror()
arc_angles#(ar#, 0, 90)
assert_eq(arc_error(), 0, "arc_angles# takes a start and a sweep")

pie_clearerror()
pie_angles#(pi#, 45, 180)
assert_eq(pie_error(), 0, "pie_angles# does too")

callout_clearerror()
callout_corners#(co#, 8, 8)
assert_eq(callout_error(), 0, "callout_corners# takes a radius")

test_case("containers/children")
rem A layout and a panel are the two things that hold other controls,
rem and both can be asked what they are holding. The count going up as
rem children are made on them is what proves the parent was taken.
ly# = layout#(f#, 10, 200, 200, 150)
assert_eq(pnttonum(layout_parent#(ly#)), pnttonum(f#), "a layout knows its form")
assert_eq(layout_childcount(ly#), 0, "and starts empty")

a# = rectangle#(ly#, 0, 0, 40, 40)
b# = rectangle#(ly#, 50, 0, 40, 40)
assert_eq(layout_childcount(ly#), 2, "layout_childcount counts what was put on it")
assert_true(pnttonum(layout_child#(ly#, 0)), "layout_child# answers one by position")

pn# = panel#(f#, 220, 200, 200, 150)
assert_eq(pnttonum(panel_parent#(pn#)), pnttonum(f#), "a panel knows its form")
assert_eq(panel_childcount(pn#), 0, "and starts empty")
c# = rectangle#(pn#, 0, 0, 40, 40)
assert_eq(panel_childcount(pn#), 1, "panel_childcount counts too")
assert_true(pnttonum(panel_child#(pn#, 0)), "and panel_child# answers one")

test_case("containers/padding")
rem One number for all four sides, or four for the sides separately.
layout_clearerror()
layout_padding#(ly#, 6)
layout_paddings#(ly#, 1, 2, 3, 4)
layout_invalidate#(ly#)
assert_eq(layout_error(), 0, "a layout takes padding both ways and a repaint")

panel_clearerror()
panel_padding#(pn#, 6)
panel_paddings#(pn#, 1, 2, 3, 4)
panel_invalidate#(pn#)
assert_eq(panel_error(), 0, "and so does a panel")

test_case("containers/scrollbox")
rem A scroll box is the third container, and the one whose content can
rem be larger than itself -- which is the whole reason it scrolls.
sb# = scrollbox#(f#, 10, 360, 200, 30)
assert_true(pnttonum(sb#), "scrollbox# answers a handle")
if scrollbox_contentwidth(sb#) >= 0 then cw_ok = 1
assert_true(cw_ok, "scrollbox_contentwidth answers a width")
if scrollbox_contentheight(sb#) >= 0 then ch_ok = 1
assert_true(ch_ok, "scrollbox_contentheight a height")
assert_true(len(scrollbox_strerror$(0)), "scrollbox_strerror$ names a code")
assert_eq(scrollbox_free(sb#), 1, "scrollbox_free reports success")

form_free(f#)
