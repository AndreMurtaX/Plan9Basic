# Plan9Basic — restructuring plan

The source for this plan is [ANALYSIS-2026-08.md](ANALYSIS-2026-08.md). Every
item below traces to a section of it, and nothing here was invented: the
analysis found these, recorded them, and in several cases deliberately left
them alone because the choice was not a tool's to make. That waiting is over.

The end state, in one sentence: **one public repository holding the language,
the IDE, the applet runner and the website, with every flaw the analysis mapped
either fixed or explicitly retired, and a site that describes what the thing
actually does.**

## Why this order

The phases are sequenced by what invalidates what.

Language corrections change documented behaviour, so they precede the site.
The architecture work changes what `BREAKPOINT` and HTTP can do on mobile, both
of which the site describes, so it precedes the site too. Repository unification
changes the build instructions the site prints, so it also precedes the site.
The website is therefore last: it is the only phase whose input is everything
else.

Within a phase, tests come with the change, not after it. The suite is the only
thing that makes a sweep across 38 libraries safe to attempt.

---

## Phase 1 — Language corrections

Each is a flaw the analysis identified and left, because changing it alters
behaviour that existing applets may rely on. The instruction to fix them is the
decision that was missing.

### 1.1 `instr` with two arguments returns a flag, not a position

**Done 2026-08-18.** Reading the implementation made this smaller than it
looked: `n_instr` already computed the position and then threw it away.

```pascal
Pos := System.Pos(Args[1].s, Args[0].s);
if Pos = 0 then Result.n := Pos else Result.n := 1;   // discards Pos
```

The three-argument form, `instrrev` and `StrLib.md` all specify the same thing —
*"Zero-based position, or -1 if not found"* — and the documented example,
`instr("Hello World", "World")` giving 6, is right for a zero-based answer. So
this was a bug against a settled contract, not a change of language.

| call | before | after |
|---|---|---|
| `instr(s$, sub$)` | 1 or 0 | zero-based position, -1 when absent |
| `instr(s$, sub$, start)` | zero-based position | unchanged |
| `instrrev(s$, sub$)` | zero-based position | unchanged |

**Breaks, and precisely how.** An applet testing `if instr(a$, b$) = 1 then` as
a contains-test now reads a position. Worse and quieter: `0` used to mean *not
found* and now means *found at the very start*, so `if instr(a$, b$) = 0 then`
is exactly inverted for that case. The release note has to say this plainly;
the new spelling is `<> -1`.

Pinned by eight assertions in `suite/06_strings.bas`, and the claim came out of
`PARKED` in `gen-doc-examples.py`, so the documented example is now executed on
every run.

### 1.2 `savetext$` and `opentext$` are not a round trip

**Done 2026-08-18.** Both halves went through a `TStringList`, which is a list
of lines and not a string: assigning to `.Text` normalised the line endings, and
both `SaveToFile` and reading `.Text` back appended a break. Eleven characters
in, thirteen out.

They use `TFile` now — what `IOUtilsLib` already used for `file_writealltext`,
which never had the problem. `TUtils.OpenStr` also leaked its `TStringList` on
the exception path; the rewrite has nothing to leak.

Two things made this contained. `StrLib` is the only caller of either, and the
documentation never described the extra break — so it has always described the
behaviour that now exists, and no page needed correcting.

`suite/12_fileio.bas` now pins the round trip and, separately, that a bare LF
inside the text survives instead of being normalised.

### 1.3 Inconsistent argument order in StrLib

**Done 2026-08-18.** All six now read `(text$, part$)`: subject first, then the
part being asked about. The four `starts`/`ends` variants swap the arguments on
the way through to `System.StrUtils` rather than passing them down, so the
language stays regular where the library it wraps is not.

This one differs from 1.1 in a way worth keeping straight. `instr` was a bug
against a contract its own documentation already stated. This is a **change of
language**: the pages described the old order faithfully, so nothing was wrong,
only uneven.

**It breaks without a word.** Both arguments are strings, so
`startsstr("Plan", text$)` still compiles and simply answers false. There is no
error to notice. `06_strings.bas` asserts that the old spelling now fails, so
the suite states the cost and not only the benefit.

