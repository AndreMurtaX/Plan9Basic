# Plan9Basic Intelligence Engine — Layer 2 Specification

> **Revision 2.0** — Updated to reflect the actual implementation as of February 2026.
> This document supersedes the original v1.0 specification.

## Architecture Overview

The Intelligence Engine is the middle layer between AILib (transport) and the Editor UI (prompt terminal). Its job is to transform a raw user request like *"make me a calculator"* into an enriched prompt that produces **working Plan9Basic code** — not hallucinated guesses.

```
User Request: "Create a calculator with buttons"
        │
        ▼
┌─────────────────────────────────────────────────┐
│           INTELLIGENCE ENGINE (Layer 2)          │
│                                                   │
│  1. INTENT CLASSIFIER                             │
│     → Detects: GUI applet, needs form + buttons   │
│                                                   │
│  2. RAG ENGINE                                    │
│     → Retrieves: FormLib, ButtonLib, LabelLib,    │
│        LayoutLib docs + calculator examples        │
│                                                   │
│  3. SKILL SELECTOR                                │
│     → Loads: "gui_applet" skill template           │
│        with form creation boilerplate              │
│                                                   │
│  4. PROMPT ASSEMBLER                              │
│     → Builds system prompt:                        │
│        [Language Rules] + [Skill Template] +       │
│        [RAG Context] + [User Request]              │
│                                                   │
│  5. TOOL EXECUTOR (optional, for tool-use mode)   │
│     → Defines: compile_check, run_program,         │
│        load_editor, save_file, etc.                │
└─────────────────┬───────────────────────────────┘
                  │
                  ▼
         AILib (Layer 1)
         ai_completesystem$(ai#, system$, user$)
                  │
                  ▼
         Working Plan9Basic code
```

---

## Part 1: RAG Engine

### 1.1 Knowledge Base Structure

The RAG knowledge base is organized as a collection of **documents** stored as plain-text files on disk. Each document has metadata and content optimized for retrieval.

**Directory layout:**

```
plan9basic/
  knowledge/
    index.json              ← Master index (generated)
    language/
      syntax.md             ← Language syntax rules
      types.md              ← Data types and conventions
      operators.md          ← Operators and expressions
      control_flow.md       ← IF/FOR/WHILE/FUNCTION
      error_handling.md     ← Error patterns
      conventions.md        ← Critical rules (Pointer#(0), local, etc.)
    libraries/
      FormLib.md            ← One file per library
      ButtonLib.md
      LabelLib.md
      ...                   ← 100+ library docs
    patterns/
      gui_form_basic.md     ← Common code patterns
      gui_event_wiring.md
      file_read_write.md
      http_request.md
      json_parse.md
      sqlite_crud.md
      timer_animation.md
      ...
    examples/
      calculator.bas        ← Complete working applets
      todo_list.bas
      image_viewer.bas
      chat_client.bas
      ...
```

### 1.2 Document Format

Each knowledge document follows a standard format that enables efficient retrieval and ranking:

```markdown
---
id: formlib
title: FormLib - Form Management
category: library
subcategory: gui_control
tags: form, window, gui, dialog, modal, show, hide, close, resize
functions: form#, form_caption#, form_size#, form_position#, form_show, ...
depends: [LayoutLib, PanelLib]
complexity: beginner
platform: all
---

# FormLib — Form Management

## Overview
FormLib provides functions to create and manage application windows.
Every GUI applet starts with a form.

## Quick Reference
| Function | Signature | Description |
|----------|-----------|-------------|
| form# | form#() → pointer | Create a new form |
| form_caption# | form_caption#(frm#, text$) → pointer | Set title |
| form_size# | form_size#(frm#, w, h) → pointer | Set dimensions |
...

## Essential Pattern
```basic
let frm# = form#()
form_caption#(frm#, "My App")
form_size#(frm#, 640, 480)
form_position#(frm#, 4)  ' center screen
form_show(frm#)
```

## Events
| Event | Callback Signature | When |
|-------|-------------------|------|
| OnShow | function name(sender#) | Form becomes visible |
| OnClose | function name(sender#, action) | Form closing |
| OnResize | function name(sender#) | Form resized |
...
```

### 1.3 Index Generation

A master index (`index.json`) is pre-generated from the document headers and updated whenever docs change. This avoids parsing files at query time.

**index.json structure:**

```json
{
  "version": 1,
  "generated": "2026-02-10T12:00:00",
  "document_count": 187,
  "documents": [
    {
      "id": "formlib",
      "path": "libraries/FormLib.md",
      "title": "FormLib - Form Management",
      "category": "library",
      "subcategory": "gui_control",
      "tags": ["form", "window", "gui", "dialog", "modal", "show", "hide", "close", "resize"],
      "functions": ["form#", "form_caption#", "form_size#", "form_position#", "form_show"],
      "depends": ["LayoutLib", "PanelLib"],
      "complexity": "beginner",
      "platform": "all",
      "size_bytes": 4200,
      "token_estimate": 1050,
      "summary": "Create and manage application windows"
    },
    ...
  ],
  "tag_index": {
    "form": ["formlib", "gui_form_basic"],
    "button": ["buttonlib", "gui_form_basic", "calculator"],
    "json": ["jsonlib", "json_parse", "http_request"],
    ...
  },
  "function_index": {
    "form#": "formlib",
    "form_caption#": "formlib",
    "button#": "buttonlib",
    "json_parse#": "jsonlib",
    ...
  }
}
```

### 1.4 Retrieval Algorithm

The retrieval system uses a **multi-signal scoring** approach that doesn't require vector embeddings — it runs entirely in Delphi with no external dependencies.

**Step 1: Query Analysis**

Extract signals from the user's natural language request:

```
Input: "Create a calculator with buttons"
Extracted:
  - Keywords: [calculator, buttons, create]
  - FunctionNames: []  (none detected in this query)
  - Intent: gui  (detected by: "create" + "buttons")
  - IntentScore: confidence value
  - LibraryHints: []  (no explicit library names mentioned)
  - IsFollowUp: false
```

**Step 2: Candidate Scoring**

For each document in the index, compute a relevance score using 8 weighted signals:

```
Score = (tag_matches × 3.0)
      + (title_matches × 2.5)
      + (function_matches × 5.0)
      + (keyword_in_id × 3.0)
      + (library_hint × 10.0)
      + (category_bonus × 2.0)
      + (dependency_bonus × 1.5)
      + (language_boost × 0.5..1.0)

Where:
  tag_matches      = count of query keywords found in document tags
  title_matches    = count of query keywords found in document title
  function_matches = count of function names from query found in document
                     (supports partial match: "button_text" matches "button_text#")
  keyword_in_id    = exact match = 2×3.0, partial = 1×3.0 (min 3 chars)
  library_hint     = 10.0 if user explicitly named this library (highest priority)
  category_bonus   = 2.0 if document category/subcategory matches detected intent
  dependency_bonus = 1.5 for each already-selected doc that depends on this one
  language_boost   = 0.5 baseline for language docs; +1.0 for 'conventions'/'syntax'
```

Documents scoring below `RAG_MIN_RELEVANCE_SCORE` (1.0) are excluded. Maximum of `RAG_MAX_RESULTS` (15) documents returned.

**Step 3: Token Budget Selection**

Select top-scoring documents that fit within the token budget:

```
MAX_RAG_TOKENS = 6000  (adjustable, ~25% of a typical 24K context)
HIGH_RELEVANCE_THRESHOLD = 8.0

sorted = sort candidates by score descending
selected = []
total_tokens = 0
for each candidate in sorted:
    if total_tokens + candidate.token_estimate <= MAX_RAG_TOKENS:
        selected.add(candidate)
        total_tokens += candidate.token_estimate
    else if candidate.score > HIGH_RELEVANCE_THRESHOLD:
        // For highly relevant docs, include truncated version
        // ExtractEssentialSections keeps Quick Reference + Essential Pattern
        selected.add(truncate(candidate, remaining_budget))
        break
```

**Step 4: Dependency Resolution**

If ButtonLib is selected but FormLib is not, auto-include FormLib (every GUI control needs a form). This uses the `depends` metadata:

```
for each selected_doc:
    for each dep in selected_doc.depends:
        if dep not in selected:
            selected.add(dep)  // Prepend, as it's foundational
```

### 1.5 Delphi Implementation Classes

```pascal
type
  TRAGDocument = record
    Id: String;
    Path: String;
    Title: String;
    Category: String;          // 'library', 'language', 'pattern', 'example'
    Subcategory: String;       // 'gui_control', 'shape', 'effect', 'data', etc.
    Tags: TArray<String>;
    Functions: TArray<String>;
    Depends: TArray<String>;
    Complexity: String;        // 'beginner', 'intermediate', 'advanced'
    Platform: String;          // 'all', 'desktop', 'mobile'
    SizeBytes: Integer;
    TokenEstimate: Integer;
    Summary: String;           // One-line summary for quick display
    Content: String;           // Lazy-loaded, empty until retrieved
    ContentLoaded: Boolean;    // True once content has been loaded from disk
  end;

  TRAGResult = record
    Document: TRAGDocument;
    Score: Double;             // Relevance score (higher = more relevant)
    Truncated: Boolean;        // True if content was truncated to fit budget
    ContentForPrompt: String;  // Final content to inject (may be truncated)
    TokensUsed: Integer;       // Actual tokens consumed by this result
    MatchReasons: String;      // Debug: why this document was selected
  end;

  TRAGQueryAnalysis = record
    OriginalQuery: String;
    Keywords: TArray<String>;       // Extracted content keywords
    FunctionNames: TArray<String>;  // Detected Plan9Basic function references
    Intent: String;                 // Detected intent: 'gui', 'console', 'data', etc.
    IntentScore: Double;            // Confidence of intent detection
    IsFollowUp: Boolean;            // True if query references previous context
    LibraryHints: TArray<String>;   // Explicit library name mentions
  end;

  TRAGEngine = class
  private
    FBasePath: String;
    FIndexPath: String;
    FDocuments: TList<TRAGDocument>;
    FDocById: TDictionary<String, Integer>;           // id → index
    FTagIndex: TDictionary<String, TList<Integer>>;   // tag → [doc indices]
    FFuncIndex: TDictionary<String, Integer>;          // function → doc index
    FCategoryIndex: TDictionary<String, TList<Integer>>;
    FMaxTokens: Integer;
    FIndexLoaded: Boolean;
    FIntentKeywords: TDictionary<String, TArray<String>>;
    FStopWords: TDictionary<String, Boolean>;
    // Internal methods ...
  public
    constructor Create(const BasePath: String);
    destructor Destroy; override;

    // Index management
    procedure LoadIndex;            // Load from index.json
    procedure BuildIndex;           // Rebuild by scanning knowledge base files
    procedure SaveIndex;            // Save in-memory index to index.json

    // Core retrieval
    function Retrieve(const Query: String;
      MaxTokens: Integer = 0): TArray<TRAGResult>;
    function RetrieveByFunctions(
      const Functions: TArray<String>): TArray<TRAGResult>;
    function RetrieveByTags(
      const Tags: TArray<String>): TArray<TRAGResult>;
    function GetDocument(const Id: String): TRAGDocument;

    // Query analysis (exposed for testing/debugging)
    function Analyze(const Query: String): TRAGQueryAnalysis;

    // Information
    function DocumentCount: Integer;
    function FunctionCount: Integer;
    function ListDocumentIds: TArray<String>;
    function ListTags: TArray<String>;
    function ListCategories: TArray<String>;
    function GetIndexSummary: String;

    // Properties
    property BasePath: String read FBasePath;
    property MaxTokens: Integer read FMaxTokens write FMaxTokens;
    property IndexLoaded: Boolean read FIndexLoaded;
  end;
```

### 1.6 Knowledge Base Generation

The library documentation is **auto-generated** from the Pascal source files by `TRAGDocGenerator` (in `RAGDocGenerator.pas`). The generator parses each `*Lib.pas` file and extracts:

- Function registration signatures from `Lib.Add('signature', ...)` calls
- Unit header comments for description, features, and events
- Library category classification (GUI control, shape, effect, animation, data, etc.)
- Error constants and messages

**Generator produces:**

```
knowledge/
  index.json                    ← Master index (auto-generated)
  libraries/
    ButtonLib.md                ← One per library
    FormLib.md
    ...
  language/
    syntax.md                   ← Language syntax rules
    conventions.md              ← Critical coding conventions
    types.md                    ← Data types reference
    control_flow.md             ← Control structures
```

Each generated markdown file includes a YAML header (id, title, category, tags, functions, depends), an overview section, a quick reference table, essential usage patterns, and events table if applicable.

---

## Part 2: Skills System

### 2.1 What Skills Are

A **Skill** is a reusable prompt template that packages domain knowledge, code patterns, and constraints for a specific category of task. Skills dramatically reduce hallucination by giving the AI a proven code skeleton and explicit rules.

Think of Skills as expert recipes: instead of asking someone to cook "something Italian" from scratch, you give them a tested carbonara recipe and let them add variations.

### 2.2 Skill Schema

Each Skill is a JSON file stored in `plan9basic/skills/`:

```json
{
  "id": "gui_applet",
  "name": "GUI Applet Builder",
  "version": "1.0",
  "description": "Creates a GUI applet with form, controls, and event handling",
  "intent_triggers": ["form", "window", "button", "gui", "app", "applet",
                       "interface", "screen", "dialog", "visual"],
  "required_libraries": ["FormLib", "LayoutLib"],
  "optional_libraries": ["ButtonLib", "LabelLib", "EditLib", "PanelLib",
                          "ComboBoxLib", "CheckBoxLib", "ImageLib"],
  "parameters": {
    "app_title": {
      "type": "string",
      "description": "Application window title",
      "default": "My Applet"
    },
    "window_width": {
      "type": "number",
      "description": "Window width in pixels",
      "default": 640
    },
    "window_height": {
      "type": "number",
      "description": "Window height in pixels",
      "default": 480
    }
  },
  "system_prompt_section": "You are generating a Plan9Basic GUI applet...",
  "code_template": "...",
  "rules": ["..."],
  "examples": ["..."]
}
```

### 2.3 Skill Components

Each Skill has four critical sections that are injected into the system prompt:

**A) Rules Section** — Non-negotiable syntax and convention rules:

```json
{
  "rules": [
    "ALL pointer variables MUST be initialized: let frm# = Pointer#(0)",
    "Local variables MUST be declared on the SAME line as the function header using the 'local' keyword",
    "Boolean expressions are ONLY valid inside IF/WHILE conditions, NEVER as function parameters",
    "Event callback functions receive sender# as first parameter",
    "Event callback names are stored in LOWERCASE — always use lowercase function names for callbacks",
    "Use form_position#(frm#, 4) to center a form on screen",
    "Every GUI applet MUST call form_show(frm#) as the LAST statement",
    "Use layout_create#(parent#) for automatic child control arrangement",
    "Controls MUST be parented to a form or container: button_parent#(btn#, frm#)",
    "Clean up resources in OnClose callback, not after form_show",
    "String variables use $ suffix, pointer variables use # suffix, numbers have no suffix",
    "Functions returning strings end with $, functions returning pointers end with #"
  ]
}
```

**B) Code Template** — The skeleton that the AI fills in:

```json
{
  "code_template": "' {app_title} — Plan9Basic GUI Applet\n' Generated by AI Assistant\n\n' === Initialize pointer variables ===\nlet frm# = Pointer#(0)\n{control_declarations}\n\n' === Create form ===\nlet frm# = form#()\nform_caption#(frm#, \"{app_title}\")\nform_size#(frm#, {window_width}, {window_height})\nform_position#(frm#, 4)\n\n{control_creation}\n\n{event_handlers}\n\n' === Show form (must be last) ===\nform_show(frm#)"
}
```

**C) System Prompt Section** — Detailed instructions for the AI:

```
You are generating Plan9Basic code for a GUI applet. Follow these rules EXACTLY:

CRITICAL SYNTAX RULES:
1. Pointer variables MUST be initialized before use: let varname# = Pointer#(0)
2. Local variables are declared on the function header line: function name(param#) local x, y$, z#
3. Boolean values: use 1 for true, 0 for false. There is no boolean type.
4. String concatenation uses + operator.
5. Event callbacks: function names must be lowercase when registered.
6. Comments start with ' (apostrophe) or REM keyword.
7. form_show(frm#) must be the LAST statement in the main code.
   All event handlers and helper functions should be defined BEFORE form_show.

CODE STRUCTURE:
1. Variable initialization (all Pointer#(0) declarations)
2. Form creation and configuration
3. Control creation, configuration, and parenting
4. Layout setup (if using layouts)
5. Event handler function definitions
6. form_show(frm#) — always last

RESPONSE FORMAT:
Return ONLY the Plan9Basic source code. No markdown, no explanations, no code fences.
Start with a comment line: ' {description}
```

**D) Examples** — Working code that demonstrates the pattern:

```json
{
  "examples": [
    {
      "description": "Simple form with a button",
      "code": "' Simple Button App\nlet frm# = Pointer#(0)\nlet btn# = Pointer#(0)\n\nlet frm# = form#()\nform_caption#(frm#, \"Button Demo\")\nform_size#(frm#, 400, 300)\nform_position#(frm#, 4)\n\nlet btn# = button#(frm#)\nbutton_text#(btn#, \"Click Me\")\nbutton_bounds#(btn#, 150, 120, 100, 40)\nbutton_onclick#(btn#, \"onbtnclick\")\n\nfunction onbtnclick(sender#)\n  button_text#(sender#, \"Clicked!\")\nend function\n\nform_show(frm#)"
    }
  ]
}
```

### 2.4 Built-in Skills Library

The initial release includes these Skills, all created programmatically in `TSkillEngine.RegisterBuiltInSkills`:

| Skill ID | Name | Triggers | Description |
|----------|------|----------|-------------|
| `gui_applet` | GUI Applet Builder | form, window, button, gui, app, visual | Full GUI application with controls and events |
| `console_tool` | Console Utility | console, text, print, input, command, cli | Text-based console application |
| `data_processor` | Data Processor | file, json, csv, read, write, parse, data | File reading, transformation, output |
| `http_client` | HTTP Client | api, http, request, web, fetch, download | HTTP requests and response processing |
| `database_app` | SQLite Application | database, sqlite, query, table, sql, crud | SQLite database operations |
| `animation_demo` | Animation Demo | animate, move, fade, rotate, transition | Visual animations and effects |
| `game_simple` | Simple Game | game, score, player, move, collision | Basic interactive game patterns |
| `timer_app` | Timer Application | timer, interval, clock, schedule, periodic | Timer-based periodic operations |
| `multi_form` | Multi-Form App | wizard, pages, navigation, multi, screen | Multiple form/screen navigation |
| `config_app` | Configurable App | settings, config, save, load, preferences | App with persistent configuration |

### 2.5 Skill Selection Algorithm

When a user request arrives, the Skill selector determines which Skill best matches:

```
Input: "Create a to-do list app with add and delete buttons"

1. Tokenize request → [create, todo, list, app, add, delete, buttons]
   (stop words removed)
2. Match against intent_triggers for each skill:
     gui_applet:     hits [app, buttons] → score 2
     console_tool:   hits [] → score 0
     data_processor: hits [] → score 0
     database_app:   hits [] → score 0
3. Contextual boost:
     "todo list" implies persistence → +1 for database_app, +1 for config_app
     "buttons" implies visual → +2 for gui_applet
4. Winner: gui_applet (score 4)
5. Secondary: database_app (score 1) — merge its rules as supplementary context
```

**Multiple Skills can be combined.** If the request implies both GUI and database operations (e.g., "to-do list app that saves to SQLite"), the engine merges the primary skill (gui_applet) with supplementary rules from the secondary skill (database_app).

`SelectSkillDetailed` returns a `TSkillSelection` record containing primary/secondary skill IDs, their match scores, and the matched trigger keywords for debugging.

### 2.6 Delphi Implementation Classes

