# JSON Literal Support - Parser Modification Design

## Overview

This document describes the modifications needed to the Plan9Basic parser to support JSON literal syntax directly in assignments.

## Proposed Syntax

### JSON Array Literals
```basic
LET json# = [10, 20, 30]
LET json# = ["hello", "world"]
LET json# = [10, "text", name$, age, [nested, array]]
LET json# = [true, false, null]
```

### JSON Object Literals
```basic
LET json# = {"name": "John", "age": 30}
LET json# = {"user": name$, "score": score}
LET json# = {"nested": {"inner": "value"}}
LET json# = {"items": [1, 2, 3]}
```

### Mixed Usage
```basic
LET name$ = "John Doe"
LET age = 34
LET json# = {"name": name$, "age": age, "hobbies": ["reading", "coding"]}
```

## Parser Modification Strategy

### 1. Detection Point

The JSON literal syntax should be detected in `AssignPtr()` method. After the `=` sign, if the next token is:
- `btkSquareOpen` (`[`) → Parse as JSON array literal
- `btkCurlyOpen` (`{`) → Parse as JSON object literal

### 2. New Parser Methods

Add the following methods to `TBasicParser`:

```pascal
private
  // JSON literal parsing
  procedure ParseJsonLiteral();        // Entry point - detects array or object
  procedure ParseJsonArray();          // Parses [...] 
  procedure ParseJsonObject();         // Parses {...}
  procedure ParseJsonValue();          // Parses a single JSON value (recursive)
```

### 3. Modified `AssignPtr()` Method

Current flow:
```pascal
procedure TBasicParser.AssignPtr();
begin
  // ... existing code to get variable name
  lexer.Advance(); // skip '='
  NextPointerExpression();  // <-- Current: expects pointer expression
  // ...
end;
```

Modified flow:
```pascal
procedure TBasicParser.AssignPtr();
begin
  // ... existing code to get variable name
  lexer.Advance(); // skip '='
  
  // NEW: Check for JSON literal syntax
  case lexer.CurrTok() of
    btkSquareOpen: ParseJsonArray();   // JSON array literal [...]
    btkCurlyOpen:  ParseJsonObject();  // JSON object literal {...}
  else
    NextPointerExpression();           // Regular pointer expression
  end;
  // ...
end;
```

### 4. Intermediate Code Generation

The JSON parsing methods will emit intermediate code that builds the JSON structure at runtime.

#### JSON Array Example

Input:
```basic
LET json# = [10, "hello", name$]
```

Generated intermediate code:
```
CALLEX# "json_array#@"          ; Create empty array
PUSHC 10                        ; Push literal 10
CALLEX# "json_pushn#@#n"        ; Append number
PUSHCS "hello"                  ; Push literal "hello"
CALLEX# "json_pushs#@#$"        ; Append string
PUSH$ @name$                    ; Push variable name$
CALLEX# "json_pushs#@#$"        ; Append string
POPSTORE# @json#                ; Store in json#
```

#### JSON Object Example

Input:
```basic
LET json# = {"name": "John", "age": 30}
```

Generated intermediate code:
```
CALLEX# "json_object#@"         ; Create empty object
PUSHCS "name"                   ; Push key "name"
PUSHCS "John"                   ; Push value "John"
CALLEX# "json_sets#@#$$"        ; Set string property
PUSHCS "age"                    ; Push key "age"
PUSHC 30                        ; Push value 30
CALLEX# "json_setn#@#$n"        ; Set number property
POPSTORE# @json#                ; Store in json#
```

### 5. Implementation Details

#### `ParseJsonArray()` Method

