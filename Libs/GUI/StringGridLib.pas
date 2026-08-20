unit StringGridLib;

{ ******************************************************************************
  StringGridLib - StringGrid Control Library for Plan9Basic
  Version: 1.1.0

  Provides complete FireMonkey TStringGrid wrapper functionality for creating
  and managing grid controls in Plan9Basic programs.

  Function Count: 150+ functions

  COLUMN TYPES:
  =============
  0 = String   - Default text column
  1 = Check    - Checkbox column
  2 = Currency - Currency formatted numbers
  3 = Date     - Date values
  4 = Glyph    - Small bitmap icons
  5 = Image    - Image column
  6 = Popup    - Dropdown/combo list
  7 = Progress - Progress bar column
  8 = Time     - Time values

  TEXT ALIGNMENT:
  ===============
  0 = Center
  1 = Leading (Left for LTR)
  2 = Trailing (Right for LTR)

  SORT ORDER:
  ===========
  0 = Ascending
  1 = Descending

  NEW IN 1.1.0:
  =============
  - Row insertion/deletion at specific positions
  - Cell text alignment per column
  - Column sorting helpers (text and numeric)
  - Copy/paste (clipboard) support
  - CSV import/export functions

  Copyright (c) 2024-2025 Plan9Basic Project
  ****************************************************************************** }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Generics.Defaults, System.Math,
  System.Rtti, System.StrUtils,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Grid,
  FMX.Grid.Style, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Presentation.Factory, FMX.Platform,
  basic, exec, UnitGC, HandleRegistry, ControlCommon;

type
  TBasStringGrid = class(TStringGrid)
  private
    FOnCellClickFunc: String;
    FOnCellDblClickFunc: String;
    FOnSelectCellFunc: String;
    FOnSelChangedFunc: String;
    FOnEditingDoneFunc: String;
    FOnHeaderClickFunc: String;
    FOnClickFunc: String;
    FOnDblClickFunc: String;
    FOnEnterFunc: String;
    FOnExitFunc: String;
    FOnKeyDownFunc: String;
    FOnKeyUpFunc: String;
    FOnMouseDownFunc: String;
    FOnMouseUpFunc: String;
    FOnMouseMoveFunc: String;
    FOnMouseEnterFunc: String;
    FOnMouseLeaveFunc: String;
    FOnResizeFunc: String;
    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;
    FSuppressCallbacks: Boolean;

    procedure InternalOnCellClick(const Column: TColumn; const Row: Integer);
    procedure InternalOnCellDblClick(const Column: TColumn; const Row: Integer);
    procedure InternalOnSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
    procedure InternalOnSelChanged(Sender: TObject);
    procedure InternalOnEditingDone(Sender: TObject; const ACol, ARow: Integer);
    procedure InternalOnHeaderClick(Column: TColumn);
    procedure InternalOnClick(Sender: TObject);
    procedure InternalOnDblClick(Sender: TObject);
    procedure InternalOnEnter(Sender: TObject);
    procedure InternalOnExit(Sender: TObject);
    procedure InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseEnter(Sender: TObject);
    procedure InternalOnMouseLeave(Sender: TObject);
    procedure InternalOnResize(Sender: TObject);

    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
    function ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;

    procedure SetOnCellClickFunc(const Value: String);
    procedure SetOnCellDblClickFunc(const Value: String);
    procedure SetOnSelectCellFunc(const Value: String);
    procedure SetOnSelChangedFunc(const Value: String);
    procedure SetOnEditingDoneFunc(const Value: String);
    procedure SetOnHeaderClickFunc(const Value: String);
    procedure SetOnClickFunc(const Value: String);
    procedure SetOnDblClickFunc(const Value: String);
    procedure SetOnEnterFunc(const Value: String);
    procedure SetOnExitFunc(const Value: String);
    procedure SetOnKeyDownFunc(const Value: String);
    procedure SetOnKeyUpFunc(const Value: String);
    procedure SetOnMouseDownFunc(const Value: String);
    procedure SetOnMouseUpFunc(const Value: String);
    procedure SetOnMouseMoveFunc(const Value: String);
    procedure SetOnMouseEnterFunc(const Value: String);
    procedure SetOnMouseLeaveFunc(const Value: String);
    procedure SetOnResizeFunc(const Value: String);

  protected
    { Override to return parent class presenter name - CRITICAL for TPresentedControl }
    function DefinePresentationName: String; override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure DisconnectAllEvents();

    { Row operations }
    procedure InsertRow(AtIndex: Integer);
    procedure DeleteRow(AtIndex: Integer);
    procedure MoveRow(FromIndex, ToIndex: Integer);
    procedure SwapRows(Row1, Row2: Integer);
    procedure ClearRow(RowIndex: Integer);
    procedure CopyRow(FromRow, ToRow: Integer);

    { Sorting }
    procedure SortByColumn(ColIndex: Integer; Ascending: Boolean);
    procedure SortByColumnNumeric(ColIndex: Integer; Ascending: Boolean);

    { Clipboard }
    function CopyToClipboard: Boolean;
    function CopySelectionToClipboard: Boolean;
    function PasteFromClipboard: Boolean;
    function CopyCellToClipboard(Col, Row: Integer): Boolean;
    function PasteToCellFromClipboard(Col, Row: Integer): Boolean;

    { CSV }
    function ExportToCSV(const FileName: String; const Delimiter: Char; IncludeHeaders: Boolean): Boolean;
    function ImportFromCSV(const FileName: String; const Delimiter: Char; HasHeaders: Boolean): Boolean;
    function ToCSVString(const Delimiter: Char; IncludeHeaders: Boolean): String;
    function FromCSVString(const CSVData: String; const Delimiter: Char; HasHeaders: Boolean): Boolean;

    property OnCellClickFunc: String read FOnCellClickFunc write SetOnCellClickFunc;
    property OnCellDblClickFunc: String read FOnCellDblClickFunc write SetOnCellDblClickFunc;
    property OnSelectCellFunc: String read FOnSelectCellFunc write SetOnSelectCellFunc;
    property OnSelChangedFunc: String read FOnSelChangedFunc write SetOnSelChangedFunc;
    property OnEditingDoneFunc: String read FOnEditingDoneFunc write SetOnEditingDoneFunc;
    property OnHeaderClickFunc: String read FOnHeaderClickFunc write SetOnHeaderClickFunc;
    property OnClickFunc: String read FOnClickFunc write SetOnClickFunc;
    property OnDblClickFunc: String read FOnDblClickFunc write SetOnDblClickFunc;
    property OnEnterFunc: String read FOnEnterFunc write SetOnEnterFunc;
    property OnExitFunc: String read FOnExitFunc write SetOnExitFunc;
    property OnKeyDownFunc: String read FOnKeyDownFunc write SetOnKeyDownFunc;
    property OnKeyUpFunc: String read FOnKeyUpFunc write SetOnKeyUpFunc;
    property OnMouseDownFunc: String read FOnMouseDownFunc write SetOnMouseDownFunc;
    property OnMouseUpFunc: String read FOnMouseUpFunc write SetOnMouseUpFunc;
    property OnMouseMoveFunc: String read FOnMouseMoveFunc write SetOnMouseMoveFunc;
    property OnMouseEnterFunc: String read FOnMouseEnterFunc write SetOnMouseEnterFunc;
    property OnMouseLeaveFunc: String read FOnMouseLeaveFunc write SetOnMouseLeaveFunc;
    property OnResizeFunc: String read FOnResizeFunc write SetOnResizeFunc;
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
    property SuppressCallbacks: Boolean read FSuppressCallbacks write FSuppressCallbacks;
  end;

procedure RegisterStringGridFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  STRINGGRID_GC_TAG = 'BASIC_STRINGGRID';
  ERR_NONE = 0;
  ERR_INVALID_GRID = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INDEX_OUT_OF_RANGE = 5;
  ERR_INVALID_COLUMN = 6;
  ERR_INVALID_COLUMN_TYPE = 7;
  ERR_FILE_ERROR = 8;
  ERR_CLIPBOARD_ERROR = 9;
  ERR_CSV_ERROR = 10;

  COL_STRING = 0;
  COL_CHECK = 1;
  COL_CURRENCY = 2;
  COL_DATE = 3;
  COL_GLYPH = 4;
  COL_IMAGE = 5;
  COL_POPUP = 6;
  COL_PROGRESS = 7;
  COL_TIME = 8;


  TEXTALIGN_CENTER = 0;
  TEXTALIGN_LEADING = 1;
  TEXTALIGN_TRAILING = 2;

  SORT_ASCENDING = 0;
  SORT_DESCENDING = 1;

var
  lastError: Integer;
  lastErrorMsg: String;

  { Error handling }

procedure SetError(Code: Integer; const Msg: String);
begin
  lastError := Code;
  lastErrorMsg := Msg;
end;

procedure ClearError();
begin
  lastError := ERR_NONE;
  lastErrorMsg := '';
end;

{ Validation helpers }

function ValidateGrid(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_GRID, FuncName + ': Nil pointer');
    Exit();
  end;
  try
    if not(IsHandleOf(P, TBasStringGrid)) then
    begin
      SetError(ERR_INVALID_GRID, FuncName + ': Invalid object');
      Exit();
    end;
  except
    SetError(ERR_INVALID_GRID, FuncName + ': Invalid pointer');
    Exit();
  end;
  ClearError();
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
var
  M: String;
begin
  Result := ControlCommon.ParentIsValid(P, FuncName, M);
  if Result then
    ClearError()
  else
    SetError(ERR_INVALID_PARENT, M);
end;

function IntToTextAlign(Value: Integer): TTextAlign;
begin
  case Value of
    TEXTALIGN_CENTER: Result := TTextAlign.Center;
    TEXTALIGN_LEADING: Result := TTextAlign.Leading;
    TEXTALIGN_TRAILING: Result := TTextAlign.Trailing;
  else
    Result := TTextAlign.Center;
  end;
end;

function TextAlignToInt(Value: TTextAlign): Integer;
begin
  case Value of
    TTextAlign.Center: Result := TEXTALIGN_CENTER;
    TTextAlign.Leading: Result := TEXTALIGN_LEADING;
    TTextAlign.Trailing: Result := TEXTALIGN_TRAILING;
  else
    Result := TEXTALIGN_CENTER;
  end;
