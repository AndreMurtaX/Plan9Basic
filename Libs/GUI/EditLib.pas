unit EditLib;

{ ******************************************************************************
  EditLib - Text Edit Control Library for Plan9Basic
  Version: 1.0.0
  Function Count: 115 functions
  Copyright (c) 2024-2025 Plan9Basic Project
  ****************************************************************************** }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Edit,
  FMX.Controls.Presentation, FMX.Text,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, ControlCommon;

type
  TBasEdit = class(TEdit)
  private
    FOnChangeFunc, FOnChangeTrackingFunc, FOnTypingFunc: String;
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
    procedure InternalOnTyping(Sender: TObject);
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
    procedure SetOnTypingFunc(const Value: String);
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
    property OnTypingFunc: String read FOnTypingFunc write SetOnTypingFunc;
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

procedure RegisterEditFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  EDIT_GC_TAG = 'BASIC_EDIT';
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_EDIT = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;


  TEXT_ALIGN_LEADING = 0;
  TEXT_ALIGN_CENTER = 1;
  TEXT_ALIGN_TRAILING = 2;

var
  lastError: Integer;
  lastErrorMsg: String;

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

function ValidateEdit(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_EDIT, FuncName + ': Nil pointer');
    Exit();
  end;

  try
    if not(IsHandleOf(P, TBasEdit)) then
    begin
      SetError(ERR_INVALID_EDIT, FuncName + ': Invalid object');
      Exit();
    end;
  except
    SetError(ERR_INVALID_EDIT, FuncName + ': Invalid pointer');
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

function IntToKeyboardType(Value: Integer): TVirtualKeyboardType;
begin
  case Value of
    0: Result := TVirtualKeyboardType.Default;
    1: Result := TVirtualKeyboardType.NumbersAndPunctuation;
    2: Result := TVirtualKeyboardType.NumberPad;
    3: Result := TVirtualKeyboardType.PhonePad;
    7: Result := TVirtualKeyboardType.EmailAddress;
  else
    Result := TVirtualKeyboardType.Default;
  end;
end;

function KeyboardTypeToInt(Value: TVirtualKeyboardType): Integer;
begin
  case Value of
    TVirtualKeyboardType.Default: Result := 0;
    TVirtualKeyboardType.NumbersAndPunctuation: Result := 1;
    TVirtualKeyboardType.NumberPad: Result := 2;
    TVirtualKeyboardType.PhonePad: Result := 3;
    TVirtualKeyboardType.EmailAddress: Result := 7;
  else
    Result := 0;
  end;
end;

function IntToReturnKeyType(Value: Integer): TReturnKeyType;
begin
  case Value of
    0: Result := TReturnKeyType.Default;
    1: Result := TReturnKeyType.Done;
    2: Result := TReturnKeyType.Go;
    3: Result := TReturnKeyType.Next;
    4: Result := TReturnKeyType.Search;
  else
    Result := TReturnKeyType.Default;
  end;
end;

function ReturnKeyTypeToInt(Value: TReturnKeyType): Integer;
begin
  case Value of
    TReturnKeyType.Default: Result := 0;
    TReturnKeyType.Done: Result := 1;
    TReturnKeyType.Go: Result := 2;
    TReturnKeyType.Next: Result := 3;
    TReturnKeyType.Search: Result := 4;
  else
    Result := 0;
  end;
end;

constructor TBasEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);
  FOnChangeFunc := '';
  FOnChangeTrackingFunc := '';
  FOnTypingFunc := '';
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
end;

destructor TBasEdit.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasEdit.DisconnectAllEvents();
begin
  Self.OnChange := nil;
  Self.OnChangeTracking := nil;
  Self.OnTyping := nil;
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

procedure TBasEdit.SetOnChangeFunc(const Value: String);
begin
  FOnChangeFunc := Value;
  if Value <> '' then
    Self.OnChange := InternalOnChange
  else
    Self.OnChange := nil;
end;

procedure TBasEdit.SetOnChangeTrackingFunc(const Value: String);
begin
  FOnChangeTrackingFunc := Value;
  if Value <> '' then
    Self.OnChangeTracking := InternalOnChangeTracking
  else
    Self.OnChangeTracking := nil;
end;

procedure TBasEdit.SetOnTypingFunc(const Value: String);
begin
  FOnTypingFunc := Value;
  if Value <> '' then
    Self.OnTyping := InternalOnTyping
  else
    Self.OnTyping := nil;
end;

procedure TBasEdit.SetOnEnterFunc(const Value: String);
begin
  FOnEnterFunc := Value;
  if Value <> '' then
    Self.OnEnter := InternalOnEnter
  else
    Self.OnEnter := nil;
end;

procedure TBasEdit.SetOnExitFunc(const Value: String);
begin
  FOnExitFunc := Value;
  if Value <> '' then
    Self.OnExit := InternalOnExit
  else
    Self.OnExit := nil;
end;

procedure TBasEdit.SetOnKeyDownFunc(const Value: String);
begin
  FOnKeyDownFunc := Value;
  if Value <> '' then
    Self.OnKeyDown := InternalOnKeyDown
  else
    Self.OnKeyDown := nil;
end;

procedure TBasEdit.SetOnKeyUpFunc(const Value: String);
begin
  FOnKeyUpFunc := Value;
  if Value <> '' then
    Self.OnKeyUp := InternalOnKeyUp
  else
    Self.OnKeyUp := nil;
end;

procedure TBasEdit.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    Self.OnClick := InternalOnClick
  else
    Self.OnClick := nil;
end;

procedure TBasEdit.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    Self.OnDblClick := InternalOnDblClick
  else
    Self.OnDblClick := nil;
end;

procedure TBasEdit.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    Self.OnDragEnter := InternalOnDragEnter
  else
    Self.OnDragEnter := nil;
end;

procedure TBasEdit.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    Self.OnDragOver := InternalOnDragOver
  else
    Self.OnDragOver := nil;
end;

procedure TBasEdit.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    Self.OnDragDrop := InternalOnDragDrop
  else
    Self.OnDragDrop := nil;
end;

procedure TBasEdit.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    Self.OnDragLeave := InternalOnDragLeave
  else
    Self.OnDragLeave := nil;
end;

procedure TBasEdit.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    Self.OnMouseDown := InternalOnMouseDown
  else
    Self.OnMouseDown := nil;
