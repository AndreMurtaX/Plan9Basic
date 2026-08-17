# Plan9Basic AI Integration Guide

## Step-by-Step Tutorial for Integrating the Intelligence Engine

This guide walks you through integrating the 10 AI units into the Plan9Basic interpreter.
By the end, your BASIC programs will have access to 92 new functions covering AI communication,
knowledge retrieval, skill-based code generation, tool-use, and the full Intelligence Engine pipeline.

---

## Overview of the Units

| Unit | Role | BASIC Functions | Registration Signature |
|------|------|-----------------|----------------------|
| `AILib.pas` | AI transport (Layer 1) | 45 | `RegisterAIFuncs(Funcs, Eng, OutP)` |
| `RAGEngine.pas` | Knowledge retrieval engine | — | *(internal, no registration)* |
| `RAGDocGenerator.pas` | Documentation generator | — | *(internal, no registration)* |
| `RAGLib.pas` | RAG bindings for BASIC | 13 | `RegisterRAGFuncs(Lib)` |
| `SkillEngine.pas` | Skill templates + selection | — | *(internal, no registration)* |
| `SkillLib.pas` | Skill bindings for BASIC | 13 | `RegisterSkillFuncs(Lib)` |
| `PromptAssembler.pas` | Prompt orchestrator | — | *(internal, no registration)* |
| `IntelligenceEngine.pas` | Main orchestrator | — | *(internal, no registration)* |
| `ToolExecutor.pas` | Tool registry + dispatcher | — | *(internal, no registration)* |
| `P9EngineLib.pas` | Engine bindings for BASIC | 21 | `RegisterP9EngineFuncs(Lib)` |

**Key insight:** Only 4 units register BASIC functions. The other 6 are internal
Delphi components used by the binding libraries. However, all 10 must be in the project
because they depend on each other.

---

## Step 1: Copy Files to the Project

Create a new subfolder under your `Libs` directory to keep the AI units organized:

```
Plan9Basic/
├── Libs/
│   ├── AI/                          ← NEW FOLDER
│   │   ├── AILib.pas
│   │   ├── RAGEngine.pas
│   │   ├── RAGDocGenerator.pas
│   │   ├── RAGLib.pas
│   │   ├── SkillEngine.pas
│   │   ├── SkillLib.pas
│   │   ├── PromptAssembler.pas
│   │   ├── IntelligenceEngine.pas
│   │   ├── ToolExecutor.pas
│   │   └── P9EngineLib.pas
│   ├── GUI/
│   ├── ArrayLib.pas
│   ├── ...
```

Copy all 10 `.pas` files into `Libs\AI\`.

---

## Step 2: Add Units to the Project File (Plan9Basic.dpr)

Open `Plan9Basic.dpr` and add the 10 new units to the `uses` clause.
Add them at the end, just before the closing semicolon, after `IOUtilsLib`:

```pascal
  SQLiteLib in 'Libs\SQLiteLib.pas',
  IOUtilsLib in 'Libs\IOUtilsLib.pas',

  // AI Intelligence Engine (Layer 1 - Transport)
  AILib in 'Libs\AI\AILib.pas',

  // AI Intelligence Engine (Layer 2 - Intelligence)
  RAGEngine in 'Libs\AI\RAGEngine.pas',
  RAGDocGenerator in 'Libs\AI\RAGDocGenerator.pas',
  SkillEngine in 'Libs\AI\SkillEngine.pas',
  PromptAssembler in 'Libs\AI\PromptAssembler.pas',
  IntelligenceEngine in 'Libs\AI\IntelligenceEngine.pas',
  ToolExecutor in 'Libs\AI\ToolExecutor.pas',

  // AI Intelligence Engine (BASIC Bindings)
  RAGLib in 'Libs\AI\RAGLib.pas',
  SkillLib in 'Libs\AI\SkillLib.pas',
  P9EngineLib in 'Libs\AI\P9EngineLib.pas';
