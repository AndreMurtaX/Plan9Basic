rem ---------------------------------------------------------------
rem A function returning a number is not a condition on its own. It
rem has to be compared: IF dict_haskey(d#, "k") <> 0 THEN.
rem
rem MUST be rejected. Every BASIC a person arrives from accepts the
rem short form, so this is a rule they bring with them and lose.
rem ---------------------------------------------------------------
let d# = dict#()
dict_set#(d#, "k", "v")
if dict_haskey(d#, "k") then
  println "found"
end if
