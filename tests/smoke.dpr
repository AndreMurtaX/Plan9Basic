program smoke;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  UnitUtils in '..\UnitUtils.pas',
  lexer in '..\lexer.pas',
  exec in '..\exec.pas',
  parser in '..\parser.pas',
  basic in '..\basic.pas',
  UnitGC in '..\utils\UnitGC.pas',
  StdLib in '..\Libs\StdLib.pas',
  NumLib in '..\Libs\NumLib.pas',
  StrLib in '..\Libs\StrLib.pas';

var
  Engine: TBasicEngine;
  Output: TStringList;
  Source: TStringList;
  i, rc: Integer;
begin
  GC := TGarbageCollector.Create();
  Engine := TBasicEngine.Create();
  Output := TStringList.Create();
  Source := TStringList.Create();
  try
    StdLib.RegisterStdFuncs(Engine.Functions);
    NumLib.RegisterNumFuncs(Engine.Functions);
    StrLib.RegisterStrFuncs(Engine.Functions);

    Source.Add('println "hello from headless"');
    Source.Add('println "2+3="; 2+3');
    Source.Add('println ucase$("works")');

    rc := Engine.Compile(Source);
    if rc <> 0 then
    begin
      Writeln('COMPILE ERROR line ', Engine.ErrorLine, ': ', Engine.ErrorMessage);
      ExitCode := 1;
      Exit;
    end;

    Engine.ExecuteProgram(Output);
    for i := 0 to Output.Count - 1 do
      Writeln(Output[i]);
    Writeln('OK');
  finally
    Source.Free();
    Output.Free();
    Engine.Free();
    GC.Free();
  end;
end.
