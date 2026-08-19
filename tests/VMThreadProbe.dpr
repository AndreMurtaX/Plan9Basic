{******************************************************************************
  VMThreadProbe - the VM on a thread of its own, called from another one

  The stack machine holds one caller at a time, whatever thread they arrive
  from. So when a host runs a program on a worker, a control click or a timer
  tick firing on the UI thread cannot execute there: it has to be handed over.

  This exercises that handover, because a BASIC test cannot. It has no threads,
  and the whole subject here is which thread a call runs on.

  Three things are checked, and the third is the one worth having:

    1. A queued call reaches the VM and its answer comes back.
    2. It ran on the VM's thread, not the caller's.
    3. It does not deadlock when the VM marshals work back to the caller.

  Three is the failure this mechanism exists to avoid and the reason it is not
  a plain WaitFor. The waiter is the main thread; TThread.Synchronize completes
  only when the main thread runs CheckSynchronize; so a blocking wait stops the
  thread the VM is waiting for. Both sides stop, and nothing reports anything.
  A test that hangs is a test that fails, which is why this one has a timeout.
******************************************************************************}
program VMThreadProbe;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.SyncObjs,
  System.Diagnostics,
  UnitUtils in '..\engine\UnitUtils.pas',
  lexer in '..\engine\lexer.pas',
  exec in '..\engine\exec.pas',
  parser in '..\engine\parser.pas',
  basic in '..\engine\basic.pas',
  UnitGC in '..\engine\utils\UnitGC.pas',
  HandleRegistry in '..\engine\utils\HandleRegistry.pas',
  HostServices in '..\engine\utils\HostServices.pas',
  StdLib in '..\engine\Libs\StdLib.pas',
  NumLib in '..\engine\Libs\NumLib.pas',
  StrLib in '..\engine\Libs\StrLib.pas',
  ArrayLib in '..\engine\Libs\ArrayLib.pas';

type
  //Runs the program, and stands in for a host that moved the VM off the UI
  //thread: it claims the thread, and drains the queue wherever the VM yields.
  TVMThread = class(TThread)
  private
    FEngine: TBasicEngine;
    FOutput: TStringList;
    procedure Yield();
  public
    //True reproduces what a real FMX host must do: its YieldProc pumps the
    //message loop, which is precisely wrong from a worker, so it has to be
    //taken away. Everything then depends on DrainProc alone.
    NoYieldProc: Boolean;
  private
  protected
    procedure Execute(); override;
  public
    Started: TEvent;
    constructor Create(AEngine: TBasicEngine; AOutput: TStringList;
      ANoYieldProc: Boolean = False);
    destructor Destroy(); override;
  end;

//Answers a BREAKPOINT only when told to, so the VM can be caught parked.
//
//This is the state the first device attempt deadlocked in and no headless test
//could reach: the VM stopped in esIdle, waiting for a host that has not
//answered yet, while another thread wants to run BASIC.
  //Records what INPUT actually handed the host, and answers later rather than
  //at once -- which is what a real host does when it queues a dialog instead
  //of blocking inside one.
  TRecordingInput = class
  public
    Caption: String;
    Labels: TArray<String>;
    Defaults: TArray<String>;
    Called: Boolean;
    Pending: TInputDoneProc;
    procedure Input(const ACaption: String; const ALabels: array of String;
                    const ADefaults: array of String; const ADone: TInputDoneProc);
  end;

  TMarshalHost = class
  public
    procedure Marshal(const AProc: TThreadMethod);
  end;

  THeldConfirm = class
  public
    Pending: TConfirmDoneProc;
    Asked: Boolean;
    procedure Confirm(const AMessage: String; const ADone: TConfirmDoneProc);
    procedure AnswerYes();
  end;

var
  Failures: Integer = 0;
  //Where a NeedsUIThread library function actually executed. The GUI libraries
  //cannot be linked here -- that would drag FireMonkey into a console probe and
  //defeat the point -- so one stands in for all 96 of them.
  MarkedRanOnThread: TThreadID = 0;

function n_where_did_i_run(var Args: Array of TAsmData): TAsmData;
begin
  Result := Default(TAsmData);
  MarkedRanOnThread := TThread.Current.ThreadID;
  Result.n := 1;
end;

procedure Check(const AWhat: String; ACondition: Boolean);
begin
  if ACondition then
    Writeln('  ok    ', AWhat)
  else
  begin
    Writeln('  FAIL  ', AWhat);
    Inc(Failures);
  end;
end;

procedure THeldConfirm.Confirm(const AMessage: String;
  const ADone: TConfirmDoneProc);
begin
  //Held, not answered. The VM is now parked and stays parked.
  Pending := ADone;
  Asked := True;
end;

procedure THeldConfirm.AnswerYes();
var
  Done: TConfirmDoneProc;
begin
  Done := Pending;
  Pending := nil;
  if Assigned(Done) then
    Done(True);
end;

constructor TVMThread.Create(AEngine: TBasicEngine; AOutput: TStringList;
  ANoYieldProc: Boolean);
begin
  FEngine := AEngine;
  FOutput := AOutput;
  NoYieldProc := ANoYieldProc;
  Started := TEvent.Create(nil, True, False, '');
  inherited Create(False);
end;

destructor TVMThread.Destroy();
begin
  Started.Free();
  inherited Destroy();
end;

//What an FMX host installs: run this on the thread that owns the window, and
//do not come back until it has.
procedure TRecordingInput.Input(const ACaption: String;
  const ALabels: array of String; const ADefaults: array of String;
  const ADone: TInputDoneProc);
var
  i: Integer;
begin
  //Copied here and now. An open array parameter is only the caller's memory,
  //and this returns before the answer is given.
  Caption := ACaption;
  SetLength(Labels, Length(ALabels));
  for i := 0 to High(ALabels) do
    Labels[i] := ALabels[i];
  SetLength(Defaults, Length(ADefaults));
  for i := 0 to High(ADefaults) do
    Defaults[i] := ADefaults[i];
  Called := True;
  Pending := ADone;
end;

procedure TMarshalHost.Marshal(const AProc: TThreadMethod);
begin
  TThread.Synchronize(nil, AProc);
end;

procedure TVMThread.Yield();
begin
  //Where a single-threaded host pumps its message loop, a host with the VM on
  //a worker runs what the UI thread has queued instead.
  FEngine.DrainQueuedCalls();
end;

procedure TVMThread.Execute();
begin
  FEngine.ClaimVMThread();
  if NoYieldProc then
    FEngine.YieldProc := nil
  else
    FEngine.YieldProc := Yield;
  Started.SetEvent();
  try
    FEngine.ExecuteProgram(FOutput);
  finally
    FEngine.ReleaseVMThread();
  end;
end;

const
  PROBE_SOURCE =
    'FUNCTION double(n) LOCAL r' + sLineBreak +
    '  LET r = n * 2' + sLineBreak +
    '  RETURN r' + sLineBreak +
    'END FUNCTION' + sLineBreak +
    'PRINTLN "printed from the vm thread"' + sLineBreak +
    'LET k = 0' + sLineBreak +
    // Long enough that the program is still running when the call is queued,
    // and stopped explicitly once it has been answered. A short loop finishes
    // in microseconds and the first version of this test queued into a VM that
    // had already released its thread -- which failed, correctly, and looked
    // like a broken handover rather than a broken test.
    'FOR k = 1 TO 100000000' + sLineBreak +
    '  LET x = processmessages()' + sLineBreak +
    'NEXT k' + sLineBreak +
    'END';

//The VM stops at a BREAKPOINT and waits for an answer. While it waits, another
//thread wants to run BASIC.
//
//This is what the applet hit on the device and what nothing here could reach
//before: every existing check runs against a VM that is executing, never one
//that is parked. A parked stack machine is stopped in the middle of an
//instruction, so it cannot simply be asked to run something else, and the
//caller that asks must not be left waiting for an answer that will never come.
//
//What is required is not that the call succeeds -- refusing it is a defensible
//answer -- but that the caller is *released*, one way or the other, rather than
//held until something times out.
//A library call that touches FireMonkey must run on the thread that owns the
//window, whatever thread the VM is on. That is what MarshalProc is for, and
//until now nothing exercised it: the seam has been inert since it was built.
//
//The GUI libraries cannot be linked into a console probe without dragging in
//the 58 FMX units the whole boundary exists to keep out, so one registered
//function stands in for all 96 that carry the flag. It records the thread it
//ran on, which is the only thing the seam is responsible for.
//What INPUT hands a host, with the VM on a thread of its own.
//
//The applet's INPUT dialog opened with its title and nothing else, twice, under
//two different marshalling strategies. Three things could produce that and only
//one is the host's fault: the engine passing empty arrays, the copy losing
//them, or the closure failing to hold them. This asks the first two, which are
//the ones a console probe can reach.
procedure CheckInputArrays();
var
  Engine: TBasicEngine;
  Output, Source: TStringList;
  Worker: TVMThread;
  Rec: TRecordingInput;
  Waited: Integer;
begin
  Engine := TBasicEngine.Create();
  Output := TStringList.Create();
  Source := TStringList.Create();
  Rec := TRecordingInput.Create();
  try
    StdLib.RegisterStdFuncs(Engine.Functions);
    NumLib.RegisterNumFuncs(Engine.Functions);
    StrLib.RegisterStrFuncs(Engine.Functions);

    Engine.InputProc := Rec.Input;
    Engine.ScriptTimeOut := 10;

    Source.Text :=
      'FUNCTION gotValue(v)' + sLineBreak +
      '  RETURN 0' + sLineBreak +
      'END FUNCTION' + sLineBreak +
      'INPUT "Plan9Basic", "Type a number:", 42, gotValue' + sLineBreak +
      'END';

    if Engine.Compile(Source) <> 0 then
    begin
      Check('the INPUT program compiles', False);
      Writeln('        (', Engine.ErrorMessage, ')');
      Exit();
    end;

    Worker := TVMThread.Create(Engine, Output, True);
    try
      Waited := 0;
      while (not Rec.Called) and (Waited < 5000) do
      begin
        Sleep(20);
        Inc(Waited, 20);
      end;
      Worker.WaitFor();
    finally
      Worker.Free();
    end;

    Check('INPUT asked the host', Rec.Called);
    Check('and gave it the caption', Rec.Caption = 'Plan9Basic');
    if Length(Rec.Labels) <> 1 then
      Writeln('        (labels count = ', Length(Rec.Labels), ')');
    Check('and one label', Length(Rec.Labels) = 1);
    Check('with the prompt the program wrote',
          (Length(Rec.Labels) = 1) and (Rec.Labels[0] = 'Type a number:'));
    if Length(Rec.Defaults) <> 1 then
      Writeln('        (defaults count = ', Length(Rec.Defaults), ')');
    Check('and one default', Length(Rec.Defaults) = 1);
    Check('carrying the value the program supplied',
          (Length(Rec.Defaults) = 1) and (Rec.Defaults[0] = '42'));
  finally
    Rec.Free();
    Source.Free();
    Output.Free();
    Engine.Free();
  end;
end;

procedure CheckMarshalling();
var
  Engine: TBasicEngine;
  Output, Source: TStringList;
  Worker: TVMThread;
  Host: TMarshalHost;
  Fn: TLinkFunction;
  Waited: Integer;
begin
  Engine := TBasicEngine.Create();
  Output := TStringList.Create();
  Source := TStringList.Create();
  Host := TMarshalHost.Create();
  try
    StdLib.RegisterStdFuncs(Engine.Functions);
    NumLib.RegisterNumFuncs(Engine.Functions);

    Fn.FarCall := True;
    Fn.Entry := n_where_did_i_run;
    Fn.NeedsUIThread := True;
    Engine.Functions.Add('marked@', Fn);

    Engine.ScriptTimeOut := 10;
    Source.Text :=
      'LET x = marked()' + sLineBreak +
      'LET k = 0' + sLineBreak +
      'FOR k = 1 TO 200000' + sLineBreak +
      '  LET y = k' + sLineBreak +
      'NEXT k' + sLineBreak +
      'END';

    if Engine.Compile(Source) <> 0 then
    begin
      Check('the marshalling program compiles', False);
      Exit();
    end;

    MarkedRanOnThread := 0;
    Engine.Parser.exec.MarshalProc := Host.Marshal;

    Worker := TVMThread.Create(Engine, Output, True);
    try
      Worker.Started.WaitFor(2000);
      //Synchronize needs this thread to keep answering, exactly as a host's
      //message loop would.
      Waited := 0;
      while (not Worker.Finished) and (Waited < 10000) do
      begin
        CheckSynchronize(10);
        Inc(Waited, 10);
      end;
      Worker.WaitFor();
    finally
      Worker.Free();
    end;

    Check('the marked function ran', MarkedRanOnThread <> 0);
    Check('and it ran on the main thread, not the VM thread',
          MarkedRanOnThread = MainThreadID);
  finally
    Host.Free();
    Source.Free();
    Output.Free();
    Engine.Free();
  end;
end;

procedure CheckPausedHandover(ANoYieldProc: Boolean);
var
  Engine: TBasicEngine;
  Output, Source: TStringList;
  Worker: TVMThread;
  Held: THeldConfirm;
  RetType: TExprKind;
  RetValue: TAsmData;
  Args: array of TAsmData;
  Waited: Integer;
  Clock: TStopwatch;
  Elapsed: Int64;
begin
  Engine := TBasicEngine.Create();
  Output := TStringList.Create();
  Source := TStringList.Create();
  Held := THeldConfirm.Create();
  try
    StdLib.RegisterStdFuncs(Engine.Functions);
    NumLib.RegisterNumFuncs(Engine.Functions);
    StrLib.RegisterStrFuncs(Engine.Functions);
    ArrayLib.RegisterArrayFuncs(Engine.Functions);

    Engine.ConfirmProc := Held.Confirm;
    Engine.ScriptTimeOut := 5;

    Source.Text :=
      'FUNCTION ping(n)' + sLineBreak +
      '  RETURN n + 1' + sLineBreak +
      'END FUNCTION' + sLineBreak +
      'TRACEON' + sLineBreak +
      'BREAKPOINT "parked here"' + sLineBreak +
      'TRACEOFF' + sLineBreak +
      'END';

    if Engine.Compile(Source) <> 0 then
    begin
      Check('the parked-VM program compiles', False);
      Exit();
    end;

    Worker := TVMThread.Create(Engine, Output, ANoYieldProc);
    try
      Worker.Started.WaitFor(2000);

      //Wait for the VM to actually reach the breakpoint and park.
      Waited := 0;
      while (not Held.Asked) and (Waited < 5000) do
      begin
        Sleep(20);
        Inc(Waited, 20);
      end;
      Check('the VM reached the breakpoint and parked', Held.Asked);

      SetLength(Args, 1);
      Args[0] := Default(TAsmData);
      Args[0].n := 41;

      Clock := TStopwatch.StartNew();
      Engine.ExecuteUserFunction(Output, 'ping@n', Args, RetType, RetValue);
      Elapsed := Clock.ElapsedMilliseconds;

      //Either answer it or refuse it, but come back. Held until a timeout is
      //the one outcome that shows up as a frozen window.
      Writeln('        (the caller waited ', Elapsed, ' ms)');
      Check('a call arriving during a pause releases its caller promptly',
            Elapsed < 2000);

      //And the pause itself has to survive being asked.
      Held.AnswerYes();
      Worker.WaitFor();
      Check('the program still finishes after the breakpoint is answered',
            True);
    finally
      Worker.Free();
    end;
  finally
    Held.Free();
    Source.Free();
    Output.Free();
    Engine.Free();
  end;
end;

var
  Engine: TBasicEngine;
  Output, Source: TStringList;
  Worker: TVMThread;
  RetType: TExprKind;
  RetValue: TAsmData;
  Args: array of TAsmData;
  Queued: Boolean;
  Shown: TStringList;
  Moved, Tries: Integer;
