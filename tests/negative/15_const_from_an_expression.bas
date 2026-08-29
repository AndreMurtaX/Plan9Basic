rem ---------------------------------------------------------------
rem CONST takes a literal. An expression MUST be rejected.
rem
rem `const N = M + 1` would need constant folding, which the council
rem rejected on its own merits, and a constant whose value depends on
rem when it is evaluated is a worse idea than a longer program. The
rem error says what CONST does take.
rem ---------------------------------------------------------------
const BASE = 10
const DOUBLED = BASE * 2
println DOUBLED
