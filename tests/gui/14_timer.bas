rem ---------------------------------------------------------------
rem TimerLib. check-coverage.py reported 0/15 -- nothing in it had
rem ever been run by a test.
rem
rem It lives under --gui because it is the one non-drawing library that
rem genuinely reaches FireMonkey: check-fmx-boundary.py reports TimerLib
rem and nothing else, because a timer is a TTimer.
rem
rem What is NOT asserted here is that a timer fires. OnTimer arrives on
rem the message loop, and this runner has no loop to pump: a test that
rem waited for a tick would wait forever. So this file covers the
rem object -- its interval, its enabled flag, its tag, its handler name
rem and the three verbs -- and the firing stays with the applets, where
rem a window is running.
rem ---------------------------------------------------------------

test_case("timer/construction")
t# = timer#()
assert_true(pnttonum(t#), "timer# answers a handle")
assert_eq(timer_error(), 0, "with nothing to report")

test_case("timer/interval")
timer_interval#(t#, 250)
assert_eq(timer_interval(t#), 250, "timer_interval# holds a value in milliseconds")
timer_interval#(t#, 1000)
assert_eq(timer_interval(t#), 1000, "and takes another")

test_case("timer/enabled")
rem A timer starts disabled, which is what stops one firing between
rem being made and being configured.
assert_false(timer_enabled(t#), "a new timer is not running")
timer_enabled#(t#, 1)
assert_true(timer_enabled(t#), "timer_enabled# starts it")
timer_enabled#(t#, 0)
assert_false(timer_enabled(t#), "and stops it")

test_case("timer/verbs")
rem The three verbs are the enabled flag said imperatively, and restart
rem is stop and start in one call -- which for a timer is not the same
rem as leaving it running, because it puts the countdown back to zero.
timer_start#(t#)
assert_true(timer_enabled(t#), "timer_start# enables")
timer_stop#(t#)
assert_false(timer_enabled(t#), "timer_stop# disables")
timer_restart#(t#)
assert_true(timer_enabled(t#), "timer_restart# leaves it enabled")
timer_stop#(t#)

test_case("timer/tag")
timer_tag#(t#, 77)
assert_eq(timer_tag(t#), 77, "timer_tag# holds a number for the program")

test_case("timer/handler-name")
rem Stored by name and read back, with an empty name unwiring it. The
rem firing is not exercised, for the reason at the head of this file.
timer_ontimer#(t#, "on_tick")
assert_eq(timer_ontimer$(t#), "on_tick", "timer_ontimer# stores a name")
timer_ontimer#(t#, "")
assert_eq(timer_ontimer$(t#), "", "and an empty name unwires it")

test_case("timer/errors")
assert_eq(timer_error(), 0, "nothing above went wrong")
assert_true(len(timer_error$()) + 1, "timer_error$ is readable")

test_case("timer/handles")
rem The registry answers for a fabricated pointer without following it.
junk# = pointer#(305419896)
n = timer_interval(junk#)
assert_eq(n, 0, "an invented timer answers nothing")
assert_true(timer_error(), "and says so")

test_case("timer/free")
assert_true(pnttonum(timer_free#(t#)) + 1, "timer_free# is reachable")
