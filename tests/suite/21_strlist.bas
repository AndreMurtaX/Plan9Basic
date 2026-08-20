rem ---------------------------------------------------------------
rem StrListLib: 46 registered functions, none of them tested.
rem
rem It was the largest gap left outside the GUI after DateTimeLib.
rem
rem A string list here indexes from ZERO. Arrays in this language
rem start at one and s$[n] takes a line from zero, so the base is
rem worth stating rather than assuming; every index below is written
rem out for that reason.
rem
rem The pair that earns its own case is find and indexof. They take
rem the same arguments, return the same thing -- an index, or -1 --
rem and one of them is a binary search that answers "not there"
rem about items that are, whenever the list is not sorted. The
rem reference page says so in a note. This says so in a run.
rem ---------------------------------------------------------------

test_case("strlist/it counts from zero")
l# = strings#()
assert_eq(strings_count(l#), 0, "a new list is empty")
assert_eq(strings_add(l#, "beta"), 0, "add returns the index it used")
assert_eq(strings_add(l#, "alpha"), 1, "and the next one")
assert_eq(strings_count(l#), 2, "two items")
assert_eq(strings_strings$(l#, 0), "beta", "index 0 is the first")
assert_eq(strings_strings$(l#, 1), "alpha", "index 1 the second")

test_case("strlist/indexof searches, and says -1 when it fails")
assert_eq(strings_indexof(l#, "alpha"), 1, "found at its index")
assert_eq(strings_indexof(l#, "zeta"), -1, "absent is -1, not 0")

test_case("strlist/find is a binary search and needs a sorted list")
rem Eight items in reverse order. indexof finds every one of them;
rem find reports -1 for every one of them, and reports it without
rem any error being raised. That is the trap: the two calls look
rem alike, take the same arguments, and disagree in silence.
r# = strings#()
strings_add(r#, "h")
strings_add(r#, "g")
strings_add(r#, "f")
strings_add(r#, "e")
strings_add(r#, "d")
strings_add(r#, "c")
strings_add(r#, "b")
strings_add(r#, "a")
assert_eq(strings_indexof(r#, "a"), 7, "indexof finds a where it is")
assert_eq(strings_find(r#, "a"), -1, "find does not, because nothing is sorted")
assert_eq(strings_indexof(r#, "d"), 4, "indexof finds d")
assert_eq(strings_find(r#, "d"), -1, "find does not")

rem Sort it and find agrees with indexof on every one.
strings_sort(r#)
assert_eq(strings_strings$(r#, 0), "a", "sorting put a first")
assert_eq(strings_strings$(r#, 7), "h", "and h last")
assert_eq(strings_find(r#, "a"), 0, "now find agrees")
assert_eq(strings_find(r#, "d"), 3, "on d as well")
assert_eq(strings_indexof(r#, "d"), 3, "and indexof answers the same")

test_case("strlist/insert, delete, exchange and move")
m# = strings#()
strings_add(m#, "one")
strings_add(m#, "two")
strings_insert(m#, 0, "zero")
assert_eq(strings_count(m#), 3, "insert grew the list")
assert_eq(strings_strings$(m#, 0), "zero", "and put it at the front")
assert_eq(strings_strings$(m#, 1), "one", "pushing the rest along")
strings_exchange(m#, 0, 2)
assert_eq(strings_strings$(m#, 0), "two", "exchange swapped the ends")
assert_eq(strings_strings$(m#, 2), "zero", "both ways")
strings_move(m#, 0, 1)
assert_eq(strings_strings$(m#, 1), "two", "move put it where it was asked")
strings_delete(m#, 0)
assert_eq(strings_count(m#), 2, "delete shrank it")
strings_clear(m#)
assert_eq(strings_count(m#), 0, "and clear emptied it")

test_case("strlist/text and comma text")
t# = strings#()
strings_add(t#, "one")
strings_add(t#, "two")
assert_eq(strings_commatext$(t#), "one,two", "commatext joins with commas")
c# = strings#()
strings_commatext(c#, "a,b,c")
assert_eq(strings_count(c#), 3, "and splits on them coming back")
assert_eq(strings_strings$(c#, 1), "b", "in order")

test_case("strlist/name=value pairs")
n# = strings#()
strings_add(n#, "host=localhost")
strings_add(n#, "port=8080")
assert_eq(strings_namevalueseparator$(n#), "=", "= is the separator by default")
assert_eq(strings_values$(n#, "port"), "8080", "values takes the name")
assert_eq(strings_valuefromindex$(n#, 1), "8080", "valuefromindex takes the index")
assert_eq(strings_names$(n#, 0), "host", "names takes the index too")
assert_eq(strings_indexofname(n#, "port"), 1, "indexofname finds the row")
assert_eq(strings_indexofname(n#, "nothing"), -1, "and says -1 when it cannot")

test_case("strlist/sorted lists reject nothing and keep order")
s# = strings#()
strings_sorted(s#, 1)
assert_eq(strings_sorted(s#), 1, "the list says it is sorted")
strings_add(s#, "gamma")
strings_add(s#, "alpha")
strings_add(s#, "beta")
assert_eq(strings_strings$(s#, 0), "alpha", "insertion keeps the order")
assert_eq(strings_strings$(s#, 2), "gamma", "throughout")
assert_eq(strings_find(s#, "beta"), 1, "and find works, the list being sorted")

test_case("strlist/free reports success and the handle stops working")
k = strings_free(l#)
assert_eq(k, 1, "free answers 1")
k = strings_free(l#)
assert_eq(k, 0, "a second free is refused")
