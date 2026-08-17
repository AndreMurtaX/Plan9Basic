' ============================================================================
' RegexLib Test Suite for Plan9Basic
' ============================================================================
' This program tests all 28 functions in the RegexLib library.
' Each test displays PASS or FAIL status.
' ============================================================================
' Test counters
LET passed = 0
LET failed = 0
LET total = 0
' Helper function to report test results
FUNCTION reportTest(name$, result) LOCAL status$
  total = total + 1
  IF result = 1 THEN
    passed = passed + 1
    status$ = "PASS"
  ELSE
    failed = failed + 1
    status$ = "FAIL"
  END IF
  PRINTLN "[" + status$ + "] " + name$
  RETURN result
END FUNCTION
PRINTLN "============================================"
PRINTLN "RegexLib Test Suite"
PRINTLN "============================================"
PRINTLN ""
' ============================================================================
' TEST GROUP 1: Validation Functions
' ============================================================================
PRINTLN "--- Validation Functions ---"
PRINTLN ""
' Test regex_isvalid()
IF regex_isvalid("[a-z]+") = 1 THEN
  r = reportTest("regex_isvalid: valid pattern", 1)
ELSE
  r = reportTest("regex_isvalid: valid pattern", 0)
END IF
' Note: Plan9Basic RegEx (PCRE) is very lenient
' Using a quantifier at start with nothing to quantify - this must fail
IF regex_isvalid("*test") = 0 THEN
  r = reportTest("regex_isvalid: invalid pattern", 1)
ELSE
  r = reportTest("regex_isvalid: invalid pattern", 0)
END IF
IF regex_isvalid("") = 1 THEN
  r = reportTest("regex_isvalid: empty pattern", 1)
ELSE
  r = reportTest("regex_isvalid: empty pattern", 0)
END IF
IF regex_isvalid("^[\w.-]+@[\w.-]+\.\w+$") = 1 THEN
  r = reportTest("regex_isvalid: complex pattern", 1)
ELSE
  r = reportTest("regex_isvalid: complex pattern", 0)
END IF
' Test regex_error$()
IF regex_error$("[a-z]+") = "" THEN
  r = reportTest("regex_error$: valid pattern returns empty", 1)
ELSE
  r = reportTest("regex_error$: valid pattern returns empty", 0)
END IF
IF regex_error$("*test") <> "" THEN
  r = reportTest("regex_error$: invalid pattern returns message", 1)
ELSE
  r = reportTest("regex_error$: invalid pattern returns message", 0)
END IF
PRINTLN ""
' ============================================================================
' TEST GROUP 2: Basic Matching Functions
' ============================================================================
PRINTLN "--- Basic Matching Functions ---"
PRINTLN ""
' Test regex_match() - 2 params
IF regex_match("\d+", "abc123def") = 1 THEN
  r = reportTest("regex_match: finds digits", 1)
ELSE
  r = reportTest("regex_match: finds digits", 0)
END IF
IF regex_match("\d+", "abcdef") = 0 THEN
  r = reportTest("regex_match: no match returns 0", 1)
ELSE
  r = reportTest("regex_match: no match returns 0", 0)
END IF
IF regex_match("hello", "say hello world") = 1 THEN
  r = reportTest("regex_match: finds word", 1)
ELSE
  r = reportTest("regex_match: finds word", 0)
END IF
IF regex_match("hello", "HELLO") = 0 THEN
  r = reportTest("regex_match: case sensitive by default", 1)
ELSE
  r = reportTest("regex_match: case sensitive by default", 0)
END IF
' Test regex_match() - 3 params (with options)
IF regex_match("hello", "HELLO WORLD", 1) = 1 THEN
  r = reportTest("regex_match: ignore case option", 1)
ELSE
  r = reportTest("regex_match: ignore case option", 0)
END IF
IF regex_match("^world", "hello" + chr$(10) + "world", 2) = 1 THEN
  r = reportTest("regex_match: multiline option", 1)
ELSE
  r = reportTest("regex_match: multiline option", 0)
END IF
' Test regex_matchfull() - 2 params
IF regex_matchfull("^\d+$", "12345") = 1 THEN
  r = reportTest("regex_matchfull: full match", 1)
ELSE
  r = reportTest("regex_matchfull: full match", 0)
END IF
IF regex_matchfull("^\d+$", "abc123") = 0 THEN
  r = reportTest("regex_matchfull: partial match fails", 1)
