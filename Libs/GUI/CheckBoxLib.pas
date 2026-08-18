unit CheckBoxLib;

{******************************************************************************
  CheckBoxLib - CheckBox Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TCheckBox wrapper functionality for creating
  and managing checkbox controls in Plan9Basic programs.

  Function Count: 90+ functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All checkboxes are created at RUNTIME using TCheckBox.Create with dynamic
  parent assignment. This ensures proper dynamic creation across all platforms.

  EVENT CONNECTION MODEL:
  =======================
  Events are connected/disconnected individually when callbacks are set:
  - Setting a non-empty callback name connects ONLY that specific event
  - Setting an empty callback name ("") disconnects ONLY that specific event
  - No events are connected by default in the constructor

  FEATURES:
  =========
  - CheckBox creation and lifecycle management
  - IsChecked state control (checked/unchecked)
  - Text content with font styling (family, size, bold, italic, etc.)
  - Complete positioning and alignment
  - Full event support with BASIC callback integration
  - Drag and drop support

  EVENTS SUPPORT:
  ===============
  - OnChange: Checked state changed (primary checkbox event)
  - OnClick: CheckBox was clicked
  - OnDblClick: CheckBox was double-clicked
  - OnEnter: CheckBox received focus
  - OnExit: CheckBox lost focus
  - OnKeyDown: Key was pressed while focused
  - OnKeyUp: Key was released while focused
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over checkbox
  - OnMouseEnter: Mouse entered checkbox area
  - OnMouseLeave: Mouse left checkbox area
  - OnResize: CheckBox is being resized
  - OnDragEnter: Drag operation entered checkbox
  - OnDragOver: Drag operation over checkbox (return non-zero to accept)
  - OnDragDrop: Item was dropped on checkbox
  - OnDragLeave: Drag operation left checkbox

  USAGE PATTERN:
  ==============
    let frm# = form#("CheckBox Demo", 400, 300)

    ' Create a checkbox
    let chk# = checkbox#(frm#, "Enable feature")
    checkbox_move#(chk#, 50, 50)
    checkbox_onchange#(chk#, "OnCheckChanged")

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnCheckChanged(sender#) local checked
      checked = checkbox_ischecked(sender#)
      if checked = 1 then
        println "Feature enabled"
      else
        println "Feature disabled"
      endif
    endfunction

    function OnCheckKeyDown(sender#, key, keychar$, shift$)
      println "Key pressed: " + str$(key)
    endfunction

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Text,
  basic, exec, UnitGC, HandleRegistry;

type
  TBasCheckBox = class(TCheckBox)
  private
    FOnChangeFunc: String;
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
    FOnDragEnterFunc: String;
    FOnDragOverFunc: String;
    FOnDragDropFunc: String;
    FOnDragLeaveFunc: String;
    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;

    procedure InternalOnChange(Sender: TObject);
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
    procedure InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
    procedure InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure InternalOnDragLeave(Sender: TObject);

    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
    function ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;

    procedure SetOnChangeFunc(const Value: String);
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
    procedure SetOnDragEnterFunc(const Value: String);
    procedure SetOnDragOverFunc(const Value: String);
    procedure SetOnDragDropFunc(const Value: String);
    procedure SetOnDragLeaveFunc(const Value: String);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure DisconnectAllEvents();

    property OnChangeFunc: String read FOnChangeFunc write SetOnChangeFunc;
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
    property OnDragEnterFunc: String read FOnDragEnterFunc write SetOnDragEnterFunc;
    property OnDragOverFunc: String read FOnDragOverFunc write SetOnDragOverFunc;
    property OnDragDropFunc: String read FOnDragDropFunc write SetOnDragDropFunc;
    property OnDragLeaveFunc: String read FOnDragLeaveFunc write SetOnDragLeaveFunc;
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
  end;

procedure RegisterCheckBoxFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  CHECKBOX_GC_TAG = 'BASIC_CHECKBOX';
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_CHECKBOX = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INDEX_OUT_OF_RANGE = 5;

  ALIGN_NONE = 0;
  ALIGN_TOP = 1;
  ALIGN_LEFT = 2;
  ALIGN_RIGHT = 3;
  ALIGN_BOTTOM = 4;
  ALIGN_CLIENT = 9;
  ALIGN_CENTER = 11;

var
  lastError: Integer;
  lastErrorMsg: String;
  ModuleEngine: TBasicEngine;
  ModuleOutput: TStrings;

// -----------------------------------------------------------------------------
// Error Handling
// -----------------------------------------------------------------------------

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

function ValidateCheckBox(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_CHECKBOX, FuncName + ': Nil pointer');
    Exit();
  end;

  try
    if not(IsHandleOf(P, TBasCheckBox)) then
    begin
      SetError(ERR_INVALID_CHECKBOX, FuncName + ': Invalid object');
      Exit();
    end;
  except
    SetError(ERR_INVALID_CHECKBOX, FuncName + ': Invalid pointer');
    Exit();
  end;

  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': Nil parent pointer');
    Exit();
  end;

  try
    if not((IsHandleOf(P, TFmxObject)) or (IsHandleOf(P, TCommonCustomForm))) then
    begin
      SetError(ERR_INVALID_PARENT, FuncName + ': Invalid parent type');
      Exit();
    end;
  except
    SetError(ERR_INVALID_PARENT, FuncName + ': Invalid parent pointer');
    Exit();
  end;

  Result := True;
end;

function ShiftStateToString(Shift: TShiftState): String;
begin
  Result := '';
  if ssShift in Shift then Result := Result + 'S';
  if ssAlt in Shift then Result := Result + 'A';
  if ssCtrl in Shift then Result := Result + 'C';
  if ssCommand in Shift then Result := Result + 'M';
end;

function MouseButtonToInt(Button: TMouseButton): Integer;
begin
  case Button of
    TMouseButton.mbLeft: Result := 1;
    TMouseButton.mbRight: Result := 2;
    TMouseButton.mbMiddle: Result := 3;
  else
    Result := 0;
  end;
end;

function AlignFromInt(Value: Integer): TAlignLayout;
begin
  case Value of
    ALIGN_TOP: Result := TAlignLayout.Top;
    ALIGN_LEFT: Result := TAlignLayout.Left;
    ALIGN_RIGHT: Result := TAlignLayout.Right;
    ALIGN_BOTTOM: Result := TAlignLayout.Bottom;
    ALIGN_CLIENT: Result := TAlignLayout.Client;
    ALIGN_CENTER: Result := TAlignLayout.Center;
  else
    Result := TAlignLayout.None;
  end;
end;

function AlignToInt(Value: TAlignLayout): Integer;
begin
  case Value of
    TAlignLayout.Top: Result := ALIGN_TOP;
    TAlignLayout.Left: Result := ALIGN_LEFT;
    TAlignLayout.Right: Result := ALIGN_RIGHT;
    TAlignLayout.Bottom: Result := ALIGN_BOTTOM;
    TAlignLayout.Client: Result := ALIGN_CLIENT;
    TAlignLayout.Center: Result := ALIGN_CENTER;
  else
    Result := ALIGN_NONE;
  end;
end;

// -----------------------------------------------------------------------------
// TBasCheckBox Implementation
// -----------------------------------------------------------------------------

constructor TBasCheckBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);
  FOnChangeFunc := '';
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
  FOnDragEnterFunc := '';
  FOnDragOverFunc := '';
  FOnDragDropFunc := '';
  FOnDragLeaveFunc := '';
  FBasicEngine := nil;
  FConsoleOutput := nil;

  // Enable HitTest for mouse events
  HitTest := True;

  // Clear StyledSettings for font customization
  StyledSettings := [];
end;

destructor TBasCheckBox.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasCheckBox.DisconnectAllEvents();
begin
  OnChange := nil;
  OnClick := nil;
  OnDblClick := nil;
  OnEnter := nil;
  OnExit := nil;
  OnKeyDown := nil;
  OnKeyUp := nil;
  OnMouseDown := nil;
  OnMouseUp := nil;
  OnMouseMove := nil;
  OnMouseEnter := nil;
  OnMouseLeave := nil;
  OnResize := nil;
  OnDragEnter := nil;
  OnDragOver := nil;
  OnDragDrop := nil;
  OnDragLeave := nil;
end;

procedure TBasCheckBox.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
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
        FConsoleOutput.Add('*** CheckBox Callback Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

function TBasCheckBox.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  i: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if UnitGC.GlobalCallbackBusy then Exit();
  if not Assigned(FBasicEngine) then Exit();
  if not Assigned(FConsoleOutput) then Exit();
  if FuncSignature = '' then Exit();

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
        FConsoleOutput.Add('*** CheckBox Callback Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

// Event Setters - Connect/Disconnect events granularly

procedure TBasCheckBox.SetOnChangeFunc(const Value: String);
begin
  FOnChangeFunc := Value;
  if Value <> '' then
    OnChange := InternalOnChange
  else
    OnChange := nil;
end;

procedure TBasCheckBox.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    OnClick := InternalOnClick
  else
    OnClick := nil;
end;

procedure TBasCheckBox.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    OnDblClick := InternalOnDblClick
  else
    OnDblClick := nil;
end;

procedure TBasCheckBox.SetOnEnterFunc(const Value: String);
begin
  FOnEnterFunc := Value;
  if Value <> '' then
    OnEnter := InternalOnEnter
  else
    OnEnter := nil;
end;

procedure TBasCheckBox.SetOnExitFunc(const Value: String);
begin
  FOnExitFunc := Value;
  if Value <> '' then
    OnExit := InternalOnExit
  else
    OnExit := nil;
end;

procedure TBasCheckBox.SetOnKeyDownFunc(const Value: String);
begin
  FOnKeyDownFunc := Value;
  if Value <> '' then
    OnKeyDown := InternalOnKeyDown
  else
    OnKeyDown := nil;
end;

procedure TBasCheckBox.SetOnKeyUpFunc(const Value: String);
begin
  FOnKeyUpFunc := Value;
  if Value <> '' then
    OnKeyUp := InternalOnKeyUp
  else
    OnKeyUp := nil;
end;

procedure TBasCheckBox.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    OnMouseDown := InternalOnMouseDown
  else
    OnMouseDown := nil;
end;

procedure TBasCheckBox.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    OnMouseUp := InternalOnMouseUp
  else
    OnMouseUp := nil;
end;

procedure TBasCheckBox.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    OnMouseMove := InternalOnMouseMove
  else
    OnMouseMove := nil;
end;

procedure TBasCheckBox.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    OnMouseEnter := InternalOnMouseEnter
  else
    OnMouseEnter := nil;
end;

procedure TBasCheckBox.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    OnMouseLeave := InternalOnMouseLeave
  else
    OnMouseLeave := nil;
end;

procedure TBasCheckBox.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    OnResize := InternalOnResize
  else
    OnResize := nil;
end;

procedure TBasCheckBox.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    OnDragEnter := InternalOnDragEnter
  else
    OnDragEnter := nil;
end;

procedure TBasCheckBox.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    OnDragOver := InternalOnDragOver
  else
    OnDragOver := nil;
end;

procedure TBasCheckBox.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    OnDragDrop := InternalOnDragDrop
  else
    OnDragDrop := nil;
end;

procedure TBasCheckBox.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    OnDragLeave := InternalOnDragLeave
  else
    OnDragLeave := nil;
end;

// Internal Event Handlers

procedure TBasCheckBox.InternalOnChange(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnChangeFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnChangeFunc) + '@#', Args);
end;

procedure TBasCheckBox.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnClickFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnClickFunc) + '@#', Args);
end;

procedure TBasCheckBox.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDblClickFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDblClickFunc) + '@#', Args);
end;

