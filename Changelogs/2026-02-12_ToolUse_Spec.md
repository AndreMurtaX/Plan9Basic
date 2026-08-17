# Internal Tool-Use Extension — Specification

## Giving the AI Hands Inside the Editor

**Version:** 1.0
**Status:** Specification
**Depends on:** AILib 1.1, IntelligenceEngine 1.0, P9EngineLib 1.0

---

## 1. The Problem

Today the Intelligence Engine is a one-way pipe: the user asks, the AI returns
a string of code, and the user must manually copy it into the editor and run it.
The AI cannot see what happens next. It cannot run the code, read errors, check
output, list files, or interact with the editor in any way.

The auto-fix loop is the only exception — and it works precisely because we gave
the AI a callback (`TCompileCallback`) that lets it take an action and see the
result. This spec generalizes that pattern into a full tool-use system.

---

## 2. How LLM Tool-Use Works

All three providers (Anthropic, OpenAI, Google) support the same fundamental
concept with different JSON formats:

```
1. Client sends:    system prompt + messages + tool definitions
2. AI responds:     text AND/OR tool calls (name + arguments)
3. Client executes: runs each tool, collects results
4. Client sends:    tool results back to AI
5. AI responds:     final text (or more tool calls)
6. Repeat 3-5 until AI gives a text-only response
```

The AI decides WHEN and WHETHER to call tools. We define WHAT tools exist
and HOW they execute. This is the critical design point — the tool definitions
become part of the system prompt, teaching the AI what it can do.

---

## 3. Architecture

```
  User: "Create a calculator and run it"
         │
         ▼
  ┌─────────────────────────────────────────────────────┐
  │              IntelligenceEngine                      │
  │                                                     │
  │  1. Assemble prompt (RAG + Skills + Tools)          │
  │  2. Call AI with tool definitions                   │
  │  3. AI returns: code + tool_call("run_program")     │
  │  4. Execute tool via TToolExecutor                  │
  │  5. Send result back to AI                          │
  │  6. AI returns: "The calculator is running..."      │
  │                                                     │
  │  ┌─────────────┐    ┌────────────────────────────┐  │
  │  │ TAIClient   │    │ TToolExecutor              │  │
  │  │ (transport)  │    │  Tools registered:         │  │
  │  │             │◄───│  • run_program             │  │
  │  │  NEW:       │    │  • load_editor             │  │
  │  │  ChatWith   │    │  • get_console_output      │  │
  │  │  Tools()    │    │  • compile_check           │  │
  │  └─────────────┘    │  • list_files              │  │
  │                     │  • read_file               │  │
  │                     │  • save_file               │  │
  │                     │  • get_editor_code          │  │
  │                     │                            │  │
  │                     │  Each tool → callback      │  │
  │                     │  set by UnitMain.pas       │  │
  │                     └────────────────────────────┘  │
  └─────────────────────────────────────────────────────┘
         │
         ▼
  UnitMain.pas (registers callbacks at engine creation)
```

---

## 4. New Unit: ToolExecutor.pas

This unit defines tools, stores them, and executes them via callbacks.
It has NO dependency on AILib — it only deals with tool definitions and execution.

### 4.1 Core Types

```pascal
unit ToolExecutor;

interface

uses
  System.SysUtils, System.Classes, System.JSON,
  System.Generics.Collections;

type
  // A single parameter definition for a tool
  TToolParam = record
    Name: String;         // "filename"
    ParamType: String;    // "string", "number", "boolean"
    Description: String;  // "The filename to save"
    Required: Boolean;    // True if mandatory
  end;

  // Complete tool definition
  TToolDef = record
    Name: String;         // "run_program"
    Description: String;  // "Execute Plan9Basic code and return console output"
    Params: TArray<TToolParam>;
  end;

  // Result of executing a tool
  TToolResult = record
    Success: Boolean;
    Output: String;       // Text returned to the AI
  end;

  // A tool call requested by the AI
  TToolCall = record
    Id: String;           // Provider-assigned ID (for matching results)
    Name: String;         // Tool name
    Arguments: String;    // JSON string of arguments
  end;

  // Callback type: receives parsed arguments, returns result
  TToolCallback = function(const Args: TJSONObject): TToolResult of object;

  // The executor: stores tool definitions and dispatches calls
  TToolExecutor = class
  private
    FTools: TDictionary<String, TToolDef>;
    FCallbacks: TDictionary<String, TToolCallback>;
    FMaxIterations: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    // Registration
    procedure RegisterTool(const Def: TToolDef;
      Callback: TToolCallback);
    procedure UnregisterTool(const Name: String);
    procedure ClearTools;

    // Execution
    function Execute(const Call: TToolCall): TToolResult;
    function HasTools: Boolean;
    function ToolCount: Integer;

    // Export definitions (for embedding in AI requests)
    function GetToolDefs: TArray<TToolDef>;

    // JSON builders for each provider format
    function BuildAnthropicTools: TJSONArray;
    function BuildOpenAITools: TJSONArray;
    function BuildGoogleTools: TJSONArray;

    property MaxIterations: Integer
      read FMaxIterations write FMaxIterations;  // default 5
  end;
```

