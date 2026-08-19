unit RadioButtonLib;

{******************************************************************************
  RadioButtonLib - RadioButton Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TRadioButton wrapper functionality for creating
  and managing radio button controls in Plan9Basic programs.

  Function Count: 90+ functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All radio buttons are created at RUNTIME using TRadioButton.Create with dynamic
  parent assignment. This ensures proper dynamic creation across all platforms.

  EVENT CONNECTION MODEL:
  =======================
  Events are connected/disconnected individually when callbacks are set:
  - Setting a non-empty callback name connects ONLY that specific event
  - Setting an empty callback name ("") disconnects ONLY that specific event
  - No events are connected by default in the constructor

  FEATURES:
  =========
  - RadioButton creation and lifecycle management
  - IsChecked state control (checked/unchecked)
  - GroupName property for mutual exclusion groups
  - Text content with font styling (family, size, bold, italic, etc.)
  - Complete positioning and alignment
  - Full event support with BASIC callback integration
  - Drag and drop support

  GROUPNAME FUNCTIONALITY:
  ========================
  Radio buttons with the same GroupName are mutually exclusive - selecting
  one automatically deselects others in the same group. Radio buttons with
  different GroupNames or empty GroupName operate independently.

  EVENTS SUPPORT:
  ===============
  - OnChange: Checked state changed (primary radio button event)
  - OnClick: RadioButton was clicked
  - OnDblClick: RadioButton was double-clicked
  - OnEnter: RadioButton received focus
  - OnExit: RadioButton lost focus
  - OnKeyDown: Key was pressed while focused
  - OnKeyUp: Key was released while focused
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over radio button
  - OnMouseEnter: Mouse entered radio button area
  - OnMouseLeave: Mouse left radio button area
  - OnResize: RadioButton is being resized
  - OnDragEnter: Drag operation entered radio button
  - OnDragOver: Drag operation over radio button (return non-zero to accept)
  - OnDragDrop: Item was dropped on radio button
  - OnDragLeave: Drag operation left radio button

  USAGE PATTERN:
  ==============
    let frm# = form#("RadioButton Demo", 400, 300)

    ' Create radio buttons in a group
    let rb1# = radiobutton#(frm#, "Option A")
    radiobutton_move#(rb1#, 50, 50)
    radiobutton_groupname#(rb1#, "options")
    radiobutton_onchange#(rb1#, "OnOptionChanged")

    let rb2# = radiobutton#(frm#, "Option B")
    radiobutton_move#(rb2#, 50, 80)
    radiobutton_groupname#(rb2#, "options")
    radiobutton_onchange#(rb2#, "OnOptionChanged")

    let rb3# = radiobutton#(frm#, "Option C")
    radiobutton_move#(rb3#, 50, 110)
    radiobutton_groupname#(rb3#, "options")
    radiobutton_onchange#(rb3#, "OnOptionChanged")

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnOptionChanged(sender#) local checked
      checked = radiobutton_ischecked(sender#)
      if checked = 1 then
        println "Option selected: " + radiobutton_text$(sender#)
      endif
    endfunction

    function OnRadioKeyDown(sender#, key, keychar$, shift$)
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
  basic, exec, UnitGC, HandleRegistry, ControlCommon;

type
  TBasRadioButton = class(TRadioButton)
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

procedure RegisterRadioButtonFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  RADIOBUTTON_GC_TAG = 'BASIC_RADIOBUTTON';
  ERR_NONE = 0;
  ERR_INVALID_RADIOBUTTON = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INDEX_OUT_OF_RANGE = 5;


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

function ValidateRadioButton(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_RADIOBUTTON, FuncName + ': Nil pointer');
    Exit();
  end;

  try
    if not(IsHandleOf(P, TBasRadioButton)) then
    begin
      SetError(ERR_INVALID_RADIOBUTTON, FuncName + ': Invalid object');
      Exit();
    end;
  except
    SetError(ERR_INVALID_RADIOBUTTON, FuncName + ': Invalid pointer');
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

// -----------------------------------------------------------------------------
// TBasRadioButton Implementation
// -----------------------------------------------------------------------------

constructor TBasRadioButton.Create(AOwner: TComponent);
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

destructor TBasRadioButton.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasRadioButton.DisconnectAllEvents();
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

procedure TBasRadioButton.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'RadioButton');
end;

function TBasRadioButton.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
begin
  Result := ControlCommon.RunCallbackWithResult(FBasicEngine, FConsoleOutput,
                          FuncSignature, Args, 'RadioButton');
end;

// Event Setters - Connect/Disconnect events granularly

procedure TBasRadioButton.SetOnChangeFunc(const Value: String);
begin
  FOnChangeFunc := Value;
  if Value <> '' then
    OnChange := InternalOnChange
  else
    OnChange := nil;
end;

procedure TBasRadioButton.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    OnClick := InternalOnClick
  else
    OnClick := nil;
end;

procedure TBasRadioButton.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    OnDblClick := InternalOnDblClick
  else
    OnDblClick := nil;
end;

procedure TBasRadioButton.SetOnEnterFunc(const Value: String);
begin
  FOnEnterFunc := Value;
  if Value <> '' then
    OnEnter := InternalOnEnter
  else
    OnEnter := nil;
end;

procedure TBasRadioButton.SetOnExitFunc(const Value: String);
begin
  FOnExitFunc := Value;
  if Value <> '' then
    OnExit := InternalOnExit
  else
    OnExit := nil;
end;

procedure TBasRadioButton.SetOnKeyDownFunc(const Value: String);
begin
  FOnKeyDownFunc := Value;
  if Value <> '' then
    OnKeyDown := InternalOnKeyDown
  else
    OnKeyDown := nil;
end;

procedure TBasRadioButton.SetOnKeyUpFunc(const Value: String);
begin
  FOnKeyUpFunc := Value;
  if Value <> '' then
    OnKeyUp := InternalOnKeyUp
  else
    OnKeyUp := nil;
end;

procedure TBasRadioButton.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    OnMouseDown := InternalOnMouseDown
  else
    OnMouseDown := nil;
end;

procedure TBasRadioButton.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    OnMouseUp := InternalOnMouseUp
  else
    OnMouseUp := nil;
end;

procedure TBasRadioButton.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    OnMouseMove := InternalOnMouseMove
  else
    OnMouseMove := nil;
end;

procedure TBasRadioButton.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    OnMouseEnter := InternalOnMouseEnter
  else
    OnMouseEnter := nil;
end;

procedure TBasRadioButton.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    OnMouseLeave := InternalOnMouseLeave
  else
    OnMouseLeave := nil;
end;

procedure TBasRadioButton.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    OnResize := InternalOnResize
  else
    OnResize := nil;
end;

procedure TBasRadioButton.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    OnDragEnter := InternalOnDragEnter
  else
    OnDragEnter := nil;
end;

procedure TBasRadioButton.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    OnDragOver := InternalOnDragOver
  else
    OnDragOver := nil;
end;

procedure TBasRadioButton.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    OnDragDrop := InternalOnDragDrop
  else
    OnDragDrop := nil;
end;

procedure TBasRadioButton.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    OnDragLeave := InternalOnDragLeave
  else
    OnDragLeave := nil;
end;

// Internal Event Handlers

procedure TBasRadioButton.InternalOnChange(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnChangeFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnChangeFunc) + '@#', Args);
end;

procedure TBasRadioButton.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnClickFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnClickFunc) + '@#', Args);
end;

procedure TBasRadioButton.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDblClickFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDblClickFunc) + '@#', Args);
end;

