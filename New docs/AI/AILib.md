# AILib - AI Client Library

## Overview

AILib provides functions to communicate with large language model APIs from Plan9Basic programs. It supports multiple AI providers out of the box, including Anthropic (Claude), OpenAI (GPT), Google (Gemini), and many others. AILib handles all HTTP transport, authentication, message formatting, streaming, and multi-turn conversations, so your BASIC programs only need to focus on what to say and how to use the response.

**Version:** 1.1  
**Function Count:** 45 functions

## Key Features

- **Multi-Provider Support** - Works with Anthropic, OpenAI, Google, Mistral, Groq, DeepSeek, xAI, Perplexity, Together, Fireworks, OpenRouter, Ollama, LM Studio, Jan, and custom OpenAI-compatible endpoints
- **Simple Chat** - Send a message, get a response in one function call
- **Streaming** - Receive tokens in real-time via BASIC callback functions
- **Single-Shot Completion** - Stateless prompt-in/response-out for simple tasks
- **Multi-Turn Conversations** - Maintain conversation history with token management
- **Configuration** - Set model, temperature, max tokens, top-p, timeout, stop sequences, custom headers, base URL, and more
- **Error Handling** - Structured error codes with human-readable messages
- **Response Metadata** - Access HTTP status, token counts, and raw response body
- **Automatic Memory Management** - AI clients and conversations are tracked by the garbage collector

## Supported Providers

| Provider Name | Alias | Default Model |
|---------------|-------|---------------|
| `"anthropic"` | `"claude"` | `claude-sonnet-4-20250514` |
| `"openai"` | `"gpt"` | `gpt-4o` |
| `"google"` | `"gemini"` | `gemini-2.0-flash` |
| `"mistral"` | — | `mistral-large-latest` |
| `"groq"` | — | `llama-3.3-70b-versatile` |
| `"deepseek"` | — | `deepseek-chat` |
| `"xai"` | `"grok"` | `grok-3` |
| `"perplexity"` | — | `sonar-pro` |
| `"together"` | — | `meta-llama/Meta-Llama-3.1-70B-Instruct-Turbo` |
| `"fireworks"` | — | `accounts/fireworks/models/llama-v3p1-70b-instruct` |
| `"openrouter"` | — | `anthropic/claude-sonnet-4-20250514` |
| `"ollama"` | — | `llama3` (local, port 11434) |
| `"lmstudio"` | — | `local-model` (local, port 1234) |
| `"jan"` | — | `local-model` (local, port 1337) |
| `"custom"` | — | *(none — set with `ai_baseurl#` and `ai_model#`)* |

## Error Codes

Use `ai_error()` and `ai_errormsg$()` to check the result of the last AILib operation:

| Code | Description |
|------|-------------|
| 0 | No error |
| 1 | Invalid client handle |
| 2 | Invalid conversation handle |
| 3 | Invalid or unknown provider |
| 4 | Invalid API key |
| 5 | Connection error |
| 6 | Request timeout |
| 7 | API error (server returned an error) |
| 8 | Response parse error |
| 9 | Rate limit exceeded |
| 10 | Authentication failed |
| 11 | Invalid model name |
| 12 | Streaming error |
| 13 | Invalid argument |
| 14 | Context window overflow |

## Function Naming Convention

| Suffix | Returns | Example |
|--------|---------|---------|
| `#` | Pointer (AI client or configuration setter) | `ai_client#()`, `ai_model#()` |
| `$` | String | `ai_chat$()`, `ai_errormsg$()` |
| (none) | Number | `ai_error()`, `ai_status()` |

Configuration setter functions (like `ai_model#`, `ai_temperature#`, etc.) return the AI client pointer. This means you can call them as standalone statements without assigning the result:

```basic
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 4096)
ai_temperature#(ai#, 0.7)
```

## Memory Management

AI clients created with `ai_client#()` and conversations created with `ai_conversation#()` are automatically tracked by Plan9Basic's garbage collector. They will be cleaned up when the program ends or resets. You can also free them explicitly with `ai_free()` and `ai_conversation_free()`.

