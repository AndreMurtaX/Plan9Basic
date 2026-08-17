' =============================================
' Plan9Basic - Age Calculator
' Calculates age and date statistics
' =============================================
PRINTLN "=========================================="
PRINTLN "         AGE CALCULATOR"
PRINTLN "=========================================="
PRINTLN ""
' Sample birth dates to demonstrate
DATA "1990-05-15", "1985-12-25", "2000-01-01", "1975-07-04"
PRINTLN "Calculating ages for sample birth dates..."
PRINTLN ""
FOR i = 1 TO 4
  READ birthstr$
  birthdate = strtodate(birthstr$)
  today_dt = today()
  PRINTLN "Birth date: "; datetostr$(birthdate)
  PRINTLN "Today: "; datetostr$(today_dt)
  PRINTLN ""
  years = yearsbetween(birthdate, today_dt)
  months = monthsbetween(birthdate, today_dt)
  weeks = weeksbetween(birthdate, today_dt)
  days = daysbetween(birthdate, today_dt)
  PRINTLN "Age breakdown:"
  PRINTLN "  Years: "; years
  PRINTLN "  Months: "; months
  PRINTLN "  Weeks: "; weeks
  PRINTLN "  Days: "; days
  PRINTLN ""
  ' Calculate next birthday
  thisyear = yearof(today_dt)
  birthmonth = monthof(birthdate)
  birthday = dayof(birthdate)
  PRINTLN "Birth month: "; birthmonth
  PRINTLN "Birth day: "; birthday
  PRINTLN ""
  PRINTLN "---"
  PRINTLN ""
NEXT
PRINTLN "=== Year Analysis ==="
PRINTLN ""
thisyear = yearof(today())
PRINTLN "Current year: "; thisyear
IF isinleapyear(today()) = 1 THEN
  PRINTLN "This is a LEAP YEAR!"
  PRINTLN "Days in this year: "; daysinyear(today())
ELSE
  PRINTLN "This is a regular year."
  PRINTLN "Days in this year: "; daysinyear(today())
ENDIF
PRINTLN ""
PRINTLN "Days in each month of "; thisyear; ":"
FOR m = 1 TO 12
  PRINTLN "  Month "; m; ": "; daysinamonth(thisyear, m); " days"
NEXT
PRINTLN ""
PRINTLN "=========================================="
