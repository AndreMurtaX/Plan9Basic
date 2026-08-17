# P9EngineLib — Intelligence Engine Library
## Version 1.1.0 | 21 Functions

The Intelligence Engine is Plan9Basic's AI-powered code generation system.
It combines RAG (Retrieval-Augmented Generation) with Skills (prompt templates)
and Tool-Use (editor interaction) to help users create applets from natural
language descriptions.

---

## Important Syntax Notes

All function calls in Plan9Basic **must use parentheses**. Functions that
return pointers must include the `#` suffix in the function name. Functions
that return strings must include the `$` suffix.

```basic
' CORRECT:
ai_model#(ai#, "claude-sonnet-4-20250514")
let code$ = p9_generate$(eng#, "create a calculator")

' WRONG — missing # suffix and parentheses:
' ai_model ai#, "claude-sonnet-4-20250514"
```

All pointer variables must be initialized before use:
```basic
let ai# = Pointer#(0)
let eng# = Pointer#(0)
```

---

## Engine Lifecycle

### p9_engine#(ai#, knowledge$, skills$)
Creates a new Intelligence Engine connected to an AI client.

**Parameters:**
- `ai#` — AI client handle (from `ai_client#`)
- `knowledge$` — Path to RAG knowledge folder
- `skills$` — Path to skills folder

**Returns:** Engine handle (pointer)

**Notes:**
- Automatically loads the RAG index if one exists
- Automatically registers 8 editor tools for AI interaction
- The engine takes ownership of internal RAG and Skill engines

```basic
let ai# = Pointer#(0)
let eng# = Pointer#(0)

let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)

let eng# = p9_engine#(ai#, "knowledge/", "skills/")
```

### p9_engine_free(eng#)
Frees engine resources.

**Parameters:**
- `eng#` — Engine handle

**Returns:** 0 (number)

```basic
let x = p9_engine_free(eng#)
```

---

## Code Generation

### p9_generate$(eng#, query$)
Generates Plan9Basic code from a natural language description. Automatically
selects the best skill template and retrieves relevant library documentation.

If tool-use is enabled and the query contains action words (run, test, save,
etc.), the AI may use editor tools to load code, compile-check, or execute.

**Parameters:**
- `eng#` — Engine handle
- `query$` — Natural language description

**Returns:** Generated code (string), or error message prefixed with "? "

```basic
let code$ = p9_generate$(eng#, "Create a calculator with +, -, *, / buttons")
if left$(code$, 2) = "? " then
  println "Error: " + mid$(code$, 3)
else
  println code$
end if
```

### p9_generate_validated$(eng#, query$)
Same as `p9_generate$` but runs a compile-fix loop: if the generated code
has syntax errors, it asks the AI to fix them automatically (up to 3 attempts).

**Parameters:**
- `eng#` — Engine handle
- `query$` — Natural language description

**Returns:** Validated code (string)

**Notes:** Requires `p9_autofix#(eng#, 1)` to enable the auto-fix loop.

```basic
p9_autofix#(eng#, 1)
let code$ = p9_generate_validated$(eng#, "Create a stopwatch applet")
```

### p9_refine$(eng#, followup$)
Refines the previously generated code with a follow-up instruction. Uses the
multi-turn conversation to maintain context.

**Parameters:**
- `eng#` — Engine handle
- `followup$` — Refinement instruction

**Returns:** Refined code (string)

```basic
let code$ = p9_generate$(eng#, "Create a color picker")
' User reviews, then asks for changes:
let code$ = p9_refine$(eng#, "Make the preview circle bigger and add a hex label")
```

### p9_generate_skill$(eng#, query$, skill$)
Generates code using a specific skill template instead of automatic selection.

**Parameters:**
- `eng#` — Engine handle
- `query$` — Natural language description
- `skill$` — Skill ID to use

**Returns:** Generated code (string)

```basic
let code$ = p9_generate_skill$(eng#, "Create a form with inputs", "gui-form")
```

### p9_generate_tools$(eng#, query$)
Forces tool-use generation. The AI can interact with the editor: load code,
compile-check, execute programs, read/save files.

**Parameters:**
- `eng#` — Engine handle
- `query$` — Natural language description with action intent

**Returns:** AI's final response text (string). Code is already loaded in editor via tools.

**Notes:**
- The AI may perform multiple actions in sequence (up to 5 tool iterations)
- Use this when you want the AI to directly manipulate the editor

```basic
' AI generates code, loads it in editor, and compile-checks it
let result$ = p9_generate_tools$(eng#, "Create a hello world program and test it")
println result$
```

