unit TrackBarLib;

{******************************************************************************
  TrackBarLib - TrackBar/Slider Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TTrackBar wrapper functionality for creating
  and managing slider controls in Plan9Basic programs.

  Function Count: 90+ functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All track bars are created at RUNTIME using TTrackBar.Create with
  dynamic parent assignment. This ensures proper dynamic creation across
  all platforms.

  EVENT CONNECTION MODEL:
  =======================
  Events are connected/disconnected individually when callbacks are set:
  - Setting a non-empty callback name connects ONLY that specific event
  - Setting an empty callback name ("") disconnects ONLY that specific event
  - No events are connected by default in the constructor

  FEATURES:
  =========
  - TrackBar creation and lifecycle management
  - Min/Max/Value range control
  - Orientation (horizontal/vertical)
  - Frequency (tick mark spacing)
  - Complete positioning and alignment
  - Full event support with BASIC callback integration
  - Drag and drop support

  EVENTS SUPPORT:
  ===============
  - OnChange: Value changed (after user releases)
  - OnTracking: Value changing (while user drags)
  - OnClick: TrackBar was clicked
  - OnDblClick: TrackBar was double-clicked
  - OnEnter: TrackBar received focus
  - OnExit: TrackBar lost focus
  - OnKeyDown: Key was pressed while focused
  - OnKeyUp: Key was released while focused
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over track bar
  - OnMouseEnter: Mouse entered track bar area
  - OnMouseLeave: Mouse left track bar area
  - OnResize: TrackBar is being resized
  - OnDragEnter: Drag operation entered track bar
  - OnDragOver: Drag operation over track bar (return non-zero to accept)
  - OnDragDrop: Item was dropped on track bar
  - OnDragLeave: Drag operation left track bar

  USAGE PATTERN:
  ==============
    let frm# = form#("TrackBar Demo", 400, 300)

    ' Create a track bar
    let tb# = trackbar#(frm#)
    trackbar_move#(tb#, 50, 50)
    trackbar_size#(tb#, 300, 45)
    trackbar_min#(tb#, 0)
    trackbar_max#(tb#, 100)
    trackbar_value#(tb#, 50)
    trackbar_onchange#(tb#, "OnValueChanged")

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnValueChanged(sender#) local val
      val = trackbar_value(sender#)
      println "Value: " + str$(val)
    endfunction

    function OnTracking(sender#) local val
      val = trackbar_value(sender#)
      println "Tracking: " + str$(val)
    endfunction

  ORIENTATION VALUES:
  ===================
  0 = Horizontal (default)
  1 = Vertical

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.StdCtrls,
  FMX.Controls.Presentation,
  basic, exec, UnitGC, HandleRegistry;

type
  TBasTrackBar = class(TTrackBar)
  private
    FOnChangeFunc: String;
    FOnTrackingFunc: String;
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
    procedure InternalOnTracking(Sender: TObject);
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
    procedure SetOnTrackingFunc(const Value: String);
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

    procedure ChoosePresentationName(Sender: TObject; var PresenterName: string);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure DisconnectAllEvents();

    property OnChangeFunc: String read FOnChangeFunc write SetOnChangeFunc;
    property OnTrackingFunc: String read FOnTrackingFunc write SetOnTrackingFunc;
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

procedure RegisterTrackBarFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  TRACKBAR_GC_TAG = 'BASIC_TRACKBAR';
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_TRACKBAR = 1;
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

  ORIENTATION_HORIZONTAL = 0;
  ORIENTATION_VERTICAL = 1;

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

function ValidateTrackBar(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_TRACKBAR, FuncName + ': Nil pointer');
    Exit();
  end;

  try
    if not(IsHandleOf(P, TBasTrackBar)) then
    begin
      SetError(ERR_INVALID_TRACKBAR, FuncName + ': Invalid object');
      Exit();
    end;
  except
    SetError(ERR_INVALID_TRACKBAR, FuncName + ': Invalid pointer');
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

procedure TBasTrackBar.ChoosePresentationName(Sender: TObject; var PresenterName: string);
begin
  PresenterName := 'TrackBar-style';
end;

// -----------------------------------------------------------------------------
// TBasTrackBar Implementation
// -----------------------------------------------------------------------------

constructor TBasTrackBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);

  OnPresentationNameChoosing := ChoosePresentationName;

  FOnChangeFunc := '';
  FOnTrackingFunc := '';
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
end;

destructor TBasTrackBar.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasTrackBar.DisconnectAllEvents();
begin
  OnChange := nil;
  OnTracking := nil;
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

procedure TBasTrackBar.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
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
        FConsoleOutput.Add('*** TrackBar Callback Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

function TBasTrackBar.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
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
        FConsoleOutput.Add('*** TrackBar Callback Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

// Event setters with granular connection/disconnection

procedure TBasTrackBar.SetOnChangeFunc(const Value: String);
begin
  FOnChangeFunc := Value;
  if Value <> '' then
    OnChange := InternalOnChange
  else
    OnChange := nil;
end;

procedure TBasTrackBar.SetOnTrackingFunc(const Value: String);
begin
  FOnTrackingFunc := Value;
  if Value <> '' then
    OnTracking := InternalOnTracking
  else
    OnTracking := nil;
end;

procedure TBasTrackBar.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    OnClick := InternalOnClick
  else
    OnClick := nil;
end;

procedure TBasTrackBar.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    OnDblClick := InternalOnDblClick
  else
    OnDblClick := nil;
end;

procedure TBasTrackBar.SetOnEnterFunc(const Value: String);
begin
  FOnEnterFunc := Value;
  if Value <> '' then
    OnEnter := InternalOnEnter
  else
    OnEnter := nil;
end;

procedure TBasTrackBar.SetOnExitFunc(const Value: String);
begin
  FOnExitFunc := Value;
  if Value <> '' then
    OnExit := InternalOnExit
  else
    OnExit := nil;
end;

procedure TBasTrackBar.SetOnKeyDownFunc(const Value: String);
begin
  FOnKeyDownFunc := Value;
  if Value <> '' then
    OnKeyDown := InternalOnKeyDown
  else
    OnKeyDown := nil;
end;

procedure TBasTrackBar.SetOnKeyUpFunc(const Value: String);
begin
  FOnKeyUpFunc := Value;
  if Value <> '' then
    OnKeyUp := InternalOnKeyUp
  else
    OnKeyUp := nil;
end;

procedure TBasTrackBar.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    OnMouseDown := InternalOnMouseDown
  else
    OnMouseDown := nil;
end;

procedure TBasTrackBar.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    OnMouseUp := InternalOnMouseUp
  else
    OnMouseUp := nil;
end;

procedure TBasTrackBar.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    OnMouseMove := InternalOnMouseMove
  else
    OnMouseMove := nil;
end;

procedure TBasTrackBar.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    OnMouseEnter := InternalOnMouseEnter
  else
    OnMouseEnter := nil;
end;

procedure TBasTrackBar.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    OnMouseLeave := InternalOnMouseLeave
  else
    OnMouseLeave := nil;
end;

procedure TBasTrackBar.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    OnResize := InternalOnResize
  else
    OnResize := nil;
end;

procedure TBasTrackBar.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    OnDragEnter := InternalOnDragEnter
  else
    OnDragEnter := nil;
end;

procedure TBasTrackBar.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    OnDragOver := InternalOnDragOver
  else
    OnDragOver := nil;
end;

procedure TBasTrackBar.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    OnDragDrop := InternalOnDragDrop
  else
    OnDragDrop := nil;
end;

procedure TBasTrackBar.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    OnDragLeave := InternalOnDragLeave
  else
    OnDragLeave := nil;
end;

// Internal event handlers

procedure TBasTrackBar.InternalOnChange(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnChangeFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Sender;
  SenderArg.s := '';

  ExecuteCallback(FOnChangeFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasTrackBar.InternalOnTracking(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnTrackingFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Sender;
  SenderArg.s := '';

  ExecuteCallback(FOnTrackingFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasTrackBar.InternalOnClick(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnClickFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Sender;
  SenderArg.s := '';

  ExecuteCallback(FOnClickFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasTrackBar.InternalOnDblClick(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnDblClickFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Sender;
  SenderArg.s := '';

  ExecuteCallback(FOnDblClickFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasTrackBar.InternalOnEnter(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnEnterFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Sender;
  SenderArg.s := '';

  ExecuteCallback(FOnEnterFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasTrackBar.InternalOnExit(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnExitFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Sender;
  SenderArg.s := '';

  ExecuteCallback(FOnExitFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasTrackBar.InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnKeyDownFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Sender; Args[0].s := '';
  Args[1].n := Key; Args[1].p := nil; Args[1].s := '';
  Args[2].n := 0; Args[2].p := nil; Args[2].s := KeyChar;
  Args[3].n := 0; Args[3].p := nil; Args[3].s := ShiftStateToString(Shift);

  ExecuteCallback(FOnKeyDownFunc.ToLower() + '@#n$$', Args);
end;

procedure TBasTrackBar.InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnKeyUpFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Sender; Args[0].s := '';
  Args[1].n := Key; Args[1].p := nil; Args[1].s := '';
  Args[2].n := 0; Args[2].p := nil; Args[2].s := KeyChar;
  Args[3].n := 0; Args[3].p := nil; Args[3].s := ShiftStateToString(Shift);

  ExecuteCallback(FOnKeyUpFunc.ToLower() + '@#n$$', Args);
end;

procedure TBasTrackBar.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseDownFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Sender; Args[0].s := '';
  Args[1].n := MouseButtonToInt(Button); Args[1].p := nil; Args[1].s := '';
  Args[2].n := 0; Args[2].p := nil; Args[2].s := ShiftStateToString(Shift);
  Args[3].n := X; Args[3].p := nil; Args[3].s := '';
  Args[4].n := Y; Args[4].p := nil; Args[4].s := '';

  ExecuteCallback(FOnMouseDownFunc.ToLower() + '@#n$nn', Args);
end;

procedure TBasTrackBar.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseUpFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Sender; Args[0].s := '';
  Args[1].n := MouseButtonToInt(Button); Args[1].p := nil; Args[1].s := '';
  Args[2].n := 0; Args[2].p := nil; Args[2].s := ShiftStateToString(Shift);
  Args[3].n := X; Args[3].p := nil; Args[3].s := '';
  Args[4].n := Y; Args[4].p := nil; Args[4].s := '';

  ExecuteCallback(FOnMouseUpFunc.ToLower() + '@#n$nn', Args);
end;

procedure TBasTrackBar.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnMouseMoveFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Sender; Args[0].s := '';
  Args[1].n := 0; Args[1].p := nil; Args[1].s := ShiftStateToString(Shift);
  Args[2].n := X; Args[2].p := nil; Args[2].s := '';
  Args[3].n := Y; Args[3].p := nil; Args[3].s := '';

  ExecuteCallback(FOnMouseMoveFunc.ToLower() + '@#$nn', Args);
end;

procedure TBasTrackBar.InternalOnMouseEnter(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnMouseEnterFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Sender;
  SenderArg.s := '';

  ExecuteCallback(FOnMouseEnterFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasTrackBar.InternalOnMouseLeave(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnMouseLeaveFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Sender;
  SenderArg.s := '';

  ExecuteCallback(FOnMouseLeaveFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasTrackBar.InternalOnResize(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnResizeFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Sender;
  SenderArg.s := '';

  ExecuteCallback(FOnResizeFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasTrackBar.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragEnterFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Sender; Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';

  ExecuteCallback(FOnDragEnterFunc.ToLower() + '@#nn', Args);
end;

procedure TBasTrackBar.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
var
  Args: array[0..2] of TAsmData;
  Ret: TAsmData;
begin
  if FOnDragOverFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Sender; Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';

  Ret := ExecuteCallbackWithResult(FOnDragOverFunc + '@#nn', Args);

  if Ret.n <> 0 then
    Operation := TDragOperation.Move
  else
    Operation := TDragOperation.None;
end;

procedure TBasTrackBar.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragDropFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Sender; Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';

  ExecuteCallback(FOnDragDropFunc.ToLower() + '@#nn', Args);
end;

procedure TBasTrackBar.InternalOnDragLeave(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnDragLeaveFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Sender;
  SenderArg.s := '';

  ExecuteCallback(FOnDragLeaveFunc.ToLower() + '@#', [SenderArg]);
end;

// -----------------------------------------------------------------------------
// Error Handling Functions
// -----------------------------------------------------------------------------

function n_trackbar_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

function s_trackbar_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

function s_trackbar_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);

  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_TRACKBAR: Result.s := 'Invalid track bar';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Creation failed';
    ERR_INDEX_OUT_OF_RANGE: Result.s := 'Index out of range';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_trackbar_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

// -----------------------------------------------------------------------------
// Creation/Destruction Functions
// -----------------------------------------------------------------------------

function p_trackbar_new(var Args: array of TAsmData): TAsmData;
var
  tb: TBasTrackBar;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'trackbar#') then Exit();

  try
    tb := TBasTrackBar.Create(nil);
    tb.BasicEngine := ModuleEngine;
    tb.ConsoleOutput := ModuleOutput;

    if TObject(Args[0].p) is TCommonCustomForm then
      tb.Parent := TCommonCustomForm(Args[0].p)
    else
    begin
      ParentObj := TFmxObject(Args[0].p);
      tb.Parent := ParentObj;
    end;

    Result.p := Pointer(tb);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(tb, TRACKBAR_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'trackbar#: ' + E.Message);
  end;
end;

function p_trackbar_new_pos(var Args: array of TAsmData): TAsmData;
var
  tb: TBasTrackBar;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'trackbar#') then Exit();

  try
    tb := TBasTrackBar.Create(nil);
    tb.BasicEngine := ModuleEngine;
    tb.ConsoleOutput := ModuleOutput;

    if TObject(Args[0].p) is TCommonCustomForm then
      tb.Parent := TCommonCustomForm(Args[0].p)
    else
    begin
      ParentObj := TFmxObject(Args[0].p);
      tb.Parent := ParentObj;
    end;

    tb.Position.X := Args[1].n;
    tb.Position.Y := Args[2].n;
    tb.Width := Args[3].n;
    tb.Height := Args[4].n;

    Result.p := Pointer(tb);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(tb, TRACKBAR_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'trackbar#: ' + E.Message);
  end;
end;

function n_trackbar_free(var Args: array of TAsmData): TAsmData;
var
  tb: TBasTrackBar;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_free') then
    Exit();

  try
    tb := TBasTrackBar(Args[0].p);
    tb.DisconnectAllEvents();
    tb.Free();

    // Use GC to properly free the control
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(TRACKBAR_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_free: ' + E.Message);
    end;
  end;
end;

// -----------------------------------------------------------------------------
// Value Properties
// -----------------------------------------------------------------------------

function n_trackbar_value_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_value') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Value;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_value: ' + E.Message);
  end;
end;

function p_trackbar_value_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_value#') then Exit();

  try
    TBasTrackBar(Args[0].p).Value := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_value#: ' + E.Message);
  end;
end;

function n_trackbar_min_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_min') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Min;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_min: ' + E.Message);
  end;
end;

function p_trackbar_min_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_min#') then Exit();

  try
    TBasTrackBar(Args[0].p).Min := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_min#: ' + E.Message);
  end;
end;

function n_trackbar_max_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_max') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Max;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_max: ' + E.Message);
  end;
end;

function p_trackbar_max_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_max#') then Exit();

  try
    TBasTrackBar(Args[0].p).Max := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_max#: ' + E.Message);
  end;
end;

function n_trackbar_frequency_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_frequency') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Frequency;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_frequency: ' + E.Message);
  end;
end;

function p_trackbar_frequency_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_frequency#') then Exit();

  try
    TBasTrackBar(Args[0].p).Frequency := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_frequency#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Orientation
// -----------------------------------------------------------------------------

function n_trackbar_orientation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_orientation') then Exit();

  try
    if TBasTrackBar(Args[0].p).Orientation = TOrientation.Horizontal then
      Result.n := ORIENTATION_HORIZONTAL
    else
      Result.n := ORIENTATION_VERTICAL;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_orientation: ' + E.Message);
  end;
end;

function p_trackbar_orientation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_orientation#') then Exit();

  try
    if Trunc(Args[1].n) = ORIENTATION_VERTICAL then
      TBasTrackBar(Args[0].p).Orientation := TOrientation.Vertical
    else
      TBasTrackBar(Args[0].p).Orientation := TOrientation.Horizontal;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_orientation#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Position and Size
// -----------------------------------------------------------------------------

function n_trackbar_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_x') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Position.X;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_x: ' + E.Message);
  end;
end;

function p_trackbar_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_x#') then Exit();

  try
    TBasTrackBar(Args[0].p).Position.X := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_x#: ' + E.Message);
  end;
end;

function n_trackbar_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_y') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Position.Y;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_y: ' + E.Message);
  end;
end;

function p_trackbar_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_y#') then Exit();

  try
    TBasTrackBar(Args[0].p).Position.Y := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_y#: ' + E.Message);
  end;
end;

function n_trackbar_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_width') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Width;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_width: ' + E.Message);
  end;
end;

function p_trackbar_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_width#') then Exit();

  try
    TBasTrackBar(Args[0].p).Width := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_width#: ' + E.Message);
  end;
end;

function n_trackbar_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_height') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Height;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_height: ' + E.Message);
  end;
end;

function p_trackbar_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_height#') then Exit();

  try
    TBasTrackBar(Args[0].p).Height := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_height#: ' + E.Message);
  end;
end;

function p_trackbar_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_bounds#') then Exit();

  try
    TBasTrackBar(Args[0].p).SetBounds(Args[1].n, Args[2].n, Args[3].n, Args[4].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_bounds#: ' + E.Message);
  end;
end;

function p_trackbar_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_move#') then Exit();

  try
    TBasTrackBar(Args[0].p).Position.X := Args[1].n;
    TBasTrackBar(Args[0].p).Position.Y := Args[2].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_move#: ' + E.Message);
  end;
end;

function p_trackbar_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_size#') then Exit();

  try
    TBasTrackBar(Args[0].p).Width := Args[1].n;
    TBasTrackBar(Args[0].p).Height := Args[2].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_size#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Alignment
// -----------------------------------------------------------------------------

function n_trackbar_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_align') then Exit();

  try
    Result.n := AlignToInt(TBasTrackBar(Args[0].p).Align);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_align: ' + E.Message);
  end;
end;

function p_trackbar_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_align#') then Exit();

  try
    TBasTrackBar(Args[0].p).Align := AlignFromInt(Trunc(Args[1].n));
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_align#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Margins
// -----------------------------------------------------------------------------

function n_trackbar_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_marginleft') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Margins.Left;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_marginleft: ' + E.Message);
  end;
end;

function p_trackbar_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_marginleft#') then Exit();

  try
    TBasTrackBar(Args[0].p).Margins.Left := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_marginleft#: ' + E.Message);
  end;
end;

function n_trackbar_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_margintop') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Margins.Top;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_margintop: ' + E.Message);
  end;
end;

function p_trackbar_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_margintop#') then Exit();

  try
    TBasTrackBar(Args[0].p).Margins.Top := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_margintop#: ' + E.Message);
  end;
end;

function n_trackbar_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_marginright') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Margins.Right;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_marginright: ' + E.Message);
  end;
end;

function p_trackbar_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_marginright#') then Exit();

  try
    TBasTrackBar(Args[0].p).Margins.Right := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_marginright#: ' + E.Message);
  end;
end;

function n_trackbar_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_marginbottom') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Margins.Bottom;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_marginbottom: ' + E.Message);
  end;
end;

function p_trackbar_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_marginbottom#') then Exit();

  try
    TBasTrackBar(Args[0].p).Margins.Bottom := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_marginbottom#: ' + E.Message);
  end;
end;

function p_trackbar_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_margins#') then Exit();

  try
    TBasTrackBar(Args[0].p).Margins.Left := Args[1].n;
    TBasTrackBar(Args[0].p).Margins.Top := Args[2].n;
    TBasTrackBar(Args[0].p).Margins.Right := Args[3].n;
    TBasTrackBar(Args[0].p).Margins.Bottom := Args[4].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_margins#: ' + E.Message);
  end;
end;

function p_trackbar_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_margin#') then Exit();

  try
    TBasTrackBar(Args[0].p).Margins.Left := Args[1].n;
    TBasTrackBar(Args[0].p).Margins.Top := Args[1].n;
    TBasTrackBar(Args[0].p).Margins.Right := Args[1].n;
    TBasTrackBar(Args[0].p).Margins.Bottom := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_margin#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Visibility and State
// -----------------------------------------------------------------------------

function n_trackbar_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_visible') then Exit();

  try
    if TBasTrackBar(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_visible: ' + E.Message);
  end;
end;

function p_trackbar_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_visible#') then Exit();

  try
    TBasTrackBar(Args[0].p).Visible := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_visible#: ' + E.Message);
  end;
end;

function n_trackbar_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_enabled') then Exit();

  try
    if TBasTrackBar(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_enabled: ' + E.Message);
  end;
end;

function p_trackbar_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_enabled#') then Exit();

  try
    TBasTrackBar(Args[0].p).Enabled := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_enabled#: ' + E.Message);
  end;
end;

function n_trackbar_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_opacity') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Opacity;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_opacity: ' + E.Message);
  end;
end;

function p_trackbar_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_opacity#') then Exit();

  try
    TBasTrackBar(Args[0].p).Opacity := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_opacity#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Focus
// -----------------------------------------------------------------------------

function n_trackbar_isfocused_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_isfocused') then Exit();

  try
    if TBasTrackBar(Args[0].p).IsFocused then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_isfocused: ' + E.Message);
  end;
end;

function p_trackbar_setfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_setfocus#') then Exit();

  try
    TBasTrackBar(Args[0].p).SetFocus();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_setfocus#: ' + E.Message);
  end;
end;

function p_trackbar_resetfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_resetfocus#') then Exit();

  try
    TBasTrackBar(Args[0].p).ResetFocus();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_resetfocus#: ' + E.Message);
  end;
end;

function n_trackbar_taborder_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_taborder') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).TabOrder;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_taborder: ' + E.Message);
  end;
end;

function p_trackbar_taborder_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_taborder#') then Exit();

  try
    TBasTrackBar(Args[0].p).TabOrder := Trunc(Args[1].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_taborder#: ' + E.Message);
  end;
end;

function n_trackbar_canfocus_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_canfocus') then Exit();

  try
    if TBasTrackBar(Args[0].p).CanFocus then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_canfocus: ' + E.Message);
  end;
end;

function p_trackbar_canfocus_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_canfocus#') then Exit();

  try
    TBasTrackBar(Args[0].p).CanFocus := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_canfocus#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Tag
// -----------------------------------------------------------------------------

function n_trackbar_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_tag') then Exit();

  try
    Result.n := TBasTrackBar(Args[0].p).Tag;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_tag: ' + E.Message);
  end;
end;

function p_trackbar_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_tag#') then Exit();

  try
    TBasTrackBar(Args[0].p).Tag := Trunc(Args[1].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_tag#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// HitTest
// -----------------------------------------------------------------------------

function n_trackbar_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_hittest') then Exit();

  try
    if TBasTrackBar(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_hittest: ' + E.Message);
  end;
end;

function p_trackbar_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_hittest#') then Exit();

  try
    TBasTrackBar(Args[0].p).HitTest := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_hittest#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// DragMode
// -----------------------------------------------------------------------------

function n_trackbar_dragmode_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_dragmode') then Exit();

  try
    if TBasTrackBar(Args[0].p).DragMode = TDragMode.dmAutomatic then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_dragmode: ' + E.Message);
  end;
end;

function p_trackbar_dragmode_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_dragmode#') then Exit();

  try
    if Args[1].n <> 0 then
      TBasTrackBar(Args[0].p).DragMode := TDragMode.dmAutomatic
    else
      TBasTrackBar(Args[0].p).DragMode := TDragMode.dmManual;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_dragmode#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Parent
// -----------------------------------------------------------------------------

function p_trackbar_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_parent#') then Exit();

  try
    Result.p := TBasTrackBar(Args[0].p).Parent;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_parent#: ' + E.Message);
  end;
end;

function p_trackbar_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_parent#') then Exit();
  if not ValidateParent(Args[1].p, 'trackbar_parent#') then Exit();

  try
    if TObject(Args[1].p) is TCommonCustomForm then
      TBasTrackBar(Args[0].p).Parent := TCommonCustomForm(Args[1].p)
    else
      TBasTrackBar(Args[0].p).Parent := TFmxObject(Args[1].p);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_parent#: ' + E.Message);
  end;
end;

function p_trackbar_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_bringtofront#') then Exit();

  try
    TBasTrackBar(Args[0].p).BringToFront();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_bringtofront#: ' + E.Message);
  end;
end;

function p_trackbar_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_sendtoback#') then Exit();

  try
    TBasTrackBar(Args[0].p).SendToBack();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_sendtoback#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Event Callbacks
// -----------------------------------------------------------------------------

function p_trackbar_onchange_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onchange#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnChangeFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onchange#: ' + E.Message);
  end;
end;

function s_trackbar_onchange_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onchange$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnChangeFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onchange$: ' + E.Message);
  end;
end;

function p_trackbar_ontracking_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_ontracking#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnTrackingFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_ontracking#: ' + E.Message);
  end;
end;

function s_trackbar_ontracking_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_ontracking$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnTrackingFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_ontracking$: ' + E.Message);
  end;
end;

function p_trackbar_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onclick#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnClickFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onclick#: ' + E.Message);
  end;
end;

function s_trackbar_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onclick$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnClickFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onclick$: ' + E.Message);
  end;
end;

function p_trackbar_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_ondblclick#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnDblClickFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_ondblclick#: ' + E.Message);
  end;
end;

function s_trackbar_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_ondblclick$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnDblClickFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_ondblclick$: ' + E.Message);
  end;
end;

function p_trackbar_onenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onenter#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onenter#: ' + E.Message);
  end;
end;

function s_trackbar_onenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onenter$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onenter$: ' + E.Message);
  end;
end;

function p_trackbar_onexit_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onexit#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnExitFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onexit#: ' + E.Message);
  end;
end;

function s_trackbar_onexit_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onexit$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnExitFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onexit$: ' + E.Message);
  end;
end;

function p_trackbar_onkeydown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onkeydown#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnKeyDownFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onkeydown#: ' + E.Message);
  end;
end;

function s_trackbar_onkeydown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onkeydown$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnKeyDownFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onkeydown$: ' + E.Message);
  end;
end;

function p_trackbar_onkeyup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onkeyup#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnKeyUpFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onkeyup#: ' + E.Message);
  end;
end;

function s_trackbar_onkeyup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onkeyup$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnKeyUpFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onkeyup$: ' + E.Message);
  end;
end;

function p_trackbar_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onmousedown#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnMouseDownFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onmousedown#: ' + E.Message);
  end;
end;

function s_trackbar_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onmousedown$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnMouseDownFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onmousedown$: ' + E.Message);
  end;
end;

function p_trackbar_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onmouseup#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnMouseUpFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onmouseup#: ' + E.Message);
  end;
end;

function s_trackbar_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onmouseup$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnMouseUpFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onmouseup$: ' + E.Message);
  end;
end;

function p_trackbar_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onmousemove#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnMouseMoveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onmousemove#: ' + E.Message);
  end;
end;

function s_trackbar_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onmousemove$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnMouseMoveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onmousemove$: ' + E.Message);
  end;
end;

function p_trackbar_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onmouseenter#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnMouseEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onmouseenter#: ' + E.Message);
  end;
end;

function s_trackbar_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onmouseenter$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnMouseEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onmouseenter$: ' + E.Message);
  end;
end;

function p_trackbar_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onmouseleave#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnMouseLeaveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onmouseleave#: ' + E.Message);
  end;
end;

function s_trackbar_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onmouseleave$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnMouseLeaveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onmouseleave$: ' + E.Message);
  end;
end;

function p_trackbar_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onresize#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnResizeFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onresize#: ' + E.Message);
  end;
end;

function s_trackbar_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_onresize$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnResizeFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_onresize$: ' + E.Message);
  end;
end;

// Drag & Drop event callbacks

function p_trackbar_ondragenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_ondragenter#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnDragEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_ondragenter#: ' + E.Message);
  end;
end;

function s_trackbar_ondragenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_ondragenter$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnDragEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_ondragenter$: ' + E.Message);
  end;
end;

function p_trackbar_ondragover_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_ondragover#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnDragOverFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_ondragover#: ' + E.Message);
  end;
end;

function s_trackbar_ondragover_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_ondragover$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnDragOverFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_ondragover$: ' + E.Message);
  end;
end;

function p_trackbar_ondragdrop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_ondragdrop#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnDragDropFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_ondragdrop#: ' + E.Message);
  end;
end;

function s_trackbar_ondragdrop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_ondragdrop$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnDragDropFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_ondragdrop$: ' + E.Message);
  end;
end;

function p_trackbar_ondragleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_ondragleave#') then Exit();

  try
    TBasTrackBar(Args[0].p).OnDragLeaveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_ondragleave#: ' + E.Message);
  end;
end;

function s_trackbar_ondragleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_ondragleave$') then Exit();

  try
    Result.s := TBasTrackBar(Args[0].p).OnDragLeaveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_TRACKBAR, 'trackbar_ondragleave$: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Clear Callbacks Function
// -----------------------------------------------------------------------------

function p_trackbar_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateTrackBar(Args[0].p, 'trackbar_clearcallbacks#') then Exit();

  try
    with TBasTrackBar(Args[0].p) do
    begin
      OnChangeFunc := '';
      OnTrackingFunc := '';
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
      SetError(ERR_OPERATION_FAILED, 'trackbar_clearcallbacks#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Library Registration
// -----------------------------------------------------------------------------

procedure RegisterTrackBarFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_trackbar_error; Lib.Add('trackbar_error@', Fn);
  Fn.Entry := @s_trackbar_errormsg; Lib.Add('trackbar_errormsg$@', Fn);
  Fn.Entry := @s_trackbar_strerror; Lib.Add('trackbar_strerror$@n', Fn);
  Fn.Entry := @n_trackbar_clearerror; Lib.Add('trackbar_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_trackbar_new; Lib.Add('trackbar#@#', Fn);
  Fn.Entry := @p_trackbar_new_pos; Lib.Add('trackbar#@#nnnn', Fn);
  Fn.Entry := @n_trackbar_free; Lib.Add('trackbar_free@#', Fn);

  // Value properties
  Fn.Entry := @n_trackbar_value_get; Lib.Add('trackbar_value@#', Fn);
  Fn.Entry := @p_trackbar_value_set; Lib.Add('trackbar_value#@#n', Fn);
  Fn.Entry := @n_trackbar_min_get; Lib.Add('trackbar_min@#', Fn);
  Fn.Entry := @p_trackbar_min_set; Lib.Add('trackbar_min#@#n', Fn);
  Fn.Entry := @n_trackbar_max_get; Lib.Add('trackbar_max@#', Fn);
  Fn.Entry := @p_trackbar_max_set; Lib.Add('trackbar_max#@#n', Fn);
  Fn.Entry := @n_trackbar_frequency_get; Lib.Add('trackbar_frequency@#', Fn);
  Fn.Entry := @p_trackbar_frequency_set; Lib.Add('trackbar_frequency#@#n', Fn);

  // Orientation
  Fn.Entry := @n_trackbar_orientation_get; Lib.Add('trackbar_orientation@#', Fn);
  Fn.Entry := @p_trackbar_orientation_set; Lib.Add('trackbar_orientation#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_trackbar_x_get; Lib.Add('trackbar_x@#', Fn);
  Fn.Entry := @p_trackbar_x_set; Lib.Add('trackbar_x#@#n', Fn);
  Fn.Entry := @n_trackbar_y_get; Lib.Add('trackbar_y@#', Fn);
  Fn.Entry := @p_trackbar_y_set; Lib.Add('trackbar_y#@#n', Fn);
  Fn.Entry := @n_trackbar_width_get; Lib.Add('trackbar_width@#', Fn);
  Fn.Entry := @p_trackbar_width_set; Lib.Add('trackbar_width#@#n', Fn);
  Fn.Entry := @n_trackbar_height_get; Lib.Add('trackbar_height@#', Fn);
  Fn.Entry := @p_trackbar_height_set; Lib.Add('trackbar_height#@#n', Fn);
  Fn.Entry := @p_trackbar_bounds_set; Lib.Add('trackbar_bounds#@#nnnn', Fn);
  Fn.Entry := @p_trackbar_move_set; Lib.Add('trackbar_move#@#nn', Fn);
  Fn.Entry := @p_trackbar_size_set; Lib.Add('trackbar_size#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_trackbar_align_get; Lib.Add('trackbar_align@#', Fn);
  Fn.Entry := @p_trackbar_align_set; Lib.Add('trackbar_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_trackbar_marginleft_get; Lib.Add('trackbar_marginleft@#', Fn);
  Fn.Entry := @p_trackbar_marginleft_set; Lib.Add('trackbar_marginleft#@#n', Fn);
  Fn.Entry := @n_trackbar_margintop_get; Lib.Add('trackbar_margintop@#', Fn);
  Fn.Entry := @p_trackbar_margintop_set; Lib.Add('trackbar_margintop#@#n', Fn);
  Fn.Entry := @n_trackbar_marginright_get; Lib.Add('trackbar_marginright@#', Fn);
  Fn.Entry := @p_trackbar_marginright_set; Lib.Add('trackbar_marginright#@#n', Fn);
  Fn.Entry := @n_trackbar_marginbottom_get; Lib.Add('trackbar_marginbottom@#', Fn);
  Fn.Entry := @p_trackbar_marginbottom_set; Lib.Add('trackbar_marginbottom#@#n', Fn);
  Fn.Entry := @p_trackbar_margins_set; Lib.Add('trackbar_margins#@#nnnn', Fn);
  Fn.Entry := @p_trackbar_margin_set; Lib.Add('trackbar_margin#@#n', Fn);

  // Visibility and state
  Fn.Entry := @n_trackbar_visible_get; Lib.Add('trackbar_visible@#', Fn);
  Fn.Entry := @p_trackbar_visible_set; Lib.Add('trackbar_visible#@#n', Fn);
  Fn.Entry := @n_trackbar_enabled_get; Lib.Add('trackbar_enabled@#', Fn);
  Fn.Entry := @p_trackbar_enabled_set; Lib.Add('trackbar_enabled#@#n', Fn);
  Fn.Entry := @n_trackbar_opacity_get; Lib.Add('trackbar_opacity@#', Fn);
  Fn.Entry := @p_trackbar_opacity_set; Lib.Add('trackbar_opacity#@#n', Fn);

  // Focus
  Fn.Entry := @n_trackbar_isfocused_get; Lib.Add('trackbar_isfocused@#', Fn);
  Fn.Entry := @p_trackbar_setfocus; Lib.Add('trackbar_setfocus#@#', Fn);
  Fn.Entry := @p_trackbar_resetfocus; Lib.Add('trackbar_resetfocus#@#', Fn);
  Fn.Entry := @n_trackbar_taborder_get; Lib.Add('trackbar_taborder@#', Fn);
  Fn.Entry := @p_trackbar_taborder_set; Lib.Add('trackbar_taborder#@#n', Fn);
  Fn.Entry := @n_trackbar_canfocus_get; Lib.Add('trackbar_canfocus@#', Fn);
  Fn.Entry := @p_trackbar_canfocus_set; Lib.Add('trackbar_canfocus#@#n', Fn);

  // Tag
  Fn.Entry := @n_trackbar_tag_get; Lib.Add('trackbar_tag@#', Fn);
  Fn.Entry := @p_trackbar_tag_set; Lib.Add('trackbar_tag#@#n', Fn);

  // HitTest
  Fn.Entry := @n_trackbar_hittest_get; Lib.Add('trackbar_hittest@#', Fn);
  Fn.Entry := @p_trackbar_hittest_set; Lib.Add('trackbar_hittest#@#n', Fn);

  // DragMode
  Fn.Entry := @n_trackbar_dragmode_get; Lib.Add('trackbar_dragmode@#', Fn);
  Fn.Entry := @p_trackbar_dragmode_set; Lib.Add('trackbar_dragmode#@#n', Fn);

  // Parent
  Fn.Entry := @p_trackbar_parent_get; Lib.Add('trackbar_parent#@#', Fn);
  Fn.Entry := @p_trackbar_parent_set; Lib.Add('trackbar_parent#@##', Fn);
  Fn.Entry := @p_trackbar_bringtofront; Lib.Add('trackbar_bringtofront#@#', Fn);
  Fn.Entry := @p_trackbar_sendtoback; Lib.Add('trackbar_sendtoback#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_trackbar_onchange_set; Lib.Add('trackbar_onchange#@#$', Fn);
  Fn.Entry := @s_trackbar_onchange_get; Lib.Add('trackbar_onchange$@#', Fn);
  Fn.Entry := @p_trackbar_ontracking_set; Lib.Add('trackbar_ontracking#@#$', Fn);
  Fn.Entry := @s_trackbar_ontracking_get; Lib.Add('trackbar_ontracking$@#', Fn);
  Fn.Entry := @p_trackbar_onclick_set; Lib.Add('trackbar_onclick#@#$', Fn);
  Fn.Entry := @s_trackbar_onclick_get; Lib.Add('trackbar_onclick$@#', Fn);
  Fn.Entry := @p_trackbar_ondblclick_set; Lib.Add('trackbar_ondblclick#@#$', Fn);
  Fn.Entry := @s_trackbar_ondblclick_get; Lib.Add('trackbar_ondblclick$@#', Fn);
  Fn.Entry := @p_trackbar_onenter_set; Lib.Add('trackbar_onenter#@#$', Fn);
  Fn.Entry := @s_trackbar_onenter_get; Lib.Add('trackbar_onenter$@#', Fn);
  Fn.Entry := @p_trackbar_onexit_set; Lib.Add('trackbar_onexit#@#$', Fn);
  Fn.Entry := @s_trackbar_onexit_get; Lib.Add('trackbar_onexit$@#', Fn);
  Fn.Entry := @p_trackbar_onkeydown_set; Lib.Add('trackbar_onkeydown#@#$', Fn);
  Fn.Entry := @s_trackbar_onkeydown_get; Lib.Add('trackbar_onkeydown$@#', Fn);
  Fn.Entry := @p_trackbar_onkeyup_set; Lib.Add('trackbar_onkeyup#@#$', Fn);
  Fn.Entry := @s_trackbar_onkeyup_get; Lib.Add('trackbar_onkeyup$@#', Fn);
  Fn.Entry := @p_trackbar_onmousedown_set; Lib.Add('trackbar_onmousedown#@#$', Fn);
  Fn.Entry := @s_trackbar_onmousedown_get; Lib.Add('trackbar_onmousedown$@#', Fn);
  Fn.Entry := @p_trackbar_onmouseup_set; Lib.Add('trackbar_onmouseup#@#$', Fn);
  Fn.Entry := @s_trackbar_onmouseup_get; Lib.Add('trackbar_onmouseup$@#', Fn);
  Fn.Entry := @p_trackbar_onmousemove_set; Lib.Add('trackbar_onmousemove#@#$', Fn);
  Fn.Entry := @s_trackbar_onmousemove_get; Lib.Add('trackbar_onmousemove$@#', Fn);
  Fn.Entry := @p_trackbar_onmouseenter_set; Lib.Add('trackbar_onmouseenter#@#$', Fn);
  Fn.Entry := @s_trackbar_onmouseenter_get; Lib.Add('trackbar_onmouseenter$@#', Fn);
  Fn.Entry := @p_trackbar_onmouseleave_set; Lib.Add('trackbar_onmouseleave#@#$', Fn);
  Fn.Entry := @s_trackbar_onmouseleave_get; Lib.Add('trackbar_onmouseleave$@#', Fn);
  Fn.Entry := @p_trackbar_onresize_set; Lib.Add('trackbar_onresize#@#$', Fn);
  Fn.Entry := @s_trackbar_onresize_get; Lib.Add('trackbar_onresize$@#', Fn);

  // Drag & Drop event callbacks
  Fn.Entry := @p_trackbar_ondragenter_set; Lib.Add('trackbar_ondragenter#@#$', Fn);
  Fn.Entry := @s_trackbar_ondragenter_get; Lib.Add('trackbar_ondragenter$@#', Fn);
  Fn.Entry := @p_trackbar_ondragover_set; Lib.Add('trackbar_ondragover#@#$', Fn);
  Fn.Entry := @s_trackbar_ondragover_get; Lib.Add('trackbar_ondragover$@#', Fn);
  Fn.Entry := @p_trackbar_ondragdrop_set; Lib.Add('trackbar_ondragdrop#@#$', Fn);
  Fn.Entry := @s_trackbar_ondragdrop_get; Lib.Add('trackbar_ondragdrop$@#', Fn);
  Fn.Entry := @p_trackbar_ondragleave_set; Lib.Add('trackbar_ondragleave#@#$', Fn);
  Fn.Entry := @s_trackbar_ondragleave_get; Lib.Add('trackbar_ondragleave$@#', Fn);

  // Clear callbacks
  Fn.Entry := @p_trackbar_clearcallbacks; Lib.Add('trackbar_clearcallbacks#@#', Fn);
end;

end.

