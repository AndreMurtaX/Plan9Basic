rem ---------------------------------------------------------------
rem The catalogue the Examples Browser reads, read the way it reads it.
rem
rem It used to be api/examples.php, a PHP endpoint answering a POST
rem with a database query. Static hosting serves neither, so it is a
rem file now -- Website/api/examples.json -- and the applet GETs it.
rem
rem The envelope and the field names were kept exactly as the endpoint
rem sent them, so that nothing in the applet's parsing had to move.
rem That claim is what is pinned here: this walks the same path the
rem applet walks, over the real file, and asserts the shape it depends
rem on. A catalogue that parses but has no "category" would show an
rem empty column and no error, which is the kind of silence this month
rem has spent itself on.
rem
rem The working directory is not one thing: tests/build.ps1 pushes into
rem tests/ before running the suite, and a single file is usually run
rem from the repository root. The first draft of this assumed the root,
rem passed on its own and failed inside the suite. So it looks for the
rem root rather than assuming one, and says where it looked if it cannot
rem find it -- a path that resolves to nothing is otherwise seven failed
rem assertions with no hint as to why.
rem ---------------------------------------------------------------

test_case("catalog/the-file-is-there")
let root$ = "../"
if file_exists("Website/api/examples.json") = 1 then root$ = ""
let path$ = root$ + "Website/api/examples.json"
if file_exists(path$) = 0 then println "no catalogue found from " + dir_getcurrent$()
assert_eq(file_exists(path$), 1, "the catalogue is where the applet's URL maps to")

let raw$ = file_readalltext$(path$)
let big = 0
if len(raw$) > 1000 then big = 1
assert_true(big, "and it is not empty")

test_case("catalog/envelope-is-what-the-applet-expects")
let root# = json_parse#(raw$)
let parsed = 0
if PntToNum(root#) <> 0 then parsed = 1
assert_true(parsed, "it parses as JSON")
assert_eq(json_gets$(root#, "status"), "ok", "the applet refuses any other status")

let data# = json_get#(root#, "data")
let got = 0
if PntToNum(data#) <> 0 then got = 1
assert_true(got, "the data array is present")

let count = json_len(data#)
let some = 0
if count > 0 then some = 1
assert_true(some, "and it lists something")

test_case("catalog/every-record-carries-what-the-grid-shows")
rem name, description and category fill the three columns; filename and
rem download_path are what the Download cell acts on. Any one of them
rem empty is a blank cell or a dead button, with no error either way.
let blank = 0
let astray = 0
for i = 0 to count - 1
  let item# = json_item#(data#, i)
  if json_gets$(item#, "name") = "" then blank = blank + 1
  if json_gets$(item#, "description") = "" then blank = blank + 1
  if json_gets$(item#, "category") = "" then blank = blank + 1
  let file$ = json_gets$(item#, "filename")
  if file$ = "" then blank = blank + 1
  let dl$ = json_gets$(item#, "download_path")
  if dl$ = "" then blank = blank + 1
  rem the download has to point at the file the record names
  if instr(dl$, file$) < 0 then astray = astray + 1
next
assert_eq(blank, 0, "every record fills every field the applet reads")
assert_eq(astray, 0, "and every download_path ends at the file its record names")

test_case("catalog/it-describes-the-directory-beside-it")
rem One record is enough to prove the two paths agree; whether all 97
rem agree is what tools/check-examples-catalog.py answers.
let first# = json_item#(data#, 0)
let f$ = root$ + "Website/assets/examples/" + json_gets$(first#, "filename")
assert_eq(file_exists(f$), 1, "the file the first record names is on disk")
