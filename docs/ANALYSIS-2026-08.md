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

## 1b. Three things waiting on a decision

Written across eight rounds of an unattended loop and gathered here, because a
finding scattered over eight sections is a finding nobody acts on. Each was left
alone deliberately: the evidence is settled and the choice is not a checker's to
make.

### The two-argument `instr` returns a flag, not a position — resolved 2026-08-18

Fixed. Reading the implementation shrank it: `n_instr` computed the position and
threw it away. The three-argument form, `instrrev` and `StrLib.md` all specify a
zero-based position with -1 for absent, and the documented example was already
right for that answer, so the engine was the only party disagreeing. See
[PLAN-restructure.md](PLAN-restructure.md) §1.1 for what it breaks.

*(original entry below)*


| call | returns |
|---|---|
| `instr(s$, sub$)` | 1 or 0 |
| `instr(s$, sub$, start)` | the position, 1-based |
| `instrrev(s$, sub$)` | the position, 1-based |

`StrLib.md` documents the first as a position, and so does every other BASIC.
Its own three-argument form disagrees with it.

*Change the engine* and any applet relying on the flag breaks. *Change the page*
and the inconsistency is written down as intended. Held in
`tools/gen-doc-examples.py` under `PARKED`, with the reason beside it, so the
generated suite shows it rather than filing it away.

### `Libs/AI/archive/` is documented and not distributed — retired 2026-08-19

Seven units — `IntelligenceEngine`, `P9EngineLib`, `PromptAssembler`,
`RAGDocGenerator`, `SkillEngine`, `SkillLib`, `ToolExecutor` — register 39
`p9_*` and `skill_*` functions. They appear in no `.dpr`, and `.gitignore`
excludes `archive/`, so they exist on one machine and in no clone.
`New docs/AI/` documents them across three pages.

This is why `check-all.py` reports 51 findings on a fresh checkout and none
here. **The public documentation describes a library nobody can obtain.**

*Finish it* — register the units, add them to the projects. *Retire it* — the
pages go with the code. Either closes the check; leaving it open keeps a red
mark that is correct.

### Which copy of the examples is canonical — settled 2026-08-19

**Kept both, and checked them.** `tools/check-site-examples.py` pairs the two
directories by name without the leading number and compares content with the
byte order mark stripped, because a BOM is an encoding difference and not a
difference in the program. 98 pairs, and `ChuckNorrisFacts_Demo.bas` was
brought forward from `Examples/`, which held the newer copy. See section 34.

*(original entry below)*


`Examples/NN_name.bas` and `Website/assets/examples/name.bas` hold the same 98
programs. 96 are identical. The copy step is real and mostly faithful, and
nothing states which direction it runs.

`ChuckNorrisFacts_Demo.bas` has already drifted: the website's copy is older,
missing a section and carrying a byte-order mark. One `savetext$` argument order
had drifted too, and was corrected against the implementation.

*Name one canonical and generate the other*, or *keep both and check them* —
either would have caught the drift. Doing neither means the next divergence is
found the same way this one was, by accident.

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

### 3.5 Per-module global state — resolved 2026-08-19, and the count was wrong twice

**Four units keep it, each because it has no parent to walk up to.** Measured
2026-08-19: of the 38 that declared `ModuleEngine`, **34 declared it, assigned
it on every registration, and read it nowhere.** Phase 2.2 gave visual controls
`EngineOf`, which walks up the parent chain to the form that owns an engine, and
left the variables behind. Dead state that reads as live, in the place this
entry said the state was the problem.

Removed: 136 lines across 34 units. What is left is `TimerLib`, `StrListLib`,
`MediaPlayerLib` and `tests/TestLib.pas` — a timer, a string list and a media
player are not in the visual tree, so there is no chain to walk, and the harness
reaches the parser deliberately. `tools/check-module-state.py` names all four
with the reason and fails if a fifth appears or one of these stops reading. See
section 35.

*(original entry below)*

38 libraries keep `ModuleEngine`, `ModuleOutput` and `lastError` as unit
variables. No `TCriticalSection` anywhere in the libraries. Consequences: two
engine instances in one process are impossible, "BASIC inside BASIC" is risky,
and running off the UI thread is closed off.

### 3.6 VM on the UI thread

> **Measured a third time on 2026-08-19, and the correction had gone stale
> too.** There is no `Application.ProcessMessages` left in `engine/`, `Libs/` or
> `utils/` at all — not 125, and not the one this note claimed. The BASIC
> `processmessages()` goes through `HostServices` now, and the hosts keep their
> own. The VM runs on a worker in the applet runner and on the interface thread
> in the IDE, which is the difference the two-IDE proposal is about. See
> [PLAN-restructure.md](PLAN-restructure.md) §2.1 and section 35.

`CmdRun` calls `ExecuteProgram` straight from the button handler, and there are
127 occurrences of `Application.ProcessMessages` across engine and libraries.
That produces re-entrancy (RUN during RUN) and a standing ANR risk on Android.
The `TThread.Sleep(16)` in the pause loop is a patch over the same problem.

Partly unblocked on 2026-08-17: the two `ProcessMessages` calls **inside the
engine** became a host callback, so the VM no longer requires a message loop of
its own. See section 10. The remaining 125 are in the GUI libraries, and moving
the VM off the UI thread is still open.

### 3.7 Fixed limits without guards — resolved on 2026-08-17

See section 7.

### 3.8 Massive boilerplate in the GUI libraries

**Measured again 2026-08-19, and this entry understated it.** The effects half
moved and the wrappers did not, and the wrappers are where the code is.

| | units | lines | share |
|---|---|---|---|
| control wrappers (`Libs/GUI/` outside `Effects/`) | 29 | 78,836 | 51% |
| engine | | 27,837 | 18% |
| effects (`Libs/GUI/Effects/`) | 65 | 25,100 | 16% |
| other libraries | | 13,845 | 9% |
| host, tests, runner | | 7,970 | 5% |
| **total** | | **153,588** | |

The effects were the part Front 5 took: all 64 units now share
`EffectCommon.pas`, 193 lines, and the total came down from 27,184 to 24,907.

The wrappers are 28 `*Lib.pas` files from 566 to 3,560 lines, and they are
**51% of the project on their own** — not the parenthesis this entry gave them.
Together with the effects it is 68%, where the entry said half. That is the
Phase 5 boundary, and the number is the argument for it being a boundary rather
than an oversight.

*(original entry below)*

64 effect units total 27,184 lines. Comparing any two, about 95% of the content
is identical up to names. The same holds for the control wrappers (2,000 to
3,600 lines each, mostly property `get`/`set`). Half the project is code that
template generation or an RTTI layer would produce. See section 9.

### 3.9 No automated tests — resolved on 2026-08-17

See section 7.

### 3.11 The engine required FireMonkey — resolved on 2026-08-17

The interpreter core linked FMX for three interactions with a person. See
section 10.

### 3.10 Documentation with no link to the code - resolved on 2026-08-18

Two generations coexist (`Changelogs/`, from January 2026, and `New docs/`, from
March 2026) and nothing guaranteed that a documented signature still existed in
the corresponding `.pas`.

`tools/check-docs.py` is that guarantee now. Both sides already write the same
thing: the engine registers `string$@nn`, and the reference writes
`` `string$(n, code)` ``, so a documented call converts to a signature and gets
looked up. That catches more than a deleted function -- an argument added,
dropped or retyped since the page was written shows up as well.

Against 4,691 registered signatures and 4,185 documented calls it found two
errors, both on adjacent lines of the user guide, and both confirmed by running
them through the interpreter rather than by reading:

- `replace$(s$, old$, new$)` does not exist. The functions are `replacestr$`,
  which is case sensitive, and `replacetext$`, which is not.
- `string$(3, "ab")` was documented as yielding `"ababab"`. It does not compile.
  `string$` takes a character code: `string$(3, 65)` is `"AAA"`.

Both are now correct in the guide and pinned in `06_strings.bas`, so the
documentation being right no longer depends on the code staying still.

Getting there took three passes over the extractor, and the reason is worth
recording: documentation writes calls in three registers, and only one of them
is a claim about arity.

| written | means | checked as |
|---|---|---|
| `` `asc(s$)` `` | a declaration | name and signature |
| `` `asc("A")` `` | an example | name and signature, typing the literal |
| `` `arr_free()` `` | prose naming the function | name only |

Reading all three as declarations produced 106 findings, essentially all noise.
Nine functions also build their signature at registration --
`Lib.Add('narr_get@#' + nStr, ...)`, one per dimension -- so their arity cannot
be read statically and is not checked.

### The third generation: the website

There is a third copy, and it is the one the public reads. `Website/` is
versioned here, and its pages write calls inside `<code>` exactly as the
markdown writes them inside backticks, so the same check covers both.

It documents the surface better than `New docs/` does -- 99.1% of registered
names against 89.1% -- and carried the same two errors, which is what one
expects of a copy.

It also advertised an entire asynchronous HTTP API that does not exist.
`httplib.html` had a section titled *Asynchronous HTTP (Polling) -- For mobile
platforms*, a signature table for `http_get_async`, `http_post_async`,
`http_put_async`, `http_patch_async`, `http_delete_async` and `http_busy`, a
worked polling example, and two Quick Reference rows. `HttpLib` registers 92
functions and none of them is any of those. The page's own category counts gave
it away in hindsight: they summed to 98 while the page claimed 92, which is 92
plus the six that were never written.

Removed on the author's instruction, along with the sidebar entry, the summary
row, and the mobile example that used it. The counts now agree at 92.

**What that leaves open is real.** The section existed to answer a real
question: a synchronous HTTP call on Android blocks the UI thread, which is the
same defect as section 3.6 in a different costume. The page now says to keep
requests small and set `http_timeout#`, which is true and is not a solution.
Either an async HTTP API or the VM off the UI thread would be one.

### What the extractor had to learn

Documentation writes calls in four registers, and only two are claims about
arity:

| written | means | checked as |
|---|---|---|
| `` `asc(s$)` `` | a declaration | name and signature |
| `` `asc("A")` `` | an example | name and signature, typing the literal |
| `` `arr_free()` `` | prose naming the function | name only |
| `arc#(parent#[, w, h] \| [, x, y, w, h])` | a synopsis of the overloads | name only |

And one register is not a claim at all: *"the syntax is `formatdatetime$(...)`
-- Not `format$(value, ...)`"* shows a call in order to warn against it. A match
a negation introduced is skipped.

Reading everything as a declaration produced 106 findings on the markdown and 54
on the website, essentially all noise. Nine functions also build their signature
at registration -- `Lib.Add('narr_get@#' + nStr, ...)`, one per array dimension
-- so their arity cannot be read statically and is not checked.

### Two more registers, and a comment read as code

Pages also state the signature outright, in the engine's own notation:

    **Signature:** `p9_ask$@#$`

That is the most exact claim a page can make and it was being ignored, which is
why `New docs/` looked worse covered than it is. Reading it lifted that side
from 89.1% to 93.2%.

The scanner was also reading Pascal **comments** as registrations. One archived
unit explains itself with *"extracts function registrations from
`Lib.Add('signature', ...)` calls"*, and the surface gained a function named
`signature`. Comments are stripped now, tracking string literals so a `//`
inside a URL opens nothing.

The remaining gap is coverage, not correctness: `New docs/` covers 93.2% of
registered names and the website 99.1%. Reported, never a failure, on the
principle that silence misleads nobody.

### Checking what the pages claim a function *does*

`check-docs.py` verifies that a documented function exists and takes what the
page says. It cannot verify that the page is right about the result. The
documentation asserts results constantly:

    `left$("Hello", 3)` -> `"Hel"`
    `string$(3, "ab")`  -> `"ababab"`

The second was false for as long as the page existed, and was caught by typing
it into the interpreter. `tools/gen-doc-examples.py` now does that on every run:
it collects the self-contained claims -- every argument a literal, the expected
value a literal -- and writes `tests/suite/16_doc_examples.bas`. Seventeen of
them, over both generations of documentation.

It found two more on its first run.

**`mid$` is 0-based, and the user guide said 1-based.** `mid$("Hello", 2, 3)`
was documented as `"ell"` and returns `"llo"`. The engine is right and the page
was wrong: `StrLib.md` already documented `mid$("ABCDEF", 3)` as `"DEF"`, and
the guide itself says string indexing is 0-based, like `s$[[n]]`. Corrected in
both the guide and the website.

**`instr` with two arguments returns a flag, not a position.** This one is
parked, not corrected, and the reason is in `gen-doc-examples.py` next to the
claim:

| call | returns |
|---|---|
| `instr(s$, sub$)` | 1 or 0 |
| `instr(s$, sub$, start)` | the position, 1-based |
| `instrrev(s$, sub$)` | the position, 1-based |

The page, the three-argument sibling and every other BASIC agree that it should
be a position. Writing the page down to match the engine would record the
inconsistency as intended, and changing the engine would break any applet
relying on the flag. That is a decision, so it waits as one -- visible in the
generated suite rather than filed away.

### The code blocks, and the limit of scanning them

Everything above checks spans -- a call written inside backticks or `<code>`.
The **code blocks** are unchecked, and they are what a reader copies: 1,719 in
the markdown, 901 on the website.

Scanning them for calls to functions that do not exist looked easy and was not.
The first pass reported 275 names. Stripping BASIC comments, where
`' Blur amount slider (0-10 range)` reads as a call to `slider`, brought it to
76. Excluding functions the block itself declares brought it lower still, and
the rest was mostly string literals: `println "sqrt(16) = "` is not a call to
`sqrt`, and the example beside it uses `sqr` correctly.

That is three times in this document that a comment or a literal has been read
as code -- once in Pascal, twice in BASIC. It is the standing hazard of scanning
a language without parsing it, and the reason the surviving finding was checked
by running it rather than by trusting the count.

One real error came out of it. **`dict_new#(0)` does not exist**, and both the
user guide and the website used it to introduce dictionaries -- the first
dictionary line a reader meets. The constructor is `dict#()`. Corrected in both
and pinned in `08_dict.bas`.

So the blocks are compiled instead of scanned, by the interpreter's own parser,
which is the only thing that knows BASIC. `Plan9BasicTest` gained
`--compile-only`: a file passes if it is valid source, and nothing runs, because
a documented example may open a window or reach the network and a reader is not
asking for either. `tools/check-doc-blocks.py` writes every block out and
compiles the lot in one pass.

Three filters were needed before the output meant anything, and each was a
lesson about the corpus rather than the code.

**The fences.** Matching ` ```basic ` with the tag optional treats a *closing*
fence as an opening one and returns the prose between two blocks as a third.
That is how 1,680 blocks first counted as 2,620. The tag is required now.

**The fragments.** A block showing the inside of a loop is not expected to
compile alone, so a block is only compiled when nothing it opens is left
unclosed.

**The accumulated context.** Pages are written cumulatively: one block creates
`ai#`, the next configures it, and compiled alone the second has no idea what
`ai#` is. That single complaint — *Unknown variable* — was 709 of the 923
failures, and it is the page working as intended. Ignoring it is what left a
signal.

What survived: **37 blocks**, of which most are `<pre>` elements holding things
that were never BASIC — SVG path data, mathematical notation, a bracketed
section header — and 20 are the archived AI library described below.

One real error. **`rectangle_cornerradius#` does not exist**; the setter is
`rectangle_corners#`. Both sources used the wrong name in a worked example.
Corrected in both and pinned in `gui/01_controls.bas`.

Two further filters took the residue from 37 to 27. The website highlights its
BASIC, so a `<pre>` carrying none of `class="kw"`, `"fn"`, `"str"`, `"num"` or
`"cmt"` is holding something else -- an ASCII diagram of a crop rectangle, SVG
path data. And a synopsis states the shape of a call rather than making one,
`dim#(size1 [, size2, ..., size10])`, in a basic-tagged fence like any example.

Of the 27 left, nine are the archived AI library below, and the rest are
illustrative examples calling invented functions -- `obj# = createSomeObject()`
-- which is the same register as the `function(sender#)` placeholder and just as
deliberate. No further real error came out of it, and that is the point at which
refining the filter stops paying.

### The applets the site hands out

`Website/assets/examples/` holds 98 `.bas` files, offered for download and never
compiled by anything. With `--compile-only` in hand they take no filtering: each
is a whole file, so the runner reads the directory directly.

**Six did not compile.** Every one of them fails on the first line that calls
the wrong name:

| written | exists |
|---|---|
| `docsdir$()` (4 files) | `documentspath$()` |
| `image_loadurl#(img#, url$)` | `image_load#(img#, url$)`, which follows a URL itself |
| `rectangle_stroke#(r#, "Blue", 3)` | `rectangle_stroke#(r#, colour$)`; the width is `rectangle_strokethickness#` |

All six corrected, and all 98 compile. The inline copies on the site were
checked for the same three names and are clean, so nothing was duplicated.

This is the sharpest finding of the loop so far, and the reason is the shape of
the surface rather than any cleverness: a downloadable applet is a whole
program, so compiling it asks a question with no ambiguity in the answer. Every
other check in this section spends most of its effort deciding what is even
being claimed.

### The same applets again, from the other copy

Sweeping the tree for `.bas` found two more sets nobody compiles: `Examples/`
with 98 files and `Demos/` with 9. `Demos/` was clean. `Examples/` failed on the
same five files as the website, which is how it became clear that
`Examples/NN_name.bas` is the source and the website carries the copy with the
number stripped. The three fixes were applied there too, and both sets compile
in full.

Comparing the copies once they were both valid: **96 identical, two divergent,
none orphaned**. So the copy step is real and mostly faithful. Both divergences
were worth having found.

**`Base64Lib_tests.bas` had the arguments of `savetext$` in different orders in
the two copies**, and only one can be right. The implementation settles it --
`SaveStr(filename, Enc, s)`, so the call is `savetext$(path$, encoding$,
content$)` -- and `StrLib.md` documents exactly that. `Examples/` was right and
the website's copy was wrong; both compile, since all three parameters are
strings, which is why nothing caught it. Corrected against the implementation
and confirmed by writing a file and reading it back.

Note what that means for the type signature as a check: `savetext$@$$$` cannot
distinguish a path from its contents. Everything this section does rests on
types, and three strings in a row is where that runs out.

**`ChuckNorrisFacts_Demo.bas` differs in content**: the website's copy is older,
missing a section the source has, and carries a byte-order mark the source does
not. Which copy is canonical is a workflow question rather than a defect, so it
is left alone and named here.

### The links between the pages

The site is 124 pages that reference each other, and nothing had ever resolved
those references. `tools/check-links.py` does: 868 internal links, external URLs
left to whoever owns them, fragments treated as positions rather than pages.

**132 of them did not resolve**, across eight distinct paths, and the cause is
the same everywhere. A page written for `docs/` keeps its relative paths when it
moves into `docs/gui/` or `docs/gui/effects/`, and a link written as a sibling
stops reaching a parent.

| pages | wrote | needed |
|---|---|---|
| 64 effect pages | `language-reference.html` | `../../language-reference.html` |
| 29 control pages | `language-reference.html` | `../language-reference.html` |
| 6 animation pages | `../index.html`, `../assets/img/...` | one level further up |

So the **Language Reference** link in the navigation of every effect and control
page — 99 pages — went nowhere. Each broken path resolved to exactly one real
file, which is why `--fix` can rewrite them and why the correction needed no
judgement. 100 files rewritten, all 868 links resolve.

This is the same shape of finding as the applets: a whole surface, an
unambiguous question, and nobody had ever asked it.

### Two surfaces measured, both sound, and one tool not shipped

With the links resolving, the two neighbouring questions were asked once each,
by throwaway script rather than by anything committed.

**Fragments.** 1,758 anchors across the site; every one names an id that exists.
The 14 that first looked broken were all `#'+e.target.id+'`, which is JavaScript
building a fragment at run time, not a fragment. That is the fourth time in this
document a scan without a parser has read code as content.

**Reachability.** Every page is linked from somewhere. `docs/httplib.html`
appeared orphaned, and was not: the throwaway script skipped external URLs with
`startswith('http')`, and `'httplib.html'.startswith('http')` is true. A scheme
test has to include its colon.

Folding both into `check-links.py` produced a version reporting 1,616 dangling
fragments where the same logic in isolation reported none. It was reverted
rather than shipped: a checker that cries wolf 1,616 times is worse than no
checker, because the next real finding arrives inside a list nobody reads.

Rebuilt from scratch the following round as `tools/check-anchors.py`, a faithful
port of the script that had worked, it reports **1,744 fragments and none
dangling** — the answer already known. So the defect was never in the logic. It
was in how the edit was applied: the change went in through a nested here-doc
whose escaping ate a ``, and probably more. The fifth time in this project
that nested escaping has corrupted something, and the first time it produced a
plausible wrong answer rather than a syntax error, which is why it cost a round.

Worth stating as a rule: an edit that rewrites a regex should be applied
directly, not through a shell that will interpret the backslashes on the way.

### One entry point, and a baseline for what will not go to zero

Six checks were written one at a time, each answering a question nobody had
asked, and each ended up a script somebody has to remember. `tools/check-all.py`
runs the lot for one verdict:

| asks | of |
|---|---|
| does a documented function exist, and take what the page says | `check-docs.py` |
| does it return what the page claims | the test suite |
| does what a reader copies compile | `check-doc-blocks.py` |
| do the files offered for download compile | the runner, over three directories |
| does a link reach a file | `check-links.py` |
| does the `#section` name anything | `check-anchors.py` |

Joining them exposed a problem the individual scripts could hide.
`check-doc-blocks.py` ends on 27 failures that are characterised and will not
become zero -- nine belong to an AI library documented but not built, the rest
are illustrative blocks naming functions nobody wrote. A check that is
permanently red is the *cries wolf* failure in slow motion, so it now keeps a
baseline of what is known and answers the only useful question: **is there
anything new?** `--baseline` records the current set when the answer changes for
a good reason.

The generators stay out of `check-all.py`. `gen-doc-examples.py` and
`--baseline` write files, and regenerating a fixture is a decision, not a check.

### What a clone sees, which is not what this machine sees

Every check above was written and run against a working tree that has files the
repository does not. Cloning fresh and running them was the last unasked
question, and it found three things.

**`tools/__pycache__` was versioned.** Committed by a `git add -A` of my own.
Removed and ignored.

**The link checker failed for everyone but this machine.** The download buttons
point at `Website/assets/devenv/`, built and placed at deploy, and two ebooks
sit under an ignored path as well. Here the files exist and the links resolve;
in a clone they do not, and the check called that a defect. It now asks git
which targets are deliberately absent and reports those separately, so the
verdict is the same in both places.

Getting that right needed one more Windows detail. `git check-ignore --stdin`
through a text-mode pipe receives every path but the last with a carriage
return glued on, because Python rewrites the newlines on the way out; git
matches anyway and answers with a quoted name that no longer compares equal to
what was asked. NUL-separated bytes in both directions.

**`check-docs.py` reports 51 findings in a clone and none here**, and that one
is not a tool defect. `.gitignore` excludes `archive/`, so the 39 `p9_*` and
`skill_*` functions exist on this machine and in no clone — while
`New docs/AI/` documents them across three pages. That is the accumulated
decision below, seen from the outside: **the documentation describes a library
nobody can obtain.** `check-all.py` will stay red on a fresh clone until it is
answered, which is correct: a red check with a named cause is an open question,
not a false alarm.

### The whole workflow, from a clone

The previous round fixed the checks so a clone would get the same answers. This
one ran the documented path end to end on one, on the assumption that a
newcomer's first hour is the only test of whether any of this was worth writing:

```
git clone --recurse-submodules ...      42 items, engine at the pinned commit
tests/build.ps1                          138,283 lines
tests/build.ps1 -Run                     367 assertions
tests/build.ps1 -Run -Gui                589 assertions
tools/check-all.py                       7 checks
```

Everything works. Six of the seven checks pass, and the seventh is the P9Engine
question below, reported with its cause named.

