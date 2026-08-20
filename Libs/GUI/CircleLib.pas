unit CircleLib;

{******************************************************************************
  CircleLib - Circle Visual Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TCircle wrapper functionality for creating
  and managing circle/ellipse visual controls in Plan9Basic programs. TCircle
  is a visual shape control with fill and stroke properties.

  Function Count: 72 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All circles are created at RUNTIME using TCircle.Create with dynamic
  parent assignment. This ensures proper dynamic creation across all platforms.

  FEATURES:
  =========
  - Circle creation and lifecycle management
  - Fill color and style (solid, gradient support via color)
  - Stroke (border) color, thickness, and style
  - Complete positioning and alignment
  - Full event support with BASIC callback integration

  EVENTS SUPPORT:
  ===============
  - OnClick: Circle was clicked
  - OnDblClick: Circle was double-clicked
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over circle
  - OnMouseEnter: Mouse entered circle area
  - OnMouseLeave: Mouse left circle area
  - OnMouseWheel: Mouse wheel scrolled
  - OnResize: Circle is being resized
  - OnResized: Circle resize completed
  - OnPaint: Circle needs repainting

  COLOR FORMAT:
  =============
  Colors are specified as strings in these formats:
  - Named colors: "red", "blue", "green", "white", "black", etc.
  - Hex RGB: "#RRGGBB" (e.g., "#FF5500")
  - Hex ARGB: "#AARRGGBB" (e.g., "#80FF5500" for semi-transparent)

  STROKE DASH STYLES:
  ===================
  0 = Solid (default)
  1 = Dash
  2 = Dot
  3 = DashDot
  4 = DashDotDot

  STROKE CAP STYLES:
  ==================
  0 = Flat (default)
  1 = Round

  STROKE JOIN STYLES:
  ===================
  0 = Miter (default)
  1 = Round
  2 = Bevel

  USAGE PATTERN:
  ==============
    let frm# = form#("Circle Demo", 800, 600)

    ' Create a blue circle
    let circ# = circle#(frm#, 50, 50, 100, 100)
    circle_fill#(circ#, "#3498db")
    circle_stroke#(circ#, "#2980b9")
    circle_strokethickness#(circ#, 2)

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnCircleClick(sender#)
      println "Circle clicked!"
    endfunction

    function OnCircleMouseMove(sender#, x, y, shift$)
      println "Mouse at: " + stri$(x) + ", " + stri$(y)
    endfunction

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, ControlCommon;

type
  // Forward declaration
  TBasCircle = class;

  {****************************************************************************
    TBasCircle - Extended TCircle with BASIC event callback support

    Wraps a TCircle and provides event bridging to Plan9Basic user functions.
    Each event stores the name of a BASIC function to call when triggered.
  ****************************************************************************}
  TBasCircle = class(TCircle)
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
    FOnPaintFunc: String;
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
    procedure InternalOnPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
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
    procedure SetOnPaintFunc(const Value: String);
    procedure SetOnDragEnterFunc(const Value: String);
    procedure SetOnDragOverFunc(const Value: String);
    procedure SetOnDragDropFunc(const Value: String);
    procedure SetOnDragLeaveFunc(const Value: String);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

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
    property OnPaintFunc: String read FOnPaintFunc write SetOnPaintFunc;
    property OnDragEnterFunc: String read FOnDragEnterFunc write SetOnDragEnterFunc;
    property OnDragOverFunc: String read FOnDragOverFunc write SetOnDragOverFunc;
    property OnDragDropFunc: String read FOnDragDropFunc write SetOnDragDropFunc;
    property OnDragLeaveFunc: String read FOnDragLeaveFunc write SetOnDragLeaveFunc;

    // Engine references
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
  end;

// Library registration
procedure RegisterCircleFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  CIRCLE_GC_TAG = 'BASIC_CIRCLE';

  // Error codes
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_CIRCLE = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INVALID_CALLBACK = 5;
  ERR_INVALID_COLOR = 6;

  // Alignment constants (matching TAlignLayout)

  // Stroke dash styles
  DASH_SOLID = 0;
  DASH_DASH = 1;
  DASH_DOT = 2;
  DASH_DASHDOT = 3;
  DASH_DASHDOTDOT = 4;

  // Stroke cap styles
  CAP_FLAT = 0;
  CAP_ROUND = 1;

  // Stroke join styles
  JOIN_MITER = 0;
  JOIN_ROUND = 1;
  JOIN_BEVEL = 2;

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

function ValidateCircle(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_CIRCLE, FuncName + ': Nil circle pointer');
    Exit;
  end;

  try
    if not (IsHandleOf(P, TBasCircle)) then
    begin
      SetError(ERR_INVALID_CIRCLE, FuncName + ': Invalid circle object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_CIRCLE, FuncName + ': Invalid circle pointer');
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

function IntToStrokeDash(Value: Integer): TStrokeDash;
begin
  case Value of
    DASH_SOLID: Result := TStrokeDash.Solid;
    DASH_DASH: Result := TStrokeDash.Dash;
    DASH_DOT: Result := TStrokeDash.Dot;
    DASH_DASHDOT: Result := TStrokeDash.DashDot;
    DASH_DASHDOTDOT: Result := TStrokeDash.DashDotDot;
  else
    Result := TStrokeDash.Solid;
  end;
end;

function StrokeDashToInt(Value: TStrokeDash): Integer;
begin
  case Value of
    TStrokeDash.Solid: Result := DASH_SOLID;
    TStrokeDash.Dash: Result := DASH_DASH;
    TStrokeDash.Dot: Result := DASH_DOT;
    TStrokeDash.DashDot: Result := DASH_DASHDOT;
    TStrokeDash.DashDotDot: Result := DASH_DASHDOTDOT;
  else
    Result := DASH_SOLID;
  end;
end;

function IntToStrokeCap(Value: Integer): TStrokeCap;
begin
  case Value of
    CAP_FLAT: Result := TStrokeCap.Flat;
    CAP_ROUND: Result := TStrokeCap.Round;
  else
    Result := TStrokeCap.Flat;
  end;
end;

function StrokeCapToInt(Value: TStrokeCap): Integer;
begin
  case Value of
    TStrokeCap.Flat: Result := CAP_FLAT;
    TStrokeCap.Round: Result := CAP_ROUND;
  else
    Result := CAP_FLAT;
  end;
end;

function IntToStrokeJoin(Value: Integer): TStrokeJoin;
begin
  case Value of
    JOIN_MITER: Result := TStrokeJoin.Miter;
    JOIN_ROUND: Result := TStrokeJoin.Round;
    JOIN_BEVEL: Result := TStrokeJoin.Bevel;
  else
    Result := TStrokeJoin.Miter;
  end;
end;

function StrokeJoinToInt(Value: TStrokeJoin): Integer;
begin
  case Value of
    TStrokeJoin.Miter: Result := JOIN_MITER;
    TStrokeJoin.Round: Result := JOIN_ROUND;
    TStrokeJoin.Bevel: Result := JOIN_BEVEL;
  else
    Result := JOIN_MITER;
  end;
end;

//==============================================================================
// TBasCircle Implementation
//==============================================================================

constructor TBasCircle.Create(AOwner: TComponent);
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
  FOnPaintFunc := '';
  FOnDragEnterFunc := '';
  FOnDragOverFunc := '';
  FOnDragDropFunc := '';
  FOnDragLeaveFunc := '';

  // Initialize engine references
  FBasicEngine := nil;
  FConsoleOutput := nil;
end;

destructor TBasCircle.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectEvents();
  inherited Destroy();
end;

procedure TBasCircle.DisconnectEvents();
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
  Self.OnPainting := nil;
  Self.OnDragEnter := nil;
  Self.OnDragOver := nil;
  Self.OnDragDrop := nil;
  Self.OnDragLeave := nil;
end;

function TBasCircle.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

procedure TBasCircle.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'Circle');
end;

function TBasCircle.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
begin
  Result := ControlCommon.RunCallbackWithResult(FBasicEngine, FConsoleOutput,
                          FuncSignature, Args, 'Circle');
end;

procedure TBasCircle.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnClickFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnClickFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasCircle.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnDblClickFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnDblClickFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasCircle.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasCircle.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasCircle.InternalOnDragLeave(Sender: TObject);
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

procedure TBasCircle.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
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

procedure TBasCircle.InternalOnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
  Signature: String;
begin
  if FOnMouseDownFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

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

procedure TBasCircle.InternalOnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
  Signature: String;
begin
  if FOnMouseUpFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

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

procedure TBasCircle.InternalOnMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Single);
var
  Args: array[0..3] of TAsmData;
  Signature: String;
begin
  if FOnMouseMoveFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

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

procedure TBasCircle.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnMouseEnterFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnMouseEnterFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasCircle.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnMouseLeaveFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnMouseLeaveFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasCircle.InternalOnMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; var Handled: Boolean);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnMouseWheelFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

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

  ExecuteCallback(Signature, Args);
  Handled := True;
end;

procedure TBasCircle.InternalOnResize(Sender: TObject);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnResizeFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

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

procedure TBasCircle.InternalOnResized(Sender: TObject);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnResizedFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

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

procedure TBasCircle.InternalOnPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Args: array[0..4] of TAsmData;
  Signature: String;
begin
  if FOnPaintFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnPaintFunc) + '@#nnnn';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := ARect.Left;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := ARect.Top;
  Args[2].p := nil;
  Args[2].s := '';

  Args[3].n := ARect.Right;
  Args[3].p := nil;
  Args[3].s := '';

  Args[4].n := ARect.Bottom;
  Args[4].p := nil;
  Args[4].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasCircle.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    Self.OnClick := InternalOnClick
  else
    Self.OnClick := nil;
