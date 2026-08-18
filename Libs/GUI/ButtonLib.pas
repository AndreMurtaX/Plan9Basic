unit ButtonLib;

{******************************************************************************
  ButtonLib - Button Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TButton wrapper functionality for creating
  and managing button controls in Plan9Basic programs. TButton provides
  the standard clickable button interface.

  Function Count: 90+ functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All buttons are created at RUNTIME using TButton.Create with dynamic
  parent assignment. This ensures proper dynamic creation across all platforms.

  EVENT CONNECTION MODEL:
  =======================
  Events are connected/disconnected individually when callbacks are set:
  - Setting a non-empty callback name connects ONLY that specific event
  - Setting an empty callback name ("") disconnects ONLY that specific event
  - No events are connected by default in the constructor

  FEATURES:
  =========
  - Button creation and lifecycle management
  - Text content with font styling (family, size, bold, italic, etc.)
  - Complete positioning and alignment
  - Full event support with BASIC callback integration
  - Drag and drop support
  - Modal result support for dialog buttons

  EVENTS SUPPORT:
  ===============
  - OnClick: Button was clicked (primary button event)
  - OnEnter: Button received focus
  - OnExit: Button lost focus
  - OnKeyDown: Key was pressed while focused
  - OnKeyUp: Key was released while focused
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over button
  - OnMouseEnter: Mouse entered button area
  - OnMouseLeave: Mouse left button area
  - OnResize: Button is being resized
  - OnDragEnter: Drag operation entered button
  - OnDragOver: Drag operation over button (return non-zero to accept)
  - OnDragDrop: Item was dropped on button
  - OnDragLeave: Drag operation left button

  MODAL RESULT VALUES:
  ====================
  0 = mrNone
  1 = mrOk
  2 = mrCancel
  3 = mrAbort
  4 = mrRetry
  5 = mrIgnore
  6 = mrYes
  7 = mrNo
  8 = mrClose
  9 = mrHelp
  10 = mrTryAgain
  11 = mrContinue
  12 = mrAll
  13 = mrNoToAll
  14 = mrYesToAll

  USAGE PATTERN:
  ==============
    let frm# = form#("Button Demo", 800, 600)

    ' Create a button
    let btn# = button#(frm#, "Click Me!")
    button_move#(btn#, 50, 50)
    button_size#(btn#, 120, 40)
    button_onclick#(btn#, "OnButtonClick")

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnButtonClick(sender#)
      println "Button clicked!"
    endfunction

    function OnButtonKeyDown(sender#, key, keychar$, shift$)
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
  basic, exec, UnitGC, UnitUtils, HandleRegistry, ControlCommon;

type
  TBasButton = class(TButton)
  private
    FOnClickFunc: String;
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

    procedure InternalOnClick(Sender: TObject);
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

    procedure SetOnClickFunc(const Value: String);
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

    property OnClickFunc: String read FOnClickFunc write SetOnClickFunc;
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

procedure RegisterButtonFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  BUTTON_GC_TAG = 'BASIC_BUTTON';
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_BUTTON = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;


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

function ValidateButton(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_BUTTON, FuncName + ': Nil pointer');
    Exit();
  end;

  //Registry lookup on the pointer value. The previous form was
  //"IsHandleOf(P, TBasButton)" inside try/except, which dereferences whatever
  //address the BASIC program supplied -- recoverable on Windows, a hard crash
  //on Android and Linux, where SIGSEGV is not turned into an exception.
  if not IsHandleOf(P, TBasButton) then
  begin
    SetError(ERR_INVALID_BUTTON, FuncName + ': Invalid or stale button handle');
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

function IntToModalResult(Value: Integer): TModalResult;
begin
  case Value of
    0: Result := mrNone;
    1: Result := mrOk;
    2: Result := mrCancel;
    3: Result := mrAbort;
    4: Result := mrRetry;
    5: Result := mrIgnore;
    6: Result := mrYes;
    7: Result := mrNo;
    8: Result := mrClose;
    9: Result := mrHelp;
    10: Result := mrTryAgain;
    11: Result := mrContinue;
    12: Result := mrAll;
    13: Result := mrNoToAll;
    14: Result := mrYesToAll;
  else
    Result := mrNone;
  end;
end;

function ModalResultToInt(Value: TModalResult): Integer;
begin
  case Value of
    mrNone: Result := 0;
    mrOk: Result := 1;
    mrCancel: Result := 2;
    mrAbort: Result := 3;
    mrRetry: Result := 4;
    mrIgnore: Result := 5;
    mrYes: Result := 6;
    mrNo: Result := 7;
    mrClose: Result := 8;
    mrHelp: Result := 9;
    mrTryAgain: Result := 10;
    mrContinue: Result := 11;
    mrAll: Result := 12;
    mrNoToAll: Result := 13;
    mrYesToAll: Result := 14;
  else
    Result := 0;
  end;
end;

{ TBasButton }

constructor TBasButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  //Makes this instance a handle the BASIC side can be validated against
  //without dereferencing the pointer it passes back in.
  RegisterHandle(Self);
  FOnClickFunc := '';
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

destructor TBasButton.Destroy();
begin
  //Must happen here and not in the library that created the button: FMX frees
  //child controls through parent ownership, and the library never sees it.
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasButton.DisconnectAllEvents();
begin
  Self.OnClick := nil;
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

procedure TBasButton.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    Self.OnClick := InternalOnClick
  else
    Self.OnClick := nil;
end;

procedure TBasButton.SetOnEnterFunc(const Value: String);
begin
  FOnEnterFunc := Value;
  if Value <> '' then
    Self.OnEnter := InternalOnEnter
  else
    Self.OnEnter := nil;
end;

procedure TBasButton.SetOnExitFunc(const Value: String);
begin
  FOnExitFunc := Value;
  if Value <> '' then
    Self.OnExit := InternalOnExit
  else
    Self.OnExit := nil;
end;

procedure TBasButton.SetOnKeyDownFunc(const Value: String);
begin
  FOnKeyDownFunc := Value;
  if Value <> '' then
    Self.OnKeyDown := InternalOnKeyDown
  else
    Self.OnKeyDown := nil;
end;

procedure TBasButton.SetOnKeyUpFunc(const Value: String);
begin
  FOnKeyUpFunc := Value;
  if Value <> '' then
    Self.OnKeyUp := InternalOnKeyUp
  else
    Self.OnKeyUp := nil;
end;

procedure TBasButton.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    Self.OnMouseDown := InternalOnMouseDown
  else
    Self.OnMouseDown := nil;
end;

procedure TBasButton.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    Self.OnMouseUp := InternalOnMouseUp
  else
    Self.OnMouseUp := nil;
end;

procedure TBasButton.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    Self.OnMouseMove := InternalOnMouseMove
  else
    Self.OnMouseMove := nil;
end;

procedure TBasButton.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    Self.OnMouseEnter := InternalOnMouseEnter
  else
    Self.OnMouseEnter := nil;
end;

procedure TBasButton.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    Self.OnMouseLeave := InternalOnMouseLeave
  else
    Self.OnMouseLeave := nil;
end;

procedure TBasButton.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    Self.OnResize := InternalOnResize
  else
    Self.OnResize := nil;
end;

procedure TBasButton.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    Self.OnDragEnter := InternalOnDragEnter
  else
    Self.OnDragEnter := nil;
end;

procedure TBasButton.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    Self.OnDragOver := InternalOnDragOver
  else
    Self.OnDragOver := nil;
end;

procedure TBasButton.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    Self.OnDragDrop := InternalOnDragDrop
  else
    Self.OnDragDrop := nil;
end;

procedure TBasButton.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    Self.OnDragLeave := InternalOnDragLeave
  else
    Self.OnDragLeave := nil;
end;

procedure TBasButton.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'Button');
end;

function TBasButton.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
begin
  Result := ControlCommon.RunCallbackWithResult(FBasicEngine, FConsoleOutput,
                          FuncSignature, Args, 'Button');
end;

procedure TBasButton.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnClickFunc = '' then
    Exit();

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnClickFunc) + '@#', Args);
end;