```pascal
type
  TSkillParameter = record
    Name: String;
    ParamType: String;    // 'string', 'number', 'boolean'
    Description: String;
    DefaultValue: String;
  end;

  TSkillExample = record
    Description: String;
    Code: String;
  end;

  TSkillSelection = record
    PrimaryId: String;
    PrimaryScore: Double;
    SecondaryId: String;       // Empty if no secondary
    SecondaryScore: Double;
    MatchedTriggers: TArray<String>;  // Keywords that matched
  end;

  TSkill = class
  private
    FId: String;
    FName: String;
    FVersion: String;
    FDescription: String;
    FIntentTriggers: TArray<String>;
    FRequiredLibraries: TArray<String>;
    FOptionalLibraries: TArray<String>;
    FParameters: TArray<TSkillParameter>;
    FRules: TArray<String>;
    FSystemPromptSection: String;
    FCodeTemplate: String;
    FExamples: TArray<TSkillExample>;
  public
    procedure LoadFromFile(const Path: String);
    procedure LoadFromJSON(const Obj: TJSONObject);
    function MatchScore(const Keywords: TArray<String>): Double;
    function BuildSystemSection(const Params: TDictionary<String, String>): String;
    function BuildCodeTemplate(const Params: TDictionary<String, String>): String;
    function BuildRulesText: String;
    function BuildExamplesText: String;
    function BuildFullPromptSection(const Params: TDictionary<String, String>): String;
    function ToJSON: TJSONObject;
    property Id: String read FId;
    property Name: String read FName;
    property RequiredLibraries: TArray<String> read FRequiredLibraries;
    property OptionalLibraries: TArray<String> read FOptionalLibraries;
    // ... additional properties for all fields
  end;

  TSkillEngine = class
  private
    FSkills: TObjectDictionary<String, TSkill>;
    FSkillsPath: String;
    FStopWords: TDictionary<String, Boolean>;
    procedure LoadAllSkills;
    procedure RegisterBuiltInSkills;
    procedure LoadSkillsFromDisk;
    function ExtractKeywords(const Query: String): TArray<String>;
    // 10 CreateSkill_* factory methods (one per built-in skill)
  public
    constructor Create(const SkillsPath: String);
    destructor Destroy; override;
    function SelectSkill(const Query: String): TSkill;
    function SelectSkillWithSecondary(const Query: String;
      out Secondary: TSkill): TSkill;
    function SelectSkillDetailed(const Query: String): TSkillSelection;
    function GetSkill(const Id: String): TSkill;
    function ListSkillIds: TArray<String>;
    function SkillCount: Integer;
    procedure ReloadSkills;
    function GetSummary: String;
    property SkillsPath: String read FSkillsPath;
  end;
```

---

## Part 3: Tool Executor

### 3.1 What the Tool Executor Does

The Tool Executor allows the AI to **act on the Plan9Basic environment**, not just generate text. With registered tools, the AI can:

- Compile generated code and check for errors
- Run the program and observe output
- Read the current editor contents
- Load code into the editor
- List and read files from disk
- Save files

This creates a **feedback loop**: generate → load → compile → fix errors → compile again → success.

### 3.2 Architecture

The Tool Executor is a lightweight, protocol-agnostic registry. It is intentionally **decoupled from AILib** — it knows nothing about HTTP, providers, or AI clients. The `IntelligenceEngine` bridges between `TToolExecutor` and `TAIClient`.

```
UnitMain.pas                    IntelligenceEngine
(registers callbacks)           (owns executor)
     │                               │
     ▼                               ▼
┌─────────────────────────────────────────────┐
│           TToolExecutor                     │
│                                             │
│  FTools: Dictionary<name, TToolDef>         │
│  FCallbacks: Dictionary<name, callback>     │
│                                             │
│  RegisterTool(def, callback)                │
│  Execute(call) → TToolResult                │
│  BuildAnthropicTools → JSON                 │
│  BuildOpenAITools → JSON                    │
│  BuildGoogleTools → JSON                    │
└─────────────────────────────────────────────┘
```

The IDE (`UnitMain.pas`) registers tool callbacks at startup. When the AI requests a tool call, the `IntelligenceEngine` dispatches execution through the `TToolExecutor`, then feeds results back to the AI via the appropriate provider protocol.

### 3.3 Tool Definitions

The Tool Executor supports the following tools (registered by the IDE):

#### 3.3.1 `compile_check`
Compiles Plan9Basic source code and reports success or error information.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `code` | string | yes | Complete Plan9Basic source code to compile |

**Result:** Text report with compilation status and any error messages with line numbers.

#### 3.3.2 `run_program`
Compiles and executes Plan9Basic code, capturing console output.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `code` | string | yes | Complete Plan9Basic source code |

**Result:** Console output from the program execution.

#### 3.3.3 `load_editor`
Loads source code into the Plan9Basic editor.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `code` | string | yes | Source code to place in the editor |

**Result:** Confirmation that code was loaded.

#### 3.3.4 `get_editor_code`
Reads the current source code from the Plan9Basic editor.

**Parameters:** None.

**Result:** The complete source code currently in the editor.

#### 3.3.5 `get_console_output`
Reads the current console output.

**Parameters:** None.

**Result:** Text content of the console output panel.

#### 3.3.6 `list_files`
Lists Plan9Basic source files in the working directory.

**Parameters:** None.

**Result:** List of available `.bas` files.

#### 3.3.7 `read_file`
Reads the content of a source file from disk.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `filename` | string | yes | Name of the file to read |

**Result:** File contents as text.

#### 3.3.8 `save_file`
Saves source code to a file on disk.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| `filename` | string | yes | File path to save to |
| `code` | string | no | Source code (if omitted, saves current editor content) |

**Result:** Confirmation with file path.

### 3.4 Provider-Specific JSON Generation

The `TToolExecutor` generates tool definitions in the format required by each AI provider:

- `BuildAnthropicTools` → Anthropic tool-use format (top-level `name`, `description`, `input_schema`)
- `BuildOpenAITools` → OpenAI function calling format (wrapped in `{"type":"function","function":{...}}`)
- `BuildGoogleTools` → Google Gemini format

Provider selection is handled automatically by `TIntelligenceEngine.BuildToolsForProvider` based on the current `FAIClient.Provider`.

### 3.5 Delphi Implementation Classes

```pascal
type
  TToolParam = record
    Name: String;         // Parameter name ("code", "filename")
    ParamType: String;    // JSON Schema type ("string", "number", "boolean")
    Description: String;  // Human-readable description for the LLM
    Required: Boolean;    // True if the parameter is mandatory
  end;

  TToolDef = record
    Name: String;                // Unique tool name ("run_program")
    Description: String;         // Description for the LLM
    Params: TArray<TToolParam>;  // Parameter definitions
  end;

  TToolResult = record
    Success: Boolean;     // True if tool executed successfully
    Output: String;       // Text returned to the AI
  end;

  TToolCall = record
    Id: String;           // Provider-assigned ID (for matching results)
    Name: String;         // Tool name
    Arguments: String;    // JSON string of arguments
  end;

  TToolCallback = function(const Args: TJSONObject): TToolResult of object;

  TToolExecutor = class
  private
    FTools: TDictionary<String, TToolDef>;
    FCallbacks: TDictionary<String, TToolCallback>;
    FToolOrder: TList<String>;   // Preserve registration order for JSON output
    FMaxIterations: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    // Registration
    procedure RegisterTool(const Def: TToolDef; Callback: TToolCallback);
    procedure UnregisterTool(const Name: String);
    procedure ClearTools;

    // Execution
    function Execute(const Call: TToolCall): TToolResult;

    // Query
    function HasTools: Boolean;
    function ToolCount: Integer;
    function GetToolDefs: TArray<TToolDef>;
    function GetToolNames: String;  // Comma-separated list

    // Provider-specific JSON builders
    function BuildAnthropicTools: TJSONArray;
    function BuildOpenAITools: TJSONArray;
    function BuildGoogleTools: TJSONArray;

    property MaxIterations: Integer read FMaxIterations write FMaxIterations;
      // Default: 5
  end;
```

