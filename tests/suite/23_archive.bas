rem ---------------------------------------------------------------
rem ZipLib, GzipLib and Base64Lib. check-coverage.py reported
rem ZipLib 0/15, GzipLib 2/10 and Base64Lib 5/8 -- the file-facing
rem half of all three had never been run.
rem
rem Scratch files go under bin\ , which git ignores.
rem ---------------------------------------------------------------

z$ = "bin/p9b_arc.zip"
src$ = "bin/p9b_arc_src.txt"
out$ = "bin/p9b_arc_out.txt"
gz$ = "bin/p9b_arc.gz"
b64$ = "bin/p9b_arc.b64"

file_delete(z$)
file_delete(src$)
file_delete(out$)
file_delete(gz$)
file_delete(b64$)
file_delete("bin/p9b_b64_out.txt")

rem A payload that actually compresses, so the ratio means something.
body$ = ""
for i = 1 to 40
  body$ = body$ + "the quick brown fox jumps over the lazy dog" + chr$(10)
next i
file_writealltext(src$, body$)

test_case("zip/create-and-add")
a# = zipcreate#(z$)
assert_true(pnttonum(a#), "zipcreate# answers a handle")
zipadd(a#, src$, "doc/source.txt")
zipaddstr(a#, "hello from a string", "doc/inline.txt")
zipclose(a#)
assert_true(file_exists(z$), "the archive is on disk after zipclose")

test_case("zip/read-back")
r# = zipopen#(z$)
assert_true(pnttonum(r#), "zipopen# answers a handle")
assert_eq(zipcount(r#), 2, "both entries are there")
assert_true(zipexists(r#, "doc/inline.txt"), "zipexists finds an entry")
assert_false(zipexists(r#, "doc/absent.txt"), "and does not invent one")
assert_eq(zipread$(r#, "doc/inline.txt"), "hello from a string", "zipread$ answers the content")
assert_eq(zipfilesize(r#, "doc/inline.txt"), 19, "zipfilesize answers the uncompressed size")

names$ = ziplist$(r#)
assert_true(instr(names$, "doc/source.txt") + 1, "ziplist$ names an entry it holds")

test_case("zip/extract")
rem The third argument is a DIRECTORY, not a file: TZipFile.Extract keeps the
rem path the entry has inside the archive. The header comment on n_zipextract
rem says "destination path" and the line above the call says "should be
rem directory"; the second one is what the code does.
zipextract(r#, "doc/inline.txt", "bin/p9b_ex")
assert_eq(file_readalltext$("bin/p9b_ex/doc/inline.txt"), "hello from a string", "zipextract writes the entry under the directory it was given")
zipextractall(r#, "bin/p9b_all")
assert_true(file_exists("bin/p9b_all/doc/source.txt"), "zipextractall recreates the tree")
zipclose(r#)

test_case("zip/quick")
rem The one-call forms, which is what most programs will reach for.
file_delete(z$)
zipquick(src$, z$)
assert_true(file_exists(z$), "zipquick makes an archive from one file")
q# = zipopen#(z$)
assert_eq(zipcount(q#), 1, "holding that one file")
zipclose(q#)
rem zipquick stores the bare file name, so the entry has no directory of its own.
unzipquick(z$, "bin/p9b_unq")
assert_true(file_exists("bin/p9b_unq/p9b_arc_src.txt"), "unzipquick puts it back")

test_case("zip/quick-entry-name")
rem zipquick named its entry with ExtractFileName, which on Windows splits on
rem backslash only. A source written with a forward slash -- which every other
rem file function in this engine accepts -- kept its directory in the entry
rem name, so the archive's shape followed which slash the programmer typed.
file_delete("bin/p9b_sep.zip")
zipquick(src$, "bin/p9b_sep.zip")
sep# = zipopen#("bin/p9b_sep.zip")
assert_eq(ziplist$(sep#), "p9b_arc_src.txt", "a forward-slash source stores the bare name")
zipclose(sep#)
file_delete("bin/p9b_sep.zip")

test_case("zip/error")
rem ziperror carries no $ , so it answers a code and not a message.
bad# = zipopen#("bin/p9b_does_not_exist.zip")
assert_true(ziperror(), "a failed open leaves a non-zero code behind")

test_case("gzip/string-roundtrip")
packed$ = gzip$(body$)
assert_eq(gunzip$(packed$), body$, "gzip$ and gunzip$ are a round trip")
assert_true(len(packed$), "the packed form is not empty")

test_case("gzip/level")
rem gzipex$ takes a compression level. Both ends of the range have to
rem come back as what went in; which one is smaller is zlib's business,
rem not this suite's.
fast$ = gzipex$(body$, 1)
best$ = gzipex$(body$, 9)
assert_eq(gunzip$(fast$), body$, "level 1 round-trips")
assert_eq(gunzip$(best$), body$, "level 9 round-trips")

test_case("gzip/files")
gzipfile(src$, gz$)
assert_true(file_exists(gz$), "gzipfile writes the packed file")
gunzipfile(gz$, out$)
assert_eq(file_readalltext$(out$), body$, "gunzipfile puts the text back")

file_delete(gz$)
gzipfileex(src$, gz$, 9)
assert_true(file_exists(gz$), "gzipfileex writes it at a stated level")

test_case("gzip/sizes")
rem All three take STRINGS, not paths: gzipsize measures the original text,
rem gzipcsize the base64 of the packed form, and gzipratio compares the two.
rem Passing a filename to any of them measures the filename, which is a quiet
rem wrong answer rather than an error.
assert_eq(gzipsize(body$), len(body$), "gzipsize measures the original text")
assert_true(gzipcsize(packed$), "gzipcsize measures the packed form")
ratio = gzipratio(body$, packed$)
assert_true(ratio, "gzipratio answers a number")
if ratio < 1 then smaller = 1
assert_true(smaller, "and forty repeated lines pack down rather than up")
assert_eq(gziperror(), 0, "nothing above failed, so the code is clear")

test_case("base64/no-line-breaks")
rem TNetEncoding.Base64 is MIME base64 and wraps at 76 characters. That made
rem b64valid reject this library's own output, and put a newline inside
rem b64urlencode$, whose whole purpose is a string that survives a URL.
rem Nothing under 57 bytes wraps, which is why it went unseen.
long$ = ""
for i = 1 to 10
  long$ = long$ + "abcdefghij"
next i

wide$ = b64encode$(long$)
assert_eq(len(wide$), 136, "100 bytes encode to exactly 136 characters, with nothing added")
assert_eq(instr(wide$, chr$(13)), -1, "no carriage return")
assert_eq(instr(wide$, chr$(10)), -1, "no line feed")
assert_eq(b64valid(wide$), 1, "and the library calls its own output valid")
assert_eq(b64decode$(wide$), long$, "which still round-trips")

url$ = b64urlencode$(long$)
assert_eq(instr(url$, chr$(10)), -1, "a URL-safe string has no line feed in it")
assert_eq(b64urldecode$(url$), long$, "and round-trips too")

rem Validation stays wider than the encoder, but only by the line breaks MIME
rem wrapping produces. A space is not part of any base64 convention, and
rem 21_Base64Lib_tests.bas has said so for longer than this file has existed.
rem One message with a break in the middle of it -- which is what wrapping
rem produces. Two messages concatenated would put a padding = inside the
rem string, and that is invalid whatever the whitespace rule says.
wrapped$ = "aGVsbG8g" + chr$(13) + chr$(10) + "d29ybGQ="
assert_eq(b64valid(wrapped$), 1, "wrapped base64 from elsewhere is still valid")
assert_eq(b64decode$(wrapped$), "hello world", "and decodes to what it holds")
assert_eq(b64valid("aGVsbG8g d29ybGQ="), 0, "but a space is still invalid")

test_case("base64/files")
b64$ = "bin/p9b_arc.b64"
enc$ = b64encodefile$(src$)
assert_true(len(enc$), "b64encodefile$ answers text")
assert_eq(b64valid(enc$), 1, "and that text is valid base64")

file_writealltext(b64$, enc$)
b64decodefile(enc$, "bin/p9b_b64_out.txt")
assert_eq(file_readalltext$("bin/p9b_b64_out.txt"), body$, "b64decodefile puts the bytes back")
assert_eq(b64error(), 0, "nothing above failed, so the code is clear")

file_delete(z$)
file_delete(src$)
file_delete(out$)
file_delete(gz$)
file_delete(b64$)
