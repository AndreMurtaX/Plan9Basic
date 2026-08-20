unit ComboBoxLib;

{******************************************************************************
  ComboBoxLib - ComboBox Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TComboBox wrapper functionality for creating
  and managing dropdown list controls in Plan9Basic programs.

  Function Count: 105+ functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  EVENT CONNECTION MODEL:
  =======================
  Events are connected/disconnected individually when callbacks are set:
  - Setting a non-empty callback name connects ONLY that specific event
  - Setting an empty callback name ("") disconnects ONLY that specific event
  - No events are connected by default in the constructor

  EVENTS SUPPORT:
  ===============
  - OnChange: Selection changed (primary combobox event)
  - OnClick: ComboBox was clicked
  - OnDblClick: ComboBox was double-clicked
  - OnEnter: ComboBox received focus
  - OnExit: ComboBox lost focus
  - OnKeyDown: Key was pressed while focused
  - OnKeyUp: Key was released while focused
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over control
  - OnMouseEnter: Mouse entered control area
  - OnMouseLeave: Mouse left control area
  - OnResize: Control is being resized
  - OnDragEnter: Drag operation entered control
  - OnDragOver: Drag operation over control (return non-zero to accept)
  - OnDragDrop: Item was dropped on control
  - OnDragLeave: Drag operation left control

  USAGE PATTERN:
  ==============
    let frm# = form#("ComboBox Demo", 400, 300)
    
    let cb# = combobox#(frm#)
    combobox_move#(cb#, 50, 50)
    combobox_size#(cb#, 200, 25)
    combobox_add(cb#, "Option 1")
    combobox_add(cb#, "Option 2")
    combobox_add(cb#, "Option 3")
    combobox_itemindex#(cb#, 0)
    combobox_onchange#(cb#, "OnComboChange")
    
    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnComboChange(sender#) local idx
      idx = combobox_itemindex(sender#)
      println "Selected index: " + str$(idx)
      println "Selected item: " + combobox_item$(sender#, idx)
    endfunction

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.ListBox,
  FMX.Controls.Presentation, FMX.Text,
  basic, exec, UnitGC, HandleRegistry, ControlCommon;

type
  TBasComboBox = class(TComboBox)
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
    FSuppressCallbacks: Boolean;

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
    property SuppressCallbacks: Boolean read FSuppressCallbacks write FSuppressCallbacks;
  end;

procedure RegisterComboBoxFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  COMBOBOX_GC_TAG = 'BASIC_COMBOBOX';
  ERR_NONE = 0;
  ERR_INVALID_COMBOBOX = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INDEX_OUT_OF_RANGE = 5;


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

function ValidateComboBox(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_COMBOBOX, FuncName + ': Nil pointer');
    Exit();
  end;

  try
    if not(IsHandleOf(P, TBasComboBox)) then
    begin
      SetError(ERR_INVALID_COMBOBOX, FuncName + ': Invalid object');
      Exit();
    end;
  except
    SetError(ERR_INVALID_COMBOBOX, FuncName + ': Invalid pointer');
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

{ TBasComboBox }

constructor TBasComboBox.Create(AOwner: TComponent);
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
  FSuppressCallbacks := False;
end;

destructor TBasComboBox.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasComboBox.DisconnectAllEvents();
begin
  Self.OnChange := nil;
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
  Self.OnDragEnter := nil;
  Self.OnDragOver := nil;
  Self.OnDragDrop := nil;
  Self.OnDragLeave := nil;
end;

procedure TBasComboBox.SetOnChangeFunc(const Value: String);
begin
  FOnChangeFunc := Value;
  if Value <> '' then Self.OnChange := InternalOnChange
  else Self.OnChange := nil;
end;

procedure TBasComboBox.SetOnClickFunc(const Value: String);
begin
  ControlCommon.BindClick(Self, Value, FOnClickFunc, InternalOnClick);
end;

procedure TBasComboBox.SetOnDblClickFunc(const Value: String);
begin
  ControlCommon.BindDblClick(Self, Value, FOnDblClickFunc, InternalOnDblClick);
end;

procedure TBasComboBox.SetOnEnterFunc(const Value: String);
begin
  ControlCommon.BindEnter(Self, Value, FOnEnterFunc, InternalOnEnter);
end;

procedure TBasComboBox.SetOnExitFunc(const Value: String);
begin
  ControlCommon.BindExit(Self, Value, FOnExitFunc, InternalOnExit);
end;

procedure TBasComboBox.SetOnKeyDownFunc(const Value: String);
begin
  ControlCommon.BindKeyDown(Self, Value, FOnKeyDownFunc, InternalOnKeyDown);
end;

procedure TBasComboBox.SetOnKeyUpFunc(const Value: String);
begin
  ControlCommon.BindKeyUp(Self, Value, FOnKeyUpFunc, InternalOnKeyUp);
end;

procedure TBasComboBox.SetOnMouseDownFunc(const Value: String);
begin
  ControlCommon.BindMouseDown(Self, Value, FOnMouseDownFunc, InternalOnMouseDown);
end;

procedure TBasComboBox.SetOnMouseUpFunc(const Value: String);
begin
  ControlCommon.BindMouseUp(Self, Value, FOnMouseUpFunc, InternalOnMouseUp);
end;

procedure TBasComboBox.SetOnMouseMoveFunc(const Value: String);
begin
  ControlCommon.BindMouseMove(Self, Value, FOnMouseMoveFunc, InternalOnMouseMove);
end;

procedure TBasComboBox.SetOnMouseEnterFunc(const Value: String);
begin
  ControlCommon.BindMouseEnter(Self, Value, FOnMouseEnterFunc, InternalOnMouseEnter);
end;

procedure TBasComboBox.SetOnMouseLeaveFunc(const Value: String);
begin
  ControlCommon.BindMouseLeave(Self, Value, FOnMouseLeaveFunc, InternalOnMouseLeave);
end;

procedure TBasComboBox.SetOnResizeFunc(const Value: String);
begin
  ControlCommon.BindResize(Self, Value, FOnResizeFunc, InternalOnResize);
end;

procedure TBasComboBox.SetOnDragEnterFunc(const Value: String);
begin
  ControlCommon.BindDragEnter(Self, Value, FOnDragEnterFunc, InternalOnDragEnter);
end;

procedure TBasComboBox.SetOnDragOverFunc(const Value: String);
begin
  ControlCommon.BindDragOver(Self, Value, FOnDragOverFunc, InternalOnDragOver);
end;

procedure TBasComboBox.SetOnDragDropFunc(const Value: String);
begin
  ControlCommon.BindDragDrop(Self, Value, FOnDragDropFunc, InternalOnDragDrop);
end;

procedure TBasComboBox.SetOnDragLeaveFunc(const Value: String);
begin
  ControlCommon.BindDragLeave(Self, Value, FOnDragLeaveFunc, InternalOnDragLeave);
end;

procedure TBasComboBox.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'ComboBox');
end;

function TBasComboBox.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
begin
  Result := ControlCommon.RunCallbackWithResult(FBasicEngine, FConsoleOutput,
                          FuncSignature, Args, 'ComboBox');
end;

procedure TBasComboBox.InternalOnChange(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnChangeFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnChangeFunc) + '@#', Args);
end;

procedure TBasComboBox.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnClickFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnClickFunc) + '@#', Args);
end;

procedure TBasComboBox.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDblClickFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDblClickFunc) + '@#', Args);
end;

procedure TBasComboBox.InternalOnEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnEnterFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnEnterFunc) + '@#', Args);
end;