### 3.6 Tool-Use Flow

When the IntelligenceEngine detects an action-oriented query (containing words like "run", "execute", "test", "save", "load", "fix", "debug"), it uses `GenerateWithTools` instead of `GenerateTextOnly`:

```
1. Assemble prompt (RAG + Skill)
2. Append tool guidance instructions to system prompt
3. Build provider-specific tool JSON
4. Call AIClient.ChatWithTools(conversation, message, tools)
5. If response contains tool calls:
   a. Execute each tool via TToolExecutor.Execute
   b. Send results back via AIClient.SendToolResults
   c. Repeat until no more tool calls (max 5 iterations)
6. Extract final text response
```

The `ShouldUseTools` method heuristically decides whether to engage tool-use mode by checking for action hint keywords: "run", "execute", "test", "try", "save", "load", "open", "show me", "list", "check", "fix", "debug". If the ToolExecutor has no registered tools, text-only mode is always used.

---

## Part 4: Prompt Assembler

### 4.1 The Assembly Pipeline

The Prompt Assembler is the orchestrator that combines all pieces into a single, optimized prompt:

```
User Request
    │
    ▼
┌──────────────────────┐
│  1. SKILL SELECTION  │  SelectSkillWithSecondary(query)
│     (local, no API)  │  Returns primary + optional secondary skill
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  2. SKILL SECTION    │  BuildSkillSection(primary, secondary)
│     + token estimate │  Estimate tokens consumed by skill content
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  3. RAG BUDGET       │  CalculateRAGBudget(skillTokens)
│     calculation      │  Dynamic budget based on remaining space
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  4. RAG RETRIEVAL    │  Retrieve(query + skill library hints, budget)
│     (file I/O)       │  Enhanced query with required library names
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  5. PROMPT ASSEMBLY  │  Identity + Language Rules + Skill + RAG +
│                      │  Examples + Template + Output Rules
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  6. USER MESSAGE     │  EnhanceUserMessage(query, skill)
│     enhancement      │  Add context/clarification
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│  7. TOKEN ACCOUNTING │  Estimate totals, calculate response budget
│                      │  Record assembly log for diagnostics
└──────────┬───────────┘
           │
           ▼
     TAssembledPrompt
```

### 4.2 System Prompt Structure

The assembled system prompt follows a strict structure:

```
[IDENTITY]
You are the Plan9Basic AI Assistant. You generate working Plan9Basic
source code for multi-platform applets.

[LANGUAGE RULES — Always included, ~400 tokens]
{Content of language rules — critical syntax rules}

[SKILL CONTEXT — From selected skill, ~300 tokens]
{skill.system_prompt_section}

[SKILL RULES — From selected skill, ~200 tokens]
{skill.rules joined with newlines}

[REFERENCE DOCUMENTATION — From RAG, ~4000-6000 tokens]
The following library documentation is available for this task:

### FormLib
{RAG-retrieved FormLib content}

### ButtonLib
{RAG-retrieved ButtonLib content}

### LabelLib
{RAG-retrieved LabelLib content}

[WORKING EXAMPLES — From skill + RAG, ~500 tokens]
{skill.examples[0].code}

[CODE TEMPLATE — From skill, ~200 tokens]
Use this structure for your code:
{skill.code_template}

[OUTPUT RULES]
- Return ONLY Plan9Basic source code
- No markdown formatting, no code fences, no explanations
- Start with a descriptive comment: ' {description}
- End with form_show(frm#) for GUI apps
- Code must compile and run without errors
```

### 4.3 Token Budget Allocation

For a typical 24K token context window (Claude Haiku) or 128K (Claude Sonnet):

```
Component                    Min Tokens    Max Tokens
─────────────────────────────────────────────────────
Identity                          50            50
Language Rules                   400           400
Skill Context                    200           500
Skill Rules                      150           300
RAG Documentation              2000          8000
Examples                         300          1000
Code Template                    100           300
Output Rules                     100           100
─────────────────────────────────────────────────────
Total System Prompt            3300         10650
User Message                    100           500
AI Response Budget             4000         16000
─────────────────────────────────────────────────────
Grand Total                    7400         27150
```

The assembler dynamically adjusts RAG content based on the model's context window via `CalculateRAGBudget`. With smaller models (Haiku, local LLMs), it retrieves fewer documents. With larger models (Sonnet, Opus), it includes more examples and fuller documentation. The `ResponseBudgetRatio` property (default ~0.4) controls how much of the context window is reserved for the AI response.

### 4.4 Specialized Assembly Methods

In addition to the primary `Assemble` method, the Prompt Assembler provides specialized methods for different workflows:

| Method | Purpose |
|--------|---------|
| `Assemble(query)` | Standard code generation assembly |
| `AssembleWithSkill(query, skillId)` | Force a specific skill override |
| `AssembleRefinement(followUp, prevCode, prevSkill)` | Modify existing code with follow-up |
| `AssembleErrorFix(code, errors, baseSysPrompt)` | Fix compilation errors (auto-fix loop) |
| `AssembleHelpQuery(query)` | Answer a help question using RAG context |

### 4.5 Delphi Implementation

```pascal
type
  TAssembledPrompt = record
    // Core output
    SystemPrompt: String;          // Complete system prompt
    UserMessage: String;           // User's request (may be enhanced)

    // Metadata
    TokenEstimate: Integer;        // Estimated total tokens (system + user)
    SkillUsed: String;             // Primary skill ID
    SecondarySkill: String;        // Secondary skill ID (empty if none)
    RAGDocuments: TArray<String>;  // IDs of RAG documents included
    RAGTokensUsed: Integer;        // Tokens consumed by RAG content

    // Budget details
    MaxContextTokens: Integer;     // Model context window used for budget
    SystemTokens: Integer;         // Tokens in system prompt
    UserTokens: Integer;           // Tokens in user message
    ResponseBudget: Integer;       // Estimated tokens left for AI response

    // Debug
    AssemblyLog: String;           // Step-by-step assembly log
  end;

  TPromptAssembler = class
  private
    FRAGEngine: TRAGEngine;
    FSkillEngine: TSkillEngine;
    FLanguageRules: String;         // Cached language rules text
    FIdentityPrompt: String;        // Cached identity section
    FOutputRules: String;           // Cached output rules section
    FMaxContextTokens: Integer;     // Model context window
    FResponseBudgetRatio: Double;   // Fraction of context for response
  public
    constructor Create(RAG: TRAGEngine; Skills: TSkillEngine);
    destructor Destroy; override;

    function Assemble(const UserQuery: String): TAssembledPrompt;
    function AssembleWithSkill(const UserQuery, SkillId: String): TAssembledPrompt;
    function AssembleRefinement(const FollowUp, PreviousCode,
      PreviousSkill: String): TAssembledPrompt;
    function AssembleErrorFix(const Code, Errors,
      BaseSystemPrompt: String): TAssembledPrompt;
    function AssembleHelpQuery(const Query: String): TAssembledPrompt;

    function GetLanguageRules: String;
    function GetIdentityPrompt: String;

    property MaxContextTokens: Integer read FMaxContextTokens write FMaxContextTokens;
    property ResponseBudgetRatio: Double read FResponseBudgetRatio write FResponseBudgetRatio;
    property RAGEngine: TRAGEngine read FRAGEngine;
    property SkillEngine: TSkillEngine read FSkillEngine;
  end;
```

