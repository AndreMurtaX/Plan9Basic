{******************************************************************************
  Plan9BasicBench - a stopwatch for the engine, in the tree

  The council that produced docs\ENGINE-COUNCIL-2026-08.md measured a great
  deal and left none of it reproducible: every figure in that document was
  taken on a machine we no longer have, against working copies that no longer
  exist. This program is step 0 of its own plan -- the instrument, committed,
  so the next person to claim a speedup has to show it here.

  Usage:
    Plan9BasicBench [options] [path ...]

    path          .bas file or directory (recursive). Defaults to .\bench
    --repeat N    run each benchmark N times and report the best (default 3).
                  The best, not the mean: a benchmark is a lower bound on what
                  the machine can do, and the slow runs are measuring Windows.
    --timeout N   the device timeout, in seconds, used for the second callback
                  column (default 30, which is what runner\AppletRunner.pas
                  sets). 0 disables that column.
    --calls N     override every file's bench-callback-calls
    --csv FILE    also append one row per benchmark, for tracking over time
    --quiet       the table only, no per-run detail

  Directives, read from `rem` lines at the top of each .bas file:

    rem bench-ops: N              how many units of work the program does, so
                                  the table can report a cost per operation.
                                  Without it the ns/op column is blank.
    rem bench-callback: sig@      after the program has run, call this user
                                  function repeatedly and time that instead.
                                  This is the ExecuteFunction path -- the one
                                  every OnTimer and OnClick takes, and the one
                                  the whole council failed to measure.
    rem bench-callback-calls: N   how many times (default 20000)

  Exit code: 0 if every benchmark ran, 1 if any failed to compile or run.

  Only the non-GUI libraries are registered. A benchmark that needs a form is
  measuring FireMonkey, not this engine.
******************************************************************************}
program Plan9BasicBench;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  System.IOUtils,
  System.Diagnostics,
  System.Math,
  System.Generics.Collections,
  UnitUtils in '..\engine\UnitUtils.pas',
  lexer in '..\engine\lexer.pas',
  exec in '..\engine\exec.pas',
  parser in '..\engine\parser.pas',
  basic in '..\engine\basic.pas',
  UnitGC in '..\engine\utils\UnitGC.pas',
  HandleRegistry in '..\engine\utils\HandleRegistry.pas',
  HostServices in '..\engine\utils\HostServices.pas',
  ArrayLib in '..\engine\Libs\ArrayLib.pas',
  DateTimeLib in '..\engine\Libs\DateTimeLib.pas',
  StdLib in '..\engine\Libs\StdLib.pas',
  NumLib in '..\engine\Libs\NumLib.pas',
  StrLib in '..\engine\Libs\StrLib.pas',
  SysLib in '..\engine\Libs\SysLib.pas',
  PlatformInfoLib in '..\engine\Libs\PlatformInfoLib.pas',
  DictLib in '..\Libs\DictLib.pas',
  ConfigLib in '..\engine\Libs\ConfigLib.pas',
  StrListLib in '..\Libs\StrListLib.pas',
  JsonLib in '..\engine\Libs\JsonLib.pas',
  RegexLib in '..\Libs\RegexLib.pas',
  Base64Lib in '..\engine\Libs\Base64Lib.pas',
  GzipLib in '..\Libs\GzipLib.pas',
  ZipLib in '..\engine\Libs\ZipLib.pas',
  IOUtilsLib in '..\Libs\IOUtilsLib.pas';

type
  //What a file asks the harness to do, read from its `rem bench-*` lines.
  TBenchSpec = record
    Ops: Int64;             //units of work, for the ns/op column; 0 = unknown
    Callback: String;       //user function signature; '' = time the program
    CallbackCalls: Integer;
  end;

  TBenchResult = record
    Name: String;
    Spec: TBenchSpec;
    CompileMs: Double;
    BestMs: Double;         //ExecuteProgram, or the callback loop at timeout 0
    WorstMs: Double;        //the slowest of the same runs, for the spread
    DeviceMs: Double;       //the callback loop at the device timeout; -1 = n/a
    Failed: Boolean;
    Detail: String;
  end;

