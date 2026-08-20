rem ---------------------------------------------------------------
rem true and false are not usable as values. MUST be rejected.
rem
rem Not even in a condition; 08 is that half, because a file here
rem stops at its first error and one rejection per file is the only
rem way to know which rejection happened.
rem ---------------------------------------------------------------
x = true
println x
