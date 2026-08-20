rem ---------------------------------------------------------------
rem The other half of 07: true is refused as a condition as well, not
rem only as a value. MUST be rejected.
rem
rem Worth its own file because the natural reading of "not usable as
rem values" is that they still work as conditions, and they do not --
rem it is the same "Value expected" from the same place.
rem ---------------------------------------------------------------
if true then
  println "t"
end if