var
  OptRepeat: Integer = 3;
  OptDeviceTimeout: Int64 = 30;
  OptCalls: Integer = 0;
  OptCsv: String = '';
  OptQuiet: Boolean = False;
  Results: TList<TBenchResult>;

//----------------------------------------------------------------------------
// Reading the directives
//----------------------------------------------------------------------------

function ReadSpec(Source: TStrings): TBenchSpec;
var
  i: Integer;
  Line, Value: String;

  //A directive is `rem <name>: <value>` and nothing else. Anchoring on `rem`
  //keeps the benchmarks ordinary BASIC: they still compile and run under
  //Plan9BasicTest, which is what stops them rotting.
  function Directive(const AName: String; out AValue: String): Boolean;
  var
    Head: String;
  begin
    Head := 'rem ' + AName + ':';
    Result := StartsText(Head, Line);
    if Result then
      AValue := Trim(Copy(Line, Length(Head) + 1, MaxInt));
  end;

begin
  Result.Ops := 0;
  Result.Callback := '';
  Result.CallbackCalls := 20000;
  for i := 0 to Source.Count - 1 do
  begin
    Line := TrimLeft(Source[i]);
    //Only the header block is scanned. A `rem bench-ops:` buried in the middle
    //of a program is a comment about the program, not an instruction to us.
    if (Line <> '') and (not StartsText('rem', Line)) then
      Break;
    if Directive('bench-ops', Value) then
      Result.Ops := StrToInt64Def(Value, 0)
    else if Directive('bench-callback', Value) then
      Result.Callback := Value
    else if Directive('bench-callback-calls', Value) then
      Result.CallbackCalls := StrToIntDef(Value, 20000);
  end;
  if OptCalls > 0 then
    Result.CallbackCalls := OptCalls;
end;

//----------------------------------------------------------------------------
// Running one benchmark
//----------------------------------------------------------------------------

procedure RegisterAll(Engine: TBasicEngine; Output: TStrings);
begin
  ArrayLib.RegisterArrayFuncs(Engine.Functions);
  DateTimeLib.RegisterDateTimeFuncs(Engine.Functions);
  StdLib.RegisterStdFuncs(Engine.Functions);
  NumLib.RegisterNumFuncs(Engine.Functions);
  StrLib.RegisterStrFuncs(Engine.Functions);
  SysLib.RegisterSysFuncs(Engine.Functions);
  PlatformInfoLib.RegisterPlatformInfoFuncs(Engine.Functions);
  DictLib.RegisterDictFuncs(Engine.Functions);
  ConfigLib.RegisterConfigFuncs(Engine.Functions);
  StrListLib.RegisterStringsFuncs(Engine.Functions, Engine, Output);
  JsonLib.RegisterJsonFuncs(Engine.Functions);
  RegexLib.RegisterRegexFuncs(Engine.Functions);
  Base64Lib.RegisterBase64Funcs(Engine.Functions);
  GzipLib.RegisterGzipFuncs(Engine.Functions);
  ZipLib.RegisterZipFuncs(Engine.Functions);
  IOUtilsLib.RegisterIOUtilsFuncs(Engine.Functions);
end;

//Calls the named user function ACalls times and returns the elapsed
//milliseconds. This is the ExecuteFunction loop, reached exactly the way a
//control callback reaches it.
function TimeCallbacks(Engine: TBasicEngine; Output: TStrings;
                       const ASignature: String; ACalls: Integer;
                       ATimeout: Int64): Double;
var
  Watch: TStopwatch;
  i: Integer;
  RetType: TExprKind;
  RetValue: TAsmData;
begin
  Engine.ScriptTimeOut := ATimeout;
  Watch := TStopwatch.StartNew();
  for i := 1 to ACalls do
    Engine.ExecuteUserFunction(Output, ASignature, [], RetType, RetValue);
  Watch.Stop();
  Result := Watch.Elapsed.TotalMilliseconds;
end;

