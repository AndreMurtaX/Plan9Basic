' =============================================
' Plan9Basic - System Information Report
' Displays comprehensive system information
' =============================================
PRINTLN "=========================================="
PRINTLN "       SYSTEM INFORMATION REPORT"
PRINTLN "=========================================="
PRINTLN ""
PRINTLN "=== Operating System ==="
PRINTLN "Platform: "; os_platform$()
PRINTLN "Name: "; os_name$()
PRINTLN "Architecture: "; os_architecture$()
PRINTLN "Version: "; os_major(); "."; os_minor(); "."; os_build()
PRINTLN ""
PRINTLN "=== Current Date/Time ==="
PRINTLN "Date: "; date$()
PRINTLN "Time: "; time$()
PRINTLN "Full: "; datetime$()
PRINTLN ""
dt = now()
PRINTLN "Year: "; yearof(dt)
PRINTLN "Month: "; monthof(dt)
PRINTLN "Day: "; dayof(dt)
PRINTLN "Day of Year: "; dayoftheyear(dt)
PRINTLN "Week of Year: "; weekoftheyear(dt)
PRINTLN ""
IF isinleapyear(dt) = 1 THEN
  PRINTLN "This is a leap year."
ELSE
  PRINTLN "This is not a leap year."
END IF
PRINTLN ""
PRINTLN "=== System Paths ==="
PRINTLN "Home: "; homepath$()
PRINTLN "Documents: "; documentspath$()
PRINTLN "Downloads: "; downloadspath$()
PRINTLN "Temp: "; temppath$()
PRINTLN "Cache: "; cachepath$()
PRINTLN ""
PRINTLN "=== Path Separators ==="
PRINTLN "Directory: "; dirseparator$()
PRINTLN "Path: "; pathseparator$()
PRINTLN ""
PRINTLN "=== Command Line ==="
PRINTLN "Parameters: "; paramcount()
PRINTLN "Program: "; extractfilename$(paramstr$(0))
PRINTLN ""
PRINTLN "=========================================="
PRINTLN "         END OF REPORT"
PRINTLN "=========================================="
