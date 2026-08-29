rem ---------------------------------------------------------------
rem A LET list declares names only. `let a, b = 5` MUST be rejected.
rem
rem It could mean that both names get five, or that a is merely
rem declared and b is assigned. A reader would have to know which,
rem and neither reading is worth a rule -- so the parser refuses and
rem says to write that one out.
rem
rem If this file ever passes, the language has quietly acquired a
rem construction whose meaning depends on knowing which of two
rem plausible readings was chosen.
rem ---------------------------------------------------------------
let a, b = 5
println a
println b
