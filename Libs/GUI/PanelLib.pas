unit PanelLib;

{******************************************************************************
  PanelLib - Panel Container Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TPanel wrapper functionality for creating and
  managing styled container controls in Plan9Basic programs. TPanel is a
  visual container control with a styled background appearance that can
  organize child controls with alignment and positioning.

  Function Count: 82 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All panels are created at RUNTIME using TPanel.Create with dynamic parent
  assignment. This ensures proper dynamic creation across all FireMonkey platforms.

  FEATURES:
  =========
  - Panel creation and lifecycle management
  - Comprehensive property access (position, size, alignment, margins, padding)
  - Parent/child relationship management
  - Visual styled background (unlike TLayout which is invisible)
  - Complete event support with BASIC callback integration
  - Full drag and drop support
  - Clipping and hit-testing control

  EVENTS SUPPORT:
  ===============
  - OnClick: Panel was clicked
  - OnDblClick: Panel was double-clicked
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over panel
  - OnMouseEnter: Mouse entered panel area
  - OnMouseLeave: Mouse left panel area
  - OnMouseWheel: Mouse wheel scrolled
  - OnResize: Panel is being resized
  - OnResized: Panel resize completed
  - OnDragEnter: Drag operation entered
  - OnDragOver: Dragging over panel
  - OnDragDrop: Item dropped on panel
  - OnDragLeave: Drag operation left

  ALIGNMENT VALUES:
  =================
  0 = None         - No alignment (manual positioning)
  1 = Top          - Align to top
  2 = Left         - Align to left
  3 = Right        - Align to right
  4 = Bottom       - Align to bottom
  5 = MostTop      - Align to very top (above Top)
  6 = MostBottom   - Align to very bottom (below Bottom)
  7 = MostLeft     - Align to very left (before Left)
  8 = MostRight    - Align to very right (after Right)
  9 = Client       - Fill remaining client area
  10 = Contents    - Fit to contents
  11 = Center      - Center in parent
  12 = VertCenter  - Center vertically
  13 = HorzCenter  - Center horizontally
  14 = Horizontal  - Stretch horizontally
  15 = Vertical    - Stretch vertically
  16 = Scale       - Scale proportionally
  17 = Fit         - Fit within parent
  18 = FitLeft     - Fit and align left
  19 = FitRight    - Fit and align right

  USAGE PATTERN:
  ==============
    let frm# = form#("My App", 800, 600)

    ' Create main panel filling the form
    let mainPanel# = panel#(frm#)
    panel_align#(mainPanel#, 9)  ' Client fill

    ' Create a top bar panel
    let topBar# = panel#(mainPanel#)
    panel_align#(topBar#, 1)      ' Top alignment
    panel_height#(topBar#, 50)

    ' Create content panel
    let content# = panel#(mainPanel#)
    panel_align#(content#, 9)     ' Fill remaining

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnPanelClick(sender#)
      println "Panel clicked!"
    endfunction

    function OnPanelMouseMove(sender#, x, y, shift$)
      println "Mouse at: " + stri$(x) + ", " + stri$(y)
    endfunction

    function OnPanelDragOver(sender#, x, y) local accept
      ' Accept the drop
      return 1
    endfunction

    function OnPanelDragDrop(sender#, x, y)
      println "Dropped at: " + stri$(x) + ", " + stri$(y)
    endfunction

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.StdCtrls,
  FMX.Controls.Presentation,
  basic, exec, UnitGC, HandleRegistry, ControlCommon;

type
  // Forward declaration
  TBasPanel = class;

  {****************************************************************************
    TBasPanel - Extended TPanel with BASIC event callback support

    Wraps a TPanel and provides event bridging to Plan9Basic user functions.
    Each event stores the name of a BASIC function to call when triggered.
  ****************************************************************************}
  TBasPanel = class(TPanel)
  private
    // Event callback function names (stored in lowercase+signature format)
    FOnClickFunc: String;
    FOnDblClickFunc: String;
    FOnMouseDownFunc: String;
    FOnMouseUpFunc: String;
    FOnMouseMoveFunc: String;
    FOnMouseEnterFunc: String;
    FOnMouseLeaveFunc: String;
    FOnMouseWheelFunc: String;
    FOnResizeFunc: String;
    FOnResizedFunc: String;
    FOnDragEnterFunc: String;
    FOnDragOverFunc: String;
    FOnDragDropFunc: String;
    FOnDragLeaveFunc: String;

    // Engine references for callback execution
    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;

    // Internal event handlers
    procedure InternalOnClick(Sender: TObject);
    procedure InternalOnDblClick(Sender: TObject);
    procedure InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseEnter(Sender: TObject);
    procedure InternalOnMouseLeave(Sender: TObject);
    procedure InternalOnMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
    procedure InternalOnResize(Sender: TObject);
    procedure InternalOnResized(Sender: TObject);
    procedure InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
    procedure InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure InternalOnDragLeave(Sender: TObject);

    // Callback execution helper
    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
    function ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;

    // Property setters that connect/disconnect individual events
    procedure SetOnClickFunc(const Value: String);
    procedure SetOnDblClickFunc(const Value: String);
    procedure SetOnMouseDownFunc(const Value: String);
    procedure SetOnMouseUpFunc(const Value: String);
    procedure SetOnMouseMoveFunc(const Value: String);
    procedure SetOnMouseEnterFunc(const Value: String);
    procedure SetOnMouseLeaveFunc(const Value: String);
    procedure SetOnMouseWheelFunc(const Value: String);
    procedure SetOnResizeFunc(const Value: String);
    procedure SetOnResizedFunc(const Value: String);
    procedure SetOnDragEnterFunc(const Value: String);
    procedure SetOnDragOverFunc(const Value: String);
    procedure SetOnDragDropFunc(const Value: String);
    procedure SetOnDragLeaveFunc(const Value: String);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    // Disconnect all events (for cleanup)
    procedure DisconnectEvents();

    // Check if callback exists
    function CallbackExists(const FuncName: String): Boolean;

    // Properties for event function names
    property OnClickFunc: String read FOnClickFunc write SetOnClickFunc;
    property OnDblClickFunc: String read FOnDblClickFunc write SetOnDblClickFunc;
    property OnMouseDownFunc: String read FOnMouseDownFunc write SetOnMouseDownFunc;
    property OnMouseUpFunc: String read FOnMouseUpFunc write SetOnMouseUpFunc;
    property OnMouseMoveFunc: String read FOnMouseMoveFunc write SetOnMouseMoveFunc;
    property OnMouseEnterFunc: String read FOnMouseEnterFunc write SetOnMouseEnterFunc;
    property OnMouseLeaveFunc: String read FOnMouseLeaveFunc write SetOnMouseLeaveFunc;
    property OnMouseWheelFunc: String read FOnMouseWheelFunc write SetOnMouseWheelFunc;
    property OnResizeFunc: String read FOnResizeFunc write SetOnResizeFunc;
    property OnResizedFunc: String read FOnResizedFunc write SetOnResizedFunc;
    property OnDragEnterFunc: String read FOnDragEnterFunc write SetOnDragEnterFunc;
    property OnDragOverFunc: String read FOnDragOverFunc write SetOnDragOverFunc;
    property OnDragDropFunc: String read FOnDragDropFunc write SetOnDragDropFunc;
    property OnDragLeaveFunc: String read FOnDragLeaveFunc write SetOnDragLeaveFunc;

    // Engine references
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
  end;

// Library registration
procedure RegisterPanelFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  PANEL_GC_TAG = 'BASIC_PANEL';

  // Error codes
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_PANEL = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INVALID_CALLBACK = 5;
  ERR_INVALID_CONTROL = 6;

  // Alignment constants (matching TAlignLayout)

var
  lastError: Integer;
  lastErrorMsg: String;

  // Module-level references for event callback support

//==============================================================================
// Helper Functions
//==============================================================================

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

function ValidatePanel(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_PANEL, FuncName + ': Nil panel pointer');
    Exit;
  end;

  // Use try-except because "is" operator can crash on invalid pointers
  try
    if not (IsHandleOf(P, TBasPanel)) then
    begin
      SetError(ERR_INVALID_PANEL, FuncName + ': Invalid panel object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_PANEL, FuncName + ': Invalid panel pointer');
    Exit;
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

function ValidateControl(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_CONTROL, FuncName + ': Nil control pointer');
    Exit;
  end;

  try
    if not (IsHandleOf(P, TFmxObject)) then
    begin
      SetError(ERR_INVALID_CONTROL, FuncName + ': Invalid control object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_CONTROL, FuncName + ': Invalid control pointer');
    Exit;
  end;

  ClearError();
  Result := True;
end;

//==============================================================================
// TBasPanel Implementation
//==============================================================================

constructor TBasPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);

  // Initialize callback function names
  FOnClickFunc := '';
  FOnDblClickFunc := '';
  FOnMouseDownFunc := '';
  FOnMouseUpFunc := '';
  FOnMouseMoveFunc := '';
  FOnMouseEnterFunc := '';
  FOnMouseLeaveFunc := '';
  FOnMouseWheelFunc := '';
  FOnResizeFunc := '';
  FOnResizedFunc := '';
  FOnDragEnterFunc := '';
  FOnDragOverFunc := '';
  FOnDragDropFunc := '';
  FOnDragLeaveFunc := '';

  // Initialize engine references
  FBasicEngine := nil;
  FConsoleOutput := nil;

  // Enable hit testing by default for mouse events
  HitTest := True;
end;

destructor TBasPanel.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectEvents();
  inherited Destroy();
end;

procedure TBasPanel.DisconnectEvents();
begin
  Self.OnClick := nil;
  Self.OnDblClick := nil;
  Self.OnMouseDown := nil;
  Self.OnMouseUp := nil;
  Self.OnMouseMove := nil;
  Self.OnMouseEnter := nil;
  Self.OnMouseLeave := nil;
  Self.OnMouseWheel := nil;
  Self.OnResize := nil;
  Self.OnResized := nil;
  Self.OnDragEnter := nil;
  Self.OnDragOver := nil;
  Self.OnDragDrop := nil;
  Self.OnDragLeave := nil;
end;

function TBasPanel.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

procedure TBasPanel.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'Panel');
end;

function TBasPanel.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
begin
  Result := ControlCommon.RunCallbackWithResult(FBasicEngine, FConsoleOutput,
                          FuncSignature, Args, 'Panel');
end;

procedure TBasPanel.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnClickFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  Signature := LowerCase(FOnClickFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasPanel.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnDblClickFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  Signature := LowerCase(FOnDblClickFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasPanel.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
  Signature: String;
begin
  if FOnMouseDownFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nnn$ (sender#, button, x, y, shift$)
  Signature := LowerCase(FOnMouseDownFunc) + '@#nnn$';

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

  ExecuteCallback(Signature, Args);
end;

procedure TBasPanel.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
  Signature: String;
begin
  if FOnMouseUpFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nnn$ (sender#, button, x, y, shift$)
  Signature := LowerCase(FOnMouseUpFunc) + '@#nnn$';

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

  ExecuteCallback(Signature, Args);
end;

procedure TBasPanel.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..3] of TAsmData;
  Signature: String;
begin
  if FOnMouseMoveFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nn$ (sender#, x, y, shift$)
  Signature := LowerCase(FOnMouseMoveFunc) + '@#nn$';

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

  ExecuteCallback(Signature, Args);
end;

procedure TBasPanel.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnMouseEnterFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  Signature := LowerCase(FOnMouseEnterFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasPanel.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnMouseLeaveFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  Signature := LowerCase(FOnMouseLeaveFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasPanel.InternalOnMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
  RetVal: TAsmData;
begin
  if FOnMouseWheelFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#n$ (sender#, delta, shift$) -> returns handled
  Signature := LowerCase(FOnMouseWheelFunc) + '@#n$';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := WheelDelta;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := 0;
  Args[2].p := nil;
  Args[2].s := BuildShiftString(Shift);

  RetVal := ExecuteCallbackWithResult(Signature, Args);
  Handled := (RetVal.n <> 0);
end;

procedure TBasPanel.InternalOnResize(Sender: TObject);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnResizeFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nn (sender#, width, height)
  Signature := LowerCase(FOnResizeFunc) + '@#nn';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := Self.Width;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := Self.Height;
  Args[2].p := nil;
  Args[2].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasPanel.InternalOnResized(Sender: TObject);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnResizedFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nn (sender#, width, height)
  Signature := LowerCase(FOnResizedFunc) + '@#nn';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := Self.Width;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := Self.Height;
  Args[2].p := nil;
  Args[2].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasPanel.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnDragEnterFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nn (sender#, x, y)
  Signature := LowerCase(FOnDragEnterFunc) + '@#nn';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasPanel.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
  RetVal: TAsmData;
begin
  if FOnDragOverFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nn (sender#, x, y) -> returns accept (0/1)
  Signature := LowerCase(FOnDragOverFunc) + '@#nn';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';

  RetVal := ExecuteCallbackWithResult(Signature, Args);
  if RetVal.n <> 0 then
    Operation := TDragOperation.Move
  else
    Operation := TDragOperation.None;
end;

procedure TBasPanel.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnDragDropFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nn (sender#, x, y)
  Signature := LowerCase(FOnDragDropFunc) + '@#nn';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasPanel.InternalOnDragLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnDragLeaveFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  Signature := LowerCase(FOnDragLeaveFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

// Property setters that connect/disconnect individual events

procedure TBasPanel.SetOnClickFunc(const Value: String);
begin
  ControlCommon.BindClick(Self, Value, FOnClickFunc, InternalOnClick);
end;

procedure TBasPanel.SetOnDblClickFunc(const Value: String);
begin
  ControlCommon.BindDblClick(Self, Value, FOnDblClickFunc, InternalOnDblClick);
end;

procedure TBasPanel.SetOnMouseDownFunc(const Value: String);
begin
  ControlCommon.BindMouseDown(Self, Value, FOnMouseDownFunc, InternalOnMouseDown);
end;

procedure TBasPanel.SetOnMouseUpFunc(const Value: String);
begin
  ControlCommon.BindMouseUp(Self, Value, FOnMouseUpFunc, InternalOnMouseUp);
end;

procedure TBasPanel.SetOnMouseMoveFunc(const Value: String);
begin
  ControlCommon.BindMouseMove(Self, Value, FOnMouseMoveFunc, InternalOnMouseMove);
end;

procedure TBasPanel.SetOnMouseEnterFunc(const Value: String);
begin
  ControlCommon.BindMouseEnter(Self, Value, FOnMouseEnterFunc, InternalOnMouseEnter);
end;

procedure TBasPanel.SetOnMouseLeaveFunc(const Value: String);
begin
  ControlCommon.BindMouseLeave(Self, Value, FOnMouseLeaveFunc, InternalOnMouseLeave);
end;

procedure TBasPanel.SetOnMouseWheelFunc(const Value: String);
begin
  ControlCommon.BindMouseWheel(Self, Value, FOnMouseWheelFunc, InternalOnMouseWheel);
end;

procedure TBasPanel.SetOnResizeFunc(const Value: String);
begin
  ControlCommon.BindResize(Self, Value, FOnResizeFunc, InternalOnResize);
end;

procedure TBasPanel.SetOnResizedFunc(const Value: String);
begin
  ControlCommon.BindResized(Self, Value, FOnResizedFunc, InternalOnResized);
end;

procedure TBasPanel.SetOnDragEnterFunc(const Value: String);
begin
  ControlCommon.BindDragEnter(Self, Value, FOnDragEnterFunc, InternalOnDragEnter);
end;

procedure TBasPanel.SetOnDragOverFunc(const Value: String);
begin
  ControlCommon.BindDragOver(Self, Value, FOnDragOverFunc, InternalOnDragOver);
end;

procedure TBasPanel.SetOnDragDropFunc(const Value: String);
begin
  ControlCommon.BindDragDrop(Self, Value, FOnDragDropFunc, InternalOnDragDrop);
end;

procedure TBasPanel.SetOnDragLeaveFunc(const Value: String);
begin
  ControlCommon.BindDragLeave(Self, Value, FOnDragLeaveFunc, InternalOnDragLeave);
end;

//==============================================================================
// Library Functions - Error Handling
//==============================================================================

// panel_error() - Get last error code
function n_panel_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

// panel_errormsg$() - Get last error message
function s_panel_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

// panel_strerror$(code) - Get error description
function s_panel_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_PANEL: Result.s := 'Invalid or nil panel';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent control';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Panel creation failed';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback function';
    ERR_INVALID_CONTROL: Result.s := 'Invalid control';
  else
    Result.s := 'Unknown error: ' + IntToStr(Code);
  end;
end;

// panel_clearerror() - Clear error state
function n_panel_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

//==============================================================================
// Library Functions - Panel Creation and Destruction
//==============================================================================

// panel#(parent#) - Create a new panel with parent
function p_panel_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Panel: TBasPanel;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'panel#') then Exit;

  try
    ParentObj := TFmxObject(Args[0].p);
    Panel := TBasPanel.Create(nil);
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Panel, Eng, Outp) then
    begin
      Panel.BasicEngine := Eng;
      Panel.ConsoleOutput := Outp;
    end;
    Panel.Parent := ParentObj;

    // Set sensible defaults
    Panel.Width := 100;
    Panel.Height := 100;
    Panel.Align := TAlignLayout.None;

    Result.p := Pointer(Panel);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Panel, PANEL_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'panel#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// panel#(parent#, width, height) - Create with size
function p_panel_new_size(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Panel: TBasPanel;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'panel#') then Exit;

  try
    ParentObj := TFmxObject(Args[0].p);
    Panel := TBasPanel.Create(nil);
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Panel, Eng, Outp) then
    begin
      Panel.BasicEngine := Eng;
      Panel.ConsoleOutput := Outp;
    end;
    Panel.Parent := ParentObj;

    Panel.Width := Args[1].n;
    Panel.Height := Args[2].n;
    Panel.Align := TAlignLayout.None;

    Result.p := Pointer(Panel);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Panel, PANEL_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'panel#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// panel#(parent#, x, y, width, height) - Create with position and size
function p_panel_new_full(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Panel: TBasPanel;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'panel#') then Exit;

  try
    ParentObj := TFmxObject(Args[0].p);
    Panel := TBasPanel.Create(nil);
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Panel, Eng, Outp) then
    begin
      Panel.BasicEngine := Eng;
      Panel.ConsoleOutput := Outp;
    end;
    Panel.Parent := ParentObj;

    Panel.Position.X := Args[1].n;
    Panel.Position.Y := Args[2].n;
    Panel.Width := Args[3].n;
    Panel.Height := Args[4].n;
    Panel.Align := TAlignLayout.None;

    Result.p := Pointer(Panel);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Panel, PANEL_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'panel#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// panel_free(panel#) - Free a panel
function n_panel_free(var Args: array of TAsmData): TAsmData;
var
  Panel: TBasPanel;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_free') then Exit;

  try
    Panel := TBasPanel(Args[0].p);
    Panel.DisconnectEvents;
    Panel.Free();

    // Use GC to properly free the panel
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
    //Its eighty-one siblings answer 1 on success. This one did too, inside
    //the collector block that was commented out.
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PANEL, 'panel_free: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Parent/Child Management
//==============================================================================

// panel_parent#(panel#) - Get parent
function p_panel_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_parent#') then Exit;

  try
    Result.p := Pointer(TBasPanel(Args[0].p).Parent);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_parent#: ' + E.Message);
  end;
end;

// panel_parent#(panel#, parent#) - Set parent
function p_panel_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_parent#') then Exit;
  if not ValidateParent(Args[1].p, 'panel_parent#') then Exit;

  try
    TBasPanel(Args[0].p).Parent := TFmxObject(Args[1].p);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_parent#: ' + E.Message);
  end;
end;

// panel_childcount(panel#) - Get number of children
function n_panel_childcount(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_childcount') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).ChildrenCount;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_childcount: ' + E.Message);
  end;
end;

// panel_child#(panel#, index) - Get child by index
function p_panel_child(var Args: array of TAsmData): TAsmData;
var
  Panel: TBasPanel;
  Index: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_child#') then Exit;

  try
    Panel := TBasPanel(Args[0].p);
    Index := Trunc(Args[1].n);
    if (Index >= 0) and (Index < Panel.ChildrenCount) then
      Result.p := Pointer(Panel.Children[Index])
    else
      SetError(ERR_INVALID_VALUE, 'panel_child#: Index out of bounds');
  except
    on E: Exception do
      SetError(ERR_INVALID_PANEL, 'panel_child#: ' + E.Message);
  end;
end;

// panel_bringtofront#(panel#) - Bring panel to front
function p_panel_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_bringtofront#') then Exit;

  try
    TBasPanel(Args[0].p).BringToFront;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_bringtofront#: ' + E.Message);
  end;
end;

// panel_sendtoback#(panel#) - Send panel to back
function p_panel_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_sendtoback#') then Exit;

  try
    TBasPanel(Args[0].p).SendToBack;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_sendtoback#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Position and Size
//==============================================================================

// panel_x(panel#) - Get X position
function n_panel_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_x') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Position.X;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_x: ' + E.Message);
  end;
end;

// panel_x#(panel#, value) - Set X position
function p_panel_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_x#') then Exit;

  try
    TBasPanel(Args[0].p).Position.X := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_x#: ' + E.Message);
  end;
end;

// panel_y(panel#) - Get Y position
function n_panel_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_y') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Position.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_y: ' + E.Message);
  end;
end;

// panel_y#(panel#, value) - Set Y position
function p_panel_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_y#') then Exit;

  try
    TBasPanel(Args[0].p).Position.Y := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_y#: ' + E.Message);
  end;
end;

// panel_width(panel#) - Get width
function n_panel_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_width') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_width: ' + E.Message);
  end;
end;

// panel_width#(panel#, value) - Set width
function p_panel_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_width#') then Exit;

  try
    TBasPanel(Args[0].p).Width := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_width#: ' + E.Message);
  end;
end;

// panel_height(panel#) - Get height
function n_panel_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_height') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_height: ' + E.Message);
  end;
end;

// panel_height#(panel#, value) - Set height
function p_panel_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_height#') then Exit;

  try
    TBasPanel(Args[0].p).Height := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_height#: ' + E.Message);
  end;
end;

// panel_bounds#(panel#, x, y, width, height) - Set all bounds
function p_panel_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_bounds#') then Exit;

  try
    with TBasPanel(Args[0].p) do
    begin
      Position.X := Args[1].n;
      Position.Y := Args[2].n;
      Width := Args[3].n;
      Height := Args[4].n;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_bounds#: ' + E.Message);
  end;
end;

// panel_size#(panel#, width, height) - Set size
function p_panel_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_size#') then Exit;

  try
    with TBasPanel(Args[0].p) do
    begin
      Width := Args[1].n;
      Height := Args[2].n;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_size#: ' + E.Message);
  end;
end;

// panel_move#(panel#, x, y) - Set position
function p_panel_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_move#') then Exit;

  try
    with TBasPanel(Args[0].p) do
    begin
      Position.X := Args[1].n;
      Position.Y := Args[2].n;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_move#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Alignment
//==============================================================================

// panel_align(panel#) - Get alignment
function n_panel_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_align') then Exit;

  try
    Result.n := AlignToInt(TBasPanel(Args[0].p).Align);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_align: ' + E.Message);
  end;
end;

// panel_align#(panel#, value) - Set alignment
function p_panel_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_align#') then Exit;

  try
    TBasPanel(Args[0].p).Align := AlignFromInt(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_align#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Margins
//==============================================================================

// panel_marginleft(panel#) - Get left margin
function n_panel_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_marginleft') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Margins.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_marginleft: ' + E.Message);
  end;
end;

// panel_marginleft#(panel#, value) - Set left margin
function p_panel_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_marginleft#') then Exit;

  try
    TBasPanel(Args[0].p).Margins.Left := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_marginleft#: ' + E.Message);
  end;
end;

// panel_margintop(panel#) - Get top margin
function n_panel_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_margintop') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Margins.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_margintop: ' + E.Message);
  end;
end;

// panel_margintop#(panel#, value) - Set top margin
function p_panel_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_margintop#') then Exit;

  try
    TBasPanel(Args[0].p).Margins.Top := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_margintop#: ' + E.Message);
  end;
end;

// panel_marginright(panel#) - Get right margin
function n_panel_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_marginright') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Margins.Right;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_marginright: ' + E.Message);
  end;
end;

// panel_marginright#(panel#, value) - Set right margin
function p_panel_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_marginright#') then Exit;

  try
    TBasPanel(Args[0].p).Margins.Right := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_marginright#: ' + E.Message);
  end;
end;

// panel_marginbottom(panel#) - Get bottom margin
function n_panel_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_marginbottom') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Margins.Bottom;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_marginbottom: ' + E.Message);
  end;
end;

// panel_marginbottom#(panel#, value) - Set bottom margin
function p_panel_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_marginbottom#') then Exit;

  try
    TBasPanel(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_marginbottom#: ' + E.Message);
  end;
end;

// panel_margins#(panel#, left, top, right, bottom) - Set all margins
function p_panel_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_margins#') then Exit;

  try
    with TBasPanel(Args[0].p).Margins do
    begin
      Left := Args[1].n;
      Top := Args[2].n;
      Right := Args[3].n;
      Bottom := Args[4].n;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_margins#: ' + E.Message);
  end;
end;

// panel_margin#(panel#, value) - Set all margins to same value
function p_panel_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_margin#') then Exit;

  try
    with TBasPanel(Args[0].p).Margins do
    begin
      Left := Args[1].n;
      Top := Args[1].n;
      Right := Args[1].n;
      Bottom := Args[1].n;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_margin#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Padding
//==============================================================================

// panel_paddingleft(panel#) - Get left padding
function n_panel_paddingleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_paddingleft') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Padding.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_paddingleft: ' + E.Message);
  end;
end;

// panel_paddingleft#(panel#, value) - Set left padding
function p_panel_paddingleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_paddingleft#') then Exit;

  try
    TBasPanel(Args[0].p).Padding.Left := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_paddingleft#: ' + E.Message);
  end;
end;

// panel_paddingtop(panel#) - Get top padding
function n_panel_paddingtop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_paddingtop') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Padding.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_paddingtop: ' + E.Message);
  end;
end;

// panel_paddingtop#(panel#, value) - Set top padding
function p_panel_paddingtop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_paddingtop#') then Exit;

  try
    TBasPanel(Args[0].p).Padding.Top := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_paddingtop#: ' + E.Message);
  end;
end;

// panel_paddingright(panel#) - Get right padding
function n_panel_paddingright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_paddingright') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Padding.Right;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_paddingright: ' + E.Message);
  end;
end;

// panel_paddingright#(panel#, value) - Set right padding
function p_panel_paddingright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_paddingright#') then Exit;

  try
    TBasPanel(Args[0].p).Padding.Right := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_paddingright#: ' + E.Message);
  end;
end;

// panel_paddingbottom(panel#) - Get bottom padding
function n_panel_paddingbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_paddingbottom') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Padding.Bottom;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_paddingbottom: ' + E.Message);
  end;
end;

// panel_paddingbottom#(panel#, value) - Set bottom padding
function p_panel_paddingbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_paddingbottom#') then Exit;

  try
    TBasPanel(Args[0].p).Padding.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_paddingbottom#: ' + E.Message);
  end;
end;

// panel_paddings#(panel#, left, top, right, bottom) - Set all paddings
function p_panel_paddings_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_paddings#') then Exit;

  try
    with TBasPanel(Args[0].p).Padding do
    begin
      Left := Args[1].n;
      Top := Args[2].n;
      Right := Args[3].n;
      Bottom := Args[4].n;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_paddings#: ' + E.Message);
  end;
end;

// panel_padding#(panel#, value) - Set all paddings to same value
function p_panel_padding_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_padding#') then Exit;

  try
    with TBasPanel(Args[0].p).Padding do
    begin
      Left := Args[1].n;
      Top := Args[1].n;
      Right := Args[1].n;
      Bottom := Args[1].n;
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_padding#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Visibility and Behavior
//==============================================================================

// panel_visible(panel#) - Get visibility
function n_panel_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_visible') then Exit;

  try
    if TBasPanel(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_visible: ' + E.Message);
  end;
end;

// panel_visible#(panel#, value) - Set visibility
function p_panel_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_visible#') then Exit;

  try
    TBasPanel(Args[0].p).Visible := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_visible#: ' + E.Message);
  end;
end;

// panel_enabled(panel#) - Get enabled state
function n_panel_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_enabled') then Exit;

  try
    if TBasPanel(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_enabled: ' + E.Message);
  end;
end;

// panel_enabled#(panel#, value) - Set enabled state
function p_panel_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_enabled#') then Exit;

  try
    TBasPanel(Args[0].p).Enabled := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_enabled#: ' + E.Message);
  end;
end;

// panel_opacity(panel#) - Get opacity
function n_panel_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_opacity') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Opacity;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_opacity: ' + E.Message);
  end;
end;

// panel_opacity#(panel#, value) - Set opacity (0.0 to 1.0)
function p_panel_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_opacity#') then Exit;

  try
    TBasPanel(Args[0].p).Opacity := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_opacity#: ' + E.Message);
  end;
end;

// panel_clipchildren(panel#) - Get ClipChildren state
function n_panel_clipchildren_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_clipchildren') then Exit;

  try
    if TBasPanel(Args[0].p).ClipChildren then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_clipchildren: ' + E.Message);
  end;
end;

// panel_clipchildren#(panel#, value) - Set ClipChildren state
function p_panel_clipchildren_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_clipchildren#') then Exit;

  try
    TBasPanel(Args[0].p).ClipChildren := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_clipchildren#: ' + E.Message);
  end;
end;

// panel_hittest(panel#) - Get HitTest state
function n_panel_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_hittest') then Exit;

  try
    if TBasPanel(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_hittest: ' + E.Message);
  end;
end;

// panel_hittest#(panel#, value) - Set HitTest state
function p_panel_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_hittest#') then Exit;

  try
    TBasPanel(Args[0].p).HitTest := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_hittest#: ' + E.Message);
  end;
end;

// panel_locked(panel#) - Get locked state
function n_panel_locked_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_locked') then Exit;

  try
    if TBasPanel(Args[0].p).Locked then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_locked: ' + E.Message);
  end;
end;

// panel_locked#(panel#, value) - Set locked state
function p_panel_locked_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_locked#') then Exit;

  try
    TBasPanel(Args[0].p).Locked := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_locked#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Tag
//==============================================================================

// panel_tag(panel#) - Get tag
function n_panel_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_tag') then Exit;

  try
    Result.n := TBasPanel(Args[0].p).Tag;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_tag: ' + E.Message);
  end;
end;

// panel_tag#(panel#, value) - Set tag
function p_panel_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_tag#') then Exit;

  try
    TBasPanel(Args[0].p).Tag := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_tag#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Invalidation
//==============================================================================

// panel_invalidate#(panel#) - Invalidate panel for repaint
function p_panel_invalidate(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_invalidate#') then Exit;

  try
    TBasPanel(Args[0].p).InvalidateRect(TBasPanel(Args[0].p).LocalRect);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_invalidate#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Event Callbacks
//==============================================================================

// panel_onclick#(panel#, funcname$) - Set OnClick handler
function p_panel_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onclick#') then Exit;

  try
    TBasPanel(Args[0].p).OnClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onclick#: ' + E.Message);
  end;
end;

// panel_onclick$(panel#) - Get OnClick handler name
function s_panel_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onclick$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onclick$: ' + E.Message);
  end;
end;

// panel_ondblclick#(panel#, funcname$) - Set OnDblClick handler
function p_panel_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_ondblclick#') then Exit;

  try
    TBasPanel(Args[0].p).OnDblClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_ondblclick#: ' + E.Message);
  end;
end;

// panel_ondblclick$(panel#) - Get OnDblClick handler name
function s_panel_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_ondblclick$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnDblClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_ondblclick$: ' + E.Message);
  end;
end;

// panel_onmousedown#(panel#, funcname$) - Set OnMouseDown handler
function p_panel_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onmousedown#') then Exit;

  try
    TBasPanel(Args[0].p).OnMouseDownFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onmousedown#: ' + E.Message);
  end;
end;

// panel_onmousedown$(panel#) - Get OnMouseDown handler name
function s_panel_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onmousedown$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnMouseDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onmousedown$: ' + E.Message);
  end;
end;

// panel_onmouseup#(panel#, funcname$) - Set OnMouseUp handler
function p_panel_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onmouseup#') then Exit;

  try
    TBasPanel(Args[0].p).OnMouseUpFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onmouseup#: ' + E.Message);
  end;
end;

// panel_onmouseup$(panel#) - Get OnMouseUp handler name
function s_panel_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onmouseup$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnMouseUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onmouseup$: ' + E.Message);
  end;
end;

// panel_onmousemove#(panel#, funcname$) - Set OnMouseMove handler
function p_panel_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onmousemove#') then Exit;

  try
    TBasPanel(Args[0].p).OnMouseMoveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onmousemove#: ' + E.Message);
  end;
end;

// panel_onmousemove$(panel#) - Get OnMouseMove handler name
function s_panel_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onmousemove$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnMouseMoveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onmousemove$: ' + E.Message);
  end;
end;

// panel_onmouseenter#(panel#, funcname$) - Set OnMouseEnter handler
function p_panel_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onmouseenter#') then Exit;

  try
    TBasPanel(Args[0].p).OnMouseEnterFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onmouseenter#: ' + E.Message);
  end;
end;

// panel_onmouseenter$(panel#) - Get OnMouseEnter handler name
function s_panel_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onmouseenter$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnMouseEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onmouseenter$: ' + E.Message);
  end;
end;

// panel_onmouseleave#(panel#, funcname$) - Set OnMouseLeave handler
function p_panel_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onmouseleave#') then Exit;

  try
    TBasPanel(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onmouseleave#: ' + E.Message);
  end;
end;

// panel_onmouseleave$(panel#) - Get OnMouseLeave handler name
function s_panel_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onmouseleave$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnMouseLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onmouseleave$: ' + E.Message);
  end;
end;

// panel_onmousewheel#(panel#, funcname$) - Set OnMouseWheel handler
function p_panel_onmousewheel_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onmousewheel#') then Exit;

  try
    TBasPanel(Args[0].p).OnMouseWheelFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onmousewheel#: ' + E.Message);
  end;
end;

// panel_onmousewheel$(panel#) - Get OnMouseWheel handler name
function s_panel_onmousewheel_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onmousewheel$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnMouseWheelFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onmousewheel$: ' + E.Message);
  end;
end;

// panel_onresize#(panel#, funcname$) - Set OnResize handler
function p_panel_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onresize#') then Exit;

  try
    TBasPanel(Args[0].p).OnResizeFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onresize#: ' + E.Message);
  end;
end;

// panel_onresize$(panel#) - Get OnResize handler name
function s_panel_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onresize$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnResizeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onresize$: ' + E.Message);
  end;
end;

// panel_onresized#(panel#, funcname$) - Set OnResized handler
function p_panel_onresized_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onresized#') then Exit;

  try
    TBasPanel(Args[0].p).OnResizedFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onresized#: ' + E.Message);
  end;
end;

// panel_onresized$(panel#) - Get OnResized handler name
function s_panel_onresized_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_onresized$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnResizedFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_onresized$: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Drag & Drop Event Callbacks
//==============================================================================

// panel_ondragenter#(panel#, funcname$) - Set OnDragEnter handler
function p_panel_ondragenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_ondragenter#') then Exit;

  try
    TBasPanel(Args[0].p).OnDragEnterFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_ondragenter#: ' + E.Message);
  end;
end;

// panel_ondragenter$(panel#) - Get OnDragEnter handler name
function s_panel_ondragenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_ondragenter$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnDragEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_ondragenter$: ' + E.Message);
  end;
end;

// panel_ondragover#(panel#, funcname$) - Set OnDragOver handler
function p_panel_ondragover_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_ondragover#') then Exit;

  try
    TBasPanel(Args[0].p).OnDragOverFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_ondragover#: ' + E.Message);
  end;
end;

// panel_ondragover$(panel#) - Get OnDragOver handler name
function s_panel_ondragover_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_ondragover$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnDragOverFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_ondragover$: ' + E.Message);
  end;
end;

// panel_ondragdrop#(panel#, funcname$) - Set OnDragDrop handler
function p_panel_ondragdrop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_ondragdrop#') then Exit;

  try
    TBasPanel(Args[0].p).OnDragDropFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_ondragdrop#: ' + E.Message);
  end;
end;

// panel_ondragdrop$(panel#) - Get OnDragDrop handler name
function s_panel_ondragdrop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_ondragdrop$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnDragDropFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_ondragdrop$: ' + E.Message);
  end;
end;

// panel_ondragleave#(panel#, funcname$) - Set OnDragLeave handler
function p_panel_ondragleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_ondragleave#') then Exit;

  try
    TBasPanel(Args[0].p).OnDragLeaveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_ondragleave#: ' + E.Message);
  end;
end;

// panel_ondragleave$(panel#) - Get OnDragLeave handler name
function s_panel_ondragleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_ondragleave$') then Exit;

  try
    Result.s := TBasPanel(Args[0].p).OnDragLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_ondragleave$: ' + E.Message);
  end;
end;

// panel_clearcallbacks#(panel#) - Clear all callbacks
function p_panel_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePanel(Args[0].p, 'panel_clearcallbacks#') then Exit;

  try
    with TBasPanel(Args[0].p) do
    begin
      OnClickFunc := '';
      OnDblClickFunc := '';
      OnMouseDownFunc := '';
      OnMouseUpFunc := '';
      OnMouseMoveFunc := '';
      OnMouseEnterFunc := '';
      OnMouseLeaveFunc := '';
      OnMouseWheelFunc := '';
      OnResizeFunc := '';
      OnResizedFunc := '';
      OnDragEnterFunc := '';
      OnDragOverFunc := '';
      OnDragDropFunc := '';
      OnDragLeaveFunc := '';
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'panel_clearcallbacks#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterPanelFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  // Store module-level references for event callbacks

  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_panel_error; Lib.Add('panel_error@', Fn);
  Fn.Entry := @s_panel_errormsg; Lib.Add('panel_errormsg$@', Fn);
  Fn.Entry := @s_panel_strerror; Lib.Add('panel_strerror$@n', Fn);
  Fn.Entry := @n_panel_clearerror; Lib.Add('panel_clearerror@', Fn);

  // Panel creation/destruction
  Fn.Entry := @p_panel_new; Lib.Add('panel#@#', Fn);
  Fn.Entry := @p_panel_new_size; Lib.Add('panel#@#nn', Fn);
  Fn.Entry := @p_panel_new_full; Lib.Add('panel#@#nnnn', Fn);
  Fn.Entry := @n_panel_free; Lib.Add('panel_free@#', Fn);

  // Parent/child management
  Fn.Entry := @p_panel_parent_get; Lib.Add('panel_parent#@#', Fn);
  Fn.Entry := @p_panel_parent_set; Lib.Add('panel_parent#@##', Fn);
  Fn.Entry := @n_panel_childcount; Lib.Add('panel_childcount@#', Fn);
  Fn.Entry := @p_panel_child; Lib.Add('panel_child#@#n', Fn);
  Fn.Entry := @p_panel_bringtofront; Lib.Add('panel_bringtofront#@#', Fn);
  Fn.Entry := @p_panel_sendtoback; Lib.Add('panel_sendtoback#@#', Fn);

  // Position and Size
  Fn.Entry := @n_panel_x_get; Lib.Add('panel_x@#', Fn);
  Fn.Entry := @p_panel_x_set; Lib.Add('panel_x#@#n', Fn);
  Fn.Entry := @n_panel_y_get; Lib.Add('panel_y@#', Fn);
  Fn.Entry := @p_panel_y_set; Lib.Add('panel_y#@#n', Fn);
  Fn.Entry := @n_panel_width_get; Lib.Add('panel_width@#', Fn);
  Fn.Entry := @p_panel_width_set; Lib.Add('panel_width#@#n', Fn);
  Fn.Entry := @n_panel_height_get; Lib.Add('panel_height@#', Fn);
  Fn.Entry := @p_panel_height_set; Lib.Add('panel_height#@#n', Fn);
  Fn.Entry := @p_panel_bounds_set; Lib.Add('panel_bounds#@#nnnn', Fn);
  Fn.Entry := @p_panel_size_set; Lib.Add('panel_size#@#nn', Fn);
  Fn.Entry := @p_panel_move_set; Lib.Add('panel_move#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_panel_align_get; Lib.Add('panel_align@#', Fn);
  Fn.Entry := @p_panel_align_set; Lib.Add('panel_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_panel_marginleft_get; Lib.Add('panel_marginleft@#', Fn);
  Fn.Entry := @p_panel_marginleft_set; Lib.Add('panel_marginleft#@#n', Fn);
  Fn.Entry := @n_panel_margintop_get; Lib.Add('panel_margintop@#', Fn);
  Fn.Entry := @p_panel_margintop_set; Lib.Add('panel_margintop#@#n', Fn);
  Fn.Entry := @n_panel_marginright_get; Lib.Add('panel_marginright@#', Fn);
  Fn.Entry := @p_panel_marginright_set; Lib.Add('panel_marginright#@#n', Fn);
  Fn.Entry := @n_panel_marginbottom_get; Lib.Add('panel_marginbottom@#', Fn);
  Fn.Entry := @p_panel_marginbottom_set; Lib.Add('panel_marginbottom#@#n', Fn);
  Fn.Entry := @p_panel_margins_set; Lib.Add('panel_margins#@#nnnn', Fn);
  Fn.Entry := @p_panel_margin_set; Lib.Add('panel_margin#@#n', Fn);

  // Padding
  Fn.Entry := @n_panel_paddingleft_get; Lib.Add('panel_paddingleft@#', Fn);
  Fn.Entry := @p_panel_paddingleft_set; Lib.Add('panel_paddingleft#@#n', Fn);
  Fn.Entry := @n_panel_paddingtop_get; Lib.Add('panel_paddingtop@#', Fn);
  Fn.Entry := @p_panel_paddingtop_set; Lib.Add('panel_paddingtop#@#n', Fn);
  Fn.Entry := @n_panel_paddingright_get; Lib.Add('panel_paddingright@#', Fn);
  Fn.Entry := @p_panel_paddingright_set; Lib.Add('panel_paddingright#@#n', Fn);
  Fn.Entry := @n_panel_paddingbottom_get; Lib.Add('panel_paddingbottom@#', Fn);
  Fn.Entry := @p_panel_paddingbottom_set; Lib.Add('panel_paddingbottom#@#n', Fn);
  Fn.Entry := @p_panel_paddings_set; Lib.Add('panel_paddings#@#nnnn', Fn);
  Fn.Entry := @p_panel_padding_set; Lib.Add('panel_padding#@#n', Fn);

  // Visibility and behavior
  Fn.Entry := @n_panel_visible_get; Lib.Add('panel_visible@#', Fn);
  Fn.Entry := @p_panel_visible_set; Lib.Add('panel_visible#@#n', Fn);
  Fn.Entry := @n_panel_enabled_get; Lib.Add('panel_enabled@#', Fn);
  Fn.Entry := @p_panel_enabled_set; Lib.Add('panel_enabled#@#n', Fn);
  Fn.Entry := @n_panel_opacity_get; Lib.Add('panel_opacity@#', Fn);
  Fn.Entry := @p_panel_opacity_set; Lib.Add('panel_opacity#@#n', Fn);
  Fn.Entry := @n_panel_clipchildren_get; Lib.Add('panel_clipchildren@#', Fn);
  Fn.Entry := @p_panel_clipchildren_set; Lib.Add('panel_clipchildren#@#n', Fn);
  Fn.Entry := @n_panel_hittest_get; Lib.Add('panel_hittest@#', Fn);
  Fn.Entry := @p_panel_hittest_set; Lib.Add('panel_hittest#@#n', Fn);
  Fn.Entry := @n_panel_locked_get; Lib.Add('panel_locked@#', Fn);
  Fn.Entry := @p_panel_locked_set; Lib.Add('panel_locked#@#n', Fn);

  // Tag
  Fn.Entry := @n_panel_tag_get; Lib.Add('panel_tag@#', Fn);
  Fn.Entry := @p_panel_tag_set; Lib.Add('panel_tag#@#n', Fn);

  // Invalidation
  Fn.Entry := @p_panel_invalidate; Lib.Add('panel_invalidate#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_panel_onclick_set; Lib.Add('panel_onclick#@#$', Fn);
  Fn.Entry := @s_panel_onclick_get; Lib.Add('panel_onclick$@#', Fn);
  Fn.Entry := @p_panel_ondblclick_set; Lib.Add('panel_ondblclick#@#$', Fn);
  Fn.Entry := @s_panel_ondblclick_get; Lib.Add('panel_ondblclick$@#', Fn);
  Fn.Entry := @p_panel_onmousedown_set; Lib.Add('panel_onmousedown#@#$', Fn);
  Fn.Entry := @s_panel_onmousedown_get; Lib.Add('panel_onmousedown$@#', Fn);
  Fn.Entry := @p_panel_onmouseup_set; Lib.Add('panel_onmouseup#@#$', Fn);
  Fn.Entry := @s_panel_onmouseup_get; Lib.Add('panel_onmouseup$@#', Fn);
  Fn.Entry := @p_panel_onmousemove_set; Lib.Add('panel_onmousemove#@#$', Fn);
  Fn.Entry := @s_panel_onmousemove_get; Lib.Add('panel_onmousemove$@#', Fn);
  Fn.Entry := @p_panel_onmouseenter_set; Lib.Add('panel_onmouseenter#@#$', Fn);
  Fn.Entry := @s_panel_onmouseenter_get; Lib.Add('panel_onmouseenter$@#', Fn);
  Fn.Entry := @p_panel_onmouseleave_set; Lib.Add('panel_onmouseleave#@#$', Fn);
  Fn.Entry := @s_panel_onmouseleave_get; Lib.Add('panel_onmouseleave$@#', Fn);
  Fn.Entry := @p_panel_onmousewheel_set; Lib.Add('panel_onmousewheel#@#$', Fn);
  Fn.Entry := @s_panel_onmousewheel_get; Lib.Add('panel_onmousewheel$@#', Fn);
  Fn.Entry := @p_panel_onresize_set; Lib.Add('panel_onresize#@#$', Fn);
  Fn.Entry := @s_panel_onresize_get; Lib.Add('panel_onresize$@#', Fn);
  Fn.Entry := @p_panel_onresized_set; Lib.Add('panel_onresized#@#$', Fn);
  Fn.Entry := @s_panel_onresized_get; Lib.Add('panel_onresized$@#', Fn);

  // Drag & Drop event callbacks
  Fn.Entry := @p_panel_ondragenter_set; Lib.Add('panel_ondragenter#@#$', Fn);
  Fn.Entry := @s_panel_ondragenter_get; Lib.Add('panel_ondragenter$@#', Fn);
  Fn.Entry := @p_panel_ondragover_set; Lib.Add('panel_ondragover#@#$', Fn);
  Fn.Entry := @s_panel_ondragover_get; Lib.Add('panel_ondragover$@#', Fn);
  Fn.Entry := @p_panel_ondragdrop_set; Lib.Add('panel_ondragdrop#@#$', Fn);
  Fn.Entry := @s_panel_ondragdrop_get; Lib.Add('panel_ondragdrop$@#', Fn);
  Fn.Entry := @p_panel_ondragleave_set; Lib.Add('panel_ondragleave#@#$', Fn);
  Fn.Entry := @s_panel_ondragleave_get; Lib.Add('panel_ondragleave$@#', Fn);

  // Clear all callbacks
  Fn.Entry := @p_panel_clearcallbacks; Lib.Add('panel_clearcallbacks#@#', Fn);
end;

end.