---

## Function Reference

### Error Handling

#### ai_error()

Returns the error code from the last AILib operation.

**Signature:** `ai_error@`

**Syntax:**
```basic
code = ai_error()
```

**Returns:** Number (error code, 0 = no error)

**Example:**
```basic
let response$ = ai_chat$(ai#, "Hello")
if ai_error() <> 0 then
    println "Error: " + ai_errormsg$()
endif
```

---

#### ai_errormsg$()

Returns the human-readable error message from the last AILib operation.

**Signature:** `ai_errormsg$@`

**Syntax:**
```basic
msg$ = ai_errormsg$()
```

**Returns:** String describing the last error, or empty string if no error

**Example:**
```basic
let response$ = ai_chat$(ai#, "Hello")
if ai_error() <> 0 then
    println "Error " + str$(ai_error()) + ": " + ai_errormsg$()
endif
```

---

#### ai_strerror$()

Converts an error code to its description string.

**Signature:** `ai_strerror$@n`

**Syntax:**
```basic
desc$ = ai_strerror$(errorCode)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `errorCode` | Number | An AILib error code (0-14) |

**Returns:** String describing the error code

**Example:**
```basic
for i = 0 to 14
    println str$(i) + ": " + ai_strerror$(i)
next
```

---

#### ai_clearerror()

Clears the last error state.

**Signature:** `ai_clearerror@`

**Syntax:**
```basic
ai_clearerror()
```

**Returns:** 0

---

### Client Lifecycle

#### ai_client#()

Creates a new AI client for a given provider.

**Signature:** `ai_client#@$$`

**Syntax:**
```basic
ai# = ai_client#(provider$, apiKey$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `provider$` | String | Provider name (see Supported Providers table) |
| `apiKey$` | String | API key for authentication |

**Returns:** Pointer to the AI client

**Example:**
```basic
' Anthropic (Claude)
let ai# = ai_client#("anthropic", "sk-ant-xxxxx")

' OpenAI (GPT)
let ai# = ai_client#("openai", "sk-xxxxx")

' Local model (Ollama) — no key needed
let ai# = ai_client#("ollama", "")
```

---

#### ai_free()

Frees an AI client and releases its resources.

**Signature:** `ai_free@#`

**Syntax:**
```basic
ai_free(ai#)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `ai#` | Pointer | AI client handle |

**Returns:** 1 on success

**Example:**
```basic
let ai# = ai_client#("anthropic", key$)
' ... use the client ...
ai_free(ai#)
```

---

### Configuration

#### ai_model#()

Sets the model to use for requests.

**Signature:** `ai_model#@#$`

**Syntax:**
```basic
ai_model#(ai#, model$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `ai#` | Pointer | AI client handle |
| `model$` | String | Model identifier (e.g., `"claude-sonnet-4-20250514"`, `"gpt-4o"`) |

**Returns:** The AI client pointer (for chaining)

**Example:**
```basic
let ai# = ai_client#("anthropic", key$)
ai_model#(ai#, "claude-sonnet-4-20250514")
```

---

#### ai_model$()

Gets the current model name.

**Signature:** `ai_model$@#`

**Syntax:**
```basic
model$ = ai_model$(ai#)
```

**Returns:** String with the current model name

---

#### ai_system#()

Sets the system prompt for the client. The system prompt is sent with every request and instructs the AI how to behave.

**Signature:** `ai_system#@#$`

**Syntax:**
```basic
ai_system#(ai#, prompt$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `ai#` | Pointer | AI client handle |
| `prompt$` | String | System prompt text |

**Example:**
```basic
ai_system#(ai#, "You are a helpful coding assistant. Always reply in Plan9Basic syntax.")
```

---

#### ai_temperature#()

Sets the temperature (randomness) for responses.

**Signature:** `ai_temperature#@#n`

**Syntax:**
```basic
ai_temperature#(ai#, value)
```

**Parameters:**
| Parameter | Type | Range | Description |
|-----------|------|-------|-------------|
| `value` | Number | 0.0 - 2.0 | Lower = more deterministic, higher = more creative |

