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

rem Argument order is NOT uniform across these three, because StrLib passes
rem straight through to Delphi's System.StrUtils, which is itself uneven:
rem   containsstr(text$, part$)   -- text first
rem   startsstr(prefix$, text$)   -- part first
rem   endsstr(suffix$, text$)     -- part first
ok = 0
if startsstr("he", "hello") <> 0 then ok = 1
assert_eq(ok, 1, "startsstr takes the prefix first")

ok = 0
if endsstr("lo", "hello") <> 0 then ok = 1
assert_eq(ok, 1, "endsstr takes the suffix first")

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
