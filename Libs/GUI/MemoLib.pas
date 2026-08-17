unit MemoLib;

{ ******************************************************************************
  MemoLib - Multi-line Text Memo Control Library for Plan9Basic
  Version: 1.0.0
  Function Count: 130+ functions
  Copyright (c) 2024-2025 Plan9Basic Project

  TMemo wrapper providing multi-line text editing capabilities with:
  - Line-based text manipulation
  - Word wrap and scroll bars
  - Full font styling
  - Selection and caret control
  - Clipboard operations
  - Undo/Redo support
  - Complete event handling
  ****************************************************************************** }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Memo,
  FMX.Controls.Presentation, FMX.Text, FMX.ScrollBox,
  basic, exec, UnitGC, UnitUtils, HandleRegistry;

type
  TBasMemo = class(TMemo)
  private
    FOnChangeFunc, FOnChangeTrackingFunc: String;
    FOnEnterFunc, FOnExitFunc: String;
    FOnKeyDownFunc, FOnKeyUpFunc: String;
    FOnClickFunc, FOnDblClickFunc: String;
    FOnMouseDownFunc, FOnMouseUpFunc, FOnMouseMoveFunc: String;
    FOnMouseEnterFunc, FOnMouseLeaveFunc: String;
    FOnResizeFunc: String;
    FOnDragEnterFunc: String;
    FOnDragOverFunc: String;
    FOnDragDropFunc: String;
    FOnDragLeaveFunc: String;
    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;
    procedure InternalOnChange(Sender: TObject);
    procedure InternalOnChangeTracking(Sender: TObject);
    procedure InternalOnEnter(Sender: TObject);
    procedure InternalOnExit(Sender: TObject);
    procedure InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure InternalOnClick(Sender: TObject);
    procedure InternalOnDblClick(Sender: TObject);
    procedure InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseEnter(Sender: TObject);
    procedure InternalOnMouseLeave(Sender: TObject);
    procedure InternalOnResize(Sender: TObject);
    procedure InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
    procedure InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure InternalOnDragLeave(Sender: TObject);

    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
    function ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;

    procedure SetOnChangeFunc(const Value: String);
    procedure SetOnChangeTrackingFunc(const Value: String);
    procedure SetOnEnterFunc(const Value: String);
    procedure SetOnExitFunc(const Value: String);
    procedure SetOnKeyDownFunc(const Value: String);
    procedure SetOnKeyUpFunc(const Value: String);
    procedure SetOnClickFunc(const Value: String);
    procedure SetOnDblClickFunc(const Value: String);
    procedure SetOnMouseDownFunc(const Value: String);
    procedure SetOnMouseUpFunc(const Value: String);
    procedure SetOnMouseMoveFunc(const Value: String);
    procedure SetOnMouseEnterFunc(const Value: String);
    procedure SetOnMouseLeaveFunc(const Value: String);
    procedure SetOnResizeFunc(const Value: String);
    procedure SetOnDragEnterFunc(const Value: String);
    procedure SetOnDragOverFunc(const Value: String);
    procedure SetOnDragDropFunc(const Value: String);
    procedure SetOnDragLeaveFunc(const Value: String);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure DisconnectAllEvents();
    property OnChangeFunc: String read FOnChangeFunc write SetOnChangeFunc;
    property OnChangeTrackingFunc: String read FOnChangeTrackingFunc write SetOnChangeTrackingFunc;
    property OnEnterFunc: String read FOnEnterFunc write SetOnEnterFunc;
    property OnExitFunc: String read FOnExitFunc write SetOnExitFunc;
    property OnKeyDownFunc: String read FOnKeyDownFunc write SetOnKeyDownFunc;
    property OnKeyUpFunc: String read FOnKeyUpFunc write SetOnKeyUpFunc;
    property OnClickFunc: String read FOnClickFunc write SetOnClickFunc;
    property OnDblClickFunc: String read FOnDblClickFunc write SetOnDblClickFunc;
    property OnMouseDownFunc: String read FOnMouseDownFunc write SetOnMouseDownFunc;
    property OnMouseUpFunc: String read FOnMouseUpFunc write SetOnMouseUpFunc;
    property OnMouseMoveFunc: String read FOnMouseMoveFunc write SetOnMouseMoveFunc;
    property OnMouseEnterFunc: String read FOnMouseEnterFunc write SetOnMouseEnterFunc;
    property OnMouseLeaveFunc: String read FOnMouseLeaveFunc write SetOnMouseLeaveFunc;
    property OnResizeFunc: String read FOnResizeFunc write SetOnResizeFunc;
    property OnDragEnterFunc: String read FOnDragEnterFunc write SetOnDragEnterFunc;
    property OnDragOverFunc: String read FOnDragOverFunc write SetOnDragOverFunc;
    property OnDragDropFunc: String read FOnDragDropFunc write SetOnDragDropFunc;
    property OnDragLeaveFunc: String read FOnDragLeaveFunc write SetOnDragLeaveFunc;
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
  end;

procedure RegisterMemoFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  MEMO_GC_TAG = 'BASIC_MEMO';
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_MEMO = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INDEX_BOUNDS = 5;
  ALIGN_NONE = 0;
  ALIGN_TOP = 1;
  ALIGN_LEFT = 2;
  ALIGN_RIGHT = 3;
  ALIGN_BOTTOM = 4;
  ALIGN_CLIENT = 9;
  ALIGN_CENTER = 11;
  TEXT_ALIGN_LEADING = 0;
  TEXT_ALIGN_CENTER = 1;
  TEXT_ALIGN_TRAILING = 2;

var
  lastError: Integer;
  lastErrorMsg: String;
  ModuleEngine: TBasicEngine;
  ModuleOutput: TStrings;

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

function ValidateMemo(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_MEMO, FuncName + ': Nil pointer');
    Exit;
  end;
  try
    if not(IsHandleOf(P, TBasMemo)) then
    begin
      SetError(ERR_INVALID_MEMO, FuncName + ': Invalid object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_MEMO, FuncName + ': Invalid pointer');
    Exit;
  end;
  ClearError();
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': Nil pointer');
    Exit;
  end;
  try
    if not(TObject(P) is TFmxObject) then
    begin
      SetError(ERR_INVALID_PARENT, FuncName + ': Invalid object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_PARENT, FuncName + ': Invalid pointer');
    Exit;
  end;
  ClearError();
  Result := True;
end;

function IntToAlign(Value: Integer): TAlignLayout;
begin
  case Value of
    0: Result := TAlignLayout.None;
    1: Result := TAlignLayout.Top;
    2: Result := TAlignLayout.Left;
    3: Result := TAlignLayout.Right;
    4: Result := TAlignLayout.Bottom;
    9: Result := TAlignLayout.Client;
    11: Result := TAlignLayout.Center;
  else
    Result := TAlignLayout.None;
  end;
end;

function AlignToInt(Value: TAlignLayout): Integer;
begin
  case Value of
    TAlignLayout.None: Result := 0;
    TAlignLayout.Top: Result := 1;
    TAlignLayout.Left: Result := 2;
    TAlignLayout.Right: Result := 3;
    TAlignLayout.Bottom: Result := 4;
    TAlignLayout.Client: Result := 9;
    TAlignLayout.Center: Result := 11;
  else
    Result := 0;
  end;
end;

function IntToTextAlign(Value: Integer): TTextAlign;
begin
  case Value of
    0: Result := TTextAlign.Leading;
    1: Result := TTextAlign.Center;
    2: Result := TTextAlign.Trailing;
  else
    Result := TTextAlign.Leading;
  end;
end;

function TextAlignToInt(Value: TTextAlign): Integer;
begin
  case Value of
    TTextAlign.Leading: Result := 0;
    TTextAlign.Center: Result := 1;
    TTextAlign.Trailing: Result := 2;
  else
    Result := 0;
  end;
end;

function BuildShiftString(Shift: TShiftState): String;
begin
  Result := '';
  if ssShift in Shift then
    Result := Result + 'S';
  if ssCtrl in Shift then
    Result := Result + 'C';
  if ssAlt in Shift then
    Result := Result + 'A';
end;

function MouseButtonToInt(Button: TMouseButton): Integer;
begin
  case Button of
    TMouseButton.mbLeft: Result := 0;
    TMouseButton.mbRight: Result := 1;
    TMouseButton.mbMiddle: Result := 2;
  else
    Result := 0;
  end;
end;

constructor TBasMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);
  FOnChangeFunc := '';
  FOnChangeTrackingFunc := '';
  FOnEnterFunc := '';
  FOnExitFunc := '';
  FOnKeyDownFunc := '';
  FOnKeyUpFunc := '';
  FOnClickFunc := '';
  FOnDblClickFunc := '';
  FOnMouseDownFunc := '';
  FOnMouseUpFunc := '';
  FOnMouseMoveFunc := '';
  FOnMouseEnterFunc := '';
  FOnMouseLeaveFunc := '';
  FOnResizeFunc := '';
  FOnDragEnterFunc := '';
  FOnDragOverFunc := '';
  FOnDragDropFunc := '';
  FOnDragLeaveFunc := '';
  FBasicEngine := nil;
  FConsoleOutput := nil;
  // Remove styled settings to allow explicit font control
  Self.StyledSettings := Self.StyledSettings - [TStyledSetting.Family, TStyledSetting.Size, TStyledSetting.Style, TStyledSetting.FontColor];
