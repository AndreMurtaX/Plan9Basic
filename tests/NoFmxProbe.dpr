{******************************************************************************
  NoFmxProbe - proves the engine no longer needs FireMonkey

  Links only the interpreter core and the non-GUI libraries, and runs a BASIC
  program. If this compiles, nothing in the core reaches for FMX: a missing
  unit is a compile error, not something that can slip through.

  It also exercises INPUT, which used to be hardwired to an FMX dialog and was
  therefore impossible outside a windowed host. Here the host reads stdin.

  Built by tests\build-nofmx.ps1, which passes an empty unit search path so
  even an accidental FMX reference cannot resolve.
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

    Source.Add('println "engine running with no FireMonkey linked"');
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
    Writeln('OK - no FMX');
  finally
    Host.Free();
    Source.Free();
    Output.Free();
    Engine.Free();
    FreeAndNil(GC);
  end;
end.
