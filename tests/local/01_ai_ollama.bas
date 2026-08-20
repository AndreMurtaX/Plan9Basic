rem ---------------------------------------------------------------
rem AILib against a model running on this machine.
rem
rem THIS FILE IS NOT PART OF THE ORDINARY SUITE. It needs Ollama
rem listening on localhost:11434 with at least one model pulled, which
rem a clone does not have. tools/verify.ps1 probes for it and reports
rem the step as skipped when it is absent, so a machine without a model
rem is never a red build -- and a machine with one is never a silent
rem pass either.
rem
rem What makes this worth doing at all: AILib was built with a local
rem provider in mind. ai_client#("ollama", "") resolves to
rem http://localhost:11434/v1/chat/completions with no key, and nothing
rem had ever called it. check-coverage.py reported 0/45 and the reason
rem given was "needs credentials and a network". Half of that was
rem wrong: it needs neither.
rem
rem The model is asked for one word at temperature 0, so the answers
rem are as close to deterministic as a language model gets. Nothing is
rem asserted about the CONTENT of a longer reply -- that would be
rem asserting the model rather than the library.
rem ---------------------------------------------------------------

MODEL$ = "qwen2.5:7b"

test_case("ai/client")
c# = ai_client#("ollama", "")
assert_true(pnttonum(c#), "ai_client# answers a handle")
assert_eq(ai_provider$(c#), "ollama", "which remembers the provider it was asked for")
assert_eq(ai_baseurl$(c#), "http://localhost:11434/v1/chat/completions", "and resolves the local endpoint")
assert_eq(ai_error(), 0, "with nothing to report")

rem The default model for this provider is llama3, which is not what is
rem necessarily installed -- so a program has to say which one it wants.
assert_true(len(ai_model$(c#)), "a provider comes with a default model")
ai_model#(c#, MODEL$)
assert_eq(ai_model$(c#), MODEL$, "ai_model# names the one to use")

test_case("ai/settings")
ai_temperature#(c#, 0)
ai_maxtokens#(c#, 16)
ai_timeout#(c#, 120000)
assert_eq(ai_error(), 0, "the request settings are reachable")

rem The base url and key can be overridden even for a named provider,
rem which is what makes any OpenAI-compatible server usable.
ai_baseurl#(c#, "http://localhost:11434/v1/chat/completions")
assert_eq(ai_baseurl$(c#), "http://localhost:11434/v1/chat/completions", "ai_baseurl# takes an endpoint")
ai_apikey#(c#, "")
assert_eq(ai_error(), 0, "and ai_apikey# an empty key, which is what a local model wants")

test_case("ai/a-real-completion")
rem One word, temperature zero. What is asserted is that a request went
rem out, a reply came back and the library reported no error -- not
rem what the model chose to say.
a$ = ai_complete$(c#, "Reply with exactly one word: OK")
assert_eq(ai_error(), 0, "the request completed without an error")
assert_eq(ai_errormsg$(), "", "and left no message")
assert_true(len(a$), "the model answered something")

test_case("ai/system-prompt")
rem The two-part form puts a system instruction in front of the
rem question, which is the difference between the two completions.
b$ = ai_completesystem$(c#, "You answer with a single digit and nothing else.", "What is two plus two?")
assert_eq(ai_error(), 0, "the system form completed")
assert_true(len(b$), "and answered")

test_case("ai/chat-keeps-a-conversation")
rem chat is completion with memory: the second turn can only be
rem answered by a model that was told the first.
ai_clearchat(c#)
one$ = ai_chat$(c#, "My name is Ada. Reply with just: noted")
assert_eq(ai_error(), 0, "the first turn completed")
assert_true(len(one$), "and answered")

two$ = ai_chat$(c#, "What name did I give you? Reply with the name only.")
assert_eq(ai_error(), 0, "the second turn completed")
assert_true(len(two$), "and answered")

rem This is the one content assertion in the file, and it is about the
rem LIBRARY rather than the model: if the history were not being sent,
rem no model could answer this, because the name appears nowhere in the
rem second question.
assert_true(instr(lcase$(two$), "ada") + 1, "the model remembered a name only the history carries")

ai_clearchat(c#)
assert_eq(ai_error(), 0, "ai_clearchat forgets the conversation")

test_case("ai/token-accounting")
rem The library counts what went out and what came back, which is the
rem part a program budgets against. Counted separately, because for a
rem paid provider the two do not cost the same.
if ai_tokensin(c#) >= 0 then tin_ok = 1
assert_true(tin_ok, "ai_tokensin answers a count")
if ai_tokensout(c#) >= 0 then tout_ok = 1
assert_true(tout_ok, "ai_tokensout answers one too")
rem ai_tokensin and ai_tokensout take the CLIENT. The ai_conversation_*
rem family takes a CONVERSATION, including the two that read like more
rem client accounting -- handing them a client answers "Invalid
rem conversation pointer", which is the library being right and the
rem name being inviting. They are exercised further down, where there
rem is a conversation to give them.

test_case("ai/request-shaping")
rem Everything a program can put on a request before it goes out, none
rem of which needs a reply to be checked -- the values are the client's
rem own state until then.
ai_system#(c#, "You are terse.")
ai_topp#(c#, 0.9)
ai_stop#(c#, "END")
ai_clearstop#(c#)
ai_useragent#(c#, "Plan9Basic-Test/1.0")
ai_header#(c#, "X-Trace", "one")
ai_headerremove#(c#, "X-Trace")
ai_headerclear#(c#)
assert_eq(ai_error(), 0, "the whole request-shaping surface is reachable")

rem ai_endpoint# is NOT another spelling of ai_baseurl#. The base is a
rem URL and the endpoint is a PATH APPENDED to it -- the request goes
rem to base + endpoint -- so handing the full address to the second one
rem sends it twice and answers 404.
ai_baseurl#(c#, "http://localhost:11434")
ai_endpoint#(c#, "/v1/chat/completions")
p$ = ai_complete$(c#, "Reply with exactly one word: split")
assert_eq(ai_error(), 0, "a base and a path compose into a working address")
assert_true(len(p$), "and the model answers through it")

rem Put it back the way the provider resolved it, so the rest of the
rem file is testing the ordinary path.
ai_endpoint#(c#, "")
ai_baseurl#(c#, "http://localhost:11434/v1/chat/completions")

test_case("ai/response-inspection")
rem After a real exchange the client can be asked how it went, in more
rem detail than the answer alone.
d$ = ai_complete$(c#, "Reply with exactly one word: fine")
assert_true(ai_ok(c#), "ai_ok says the exchange succeeded")
assert_eq(ai_status(c#), 200, "with the status the server sent")
assert_true(len(ai_body$(c#)), "and ai_body$ keeps the raw reply")
assert_true(len(ai_strerror$(0)), "ai_strerror$ names a code")

test_case("ai/conversations-as-objects")
rem A conversation can be held apart from the client, which is what
rem lets one client serve several of them.
v# = ai_conversation#()
assert_true(pnttonum(v#), "ai_conversation# answers a handle")
ai_conversation_system#(v#, "You answer in one word.")
assert_eq(ai_conversation_count(v#), 0, "a new conversation has no turns")

r$ = ai_ask$(c#, v#, "Reply with exactly one word: yes")
assert_eq(ai_error(), 0, "ai_ask$ runs a turn through the conversation")
assert_true(len(r$), "and answers")
assert_true(ai_conversation_count(v#), "which the conversation now counts")

rem The two that take a conversation rather than a client.
if ai_conversation_tokens(v#) >= 0 then ctok_ok = 1
assert_true(ctok_ok, "ai_conversation_tokens counts the exchange")
assert_true(len(ai_conversation_last$(v#)), "and ai_conversation_last$ holds the last reply")

ai_conversation_maxhistory#(v#, 4)
ai_conversation_clear(v#)
assert_eq(ai_conversation_count(v#), 0, "ai_conversation_clear empties it")
assert_eq(ai_conversation_free(v#), 1, "and ai_conversation_free reports success")

test_case("ai/streaming")
rem The streaming form calls a handler per token and accumulates what
rem it received. The handler is stored by name; whether it fires is the
rem host's business, and what is pinned here is that the call completes
rem and the buffer holds what came back.
ai_ontoken#(c#, "on_token")
ai_chatstream(c#, "Reply with exactly one word: done")
assert_eq(ai_error(), 0, "ai_chatstream completes")
assert_true(len(ai_streambuffer$(c#)), "and ai_streambuffer$ holds what arrived")
ai_ontoken#(c#, "")

test_case("ai/errors-are-reported")
rem A model that is not installed has to fail and say so, rather than
rem answer an empty string that reads like a terse reply.
bad# = ai_client#("ollama", "")
ai_model#(bad#, "no-such-model-exists:0b")
ai_timeout#(bad#, 30000)
ai_clearerror()
x$ = ai_complete$(bad#, "hello")
assert_true(ai_error(), "an unknown model reports an error")
assert_true(len(ai_errormsg$()), "with a message")
ai_free(bad#)

test_case("ai/free")
assert_eq(ai_free(c#), 1, "ai_free reports success")
