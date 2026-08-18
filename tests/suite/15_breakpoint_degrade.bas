rem ---------------------------------------------------------------
rem BREAKPOINT must never park the VM when nobody can answer it.
rem
rem The command sets the machine to esIdle and waits for ConfirmProc to
rem call back. A headless host installs no ConfirmProc, and neither does
rem an FMX host on Android or iOS, where a modal answer cannot reach a
rem calling thread that is already blocked. In both cases the engine has
rem to report the frame and carry on.
rem
rem If it ever waits instead, this file stops producing output and the
rem runner kills it on timeout, which is the failure this guards.
rem ---------------------------------------------------------------

test_case("breakpoint/trace-off-is-skipped")
n = 7
s$ = "frame"
rem With trace off the command does nothing, but still has to pop the
rem message and the operands it was given.
breakpoint "ignored while trace is off", n, s$
assert_eq(n, 7, "trace off leaves the numeric operand untouched")
assert_eq(s$, "frame", "and the string operand as well")

test_case("breakpoint/no-host-continues")
trace 1
breakpoint "degrade check", n, s$
trace 0
assert_eq(n, 7, "execution continued past the breakpoint")
assert_eq(s$, "frame", "and the operands were popped in the right order")

test_case("breakpoint/no-variables")
trace 1
breakpoint "bare breakpoint"
trace 0
assert_true(1, "a breakpoint carrying no variables also continues")
