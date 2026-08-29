rem ---------------------------------------------------------------
rem Assigning to a constant MUST be rejected.
rem
rem This is what CONST is for. Substituting a literal is worth low
rem single-digit nanoseconds and a variable slot; catching a write to
rem a name the program declared constant is worth an afternoon, and
rem it is the half neither analyst proposed.
rem
rem If this file ever passes, CONST has become a slower way to write
rem a variable.
rem ---------------------------------------------------------------
const MAXLIVES = 3
MAXLIVES = 4
println MAXLIVES