---

## Part 5: Auto-Fix Loop (Compile Callback + AILib Integration)

### 5.1 The Compile-Fix Cycle

When a compile callback is provided, the Intelligence Engine can automatically fix compilation errors. Instead of coupling directly to a compiler, the engine uses a **callback pattern** that lets the IDE provide its own compilation mechanism:

```pascal
TCompileCallback = function(const Code: String;
  out Errors: String): Boolean of object;
```

This decouples the engine from the Plan9Basic compiler, allowing the IDE to implement compilation however it sees fit.

```
┌─────────┐    generate     ┌──────────┐
│   AI    │───────────────►│  Source   │
│  Model  │                 │   Code   │
└────▲────┘                 └────┬─────┘
     │                           │
     │ fix request               │ TCompileCallback
     │ + error context           │ (provided by IDE)
     │                           ▼
     │                    ┌──────────────┐
     │    errors?    YES  │  Compiler    │
     └────────────────────│  Errors      │
                          └──────┬───────┘
                                 │ NO errors
                                 ▼
                          ┌──────────────┐
                          │   Success!   │
                          │   Return     │
                          │   code       │
                          └──────────────┘
```

**Implementation flow:**

```pascal
function TIntelligenceEngine.GenerateAndValidate(
  const UserQuery: String): TGenerationResult;
var
  FinalCode, LastErrors: String;
  Attempts: Integer;
  CompileOK: Boolean;
begin
  // Phase 1: Generate normally (text-only)
  Result := GenerateTextOnly(UserQuery);

  if not Result.Success then Exit;
  if not FAutoFix then Exit;
  if not Assigned(FOnCompile) then Exit;

  // Phase 2: Validate + Fix loop
  CompileOK := RunAutoFixLoop(
    Result.Code, FLastSystemPrompt,
    FinalCode, Attempts, LastErrors);

  Result.Code := FinalCode;
  Result.FixAttempts := Attempts;
  Result.CompileErrors := LastErrors;
  Result.Success := CompileOK;

  // Update conversation with final code
  if CompileOK and (Attempts > 0) then
  begin
    FConversation.Clear;
    FConversation.AddMessage(airUser, UserQuery);
    FConversation.AddMessage(airAssistant, FinalCode);
  end;

  if not CompileOK then
    Result.Code := ''' WARNING: Code may contain errors (auto-fix failed after ' +
      IntToStr(Attempts) + ' attempts)' + sLineBreak + FinalCode;

  FLastResult := Result;
end;
```

The `RunAutoFixLoop` method iterates up to `MaxFixAttempts` (default 3) times:

1. Try compiling current code via `TCompileCallback`
2. If errors: assemble an error-fix prompt via `FAssembler.AssembleErrorFix`
3. Call AI to fix the errors
4. Clean the response (strip markdown fences)
5. Repeat from step 1

### 5.2 Error Context Formatting

When feeding errors back to the AI, `AssembleErrorFix` produces structured context:

```
[Original system prompt]

ERROR FIX MODE:
You are fixing compilation errors in Plan9Basic code.
Fix ONLY the reported errors. Do NOT change working code.
Return the COMPLETE corrected source code.
Ensure all pointer variables are initialized with Pointer#(0).

---

COMPILATION ERRORS:
Line 15: Unknown function 'buton#' — Did you mean 'button#'?
Line 23: Type mismatch: expected pointer, got string
Line 31: Undeclared variable 'result$' — Did you forget 'local result$'?

CODE TO FIX:
[full source code]

Return the COMPLETE corrected code with all errors fixed.
```

---

## Part 6: Complete Intelligence Engine Class

### 6.1 Main Orchestrator

```pascal
type
  /// Callback for compilation check in auto-fix loop
  TCompileCallback = function(const Code: String;
    out Errors: String): Boolean of object;

  /// Callback for streaming generation progress
  TProgressCallback = procedure(const Phase, Detail: String) of object;

  /// Complete result of a code generation
  TGenerationResult = record
    Code: String;                  // Generated (or fixed) source code
    Success: Boolean;              // True if code was generated (and compiled if validated)
    SkillUsed: String;             // Skill ID that was selected
    SecondarySkill: String;        // Secondary skill ID if compound request
    RAGDocuments: TArray<String>;  // RAG documents that were included
    TokensUsed: Integer;           // Total prompt tokens used
    ResponseBudget: Integer;       // Tokens available for AI response
    FixAttempts: Integer;          // Number of fix attempts (0 if no auto-fix)
    CompileErrors: String;         // Last compile errors (empty if success)
    AssemblyLog: String;           // Prompt assembly debug log
    ErrorMessage: String;          // Engine-level error (not compile error)
  end;

  TIntelligenceEngine = class
  private
    // Sub-engines (owned)
    FRAGEngine: TRAGEngine;
    FSkillEngine: TSkillEngine;
    FAssembler: TPromptAssembler;

    // AI transport (NOT owned — external reference)
    FAIClient: TAIClient;

    // Conversation for follow-ups
    FConversation: TAIConversation;

    // Configuration
    FMaxContextTokens: Integer;
    FAutoFix: Boolean;
    FMaxFixAttempts: Integer;

    // Callbacks
    FOnCompile: TCompileCallback;
    FOnProgress: TProgressCallback;

    // Tool-use
    FToolExecutor: TToolExecutor;    // Owned
    FToolsEnabled: Boolean;

    // State
    FLastResult: TGenerationResult;
    FLastSystemPrompt: String;
  public
    /// Create Intelligence Engine with pre-configured sub-engines.
    /// RAG and Skills ownership is transferred to this engine.
    constructor Create(RAG: TRAGEngine; Skills: TSkillEngine);
    destructor Destroy; override;

    // --- Configuration ---
    procedure SetAIClient(Client: TAIClient);
    procedure SetCompileCallback(Callback: TCompileCallback);
    procedure SetProgressCallback(Callback: TProgressCallback);

    // --- Code Generation ---
    function Generate(const UserQuery: String): TGenerationResult;
    function GenerateAndValidate(const UserQuery: String): TGenerationResult;
    function Refine(const FollowUpQuery: String): TGenerationResult;
    function GenerateWithSkill(const UserQuery, SkillId: String): TGenerationResult;
    function GenerateWithTools(const UserQuery: String): TGenerationResult;

    // --- Information Queries ---
    function ExplainCode(const Code: String): String;
    function SearchFunctions(const Query: String): String;
    function GetHelp(const LibOrFuncName: String): String;
    function SuggestLibraries(const Description: String): String;
    function AskQuestion(const Question: String): String;

    // --- State ---
    property LastResult: TGenerationResult read FLastResult;
    procedure ClearConversation;
    function GetSummary: String;

    // --- Properties ---
    property RAGEngine: TRAGEngine read FRAGEngine;
    property SkillEngine: TSkillEngine read FSkillEngine;
    property Assembler: TPromptAssembler read FAssembler;
    property AIClient: TAIClient read FAIClient;
    property MaxContextTokens: Integer read FMaxContextTokens write SetMaxContextTokens;
    property AutoFix: Boolean read FAutoFix write FAutoFix;
    property MaxFixAttempts: Integer read FMaxFixAttempts write FMaxFixAttempts;
    property OnCompile: TCompileCallback read FOnCompile write FOnCompile;
    property OnProgress: TProgressCallback read FOnProgress write FOnProgress;
    property ToolExecutor: TToolExecutor read FToolExecutor;
    property ToolsEnabled: Boolean read FToolsEnabled write FToolsEnabled;
  end;
```