ELSE
  r = reportTest("regex_matchfull: partial match fails", 0)
END IF
IF regex_matchfull("hello", "hello") = 1 THEN
  r = reportTest("regex_matchfull: exact string", 1)
ELSE
  r = reportTest("regex_matchfull: exact string", 0)
END IF
IF regex_matchfull("hello", "hello world") = 0 THEN
  r = reportTest("regex_matchfull: substring fails", 1)
ELSE
  r = reportTest("regex_matchfull: substring fails", 0)
END IF
' Test regex_matchfull() - 3 params (with options)
IF regex_matchfull("hello", "HELLO", 1) = 1 THEN
  r = reportTest("regex_matchfull: ignore case", 1)
ELSE
  r = reportTest("regex_matchfull: ignore case", 0)
END IF
PRINTLN ""
' ============================================================================
' TEST GROUP 3: Find/Search Functions
' ============================================================================
PRINTLN "--- Find/Search Functions ---"
PRINTLN ""
' Test regex_find$() - 2 params
IF regex_find$("\d+", "abc123def456") = "123" THEN
  r = reportTest("regex_find$: finds first number", 1)
ELSE
  r = reportTest("regex_find$: finds first number", 0)
END IF
IF regex_find$("\d+", "abcdef") = "" THEN
  r = reportTest("regex_find$: no match returns empty", 1)
ELSE
  r = reportTest("regex_find$: no match returns empty", 0)
END IF
IF regex_find$("\w+", "  hello world") = "hello" THEN
  r = reportTest("regex_find$: finds word", 1)
ELSE
  r = reportTest("regex_find$: finds word", 0)
END IF
' Test regex_find$() - 3 params (with options)
IF regex_find$("hello", "say HELLO there", 1) = "HELLO" THEN
  r = reportTest("regex_find$: ignore case", 1)
ELSE
  r = reportTest("regex_find$: ignore case", 0)
END IF
' Test regex_findpos() - 2 params
IF regex_findpos("\d", "abc123") = 4 THEN
  r = reportTest("regex_findpos: finds position (1-based)", 1)
ELSE
  r = reportTest("regex_findpos: finds position (1-based)", 0)
END IF
IF regex_findpos("\d", "abcdef") = 0 THEN
  r = reportTest("regex_findpos: no match returns 0", 1)
ELSE
  r = reportTest("regex_findpos: no match returns 0", 0)
END IF
IF regex_findpos("hello", "hello world") = 1 THEN
  r = reportTest("regex_findpos: start of string", 1)
ELSE
  r = reportTest("regex_findpos: start of string", 0)
END IF
' Test regex_findpos() - 3 params (with options)
IF regex_findpos("world", "HELLO WORLD", 1) = 7 THEN
  r = reportTest("regex_findpos: ignore case", 1)
ELSE
  r = reportTest("regex_findpos: ignore case", 0)
END IF
' Test regex_findlen() - 2 params
IF regex_findlen("\d+", "abc123def") = 3 THEN
  r = reportTest("regex_findlen: length of match", 1)
ELSE
  r = reportTest("regex_findlen: length of match", 0)
END IF
IF regex_findlen("\d+", "abcdef") = 0 THEN
  r = reportTest("regex_findlen: no match returns 0", 1)
ELSE
  r = reportTest("regex_findlen: no match returns 0", 0)
END IF
IF regex_findlen("\d", "abc1def") = 1 THEN
  r = reportTest("regex_findlen: single char", 1)
ELSE
  r = reportTest("regex_findlen: single char", 0)
END IF
' Test regex_findlen() - 3 params (with options)
IF regex_findlen("[a-z]+", "HELLO", 1) = 5 THEN
  r = reportTest("regex_findlen: with options", 1)
ELSE
  r = reportTest("regex_findlen: with options", 0)