---

#### ai_maxtokens#()

Sets the maximum number of tokens the AI can generate in a single response.

**Signature:** `ai_maxtokens#@#n`

**Syntax:**
```basic
ai_maxtokens#(ai#, tokens)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `tokens` | Number | Maximum output tokens (e.g., 1024, 4096) |

---

#### ai_topp#()

Sets the top-p (nucleus sampling) parameter.

**Signature:** `ai_topp#@#n`

**Syntax:**
```basic
ai_topp#(ai#, value)
```

**Parameters:**
| Parameter | Type | Range | Description |
|-----------|------|-------|-------------|
| `value` | Number | 0.0 - 1.0 | Controls diversity of output |

---

#### ai_timeout#()

Sets the request timeout in seconds.

**Signature:** `ai_timeout#@#n`

**Syntax:**
```basic
ai_timeout#(ai#, seconds)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `seconds` | Number | Timeout in seconds (default varies by provider) |

---

#### ai_baseurl#()

Sets a custom base URL for API requests. Useful for proxies or self-hosted endpoints.

**Signature:** `ai_baseurl#@#$`

**Syntax:**
```basic
ai_baseurl#(ai#, url$)
```

**Example:**
```basic
let ai# = ai_client#("custom", key$)
ai_baseurl#(ai#, "https://my-proxy.example.com/v1")
ai_model#(ai#, "my-model")
```

---

#### ai_baseurl$()

Gets the current base URL.

**Signature:** `ai_baseurl$@#`

**Syntax:**
```basic
url$ = ai_baseurl$(ai#)
```

---

#### ai_stop#()

Adds a stop sequence. The AI will stop generating when it encounters any of the registered stop sequences.

**Signature:** `ai_stop#@#$`

**Syntax:**
```basic
ai_stop#(ai#, sequence$)
```

**Example:**
```basic
ai_stop#(ai#, "```")    ' Stop at code block end
ai_stop#(ai#, "END")    ' Stop at END marker
```

---

#### ai_clearstop#()

Removes all stop sequences.

**Signature:** `ai_clearstop#@#`

**Syntax:**
```basic
ai_clearstop#(ai#)
```

---

### Custom Headers

#### ai_header#()

Adds a custom HTTP header to all requests.

**Signature:** `ai_header#@#$$`

**Syntax:**
```basic
ai_header#(ai#, name$, value$)
```

**Example:**
```basic
ai_header#(ai#, "X-Custom-Tag", "my-app")
```

---

#### ai_headerremove#()

Removes a custom header by name.

**Signature:** `ai_headerremove#@#$`

**Syntax:**
```basic
ai_headerremove#(ai#, name$)
```

---

#### ai_headerclear#()

Removes all custom headers.

**Signature:** `ai_headerclear#@#`

**Syntax:**
```basic
ai_headerclear#(ai#)
```

---

### Identity

#### ai_apikey#()

Changes the API key after client creation.

**Signature:** `ai_apikey#@#$`

**Syntax:**
```basic
ai_apikey#(ai#, newKey$)
```

---

#### ai_endpoint#()

Sets a custom endpoint path (appended to the base URL).

**Signature:** `ai_endpoint#@#$`

**Syntax:**
```basic
ai_endpoint#(ai#, path$)
```

---

#### ai_useragent#()

Sets a custom User-Agent header for HTTP requests.

**Signature:** `ai_useragent#@#$`

**Syntax:**
```basic
ai_useragent#(ai#, agent$)
```

---

#### ai_provider$()

Returns the provider name of the client.

**Signature:** `ai_provider$@#`

**Syntax:**
```basic
name$ = ai_provider$(ai#)
```

**Returns:** String such as `"anthropic"`, `"openai"`, `"google"`, etc.

---

### Simple Chat

#### ai_chat$()

Sends a message to the AI and returns the complete response. Maintains internal chat history so the AI remembers previous messages in the session.

**Signature:** `ai_chat$@#$`

**Syntax:**
```basic
response$ = ai_chat$(ai#, message$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `ai#` | Pointer | AI client handle |
| `message$` | String | User message to send |

