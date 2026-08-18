# Plan9Basic - Quick Start Guide

## 📁 Project Overview

**Plan9Basic** is a modern BASIC interpreter built with Delphi/FireMonkey for cross-platform applet development (Windows, macOS, Linux, Android, iOS).

---

## 🔧 How to Build

### Clone recursively

The interpreter core and the shared standard library live in a separate
repository, [Plan9BasicEngine](https://github.com/AndreMurtaX/Plan9BasicEngine),
and are pulled in as a git submodule under `engine/`. Clone recursively, or the
`engine/` folder arrives empty and the build fails on the first unit:

```bash
git clone --recurse-submodules <repository-url>
```

Already cloned without it? Fix an existing checkout with:

```bash
git submodule update --init --recursive
```

### Build

1. Open **RAD Studio / Delphi** (version 10.3 Rio or later recommended)
2. Open the project file: `Plan9Basic.dpr`
3. Select your target platform (Win32, Win64, macOS, Android, etc.)
4. Press **F9** to compile and run, or **Ctrl+Shift+F9** for build only

From the command line, no search paths or environment setup are needed — every
unit is referenced with its path from the `.dpr`, including the ones inside
`engine/`:

```bash
dcc64 Plan9Basic.dpr
```

### Build Configurations
- **Debug**: Memory leak reporting enabled on Windows
- **Release**: Optimized for distribution

### Tests

`tests/build.ps1 -Run` compiles and runs the automated suite; add `-Gui` for the
FMX libraries. See [tests/README.md](tests/README.md).

---

## 📦 Project Entry Points

| File | Description |
|------|-------------|
| `Plan9Basic.dpr` | **Main project file** - The interpreter/IDE application |
| `UnitMain.pas` | Main form with editor, output, and file manager |

> **Note**: Currently there is a single executable that serves as both the interpreter engine and the development environment (IDE).

---

## 🔗 External Dependencies

### Required
| Dependency | Purpose | Notes |
|------------|---------|-------|
| **FireMonkey (FMX)** | Cross-platform GUI framework | Included with Delphi |
| **FireDAC** | Database access (for SQLiteLib) | Included with Delphi |

### Optional / Runtime
| Dependency | Purpose | Notes |
|------------|---------|-------|
| **SQLite** | Database operations via SQLiteLib | System library or bundled DLL |
| **Network access** | HTTP operations via HttpLib | System sockets |

### Translation File
- `Translations.ini` - Required for UI localization (placed in app directory or Documents folder on mobile)

---

## 🛤️ Main Code Paths

### Path 1: Source Code → Tokenization → Parsing
```
[BASIC Source Code]
       ↓
   lexer.pas         → Tokenizer: converts source to TBasToken stream
       ↓
   parser.pas        → Parser: validates syntax, generates postfix code
       ↓
[Intermediate Code (Postfix)]
```

### Path 2: Intermediate Code → Execution
```
[Intermediate Code]
       ↓
   parser.pas        → ProcessPostfixCode: generates assembly (TAsmToken)
       ↓
   exec.pas          → TExec: Stack machine executes instructions
       ↓
[Program Output / GUI]
```

### Path 3: Library Functions → Runtime
```
   *Lib.pas files    → Define native functions (TBindFunction signature)
       ↓
   Register*Funcs()  → Registers functions in TFunctionsDictionary
       ↓
   exec.pas          → VM calls functions via atkCallFar instruction
       ↓
[Result returned via TAsmData]
```

---

## 🏗️ Architecture Summary

```
┌─────────────────────────────────────────────────────────────────┐
│                        Plan9Basic.dpr                           │
│                     (Main Application)                          │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  UnitMain.pas (IDE Interface)                                   │
│  ├── Code Editor (FrameMemoLineCount)                           │
│  ├── Output Panel                                               │
│  └── File Manager                                               │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  basic.pas (TBasicEngine - Main Interface)                      │
│  ├── Compile()        → Parse and generate code                 │
│  ├── ExecuteProgram() → Run entire program                      │
│  └── ExecuteUserFunction() → Call specific function             │
└─────────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│    lexer.pas     │ │    parser.pas    │ │     exec.pas     │
│  (Tokenizer)     │ │   (Parser/       │ │  (Stack Machine) │
│                  │ │    Compiler)     │ │                  │
│ TBasicLexer      │ │ TBasicParser     │ │ TExec            │
│ - LoadProg()     │ │ - Compile()      │ │ - LoadSource()   │
│ - Advance()      │ │ - ProcessPostfix │ │ - ExecuteProgram │
│ - CurrTok()      │ │                  │ │                  │
└──────────────────┘ └──────────────────┘ └──────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  Libraries (100+ *Lib.pas files)                                │
│  ├── Core: StdLib, StrLib, NumLib, ArrayLib, DateTimeLib...     │
│  ├── I/O: IOUtilsLib, ConfigLib, JsonLib, HttpLib, SQLiteLib... │
│  ├── GUI Controls: FormLib, ButtonLib, LabelLib, EditLib...     │
│  ├── Effects: BlurEffectLib, GlowEffectLib, ShadowEffectLib...  │
│  └── Animations: FloatAnimationLib, ColorAnimationLib...        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  UnitGC.pas (Garbage Collector)                                 │
│  - Manages memory for BASIC-created objects                     │
│  - Tag-based collection system                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📂 Key Source Files

| File | Purpose |
|------|---------|
| `lexer.pas` | Tokenizer - breaks source into tokens |
| `parser.pas` | Parser - validates syntax, generates intermediate code |
| `exec.pas` | Stack machine VM - executes compiled code |
| `basic.pas` | TBasicEngine - main API for compiling and running programs |
| `UnitUtils.pas` | Utility functions and type helpers |
| `UnitGC.pas` | Garbage collector for managed objects |
| `UnitMain.pas` | Main form / IDE interface |

---

## 📚 Library Organization

```
Libs/
├── Core Libraries
│   ├── StdLib.pas          Standard functions (pause, classname, etc.)
│   ├── NumLib.pas          Math functions (sin, cos, sqrt, etc.)
│   ├── StrLib.pas          String manipulation (47+ functions)
│   ├── ArrayLib.pas        Dynamic arrays
│   ├── DictLib.pas         Key-value dictionaries
│   └── DateTimeLib.pas     Date/time operations (63 functions)
│
├── I/O Libraries
│   ├── IOUtilsLib.pas      File system operations
│   ├── ConfigLib.pas       INI-style configuration
│   ├── JsonLib.pas         JSON parsing/generation
│   ├── HttpLib.pas         HTTP client operations
│   └── SQLiteLib.pas       SQLite database access
│
├── GUI/ (FireMonkey Controls)
│   ├── FormLib.pas         Windows/Forms
│   ├── ButtonLib.pas       Buttons
│   ├── LabelLib.pas        Labels
│   ├── EditLib.pas         Text input
│   ├── MemoLib.pas         Multi-line text
│   ├── ListBoxLib.pas      List boxes
│   └── ... (20+ control libraries)
│
├── GUI/Effects/
│   ├── BlurEffectLib.pas   Blur effects
│   ├── GlowEffectLib.pas   Glow effects
│   └── ... (40+ effect libraries)
│
└── GUI/Animations/
    ├── FloatAnimationLib.pas
    ├── ColorAnimationLib.pas
    └── ... (6 animation libraries)
```

---

## 🔑 Key Types (exec.pas)

```pascal
// Data cell for stack operations and function parameters
TAsmData = record
  n: Extended;    // Numeric value
  p: Pointer;     // Pointer value
  s: String;      // String value
end;

// Function signature for library bindings
TBindFunction = function(var Args: Array of TAsmData): TAsmData;

// Function registration format: "name@params" or "name$@params" or "name#@params"
// Where: $ = returns string, # = returns pointer, (none) = returns number
// Params: n = number, $ = string, # = pointer
// Example: "strlen@$" = strlen(string) returns number
```

---

## 📝 Quick Example

```basic
rem Hello World in Plan9Basic
println "Hello, World!"

rem Variables
name$ = "Plan9Basic"
version = 1.0
println "Welcome to " + name$ + "!"

rem Function example
function square(x) local result
  result = x * x
  return result
endfunction

println "5 squared = " + str$(square(5))
```

---

## 🐛 Debugging Commands

Plan9Basic includes built-in debugging support through three commands:

### Commands Overview

| Command | Description |
|---------|-------------|
| `TRACEON` | Enables trace mode - outputs each line executed to console |
| `TRACEOFF` | Disables trace mode |
| `BREAKPOINT` | Reports the current state, and pauses where the host can (only when trace mode is ON) |

### TRACEON / TRACEOFF

```basic
traceon                     ' Enable tracing
' ... your code here ...
traceoff                    ' Disable tracing
```

**Trace Output:**
```
[TRACE] Trace mode enabled
[TRACE] Line 5 | IP=23
[TRACE] Line 6 | IP=27
```

### BREAKPOINT

Reports the current state, and on desktop pauses until you answer. **Only active when trace mode is enabled.**

```basic
breakpoint                                    ' Simple breakpoint
breakpoint "checkpoint reached"               ' With message
breakpoint "loop iteration", i, sum, name$    ' With message and variables
```

The frame carries:
- Current line number
- Optional message
- Variable values (numeric, string, and pointer variables supported)

**On Windows, macOS and Linux** a dialog appears:
- **Yes** - Continue execution
- **No** - Stop execution immediately

The frame also goes to the output, on every platform, so the trace keeps the
values after the dialog is gone:

```
[BREAKPOINT] checkpoint reached (Line 25)
             n = 7
             s$ = "frame"
```

Pausing requires the answer to reach a thread the VM has already blocked, and
those platforms deliver it through the looper that called into the application
in the first place — a paused VM would be blocking the very mechanism meant to
wake it. The same fallback applies to any host that installs no `ConfirmProc`,
such as the headless test runner.

### Debugging Example

```basic
let counter = 0
let name$ = "Test"

traceon                     ' Enable debugging

for i = 1 to 5
    counter = counter + 10
    breakpoint "Loop check", i, counter, name$
next

traceoff
println "Done! Counter = "; counter
end
```

### Best Practices

1. **Leave breakpoints in production code** - They're ignored when trace mode is off
2. **Use conditional debugging:**
   ```basic
   let debugMode = 1
   if debugMode = 1 then traceon
   ' ... your code ...
   if debugMode = 1 then traceoff
   ```
3. **Limit trace scope** - Use `TRACEON`/`TRACEOFF` around specific sections to avoid output flood
4. **Timer handling** - All timers automatically pause during breakpoints and resume on continue

### Limitations

- Only **global variables** can be watched (local function variables not accessible)
- No step-by-step execution (use multiple breakpoints)
- No conditional breakpoints (use IF statements instead)

---

## ⚠️ Important Notes

1. **Pointer initialization**: Always use `Pointer#(0)` to initialize pointer variables
2. **Boolean expressions**: Only valid inside IF/WHILE/DO/UNTIL - use numeric comparisons elsewhere
3. **Array indexing**: Arrays are 1-based; strings are 0-based
4. **Local variables**: Must be declared on the same line as FUNCTION using `local` keyword
5. **str$ vs stri$**: `str$` uses locale (comma in Brazil), `stri$` is invariant (period)

---

## 📖 More Information

- Check individual `*Lib.pas` files for function documentation
- See `UnitMain.pas` for IDE implementation details
- Review `parser.pas` for language syntax rules

---

*Last updated: January 2026*