procedure TBasComboBox.InternalOnExit(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnExitFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnExitFunc) + '@#', Args);
end;

procedure TBasComboBox.InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnKeyDownFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Key;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := 0;
  Args[2].p := nil;
  Args[2].s := KeyChar;
  Args[3].n := 0;
  Args[3].p := nil;
  Args[3].s := BuildShiftString(Shift);
  ExecuteCallback(LowerCase(FOnKeyDownFunc) + '@#n$$', Args);
end;

procedure TBasComboBox.InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnKeyUpFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Key;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := 0;
  Args[2].p := nil;
  Args[2].s := KeyChar;
  Args[3].n := 0;
  Args[3].p := nil;
  Args[3].s := BuildShiftString(Shift);
  ExecuteCallback(LowerCase(FOnKeyUpFunc) + '@#n$$', Args);
end;

procedure TBasComboBox.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseDownFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := MouseButtonToInt(Button);
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := X;
  Args[2].p := nil;
  Args[2].s := '';
  Args[3].n := Y;
  Args[3].p := nil;
  Args[3].s := '';
  Args[4].n := 0;
  Args[4].p := nil;
  Args[4].s := BuildShiftString(Shift);
  ExecuteCallback(LowerCase(FOnMouseDownFunc) + '@#nnn$', Args);
end;

procedure TBasComboBox.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseUpFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := MouseButtonToInt(Button);
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := X;
  Args[2].p := nil;
  Args[2].s := '';
  Args[3].n := Y;
  Args[3].p := nil;
  Args[3].s := '';
  Args[4].n := 0;
  Args[4].p := nil;
  Args[4].s := BuildShiftString(Shift);
  ExecuteCallback(LowerCase(FOnMouseUpFunc) + '@#nnn$', Args);
end;

procedure TBasComboBox.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnMouseMoveFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := X;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Y;
  Args[2].p := nil;
  Args[2].s := '';
  Args[3].n := 0;
  Args[3].p := nil;
  Args[3].s := BuildShiftString(Shift);
  ExecuteCallback(LowerCase(FOnMouseMoveFunc) + '@#nn$', Args);
end;

procedure TBasComboBox.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseEnterFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseEnterFunc) + '@#', Args);
end;

procedure TBasComboBox.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseLeaveFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseLeaveFunc) + '@#', Args);
end;

procedure TBasComboBox.InternalOnResize(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizeFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizeFunc) + '@#', Args);
end;

procedure TBasComboBox.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragEnterFunc = '' then Exit();
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

procedure TBasComboBox.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
var
  Args: array[0..2] of TAsmData;
  RetVal: TAsmData;
begin
  if FOnDragOverFunc = '' then Exit();
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

procedure TBasComboBox.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragDropFunc = '' then Exit();
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

procedure TBasComboBox.InternalOnDragLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDragLeaveFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDragLeaveFunc) + '@#', Args);
end;

{ Library Functions }

// Error Functions
function n_combobox_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

function s_combobox_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

function s_combobox_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Trunc(Args[0].n) of
    0: Result.s := 'No error';
    1: Result.s := 'Invalid combobox';
    2: Result.s := 'Invalid parent';
    3: Result.s := 'Invalid value';
    4: Result.s := 'Create failed';
    5: Result.s := 'Index out of range';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_combobox_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  ClearError();
end;

