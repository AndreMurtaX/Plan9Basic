unit SpeedButtonLib;

{******************************************************************************
  SpeedButtonLib - Speed Button Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TSpeedButton wrapper functionality for creating
  and managing speed button controls in Plan9Basic programs. TSpeedButton is
  a flat, toolbar-style button that supports grouping and toggle behavior.

  Function Count: 85+ functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All speed buttons are created at RUNTIME using TSpeedButton.Create with
  dynamic parent assignment. This ensures proper dynamic creation across
  all platforms.

  EVENT CONNECTION MODEL:
  =======================
  Events are connected/disconnected individually when callbacks are set:
  - Setting a non-empty callback name connects ONLY that specific event
  - Setting an empty callback name ("") disconnects ONLY that specific event
  - No events are connected by default in the constructor

  KEY DIFFERENCES FROM TBUTTON:
  =============================
  - GroupIndex: Custom property for logical grouping (0 = no group)
    NOTE: FMX TSpeedButton lacks built-in radio behavior, so this is
    just a storage value. Implement radio logic in your BASIC code.
  - StaysPressed: Button stays pressed after click (toggle behavior)
  - Down (IsPressed): Current pressed/toggle state
  - No keyboard focus by default (no OnEnter/OnExit/OnKeyDown/OnKeyUp)
  - No ModalResult/Default/Cancel properties
  - Flat appearance, typically used in toolbars

  GROUPINDEX BEHAVIOR (MANUAL):
  =============================
  - GroupIndex = 0: Button acts independently (default)
  - GroupIndex > 0: Use same value to logically group buttons
    - Unlike VCL, FMX has NO automatic radio-button behavior
    - You must manually toggle other buttons in your OnClick handler
    - Example: Loop through buttons, check GroupIndex, set Down = 0

  EVENTS SUPPORT:
  ===============
  - OnClick: Button was clicked (primary button event)
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

  USAGE PATTERN:
  ==============
    let frm# = form#("SpeedButton Demo", 800, 600)

    ' Create a toolbar with grouped speed buttons
    let sb1# = speedbutton#(frm#, "Bold")
    speedbutton_move#(sb1#, 10, 10)
    speedbutton_size#(sb1#, 60, 30)
    speedbutton_groupindex#(sb1#, 1)
    speedbutton_onclick#(sb1#, "OnFormatClick")

    let sb2# = speedbutton#(frm#, "Italic")
    speedbutton_move#(sb2#, 75, 10)
    speedbutton_size#(sb2#, 60, 30)
    speedbutton_groupindex#(sb2#, 1)
    speedbutton_onclick#(sb2#, "OnFormatClick")

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnFormatClick(sender#)
      if speedbutton_down(sender#) = 1 then
        println "Button is now pressed"
      else
        println "Button is now released"
      endif
    endfunction

    function OnSpeedMouseDown(sender#, btn, x, y, shift$)
      println "Mouse down at: " + str$(x) + ", " + str$(y)
    endfunction

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Text,
  basic, exec, UnitGC, UnitUtils, HandleRegistry;

type
  TBasSpeedButton = class(TSpeedButton)
  private
    FOnClickFunc: String;
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
    FGroupIndex: Integer;  // Custom field since FMX TSpeedButton lacks GroupIndex

    procedure InternalOnClick(Sender: TObject);
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
    property GroupIndex: Integer read FGroupIndex write FGroupIndex;  // Custom property
  end;

procedure RegisterSpeedButtonFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  SPEEDBUTTON_GC_TAG = 'BASIC_SPEEDBUTTON';
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_SPEEDBUTTON = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;

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

function ValidateSpeedButton(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_SPEEDBUTTON, FuncName + ': Nil pointer');
    Exit();
  end;

  try
    if not(IsHandleOf(P, TBasSpeedButton)) then
    begin
      SetError(ERR_INVALID_SPEEDBUTTON, FuncName + ': Invalid object');
      Exit();
    end;
  except
    SetError(ERR_INVALID_SPEEDBUTTON, FuncName + ': Invalid pointer');
    Exit();
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
    Exit();
  end;

  try
    if not(TObject(P) is TFmxObject) then
    begin
      SetError(ERR_INVALID_PARENT, FuncName + ': Invalid object');
      Exit();
    end;
  except
    SetError(ERR_INVALID_PARENT, FuncName + ': Invalid pointer');
    Exit();
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

{ TBasSpeedButton }

constructor TBasSpeedButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);
  FOnClickFunc := '';
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
  FGroupIndex := 0;  // Initialize custom group index
end;

destructor TBasSpeedButton.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasSpeedButton.DisconnectAllEvents();
begin
  Self.OnClick := nil;
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

procedure TBasSpeedButton.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    Self.OnClick := InternalOnClick
  else
    Self.OnClick := nil;
end;

procedure TBasSpeedButton.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    Self.OnMouseDown := InternalOnMouseDown
  else
    Self.OnMouseDown := nil;
end;

procedure TBasSpeedButton.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    Self.OnMouseUp := InternalOnMouseUp
  else
    Self.OnMouseUp := nil;
end;

procedure TBasSpeedButton.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    Self.OnMouseMove := InternalOnMouseMove
  else
    Self.OnMouseMove := nil;
end;

procedure TBasSpeedButton.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    Self.OnMouseEnter := InternalOnMouseEnter
  else
    Self.OnMouseEnter := nil;
end;

procedure TBasSpeedButton.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    Self.OnMouseLeave := InternalOnMouseLeave
  else
    Self.OnMouseLeave := nil;
end;

procedure TBasSpeedButton.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    Self.OnResize := InternalOnResize
  else
    Self.OnResize := nil;
end;

procedure TBasSpeedButton.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    Self.OnDragEnter := InternalOnDragEnter
  else
    Self.OnDragEnter := nil;
end;

procedure TBasSpeedButton.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    Self.OnDragOver := InternalOnDragOver
  else
    Self.OnDragOver := nil;
end;

procedure TBasSpeedButton.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    Self.OnDragDrop := InternalOnDragDrop
  else
    Self.OnDragDrop := nil;
end;

procedure TBasSpeedButton.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    Self.OnDragLeave := InternalOnDragLeave
  else
    Self.OnDragLeave := nil;
end;

procedure TBasSpeedButton.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
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
        FConsoleOutput.Add('*** SpeedButton Callback Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

function TBasSpeedButton.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
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
        FConsoleOutput.Add('*** SpeedButton Event Callback Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

procedure TBasSpeedButton.InternalOnClick(Sender: TObject);
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

procedure TBasSpeedButton.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasSpeedButton.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasSpeedButton.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
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

procedure TBasSpeedButton.InternalOnMouseEnter(Sender: TObject);
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

procedure TBasSpeedButton.InternalOnMouseLeave(Sender: TObject);
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

procedure TBasSpeedButton.InternalOnResize(Sender: TObject);
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

procedure TBasSpeedButton.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasSpeedButton.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
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

procedure TBasSpeedButton.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasSpeedButton.InternalOnDragLeave(Sender: TObject);
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
function n_speedbutton_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

function s_speedbutton_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

function s_speedbutton_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Trunc(Args[0].n) of
    0: Result.s := 'No error';
    1: Result.s := 'Invalid speed button';
    2: Result.s := 'Invalid parent';
    3: Result.s := 'Invalid value';
    4: Result.s := 'Create failed';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_speedbutton_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  ClearError();
end;

// Creation Functions
function p_speedbutton_new(var Args: array of TAsmData): TAsmData;
var
  Btn: TBasSpeedButton;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'speedbutton#') then
    Exit();

  try
    Btn := TBasSpeedButton.Create(nil);
    Btn.Parent := TFmxObject(Args[0].p);
    Btn.Text := 'SpeedButton';
    Btn.Position.X := 0;
    Btn.Position.Y := 0;
    Btn.Width := 80;
    Btn.Height := 22;
    Btn.StaysPressed := False;
    Btn.BasicEngine := ModuleEngine;
    Btn.ConsoleOutput := ModuleOutput;
    Result.p := Pointer(Btn);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Btn, SPEEDBUTTON_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'speedbutton#: ' + E.Message);
    end;
  end;
end;

function p_speedbutton_new_text(var Args: array of TAsmData): TAsmData;
var
  Btn: TBasSpeedButton;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'speedbutton#') then
    Exit();

  try
    Btn := TBasSpeedButton.Create(nil);
    Btn.Parent := TFmxObject(Args[0].p);
    Btn.Text := Args[1].s;
    Btn.Position.X := 0;
    Btn.Position.Y := 0;
    Btn.Width := 80;
    Btn.Height := 22;
    Btn.StaysPressed := False;
    Btn.BasicEngine := ModuleEngine;
    Btn.ConsoleOutput := ModuleOutput;
    Result.p := Pointer(Btn);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Btn, SPEEDBUTTON_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'speedbutton#: ' + E.Message);
    end;
  end;
end;

function p_speedbutton_new_pos(var Args: array of TAsmData): TAsmData;
var
  Btn: TBasSpeedButton;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'speedbutton#') then
    Exit();

  try
    Btn := TBasSpeedButton.Create(nil);
    Btn.Parent := TFmxObject(Args[0].p);
    Btn.Text := 'SpeedButton';
    Btn.Position.X := Args[1].n;
    Btn.Position.Y := Args[2].n;
    Btn.Width := Args[3].n;
    Btn.Height := Args[4].n;
    Btn.StaysPressed := False;
    Btn.BasicEngine := ModuleEngine;
    Btn.ConsoleOutput := ModuleOutput;
    Result.p := Pointer(Btn);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Btn, SPEEDBUTTON_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'speedbutton#: ' + E.Message);
    end;
  end;
