# SkillLib - Skills System Library

## Overview

SkillLib provides functions to manage and query skill templates for AI-assisted code generation. A skill is a structured prompt template that teaches an AI model how to generate a specific type of Plan9Basic program — such as a GUI applet, a console tool, an HTTP client, or a data processor. SkillLib handles skill selection, retrieval of prompt sections (system prompt, rules, code templates, examples), and engine management.

**Version:** 1.0  
**Function Count:** 13 functions

## Key Features

- **Automatic Skill Selection** - Match a natural language query to the best skill template
- **Detailed Selection** - Get scoring details and matched triggers as JSON
- **Prompt Section Access** - Retrieve individual parts of a skill (system, rules, template, examples) or the full combined prompt
- **Built-In Skills** - 10 default skill templates that work without any files on disk
- **Custom Skills** - Load additional skills from JSON files in a skills directory
- **Hot Reload** - Reload skills from disk without recreating the engine
- **Automatic Memory Management** - Skill engines are tracked by the garbage collector

## How Skills Work

Each skill contains structured prompt sections designed to guide an AI model:

| Section | Purpose | Example Content |
|---------|---------|-----------------|
| **System Prompt** | Sets the AI's role and overall behavior | "You are a Plan9Basic GUI expert..." |
| **Rules** | Coding rules and constraints the AI must follow | "Always use `let` for variables, use `form_show` last..." |
| **Code Template** | A skeleton code structure for the AI to fill in | Form creation boilerplate, event handler stubs |
| **Examples** | Complete working examples the AI can learn from | A full calculator applet, a file browser |

When the Intelligence Engine (P9EngineLib) generates code, it selects the best skill for the user's query, assembles these sections into a prompt, combines them with RAG documentation, and sends everything to the AI.

You can also use SkillLib directly to build custom prompts, inspect skill contents, or select skills without the full Intelligence Engine pipeline.

## Built-In Skills

The engine includes these default skills (available even with an empty skills directory):

| Skill ID | Description | Triggers |
|----------|-------------|----------|
| `gui_applet` | GUI applications with forms, buttons, labels | form, button, window, GUI, interface |
| `console_tool` | Console-based utilities and text programs | console, print, text, command-line |
| `data_processor` | Data manipulation, file processing, conversion | data, file, convert, parse, CSV, JSON |
| `http_client` | HTTP requests, REST APIs, web communication | HTTP, API, REST, web, download, fetch |
| `game_simple` | Simple games with timers and interaction | game, play, score, timer, animation |
| `database_app` | SQLite database applications | database, SQL, SQLite, table, query |
| `chart_visual` | Data visualization with shapes and graphics | chart, graph, draw, visual, plot |
| `media_player` | Audio/video playback applications | media, audio, video, play, sound, music |
| `network_tool` | Network utilities and diagnostics | network, socket, ping, IP, port |
| `config_editor` | Configuration file editors and managers | config, settings, INI, preferences |

## Function Naming Convention

| Suffix | Returns | Example |
|--------|---------|---------|
| `#` | Pointer (skill engine) | `skill_engine#()`, `skill_reload#()` |
| `$` | String | `skill_select$()`, `skill_get_system$()` |
| (none) | Number | `skill_count()` |

## Memory Management

Skill engines created with `skill_engine#()` are automatically tracked by Plan9Basic's garbage collector. They will be cleaned up when the program ends or resets. You can also free them explicitly with `skill_engine_free()`.

---

## Function Reference

### Engine Lifecycle

#### skill_engine#()

Creates a skill engine and loads skills from the given directory. Built-in skills are always available even if the directory is empty or does not exist.

**Signature:** `skill_engine#@$`