Corrected with it: four shipped applets in both copies, twelve worked examples
and six synopsis lines in `StrLib.md`, and the calls on `strlib.html`.

### 1.4 The `progress` scale in the 17 transition effects

```pascal
Value := Args[1].n;
if Value <= 1.0 then Value := Value * 100;
```

**Done 2026-08-18.** There were 22 of these, not 17, and the guess made the
scale discontinuous: `progress#(e, 1)` meant 100% and `progress#(e, 2)` meant
2%, while `0.5` and `50` both meant halfway.

Like 1.1, the contract was already settled and only the setter disagreed. The
documentation says *"Progress | 0.0 - 1.0 | 0.0 | Transition progress (0=source,
1=target)"* and the getter already returned `Progress / 100`. So the setter now
clamps to 0..1 and converts, and out-of-range saturates at the ends instead of
being reinterpreted.

The generated effect suite got tighter rather than merely staying green. Its
tolerance existed for the scale conversion, and with the guess gone the only
imprecision left is arithmetic: 0.3 through a 32-bit `Single` and the ×100 ÷100
pair comes back 0.300000019073486. So 124 round-trips are asserted **exactly**
now and only the 22 `progress` ones keep a tolerance, for a reason the comment
can state honestly.

`gui/05_progress_scale.bas` pins the scale, the clamping and — the thing the old
setter got wrong — that the scale is continuous across 1.

### 1.5 SQLiteLib is outside the error policy

**Done 2026-08-18, and the item was mis-stated.** The 70 handlers looked like
the problem and were not. `ValidateConn` and `ValidateStmt` already record
before they raise, and the library already exposes `sql_error`,
`sql_errormsg$`, `sql_strerror$` and `sql_clearerror`. The policy was in place.

**`SQLiteLib` was dead.** It validates handles with `IsHandleOf` and never
called `RegisterHandle`, so every call refused the pointer `sql_open#` had just
returned — the same defect as `ScrollBoxLib`, found the same way, by trying to
use the thing rather than by reading it.

The earlier sweep for this shape missed it because it searched `Libs/GUI/**`
rather than the whole tree. Redone properly, it found a second: **`RAGLib`**,
which never registered either *and* freed by testing
`TObject(P) is TRAGEngine` — the pattern the registry exists to replace, which
follows whatever address it is handed and is fatal outside Windows.

Both fixed: registered at creation, revoked at destruction, and `rag_free` asks
the registry. `gui/06_sqlite.bas` is the first test the library has ever had —
16 assertions over open, exec, query, a genuine SQL error with its code and
message, and a fabricated pointer.

The lesson worth keeping: an item written from reading the code named the wrong
defect. Running it named the right one.

### 1.6 `Libs/AI/archive/` — finish it or retire it

Seven units registering 39 `p9_*` and `skill_*` functions. They appear in no
`.dpr`, `.gitignore` excludes them, and `New docs/AI/` documents them across
three pages. The public documentation describes a library nobody can obtain,
which is why `check-all.py` is red on a fresh clone.

**Retired, on the author's decision, 2026-08-19.**

The measurement that informed it: 6,969 lines across seven units, 97 registered
functions, never versioned, and — checked rather than assumed — they still
compile. Adding them to the test project builds at 145,323 lines with no error.
So "finish it" was cheaper than it looked, and the reason not to take it is not
cost.

It is that compiling is not working. `SQLiteLib` compiled perfectly and was
dead, which item 1.5 discovered the same day, and `RAGLib` with it. These seven
units have never been exercised by anything at all, so finishing means finding
out what else is wrong in code nobody has run.

Three pages were retired with the decision: `P9EngineLib.md`, `SkillLib.md` and
`IntelligenceEngine_Spec.md`. `AILib.md` and `RAGLib.md` stay, because both
describe libraries that ship. Nothing outside `New docs/AI/` linked to the
three, so no navigation broke.

The code stays where it was, still excluded by `.gitignore`, and the pages stay
in git history. Retiring is not deleting.

With them gone, `check-docs.py` is green against a tree that has no
`Libs/AI/archive/` — which is what a clone is, and which is what had been
keeping `check-all.py` red for everyone but this machine.

---

