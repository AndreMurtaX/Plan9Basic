rem bench-ops: 2000000
rem ---------------------------------------------------------------
rem The dispatch floor: two million iterations that compute nothing.
rem
rem Whatever this costs is what the VM charges for the loop itself --
rem the FOR bookkeeping, the line-number opcode, and one dispatch per
rem instruction. Every other benchmark here is this plus its subject,
rem so this is the number to subtract.
rem ---------------------------------------------------------------

for i = 1 to 2000000
next
