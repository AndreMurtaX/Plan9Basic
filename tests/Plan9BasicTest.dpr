{******************************************************************************
  Plan9BasicTest - headless test runner for Plan9Basic

  Compiles and executes .bas files with no IDE and no UI, then reports the
  assertions collected by TestLib.

  Usage:
    Plan9BasicTest [options] [path ...]

    path        .bas file or directory (recursive). Defaults to .\suite
    --smoke     only require that the file compiles and runs without a runtime
                error; do not require assertions. Turns the existing
                Examples/ and Demos/ programs into a regression net.
    --expect-fail
                invert the verdict: every file MUST fail. Used for the negative
                suite, where the point is that the engine rejects the program.
    --verbose   print each program's output, not just failures
    --timeout N script timeout in seconds per file (default 30, 0 = unlimited)

  Exit code: 0 all files passed, 1 one or more failed, 2 usage error.

  Only non-GUI libraries are registered: the GUI wrappers need an FMX form and
  a message loop, which a headless run does not have.
******************************************************************************}
program Plan9BasicTest;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  System.IOUtils,
  System.Diagnostics,
  System.Generics.Collections,
  UnitUtils in '..\UnitUtils.pas',
  lexer in '..\lexer.pas',
  exec in '..\exec.pas',
  parser in '..\parser.pas',
  basic in '..\basic.pas',
  UnitGC in '..\utils\UnitGC.pas',
  ArrayLib in '..\Libs\ArrayLib.pas',
  DateTimeLib in '..\Libs\DateTimeLib.pas',
  StdLib in '..\Libs\StdLib.pas',
  NumLib in '..\Libs\NumLib.pas',
  StrLib in '..\Libs\StrLib.pas',
  SysLib in '..\Libs\SysLib.pas',
  PlatformInfoLib in '..\Libs\PlatformInfoLib.pas',
  DictLib in '..\Libs\DictLib.pas',
  ConfigLib in '..\Libs\ConfigLib.pas',
  StrListLib in '..\Libs\StrListLib.pas',
  JsonLib in '..\Libs\JsonLib.pas',
  RegexLib in '..\Libs\RegexLib.pas',
  Base64Lib in '..\Libs\Base64Lib.pas',
  GzipLib in '..\Libs\GzipLib.pas',
  ZipLib in '..\Libs\ZipLib.pas',
  IOUtilsLib in '..\Libs\IOUtilsLib.pas',
  HttpLib in '..\Libs\HttpLib.pas',
  TestLib in 'TestLib.pas';

type
  TFileOutcome = (foPass, foCompileError, foRuntimeError, foAssertFailed,
                  foNoAsserts, foOutputFailure);

  TFileResult = record
    FileName: String;
    Outcome: TFileOutcome;
    Passed: Integer;
    Failed: Integer;
    Detail: String;
    Failures: TArray<String>;
    Output: String;
    ElapsedMs: Int64;
  end;

var
  OptSmoke: Boolean = False;
  OptVerbose: Boolean = False;
  OptExpectFail: Boolean = False;
  OptTimeout: Int64 = 30;

//Programs written before this runner existed report their own results by
//printing lines like "[FAIL] Test 3: ...". Without this check a file that
//printed nothing but failures would still be reported as passing in smoke
//mode, which is worse than not running it at all.
function OutputFailureLines(const Output: String): TArray<String>;
var
  Line: String;
  Collected: TStringList;
begin
  Collected := TStringList.Create();
  try
    for Line in Output.Split([sLineBreak]) do
      if Line.Contains('[FAIL]') or Line.Contains('[ASSERT FAILED]') then
        Collected.Add(Line.Trim());
    Result := Collected.ToStringArray();
  finally
    Collected.Free();
  end;
end;

//----------------------------------------------------------------------------
// Execution of a single file
//----------------------------------------------------------------------------

function RunFile(const FileName: String): TFileResult;
var
  Engine: TBasicEngine;
  Output, Source: TStringList;
  Watch: TStopwatch;
  RuntimeMsg: String;
