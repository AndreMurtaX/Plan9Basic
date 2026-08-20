rem ---------------------------------------------------------------
rem A boolean expression is only valid inside an IF, WHILE or UNTIL
rem condition. ANALYSIS section 4 says so, and this MUST be rejected.
rem
rem It is the constraint a person meets first and by accident: the
rem obvious way to write a test is assert_true(2 > 1), and the obvious
rem way to keep a flag is x = a > b. Both are syntax errors, and the
rem message says only "Syntax error", so knowing the rule is the
rem difference between a minute and an afternoon. It cost one of each
rem while section 31's test was being written.
rem ---------------------------------------------------------------
x = 2 > 1
println x
