unit SwitchLib;

{******************************************************************************
  SwitchLib - Switch Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TSwitch wrapper functionality for creating
  and managing toggle switch controls in Plan9Basic programs.

  Function Count: 90+ functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All switches are created at RUNTIME using TSwitch.Create with dynamic
  parent assignment. This ensures proper dynamic creation across all platforms.

  EVENT CONNECTION MODEL:
  =======================
  Events are connected/disconnected individually when callbacks are set:
  - Setting a non-empty callback name connects ONLY that specific event
  - Setting an empty callback name ("") disconnects ONLY that specific event
  - No events are connected by default in the constructor

  FEATURES:
  =========
  - Switch creation and lifecycle management
  - IsChecked state control (on/off)
  - Complete positioning and alignment
  - Full event support with BASIC callback integration
  - Drag and drop support

  EVENTS SUPPORT:
  ===============
  - OnSwitch: Switch state changed (primary switch event)
  - OnClick: Switch was clicked
  - OnDblClick: Switch was double-clicked
  - OnEnter: Switch received focus
  - OnExit: Switch lost focus
  - OnKeyDown: Key was pressed while focused
  - OnKeyUp: Key was released while focused
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over switch
  - OnMouseEnter: Mouse entered switch area
  - OnMouseLeave: Mouse left switch area
  - OnResize: Switch is being resized
  - OnDragEnter: Drag operation entered switch
  - OnDragOver: Drag operation over switch (return non-zero to accept)
  - OnDragDrop: Item was dropped on switch
  - OnDragLeave: Drag operation left switch

  USAGE PATTERN:
  ==============
    let frm# = form#("Switch Demo", 400, 300)

    ' Create a switch
    let sw# = switch#(frm#)
    switch_move#(sw#, 50, 50)
    switch_onswitch#(sw#, "OnSwitchChanged")

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnSwitchChanged(sender#) local ison
      ison = switch_ischecked(sender#)
      if ison = 1 then
        println "Switch is ON"
      else
        println "Switch is OFF"
      endif
    endfunction

    function OnSwitchKeyDown(sender#, key, keychar$, shift$)
      println "Key pressed: " + str$(key)
    endfunction

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
  TBasSwitch = class(TSwitch)
  private
    FOnSwitchFunc: String;
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

    procedure InternalOnSwitch(Sender: TObject);
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

    procedure SetOnSwitchFunc(const Value: String);
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

    (*
    Source - https://stackoverflow.com/a/35069961
    Posted by Tom Brunberg
    Retrieved 2026-01-10, License - CC BY-SA 3.0
    *)
    procedure ChoosePresentationName(Sender: TObject; var PresenterName: string);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure DisconnectAllEvents();

    property OnSwitchFunc: String read FOnSwitchFunc write SetOnSwitchFunc;
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

procedure RegisterSwitchFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  SWITCH_GC_TAG = 'BASIC_SWITCH';
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_SWITCH = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INDEX_OUT_OF_RANGE = 5;


var
  lastError: Integer;
  lastErrorMsg: String;

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

function ValidateSwitch(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_SWITCH, FuncName + ': Nil pointer');
    Exit();
  end;

  try
    if not(IsHandleOf(P, TBasSwitch)) then
    begin
      SetError(ERR_INVALID_SWITCH, FuncName + ': Invalid object');
      Exit();
    end;
  except
    SetError(ERR_INVALID_SWITCH, FuncName + ': Invalid pointer');
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

procedure TBasSwitch.ChoosePresentationName(Sender: TObject; var PresenterName: string);
begin
  PresenterName := 'Switch-style';
end;

// -----------------------------------------------------------------------------
// TBasSwitch Implementation
// -----------------------------------------------------------------------------

constructor TBasSwitch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);

  OnPresentationNameChoosing := ChoosePresentationName;

  FOnSwitchFunc := '';
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
  // Use all inherited defaults - no additional property modifications
end;

destructor TBasSwitch.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasSwitch.DisconnectAllEvents();
begin
  OnSwitch := nil;
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

procedure TBasSwitch.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'Switch');
end;

function TBasSwitch.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
begin
  Result := ControlCommon.RunCallbackWithResult(FBasicEngine, FConsoleOutput,
                          FuncSignature, Args, 'Switch');
end;

// Event Setters - Connect/Disconnect events granularly

procedure TBasSwitch.SetOnSwitchFunc(const Value: String);
begin
  FOnSwitchFunc := Value;
  if Value <> '' then
    OnSwitch := InternalOnSwitch
  else
    OnSwitch := nil;
end;

procedure TBasSwitch.SetOnClickFunc(const Value: String);
begin
  ControlCommon.BindClick(Self, Value, FOnClickFunc, InternalOnClick);
end;

procedure TBasSwitch.SetOnDblClickFunc(const Value: String);
begin
  ControlCommon.BindDblClick(Self, Value, FOnDblClickFunc, InternalOnDblClick);
end;

procedure TBasSwitch.SetOnEnterFunc(const Value: String);
begin
  ControlCommon.BindEnter(Self, Value, FOnEnterFunc, InternalOnEnter);
end;

procedure TBasSwitch.SetOnExitFunc(const Value: String);
begin
  ControlCommon.BindExit(Self, Value, FOnExitFunc, InternalOnExit);
end;

procedure TBasSwitch.SetOnKeyDownFunc(const Value: String);
begin
  ControlCommon.BindKeyDown(Self, Value, FOnKeyDownFunc, InternalOnKeyDown);
end;

procedure TBasSwitch.SetOnKeyUpFunc(const Value: String);
begin
  ControlCommon.BindKeyUp(Self, Value, FOnKeyUpFunc, InternalOnKeyUp);
end;

procedure TBasSwitch.SetOnMouseDownFunc(const Value: String);
begin
  ControlCommon.BindMouseDown(Self, Value, FOnMouseDownFunc, InternalOnMouseDown);
end;

procedure TBasSwitch.SetOnMouseUpFunc(const Value: String);
begin
  ControlCommon.BindMouseUp(Self, Value, FOnMouseUpFunc, InternalOnMouseUp);
end;

procedure TBasSwitch.SetOnMouseMoveFunc(const Value: String);
begin
  ControlCommon.BindMouseMove(Self, Value, FOnMouseMoveFunc, InternalOnMouseMove);
end;

procedure TBasSwitch.SetOnMouseEnterFunc(const Value: String);
begin
  ControlCommon.BindMouseEnter(Self, Value, FOnMouseEnterFunc, InternalOnMouseEnter);
end;

procedure TBasSwitch.SetOnMouseLeaveFunc(const Value: String);
begin
  ControlCommon.BindMouseLeave(Self, Value, FOnMouseLeaveFunc, InternalOnMouseLeave);
end;

procedure TBasSwitch.SetOnResizeFunc(const Value: String);
begin
  ControlCommon.BindResize(Self, Value, FOnResizeFunc, InternalOnResize);
end;

procedure TBasSwitch.SetOnDragEnterFunc(const Value: String);
begin
  ControlCommon.BindDragEnter(Self, Value, FOnDragEnterFunc, InternalOnDragEnter);
end;

procedure TBasSwitch.SetOnDragOverFunc(const Value: String);
begin
  ControlCommon.BindDragOver(Self, Value, FOnDragOverFunc, InternalOnDragOver);
end;

procedure TBasSwitch.SetOnDragDropFunc(const Value: String);
begin
  ControlCommon.BindDragDrop(Self, Value, FOnDragDropFunc, InternalOnDragDrop);
end;

procedure TBasSwitch.SetOnDragLeaveFunc(const Value: String);
begin
  ControlCommon.BindDragLeave(Self, Value, FOnDragLeaveFunc, InternalOnDragLeave);
end;

// Internal Event Handlers

procedure TBasSwitch.InternalOnSwitch(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnSwitchFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnSwitchFunc) + '@#', Args);
end;

procedure TBasSwitch.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnClickFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnClickFunc) + '@#', Args);
end;