### 4.2 JSON Output Formats

The executor builds provider-specific JSON for tool definitions:

**Anthropic format:**
```json
[
  {
    "name": "run_program",
    "description": "Execute Plan9Basic code and return console output",
    "input_schema": {
      "type": "object",
      "properties": {
        "code": {"type": "string", "description": "The Plan9Basic source code"}
      },
      "required": ["code"]
    }
  }
]
```

**OpenAI format:**
```json
[
  {
    "type": "function",
    "function": {
      "name": "run_program",
      "description": "Execute Plan9Basic code and return console output",
      "parameters": {
        "type": "object",
        "properties": {
          "code": {"type": "string", "description": "The Plan9Basic source code"}
        },
        "required": ["code"]
      }
    }
  }
]
```

**Google format:**
```json
[
  {
    "functionDeclarations": [
      {
        "name": "run_program",
        "description": "Execute Plan9Basic code and return console output",
        "parameters": {
          "type": "object",
          "properties": {
            "code": {"type": "string", "description": "The Plan9Basic source code"}
          },
          "required": ["code"]
        }
      }
    ]
  }
]
```

### 4.3 Implementation Notes

```pascal
function TToolExecutor.Execute(const Call: TToolCall): TToolResult;
var
  Callback: TToolCallback;
  ArgsJson: TJSONObject;
begin
  Result.Success := False;
  Result.Output := '';

  if not FCallbacks.TryGetValue(Call.Name, Callback) then
  begin
    Result.Output := 'Unknown tool: ' + Call.Name;
    Exit;
  end;

  ArgsJson := nil;
  try
    if Call.Arguments <> '' then
      ArgsJson := TJSONObject.ParseJSONValue(Call.Arguments) as TJSONObject
    else
      ArgsJson := TJSONObject.Create;

    if ArgsJson = nil then
    begin
      Result.Output := 'Invalid arguments JSON';
      Exit;
    end;

    Result := Callback(ArgsJson);
  except
    on E: Exception do
    begin
      Result.Success := False;
      Result.Output := 'Tool error: ' + E.Message;
    end;
  end;
  if ArgsJson <> nil then
    ArgsJson.Free;
end;
```

---

## 5. AILib Modifications

AILib needs 3 changes: tool-aware request building, tool-call response parsing,
and a new conversation method that handles the tool-use loop.

### 5.1 New Types (in AILib interface section)

```pascal
type
  // Represents a tool call found in an AI response
  TAIToolCall = record
    Id: String;         // Provider-assigned ID
    Name: String;       // Tool function name
    Arguments: String;  // JSON arguments string
  end;

  // Extended response that can contain both text and tool calls
  TAIResponse = record
    Text: String;                    // Text content (may be empty if tool calls)
    ToolCalls: TArray<TAIToolCall>;  // Tool calls (empty if text-only)
    StopReason: String;              // "end_turn", "tool_use", "stop", etc.
    HasToolCalls: Boolean;           // Convenience flag
    RawBody: String;                 // Full response body for debugging
  end;
```

### 5.2 New TAIClient Methods

```pascal
  TAIClient = class
  public
    // ... existing methods ...

    // New: Send request with tool definitions, parse structured response
    function ChatWithTools(Conv: TAIConversation;
      const UserMessage: String;
      const ToolsJson: TJSONArray): TAIResponse;

    // New: Send tool results back and get next response
    function SendToolResults(Conv: TAIConversation;
      const ToolCalls: TArray<TAIToolCall>;
      const Results: TArray<String>;
      const ToolsJson: TJSONArray): TAIResponse;
  end;
```

### 5.3 Request Building Changes