procedure TBasButton.InternalOnEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnEnterFunc = '' then
    Exit();

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnEnterFunc) + '@#', Args);
end;

procedure TBasButton.InternalOnExit(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnExitFunc = '' then
    Exit();

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnExitFunc) + '@#', Args);
end;

procedure TBasButton.InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnKeyDownFunc = '' then
    Exit();

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

procedure TBasButton.InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnKeyUpFunc = '' then
    Exit();

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

procedure TBasButton.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseDownFunc = '' then
    Exit();

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

procedure TBasButton.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseUpFunc = '' then
    Exit();

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

procedure TBasButton.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnMouseMoveFunc = '' then
    Exit();

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

procedure TBasButton.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseEnterFunc = '' then
    Exit();

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnMouseEnterFunc) + '@#', Args);
end;

procedure TBasButton.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseLeaveFunc = '' then
    Exit();

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnMouseLeaveFunc) + '@#', Args);
end;

procedure TBasButton.InternalOnResize(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizeFunc = '' then
    Exit();

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(LowerCase(FOnResizeFunc) + '@#', Args);
end;

procedure TBasButton.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasButton.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
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

procedure TBasButton.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasButton.InternalOnDragLeave(Sender: TObject);
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

{ Library Functions }

// Error Functions
function n_button_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

function s_button_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

function s_button_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Trunc(Args[0].n) of
    0: Result.s := 'No error';
    1: Result.s := 'Invalid button';
    2: Result.s := 'Invalid parent';
    3: Result.s := 'Invalid value';
    4: Result.s := 'Create failed';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_button_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  ClearError();
end;

// Creation Functions
function p_button_new(var Args: array of TAsmData): TAsmData;
var
  Btn: TBasButton;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'button#') then
    Exit();

  try
    Btn := TBasButton.Create(nil);
    Btn.Parent := TFmxObject(Args[0].p);
    Btn.Text := 'Button';
    Btn.Position.X := 0;
    Btn.Position.Y := 0;
    Btn.Width := 80;
    Btn.Height := 22;
    Btn.BasicEngine := ModuleEngine;
    Btn.ConsoleOutput := ModuleOutput;

    Result.p := Pointer(Btn);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Btn, BUTTON_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'button#: ' + E.Message);
    end;
  end;
end;

function p_button_new_text(var Args: array of TAsmData): TAsmData;
var
  Btn: TBasButton;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'button#') then
    Exit();

  try
    Btn := TBasButton.Create(nil);
    Btn.Parent := TFmxObject(Args[0].p);
    Btn.Text := Args[1].s;
    Btn.Position.X := 0;
    Btn.Position.Y := 0;
    Btn.Width := 80;
    Btn.Height := 22;
    Btn.BasicEngine := ModuleEngine;
    Btn.ConsoleOutput := ModuleOutput;

    Result.p := Pointer(Btn);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Btn, BUTTON_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'button#: ' + E.Message);
    end;
  end;