end;

destructor TBasMemo.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasMemo.DisconnectAllEvents();
begin
  Self.OnChange := nil;
  Self.OnChangeTracking := nil;
  Self.OnEnter := nil;
  Self.OnExit := nil;
  Self.OnKeyDown := nil;
  Self.OnKeyUp := nil;
  Self.OnClick := nil;
  Self.OnDblClick := nil;
  Self.OnMouseDown := nil;
  Self.OnMouseUp := nil;
  Self.OnMouseMove := nil;
  Self.OnMouseEnter := nil;
  Self.OnMouseLeave := nil;
  Self.OnResize := nil;
  Self.OnDragEnter := nil;
  Self.OnDragOver := nil;
  Self.OnDragDrop := nil;
  Self.OnDragLeave := nil;
end;

procedure TBasMemo.SetOnChangeFunc(const Value: String);
begin
  FOnChangeFunc := Value;
  if Value <> '' then
    Self.OnChange := InternalOnChange
  else
    Self.OnChange := nil;
end;

procedure TBasMemo.SetOnChangeTrackingFunc(const Value: String);
begin
  FOnChangeTrackingFunc := Value;
  if Value <> '' then
    Self.OnChangeTracking := InternalOnChangeTracking
  else
    Self.OnChangeTracking := nil;
end;

procedure TBasMemo.SetOnEnterFunc(const Value: String);
begin
  FOnEnterFunc := Value;
  if Value <> '' then
    Self.OnEnter := InternalOnEnter
  else
    Self.OnEnter := nil;
end;

procedure TBasMemo.SetOnExitFunc(const Value: String);
begin
  FOnExitFunc := Value;
  if Value <> '' then
    Self.OnExit := InternalOnExit
  else
    Self.OnExit := nil;
end;

procedure TBasMemo.SetOnKeyDownFunc(const Value: String);
begin
  FOnKeyDownFunc := Value;
  if Value <> '' then
    Self.OnKeyDown := InternalOnKeyDown
  else
    Self.OnKeyDown := nil;
end;

procedure TBasMemo.SetOnKeyUpFunc(const Value: String);
begin
  FOnKeyUpFunc := Value;
  if Value <> '' then
    Self.OnKeyUp := InternalOnKeyUp
  else
    Self.OnKeyUp := nil;
end;

procedure TBasMemo.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    Self.OnClick := InternalOnClick
  else
    Self.OnClick := nil;
end;

procedure TBasMemo.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    Self.OnDblClick := InternalOnDblClick
  else
    Self.OnDblClick := nil;
end;

procedure TBasMemo.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    Self.OnDragEnter := InternalOnDragEnter
  else
    Self.OnDragEnter := nil;
end;

procedure TBasMemo.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    Self.OnDragOver := InternalOnDragOver
  else
    Self.OnDragOver := nil;
end;

procedure TBasMemo.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    Self.OnDragDrop := InternalOnDragDrop
  else
    Self.OnDragDrop := nil;
end;

procedure TBasMemo.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    Self.OnDragLeave := InternalOnDragLeave
  else
    Self.OnDragLeave := nil;
end;

procedure TBasMemo.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    Self.OnMouseDown := InternalOnMouseDown
  else
    Self.OnMouseDown := nil;
end;

procedure TBasMemo.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    Self.OnMouseUp := InternalOnMouseUp
  else
    Self.OnMouseUp := nil;
end;

procedure TBasMemo.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    Self.OnMouseMove := InternalOnMouseMove
  else
    Self.OnMouseMove := nil;
end;

procedure TBasMemo.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    Self.OnMouseEnter := InternalOnMouseEnter
  else
    Self.OnMouseEnter := nil;
end;

procedure TBasMemo.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    Self.OnMouseLeave := InternalOnMouseLeave
  else
    Self.OnMouseLeave := nil;
end;

procedure TBasMemo.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    Self.OnResize := InternalOnResize
  else
    Self.OnResize := nil;
end;

procedure TBasMemo.ExecuteCallback(const FuncSignature: String;
  const Args: array of TAsmData);
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  RetVal: TAsmData;
  i: Integer;