end;

procedure TBasEdit.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    Self.OnMouseUp := InternalOnMouseUp
  else
    Self.OnMouseUp := nil;
end;

procedure TBasEdit.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    Self.OnMouseMove := InternalOnMouseMove
  else
    Self.OnMouseMove := nil;
end;

procedure TBasEdit.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    Self.OnMouseEnter := InternalOnMouseEnter
  else
    Self.OnMouseEnter := nil;
end;

procedure TBasEdit.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    Self.OnMouseLeave := InternalOnMouseLeave
  else
    Self.OnMouseLeave := nil;
end;

procedure TBasEdit.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    Self.OnResize := InternalOnResize
  else
    Self.OnResize := nil;
end;

procedure TBasEdit.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'Edit');
end;

function TBasEdit.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
begin
  Result := ControlCommon.RunCallbackWithResult(FBasicEngine, FConsoleOutput,
                          FuncSignature, Args, 'Edit');
end;

procedure TBasEdit.InternalOnChange(Sender: TObject);
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

procedure TBasEdit.InternalOnChangeTracking(Sender: TObject);
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

procedure TBasEdit.InternalOnTyping(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
begin
  if FOnTypingFunc = '' then
    Exit();

  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';

  ExecuteCallback(LowerCase(FOnTypingFunc) + '@#', Args);
end;

procedure TBasEdit.InternalOnEnter(Sender: TObject);
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

procedure TBasEdit.InternalOnExit(Sender: TObject);
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

procedure TBasEdit.InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
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

procedure TBasEdit.InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
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

procedure TBasEdit.InternalOnClick(Sender: TObject);
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

procedure TBasEdit.InternalOnDblClick(Sender: TObject);
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

procedure TBasEdit.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasEdit.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
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

procedure TBasEdit.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasEdit.InternalOnDragLeave(Sender: TObject);
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

procedure TBasEdit.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasEdit.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasEdit.InternalOnMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
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

procedure TBasEdit.InternalOnMouseEnter(Sender: TObject);
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

procedure TBasEdit.InternalOnMouseLeave(Sender: TObject);
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

procedure TBasEdit.InternalOnResize(Sender: TObject);
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

// Error Functions
function n_edit_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.P := nil;
  Result.S := '';
end;

function s_edit_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := lastErrorMsg;
end;

function s_edit_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  case Trunc(Args[0].n) of
    0: Result.S := 'No error';
    1: Result.S := 'Invalid edit';
    2: Result.S := 'Invalid parent';
    3: Result.S := 'Invalid value';
    4: Result.S := 'Create failed';
  else
    Result.S := 'Unknown error';
  end;
end;

function n_edit_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  ClearError();
end;

// Creation Functions
function p_edit_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Edit: TBasEdit;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateParent(Args[0].P, 'edit#') then
    Exit();

  try
    Edit := TBasEdit.Create(nil);
    Edit.Parent := TFmxObject(Args[0].P);
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Edit, Eng, Outp) then
    begin
      Edit.BasicEngine := Eng;
      Edit.ConsoleOutput := Outp;
    end;
    Edit.StyledSettings := Edit.StyledSettings - [TStyledSetting.Family, TStyledSetting.Size, TStyledSetting.Style, TStyledSetting.FontColor];

    Result.P := Pointer(Edit);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      GC.Add(Edit, EDIT_GC_TAG + '_' + IntToStr(NativeInt(Result.P)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'edit#: ' + E.Message);
  end;
end;

function p_edit_new_pos(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Edit: TBasEdit;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateParent(Args[0].P, 'edit#') then
    Exit();

  try
    Edit := TBasEdit.Create(nil);
    Edit.Parent := TFmxObject(Args[0].P);
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Edit, Eng, Outp) then
    begin
      Edit.BasicEngine := Eng;
      Edit.ConsoleOutput := Outp;
    end;
    Edit.Position.X := Args[1].n;
    Edit.Position.Y := Args[2].n;
    Edit.Width := Args[3].n;
    Edit.Height := Args[4].n;
    Edit.StyledSettings := Edit.StyledSettings - [TStyledSetting.Family, TStyledSetting.Size, TStyledSetting.Style, TStyledSetting.FontColor];

    Result.P := Pointer(Edit);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      GC.Add(Edit, EDIT_GC_TAG + '_' + IntToStr(NativeInt(Result.P)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'edit#: ' + E.Message);
  end;
end;

function p_edit_new_text(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Edit: TBasEdit;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateParent(Args[0].P, 'edit#') then
    Exit();
  try
    Edit := TBasEdit.Create(nil);
    Edit.Parent := TFmxObject(Args[0].P);
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Edit, Eng, Outp) then
    begin
      Edit.BasicEngine := Eng;
      Edit.ConsoleOutput := Outp;
    end;
    Edit.Position.X := Args[1].n;
    Edit.Position.Y := Args[2].n;
    Edit.Width := Args[3].n;
    Edit.Height := Args[4].n;
    Edit.Text := Args[5].S;
    Edit.StyledSettings := Edit.StyledSettings - [TStyledSetting.Family,
      TStyledSetting.Size, TStyledSetting.Style, TStyledSetting.FontColor];

    Result.P := Pointer(Edit);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      GC.Add(Edit, EDIT_GC_TAG + '_' + IntToStr(NativeInt(Result.P)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'edit#: ' + E.Message);
  end;
end;

function n_edit_free(var Args: array of TAsmData): TAsmData;
var
  Edt: TBasEdit;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_free') then
    Exit();

  try
    Edt := TBasEdit(Args[0].P);
    Edt.DisconnectAllEvents();
    Edt.Free();

    // Free via GC using individualized tag
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(EDIT_GC_TAG + '_' + IntToStr(NativeInt(Args[0].P)));
//      Result.n := 1;
//    end;
    ClearError();
    //Its eighty-one siblings answer 1 on success. This one did too, inside
    //the collector block that was commented out.
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EDIT, 'edit_free: ' + E.Message);
  end;
end;

// Text Content Functions
function s_edit_text_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_text$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).Text;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_text$: ' + E.Message);
  end;
end;

function p_edit_text_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_text#') then
    Exit();
  try
    TBasEdit(Args[0].P).Text := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_text#: ' + E.Message);
  end;
end;

function s_edit_prompt_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_prompt$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).TextPrompt;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_prompt$: ' + E.Message);
  end;