//One compile-and-run of one file. Everything is torn down afterwards, in the
//order InitBASICEngine uses, so a run cannot inherit the previous one's heap.
function RunOnce(const FileName: String; const Spec: TBenchSpec;
                 out CompileMs, RunMs, DeviceMs: Double;
                 out Detail: String): Boolean;
var
  Engine: TBasicEngine;
  Output, Source: TStringList;
  Watch: TStopwatch;
begin
  Result := False;
  CompileMs := 0;
  RunMs := 0;
  DeviceMs := -1;
  Detail := '';

  GC := TGarbageCollector.Create();
  Engine := TBasicEngine.Create();
  Output := TStringList.Create();
  Source := TStringList.Create();
  try
    //A benchmark is not allowed to be stopped by the clock it is measuring.
    Engine.ScriptTimeOut := 0;
    RegisterAll(Engine, Output);

    try
      Source.LoadFromFile(FileName, TEncoding.UTF8);
    except
      on E: Exception do
      begin
        Detail := 'cannot read file: ' + E.Message;
        Exit();
      end;
    end;

    Watch := TStopwatch.StartNew();
    if Engine.Compile(Source) <> 0 then
    begin
      Detail := Format('line %d, pos %d: %s',
        [Engine.ErrorLine, Engine.ErrorPos, Engine.ErrorMessage]);
      Exit();
    end;
    Watch.Stop();
    CompileMs := Watch.Elapsed.TotalMilliseconds;

    try
      Watch := TStopwatch.StartNew();
      Engine.ExecuteProgram(Output);
      Watch.Stop();
      RunMs := Watch.Elapsed.TotalMilliseconds;
    except
      on E: Exception do
      begin
        Detail := Format('line %d: %s', [Engine.Parser.exec.SourceLine, E.Message]);
        Exit();
      end;
    end;

    if Engine.Parser.exec.ErrorMessage <> '' then
    begin
      Detail := Engine.Parser.exec.ErrorMessage;
      Exit();
    end;

    //With a callback named, the program above was only the setup: what we came
    //to measure is the second loop. Two columns on purpose -- the timeout is
    //off in the IDE and on for a device, and that difference is a real cost
    //nobody can see on the machine they develop on.
    if Spec.Callback <> '' then
    begin
      if not Engine.UserFunctionExists(Spec.Callback) then
      begin
        Detail := Format('no user function %s in this program', [Spec.Callback]);
        Exit();
      end;
      RunMs := TimeCallbacks(Engine, Output, Spec.Callback, Spec.CallbackCalls, 0);
      if OptDeviceTimeout > 0 then
        DeviceMs := TimeCallbacks(Engine, Output, Spec.Callback,
                                  Spec.CallbackCalls, OptDeviceTimeout);
    end;

    Result := True;
  finally
    Source.Free();
    Output.Free();
    Engine.Free();
    FreeAndNil(GC);
  end;
end;

function RunBenchmark(const FileName: String): TBenchResult;
var
  Source: TStringList;
  i: Integer;
  CompileMs, RunMs, DeviceMs: Double;
  Detail: String;
  Ok: Boolean;
begin
  Result := Default(TBenchResult);
  Result.Name := TPath.GetFileNameWithoutExtension(FileName);
  Result.BestMs := -1;
  Result.WorstMs := -1;
  Result.DeviceMs := -1;

  Source := TStringList.Create();
  try
    try
      Source.LoadFromFile(FileName, TEncoding.UTF8);
    except
      on E: Exception do
      begin
        Result.Failed := True;
        Result.Detail := 'cannot read file: ' + E.Message;
        Exit();
      end;
    end;
    Result.Spec := ReadSpec(Source);
  finally
    Source.Free();
  end;

  for i := 1 to OptRepeat do
  begin
    Ok := RunOnce(FileName, Result.Spec, CompileMs, RunMs, DeviceMs, Detail);
    if not Ok then
    begin
      Result.Failed := True;
      Result.Detail := Detail;
      Exit();
    end;
    if not OptQuiet then
      WriteLn(Format('    run %d/%d  %.2f ms', [i, OptRepeat, RunMs],
                     TFormatSettings.Invariant));
    if (Result.BestMs < 0) or (RunMs < Result.BestMs) then
    begin
      Result.BestMs := RunMs;
      Result.CompileMs := CompileMs;
    end;
    if RunMs > Result.WorstMs then
      Result.WorstMs := RunMs;
    if (DeviceMs >= 0) and ((Result.DeviceMs < 0) or (DeviceMs < Result.DeviceMs)) then
      Result.DeviceMs := DeviceMs;
  end;