// Creation Functions
function p_combobox_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  CB: TBasComboBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'combobox#') then Exit();

  try
    CB := TBasComboBox.Create(nil);
    CB.Parent := TFmxObject(Args[0].p);
    CB.Position.X := 0;
    CB.Position.Y := 0;
    CB.Width := 150;
    CB.Height := 22;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(CB, Eng, Outp) then
    begin
      CB.BasicEngine := Eng;
      CB.ConsoleOutput := Outp;
    end;

    Result.p := Pointer(CB);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(CB, COMBOBOX_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));
    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'combobox#: ' + E.Message);
  end;
end;

function p_combobox_new_pos(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  CB: TBasComboBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'combobox#') then Exit();

  try
    CB := TBasComboBox.Create(nil);
    CB.Parent := TFmxObject(Args[0].p);
    CB.Position.X := Args[1].n;
    CB.Position.Y := Args[2].n;
    CB.Width := Args[3].n;
    CB.Height := Args[4].n;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(CB, Eng, Outp) then
    begin
      CB.BasicEngine := Eng;
      CB.ConsoleOutput := Outp;
    end;

    Result.p := Pointer(CB);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(CB, COMBOBOX_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));
    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'combobox#: ' + E.Message);
  end;
end;

function n_combobox_free(var Args: array of TAsmData): TAsmData;
var
  CB: TBasComboBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateComboBox(Args[0].p, 'combobox_free') then Exit();

  try
    CB := TBasComboBox(Args[0].p);
    CB.DisconnectAllEvents();
    CB.Free();

    // Free via GC using individualized tag
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(COMBOBOX_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;
    ClearError();
    //Its eighty-one siblings answer 1 on success. This one did too, inside
    //the collector block that was commented out.
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_COMBOBOX, 'combobox_free: ' + E.Message);
  end;
end;

// Items management
function n_combobox_add(var Args: array of TAsmData): TAsmData;
var
  CB: TBasComboBox;
  Item: TListBoxItem;
begin
  Result.n := -1;
  Result.p := nil;
  Result.s := '';

  if not ValidateComboBox(Args[0].p, 'combobox_add') then Exit();

  try
    CB := TBasComboBox(Args[0].p);
    Item := TListBoxItem.Create(CB);
    Item.Parent := CB;
    Item.Text := Args[1].s;
    Result.n := CB.Count - 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'combobox_add: ' + E.Message);
  end;
end;

function n_combobox_insert(var Args: array of TAsmData): TAsmData;
var
  CB: TBasComboBox;
  Item: TListBoxItem;
  Idx: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateComboBox(Args[0].p, 'combobox_insert') then Exit();

  try
    CB := TBasComboBox(Args[0].p);
    Idx := Trunc(Args[1].n);
    if (Idx < 0) or (Idx > CB.Count) then
    begin
      SetError(ERR_INDEX_OUT_OF_RANGE, 'combobox_insert: Index out of range');
      Exit();
    end;
    Item := TListBoxItem.Create(CB);
    Item.Text := Args[2].s;
    CB.InsertObject(Idx, Item);
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'combobox_insert: ' + E.Message);
  end;
end;

function n_combobox_delete(var Args: array of TAsmData): TAsmData;
var
  CB: TBasComboBox;
  Idx: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateComboBox(Args[0].p, 'combobox_delete') then Exit();

  try
    CB := TBasComboBox(Args[0].p);
    Idx := Trunc(Args[1].n);
    if (Idx < 0) or (Idx >= CB.Count) then
    begin
      SetError(ERR_INDEX_OUT_OF_RANGE, 'combobox_delete: Index out of range');
      Exit();
    end;
    // Use TStrings.Delete - simple and direct
    CB.Items.Delete(Idx);
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'combobox_delete: ' + E.Message);
  end;
end;

function n_combobox_clear(var Args: array of TAsmData): TAsmData;
var
  CB: TBasComboBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateComboBox(Args[0].p, 'combobox_clear') then Exit();

  try
    CB := TBasComboBox(Args[0].p);
    CB.Items.Clear;
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'combobox_clear: ' + E.Message);
  end;
end;

function n_combobox_count(var Args: array of TAsmData): TAsmData;
var
  CB: TBasComboBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateComboBox(Args[0].p, 'combobox_count') then Exit();

  try
    CB := TBasComboBox(Args[0].p);
    Result.n := CB.Count;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_COMBOBOX, 'combobox_count: ' + E.Message);
  end;
end;

function s_combobox_item_get(var Args: array of TAsmData): TAsmData;
var
  CB: TBasComboBox;
  Idx: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateComboBox(Args[0].p, 'combobox_item$') then Exit();

  try
    CB := TBasComboBox(Args[0].p);
    Idx := Trunc(Args[1].n);
    if (Idx < 0) or (Idx >= CB.Items.Count) then
    begin
      SetError(ERR_INDEX_OUT_OF_RANGE, 'combobox_item$: Index out of range');
      Exit();
    end;
    Result.s := CB.Items[Idx];
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'combobox_item$: ' + E.Message);
  end;
end;

function p_combobox_item_set(var Args: array of TAsmData): TAsmData;
var
  CB: TBasComboBox;
  Idx: Integer;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateComboBox(Args[0].p, 'combobox_item#') then Exit();

  try
    CB := TBasComboBox(Args[0].p);
    Idx := Trunc(Args[1].n);
    if (Idx < 0) or (Idx >= CB.Items.Count) then
    begin
      SetError(ERR_INDEX_OUT_OF_RANGE, 'combobox_item#: Index out of range');
      Exit();
    end;
    CB.Items[Idx] := Args[2].s;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'combobox_item#: ' + E.Message);
  end;