## Phase 2 — Architecture

Sections 3.5 and 3.6 of the analysis, which are the same problem seen from two
sides. This is the largest phase and the one that changes what the language can
promise.

### 2.1 Measure first

**Done 2026-08-19, and it reshapes the phase.**

**The `ProcessMessages` count is stale.** The analysis says 125 remain in the
GUI libraries. There is **one**, and it is not internal pumping:
`StdLib.n_processmessages` is the BASIC function `processmessages()`, which a
script calls deliberately to keep the interface alive during a long loop. The
host has two more, both legitimate: one updating the console as output arrives,
and `HostYield`, which is the callback the engine decoupling created. The rest
went with section 10 and the sweeps after it, and nobody updated the number.

What looked like 125 sites to convert is 0.

**The per-module state is real, and has one shape.** 37 units declare
`ModuleEngine` and `ModuleOutput`; 35 read them, all in the same statement:

```pascal
Btn.BasicEngine := ModuleEngine;
Btn.ConsoleOutput := ModuleOutput;
```

`RegisterXxxFuncs(Lib, Eng, OutP)` stashes the engine in a unit variable, and
every constructor copies it into the instance. So the engine is per-process by
construction, and a second one cannot exist beside it.

The error slots are a different matter and are **not** a defect: `lastError` is
per-library on purpose, so that `button_error()` stays independent of
`circle_error()`. 64 effect units hold `Err` for the same reason. What makes
them a hazard is threads, not multiplicity.

**The VM does run on the UI thread**, in both hosts, straight from the button
handler with no `TThread` anywhere.

### What the measurement means for 2.2 and 2.3

The plan treated 3.5 and 3.6 as one problem. They are two, and only one of them
is large.

Removing `ModuleEngine` needs the engine to reach a constructor some other way.
The honest route is the parent chain — a control is created against a parent,
the chain ends at a form, and the form is created when the engine is in hand.
That is a design change across 35 units, but a mechanical one.

Moving the VM off the UI thread is the large one, and the cost is not
`ProcessMessages`. FireMonkey is not thread-safe, so **every** call that touches
an FMX object has to be marshalled: 3,899 functions across 101 units in
`Libs/GUI/`. The 709 functions outside `Libs/GUI/` touch nothing and need
nothing.

That ratio is the decision. A worker-thread VM makes `BREAKPOINT` pause on
mobile and stops long scripts freezing the interface, and it costs a marshalling
layer around four thousand entry points.

### 2.2 Remove the per-module global state

**Done 2026-08-19.** A control now finds its engine by walking up its parents to
the form, which is what holds it. `ControlCommon.EngineOf` does the walk, and
`TBasForm` answers it through a small `IEngineHost` interface — an interface
rather than a class reference because `FormLib` already uses `ControlCommon`,
and naming the class would close the circle.

**87 construction sites across 34 units.** The shape was identical everywhere,
which is why a sweep was possible at all:

```pascal
Btn.BasicEngine := ModuleEngine;      ->   if EngineOf(Btn, Eng, Outp) then
Btn.ConsoleOutput := ModuleOutput;         begin
                                             Btn.BasicEngine := Eng;
                                             Btn.ConsoleOutput := Outp;
                                           end;
```

Two cases needed the sweep adjusted, and both are worth naming.

An **animation** is a `TComponent` with no `Parent` of its own — it attaches to
a target rather than being a child of one — so its walk starts at the control it
animates. Six units.

A **media player** is a plain `TObject` created with no parent at all, and has
no place in a form tree to walk. It keeps `ModuleEngine`, and is the single
honest exception. The comment there says so, so the next person does not read it
as an oversight.

`gui/07_engine_by_parent.bas` proves it where it matters: a callback firing
needs the engine to run the BASIC function, and the only place it can have come
from is the form. One level down, two levels down, and through an animation's
target.

### 2.3 Move the VM off the UI thread

**Done 2026-08-19.** The applet runner executes on a thread of its own, and
the five checks of its validation applet pass on Windows with the interface
responsive throughout, `BREAKPOINT` pausing and resuming through a dialog,
and `INPUT` answering asynchronously.

