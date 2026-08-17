# Plan9Basic Thread Safety Guide

## Overview

Plan9Basic is designed primarily for **single-threaded execution**. The virtual machine (TExec) and related components are not thread-safe by default. This document outlines the threading model and provides guidance for multi-threaded scenarios.

## Threading Model

### Single-Threaded Components

The following components should only be accessed from a single thread:

| Component | Class | Reason |
|-----------|-------|--------|
| Lexer | `TBasicLexer` | Stateful parsing with shared index |
| Parser | `TBasicParser` | Stateful compilation with counters |
| VM | `TExec` | Stack manipulation, instruction pointer |
| Compiler | `TCompiler` | Stateful code generation |

### Shared State

The VM maintains the following shared state that is **not thread-safe**:

```pascal
// Stack memory
HeapMem: array [0..MAXVARS] of TAsmData;    // Global variables
StackMem: array [0..MAXSTACK] of TAsmData;  // Local variables stack
TypeStack: array [0..MAXSTACK] of TExprKind; // Type tracking

// Execution state
PRG_IP: Integer;     // Instruction pointer
STKP: Integer;       // Stack pointer
BASEP: Integer;      // Base pointer for functions
AuxStackIdx: Integer; // Auxiliary stack for SELECT/CASE

// Program state
ended: Boolean;      // Termination flag
ExecStatus: TExecStatus; // Running/Idle status
```

## Safe Practices

### 1. One VM Instance Per Thread

If you need concurrent execution, create separate `TExec` instances:

```pascal
// Thread 1
var
  VM1: TExec;
begin
  VM1 := TExec.Create();
  try
    VM1.LoadSource(Program1);
    VM1.ExecuteProgram();
  finally
    VM1.Free();
  end;
end;

// Thread 2
var
  VM2: TExec;
begin
  VM2 := TExec.Create();
  try
    VM2.LoadSource(Program2);
    VM2.ExecuteProgram();
  finally
    VM2.Free();
  end;
end;
```

### 2. Callback Functions

When using callback functions (`CallbackProc`), ensure they are thread-safe:

```pascal
// Safe: Use TThread.Synchronize for UI updates
procedure TMyForm.OnVMCallback(Sender: TObject);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      // Update UI here
    end
  );
end;
```

### 3. Function Bindings (Far Calls)

Custom functions bound via `TBindFunction` may be called from the VM. Ensure they are thread-safe if the VM might run in a background thread:

```pascal
// Thread-safe bound function example
function MyThreadSafeFunc(var Args: Array of TAsmData): TAsmData;
var
  Lock: TCriticalSection;
begin
  Lock := GetGlobalLock();
  Lock.Enter;
  try
    // Protected code here
    Result.n := SomeSharedResource.Value;
  finally
    Lock.Leave;
  end;
end;
```

### 4. INPUT Command (Async)

The `INPUT` command uses `TDialogServiceAsync.InputQuery` which is inherently thread-safe for UI interaction. However, the callback modifies VM state, so:

- The VM should be in a known state when INPUT completes
- Avoid calling INPUT while other threads access the same VM instance

## Platform-Specific Considerations

### Windows
- UI operations must occur on the main thread
- `Application.ProcessMessages` is called during execution

### Android/iOS
- All UI operations are inherently async
- The callback-based INPUT design is required
- Never block the main thread

### macOS
- Similar to iOS, use async patterns
- Cocoa requires main thread for UI

## Future Improvements

Potential thread safety enhancements for future versions:

1. **VM State Locking**: Add optional critical section protection
2. **Thread-Local Storage**: Per-thread variable spaces
3. **Atomic Operations**: For simple state flags
4. **Concurrent Execution Model**: Multiple VMs with shared data

## Summary

| Scenario | Safe? | Recommendation |
|----------|-------|----------------|
| Single VM, main thread | ✅ | Default usage |
| Single VM, background thread | ⚠️ | Be careful with callbacks |
| Multiple VMs, separate threads | ✅ | Each thread has own instance |
| Single VM, multiple threads | ❌ | Not supported |
| Shared data between VMs | ⚠️ | Use external synchronization |

---

*Document Version: 1.0*  
*Last Updated: Phase 4 Improvements*