**Returns:** The AI's response text, or empty string on error

**Example:**
```basic
let ai# = ai_client#("anthropic", key$)
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 1024)

let reply$ = ai_chat$(ai#, "What is Plan9Basic?")
println reply$

' Follow-up (the AI remembers the previous message)
let reply$ = ai_chat$(ai#, "Can you give me an example?")
println reply$
```

---

#### ai_clearchat()

Clears the internal chat history. The next `ai_chat$` call starts a fresh conversation.

**Signature:** `ai_clearchat@#`

**Syntax:**
```basic
ai_clearchat(ai#)
```

---

### Streaming

#### ai_ontoken#()

Sets the name of a BASIC function to call for each token received during streaming.

**Signature:** `ai_ontoken#@#$`

**Syntax:**
```basic
ai_ontoken#(ai#, callbackName$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `callbackName$` | String | Name of a BASIC function with signature `name$(token$, done)` |

The callback function receives two parameters:
- `token$` — the text token just received
- `done` — 0 while streaming, 1 when the final token is sent

**Example:**
```basic
function on_token$(token$, done)
    print token$;
    if done = 1 then
        println ""
        println "--- Stream complete ---"
    endif
    return ""
endfunction

let ai# = ai_client#("anthropic", key$)
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 1024)
ai_ontoken#(ai#, "on_token")
```

---

#### ai_chatstream()

Sends a message and streams the response token by token through the callback set with `ai_ontoken#`.

**Signature:** `ai_chatstream@#$`

**Syntax:**
```basic
ok = ai_chatstream(ai#, message$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `ai#` | Pointer | AI client handle |
| `message$` | String | User message to send |

**Returns:** 1 on success, 0 on error

**Example:**
```basic
' (Assuming on_token$ callback is set up as shown above)
ai_chatstream(ai#, "Write a short poem about coding")
```

---

#### ai_streambuffer$()

Returns the full accumulated text from the last streaming request. Useful for processing the complete response after streaming finishes.

**Signature:** `ai_streambuffer$@#`

**Syntax:**
```basic
fullText$ = ai_streambuffer$(ai#)
```

---

### Single-Shot Completion

#### ai_complete$()

Sends a single prompt and returns the response, with no chat history. Each call is independent.

**Signature:** `ai_complete$@#$`

**Syntax:**
```basic
response$ = ai_complete$(ai#, prompt$)
```

**Example:**
```basic
let summary$ = ai_complete$(ai#, "Summarize in one sentence: " + longText$)
println summary$
```

---

#### ai_completesystem$()

Single-shot completion with a system prompt. Useful for focused tasks where you want to control the AI's behavior for one specific request.

**Signature:** `ai_completesystem$@#$$`

**Syntax:**
```basic
response$ = ai_completesystem$(ai#, systemPrompt$, userMessage$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `ai#` | Pointer | AI client handle |
| `systemPrompt$` | String | System instructions for this request |
| `userMessage$` | String | The user's message |

**Example:**
```basic
let code$ = ai_completesystem$(ai#, "You are a Plan9Basic expert. Return only code, no explanation.", "Create a hello world program")
println code$
```

---

### Conversation Management

Conversations provide explicit control over multi-turn chat history, separate from the simple `ai_chat$` interface. You can create multiple conversations and switch between them.

#### ai_conversation#()

Creates a new empty conversation.

**Signature:** `ai_conversation#@`

**Syntax:**
```basic
conv# = ai_conversation#()
```

**Returns:** Pointer to a new conversation object

---

#### ai_conversation_free()

Frees a conversation and its history.

**Signature:** `ai_conversation_free@#`

**Syntax:**
```basic
ai_conversation_free(conv#)
```

---

#### ai_conversation_system#()

Sets the system prompt for a conversation.

**Signature:** `ai_conversation_system#@#$`

**Syntax:**
```basic
ai_conversation_system#(conv#, systemPrompt$)
```

---

#### ai_conversation_clear()

Clears all messages from a conversation, keeping the system prompt.

**Signature:** `ai_conversation_clear@#`