end;

//----------------------------------------------------------------------------
// Reporting
//----------------------------------------------------------------------------

//How far apart the fastest and slowest runs of the same benchmark were, as a
//percentage of the fastest.
//
//This column exists because of a mistake made while using this harness: three
//runs of the callback benchmark differed by 5.8% between builds, and 3% of that
//was read as the cost of a change that turned out to cost nothing. A number
//without its spread invites exactly that. Anything smaller than this column is
//not a result.
function Spread(const R: TBenchResult): String;
begin
  if (R.BestMs <= 0) or (R.WorstMs <= R.BestMs) then
    Exit('0.0%');
  Result := Format('%.1f%%', [(R.WorstMs - R.BestMs) * 100.0 / R.BestMs],
                   TFormatSettings.Invariant);
end;

function NsPerOp(const R: TBenchResult; Ms: Double): String;
var
  Total: Int64;
begin
  //For a callback benchmark the work is ops-per-call times calls; for a plain
  //one it is ops. Getting this wrong would make the two kinds of row
  //incomparable, which is the only thing this column is for.
  if R.Spec.Ops <= 0 then
    Exit('');
  if R.Spec.Callback <> '' then
    Total := R.Spec.Ops * R.Spec.CallbackCalls
  else
    Total := R.Spec.Ops;
  if Total <= 0 then
    Exit('');
  Result := Format('%.1f', [Ms * 1000000.0 / Total], TFormatSettings.Invariant);
end;

procedure Report();
var
  R: TBenchResult;
  AnyDevice: Boolean;
begin
  AnyDevice := False;
  for R in Results do
    if R.DeviceMs >= 0 then
      AnyDevice := True;

  WriteLn;
  WriteLn(StringOfChar('-', 92));
  if AnyDevice then
    WriteLn(Format('%-22s %10s %12s %8s %10s %14s %8s',
      ['benchmark', 'compile', 'best', 'spread', 'ns/op', 'at timeout', 'cost']))
  else
    WriteLn(Format('%-22s %10s %12s %8s %10s',
      ['benchmark', 'compile', 'best', 'spread', 'ns/op']));
  WriteLn(StringOfChar('-', 92));

  for R in Results do
  begin
    if R.Failed then
    begin
      WriteLn(Format('%-22s %10s %12s', [R.Name, '-', 'FAILED']));
      WriteLn('    ! ' + R.Detail);
      Continue;
    end;
    //Invariant throughout: a decimal comma in one column and a thousands
    //comma in the next is a table nobody can read twice the same way.
    if R.DeviceMs >= 0 then
      WriteLn(Format('%-22s %10.2f %12.2f %8s %10s %14.2f %7.2fx',
        [R.Name, R.CompileMs, R.BestMs, Spread(R), NsPerOp(R, R.BestMs),
         R.DeviceMs, R.DeviceMs / Max(R.BestMs, 0.0001)],
        TFormatSettings.Invariant))
    else if AnyDevice then
      WriteLn(Format('%-22s %10.2f %12.2f %8s %10s %14s %8s',
        [R.Name, R.CompileMs, R.BestMs, Spread(R), NsPerOp(R, R.BestMs), '-', '-'],
        TFormatSettings.Invariant))
    else
      WriteLn(Format('%-22s %10.2f %12.2f %8s %10s',
        [R.Name, R.CompileMs, R.BestMs, Spread(R), NsPerOp(R, R.BestMs)],
        TFormatSettings.Invariant));
  end;
  WriteLn(StringOfChar('-', 92));
  WriteLn('best of ' + IntToStr(OptRepeat) + ' run(s); times in milliseconds.');
  WriteLn('"spread" is how far the slowest run of each benchmark was from the fastest.');
  WriteLn('A difference between two builds smaller than that is not a result.');
  if AnyDevice then
  begin
    WriteLn(Format('"at timeout" is the same loop with ScriptTimeOut = %d, the way '
      + 'runner\AppletRunner.pas', [OptDeviceTimeout]));
    WriteLn('sets it for a device. "cost" is what the clock check charges there.');
  end;