What it took, beyond the seam described below, is in ANALYSIS §17 through
§24: the UI-to-VM queue, a drain point in the instruction loop *and* in the
pause loop, output that waits to be fetched, an atomic re-entry guard, and
one deadlock of the author's own making that cost four wrong diagnoses. The
applet now tests itself, which is the part most worth keeping.

The `ProcessMessages` part of this item was already done — see 2.1. What is real
is that FireMonkey is not thread-safe and 3,899 GUI functions touch it.

That number turned out not to be the cost. **The VM reaches every one of them
through seven call sites**, and now through one method, `TExec.CallNative`. So
the handover belongs in the engine and not in the libraries.

What is in place:

- `TLinkFunction.NeedsUIThread` — a library sets it once in its `Register`
  procedure before its first `Add`, because the record is copied by value into
  every entry. One line marks a whole library.
- `TExec.MarshalProc` — a host installs it to hand a call to the thread
  FireMonkey belongs to. The call travels in fields rather than parameters,
  because `Synchronize` takes a parameterless method and an open array cannot be
  captured.
- All seven dispatch sites routed through `CallNative`.

All of it is inert. With no marshaller installed `CallNative` calls straight
through, which is what the sites did before, and the suites and the no-FMX probe
confirm nothing moved.

The flags are in as well, 2026-08-19: 96 units say `True`, 20 say `False`, and
every one states it rather than defaulting — `Fn` is a local record whose other
fields were never assigned, so an unstated field is stack garbage and a stray
`True` marshals a call that must not be.

### What the flip still requires, and why it was not attempted

Reading the run path turned up more than a worker thread. The VM would be
entered from **two directions**, and only one of them has a seam.

**Output writes to a UI object.** `ExecuteProgram(FOutputMemo.Lines)` hands the
engine the memo's own `Lines`, and every `PRINT` appends to it. From a worker
that is a data race on every line of output.

**Timers re-enter the VM from the UI thread.** `TimerLib` calls
`ExecuteUserFunction` from `OnTimer`, which fires on the UI thread. With the VM
on a worker, the UI thread would enter the VM while the worker is already
inside it.

**So does every control callback.** `ControlCommon.RunCallback` runs a BASIC
function from an FMX event, on the UI thread, for all 405 dispatchers.

**And the re-entry guard is not thread-safe.** `UnitGC.GlobalCallbackBusy` is a
plain Boolean with no lock. It stops a callback firing inside a callback on one
thread and does nothing across two.

That is the real shape: the seam built here marshals **VM → UI**, and the flip
also needs **UI → VM**, which is a queue rather than a `Synchronize` — a
callback cannot run where it fires, it has to be handed to the VM's thread and
waited for. Plus a lock on the guard.

Naming these is the point of stopping. Each one fails as a hang or a corrupted
memo rather than a red assertion, which is precisely the failure this project
spent a session chasing on Android, and the device was not reachable when the
attempt came up.

**Sequenced after Phases 3 and 4.** Nothing else in the plan depends on it, the
site can describe the language without it, and it is the one change that wants a
device in hand and a clear head rather than the end of a long pass.

### 2.4 What that unlocks

- `BREAKPOINT` pauses on Android and iOS instead of degrading to a trace dump.
- Asynchronous HTTP becomes buildable, which is the section the website
  advertised for functions that were never written.
- A long-running script stops freezing the interface.
- The `TThread.Sleep(16)` patch in the pause loop goes away.

---

## Phase 3 — One repository

Today the code lives in three: `Plan9Basic` (private, the IDE),
`Plan9BasicEngine` (public, a submodule) and `Plan9BasicAppletRunner` (public).
The runner holds exactly one unit of its own; the rest is submodule.

### 3.1 Fold the engine back in

**Done 2026-08-19.** `engine/` is an ordinary directory: the same 26 files, byte
for byte, at the same path, so nothing in either `.dpr` had to move. What went
away is the ceremony — a change under `engine/` used to need three commits
across three repositories, and forgetting the third produced no error, just a
consumer still building the previous interpreter.

`Plan9BasicEngine` stays where it is; its history and any clone pointing at it
keep resolving.

The one thing worth keeping from the split was the *meaning* of `engine/`: the
part that runs with no windowing system driving it. That is no longer a
repository boundary, so nothing enforced it — and it turned out nothing ever had. See 3.1b.

