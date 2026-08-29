# Plan9Basic — Engine Council: syntax and VM performance

**Date:** 2026-08-29
**Baseline:** commit `e9ab83f`
**Scope:** the interpreter core (`engine/`), the two dispatch loops, the parser,
and the language's surface syntax. Line references apply to the commit above.

---

## How this document was produced

This is the settlement of an adversarial review, run because the engine is
complete against its specification and the author had run out of his own ideas
for it. Eleven agents in three phases:

* **Five analysts**, one lens each and no overlap: the dispatch loop; value
  representation and memory traffic; the compile pipeline; syntax sugar and
  missing features; the call path, user and native.
* **Four judges**, each with a default verdict of *reject*: compatibility
  (does this break an existing applet?), Delphi feasibility (can Object Pascal
  express it on Win64, Linux64 and ARM64?), a performance red team (is the
  number wrong, and what measurement would falsify it?), and simplicity
  (does this make a program plainer, or only the language bigger?).
* **A completeness critic**, which read the engine independently to find what
  all nine had missed, and **a synthesist**, which wrote what follows.

45 proposals were filed. 29 survived all four judges, 9 took one rejection, 5
were rejected by two or more. Several analysts and judges did not stop at
reading: they built probes, compiled them with `dcc64`, `dccaarm64`,
`dcclinux64` and `dccosx64`, patched the engine and ran the suites. **Where a
number appears below it was measured on this codebase, not estimated** — but
those measurements were taken on the agents' machines and against patched
working copies, so treat every figure as a hypothesis with a known experiment
attached, not as a result already in the tree. Step 0 of the plan exists for
exactly that reason.

The immediate provocation was a remark by Vincent Parret — author of the
replacement VBScript and JScript engines used in FinalBuilder — on
delphipraxis.net, that the method-pointer opcode dispatch was leaving about 20%
on the table. Section 2.1 settles that claim. It does not go the way it was
expected to.

---

# Plan9Basic: what the council found, and what to do Monday

Five lenses read the engine, four judges tried to break every proposal, and a completeness critic went looking for what all of them missed. This is the settlement. Every claim below carries a `file:line` I re-read myself; where I corrected an analyst or a judge, I say so.

The short version, before the detail: **the lead you were given by Vincent Parret is the one thing on this list that does not pay, and the two largest wins are both outside the loop everybody was pointed at.**

---

## 1. What the council found

### 1.1 The host you ship runs two `QueryPerformanceCounter` calls per instruction; the host you develop in does not

`TExec.ExecuteFunction` — the second dispatch loop, the one every FMX callback, `OnClick`, `OnTimer` and `OnKey` actually runs in — does this on **every instruction**:

```pascal
// engine/exec.pas:1028-1037
if FTimeOut > 0 then          // 0 = no timeout (be careful)
begin
  Timer.Stop();               // -> QueryPerformanceCounter
  if Timer.ElapsedMilliseconds > deltaTicks then
  begin HadError := true; Break; end;
  Timer.Start();              // -> QueryPerformanceCounter again
end;
```

`ExecuteProgram` does not. It checks the same timeout **every 10,000 instructions** and never stops the watch (`engine/exec.pas:1153-1166`, `TIMEOUT_CHECK_INTERVAL = 10000` at `engine/exec.pas:1070`), under a comment that says *"HIGH PRIORITY FIX: Optimized timeout checking"*. The fix landed in one loop and not the other, 120 lines apart in the same file. Who pays: `UnitMain.pas:2260` sets `FBasic.ScriptTimeOut := 0` — the IDE turns it off. `runner/AppletRunner.pas:432` sets `FEngine.ScriptTimeOut := 30`, and the embedding guide in that file's own header (`runner/AppletRunner.pas:78`) tells third-party hosts to do the same. `runner/` is what goes on the device. The critic measured a 300k-iteration arithmetic loop at 61.64 ms in `ExecuteProgram`, 59.15 ms in `ExecuteFunction` with the timeout off, and **221.48 ms with `ScriptTimeOut = 30`** — 3.59x, ~34 ns per instruction of pure stopwatch. On a workload shaped like a real `OnTimer` game step (20,000 callbacks, 40 entities, two parallel arrays — i.e. `Demos/snake.bas`), 0.135 → 0.079 ms per frame, **1.71x off the deployed frame time**. This item was found after the judging and carries no verdicts; I verified the code and the asymmetry myself.

### 1.2 The per-instruction cost is managed-record traffic, not dispatch

`TAsmData` (`engine/exec.pas:111`) contains a `String`. Three lines move whole records of it: `StackMem[STKP] := dt;` in `PushAsmData` (`engine/exec.pas:3105`), `Result := StackMem[STKP];` in `PopAsmData` (`engine/exec.pas:3086`, which also returns the record **by value**), and `StackMem[STKP] := StackMem[SP];` in `fRetFunction` (`engine/exec.pas:2850`). Each compiles to `System.@CopyRecord`, which walks the record's RTTI field table at run time — the values analyst measured 7.85 ns against 2.45 ns for the identical three field assignments, and proved it is the record copy and not the string by showing a one-`String`-field record costs 5.85 ns, *more* than three separate field writes. On top of that, three of the hottest handlers declare managed locals that force an implicit `try/finally`: `fComma` (`engine/exec.pas:1427`) declares `traceMsg: String` and runs once per source line; `fPushC` (`engine/exec.pas:2720`) and `fPopStore` (`engine/exec.pas:2515`) each declare `dt: TAsmData` to move one `Extended`. The perf judge built the fix — 60 lines, no duplicated guards — and measured the empty 2M `FOR` loop 174.8 → 96.7 ms and the arithmetic loop 623.2 → 282.0 ms (**2.21x**), with `tests/suite` 1139/1139, `tests/gui` 4950/4950, `tests/negative` 10/10 still rejected and all 98 Examples green. All four judges accepted both halves.

### 1.3 `s$ = s$ + x$` is quadratic, and the cause is a reference count

`fPushS` (`engine/exec.pas:2750`) pushes a global string by handing `HeapMem[i]` whole to `PushAsmData`, which copies the record — so `HeapMem[i].s` and `StackMem[STKP].s` now share one buffer at refcount 2. `fAddS` (`engine/exec.pas:1183`) then does `StackMem[STKP].s := StackMem[STKP].s + StackMem[STKP + 1].s`, and Delphi's `_UStrCat` can only realloc in place at refcount 1. At refcount 2 it allocates a fresh buffer and copies the entire accumulated string — every iteration. `Pop()` (`engine/exec.pas:3058`) deliberately does not clear `.s`, and its comment is correct to say so, which makes the refcount-2 state structural rather than accidental. The perf judge's scaling run on the unmodified engine: 10k appends 3.70 ms, 20k 10.64, 40k 36.04, 80k 126.13, **160k 2330.52 ms** — 18x the time for 2x the work at the top end, because the growing buffer crosses a FastMM block-class threshold. The Delphi judge measured the underlying cliff directly: 200,000 appends at refcount 1 cost 2 ms, at refcount 2 cost 5,759 ms. This is the only proposal in the entire council that changes a complexity class, and the only one whose value grows without bound. 4/4 accept.

### 1.4 Every native call re-resolves its own target, and `a#[i]` is a native call

`fCallFar` opens with `farFuncSign := StrPas(PChar(strConst) + asmProg[PRG_IP].i);` (`engine/exec.pas:1225`), then `ProgramFunctions.ContainsKey(farFuncSign)` (`:1226`), then `ProgramFunctions[farFuncSign]` (`:1234`) — a fresh heap `String` and two hashes of it, per execution, for a signature that is a compile-time constant sitting in the instruction. Repeated verbatim in `fCallFarP` (`engine/exec.pas:1282`ff) and `fCallFarS` (`engine/exec.pas:1347`ff). Then `SetLength(Args, n)` on a local `array of TAsmData` allocates, zero-initialises, registers and later finalises a heap block for a call that may take one number. The dictionary is complete and frozen before the VM starts: `exec.ProgramFunctions` is filled at `parser.pas:1235-1238` inside `Parser.Compile`, which returns before `basic.pas:227` calls `LoadSource`. Two analysts patched the engine independently and got 54 ns and 56 ns per call saved from the signature lookup alone; the array-read loop went 158.9 → 117.9 ms. And this is not a rare path — `a#[i]` compiles to `PUSH# / PUSHC / PUSHC / CALLEX "narr_get@#n" / POPSTORE`, so every array element access pays it. 4/4 accept on the resolution change.