One detail worth keeping: `check-doc-blocks.py` passes in the clone, where the
archived AI library does not exist at all, because its baseline is keyed on the
file and the compiler's complaint rather than on a block's position. A fixture
keyed to position would have gone red the moment anything moved.

That closes the question this loop has been circling: not whether the
documentation is right, but whether anyone other than this machine can find out.

### Resolved 2026-08-19: Libs/AI/archive/ retired

The author chose to retire rather than finish. `P9EngineLib.md`, `SkillLib.md`
and `IntelligenceEngine_Spec.md` are gone from `New docs/AI/`; `AILib.md` and
`RAGLib.md` remain, describing libraries that ship. The code is untouched and
still ignored, and the pages remain in history.

What decided it was not cost. The seven units compile — adding them to the test
project builds clean — so finishing was cheap in the obvious sense. But
`SQLiteLib` compiled too, and was dead, and so was `RAGLib`; both were found the
same day by running them rather than reading them. Seven units that nothing has
ever exercised are seven units whose defects are all still ahead.

`check-all.py` is now green against a tree without `Libs/AI/archive/`, which is
what every clone is.

*(the original entry follows)*

### Accumulated for review: Libs/AI/archive/ is not in any build

Seven units live under `Libs/AI/archive/` — `IntelligenceEngine`, `P9EngineLib`,
`PromptAssembler`, `RAGDocGenerator`, `SkillEngine`, `SkillLib`, `ToolExecutor`
— and **none is listed in any `.dpr`**. Not the IDE, not the applet runner, not
the test runner. The 39 `p9_*` and `skill_*` functions they register are in no
shipped binary.

`New docs/AI/` documents them across three pages. The website does not, which is
the difference between its 99.1% coverage and the markdown's 93.2%.

Left exactly as found. Whether that is a feature parked mid-flight or one
abandoned with its pages still standing is not a question a checker can answer,
and the two answers point opposite ways: finish and register them, or retire the
pages with the code.

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

**Run rather than read, 2026-08-19.** Every sentence below was checked against
the engine and all of them hold — the first section of this document measured
that day and found accurate. `tests/suite/19_language_contract.bas` and four
files in `tests/negative/` keep it that way. See section 36.

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
| 5 | **Collapse GUI boilerplate** | Shared plumbing extracted from the effect libraries and the control libraries; the property code and the event setters are left alone | Partly done 2026-08-18 — see section 9 |

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

### Making a fresh clone buildable

Splitting shared files across repositories creates ways for a clone to arrive
broken, so this was verified empirically rather than assumed: clone from GitHub
into an empty folder, build with no search paths and no environment setup.

Two problems showed up, and both are fixed:

- **The project resource was not versioned.** `*.res` in the `.gitignore` also
  caught `Plan9Basic.res` and `Plan9BasicApplet.res`. RAD Studio only
  regenerates those when the project is opened in the IDE, so a command-line
  build failed outright on a clean checkout. They are versioned now; the rule
  still excludes every other `.res`. This was a pre-existing gap, not one the
  submodule split introduced.
- **A plain `git clone` leaves `engine/` empty**, and the build dies on the
  first unit with a confusing error. Both READMEs now say to clone recursively
  and how to repair a checkout already made without it.

What the split did **not** break: unit resolution. Every unit is referenced with
its path from the `.dpr`, including the ones inside `engine/`, so no search path
or environment setup is needed. Verified by building both projects from a fresh
clone with no `-U` flags at all.

Also cleaned up: 17 stale `.dcu`/`.o` files left in the runner by pre-submodule
builds, sitting in folders whose sources had moved into `engine/`. They are
ignored by git, so they never reached a clone, but locally an IDE *Compile*
could have picked up a stale unit instead of the submodule's source.

**Fresh-clone verification, both repositories:** build succeeds, and in the IDE
repository the full suite runs — 338 non-GUI assertions, 380 GUI assertions and
the negative suite, all green.

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

### Done: the shared plumbing

The conservative option was taken. `Libs/GUI/Effects/EffectCommon.pas` now holds
what was written out in all 64 units: the six shared error constants, the error
slot, `SetError`, `ClearError`, `ValidateEffect`, `ValidateParent`, and the three
trivial error accessors. Each library keeps its own `TEffectErrors` record, so
`sepia_error()` stays independent from `bevel_error()`, and keeps one-line
forwarders — which leaves the thousands of call sites in the property code
untouched.

26 of the 64 declare error codes beyond the shared six and keep their own
`strerror`; the other 38 forward.

**2,738 lines removed** from the effect libraries, 192 added in `EffectCommon`,
net **2,546**. The IDE compiles 145,440 lines, down from 147,983.

The one observable change: the message from a failed validation is now uniform.
It used to vary between "invalid effect object", "invalid type", "not a TXxx"
and plain "invalid" depending on the unit. Error codes are unchanged.

Four units packed declarations and bodies onto single lines and were reformatted
first, so one transformation could apply to all 64.

That is less than the 5,000 to 9,000 estimated above. The estimate came from
counting lines whose shape appears in at least 60 of the 64 units, and that
count includes things no extraction can remove — `uses`, `begin`,
`implementation`, the license header. The honest figure for shareable plumbing
was always closer to 2,500.

### Options still open for the property code

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

### Done: the control libraries' shared conversions

The measurement above covered the 64 effect units, 24,888 lines. It never
touched the other side of `Libs/GUI`, and that is where the weight sits:

| | files | lines |
|---|---|---|
| `Effects/` | 65 | 24,888 |
| `Animations/` | 6 | 7,264 |
| controls | 29 | **74,317** |

Seven helpers had been pasted into 27 control units, and had drifted:

| helper | units | distinct variants |
|---|---|---|
| `SetError` | 28 | 1 — byte for byte |
| `ClearError` | 28 | 2 |
| `BuildShiftString` | 18 | 2 |
| `MouseButtonToInt` | 23 | 3 |
| `IntToAlign` / `AlignFromInt` | 27 | 5 — *under two different names* |
| `AlignToInt` | 27 | 6 |
| `ValidateParent` | 26 | 7 |

`ValidateParent`'s seven variants proved to be wording and `Exit` versus
`Exit()`. One group also tested `TCommonCustomForm` separately, which is
redundant: in this Delphi, `TCommonCustomForm = class(TFmxObject, ...)`.

The alignment pair was not cosmetic. It had split into three tiers, covering
6, 7 or 20 of the `TAlignLayout` values depending on which unit the author
copied from, so the same number meant different things:

```basic
rectangle_align#(r, 5)   ' MostTop
button_align#(b, 5)      ' None, silently
```

The constants agreed everywhere; only the coverage differed. `ControlCommon.pas`
now answers for all of them from one table. Each library keeps its own error
slot and error codes, because code 1 names the library's own type, and
`ValidateParent` stays as a short forwarder over `ParentIsValid` for the same
reason — only the unit knows where to record the failure.

**2,353 lines removed** across 27 units, 213 added. The IDE compiles 143,515
lines, down from 145,645.

`tests/gui/04_alignment.bas` is generated over 26 controls and 8 values chosen
to cross the old tier boundaries: 208 assertions, taking the GUI suite to 588.

### The bug that fell out of testing it

That suite showed `ScrollBoxLib` failing every assertion, every call returning
error 1. `ScrollBoxLib` never calls `RegisterHandle`. It creates a bare
`TVertScrollBox` rather than a `TBasXxx` subclass, so it has no constructor of
its own — which is exactly where every other library was hooked during the
HandleRegistry conversion. Its validation was checking a registry the object had
never been added to.

**Every `scrollbox_*` function had been failing since that conversion.** The
whole library was dead and nothing noticed, because the GUI suite covered
`scrollbox` about as well as it covered alignment. Two `RegisterHandle` calls
fix it; revocation needs nothing more, since `THandleRegistry.Add` wires
`FreeNotification` for any `TComponent`.

A sweep for the same shape — validates but never registers — found no others.

### The event layer: where collapsing stops being cheap

The 407 event setters were the next layer, and measuring them changed the
answer rather than confirming it.

| | instances | shapes | lines |
|---|---|---|---|
| `SetOnXxxFunc` | 407 | effectively **1** | 3,206 |
| `InternalOnXxx` | 405 | 93, over 16 signatures | 7,017 |

The setters are the purest duplication in the whole tree — the two largest
groups cover 95% and differ only by `Self.OnClick :=` versus `OnClick :=`, which
is the same statement. And they cannot be shared:

```pascal
FOnClickFunc := Value;
if Value <> '' then Self.OnClick := InternalOnClick else Self.OnClick := nil;
```

Every token that varies is an *identifier* — a field, an FMX property, a method.
Delphi has no way to abstract over a property name at compile time, so the only
routes are generating the units from descriptors or binding the property through
RTTI at runtime. The helpers collapsed because they were functions over values;
this does not, because it is names.

~~That is the honest boundary of "collapse the boilerplate".~~ **It was
not, and the premise was right while the conclusion did not follow.
2026-08-19, see section 37.** Delphi cannot abstract over a property name
at compile time -- and it does not have to. The name is fixed *inside* a
helper, and there are 19 names against 369 sites.

### Done anyway: the callback plumbing

What the event layer *does* expose to sharing is the part that runs on values.
`ExecuteCallback` and `ExecuteCallbackWithResult` were written out in all 27
units, 1,650 lines in eight and nine near-identical shapes, differing only in
the wording of the error line. They now forward to `ControlCommon.RunCallback`,
which takes the engine, the output and an owner name:

```pascal
procedure TBasButton.ExecuteCallback(const FuncSignature: String;
                                     const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'Button');
end;
```

**1,452 lines removed.** The IDE compiles 142,130, down from 143,515. The one
observable change is the error line, now uniform and carrying the failing
signature, which not every previous version did.

### Unified: the handle a callback receives

264 dispatchers passed `Pointer(Self)` to the BASIC callback and 141 passed
`Sender`. All 405 now pass `Pointer(Self)`.

This is a normalization, not a repair, and the check that established it is
worth keeping: every `InternalOnXxx` is bound to `Self.OnXxx`, so FMX fires it
with `Sender = Self` and the two forms agreed at runtime. The one place an
event is bound to a child — `FTimer.OnTimer` in `MediaPlayerLib`, where `Sender`
really is the inner `TTimer` and not the control — already passed
`Pointer(Self)`.

What it buys is that the agreement no longer depends on that. `Pointer(Self)` is
unconditionally the handle the program registered the callback against;
`Sender` is whatever FMX supplies, and an unregistered inner object handed to
BASIC would be indistinguishable from a fabricated pointer — the failure mode
`ScrollBoxLib` had. Binding one of these 405 events to a child later is now a
one-line change instead of a silent bug.

The dispatch tails — the argument packing before the call — are the remaining
shareable piece: 16 signatures, of which about ten carry weight. That would cut
into the 7,017 lines, and is the next thing worth measuring.

---

## 10. Taking FireMonkey out of the engine

Executed on 2026-08-17, after the roadmap's five fronts.

### What the coupling actually was

| Unit | FMX |
|---|---|
| `lexer.pas`, `parser.pas`, `basic.pas`, `UnitGC`, `HandleRegistry` | none, already |
| `UnitUtils.pas` | `FMX.Graphics`, `FMX.Types` |
| `exec.pas` | eight FMX units in the interface |

Shallower than it looked. `exec.pas` used those eight units for **six call
sites** serving three concerns: the BREAKPOINT dialog, the INPUT statement, and
`Application.ProcessMessages`. `UnitUtils` had 78 uses of FMX-looking types, of
which 76 were `TAlphaColor` and `TAlphaColorRec` — which live in
`System.UITypes`.

### What changed

The engine already knew the right pattern and had applied it once: `PrintProc`
is a host callback, which is why the PRINT statement never depended on a UI.
The other three interactions were hardwired instead. They now follow the same
shape:

| Callback | Purpose |
|---|---|
| `InputProc` | ask for a value |
| `ConfirmProc` | ask a yes/no question |
| `YieldProc` | let a host with a message loop pump it |

Both requests carry a continuation rather than returning a value, so a host
whose dialogs are asynchronous answers later without blocking the VM — exactly
what the FMX code did. All three may be left nil: INPUT then keeps the default
the program supplied, and BREAKPOINT continues.

Suspending timers around a breakpoint moved to the host too, which is what let
`exec` drop its dependency on `TimerLib` — a GUI library that pulled the entire
FMX stack into the engine through a single line.

`LoadImageFromWeb` moved to `Libs/GUI/GuiUtils.pas` on the host side; it takes
an FMX `TBitmap` and is called only by GUI libraries. `ValidMethod` took a
`TFMXObject` but only reads `ClassType`, so it takes `TObject`.

Removed along the way: an `EInvalidFmxHandle` clause in two exception blocks
that could never fire, because the `Exception` handler above it caught
everything first.

### The guard

`tests/NoFmxProbe.dpr`, built by `tests/build-nofmx.ps1`, links the core with
the FMX directories **removed from the compiler's search path**. Putting an FMX
reference back into the engine is then a hard build failure, not something the
ordinary suites would miss.

It also runs INPUT from stdin — impossible before, since INPUT was hardwired to
a modal dialog.

```
18,799 lines, and a BASIC program runs.
```

### What it buys

- The engine can be hosted from a console, a service, a test harness, or a VCL
  application
- INPUT works outside a window
- It is the prerequisite for moving the VM off the UI thread: those
  `ProcessMessages` calls were the reason the VM needed that thread

### Defect found while validating on a device: BREAKPOINT hangs Android

Running the validation applet on a Galaxy S24 exposed a defect that **predates
this work**. The engine's `BREAKPOINT` parks the VM:

```pascal
ExecStatus := TExecStatus.esIdle;
```

and the main loop then spins, waiting for the host to answer:

```pascal
if ExecStatus <> esRun then
begin
  if Assigned(FYieldProc) then FYieldProc();   // Application.ProcessMessages
  TThread.Sleep(16);
  continue;
end;
```

The dialog is a native Java dialog, and its result comes back through the
Android main looper. That loop never returns to the looper, so the answer can
never arrive: the spin is infinite and Android kills the app as not responding,
in about three seconds.

`INPUT` is unaffected, and the contrast is the proof. It is asynchronous by
design — the statement names a function, and that function is the continuation
the host calls back into. It never parks the VM, so control returns to the
looper, the dialog appears, and the answer arrives whenever the person gives
it. On the device INPUT works and BREAKPOINT does not.

Confirmed pre-existing: the code before the host callbacks had the identical
structure, and its own comment already named the risk — *"On mobile devices
this drains battery and can trigger Android ANR or iOS watchdog."* The
`Sleep(16)` addressed the battery half and could not address the other.

Bisected on the device: with the `BREAKPOINT` line removed, the same applet
runs to completion on Android — 30 printed lines, the error-policy check, the
handle check, and the INPUT dialog returning its value after the script ended.

### Repaired by degrading rather than by pausing

Three options were weighed.

*Suspend and resume.* Make `ExecuteProgram` return at a breakpoint and let the
host call `Resume()` from the dialog's callback. Feasible at the top level,
since `PRG_IP`, `STKP`, `BASEP` and both memories are object fields rather than
native stack. It breaks for a breakpoint inside `ExecuteFunction` — a timer
tick, an `INPUT` continuation — where a live native frame cannot be unwound and
resumed, and it changes what a returning `ExecuteProgram` means for every host
and for the test runner. The fallback below would still be needed for the
nested case, leaving two mechanisms where one would do.

*VM on a worker thread.* The real repair, and section 3.6's subject. The
breakpoint blocks the worker, the UI thread stays free, and the hang becomes
impossible by construction; it also ends the reason `YieldProc` exists at all.
The cost is marshalling every GUI library call to the UI thread across all of
`Libs/GUI/`. A project, not a patch — still owed.

*Degrade where the VM cannot be parked.* Taken.

The engine already had the seam: with no `ConfirmProc` assigned, `fBreakpoint`
reports to the trace and returns without ever setting `esIdle`. Two changes
make that path worth taking.

`CanPauseForHostDialog`, declared in `exec.pas`, reports whether the platform
can deliver a modal answer to a calling thread that is already blocked — false
on Android and iOS.

`fBreakpoint` consults it at the point of decision, so parking requires both
someone to ask *and* a platform that can answer. On those targets `ExecStatus`
never reaches `esIdle` whatever a host assigns, which is what turns the hang
from avoided into impossible. The first cut of this fix left the check to the
hosts alone, and that was too weak: anyone embedding the engine who wrote
`Engine.ConfirmProc := Handler` without reading the note would have hung
exactly as before, on information the engine held and never consulted.

Both hosts still gate the assignment — a handler that will never be called is
worth not installing — but the guarantee no longer rests on their remembering.

And the unset path now carries the whole frame rather than the message alone:

```
[BREAKPOINT] checkpoint reached (Line 25)
             n = 7
             s$ = "frame"
```

which is the half of a breakpoint that still means something on a phone, where
the application is its own debugger and there is no separate window to pause.

`tests/suite/15_breakpoint_degrade.bas` guards it. The headless runner installs
no `ConfirmProc`, so a regression that parks the VM stops that file's output and
the runner kills it on timeout.

Block 4 of the validation applet runs again on every platform.

Running it produced one further correction. The variable dump sat inside the
branch taken only when the VM does not park, so the desktop — where a dialog
follows — logged the line and the message and nothing else. The trace was
therefore richer on a phone than on a workstation, and answering the dialog
discarded the values for good. The dump now runs above the branch: the frame
reads the same everywhere, and where a dialog does appear it repeats the values
rather than being the only place they exist.

### Validated on the devices, not only in the suite

**Android** — Galaxy S24 over `adb`, one press of Run. The applet runs to
completion and block 4 prints:

```
[BREAKPOINT] checkpoint reached (Line 52)
             bpcount = 3
             bpname$ = "frame dump"
  PASS - execution continued past the breakpoint
```

The process stayed alive throughout and the window kept focus — no system
"not responding" dialog. This is the same statement that killed the app in
about three seconds.

**Linux** — over PAServer. The dialog appears carrying the frame and the script
pauses, so the guard costs the desktop nothing. **Yes** resumes; **No** aborts
at the breakpoint and block 5 never runs, which exercises the `ended := true`
arm of the callback. That arm is reachable only from a host that can pause, so
no amount of mobile testing could have covered it.

All five blocks pass on Windows, Linux and Android.

### What it does not touch

The GUI libraries are still FireMonkey, and should be — they exist to wrap it.
The separation is: `Libs/GUI/` bound to FMX by definition, everything else
meant to be free of it. — Meant to be — is doing a lot of work in that
sentence; see below.

---

## 12. A green check that was answering the wrong question

Found 2026-08-19, while folding the engine in and writing down what `engine/`
means now that it is not a repository.

The claim under test was the one this document made a paragraph ago: that the
engine is free of FireMonkey. `tests/build-nofmx.ps1` existed to hold it, and
its header said it compiled "with the FMX unit directories removed from the
compiler's search path, so any reference to FireMonkey from the engine is a
hard compile error". It passed. It had always passed.

Three units under `engine/` import FMX in their interface `uses`, with no
conditional — `StdLib`, `StrLib`, `SysLib` — and the probe links two of them.

The path trick never worked. `dcc64` ships the compiled FMX `.dcu` files in
`lib\Win64\release`, the same directory as the RTL's own — 209 of them — so a
search path holding "the RTL only" holds all of FireMonkey too. Removing the
FMX *source* directories excluded nothing. Compiling the probe with a detailed
map and counting what actually linked: **58 FMX units**.

So it passed for a reason unrelated to what it asserted, which is worse than
not having it. A red check gets investigated. A green one answering a question
nobody asked closes the question instead, and this one closed it long enough
for the claim to reach this document and the onboarding guide.

**What replaced it.** The question is about `uses` clauses, so it is now asked
of `uses` clauses — `tools/check-fmx-boundary.py` reads them and holds the
answer as a ratchet:

| Unit | Why it still reaches FMX |
|---|---|
| `StdLib` | `processmessages()` and `handlemessage()` call `Application` |
| `StrLib` | the clipboard functions go through `IFMXClipboardService` |
| `TimerLib` | a GUI library on purpose, kept here because `exec.pas` needs it |

A fourth unit fails the run. So does an entry that stops being true, so the
list cannot rot into a comment. `SysLib` was the fourth when this started: its
`FMX.Forms` was a dead import, used for nothing, and removing it cost nothing.

`NoFmxProbe` stays, with its claim corrected. It demonstrates something real
and worth guarding — the interpreter running in a program with no form, no
`Application` and no window, `INPUT` included, reading stdin through the host
callback that replaced the FMX dialog. That was always what it proved.

~~**Left as named work, not fixed here.**~~ **Done with 2.3, and this
paragraph outlived it.** `StdLib` and `StrLib` wanted the treatment `PrintProc`
and `InputProc` already had: a host callback, so the engine asks for a clipboard
or a message pump rather than reaching for one. They were left here because
`processmessages()` is *literally* a question about which thread owns the
message loop, so answering it before the flip would have been wasted work.

The flip happened, and so did this. `engine/utils/HostServices.pas` holds four
procedure variables — `SetClipboardText`, `GetClipboardText`, `PumpMessages`,
`HandleOneMessage` — where unassigned means the service does not exist rather
than that something failed. Both hosts install all four.
`tests/suite/17_host_services.bas` pins the empty answer, which is the case that
would otherwise be an access violation on a nil procedure.

Corrected 2026-08-19, along with the identical note in the plan. See section
32.

**The lesson**, since this is the second time this pass that running something
contradicted reading it: a check is not evidence until it has been seen to
fail. This one was never watched going red, so nobody learned that it could
not. Writing the negative test — adding an FMX import to a unit that has none,
watching the ratchet catch it — took under a minute.

---

## 13. The same rot, in the checker next door

Found 2026-08-19, in Phase 4.2, looking for pages that still describe the
language as it was before Phase 1.

`tools/check-doc-blocks.py` keeps a baseline of code blocks that are known not
to compile, so that a page's existing problems do not drown a new one. Five of
its twenty-two entries named files that no longer exist — `SkillLib.md`,
`P9EngineLib.md`, `IntelligenceEngine_Spec.md`, all retired with the AI archive
in 1.6.

The checker *noticed*. It computed the set of known failures that no longer
occur, printed them, and said what to do about it — and then returned zero.

So the notice went out on every run and nothing acted on it, which is the same
failure as §12 wearing different clothes: §12 was a check that could not go red,
this was a check that chose not to. Worse here, because `check-all.py` reports
each check by its last line of output, and the last line of this one was a dead
filename. The summary table read:

```
ok    code blocks    New docs/AI/SkillLib.md
```

A verdict slot containing the name of a file that had been deleted, on a green
run. It had looked like that for as long as the archive had been gone, and it
went unread every time because the `ok` in front of it answered the question.

**Fixed:** a stale entry now fails, and the report says which of them lost their
file, since that is the usual cause. The baseline went from 22 entries to 17.

**The general shape**, now that it has happened twice in two days: a list that
excuses things has to fail when it stops describing the tree, not merely mention
it. `check-fmx-boundary.py` was built with that property on the same day and it
was not a coincidence — it was the lesson from §12, applied once and then found
to be needed again ten metres away.

So the rest were asked the same question, immediately, rather than left as a
suggestion at the end of a section.

**`gen-doc-examples.py`** parks claims the engine contradicts. `PARKED` is
empty — its one entry was `instr("Hello", "ll")`, and 1.1 resolved it by fixing
the engine. Nothing to rot.

**`check-links.py`** does not keep a list at all: it asks git, per run, which
targets are deliberately ignored. That cannot go stale. But it had a subtler
version of the same defect. A gitignored target *resolves* on the machine that
has the file sitting in its working tree, so it never reaches the failure path,
so the exception is reported only on a clone — and stays invisible on the one
machine that could act on it. Here the run said `863 internal link(s), all
resolve` and nothing else.

It now names them on every run, whether or not they resolve:

```
2 linked file(s) git ignores, present here and nowhere the repository
can see (65 MB):
  Website/assets/ebooks/Computer Spacegames (1982)(Usborne Publishing).pdf
  Website/assets/ebooks/programas_de_jogos_espaciais.pdf
```

Not a failure — they are deliberate — but 65 MB the site serves and the
repository has never seen, which **4.6 has to decide about**: if the repository
becomes the site, these either get committed or the links break.

Writing it took three wrong versions, each caught by looking at the output
instead of the code. It reported nothing, because `every_file()` answers
relative to `Website/` and the open failed into an `except OSError: continue`.
Then six files, because searching the page text counts a filename discussed in
prose — `downloads.html` names `Translations.ini` and points at it nowhere.
Then three, because an absolute URL has a last segment too, and
`github.com/AndreMurtaX/Plan9Basic` ends in the name of the Linux binary.

---

## 14. And then I built the same defect again, on purpose to avoid it

Same day, Phase 4.6, writing `tools/package-site.py` — the script that assembles
what belongs on the server, so that publishing stops being a judgement about
which of 124 pages changed.

It has a guard. Some files the pages link to are not in the repository, and
uploading without them publishes a broken link, so the packager refuses:

```
1 file(s) the pages link to are not on this disk:
  Website/assets/ebooks/programas_de_jogos_espaciais.pdf

uploading without them would publish a broken link.
```

That is the output *after* the fix. The first version could not produce it.

It asked `git ls-files --others --ignored` for the files it needed — and that
command reports files, not paths, so it only ever lists things that exist.
Moving an ebook out of the tree did not make it missing. It made it **not
needed**: the set the guard compares against shrank by exactly the file that had
gone. The packager produced a package one file smaller and reported success.

Written on the same day as §12 and §13, both of which are about checks that
cannot fail. Knowing the shape of the mistake did not prevent the mistake. What
caught it was the habit those two produced: move the file, run it, watch for
red. Thirty seconds, and it was the only thing standing between this and a guard
that would have been quietly decorative for as long as it existed.

**The fix** is `git check-ignore`, which answers about paths rather than files
and therefore works on one that is not there — the question actually being asked.
Combined with the broken links `check-links` already finds, since a linked file
that is gone is a broken link before it is anything else.

**What generalises**, and it is not "be careful": a guard whose input is derived
from the same state it is guarding cannot see that state change. The needed-set
came from the disk, and the thing being checked was the disk. Nothing about
attention fixes that, and no amount of reading the code reveals it. Running it
does, immediately, every time.

---

## 15. The website is part of the product, and nothing knew

Found 2026-08-19, by the author asking a question about a page rather than by
any check.

The question was small: `downloads.html` still references the compiled
environments, is that right? The answer was no, and the answer underneath it was
worse.

**First, the small one.** 4.4 removed the download buttons and rewrote the page
title and intro. Its commit message says the page *"now describes running what
you built"*. That was asserted, not read. Step 1 of 3 still said **"Download the
executable — Click the Download .exe button above"**, and so did the Linux and
Android sections: five places telling a reader to press a button that no longer
existed. The claim was made about content that had not been opened.

**Then the real one.** Chasing it turned up what the site actually is:

| Path | Fetched by |
|---|---|
| `assets/devenv/Translations.ini` | the IDE, first run of every install |
| `assets/examples/ExamplesBrowser.bas` | the IDE, first run |
| `api/examples.php` | the Examples Browser applet |
| `assets/sounds/{lunar,missile,snake,invaders}/` | four demo games |

The site is a **runtime backend**. `UnitMain.pas` line 25 fetches its
translations from `plan9basic.com/assets/devenv/Translations.ini` on first run,
and all of these return 200 today.

Earlier the same day, `assets/devenv/` had been moved out of the publish tree
for being unreferenced. Which it was — `grep` for `devenv` across 124 pages
returned zero, `check-links.py` agreed, and the directory held 63 MB of
binaries nothing pointed at. Publishing in that state would have 404ed the first
run of every fresh installation, silently, and no check in the repository would
have disagreed.

The reason none could: **those URLs live in Pascal, not in an `href`.**
`check-links.py` reads pages. A string constant in a `.pas` file is invisible to
it, and the file being unreferenced *by pages* was true and irrelevant.

**Fixed:** `Translations.ini` is back in the tree and now tracked — the ignore
rule excludes the directory's contents with one exception, since git cannot
re-include a file inside an excluded directory. And `tools/check-site-deps.py`
asks the question `check-links` structurally cannot: for every plan9basic.com
URL in Pascal or BASIC source, is the file in `Website/`? Both failure paths
watched going red before it was trusted.

**And one thing cannot be fixed from here.** `api/examples.php` is PHP on the
host; its source has never been in this repository. So **an upload must merge,
not replace** — wiping the document root and copying `Website/` over it deletes
that endpoint. `PUBLISHING.md` now opens with that, because it is the kind of
mistake that is made once and discovered by users.

**What this adds** to §12 through §14, which were all about checks that cannot
fail: this one is about a question no check was asking. Every checker here reads
one language — pages, or Pascal, or BASIC — and the dependency ran between two of
them. Coverage of each says nothing about the seam.

It was found because somebody read a page and asked.

---

## 16. The engine asks for platform services instead of reaching for them

Done 2026-08-19. §12 named this and left it: `StdLib` calling
`Application.ProcessMessages` and `Application.HandleMessage`, `StrLib` going
through `IFMXClipboardService`. Three imports, and the whole reason `engine/`
could not link without a windowing framework.

**The cost was not tidiness.** Those three imports pulled **58 FireMonkey units**
into anything that wanted `left$()`. A console host, a service, a test runner,
a future non-FMX front end: all of them paid for a clipboard they never asked
for.

**`engine/utils/HostServices.pas`** holds four procedure variables the host
fills in — set the clipboard, get the clipboard, pump the message loop, wait
for one message. `StdLib` and `StrLib` call them and no longer import FMX at
all. The hosts implement them, which is where FireMonkey belongs: they already
have a window.

This is not the per-module global state Phase 2.2 removed, and the distinction
matters. That was 35 libraries each holding their own copy of an engine
reference, filled in at registration and wrong the moment a second engine
existed. A clipboard is one resource belonging to the process, as is the message
loop. One set, filled once.

**Unassigned is an answer.** A headless runner has no event loop and no
clipboard, so `processmessages()` returns 0 rather than 1, and `copytext$`
reports `ERR_CLIPBOARD_ERROR` — which is exactly what the missing platform
service produced before. `tests/suite/17_host_services.bas` pins that, because
the failure it guards against is an access violation on a nil procedure.

**Measured, not assumed:**

| | before | after |
|---|---:|---:|
| engine units importing FMX | 3 | 1 |
| FMX units linked into the console host | 58 | **0** |
| console host binary | 10.2 MB | **3.16 MB** |

The one remaining is `TimerLib`, which is a GUI library on purpose.

**And the probe finally proves its claim.** `build-nofmx.ps1` spent months
asserting the engine linked without FireMonkey, by a search path that excluded
nothing (§12). It now compiles with `-GD` and reads the linker's map: a single
`FMX.` line fails the run. Watched going red first — one `uses FMX.Forms` added
to `NumLib` brings back all 58, which is its own confirmation that those 58 were
StdLib and StrLib's doing and nothing else's.

So the boundary now has two independent guards, one on the source and one on
the link, and neither was trusted until it had been seen to fail.

---

## 17. The handover into the VM, and the yield points that were not there

Done 2026-08-19. The other half of 2.3: the seam built earlier marshals **VM to
UI**, and a worker VM also needs **UI to VM** — a click or a timer tick that
fires on the UI thread while the VM runs elsewhere.

**The design turned out much smaller than feared.** Every one of those paths
reaches the VM through one method, `TBasicEngine.ExecuteUserFunction`:
`TimerLib`'s `OnTimer`, and all 405 control callbacks through
`ControlCommon.RunCallback`. So the routing goes there, and **no call site
changes at all**. If the caller is not on the thread that claimed the VM, the
call is queued and waited for; otherwise it runs exactly as before.

**The wait is the part that cannot be naive.** The VM may marshal a library
call back to the UI thread through `TThread.Synchronize`, which completes only
when the main thread runs `CheckSynchronize`. A plain `WaitFor` on the main
thread parks the very thread the VM is waiting for: both sides stopped, nothing
reported. So the wait is a loop that keeps answering, with a timeout, because a
VM wedged without a yield point should give the interface back rather than hold
it.

**And then the probe hung, which is how the real gap was found.**

`YieldProc` is called in exactly two places: the pause loop, when the VM is
already idle, and after a `PRINT`, throttled. Both are right for pumping a
message loop — there is nothing to show and nothing to do. Neither fires while
a program computes. The probe's program looped without printing, so the queue
was never drained and the caller waited until it timed out.

The existing yield points were sufficient for *refreshing an interface* and
useless for *answering it*. That is not a bug in them; they were built for a
different question.

So `TExec` gained `DrainProc`, called between two instructions every 512 of
them — the only place a stack machine holds no caller and can take another.
`nil` for a host that kept the VM on the UI thread, so it costs one null test
per interval.

**What is pinned.** `tests/VMThreadProbe.dpr`, because a BASIC test cannot: it
has no threads, and which thread a call runs on is the entire subject. It runs
a program on a worker, queues a call from the main thread, and checks the answer
comes back. Under a 60-second kill, since **the failure this guards against is a
deadlock, and a deadlocked test does not fail, it waits.**

Isolating that first failure was worth the two minutes it took. A direct call
with no thread claimed was added above the queued one, so "the signature is
wrong" and "the handover is broken" stopped being the same red line. The
signature was fine.

**What 2.3 still needs**, so this is not read as finished:

- `ExecuteProgram` is handed the memo's own `Lines`, so every `PRINT` writes a
  UI object from the worker. That is a data race per line of output.
- `UnitGC.GlobalCallbackBusy` is a plain Boolean. It stops a callback inside a
  callback on one thread and does nothing across two.
- No host claims a thread yet. All of this is inert, deliberately, and proved
  by the suites being unchanged at 387 and 614.
- Nothing has run on a device.

---

## 18. Output that waits to be fetched, and a guard that could be claimed twice

Done 2026-08-19, closing two of the three hazards §17 left open.

### The output

`ExecuteProgram` is handed a `TStrings`, and on a real host that is a `TMemo`'s
own `Lines`. `PrintProc` appended to it directly, which from a worker is a data
race on **every line of output** — the most frequent operation a BASIC program
performs.

The text now waits in the engine and the host comes and gets it, on the host's
thread, through `DrainOutput`. The append rule — what `PRINT` emits continues the
line already there, and only an embedded break starts a new one — moved into a
method both paths call, so the threaded and unthreaded versions cannot drift
apart on the one piece of behaviour a reader would notice.

`OnPrintOutput` moved with it, and fires during the drain rather than from
`PrintProc`. A handler that touches the interface now runs on the thread that
owns it, which is where a host would naturally have put one.

Pinned in `VMThreadProbe`: the list handed to `ExecuteProgram` is checked to be
**still empty** after the program has printed, and the text is checked to arrive
only when the host asks for it.

### The guard

`UnitGC.GlobalCallbackBusy` stopped a callback firing inside a callback. Tested,
then set. Sound on one thread, where nothing runs between those two lines, and
useless across two: both callers read `False`, both write `True`, both proceed
into a stack machine that holds one caller.

Now `ClaimCallbackGuard`, one interlocked compare-and-exchange, so exactly one
caller can win however many arrive together. The cheap read stays for the
early-out, because a caller that loses *there* has merely asked twice.

**Measured before sweeping, and the measurement halved the work.** 43 references
across 15 files — but 19 of them were inside commented-out blocks, left behind
when those libraries were reworked. 24 live sites in 8 files, every one with the
identical three-line shape, which is what made a mechanical sweep safe.

Had that not been counted first, the sweep would have been written to handle
shapes that only exist in dead code.

---

## 19. The flip on a real device, and why it was rolled back

Attempted 2026-08-19 on a Galaxy S24 Ultra. Three real defects found, two fixed,
and one that stopped the attempt. **The runner is back on the UI thread**; the
engine mechanism stays, inert and tested.

Recorded in the order they were found, because each was hidden behind the last.

### The application stopped dying, which was the first result

Before any of this, `BREAKPOINT` on Android killed the process in about three
seconds. With the program on a worker, the applet ran, the window kept
responding, and the system raised no complaint. That much worked on the first
attempt.

Nothing printed, though, and nothing else happened.

### `YieldProc` means "pump the host's loop", which is precisely wrong on a worker

`ExecuteProgram` installs the host's `YieldProc`, and the runner's is
`Application.ProcessMessages`. On a worker that is a call into the message loop
of a thread that does not own it, from a thread that does not own the window.
Everything stopped there.

The probe had not caught it because the probe's host sets `YieldProc` to drain
the queue — which is what a threaded host *should* do, arrived at by writing
the test rather than by understanding the rule. The rule is: with the VM on a
worker, yielding is draining, and pumping belongs to the thread that pumps.

### Dialogs have to be raised from the thread that owns the window

With that fixed the program ran and reached `INPUT`. `TDialogServiceAsync` had
to be wrapped in `TThread.Synchronize` in `HostConfirm` and `HostInput`, and
then **the dialog appeared on the phone, raised from a worker**. Delphi will not
let an anonymous method capture an open array or a `const` parameter, so the
labels and the message are copied into locals first.

### And then answering it deadlocked, which is where this stops

Tapping OK produced an ANR. The chain:

1. `INPUT` completes on the UI thread and calls the BASIC callback `gotIt(v)`
2. that goes through `ExecuteUserFunction`, which is not on the VM's thread, so
   it queues and waits
3. the VM is parked in `esIdle` waiting for the input answer
4. the pause loop does `continue`, which skips the instruction dispatch — and the
   drain lives in the instruction dispatch

Both wait for each other.

> **This paragraph was wrong, and §20 corrects it.** What stood here said the
> obvious repair — draining in the pause loop too — was not a positioning problem
> but a re-entrancy one, running a BASIC function while the VM is parked
> mid-instruction. That was reasoned from the code and never tested. A test
> written the next morning showed draining while parked works, and that the
> repair was exactly the positioning fix it had been dismissed as.

### What was kept

The engine side is sound and stays: the queue, `DrainProc` in the instruction
loop, the output buffer, the atomic guard, and `CanPauseForHostDialog` deciding
by thread rather than by platform. All inert, all covered by `VMThreadProbe`,
and the suites unchanged at 387 and 614.

`runner/AppletRunner.pas` is reverted. A host that half-works is worse than one
that does not try: the device showed a window that said `Running...` forever.

**What the next attempt needs**, and it is now a specific question rather than a
vague one: *how does the VM accept a nested call while parked?* Either the pause
becomes a state the VM can safely run other work from, or callbacks arriving
during a pause are refused rather than queued, or the answer path stops calling
back into BASIC while the VM is parked. Three shapes, and choosing between them
is the work.

Two things about method, since this cost a morning. Every one of these three was
invisible to a headless test and obvious within seconds on the device — the
probe passes and always did. And the first symptom, an application that ran and
printed nothing, had three separate causes stacked behind it, each only visible
once the one in front was fixed.

---

## 20. The test that should have been written first, and what it corrected

Written 2026-08-19, after being asked to show the tests actually running.

§19 ended with a confident diagnosis: that a call arriving while the VM is
parked cannot be run, because a parked stack machine is stopped mid-instruction
and re-entering it corrupts the state the pause depends on. It read well. It
was reasoned entirely from the code, and it was **wrong**.

**What the test does.** `VMThreadProbe` now parks the VM for real. A host
installs a `ConfirmProc` that captures the callback and does not answer, the
program hits a `BREAKPOINT`, and the VM stops in `esIdle` and stays there. The
main thread then queues a call and the probe measures **how long the caller
waits**, because the failure being hunted is not a wrong answer but a caller
that is never released.

It runs twice, and the second run is the one that mattered:

| | caller released after |
|---|---|
| host with a `YieldProc` that drains | **12 ms** |
| host with no `YieldProc` at all | **5,197 ms** — the entire script timeout |

The second row is the device failure, reproduced on Windows in five seconds
instead of a twenty-minute build-deploy-tap cycle.

**And it names the real cause.** Nothing to do with re-entrancy: the first row
re-enters a parked VM and is fine. The pause loop drained only through
`YieldProc`, and on the device `YieldProc` had been set to nil — correctly,
because a real FMX host's `YieldProc` pumps the message loop, which from a
worker is exactly wrong. Removing it removed the only drain point the pause had.

So the repair is the one §19 dismissed: `DrainProc` in the pause loop as well as
in the instruction loop. Both rows now release in about 12 ms.

**Why this went wrong is worth more than the bug.** The reasoning in §19 was
plausible, specific, and produced a decision — roll back and redesign — that
would have cost days. What made it wrong was not carelessness in the argument
but that no argument was owed: the question was decidable by experiment in
minutes, and the experiment was not run.

The tell was there to be noticed. §19 already recorded that the probe *passed*
while the device failed, and treated that as a limitation of headless testing.
It was really a gap in the probe: every check ran against a VM that was
executing, and none against one that was parked. A test suite that cannot enter
the state a bug lives in will keep agreeing with you.

**The rule, since this is the second time in two days a conclusion was reached
by reading:** when a claim about behaviour is testable in minutes, it is not a
conclusion until it has been tested. §12 was a check that could not fail. This
was a diagnosis that was never made to.

---

## 21. The marshalling seam had never worked

Found 2026-08-19, immediately after §20, by writing the first test that
exercised it.

The seam is from §2.3: `TLinkFunction.NeedsUIThread`, set by 116 libraries, read
by `CallNative`, which hands the call to the host's `MarshalProc` when the VM is
not on the UI thread. Built, documented, committed, and marked inert *by design*
because no host had claimed a thread yet.

It was inert for a different reason. All seven dispatch sites did this:

```pascal
numF.Entry := ProgramFunctions[farFuncSign].Entry; //get entry point
```

`numF` is a fresh local `TLinkFunction`. One field is filled in. **NeedsUIThread
holds whatever was on the stack**, so the flag those 116 libraries were changed
to set never reached the code that reads it.

Two things make this worse than a missed assignment.

It is the exact hazard the flag's own commit message described — *"`Fn` is a
local record whose other fields were never assigned, so an unstated field is
stack garbage"* — noticed on the writing side, where every library was made to
state the value, and not on the reading side, where the value was thrown away.

And it is **not** merely a seam that failed to fire. Uninitialised stack memory
is not reliably zero. A call could have marshalled at random, on a host that had
installed a marshaller, for reasons nothing could reproduce.

**The test that caught it.** The GUI libraries cannot be linked into a console
probe — that would drag in the 58 FMX units the whole boundary exists to keep
out — so one registered function stands in for all 96 that carry the flag. It
records the thread it ran on. That is the only thing the seam is responsible
for, and it is enough.

**Fixed** by copying the whole record at all seven sites rather than one field.

**What this says about "inert by design".** Three things in this project have
been committed inert and correct-by-inspection: the seam, the flags, the queue.
Two of the three were fine. This one was not, and nothing would have found it
until a host claimed a thread and a user reported that their button did nothing
in a way nobody could reproduce.

Inert code is untested code wearing a justification. It is worth having a probe
that exercises it *as* inert code, before the day it stops being inert.

---

## 22. The flip, redone, and watched running

Done 2026-08-19. The applet runner now runs the program on a thread of its own.
It is the same change §19 rolled back, over parts that are all tested now rather
than all inert.

**What it does.** `BtnRunClick` starts a worker, which claims the VM and calls
`ExecuteProgram`. A 50 ms timer brings output across with `DrainOutput`.
`MarshalProc` sends the FireMonkey library calls back to the UI thread.
`OnTerminate` reports the result, and runs on the UI thread already.

**`YieldProc` is set to nil inside the worker**, which is the piece §19 needed
and did not have. It means "let the host's event loop run", and on a worker that
is a call into a loop belonging to another thread. The VM's yielding is now
`DrainProc`, which runs both between instructions and — since §20 — while the VM
is parked waiting for an answer.

**Watched on screen, on Windows:**

- the program runs while the window keeps redrawing and the status says
  `Running...`
- `PRINT` output arrives in the memo, brought over by the timer, from a thread
  that never touches it
- the `BREAKPOINT` dialog is raised **from the worker** and renders complete
- answering it continues execution

That last pair is the whole point of the exercise. A dialog raised by a thread
that does not own the window, answered by the thread that does, releasing a VM
parked on a third path.

**One thing is not verified, and is marked as such in the code.** `INPUT`'s
dialog opened blank the first time, raised through `Synchronize`. The reasoning:
`INPUT` does not park the VM — the script carries on and the answer arrives later
through a callback — so there is nothing for the worker to wait for, and holding
it inside the dialog's construction is wrong. `TThread.Queue` instead.

~~That repair has not been seen working.~~ **It has, and the reasoning above was
not what fixed it.** The author ran the applet the same day and reported the
dialog appearing, the breakpoint parking and the run finishing after the answer.

But section 23 is where that happened, and what it found was a different cause
entirely: `FreeAndNil` in the worker's own `OnTerminate`. `Queue` instead of
`Synchronize` is still right, and it is not why the dialog was blank. The
paragraph above is left struck through rather than deleted because a correct
change made for a wrong reason is worth being able to find again.

Corrected 2026-08-19. See section 32.

**Why this is committed anyway**, having rolled back once for less: §19 rolled
back a flip whose core was unproven and whose failure was a window that said
`Running...` forever. This one has its core on screen. What remains is one
dialog on one path, named, with the check that settles it.

---

## 23. One symptom read as two, and a deadlock of my own making

Found 2026-08-19, after four wrong diagnoses. The applet's `INPUT` dialog opened
with its title and nothing inside it, and the application stopped responding.

**The cause, in one line:** `VMWorkerDone` is the worker's `OnTerminate`
handler, and it called `FreeAndNil(FVMWorker)`.

`OnTerminate` runs on the UI thread, through `Synchronize`, called from the
worker's own epilogue while the worker is still alive waiting for it to return.
`TThread.Free` calls `WaitFor`. So the UI thread waited for a worker that was
waiting for the UI thread. Neither moved again.

Fixed with `FreeOnTerminate := True` and a handler that only clears the
reference.

**The blank dialog was the same event.** The window had been shown a moment
earlier and the UI thread froze before it could paint. Two symptoms, one cause,
and treating them as two is what cost the morning.

### Four diagnoses, each confidently wrong

1. **`Synchronize` versus `Queue`.** `INPUT` does not park the VM, so holding
   the worker inside the dialog's construction is wrong. True, and irrelevant.
2. **The lifetime of the open arrays.** An open array parameter is the caller's
   memory and `FMX` shows that dialog with `Show`, not `ShowModal`, so it might
   read its prompts after the frame is gone. Plausible, testable, tested — and
   the data was correct at every point measured.
3. **FireMonkey discarding what it was given.** Written down as a conclusion
   with a diagnostic to back it: caption, prompt and default all present, on the
   main thread, immediately before the call, blank window after. Correct input,
   blank output, therefore FMX. The reasoning was sound and the premise — that
   the window had rendered at all — was false.
4. So the dialog was rebuilt by hand, forty lines, full control. **It came up
   blank too.**

### The signal that was there to be read

Point 4 was the answer and it was mistaken for another failure. Two
implementations sharing nothing but their surroundings, failing identically,
point at the surroundings. Instead of reading it that way, the investigation
carried on inside the second implementation.

Every measurement taken was of the dialog's *contents*. The bug was in what ran
*after* it: the seven lines of thread teardown that nobody had looked at,
because the dialog was where the symptom appeared.

**The rule this leaves:** when two independent implementations of a thing fail
the same way, stop investigating the thing. And when a symptom has two
descriptions — "it renders blank" and "it freezes" — check whether they are one
event before hunting two causes.

### What it cost, and what would have prevented it