### 3.1b The boundary was guarded by a check that could not fail

**Found while writing 3.1 down.** `tests/build-nofmx.ps1` claimed to compile the
engine "with the FMX unit directories removed from the compiler's search path,
so any reference to FireMonkey from the engine is a hard compile error". It
passed, and always had. Three units under `engine/` import FMX unconditionally.

`dcc64` ships the FMX `.dcu` files in the RTL's own directory — 209 of
them — so
a search path holding "the RTL only" holds all of FireMonkey. Built with a
detailed map and counted: **58 FMX units** linked into the program reporting it
needed none.

Replaced by `tools/check-fmx-boundary.py`, which reads the `uses` clauses and
holds the answer as a ratchet: `StdLib` (`processmessages`), `StrLib`
(clipboard), `TimerLib` (a GUI library on purpose). A fourth fails; so does an
entry that stops being true. `SysLib` was a fourth, and its import was dead.

`StdLib` and `StrLib` want host callbacks, the way `PrintProc` and `InputProc`
already have them. Left named rather than done here: `processmessages()` is a
question about which thread owns the message loop, so it belongs with the
deferred 2.3 flip.

Full account in ANALYSIS §12.

### 3.2 Fold the runner in

**Done 2026-08-19.** 32 files under `runner/`, one form and a `.dpr`. The whole
of the port was 23 engine paths moving from `engine` to one directory up. Both
applications build from the same tree: the IDE at 143,186 lines, the runner at
28,072.

Consolidated on the way: `LICENSE` existed in the engine and the runner and not
at the root, which is where a repository's licence belongs — one copy now, at
the top. `runner/.gitignore` was a strict subset of the root's, so it went.

Its 20 example applets had never been checked by anything, because they shipped
in a repository with no test runner. They compile, and `check-all.py` says so on
every run.

### 3.3 One build, one suite

**Done 2026-08-19.** `tools/verify.ps1`: both application builds, both suites
and the negative one, the console host, and every documentation check — one
table, one exit code. A failing step does not stop the run.

The gap it closes was real and larger than "four scripts instead of one":
*nothing built the applications*. The suites link `engine/` and `Libs/`
directly, so both shipped applications could stop compiling with every check
green. Proving the script catches that meant breaking a build on purpose, and
the run came back with 994 assertions and nine checks passing while one of the
two applications did not compile.

Both failure paths were watched going red before it landed — which is the
lesson from 3.1b applied immediately.

### 3.4 Mark the old repositories obsolete

**Done 2026-08-19.** Both READMEs open with a notice: development moved, nothing
was deleted, clones and submodule pointers keep resolving, and here is why the
split was undone. `Plan9BasicEngine` also lost the paragraph describing itself
as the shared copy consumed by two submodules, which is no longer true.

### 3.5 Make `Plan9Basic` public

**Held, 2026-08-19, at the author's decision.** The engineering side is done and
the tree was audited for it: 68 commits, one author, no secret in the history,
no file with a sensitive name ever added and removed, no absolute path from a
developer's machine. Every check passes. Flipping a private repository to
public is not reversible in any meaningful sense — the content is out — so it
waits for a deliberate go-ahead rather than arriving as the tail of a long pass.

**Sequenced to the end of the project**, and everything written before then
describes the repository as public — the obsolete notices in 3.4, the website in
Phase 4, every link that points at it. Documentation that hedges about a
temporary state is documentation somebody has to find and unwrite later, and
the window is measured in this project's remaining work rather than in months.

So the only thing this step still involves is the flip itself.

Nothing else in the plan waits on it.

---

## Phase 4 — The website

### 4.1 Inventory what is actually published

**Done 2026-08-19, and it inverted the expectation.** The instruction was not to
trust the disk copy. The drift is real and runs the other way: the disk is
ahead, and the published site is stale by 111 files.

`plan9basic.com` predates 2026-08-18, so every Phase 1 correction is unpublished.
Verified page by page against the live instance rather than assumed:

| Live now | Actually |
|---|---|
| `httplib.html` has an "Asynchronous HTTP (Polling)" section with six functions and a worked example | none of the six exist; HttpLib registers 92 and none is asynchronous |
| `strlib.html` gives `startsstr(pre$, s$)` | the prefix is the second argument, since 1.3 |
| `language-reference.html` opens dictionaries with `dict_new#(0)` | never existed |

Bracketed by testing corrections either side of the date: the `instr` wording is
live and correct, because there the documentation was right and the engine was
wrong. That is what dates the copy.

Nothing in the tree publishes the site, which is the real finding and became
**4.6**.

### 4.2 Rebuild the documentation from the corrected language

**Done 2026-08-19.** Phase 1's corrections were already in `Website/` — that is
what the 111 unpublished files are. So this item was mostly a search for what
the checkers structurally cannot see: prose that contradicts the language while
every signature and every code block stays valid.

Two real defects, and one false alarm worth recording. `instr` is described
correctly everywhere, and the `0-100` hits under `Libs/GUI/` turned out to be
`IntAnimationLib` animating a `Tag` between 0 and 100, which is a different
thing from a transition's `progress`.

**`BREAKPOINT` was documented as pausing.** It has not paused on Android or iOS
since the degradation landed. Both the reference and the User Guide now say so,
with the output format checked against the code that emits it.

**The checkers themselves had rotted**, in two different ways, and that is
written up as ANALYSIS §13. Briefly: `check-doc-blocks` excused five code blocks
in files retired with the AI archive, noticed, printed a notice, and returned
zero — so `check-all` had been printing a deleted filename where a verdict
belongs. And `check-links` never mentioned the 65 MB of ebooks the site serves
from outside the repository, because a gitignored target resolves fine on the
machine that has the file.

### 4.3 Reorganise, keeping the look

**Done 2026-08-19.** The arrangement turned out to be sound and the navigation
inverted, which measuring found and reading would not have.

All 124 pages are reachable from the front page — no orphans. But counting who
links to whom:

| Page | Links in | Links out |
|---|---:|---:|
| `library_guide.html` | 3 | **121** |
| `language-reference.html` | **120** | 1 |

The site had a directory, organised into ten sections, listing every library
page. Almost nothing pointed at it. Meanwhile the page 120 others put in their
top bar was a dead end. Getting from one library's page to another's cost three
hops through the front page, and a reader had no way to learn the directory
existed.

So the fix is one link, in the markup and classes already there: `Libraries`
beside `Language`, on 116 pages. Four more had no library navigation at all —
`language-reference.html` itself, `examples.html` and the two AI pages — and
now do.

Those two docs pages use a different top bar from the other 120: a breadcrumb
and a `topbar-right`. The link went in `topbar-right`, for two reasons. The
breadcrumb is `display:none` under the mobile media query, and Libraries is a
sibling of those pages rather than a step in the path to them. Confirmed in a
browser at 682px, where the breadcrumb is already gone and the new link is not.

Two CSS lines were added, `.topbar-right a` and its hover, because that slot had
never held a link. Nothing was replaced.

Result: the directory went from 3 inbound links to 123. 863 links became 987,
all resolving, and 1,749 fragments still name something.

### 4.4 Remove the download section

**Done 2026-08-19.** Six buttons across two pages pointed into
`Website/assets/devenv/`: 63 MB of executables that were never in the
repository, gitignored, placed by hand at publish time. The site was handing out
artefacts that existed on exactly one machine, and nothing in the tree could say
whether they matched it.

The section keeps its shape and its stylesheet; the three cards now offer the
IDE, the applet runner and the engine, each pointing at the directory it lives
in. `#download` became `#source`.

`downloads.html` keeps every platform note — what Windows, Linux and Android each
need is still true, and now describes running what you built.

One thing did not survive review: the rewritten header carried a
`section-subtitle`, and the stylesheet has no such class. The other six headers
are a label and a title, so this one is too.

### 4.6 Close the gap between the tree and the site

**Added 2026-08-19, from what 4.1 found.** The published site predates
2026-08-18 and therefore every documentation correction in Phase 1. Live right
now: six HTTP functions that do not exist, with a worked polling example; four
predicates documented with their arguments the wrong way round; and
`dict_new#(0)`, a constructor that never existed, as the first line a reader
meets about dictionaries. 111 corrected files have never been published.

