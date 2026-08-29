rem bench-callback: benchstep@
rem bench-callback-calls: 20000
rem bench-ops: 40
rem ---------------------------------------------------------------
rem The loop the shipped product actually spends its time in.
rem
rem Everything else in this directory runs under ExecuteProgram. A
rem game does not: it draws one frame and returns, and the next frame
rem arrives as an OnTimer callback, which runs under ExecuteFunction
rem instead -- a second dispatch loop, 120 lines away in the same
rem file, that does not necessarily carry the same fixes.
rem
rem The harness calls benchstep below twenty thousand times, and calls
rem it twice: once with the script timeout off, the way the IDE runs,
rem and once with it set the way runner/AppletRunner.pas sets it for
rem a device. A gap between those two columns is not measurement
rem noise. It is a cost the machine we develop on cannot show us.
rem
rem The body is shaped like a real frame rather than a synthetic loop:
rem forty entities held in two parallel arrays indexed by one counter,
rem which is the idiom every game in Demos/ uses.
rem ---------------------------------------------------------------

let ENTITIES = 40
let PLAY_H = 400

ex# = dim#(40)
ey# = dim#(40)

for i = 1 to ENTITIES
  ex#[i] = i * 3
  ey#[i] = i * 7
next

function benchstep() local i, x, y
  for i = 1 to 40
    x = ex#[i]
    y = ey#[i] + 1
    if y > 400 then
      y = 0
      x = x + 1
    end if
    ex#[i] = x
    ey#[i] = y
  next
  return 0
endfunction
