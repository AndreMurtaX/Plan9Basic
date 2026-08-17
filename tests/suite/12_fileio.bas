rem ---------------------------------------------------------------
rem File text I/O. Scratch files go under bin\ , which is ignored by
rem git, and are deleted at the end of the run.
rem ---------------------------------------------------------------

f$ = "bin/p9b_io_a.tmp"
g$ = "bin/p9b_io_b.tmp"

test_case("io/writealltext-roundtrip")
content$ = "hello world"
assert_eq(file_writealltext(f$, content$), 1, "write reports success")
assert_eq(file_readalltext$(f$), content$, "IOUtilsLib preserves the text exactly")

ok = 0
if file_exists(f$) <> 0 then ok = 1
assert_eq(ok, 1, "file exists after writing")

test_case("io/multiline")
multi$ = "line1" + chr$(10) + "line2"
file_writealltext(g$, multi$)
assert_eq(file_readalltext$(g$), multi$, "line breaks survive the round trip")

test_case("io/savetext-appends-a-line-break")
rem Known wart: savetext$/opentext$ go through a TStringList, so the text
rem read back is NOT identical to the text written -- a trailing CRLF is
rem added. file_writealltext$/file_readalltext$ do not have this problem.
rem This test pins the current behaviour so that changing it is a decision
rem rather than an accident.
src$ = "hello world"
savetext$(f$, "utf-8", src$)
back$ = opentext$(f$, "utf-8")
assert_eq(len(src$), 11, "source length")
assert_eq(len(back$), 13, "two extra characters come back")
assert_eq(back$, src$ + chr$(13) + chr$(10), "the extra characters are CRLF")

test_case("io/delete")
file_delete(f$)
file_delete(g$)
ok = 1
if file_exists(f$) <> 0 then ok = 0
assert_eq(ok, 1, "deleted file is gone")
ok = 1
if file_exists(g$) <> 0 then ok = 0
assert_eq(ok, 1, "second file is gone too")

test_case("io/path-helpers")
assert_eq(path_getfilename$("a/b/c.txt"), "c.txt")
assert_eq(path_getextension$("a/b/c.txt"), ".txt")
assert_eq(path_getfilenamenoext$("a/b/c.txt"), "c")
assert_eq(path_changeextension$("a/b/c.txt", ".bas"), "a/b/c.bas")