begin
  if UnitGC.GlobalCallbackBusy then
    Exit();
  if not Assigned(FBasicEngine) then
    Exit();
  if not Assigned(FConsoleOutput) then
    Exit();
  if FuncSignature = '' then
    Exit();
  UnitGC.GlobalCallbackBusy := True;
  UnitGC.SkipProcessMessages := True;
  try
    SetLength(CallArgs, Length(Args));
    for i := 0 to High(Args) do
      CallArgs[i] := Args[i];
    try
      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs,
        RetType, RetVal);
    except
      on E: Exception do
      begin
        FConsoleOutput.Add('*** Memo Callback Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

function TBasMemo.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  i: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if UnitGC.GlobalCallbackBusy then Exit();
  if not Assigned(FBasicEngine) then Exit;
  if not Assigned(FConsoleOutput) then Exit;
  if FuncSignature = '' then Exit;

  UnitGC.GlobalCallbackBusy := True;
  UnitGC.SkipProcessMessages := True;
  try
    SetLength(CallArgs, Length(Args));
    for i := 0 to High(Args) do
      CallArgs[i] := Args[i];

    try
      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs, RetType, Result);
    except
      on E: Exception do
      begin
        FConsoleOutput.Add('*** Memo Event Callback Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

procedure TBasMemo.InternalOnChange(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnChangeFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(LowerCase(FOnChangeFunc) + '@#', Args);
end;

procedure TBasMemo.InternalOnChangeTracking(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnChangeTrackingFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(LowerCase(FOnChangeTrackingFunc) + '@#', Args);
end;

procedure TBasMemo.InternalOnEnter(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnEnterFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(LowerCase(FOnEnterFunc) + '@#', Args);
end;

procedure TBasMemo.InternalOnExit(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnExitFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(LowerCase(FOnExitFunc) + '@#', Args);
end;

procedure TBasMemo.InternalOnKeyDown(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
var
  Args: array [0 .. 3] of TAsmData;
begin
  if FOnKeyDownFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  Args[1].n := Key;
  Args[1].P := nil;
  Args[1].S := '';
  Args[2].n := 0;
  Args[2].P := nil;
  Args[2].S := KeyChar;
  Args[3].n := 0;
  Args[3].P := nil;
  Args[3].S := BuildShiftString(Shift);
  ExecuteCallback(LowerCase(FOnKeyDownFunc) + '@#n$$', Args);
end;

procedure TBasMemo.InternalOnKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: Char; Shift: TShiftState);
var
  Args: array [0 .. 3] of TAsmData;
begin
  if FOnKeyUpFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  Args[1].n := Key;
  Args[1].P := nil;
  Args[1].S := '';
  Args[2].n := 0;
  Args[2].P := nil;
  Args[2].S := KeyChar;
  Args[3].n := 0;
  Args[3].P := nil;
  Args[3].S := BuildShiftString(Shift);
  ExecuteCallback(LowerCase(FOnKeyUpFunc) + '@#n$$', Args);
end;

procedure TBasMemo.InternalOnClick(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnClickFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(LowerCase(FOnClickFunc) + '@#', Args);
end;

procedure TBasMemo.InternalOnDblClick(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnDblClickFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(LowerCase(FOnDblClickFunc) + '@#', Args);
end;

procedure TBasMemo.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragEnterFunc = '' then
    Exit();

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';

  ExecuteCallback(LowerCase(FOnDragEnterFunc) + '@#nn', Args);
end;

procedure TBasMemo.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
var
  Args: array[0..2] of TAsmData;
  RetVal: TAsmData;
begin
  if FOnDragOverFunc = '' then
    Exit();

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';

  RetVal := ExecuteCallbackWithResult(LowerCase(FOnDragOverFunc) + '@#nn', Args);

  if RetVal.n <> 0 then
    Operation := TDragOperation.Move
  else
    Operation := TDragOperation.None;
end;

procedure TBasMemo.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragDropFunc = '' then
    Exit();

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';

  ExecuteCallback(LowerCase(FOnDragDropFunc) + '@#nn', Args);
end;

procedure TBasMemo.InternalOnDragLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDragLeaveFunc = '' then
    Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnDragLeaveFunc) + '@#', Args);
end;

procedure TBasMemo.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array [0 .. 4] of TAsmData;
begin
  if FOnMouseDownFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  Args[1].n := MouseButtonToInt(Button);
  Args[1].P := nil;
  Args[1].S := '';
  Args[2].n := X;
  Args[2].P := nil;
  Args[2].S := '';
  Args[3].n := Y;
  Args[3].P := nil;
  Args[3].S := '';
  Args[4].n := 0;
  Args[4].P := nil;
  Args[4].S := BuildShiftString(Shift);
  ExecuteCallback(LowerCase(FOnMouseDownFunc) + '@#nnn$', Args);
end;

procedure TBasMemo.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array [0 .. 4] of TAsmData;
begin
  if FOnMouseUpFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  Args[1].n := MouseButtonToInt(Button);
  Args[1].P := nil;
  Args[1].S := '';
  Args[2].n := X;
  Args[2].P := nil;
  Args[2].S := '';
  Args[3].n := Y;
  Args[3].P := nil;
  Args[3].S := '';
  Args[4].n := 0;
  Args[4].P := nil;
  Args[4].S := BuildShiftString(Shift);
  ExecuteCallback(LowerCase(FOnMouseUpFunc) + '@#nnn$', Args);
end;

procedure TBasMemo.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array [0 .. 3] of TAsmData;
begin
  if FOnMouseMoveFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  Args[1].n := X;
  Args[1].P := nil;
  Args[1].S := '';
  Args[2].n := Y;
  Args[2].P := nil;
  Args[2].S := '';
  Args[3].n := 0;
  Args[3].P := nil;
  Args[3].S := BuildShiftString(Shift);
  ExecuteCallback(LowerCase(FOnMouseMoveFunc) + '@#nn$', Args);
end;

procedure TBasMemo.InternalOnMouseEnter(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnMouseEnterFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(LowerCase(FOnMouseEnterFunc) + '@#', Args);
end;

procedure TBasMemo.InternalOnMouseLeave(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnMouseLeaveFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(LowerCase(FOnMouseLeaveFunc) + '@#', Args);
end;

procedure TBasMemo.InternalOnResize(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnResizeFunc = '' then
    Exit();
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(LowerCase(FOnResizeFunc) + '@#', Args);
end;

// ============================================================================
// Error Functions
// ============================================================================
function n_memo_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.P := nil;
  Result.S := '';
end;

function s_memo_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := lastErrorMsg;
end;

function s_memo_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  case Trunc(Args[0].n) of
    0: Result.S := 'No error';
    1: Result.S := 'Invalid memo';
    2: Result.S := 'Invalid parent';
    3: Result.S := 'Invalid value';
    4: Result.S := 'Create failed';
    5: Result.S := 'Index out of bounds';
  else
    Result.S := 'Unknown error';
  end;
end;

function n_memo_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  ClearError();
end;

// ============================================================================
// Creation Functions
// ============================================================================
function p_memo_new(var Args: array of TAsmData): TAsmData;
var
  Memo: TBasMemo;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateParent(Args[0].P, 'memo#') then
    Exit();
  try
    Memo := TBasMemo.Create(nil);
    Memo.Parent := TFmxObject(Args[0].P);
    Memo.BasicEngine := ModuleEngine;
    Memo.ConsoleOutput := ModuleOutput;

    Result.P := Pointer(Memo);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Memo, MEMO_GC_TAG + '_' + IntToStr(NativeInt(Result.P)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'memo#: ' + E.Message);
  end;
end;

function p_memo_new_pos(var Args: array of TAsmData): TAsmData;
var
  Memo: TBasMemo;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateParent(Args[0].P, 'memo#') then
    Exit();
  try
    Memo := TBasMemo.Create(nil);
    Memo.Parent := TFmxObject(Args[0].P);
    Memo.BasicEngine := ModuleEngine;
    Memo.ConsoleOutput := ModuleOutput;
    Memo.Position.X := Args[1].n;
    Memo.Position.Y := Args[2].n;
    Memo.Width := Args[3].n;
    Memo.Height := Args[4].n;

    Result.P := Pointer(Memo);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Memo, MEMO_GC_TAG + '_' + IntToStr(NativeInt(Result.P)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'memo#: ' + E.Message);
  end;
end;

function p_memo_new_text(var Args: array of TAsmData): TAsmData;
var
  Memo: TBasMemo;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateParent(Args[0].P, 'memo#') then
    Exit();
  try
    Memo := TBasMemo.Create(nil);
    Memo.Parent := TFmxObject(Args[0].P);
    Memo.BasicEngine := ModuleEngine;
    Memo.ConsoleOutput := ModuleOutput;
    Memo.Position.X := Args[1].n;
    Memo.Position.Y := Args[2].n;
    Memo.Width := Args[3].n;
    Memo.Height := Args[4].n;
    Memo.Text := Args[5].S;

    Result.P := Pointer(Memo);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Memo, MEMO_GC_TAG + '_' + IntToStr(NativeInt(Result.P)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'memo#: ' + E.Message);
  end;
end;

function n_memo_free(var Args: array of TAsmData): TAsmData;
var
  M: TBasMemo;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_free') then
    Exit();

  try
    M := TBasMemo(Args[0].P);
    M.DisconnectAllEvents();
    M.Free();

    // Use GC to properly free the layout
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_MEMO, 'memo_free: ' + E.Message);
  end;
end;

// ============================================================================
// Text Content Functions
// ============================================================================
function s_memo_text_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_text$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).Text;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_text$: ' + E.Message);
  end;
end;

function p_memo_text_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_text#') then
    Exit();

  try
    TBasMemo(Args[0].P).Text := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_text#: ' + E.Message);
  end;
end;

function n_memo_textlength_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_textlength') then
    Exit();

  try
    Result.n := Length(TBasMemo(Args[0].P).Text);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_textlength: ' + E.Message);
  end;
end;

function p_memo_clear(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_clear#') then
    Exit();

  try
    TBasMemo(Args[0].P).Lines.Clear;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_clear#: ' + E.Message);
  end;
end;

// ============================================================================
// Line-Based Operations
// ============================================================================
function n_memo_linecount(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_linecount') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).Lines.Count;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_linecount: ' + E.Message);
  end;
end;

function s_memo_line_get(var Args: array of TAsmData): TAsmData;
var
  idx: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_line$') then
    Exit();

  try
    idx := Trunc(Args[1].n);
    if (idx >= 0) and (idx < TBasMemo(Args[0].P).Lines.Count) then
      Result.S := TBasMemo(Args[0].P).Lines[idx]
    else
      SetError(ERR_INDEX_BOUNDS, 'memo_line$: Index out of bounds');
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_line$: ' + E.Message);
  end;
end;

function p_memo_line_set(var Args: array of TAsmData): TAsmData;
var
  idx: Integer;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateMemo(Args[0].P, 'memo_line#') then
    Exit();
  try
    idx := Trunc(Args[1].n);
    if (idx >= 0) and (idx < TBasMemo(Args[0].P).Lines.Count) then
      TBasMemo(Args[0].P).Lines[idx] := Args[2].S
    else
      SetError(ERR_INDEX_BOUNDS, 'memo_line#: Index out of bounds');
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_line#: ' + E.Message);
  end;
end;

function p_memo_addline(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateMemo(Args[0].P, 'memo_addline#') then
    Exit();
  try
    TBasMemo(Args[0].P).Lines.Add(Args[1].S);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_addline#: ' + E.Message);
  end;
end;

function p_memo_insertline(var Args: array of TAsmData): TAsmData;
var
  idx: Integer;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_insertline#') then
    Exit();

  try
    idx := Trunc(Args[1].n);
    if (idx >= 0) and (idx <= TBasMemo(Args[0].P).Lines.Count) then
      TBasMemo(Args[0].P).Lines.Insert(idx, Args[2].S)
    else
      SetError(ERR_INDEX_BOUNDS, 'memo_insertline#: Index out of bounds');
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_insertline#: ' + E.Message);
  end;
end;

function p_memo_deleteline(var Args: array of TAsmData): TAsmData;
var
  idx: Integer;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_deleteline#') then
    Exit();

  try
    idx := Trunc(Args[1].n);
    if (idx >= 0) and (idx < TBasMemo(Args[0].P).Lines.Count) then
      TBasMemo(Args[0].P).Lines.Delete(idx)
    else
      SetError(ERR_INDEX_BOUNDS, 'memo_deleteline#: Index out of bounds');
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_deleteline#: ' + E.Message);
  end;
end;

function s_memo_lines_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_lines$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).Lines.Text;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_lines$: ' + E.Message);
  end;
end;

function p_memo_lines_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_lines#') then
    Exit();

  try
    TBasMemo(Args[0].P).Lines.Text := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_lines#: ' + E.Message);
  end;
end;

// ============================================================================
// Word Wrap and Scroll
// ============================================================================
function n_memo_wordwrap_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_wordwrap') then
    Exit();

  try
    if TBasMemo(Args[0].P).WordWrap then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_wordwrap: ' + E.Message);
  end;
end;

function p_memo_wordwrap_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_wordwrap#') then
    Exit();

  try
    TBasMemo(Args[0].P).WordWrap := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_wordwrap#: ' + E.Message);
  end;
end;

function n_memo_showscrollbars_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_showscrollbars') then
    Exit();

  try
    if TBasMemo(Args[0].P).ShowScrollBars then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_showscrollbars: ' + E.Message);
  end;
end;

function p_memo_showscrollbars_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_showscrollbars#') then
    Exit();

  try
    TBasMemo(Args[0].P).ShowScrollBars := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_showscrollbars#: ' + E.Message);
  end;
end;

// ============================================================================
// Read-Only Mode
// ============================================================================
function n_memo_readonly_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_readonly') then
    Exit();

  try
    if TBasMemo(Args[0].P).ReadOnly then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_readonly: ' + E.Message);
  end;
end;

function p_memo_readonly_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_readonly#') then
    Exit();

  try
    TBasMemo(Args[0].P).ReadOnly := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_readonly#: ' + E.Message);
  end;
end;

// ============================================================================
// Font Properties
// ============================================================================
function s_memo_fontfamily_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_fontfamily$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).TextSettings.Font.Family;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_fontfamily$: ' + E.Message);
  end;
end;

function p_memo_fontfamily_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_fontfamily#') then
    Exit();

  try
    TBasMemo(Args[0].P).TextSettings.Font.Family := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_fontfamily#: ' + E.Message);
  end;
end;

function n_memo_fontsize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_fontsize') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).TextSettings.Font.Size;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_fontsize: ' + E.Message);
  end;
end;

function p_memo_fontsize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_fontsize#') then
    Exit();

  try
    TBasMemo(Args[0].P).TextSettings.Font.Size := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_fontsize#: ' + E.Message);
  end;
end;

function s_memo_fontcolor_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_fontcolor$') then
    Exit();

  try
    Result.S := TUtils.AlphaColorToStr(TBasMemo(Args[0].P).TextSettings.FontColor);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_fontcolor$: ' + E.Message);
  end;
end;

function p_memo_fontcolor_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_fontcolor#') then
    Exit();

  try
    TBasMemo(Args[0].P).TextSettings.FontColor := TUtils.ColorToAlphaColor(Args[1].S);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_fontcolor#: ' + E.Message);
  end;
end;

function n_memo_bold_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_bold') then
    Exit();

  try
    if TFontStyle.fsBold in TBasMemo(Args[0].P).TextSettings.Font.Style then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_bold: ' + E.Message);
  end;
end;

function p_memo_bold_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_bold#') then
    Exit();

  try
    if Args[1].n <> 0 then
      TBasMemo(Args[0].P).TextSettings.Font.Style := TBasMemo(Args[0].P).TextSettings.Font.Style + [TFontStyle.fsBold]
    else
      TBasMemo(Args[0].P).TextSettings.Font.Style := TBasMemo(Args[0].P).TextSettings.Font.Style - [TFontStyle.fsBold];
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_bold#: ' + E.Message);
  end;
end;

function n_memo_italic_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_italic') then
    Exit();

  try
    if TFontStyle.fsItalic in TBasMemo(Args[0].P).TextSettings.Font.Style then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_italic: ' + E.Message);
  end;
end;

function p_memo_italic_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_italic#') then
    Exit();

  try
    if Args[1].n <> 0 then
      TBasMemo(Args[0].P).TextSettings.Font.Style := TBasMemo(Args[0].P).TextSettings.Font.Style + [TFontStyle.fsItalic]
    else
      TBasMemo(Args[0].P).TextSettings.Font.Style := TBasMemo(Args[0].P).TextSettings.Font.Style - [TFontStyle.fsItalic];
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_italic#: ' + E.Message);
  end;
end;

function n_memo_underline_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_underline') then
    Exit();

  try
    if TFontStyle.fsUnderline in TBasMemo(Args[0].P).TextSettings.Font.Style then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_underline: ' + E.Message);
  end;
end;

function p_memo_underline_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_underline#') then
    Exit();

  try
    if Args[1].n <> 0 then
      TBasMemo(Args[0].P).TextSettings.Font.Style := TBasMemo(Args[0].P).TextSettings.Font.Style + [TFontStyle.fsUnderline]
    else
      TBasMemo(Args[0].P).TextSettings.Font.Style := TBasMemo(Args[0].P).TextSettings.Font.Style - [TFontStyle.fsUnderline];
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_underline#: ' + E.Message);
  end;
end;

function n_memo_strikeout_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_strikeout') then
    Exit();

  try
    if TFontStyle.fsStrikeOut in TBasMemo(Args[0].P).TextSettings.Font.Style then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_strikeout: ' + E.Message);
  end;
end;

function p_memo_strikeout_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_strikeout#') then
    Exit();

  try
    if Args[1].n <> 0 then
      TBasMemo(Args[0].P).TextSettings.Font.Style := TBasMemo(Args[0].P).TextSettings.Font.Style + [TFontStyle.fsStrikeOut]
    else
      TBasMemo(Args[0].P).TextSettings.Font.Style := TBasMemo(Args[0].P).TextSettings.Font.Style - [TFontStyle.fsStrikeOut];
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_strikeout#: ' + E.Message);
  end;
end;

// ============================================================================
// Text Alignment
// ============================================================================
function n_memo_textalign_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_textalign') then
    Exit();

  try
    Result.n := TextAlignToInt(TBasMemo(Args[0].P).TextSettings.HorzAlign);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_textalign: ' + E.Message);
  end;
end;

function p_memo_textalign_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_textalign#') then
    Exit();

  try
    TBasMemo(Args[0].P).TextSettings.HorzAlign :=
      IntToTextAlign(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_textalign#: ' + E.Message);
  end;
end;

// ============================================================================
// Selection Functions
// ============================================================================
function n_memo_selstart_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_selstart') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).SelStart;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_selstart: ' + E.Message);
  end;
end;

function p_memo_selstart_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_selstart#') then
    Exit();

  try
    TBasMemo(Args[0].P).SelStart := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_selstart#: ' + E.Message);
  end;
end;

function n_memo_sellength_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_sellength') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).SelLength;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_sellength: ' + E.Message);
  end;
end;

function p_memo_sellength_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_sellength#') then
    Exit();

  try
    TBasMemo(Args[0].P).SelLength := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_sellength#: ' + E.Message);
  end;
end;

function s_memo_seltext_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_seltext$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).SelText;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_seltext$: ' + E.Message);
  end;
end;

function p_memo_selectall(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_selectall#') then
    Exit();

  try
    TBasMemo(Args[0].P).SelectAll;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_selectall#: ' + E.Message);
  end;
end;

function p_memo_clearselection(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_clearselection#') then
    Exit();

  try
    TBasMemo(Args[0].P).SelLength := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_clearselection#: ' + E.Message);
  end;
end;

// ============================================================================
// Caret Functions
// ============================================================================
function n_memo_caretposition_getline(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_caretpositionline') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).CaretPosition.Line;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_caretpositionline: ' + E.Message);
  end;
end;

function n_memo_caretposition_getpos(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_caretpositionpos') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).CaretPosition.Pos;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_caretpositionpos: ' + E.Message);
  end;
end;

function p_memo_caretposition_setline(var Args: array of TAsmData): TAsmData;
var
  cpos: TCaretPosition;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_caretpositionline#') then
    Exit();

  cpos.Pos := TBasMemo(Args[0].P).CaretPosition.Pos;
  cpos.Line :=  Trunc(Args[1].n);

  try
    TBasMemo(Args[0].P).CaretPosition := cpos;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_caretpositionline#: ' + E.Message);
  end;
end;

function p_memo_caretposition_setpos(var Args: array of TAsmData): TAsmData;
var
  cpos: TCaretPosition;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_caretpositionline#') then
    Exit();

  cpos.Pos := Trunc(Args[1].n);
  cpos.Line := TBasMemo(Args[0].P).CaretPosition.Line;

  try
    TBasMemo(Args[0].P).CaretPosition := cpos;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_caretpositionline#: ' + E.Message);
  end;
end;

function p_memo_gotoend(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_gotoend#') then
    Exit();

  try
    TBasMemo(Args[0].P).GoToTextEnd;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_gotoend#: ' + E.Message);
  end;
end;

function p_memo_gotobegin(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_gotobegin#') then
    Exit();

  try
    TBasMemo(Args[0].P).GoToTextBegin;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_gotobegin#: ' + E.Message);
  end;
end;

// ============================================================================
// Clipboard Functions
// ============================================================================
function p_memo_copy(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_copy#') then
    Exit();

  try
    TBasMemo(Args[0].P).CopyToClipboard;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_copy#: ' + E.Message);
  end;
end;

function p_memo_cut(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_cut#') then
    Exit();

  try
    TBasMemo(Args[0].P).CutToClipboard;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_cut#: ' + E.Message);
  end;
end;

function p_memo_paste(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_paste#') then
    Exit();

  try
    TBasMemo(Args[0].P).PasteFromClipboard;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_paste#: ' + E.Message);
  end;
end;

function p_memo_deleteselection(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_deleteselection#') then
    Exit();

  try
    TBasMemo(Args[0].P).DeleteSelection;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_deleteselection#: ' + E.Message);
  end;
end;

// ============================================================================
// Position and Size
// ============================================================================
function n_memo_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_x') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).Position.X;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_x: ' + E.Message);
  end;
end;

function p_memo_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_x#') then
    Exit();

  try
    TBasMemo(Args[0].P).Position.X := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_x#: ' + E.Message);
  end;
end;

function n_memo_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_y') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).Position.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_y: ' + E.Message);
  end;
end;

function p_memo_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_y#') then
    Exit();

  try
    TBasMemo(Args[0].P).Position.Y := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_y#: ' + E.Message);
  end;
end;

function n_memo_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_width') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_width: ' + E.Message);
  end;
end;

function p_memo_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_width#') then
    Exit();

  try
    TBasMemo(Args[0].P).Width := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_width#: ' + E.Message);
  end;
end;

function n_memo_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_height') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_height: ' + E.Message);
  end;
end;

function p_memo_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_height#') then
    Exit();

  try
    TBasMemo(Args[0].P).Height := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_height#: ' + E.Message);
  end;
end;

function p_memo_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_bounds#') then
    Exit();

  try
    TBasMemo(Args[0].P).SetBounds(Args[1].n, Args[2].n, Args[3].n, Args[4].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_bounds#: ' + E.Message);
  end;
end;

function p_memo_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_move#') then
    Exit();

  try
    TBasMemo(Args[0].P).Position.X := Args[1].n;
    TBasMemo(Args[0].P).Position.Y := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_move#: ' + E.Message);
  end;
end;

function p_memo_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_size#') then
    Exit();

  try
    TBasMemo(Args[0].P).Width := Args[1].n;
    TBasMemo(Args[0].P).Height := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_size#: ' + E.Message);
  end;
end;

// ============================================================================
// Alignment
// ============================================================================
function n_memo_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_align') then
    Exit();

  try
    Result.n := AlignToInt(TBasMemo(Args[0].P).Align);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_align: ' + E.Message);
  end;
end;

function p_memo_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_align#') then
    Exit();

  try
    TBasMemo(Args[0].P).Align := IntToAlign(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_align#: ' + E.Message);
  end;
end;

// ============================================================================
// Margins
// ============================================================================
function n_memo_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_marginleft') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).Margins.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_marginleft: ' + E.Message);
  end;
end;

function p_memo_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_marginleft#') then
    Exit();

  try
    TBasMemo(Args[0].P).Margins.Left := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_marginleft#: ' + E.Message);
  end;
end;

function n_memo_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_margintop') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).Margins.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_margintop: ' + E.Message);
  end;
end;

function p_memo_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_margintop#') then
    Exit();

  try
    TBasMemo(Args[0].P).Margins.Top := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_margintop#: ' + E.Message);
  end;
end;

function n_memo_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_marginright') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).Margins.Right;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_marginright: ' + E.Message);
  end;
end;

function p_memo_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_marginright#') then
    Exit();

  try
    TBasMemo(Args[0].P).Margins.Right := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_marginright#: ' + E.Message);
  end;
end;

function n_memo_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_marginbottom') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).Margins.Bottom;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_marginbottom: ' + E.Message);
  end;
end;

function p_memo_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_marginbottom#') then
    Exit();

  try
    TBasMemo(Args[0].P).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_marginbottom#: ' + E.Message);
  end;
end;

function p_memo_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_margins#') then
    Exit();

  try
    TBasMemo(Args[0].P).Margins.Left := Args[1].n;
    TBasMemo(Args[0].P).Margins.Top := Args[2].n;
    TBasMemo(Args[0].P).Margins.Right := Args[3].n;
    TBasMemo(Args[0].P).Margins.Bottom := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_margins#: ' + E.Message);
  end;
end;

function p_memo_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_margin#') then
    Exit();

  try
    TBasMemo(Args[0].P).Margins.Left := Args[1].n;
    TBasMemo(Args[0].P).Margins.Top := Args[1].n;
    TBasMemo(Args[0].P).Margins.Right := Args[1].n;
    TBasMemo(Args[0].P).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_margin#: ' + E.Message);
  end;
end;

// ============================================================================
// Visibility
// ============================================================================
function n_memo_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_visible') then
    Exit();

  try
    if TBasMemo(Args[0].P).Visible then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_visible: ' + E.Message);
  end;
end;

function p_memo_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_visible#') then
    Exit();

  try
    TBasMemo(Args[0].P).Visible := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_visible#: ' + E.Message);
  end;
end;

function n_memo_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_enabled') then
    Exit();

  try
    if TBasMemo(Args[0].P).Enabled then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_enabled: ' + E.Message);
  end;
end;

function p_memo_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_enabled#') then
    Exit();

  try
    TBasMemo(Args[0].P).Enabled := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_enabled#: ' + E.Message);
  end;
end;

function n_memo_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_opacity') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).Opacity;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_opacity: ' + E.Message);
  end;
end;

function p_memo_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_opacity#') then
    Exit();

  try
    TBasMemo(Args[0].P).Opacity := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_opacity#: ' + E.Message);
  end;
end;

// ============================================================================
// Focus
// ============================================================================
function n_memo_isfocused_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_isfocused') then
    Exit();

  try
    if TBasMemo(Args[0].P).IsFocused then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_isfocused: ' + E.Message);
  end;
end;

function p_memo_setfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_setfocus#') then
    Exit();

  try
    TBasMemo(Args[0].P).SetFocus;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_setfocus#: ' + E.Message);
  end;
end;

function p_memo_resetfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_resetfocus#') then
    Exit();

  try
    TBasMemo(Args[0].P).ResetFocus;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_resetfocus#: ' + E.Message);
  end;
end;

function n_memo_taborder_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_taborder') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).TabOrder;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_taborder: ' + E.Message);
  end;
end;

function p_memo_taborder_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_taborder#') then
    Exit();

  try
    TBasMemo(Args[0].P).TabOrder := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_taborder#: ' + E.Message);
  end;
end;

// ============================================================================
// Tag
// ============================================================================
function n_memo_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_tag') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).Tag;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_tag: ' + E.Message);
  end;
end;

function p_memo_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_tag#') then
    Exit();

  try
    TBasMemo(Args[0].P).Tag := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_tag#: ' + E.Message);
  end;
end;

// ============================================================================
// Parent
// ============================================================================
function p_memo_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_parent#') then
    Exit();

  try
    Result.P := Pointer(TBasMemo(Args[0].P).Parent);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_parent#: ' + E.Message);
  end;
end;

function p_memo_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_parent#') then
    Exit();
  if not ValidateParent(Args[1].P, 'memo_parent#') then
    Exit();

  try
    TBasMemo(Args[0].P).Parent := TFmxObject(Args[1].P);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_parent#: ' + E.Message);
  end;
end;

function p_memo_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_bringtofront#') then
    Exit();
  try
    TBasMemo(Args[0].P).BringToFront;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_bringtofront#: ' + E.Message);
  end;
end;

function p_memo_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_sendtoback#') then
    Exit();

  try
    TBasMemo(Args[0].P).SendToBack;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_sendtoback#: ' + E.Message);
  end;
end;

// ============================================================================
// Scroll Position
// ============================================================================
function n_memo_scrolltop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_scrolltop') then
    Exit();

  try
    Result.n := TBasMemo(Args[0].P).ViewportPosition.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_scrolltop: ' + E.Message);
  end;
end;

function p_memo_scrolltop_set(var Args: array of TAsmData): TAsmData;
var
  VP: TPointF;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_scrolltop#') then
    Exit();

  try
    VP := TBasMemo(Args[0].P).ViewportPosition;
    VP.Y := Args[1].n;
    TBasMemo(Args[0].P).ViewportPosition := VP;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_scrolltop#: ' + E.Message);
  end;
end;

function p_memo_scrolltoend(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_scrolltoend#') then
    Exit();

  try
    TBasMemo(Args[0].P).GoToTextEnd;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_scrolltoend#: ' + E.Message);
  end;
end;

// ============================================================================
// Event Callbacks
// ============================================================================
function p_memo_onchange_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onchange#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnChangeFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onchange#: ' + E.Message);
  end;
end;

function s_memo_onchange_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onchange$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnChangeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onchange$: ' + E.Message);
  end;
end;

function p_memo_onchangetracking_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onchangetracking#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnChangeTrackingFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onchangetracking#: ' + E.Message);
  end;
end;

function s_memo_onchangetracking_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onchangetracking$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnChangeTrackingFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onchangetracking$: ' + E.Message);
  end;
end;

function p_memo_onenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onenter#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnEnterFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onenter#: ' + E.Message);
  end;
end;

function s_memo_onenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onenter$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onenter$: ' + E.Message);
  end;
end;

function p_memo_onexit_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onexit#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnExitFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onexit#: ' + E.Message);
  end;
end;

function s_memo_onexit_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onexit$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnExitFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onexit$: ' + E.Message);
  end;
end;

function p_memo_onkeydown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onkeydown#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnKeyDownFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onkeydown#: ' + E.Message);
  end;
end;

function s_memo_onkeydown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onkeydown$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnKeyDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onkeydown$: ' + E.Message);
  end;
end;

function p_memo_onkeyup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onkeyup#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnKeyUpFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onkeyup#: ' + E.Message);
  end;
end;

function s_memo_onkeyup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onkeyup$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnKeyUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onkeyup$: ' + E.Message);
  end;
end;

function p_memo_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onclick#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnClickFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onclick#: ' + E.Message);
  end;
end;

function s_memo_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onclick$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onclick$: ' + E.Message);
  end;
end;

function p_memo_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_ondblclick#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnDblClickFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_ondblclick#: ' + E.Message);
  end;
end;

function s_memo_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_ondblclick$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnDblClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_ondblclick$: ' + E.Message);
  end;
end;

function p_memo_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onmousedown#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnMouseDownFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onmousedown#: ' + E.Message);
  end;
end;

function s_memo_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onmousedown$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnMouseDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onmousedown$: ' + E.Message);
  end;
end;

function p_memo_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onmouseup#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnMouseUpFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onmouseup#: ' + E.Message);
  end;
end;

function s_memo_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onmouseup$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnMouseUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onmouseup$: ' + E.Message);
  end;
end;

function p_memo_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onmousemove#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnMouseMoveFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onmousemove#: ' + E.Message);
  end;
end;

function s_memo_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onmousemove$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnMouseMoveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onmousemove$: ' + E.Message);
  end;
end;

function p_memo_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onmouseenter#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnMouseEnterFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onmouseenter#: ' + E.Message);
  end;
end;

function s_memo_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onmouseenter$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnMouseEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onmouseenter$: ' + E.Message);
  end;
end;

function p_memo_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onmouseleave#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnMouseLeaveFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onmouseleave#: ' + E.Message);
  end;
end;

function s_memo_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onmouseleave$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnMouseLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onmouseleave$: ' + E.Message);
  end;
end;

function p_memo_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onresize#') then
    Exit();

  try
    TBasMemo(Args[0].P).OnResizeFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onresize#: ' + E.Message);
  end;
end;

function s_memo_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_onresize$') then
    Exit();

  try
    Result.S := TBasMemo(Args[0].P).OnResizeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_onresize$: ' + E.Message);
  end;
end;

// edit_ondragenter#(edit#, funcname$) - Set OnDragEnter handler
function p_memo_ondragenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateMemo(Args[0].p, 'memo_ondragenter#') then
    Exit();
  try
    TBasMemo(Args[0].p).OnDragEnterFunc := Args[1].s;
    except
      on E: Exception do
        SetError(ERR_OPERATION_FAILED, 'memo_ondragenter#: ' + E.Message);
    end;
end;

// memo_ondragenter$(edit#) - Get OnDragEnter handler
function s_memo_ondragenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateMemo(Args[0].p, 'memo_ondragenter$') then
    Exit();
  try
    Result.s := TBasMemo(Args[0].p).OnDragEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_ondragenter$: ' + E.Message);
  end;
end;

// memo_ondragover#(edit#, funcname$) - Set OnDragOver handler
function p_memo_ondragover_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateMemo(Args[0].p, 'memo_ondragover#') then
    Exit();
  try
    TBasMemo(Args[0].p).OnDragOverFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_ondragover#: ' + E.Message);
  end;
end;

// memo_ondragover$(edit#) - Get OnDragOver handler
function s_memo_ondragover_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateMemo(Args[0].p, 'memo_ondragover$') then
    Exit();
  try
    Result.s := TBasMemo(Args[0].p).OnDragOverFunc;
    except
      on E: Exception do
        SetError(ERR_OPERATION_FAILED, 'memo_ondragover$: ' + E.Message);
    end;
end;

// memo_ondragdrop#(edit#, funcname$) - Set OnDragDrop handler
function p_memo_ondragdrop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateMemo(Args[0].p, 'memo_ondragdrop#') then
    Exit();
  try
    TBasMemo(Args[0].p).OnDragDropFunc := Args[1].s;
    except
      on E: Exception do
        SetError(ERR_OPERATION_FAILED, 'memo_ondragdrop#: ' + E.Message);
    end;
end;

// memo_ondragdrop$(edit#) - Get OnDragDrop handler
function s_memo_ondragdrop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateMemo(Args[0].p, 'memo_ondragdrop$') then
    Exit();
  try
    Result.s := TBasMemo(Args[0].p).OnDragDropFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_ondragdrop$: ' + E.Message);
  end;
end;

// memo_ondragleave#(edit#, funcname$) - Set OnDragLeave handler
function p_memo_ondragleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateMemo(Args[0].p, 'memo_ondragleave#') then
    Exit();
  try
    TBasMemo(Args[0].p).OnDragLeaveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_ondragleave#: ' + E.Message);
  end;
end;

// memo_ondragleave$(edit#) - Get OnDragLeave handler
function s_memo_ondragleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateMemo(Args[0].p, 'memo_ondragleave$') then
    Exit();
  try
    Result.s := TBasMemo(Args[0].p).OnDragLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_ondragleave$: ' + E.Message);
  end;
end;

function p_memo_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateMemo(Args[0].P, 'memo_clearcallbacks#') then
    Exit();

  try
    with TBasMemo(Args[0].P) do
    begin
      OnChangeFunc := '';
      OnChangeTrackingFunc := '';
      OnEnterFunc := '';
      OnExitFunc := '';
      OnKeyDownFunc := '';
      OnKeyUpFunc := '';
      OnClickFunc := '';
      OnDblClickFunc := '';
      OnMouseDownFunc := '';
      OnMouseUpFunc := '';
      OnMouseMoveFunc := '';
      OnMouseEnterFunc := '';
      OnMouseLeaveFunc := '';
      OnResizeFunc := '';
      OnDragEnterFunc := '';
      OnDragOverFunc := '';
      OnDragDropFunc := '';
      OnDragLeaveFunc := '';
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'memo_clearcallbacks#: ' + E.Message);
  end;
end;

// ============================================================================
// Library Registration
// ============================================================================
procedure RegisterMemoFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine;
  OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_memo_error; Lib.Add('memo_error@', Fn);
  Fn.Entry := @s_memo_errormsg; Lib.Add('memo_errormsg$@', Fn);
  Fn.Entry := @s_memo_strerror; Lib.Add('memo_strerror$@n', Fn);
  Fn.Entry := @n_memo_clearerror; Lib.Add('memo_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_memo_new; Lib.Add('memo#@#', Fn);
  Fn.Entry := @p_memo_new_pos; Lib.Add('memo#@#nnnn', Fn);
  Fn.Entry := @p_memo_new_text; Lib.Add('memo#@#nnnn$', Fn);
  Fn.Entry := @n_memo_free; Lib.Add('memo_free@#', Fn);

  // Text content
  Fn.Entry := @s_memo_text_get; Lib.Add('memo_text$@#', Fn);
  Fn.Entry := @p_memo_text_set; Lib.Add('memo_text#@#$', Fn);
  Fn.Entry := @n_memo_textlength_get; Lib.Add('memo_textlength@#', Fn);
  Fn.Entry := @p_memo_clear; Lib.Add('memo_clear#@#', Fn);

  // Line-based operations
  Fn.Entry := @n_memo_linecount; Lib.Add('memo_linecount@#', Fn);
  Fn.Entry := @s_memo_line_get; Lib.Add('memo_line$@#n', Fn);
  Fn.Entry := @p_memo_line_set; Lib.Add('memo_line#@#n$', Fn);
  Fn.Entry := @p_memo_addline; Lib.Add('memo_addline#@#$', Fn);
  Fn.Entry := @p_memo_insertline; Lib.Add('memo_insertline#@#n$', Fn);
  Fn.Entry := @p_memo_deleteline; Lib.Add('memo_deleteline#@#n', Fn);
  Fn.Entry := @s_memo_lines_get; Lib.Add('memo_lines$@#', Fn);
  Fn.Entry := @p_memo_lines_set; Lib.Add('memo_lines#@#$', Fn);

  // Word wrap and scroll
  Fn.Entry := @n_memo_wordwrap_get; Lib.Add('memo_wordwrap@#', Fn);
  Fn.Entry := @p_memo_wordwrap_set; Lib.Add('memo_wordwrap#@#n', Fn);
  Fn.Entry := @n_memo_showscrollbars_get; Lib.Add('memo_showscrollbars@#', Fn);
  Fn.Entry := @p_memo_showscrollbars_set; Lib.Add('memo_showscrollbars#@#n', Fn);

  // Read-only
  Fn.Entry := @n_memo_readonly_get; Lib.Add('memo_readonly@#', Fn);
  Fn.Entry := @p_memo_readonly_set; Lib.Add('memo_readonly#@#n', Fn);

  // Font properties
  Fn.Entry := @s_memo_fontfamily_get; Lib.Add('memo_fontfamily$@#', Fn);
  Fn.Entry := @p_memo_fontfamily_set; Lib.Add('memo_fontfamily#@#$', Fn);
  Fn.Entry := @n_memo_fontsize_get; Lib.Add('memo_fontsize@#', Fn);
  Fn.Entry := @p_memo_fontsize_set; Lib.Add('memo_fontsize#@#n', Fn);
  Fn.Entry := @s_memo_fontcolor_get; Lib.Add('memo_fontcolor$@#', Fn);
  Fn.Entry := @p_memo_fontcolor_set; Lib.Add('memo_fontcolor#@#$', Fn);
  Fn.Entry := @n_memo_bold_get; Lib.Add('memo_bold@#', Fn);
  Fn.Entry := @p_memo_bold_set; Lib.Add('memo_bold#@#n', Fn);
  Fn.Entry := @n_memo_italic_get; Lib.Add('memo_italic@#', Fn);
  Fn.Entry := @p_memo_italic_set; Lib.Add('memo_italic#@#n', Fn);
  Fn.Entry := @n_memo_underline_get; Lib.Add('memo_underline@#', Fn);
  Fn.Entry := @p_memo_underline_set; Lib.Add('memo_underline#@#n', Fn);
  Fn.Entry := @n_memo_strikeout_get; Lib.Add('memo_strikeout@#', Fn);
  Fn.Entry := @p_memo_strikeout_set; Lib.Add('memo_strikeout#@#n', Fn);

  // Text alignment
  Fn.Entry := @n_memo_textalign_get; Lib.Add('memo_textalign@#', Fn);
  Fn.Entry := @p_memo_textalign_set; Lib.Add('memo_textalign#@#n', Fn);

  // Selection
  Fn.Entry := @n_memo_selstart_get; Lib.Add('memo_selstart@#', Fn);
  Fn.Entry := @p_memo_selstart_set; Lib.Add('memo_selstart#@#n', Fn);
  Fn.Entry := @n_memo_sellength_get; Lib.Add('memo_sellength@#', Fn);
  Fn.Entry := @p_memo_sellength_set; Lib.Add('memo_sellength#@#n', Fn);
  Fn.Entry := @s_memo_seltext_get; Lib.Add('memo_seltext$@#', Fn);
  Fn.Entry := @p_memo_selectall; Lib.Add('memo_selectall#@#', Fn);
  Fn.Entry := @p_memo_clearselection; Lib.Add('memo_clearselection#@#', Fn);

  // Caret
  Fn.Entry := @n_memo_caretposition_getline; Lib.Add('memo_caretpositionline@#', Fn);
  Fn.Entry := @n_memo_caretposition_getpos; Lib.Add('memo_caretpositionpos@#', Fn);
  Fn.Entry := @p_memo_caretposition_setline; Lib.Add('memo_caretpositionline#@#n', Fn);
  Fn.Entry := @p_memo_caretposition_setpos; Lib.Add('memo_caretpositionpos#@#n', Fn);
  Fn.Entry := @p_memo_gotoend; Lib.Add('memo_gotoend#@#', Fn);
  Fn.Entry := @p_memo_gotobegin; Lib.Add('memo_gotobegin#@#', Fn);

  // Clipboard
  Fn.Entry := @p_memo_copy; Lib.Add('memo_copy#@#', Fn);
  Fn.Entry := @p_memo_cut; Lib.Add('memo_cut#@#', Fn);
  Fn.Entry := @p_memo_paste; Lib.Add('memo_paste#@#', Fn);
  Fn.Entry := @p_memo_deleteselection; Lib.Add('memo_deleteselection#@#', Fn);

  // Position and Size
  Fn.Entry := @n_memo_x_get; Lib.Add('memo_x@#', Fn);
  Fn.Entry := @p_memo_x_set; Lib.Add('memo_x#@#n', Fn);
  Fn.Entry := @n_memo_y_get; Lib.Add('memo_y@#', Fn);
  Fn.Entry := @p_memo_y_set; Lib.Add('memo_y#@#n', Fn);
  Fn.Entry := @n_memo_width_get; Lib.Add('memo_width@#', Fn);
  Fn.Entry := @p_memo_width_set; Lib.Add('memo_width#@#n', Fn);
  Fn.Entry := @n_memo_height_get; Lib.Add('memo_height@#', Fn);
  Fn.Entry := @p_memo_height_set; Lib.Add('memo_height#@#n', Fn);
  Fn.Entry := @p_memo_bounds_set; Lib.Add('memo_bounds#@#nnnn', Fn);
  Fn.Entry := @p_memo_move_set; Lib.Add('memo_move#@#nn', Fn);
  Fn.Entry := @p_memo_size_set; Lib.Add('memo_size#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_memo_align_get; Lib.Add('memo_align@#', Fn);
  Fn.Entry := @p_memo_align_set; Lib.Add('memo_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_memo_marginleft_get; Lib.Add('memo_marginleft@#', Fn);
  Fn.Entry := @p_memo_marginleft_set; Lib.Add('memo_marginleft#@#n', Fn);
  Fn.Entry := @n_memo_margintop_get; Lib.Add('memo_margintop@#', Fn);
  Fn.Entry := @p_memo_margintop_set; Lib.Add('memo_margintop#@#n', Fn);
  Fn.Entry := @n_memo_marginright_get; Lib.Add('memo_marginright@#', Fn);
  Fn.Entry := @p_memo_marginright_set; Lib.Add('memo_marginright#@#n', Fn);
  Fn.Entry := @n_memo_marginbottom_get; Lib.Add('memo_marginbottom@#', Fn);
  Fn.Entry := @p_memo_marginbottom_set; Lib.Add('memo_marginbottom#@#n', Fn);
  Fn.Entry := @p_memo_margins_set; Lib.Add('memo_margins#@#nnnn', Fn);
  Fn.Entry := @p_memo_margin_set; Lib.Add('memo_margin#@#n', Fn);

  // Visibility
  Fn.Entry := @n_memo_visible_get; Lib.Add('memo_visible@#', Fn);
  Fn.Entry := @p_memo_visible_set; Lib.Add('memo_visible#@#n', Fn);
  Fn.Entry := @n_memo_enabled_get; Lib.Add('memo_enabled@#', Fn);
  Fn.Entry := @p_memo_enabled_set; Lib.Add('memo_enabled#@#n', Fn);
  Fn.Entry := @n_memo_opacity_get; Lib.Add('memo_opacity@#', Fn);
  Fn.Entry := @p_memo_opacity_set; Lib.Add('memo_opacity#@#n', Fn);

  // Focus
  Fn.Entry := @n_memo_isfocused_get; Lib.Add('memo_isfocused@#', Fn);
  Fn.Entry := @p_memo_setfocus; Lib.Add('memo_setfocus#@#', Fn);
  Fn.Entry := @p_memo_resetfocus; Lib.Add('memo_resetfocus#@#', Fn);
  Fn.Entry := @n_memo_taborder_get; Lib.Add('memo_taborder@#', Fn);
  Fn.Entry := @p_memo_taborder_set; Lib.Add('memo_taborder#@#n', Fn);

  // Tag
  Fn.Entry := @n_memo_tag_get; Lib.Add('memo_tag@#', Fn);
  Fn.Entry := @p_memo_tag_set; Lib.Add('memo_tag#@#n', Fn);

  // Parent
  Fn.Entry := @p_memo_parent_get; Lib.Add('memo_parent#@#', Fn);
  Fn.Entry := @p_memo_parent_set; Lib.Add('memo_parent#@##', Fn);
  Fn.Entry := @p_memo_bringtofront; Lib.Add('memo_bringtofront#@#', Fn);
  Fn.Entry := @p_memo_sendtoback; Lib.Add('memo_sendtoback#@#', Fn);

  // Scroll
  Fn.Entry := @n_memo_scrolltop_get; Lib.Add('memo_scrolltop@#', Fn);
  Fn.Entry := @p_memo_scrolltop_set; Lib.Add('memo_scrolltop#@#n', Fn);
  Fn.Entry := @p_memo_scrolltoend; Lib.Add('memo_scrolltoend#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_memo_onchange_set; Lib.Add('memo_onchange#@#$', Fn);
  Fn.Entry := @s_memo_onchange_get; Lib.Add('memo_onchange$@#', Fn);
  Fn.Entry := @p_memo_onchangetracking_set; Lib.Add('memo_onchangetracking#@#$', Fn);
  Fn.Entry := @s_memo_onchangetracking_get; Lib.Add('memo_onchangetracking$@#', Fn);
  Fn.Entry := @p_memo_onenter_set; Lib.Add('memo_onenter#@#$', Fn);
  Fn.Entry := @s_memo_onenter_get; Lib.Add('memo_onenter$@#', Fn);
  Fn.Entry := @p_memo_onexit_set; Lib.Add('memo_onexit#@#$', Fn);
  Fn.Entry := @s_memo_onexit_get; Lib.Add('memo_onexit$@#', Fn);
  Fn.Entry := @p_memo_onkeydown_set; Lib.Add('memo_onkeydown#@#$', Fn);
  Fn.Entry := @s_memo_onkeydown_get; Lib.Add('memo_onkeydown$@#', Fn);
  Fn.Entry := @p_memo_onkeyup_set; Lib.Add('memo_onkeyup#@#$', Fn);
  Fn.Entry := @s_memo_onkeyup_get; Lib.Add('memo_onkeyup$@#', Fn);
  Fn.Entry := @p_memo_onclick_set; Lib.Add('memo_onclick#@#$', Fn);
  Fn.Entry := @s_memo_onclick_get; Lib.Add('memo_onclick$@#', Fn);
  Fn.Entry := @p_memo_ondblclick_set; Lib.Add('memo_ondblclick#@#$', Fn);
  Fn.Entry := @s_memo_ondblclick_get; Lib.Add('memo_ondblclick$@#', Fn);
  Fn.Entry := @p_memo_onmousedown_set; Lib.Add('memo_onmousedown#@#$', Fn);
  Fn.Entry := @s_memo_onmousedown_get; Lib.Add('memo_onmousedown$@#', Fn);
  Fn.Entry := @p_memo_onmouseup_set; Lib.Add('memo_onmouseup#@#$', Fn);
  Fn.Entry := @s_memo_onmouseup_get; Lib.Add('memo_onmouseup$@#', Fn);
  Fn.Entry := @p_memo_onmousemove_set; Lib.Add('memo_onmousemove#@#$', Fn);
  Fn.Entry := @s_memo_onmousemove_get; Lib.Add('memo_onmousemove$@#', Fn);
  Fn.Entry := @p_memo_onmouseenter_set; Lib.Add('memo_onmouseenter#@#$', Fn);
  Fn.Entry := @s_memo_onmouseenter_get; Lib.Add('memo_onmouseenter$@#', Fn);
  Fn.Entry := @p_memo_onmouseleave_set; Lib.Add('memo_onmouseleave#@#$', Fn);
  Fn.Entry := @s_memo_onmouseleave_get; Lib.Add('memo_onmouseleave$@#', Fn);
  Fn.Entry := @p_memo_onresize_set; Lib.Add('memo_onresize#@#$', Fn);
  Fn.Entry := @s_memo_onresize_get; Lib.Add('memo_onresize$@#', Fn);
  Fn.Entry := @p_memo_ondragenter_set; Lib.Add('memo_ondragenter#@#$', Fn);
  Fn.Entry := @s_memo_ondragenter_get; Lib.Add('memo_ondragenter$@#', Fn);
  Fn.Entry := @p_memo_ondragover_set; Lib.Add('memo_ondragover#@#$', Fn);
  Fn.Entry := @s_memo_ondragover_get; Lib.Add('memo_ondragover$@#', Fn);
  Fn.Entry := @p_memo_ondragdrop_set; Lib.Add('memo_ondragdrop#@#$', Fn);
  Fn.Entry := @s_memo_ondragdrop_get; Lib.Add('memo_ondragdrop$@#', Fn);
  Fn.Entry := @p_memo_ondragleave_set; Lib.Add('memo_ondragleave#@#$', Fn);
  Fn.Entry := @s_memo_ondragleave_get; Lib.Add('memo_ondragleave$@#', Fn);
  Fn.Entry := @p_memo_clearcallbacks; Lib.Add('memo_clearcallbacks#@#', Fn);
end;

end.