end;

function p_button_new_pos(var Args: array of TAsmData): TAsmData;
var
  Btn: TBasButton;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'button#') then
    Exit();

  try
    Btn := TBasButton.Create(nil);
    Btn.Parent := TFmxObject(Args[0].p);
    Btn.Text := 'Button';
    Btn.Position.X := Args[1].n;
    Btn.Position.Y := Args[2].n;
    Btn.Width := Args[3].n;
    Btn.Height := Args[4].n;
    Btn.BasicEngine := ModuleEngine;
    Btn.ConsoleOutput := ModuleOutput;

    Result.p := Pointer(Btn);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Btn, BUTTON_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'button#: ' + E.Message);
    end;
  end;
end;

function p_button_new_full(var Args: array of TAsmData): TAsmData;
var
  Btn: TBasButton;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'button#') then
    Exit();

  try
    Btn := TBasButton.Create(nil);
    Btn.Parent := TFmxObject(Args[0].p);
    Btn.Text := Args[1].s;
    Btn.Position.X := Args[2].n;
    Btn.Position.Y := Args[3].n;
    Btn.Width := Args[4].n;
    Btn.Height := Args[5].n;
    Btn.BasicEngine := ModuleEngine;
    Btn.ConsoleOutput := ModuleOutput;

    Result.p := Pointer(Btn);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Btn, BUTTON_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));
    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'button#: ' + E.Message);
    end;
  end;
end;

function n_button_free(var Args: array of TAsmData): TAsmData;
var
  Btn: TBasButton;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateButton(Args[0].p, 'button_free') then
    Exit();

  try
    Btn := TBasButton(Args[0].p);
    Btn.DisconnectAllEvents();
    Btn.Free();

    // Free via GC using individualized tag
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(BUTTON_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;
    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_INVALID_BUTTON, 'button_free: ' + E.Message);
    end;
  end;
end;

// Text content
function s_button_text_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_text$') then Exit();
  try Result.s := TBasButton(Args[0].p).Text; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_text$: ' + E.Message); end;
end;

function p_button_text_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_text#') then Exit();
  try TBasButton(Args[0].p).Text := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_text#: ' + E.Message); end;
end;

// Font properties
function s_button_fontfamily_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_fontfamily$') then Exit();
  try Result.s := TBasButton(Args[0].p).TextSettings.Font.Family; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_fontfamily$: ' + E.Message); end;
end;

function p_button_fontfamily_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_fontfamily#') then Exit();
  try
    TBasButton(Args[0].p).StyledSettings := TBasButton(Args[0].p).StyledSettings - [TStyledSetting.Family];
    TBasButton(Args[0].p).TextSettings.Font.Family := Args[1].s;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_fontfamily#: ' + E.Message); end;
end;

function n_button_fontsize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_fontsize') then Exit();
  try Result.n := TBasButton(Args[0].p).TextSettings.Font.Size; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_fontsize: ' + E.Message); end;
end;

function p_button_fontsize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_fontsize#') then Exit();
  try
    TBasButton(Args[0].p).StyledSettings := TBasButton(Args[0].p).StyledSettings - [TStyledSetting.Size];
    TBasButton(Args[0].p).TextSettings.Font.Size := Args[1].n;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_fontsize#: ' + E.Message); end;
end;

function s_button_fontcolor_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_fontcolor$') then Exit();
  try Result.s := TUtils.AlphaColorToStr(TBasButton(Args[0].p).TextSettings.FontColor); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_fontcolor$: ' + E.Message); end;
end;

function p_button_fontcolor_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_fontcolor#') then Exit();
  try
    TBasButton(Args[0].p).StyledSettings := TBasButton(Args[0].p).StyledSettings - [TStyledSetting.FontColor];
    TBasButton(Args[0].p).TextSettings.FontColor := TUtils.ColorToAlphaColor(Args[1].s);
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_fontcolor#: ' + E.Message); end;
end;

