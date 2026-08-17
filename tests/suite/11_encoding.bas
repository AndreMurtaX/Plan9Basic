rem ---------------------------------------------------------------
rem Base64Lib, GzipLib and RegexLib
rem ---------------------------------------------------------------

test_case("base64/roundtrip")
src$ = "Plan9Basic"
enc$ = b64encode$(src$)
assert_eq(b64decode$(enc$), src$, "encode then decode is identity")
assert_eq(b64encode$(""), "", "empty string")

test_case("base64/known-vector")
assert_eq(b64encode$("Man"), "TWFu")
assert_eq(b64decode$("TWFu"), "Man")

test_case("base64/validation")
ok = 0
if b64valid("TWFu") <> 0 then ok = 1
assert_eq(ok, 1, "valid base64")

test_case("base64/url-safe")
u$ = b64urlencode$("Plan9Basic??")
assert_eq(b64urldecode$(u$), "Plan9Basic??", "url-safe round trip")

test_case("gzip/roundtrip")
plain$ = "the quick brown fox jumps over the lazy dog"
z$ = gzip$(plain$)
assert_eq(gunzip$(z$), plain$, "compress then decompress is identity")

test_case("gzip/compresses-repetitive-data")
big$ = mulstring$("abcdefgh", 200)
cz$ = gzip$(big$)
assert_eq(gunzip$(cz$), big$, "round trip on larger input")
ok = 0
if len(cz$) < len(big$) then ok = 1
assert_eq(ok, 1, "repetitive input gets smaller")

rem Every RegexLib function takes the pattern FIRST and the subject second.
test_case("regex/match")
ok = 0
if regex_match("[a-z]+[0-9]+", "hello123") <> 0 then ok = 1
assert_eq(ok, 1, "pattern matches")

ok = 1
if regex_match("[0-9]+$", "hello") <> 0 then ok = 0
assert_eq(ok, 1, "pattern does not match")

test_case("regex/validity")
ok = 0
if regex_isvalid("[a-z]+") <> 0 then ok = 1
assert_eq(ok, 1, "well formed pattern")

ok = 1
if regex_isvalid("[a-z") <> 0 then ok = 0
assert_eq(ok, 1, "unclosed character class is rejected")

ok = 1
if regex_isvalid("(unclosed") <> 0 then ok = 0
assert_eq(ok, 1, "unclosed group is rejected")

rem an empty pattern is legal regex and must not be reported as malformed
ok = 0
if regex_isvalid("") <> 0 then ok = 1
assert_eq(ok, 1, "empty pattern is valid")

assert_eq(regex_error$("[a-z]+"), "", "no message for a valid pattern")
assert_eq(regex_error$(""), "", "no message for the empty pattern")
ok = 0
if len(regex_error$("(unclosed")) > 0 then ok = 1
assert_eq(ok, 1, "a malformed pattern reports a message")

test_case("regex/find")
assert_eq(regex_find$("[0-9]+", "order 12345 shipped"), "12345")
assert_eq(regex_count("[0-9]", "a1b2c3"), 3)

test_case("regex/replace")
assert_eq(regex_replace$("[0-9]", "a1b2c3", "#"), "a#b#c#")
assert_eq(regex_replacefirst$("[0-9]", "a1b2c3", "#"), "a#b2c3")

test_case("regex/groups")
assert_eq(regex_group$("([0-9]{4})-([0-9]{2})-([0-9]{2})", "2026-08-17", 1), "2026")
assert_eq(regex_group$("([0-9]{4})-([0-9]{2})-([0-9]{2})", "2026-08-17", 2), "08")

test_case("regex/escape")
lit$ = regex_escape$("a.b")
ok = 0
if regex_matchfull(lit$, "a.b") <> 0 then ok = 1
assert_eq(ok, 1, "escaped text matches literally")

ok = 1
if regex_matchfull(lit$, "axb") <> 0 then ok = 0
assert_eq(ok, 1, "escaped dot is not a wildcard")
