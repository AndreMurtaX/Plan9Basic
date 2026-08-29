rem bench-ops: 500000
rem ---------------------------------------------------------------
rem The cheapest native call the engine has, called half a million
rem times.
rem
rem abs() does almost nothing, which is the point: subtract the empty
rem loop and what remains is very nearly the fixed cost of reaching a
rem registered function -- building its signature, hashing it twice,
rem and allocating the argument array.
rem ---------------------------------------------------------------

s = 0
for i = 1 to 500000
  s = s + abs(0 - i)
next