Each `Build*Body` method gets an optional `Tools: TJSONArray` parameter.
When non-nil, the tools array is injected into the request JSON at the
provider-specific location:

```pascal
function TAIClient.BuildAnthropicBody(
  const Messages: TList<TAIMessage>;
  const SystemPrompt: String;
  Stream: Boolean;
  Tools: TJSONArray = nil): String;
var
  Root: TJSONObject;
begin
  Root := TJSONObject.Create;
  try
    // ... existing body building ...

    // NEW: inject tools if provided
    if (Tools <> nil) and (Tools.Count > 0) then
      Root.AddPair('tools', Tools.Clone as TJSONArray);

    Result := Root.ToJSON;
  finally
    Root.Free;
  end;
end;
```

For OpenAI/Custom:
```pascal
    if (Tools <> nil) and (Tools.Count > 0) then
      Root.AddPair('tools', Tools.Clone as TJSONArray);
```

For Google:
```pascal
    if (Tools <> nil) and (Tools.Count > 0) then
      Root.AddPair('tools', Tools.Clone as TJSONArray);
```

### 5.4 Response Parsing Changes

New parse methods that return `TAIResponse` instead of `String`:

```pascal
function TAIClient.ParseAnthropicResponseEx(const Body: String): TAIResponse;
var
  Json, ContentItem: TJSONObject;
  ContentArray: TJSONArray;
  I: Integer;
  ItemType, ToolId, ToolName, ToolArgs: String;
  TC: TAIToolCall;
  ToolCallList: TList<TAIToolCall>;
  TextParts: TStringBuilder;
begin
  Result := Default(TAIResponse);
  Result.RawBody := Body;
  // ... error checking same as current ...

  ContentArray := Json.GetValue('content') as TJSONArray;
  Result.StopReason := Json.GetValue<String>('stop_reason', 'end_turn');

  TextParts := TStringBuilder.Create;
  ToolCallList := TList<TAIToolCall>.Create;
  try
    for I := 0 to ContentArray.Count - 1 do
    begin
      ContentItem := ContentArray.Items[I] as TJSONObject;
      ItemType := ContentItem.GetValue<String>('type', '');

      if ItemType = 'text' then
        TextParts.Append(ContentItem.GetValue<String>('text', ''))
      else if ItemType = 'tool_use' then
      begin
        TC.Id := ContentItem.GetValue<String>('id', '');
        TC.Name := ContentItem.GetValue<String>('name', '');
        if ContentItem.GetValue('input') <> nil then
          TC.Arguments := ContentItem.GetValue('input').ToJSON
        else
          TC.Arguments := '{}';
        ToolCallList.Add(TC);
      end;
    end;

    Result.Text := TextParts.ToString;
    Result.ToolCalls := ToolCallList.ToArray;
    Result.HasToolCalls := Length(Result.ToolCalls) > 0;
  finally
    TextParts.Free;
    ToolCallList.Free;
  end;
end;
```

Similar for OpenAI (tool calls in `message.tool_calls`) and Google
(function calls in `parts[].functionCall`).

### 5.5 Sending Tool Results Back

After executing tools, results must be sent back in the conversation.
Each provider has a different message format for tool results:

**Anthropic:** Tool results are a user message with `tool_result` content blocks:
```json
{
  "role": "user",
  "content": [
    {
      "type": "tool_result",
      "tool_use_id": "toolu_abc123",
      "content": "Program executed. Output:\nHello World!"
    }
  ]
}
```

**OpenAI:** Each tool result is a separate message with role "tool":
```json
{
  "role": "tool",
  "tool_call_id": "call_abc123",
  "content": "Program executed. Output:\nHello World!"
}
```

**Google:** Tool results are a `functionResponse` part in a user turn:
```json
{
  "role": "user",
  "parts": [
    {
      "functionResponse": {
        "name": "run_program",
        "response": {"result": "Hello World!"}
      }
    }
  ]
}
```

The `SendToolResults` method handles this formatting internally, so the
IntelligenceEngine just provides tool call IDs and result strings.

### 5.6 Backward Compatibility

All existing methods remain unchanged. The new `ChatWithTools` and
`SendToolResults` are additions. The existing `Build*Body` methods gain
an optional `Tools` parameter with a default of `nil`, so no existing
call sites break.

---

## 6. IntelligenceEngine Integration

### 6.1 New Fields