end;

{ CSV Helper functions }

function EscapeCSVField(const Field: String; Delimiter: Char): String;
var
  NeedsQuotes: Boolean;
begin
  NeedsQuotes := (Pos(Delimiter, Field) > 0) or (Pos('"', Field) > 0) or
                 (Pos(#13, Field) > 0) or (Pos(#10, Field) > 0);
  if NeedsQuotes then
    Result := '"' + StringReplace(Field, '"', '""', [rfReplaceAll]) + '"'
  else
    Result := Field;
end;

function UnescapeCSVField(const Field: String): String;
var
  S: String;
begin
  S := Field;
  if (Length(S) >= 2) and (S[1] = '"') and (S[Length(S)] = '"') then
  begin
    S := Copy(S, 2, Length(S) - 2);
    S := StringReplace(S, '""', '"', [rfReplaceAll]);
  end;
  Result := S;
end;

procedure ParseCSVLine(const Line: String; Delimiter: Char; Fields: TStrings);
var
  I: Integer;
  InQuotes: Boolean;
  Field: String;
begin
  Fields.Clear();
  if Line = '' then
    Exit();

  I := 1;
  InQuotes := False;
  Field := '';

  while I <= Length(Line) do
  begin
    if Line[I] = '"' then
    begin
      if InQuotes and (I < Length(Line)) and (Line[I + 1] = '"') then
      begin
        Field := Field + '"';
        Inc(I);
      end
      else
        InQuotes := not InQuotes;
    end
    else if (Line[I] = Delimiter) and not InQuotes then
    begin
      Fields.Add(Field);
      Field := '';
    end
    else
      Field := Field + Line[I];

    Inc(I);
  end;

  Fields.Add(Field);
end;

{ TBasStringGrid implementation }

constructor TBasStringGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);

  FOnCellClickFunc := '';
  FOnCellDblClickFunc := '';
  FOnSelectCellFunc := '';
  FOnSelChangedFunc := '';
  FOnEditingDoneFunc := '';
  FOnHeaderClickFunc := '';
  FOnClickFunc := '';
  FOnDblClickFunc := '';
  FOnEnterFunc := '';
  FOnExitFunc := '';
  FOnKeyDownFunc := '';
  FOnKeyUpFunc := '';
  FOnMouseDownFunc := '';
  FOnMouseUpFunc := '';
  FOnMouseMoveFunc := '';
  FOnMouseEnterFunc := '';
  FOnMouseLeaveFunc := '';
  FOnResizeFunc := '';
  FBasicEngine := nil;
  FConsoleOutput := nil;
  FSuppressCallbacks := False;
end;

destructor TBasStringGrid.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasStringGrid.DisconnectAllEvents();
begin
  Self.OnCellClick := nil;
  Self.OnCellDblClick := nil;
  Self.OnSelectCell := nil;
  Self.OnSelChanged := nil;
  Self.OnEditingDone := nil;
  Self.OnHeaderClick := nil;
  Self.OnClick := nil;
  Self.OnDblClick := nil;
  Self.OnEnter := nil;
  Self.OnExit := nil;
  Self.OnKeyDown := nil;
  Self.OnKeyUp := nil;
  Self.OnMouseDown := nil;
  Self.OnMouseUp := nil;
  Self.OnMouseMove := nil;
  Self.OnMouseEnter := nil;
  Self.OnMouseLeave := nil;
  Self.OnResize := nil;
end;

{ CRITICAL: Override DefinePresentationName for TPresentedControl subclass }
{ TStringGrid is a TPresentedControl. When subclassed, the framework doesn't }
{ automatically find the presenter. This override returns the parent class }
{ presenter name so the grid renders and functions correctly. }
function TBasStringGrid.DefinePresentationName: String;
begin
  Result := 'Grid-style';
end;

{ Row operations }

procedure TBasStringGrid.InsertRow(AtIndex: Integer);
var
  Col, Row: Integer;
  OldRowCount: Integer;
begin
  if AtIndex < 0 then
    AtIndex := 0;
  if AtIndex > RowCount then
    AtIndex := RowCount;

  OldRowCount := RowCount;
  RowCount := OldRowCount + 1;

  // Shift rows down
  for Row := OldRowCount - 1 downto AtIndex do
  begin
    for Col := 0 to ColumnCount - 1 do
      Cells[Col, Row + 1] := Cells[Col, Row];
  end;

  // Clear the new row
  for Col := 0 to ColumnCount - 1 do
    Cells[Col, AtIndex] := '';
end;

procedure TBasStringGrid.DeleteRow(AtIndex: Integer);
var
  Col, Row: Integer;
begin
  if (AtIndex < 0) or (AtIndex >= RowCount) then
    Exit();

  // Shift rows up
  for Row := AtIndex to RowCount - 2 do
  begin
    for Col := 0 to ColumnCount - 1 do
      Cells[Col, Row] := Cells[Col, Row + 1];
  end;

  RowCount := RowCount - 1;
end;

procedure TBasStringGrid.MoveRow(FromIndex, ToIndex: Integer);
var
  Col: Integer;
  TempRow: array of String;
  I: Integer;
begin
  if (FromIndex < 0) or (FromIndex >= RowCount) then
    Exit();
  if (ToIndex < 0) or (ToIndex >= RowCount) then
    Exit();
  if FromIndex = ToIndex then
    Exit();

  // Save source row
  SetLength(TempRow, ColumnCount);
  for Col := 0 to ColumnCount - 1 do
    TempRow[Col] := Cells[Col, FromIndex];

  // Shift rows
  if FromIndex < ToIndex then
  begin
    for I := FromIndex to ToIndex - 1 do
      for Col := 0 to ColumnCount - 1 do
        Cells[Col, I] := Cells[Col, I + 1];
  end
  else
  begin
    for I := FromIndex downto ToIndex + 1 do
      for Col := 0 to ColumnCount - 1 do
        Cells[Col, I] := Cells[Col, I - 1];
  end;

  // Place source row at destination
  for Col := 0 to ColumnCount - 1 do
    Cells[Col, ToIndex] := TempRow[Col];
end;

procedure TBasStringGrid.SwapRows(Row1, Row2: Integer);
var
  Col: Integer;
  Temp: String;
begin
  if (Row1 < 0) or (Row1 >= RowCount) then
    Exit();
  if (Row2 < 0) or (Row2 >= RowCount) then
    Exit();
  if Row1 = Row2 then
    Exit();

  for Col := 0 to ColumnCount - 1 do
  begin
    Temp := Cells[Col, Row1];
    Cells[Col, Row1] := Cells[Col, Row2];
    Cells[Col, Row2] := Temp;
  end;
end;

procedure TBasStringGrid.ClearRow(RowIndex: Integer);
var
  Col: Integer;
begin
  if (RowIndex < 0) or (RowIndex >= RowCount) then
    Exit();

  for Col := 0 to ColumnCount - 1 do
    Cells[Col, RowIndex] := '';
end;

procedure TBasStringGrid.CopyRow(FromRow, ToRow: Integer);
var
  Col: Integer;
begin
  if (FromRow < 0) or (FromRow >= RowCount) then
    Exit();
  if (ToRow < 0) or (ToRow >= RowCount) then
    Exit();

  for Col := 0 to ColumnCount - 1 do
    Cells[Col, ToRow] := Cells[Col, FromRow];
end;

{ Sorting }

procedure TBasStringGrid.SortByColumn(ColIndex: Integer; Ascending: Boolean);
var
  I, J: Integer;
  MinMax: Integer;
begin
  if (ColIndex < 0) or (ColIndex >= ColumnCount) then
    Exit();
  if RowCount <= 1 then
    Exit();

  // Simple selection sort for text
  for I := 0 to RowCount - 2 do
  begin
    MinMax := I;
    for J := I + 1 to RowCount - 1 do
    begin
      if Ascending then
      begin
        if CompareText(Cells[ColIndex, J], Cells[ColIndex, MinMax]) < 0 then
          MinMax := J;
      end
      else
      begin
        if CompareText(Cells[ColIndex, J], Cells[ColIndex, MinMax]) > 0 then
          MinMax := J;
      end;
    end;
    if MinMax <> I then
      SwapRows(I, MinMax);
  end;
end;

procedure TBasStringGrid.SortByColumnNumeric(ColIndex: Integer; Ascending: Boolean);
var
  I, J: Integer;
  MinMax: Integer;
  Val1, Val2: Extended;
begin
  if (ColIndex < 0) or (ColIndex >= ColumnCount) then
    Exit();
  if RowCount <= 1 then
    Exit();

  // Simple selection sort for numbers
  for I := 0 to RowCount - 2 do
  begin
    MinMax := I;
    for J := I + 1 to RowCount - 1 do
    begin
      Val1 := StrToFloatDef(Cells[ColIndex, J], 0);
      Val2 := StrToFloatDef(Cells[ColIndex, MinMax], 0);
      if Ascending then
      begin
        if Val1 < Val2 then
          MinMax := J;
      end
      else
      begin
        if Val1 > Val2 then
          MinMax := J;
      end;
    end;
    if MinMax <> I then
      SwapRows(I, MinMax);
  end;
end;

{ Clipboard operations }

function TBasStringGrid.CopyToClipboard: Boolean;
var
  SB: TStringBuilder;
  Col, Row: Integer;
  ClipService: IFMXClipboardService;
begin
  Result := False;
  if not TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, ClipService) then
    Exit();

  SB := TStringBuilder.Create();
  try
    // Add headers
    for Col := 0 to ColumnCount - 1 do
    begin
      if Col > 0 then
        SB.Append(#9);
      SB.Append(Columns[Col].Header);
    end;
    SB.AppendLine();

    // Add data
    for Row := 0 to RowCount - 1 do
    begin
      for Col := 0 to ColumnCount - 1 do
      begin
        if Col > 0 then
          SB.Append(#9);
        SB.Append(Cells[Col, Row]);
      end;
      SB.AppendLine();
    end;

    ClipService.SetClipboard(SB.ToString());
    Result := True;
  finally
    SB.Free();
  end;
end;

function TBasStringGrid.CopySelectionToClipboard: Boolean;
var
  ClipService: IFMXClipboardService;
  SelCol, SelRow: Integer;
begin
  Result := False;
  if not TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, ClipService) then
    Exit();

  SelCol := Self.Col;
  SelRow := Self.Row;

  if (SelCol >= 0) and (SelCol < ColumnCount) and (SelRow >= 0) and (SelRow < RowCount) then
  begin
    ClipService.SetClipboard(Cells[SelCol, SelRow]);
    Result := True;
  end;
end;

function TBasStringGrid.PasteFromClipboard: Boolean;
var
  ClipService: IFMXClipboardService;
  ClipValue: TValue;
  ClipText: String;
  Lines: TStringList;
  Fields: TStringList;
  Row, Col, I: Integer;
begin
  Result := False;
  if not TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, ClipService) then
    Exit();

  ClipValue := ClipService.GetClipboard();
  if not ClipValue.TryAsType<String>(ClipText) then
    Exit();

  Lines := TStringList.Create();
  Fields := TStringList.Create();
  try
    Lines.Text := ClipText;
    Row := Self.Row;
    if Row < 0 then
      Row := 0;

    for I := 0 to Lines.Count - 1 do
    begin
      if Row >= RowCount then
        RowCount := Row + 1;

      ParseCSVLine(Lines[I], #9, Fields);
      for Col := 0 to Min(Fields.Count - 1, ColumnCount - 1) do
        Cells[Col, Row] := Fields[Col];

      Inc(Row);
    end;

    Result := True;
  finally
    Fields.Free();
    Lines.Free();
  end;
end;

function TBasStringGrid.CopyCellToClipboard(Col, Row: Integer): Boolean;
var
  ClipService: IFMXClipboardService;
begin
  Result := False;
  if not TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, ClipService) then
    Exit();

  if (Col < 0) or (Col >= ColumnCount) or (Row < 0) or (Row >= RowCount) then
    Exit();

  ClipService.SetClipboard(Cells[Col, Row]);
  Result := True;
end;

function TBasStringGrid.PasteToCellFromClipboard(Col, Row: Integer): Boolean;
var
  ClipService: IFMXClipboardService;
  ClipValue: TValue;
  ClipText: String;
begin
  Result := False;
  if not TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, ClipService) then
    Exit();

  if (Col < 0) or (Col >= ColumnCount) or (Row < 0) or (Row >= RowCount) then
    Exit();

  ClipValue := ClipService.GetClipboard();
  if ClipValue.TryAsType<String>(ClipText) then
  begin
    // Take only first line if multiline
    if Pos(#13, ClipText) > 0 then
      ClipText := Copy(ClipText, 1, Pos(#13, ClipText) - 1);
    if Pos(#10, ClipText) > 0 then
      ClipText := Copy(ClipText, 1, Pos(#10, ClipText) - 1);

    Cells[Col, Row] := ClipText;
    Result := True;
  end;
end;

{ CSV operations }

function TBasStringGrid.ExportToCSV(const FileName: String; const Delimiter: Char; IncludeHeaders: Boolean): Boolean;
var
  SL: TStringList;
  CSVData: String;
begin
  Result := False;
  CSVData := ToCSVString(Delimiter, IncludeHeaders);

  SL := TStringList.Create();
  try
    SL.Text := CSVData;
    try
      SL.SaveToFile(FileName, TEncoding.UTF8);
      Result := True;
    except
      on E: Exception do
        SetError(ERR_FILE_ERROR, 'ExportToCSV: ' + E.Message);
    end;
  finally
    SL.Free();
  end;
end;

function TBasStringGrid.ImportFromCSV(const FileName: String; const Delimiter: Char; HasHeaders: Boolean): Boolean;
var
  SL: TStringList;
begin
  Result := False;

  if not FileExists(FileName) then
  begin
    SetError(ERR_FILE_ERROR, 'ImportFromCSV: File not found');
    Exit();
  end;

  SL := TStringList.Create();
  try
    try
      SL.LoadFromFile(FileName, TEncoding.UTF8);
      Result := FromCSVString(SL.Text, Delimiter, HasHeaders);
    except
      on E: Exception do
        SetError(ERR_FILE_ERROR, 'ImportFromCSV: ' + E.Message);
    end;
  finally
    SL.Free();
  end;
end;

function TBasStringGrid.ToCSVString(const Delimiter: Char; IncludeHeaders: Boolean): String;
var
  SB: TStringBuilder;
  Col, Row: Integer;
begin
  SB := TStringBuilder.Create();
  try
    // Add headers
    if IncludeHeaders then
    begin
      for Col := 0 to ColumnCount - 1 do
      begin
        if Col > 0 then
          SB.Append(Delimiter);
        SB.Append(EscapeCSVField(Columns[Col].Header, Delimiter));
      end;
      SB.AppendLine();
    end;

    // Add data
    for Row := 0 to RowCount - 1 do
    begin
      for Col := 0 to ColumnCount - 1 do
      begin
        if Col > 0 then
          SB.Append(Delimiter);
        SB.Append(EscapeCSVField(Cells[Col, Row], Delimiter));
      end;
      if Row < RowCount - 1 then
        SB.AppendLine();
    end;

    Result := SB.ToString();
  finally
    SB.Free();
  end;
end;

function TBasStringGrid.FromCSVString(const CSVData: String; const Delimiter: Char; HasHeaders: Boolean): Boolean;
var
  Lines: TStringList;
  Fields: TStringList;
  Row, Col, StartLine: Integer;
begin
  //Result := False;

  Lines := TStringList.Create();
  Fields := TStringList.Create();
  try
    Lines.Text := CSVData;

    if Lines.Count = 0 then
    begin
      RowCount := 0;
      Result := True;
      Exit();
    end;

    StartLine := 0;

    // Handle headers
    if HasHeaders then
    begin
      ParseCSVLine(Lines[0], Delimiter, Fields);
      // Update column headers if columns exist
      for Col := 0 to Min(Fields.Count - 1, ColumnCount - 1) do
        Columns[Col].Header := UnescapeCSVField(Fields[Col]);
      StartLine := 1;
    end;

    // Import data
    RowCount := Lines.Count - StartLine;
    for Row := 0 to RowCount - 1 do
    begin
      ParseCSVLine(Lines[Row + StartLine], Delimiter, Fields);
      for Col := 0 to Min(Fields.Count - 1, ColumnCount - 1) do
        Cells[Col, Row] := UnescapeCSVField(Fields[Col]);
    end;

    Result := True;
  finally
    Fields.Free();
    Lines.Free();
  end;
end;

{ Event property setters }

procedure TBasStringGrid.SetOnCellClickFunc(const Value: String);
begin
  FOnCellClickFunc := Value;
  if Value <> '' then
    Self.OnCellClick := InternalOnCellClick
  else
    Self.OnCellClick := nil;
end;

procedure TBasStringGrid.SetOnCellDblClickFunc(const Value: String);
begin
  FOnCellDblClickFunc := Value;
  if Value <> '' then
    Self.OnCellDblClick := InternalOnCellDblClick
  else
    Self.OnCellDblClick := nil;
end;

procedure TBasStringGrid.SetOnSelectCellFunc(const Value: String);
begin
  FOnSelectCellFunc := Value;
  if Value <> '' then
    Self.OnSelectCell := InternalOnSelectCell
  else
    Self.OnSelectCell := nil;
end;

procedure TBasStringGrid.SetOnSelChangedFunc(const Value: String);
begin
  FOnSelChangedFunc := Value;
  if Value <> '' then
    Self.OnSelChanged := InternalOnSelChanged
  else
    Self.OnSelChanged := nil;
end;

procedure TBasStringGrid.SetOnEditingDoneFunc(const Value: String);
begin
  FOnEditingDoneFunc := Value;
  if Value <> '' then
    Self.OnEditingDone := InternalOnEditingDone
  else
    Self.OnEditingDone := nil;
end;

procedure TBasStringGrid.SetOnHeaderClickFunc(const Value: String);
begin
  FOnHeaderClickFunc := Value;
  if Value <> '' then
    Self.OnHeaderClick := InternalOnHeaderClick
  else
    Self.OnHeaderClick := nil;
end;

procedure TBasStringGrid.SetOnClickFunc(const Value: String);
begin
  ControlCommon.BindClick(Self, Value, FOnClickFunc, InternalOnClick);
end;

procedure TBasStringGrid.SetOnDblClickFunc(const Value: String);
begin
  ControlCommon.BindDblClick(Self, Value, FOnDblClickFunc, InternalOnDblClick);
end;

procedure TBasStringGrid.SetOnEnterFunc(const Value: String);
begin
  ControlCommon.BindEnter(Self, Value, FOnEnterFunc, InternalOnEnter);
end;

procedure TBasStringGrid.SetOnExitFunc(const Value: String);
begin
  ControlCommon.BindExit(Self, Value, FOnExitFunc, InternalOnExit);
end;

procedure TBasStringGrid.SetOnKeyDownFunc(const Value: String);
begin
  ControlCommon.BindKeyDown(Self, Value, FOnKeyDownFunc, InternalOnKeyDown);
end;

procedure TBasStringGrid.SetOnKeyUpFunc(const Value: String);
begin
  ControlCommon.BindKeyUp(Self, Value, FOnKeyUpFunc, InternalOnKeyUp);
end;

procedure TBasStringGrid.SetOnMouseDownFunc(const Value: String);
begin
  ControlCommon.BindMouseDown(Self, Value, FOnMouseDownFunc, InternalOnMouseDown);
end;

procedure TBasStringGrid.SetOnMouseUpFunc(const Value: String);
begin
  ControlCommon.BindMouseUp(Self, Value, FOnMouseUpFunc, InternalOnMouseUp);
end;

procedure TBasStringGrid.SetOnMouseMoveFunc(const Value: String);
begin
  ControlCommon.BindMouseMove(Self, Value, FOnMouseMoveFunc, InternalOnMouseMove);
end;

procedure TBasStringGrid.SetOnMouseEnterFunc(const Value: String);
begin
  ControlCommon.BindMouseEnter(Self, Value, FOnMouseEnterFunc, InternalOnMouseEnter);
end;

procedure TBasStringGrid.SetOnMouseLeaveFunc(const Value: String);
begin
  ControlCommon.BindMouseLeave(Self, Value, FOnMouseLeaveFunc, InternalOnMouseLeave);
end;

procedure TBasStringGrid.SetOnResizeFunc(const Value: String);
begin
  ControlCommon.BindResize(Self, Value, FOnResizeFunc, InternalOnResize);
end;

{ Callback execution }

procedure TBasStringGrid.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'StringGrid');
end;

function TBasStringGrid.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
begin
  Result := ControlCommon.RunCallbackWithResult(FBasicEngine, FConsoleOutput,
                          FuncSignature, Args, 'StringGrid');
end;

{ Internal event handlers }

procedure TBasStringGrid.InternalOnCellClick(const Column: TColumn; const Row: Integer);
var
  Args: array [0 .. 2] of TAsmData;
  ColIdx: Integer;
begin
  if FOnCellClickFunc = '' then
    Exit();
  if Column = nil then
    ColIdx := -1
  else
    ColIdx := Column.Index;

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := ColIdx;
  Args[1].P := nil;
  Args[1].s := '';
  Args[2].n := Row;
  Args[2].P := nil;
  Args[2].s := '';

  ExecuteCallback(LowerCase(FOnCellClickFunc) + '@#nn', Args);
end;

procedure TBasStringGrid.InternalOnCellDblClick(const Column: TColumn; const Row: Integer);
var
  Args: array [0 .. 2] of TAsmData;
  ColIdx: Integer;
begin
  if FOnCellDblClickFunc = '' then
    Exit();
  if Column = nil then
    ColIdx := -1
  else
    ColIdx := Column.Index;

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := ColIdx;
  Args[1].P := nil;
  Args[1].s := '';
  Args[2].n := Row;
  Args[2].P := nil;
  Args[2].s := '';

  ExecuteCallback(LowerCase(FOnCellDblClickFunc) + '@#nn', Args);
end;

procedure TBasStringGrid.InternalOnSelectCell(Sender: TObject; const ACol, ARow: Integer; var CanSelect: Boolean);
var
  Args: array [0 .. 2] of TAsmData;
  RetVal: TAsmData;
begin
  if FOnSelectCellFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := ACol;
  Args[1].P := nil;
  Args[1].s := '';
  Args[2].n := ARow;
  Args[2].P := nil;
  Args[2].s := '';

  RetVal := ExecuteCallbackWithResult(LowerCase(FOnSelectCellFunc) + '@#nn', Args);
  CanSelect := (RetVal.n <> 0);
end;

procedure TBasStringGrid.InternalOnSelChanged(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnSelChangedFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnSelChangedFunc) + '@#', Args);
end;

procedure TBasStringGrid.InternalOnEditingDone(Sender: TObject; const ACol, ARow: Integer);
var
  Args: array [0 .. 2] of TAsmData;
begin
  if FOnEditingDoneFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := ACol;
  Args[1].P := nil;
  Args[1].s := '';
  Args[2].n := ARow;
  Args[2].P := nil;
  Args[2].s := '';

  ExecuteCallback(LowerCase(FOnEditingDoneFunc) + '@#nn', Args);
end;

procedure TBasStringGrid.InternalOnHeaderClick(Column: TColumn);
var
  Args: array [0 .. 1] of TAsmData;
  ColIdx: Integer;
begin
  if FOnHeaderClickFunc = '' then
    Exit();
  if Column = nil then
    ColIdx := -1
  else
    ColIdx := Column.Index;

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := ColIdx;
  Args[1].P := nil;
  Args[1].s := '';

  ExecuteCallback(LowerCase(FOnHeaderClickFunc) + '@#n', Args);
end;

procedure TBasStringGrid.InternalOnClick(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnClickFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnClickFunc) + '@#', Args);
end;

procedure TBasStringGrid.InternalOnDblClick(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnDblClickFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnDblClickFunc) + '@#', Args);
end;

procedure TBasStringGrid.InternalOnEnter(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnEnterFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnEnterFunc) + '@#', Args);
end;

procedure TBasStringGrid.InternalOnExit(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnExitFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnExitFunc) + '@#', Args);
end;

