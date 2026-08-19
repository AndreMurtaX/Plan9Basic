rem ---------------------------------------------------------------
rem The transition effects take progress on a 0..1 scale, which is what
rem their documentation always said and what the getter always returned.
rem
rem The setter used to guess: it multiplied by 100 only when the value was
rem at most 1. So progress#(e, 1) meant 100% and progress#(e, 2) meant 2%,
rem and 0.5 and 50 both meant half way. The scale was discontinuous at 1.
rem ---------------------------------------------------------------

f# = form#()
r# = rectangle#(f#)
e# = blurtrans#(r#)

test_case("effects/progress-scale")
p# = blurtrans_progress#(e#, 0)
assert_eq(blurtrans_progress(e#), 0, "0 is the source image")
p# = blurtrans_progress#(e#, 1)
assert_eq(blurtrans_progress(e#), 1, "1 is the target image")
p# = blurtrans_progress#(e#, 0.25)
assert_near(blurtrans_progress(e#), 0.25, 0.001, "a quarter of the way")

test_case("effects/progress-clamps")
rem Out of range saturates at the ends rather than being reinterpreted.
p# = blurtrans_progress#(e#, 2)
assert_eq(blurtrans_progress(e#), 1, "above the range is the target, not 2%")
p# = blurtrans_progress#(e#, -1)
assert_eq(blurtrans_progress(e#), 0, "below the range is the source")

test_case("effects/progress-is-continuous")
rem The old setter jumped: 1 meant everything and 1.5 meant almost nothing.
p# = blurtrans_progress#(e#, 0.9)
a = blurtrans_progress(e#)
p# = blurtrans_progress#(e#, 1)
b = blurtrans_progress(e#)
ok = 0
if b > a then ok = 1
assert_eq(ok, 1, "0.9 comes before 1, and both are near the end")