```pascal
  TIntelligenceEngine = class
  private
    // ... existing fields ...
    FToolExecutor: TToolExecutor;   // NEW: owned
```

### 6.2 New Method: GenerateWithTools

This is the core tool-use loop, sitting alongside the existing `Generate`:

```pascal
function TIntelligenceEngine.GenerateWithTools(
  const UserQuery: String): TGenerationResult;
var
  Prompt: TAssembledPrompt;
  ToolsJson: TJSONArray;
  Response: TAIResponse;
  ToolResults: TArray<String>;
  Iteration: Integer;
  I: Integer;
  TR: TToolResult;
begin
  Result := Default(TGenerationResult);

  // Step 1: Assemble prompt (same as Generate)
  Progress('ASSEMBLE', 'Building prompt...');
  Prompt := FAssembler.Assemble(UserQuery);
  // ... fill Result metadata from Prompt ...

  // Step 2: Build tool definitions for the active provider
  ToolsJson := BuildToolsForProvider;

  // Step 3: Initial AI call with tools
  Progress('GENERATE', 'Calling AI with tools...');
  Response := FAIClient.ChatWithTools(
    FConversation, UserQuery, ToolsJson);

  // Step 4: Tool-use loop
  Iteration := 0;
  while Response.HasToolCalls and
        (Iteration < FToolExecutor.MaxIterations) do
  begin
    Inc(Iteration);
    Progress('TOOLS', Format('Executing %d tool(s), iteration %d',
      [Length(Response.ToolCalls), Iteration]));

    // Execute each tool call
    SetLength(ToolResults, Length(Response.ToolCalls));
    for I := 0 to Length(Response.ToolCalls) - 1 do
    begin
      TR := FToolExecutor.Execute(TToolCall(Response.ToolCalls[I]));
      ToolResults[I] := TR.Output;
      Progress('TOOLS', Format('  %s → %s',
        [Response.ToolCalls[I].Name,
         Copy(TR.Output, 1, 80)]));
    end;

    // Send results back to AI
    Response := FAIClient.SendToolResults(
      FConversation, Response.ToolCalls, ToolResults, ToolsJson);
  end;

  // Step 5: Extract final code from text response
  Result.Code := CleanAIResponse(Response.Text);
  Result.Success := Result.Code <> '';
  FLastResult := Result;
end;
```

### 6.3 Provider-Aware Tool JSON Building

```pascal
function TIntelligenceEngine.BuildToolsForProvider: TJSONArray;
begin
  if (FToolExecutor = nil) or not FToolExecutor.HasTools then
  begin
    Result := nil;
    Exit;
  end;

  case FAIClient.Provider of
    aipAnthropic: Result := FToolExecutor.BuildAnthropicTools;
    aipOpenAI,
    aipCustom:    Result := FToolExecutor.BuildOpenAITools;
    aipGoogle:    Result := FToolExecutor.BuildGoogleTools;
  else
    Result := FToolExecutor.BuildOpenAITools; // safe default
  end;
end;
```

### 6.4 Smart Tool Selection

Not every request needs tools. The engine should only include tools when
the user's intent suggests interaction:

```pascal
function TIntelligenceEngine.ShouldUseTools(
  const UserQuery: String): Boolean;
const
  ACTION_HINTS: array[0..9] of String = (
    'run', 'execute', 'test', 'try', 'save',
    'load', 'open', 'show', 'list', 'check'
  );
var
  LQ: String;
  I: Integer;
begin
  Result := False;
  if (FToolExecutor = nil) or not FToolExecutor.HasTools then Exit;

  LQ := LowerCase(UserQuery);
  for I := 0 to High(ACTION_HINTS) do
    if Pos(ACTION_HINTS[I], LQ) > 0 then
    begin
      Result := True;
      Exit;
    end;
end;
```

The main `Generate` method can then auto-select:

```pascal
function TIntelligenceEngine.Generate(
  const UserQuery: String): TGenerationResult;
begin
  if ShouldUseTools(UserQuery) then
    Result := GenerateWithTools(UserQuery)
  else
    Result := GenerateTextOnly(UserQuery);  // current Generate logic
end;
```

---

## 7. Built-in Editor Tools

These are the tools that UnitMain.pas registers. Each one maps to a
callback method on `TfrmMain`:

### 7.1 Tool Definitions

