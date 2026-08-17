# RAGLib - Knowledge Retrieval Library

## Overview

RAGLib provides functions to query and manage a local knowledge base from Plan9Basic programs. RAG stands for Retrieval-Augmented Generation — a technique where relevant documentation is retrieved from a knowledge base and injected into AI prompts so the AI can give accurate, context-aware answers. RAGLib handles indexing, searching, scoring, and formatting so your programs can find the right documentation for any query.

**Version:** 1.0  
**Function Count:** 13 functions

## Key Features

- **Knowledge Base Search** - Find relevant documents by natural language query
- **Function Lookup** - Search for documents by function names
- **Tag-Based Search** - Find documents by category tags
- **Query Analysis** - Break down a query into intent, keywords, and library hints
- **Token Budget Control** - Retrieve documents within a token limit for prompt assembly
- **JSON Output** - Get search results as structured JSON with scores
- **Automatic Indexing** - Build and rebuild the search index from source documents
- **Automatic Memory Management** - RAG engines are tracked by the garbage collector

## How the Knowledge Base Works

The RAG engine reads markdown documents from a directory tree (typically `knowledge/`) and builds a search index. Each document can contain function signatures, tags, categories, and free-text content. When you search, the engine scores documents by keyword matching, function name overlap, and tag relevance, then returns the best matches formatted for prompt injection.

A typical knowledge base directory looks like:

```
knowledge/
├── libraries/
│   ├── FormLib.md
│   ├── JsonLib.md
│   ├── ArrayLib.md
│   └── ...
├── language/
│   ├── syntax.md
│   ├── variables.md
│   └── ...
├── patterns/
│   ├── gui-pattern.md
│   └── ...
└── examples/
    ├── calculator.md
    └── ...
```

## Function Naming Convention

| Suffix | Returns | Example |
|--------|---------|---------|
| `#` | Pointer (RAG engine or rebuilt engine) | `rag#()`, `rag_rebuild#()` |
| `$` | String | `rag_retrieve$()`, `rag_summary$()` |
| (none) | Number | `rag_count()`, `rag_funccount()` |

## Memory Management

RAG engines created with `rag#()` are automatically tracked by Plan9Basic's garbage collector. They will be cleaned up when the program ends or resets. You can also free them explicitly with `rag_free()`.

---

## Function Reference

### Engine Lifecycle

#### rag#()

Creates a RAG engine and loads the search index from the given knowledge base path.

**Signature:** `rag#@$`

**Syntax:**
```basic
eng# = rag#(path$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `path$` | String | Path to the knowledge base directory (e.g., `"knowledge/"`) |

**Returns:** Pointer to the RAG engine

If the index has been built previously, it is loaded from a JSON file on disk. If no index exists yet, the engine starts empty — call `rag_rebuild#()` to build it.

**Example:**
```basic
let eng# = rag#("knowledge/")
println "Documents: " + str$(rag_count(eng#))
println "Functions: " + str$(rag_funccount(eng#))
```

---

#### rag_free()

Frees a RAG engine and releases its resources.

**Signature:** `rag_free@#`

**Syntax:**
```basic
rag_free(eng#)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | RAG engine handle |

**Returns:** 1 on success

---

#### rag_rebuild#()

Rebuilds the search index by scanning all documents in the knowledge base directory. The rebuilt index is saved to disk as JSON for fast loading on subsequent runs.

**Signature:** `rag_rebuild#@#`

