{******************************************************************************
  Plan9Basic Interpreter Engine

  MIT License
  Copyright (c) 2026 André Murta

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
******************************************************************************}
unit basic;

interface

uses
  System.Classes, System.SysUtils, System.Character, System.Math,
  System.SyncObjs, System.Generics.Collections,
  lexer, parser, exec, UnitUtils;

type
  // Event fired after each PRINT output, allowing UI to refresh
  TPrintOutputEvent = procedure(Sender: TObject; const Text: String; IsClear: Boolean) of object;

  //****************************************************************************
  // Classes definitions
  // Begin
  //****************************************************************************
  //
  //************
  //TBasicEngine
  //************
  //
  //Interface between the language engine and the host application
  //
  //One call the UI thread wants made, waiting for the thread that owns the VM.
  //
  //The VM is a single-threaded stack machine: two callers cannot be inside it
  //at once, whatever thread they arrive from. So a control click or a timer
  //tick that fires on the UI thread while the VM runs elsewhere cannot execute
  //there -- it has to be handed over and waited for.
  TVMCall = class
  public
    Signature: String;
    Args: TArray<TAsmData>;
    RetType: TExprKind;
    RetValue: TAsmData;
    Failed: Boolean;
    ErrorText: String;
    Finished: TEvent;
    constructor Create();
    destructor Destroy(); override;
  end;

  TBasicEngine = class
  private
    output: TStrings;
    INTSource, ASMSource: TStringTokens;
    errPos, errLine: Integer;
    errMessage, FRTExceptionMsg: String;
    FRTException: Boolean;
    FFunctions: TFunctionsDictionary; //Dictionary with registered functions
    FOnPrintOutput: TPrintOutputEvent;
    FInputProc: TInputProc;
    FConfirmProc: TConfirmProc;
    FYieldProc: TYieldProc;
    //Store data for all UDFs in the "compiled" source code.
    //Could be accessed after source code compilation to call for a specific
    //function in the host application
    UserFunctionsTable: TUserFunctionsDictionary;
    //Table with signatures and entry points for all functions available in the
    //BASIC program.
    //Can be used after source code compilation to get the signatures and entry
    //points for all these available functions.
    LibFunctionsTable: TFunctionsDictionary;

    //--------------------------------------------------------------------------
    // The variables below are used solely by the functions to support the
    // compiler engine object.
    //--------------------------------------------------------------------------
    //ArgStack: Array of TAsmData; //Function call parameters
    //LastCallResult: TAsmData; //Keep result of last function call
    //LastCallType: TExprKind; //Keep return type of last function call
    //--------------------------------------------------------------------------

    FScriptTimeOut: Int64; //Maximum script execution time

    //Zero until a host declares that the VM has a thread of its own. While it
    //is zero every call runs where it is made, which is what happened before
    //any of this existed and is still what a single-threaded host wants.
    FVMThread: TThreadID;
    FPending: TObjectList<TVMCall>;
    FPendingLock: TCriticalSection;

    //With the VM on a thread of its own, PRINT cannot write to the TStrings the
    //host handed over: that is a TMemo's Lines, and appending to it from a
    //worker is a data race on every line of output. The text waits here until
    //the host moves it across, on the host's own thread.
    FPendingText: String;
    FPendingClear: Boolean;
    FOutputLock: TCriticalSection;
    //The append rule, shared by both paths so they cannot drift: the first
    //piece continues the last line, the rest start new ones.
    procedure AppendToOutput(ATarget: TStrings; const AText: String);
    procedure RunOneQueuedCall(const ACall: TVMCall);
    function QueueAndWait(const ASignature: String;
                          const AParameters: array of TAsmData;
                          out RetType: TExprKind;
                          out RetValue: TAsmData): Boolean;

    procedure PrintProc(p: PChar); //PRINT management function
    procedure SetScriptTimeOut(const Value: Int64);
  public
    Parser: TBasicParser; //parser object
    //An event that could be triggered between the execution of each instruction
    //in the stack machine.
    //It's useful for debugging.
    OnProgress: TNotifyEvent;
    This: TObject;
    constructor Create();
    destructor Destroy(); override;

    //--- Running the VM on a thread of its own ---------------------------
    //
    //Called from inside the thread that is about to run ExecuteProgram, and
    //again when it finishes. Between the two, ExecuteUserFunction called from
    //any other thread queues instead of executing, and DrainQueuedCalls runs
    //what was queued. A host that never calls these behaves exactly as before.
    procedure ClaimVMThread();
    procedure ReleaseVMThread();
    //Runs everything the UI thread has queued, on the caller's thread. Belongs
    //in YieldProc, which the VM already calls at its pause and refresh points.
    procedure DrainQueuedCalls();
    //Moves whatever PRINT has produced into ATarget, applying the same append
    //rule the unthreaded path applies directly. Called by the host, on the
    //host's thread, which is the whole point. Answers how many lines moved.
    function DrainOutput(ATarget: TStrings): Integer;
    //True while a thread has been claimed and this is not it.
    function CallsMustBeQueued(): Boolean;

    function Compile(source: TStrings): Integer; overload;
    function Compile(source: PChar): Integer; overload;
    function LoadIntermediate(source: TStrList): Integer;
    function TotalTokens: Cardinal; //Total of tokens in BASIC source
    function UserFunctionExists(Signature: String): Boolean;
    procedure ExecuteUserFunction( //exec. an user defined function only
      stdout: TStrings; //output (PRINT command)
      FunctionSignature: String;
      Parameters: Array of TAsmData;
      out RetType: TExprKind;
      out RetValue: TAsmData
    );
    procedure ExecuteProgram(stdout: TStrings); //exec. entire program
    procedure Stop(); //Stop execution
    function GetGlobalNum(const name: String; out index: Integer): Extended;
    function GetGlobalPtr(const name: String; out index: Integer): Pointer;
    function GetGlobalStr(const name: String; out index: Integer): String;

    property INTCode: TStringTokens read INTSource;
    property ASMCode: TStringTokens read ASMSource;
    property ErrorPos: Integer read errPos;
    property ErrorLine: Integer read errLine;
    property ErrorMessage: String read errMessage;
    //Used to keep the registered functions
    property Functions: TFunctionsDictionary read FFunctions write FFunctions;
    property UserFunctions: TUserFunctionsDictionary read UserFunctionsTable;
    //property LibFunctions: TFunctionsDictionary read LibFunctionsTable;
    //Indicates if a runtime exception ocurred during the script execution of a
    //self contained engine.
    property RuntimeException: Boolean read FRTException;
    //Keep last runtime exception message if such exception ocurred during a
    //self contained engine script execution. This text could be useful when
    //runing Basic from Basic
    property RuntimeExceptionMsg: String read FRTExceptionMsg write FRTExceptionMsg;
    //Script execution time limit (in seconds)
    property ScriptTimeOut: Int64 read FScriptTimeOut write SetScriptTimeOut;
    // PRINT instruction callback
    property OnPrintOutput: TPrintOutputEvent read FOnPrintOutput write FOnPrintOutput;
    //How the host talks to a person. Leave nil in a host with no one to ask:
    //INPUT then keeps its default value and BREAKPOINT simply continues.
    //YieldProc is where a host with a message loop pumps it.
    property InputProc: TInputProc read FInputProc write FInputProc;
    property ConfirmProc: TConfirmProc read FConfirmProc write FConfirmProc;
    property YieldProc: TYieldProc read FYieldProc write FYieldProc;
  end;

