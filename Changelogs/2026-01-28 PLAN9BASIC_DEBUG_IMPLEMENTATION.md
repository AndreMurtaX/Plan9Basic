# Plan9Basic Debug Commands - Implementation Guide

This document contains all the code changes needed to implement the debugging commands (`TRACEON`, `TRACEOFF`, `BREAKPOINT`) in Plan9Basic.

---

## 1. lexer.pas

### 1.1 Add new tokens to TBasToken enum

Find the `TBasToken` enum and add the new tokens:

```pascal
TBasToken = (
  {A}
  btkAnd, btkAmpersand, btkAt,
  {B}
  btkBreak, btkBreakpoint,   // <-- ADD btkBreakpoint
  {C}
  btkCall, btkCase, btkCharArray, btkCRLF,
  // ... rest of tokens ...
  {T}
  btkThen, btkTo, btkTraceOff, btkTraceOn, btkTrue,   // <-- ADD btkTraceOff, btkTraceOn
  {U}
  btkUnknown, btkUntil,
  {V}
  {W}
  btkWhile
  {X}
  {Y}
  {Z}
);
```

### 1.2 Add hash code recognition in BasIdentKind function

Find the `BasIdentKind` function and add these cases to the `case HashCode of` statement:

```pascal
function TBasicLexer.BasIdentKind(tokStr: String): TBasToken;
var
  HashCode: Integer;
begin
  Result := btkIdentifier;
  tokStr := UpperCase(tokStr);
  HashCode := TUtils.StringCode(tokStr);

  if (HashCode < 143) or (HashCode > 829) then
    Exit();

  case HashCode of
    // ... existing cases ...
    
    524: if tokStr = 'TRACEON' then Result := btkTraceOn;       // <-- ADD (between 480 and 548)
    
    586: if tokStr = 'TRACEOFF' then Result := btkTraceOff;     // <-- ADD (between 551 and 592)
    
    751: if tokStr = 'BREAKPOINT' then Result := btkBreakpoint; // <-- ADD (between 663 and 829)
    
    // ... existing cases ...
  end;
end;
```

**Hash codes reference:**
- TRACEON = 524
- TRACEOFF = 586  
- BREAKPOINT = 751

---

## 2. exec.pas

### 2.1 Add FMX.DialogService to uses clause

```pascal
uses
  System.Classes, System.SysUtils, System.Character, System.Generics.Collections,
  System.TypInfo, System.Math, System.Diagnostics, System.UITypes, System.SyncObjs,

  FMX.Types, FMX.Platform, FMX.Controls, FMX.Forms, FMX.Graphics,

  FMX.Dialogs, FMX.DialogService, FMX.DialogService.Async,  // <-- ADD FMX.DialogService

  UnitUtils, lexer, UnitGC;
```

### 2.2 Add new tokens to TAsmToken enum

```pascal
TAsmToken = (
  {A}
  atkAdd, atkAddCRLFS, atkAddS, atkAnd,
  {B}
  atkBreak, atkBreakpoint, atkCRLF, atkCallFar, ...  // <-- ADD atkBreakpoint after atkBreak
  // ... rest of tokens ...
  {T}
  atkTo, atkTraceOff, atkTraceOn,  // <-- ADD atkTraceOff, atkTraceOn after atkTo
  {U}
  atkUnknown, atkUntil,
  // ...
);
```

### 2.3 Add FTraceEnabled field to TExec class (private section)

```pascal
TExec = class
private
  PRG_IP,
  STKP,
  BASEP: Integer;
  AuxStackIdx: Integer;
  FErrorMessage: String;
  srcLine: Integer;
  FPrintProc: TPrintProc;
  strConst: String;
  sourceAlloc, ended: Boolean;
  asmLexer: TAsmLexer;
  asmProg: TInstrArray;
  FTotInsts: Integer;
  FCallbackProc: TNotifyEvent;
  FCallbackObj: TObject;
  FTimeOut: Int64;
  ExecStatus: TExecStatus;
  FTraceEnabled: Boolean;  // <-- ADD THIS LINE
```

### 2.4 Add debug procedure declarations (private section)

Add these declarations after the existing procedure declarations in the private section:

```pascal
    procedure fPushAuxStack();
    procedure fPushAuxStackS();
    procedure fPopAuxStack();
    procedure fPushAuxTOS();
    //Debug instructions
    procedure fBreakpoint(); //breakpoint (only when trace enabled)
    procedure fTraceOn();    //enable trace mode
    procedure fTraceOff();   //disable trace mode
  public
```