end;

function p_edit_prompt_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_prompt#') then
    Exit();
  try
    TBasEdit(Args[0].P).TextPrompt := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_prompt#: ' + E.Message);
  end;
end;

function n_edit_maxlength_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_maxlength') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).MaxLength;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_maxlength: ' + E.Message);
  end;
end;

function p_edit_maxlength_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_maxlength#') then
    Exit();

  try
    TBasEdit(Args[0].P).MaxLength := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_maxlength#: ' + E.Message);
  end;
end;

function n_edit_textlength_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_textlength') then
    Exit();

  try
    Result.n := Length(TBasEdit(Args[0].P).Text);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_textlength: ' + E.Message);
  end;
end;

// Password Mode
function n_edit_password_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_password') then
    Exit();
  try
    if TBasEdit(Args[0].P).Password then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_password: ' + E.Message);
  end;
end;

function p_edit_password_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_password#') then
    Exit();
  try
    TBasEdit(Args[0].P).Password := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_password#: ' + E.Message);
  end;
end;

// Read-Only Mode
function n_edit_readonly_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_readonly') then
    Exit();
  try
    if TBasEdit(Args[0].P).ReadOnly then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_readonly: ' + E.Message);
  end;
end;

function p_edit_readonly_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_readonly#') then
    Exit();
  try
    TBasEdit(Args[0].P).ReadOnly := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_readonly#: ' + E.Message);
  end;
end;

// Font Properties
function s_edit_fontfamily_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_fontfamily$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).TextSettings.Font.Family;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_fontfamily$: ' + E.Message);
  end;
end;

function p_edit_fontfamily_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_fontfamily#') then
    Exit();
  try
    TBasEdit(Args[0].P).TextSettings.Font.Family := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_fontfamily#: ' + E.Message);
  end;
end;

function n_edit_fontsize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_fontsize') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).TextSettings.Font.Size;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_fontsize: ' + E.Message);
  end;
end;

function p_edit_fontsize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_fontsize#') then
    Exit();
  try
    TBasEdit(Args[0].P).TextSettings.Font.Size := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_fontsize#: ' + E.Message);
  end;
end;

function s_edit_fontcolor_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_fontcolor$') then
    Exit();
  try
    Result.S := TUtils.AlphaColorToStr(TBasEdit(Args[0].P).TextSettings.FontColor);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_fontcolor$: ' + E.Message);
  end;
end;

function p_edit_fontcolor_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_fontcolor#') then
    Exit();
  try
    TBasEdit(Args[0].P).TextSettings.FontColor := TUtils.ColorToAlphaColor(Args[1].S);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_fontcolor#: ' + E.Message);
  end;
end;

function n_edit_bold_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_bold') then
    Exit();
  try
    if TFontStyle.fsBold in TBasEdit(Args[0].P).TextSettings.Font.Style then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_bold: ' + E.Message);
  end;
end;

function p_edit_bold_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_bold#') then
    Exit();
  try
    if Args[1].n <> 0 then
      TBasEdit(Args[0].P).TextSettings.Font.Style := TBasEdit(Args[0].P)
        .TextSettings.Font.Style + [TFontStyle.fsBold]
    else
      TBasEdit(Args[0].P).TextSettings.Font.Style := TBasEdit(Args[0].P)
        .TextSettings.Font.Style - [TFontStyle.fsBold];
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_bold#: ' + E.Message);
  end;
end;

function n_edit_italic_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_italic') then
    Exit();
  try
    if TFontStyle.fsItalic in TBasEdit(Args[0].P).TextSettings.Font.Style then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_italic: ' + E.Message);
  end;
end;

function p_edit_italic_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_italic#') then
    Exit();
  try
    if Args[1].n <> 0 then
      TBasEdit(Args[0].P).TextSettings.Font.Style := TBasEdit(Args[0].P).TextSettings.Font.Style + [TFontStyle.fsItalic]
    else
      TBasEdit(Args[0].P).TextSettings.Font.Style := TBasEdit(Args[0].P).TextSettings.Font.Style - [TFontStyle.fsItalic];
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_italic#: ' + E.Message);
  end;
end;

function n_edit_underline_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_underline') then
    Exit();

  try
    if TFontStyle.fsUnderline in TBasEdit(Args[0].P).TextSettings.Font.Style then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_underline: ' + E.Message);
  end;
end;

function p_edit_underline_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_underline#') then
    Exit();

  try
    if Args[1].n <> 0 then
      TBasEdit(Args[0].P).TextSettings.Font.Style := TBasEdit(Args[0].P).TextSettings.Font.Style + [TFontStyle.fsUnderline]
    else
      TBasEdit(Args[0].P).TextSettings.Font.Style := TBasEdit(Args[0].P).TextSettings.Font.Style - [TFontStyle.fsUnderline];
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_underline#: ' + E.Message);
  end;
end;

function n_edit_strikeout_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_strikeout') then
    Exit();

  try
    if TFontStyle.fsStrikeOut in TBasEdit(Args[0].P).TextSettings.Font.Style then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_strikeout: ' + E.Message);
  end;
end;

function p_edit_strikeout_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';

  if not ValidateEdit(Args[0].P, 'edit_strikeout#') then
    Exit();

  try
    if Args[1].n <> 0 then
      TBasEdit(Args[0].P).TextSettings.Font.Style := TBasedit(Args[0].P).TextSettings.Font.Style + [TFontStyle.fsStrikeOut]
    else
      TBasEdit(Args[0].P).TextSettings.Font.Style := TBasEdit(Args[0].P).TextSettings.Font.Style - [TFontStyle.fsStrikeOut];
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_strikeout#: ' + E.Message);
  end;
end;

// Text Alignment
function n_edit_textalign_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_textalign') then
    Exit();
  try
    Result.n := TextAlignToInt(TBasEdit(Args[0].P).TextSettings.HorzAlign);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_textalign: ' + E.Message);
  end;
end;

function p_edit_textalign_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_textalign#') then
    Exit();
  try
    TBasEdit(Args[0].P).TextSettings.HorzAlign :=
      IntToTextAlign(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_textalign#: ' + E.Message);
  end;
end;

// Selection Functions
function n_edit_selstart_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_selstart') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).SelStart;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_selstart: ' + E.Message);
  end;