implementation

{ TBasicEngine }

//Compile a BASIC program
function TBasicEngine.Compile(source: TStrings): Integer;
var
  Key: String;
begin
  //Call the method in the parser object to do the real job
  Result := Parser.Compile(PChar(source.Text), nil, INTSource, ASMSource, FFunctions);
  if Result = 0 then //It means no errors
  begin
    errPos := 0;
    errLine := 0;
    errMessage := '';

    //Get the UDFs
    UserFunctionsTable.Clear;
    for Key in Parser.UserFunctionsTable.Keys do
      UserFunctionsTable.Add(Key, Parser.UserFunctionsTable[Key]);

    //Get all functions signatures and entry points
    LibFunctionsTable.Clear;
    for Key in Parser.LibFunctionsTable.Keys do
      LibFunctionsTable.Add(Key, Parser.LibFunctionsTable[Key]);

    Parser.exec.LoadSource(ASMSource);
  end
  else //there is an error
  begin
    errPos := Parser.errPos; //pos
    errLine := Parser.errLine; //line
    errMessage := Parser.lastErr; //error message
  end;
end;

//Same as "Compile" but using PChar type
function TBasicEngine.Compile(source: PChar): Integer;
var
  Key: String;
begin
  Result := Parser.Compile(source, nil, INTSource, ASMSource, FFunctions);
  if Result = 0 then
  begin
    errPos := 0;
    errLine := 0;
    errMessage := '';

    UserFunctionsTable.Clear();
    for Key in Parser.UserFunctionsTable.Keys do
      UserFunctionsTable.Add(Key, Parser.UserFunctionsTable[Key]);

    LibFunctionsTable.Clear();
    for Key in Parser.LibFunctionsTable.Keys do
      LibFunctionsTable.Add(Key, Parser.LibFunctionsTable[Key]);

    Parser.exec.LoadSource(ASMSource);
  end
  else
  begin
    errPos := Parser.errPos;
    errLine := Parser.errLine;
    errMessage := Parser.lastErr;
  end;
