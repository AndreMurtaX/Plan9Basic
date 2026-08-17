# ToolExecutor — Internal Architecture Reference
## Version 1.0 | Plan9Basic AI Tool-Use System

## Overview

`ToolExecutor` is the **self-contained** tool registry and dispatcher that
enables LLMs to interact with the Plan9Basic editor environment. It has
**zero dependencies** on AILib, IntelligenceEngine, or UnitMain — it only
deals with tool definitions, execution dispatch, and provider-specific JSON
serialization.

## Design Principles

1. **Decoupled** — Knows nothing about HTTP, AI providers, or the editor
2. **Registry pattern** — Tools are registered with definitions + callbacks
3. **Provider-agnostic** — Serializes to Anthropic, OpenAI, and Google formats
4. **Safe execution** — Wraps callbacks in try/except, validates arguments

## Architecture

```
UnitMain.pas                    IntelligenceEngine.pas
(registers callbacks)           (owns TToolExecutor)
     │                               │
     ▼                               ▼
┌─────────────────────────────────────────┐
│           TToolExecutor                 │
│                                         │
│  FTools: Dictionary<name, TToolDef>     │
│  FCallbacks: Dictionary<name, callback> │
│  FToolOrder: List<name>                 │
│                                         │
│  RegisterTool(def, callback)            │
│  Execute(call) → TToolResult            │
│  BuildAnthropicTools → TJSONArray       │
│  BuildOpenAITools → TJSONArray          │
│  BuildGoogleTools → TJSONArray          │
└─────────────────────────────────────────┘
```

## Data Flow

### Registration (app startup)
```
FormCreate
  → P9EngineLib.OnEditorToolRegistration = RegisterEditorTools
  
p9_engine#() called from BASIC
  → OnEditorToolRegistration(Engine)
    → TfrmMain.RegisterEditorTools(Engine)
      → Engine.ToolExecutor.RegisterTool(def, callback) × 8
```

### Execution (during AI conversation)
```
IntelligenceEngine.GenerateWithTools
  → FAIClient.ChatWithTools(conv, msg, toolsJson)
    → AI responds with tool_use blocks
  → Parse TAIResponse.ToolCalls
  → For each tool call:
      → FToolExecutor.Execute(call) → TToolResult
        → Parses arguments JSON
        → Calls registered callback (TfrmMain method)
        → Returns result string
  → FAIClient.SendToolResults(conv, calls, results, toolsJson)
    → AI responds with next action or final text
  → Loop until no more tool calls (max 5 iterations)
```

## Types

### TToolParam
```pascal
TToolParam = record
  Name: String;         // "code", "filename"
  ParamType: String;    // JSON Schema: "string", "number", "boolean"
  Description: String;  // For the LLM
  Required: Boolean;
end;
```

### TToolDef
```pascal
TToolDef = record
  Name: String;                // "run_program"
  Description: String;         // For the LLM
  Params: TArray<TToolParam>;
end;
```

### TToolResult
```pascal
TToolResult = record
  Success: Boolean;    // Did the tool execute successfully?
  Output: String;      // Text returned to the AI
end;
```

### TToolCall
```pascal
TToolCall = record
  Id: String;          // Provider-assigned ID
  Name: String;        // "run_program"
  Arguments: String;   // '{"code": "println \"hello\""}'
end;
```

### TToolCallback
```pascal
TToolCallback = function(const Args: TJSONObject): TToolResult of object;
```

## Provider JSON Formats

### Anthropic
```json
[
  {
    "name": "run_program",
    "description": "Execute Plan9Basic code...",
    "input_schema": {
      "type": "object",
      "properties": { "code": {"type": "string", "description": "..."} },
      "required": ["code"]
    }
  }
]
```

### OpenAI (also used by Custom providers)
```json
[
  {
    "type": "function",
    "function": {
      "name": "run_program",
      "description": "Execute Plan9Basic code...",
      "parameters": {
        "type": "object",
        "properties": { "code": {"type": "string", "description": "..."} },
        "required": ["code"]
      }
    }
  }
]
```

### Google (Gemini)
```json
[
  {
    "functionDeclarations": [
      {
        "name": "run_program",
        "description": "Execute Plan9Basic code...",
        "parameters": {
          "type": "object",
          "properties": { "code": {"type": "string", "description": "..."} },
          "required": ["code"]
        }
      }
    ]
  }
]
```

## Configuration

| Property | Default | Description |
|----------|---------|-------------|
| `MaxIterations` | 5 | Maximum tool-use loop iterations per request |

## Adding New Tools

To add a new editor tool:

1. **Define the callback** in `TfrmMain`:
```pascal
function TfrmMain.ToolMyAction(const Args: TJSONObject): TToolResult;
begin
  Result.Success := True;
  Result.Output := 'Action completed';
end;
```

2. **Register it** in `RegisterEditorTools`:
```pascal
Exec.RegisterTool(
  MakeTool('my_action',
    'Description of what this tool does for the AI',
    [MakeParam('param1', 'string', 'Description', True)]),
  ToolMyAction);
```

3. **Declare** in the `private` section of `TfrmMain`:
```pascal
function ToolMyAction(const Args: TJSONObject): TToolResult;
```

That's it — the tool automatically appears in all provider formats.
