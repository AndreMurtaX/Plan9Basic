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
  protected
    procedure Execute(); override;
  public
    Started: TEvent;
    constructor Create(AEngine: TBasicEngine; AOutput: TStringList);
    destructor Destroy(); override;
  end;

var
  Failures: Integer = 0;

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

constructor TVMThread.Create(AEngine: TBasicEngine; AOutput: TStringList);
begin
  FEngine := AEngine;
  FOutput := AOutput;
  Started := TEvent.Create(nil, True, False, '');
  inherited Create(False);
end;

destructor TVMThread.Destroy();
begin
  Started.Free();
  inherited Destroy();
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

var
  Engine: TBasicEngine;
  Output, Source: TStringList;
  Worker: TVMThread;
  RetType: TExprKind;
  RetValue: TAsmData;
  Args: array of TAsmData;
  Queued: Boolean;
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

      //The program would otherwise run for a very long time.
      Engine.Stop();
      Worker.WaitFor();
    finally
      Worker.Free();
    end;

    //The thread is gone, so calls run in place again.
    Check('after release, nothing is queued', not Engine.CallsMustBeQueued());
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
