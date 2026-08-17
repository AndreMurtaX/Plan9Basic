# P9EngineLib - Intelligence Engine Library

## Overview

P9EngineLib provides functions to generate Plan9Basic code from natural language descriptions using AI. It is the highest-level library in the AI stack, combining AILib (transport), RAGLib (knowledge retrieval), and SkillLib (prompt templates) into a single, easy-to-use code generation pipeline. You describe what you want to build, and the engine handles skill selection, documentation retrieval, prompt assembly, AI communication, and optional code validation — returning working Plan9Basic code.

**Version:** 1.1
**Function Count:** 26 functions (25 unique, 2 overloads for p9_engine#)

## Key Features

- **Natural Language Code Generation** - Describe what you want, get working code
- **Automatic Skill Selection** - The engine picks the best prompt template for your request
- **RAG-Powered Context** - Relevant library documentation is automatically injected into prompts
- **Auto-Fix Loop** - Optionally compile-test generated code and let the AI fix errors
- **Iterative Refinement** - Ask follow-up questions to improve generated code
- **Tool-Use** - The AI can interact with the editor: load code, compile, run, and iterate
- **Function Search** - Search for Plan9Basic functions and libraries by keyword
- **Code Explanation** - Ask the AI to explain existing Plan9Basic code
- **Library Suggestions** - Get recommendations for which libraries to use for a task
- **Question Answering** - Ask general questions about Plan9Basic
- **Automatic Memory Management** - Engines are tracked by the garbage collector

## Architecture

P9EngineLib is the top layer in a three-layer AI stack:

```
┌──────────────────────────────────┐
│  P9EngineLib (26 functions)      │  ← You call these
│  Code generation, search, help   │
├──────────────────────────────────┤
│  RAGLib (13) + SkillLib (13)     │  ← Used internally
│  Knowledge retrieval + Skills    │
├──────────────────────────────────┤
│  AILib (45 functions)            │  ← Used internally
│  HTTP transport, streaming       │
└──────────────────────────────────┘
```

For most use cases, P9EngineLib is all you need. Use RAGLib and SkillLib directly only if you need fine-grained control over prompt assembly.

## Function Naming Convention

| Suffix | Returns | Example |
|--------|---------|---------|
| `#` | Pointer (engine or configuration setter) | `p9_engine#()`, `p9_autofix#()` |
| `$` | String | `p9_generate$()`, `p9_search$()` |
| (none) | Number | `p9_lasttokens()`, `p9_tools_count()` |

## Prerequisites

P9EngineLib requires an AILib client. You must create an AI client first, then pass it to the engine:

```basic
' Step 1: Create AI client
let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)

' Step 2: Create Intelligence Engine (auto-resolves paths)
let eng# = p9_engine#(ai#)

' Step 3: Generate code
let code$ = p9_generate$(eng#, "Create a calculator")
```

When running inside the Plan9Basic IDE, the engine automatically finds the `knowledge/` and `skills/` directories relative to the application base path. You can also provide explicit paths for custom setups:

```basic
let eng# = p9_engine#(ai#, "my_knowledge/", "my_skills/")
```

## Memory Management

Intelligence engines created with `p9_engine#()` are automatically tracked by Plan9Basic's garbage collector. The engine takes ownership of the internal RAG and Skill engines it creates, freeing them when the engine is freed. The AI client (from AILib) is **not** owned by the engine — you must free it separately.

**Important:** When using `p9_engine#` with GUI forms, do **not** free the engine after `form_show()`. Since `form_show` returns immediately (non-blocking), the form's button callbacks still need the engine. Let the garbage collector handle cleanup automatically.

---

## Function Reference

### Engine Lifecycle

#### p9_engine#()

Creates an Intelligence Engine with a RAG knowledge base and skill templates.

**Signatures:**
- `p9_engine#@#` — auto-resolve paths (preferred)
- `p9_engine#@#$$` — explicit paths (backward compatible)

**Syntax:**
```basic
' Auto-resolve (uses knowledge/ and skills/ relative to AppBasePath)
eng# = p9_engine#(ai#)

' Explicit paths
eng# = p9_engine#(ai#, knowledgePath$, skillsPath$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `ai#` | Pointer | AILib client handle (from `ai_client#`) |
| `knowledgePath$` | String | *(optional)* Path to the knowledge base directory (e.g., `"knowledge/"`) |
| `skillsPath$` | String | *(optional)* Path to the skills directory (e.g., `"skills/"`) |

**Returns:** Pointer to the Intelligence Engine

When called with only the AI client handle, the engine auto-resolves paths using the application base path set by the IDE. If paths are relative, they are resolved against the base path. This is the preferred form for programs running inside the Plan9Basic IDE.

The engine loads the RAG index and skills at creation. If the knowledge base has no index yet, retrieval will return empty results until you build it with `rag_rebuild#()`. The skills directory can be empty — built-in skills are always available.

When running inside the Plan9Basic IDE, the engine also receives 8 editor tools (load code, compile, run, etc.) automatically.

**Example:**
```basic
let ai# = ai_client#("anthropic", key$)
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)

' Preferred: auto-resolve paths
let eng# = p9_engine#(ai#)
println p9_summary$(eng#)

' Alternative: explicit paths for custom setups
let eng# = p9_engine#(ai#, "my_data/knowledge/", "my_data/skills/")
```

---

#### p9_engine_free()

Frees the engine and its internal RAG and Skill engines.

**Signature:** `p9_engine_free@#`

**Syntax:**
```basic
p9_engine_free(eng#)
```

**Returns:** 1 on success

**Note:** Does not free the AILib client — free it separately with `ai_free()`.

---

### Code Generation

#### p9_generate$()

Generates Plan9Basic code from a natural language description. The engine automatically selects the best skill, retrieves relevant documentation, assembles a prompt, and calls the AI.

**Signature:** `p9_generate$@#$`

**Syntax:**
```basic
code$ = p9_generate$(eng#, query$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Engine handle |
| `query$` | String | Natural language description of what to build |

**Returns:** Generated Plan9Basic code, or a comment prefixed with `' ERROR:` if generation failed

**Example:**
```basic
let code$ = p9_generate$(eng#, "Create a form with a text field and a button that shows an alert when clicked")
println code$
```

---

#### p9_generate_validated$()

Generates code and then attempts to compile it. If compilation fails, the engine sends the error back to the AI for automatic correction, repeating until the code compiles or the retry limit is reached.

**Signature:** `p9_generate_validated$@#$`

**Syntax:**
```basic
code$ = p9_generate_validated$(eng#, query$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Engine handle |
| `query$` | String | Natural language description |

**Returns:** Validated code (compiles successfully), or the last attempt with error info if validation failed

**Example:**
```basic
let code$ = p9_generate_validated$(eng#, "Create a countdown timer from 10 to 0")
println code$
println "Skill used: " + p9_lastskill$(eng#)
```

---

#### p9_refine$()

Sends a follow-up instruction to improve the most recently generated code. The AI receives the previous code and your refinement request, and returns an updated version.

**Signature:** `p9_refine$@#$`

**Syntax:**
```basic
code$ = p9_refine$(eng#, followup$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Engine handle |
| `followup$` | String | Refinement instruction |

**Returns:** Updated code

**Example:**
```basic
' First generation
let code$ = p9_generate$(eng#, "Create a temperature converter")
println code$

' Refine it
let code$ = p9_refine$(eng#, "Add input validation and a Clear button")
println code$

' Refine again
let code$ = p9_refine$(eng#, "Make the buttons blue with white text")
println code$
```

---

#### p9_generate_skill$()

Generates code using a specific skill, bypassing automatic skill selection. Use this when you know exactly which skill template you want.

**Signature:** `p9_generate_skill$@#$$`

**Syntax:**
```basic
code$ = p9_generate_skill$(eng#, query$, skillId$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Engine handle |
| `query$` | String | Natural language description |
| `skillId$` | String | Skill ID (e.g., `"gui_applet"`, `"http_client"`) |

**Returns:** Generated code using the specified skill

**Example:**
```basic
' Force the use of the HTTP client skill
let code$ = p9_generate_skill$(eng#, "Fetch weather data and display it", "http_client")
println code$
```

---

#### p9_generate_tools$()

Generates code with tool-use enabled. The AI can interact with the Plan9Basic IDE during generation: it can load code into the editor, compile it, run it, check the output, and iterate until the result is correct.

**Signature:** `p9_generate_tools$@#$`

**Syntax:**
```basic
result$ = p9_generate_tools$(eng#, query$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Engine handle |
| `query$` | String | Natural language description, may include action verbs like "run", "test", "load" |

**Returns:** The AI's final response text (the code is typically also loaded into the editor via tools)

The 8 editor tools available to the AI are:

| Tool | What It Does |
|------|-------------|
| `run_program` | Compiles and runs code, returns console output |
| `compile_check` | Checks if code compiles, returns OK or errors |
| `load_editor` | Puts code in the editor for the user to see |
| `get_editor_code` | Reads current code from the editor |
| `get_console_output` | Reads current console text |
| `list_files` | Lists `.bas` files in the user's directory |
| `read_file` | Reads a saved `.bas` file |
| `save_file` | Saves code to a `.bas` file |

**Example:**
```basic
' The AI will create the code, load it in the editor, compile it, and fix any issues
let result$ = p9_generate_tools$(eng#, "Create a hello world program, load it in the editor and run it")
println result$
```

---

### Information

#### p9_search$()

Searches the knowledge base for functions and libraries matching a query.

**Signature:** `p9_search$@#$`

**Syntax:**
```basic
results$ = p9_search$(eng#, query$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Engine handle |
| `query$` | String | Search query (e.g., `"JSON parsing"`, `"file operations"`) |

**Returns:** Formatted text with matching functions and documentation

**Example:**
```basic
let results$ = p9_search$(eng#, "timer and animation")
println results$
```

---

#### p9_help$()

Gets documentation for a specific library or function.

**Signature:** `p9_help$@#$`

**Syntax:**
```basic
docs$ = p9_help$(eng#, name$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Engine handle |
| `name$` | String | Library name (e.g., `"FormLib"`) or function name (e.g., `"json_parse#"`) |

**Returns:** Documentation text

---

#### p9_suggest$()

Suggests which libraries to use for a given task.

**Signature:** `p9_suggest$@#$`

**Syntax:**
```basic
suggestions$ = p9_suggest$(eng#, description$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Engine handle |
| `description$` | String | Description of the task |

**Returns:** List of recommended libraries with explanations

**Example:**
```basic
let s$ = p9_suggest$(eng#, "I want to build a weather app that fetches data from the internet and shows it in a GUI")
println s$
```

---

#### p9_ask$()

Asks a general question about Plan9Basic and gets an AI-powered answer.

**Signature:** `p9_ask$@#$`

**Syntax:**
```basic
answer$ = p9_ask$(eng#, question$)
```

**Example:**
```basic
let a$ = p9_ask$(eng#, "How do I handle click events on buttons?")
println a$
```

---

#### p9_explain$()

Asks the AI to explain a piece of Plan9Basic code.

**Signature:** `p9_explain$@#$`

**Syntax:**
```basic
explanation$ = p9_explain$(eng#, code$)
```

**Example:**
```basic
let code$ = p9_lastcode$(eng#)
let explanation$ = p9_explain$(eng#, code$)
println explanation$
```

---

### Configuration

#### p9_autofix#()

Enables or disables the auto-fix loop for `p9_generate_validated$`. When enabled, the engine compiles generated code and sends errors back to the AI for correction.

**Signature:** `p9_autofix#@#n`

**Syntax:**
```basic
p9_autofix#(eng#, enabled)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Engine handle |
| `enabled` | Number | 1 to enable, 0 to disable |

**Returns:** The engine pointer

---

#### p9_maxtokens#()

Sets the maximum context window size for prompt assembly. The engine uses this to decide how much RAG documentation to include in prompts.

**Signature:** `p9_maxtokens#@#n`

**Syntax:**
```basic
p9_maxtokens#(eng#, tokens)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Engine handle |
| `tokens` | Number | Maximum context tokens (e.g., 4096, 8192) |

**Returns:** The engine pointer

---

### Tool-Use Control

#### p9_tools_enable#()

Globally enables or disables tool-use for this engine. When disabled, `p9_generate$` will never use tools even if action verbs are detected. When enabled, the engine decides automatically.

**Signature:** `p9_tools_enable#@#n`

**Syntax:**
```basic
p9_tools_enable#(eng#, enabled)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Engine handle |
| `enabled` | Number | 1 to enable, 0 to disable |

**Returns:** The engine pointer

---

#### p9_tools_count()

Returns the number of tools registered with the engine.

**Signature:** `p9_tools_count@#`

**Syntax:**
```basic
count = p9_tools_count(eng#)
```

**Returns:** Number of tools (typically 8 when running in the IDE, 0 when running standalone)

---

#### p9_tools_list$()

Returns a comma-separated list of registered tool names.

**Signature:** `p9_tools_list$@#`

**Syntax:**
```basic
names$ = p9_tools_list$(eng#)
```

**Returns:** String like `"run_program,compile_check,load_editor,get_editor_code,get_console_output,list_files,read_file,save_file"`

---

### State

#### p9_lastcode$()

Returns the code from the last generation or refinement call.

**Signature:** `p9_lastcode$@#`

**Syntax:**
```basic
code$ = p9_lastcode$(eng#)
```

---

#### p9_lastskill$()

Returns the skill ID that was used for the last generation.

**Signature:** `p9_lastskill$@#`

**Syntax:**
```basic
skill$ = p9_lastskill$(eng#)
```

---

#### p9_lasttokens()

Returns the number of tokens used in the last AI call.

**Signature:** `p9_lasttokens@#`

**Syntax:**
```basic
tokens = p9_lasttokens(eng#)
```

---

#### p9_summary$()

Returns a human-readable summary of the engine state: loaded documents, available skills, tool count, and configuration.

**Signature:** `p9_summary$@#`

**Syntax:**
```basic
summary$ = p9_summary$(eng#)
```

**Example:**
```basic
println p9_summary$(eng#)
```

---

### Diagnostics

#### p9_lastdocs$()

Returns the list of RAG documents that were retrieved and included in the last generation call. Each document is shown with its title and content. Useful for understanding what documentation context was injected into the AI prompt.

**Signature:** `p9_lastdocs$@#`

**Syntax:**
```basic
docs$ = p9_lastdocs$(eng#)
```

**Returns:** Formatted string listing the RAG documents included in the last generation, or `"(no RAG documents retrieved)"` if none were used

---

#### p9_lastlog$()

Returns the full assembly log from the last generation call. The log records each step of the prompt assembly pipeline: skill selection, RAG retrieval, token budget decisions, and prompt construction.

**Signature:** `p9_lastlog$@#`

**Syntax:**
```basic
log$ = p9_lastlog$(eng#)
```

**Returns:** Assembly log string, or `"(no assembly log — run a generation first)"` if no generation has been run

---

#### p9_lastbudget$()

Returns a token budget breakdown from the last generation call, showing how the context window was allocated between skill sections and RAG documentation.

**Signature:** `p9_lastbudget$@#`

**Syntax:**
```basic
budget$ = p9_lastbudget$(eng#)
```

**Returns:** Formatted string with the token budget breakdown

---

#### p9_lastprompt$()

Returns the full system prompt that was sent to the AI in the last generation call. This includes skill sections and RAG documentation combined. Use for debugging only — the output can be very large.

**Signature:** `p9_lastprompt$@#`

**Syntax:**
```basic
prompt$ = p9_lastprompt$(eng#)
```

**Returns:** The complete system prompt string sent to the AI

---

## Complete Examples

### Example 1: Basic Code Generation

```basic
' Generate code from a natural language description
println "=== Code Generation ==="
println ""

let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)

let eng# = p9_engine#(ai#)

let code$ = p9_generate$(eng#, "Create a number guessing game from 1 to 100")

println code$
println ""
println "Skill used: " + p9_lastskill$(eng#)
println "Tokens: " + str$(p9_lasttokens(eng#))

p9_engine_free(eng#)
ai_free(ai#)
```

### Example 2: Generate and Refine

```basic
' Generate code, then iteratively refine it
println "=== Iterative Refinement ==="
println ""

let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)

let eng# = p9_engine#(ai#)

' Initial generation
println "--- Version 1 ---"
let code$ = p9_generate$(eng#, "Create a simple calculator")
println code$

' First refinement
println ""
println "--- Version 2 (adding GUI) ---"
let code$ = p9_refine$(eng#, "Make it a GUI app with buttons for +, -, *, /")
println code$

' Second refinement
println ""
println "--- Version 3 (adding features) ---"
let code$ = p9_refine$(eng#, "Add a Clear button and make the display bigger")
println code$

p9_engine_free(eng#)
ai_free(ai#)
```

### Example 3: Library Search and Help

```basic
' Search for functions and get documentation
println "=== Function Search and Help ==="
println ""

let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 2048)

let eng# = p9_engine#(ai#)

' Search by topic
println "--- Searching: JSON parsing ---"
let results$ = p9_search$(eng#, "JSON parsing")
println results$
println ""

' Get specific library help
println "--- Help: FormLib ---"
let docs$ = p9_help$(eng#, "FormLib")
println docs$
println ""

' Get library suggestions
println "--- Suggestions for a task ---"
let suggest$ = p9_suggest$(eng#, "I want to create a file manager that reads ZIP archives")
println suggest$

p9_engine_free(eng#)
ai_free(ai#)
```

### Example 4: Tool-Use with Editor Interaction

```basic
' Let the AI interact with the editor
println "=== Tool-Use Demo ==="
println ""

let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)

let eng# = p9_engine#(ai#)

' Check available tools
println "Tools: " + str$(p9_tools_count(eng#))
println "Names: " + p9_tools_list$(eng#)
println ""

' The AI will generate code, load it, compile it, and fix any errors
let result$ = p9_generate_tools$(eng#, "Create a program that prints the Fibonacci sequence up to 100, load it and run it")
println result$

p9_engine_free(eng#)
ai_free(ai#)
```

### Example 5: Engine Status and Diagnostics

```basic
' Inspect the engine state
println "=== Engine Diagnostics ==="
println ""

let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)

let eng# = p9_engine#(ai#)

' Show engine summary
println p9_summary$(eng#)
println ""

' Generate something to populate state
let code$ = p9_generate$(eng#, "Hello world")

' Inspect last generation state
println "Last code length: " + str$(len(p9_lastcode$(eng#)))
println "Last skill: " + p9_lastskill$(eng#)
println "Last tokens: " + str$(p9_lasttokens(eng#))
println ""

' Check tool status
println "Tools enabled: " + str$(p9_tools_count(eng#))
println "Tool list: " + p9_tools_list$(eng#)

p9_engine_free(eng#)
ai_free(ai#)
```

### Example 6: GUI AI Assistant

```basic
' ============================================
' AI Code Assistant with GUI
' ============================================

' Initialize AI
let key$ = "sk-ant-xxxxx"
let ai# = ai_client#("anthropic", key$)
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)

let eng# = p9_engine#(ai#)

' Create GUI
let frm# = form_create#("AI Assistant", 500, 400)
let lblPrompt# = label_create#(frm#, "Describe what you want to build:", 10, 10, 480, 20)
let edtPrompt# = memo_create#(frm#, 10, 35, 480, 80)
let btnGenerate# = button_create#(frm#, "Generate Code", 10, 125, 150, 35)
let lblOutput# = label_create#(frm#, "Generated Code:", 10, 170, 480, 20)
let edtOutput# = memo_create#(frm#, 10, 195, 480, 190)

' Button click handler
function on_generate#(sender#) local query$, code$
    query$ = memo_text$(edtPrompt#)
    if query$ = "" then
        return sender#
    endif
    
    memo_settext(edtOutput#, "Generating...")
    code$ = p9_generate$(eng#, query$)
    memo_settext(edtOutput#, code$)
    
    return sender#
endfunction

button_onclick(btnGenerate#, "on_generate")

' Do NOT free engine/AI here!
' form_show returns immediately, but the form and its callbacks
' still need these objects. The GC will handle cleanup automatically
' when the user runs another program or closes the app.
form_show(frm#)
```

---

## Quick Reference

### Engine Lifecycle
```basic
p9_engine#(ai#)                        ' Create engine (auto-resolve, preferred)
p9_engine#(ai#, knowPath$, skillPath$) ' Create engine (explicit paths)
p9_engine_free(eng#)                   ' Free engine
```

### Code Generation
```basic
p9_generate$(eng#, query$)            ' Generate code
p9_generate_validated$(eng#, query$)  ' Generate with auto-fix
p9_refine$(eng#, followup$)           ' Refine last code
p9_generate_skill$(eng#, q$, skill$)  ' Generate with explicit skill
p9_generate_tools$(eng#, query$)      ' Generate with tool-use
```

### Information
```basic
p9_search$(eng#, query$)              ' Search functions/libraries
p9_help$(eng#, name$)                 ' Get library documentation
p9_suggest$(eng#, desc$)              ' Suggest libraries for a task
p9_ask$(eng#, question$)              ' Ask a Plan9Basic question
p9_explain$(eng#, code$)              ' Explain existing code
```

### Configuration
```basic
p9_autofix#(eng#, enabled)            ' Toggle auto-fix (1/0)
p9_maxtokens#(eng#, tokens)           ' Set context window
```

### Tool-Use Control
```basic
p9_tools_enable#(eng#, enabled)       ' Enable/disable tools (1/0)
p9_tools_count(eng#)                  ' Number of registered tools
p9_tools_list$(eng#)                  ' List tool names
```

### State
```basic
p9_lastcode$(eng#)                    ' Last generated code
p9_lastskill$(eng#)                   ' Last skill used
p9_lasttokens(eng#)                   ' Last tokens used
p9_summary$(eng#)                     ' Engine status
```

### Diagnostics
```basic
p9_lastdocs$(eng#)                    ' RAG documents from last generation
p9_lastlog$(eng#)                     ' Assembly log from last generation
p9_lastbudget$(eng#)                  ' Token budget breakdown
p9_lastprompt$(eng#)                  ' Full system prompt sent to AI
```

---

### All Registered Functions (Alphabetical)

| Function | Signature | Description |
|----------|-----------|-------------|
| `p9_ask$` | `p9_ask$@#$` | Ask a Plan9Basic question |
| `p9_autofix#` | `p9_autofix#@#n` | Toggle auto-fix loop |
| `p9_engine#` | `p9_engine#@#` | Create engine (auto-resolve paths) |
| `p9_engine#` | `p9_engine#@#$$` | Create engine (explicit paths) |
| `p9_engine_free` | `p9_engine_free@#` | Free engine |
| `p9_explain$` | `p9_explain$@#$` | Explain code |
| `p9_generate$` | `p9_generate$@#$` | Generate code |
| `p9_generate_skill$` | `p9_generate_skill$@#$$` | Generate with explicit skill |
| `p9_generate_tools$` | `p9_generate_tools$@#$` | Generate with tool-use |
| `p9_generate_validated$` | `p9_generate_validated$@#$` | Generate with auto-fix |
| `p9_help$` | `p9_help$@#$` | Get documentation |
| `p9_lastbudget$` | `p9_lastbudget$@#` | Token budget breakdown from last generation |
| `p9_lastcode$` | `p9_lastcode$@#` | Last generated code |
| `p9_lastdocs$` | `p9_lastdocs$@#` | RAG documents from last generation |
| `p9_lastlog$` | `p9_lastlog$@#` | Assembly log from last generation |
| `p9_lastprompt$` | `p9_lastprompt$@#` | Full system prompt from last generation |
| `p9_lastskill$` | `p9_lastskill$@#` | Last skill used |
| `p9_lasttokens` | `p9_lasttokens@#` | Last tokens used |
| `p9_maxtokens#` | `p9_maxtokens#@#n` | Set context window |
| `p9_refine$` | `p9_refine$@#$` | Refine last code |
| `p9_search$` | `p9_search$@#$` | Search functions |
| `p9_suggest$` | `p9_suggest$@#$` | Suggest libraries |
| `p9_summary$` | `p9_summary$@#` | Engine status |
| `p9_tools_count` | `p9_tools_count@#` | Number of tools |
| `p9_tools_enable#` | `p9_tools_enable#@#n` | Enable/disable tools |
| `p9_tools_list$` | `p9_tools_list$@#` | List tool names |

---

## Notes and Best Practices

### Choosing a Generation Mode

| Mode | When to Use |
|------|-------------|
| `p9_generate$` | Quick generation, you will review the code yourself |
| `p9_generate_validated$` | When you want code that compiles without errors |
| `p9_generate_tools$` | When you want the AI to load, compile, run, and iterate on the code |
| `p9_generate_skill$` | When you know exactly which skill template to use |

### GUI Programs and form_show

When generating GUI code that uses `form_show()`, remember that `form_show` is non-blocking — it returns immediately while the form stays visible. Do **not** free the engine or AI client after `form_show`. The garbage collector handles cleanup automatically.

```basic
' CORRECT - let GC handle it
form_show(frm#)

' WRONG - frees objects while form is still visible
form_show(frm#)
p9_engine_free(eng#)   ' ← DON'T DO THIS
ai_free(ai#)           ' ← DON'T DO THIS
```

### Knowledge Base Quality

The quality of generated code depends heavily on the RAG knowledge base. A well-populated `knowledge/` directory with documentation for all Plan9Basic libraries produces much better results than an empty one. Use `rag_rebuild#()` after adding documentation.

### Token Costs

Each generation call makes one or more AI API calls. Use `p9_lasttokens()` to monitor usage. `p9_generate_validated$` may make multiple calls (one per fix attempt). `p9_generate_tools$` can make up to 5 round trips.

### Console vs Linear Scripts

For console-only programs (no forms), it is safe to free the engine at the end of the script because the script runs to completion before exiting:

```basic
let code$ = p9_generate$(eng#, "Hello world")
println code$
p9_engine_free(eng#)
ai_free(ai#)
```

---

## See Also

- **AILib** - Low-level AI client (transport, streaming, conversations)
- **RAGLib** - Knowledge base retrieval (used internally by P9EngineLib)
- **SkillLib** - Skill template management (used internally by P9EngineLib)
- **JsonLib** - JSON parsing for processing AI responses

---

*End of P9EngineLib Documentation*