### 2.5 Add TraceEnabled property (public section)

Add at the end of the public properties:

```pascal
    property TimeOut: Int64 read FTimeOut write FTimeOut;
    property TraceEnabled: Boolean read FTraceEnabled write FTraceEnabled;  // <-- ADD
  end;
```

### 2.6 Add TimerLib to implementation uses clause

```pascal
implementation

uses
  TimerLib;  //For PauseAllTimers/ResumeAllTimers in breakpoint handling
```

### 2.7 Add hash code recognition in AsmIdentKind function

Add these cases to the `case code of` statement:

```pascal
    524: if tokStr = 'TRACEON' then Result := atkTraceOn;       // <-- ADD (between 499 and 532)
    
    586: if tokStr = 'TRACEOFF' then Result := atkTraceOff;     // <-- ADD (between 581 and 592)
    
    751: if tokStr = 'BREAKPOINT' then Result := atkBreakpoint; // <-- ADD (between 742 and 760)
```

### 2.8 Initialize FTraceEnabled in constructor

```pascal
constructor TExec.Create();
begin
  TagObject := nil;
  sourceAlloc := false;
  FTraceEnabled := false; //Debug trace mode disabled by default  // <-- ADD
  // ... rest of constructor ...
end;
```

### 2.9 Modify fComma procedure to output trace info

Replace the existing `fComma` procedure with:

```pascal
procedure TExec.fComma();
var
  traceMsg: String;
begin
  srcLine := asmProg[PRG_IP].i;
  //Output trace info when trace mode is enabled
  if FTraceEnabled and Assigned(FPrintProc) then
  begin
    traceMsg := '[TRACE] Line ' + IntToStr(srcLine) + ' | IP=' + IntToStr(PRG_IP) + System.sLineBreak;
    FPrintProc(PChar(traceMsg));
  end;
end;
```

### 2.10 Add new debug procedures (implementation)

Add these procedures in the implementation section (after `fEnd` is a good place):

```pascal
//Debug: Enable trace mode
procedure TExec.fTraceOn();
begin
  FTraceEnabled := true;
  if Assigned(FPrintProc) then
    FPrintProc(PChar('[TRACE] Trace mode enabled' + System.sLineBreak));
end;

//Debug: Disable trace mode
procedure TExec.fTraceOff();
begin
  FTraceEnabled := false;
  if Assigned(FPrintProc) then
    FPrintProc(PChar('[TRACE] Trace mode disabled' + System.sLineBreak));
end;

//Debug: Breakpoint (only executes when trace is enabled)
procedure TExec.fBreakpoint();
var
  varCount, i: Integer;
  bkptMsg, varName, varInfo, dialogMsg: String;
  varValue: TAsmData;
  varType: TExprKind;
begin
  //Only execute if trace mode is enabled
  if not FTraceEnabled then
    Exit();

  //Get the variable count from the instruction
  varCount := Round(asmProg[PRG_IP].n);

  //Pop the breakpoint message
  bkptMsg := PopAsmData(ekString).s;

  //Build variable info string
  varInfo := '';
  for i := 0 to varCount - 1 do
  begin
    //Pop variable value first (was pushed last)
    varType := TypeStack[STKP];
    case varType of
      ekNumber:
      begin
        varValue := PopAsmData(ekNumber);
        //Pop variable name
        varName := PopAsmData(ekString).s;
        varInfo := varInfo + '  ' + varName + ' = ' + FloatToStr(varValue.n) + System.sLineBreak;
      end;
      ekString:
      begin
        varValue := PopAsmData(ekString);
        //Pop variable name
        varName := PopAsmData(ekString).s;
        varInfo := varInfo + '  ' + varName + ' = "' + varValue.s + '"' + System.sLineBreak;
      end;
      ekPointer:
      begin
        varValue := PopAsmData(ekPointer);
        //Pop variable name
        varName := PopAsmData(ekString).s;
        if varValue.p = nil then
          varInfo := varInfo + '  ' + varName + ' = nil' + System.sLineBreak
        else
          varInfo := varInfo + '  ' + varName + ' = $' + IntToHex(NativeInt(varValue.p), 8) + System.sLineBreak;
      end;
    end;
  end;

  //Build dialog message
  dialogMsg := 'BREAKPOINT at Line ' + IntToStr(srcLine) + System.sLineBreak;
  if bkptMsg <> '' then
    dialogMsg := dialogMsg + System.sLineBreak + 'Message: ' + bkptMsg + System.sLineBreak;
  if varInfo <> '' then
    dialogMsg := dialogMsg + System.sLineBreak + 'Variables:' + System.sLineBreak + varInfo;
  dialogMsg := dialogMsg + System.sLineBreak + 'Press YES to continue, NO to stop execution.';

  //Pause all timers using TimerLib helper
  TimerLib.PauseAllTimers();

  //Output to trace
  if Assigned(FPrintProc) then
    FPrintProc(PChar('[BREAKPOINT] ' + bkptMsg + ' (Line ' + IntToStr(srcLine) + ')' + System.sLineBreak));

  //Show dialog and wait for user response
  //Using Yes/No buttons for cross-platform clarity
  TDialogService.MessageDialog(
    dialogMsg,
    TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbYes,
    0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrNo then
      begin
        //User chose to stop execution
        ended := true;
        if Assigned(FPrintProc) then
          FPrintProc(PChar('[BREAKPOINT] Execution stopped by user' + System.sLineBreak));
      end
      else
      begin
        //User chose to continue - resume timers
        TimerLib.ResumeAllTimers();
        if Assigned(FPrintProc) then
          FPrintProc(PChar('[BREAKPOINT] Execution resumed' + System.sLineBreak));
      end;
      //Resume execution
      ExecStatus := TExecStatus.esRun;
    end
  );

  //Pause execution until dialog is closed
  ExecStatus := TExecStatus.esIdle;
end;
```

