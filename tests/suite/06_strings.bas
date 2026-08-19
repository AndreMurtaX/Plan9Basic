rem ---------------------------------------------------------------
rem StrLib plus the string indexing sugar.
rem s$[n]  -> line n   (0-based)
rem s$[[n]] -> character n
rem ---------------------------------------------------------------

test_case("str/case")
assert_eq(ucase$("Plan9Basic"), "PLAN9BASIC")
assert_eq(lcase$("Plan9Basic"), "plan9basic")
assert_eq(ucase$(""), "")

test_case("str/length")
assert_eq(len("abcde"), 5)
assert_eq(len(""), 0)

test_case("str/left-right")
assert_eq(left$("abcdef", 3), "abc")
assert_eq(right$("abcdef", 3), "def")
assert_eq(left$("ab", 10), "ab", "asking for more than exists")

test_case("str/trim")
assert_eq(trim$("  x  "), "x")
assert_eq(ltrim$("  x"), "x")
assert_eq(rtrim$("x  "), "x")
assert_eq(trim$(""), "")

test_case("str/reverse")
assert_eq(reverse$("abc"), "cba")
assert_eq(reverse$(""), "")

test_case("str/char-codes")
assert_eq(asc("A"), 65)
assert_eq(chr$(65), "A")
assert_eq(chr$(asc("z")), "z")

test_case("str/radix")
assert_eq(hex$(255), "FF")
assert_eq(bin$(10), "1010")
assert_eq(oct$(8), "10")

test_case("str/numeric-conversion")
assert_eq(val("3.5"), 3.5)
assert_eq(val("42"), 42)
assert_eq(stri$(42), "42", "stri$ is locale invariant")
assert_eq(stri$(3.5), "3.5")

test_case("str/padding")
assert_eq(space$(3), "   ")
assert_eq(len(space$(5)), 5)

test_case("str/replace")
assert_eq(replacestr$("aXbXc", "X", "-"), "a-b-c")
assert_eq(replacestr$("abc", "z", "-"), "abc", "no match leaves it alone")

test_case("str/search")
assert_eq(countstr("banana", "an"), 2)
assert_eq(countstr("abc", "z"), 0)

ok = 0
if containsstr("hello world", "lo wo") <> 0 then ok = 1
assert_eq(ok, 1, "containsstr finds a substring")

rem All six take the text first. Delphi's System.StrUtils is uneven here --
rem ContainsStr(AText, ASubText) but StartsStr(ASubText, AText) -- and StrLib
rem used to pass straight through, so the language inherited the unevenness.
rem The arguments are swapped on the way through now.
ok = 0
if startsstr("hello", "he") <> 0 then ok = 1
assert_eq(ok, 1, "startsstr takes the text first")

ok = 0
if endsstr("hello", "lo") <> 0 then ok = 1
assert_eq(ok, 1, "endsstr takes the text first")

rem The old order now answers false, which is the whole cost of the change:
rem both arguments are strings, so it breaks without a word.
ok = 0
if startsstr("he", "hello") <> 0 then ok = 1
assert_eq(ok, 0, "the old spelling no longer matches")

ok = 0
if startstext("HELLO", "he") <> 0 then ok = 1
assert_eq(ok, 1, "startstext ignores case, text first")

ok = 0
if endstext("HELLO", "LO") <> 0 then ok = 1
assert_eq(ok, 1, "endstext ignores case, text first")

test_case("str/predicates")
ok = 0
if isnumeric("123") <> 0 then ok = 1
assert_eq(ok, 1, "isnumeric on digits")

ok = 1
if isnumeric("12a") <> 0 then ok = 0
assert_eq(ok, 1, "isnumeric rejects letters")

ok = 0
if isalpha("abc") <> 0 then ok = 1
assert_eq(ok, 1, "isalpha")

test_case("str/mulstring")
assert_eq(mulstring$("ab", 3), "ababab")

test_case("str/char-index")
rem s$[[n]] indexes a character and is 0-based, unlike arrays which are 1-based
s$ = "abcdef"
assert_eq(s$[[0]], "a", "first character")
assert_eq(s$[[5]], "f", "last character")
assert_eq(s$[[2]], "c", "middle character")

test_case("str/line-index")
multi$ = "first" + chr$(10) + "second" + chr$(10) + "third"
assert_eq(multi$[0], "first", "lines are 0-based")
assert_eq(multi$[1], "second")
assert_eq(multi$[2], "third")
assert_eq(count(multi$), 3, "line count")

test_case("str/word")
assert_eq(word$("alpha beta gamma", 2, " "), "beta")
assert_eq(wordcount("alpha beta gamma", " "), 3)

test_case("strings/repeat-and-replace")
rem Pinned because the user guide got all three of these wrong: it documented
rem a string$ that repeats a string, and a replace$ that does not exist.
assert_eq(string$(3, 65), "AAA", "string$ repeats a character by its code")
assert_eq(string$(0, 65), "", "zero repetitions is empty")
assert_eq(replacestr$("Hello", "l", "L"), "HeLLo", "replacestr$ is case sensitive")
assert_eq(replacestr$("Hello", "L", "X"), "Hello", "and so leaves the wrong case alone")
assert_eq(replacetext$("Hello", "L", "X"), "HeXXo", "replacetext$ ignores case")

test_case("strings/instr-family")
rem All three answer the same way: a zero-based position, -1 when absent.
rem The two-argument form used to return 1 for found and 0 for absent, which
rem agreed with neither its own siblings nor its documentation.
assert_eq(instr("Hello World", "World"), 6, "instr finds the position")
assert_eq(instr("Hello", "H"), 0, "zero-based, so the first character is 0")
assert_eq(instr("Hello", "ll"), 2, "and not merely 'found'")
assert_eq(instr("Hello", "zz"), -1, "absent is -1")
assert_eq(instr("Hello World", "World", 1), 6, "the three-argument form agrees")
assert_eq(instr("abcabc", "b", 3), 4, "searching from an offset")
assert_eq(instrrev("abcabc", "b"), 4, "and so does instrrev")
assert_eq(instrrev("abcabc", "zz"), -1, "absent is -1 there too")
