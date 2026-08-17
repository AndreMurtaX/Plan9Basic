rem ---------------------------------------------------------------
rem StrListLib
rem ---------------------------------------------------------------

test_case("strings/add-count")
l# = strings#()
assert_eq(strings_count(l#), 0, "starts empty")
strings_add(l#, "banana")
strings_add(l#, "apple")
strings_add(l#, "cherry")
assert_eq(strings_count(l#), 3)

test_case("strings/index-access")
assert_eq(strings_strings$(l#, 0), "banana", "0-based")
assert_eq(strings_strings$(l#, 1), "apple")
assert_eq(strings_strings$(l#, 2), "cherry")

test_case("strings/indexof")
assert_eq(strings_indexof(l#, "apple"), 1)
assert_eq(strings_indexof(l#, "missing"), -1, "absent returns -1")

test_case("strings/insert-delete")
strings_insert(l#, 0, "first")
assert_eq(strings_count(l#), 4)
assert_eq(strings_strings$(l#, 0), "first")
strings_delete(l#, 0)
assert_eq(strings_count(l#), 3)
assert_eq(strings_strings$(l#, 0), "banana")

test_case("strings/sort")
strings_sort(l#)
assert_eq(strings_strings$(l#, 0), "apple")
assert_eq(strings_strings$(l#, 1), "banana")
assert_eq(strings_strings$(l#, 2), "cherry")

test_case("strings/exchange")
strings_exchange(l#, 0, 2)
assert_eq(strings_strings$(l#, 0), "cherry")
assert_eq(strings_strings$(l#, 2), "apple")

test_case("strings/clear")
strings_clear(l#)
assert_eq(strings_count(l#), 0)

test_case("strings/text")
t# = strings#()
strings_add(t#, "one")
strings_add(t#, "two")
assert_eq(strings_count(t#), 2)
strings_clear(t#)
strings_text(t#, "alpha" + chr$(10) + "beta")
assert_eq(strings_count(t#), 2, "text assignment splits on line breaks")
assert_eq(strings_strings$(t#, 0), "alpha")
assert_eq(strings_strings$(t#, 1), "beta")

test_case("strings/namevalue")
nv# = strings#()
strings_add(nv#, "host=localhost")
strings_add(nv#, "port=8080")
assert_eq(strings_values$(nv#, "host"), "localhost")
assert_eq(strings_values$(nv#, "port"), "8080")
assert_eq(strings_indexofname(nv#, "port"), 1)

test_case("strings/commatext")
ct# = strings#()
strings_commatext(ct#, "a,b,c")
assert_eq(strings_count(ct#), 3)
assert_eq(strings_strings$(ct#, 0), "a")
assert_eq(strings_strings$(ct#, 2), "c")