end;

{ TVMCall }

constructor TVMCall.Create();
begin
  inherited Create();
  //Manual reset, because the waiter may look after the VM has already
  //signalled, and an auto-reset event would have forgotten by then.
  Finished := TEvent.Create(nil, True, False, '');
end;

destructor TVMCall.Destroy();
begin
  Finished.Free();
  inherited Destroy();
end;

{ TBasicEngine }

constructor TBasicEngine.Create();
begin
  FVMThread := 0;
  FPending := TObjectList<TVMCall>.Create(False); //the waiter owns each call
  FPendingLock := TCriticalSection.Create();
  FOutputLock := TCriticalSection.Create();
  FPendingText := '';
  FPendingClear := False;
  FFunctions := TFunctionsDictionary.Create();
  Parser := TBasicParser.Create(); //Creates the parser
  INTSource := TStringTokens.Create(); //Holds intermediate postfix code
  ASMSource := TStringTokens.Create(); //Holds final postfix code
  //Allow following program execution
  OnProgress := nil;
  //Pointer to the main object in BASIC
  This := nil;
  //UDFs data
  UserFunctionsTable := TUserFunctionsDictionary.Create();
  //All functions entry points
  LibFunctionsTable := TFunctionsDictionary.Create();
  FScriptTimeOut := 30; //In seconds
end;

destructor TBasicEngine.Destroy();
begin
  //Anything still queued will never run, and its waiter is blocked on an event
  //nobody will set. Release them with a failure rather than leaving threads
  //parked on a dead engine.
  if Assigned(FPendingLock) then
  begin
    FPendingLock.Enter();
    try
      while FPending.Count > 0 do
      begin
        FPending[0].Failed := True;
        FPending[0].ErrorText := 'the engine was destroyed before this call ran';
        FPending[0].Finished.SetEvent();
        FPending.Delete(0);
      end;
    finally
      FPendingLock.Leave();
    end;
  end;
  if Assigned(FPending) then FreeAndNil(FPending);
  if Assigned(FPendingLock) then FreeAndNil(FPendingLock);
  if Assigned(FOutputLock) then FreeAndNil(FOutputLock);

  if Assigned(LibFunctionsTable) then FreeAndNil(LibFunctionsTable);
  if Assigned(UserFunctionsTable) then FreeAndNil(UserFunctionsTable);
  if Assigned(ASMSource) then FreeAndNil(ASMSource);
  if Assigned(INTSource) then FreeAndNil(INTSource);
  if Assigned(Parser) then FreeAndNil(Parser);
  if Assigned(FFunctions) then FreeAndNil(FFunctions);

  inherited Destroy();
end;

//Execute the program from the first instruction
procedure TBasicEngine.ExecuteProgram(stdout: TStrings);
begin
  Parser.exec.CallbackObj := nil;
  if Assigned(OnProgress) then
    Parser.exec.CallbackObj := Self;
  output := stdout;
  Parser.exec.TimeOut := FScriptTimeOut;
  Parser.exec.TagObject := This;
  Parser.exec.PrintProc := PrintProc;
  Parser.exec.InputProc := FInputProc;
  Parser.exec.ConfirmProc := FConfirmProc;
  Parser.exec.YieldProc := FYieldProc;
  Parser.exec.CallbackProc := OnProgress; // Debugger
  Parser.exec.GlobalVarNames := Parser.GlobalVars;
  Parser.exec.ExecuteProgram();
end;

//Execute a user defined function present at the compiled BASIC code
procedure TBasicEngine.ClaimVMThread();
begin
  FVMThread := TThread.Current.ThreadID;
  //The VM needs somewhere to run what other threads queue. Its existing yield
  //points fire only when paused or after a PRINT, so a computing program would
  //never reach one and the caller would wait until it timed out.
  Parser.exec.DrainProc := DrainQueuedCalls;
end;

procedure TBasicEngine.ReleaseVMThread();
begin
  FVMThread := 0;
  Parser.exec.DrainProc := nil;
  //Whatever is still queued can no longer be run by anyone.
  DrainQueuedCalls();
end;

function TBasicEngine.CallsMustBeQueued(): Boolean;
begin
  Result := (FVMThread <> 0) and (TThread.Current.ThreadID <> FVMThread);
end;

procedure TBasicEngine.RunOneQueuedCall(const ACall: TVMCall);
begin
  try
    //Straight through: this is already the VM's thread, so the routing test in
    //ExecuteUserFunction sends it down the ordinary path.
    ExecuteUserFunction(output, ACall.Signature, ACall.Args,
                        ACall.RetType, ACall.RetValue);
  except
    on E: Exception do
    begin
      ACall.Failed := True;
      ACall.ErrorText := E.Message;
    end;
  end;
  ACall.Finished.SetEvent();
end;

procedure TBasicEngine.DrainQueuedCalls();
var
  Call: TVMCall;
begin
  if not Assigned(FPendingLock) then
    Exit();

  //One at a time, releasing the lock while the VM runs, so a callback that
  //queues another call cannot deadlock against the queue it is queueing into.
  repeat
    Call := nil;
    FPendingLock.Enter();
    try
      if FPending.Count > 0 then
      begin
        Call := FPending[0];
        FPending.Delete(0);
      end;
    finally
      FPendingLock.Leave();
    end;

    if Call = nil then
      Break;

    if FVMThread = 0 then
    begin
      //Nobody owns the VM any more; the waiter would wait forever.
      Call.Failed := True;
      Call.ErrorText := 'the VM thread ended before this call ran';
      Call.Finished.SetEvent();
    end
    else
      RunOneQueuedCall(Call);
  until False;
end;

function TBasicEngine.QueueAndWait(const ASignature: String;
                                   const AParameters: array of TAsmData;
                                   out RetType: TExprKind;
                                   out RetValue: TAsmData): Boolean;
var
  Call: TVMCall;
  i: Integer;
  Waited: Cardinal;
begin
  Result := False;
  RetType := TExprKind.ekNumber;
  RetValue := Default(TAsmData);

  Call := TVMCall.Create();
  try
    Call.Signature := ASignature;
    SetLength(Call.Args, Length(AParameters));
    for i := 0 to High(AParameters) do
      Call.Args[i] := AParameters[i];

    FPendingLock.Enter();
    try
      FPending.Add(Call);
    finally
      FPendingLock.Leave();
    end;

    //The wait cannot simply block. The VM may marshal a library call back to
    //this thread through TThread.Synchronize, and Synchronize only completes
    //when the main thread runs CheckSynchronize. A plain WaitFor here would
    //park the very thread the VM is waiting on: both sides stopped, forever.
    //
    //So the wait is a loop that keeps answering.
    Waited := 0;
    while Call.Finished.WaitFor(10) = wrTimeout do
    begin
      if TThread.Current.ThreadID = MainThreadID then
        CheckSynchronize(0);
      Inc(Waited, 10);
      //A VM stuck in a loop with no yield point would otherwise hold the
      //interface still. Give up rather than freeze, and say why.
      if (FScriptTimeOut > 0) and (Waited > Cardinal(FScriptTimeOut) * 1000) then
      begin
        Call.Failed := True;
        Call.ErrorText := 'the VM did not reach a yield point in time';
        Break;
      end;
      if FVMThread = 0 then
      begin
        Call.Failed := True;
        Call.ErrorText := 'the VM thread ended while this call waited';
        Break;
      end;
    end;

    if not Call.Failed then
    begin
      RetType := Call.RetType;
      RetValue := Call.RetValue;
      Result := True;
    end;
  finally
    //Taken out of the queue if the wait gave up on it before the VM got there.
    FPendingLock.Enter();
    try
      FPending.Remove(Call);
    finally
      FPendingLock.Leave();
    end;
    Call.Free();
  end;
end;

procedure TBasicEngine.ExecuteUserFunction(stdout: TStrings; FunctionSignature: String; Parameters: array of TAsmData; out RetType: TExprKind; out RetValue: TAsmData);
var
  wFunction: TFunctionData;

  function ReturnType(signature: String; out rType: TExprKind): Boolean;
  var
    sepPos: Integer;
  begin
    //minimum valid signature name is 1 alpha char + the @ char, like: 'f@'
    if signature.Length < 2 then
      Exit(false);
    sepPos := signature.IndexOf('@'); //find position of '@'
    if (sepPos <= 0) then
      Exit(false);
    case signature.Chars[sepPos-1] of //find type
      '$': rType := ekString;
      '#': rType := ekPointer;
      else rType := ekNumber;
    end;
    Result := true;
  end;

begin
  //Tries to locate de function signature...
  if not UserFunctionsTable.ContainsKey(FunctionSignature) then
    Exit(); //... if not found, just do nothing.

  //wFunction holds the located function data
  wFunction := UserFunctionsTable[FunctionSignature];

  //Find function return type.
  //If there is a problem with the signature syntax, leave with no action.
  //But this should never take place.
  //Arriving from a thread that does not own the VM, this cannot run here: the
  //stack machine holds one caller at a time. Hand it over and wait.
  //
  //The call site does not change. TimerLib's OnTimer and the 405 control
  //callbacks all reach the VM through this method, so routing it once routes
  //all of them, and a host that never claims a thread never takes this path.
  if CallsMustBeQueued() then
  begin
    QueueAndWait(FunctionSignature, Parameters, RetType, RetValue);
    Exit();
  end;

  if not ReturnType(FunctionSignature, RetType) then
    Exit();

  Parser.exec.CallbackObj := nil;

  if Assigned(OnProgress) then
    Parser.exec.CallbackObj := Self; //Callback obj
  output := stdout; //"standard output"
  Parser.exec.TimeOut := FScriptTimeOut; //Set timeout
  Parser.exec.TagObject := This; //sets TAG object
  Parser.exec.PrintProc := PrintProc; //Output object
  Parser.exec.InputProc := FInputProc;
  Parser.exec.ConfirmProc := FConfirmProc;
  Parser.exec.YieldProc := FYieldProc;
  Parser.exec.CallbackProc := OnProgress; //Callback proc (Debugger)
  Parser.exec.GlobalVarNames := Parser.GlobalVars; //Update global vars info
  Parser.exec.ExecuteFunction(
    wFunction.Entry,
    wFunction.ArgCount,
    wFunction.ArgType,
    Parameters,
    RetType,
    RetValue //set after method call
  );
end;

function TBasicEngine.GetGlobalNum(const name: String; out index: Integer): Extended;
begin
  Result := NaN;
  index := Parser.GlobalVars.IndexOf(name);
  if index >= 0 then
    Result := Parser.exec.GetGlobalNum(index);
end;

function TBasicEngine.GetGlobalPtr(const name: String; out index: Integer): Pointer;
begin
  Result := nil;

  if name.Chars[Pred(name.Length)] <> '#' then
    index := Parser.GlobalVars.IndexOf(name+'#')
  else
    index := Parser.GlobalVars.IndexOf(name);

  if index >= 0 then
    Result := Parser.exec.GetGlobalPtr(index);
end;

function TBasicEngine.GetGlobalStr(const name: String; out index: Integer): String;
begin
  Result := '';

  if name.Chars[Pred(name.Length)] <> '$' then
    index := Parser.GlobalVars.IndexOf(name+'$')
  else
    index := Parser.GlobalVars.IndexOf(name);

  if index >= 0 then
    Result := Parser.exec.GetGlobalStr(index);
end;

function TBasicEngine.LoadIntermediate(source: TStrList): Integer;
var
  i: Integer;
  Key: String;
  PFCode: TStringTokens;
  Token: TStringToken;
begin
  //Convert the intermediate code from strings to the proper notation
  PFCode := TStringTokens.Create();
  for i := 0 to Source.Count-1 do
  begin
    Token.Str := Source[i];
    PFCode.Add(Token);
  end;
  //Call the method in the parser object to do the real job
  Result := Parser.ProcessPostfixCode(PFCode, ASMSource, FFunctions, nil);
  if Result = 0 then //It means no errors
  begin
    errPos := 0;
    errLine := 0;
    errMessage := '';

    //Get the UDFs
    UserFunctionsTable.Clear();
    for Key in Parser.UserFunctionsTable.Keys do
      UserFunctionsTable.Add(Key, Parser.UserFunctionsTable[Key]);

    //Get all functions signatures and entry points
    LibFunctionsTable.Clear();
    for Key in Parser.LibFunctionsTable.Keys do
      LibFunctionsTable.Add(Key, Parser.LibFunctionsTable[Key]);

    //Calls the stack machine and load the assembly code produced
    Parser.exec.LoadSource(ASMSource);
  end
  else //there is an error
  begin
    errPos := Parser.errPos; //pos
    errLine := Parser.errLine; //line
    errMessage := Parser.lastErr; //error message
  end;