---

## 2. Performance

### 2.1 Vincent Parret's 20%: right about the mechanism, wrong about this engine, and not the largest win

**No.** Do not write the case statement.

Vincent is describing `asmProg[PRG_IP].proc()` at `engine/exec.pas:1122`, an indirect call through `TExeFunc` (`engine/exec.pas:136`), a 16-byte method pointer bound once at load (`engine/exec.pas:3037`) by `TokenToFunc` (`engine/exec.pas:3144`). His mechanism is real and his estimate is a fair one for a typical bytecode VM. It does not hold here, and the reason is instructive.

The dispatch analyst built the hybrid case — 356 lines added, thirty-odd opcodes inlined verbatim, `else asmProg[PRG_IP].proc()` for the rest — and measured 328 → 178 ms, **1.84x**. The perf judge then built the control the analyst never built: **v2**, the same case over the same tokens, but with arms making *static calls to the same handler methods* instead of inlining them. That isolates exactly what Vincent describes. Result on the real engine: empty 2M `FOR` 174.8 → 182.3 ms (slower), arith 623.2 → 610.3 (1.02x), `abs()` loop 100.5 → 101.9 (slower), array read 225.7 → 236.7 (slower). Stacked on top of the value fixes, net zero to negative. **The 1.84x was the inlining, not the dispatch** — and inlining's win is exactly the win that §1.2 gets in 60 lines by deleting the `@CopyRecord` calls and the managed locals, without transcribing 356 lines of hand-copied guards into the hottest code in the engine.

Two corrections to the record while I settle this. First, the perf judge's *explanation* is wrong even though his measurement stands: he says `TAsmToken` is "a large sparse enum" so `dcc64` emits a compare chain. It is not sparse — `TAsmToken` (`engine/exec.pas:~60-108`) is a plain dense enumeration of ~123 members with no explicit ordinals, and the Delphi judge probed `Ord(High) = 122` and compiled a 25-arm case clean on `dcc64`, `dcclinux64` and `dccaarm64`. A jump table is available. The number is the evidence; the reason offered for it is not. Second, the compat judge caught something that would have bitten regardless: the proposal only touches `ExecuteProgram`, while `ExecuteFunction` has its own `asmProg[PRG_IP].proc()` at `engine/exec.pas:1023` — so 30 opcodes would have acquired two implementations that must stay byte-identical forever, and the transcription slip would only surface inside callbacks.

Verdicts on `hybrid-case-dispatch`: compat `accept_with_changes`, delphi `accept_with_changes`, simplicity `accept`, perf **`reject`**. Three-to-one in favour — and the dissenter is the only one who built the control. I side with the dissenter.

**The measurement that settles it before any code is written**, if you want it settled by your own hand: land the value fixes (§1.2) first, then build only the case-with-static-calls on top — no inlining, `else asmProg[PRG_IP].proc()`, maybe 80 lines — and run a pure arithmetic loop. **Require better than 10% before writing the inlined version.** On the perf judge's machine it does not clear that bar; on yours it may differ, but that is the experiment, and it costs an afternoon rather than a week.

### 2.2 Do — ranked

| # | Change | Measured win | Effort | Red team |
|---|---|---|---|---|
| 1 | Throttle the timeout check in `ExecuteFunction` (`exec.pas:1028-1037`) to a counter, same shape as `exec.pas:1155-1158`; stop stopping the watch | **1.71x** deployed frame time; **3.59x** on arithmetic callbacks | ~8 lines | Not judged — found after the council. Code verified; suites green on the critic's patched engine (1139 + 4950 + 10/10) |
| 2 | `record-assign-to-field-assign` (`exec.pas:3105`, `3086`, `2850`) + `hoist-managed-locals-hot-handlers` (`fComma` 1427, `fPushC` 2720, `fPopStore` 2515) | **2.21x** arith loop, 1.81x empty loop | ~60 lines | **4/4 accept.** Built and suite-verified by the perf judge |
| 3 | `append-in-place-peephole` — new `APPEND$` opcode + peephole in `TCompiler` | O(n²) → O(n). 126 ms → ~17 ms at 80k appends; unbounded above that | medium | **4/4 accept.** Compat requires it be **instruction-count-preserving** (see 2.4) |
| 4 | `resolve-far-calls-at-load` — side `FFarTable` + index in `TInstr`, plus `FFarNames` so `'Far call error (sig)'` still names the function | ~**55 ns/call**; array-read loop 1.35x | ~20 lines | **4/4 accept.** Two independent builds agreeing within 4% |
| 5 | `reuse-far-call-arg-buffer` — depth-indexed static `FArgBuf`, passed with `Slice` | ~46 ns/call on top of #4; array-read path 483 → 322 ns combined | small | **4/4 accept_with_changes.** Two hard conditions (2.4) |
| 6 | Give `ExecuteFunction` the drain that `ExecuteProgram` has | Responsiveness, not throughput | small | Not judged. `FDrainProc` is called only at `exec.pas:1102` and `:1149`; `ExecuteFunction` never drains, so a computing callback blocks `QueueAndWait` for up to `FScriptTimeOut * 1000` ms (`basic.pas:478`) — the exact failure `basic.pas:361-363` says the drain exists to prevent |
| 7 | `fold-println-crlf` — replace nine emitted instructions with three at `parser.pas:3589-3597` and `parser.pas:3631-3639` | 43% off a headless `println` loop | 12 lines | **4/4 accept.** Perf: discount the number — in the FMX host, `fPrint`'s throttled refresh dominates |
| 8 | Take the mutex out of handle validation | 13.53 ns of the 21.45 ns `IsHandleOf` costs; ~9% of `a#[i]` | small | Not judged. `THandleRegistry.IsValidAs` takes a process-wide `TCriticalSection` (`HandleRegistry.pas:97`, entered `:215`); `ArrayLib.pas:250` calls it from `ValidateArrayType`, which `narr_get` calls at `ArrayLib.pas:407` |
| 9 | `fix-token-corruption-getenumvalue` — `parser.pas:5009` and `:5014` | Zero speed. A field that lies | 2 lines | **4/4 accept.** `GetEnumValue(TypeInfo(TAsmToken),'PUSH')` returns −1; the correct value is already in `tokenType` |
| 10 | `single-hash-dynamic-lookups` — `TryGetValue` in the six ICALL/`ON..CALL` handlers | ~45 ns per removed lookup, on rare paths | small | **4/4 accept.** Compat: do **not** touch `@programFunctions[...].Entry` (`exec.pas:1917`) in the same commit |
| 11 | `loadsource-numeric-conversion` — `exec.pas:3039-3047`, `UnitUtils.StrToFloat2` | −17% on `LoadSource` | small | **4/4 accept.** Keep the decimal-separator branch |
| 12 | `one-function-dictionary` (a)+(b), and `dedupe-function-dictionary-copies` | Deletes dead code; ~1 ms/compile | small | **Accept (a)(b), 3 judges reject (c).** `LibFunctionsTable` has **zero** `.Add` in `parser.pas` — verified — yet `basic.pas:223-225`, `:253-255`, `:643-645` copy it every compile, for a property commented out at `basic.pas:180` |
| 13 | `clear-stacks-on-clear` — finalise `StackMem`/`AuxStack` in `Clear` (`exec.pas:886-906`) | Footprint. A 10 MB string survives into the next run | small | **4/4 accept** |
| 14 | `shrink-vm-instance` **(a) only** — split `AuxStack` into `AuxStackN`/`AuxStackS` | ~250 KB of 831,992 | small | **Accept (a); 3 judges reject (b)** (dynamic `StackMem` adds an indirection to the hottest array and turns overflow guards into growth) |
| 15 | `jump-threading-at-load` | Fraction of a percent | ~25 lines | **4/4 accept.** Perf: drop the ns figure. Never thread past `atkComma` — `exec.pas:1431` is the only writer of `srcLine` |
| 16 | `basnum-double-alias` — `TBasNum = Double` | **Zero on Win64/Android/iOS/macOS-ARM.** Linux64 and macOS-Intel only | small | **4/4 accept_with_changes.** Sell it as consistency, not speed |
| 17 | Set `FError` when `MAXINSTR` is hit (`lexer.pas:43`, `:722`) | Correctness of a diagnostic | 2 lines | Not judged. A 30,002-line valid program reports `line 16667, pos 183332: Value expected` |
| 18 | Make `/` and `println` agree on a line break | Cross-platform correctness | small | Not judged. `parser.pas:3631-3639` hardcodes CRLF; `fAddCRLFS` (`exec.pas:1177-1180`) uses `System.sLineBreak` |
| 19 | Guard `fPrint`'s separator read (`exec.pas:2613`) with `TypeStack` | Correctness | 1 line | **4/4 say ship this half alone.** Four lines above, `exec.pas:2604` *does* consult `TypeStack`; `:2613` does not, and works today only because a numeric push copies an empty `.s` over the slot |