procedure TBasSwitch.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDblClickFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDblClickFunc) + '@#', Args);
end;

procedure TBasSwitch.InternalOnEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnEnterFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnEnterFunc) + '@#', Args);
end;

procedure TBasSwitch.InternalOnExit(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnExitFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnExitFunc) + '@#', Args);
end;

procedure TBasSwitch.InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnKeyDownFunc = '' then Exit();
  Args[0].p := Pointer(Self); Args[0].n := 0; Args[0].s := '';
  Args[1].n := Key; Args[1].p := nil; Args[1].s := '';
  Args[2].s := KeyChar; Args[2].n := 0; Args[2].p := nil;
  Args[3].s := ShiftStateToString(Shift); Args[3].n := 0; Args[3].p := nil;
  ExecuteCallback(LowerCase(FOnKeyDownFunc) + '@#n$$', Args);
end;

procedure TBasSwitch.InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnKeyUpFunc = '' then Exit();
  Args[0].p := Pointer(Self); Args[0].n := 0; Args[0].s := '';
  Args[1].n := Key; Args[1].p := nil; Args[1].s := '';
  Args[2].s := KeyChar; Args[2].n := 0; Args[2].p := nil;
  Args[3].s := ShiftStateToString(Shift); Args[3].n := 0; Args[3].p := nil;
  ExecuteCallback(LowerCase(FOnKeyUpFunc) + '@#n$$', Args);
end;

procedure TBasSwitch.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseDownFunc = '' then Exit();
  Args[0].p := Pointer(Self); Args[0].n := 0; Args[0].s := '';
  Args[1].n := MouseButtonToInt(Button); Args[1].p := nil; Args[1].s := '';
  Args[2].s := ShiftStateToString(Shift); Args[2].n := 0; Args[2].p := nil;
  Args[3].n := X; Args[3].p := nil; Args[3].s := '';
  Args[4].n := Y; Args[4].p := nil; Args[4].s := '';
  ExecuteCallback(LowerCase(FOnMouseDownFunc) + '@#n$nn', Args);
end;

