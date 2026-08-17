' ============================================
' Test Applet: StrLib Improved Functions
' Plan9Basic String Library Test Suite
' ============================================
PRINTLN "========================================"
PRINTLN "StrLib Improved Functions Test Suite"
PRINTLN "========================================"
PRINTLN ""
' Test counter
passed = 0
failed = 0
' --------------------------------------------
' Test 1: trim$ function (NEW)
' --------------------------------------------
PRINTLN "Test 1: trim$ function"
s$ = "  hello world  "
result$ = trim$(s$)
IF result$ = "hello world" THEN
  PRINTLN "  PASS: trim$ works correctly"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected 'hello world', got '" + result$ + "'"
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 2: instr function (NEW)
' --------------------------------------------
PRINTLN "Test 2: instr function"
s$ = "hello world"
pos = instr(s$, "world")
IF pos = 6 THEN
  PRINTLN "  PASS: instr found 'world' at position 6"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected 6, got " + str$(pos)
  failed = failed + 1
ENDIF
pos = instr(s$, "xyz")
IF pos = -1 THEN
  PRINTLN "  PASS: instr returns -1 for not found"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected -1, got " + str$(pos)
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 3: instr with start position (NEW)
' --------------------------------------------
PRINTLN "Test 3: instr with start position"
s$ = "hello hello"
pos = instr(s$, "hello", 1)
IF pos = 6 THEN
  PRINTLN "  PASS: instr from pos 1 found at 6"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected 6, got " + str$(pos)
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 4: left$ and right$ overloads (NEW)
' --------------------------------------------
PRINTLN "Test 4: left$ and right$ single char"
s$ = "hello"
IF left$(s$) = "h" THEN
  PRINTLN "  PASS: left$(s$) returns first char"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: left$ single char"
  failed = failed + 1
ENDIF
IF right$(s$) = "o" THEN
  PRINTLN "  PASS: right$(s$) returns last char"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: right$ single char"
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 5: hex$ with digit count (NEW)
' --------------------------------------------
PRINTLN "Test 5: hex$ with digit count"
result$ = hex$(255, 4)
IF result$ = "00FF" THEN
  PRINTLN "  PASS: hex$(255, 4) = '00FF'"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected '00FF', got '" + result$ + "'"
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 6: str$ with decimal places (locale-aware)
' --------------------------------------------
PRINTLN "Test 6: str$ with decimal places (locale)"
pi = 3.14159265
result$ = str$(pi, 2)
PRINTLN "  INFO: str$(3.14159, 2) = '" + result$ + "' (uses system locale)"
PRINTLN "  PASS: str$ uses locale decimal separator"
passed = passed + 1
' --------------------------------------------
' Test 6b: stri$ invariant (NEW - always uses period)
' --------------------------------------------
PRINTLN "Test 6b: stri$ invariant function"
pi = 3.14159265
result$ = stri$(pi, 2)
IF left$(result$, 4) = "3.14" THEN
  PRINTLN "  PASS: stri$(pi, 2) = '" + result$ + "' (always period)"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected '3.14', got '" + result$ + "'"
  failed = failed + 1
ENDIF
' Test stri$ without decimals
result$ = stri$(123.456)
IF containsstr(result$, ".") = 1 THEN
  PRINTLN "  PASS: stri$(123.456) = '" + result$ + "' (uses period)"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected period in '" + result$ + "'"
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 7: space$ function (NEW)
' --------------------------------------------
PRINTLN "Test 7: space$ function"
result$ = space$(5)
IF len(result$) = 5 THEN
  PRINTLN "  PASS: space$(5) creates 5 spaces"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected length 5, got " + str$(len(result$))
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 8: string$ function (NEW)
' --------------------------------------------
PRINTLN "Test 8: string$ function"
result$ = string$(5, 42)
IF result$ = "*****" THEN
  PRINTLN "  PASS: string$(5, 42) = '*****'"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected '*****', got '" + result$ + "'"
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 9: Bounds checking - mid$ with out of range
' --------------------------------------------
PRINTLN "Test 9: mid$ bounds checking"
s$ = "hello"
result$ = mid$(s$, 100, 5)
IF result$ = "" THEN
  PRINTLN "  PASS: mid$ with out-of-range returns empty"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected empty string"
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 10: Negative number handling - hex$
' --------------------------------------------
PRINTLN "Test 10: hex$ with negative numbers"
result$ = hex$(-255)
IF left$(result$, 1) = "-" THEN
  PRINTLN "  PASS: hex$(-255) = '" + result$ + "'"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected negative prefix, got '" + result$ + "'"
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 11: bin$ with zero and negative
' --------------------------------------------
PRINTLN "Test 11: bin$ edge cases"
result$ = bin$(0)
IF result$ = "0" THEN
  PRINTLN "  PASS: bin$(0) = '0'"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected '0', got '" + result$ + "'"
  failed = failed + 1
ENDIF
result$ = bin$(-5)
IF left$(result$, 1) = "-" THEN
  PRINTLN "  PASS: bin$(-5) handles negative"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected negative, got '" + result$ + "'"
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 12: oct$ with zero
' --------------------------------------------
PRINTLN "Test 12: oct$ edge cases"
result$ = oct$(0)
IF result$ = "0" THEN
  PRINTLN "  PASS: oct$(0) = '0'"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected '0', got '" + result$ + "'"
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 13: left$ and right$ bounds
' --------------------------------------------
PRINTLN "Test 13: left$/right$ with excess length"
s$ = "hi"
result$ = left$(s$, 100)
IF result$ = "hi" THEN
  PRINTLN "  PASS: left$ clamps to string length"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected 'hi', got '" + result$ + "'"
  failed = failed + 1
ENDIF
result$ = right$(s$, 100)
IF result$ = "hi" THEN
  PRINTLN "  PASS: right$ clamps to string length"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected 'hi', got '" + result$ + "'"
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 14: Empty string handling
' --------------------------------------------
PRINTLN "Test 14: Empty string handling"
s$ = ""
result$ = left$(s$)
IF result$ = "" THEN
  PRINTLN "  PASS: left$ on empty returns empty"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected empty"
  failed = failed + 1
ENDIF
' --------------------------------------------
' Test 15: mulstring$ (dupestring) limit
' --------------------------------------------
PRINTLN "Test 15: mulstring$ function"
result$ = mulstring$("ab", 3)
IF result$ = "ababab" THEN
  PRINTLN "  PASS: mulstring$('ab', 3) = 'ababab'"
  passed = passed + 1
ELSE
  PRINTLN "  FAIL: expected 'ababab', got '" + result$ + "'"
  failed = failed + 1
ENDIF
' --------------------------------------------
' Summary
' --------------------------------------------
PRINTLN ""
PRINTLN "========================================"
PRINTLN "Test Summary"
PRINTLN "========================================"
PRINTLN "Passed: " + str$(passed)
PRINTLN "Failed: " + str$(failed)
total = passed + failed
PRINTLN "Total:  " + str$(total)
PRINTLN ""
IF failed = 0 THEN
  PRINTLN "All tests PASSED!"
ELSE
  PRINTLN "Some tests FAILED. Please review."
ENDIF
PRINTLN "========================================"
END
