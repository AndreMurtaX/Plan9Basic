rem bench-ops: 2000000
rem ---------------------------------------------------------------
rem Arithmetic through the stack machine.
rem
rem One multiply and one add per iteration, both operands reaching the
rem stack through PUSH and PUSHC. The arithmetic handlers themselves
rem write the result in place and are nearly free; what this measures
rem is the cost of getting values onto the stack and back off it.
rem ---------------------------------------------------------------

s = 0
for i = 1 to 2000000
  s = s + i * 2
next