//  {$IFDEF MSWINDOWS}
  FreeAndNil(PFCode);
//  {$ELSE}
//  PFCode := nil;
//  {$ENDIF}
end;

//Auxiliary to the PRINT command. Adds the text in "p" to the output list
//procedure TBasicEngine.PrintProc(p: PChar);
//begin
//  if output = nil then
//    Exit();
//  if p = nil then
//    output.Clear()
//  else
//    output.Text := output.Text + StrPas(p);
//    //output.Add(StrPas(p));
//end;
//Auxiliary to the PRINT command. Adds the text in "p" to the output list
//The rule PRINT has always followed: what it emits continues the line already
//there, and only an embedded break starts a new one. Extracted so the threaded
//and unthreaded paths cannot drift apart on it.
procedure TBasicEngine.AppendToOutput(ATarget: TStrings; const AText: String);
var
  Lines: TArray<String>;
  I, LastIndex: Integer;
begin
  if (ATarget = nil) or (AText = '') then
    Exit();

  Lines := AText.Split([#13#10, #10, #13], TStringSplitOptions.None);
  if Length(Lines) = 0 then
    Exit();

  // First part: append to the last line, or start a new one
  if ATarget.Count = 0 then
    ATarget.Add(Lines[0])
  else
  begin
    LastIndex := ATarget.Count - 1;
    ATarget[LastIndex] := ATarget[LastIndex] + Lines[0];
  end;

  // Additional lines (from line breaks inside the text)
  for I := 1 to High(Lines) do
    ATarget.Add(Lines[I]);
end;

procedure TBasicEngine.PrintProc(p: PChar);
var
  Text: String;
begin
  //With a thread claimed, `output` is the host's TMemo.Lines and this is the
  //worker. Touching it here is a data race on every line, so the text waits
  //for DrainOutput, which the host calls on its own thread.
  if FVMThread <> 0 then
  begin
    FOutputLock.Enter();
    try
      if p = nil then
      begin
        //A clear cancels everything queued behind it, exactly as it would if
        //it had been applied the moment it was asked for.
        FPendingText := '';
        FPendingClear := True;
      end
      else
        FPendingText := FPendingText + StrPas(p);
    finally
      FOutputLock.Leave();
    end;
    Exit();
  end;

  if output = nil then Exit();
  if p = nil then begin output.Clear(); Exit(); end;

  Text := StrPas(p);
  if Text = '' then Exit();

  AppendToOutput(output, Text);

  // Fire the event HERE - after the text is already in the output
  if Assigned(FOnPrintOutput) then
    FOnPrintOutput(Self, Text, False);
end;

function TBasicEngine.DrainOutput(ATarget: TStrings): Integer;
var
  Text: String;
  DoClear: Boolean;
  Before: Integer;
begin
  Result := 0;
  if not Assigned(FOutputLock) then
    Exit();

  //Held only long enough to take the text, so a PRINT on the VM thread is not
  //waiting on however long a TMemo takes to redraw.
  FOutputLock.Enter();
  try
    Text := FPendingText;
    DoClear := FPendingClear;
    FPendingText := '';
    FPendingClear := False;
  finally
    FOutputLock.Leave();
  end;

  if ATarget = nil then
    Exit();
  if DoClear then
    ATarget.Clear();
  if Text = '' then
    Exit();

  Before := ATarget.Count;
  AppendToOutput(ATarget, Text);
  Result := ATarget.Count - Before;

  //Fired here rather than from PrintProc, so a handler that touches the
  //interface runs on the thread that owns it.
  if Assigned(FOnPrintOutput) then
    FOnPrintOutput(Self, Text, False);
end;

//Set the script timeout
procedure TBasicEngine.SetScriptTimeOut(const Value: Int64);
begin
  if Value < 0 then
    FScriptTimeOut := 0
  else
    FScriptTimeOut := Value;
end;

procedure TBasicEngine.Stop();
begin
  Parser.exec.Stop();
end;

function TBasicEngine.TotalTokens: Cardinal;
begin
  Result := Parser.lexer.TotalTokens;
end;

function TBasicEngine.UserFunctionExists(Signature: String): Boolean;
begin
  Result := false;
  if UserFunctionsTable.ContainsKey(Signature) then
    Result := true;
end;

end.

