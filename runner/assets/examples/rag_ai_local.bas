' ============================================================================
' rag_ai_local.bas - Retrieval-augmented answering, entirely on this machine
' ============================================================================
' RAGLib finds the part of a document set that a question needs. AILib sends
' that to a model. Together they let a small local model answer questions about
' material it was never trained on -- which is the whole point of RAG.
'
' This program shows the two libraries working as a pair:
'
'   1. write a small knowledge base to disk and index it        (RAGLib)
'   2. retrieve only what one question needs, within a budget   (RAGLib)
'   3. ask a local model the SAME question twice -- once bare,
'      once with the retrieved text in front of it              (AILib)
'   4. keep asking, with the conversation remembering itself    (AILib)
'
' Nothing leaves this machine. ai_client#("ollama", "") resolves to
' http://localhost:11434 and sends no API key, because a local model wants none.
'
' TO RUN
'   1. Install Ollama from https://ollama.com
'   2. ollama pull gemma3:4b     (any model will do -- see MODEL$ below)
'   3. Run this program
'
' With no Ollama running it explains what is missing and stops without failing:
' a machine without a model is a normal machine, not a broken one.
' ============================================================================

LET MODEL$ = "gemma3:4b"
LET HOST$  = "http://localhost:11434"
LET KB$    = "p9b_example_kb"

PRINTLN "=== RAGLib + AILib, local ==="
PRINTLN ""

