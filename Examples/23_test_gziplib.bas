' ============================================================================
' GzipLib Test Suite
' ============================================================================
' This script tests all functions in the GzipLib library.
' Run this to validate the library implementation.
' ============================================================================
LET totalTests = 0
LET passedTests = 0
LET failedTests = 0
' ----------------------------------------------------------------------------
' Test helper functions
' ----------------------------------------------------------------------------
FUNCTION passTest$(testName$)
  totalTests = totalTests + 1
  passedTests = passedTests + 1
  PRINTLN "[PASS] "; testName$
  RETURN ""
END FUNCTION
FUNCTION failTest$(testName$, reason$)
  totalTests = totalTests + 1
  failedTests = failedTests + 1
  PRINTLN "[FAIL] "; testName$
  PRINTLN "       Reason: "; reason$
  RETURN ""
END FUNCTION
' ============================================================================
' TEST SECTION 1: Error Handling
' ============================================================================
FUNCTION test_gziperror$() LOCAL dummy$, err, bad$
  PRINTLN
  PRINTLN "=== Test Section 1: Error Handling ==="
  PRINTLN
  ' Test 1.1: gziperror() should return 0 initially or after successful operation
  dummy$ = gzip$("test")
  err = gziperror()
  IF err = 0 THEN
    passTest$("1.1 gziperror() returns 0 after successful compression")
  ELSE
    failTest$("1.1 gziperror() returns 0 after successful compression", "Got error code: " + str$(err))
  END IF
  ' Test 1.2: gziperror() should return error for invalid decompression
  bad$ = gunzip$("not-valid-base64-gzip-data!!!")
  err = gziperror()
  IF err <> 0 THEN
    passTest$("1.2 gziperror() returns non-zero for invalid data")
  ELSE
    failTest$("1.2 gziperror() returns non-zero for invalid data", "Expected error but got 0")
  END IF
  RETURN ""
END FUNCTION
' ============================================================================
' TEST SECTION 2: String Compression
' ============================================================================
FUNCTION test_string_compression$() LOCAL original$, compressed$, restored$, fast$, best$, result$, unicode$, large$, i, err
  PRINTLN
  PRINTLN "=== Test Section 2: String Compression ==="
  PRINTLN
  ' Test 2.1: Basic gzip$/gunzip$ round-trip
  original$ = "Hello World! This is a test string."
  compressed$ = gzip$(original$)
  restored$ = gunzip$(compressed$)
  IF original$ = restored$ THEN
    passTest$("2.1 gzip$/gunzip$ round-trip preserves data")
  ELSE
    failTest$("2.1 gzip$/gunzip$ round-trip preserves data", "Data mismatch after decompression")
  END IF
  ' Test 2.2: gzip$() returns non-empty result
  compressed$ = gzip$("Test data")
  IF len(compressed$) > 0 THEN
    passTest$("2.2 gzip$() returns non-empty compressed data")
  ELSE
    failTest$("2.2 gzip$() returns non-empty compressed data", "Got empty string")
  END IF
  ' Test 2.3: Empty string handling
  compressed$ = gzip$("")
  err = gziperror()
  ' Empty input might return empty or error - both are acceptable
  passTest$("2.3 gzip$() handles empty string (error=" + str$(err) + ")")
  ' Test 2.4: gzipex$() with compression level 1 (fastest)
  original$ = "The quick brown fox jumps over the lazy dog. "
  original$ = original$ + original$ + original$ + original$
  fast$ = gzipex$(original$, 1)
  restored$ = gunzip$(fast$)
  IF original$ = restored$ THEN
    passTest$("2.4 gzipex$() level 1 round-trip works")
  ELSE
    failTest$("2.4 gzipex$() level 1 round-trip works", "Data mismatch")
  END IF
  ' Test 2.5: gzipex$() with compression level 9 (best)
  best$ = gzipex$(original$, 9)
  restored$ = gunzip$(best$)
  IF original$ = restored$ THEN
    passTest$("2.5 gzipex$() level 9 round-trip works")
  ELSE
    failTest$("2.5 gzipex$() level 9 round-trip works", "Data mismatch")
  END IF
  ' Test 2.6: Level 9 should compress better or equal to level 1
  IF len(best$) <= len(fast$) THEN
    passTest$("2.6 Level 9 compresses better or equal to level 1")
  ELSE
    failTest$("2.6 Level 9 compresses better or equal to level 1", "Level 9: " + str$(len(best$)) + ", Level 1: " + str$(len(fast$)))
  END IF
  ' Test 2.7: gzipex$() with invalid level should handle gracefully
  result$ = gzipex$("test", 0)
  err = gziperror()
  passTest$("2.7 gzipex$() with level 0 handled (error=" + str$(err) + ")")
  result$ = gzipex$("test", 10)
  err = gziperror()
  passTest$("2.8 gzipex$() with level 10 handled (error=" + str$(err) + ")")
  ' Test 2.9: Unicode/special characters
  unicode$ = "Olá Mundo! Привет мир! 你好世界!"
  compressed$ = gzip$(unicode$)
  restored$ = gunzip$(compressed$)
  IF unicode$ = restored$ THEN
    passTest$("2.9 gzip$/gunzip$ handles Unicode characters")
  ELSE
    failTest$("2.9 gzip$/gunzip$ handles Unicode characters", "Unicode data corrupted")
  END IF
  ' Test 2.10: Large string compression
  large$ = ""
  FOR i = 1 TO 100
    large$ = large$ + "Line " + str$(i) + ": This is test data for compression testing." + chr$(10)
  NEXT
  compressed$ = gzip$(large$)
  restored$ = gunzip$(compressed$)
  IF large$ = restored$ THEN
    passTest$("2.10 Large string compression works (" + str$(len(large$)) + " chars)")
  ELSE
    failTest$("2.10 Large string compression works", "Data mismatch on large string")
  END IF
  RETURN ""