procedure TBasCheckBox.InternalOnEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnEnterFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnEnterFunc) + '@#', Args);
end;

procedure TBasCheckBox.InternalOnExit(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnExitFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnExitFunc) + '@#', Args);
end;

procedure TBasCheckBox.InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnKeyDownFunc = '' then Exit();
  Args[0].p := Sender; Args[0].n := 0; Args[0].s := '';
  Args[1].n := Key; Args[1].p := nil; Args[1].s := '';
  Args[2].s := KeyChar; Args[2].n := 0; Args[2].p := nil;
  Args[3].s := ShiftStateToString(Shift); Args[3].n := 0; Args[3].p := nil;
  ExecuteCallback(LowerCase(FOnKeyDownFunc) + '@#n$$', Args);
end;

procedure TBasCheckBox.InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnKeyUpFunc = '' then Exit();
  Args[0].p := Sender; Args[0].n := 0; Args[0].s := '';
  Args[1].n := Key; Args[1].p := nil; Args[1].s := '';
  Args[2].s := KeyChar; Args[2].n := 0; Args[2].p := nil;
  Args[3].s := ShiftStateToString(Shift); Args[3].n := 0; Args[3].p := nil;
  ExecuteCallback(LowerCase(FOnKeyUpFunc) + '@#n$$', Args);
end;

