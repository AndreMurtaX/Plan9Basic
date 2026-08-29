rem bench-ops: 40000
rem ---------------------------------------------------------------
rem String append at 40k. See 06_append_010k.bas for what the series
rem is for: read the ns/op column across all five, not this file
rem alone.
rem ---------------------------------------------------------------

s$ = ""
for i = 1 to 40000
  s$ = s$ + "x"
next