procedure TBasSwitch.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseUpFunc = '' then Exit();
  Args[0].p := Pointer(Self); Args[0].n := 0; Args[0].s := '';
  Args[1].n := MouseButtonToInt(Button); Args[1].p := nil; Args[1].s := '';
  Args[2].s := ShiftStateToString(Shift); Args[2].n := 0; Args[2].p := nil;
  Args[3].n := X; Args[3].p := nil; Args[3].s := '';
  Args[4].n := Y; Args[4].p := nil; Args[4].s := '';
  ExecuteCallback(LowerCase(FOnMouseUpFunc) + '@#n$nn', Args);
end;

procedure TBasSwitch.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnMouseMoveFunc = '' then Exit();
  Args[0].p := Pointer(Self); Args[0].n := 0; Args[0].s := '';
  Args[1].s := ShiftStateToString(Shift); Args[1].n := 0; Args[1].p := nil;
  Args[2].n := X; Args[2].p := nil; Args[2].s := '';
  Args[3].n := Y; Args[3].p := nil; Args[3].s := '';
  ExecuteCallback(LowerCase(FOnMouseMoveFunc) + '@#$nn', Args);
end;

procedure TBasSwitch.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseEnterFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseEnterFunc) + '@#', Args);
end;

procedure TBasSwitch.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseLeaveFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseLeaveFunc) + '@#', Args);
end;

procedure TBasSwitch.InternalOnResize(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizeFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizeFunc) + '@#', Args);
end;

procedure TBasSwitch.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragEnterFunc = '' then Exit();
  Args[0].p := Pointer(Self); Args[0].n := 0; Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';
  ExecuteCallback(LowerCase(FOnDragEnterFunc) + '@#nn', Args);
end;

procedure TBasSwitch.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
var
  Args: array[0..2] of TAsmData;
  Res: TAsmData;
begin
  Operation := TDragOperation.None;
  if FOnDragOverFunc = '' then Exit();
  Args[0].p := Pointer(Self); Args[0].n := 0; Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';
  Res := ExecuteCallbackWithResult(LowerCase(FOnDragOverFunc) + '@#nn', Args);
  if Res.n <> 0 then
    Operation := TDragOperation.Move;
end;

procedure TBasSwitch.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragDropFunc = '' then Exit();
  Args[0].p := Pointer(Self); Args[0].n := 0; Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';
  ExecuteCallback(LowerCase(FOnDragDropFunc) + '@#nn', Args);
end;

procedure TBasSwitch.InternalOnDragLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDragLeaveFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDragLeaveFunc) + '@#', Args);
end;

// -----------------------------------------------------------------------------
// Error Functions
// -----------------------------------------------------------------------------

function n_switch_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

function s_switch_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

function s_switch_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Round(Args[0].n) of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_SWITCH: Result.s := 'Invalid switch pointer';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent pointer';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Failed to create switch';
    ERR_INDEX_OUT_OF_RANGE: Result.s := 'Index out of range';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_switch_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

// -----------------------------------------------------------------------------
// Creation and Destruction Functions
// -----------------------------------------------------------------------------

function p_switch_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  SW: TBasSwitch;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'switch#') then Exit();

  try
    if TObject(Args[0].p) is TCommonCustomForm then
      ParentObj := TCommonCustomForm(Args[0].p)
    else
      ParentObj := TFmxObject(Args[0].p);

    SW := TBasSwitch.Create(nil);
    SW.Parent := ParentObj;

    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(SW, Eng, Outp) then
    begin
      SW.BasicEngine := Eng;
      SW.ConsoleOutput := Outp;
    end;
    SW.Position.X := 0;
    SW.Position.Y := 0;
    SW.Width := 50;
    SW.Height := 22;

    Result.p := Pointer(SW);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(SW, SWITCH_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'switch#: ' + E.Message);
  end;
end;

function p_switch_new_pos(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  SW: TBasSwitch;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'switch#') then Exit();

  try
    if TObject(Args[0].p) is TCommonCustomForm then
      ParentObj := TCommonCustomForm(Args[0].p)
    else
      ParentObj := TFmxObject(Args[0].p);

    SW := TBasSwitch.Create(nil);
    SW.Parent := ParentObj;

    // CRITICAL: Set StyleLookup AFTER parent assignment to use the standard switch style
    // Since TBasSwitch is a subclass, FMX would look for 'basswitchstyle' which doesn't exist
    SW.StyleLookup := 'switchstyle';

    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(SW, Eng, Outp) then
    begin
      SW.BasicEngine := Eng;
      SW.ConsoleOutput := Outp;
    end;
    SW.Position.X := Args[1].n;
    SW.Position.Y := Args[2].n;
    SW.Width := Args[3].n;
    SW.Height := Args[4].n;

    Result.p := Pointer(SW);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(SW, SWITCH_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'switch#: ' + E.Message);
  end;
end;