procedure TBasStringGrid.InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array [0 .. 2] of TAsmData;
begin
  if FOnKeyDownFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Key;
  Args[1].P := nil;
  Args[1].s := '';
  Args[2].n := Ord(KeyChar);
  Args[2].P := nil;
  Args[2].s := '';

  ExecuteCallback(LowerCase(FOnKeyDownFunc) + '@#nn', Args);
end;

procedure TBasStringGrid.InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array [0 .. 2] of TAsmData;
begin
  if FOnKeyUpFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Key;
  Args[1].P := nil;
  Args[1].s := '';
  Args[2].n := Ord(KeyChar);
  Args[2].P := nil;
  Args[2].s := '';

  ExecuteCallback(LowerCase(FOnKeyUpFunc) + '@#nn', Args);
end;

procedure TBasStringGrid.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array [0 .. 3] of TAsmData;
begin
  if FOnMouseDownFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Ord(Button);
  Args[1].P := nil;
  Args[1].s := '';
  Args[2].n := X;
  Args[2].P := nil;
  Args[2].s := '';
  Args[3].n := Y;
  Args[3].P := nil;
  Args[3].s := '';

  ExecuteCallback(LowerCase(FOnMouseDownFunc) + '@#nnn', Args);
end;

procedure TBasStringGrid.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array [0 .. 3] of TAsmData;
begin
  if FOnMouseUpFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Ord(Button);
  Args[1].P := nil;
  Args[1].s := '';
  Args[2].n := X;
  Args[2].P := nil;
  Args[2].s := '';
  Args[3].n := Y;
  Args[3].P := nil;
  Args[3].s := '';

  ExecuteCallback(LowerCase(FOnMouseUpFunc) + '@#nnn', Args);