Six build-and-run cycles, each needing a human to press a button, because the
applet has no automated test of any kind. Everything about it has been validated
by eye since it was written.

That is the standing gap this episode exposed, and it is worth more than the
bug: `VMThreadProbe` covers the engine's threading thoroughly and the host's not
at all. A host harness that drives Run, answers the dialogs and reads the output
would have found this in one run, alone, in seconds.

---

## 24. The applet tests itself

Done 2026-08-19, closing the gap §23 named an hour after naming it.

`Plan9BasicApplet.exe --selftest` presses its own Run, answers its own dialogs,
writes the output beside the executable and exits with a verdict. `verify.ps1`
runs it, so the count is now eight steps.

**What it covers that nothing else did.** `VMThreadProbe` exercises the engine's
threading thoroughly and the host's not at all, and the host is where every bug
in this phase lived: the worker's lifetime, the drain timer, the marshaller, the
teardown. All of it had been checked by eye since it was written.

**Watched failing before being trusted**, and the way it failed matters.
Reintroducing the §23 deadlock — `FreeAndNil` in the worker's own `OnTerminate`
— hangs the applet, and **its own 30-second timeout never fires**: a deadlocked
UI thread cannot run the timer that would report it. Only the outer kill in
`verify.ps1` ends it.

That is worth stating plainly, because the internal timeout looks like the
safety net and is not one. A process cannot time itself out when the thing that
failed is the thread that would notice.

**Two small things it cost.** `FindCmdLineSwitch` strips one switch character,
so `--selftest` arrives as `-selftest` and never matches — the first run went
straight past the flag and sat there as an ordinary window until the harness
killed it, which looked exactly like a deadlock and was not. And Delphi will not
capture a `const` parameter in a closure, so the auto-answers copy their
callbacks to locals first.

**What it does not cover**, and should be said rather than assumed: the dialogs
answer themselves, so nothing here proves one renders. That is why §23's
blank-window hunt needed a person, and it still would. What this catches is
everything around them, which is where the fault actually was.

**Confirmed by hand afterwards**, which the harness cannot do: the platform's own
`InputQuery` renders correctly again, prompt and default and all, and accepts a
typed answer. The bespoke dialog that §23 built was never needed — it was a
repair for a fault that was somewhere else entirely, and removing it is the last
trace of that detour to disappear.

---

## 25. Compiling 225 applets proved they were valid source and nothing else

Found 2026-08-19, because the author declined to make the repository public
until the IDE and the applets that exercise the GUI libraries had been tested,
which was the right call and this section is the evidence.

`check-all.py` ran every shipped applet with `--compile-only`. The runner has
had a `--smoke` mode all along — compile *and run*, requiring only that nothing
raises. Turning it on took one word and found three things, one of them in every
game on the website.

### The platform detection in all nine games was broken

`os_name$()` answers `Windows 11`. So `instr(P$, "Windows")` is **0**, and:

```basic
if instr(PLATFORM$, "Windows") > 0 then SOUND_EXT$ = "wav"
```

is false. The sound extension is never set. The same line decides mobile:

```basic
if instr(PLATFORM$, "Android") > 0 or instr(PLATFORM$, "iOS") > 0 then IS_MOBILE = 1
```

and on Android `instr("Android 14", "Android")` is also 0, so a phone is not
detected as one.

This is 1.1's doing, and 1.1 was right: `instr` was documented everywhere as
returning a zero-based position and `-1` when absent, and the implementation
computed the position and threw it away. Correcting the engine to match its own
manual left every caller written for the old contract quietly meaning something
else.

Eighty comparisons across seventeen files, rewritten by meaning rather than by
pattern:

| written as | meant | now |
|---|---|---|
| `> 0` | found | `>= 0` |
| `<> 0` | found | `>= 0` |
| `= 0` | not found | `< 0` |

`>= 0` was left alone: under the new contract it already says "found", which is
why the scan flagged fifty-one files and only seventeen needed touching.

### Twenty-five library functions always answered 0

`Examples/42_test_buttonlib_basic.bas` asserts `button_free(b) = 1`. It had
always failed. The assignment that reported success lived inside a
garbage-collector block, and when that block was commented out it went with it:

```pascal
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(...);
//      Result.n := 1;          <- here
//    end;
      ClearError();
```

Eighty-one `*_free` functions return 1. Twenty-five did not, all in GUI
libraries, all the same shape. Fixed.

### And one assertion that was never true

The same file checks that a button's parent is the scrollbox it was created on.
FMX puts a scrollbox's children inside its *content* object, so it never was.
Measured rather than assumed: a button on a form reports the form; a button on a
scrollbox reports something else. The example's expectation was wrong, not the
library, and it now checks what is actually guaranteed.

### What this says about compile-only

Every one of these had been in the tree for months, in files whose whole purpose
is to demonstrate the language working. Compiling proved the source was valid.
It could not prove the programs did anything, and two of the three defects are
of the kind that leave a program running happily while doing the wrong thing.

`check-all.py` now runs them: 225 applets, about two minutes, and the games are
part of the regression net rather than decoration beside it.

---

## 26. The IDE tests itself, and the first run of it found a defect

Done 2026-08-19. `Plan9Basic.exe --selftest` loads a program, runs it, checks
its own console and exits with a verdict. `verify.ps1` runs it, so the count is
nine steps.

It matters more than the applet's. The IDE is the application on the download
page, it is the larger host at 143,966 lines, and until now **nothing exercised
it at all**. It is also still the host that runs the VM on its interface thread
— the runner was moved off it in 2.3 and this one was not — so having that
difference covered rather than assumed is worth something on its own.

### The first run failed, and the reason is a real defect

`FAIL - the program did not finish within 30s`, with a console holding the
welcome block and nothing else. Every run afterwards passed, four in a row, in
500 ms.

The difference was the network. On first launch the IDE downloads
`Translations.ini`, and when that arrives:

```pascal
if TransDownloaded then
  TThread.Synchronize(nil, procedure begin
    ...
    CmdCls();                          // <- the console is emptied
    PrintLn('Plan9 BASIC v' + VERSION);
```

It clears the console so the welcome block can be reprinted in the language just
downloaded. The test's program had already run, and its output went with it.

**That happens to users, not only to tests.** Run a program during the first
launch of a fresh installation and your output disappears when the download
lands. It is not deliberate — nobody chose to discard what the user had — it is
a side effect of reprinting a header.

~~Left as a finding rather than fixed, because the repair has a judgement in
it.~~ **Fixed 2026-08-19; see section 33** for why the judgement turned out to
be smaller than this paragraph claimed.

The test was made immune at the time: it accumulates the console as it appears
rather than reading it at the end, so a clear cannot erase the evidence.

### And a filter that read a hint as an error

The step failed once more before it settled, on this:

```
UnitMain.pas(267) Hint: H2219 Private symbol 'PrintSyntaxError' declared but never used
```

The build check matched `Error|Fatal`, and the *identifier* is called
`PrintSyntaxError`. Compiler diagnostics carry a colon — `Error:`, `Fatal:` —
and the filter now requires it, in all three places that had it.

Same shape as the scheme test in §13's neighbourhood: `'httplib.html'` starts
with `'http'`. A substring test wants the delimiter that makes it a token.

---

## 27. The IDE's own features, as opposed to the engine reached through it

Done 2026-08-19, extending §26. Running a program proves the engine works. These
are the things that *are* the IDE, and a fault in any of them loses somebody's
work, which is the worst thing a text editor can do:

- the editor and the program buffer staying two copies of one thing, in both
  directions
- switching between command and editor mode without disturbing the program
- save then load returning what was saved, and not leaving the previous program
  behind
- replace-all replacing all of them

**Watched failing.** `SyncEditorToProgram` was broken on purpose — one line, made
to assign an empty string — and the run answered:

```
FAIL - IDE feature: program -> editor did not carry the text
```

**And it littered.** The save-and-load check calls `CmdSave`, which writes into
the user's own documents folder, and the first run left `p9b-selftest-tmp.bas`
sitting among their real programs. A test that leaves a file in somebody's
working directory is not finished. It deletes it now.

That is a small thing with a general shape worth keeping: a test that exercises
a host exercises the host's *side effects* too, and the ones that reach outside
the repository are the ones nobody looks for.

---

## 28. Five of the nine games had dead keyboard handlers

Found 2026-08-19, when the author loaded `flappy_bird` in the IDE and its start
screen would not respond to UP. The first guess — mine and theirs — was the
remote desktop session eating the key events. It was not.

`TBasForm.InternalOnKeyDown` builds a signature and looks it up:

```pascal
Signature := LowerCase(FOnKeyDownFunc) + '@#n$$';   // form, key, char, shift
...
if UserFunctionsTable.ContainsKey(Signature) then
```

`ContainsKey` is exact. The game declared:

```basic
function OnKeyDown(sender#, keyCode, keyChar$)
```

which compiles to `@#n$`. Three parameters where four were sent, so the lookup
misses, and **the event is dropped in silence**. No error, no warning, no
message: the key is pressed and the program does not hear.

**Five of the nine games**, in seven declarations: `2048`, `asteroids`,
`breakout`, `flappy_bird`, `whack_a_mole`. The other four declared four
parameters and worked. The documentation had said four all along.

### Why nothing caught it

§25 turned on running the applets, which found three defects. It could not find
this one: a program run to completion is never sent an event. The suites create
controls and read their properties; they do not press anything.

And this is not a bug the language can report. A signature that does not match
is not an error — it is a function that was not called.

### The check that will

`tools/check-callbacks.py` reads both sides. The libraries declare what shape
they will call, in the `Signature := LowerCase(F...Func) + '@...'` lines the
dispatchers already contain. The programs declare what they wrote. Where a name
is registered, the two have to agree.

**1,176 registered callbacks across the tree**, every one now the right
shape. The figure first written here was 937, which was the count the check
could see before section 29 corrected it.
Watched failing first: putting the three-parameter declaration back into
`flappy_bird` produces

```
Demos/flappy_bird.bas
    onkeydown calls OnKeyDown with 4 parameter(s), and it declares 3
```

It covers every event kind, not only the keyboard — the dispatchers use eight
distinct shapes, from `@#` for a click to `@#nnnn` — so the same silent drop
cannot happen to `onclick` or `ontimer` either.

### What it says about the day

The author declined to publish until the applets and the IDE had been tested.
That decision has now produced four defects that shipped for months: a library
function that always answered 0, an assertion that was never true, eighty
comparisons written for a contract `instr` no longer has, and this. Every one of
them found by running something rather than reading it, and this last one only
because a person sat in front of a game and pressed a key.


## 29. The check itself skipped in silence, and the review that followed

Written 2026-08-19, after the author asked for a review of `Demos/`, having
tried to run `flappy_bird` from that folder.

### The check had the defect it was written to catch

Section 28 built `tools/check-callbacks.py` to catch a callback whose parameter
count does not match the signature the dispatcher sends. It read the dispatchers
with one pattern:

```
Signature := LowerCase(FOnKeyDownFunc) + '@#n$$';
```

The libraries use three forms, not one. Two hundred and thirty-six dispatchers
call `ExecuteCallback(LowerCase(FOnTimerFunc) + '@#', Args)` inline without ever
naming a `Signature` variable, and the track bar writes
`FOnChangeFunc.ToLower() + '@#'`. The check saw 937 of 1,176 registrations and
reported `ok` for the rest — skipping in silence, which is exactly the failure
the file was written to catch.

### And fixing it broke the other end

Widening the pattern made the check permissive. It keyed its expectations on the
event name alone, so `keydown` accumulated the arities of every control that
sends one — `[3, 4]` — and a three-parameter declaration was accepted again. The
original bug passed.

The shape of an event depends on **which control sends it**, so the key has to
carry the library too. Which prefix a library answers to is now read from the
library's own `Lib.Add('callout_onclick#@#$', Fn)` lines rather than guessed
from its filename, because `CalloutRectangleLib.pas` answers `callout_` and
`FloatAnimationLib.pas` answers `floatani_`. Keyed by `(library, event)` the
check is exact: **1,176 registrations, no event left unchecked**, and putting
the three-parameter declaration back into `flappy_bird` reports it again.

### The comments were wrong where it mattered most

Holding each dispatcher against the comment beside it turned up two
disagreements in the whole tree, and they were these:

```
  // Signature: funcname@#nn$ (form#, keyCode, keyChar, shiftState$)
  Signature := LowerCase(FOnKeyDownFunc) + '@#n$$';
```

`OnKeyDown` and `OnKeyUp` in `FormLib.pas`, documenting the keyboard handler
with its third parameter typed as a number where a string arrives. The count is
right, so this did not cause section 28's defect, but it is the comment a person
reads in order to write the handler that did. Corrected, and the comparison is
now part of the check.

### What the review of the nine games found

Every other class came back clean, and each was measured rather than read:

- every callback matches the shape its dispatcher sends
- every `instr` comparison uses the position contract, none the old flag
- every library call's argument count matches its registered signature, once the
  checker was taught that nine array families are registered in a loop for one
  to ten dimensions, so `dim#@` + `nStr` means arity 1..10 and not 0
- no callback names a function the program does not declare
- no array indexed from zero, in a language whose arrays start at one
- no boolean expression outside `IF`, `WHILE` or `UNTIL`

`flappy_bird` in particular loads no external file at all.

### The site was still handing out the broken copy

This is the part that matters, and it is why the author saw what they saw.

`Website/docs/examples.html` carries the source of every example inside itself,
in a JavaScript template literal. That embedded copy is what a reader copies and
runs. The nine games also exist as files under `Demos/`. Two copies of the same
program, and only one of them was ever fixed.

Every correction of this month landed in `Demos/` and none in the page. On
2026-08-19 the page was still serving:

- **seven keyboard handlers declared with three parameters**, in `2048`,
  `asteroids`, `breakout`, `flappy_bird` and `whack_a_mole` -- the exact defect
  of section 28, in the exact copy a reader takes
- **twenty-three comparisons written for the contract `instr` had before 1.1**,
  across seven of the games, breaking platform detection

Which explains the source the author pasted into this conversation after the
keyboard would not respond. They had copied it from the site. The repository had
been right for days; the thing people actually download had not.

Both copies now agree, in a diff of twenty-six lines against twenty-six, every
one of them an `instr` comparison or a keyboard declaration.

`tools/check-site-examples.py` holds them together from here, and
`check-callbacks.py` now reads the embedded examples as programs in their own
right -- **1,256 registrations** rather than 1,176, the eighty new ones being
the site's own copies, which had never been checked at all.

Only the nine games are paired by name. `calculator` exists in both places and
is two entirely different programs that happen to share a name, which is why the
pairing is an explicit list rather than a filename match.

### Nine PLAY buttons that lead nowhere

Each game entry carries a `url` alongside its code, and the page renders it as a
button:

```html
<a class="btn-play" href="${game.url}" target="_blank">PLAY</a>
```

All nine point at `https://plan9basic.com/docs/examples/games/<name>`, and all
nine answer 404 today. Nothing under `Website/` would answer them either -- the
directory does not exist -- so this is not something publishing would break. It
is already broken, and has been.

`check-links.py` did not see it because it reads relative links, and these are
written absolute against the site's own domain. Eighteen such paths exist across
the site; nine resolve to a file in `Website/`, and the nine that do not are
exactly these buttons.

The author chose to remove them. The button is gone, and with it the CSS rule
it was the only user of and the nine `url` fields nothing reads any more. The
`Code` button stays, which is the one that works: it opens the source, and the
source is now the corrected one. Watched in a browser afterwards -- nine cards,
nine `Code` buttons, no `PLAY`, no console error, and the modal for
`flappy_bird` showing `function OnKeyDown(sender#, keyCode, keyChar$,
shiftState$)` and `instr(...) >= 0`.

### The sounds are fetched from the live site, and most are not there

Four games — `lunar_lander`, `missile_command`, `snake`, `space_invaders` —
load audio over the network from `https://plan9basic.com/assets/sounds/`.
Checking all sixty combinations of game, sound and extension against both the
repository and the running site:

- **three files the site served were missing from `Website/`**: `lunar/start.wav`,
  `lunar/start.ogg` and `lunar/thrust.mp3`. Publishing `Website/` as it stood
  would have taken them off the site. Fetched back into the repository on the
  author's instruction -- 307,244, 6,416 and 2,906,583 bytes, headers `RIFF`,
  `OggS` and `ID3` -- so `lunar` is now complete at five sounds in three
  extensions.
- **twenty-seven exist in neither place.** `space_invaders` loses `player_hit`,
  `game_over`, `wave_clear` and `march` on every platform; `snake` loses `die`
  and `start` on every platform.
- `SOUND_EXT$` defaults to `mp3` and is only overridden for Windows, Linux and
  Android, so macOS, iOS and anything unrecognised ask for a set that barely
  exists: `missile` and `invaders` have no `.mp3` at all.

None of it is fatal. `SetError` records and does not halt, so a game whose sound
will not load runs without it. It is silent in both senses.


## 30. The site cannot become the repository until an applet stops POSTing

Written 2026-08-19, taking PLAN 4.6's remaining half: the GitHub Pages layout,
which the plan said could be committed early and sit inert.

### The inert half

`Website/CNAME` names `plan9basic.com`, so the domain follows rather than the
`github.io` address. `Website/.nojekyll` stops Pages running Jekyll over a site
that is already built. `.github/workflows/pages.yml` runs `check-all.py --quick`
and then uploads `Website/` as the document root — the directory itself is not
part of the path, which is the same rule the FTP procedure already states.

None of it does anything until the repository is public and Pages is enabled.
Committing it early is the point: it can be read and corrected while nothing
depends on it, so the day the switch is thrown is a switch and not a project.

`tools/check-pages.py` holds the layout, and all five ways it can fail were
watched failing: no `.nojekyll`, a `CNAME` naming a domain the pages do not
link to, a missing workflow, a new dynamic endpoint, and a linked file left out
of git.

### What building it found

The interesting part was not the layout. Pages serves **static files, over GET,
and only what git tracks**, and reading the site against those three words turned
up something the plan had not accounted for.

`api/examples.php` is PHP on the host. `check-site-deps.py` already knew it was
server-only, and the note in `PUBLISHING.md` already said an upload must merge
rather than replace because of it. What nobody had said is what happens when
there is no server to merge with.

Asked directly, it answers 200 with 70,058 bytes of `application/json`: a
catalogue of every example, `{"status": "ok", "data": [...]}`, with a name,
description, category, level and download path for each. Nothing in it depends
on the request — the applet posts `{}`.

So it looks like a file. It is not, twice over. Pages runs no PHP, which is the
obvious half; and **Pages answers no POST**, which is the half that matters,
because it means a static `examples.json` sitting at that path would return 405
to the applet exactly as reliably as the PHP would return 404.

The applet has to ask by GET. That is three lines in
`Website/assets/examples/ExamplesBrowser.bas`, and it is not a repair: the IDE
fetches that file from the site on the first run of every installation, so
changing it here changes what every install does. Shipped behaviour, and the
author's call rather than mine.

The two ebooks are the second blocker and a plainer one: about 68 MB of PDF,
linked from the story on the front page, present on this disk, excluded by
`.gitignore`. Pages serves what git tracks, so on the day of the switch they are
404s. Git will hold 68 MB without complaint; it is a change in how they are
handled and therefore a choice.

### Recorded in a check rather than a note

Both lists live in `check-pages.py`, and it fails in either direction: a new
dynamic endpoint that nobody declared, a new linked file left out of git, or one
of these settled and the record left stale. The reason is the same one that
produced this whole month — a note saying "still open" outlives the thing it
described, and nothing notices.

Which had already happened. The plan carried an item reading *"Also still open:
`StdLib` and `StrLib` reach FireMonkey"*, and they do not: they go through
`HostServices` now, both hosts install all four services,
`check-fmx-boundary.py` reports one unit reaching FMX and it is `TimerLib` by
design, and `tests/suite/17_host_services.bas` covers it. The work was done and
the note was not. Corrected.


## 31. The catalogue became a file, and the site became only files

Written 2026-08-19, on the author's decision about the blocker section 30 found.

### What moved

`api/examples.php` answered a POST with a database query: 97 records, each with
a name, a description, a category, a filename and a download path, and not one
of them in this repository. It is now `Website/api/examples.json`, and
`ExamplesBrowser.bas` asks for it with `http_get$`.

The envelope and every field name were kept exactly as the endpoint sent them.
That was deliberate and it is the reason the change is small: nothing below the
fetch in the applet had to move, so the risk is confined to one line rather than
spread across the parsing, the grid and the download.

### What that cost, and what it bought

It bought two things. The catalogue is now reviewable — 97 descriptions that
lived in a database nobody here could read are text in a repository — and the
site stopped having a part that is not files. `check-site-deps.py` reports **7
fetched paths present, 0 served by the host**, where it used to carry a standing
exception; `check-pages.py` reports **0 endpoints** standing between the tree
and Pages. `PUBLISHING.md` said for a month that an upload must merge rather
than replace, because of this one endpoint. It can replace now.

What it cost is a new way to drift. A database could not list a file the web
server did not have; two directories in one repository can fall out of step
quietly, which is precisely what section 29 spent a day on.

So the pairing is checked from both sides.
`tools/check-examples-catalog.py` reads the catalogue against
`Website/assets/examples/`: a record whose file is gone, a file with no record,
a `download_path` that ends somewhere other than the file its record names, a
description left blank. `--fix` settles the two it can and deliberately cannot
write a description, so a new example keeps the check red until a person says
what it is.

### Pinned by walking the applet's own path

`tests/suite/18_examples_catalog.bas` reads the real file with
`file_readalltext$`, parses it with `json_parse#`, and walks it exactly as
`LoadExamples` and `OnCellClick` do — `status`, `data`, then `name`,
`description`, `category`, `filename` and `download_path` on all 97 records.
Nine assertions.

Watched failing first, four ways: a blank description, a `download_path`
pointing at another file, an example on disk with no record, and the file
absent. The first two fail the suite; the third fails the checker; and the
distinction matters, because the suite proves the applet can read what is there
and the checker proves what is there is the whole of it.

The first draft of that test was wrong twice, and both are worth keeping.

`assert_true(len(raw$) > 1000, ...)` does not compile. Comparisons are only
expressions inside `IF`, `WHILE` and `UNTIL` -- the same constraint the review
in section 29 checked the nine games against -- so the flag is computed in an
`IF` and then asserted. Writing a test in the language is a way of being told
what the language is.

The second was mine rather than the language's. It read the catalogue at
`Website/api/examples.json`, which is right from the repository root, and
`tests/build.ps1` pushes into `tests/` before running the suite. Run on its own
it passed, and it was reported as passing here on that basis; run as part of the
suite, seven of its nine assertions failed. Which is section 25's mistake again
-- taking the run that was convenient for the run that counts.

It finds the root now instead of assuming one, and prints `dir_getcurrent$()`
when it cannot, because a path that resolves to nothing is otherwise seven
failures with no hint as to why. Watched passing from both directories.

### One thing a check cannot hold

The catalogue and the applet changed together, and they have to be uploaded
together — the applet before the catalogue gives every fresh installation a 404
where its example list should be, because the IDE fetches
`assets/examples/ExamplesBrowser.bas` from the site on first run.

Nothing in the repository can enforce that, because nothing in the repository
performs the upload. It is a paragraph in `PUBLISHING.md`, which is the same
kind of protection that failed for 111 files, and it stops being needed on the
day Pages does the upload instead.


## 32. Three notes that outlived what they described

Written 2026-08-19, after finding the third one in a day.

### What rotted

**The plan.** *"Also still open: `StdLib` and `StrLib` reach FireMonkey for
`processmessages()`, `handlemessage()` and the clipboard."* They do not. They go
through `HostServices` and have since 2.3, both hosts install all four services,
and `tests/suite/17_host_services.bas` covers the case where none are installed.

**Section 12 of this document**, saying the same thing in the same words, since
that is where the plan took it from.

