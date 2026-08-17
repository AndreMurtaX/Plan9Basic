{******************************************************************************
  TestLib - Assertion library for the Plan9Basic headless test runner

  Registers assert_* / test_* functions into the BASIC engine so that .bas
  files can act as self-checking test suites.

  Unlike the built-in ASSERT statement (which only fires when TRACE is on and
  halts the program on the first failure), these functions always evaluate,
  count passes and failures, and let execution continue so a single run
  reports every problem.

  Counters and the failure list are read by the runner after each file.
******************************************************************************}
unit TestLib;

interface

uses
  System.SysUtils, System.Classes, System.Math,
  exec, basic, HandleRegistry;

var
  AssertsPassed: Integer = 0;
  AssertsFailed: Integer = 0;
  Failures: TStringList = nil;
  CurrentCase: String = '';

//Registers the assertion functions. Eng is kept so failures can report the
//BASIC source line via Eng.Parser.exec.SourceLine.
procedure RegisterTestFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine);
//Clears counters, failure list and current case. Called between files.
procedure ResetTestState();

implementation

var
  ModuleEngine: TBasicEngine = nil;

//----------------------------------------------------------------------------
// Helpers
//----------------------------------------------------------------------------

function CurrentLine(): Integer;
begin
  Result := 0;
  if Assigned(ModuleEngine) and Assigned(ModuleEngine.Parser) and
     Assigned(ModuleEngine.Parser.exec) then
    Result := ModuleEngine.Parser.exec.SourceLine;
end;

//Locale-independent rendering, so failure messages read the same everywhere
function NumStr(const Value: Extended): String;
begin
  Result := FloatToStr(Value, TFormatSettings.Invariant);
end;

//Tolerant comparison: exact match first, then a relative epsilon so that
//accumulated floating point error does not produce spurious failures.
function NumEquals(const A, B: Extended): Boolean;
var
  Eps: Extended;
begin
  if A = B then
    Exit(True);
  Eps := 1E-12 * Max(1.0, Max(Abs(A), Abs(B)));
  Result := Abs(A - B) <= Eps;
end;

procedure RecordPass();
begin
  Inc(AssertsPassed);
end;

procedure RecordFail(const Msg: String);
var
  Where: String;
begin
  Inc(AssertsFailed);
  Where := 'line ' + IntToStr(CurrentLine());
  if CurrentCase <> '' then
    Where := CurrentCase + ' (' + Where + ')'
  else
    Where := '(' + Where + ')';
  if Assigned(Failures) then
    Failures.Add(Where + ': ' + Msg);
end;

//Applies a result, using Msg when supplied and a generated text otherwise
procedure Check(Ok: Boolean; const Msg, Generated: String);
begin
  if Ok then
    RecordPass()
  else if Msg <> '' then
    RecordFail(Msg + ' -- ' + Generated)
  else
    RecordFail(Generated);
end;

//----------------------------------------------------------------------------
// Bound functions
//----------------------------------------------------------------------------

function t_test_case(var Args: array of TAsmData): TAsmData;
begin
  CurrentCase := Args[0].s;
  Result.n := 1;
end;

function t_assert_true(var Args: array of TAsmData): TAsmData;
begin
  Check(Args[0].n <> 0, '', 'expected true, got false');
  Result.n := Ord(Args[0].n <> 0);
end;

function t_assert_true_msg(var Args: array of TAsmData): TAsmData;
begin
  Check(Args[0].n <> 0, Args[1].s, 'expected true, got false');
  Result.n := Ord(Args[0].n <> 0);
end;

function t_assert_false(var Args: array of TAsmData): TAsmData;
begin
  Check(Args[0].n = 0, '', 'expected false, got true');
  Result.n := Ord(Args[0].n = 0);
end;

function t_assert_false_msg(var Args: array of TAsmData): TAsmData;
begin
  Check(Args[0].n = 0, Args[1].s, 'expected false, got true');
  Result.n := Ord(Args[0].n = 0);
end;

function t_assert_eq_num(var Args: array of TAsmData): TAsmData;
var
  Ok: Boolean;
begin
  Ok := NumEquals(Args[0].n, Args[1].n);
  Check(Ok, '', 'expected ' + NumStr(Args[1].n) + ', got ' + NumStr(Args[0].n));
  Result.n := Ord(Ok);
end;

function t_assert_eq_num_msg(var Args: array of TAsmData): TAsmData;
var
  Ok: Boolean;
begin
  Ok := NumEquals(Args[0].n, Args[1].n);
  Check(Ok, Args[2].s, 'expected ' + NumStr(Args[1].n) + ', got ' + NumStr(Args[0].n));
  Result.n := Ord(Ok);
end;

function t_assert_eq_str(var Args: array of TAsmData): TAsmData;
var
  Ok: Boolean;
begin
  Ok := Args[0].s = Args[1].s;
  Check(Ok, '', 'expected "' + Args[1].s + '", got "' + Args[0].s + '"');
  Result.n := Ord(Ok);
end;

function t_assert_eq_str_msg(var Args: array of TAsmData): TAsmData;
var
  Ok: Boolean;
begin
  Ok := Args[0].s = Args[1].s;
  Check(Ok, Args[2].s, 'expected "' + Args[1].s + '", got "' + Args[0].s + '"');
  Result.n := Ord(Ok);
end;

function t_assert_near(var Args: array of TAsmData): TAsmData;
var
  Ok: Boolean;
begin
  Ok := Abs(Args[0].n - Args[1].n) <= Abs(Args[2].n);
  Check(Ok, '', 'expected ' + NumStr(Args[1].n) + ' +/- ' + NumStr(Args[2].n) +
               ', got ' + NumStr(Args[0].n));
  Result.n := Ord(Ok);