```

**Important:** The order matters because of unit dependencies. `AILib` must come before
`IntelligenceEngine` (which uses it), and both `RAGEngine` and `SkillEngine` must come
before `PromptAssembler`. `ToolExecutor` must come before `IntelligenceEngine`.
The binding libraries (`RAGLib`, `SkillLib`, `P9EngineLib`) come last because they
depend on everything above.

---

## Step 3: Add Units to UnitMain.pas Uses Clause

In `UnitMain.pas`, the library units are listed in the **implementation** `uses` clause
(not the interface). Add the 4 binding units plus `AILib` and `ToolExecutor` at the end:

Find the current end of the implementation uses:

```pascal
  MediaPlayerLib, SQLiteLib, IOUtilsLib;
```

Change it to:

```pascal
  MediaPlayerLib, SQLiteLib, IOUtilsLib,
  // AI Intelligence Engine
  AILib, RAGLib, SkillLib, P9EngineLib, ToolExecutor;
```

**Note:** You only need to add the units that have `Register*` procedures, plus
`ToolExecutor` (needed for the `TToolExecutor` type used in `RegisterEditorTools`).
The internal units (`RAGEngine`, `RAGDocGenerator`, `SkillEngine`, `PromptAssembler`,
`IntelligenceEngine`) are used internally by the binding units and will be compiled
automatically through their own `uses` clauses. However, having them in the `.dpr`
ensures they appear in the Project Manager and are easy to navigate in the IDE.

---

## Step 4: Register Functions in InitBASICEngine

In `UnitMain.pas`, find the `InitBASICEngine` procedure. At the end of the library
registration block, just before `FBasic.OnPrintOutput := HandlePrintOutput;`,
add the 4 registration calls:

```pascal
  IOUtilsLib.RegisterIOUtilsFuncs(FBasic.Functions);

  // AI Intelligence Engine
  AILib.RegisterAIFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  RAGLib.RegisterRAGFuncs(FBasic.Functions);
  SkillLib.RegisterSkillFuncs(FBasic.Functions);
  P9EngineLib.RegisterP9EngineFuncs(FBasic.Functions);

  FBasic.OnPrintOutput := HandlePrintOutput;
end;
```

**Additionally**, in `FormCreate`, hook up the editor tool registration callback.
This allows the Intelligence Engine to register 8 editor tools (load_editor,
compile_check, run_program, etc.) when a BASIC program creates an engine:

```pascal
procedure TfrmMain.FormCreate(Sender: TObject);
begin
  // ... existing FormCreate code ...

  // Hook up editor tool registration for AI tool-use
  P9EngineLib.OnEditorToolRegistration := RegisterEditorTools;
end;
```

The `RegisterEditorTools` method (in the updated UnitMain.pas) registers 8 tool
callbacks that allow the AI to interact with the editor during tool-use sessions.

**Registration signatures explained:**

- `AILib.RegisterAIFuncs(FBasic.Functions, FBasic, FConsole.Lines)` — Takes 3 parameters
  because AILib needs access to the BASIC engine (for stream callbacks) and the console
  output lines (for printing). This follows the same pattern as `HttpLib`, `FormLib`, etc.

- `RAGLib.RegisterRAGFuncs(FBasic.Functions)` — Takes only the function dictionary.
  RAG operations are self-contained (file I/O based).

- `SkillLib.RegisterSkillFuncs(FBasic.Functions)` — Same pattern, self-contained.

- `P9EngineLib.RegisterP9EngineFuncs(FBasic.Functions)` — Same pattern. The engine
  receives its AI client handle through BASIC code (at runtime), not at registration time.

---

## Step 5: Create the Knowledge Base Directory

The RAG engine needs a directory structure for its knowledge base.
Create the following under your Plan9Basic documents folder:

```
Plan9Basic/
├── knowledge/                       ← RAG knowledge base root
│   ├── libraries/                   ← Auto-generated library docs
│   ├── language/                    ← Language rules documents
│   ├── patterns/                    ← Code patterns
│   └── examples/                    ← Example applets
├── skills/                          ← Custom skill JSON files (optional)
├── Programs/                        ← User's BASIC programs
```

On Windows, this would be at:
```
C:\Users\<user>\Documents\Plan9Basic\knowledge\
C:\Users\<user>\Documents\Plan9Basic\skills\
```

**The `knowledge/` and `skills/` directories can start empty.** The RAG engine will
create the index when `rag_rebuild#()` is called, and the Skill engine has 10 built-in
skills that work without any files on disk.