**Section 22.** *"That repair has not been seen working."* It had been, the same
day — and section 23 is where, having found that the cause was something else
entirely. `Queue` instead of `Synchronize` is still the right change; it is not
why the dialog was blank. That paragraph is struck through rather than deleted,
because a correct change made for a wrong reason is worth being able to find.

All three are corrected in place, struck rather than removed, so what was
believed stays legible beside what is true.

### The shape of the failure

A note describes a **state**; the tree then moves and the note does not. Nothing
notices, because nothing in this repository reads prose.

It is the same failure as section 29's, one level up. There, the corrections
landed in `Demos/` and the site kept handing out the unfixed copy — two places
holding the same thing, and only one of them maintained. Here it is a document
and the code it describes.

The distance between them is measurable in one case. `check-fmx-boundary.py`
knew the truth about `StdLib` the whole time. The measurement existed and the
prose was never held against it.

### A check for it was written and thrown away

The obvious answer is to hold the prose against the measurement: find every line
in `docs/` claiming a library reaches FireMonkey, and fail if the boundary check
disagrees.

Written, run, and dropped. It matches exactly one line in the tree, and that
line is this correction — the sentence that quotes the false claim in order to
deny it. A check whose only finding is the fix for the thing it looks for is
worse than no check, and this project has already shipped one ratchet that could
not fail (3.1b) and one that skipped in silence (29). A third would be a habit.

The reason it cannot work is that the difference between a claim and a quotation
of a claim is not in the text. Prose is not checkable the way a signature is,
and pretending otherwise produces a check that has to be argued with.

### What is left instead

Nothing automatic, and that is the honest position. What the three have in
common is that each was a **state written in a place that does not get run** —
so the guard is to prefer, where there is a choice, putting the fact somewhere
executable. `check-pages.py` was written that way earlier the same day: the two
things standing between the tree and Pages are lists in a program that fails
when the tree stops matching them, rather than a paragraph saying "still to do".

That is not a rule that can be enforced either. It is a preference, and it is
written here so the next person can see it was arrived at rather than assumed.


## 33. The reprint that asks first, and a judgement that was smaller than it looked

Written 2026-08-19, taking section 26's unrepaired finding.

### What it was

On the first launch of a fresh installation the IDE downloads
`Translations.ini`, and when it lands the handler clears the console so it can
reprint its banner in the language that just arrived. Anything the user printed
in the meantime goes with it. Nobody chose that; it is a side effect of
reprinting a header, and the first launch is exactly when somebody is most
likely to be typing at the thing.

### Why this was not asked about

Section 26 recorded three possible repairs — reprint only when nothing has been
added, translate the header in place, or drop the reprint — and said the choice
was the author's. I did not ask, and the reason is worth stating because the
instruction for this pass names two product judgements to bring back and this
was not one of them.

**Not destroying the user's output is not a judgement.** It is the defect. The
judgement is only about what to do instead, and one of the three answers changes
behaviour in no case except the destructive one: ask before clearing. Somebody
who wanted a different answer wants a different second-best, not a different
first. The other two remain a single condition away.

### The repair

`PrintWelcomeBlock` now exists once and is called twice — at startup and on
reprint — and records how many lines it left behind. The handler asks
`ConsoleHoldsOnlyWelcome` before clearing: untouched, it clears and reprints
translated; touched, it leaves everything alone. `TranslationsLoaded` is printed
either way, because it is news either way.

### And extracting it found a second defect

The startup banner is written with a platform conditional — `WelcomeMobileTip`
on Android and iOS, `WelcomeDesktopTip` elsewhere. The reprint was written
without it, and printed `WelcomeDesktopTip` unconditionally.

So on a phone, the arrival of translations replaced the mobile tip with the
desktop one: a first launch that ends up telling an Android user about a
keyboard shortcut. Nothing detected it because both branches compile and both
print something.

It is fixed by not existing. There was one banner written in two places, which
is the same shape as section 29's two copies of the games and section 32's three
notes — and the repair is the same one, which is to have one of the thing.

### Pinned

The IDE's own self-test now asks the question in both directions: with this
test's program output in the console the answer has to be no, with the count
aligned to the banner it has to be yes, and one line later it has to be no
again. It does not clear the console to do it, so a failure report still shows
what happened.

Watched failing: with `ConsoleHoldsOnlyWelcome` forced to `True`, the self-test
reports

```
FAIL - IDE feature: the console holds 24 line(s) of program output and still
reports itself untouched
```

which is the defect itself, stated in the terms a user would have met it in.


## 34. The last of the three decisions, six sections after the other two

Written 2026-08-19. Section 1b gathered three findings whose evidence was
settled and whose choice was not a checker's to make. Two were answered the same
week — `instr` on the 18th, the AI archive on the 19th. The third sat there.

### What it was

`Examples/NN_name.bas` and `Website/assets/examples/name.bas` hold the same 98
programs. Something copies one to the other and nothing says which direction, so
nothing could say which one was right when they disagreed.

They disagreed in exactly one file, and section 1b already named it:
`ChuckNorrisFacts_Demo.bas`. Measured again on the 19th, still one, still that
one — 23 lines apart.

The site's copy was the older. It lacked the rectangle drawn behind the category
dropdown, and it still bound `listbox_onitemclick#` with its two-parameter
handler where the other had moved to `listbox_onchange#` with one, under a
comment explaining that the single-pointer form matches every other handler in
the file. Somebody made that change and it reached one of the two copies.

**And the site's copy is the one people download.** `Examples/` is the
repository's own; `assets/examples/` is what `download_path` points at in the
catalogue and what the Examples Browser fetches. The stale half was the half
that ships.

### The choice, and why this one

Section 1b offered two: name one canonical and generate the other, or keep both
and check them. Either would have caught this.

Kept both. The two directories are read by different things and neither is
obviously the copy — generating `Examples/` from the site's downloads is as
strange as the reverse — and a generator that nobody remembers to run is a
third way to drift rather than a cure for the first two.

### Where it went

Into `check-site-examples.py`, which already asked this question about the nine
games and their copies embedded in `examples.html`. It now asks it twice, of two
kinds of pairing:

```
ok  59 example(s) on the page, 9 paired with the repository, and 98 in both
    example directories, all identical
```

Watched failing both new ways: one line changed on one side, and one side
missing the file altogether.

### The pattern, for the fourth time in two days

Section 29 was the games in two places with one maintained. Section 31 traded a
database for a file and had to check the file against the directory beside it.
Section 32 was three notes describing a tree that had moved. Section 33 was one
banner written twice, where the copy nobody looked at printed the desktop tip on
a phone.

This is the same, and it is the oldest of them: named on the first day, and it
outlived both of the decisions it was gathered alongside. Which is the argument
for the preference section 32 arrived at — a fact belongs somewhere that runs.
Section 1b is prose, and prose kept the finding perfectly and did nothing with
it for a week.


## 35. State the documentation called necessary, that nothing had read for weeks

Written 2026-08-19, after measuring two entries in section 3 rather than
believing them.

### Both were wrong, in opposite directions

**3.6** said 125 `Application.ProcessMessages` remained in the GUI libraries. It
carried a correction from earlier the same day saying the figure was stale and
one remained. Counted again: **none**. Not in `engine/`, not in `Libs/`, not in
`utils/`. The BASIC `processmessages()` reaches the host through `HostServices`,
and the two in the hosts are the hosts' own. A note corrected once had gone
stale a second time, which is a good argument that correcting notes is not the
repair.

**3.5** said 38 libraries keep `ModuleEngine` and `ModuleOutput` as unit
variables, and that this closes off running the VM off the interface thread.
Both halves of that were out of date, and the interesting half is not the count.

### What the measurement found

Of the 38 units declaring `ModuleEngine`, **34 assigned it on every registration
and read it nowhere.**

Phase 2.2 replaced the lookup with `EngineOf`, which walks a control's parent
chain up to the form that owns an engine. It did not remove what it replaced. So
for weeks the libraries carried a variable that was written on every startup,
read by nobody, and described in the analysis as the reason two engines could
not coexist.

That is worse than a stale sentence. A reader of `FloatAnimationLib` saw
per-module engine state and would reasonably conclude the module is
single-engine — the opposite of what 2.2 established — and the code agreed with
them.

Removed: **136 lines across 34 units**, and the IDE went from 144,110 lines to
143,974 without any behaviour moving.

### The four that stay, and why they are not an exception

`TimerLib`, `StrListLib` and `MediaPlayerLib` still read it, and `tests/TestLib.pas`
does. Not oversights: a timer is not a visual control, a string list is not in
the visual tree at all, and a media player is not necessarily parented when it
is created. There is no parent chain to walk, so the module variable is the only
route they have. The harness reaches the parser on purpose, which is its job.

`EngineOf` is a repair for controls, not for everything, and 3.5 read as though
the state itself were the defect.

### Where it went

`tools/check-module-state.py`, failing in both directions: a unit that declares
one of these and never reads it, and a name in its list that has stopped
reading. Watched failing both ways, plus a unit reading it without being listed.

### 3.8 was measured too, and was wrong the other way

While in section 3, the last entry without a resolution on it. It says 64 effect
units total 27,184 lines and puts the control wrappers in a parenthesis, then
concludes that half the project is code a generator would produce.

The effects are 24,907 lines now and all 64 share `EffectCommon.pas`, which is
Front 5's work and this entry never learned about. The wrappers are 78,836
lines, **51% of the project by themselves**, and with the effects 68%.

So the entry was stale about the half that had been repaired and understated the
half that had not — and the understatement is the one that matters, because it
is the argument for Phase 5 being a boundary rather than an omission, and it was
filed in brackets.

### The sixth of these in two days

29 was the games in two places. 31 traded a database for a file and had to check
the file against the directory beside it. 32 was three notes describing a tree
that had moved. 33 was one banner written twice. 34 was two example directories
with one drifted file, named on the first day and left for a week.

This one is the same and the most expensive, because the thing left behind was
not a sentence. Every previous instance cost a reader a wrong belief; this one
cost 136 lines of code that ran on every start and meant nothing, and it sat
under a heading that explained why it had to be there.


## 36. The language contract, run rather than read

Written 2026-08-19. Section 4 tells somebody what they may write in a `.bas`
file: which constructs exist, how a string is indexed, where an array starts.
Nothing executed a word of it.

### Measured first, and it was right

Given how sections 3.5, 3.6 and 3.8 turned out the same day, the expectation was
more of the same. It was not. **Every sentence in section 4 holds.**

- `s$[0]` is `"alpha"` and `s$[1]` is `"beta"` — the n-th line, from zero
- `t$[[0]]` is `"a"` — the n-th character, from zero
- `a#[1]` is the first element — arrays from one, next to two notations that
  start at zero
- `"he said {backslash}"hi{backslash}""` is twelve characters, and the ninth is a quote
- `x = 2 > 1` is a syntax error
- `if dict_haskey(d#, "k") then` is "Logic operator expected"
- `x = true` is "Value expected", and so is `if true then`

`ON k GOTO` and `ON j GOSUB` were the interesting case: documented in section 4,
exercised by no test in the suite, and — checked — both correct. A documented
feature with no coverage is a coin toss, and this one came up heads.

### Pinned

The positive half is `tests/suite/19_language_contract.bas`, eleven assertions
over the indexing rules, the array base, the escape, and the two `ON` forms.

The half that says what does **not** compile cannot be asserted from inside the
language, so it went to `tests/negative/`, where the runner inverts the verdict
and every file must be rejected. Four files, one rejection each, because a file
stops at its first error and one per file is the only way to know which
rejection happened:

```
COMPILE  05_boolean_outside_a_condition.bas   line 12: Syntax error
COMPILE  06_number_as_a_condition.bas         line 10: Logic operator expected
COMPILE  07_true_is_not_a_value.bas           line  8: Value expected
COMPILE  08_true_is_not_a_condition.bas       line  9: Value expected
```

The harness itself was watched inverting: a valid program dropped into
`negative/` reports *"expected this file to be rejected, but it ran clean"*.

### Why these four and not the others

They are the constraints a person meets by accident rather than by reading.

`assert_true(2 > 1)` is the obvious way to write an assertion and `x = a > b` the
obvious way to keep a flag; both are a bare "Syntax error", which says nothing
about the rule. That cost an hour while section 31's test was being written —
by me, with the rule written down in this very document, four sections above the
work.

Which is the argument for this section in one line: the contract was correct,
legible, and in a file nobody runs.

### A comment that claimed more than its file tested

`07` was first written asserting in its header that `IF true THEN` is refused at
the same place, while testing only `x = true`. That is the failure this month has
spent itself on, committed inside a file whose whole purpose is to hold a claim
to a test. It is `08` now, and `07`'s header says only what `07` does.


## 37. The boundary that was not one, and the paint event underneath it

Written 2026-08-19, on the author's authorisation of Phase 5.

### The premise was right and the conclusion did not follow

Section 9 measured the 407 event setters, found them "effectively one shape",
and concluded they could not be shared:

> Every token that varies is an *identifier* — a field, an FMX property, a
> method. Delphi has no way to abstract over a property name at compile time.

Every word of that is true. What does not follow is that nothing can be shared,
because **abstracting over the name was never necessary**. Fix the name inside a
helper and pass what varies:

```pascal
procedure BindClick(AControl: TControl; const AName: String;
                    var AField: String; AHandler: TNotifyEvent);
begin
  AField := AName;
  if AName <> '' then AControl.OnClick := AHandler else AControl.OnClick := nil;
end;
```

The field goes by reference because it is a field and may; the property is
assigned inside, because a property may not. There are **19 event names against
369 sites**, and `TControl` publishes all 19, so one helper each covers every
control that inherits from it.

**365 setters became one line.** The IDE went from 143,974 to 142,791 —
1,183 lines, net of the helpers. No RTTI, no generator, no descriptor table:
nothing that could drift from the thing it describes, which after six such
incidents in two days was the property worth buying.

What stayed: 47 events belonging to the concrete FMX class rather than
`TControl` — `CellClick` is a `TStringGrid`'s, `Switch` a `TSwitch`'s — and 8
setters on classes that are not `TControl` at all.

### What reading 420 setters turned up

`onpaint` is not one event. Seven libraries bind `TControl.OnPainting`; five
bind `TShape.OnPaint`:

| | libraries | fires |
|---|---|---|
| `OnPainting` | Arc, CalloutRectangle, Image, Line, Path, Pie, RoundRect | before the control paints, and it still paints |
| `OnPaint` | Circle, Ellipse, Layout, Rectangle, Form | where the shape's own drawing happens |

`TArc`, `TCircle`, `TPie` and `TEllipse` are all `TShape` descendants, as are
`TRectangle`, `TRoundRect`, `TCalloutRectangle` and `TLine`. **Every one of the
twelve could take either.** Which it took was decided by the unit its author
copied from.

So `rectangle_onpaint#` hands a program the drawing, and `arc_onpaint#` runs
alongside a drawing that happens regardless — one documented name, two
behaviours. It is the alignment tiers again, where the same number meant
`MostTop` in one library and `None` in another.

Unifying is not a repair, because it changes what shipped applets see and
neither half is the wrong one. Left for the author, and both lists are named in
`check-event-binding.py` so a new library has to join one of them on purpose.

### The price of collapsing, and what pays it

365 identical five-line bodies could be wrong only by being edited. One line
each can be wrong by being *written*: `BindClick` with `FOnDblClickFunc`
compiles perfectly, stores the name where nothing reads it, and the click never
fires. That is section 28 one layer down.

`check-event-binding.py` reads all four names in every call and requires them to
agree. Watched failing on a swapped field, on a setter written out by hand where
a helper exists, and — after the first version reported the wrong identifier
when only some of the four diverged — on its own message.

### What Phase 5 does not do, with a number

The property accessors are 2,108 functions in **296 shapes**. The 20 largest
cover 61%; 137 shapes occur exactly once. Section 9 predicted that "the gain
shrinks as the irregular third is chased" and it was right to the percentage.

That, and not the setters, is why half the project is boilerplate: the control
wrappers are 78,836 lines, 51% of the tree. The boundary stands, and it now has
a measurement rather than an assertion behind it.


## 38. Twenty per cent, and what the other eighty had been hiding

Written 2026-08-19, taking the author's own instruction — test exhaustively,
having used the engine very little — as the next item.

### The measurement

The GUI suite held 614 assertions across eight files and exercised **745 of the
3,767 registered GUI functions: 20%**.

Everything this project has found by running rather than reading came out of the
other 80%. `SQLiteLib` compiled perfectly and was dead. So did `RAGLib`.
Twenty-five `*_free` functions always answered 0. An assertion about scrollbox
parents had never once been true. `ScrollBoxLib` had been failing every call
since the HandleRegistry conversion, and was found the day `04_alignment.bas`
was generated over 26 controls — not before, and not by reading it.

### The round trip, and what it deliberately does not assert

`tests/gen_property_suite.py` emits, for every library with a constructor, an
error accessor, and a property carrying a setter and a getter of one type:

```basic
v = lib_prop(c#)
assert_eq(lib_error(), 0, "lib_prop reads")
lib_prop#(c#, v)
assert_eq(lib_error(), 0, "lib_prop writes back what it read")
```

**The value written is the value just read.** A setter may clamp, round, or
refuse something out of range, and asserting that an invented value survives
would report all of those as failures — noise that buries the signal. What is
asserted is narrower and is the thing that has actually been wrong: that the
call can be made, and that neither half records an error.

26 libraries, 899 properties, **1,824 assertions, all passing**. No dead control
library, which is the answer worth having either way. Coverage went from 20% to
**66%**, and the GUI suite from 614 assertions to 2,438.

### And the generators got the treatment the rest of the tree got

`03_effects.bas` and `08_property_roundtrip.bas` are generated and committed,
which is a generator and its output: two artefacts, and two artefacts drift.
That is six incidents in two days, and adding a library without regenerating
would leave the suite describing the tree as it used to be, in silence.

Both generators take `--check` now: write nothing, and answer whether the
committed file is still what they produce. Both watched failing on one
hand-edited line. `check-all.py` runs them, and is at 13 checks.

### A method note, because it cost the whole day

Six edits failed today with an anchor that was character-for-character correct,
and the reason is the same each time: **in a quoted heredoc here, `{backslash}{backslash}`
collapses to `{backslash}`**. An anchor written with `"{backslash}n"` reaches Python as a real
newline and never matches a file containing the two characters. Every edit that
worked built the backslash with `chr(92)`.

Recorded as a rule rather than an accident, since the failure looks exactly like
a stale anchor and was diagnosed as one five times before it was diagnosed
correctly.


## 39. onpaint meant two things, and the reason was not what I said it was

Written 2026-08-19, on the author's decision to settle the split section 37
found.

### I described it wrong, and the source said so

Section 37 reported that seven libraries bind `TControl.OnPainting` and five
bind `TShape.OnPaint`, and characterised the second as *"where the shape's own
drawing happens"*. That came from the property name, not from FMX.

Both are declared on **`TControl`**, three lines apart, and neither replaces
anything. The paint pass runs

```
Painting  ->  OnPainting     before the control draws itself
Paint                        the control draws itself
DoPaint   ->  OnPaint        after
```

So they are a **backdrop and an overlay**, not rival designs. Twelve libraries
could take either, and one documented call put a program's drawing *under* an
arc and *over* a rectangle.

That correction is what made the decision easy rather than hard. Section 37 said
"neither half is the wrong one" and offered the author three options; with the
semantics read rather than guessed there is one answer, and the argument is not
a preference:

- the BASIC name is `onpaint` and the FMX property it should mean is `OnPaint`
- the reference pages describe it as *custom drawing*, which is the overlay
- **the only two callers in the whole tree** — `layout_onpaint#` in a library
  round-trip test and `form_onpaint#` in the documentation — were already
  getting `OnPaint`

Nothing that exists loses anything, and the seven that changed had no caller at
all.

### The repair was one line, because of yesterday's work

The seven all reach the event through `ControlCommon.BindPaint`, which Phase 5
introduced this same day. Changing what that one helper assigns changed all
seven. The four hand-written ones then became `BindPaint` calls too, which took
the setters bound through `ControlCommon` from 365 to **369** and let
`check-event-binding.py` drop its list of exceptions entirely.

That is the argument for the collapse stated as a fact rather than a hope: the
`onpaint` split existed *because* the wiring was written out 420 times, and it
was repaired in one place *because* it no longer is.

`FormLib` stays hand-written. A form is a `TCommonCustomForm` and not a
`TControl`, so no helper reaches it; it already bound `OnPaint` and still does.

### The gap this leaves, named rather than left

`OnPainting` now has **no BASIC name at all**. Nothing can draw underneath a
control any more, where seven libraries accidentally could.

That is a real loss and it is written into `BindPaint` where somebody will meet
it. Restoring it means an `onpainting` family — a setter, a getter, a field, a
handler and a reference page per library — which is a feature rather than this
repair, and inventing it while settling an ambiguity would be how the ambiguity
got here.


## 40. The quarter of the surface that fails without saying so

Written 2026-08-20, continuing the coverage work of section 38.

### Which quarter, and why it is the one that matters

After the property round trip, 1,289 of the 3,767 registered GUI functions were
still called by nothing. Sorted by family, the top five were not obscure:

| family | functions |
|---|---|
| `free` | 99 |
| `strerror` | 98 |
| `error` | 98 |
| `clearerror` | 98 |
| `errormsg` | 97 |

**490 functions, and every one of them fails invisibly.** A `free` that reports
success without freeing, or an error slot that never clears, looks from a BASIC
program exactly like a library that works. There is nothing to notice.

The history is in the source. `n_rect_free` still carries the note from when
**25 `*_free` functions answered 0 on every call**, for months, because the
block that set the result had been commented out. Nothing caught it because
nothing called `free` and looked at what came back.

### One sequence, ninety-five times

`tests/gen_lifecycle_suite.py` emits, per library: build, free, free again, then
read the error out and clear it. Every step is a claim —

```
build            the constructor records no error
free             answers 1, records no error
free again       answers 0
error            the refusal was recorded rather than swallowed
errormsg$        says something about it
strerror$(code)  names the code
clearerror       and the slot goes back to clean
```

The second free is the point of the exercise. `HandleRegistry` exists so that a
pointer a program kept after freeing is *detected* rather than dereferenced, and
until now nothing asked it in anger. This asks it 95 times.

**760 assertions, all passing.** No dead `free`, no error slot that will not
clear, no handle that survives its own release. Coverage went from 66% to
**74%**, and the GUI suite from 2,438 assertions to 3,198.

### The generator claimed a number it had not counted

Its first run announced 855 assertions. The sequence has eight steps and 95 × 9
is not 760: the nine was remembered rather than measured, and the run that
followed reported the real figure and contradicted it.

It counts now. Writing an unchecked number into the output of a tool built to
catch unchecked claims is worth recording rather than quietly fixing — it is the
same reflex that produced sections 32, 35 and 36, appearing inside the work that
exists to stop it.


## 41. The one family where a test can assert what the call did

Written 2026-08-20, continuing sections 38 and 40.

### Why geometry, and why the values are all different

`move`, `size`, `bounds`, `margin` and `margins` take their values as a group
and are read back one at a time. Every other family this week could only be
asked whether the call could be *made*; this one can be asked what it *did*.

The failure it invites is the one Phase 1 already found in `StrLib`: arguments
in the wrong order. That compiles, runs, reports nothing, and puts the height in
the width. So no two values in the suite are the same — `move#(c, 11, 22)` with
the axes swapped reads back 22 and 11, and the assertion names which one moved.

Measured before generating, and the semantics held: `move(x, y)`,
`size(w, h)`, `bounds(x, y, w, h)`, `margin(n)` on all four sides, and
`margins(l, t, r, b)` in that order.

**456 assertions over 25 libraries.** Coverage 74% to **79%**, the GUI suite from
3,198 assertions to 3,654.

### The failure it reported, which was mine

`scrollbox_move` did not move: x and y stayed at 0. `ScrollBoxLib` is the
library that was found completely dead once already — every call failing
validation because it never registered its handle — so "that one again" was the
easy reading, and it was wrong.