```pascal
procedure TBasicParser.ParseJsonArray();
begin
  // Emit code to create empty JSON array
  Emmit('CALLEX# "json_array#@"');
  
  lexer.Advance(); // Skip '['
  
  // Handle empty array []
  if lexer.CurrTok() = btkSquareClose then
  begin
    lexer.Advance(); // Skip ']'
    Exit;
  end;
  
  // Parse first element
  ParseJsonValue();
  
  // Parse remaining elements
  while lexer.CurrTok() = btkComma do
  begin
    lexer.Advance(); // Skip ','
    ParseJsonValue();
  end;
  
  // Expect closing bracket
  if lexer.CurrTok() <> btkSquareClose then
    SetError('] expected');
  lexer.Advance(); // Skip ']'
end;
```

#### `ParseJsonObject()` Method

```pascal
procedure TBasicParser.ParseJsonObject();
var
  keyStr: String;
begin
  // Emit code to create empty JSON object
  Emmit('CALLEX# "json_object#@"');
  
  lexer.Advance(); // Skip '{'
  
  // Handle empty object {}
  if lexer.CurrTok() = btkCurlyClose then
  begin
    lexer.Advance(); // Skip '}'
    Exit;
  end;
  
  // Parse first key-value pair
  ParseJsonKeyValue();
  
  // Parse remaining pairs
  while lexer.CurrTok() = btkComma do
  begin
    lexer.Advance(); // Skip ','
    ParseJsonKeyValue();
  end;
  
  // Expect closing brace
  if lexer.CurrTok() <> btkCurlyClose then
    SetError('} expected');
  lexer.Advance(); // Skip '}'
end;

procedure TBasicParser.ParseJsonKeyValue();
var
  keyStr: String;
begin
  // Key must be a string literal (for now)
  if lexer.CurrTok() <> btkString then
    SetError('String key expected');
  
  keyStr := lexer.CurrS();
  Emmit('PUSHCS "' + EscapeString(keyStr) + '"');  // Push key
  
  lexer.Advance(); // Skip key
  
  // Expect colon
  if lexer.CurrTok() <> btkColon then
    SetError(': expected after key');
  lexer.Advance(); // Skip ':'
  
  // Parse value and emit appropriate set function
  ParseJsonObjectValue(keyStr);
end;
```

#### `ParseJsonValue()` Method (for array elements)

```pascal
procedure TBasicParser.ParseJsonValue();
begin
  case lexer.CurrTok() of
    btkSquareOpen:  // Nested array
    begin
      ParseJsonArray();
      Emmit('CALLEX# "json_push#@##"');  // Push JSON value
    end;
    
    btkCurlyOpen:   // Nested object
    begin
      ParseJsonObject();
      Emmit('CALLEX# "json_push#@##"');  // Push JSON value
    end;
    
    btkString:      // String literal
    begin
      Emmit('PUSHCS "' + EscapeString(lexer.CurrS()) + '"');
      Emmit('CALLEX# "json_pushs#@#$"');
      lexer.Advance();
    end;
    
    btkInteger, btkFloat:  // Numeric literal
    begin
      Emmit('PUSHC ' + lexer.CurrS());
      Emmit('CALLEX# "json_pushn#@#n"');
      lexer.Advance();
    end;
    
    btkIdentifier:  // Variable (numeric) or keyword
    begin
      if UpperCase(lexer.CurrS()) = 'TRUE' then
      begin
        Emmit('PUSHC 1');
        Emmit('CALLEX# "json_pushb#@#n"');
      end
      else if UpperCase(lexer.CurrS()) = 'FALSE' then
      begin
        Emmit('PUSHC 0');
        Emmit('CALLEX# "json_pushb#@#n"');
      end
      else if UpperCase(lexer.CurrS()) = 'NULL' then
      begin
        Emmit('CALLEX# "json_pushnull#@#"');
      end
      else
      begin
        // Numeric variable
        Emmit('PUSH @' + lexer.CurrS().ToLower());
        Emmit('CALLEX# "json_pushn#@#n"');
      end;
      lexer.Advance();
    end;
    
    btkStrIdentifier:  // String variable
    begin
      Emmit('PUSH$ @' + lexer.CurrS().ToLower());
      Emmit('CALLEX# "json_pushs#@#$"');
      lexer.Advance();
    end;
    
    btkPointerIdentifier:  // Pointer variable (nested JSON)
    begin
      Emmit('PUSH# @' + lexer.CurrS().ToLower());
      Emmit('CALLEX# "json_push#@##"');
      lexer.Advance();
    end;
    
    else
      SetError('Invalid JSON value');
  end;
end;
```