end;

function p_speedbutton_new_full(var Args: array of TAsmData): TAsmData;
var
  Btn: TBasSpeedButton;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'speedbutton#') then
    Exit();

  try
    Btn := TBasSpeedButton.Create(nil);
    Btn.Parent := TFmxObject(Args[0].p);
    Btn.Text := Args[1].s;
    Btn.Position.X := Args[2].n;
    Btn.Position.Y := Args[3].n;
    Btn.Width := Args[4].n;
    Btn.Height := Args[5].n;
    Btn.StaysPressed := False;
    Btn.BasicEngine := ModuleEngine;
    Btn.ConsoleOutput := ModuleOutput;
    Result.p := Pointer(Btn);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Btn, SPEEDBUTTON_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'speedbutton#: ' + E.Message);
    end;
  end;
end;

function n_speedbutton_free(var Args: array of TAsmData): TAsmData;
var
  Btn: TBasSpeedButton;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateSpeedButton(Args[0].p, 'speedbutton_free') then
    Exit();

  try
    Btn := TBasSpeedButton(Args[0].p);
    Btn.DisconnectAllEvents();
    Btn.Free();

    // Use GC to properly free the control
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(SPEEDBUTTON_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_INVALID_SPEEDBUTTON, 'speedbutton_free: ' + E.Message);
    end;
  end;
