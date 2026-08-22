{ How FireMonkey orders Align := Top siblings, measured three ways.

  A comment in UnitMain.pas claimed they stack in REVERSE order of creation.
  They do not, and the catalogue row appeared at the bottom of the file picker.
  The replacement claim -- list order, so Index := 0 lifts a row to the top --
  was a second guess. This probe measures instead of guessing a third time.

  The answer is neither: siblings are stacked by their current Position.Y, and
  the parent's child list breaks ties only. Every row the picker builds still
  has Y = 0 when the last is created, because that loop never turns the message
  queue, so the tie-break decides -- which is why Index := 0 works there.

  NOT PART OF verify.ps1, deliberately. FireMonkey runs no layout pass for a
  form with no window handle, so the form has to be shown for any of this to be
  measurable, and a verification run that flashes windows is one people stop
  trusting. Run it by hand when the question comes up again:

    dcc64 -B -NU<dir> -E<dir> AlignOrderProbe.dpr && AlignOrderProbe.exe }
program AlignOrderProbe;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Types, System.UITypes,
  FMX.Forms, FMX.Layouts, FMX.StdCtrls, FMX.Types, FMX.Controls;

var
  Form: TForm;

function NewBox(): TVertScrollBox;
begin
  Result := TVertScrollBox.Create(Form);
  Result.Parent := Form;
  Result.Align := TAlignLayout.Client;
  Result.Visible := True;
end;

function AddRow(ABox: TVertScrollBox; const AName: String): TSpeedButton;
begin
  Result := TSpeedButton.Create(ABox);
  Result.Parent := ABox;
  Result.Align := TAlignLayout.Top;
  Result.Height := 20;
  Result.Name := AName;
end;

procedure Pump();
var
  i: Integer;
begin
  for i := 1 to 20 do
  begin
    Application.ProcessMessages();
    Sleep(2);
  end;
end;

//Reported in the order the eye sees, smallest y first -- so the answer needs no
//arithmetic from whoever reads it.
procedure Report(ABox: TVertScrollBox; const ALabel: String);
var
  i, j, n: Integer;
  Ctl: array[0..15] of TControl;
  Tmp: TControl;
  Line: String;
begin
  n := ABox.Content.ControlsCount;
  for i := 0 to n - 1 do
    Ctl[i] := ABox.Content.Controls[i];
  for i := 0 to n - 2 do
    for j := 0 to n - 2 - i do
      if Ctl[j].Position.Y > Ctl[j + 1].Position.Y then
      begin
        Tmp := Ctl[j]; Ctl[j] := Ctl[j + 1]; Ctl[j + 1] := Tmp;
      end;
  Line := '';
  for i := 0 to n - 1 do
    Line := Line + Ctl[i].Name + ' ';
  Writeln(ALabel, Line);
end;

var
  Box: TVertScrollBox;
  Extra: TSpeedButton;
begin
  Application.Initialize();
  Form := TForm.CreateNew(nil);
  Form.SetBounds(0, 0, 300, 400);
  Form.Show();
  Pump();

  // (1) What the IDE did before the fix: rows, then the extra one last.
  Box := NewBox();
  AddRow(Box, 'fileA'); AddRow(Box, 'fileB'); AddRow(Box, 'fileC');
  AddRow(Box, 'EXTRA');
  Pump();
  Report(Box, '1 extra added last, untouched : ');
  Box.Visible := False;

  // (2) The fix that shipped: added last, then Index := 0.
  Box := NewBox();
  AddRow(Box, 'fileA'); AddRow(Box, 'fileB'); AddRow(Box, 'fileC');
  Extra := AddRow(Box, 'EXTRA');
  Extra.Index := 0;
  Pump();
  Report(Box, '2 extra added last, Index := 0: ');
  Box.Visible := False;

  // (3) The prediction: created first, before any of the rows exist.
  Box := NewBox();
  Extra := AddRow(Box, 'EXTRA');
  AddRow(Box, 'fileA'); AddRow(Box, 'fileB'); AddRow(Box, 'fileC');
  Pump();
  Report(Box, '3 extra created first        : ');
  Box.Visible := False;

  Form.Close();
  Writeln('');
  Writeln('left-to-right IS top-to-bottom on screen.');
end.