### 2.11 Add token mappings in TokenToFunc function

Add these cases to the `case tk of` statement:

```pascal
    atkInput: Result := fInput;
    atkInputS: Result := fInputS;
    //Debug instructions
    atkBreakpoint: Result := fBreakpoint;
    atkTraceOn: Result := fTraceOn;
    atkTraceOff: Result := fTraceOff;
  else
    RTError(rteUnknownInstr, tk);
  end;
```

---

## 3. parser.pas

### 3.1 Add debug procedure declarations (private section)

Add after the existing procedure declarations:

```pascal
    procedure ParseGosub(); //GOSUB
    procedure ParseOn(); //ON
    //Debug commands
    procedure ParseBreakpoint(); //BREAKPOINT
    procedure ParseTraceOn(); //TRACEON
    procedure ParseTraceOff(); //TRACEOFF
    procedure NextCommand();
```

### 3.2 Add token handling in NextCommand procedure

Add these cases to the `case lexer.currTok() of` statement:

```pascal
    btkGosub: ParseGosub();
    btkOn: ParseOn();
    //Debug commands
    btkBreakpoint: ParseBreakpoint();
    btkTraceOn: ParseTraceOn();
    btkTraceOff: ParseTraceOff();
    btkCRLF: ;
```

### 3.3 Add debug command parsing procedures (implementation)

Add these procedures in the implementation section:

```pascal
//-----------------------------------------------------------------------------
// TRACEON - Enable trace mode
//-----------------------------------------------------------------------------
procedure TBasicParser.ParseTraceOn();
begin
  Emmit('TRACEON');
  lexer.Advance();
end;

//-----------------------------------------------------------------------------
// TRACEOFF - Disable trace mode
//-----------------------------------------------------------------------------
procedure TBasicParser.ParseTraceOff();
begin
  Emmit('TRACEOFF');
  lexer.Advance();
end;

//-----------------------------------------------------------------------------
// BREAKPOINT ["message"] [, var1, var2$, var3#, ...]
// Only executes when trace mode is enabled
// Shows dialog with message and variable values
//-----------------------------------------------------------------------------
procedure TBasicParser.ParseBreakpoint();
var
  varCount: Integer;
  varName, varIndex: String;
begin
  varCount := 0;
  lexer.Advance(); //skip BREAKPOINT keyword

  //Check for optional message string
  if lexer.CurrTok() = btkString then
  begin
    //Push the message string
    Emmit('PUSHC$ "' + lexer.CurrS() + '"');
    lexer.Advance();
  end
  else
  begin
    //No message - push empty string
    Emmit('PUSHC$ ""');
  end;

  //Check for comma (variables follow)
  while lexer.CurrTok() = btkComma do
  begin
    lexer.Advance(); //skip comma

    //Expect a variable identifier
    case lexer.CurrTok() of
      btkIdentifier:
      begin
        //Numeric variable
        varName := lexer.CurrS();
        varIndex := FGlobalVars.IndexOf(varName).ToString;
        if FGlobalVars.IndexOf(varName) < 0 then
        begin
          //Variable not found - add it (will be 0/undefined)
          FGlobalVars.Add(varName);
          varIndex := FGlobalVars.IndexOf(varName).ToString;
        end;
        //Push variable name as string
        Emmit('PUSHC$ "' + varName + '"');
        //Push variable value
        Emmit('PUSH @' + varIndex);
        Inc(varCount);
        lexer.Advance();
      end;
      btkStrIdentifier:
      begin
        //String variable
        varName := lexer.CurrS();
        varIndex := FGlobalVars.IndexOf(varName).ToString;
        if FGlobalVars.IndexOf(varName) < 0 then
        begin
          FGlobalVars.Add(varName);
          varIndex := FGlobalVars.IndexOf(varName).ToString;
        end;
        Emmit('PUSHC$ "' + varName + '"');
        Emmit('PUSH$ @' + varIndex);
        Inc(varCount);
        lexer.Advance();
      end;
      btkPointerIdentifier:
      begin
        //Pointer variable
        varName := lexer.CurrS();
        varIndex := FGlobalVars.IndexOf(varName).ToString;
        if FGlobalVars.IndexOf(varName) < 0 then
        begin
          FGlobalVars.Add(varName);
          varIndex := FGlobalVars.IndexOf(varName).ToString;
        end;
        Emmit('PUSHC$ "' + varName + '"');
        Emmit('PUSH# @' + varIndex);
        Inc(varCount);
        lexer.Advance();
      end;
      else
      begin
        status := BasTerminated;
        SetError('Variable identifier expected in BREAKPOINT');
        Exit();
      end;
    end;
  end;

  //Emit BREAKPOINT instruction with variable count
  Emmit('BREAKPOINT ' + IntToStr(varCount));
end;
```

---

## 4. TimerLib.pas

### 4.1 Add procedure declarations (interface section)

Add after `CleanupAllTimers` declaration:

```pascal
procedure RegisterTimerFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

// Call this before application shutdown to clean up all timers
// This is called automatically during unit finalization
procedure CleanupAllTimers();

// Debug support: Pause and resume all active timers (for breakpoints)
procedure PauseAllTimers();
procedure ResumeAllTimers();

implementation
```

### 4.2 Add PausedTimerStates variable (implementation var section)

```pascal
var
  lastError: Integer;
  lastErrorMsg: String;
  ModuleEngine: TBasicEngine;
  ModuleOutput: TStrings;

  // ActiveTimers is the SOLE owner of all timer instances
  // No GC involvement - this list manages the complete lifecycle
  ActiveTimers: TList<TBasTimer>;
  
  // Tracks which timers were enabled before PauseAllTimers was called
  // Used to restore only those timers that were actually running
  PausedTimerStates: TDictionary<TBasTimer, Boolean>;
```

### 4.3 Add PauseAllTimers and ResumeAllTimers procedures (implementation)

Add these procedures before the initialization section:

```pascal
// -----------------------------------------------------------------------------
// Debug Support - Pause/Resume all timers for breakpoints
// -----------------------------------------------------------------------------

procedure PauseAllTimers();
var
  Tmr: TBasTimer;
begin
  if not Assigned(ActiveTimers) then
    Exit;
  if not Assigned(PausedTimerStates) then
    Exit;
    
  // Clear any previous state
  PausedTimerStates.Clear();
  
  // Save state and disable all active timers
  for Tmr in ActiveTimers do
  begin
    try
      // Save whether this timer was enabled
      PausedTimerStates.Add(Tmr, Tmr.Enabled);
      // Disable the timer
      if Tmr.Enabled then
        Tmr.Enabled := False;
    except
      // Ignore errors
    end;
  end;
end;

procedure ResumeAllTimers();
var
  Tmr: TBasTimer;
  WasEnabled: Boolean;
begin
  if not Assigned(ActiveTimers) then
    Exit;
  if not Assigned(PausedTimerStates) then
    Exit;
    
  // Restore state for all timers
  for Tmr in ActiveTimers do
  begin
    try
      // Only re-enable timers that were enabled before pause
      if PausedTimerStates.TryGetValue(Tmr, WasEnabled) then
      begin
        if WasEnabled then
          Tmr.Enabled := True;
      end;
    except
      // Ignore errors
    end;
  end;
  
  // Clear the saved state
  PausedTimerStates.Clear();
end;
```