`scrollbox#(parent#)` ends with `SB.Align := TAlignLayout.Client`, and **an
aligned control does not own its position**. The parent's layout writes it, so
`Position.X := 11` is overwritten before anything can read it.

Confirmed on three points before a word was written: with `align` set to 0 the
same `move` works; the five-argument constructor positions correctly; and a
plain `rectangle` set to Client ignores `move` exactly as the scrollbox did.
`move` is right everywhere. What was wrong was my test's premise — that a
freshly built control is positionable.

### The trap is now an assertion rather than a note

That is FMX, it is true of every control, and it is invisible from BASIC: the
call reports **no error** while doing nothing. A program that aligns a control
and then tries to move it has no way to find out why nothing happened.

So the generator sets `align` to 0 before measuring, and the suite opens with a
case that states the trap instead of avoiding it:

```basic
rectangle_align#(a#, 9)
rectangle_move#(a#, 11, 22)
assert_eq(rectangle_x(a#), 0, "Client alignment kept x at 0")
assert_eq(rectangle_error(), 0, "and move reported no error doing it")
rectangle_align#(a#, 0)
rectangle_move#(a#, 11, 22)
assert_eq(rectangle_x(a#), 11, "with alignment off the same call works")
```

A behaviour nobody had written down, held by a test rather than by whoever next
loses an afternoon to it.

### The count, again

The generator counts the assertions it emitted rather than multiplying the
libraries by a number. Section 40 recorded getting that wrong the day before —
95 times a nine, when the sequence had eight steps — and this one was written
with that fresh.


## 42. The same generator, one line wider

Written 2026-08-20, finishing the coverage round of sections 38, 40 and 41.

### What was left, and why it was left

The largest untested family was `trigger`: 52 setters and 52 getters, a string
pair on the effect libraries. `gen_property_suite.py` already knew how to test
exactly that shape — it had been round-tripping string pairs on the controls
since section 38 — and it never saw them, because `control_units()` globbed
`Libs/GUI/*.pas` and stopped there.

The only thing it lacked was knowing that an effect attaches to a **control**
rather than to the form. One line chooses the parent:

```python
group = os.path.basename(os.path.dirname(p))
yield p, ('host#' if group in ('Effects', 'Animations') else 'f#')
```

With that, the same generator went from 26 libraries to **96**, from 899
properties to **1,246**, and from 1,824 assertions to **2,588**. All passing.
Coverage 79% to **87%**, and the GUI suite from 3,654 assertions to 4,418.

That is worth stating plainly because it is the argument for building the tool
rather than the test: the reach tripled on a line that picks a parent, not on
new work. Three days ago this would have been a fourth hand-written suite.

### And the count that was right anyway

The generator reported its total as `pairs * 2 + len(libs)`. The arithmetic was
correct — checked against what the runner then reported — and it counts now
regardless.

Section 40 recorded multiplying 95 libraries by a nine that was remembered
rather than measured, and being contradicted by the very next run. Leaving a
formula where a count fits keeps that bet open for no gain. All three generators
count what they emitted.

### Where the GUI surface stands

3,268 of 3,767 functions are exercised. What remains is mostly
`clearcallbacks` (32), `target` and `loadtarget` on the effects (45), and the
long tail of one-off names — the shapes no round trip fits, which are the ones
a hand-written test has to state a claim about rather than derive one.


## 43. The half of the library surface nobody had measured

Written 2026-08-20. Sections 38 to 42 took the GUI surface from 20% to 87%, and
never asked what the rest was at.

### 29%

452 functions live outside `Libs/GUI`, and 132 of them were exercised. Those are
the libraries a program without a window uses: strings, files, dates, archives,
configuration.

The gaps, by unit: `DateTimeLib` 66, `StrListLib` 46, `IOUtilsLib` 43, `SysLib`
42, `ConfigLib` 31, `StrLib` 22.

### One name was worth more than the count

`RAGLib` appeared in that list with 13 untested functions, and this document
says it was found **dead** on the same day as `SQLiteLib` — while item 1.5
records repairing only `SQLiteLib`. It ships in all three executables and has a
reference page, so the question was whether a dead library had been left in.

It had not: `RegisterHandle(RAG)` is there, with the comment explaining why.
Confirmed by running rather than reading — build a knowledge base, count it,
summarise it, free it, four assertions, all green.

**Found on the way:** `RegisterRAGFuncs` sits inside `RegisterGuiLibs` in the
test runner, alongside `SQLiteLib` and `AILib`. None of the three has anything
to do with graphics. That is why `06_sqlite.bas` lives in `tests/gui/`, which
had looked arbitrary. The shipped IDE and applet runner register all of them
unconditionally, so this is a limit of the harness rather than a product defect
— but it means a headless test cannot reach three libraries, and the reason is
now written down instead of inferred.

### DateTimeLib, 66 functions and no test

The largest single gap, and the kind where defects hide in plain sight. Written
by hand: no round trip derives an answer here, so the assertion *is* the content.

**Every date is a numeric literal.** A `TDateTime` is days since 1899-12-30 with
the clock in the fraction, and parsing text would make the suite depend on the
machine's date format — passing here, failing elsewhere, and saying nothing
about the library either way.

The assertions worth the most are the pairs whose names do not distinguish them,
none of which was written down anywhere in the tree:

- **`dayofweek` counts from Sunday and `dayoftheweek` from Monday.** For the same
  Thursday they answer 5 and 4. Three letters apart in the name, one in the
  result.
- **`daysinmonth` takes a date; `daysinamonth` takes a year and a month.**
- `incyear` from 29 February **clamps to the 28th** rather than rolling into
  March.
- 1900 is not a leap year and 2000 is — the two exceptions in the calendar.

39 assertions, all passing. The library is correct; what was missing was anything
that said so. Non-GUI coverage 29% to **37%**, and the engine suite from 407
assertions to 446.

### What the clock can be asked

`now`, `today`, `time` and `date` cannot be asserted against a value. What can be
asserted is the relation between them: today is now with the fraction removed,
tomorrow is one day on, yesterday one back, and `istoday(today())` holds. A test
that cannot know the answer can still know the shape.


## 44. StrListLib was missed by the HandleRegistry conversion

Written 2026-08-20. Started as coverage and turned into a shipped defect.

### How it surfaced

`StrListLib` was the largest gap left outside the GUI: 46 registered functions,
none tested. Writing the suite meant measuring the conventions first — the list
indexes from **zero**, `add` returns the index it used, `indexof` answers -1
when it fails.

Two of those measurements are worth their own assertions because the names do
not distinguish them. `find` and `indexof` take the same arguments and return
the same thing, and `find` is a binary search: on eight items in reverse order
`indexof` finds every one and `find` reports -1 for every one, raising nothing.
The reference page states this in a note and its own example sorts first, so
there is no defect there — what was missing was a test, and its value is making
a precondition executable rather than a paragraph somebody may not read.

**The defect was in the last assertion.** `strings_free` on an already freed
list answered **1**. Its ninety-five siblings in `Libs/GUI` answer 0, which
section 40 pinned the day before.

### What was underneath

`ValidateStringList` tested `Assigned(P)` and cast. No registry, anywhere in the
unit — and **65 of its signatures take a pointer**.

```
strings_count(pointer#(123456))
  -> Access violation ... Read of address 000000000001E240
```

That is verbatim the failure `tests/negative/02_fabricated_array_handle.bas`
describes for `ArrayLib` before item 3.4: *"recoverable on Windows, a hard crash
on Android and Linux."* `StrListLib` was simply missed by that conversion, and
nothing noticed for months because nothing called it with a bad handle.

A sweep of the non-GUI libraries found a second: `classname$` in `StdLib` was
one line with **no check at all**, not even for nil, casting whatever number it
received to `TObject` and reading from it.

`ZipLib` was flagged by the same sweep and is **not** a defect. It keeps an
integer key into a dictionary, so an invented handle is a lookup that misses and
nothing is ever dereferenced. A different design, equally safe, and worth
recording so the next sweep does not 'fix' it.

### The repair, and the part I got wrong

`ValidateStringList` and `stringlist_free` ask the registry; the constructor
registers; `classname$` answers an empty string for a pointer the registry does
not know, since refusing to answer beats crashing for an introspection call.

Then the **examples** failed — and only the full run caught it. `RegexLib`
hands match results to BASIC as handles that the `strings_*` family reads, and
they are plain `TStringList`, not `TBasStringList`. I had required both
registration *and* the subclass, tightening two things when the family's design
had always been the looser one.

Both sides were wrong and neither is fixed by loosening the guard:
`RegexLib.CreateManagedStringList` registers what it produces, and
`ValidateStringList` asks for the **base class**, which the registry answers for
both.

**Two things I did badly here.** My detector for "what escapes to BASIC" looked
for `Result.p := ...` and missed `RegexLib` entirely, because it escapes through
a Pascal function whose return variable is also called `Result`. And I declared
the repair done on the strength of two partial suites, both green, before
running the one that exercises real programs. That is section 25's mistake
again: taking the run that is convenient for the run that counts.

Coverage of the non-GUI libraries went 37% to 44%, the engine suite 446 to 486
assertions, and the negative suite from 8 files to 10.


## 45. Every event was dead, and I wrote the line that killed them

Written 2026-08-20, after the author reported that flappy_bird still would not
answer a key and that the fault was mine.

### The bisection

Reading had failed four times on this game already, so this time the code was
cut down instead: 31 lines, a form, a counter and a `form_onkeydown`, no game
logic at all. The author ran it with the window focused and the counter stayed
at zero.

That answered more than the question asked. **No form in the host delivered
keys**, so all nine games had the same dead keyboard and flappy_bird was never
the subject.

### What I did in Phase 2.2

Commit `1ca9324` — *"a control finds its engine through the form, not a unit
variable"* — replaced

```pascal
Frm.BasicEngine := ModuleEngine;
```

with

```pascal
if EngineOf(Frm, Eng, Outp) then
  Frm.BasicEngine := Eng;
```

`EngineOf` walks a control's parent chain up to the form that owns an engine.
**A form is the root of that chain.** There is nothing above it, the call
answered False, `BasicEngine` stayed nil, and every `InternalOnXxx` in `FormLib`
exits on its first line when it is. `onshow`, `onclose`, `onresize`, `onkeydown`
— all of them, from that commit until today.

`tools/check-callbacks.py` never had a chance: it proves the **shapes** agree,
and they did. **Delivery was never asked about.**

There is a detail that accuses me twice. My sweep of 2026-08-19 removed the two
assignments as unread — correctly, since 2.2 had already stopped reading them —
and left the comment `// Store module-level references for event callbacks`
hanging over nothing. That was the sign, and I walked past it.

### The author asked the right question

*"Would it not be worth sweeping every library with event handling, to confirm
the trigger is actually wired to the interpreter?"*

It was. `EngineOf` has a precondition nothing enforced: **the control must
already be parented.** Of 74 construction sequences in `Libs/GUI`, **17 called
it on an orphan** — created with `Create(nil)`, parented two lines later:
`label`, `layout`, `panel`, `progressbar`, `rectangle` and `trackbar`.

`RectangleLib` created, looked up, then parented. `ArcLib`, in the same phase,
parented first. Two patterns, one commit, and no way to tell from outside.

That is the rest of the symptom: `rectangle_onmousedown` is what flappy_bird
used for touch, so the game answered neither a key nor a tap.

### Confirmed by running, and a wrong turn avoided

`edit_onchange` and `checkbox_onchange` fire, and both libraries were sound.
`trackbar_onchange` does not, and it was among the seven. The baseline mattered:
the first probe used `onresize`, which failed even on `arc` — a programmatic
resize does not raise it — and without a control that works, that would have
read as "arc is broken too".

### What could not be proved -- and was, once the author pushed

`trackbar_onchange` still did not fire after the repair. `CallbackCore` exits
silently on a nil engine **and** stays silent when FMX never raises the event,
so from BASIC the two are indistinguishable, and the assertion was left out
rather than left green.

The author asked whether Embarcadero's own sources were worth reading properly.
They were, and they answered a different question than the one asked.

`TValueRangeTrack.DoChanged` calls `FTrack.DoTracking`, so a programmatic write
raises **`OnTracking`** first, and `OnChange` follows through `DoAfterChange`.
Real, and not the explanation: measured, **neither** fired, which did not match
the reading.

**Because the repair had broken it.** `ProgressBarLib` and `TrackBarLib` assign
the parent inside an `if/else` -- one branch for a form, one for a control --
and the automated move put the engine lookup after the *first* `Parent :=` it
found, which is inside the `else`. It compiled. Whenever the parent was a form,
the lookup was skipped entirely.

Corrected, both events fire, and both are asserted. See section 46.

### What holds it now

`tests/gui/11_form_events.bas` — `form_show` reaches its handler, hands it the
form as `sender#`, and an empty name unwires it; plus the two control events
that demonstrably fire.

`tools/check-engine-lookup.py` — no construction may ask for its engine before
it has a parent. Watched failing with one site inverted on purpose.

`FormLib` joins `check-module-state.py`'s named readers as the fifth, for the
reason that makes it one: the root of a chain has nobody to ask.

### The shape of it

This is the same failure as sections 29, 32, 34, 35 and 44, and the most
expensive: **a silent exit is indistinguishable from nothing to do.** Every one
of those was found by running something rather than reading it, and this one
needed a person at a keyboard because the last mile is a key press. The suite
now covers the mile before it.


## 46. The repair broke two of the seven, and the check said nothing

Written 2026-08-20, closing the open question section 45 left.

### An automated move that could not see a branch

Section 45 reordered 17 sites so the engine lookup came after the parent was
set. The script moved the block to just after the first `X.Parent :=` line it
found within the window. In four of them that line is **inside an `else`**:

```pascal
if TObject(Args[0].p) is TCommonCustomForm then
  tb.Parent := TCommonCustomForm(Args[0].p)
else
begin
  ParentObj := TFmxObject(Args[0].p);
  tb.Parent := ParentObj;
  if EngineOf(tb, Eng, Outp) then ...   <- landed here
end;
```

Valid Pascal, so it built. A trackbar or progress bar parented to a **form** --
the ordinary case, and the one every test uses -- skipped the lookup entirely
and kept the nil engine section 45 was written to remove.

`Label`, `Layout`, `Panel` and `Rectangle` have no branch there and came out
correct, which is why the form-level test passed and hid it.

### And the check I had just written passed on it

`tools/check-engine-lookup.py` reported *ok, 74 constructions* over the broken
tree. It counted `begin`/`end` to know whether the lookup sat inside a branch,
and the pattern it counted with was `begin`.

The generator wrote `''` inside an ordinary Python string, where `` is the
**backspace escape**, not a regular-expression word boundary. The check was
looking for a control character. It matched nothing, depth stayed 0, and every
site read as sound.

That is the third form the same rule has taken in this project -- a heredoc
eating a backslash -- and the first where the casualty was a checker rather than
an edit. Rebuilt with `chr(92)`, it now names all four sites in the commit that
introduced them, and clears the corrected tree.

### The answer, finally

With the lookup outside the branch, **both** trackbar events fire:
`ontracking` on the write and `onchange` after it. The FMX reading in section 45
was correct about the order and irrelevant to the symptom; the symptom was mine
throughout.

`tests/gui/11_form_events.bas` asserts both, and is at eight assertions.

### What this cost, and what it is worth

Four turns and two wrong explanations -- FMX semantics, then an unprovable
question -- to reach a defect I had introduced twenty minutes earlier while
fixing a defect I had introduced in Phase 2.2.

The pattern is worth stating plainly. **An automated edit that does not
understand structure will produce something that compiles**, and a check written
in the same sitting is written by the same mistaken hand. The verification that
caught it was neither: it was running the thing and not believing the reading.


## 47. Confirmed by somebody playing it

Written 2026-08-20. The author ran `flappy_bird` and reported a score of 13 with
the game-over screen up.

### What one screenshot proves that the suite cannot

A score of 13 is not one assertion, it is the whole chain in sequence:

- **the keyboard** started the game and flapped, thirteen gaps' worth
- **the timer** ran `GameLoop` on every frame, so `timer_ontimer` reaches the
  interpreter across the thread the host runs the VM on
- pipes spawned, moved, and were recycled off-screen
- **collision** ended the run, which means the geometry reads back what it wrote
- the score label updated and the high score was kept

Sections 45 and 46 fixed the delivery and pinned everything up to the dispatcher.
The last step — a real key, from a real keyboard, into a real window, driving a
real game loop — is the one no headless test reaches, and it is the one that had
been broken since Phase 2.2 without anything noticing.

### What it does not prove

The suite runs the nine games to completion, which shows they build and finish,
not that they play. This screenshot shows one of them playing. The other eight
share every mechanism it used and none has been played since the repair.

Sound is still missing for six of the twenty files `snake` and `space_invaders`
ask for, which is silent by design and unrelated.

### The diagnostic that found it, kept

`Demos/_keytest.bas` is committed rather than left loose. It was written to
bisect this, deleted once as redundant when the headless test landed -- and it
was not redundant, because the headless test stops exactly where this one
starts. It counts keys and clicks, which are the two paths that were dead.


## 48. The reference pages described handlers the engine would never call

Written 2026-08-20, after the author asked the question this section is an
answer to: *"either your verification was rubbish, or you lied."*

Neither, and the true answer is worse than the first: the two defects they found
by using the interpreter were **introduced by me** in Phase 2.2, and the checks I
had written were blind in exactly the two places I had broken.

### The two blind spots, named

`check-callbacks.py` reads the programs in this tree and holds them to the
dispatchers. All 1,263 agree. What nothing did was

1. **hold the reference pages to the dispatchers**, and
2. **prove an event is delivered at all**, rather than correctly shaped.

Sections 45 and 46 closed the second. This one closes the first.

### 63 pages promised a shape the engine does not send

```
rectangle_onresize#(r#, func$)   ->   function name(sender#)
```

and the dispatcher sends `@#nn` — sender, width, height. A handler written as
the page describes it compiles, registers, and is never called: the lookup is on
the type signature and simply misses. Nothing reports anything. Section 28's
defect with the documentation as its source.

**63 of 331 comparable events.** Corrected across 22 pages, and
`tools/check-event-docs.py` holds them from here. Watched failing on a page
broken on purpose.

### And the checker was counting, not comparing

The first measurement found 48. Comparing **types** rather than counts found 63.

`onmousedown` is sent as `@#nnn$` by eighteen libraries and as `@#n$nn` by five:
the same five parameters with the shift string third instead of last. Both are
arity 5, so a count-based check calls them equal — and the engine does not,
because it looks up the type string. `check-callbacks.py` compares types now.
Re-run strictly over the tree: **zero programs affected.** The 1,263 were right
by how they happened to be written, not by anything that checked.

### Measured against Delphi, which the author asked about

| event | FMX order | who matches |
|---|---|---|
| `onmousedown` / `onmouseup` | Sender, Button, **Shift**, X, Y | the five, not the eighteen |
| `onmousemove` | Sender, **Shift**, X, Y | the five, not the eighteen |
| `onkeydown` / `onkeyup` | Sender, Key, KeyChar, Shift | the nine, not the two |

So it is not a slip. There are two conventions, each applied consistently: one
faithful to FMX, one that moves the shift string last — which reads better in
BASIC, groups the numbers, and was chosen eighteen times. Neither is wrong
against Delphi. Having both is what costs.

### Left alone, on the author's decision

Aligning everything came to **57 dispatchers across 19 files**, plus the pages
and every example — and the measurement turned up two things the majority rule
answers badly: `onresize`'s majority would *discard* the width and height that
nine libraries deliver, and `onpaint` is split six to six with no majority at
all.

The author first chose to align on the information-preserving shapes, then
reconsidered and left it. That is defensible and is recorded as their call: the
split costs nothing today now that **every page describes what its own library
sends**, and 57 hand-edited dispatchers is precisely the kind of sweep that put
sections 45 and 46 in this document.

What remains is a trap only for somebody who learns one library and assumes
another: `rectangle_onmousedown` and `checkbox_onmousedown` hand over the same
five values in different orders. The pages now say so, one library at a time.

## 49. Android had not been broken; it had not been looked at

The APK in the tree was dated 16 March. It predates the handle registry, the
per-module state, the VM seam, and every one of the event repairs in sections
45 and 46. Nobody had installed the IDE on a phone this year, so the platform
had no verdict at all -- neither good nor bad, simply unmeasured. Had anyone
installed it, they would have met the same dead GUI events the author met on
the desktop.

Packaging it again took four failures, and only the last was interesting.

**Three were one lock.** `msbuild /t:Build;Deploy` stopped with `E0018 Unable to
delete directory` on `assets/deployinfo`, then on `bin`, then on
`Plan9Basic.classes`. `bin` was empty and still would not go, which is the
signature of an open handle rather than a permission. It was `adb`, holding the
output tree since some earlier install. Killing the process is not enough --
the daemon restarts on demand -- and only `adb kill-server` released it. Three
attempts were spent treating each directory as a fresh problem.

**One was real.** `r8` then failed with `NoSuchFileException` on nine of the
Android support libraries: `kotlin-stdlib-1.8.22`, `annotations-13.0`,
`core-1.15.0` and six more. The project file listed the libraries of an older
RAD Studio; the 37.0 installation ships `kotlin-stdlib-2.1.21`,
`annotations-23.0.0`, `core-1.17.0`. Three of the nine have no successor
because Kotlin 2.x folded `stdlib-common`, `-jdk7` and `-jdk8` into
`kotlin-stdlib`, and two new ones arrived as dependencies of `core` 1.17.

Both `EnabledSysJars` lists were rewritten by a script that refuses to write
unless the result is *exactly* the set of jars the installation ships. That
guard is what confirmed the reading: the stale list was the complete set of an
earlier installation, so the corrected one is the complete set of this one.
An upgrade of the IDE will break this again, and the same script will fix it.

### The device now reports its own verdict

The IDE self-test ran from a command-line switch, and an activity started by a
launcher has no command line -- the one host most worth measuring was the one
that could not be measured unattended. It now also starts when a file named
`selftest.run` appears in the app's documents, which `adb` can place, and
writes `ide-selftest.out` where `adb` can read it. The phone answered:

    OK - the IDE ran a program and its own features hold
      PASS arithmetic
      PASS strings
      PASS gui controls
      PASS free reports success
      PASS instr answers a position

A false alarm along the way is worth recording, because it is the same mistake
this document keeps finding: the trigger appeared to be ignored, and the
suspicion fell on the app. The app was innocent. An earlier call in the same
session had launched it already, so the second launch only brought a running
activity to the front and `FormCreate` never ran again. The binary was checked
for the literals -- present, UTF-16, as Delphi stores them -- before the actual
cause was found in the sequence of commands, not in the code.

### What BREAKPOINT proves, and where

`BREAKPOINT` is inert while trace is off: it clears its arguments from the
stack and returns. A check that merely executed it would prove nothing, so the
self-test turns trace on around the single statement.

With trace on the behaviour **diverges by host**, and that divergence is the
whole point of section 2.3's open item. The desktop IDE runs the VM on the UI
thread, `CanPauseForHostDialog` answers True, and `BREAKPOINT` is supposed to
stop and ask -- a self-test that stops and asks never finishes. Android answers
False, and the claim under test is that one: where parking would have the
platform kill the process, the frame is reported and execution carries on.

So the check is conditioned on the same predicate the engine consults. It runs
on the phone and not on the desktop, and that is not a gap being hidden: on the
desktop the correct behaviour requires a human finger, and no unattended run
can supply one.

What is still unmeasured on Android is touch. The self-test runs a program and
reads the console; it presses nothing. Given that the two defects found this
month were both about events reaching the interpreter, that limit is worth
stating plainly rather than leaving for somebody to discover.

## 50. Counting what nothing had ever run

"Test everything exhaustively" was the author's condition for making this
public, and there was no way to tell how far along that was. The 87% and 44%
quoted earlier in this document were arithmetic done once by hand and never
repeated.

