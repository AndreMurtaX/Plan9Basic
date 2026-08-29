rem bench-ops: 500000
rem ---------------------------------------------------------------
rem Reading an array element half a million times.
rem
rem a#[i] is not a VM instruction. It compiles to a native call --
rem PUSH# / PUSHC / PUSHC / CALLEX "narr_get@#n" / POPSTORE -- so this
rem measures the whole far-call path: the signature lookup, the
rem argument array, and the handle validation inside ArrayLib.
rem ---------------------------------------------------------------

a# = dim#(64)
for i = 1 to 64
  a#[i] = i
next

s = 0
for i = 1 to 500000
  s = s + a#[(i mod 64) + 1]
next