Nothing in the repository publishes the site. It goes up by FTP, by hand, and
the tree holds no record of how — which is why a month of corrections could sit
in `Website/` without anyone noticing they had not shipped.

**Interim, and it works today.** A script that assembles exactly what belongs on
the server into one directory, so the manual step is a copy rather than a
judgement about which of 124 pages changed. Plus the procedure, written down, in
the repository.

**The endgame is to delete the manual step, not to automate it.** Once the
repository is public (3.5), GitHub Pages can serve `Website/` directly, and
publishing becomes a consequence of the push that is already happening. The
drift this item exists to fix stops being possible rather than becoming easier
to fix.

That needs three one-time acts from the author, none of which involve handing
over a credential: making the repository public, enabling Pages, and pointing
the domain's DNS at GitHub. Everything on this side — workflow, `CNAME`, the
layout Pages expects — can be committed before any of it, and sit inert.

### 4.5 Tell the story of the evolution

**Done 2026-08-19.** The front page already had a story section with two blocks,
ORIGIN and VISION, so the evolution became a third rather than a new page:
**THE 2026 REBUILD**, seven paragraphs, in the register of VISION rather than
ORIGIN — impersonal, since it is about the project and not the memory that
started it.

What it says, because it is the honest shape of the year: a project that grows
by addition long enough stops being one project; three repositories meant a
one-line fix took three commits and forgetting the third produced no error at
all. So 2026 was the year it got measured rather than extended, and most of what
that found was not where it was expected.

It names the uncomfortable parts rather than the flattering ones. That the
documentation was right and the code was wrong, nearly every time. That a test
had been passing for months while proving nothing, because the framework it
claimed to exclude was never excluded and it linked 58 of those units on every
run. That a check is not evidence until it has been watched failing.

It closes on the only claim worth making about the pages themselves: they are
verified against the language on every run, which is the sole honest reason to
say they are accurate. And then: *"None of this is visible in a program you
write. That is rather the point."*

---

## Phase 5 — Deferred, and named rather than hidden

Section 3.8: 407 event setters and the property code across the GUI libraries,
roughly 27,000 lines whose repetition is in identifiers rather than values.
Delphi cannot abstract over a property name at compile time, so the only routes
are generating the units from descriptors or binding through RTTI at run time.

The analysis weighed both and recorded the boundary. It stays a boundary unless
someone decides otherwise; it is listed here so that "why is half the project
still boilerplate" has a written answer.

---

## After this plan — named, not scheduled

Raised by the author on 2026-08-19, while this plan was still running. Recorded
here so it survives the end of it.

**Two IDEs instead of one.** The current environment tries to be both a desktop
development tool and a mobile applet host, and has become confusing as a result.
The proposal is to split it: one project aimed at desktop use, one at Android
and iOS.

That is a product decision and not this plan's to take, but it is worth noting
how squarely it lands on 2.3. The whole difficulty of moving the VM off the UI
thread is that **the two platforms want different answers and one host has to
give both**. `BREAKPOINT` is the clearest case: on desktop it should stop and
show a dialog, on mobile it cannot, so today the engine degrades and both get
the lesser behaviour. A split lets each host decide, instead of one host
apologising.

So the ordering matters. 2.3 built for one host that must satisfy both
platforms is harder than 2.3 built for two hosts that each satisfy one, and some
of what makes it hard would simply not arise.

**Also still open:** `StdLib` and `StrLib` reach FireMonkey for
`processmessages()`, `handlemessage()` and the clipboard (ANALYSIS §12). They
want host callbacks, and they belong with 2.3 rather than before it.

---

## Rules for the whole project

- **English** in every artefact that lands in the tree: code, comments,
  documentation, tools, commit messages.
- **A test with every behaviour change.** A corrected behaviour that is not
  pinned is a behaviour that will drift back.
- **`tools/check-all.py` green** before anything is called done, and the suites
  with it.
- **Measure before sweeping.** Every productive change in the analysis started
  with a count; every unproductive one started with a guess.
- **Product judgements get asked, not assumed.** 1.6 and 3.5 are the two in
  this plan.