`check-coverage.py` reads the same `Lib.Add` surface `check-docs.py` reads and
asks a different question of it: has a test ever called this name. The answer
was **3,491 of 4,488 -- 77.8%**, and the shape of the remainder was the useful
part: `HttpLib` 0/91, `MediaPlayerLib` 0/58, `AILib` 0/45, `ConfigLib` 0/31,
`SysLib` 1/43, `ZipLib` 0/15, `PlatformInfoLib` 0/9.

The unit is the name, not the signature, because a BASIC argument list is
usually an expression and typing it statically would mean evaluating it. The
number is therefore an upper bound and says so. What it reports exactly is the
other direction: an uncovered name is one nothing has ever run, and any defect
in it is undiscovered by construction.

### Three defects, found by running code for the first time

**`b64urlencode$` emitted a line break.** `TNetEncoding.Base64` is MIME base64
and wraps at 76 characters. The cosmetic consequence was that `b64valid`
rejected its own library's output; the real one is that URL-safe base64 with a
newline in it does not survive a URL, which is the only reason that function
exists. Nothing under 57 bytes wraps, which is why it went unseen. The three
encoders now use a `TBase64Encoding` created with no wrapping; the decoders
stay on `TNetEncoding.Base64`, which ignores line breaks, so anything encoded
by the old behaviour still reads back.

**`zipquick` named its entry differently depending on the separator.**
`ExtractFileName` splits on backslash only under Windows, so
`zipquick('bin/notes.txt', ...)` stored an entry called `bin/notes.txt` and
`zipquick('bin\\notes.txt', ...)` stored `notes.txt`. The archive's
shape followed which key the programmer pressed.

**The same root, five more times, in `SysLib`.** `extractfilename$`,
`extractfileext$`, `extractfilepath$`, `changefileext$` and
`forcedirectories` all go through RTL helpers that split on the platform
separator only. `extractfilename$('bin/notes.txt')` answered the whole path
back, and `forcedirectories('a/b/c')` failed outright because it could not see
a parent to create. Every other file function in this engine takes either
separator -- the OS accepts both -- so a program written with forward slashes
worked everywhere except in these five. Fixed at the root with one helper, and
only under Windows: a backslash is a legal character in a POSIX file name, and
replacing it there would corrupt names rather than repair them.

`HttpLib.AddFile` has the same `ExtractFileName` call and was **left alone**.
Its result is only observable in a multipart request body: `http_formurlencoded$`
walks text fields and skips file fields, and no function answers a file field's
stored name. The rule for this project is that a behaviour change comes with a
test that would fail if it reverted, and there is no way to write one without a
server. Recorded here rather than repaired blind, which is the failure mode
sections 45 and 46 already cost a session to.

### An applet caught the over-correction

Widening `b64valid` to accept whitespace was too wide. `21_Base64Lib_tests.bas`
has asserted since before any of this that base64 containing a space is
invalid, and it is right: line breaks are a wrapping convention, a space is not
part of any. The applet failed, the change was narrowed to `#10` and `#13`, and
the space case is now pinned in `tests/suite/23_archive.bas` as well.

Worth recording for what it says about the arrangement rather than the bug: the
suites passed the over-correction without complaint. The thing that caught it
was a program written to be run, which is the same lesson as flappy_bird in
section 47, arriving from the other direction.

### A language trap, now pinned

Writing the tests turned up something that is documented and still catches
people: string literals take escape sequences, so `"C:\folder\notes.txt"`
is not a path. `\f` is a form feed and `\n` is a newline, and nineteen
characters of intended path arrive as seventeen characters of something else. A
Windows separator has to be written twice. The reference documents the escape
table; `tests/suite/19_language_contract.bas` now documents the consequence.

### Where the coverage stands

`ConfigLib` 0 to 31, `ZipLib` 0 to 15, `SysLib` 1 to 43, `PlatformInfoLib` 0 to
9, plus `GzipLib`, `Base64Lib` and `StdLib` completed. Four new suite files,
and the engine suite went from 486 assertions to 644.

The largest gaps left are the three that need something the harness does not
have: `HttpLib` needs a loopback server, `MediaPlayerLib` needs an audio
device, `AILib` and `RAGLib` need credentials and a network. `HttpLib` alone is
91 functions -- more than `MediaPlayerLib` and `AILib` together -- and a local
listener in the harness is the one addition that would unlock a whole layer
rather than a handful of calls.

## 51. The next tier, and one crash nobody had reached

`IOUtilsLib` 10/52, `SQLiteLib` 11/52, `StrListLib` 22/60 and `JsonLib` 25/50 --
all four now at 100%, and 82.3% of the whole surface up to 83.7%. Four new
files, 260 assertions.

### The defect

**`strings_encoding$` read a name off a nil pointer.** `TStrings.Encoding` is
nil until a load or a save establishes one, and `GetEncodingName` compared it
against six known encodings and then, having matched none, read
`Encoding.EncodingName`. Every list a program has just made crashes -- an
access violation at address zero, which the far-call wrapper turns into a
runtime error rather than a value.

It answers the default encoding now, which is not a guess: `SaveToFile` without
an explicit encoding uses `DefaultEncoding`, so that genuinely is the encoding
in force. The nil guard went into the shared helper as well, so no other caller
can reach the same read.

**`strings_onchange$` answered a signature where the pages promise a name.**
The setter stores `name#@#` so the dispatcher can look the function up without
rebuilding it. That is an implementation convenience, and it leaked: setting
`"on_change"` and reading it back answered `"on_change#@#"`, so the obvious
comparison against what was written never matched. The reference calls it "Get
OnChange handler name", and now it is one. The stored form is unchanged, so the
dispatcher is untouched.

### Five conventions this suite got wrong before it got them right

Worth listing, because every one of them is documented and every one of them is
the opposite of the obvious guess. A reader coming to this engine will make the
same five.

| | the guess | what it is |
|---|---|---|
| `sql_bind*` index | 1-based, like SQLite's C API | **0-based** |
| a fresh `sql_query#` | positioned on the first row | **not positioned until `sql_step`** |
| `json_count` on an array | the number of items | **object keys only; use `json_len`** |
| `path_matchespattern`'s flag | case-insensitive | **case-SENSITIVE** |
| `strings_save*` / `load*` | 1 for success | **the line count** |

Two of them fail silently rather than loudly. A query read before its first step
answers empty strings and zeroes, which is exactly what an empty table answers.
`json_count` on an array answers 0, which is exactly what an empty array
answers. Neither raises, and neither is wrong -- they are answering a different
question from the one being asked.

### What was suspected and did not hold

`file_writeallbytes` casts its second argument to `TMemoryStream` with no handle
check, and `file_readallbytes#` hands out a stream registered with the collector
rather than with the handle registry -- so there is nothing to check against.
That reads like section 27's defect one library over.

It was probed both ways: a fabricated address, and a live handle of the wrong
class. Both answer 0 and set an error code, because the `try..except` around the
call catches the access violation. No silent corruption could be produced, so
nothing was changed. Recorded because the reasoning looked sound and the
measurement disagreed, which is the only reason worth writing down.

### Where the coverage stands

83.7%. What is left divides cleanly:

- **Needs a harness this project does not have.** `HttpLib` 0/91 (a loopback
  server), `MediaPlayerLib` 0/58 (an audio device), `AILib` 0/45 and `RAGLib`
  0/13 (credentials and a network). `HttpLib` alone is larger than the other
  three together.
- **Needs the GUI suite rather than the engine suite.** `FormLib` 7/103,
  `TimerLib` 0/15.
- **Needs nothing but the writing.** `DateTimeLib` 35/66, `StrLib` 41/63,
  `NumLib` 23/32, `RegexLib` 10/16, `DictLib` 16/20.

## 52. What the old applets are worth, measured

The author asked whether the applets in `Examples/` and `Demos/`, written years
ago as each library was finished, were still valid and whether they could seed a
proper test suite. Both halves have an answer, and neither is the obvious one.

**Syntactically they are all still valid, and this is proven daily.**
`check-all.py` compiles and runs all 128 on every run, and the compiler resolves
every call against the registered signature. A function that had changed shape
would fail to compile, not fail quietly. That risk is closed.

**Semantically there is almost nothing to be stale, because they claim almost
nothing.** 94 of the 128 cannot report a failure at all. In `--smoke` mode the
criterion is: compiles, runs without a runtime error, prints no `[FAIL]`. An
applet that computes the wrong answer and prints it cheerfully passes.
`Demos/` is 0 of 10. `58_PathLib_Tests.bas` is 1,002 lines exercising 101
distinct functions with **one** check in it.

**And that is exactly why they are worth keeping.** They reach **358 registered
names no suite reaches** -- someone who knew each library had already worked out
which functions matter, in what order, with what arguments. What is missing is
the assertion, not the knowledge. `FormLib` 77 names, `HttpLib` 48, `PathLib`
26, `StringGridLib` 25, `ListBoxLib` 20.

### Two things found while reading them

**The verification makes live calls to httpbin.org.** Five applets in
`Examples/` build an HTTP client against `https://httpbin.org` and issue real
requests on every `check-all.py` run. They assert nothing -- `http_ok` may
answer NO and the applet still passes -- so the cost is paid for no information:
a third-party dependency in a check that is supposed to be hermetic, minutes of
wall-clock, and a red build whenever that service is down.

**`regex_findpos` and `instr` disagree about where things are.** For the same
match in the same string, `instr` answers 6 and `regex_findpos` answers 7; for
absence, `instr` answers -1 and `regex_findpos` answers 0. Both are documented.
What was wrong is the reason the reference gave: "returns 1-based positions
(like other BASIC string functions)", which stopped being true when Phase 1.1
corrected `instr` to answer a position rather than a flag. The note now says
they differ, and says how. Unifying them is a language decision and is not
taken here.

### The tier that needed nothing but writing

`DateTimeLib` 36/66, `StrLib` 41/63, `NumLib` 23/32, `RegexLib` 10/16 and
`DictLib` 16/20 -- all five now 100%, and the surface 83.7% to 85.3%. Three
files, 154 assertions, and the map for every one of them came from `Examples/`.

Four conventions worth having in writing, all found by asserting something else
and being wrong:

- **`alcase$`/`aucase$` are Ansi, not "all".** They go through
  `AnsiLowerCase`/`AnsiUpperCase` and follow the locale; `lcase$`/`ucase$` go
  through `LowerCase`/`UpperCase` and only know a-z. On plain ASCII the pairs
  agree. They part on every accented letter -- which is most of the alphabet in
  the language this engine was written in, and is now pinned with one.
- **`lfill$`/`rfill$` take a character CODE**, not a string: `lfill$("42", 5,
  asc("0"))`.
- **Group zero is the whole match**, so three brackets make `regex_groupcount`
  answer four and `regex_groups#` starts with the match itself.
- **`int` floors and `fix` truncates.** They agree on positives and part the
  first time a number goes below zero: `int(-3.7)` is -4, `fix(-3.7)` is -3.
  That is correct classic BASIC and it caught this suite out.

### What is left, and what each part needs

`FormLib` 7/103, `StringGridLib` 60/110, `PathLib` 78/104 and the other GUI
libraries want the GUI suite, and the applets have already mapped them.
`HttpLib` 0/91 divides: the verbs need a loopback server, but the client
configuration -- headers, auth, cookies, timeouts, content types -- is most of
the surface and needs no network at all. `MediaPlayerLib` 0/58 needs an audio
device and `AILib` 0/45 credentials, and those two stay unmeasured until
somebody decides they are worth a harness.

## 53. Half of HttpLib needs no network, and FormLib needed none at all

Two libraries that looked like they were waiting on a harness, and were not.

**`HttpLib` 0/91 to 52/91, offline.** A client is a bag of settings until a verb
is called. Construction, base URL, timeouts, request headers, query parameters,
cookies, the three authentication schemes, the proxy, the behaviour flags,
`reset`, the whole form builder and the four encoding helpers are all reachable
with no server in sight -- 52 of the 91. What is left is the verbs, the
transfers and the response accessors, and `tests/suite/32_http_offline.bas` ends
by naming them rather than leaving the gap to be noticed.

**`FormLib` 7/103 to 100/103.** Nothing here shows a window. A form is an object
whether or not it is on screen, so the caption, the geometry, the constraints,
the window state, the style flags, the fill, the padding, the tag, the closing
behaviour, the z-order verbs, the screen accessors and all eleven event names
store and read back with no display involved. `Examples/31_FormLib_Tests.bas`
had already worked out which ones matter -- 727 lines calling 89 functions and
checking eighteen things.

### The defect

**`http_urlencode$` was form encoding, not URL encoding.** It wrote a space as
`+`, which is correct in a form body and wrong in a URL, where `+` is an
ordinary character. Its own reference page shows the answer it should give:
`hello%20world%20%26%20more`. The name and the documentation agreed with each
other and not with the code.

The repair is a substitution on the encoder's output, and it is lossless for a
reason worth stating: a literal `+` in the input is already written `%2B`, so
every `+` left in the output is a space and nothing else. Probed before the
change rather than assumed. Decoding is untouched and still reads `+`, `%20`
and `%2B` alike, so anything encoded by the old behaviour still reads back.

The two form and query builders inside the library keep `+`: there it is the
right encoding for the body being produced. Only the standalone helper changed.

### Where this leaves the count

88.5% of the surface, from 85.3%. The engine suite is at 1,055 assertions and
the GUI suite at 4,550.

What is left needs a decision rather than more writing:

- **A loopback server** would close the other 39 of `HttpLib` -- and would also
  let the five applets in `Examples/` stop calling httpbin.org on every
  verification run. That is currently the largest single cost in `check-all.py`
  and it buys nothing, because those applets assert nothing about the answers.
- **An audio device** for `MediaPlayerLib` 0/58.
- **Credentials and a network** for `AILib` 0/45 and `RAGLib` 0/13.

And a tier that still needs only writing: `StringGridLib` 60/110, `PathLib`
78/104, `ListBoxLib`, `ComboBoxLib`, `ImageLib`, `MemoLib`, `TimerLib` 0/15 --
all mapped already by the applets.

## 54. The applet was the authority, and it stopped a repair

`StringGridLib` 60/110 to 110/110 and `TimerLib` 0/15 to 15/15. The surface
crosses 90%.

### What nearly went wrong

`stringgrid_sort` reads its third argument as `Ascending := Args[2].n = 0`, so
**zero sorts A to Z** and non-zero reverses. Every page describing it names that
argument `ascending`, `asc` or `sortAsc` -- a flag called "ascending" that sorts
ascending when you pass false.

That is exactly the shape of the defects this document has been recording, and
the repair was obvious: make the code match the name. It would have been wrong.
`Examples/66_StringGrid_NewFeatures_Demo.bas` reads

    stringgrid_sort(grid#, 1, 0)  ' Column 1 (Name), Ascending

so the author knew the convention when the demo was written. The code and the
program agree; only the documentation is wrong, and the fix is to the pages.
They now say **descending**, and spell out that 0 sorts A to Z.

Section 50 recorded an applet catching an over-correction after the fact. This
one caught it before, and the difference matters: the suites would have gone
green on the inverted version, because the suites are written from the same
reading of the documentation that produced the mistake. A program somebody
actually ran is the only thing in the repository that carries the original
intent.

### Two conventions, both worth writing down

**Cell accessors take the COLUMN first**: `stringgrid_cell$(grid#, col, row)`,
not row and then column. Every one of the six typed accessors is the same way
round. This file had them backwards on its first run and read a progress value
out of a text cell -- no error, just the wrong number, which is the failure mode
that survives a test suite.

**A control can hold the focus with no window on screen.** `stringgrid_focus`
followed by `stringgrid_isfocused` answers true on a form that was never shown:
focus belongs to the form, not to the desktop.

### TimerLib, and what a timer cannot be asked here

15/15, and none of them is that a timer fires. `OnTimer` arrives on the message
loop and this runner has none to pump, so a test that waited for a tick would
wait forever. The file covers the object -- interval, enabled, tag, handler
name, the three verbs, the handle guard -- and says at its head that the firing
belongs to the applets, where a window is running.

`TimerLib` is also the one non-drawing library that genuinely reaches FireMonkey,
which `check-fmx-boundary.py` has reported all along: a timer is a `TTimer`.

## 55. Text a memo gives back is not the text it was given

`PathLib` 78/104, `ListBoxLib` 101/124, `MemoLib` 116/136 to 100% each,
`ComboBoxLib` 98% and `ImageLib` 97%. The surface reaches 91.9%.

All four had their *properties* covered by the generated suite and their actual
work covered by nothing: the pen movements, the items, the selection, the text
editing, the bitmap.

### What a program would trip on

**A memo normalises line breaks, and the text is not the same length coming out.**
`memo_text#(m#, "one" + chr$(10) + "two")` puts seven characters in;
`memo_textlength` answers **eight**, because the bare line feed is stored as a
carriage return and a line feed. A program that writes a memo, reads it back and
compares the two finds them different, and nothing in the library says why.

**And the caret cannot stand between the two.** Setting the selection start to 3
keeps 3, setting it to 4 -- between the CR and the LF -- answers 5. Both are
measured rather than inferred, and both are pinned.

**A listbox is single-select until told otherwise**, so `listbox_selectall`
reaches exactly one row. That is not a defect, but it is the opposite of what
the verb's name suggests, and it is now written down with the flag that changes
it.

**A path's bounds and a path's `bounds#` are different boxes.** `path_boundsx`
and friends measure the geometry; `path_bounds#` sets the control's rectangle on
the form. The same word for the shape and for the thing that draws it.

### What could not be asserted, and why it is said out loud

`memo_gotoend#` and `memo_gotobegin#` move a caret, and on a control that was
never shown the caret has nowhere to be -- FMX places it when the control is
realised. `selstart` does not follow. The file pins that both are reachable and
leave the text alone, and says in a comment that asserting the caret moved would
be asserting a window that is not there.

`image_load` reads a file this repository does not ship, so it is exercised for
its refusal: a picture that is not there must fail and leave the image empty
rather than half-loaded. That is the assertable half of loading.

### Where the count stands

91.9%, and what is left divides into three:

- **Needs a harness**: `MediaPlayerLib` 0/58 (an audio device), `AILib` 0/45 and
  `RAGLib` 0/13 (credentials and a network), and the 39 verbs and response
  accessors of `HttpLib` (a loopback server).
- **Needs a running message loop**: the animation libraries --
  `RectAnimationLib` 26/43, `ColorAnimationLib` 38/49,
  `BitmapListAnimationLib` 36/45 -- whose start/stop/running trio only means
  anything while something is ticking.
- **Needs only writing**: the transition effects' `loadtarget#`, and the last
  handful in `ComboBoxLib` and `ImageLib`.

## 56. A picture can come from the network, and the suite was written as if it could not

Told by the author, and it corrects a claim made in section 55. `image_load`
does not read a file -- it reads a **source**. An argument beginning `http://`
or `https://` is fetched; anything else is opened as a path. There is no second
function and no flag.

`Examples/60_ImageLib_WebGallery_Demo.bas` has been loading pictures that way
since it was written, and 59_ImageLib_Tests.bas alongside it. The applets knew;
the suite did not.

**Twenty-six units share the helper**: `ImageLib`, `MediaPlayerLib`,
`BitmapListAnimationLib` and the twenty-two transition effects, whose
`loadtarget#` is the same rule under another name. That is why those
twenty-two showed as uncovered -- they were never called at all.

### Asserting it without fetching anything

A suite that downloads a picture fails whenever somebody else's server is down.
The test proves the two paths are told **apart** instead, using a host under
`.invalid` -- reserved by RFC 2606 so that it can never resolve. No request
leaves the machine and the answer is immediate.

What separates them differs by library, and finding that out was the point:

- **`ImageLib` uses different codes.** A missing file is 6, file-not-found; an
  unreachable URL is 7, load-failed. The prefix is matched without regard to
  case, and any other scheme -- `ftp://` -- falls back to being a file name.
- **The twenty-two transitions use one code for both** and separate them only in
  the message: "file not found" against "failed to load from URL". All
  twenty-one besides `fadetrans` are swept individually, so a library that was
  never wired to the shared helper shows up here rather than in somebody's
  program.
- **`BitmapListAnimationLib` is built the other way round.** It tries the web
  first and falls through to opening the same string as a file, so an
  unreachable URL is reported as `File not found: https://...` -- honest about
  what was tried last, misleading about what was tried first. Recorded rather
  than changed: trying both is the more forgiving design, and the wording is not
  a contract.

### What this turned up about the verification

Four external hosts are contacted on every `check-all.py` run, across **39
applet files**: `httpbin.org`, `picsum.photos`, `api.chucknorris.io` and
`plan9basic.com` -- the author's own site, for an examples index and a set of
sound files.

None of those applets asserts anything about what comes back. So the run pays
minutes of wall-clock and a dependency on four third parties, and learns
nothing. It is also why a full verification now takes over twenty minutes.

That is the strongest argument yet for the loopback server: it would close the
39 remaining `HttpLib` functions **and** let the applets stop reaching outside
the machine. Both are one decision.

Coverage 91.9% to 92.5%.

## 57. A player forgets the volume until it has something to play

`MediaPlayerLib` 0/58 to 58/58, and the surface reaches 93.8%. Another library
that looked like it was waiting on hardware and mostly was not.

It is two families under one prefix. `media_*` is a player with no face: it
holds a file, a volume and a position and has nothing to draw. `media_ctrl_*` is
a control on a form that owns one of those and adds a rectangle, a visibility
and the usual events. Only the sound needs a device; everything else is an
object with settings.

### The finding

**Setting the volume before loading a track does nothing.** The setter clamps to
0..1 and passes the value straight to the FireMonkey player, which has nowhere
to put it while no media is loaded and answers its default of 1 whatever was
asked for. Setting 0.5 reads back 1; so does setting 0. The position behaves the
same way: a seek on an empty player leaves it at the start.

So a program that sets the volume and then loads a track gets the default rather
than what it set. The order has to be load first, then volume, and nothing in
the library or the pages says so.

**Not repaired, and the reason is the rule this project has been keeping.** The
fix would be to remember the requested volume and apply it when a track arrives,
and it cannot be pinned: proving it works needs a track to load, and this
repository ships no audio. Repairing what cannot be proven is what cost this
project a session in sections 45 and 46. Recorded here, and pinned as it stands,
so the day an audio fixture exists the test is already the wrong way round and
says so loudly.

### Asserting a media library with no media

The refusals carry most of the weight. A file that is not there and a URL that
cannot be reached both have to fail cleanly and leave the player empty rather
than half-loaded -- and the URL case uses a `.invalid` host, so nothing leaves
the machine. `play`, `pause` and `stop` on a player holding nothing have to
answer rather than reach for a device with nothing to send it. And a fabricated
pointer has to be refused by the registry rather than followed.

That is 57 of the 58 without a sound card, an audio file or a network.

### Still outstanding

`AILib` 0/45 and `RAGLib` 0/13 need credentials and a network. The 39 verbs and
response accessors of `HttpLib` need a loopback server. The animation libraries
need a message loop turning. Everything else is now covered.

## 58. The findings were reaching the tests and not the reader

Asked by the author, and the answer was no.

Eleven behaviours were found by writing a test that asserted the opposite and
watching it fail. Every one was written down -- in a comment above the
assertion, and in this document. Neither is a place anybody reading
plan9basic.com will ever look.

The first check of this was too loose to be worth anything: grepping the site
for the words in each finding reported all seven present. Reading the matches
showed the pages mention the *function* and not the caveat -- "Set volume" with
no hint that it is discarded before a track is loaded, "Select all items" with
no hint that it reaches one row. A search that answers yes to everything is a
search that answers nothing.

Checked properly, six of seven were absent. The seventh, `http_urlencode$`, was
correct on the page only because the code had been changed to match it.

### One page was carrying the opposite

`regexlib.html` said `regex_findpos()` returns 1-based positions "(consistent
with other Plan9Basic string functions)". That was true when it was written and
stopped being true when Phase 1.1 corrected `instr` to answer a position rather
than a flag. The markdown had already been fixed; the HTML, which is the file
people actually read, had not. It now states the difference and why it exists.

