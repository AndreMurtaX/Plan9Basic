# Tool-Use Extension — Integration Guide

## What Changed

### New File
- **ToolExecutor.pas** (453 lines) — Tool definition registry and dispatcher

### Modified Files
| File | Before | After | Delta |
|------|--------|-------|-------|
| AILib.pas | 1952 | 2626 | +674 |
| IntelligenceEngine.pas | 912 | 1161 | +249 |
| P9EngineLib.pas | 426 | 504 | +78 |
| UnitMain.pas | 2878 | 3411 | +533 |

**Total new code: ~1,987 lines** (includes tool-use implementation + bug fixes)

---

## Step 1: Add ToolExecutor.pas to the Project

Copy `ToolExecutor.pas` to your `Libs/AI/` folder alongside the other AI units.

Add it to `Plan9Basic.dpr`:

```pascal
uses
  // ... existing units ...
  ToolExecutor in 'Libs\AI\ToolExecutor.pas',  // <-- ADD THIS
  // ... rest of AI units ...
```

---

## Step 2: Replace Modified Files

Replace these 4 files with the updated versions:

- `Libs/AI/AILib.pas`
- `Libs/AI/IntelligenceEngine.pas`
- `Libs/AI/P9EngineLib.pas`
- `UnitMain.pas`

---

## Step 3: Verify Compilation

Build the project. There should be no breaking changes.

---

## How It Works

### Auto-Registration Flow

When a BASIC program creates an Intelligence Engine, the editor tools are
registered automatically:

```
FormCreate
  └── P9EngineLib.OnEditorToolRegistration := RegisterEditorTools
        │
        ▼ (later, when BASIC runs)
  
BASIC: let eng# = p9_engine#(ai#, "knowledge/", "skills/")
  └── P9EngineLib.p_p9_engine_create
        └── OnEditorToolRegistration(Engine)
              └── TfrmMain.RegisterEditorTools(Engine)
                    └── Registers 8 tools with callbacks to TfrmMain
```

### Tool-Use Conversation Loop

When the AI decides to use tools:

```
1. BASIC: let code$ = p9_generate$(eng#, "Create a calculator and run it")
   or:    let code$ = p9_generate_tools$(eng#, "Create a calculator and run it")

2. IntelligenceEngine.Generate detects action verb "run" → uses tools

3. AI receives tool definitions in request, responds with tool calls:
   - load_editor(code="...")
   - compile_check(code="...")

4. Engine executes tools via TfrmMain callbacks

5. Results sent back to AI

6. AI responds with final text

7. Loop repeats if AI makes more tool calls (max 5 iterations)
```

### The 8 Editor Tools

| Tool | What It Does |
|------|-------------|
| `run_program` | Compiles & executes code, returns console output |
| `compile_check` | Checks if code compiles, returns OK or errors |
| `load_editor` | Puts code in the editor for the user to see |
| `get_editor_code` | Reads current code from the editor |
| `get_console_output` | Reads current console text |
| `list_files` | Lists .bas files in the user's directory |
| `read_file` | Reads a saved .bas file |
| `save_file` | Saves code to a .bas file |

### New BASIC Functions

| Function | Description |
|----------|-------------|
| `p9_generate_tools$(eng#, query$)` | Force tool-use generation |
| `p9_tools_enable#(eng#, 1/0)` | Enable/disable tool-use |
| `p9_tools_count(eng#)` | Number of registered tools |
| `p9_tools_list$(eng#)` | Comma-separated tool names |

### Security

- `run_program` uses Plan9Basic's existing VM with timeout
- `read_file` / `save_file` are restricted to `GetBasePath()` — no path traversal
- Tool-use loop has a hard cap of 5 iterations (configurable)
- All tools execute in the main thread via TfrmMain methods

---

## Smoke Test

```basic
' Test tool-use integration
let key$ = "your-api-key"
let ai# = Pointer#(0)
let eng# = Pointer#(0)
let ai# = ai_client#("anthropic", key$)
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)

let eng# = p9_engine#(ai#, "knowledge/", "skills/")

' Check tools are registered
println "Tools: " + str$(p9_tools_count(eng#))
println "Names: " + p9_tools_list$(eng#)

' Generate with tools (AI can interact with editor)
let result$ = p9_generate_tools$(eng#, "Create a hello world program and load it in the editor")
println "Result: " + result$

' Cleanup
let x = p9_engine_free(eng#)
let x = ai_free(ai#)
```

Expected output:
```
Tools: 8
Names: run_program,compile_check,load_editor,get_editor_code,get_console_output,list_files,read_file,save_file
Result: (AI's response text)
```

And the editor should now contain the generated code.
