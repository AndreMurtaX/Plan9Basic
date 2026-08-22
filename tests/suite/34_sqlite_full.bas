rem ---------------------------------------------------------------
rem SQLiteLib. check-coverage.py reported 11/52: prepared statements,
rem binding, transactions, introspection and the JSON bridge had all
rem never been run. 06_sqlite.bas covers the other eleven.
rem
rem This lives under tests/gui/ because that is where the library is
rem registered, not because it draws anything. SQLiteLib touches no
rem FireMonkey -- check-fmx-boundary.py reports only TimerLib doing
rem that -- so its place in the --gui set is a wart worth moving one
rem day, with its own reason and its own test.
rem
rem Two conventions to keep hold of, both documented and both easy to
rem get wrong coming from SQL:
rem
rem   * parameter and column indices are 0-BASED. SQLite's own C API is
rem     1-based, so the obvious guess binds the wrong parameter.
rem   * a query is not positioned until sql_step has been called. Before
rem     the first step, sql_eof answers true and every getter answers
rem     empty -- which reads exactly like an empty table.
rem ---------------------------------------------------------------

db$ = "bin/p9b_sql.db"
file_delete(db$)

test_case("sql/open")
d# = sql_open#(db$)
assert_true(pnttonum(d#), "sql_open# answers a handle")
assert_true(sql_isopen(d#), "and the handle says it is open")
assert_eq(sql_path$(d#), db$, "which remembers its file")
assert_true(len(sql_version$()), "sql_version$ answers the library version")
assert_eq(sql_error(), 0, "and nothing has gone wrong yet")

test_case("sql/exec")
sql_exec(d#, "CREATE TABLE people (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)")
assert_true(sql_tableexists(d#, "people"), "sql_tableexists finds the new table")
assert_false(sql_tableexists(d#, "nobody"), "and does not invent one")

sql_exec(d#, "INSERT INTO people (name, age) VALUES ('Alice', 30)")
assert_eq(sql_changes(d#), 1, "sql_changes counts the last statement")
assert_eq(sql_lastid(d#), 1, "sql_lastid answers the new row id")
assert_true(sql_totalchanges(d#), "sql_totalchanges counts the session")

test_case("sql/prepare-and-bind")
rem The parameterised path. Binding is what keeps a name with an
rem apostrophe from becoming a syntax error or worse.
s# = sql_prepare#(d#, "INSERT INTO people (name, age) VALUES (?, ?)")
assert_true(pnttonum(s#), "sql_prepare# answers a statement")

sql_bindstr#(s#, 0, "Bob")
sql_bindnum#(s#, 1, 41)
sql_step(s#)
assert_eq(sql_lastid(d#), 2, "the bound insert made a row")

sql_reset#(s#)
sql_clearbind#(s#)
sql_bindstr#(s#, 0, "O'Brien")
sql_bindnum#(s#, 1, 55)
sql_step(s#)
assert_eq(sql_lastid(d#), 3, "and a name with a quote in it is no trouble")

sql_reset#(s#)
sql_clearbind#(s#)
sql_bindstr#(s#, 0, "Nobody")
sql_bindnull#(s#, 1)
sql_step(s#)
assert_eq(sql_lastid(d#), 4, "and a bound null makes a row like any other")
sql_finalize(s#)

test_case("sql/bind-from-json")
rem sql_bindjson# matches by NAME, not by position: it walks the object's
rem keys and asks the statement for a parameter of that name. So the
rem statement has to be written with named parameters -- a statement full
rem of question marks binds nothing at all, silently, because a parameter
rem that is not found is skipped.
j# = sql_prepare#(d#, "INSERT INTO people (name, age) VALUES (:name, :age)")
p# = json_object#()
json_sets#(p#, "name", "Dana")
json_setn#(p#, "age", 33)
sql_bindjson#(j#, p#)
sql_step(j#)
sql_finalize(j#)

jq# = sql_query#(d#, "SELECT age FROM people WHERE name = 'Dana'")
sql_step(jq#)
assert_eq(sql_getn(jq#, "age"), 33, "the JSON object became a bound row")
sql_finalize(jq#)

test_case("sql/query-by-column")
q# = sql_query#(d#, "SELECT id, name, age FROM people ORDER BY id")
assert_true(pnttonum(q#), "sql_query# answers a result")
assert_eq(sql_step(q#), 1, "and the first step lands on a row")
assert_false(sql_eof(q#), "which is not the end")

assert_eq(sql_colcount(q#), 3, "three columns were asked for")
assert_eq(sql_colname$(q#, 0), "id", "sql_colname$ names the first")
assert_eq(sql_colindex(q#, "age"), 2, "sql_colindex finds one by name")
assert_true(len(sql_coltypename$(sql_coltype(q#, 0))), "sql_coltypename$ names the type sql_coltype answers")

assert_eq(sql_getstr$(q#, 1), "Alice", "sql_getstr$ reads by position")
assert_eq(sql_getnum(q#, 2), 30, "sql_getnum too")
assert_eq(sql_gets$(q#, "name"), "Alice", "sql_gets$ reads by name")
assert_eq(sql_getn(q#, "age"), 30, "and sql_getn")
assert_false(sql_isnull(q#, 1), "a value that is there is not null")
assert_false(sql_isblob(q#, 1), "and text is not a blob")

test_case("sql/stepping")
rem Walking to the end proves eof means what it says rather than
rem answering true only when nothing was ever opened.
count = 1
while sql_step(q#) = 1
  count = count + 1
wend
assert_eq(count, 5, "five rows were inserted and five were walked")
assert_true(sql_eof(q#), "and the result is at its end")
sql_finalize(q#)

test_case("sql/nulls")
n# = sql_query#(d#, "SELECT age FROM people WHERE name = 'Nobody'")
sql_step(n#)
assert_true(sql_isnull(n#, 0), "the bound null really is null")
assert_true(sql_isn(n#, "age"), "and sql_isn agrees by name")
sql_finalize(n#)

test_case("sql/json")
rem Every one of these answers a JSON handle, so JsonLib is what reads
rem them back.
r# = sql_query#(d#, "SELECT id, name FROM people ORDER BY id")
sql_step(r#)
row# = sql_row#(r#)
assert_true(json_isobj(row#), "sql_row# answers an object")
assert_eq(json_gets$(row#, "name"), "Alice", "holding the current row")

one# = sql_fetchone#(r#)
assert_true(json_isobj(one#), "sql_fetchone# answers an object too")
sql_finalize(r#)

rem json_count is object keys only, by definition. An array is counted
rem by json_len, which handles both -- and these three answer arrays.
f# = sql_query#(d#, "SELECT id FROM people")
all# = sql_fetchall#(f#)
assert_true(json_isarr(all#), "sql_fetchall# answers an array")
assert_eq(json_len(all#), 5, "holding every row at once")
assert_eq(json_count(all#), 0, "and json_count, which counts object keys, says nothing about it")
sql_finalize(f#)

t# = sql_tables#(d#)
assert_true(json_len(t#), "sql_tables# lists the tables")
c# = sql_columns#(d#, "people")
assert_eq(json_len(c#), 3, "sql_columns# describes the three columns")

test_case("sql/json-writes")
rem The JSON write path: an object becomes a row, and a second object
rem updates it.
o# = json_object#()
json_sets#(o#, "name", "Carol")
json_setn#(o#, "age", 28)
assert_eq(sql_insertjson(d#, "people", o#), 1, "sql_insertjson writes a row")

k# = sql_query#(d#, "SELECT name, age FROM people WHERE name = 'Carol'")
sql_step(k#)
assert_eq(sql_gets$(k#, "name"), "Carol", "and the row is there")
sql_finalize(k#)

u# = json_object#()
json_setn#(u#, "age", 29)
assert_eq(sql_updatejson(d#, "people", u#, "name = 'Carol'"), 1, "sql_updatejson changes it")

k2# = sql_query#(d#, "SELECT age FROM people WHERE name = 'Carol'")
sql_step(k2#)
assert_eq(sql_getn(k2#, "age"), 29, "and the new value is stored")
sql_finalize(k2#)

test_case("sql/transactions")
assert_false(sql_intrans(d#), "no transaction is open to begin with")
sql_begin(d#)
assert_true(sql_intrans(d#), "sql_begin opens one")
sql_exec(d#, "INSERT INTO people (name, age) VALUES ('Temporary', 1)")
sql_rollback(d#)
assert_false(sql_intrans(d#), "sql_rollback closes it")

t1# = sql_query#(d#, "SELECT count(*) AS n FROM people WHERE name = 'Temporary'")
sql_step(t1#)
assert_eq(sql_getn(t1#, "n"), 0, "and the rolled-back row is not there")
sql_finalize(t1#)

sql_begin(d#)
sql_exec(d#, "INSERT INTO people (name, age) VALUES ('Permanent', 2)")
sql_commit(d#)
assert_false(sql_intrans(d#), "sql_commit closes it too")

t2# = sql_query#(d#, "SELECT count(*) AS n FROM people WHERE name = 'Permanent'")
sql_step(t2#)
assert_eq(sql_getn(t2#, "n"), 1, "and the committed row stayed")
sql_finalize(t2#)

test_case("sql/escaping")
rem sql_escape$ doubles the quote, sql_quote$ wraps the whole thing.
rem Both exist because building SQL by hand is sometimes unavoidable.
assert_eq(sql_escape$("O'Brien"), "O''Brien", "sql_escape$ doubles an apostrophe")
assert_eq(sql_quote$("O'Brien"), "'O''Brien'", "sql_quote$ escapes and wraps")

test_case("sql/errors")
sql_clearerror()
assert_eq(sql_error(), 0, "sql_clearerror clears the code")
sql_exec(d#, "THIS IS NOT SQL")
assert_true(sql_error(), "a bad statement leaves a code")
assert_true(len(sql_errormsg$()), "and a message")
assert_true(len(sql_strerror$(sql_error())), "sql_strerror$ names the code")
sql_clearerror()
assert_eq(sql_error(), 0, "and it can be cleared again")

test_case("sql/maintenance")
back$ = "bin/p9b_sql_backup.db"
file_delete(back$)
assert_eq(sql_backup(d#, back$), 1, "sql_backup writes a copy")
assert_true(file_exists(back$), "and the copy is on disk")

b# = sql_open#(back$)
assert_true(sql_tableexists(b#, "people"), "which holds the same tables")
sql_close(b#)
file_delete(back$)

assert_eq(sql_vacuum(d#), 1, "sql_vacuum runs")

test_case("sql/memory")
rem The no-argument form opens a database that never touches the disk.
m# = sql_open#()
assert_true(sql_isopen(m#), "sql_open# with no file answers an open handle")
sql_exec(m#, "CREATE TABLE t (v INTEGER)")
assert_true(sql_tableexists(m#, "t"), "which behaves like any other")
sql_close(m#)

test_case("sql/close")
sql_close(d#)
assert_false(sql_isopen(d#), "sql_close closes it")

file_delete(db$)
