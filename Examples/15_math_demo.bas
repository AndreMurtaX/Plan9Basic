' =============================================
' Plan9Basic - Math Functions Demo
' Comprehensive mathematical functions showcase
' =============================================
PRINTLN "=========================================="
PRINTLN "       MATH FUNCTIONS DEMO"
PRINTLN "=========================================="
PRINTLN ""
pi = 3.14159265358979
PRINTLN "=== Trigonometric Functions (degrees) ==="
PRINTLN ""
PRINTLN "Angle   Sin        Cos        Tan"
PRINTLN "------  ---------  ---------  ---------"
FOR deg = 0 TO 90 STEP 15
  rad = degtorad(deg)
  s = sin(rad)
  c = cos(rad)
  ' Avoid tan(90) which is undefined
  IF deg = 90 THEN
    t$ = "undefined"
  ELSE
    t$ = str$(tan(rad))
  ENDIF
  PRINTLN deg; "     "; s; "  "; c; "  "; t$
NEXT
PRINTLN ""
PRINTLN "=== Inverse Trigonometric ==="
PRINTLN ""
PRINTLN "asin(0.5) = "; radtodeg(asin(0.5)); " degrees"
PRINTLN "acos(0.5) = "; radtodeg(acos(0.5)); " degrees"
PRINTLN "atan(1) = "; radtodeg(atan(1)); " degrees"
PRINTLN ""
PRINTLN "=== Hyperbolic Functions ==="
PRINTLN ""
FOR x = 0 TO 2
  PRINTLN "x="; x; ": sinh="; sinh(x); " cosh="; cosh(x); " tanh="; tanh(x)
NEXT
PRINTLN ""
PRINTLN "=== Powers and Roots ==="
PRINTLN ""
PRINTLN "2^10 = "; 2^10
PRINTLN "10^3 = "; 10^3
PRINTLN "sqr(2) = "; sqr(2)
PRINTLN "sqr(144) = "; sqr(144)
PRINTLN ""
PRINTLN "=== Logarithms ==="
PRINTLN ""
PRINTLN "e = exp(1) = "; exp(1)
PRINTLN "ln(e) = "; ln(exp(1))
PRINTLN "ln(10) = "; ln(10)
PRINTLN "log10(10) = "; log10(10)
PRINTLN "log10(1000) = "; log10(1000)
PRINTLN "log2(2) = "; log2(2)
PRINTLN "log2(256) = "; log2(256)
PRINTLN ""
PRINTLN "=== Rounding Functions ==="
PRINTLN ""
PRINTLN "Value    round    int      fix      frac     cint"
PRINTLN "-------  -------  -------  -------  -------  -------"
DATA 3.2, 3.7, -3.2, -3.7, 0.5
FOR i = 1 TO 5
  READ x
  PRINTLN x; "   "; round(x); "    "; int(x); "    "; fix(x); "    "; frac(x); "    "; cint(x)
NEXT
PRINTLN ""
PRINTLN "=== Min/Max/Abs/Sign ==="
PRINTLN ""
PRINTLN "min(10, 5) = "; min(10, 5)
PRINTLN "max(10, 5) = "; max(10, 5)
PRINTLN "abs(-42) = "; abs(-42)
PRINTLN "abs(42) = "; abs(42)
PRINTLN "sgn(-100) = "; sgn(-100)
PRINTLN "sgn(0) = "; sgn(0)
PRINTLN "sgn(100) = "; sgn(100)
PRINTLN ""
PRINTLN "=== Compare Values ==="
PRINTLN ""
PRINTLN "cmpval(5, 5) = "; cmpval(5, 5); " (equal)"
PRINTLN "cmpval(3, 7) = "; cmpval(3, 7); " (less)"
PRINTLN "cmpval(9, 2) = "; cmpval(9, 2); " (greater)"
PRINTLN ""
PRINTLN "=========================================="
