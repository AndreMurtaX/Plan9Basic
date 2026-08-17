' =============================================
' Plan9Basic - Comprehensive Library Test
' Tests all 6 libraries in one applet
' =============================================
PRINTLN "=========================================="
PRINTLN "   PLAN9BASIC COMPREHENSIVE TEST"
PRINTLN "=========================================="
PRINTLN ""
PRINTLN "Testing all 6 libraries..."
PRINTLN ""
' ===========================================
' 1. STDLIB TEST
' ===========================================
PRINTLN ">>> 1. StdLib Test <<<"
PRINTLN ""
PRINTLN "pause(0.5) - waiting..."
pause(0.5)
PRINTLN "Done!"
PRINTLN "sign(-5) = "; sign(-5)
PRINTLN "sign(0) = "; sign(0)
PRINTLN "sign(5) = "; sign(5)
PRINTLN "formatsettings$('decimalseparator') = "; formatsettings$("decimalseparator")
PRINTLN ""
' ===========================================
' 2. STRLIB TEST
' ===========================================
PRINTLN ">>> 2. StrLib Test <<<"
PRINTLN ""
text$ = "Plan9Basic"
PRINTLN "text$ = "; text$
PRINTLN "ucase$() = "; ucase$(text$)
PRINTLN "lcase$() = "; lcase$(text$)
PRINTLN "len() = "; len(text$)
PRINTLN "left$(5) = "; left$(text$, 5)
PRINTLN "right$(5) = "; right$(text$, 5)
PRINTLN "reverse$() = "; reverse$(text$)
PRINTLN "chr$(65) = "; chr$(65)
PRINTLN "asc('Z') = "; asc("Z")
PRINTLN "hex$(255) = "; hex$(255)
PRINTLN "bin$(10) = "; bin$(10)
PRINTLN "val('3.14') = "; val("3.14")
PRINTLN ""
' ===========================================
' 3. NUMLIB TEST
' ===========================================
PRINTLN ">>> 3. NumLib Test <<<"
PRINTLN ""
PRINTLN "abs(-42) = "; abs(-42)
PRINTLN "sqr(16) = "; sqr(16)
PRINTLN "round(3.7) = "; round(3.7)
PRINTLN "int(-3.7) = "; int(-3.7)
pi = 3.14159265358979
PRINTLN "sin(pi/2) = "; sin(pi/2)
PRINTLN "cos(0) = "; cos(0)
PRINTLN "exp(1) = "; exp(1)
PRINTLN "ln(2.718) = "; ln(2.718)
PRINTLN "log10(100) = "; log10(100)
PRINTLN "min(5, 3) = "; min(5, 3)
PRINTLN "max(5, 3) = "; max(5, 3)
randomize()
PRINTLN "rnd() = "; rnd()
PRINTLN "rnd(100) = "; rnd(100)
PRINTLN ""
' ===========================================
' 4. DATETIMELIB TEST
' ===========================================
PRINTLN ">>> 4. DateTimeLib Test <<<"
PRINTLN ""
PRINTLN "date$() = "; date$()
PRINTLN "time$() = "; time$()
PRINTLN "datetime$() = "; datetime$()
dt = now()
PRINTLN "yearof(now) = "; yearof(dt)
PRINTLN "monthof(now) = "; monthof(dt)
PRINTLN "dayof(now) = "; dayof(dt)
PRINTLN "hourof(now) = "; hourof(dt)
PRINTLN "minuteof(now) = "; minuteof(dt)
PRINTLN "dayoftheweek(now) = "; dayoftheweek(dt)
PRINTLN "weekoftheyear(now) = "; weekoftheyear(dt)
PRINTLN "dayoftheyear(now) = "; dayoftheyear(dt)
PRINTLN "yesterday = "; datetostr$(yesterday())
PRINTLN "today = "; datetostr$(today())
PRINTLN "tomorrow = "; datetostr$(tomorrow())
PRINTLN "isinleapyear(now) = "; isinleapyear(dt)
PRINTLN "isam(now) = "; isam(dt)
PRINTLN "ispm(now) = "; ispm(dt)
PRINTLN ""
' ===========================================
' 5. PLATFORMINFOLIB TEST
' ===========================================
PRINTLN ">>> 5. PlatformInfoLib Test <<<"
PRINTLN ""
PRINTLN "os_platform$() = "; os_platform$()
PRINTLN "os_name$() = "; os_name$()
PRINTLN "os_architecture$() = "; os_architecture$()
PRINTLN "os_major() = "; os_major()
PRINTLN "os_minor() = "; os_minor()
PRINTLN "os_build() = "; os_build()
PRINTLN ""
' ===========================================
' 6. SYSLIB TEST
' ===========================================
PRINTLN ">>> 6. SysLib Test <<<"
PRINTLN ""
PRINTLN "homepath$() = "; homepath$()
PRINTLN "temppath$() = "; temppath$()
PRINTLN "documentspath$() = "; documentspath$()
PRINTLN "dirseparator$() = "; dirseparator$()
PRINTLN "randomfilename$() = "; randomfilename$()
filepath$ = homepath$() + "test.bas"
PRINTLN "extractfilename$() = "; extractfilename$(filepath$)
PRINTLN "extractfileext$() = "; extractfileext$(filepath$)
PRINTLN "paramcount() = "; paramcount()
PRINTLN ""
' ===========================================
' SUMMARY
' ===========================================
PRINTLN "=========================================="
PRINTLN "   ALL TESTS COMPLETED SUCCESSFULLY!"
PRINTLN "=========================================="
PRINTLN ""
PRINTLN "Libraries tested:"
PRINTLN "  1. StdLib - Standard utilities"
PRINTLN "  2. StrLib - String manipulation"
PRINTLN "  3. NumLib - Mathematical functions"
PRINTLN "  4. DateTimeLib - Date/time operations"
PRINTLN "  5. PlatformInfoLib - OS information"
PRINTLN "  6. SysLib - System paths and files"
PRINTLN ""
PRINTLN "=========================================="