' --------------------------------------------------------------------------
' 1. Is there a model to talk to?
' --------------------------------------------------------------------------
' Asked before anything else, so the program can say something useful instead
' of failing four steps later with a connection error. /api/tags also names
' what IS installed, which lets the example run on a machine that pulled a
' different model without anybody editing this file.
PRINTLN "1. Looking for Ollama on " + HOST$
LET probe# = http_client#(HOST$)
http_timeout#(probe#, 4000)
LET tags$ = http_get$(probe#, "/api/tags")
LET ready = 0
IF http_ok(probe#) <> 0 THEN LET ready = 1

IF ready = 0 THEN
  PRINTLN "   Ollama is not answering there."
  PRINTLN ""
  PRINTLN "   Install it from https://ollama.com, then:"
  PRINTLN "     ollama pull " + MODEL$
  PRINTLN ""
  PRINTLN "   Everything below needs a model, so there is nothing more to do."
END IF

IF ready = 1 THEN
  LET root# = json_parse#(tags$)
  LET models# = json_get#(root#, "models")
  LET count = json_len(models#)
  LET have = 0
  FOR i = 0 TO count - 1
    LET nm$ = json_gets$(json_item#(models#, i), "name")
    IF nm$ = MODEL$ THEN LET have = 1
  NEXT i

  ' Any model can answer this; the example should not insist on one particular
  ' download just because it was written against it.
  IF have = 0 THEN
    IF count > 0 THEN
      LET MODEL$ = json_gets$(json_item#(models#, 0), "name")
      PRINTLN "   using " + MODEL$ + " (the model this example names is not pulled)"
    END IF
    IF count = 0 THEN
      PRINTLN "   Ollama is running but has no models. Try: ollama pull gemma3:4b"
      LET ready = 0
    END IF
  END IF
  IF have = 1 THEN PRINTLN "   found " + MODEL$
END IF

' --------------------------------------------------------------------------
' 2. A knowledge base, written here so the example is self-contained
' --------------------------------------------------------------------------
' RAGEngine reads markdown files that open with a YAML-style header. The header
' is what makes retrieval cheap: tags and function names are scored without the
' body ever being read, and only the documents that win get loaded.
IF ready = 1 THEN
  PRINTLN ""
  PRINTLN "2. Building a knowledge base in " + KB$
  IF dir_exists(KB$) <> 0 THEN dir_delete(KB$, 1)
  dir_create(KB$)

  LET d$ = "---" + chr$(10)
  LET d$ = d$ + "id: buttons" + chr$(10)
  LET d$ = d$ + "title: Buttons" + chr$(10)
  LET d$ = d$ + "category: library" + chr$(10)
  LET d$ = d$ + "tags: button, click, event, gui" + chr$(10)
  LET d$ = d$ + "functions: button#, button_text#, button_onclick#" + chr$(10)
  LET d$ = d$ + "complexity: beginner" + chr$(10)
  LET d$ = d$ + "platform: all" + chr$(10)
  LET d$ = d$ + "---" + chr$(10)
  LET d$ = d$ + "# Buttons" + chr$(10) + chr$(10)
  LET d$ = d$ + "button#(parent#, x, y, w, h) creates a button." + chr$(10)
  LET d$ = d$ + "button_text#(b#, caption$) sets what it says." + chr$(10)
  LET d$ = d$ + "button_onclick#(b#, handler$) names a SUB to run when it is" + chr$(10)
  LET d$ = d$ + "clicked. The handler is named as a string, and an empty string" + chr$(10)
  LET d$ = d$ + "unwires it again." + chr$(10)
  file_writealltext(KB$ + "/buttons.md", d$)

  LET d$ = "---" + chr$(10)
  LET d$ = d$ + "id: timers" + chr$(10)
  LET d$ = d$ + "title: Timers" + chr$(10)
  LET d$ = d$ + "category: library" + chr$(10)
  LET d$ = d$ + "tags: timer, interval, repeat, time" + chr$(10)
  LET d$ = d$ + "functions: timer#, timer_interval#, timer_ontimer#" + chr$(10)
  LET d$ = d$ + "complexity: beginner" + chr$(10)
  LET d$ = d$ + "platform: all" + chr$(10)
  LET d$ = d$ + "---" + chr$(10)
  LET d$ = d$ + "# Timers" + chr$(10) + chr$(10)
  LET d$ = d$ + "timer#(parent#) creates a timer, stopped." + chr$(10)
  LET d$ = d$ + "timer_interval#(t#, ms) sets how often it fires." + chr$(10)
  LET d$ = d$ + "timer_ontimer#(t#, handler$) names the SUB it calls." + chr$(10)
  file_writealltext(KB$ + "/timers.md", d$)

  LET d$ = "---" + chr$(10)
  LET d$ = d$ + "id: http" + chr$(10)
  LET d$ = d$ + "title: HTTP" + chr$(10)
  LET d$ = d$ + "category: library" + chr$(10)
  LET d$ = d$ + "tags: http, network, request, web" + chr$(10)
  LET d$ = d$ + "functions: http_client#, http_get$, http_post$" + chr$(10)
  LET d$ = d$ + "complexity: intermediate" + chr$(10)
  LET d$ = d$ + "platform: all" + chr$(10)
  LET d$ = d$ + "---" + chr$(10)
  LET d$ = d$ + "# HTTP" + chr$(10) + chr$(10)
  LET d$ = d$ + "http_client#(baseurl$) opens a client." + chr$(10)
  LET d$ = d$ + "http_get$(c#, path$) fetches, http_post$(c#, path$, body$) sends." + chr$(10)
  file_writealltext(KB$ + "/http.md", d$)

  LET kb# = rag#(KB$)
  rag_rebuild#(kb#)
  PRINTLN "   " + str$(rag_count(kb#)) + " documents, " + str$(rag_funccount(kb#)) + " functions indexed"
END IF

' --------------------------------------------------------------------------
' 3. Retrieval: the part the question actually needs
' --------------------------------------------------------------------------
IF ready = 1 THEN
  LET Q$ = "How do I run some code when a button is clicked?"
  PRINTLN ""
  PRINTLN "3. Question: " + Q$

  ' rag_analyze$ shows the scoring's reasoning -- useful while tuning a base,
  ' and the first thing to read when retrieval brings back the wrong document.
  PRINTLN "   analysis: " + rag_analyze$(kb#, Q$)

  ' The budget is a TOKEN budget, and it is what keeps a growing knowledge base
  ' from quietly outgrowing the model's context window. Ask for less and the
  ' retrieved text is cut to fit.
  LET ctx$ = rag_retrieve_budget$(kb#, Q$, 400)
  PRINTLN "   retrieved " + str$(len(ctx$)) + " characters within a 400-token budget"
END IF

' --------------------------------------------------------------------------
' 4. The same question, bare and grounded
' --------------------------------------------------------------------------
' Two calls, one difference: the second is given the retrieved text as its
' system prompt. The first answer is the model guessing about a language it
' most likely never saw; the second is the model reading.
IF ready = 1 THEN
  PRINTLN ""
  PRINTLN "4. Asking " + MODEL$
  LET ai# = ai_client#("ollama", "")
  ai_model#(ai#, MODEL$)
  ai_temperature#(ai#, 0)
  ai_maxtokens#(ai#, 200)
  ai_timeout#(ai#, 120000)

  PRINTLN ""
  PRINTLN "   --- without the knowledge base ---"
  LET bare$ = ai_complete$(ai#, Q$ + " Answer in two sentences.")
  IF ai_ok(ai#) <> 0 THEN
    PRINTLN "   " + bare$
  ELSE
    PRINTLN "   failed: " + ai_errormsg$()
  END IF

  PRINTLN ""
  PRINTLN "   --- with it ---"
  LET SYS$ = "Answer using only the reference material below. If it does not "
  LET SYS$ = SYS$ + "cover the question, say so." + chr$(10) + chr$(10) + ctx$
  LET grounded$ = ai_completesystem$(ai#, SYS$, Q$ + " Answer in two sentences.")
  IF ai_ok(ai#) <> 0 THEN
    PRINTLN "   " + grounded$
  ELSE
    PRINTLN "   failed: " + ai_errormsg$()
  END IF

  PRINTLN ""
  PRINTLN "   tokens: " + str$(ai_tokensin(ai#)) + " in, " + str$(ai_tokensout(ai#)) + " out"
END IF

' --------------------------------------------------------------------------
' 5. A conversation remembers what a completion forgets
' --------------------------------------------------------------------------
' ai_complete$ is one question and one answer, with nothing kept. ai_chat$ keeps
' the history and sends it every turn, which is why the follow-up below can say
' "it" and still be understood.
IF ready = 1 THEN
  PRINTLN ""
  PRINTLN "5. A follow-up, using the chat history"
  ai_clearchat(ai#)
  ai_system#(ai#, SYS$)

  LET t1$ = ai_chat$(ai#, "Which function wires a click handler? Name it only.")
  IF ai_ok(ai#) <> 0 THEN PRINTLN "   Q1 -> " + t1$

  ' Nothing in this sentence names the function. Only the history carries it.
  LET t2$ = ai_chat$(ai#, "How do I unwire it again? One sentence.")
  IF ai_ok(ai#) <> 0 THEN PRINTLN "   Q2 -> " + t2$

  ai_clearchat(ai#)
END IF

' --------------------------------------------------------------------------
' 6. Tidy up
' --------------------------------------------------------------------------
IF ready = 1 THEN
  LET x = ai_free(ai#)
  LET x = rag_free(kb#)
  dir_delete(KB$, 1)
  PRINTLN ""
  PRINTLN "Done."
END IF