END IF
PRINTLN ""
' ============================================================================
' TEST GROUP 4: Find All Functions
' ============================================================================
PRINTLN "--- Find All Functions ---"
PRINTLN ""
' Test regex_findall#() - 2 params
matches# = regex_findall#("\d+", "a1b22c333")
IF strings_count(matches#) = 3 THEN
  r = reportTest("regex_findall#: correct count", 1)
ELSE
  r = reportTest("regex_findall#: correct count", 0)
END IF
IF strings_strings$(matches#, 0) = "1" THEN
  r = reportTest("regex_findall#: first match", 1)
ELSE
  r = reportTest("regex_findall#: first match", 0)
END IF
IF strings_strings$(matches#, 1) = "22" THEN
  r = reportTest("regex_findall#: second match", 1)
ELSE
  r = reportTest("regex_findall#: second match", 0)
END IF
IF strings_strings$(matches#, 2) = "333" THEN
  r = reportTest("regex_findall#: third match", 1)
ELSE
  r = reportTest("regex_findall#: third match", 0)
END IF
matches# = regex_findall#("\d+", "no numbers here")
IF strings_count(matches#) = 0 THEN
  r = reportTest("regex_findall#: no matches returns empty list", 1)
ELSE
  r = reportTest("regex_findall#: no matches returns empty list", 0)
END IF
' Test regex_findall#() - 3 params (with options)
matches# = regex_findall#("[a-z]+", "Hello World Test", 1)
IF strings_count(matches#) = 3 THEN
  r = reportTest("regex_findall#: ignore case", 1)
ELSE
  r = reportTest("regex_findall#: ignore case", 0)
END IF
' Test regex_count() - 2 params
IF regex_count("\d", "a1b2c3d4") = 4 THEN
  r = reportTest("regex_count: counts matches", 1)
ELSE
  r = reportTest("regex_count: counts matches", 0)
END IF
IF regex_count("\d", "abcd") = 0 THEN
  r = reportTest("regex_count: no matches returns 0", 1)
ELSE
  r = reportTest("regex_count: no matches returns 0", 0)
END IF
IF regex_count("\w+", "one two three") = 3 THEN
  r = reportTest("regex_count: words", 1)
ELSE
  r = reportTest("regex_count: words", 0)
END IF
' Test regex_count() - 3 params (with options)
IF regex_count("[aeiou]", "HELLO", 1) = 2 THEN
  r = reportTest("regex_count: ignore case vowels", 1)
ELSE
  r = reportTest("regex_count: ignore case vowels", 0)
END IF
PRINTLN ""
' ============================================================================
' TEST GROUP 5: Replace Functions
' ============================================================================
PRINTLN "--- Replace Functions ---"
PRINTLN ""
' Test regex_replace$() - 3 params
IF regex_replace$("\d", "a1b2c3", "X") = "aXbXcX" THEN
  r = reportTest("regex_replace$: replace all digits", 1)
ELSE
  r = reportTest("regex_replace$: replace all digits", 0)
END IF
IF regex_replace$("\s+", "hello   world", " ") = "hello world" THEN
  r = reportTest("regex_replace$: collapse spaces", 1)
ELSE
  r = reportTest("regex_replace$: collapse spaces", 0)
END IF
IF regex_replace$("\d", "abc", "X") = "abc" THEN
  r = reportTest("regex_replace$: no match unchanged", 1)
ELSE
  r = reportTest("regex_replace$: no match unchanged", 0)
END IF
' Test regex_replace$() - 4 params (with options)
IF regex_replace$("hello", "HELLO world", "hi", 1) = "hi world" THEN
  r = reportTest("regex_replace$: ignore case", 1)
ELSE
  r = reportTest("regex_replace$: ignore case", 0)
END IF
' Test capture group replacement
IF regex_replace$("(\w+) (\w+)", "John Smith", "$2, $1") = "Smith, John" THEN
  r = reportTest("regex_replace$: swap with groups", 1)
ELSE
  r = reportTest("regex_replace$: swap with groups", 0)
END IF
' Test regex_replacefirst$() - 3 params
IF regex_replacefirst$("\d", "a1b2c3", "X") = "aXb2c3" THEN
  r = reportTest("regex_replacefirst$: only first", 1)
ELSE
  r = reportTest("regex_replacefirst$: only first", 0)
END IF
IF regex_replacefirst$("\d", "abc", "X") = "abc" THEN
  r = reportTest("regex_replacefirst$: no match unchanged", 1)
ELSE
  r = reportTest("regex_replacefirst$: no match unchanged", 0)
END IF
' Test regex_replacefirst$() - 4 params (with options)
IF regex_replacefirst$("a", "ABCABC", "X", 1) = "XBCABC" THEN
  r = reportTest("regex_replacefirst$: ignore case", 1)
ELSE
  r = reportTest("regex_replacefirst$: ignore case", 0)
END IF
PRINTLN ""
' ============================================================================
' TEST GROUP 6: Split Functions
' ============================================================================
PRINTLN "--- Split Functions ---"
PRINTLN ""
' Test regex_split#() - 2 params
parts# = regex_split#(",", "a,b,c")
IF strings_count(parts#) = 3 THEN
  r = reportTest("regex_split#: simple split count", 1)
ELSE
  r = reportTest("regex_split#: simple split count", 0)
END IF
IF strings_strings$(parts#, 0) = "a" THEN
  r = reportTest("regex_split#: first part", 1)
ELSE
  r = reportTest("regex_split#: first part", 0)
END IF
IF strings_strings$(parts#, 1) = "b" THEN
  r = reportTest("regex_split#: second part", 1)
ELSE
  r = reportTest("regex_split#: second part", 0)
END IF
IF strings_strings$(parts#, 2) = "c" THEN
  r = reportTest("regex_split#: third part", 1)
ELSE
  r = reportTest("regex_split#: third part", 0)
END IF
parts# = regex_split#("\s+", "hello   world  test")
IF strings_count(parts#) = 3 THEN
  r = reportTest("regex_split#: whitespace split", 1)
ELSE
  r = reportTest("regex_split#: whitespace split", 0)
END IF
parts# = regex_split#("[,;]", "a,b;c")
IF strings_count(parts#) = 3 THEN
  r = reportTest("regex_split#: multiple delimiters", 1)
ELSE
  r = reportTest("regex_split#: multiple delimiters", 0)
END IF
' Test regex_split#() - 3 params (with options)
parts# = regex_split#("x", "aXbXc", 1)
IF strings_count(parts#) = 3 THEN
  r = reportTest("regex_split#: ignore case", 1)
ELSE
  r = reportTest("regex_split#: ignore case", 0)
END IF
PRINTLN ""
' ============================================================================
' TEST GROUP 7: Group/Capture Functions
' ============================================================================
PRINTLN "--- Group/Capture Functions ---"
PRINTLN ""
' Test regex_groups#() - 2 params
groups# = regex_groups#("(\d{4})-(\d{2})-(\d{2})", "Date: 2025-01-03")
IF strings_count(groups#) = 4 THEN
  r = reportTest("regex_groups#: correct count", 1)
ELSE
  r = reportTest("regex_groups#: correct count", 0)
END IF
IF strings_strings$(groups#, 0) = "2025-01-03" THEN
  r = reportTest("regex_groups#: full match (index 0)", 1)
ELSE
  r = reportTest("regex_groups#: full match (index 0)", 0)
END IF
IF strings_strings$(groups#, 1) = "2025" THEN
  r = reportTest("regex_groups#: group 1 (year)", 1)
ELSE
  r = reportTest("regex_groups#: group 1 (year)", 0)
END IF
IF strings_strings$(groups#, 2) = "01" THEN
  r = reportTest("regex_groups#: group 2 (month)", 1)
ELSE
  r = reportTest("regex_groups#: group 2 (month)", 0)
END IF
IF strings_strings$(groups#, 3) = "03" THEN
  r = reportTest("regex_groups#: group 3 (day)", 1)
ELSE
  r = reportTest("regex_groups#: group 3 (day)", 0)
END IF
' Test email parsing
groups# = regex_groups#("(\w+)@(\w+)\.(\w+)", "email: user@example.com")
IF strings_count(groups#) = 4 THEN
  r = reportTest("regex_groups#: email parts count", 1)
ELSE
  r = reportTest("regex_groups#: email parts count", 0)
END IF
IF strings_strings$(groups#, 1) = "user" THEN
  r = reportTest("regex_groups#: email user", 1)
ELSE
  r = reportTest("regex_groups#: email user", 0)
END IF
IF strings_strings$(groups#, 2) = "example" THEN
  r = reportTest("regex_groups#: email domain", 1)
ELSE
  r = reportTest("regex_groups#: email domain", 0)
END IF
IF strings_strings$(groups#, 3) = "com" THEN
  r = reportTest("regex_groups#: email tld", 1)
ELSE
  r = reportTest("regex_groups#: email tld", 0)
END IF
' Test no match
groups# = regex_groups#("\d+", "no match here")
IF strings_count(groups#) = 0 THEN
  r = reportTest("regex_groups#: no match returns empty", 1)
ELSE
  r = reportTest("regex_groups#: no match returns empty", 0)
END IF
' Test regex_groups#() - 3 params (with options)
groups# = regex_groups#("([a-z]+)", "HELLO", 1)
IF strings_count(groups#) = 2 THEN
  r = reportTest("regex_groups#: ignore case", 1)
ELSE
  r = reportTest("regex_groups#: ignore case", 0)
END IF
' Test regex_group$() - 3 params
IF regex_group$("(\w+)-(\w+)", "hello-world", 1) = "hello" THEN
  r = reportTest("regex_group$: get first group", 1)
ELSE
  r = reportTest("regex_group$: get first group", 0)
END IF
IF regex_group$("(\w+)-(\w+)", "hello-world", 2) = "world" THEN
  r = reportTest("regex_group$: get second group", 1)
ELSE
  r = reportTest("regex_group$: get second group", 0)
END IF
IF regex_group$("(\w+)-(\w+)", "hello-world", 0) = "hello-world" THEN
  r = reportTest("regex_group$: full match (index 0)", 1)
ELSE
  r = reportTest("regex_group$: full match (index 0)", 0)
END IF
IF regex_group$("(\w+)", "test", 5) = "" THEN
  r = reportTest("regex_group$: out of range returns empty", 1)
ELSE
  r = reportTest("regex_group$: out of range returns empty", 0)
END IF
' Test regex_group$() - 4 params (with options)
IF regex_group$("([a-z]+)", "HELLO", 1, 1) = "HELLO" THEN
  r = reportTest("regex_group$: ignore case", 1)
ELSE
  r = reportTest("regex_group$: ignore case", 0)
END IF
' Test regex_groupcount()
IF regex_groupcount("(\w+)-(\w+)-(\w+)", "a-b-c") = 4 THEN
  r = reportTest("regex_groupcount: 3 groups + full", 1)
ELSE
  r = reportTest("regex_groupcount: 3 groups + full", 0)
END IF
IF regex_groupcount("(\d+)", "123") = 2 THEN
  r = reportTest("regex_groupcount: 1 group + full", 1)
ELSE
  r = reportTest("regex_groupcount: 1 group + full", 0)
END IF
IF regex_groupcount("\d+", "123") = 1 THEN
  r = reportTest("regex_groupcount: no groups", 1)
ELSE
  r = reportTest("regex_groupcount: no groups", 0)
END IF
IF regex_groupcount("\d+", "abc") = 0 THEN
  r = reportTest("regex_groupcount: no match returns 0", 1)
ELSE
  r = reportTest("regex_groupcount: no match returns 0", 0)
END IF
PRINTLN ""
' ============================================================================
' TEST GROUP 8: Utility Functions
' ============================================================================
PRINTLN "--- Utility Functions ---"
PRINTLN ""
' Test regex_escape$()
' Note: Plan9Basic escapes with backslashes, check that escaping occurred
escaped$ = regex_escape$("(2+2)")
IF len(escaped$) > len("(2+2)") THEN
  r = reportTest("regex_escape$: adds escape characters", 1)
ELSE
  r = reportTest("regex_escape$: adds escape characters", 0)
END IF
IF regex_match(regex_escape$("(test)"), "this is (test) here") = 1 THEN
  r = reportTest("regex_escape$: escaped works in match", 1)
ELSE
  r = reportTest("regex_escape$: escaped works in match", 0)
END IF
IF regex_match(regex_escape$("a.b"), "a.b") = 1 THEN
  r = reportTest("regex_escape$: dot escaped matches literal", 1)
ELSE
  r = reportTest("regex_escape$: dot escaped matches literal", 0)
END IF
IF regex_match(regex_escape$("a.b"), "aXb") = 0 THEN
  r = reportTest("regex_escape$: escaped dot no false match", 1)
ELSE
  r = reportTest("regex_escape$: escaped dot no false match", 0)
END IF
PRINTLN ""
' ============================================================================
' TEST SUMMARY
' ============================================================================
PRINTLN "============================================"
PRINTLN "Test Summary"
PRINTLN "============================================"
PRINTLN "Total:  " + str$(total)
PRINTLN "Passed: " + str$(passed)
PRINTLN "Failed: " + str$(failed)
PRINTLN ""
IF failed = 0 THEN
  PRINTLN "*** ALL TESTS PASSED! ***"
ELSE
  PRINTLN "*** SOME TESTS FAILED ***"
END IF
PRINTLN "============================================"