end;

// ItemIndex
function n_combobox_itemindex_get(var Args: array of TAsmData): TAsmData;
var
  CB: TBasComboBox;
begin
  Result.n := -1;
  Result.p := nil;
  Result.s := '';

  if not ValidateComboBox(Args[0].p, 'combobox_itemindex') then Exit();

  try
    CB := TBasComboBox(Args[0].p);
    Result.n := CB.ItemIndex;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_COMBOBOX, 'combobox_itemindex: ' + E.Message);
  end;
end;

function p_combobox_itemindex_set(var Args: array of TAsmData): TAsmData;
var
  CB: TBasComboBox;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateComboBox(Args[0].p, 'combobox_itemindex#') then Exit();

  try
    CB := TBasComboBox(Args[0].p);
    CB.ItemIndex := Trunc(Args[1].n);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'combobox_itemindex#: ' + E.Message);
  end;
end;

// Selected text (convenience function)
function s_combobox_selected(var Args: array of TAsmData): TAsmData;
var
  CB: TBasComboBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateComboBox(Args[0].p, 'combobox_selected$') then Exit();

  try
    CB := TBasComboBox(Args[0].p);
    if (CB.ItemIndex >= 0) and (CB.ItemIndex < CB.Items.Count) then
      Result.s := CB.Items[CB.ItemIndex];
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_COMBOBOX, 'combobox_selected$: ' + E.Message);
  end;
end;

// Find item by text
function n_combobox_indexof(var Args: array of TAsmData): TAsmData;
var
  CB: TBasComboBox;
begin
  Result.n := -1;
  Result.p := nil;
  Result.s := '';

  if not ValidateComboBox(Args[0].p, 'combobox_indexof') then Exit();

  try
    CB := TBasComboBox(Args[0].p);
    Result.n := CB.Items.IndexOf(Args[1].s);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'combobox_indexof: ' + E.Message);
  end;
end;

// Position and Size
function n_combobox_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_x') then Exit();
  Result.n := TBasComboBox(Args[0].p).Position.X;
  ClearError();
end;

function p_combobox_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_x#') then Exit();
  TBasComboBox(Args[0].p).Position.X := Args[1].n;
  ClearError();
end;

function n_combobox_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_y') then Exit();
  Result.n := TBasComboBox(Args[0].p).Position.Y;
  ClearError();
end;

function p_combobox_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_y#') then Exit();
  TBasComboBox(Args[0].p).Position.Y := Args[1].n;
  ClearError();
end;

function n_combobox_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_width') then Exit();
  Result.n := TBasComboBox(Args[0].p).Width;
  ClearError();
end;

function p_combobox_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_width#') then Exit();
  TBasComboBox(Args[0].p).Width := Args[1].n;
  ClearError();
end;

function n_combobox_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_height') then Exit();
  Result.n := TBasComboBox(Args[0].p).Height;
  ClearError();
end;

function p_combobox_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_height#') then Exit();
  TBasComboBox(Args[0].p).Height := Args[1].n;
  ClearError();
end;

function p_combobox_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_bounds#') then Exit();
  with TBasComboBox(Args[0].p) do
  begin
    Position.X := Args[1].n;
    Position.Y := Args[2].n;
    Width := Args[3].n;
    Height := Args[4].n;
  end;
  ClearError();
end;

function p_combobox_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_move#') then Exit();
  with TBasComboBox(Args[0].p) do
  begin
    Position.X := Args[1].n;
    Position.Y := Args[2].n;
  end;
  ClearError();
end;

function p_combobox_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_size#') then Exit();
  with TBasComboBox(Args[0].p) do
  begin
    Width := Args[1].n;
    Height := Args[2].n;
  end;
  ClearError();
end;

// Alignment
function n_combobox_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_align') then Exit();
  Result.n := AlignToInt(TBasComboBox(Args[0].p).Align);
  ClearError();
end;

function p_combobox_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_align#') then Exit();
  TBasComboBox(Args[0].p).Align := AlignFromInt(Trunc(Args[1].n));
  ClearError();
end;

// Margins
function n_combobox_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_marginleft') then Exit();
  Result.n := TBasComboBox(Args[0].p).Margins.Left;
  ClearError();
end;

function p_combobox_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_marginleft#') then Exit();
  TBasComboBox(Args[0].p).Margins.Left := Args[1].n;
  ClearError();
end;

function n_combobox_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_margintop') then Exit();
  Result.n := TBasComboBox(Args[0].p).Margins.Top;
  ClearError();
end;

function p_combobox_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_margintop#') then Exit();
  TBasComboBox(Args[0].p).Margins.Top := Args[1].n;
  ClearError();
end;

function n_combobox_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_marginright') then Exit();
  Result.n := TBasComboBox(Args[0].p).Margins.Right;
  ClearError();
end;

function p_combobox_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_marginright#') then Exit();
  TBasComboBox(Args[0].p).Margins.Right := Args[1].n;
  ClearError();
end;

function n_combobox_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_marginbottom') then Exit();
  Result.n := TBasComboBox(Args[0].p).Margins.Bottom;
  ClearError();
end;

function p_combobox_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_marginbottom#') then Exit();
  TBasComboBox(Args[0].p).Margins.Bottom := Args[1].n;
  ClearError();
end;