end;

function p_edit_selstart_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_selstart#') then
    Exit();
  try
    TBasEdit(Args[0].P).SelStart := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_selstart#: ' + E.Message);
  end;
end;

function n_edit_sellength_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_sellength') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).SelLength;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_sellength: ' + E.Message);
  end;
end;

function p_edit_sellength_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_sellength#') then
    Exit();
  try
    TBasEdit(Args[0].P).SelLength := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_sellength#: ' + E.Message);
  end;
end;

function s_edit_seltext_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_seltext$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).SelText;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_seltext$: ' + E.Message);
  end;
end;

function p_edit_selectall(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_selectall#') then
    Exit();
  try
    TBasEdit(Args[0].P).SelectAll;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_selectall#: ' + E.Message);
  end;
end;

function p_edit_clearselection(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_clearselection#') then
    Exit();
  try
    TBasEdit(Args[0].P).SelLength := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_clearselection#: ' + E.Message);
  end;
end;

// Caret Functions
function n_edit_caretposition_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_caretposition') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).CaretPosition;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_caretposition: ' + E.Message);
  end;
end;

function p_edit_caretposition_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_caretposition#') then
    Exit();
  try
    TBasEdit(Args[0].P).CaretPosition := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_caretposition#: ' + E.Message);
  end;
end;

function p_edit_gotoend(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_gotoend#') then
    Exit();
  try
    TBasEdit(Args[0].P).GoToTextEnd;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_gotoend#: ' + E.Message);
  end;
end;

function p_edit_gotobegin(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_gotobegin#') then
    Exit();
  try
    TBasEdit(Args[0].P).GoToTextBegin;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_gotobegin#: ' + E.Message);
  end;
end;

// Clipboard Functions
function p_edit_copy(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_copy#') then
    Exit();
  try
    TBasEdit(Args[0].P).CopyToClipboard;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_copy#: ' + E.Message);
  end;
end;

function p_edit_cut(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_cut#') then
    Exit();
  try
    TBasEdit(Args[0].P).CutToClipboard;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_cut#: ' + E.Message);
  end;
end;

function p_edit_paste(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_paste#') then
    Exit();
  try
    TBasEdit(Args[0].P).PasteFromClipboard;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_paste#: ' + E.Message);
  end;
end;

function p_edit_clear(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_clear#') then
    Exit();
  try
    TBasEdit(Args[0].P).DeleteSelection;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_clear#: ' + E.Message);
  end;
end;

// Mobile Functions
function n_edit_keyboardtype_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_keyboardtype') then
    Exit();
  try
    Result.n := KeyboardTypeToInt(TBasEdit(Args[0].P).KeyboardType);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_keyboardtype: ' + E.Message);
  end;
end;

function p_edit_keyboardtype_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_keyboardtype#') then
    Exit();
  try
    TBasEdit(Args[0].P).KeyboardType := IntToKeyboardType(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_keyboardtype#: ' + E.Message);
  end;
end;

function n_edit_returnkeytype_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_returnkeytype') then
    Exit();
  try
    Result.n := ReturnKeyTypeToInt(TBasEdit(Args[0].P).ReturnKeyType);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_returnkeytype: ' + E.Message);
  end;
end;

function p_edit_returnkeytype_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_returnkeytype#') then
    Exit();
  try
    TBasEdit(Args[0].P).ReturnKeyType := IntToReturnKeyType(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_returnkeytype#: ' + E.Message);
  end;
end;

function n_edit_checkspelling_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_checkspelling') then
    Exit();
  try
    if TBasEdit(Args[0].P).CheckSpelling then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_checkspelling: ' + E.Message);
  end;
end;

function p_edit_checkspelling_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_checkspelling#') then
    Exit();
  try
    TBasEdit(Args[0].P).CheckSpelling := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_checkspelling#: ' + E.Message);
  end;
end;

function s_edit_filterchar_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_filterchar$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).FilterChar;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_filterchar$: ' + E.Message);
  end;
end;

function p_edit_filterchar_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_filterchar#') then
    Exit();
  try
    TBasEdit(Args[0].P).FilterChar := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_filterchar#: ' + E.Message);
  end;
end;

// Position and Size
function n_edit_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_x') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).Position.X;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_x: ' + E.Message);
  end;
end;

function p_edit_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_x#') then
    Exit();
  try
    TBasEdit(Args[0].P).Position.X := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_x#: ' + E.Message);
  end;
end;

function n_edit_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_y') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).Position.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_y: ' + E.Message);
  end;
end;

function p_edit_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_y#') then
    Exit();
  try
    TBasEdit(Args[0].P).Position.Y := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_y#: ' + E.Message);
  end;
end;

function n_edit_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_width') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_width: ' + E.Message);
  end;
end;

function p_edit_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_width#') then
    Exit();
  try
    TBasEdit(Args[0].P).Width := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_width#: ' + E.Message);
  end;
end;

function n_edit_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_height') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_height: ' + E.Message);
  end;
end;

function p_edit_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_height#') then
    Exit();
  try
    TBasEdit(Args[0].P).Height := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_height#: ' + E.Message);
  end;
end;

function p_edit_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_bounds#') then
    Exit();
  try
    TBasEdit(Args[0].P).SetBounds(Args[1].n, Args[2].n, Args[3].n, Args[4].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_bounds#: ' + E.Message);
  end;
end;

function p_edit_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_move#') then
    Exit();
  try
    TBasEdit(Args[0].P).Position.X := Args[1].n;
    TBasEdit(Args[0].P).Position.Y := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_move#: ' + E.Message);
  end;
end;

function p_edit_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_size#') then
    Exit();
  try
    TBasEdit(Args[0].P).Width := Args[1].n;
    TBasEdit(Args[0].P).Height := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_size#: ' + E.Message);
  end;
end;

// Alignment
function n_edit_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_align') then
    Exit();
  try
    Result.n := AlignToInt(TBasEdit(Args[0].P).Align);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_align: ' + E.Message);
  end;
end;

function p_edit_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_align#') then
    Exit();
  try
    TBasEdit(Args[0].P).Align := AlignFromInt(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_align#: ' + E.Message);
  end;
end;

// Margins
function n_edit_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_marginleft') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).Margins.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_marginleft: ' + E.Message);
  end;
end;

function p_edit_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_marginleft#') then
    Exit();
  try
    TBasEdit(Args[0].P).Margins.Left := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_marginleft#: ' + E.Message);
  end;
end;

function n_edit_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_margintop') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).Margins.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_margintop: ' + E.Message);
  end;
end;

function p_edit_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_margintop#') then
    Exit();
  try
    TBasEdit(Args[0].P).Margins.Top := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_margintop#: ' + E.Message);
  end;
end;

function p_edit_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_margins#') then
    Exit();
  try
    TBasEdit(Args[0].P).Margins.Left := Args[1].n;
    TBasEdit(Args[0].P).Margins.Top := Args[2].n;
    TBasEdit(Args[0].P).Margins.Right := Args[3].n;
    TBasEdit(Args[0].P).Margins.Bottom := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_margins#: ' + E.Message);
  end;
end;

function p_edit_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_margin#') then
    Exit();
  try
    TBasEdit(Args[0].P).Margins.Left := Args[1].n;
    TBasEdit(Args[0].P).Margins.Top := Args[1].n;
    TBasEdit(Args[0].P).Margins.Right := Args[1].n;
    TBasEdit(Args[0].P).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_margin#: ' + E.Message);
  end;
end;

// Visibility
function n_edit_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_visible') then
    Exit();
  try
    if TBasEdit(Args[0].P).Visible then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_visible: ' + E.Message);
  end;
end;

function p_edit_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_visible#') then
    Exit();
  try
    TBasEdit(Args[0].P).Visible := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_visible#: ' + E.Message);
  end;
end;

function n_edit_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_enabled') then
    Exit();
  try
    if TBasEdit(Args[0].P).Enabled then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_enabled: ' + E.Message);
  end;
end;

function p_edit_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_enabled#') then
    Exit();
  try
    TBasEdit(Args[0].P).Enabled := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_enabled#: ' + E.Message);
  end;
end;

function n_edit_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_opacity') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).Opacity;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_opacity: ' + E.Message);
  end;
end;

function p_edit_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_opacity#') then
    Exit();
  try
    TBasEdit(Args[0].P).Opacity := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_opacity#: ' + E.Message);
  end;
end;

// Focus
function n_edit_isfocused_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_isfocused') then
    Exit();
  try
    if TBasEdit(Args[0].P).IsFocused then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_isfocused: ' + E.Message);
  end;
end;

function p_edit_setfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_setfocus#') then
    Exit();
  try
    TBasEdit(Args[0].P).SetFocus;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_setfocus#: ' + E.Message);
  end;
end;

function p_edit_resetfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_resetfocus#') then
    Exit();
  try
    TBasEdit(Args[0].P).ResetFocus;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_resetfocus#: ' + E.Message);
  end;
end;

function n_edit_taborder_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_taborder') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).TabOrder;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_taborder: ' + E.Message);
  end;
end;

function p_edit_taborder_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_taborder#') then
    Exit();
  try
    TBasEdit(Args[0].P).TabOrder := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_taborder#: ' + E.Message);
  end;
end;

// Tag
function n_edit_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_tag') then
    Exit();
  try
    Result.n := TBasEdit(Args[0].P).Tag;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_tag: ' + E.Message);
  end;
end;

function p_edit_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_tag#') then
    Exit();
  try
    TBasEdit(Args[0].P).Tag := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_tag#: ' + E.Message);
  end;
end;

// Parent
function p_edit_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_parent#') then
    Exit();
  try
    Result.P := Pointer(TBasEdit(Args[0].P).Parent);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_parent#: ' + E.Message);
  end;
end;

function p_edit_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_parent#') then
    Exit();
  if not ValidateParent(Args[1].P, 'edit_parent#') then
    Exit();
  try
    TBasEdit(Args[0].P).Parent := TFmxObject(Args[1].P);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_parent#: ' + E.Message);
  end;
end;

function p_edit_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_bringtofront#') then
    Exit();
  try
    TBasEdit(Args[0].P).BringToFront;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_bringtofront#: ' + E.Message);
  end;
end;

function p_edit_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_sendtoback#') then
    Exit();
  try
    TBasEdit(Args[0].P).SendToBack;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_sendtoback#: ' + E.Message);
  end;
end;

// Event Callbacks
function p_edit_onchange_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onchange#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnChangeFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onchange#: ' + E.Message);
  end;
end;

function s_edit_onchange_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onchange$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnChangeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onchange$: ' + E.Message);
  end;
end;

function p_edit_onchangetracking_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onchangetracking#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnChangeTrackingFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onchangetracking#: ' + E.Message);
  end;
end;

function s_edit_onchangetracking_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onchangetracking$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnChangeTrackingFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onchangetracking$: ' + E.Message);
  end;
end;

function p_edit_ontyping_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_ontyping#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnTypingFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_ontyping#: ' + E.Message);
  end;
end;

function s_edit_ontyping_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_ontyping$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnTypingFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_ontyping$: ' + E.Message);
  end;
end;

function p_edit_onenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onenter#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnEnterFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onenter#: ' + E.Message);
  end;
end;

function s_edit_onenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onenter$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onenter$: ' + E.Message);
  end;
end;

function p_edit_onexit_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onexit#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnExitFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onexit#: ' + E.Message);
  end;
end;

function s_edit_onexit_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onexit$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnExitFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onexit$: ' + E.Message);
  end;
end;

function p_edit_onkeydown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onkeydown#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnKeyDownFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onkeydown#: ' + E.Message);
  end;
end;

function s_edit_onkeydown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onkeydown$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnKeyDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onkeydown$: ' + E.Message);
  end;
end;

function p_edit_onkeyup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onkeyup#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnKeyUpFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onkeyup#: ' + E.Message);
  end;
end;

function s_edit_onkeyup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onkeyup$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnKeyUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onkeyup$: ' + E.Message);
  end;
end;

function p_edit_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onclick#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnClickFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onclick#: ' + E.Message);
  end;
end;

function s_edit_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onclick$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onclick$: ' + E.Message);
  end;
end;

function p_edit_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_ondblclick#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnDblClickFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_ondblclick#: ' + E.Message);
  end;
end;

function s_edit_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_ondblclick$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnDblClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_ondblclick$: ' + E.Message);
  end;
end;

function p_edit_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onmousedown#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnMouseDownFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onmousedown#: ' + E.Message);
  end;
end;

function s_edit_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onmousedown$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnMouseDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onmousedown$: ' + E.Message);
  end;
end;

function p_edit_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onmouseup#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnMouseUpFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onmouseup#: ' + E.Message);
  end;
end;

function s_edit_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onmouseup$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnMouseUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onmouseup$: ' + E.Message);
  end;
end;

function p_edit_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onmousemove#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnMouseMoveFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onmousemove#: ' + E.Message);
  end;
end;

function s_edit_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onmousemove$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnMouseMoveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onmousemove$: ' + E.Message);
  end;
end;

function p_edit_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onmouseenter#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnMouseEnterFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onmouseenter#: ' + E.Message);
  end;
end;

function s_edit_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onmouseenter$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnMouseEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onmouseenter$: ' + E.Message);
  end;
end;

function p_edit_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onmouseleave#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnMouseLeaveFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onmouseleave#: ' + E.Message);
  end;
end;

function s_edit_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onmouseleave$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnMouseLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onmouseleave$: ' + E.Message);
  end;
end;

function p_edit_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onresize#') then
    Exit();
  try
    TBasEdit(Args[0].P).OnResizeFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onresize#: ' + E.Message);
  end;
end;

function s_edit_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_onresize$') then
    Exit();
  try
    Result.S := TBasEdit(Args[0].P).OnResizeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_onresize$: ' + E.Message);
  end;
end;

// edit_ondragenter#(edit#, funcname$) - Set OnDragEnter handler
function p_edit_ondragenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEdit(Args[0].p, 'edit_ondragenter#') then
    Exit();
  try
    TBasEdit(Args[0].p).OnDragEnterFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_ondragenter#: ' + E.Message);
  end;
end;

// edit_ondragenter$(edit#) - Get OnDragEnter handler
function s_edit_ondragenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEdit(Args[0].p, 'edit_ondragenter$') then
    Exit();
  try
    Result.s := TBasEdit(Args[0].p).OnDragEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_ondragenter$: ' + E.Message);
  end;
end;

// edit_ondragover#(edit#, funcname$) - Set OnDragOver handler
function p_edit_ondragover_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEdit(Args[0].p, 'edit_ondragover#') then
    Exit();
  try
    TBasEdit(Args[0].p).OnDragOverFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_ondragover#: ' + E.Message);
  end;
end;

// edit_ondragover$(edit#) - Get OnDragOver handler
function s_edit_ondragover_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEdit(Args[0].p, 'edit_ondragover$') then
    Exit();
  try
    Result.s := TBasEdit(Args[0].p).OnDragOverFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_ondragover$: ' + E.Message);
  end;
end;

// edit_ondragdrop#(edit#, funcname$) - Set OnDragDrop handler
function p_edit_ondragdrop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEdit(Args[0].p, 'edit_ondragdrop#') then
    Exit();
  try
    TBasEdit(Args[0].p).OnDragDropFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_ondragdrop#: ' + E.Message);
  end;
end;

// edit_ondragdrop$(edit#) - Get OnDragDrop handler
function s_edit_ondragdrop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEdit(Args[0].p, 'edit_ondragdrop$') then
    Exit();
  try
    Result.s := TBasEdit(Args[0].p).OnDragDropFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_ondragdrop$: ' + E.Message);
  end;
end;

// edit_ondragleave#(edit#, funcname$) - Set OnDragLeave handler
function p_edit_ondragleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEdit(Args[0].p, 'edit_ondragleave#') then
    Exit();
  try
    TBasEdit(Args[0].p).OnDragLeaveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_ondragleave#: ' + E.Message);
  end;
end;

// edit_ondragleave$(edit#) - Get OnDragLeave handler
function s_edit_ondragleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEdit(Args[0].p, 'edit_ondragleave$') then
    Exit();
  try
    Result.s := TBasEdit(Args[0].p).OnDragLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'edit_ondragleave$: ' + E.Message);
  end;
end;

function p_edit_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidateEdit(Args[0].P, 'edit_clearcallbacks#') then
    Exit();
  try
    with TBasEdit(Args[0].P) do
    begin
      OnChangeFunc := '';
      OnChangeTrackingFunc := '';
      OnTypingFunc := '';
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
      SetError(ERR_OPERATION_FAILED, 'edit_clearcallbacks#: ' + E.Message);
  end;
end;

// Library Registration
procedure RegisterEditFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_edit_error; Lib.Add('edit_error@', Fn);
  Fn.Entry := @s_edit_errormsg; Lib.Add('edit_errormsg$@', Fn);
  Fn.Entry := @s_edit_strerror; Lib.Add('edit_strerror$@n', Fn);
  Fn.Entry := @n_edit_clearerror; Lib.Add('edit_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_edit_new; Lib.Add('edit#@#', Fn);
  Fn.Entry := @p_edit_new_pos; Lib.Add('edit#@#nnnn', Fn);
  Fn.Entry := @p_edit_new_text; Lib.Add('edit#@#nnnn$', Fn);
  Fn.Entry := @n_edit_free; Lib.Add('edit_free@#', Fn);

  // Text content
  Fn.Entry := @s_edit_text_get; Lib.Add('edit_text$@#', Fn);
  Fn.Entry := @p_edit_text_set; Lib.Add('edit_text#@#$', Fn);
  Fn.Entry := @s_edit_prompt_get; Lib.Add('edit_prompt$@#', Fn);
  Fn.Entry := @p_edit_prompt_set; Lib.Add('edit_prompt#@#$', Fn);
  Fn.Entry := @n_edit_maxlength_get; Lib.Add('edit_maxlength@#', Fn);
  Fn.Entry := @p_edit_maxlength_set; Lib.Add('edit_maxlength#@#n', Fn);
  Fn.Entry := @n_edit_textlength_get; Lib.Add('edit_textlength@#', Fn);

  // Password and readonly
  Fn.Entry := @n_edit_password_get; Lib.Add('edit_password@#', Fn);
  Fn.Entry := @p_edit_password_set; Lib.Add('edit_password#@#n', Fn);
  Fn.Entry := @n_edit_readonly_get; Lib.Add('edit_readonly@#', Fn);
  Fn.Entry := @p_edit_readonly_set; Lib.Add('edit_readonly#@#n', Fn);

  // Font properties
  Fn.Entry := @s_edit_fontfamily_get; Lib.Add('edit_fontfamily$@#', Fn);
  Fn.Entry := @p_edit_fontfamily_set; Lib.Add('edit_fontfamily#@#$', Fn);
  Fn.Entry := @n_edit_fontsize_get; Lib.Add('edit_fontsize@#', Fn);
  Fn.Entry := @p_edit_fontsize_set; Lib.Add('edit_fontsize#@#n', Fn);
  Fn.Entry := @s_edit_fontcolor_get; Lib.Add('edit_fontcolor$@#', Fn);
  Fn.Entry := @p_edit_fontcolor_set; Lib.Add('edit_fontcolor#@#$', Fn);
  Fn.Entry := @n_edit_bold_get; Lib.Add('edit_bold@#', Fn);
  Fn.Entry := @p_edit_bold_set; Lib.Add('edit_bold#@#n', Fn);
  Fn.Entry := @n_edit_italic_get;Lib.Add('edit_italic@#', Fn);
  Fn.Entry := @p_edit_italic_set; Lib.Add('edit_italic#@#n', Fn);
  Fn.Entry := @n_edit_underline_get; Lib.Add('edit_underline@#', Fn);
  Fn.Entry := @p_edit_underline_set; Lib.Add('edit_underline#@#n', Fn);
  Fn.Entry := @n_edit_strikeout_get; Lib.Add('edit_strikeout@#', Fn);
  Fn.Entry := @p_edit_strikeout_set; Lib.Add('edit_strikeout#@#n', Fn);

  // Text alignment
  Fn.Entry := @n_edit_textalign_get; Lib.Add('edit_textalign@#', Fn);
  Fn.Entry := @p_edit_textalign_set; Lib.Add('edit_textalign#@#n', Fn);

  // Selection
  Fn.Entry := @n_edit_selstart_get; Lib.Add('edit_selstart@#', Fn);
  Fn.Entry := @p_edit_selstart_set; Lib.Add('edit_selstart#@#n', Fn);
  Fn.Entry := @n_edit_sellength_get; Lib.Add('edit_sellength@#', Fn);
  Fn.Entry := @p_edit_sellength_set; Lib.Add('edit_sellength#@#n', Fn);
  Fn.Entry := @s_edit_seltext_get; Lib.Add('edit_seltext$@#', Fn);
  Fn.Entry := @p_edit_selectall; Lib.Add('edit_selectall#@#', Fn);
  Fn.Entry := @p_edit_clearselection; Lib.Add('edit_clearselection#@#', Fn);

  // Caret
  Fn.Entry := @n_edit_caretposition_get; Lib.Add('edit_caretposition@#', Fn);
  Fn.Entry := @p_edit_caretposition_set; Lib.Add('edit_caretposition#@#n', Fn);
  Fn.Entry := @p_edit_gotoend; Lib.Add('edit_gotoend#@#', Fn);
  Fn.Entry := @p_edit_gotobegin; Lib.Add('edit_gotobegin#@#', Fn);

  // Clipboard
  Fn.Entry := @p_edit_copy; Lib.Add('edit_copy#@#', Fn);
  Fn.Entry := @p_edit_cut; Lib.Add('edit_cut#@#', Fn);
  Fn.Entry := @p_edit_paste; Lib.Add('edit_paste#@#', Fn);
  Fn.Entry := @p_edit_clear; Lib.Add('edit_clear#@#', Fn);

  // Mobile-specific
  Fn.Entry := @n_edit_keyboardtype_get; Lib.Add('edit_keyboardtype@#', Fn);
  Fn.Entry := @p_edit_keyboardtype_set; Lib.Add('edit_keyboardtype#@#n', Fn);
  Fn.Entry := @n_edit_returnkeytype_get; Lib.Add('edit_returnkeytype@#', Fn);
  Fn.Entry := @p_edit_returnkeytype_set; Lib.Add('edit_returnkeytype#@#n', Fn);
  Fn.Entry := @n_edit_checkspelling_get; Lib.Add('edit_checkspelling@#', Fn);
  Fn.Entry := @p_edit_checkspelling_set; Lib.Add('edit_checkspelling#@#n', Fn);
  Fn.Entry := @s_edit_filterchar_get; Lib.Add('edit_filterchar$@#', Fn);
  Fn.Entry := @p_edit_filterchar_set; Lib.Add('edit_filterchar#@#$', Fn);

  // Position and Size
  Fn.Entry := @n_edit_x_get; Lib.Add('edit_x@#', Fn);
  Fn.Entry := @p_edit_x_set; Lib.Add('edit_x#@#n', Fn);
  Fn.Entry := @n_edit_y_get; Lib.Add('edit_y@#', Fn);
  Fn.Entry := @p_edit_y_set; Lib.Add('edit_y#@#n', Fn);
  Fn.Entry := @n_edit_width_get; Lib.Add('edit_width@#', Fn);
  Fn.Entry := @p_edit_width_set; Lib.Add('edit_width#@#n', Fn);
  Fn.Entry := @n_edit_height_get; Lib.Add('edit_height@#', Fn);
  Fn.Entry := @p_edit_height_set; Lib.Add('edit_height#@#n', Fn);
  Fn.Entry := @p_edit_bounds_set; Lib.Add('edit_bounds#@#nnnn', Fn);
  Fn.Entry := @p_edit_move_set; Lib.Add('edit_move#@#nn', Fn);
  Fn.Entry := @p_edit_size_set; Lib.Add('edit_size#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_edit_align_get; Lib.Add('edit_align@#', Fn);
  Fn.Entry := @p_edit_align_set; Lib.Add('edit_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_edit_marginleft_get; Lib.Add('edit_marginleft@#', Fn);
  Fn.Entry := @p_edit_marginleft_set; Lib.Add('edit_marginleft#@#n', Fn);
  Fn.Entry := @n_edit_margintop_get; Lib.Add('edit_margintop@#', Fn);
  Fn.Entry := @p_edit_margintop_set; Lib.Add('edit_margintop#@#n', Fn);
  Fn.Entry := @p_edit_margins_set; Lib.Add('edit_margins#@#nnnn', Fn);
  Fn.Entry := @p_edit_margin_set; Lib.Add('edit_margin#@#n', Fn);

  // Visibility
  Fn.Entry := @n_edit_visible_get; Lib.Add('edit_visible@#', Fn);
  Fn.Entry := @p_edit_visible_set; Lib.Add('edit_visible#@#n', Fn);
  Fn.Entry := @n_edit_enabled_get; Lib.Add('edit_enabled@#', Fn);
  Fn.Entry := @p_edit_enabled_set; Lib.Add('edit_enabled#@#n', Fn);
  Fn.Entry := @n_edit_opacity_get; Lib.Add('edit_opacity@#', Fn);
  Fn.Entry := @p_edit_opacity_set; Lib.Add('edit_opacity#@#n', Fn);

  // Focus
  Fn.Entry := @n_edit_isfocused_get; Lib.Add('edit_isfocused@#', Fn);
  Fn.Entry := @p_edit_setfocus; Lib.Add('edit_setfocus#@#', Fn);
  Fn.Entry := @p_edit_resetfocus; Lib.Add('edit_resetfocus#@#', Fn);
  Fn.Entry := @n_edit_taborder_get; Lib.Add('edit_taborder@#', Fn);
  Fn.Entry := @p_edit_taborder_set; Lib.Add('edit_taborder#@#n', Fn);

  // Tag
  Fn.Entry := @n_edit_tag_get; Lib.Add('edit_tag@#', Fn);
  Fn.Entry := @p_edit_tag_set; Lib.Add('edit_tag#@#n', Fn);

  // Parent
  Fn.Entry := @p_edit_parent_get; Lib.Add('edit_parent#@#', Fn);
  Fn.Entry := @p_edit_parent_set; Lib.Add('edit_parent#@##', Fn);
  Fn.Entry := @p_edit_bringtofront; Lib.Add('edit_bringtofront#@#', Fn);
  Fn.Entry := @p_edit_sendtoback; Lib.Add('edit_sendtoback#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_edit_onchange_set; Lib.Add('edit_onchange#@#$', Fn);
  Fn.Entry := @s_edit_onchange_get; Lib.Add('edit_onchange$@#', Fn);
  Fn.Entry := @p_edit_onchangetracking_set; Lib.Add('edit_onchangetracking#@#$', Fn);
  Fn.Entry := @s_edit_onchangetracking_get; Lib.Add('edit_onchangetracking$@#', Fn);
  Fn.Entry := @p_edit_ontyping_set; Lib.Add('edit_ontyping#@#$', Fn);
  Fn.Entry := @s_edit_ontyping_get; Lib.Add('edit_ontyping$@#', Fn);
  Fn.Entry := @p_edit_onenter_set; Lib.Add('edit_onenter#@#$', Fn);
  Fn.Entry := @s_edit_onenter_get; Lib.Add('edit_onenter$@#', Fn);
  Fn.Entry := @p_edit_onexit_set; Lib.Add('edit_onexit#@#$', Fn);
  Fn.Entry := @s_edit_onexit_get; Lib.Add('edit_onexit$@#', Fn);
  Fn.Entry := @p_edit_onkeydown_set; Lib.Add('edit_onkeydown#@#$', Fn);
  Fn.Entry := @s_edit_onkeydown_get; Lib.Add('edit_onkeydown$@#', Fn);
  Fn.Entry := @p_edit_onkeyup_set; Lib.Add('edit_onkeyup#@#$', Fn);
  Fn.Entry := @s_edit_onkeyup_get; Lib.Add('edit_onkeyup$@#', Fn);
  Fn.Entry := @p_edit_onclick_set; Lib.Add('edit_onclick#@#$', Fn);
  Fn.Entry := @s_edit_onclick_get; Lib.Add('edit_onclick$@#', Fn);
  Fn.Entry := @p_edit_ondblclick_set; Lib.Add('edit_ondblclick#@#$', Fn);
  Fn.Entry := @s_edit_ondblclick_get; Lib.Add('edit_ondblclick$@#', Fn);
  Fn.Entry := @p_edit_onmousedown_set; Lib.Add('edit_onmousedown#@#$', Fn);
  Fn.Entry := @s_edit_onmousedown_get; Lib.Add('edit_onmousedown$@#', Fn);
  Fn.Entry := @p_edit_onmouseup_set; Lib.Add('edit_onmouseup#@#$', Fn);
  Fn.Entry := @s_edit_onmouseup_get; Lib.Add('edit_onmouseup$@#', Fn);
  Fn.Entry := @p_edit_onmousemove_set; Lib.Add('edit_onmousemove#@#$', Fn);
  Fn.Entry := @s_edit_onmousemove_get; Lib.Add('edit_onmousemove$@#', Fn);
  Fn.Entry := @p_edit_onmouseenter_set; Lib.Add('edit_onmouseenter#@#$', Fn);
  Fn.Entry := @s_edit_onmouseenter_get; Lib.Add('edit_onmouseenter$@#', Fn);
  Fn.Entry := @p_edit_onmouseleave_set; Lib.Add('edit_onmouseleave#@#$', Fn);
  Fn.Entry := @s_edit_onmouseleave_get; Lib.Add('edit_onmouseleave$@#', Fn);
  Fn.Entry := @p_edit_onresize_set; Lib.Add('edit_onresize#@#$', Fn);
  Fn.Entry := @s_edit_onresize_get; Lib.Add('edit_onresize$@#', Fn);
  Fn.Entry := @p_edit_ondragenter_set; Lib.Add('edit_ondragenter#@#$', Fn);
  Fn.Entry := @s_edit_ondragenter_get; Lib.Add('edit_ondragenter$@#', Fn);
  Fn.Entry := @p_edit_ondragover_set; Lib.Add('edit_ondragover#@#$', Fn);
  Fn.Entry := @s_edit_ondragover_get; Lib.Add('edit_ondragover$@#', Fn);
  Fn.Entry := @p_edit_ondragdrop_set; Lib.Add('edit_ondragdrop#@#$', Fn);
  Fn.Entry := @s_edit_ondragdrop_get; Lib.Add('edit_ondragdrop$@#', Fn);
  Fn.Entry := @p_edit_ondragleave_set; Lib.Add('edit_ondragleave#@#$', Fn);
  Fn.Entry := @s_edit_ondragleave_get; Lib.Add('edit_ondragleave$@#', Fn);
  Fn.Entry := @p_edit_clearcallbacks; Lib.Add('edit_clearcallbacks#@#', Fn);
end;

end.