### 6. Lexer Considerations

The existing lexer already has tokens for:
- `btkSquareOpen` and `btkSquareClose` for `[` and `]`
- `btkCurlyOpen` and `btkCurlyClose` for `{` and `}`
- `btkColon` for `:`
- `btkComma` for `,`

However, we may need to add recognition for JSON-specific keywords:

```pascal
// In BasIdentKind, add:
// HashCode for 'TRUE', 'FALSE', 'NULL'
// These could be new tokens: btkTrue, btkFalse, btkJsonNull
```

Alternatively, we can handle these as identifiers in the parser and check the string value.

### 7. Special Considerations

#### String Escaping
When emitting string literals for intermediate code, we need to properly escape special characters:
- `"` → `\"`
- `\` → `\\`
- Newlines → `\n`

#### Nested Structures
The recursive nature of `ParseJsonValue()` naturally handles nested arrays and objects.

#### Variable Interpolation
Variables in JSON literals are evaluated at runtime. The parser emits code to:
1. Push the variable value onto the stack
2. Call the appropriate JSON function to add it to the structure

#### Error Handling
- Unclosed brackets/braces
- Missing colons in objects
- Invalid value types
- Malformed key-value pairs

### 8. Testing Strategy

#### Basic Tests
```basic
' Empty structures
LET arr# = []
LET obj# = {}

' Simple values
LET arr# = [1, 2, 3]
LET obj# = {"a": 1, "b": 2}

' String values
LET arr# = ["hello", "world"]
LET obj# = {"greeting": "hello"}

' Mixed types
LET arr# = [1, "two", 3.14]
```

#### Variable Interpolation Tests
```basic
LET name$ = "John"
LET age = 30
LET arr# = [name$, age]
LET obj# = {"name": name$, "age": age}
```

#### Nesting Tests
```basic
LET arr# = [[1, 2], [3, 4]]
LET obj# = {"inner": {"a": 1}}
LET mixed# = {"arr": [1, 2, 3], "obj": {"x": 10}}
```

#### Boolean and Null Tests
```basic
LET arr# = [true, false, null]
LET obj# = {"active": true, "data": null}
```

### 9. Implementation Phases

#### Phase 1: Basic JSON Library (DONE)
- Create JsonLib.pas with all manipulation functions
- Test with string-based JSON creation

#### Phase 2: Parser - Array Literals
- Implement `ParseJsonArray()`
- Implement `ParseJsonValue()` for arrays
- Test array literal syntax

#### Phase 3: Parser - Object Literals
- Implement `ParseJsonObject()`
- Implement `ParseJsonKeyValue()`
- Test object literal syntax

#### Phase 4: Integration
- Modify `AssignPtr()` to detect and route to JSON parsing
- Full integration testing
- Documentation update

### 10. Alternative Approach: Simplified First Implementation

If the full parser modification proves complex, a simpler first approach could be:

1. Use a special function syntax:
```basic
LET json# = json_literal#("[10, 20, 30]")
LET json# = json_literal#('{"name": "John"}')
```

This would:
- Avoid parser changes initially
- Allow string interpolation via concatenation
- Still provide the convenience of JSON syntax

However, this is less elegant than native syntax support.

## Conclusion

The native JSON literal syntax integration is achievable with moderate parser modifications. The key insight is that JSON parsing can reuse much of the existing expression parsing infrastructure, with the addition of specific handling for JSON-specific constructs like key-value pairs and the recognition of `true`, `false`, and `null` literals.

The recommended implementation order is:
1. Complete and test JsonLib.pas
2. Add array literal support
3. Add object literal support
4. Comprehensive integration testing