end;

function t_assert_near_msg(var Args: array of TAsmData): TAsmData;
var
  Ok: Boolean;
begin
  Ok := Abs(Args[0].n - Args[1].n) <= Abs(Args[2].n);
  Check(Ok, Args[3].s, 'expected ' + NumStr(Args[1].n) + ' +/- ' + NumStr(Args[2].n) +
                       ', got ' + NumStr(Args[0].n));
  Result.n := Ord(Ok);
end;

function t_test_fail(var Args: array of TAsmData): TAsmData;
begin
  RecordFail(Args[0].s);
  Result.n := 0;
end;

function t_test_passed(var Args: array of TAsmData): TAsmData;
begin
  Result.n := AssertsPassed;
end;

function t_test_failed(var Args: array of TAsmData): TAsmData;
begin
  Result.n := AssertsFailed;
end;

//----------------------------------------------------------------------------
// Probes for HandleRegistry
//
// The GUI libraries validate a BASIC pointer against the registry instead of
// dereferencing it. That property cannot be exercised headlessly through the
// GUI libraries themselves (they need a form and a message loop), so these
// two throwaway classes stand in for them and let the suite check the rules
// that matter: an unregistered address is never valid, a registered object is
// valid only as its own class, and freeing it takes the handle away.
//----------------------------------------------------------------------------

type
  TProbeA = class(TObject)
  public
    constructor Create();
    destructor Destroy(); override;
  end;

  TProbeB = class(TObject)
  public
    constructor Create();
    destructor Destroy(); override;
  end;

constructor TProbeA.Create();
begin
  inherited Create();
  RegisterHandle(Self);
end;

destructor TProbeA.Destroy();
begin
  UnregisterHandle(Self);
  inherited Destroy();
end;

constructor TProbeB.Create();
begin
  inherited Create();
  RegisterHandle(Self);
end;

destructor TProbeB.Destroy();
begin
  UnregisterHandle(Self);
  inherited Destroy();
end;

function t_probe_new_a(var Args: array of TAsmData): TAsmData;
begin
  Result.p := TProbeA.Create();
end;

function t_probe_new_b(var Args: array of TAsmData): TAsmData;
begin
  Result.p := TProbeB.Create();
end;

function t_probe_is_handle(var Args: array of TAsmData): TAsmData;
begin
  Result.n := Ord(IsHandle(Args[0].p));
end;

function t_probe_is_a(var Args: array of TAsmData): TAsmData;
begin
  Result.n := Ord(IsHandleOf(Args[0].p, TProbeA));
end;

function t_probe_is_b(var Args: array of TAsmData): TAsmData;
begin
  Result.n := Ord(IsHandleOf(Args[0].p, TProbeB));
end;

function t_probe_free(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  //Only free what the registry vouches for, otherwise this probe would itself
  //dereference an arbitrary pointer -- exactly the bug it exists to test.
  if IsHandle(Args[0].p) then
  begin
    TObject(Args[0].p).Free();
    Result.n := 1;
  end;
end;

function t_probe_count(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  if Assigned(Handles) then
    Result.n := Handles.Count;
end;

//----------------------------------------------------------------------------
// Registration
//----------------------------------------------------------------------------

procedure RegisterTestFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine);
var
  FnData: TLinkFunction;
begin
  ModuleEngine := Eng;
  FnData.FarCall := True;

  FnData.Entry := t_test_case;        Lib.Add('test_case@$', FnData);

  FnData.Entry := t_assert_true;      Lib.Add('assert_true@n', FnData);
  FnData.Entry := t_assert_true_msg;  Lib.Add('assert_true@n$', FnData);

  FnData.Entry := t_assert_false;     Lib.Add('assert_false@n', FnData);
  FnData.Entry := t_assert_false_msg; Lib.Add('assert_false@n$', FnData);

  FnData.Entry := t_assert_eq_num;     Lib.Add('assert_eq@nn', FnData);
  FnData.Entry := t_assert_eq_num_msg; Lib.Add('assert_eq@nn$', FnData);
  FnData.Entry := t_assert_eq_str;     Lib.Add('assert_eq@$$', FnData);
  FnData.Entry := t_assert_eq_str_msg; Lib.Add('assert_eq@$$$', FnData);

  FnData.Entry := t_assert_near;      Lib.Add('assert_near@nnn', FnData);
  FnData.Entry := t_assert_near_msg;  Lib.Add('assert_near@nnn$', FnData);

  FnData.Entry := t_test_fail;        Lib.Add('test_fail@$', FnData);
  FnData.Entry := t_test_passed;      Lib.Add('test_passed@', FnData);
  FnData.Entry := t_test_failed;      Lib.Add('test_failed@', FnData);

  //HandleRegistry probes
  FnData.Entry := t_probe_new_a;      Lib.Add('probe_new_a#@', FnData);
  FnData.Entry := t_probe_new_b;      Lib.Add('probe_new_b#@', FnData);
  FnData.Entry := t_probe_is_handle;  Lib.Add('probe_is_handle@#', FnData);
  FnData.Entry := t_probe_is_a;       Lib.Add('probe_is_a@#', FnData);
  FnData.Entry := t_probe_is_b;       Lib.Add('probe_is_b@#', FnData);
  FnData.Entry := t_probe_free;       Lib.Add('probe_free@#', FnData);
  FnData.Entry := t_probe_count;      Lib.Add('probe_count@', FnData);
end;

procedure ResetTestState();
begin
  AssertsPassed := 0;
  AssertsFailed := 0;
  CurrentCase := '';
  if Assigned(Failures) then
    Failures.Clear();
end;

initialization
  Failures := TStringList.Create();

finalization
  FreeAndNil(Failures);

end.