end;

// Text content
function s_speedbutton_text_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_text$') then Exit();
  try
    Result.s := TBasSpeedButton(Args[0].p).Text;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_text$: ' + E.Message);
  end;
end;

function p_speedbutton_text_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_text#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Text := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_text#: ' + E.Message);
  end;
end;

// Font properties
function s_speedbutton_fontfamily_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_fontfamily$') then Exit();
  try
    Result.s := TBasSpeedButton(Args[0].p).TextSettings.Font.Family;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_fontfamily$: ' + E.Message);
  end;
end;

function p_speedbutton_fontfamily_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_fontfamily#') then Exit();
  try
    with TBasSpeedButton(Args[0].p) do
    begin
      StyledSettings := StyledSettings - [TStyledSetting.Family];
      TextSettings.Font.Family := Args[1].s;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_fontfamily#: ' + E.Message);
  end;
end;

function n_speedbutton_fontsize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_fontsize') then Exit();
  try
    Result.n := TBasSpeedButton(Args[0].p).TextSettings.Font.Size;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_fontsize: ' + E.Message);
  end;
end;

function p_speedbutton_fontsize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_fontsize#') then Exit();
  try
    with TBasSpeedButton(Args[0].p) do
    begin
      StyledSettings := StyledSettings - [TStyledSetting.Size];
      TextSettings.Font.Size := Args[1].n;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_fontsize#: ' + E.Message);
  end;
end;

function s_speedbutton_fontcolor_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_fontcolor$') then Exit();
  try
    Result.s := TUtils.AlphaColorToStr(TBasSpeedButton(Args[0].p).TextSettings.FontColor);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_fontcolor$: ' + E.Message);
  end;
end;

function p_speedbutton_fontcolor_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_fontcolor#') then Exit();
  try
    with TBasSpeedButton(Args[0].p) do
    begin
      StyledSettings := StyledSettings - [TStyledSetting.FontColor];
      TextSettings.FontColor := TUtils.ColorToAlphaColor(Args[1].s);
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_fontcolor#: ' + E.Message);
  end;
end;