begin
  Result := Default(TFileResult);
  Result.FileName := FileName;

  //Each file gets a fresh GC and engine so that state cannot leak between
  //tests. Teardown order mirrors InitBASICEngine: engine, then GC.
  GC := TGarbageCollector.Create();
  Engine := TBasicEngine.Create();
  Output := TStringList.Create();
  Source := TStringList.Create();
  Watch := TStopwatch.StartNew();
  try
    Engine.ScriptTimeOut := OptTimeout;

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
    HttpLib.RegisterHttpFuncs(Engine.Functions, Engine, Output);
    TestLib.RegisterTestFuncs(Engine.Functions, Engine);

    TestLib.ResetTestState();

    try
      Source.LoadFromFile(FileName, TEncoding.UTF8);
    except
      on E: Exception do
      begin
        Result.Outcome := foCompileError;
        Result.Detail := 'cannot read file: ' + E.Message;
        Exit();
      end;
    end;

    if Engine.Compile(Source) <> 0 then
    begin
      Result.Outcome := foCompileError;
      Result.Detail := Format('line %d, pos %d: %s',
        [Engine.ErrorLine, Engine.ErrorPos, Engine.ErrorMessage]);
      Exit();
    end;

    RuntimeMsg := '';
    try
      Engine.ExecuteProgram(Output);
    except
      on E: Exception do
        RuntimeMsg := Format('line %d: %s', [Engine.Parser.exec.SourceLine, E.Message]);
    end;

    //The VM also records recoverable runtime errors without raising
    if (RuntimeMsg = '') and (Engine.Parser.exec.ErrorMessage <> '') then
      RuntimeMsg := Engine.Parser.exec.ErrorMessage;

    Result.Passed := TestLib.AssertsPassed;
    Result.Failed := TestLib.AssertsFailed;
    Result.Failures := TestLib.Failures.ToStringArray();
    Result.Output := Output.Text;

    if RuntimeMsg <> '' then
    begin
      Result.Outcome := foRuntimeError;
      Result.Detail := RuntimeMsg;
    end
    else if Result.Failed > 0 then
      Result.Outcome := foAssertFailed
    else if Length(OutputFailureLines(Result.Output)) > 0 then
    begin
      Result.Outcome := foOutputFailure;
      Result.Failures := OutputFailureLines(Result.Output);
      Result.Detail := Format('%d self-reported failure(s) in the program output',
        [Length(Result.Failures)]);
    end
    else if (Result.Passed = 0) and (not OptSmoke) then
      Result.Outcome := foNoAsserts
    else
      Result.Outcome := foPass;
  finally
    Result.ElapsedMs := Watch.ElapsedMilliseconds;
    Source.Free();
    Output.Free();
    Engine.Free();
    FreeAndNil(GC);
  end;
end;

//----------------------------------------------------------------------------
// Reporting
//----------------------------------------------------------------------------

function OutcomeLabel(Outcome: TFileOutcome): String;
begin
  case Outcome of
    foPass:         Result := 'PASS';
    foCompileError: Result := 'COMPILE';
    foRuntimeError: Result := 'RUNTIME';
    foAssertFailed: Result := 'FAIL';
    foNoAsserts:    Result := 'EMPTY';
    foOutputFailure: Result := 'OUTPUT';
  else
    Result := '????';
  end;
end;

//A file counts as good when it passed, or -- under --expect-fail -- when it
//did not. The negative suite exists to prove the engine rejects things.
function FileSucceeded(const R: TFileResult): Boolean;
begin
  if OptExpectFail then
    Result := R.Outcome <> foPass
  else
    Result := R.Outcome = foPass;
end;

procedure ReportFile(const R: TFileResult; const BaseDir: String);
var
  Name, Line: String;
begin
  Name := R.FileName;
  if (BaseDir <> '') and Name.StartsWith(BaseDir) then
    Name := Name.Substring(BaseDir.Length).TrimLeft([PathDelim]);

  Writeln(Format('%-8s %-52s %4d ok %4d fail %6d ms',
    [OutcomeLabel(R.Outcome), Name, R.Passed, R.Failed, R.ElapsedMs]));

  //Under --expect-fail the detail is the evidence that the rejection happened
  //for the right reason, so it stays visible.
  if R.Detail <> '' then
    Writeln('         ! ' + R.Detail);

  if not OptExpectFail then
    for Line in R.Failures do
      Writeln('         - ' + Line);

  if OptExpectFail and (R.Outcome = foPass) then
    Writeln('         ! expected this file to be rejected, but it ran clean');

  if (not OptExpectFail) and (R.Outcome = foNoAsserts) then
    Writeln('         ! no assertions were executed (use --smoke to allow this)');

  if OptVerbose and (R.Output <> '') then
  begin
    Writeln('         --- output ---');
    for Line in R.Output.Split([sLineBreak]) do
      Writeln('         | ' + Line);
  end;
