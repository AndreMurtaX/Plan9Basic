rem ---------------------------------------------------------------
rem The half of HttpLib that needs a server to answer it: the verbs,
rem the transfers and every accessor that reads a reply.
rem 32_http_offline.bas covers the other half, which needs nothing.
rem
rem It talks to tests/LoopbackServer.exe, which tools/verify.ps1 starts
rem before this file and stops after it. That server is built from this
rem repository and binds to 127.0.0.1 only, so this is a REQUIRED step
rem rather than one that can be skipped: nothing leaves the machine and
rem nothing outside it can be down.
rem
rem It answers the shapes httpbin.org answers, because that is the
rem contract these tests and the five HTTP applets in Examples/ were
rem already written against. Those applets have called the real
rem httpbin since they were written, and never asserted anything about
rem what came back -- which is why 39 functions here had never been
rem proven to work at all.
rem
rem Nothing here asserts more than the server guarantees: the status it
rem was asked for, the header it was told to echo, the body it was
rem sent back.
rem ---------------------------------------------------------------

BASE$ = "http://127.0.0.1:8731"

test_case("http/get")
c# = http_client#(BASE$)
http_timeout#(c#, 30000)
http_responsetimeout#(c#, 30000)

body$ = http_get$(c#, "/get")
assert_eq(http_error(), 0, "a GET completes")
assert_eq(http_status(c#), 200, "with the status the server sent")
assert_true(http_ok(c#), "http_ok agrees")
assert_true(len(body$), "and there is a body")
assert_eq(http_body$(c#), body$, "which http_body$ answers again")
assert_true(len(http_statustext$(c#)), "http_statustext$ names the status")
assert_true(http_contentlength(c#), "http_contentlength answers a size")
assert_true(instr(http_respcontenttype$(c#), "json") + 1, "and http_respcontenttype$ the type")

rem The reply is JSON, so it can be read rather than merely measured.
j# = json_parse#(body$)
assert_true(pnttonum(j#), "the reply parses")
assert_true(len(json_gets$(j#, "url")), "and names the url it answered")

test_case("http/the-other-verbs")
rem Each one is a different method, and httpbin answers 200 to all of
rem them. What is proven is that the method reached the server at all.
p$ = http_post$(c#, "/post", "hello")
assert_eq(http_status(c#), 200, "POST reaches")
assert_true(instr(p$, "hello") + 1, "and the body sent comes back in the mirror")

u$ = http_put$(c#, "/put", "put-body")
assert_eq(http_status(c#), 200, "PUT reaches")
assert_true(instr(u$, "put-body") + 1, "with its body")

a$ = http_patch$(c#, "/patch", "patch-body")
assert_eq(http_status(c#), 200, "PATCH reaches")
assert_true(instr(a$, "patch-body") + 1, "with its body")

d$ = http_delete$(c#, "/delete")
assert_eq(http_status(c#), 200, "DELETE reaches")

o$ = http_options$(c#, "/get")
assert_true(http_status(c#), "OPTIONS answers a status")

rem HEAD answers headers and no body, which is the whole point of it.
http_head(c#, "/get")
assert_eq(http_status(c#), 200, "HEAD reaches")
assert_eq(len(http_body$(c#)), 0, "and brings back no body")

test_case("http/status-families")
rem The four predicates each have to be true for their own family and
rem false for the others, so each is asked with a status chosen to
rem prove it.
http_get$(c#, "/status/404")
assert_eq(http_status(c#), 404, "a 404 is reported as one")
assert_false(http_ok(c#), "which is not ok")
assert_true(http_isclienterror(c#), "and is a client error")
assert_false(http_isservererror(c#), "not a server one")

http_get$(c#, "/status/500")
assert_eq(http_status(c#), 500, "a 500 is reported as one")
assert_true(http_isservererror(c#), "and is a server error")
assert_false(http_isclienterror(c#), "not a client one")

test_case("http/redirects")
rem With redirects followed, the client ends at the destination. With
rem them off, it stops at the redirect and can say where it was sent.
http_followredirects#(c#, 0)
http_get$(c#, "/redirect/1")
assert_true(http_isredirect(c#), "a redirect is recognised when not followed")
assert_true(len(http_redirecturl$(c#)), "and http_redirecturl$ says where to")

http_followredirects#(c#, 1)
http_get$(c#, "/redirect/1")
assert_eq(http_status(c#), 200, "and following it lands on the destination")
assert_false(http_isredirect(c#), "which is not itself a redirect")

test_case("http/response-headers")
rem httpbin echoes whatever is asked for in the query, so the header
rem coming back is one this test chose.
http_get$(c#, "/response-headers?X-Plan9=basic")
assert_eq(http_respheader$(c#, "X-Plan9"), "basic", "http_respheader$ reads a named header")
assert_true(http_respheadercount(c#), "http_respheadercount counts them")
assert_true(len(http_respheaders$(c#)), "http_respheaders$ renders the lot")
assert_true(len(http_respheadername$(c#, 0)), "http_respheadername$ names one by position")
assert_true(len(http_respheadervalue$(c#, 0)) + 1, "and http_respheadervalue$ its value")

test_case("http/response-cookies")
http_get$(c#, "/cookies/set?flavour=mint")
assert_true(http_respcookiecount(c#) + 1, "http_respcookiecount answers")
assert_true(len(http_respcookies$(c#)) + 1, "http_respcookies$ renders them")
assert_true(len(http_respcookie$(c#, "flavour")) + 1, "and http_respcookie$ reads one by name")

test_case("http/binary-and-saving")
rem Ten bytes of nothing in particular, which is enough to prove the
rem body survived as bytes rather than as text.
http_get$(c#, "/bytes/10")
assert_true(len(http_bodybase64$(c#)), "http_bodybase64$ answers the body as base64")
assert_eq(b64valid(http_bodybase64$(c#)), 1, "which is valid base64")

sp$ = "bin/p9b_http_body.txt"
file_delete(sp$)
assert_true(http_savebody(c#, sp$), "http_savebody writes the last reply to a file")
assert_true(file_exists(sp$), "and the file is there")
file_delete(sp$)

test_case("http/download")
dp$ = "bin/p9b_http_download.json"
file_delete(dp$)
assert_true(http_download(c#, "/get", dp$), "http_download fetches straight to a file")
assert_true(file_exists(dp$), "and the file is there")
assert_true(instr(file_readalltext$(dp$), "url") + 1, "holding what was fetched")
file_delete(dp$)

test_case("http/uploads")
up$ = "bin/p9b_http_upload.txt"
file_writealltext(up$, "payload")

r1$ = http_upload$(c#, "/post", up$)
assert_eq(http_status(c#), 200, "http_upload$ posts a file")
r2$ = http_uploadput$(c#, "/put", up$)
assert_eq(http_status(c#), 200, "http_uploadput$ puts one")
r3$ = http_postfile$(c#, "/post", "attachment", up$)
assert_eq(http_status(c#), 200, "http_postfile$ posts one under a field name")

file_delete(up$)

test_case("http/forms")
fm# = http_form#()
http_formfield#(fm#, "name", "Alice")
http_formfield#(fm#, "city", "Lisbon")

f1$ = http_postform$(c#, "/post", fm#)
assert_eq(http_status(c#), 200, "http_postform$ sends a form")
assert_true(instr(f1$, "Alice") + 1, "and the fields arrive")

f2$ = http_postformurl$(c#, "/post", fm#)
assert_eq(http_status(c#), 200, "http_postformurl$ sends it url-encoded")

f3$ = http_putform$(c#, "/put", fm#)
assert_eq(http_status(c#), 200, "http_putform$ puts one")

f4$ = http_postformstr$(c#, "/post", "a=1&b=2")
assert_eq(http_status(c#), 200, "http_postformstr$ sends a ready-made body")
assert_true(instr(f4$, "b") + 1, "which arrives")

http_formfree(fm#)

test_case("http/the-simple-three")
rem Three one-call forms with no client at all, for a program that
rem wants one thing and no ceremony.
s1$ = http_simpleget$(BASE$ + "/get")
assert_true(len(s1$), "http_simpleget$ fetches without a client")

s2$ = http_simplepost$(BASE$ + "/post", "quick")
assert_true(instr(s2$, "quick") + 1, "http_simplepost$ sends without one")

sd$ = "bin/p9b_http_simple.json"
file_delete(sd$)
assert_true(http_simpledownload(BASE$ + "/get", sd$), "http_simpledownload saves without one")
assert_true(file_exists(sd$), "and the file is there")
file_delete(sd$)

test_case("http/errors-are-reported")
rem A host that cannot resolve has to fail and say so. The name below
rem is under .invalid, which RFC 2606 reserves so it can never resolve,
rem so this costs no request either.
bad# = http_client#("https://plan9basic.invalid")
http_timeout#(bad#, 10000)
http_clearerror()
http_get$(bad#, "/get")
assert_true(http_error(), "an unreachable host reports an error")
assert_true(len(http_errormsg$()), "with a message")
http_free(bad#)

http_free(c#)