---

## Information

### p9_search$(eng#, query$)
Searches the RAG knowledge base for functions and libraries matching a query.

```basic
let info$ = p9_search$(eng#, "how to create buttons")
println info$
```

### p9_help$(eng#, name$)
Gets detailed documentation for a specific library or function.

```basic
let docs$ = p9_help$(eng#, "FormLib")
println docs$
```

### p9_suggest$(eng#, description$)
Suggests which libraries would be useful for a described task.

```basic
let libs$ = p9_suggest$(eng#, "I want to read a JSON file and display data in a grid")
println libs$
```

### p9_ask$(eng#, question$)
Answers a general question about Plan9Basic with AI assistance.

```basic
let answer$ = p9_ask$(eng#, "How do I create a timer that updates a label every second?")
println answer$
```

### p9_explain$(eng#, code$)
Explains what existing Plan9Basic code does.

```basic
let explanation$ = p9_explain$(eng#, p9_lastcode$(eng#))
println explanation$
```

---

## Configuration

### p9_autofix#(eng#, enabled)
Enables or disables the auto-fix compile loop for `p9_generate_validated$`.

**Parameters:**
- `eng#` — Engine handle
- `enabled` — 1 to enable, 0 to disable

**Returns:** Engine handle (pointer)

```basic
p9_autofix#(eng#, 1)   ' Enable auto-fix
p9_autofix#(eng#, 0)   ' Disable auto-fix
```

### p9_maxtokens#(eng#, tokens)
Sets the maximum context window size. Affects how much RAG documentation
is included in prompts.

**Parameters:**
- `eng#` — Engine handle
- `tokens` — Token limit (e.g. 8000, 24000, 128000)

**Returns:** Engine handle (pointer)

```basic
p9_maxtokens#(eng#, 128000)  ' For Claude Sonnet/Opus
p9_maxtokens#(eng#, 8000)    ' For smaller models
```

---

## Tool-Use

### p9_tools_enable#(eng#, enabled)
Globally enables or disables the tool-use system. When disabled, `p9_generate$`
always uses text-only generation regardless of action words in the query.

**Parameters:**
- `eng#` — Engine handle
- `enabled` — 1 to enable, 0 to disable

**Returns:** Engine handle (pointer)

```basic
p9_tools_enable#(eng#, 0)  ' Force text-only generation
p9_tools_enable#(eng#, 1)  ' Re-enable tool-use
```

### p9_tools_count(eng#)
Returns the number of editor tools currently registered.

**Parameters:**
- `eng#` — Engine handle

**Returns:** Number of tools (normally 8)

```basic
println "Tools: " + str$(p9_tools_count(eng#))
```

### p9_tools_list$(eng#)
Returns a comma-separated list of registered tool names.

**Parameters:**
- `eng#` — Engine handle

**Returns:** Tool names (string)

```basic
println p9_tools_list$(eng#)
' Output: run_program,compile_check,load_editor,get_editor_code,
'         get_console_output,list_files,read_file,save_file
```

---

## State

### p9_lastcode$(eng#)
Returns the last generated code.

```basic
let code$ = p9_lastcode$(eng#)
```

### p9_lastskill$(eng#)
Returns the skill ID used in the last generation.

```basic
println "Skill used: " + p9_lastskill$(eng#)
```

### p9_lasttokens(eng#)
Returns the token count from the last generation.

```basic
println "Tokens: " + str$(p9_lasttokens(eng#))
```

### p9_summary$(eng#)
Returns a multi-line summary of the engine's current state including
configuration, sub-engine status, and last generation details.

```basic
println p9_summary$(eng#)
```

---

## Available Editor Tools

When an Intelligence Engine is created, 8 editor tools are automatically
registered. These are used by the AI during `p9_generate$` (when action
words are detected) and `p9_generate_tools$` calls.

| Tool | Description |
|------|-------------|
| `run_program` | Compiles and executes Plan9Basic code, returns console output |
| `compile_check` | Checks if code compiles without running it |
| `load_editor` | Loads code into the editor for the user to see |
| `get_editor_code` | Reads the current code from the editor |
| `get_console_output` | Reads the current console text |
| `list_files` | Lists all .bas files in the user's directory |
| `read_file` | Reads a saved .bas file by name |
| `save_file` | Saves code to a .bas file |