| Tool Name | Description | Parameters | Returns |
|-----------|-------------|------------|---------|
| `run_program` | Execute Plan9Basic code and return console output | `code: string` | Console output text |
| `compile_check` | Check if code compiles without running | `code: string` | "OK" or error messages |
| `load_editor` | Load code into the editor (does not run) | `code: string` | "Code loaded (N lines)" |
| `get_editor_code` | Get the current code from the editor | *(none)* | Current editor contents |
| `get_console_output` | Read the current console output | *(none)* | Console text |
| `list_files` | List saved Plan9Basic program files | *(none)* | Filename list |
| `read_file` | Read a saved program file | `filename: string` | File contents |
| `save_file` | Save code to a file | `filename: string, code: string` | "Saved" or error |

### 7.2 Tool Registration in UnitMain.pas

The tools are registered when the Intelligence Engine is created. This
requires adding new callback methods to `TfrmMain`:

```pascal
// In TfrmMain private section:
private
  // ... existing ...

  // AI Tool callbacks
  function ToolRunProgram(const Args: TJSONObject): TToolResult;
  function ToolCompileCheck(const Args: TJSONObject): TToolResult;
  function ToolLoadEditor(const Args: TJSONObject): TToolResult;
  function ToolGetEditorCode(const Args: TJSONObject): TToolResult;
  function ToolGetConsoleOutput(const Args: TJSONObject): TToolResult;
  function ToolListFiles(const Args: TJSONObject): TToolResult;
  function ToolReadFile(const Args: TJSONObject): TToolResult;
  function ToolSaveFile(const Args: TJSONObject): TToolResult;
```

### 7.3 Callback Implementations (Examples)

```pascal
function TfrmMain.ToolRunProgram(const Args: TJSONObject): TToolResult;
var
  Code, Output: String;
begin
  Code := Args.GetValue<String>('code', '');
  if Code = '' then
  begin
    Result.Success := False;
    Result.Output := 'No code provided';
    Exit;
  end;

  // Clear console, load code, execute
  FConsole.Clear;
  FBasic.Reset;
  FBasic.LoadProgram(Code);
  FBasic.Execute;

  // Capture output
  Output := FConsole.GetAllText;
  if FBasic.LastError <> '' then
    Output := Output + #13#10 + 'ERROR: ' + FBasic.LastError;

  Result.Success := True;
  Result.Output := Output;
end;

function TfrmMain.ToolCompileCheck(const Args: TJSONObject): TToolResult;
var
  Code, Errors: String;
begin
  Code := Args.GetValue<String>('code', '');
  // Use the parser to check syntax without executing
  Errors := FBasic.CompileCheck(Code);

  Result.Success := (Errors = '');
  if Errors = '' then
    Result.Output := 'OK — code compiles without errors'
  else
    Result.Output := 'Compilation errors:' + #13#10 + Errors;
end;

function TfrmMain.ToolLoadEditor(const Args: TJSONObject): TToolResult;
var
  Code: String;
  LineCount: Integer;
begin
  Code := Args.GetValue<String>('code', '');
  // Load into editor (same logic as LOAD command)
  Editor.Lines.Text := Code;
  SyncEditorToProgram;
  LineCount := FProgram.Count;
  FModified := True;
  UpdateStatusBar;

  Result.Success := True;
  Result.Output := Format('Code loaded into editor (%d lines)', [LineCount]);
end;

function TfrmMain.ToolGetEditorCode(const Args: TJSONObject): TToolResult;
begin
  if FInterfaceMode = imEditor then
    SyncProgramToEditor;

  Result.Success := True;
  Result.Output := GetProgramText;
  if Result.Output = '' then
    Result.Output := '(editor is empty)';
end;

function TfrmMain.ToolGetConsoleOutput(const Args: TJSONObject): TToolResult;
begin
  Result.Success := True;
  Result.Output := FConsole.GetAllText;
  if Result.Output = '' then
    Result.Output := '(console is empty)';
end;

function TfrmMain.ToolListFiles(const Args: TJSONObject): TToolResult;
var
  Files: TStringDynArray;
  SB: TStringBuilder;
  F: String;
begin
  Files := TDirectory.GetFiles(GetBasePath, '*.bas');

  SB := TStringBuilder.Create;
  try
    for F in Files do
      SB.AppendLine(TPath.GetFileName(F));

    Result.Success := True;
    if SB.Length > 0 then
      Result.Output := SB.ToString
    else
      Result.Output := '(no saved files)';
  finally
    SB.Free;
  end;
end;

function TfrmMain.ToolReadFile(const Args: TJSONObject): TToolResult;
var
  Filename, FullPath, Content: String;
begin
  Filename := Args.GetValue<String>('filename', '');
  if Filename = '' then
  begin
    Result.Success := False;
    Result.Output := 'No filename provided';
    Exit;
  end;

  FullPath := TPath.Combine(GetBasePath, Filename);
  if not TFile.Exists(FullPath) then
  begin
    Result.Success := False;
    Result.Output := 'File not found: ' + Filename;
    Exit;
  end;

  Content := TFile.ReadAllText(FullPath);
  Result.Success := True;
  Result.Output := Content;
end;

function TfrmMain.ToolSaveFile(const Args: TJSONObject): TToolResult;
var
  Filename, Code, FullPath: String;
begin
  Filename := Args.GetValue<String>('filename', '');
  Code := Args.GetValue<String>('code', '');

  if (Filename = '') or (Code = '') then
  begin
    Result.Success := False;
    Result.Output := 'Both filename and code are required';
    Exit;
  end;

  // Ensure .bas extension
  if not Filename.EndsWith('.bas', True) then
    Filename := Filename + '.bas';

  FullPath := TPath.Combine(GetBasePath, Filename);
  TFile.WriteAllText(FullPath, Code);

  Result.Success := True;
  Result.Output := 'Saved to ' + Filename;
end;
```