### 2.3 Do not — measured zero, or negative

| Proposal | Verdicts | Why |
|---|---|---|
| `hybrid-case-dispatch` | 3 accept / **perf reject** | §2.1. The 1.84x is the inlining, and the inlining's win is item #2 for a tenth of the code |
| `hoist-exception-frame` | 3 accept / **perf reject** — and the critic rebuilt it | The majority is wrong. Win64 uses table-driven SEH, so `try` costs nothing on entry. The critic patched `exec.pas:1121-1136` exactly as specified and got **slower on every run** (79.47 → 80.59, 77.64 → 80.04) and on all four loops. The claimed 7.6% is a synthetic-probe artifact. It also buys a real semantic change (a `CallBackProc`/`FDrainProc` exception now sets `FErrorMessage` and `ended`) for a measured 0% |
| `single-countdown-host-checks` | 3 accept / **perf reject** | Same synthetic-probe evidence, same answer: empty 93.2 → 94.8, arith 270.3 → 270.1. Zero. Keep the analyst's warning in your head anyway — never hoist `Assigned(FDrainProc)` or `FTimeOut` into a precomputed flag, both are public properties (`exec.pas:455`, `:459`) |
| `unmanaged-vm-stack-cells` (full split) | 3 accept_with_changes / **perf reject** | The isolated 2.25x was measured against a baseline that still had the `@CopyRecord` in it. After item #2 the surviving `.s` traffic is a `_UStrAsg` with nil on both sides: measured ceiling **2.6%**, against rewriting the two whole-record copies and 30 `.s` sites. Do it for the Linux64 footprint if at all |
| `type-directed-push` | 3 accept_with_changes / **perf reject** | Measured ceiling 2.6%, and it trades away a verified `PRINT`-correctness dependency plus a whole-engine audit. Ship only item #19 |
| `drop-proc-from-tinstr` | 3 accept_with_changes / **perf reject** | Explicitly downstream of the case. If you ever want the 16 bytes, take them without the case: a one-byte handler index into a class-level `array of TExeFunc`, ~15 lines, falsifiable on its own |
| `compiler-emits-instructions-not-text` | 3 accept_with_changes / **perf reject** | Wrong axis. 367 `Emmit` sites plus 15 passes to save compile time, which is 4.70 ms once per RUN. Nothing in the tree compiles at run time |
| `constant-folding-in-emmit` | perf **reject**, delphi effectively so | Its own evidence says most `PUSHC` are call-argument counts, and the `FOR`-header saving is two instructions *once per loop*. Against that, a mis-set barrier is a jump landing two instructions off — a silent wrong answer |
| `marshalling-branch-is-already-free` | **4/4 accept — as a decision to do nothing** | `CallNative`'s fast path (`exec.pas:524-526`) measured at 10.5 vs 9.5 ns against a bare call. The comment at `exec.pas:128-131` claiming it is free is accurate. Removing the branch would silently break any host running the VM off the UI thread |

### 2.4 Conditions that are not optional

- **`append-in-place-peephole` must preserve the instruction count.** The parser bakes *absolute* indices into emitted text as it goes (`parser.pas:2556` with the backward patch at `:2598`, `ParseUntil` at `:3825`, `ParseWhile` at `:3953`), which is why all fifteen `TCompiler` passes are strictly 1:1 in-place rewrites. Rewrite `PUSH$ v` → `NOP`, `ADD$` → `NOP`, `POPSTORE$ v` → `APPEND$ v`. Match only the exact four-instruction shape — in `s$ = s$ + a$ + b$` the emission is `PUSH$ v / PUSH$ a / ADD$ / PUSH$ b / ADD$ / POPSTORE$ v`, and pairing the first `PUSH$` with the last `ADD$` is wrong. `APPEND$` **must clear the stack slot it consumes**, or the destination is still at refcount 2 and nothing changes.
- **`reuse-far-call-arg-buffer`:** (i) `n > 64` or depth `> 15` must **fall back to the existing `SetLength` path**, never error — "a function taking more than 64 arguments would now error" is a compatibility break and this commission forbids it. (ii) Resetting `FArgDepth` in `TExec.Clear` is not enough: `Clear` runs only from `TExec.Create` and the top of `ExecuteProgram` (`exec.pas:1081`), and `ExecuteFunction` never calls it, so an `RTError` inside the fill loop leaks depth across callbacks. Save and restore `FArgDepth` in `ExecuteFunction` alongside `STKP`/`BASEP`/`AuxStackIdx` (`exec.pas:1043-1046`, `:1058-1063`), inside the `try/finally` that already exists for exactly this class of bug.
- **`hoist-managed-locals`:** the compat note in the record says *"keep `fPushC`'s `.s := ''`"*. **There is no such line.** `fPushC` (`exec.pas:2720`) assigns only `dt.n`; `.s` is cleared by the compiler's implicit managed-local init and `.p` is left as stack garbage. The direct-write rewrite must write `StackMem[STKP].s := '';` **explicitly** — that is what keeps `fPrint`'s separator check at `exec.pas:2613` working — and must make a deliberate, commented choice about `.p` rather than inheriting garbage.
- **`resolve-far-calls-at-load`:** keep the missing-signature error firing at **call** time. `LoadIntermediate` (`basic.pas:615`) is public and bypasses the parser's compile-time check, and a load-time `RTError` would be discarded anyway because `Clear` at `exec.pas:1081` resets `ended` to false.
- **`basnum-double-alias`:** the record says "Linux64 alone gets 80-bit". The Delphi judge probed `dccosx64` and found `Extended` is 16 bytes there too, and that `Base_Linux64` does not exist as a configuration in `Plan9Basic.dproj` while `Base_OSX64` does. Also: `Website/docs/language-reference.html:667` currently tells users numbers are "80-bit on Windows/Linux x86/x64" — that has been wrong on Win64 all along. Fix the doc in the same commit.

---

## 3. Syntax

Only sugar that cleared **both** the compatibility judge and the simplicity judge appears here. One structural warning applies to four of them: `BasIdentKind` is consulted at `lexer.pas:261`, *before* the `'('` test at `lexer.pas:268`, and that test only remaps the three identifier tokens. So adding a word to `BasIdentKind` breaks a user *function* of that name as well as a variable. The Delphi judge compiled and ran programs using `with`, `each`, `in`, `const` and `elseif` as ordinary numeric variables against the shipped `tests/bin/Plan9BasicTest.exe` — **they pass today**. Under a mandatory-compatibility commission, every new keyword must be **contextual**, recognised at statement position only.

### 3.1 `bare-return` — the strongest item in the set

```basic
' today: a compile error, 'Return value expected'
function OnBtnUpDown(sender#)
  if running = 0 then
    return 0            ' invent a value the engine is about to discard
  end if
  nextDirY = -1
  return 0
end function

' after
function OnBtnUpDown(sender#)
  if running = 0 then return
  nextDirY = -1
end function
```

**Where:** `ParseReturn`, `parser.pas:3723`; the guard that raises is `parser.pas:3731-3734`, firing only when the next token is `btkCRLF` or `btkColon`. The defaults it needs already exist for the fall-off-the-end case in `ParseEndFunction` (`parser.pas:2462-2468`: `PUSHC 0` numeric, `PUSHC$ ""` string, `PUSHC 0` pointer, then `RETFUNCTION`). No compiler pass, no VM change, ~10 lines. `RETURN` outside a function is handled first at `parser.pas:3727-3728` and is untouched. **Verdicts: compat accept, simplicity accept, delphi accept, perf accept.** The simplicity judge parsed all 1,115 `FUNCTION` declarations in `Demos/` + `Examples/`: 929 have no `RETURN` at all and 122 more return only a dummy — **1,051 of 1,115 functions are procedures forced to pretend they are functions.** One gap the compat judge found: the guard tests only `btkCRLF` and `btkColon`, so a bare `return` as the last token of a file still falls through to the expression parser.