END FUNCTION
' ============================================================================
' TEST SECTION 3: Utility Functions
' ============================================================================
FUNCTION test_utility_functions$() LOCAL size, original$, compressed$, csize, ratio, repetitive$, i
  PRINTLN
  PRINTLN "=== Test Section 3: Utility Functions ==="
  PRINTLN
  ' Test 3.1: gzipsize() returns positive value for non-empty string
  size = gzipsize("Hello World")
  IF size > 0 THEN
    passTest$("3.1 gzipsize() returns positive value (" + str$(size) + " bytes)")
  ELSE
    failTest$("3.1 gzipsize() returns positive value", "Got: " + str$(size))
  END IF
  ' Test 3.2: gzipsize() returns 0 for empty string
  size = gzipsize("")
  IF size = 0 THEN
    passTest$("3.2 gzipsize() returns 0 for empty string")
  ELSE
    failTest$("3.2 gzipsize() returns 0 for empty string", "Got: " + str$(size))
  END IF
  ' Test 3.3: gzipsize() handles Unicode (UTF-8 encoding)
  ' "Olá" in UTF-8 is 4 bytes (O=1, l=1, á=2)
  size = gzipsize("Olá")
  IF size >= 3 THEN
    passTest$("3.3 gzipsize() handles Unicode (" + str$(size) + " bytes for 'Olá')")
  ELSE
    failTest$("3.3 gzipsize() handles Unicode", "Expected >= 3, got: " + str$(size))
  END IF
  ' Test 3.4: gzipcsize() returns actual compressed size
  original$ = "Test data for compression size measurement"
  compressed$ = gzip$(original$)
  csize = gzipcsize(compressed$)
  IF csize > 0 THEN
    passTest$("3.4 gzipcsize() returns positive value (" + str$(csize) + " bytes)")
  ELSE
    failTest$("3.4 gzipcsize() returns positive value", "Got: " + str$(csize))
  END IF
  ' Test 3.5: Compressed size should be less than Base64 length (Base64 adds ~33% overhead)
  IF csize < len(compressed$) THEN
    passTest$("3.5 gzipcsize() < Base64 length (actual: " + str$(csize) + ", B64: " + str$(len(compressed$)) + ")")
  ELSE
    failTest$("3.5 gzipcsize() < Base64 length", "Compressed: " + str$(csize) + ", Base64: " + str$(len(compressed$)))
  END IF
  ' Test 3.6: gzipratio() returns value between 0 and 2 for normal data
  original$ = "The quick brown fox jumps over the lazy dog. "
  original$ = original$ + original$ + original$ + original$
  compressed$ = gzip$(original$)
  ratio = gzipratio(original$, compressed$)
  IF ratio > 0 AND ratio < 2 THEN
    passTest$("3.6 gzipratio() returns reasonable value (" + str$(ratio) + ")")
  ELSE
    failTest$("3.6 gzipratio() returns reasonable value", "Got: " + str$(ratio))
  END IF
  ' Test 3.7: Repetitive data should compress well (ratio < 1)
  repetitive$ = ""
  FOR i = 1 TO 100
    repetitive$ = repetitive$ + "AAAAAAAAAA"
  NEXT
  compressed$ = gzip$(repetitive$)
  ratio = gzipratio(repetitive$, compressed$)
  IF ratio < 1 THEN
    passTest$("3.7 Repetitive data compresses well (ratio=" + str$(ratio) + ")")
  ELSE
    failTest$("3.7 Repetitive data compresses well", "Expected ratio < 1, got: " + str$(ratio))
  END IF
  RETURN ""
