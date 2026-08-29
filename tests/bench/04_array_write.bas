rem bench-ops: 500000
rem ---------------------------------------------------------------
rem Writing an array element half a million times.
rem
rem The store path is a different handler from the read path -- it
rem goes through fCallFarP rather than fCallFar -- and a change that
rem only fixes one of them would show up here as an unmoved number.
rem ---------------------------------------------------------------

a# = dim#(64)

for i = 1 to 500000
  a#[(i mod 64) + 1] = i
next
