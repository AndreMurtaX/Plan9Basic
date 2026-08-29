{ What it costs to uppercase the keywords on one line of a program.

  The IDE reformats the line you just left when you press ENTER. The question
  that prompted this was whether it could run whenever you leave a line by any
  means -- an arrow key, a mouse click -- without making the editor sluggish.

  Answering it needs the current cost measured rather than guessed, because the
  current implementation does not touch one line. EditorChange runs on EVERY
  keystroke and begins by copying the whole document out of the memo and walking
  it character by character to count the lines; when it decides a line break
  happened it splits the document into a TStringList, replaces one entry, joins
  it back and assigns the result to Editor.Text, which makes FireMonkey rebuild
  the layout of every line.

  So this measures three things against a document of a realistic size:

    1. UppercaseKeywords on one line, which is the actual work
    2. the document round trip the code does today
    3. assigning Editor.Lines[i], which touches one line

  NOT PART OF the verification run, for the same reason AlignOrderProbe is not:
  FireMonkey lays out nothing for a form with no window handle, so the form has
  to be shown for the memo timings to mean anything, and a check that flashes
  windows is one people stop trusting. Run it by hand:

    dcc64 -B -NU<dir> -E<dir> EditorFormatProbe.dpr && EditorFormatProbe.exe }
program EditorFormatProbe;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.Diagnostics, System.Types,
  System.UITypes, System.Character,
  FMX.Forms, FMX.Memo, FMX.Types, FMX.Controls, FMX.ScrollBox;

const
  //tractor.bas is about 1,200 lines and space_invaders.bas rather more. Two
  //sizes, because the whole question is how the cost grows with the document.
  SIZES: array[0..2] of Integer = (200, 1200, 5000);
  REPS = 200;

var
  Form: TForm;
  Memo: TMemo;

//A copy of the IDE's routine, so the measurement is of the real thing. Kept
//verbatim rather than tidied: a faster copy would answer a different question.
function IsKeyword(const W0: string): Boolean;
var
  W: string;
begin
  W := UpperCase(W0);
  Result :=
    (W = 'IF') or (W = 'DO') or (W = 'ON') or (W = 'OR') or (W = 'TO') or
    (W = 'AND') or (W = 'END') or (W = 'MOD') or (W = 'REM') or
    (W = 'CLS') or (W = 'LET') or (W = 'FOR') or (W = 'NOT') or
    (W = 'DATA') or (W = 'CALL') or (W = 'CASE') or (W = 'READ') or
    (W = 'ELSE') or (W = 'WEND') or (W = 'THEN') or (W = 'DUMP') or
    (W = 'GOTO') or (W = 'LOOP') or (W = 'NULL') or (W = 'STEP') or
    (W = 'NEXT') or (W = 'TRUE') or (W = 'BREAK') or (W = 'ENDIF') or
    (W = 'LOCAL') or (W = 'FALSE') or (W = 'TRACE') or (W = 'WATCH') or
    (W = 'WHILE') or (W = 'GOSUB') or (W = 'UNTIL') or (W = 'PRINT') or
    (W = 'INPUT') or (W = 'ENDFOR') or (W = 'SELECT') or (W = 'REPEAT') or
    (W = 'ASSERT') or (W = 'RETURN') or (W = 'TRACEON') or
    (W = 'UNWATCH') or (W = 'RESTORE') or (W = 'PRINTLN') or
    (W = 'TRACEOFF') or (W = 'ENDWHILE') or (W = 'CONTINUE') or
    (W = 'FUNCTION') or (W = 'ENDSELECT') or (W = 'BREAKPOINT') or
    (W = 'REFRESHRATE') or (W = 'ENDFUNCTION');
end;

function UppercaseKeywords(const Line: string): string;
var
  I, Len, WordStart: Integer;
  Ch: Char;
  Word: string;
  InString: Boolean;
  StringChar: Char;
