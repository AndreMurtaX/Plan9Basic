rem ---------------------------------------------------------------
rem The kind of an expression is decided by its FIRST token, so a
rem number followed by text MUST still be rejected.
rem
rem `"text " + number` now works; `number + "text"` does not, and
rem cannot without the parser deciding an expression's kind from
rem something other than where it starts. What changed is the
rem message, which used to be "Arithmetic operator expected" and now
rem says to put the text first -- advice that is worth giving because
rem the reverse order needs no str$ at all any more.
rem ---------------------------------------------------------------
x = 5
s$ = x + " items"
println s$