end;

//----------------------------------------------------------------------------
// Entry point
//----------------------------------------------------------------------------

procedure CollectFiles(const Path: String; Files: TStringList);
var
  Found: TArray<String>;
  F: String;
begin
  if TFile.Exists(Path) then
  begin
    Files.Add(TPath.GetFullPath(Path));
    Exit();
  end;

  if TDirectory.Exists(Path) then
  begin
    Found := TDirectory.GetFiles(Path, '*.bas', TSearchOption.soAllDirectories);
    for F in Found do
      Files.Add(TPath.GetFullPath(F));
    Exit();
  end;

  Writeln(ErrOutput, 'path not found: ' + Path);
end;

var
  Args, Paths, Files: TStringList;
  i: Integer;
  Arg, BaseDir: String;
  Results: TList<TFileResult>;
  R: TFileResult;
  TotalPassed, TotalFailed, FilesOk, FilesBad: Integer;
  Watch: TStopwatch;
begin
  //Headless: no message loop exists, so the VM must not pump one
  UnitGC.SkipProcessMessages := True;
  //Keep number formatting stable regardless of the machine's locale
  FormatSettings := TFormatSettings.Invariant;

  Args := TStringList.Create();
  Paths := TStringList.Create();
  Files := TStringList.Create();
  Results := TList<TFileResult>.Create();
  try
    for i := 1 to ParamCount do
      Args.Add(ParamStr(i));

    i := 0;
    while i < Args.Count do
    begin
      Arg := Args[i];
      if Arg = '--smoke' then
        OptSmoke := True
      else if Arg = '--verbose' then
        OptVerbose := True
      else if Arg = '--expect-fail' then
        OptExpectFail := True
      else if Arg = '--timeout' then
      begin
        Inc(i);
        if (i >= Args.Count) or not TryStrToInt64(Args[i], OptTimeout) then
        begin
          Writeln(ErrOutput, '--timeout requires a number of seconds');
          ExitCode := 2;
          Exit();
        end;
      end
      else if Arg.StartsWith('--') then
      begin
        Writeln(ErrOutput, 'unknown option: ' + Arg);
        ExitCode := 2;
        Exit();
      end
      else
        Paths.Add(Arg);
      Inc(i);
    end;

    if Paths.Count = 0 then
      Paths.Add('suite');

    for i := 0 to Paths.Count - 1 do
      CollectFiles(Paths[i], Files);

    if Files.Count = 0 then
    begin
      Writeln(ErrOutput, 'no .bas files found');
      ExitCode := 2;
      Exit();
    end;

    Files.Sort();

    //Trim the common root from reported names to keep the output readable
    BaseDir := TPath.GetFullPath(Paths[0]);
    if not TDirectory.Exists(BaseDir) then
      BaseDir := TPath.GetDirectoryName(BaseDir);

    Writeln(Format('Plan9Basic test runner - %d file(s)%s%s', [Files.Count,
      IfThen(OptSmoke, ' [smoke mode]', ''),
      IfThen(OptExpectFail, ' [expect-fail mode]', '')]));
    Writeln(StringOfChar('-', 92));

    Watch := TStopwatch.StartNew();
    for i := 0 to Files.Count - 1 do
    begin
      R := RunFile(Files[i]);
      Results.Add(R);
      ReportFile(R, BaseDir);
    end;

    TotalPassed := 0;
    TotalFailed := 0;
    FilesOk := 0;
    FilesBad := 0;
    for R in Results do
    begin
      Inc(TotalPassed, R.Passed);
      Inc(TotalFailed, R.Failed);
      if FileSucceeded(R) then Inc(FilesOk) else Inc(FilesBad);
    end;

    Writeln(StringOfChar('-', 92));
    Writeln(Format('%d file(s): %d passed, %d failed | %d assertion(s): %d ok, %d failed | %d ms',
      [Files.Count, FilesOk, FilesBad, TotalPassed + TotalFailed, TotalPassed,
       TotalFailed, Watch.ElapsedMilliseconds]));

    if FilesBad > 0 then
      ExitCode := 1
    else
      ExitCode := 0;
  finally
    Results.Free();
    Files.Free();
    Paths.Free();
    Args.Free();
  end;
end.
