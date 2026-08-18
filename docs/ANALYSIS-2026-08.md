# Plan9Basic — Technical Analysis and Modernization Roadmap

**Date:** 2026-08-17
**Baseline:** commit `5d54670` (state of the code at the repository's initial commit)
**Scope:** main project (IDE + engine). Line references apply to the commit above.

---

## 1. Overview

| Metric | Value |
|---|---|
| Pascal code (main project) | **136 units / ~150,400 lines** |
| Interpreter core | 15,174 lines |
| GUI libraries (controls, 64 effects, animations) | **71,895 lines — 48% of the project** |
| Non-GUI libraries (Str, Num, Json, Http, SQLite, AI/RAG…) | 21,791 lines |
| Registered native functions | ~4,690 bindings |
| Documentation | 217 `.md` files (two generations: `Changelogs/` and `New docs/`) |
| `.bas` examples / demos | 98 examples + 9 games |
| Platforms configured in the `.dproj` | Win32/64, Linux64, macOS (3), Android (2), iOS (3) |

Core breakdown:

| Unit | Lines | Role |
|---|---|---|
| `parser.pas` | 5,103 | parser and code generator |
| `UnitMain.pas` | 3,550 | IDE (console, editor, commands) |
| `exec.pas` | 3,001 | stack machine (VM) |
| `UnitUtils.pas` | 1,011 | shared utilities |
| `utils/BasicConsole.pas` | 963 | console with syntax highlighting |
| `lexer.pas` | 775 | tokenizer |
| `basic.pas` | 450 | `TBasicEngine` facade |
| `utils/UnitGC.pas` | 321 | garbage collector |

---

## 2. Architecture

The pipeline is clean and well separated:

```
BASIC source
   |  lexer.pas          tokenization (TBasToken)
   |  parser.pas         syntax validation -> intermediate postfix code
   |  ProcessPostfixCode assembly generation (TAsmToken)
   |  exec.pas           stack machine executes
output
```

`TBasicEngine` is a thin, correct facade over that set. The VM dispatch resolves
method pointers at load time rather than through a `case` in the hot loop — the
right call.

The extension model maps string signatures (`"strlen@$"`, `"pointer#@n"`) to
`TBindFunction`. Simple and productive: it is what made 4,690 functions viable.

### Genuinely good decisions

- Layer separation in the engine, with the host decoupled behind `TBasicEngine`
- `LoadIntermediate` allows distributing pre-compiled applets without the source
- Tagged GC with an explicit split between visual FMX objects and non-visual ones
- Documented and correct teardown order in `InitBASICEngine` (timers, forms, engine, GC)
- A custom console with syntax highlighting through a custom `Paint`
- Real coverage of 5 platforms
- Per-library documentation above the market average

---

## 3. Technical debt, by severity

### 3.1 Version control — resolved on 2026-08-17

The project lived without version control, on OneDrive, with `__history/`,
`__recovery/` and a 2.3 GB `archive/` folder. Resolved by creating the private
`AndreMurtaX/Plan9Basic` repository. See section 6.

### 3.2 Duplicated engine — resolved on 2026-08-17

`exec.pas`, `parser.pas`, `lexer.pas`, `basic.pas`, `UnitUtils.pas` and 15
libraries existed in two copies. See section 8.

### 3.3 Silenced exceptions at scale — resolved on 2026-08-17

The dominant pattern in the GUI accessors swallowed the failure without even
recording it in the module's `lastError`. See section 7.

### 3.4 Handle validation by `is` over an arbitrary pointer — resolved on 2026-08-17

`TObject(P) is TBasButton` inside `try/except` dereferences whatever address the
BASIC program supplied. See section 7.

### 3.5 Per-module global state

38 libraries keep `ModuleEngine`, `ModuleOutput` and `lastError` as unit
variables. No `TCriticalSection` anywhere in the libraries. Consequences: two
engine instances in one process are impossible, "BASIC inside BASIC" is risky,
and running off the UI thread is closed off.

### 3.6 VM on the UI thread

`CmdRun` calls `ExecuteProgram` straight from the button handler, and there are
127 occurrences of `Application.ProcessMessages` across engine and libraries.
That produces re-entrancy (RUN during RUN) and a standing ANR risk on Android.
The `TThread.Sleep(16)` in the pause loop is a patch over the same problem.

### 3.7 Fixed limits without guards — resolved on 2026-08-17

See section 7.

### 3.8 Massive boilerplate in the GUI libraries

64 effect units total 27,184 lines. Comparing any two, about 95% of the content
is identical up to names. The same holds for the control wrappers (2,000 to
3,600 lines each, mostly property `get`/`set`). Half the project is code that
template generation or an RTTI layer would produce. See section 9.

### 3.9 No automated tests — resolved on 2026-08-17

See section 7.

### 3.10 Documentation with no link to the code

Two generations coexist (`Changelogs/`, from January 2026, and `New docs/`, from
March 2026) and nothing guarantees that a documented signature still exists in
the corresponding `.pas`.

---

## 4. The language

Solid coverage for a BASIC: `FUNCTION` with locals, `SELECT CASE`,
`DO/LOOP/UNTIL`, `FOR/NEXT`, `GOTO/GOSUB/ON`, `DATA/READ/RESTORE`,
multi-dimensional arrays, pointers as handles, indirect calls (callbacks), JSON
literals in the parser, and debugging features (`TRACE`, `WATCH`, `BREAKPOINT`).

Notable absences:

- User-defined types or structures
- `INCLUDE` / modules — every program is a single file
- Error handling in the language (`TRY` / `ON ERROR`)
- Block scope

Constraints worth knowing before writing `.bas`:

- A boolean expression is only valid inside an `IF`/`WHILE`/`UNTIL` condition.
  `assert_true(2 > 1)` and `x = 2 > 1` do not compile.
- A function returning a number is not valid as a condition on its own:
  `if dict_haskey(d#, "k") <> 0 then`.
- `true` and `false` are not usable as values.
- `s$[n]` indexes a **line** (0-based); `s$[[n]]` indexes a **character**
  (0-based). Arrays are 1-based.
- Quotes inside a literal are escaped with a backslash.

---

## 5. Modernization roadmap

Five fronts, in order of expected return.

| # | Front | Goal | Status |
|---|---|---|---|
| 1 | **Engineering foundation** | Version control, `.gitignore`, on-disk layout | Done 2026-08-17 |
| 4 | **Tests** | Headless `.bas` runner with assertions | Done 2026-08-17 |
| 3 | **Runtime safety** | Opaque handles via registry; error policy; global limit guard | Done 2026-08-17 |
| 2 | **Unify the engine** | One copy of `exec`/`parser`/`lexer`/`basic`, consumed by the IDE and the AppletRunner | Done 2026-08-17 |
| 5 | **Collapse GUI boilerplate** | Generate the wrappers from descriptors, or replace them with a generic RTTI layer | Open — see section 9 |

Front 4 was executed first because it is the practical prerequisite for the
others: without an executable suite, refactoring the engine or the libraries is
work done blind. It paid for itself immediately — it found two real defects
while it was being built (section 7).

---

## 6. Front 1 record

Executed on 2026-08-17.

| Repository | Visibility | On disk |
|---|---|---|
| `AndreMurtaX/Plan9Basic` | private | `C:\Dev\Plan9Basic` |
| `AndreMurtaX/Plan9BasicAppletRunner` | public | `C:\Dev\Plan9BasicAppletRunner` |

**Versioning decisions**

- `archive/` (2.3 GB of old snapshots) stays **out** of the repository,
  preserved only in the OneDrive copy
- Build output, IDE artefacts, distributable site binaries and third-party PDFs
  are excluded too

**On-disk layout**

The project moved out of OneDrive to `C:\Dev`, the AppletRunner stopped being
nested, and the project folder went from 3,363 MB to 622 MB. The old OneDrive
copy was kept as a backup, with `.git` renamed to `.git.disabled` to prevent an
accidental commit in the wrong tree.

**Portability verified:** `.dproj`, `.dpr`, `.deployproj` and `.git/config`
contain no absolute paths — the project moves without adjustment. Only
`Plan9Basic.dsk` (regenerated by the IDE) and `.claude/settings.local.json`
carry absolute paths.

---

## 7. Fronts 4 and 3 record

Executed on 2026-08-17, over commit `9f1215b`.

### Tooling discovered

The command-line compiler (`dcc64.exe`, RAD Studio 37.0) builds both projects
with no environment setup at all:

| Project | Lines | Time |
|---|---|---|
| `Plan9Basic.dpr` (full IDE, FMX) | 147,983 | ~4.5 s |
| `Plan9BasicApplet.dpr` (runner) | 27,790 | ~1.4 s |

That is what makes any refactoring from here on verifiable, and it is what
allowed touching 90+ libraries with confidence.

### Front 4 — tests

`tests/Plan9BasicTest.dpr` executes `.bas` files with no IDE and no UI, with a
fresh engine and GC per file. The engine was already headless-capable:
`exec.pas` references FMX, but the `UnitGC.SkipProcessMessages` flag turns off
message pumping in the PRINT path, and the only other
`Application.ProcessMessages` runs solely while paused or at a breakpoint.

- **338 assertions** across 15 files, plus a 4-file negative suite
- `--smoke` mode runs the existing `Examples/` as a regression net: **24 of the
  25 non-GUI examples** pass
- `--gui` mode registers the FMX libraries and adds **380 more assertions**
  across 4 files. No window is ever displayed: `form#()` builds the form and
  `form_show#()` is a separate call the suites never make
- The output is scanned for `[FAIL]`, because several examples report their own
  result by printing — without that, a file printing nothing but failures would
  pass

### Front 3 — global limit

A global's index addresses `HeapMem`, a fixed `[0..515]` array, and range
checking is only enabled in the Debug configuration. The parser did not check
the ceiling: in Release, a program with more than 513 globals silently corrupted
memory.

It is now a compile error pointing at the exact line, and the `HeapMem` accesses
in `exec` validate the index. The limit is pinned from both sides by tests: 513
globals compiles and runs, 514 is rejected.

### Front 3 — opaque handles

`utils/HandleRegistry.pas`. Every object handed out as a handle registers itself
along with its class on construction, and removes itself on destruction.
Validation became a dictionary lookup on the pointer **value**, compared against
the class recorded at registration — the caller's pointer is never followed.

Deregistration lives in the destructor rather than in the library that created
the object, because FMX frees child controls through parent ownership and the
library never sees those frees. In `ArrayLib` and `DictLib`, whose descendants
have their own constructors and no destructor, the base classes use
`AfterConstruction` and `BeforeDestruction`.

### Front 3 — later correction: the unsafe pattern outside `TBas` classes

The first sweep searched for `TObject(P) is TBas...` and declared the front
closed. That was **literally true and misleading**: many libraries validate
against raw FMX classes, without the `TBas` prefix, and were missed. **163
sites** still had the dereference.

| Where | Sites | Validated against |
|---|---|---|
| `ValidateParent`, in 91 libraries | 93 | `TFmxObject` |
| `ValidateEffect`, in the 64 effect libraries | 64 | the effect's FMX class |
| `ConfigLib`, `RAGLib` (in the engine) | 2 | `TBasConfig`, `TRAGEngine` |
| Others | 4 | `TCommonCustomForm`, `TVertScrollBox` |

`ValidateParent` was the most exposed: it receives the parent whenever a program
creates any control. The swap was direct — the parent is always a control the
libraries themselves created, and those classes already registered.

The effects needed a new piece. They are FMX classes instantiated directly, with
no `TBas` subclass in which to place registration and revocation, and FMX frees
the effect together with the owning control without telling the library.
`THandleWatcher` is a `TComponent` that subscribes to `FreeNotification` on
everything that is a `TComponent` and deregisters on `opRemove` — one piece
covers all 64, with no per-type subclass.

Why the suite missed it: `gui/02_handles.bas` tested `button_text$` with a wrong
handle, which goes through `ValidateButton` — precisely the path that **had**
been converted. It now also covers fabricated parent, fabricated effect,
wrong-class effect, and an effect freed through its owning control.

### Front 3 — error policy

1,675 `try ... except end;` blocks across 25 libraries swallowed the exception
without even recording it in the module's `lastError`. They now record it, while
leaving control flow alone: the accessor still returns normally, but the failure
becomes visible through the error accessors each library already exposes.

The label is the name the BASIC program uses, extracted from the handle
validation call nearly every function already makes —
`ValidateMemo(Args[0].P, 'memo_text#')` becomes
`SetError(ERR_OPERATION_FAILED, 'memo_text#: ' + E.Message)`. Of the 1,675
sites, 1,673 got the right BASIC name; 2 in `AILib` were inside class methods
without such a call and got the method name.

Two sites in `RectAnimationLib` stay silent on purpose: they are a teardown
path, where the only sane action is to keep unwinding, and `SetError` is
declared further down that unit.

`SQLiteLib` was left out: it does not follow the error-constant pattern of the
others.

### Defects found by the suite

1. **`RegexLib.regex_isvalid` and `regex_error$`** used `TRegEx.Create`, which in
   Delphi is lazy and does not compile the pattern. Every malformed pattern was
   reported as valid. Fixed by forcing compilation, with the empty pattern
   (which is legal regex) handled separately.
2. **`Examples/21_Base64Lib_tests.bas`** called `savetext$` with its arguments
   out of order, creating a junk file whose name was the content.

### Findings recorded without a fix

- **`savetext$` and `opentext$` are not a faithful round trip**: they go through
  a `TStringList`, so text read back gains a trailing CRLF — 11 characters in,
  13 out. `file_writealltext` and `file_readalltext$` (IOUtilsLib) do not have
  the problem. The behaviour is pinned by a test in `suite/12_fileio.bas` so
  that changing it is a decision rather than an accident.
- **Inconsistent argument order in StrLib**: `containsstr(text$, part$)` but
  `startsstr(prefix$, text$)` and `endsstr(suffix$, text$)`. Inherited from
  Delphi's own `System.StrUtils`, which is irregular. Documented in
  `suite/06_strings.bas`.

---

## 8. Front 2 record

Executed on 2026-08-17, right after fronts 4 and 3.

The divergence this analysis predicted **materialized during the work**. Until
the security fixes, the two copies differed only in the license header (**zero
code divergence** across 22 units); afterwards `exec.pas` differed by 45 lines
and `parser.pas` by 19, leaving the AppletRunner — which runs distributed
applets — with the memory corruption and the arbitrary-pointer dereference.

**Solution adopted:** a repository of its own for the engine, consumed as a
submodule by both hosts.

| Repository | Visibility | Role |
|---|---|---|
| [`AndreMurtaX/Plan9BasicEngine`](https://github.com/AndreMurtaX/Plan9BasicEngine) | public | core plus standard library (23 units) |
| `AndreMurtaX/Plan9Basic` | private | IDE — consumes it at `engine/` |
| `AndreMurtaX/Plan9BasicAppletRunner` | public | runner — consumes it at `engine/` |

Merging everything into a single repository was blocked by the visibility
difference; the engine is MIT by its own headers, so publishing it separately is
coherent.

**What went into the engine:** core (`basic`, `exec`, `lexer`, `parser`,
`UnitUtils`), `utils/UnitGC`, `utils/HandleRegistry`, `Libs/GUI/TimerLib` (a
dependency of `exec.pas`), the 12 non-GUI libraries the runner uses, and the 3
AI ones. The MIT header was normalized across all of them — 14 had none, and 9
carried a placeholder instead of the author's name.

**What stayed in the IDE:** the remaining 34 GUI libraries, the 64 effects,
`DictLib`, `StrListLib`, `RegexLib`, `GzipLib`, `IOUtilsLib` and `SQLiteLib`.

Paths were updated in the `.dpr` **and** the `.dproj` of both projects — the
`.dproj` lists every unit individually, and forgetting it would break the IDE
build.

**Verification:** the IDE builds, the runner builds, the suites stay green, and
the divergence between the two trees dropped to **zero lines** across the five
core units. A fresh clone with `--recurse-submodules` builds identically.

**Pending item found during verification:** `Plan9BasicApplet.res` is not
versioned (`*.res` in the `.gitignore`), so a clean clone only builds after the
project is opened once in RAD Studio, which regenerates the file. A pre-existing
gap, not introduced here, but awkward in a public repository whose point is that
others can build it.

---

## 9. Front 5 — prerequisite done, scope measured

### GUI test coverage — done

This was the blocker for front 5, and it is resolved. The runner gained `--gui`,
which registers the 102 FMX libraries. **No window is displayed**: `form#()`
builds the form and `form_show#()` is a separate call the suites never make, so
almost the entire property surface is checkable automatically.

- `gui/01_controls.bas` — one instance of each control type
- `gui/02_handles.bas` — validates, in the **real** libraries, the replacement of
  `TObject(P) is TBasXxx` by `HandleRegistry`
- `gui/03_effects.bas` — **generated** by `tests/gen_effects_suite.py` from
  descriptors extracted from the units themselves: 338 assertions over 64
  effects and 200 properties. The suite checks those descriptors against the
  current code, which validates them before any attempt to regenerate the units
  from them

380 GUI assertions, 718 in total.

### What the measurement showed about generating the units

Normalizing the proper names (BASIC prefix, FMX class, unit name, property
names) across the 64 units:

| | |
|---|---|
| Non-empty lines | 23,041 |
| Distinct shapes after normalization | **1,330** |
| Lines repeating some shape | 22,266 (**96%**) |
| Truly unique lines | 775 |
| Average repetition factor | **17.3x** |

But the 284 setters are not uniform:

| Shape | Setters | What it does |
|---|---|---|
| one line | 126 | `Effect.Prop := Args[1].n` |
| five lines | 64 | a `TPointF` component (`Center.X`, `Center.Y`) |
| two to four lines | 47 | range clamp, scale conversion |
| six or more | 40 | target load, bitmap, one-offs |
| none | 7 | empty setter |

Two templates cover 190 of the 284 (67%). The remaining third is varied, and a
regeneration has to reproduce **all** of the behaviour, not most of it.

### Finding recorded, without a fix

The `progress` setter in the 17 transition units guesses the scale:

```pascal
Value := Args[1].n;
if Value <= 1.0 then Value := Value * 100;
```

The FMX property is 0..100 and the getter divides by 100. So `progress#(e, 1)`
means **100%**, not 1%. Beyond the ambiguity, the pair of conversions through a
`Single` makes the round trip lossy — which is why the generated suite uses a
tolerance. Changing this would break existing applets relying on either
convention, so it stays a decision.

### Options

| Path | Effect | Cost |
|---|---|---|
| **Generate the units from descriptors**, keeping the output versioned | same runtime behaviour, the diff stays readable, errors stay at compile time | about 6 templates plus the one-offs; the gain shrinks as the irregular third is chased |
| **Generic RTTI layer** replacing the 64 units | actually deletes ~27,000 lines | trades a compile error for a runtime error, and changes the error surface of a project that ships these libraries ready to use |
| **Extract only the shared infrastructure**, leaving the property code alone | cuts 5,000 to 9,000 lines, no API change, errors stay at compile time | smaller gain than full generation, but an order of magnitude less risk |

The counter-argument is worth recording: these are 27,000 lines of boilerplate
that work, are now covered by tests, and that nobody edits. The cost of owning
them is low; the gain is mostly having less code to read. Three mechanical
sweeps were run across these libraries in a single session — the HandleRegistry
conversion, the error policy, and the `ValidateParent` / `ValidateEffect`
correction — each a matter of a script plus a build plus the suite. Duplication
only costs a lot when the bulk change has to be made by hand.