**Key design decisions:**

- `Create` receives **pre-created** `TRAGEngine` and `TSkillEngine` objects and takes ownership of them. This allows the caller to configure sub-engines (e.g., load index, set paths) before handing them off.
- `FAIClient` is **NOT owned** — the caller manages its lifecycle. This prevents double-free issues when multiple components reference the same AI client.
- `SetCompileCallback` automatically sets `FAutoFix := True` when a callback is assigned.
- `Generate` auto-selects between `GenerateTextOnly` and `GenerateWithTools` based on `ShouldUseTools` heuristics.
- `TToolExecutor` is created internally in the constructor and exposed via the `ToolExecutor` property. The IDE registers callbacks against it directly.

### 6.2 Usage From Plan9Basic (via Binding Functions)

The Intelligence Engine is exposed to Plan9Basic through binding functions in `P9EngineLib.pas`, enabling both the built-in prompt terminal AND user-written BASIC programs to use it:

```basic
' === Using the Intelligence Engine from Plan9Basic ===

' Initialize AI client
let ai# = ai_client#("anthropic", "sk-ant-xxxxx")

' Initialize Intelligence Engine (auto-resolves knowledge/ and skills/ paths)
let engine# = p9_engine#(ai#)

' Generate code from natural language
let code$ = p9_generate$(engine#, "Create a calculator with buttons")
println code$

' Generate with auto-fix (requires compile callback)
let code$ = p9_generate_validated$(engine#, "Create a to-do list app")

' Follow-up refinement
let code$ = p9_refine$(engine#, "Make the buttons bigger and add a history display")

' Generate with explicit skill
let code$ = p9_generate_skill$(engine#, "Make a timer", "timer_app")

' Generate with tool-use (AI interacts with editor)
let code$ = p9_generate_tools$(engine#, "Create and run a hello world program")

' Search functions
let info$ = p9_search$(engine#, "how to read JSON files")
println info$

' Get library documentation
let docs$ = p9_help$(engine#, "FormLib")
println docs$

' Suggest relevant libraries
let libs$ = p9_suggest$(engine#, "I want to make HTTP requests and parse JSON")
println libs$

' Ask a general question
let answer$ = p9_ask$(engine#, "How do I handle events in Plan9Basic?")
println answer$

' Explain existing code
let explanation$ = p9_explain$(engine#, code$)
println explanation$

' Get engine summary
let status$ = p9_summary$(engine#)
println status$

' Tool-use management
let x = p9_tools_enable#(engine#, 1)  ' enable tool-use
let count = p9_tools_count(engine#)
let names$ = p9_tools_list$(engine#)

' Cleanup
let x = p9_engine_free(engine#)
let x = ai_free(ai#)
```

### 6.3 Binding Function Signatures

All 22 registered binding functions:

```
' Intelligence Engine management
p9_engine#@#              → p9_engine#(ai_client#)                          [auto-resolve paths]
p9_engine#@#$$            → p9_engine#(ai_client#, knowledge_path$, skills_path$) [explicit paths]
p9_engine_free@#          → p9_engine_free(engine#)

' Code generation
p9_generate$@#$           → p9_generate$(engine#, query$)
p9_generate_validated$@#$ → p9_generate_validated$(engine#, query$)
p9_refine$@#$             → p9_refine$(engine#, followup$)
p9_generate_skill$@#$$    → p9_generate_skill$(engine#, query$, skill_id$)
p9_generate_tools$@#$     → p9_generate_tools$(engine#, query$)

' Information queries
p9_search$@#$             → p9_search$(engine#, query$)
p9_help$@#$               → p9_help$(engine#, library_or_function$)
p9_suggest$@#$            → p9_suggest$(engine#, description$)
p9_ask$@#$                → p9_ask$(engine#, question$)
p9_explain$@#$            → p9_explain$(engine#, code$)

' Configuration
p9_autofix#@#n            → p9_autofix#(engine#, enabled)
p9_maxtokens#@#n          → p9_maxtokens#(engine#, tokens)

' Tool-use management
p9_tools_enable#@#n       → p9_tools_enable#(engine#, enabled)
p9_tools_count@#          → p9_tools_count(engine#)
p9_tools_list$@#          → p9_tools_list$(engine#)

' State queries
p9_lastcode$@#            → p9_lastcode$(engine#)
p9_lastskill$@#           → p9_lastskill$(engine#)
p9_lasttokens@#           → p9_lasttokens(engine#)
p9_summary$@#             → p9_summary$(engine#)
```

---

## Part 7: Implementation Roadmap

### Phase 1: RAG Engine (Foundation)
**Effort: 1-2 weeks**

1. Create knowledge base directory structure
2. Implement `TRAGDocGenerator` — auto-generates markdown docs from `*Lib.pas` files
3. Generate docs for all 100+ libraries
4. Write language rules documents (syntax, conventions, types)
5. Implement `TRAGEngine` with index generation and multi-signal scoring
6. Write 10 code pattern documents and 10 example applets
7. Test retrieval quality with various queries

**Deliverable:** Working RAG engine that retrieves relevant docs for any query.

### Phase 2: Skills System
**Effort: 1 week**

1. Define the Skill JSON schema
2. Implement `TSkill` and `TSkillEngine` classes
3. Create the 10 built-in skills with rules, templates, and examples (programmatic factory methods)
4. Implement skill selection algorithm with primary/secondary support
5. Test skill matching with various query types

**Deliverable:** Working skill selection that picks the right template for a request.

### Phase 3: Prompt Assembler + Integration
**Effort: 1 week**

1. Implement `TPromptAssembler` with all assembly methods (standard, refinement, error-fix, help)
2. Implement `TIntelligenceEngine` as the main orchestrator
3. Create Plan9Basic binding functions in `P9EngineLib.pas` (22 functions)
4. Write the language rules and identity prompt sections
5. Integration test: natural language → prompt → AILib → code

**Deliverable:** Complete intelligence pipeline: query → prompt → AILib → code.

### Phase 4: Tool Executor + Auto-Fix
**Effort: 1-2 weeks**