---

## Step 6: Compile and Test

### 6.1 — Compile the project

Build the project in RAD Studio. The expected compilation order is:

1. `AILib.pas` compiles (depends on `exec`, `UnitGC`, `basic`)
2. `RAGEngine.pas` compiles (depends on `System.*` only)
3. `RAGDocGenerator.pas` compiles (depends on `System.*` only)
4. `SkillEngine.pas` compiles (depends on `System.JSON`)
5. `PromptAssembler.pas` compiles (depends on `RAGEngine`, `SkillEngine`)
6. `ToolExecutor.pas` compiles (depends on `System.JSON`, `System.Generics.Collections`)
7. `IntelligenceEngine.pas` compiles (depends on `RAGEngine`, `SkillEngine`, `PromptAssembler`, `ToolExecutor`, `AILib`)
8. `RAGLib.pas` compiles (depends on `exec`, `UnitGC`, `RAGEngine`)
9. `SkillLib.pas` compiles (depends on `exec`, `UnitGC`, `SkillEngine`)
10. `P9EngineLib.pas` compiles (depends on `exec`, `UnitGC`, `AILib`, `RAGEngine`, `SkillEngine`, `PromptAssembler`, `IntelligenceEngine`)

If you see errors about undeclared identifiers `TAIClient` or `TAIConversation`,
verify that the corrected `AILib.pas` has these types declared in the **interface**
section (around lines 82-220), not in the implementation.

### 6.2 — Minimal smoke test (AILib only)

Run Plan9Basic and type or paste this program. It tests that the AI functions are
registered and callable without making any actual API calls:

```basic
' AILib smoke test
let ai# = Pointer#(0)
println "ai_strerror: " + ai_strerror$()
println "AI functions registered OK"
```

Expected output:
```
ai_strerror:
AI functions registered OK
Ready.
```

### 6.3 — Skill engine test

```basic
' SkillLib smoke test
let eng# = skill_engine#("")
println "Skills loaded: " + str$(skill_count(eng#))
println "Available: " + skill_list$(eng#)
let id$ = skill_select$(eng#, "calculator with buttons")
println "Selected: " + id$
let x = skill_engine_free(eng#)
```

Expected output:
```
Skills loaded: 10
Available: gui_applet,console_tool,data_processor,http_client,...
Selected: gui_applet
Ready.
```

### 6.4 — Full pipeline test (requires API key)

```basic
' Full Intelligence Engine test
' Replace with your actual API key
let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_model#(ai#, "claude-sonnet-4-20250514")

let eng# = p9_engine#(ai#, "knowledge/", "skills/")
println p9_summary$(eng#)

' Generate code from natural language
let code$ = p9_generate$(eng#, "Print hello world")
println "--- Generated Code ---"
println code$
println "--- End ---"

let x = p9_engine_free(eng#)
let x = ai_free(ai#)
```

### 6.5 — Tool-use test (requires API key)

```basic
' Tool-use smoke test
let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)

let eng# = p9_engine#(ai#, "knowledge/", "skills/")

' Check tools are registered
println "Tools: " + str$(p9_tools_count(eng#))
println "Names: " + p9_tools_list$(eng#)

' Generate with tools (AI interacts with editor)
let result$ = p9_generate_tools$(eng#, "Create a hello world program and load it in the editor")
println "Result: " + result$

let x = p9_engine_free(eng#)
let x = ai_free(ai#)
```

Expected output:
```
Tools: 8
Names: run_program,compile_check,load_editor,get_editor_code,get_console_output,list_files,read_file,save_file
Result: (AI's response text)
```

The editor should now contain the generated code.

---

## Step 7: Generate the RAG Knowledge Base (Optional but Recommended)

