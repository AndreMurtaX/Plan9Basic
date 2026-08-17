' =============================================
' Plan9Basic - Calculator Demo
' Demonstrates mathematical operations
' =============================================
PRINTLN "=========================================="
PRINTLN "         CALCULATOR DEMO"
PRINTLN "=========================================="
PRINTLN ""
a = 15
b = 4
PRINTLN "Values: a = "; a; ", b = "; b
PRINTLN ""
PRINTLN "--- Basic Operations ---"
PRINTLN "a + b = "; a + b
PRINTLN "a - b = "; a - b
PRINTLN "a * b = "; a * b
PRINTLN "a / b = "; a / b
PRINTLN "a ^ b = "; a ^ b
PRINTLN ""
PRINTLN "--- Advanced Math ---"
PRINTLN "sqr(a) = "; sqr(a)
PRINTLN "abs(-a) = "; abs(-a)
PRINTLN "exp(1) = "; exp(1)
PRINTLN "ln(a) = "; ln(a)
PRINTLN "log10(100) = "; log10(100)
PRINTLN ""
PRINTLN "--- Trigonometry (radians) ---"
pi = 3.14159265358979
PRINTLN "sin(pi/2) = "; sin(pi/2)
PRINTLN "cos(pi) = "; cos(pi)
PRINTLN "tan(pi/4) = "; tan(pi/4)
PRINTLN ""
PRINTLN "--- Rounding ---"
x = 3.7
PRINTLN "x = "; x
PRINTLN "round(x) = "; round(x)
PRINTLN "int(x) = "; int(x)
PRINTLN "fix(x) = "; fix(x)
PRINTLN "frac(x) = "; frac(x)
PRINTLN ""
PRINTLN "=========================================="
