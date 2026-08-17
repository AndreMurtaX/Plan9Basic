# Plan9Basic - Naming Conventions

## Unit Naming Standard

All units in the Plan9Basic project follow this naming convention:

```
Unit<Functionality>.pas
```

### Examples

| Unit Name | Purpose |
|-----------|---------|
| `UnitMain.pas` | Main form and application entry point |
| `UnitUtils.pas` | Utility functions and helpers |

### Core Interpreter Units (Exceptions)

The following units are part of the core interpreter and do not follow the `Unit` prefix convention for historical reasons and clarity:

| Unit Name | Purpose |
|-----------|---------|
| `lexer.pas` | Lexical analyzer (tokenizer) |
| `parser.pas` | Syntax parser and compiler |
| `exec.pas` | Virtual machine (executor) |

### Future Units

When adding new units to the project, use the `Unit<Functionality>.pas` pattern:

- `UnitEditor.pas` - Code editor component
- `UnitDebugger.pas` - Debugging functionality
- `UnitHighlighter.pas` - Syntax highlighting
- `UnitProject.pas` - Project management
- `UnitLibMath.pas` - Math library functions
- `UnitLibString.pas` - String library functions
- `UnitLibGraphics.pas` - Graphics library functions

---

## Variable Naming

### Hungarian-style Prefixes (Optional)

| Prefix | Type | Example |
|--------|------|---------|
| `F` | Private field | `FErrorMessage` |
| `p` | Pointer | `pSource` |
| `s` | String | `sCaption` |
| `n` | Number | `nCount` |
| `i` | Integer/Index | `idx`, `iVal` |
| `dt` | Data record | `dt: TAsmData` |
| `tk` | Token | `tk: TBasToken` |

### Constants

- Use UPPERCASE with underscores
- Examples: `MAXSTACK`, `MAX_INTEGER_VALUE`, `DEFAULT_TIMEOUT`

### Types

- Prefix with `T` for types
- Prefix with `E` for exceptions
- Examples: `TBasicLexer`, `TAsmToken`, `TExprKind`

---

## Class Naming

| Pattern | Purpose | Example |
|---------|---------|---------|
| `TBasic*` | BASIC language related | `TBasicLexer`, `TBasicParser` |
| `TAsm*` | Assembly/VM related | `TAsmLexer`, `TAsmToken` |
| `TExec` | Executor/VM | `TExec` |
| `TCompiler` | Compiler class | `TCompiler` |

---

## Function Signatures (Plan9Basic)

User-defined functions use signature format: `name@params`

| Suffix | Type | Example |
|--------|------|---------|
| `@` | No parameters | `init@` |
| `@n` | One numeric | `sin@n` |
| `@$` | One string | `len@$` |
| `@#` | One pointer | `free@#` |
| `@nn` | Two numerics | `pow@nn` |
| `@$n` | String + numeric | `left$@$n` |

Return type indicated by function name suffix:
- `func(...)` → returns number
- `func$(...)` → returns string  
- `func#(...)` → returns pointer

---

*Last Updated: Phase 4*