The RAG knowledge base makes the Intelligence Engine much smarter by giving
it access to all 300+ Plan9Basic function signatures and documentation.

**Note:** The documentation generator (`TRAGDocGenerator`) is a Delphi-only class
with no BASIC bindings. To generate the knowledge base, you have two options:

### Option A: Use TRAGDocGenerator from Delphi Code

Add a helper method to your application that calls the generator:

```pascal
procedure TfrmMain.GenerateKnowledgeBase;
var
  DocGen: TRAGDocGenerator;
  RAG: TRAGEngine;
begin
  DocGen := TRAGDocGenerator.Create('C:\path\to\Plan9Basic\Libs\');
  try
    DocGen.GenerateAll('knowledge\libraries\');
  finally
    DocGen.Free;
  end;

  // Rebuild the search index
  RAG := TRAGEngine.Create('knowledge\');
  try
    RAG.RebuildIndex;
  finally
    RAG.Free;
  end;
end;
```

### Option B: Build the Index from Existing Docs

If you have manually written markdown documentation in the `knowledge/` folder,
you can build the index from BASIC:

```basic
' Build RAG index from existing docs
let rag# = rag#("knowledge/")
let x = rag_rebuild#(rag#)
println "Documents: " + str$(rag_count(rag#))
println "Functions: " + str$(rag_funccount(rag#))
let x = rag_free(rag#)
```

After building the index, the `knowledge/` directory will contain a JSON index
file. The RAG engine will load this index automatically on subsequent runs.

---

## Dependency Diagram

```
                    Plan9Basic Interpreter
                           │
                     UnitMain.pas
                   (InitBASICEngine)
                           │
              ┌────────────┼────────────────┐
              │            │                │
         RegisterAI   RegisterRAG    RegisterSkill  RegisterP9Engine
              │            │                │              │
           AILib.pas   RAGLib.pas     SkillLib.pas   P9EngineLib.pas
              │            │                │              │
              │        RAGEngine.pas  SkillEngine.pas      │
              │        RAGDocGen.pas       │               │
              │            │               │               │
              │            └───────┬───────┘               │
              │                    │                        │
              │            PromptAssembler.pas              │
              │                    │                        │
              └──────────┬─────────┘                        │
                         │                                  │
                  IntelligenceEngine.pas ◄───────────────────┘
                         │
                  ToolExecutor.pas
                  (owned by IntelligenceEngine)
```

---

## GC Tag Reference

All AI objects are managed by the garbage collector with these tags:

| Tag | Object Type | Created By |
|-----|------------|------------|
| `BASIC_AI` | `TAIClient` | `ai_client#()` |
| `BASIC_AI_CONV` | `TAIConversation` | `ai_conversation#()` |
| `BASIC_RAG` | `TRAGEngine` | `rag#()` |
| `BASIC_SKILL` | `TSkillEngine` | `skill_engine#()` |
| `BASIC_P9ENGINE` | `TIntelligenceEngine` | `p9_engine#()` |

**Note:** `TRAGDocGenerator` has no BASIC bindings and no GC tag — it is used
only from Delphi code. `TToolExecutor` is owned by `TIntelligenceEngine` and
freed automatically when the engine is freed.

When the BASIC engine resets (`InitBASICEngine`), the GC cleanup at step 4
will automatically free all AI objects. No special cleanup code is needed
in `FormDestroy` or `InitBASICEngine` beyond the existing GC cleanup pattern.

---

## Quick Function Reference

### AILib (45 functions)