function n_speedbutton_bold_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_bold') then Exit();
  try
    if TFontStyle.fsBold in TBasSpeedButton(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_bold: ' + E.Message);
  end;
end;

function p_speedbutton_bold_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_bold#') then Exit();
  try
    with TBasSpeedButton(Args[0].p) do
    begin
      StyledSettings := StyledSettings - [TStyledSetting.Style];
      if Trunc(Args[1].n) <> 0 then
        TextSettings.Font.Style := TextSettings.Font.Style + [TFontStyle.fsBold]
      else
        TextSettings.Font.Style := TextSettings.Font.Style - [TFontStyle.fsBold];
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_bold#: ' + E.Message);
  end;
end;

function n_speedbutton_italic_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_italic') then Exit();
  try
    if TFontStyle.fsItalic in TBasSpeedButton(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_italic: ' + E.Message);
  end;
end;

function p_speedbutton_italic_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_italic#') then Exit();
  try
    with TBasSpeedButton(Args[0].p) do
    begin
      StyledSettings := StyledSettings - [TStyledSetting.Style];
      if Trunc(Args[1].n) <> 0 then
        TextSettings.Font.Style := TextSettings.Font.Style + [TFontStyle.fsItalic]
      else
        TextSettings.Font.Style := TextSettings.Font.Style - [TFontStyle.fsItalic];
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_italic#: ' + E.Message);
  end;
end;

function n_speedbutton_underline_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_underline') then Exit();
  try
    if TFontStyle.fsUnderline in TBasSpeedButton(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_underline: ' + E.Message);
  end;
end;

function p_speedbutton_underline_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_underline#') then Exit();
  try
    with TBasSpeedButton(Args[0].p) do
    begin
      StyledSettings := StyledSettings - [TStyledSetting.Style];
      if Trunc(Args[1].n) <> 0 then
        TextSettings.Font.Style := TextSettings.Font.Style + [TFontStyle.fsUnderline]
      else
        TextSettings.Font.Style := TextSettings.Font.Style - [TFontStyle.fsUnderline];
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_underline#: ' + E.Message);
  end;
end;

function n_speedbutton_strikeout_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_strikeout') then Exit();
  try
    if TFontStyle.fsStrikeOut in TBasSpeedButton(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_strikeout: ' + E.Message);
  end;
end;

function p_speedbutton_strikeout_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_strikeout#') then Exit();
  try
    with TBasSpeedButton(Args[0].p) do
    begin
      StyledSettings := StyledSettings - [TStyledSetting.Style];
      if Trunc(Args[1].n) <> 0 then
        TextSettings.Font.Style := TextSettings.Font.Style + [TFontStyle.fsStrikeOut]
      else
        TextSettings.Font.Style := TextSettings.Font.Style - [TFontStyle.fsStrikeOut];
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_strikeout#: ' + E.Message);
  end;
end;

// SpeedButton-specific properties: GroupIndex (custom), StaysPressed, Down
// NOTE: FMX TSpeedButton doesn't have built-in GroupIndex like VCL.
// We provide a custom GroupIndex property for logical grouping.
// Radio-button behavior must be implemented manually in BASIC code.
function n_speedbutton_groupindex_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_groupindex') then Exit();
  try
    Result.n := TBasSpeedButton(Args[0].p).GroupIndex;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_groupindex: ' + E.Message);
  end;
end;

function p_speedbutton_groupindex_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_groupindex#') then Exit();
  try
    TBasSpeedButton(Args[0].p).GroupIndex := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_groupindex#: ' + E.Message);
  end;
end;

function n_speedbutton_stayspressed_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_stayspressed') then Exit();
  try
    if TBasSpeedButton(Args[0].p).StaysPressed then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_stayspressed: ' + E.Message);
  end;
end;

function p_speedbutton_stayspressed_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_stayspressed#') then Exit();
  try
    TBasSpeedButton(Args[0].p).StaysPressed := Trunc(Args[1].n) <> 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_stayspressed#: ' + E.Message);
  end;
end;

function n_speedbutton_down_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_down') then Exit();
  try
    if TBasSpeedButton(Args[0].p).IsPressed then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_down: ' + E.Message);
  end;
end;

function p_speedbutton_down_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_down#') then Exit();
  try
    TBasSpeedButton(Args[0].p).IsPressed := Trunc(Args[1].n) <> 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_down#: ' + E.Message);
  end;
end;

// Position and Size
function n_speedbutton_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_x') then Exit();
  try
    Result.n := TBasSpeedButton(Args[0].p).Position.X;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_x: ' + E.Message);
  end;
end;

function p_speedbutton_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_x#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Position.X := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_x#: ' + E.Message);
  end;
end;

function n_speedbutton_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_y') then Exit();
  try
    Result.n := TBasSpeedButton(Args[0].p).Position.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_y: ' + E.Message);
  end;
end;

function p_speedbutton_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_y#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Position.Y := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_y#: ' + E.Message);
  end;
end;

function n_speedbutton_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_width') then Exit();
  try
    Result.n := TBasSpeedButton(Args[0].p).Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_width: ' + E.Message);
  end;
end;

function p_speedbutton_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_width#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Width := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_width#: ' + E.Message);
  end;
end;

function n_speedbutton_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_height') then Exit();
  try
    Result.n := TBasSpeedButton(Args[0].p).Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_height: ' + E.Message);
  end;
end;

function p_speedbutton_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_height#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Height := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_height#: ' + E.Message);
  end;
end;

function p_speedbutton_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_bounds#') then Exit();
  try
    with TBasSpeedButton(Args[0].p) do
    begin
      Position.X := Args[1].n;
      Position.Y := Args[2].n;
      Width := Args[3].n;
      Height := Args[4].n;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_bounds#: ' + E.Message);
  end;
end;

function p_speedbutton_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_move#') then Exit();
  try
    with TBasSpeedButton(Args[0].p) do
    begin
      Position.X := Args[1].n;
      Position.Y := Args[2].n;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_move#: ' + E.Message);
  end;
end;

function p_speedbutton_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_size#') then Exit();
  try
    with TBasSpeedButton(Args[0].p) do
    begin
      Width := Args[1].n;
      Height := Args[2].n;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_size#: ' + E.Message);
  end;
end;

// Alignment
function n_speedbutton_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_align') then Exit();
  try
    Result.n := AlignToInt(TBasSpeedButton(Args[0].p).Align);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_align: ' + E.Message);
  end;
end;

function p_speedbutton_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_align#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Align := IntToAlign(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_align#: ' + E.Message);
  end;
end;

// Margins
function n_speedbutton_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_marginleft') then Exit();
  try
    Result.n := TBasSpeedButton(Args[0].p).Margins.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_marginleft: ' + E.Message);
  end;
end;

function p_speedbutton_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_marginleft#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Margins.Left := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_marginleft#: ' + E.Message);
  end;
end;

function n_speedbutton_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_margintop') then Exit();
  try
    Result.n := TBasSpeedButton(Args[0].p).Margins.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_margintop: ' + E.Message);
  end;
end;

function p_speedbutton_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_margintop#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Margins.Top := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_margintop#: ' + E.Message);
  end;
end;

function n_speedbutton_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_marginright') then Exit();
  try
    Result.n := TBasSpeedButton(Args[0].p).Margins.Right;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_marginright: ' + E.Message);
  end;
end;

function p_speedbutton_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_marginright#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Margins.Right := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_marginright#: ' + E.Message);
  end;
end;

function n_speedbutton_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_marginbottom') then Exit();
  try
    Result.n := TBasSpeedButton(Args[0].p).Margins.Bottom;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_marginbottom: ' + E.Message);
  end;
end;

function p_speedbutton_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_marginbottom#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_marginbottom#: ' + E.Message);
  end;
end;

function p_speedbutton_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_margins#') then Exit();
  try
    with TBasSpeedButton(Args[0].p).Margins do
    begin
      Left := Args[1].n;
      Top := Args[2].n;
      Right := Args[3].n;
      Bottom := Args[4].n;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_margins#: ' + E.Message);
  end;
end;

function p_speedbutton_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_margin#') then Exit();
  try
    with TBasSpeedButton(Args[0].p).Margins do
    begin
      Left := Args[1].n;
      Top := Args[1].n;
      Right := Args[1].n;
      Bottom := Args[1].n;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_margin#: ' + E.Message);
  end;
end;

// Visibility and state
function n_speedbutton_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_visible') then Exit();
  try
    if TBasSpeedButton(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_visible: ' + E.Message);
  end;
end;

function p_speedbutton_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_visible#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Visible := Trunc(Args[1].n) <> 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_visible#: ' + E.Message);
  end;
end;

function n_speedbutton_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_enabled') then Exit();
  try
    if TBasSpeedButton(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_enabled: ' + E.Message);
  end;
end;

function p_speedbutton_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_enabled#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Enabled := Trunc(Args[1].n) <> 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_enabled#: ' + E.Message);
  end;
end;

function n_speedbutton_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_opacity') then Exit();
  try
    Result.n := TBasSpeedButton(Args[0].p).Opacity;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_opacity: ' + E.Message);
  end;
end;

function p_speedbutton_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_opacity#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Opacity := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_opacity#: ' + E.Message);
  end;
end;

// Tag
function n_speedbutton_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_tag') then Exit();
  try
    Result.n := TBasSpeedButton(Args[0].p).Tag;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_tag: ' + E.Message);
  end;
end;

function p_speedbutton_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_tag#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Tag := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_tag#: ' + E.Message);
  end;
end;

// HitTest
function n_speedbutton_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_hittest') then Exit();
  try
    if TBasSpeedButton(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_hittest: ' + E.Message);
  end;
end;

function p_speedbutton_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_hittest#') then Exit();
  try
    TBasSpeedButton(Args[0].p).HitTest := Trunc(Args[1].n) <> 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_hittest#: ' + E.Message);
  end;
end;

// DragMode
function n_speedbutton_dragmode_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_dragmode') then Exit();
  try
    if TBasSpeedButton(Args[0].p).DragMode = TDragMode.dmAutomatic then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_dragmode: ' + E.Message);
  end;
end;

function p_speedbutton_dragmode_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_dragmode#') then Exit();
  try
    if Trunc(Args[1].n) <> 0 then
      TBasSpeedButton(Args[0].p).DragMode := TDragMode.dmAutomatic
    else
      TBasSpeedButton(Args[0].p).DragMode := TDragMode.dmManual;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_dragmode#: ' + E.Message);
  end;
end;

// Parent
function p_speedbutton_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_parent#') then Exit();
  try
    Result.p := Pointer(TBasSpeedButton(Args[0].p).Parent);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_parent#: ' + E.Message);
  end;
end;

function p_speedbutton_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_parent#') then Exit();
  if not ValidateParent(Args[1].p, 'speedbutton_parent#') then Exit();
  try
    TBasSpeedButton(Args[0].p).Parent := TFmxObject(Args[1].p);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_parent#: ' + E.Message);
  end;
end;

function p_speedbutton_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_bringtofront#') then Exit();
  try
    TBasSpeedButton(Args[0].p).BringToFront();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_bringtofront#: ' + E.Message);
  end;
end;

function p_speedbutton_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_sendtoback#') then Exit();
  try
    TBasSpeedButton(Args[0].p).SendToBack();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_sendtoback#: ' + E.Message);
  end;
end;

// Event callbacks
function p_speedbutton_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onclick#') then Exit();
  try
    TBasSpeedButton(Args[0].p).OnClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onclick#: ' + E.Message);
  end;
end;

function s_speedbutton_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onclick$') then Exit();
  try
    Result.s := TBasSpeedButton(Args[0].p).OnClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onclick$: ' + E.Message);
  end;
end;

function p_speedbutton_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onmousedown#') then Exit();
  try
    TBasSpeedButton(Args[0].p).OnMouseDownFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onmousedown#: ' + E.Message);
  end;
end;

function s_speedbutton_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onmousedown$') then Exit();
  try
    Result.s := TBasSpeedButton(Args[0].p).OnMouseDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onmousedown$: ' + E.Message);
  end;
end;

function p_speedbutton_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onmouseup#') then Exit();
  try
    TBasSpeedButton(Args[0].p).OnMouseUpFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onmouseup#: ' + E.Message);
  end;
end;

function s_speedbutton_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onmouseup$') then Exit();
  try
    Result.s := TBasSpeedButton(Args[0].p).OnMouseUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onmouseup$: ' + E.Message);
  end;
end;

function p_speedbutton_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onmousemove#') then Exit();
  try
    TBasSpeedButton(Args[0].p).OnMouseMoveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onmousemove#: ' + E.Message);
  end;
end;

function s_speedbutton_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onmousemove$') then Exit();
  try
    Result.s := TBasSpeedButton(Args[0].p).OnMouseMoveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onmousemove$: ' + E.Message);
  end;
end;

function p_speedbutton_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onmouseenter#') then Exit();
  try
    TBasSpeedButton(Args[0].p).OnMouseEnterFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onmouseenter#: ' + E.Message);
  end;
end;

function s_speedbutton_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onmouseenter$') then Exit();
  try
    Result.s := TBasSpeedButton(Args[0].p).OnMouseEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onmouseenter$: ' + E.Message);
  end;
end;

function p_speedbutton_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onmouseleave#') then Exit();
  try
    TBasSpeedButton(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onmouseleave#: ' + E.Message);
  end;
end;

function s_speedbutton_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onmouseleave$') then Exit();
  try
    Result.s := TBasSpeedButton(Args[0].p).OnMouseLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onmouseleave$: ' + E.Message);
  end;
end;

function p_speedbutton_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onresize#') then Exit();
  try
    TBasSpeedButton(Args[0].p).OnResizeFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onresize#: ' + E.Message);
  end;
end;

function s_speedbutton_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_onresize$') then Exit();
  try
    Result.s := TBasSpeedButton(Args[0].p).OnResizeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_onresize$: ' + E.Message);
  end;
end;

// Drag & Drop event callbacks
function p_speedbutton_ondragenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_ondragenter#') then Exit();
  try
    TBasSpeedButton(Args[0].p).OnDragEnterFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_ondragenter#: ' + E.Message);
  end;
end;

function s_speedbutton_ondragenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_ondragenter$') then Exit();
  try
    Result.s := TBasSpeedButton(Args[0].p).OnDragEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_ondragenter$: ' + E.Message);
  end;
end;

function p_speedbutton_ondragover_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_ondragover#') then Exit();
  try
    TBasSpeedButton(Args[0].p).OnDragOverFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_ondragover#: ' + E.Message);
  end;
end;

function s_speedbutton_ondragover_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_ondragover$') then Exit();
  try
    Result.s := TBasSpeedButton(Args[0].p).OnDragOverFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_ondragover$: ' + E.Message);
  end;
end;

function p_speedbutton_ondragdrop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_ondragdrop#') then Exit();
  try
    TBasSpeedButton(Args[0].p).OnDragDropFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_ondragdrop#: ' + E.Message);
  end;
end;

function s_speedbutton_ondragdrop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_ondragdrop$') then Exit();
  try
    Result.s := TBasSpeedButton(Args[0].p).OnDragDropFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_ondragdrop$: ' + E.Message);
  end;
end;

function p_speedbutton_ondragleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_ondragleave#') then Exit();
  try
    TBasSpeedButton(Args[0].p).OnDragLeaveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_ondragleave#: ' + E.Message);
  end;
end;

function s_speedbutton_ondragleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_ondragleave$') then Exit();
  try
    Result.s := TBasSpeedButton(Args[0].p).OnDragLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'speedbutton_ondragleave$: ' + E.Message);
  end;
end;

// Clear callbacks
function p_speedbutton_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateSpeedButton(Args[0].p, 'speedbutton_clearcallbacks#') then Exit();
  try
    with TBasSpeedButton(Args[0].p) do
    begin
      OnClickFunc := '';
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
      SetError(ERR_OPERATION_FAILED, 'speedbutton_clearcallbacks#: ' + E.Message);
  end;
end;

// Library Registration
procedure RegisterSpeedButtonFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_speedbutton_error; Lib.Add('speedbutton_error@', Fn);
  Fn.Entry := @s_speedbutton_errormsg; Lib.Add('speedbutton_errormsg$@', Fn);
  Fn.Entry := @s_speedbutton_strerror; Lib.Add('speedbutton_strerror$@n', Fn);
  Fn.Entry := @n_speedbutton_clearerror; Lib.Add('speedbutton_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_speedbutton_new; Lib.Add('speedbutton#@#', Fn);
  Fn.Entry := @p_speedbutton_new_text; Lib.Add('speedbutton#@#$', Fn);
  Fn.Entry := @p_speedbutton_new_pos; Lib.Add('speedbutton#@#nnnn', Fn);
  Fn.Entry := @p_speedbutton_new_full; Lib.Add('speedbutton#@#$nnnn', Fn);
  Fn.Entry := @n_speedbutton_free; Lib.Add('speedbutton_free@#', Fn);

  // Text content
  Fn.Entry := @s_speedbutton_text_get; Lib.Add('speedbutton_text$@#', Fn);
  Fn.Entry := @p_speedbutton_text_set; Lib.Add('speedbutton_text#@#$', Fn);

  // Font properties
  Fn.Entry := @s_speedbutton_fontfamily_get; Lib.Add('speedbutton_fontfamily$@#', Fn);
  Fn.Entry := @p_speedbutton_fontfamily_set; Lib.Add('speedbutton_fontfamily#@#$', Fn);
  Fn.Entry := @n_speedbutton_fontsize_get; Lib.Add('speedbutton_fontsize@#', Fn);
  Fn.Entry := @p_speedbutton_fontsize_set; Lib.Add('speedbutton_fontsize#@#n', Fn);
  Fn.Entry := @s_speedbutton_fontcolor_get; Lib.Add('speedbutton_fontcolor$@#', Fn);
  Fn.Entry := @p_speedbutton_fontcolor_set; Lib.Add('speedbutton_fontcolor#@#$', Fn);
  Fn.Entry := @n_speedbutton_bold_get; Lib.Add('speedbutton_bold@#', Fn);
  Fn.Entry := @p_speedbutton_bold_set; Lib.Add('speedbutton_bold#@#n', Fn);
  Fn.Entry := @n_speedbutton_italic_get; Lib.Add('speedbutton_italic@#', Fn);
  Fn.Entry := @p_speedbutton_italic_set; Lib.Add('speedbutton_italic#@#n', Fn);
  Fn.Entry := @n_speedbutton_underline_get; Lib.Add('speedbutton_underline@#', Fn);
  Fn.Entry := @p_speedbutton_underline_set; Lib.Add('speedbutton_underline#@#n', Fn);
  Fn.Entry := @n_speedbutton_strikeout_get; Lib.Add('speedbutton_strikeout@#', Fn);
  Fn.Entry := @p_speedbutton_strikeout_set; Lib.Add('speedbutton_strikeout#@#n', Fn);

  // SpeedButton-specific properties
  Fn.Entry := @n_speedbutton_groupindex_get; Lib.Add('speedbutton_groupindex@#', Fn);
  Fn.Entry := @p_speedbutton_groupindex_set; Lib.Add('speedbutton_groupindex#@#n', Fn);
  Fn.Entry := @n_speedbutton_stayspressed_get; Lib.Add('speedbutton_stayspressed@#', Fn);
  Fn.Entry := @p_speedbutton_stayspressed_set; Lib.Add('speedbutton_stayspressed#@#n', Fn);
  Fn.Entry := @n_speedbutton_down_get; Lib.Add('speedbutton_down@#', Fn);
  Fn.Entry := @p_speedbutton_down_set; Lib.Add('speedbutton_down#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_speedbutton_x_get; Lib.Add('speedbutton_x@#', Fn);
  Fn.Entry := @p_speedbutton_x_set; Lib.Add('speedbutton_x#@#n', Fn);
  Fn.Entry := @n_speedbutton_y_get; Lib.Add('speedbutton_y@#', Fn);
  Fn.Entry := @p_speedbutton_y_set; Lib.Add('speedbutton_y#@#n', Fn);
  Fn.Entry := @n_speedbutton_width_get; Lib.Add('speedbutton_width@#', Fn);
  Fn.Entry := @p_speedbutton_width_set; Lib.Add('speedbutton_width#@#n', Fn);
  Fn.Entry := @n_speedbutton_height_get; Lib.Add('speedbutton_height@#', Fn);
  Fn.Entry := @p_speedbutton_height_set; Lib.Add('speedbutton_height#@#n', Fn);
  Fn.Entry := @p_speedbutton_bounds_set; Lib.Add('speedbutton_bounds#@#nnnn', Fn);
  Fn.Entry := @p_speedbutton_move_set; Lib.Add('speedbutton_move#@#nn', Fn);
  Fn.Entry := @p_speedbutton_size_set; Lib.Add('speedbutton_size#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_speedbutton_align_get; Lib.Add('speedbutton_align@#', Fn);
  Fn.Entry := @p_speedbutton_align_set; Lib.Add('speedbutton_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_speedbutton_marginleft_get; Lib.Add('speedbutton_marginleft@#', Fn);
  Fn.Entry := @p_speedbutton_marginleft_set; Lib.Add('speedbutton_marginleft#@#n', Fn);
  Fn.Entry := @n_speedbutton_margintop_get; Lib.Add('speedbutton_margintop@#', Fn);
  Fn.Entry := @p_speedbutton_margintop_set; Lib.Add('speedbutton_margintop#@#n', Fn);
  Fn.Entry := @n_speedbutton_marginright_get; Lib.Add('speedbutton_marginright@#', Fn);
  Fn.Entry := @p_speedbutton_marginright_set; Lib.Add('speedbutton_marginright#@#n', Fn);
  Fn.Entry := @n_speedbutton_marginbottom_get; Lib.Add('speedbutton_marginbottom@#', Fn);
  Fn.Entry := @p_speedbutton_marginbottom_set; Lib.Add('speedbutton_marginbottom#@#n', Fn);
  Fn.Entry := @p_speedbutton_margins_set; Lib.Add('speedbutton_margins#@#nnnn', Fn);
  Fn.Entry := @p_speedbutton_margin_set; Lib.Add('speedbutton_margin#@#n', Fn);

  // Visibility and state
  Fn.Entry := @n_speedbutton_visible_get; Lib.Add('speedbutton_visible@#', Fn);
  Fn.Entry := @p_speedbutton_visible_set; Lib.Add('speedbutton_visible#@#n', Fn);
  Fn.Entry := @n_speedbutton_enabled_get; Lib.Add('speedbutton_enabled@#', Fn);
  Fn.Entry := @p_speedbutton_enabled_set; Lib.Add('speedbutton_enabled#@#n', Fn);
  Fn.Entry := @n_speedbutton_opacity_get; Lib.Add('speedbutton_opacity@#', Fn);
  Fn.Entry := @p_speedbutton_opacity_set; Lib.Add('speedbutton_opacity#@#n', Fn);

  // Tag
  Fn.Entry := @n_speedbutton_tag_get; Lib.Add('speedbutton_tag@#', Fn);
  Fn.Entry := @p_speedbutton_tag_set; Lib.Add('speedbutton_tag#@#n', Fn);

  // HitTest
  Fn.Entry := @n_speedbutton_hittest_get; Lib.Add('speedbutton_hittest@#', Fn);
  Fn.Entry := @p_speedbutton_hittest_set; Lib.Add('speedbutton_hittest#@#n', Fn);

  // DragMode
  Fn.Entry := @n_speedbutton_dragmode_get; Lib.Add('speedbutton_dragmode@#', Fn);
  Fn.Entry := @p_speedbutton_dragmode_set; Lib.Add('speedbutton_dragmode#@#n', Fn);

  // Parent
  Fn.Entry := @p_speedbutton_parent_get; Lib.Add('speedbutton_parent#@#', Fn);
  Fn.Entry := @p_speedbutton_parent_set; Lib.Add('speedbutton_parent#@##', Fn);
  Fn.Entry := @p_speedbutton_bringtofront; Lib.Add('speedbutton_bringtofront#@#', Fn);
  Fn.Entry := @p_speedbutton_sendtoback; Lib.Add('speedbutton_sendtoback#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_speedbutton_onclick_set; Lib.Add('speedbutton_onclick#@#$', Fn);
  Fn.Entry := @s_speedbutton_onclick_get; Lib.Add('speedbutton_onclick$@#', Fn);
  Fn.Entry := @p_speedbutton_onmousedown_set; Lib.Add('speedbutton_onmousedown#@#$', Fn);
  Fn.Entry := @s_speedbutton_onmousedown_get; Lib.Add('speedbutton_onmousedown$@#', Fn);
  Fn.Entry := @p_speedbutton_onmouseup_set; Lib.Add('speedbutton_onmouseup#@#$', Fn);
  Fn.Entry := @s_speedbutton_onmouseup_get; Lib.Add('speedbutton_onmouseup$@#', Fn);
  Fn.Entry := @p_speedbutton_onmousemove_set; Lib.Add('speedbutton_onmousemove#@#$', Fn);
  Fn.Entry := @s_speedbutton_onmousemove_get; Lib.Add('speedbutton_onmousemove$@#', Fn);
  Fn.Entry := @p_speedbutton_onmouseenter_set; Lib.Add('speedbutton_onmouseenter#@#$', Fn);
  Fn.Entry := @s_speedbutton_onmouseenter_get; Lib.Add('speedbutton_onmouseenter$@#', Fn);
  Fn.Entry := @p_speedbutton_onmouseleave_set; Lib.Add('speedbutton_onmouseleave#@#$', Fn);
  Fn.Entry := @s_speedbutton_onmouseleave_get; Lib.Add('speedbutton_onmouseleave$@#', Fn);
  Fn.Entry := @p_speedbutton_onresize_set; Lib.Add('speedbutton_onresize#@#$', Fn);
  Fn.Entry := @s_speedbutton_onresize_get; Lib.Add('speedbutton_onresize$@#', Fn);

  // Drag & Drop event callbacks
  Fn.Entry := @p_speedbutton_ondragenter_set; Lib.Add('speedbutton_ondragenter#@#$', Fn);
  Fn.Entry := @s_speedbutton_ondragenter_get; Lib.Add('speedbutton_ondragenter$@#', Fn);
  Fn.Entry := @p_speedbutton_ondragover_set; Lib.Add('speedbutton_ondragover#@#$', Fn);
  Fn.Entry := @s_speedbutton_ondragover_get; Lib.Add('speedbutton_ondragover$@#', Fn);
  Fn.Entry := @p_speedbutton_ondragdrop_set; Lib.Add('speedbutton_ondragdrop#@#$', Fn);
  Fn.Entry := @s_speedbutton_ondragdrop_get; Lib.Add('speedbutton_ondragdrop$@#', Fn);
  Fn.Entry := @p_speedbutton_ondragleave_set; Lib.Add('speedbutton_ondragleave#@#$', Fn);
  Fn.Entry := @s_speedbutton_ondragleave_get; Lib.Add('speedbutton_ondragleave$@#', Fn);

  // Clear callbacks
  Fn.Entry := @p_speedbutton_clearcallbacks; Lib.Add('speedbutton_clearcallbacks#@#', Fn);
end;

end.