### 3.2 `compound-assign` — `+= -= *= /=`, and `$ +=`

```basic
' today
emptyCount = emptyCount + 1
let score = score + val * 2
writeCol = writeCol - 1

' after
emptyCount += 1
score += val * 2
writeCol -= 1
```

**Where:** `AssignNum`'s guard at `parser.pas:264`, `AssignStr`'s at `parser.pas:535`. **No lexer change** — `'+'` and `'='` are already separate tokens, and `lexer.TokenInfo(n)` / `lexer.CurrIP` are public and carry `pos`/`len`, so adjacency can be required and `x + = 1` stays an error. Emit `PUSH @v / <expr> / ADD / POPSTORE @v`; operand order is already right because `fSub` (`exec.pas:2858`) computes first-pushed minus second-pushed. **Verdicts: 4/4 accept.** 406 corpus lines match `^(let )?(\w+) = \2 [-+*/]`. Take all four operators even though `*` and `/` are 8 sites — refusing `*=` after granting `+=` costs the reader a surprise. Leave `s$ -=` rejected: `-` on strings already means truncate. Leave the three array-element paths (`parser.pas:276/327/379`) out of the first cut.

The values lens filed a second, incompatible version of this (`compound-assign-sugar`, with a new lexer token). **Withdraw it.** Carry forward only its one good idea: string `+=` should emit `APPEND$` directly rather than making the peephole rediscover the pattern.

### 3.3 `let-declaration-list`

```basic
' today — Demos/snake.bas:79-104 is 26 lines of this
let frm# = pointer#(0)
let lblScore# = pointer#(0)
let lblHigh# = pointer#(0)

' after
let frm#, lblScore#, lblHigh#, lblMsg#, food#, tmr#
let score, highScore, running, gameOver, snakeLen
```

**Where:** the `btkLet` arm at `parser.pas:1444`. Emit byte-for-byte what the longhand emits (`PUSHC 0 / POPSTORE @n`, `PUSHC$ "" / POPSTORE$ @n`, `PUSHC 0 / PUSHC 1 / CALLEX# "pointer#@n" / POPSTORE# @n`), so `EnumVarsFuncs` (`parser.pas:4836-4872`) registers the globals identically. `let a#, b#` is a compile error today. **Verdicts: 4/4 accept.** 618 `pointer#(0)` lines in the corpus.

The analyst named an alternative honestly and it is a genuine fork you should decide rather than default past: `EnumVarsFuncs` could register globals written *inside* functions too, deleting all 618 lines with **no new syntax at all** — at the cost of turning a typo inside a function from a compile error into a silently created global. Also decide what `let a, b = 5` means before shipping; reject it outright rather than letting it half-parse.

### 3.4 `inline-else`

```basic
' today — Demos/snake.bas:513-517
if i = 1 then
  rectangle_fill#(seg#, "#44ff44")
else
  rectangle_fill#(seg#, "#00cc00")
end if

' after
if i = 1 then rectangle_fill#(seg#, "#44ff44") else rectangle_fill#(seg#, "#00cc00")
```

**Where:** `ParseIf` takes the single-line path at `parser.pas:2796`, emitting `POPNJUMP_CRLF` without incrementing `ifCnt`; `AssignIfCRLF` (`parser.pas:4418-4438`) already resolves it by scanning forward to the next `atkComma`. `btkElse` already exists — no keyword reserved. **Verdicts: compat accept_with_changes, simplicity accept, delphi accept, perf accept.**

**The compat judge found a program in your own tree that this breaks if you get one detail wrong.** `Demos/space_invaders.bas:1164-1169`:

```basic
if alienDirX > 0 then
  if GetRightmostAlien() >= GAME_W - 20 then needDrop = 1
else
  if GetLeftmostAlien() <= 20 then needDrop = 1
end if
```

That `else` belongs to the outer block `IF`. If the inline-IF stack survives the CRLF, the new `btkElse` arm binds it to the inner single-line `IF` instead — inverting the alien direction logic and leaving `end if` matched against nothing. **Pop the inline-IF stack unconditionally at `btkCRLF`**, so `ELSE` can bind to a single-line `IF` only on the same source line, and add that file's block to `tests/suite` as a regression case. Clearing the stack in `ClearCounts` (`parser.pas:1158`) is necessary but runs per program, and this needs per line.

The simplicity judge also trimmed the headline: of 931 matching blocks, the median flattened one-liner is 105 characters and only 30% fit under 80. The honest population is ~280–350 sites, not 884.

### 3.5 `string-plus-number`

```basic
' today
label_text#(lblScore#, "SCORE: " + str$(score))

' after
label_text#(lblScore#, "SCORE: " + score)
```

**Where:** `NextStringExpression`'s `btkPlus` arm at `parser.pas:1909`, and `NextStringValue`'s `else` at `parser.pas:2001` (`SetError('String expected')`). Call `NextArith()` for the numeric operand — the right precedence level, consuming `*`, `/`, `MOD`, `^` and stopping at the next `+` — then emit `PUSHC 1 / CALLEX$ "str$@n" / ADD$`. **Verdicts: compat accept_with_changes, simplicity accept_with_changes, delphi accept, perf accept.**

Two conditions, both real. **(1) Do not dispatch on `ExpressionKind`.** It returns `ekNumber` for anything not in its two lists (`parser.pas:1317-1322`), and `btkRoundOpen` is in neither — but `NextStringValue` has a genuine `btkRoundOpen` arm at `parser.pas:1954-1959` that parses a parenthesised *string* expression, so `s$ = "a" + (b$ + c$)` compiles today and would be handed to the numeric parser. Gate on an explicit token list: `btkInteger`, `btkFloat`, `btkIdentifier`, `btkNumFunction`, `btkPointerArray`, `btkAmpersand`, `btkMinus`. **(2) The engine already has two disagreeing number-to-text conversions**, and this sugar must pick one and say so. `fPrint` formats with `FloatToStrF(..., ffgeneral, 13, 0)` at `exec.pas:2608`; `str$` uses `FloatToStr` (15 digits). `println "third = "; 1/3` prints `0.3333333333333`; `"third = " + str$(1/3)` prints `0.333333333333333`. Use `str$@n` and document it on the same page as `PRINT`'s formatting.

Keep the asymmetry deliberately: `-` between a string and a number keeps its truncate meaning (`parser.pas:1922-1935`), `/` keeps `ADDCRLF$`. And the kind of an expression is still decided by its first token, so `println x + " items"` still fails — **make that failure teach**: "put the text first, or wrap the number in `str$`", not "String expected".

### 3.6 `elseif-one-word` — and `const`, contextual only

`ELSEIF` costs eight lines: `ParseElse` (`parser.pas:2386-2400`) already implements the chain via `ELSEIFTEST`/`ELSEIFBODY`, which `AssignIf` already resolves at `parser.pas:4361-4392`. It buys familiarity, not brevity — 27 `else if` lines in the corpus. `WEND`/`ENDWHILE` and `NEXT`/`ENDFOR` already establish doubled spellings as house style (`lexer.pas:600-604`). **Verdicts: compat accept_with_changes, simplicity accept_with_changes, delphi accept_with_changes, perf accept** — all four requiring contextual recognition, because `elseif = 5 : println elseif` compiles and runs today.

`const-declarations` clears the same bar with the same caveat, plus two corrections. **Verdicts: 4/4 accept_with_changes.** Lead with the right motivation — `MAXVARS` is 515 (`exec.pas:39`) with three reserved registers, `compTooManyVars` fires at `parser.pas:4864`, and named constants currently burn that budget — not with `PUSHC`-vs-`PUSH`, which after item #2 is worth low single-digit nanoseconds. **Make assignment to a `CONST` a compile error**; that diagnostic is the thing the programmer actually gains and neither analyst mentioned it. Ship the literal form only; it does not need the folding proposal I have rejected.

`step-expression` also clears both judges (`accept_with_changes` from all four) and is the lowest-value item I am forwarding: all 10 `STEP` uses in the corpus are literal. It survives only because it removes a rule from the language's description. If you build it, **leave the literal path byte-identical as a separate branch** — `parser.pas:2597-2598` back-patches `TMPOutput[i-3]` by raw index arithmetic, and the perf judge is right that the sign-independent test adds three instructions per iteration, a 25–30% regression on an empty loop if it ever reaches the literal path.

### 3.7 Considered and declined