**Syntax:**
```basic
rag_rebuild#(eng#)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | RAG engine handle |

**Returns:** The RAG engine pointer

**Example:**
```basic
let eng# = rag#("knowledge/")
rag_rebuild#(eng#)
println "Index rebuilt: " + str$(rag_count(eng#)) + " documents, " + str$(rag_funccount(eng#)) + " functions"
```

---

### Core Retrieval

#### rag_retrieve$()

Searches the knowledge base and returns the best matching documents as formatted text, ready for injection into an AI prompt.

**Signature:** `rag_retrieve$@#$`

**Syntax:**
```basic
docs$ = rag_retrieve$(eng#, query$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | RAG engine handle |
| `query$` | String | Natural language query (e.g., `"create a form with buttons"`) |

**Returns:** String with formatted document content, sections separated by blank lines, each prefixed with `### Title`

**Example:**
```basic
let eng# = rag#("knowledge/")
let docs$ = rag_retrieve$(eng#, "how to read a JSON file")
println docs$
```

---

#### rag_retrieve_json$()

Searches the knowledge base and returns results as a JSON array with scores, categories, token counts, and match reasons.

**Signature:** `rag_retrieve_json$@#$`

**Syntax:**
```basic
json$ = rag_retrieve_json$(eng#, query$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | RAG engine handle |
| `query$` | String | Natural language query |

**Returns:** JSON array string. Each element has: `id`, `title`, `category`, `score`, `tokens`, `truncated`, `reasons`, `content`

**Example:**
```basic
let eng# = rag#("knowledge/")
let json$ = rag_retrieve_json$(eng#, "timer events")
println json$

' Parse with JsonLib for structured access
let results# = json_parse#(json$)
println "Found " + str$(json_len(results#)) + " documents"

for i = 0 to json_len(results#) - 1
    let doc# = json_item#(results#, i)
    println json_gets$(doc#, "title") + " (score: " + str$(json_getn(doc#, "score")) + ")"
next
```

---

#### rag_retrieve_budget$()

Searches the knowledge base with a custom token budget. The engine stops including documents once the budget is exhausted, so the result fits within a prompt token limit.

**Signature:** `rag_retrieve_budget$@#$n`

**Syntax:**
```basic
docs$ = rag_retrieve_budget$(eng#, query$, maxTokens)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | RAG engine handle |
| `query$` | String | Natural language query |
| `maxTokens` | Number | Maximum tokens to include in the result |

**Returns:** Formatted document text within the token budget

**Example:**
```basic
' Retrieve docs that fit in 2000 tokens
let docs$ = rag_retrieve_budget$(eng#, "GUI controls and events", 2000)

' Use in a prompt
let system$ = "You are a Plan9Basic expert." + chr$(10) + docs$
let code$ = ai_completesystem$(ai#, system$, "Create a calculator with buttons")
```

---

### Direct Lookup

#### rag_doc$()

Gets the full content of a specific document by its ID.

**Signature:** `rag_doc$@#$`

**Syntax:**
```basic
content$ = rag_doc$(eng#, docId$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | RAG engine handle |
| `docId$` | String | Document identifier |

**Returns:** The full document content, or an error message if not found

**Example:**
```basic
let content$ = rag_doc$(eng#, "FormLib")
println content$
```

---

#### rag_functions$()

Finds documents that contain specific function names. Pass a comma-separated or space-separated list of function names.

**Signature:** `rag_functions$@#$`

**Syntax:**
```basic
docs$ = rag_functions$(eng#, functionNames$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | RAG engine handle |
| `functionNames$` | String | Comma or space-separated function names |

**Returns:** Formatted content from matching documents

**Example:**
```basic
' Find docs for specific functions
let docs$ = rag_functions$(eng#, "json_parse#, json_stringify$, json_gets$")
println docs$

' Also works with spaces
let docs$ = rag_functions$(eng#, "form_create# button_create# label_create#")
println docs$
```

---

#### rag_tags$()

Finds documents that match specific tags. Pass a comma-separated list of tags.

**Signature:** `rag_tags$@#$`

**Syntax:**
```basic
docs$ = rag_tags$(eng#, tags$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | RAG engine handle |
| `tags$` | String | Comma-separated tag names |

**Returns:** Formatted content from matching documents, with scores

**Example:**
```basic
let docs$ = rag_tags$(eng#, "gui,forms,events")
println docs$
```

---

### Query Analysis

#### rag_analyze$()

Analyzes a query and returns its intent, keywords, detected function names, and library hints as a JSON object. This is useful for understanding how the RAG engine interprets queries, or for building custom retrieval logic.

**Signature:** `rag_analyze$@#$`

**Syntax:**
```basic
analysis$ = rag_analyze$(eng#, query$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `eng#` | Pointer | RAG engine handle |
| `query$` | String | Natural language query to analyze |

**Returns:** JSON object with fields: `query`, `intent`, `is_followup`, `keywords`, `function_names`, `library_hints`

**Example:**
```basic
let analysis$ = rag_analyze$(eng#, "How do I create a form with buttons and handle click events?")
println analysis$

' Example output:
' {"query":"How do I create a form with buttons and handle click events?",
'  "intent":"gui_creation",
'  "is_followup":false,
'  "keywords":["form","buttons","click","events"],
'  "function_names":["form_create#","button_create#"],
'  "library_hints":["FormLib","ButtonLib"]}
```

---

### Information

#### rag_count()

Returns the number of documents in the search index.

**Signature:** `rag_count@#`

**Syntax:**
```basic
count = rag_count(eng#)
```

**Returns:** Number of indexed documents

---

#### rag_funccount()

Returns the number of function signatures indexed across all documents.

**Signature:** `rag_funccount@#`

**Syntax:**
```basic
count = rag_funccount(eng#)
```

**Returns:** Number of indexed functions

---

#### rag_summary$()

Returns a human-readable summary of the index state: document count, function count, categories, and other statistics.

**Signature:** `rag_summary$@#`

**Syntax:**
```basic
summary$ = rag_summary$(eng#)
```

**Returns:** Summary string

**Example:**
```basic
let eng# = rag#("knowledge/")
println rag_summary$(eng#)
```

---

## Complete Examples

### Example 1: Exploring the Knowledge Base

```basic
' Browse and inspect the knowledge base
println "=== Knowledge Base Explorer ==="
println ""

let eng# = rag#("knowledge/")
println rag_summary$(eng#)
println ""

' Search for GUI-related docs
println "--- GUI Documentation ---"
let docs$ = rag_retrieve$(eng#, "create a graphical user interface")
println docs$
println ""

' Search for specific functions
println "--- JSON Functions ---"
let docs$ = rag_functions$(eng#, "json_parse#,json_stringify$")
println docs$

rag_free(eng#)
```

### Example 2: AI-Assisted Code Generation

```basic
' Use RAG to give the AI context about Plan9Basic
println "=== RAG + AI Code Generation ==="
println ""

let key$ = "sk-ant-xxxxx"
let ai# = ai_client#("anthropic", key$)
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 2048)

let eng# = rag#("knowledge/")

' Retrieve relevant docs for the query
let query$ = "Create a temperature converter with Celsius and Fahrenheit"
let docs$ = rag_retrieve_budget$(eng#, query$, 3000)

' Build a system prompt with documentation context
let system$ = "You are a Plan9Basic code generator." + chr$(10)
system$ = system$ + "Use ONLY the functions documented below." + chr$(10)
system$ = system$ + "Return only code with comments, no explanation." + chr$(10)
system$ = system$ + chr$(10)
system$ = system$ + docs$

' Generate code
let code$ = ai_completesystem$(ai#, system$, query$)

if ai_ok(ai#) = 1 then
    println code$
else
    println "Error: " + ai_errormsg$()
endif

rag_free(eng#)
ai_free(ai#)
```

### Example 3: Query Analysis

```basic
' Analyze how the RAG engine interprets different queries
println "=== Query Analysis Demo ==="
println ""

let eng# = rag#("knowledge/")

let queries$ = "create a form with buttons,read a JSON file,play a sound,draw a circle,connect to a REST API"
let pos = 0

while pos < len(queries$)
    let endPos = instr(queries$, ",", pos)
    if endPos = -1 then
        endPos = len(queries$)
    endif
    
    let q$ = mid$(queries$, pos, endPos - pos)
    
    println "Query: " + q$
    let analysis$ = rag_analyze$(eng#, q$)
    
    ' Parse the JSON result
    let a# = json_parse#(analysis$)
    println "  Intent: " + json_gets$(a#, "intent")
    
    let kw# = json_get#(a#, "keywords")
    let kwStr$ = ""
    for i = 0 to json_len(kw#) - 1
        if i > 0 then kwStr$ = kwStr$ + ", "
        kwStr$ = kwStr$ + json_items$(kw#, i)
    next
    println "  Keywords: " + kwStr$
    
    let hints# = json_get#(a#, "library_hints")
    let hStr$ = ""
    for i = 0 to json_len(hints#) - 1
        if i > 0 then hStr$ = hStr$ + ", "
        hStr$ = hStr$ + json_items$(hints#, i)
    next
    println "  Libraries: " + hStr$
    println ""
    
    pos = endPos + 1
wend

rag_free(eng#)
```

---

## Quick Reference

### Engine Lifecycle
```basic
rag#(path$)                          ' Create RAG engine
rag_free(eng#)                       ' Free engine
rag_rebuild#(eng#)                   ' Rebuild index from documents
```

### Core Retrieval
```basic
rag_retrieve$(eng#, query$)          ' Search (formatted text)
rag_retrieve_json$(eng#, query$)     ' Search (JSON with scores)
rag_retrieve_budget$(eng#, q$, tok)  ' Search with token budget
```

### Direct Lookup
```basic
rag_doc$(eng#, id$)                  ' Get document by ID
rag_functions$(eng#, names$)         ' Find by function names
rag_tags$(eng#, tags$)               ' Find by tags
```

### Query Analysis
```basic
rag_analyze$(eng#, query$)           ' Analyze query intent (JSON)
```

### Information
```basic
rag_count(eng#)                      ' Document count
rag_funccount(eng#)                  ' Function count
rag_summary$(eng#)                   ' Index summary
```

---

### All Registered Functions (Alphabetical)

| Function | Signature | Description |
|----------|-----------|-------------|
| `rag#` | `rag#@$` | Create RAG engine |
| `rag_analyze$` | `rag_analyze$@#$` | Analyze query intent |
| `rag_count` | `rag_count@#` | Document count |
| `rag_doc$` | `rag_doc$@#$` | Get document by ID |
| `rag_free` | `rag_free@#` | Free RAG engine |
| `rag_funccount` | `rag_funccount@#` | Function count |
| `rag_functions$` | `rag_functions$@#$` | Find docs by function names |
| `rag_rebuild#` | `rag_rebuild#@#` | Rebuild search index |
| `rag_retrieve$` | `rag_retrieve$@#$` | Search knowledge base (text) |
| `rag_retrieve_budget$` | `rag_retrieve_budget$@#$n` | Search with token budget |
| `rag_retrieve_json$` | `rag_retrieve_json$@#$` | Search knowledge base (JSON) |
| `rag_summary$` | `rag_summary$@#` | Index summary |
| `rag_tags$` | `rag_tags$@#$` | Find docs by tags |

---

## Notes and Best Practices

### Building the Index

The RAG index must be built before searches will return results. Call `rag_rebuild#()` after adding or modifying documents in the `knowledge/` directory. The index is saved to disk as JSON, so you only need to rebuild when documents change.

### Token Budgets

When assembling prompts for AI calls, use `rag_retrieve_budget$()` to keep the documentation context within a token limit. This prevents the prompt from exceeding the model's context window. A budget of 2000-4000 tokens usually provides enough context for code generation tasks.

### Combining with AILib

The most common pattern is: search the knowledge base for relevant docs, prepend them to a system prompt, then call the AI:

```basic
let docs$ = rag_retrieve$(eng#, query$)
let system$ = "You are a Plan9Basic expert." + chr$(10) + docs$
let code$ = ai_completesystem$(ai#, system$, query$)
```

For a fully automated pipeline that handles this pattern plus skill selection, see **P9EngineLib**.

---

## See Also

- **P9EngineLib** - High-level AI engine that uses RAG automatically
- **SkillLib** - Skill templates that complement RAG context
- **AILib** - AI client for making API calls
- **JsonLib** - Parse JSON results from `rag_retrieve_json$` and `rag_analyze$`

---

*End of RAGLib Documentation*