end;

procedure TBasCircle.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    Self.OnDblClick := InternalOnDblClick
  else
    Self.OnDblClick := nil;
end;

procedure TBasCircle.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    Self.OnDragDrop := InternalOnDragDrop
  else
    Self.OnDragDrop := nil;
end;

procedure TBasCircle.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    Self.OnDragEnter := InternalOnDragEnter
  else
    Self.OnDragEnter := nil;
end;

procedure TBasCircle.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    Self.OnDragLeave := InternalOnDragLeave
  else
    Self.OnDragLeave := nil;
end;

procedure TBasCircle.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    Self.OnDragOver := InternalOnDragOver
  else
    Self.OnDragOver := nil;
end;

procedure TBasCircle.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    Self.OnMouseDown := InternalOnMouseDown
  else
    Self.OnMouseDown := nil;
end;

procedure TBasCircle.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    Self.OnMouseEnter := InternalOnMouseEnter
  else
    Self.OnMouseEnter := nil;
end;

procedure TBasCircle.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    Self.OnMouseLeave := InternalOnMouseLeave
  else
    Self.OnMouseLeave := nil;
end;

procedure TBasCircle.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    Self.OnMouseMove := InternalOnMouseMove
  else
    Self.OnMouseMove := nil;
end;

procedure TBasCircle.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    Self.OnMouseUp := InternalOnMouseUp
  else
    Self.OnMouseUp := nil;
