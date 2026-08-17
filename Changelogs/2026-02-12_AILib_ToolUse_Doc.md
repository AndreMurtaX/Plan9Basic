# AILib v1.1 — Tool-Use Extensions
## Additions to AILib for Provider-Agnostic Function Calling

### New Types

#### TAIToolCall
Represents a tool call requested by the AI in its response.

```pascal
TAIToolCall = record
  Id: String;           // Provider-assigned ID (for matching results)
  Name: String;         // Tool function name ("run_program")
  Arguments: String;    // JSON arguments string ('{"code":"..."}')
end;
```

#### TAIResponse
Extended response that carries both text content and tool calls.

```pascal
TAIResponse = record
  Text: String;                    // Text content (may be empty)
  ToolCalls: TArray<TAIToolCall>;  // Tool calls (empty if text-only)
  StopReason: String;              // "end_turn", "tool_use", "stop"
  HasToolCalls: Boolean;           // Convenience flag
  RawBody: String;                 // Full response for debugging
end;
```

### New Methods on TAIClient

#### ChatWithTools
Sends a user message with tool definitions. Returns a structured response
that may contain text, tool calls, or both.

```pascal
function ChatWithTools(
  Conv: TAIConversation;
  const UserMessage: String;
  Tools: TJSONArray): TAIResponse;
```

**Parameters:**
- `Conv` — Conversation for multi-turn context
- `UserMessage` — The user's message
- `Tools` — Provider-specific tool definitions (from TToolExecutor.Build*Tools)

**Returns:** `TAIResponse` with text and/or tool calls

**Usage:**
```pascal
var
  Response: TAIResponse;
  ToolsJson: TJSONArray;
begin
  ToolsJson := ToolExecutor.BuildAnthropicTools;
  try
    Response := AIClient.ChatWithTools(Conv, 'Create a hello world', ToolsJson);
    
    if Response.HasToolCalls then
      // Process tool calls...
    else
      // Use Response.Text directly
  finally
    ToolsJson.Free;
  end;
end;
```

#### SendToolResults
Sends tool execution results back to the AI and gets the next response.

```pascal
function SendToolResults(
  Conv: TAIConversation;
  const ToolCalls: TArray<TAIToolCall>;
  const Results: TArray<String>;
  Tools: TJSONArray): TAIResponse;
```

**Parameters:**
- `Conv` — Same conversation used in ChatWithTools
- `ToolCalls` — The tool calls from the previous response
- `Results` — Execution results (same length, same order as ToolCalls)
- `Tools` — Same tool definitions (AI may call more tools)

**Returns:** Next `TAIResponse` (may contain more tool calls)

### Provider-Specific Handling

The tool-use system handles all three providers transparently:

| Aspect | Anthropic | OpenAI | Google |
|--------|-----------|--------|--------|
| Tool definitions | `tools` array | `tools` array | `tools[].functionDeclarations` |
| Tool call in response | `content[].type=tool_use` | `message.tool_calls` | `parts[].functionCall` |
| Tool results | `content[].type=tool_result` (user msg) | `role=tool` messages | `parts[].functionResponse` |
| Tool call ID | Required (string) | Required (string) | Not used |
| Stop reason | `stop_reason=tool_use` | `finish_reason=tool_calls` | `finishReason=STOP` |

### Plan9Basic Usage

From Plan9Basic, tool-use is accessed through P9EngineLib:

```basic
' Initialize pointers
let ai# = Pointer#(0)
let eng# = Pointer#(0)

' Setup AI client
let ai# = ai_client#("anthropic", "your-api-key")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)

' Create engine (auto-registers 8 editor tools)
let eng# = p9_engine#(ai#, "knowledge/", "skills/")

' Generate with tool-use
let result$ = p9_generate_tools$(eng#, "Create a hello world and run it")
println result$

' Cleanup
let x = p9_engine_free(eng#)
let x = ai_free(ai#)
```

### Backward Compatibility

All existing methods are unchanged:
- `ai_chat$`, `ai_chatstream` — still work exactly the same
- `ai_complete$`, `ai_completesystem$` — unchanged
- `ai_conversation#`, `ai_ask$` — unchanged

The new tool-use methods are purely additive.
