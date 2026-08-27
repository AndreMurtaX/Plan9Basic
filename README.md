# Plan9Basic

A BASIC interpreter and IDE, written in Delphi/FireMonkey, for Windows, Linux
and Android. One tree holds the interpreter, the IDE and a minimal applet
runner; a program written on one of them runs on the others.

- **Website and documentation:** <https://plan9basic.com>
- **Licence:** MIT (see [LICENSE](LICENSE))
- **Status:** v1.8, BETA. The language and libraries are stable enough to build
  with; the surface is still moving in places, and the website says where.

The interpreter is a tokenizer, a code generator and a stack-based VM. Around it
sit roughly a hundred libraries -- controls, drawing, animations, effects, HTTP,
JSON, SQLite, and an AI pair that talks to a local model through Ollama with no
key and nothing leaving the machine.

Everything registered is exercised: 6,193 assertions run against the engine, the
GUI libraries, a local model and the HTTP verbs, and `tools/check-all.py`
verifies the documentation against the code that implements it. `tools/verify.ps1`
runs the lot in one command.

---

## 🕹️ About the example games

`Demos/` holds a shelf of arcade games, and some of them carry the name of a
machine from the late seventies or early eighties. A word about what they are,
because the names invite an assumption that is not true.

**Every one is an original implementation, written for this project as teaching
material.** No sprite was traced, no sound sampled, no level data copied, and no
code taken from any other version. Each ship on screen is drawn by the program
from rectangles and ellipses -- open any of the files and the drawing is right
there in the source, which is the whole point of them being here.

What they reproduce is the *mechanics*: a formation that dives, a lander that
runs out of fuel, tiles that merge. Mechanics are ideas, and ideas are what a
programming example exists to teach.

The names are used to say which classic a program is in the tradition of, so a
reader knows what they are about to read. This project is not affiliated with,
endorsed by, or connected to the rights holders of those games, and claims no
interest in their trademarks. Games written from scratch here rather than in an
existing tradition are given names of their own -- `Tractor` is one.

---
## 📁 Project Overview

**Plan9Basic** is a modern BASIC interpreter built with Delphi/FireMonkey for cross-platform applet development (Windows, macOS, Linux, Android, iOS).

---

## 🔧 How to Build

### Clone

One repository, one clone. No submodules, no `--recurse`, no second checkout:

```bash
git clone <repository-url>
```

`engine/` was a submodule until 2026-08-19, pointing at
[Plan9BasicEngine](https://github.com/AndreMurtaX/Plan9BasicEngine). It is now
an ordinary directory in this tree. That repository stays where it is, so old
clones and the history in it keep resolving, but nothing builds from it any
more. If you have a checkout from before the change, the fix is a fresh clone
rather than a `submodule update`.

### Where a change belongs

Everything is in this tree, so a change is finished when it compiles and the
suites are green here. The split that used to make that untrue — an `engine/`
commit that had to be pushed and then have its pointer bumped in two consumers,
or the applet runner would quietly keep building the previous commit — is gone.

There are two applications and one library set:

| Path | What it is |
|---|---|
| `Plan9Basic.dpr` | the IDE: editor, output, file manager |
| `runner/` | the applet runner: a minimal FMX host, one form, no editor |
| `engine/` | the interpreter and the non-GUI libraries, shared by both |
| `Libs/` | the IDE's libraries, `Libs/GUI/` included |
| `tests/` | the headless suites, which link `engine/` and `Libs/` directly |

The runner was its own repository until 2026-08-19, and pulled `engine/` in as a
submodule of its own. Both applications now build from the same working tree, so
an engine change reaches them together or not at all.

`engine/` still means something, even though it no longer means a repository
boundary: it is the part meant to run without a windowing system driving it,
which is what `tests/NoFmxProbe.dpr` builds into a console host. Three units
under it still reach FireMonkey -- `StdLib` for `processmessages()`, `StrLib`
for the clipboard, and `TimerLib`, which is a GUI library on purpose. Adding a
fourth fails `tools/check-fmx-boundary.py`; nothing else notices, because a
`uses FMX.Forms` under `engine/` compiles here exactly as well as anywhere.

The trap worth naming: `Libs/GUI/` holds a hundred control, effect and animation
libraries and looks like the home of everything GUI, but **one** GUI library
lives under `engine/` instead -- `engine/Libs/GUI/TimerLib.pas`, because
`exec.pas` depends on it. A sweep across "the GUI libraries" that globs
`Libs/GUI/*.pas` misses exactly that one. Sweep both paths.

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

### Does all of it still work

One command, one verdict:

```powershell
.\tools\verify.ps1
```

It builds both applications, runs both suites and the negative one, builds and
runs the console host, and runs every documentation check — then prints one
table. A failing step does not stop the run, because knowing that three things
broke is worth more than knowing the first one did. `-Quick` skips the two
application builds, which are most of the wall clock.

Those steps used to be four separate invocations with no common answer, and
nothing at all built the IDE or the runner: both could stop compiling while
every suite stayed green. That is not hypothetical — it is what the first run
of this script demonstrated, with a syntax error in `runner/AppletRunner.pas`
and 994 assertions passing.

The rest of this section is what each step asks. Run one alone when it fails.

### Checking the documentation against the code

All of it, from one place:

```bash
python tools/check-all.py
```

Seven checks, one verdict, everything read-only. `--quick` skips the two that
compile, which are most of the wall clock. The rest of this section explains
what each of them asks; run them alone when one of them fails.

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

The engine is supposed to stay reachable from a host with no window, so the
units under `engine/` that import FireMonkey are held to a list:

```bash
python tools/check-fmx-boundary.py
```

Three are on it, each with a reason. A fourth fails the run, and so does an
entry that no longer describes the tree -- a list nobody has to maintain turns
into fiction. This replaced a probe that claimed to prove the same thing by
compiling with FMX off the search path, and never did: `dcc64` keeps the FMX
`.dcu` files beside the RTL's own, so the exclusion excluded nothing and the
probe linked 58 FMX units while reporting success.

And the site's own links resolve or they do not:

```bash
python tools/check-links.py         # --fix rewrites the unambiguous ones
python tools/check-anchors.py       # and the #section on the end of them
```

A link that reaches the right file and then names a section that is not there
does not fail: the browser leaves the reader at the top of the page, which is
worse than an error, because nobody reports it.

### Tests

`tests/build.ps1 -Run` compiles and runs the automated suite; add `-Gui` for the
FMX libraries. See [tests/README.md](tests/README.md). `tools/verify.ps1` runs
both, along with everything else.

### Publishing the site

The site is uploaded by hand and nothing here does it, which is how the
published copy came to be 111 files behind this tree while looking finished.
The procedure is [docs/PUBLISHING.md](docs/PUBLISHING.md), and

```bash
python tools/package-site.py
```

assembles exactly what belongs on the server — tracked pages plus the handful of
linked files git deliberately ignores — so the manual step is a copy rather than
a judgement about which of 124 pages changed.

---

## 📦 Project Entry Points

| File | Description |
|------|-------------|
| `Plan9Basic.dpr` | **Main project file** - The interpreter/IDE application |
| `UnitMain.pas` | Main form with editor, output, and file manager |
| `runner/Plan9BasicApplet.dpr` | The applet runner: the same engine in a host with no editor |
| `runner/AppletRunner.pas` | Its one form — see [runner/README.md](runner/README.md) |

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
