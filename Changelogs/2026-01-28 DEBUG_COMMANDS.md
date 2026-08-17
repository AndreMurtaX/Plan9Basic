# Plan9Basic Debugging Commands

## Overview

Plan9Basic now includes built-in debugging support through three new commands: `TRACEON`, `TRACEOFF`, and `BREAKPOINT`. These commands provide a simple but effective way to debug applets without requiring a complex visual debugger.

## Commands

### TRACEON

Enables trace mode. When trace mode is active:
- Each source line executed outputs a trace message to the output console
- The `BREAKPOINT` command becomes active

**Syntax:**
```basic
TRACEON
```

**Output:**
```
[TRACE] Trace mode enabled
[TRACE] Line 5 | IP=23
[TRACE] Line 6 | IP=27
...
```

### TRACEOFF

Disables trace mode. The `BREAKPOINT` command will be ignored when trace mode is off.

**Syntax:**
```basic
TRACEOFF
```

**Output:**
```
[TRACE] Trace mode disabled
```

### BREAKPOINT

When trace mode is active, pauses execution and shows a dialog with:
- The current line number
- An optional message
- Optional variable values

The dialog offers two buttons:
- **OK**: Continue execution
- **Abort**: Stop execution immediately

**Important:** `BREAKPOINT` only executes when trace mode is enabled (after `TRACEON`). When trace mode is off, `BREAKPOINT` commands are silently ignored, allowing you to leave them in your code for production.

**Syntax:**
```basic
BREAKPOINT                                    ' Simple breakpoint
BREAKPOINT "checkpoint reached"               ' With message
BREAKPOINT "loop iteration", i, sum, name$    ' With message and variables
```

**Variable Types Supported:**
- Numeric variables: `x`, `counter`, `total`
- String variables: `name$`, `message$`
- Pointer variables: `obj#`, `form#`

## Timer Handling

When a `BREAKPOINT` is hit:
1. All active timers are automatically paused
2. The breakpoint dialog is displayed
3. On **Continue**: All timers that were running are resumed
4. On **Abort**: Execution stops, timers remain disabled

This ensures that timer events don't interfere with debugging.

## Usage Examples

### Example 1: Simple Trace

```basic
traceon

for i = 1 to 5
    println "i = "; i
next

traceoff
end
```

**Output:**
```
[TRACE] Trace mode enabled
[TRACE] Line 3 | IP=5
i = 1
[TRACE] Line 4 | IP=12
[TRACE] Line 3 | IP=5
i = 2
...
[TRACE] Trace mode disabled
```

### Example 2: Breakpoint with Variables

```basic
let x = 10
let name$ = "Test"
let counter = 0

traceon

for i = 1 to 3
    counter = counter + x
    breakpoint "Inside loop", i, counter, name$
next

traceoff
println "Final counter: "; counter
end
```

When the breakpoint is hit, a dialog will show:
```
BREAKPOINT at Line 9

Message: Inside loop

Variables:
  i = 1
  counter = 10
  name$ = "Test"
```

### Example 3: Conditional Debugging

```basic
let debugMode = 1

if debugMode = 1 then traceon

' Your code here
for i = 1 to 100
    ' Complex calculation
    result = calculate(i)
    
    ' Only break on specific condition
    if result < 0 then
        breakpoint "Negative result found!", i, result
    endif
next

if debugMode = 1 then traceoff
end
```

### Example 4: Debugging with Timers

```basic
let tmr# = timer#()
timer_interval#(tmr#, 1000)
timer_ontimer#(tmr#, "OnTick")
timer_enabled#(tmr#, 1)

let tickCount = 0

traceon

' Main loop - breakpoint will pause the timer
for i = 1 to 5
    breakpoint "Main loop iteration", i, tickCount
    pause(1)
next

traceoff
timer_free#(tmr#)
end

function OnTick(sender#)
    tickCount = tickCount + 1
    println "Tick: "; tickCount
endfunction
```

## Best Practices

1. **Leave breakpoints in code**: Since `BREAKPOINT` only executes when trace mode is on, you can leave breakpoints in your code and only enable them when debugging by adding `TRACEON` at the start.

2. **Use meaningful messages**: The message parameter helps identify which breakpoint was hit when you have multiple breakpoints.

3. **Watch critical variables**: Use the variable list to monitor values that are important for understanding your program's state.

4. **Structured debugging**: Use `TRACEON`/`TRACEOFF` to limit tracing to specific sections of code to avoid overwhelming output.

5. **Timer-aware debugging**: Remember that all timers pause during breakpoints, so timer-dependent code will behave differently during debugging.

## Implementation Notes

- Trace output goes to the standard output console (same as `PRINTLN`)
- The trace format is: `[TRACE] Line N | IP=M` where N is the source line and M is the instruction pointer
- Breakpoint dialogs are asynchronous but execution is paused until the user responds
- Variable values are captured at the moment the breakpoint is hit

## Limitations

- Only global variables can be watched in `BREAKPOINT` (local function variables are not accessible)
- Step-by-step execution is not currently supported (planned for future)
- No conditional breakpoints (use IF statements to achieve this)