| Proposal | Killed by | Reason |
|---|---|---|
| `with-block` / `with-block-property-sugar` | simplicity **reject** (both), delphi **reject** (the second) | `.fontsize(16)` manufactures the name `label_fontsize#@#n` by string concatenation from a prefix inferred elsewhere in the file. `Demos/snake.bas:159` — `label_fontsize#(lblScore#, 16)` — can be read in isolation; the sugared line cannot. Terser, not plainer. The alternative spelling is worse: inside the block `fontsize = 14` is a bare assignment that is not an assignment, while outside it the identical text stores 14 in a global. Two analysts filed two **incompatible** designs for one grammar slot, which is itself the tell. The 3,717 handle-first signatures are a real irritation, but the fix for a library naming convention is not a grammar rule that reconstructs the names |
| `for-each` | simplicity **reject**, delphi **reject** | The census collapses it: `arraysize(` appears **17 times in 41,274 lines**. The real idiom is `for i = 1 to MAX_ENEMY` with parallel arrays indexed by the same `i` (`Demos/snake.bas:507-509` walks `snakeX#`, `snakeY#` and `snakeRect##` together) — which `FOR EACH` cannot express at all. It reserves two words, one of which is `in`. It needs two hidden globals **per loop** out of a 512 budget, with no reuse scheme. Its own author rated it 0.55 |
| `string-interpolation` | compat **reject**, delphi **reject**, simplicity **reject** | Barred by your own brief — imported because other languages have it. 47 corpus lines join three or more pieces. And the mechanism cannot produce correct constants: `CurrS` reconstructs a token's text from `pos`/`len` by reading back into the source (`lexer.pas:598-600`) and the parser emits `Emmit('PUSHC$ "'+lexer.CurrS()+'"')` (`parser.pas:2000`) — so a synthetic literal run has no contiguous span to name, and `{{` is by definition not one. It is a change to the data structure every error message reads, for the smallest payoff in the set |
| `default-parameters` | delphi **reject**, simplicity **reject** | Structurally blocked, and demonstrated rather than argued: a call may precede its declaration (`println later(3)` above `function later(x)` compiles and runs, resolved by `EnumFuncs`/`AssignFuncs` at `parser.pas:4895-4916` and `:4203-4212`), so at emit time the parser does not know the callee's arity. The later pass cannot insert instructions because of the absolute-index constraint. And the corpus has **zero** functions declared twice in one file — no overloading, no forwarding stubs |
| `strip-nop-instructions-at-load` | compat **reject**, delphi **reject** | It destroys `DATA`. `AssignData` rewrites `DATA n` into `NOP <value>` at `parser.pas:4163` and `DATA$ s` into `NOP "<text>"` at `:4168`, recording the index in `DataStmts`; `fRead` then reads `asmProg[DataStmts[...].DataPos].n`. Delete every `fNop`-mapped instruction and the payload is gone. It also cannot reach `UserFunctionsTable`, which lives in `TBasicParser`/`TBasicEngine`, not `TExec`, and is copied out at `basic.pas:218-220` **before** `LoadSource` runs. And deleting `atkComma` deletes `TRACE`: `fComma` (`exec.pas:1427-1457`) is not a `srcLine` setter with a trace test bolted on, it **is** the trace emitter. `jump-threading-at-load` is the safe half; ship that instead |

### 3.8 The syntax question nobody asked

Five analysts proposed twelve features. None asked what happens when a call fails. The language has no `TRY`, no `ON ERROR`, no catchable failure — `BasIdentKind` (`lexer.pas:553-627`) has no arm for any of them. What exists instead is a per-library last-error convention applied to about half the libraries. I counted the raise sites myself:

| library | `raise Exception` | error accessor |
|---|---|---|
| `engine/Libs/ArrayLib.pas` | **50** | none |
| `engine/Libs/ConfigLib.pas` | **34** | none |
| `Libs/DictLib.pas` | **25** | none |
| `Libs/StrListLib.pas` | **12** | none |
| `engine/Libs/StrLib.pas` | 0 | `strerror@` (`StrLib.pas:1559`) |

121 unconditionally fatal raise sites live in the four **collection** libraries — arrays, dictionaries, config, string lists — which are exactly the ones an ordinary program leans on, and the only four with no accessor. An off-by-one on `a#[i]` aborts the program; the same mistake in `mid$` sets `strerror` and continues. The cheap version needs **no new syntax at all**: give those four the `lastError` + `<lib>_error@` treatment `StrLib` already has. The full version is `TRY`/`CATCH`, and it is a better proposal than anything the syntax lens produced. (Note: the critic listed `DictLib`/`StrListLib` under `engine/Libs/`; they are in `Libs/`.)

---

## 4. What was rejected, and why

Consolidated from §2.3 and §3.7, in one place, with vote counts:

- **`hybrid-case-dispatch`** — 3 accept / 1 reject, and I side with the dissenter, who built the control (§2.1).
- **`hoist-exception-frame`** — 3 accept / 1 reject; the perf judge and the critic independently measured it **slower**. Majority overturned.
- **`single-countdown-host-checks`** — 3 accept / 1 reject; measured zero.
- **`unmanaged-vm-stack-cells`** (full split), **`type-directed-push`**, **`drop-proc-from-tinstr`**, **`compiler-emits-instructions-not-text`**, **`constant-folding-in-emmit`** — each 3 accept_with_changes / 1 hard reject, all on the same ground: measured ceiling too small, or wrong axis, for the risk.
- **`strip-nop-instructions-at-load`** — 2 hard rejects. Destroys `DATA`, cannot reach `UserFunctionsTable`, deletes `TRACE`.
- **`with-block`**, **`with-block-property-sugar`**, **`for-each`**, **`string-interpolation`**, **`default-parameters`** — 2 to 3 rejects each; the simplicity judge killed all five and the Delphi judge killed three of them independently.
- **`shrink-vm-instance` (b)** and **`one-function-dictionary` (c)** — the halves that change ownership or allocation strategy; three judges each said land the neutral half and treat these as separate lifetime reviews.
- **Three duplicate filings of the far-call resolution change** (`resolve-far-call-at-load`, `resolve-native-signatures-at-load`, `resolve-far-calls-at-load`) and **two of compound assignment**. One change each. Do not count them three times when ranking; the three independent measurements were 17, 51 and 54 ns, and the 17 came from a probe that changed two things and decomposed by assumption. The real figure is **~55 ns/call**.

---

## 5. An order of work

Each step names what it must not break and the measurement that says it worked. Steps 0–3 are the whole story; everything after is cleanup.

**Step 0 — build the bench harness first, in the tree.** Nothing in this council is reproducible tomorrow. `tests/` has `AlignOrderProbe`, `LoopbackServer`, `NoFmxProbe`, `Plan9BasicTest`, `VMThreadProbe` — no `CompileBench.dpr` and no `DispatchBench.dpr`, both of which analysts told you to re-run. Add `tests/bench/` and a `-Bench` switch on `tests/build.ps1`, with five loops: empty 2M `FOR`; `s = s + i * 2`; `a#[i]` read and write at 500k; an `abs()` call loop; **and a callback-driven `OnTimer`-shaped loop** — the entire council measured only the loop the shipped product does not spend its time in. Include the 160k-append point, not just 80k. *Must not break:* nothing. *Success:* five numbers you can re-take in one command.

**Step 1 — the callback loop.** Replace the per-instruction `Timer.Stop()`/`Start()` at `exec.pas:1028-1037` with a counter of the same shape as `exec.pas:1155-1158`, and use `GetElapsedTicks` on a running stopwatch. Add the drain (`FDrainProc`, matching `exec.pas:1143-1150`) and the `FIX #12` exception frame that `ExecuteProgram` has and `ExecuteFunction` does not. ~8 lines for the timeout, a few more for the rest. *Must not break:* the timeout must still fire — a callback with an infinite `do…loop` under `ScriptTimeOut = 2` must still return at ~2.00 s; and `ExecuteFunction` must keep saving and restoring `STKP`/`BASEP`/`AuxStackIdx` (`exec.pas:1043-1046`, `:1058-1063`) — that `try/finally` is load-bearing. *Success:* `tests/gui` 4950/4950 (this is the callback-driven suite, so it is the right instrument), plus the frame benchmark at `ScriptTimeOut = 30` matching the `= 0` figure. Expect **1.7x on the deployed frame time**.