procedure TBasRadioButton.InternalOnEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnEnterFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnEnterFunc) + '@#', Args);
end;

procedure TBasRadioButton.InternalOnExit(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnExitFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnExitFunc) + '@#', Args);
end;

procedure TBasRadioButton.InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
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

procedure TBasRadioButton.InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
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

procedure TBasRadioButton.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasRadioButton.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasRadioButton.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
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

procedure TBasRadioButton.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseEnterFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseEnterFunc) + '@#', Args);
end;

procedure TBasRadioButton.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseLeaveFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseLeaveFunc) + '@#', Args);
end;

procedure TBasRadioButton.InternalOnResize(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizeFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizeFunc) + '@#', Args);
end;

procedure TBasRadioButton.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragEnterFunc = '' then Exit();
  Args[0].p := Pointer(Self); Args[0].n := 0; Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';
  ExecuteCallback(LowerCase(FOnDragEnterFunc) + '@#nn', Args);
end;

procedure TBasRadioButton.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
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

procedure TBasRadioButton.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragDropFunc = '' then Exit();
  Args[0].p := Pointer(Self); Args[0].n := 0; Args[0].s := '';
  Args[1].n := Point.X; Args[1].p := nil; Args[1].s := '';
  Args[2].n := Point.Y; Args[2].p := nil; Args[2].s := '';
  ExecuteCallback(LowerCase(FOnDragDropFunc) + '@#nn', Args);
end;

procedure TBasRadioButton.InternalOnDragLeave(Sender: TObject);
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

function n_radiobutton_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

function s_radiobutton_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

function s_radiobutton_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Round(Args[0].n) of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_RADIOBUTTON: Result.s := 'Invalid radio button pointer';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent pointer';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Failed to create radio button';
    ERR_INDEX_OUT_OF_RANGE: Result.s := 'Index out of range';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_radiobutton_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

// -----------------------------------------------------------------------------
// Creation and Destruction Functions
// -----------------------------------------------------------------------------

function p_radiobutton_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  RB: TBasRadioButton;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'radiobutton#') then Exit();

  try
    if TObject(Args[0].p) is TCommonCustomForm then
      ParentObj := TCommonCustomForm(Args[0].p)
    else
      ParentObj := TFmxObject(Args[0].p);

    RB := TBasRadioButton.Create(nil);
    RB.Parent := ParentObj;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(RB, Eng, Outp) then
    begin
      RB.BasicEngine := Eng;
      RB.ConsoleOutput := Outp;
    end;
    RB.Position.X := 0;
    RB.Position.Y := 0;
    RB.Width := 120;
    RB.Height := 22;

    Result.p := Pointer(RB);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(RB, RADIOBUTTON_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'radiobutton#: ' + E.Message);
  end;
end;

function p_radiobutton_new_text(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  RB: TBasRadioButton;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'radiobutton#') then Exit();

  try
    if TObject(Args[0].p) is TCommonCustomForm then
      ParentObj := TCommonCustomForm(Args[0].p)
    else
      ParentObj := TFmxObject(Args[0].p);

    RB := TBasRadioButton.Create(nil);
    RB.Parent := ParentObj;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(RB, Eng, Outp) then
    begin
      RB.BasicEngine := Eng;
      RB.ConsoleOutput := Outp;
    end;
    RB.Text := Args[1].s;
    RB.Position.X := 0;
    RB.Position.Y := 0;
    RB.Width := 120;
    RB.Height := 22;

    Result.p := Pointer(RB);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(RB, RADIOBUTTON_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'radiobutton#: ' + E.Message);
  end;
end;

function p_radiobutton_new_pos(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  RB: TBasRadioButton;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'radiobutton#') then Exit();

  try
    if TObject(Args[0].p) is TCommonCustomForm then
      ParentObj := TCommonCustomForm(Args[0].p)
    else
      ParentObj := TFmxObject(Args[0].p);

    RB := TBasRadioButton.Create(nil);
    RB.Parent := ParentObj;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(RB, Eng, Outp) then
    begin
      RB.BasicEngine := Eng;
      RB.ConsoleOutput := Outp;
    end;
    RB.Position.X := Args[1].n;
    RB.Position.Y := Args[2].n;
    RB.Width := Args[3].n;
    RB.Height := Args[4].n;

    Result.p := Pointer(RB);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(RB, RADIOBUTTON_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'radiobutton#: ' + E.Message);
  end;