function p_combobox_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_margins#') then Exit();
  with TBasComboBox(Args[0].p).Margins do
  begin
    Left := Args[1].n;
    Top := Args[2].n;
    Right := Args[3].n;
    Bottom := Args[4].n;
  end;
  ClearError();
end;

function p_combobox_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_margin#') then Exit();
  with TBasComboBox(Args[0].p).Margins do
  begin
    Left := Args[1].n;
    Top := Args[1].n;
    Right := Args[1].n;
    Bottom := Args[1].n;
  end;
  ClearError();
end;

// Visibility and state
function n_combobox_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_visible') then Exit();
  if TBasComboBox(Args[0].p).Visible then Result.n := 1 else Result.n := 0;
  ClearError();
end;

function p_combobox_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_visible#') then Exit();
  TBasComboBox(Args[0].p).Visible := (Args[1].n <> 0);
  ClearError();
end;

function n_combobox_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_enabled') then Exit();
  if TBasComboBox(Args[0].p).Enabled then Result.n := 1 else Result.n := 0;
  ClearError();
end;

function p_combobox_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_enabled#') then Exit();
  TBasComboBox(Args[0].p).Enabled := (Args[1].n <> 0);
  ClearError();
end;

function n_combobox_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_opacity') then Exit();
  Result.n := TBasComboBox(Args[0].p).Opacity;
  ClearError();
end;

function p_combobox_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_opacity#') then Exit();
  TBasComboBox(Args[0].p).Opacity := Args[1].n;
  ClearError();
end;

// Focus
function n_combobox_isfocused_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_isfocused') then Exit();
  if TBasComboBox(Args[0].p).IsFocused then Result.n := 1 else Result.n := 0;
  ClearError();
end;

function p_combobox_setfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_setfocus#') then Exit();
  TBasComboBox(Args[0].p).SetFocus;
  ClearError();
end;

function p_combobox_resetfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_resetfocus#') then Exit();
  TBasComboBox(Args[0].p).ResetFocus;
  ClearError();
end;

function n_combobox_taborder_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_taborder') then Exit();
  Result.n := TBasComboBox(Args[0].p).TabOrder;
  ClearError();
end;

function p_combobox_taborder_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_taborder#') then Exit();
  TBasComboBox(Args[0].p).TabOrder := Trunc(Args[1].n);
  ClearError();
end;

function n_combobox_canfocus_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_canfocus') then Exit();
  if TBasComboBox(Args[0].p).CanFocus then Result.n := 1 else Result.n := 0;
  ClearError();
end;

function p_combobox_canfocus_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_canfocus#') then Exit();
  TBasComboBox(Args[0].p).CanFocus := (Args[1].n <> 0);
  ClearError();
end;

// Tag
function n_combobox_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_tag') then Exit();
  Result.n := TBasComboBox(Args[0].p).Tag;
  ClearError();
end;

function p_combobox_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_tag#') then Exit();
  TBasComboBox(Args[0].p).Tag := Trunc(Args[1].n);
  ClearError();
end;

// HitTest
function n_combobox_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_hittest') then Exit();
  if TBasComboBox(Args[0].p).HitTest then Result.n := 1 else Result.n := 0;
  ClearError();
end;

function p_combobox_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_hittest#') then Exit();
  TBasComboBox(Args[0].p).HitTest := (Args[1].n <> 0);
  ClearError();
end;

// DragMode
function n_combobox_dragmode_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_dragmode') then Exit();
  Result.n := Ord(TBasComboBox(Args[0].p).DragMode);
  ClearError();
end;

function p_combobox_dragmode_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_dragmode#') then Exit();
  TBasComboBox(Args[0].p).DragMode := TDragMode(Trunc(Args[1].n));
  ClearError();
end;

// Parent
function p_combobox_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_parent#') then Exit();
  Result.p := Pointer(TBasComboBox(Args[0].p).Parent);
  ClearError();
end;

function p_combobox_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_parent#') then Exit();
  if not ValidateParent(Args[1].p, 'combobox_parent#') then Exit();
  TBasComboBox(Args[0].p).Parent := TFmxObject(Args[1].p);
  ClearError();
end;

function p_combobox_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_bringtofront#') then Exit();
  TBasComboBox(Args[0].p).BringToFront;
  ClearError();
end;

function p_combobox_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_sendtoback#') then Exit();
  TBasComboBox(Args[0].p).SendToBack;
  ClearError();
end;

// DropDownCount
function n_combobox_dropdowncount_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_dropdowncount') then Exit();
  Result.n := TBasComboBox(Args[0].p).DropDownCount;
  ClearError();
end;

function p_combobox_dropdowncount_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_dropdowncount#') then Exit();
  TBasComboBox(Args[0].p).DropDownCount := Trunc(Args[1].n);
  ClearError();
end;

// Event callbacks
function p_combobox_onchange_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onchange#') then Exit();
  TBasComboBox(Args[0].p).OnChangeFunc := Args[1].s;
  ClearError();
end;

function s_combobox_onchange_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onchange$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnChangeFunc;
  ClearError();
end;

function p_combobox_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onclick#') then Exit();
  TBasComboBox(Args[0].p).OnClickFunc := Args[1].s;
  ClearError();
end;

function s_combobox_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onclick$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnClickFunc;
  ClearError();
end;

function p_combobox_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_ondblclick#') then Exit();
  TBasComboBox(Args[0].p).OnDblClickFunc := Args[1].s;
  ClearError();
end;

function s_combobox_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_ondblclick$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnDblClickFunc;
  ClearError();
end;