begin
  Result := '';
  Len := Length(Line);
  I := 1;
  InString := False;
  StringChar := #0;
  while I <= Len do
  begin
    Ch := Line[I];
    if (not InString) and (Ch = '''') then
    begin
      Result := Result + Copy(Line, I, Len - I + 1);
      Exit();
    end;
    if (not InString) and (I + 2 <= Len) and
       (UpperCase(Copy(Line, I, 4)) = 'REM ') then
    begin
      Result := Result + 'REM' + Copy(Line, I + 3, Len - I - 2);
      Exit();
    end;
    if InString then
    begin
      Result := Result + Ch;
      if Ch = StringChar then InString := False;
      Inc(I);
      Continue;
    end;
    if (Ch = '"') then
    begin
      InString := True;
      StringChar := Ch;
      Result := Result + Ch;
      Inc(I);
      Continue;
    end;
    if CharInSet(Ch, ['A'..'Z', 'a'..'z', '_']) then
    begin
      WordStart := I;
      while (I <= Len) and CharInSet(Line[I], ['A'..'Z', 'a'..'z', '0'..'9', '_']) do
        Inc(I);
      Word := Copy(Line, WordStart, I - WordStart);
      if IsKeyword(Word) then
        Result := Result + UpperCase(Word)
      else
        Result := Result + Word;
      Continue;
    end;
    Result := Result + Ch;
    Inc(I);
  end;
end;

function BuildProgram(ALines: Integer): string;
var
  SL: TStringList;
  i: Integer;
begin
  SL := TStringList.Create();
  try
    for i := 1 to ALines do
      case i mod 5 of
        0: SL.Add('  if count > 0 then println "row " + str$(count)');
        1: SL.Add('  for j = 1 to 10');
        2: SL.Add('    total = total + j * 2');
        3: SL.Add('  next');
      else
        SL.Add('  rem a comment that the formatter copies as-is');
      end;
    Result := SL.Text;
  finally
    SL.Free();
  end;
end;

procedure Report(const AWhat: String; AMs: Double; AReps: Integer);
begin
  WriteLn(Format('    %-46s %9.4f ms/op', [AWhat, AMs / AReps],
                 TFormatSettings.Invariant));
end;

procedure Measure(ALines: Integer);
var
  Text, Line, Formatted: string;
  SL: TStringList;
  W: TStopwatch;
  i, n, CharCount: Integer;
begin
  Text := BuildProgram(ALines);
  Memo.Lines.Text := Text;
  Application.ProcessMessages();
  Line := Memo.Lines[ALines div 2];

  WriteLn(Format('  %d lines, %d characters', [ALines, Length(Text)]));

  //1. the work that actually has to happen
  W := TStopwatch.StartNew();
  for i := 1 to REPS do
    Formatted := UppercaseKeywords(Line);
  W.Stop();
  Report('UppercaseKeywords, one line', W.Elapsed.TotalMilliseconds, REPS);

  //2. reading the whole document out of the memo, which EditorChange does on
  //   every keystroke before it knows whether anything happened
  W := TStopwatch.StartNew();
  for i := 1 to REPS do
  begin
    Text := Memo.Text;
    CharCount := 0;
    for n := 1 to Length(Text) do
      if Text[n] = #10 then Inc(CharCount);
  end;
  W.Stop();
  Report('Memo.Text + counting lines (every keystroke)',
         W.Elapsed.TotalMilliseconds, REPS);

  //3. the document round trip on ENTER
  W := TStopwatch.StartNew();
  for i := 1 to REPS do
  begin
    SL := TStringList.Create();
    try
      SL.Text := Memo.Text;
      SL[ALines div 2] := Formatted;
      Memo.Text := SL.Text;
    finally
      SL.Free();
    end;
  end;
  W.Stop();
  Report('split, rejoin, assign Memo.Text (on ENTER)',
         W.Elapsed.TotalMilliseconds, REPS);

  //4. one line
  W := TStopwatch.StartNew();
  for i := 1 to REPS do
    Memo.Lines[ALines div 2] := Formatted;
  W.Stop();
  Report('Memo.Lines[i] := ... (one line)',
         W.Elapsed.TotalMilliseconds, REPS);

  WriteLn;
end;

var
  s: Integer;
begin
  Application.Initialize();
  Form := TForm.CreateNew(nil);
  try
    Form.SetBounds(0, 0, 800, 600);
    Memo := TMemo.Create(Form);
    Memo.Parent := Form;
    Memo.Align := TAlignLayout.Client;
    //FireMonkey lays out nothing without a window handle, so the memo has to be
    //real for any of these numbers to mean anything.
    Form.Show();
    Application.ProcessMessages();

    WriteLn('EditorFormatProbe - what the IDE pays to uppercase one line');
    WriteLn;
    for s := Low(SIZES) to High(SIZES) do
      Measure(SIZES[s]);
  finally
    Form.Free();
  end;
end.