end;

function p_radiobutton_new_full(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  RB: TBasRadioButton;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'radiobutton#') then Exit();

  try
    if TObject(Args[0].p) is TCommonCustomForm then
      ParentObj := TCommonCustomForm(Args[0].p)
    else
      ParentObj := TFmxObject(Args[0].p);

    RB := TBasRadioButton.Create(nil);
    RB.Parent := ParentObj;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(RB, Eng, Outp) then
    begin
      RB.BasicEngine := Eng;
      RB.ConsoleOutput := Outp;
    end;
    RB.Text := Args[1].s;
    RB.Position.X := Args[2].n;
    RB.Position.Y := Args[3].n;
    RB.Width := Args[4].n;
    RB.Height := Args[5].n;

    Result.p := Pointer(RB);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(RB, RADIOBUTTON_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'radiobutton#: ' + E.Message);
  end;
end;

function n_radiobutton_free(var Args: array of TAsmData): TAsmData;
var
  RB: TBasRadioButton;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_free') then Exit();

  try
    RB := TBasRadioButton(Args[0].p);
    RB.DisconnectAllEvents();
    RB.Free();

    // Use GC to properly free the control
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(RADIOBUTTON_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_free: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Checked State Functions
// -----------------------------------------------------------------------------

function n_radiobutton_ischecked_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_ischecked') then Exit();

  try
    if TBasRadioButton(Args[0].p).IsChecked then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_ischecked: ' + E.Message);
  end;
end;

function p_radiobutton_ischecked_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_ischecked#') then Exit();

  try
    TBasRadioButton(Args[0].p).IsChecked := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_ischecked#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// GroupName Functions (IMPORTANT for radio button mutual exclusion)
// -----------------------------------------------------------------------------

function s_radiobutton_groupname_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_groupname$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).GroupName;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_groupname$: ' + E.Message);
  end;
end;

function p_radiobutton_groupname_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_groupname#') then Exit();

  try
    TBasRadioButton(Args[0].p).GroupName := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_groupname#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Text Content Functions
// -----------------------------------------------------------------------------

function s_radiobutton_text_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_text$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).Text;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_text$: ' + E.Message);
  end;
end;

function p_radiobutton_text_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_text#') then Exit();

  try
    TBasRadioButton(Args[0].p).Text := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_text#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Font Properties Functions
// -----------------------------------------------------------------------------

function s_radiobutton_fontfamily_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_fontfamily$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).TextSettings.Font.Family;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_fontfamily$: ' + E.Message);
  end;
end;

function p_radiobutton_fontfamily_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_fontfamily#') then Exit();

  try
    TBasRadioButton(Args[0].p).TextSettings.Font.Family := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_fontfamily#: ' + E.Message);
  end;
end;

function n_radiobutton_fontsize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_fontsize') then Exit();

  try
    Result.n := TBasRadioButton(Args[0].p).TextSettings.Font.Size;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_fontsize: ' + E.Message);
  end;
end;

function p_radiobutton_fontsize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_fontsize#') then Exit();

  try
    TBasRadioButton(Args[0].p).TextSettings.Font.Size := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_fontsize#: ' + E.Message);
  end;
end;

function s_radiobutton_fontcolor_get(var Args: array of TAsmData): TAsmData;
var
  Color: TAlphaColor;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_fontcolor$') then Exit();

  try
    Color := TBasRadioButton(Args[0].p).TextSettings.FontColor;
    Result.s := '#' + IntToHex(TAlphaColorRec(Color).R, 2) +
                      IntToHex(TAlphaColorRec(Color).G, 2) +
                      IntToHex(TAlphaColorRec(Color).B, 2);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_fontcolor$: ' + E.Message);
  end;
end;

function p_radiobutton_fontcolor_set(var Args: array of TAsmData): TAsmData;
var
  ColorStr: String;
  R, G, B: Byte;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_fontcolor#') then Exit();

  try
    ColorStr := Args[1].s;
    if (Length(ColorStr) >= 7) and (ColorStr[1] = '#') then
    begin
      R := StrToInt('$' + Copy(ColorStr, 2, 2));
      G := StrToInt('$' + Copy(ColorStr, 4, 2));
      B := StrToInt('$' + Copy(ColorStr, 6, 2));
      TBasRadioButton(Args[0].p).TextSettings.FontColor := TAlphaColorF.Create(R/255, G/255, B/255, 1.0).ToAlphaColor;
    end;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'radiobutton_fontcolor#: ' + E.Message);
  end;
end;

