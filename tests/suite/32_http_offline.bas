rem ---------------------------------------------------------------
rem HttpLib, the half that needs no network. check-coverage.py
rem reported 0/91 -- nothing in this library had ever been run by a
rem test, and the five applets in Examples/ that do exercise it make
rem live calls to httpbin.org and assert nothing about the answers.
rem
rem A client is a bag of settings until a verb is called. Building it,
rem configuring it, filling in a form and encoding a string are all
rem offline, and that is most of the library. The verbs and the
rem response accessors need a server and are not attempted here --
rem what is missing is named at the end of this file rather than left
rem for somebody to notice.
rem ---------------------------------------------------------------

test_case("http/construction")
c# = http_client#("https://example.invalid")
assert_true(pnttonum(c#), "http_client# answers a handle")
assert_eq(http_baseurl$(c#), "https://example.invalid", "which remembers the base url it was given")

bare# = http_client#()
assert_true(pnttonum(bare#), "the no-argument form answers one too")
assert_eq(http_baseurl$(bare#), "", "with no base url")

http_baseurl#(bare#, "https://elsewhere.invalid")
assert_eq(http_baseurl$(bare#), "https://elsewhere.invalid", "which can be set afterwards")

test_case("http/timeouts")
rem Both take milliseconds. Only the connect timeout has a getter, so
rem the response timeout is exercised for reachability rather than for
rem a value it will not report back.
http_timeout#(c#, 5000)
assert_eq(http_timeout(c#), 5000, "http_timeout holds what it was given")
http_timeout#(c#, 30000)
assert_eq(http_timeout(c#), 30000, "and takes a new value")
http_responsetimeout#(c#, 15000)

test_case("http/request-headers")
assert_eq(http_headercount(c#), 0, "a new client carries no headers")

http_header#(c#, "X-One", "first")
http_header#(c#, "X-Two", "second")
assert_eq(http_headercount(c#), 2, "http_header# adds them")
assert_eq(http_header$(c#, "X-One"), "first", "and http_header$ reads one back")
assert_eq(http_header$(c#, "X-Absent"), "", "a header that was never set reads empty")

http_header#(c#, "X-One", "changed")
assert_eq(http_headercount(c#), 2, "setting an existing name replaces rather than adds")
assert_eq(http_header$(c#, "X-One"), "changed", "with the new value")

http_headerremove#(c#, "X-One")
assert_eq(http_headercount(c#), 1, "http_headerremove# takes one out")
assert_eq(http_header$(c#, "X-One"), "", "and it is gone")

http_headerclear#(c#)
assert_eq(http_headercount(c#), 0, "http_headerclear# empties them")

test_case("http/query-parameters")
http_param#(c#, "page", "2")
http_param#(c#, "sort", "name")
assert_eq(http_param$(c#, "page"), "2", "http_param# stores a query parameter")
assert_eq(http_param$(c#, "absent"), "", "and an unset one reads empty")

http_paramremove#(c#, "page")
assert_eq(http_param$(c#, "page"), "", "http_paramremove# takes one out")
http_paramclear#(c#)
assert_eq(http_param$(c#, "sort"), "", "and http_paramclear# takes the rest")

test_case("http/cookies")
assert_eq(http_cookiecount(c#), 0, "a new client carries no cookies")
http_cookie#(c#, "session", "abc123")
http_cookie#(c#, "theme", "dark")
assert_eq(http_cookiecount(c#), 2, "http_cookie# adds them")
assert_eq(http_cookie$(c#, "session"), "abc123", "http_cookie$ reads one back")

http_cookieremove#(c#, "session")
assert_eq(http_cookiecount(c#), 1, "http_cookieremove# takes one out")
http_cookieclear#(c#)
assert_eq(http_cookiecount(c#), 0, "and http_cookieclear# takes the rest")

test_case("http/authentication")
rem None of the three has a getter -- the credential is not readable
rem back by design -- so what is asserted is that each is reachable,
rem answers the client for chaining, and leaves no error behind.
http_clearerror()
http_basicauth#(c#, "user", "secret")
assert_eq(http_error(), 0, "http_basicauth# sets without complaint")
http_bearerauth#(c#, "a-token")
assert_eq(http_error(), 0, "http_bearerauth# too")
http_customauth#(c#, "Negotiate abc")
assert_eq(http_error(), 0, "and http_customauth#")
http_clearauth#(c#)
assert_eq(http_error(), 0, "http_clearauth# removes whichever was set")

test_case("http/proxy")
http_proxy#(c#, "proxy.invalid", 8080)
assert_eq(http_error(), 0, "http_proxy# takes a host and a port")
http_proxyauth#(c#, "puser", "ppass")
assert_eq(http_error(), 0, "http_proxyauth# takes credentials for it")
http_clearproxy#(c#)
assert_eq(http_error(), 0, "and http_clearproxy# removes it")

test_case("http/behaviour-flags")
http_useragent#(c#, "Plan9Basic-Test/1.0")
http_contenttype#(c#, "application/json")
http_accept#(c#, "application/json")
http_followredirects#(c#, 1)
http_maxredirects#(c#, 3)
http_validatessl#(c#, 1)
assert_eq(http_error(), 0, "the whole configuration surface is reachable without a request")

test_case("http/reset")
rem reset returns the client to how it left the factory, which is what
rem makes one client reusable for unrelated requests.
http_header#(c#, "X-Kept", "value")
http_cookie#(c#, "c", "v")
http_reset#(c#)
assert_eq(http_headercount(c#), 0, "http_reset# clears the headers")
assert_eq(http_cookiecount(c#), 0, "and the cookies")

test_case("http/forms")
f# = http_form#()
assert_true(pnttonum(f#), "http_form# answers a handle")
assert_eq(http_formfieldcount(f#), 0, "a new form is empty")
assert_eq(http_formfilecount(f#), 0, "of both kinds")

http_formfield#(f#, "name", "Alice")
http_formfield#(f#, "city", "Lisbon")
assert_eq(http_formfieldcount(f#), 2, "http_formfield# adds text fields")

rem The url-encoded rendering is the only way to see a form without
rem sending it, and it walks the TEXT fields only.
enc$ = http_formurlencoded$(f#)
assert_true(instr(enc$, "name=Alice") + 1, "http_formurlencoded$ renders a field")
assert_true(instr(enc$, "&") + 1, "and joins them with an ampersand")

test_case("http/form-files")
rem A file field needs a file that exists, so one is made under bin\ .
p$ = "bin/p9b_http_upload.txt"
file_writealltext(p$, "payload")

http_formfile#(f#, "attachment", p$)
assert_eq(http_formfilecount(f#), 1, "http_formfile# adds a file field")
http_formfilenamed#(f#, "renamed", p$, "other.txt")
assert_eq(http_formfilecount(f#), 2, "http_formfilenamed# adds one under a chosen name")
http_formfiletype#(f#, "typed", p$, "typed.txt", "text/plain")
assert_eq(http_formfilecount(f#), 3, "http_formfiletype# adds one with a stated type")

rem The rendering still shows only the text fields, which is why the
rem name a file field carries cannot be checked from BASIC at all.
assert_eq(instr(http_formurlencoded$(f#), "attachment"), -1, "the url-encoded form skips file fields")

http_formclear#(f#)
assert_eq(http_formfieldcount(f#), 0, "http_formclear# empties the text fields")
assert_eq(http_formfilecount(f#), 0, "and the file fields")
http_formfree(f#)
file_delete(p$)

test_case("http/encoding-helpers")
rem Four pure functions with no client and no network in them.
rem
rem A space is %20 and not '+'. TNetEncoding.URL.Encode writes '+',
rem which is form encoding and is correct in a form body -- but this
rem function builds URLs, where '+' is an ordinary character, and the
rem reference for it shows "hello%20world%20%26%20more".
assert_eq(http_urlencode$("a b"), "a%20b", "http_urlencode$ percent-encodes a space")
assert_eq(http_urlencode$("a+b"), "a%2Bb", "and a literal plus is %2B, which is why the two never collide")
assert_eq(http_urldecode$("a%20b"), "a b", "http_urldecode$ puts it back")
assert_eq(http_urldecode$("a+b"), "a b", "and still reads the form spelling, so old data keeps working")
assert_eq(http_urldecode$("a%2Bb"), "a+b", "while %2B stays a plus")
assert_eq(http_urldecode$(http_urlencode$("a=b&c")), "a=b&c", "and the pair round-trips")

assert_eq(http_htmlencode$("<b>"), "&lt;b&gt;", "http_htmlencode$ escapes markup")
assert_eq(http_htmldecode$("&lt;b&gt;"), "<b>", "http_htmldecode$ puts it back")
assert_eq(http_htmldecode$(http_htmlencode$("a & b")), "a & b", "and that pair round-trips too")

test_case("http/errors")
http_clearerror()
assert_eq(http_error(), 0, "http_clearerror clears the code")
assert_true(len(http_strerror$(0)), "http_strerror$ names a code")

test_case("http/handles")
rem The registry is what lets a fabricated pointer be refused without
rem following it.
junk# = pointer#(305419896)
http_clearerror()
n = http_headercount(junk#)
assert_eq(n, 0, "an invented client answers nothing")
assert_true(http_error(), "and says so")

http_free(c#)
http_free(bare#)

rem ---------------------------------------------------------------
rem NOT COVERED HERE, and it is half the library: the verbs
rem (http_get$, http_post$, http_put$, http_patch$, http_delete$,
rem http_head, http_options$), the transfers (http_download,
rem http_upload$, http_postfile$, http_savebody) and every response
rem accessor (http_status, http_body$, http_respheader$, http_ok and
rem the rest) need a server to answer them.
rem
rem Examples/ reaches them by calling httpbin.org for real, on every
rem verification run, and asserting nothing about what comes back. A
rem loopback server in the harness is what would close this, and that
rem is a decision about the test bench rather than about the engine.
rem ---------------------------------------------------------------