**Step 2 — the value handling.** `record-assign-to-field-assign` at `exec.pas:3105`, `:3086`, `:2850`, then `hoist-managed-locals` in `fComma` (move the trace block verbatim into `TraceComma`), `fPushC` and `fPopStore`. ~60 lines. *Must not break:* `PopAsmData`'s two early exits — the underflow path at `exec.pas:3078-3084` and the type-mismatch path at `:3087-3089`, **neither of which decrements** — must be preserved exactly; the rewritten `fPushC` must write `StackMem[STKP].s := '';` explicitly with a comment saying it replaces the implicit init; `TraceComma` must produce byte-identical trace text (`TRACE` is exercised by `tests/suite/15_breakpoint_degrade.bas`). *Success:* arithmetic loop **2.2x**, empty loop **1.8x**, and 1139 + 4950 + 10/10 + 98 Examples identical. This is the largest constant-factor win available and it is the one Vincent's estimate was pointing near but not at.

**Step 3 — the append.** `APPEND$` opcode plus a count-preserving peephole (§2.4). *Must not break:* `s$ = s$ + s$` (safe by construction — at refcount 2 `_UStrCat` allocates), a local-variable destination, and a `GOTO` label sitting between the `PUSH$` and the `POPSTORE$` — the compiler already tracks labels at `parser.pas:4471`. Add all three as suite cases. *Success:* the ns-per-append figure stops climbing across 10k/20k/40k/80k/**160k**. Today that series is 3.70 / 10.64 / 36.04 / 126.13 / 2330.52 ms.

**Step 4 — the far-call path, once.** `resolve-far-calls-at-load` with `FFarTable` + `FFarNames`, then `reuse-far-call-arg-buffer` with the two mandatory conditions (§2.4). Apply both to **all** of `fCallFar`/`fCallFarP`/`fCallFarS` — the array *store* path goes through `fCallFarP` (`exec.pas:1282`). *Must not break:* `'Far call error (sig)'` must still name the function; the missing-signature error must still fire at call time; `Slice(Buf, 0)` must work, because `GetParams` emits `PUSHC 0` for zero-argument signatures. *Success:* array-read loop 1.35x from the resolution alone, and the `abs()` loop approaching the call-free baseline once the buffer lands. **Measure them separately** — a probe that patches both and reports one number cannot tell you which half paid, which is how the 17 ns figure got into the record.

**Step 5 — the two correctness fixes that stand alone.** Guard `fPrint`'s separator read at `exec.pas:2613` with `TypeStack`, matching the guarded read four lines above at `:2604`. Set `FError`/`FErrorMessage` when `MAXINSTR` is hit at `lexer.pas:722`, the way the `SetLength` failure at `:713-718` does. Both are small, both are latent, and the first one becomes load-bearing the moment anyone optimises the push path. *Success:* a `PRINT` with mixed types after a string-heavy loop still errors correctly; a 32,002-line program says so instead of reporting `line 1, pos 0`.

**Step 6 — the cheap sweep.** `fix-token-corruption-getenumvalue` (2 lines, and it is the precondition for anything that ever trusts that field), `fold-println-crlf`, `loadsource-numeric-conversion`, the dead `LibFunctionsTable` deletion, pair-enumeration and capacity on the surviving dictionaries, `clear-stacks-on-clear`, `jump-threading-at-load`, `single-hash-dynamic-lookups`, `shrink-vm-instance (a)`. *Must not break:* `TokenToFunc`'s `rteUnknownInstr` path at `exec.pas:3229` must survive anything that touches it, and `jump-threading` must never thread past `atkComma`. *Success:* suites identical; `LoadSource` −17%; the `println` loop moves on the headless runner.

**Step 7 — syntax, in this order.** `bare-return` → `compound-assign` → `let-declaration-list` → `inline-else` (with the `space_invaders.bas:1164-1169` regression case) → `string-plus-number` (token list, not `ExpressionKind`; `str$@n` and a documented formatting note) → contextual `elseif` and `const`. *Must not break:* nothing. Every one of these is a compile error today — the analysts probed each spelling against the shipped `tests/bin/Plan9BasicTest.exe`. *Success:* a suite file per feature, plus a diff of the ASM dump of all 98 Examples showing **zero change** for programs that do not use the new syntax.

**Step 8 — decide, do not drift.** Three things are yours and not the council's: whether `EnumVarsFuncs` should register globals written inside functions (it would delete 618 lines with no new syntax, at the cost of turning a typo into a silent global); whether `Extended` becomes `Double` on Linux64 and macOS-Intel, which changes numeric results there — *toward* consistency, but a change; and whether the four collection libraries get `lastError`, which is the cheapest real answer to a language that cannot survive an off-by-one.

**One last honest note.** If your only interest were the number Vincent named, the correct answer to this whole exercise is: do step 2, take the 2.2x, and never write the case statement. Steps 1 and 3 are worth more than step 2, and neither was in the brief.

---

## Appendix — corrections the analysts made to the brief

Each analyst was given a summary of the architecture and told to verify it
rather than trust it. These are the places where the code contradicted the
summary, or where a measurement contradicted an expectation. They are recorded
because several are facts about the engine worth knowing on their own — among
them that `Extended` is 8 bytes on Win64 and Android and 16 on Linux64 and
macOS-Intel, which means the same BASIC arithmetic runs at a different precision
depending on the target.

1. [dispatch] TInstr and TAsmData do not have one layout. Compile-time probe (SizeProbe.pas, dcc64/dccaarm64/dcclinux64 37.0): Extended is 8 bytes on Win64 and Android ARM64 but 16 bytes on Linux64. So TAsmData is 24 bytes on Win64/Android and 32 on Linux64; TInstr (exec.pas:200) is 32 bytes on Win64/Android and 48 on Linux64. Any statement about cache lines per instruction has to be made per platform: Win64/Android fit 2 TInstr per 64-byte line, Linux64 fits 1.33. TExeFunc is 16 bytes everywhere, as the summary says.

2. [dispatch] LEAD 2 IS LARGELY DEMOLISHED AS STATED, THOUGH THE COST IS REAL. 'Every single instruction sets up an exception frame' is not what the Win64 code does -- Delphi's 64-bit compilers use table-driven unwind info, so entering a try costs no instructions at entry. But the try/except at exec.pas:1121 is still measurably expensive: in the isolation benchmark it is 7.6% of the loop's total time (421.01 ms -> 388.88 ms over 27M instructions). I did not disassemble, so I cannot say whether that 7.6% is lost register allocation across the protected region or something else. What matters practically: it is worth removing, it is cheap to remove, and once the handlers are inlined it shrinks to about 2% because the loop body grew.

3. [dispatch] LEAD 3 IS CONFIRMED AND IS THE BIGGEST SINGLE FACTOR -- BIGGER THAN DISPATCH. Changing only the stack cell type from managed (n/p/s) to unmanaged, with the method-pointer dispatch and every helper call left exactly as they are, took the isolation benchmark from 405.14 ms to 180.44 ms (x2.25). A 24-byte unmanaged cell and a 16-byte one performed the same (180.44 vs 188.30), so the cost is the managed field, not the copy width. Three separate mechanisms: PushAsmData (exec.pas:3105) does a managed record assignment per push; PopAsmData (exec.pas:3074) returns a record with a String by value, so every numeric pop allocates a temporary that must be finalised; and fPushC/fPopStore/fPopStorePtr/fPopNCall/fInitFunc declare a local `dt: TAsmData`, which forces an implicit initialise-and-finalise around each of those handlers.

4. [dispatch] VINCENT'S 20% IS BOTH TOO HIGH AND TOO LOW, FOR THE SAME REASON. Measured on this codebase's exact shapes: a case statement whose arms merely call the same handler methods statically, instead of through the method pointer, is only 11.5% faster (405.14 -> 363.28 ms). That is the pure dispatch change he describes and it lands under his 20%. But a case statement whose arms contain the handler bodies is 4.2x faster (405.14 -> 95.75 ms), because it also removes ~76 procedure prologues, the nested calls to Pop/PushAsmData/PopAsmData, and the managed temporaries above. The win is not in the dispatch, it is in what inlining the handler unlocks. Handler size is why this works here: the top ten opcodes by dynamic count are 3 to 8 lines each (fAdd exec.pas:1171, fPush exec.pas:2648, fPushC exec.pas:2720, fPopStore exec.pas:2515).

5. [dispatch] THE LOOP PAYS FOR SOMETHING THE SUMMARY DOES NOT MENTION, AND IT IS BIG. The `,` opcode (atkComma -> fComma, exec.pas:1427) is 16.3% of all executed instructions in a numeric benchmark and 21.1% in a string one (measured with the engine's own OnProgress hook, no engine modification). Its entire job with tracing off is `srcLine := asmProg[PRG_IP].i`. One in five dispatches buys a single field store.

6. [dispatch] SUPERINSTRUCTIONS FOR COMMON PAIRS ARE NOT WORTH IT ONCE THE CASE IS IN. The top adjacent pairs are `, ;PUSH` (11.6%), `PUSH;PUSHC` (9.3%), `PUSH;PUSH` (9.3%), `POPSTORE;,` (7.0%). I tested the ceiling by deleting atkComma's work entirely from the case loop -- the strongest possible fusion result for the single most frequent opcode -- and the difference was inside noise (+/-4.8%, negative on one benchmark and positive on the other). What a superinstruction would save is the dispatch, and the case arm has already saved it. Fusion also costs backward compatibility that the case does not: jump targets are absolute indices in TInstr.i, so removing slots means rewriting every branch target at load time, and IP is a public property (exec.pas:448) used in error text.

7. [dispatch] LEAD 4 IS CONFIRMED BUT SMALL. The callBackObj test (exec.pas:1139), the drain counter (1143) and the timeout counter (1153) together cost 3.5% of loop time (388.88 -> 375.35 ms). Real, cheap to fix, not where the money is.

8. [dispatch] PRG_IP AND STKP AS FIELDS COST ALMOST NOTHING, AND MOVING THEM CAN LOSE. With every opcode inlined and no fallback, locals were 7.5% faster (85.94 -> 79.64 ms). With a fallback arm for cold opcodes -- which any realistic version needs, since the handlers read PRG_IP -- locals were 12% SLOWER (54.17 -> 60.75 ms), because each cold dispatch has to write three fields out and read them back. Leave them as fields.

9. [dispatch] Libs/GUI/** is 102,646 lines, not ~116k. The ~116k figure looks like Libs/GUI plus engine/Libs (16,278), which is 118,924. lexer.pas 775, parser.pas 5118, exec.pas 3234, basic.pas 809 are all exactly right, as are exec.pas:111 / :136 / :200 / :1068 / :3037 / :3144. TokenToFunc is 78 case arms mapping to 76 distinct handlers.

10. [dispatch] A separate compatibility fact the Extended probe turned up, outside this lens but worth someone's attention: because Extended is 16 bytes on Linux64 and 8 on Win64/Android, the same BASIC arithmetic runs at 80-bit precision on Linux and 64-bit everywhere else. That is a live cross-platform behaviour difference in the shipped engine, independent of anything proposed here.

11. [values] Lead #3 is half wrong, and the wrong half matters. Arithmetic does NOT move a string. fAdd (exec.pas:1171), fSub (2859), fMul (2264), fDiv (1460), fMod (2255), fGE/fGT/fLE/fLT/fNE/fEQ (1794-2290) never call PushAsmData/PopAsmData at all -- they do `Pop()` (which is only `Dec(STKP)`, exec.pas:3058) and then write `StackMem[STKP].n` in place. Per arithmetic instruction the string traffic is ZERO. The traffic is entirely in the value-movement handlers: fPush (2648), fPushC (2720), fPushS (2750), fPushPtr (2729), fPopStore (2515), fPopStoreS (2541), fRetFunction (2850) -- and in the far-call argument marshalling (1237-1266).

12. [values] The dominant cost of the managed field is NOT the reference count. It is that a record containing a managed field makes `StackMem[STKP] := dt` (exec.pas:3105) a call to `System.@CopyRecord`, which walks the record's RTTI field table at run time. Measured on Win64 with dcc64 37.0 -$O+, 20M iterations: whole-record assign 7.85 ns; the identical three field assignments (including the same _UStrAsg on .s) 2.45 ns; number-only 1.00 ns. Proof it is @CopyRecord and not the string: assigning a record with ONE String field and nothing else costs 5.85 ns, i.e. MORE than three separate field assignments. The reference count on a numeric push is nearly free because HeapMem[i].s is nil for a numeric variable -- _UStrAsg takes the nil-source path with no lock-prefixed instruction.

13. [values] TAsmData is not one layout. Compile-time probe (sizeprobe.dpr, {$IF SizeOf(...)}), all six dcc compilers in RAD Studio 37: Win32 Extended=10 / TAsmData=24; Win64 Extended=8 / TAsmData=24; Linux64 Extended=16 / TAsmData=32; Android ARM64, iOS ARM64, macOS ARM64 all Extended=8 / TAsmData=24. Linux64 is the outlier on BOTH counts: 33% more bytes per stack slot, and real 80-bit x87 arithmetic where every other shipped target gets 53-bit SSE2 doubles. The same BASIC program can already produce different numeric results on Linux64 than on Win64 and Android64. Nothing in the tree acknowledges this.

14. [values] Libs/GUI is ~103k lines, not ~116k. `find Libs/GUI -name '*.pas' | xargs wc -l` gives 102,646; adding engine/Libs/GUI/TimerLib.pas gives 103,376.

15. [values] 'a case over ~75 handlers' -- TokenToFunc (exec.pas:3144) has 78 arms (`grep -c 'Result := f' engine/exec.pas`). Immaterial, but stated for completeness.

16. [values] Variables ARE compile-time slots, so no correction there -- but the summary should record what is NOT. parser.pas:4994-5010 rewrites every PUSH/POPSTORE/FORCYCLE/READ operand into an integer: negative = local (BASEP + i + MAXLOCALS), non-negative = HeapMem index, resolved once in TCompiler.EnumVarsFuncs (parser.pas:4815). Array element access is NOT a slot: `a#[i]` compiles to a far call (AsmDump of `v = a#[1]`: `PUSH# 5 / PUSHC 1 / PUSHC 2 / CALLEX "narr_get@#n" / POPSTORE 6`), and the far-call signature is re-materialised from a char buffer and hashed twice on every single execution (exec.pas:1225, 1226, 1234).

17. [pipeline] `engine/parser.pas` is two units of work, not one. `TBasicParser` (parser.pas:1168) emits postfix TEXT; a second class `TCompiler` (parser.pas:4051-5115, entry at 4756) then runs **15 rewrite passes** over that text (AssignTokens, AssignCommas, EnumVarsFuncs, AssignLabels, AssignIfCRLF, AssignIf, AssignSelect, AssignBreak, AssignContinue, AssignRepeat, AssignWhile, AssignDo, AssignFuncs, SkipFuncs, AssignData) using its OWN TAsmLexer instance, re-lexing lines 23 times over. Measured on Examples/25_ArrayLib_Tests.bas (458 source lines -> 3356 instructions), the split of a 4.70 ms Compile() is: lexer+parser ~22-27%, TCompiler passes ~50%, exec.LoadSource re-lex 25.1%. So the summary's "parser -> text, exec re-lexes" understates it: the text is lexed three times over (once by AssignTokens, repeatedly by the passes, once by LoadSource), and the parser itself is the cheapest third of the front end.

18. [pipeline] The intermediate program is NOT purely textual. `TStringToken` (exec.pas:216) pairs each line's Str with a `Token: TAsmToken`, and TCompiler maintains it. exec.LoadSource ignores that token and re-lexes anyway (exec.pas:3033-3035). It has to: `TCompiler.EnumVarsFuncs` corrupts it at parser.pas:5009 and 5014, which write `TAsmToken(GetEnumValue(TypeInfo(TAsmToken), sInstr))` with sInstr = 'PUSH' / 'POPSTORE$' / 'FORCYCLE' while the enum members are named atkPush, atkPopStoreS... I compiled a probe with dcc64 37.0: GetEnumValue(TypeInfo(...),'PUSH') = -1, GetEnumValue(...,'atkPush') = 1. So every variable-touching instruction leaves EnumVarsFuncs with an out-of-range Token. It is harmless today only because no later pass reads those tokens (grep: atkPush/atkPopStore/atkForCycle/atkRead appear only at parser.pas:4842 and 4984-4985, both inside EnumVarsFuncs itself) and because exec throws the field away.

19. [pipeline] "exec.pas:3037 asmProg[i].proc := TokenToFunc(atk); // resolved at LOAD time" is right for the opcode but not for the callee. Native (far) calls are resolved on EVERY execution: fCallFar/fCallFarP/fCallFarS rebuild the signature String out of the constant pool with StrPas and then hash it twice - ContainsKey then the indexer (exec.pas:1225/1226/1234, 1290/1291/1299, 1355/1356/1364). Near (user-defined) calls ARE resolved at compile time (parser.pas:4211 -> `CALL <index>`, consumed by fCallNear at exec.pas:1419), as are globals, locals and labels.

20. [pipeline] TokenToFunc is 77 arms, and 7 tokens (atkComment, atkNop, atkPause, atkInteger, atkEndIf, atkRepeat, atkEndFunction) map to fNop at exec.pas:3208. The loaded program therefore keeps instructions that exist only to be skipped - ENDIF, ENDFUNCTION, REPEAT, GOTO labels, comments - each still costing a full indirect dispatch every time control passes over it.

21. [pipeline] There is no caching of anything. `TBasicEngine.LoadIntermediate` (basic.pas:615) exists and is called by nothing in the tree (grep over *.pas/*.dpr: only its own declaration and definition), and it would re-run all 15 compiler passes anyway. `UnitMain.CmdRun` calls `InitBASICEngine()` - which FreeAndNils the engine and re-registers the libraries, 2944 `Lib.Add` calls across engine/Libs + Libs - and then `FBasic.Compile(SourceCode)` (UnitMain.pas:2233-2320, 2973) on every single RUN, source unchanged or not. Measured cost per RUN for that 458-line applet: 0.46 ms engine construction + registration, 4.70 ms compile.

22. [syntax] The architecture summary is right on every line number I checked. exec.pas:111 TAsmData with n/p/s, exec.pas:136 TExeFunc = procedure of object, exec.pas:200 TInstr with proc/token/i/n, exec.pas:1068 ExecuteProgram, exec.pas:3037 asmProg[i].proc := TokenToFunc(atk) at load time, exec.pas:3144 TokenToFunc as a case over the handlers. Line counts match too: lexer 775, parser 5118, exec 3234, basic 809. The parser really does emit textual assembly — TBasicParser.Emmit at parser.pas:1309 appends a String to TMPOutput, and TCompiler re-parses those strings with a TAsmLexer.

23. [syntax] There is not one hot loop, there are two, and the summary only describes the first. exec.pas:1020-1038, inside TExec.ExecuteFunction (declared at exec.pas:958, commented 'Executes a user defined function (called directly only for callbacks)'), is a second per-instruction dispatch loop. Every GUI event handler and every INPUT callback runs its body there rather than in ExecuteProgram — which in the Demos means every frame of every game, since they are all driven by timer_ontimer#. This matters for the performance lens: that loop has no per-instruction try/except (so point 2 of the four leads applies to ExecuteProgram only), but it pays two extra asmProg[PRG_IP].token comparisons per instruction (atkCallNear, atkRetFunction at exec.pas:1021-1022), and when FTimeOut > 0 — the default is 30, exec.pas:43 — it calls Timer.Stop(), reads ElapsedMilliseconds and calls Timer.Start() on every single instruction (exec.pas:1028-1037), where ExecuteProgram amortises the same check over 10,000 instructions via TIMEOUT_CHECK_INTERVAL. That is two QueryPerformanceCounter calls per instruction in the loop that runs the game code.

24. [syntax] The dialect rules given are correct, with one qualification that matters to any 'for each' or indexing sugar: 1-based is true of dim#/sdim#/pdim# arrays, but string line indexing s$[n] and string character indexing s$[[n]] are both 0-based (Website/docs/language-reference.html, 'Array Indexing Rules', and confirmed by the emitted line$@$n / chr$@$n calls at parser.pas:1985 and 1971). 'on' is indeed reserved (lexer.pas:157) and sqr is the square root (engine/Libs/NumLib.pas:254, 'sqr@n').

25. [syntax] One thing the summary implies that the code does not: 'ELSE IF' chains already exist and work (ParseElse at parser.pas:2386 handles ELSE followed by IF, and TCompiler.AssignIf resolves it at parser.pas:4361-4400). What is missing is only the one-word ELSEIF spelling. Similarly, array and object literals already exist for JSON pointers — '[1,2,3]' and '{"a":1}' compile (parser.pas:574 ParseJsonArray, 661 ParseJsonObject) — so that syntax is taken. Note that they build json_array#/json_object# structures, not dim# arrays: 'a# = [1,2,3]' compiles and then fails at run time on 'a#[1]' with 'narr_get: Invalid array object'. Any array-literal proposal has to use a different form.

26. [syntax] A constraint worth stating before anyone proposes a two-pass front end: globals are registered by a whole-program scan of POPSTORE outside functions (TCompiler.EnumVarsFuncs, parser.pas:4836-4872), so declaration *order* does not matter, but a function that writes a global the main body never wrote is a compile error ('Unknown variable', parser.pas:5002). That single rule is what produces the 604 'let x# = pointer#(0)' lines in the Demos, and it also means the parser cannot see function signatures ahead of their call sites — so anything needing look-ahead across the whole file (default parameters, for one) has to be resolved in TCompiler, not in TBasicParser.

27. [syntax] On method: every construction proposed above was run through tests/bin/Plan9BasicTest.exe --smoke and confirmed to be a compile error against the engine as it stands today, and the line counts come from a census over the 109 .bas files in Demos/ and Examples/ (41,274 lines). Two things I expected to propose I dropped because the corpus says they are not earned: default parameters (exactly 1 overload pair in the corpus is default-shaped) and CASE lo TO hi (2 range tests written longhand). Line continuation I dropped for a different reason — '_' is a legal identifier (lexer.pas:36 identChars), so making a trailing '_' a continuation would change the meaning of any program with a variable named '_'.

28. [calls] engine/exec.pas:522 is `function TExec.CallNative`, not 517. Everything else in the architecture summary checks out at the line given: TAsmData:111, TFunctionsDictionary:133, TExeFunc:136, TInstr:200, ExecuteProgram:1068, `asmProg[i].proc := TokenToFunc(atk)`:3037, TokenToFunc:3144.

29. [calls] "The engine looks functions up by an exact string signature" is true only for FAR (native library) calls. NEAR calls -- user-defined BASIC functions -- are resolved at COMPILE time: parser.pas:4203-4222 (`TCompiler.AssignFuncs`) rewrites `CALLEX "name@sig"` into `CALL <integer entry>` when the signature names a near function, and exec.pas:1412 `fCallNear` is three lines with no dictionary in sight. Only atkCallFar/atkCallFarS/atkCallFarP survive to runtime carrying a string, and that is the whole of the problem.

30. [calls] "Roughly 3,899 GUI functions are registered" is close but low. Counting distinct signature literals passed to `Lib.Add`/`Funcs.Add`: 3,874 in Libs/GUI and 534 in engine/Libs, so a full FMX host registers 4,408 distinct signatures. (4,438 string literals reach `.Add` in those trees; 30 of them are TStrings messages, not signatures.)

31. [calls] Lead #2 -- the try/except inside the per-instruction loop -- is free on Win64, not merely cheap. I compiled the same loop shape both ways with dcc64 37.0 and measured 4 ms per 2,000,000 iterations either way (2.0 ns/instruction, identical). Delphi Win64 uses table-driven SEH, so entering a try block emits no instructions. Whatever is worth attacking in ExecuteProgram, exec.pas:1120-1136 is not it. (I did not measure Linux64 or Android/ARM64.)

32. [calls] parser.pas:4211 and exec.pas:1917/2047/2139/2395 look like an address-of bug -- `NativeInt(@ProgramFunctions[s].Entry)` taking the address of a temporary returned by a dictionary getter. It is not. I compiled a probe (a TDictionary<String,TLinkFunction> holding `Entry := TBindFunction(42)`): `NativeInt(@d[s].Entry)` prints 42, the stored value. Delphi's `@` on a procedural-typed expression suppresses the implicit call and yields the pointer value; the bare form `NativeInt(d[s].Entry)` is what fails to compile (E2035 Not enough actual parameters). The near-call entry encoding is sound.

33. [calls] TBasicParser.LibFunctionsTable (parser.pas:184, created 1272) is never written to -- there is no `LibFunctionsTable.Add` anywhere in parser.pas. So basic.pas:223-225, 253-255 and 643-645 clear an empty dictionary and copy an empty dictionary into it on every compile, and the property that read the result is commented out at basic.pas:180. Two live TDictionary objects that have never held an entry.