function n_button_bold_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_bold') then Exit();
  try
    if TFontStyle.fsBold in TBasButton(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_bold: ' + E.Message); end;
end;

function p_button_bold_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_bold#') then Exit();
  try
    TBasButton(Args[0].p).StyledSettings := TBasButton(Args[0].p).StyledSettings - [TStyledSetting.Style];
    if Args[1].n <> 0 then
      TBasButton(Args[0].p).TextSettings.Font.Style :=
        TBasButton(Args[0].p).TextSettings.Font.Style + [TFontStyle.fsBold]
    else
      TBasButton(Args[0].p).TextSettings.Font.Style :=
        TBasButton(Args[0].p).TextSettings.Font.Style - [TFontStyle.fsBold];
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_bold#: ' + E.Message); end;
end;

function n_button_italic_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_italic') then Exit();
  try
    if TFontStyle.fsItalic in TBasButton(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_italic: ' + E.Message); end;
end;

function p_button_italic_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_italic#') then Exit();
  try
    TBasButton(Args[0].p).StyledSettings := TBasButton(Args[0].p).StyledSettings - [TStyledSetting.Style];
    if Args[1].n <> 0 then
      TBasButton(Args[0].p).TextSettings.Font.Style :=
        TBasButton(Args[0].p).TextSettings.Font.Style + [TFontStyle.fsItalic]
    else
      TBasButton(Args[0].p).TextSettings.Font.Style :=
        TBasButton(Args[0].p).TextSettings.Font.Style - [TFontStyle.fsItalic];
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_italic#: ' + E.Message); end;
end;

function n_button_underline_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_underline') then Exit();
  try
    if TFontStyle.fsUnderline in TBasButton(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_underline: ' + E.Message); end;
end;

function p_button_underline_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_underline#') then Exit();
  try
    TBasButton(Args[0].p).StyledSettings := TBasButton(Args[0].p).StyledSettings - [TStyledSetting.Style];
    if Args[1].n <> 0 then
      TBasButton(Args[0].p).TextSettings.Font.Style :=
        TBasButton(Args[0].p).TextSettings.Font.Style + [TFontStyle.fsUnderline]
    else
      TBasButton(Args[0].p).TextSettings.Font.Style :=
        TBasButton(Args[0].p).TextSettings.Font.Style - [TFontStyle.fsUnderline];
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_underline#: ' + E.Message); end;
end;

function n_button_strikeout_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_strikeout') then Exit();
  try
    if TFontStyle.fsStrikeOut in TBasButton(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_strikeout: ' + E.Message); end;
end;

function p_button_strikeout_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_strikeout#') then Exit();
  try
    TBasButton(Args[0].p).StyledSettings := TBasButton(Args[0].p).StyledSettings - [TStyledSetting.Style];
    if Args[1].n <> 0 then
      TBasButton(Args[0].p).TextSettings.Font.Style :=
        TBasButton(Args[0].p).TextSettings.Font.Style + [TFontStyle.fsStrikeOut]
    else
      TBasButton(Args[0].p).TextSettings.Font.Style :=
        TBasButton(Args[0].p).TextSettings.Font.Style - [TFontStyle.fsStrikeOut];
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_strikeout#: ' + E.Message); end;
end;

// Modal Result
function n_button_modalresult_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_modalresult') then Exit();
  try Result.n := ModalResultToInt(TBasButton(Args[0].p).ModalResult); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_modalresult: ' + E.Message); end;
end;

function p_button_modalresult_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_modalresult#') then Exit();
  try TBasButton(Args[0].p).ModalResult := IntToModalResult(Trunc(Args[1].n)); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_modalresult#: ' + E.Message); end;
end;

// Default button
function n_button_default_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_default') then Exit();
  try
    if TBasButton(Args[0].p).Default then
      Result.n := 1
    else
      Result.n := 0;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_default: ' + E.Message); end;
end;

function p_button_default_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_default#') then Exit();
  try TBasButton(Args[0].p).Default := (Args[1].n <> 0); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_default#: ' + E.Message); end;
end;

// Cancel button
function n_button_cancel_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_cancel') then Exit();
  try
    if TBasButton(Args[0].p).Cancel then
      Result.n := 1
    else
      Result.n := 0;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_cancel: ' + E.Message); end;
end;

function p_button_cancel_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_cancel#') then Exit();
  try TBasButton(Args[0].p).Cancel := (Args[1].n <> 0); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_cancel#: ' + E.Message); end;
end;

// Position and Size
function n_button_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_x') then Exit();
  try Result.n := TBasButton(Args[0].p).Position.X; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_x: ' + E.Message); end;
end;

function p_button_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_x#') then Exit();
  try TBasButton(Args[0].p).Position.X := Args[1].n; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_x#: ' + E.Message); end;
end;

function n_button_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_y') then Exit();
  try Result.n := TBasButton(Args[0].p).Position.Y; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_y: ' + E.Message); end;
end;

function p_button_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_y#') then Exit();
  try TBasButton(Args[0].p).Position.Y := Args[1].n; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_y#: ' + E.Message); end;
end;

function n_button_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_width') then Exit();
  try Result.n := TBasButton(Args[0].p).Width; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_width: ' + E.Message); end;
end;

function p_button_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_width#') then Exit();
  try TBasButton(Args[0].p).Width := Args[1].n; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_width#: ' + E.Message); end;
end;

function n_button_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_height') then Exit();
  try Result.n := TBasButton(Args[0].p).Height; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_height: ' + E.Message); end;
end;

function p_button_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_height#') then Exit();
  try TBasButton(Args[0].p).Height := Args[1].n; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_height#: ' + E.Message); end;
end;

function p_button_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_bounds#') then Exit();
  try
    TBasButton(Args[0].p).SetBounds(Args[1].n, Args[2].n, Args[3].n, Args[4].n);
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_bounds#: ' + E.Message); end;
end;

function p_button_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_move#') then Exit();
  try
    TBasButton(Args[0].p).Position.X := Args[1].n;
    TBasButton(Args[0].p).Position.Y := Args[2].n;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_move#: ' + E.Message); end;
end;

function p_button_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_size#') then Exit();
  try
    TBasButton(Args[0].p).Width := Args[1].n;
    TBasButton(Args[0].p).Height := Args[2].n;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_size#: ' + E.Message); end;
end;

// Alignment
function n_button_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_align') then Exit();
  try Result.n := AlignToInt(TBasButton(Args[0].p).Align); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_align: ' + E.Message); end;
end;

function p_button_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_align#') then Exit();
  try TBasButton(Args[0].p).Align := AlignFromInt(Trunc(Args[1].n)); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_align#: ' + E.Message); end;
end;

// Margins
function n_button_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_marginleft') then Exit();
  try Result.n := TBasButton(Args[0].p).Margins.Left; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_marginleft: ' + E.Message); end;
end;

function p_button_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_marginleft#') then Exit();
  try TBasButton(Args[0].p).Margins.Left := Args[1].n; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_marginleft#: ' + E.Message); end;
end;

function n_button_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_margintop') then Exit();
  try Result.n := TBasButton(Args[0].p).Margins.Top; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_margintop: ' + E.Message); end;
end;

function p_button_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_margintop#') then Exit();
  try TBasButton(Args[0].p).Margins.Top := Args[1].n; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_margintop#: ' + E.Message); end;
end;

function n_button_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_marginright') then Exit();
  try Result.n := TBasButton(Args[0].p).Margins.Right; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_marginright: ' + E.Message); end;
end;

function p_button_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_marginright#') then Exit();
  try TBasButton(Args[0].p).Margins.Right := Args[1].n; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_marginright#: ' + E.Message); end;
end;

function n_button_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_marginbottom') then Exit();
  try Result.n := TBasButton(Args[0].p).Margins.Bottom; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_marginbottom: ' + E.Message); end;
end;

function p_button_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_marginbottom#') then Exit();
  try TBasButton(Args[0].p).Margins.Bottom := Args[1].n; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_marginbottom#: ' + E.Message); end;
end;

function p_button_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_margins#') then Exit();
  try
    TBasButton(Args[0].p).Margins.Left := Args[1].n;
    TBasButton(Args[0].p).Margins.Top := Args[2].n;
    TBasButton(Args[0].p).Margins.Right := Args[3].n;
    TBasButton(Args[0].p).Margins.Bottom := Args[4].n;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_margins#: ' + E.Message); end;
end;

function p_button_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_margin#') then Exit();
  try
    TBasButton(Args[0].p).Margins.Left := Args[1].n;
    TBasButton(Args[0].p).Margins.Top := Args[1].n;
    TBasButton(Args[0].p).Margins.Right := Args[1].n;
    TBasButton(Args[0].p).Margins.Bottom := Args[1].n;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_margin#: ' + E.Message); end;
end;

// Visibility and state
function n_button_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_visible') then Exit();
  try
    if TBasButton(Args[0].p).Visible then Result.n := 1 else Result.n := 0;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_visible: ' + E.Message); end;
end;

function p_button_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_visible#') then Exit();
  try TBasButton(Args[0].p).Visible := (Args[1].n <> 0); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_visible#: ' + E.Message); end;
end;

function n_button_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_enabled') then Exit();
  try
    if TBasButton(Args[0].p).Enabled then Result.n := 1 else Result.n := 0;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_enabled: ' + E.Message); end;
end;

function p_button_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_enabled#') then Exit();
  try TBasButton(Args[0].p).Enabled := (Args[1].n <> 0); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_enabled#: ' + E.Message); end;
end;

function n_button_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_opacity') then Exit();
  try Result.n := TBasButton(Args[0].p).Opacity; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_opacity: ' + E.Message); end;
end;

function p_button_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_opacity#') then Exit();
  try TBasButton(Args[0].p).Opacity := Args[1].n; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_opacity#: ' + E.Message); end;
end;

// Focus
function n_button_isfocused_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_isfocused') then Exit();
  try
    if TBasButton(Args[0].p).IsFocused then Result.n := 1 else Result.n := 0;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_isfocused: ' + E.Message); end;
end;

function p_button_setfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_setfocus#') then Exit();
  try TBasButton(Args[0].p).SetFocus; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_setfocus#: ' + E.Message); end;
end;

function p_button_resetfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_resetfocus#') then Exit();
  try TBasButton(Args[0].p).ResetFocus; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_resetfocus#: ' + E.Message); end;
end;

function n_button_taborder_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_taborder') then Exit();
  try Result.n := TBasButton(Args[0].p).TabOrder; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_taborder: ' + E.Message); end;
end;

function p_button_taborder_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_taborder#') then Exit();
  try TBasButton(Args[0].p).TabOrder := Trunc(Args[1].n); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_taborder#: ' + E.Message); end;
end;

function n_button_canfocus_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_canfocus') then Exit();
  try
    if TBasButton(Args[0].p).CanFocus then Result.n := 1 else Result.n := 0;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_canfocus: ' + E.Message); end;
end;

function p_button_canfocus_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_canfocus#') then Exit();
  try TBasButton(Args[0].p).CanFocus := (Args[1].n <> 0); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_canfocus#: ' + E.Message); end;
end;

// Tag
function n_button_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_tag') then Exit();
  try Result.n := TBasButton(Args[0].p).Tag; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_tag: ' + E.Message); end;
end;

function p_button_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_tag#') then Exit();
  try TBasButton(Args[0].p).Tag := Trunc(Args[1].n); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_tag#: ' + E.Message); end;
end;

// HitTest
function n_button_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_hittest') then Exit();
  try
    if TBasButton(Args[0].p).HitTest then Result.n := 1 else Result.n := 0;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_hittest: ' + E.Message); end;
end;

function p_button_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_hittest#') then Exit();
  try TBasButton(Args[0].p).HitTest := (Args[1].n <> 0); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_hittest#: ' + E.Message); end;
end;

// DragMode
function n_button_dragmode_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_dragmode') then Exit();
  try
    case TBasButton(Args[0].p).DragMode of
      TDragMode.dmManual: Result.n := 0;
      TDragMode.dmAutomatic: Result.n := 1;
    else
      Result.n := 0;
    end;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_dragmode: ' + E.Message); end;
end;

function p_button_dragmode_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_dragmode#') then Exit();
  try
    if Args[1].n = 0 then
      TBasButton(Args[0].p).DragMode := TDragMode.dmManual
    else
      TBasButton(Args[0].p).DragMode := TDragMode.dmAutomatic;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_dragmode#: ' + E.Message); end;
end;

// Parent
function p_button_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_parent#') then Exit();
  try Result.p := Pointer(TBasButton(Args[0].p).Parent); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_parent#: ' + E.Message); end;
end;

function p_button_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_parent#') then Exit();
  if not ValidateParent(Args[1].p, 'button_parent#') then Exit();
  try TBasButton(Args[0].p).Parent := TFmxObject(Args[1].p); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_parent#: ' + E.Message); end;
end;

function p_button_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_bringtofront#') then Exit();
  try TBasButton(Args[0].p).BringToFront; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_bringtofront#: ' + E.Message); end;
end;

function p_button_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_sendtoback#') then Exit();
  try TBasButton(Args[0].p).SendToBack; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_sendtoback#: ' + E.Message); end;
end;

// Event Callback Get/Set Functions

function p_button_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onclick#') then Exit();
  try TBasButton(Args[0].p).OnClickFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onclick#: ' + E.Message); end;
end;

function s_button_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onclick$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnClickFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onclick$: ' + E.Message); end;
end;

function p_button_onenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onenter#') then Exit();
  try TBasButton(Args[0].p).OnEnterFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onenter#: ' + E.Message); end;
end;

function s_button_onenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onenter$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnEnterFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onenter$: ' + E.Message); end;
end;

function p_button_onexit_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onexit#') then Exit();
  try TBasButton(Args[0].p).OnExitFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onexit#: ' + E.Message); end;
end;

function s_button_onexit_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onexit$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnExitFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onexit$: ' + E.Message); end;
end;

function p_button_onkeydown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onkeydown#') then Exit();
  try TBasButton(Args[0].p).OnKeyDownFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onkeydown#: ' + E.Message); end;
end;

function s_button_onkeydown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onkeydown$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnKeyDownFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onkeydown$: ' + E.Message); end;
end;

function p_button_onkeyup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onkeyup#') then Exit();
  try TBasButton(Args[0].p).OnKeyUpFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onkeyup#: ' + E.Message); end;
end;

function s_button_onkeyup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onkeyup$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnKeyUpFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onkeyup$: ' + E.Message); end;
end;

function p_button_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onmousedown#') then Exit();
  try TBasButton(Args[0].p).OnMouseDownFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onmousedown#: ' + E.Message); end;
end;

function s_button_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onmousedown$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnMouseDownFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onmousedown$: ' + E.Message); end;
end;

function p_button_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onmouseup#') then Exit();
  try TBasButton(Args[0].p).OnMouseUpFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onmouseup#: ' + E.Message); end;
end;

function s_button_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onmouseup$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnMouseUpFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onmouseup$: ' + E.Message); end;
end;

function p_button_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onmousemove#') then Exit();
  try TBasButton(Args[0].p).OnMouseMoveFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onmousemove#: ' + E.Message); end;
end;

function s_button_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onmousemove$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnMouseMoveFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onmousemove$: ' + E.Message); end;
end;

function p_button_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onmouseenter#') then Exit();
  try TBasButton(Args[0].p).OnMouseEnterFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onmouseenter#: ' + E.Message); end;
end;

function s_button_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onmouseenter$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnMouseEnterFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onmouseenter$: ' + E.Message); end;
end;

function p_button_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onmouseleave#') then Exit();
  try TBasButton(Args[0].p).OnMouseLeaveFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onmouseleave#: ' + E.Message); end;
end;

function s_button_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onmouseleave$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnMouseLeaveFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onmouseleave$: ' + E.Message); end;
end;

function p_button_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onresize#') then Exit();
  try TBasButton(Args[0].p).OnResizeFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onresize#: ' + E.Message); end;
end;

function s_button_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_onresize$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnResizeFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_onresize$: ' + E.Message); end;
end;

// Drag & Drop event callbacks
function p_button_ondragenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_ondragenter#') then Exit();
  try TBasButton(Args[0].p).OnDragEnterFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_ondragenter#: ' + E.Message); end;
end;

function s_button_ondragenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_ondragenter$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnDragEnterFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_ondragenter$: ' + E.Message); end;
end;

function p_button_ondragover_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_ondragover#') then Exit();
  try TBasButton(Args[0].p).OnDragOverFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_ondragover#: ' + E.Message); end;
end;

function s_button_ondragover_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_ondragover$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnDragOverFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_ondragover$: ' + E.Message); end;
end;

function p_button_ondragdrop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_ondragdrop#') then Exit();
  try TBasButton(Args[0].p).OnDragDropFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_ondragdrop#: ' + E.Message); end;
end;

function s_button_ondragdrop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_ondragdrop$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnDragDropFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_ondragdrop$: ' + E.Message); end;
end;

function p_button_ondragleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_ondragleave#') then Exit();
  try TBasButton(Args[0].p).OnDragLeaveFunc := Args[1].s; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_ondragleave#: ' + E.Message); end;
end;

function s_button_ondragleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_ondragleave$') then Exit();
  try Result.s := TBasButton(Args[0].p).OnDragLeaveFunc; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'button_ondragleave$: ' + E.Message); end;
end;

function p_button_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateButton(Args[0].p, 'button_clearcallbacks#') then Exit();
  try
    with TBasButton(Args[0].p) do
    begin
      OnClickFunc := '';
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
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'button_clearcallbacks#: ' + E.Message);
  end;
end;

// Library Registration
procedure RegisterButtonFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_button_error; Lib.Add('button_error@', Fn);
  Fn.Entry := @s_button_errormsg; Lib.Add('button_errormsg$@', Fn);
  Fn.Entry := @s_button_strerror; Lib.Add('button_strerror$@n', Fn);
  Fn.Entry := @n_button_clearerror; Lib.Add('button_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_button_new; Lib.Add('button#@#', Fn);
  Fn.Entry := @p_button_new_text; Lib.Add('button#@#$', Fn);
  Fn.Entry := @p_button_new_pos; Lib.Add('button#@#nnnn', Fn);
  Fn.Entry := @p_button_new_full; Lib.Add('button#@#$nnnn', Fn);
  Fn.Entry := @n_button_free; Lib.Add('button_free@#', Fn);

  // Text content
  Fn.Entry := @s_button_text_get; Lib.Add('button_text$@#', Fn);
  Fn.Entry := @p_button_text_set; Lib.Add('button_text#@#$', Fn);

  // Font properties
  Fn.Entry := @s_button_fontfamily_get; Lib.Add('button_fontfamily$@#', Fn);
  Fn.Entry := @p_button_fontfamily_set; Lib.Add('button_fontfamily#@#$', Fn);
  Fn.Entry := @n_button_fontsize_get; Lib.Add('button_fontsize@#', Fn);
  Fn.Entry := @p_button_fontsize_set; Lib.Add('button_fontsize#@#n', Fn);
  Fn.Entry := @s_button_fontcolor_get; Lib.Add('button_fontcolor$@#', Fn);
  Fn.Entry := @p_button_fontcolor_set; Lib.Add('button_fontcolor#@#$', Fn);
  Fn.Entry := @n_button_bold_get; Lib.Add('button_bold@#', Fn);
  Fn.Entry := @p_button_bold_set; Lib.Add('button_bold#@#n', Fn);
  Fn.Entry := @n_button_italic_get; Lib.Add('button_italic@#', Fn);
  Fn.Entry := @p_button_italic_set; Lib.Add('button_italic#@#n', Fn);
  Fn.Entry := @n_button_underline_get; Lib.Add('button_underline@#', Fn);
  Fn.Entry := @p_button_underline_set; Lib.Add('button_underline#@#n', Fn);
  Fn.Entry := @n_button_strikeout_get; Lib.Add('button_strikeout@#', Fn);
  Fn.Entry := @p_button_strikeout_set; Lib.Add('button_strikeout#@#n', Fn);

  // Modal Result and special properties
  Fn.Entry := @n_button_modalresult_get; Lib.Add('button_modalresult@#', Fn);
  Fn.Entry := @p_button_modalresult_set; Lib.Add('button_modalresult#@#n', Fn);
  Fn.Entry := @n_button_default_get; Lib.Add('button_default@#', Fn);
  Fn.Entry := @p_button_default_set; Lib.Add('button_default#@#n', Fn);
  Fn.Entry := @n_button_cancel_get; Lib.Add('button_cancel@#', Fn);
  Fn.Entry := @p_button_cancel_set; Lib.Add('button_cancel#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_button_x_get; Lib.Add('button_x@#', Fn);
  Fn.Entry := @p_button_x_set; Lib.Add('button_x#@#n', Fn);
  Fn.Entry := @n_button_y_get; Lib.Add('button_y@#', Fn);
  Fn.Entry := @p_button_y_set; Lib.Add('button_y#@#n', Fn);
  Fn.Entry := @n_button_width_get; Lib.Add('button_width@#', Fn);
  Fn.Entry := @p_button_width_set; Lib.Add('button_width#@#n', Fn);
  Fn.Entry := @n_button_height_get; Lib.Add('button_height@#', Fn);
  Fn.Entry := @p_button_height_set; Lib.Add('button_height#@#n', Fn);
  Fn.Entry := @p_button_bounds_set; Lib.Add('button_bounds#@#nnnn', Fn);
  Fn.Entry := @p_button_move_set; Lib.Add('button_move#@#nn', Fn);
  Fn.Entry := @p_button_size_set; Lib.Add('button_size#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_button_align_get; Lib.Add('button_align@#', Fn);
  Fn.Entry := @p_button_align_set; Lib.Add('button_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_button_marginleft_get; Lib.Add('button_marginleft@#', Fn);
  Fn.Entry := @p_button_marginleft_set; Lib.Add('button_marginleft#@#n', Fn);
  Fn.Entry := @n_button_margintop_get; Lib.Add('button_margintop@#', Fn);
  Fn.Entry := @p_button_margintop_set; Lib.Add('button_margintop#@#n', Fn);
  Fn.Entry := @n_button_marginright_get; Lib.Add('button_marginright@#', Fn);
  Fn.Entry := @p_button_marginright_set; Lib.Add('button_marginright#@#n', Fn);
  Fn.Entry := @n_button_marginbottom_get; Lib.Add('button_marginbottom@#', Fn);
  Fn.Entry := @p_button_marginbottom_set; Lib.Add('button_marginbottom#@#n', Fn);
  Fn.Entry := @p_button_margins_set; Lib.Add('button_margins#@#nnnn', Fn);
  Fn.Entry := @p_button_margin_set; Lib.Add('button_margin#@#n', Fn);

  // Visibility and state
  Fn.Entry := @n_button_visible_get; Lib.Add('button_visible@#', Fn);
  Fn.Entry := @p_button_visible_set; Lib.Add('button_visible#@#n', Fn);
  Fn.Entry := @n_button_enabled_get; Lib.Add('button_enabled@#', Fn);
  Fn.Entry := @p_button_enabled_set; Lib.Add('button_enabled#@#n', Fn);
  Fn.Entry := @n_button_opacity_get; Lib.Add('button_opacity@#', Fn);
  Fn.Entry := @p_button_opacity_set; Lib.Add('button_opacity#@#n', Fn);

  // Focus
  Fn.Entry := @n_button_isfocused_get; Lib.Add('button_isfocused@#', Fn);
  Fn.Entry := @p_button_setfocus; Lib.Add('button_setfocus#@#', Fn);
  Fn.Entry := @p_button_resetfocus; Lib.Add('button_resetfocus#@#', Fn);
  Fn.Entry := @n_button_taborder_get; Lib.Add('button_taborder@#', Fn);
  Fn.Entry := @p_button_taborder_set; Lib.Add('button_taborder#@#n', Fn);
  Fn.Entry := @n_button_canfocus_get; Lib.Add('button_canfocus@#', Fn);
  Fn.Entry := @p_button_canfocus_set; Lib.Add('button_canfocus#@#n', Fn);

  // Tag
  Fn.Entry := @n_button_tag_get; Lib.Add('button_tag@#', Fn);
  Fn.Entry := @p_button_tag_set; Lib.Add('button_tag#@#n', Fn);

  // HitTest
  Fn.Entry := @n_button_hittest_get; Lib.Add('button_hittest@#', Fn);
  Fn.Entry := @p_button_hittest_set; Lib.Add('button_hittest#@#n', Fn);

  // DragMode
  Fn.Entry := @n_button_dragmode_get; Lib.Add('button_dragmode@#', Fn);
  Fn.Entry := @p_button_dragmode_set; Lib.Add('button_dragmode#@#n', Fn);

  // Parent
  Fn.Entry := @p_button_parent_get; Lib.Add('button_parent#@#', Fn);
  Fn.Entry := @p_button_parent_set; Lib.Add('button_parent#@##', Fn);
  Fn.Entry := @p_button_bringtofront; Lib.Add('button_bringtofront#@#', Fn);
  Fn.Entry := @p_button_sendtoback; Lib.Add('button_sendtoback#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_button_onclick_set; Lib.Add('button_onclick#@#$', Fn);
  Fn.Entry := @s_button_onclick_get; Lib.Add('button_onclick$@#', Fn);
  Fn.Entry := @p_button_onenter_set; Lib.Add('button_onenter#@#$', Fn);
  Fn.Entry := @s_button_onenter_get; Lib.Add('button_onenter$@#', Fn);
  Fn.Entry := @p_button_onexit_set; Lib.Add('button_onexit#@#$', Fn);
  Fn.Entry := @s_button_onexit_get; Lib.Add('button_onexit$@#', Fn);
  Fn.Entry := @p_button_onkeydown_set; Lib.Add('button_onkeydown#@#$', Fn);
  Fn.Entry := @s_button_onkeydown_get; Lib.Add('button_onkeydown$@#', Fn);
  Fn.Entry := @p_button_onkeyup_set; Lib.Add('button_onkeyup#@#$', Fn);
  Fn.Entry := @s_button_onkeyup_get; Lib.Add('button_onkeyup$@#', Fn);
  Fn.Entry := @p_button_onmousedown_set; Lib.Add('button_onmousedown#@#$', Fn);
  Fn.Entry := @s_button_onmousedown_get; Lib.Add('button_onmousedown$@#', Fn);
  Fn.Entry := @p_button_onmouseup_set; Lib.Add('button_onmouseup#@#$', Fn);
  Fn.Entry := @s_button_onmouseup_get; Lib.Add('button_onmouseup$@#', Fn);
  Fn.Entry := @p_button_onmousemove_set; Lib.Add('button_onmousemove#@#$', Fn);
  Fn.Entry := @s_button_onmousemove_get; Lib.Add('button_onmousemove$@#', Fn);
  Fn.Entry := @p_button_onmouseenter_set; Lib.Add('button_onmouseenter#@#$', Fn);
  Fn.Entry := @s_button_onmouseenter_get; Lib.Add('button_onmouseenter$@#', Fn);
  Fn.Entry := @p_button_onmouseleave_set; Lib.Add('button_onmouseleave#@#$', Fn);
  Fn.Entry := @s_button_onmouseleave_get; Lib.Add('button_onmouseleave$@#', Fn);
  Fn.Entry := @p_button_onresize_set; Lib.Add('button_onresize#@#$', Fn);
  Fn.Entry := @s_button_onresize_get; Lib.Add('button_onresize$@#', Fn);

  // Drag & Drop event callbacks
  Fn.Entry := @p_button_ondragenter_set; Lib.Add('button_ondragenter#@#$', Fn);
  Fn.Entry := @s_button_ondragenter_get; Lib.Add('button_ondragenter$@#', Fn);
  Fn.Entry := @p_button_ondragover_set; Lib.Add('button_ondragover#@#$', Fn);
  Fn.Entry := @s_button_ondragover_get; Lib.Add('button_ondragover$@#', Fn);
  Fn.Entry := @p_button_ondragdrop_set; Lib.Add('button_ondragdrop#@#$', Fn);
  Fn.Entry := @s_button_ondragdrop_get; Lib.Add('button_ondragdrop$@#', Fn);
  Fn.Entry := @p_button_ondragleave_set; Lib.Add('button_ondragleave#@#$', Fn);
  Fn.Entry := @s_button_ondragleave_get; Lib.Add('button_ondragleave$@#', Fn);

  // Clear callbacks
  Fn.Entry := @p_button_clearcallbacks; Lib.Add('button_clearcallbacks#@#', Fn);
end;

end.