```
Error handling (4):
  ai_error()                            Last error code
  ai_errormsg$()                        Last error message
  ai_strerror$(code)                    Error code to string
  ai_clearerror()                       Clear last error

Client lifecycle (2):
  ai_client#(provider$, apikey$)        Create AI client
  ai_free(ai#)                          Free client

Configuration (11):
  ai_model#(ai#, model$)               Set model
  ai_model$(ai#)                        Get model name
  ai_system#(ai#, prompt$)             Set system prompt
  ai_temperature#(ai#, value)          Set temperature
  ai_maxtokens#(ai#, value)            Set max tokens
  ai_topp#(ai#, value)                 Set top-p
  ai_timeout#(ai#, seconds)            Set timeout
  ai_baseurl#(ai#, url$)               Set custom base URL
  ai_baseurl$(ai#)                      Get base URL
  ai_stop#(ai#, seq$)                  Add stop sequence
  ai_clearstop#(ai#)                   Clear stop sequences

Custom headers (3):
  ai_header#(ai#, name$, value$)       Add custom header
  ai_headerremove#(ai#, name$)         Remove header
  ai_headerclear#(ai#)                 Clear all headers

Identity (4):
  ai_apikey#(ai#, key$)                Set API key
  ai_endpoint#(ai#, path$)             Set endpoint path
  ai_useragent#(ai#, agent$)           Set user agent
  ai_provider$(ai#)                     Get provider name

Simple chat (2):
  ai_chat$(ai#, message$)              Send message, get response
  ai_clearchat(ai#)                    Clear chat history

Streaming (3):
  ai_ontoken#(ai#, callback$)          Set stream callback
  ai_chatstream(ai#, message$)         Stream a message
  ai_streambuffer$(ai#)                Get stream buffer

Single-shot completion (2):
  ai_complete$(ai#, prompt$)           One-shot completion
  ai_completesystem$(ai#, sys$, usr$)  One-shot with system prompt

Conversation management (9):
  ai_conversation#()                    Create conversation
  ai_conversation_free(conv#)           Free conversation
  ai_conversation_system#(conv#, sys$)  Set conversation system prompt
  ai_conversation_clear(conv#)          Clear messages
  ai_conversation_maxhistory#(conv#, n) Set max history
  ai_ask$(ai#, conv#, message$)         Chat with conversation
  ai_conversation_count(conv#)          Message count
  ai_conversation_last$(conv#)          Last message text
  ai_conversation_tokens(conv#)         Token estimate

Response metadata (5):
  ai_status(ai#)                        HTTP status code
  ai_body$(ai#)                         Raw response body
  ai_tokensin(ai#)                      Input tokens used
  ai_tokensout(ai#)                     Output tokens used
  ai_ok(ai#)                            1 if last call succeeded
```

### RAGLib (13 functions)

```
Engine lifecycle (3):
  rag#(path$)                           Create RAG engine
  rag_free(eng#)                        Free engine
  rag_rebuild#(eng#)                    Rebuild search index

Core retrieval (3):
  rag_retrieve$(eng#, query$)           Search knowledge base (text)
  rag_retrieve_json$(eng#, query$)      Search knowledge base (JSON)
  rag_retrieve_budget$(eng#, q$, tok)   Search with token budget

Direct lookup (3):
  rag_doc$(eng#, name$)                 Get document by name
  rag_functions$(eng#, query$)          Search functions
  rag_tags$(eng#, query$)              Search by tags

Query analysis (1):
  rag_analyze$(eng#, query$)            Analyze query intent

Information (3):
  rag_count(eng#)                       Document count
  rag_funccount(eng#)                   Function count
  rag_summary$(eng#)                    Engine summary
```

### SkillLib (13 functions)

```
Engine lifecycle (3):
  skill_engine#(path$)                  Create skill engine
  skill_engine_free(eng#)               Free engine
  skill_reload#(eng#)                   Reload from disk

Skill selection (7):
  skill_select$(eng#, query$)           Select best skill
  skill_select_json$(eng#, query$)      Detailed selection (JSON)
  skill_get_system$(eng#, id$)          Get system prompt
  skill_get_rules$(eng#, id$)           Get rules text
  skill_get_template$(eng#, id$)        Get code template
  skill_get_examples$(eng#, id$)        Get examples text
  skill_get_full$(eng#, id$)            Get full prompt section

Information (3):
  skill_count(eng#)                     Skill count
  skill_list$(eng#)                     List skill IDs
  skill_summary$(eng#)                  Summary of all skills
```

### P9EngineLib (21 functions)

