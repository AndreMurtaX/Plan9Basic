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

### Which copy of the examples is canonical

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

### 3.5 Per-module global state

38 libraries keep `ModuleEngine`, `ModuleOutput` and `lastError` as unit
variables. No `TCriticalSection` anywhere in the libraries. Consequences: two
engine instances in one process are impossible, "BASIC inside BASIC" is risky,
and running off the UI thread is closed off.

### 3.6 VM on the UI thread

> **Measured again 2026-08-19 and partly stale.** The "125 remaining" figure
> below is no longer true: there is one `Application.ProcessMessages` in the
> libraries, and it is the BASIC function `processmessages()` that a script
> calls on purpose. Two more live in the host, both legitimate. What remains of
> this item is the VM itself, which does still run on the UI thread in both
> hosts. See [PLAN-restructure.md](PLAN-restructure.md) §2.1.

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

That is the honest boundary of "collapse the boilerplate", and it is worth
recording as a boundary rather than as a to-do.

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

**Left as named work, not fixed here.** `StdLib` and `StrLib` want the
treatment `PrintProc` and `InputProc` already got: a host callback, so the
engine asks for a clipboard or a message pump rather than reaching for one.
Both belong with the deferred 2.3 flip rather than with a repository move —
`processmessages()` is *literally* a question about which thread owns the
message loop, and answering it twice would be wasted work.

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

Both wait for each other. The obvious repair, draining in the pause loop too,
made it worse and is **not a positioning problem**: it runs a BASIC function
while the VM is parked mid-instruction, re-entering the stack machine and
touching the `ExecStatus` the pause itself depends on.

That is a re-entrancy question, and it wants design rather than another
twenty-minute build-deploy-tap cycle.

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
