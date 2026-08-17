' =============================================
' Plan9Basic - Text Statistics
' Analyzes text using string functions
' =============================================
PRINTLN "=========================================="
PRINTLN "         TEXT STATISTICS"
PRINTLN "=========================================="
PRINTLN ""
text$ = "Plan9Basic is a simple programming language inspired by classic BASIC."
PRINTLN "Text:"
PRINTLN text$
PRINTLN ""
PRINTLN "--- Basic Statistics ---"
PRINTLN "Length: "; len(text$); " characters"
PRINTLN ""
PRINTLN "--- Case Conversions ---"
PRINTLN "Upper: "; ucase$(text$)
PRINTLN "Lower: "; lcase$(text$)
PRINTLN ""
PRINTLN "--- Substrings ---"
PRINTLN "First 10: "; left$(text$, 10)
PRINTLN "Last 10: "; right$(text$, 10)
PRINTLN "Middle (20-30): "; mid$(text$, 20, 10)
PRINTLN ""
PRINTLN "--- String Search ---"
PRINTLN "Contains 'BASIC': "; containstext(text$, "BASIC")
PRINTLN "Contains 'Python': "; containstext(text$, "Python")
PRINTLN "Starts with 'Plan': "; startsstr("Plan", text$)
PRINTLN "Ends with 'BASIC.': "; endsstr("BASIC.", text$)
PRINTLN ""
PRINTLN "--- Manipulation ---"
PRINTLN "Reversed: "; reverse$(text$)
PRINTLN ""
PRINTLN "Replace 'simple' with 'powerful':"
PRINTLN replacestr$(text$, "simple", "powerful")
PRINTLN ""
PRINTLN "=========================================="
