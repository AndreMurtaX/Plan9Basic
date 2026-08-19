# Plan9BasicEngine

Core of the **Plan9Basic** interpreter and the standard library shared by the
projects that host it. Delphi / FireMonkey, MIT.

This repository exists so that there is **a single copy** of this code. It is
consumed as a submodule by:

| Project | Role |
|---|---|
| [Plan9Basic](https://github.com/AndreMurtaX/Plan9Basic) | IDE and development environment |
| [Plan9BasicAppletRunner](https://github.com/AndreMurtaX/Plan9BasicAppletRunner) | runner for distributed applets |

## Contents

```
basic.pas                TBasicEngine -- the engine's facade for the host application
lexer.pas                tokenizer
parser.pas               parser and generator of intermediate/assembly code
exec.pas                 stack machine that executes the assembly
UnitUtils.pas            shared utilities
utils/UnitGC.pas         garbage collector for non-visual objects
utils/HandleRegistry.pas handle validation that never dereferences a pointer
                         supplied by the BASIC program
Libs/                    standard library (Array, Str, Num, DateTime, Json, Http, Zip...)
Libs/GUI/TimerLib.pas    timers -- a dependency of exec.pas
Libs/AI/                 AI client and RAG engine
```

## Pipeline

```
BASIC source
   |  lexer.pas          tokenization
   |  parser.pas         syntax validation -> intermediate postfix code
   |  ProcessPostfixCode assembly generation
   |  exec.pas           stack machine executes
output
```

## Using it

Add it as a submodule and point the `.dpr` at the paths inside it:

```bash
git submodule add https://github.com/AndreMurtaX/Plan9BasicEngine.git engine
```

```pascal
uses
  basic in 'engine\basic.pas',
  exec in 'engine\exec.pas',
  lexer in 'engine\lexer.pas',
  parser in 'engine\parser.pas',
  UnitUtils in 'engine\UnitUtils.pas',
  UnitGC in 'engine\utils\UnitGC.pas',
  HandleRegistry in 'engine\utils\HandleRegistry.pas',
  StdLib in 'engine\Libs\StdLib.pas',
  // ...
```

The host creates the `TBasicEngine`, registers whichever libraries it wants to
expose, and runs:

```pascal
GC := TGarbageCollector.Create();
Engine := TBasicEngine.Create();
StdLib.RegisterStdFuncs(Engine.Functions);
NumLib.RegisterNumFuncs(Engine.Functions);
// ...
if Engine.Compile(Source) = 0 then
  Engine.ExecuteProgram(Output);
```

For a run with no user interface, set `UnitGC.SkipProcessMessages := True` so
the engine does not try to pump a message loop.

## Host interaction

The engine never opens a window. Four callbacks carry everything that needs a
person or a message loop, and a host installs only the ones it can serve:

| Callback | Used by | Left unset |
|---|---|---|
| `PrintProc` | `PRINT`, `PRINTLN` | output is discarded |
| `InputProc` | `INPUT` | the statement keeps the default the program supplied |
| `ConfirmProc` | `BREAKPOINT` | the frame goes to the trace and execution continues |
| `YieldProc` | idle wait, and periodically during `PRINT` | nothing is pumped |

`InputProc` and `ConfirmProc` both receive a continuation instead of returning a
value, so a host whose dialogs are asynchronous can answer later.

### BREAKPOINT and the calling thread

`BREAKPOINT` is the one construct that parks the VM: it waits in a loop on
whichever thread called `ExecuteProgram` until `ConfirmProc` answers. That is
safe only where the platform can deliver a modal answer while that thread is
blocked -- true of the Windows, Linux and macOS message queues, false on Android
and iOS. There the answer travels back through the platform's own looper, which
is the very thing that called into the application: a parked VM blocks the
mechanism that would wake it, the wait never ends, and the system kills the
process as unresponsive.

The engine consults this itself before parking, so a host that assigns
`ConfirmProc` unconditionally cannot hang: on those platforms the VM simply
never parks. Hosts should still gate the assignment, since a handler that will
never be called is worth not installing:

```pascal
if CanPauseForHostDialog then   // declared in exec.pas
  Engine.ConfirmProc := HostConfirm;
```

`BREAKPOINT` always reports the frame -- line, message and watched variables --
to the trace, so the record reads the same on every platform:

```
[BREAKPOINT] checkpoint reached (Line 25)
             n = 7
             s$ = "frame"
```

That is the half of a breakpoint which still carries meaning on a device, where
the application is its own debugger and there is no separate window to pause.

## Extension model

Native functions are registered by a string signature, `name@parameters`, where
the suffix on the name gives the return type (`$` string, `#` pointer, none =
number) and each parameter is `n`, `$` or `#`.

```pascal
FnData.Entry := n_abs;   Lib.Add('abs@n', FnData);      // abs(number)
FnData.Entry := s_left;  Lib.Add('left$@$n', FnData);   // left$(text, n)
```

## Handle safety

The language lets a program fabricate a pointer with `pointer#(n)`. Libraries
must therefore never dereference a pointer they receive in order to check it.
`HandleRegistry` answers from the pointer **value**: every object handed out as
a handle registers itself along with its class, and validation is a dictionary
lookup. Revocation happens through the object's destructor, or -- for objects
freed by an FMX parent -- through `TComponent.FreeNotification`.

```pascal
if not IsHandleOf(P, TBasButton) then
  // reject: unknown or stale handle
```

## Changing this repository

Every commit here reaches two applications, and neither picks it up on its own.
A submodule pins a commit, so both consumers keep building the old one until
their pointer is moved:

```bash
# here
git commit -am "..." && git push
# then in each consumer's checkout
cd engine && git pull && cd .. && git add engine && git commit
```

Forgetting the second half is silent: the consumer still compiles, still passes
its tests, and is simply running the previous version of the engine.

One file here is easy to miss when sweeping the other way round.
`Libs/GUI/TimerLib.pas` is a FireMonkey library, and it lives in the engine
rather than with the IDE's other GUI libraries because `exec.pas` depends on it.
A change made across "the GUI libraries" in the IDE repository will not touch
it, and it is the only GUI library that ships from here.

## Tests

The automated suite lives in the IDE repository, under
[Plan9Basic/tests](https://github.com/AndreMurtaX/Plan9Basic/tree/main/tests):
a headless runner that compiles and executes `.bas` programs and checks
assertions. Changes to this repository should be validated with it.
