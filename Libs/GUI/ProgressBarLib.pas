unit ProgressBarLib;

{******************************************************************************
  ProgressBarLib - ProgressBar Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TProgressBar wrapper functionality for creating
  and managing progress bar controls in Plan9Basic programs.

  Function Count: 70+ functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All progress bars are created at RUNTIME using TProgressBar.Create with
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
  - ProgressBar creation and lifecycle management
  - Min/Max/Value range control
  - Orientation (horizontal/vertical)
  - Complete positioning and alignment
  - Full event support with BASIC callback integration
  - Drag and drop support

  EVENTS SUPPORT:
  ===============
  - OnClick: ProgressBar was clicked
  - OnDblClick: ProgressBar was double-clicked
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over progress bar
  - OnMouseEnter: Mouse entered progress bar area
  - OnMouseLeave: Mouse left progress bar area
  - OnResize: ProgressBar is being resized
  - OnDragEnter: Drag operation entered progress bar
  - OnDragOver: Drag operation over progress bar (return non-zero to accept)
  - OnDragDrop: Item was dropped on progress bar
  - OnDragLeave: Drag operation left progress bar

  USAGE PATTERN:
  ==============
    let frm# = form#("ProgressBar Demo", 400, 300)

    ' Create a progress bar
    let pb# = progressbar#(frm#)
    progressbar_move#(pb#, 50, 50)
    progressbar_size#(pb#, 300, 20)
    progressbar_min#(pb#, 0)
    progressbar_max#(pb#, 100)
    progressbar_value#(pb#, 50)

    form_show(frm#)

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
  basic, exec, UnitGC, HandleRegistry, ControlCommon;

type
  TBasProgressBar = class(TProgressBar)
  private
    FOnClickFunc: String;
    FOnDblClickFunc: String;
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

    procedure ChoosePresentationName(Sender: TObject; var PresenterName: string);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure DisconnectAllEvents();

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

procedure RegisterProgressBarFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  PROGRESSBAR_GC_TAG = 'BASIC_PROGRESSBAR';
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_PROGRESSBAR = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INDEX_OUT_OF_RANGE = 5;


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

function ValidateProgressBar(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_PROGRESSBAR, FuncName + ': Nil pointer');
    Exit();
  end;

  try
    if not(IsHandleOf(P, TBasProgressBar)) then
    begin
      SetError(ERR_INVALID_PROGRESSBAR, FuncName + ': Invalid object');
      Exit();
    end;
  except
    SetError(ERR_INVALID_PROGRESSBAR, FuncName + ': Invalid pointer');
    Exit();
  end;

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

function ShiftStateToString(Shift: TShiftState): String;
begin
  Result := '';
  if ssShift in Shift then Result := Result + 'S';
  if ssAlt in Shift then Result := Result + 'A';
  if ssCtrl in Shift then Result := Result + 'C';
  if ssCommand in Shift then Result := Result + 'M';
end;

procedure TBasProgressBar.ChoosePresentationName(Sender: TObject; var PresenterName: string);
begin
  PresenterName := 'ProgressBar-style';
end;

// -----------------------------------------------------------------------------
// TBasProgressBar Implementation
// -----------------------------------------------------------------------------

constructor TBasProgressBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);

  OnPresentationNameChoosing := ChoosePresentationName;

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

destructor TBasProgressBar.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasProgressBar.DisconnectAllEvents();
begin
  OnClick := nil;
  OnDblClick := nil;
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

procedure TBasProgressBar.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'ProgressBar');
end;

function TBasProgressBar.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
begin
  Result := ControlCommon.RunCallbackWithResult(FBasicEngine, FConsoleOutput,
                          FuncSignature, Args, 'ProgressBar');
end;

// Event setters with granular connection/disconnection

procedure TBasProgressBar.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    OnClick := InternalOnClick
  else
    OnClick := nil;
end;

procedure TBasProgressBar.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    OnDblClick := InternalOnDblClick
  else
    OnDblClick := nil;
end;

procedure TBasProgressBar.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    OnMouseDown := InternalOnMouseDown
  else
    OnMouseDown := nil;
end;

procedure TBasProgressBar.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    OnMouseUp := InternalOnMouseUp
  else
    OnMouseUp := nil;
end;

procedure TBasProgressBar.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    OnMouseMove := InternalOnMouseMove
  else
    OnMouseMove := nil;
end;

procedure TBasProgressBar.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    OnMouseEnter := InternalOnMouseEnter
  else
    OnMouseEnter := nil;