end;

procedure TBasCircle.SetOnMouseWheelFunc(const Value: String);
begin
  FOnMouseWheelFunc := Value;
  if Value <> '' then
    Self.OnMouseWheel := InternalOnMouseWheel
  else
    Self.OnMouseWheel := nil;
end;

procedure TBasCircle.SetOnPaintFunc(const Value: String);
begin
  FOnPaintFunc := Value;
  if Value <> '' then
    Self.OnPaint := InternalOnPaint
  else
    Self.OnPaint := nil;
end;

procedure TBasCircle.SetOnResizedFunc(const Value: String);
begin
  FOnResizedFunc := Value;
  if Value <> '' then
    Self.OnResized := InternalOnResized
  else
    Self.OnResized := nil;
end;

procedure TBasCircle.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    Self.OnResize := InternalOnResize
  else
    Self.OnResize := nil;
end;

//==============================================================================
// Error Handling Functions
//==============================================================================

// circle_error@ - Get last error code
function n_circle_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

// circle_errormsg$@ - Get last error message
function s_circle_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

// circle_strerror$@n - Get error description by code
function s_circle_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Trunc(Args[0].n) of
    ERR_NONE:            Result.s := 'No error';
    ERR_INVALID_CIRCLE:  Result.s := 'Invalid circle';
    ERR_INVALID_PARENT:  Result.s := 'Invalid parent';
    ERR_INVALID_VALUE:   Result.s := 'Invalid value';
    ERR_CREATE_FAILED:   Result.s := 'Creation failed';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback';
    ERR_INVALID_COLOR:   Result.s := 'Invalid color';
  else
    Result.s := 'Unknown error';
  end;
end;

// circle_clearerror@ - Clear last error
function n_circle_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

//==============================================================================
// Circle Creation/Destruction Functions
//==============================================================================

// circle#@# - Create circle with parent only
function p_circle_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Circle: TBasCircle;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'circle#') then Exit;

  try
    Circle := TBasCircle.Create(nil);
    Circle.Parent := TFmxObject(Args[0].p);
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Circle, Eng, Outp) then
    begin
      Circle.BasicEngine := Eng;
      Circle.ConsoleOutput := Outp;
    end;
    Circle.HitTest := True;  // Enable mouse events by default

    Result.p := Pointer(Circle);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Circle, CIRCLE_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'circle#: ' + E.Message);
    end;
  end;
end;

// circle#@#nn - Create circle with parent and size (width, height)
function p_circle_new_size(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Circle: TBasCircle;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'circle#') then Exit;

  try
    Circle := TBasCircle.Create(nil);
    Circle.Parent := TFmxObject(Args[0].p);
    Circle.Width := Args[1].n;
    Circle.Height := Args[2].n;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Circle, Eng, Outp) then
    begin
      Circle.BasicEngine := Eng;
      Circle.ConsoleOutput := Outp;
    end;
    Circle.HitTest := True;

    Result.p := Pointer(Circle);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Circle, CIRCLE_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'circle#: ' + E.Message);
    end;
  end;
end;

// circle#@#nnnn - Create circle with parent, position, and size
function p_circle_new_full(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Circle: TBasCircle;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'circle#') then Exit;

  try
    Circle := TBasCircle.Create(nil);
    Circle.Parent := TFmxObject(Args[0].p);
    Circle.Position.X := Args[1].n;
    Circle.Position.Y := Args[2].n;
    Circle.Width := Args[3].n;
    Circle.Height := Args[4].n;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Circle, Eng, Outp) then
    begin
      Circle.BasicEngine := Eng;
      Circle.ConsoleOutput := Outp;
    end;
    Circle.HitTest := True;

    Result.p := Pointer(Circle);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Circle, CIRCLE_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'circle#: ' + E.Message);
    end;
  end;
end;

