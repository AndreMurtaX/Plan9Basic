rem ---------------------------------------------------------------
rem Compound assignment requires the operator and the '=' to be
rem adjacent. `x + = 1` MUST still be rejected.
rem
rem This is the guard on the whole feature. `+` and `=` were already
rem separate tokens before compound assignment existed, so the parser
rem could have recognised the pair wherever it found them -- and then
rem `x + = 1`, which has always been a syntax error, would quietly
rem have started meaning `x = x + 1`. Text that already exists cannot
rem be allowed to change meaning, and the only thing standing between
rem those two readings is the test that the two characters touch.
rem
rem If this file ever passes, the adjacency test in
rem TBasicParser.CompoundOp has been lost.
rem ---------------------------------------------------------------
x = 1
x + = 1
println x