**Syntax:**
```basic
ai_conversation_clear(conv#)
```

---

#### ai_conversation_maxhistory#()

Sets the maximum number of messages to keep in history. Older messages are trimmed automatically to save tokens.

**Signature:** `ai_conversation_maxhistory#@#n`

**Syntax:**
```basic
ai_conversation_maxhistory#(conv#, maxMessages)
```

---

#### ai_ask$()

Sends a message using a specific conversation and returns the response.

**Signature:** `ai_ask$@##$`

**Syntax:**
```basic
response$ = ai_ask$(ai#, conv#, message$)
```

**Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `ai#` | Pointer | AI client handle |
| `conv#` | Pointer | Conversation handle |
| `message$` | String | User message |

**Returns:** The AI's response text

**Example:**
```basic
let conv# = ai_conversation#()
ai_conversation_system#(conv#, "You are a math tutor.")
ai_conversation_maxhistory#(conv#, 20)

let reply$ = ai_ask$(ai#, conv#, "What is the Pythagorean theorem?")
println reply$

let reply$ = ai_ask$(ai#, conv#, "Can you give me an example?")
println reply$
```

---

#### ai_conversation_count()

Returns the number of messages in a conversation.

**Signature:** `ai_conversation_count@#`

**Syntax:**
```basic
count = ai_conversation_count(conv#)
```

---

#### ai_conversation_last$()