// circle_free@# - Explicitly free a circle
function n_circle_free(var Args: array of TAsmData): TAsmData;
var
  Circle: TBasCircle;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateCircle(Args[0].p, 'circle_free') then Exit;

  try
    Circle := TBasCircle(Args[0].p);
    Circle.DisconnectEvents();
    Circle.Free();

    // Use GC to properly free the control
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(CIRCLE_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
    //Its eighty-one siblings answer 1 on success. This one did too, inside
    //the collector block that was commented out.
    Result.n := 1;
  except
    on E: Exception do
    begin
      SetError(ERR_INVALID_CIRCLE, 'circle_free: ' + E.Message);
    end;
  end;
end;

//==============================================================================
// Fill Functions
//==============================================================================

// circle_fill$@# - Get fill color
function s_circle_fill_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_fill$') then Exit;
  try
    Result.s := TUtils.AlphaColorToStr(TBasCircle(Args[0].p).Fill.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_fill$: ' + E.Message);
  end;
end;

// circle_fill#@#$ - Set fill color
function p_circle_fill_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_fill#') then Exit;
  try
    TBasCircle(Args[0].p).Fill.Color := TUtils.ColorToAlphaColor(Args[1].s);
    TBasCircle(Args[0].p).Fill.Kind := TBrushKind.Solid;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_fill#: ' + E.Message);
  end;
end;

// circle_fillnone#@# - Set fill to none (transparent)
function p_circle_fillnone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_fillnone#') then Exit;
  try
    TBasCircle(Args[0].p).Fill.Kind := TBrushKind.None;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_fillnone#: ' + E.Message);
  end;
end;

//==============================================================================
// Stroke Functions
//==============================================================================

// circle_stroke$@# - Get stroke color
function s_circle_stroke_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_stroke$') then Exit;
  try
    Result.s := TUtils.AlphaColorToStr(TBasCircle(Args[0].p).Stroke.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_stroke$: ' + E.Message);
  end;
end;

// circle_stroke#@#$ - Set stroke color
function p_circle_stroke_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_stroke#') then Exit;
  try
    TBasCircle(Args[0].p).Stroke.Color := TUtils.ColorToAlphaColor(Args[1].s);
    TBasCircle(Args[0].p).Stroke.Kind := TBrushKind.Solid;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_stroke#: ' + E.Message);
  end;
end;

// circle_strokenone#@# - Set stroke to none
function p_circle_strokenone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_strokenone#') then Exit;
  try
    TBasCircle(Args[0].p).Stroke.Kind := TBrushKind.None;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_strokenone#: ' + E.Message);
  end;
end;

// circle_strokethickness@# - Get stroke thickness
function n_circle_strokethickness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_strokethickness') then Exit;
  try
    Result.n := TBasCircle(Args[0].p).Stroke.Thickness;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_strokethickness: ' + E.Message);
  end;
end;

// circle_strokethickness#@#n - Set stroke thickness
function p_circle_strokethickness_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_strokethickness#') then Exit;
  try
    TBasCircle(Args[0].p).Stroke.Thickness := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_strokethickness#: ' + E.Message);
  end;
end;

// circle_strokedash@# - Get stroke dash style
function n_circle_strokedash_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_strokedash') then Exit;
  try
    Result.n := StrokeDashToInt(TBasCircle(Args[0].p).Stroke.Dash);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_strokedash: ' + E.Message);
  end;
end;

// circle_strokedash#@#n - Set stroke dash style
function p_circle_strokedash_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_strokedash#') then Exit;
  try
    TBasCircle(Args[0].p).Stroke.Dash := IntToStrokeDash(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_strokedash#: ' + E.Message);
  end;
end;

// circle_strokecap@# - Get stroke cap style
function n_circle_strokecap_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_strokecap') then Exit;
  try
    Result.n := StrokeCapToInt(TBasCircle(Args[0].p).Stroke.Cap);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_strokecap: ' + E.Message);
  end;
end;

// circle_strokecap#@#n - Set stroke cap style
function p_circle_strokecap_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_strokecap#') then Exit;
  try
    TBasCircle(Args[0].p).Stroke.Cap := IntToStrokeCap(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_strokecap#: ' + E.Message);
  end;
end;

// circle_strokejoin@# - Get stroke join style
function n_circle_strokejoin_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_strokejoin') then Exit;
  try
    Result.n := StrokeJoinToInt(TBasCircle(Args[0].p).Stroke.Join);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_strokejoin: ' + E.Message);
  end;
end;

// circle_strokejoin#@#n - Set stroke join style
function p_circle_strokejoin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_strokejoin#') then Exit;
  try
    TBasCircle(Args[0].p).Stroke.Join := IntToStrokeJoin(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_strokejoin#: ' + E.Message);
  end;
end;

//==============================================================================
// Position and Size Functions
//==============================================================================

// circle_x@# - Get X position
function n_circle_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_x') then Exit;
  try
    Result.n := TBasCircle(Args[0].p).Position.X;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_x: ' + E.Message);
  end;
end;

// circle_x#@#n - Set X position
function p_circle_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_x#') then Exit;
  try
    TBasCircle(Args[0].p).Position.X := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_x#: ' + E.Message);
  end;
end;

// circle_y@# - Get Y position
function n_circle_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_y') then Exit;
  try
    Result.n := TBasCircle(Args[0].p).Position.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_y: ' + E.Message);
  end;
end;

// circle_y#@#n - Set Y position
function p_circle_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_y#') then Exit;
  try
    TBasCircle(Args[0].p).Position.Y := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_y#: ' + E.Message);
  end;
end;

// circle_width@# - Get width
function n_circle_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_width') then Exit;
  try
    Result.n := TBasCircle(Args[0].p).Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_width: ' + E.Message);
  end;
end;

// circle_width#@#n - Set width
function p_circle_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_width#') then Exit;
  try
    TBasCircle(Args[0].p).Width := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_width#: ' + E.Message);
  end;
end;

// circle_height@# - Get height
function n_circle_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_height') then Exit;
  try
    Result.n := TBasCircle(Args[0].p).Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_height: ' + E.Message);
  end;
end;

// circle_height#@#n - Set height
function p_circle_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_height#') then Exit;
  try
    TBasCircle(Args[0].p).Height := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_height#: ' + E.Message);
  end;
end;

// circle_bounds#@#nnnn - Set position and size at once
function p_circle_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_bounds#') then Exit;
  try
    TBasCircle(Args[0].p).SetBounds(Args[1].n, Args[2].n, Args[3].n, Args[4].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_bounds#: ' + E.Message);
  end;
end;

// circle_size#@#nn - Set width and height
function p_circle_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_size#') then Exit;
  try
    TBasCircle(Args[0].p).Width := Args[1].n;
    TBasCircle(Args[0].p).Height := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_size#: ' + E.Message);
  end;
end;

// circle_move#@#nn - Set position
function p_circle_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_move#') then Exit;
  try
    TBasCircle(Args[0].p).Position.X := Args[1].n;
    TBasCircle(Args[0].p).Position.Y := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_move#: ' + E.Message);
  end;
end;

//==============================================================================
// Alignment Functions
//==============================================================================

// circle_align@# - Get alignment
function n_circle_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_align') then Exit;
  try
    Result.n := AlignToInt(TBasCircle(Args[0].p).Align);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_align: ' + E.Message);
  end;
end;

// circle_align#@#n - Set alignment
function p_circle_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_align#') then Exit;
  try
    TBasCircle(Args[0].p).Align := AlignFromInt(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_align#: ' + E.Message);
  end;
end;

//==============================================================================
// Margin Functions
//==============================================================================

// circle_marginleft@# - Get left margin
function n_circle_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_marginleft') then Exit;
  try
    Result.n := TBasCircle(Args[0].p).Margins.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_marginleft: ' + E.Message);
  end;
end;

// circle_marginleft#@#n - Set left margin
function p_circle_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_marginleft#') then Exit;
  try
    TBasCircle(Args[0].p).Margins.Left := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_marginleft#: ' + E.Message);
  end;
end;

// circle_margintop@# - Get top margin
function n_circle_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_margintop') then Exit;
  try
    Result.n := TBasCircle(Args[0].p).Margins.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_margintop: ' + E.Message);
  end;
end;

// circle_margintop#@#n - Set top margin
function p_circle_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_margintop#') then Exit;
  try
    TBasCircle(Args[0].p).Margins.Top := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_margintop#: ' + E.Message);
  end;
end;

// circle_marginright@# - Get right margin
function n_circle_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_marginright') then Exit;
  try
    Result.n := TBasCircle(Args[0].p).Margins.Right;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_marginright: ' + E.Message);
  end;
end;

// circle_marginright#@#n - Set right margin
function p_circle_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_marginright#') then Exit;
  try
    TBasCircle(Args[0].p).Margins.Right := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_marginright#: ' + E.Message);
  end;
end;

// circle_marginbottom@# - Get bottom margin
function n_circle_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_marginbottom') then Exit;
  try
    Result.n := TBasCircle(Args[0].p).Margins.Bottom;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_marginbottom: ' + E.Message);
  end;
end;

// circle_marginbottom#@#n - Set bottom margin
function p_circle_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_marginbottom#') then Exit;
  try
    TBasCircle(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_marginbottom#: ' + E.Message);
  end;
end;

// circle_margins#@#nnnn - Set all margins
function p_circle_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_margins#') then Exit;
  try
    TBasCircle(Args[0].p).Margins.Left := Args[1].n;
    TBasCircle(Args[0].p).Margins.Top := Args[2].n;
    TBasCircle(Args[0].p).Margins.Right := Args[3].n;
    TBasCircle(Args[0].p).Margins.Bottom := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_margins#: ' + E.Message);
  end;
end;

// circle_margin#@#n - Set all margins to same value
function p_circle_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_margin#') then Exit;
  try
    TBasCircle(Args[0].p).Margins.Left := Args[1].n;
    TBasCircle(Args[0].p).Margins.Top := Args[1].n;
    TBasCircle(Args[0].p).Margins.Right := Args[1].n;
    TBasCircle(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_margin#: ' + E.Message);
  end;
end;

//==============================================================================
// Visibility and Behavior Functions
//==============================================================================

// circle_visible@# - Get visible state
function n_circle_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_visible') then Exit;
  try
    if TBasCircle(Args[0].p).Visible then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_visible: ' + E.Message);
  end;
end;

// circle_visible#@#n - Set visible state
function p_circle_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_visible#') then Exit;
  try
    TBasCircle(Args[0].p).Visible := Args[1].n <> 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_visible#: ' + E.Message);
  end;
end;

// circle_enabled@# - Get enabled state
function n_circle_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_enabled') then Exit;
  try
    if TBasCircle(Args[0].p).Enabled then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_enabled: ' + E.Message);
  end;
end;

// circle_enabled#@#n - Set enabled state
function p_circle_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_enabled#') then Exit;
  try
    TBasCircle(Args[0].p).Enabled := Args[1].n <> 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_enabled#: ' + E.Message);
  end;
end;

// circle_opacity@# - Get opacity (0.0 to 1.0)
function n_circle_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_opacity') then Exit;
  try
    Result.n := TBasCircle(Args[0].p).Opacity;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_opacity: ' + E.Message);
  end;
end;

// circle_opacity#@#n - Set opacity (0.0 to 1.0)
function p_circle_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_opacity#') then Exit;
  try
    TBasCircle(Args[0].p).Opacity := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_opacity#: ' + E.Message);
  end;
end;

// circle_hittest@# - Get hit test state
function n_circle_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_hittest') then Exit;
  try
    if TBasCircle(Args[0].p).HitTest then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_hittest: ' + E.Message);
  end;
end;

// circle_hittest#@#n - Set hit test state
function p_circle_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_hittest#') then Exit;
  try
    TBasCircle(Args[0].p).HitTest := Args[1].n <> 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_hittest#: ' + E.Message);
  end;
end;

//==============================================================================
// Tag and Rotation Functions
//==============================================================================

// circle_tag@# - Get tag
function n_circle_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_tag') then Exit;
  try
    Result.n := TBasCircle(Args[0].p).Tag;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_tag: ' + E.Message);
  end;
end;

// circle_tag#@#n - Set tag
function p_circle_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_tag#') then Exit;
  try
    TBasCircle(Args[0].p).Tag := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_tag#: ' + E.Message);
  end;
end;

// circle_rotation@# - Get rotation angle
function n_circle_rotation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_rotation') then Exit;
  try
    Result.n := TBasCircle(Args[0].p).RotationAngle;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_rotation: ' + E.Message);
  end;
end;

// circle_rotation#@#n - Set rotation angle
function p_circle_rotation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_rotation#') then Exit;
  try
    TBasCircle(Args[0].p).RotationAngle := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_rotation#: ' + E.Message);
  end;
end;

//==============================================================================
// Parent Functions
//==============================================================================

// circle_parent#@# - Get parent
function p_circle_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_parent#') then Exit;
  try
    Result.p := TBasCircle(Args[0].p).Parent;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_parent#: ' + E.Message);
  end;
end;

// circle_parent#@## - Set parent
function p_circle_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_parent#') then Exit;
  if not ValidateParent(Args[1].p, 'circle_parent#') then Exit;
  try
    TBasCircle(Args[0].p).Parent := TFmxObject(Args[1].p);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_parent#: ' + E.Message);
  end;
end;

// circle_bringtofront#@# - Bring to front
function p_circle_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_bringtofront#') then Exit;
  try
    TBasCircle(Args[0].p).BringToFront;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_bringtofront#: ' + E.Message);
  end;
end;

// circle_sendtoback#@# - Send to back
function p_circle_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_sendtoback#') then Exit;
  try
    TBasCircle(Args[0].p).SendToBack;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_sendtoback#: ' + E.Message);
  end;
end;

//==============================================================================
// Invalidation Function
//==============================================================================

// circle_invalidate#@# - Force repaint
function p_circle_invalidate(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_invalidate#') then Exit;
  try
    TBasCircle(Args[0].p).Repaint;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_invalidate#: ' + E.Message);
  end;
end;

//==============================================================================
// Event Callback Functions
//==============================================================================

// circle_onclick#@#$ - Set OnClick handler
function p_circle_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onclick#') then Exit;
  try
    TBasCircle(Args[0].p).OnClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onclick#: ' + E.Message);
  end;
end;

// circle_onclick$@# - Get OnClick handler name
function s_circle_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onclick$') then Exit;
  try
    Result.s := TBasCircle(Args[0].p).OnClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onclick$: ' + E.Message);
  end;
end;

// circle_ondblclick#@#$ - Set OnDblClick handler
function p_circle_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_ondblclick#') then Exit;
  try
    TBasCircle(Args[0].p).OnDblClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_ondblclick#: ' + E.Message);
  end;
end;

// circle_ondblclick$@# - Get OnDblClick handler name
function s_circle_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_ondblclick$') then Exit;
  try
    Result.s := TBasCircle(Args[0].p).OnDblClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_ondblclick$: ' + E.Message);
  end;
end;

// circle_onmousedown#@#$ - Set OnMouseDown handler
function p_circle_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onmousedown#') then Exit;
  try
    TBasCircle(Args[0].p).OnMouseDownFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onmousedown#: ' + E.Message);
  end;
end;

// circle_onmousedown$@# - Get OnMouseDown handler name
function s_circle_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onmousedown$') then Exit;
  try
    Result.s := TBasCircle(Args[0].p).OnMouseDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onmousedown$: ' + E.Message);
  end;
end;

// circle_onmouseup#@#$ - Set OnMouseUp handler
function p_circle_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onmouseup#') then Exit;
  try
    TBasCircle(Args[0].p).OnMouseUpFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onmouseup#: ' + E.Message);
  end;
end;

// circle_onmouseup$@# - Get OnMouseUp handler name
function s_circle_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onmouseup$') then Exit;
  try
    Result.s := TBasCircle(Args[0].p).OnMouseUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onmouseup$: ' + E.Message);
  end;
end;

// circle_onmousemove#@#$ - Set OnMouseMove handler
function p_circle_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onmousemove#') then Exit;
  try
    TBasCircle(Args[0].p).OnMouseMoveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onmousemove#: ' + E.Message);
  end;
end;

// circle_onmousemove$@# - Get OnMouseMove handler name
function s_circle_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onmousemove$') then Exit;
  try
    Result.s := TBasCircle(Args[0].p).OnMouseMoveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onmousemove$: ' + E.Message);
  end;
end;

// circle_onmouseenter#@#$ - Set OnMouseEnter handler
function p_circle_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onmouseenter#') then Exit;
  try
    TBasCircle(Args[0].p).OnMouseEnterFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onmouseenter#: ' + E.Message);
  end;
end;

// circle_onmouseenter$@# - Get OnMouseEnter handler name
function s_circle_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onmouseenter$') then Exit;
  try
    Result.s := TBasCircle(Args[0].p).OnMouseEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onmouseenter$: ' + E.Message);
  end;
end;

// circle_onmouseleave#@#$ - Set OnMouseLeave handler
function p_circle_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onmouseleave#') then Exit;
  try
    TBasCircle(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onmouseleave#: ' + E.Message);
  end;
end;

// circle_onmouseleave$@# - Get OnMouseLeave handler name
function s_circle_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onmouseleave$') then Exit;
  try
    Result.s := TBasCircle(Args[0].p).OnMouseLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onmouseleave$: ' + E.Message);
  end;
end;

// circle_onmousewheel#@#$ - Set OnMouseWheel handler
function p_circle_onmousewheel_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onmousewheel#') then Exit;
  try
    TBasCircle(Args[0].p).OnMouseWheelFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onmousewheel#: ' + E.Message);
  end;
end;

// circle_onmousewheel$@# - Get OnMouseWheel handler name
function s_circle_onmousewheel_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onmousewheel$') then Exit;
  try
    Result.s := TBasCircle(Args[0].p).OnMouseWheelFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onmousewheel$: ' + E.Message);
  end;
end;

// circle_onresize#@#$ - Set OnResize handler
function p_circle_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onresize#') then Exit;
  try
    TBasCircle(Args[0].p).OnResizeFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onresize#: ' + E.Message);
  end;
end;

// circle_onresize$@# - Get OnResize handler name
function s_circle_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCircle(Args[0].p, 'circle_onresize$') then Exit;
  try
    Result.s := TBasCircle(Args[0].p).OnResizeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_onresize$: ' + E.Message);
  end;
end;

// circle_clearcallbacks#@# - Clear all callbacks
function p_circle_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateCircle(Args[0].p, 'circle_clearcallbacks#') then Exit;

  try
    with TBasCircle(Args[0].p) do
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
      OnPaintFunc := '';
      OnDragEnterFunc := '';
      OnDragOverFunc := '';
      OnDragDropFunc := '';
      OnDragLeaveFunc := '';
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'circle_clearcallbacks#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterCircleFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin

  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_circle_error; Lib.Add('circle_error@', Fn);
  Fn.Entry := @s_circle_errormsg; Lib.Add('circle_errormsg$@', Fn);
  Fn.Entry := @s_circle_strerror; Lib.Add('circle_strerror$@n', Fn);
  Fn.Entry := @n_circle_clearerror; Lib.Add('circle_clearerror@', Fn);

  // Circle creation/destruction
  Fn.Entry := @p_circle_new; Lib.Add('circle#@#', Fn);
  Fn.Entry := @p_circle_new_size; Lib.Add('circle#@#nn', Fn);
  Fn.Entry := @p_circle_new_full; Lib.Add('circle#@#nnnn', Fn);
  Fn.Entry := @n_circle_free; Lib.Add('circle_free@#', Fn);

  // Fill
  Fn.Entry := @s_circle_fill_get; Lib.Add('circle_fill$@#', Fn);
  Fn.Entry := @p_circle_fill_set; Lib.Add('circle_fill#@#$', Fn);
  Fn.Entry := @p_circle_fillnone; Lib.Add('circle_fillnone#@#', Fn);

  // Stroke
  Fn.Entry := @s_circle_stroke_get; Lib.Add('circle_stroke$@#', Fn);
  Fn.Entry := @p_circle_stroke_set; Lib.Add('circle_stroke#@#$', Fn);
  Fn.Entry := @p_circle_strokenone; Lib.Add('circle_strokenone#@#', Fn);
  Fn.Entry := @n_circle_strokethickness_get; Lib.Add('circle_strokethickness@#', Fn);
  Fn.Entry := @p_circle_strokethickness_set; Lib.Add('circle_strokethickness#@#n', Fn);
  Fn.Entry := @n_circle_strokedash_get; Lib.Add('circle_strokedash@#', Fn);
  Fn.Entry := @p_circle_strokedash_set; Lib.Add('circle_strokedash#@#n', Fn);
  Fn.Entry := @n_circle_strokecap_get; Lib.Add('circle_strokecap@#', Fn);
  Fn.Entry := @p_circle_strokecap_set; Lib.Add('circle_strokecap#@#n', Fn);
  Fn.Entry := @n_circle_strokejoin_get; Lib.Add('circle_strokejoin@#', Fn);
  Fn.Entry := @p_circle_strokejoin_set; Lib.Add('circle_strokejoin#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_circle_x_get; Lib.Add('circle_x@#', Fn);
  Fn.Entry := @p_circle_x_set; Lib.Add('circle_x#@#n', Fn);
  Fn.Entry := @n_circle_y_get; Lib.Add('circle_y@#', Fn);
  Fn.Entry := @p_circle_y_set; Lib.Add('circle_y#@#n', Fn);
  Fn.Entry := @n_circle_width_get; Lib.Add('circle_width@#', Fn);
  Fn.Entry := @p_circle_width_set; Lib.Add('circle_width#@#n', Fn);
  Fn.Entry := @n_circle_height_get; Lib.Add('circle_height@#', Fn);
  Fn.Entry := @p_circle_height_set; Lib.Add('circle_height#@#n', Fn);
  Fn.Entry := @p_circle_bounds_set; Lib.Add('circle_bounds#@#nnnn', Fn);
  Fn.Entry := @p_circle_size_set; Lib.Add('circle_size#@#nn', Fn);
  Fn.Entry := @p_circle_move_set; Lib.Add('circle_move#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_circle_align_get; Lib.Add('circle_align@#', Fn);
  Fn.Entry := @p_circle_align_set; Lib.Add('circle_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_circle_marginleft_get; Lib.Add('circle_marginleft@#', Fn);
  Fn.Entry := @p_circle_marginleft_set; Lib.Add('circle_marginleft#@#n', Fn);
  Fn.Entry := @n_circle_margintop_get; Lib.Add('circle_margintop@#', Fn);
  Fn.Entry := @p_circle_margintop_set; Lib.Add('circle_margintop#@#n', Fn);
  Fn.Entry := @n_circle_marginright_get; Lib.Add('circle_marginright@#', Fn);
  Fn.Entry := @p_circle_marginright_set; Lib.Add('circle_marginright#@#n', Fn);
  Fn.Entry := @n_circle_marginbottom_get; Lib.Add('circle_marginbottom@#', Fn);
  Fn.Entry := @p_circle_marginbottom_set; Lib.Add('circle_marginbottom#@#n', Fn);
  Fn.Entry := @p_circle_margins_set; Lib.Add('circle_margins#@#nnnn', Fn);
  Fn.Entry := @p_circle_margin_set; Lib.Add('circle_margin#@#n', Fn);

  // Visibility and behavior
  Fn.Entry := @n_circle_visible_get; Lib.Add('circle_visible@#', Fn);
  Fn.Entry := @p_circle_visible_set; Lib.Add('circle_visible#@#n', Fn);
  Fn.Entry := @n_circle_enabled_get; Lib.Add('circle_enabled@#', Fn);
  Fn.Entry := @p_circle_enabled_set; Lib.Add('circle_enabled#@#n', Fn);
  Fn.Entry := @n_circle_opacity_get; Lib.Add('circle_opacity@#', Fn);
  Fn.Entry := @p_circle_opacity_set; Lib.Add('circle_opacity#@#n', Fn);
  Fn.Entry := @n_circle_hittest_get; Lib.Add('circle_hittest@#', Fn);
  Fn.Entry := @p_circle_hittest_set; Lib.Add('circle_hittest#@#n', Fn);

  // Tag and rotation
  Fn.Entry := @n_circle_tag_get; Lib.Add('circle_tag@#', Fn);
  Fn.Entry := @p_circle_tag_set; Lib.Add('circle_tag#@#n', Fn);
  Fn.Entry := @n_circle_rotation_get; Lib.Add('circle_rotation@#', Fn);
  Fn.Entry := @p_circle_rotation_set; Lib.Add('circle_rotation#@#n', Fn);

  // Parent
  Fn.Entry := @p_circle_parent_get; Lib.Add('circle_parent#@#', Fn);
  Fn.Entry := @p_circle_parent_set; Lib.Add('circle_parent#@##', Fn);
  Fn.Entry := @p_circle_bringtofront; Lib.Add('circle_bringtofront#@#', Fn);
  Fn.Entry := @p_circle_sendtoback; Lib.Add('circle_sendtoback#@#', Fn);

  // Invalidation
  Fn.Entry := @p_circle_invalidate; Lib.Add('circle_invalidate#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_circle_onclick_set; Lib.Add('circle_onclick#@#$', Fn);
  Fn.Entry := @s_circle_onclick_get; Lib.Add('circle_onclick$@#', Fn);
  Fn.Entry := @p_circle_ondblclick_set; Lib.Add('circle_ondblclick#@#$', Fn);
  Fn.Entry := @s_circle_ondblclick_get; Lib.Add('circle_ondblclick$@#', Fn);
  Fn.Entry := @p_circle_onmousedown_set; Lib.Add('circle_onmousedown#@#$', Fn);
  Fn.Entry := @s_circle_onmousedown_get; Lib.Add('circle_onmousedown$@#', Fn);
  Fn.Entry := @p_circle_onmouseup_set; Lib.Add('circle_onmouseup#@#$', Fn);
  Fn.Entry := @s_circle_onmouseup_get; Lib.Add('circle_onmouseup$@#', Fn);
  Fn.Entry := @p_circle_onmousemove_set; Lib.Add('circle_onmousemove#@#$', Fn);
  Fn.Entry := @s_circle_onmousemove_get; Lib.Add('circle_onmousemove$@#', Fn);
  Fn.Entry := @p_circle_onmouseenter_set; Lib.Add('circle_onmouseenter#@#$', Fn);
  Fn.Entry := @s_circle_onmouseenter_get; Lib.Add('circle_onmouseenter$@#', Fn);
  Fn.Entry := @p_circle_onmouseleave_set; Lib.Add('circle_onmouseleave#@#$', Fn);
  Fn.Entry := @s_circle_onmouseleave_get; Lib.Add('circle_onmouseleave$@#', Fn);
  Fn.Entry := @p_circle_onmousewheel_set; Lib.Add('circle_onmousewheel#@#$', Fn);
  Fn.Entry := @s_circle_onmousewheel_get; Lib.Add('circle_onmousewheel$@#', Fn);
  Fn.Entry := @p_circle_onresize_set; Lib.Add('circle_onresize#@#$', Fn);
  Fn.Entry := @s_circle_onresize_get; Lib.Add('circle_onresize$@#', Fn);
  Fn.Entry := @p_circle_clearcallbacks; Lib.Add('circle_clearcallbacks#@#', Fn);
end;

end.

