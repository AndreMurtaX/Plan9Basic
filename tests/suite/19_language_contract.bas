rem ---------------------------------------------------------------
rem The language contract of ANALYSIS section 4, run rather than read.
rem
rem That section tells somebody what they may write in a .bas file:
rem which constructs exist, how a string is indexed, where an array
rem starts. Nothing executed any of it. It was checked by hand on
rem 2026-08-19 and every sentence held -- which is worth having, and
rem is worth rather more once something re-checks it.
rem
rem The half that says what does NOT compile lives in tests/negative/,
rem because a rejection cannot be asserted from inside the language.
rem ---------------------------------------------------------------

test_case("contract/a-string-indexes-lines-from-zero")
rem s$[n] is the n-th LINE, counting from zero -- not the n-th
rem character, which is the mistake the notation invites.
let nl$ = chr$(10)
let s$ = "alpha" + nl$ + "beta" + nl$ + "gamma"
assert_eq(s$[0], "alpha", "s$[0] is the first line")
assert_eq(s$[1], "beta", "s$[1] is the second")
assert_eq(s$[2], "gamma", "s$[2] is the third")

test_case("contract/double-brackets-index-characters-from-zero")
let t$ = "abcd"
assert_eq(t$[[0]], "a", "t$[[0]] is the first character")
assert_eq(t$[[3]], "d", "and t$[[3]] the fourth")

test_case("contract/arrays-start-at-one")
rem The two notations above start at zero and this one does not,
rem which is the single most likely thing to be misremembered.
let a# = dim#(3)
a#[1] = 11
a#[2] = 22
a#[3] = 33
assert_eq(a#[1], 11, "the first element is at 1")
assert_eq(a#[3], 33, "and the last at the declared size")

test_case("contract/a-quote-inside-a-literal-is-escaped-with-a-backslash")
let q$ = "he said \"hi\""
assert_eq(len(q$), 12, "the escapes produce one character each")
assert_eq(q$[[8]], chr$(34), "and that character is a quote")

test_case("contract/on-goto-picks-the-nth-label")
rem Documented in section 4 and exercised by nothing until now.
let hit = 0
let k = 2
on k goto lblOne, lblTwo, lblThree
lblOne:
  hit = 1
  goto afterGoto
lblTwo:
  hit = 2
  goto afterGoto
lblThree:
  hit = 3
afterGoto:
assert_eq(hit, 2, "on k goto took the second branch")

test_case("contract/on-gosub-calls-the-nth-routine-and-returns")
let acc = 0
let j = 3
on j gosub subA, subB, subC
assert_eq(acc, 30, "on j gosub called the third routine")
goto afterSubs
subA:
  acc = 10
  return
subB:
  acc = 20
  return
subC:
  acc = 30
  return
afterSubs:
