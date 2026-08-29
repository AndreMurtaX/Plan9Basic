{******************************************************************************
  CallbackProbe - the second dispatch loop, which no BASIC test can reach

  The engine has two loops. ExecuteProgram runs a program; ExecuteFunction runs
  everything a host calls back into -- every OnTimer, OnClick and OnKey. A .bas
  file cannot exercise the second one, because reaching it means being the host,
  and that is why it drifted: the commit that throttled the timeout check to one
  instruction in ten thousand landed in ExecuteProgram and not in the loop 120
  lines below it, and nothing failed.

  The GUI suite registers callbacks but never fires them -- there is no message
  loop to fire them -- so its 4,950 assertions say nothing about this code. This
  program says something about it.

  Four checks, and the fourth is the one that would have caught the drift:

    1. A callback returns the right answer, and goes on doing so when it is
       called many times. ExecuteFunction saves and restores the whole VM state
       around its body; if that ever stops working, the tenth call is wrong.
    2. A runaway callback is still stopped by the script timeout, close to the
       deadline rather than at the first instruction or not at all.
    3. That timeout is PER CALL and not cumulative. The stopwatch is created
       inside ExecuteFunction, so ten thousand short calls totalling more than
       the limit must all succeed. Hoisting that watch would look like an
       optimisation and would break every long-running program built on
       callbacks.
    4. Turning the timeout ON must not make callbacks measurably slower. It used
       to make them 1.7x slower, and the only reason nobody noticed is that the
       IDE sets ScriptTimeOut to 0 while runner\AppletRunner.pas sets 30 -- the
       cost was invisible on the machine it was written on and paid on every
       frame of every game on a device.

  Exit code: 0 all checks passed, 1 one or more failed.
******************************************************************************}
program CallbackProbe;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
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

const
  //fast(n) is shaped like a real frame step: a short bounded loop over a
  //parameter, returning a value the caller can check. runaway() is the program
  //the timeout exists for.
  SOURCE =
    'function fast(n) local i, s'                     + sLineBreak +
    '  s = 0'                                         + sLineBreak +
    '  for i = 1 to 50'                               + sLineBreak +
    '    s = s + i * n'                               + sLineBreak +
    '  next'                                          + sLineBreak +
    '  return s'                                      + sLineBreak +
    'endfunction'                                     + sLineBreak +
    ''                                                + sLineBreak +
    'function runaway() local i'                      + sLineBreak +
    '  i = 0'                                         + sLineBreak +
    '  do while 1 = 1'                                + sLineBreak +
    '    i = i + 1'                                   + sLineBreak +
    '  loop'                                          + sLineBreak +
    '  return i'                                      + sLineBreak +
    'endfunction'                                     + sLineBreak +
    ''                                                + sLineBreak +
    'ready = 1'                                       + sLineBreak;

  //sum(i*n for i in 1..50) = n * 1275
  EXPECTED_FACTOR = 1275;

  SIG_FAST    = 'fast@n';
  SIG_RUNAWAY = 'runaway@';

  RUNAWAY_TIMEOUT = 2;      //seconds
  DEVICE_TIMEOUT  = 30;     //what runner\AppletRunner.pas sets

var
  Engine: TBasicEngine;
  Output: TStringList;
  Failures: Integer = 0;
  Checks: Integer = 0;

procedure Check(APassed: Boolean; const AWhat: String; const ADetail: String = '');
begin
  Inc(Checks);
  if APassed then
    WriteLn('  ok    ' + AWhat)
  else
  begin
    Inc(Failures);
    WriteLn('  FAIL  ' + AWhat);
    if ADetail <> '' then
      WriteLn('        ' + ADetail);
  end;
end;

function CallFast(AArg: Extended): Extended;
var
  Args: array[0..0] of TAsmData;
  RetType: TExprKind;
  RetValue: TAsmData;
begin
  Args[0] := Default(TAsmData);
  Args[0].n := AArg;
  RetValue := Default(TAsmData);
  Engine.ExecuteUserFunction(Output, SIG_FAST, Args, RetType, RetValue);
  Result := RetValue.n;
end;

//Times ACalls calls of fast() with the given script timeout, in milliseconds.
function TimeFast(ACalls: Integer; ATimeout: Int64): Double;
var
  Watch: TStopwatch;
  i: Integer;
begin
  Engine.ScriptTimeOut := ATimeout;
  Watch := TStopwatch.StartNew();
  for i := 1 to ACalls do
    CallFast(3);
  Watch.Stop();
  Result := Watch.Elapsed.TotalMilliseconds;
end;

procedure CheckAnswers();
var
  i: Integer;
  Bad: Integer;
  Got: Extended;
begin
  Engine.ScriptTimeOut := 0;
  Bad := 0;
  for i := 1 to 10000 do
  begin
    Got := CallFast(i);
    if Got <> i * EXPECTED_FACTOR then
      Inc(Bad);
  end;
  Check(Bad = 0, 'ten thousand calls, every answer correct',
        Format('%d wrong', [Bad]));
end;

procedure CheckRunawayStops();
var
  Watch: TStopwatch;
  Args: array of TAsmData;
  RetType: TExprKind;
  RetValue: TAsmData;
  Elapsed: Double;
begin
  Engine.ScriptTimeOut := RUNAWAY_TIMEOUT;
  SetLength(Args, 0);
  RetValue := Default(TAsmData);
  Watch := TStopwatch.StartNew();
  Engine.ExecuteUserFunction(Output, SIG_RUNAWAY, Args, RetType, RetValue);
  Watch.Stop();
  Elapsed := Watch.Elapsed.TotalSeconds;

  //Generous on both sides. The point is that it stops, near the deadline: a
  //check that never fires leaves it running forever, and one that fires on
  //every instruction is the cost this loop was carrying.
  Check((Elapsed > RUNAWAY_TIMEOUT * 0.5) and (Elapsed < RUNAWAY_TIMEOUT * 3.0),
        Format('a runaway callback stops near its %d s deadline', [RUNAWAY_TIMEOUT]),
        Format('returned after %.2f s', [Elapsed], TFormatSettings.Invariant));
end;

procedure CheckTimeoutIsPerCall();
var
  Watch: TStopwatch;
  Calls, Bad: Integer;
  Got: Extended;
begin
  //Keep calling a short function until the wall clock is well past the limit.
  //Every call must still succeed, because each one gets its own stopwatch.
  Engine.ScriptTimeOut := RUNAWAY_TIMEOUT;
  Bad := 0;
  Calls := 0;
  Watch := TStopwatch.StartNew();
  while Watch.Elapsed.TotalSeconds < RUNAWAY_TIMEOUT * 1.5 do
  begin
    Got := CallFast(7);
    Inc(Calls);
    if Got <> 7 * EXPECTED_FACTOR then
      Inc(Bad);
  end;
  Watch.Stop();
  Check(Bad = 0,
        Format('%d call(s) over %.1f s, all inside a %d s per-call limit',
               [Calls, Watch.Elapsed.TotalSeconds, RUNAWAY_TIMEOUT],
               TFormatSettings.Invariant),
        Format('%d call(s) failed: the timeout is being accumulated across '
             + 'calls rather than measured per call', [Bad]));
end;

procedure CheckTimeoutIsNotExpensive();
var
  Off, On_, Ratio: Double;
begin
  //Warm both paths first so neither pays for the first-call effects.
  TimeFast(2000, 0);
  TimeFast(2000, DEVICE_TIMEOUT);

  Off := TimeFast(40000, 0);
  On_ := TimeFast(40000, DEVICE_TIMEOUT);
  Ratio := On_ / Off;

  //It was 1.70x on the machine that found it. 1.25 is loose enough that this
  //will not flake on a busy laptop and tight enough that putting a clock read
  //back on the instruction path fails here instead of on a phone.
  Check(Ratio < 1.25,
        Format('the timeout costs %.2fx when switched on, not 1.7x', [Ratio],
               TFormatSettings.Invariant),
        Format('%.1f ms off, %.1f ms on: something is reading the clock per '
             + 'instruction again', [Off, On_], TFormatSettings.Invariant));
end;

var
  ProbeSource: TStringList;
  Key: String;
  Known: String;
begin
  WriteLn('CallbackProbe - ExecuteFunction, the loop no .bas file can reach');
  WriteLn;

  GC := TGarbageCollector.Create();
  Engine := TBasicEngine.Create();
  Output := TStringList.Create();
  ProbeSource := TStringList.Create();
  try
    Engine.ScriptTimeOut := 0;
    StdLib.RegisterStdFuncs(Engine.Functions);
    NumLib.RegisterNumFuncs(Engine.Functions);
    StrLib.RegisterStrFuncs(Engine.Functions);
    ArrayLib.RegisterArrayFuncs(Engine.Functions);

    ProbeSource.Text := SOURCE;
    if Engine.Compile(ProbeSource) <> 0 then
    begin
      WriteLn(Format('  FAIL  the probe program does not compile: line %d, pos %d: %s',
        [Engine.ErrorLine, Engine.ErrorPos, Engine.ErrorMessage]));
      ExitCode := 1;
      Exit();
    end;
    Engine.ExecuteProgram(Output);

    //A signature the engine does not know would make every check below pass by
    //doing nothing at all: ExecuteUserFunction returns silently when the name
    //is not in the table. Say so loudly instead.
    Known := '';
    for Key in Engine.UserFunctions.Keys do
      Known := Known + ' ' + Key;
    if not Engine.UserFunctionExists(SIG_FAST) then
    begin
      WriteLn('  FAIL  no user function ' + SIG_FAST + '; known:' + Known);
      ExitCode := 1;
      Exit();
    end;
    if not Engine.UserFunctionExists(SIG_RUNAWAY) then
    begin
      WriteLn('  FAIL  no user function ' + SIG_RUNAWAY + '; known:' + Known);
      ExitCode := 1;
      Exit();
    end;

    CheckAnswers();
    CheckRunawayStops();
    CheckTimeoutIsPerCall();
    CheckTimeoutIsNotExpensive();
  finally
    ProbeSource.Free();
    Output.Free();
    Engine.Free();
    FreeAndNil(GC);
  end;

  WriteLn;
  if Failures = 0 then
    WriteLn(Format('%d check(s) passed', [Checks]))
  else
  begin
    WriteLn(Format('%d of %d check(s) failed', [Failures, Checks]));
    ExitCode := 1;
  end;
end.