### What went onto the site

Eleven `warning-box` entries across ten pages, in the convention the site
already had:

| page | what a reader would otherwise discover the hard way |
|---|---|
| `sqlitelib` | bind and column indices are 0-based; a query is not on a row until `sql_step`; `sql_bindjson#` matches by name |
| `jsonlib` | `json_count` is object keys only, and answers 0 for an array |
| `regexlib` | `regex_findpos` is 1-based where `instr` is 0-based |
| `strlib` | `alcase$`/`aucase$` follow the locale; `lfill$`/`rfill$` take a character code |
| `numlib` | `int` floors and `fix` truncates |
| `ioutilslib` | `path_matchespattern`'s flag is case-SENSITIVE |
| `strlistlib` | the save and load family answers a line count |
| `gui/memolib` | a bare line feed is stored as CRLF |
| `gui/listboxlib` | `listbox_selectall` reaches one row unless multiselect is on |
| `gui/mediaplayerlib` | the volume is discarded until a track is loaded |
| `gui/imagelib` | a picture can come from the network, and the same rule reaches every effect, the sprite sheet and the media player |

`New docs/` was left alone: `package-site.py` does not ship it, so it is not
what a reader sees.

### What is not solved

Nothing checks this. `check-docs.py` holds the *signatures* to the code and
`check-event-docs.py` holds the *event shapes*, so a function that changes arity
cannot drift unnoticed. A function that keeps its shape and surprises the caller
has no such guard, which is exactly how `regexlib.html` came to be carrying a
claim the engine had contradicted for weeks.

## 59. The retired archive was still being counted

`check-docs.py` reported 38 registered names with no reference page. All 38 were
`p9_*` and `skill_*`, and the interesting part is where they come from:
`Libs/AI/archive/P9EngineLib.pas` and `SkillLib.pas` -- the archive item 1.6
retired.

It is in no `.dpr` and `.gitignore` excludes it, so **a clone does not have it**.
`check-coverage.py` skips it; `check-docs.py` did not. Two consequences, and the
second is the one that matters:

**The numbers differed per machine.** 4,690 signatures here against 4,651
anywhere else, and 38 undocumented against 0. A tool whose output depends on
which computer runs it cannot be quoted.

**And it would have approved a page for code nobody can obtain.** Had anybody
documented `p9_ask$`, `check-docs.py` would have found it registered -- in the
archive -- and reported that the documentation matched the code. That is
precisely the failure 1.6 was closed to stop: "The public documentation
describes a library nobody can obtain." Retiring the archive did not retire it
from the checker.

The exclusion is now stated in one place with the reason beside it, and a
documented `p9_*` would be MISSING, which fails the run.

### What the corrected count says

**4,488 registered names, and every one of them has a reference page.**
`check-docs.py` and `check-coverage.py` now agree on the size of the surface --
they did not before, and neither was obviously wrong from its own output.

That number is worth holding beside the other one: 93.8% of those names are
called by a test. The surface is fully documented and not yet fully executed,
and those are different claims about different things.

### The six that were never at risk

`check-callbacks.py`, `check-event-docs.py`, `check-engine-lookup.py`,
`check-event-binding.py`, `check-module-state.py` and `check-fmx-boundary.py`
have no exclusion either. Checked rather than assumed: only
`IntelligenceEngine.pas` in the archive contains anything they look for, and
none of the six walks a path that reaches it. Left alone -- adding a guard
against a case that cannot arise is a comment pretending to be code.

## 60. The AI libraries needed neither credentials nor a network

The author asked whether `AILib` and `RAGLib` could be tested against Ollama,
which is installed on this machine. They can, and the premise this document had
been repeating -- "needs credentials and a network" -- was wrong about both, in
different ways.

**`RAGLib` needs nothing at all.** The unit contains no HTTP call, no client and
no embedding: it is a local retrieval index over markdown files, scored by tag
and function name. `tests/gui/20_rag.bas` builds its own two-document knowledge
base under `bin\`, rebuilds the index and asks questions of it. 13/13, entirely
hermetic. It had been written off because it sits in `Libs/AI/`.

**`AILib` was built for a local model and had never been pointed at one.**
`ai_client#("ollama", "")` resolves to `http://localhost:11434/v1/chat/completions`
with no key -- the provider table has known `ollama` and `lmstudio` all along.
45/45 now, against `qwen2.5:7b` running here.

### How it runs without becoming a dependency

A clone has no Ollama, so this cannot be a required step, and it must not be a
silently-passing one either -- that is the failure this project spent a week
removing from the applets. `tests/local/` is outside the ordinary suite, and
`verify.ps1` gained a step that probes `localhost:11434` first and reports one
of three things: the run, `skipped - no model answering`, or `skipped -
qwen2.5:7b not pulled (have: ...)`. Both skip paths were exercised rather than
assumed.

The distinction from the applets matters: this is **localhost**. No third party,
no internet, nothing that can be down because somebody else's server is.

### Three traps, all found by asserting the obvious and being wrong

**`ai_endpoint#` is not another spelling of `ai_baseurl#`.** The base is a URL
and the endpoint is a **path appended to it** -- the request goes to
`FBaseUrl + FEndpoint`. Handing the full address to the second one sends it
twice and answers 404. Both spellings are now pinned, including the composition.

**The `ai_conversation_*` family takes a conversation, not a client** -- including
`ai_conversation_tokens` and `ai_conversation_last$`, which read like more client
accounting. Given a client they answer "Invalid conversation pointer", which is
the library being right and the name being inviting. `ai_tokensin` and
`ai_tokensout` are the ones that take the client.

**`rag_doc$` answers the error message as though it were content.** A missing id
returns `Error: RAGEngine: Document not found: ...`, and a caller cannot tell it
from a document that begins that way. Left alone: `RAGLib` has no `rag_error` to
ask, so the string is the only channel it has. Pinned as it stands.

### The one assertion about content

Everything else in the AI file asserts that a request went out, a reply came
back and the library reported no error -- never what the model chose to say,
which would be asserting the model. The exception is deliberate: a second chat
turn asks for a name given only in the first. No model can answer that unless
the library is actually sending the history, and the name appears nowhere in the
question. That one is about `AILib` and not about `qwen`.

Coverage 93.8% to 95.1%. What is left needs a loopback server (`HttpLib`'s 39
verbs) or a message loop turning (the animation libraries).

## 61. Ninety-nine per cent, and what the last four files found

The 131 names described as "needing nothing but writing" are written, and so are
the 51 animation ones. **4,448 of 4,488 -- 99.1%.** What is left is the 39 HTTP
verbs, which need a server to answer them, and nothing else.

Four files: the shapes and containers, the focus family and `EditLib`, the
effect targets, and the animations.

### Stop is not cancel

`rectani_stop` and `pathani_stop` jump the animation to its **end** -- normalized
time 1 -- even though nothing ever moved, while the float, integer, colour and
sprite-sheet ones stay at 0. Measured across all six rather than assumed from
one.

That is FireMonkey's semantic showing through: `TAnimation.Stop` completes the
animation and applies the final value, and `StopAtCurrent` is the verb that
actually cancels. A program calling `stop` to abandon a movement gets the
destination applied instead. Two of the six do it and four do not, which makes
it worse than if they all did.

### Three names that invite the wrong reading

**`edit_clear#` does not empty the edit.** It deletes the SELECTION -- the
reference says "Delete the selected text" and that is exactly what it does --
while `edit_clearselection#` is the one that only deselects and removes nothing.
Both pages are correct; the trap is entirely in how the names read.

**`colortoalphacolor` takes a name and answers a number.** The pair
`colortoalphacolor` / `alphacolortostring$` reads as though the first went from
one colour representation to another, and it goes from text to number.

**`blend_target#` wants an image control**, not a shape and not a bitmap handle.
Anything else answers "target must be a TImage", which is the library checking
its argument rather than dereferencing it -- the pattern section 27 established,
working.

### An empty image saves, and says it worked

`image_save` has no check for an empty bitmap. A 0x0 image writes a twelve-byte
file and reports success, so a program that trusts the return value believes it
saved a picture. The behaviour is defensible -- the bitmap saved what it had --
and it is the return value that misleads. Pinned as it stands rather than
changed.

### The web-to-effect chain, proven without fetching

The author pointed out that pictures for the more elaborate animations come from
the network, and that `Examples/` already does it. The chain those applets use
is: load a URL into an image, hand the image to an effect. It is now pinned end
to end with a `.invalid` host, so each step reports for itself -- the image says
the fetch failed, and the effect accepts the image it was given regardless,
which is the right division of responsibility between them.

Only four of the twenty-two transitions carry the image-control form at all;
the rest take a file or a URL and nothing else. That difference is worth knowing
before writing a program around one of them, and it is now written down.

### What could not be asked, and is said rather than skipped

`form_showmodal` is never called from a suite and never will be: it blocks until
somebody closes the window, and nobody is watching. `form_close` is called, and
does not hide the window -- FireMonkey raises `OnCloseQuery` and then `OnClose`,
and what follows is the close action's business, which without a message loop
does not complete. Both are stated in the file rather than left as gaps.

## 62. The better answer was blocking the available one

The author asked why the count had stopped at 99.1%, and why the HTTP verbs
could not simply be tested against the mirroring service the applets already
use. The question was right and my reasoning had been wrong in a specific way
worth writing down.

The 39 uncovered names map one to one onto httpbin.org's endpoints: `/get`,
`/post`, `/put`, `/patch`, `/delete`, `/status/404`, `/redirect/1`,
`/response-headers`, `/cookies/set`, `/bytes/N`. There was never a technical
obstacle.

The objection was about fragility, and it was real but narrow: an applet
tolerates httpbin being down because it **asserts nothing** -- it prints the
error and passes -- while a test with assertions turns the build red when
somebody else's server is unavailable.

**And that class of problem had already been solved, two sections earlier.** The
local-model step probes `localhost:11434` and reports `skipped` when there is
nothing there. The same arrangement works for a third party. I had been holding
out for a loopback server in the harness -- which would be better, because
nothing would leave the machine and the applets could stop reaching outside too
-- and in doing so let the better answer block the available one for three
turns.

The two new steps both reported 104 assertions on their first run -- 43 plus 61 -- because each was running the whole folder rather than its own file. The paths had been written through a Python heredoc, where `local\\01_...` collapsed to a literal  byte: an octal escape, not a backslash. Section 44 recorded the same trap costing a dozen edits and one silently-wrong checker, and the note there says to build backslashes with `chr(92)`. Written down and then walked into again.

`tests/local/02_http_verbs.bas`: 61 assertions, under five seconds, green on the
first run. The step probes httpbin and skips when it cannot be reached.

### What is asserted, and what is not

Only what the service guarantees: the status it was asked for, the header it was
told to echo, the body it was sent back. Never its mood. `/status/404` proves
`http_isclienterror` and disproves `http_isservererror`; `/redirect/1` proves
both sides of `http_followredirects#`; `/response-headers?X-Plan9=basic` proves
`http_respheader$` reads a header this test chose rather than one that happened
to be there.

### Where the count lands

**4,487 of 4,488 registered names -- 100.0%.**

The one exception is `form_showmodal`, and it is not an oversight: it blocks
until somebody closes the window, so no unattended run can call it. That is
written in `13_form_properties.bas` beside the verbs that can be called, rather
than left as a silent gap.

Two things that number does not say, and both matter more than it does. It
counts a name as covered the first time anything calls it, so it is an upper
bound on how well the surface is tested -- the tool prints that line under every
run for a reason. And a suite green on 6,000 assertions is still a suite written
from one reading of the documentation: section 54 recorded an applet catching an
inverted flag that every suite here would have gone green on.

## 63. One tap to the catalogue, and a server of our own

Two items the author authorised together, and each turned out smaller than it
looked because most of the machinery was already there.

### The catalogue row

`ExamplesBrowser.bas` is downloaded on the first run with a network and appears
in the file picker as an ordinary file. That is the whole problem: nothing says
this particular file is the way to the catalogue, and choosing it only loads it,
so a person still has to find Run. On Android, where loading a `.bas` is the
hard part to begin with, that is two obscure steps.

The change is a row of its own at the top of the picker, which loads **and**
runs it. No new protocol, no new format, no toolbar surgery -- the picker is
built in code, so the `.fmx` was never opened.

Two smaller things came with it. An empty documents folder used to close the
picker before it opened, which on a fresh install is exactly when somebody most
needs the catalogue; it now opens when the browser is there even if nothing else
is. And the row is offered only when the browser is on disk, because a row that
cannot work is worse than none.

The row itself needs the picker on screen and a tap, so the self-test cannot
reach it. What it does check is the part that decides: that the sentinel is not
a name a real file could answer to -- which would send somebody to the catalogue
when they asked for their own program -- and that the URL `EnsureRequiredFiles`
fetches still ends in the file name the picker looks for.

### The loopback server

`tests/LoopbackServer.dpr`, 253 lines on Indy's `TIdHTTPServer`, bound to
127.0.0.1 only. It answers the shapes httpbin.org answers, because that is the
contract the tests and the five HTTP applets were already written against:
`/get`, `/post`, `/put`, `/patch`, `/delete`, `/status/N`, `/redirect/N`,
`/response-headers`, `/cookies/set`, `/bytes/N`, and `/quit` to stop.

`verify.ps1` builds it, starts it, waits for the port to answer rather than
sleeping a guess, runs the verbs and stops it. The step is now **required**
rather than probed-and-skipped: the server comes from this repository, so there
is nothing left that can be unavailable.

**61 assertions in 186 milliseconds**, against about five seconds through the
real httpbin. Twenty-five times faster, and nothing leaves the machine.

Section 62 recorded holding out for this and letting it block the available
answer for three turns. Building it took one, which is the honest measure of how
much that hesitation cost.

### What is still outside

The 39 applets in `Examples/` still reach `httpbin.org`, `picsum.photos`,
`api.chucknorris.io` and `plan9basic.com` on every verification run, and still
assert nothing about what comes back. The server that would let them stop now
exists. Pointing them at it is a change to the author's own programs and is not
taken here.

## 64. Two numbers that disagreed, and nothing that would have said so

Asked whether the site could be published as it stands. Measuring rather than
answering turned up two drifts, and the second is the interesting one.

**The `Translations.ini` the IDE downloads was a line behind the repository.**
`EnsureRequiredFiles` fetches it from the site on the first run, so the site's
copy is what a fresh installation actually gets -- not the repository's. The
picker's new catalogue row added a string, and a missing key falls back to its
own name, so that row would have read `FilePickerExamplesRow` on every machine
installed after the next publish. Found by comparing the two files, not by
anyone meeting it.

**The engine had been 1.8 (BETA) for some time and every page still said v1.0.**
Four places: the boot banner on the front page, the badge beside it, the boot
animation, and the language reference's own header. The author authorised
showing BETA publicly, so all four now state what the IDE prints.

### The guard, because this is the checkable half of section 58

Section 58 closed by naming what nothing checks: a function that keeps its shape
and surprises the caller has no guard, and a caveat in prose cannot be held to
code. That is true of prose. A **version number** is not prose -- it is a fact
stated in two places that must agree, and comparing them is mechanical.

`check-site-deps.py` now reads `VERSION` out of `UnitMain.pas` and requires each
page that states a version to state that one, the expected number of times. The
count matters: a page saying it twice where three were meant has lost one, and a
bare "is it mentioned" check would pass.

Exercised in both directions rather than assumed -- one page was set back to
v1.0 and the check failed with the drift named and a non-zero exit, then
restored. A checker that has only ever been seen to pass is a checker nobody has
tested.

### What still stands between the tree and plan9basic.com

Two ebook PDFs are linked from the front page and are not in git, so a publish
that replaces the server wholesale would break both links. `check-pages.py`
knows them by name and says so on every run. They are the author's files and
presumably already on the host; nothing here can put them in the tree.

## 65. Twenty-five compiler hints, and one of them was a defect

The author pasted a clean Release build of the IDE -- no errors, no warnings,
twenty-five hints -- and asked whether any of it was worth correcting. Most of it
is not. Three were worth reading, and one of those turned out to be a defect the
suite was hiding.

### The budget that does nothing

`RAGEngine.pas(1585): Value assigned to 'MaxChars' never used` sits inside
`ExtractEssentialSections`, the function called to trim a document that does not
fit the caller's token budget. A trimming function computing a limit and
discarding it is worth a look.

Measured rather than reasoned about: a 3.4 KB document, one query, budgets of 10,
50, 100, 500, 2000 and 100000 tokens. **Every one answered 98 characters.**
`rag_retrieve_budget$` returns the same thing whatever it is asked for.

The root cause is not `MaxChars`. `MaxTokens` is used in that function, the
binding passes the number through, and `Retrieve` assigns it to `Budget` and
reads it. The loss is further in, and finding it is a session of its own rather
than something to guess at here.

**What the suite did instead of catching it.** `20_rag.bas` asserted
`len(small) <= len(big)` -- which is true when the two are identical, so a
budget that does nothing passes. That assertion now states what the engine
actually does, `assert_eq(len(small), len(big))`, with a comment naming it as
the defect. The run stays green and the defect stays visible, which is the same
choice made for `image_save` in section 61.

The lesson is about the assertion, not the bug: **a comparison that admits
equality cannot detect a parameter being ignored.** Anywhere a test says "no
more than", it is worth asking whether "exactly the same" would also pass.

### The one worth fixing

`UnitMain.pas(3665): Variable 'UpperFull' declared but never used in
'DoReplaceAll'`. The variable was declared for an uppercased copy of the text,
and the loop called `FullText.ToUpper()` **inside itself** instead -- so a file
with a hundred matches uppercased the whole file a hundred times, for an answer
that never changes. Now computed once, into the variable that was always there
for it. Covered by the IDE self-test's replace-all check, so the change is
pinned.

### The rest, and why they stay

- **Six `Eng`/`Outp` in `FormLib` and `MediaPlayerLib` constructors** are
  leftovers from the section 45 repair: the fix replaced `EngineOf` with the
  module-level engine, and the variables it had filled were left behind. Dead,
  harmless, and a reminder of where that repair went.
- **`parser.pas(1609)`** assigns `Result := True` and then guards with
  `Exit(False)`. Defensive, not wrong.
- **`AILib`'s `ProcessSSEChunk` and `OnReceiveData`** are private and unused,
  while `ai_chatstream` works -- an earlier streaming implementation left in
  place. Worth removing one day by somebody who knows which one is live.
- **`H2443` on `TCaretPosition.Create`** is an inlining hint: adding `FMX.Text`
  to the uses would let it expand. A caret is created on a keystroke; the cost
  is not measurable by anything here.

None of those changes behaviour, and this project does not touch what it cannot
pin.

## 66. A screenshot found both defects the compiler could not

The author built the IDE, opened the file picker and sent a picture of it. Two
things were wrong with the row added in section 63, and neither could have been
caught by anything in this repository.

**It read `FilePickerExamplesRow`.** A missing translation key falls back to its
own name, and the IDE loads `Translations.ini` from beside the executable --
`GetAppPath`, not the repository. There were **four copies** of that file: the
source in `utils/`, the one the IDE downloads from `Website/assets/devenv/`, and
two build outputs in `bin/` and `Win64/Release/`. Section 64 synchronised the
site copy and stopped there, because that was the one publishing would ship. The
one the developer's own build reads was still a line behind.

**And it was at the bottom of the list.** The comment beside the call said
"Added last so that Align := Top puts it first: FireMonkey stacks top-aligned
children in reverse order of creation." That is simply not true -- top-aligned
children stack in the order they sit in the parent's list, so the last created
lands last. The row is created last and moved with `Index := 0` now.

### What this says about the verification

Eleven green steps, 6,191 assertions, and both defects were sitting in a
screenshot. Neither is testable by anything here: one is a file outside the
repository that only a built IDE reads, and the other is where a control appears
on a screen nobody was looking at.

That is the same lesson as sections 47 and 54, arriving a third time and by a
third route. The suites prove the engine answers correctly. They cannot prove
the application looks right, and this one wrote a confident comment about
FireMonkey's layout order and was wrong about it.

### The guard that was possible

Copies of one file being equal is mechanical, so `check-site-deps.py` now
compares the two **tracked** copies of `Translations.ini` and prints the lines
that differ. The build outputs are deliberately excluded: git ignores them, so a
clone does not have them and checking them would fail for everybody except
whoever last built.

Exercised in both directions -- the key was removed from the site copy, the
check named the missing line and exited non-zero, then it was restored.

What remains unguarded is the copy beside the executable. Nothing in the build
puts it there: the `.dproj` has no post-build event, and the IDE only downloads
the file when it is **absent**, so a stale one is never refreshed. Worth a
post-build copy one day; recorded rather than added, because a `.dproj` edit is
not something to do blind.

## 67. The second guess was right, and I still could not have known it

Yesterday's screenshot showed the catalogue row at the bottom of the picker.
§66 fixed it with `Index := 0` and a comment saying that top-aligned children
stack in list order. Today's screenshot showed the text corrected -- and the row
still at the bottom.

Two candidate explanations, and no way to tell them apart by reading: either the
new claim about FireMonkey was wrong too, or the binary predated the fix. The
timestamps favoured the second. `Win64/Release/Plan9Basic.exe` was built at
09:10:05, the source edit landed at 09:13:39, and `Translations.ini` was copied
at 09:13:39 as well -- which is exactly the combination that updates the text
and not the layout, because the translation is data read at run time and the
ordering is code. But `bin/Plan9Basic.exe` was built at 09:15:23, *after* the
edit, and nothing in a screenshot says which of the two was run.

Having been wrong about this rule once, guessing a third time was not
defensible. `AlignOrderProbe.dpr` was written instead -- the same shape as
`VMThreadProbe.dpr`: one file, compiled with `dcc64`, measuring what no suite
can reach. It builds three scroll boxes and reports their rows sorted by
`Position.Y`, so the output reads top-to-bottom the way an eye does:

    1 extra added last, untouched : fileA fileB fileC EXTRA
    2 extra added last, Index := 0: EXTRA fileA fileB fileC
    3 extra created first        : EXTRA fileA fileB fileC

Line 1 reproduces the screenshot; line 2 is the shipped fix, and it works. So
the code was right and the binary was old.

**The rule underneath is neither of the two I had claimed.** FireMonkey stacks
top-aligned siblings by their current `Position.Y`, and consults the parent's
child list only to break ties. An earlier version of this probe pumped the
message queue between additions, which gave each row a real Y; the row added
last then had Y still 0, tied with the *first* row, lost the tie-break and
landed second -- and `Index := 0` moved it in the list while moving nothing on
screen. That output is what made me doubt a fix that was already correct.

Which means the shipped fix works for a reason worth writing down: the picker's
loop never turns the message queue, so every row still has Y = 0 when the last
one is created, the tie-break decides all of them, and `Index := 0` therefore
lifts this row to the top. Add a `ProcessMessages` inside that loop one day and
the fix silently stops working. The comment now says so, and names the
alternative that holds under either rule -- create the row before the files,
which line 3 measures.

The probe stays out of `verify.ps1`. It needs a form actually shown to make
FireMonkey run a layout pass at all -- with no window handle every row reports
`y=0` and the measurement says nothing -- and a verification run that flashes
windows is a verification run people stop trusting. It did its job by answering
one question once; the answer lives in the comment and here.

**What this cost, and what it bought.** Two screenshots and a rebuild to fix a
row's position, and at no point could the suites have helped: the first defect
was a data file the tests do not read, and the second was a layout rule with no
observable behaviour outside a window. What it bought is a measurement in place
of a belief. I had asserted this rule twice, confidently, in a comment, and been
wrong both times -- the third statement is the first one with a number behind it.