function n_radiobutton_bold_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_bold') then Exit();

  try
    if TFontStyle.fsBold in TBasRadioButton(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_bold: ' + E.Message);
  end;
end;

function p_radiobutton_bold_set(var Args: array of TAsmData): TAsmData;
var
  Style: TFontStyles;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_bold#') then Exit();

  try
    Style := TBasRadioButton(Args[0].p).TextSettings.Font.Style;
    if Args[1].n <> 0 then
      Style := Style + [TFontStyle.fsBold]
    else
      Style := Style - [TFontStyle.fsBold];
    TBasRadioButton(Args[0].p).TextSettings.Font.Style := Style;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_bold#: ' + E.Message);
  end;
end;

function n_radiobutton_italic_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_italic') then Exit();

  try
    if TFontStyle.fsItalic in TBasRadioButton(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_italic: ' + E.Message);
  end;
end;

function p_radiobutton_italic_set(var Args: array of TAsmData): TAsmData;
var
  Style: TFontStyles;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_italic#') then Exit();

  try
    Style := TBasRadioButton(Args[0].p).TextSettings.Font.Style;
    if Args[1].n <> 0 then
      Style := Style + [TFontStyle.fsItalic]
    else
      Style := Style - [TFontStyle.fsItalic];
    TBasRadioButton(Args[0].p).TextSettings.Font.Style := Style;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_italic#: ' + E.Message);
  end;
end;

function n_radiobutton_underline_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_underline') then Exit();

  try
    if TFontStyle.fsUnderline in TBasRadioButton(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_underline: ' + E.Message);
  end;
end;

function p_radiobutton_underline_set(var Args: array of TAsmData): TAsmData;
var
  Style: TFontStyles;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_underline#') then Exit();

  try
    Style := TBasRadioButton(Args[0].p).TextSettings.Font.Style;
    if Args[1].n <> 0 then
      Style := Style + [TFontStyle.fsUnderline]
    else
      Style := Style - [TFontStyle.fsUnderline];
    TBasRadioButton(Args[0].p).TextSettings.Font.Style := Style;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_underline#: ' + E.Message);
  end;
end;

function n_radiobutton_strikeout_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_strikeout') then Exit();

  try
    if TFontStyle.fsStrikeOut in TBasRadioButton(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_strikeout: ' + E.Message);
  end;
end;

function p_radiobutton_strikeout_set(var Args: array of TAsmData): TAsmData;
var
  Style: TFontStyles;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_strikeout#') then Exit();

  try
    Style := TBasRadioButton(Args[0].p).TextSettings.Font.Style;
    if Args[1].n <> 0 then
      Style := Style + [TFontStyle.fsStrikeOut]
    else
      Style := Style - [TFontStyle.fsStrikeOut];
    TBasRadioButton(Args[0].p).TextSettings.Font.Style := Style;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_strikeout#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Position and Size Functions
// -----------------------------------------------------------------------------

function n_radiobutton_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_x') then Exit();

  try
    Result.n := TBasRadioButton(Args[0].p).Position.X;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_x: ' + E.Message);
  end;
end;

function p_radiobutton_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_x#') then Exit();

  try
    TBasRadioButton(Args[0].p).Position.X := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_x#: ' + E.Message);
  end;
end;

function n_radiobutton_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_y') then Exit();

  try
    Result.n := TBasRadioButton(Args[0].p).Position.Y;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_y: ' + E.Message);
  end;
end;

function p_radiobutton_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_y#') then Exit();

  try
    TBasRadioButton(Args[0].p).Position.Y := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_y#: ' + E.Message);
  end;
end;

function n_radiobutton_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_width') then Exit();

  try
    Result.n := TBasRadioButton(Args[0].p).Width;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_width: ' + E.Message);
  end;
end;

function p_radiobutton_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_width#') then Exit();

  try
    TBasRadioButton(Args[0].p).Width := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_width#: ' + E.Message);
  end;
end;

function n_radiobutton_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_height') then Exit();

  try
    Result.n := TBasRadioButton(Args[0].p).Height;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_height: ' + E.Message);
  end;
end;

function p_radiobutton_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_height#') then Exit();

  try
    TBasRadioButton(Args[0].p).Height := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_height#: ' + E.Message);
  end;
end;

function p_radiobutton_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_bounds#') then Exit();

  try
    TBasRadioButton(Args[0].p).SetBounds(Args[1].n, Args[2].n, Args[3].n, Args[4].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_bounds#: ' + E.Message);
  end;
end;

function p_radiobutton_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_move#') then Exit();

  try
    TBasRadioButton(Args[0].p).Position.X := Args[1].n;
    TBasRadioButton(Args[0].p).Position.Y := Args[2].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_move#: ' + E.Message);
  end;
end;

function p_radiobutton_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_size#') then Exit();

  try
    TBasRadioButton(Args[0].p).Width := Args[1].n;
    TBasRadioButton(Args[0].p).Height := Args[2].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_size#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Alignment Functions
// -----------------------------------------------------------------------------

function n_radiobutton_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_align') then Exit();

  try
    Result.n := AlignToInt(TBasRadioButton(Args[0].p).Align);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_align: ' + E.Message);
  end;
end;

function p_radiobutton_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_align#') then Exit();

  try
    TBasRadioButton(Args[0].p).Align := AlignFromInt(Round(Args[1].n));
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_align#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Margin Functions
// -----------------------------------------------------------------------------

function n_radiobutton_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_marginleft') then Exit();

  try
    Result.n := TBasRadioButton(Args[0].p).Margins.Left;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_marginleft: ' + E.Message);
  end;
end;

function p_radiobutton_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_marginleft#') then Exit();

  try
    TBasRadioButton(Args[0].p).Margins.Left := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_marginleft#: ' + E.Message);
  end;
end;

function n_radiobutton_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_margintop') then Exit();

  try
    Result.n := TBasRadioButton(Args[0].p).Margins.Top;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_margintop: ' + E.Message);
  end;
end;

function p_radiobutton_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_margintop#') then Exit();

  try
    TBasRadioButton(Args[0].p).Margins.Top := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_margintop#: ' + E.Message);
  end;
end;

function n_radiobutton_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_marginright') then Exit();

  try
    Result.n := TBasRadioButton(Args[0].p).Margins.Right;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_marginright: ' + E.Message);
  end;
end;

function p_radiobutton_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_marginright#') then Exit();

  try
    TBasRadioButton(Args[0].p).Margins.Right := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_marginright#: ' + E.Message);
  end;
end;

function n_radiobutton_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_marginbottom') then Exit();

  try
    Result.n := TBasRadioButton(Args[0].p).Margins.Bottom;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_marginbottom: ' + E.Message);
  end;
end;

function p_radiobutton_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_marginbottom#') then Exit();

  try
    TBasRadioButton(Args[0].p).Margins.Bottom := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_marginbottom#: ' + E.Message);
  end;
end;

function p_radiobutton_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_margins#') then Exit();

  try
    TBasRadioButton(Args[0].p).Margins.Left := Args[1].n;
    TBasRadioButton(Args[0].p).Margins.Top := Args[2].n;
    TBasRadioButton(Args[0].p).Margins.Right := Args[3].n;
    TBasRadioButton(Args[0].p).Margins.Bottom := Args[4].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_margins#: ' + E.Message);
  end;
end;

function p_radiobutton_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_margin#') then Exit();

  try
    TBasRadioButton(Args[0].p).Margins.Left := Args[1].n;
    TBasRadioButton(Args[0].p).Margins.Top := Args[1].n;
    TBasRadioButton(Args[0].p).Margins.Right := Args[1].n;
    TBasRadioButton(Args[0].p).Margins.Bottom := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_margin#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Visibility and State Functions
// -----------------------------------------------------------------------------

function n_radiobutton_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_visible') then Exit();

  try
    if TBasRadioButton(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_visible: ' + E.Message);
  end;
end;

function p_radiobutton_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_visible#') then Exit();

  try
    TBasRadioButton(Args[0].p).Visible := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_visible#: ' + E.Message);
  end;
end;

function n_radiobutton_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_enabled') then Exit();

  try
    if TBasRadioButton(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_enabled: ' + E.Message);
  end;
end;

function p_radiobutton_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_enabled#') then Exit();

  try
    TBasRadioButton(Args[0].p).Enabled := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_enabled#: ' + E.Message);
  end;
end;

function n_radiobutton_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_opacity') then Exit();

  try
    Result.n := TBasRadioButton(Args[0].p).Opacity;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_opacity: ' + E.Message);
  end;
end;

function p_radiobutton_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_opacity#') then Exit();

  try
    TBasRadioButton(Args[0].p).Opacity := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_opacity#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Focus Functions
// -----------------------------------------------------------------------------

function n_radiobutton_isfocused_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_isfocused') then Exit();

  try
    if TBasRadioButton(Args[0].p).IsFocused then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_isfocused: ' + E.Message);
  end;
end;

function p_radiobutton_setfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_setfocus#') then Exit();

  try
    TBasRadioButton(Args[0].p).SetFocus();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_setfocus#: ' + E.Message);
  end;
end;

function p_radiobutton_resetfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_resetfocus#') then Exit();

  try
    TBasRadioButton(Args[0].p).ResetFocus();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_resetfocus#: ' + E.Message);
  end;
end;

function n_radiobutton_taborder_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_taborder') then Exit();

  try
    Result.n := TBasRadioButton(Args[0].p).TabOrder;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_taborder: ' + E.Message);
  end;
end;

function p_radiobutton_taborder_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_taborder#') then Exit();

  try
    TBasRadioButton(Args[0].p).TabOrder := Round(Args[1].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_taborder#: ' + E.Message);
  end;
end;

function n_radiobutton_canfocus_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_canfocus') then Exit();

  try
    if TBasRadioButton(Args[0].p).CanFocus then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_canfocus: ' + E.Message);
  end;
end;

function p_radiobutton_canfocus_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_canfocus#') then Exit();

  try
    TBasRadioButton(Args[0].p).CanFocus := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_canfocus#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Tag Functions
// -----------------------------------------------------------------------------

function n_radiobutton_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_tag') then Exit();

  try
    Result.n := TBasRadioButton(Args[0].p).Tag;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_tag: ' + E.Message);
  end;
end;

function p_radiobutton_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_tag#') then Exit();

  try
    TBasRadioButton(Args[0].p).Tag := Round(Args[1].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_tag#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// HitTest Functions
// -----------------------------------------------------------------------------

function n_radiobutton_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_hittest') then Exit();

  try
    if TBasRadioButton(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_hittest: ' + E.Message);
  end;
end;

function p_radiobutton_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_hittest#') then Exit();

  try
    TBasRadioButton(Args[0].p).HitTest := (Args[1].n <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_hittest#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// DragMode Functions
// -----------------------------------------------------------------------------

function n_radiobutton_dragmode_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_dragmode') then Exit();

  try
    Result.n := Ord(TBasRadioButton(Args[0].p).DragMode);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_dragmode: ' + E.Message);
  end;
end;

function p_radiobutton_dragmode_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_dragmode#') then Exit();

  try
    TBasRadioButton(Args[0].p).DragMode := TDragMode(Round(Args[1].n));
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_dragmode#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Parent Functions
// -----------------------------------------------------------------------------

function p_radiobutton_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_parent#') then Exit();

  try
    Result.p := TBasRadioButton(Args[0].p).Parent;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_parent#: ' + E.Message);
  end;
end;

function p_radiobutton_parent_set(var Args: array of TAsmData): TAsmData;
var
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_parent#') then Exit();
  if not ValidateParent(Args[1].p, 'radiobutton_parent#') then Exit();

  try
    if TObject(Args[1].p) is TCommonCustomForm then
      ParentObj := TCommonCustomForm(Args[1].p)
    else
      ParentObj := TFmxObject(Args[1].p);

    TBasRadioButton(Args[0].p).Parent := ParentObj;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_parent#: ' + E.Message);
  end;
end;

function p_radiobutton_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_bringtofront#') then Exit();

  try
    TBasRadioButton(Args[0].p).BringToFront();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_bringtofront#: ' + E.Message);
  end;
end;

function p_radiobutton_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_sendtoback#') then Exit();

  try
    TBasRadioButton(Args[0].p).SendToBack();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_sendtoback#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Event Callback Functions
// -----------------------------------------------------------------------------

function p_radiobutton_onchange_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onchange#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnChangeFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onchange#: ' + E.Message);
  end;
end;

function s_radiobutton_onchange_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onchange$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnChangeFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onchange$: ' + E.Message);
  end;
end;

function p_radiobutton_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onclick#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnClickFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onclick#: ' + E.Message);
  end;
end;

function s_radiobutton_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onclick$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnClickFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onclick$: ' + E.Message);
  end;
end;

function p_radiobutton_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_ondblclick#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnDblClickFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_ondblclick#: ' + E.Message);
  end;
end;

function s_radiobutton_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_ondblclick$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnDblClickFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_ondblclick$: ' + E.Message);
  end;
end;

function p_radiobutton_onenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onenter#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onenter#: ' + E.Message);
  end;
end;

function s_radiobutton_onenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onenter$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onenter$: ' + E.Message);
  end;
end;

function p_radiobutton_onexit_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onexit#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnExitFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onexit#: ' + E.Message);
  end;
end;

function s_radiobutton_onexit_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onexit$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnExitFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onexit$: ' + E.Message);
  end;
end;

function p_radiobutton_onkeydown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onkeydown#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnKeyDownFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onkeydown#: ' + E.Message);
  end;
end;

function s_radiobutton_onkeydown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onkeydown$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnKeyDownFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onkeydown$: ' + E.Message);
  end;
end;

function p_radiobutton_onkeyup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onkeyup#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnKeyUpFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onkeyup#: ' + E.Message);
  end;
end;

function s_radiobutton_onkeyup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onkeyup$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnKeyUpFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onkeyup$: ' + E.Message);
  end;
end;

function p_radiobutton_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onmousedown#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnMouseDownFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onmousedown#: ' + E.Message);
  end;
end;

function s_radiobutton_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onmousedown$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnMouseDownFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onmousedown$: ' + E.Message);
  end;
end;

function p_radiobutton_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onmouseup#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnMouseUpFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onmouseup#: ' + E.Message);
  end;
end;

function s_radiobutton_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onmouseup$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnMouseUpFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onmouseup$: ' + E.Message);
  end;
end;

function p_radiobutton_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onmousemove#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnMouseMoveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onmousemove#: ' + E.Message);
  end;
end;

function s_radiobutton_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onmousemove$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnMouseMoveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onmousemove$: ' + E.Message);
  end;
end;

function p_radiobutton_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onmouseenter#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnMouseEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onmouseenter#: ' + E.Message);
  end;
end;

function s_radiobutton_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onmouseenter$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnMouseEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onmouseenter$: ' + E.Message);
  end;
end;

function p_radiobutton_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onmouseleave#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnMouseLeaveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onmouseleave#: ' + E.Message);
  end;
end;

function s_radiobutton_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onmouseleave$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnMouseLeaveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onmouseleave$: ' + E.Message);
  end;
end;

function p_radiobutton_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onresize#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnResizeFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onresize#: ' + E.Message);
  end;
end;

function s_radiobutton_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_onresize$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnResizeFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_onresize$: ' + E.Message);
  end;
end;

// Drag & Drop Event Callbacks

function p_radiobutton_ondragenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_ondragenter#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnDragEnterFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_ondragenter#: ' + E.Message);
  end;
end;

function s_radiobutton_ondragenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_ondragenter$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnDragEnterFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_ondragenter$: ' + E.Message);
  end;
end;

function p_radiobutton_ondragover_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_ondragover#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnDragOverFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_ondragover#: ' + E.Message);
  end;
end;

function s_radiobutton_ondragover_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_ondragover$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnDragOverFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_ondragover$: ' + E.Message);
  end;
end;

function p_radiobutton_ondragdrop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_ondragdrop#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnDragDropFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_ondragdrop#: ' + E.Message);
  end;
end;

function s_radiobutton_ondragdrop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_ondragdrop$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnDragDropFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_ondragdrop$: ' + E.Message);
  end;
end;

function p_radiobutton_ondragleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_ondragleave#') then Exit();

  try
    TBasRadioButton(Args[0].p).OnDragLeaveFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_ondragleave#: ' + E.Message);
  end;
end;

function s_radiobutton_ondragleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_ondragleave$') then Exit();

  try
    Result.s := TBasRadioButton(Args[0].p).OnDragLeaveFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_ondragleave$: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Clear Callbacks Function (returns pointer type)
// -----------------------------------------------------------------------------

function p_radiobutton_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRadioButton(Args[0].p, 'radiobutton_clearcallbacks#') then Exit();

  try
    with TBasRadioButton(Args[0].p) do
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
      SetError(ERR_INVALID_RADIOBUTTON, 'radiobutton_clearcallbacks#: ' + E.Message);
  end;
end;

// -----------------------------------------------------------------------------
// Library Registration
// -----------------------------------------------------------------------------

procedure RegisterRadioButtonFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_radiobutton_error; Lib.Add('radiobutton_error@', Fn);
  Fn.Entry := @s_radiobutton_errormsg; Lib.Add('radiobutton_errormsg$@', Fn);
  Fn.Entry := @s_radiobutton_strerror; Lib.Add('radiobutton_strerror$@n', Fn);
  Fn.Entry := @n_radiobutton_clearerror; Lib.Add('radiobutton_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_radiobutton_new; Lib.Add('radiobutton#@#', Fn);
  Fn.Entry := @p_radiobutton_new_text; Lib.Add('radiobutton#@#$', Fn);
  Fn.Entry := @p_radiobutton_new_pos; Lib.Add('radiobutton#@#nnnn', Fn);
  Fn.Entry := @p_radiobutton_new_full; Lib.Add('radiobutton#@#$nnnn', Fn);
  Fn.Entry := @n_radiobutton_free; Lib.Add('radiobutton_free@#', Fn);

  // Checked state
  Fn.Entry := @n_radiobutton_ischecked_get; Lib.Add('radiobutton_ischecked@#', Fn);
  Fn.Entry := @p_radiobutton_ischecked_set; Lib.Add('radiobutton_ischecked#@#n', Fn);

  // GroupName (IMPORTANT for radio button mutual exclusion)
  Fn.Entry := @s_radiobutton_groupname_get; Lib.Add('radiobutton_groupname$@#', Fn);
  Fn.Entry := @p_radiobutton_groupname_set; Lib.Add('radiobutton_groupname#@#$', Fn);

  // Text content
  Fn.Entry := @s_radiobutton_text_get; Lib.Add('radiobutton_text$@#', Fn);
  Fn.Entry := @p_radiobutton_text_set; Lib.Add('radiobutton_text#@#$', Fn);

  // Font properties
  Fn.Entry := @s_radiobutton_fontfamily_get; Lib.Add('radiobutton_fontfamily$@#', Fn);
  Fn.Entry := @p_radiobutton_fontfamily_set; Lib.Add('radiobutton_fontfamily#@#$', Fn);
  Fn.Entry := @n_radiobutton_fontsize_get; Lib.Add('radiobutton_fontsize@#', Fn);
  Fn.Entry := @p_radiobutton_fontsize_set; Lib.Add('radiobutton_fontsize#@#n', Fn);
  Fn.Entry := @s_radiobutton_fontcolor_get; Lib.Add('radiobutton_fontcolor$@#', Fn);
  Fn.Entry := @p_radiobutton_fontcolor_set; Lib.Add('radiobutton_fontcolor#@#$', Fn);
  Fn.Entry := @n_radiobutton_bold_get; Lib.Add('radiobutton_bold@#', Fn);
  Fn.Entry := @p_radiobutton_bold_set; Lib.Add('radiobutton_bold#@#n', Fn);
  Fn.Entry := @n_radiobutton_italic_get; Lib.Add('radiobutton_italic@#', Fn);
  Fn.Entry := @p_radiobutton_italic_set; Lib.Add('radiobutton_italic#@#n', Fn);
  Fn.Entry := @n_radiobutton_underline_get; Lib.Add('radiobutton_underline@#', Fn);
  Fn.Entry := @p_radiobutton_underline_set; Lib.Add('radiobutton_underline#@#n', Fn);
  Fn.Entry := @n_radiobutton_strikeout_get; Lib.Add('radiobutton_strikeout@#', Fn);
  Fn.Entry := @p_radiobutton_strikeout_set; Lib.Add('radiobutton_strikeout#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_radiobutton_x_get; Lib.Add('radiobutton_x@#', Fn);
  Fn.Entry := @p_radiobutton_x_set; Lib.Add('radiobutton_x#@#n', Fn);
  Fn.Entry := @n_radiobutton_y_get; Lib.Add('radiobutton_y@#', Fn);
  Fn.Entry := @p_radiobutton_y_set; Lib.Add('radiobutton_y#@#n', Fn);
  Fn.Entry := @n_radiobutton_width_get; Lib.Add('radiobutton_width@#', Fn);
  Fn.Entry := @p_radiobutton_width_set; Lib.Add('radiobutton_width#@#n', Fn);
  Fn.Entry := @n_radiobutton_height_get; Lib.Add('radiobutton_height@#', Fn);
  Fn.Entry := @p_radiobutton_height_set; Lib.Add('radiobutton_height#@#n', Fn);
  Fn.Entry := @p_radiobutton_bounds_set; Lib.Add('radiobutton_bounds#@#nnnn', Fn);
  Fn.Entry := @p_radiobutton_move_set; Lib.Add('radiobutton_move#@#nn', Fn);
  Fn.Entry := @p_radiobutton_size_set; Lib.Add('radiobutton_size#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_radiobutton_align_get; Lib.Add('radiobutton_align@#', Fn);
  Fn.Entry := @p_radiobutton_align_set; Lib.Add('radiobutton_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_radiobutton_marginleft_get; Lib.Add('radiobutton_marginleft@#', Fn);
  Fn.Entry := @p_radiobutton_marginleft_set; Lib.Add('radiobutton_marginleft#@#n', Fn);
  Fn.Entry := @n_radiobutton_margintop_get; Lib.Add('radiobutton_margintop@#', Fn);
  Fn.Entry := @p_radiobutton_margintop_set; Lib.Add('radiobutton_margintop#@#n', Fn);
  Fn.Entry := @n_radiobutton_marginright_get; Lib.Add('radiobutton_marginright@#', Fn);
  Fn.Entry := @p_radiobutton_marginright_set; Lib.Add('radiobutton_marginright#@#n', Fn);
  Fn.Entry := @n_radiobutton_marginbottom_get; Lib.Add('radiobutton_marginbottom@#', Fn);
  Fn.Entry := @p_radiobutton_marginbottom_set; Lib.Add('radiobutton_marginbottom#@#n', Fn);
  Fn.Entry := @p_radiobutton_margins_set; Lib.Add('radiobutton_margins#@#nnnn', Fn);
  Fn.Entry := @p_radiobutton_margin_set; Lib.Add('radiobutton_margin#@#n', Fn);

  // Visibility and state
  Fn.Entry := @n_radiobutton_visible_get; Lib.Add('radiobutton_visible@#', Fn);
  Fn.Entry := @p_radiobutton_visible_set; Lib.Add('radiobutton_visible#@#n', Fn);
  Fn.Entry := @n_radiobutton_enabled_get; Lib.Add('radiobutton_enabled@#', Fn);
  Fn.Entry := @p_radiobutton_enabled_set; Lib.Add('radiobutton_enabled#@#n', Fn);
  Fn.Entry := @n_radiobutton_opacity_get; Lib.Add('radiobutton_opacity@#', Fn);
  Fn.Entry := @p_radiobutton_opacity_set; Lib.Add('radiobutton_opacity#@#n', Fn);

  // Focus
  Fn.Entry := @n_radiobutton_isfocused_get; Lib.Add('radiobutton_isfocused@#', Fn);
  Fn.Entry := @p_radiobutton_setfocus; Lib.Add('radiobutton_setfocus#@#', Fn);
  Fn.Entry := @p_radiobutton_resetfocus; Lib.Add('radiobutton_resetfocus#@#', Fn);
  Fn.Entry := @n_radiobutton_taborder_get; Lib.Add('radiobutton_taborder@#', Fn);
  Fn.Entry := @p_radiobutton_taborder_set; Lib.Add('radiobutton_taborder#@#n', Fn);
  Fn.Entry := @n_radiobutton_canfocus_get; Lib.Add('radiobutton_canfocus@#', Fn);
  Fn.Entry := @p_radiobutton_canfocus_set; Lib.Add('radiobutton_canfocus#@#n', Fn);

  // Tag
  Fn.Entry := @n_radiobutton_tag_get; Lib.Add('radiobutton_tag@#', Fn);
  Fn.Entry := @p_radiobutton_tag_set; Lib.Add('radiobutton_tag#@#n', Fn);

  // HitTest
  Fn.Entry := @n_radiobutton_hittest_get; Lib.Add('radiobutton_hittest@#', Fn);
  Fn.Entry := @p_radiobutton_hittest_set; Lib.Add('radiobutton_hittest#@#n', Fn);

  // DragMode
  Fn.Entry := @n_radiobutton_dragmode_get; Lib.Add('radiobutton_dragmode@#', Fn);
  Fn.Entry := @p_radiobutton_dragmode_set; Lib.Add('radiobutton_dragmode#@#n', Fn);

  // Parent
  Fn.Entry := @p_radiobutton_parent_get; Lib.Add('radiobutton_parent#@#', Fn);
  Fn.Entry := @p_radiobutton_parent_set; Lib.Add('radiobutton_parent#@##', Fn);
  Fn.Entry := @p_radiobutton_bringtofront; Lib.Add('radiobutton_bringtofront#@#', Fn);
  Fn.Entry := @p_radiobutton_sendtoback; Lib.Add('radiobutton_sendtoback#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_radiobutton_onchange_set; Lib.Add('radiobutton_onchange#@#$', Fn);
  Fn.Entry := @s_radiobutton_onchange_get; Lib.Add('radiobutton_onchange$@#', Fn);
  Fn.Entry := @p_radiobutton_onclick_set; Lib.Add('radiobutton_onclick#@#$', Fn);
  Fn.Entry := @s_radiobutton_onclick_get; Lib.Add('radiobutton_onclick$@#', Fn);
  Fn.Entry := @p_radiobutton_ondblclick_set; Lib.Add('radiobutton_ondblclick#@#$', Fn);
  Fn.Entry := @s_radiobutton_ondblclick_get; Lib.Add('radiobutton_ondblclick$@#', Fn);
  Fn.Entry := @p_radiobutton_onenter_set; Lib.Add('radiobutton_onenter#@#$', Fn);
  Fn.Entry := @s_radiobutton_onenter_get; Lib.Add('radiobutton_onenter$@#', Fn);
  Fn.Entry := @p_radiobutton_onexit_set; Lib.Add('radiobutton_onexit#@#$', Fn);
  Fn.Entry := @s_radiobutton_onexit_get; Lib.Add('radiobutton_onexit$@#', Fn);
  Fn.Entry := @p_radiobutton_onkeydown_set; Lib.Add('radiobutton_onkeydown#@#$', Fn);
  Fn.Entry := @s_radiobutton_onkeydown_get; Lib.Add('radiobutton_onkeydown$@#', Fn);
  Fn.Entry := @p_radiobutton_onkeyup_set; Lib.Add('radiobutton_onkeyup#@#$', Fn);
  Fn.Entry := @s_radiobutton_onkeyup_get; Lib.Add('radiobutton_onkeyup$@#', Fn);
  Fn.Entry := @p_radiobutton_onmousedown_set; Lib.Add('radiobutton_onmousedown#@#$', Fn);
  Fn.Entry := @s_radiobutton_onmousedown_get; Lib.Add('radiobutton_onmousedown$@#', Fn);
  Fn.Entry := @p_radiobutton_onmouseup_set; Lib.Add('radiobutton_onmouseup#@#$', Fn);
  Fn.Entry := @s_radiobutton_onmouseup_get; Lib.Add('radiobutton_onmouseup$@#', Fn);
  Fn.Entry := @p_radiobutton_onmousemove_set; Lib.Add('radiobutton_onmousemove#@#$', Fn);
  Fn.Entry := @s_radiobutton_onmousemove_get; Lib.Add('radiobutton_onmousemove$@#', Fn);
  Fn.Entry := @p_radiobutton_onmouseenter_set; Lib.Add('radiobutton_onmouseenter#@#$', Fn);
  Fn.Entry := @s_radiobutton_onmouseenter_get; Lib.Add('radiobutton_onmouseenter$@#', Fn);
  Fn.Entry := @p_radiobutton_onmouseleave_set; Lib.Add('radiobutton_onmouseleave#@#$', Fn);
  Fn.Entry := @s_radiobutton_onmouseleave_get; Lib.Add('radiobutton_onmouseleave$@#', Fn);
  Fn.Entry := @p_radiobutton_onresize_set; Lib.Add('radiobutton_onresize#@#$', Fn);
  Fn.Entry := @s_radiobutton_onresize_get; Lib.Add('radiobutton_onresize$@#', Fn);

  // Drag & Drop event callbacks
  Fn.Entry := @p_radiobutton_ondragenter_set; Lib.Add('radiobutton_ondragenter#@#$', Fn);
  Fn.Entry := @s_radiobutton_ondragenter_get; Lib.Add('radiobutton_ondragenter$@#', Fn);
  Fn.Entry := @p_radiobutton_ondragover_set; Lib.Add('radiobutton_ondragover#@#$', Fn);
  Fn.Entry := @s_radiobutton_ondragover_get; Lib.Add('radiobutton_ondragover$@#', Fn);
  Fn.Entry := @p_radiobutton_ondragdrop_set; Lib.Add('radiobutton_ondragdrop#@#$', Fn);
  Fn.Entry := @s_radiobutton_ondragdrop_get; Lib.Add('radiobutton_ondragdrop$@#', Fn);
  Fn.Entry := @p_radiobutton_ondragleave_set; Lib.Add('radiobutton_ondragleave#@#$', Fn);
  Fn.Entry := @s_radiobutton_ondragleave_get; Lib.Add('radiobutton_ondragleave$@#', Fn);

  // Clear callbacks (returns pointer type)
  Fn.Entry := @p_radiobutton_clearcallbacks; Lib.Add('radiobutton_clearcallbacks#@#', Fn);
end;

end.

