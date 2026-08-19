{******************************************************************************
  NoFmxProbe - the engine core running in a console host

  Links the interpreter and the non-GUI libraries into a program with no form,
  no Application and no window, and runs BASIC through it. The host's PrintProc
  writes to stdout and its InputProc reads stdin, which is the point: INPUT used
  to be hardwired to an FMX dialog and was therefore impossible outside a
  windowed host.

  It does not prove the engine links without FireMonkey. It cannot: dcc64 finds
  the FMX .dcu files beside the RTL's, so an FMX reference resolves whatever the
  search path says, and this program links 58 FMX units by way of StdLib and
  StrLib. That boundary is checked by reading the uses clauses instead, in
  tools\check-fmx-boundary.py.

  Built by tests\build-nofmx.ps1.
******************************************************************************}
program NoFmxProbe;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  UnitUtils in '..\engine\UnitUtils.pas',
  lexer in '..\engine\lexer.pas',
  exec in '..\engine\exec.pas',
  parser in '..\engine\parser.pas',
  basic in '..\engine\basic.pas',
  UnitGC in '..\engine\utils\UnitGC.pas',
  HandleRegistry in '..\engine\utils\HandleRegistry.pas',
  ArrayLib in '..\engine\Libs\ArrayLib.pas',
  DateTimeLib in '..\engine\Libs\DateTimeLib.pas',
  StdLib in '..\engine\Libs\StdLib.pas',
  NumLib in '..\engine\Libs\NumLib.pas',
  StrLib in '..\engine\Libs\StrLib.pas',
  PlatformInfoLib in '..\engine\Libs\PlatformInfoLib.pas',
  ConfigLib in '..\engine\Libs\ConfigLib.pas',
  JsonLib in '..\engine\Libs\JsonLib.pas',
  Base64Lib in '..\engine\Libs\Base64Lib.pas',
  ZipLib in '..\engine\Libs\ZipLib.pas';

type
  //Console implementation of the three host interactions. This is the whole
  //cost of hosting the engine somewhere without a window.
  TConsoleHost = class(TObject)
  public
    procedure Input(const ACaption: String; const ALabels: array of String;
                    const ADefaults: array of String; const ADone: TInputDoneProc);
    procedure Confirm(const AMessage: String; const ADone: TConfirmDoneProc);
  end;

procedure TConsoleHost.Input(const ACaption: String; const ALabels: array of String;
  const ADefaults: array of String; const ADone: TInputDoneProc);
var
  Line: String;
  Values: TArray<String>;
begin
  Write(ACaption);
  if Length(ALabels) > 0 then
    Write(' ', ALabels[0]);
  Write(' ');
  ReadLn(Line);
  if (Line = '') and (Length(ADefaults) > 0) then
    Line := ADefaults[0];
  SetLength(Values, 1);
  Values[0] := Line;
  ADone(True, Values);
end;

procedure TConsoleHost.Confirm(const AMessage: String; const ADone: TConfirmDoneProc);
begin
  Writeln(AMessage);
  //Nobody to ask in a batch run: carry on.
  ADone(True);
end;

var
  Engine: TBasicEngine;
  Output, Source: TStringList;
  Host: TConsoleHost;
  i: Integer;
begin
  //No message loop here, so nothing to pump: YieldProc stays nil.
  UnitGC.SkipProcessMessages := True;

  GC := TGarbageCollector.Create();
  Engine := TBasicEngine.Create();
  Output := TStringList.Create();
  Source := TStringList.Create();
  Host := TConsoleHost.Create();
  try
    StdLib.RegisterStdFuncs(Engine.Functions);
    NumLib.RegisterNumFuncs(Engine.Functions);
    StrLib.RegisterStrFuncs(Engine.Functions);
    ArrayLib.RegisterArrayFuncs(Engine.Functions);
    DateTimeLib.RegisterDateTimeFuncs(Engine.Functions);
    PlatformInfoLib.RegisterPlatformInfoFuncs(Engine.Functions);
    ConfigLib.RegisterConfigFuncs(Engine.Functions);
    JsonLib.RegisterJsonFuncs(Engine.Functions);
    Base64Lib.RegisterBase64Funcs(Engine.Functions);
    ZipLib.RegisterZipFuncs(Engine.Functions);

    Engine.InputProc := Host.Input;
    Engine.ConfirmProc := Host.Confirm;

    Source.Add('println "engine running in a host with no window"');
    Source.Add('a# = dim#(3)');
    Source.Add('a#[1] = 21');
    Source.Add('println "array: "; narr_get(a#, 1) * 2');
    Source.Add('println "string: "; ucase$("works")');
    Source.Add('println "json: "; json_getn(json_parse#("{\"k\":7}"), "k")');

    if Engine.Compile(Source) <> 0 then
    begin
      Writeln('COMPILE ERROR line ', Engine.ErrorLine, ': ', Engine.ErrorMessage);
      ExitCode := 1;
      Exit();
    end;

    Engine.ExecuteProgram(Output);
    for i := 0 to Output.Count - 1 do
      Writeln(Output[i]);
    Writeln('OK - ran headless');
  finally
    Host.Free();
    Source.Free();
    Output.Free();
    Engine.Free();
    FreeAndNil(GC);
  end;
end.