begin
  UnitGC.SkipProcessMessages := True;
  GC := TGarbageCollector.Create();
  Engine := TBasicEngine.Create();
  Output := TStringList.Create();
  Source := TStringList.Create();
  try
    StdLib.RegisterStdFuncs(Engine.Functions);
    NumLib.RegisterNumFuncs(Engine.Functions);
    StrLib.RegisterStrFuncs(Engine.Functions);
    ArrayLib.RegisterArrayFuncs(Engine.Functions);

    Source.Text := PROBE_SOURCE;
    if Engine.Compile(Source) <> 0 then
    begin
      Writeln('the probe program did not compile: ', Engine.ErrorMessage);
      Halt(2);
    end;

    //Before any thread is claimed, everything runs where it is called. That is
    //what every host did before this existed and must keep working.
    Check('no claim, so nothing is queued', not Engine.CallsMustBeQueued());

    //Isolates the signature from the handover: if this fails, the queued call
    //below was never going to work and the fault is not in the threading.
    Check('the probe function exists under that signature',
          Engine.UserFunctionExists('double@n'));
    SetLength(Args, 1);
    Args[0] := Default(TAsmData);
    Args[0].n := 21;
    Engine.ExecuteUserFunction(Output, 'double@n', Args, RetType, RetValue);
    if RetValue.n <> 42 then
      Writeln('        (direct call came back with ', RetValue.n:0:4, ')');
    Check('called directly, with no thread claimed, it answers', RetValue.n = 42);

    Worker := TVMThread.Create(Engine, Output);
    try
      Worker.Started.WaitFor(2000);

      Queued := Engine.CallsMustBeQueued();
      Check('the main thread is not the VM thread, so calls queue', Queued);

      SetLength(Args, 1);
      Args[0] := Default(TAsmData);
      Args[0].n := 21;

      //Blocks until the VM drains it at a yield point. If the handover is
      //broken this never returns and the run times out, which is the point.
      Engine.ExecuteUserFunction(Output, 'double@n', Args, RetType, RetValue);

      if RetValue.n <> 42 then
        Writeln('        (came back with ', RetValue.n:0:4, ')');
      Check('the queued call came back with the VM answer', RetValue.n = 42);
      Check('and with the right type', RetType = TExprKind.ekNumber);

      //PRINT must not have touched the TStrings handed to ExecuteProgram: on a
      //real host that is a TMemo's Lines, and this is not its thread. The text
      //waits for the host to come and get it.
      Check('the handed-over list was never written from the worker',
            Output.Count = 0);

      Shown := TStringList.Create();
      try
        Moved := 0;
        for Tries := 1 to 200 do
        begin
          Moved := Moved + Engine.DrainOutput(Shown);
          if Moved > 0 then
            Break;
          Sleep(10);
        end;
        Check('and it arrives when the host drains it', Moved > 0);
        Check('with the text the program printed',
              (Shown.Count > 0) and
              (Pos('printed from the vm thread', Shown.Text) > 0));
      finally
        Shown.Free();
      end;

      //The program would otherwise run for a very long time.
      Engine.Stop();
      Worker.WaitFor();
    finally
      Worker.Free();
    end;

    //The thread is gone, so calls run in place again.
    Check('after release, nothing is queued', not Engine.CallsMustBeQueued());

    Writeln;
    Writeln('  --- a call arriving while the VM is parked ---');
    Writeln('  (with a YieldProc that drains, as a console host can have)');
    CheckPausedHandover(False);
    Writeln;
    Writeln('  (with no YieldProc at all, as an FMX host on a worker must be)');
    CheckPausedHandover(True);

    Writeln;
    Writeln('  --- a library call that must touch the UI thread ---');
    CheckMarshalling();

    Writeln;
    Writeln('  --- what INPUT hands the host ---');
    CheckInputArrays();
  finally
    Source.Free();
    Output.Free();
    Engine.Free();
    GC.Free();
  end;

  Writeln;
  if Failures > 0 then
  begin
    Writeln(Failures, ' check(s) failed');
    Halt(1);
  end;
  Writeln('OK - the VM ran on its own thread and answered another one');
end.