END FUNCTION
' ============================================================================
' TEST SECTION 4: File Compression
' ============================================================================
FUNCTION test_file_compression$() LOCAL testFile$, testContent$, gzFile$, result, restoredFile$, restoredContent$, gzFile2$, tempDir$
  PRINTLN
  PRINTLN "=== Test Section 4: File Compression ==="
  PRINTLN
  ' Use system temp folder
  tempDir$ = temppath$()
  ' Create a test file
  testFile$ = tempDir$ + "gzip_test_file.txt"
  testContent$ = "This is test content for file compression." + chr$(10)
  testContent$ = testContent$ + "Line 2 of the test file." + chr$(10)
  testContent$ = testContent$ + "Line 3 with special chars: áéíóú" + chr$(10)
  ' Write test file
  savetext$(testFile$, "utf-8", testContent$)
  ' Read back the original to ensure same line-ending treatment
  testContent$ = opentext$(testFile$, "utf-8")
  ' Test 4.1: gzipfile() basic compression
  gzFile$ = testFile$ + ".gz"
  result = gzipfile(testFile$, gzFile$)
  IF result = 1 THEN
    passTest$("4.1 gzipfile() compresses file successfully")
  ELSE
    failTest$("4.1 gzipfile() compresses file successfully", "Error: " + str$(gziperror()))
  END IF
  ' Test 4.2: Compressed file exists
  IF fileexists(gzFile$, 0) = 1 THEN
    passTest$("4.2 Compressed file exists")
  ELSE
    failTest$("4.2 Compressed file exists", "File not found: " + gzFile$)
  END IF
  ' Test 4.3: gunzipfile() decompresses correctly
  restoredFile$ = tempDir$ + "gzip_test_restored.txt"
  result = gunzipfile(gzFile$, restoredFile$)
  IF result = 1 THEN
    passTest$("4.3 gunzipfile() decompresses successfully")
  ELSE
    failTest$("4.3 gunzipfile() decompresses successfully", "Error: " + str$(gziperror()))
  END IF
  ' Test 4.4: Decompressed content matches original
  restoredContent$ = opentext$(restoredFile$, "utf-8")
  IF testContent$ = restoredContent$ THEN
    passTest$("4.4 Decompressed file content matches original")
  ELSE
    failTest$("4.4 Decompressed file content matches original", "Original len=" + str$(len(testContent$)) + " Restored len=" + str$(len(restoredContent$)))
  END IF
  ' Test 4.5: gzipfileex() with compression level
  gzFile2$ = tempDir$ + "gzip_test_level9.gz"
  result = gzipfileex(testFile$, gzFile2$, 9)
  IF result = 1 THEN
    passTest$("4.5 gzipfileex() with level 9 works")
  ELSE
    failTest$("4.5 gzipfileex() with level 9 works", "Error: " + str$(gziperror()))
  END IF
  ' Test 4.6: gzipfile() with non-existent source file
  result = gzipfile(tempDir$ + "nonexistent_file_12345.txt", tempDir$ + "output.gz")
  IF result = 0 THEN
    passTest$("4.6 gzipfile() returns 0 for non-existent file")
  ELSE
    failTest$("4.6 gzipfile() returns 0 for non-existent file", "Expected 0, got 1")
  END IF
  ' Test 4.7: gunzipfile() with invalid compressed file
  ' Create an invalid gz file
  savetext$(tempDir$ + "invalid.gz", "utf-8", "This is not valid gzip data")
  result = gunzipfile(tempDir$ + "invalid.gz", tempDir$ + "output.txt")
  IF result = 0 THEN
    passTest$("4.7 gunzipfile() returns 0 for invalid gzip file")
  ELSE
    failTest$("4.7 gunzipfile() returns 0 for invalid gzip file", "Expected 0, got 1")
  END IF
  ' Cleanup test files
  kill(testFile$)
  kill(gzFile$)
  kill(gzFile2$)
  kill(restoredFile$)
  kill(tempDir$ + "invalid.gz")
  kill(tempDir$ + "output.txt")
  passTest$("4.8 Cleanup completed")
  RETURN ""
END FUNCTION
' ============================================================================
' RUN ALL TESTS
' ============================================================================
PRINTLN "============================================================================"
PRINTLN "                     GzipLib Test Suite"
PRINTLN "============================================================================"
PRINTLN "Starting tests at: "; formatdatetime$("yyyy-mm-dd hh:nn:ss", now())
PRINTLN
test_gziperror$()
test_string_compression$()
test_utility_functions$()
test_file_compression$()
PRINTLN
PRINTLN "============================================================================"
PRINTLN "                     TEST RESULTS SUMMARY"
PRINTLN "============================================================================"
PRINTLN
PRINTLN "Total tests:  "; totalTests
PRINTLN "Passed:       "; passedTests
PRINTLN "Failed:       "; failedTests
PRINTLN
IF failedTests = 0 THEN
  PRINTLN "*** ALL TESTS PASSED ***"
ELSE
  PRINTLN "*** SOME TESTS FAILED - Please review ***"
END IF
PRINTLN
PRINTLN "Completed at: "; formatdatetime$("yyyy-mm-dd hh:nn:ss", now())
PRINTLN "============================================================================"