end;

procedure WriteCsv();
var
  F: TextFile;
  R: TBenchResult;
  Exists: Boolean;
begin
  Exists := TFile.Exists(OptCsv);
  AssignFile(F, OptCsv);
  try
    if Exists then Append(F) else Rewrite(F);
    if not Exists then
      WriteLn(F, 'benchmark,compile_ms,best_ms,worst_ms,device_ms,ops,calls');
    for R in Results do
      if not R.Failed then
        WriteLn(F, Format('%s,%.3f,%.3f,%.3f,%.3f,%d,%d',
          [R.Name, R.CompileMs, R.BestMs, R.WorstMs, R.DeviceMs, R.Spec.Ops,
           R.Spec.CallbackCalls], TFormatSettings.Invariant));
  finally
    CloseFile(F);
  end;
  WriteLn('appended to ' + OptCsv);
end;

//----------------------------------------------------------------------------
// Collecting the files
//----------------------------------------------------------------------------

procedure Collect(const APath: String; AInto: TStrings);
var
  Found: TArray<String>;
  S: String;
begin
  if TFile.Exists(APath) then
  begin
    AInto.Add(APath);
    Exit();
  end;
  if not TDirectory.Exists(APath) then
  begin
    WriteLn('no such file or directory: ' + APath);
    Exit();
  end;
  Found := TDirectory.GetFiles(APath, '*.bas', TSearchOption.soAllDirectories);
  TArray.Sort<String>(Found);
  for S in Found do
    AInto.Add(S);
end;

//----------------------------------------------------------------------------
// Main
//----------------------------------------------------------------------------

var
  Paths, Files: TStringList;
  i: Integer;
  Arg, F: String;
  R: TBenchResult;
  Failures: Integer;
begin
  Paths := TStringList.Create();
  Files := TStringList.Create();
  Results := TList<TBenchResult>.Create();
  try
    i := 1;
    while i <= ParamCount() do
    begin
      Arg := ParamStr(i);
      if Arg = '--repeat' then
      begin
        Inc(i);
        OptRepeat := Max(1, StrToIntDef(ParamStr(i), 3));
      end
      else if Arg = '--timeout' then
      begin
        Inc(i);
        OptDeviceTimeout := StrToInt64Def(ParamStr(i), 30);
      end
      else if Arg = '--calls' then
      begin
        Inc(i);
        OptCalls := StrToIntDef(ParamStr(i), 0);
      end
      else if Arg = '--csv' then
      begin
        Inc(i);
        OptCsv := ParamStr(i);
      end
      else if Arg = '--quiet' then
        OptQuiet := True
      else if StartsStr('--', Arg) then
      begin
        WriteLn('unknown option: ' + Arg);
        ExitCode := 2;
        Exit();
      end
      else
        Paths.Add(Arg);
      Inc(i);
    end;

    if Paths.Count = 0 then
      Paths.Add('bench');

    for Arg in Paths do
      Collect(Arg, Files);

    if Files.Count = 0 then
    begin
      WriteLn('nothing to run');
      ExitCode := 2;
      Exit();
    end;

    for F in Files do
    begin
      if not OptQuiet then
        WriteLn(TPath.GetFileName(F));
      Results.Add(RunBenchmark(F));
    end;

    Report();
    if OptCsv <> '' then
      WriteCsv();

    Failures := 0;
    for R in Results do
      if R.Failed then
        Inc(Failures);
    if Failures > 0 then
      ExitCode := 1;
  finally
    Results.Free();
    Files.Free();
    Paths.Free();
  end;
end.