```
Engine lifecycle (2):
  p9_engine#(ai#, know$, skill$)        Create engine
  p9_engine_free(eng#)                  Free engine

Code generation (4):
  p9_generate$(eng#, query$)            Generate code
  p9_generate_validated$(eng#, query$)  Generate + auto-fix
  p9_refine$(eng#, followup$)           Refine last code
  p9_generate_skill$(eng#, q$, skill$)  Generate with skill

Information (5):
  p9_search$(eng#, query$)              Search functions
  p9_help$(eng#, name$)                 Get documentation
  p9_suggest$(eng#, desc$)              Suggest libraries
  p9_ask$(eng#, question$)              Ask a question
  p9_explain$(eng#, code$)              Explain code

Configuration (2):
  p9_autofix#(eng#, enabled)            Toggle auto-fix
  p9_maxtokens#(eng#, tokens)           Set context window

State (4):
  p9_lastcode$(eng#)                    Last generated code
  p9_lastskill$(eng#)                   Last skill used
  p9_lasttokens(eng#)                   Last tokens used
  p9_summary$(eng#)                     Engine status

Tool-use (4):
  p9_generate_tools$(eng#, query$)      Generate with tool-use
  p9_tools_enable#(eng#, enabled)       Enable/disable tools
  p9_tools_count(eng#)                  Count registered tools
  p9_tools_list$(eng#)                  List tool names
```

---

## Troubleshooting

### "Undeclared identifier 'TAIClient'"

The types `TAIClient` and `TAIConversation` must be in the **interface** section
of `AILib.pas`, not in the implementation. Verify that lines ~82-220 of `AILib.pas`
contain the `type` declarations before the `implementation` keyword.

### "Undeclared identifier 'TFunctionsDictionary'"

The binding units (`RAGLib`, `SkillLib`, `P9EngineLib`) use `exec` in their
`uses` clause. Make sure `exec.pas` is accessible from the unit search path.
Since it is already in the project root, this should work automatically.

### "Undeclared identifier 'TToolExecutor'"

Make sure `ToolExecutor` is in the `uses` clause of `UnitMain.pas` (implementation
section) and that `ToolExecutor.pas` is in the project.

### GC errors or access violations on shutdown

The existing cleanup order in `InitBASICEngine` and `FormDestroy` handles
AI objects correctly:
1. Timers stop first
2. Forms close
3. Engine is freed
4. **GC frees all remaining objects** (including AI clients, RAG engines, etc.)

No additional cleanup code is needed. The GC tags (`BASIC_AI`, `BASIC_RAG`, etc.)
ensure all AI objects are tracked and freed automatically.

### "AI callback not configured" at runtime

This means `p9_engine#()` was called but the `TAIClient` handle passed as
the first argument was invalid (nil or not a TAIClient). Make sure you create
the AI client first:

```basic
let ai# = ai_client#("anthropic", "your-key-here")
let eng# = p9_engine#(ai#, "knowledge/", "skills/")
```

### RAG search returns empty results

The RAG index needs to be built first. Run `rag_rebuild#(eng#)` after creating
the engine, or generate documentation with `TRAGDocGenerator` from Delphi first.
The index is persisted to disk as JSON, so you only need to build it once.

### Tool-use: "No tools registered"

Make sure `P9EngineLib.OnEditorToolRegistration` is assigned in `FormCreate`.
Without this hookup, `p9_engine#()` creates an engine with no editor tools.

---

## Summary of Changes

| File | What to Change |
|------|---------------|
| **Plan9Basic.dpr** | Add 10 units to the `uses` clause |
| **UnitMain.pas** (implementation uses) | Add `AILib, RAGLib, SkillLib, P9EngineLib, ToolExecutor` |
| **UnitMain.pas** (InitBASICEngine) | Add 4 `Register*` calls at the end |
| **UnitMain.pas** (FormCreate) | Add `P9EngineLib.OnEditorToolRegistration := RegisterEditorTools` |
| **File system** | Create `Libs\AI\` folder with 10 `.pas` files |
| **File system** | Create `knowledge\` and `skills\` directories (can be empty) |

Total lines of code changed in existing files: approximately 20 lines.
