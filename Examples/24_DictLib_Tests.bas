' ============================================================================
' DictLib Test Suite for Plan9Basic
' Tests all 21 dictionary functions across all categories
' ============================================================================
' ----------------------------------------------------------------------------
' Test 1: Numeric Dictionary Creation and Basic Operations
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 1: Numeric Dictionary ==="
d# = dict#()
IF PntToNum(d#) <> 0 THEN
  PRINTLN "PASS: dict#() created numeric dictionary"
ELSE
  PRINTLN "FAIL: dict#() returned null"
END IF
' Test dict_type and dict_typename$
t = dict_type(d#)
IF t = 0 THEN
  PRINTLN "PASS: dict_type() returned 0 (numeric)"
ELSE
  PRINTLN "FAIL: dict_type() expected 0, got "; t
END IF
tn$ = dict_typename$(d#)
IF tn$ = "numeric" THEN
  PRINTLN "PASS: dict_typename$() returned 'numeric'"
ELSE
  PRINTLN "FAIL: dict_typename$() expected 'numeric', got '"; tn$; "'"
END IF
' Test empty dictionary count
c = dict_count(d#)
IF c = 0 THEN
  PRINTLN "PASS: Empty dictionary has count 0"
ELSE
  PRINTLN "FAIL: Empty dictionary count expected 0, got "; c
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Test 2: Numeric Dictionary Set/Get Operations
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 2: Numeric Set/Get ==="
' Set values
dict_set#(d#, "age", 25)
dict_set#(d#, "score", 100.5)
dict_set#(d#, "negative", -42)
dict_set#(d#, "zero", 0)
' Test count after adding
c = dict_count(d#)
IF c = 4 THEN
  PRINTLN "PASS: Dictionary count is 4 after adding 4 items"
ELSE
  PRINTLN "FAIL: Expected count 4, got "; c
END IF
' Test dict_get
v = dict_get(d#, "age")
IF v = 25 THEN
  PRINTLN "PASS: dict_get('age') returned 25"
ELSE
  PRINTLN "FAIL: dict_get('age') expected 25, got "; v
END IF
v = dict_get(d#, "score")
IF v = 100.5 THEN
  PRINTLN "PASS: dict_get('score') returned 100.5"
ELSE
  PRINTLN "FAIL: dict_get('score') expected 100.5, got "; v
END IF
v = dict_get(d#, "negative")
IF v = -42 THEN
  PRINTLN "PASS: dict_get('negative') returned -42"
ELSE
  PRINTLN "FAIL: dict_get('negative') expected -42, got "; v
END IF
v = dict_get(d#, "zero")
IF v = 0 THEN
  PRINTLN "PASS: dict_get('zero') returned 0"
ELSE
  PRINTLN "FAIL: dict_get('zero') expected 0, got "; v
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Test 3: Numeric Dictionary - dict_getdef (default values)
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 3: Numeric dict_getdef ==="
' Existing key - should return stored value
v = dict_getdef(d#, "age", 999)
IF v = 25 THEN
  PRINTLN "PASS: dict_getdef('age', 999) returned stored value 25"
ELSE
  PRINTLN "FAIL: Expected 25, got "; v
END IF
' Non-existing key - should return default
v = dict_getdef(d#, "nonexistent", 999)
IF v = 999 THEN
  PRINTLN "PASS: dict_getdef('nonexistent', 999) returned default 999"
ELSE
  PRINTLN "FAIL: Expected default 999, got "; v
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Test 4: Dictionary Key Existence
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 4: Key Existence (dict_exists, dict_haskey) ==="
' Test dict_exists (same as dict_haskey)
IF dict_exists(d#, "age") = 1 THEN
  PRINTLN "PASS: dict_exists('age') returned 1"
ELSE
  PRINTLN "FAIL: dict_exists('age') should return 1"
END IF
IF dict_exists(d#, "nothere") = 0 THEN
  PRINTLN "PASS: dict_exists('nothere') returned 0"
ELSE
  PRINTLN "FAIL: dict_exists('nothere') should return 0"
END IF
' Test dict_haskey (alias)
IF dict_haskey(d#, "score") = 1 THEN
  PRINTLN "PASS: dict_haskey('score') returned 1"
ELSE
  PRINTLN "FAIL: dict_haskey('score') should return 1"
END IF
IF dict_haskey(d#, "missing") = 0 THEN
  PRINTLN "PASS: dict_haskey('missing') returned 0"
ELSE
  PRINTLN "FAIL: dict_haskey('missing') should return 0"
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Test 5: Dictionary Key Enumeration
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 5: Key Enumeration (dict_key$) ==="
PRINTLN "Keys in numeric dictionary:"
c = dict_count(d#)
FOR i = 0 TO c - 1
  k$ = dict_key$(d#, i)
  v = dict_get(d#, k$)
  PRINTLN "  ["; i; "] "; k$; " = "; v
NEXT
PRINTLN
' ----------------------------------------------------------------------------
' Test 6: Dictionary Remove
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 6: dict_remove ==="
' Remove existing key
r = dict_remove(d#, "negative")
IF r = 1 THEN
  PRINTLN "PASS: dict_remove('negative') returned 1 (success)"
ELSE
  PRINTLN "FAIL: dict_remove('negative') should return 1"
END IF
' Verify it's gone
IF dict_exists(d#, "negative") = 0 THEN
  PRINTLN "PASS: 'negative' key no longer exists"
ELSE
  PRINTLN "FAIL: 'negative' key should not exist after removal"
END IF
' Verify count decreased
c = dict_count(d#)
IF c = 3 THEN
  PRINTLN "PASS: Count is now 3 after removal"
ELSE
  PRINTLN "FAIL: Expected count 3, got "; c
END IF
' Try to remove non-existing key
r = dict_remove(d#, "nonexistent")
IF r = 0 THEN
  PRINTLN "PASS: dict_remove('nonexistent') returned 0 (not found)"
ELSE
  PRINTLN "FAIL: dict_remove('nonexistent') should return 0"
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Test 7: Dictionary Clear
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 7: dict_clear# ==="
dict_clear#(d#)
c = dict_count(d#)
IF c = 0 THEN
  PRINTLN "PASS: Dictionary is empty after dict_clear#"
ELSE
  PRINTLN "FAIL: Expected count 0 after clear, got "; c
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Test 8: String Dictionary
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 8: String Dictionary ==="
sd# = sdict#()
IF PntToNum(sd#) <> 0 THEN
  PRINTLN "PASS: sdict#() created string dictionary"
ELSE
  PRINTLN "FAIL: sdict#() returned null"
END IF
' Verify type
t = dict_type(sd#)
IF t = 1 THEN
  PRINTLN "PASS: dict_type() returned 1 (string)"
ELSE
  PRINTLN "FAIL: dict_type() expected 1, got "; t
END IF
tn$ = dict_typename$(sd#)
IF tn$ = "string" THEN
  PRINTLN "PASS: dict_typename$() returned 'string'"
ELSE
  PRINTLN "FAIL: dict_typename$() expected 'string', got '"; tn$; "'"
END IF
' Set string values
sdict_set#(sd#, "name", "John Doe")
sdict_set#(sd#, "city", "São Paulo")
sdict_set#(sd#, "empty", "")
sdict_set#(sd#, "special", "Line1" + chr$(10) + "Line2")
' Get string values
s$ = sdict_get$(sd#, "name")
IF s$ = "John Doe" THEN
  PRINTLN "PASS: sdict_get$('name') returned 'John Doe'"
ELSE
  PRINTLN "FAIL: Expected 'John Doe', got '"; s$; "'"
END IF
s$ = sdict_get$(sd#, "city")
IF s$ = "São Paulo" THEN
  PRINTLN "PASS: sdict_get$('city') returned 'São Paulo' (Unicode OK)"
ELSE
  PRINTLN "FAIL: Expected 'São Paulo', got '"; s$; "'"
END IF
s$ = sdict_get$(sd#, "empty")
IF s$ = "" THEN
  PRINTLN "PASS: sdict_get$('empty') returned empty string"
ELSE
  PRINTLN "FAIL: Expected empty string, got '"; s$; "'"
END IF
' Test sdict_getdef$
s$ = sdict_getdef$(sd#, "name", "DEFAULT")
IF s$ = "John Doe" THEN
  PRINTLN "PASS: sdict_getdef$('name', 'DEFAULT') returned stored value"
ELSE
  PRINTLN "FAIL: Expected 'John Doe', got '"; s$; "'"
END IF
s$ = sdict_getdef$(sd#, "missing", "DEFAULT")
IF s$ = "DEFAULT" THEN
  PRINTLN "PASS: sdict_getdef$('missing', 'DEFAULT') returned default"
ELSE
  PRINTLN "FAIL: Expected 'DEFAULT', got '"; s$; "'"
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Test 9: Pointer Dictionary
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 9: Pointer Dictionary ==="
pd# = pdict#()
IF PntToNum(pd#) <> 0 THEN
  PRINTLN "PASS: pdict#() created pointer dictionary"
ELSE
  PRINTLN "FAIL: pdict#() returned null"
END IF
' Verify type
t = dict_type(pd#)
IF t = 2 THEN
  PRINTLN "PASS: dict_type() returned 2 (pointer)"
ELSE
  PRINTLN "FAIL: dict_type() expected 2, got "; t
END IF
tn$ = dict_typename$(pd#)
IF tn$ = "pointer" THEN
  PRINTLN "PASS: dict_typename$() returned 'pointer'"
ELSE
  PRINTLN "FAIL: dict_typename$() expected 'pointer', got '"; tn$; "'"
END IF
' Store dictionaries as pointer values (nested dictionaries!)
innerDict# = dict#()
dict_set#(innerDict#, "inner_value", 42)
pdict_set#(pd#, "nested", innerDict#)
' Retrieve and verify
retrieved# = pdict_get#(pd#, "nested")
IF PntToNum(retrieved#) = PntToNum(innerDict#) THEN
  PRINTLN "PASS: pdict_get#('nested') returned correct pointer"
ELSE
  PRINTLN "FAIL: Retrieved pointer doesn't match"
END IF
' Verify inner dictionary still works
v = dict_get(retrieved#, "inner_value")
IF v = 42 THEN
  PRINTLN "PASS: Nested dictionary value is 42"
ELSE
  PRINTLN "FAIL: Expected 42, got "; v
END IF
' Test pdict_getdef#
' Test with existing key - should return stored value
p# = pdict_getdef#(pd#, "nested", innerDict#)
IF PntToNum(p#) = PntToNum(innerDict#) THEN
  PRINTLN "PASS: pdict_getdef#('nested', default) returned stored pointer"
ELSE
  PRINTLN "FAIL: pdict_getdef# returned wrong pointer"
END IF
' Test with missing key - should return default (we use innerDict# as default)
defaultPtr# = dict#()
p# = pdict_getdef#(pd#, "missing", defaultPtr#)
IF PntToNum(p#) = PntToNum(defaultPtr#) THEN
  PRINTLN "PASS: pdict_getdef#('missing', default) returned default pointer"
ELSE
  PRINTLN "FAIL: Expected default pointer, got different pointer"
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Test 10: Method Chaining
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 10: Method Chaining ==="
chain# = dict#()
dict_set#(dict_set#(dict_set#(chain#, "a", 1), "b", 2), "c", 3)
c = dict_count(chain#)
IF c = 3 THEN
  PRINTLN "PASS: Chained dict_set# added 3 items"
ELSE
  PRINTLN "FAIL: Expected 3 items, got "; c
END IF
va = dict_get(chain#, "a")
vb = dict_get(chain#, "b")
vc = dict_get(chain#, "c")
IF va = 1 AND vb = 2 AND vc = 3 THEN
  PRINTLN "PASS: All chained values correct (1, 2, 3)"
ELSE
  PRINTLN "FAIL: Chained values incorrect"
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Test 11: Overwriting Values
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 11: Overwriting Values ==="
ow# = dict#()
dict_set#(ow#, "key", 100)
v = dict_get(ow#, "key")
IF v = 100 THEN
  PRINTLN "PASS: Initial value is 100"
ELSE
  PRINTLN "FAIL: Expected 100, got "; v
END IF
dict_set#(ow#, "key", 200)
v = dict_get(ow#, "key")
IF v = 200 THEN
  PRINTLN "PASS: Overwritten value is 200"
ELSE
  PRINTLN "FAIL: Expected 200, got "; v
END IF
' Count should still be 1
c = dict_count(ow#)
IF c = 1 THEN
  PRINTLN "PASS: Count still 1 after overwrite"
ELSE
  PRINTLN "FAIL: Expected count 1, got "; c
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Test 12: Special Key Names
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 12: Special Key Names ==="
sk# = sdict#()
' Keys with spaces
sdict_set#(sk#, "key with spaces", "value1")
s$ = sdict_get$(sk#, "key with spaces")
IF s$ = "value1" THEN
  PRINTLN "PASS: Key with spaces works"
ELSE
  PRINTLN "FAIL: Key with spaces failed"
END IF
' Keys with special characters
sdict_set#(sk#, "key@#$%", "value2")
s$ = sdict_get$(sk#, "key@#$%")
IF s$ = "value2" THEN
  PRINTLN "PASS: Key with special chars works"
ELSE
  PRINTLN "FAIL: Key with special chars failed"
END IF
' Keys with Unicode
sdict_set#(sk#, "chave_português", "valor")
s$ = sdict_get$(sk#, "chave_português")
IF s$ = "valor" THEN
  PRINTLN "PASS: Unicode key works"
ELSE
  PRINTLN "FAIL: Unicode key failed"
END IF
' Empty key
sdict_set#(sk#, "", "empty_key_value")
s$ = sdict_get$(sk#, "")
IF s$ = "empty_key_value" THEN
  PRINTLN "PASS: Empty key works"
ELSE
  PRINTLN "FAIL: Empty key failed"
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Test 13: Large Dictionary
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 13: Large Dictionary (100 items) ==="
large# = dict#()
FOR i = 1 TO 100
  dict_set#(large#, "key" + str$(i), i * 10)
NEXT
c = dict_count(large#)
IF c = 100 THEN
  PRINTLN "PASS: Dictionary has 100 items"
ELSE
  PRINTLN "FAIL: Expected 100 items, got "; c
END IF
' Spot check some values
v = dict_get(large#, "key1")
IF v = 10 THEN
  PRINTLN "PASS: key1 = 10"
ELSE
  PRINTLN "FAIL: key1 expected 10, got "; v
END IF
v = dict_get(large#, "key50")
IF v = 500 THEN
  PRINTLN "PASS: key50 = 500"
ELSE
  PRINTLN "FAIL: key50 expected 500, got "; v
END IF
v = dict_get(large#, "key100")
IF v = 1000 THEN
  PRINTLN "PASS: key100 = 1000"
ELSE
  PRINTLN "FAIL: key100 expected 1000, got "; v
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Test 14: Iteration Over All Keys
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 14: Full Iteration ==="
iter# = dict#()
dict_set#(iter#, "alpha", 1)
dict_set#(iter#, "beta", 2)
dict_set#(iter#, "gamma", 3)
dict_set#(iter#, "delta", 4)
total = 0
c = dict_count(iter#)
FOR i = 0 TO c - 1
  k$ = dict_key$(iter#, i)
  v = dict_get(iter#, k$)
  total = total + v
NEXT
IF total = 10 THEN
  PRINTLN "PASS: Sum of all values is 10"
ELSE
  PRINTLN "FAIL: Expected sum 10, got "; total
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Test 15: Multiple Dictionaries Independence
' ----------------------------------------------------------------------------
PRINTLN "=== TEST 15: Multiple Dictionaries Independence ==="
d1# = dict#()
d2# = dict#()
d3# = sdict#()
dict_set#(d1#, "value", 100)
dict_set#(d2#, "value", 200)
sdict_set#(d3#, "value", "text")
v1 = dict_get(d1#, "value")
v2 = dict_get(d2#, "value")
v3$ = sdict_get$(d3#, "value")
IF v1 = 100 THEN
  PRINTLN "PASS: d1# value is 100"
ELSE
  PRINTLN "FAIL: d1# expected 100, got "; v1
END IF
IF v2 = 200 THEN
  PRINTLN "PASS: d2# value is 200"
ELSE
  PRINTLN "FAIL: d2# expected 200, got "; v2
END IF
IF v3$ = "text" THEN
  PRINTLN "PASS: d3# value is 'text'"
ELSE
  PRINTLN "FAIL: d3# expected 'text', got '"; v3$; "'"
END IF
PRINTLN
' ----------------------------------------------------------------------------
' Summary
' ----------------------------------------------------------------------------
PRINTLN "============================================"
PRINTLN "DictLib Test Suite Complete!"
PRINTLN "============================================"
PRINTLN
PRINTLN "If all tests show PASS, the library is working correctly."
PRINTLN "Any FAIL messages indicate issues that need investigation."