end;

procedure TBasStringGrid.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array [0 .. 2] of TAsmData;
begin
  if FOnMouseMoveFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := X;
  Args[1].P := nil;
  Args[1].s := '';
  Args[2].n := Y;
  Args[2].P := nil;
  Args[2].s := '';

  ExecuteCallback(LowerCase(FOnMouseMoveFunc) + '@#nn', Args);
end;

procedure TBasStringGrid.InternalOnMouseEnter(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnMouseEnterFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnMouseEnterFunc) + '@#', Args);
end;

procedure TBasStringGrid.InternalOnMouseLeave(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnMouseLeaveFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnMouseLeaveFunc) + '@#', Args);
end;

procedure TBasStringGrid.InternalOnResize(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnResizeFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnResizeFunc) + '@#', Args);
end;

{ ============================================================================
  EXPORTED FUNCTIONS
  ============================================================================ }

{ Error functions }

function n_stringgrid_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.P := nil;
  Result.s := '';
end;

function s_stringgrid_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := lastErrorMsg;
end;

function s_stringgrid_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  case Trunc(Args[0].n) of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_GRID: Result.s := 'Invalid grid';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Create failed';
    ERR_INDEX_OUT_OF_RANGE: Result.s := 'Index out of range';
    ERR_INVALID_COLUMN: Result.s := 'Invalid column';
    ERR_INVALID_COLUMN_TYPE: Result.s := 'Invalid column type';
    ERR_FILE_ERROR: Result.s := 'File error';
    ERR_CLIPBOARD_ERROR: Result.s := 'Clipboard error';
    ERR_CSV_ERROR: Result.s := 'CSV error';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_stringgrid_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  ClearError();
end;

{ Creation and destruction }