function p_combobox_onenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onenter#') then Exit();
  TBasComboBox(Args[0].p).OnEnterFunc := Args[1].s;
  ClearError();
end;

function s_combobox_onenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onenter$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnEnterFunc;
  ClearError();
end;

function p_combobox_onexit_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onexit#') then Exit();
  TBasComboBox(Args[0].p).OnExitFunc := Args[1].s;
  ClearError();
end;

function s_combobox_onexit_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onexit$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnExitFunc;
  ClearError();
end;

function p_combobox_onkeydown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onkeydown#') then Exit();
  TBasComboBox(Args[0].p).OnKeyDownFunc := Args[1].s;
  ClearError();
end;

function s_combobox_onkeydown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onkeydown$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnKeyDownFunc;
  ClearError();
end;

function p_combobox_onkeyup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onkeyup#') then Exit();
  TBasComboBox(Args[0].p).OnKeyUpFunc := Args[1].s;
  ClearError();
end;

function s_combobox_onkeyup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onkeyup$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnKeyUpFunc;
  ClearError();
end;

function p_combobox_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onmousedown#') then Exit();
  TBasComboBox(Args[0].p).OnMouseDownFunc := Args[1].s;
  ClearError();
end;

function s_combobox_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onmousedown$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnMouseDownFunc;
  ClearError();
end;

function p_combobox_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onmouseup#') then Exit();
  TBasComboBox(Args[0].p).OnMouseUpFunc := Args[1].s;
  ClearError();
end;

function s_combobox_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onmouseup$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnMouseUpFunc;
  ClearError();
end;

function p_combobox_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onmousemove#') then Exit();
  TBasComboBox(Args[0].p).OnMouseMoveFunc := Args[1].s;
  ClearError();
end;

function s_combobox_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onmousemove$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnMouseMoveFunc;
  ClearError();
end;

function p_combobox_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onmouseenter#') then Exit();
  TBasComboBox(Args[0].p).OnMouseEnterFunc := Args[1].s;
  ClearError();
end;

function s_combobox_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onmouseenter$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnMouseEnterFunc;
  ClearError();
end;