procedure TBasCheckBox.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseDownFunc = '' then Exit();
  Args[0].p := Sender; Args[0].n := 0; Args[0].s := '';
  Args[1].n := MouseButtonToInt(Button); Args[1].p := nil; Args[1].s := '';
  Args[2].s := ShiftStateToString(Shift); Args[2].n := 0; Args[2].p := nil;
  Args[3].n := X; Args[3].p := nil; Args[3].s := '';
  Args[4].n := Y; Args[4].p := nil; Args[4].s := '';
  ExecuteCallback(LowerCase(FOnMouseDownFunc) + '@#n$nn', Args);
end;

procedure TBasCheckBox.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseUpFunc = '' then Exit();
  Args[0].p := Sender; Args[0].n := 0; Args[0].s := '';
  Args[1].n := MouseButtonToInt(Button); Args[1].p := nil; Args[1].s := '';
  Args[2].s := ShiftStateToString(Shift); Args[2].n := 0; Args[2].p := nil;
  Args[3].n := X; Args[3].p := nil; Args[3].s := '';
  Args[4].n := Y; Args[4].p := nil; Args[4].s := '';
  ExecuteCallback(LowerCase(FOnMouseUpFunc) + '@#n$nn', Args);
end;

procedure TBasCheckBox.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnMouseMoveFunc = '' then Exit();
  Args[0].p := Sender; Args[0].n := 0; Args[0].s := '';
  Args[1].s := ShiftStateToString(Shift); Args[1].n := 0; Args[1].p := nil;
  Args[2].n := X; Args[2].p := nil; Args[2].s := '';
  Args[3].n := Y; Args[3].p := nil; Args[3].s := '';
  ExecuteCallback(LowerCase(FOnMouseMoveFunc) + '@#$nn', Args);
end;

procedure TBasCheckBox.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseEnterFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseEnterFunc) + '@#', Args);
end;

procedure TBasCheckBox.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseLeaveFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseLeaveFunc) + '@#', Args);
end;

procedure TBasCheckBox.InternalOnResize(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizeFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizeFunc) + '@#', Args);
end;

procedure TBasCheckBox.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragEnterFunc = '' then Exit();
  Args[0].p := Sender; Args[0].n := 0; Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';
  ExecuteCallback(LowerCase(FOnDragEnterFunc) + '@#nn', Args);
end;

procedure TBasCheckBox.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
var
  Args: array[0..2] of TAsmData;
  Res: TAsmData;
begin
  Operation := TDragOperation.None;
  if FOnDragOverFunc = '' then Exit();
  Args[0].p := Sender; Args[0].n := 0; Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';
  Res := ExecuteCallbackWithResult(LowerCase(FOnDragOverFunc) + '@#nn', Args);
  if Res.n <> 0 then
    Operation := TDragOperation.Move;
end;

procedure TBasCheckBox.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragDropFunc = '' then Exit();
  Args[0].p := Sender; Args[0].n := 0; Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';
  ExecuteCallback(LowerCase(FOnDragDropFunc) + '@#nn', Args);
end;

procedure TBasCheckBox.InternalOnDragLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDragLeaveFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDragLeaveFunc) + '@#', Args);
end;

// -----------------------------------------------------------------------------
// Error Functions
// -----------------------------------------------------------------------------

function n_checkbox_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

function s_checkbox_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

function s_checkbox_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Round(Args[0].n) of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_CHECKBOX: Result.s := 'Invalid checkbox pointer';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent pointer';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Failed to create checkbox';
    ERR_INDEX_OUT_OF_RANGE: Result.s := 'Index out of range';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_checkbox_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

// -----------------------------------------------------------------------------
// Creation and Destruction Functions
// -----------------------------------------------------------------------------

function p_checkbox_new(var Args: array of TAsmData): TAsmData;
var
  CB: TBasCheckBox;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'checkbox#') then Exit();

  try
    if TObject(Args[0].p) is TCommonCustomForm then
      ParentObj := TCommonCustomForm(Args[0].p)
    else
      ParentObj := TFmxObject(Args[0].p);

    CB := TBasCheckBox.Create(nil);
    CB.Parent := ParentObj;
    CB.BasicEngine := ModuleEngine;
    CB.ConsoleOutput := ModuleOutput;
    CB.Position.X := 0;
    CB.Position.Y := 0;
    CB.Width := 120;
    CB.Height := 22;

    Result.p := CB;

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      GC.Add(CB, CHECKBOX_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));
    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'checkbox#: ' + E.Message);
  end;
end;

function p_checkbox_new_text(var Args: array of TAsmData): TAsmData;
var
  CB: TBasCheckBox;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'checkbox#') then Exit();

  try
    if TObject(Args[0].p) is TCommonCustomForm then
      ParentObj := TCommonCustomForm(Args[0].p)
    else
      ParentObj := TFmxObject(Args[0].p);

    CB := TBasCheckBox.Create(nil);
    CB.Parent := ParentObj;
    CB.BasicEngine := ModuleEngine;
    CB.ConsoleOutput := ModuleOutput;
    CB.Text := Args[1].s;
    CB.Position.X := 0;
    CB.Position.Y := 0;
    CB.Width := 120;
    CB.Height := 22;

    Result.p := CB;

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      GC.Add(CB, CHECKBOX_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));
    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'checkbox#: ' + E.Message);
  end;
end;

function p_checkbox_new_pos(var Args: array of TAsmData): TAsmData;
var
  CB: TBasCheckBox;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'checkbox#') then Exit();

  try
    if TObject(Args[0].p) is TCommonCustomForm then
      ParentObj := TCommonCustomForm(Args[0].p)
    else
      ParentObj := TFmxObject(Args[0].p);

    CB := TBasCheckBox.Create(nil);
    CB.Parent := ParentObj;
    CB.BasicEngine := ModuleEngine;
    CB.ConsoleOutput := ModuleOutput;
    CB.Position.X := Args[1].n;
    CB.Position.Y := Args[2].n;
    CB.Width := Args[3].n;
    CB.Height := Args[4].n;

    Result.p := CB;

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      GC.Add(CB, CHECKBOX_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));
    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'checkbox#: ' + E.Message);
  end;
end;

function p_checkbox_new_full(var Args: array of TAsmData): TAsmData;
var
  CB: TBasCheckBox;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'checkbox#') then Exit();

  try
    if TObject(Args[0].p) is TCommonCustomForm then
      ParentObj := TCommonCustomForm(Args[0].p)
    else
      ParentObj := TFmxObject(Args[0].p);

    CB := TBasCheckBox.Create(nil);
    CB.Parent := ParentObj;
    CB.BasicEngine := ModuleEngine;
    CB.ConsoleOutput := ModuleOutput;
    CB.Text := Args[1].s;
    CB.Position.X := Args[2].n;
    CB.Position.Y := Args[3].n;
    CB.Width := Args[4].n;
    CB.Height := Args[5].n;

    Result.p := CB;

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      GC.Add(CB, CHECKBOX_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));
    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'checkbox#: ' + E.Message);
  end;