1. Implement `TToolExecutor` with registration, dispatch, and multi-provider JSON generation
2. Implement compile callback pattern with `TCompileCallback`
3. Implement progress callback with `TProgressCallback`
4. Register IDE tools in `UnitMain.pas` (compile_check, run_program, load_editor, etc.)
5. Implement `GenerateWithTools` with iterative tool-use loop (max 5 iterations)
6. Implement auto-fix loop in `GenerateAndValidate`
7. Add `ShouldUseTools` heuristic for automatic tool-use detection

**Deliverable:** Full tool-use support, auto-fix loop, IDE integration.

### Phase 5: Editor Integration (Layer 3 prep)
**Effort: 1 week**

1. Add "AI Assistant" panel to Plan9Basic IDE
2. Create prompt panel (docked TMemo + send button)
3. Wire prompt panel to Intelligence Engine
4. Display generated code in editor with syntax highlighting
5. Support follow-up refinements in conversational mode
6. Add status indicators (generating, compiling, fixing...)
7. Wire progress callback for real-time feedback

**Deliverable:** Working prompt terminal in the IDE.

---

## Appendix A: Intent Classification Keywords

```
GUI Intent:        form, window, button, gui, app, applet, interface, screen,
                   dialog, visual, click, menu, toolbar, panel, label, edit,
                   checkbox, combobox, listbox, image, widget

Console Intent:    console, text, print, input, command, cli, terminal,
                   output, prompt, stdin, stdout

Data Intent:       file, json, csv, xml, read, write, parse, data, load, save,
                   import, export, config, ini

Network Intent:    http, api, request, web, fetch, download, url, post, get,
                   rest, endpoint, server, client

Database Intent:   database, sqlite, query, table, sql, crud, record, field,
                   select, insert, update, delete, schema

Animation Intent:  animate, move, fade, rotate, transition, effect, tween,
                   interpolate, keyframe, timeline

Game Intent:       game, score, player, move, collision, sprite, level, enemy,
                   health, lives, timer, random

System Intent:     os, platform, environment, system, process, execute, shell,
                   directory, path, date, time, clipboard
```

## Appendix B: Critical Language Rules Document

This document is ALWAYS included in the system prompt (≈400 tokens):

```markdown
# Plan9Basic Critical Syntax Rules

## Variable Types
- Numbers: no suffix (let x = 42)
- Strings: $ suffix (let name$ = "hello")
- Pointers: # suffix (let obj# = Pointer#(0))

## Pointer Initialization — MANDATORY
Every pointer variable MUST be initialized before use:
  let frm# = Pointer#(0)
  let btn# = Pointer#(0)
Failure to initialize causes runtime errors.

## Local Variables
Declared on the SAME line as the function header:
  function calculate(x, y) local result, temp$
NOT on a separate line. NOT with DIM or LET.

## Boolean Values
Plan9Basic has NO boolean type. Use 1 for true, 0 for false.
Boolean expressions are ONLY valid inside IF and WHILE conditions.
NEVER pass a boolean expression as a function parameter.
WRONG: button_visible#(btn#, x > 0)
RIGHT: if x > 0 then : button_visible#(btn#, 1) : end if

## Event Callbacks
- Callback function names stored LOWERCASE in the engine
- Always use lowercase function names: function onclick(sender#)
- First parameter is always sender# (the control that fired the event)

## form_show Behavior
form_show(frm#) enters the FireMonkey event loop. It must be the
LAST statement in the main code. All function definitions and
variable initialization go BEFORE the form_show call.
Do NOT free objects after form_show — use the OnClose event handler
for cleanup, or let the garbage collector handle it.

## String Concatenation
Use + operator: let full$ = first$ + " " + last$

## Comments
Start with ' (apostrophe) or REM keyword.
```

## Appendix C: Change Log (v1.0 → v2.0)

| Section | Change | Impact |
|---------|--------|--------|
| Part 3 | **Replaced MCP Server with Tool Executor** — TMCPServer, JSON-RPC, stdio, and MCP resources removed. TToolExecutor with callback registration pattern implemented instead. | Architecture |
| Part 3 | Tool names changed: `compile_code`→`compile_check`, `run_code`→`run_program`, `set_editor_content`→`load_editor`, `get_editor_content`→`get_editor_code`. Removed: `list_functions`, `get_documentation`, `edit_lines`. Added: `get_console_output`, `list_files`, `read_file`. | API |
| Part 5 | Auto-fix loop uses `TCompileCallback` instead of MCP `InvokeTool` calls | Architecture |
| Part 6.1 | `TIntelligenceEngine.Create` takes `(RAG, Skills)` objects instead of path strings | API |
| Part 6.1 | `FAIClient` typed as `TAIClient` instead of `Pointer` | API |
| Part 6.1 | `Generate` returns `TGenerationResult` record instead of `String` | API |
| Part 6.1 | Added: `TGenerationResult`, `TCompileCallback`, `TProgressCallback` types | API |
| Part 6.1 | Added methods: `GenerateWithSkill`, `GenerateWithTools`, `AskQuestion`, `ClearConversation`, `GetSummary` | API |
| Part 6.1 | Added properties: `ToolExecutor`, `ToolsEnabled`, `OnCompile`, `OnProgress`, `LastResult` | API |
| Part 6.1 | Removed: `SetMCPServer` method (no MCP server exists) | API |
| Part 6.3 | Binding functions expanded from 12 to 22 (including p9_engine# auto-resolve overload) | API |
| §1.4 | Scoring formula updated: `function_match` weight 4.0→5.0, added `keyword_in_id × 3.0`, `library_hint × 10.0`, `language_boost × 0.5..1.0` | Algorithm |
| §1.5 | `TRAGDocument`: added `Subcategory`, `Summary`, `ContentLoaded` fields | Data |
| §1.5 | `TRAGResult`: added `ContentForPrompt`, `TokensUsed`, `MatchReasons` fields | Data |
| §1.5 | `TRAGQueryAnalysis`: added `IntentScore`, `IsFollowUp`, `LibraryHints` fields | Data |
| §1.5 | `TRAGEngine`: added `Analyze`, `GetDocument`, `DocumentCount`, `FunctionCount`, `ListDocumentIds`, `ListTags`, `ListCategories`, `GetIndexSummary`, `SaveIndex`; `BuildIndex`/`LoadIndex` distinction | API |
| §2.6 | `TSkillEngine`: added `SelectSkillDetailed`, `ListSkillIds`, `SkillCount`, `GetSummary` | API |
| §2.6 | `TSkill`: added `BuildFullPromptSection`, `BuildRulesText`, `BuildExamplesText`, `ToJSON`, `LoadFromJSON` | API |
| §2.6 | Added `TSkillSelection` record type | Data |
| §4.4 | `TPromptAssembler`: added `AssembleWithSkill`, `AssembleRefinement`, `AssembleErrorFix`, `AssembleHelpQuery`, `GetLanguageRules`, `GetIdentityPrompt`, `ResponseBudgetRatio` | API |
| §4.5 | `TAssembledPrompt`: expanded from 5 to 11 fields | Data |
| App B | **Fixed `form_show` description** — removed incorrect "BLOCKING" claim. Updated to describe actual behavior. | Correctness |
| Part 7 | Roadmap Phase 4 updated from "MCP Server" to "Tool Executor + Auto-Fix" | Documentation |