end;

procedure TBasProgressBar.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    OnMouseLeave := InternalOnMouseLeave
  else
    OnMouseLeave := nil;
end;

procedure TBasProgressBar.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    OnResize := InternalOnResize
  else
    OnResize := nil;
end;

procedure TBasProgressBar.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    OnDragEnter := InternalOnDragEnter
  else
    OnDragEnter := nil;
end;

procedure TBasProgressBar.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    OnDragOver := InternalOnDragOver
  else
    OnDragOver := nil;
end;

procedure TBasProgressBar.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    OnDragDrop := InternalOnDragDrop
  else
    OnDragDrop := nil;
end;

procedure TBasProgressBar.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    OnDragLeave := InternalOnDragLeave
  else
    OnDragLeave := nil;
end;

// Internal event handlers

procedure TBasProgressBar.InternalOnClick(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnClickFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Pointer(Self);
  SenderArg.s := '';

  ExecuteCallback(FOnClickFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasProgressBar.InternalOnDblClick(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnDblClickFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Pointer(Self);
  SenderArg.s := '';

  ExecuteCallback(FOnDblClickFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasProgressBar.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseDownFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Pointer(Self); Args[0].s := '';
  Args[1].n := MouseButtonToInt(Button); Args[1].p := nil; Args[1].s := '';
  Args[2].n := 0; Args[2].p := nil; Args[2].s := ShiftStateToString(Shift);
  Args[3].n := X; Args[3].p := nil; Args[3].s := '';
  Args[4].n := Y; Args[4].p := nil; Args[4].s := '';

  ExecuteCallback(FOnMouseDownFunc.ToLower() + '@#n$nn', Args);
end;

procedure TBasProgressBar.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseUpFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Pointer(Self); Args[0].s := '';
  Args[1].n := MouseButtonToInt(Button); Args[1].p := nil; Args[1].s := '';
  Args[2].n := 0; Args[2].p := nil; Args[2].s := ShiftStateToString(Shift);
  Args[3].n := X; Args[3].p := nil; Args[3].s := '';
  Args[4].n := Y; Args[4].p := nil; Args[4].s := '';

  ExecuteCallback(FOnMouseUpFunc.ToLower() + '@#n$nn', Args);
end;

procedure TBasProgressBar.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnMouseMoveFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Pointer(Self); Args[0].s := '';
  Args[1].n := 0; Args[1].p := nil; Args[1].s := ShiftStateToString(Shift);
  Args[2].n := X; Args[2].p := nil; Args[2].s := '';
  Args[3].n := Y; Args[3].p := nil; Args[3].s := '';

  ExecuteCallback(FOnMouseMoveFunc.ToLower() + '@#$nn', Args);
end;

procedure TBasProgressBar.InternalOnMouseEnter(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnMouseEnterFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Pointer(Self);
  SenderArg.s := '';

  ExecuteCallback(FOnMouseEnterFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasProgressBar.InternalOnMouseLeave(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnMouseLeaveFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Pointer(Self);
  SenderArg.s := '';

  ExecuteCallback(FOnMouseLeaveFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasProgressBar.InternalOnResize(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnResizeFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Pointer(Self);
  SenderArg.s := '';

  ExecuteCallback(FOnResizeFunc.ToLower() + '@#', [SenderArg]);
end;

procedure TBasProgressBar.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragEnterFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Pointer(Self); Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';

  ExecuteCallback(FOnDragEnterFunc.ToLower() + '@#nn', Args);
end;

procedure TBasProgressBar.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
var
  Args: array[0..2] of TAsmData;
  Ret: TAsmData;
begin
  if FOnDragOverFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Pointer(Self); Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';

  Ret := ExecuteCallbackWithResult(FOnDragOverFunc + '@#nn', Args);

  if Ret.n <> 0 then
    Operation := TDragOperation.Move
  else
    Operation := TDragOperation.None;
end;

procedure TBasProgressBar.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragDropFunc = '' then Exit();

  Args[0].n := 0; Args[0].p := Pointer(Self); Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';

  ExecuteCallback(FOnDragDropFunc.ToLower() + '@#nn', Args);
end;

procedure TBasProgressBar.InternalOnDragLeave(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnDragLeaveFunc = '' then Exit();

  SenderArg.n := 0;
  SenderArg.p := Pointer(Self);
  SenderArg.s := '';

  ExecuteCallback(FOnDragLeaveFunc.ToLower() + '@#', [SenderArg]);
end;

// -----------------------------------------------------------------------------
// Error Handling Functions
// -----------------------------------------------------------------------------

function n_progressbar_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

function s_progressbar_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

function s_progressbar_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);

  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_PROGRESSBAR: Result.s := 'Invalid progress bar';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Creation failed';
    ERR_INDEX_OUT_OF_RANGE: Result.s := 'Index out of range';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_progressbar_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

// -----------------------------------------------------------------------------
// Creation/Destruction Functions
// -----------------------------------------------------------------------------

function p_progressbar_new(var Args: array of TAsmData): TAsmData;
var
  pb: TBasProgressBar;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'progressbar#') then Exit();

  try
    pb := TBasProgressBar.Create(nil);
    pb.BasicEngine := ModuleEngine;
    pb.ConsoleOutput := ModuleOutput;

    if TObject(Args[0].p) is TCommonCustomForm then
      pb.Parent := TCommonCustomForm(Args[0].p)
    else
    begin
      ParentObj := TFmxObject(Args[0].p);
      pb.Parent := ParentObj;
    end;

    Result.p := Pointer(pb);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(pb, PROGRESSBAR_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'progressbar#: ' + E.Message);
  end;
end;

function p_progressbar_new_pos(var Args: array of TAsmData): TAsmData;
var
  pb: TBasProgressBar;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'progressbar#') then Exit();

  try
    pb := TBasProgressBar.Create(nil);
    pb.BasicEngine := ModuleEngine;
    pb.ConsoleOutput := ModuleOutput;

    if TObject(Args[0].p) is TCommonCustomForm then
      pb.Parent := TCommonCustomForm(Args[0].p)
    else
    begin
      ParentObj := TFmxObject(Args[0].p);
      pb.Parent := ParentObj;
    end;

    pb.Position.X := Args[1].n;
    pb.Position.Y := Args[2].n;
    pb.Width := Args[3].n;
    pb.Height := Args[4].n;

    Result.p := Pointer(pb);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(pb, PROGRESSBAR_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'progressbar#: ' + E.Message);
  end;
end;

function n_progressbar_free(var Args: array of TAsmData): TAsmData;
var
  pb: TBasProgressBar;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_free') then
    Exit();

  try
    pb := TBasProgressBar(Args[0].p);
    pb.DisconnectAllEvents();
    pb.Free();

    // Use GC to properly free the control
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(PROGRESSBAR_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_free: ' + E.Message);
    end;
  end;
end;

// -----------------------------------------------------------------------------
// Value Properties
// -----------------------------------------------------------------------------

function n_progressbar_value_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_value') then Exit();

  try
    Result.n := TBasProgressBar(Args[0].p).Value;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_value: ' + E.Message);
  end;
end;

function p_progressbar_value_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_value#') then Exit();

  try
    TBasProgressBar(Args[0].p).Value := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_value#: ' + E.Message);
  end;
end;

function n_progressbar_min_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_min') then Exit();

  try
    Result.n := TBasProgressBar(Args[0].p).Min;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_min: ' + E.Message);
  end;
end;

function p_progressbar_min_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_min#') then Exit();

  try
    TBasProgressBar(Args[0].p).Min := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_min#: ' + E.Message);
  end;
end;

function n_progressbar_max_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_max') then Exit();

  try
    Result.n := TBasProgressBar(Args[0].p).Max;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_max: ' + E.Message);
  end;
end;

function p_progressbar_max_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_max#') then Exit();

  try
    TBasProgressBar(Args[0].p).Max := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_max#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Orientation
// -----------------------------------------------------------------------------

function n_progressbar_orientation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_orientation') then Exit();

  try
    if TBasProgressBar(Args[0].p).Orientation = TOrientation.Horizontal then
      Result.n := ORIENTATION_HORIZONTAL
    else
      Result.n := ORIENTATION_VERTICAL;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_orientation: ' + E.Message);
  end;
end;

function p_progressbar_orientation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_orientation#') then Exit();

  try
    if Trunc(Args[1].n) = ORIENTATION_VERTICAL then
      TBasProgressBar(Args[0].p).Orientation := TOrientation.Vertical
    else
      TBasProgressBar(Args[0].p).Orientation := TOrientation.Horizontal;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_orientation#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Position and Size
// -----------------------------------------------------------------------------

function n_progressbar_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_x') then Exit();

  try
    Result.n := TBasProgressBar(Args[0].p).Position.X;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_x: ' + E.Message);
  end;
end;

function p_progressbar_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_x#') then Exit();

  try
    TBasProgressBar(Args[0].p).Position.X := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_x#: ' + E.Message);
  end;
end;

function n_progressbar_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_y') then Exit();

  try
    Result.n := TBasProgressBar(Args[0].p).Position.Y;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_y: ' + E.Message);
  end;
end;

function p_progressbar_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_y#') then Exit();

  try
    TBasProgressBar(Args[0].p).Position.Y := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_y#: ' + E.Message);
  end;
end;

function n_progressbar_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_width') then Exit();

  try
    Result.n := TBasProgressBar(Args[0].p).Width;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_width: ' + E.Message);
  end;
end;

function p_progressbar_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_width#') then Exit();

  try
    TBasProgressBar(Args[0].p).Width := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_width#: ' + E.Message);
  end;
end;

function n_progressbar_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_height') then Exit();

  try
    Result.n := TBasProgressBar(Args[0].p).Height;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_height: ' + E.Message);
  end;
end;

function p_progressbar_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_height#') then Exit();

  try
    TBasProgressBar(Args[0].p).Height := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_height#: ' + E.Message);
  end;
end;

function p_progressbar_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_bounds#') then Exit();

  try
    TBasProgressBar(Args[0].p).SetBounds(Args[1].n, Args[2].n, Args[3].n, Args[4].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_bounds#: ' + E.Message);
  end;
end;

function p_progressbar_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_move#') then Exit();

  try
    TBasProgressBar(Args[0].p).Position.X := Args[1].n;
    TBasProgressBar(Args[0].p).Position.Y := Args[2].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_move#: ' + E.Message);
  end;
end;

function p_progressbar_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_size#') then Exit();

  try
    TBasProgressBar(Args[0].p).Width := Args[1].n;
    TBasProgressBar(Args[0].p).Height := Args[2].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_size#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Alignment
// -----------------------------------------------------------------------------

function n_progressbar_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_align') then Exit();

  try
    Result.n := AlignToInt(TBasProgressBar(Args[0].p).Align);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_align: ' + E.Message);
  end;
end;

function p_progressbar_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_align#') then Exit();

  try
    TBasProgressBar(Args[0].p).Align := AlignFromInt(Trunc(Args[1].n));
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_align#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Margins
// -----------------------------------------------------------------------------

function n_progressbar_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_marginleft') then Exit();

  try
    Result.n := TBasProgressBar(Args[0].p).Margins.Left;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_marginleft: ' + E.Message);
  end;
end;

function p_progressbar_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_marginleft#') then Exit();

  try
    TBasProgressBar(Args[0].p).Margins.Left := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_marginleft#: ' + E.Message);
  end;
end;

function n_progressbar_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_margintop') then Exit();

  try
    Result.n := TBasProgressBar(Args[0].p).Margins.Top;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_margintop: ' + E.Message);
  end;
end;

function p_progressbar_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_margintop#') then Exit();

  try
    TBasProgressBar(Args[0].p).Margins.Top := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_margintop#: ' + E.Message);
  end;
end;

function n_progressbar_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_marginright') then Exit();

  try
    Result.n := TBasProgressBar(Args[0].p).Margins.Right;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_marginright: ' + E.Message);
  end;
end;

function p_progressbar_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_marginright#') then Exit();

  try
    TBasProgressBar(Args[0].p).Margins.Right := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_marginright#: ' + E.Message);
  end;
end;

function n_progressbar_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_marginbottom') then Exit();

  try
    Result.n := TBasProgressBar(Args[0].p).Margins.Bottom;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_marginbottom: ' + E.Message);
  end;
end;

function p_progressbar_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_marginbottom#') then Exit();

  try
    TBasProgressBar(Args[0].p).Margins.Bottom := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_marginbottom#: ' + E.Message);
  end;
end;

function p_progressbar_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_margins#') then Exit();

  try
    TBasProgressBar(Args[0].p).Margins.Left := Args[1].n;
    TBasProgressBar(Args[0].p).Margins.Top := Args[2].n;
    TBasProgressBar(Args[0].p).Margins.Right := Args[3].n;
    TBasProgressBar(Args[0].p).Margins.Bottom := Args[4].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_margins#: ' + E.Message);
  end;
end;

function p_progressbar_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_margin#') then Exit();

  try
    TBasProgressBar(Args[0].p).Margins.Left := Args[1].n;
    TBasProgressBar(Args[0].p).Margins.Top := Args[1].n;
    TBasProgressBar(Args[0].p).Margins.Right := Args[1].n;
    TBasProgressBar(Args[0].p).Margins.Bottom := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_margin#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Visibility and State
// -----------------------------------------------------------------------------

function n_progressbar_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_visible') then Exit();

  try
    if TBasProgressBar(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_visible: ' + E.Message);
  end;
end;

function p_progressbar_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_visible#') then Exit();

  try
    TBasProgressBar(Args[0].p).Visible := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_visible#: ' + E.Message);
  end;
end;

function n_progressbar_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_enabled') then Exit();

  try
    if TBasProgressBar(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_enabled: ' + E.Message);
  end;
end;

function p_progressbar_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_enabled#') then Exit();

  try
    TBasProgressBar(Args[0].p).Enabled := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_enabled#: ' + E.Message);
  end;
end;

function n_progressbar_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_opacity') then Exit();

  try
    Result.n := TBasProgressBar(Args[0].p).Opacity;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_opacity: ' + E.Message);
  end;
end;

function p_progressbar_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_opacity#') then Exit();

  try
    TBasProgressBar(Args[0].p).Opacity := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_opacity#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Tag
// -----------------------------------------------------------------------------

function n_progressbar_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_tag') then Exit();

  try
    Result.n := TBasProgressBar(Args[0].p).Tag;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_tag: ' + E.Message);
  end;
end;

function p_progressbar_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_tag#') then Exit();

  try
    TBasProgressBar(Args[0].p).Tag := Trunc(Args[1].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_tag#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// HitTest
// -----------------------------------------------------------------------------

function n_progressbar_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_hittest') then Exit();

  try
    if TBasProgressBar(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_hittest: ' + E.Message);
  end;
end;

function p_progressbar_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_hittest#') then Exit();

  try
    TBasProgressBar(Args[0].p).HitTest := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_hittest#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// DragMode
// -----------------------------------------------------------------------------

function n_progressbar_dragmode_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_dragmode') then Exit();

  try
    if TBasProgressBar(Args[0].p).DragMode = TDragMode.dmAutomatic then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_dragmode: ' + E.Message);
  end;
end;

function p_progressbar_dragmode_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_dragmode#') then Exit();

  try
    if Args[1].n <> 0 then
      TBasProgressBar(Args[0].p).DragMode := TDragMode.dmAutomatic
    else
      TBasProgressBar(Args[0].p).DragMode := TDragMode.dmManual;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_dragmode#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Parent
// -----------------------------------------------------------------------------

function p_progressbar_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_parent#') then Exit();

  try
    Result.p := TBasProgressBar(Args[0].p).Parent;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_parent#: ' + E.Message);
  end;
end;

function p_progressbar_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_parent#') then Exit();
  if not ValidateParent(Args[1].p, 'progressbar_parent#') then Exit();

  try
    if TObject(Args[1].p) is TCommonCustomForm then
      TBasProgressBar(Args[0].p).Parent := TCommonCustomForm(Args[1].p)
    else
      TBasProgressBar(Args[0].p).Parent := TFmxObject(Args[1].p);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_parent#: ' + E.Message);
  end;
end;

function p_progressbar_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_bringtofront#') then Exit();

  try
    TBasProgressBar(Args[0].p).BringToFront();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_bringtofront#: ' + E.Message);
  end;
end;

function p_progressbar_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_sendtoback#') then Exit();

  try
    TBasProgressBar(Args[0].p).SendToBack();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_sendtoback#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Event Callbacks
// -----------------------------------------------------------------------------

function p_progressbar_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onclick#') then Exit();

  try
    TBasProgressBar(Args[0].p).OnClickFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onclick#: ' + E.Message);
  end;
end;

function s_progressbar_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onclick$') then Exit();

  try
    Result.s := TBasProgressBar(Args[0].p).OnClickFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onclick$: ' + E.Message);
  end;
end;

function p_progressbar_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_ondblclick#') then Exit();

  try
    TBasProgressBar(Args[0].p).OnDblClickFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_ondblclick#: ' + E.Message);
  end;
end;

function s_progressbar_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_ondblclick$') then Exit();

  try
    Result.s := TBasProgressBar(Args[0].p).OnDblClickFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_ondblclick$: ' + E.Message);
  end;
end;

function p_progressbar_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onmousedown#') then Exit();

  try
    TBasProgressBar(Args[0].p).OnMouseDownFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onmousedown#: ' + E.Message);
  end;
end;

function s_progressbar_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onmousedown$') then Exit();

  try
    Result.s := TBasProgressBar(Args[0].p).OnMouseDownFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onmousedown$: ' + E.Message);
  end;
end;

function p_progressbar_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onmouseup#') then Exit();

  try
    TBasProgressBar(Args[0].p).OnMouseUpFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onmouseup#: ' + E.Message);
  end;
end;

function s_progressbar_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onmouseup$') then Exit();

  try
    Result.s := TBasProgressBar(Args[0].p).OnMouseUpFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onmouseup$: ' + E.Message);
  end;
end;

function p_progressbar_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onmousemove#') then Exit();

  try
    TBasProgressBar(Args[0].p).OnMouseMoveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onmousemove#: ' + E.Message);
  end;
end;

function s_progressbar_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onmousemove$') then Exit();

  try
    Result.s := TBasProgressBar(Args[0].p).OnMouseMoveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onmousemove$: ' + E.Message);
  end;
end;

function p_progressbar_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onmouseenter#') then Exit();

  try
    TBasProgressBar(Args[0].p).OnMouseEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onmouseenter#: ' + E.Message);
  end;
end;

function s_progressbar_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onmouseenter$') then Exit();

  try
    Result.s := TBasProgressBar(Args[0].p).OnMouseEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onmouseenter$: ' + E.Message);
  end;
end;

function p_progressbar_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onmouseleave#') then Exit();

  try
    TBasProgressBar(Args[0].p).OnMouseLeaveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onmouseleave#: ' + E.Message);
  end;
end;

function s_progressbar_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onmouseleave$') then Exit();

  try
    Result.s := TBasProgressBar(Args[0].p).OnMouseLeaveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onmouseleave$: ' + E.Message);
  end;
end;

function p_progressbar_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onresize#') then Exit();

  try
    TBasProgressBar(Args[0].p).OnResizeFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onresize#: ' + E.Message);
  end;
end;

function s_progressbar_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_onresize$') then Exit();

  try
    Result.s := TBasProgressBar(Args[0].p).OnResizeFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_onresize$: ' + E.Message);
  end;
end;

// Drag & Drop event callbacks

function p_progressbar_ondragenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_ondragenter#') then Exit();

  try
    TBasProgressBar(Args[0].p).OnDragEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_ondragenter#: ' + E.Message);
  end;
end;

function s_progressbar_ondragenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_ondragenter$') then Exit();

  try
    Result.s := TBasProgressBar(Args[0].p).OnDragEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_ondragenter$: ' + E.Message);
  end;
end;

function p_progressbar_ondragover_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_ondragover#') then Exit();

  try
    TBasProgressBar(Args[0].p).OnDragOverFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_ondragover#: ' + E.Message);
  end;
end;

function s_progressbar_ondragover_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_ondragover$') then Exit();

  try
    Result.s := TBasProgressBar(Args[0].p).OnDragOverFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_ondragover$: ' + E.Message);
  end;
end;

function p_progressbar_ondragdrop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_ondragdrop#') then Exit();

  try
    TBasProgressBar(Args[0].p).OnDragDropFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_ondragdrop#: ' + E.Message);
  end;
end;

function s_progressbar_ondragdrop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_ondragdrop$') then Exit();

  try
    Result.s := TBasProgressBar(Args[0].p).OnDragDropFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_ondragdrop$: ' + E.Message);
  end;
end;

function p_progressbar_ondragleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_ondragleave#') then Exit();

  try
    TBasProgressBar(Args[0].p).OnDragLeaveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_ondragleave#: ' + E.Message);
  end;
end;

function s_progressbar_ondragleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_ondragleave$') then Exit();

  try
    Result.s := TBasProgressBar(Args[0].p).OnDragLeaveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROGRESSBAR, 'progressbar_ondragleave$: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Clear Callbacks Function
// -----------------------------------------------------------------------------

function p_progressbar_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateProgressBar(Args[0].p, 'progressbar_clearcallbacks#') then Exit();

  try
    with TBasProgressBar(Args[0].p) do
    begin
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
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'progressbar_clearcallbacks#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Library Registration
// -----------------------------------------------------------------------------

procedure RegisterProgressBarFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_progressbar_error; Lib.Add('progressbar_error@', Fn);
  Fn.Entry := @s_progressbar_errormsg; Lib.Add('progressbar_errormsg$@', Fn);
  Fn.Entry := @s_progressbar_strerror; Lib.Add('progressbar_strerror$@n', Fn);
  Fn.Entry := @n_progressbar_clearerror; Lib.Add('progressbar_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_progressbar_new; Lib.Add('progressbar#@#', Fn);
  Fn.Entry := @p_progressbar_new_pos; Lib.Add('progressbar#@#nnnn', Fn);
  Fn.Entry := @n_progressbar_free; Lib.Add('progressbar_free@#', Fn);

  // Value properties
  Fn.Entry := @n_progressbar_value_get; Lib.Add('progressbar_value@#', Fn);
  Fn.Entry := @p_progressbar_value_set; Lib.Add('progressbar_value#@#n', Fn);
  Fn.Entry := @n_progressbar_min_get; Lib.Add('progressbar_min@#', Fn);
  Fn.Entry := @p_progressbar_min_set; Lib.Add('progressbar_min#@#n', Fn);
  Fn.Entry := @n_progressbar_max_get; Lib.Add('progressbar_max@#', Fn);
  Fn.Entry := @p_progressbar_max_set; Lib.Add('progressbar_max#@#n', Fn);

  // Orientation
  Fn.Entry := @n_progressbar_orientation_get; Lib.Add('progressbar_orientation@#', Fn);
  Fn.Entry := @p_progressbar_orientation_set; Lib.Add('progressbar_orientation#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_progressbar_x_get; Lib.Add('progressbar_x@#', Fn);
  Fn.Entry := @p_progressbar_x_set; Lib.Add('progressbar_x#@#n', Fn);
  Fn.Entry := @n_progressbar_y_get; Lib.Add('progressbar_y@#', Fn);
  Fn.Entry := @p_progressbar_y_set; Lib.Add('progressbar_y#@#n', Fn);
  Fn.Entry := @n_progressbar_width_get; Lib.Add('progressbar_width@#', Fn);
  Fn.Entry := @p_progressbar_width_set; Lib.Add('progressbar_width#@#n', Fn);
  Fn.Entry := @n_progressbar_height_get; Lib.Add('progressbar_height@#', Fn);
  Fn.Entry := @p_progressbar_height_set; Lib.Add('progressbar_height#@#n', Fn);
  Fn.Entry := @p_progressbar_bounds_set; Lib.Add('progressbar_bounds#@#nnnn', Fn);
  Fn.Entry := @p_progressbar_move_set; Lib.Add('progressbar_move#@#nn', Fn);
  Fn.Entry := @p_progressbar_size_set; Lib.Add('progressbar_size#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_progressbar_align_get; Lib.Add('progressbar_align@#', Fn);
  Fn.Entry := @p_progressbar_align_set; Lib.Add('progressbar_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_progressbar_marginleft_get; Lib.Add('progressbar_marginleft@#', Fn);
  Fn.Entry := @p_progressbar_marginleft_set; Lib.Add('progressbar_marginleft#@#n', Fn);
  Fn.Entry := @n_progressbar_margintop_get; Lib.Add('progressbar_margintop@#', Fn);
  Fn.Entry := @p_progressbar_margintop_set; Lib.Add('progressbar_margintop#@#n', Fn);
  Fn.Entry := @n_progressbar_marginright_get; Lib.Add('progressbar_marginright@#', Fn);
  Fn.Entry := @p_progressbar_marginright_set; Lib.Add('progressbar_marginright#@#n', Fn);
  Fn.Entry := @n_progressbar_marginbottom_get; Lib.Add('progressbar_marginbottom@#', Fn);
  Fn.Entry := @p_progressbar_marginbottom_set; Lib.Add('progressbar_marginbottom#@#n', Fn);
  Fn.Entry := @p_progressbar_margins_set; Lib.Add('progressbar_margins#@#nnnn', Fn);
  Fn.Entry := @p_progressbar_margin_set; Lib.Add('progressbar_margin#@#n', Fn);

  // Visibility and state
  Fn.Entry := @n_progressbar_visible_get; Lib.Add('progressbar_visible@#', Fn);
  Fn.Entry := @p_progressbar_visible_set; Lib.Add('progressbar_visible#@#n', Fn);
  Fn.Entry := @n_progressbar_enabled_get; Lib.Add('progressbar_enabled@#', Fn);
  Fn.Entry := @p_progressbar_enabled_set; Lib.Add('progressbar_enabled#@#n', Fn);
  Fn.Entry := @n_progressbar_opacity_get; Lib.Add('progressbar_opacity@#', Fn);
  Fn.Entry := @p_progressbar_opacity_set; Lib.Add('progressbar_opacity#@#n', Fn);

  // Tag
  Fn.Entry := @n_progressbar_tag_get; Lib.Add('progressbar_tag@#', Fn);
  Fn.Entry := @p_progressbar_tag_set; Lib.Add('progressbar_tag#@#n', Fn);

  // HitTest
  Fn.Entry := @n_progressbar_hittest_get; Lib.Add('progressbar_hittest@#', Fn);
  Fn.Entry := @p_progressbar_hittest_set; Lib.Add('progressbar_hittest#@#n', Fn);

  // DragMode
  Fn.Entry := @n_progressbar_dragmode_get; Lib.Add('progressbar_dragmode@#', Fn);
  Fn.Entry := @p_progressbar_dragmode_set; Lib.Add('progressbar_dragmode#@#n', Fn);

  // Parent
  Fn.Entry := @p_progressbar_parent_get; Lib.Add('progressbar_parent#@#', Fn);
  Fn.Entry := @p_progressbar_parent_set; Lib.Add('progressbar_parent#@##', Fn);
  Fn.Entry := @p_progressbar_bringtofront; Lib.Add('progressbar_bringtofront#@#', Fn);
  Fn.Entry := @p_progressbar_sendtoback; Lib.Add('progressbar_sendtoback#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_progressbar_onclick_set; Lib.Add('progressbar_onclick#@#$', Fn);
  Fn.Entry := @s_progressbar_onclick_get; Lib.Add('progressbar_onclick$@#', Fn);
  Fn.Entry := @p_progressbar_ondblclick_set; Lib.Add('progressbar_ondblclick#@#$', Fn);
  Fn.Entry := @s_progressbar_ondblclick_get; Lib.Add('progressbar_ondblclick$@#', Fn);
  Fn.Entry := @p_progressbar_onmousedown_set; Lib.Add('progressbar_onmousedown#@#$', Fn);
  Fn.Entry := @s_progressbar_onmousedown_get; Lib.Add('progressbar_onmousedown$@#', Fn);
  Fn.Entry := @p_progressbar_onmouseup_set; Lib.Add('progressbar_onmouseup#@#$', Fn);
  Fn.Entry := @s_progressbar_onmouseup_get; Lib.Add('progressbar_onmouseup$@#', Fn);
  Fn.Entry := @p_progressbar_onmousemove_set; Lib.Add('progressbar_onmousemove#@#$', Fn);
  Fn.Entry := @s_progressbar_onmousemove_get; Lib.Add('progressbar_onmousemove$@#', Fn);
  Fn.Entry := @p_progressbar_onmouseenter_set; Lib.Add('progressbar_onmouseenter#@#$', Fn);
  Fn.Entry := @s_progressbar_onmouseenter_get; Lib.Add('progressbar_onmouseenter$@#', Fn);
  Fn.Entry := @p_progressbar_onmouseleave_set; Lib.Add('progressbar_onmouseleave#@#$', Fn);
  Fn.Entry := @s_progressbar_onmouseleave_get; Lib.Add('progressbar_onmouseleave$@#', Fn);
  Fn.Entry := @p_progressbar_onresize_set; Lib.Add('progressbar_onresize#@#$', Fn);
  Fn.Entry := @s_progressbar_onresize_get; Lib.Add('progressbar_onresize$@#', Fn);

  // Drag & Drop event callbacks
  Fn.Entry := @p_progressbar_ondragenter_set; Lib.Add('progressbar_ondragenter#@#$', Fn);
  Fn.Entry := @s_progressbar_ondragenter_get; Lib.Add('progressbar_ondragenter$@#', Fn);
  Fn.Entry := @p_progressbar_ondragover_set; Lib.Add('progressbar_ondragover#@#$', Fn);
  Fn.Entry := @s_progressbar_ondragover_get; Lib.Add('progressbar_ondragover$@#', Fn);
  Fn.Entry := @p_progressbar_ondragdrop_set; Lib.Add('progressbar_ondragdrop#@#$', Fn);
  Fn.Entry := @s_progressbar_ondragdrop_get; Lib.Add('progressbar_ondragdrop$@#', Fn);
  Fn.Entry := @p_progressbar_ondragleave_set; Lib.Add('progressbar_ondragleave#@#$', Fn);
  Fn.Entry := @s_progressbar_ondragleave_get; Lib.Add('progressbar_ondragleave$@#', Fn);

  // Clear callbacks
  Fn.Entry := @p_progressbar_clearcallbacks; Lib.Add('progressbar_clearcallbacks#@#', Fn);
end;

end.