end;

function n_checkbox_free(var Args: array of TAsmData): TAsmData;
var
  CB: TBasCheckBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateCheckBox(Args[0].p, 'checkbox_free') then Exit();

  try
    CB := TBasCheckBox(Args[0].p);
    CB.DisconnectAllEvents();
    CB.Free();

    // Free via GC using individualized tag
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(CHECKBOX_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'checkbox_free: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Checked State Functions
// -----------------------------------------------------------------------------

function n_checkbox_ischecked_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_ischecked') then Exit();
  try
    if TBasCheckBox(Args[0].p).IsChecked then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_ischecked: ' + E.Message);
  end;
end;

function p_checkbox_ischecked_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_ischecked#') then Exit();
  try
    TBasCheckBox(Args[0].p).IsChecked := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_ischecked#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Text Content Functions
// -----------------------------------------------------------------------------

function s_checkbox_text_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_text$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).Text;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_text$: ' + E.Message);
  end;
end;

function p_checkbox_text_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_text#') then Exit();
  try
    TBasCheckBox(Args[0].p).Text := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_text#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Font Properties Functions
// -----------------------------------------------------------------------------

function s_checkbox_fontfamily_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_fontfamily$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).TextSettings.Font.Family;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_fontfamily$: ' + E.Message);
  end;
end;

function p_checkbox_fontfamily_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_fontfamily#') then Exit();
  try
    TBasCheckBox(Args[0].p).TextSettings.Font.Family := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_fontfamily#: ' + E.Message);
  end;
end;

function n_checkbox_fontsize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_fontsize') then Exit();
  try
    Result.n := TBasCheckBox(Args[0].p).TextSettings.Font.Size;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_fontsize: ' + E.Message);
  end;
end;

function p_checkbox_fontsize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_fontsize#') then Exit();
  try
    TBasCheckBox(Args[0].p).TextSettings.Font.Size := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_fontsize#: ' + E.Message);
  end;
end;

function s_checkbox_fontcolor_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_fontcolor$') then Exit();
  try
    Result.s := '#' + IntToHex(TBasCheckBox(Args[0].p).TextSettings.FontColor, 8);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_fontcolor$: ' + E.Message);
  end;
end;

function p_checkbox_fontcolor_set(var Args: array of TAsmData): TAsmData;
var
  ColorStr: String;
  ColorVal: Cardinal;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_fontcolor#') then Exit();
  try
    ColorStr := Args[1].s;
    if (Length(ColorStr) > 0) and (ColorStr[1] = '#') then
      Delete(ColorStr, 1, 1);
    if Length(ColorStr) = 6 then
      ColorStr := 'FF' + ColorStr;
    ColorVal := StrToInt64('$' + ColorStr);
    TBasCheckBox(Args[0].p).TextSettings.FontColor := ColorVal;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'checkbox_fontcolor#: ' + E.Message);
  end;
end;