**Syntax:**
```basic
eng# = skill_engine#(path$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `path$` | String | Path to the skills directory (e.g., `"skills/"`), or `""` for built-in skills only |

**Returns:** Pointer to the skill engine

**Example:**
```basic
let eng# = skill_engine#("skills/")
println "Skills loaded: " + str$(skill_count(eng#))
println "Available: " + skill_list$(eng#)
```

---

#### skill_engine_free()

Frees a skill engine and releases its resources.

**Signature:** `skill_engine_free@#`

**Syntax:**
```basic
skill_engine_free(eng#)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Skill engine handle |

**Returns:** 1 on success

---

#### skill_reload#()

Reloads all skills from disk. Useful if skill files have been modified since the engine was created. Built-in skills are always re-loaded.

**Signature:** `skill_reload#@#`

**Syntax:**
```basic
skill_reload#(eng#)
```

**Returns:** The skill engine pointer

**Example:**
```basic
skill_reload#(eng#)
println "Reloaded: " + str$(skill_count(eng#)) + " skills"
```

---

### Skill Selection

#### skill_select$()

Selects the best skill for a given natural language query. The engine analyzes the query text and matches it against skill triggers and descriptions.

**Signature:** `skill_select$@#$`

**Syntax:**
```basic
skillId$ = skill_select$(eng#, query$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Skill engine handle |
| `query$` | String | Natural language description (e.g., `"calculator with buttons"`) |

**Returns:** Skill ID string (e.g., `"gui_applet"`), or empty string if no skill matches

**Example:**
```basic
let id$ = skill_select$(eng#, "Create a form with two text fields and a Submit button")
println "Selected skill: " + id$
' Output: Selected skill: gui_applet

let id$ = skill_select$(eng#, "Download JSON data from a REST API")
println "Selected skill: " + id$
' Output: Selected skill: http_client
```

---

#### skill_select_json$()

Selects the best skill with full scoring details. Returns a JSON object with the primary and secondary skill matches, their scores, and which trigger words matched.

**Signature:** `skill_select_json$@#$`

**Syntax:**
```basic
json$ = skill_select_json$(eng#, query$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Skill engine handle |
| `query$` | String | Natural language description |

**Returns:** JSON object with fields: `primary_id`, `primary_score`, `secondary_id`, `secondary_score`, `matched_triggers`

**Example:**
```basic
let json$ = skill_select_json$(eng#, "Create a game with a timer and score display")
println json$
' Output: {"primary_id":"game_simple","primary_score":8.5,
'          "secondary_id":"gui_applet","secondary_score":3.0,
'          "matched_triggers":["game","timer","score"]}
```

---

#### skill_get_system$()

Gets the system prompt section of a skill by its ID. The system prompt sets the AI's role and general behavior.

**Signature:** `skill_get_system$@#$`

**Syntax:**
```basic
system$ = skill_get_system$(eng#, skillId$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | Skill engine handle |
| `skillId$` | String | Skill identifier (e.g., `"gui_applet"`) |

**Returns:** System prompt text, or empty string if skill not found

---

#### skill_get_rules$()

Gets the coding rules section of a skill. Rules define constraints the AI must follow when generating code.

**Signature:** `skill_get_rules$@#$`

**Syntax:**
```basic
rules$ = skill_get_rules$(eng#, skillId$)
```

---

#### skill_get_template$()

Gets the code template section of a skill. The template is a skeleton code structure the AI uses as a starting point.

**Signature:** `skill_get_template$@#$`

**Syntax:**
```basic
template$ = skill_get_template$(eng#, skillId$)
```

---

#### skill_get_examples$()

Gets the examples section of a skill. Examples are complete, working programs that demonstrate the expected output style.

**Signature:** `skill_get_examples$@#$`

**Syntax:**
```basic
examples$ = skill_get_examples$(eng#, skillId$)
```

---

#### skill_get_full$()

Gets the complete prompt section of a skill — all sections (system, rules, template, examples) combined into a single formatted string. This is the most convenient way to get the full skill content.

**Signature:** `skill_get_full$@#$`

**Syntax:**
```basic
full$ = skill_get_full$(eng#, skillId$)
```

**Returns:** Complete skill prompt text

**Example:**
```basic
' Get the complete skill prompt in one call
let full$ = skill_get_full$(eng#, "gui_applet")
println full$
```

---

### Information

#### skill_count()

Returns the number of available skills.

**Signature:** `skill_count@#`

**Syntax:**
```basic
count = skill_count(eng#)
```

---

#### skill_list$()

Returns a comma-separated list of all skill IDs.

**Signature:** `skill_list$@#`

**Syntax:**
```basic
ids$ = skill_list$(eng#)
```

**Returns:** Comma-separated string (e.g., `"gui_applet, console_tool, data_processor, ..."`)

---

#### skill_summary$()

Returns a human-readable summary of all available skills, including their IDs and descriptions.

**Signature:** `skill_summary$@#`

**Syntax:**
```basic
summary$ = skill_summary$(eng#)
```

**Example:**
```basic
let eng# = skill_engine#("skills/")
println skill_summary$(eng#)
```

---

## Complete Examples

### Example 1: Exploring Available Skills

```basic
' List all skills and their prompt sizes
println "=== Skill Explorer ==="
println ""

let eng# = skill_engine#("skills/")
println "Total skills: " + str$(skill_count(eng#))
println ""

' Get the list and iterate
let ids$ = skill_list$(eng#)
let pos = 0

while pos < len(ids$)
    let endPos = instr(ids$, ",", pos)
    if endPos = -1 then
        endPos = len(ids$)
    endif
    
    let id$ = trim$(mid$(ids$, pos, endPos - pos))
    
    if id$ <> "" then
        let full$ = skill_get_full$(eng#, id$)
        println id$ + " (" + str$(len(full$)) + " chars)"
    endif
    
    pos = endPos + 1
wend

skill_engine_free(eng#)
```

### Example 2: Skill Selection Demo

```basic
' Test skill selection with different queries
println "=== Skill Selection Demo ==="
println ""

let eng# = skill_engine#("skills/")

' Test queries
let queries$ = "make a calculator GUI,download weather data from API,create a number guessing game,read and parse a CSV file,play background music,query a SQLite database"
let pos = 0

while pos < len(queries$)
    let endPos = instr(queries$, ",", pos)
    if endPos = -1 then
        endPos = len(queries$)
    endif
    
    let q$ = mid$(queries$, pos, endPos - pos)
    let id$ = skill_select$(eng#, q$)
    println q$
    println "  → " + id$
    println ""
    
    pos = endPos + 1
wend

skill_engine_free(eng#)
```

### Example 3: Building a Custom Prompt

```basic
' Use SkillLib + RAGLib + AILib to build a custom prompt
println "=== Custom Prompt Assembly ==="
println ""

let key$ = "sk-ant-xxxxx"
let ai# = ai_client#("anthropic", key$)
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 2048)

let skills# = skill_engine#("skills/")
let rag# = rag#("knowledge/")

' User's request
let query$ = "Create a form with a text field and a button that converts Celsius to Fahrenheit"

' Step 1: Select the best skill
let skillId$ = skill_select$(skills#, query$)
println "Selected skill: " + skillId$

' Step 2: Get skill prompt sections
let system$ = skill_get_system$(skills#, skillId$)
let rules$ = skill_get_rules$(skills#, skillId$)
let template$ = skill_get_template$(skills#, skillId$)

' Step 3: Get relevant documentation from RAG
let docs$ = rag_retrieve_budget$(rag#, query$, 2000)

' Step 4: Assemble the full prompt
let fullSystem$ = system$ + chr$(10)
fullSystem$ = fullSystem$ + "=== Rules ===" + chr$(10) + rules$ + chr$(10)
fullSystem$ = fullSystem$ + "=== Template ===" + chr$(10) + template$ + chr$(10)
fullSystem$ = fullSystem$ + "=== Documentation ===" + chr$(10) + docs$

' Step 5: Generate code
let code$ = ai_completesystem$(ai#, fullSystem$, query$)

if ai_ok(ai#) = 1 then
    println ""
    println code$
else
    println "Error: " + ai_errormsg$()
endif

rag_free(rag#)
skill_engine_free(skills#)
ai_free(ai#)
```

### Example 4: Detailed Selection with JSON

```basic
' Get detailed scoring for skill selection
println "=== Detailed Selection ==="
println ""

let eng# = skill_engine#("skills/")

let query$ = "Create a dashboard that fetches data from an API and displays charts"
println "Query: " + query$
println ""

let json$ = skill_select_json$(eng#, query$)
let sel# = json_parse#(json$)

println "Primary: " + json_gets$(sel#, "primary_id") + " (score: " + str$(json_getn(sel#, "primary_score")) + ")"
println "Secondary: " + json_gets$(sel#, "secondary_id") + " (score: " + str$(json_getn(sel#, "secondary_score")) + ")"

let triggers# = json_get#(sel#, "matched_triggers")
let tStr$ = ""
for i = 0 to json_len(triggers#) - 1
    if i > 0 then tStr$ = tStr$ + ", "
    tStr$ = tStr$ + json_items$(triggers#, i)
next
println "Matched triggers: " + tStr$

skill_engine_free(eng#)
```

---

## Quick Reference

### Engine Lifecycle
```basic
skill_engine#(path$)                 ' Create skill engine
skill_engine_free(eng#)              ' Free engine
skill_reload#(eng#)                  ' Reload from disk
```

### Skill Selection
```basic
skill_select$(eng#, query$)          ' Select best skill ID
skill_select_json$(eng#, query$)     ' Select with scoring details
skill_get_system$(eng#, id$)         ' Get system prompt section
skill_get_rules$(eng#, id$)          ' Get rules section
skill_get_template$(eng#, id$)       ' Get code template section
skill_get_examples$(eng#, id$)       ' Get examples section
skill_get_full$(eng#, id$)           ' Get all sections combined
```

### Information
```basic
skill_count(eng#)                    ' Number of skills
skill_list$(eng#)                    ' List all skill IDs
skill_summary$(eng#)                 ' Summary of all skills
```

---

### All Registered Functions (Alphabetical)

| Function | Signature | Description |
|----------|-----------|-------------|
| `skill_count` | `skill_count@#` | Number of available skills |
| `skill_engine#` | `skill_engine#@$` | Create skill engine |
| `skill_engine_free` | `skill_engine_free@#` | Free skill engine |
| `skill_get_examples$` | `skill_get_examples$@#$` | Get examples section |
| `skill_get_full$` | `skill_get_full$@#$` | Get all sections combined |
| `skill_get_rules$` | `skill_get_rules$@#$` | Get rules section |
| `skill_get_system$` | `skill_get_system$@#$` | Get system prompt section |
| `skill_get_template$` | `skill_get_template$@#$` | Get code template section |
| `skill_list$` | `skill_list$@#` | List all skill IDs |
| `skill_reload#` | `skill_reload#@#` | Reload skills from disk |
| `skill_select$` | `skill_select$@#$` | Select best skill for query |
| `skill_select_json$` | `skill_select_json$@#$` | Select with scoring details |
| `skill_summary$` | `skill_summary$@#` | Summary of all skills |

---

## Notes and Best Practices

### Custom Skills

To add custom skills, create JSON files in the skills directory. Each file defines a skill with its ID, description, triggers, and prompt sections. The engine loads all `.json` files from the directory at creation time and when `skill_reload#()` is called.

### Skill Selection Tips

The selection algorithm matches query words against skill trigger words and descriptions. For best results, describe what you want to build rather than how: "calculator with buttons" matches `gui_applet`, while "download stock prices" matches `http_client`.

### Using SkillLib Without P9EngineLib

SkillLib can be used independently from the full Intelligence Engine. This is useful when you want to build custom AI prompts with fine-grained control over what goes into each section, or when you want to inspect and debug skill matching behavior.

### Using SkillLib With P9EngineLib

The Intelligence Engine (P9EngineLib) uses SkillLib internally. When you call `p9_generate$()`, the engine automatically selects a skill, retrieves its prompt sections, combines them with RAG documentation, and sends the assembled prompt to the AI. You only need SkillLib directly if you want custom prompt assembly or skill inspection.

---

## See Also

- **P9EngineLib** - High-level engine that uses skills automatically
- **RAGLib** - Knowledge retrieval that complements skill prompts
- **AILib** - AI client for sending assembled prompts
- **JsonLib** - Parse JSON from `skill_select_json$`

---

*End of SkillLib Documentation*