### 4.4 Update initialization and finalization sections

```pascal
initialization
  ActiveTimers := TList<TBasTimer>.Create();
  PausedTimerStates := TDictionary<TBasTimer, Boolean>.Create();

finalization
  // Clean up all timers before the platform services shut down
  CleanupAllTimers();
  FreeAndNil(PausedTimerStates);
  FreeAndNil(ActiveTimers);

end.
```

---

## 5. UnitMain.pas

### 5.1 Update STokens array

Update the `STokens` constant array to include the new tokens in the correct order:

```pascal
const
  STokens: array[TBasToken] of String = (
    'btkAnd', 'btkAmpersand', 'btkAt',
    'btkBreak', 'btkBreakpoint',  // <-- ADD btkBreakpoint
    'btkCall', 'btkCase', 'btkCharArray', 'btkCRLF',
    'btkCls', 'btkColon', 'btkComma', 'btkContinue', 'btkCurlyClose', 'btkCurlyOpen',
    'btkData', 'btkDo', 'btkDoubleSquareClose', 'btkDoubleSquareOpen',
    'btkElse', 'btkEnd', 'btkEndFor', 'btkEndFunction', 'btkEndIf', 'btkEndSelect',
    'btkEndWhile', 'btkEqual',
    'btkFalse', 'btkFloat', 'btkFor', 'btkFunction',
    'btkGoto', 'btkGreater', 'btkGreaterEqual', 'btkGosub',
    'btkIdentifier', 'btkIf', 'btkIndirectCallPtr', 'btkIndirectCallStr', 'btkInput',
    'btkInteger',
    'btkJsonNULL',
    'btkLabel', 'btkLet', 'btkLocal', 'btkLoop', 'btkLower', 'btkLowerEqual',
    'btkMax', 'btkMin', 'btkMinus', 'btkMod',
    'btkNext', 'btkNone', 'btkNot', 'btkNotEqual', 'btkNull', 'btkNumFunction',
    'btkOn', 'btkOr',
    'btkPipe', 'btkPlus', 'btkPointerArray', 'btkPointerArrayStr', 'btkPointerArrayPtr', 'btkPointerFunction', 'btkPointerIdentifier', 'btkPower',
    'btkPrint','btkPrintLn',
    'btkRem', 'btkRead', 'btkRepeat', 'btkReturn', 'btkRoundClose', 'btkRoundOpen',
    'btkRestore',
    'btkSelect', 'btkSemiColon', 'btkSlash', 'btkSquareClose', 'btkSquareOpen', 'btkStar',
    'btkStep', 'btkStrArray', 'btkStrFunction', 'btkStrIdentifier',
    'btkString', 'btkSymbol',
    'btkThen', 'btkTo', 'btkTraceOff', 'btkTraceOn', 'btkTrue',  // <-- ADD btkTraceOff, btkTraceOn
    'btkUnknown', 'btkUntil',
    'btkWhile'
  );
```

---

## Testing

After implementing all changes, test with this sample program:

```basic
let x = 10
let name$ = "Hello"
let counter = 0

traceon

for i = 1 to 3
    counter = counter + x
    breakpoint "Loop iteration", i, counter, name$
next

traceoff
println "Done! Counter = "; counter
end
```

Expected behavior:
1. `[TRACE] Trace mode enabled` appears
2. Trace lines appear for each source line executed
3. A dialog appears at each breakpoint showing variables
4. Pressing **Yes** continues, **No** stops execution
5. `[TRACE] Trace mode disabled` appears after the loop

---

## Summary of Files Changed

| File | Changes |
|------|---------|
| lexer.pas | 3 new tokens + 3 hash recognitions |
| exec.pas | 3 new ASM tokens + 1 field + 3 procedures + trace in fComma + TokenToFunc mappings |
| parser.pas | 3 new parse procedures + NextCommand handling |
| TimerLib.pas | 2 new procedures + 1 dictionary + init/finalize updates |
| UnitMain.pas | STokens array update |