function p_combobox_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onmouseleave#') then Exit();
  TBasComboBox(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  ClearError();
end;

function s_combobox_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onmouseleave$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnMouseLeaveFunc;
  ClearError();
end;

function p_combobox_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onresize#') then Exit();
  TBasComboBox(Args[0].p).OnResizeFunc := Args[1].s;
  ClearError();
end;

function s_combobox_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_onresize$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnResizeFunc;
  ClearError();
end;

// Drag & Drop event callbacks
function p_combobox_ondragenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_ondragenter#') then Exit();
  TBasComboBox(Args[0].p).OnDragEnterFunc := Args[1].s;
  ClearError();
end;

function s_combobox_ondragenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_ondragenter$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnDragEnterFunc;
  ClearError();
end;

function p_combobox_ondragover_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_ondragover#') then Exit();
  TBasComboBox(Args[0].p).OnDragOverFunc := Args[1].s;
  ClearError();
end;

function s_combobox_ondragover_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_ondragover$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnDragOverFunc;
  ClearError();
end;

function p_combobox_ondragdrop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_ondragdrop#') then Exit();
  TBasComboBox(Args[0].p).OnDragDropFunc := Args[1].s;
  ClearError();
end;

function s_combobox_ondragdrop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_ondragdrop$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnDragDropFunc;
  ClearError();
end;

function p_combobox_ondragleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_ondragleave#') then Exit();
  TBasComboBox(Args[0].p).OnDragLeaveFunc := Args[1].s;
  ClearError();
end;

function s_combobox_ondragleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateComboBox(Args[0].p, 'combobox_ondragleave$') then Exit();
  Result.s := TBasComboBox(Args[0].p).OnDragLeaveFunc;
  ClearError();
end;

// Clear callbacks
function p_combobox_clearcallbacks(var Args: array of TAsmData): TAsmData;
var
  CB: TBasComboBox;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateComboBox(Args[0].p, 'combobox_clearcallbacks') then Exit();

  CB := TBasComboBox(Args[0].p);
  CB.OnChangeFunc := '';
  CB.OnClickFunc := '';
  CB.OnDblClickFunc := '';
  CB.OnEnterFunc := '';
  CB.OnExitFunc := '';
  CB.OnKeyDownFunc := '';
  CB.OnKeyUpFunc := '';
  CB.OnMouseDownFunc := '';
  CB.OnMouseUpFunc := '';
  CB.OnMouseMoveFunc := '';
  CB.OnMouseEnterFunc := '';
  CB.OnMouseLeaveFunc := '';
  CB.OnResizeFunc := '';
  CB.OnDragEnterFunc := '';
  CB.OnDragOverFunc := '';
  CB.OnDragDropFunc := '';
  CB.OnDragLeaveFunc := '';
  ClearError();
end;

// Library Registration
procedure RegisterComboBoxFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_combobox_error; Lib.Add('combobox_error@', Fn);
  Fn.Entry := @s_combobox_errormsg; Lib.Add('combobox_errormsg$@', Fn);
  Fn.Entry := @s_combobox_strerror; Lib.Add('combobox_strerror$@n', Fn);
  Fn.Entry := @n_combobox_clearerror; Lib.Add('combobox_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_combobox_new; Lib.Add('combobox#@#', Fn);
  Fn.Entry := @p_combobox_new_pos; Lib.Add('combobox#@#nnnn', Fn);
  Fn.Entry := @n_combobox_free; Lib.Add('combobox_free@#', Fn);

  // Items management
  Fn.Entry := @n_combobox_add; Lib.Add('combobox_add@#$', Fn);
  Fn.Entry := @n_combobox_insert; Lib.Add('combobox_insert@#n$', Fn);
  Fn.Entry := @n_combobox_delete; Lib.Add('combobox_delete@#n', Fn);
  Fn.Entry := @n_combobox_clear; Lib.Add('combobox_clear@#', Fn);
  Fn.Entry := @n_combobox_count; Lib.Add('combobox_count@#', Fn);
  Fn.Entry := @s_combobox_item_get; Lib.Add('combobox_item$@#n', Fn);
  Fn.Entry := @p_combobox_item_set; Lib.Add('combobox_item#@#n$', Fn);
  Fn.Entry := @n_combobox_itemindex_get; Lib.Add('combobox_itemindex@#', Fn);
  Fn.Entry := @p_combobox_itemindex_set; Lib.Add('combobox_itemindex#@#n', Fn);
  Fn.Entry := @s_combobox_selected; Lib.Add('combobox_selected$@#', Fn);
  Fn.Entry := @n_combobox_indexof; Lib.Add('combobox_indexof@#$', Fn);

  // Position and Size
  Fn.Entry := @n_combobox_x_get; Lib.Add('combobox_x@#', Fn);
  Fn.Entry := @p_combobox_x_set; Lib.Add('combobox_x#@#n', Fn);
  Fn.Entry := @n_combobox_y_get; Lib.Add('combobox_y@#', Fn);
  Fn.Entry := @p_combobox_y_set; Lib.Add('combobox_y#@#n', Fn);
  Fn.Entry := @n_combobox_width_get; Lib.Add('combobox_width@#', Fn);
  Fn.Entry := @p_combobox_width_set; Lib.Add('combobox_width#@#n', Fn);
  Fn.Entry := @n_combobox_height_get; Lib.Add('combobox_height@#', Fn);
  Fn.Entry := @p_combobox_height_set; Lib.Add('combobox_height#@#n', Fn);
  Fn.Entry := @p_combobox_bounds_set; Lib.Add('combobox_bounds#@#nnnn', Fn);
  Fn.Entry := @p_combobox_move_set; Lib.Add('combobox_move#@#nn', Fn);
  Fn.Entry := @p_combobox_size_set; Lib.Add('combobox_size#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_combobox_align_get; Lib.Add('combobox_align@#', Fn);
  Fn.Entry := @p_combobox_align_set; Lib.Add('combobox_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_combobox_marginleft_get; Lib.Add('combobox_marginleft@#', Fn);
  Fn.Entry := @p_combobox_marginleft_set; Lib.Add('combobox_marginleft#@#n', Fn);
  Fn.Entry := @n_combobox_margintop_get; Lib.Add('combobox_margintop@#', Fn);
  Fn.Entry := @p_combobox_margintop_set; Lib.Add('combobox_margintop#@#n', Fn);
  Fn.Entry := @n_combobox_marginright_get; Lib.Add('combobox_marginright@#', Fn);
  Fn.Entry := @p_combobox_marginright_set; Lib.Add('combobox_marginright#@#n', Fn);
  Fn.Entry := @n_combobox_marginbottom_get; Lib.Add('combobox_marginbottom@#', Fn);
  Fn.Entry := @p_combobox_marginbottom_set; Lib.Add('combobox_marginbottom#@#n', Fn);
  Fn.Entry := @p_combobox_margins_set; Lib.Add('combobox_margins#@#nnnn', Fn);
  Fn.Entry := @p_combobox_margin_set; Lib.Add('combobox_margin#@#n', Fn);

  // Visibility and state
  Fn.Entry := @n_combobox_visible_get; Lib.Add('combobox_visible@#', Fn);
  Fn.Entry := @p_combobox_visible_set; Lib.Add('combobox_visible#@#n', Fn);
  Fn.Entry := @n_combobox_enabled_get; Lib.Add('combobox_enabled@#', Fn);
  Fn.Entry := @p_combobox_enabled_set; Lib.Add('combobox_enabled#@#n', Fn);
  Fn.Entry := @n_combobox_opacity_get; Lib.Add('combobox_opacity@#', Fn);
  Fn.Entry := @p_combobox_opacity_set; Lib.Add('combobox_opacity#@#n', Fn);

  // Focus
  Fn.Entry := @n_combobox_isfocused_get; Lib.Add('combobox_isfocused@#', Fn);
  Fn.Entry := @p_combobox_setfocus; Lib.Add('combobox_setfocus#@#', Fn);
  Fn.Entry := @p_combobox_resetfocus; Lib.Add('combobox_resetfocus#@#', Fn);
  Fn.Entry := @n_combobox_taborder_get; Lib.Add('combobox_taborder@#', Fn);
  Fn.Entry := @p_combobox_taborder_set; Lib.Add('combobox_taborder#@#n', Fn);
  Fn.Entry := @n_combobox_canfocus_get; Lib.Add('combobox_canfocus@#', Fn);
  Fn.Entry := @p_combobox_canfocus_set; Lib.Add('combobox_canfocus#@#n', Fn);

  // Tag
  Fn.Entry := @n_combobox_tag_get; Lib.Add('combobox_tag@#', Fn);
  Fn.Entry := @p_combobox_tag_set; Lib.Add('combobox_tag#@#n', Fn);

  // HitTest
  Fn.Entry := @n_combobox_hittest_get; Lib.Add('combobox_hittest@#', Fn);
  Fn.Entry := @p_combobox_hittest_set; Lib.Add('combobox_hittest#@#n', Fn);

  // DragMode
  Fn.Entry := @n_combobox_dragmode_get; Lib.Add('combobox_dragmode@#', Fn);
  Fn.Entry := @p_combobox_dragmode_set; Lib.Add('combobox_dragmode#@#n', Fn);

  // Parent
  Fn.Entry := @p_combobox_parent_get; Lib.Add('combobox_parent#@#', Fn);
  Fn.Entry := @p_combobox_parent_set; Lib.Add('combobox_parent#@##', Fn);
  Fn.Entry := @p_combobox_bringtofront; Lib.Add('combobox_bringtofront#@#', Fn);
  Fn.Entry := @p_combobox_sendtoback; Lib.Add('combobox_sendtoback#@#', Fn);

  // DropDownCount
  Fn.Entry := @n_combobox_dropdowncount_get; Lib.Add('combobox_dropdowncount@#', Fn);
  Fn.Entry := @p_combobox_dropdowncount_set; Lib.Add('combobox_dropdowncount#@#n', Fn);

  // Event callbacks
  Fn.Entry := @p_combobox_onchange_set; Lib.Add('combobox_onchange#@#$', Fn);
  Fn.Entry := @s_combobox_onchange_get; Lib.Add('combobox_onchange$@#', Fn);
  Fn.Entry := @p_combobox_onclick_set; Lib.Add('combobox_onclick#@#$', Fn);
  Fn.Entry := @s_combobox_onclick_get; Lib.Add('combobox_onclick$@#', Fn);
  Fn.Entry := @p_combobox_ondblclick_set; Lib.Add('combobox_ondblclick#@#$', Fn);
  Fn.Entry := @s_combobox_ondblclick_get; Lib.Add('combobox_ondblclick$@#', Fn);
  Fn.Entry := @p_combobox_onenter_set; Lib.Add('combobox_onenter#@#$', Fn);
  Fn.Entry := @s_combobox_onenter_get; Lib.Add('combobox_onenter$@#', Fn);
  Fn.Entry := @p_combobox_onexit_set; Lib.Add('combobox_onexit#@#$', Fn);
  Fn.Entry := @s_combobox_onexit_get; Lib.Add('combobox_onexit$@#', Fn);
  Fn.Entry := @p_combobox_onkeydown_set; Lib.Add('combobox_onkeydown#@#$', Fn);
  Fn.Entry := @s_combobox_onkeydown_get; Lib.Add('combobox_onkeydown$@#', Fn);
  Fn.Entry := @p_combobox_onkeyup_set; Lib.Add('combobox_onkeyup#@#$', Fn);
  Fn.Entry := @s_combobox_onkeyup_get; Lib.Add('combobox_onkeyup$@#', Fn);
  Fn.Entry := @p_combobox_onmousedown_set; Lib.Add('combobox_onmousedown#@#$', Fn);
  Fn.Entry := @s_combobox_onmousedown_get; Lib.Add('combobox_onmousedown$@#', Fn);
  Fn.Entry := @p_combobox_onmouseup_set; Lib.Add('combobox_onmouseup#@#$', Fn);
  Fn.Entry := @s_combobox_onmouseup_get; Lib.Add('combobox_onmouseup$@#', Fn);
  Fn.Entry := @p_combobox_onmousemove_set; Lib.Add('combobox_onmousemove#@#$', Fn);
  Fn.Entry := @s_combobox_onmousemove_get; Lib.Add('combobox_onmousemove$@#', Fn);
  Fn.Entry := @p_combobox_onmouseenter_set; Lib.Add('combobox_onmouseenter#@#$', Fn);
  Fn.Entry := @s_combobox_onmouseenter_get; Lib.Add('combobox_onmouseenter$@#', Fn);
  Fn.Entry := @p_combobox_onmouseleave_set; Lib.Add('combobox_onmouseleave#@#$', Fn);
  Fn.Entry := @s_combobox_onmouseleave_get; Lib.Add('combobox_onmouseleave$@#', Fn);
  Fn.Entry := @p_combobox_onresize_set; Lib.Add('combobox_onresize#@#$', Fn);
  Fn.Entry := @s_combobox_onresize_get; Lib.Add('combobox_onresize$@#', Fn);

  // Drag & Drop event callbacks
  Fn.Entry := @p_combobox_ondragenter_set; Lib.Add('combobox_ondragenter#@#$', Fn);
  Fn.Entry := @s_combobox_ondragenter_get; Lib.Add('combobox_ondragenter$@#', Fn);
  Fn.Entry := @p_combobox_ondragover_set; Lib.Add('combobox_ondragover#@#$', Fn);
  Fn.Entry := @s_combobox_ondragover_get; Lib.Add('combobox_ondragover$@#', Fn);
  Fn.Entry := @p_combobox_ondragdrop_set; Lib.Add('combobox_ondragdrop#@#$', Fn);
  Fn.Entry := @s_combobox_ondragdrop_get; Lib.Add('combobox_ondragdrop$@#', Fn);
  Fn.Entry := @p_combobox_ondragleave_set; Lib.Add('combobox_ondragleave#@#$', Fn);
  Fn.Entry := @s_combobox_ondragleave_get; Lib.Add('combobox_ondragleave$@#', Fn);

  // Clear callbacks
  Fn.Entry := @p_combobox_clearcallbacks; Lib.Add('combobox_clearcallbacks#@#', Fn);
end;

end.