function n_checkbox_bold_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_bold') then Exit();
  try
    if TFontStyle.fsBold in TBasCheckBox(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_bold: ' + E.Message);
  end;
end;

function p_checkbox_bold_set(var Args: array of TAsmData): TAsmData;
var
  CB: TBasCheckBox;
  Style: TFontStyles;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_bold#') then Exit();
  try
    CB := TBasCheckBox(Args[0].p);
    Style := CB.TextSettings.Font.Style;
    if Args[1].n <> 0 then
      Style := Style + [TFontStyle.fsBold]
    else
      Style := Style - [TFontStyle.fsBold];
    CB.TextSettings.Font.Style := Style;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_bold#: ' + E.Message);
  end;
end;

function n_checkbox_italic_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_italic') then Exit();
  try
    if TFontStyle.fsItalic in TBasCheckBox(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_italic: ' + E.Message);
  end;
end;

function p_checkbox_italic_set(var Args: array of TAsmData): TAsmData;
var
  CB: TBasCheckBox;
  Style: TFontStyles;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_italic#') then Exit();
  try
    CB := TBasCheckBox(Args[0].p);
    Style := CB.TextSettings.Font.Style;
    if Args[1].n <> 0 then
      Style := Style + [TFontStyle.fsItalic]
    else
      Style := Style - [TFontStyle.fsItalic];
    CB.TextSettings.Font.Style := Style;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_italic#: ' + E.Message);
  end;
end;

function n_checkbox_underline_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_underline') then Exit();
  try
    if TFontStyle.fsUnderline in TBasCheckBox(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_underline: ' + E.Message);
  end;
end;

function p_checkbox_underline_set(var Args: array of TAsmData): TAsmData;
var
  CB: TBasCheckBox;
  Style: TFontStyles;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_underline#') then Exit();
  try
    CB := TBasCheckBox(Args[0].p);
    Style := CB.TextSettings.Font.Style;
    if Args[1].n <> 0 then
      Style := Style + [TFontStyle.fsUnderline]
    else
      Style := Style - [TFontStyle.fsUnderline];
    CB.TextSettings.Font.Style := Style;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_underline#: ' + E.Message);
  end;
end;

function n_checkbox_strikeout_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_strikeout') then Exit();
  try
    if TFontStyle.fsStrikeOut in TBasCheckBox(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_strikeout: ' + E.Message);
  end;
end;

function p_checkbox_strikeout_set(var Args: array of TAsmData): TAsmData;
var
  CB: TBasCheckBox;
  Style: TFontStyles;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_strikeout#') then Exit();
  try
    CB := TBasCheckBox(Args[0].p);
    Style := CB.TextSettings.Font.Style;
    if Args[1].n <> 0 then
      Style := Style + [TFontStyle.fsStrikeOut]
    else
      Style := Style - [TFontStyle.fsStrikeOut];
    CB.TextSettings.Font.Style := Style;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_strikeout#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Position and Size Functions
// -----------------------------------------------------------------------------

function n_checkbox_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_x') then Exit();
  try
    Result.n := TBasCheckBox(Args[0].p).Position.X;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_x: ' + E.Message);
  end;
end;

function p_checkbox_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_x#') then Exit();
  try
    TBasCheckBox(Args[0].p).Position.X := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_x#: ' + E.Message);
  end;
end;

function n_checkbox_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_y') then Exit();
  try
    Result.n := TBasCheckBox(Args[0].p).Position.Y;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_y: ' + E.Message);
  end;
end;

function p_checkbox_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_y#') then Exit();
  try
    TBasCheckBox(Args[0].p).Position.Y := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_y#: ' + E.Message);
  end;
end;

function n_checkbox_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_width') then Exit();
  try
    Result.n := TBasCheckBox(Args[0].p).Width;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_width: ' + E.Message);
  end;
end;

function p_checkbox_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_width#') then Exit();
  try
    TBasCheckBox(Args[0].p).Width := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_width#: ' + E.Message);
  end;
end;

function n_checkbox_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_height') then Exit();
  try
    Result.n := TBasCheckBox(Args[0].p).Height;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_height: ' + E.Message);
  end;
end;

function p_checkbox_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_height#') then Exit();
  try
    TBasCheckBox(Args[0].p).Height := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_height#: ' + E.Message);
  end;
end;

function p_checkbox_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_bounds#') then Exit();
  try
    with TBasCheckBox(Args[0].p) do
    begin
      Position.X := Args[1].n;
      Position.Y := Args[2].n;
      Width := Args[3].n;
      Height := Args[4].n;
    end;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_bounds#: ' + E.Message);
  end;
end;

function p_checkbox_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_move#') then Exit();
  try
    with TBasCheckBox(Args[0].p) do
    begin
      Position.X := Args[1].n;
      Position.Y := Args[2].n;
    end;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_move#: ' + E.Message);
  end;
end;

function p_checkbox_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_size#') then Exit();
  try
    with TBasCheckBox(Args[0].p) do
    begin
      Width := Args[1].n;
      Height := Args[2].n;
    end;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_size#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Alignment Functions
// -----------------------------------------------------------------------------

function n_checkbox_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_align') then Exit();
  try
    Result.n := AlignToInt(TBasCheckBox(Args[0].p).Align);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_align: ' + E.Message);
  end;
end;

function p_checkbox_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_align#') then Exit();
  try
    TBasCheckBox(Args[0].p).Align := AlignFromInt(Round(Args[1].n));
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_align#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Margins Functions
// -----------------------------------------------------------------------------

function n_checkbox_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_marginleft') then Exit();
  try
    Result.n := TBasCheckBox(Args[0].p).Margins.Left;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_marginleft: ' + E.Message);
  end;
end;

function p_checkbox_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_marginleft#') then Exit();
  try
    TBasCheckBox(Args[0].p).Margins.Left := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_marginleft#: ' + E.Message);
  end;
end;

function n_checkbox_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_margintop') then Exit();
  try
    Result.n := TBasCheckBox(Args[0].p).Margins.Top;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_margintop: ' + E.Message);
  end;
end;

function p_checkbox_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_margintop#') then Exit();
  try
    TBasCheckBox(Args[0].p).Margins.Top := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_margintop#: ' + E.Message);
  end;
end;

function n_checkbox_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_marginright') then Exit();
  try
    Result.n := TBasCheckBox(Args[0].p).Margins.Right;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_marginright: ' + E.Message);
  end;
end;

function p_checkbox_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_marginright#') then Exit();
  try
    TBasCheckBox(Args[0].p).Margins.Right := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_marginright#: ' + E.Message);
  end;
end;

function n_checkbox_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_marginbottom') then Exit();
  try
    Result.n := TBasCheckBox(Args[0].p).Margins.Bottom;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_marginbottom: ' + E.Message);
  end;
end;

function p_checkbox_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_marginbottom#') then Exit();
  try
    TBasCheckBox(Args[0].p).Margins.Bottom := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_marginbottom#: ' + E.Message);
  end;
end;

function p_checkbox_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_margins#') then Exit();
  try
    with TBasCheckBox(Args[0].p).Margins do
    begin
      Left := Args[1].n;
      Top := Args[2].n;
      Right := Args[3].n;
      Bottom := Args[4].n;
    end;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_margins#: ' + E.Message);
  end;
end;

function p_checkbox_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_margin#') then Exit();
  try
    with TBasCheckBox(Args[0].p).Margins do
    begin
      Left := Args[1].n;
      Top := Args[1].n;
      Right := Args[1].n;
      Bottom := Args[1].n;
    end;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_margin#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Visibility and State Functions
// -----------------------------------------------------------------------------

function n_checkbox_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_visible') then Exit();
  try
    if TBasCheckBox(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_visible: ' + E.Message);
  end;
end;

function p_checkbox_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_visible#') then Exit();
  try
    TBasCheckBox(Args[0].p).Visible := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_visible#: ' + E.Message);
  end;
end;

function n_checkbox_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_enabled') then Exit();
  try
    if TBasCheckBox(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_enabled: ' + E.Message);
  end;
end;

function p_checkbox_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_enabled#') then Exit();
  try
    TBasCheckBox(Args[0].p).Enabled := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_enabled#: ' + E.Message);
  end;
end;

function n_checkbox_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_opacity') then Exit();
  try
    Result.n := TBasCheckBox(Args[0].p).Opacity;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_opacity: ' + E.Message);
  end;
end;

function p_checkbox_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_opacity#') then Exit();
  try
    TBasCheckBox(Args[0].p).Opacity := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_opacity#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Focus Functions
// -----------------------------------------------------------------------------

function n_checkbox_isfocused_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_isfocused') then Exit();
  try
    if TBasCheckBox(Args[0].p).IsFocused then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_isfocused: ' + E.Message);
  end;
end;

function p_checkbox_setfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_setfocus#') then Exit();
  try
    TBasCheckBox(Args[0].p).SetFocus();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_setfocus#: ' + E.Message);
  end;
end;

function p_checkbox_resetfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_resetfocus#') then Exit();
  try
    TBasCheckBox(Args[0].p).ResetFocus();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_resetfocus#: ' + E.Message);
  end;
end;

function n_checkbox_taborder_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_taborder') then Exit();
  try
    Result.n := TBasCheckBox(Args[0].p).TabOrder;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_taborder: ' + E.Message);
  end;
end;

function p_checkbox_taborder_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_taborder#') then Exit();
  try
    TBasCheckBox(Args[0].p).TabOrder := Round(Args[1].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_taborder#: ' + E.Message);
  end;
end;

function n_checkbox_canfocus_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_canfocus') then Exit();
  try
    if TBasCheckBox(Args[0].p).CanFocus then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_canfocus: ' + E.Message);
  end;
end;

function p_checkbox_canfocus_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_canfocus#') then Exit();
  try
    TBasCheckBox(Args[0].p).CanFocus := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_canfocus#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Tag Functions
// -----------------------------------------------------------------------------

function n_checkbox_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_tag') then Exit();
  try
    Result.n := TBasCheckBox(Args[0].p).Tag;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_tag: ' + E.Message);
  end;
end;

function p_checkbox_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_tag#') then Exit();
  try
    TBasCheckBox(Args[0].p).Tag := Round(Args[1].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_tag#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// HitTest Functions
// -----------------------------------------------------------------------------

function n_checkbox_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_hittest') then Exit();
  try
    if TBasCheckBox(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_hittest: ' + E.Message);
  end;
end;

function p_checkbox_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_hittest#') then Exit();
  try
    TBasCheckBox(Args[0].p).HitTest := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_hittest#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// DragMode Functions
// -----------------------------------------------------------------------------

function n_checkbox_dragmode_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_dragmode') then Exit();
  try
    Result.n := Ord(TBasCheckBox(Args[0].p).DragMode);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_dragmode: ' + E.Message);
  end;
end;

function p_checkbox_dragmode_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_dragmode#') then Exit();
  try
    TBasCheckBox(Args[0].p).DragMode := TDragMode(Round(Args[1].n));
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_dragmode#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Parent Functions
// -----------------------------------------------------------------------------

function p_checkbox_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_parent#') then Exit();
  try
    Result.p := TBasCheckBox(Args[0].p).Parent;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_parent#: ' + E.Message);
  end;
end;

function p_checkbox_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_parent#') then Exit();
  if not ValidateParent(Args[1].p, 'checkbox_parent#') then Exit();
  try
    if TObject(Args[1].p) is TCommonCustomForm then
      TBasCheckBox(Args[0].p).Parent := TCommonCustomForm(Args[1].p)
    else
      TBasCheckBox(Args[0].p).Parent := TFmxObject(Args[1].p);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_parent#: ' + E.Message);
  end;
end;

function p_checkbox_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_bringtofront#') then Exit();
  try
    TBasCheckBox(Args[0].p).BringToFront();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_bringtofront#: ' + E.Message);
  end;
end;

function p_checkbox_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_sendtoback#') then Exit();
  try
    TBasCheckBox(Args[0].p).SendToBack();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_sendtoback#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Event Callback Setters/Getters
// -----------------------------------------------------------------------------

function p_checkbox_onchange_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onchange#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnChangeFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onchange#: ' + E.Message);
  end;
end;

function s_checkbox_onchange_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onchange$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnChangeFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onchange$: ' + E.Message);
  end;
end;

function p_checkbox_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onclick#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnClickFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onclick#: ' + E.Message);
  end;
end;

function s_checkbox_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onclick$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnClickFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onclick$: ' + E.Message);
  end;
end;

function p_checkbox_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_ondblclick#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnDblClickFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_ondblclick#: ' + E.Message);
  end;
end;

function s_checkbox_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_ondblclick$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnDblClickFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_ondblclick$: ' + E.Message);
  end;
end;

function p_checkbox_onenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onenter#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onenter#: ' + E.Message);
  end;
end;

function s_checkbox_onenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onenter$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onenter$: ' + E.Message);
  end;
end;

function p_checkbox_onexit_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onexit#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnExitFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onexit#: ' + E.Message);
  end;
end;

function s_checkbox_onexit_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onexit$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnExitFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onexit$: ' + E.Message);
  end;
end;

function p_checkbox_onkeydown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onkeydown#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnKeyDownFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onkeydown#: ' + E.Message);
  end;
end;

function s_checkbox_onkeydown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onkeydown$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnKeyDownFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onkeydown$: ' + E.Message);
  end;
end;

function p_checkbox_onkeyup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onkeyup#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnKeyUpFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onkeyup#: ' + E.Message);
  end;
end;

function s_checkbox_onkeyup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onkeyup$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnKeyUpFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onkeyup$: ' + E.Message);
  end;
end;

function p_checkbox_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onmousedown#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnMouseDownFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onmousedown#: ' + E.Message);
  end;
end;

function s_checkbox_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onmousedown$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnMouseDownFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onmousedown$: ' + E.Message);
  end;
end;

function p_checkbox_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onmouseup#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnMouseUpFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onmouseup#: ' + E.Message);
  end;
end;

function s_checkbox_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onmouseup$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnMouseUpFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onmouseup$: ' + E.Message);
  end;
end;

function p_checkbox_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onmousemove#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnMouseMoveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onmousemove#: ' + E.Message);
  end;
end;

function s_checkbox_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onmousemove$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnMouseMoveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onmousemove$: ' + E.Message);
  end;
end;

function p_checkbox_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onmouseenter#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnMouseEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onmouseenter#: ' + E.Message);
  end;
end;

function s_checkbox_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onmouseenter$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnMouseEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onmouseenter$: ' + E.Message);
  end;
end;

function p_checkbox_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onmouseleave#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnMouseLeaveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onmouseleave#: ' + E.Message);
  end;
end;

function s_checkbox_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onmouseleave$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnMouseLeaveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onmouseleave$: ' + E.Message);
  end;
end;

function p_checkbox_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onresize#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnResizeFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onresize#: ' + E.Message);
  end;
end;

function s_checkbox_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_onresize$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnResizeFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_onresize$: ' + E.Message);
  end;
end;

function p_checkbox_ondragenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_ondragenter#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnDragEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_ondragenter#: ' + E.Message);
  end;
end;

function s_checkbox_ondragenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_ondragenter$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnDragEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_ondragenter$: ' + E.Message);
  end;
end;

function p_checkbox_ondragover_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_ondragover#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnDragOverFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_ondragover#: ' + E.Message);
  end;
end;

function s_checkbox_ondragover_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_ondragover$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnDragOverFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_ondragover$: ' + E.Message);
  end;
end;

function p_checkbox_ondragdrop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_ondragdrop#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnDragDropFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_ondragdrop#: ' + E.Message);
  end;
end;

function s_checkbox_ondragdrop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_ondragdrop$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnDragDropFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_ondragdrop$: ' + E.Message);
  end;
end;

function p_checkbox_ondragleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_ondragleave#') then Exit();
  try
    TBasCheckBox(Args[0].p).OnDragLeaveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_ondragleave#: ' + E.Message);
  end;
end;

function s_checkbox_ondragleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_ondragleave$') then Exit();
  try
    Result.s := TBasCheckBox(Args[0].p).OnDragLeaveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_ondragleave$: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Clear Callbacks
// -----------------------------------------------------------------------------

function p_checkbox_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCheckBox(Args[0].p, 'checkbox_clearcallbacks#') then Exit();
  try
    with TBasCheckBox(Args[0].p) do
    begin
      OnChangeFunc := '';
      OnClickFunc := '';
      OnDblClickFunc := '';
      OnEnterFunc := '';
      OnExitFunc := '';
      OnKeyDownFunc := '';
      OnKeyUpFunc := '';
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
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'checkbox_clearcallbacks#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Library Registration
// -----------------------------------------------------------------------------

procedure RegisterCheckBoxFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_checkbox_error; Lib.Add('checkbox_error@', Fn);
  Fn.Entry := @s_checkbox_errormsg; Lib.Add('checkbox_errormsg$@', Fn);
  Fn.Entry := @s_checkbox_strerror; Lib.Add('checkbox_strerror$@n', Fn);
  Fn.Entry := @n_checkbox_clearerror; Lib.Add('checkbox_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_checkbox_new; Lib.Add('checkbox#@#', Fn);
  Fn.Entry := @p_checkbox_new_text; Lib.Add('checkbox#@#$', Fn);
  Fn.Entry := @p_checkbox_new_pos; Lib.Add('checkbox#@#nnnn', Fn);
  Fn.Entry := @p_checkbox_new_full; Lib.Add('checkbox#@#$nnnn', Fn);
  Fn.Entry := @n_checkbox_free; Lib.Add('checkbox_free@#', Fn);

  // Checked state
  Fn.Entry := @n_checkbox_ischecked_get; Lib.Add('checkbox_ischecked@#', Fn);
  Fn.Entry := @p_checkbox_ischecked_set; Lib.Add('checkbox_ischecked#@#n', Fn);

  // Text content
  Fn.Entry := @s_checkbox_text_get; Lib.Add('checkbox_text$@#', Fn);
  Fn.Entry := @p_checkbox_text_set; Lib.Add('checkbox_text#@#$', Fn);

  // Font properties
  Fn.Entry := @s_checkbox_fontfamily_get; Lib.Add('checkbox_fontfamily$@#', Fn);
  Fn.Entry := @p_checkbox_fontfamily_set; Lib.Add('checkbox_fontfamily#@#$', Fn);
  Fn.Entry := @n_checkbox_fontsize_get; Lib.Add('checkbox_fontsize@#', Fn);
  Fn.Entry := @p_checkbox_fontsize_set; Lib.Add('checkbox_fontsize#@#n', Fn);
  Fn.Entry := @s_checkbox_fontcolor_get; Lib.Add('checkbox_fontcolor$@#', Fn);
  Fn.Entry := @p_checkbox_fontcolor_set; Lib.Add('checkbox_fontcolor#@#$', Fn);
  Fn.Entry := @n_checkbox_bold_get; Lib.Add('checkbox_bold@#', Fn);
  Fn.Entry := @p_checkbox_bold_set; Lib.Add('checkbox_bold#@#n', Fn);
  Fn.Entry := @n_checkbox_italic_get; Lib.Add('checkbox_italic@#', Fn);
  Fn.Entry := @p_checkbox_italic_set; Lib.Add('checkbox_italic#@#n', Fn);
  Fn.Entry := @n_checkbox_underline_get; Lib.Add('checkbox_underline@#', Fn);
  Fn.Entry := @p_checkbox_underline_set; Lib.Add('checkbox_underline#@#n', Fn);
  Fn.Entry := @n_checkbox_strikeout_get; Lib.Add('checkbox_strikeout@#', Fn);
  Fn.Entry := @p_checkbox_strikeout_set; Lib.Add('checkbox_strikeout#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_checkbox_x_get; Lib.Add('checkbox_x@#', Fn);
  Fn.Entry := @p_checkbox_x_set; Lib.Add('checkbox_x#@#n', Fn);
  Fn.Entry := @n_checkbox_y_get; Lib.Add('checkbox_y@#', Fn);
  Fn.Entry := @p_checkbox_y_set; Lib.Add('checkbox_y#@#n', Fn);
  Fn.Entry := @n_checkbox_width_get; Lib.Add('checkbox_width@#', Fn);
  Fn.Entry := @p_checkbox_width_set; Lib.Add('checkbox_width#@#n', Fn);
  Fn.Entry := @n_checkbox_height_get; Lib.Add('checkbox_height@#', Fn);
  Fn.Entry := @p_checkbox_height_set; Lib.Add('checkbox_height#@#n', Fn);
  Fn.Entry := @p_checkbox_bounds_set; Lib.Add('checkbox_bounds#@#nnnn', Fn);
  Fn.Entry := @p_checkbox_move_set; Lib.Add('checkbox_move#@#nn', Fn);
  Fn.Entry := @p_checkbox_size_set; Lib.Add('checkbox_size#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_checkbox_align_get; Lib.Add('checkbox_align@#', Fn);
  Fn.Entry := @p_checkbox_align_set; Lib.Add('checkbox_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_checkbox_marginleft_get; Lib.Add('checkbox_marginleft@#', Fn);
  Fn.Entry := @p_checkbox_marginleft_set; Lib.Add('checkbox_marginleft#@#n', Fn);
  Fn.Entry := @n_checkbox_margintop_get; Lib.Add('checkbox_margintop@#', Fn);
  Fn.Entry := @p_checkbox_margintop_set; Lib.Add('checkbox_margintop#@#n', Fn);
  Fn.Entry := @n_checkbox_marginright_get; Lib.Add('checkbox_marginright@#', Fn);
  Fn.Entry := @p_checkbox_marginright_set; Lib.Add('checkbox_marginright#@#n', Fn);
  Fn.Entry := @n_checkbox_marginbottom_get; Lib.Add('checkbox_marginbottom@#', Fn);
  Fn.Entry := @p_checkbox_marginbottom_set; Lib.Add('checkbox_marginbottom#@#n', Fn);
  Fn.Entry := @p_checkbox_margins_set; Lib.Add('checkbox_margins#@#nnnn', Fn);
  Fn.Entry := @p_checkbox_margin_set; Lib.Add('checkbox_margin#@#n', Fn);

  // Visibility and state
  Fn.Entry := @n_checkbox_visible_get; Lib.Add('checkbox_visible@#', Fn);
  Fn.Entry := @p_checkbox_visible_set; Lib.Add('checkbox_visible#@#n', Fn);
  Fn.Entry := @n_checkbox_enabled_get; Lib.Add('checkbox_enabled@#', Fn);
  Fn.Entry := @p_checkbox_enabled_set; Lib.Add('checkbox_enabled#@#n', Fn);
  Fn.Entry := @n_checkbox_opacity_get; Lib.Add('checkbox_opacity@#', Fn);
  Fn.Entry := @p_checkbox_opacity_set; Lib.Add('checkbox_opacity#@#n', Fn);

  // Focus
  Fn.Entry := @n_checkbox_isfocused_get; Lib.Add('checkbox_isfocused@#', Fn);
  Fn.Entry := @p_checkbox_setfocus; Lib.Add('checkbox_setfocus#@#', Fn);
  Fn.Entry := @p_checkbox_resetfocus; Lib.Add('checkbox_resetfocus#@#', Fn);
  Fn.Entry := @n_checkbox_taborder_get; Lib.Add('checkbox_taborder@#', Fn);
  Fn.Entry := @p_checkbox_taborder_set; Lib.Add('checkbox_taborder#@#n', Fn);
  Fn.Entry := @n_checkbox_canfocus_get; Lib.Add('checkbox_canfocus@#', Fn);
  Fn.Entry := @p_checkbox_canfocus_set; Lib.Add('checkbox_canfocus#@#n', Fn);

  // Tag
  Fn.Entry := @n_checkbox_tag_get; Lib.Add('checkbox_tag@#', Fn);
  Fn.Entry := @p_checkbox_tag_set; Lib.Add('checkbox_tag#@#n', Fn);

  // HitTest
  Fn.Entry := @n_checkbox_hittest_get; Lib.Add('checkbox_hittest@#', Fn);
  Fn.Entry := @p_checkbox_hittest_set; Lib.Add('checkbox_hittest#@#n', Fn);

  // DragMode
  Fn.Entry := @n_checkbox_dragmode_get; Lib.Add('checkbox_dragmode@#', Fn);
  Fn.Entry := @p_checkbox_dragmode_set; Lib.Add('checkbox_dragmode#@#n', Fn);

  // Parent
  Fn.Entry := @p_checkbox_parent_get; Lib.Add('checkbox_parent#@#', Fn);
  Fn.Entry := @p_checkbox_parent_set; Lib.Add('checkbox_parent#@##', Fn);
  Fn.Entry := @p_checkbox_bringtofront; Lib.Add('checkbox_bringtofront#@#', Fn);
  Fn.Entry := @p_checkbox_sendtoback; Lib.Add('checkbox_sendtoback#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_checkbox_onchange_set; Lib.Add('checkbox_onchange#@#$', Fn);
  Fn.Entry := @s_checkbox_onchange_get; Lib.Add('checkbox_onchange$@#', Fn);
  Fn.Entry := @p_checkbox_onclick_set; Lib.Add('checkbox_onclick#@#$', Fn);
  Fn.Entry := @s_checkbox_onclick_get; Lib.Add('checkbox_onclick$@#', Fn);
  Fn.Entry := @p_checkbox_ondblclick_set; Lib.Add('checkbox_ondblclick#@#$', Fn);
  Fn.Entry := @s_checkbox_ondblclick_get; Lib.Add('checkbox_ondblclick$@#', Fn);
  Fn.Entry := @p_checkbox_onenter_set; Lib.Add('checkbox_onenter#@#$', Fn);
  Fn.Entry := @s_checkbox_onenter_get; Lib.Add('checkbox_onenter$@#', Fn);
  Fn.Entry := @p_checkbox_onexit_set; Lib.Add('checkbox_onexit#@#$', Fn);
  Fn.Entry := @s_checkbox_onexit_get; Lib.Add('checkbox_onexit$@#', Fn);
  Fn.Entry := @p_checkbox_onkeydown_set; Lib.Add('checkbox_onkeydown#@#$', Fn);
  Fn.Entry := @s_checkbox_onkeydown_get; Lib.Add('checkbox_onkeydown$@#', Fn);
  Fn.Entry := @p_checkbox_onkeyup_set; Lib.Add('checkbox_onkeyup#@#$', Fn);
  Fn.Entry := @s_checkbox_onkeyup_get; Lib.Add('checkbox_onkeyup$@#', Fn);
  Fn.Entry := @p_checkbox_onmousedown_set; Lib.Add('checkbox_onmousedown#@#$', Fn);
  Fn.Entry := @s_checkbox_onmousedown_get; Lib.Add('checkbox_onmousedown$@#', Fn);
  Fn.Entry := @p_checkbox_onmouseup_set; Lib.Add('checkbox_onmouseup#@#$', Fn);
  Fn.Entry := @s_checkbox_onmouseup_get; Lib.Add('checkbox_onmouseup$@#', Fn);
  Fn.Entry := @p_checkbox_onmousemove_set; Lib.Add('checkbox_onmousemove#@#$', Fn);
  Fn.Entry := @s_checkbox_onmousemove_get; Lib.Add('checkbox_onmousemove$@#', Fn);
  Fn.Entry := @p_checkbox_onmouseenter_set; Lib.Add('checkbox_onmouseenter#@#$', Fn);
  Fn.Entry := @s_checkbox_onmouseenter_get; Lib.Add('checkbox_onmouseenter$@#', Fn);
  Fn.Entry := @p_checkbox_onmouseleave_set; Lib.Add('checkbox_onmouseleave#@#$', Fn);
  Fn.Entry := @s_checkbox_onmouseleave_get; Lib.Add('checkbox_onmouseleave$@#', Fn);
  Fn.Entry := @p_checkbox_onresize_set; Lib.Add('checkbox_onresize#@#$', Fn);
  Fn.Entry := @s_checkbox_onresize_get; Lib.Add('checkbox_onresize$@#', Fn);

  // Drag & Drop event callbacks
  Fn.Entry := @p_checkbox_ondragenter_set; Lib.Add('checkbox_ondragenter#@#$', Fn);
  Fn.Entry := @s_checkbox_ondragenter_get; Lib.Add('checkbox_ondragenter$@#', Fn);
  Fn.Entry := @p_checkbox_ondragover_set; Lib.Add('checkbox_ondragover#@#$', Fn);
  Fn.Entry := @s_checkbox_ondragover_get; Lib.Add('checkbox_ondragover$@#', Fn);
  Fn.Entry := @p_checkbox_ondragdrop_set; Lib.Add('checkbox_ondragdrop#@#$', Fn);
  Fn.Entry := @s_checkbox_ondragdrop_get; Lib.Add('checkbox_ondragdrop$@#', Fn);
  Fn.Entry := @p_checkbox_ondragleave_set; Lib.Add('checkbox_ondragleave#@#$', Fn);
  Fn.Entry := @s_checkbox_ondragleave_get; Lib.Add('checkbox_ondragleave$@#', Fn);

  // Clear callbacks
  Fn.Entry := @p_checkbox_clearcallbacks; Lib.Add('checkbox_clearcallbacks#@#', Fn);
end;

end.

