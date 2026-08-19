rem ---------------------------------------------------------------
rem SQLiteLib had no test of any kind, and was dead: it validates its
rem handles against the registry with IsHandleOf and never registered
rem anything, so every sql_* call answered "Invalid connection object"
rem against the pointer sql_open# had just returned.
rem
rem It lives under --gui only because that is where the runner registers
rem it, not because it needs a window.
rem ---------------------------------------------------------------

path$ = documentspath$() + "/p9b_suite_sqlite.db"
x = file_delete(path$)

test_case("sqlite/open-and-exec")
db# = sql_open#(path$)
assert_eq(sql_error(), 0, "opening a database reports no error")
assert_eq(sql_exec(db#, "CREATE TABLE t (a INTEGER, b TEXT)"), 1, "create a table")
assert_eq(sql_exec(db#, "INSERT INTO t VALUES (42, 'answer')"), 1, "insert a row")
assert_eq(sql_error(), 0, "and nothing was recorded")

test_case("sqlite/errors-are-reported")
rem A genuine SQLite failure, not a handle problem: the code and the message
rem both have to come back, because a caller cannot see the exception.
assert_eq(sql_exec(db#, "THIS IS NOT SQL"), 0, "invalid SQL fails")
assert_true(sql_error(), "and reports a code")
assert_true(len(sql_errormsg$()), "and a message")
x = sql_clearerror()
assert_eq(sql_error(), 0, "which clears")

test_case("sqlite/query")
q# = sql_query#(db#, "SELECT a, b FROM t")
assert_eq(sql_error(), 0, "a query prepares")
assert_eq(sql_step(q#), 1, "and steps to the first row")
assert_eq(sql_getnum(q#, 0), 42, "reading a number back")
assert_eq(sql_getstr$(q#, 1), "answer", "and a string")
assert_eq(sql_step(q#), 0, "one row only")
x = sql_finalize(q#)

test_case("sqlite/fabricated-pointer")
rem The registry is what makes this answerable without following the address.
junk# = pointer#(305419896)
assert_eq(sql_exec(junk#, "SELECT 1"), 0, "an invented connection is refused")
assert_true(sql_error(), "and says so")

test_case("sqlite/close")
assert_eq(sql_close(db#), 1, "closing succeeds")
x = file_delete(path$)