### 7.4 Registration Wiring

When the user creates an Intelligence Engine via BASIC or when the IDE's
AI panel initializes, tools are registered:

```pascal
procedure TfrmMain.RegisterEditorTools(Engine: TIntelligenceEngine);

  function MakeParam(const AName, AType, ADesc: String;
    ARequired: Boolean): TToolParam;
  begin
    Result.Name := AName;
    Result.ParamType := AType;
    Result.Description := ADesc;
    Result.Required := ARequired;
  end;

  function MakeTool(const AName, ADesc: String;
    const AParams: TArray<TToolParam>): TToolDef;
  begin
    Result.Name := AName;
    Result.Description := ADesc;
    Result.Params := AParams;
  end;

var
  Exec: TToolExecutor;
begin
  Exec := Engine.ToolExecutor;

  Exec.RegisterTool(
    MakeTool('run_program',
      'Execute Plan9Basic code and return the console output. ' +
      'Use this to test code after generating it.',
      [MakeParam('code', 'string',
        'Complete Plan9Basic source code to execute', True)]),
    ToolRunProgram);

  Exec.RegisterTool(
    MakeTool('compile_check',
      'Check if Plan9Basic code compiles without running it. ' +
      'Returns "OK" or error messages with line numbers.',
      [MakeParam('code', 'string',
        'Plan9Basic source code to check', True)]),
    ToolCompileCheck);

  Exec.RegisterTool(
    MakeTool('load_editor',
      'Load Plan9Basic code into the editor for the user to see and modify. ' +
      'Does NOT execute the code.',
      [MakeParam('code', 'string',
        'Plan9Basic source code to load', True)]),
    ToolLoadEditor);

  Exec.RegisterTool(
    MakeTool('get_editor_code',
      'Read the current contents of the code editor.',
      []),
    ToolGetEditorCode);

  Exec.RegisterTool(
    MakeTool('get_console_output',
      'Read the current console/terminal output.',
      []),
    ToolGetConsoleOutput);

  Exec.RegisterTool(
    MakeTool('list_files',
      'List all saved Plan9Basic program files (.bas).',
      []),
    ToolListFiles);

  Exec.RegisterTool(
    MakeTool('read_file',
      'Read the contents of a saved Plan9Basic program file.',
      [MakeParam('filename', 'string',
        'Name of the .bas file to read', True)]),
    ToolReadFile);

  Exec.RegisterTool(
    MakeTool('save_file',
      'Save Plan9Basic code to a file.',
      [MakeParam('filename', 'string',
        'Name for the .bas file', True),
       MakeParam('code', 'string',
        'Plan9Basic source code to save', True)]),
    ToolSaveFile);
end;
```

---

## 8. P9EngineLib Binding Changes

New BASIC functions to expose tool control:

| Function | Signature | Description |
|----------|-----------|-------------|
| `p9_tools_enable#` | `p9_tools_enable#(eng#, enabled)` | Enable/disable tool-use |
| `p9_tools_count` | `p9_tools_count(eng#)` | Number of registered tools |
| `p9_tools_list$` | `p9_tools_list$(eng#)` | Comma-separated tool names |

