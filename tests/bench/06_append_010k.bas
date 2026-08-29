rem bench-ops: 10000
rem ---------------------------------------------------------------
rem String append, first of five.
rem
rem These five files exist to be read as a series, not one at a time.
rem The work doubles from each to the next, so if appending costs a
rem constant amount the millisecond column doubles too and the ns/op
rem column stays flat. If it does not, the cost per append is growing
rem with the length of the string already built -- which is the
rem definition of a quadratic loop, and is what the council measured.
rem ---------------------------------------------------------------

s$ = ""
for i = 1 to 10000
  s$ = s$ + "x"
next