function p_stringgrid_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateParent(Args[0].P, 'stringgrid#') then
    Exit();
  try
    SG := TBasStringGrid.Create(nil);
    SG.Parent := TFmxObject(Args[0].P);
    SG.Position.X := 0;
    SG.Position.Y := 0;
    SG.Width := 300;
    SG.Height := 200;
    SG.RowCount := 0;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(SG, Eng, Outp) then
    begin
      SG.BasicEngine := Eng;
      SG.ConsoleOutput := Outp;
    end;
    Result.P := Pointer(SG);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(SG, STRINGGRID_GC_TAG + '_' + IntToStr(NativeInt(Result.P)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'stringgrid#: ' + E.Message);
  end;
end;

function p_stringgrid_new_pos(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateParent(Args[0].P, 'stringgrid#') then
    Exit();
  try
    SG := TBasStringGrid.Create(nil);
    SG.Parent := TFmxObject(Args[0].P);
    SG.Position.X := Args[1].n;
    SG.Position.Y := Args[2].n;
    SG.Width := Args[3].n;
    SG.Height := Args[4].n;
    SG.RowCount := 0;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(SG, Eng, Outp) then
    begin
      SG.BasicEngine := Eng;
      SG.ConsoleOutput := Outp;
    end;
    Result.P := Pointer(SG);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(SG, STRINGGRID_GC_TAG + '_' + IntToStr(NativeInt(Result.P)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'stringgrid#: ' + E.Message);
  end;
end;

function n_stringgrid_free(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_free') then
    Exit();
  try
    SG := TBasStringGrid(Args[0].P);
    SG.DisconnectAllEvents();
    SG.Free();

    // Use GC to properly free the control
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(STRINGGRID_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
    //Its eighty-one siblings answer 1 on success. This one did too, inside
    //the collector block that was commented out.
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_GRID, 'stringgrid_free: ' + E.Message);
  end;
end;

{ Row and Column Count }

function n_stringgrid_rowcount_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_rowcount') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Result.n := SG.RowCount;
  ClearError();
end;

function p_stringgrid_rowcount_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_rowcount#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  SG.RowCount := Trunc(Args[1].n);
  ClearError();
end;

function n_stringgrid_colcount(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_colcount') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Result.n := SG.ColumnCount;
  ClearError();
end;

{ Column Management }

function p_stringgrid_addcolumn(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Col: TColumn;
  ColType: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_addcolumn#') then
    Exit();
  try
    SG := TBasStringGrid(Args[0].P);
    ColType := Trunc(Args[2].n);
    case ColType of
      COL_STRING: Col := TStringColumn.Create(SG);
      COL_CHECK: Col := TCheckColumn.Create(SG);
      COL_CURRENCY: Col := TCurrencyColumn.Create(SG);
      COL_DATE: Col := TDateColumn.Create(SG);
      COL_GLYPH: Col := TGlyphColumn.Create(SG);
      COL_IMAGE: Col := TImageColumn.Create(SG);
      COL_POPUP: Col := TPopupColumn.Create(SG);
      COL_PROGRESS: Col := TProgressColumn.Create(SG);
      COL_TIME: Col := TTimeColumn.Create(SG);
    else
      SetError(ERR_INVALID_COLUMN_TYPE, 'Invalid column type');
      Exit;
    end;
    Col.Header := Args[1].s;
    Col.Width := Args[3].n;
    SG.AddObject(Col);
    Result.P := Pointer(Col);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'stringgrid_addcolumn#: ' + E.Message);
  end;
end;

function n_stringgrid_deletecolumn(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_deletecolumn') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  SG.Columns[Idx].Free;
  Result.n := 1;
  ClearError();
end;

function n_stringgrid_clearcolumns(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_clearcolumns') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  SG.ClearColumns;
  Result.n := 1;
  ClearError();
end;

function p_stringgrid_column(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_column#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  Result.P := Pointer(SG.Columns[Idx]);
  ClearError();
end;

{ Column Properties }

function s_stringgrid_columnheader_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_columnheader$') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  Result.s := SG.Columns[Idx].Header;
  ClearError();
end;

function p_stringgrid_columnheader_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_columnheader#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  SG.Columns[Idx].Header := Args[2].s;
  ClearError();
end;

function n_stringgrid_columnwidth_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_columnwidth') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  Result.n := SG.Columns[Idx].Width;
  ClearError();
end;

function p_stringgrid_columnwidth_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_columnwidth#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  SG.Columns[Idx].Width := Args[2].n;
  ClearError();
end;

function n_stringgrid_columnvisible_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_columnvisible') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  if SG.Columns[Idx].Visible then
    Result.n := 1
  else
    Result.n := 0;
  ClearError();
end;

function p_stringgrid_columnvisible_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_columnvisible#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  SG.Columns[Idx].Visible := Args[2].n <> 0;
  ClearError();
end;

function n_stringgrid_columnreadonly_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_columnreadonly') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  if SG.Columns[Idx].ReadOnly then
    Result.n := 1
  else
    Result.n := 0;
  ClearError();
end;

function p_stringgrid_columnreadonly_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_columnreadonly#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  SG.Columns[Idx].ReadOnly := Args[2].n <> 0;
  ClearError();
end;

function n_stringgrid_columntype(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Col: TColumn;
  Idx: Integer;
begin
  Result.n := -1;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_columntype') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  Col := SG.Columns[Idx];
  if Col is TStringColumn then
    Result.n := COL_STRING
  else if Col is TCheckColumn then
    Result.n := COL_CHECK
  else if Col is TCurrencyColumn then
    Result.n := COL_CURRENCY
  else if Col is TDateColumn then
    Result.n := COL_DATE
  else if Col is TGlyphColumn then
    Result.n := COL_GLYPH
  else if Col is TImageColumn then
    Result.n := COL_IMAGE
  else if Col is TPopupColumn then
    Result.n := COL_POPUP
  else if Col is TProgressColumn then
    Result.n := COL_PROGRESS
  else if Col is TTimeColumn then
    Result.n := COL_TIME
  else
    Result.n := -1;
  ClearError();
end;

{ Cell Access }

function s_stringgrid_cell_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Col, Row: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_cell$') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Col := Trunc(Args[1].n);
  Row := Trunc(Args[2].n);
  if (Col < 0) or (Col >= SG.ColumnCount) or (Row < 0) or (Row >= SG.RowCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  Result.s := SG.Cells[Col, Row];
  ClearError();
end;

function p_stringgrid_cell_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Col, Row: Integer;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_cell#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Col := Trunc(Args[1].n);
  Row := Trunc(Args[2].n);
  if (Col < 0) or (Col >= SG.ColumnCount) or (Row < 0) or (Row >= SG.RowCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  SG.Cells[Col, Row] := Args[3].s;
  ClearError();
end;

function n_stringgrid_cellcheck_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Col, Row: Integer;
  Value: String;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_cellcheck') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Col := Trunc(Args[1].n);
  Row := Trunc(Args[2].n);
  if (Col < 0) or (Col >= SG.ColumnCount) or (Row < 0) or (Row >= SG.RowCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  Value := LowerCase(SG.Cells[Col, Row]);
  if (Value = 'true') or (Value = '1') or (Value = 'yes') then
    Result.n := 1
  else
    Result.n := 0;
  ClearError();
end;

function p_stringgrid_cellcheck_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Col, Row: Integer;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_cellcheck#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Col := Trunc(Args[1].n);
  Row := Trunc(Args[2].n);
  if (Col < 0) or (Col >= SG.ColumnCount) or (Row < 0) or (Row >= SG.RowCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  if Args[3].n <> 0 then
    SG.Cells[Col, Row] := 'True'
  else
    SG.Cells[Col, Row] := 'False';
  ClearError();
end;

function n_stringgrid_cellnum_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Col, Row: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_cellnum') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Col := Trunc(Args[1].n);
  Row := Trunc(Args[2].n);
  if (Col < 0) or (Col >= SG.ColumnCount) or (Row < 0) or (Row >= SG.RowCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  Result.n := StrToFloatDef(SG.Cells[Col, Row], 0);
  ClearError();
end;

function p_stringgrid_cellnum_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Col, Row: Integer;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_cellnum#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Col := Trunc(Args[1].n);
  Row := Trunc(Args[2].n);
  if (Col < 0) or (Col >= SG.ColumnCount) or (Row < 0) or (Row >= SG.RowCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  SG.Cells[Col, Row] := FloatToStr(Args[3].n);
  ClearError();
end;

function n_stringgrid_cellprogress_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Col, Row: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_cellprogress') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Col := Trunc(Args[1].n);
  Row := Trunc(Args[2].n);
  if (Col < 0) or (Col >= SG.ColumnCount) or (Row < 0) or (Row >= SG.RowCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  Result.n := StrToFloatDef(SG.Cells[Col, Row], 0);
  ClearError();
end;

function p_stringgrid_cellprogress_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Col, Row: Integer;
  Value: Extended;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_cellprogress#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Col := Trunc(Args[1].n);
  Row := Trunc(Args[2].n);
  Value := Args[3].n;
  if (Col < 0) or (Col >= SG.ColumnCount) or (Row < 0) or (Row >= SG.RowCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  if Value < 0 then
    Value := 0;
  if Value > 100 then
    Value := 100;
  SG.Cells[Col, Row] := FloatToStr(Value);
  ClearError();
end;

{ Row Height }

function n_stringgrid_rowheight_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_rowheight') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Result.n := SG.RowHeight;
  ClearError();
end;

function p_stringgrid_rowheight_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_rowheight#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  SG.RowHeight := Args[1].n;
  ClearError();
end;

{ Row Operations - NEW }

function n_stringgrid_insertrow(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_insertrow') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  SG.InsertRow(Trunc(Args[1].n));
  Result.n := 1;
  ClearError();
end;

function n_stringgrid_deleterow(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_deleterow') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.RowCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  SG.DeleteRow(Idx);
  Result.n := 1;
  ClearError();
end;

function n_stringgrid_moverow(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  FromIdx, ToIdx: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_moverow') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  FromIdx := Trunc(Args[1].n);
  ToIdx := Trunc(Args[2].n);
  if (FromIdx < 0) or (FromIdx >= SG.RowCount) or (ToIdx < 0) or (ToIdx >= SG.RowCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  SG.MoveRow(FromIdx, ToIdx);
  Result.n := 1;
  ClearError();
end;

function n_stringgrid_swaprows(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Row1, Row2: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_swaprows') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Row1 := Trunc(Args[1].n);
  Row2 := Trunc(Args[2].n);
  if (Row1 < 0) or (Row1 >= SG.RowCount) or (Row2 < 0) or (Row2 >= SG.RowCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  SG.SwapRows(Row1, Row2);
  Result.n := 1;
  ClearError();
end;

function n_stringgrid_clearrow(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_clearrow') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.RowCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  SG.ClearRow(Idx);
  Result.n := 1;
  ClearError();
end;

function n_stringgrid_copyrow(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  FromRow, ToRow: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_copyrow') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  FromRow := Trunc(Args[1].n);
  ToRow := Trunc(Args[2].n);
  if (FromRow < 0) or (FromRow >= SG.RowCount) or (ToRow < 0) or (ToRow >= SG.RowCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  SG.CopyRow(FromRow, ToRow);
  Result.n := 1;
  ClearError();
end;

{ Sorting - NEW }

function n_stringgrid_sort(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  ColIdx: Integer;
  Ascending: Boolean;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_sort') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  ColIdx := Trunc(Args[1].n);
  Ascending := Args[2].n = 0;
  if (ColIdx < 0) or (ColIdx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Column index out of range');
    Exit;
  end;
  SG.SortByColumn(ColIdx, Ascending);
  Result.n := 1;
  ClearError();
end;

function n_stringgrid_sortnum(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  ColIdx: Integer;
  Ascending: Boolean;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_sortnum') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  ColIdx := Trunc(Args[1].n);
  Ascending := Args[2].n = 0;
  if (ColIdx < 0) or (ColIdx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Column index out of range');
    Exit;
  end;
  SG.SortByColumnNumeric(ColIdx, Ascending);
  Result.n := 1;
  ClearError();
end;

{ Column Text Alignment - NEW }

function n_stringgrid_columnalign_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_columnalign') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  Result.n := TextAlignToInt(SG.Columns[Idx].HorzAlign);
  ClearError();
end;

function p_stringgrid_columnalign_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_columnalign#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  SG.Columns[Idx].HorzAlign := IntToTextAlign(Trunc(Args[2].n));
  SG.Repaint;  // Force visual update
  ClearError();
end;

{ Clipboard - NEW }

function n_stringgrid_copy(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_copy') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if SG.CopyToClipboard() then
    Result.n := 1
  else
    SetError(ERR_CLIPBOARD_ERROR, 'Failed to copy to clipboard');
end;

function n_stringgrid_copysel(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_copysel') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if SG.CopySelectionToClipboard() then
    Result.n := 1
  else
    SetError(ERR_CLIPBOARD_ERROR, 'Failed to copy selection');
end;

function n_stringgrid_paste(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_paste') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if SG.PasteFromClipboard() then
    Result.n := 1
  else
    SetError(ERR_CLIPBOARD_ERROR, 'Failed to paste from clipboard');
end;

function n_stringgrid_copycell(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_copycell') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if SG.CopyCellToClipboard(Trunc(Args[1].n), Trunc(Args[2].n)) then
    Result.n := 1
  else
    SetError(ERR_CLIPBOARD_ERROR, 'Failed to copy cell');
end;

function n_stringgrid_pastecell(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_pastecell') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if SG.PasteToCellFromClipboard(Trunc(Args[1].n), Trunc(Args[2].n)) then
    Result.n := 1
  else
    SetError(ERR_CLIPBOARD_ERROR, 'Failed to paste to cell');
end;

{ CSV - NEW }

function n_stringgrid_exportcsv(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Delimiter: Char;
  IncludeHeaders: Boolean;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_exportcsv') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if Length(Args[2].s) > 0 then
    Delimiter := Args[2].s[1]
  else
    Delimiter := ',';
  IncludeHeaders := Args[3].n <> 0;
  if SG.ExportToCSV(Args[1].s, Delimiter, IncludeHeaders) then
    Result.n := 1;
end;

function n_stringgrid_importcsv(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Delimiter: Char;
  HasHeaders: Boolean;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_importcsv') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if Length(Args[2].s) > 0 then
    Delimiter := Args[2].s[1]
  else
    Delimiter := ',';
  HasHeaders := Args[3].n <> 0;
  if SG.ImportFromCSV(Args[1].s, Delimiter, HasHeaders) then
    Result.n := 1;
end;

function s_stringgrid_tocsv(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Delimiter: Char;
  IncludeHeaders: Boolean;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_tocsv$') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if Length(Args[1].s) > 0 then
    Delimiter := Args[1].s[1]
  else
    Delimiter := ',';
  IncludeHeaders := Args[2].n <> 0;
  Result.s := SG.ToCSVString(Delimiter, IncludeHeaders);
  ClearError();
end;

function n_stringgrid_fromcsv(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Delimiter: Char;
  HasHeaders: Boolean;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_fromcsv') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if Length(Args[2].s) > 0 then
    Delimiter := Args[2].s[1]
  else
    Delimiter := ',';
  HasHeaders := Args[3].n <> 0;
  if SG.FromCSVString(Args[1].s, Delimiter, HasHeaders) then
    Result.n := 1;
end;

{ Selection }

function n_stringgrid_col_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := -1;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_col') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Result.n := SG.Col;
  ClearError();
end;

function p_stringgrid_col_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_col#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  SG.Col := Trunc(Args[1].n);
  ClearError();
end;

function n_stringgrid_row_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := -1;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_row') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Result.n := SG.Row;
  ClearError();
end;

function p_stringgrid_row_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_row#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  SG.Row := Trunc(Args[1].n);
  ClearError();
end;

function p_stringgrid_selectcell(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_selectcell#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  SG.SelectCell(Trunc(Args[1].n), Trunc(Args[2].n));
  ClearError();
end;

{ Grid Options }

function n_stringgrid_showhdr_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_showhdr') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if TGridOption.Header in SG.Options then
    Result.n := 1
  else
    Result.n := 0;
  ClearError();
end;

function p_stringgrid_showhdr_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_showhdr#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if Args[1].n <> 0 then
    SG.Options := SG.Options + [TGridOption.Header]
  else
    SG.Options := SG.Options - [TGridOption.Header];
  ClearError();
end;

function n_stringgrid_editing_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_editing') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if TGridOption.Editing in SG.Options then
    Result.n := 1
  else
    Result.n := 0;
  ClearError();
end;

function p_stringgrid_editing_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_editing#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if Args[1].n <> 0 then
    SG.Options := SG.Options + [TGridOption.Editing]
  else
    SG.Options := SG.Options - [TGridOption.Editing];
  ClearError();
end;

function n_stringgrid_altcolors_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_altcolors') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if TGridOption.AlternatingRowBackground in SG.Options then
    Result.n := 1
  else
    Result.n := 0;
  ClearError();
end;

function p_stringgrid_altcolors_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_altcolors#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if Args[1].n <> 0 then
    SG.Options := SG.Options + [TGridOption.AlternatingRowBackground]
  else
    SG.Options := SG.Options - [TGridOption.AlternatingRowBackground];
  ClearError();
end;

function n_stringgrid_colresize_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_colresize') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if TGridOption.ColumnResize in SG.Options then
    Result.n := 1
  else
    Result.n := 0;
  ClearError();
end;

function p_stringgrid_colresize_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_colresize#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if Args[1].n <> 0 then
    SG.Options := SG.Options + [TGridOption.ColumnResize]
  else
    SG.Options := SG.Options - [TGridOption.ColumnResize];
  ClearError();
end;

function n_stringgrid_rowselect_get(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_rowselect') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if TGridOption.RowSelect in SG.Options then
    Result.n := 1
  else
    Result.n := 0;
  ClearError();
end;

function p_stringgrid_rowselect_set(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_rowselect#') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  if Args[1].n <> 0 then
    SG.Options := SG.Options + [TGridOption.RowSelect]
  else
    SG.Options := SG.Options - [TGridOption.RowSelect];
  ClearError();
end;

{ Popup Column Items }

function n_stringgrid_popupadd(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Col: TColumn;
  PopupCol: TPopupColumn;
  Idx: Integer;
begin
  Result.n := -1;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_popupadd') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  Col := SG.Columns[Idx];
  if not(Col is TPopupColumn) then
  begin
    SetError(ERR_INVALID_COLUMN_TYPE, 'Not a Popup column');
    Exit;
  end;
  PopupCol := TPopupColumn(Col);
  Result.n := PopupCol.Items.Add(Args[2].s);
  ClearError();
end;

function n_stringgrid_popupclear(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Col: TColumn;
  PopupCol: TPopupColumn;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_popupclear') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  Col := SG.Columns[Idx];
  if not(Col is TPopupColumn) then
  begin
    SetError(ERR_INVALID_COLUMN_TYPE, 'Not a Popup column');
    Exit;
  end;
  PopupCol := TPopupColumn(Col);
  PopupCol.Items.Clear;
  Result.n := 1;
  ClearError();
end;

function n_stringgrid_popupcount(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Col: TColumn;
  PopupCol: TPopupColumn;
  Idx: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_popupcount') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Idx := Trunc(Args[1].n);
  if (Idx < 0) or (Idx >= SG.ColumnCount) then
  begin
    SetError(ERR_INDEX_OUT_OF_RANGE, 'Index out of range');
    Exit;
  end;
  Col := SG.Columns[Idx];
  if not(Col is TPopupColumn) then
  begin
    SetError(ERR_INVALID_COLUMN_TYPE, 'Not a Popup column');
    Exit;
  end;
  PopupCol := TPopupColumn(Col);
  Result.n := PopupCol.Items.Count;
  ClearError();
end;

{ Position and Size }

function n_stringgrid_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_x') then
    Exit();
  Result.n := TBasStringGrid(Args[0].P).Position.X;
  ClearError();
end;

function p_stringgrid_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_x#') then
    Exit();
  TBasStringGrid(Args[0].P).Position.X := Args[1].n;
  ClearError();
end;

function n_stringgrid_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_y') then
    Exit();
  Result.n := TBasStringGrid(Args[0].P).Position.Y;
  ClearError();
end;

function p_stringgrid_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_y#') then
    Exit();
  TBasStringGrid(Args[0].P).Position.Y := Args[1].n;
  ClearError();
end;

function n_stringgrid_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_width') then
    Exit();
  Result.n := TBasStringGrid(Args[0].P).Width;
  ClearError();
end;

function p_stringgrid_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_width#') then
    Exit();
  TBasStringGrid(Args[0].P).Width := Args[1].n;
  ClearError();
end;

function n_stringgrid_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_height') then
    Exit();
  Result.n := TBasStringGrid(Args[0].P).Height;
  ClearError();
end;

function p_stringgrid_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_height#') then
    Exit();
  TBasStringGrid(Args[0].P).Height := Args[1].n;
  ClearError();
end;

function p_stringgrid_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_bounds#') then
    Exit();
  TBasStringGrid(Args[0].P).SetBounds(Args[1].n, Args[2].n, Args[3].n, Args[4].n);
  ClearError();
end;

{ Alignment }

function n_stringgrid_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_align') then
    Exit();
  Result.n := AlignToInt(TBasStringGrid(Args[0].P).Align);
  ClearError();
end;

function p_stringgrid_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_align#') then
    Exit();
  TBasStringGrid(Args[0].P).Align := AlignFromInt(Trunc(Args[1].n));
  ClearError();
end;

{ Visibility and State }

function n_stringgrid_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_visible') then
    Exit();
  if TBasStringGrid(Args[0].P).Visible then
    Result.n := 1
  else
    Result.n := 0;
  ClearError();
end;

function p_stringgrid_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_visible#') then
    Exit();
  TBasStringGrid(Args[0].P).Visible := Args[1].n <> 0;
  ClearError();
end;

function n_stringgrid_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_enabled') then
    Exit();
  if TBasStringGrid(Args[0].P).Enabled then
    Result.n := 1
  else
    Result.n := 0;
  ClearError();
end;

function p_stringgrid_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_enabled#') then
    Exit();
  TBasStringGrid(Args[0].P).Enabled := Args[1].n <> 0;
  ClearError();
end;

function n_stringgrid_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_opacity') then
    Exit();
  Result.n := TBasStringGrid(Args[0].P).Opacity;
  ClearError();
end;

function p_stringgrid_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_opacity#') then
    Exit();
  TBasStringGrid(Args[0].P).Opacity := Args[1].n;
  ClearError();
end;

{ Focus }

function n_stringgrid_focus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_focus') then
    Exit();
  TBasStringGrid(Args[0].P).SetFocus;
  Result.n := 1;
  ClearError();
end;

function n_stringgrid_isfocused(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_isfocused') then
    Exit();
  if TBasStringGrid(Args[0].P).IsFocused then
    Result.n := 1
  else
    Result.n := 0;
  ClearError();
end;

{ Tag }

function n_stringgrid_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_tag') then
    Exit();
  Result.n := TBasStringGrid(Args[0].P).Tag;
  ClearError();
end;

function p_stringgrid_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_tag#') then
    Exit();
  TBasStringGrid(Args[0].P).Tag := Trunc(Args[1].n);
  ClearError();
end;

{ Parent }

function p_stringgrid_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_parent#') then
    Exit();
  Result.P := Pointer(TBasStringGrid(Args[0].P).Parent);
  ClearError();
end;

function p_stringgrid_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_parent#') then
    Exit();
  if not ValidateParent(Args[1].P, 'stringgrid_parent#') then
    Exit();
  TBasStringGrid(Args[0].P).Parent := TFmxObject(Args[1].P);
  ClearError();
end;

{ Clear rows }

function n_stringgrid_clearrows(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_clearrows') then
    Exit();
  TBasStringGrid(Args[0].P).RowCount := 0;
  Result.n := 1;
  ClearError();
end;

{ Scrolling }

function n_stringgrid_scrolltorow(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
  Row: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_scrolltorow') then
    Exit();
  SG := TBasStringGrid(Args[0].P);
  Row := Trunc(Args[1].n);
  if (Row >= 0) and (Row < SG.RowCount) then
  begin
    SG.Row := Row;
    SG.ScrollToSelectedCell;
    Result.n := 1;
  end;
  ClearError();
end;

{ Event callback getters }

function s_stringgrid_oncellclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_oncellclick$') then
    Result.s := TBasStringGrid(Args[0].P).OnCellClickFunc;
end;

function s_stringgrid_oncelldblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_oncelldblclick$') then
    Result.s := TBasStringGrid(Args[0].P).OnCellDblClickFunc;
end;

function s_stringgrid_onselectcell_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_onselectcell$') then
    Result.s := TBasStringGrid(Args[0].P).OnSelectCellFunc;
end;

function s_stringgrid_onselchanged_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_onselchanged$') then
    Result.s := TBasStringGrid(Args[0].P).OnSelChangedFunc;
end;

function s_stringgrid_oneditingdone_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_oneditingdone$') then
    Result.s := TBasStringGrid(Args[0].P).OnEditingDoneFunc;
end;

function s_stringgrid_onheaderclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_onheaderclick$') then
    Result.s := TBasStringGrid(Args[0].P).OnHeaderClickFunc;
end;

function s_stringgrid_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_onclick$') then
    Result.s := TBasStringGrid(Args[0].P).OnClickFunc;
end;

function s_stringgrid_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_onresize$') then
    Result.s := TBasStringGrid(Args[0].P).OnResizeFunc;
end;

{ Event callback setters }

function p_stringgrid_oncellclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_oncellclick#') then
    TBasStringGrid(Args[0].P).OnCellClickFunc := Args[1].s;
end;

function p_stringgrid_oncelldblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_oncelldblclick#') then
    TBasStringGrid(Args[0].P).OnCellDblClickFunc := Args[1].s;
end;

function p_stringgrid_onselectcell_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_onselectcell#') then
    TBasStringGrid(Args[0].P).OnSelectCellFunc := Args[1].s;
end;

function p_stringgrid_onselchanged_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_onselchanged#') then
    TBasStringGrid(Args[0].P).OnSelChangedFunc := Args[1].s;
end;

function p_stringgrid_oneditingdone_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_oneditingdone#') then
    TBasStringGrid(Args[0].P).OnEditingDoneFunc := Args[1].s;
end;

function p_stringgrid_onheaderclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_onheaderclick#') then
    TBasStringGrid(Args[0].P).OnHeaderClickFunc := Args[1].s;
end;

function p_stringgrid_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_onclick#') then
    TBasStringGrid(Args[0].P).OnClickFunc := Args[1].s;
end;

function p_stringgrid_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if ValidateGrid(Args[0].P, 'stringgrid_onresize#') then
    TBasStringGrid(Args[0].P).OnResizeFunc := Args[1].s;
end;

function p_stringgrid_clearcallbacks(var Args: array of TAsmData): TAsmData;
var
  SG: TBasStringGrid;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.s := '';
  if not ValidateGrid(Args[0].P, 'stringgrid_clearcallbacks#') then
    Exit();

  SG := TBasStringGrid(Args[0].P);
  SG.DisconnectAllEvents();
  SG.FOnCellClickFunc := '';
  SG.FOnCellDblClickFunc := '';
  SG.FOnSelectCellFunc := '';
  SG.FOnSelChangedFunc := '';
  SG.FOnEditingDoneFunc := '';
  SG.FOnHeaderClickFunc := '';
  SG.FOnClickFunc := '';
  SG.FOnDblClickFunc := '';
  SG.FOnEnterFunc := '';
  SG.FOnExitFunc := '';
  SG.FOnKeyDownFunc := '';
  SG.FOnKeyUpFunc := '';
  SG.FOnMouseDownFunc := '';
  SG.FOnMouseUpFunc := '';
  SG.FOnMouseMoveFunc := '';
  SG.FOnMouseEnterFunc := '';
  SG.FOnMouseLeaveFunc := '';
  SG.FOnResizeFunc := '';
end;

{ ============================================================================
  FUNCTION REGISTRATION
  ============================================================================ }

procedure RegisterStringGridFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error functions
  Fn.Entry := @n_stringgrid_error; Lib.Add('stringgrid_error@', Fn);
  Fn.Entry := @s_stringgrid_errormsg; Lib.Add('stringgrid_errormsg$@', Fn);
  Fn.Entry := @s_stringgrid_strerror; Lib.Add('stringgrid_strerror$@n', Fn);
  Fn.Entry := @n_stringgrid_clearerror; Lib.Add('stringgrid_clearerror@', Fn);

  // Creation and destruction
  Fn.Entry := @p_stringgrid_new; Lib.Add('stringgrid#@#', Fn);
  Fn.Entry := @p_stringgrid_new_pos; Lib.Add('stringgrid#@#nnnn', Fn);
  Fn.Entry := @n_stringgrid_free; Lib.Add('stringgrid_free@#', Fn);

  // Row and column count
  Fn.Entry := @n_stringgrid_rowcount_get; Lib.Add('stringgrid_rowcount@#', Fn);
  Fn.Entry := @p_stringgrid_rowcount_set; Lib.Add('stringgrid_rowcount#@#n', Fn);
  Fn.Entry := @n_stringgrid_colcount; Lib.Add('stringgrid_colcount@#', Fn);

  // Column management
  Fn.Entry := @p_stringgrid_addcolumn; Lib.Add('stringgrid_addcolumn#@#$nn', Fn);
  Fn.Entry := @n_stringgrid_deletecolumn; Lib.Add('stringgrid_deletecolumn@#n', Fn);
  Fn.Entry := @n_stringgrid_clearcolumns; Lib.Add('stringgrid_clearcolumns@#', Fn);
  Fn.Entry := @p_stringgrid_column; Lib.Add('stringgrid_column#@#n', Fn);

  // Column properties
  Fn.Entry := @s_stringgrid_columnheader_get; Lib.Add('stringgrid_columnheader$@#n', Fn);
  Fn.Entry := @p_stringgrid_columnheader_set; Lib.Add('stringgrid_columnheader#@#n$', Fn);
  Fn.Entry := @n_stringgrid_columnwidth_get; Lib.Add('stringgrid_columnwidth@#n', Fn);
  Fn.Entry := @p_stringgrid_columnwidth_set; Lib.Add('stringgrid_columnwidth#@#nn', Fn);
  Fn.Entry := @n_stringgrid_columnvisible_get; Lib.Add('stringgrid_columnvisible@#n', Fn);
  Fn.Entry := @p_stringgrid_columnvisible_set; Lib.Add('stringgrid_columnvisible#@#nn', Fn);
  Fn.Entry := @n_stringgrid_columnreadonly_get; Lib.Add('stringgrid_columnreadonly@#n', Fn);
  Fn.Entry := @p_stringgrid_columnreadonly_set; Lib.Add('stringgrid_columnreadonly#@#nn', Fn);
  Fn.Entry := @n_stringgrid_columntype; Lib.Add('stringgrid_columntype@#n', Fn);

  // Cell access
  Fn.Entry := @s_stringgrid_cell_get; Lib.Add('stringgrid_cell$@#nn', Fn);
  Fn.Entry := @p_stringgrid_cell_set; Lib.Add('stringgrid_cell#@#nn$', Fn);
  Fn.Entry := @n_stringgrid_cellcheck_get; Lib.Add('stringgrid_cellcheck@#nn', Fn);
  Fn.Entry := @p_stringgrid_cellcheck_set; Lib.Add('stringgrid_cellcheck#@#nnn', Fn);
  Fn.Entry := @n_stringgrid_cellnum_get; Lib.Add('stringgrid_cellnum@#nn', Fn);
  Fn.Entry := @p_stringgrid_cellnum_set; Lib.Add('stringgrid_cellnum#@#nnn', Fn);
  Fn.Entry := @n_stringgrid_cellprogress_get; Lib.Add('stringgrid_cellprogress@#nn', Fn);
  Fn.Entry := @p_stringgrid_cellprogress_set; Lib.Add('stringgrid_cellprogress#@#nnn', Fn);

  // Row height
  Fn.Entry := @n_stringgrid_rowheight_get; Lib.Add('stringgrid_rowheight@#', Fn);
  Fn.Entry := @p_stringgrid_rowheight_set; Lib.Add('stringgrid_rowheight#@#n', Fn);

  // Row operations - NEW
  Fn.Entry := @n_stringgrid_insertrow; Lib.Add('stringgrid_insertrow@#n', Fn);
  Fn.Entry := @n_stringgrid_deleterow; Lib.Add('stringgrid_deleterow@#n', Fn);
  Fn.Entry := @n_stringgrid_moverow; Lib.Add('stringgrid_moverow@#nn', Fn);
  Fn.Entry := @n_stringgrid_swaprows; Lib.Add('stringgrid_swaprows@#nn', Fn);
  Fn.Entry := @n_stringgrid_clearrow; Lib.Add('stringgrid_clearrow@#n', Fn);
  Fn.Entry := @n_stringgrid_copyrow; Lib.Add('stringgrid_copyrow@#nn', Fn);

  // Sorting - NEW
  Fn.Entry := @n_stringgrid_sort; Lib.Add('stringgrid_sort@#nn', Fn);
  Fn.Entry := @n_stringgrid_sortnum; Lib.Add('stringgrid_sortnum@#nn', Fn);

  // Column text alignment - NEW
  Fn.Entry := @n_stringgrid_columnalign_get; Lib.Add('stringgrid_columnalign@#n', Fn);
  Fn.Entry := @p_stringgrid_columnalign_set; Lib.Add('stringgrid_columnalign#@#nn', Fn);

  // Clipboard - NEW
  Fn.Entry := @n_stringgrid_copy; Lib.Add('stringgrid_copy@#', Fn);
  Fn.Entry := @n_stringgrid_copysel; Lib.Add('stringgrid_copysel@#', Fn);
  Fn.Entry := @n_stringgrid_paste; Lib.Add('stringgrid_paste@#', Fn);
  Fn.Entry := @n_stringgrid_copycell; Lib.Add('stringgrid_copycell@#nn', Fn);
  Fn.Entry := @n_stringgrid_pastecell; Lib.Add('stringgrid_pastecell@#nn', Fn);

  // CSV - NEW
  Fn.Entry := @n_stringgrid_exportcsv; Lib.Add('stringgrid_exportcsv@#$$n', Fn);
  Fn.Entry := @n_stringgrid_importcsv; Lib.Add('stringgrid_importcsv@#$$n', Fn);
  Fn.Entry := @s_stringgrid_tocsv; Lib.Add('stringgrid_tocsv$@#$n', Fn);
  Fn.Entry := @n_stringgrid_fromcsv; Lib.Add('stringgrid_fromcsv@#$$n', Fn);

  // Selection
  Fn.Entry := @n_stringgrid_col_get; Lib.Add('stringgrid_col@#', Fn);
  Fn.Entry := @p_stringgrid_col_set; Lib.Add('stringgrid_col#@#n', Fn);
  Fn.Entry := @n_stringgrid_row_get; Lib.Add('stringgrid_row@#', Fn);
  Fn.Entry := @p_stringgrid_row_set; Lib.Add('stringgrid_row#@#n', Fn);
  Fn.Entry := @p_stringgrid_selectcell; Lib.Add('stringgrid_selectcell#@#nn', Fn);

  // Grid options
  Fn.Entry := @n_stringgrid_showhdr_get; Lib.Add('stringgrid_showhdr@#', Fn);
  Fn.Entry := @p_stringgrid_showhdr_set; Lib.Add('stringgrid_showhdr#@#n', Fn);
  Fn.Entry := @n_stringgrid_editing_get; Lib.Add('stringgrid_editing@#', Fn);
  Fn.Entry := @p_stringgrid_editing_set; Lib.Add('stringgrid_editing#@#n', Fn);
  Fn.Entry := @n_stringgrid_altcolors_get; Lib.Add('stringgrid_altcolors@#', Fn);
  Fn.Entry := @p_stringgrid_altcolors_set; Lib.Add('stringgrid_altcolors#@#n', Fn);
  Fn.Entry := @n_stringgrid_colresize_get; Lib.Add('stringgrid_colresize@#', Fn);
  Fn.Entry := @p_stringgrid_colresize_set; Lib.Add('stringgrid_colresize#@#n', Fn);
  Fn.Entry := @n_stringgrid_rowselect_get; Lib.Add('stringgrid_rowselect@#', Fn);
  Fn.Entry := @p_stringgrid_rowselect_set; Lib.Add('stringgrid_rowselect#@#n', Fn);

  // Popup column items
  Fn.Entry := @n_stringgrid_popupadd; Lib.Add('stringgrid_popupadd@#n$', Fn);
  Fn.Entry := @n_stringgrid_popupclear; Lib.Add('stringgrid_popupclear@#n', Fn);
  Fn.Entry := @n_stringgrid_popupcount; Lib.Add('stringgrid_popupcount@#n', Fn);

  // Position and size
  Fn.Entry := @n_stringgrid_x_get; Lib.Add('stringgrid_x@#', Fn);
  Fn.Entry := @p_stringgrid_x_set; Lib.Add('stringgrid_x#@#n', Fn);
  Fn.Entry := @n_stringgrid_y_get; Lib.Add('stringgrid_y@#', Fn);
  Fn.Entry := @p_stringgrid_y_set; Lib.Add('stringgrid_y#@#n', Fn);
  Fn.Entry := @n_stringgrid_width_get; Lib.Add('stringgrid_width@#', Fn);
  Fn.Entry := @p_stringgrid_width_set; Lib.Add('stringgrid_width#@#n', Fn);
  Fn.Entry := @n_stringgrid_height_get; Lib.Add('stringgrid_height@#', Fn);
  Fn.Entry := @p_stringgrid_height_set; Lib.Add('stringgrid_height#@#n', Fn);
  Fn.Entry := @p_stringgrid_bounds_set; Lib.Add('stringgrid_bounds#@#nnnn', Fn);

  // Alignment
  Fn.Entry := @n_stringgrid_align_get; Lib.Add('stringgrid_align@#', Fn);
  Fn.Entry := @p_stringgrid_align_set; Lib.Add('stringgrid_align#@#n', Fn);

  // Visibility and state
  Fn.Entry := @n_stringgrid_visible_get; Lib.Add('stringgrid_visible@#', Fn);
  Fn.Entry := @p_stringgrid_visible_set; Lib.Add('stringgrid_visible#@#n', Fn);
  Fn.Entry := @n_stringgrid_enabled_get; Lib.Add('stringgrid_enabled@#', Fn);
  Fn.Entry := @p_stringgrid_enabled_set; Lib.Add('stringgrid_enabled#@#n', Fn);
  Fn.Entry := @n_stringgrid_opacity_get; Lib.Add('stringgrid_opacity@#', Fn);
  Fn.Entry := @p_stringgrid_opacity_set; Lib.Add('stringgrid_opacity#@#n', Fn);

  // Focus
  Fn.Entry := @n_stringgrid_focus; Lib.Add('stringgrid_focus@#', Fn);
  Fn.Entry := @n_stringgrid_isfocused; Lib.Add('stringgrid_isfocused@#', Fn);

  // Tag
  Fn.Entry := @n_stringgrid_tag_get; Lib.Add('stringgrid_tag@#', Fn);
  Fn.Entry := @p_stringgrid_tag_set; Lib.Add('stringgrid_tag#@#n', Fn);

  // Parent
  Fn.Entry := @p_stringgrid_parent_get; Lib.Add('stringgrid_parent#@#', Fn);
  Fn.Entry := @p_stringgrid_parent_set; Lib.Add('stringgrid_parent#@##', Fn);

  // Clear rows
  Fn.Entry := @n_stringgrid_clearrows; Lib.Add('stringgrid_clearrows@#', Fn);

  // Scrolling
  Fn.Entry := @n_stringgrid_scrolltorow; Lib.Add('stringgrid_scrolltorow@#n', Fn);

  // Event callbacks - getters
  Fn.Entry := @s_stringgrid_oncellclick_get; Lib.Add('stringgrid_oncellclick$@#', Fn);
  Fn.Entry := @s_stringgrid_oncelldblclick_get; Lib.Add('stringgrid_oncelldblclick$@#', Fn);
  Fn.Entry := @s_stringgrid_onselectcell_get; Lib.Add('stringgrid_onselectcell$@#', Fn);
  Fn.Entry := @s_stringgrid_onselchanged_get; Lib.Add('stringgrid_onselchanged$@#', Fn);
  Fn.Entry := @s_stringgrid_oneditingdone_get; Lib.Add('stringgrid_oneditingdone$@#', Fn);
  Fn.Entry := @s_stringgrid_onheaderclick_get; Lib.Add('stringgrid_onheaderclick$@#', Fn);
  Fn.Entry := @s_stringgrid_onclick_get; Lib.Add('stringgrid_onclick$@#', Fn);
  Fn.Entry := @s_stringgrid_onresize_get; Lib.Add('stringgrid_onresize$@#', Fn);

  // Event callbacks - setters
  Fn.Entry := @p_stringgrid_oncellclick_set; Lib.Add('stringgrid_oncellclick#@#$', Fn);
  Fn.Entry := @p_stringgrid_oncelldblclick_set; Lib.Add('stringgrid_oncelldblclick#@#$', Fn);
  Fn.Entry := @p_stringgrid_onselectcell_set; Lib.Add('stringgrid_onselectcell#@#$', Fn);
  Fn.Entry := @p_stringgrid_onselchanged_set; Lib.Add('stringgrid_onselchanged#@#$', Fn);
  Fn.Entry := @p_stringgrid_oneditingdone_set; Lib.Add('stringgrid_oneditingdone#@#$', Fn);
  Fn.Entry := @p_stringgrid_onheaderclick_set; Lib.Add('stringgrid_onheaderclick#@#$', Fn);
  Fn.Entry := @p_stringgrid_onclick_set; Lib.Add('stringgrid_onclick#@#$', Fn);
  Fn.Entry := @p_stringgrid_onresize_set; Lib.Add('stringgrid_onresize#@#$', Fn);

  // Clear all callbacks
  Fn.Entry := @p_stringgrid_clearcallbacks; Lib.Add('stringgrid_clearcallbacks#@#', Fn);
end;

end.