The key point is that **most tool registration happens from UnitMain.pas
(Delphi side), not from BASIC**. BASIC programs can enable/disable tools
and query what's available, but the actual tool callbacks require Delphi
code with access to the editor, console, and file system.

---

## 9. Security Considerations

### 9.1 Sandboxing

Tools must enforce boundaries:

- **`run_program`**: Uses the existing BASIC VM with its timeout
  (`FBasic.ScriptTimeOut`). No access to system resources beyond what
  Plan9Basic already permits.

- **`save_file` / `read_file`**: Restricted to `GetBasePath()` only.
  No path traversal (`..`), no absolute paths, no access outside the
  Plan9Basic documents folder.

- **`load_editor`**: Safe — just sets text in the editor memo.

### 9.2 Iteration Limit

The tool-use loop has a hard cap (`MaxIterations`, default 5) to prevent
runaway loops where the AI keeps calling tools indefinitely.

### 9.3 User Consent

For the initial implementation, tools execute automatically. A future
enhancement could add a confirmation callback:

```pascal
TToolConfirmCallback = function(const ToolName: String;
  const Args: TJSONObject): Boolean of object;
```

This would let the UI show "AI wants to run your program. Allow?" before
executing. This is NOT required for v1.0 but should be kept in mind.

---

## 10. Implementation Plan

### Phase 1: ToolExecutor.pas (new unit)
- Tool definition types and registry
- Callback execution with error handling
- JSON builders for Anthropic, OpenAI, Google formats
- No external dependencies (self-contained)

### Phase 2: AILib modifications
- Add `TAIToolCall` and `TAIResponse` types to interface
- Add `ChatWithTools` method
- Add `SendToolResults` method
- Add `Tools` parameter to `Build*Body` methods (with nil default)
- Add `Parse*ResponseEx` methods returning `TAIResponse`
- All existing methods unchanged (backward compatible)

### Phase 3: IntelligenceEngine integration
- Add `FToolExecutor` field (owned)
- Add `GenerateWithTools` method
- Add `ShouldUseTools` heuristic
- Modify `Generate` to auto-select text-only vs tool-use
- Expose `ToolExecutor` property for external registration

### Phase 4: P9EngineLib bindings
- Add 3 new BASIC functions
- Update registration

### Phase 5: UnitMain.pas integration
- Add 8 tool callback methods to `TfrmMain`
- Add `RegisterEditorTools` procedure
- Call `RegisterEditorTools` during engine initialization

---

## 11. Example User Session

```
User:  "Create a program that asks for your name and greets you. Run it."

AI thinking:
  - Intent: create + run → tools needed
  - Skill selected: console_tool
  - RAG: StdLib (input$, println), StrLib (string ops)
  - Tools available: run_program, load_editor, ...

AI response:
  [text] "I'll create a greeting program and run it for you."
  [tool_call] load_editor(code="let name$ = input$(\"Your name: \")\nprintln \"Hello, \" + name$ + \"!\"")
  [tool_call] compile_check(code="...")

Engine executes tools:
  load_editor → "Code loaded into editor (2 lines)"
  compile_check → "OK — code compiles without errors"

Engine sends results back to AI.

AI response:
  [text] "I've loaded the program into the editor. It compiles correctly.
   The program will ask for your name and then print a greeting.
   You can press RUN to try it, or I can modify it for you."
```

```
User:  "What files do I have saved?"

AI thinking:
  - Intent: list → tools needed
  - No code generation required

AI response:
  [tool_call] list_files()

Engine executes:
  list_files → "calculator.bas\nguess_game.bas\nhello.bas"

AI response:
  "You have 3 saved programs: calculator.bas, guess_game.bas, and hello.bas.
   Would you like me to open or modify any of them?"
```

---

## 12. Files Summary

| File | Action | Lines (est.) |
|------|--------|-------------|
| `ToolExecutor.pas` | **NEW** | ~450 |
| `AILib.pas` | **MODIFY** | +250 |
| `IntelligenceEngine.pas` | **MODIFY** | +120 |
| `P9EngineLib.pas` | **MODIFY** | +40 |
| `UnitMain.pas` | **MODIFY** | +180 |

Total new/modified: ~1,040 lines

No breaking changes to existing APIs.
