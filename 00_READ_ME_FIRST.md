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

### Where a change belongs, and how far it travels

The tree spans three repositories, and which one a file sits in decides who has
to be updated when you touch it. This is easy to get wrong, because `engine/`
looks like an ordinary folder.

| Path | Repository | Reaches |
|---|---|---|
| `engine/**` | Plan9BasicEngine (public) | this IDE **and** the applet runner |
| `Libs/GUI/**` | Plan9Basic (this one) | this IDE only |
| `Libs/**` outside `GUI/` | Plan9Basic (this one) | this IDE only |
| everything else at the root | Plan9Basic (this one) | this IDE only |

**A change under `engine/` is not finished when it compiles here.** It has to be
committed and pushed in the submodule, then the pointer bumped in *both*
consumers -- this repository and
[Plan9BasicAppletRunner](https://github.com/AndreMurtaX/Plan9BasicAppletRunner)
-- or the runner keeps building against the previous commit and quietly
diverges.

```bash
cd engine && git commit -am "..." && git push    # the engine itself
cd ..      && git add engine && git commit       # this repository's pointer
# then, in the runner checkout:
cd engine && git pull && cd .. && git add engine && git commit
```

The trap worth naming: `Libs/GUI/` holds a hundred control, effect and animation
libraries and looks like the home of everything GUI, but **one** GUI library
lives in the engine instead -- `engine/Libs/GUI/TimerLib.pas`, because
`exec.pas` depends on it. A sweep across "the GUI libraries" that globs
`Libs/GUI/*.pas` misses exactly that one, and it is the only one of the hundred
that ships in the public repositories. Sweep both paths, or the exception ends
up in the half other people build on.

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

### Checking the documentation against the code

The library surface is registered in exactly one place -- the `Lib.Add` calls
that bind a native function to a signature -- and the reference pages under
`New docs/` write their calls the same way, so the two can be compared:

```bash
python tools/check-docs.py
```

It reports a documented function that is not registered, and a documented call
whose arguments no registered overload accepts, and exits non-zero on either.
`Changelogs/` is scanned but never fails the run: a page describing what a
release did is not promising the function still exists.

Undocumented functions are counted, never a failure -- silence misleads nobody.
Run with `--undocumented` to list them.

That checks the shape of what is documented, not the truth of it. The pages also
assert results -- ``left$("Hello", 3)`` yields ``"Hel"`` -- and those can be
typed back into the interpreter:

```bash
python tools/gen-doc-examples.py
```

It regenerates `tests/suite/16_doc_examples.bas` from every self-contained claim
in both generations of documentation, so the ordinary test run answers whether
the pages are telling the truth. Claims the engine contradicts *and* the page
looks right about are parked in the generator, named, rather than quietly
corrected to match the code.

And the code blocks -- what a reader actually copies -- are compiled:

```bash
python tools/check-doc-blocks.py
```

Nothing is executed, since a documented example may open a window or reach the
network. It reports blocks that are whole and still do not compile; fragments
and blocks that name a variable an earlier block created are skipped, because
pages are written cumulatively and neither is a defect.

The applets the site offers for download take no filtering at all -- each is a
whole file -- so they go straight to the runner:

```bash
tests/bin/Plan9BasicTest.exe --gui --compile-only Website/assets/examples
```

And the site's own links resolve or they do not:

```bash
python tools/check-links.py         # --fix rewrites the unambiguous ones
```

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