Returns the text of the last message in the conversation (typically the AI's most recent response).

**Signature:** `ai_conversation_last$@#`

**Syntax:**
```basic
lastMsg$ = ai_conversation_last$(conv#)
```

---

#### ai_conversation_tokens()

Returns an estimated token count for the entire conversation history.

**Signature:** `ai_conversation_tokens@#`

**Syntax:**
```basic
tokens = ai_conversation_tokens(conv#)
```

---

### Response Metadata

#### ai_status()

Returns the HTTP status code from the last request.

**Signature:** `ai_status@#`

**Syntax:**
```basic
status = ai_status(ai#)
```

**Returns:** HTTP status code (200 = OK, 401 = unauthorized, 429 = rate limited, etc.)

---

#### ai_body$()

Returns the raw JSON response body from the last request. Useful for debugging or extracting data not exposed by other functions.

**Signature:** `ai_body$@#`

**Syntax:**
```basic
rawJson$ = ai_body$(ai#)
```

---

#### ai_tokensin()

Returns the number of input tokens used in the last request.

**Signature:** `ai_tokensin@#`

**Syntax:**
```basic
inputTokens = ai_tokensin(ai#)
```

---

#### ai_tokensout()

Returns the number of output tokens generated in the last request.

**Signature:** `ai_tokensout@#`

**Syntax:**
```basic
outputTokens = ai_tokensout(ai#)
```

---

#### ai_ok()

Returns 1 if the last request succeeded (HTTP 200), 0 otherwise.

**Signature:** `ai_ok@#`

**Syntax:**
```basic
if ai_ok(ai#) = 1 then
    println "Request succeeded"
endif
```

---

## Complete Examples

### Example 1: Simple Chat

```basic
' Basic chat with Claude
println "=== Simple AI Chat ==="
println ""

let key$ = "sk-ant-xxxxx"    ' Replace with your key
let ai# = ai_client#("anthropic", key$)
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 1024)

let reply$ = ai_chat$(ai#, "Hello! What are the 3 primary colors?")

if ai_ok(ai#) = 1 then
    println reply$
    println ""
    println "Tokens: " + str$(ai_tokensin(ai#)) + " in, " + str$(ai_tokensout(ai#)) + " out"
else
    println "Error: " + ai_errormsg$()
endif

ai_free(ai#)
```

### Example 2: Streaming Response

```basic
' Stream tokens to the console in real-time
println "=== Streaming Demo ==="
println ""

function on_token$(token$, done)
    print token$;
    if done = 1 then
        println ""
        println ""
        println "--- Done ---"
    endif
    return ""
endfunction

let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 512)
ai_ontoken#(ai#, "on_token")

ai_chatstream(ai#, "Write a haiku about programming")

' Get the complete response after streaming
let full$ = ai_streambuffer$(ai#)
println "Total length: " + str$(len(full$)) + " characters"

ai_free(ai#)
```

### Example 3: Multi-Turn Conversation

```basic
' Maintain a conversation with history management
println "=== Conversation Demo ==="
println ""

let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 1024)

let conv# = ai_conversation#()
ai_conversation_system#(conv#, "You are a patient math tutor. Give short, clear explanations.")
ai_conversation_maxhistory#(conv#, 10)

' First question
let r$ = ai_ask$(ai#, conv#, "What is a prime number?")
println "Q: What is a prime number?"
println "A: " + r$
println ""

' Follow-up (AI remembers context)
let r$ = ai_ask$(ai#, conv#, "Is 17 a prime number? Why?")
println "Q: Is 17 a prime number?"
println "A: " + r$
println ""

' Check conversation state
println "Messages in history: " + str$(ai_conversation_count(conv#))
println "Estimated tokens: " + str$(ai_conversation_tokens(conv#))

ai_conversation_free(conv#)
ai_free(ai#)
```

### Example 4: Multiple Providers

```basic
' Compare responses from different AI providers
println "=== Multi-Provider Comparison ==="
println ""

let question$ = "In one sentence, what is recursion?"

' Try Anthropic
let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_maxtokens#(ai#, 100)
let reply$ = ai_chat$(ai#, question$)
println "Claude: " + reply$
ai_free(ai#)
println ""

' Try OpenAI
let ai# = ai_client#("openai", "sk-xxxxx")
ai_maxtokens#(ai#, 100)
let reply$ = ai_chat$(ai#, question$)
println "GPT: " + reply$
ai_free(ai#)
println ""

' Try local Ollama
let ai# = ai_client#("ollama", "")
ai_model#(ai#, "llama3")
ai_maxtokens#(ai#, 100)
let reply$ = ai_chat$(ai#, question$)
println "Llama: " + reply$
ai_free(ai#)
```

### Example 5: Error Handling and Diagnostics

```basic
' Comprehensive error handling example
println "=== Error Handling Demo ==="
println ""

let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 512)
ai_timeout#(ai#, 30)

let reply$ = ai_chat$(ai#, "Hello!")

if ai_ok(ai#) = 1 then
    println "Success!"
    println "Response: " + reply$
    println ""
    println "HTTP Status: " + str$(ai_status(ai#))
    println "Tokens In: " + str$(ai_tokensin(ai#))
    println "Tokens Out: " + str$(ai_tokensout(ai#))
    println "Provider: " + ai_provider$(ai#)
    println "Model: " + ai_model$(ai#)
else
    println "Request failed!"
    println "Error Code: " + str$(ai_error())
    println "Error Name: " + ai_strerror$(ai_error())
    println "Error Message: " + ai_errormsg$()
    println "HTTP Status: " + str$(ai_status(ai#))
endif

ai_free(ai#)
```

### Example 6: Code Generation with System Prompt

```basic
' Use the AI to generate Plan9Basic code
println "=== Code Generation ==="
println ""

let ai# = ai_client#("anthropic", "sk-ant-xxxxx")
ai_model#(ai#, "claude-sonnet-4-20250514")
ai_maxtokens#(ai#, 2048)

let system$ = "You are a Plan9Basic code generator. "
system$ = system$ + "Return ONLY valid Plan9Basic code with comments, no explanation. "
system$ = system$ + "Use println for output, let for variables, for/next for loops."

let code$ = ai_completesystem$(ai#, system$, "Create a program that prints a multiplication table for 1-5")

if ai_ok(ai#) = 1 then
    println "Generated code:"
    println "---"
    println code$
    println "---"
else
    println "Generation failed: " + ai_errormsg$()
endif

ai_free(ai#)
```

---

## Quick Reference

### Error Handling
```basic
ai_error()                           ' Last error code (0 = none)
ai_errormsg$()                       ' Last error message
ai_strerror$(code)                   ' Error code to string
ai_clearerror()                      ' Clear error state
```

### Client Lifecycle
```basic
ai_client#(provider$, key$)          ' Create AI client
ai_free(ai#)                         ' Free client
```

### Configuration
```basic
ai_model#(ai#, model$)              ' Set model
ai_model$(ai#)                       ' Get model name
ai_system#(ai#, prompt$)            ' Set system prompt
ai_temperature#(ai#, value)          ' Set temperature (0.0-2.0)
ai_maxtokens#(ai#, tokens)          ' Set max output tokens
ai_topp#(ai#, value)                ' Set top-p (0.0-1.0)
ai_timeout#(ai#, seconds)           ' Set timeout
ai_baseurl#(ai#, url$)              ' Set custom base URL
ai_baseurl$(ai#)                     ' Get base URL
ai_stop#(ai#, sequence$)            ' Add stop sequence
ai_clearstop#(ai#)                  ' Clear stop sequences
```

### Custom Headers
```basic
ai_header#(ai#, name$, value$)      ' Add header
ai_headerremove#(ai#, name$)        ' Remove header
ai_headerclear#(ai#)                ' Clear all headers
```

### Identity
```basic
ai_apikey#(ai#, key$)               ' Change API key
ai_endpoint#(ai#, path$)            ' Set endpoint path
ai_useragent#(ai#, agent$)          ' Set User-Agent
ai_provider$(ai#)                    ' Get provider name
```

### Simple Chat
```basic
ai_chat$(ai#, message$)             ' Chat (keeps history)
ai_clearchat(ai#)                    ' Clear chat history
```

### Streaming
```basic
ai_ontoken#(ai#, callback$)         ' Set stream callback
ai_chatstream(ai#, message$)        ' Stream a message
ai_streambuffer$(ai#)                ' Get full streamed text
```

### Single-Shot Completion
```basic
ai_complete$(ai#, prompt$)           ' One-shot completion
ai_completesystem$(ai#, sys$, msg$)  ' One-shot with system prompt
```

### Conversation Management
```basic
ai_conversation#()                    ' Create conversation
ai_conversation_free(conv#)           ' Free conversation
ai_conversation_system#(conv#, sys$)  ' Set system prompt
ai_conversation_clear(conv#)          ' Clear messages
ai_conversation_maxhistory#(conv#, n) ' Set max history
ai_ask$(ai#, conv#, message$)         ' Chat with conversation
ai_conversation_count(conv#)          ' Message count
ai_conversation_last$(conv#)          ' Last message text
ai_conversation_tokens(conv#)         ' Estimated token count
```

### Response Metadata
```basic
ai_status(ai#)                       ' HTTP status code
ai_body$(ai#)                        ' Raw response JSON
ai_tokensin(ai#)                     ' Input tokens used
ai_tokensout(ai#)                    ' Output tokens used
ai_ok(ai#)                           ' 1 if success (HTTP 200)
```

---

### All Registered Functions (Alphabetical)

| Function | Signature | Description |
|----------|-----------|-------------|
| `ai_apikey#` | `ai_apikey#@#$` | Change API key |
| `ai_ask$` | `ai_ask$@##$` | Chat with conversation |
| `ai_baseurl#` | `ai_baseurl#@#$` | Set custom base URL |
| `ai_baseurl$` | `ai_baseurl$@#` | Get base URL |
| `ai_body$` | `ai_body$@#` | Raw response JSON body |
| `ai_chat$` | `ai_chat$@#$` | Send message, get response |
| `ai_chatstream` | `ai_chatstream@#$` | Stream a message |
| `ai_clearchat` | `ai_clearchat@#` | Clear internal chat history |
| `ai_clearerror` | `ai_clearerror@` | Clear error state |
| `ai_clearstop#` | `ai_clearstop#@#` | Clear stop sequences |
| `ai_client#` | `ai_client#@$$` | Create AI client |
| `ai_complete$` | `ai_complete$@#$` | Single-shot completion |
| `ai_completesystem$` | `ai_completesystem$@#$$` | Completion with system prompt |
| `ai_conversation#` | `ai_conversation#@` | Create conversation |
| `ai_conversation_clear` | `ai_conversation_clear@#` | Clear conversation messages |
| `ai_conversation_count` | `ai_conversation_count@#` | Conversation message count |
| `ai_conversation_free` | `ai_conversation_free@#` | Free conversation |
| `ai_conversation_last$` | `ai_conversation_last$@#` | Last message text |
| `ai_conversation_maxhistory#` | `ai_conversation_maxhistory#@#n` | Set max history size |
| `ai_conversation_system#` | `ai_conversation_system#@#$` | Set conversation system prompt |
| `ai_conversation_tokens` | `ai_conversation_tokens@#` | Estimated token count |
| `ai_endpoint#` | `ai_endpoint#@#$` | Set endpoint path |
| `ai_error` | `ai_error@` | Last error code |
| `ai_errormsg$` | `ai_errormsg$@` | Last error message |
| `ai_free` | `ai_free@#` | Free AI client |
| `ai_header#` | `ai_header#@#$$` | Add custom header |
| `ai_headerclear#` | `ai_headerclear#@#` | Clear all headers |
| `ai_headerremove#` | `ai_headerremove#@#$` | Remove custom header |
| `ai_maxtokens#` | `ai_maxtokens#@#n` | Set max output tokens |
| `ai_model#` | `ai_model#@#$` | Set model |
| `ai_model$` | `ai_model$@#` | Get model name |
| `ai_ok` | `ai_ok@#` | 1 if last request succeeded |
| `ai_ontoken#` | `ai_ontoken#@#$` | Set stream callback |
| `ai_provider$` | `ai_provider$@#` | Get provider name |
| `ai_status` | `ai_status@#` | HTTP status code |
| `ai_stop#` | `ai_stop#@#$` | Add stop sequence |
| `ai_streambuffer$` | `ai_streambuffer$@#` | Get full streamed text |
| `ai_strerror$` | `ai_strerror$@n` | Error code to string |
| `ai_system#` | `ai_system#@#$` | Set system prompt |
| `ai_temperature#` | `ai_temperature#@#n` | Set temperature |
| `ai_timeout#` | `ai_timeout#@#n` | Set request timeout |
| `ai_tokensin` | `ai_tokensin@#` | Input tokens used |
| `ai_tokensout` | `ai_tokensout@#` | Output tokens used |
| `ai_topp#` | `ai_topp#@#n` | Set top-p parameter |
| `ai_useragent#` | `ai_useragent#@#$` | Set User-Agent header |

---

## Notes and Best Practices

### Choosing a Chat Mode

AILib offers three ways to talk to an AI. Choose based on your needs:

- **`ai_chat$`** — simplest option, keeps history automatically. Good for interactive chatbots.
- **`ai_complete$` / `ai_completesystem$`** — stateless, each call is independent. Good for classification, summarization, code generation, and other one-off tasks.
- **`ai_ask$` with `ai_conversation#`** — full control over history, system prompt, and token management. Good for complex multi-conversation applications.

### Token Awareness

AI API calls are billed per token. Use `ai_tokensin()` and `ai_tokensout()` to monitor usage. Set `ai_maxtokens#` to limit response length and `ai_conversation_maxhistory#` to prevent conversation history from growing unbounded.

### Error Recovery

Always check `ai_ok()` or `ai_error()` after API calls. Network errors (code 5), timeouts (code 6), and rate limits (code 9) are transient — your program can retry after a brief wait.

### Local Models

For development and testing without API costs, use local model providers like Ollama, LM Studio, or Jan. They use the same AILib functions — just change the provider name:

```basic
let ai# = ai_client#("ollama", "")
ai_model#(ai#, "llama3")
```

---

## See Also

- **P9EngineLib** - Intelligence Engine for AI-powered code generation
- **RAGLib** - Knowledge base retrieval for enriching AI prompts
- **SkillLib** - Skill templates for structured code generation
- **JsonLib** - JSON parsing for processing raw API responses
- **HttpLib** - Low-level HTTP for custom API integration

---

*End of AILib Documentation*