**Security:**
- File operations are sandboxed to the Plan9Basic documents directory
- No path traversal is allowed (no `..`, `/`, or `\` in filenames)
- Code execution uses Plan9Basic's existing VM timeout
- The tool-use loop has a maximum of 5 iterations per request

---

## Complete Example: AI-Powered Code Generator

```basic
' ============================================
' AI Code Generator with Tool-Use
' ============================================

' Initialize pointers
let ai# = Pointer#(0)
let eng# = Pointer#(0)

' Setup AI
let key$ = "your-api-key-here"
let ai# = ai_client#("anthropic", key$)
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)

' Create Intelligence Engine
let eng# = p9_engine#(ai#, "knowledge/", "skills/")
p9_maxtokens#(eng#, 24000)

' Show tool status
println "Engine ready!"
println "Tools: " + str$(p9_tools_count(eng#))
println "Available: " + p9_tools_list$(eng#)
println ""

' Generate with tools - AI creates, loads, and verifies code
let result$ = p9_generate_tools$(eng#, "Create a temperature converter with a nice interface")
println result$

' Check what was generated
println ""
println "Last skill: " + p9_lastskill$(eng#)
println "Tokens used: " + str$(p9_lasttokens(eng#))

' Cleanup
let x = p9_engine_free(eng#)
let x = ai_free(ai#)
```

---

## Complete Example: GUI AI Assistant

```basic
' ============================================
' AI Code Assistant - GUI Applet
' ============================================

' Initialize pointers
let frm# = Pointer#(0)
let lay# = Pointer#(0)
let lblTitle# = Pointer#(0)
let edtPrompt# = Pointer#(0)
let btnGenerate# = Pointer#(0)
let memoResult# = Pointer#(0)
let ai# = Pointer#(0)
let eng# = Pointer#(0)

' AI Setup
let ai# = ai_client#("anthropic", "your-key")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)
let eng# = p9_engine#(ai#, "knowledge/", "skills/")
p9_maxtokens#(eng#, 24000)

' Build UI
let frm# = form#("AI Assistant", 500, 400)
let lay# = layout#(frm#, 0, 0, 500, 400)
let lblTitle# = label#(lay#, "Plan9Basic AI", 10, 10, 480, 30)
label_fontsize#(lblTitle#, 18)
let edtPrompt# = edit#(lay#, 10, 50, 380, 30)
edit_prompt#(edtPrompt#, "Describe what you want...")
let btnGenerate# = button#(lay#, "Generate", 395, 50, 95, 30)
let memoResult# = memo#(lay#, 10, 90, 480, 300)
memo_readonly#(memoResult#, 1)
memo_text#(memoResult#, "Type a description and press Generate.")

' Event handler
function ongenerate(sender#) local prompt$, result$
  let prompt$ = edit_text$(edtPrompt#)
  if len(prompt$) = 0 then
    memo_text#(memoResult#, "Please enter a description.")
    return 0
  end if
  memo_text#(memoResult#, "Working...")
  let result$ = p9_generate_tools$(eng#, prompt$)
  if left$(result$, 2) = "? " then
    memo_text#(memoResult#, "Error: " + mid$(result$, 3))
  else
    memo_text#(memoResult#, "Done!\r\n\r\n" + result$)
  end if
  return 0
end function

button_onclick#(btnGenerate#, "ongenerate")

' Show form (non-blocking - event-driven from here)
' Do NOT free engine/AI client here!
' form_show returns immediately, but the form and its callbacks
' still need these objects. The GC will handle cleanup automatically
' when the user runs another program or closes the app.
form_show(frm#)
```

---

## AILib Functions Used by P9EngineLib

The Intelligence Engine requires an AI client created with AILib. Here are
the most commonly used AILib functions:

| Function | Signature | Description |
|----------|-----------|-------------|
| `ai_client#(provider$, key$)` | `ai_client#@$$` | Create AI client |
| `ai_model#(ai#, model$)` | `ai_model#@#$` | Set model name |
| `ai_maxtokens#(ai#, n)` | `ai_maxtokens#@#n` | Set max response tokens |
| `ai_system#(ai#, prompt$)` | `ai_system#@#$` | Set system prompt |
| `ai_temperature#(ai#, n)` | `ai_temperature#@#n` | Set temperature |
| `ai_free(ai#)` | `ai_free@#` | Free AI client |

**Important:** All setter functions (`ai_model#`, `ai_maxtokens#`, etc.) return
the AI client pointer. They can be called as unassigned statements:

```basic
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)
ai_temperature#(ai#, 0.7)
```

Or with assignment if the return value is needed:

```basic
let ai# = ai_model#(ai#, "claude-sonnet-4-20250514")
```
