' =============================================
' Plan9Basic - Digital Clock
' A simple digital clock demonstration
' =============================================
PRINTLN "=========================================="
PRINTLN "         DIGITAL CLOCK"
PRINTLN "=========================================="
PRINTLN ""
' Run for 10 iterations
FOR i = 1 TO 10
  PRINTLN "Date: "; date$()
  PRINTLN "Time: "; time$()
  PRINTLN ""
  PRINTLN "Year: "; yearof(now()); "  Month: "; monthof(now()); "  Day: "; dayof(now())
  PRINTLN "Hour: "; hourof(now()); "  Min: "; minuteof(now()); "  Sec: "; int(now() * 86400) - int(now() * 86400 / 60) * 60
  PRINTLN ""
  ' Show day information
  dow = dayoftheweek(now())
  IF dow = 1 THEN PRINTLN "Today is Monday"
  IF dow = 2 THEN PRINTLN "Today is Tuesday"
  IF dow = 3 THEN PRINTLN "Today is Wednesday"
  IF dow = 4 THEN PRINTLN "Today is Thursday"
  IF dow = 5 THEN PRINTLN "Today is Friday"
  IF dow = 6 THEN PRINTLN "Today is Saturday"
  IF dow = 7 THEN PRINTLN "Today is Sunday"
  PRINTLN ""
  PRINTLN "Week "; weekoftheyear(now()); " of the year"
  PRINTLN "Day "; dayoftheyear(now()); " of "; daysinyear(now())
  PRINTLN ""
  PRINTLN "---"
  pause(1)
NEXT
PRINTLN ""
PRINTLN "Clock demonstration finished."