function n_switch_free(var Args: array of TAsmData): TAsmData;
var
  SW: TBasSwitch;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_free') then
    Exit();

  try
    SW := TBasSwitch(Args[0].p);
    SW.DisconnectAllEvents();
    SW.Free();

    // Use GC to properly free the control
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(SWITCH_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
    //Its eighty-one siblings answer 1 on success. This one did too, inside
    //the collector block that was commented out.
    Result.n := 1;
  except
    on E: Exception do
    begin
      SetError(ERR_INVALID_SWITCH, 'switch_free: ' + E.Message);
    end;
  end;
end;

// -----------------------------------------------------------------------------
// Checked State Functions
// -----------------------------------------------------------------------------

function n_switch_ischecked_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_ischecked') then Exit();

  try
    if TBasSwitch(Args[0].p).IsChecked then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_ischecked: ' + E.Message);
  end;
end;

function p_switch_ischecked_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_ischecked#') then Exit();

  try
    TBasSwitch(Args[0].p).IsChecked := (Round(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_ischecked#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Position and Size Functions
// -----------------------------------------------------------------------------

function n_switch_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_x') then Exit();

  try
    Result.n := TBasSwitch(Args[0].p).Position.X;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_x: ' + E.Message);
  end;
end;

function p_switch_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_x#') then Exit();

  try
    TBasSwitch(Args[0].p).Position.X := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_x#: ' + E.Message);
  end;
end;

function n_switch_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_y') then Exit();

  try
    Result.n := TBasSwitch(Args[0].p).Position.Y;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_y: ' + E.Message);
  end;
end;

function p_switch_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_y#') then Exit();

  try
    TBasSwitch(Args[0].p).Position.Y := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_y#: ' + E.Message);
  end;
end;

function n_switch_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_width') then Exit();

  try
    Result.n := TBasSwitch(Args[0].p).Width;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_width: ' + E.Message);
  end;
end;

function p_switch_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_width#') then Exit();

  try
    TBasSwitch(Args[0].p).Width := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_width#: ' + E.Message);
  end;
end;

function n_switch_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_height') then Exit();

  try
    Result.n := TBasSwitch(Args[0].p).Height;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_height: ' + E.Message);
  end;
end;

function p_switch_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_height#') then Exit();

  try
    TBasSwitch(Args[0].p).Height := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_height#: ' + E.Message);
  end;
end;

function p_switch_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_bounds#') then Exit();

  try
    TBasSwitch(Args[0].p).SetBounds(Args[1].n, Args[2].n, Args[3].n, Args[4].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_bounds#: ' + E.Message);
  end;
end;

function p_switch_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_move#') then Exit();

  try
    TBasSwitch(Args[0].p).Position.X := Args[1].n;
    TBasSwitch(Args[0].p).Position.Y := Args[2].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_move#: ' + E.Message);
  end;
end;

function p_switch_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_size#') then Exit();

  try
    TBasSwitch(Args[0].p).Width := Args[1].n;
    TBasSwitch(Args[0].p).Height := Args[2].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_size#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Alignment Functions
// -----------------------------------------------------------------------------

function n_switch_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_align') then Exit();

  try
    Result.n := AlignToInt(TBasSwitch(Args[0].p).Align);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_align: ' + E.Message);
  end;
end;

function p_switch_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_align#') then Exit();

  try
    TBasSwitch(Args[0].p).Align := AlignFromInt(Round(Args[1].n));
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_align#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Margin Functions
// -----------------------------------------------------------------------------

function n_switch_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_marginleft') then Exit();

  try
    Result.n := TBasSwitch(Args[0].p).Margins.Left;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_marginleft: ' + E.Message);
  end;
end;

function p_switch_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_marginleft#') then Exit();

  try
    TBasSwitch(Args[0].p).Margins.Left := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_marginleft#: ' + E.Message);
  end;
end;

function n_switch_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_margintop') then Exit();

  try
    Result.n := TBasSwitch(Args[0].p).Margins.Top;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_margintop: ' + E.Message);
  end;
end;

function p_switch_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_margintop#') then Exit();

  try
    TBasSwitch(Args[0].p).Margins.Top := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_margintop#: ' + E.Message);
  end;
end;

function n_switch_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_marginright') then Exit();

  try
    Result.n := TBasSwitch(Args[0].p).Margins.Right;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_marginright: ' + E.Message);
  end;
end;

function p_switch_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_marginright#') then Exit();

  try
    TBasSwitch(Args[0].p).Margins.Right := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_marginright#: ' + E.Message);
  end;
end;

function n_switch_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_marginbottom') then Exit();

  try
    Result.n := TBasSwitch(Args[0].p).Margins.Bottom;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_marginbottom: ' + E.Message);
  end;
end;

function p_switch_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_marginbottom#') then Exit();

  try
    TBasSwitch(Args[0].p).Margins.Bottom := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_marginbottom#: ' + E.Message);
  end;
end;

function p_switch_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_margins#') then Exit();

  try
    TBasSwitch(Args[0].p).Margins.Left := Args[1].n;
    TBasSwitch(Args[0].p).Margins.Top := Args[2].n;
    TBasSwitch(Args[0].p).Margins.Right := Args[3].n;
    TBasSwitch(Args[0].p).Margins.Bottom := Args[4].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_margins#: ' + E.Message);
  end;
end;

function p_switch_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_margin#') then Exit();

  try
    TBasSwitch(Args[0].p).Margins.Left := Args[1].n;
    TBasSwitch(Args[0].p).Margins.Top := Args[1].n;
    TBasSwitch(Args[0].p).Margins.Right := Args[1].n;
    TBasSwitch(Args[0].p).Margins.Bottom := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_margin#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Visibility and State Functions
// -----------------------------------------------------------------------------

function n_switch_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_visible') then Exit();

  try
    if TBasSwitch(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_visible: ' + E.Message);
  end;
end;

function p_switch_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_visible#') then Exit();

  try
    TBasSwitch(Args[0].p).Visible := (Round(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_visible#: ' + E.Message);
  end;
end;

function n_switch_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_enabled') then Exit();

  try
    if TBasSwitch(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_enabled: ' + E.Message);
  end;
end;

function p_switch_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_enabled#') then Exit();

  try
    TBasSwitch(Args[0].p).Enabled := (Round(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_enabled#: ' + E.Message);
  end;
end;

function n_switch_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_opacity') then Exit();

  try
    Result.n := TBasSwitch(Args[0].p).Opacity;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_opacity: ' + E.Message);
  end;
end;

function p_switch_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_opacity#') then Exit();

  try
    TBasSwitch(Args[0].p).Opacity := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_opacity#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Focus Functions
// -----------------------------------------------------------------------------

function n_switch_isfocused_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_isfocused') then Exit();

  try
    if TBasSwitch(Args[0].p).IsFocused then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_isfocused: ' + E.Message);
  end;
end;

function p_switch_setfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_setfocus#') then Exit();

  try
    TBasSwitch(Args[0].p).SetFocus();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_setfocus#: ' + E.Message);
  end;
end;

function p_switch_resetfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_resetfocus#') then Exit();

  try
    TBasSwitch(Args[0].p).ResetFocus();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_resetfocus#: ' + E.Message);
  end;
end;

function n_switch_taborder_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_taborder') then Exit();

  try
    Result.n := TBasSwitch(Args[0].p).TabOrder;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_taborder: ' + E.Message);
  end;
end;

function p_switch_taborder_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_taborder#') then Exit();

  try
    TBasSwitch(Args[0].p).TabOrder := Round(Args[1].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_taborder#: ' + E.Message);
  end;
end;

function n_switch_canfocus_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_canfocus') then Exit();

  try
    if TBasSwitch(Args[0].p).CanFocus then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_canfocus: ' + E.Message);
  end;
end;

function p_switch_canfocus_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_canfocus#') then Exit();

  try
    TBasSwitch(Args[0].p).CanFocus := (Round(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_canfocus#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Tag Functions
// -----------------------------------------------------------------------------

function n_switch_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_tag') then Exit();

  try
    Result.n := TBasSwitch(Args[0].p).Tag;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_tag: ' + E.Message);
  end;
end;

function p_switch_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_tag#') then Exit();

  try
    TBasSwitch(Args[0].p).Tag := Round(Args[1].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_tag#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// HitTest Functions
// -----------------------------------------------------------------------------

function n_switch_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_hittest') then Exit();

  try
    if TBasSwitch(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_hittest: ' + E.Message);
  end;
end;

function p_switch_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_hittest#') then Exit();

  try
    TBasSwitch(Args[0].p).HitTest := (Round(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_hittest#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// DragMode Functions
// -----------------------------------------------------------------------------

function n_switch_dragmode_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_dragmode') then Exit();

  try
    if TBasSwitch(Args[0].p).DragMode = TDragMode.dmAutomatic then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_dragmode: ' + E.Message);
  end;
end;

function p_switch_dragmode_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_dragmode#') then Exit();

  try
    if Round(Args[1].n) <> 0 then
      TBasSwitch(Args[0].p).DragMode := TDragMode.dmAutomatic
    else
      TBasSwitch(Args[0].p).DragMode := TDragMode.dmManual;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_dragmode#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Parent Functions
// -----------------------------------------------------------------------------

function p_switch_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_parent#') then Exit();

  try
    Result.p := TBasSwitch(Args[0].p).Parent;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_parent#: ' + E.Message);
  end;
end;

function p_switch_parent_set(var Args: array of TAsmData): TAsmData;
var
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_parent#') then Exit();
  if not ValidateParent(Args[1].p, 'switch_parent#') then Exit();

  try
    if TObject(Args[1].p) is TCommonCustomForm then
      ParentObj := TCommonCustomForm(Args[1].p)
    else
      ParentObj := TFmxObject(Args[1].p);

    TBasSwitch(Args[0].p).Parent := ParentObj;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_parent#: ' + E.Message);
  end;
end;

function p_switch_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_bringtofront#') then Exit();

  try
    TBasSwitch(Args[0].p).BringToFront();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_bringtofront#: ' + E.Message);
  end;
end;

function p_switch_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_sendtoback#') then Exit();

  try
    TBasSwitch(Args[0].p).SendToBack();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_sendtoback#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Toggle Function
// -----------------------------------------------------------------------------

function p_switch_toggle(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_toggle#') then Exit();

  try
    TBasSwitch(Args[0].p).IsChecked := not TBasSwitch(Args[0].p).IsChecked;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_toggle#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Event Callback Functions
// -----------------------------------------------------------------------------

function p_switch_onswitch_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onswitch#') then Exit();

  try
    TBasSwitch(Args[0].p).OnSwitchFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onswitch#: ' + E.Message);
  end;
end;

function s_switch_onswitch_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onswitch$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnSwitchFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onswitch$: ' + E.Message);
  end;
end;

function p_switch_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onclick#') then Exit();

  try
    TBasSwitch(Args[0].p).OnClickFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onclick#: ' + E.Message);
  end;
end;

function s_switch_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onclick$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnClickFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onclick$: ' + E.Message);
  end;
end;

function p_switch_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_ondblclick#') then Exit();

  try
    TBasSwitch(Args[0].p).OnDblClickFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_ondblclick#: ' + E.Message);
  end;
end;

function s_switch_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_ondblclick$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnDblClickFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_ondblclick$: ' + E.Message);
  end;
end;

function p_switch_onenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onenter#') then Exit();

  try
    TBasSwitch(Args[0].p).OnEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onenter#: ' + E.Message);
  end;
end;

function s_switch_onenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onenter$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onenter$: ' + E.Message);
  end;
end;

function p_switch_onexit_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onexit#') then Exit();

  try
    TBasSwitch(Args[0].p).OnExitFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onexit#: ' + E.Message);
  end;
end;

function s_switch_onexit_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onexit$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnExitFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onexit$: ' + E.Message);
  end;
end;

function p_switch_onkeydown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onkeydown#') then Exit();

  try
    TBasSwitch(Args[0].p).OnKeyDownFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onkeydown#: ' + E.Message);
  end;
end;

function s_switch_onkeydown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onkeydown$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnKeyDownFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onkeydown$: ' + E.Message);
  end;
end;

function p_switch_onkeyup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onkeyup#') then Exit();

  try
    TBasSwitch(Args[0].p).OnKeyUpFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onkeyup#: ' + E.Message);
  end;
end;

function s_switch_onkeyup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onkeyup$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnKeyUpFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onkeyup$: ' + E.Message);
  end;
end;

function p_switch_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onmousedown#') then Exit();

  try
    TBasSwitch(Args[0].p).OnMouseDownFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onmousedown#: ' + E.Message);
  end;
end;

function s_switch_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onmousedown$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnMouseDownFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onmousedown$: ' + E.Message);
  end;
end;

function p_switch_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onmouseup#') then Exit();

  try
    TBasSwitch(Args[0].p).OnMouseUpFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onmouseup#: ' + E.Message);
  end;
end;

function s_switch_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onmouseup$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnMouseUpFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onmouseup$: ' + E.Message);
  end;
end;

function p_switch_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onmousemove#') then Exit();

  try
    TBasSwitch(Args[0].p).OnMouseMoveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onmousemove#: ' + E.Message);
  end;
end;

function s_switch_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onmousemove$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnMouseMoveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onmousemove$: ' + E.Message);
  end;
end;

function p_switch_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onmouseenter#') then Exit();

  try
    TBasSwitch(Args[0].p).OnMouseEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onmouseenter#: ' + E.Message);
  end;
end;

function s_switch_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onmouseenter$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnMouseEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onmouseenter$: ' + E.Message);
  end;
end;

function p_switch_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onmouseleave#') then Exit();

  try
    TBasSwitch(Args[0].p).OnMouseLeaveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onmouseleave#: ' + E.Message);
  end;
end;

function s_switch_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onmouseleave$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnMouseLeaveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onmouseleave$: ' + E.Message);
  end;
end;

function p_switch_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onresize#') then Exit();

  try
    TBasSwitch(Args[0].p).OnResizeFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onresize#: ' + E.Message);
  end;
end;

function s_switch_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_onresize$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnResizeFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_onresize$: ' + E.Message);
  end;
end;

// Drag & Drop event callbacks

function p_switch_ondragenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_ondragenter#') then Exit();

  try
    TBasSwitch(Args[0].p).OnDragEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_ondragenter#: ' + E.Message);
  end;
end;

function s_switch_ondragenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_ondragenter$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnDragEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_ondragenter$: ' + E.Message);
  end;
end;

function p_switch_ondragover_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_ondragover#') then Exit();

  try
    TBasSwitch(Args[0].p).OnDragOverFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_ondragover#: ' + E.Message);
  end;
end;

function s_switch_ondragover_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_ondragover$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnDragOverFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_ondragover$: ' + E.Message);
  end;
end;

function p_switch_ondragdrop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_ondragdrop#') then Exit();

  try
    TBasSwitch(Args[0].p).OnDragDropFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_ondragdrop#: ' + E.Message);
  end;
end;

function s_switch_ondragdrop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_ondragdrop$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnDragDropFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_ondragdrop$: ' + E.Message);
  end;
end;

function p_switch_ondragleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_ondragleave#') then Exit();

  try
    TBasSwitch(Args[0].p).OnDragLeaveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_ondragleave#: ' + E.Message);
  end;
end;

function s_switch_ondragleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_ondragleave$') then Exit();

  try
    Result.s := TBasSwitch(Args[0].p).OnDragLeaveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SWITCH, 'switch_ondragleave$: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Clear Callbacks Function
// -----------------------------------------------------------------------------

function p_switch_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSwitch(Args[0].p, 'switch_clearcallbacks#') then Exit();

  try
    with TBasSwitch(Args[0].p) do
    begin
      OnSwitchFunc := '';
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
      SetError(ERR_OPERATION_FAILED, 'switch_clearcallbacks#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Library Registration
// -----------------------------------------------------------------------------

procedure RegisterSwitchFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_switch_error; Lib.Add('switch_error@', Fn);
  Fn.Entry := @s_switch_errormsg; Lib.Add('switch_errormsg$@', Fn);
  Fn.Entry := @s_switch_strerror; Lib.Add('switch_strerror$@n', Fn);
  Fn.Entry := @n_switch_clearerror; Lib.Add('switch_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_switch_new; Lib.Add('switch#@#', Fn);
  Fn.Entry := @p_switch_new_pos; Lib.Add('switch#@#nnnn', Fn);
  Fn.Entry := @n_switch_free; Lib.Add('switch_free@#', Fn);

  // Checked state
  Fn.Entry := @n_switch_ischecked_get; Lib.Add('switch_ischecked@#', Fn);
  Fn.Entry := @p_switch_ischecked_set; Lib.Add('switch_ischecked#@#n', Fn);

  // Toggle
  Fn.Entry := @p_switch_toggle; Lib.Add('switch_toggle#@#', Fn);

  // Position and Size
  Fn.Entry := @n_switch_x_get; Lib.Add('switch_x@#', Fn);
  Fn.Entry := @p_switch_x_set; Lib.Add('switch_x#@#n', Fn);
  Fn.Entry := @n_switch_y_get; Lib.Add('switch_y@#', Fn);
  Fn.Entry := @p_switch_y_set; Lib.Add('switch_y#@#n', Fn);
  Fn.Entry := @n_switch_width_get; Lib.Add('switch_width@#', Fn);
  Fn.Entry := @p_switch_width_set; Lib.Add('switch_width#@#n', Fn);
  Fn.Entry := @n_switch_height_get; Lib.Add('switch_height@#', Fn);
  Fn.Entry := @p_switch_height_set; Lib.Add('switch_height#@#n', Fn);
  Fn.Entry := @p_switch_bounds_set; Lib.Add('switch_bounds#@#nnnn', Fn);
  Fn.Entry := @p_switch_move_set; Lib.Add('switch_move#@#nn', Fn);
  Fn.Entry := @p_switch_size_set; Lib.Add('switch_size#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_switch_align_get; Lib.Add('switch_align@#', Fn);
  Fn.Entry := @p_switch_align_set; Lib.Add('switch_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_switch_marginleft_get; Lib.Add('switch_marginleft@#', Fn);
  Fn.Entry := @p_switch_marginleft_set; Lib.Add('switch_marginleft#@#n', Fn);
  Fn.Entry := @n_switch_margintop_get; Lib.Add('switch_margintop@#', Fn);
  Fn.Entry := @p_switch_margintop_set; Lib.Add('switch_margintop#@#n', Fn);
  Fn.Entry := @n_switch_marginright_get; Lib.Add('switch_marginright@#', Fn);
  Fn.Entry := @p_switch_marginright_set; Lib.Add('switch_marginright#@#n', Fn);
  Fn.Entry := @n_switch_marginbottom_get; Lib.Add('switch_marginbottom@#', Fn);
  Fn.Entry := @p_switch_marginbottom_set; Lib.Add('switch_marginbottom#@#n', Fn);
  Fn.Entry := @p_switch_margins_set; Lib.Add('switch_margins#@#nnnn', Fn);
  Fn.Entry := @p_switch_margin_set; Lib.Add('switch_margin#@#n', Fn);

  // Visibility and state
  Fn.Entry := @n_switch_visible_get; Lib.Add('switch_visible@#', Fn);
  Fn.Entry := @p_switch_visible_set; Lib.Add('switch_visible#@#n', Fn);
  Fn.Entry := @n_switch_enabled_get; Lib.Add('switch_enabled@#', Fn);
  Fn.Entry := @p_switch_enabled_set; Lib.Add('switch_enabled#@#n', Fn);
  Fn.Entry := @n_switch_opacity_get; Lib.Add('switch_opacity@#', Fn);
  Fn.Entry := @p_switch_opacity_set; Lib.Add('switch_opacity#@#n', Fn);

  // Focus
  Fn.Entry := @n_switch_isfocused_get; Lib.Add('switch_isfocused@#', Fn);
  Fn.Entry := @p_switch_setfocus; Lib.Add('switch_setfocus#@#', Fn);
  Fn.Entry := @p_switch_resetfocus; Lib.Add('switch_resetfocus#@#', Fn);
  Fn.Entry := @n_switch_taborder_get; Lib.Add('switch_taborder@#', Fn);
  Fn.Entry := @p_switch_taborder_set; Lib.Add('switch_taborder#@#n', Fn);
  Fn.Entry := @n_switch_canfocus_get; Lib.Add('switch_canfocus@#', Fn);
  Fn.Entry := @p_switch_canfocus_set; Lib.Add('switch_canfocus#@#n', Fn);

  // Tag
  Fn.Entry := @n_switch_tag_get; Lib.Add('switch_tag@#', Fn);
  Fn.Entry := @p_switch_tag_set; Lib.Add('switch_tag#@#n', Fn);

  // HitTest
  Fn.Entry := @n_switch_hittest_get; Lib.Add('switch_hittest@#', Fn);
  Fn.Entry := @p_switch_hittest_set; Lib.Add('switch_hittest#@#n', Fn);

  // DragMode
  Fn.Entry := @n_switch_dragmode_get; Lib.Add('switch_dragmode@#', Fn);
  Fn.Entry := @p_switch_dragmode_set; Lib.Add('switch_dragmode#@#n', Fn);

  // Parent
  Fn.Entry := @p_switch_parent_get; Lib.Add('switch_parent#@#', Fn);
  Fn.Entry := @p_switch_parent_set; Lib.Add('switch_parent#@##', Fn);
  Fn.Entry := @p_switch_bringtofront; Lib.Add('switch_bringtofront#@#', Fn);
  Fn.Entry := @p_switch_sendtoback; Lib.Add('switch_sendtoback#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_switch_onswitch_set; Lib.Add('switch_onswitch#@#$', Fn);
  Fn.Entry := @s_switch_onswitch_get; Lib.Add('switch_onswitch$@#', Fn);
  Fn.Entry := @p_switch_onclick_set; Lib.Add('switch_onclick#@#$', Fn);
  Fn.Entry := @s_switch_onclick_get; Lib.Add('switch_onclick$@#', Fn);
  Fn.Entry := @p_switch_ondblclick_set; Lib.Add('switch_ondblclick#@#$', Fn);
  Fn.Entry := @s_switch_ondblclick_get; Lib.Add('switch_ondblclick$@#', Fn);
  Fn.Entry := @p_switch_onenter_set; Lib.Add('switch_onenter#@#$', Fn);
  Fn.Entry := @s_switch_onenter_get; Lib.Add('switch_onenter$@#', Fn);
  Fn.Entry := @p_switch_onexit_set; Lib.Add('switch_onexit#@#$', Fn);
  Fn.Entry := @s_switch_onexit_get; Lib.Add('switch_onexit$@#', Fn);
  Fn.Entry := @p_switch_onkeydown_set; Lib.Add('switch_onkeydown#@#$', Fn);
  Fn.Entry := @s_switch_onkeydown_get; Lib.Add('switch_onkeydown$@#', Fn);
  Fn.Entry := @p_switch_onkeyup_set; Lib.Add('switch_onkeyup#@#$', Fn);
  Fn.Entry := @s_switch_onkeyup_get; Lib.Add('switch_onkeyup$@#', Fn);
  Fn.Entry := @p_switch_onmousedown_set; Lib.Add('switch_onmousedown#@#$', Fn);
  Fn.Entry := @s_switch_onmousedown_get; Lib.Add('switch_onmousedown$@#', Fn);
  Fn.Entry := @p_switch_onmouseup_set; Lib.Add('switch_onmouseup#@#$', Fn);
  Fn.Entry := @s_switch_onmouseup_get; Lib.Add('switch_onmouseup$@#', Fn);
  Fn.Entry := @p_switch_onmousemove_set; Lib.Add('switch_onmousemove#@#$', Fn);
  Fn.Entry := @s_switch_onmousemove_get; Lib.Add('switch_onmousemove$@#', Fn);
  Fn.Entry := @p_switch_onmouseenter_set; Lib.Add('switch_onmouseenter#@#$', Fn);
  Fn.Entry := @s_switch_onmouseenter_get; Lib.Add('switch_onmouseenter$@#', Fn);
  Fn.Entry := @p_switch_onmouseleave_set; Lib.Add('switch_onmouseleave#@#$', Fn);
  Fn.Entry := @s_switch_onmouseleave_get; Lib.Add('switch_onmouseleave$@#', Fn);
  Fn.Entry := @p_switch_onresize_set; Lib.Add('switch_onresize#@#$', Fn);
  Fn.Entry := @s_switch_onresize_get; Lib.Add('switch_onresize$@#', Fn);

  // Drag & Drop event callbacks
  Fn.Entry := @p_switch_ondragenter_set; Lib.Add('switch_ondragenter#@#$', Fn);
  Fn.Entry := @s_switch_ondragenter_get; Lib.Add('switch_ondragenter$@#', Fn);
  Fn.Entry := @p_switch_ondragover_set; Lib.Add('switch_ondragover#@#$', Fn);
  Fn.Entry := @s_switch_ondragover_get; Lib.Add('switch_ondragover$@#', Fn);
  Fn.Entry := @p_switch_ondragdrop_set; Lib.Add('switch_ondragdrop#@#$', Fn);
  Fn.Entry := @s_switch_ondragdrop_get; Lib.Add('switch_ondragdrop$@#', Fn);
  Fn.Entry := @p_switch_ondragleave_set; Lib.Add('switch_ondragleave#@#$', Fn);
  Fn.Entry := @s_switch_ondragleave_get; Lib.Add('switch_ondragleave$@#', Fn);

  // Clear callbacks
  Fn.Entry := @p_switch_clearcallbacks; Lib.Add('switch_clearcallbacks#@#', Fn);
end;

end.

