unit ArcLib;

{******************************************************************************
  ArcLib - Arc Visual Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TArc wrapper functionality for creating
  and managing arc visual controls in Plan9Basic programs. TArc is a visual
  shape control that draws an arc (portion of an ellipse) defined by start
  and end angles.

  Function Count: 77 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All arcs are created at RUNTIME using TArc.Create with dynamic parent
  assignment. This ensures proper dynamic creation across all platforms.

  FEATURES:
  =========
  - Arc creation and lifecycle management
  - Start and end angle control (defines the arc portion)
  - Fill color and style (solid, gradient support via color)
  - Stroke (border) color, thickness, and style
  - Complete positioning and alignment
  - Full event support with BASIC callback integration

  ARC ANGLES:
  ===========
  Angles are specified in degrees (0-360):
  - 0° = Right (3 o'clock position)
  - 90° = Bottom (6 o'clock position)
  - 180° = Left (9 o'clock position)
  - 270° = Top (12 o'clock position)

  The arc is drawn clockwise from StartAngle to EndAngle.

  Examples:
  - StartAngle=0, EndAngle=90 → Quarter circle (bottom-right quadrant)
  - StartAngle=0, EndAngle=180 → Semi-circle (bottom half)
  - StartAngle=0, EndAngle=360 → Full circle
  - StartAngle=45, EndAngle=135 → 90° arc

  EVENTS SUPPORT:
  ===============
  - OnClick: Arc was clicked
  - OnDblClick: Arc was double-clicked
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over arc
  - OnMouseEnter: Mouse entered arc area
  - OnMouseLeave: Mouse left arc area
  - OnMouseWheel: Mouse wheel scrolled
  - OnResize: Arc is being resized
  - OnResized: Arc resize completed
  - OnPaint: Arc needs repainting

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
    let frm# = form#("Arc Demo", 800, 600)

    ' Create a blue quarter-circle arc
    let a# = arc#(frm#, 50, 50, 100, 100)
    arc_startangle#(a#, 0)
    arc_endangle#(a#, 90)
    arc_fill#(a#, "#3498db")
    arc_stroke#(a#, "#2980b9")
    arc_strokethickness#(a#, 2)

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnArcClick(sender#)
      println "Arc clicked!"
    endfunction

    function OnArcMouseMove(sender#, x, y, shift$)
      println "Mouse at: " + stri$(x) + ", " + stri$(y)
    endfunction

  Copyright (c) 2024-2026 André Murta
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, ControlCommon;

type
  // Forward declaration
  TBasArc = class;

  {****************************************************************************
    TBasArc - Extended TArc with BASIC event callback support

    Wraps a TArc and provides event bridging to Plan9Basic user functions.
    Each event stores the name of a BASIC function to call when triggered.
  ****************************************************************************}
  TBasArc = class(TArc)
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
procedure RegisterArcFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  ARC_GC_TAG = 'BASIC_ARC';

  // Error codes
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_ARC = 1;
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

function ValidateArc(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_ARC, FuncName + ': Nil arc pointer');
    Exit;
  end;

  try
    if not (IsHandleOf(P, TBasArc)) then
    begin
      SetError(ERR_INVALID_ARC, FuncName + ': Invalid arc object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_ARC, FuncName + ': Invalid arc pointer');
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
// TBasArc Implementation
//==============================================================================

constructor TBasArc.Create(AOwner: TComponent);
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

destructor TBasArc.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectEvents();
  inherited Destroy();
end;

procedure TBasArc.DisconnectEvents();
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

function TBasArc.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

procedure TBasArc.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'Arc');
end;

function TBasArc.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
begin
  Result := ControlCommon.RunCallbackWithResult(FBasicEngine, FConsoleOutput,
                          FuncSignature, Args, 'Arc');
end;

procedure TBasArc.InternalOnClick(Sender: TObject);
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

procedure TBasArc.InternalOnDblClick(Sender: TObject);
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

procedure TBasArc.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnDragDropFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

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

procedure TBasArc.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnDragEnterFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

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

procedure TBasArc.InternalOnDragLeave(Sender: TObject);
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

procedure TBasArc.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
  RetVal: TAsmData;
begin
  if FOnDragOverFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

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

procedure TBasArc.InternalOnMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TBasArc.InternalOnMouseUp(Sender: TObject; Button: TMouseButton;
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

procedure TBasArc.InternalOnMouseMove(Sender: TObject; Shift: TShiftState;
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

procedure TBasArc.InternalOnMouseEnter(Sender: TObject);
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

procedure TBasArc.InternalOnMouseLeave(Sender: TObject);
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

procedure TBasArc.InternalOnMouseWheel(Sender: TObject; Shift: TShiftState;
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

procedure TBasArc.InternalOnResize(Sender: TObject);
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

procedure TBasArc.InternalOnResized(Sender: TObject);
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

procedure TBasArc.InternalOnPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
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

procedure TBasArc.SetOnClickFunc(const Value: String);
begin
  ControlCommon.BindClick(Self, Value, FOnClickFunc, InternalOnClick);
end;

procedure TBasArc.SetOnDblClickFunc(const Value: String);
begin
  ControlCommon.BindDblClick(Self, Value, FOnDblClickFunc, InternalOnDblClick);
end;

procedure TBasArc.SetOnDragDropFunc(const Value: String);
begin
  ControlCommon.BindDragDrop(Self, Value, FOnDragDropFunc, InternalOnDragDrop);
end;

procedure TBasArc.SetOnDragEnterFunc(const Value: String);
begin
  ControlCommon.BindDragEnter(Self, Value, FOnDragEnterFunc, InternalOnDragEnter);
end;

procedure TBasArc.SetOnDragLeaveFunc(const Value: String);
begin
  ControlCommon.BindDragLeave(Self, Value, FOnDragLeaveFunc, InternalOnDragLeave);
end;

procedure TBasArc.SetOnDragOverFunc(const Value: String);
begin
  ControlCommon.BindDragOver(Self, Value, FOnDragOverFunc, InternalOnDragOver);
end;

procedure TBasArc.SetOnMouseDownFunc(const Value: String);
begin
  ControlCommon.BindMouseDown(Self, Value, FOnMouseDownFunc, InternalOnMouseDown);
end;

procedure TBasArc.SetOnMouseUpFunc(const Value: String);
begin
  ControlCommon.BindMouseUp(Self, Value, FOnMouseUpFunc, InternalOnMouseUp);
end;

procedure TBasArc.SetOnMouseMoveFunc(const Value: String);
begin
  ControlCommon.BindMouseMove(Self, Value, FOnMouseMoveFunc, InternalOnMouseMove);
end;

procedure TBasArc.SetOnMouseEnterFunc(const Value: String);
begin
  ControlCommon.BindMouseEnter(Self, Value, FOnMouseEnterFunc, InternalOnMouseEnter);
end;

procedure TBasArc.SetOnMouseLeaveFunc(const Value: String);
begin
  ControlCommon.BindMouseLeave(Self, Value, FOnMouseLeaveFunc, InternalOnMouseLeave);
end;

procedure TBasArc.SetOnMouseWheelFunc(const Value: String);
begin
  ControlCommon.BindMouseWheel(Self, Value, FOnMouseWheelFunc, InternalOnMouseWheel);
end;

procedure TBasArc.SetOnResizeFunc(const Value: String);
begin
  ControlCommon.BindResize(Self, Value, FOnResizeFunc, InternalOnResize);
end;

procedure TBasArc.SetOnResizedFunc(const Value: String);
begin
  ControlCommon.BindResized(Self, Value, FOnResizedFunc, InternalOnResized);
end;

procedure TBasArc.SetOnPaintFunc(const Value: String);
begin
  ControlCommon.BindPaint(Self, Value, FOnPaintFunc, InternalOnPaint);
end;

//==============================================================================
// Error Handling Functions
//==============================================================================

// arc_error@ - Get last error code
function n_arc_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

// arc_errormsg$@ - Get last error message
function s_arc_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

// arc_strerror$@n - Get error description by code
function s_arc_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Trunc(Args[0].n) of
    ERR_NONE:            Result.s := 'No error';
    ERR_INVALID_ARC:     Result.s := 'Invalid arc';
    ERR_INVALID_PARENT:  Result.s := 'Invalid parent';
    ERR_INVALID_VALUE:   Result.s := 'Invalid value';
    ERR_CREATE_FAILED:   Result.s := 'Creation failed';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback';
    ERR_INVALID_COLOR:   Result.s := 'Invalid color';
  else
    Result.s := 'Unknown error';
  end;
end;

// arc_clearerror@ - Clear last error
function n_arc_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

//==============================================================================
// Arc Creation/Destruction Functions
//==============================================================================

// arc#@# - Create arc with parent only
function p_arc_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Arc: TBasArc;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'arc#') then Exit;

  try
    Arc := TBasArc.Create(nil);
    Arc.Parent := TFmxObject(Args[0].p);
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Arc, Eng, Outp) then
    begin
      Arc.BasicEngine := Eng;
      Arc.ConsoleOutput := Outp;
    end;
    Arc.HitTest := True;  // Enable mouse events by default

    Result.p := Pointer(Arc);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Arc, ARC_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'arc#: ' + E.Message);
    end;
  end;
end;

// arc#@#nn - Create arc with parent and size (width, height)
function p_arc_new_size(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Arc: TBasArc;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'arc#') then Exit;

  try
    Arc := TBasArc.Create(nil);
    Arc.Parent := TFmxObject(Args[0].p);
    Arc.Width := Args[1].n;
    Arc.Height := Args[2].n;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Arc, Eng, Outp) then
    begin
      Arc.BasicEngine := Eng;
      Arc.ConsoleOutput := Outp;
    end;
    Arc.HitTest := True;

    Result.p := Pointer(Arc);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Arc, ARC_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'arc#: ' + E.Message);
    end;
  end;
end;

// arc#@#nnnn - Create arc with parent, position, and size
function p_arc_new_full(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Arc: TBasArc;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'arc#') then Exit;

  try
    Arc := TBasArc.Create(nil);
    Arc.Parent := TFmxObject(Args[0].p);
    Arc.Position.X := Args[1].n;
    Arc.Position.Y := Args[2].n;
    Arc.Width := Args[3].n;
    Arc.Height := Args[4].n;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Arc, Eng, Outp) then
    begin
      Arc.BasicEngine := Eng;
      Arc.ConsoleOutput := Outp;
    end;
    Arc.HitTest := True;

    Result.p := Pointer(Arc);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Arc, ARC_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'arc#: ' + E.Message);
    end;
  end;
end;

// arc_free@# - Explicitly free an arc
function n_arc_free(var Args: array of TAsmData): TAsmData;
var
  Arc: TBasArc;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateArc(Args[0].p, 'arc_free') then Exit;

  try
    Arc := TBasArc(Args[0].p);
    Arc.DisconnectEvents;
    Arc.Free();

//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(ARC_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
    //Its eighty-one siblings answer 1 on success. This one did too, inside
    //the collector block that was commented out.
    Result.n := 1;
  except
    on E: Exception do
    begin
      SetError(ERR_INVALID_ARC, 'arc_free: ' + E.Message);
    end;
  end;
end;

//==============================================================================
// Arc-Specific Angle Functions
//==============================================================================

// arc_startangle@# - Get start angle
function n_arc_startangle_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_startangle') then Exit;
  try
    Result.n := TBasArc(Args[0].p).StartAngle;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_startangle: ' + E.Message);
  end;
end;

// arc_startangle#@#n - Set start angle
function p_arc_startangle_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_startangle#') then Exit;
  try
    TBasArc(Args[0].p).StartAngle := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_startangle#: ' + E.Message);
  end;
end;

// arc_endangle@# - Get end angle
function n_arc_endangle_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_endangle') then Exit;
  try
    Result.n := TBasArc(Args[0].p).EndAngle;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_endangle: ' + E.Message);
  end;
end;

// arc_endangle#@#n - Set end angle
function p_arc_endangle_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_endangle#') then Exit;
  try
    TBasArc(Args[0].p).EndAngle := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_endangle#: ' + E.Message);
  end;
end;

// arc_angles#@#nn - Set both start and end angles at once
function p_arc_angles_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_angles#') then Exit;
  try
    TBasArc(Args[0].p).StartAngle := Args[1].n;
    TBasArc(Args[0].p).EndAngle := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_angles#: ' + E.Message);
  end;
end;

//==============================================================================
// Fill Functions
//==============================================================================

// arc_fill$@# - Get fill color
function s_arc_fill_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_fill$') then Exit;
  try
    Result.s := TUtils.AlphaColorToStr(TBasArc(Args[0].p).Fill.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_fill$: ' + E.Message);
  end;
end;

// arc_fill#@#$ - Set fill color
function p_arc_fill_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_fill#') then Exit;
  try
    TBasArc(Args[0].p).Fill.Color := TUtils.ColorToAlphaColor(Args[1].s);
    TBasArc(Args[0].p).Fill.Kind := TBrushKind.Solid;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_fill#: ' + E.Message);
  end;
end;

// arc_fillnone#@# - Set fill to none (transparent)
function p_arc_fillnone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_fillnone#') then Exit;
  try
    TBasArc(Args[0].p).Fill.Kind := TBrushKind.None;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_fillnone#: ' + E.Message);
  end;
end;

//==============================================================================
// Stroke Functions
//==============================================================================

// arc_stroke$@# - Get stroke color
function s_arc_stroke_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_stroke$') then Exit;
  try
    Result.s := TUtils.AlphaColorToStr(TBasArc(Args[0].p).Stroke.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_stroke$: ' + E.Message);
  end;
end;

// arc_stroke#@#$ - Set stroke color
function p_arc_stroke_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_stroke#') then Exit;
  try
    TBasArc(Args[0].p).Stroke.Color := TUtils.ColorToAlphaColor(Args[1].s);
    TBasArc(Args[0].p).Stroke.Kind := TBrushKind.Solid;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_stroke#: ' + E.Message);
  end;
end;

// arc_strokenone#@# - Set stroke to none
function p_arc_strokenone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_strokenone#') then Exit;
  try
    TBasArc(Args[0].p).Stroke.Kind := TBrushKind.None;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_strokenone#: ' + E.Message);
  end;
end;

// arc_strokethickness@# - Get stroke thickness
function n_arc_strokethickness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_strokethickness') then Exit;
  try
    Result.n := TBasArc(Args[0].p).Stroke.Thickness;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_strokethickness: ' + E.Message);
  end;
end;

// arc_strokethickness#@#n - Set stroke thickness
function p_arc_strokethickness_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_strokethickness#') then Exit;
  try
    TBasArc(Args[0].p).Stroke.Thickness := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_strokethickness#: ' + E.Message);
  end;
end;

// arc_strokedash@# - Get stroke dash style
function n_arc_strokedash_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_strokedash') then Exit;
  try
    Result.n := StrokeDashToInt(TBasArc(Args[0].p).Stroke.Dash);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_strokedash: ' + E.Message);
  end;
end;

// arc_strokedash#@#n - Set stroke dash style
function p_arc_strokedash_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_strokedash#') then Exit;
  try
    TBasArc(Args[0].p).Stroke.Dash := IntToStrokeDash(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_strokedash#: ' + E.Message);
  end;
end;

// arc_strokecap@# - Get stroke cap style
function n_arc_strokecap_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_strokecap') then Exit;
  try
    Result.n := StrokeCapToInt(TBasArc(Args[0].p).Stroke.Cap);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_strokecap: ' + E.Message);
  end;
end;

// arc_strokecap#@#n - Set stroke cap style
function p_arc_strokecap_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_strokecap#') then Exit;
  try
    TBasArc(Args[0].p).Stroke.Cap := IntToStrokeCap(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_strokecap#: ' + E.Message);
  end;
end;

// arc_strokejoin@# - Get stroke join style
function n_arc_strokejoin_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_strokejoin') then Exit;
  try
    Result.n := StrokeJoinToInt(TBasArc(Args[0].p).Stroke.Join);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_strokejoin: ' + E.Message);
  end;
end;

// arc_strokejoin#@#n - Set stroke join style
function p_arc_strokejoin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_strokejoin#') then Exit;
  try
    TBasArc(Args[0].p).Stroke.Join := IntToStrokeJoin(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_strokejoin#: ' + E.Message);
  end;
end;

//==============================================================================
// Position and Size Functions
//==============================================================================

// arc_x@# - Get X position
function n_arc_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_x') then Exit;
  try
    Result.n := TBasArc(Args[0].p).Position.X;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_x: ' + E.Message);
  end;
end;

// arc_x#@#n - Set X position
function p_arc_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_x#') then Exit;
  try
    TBasArc(Args[0].p).Position.X := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_x#: ' + E.Message);
  end;
end;

// arc_y@# - Get Y position
function n_arc_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_y') then Exit;
  try
    Result.n := TBasArc(Args[0].p).Position.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_y: ' + E.Message);
  end;
end;

// arc_y#@#n - Set Y position
function p_arc_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_y#') then Exit;
  try
    TBasArc(Args[0].p).Position.Y := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_y#: ' + E.Message);
  end;
end;

// arc_width@# - Get width
function n_arc_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_width') then Exit;
  try
    Result.n := TBasArc(Args[0].p).Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_width: ' + E.Message);
  end;
end;

// arc_width#@#n - Set width
function p_arc_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_width#') then Exit;
  try
    TBasArc(Args[0].p).Width := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_width#: ' + E.Message);
  end;
end;

// arc_height@# - Get height
function n_arc_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_height') then Exit;
  try
    Result.n := TBasArc(Args[0].p).Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_height: ' + E.Message);
  end;
end;

// arc_height#@#n - Set height
function p_arc_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_height#') then Exit;
  try
    TBasArc(Args[0].p).Height := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_height#: ' + E.Message);
  end;
end;

// arc_bounds#@#nnnn - Set bounds (x, y, width, height)
function p_arc_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_bounds#') then Exit;
  try
    TBasArc(Args[0].p).Position.X := Args[1].n;
    TBasArc(Args[0].p).Position.Y := Args[2].n;
    TBasArc(Args[0].p).Width := Args[3].n;
    TBasArc(Args[0].p).Height := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_bounds#: ' + E.Message);
  end;
end;

// arc_size#@#nn - Set size (width, height)
function p_arc_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_size#') then Exit;
  try
    TBasArc(Args[0].p).Width := Args[1].n;
    TBasArc(Args[0].p).Height := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_size#: ' + E.Message);
  end;
end;

// arc_move#@#nn - Set position (x, y)
function p_arc_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_move#') then Exit;
  try
    TBasArc(Args[0].p).Position.X := Args[1].n;
    TBasArc(Args[0].p).Position.Y := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_move#: ' + E.Message);
  end;
end;

//==============================================================================
// Alignment Functions
//==============================================================================

// arc_align@# - Get alignment
function n_arc_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_align') then Exit;
  try
    Result.n := AlignToInt(TBasArc(Args[0].p).Align);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_align: ' + E.Message);
  end;
end;

// arc_align#@#n - Set alignment
function p_arc_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_align#') then Exit;
  try
    TBasArc(Args[0].p).Align := AlignFromInt(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_align#: ' + E.Message);
  end;
end;

//==============================================================================
// Margin Functions
//==============================================================================

// arc_marginleft@# - Get left margin
function n_arc_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_marginleft') then Exit;
  try
    Result.n := TBasArc(Args[0].p).Margins.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_marginleft: ' + E.Message);
  end;
end;

// arc_marginleft#@#n - Set left margin
function p_arc_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_marginleft#') then Exit;
  try
    TBasArc(Args[0].p).Margins.Left := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_marginleft#: ' + E.Message);
  end;
end;

// arc_margintop@# - Get top margin
function n_arc_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_margintop') then Exit;
  try
    Result.n := TBasArc(Args[0].p).Margins.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_margintop: ' + E.Message);
  end;
end;

// arc_margintop#@#n - Set top margin
function p_arc_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_margintop#') then Exit;
  try
    TBasArc(Args[0].p).Margins.Top := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_margintop#: ' + E.Message);
  end;
end;

// arc_marginright@# - Get right margin
function n_arc_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_marginright') then Exit;
  try
    Result.n := TBasArc(Args[0].p).Margins.Right;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_marginright: ' + E.Message);
  end;
end;

// arc_marginright#@#n - Set right margin
function p_arc_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_marginright#') then Exit;
  try
    TBasArc(Args[0].p).Margins.Right := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_marginright#: ' + E.Message);
  end;
end;

// arc_marginbottom@# - Get bottom margin
function n_arc_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_marginbottom') then Exit;
  try
    Result.n := TBasArc(Args[0].p).Margins.Bottom;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_marginbottom: ' + E.Message);
  end;
end;

// arc_marginbottom#@#n - Set bottom margin
function p_arc_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_marginbottom#') then Exit;
  try
    TBasArc(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_marginbottom#: ' + E.Message);
  end;
end;

// arc_margins#@#nnnn - Set all margins (left, top, right, bottom)
function p_arc_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_margins#') then Exit;
  try
    TBasArc(Args[0].p).Margins.Left := Args[1].n;
    TBasArc(Args[0].p).Margins.Top := Args[2].n;
    TBasArc(Args[0].p).Margins.Right := Args[3].n;
    TBasArc(Args[0].p).Margins.Bottom := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_margins#: ' + E.Message);
  end;
end;

// arc_margin#@#n - Set uniform margin
function p_arc_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_margin#') then Exit;
  try
    TBasArc(Args[0].p).Margins.Left := Args[1].n;
    TBasArc(Args[0].p).Margins.Top := Args[1].n;
    TBasArc(Args[0].p).Margins.Right := Args[1].n;
    TBasArc(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_margin#: ' + E.Message);
  end;
end;

//==============================================================================
// Visibility and Behavior Functions
//==============================================================================

// arc_visible@# - Get visible state
function n_arc_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_visible') then Exit;
  try
    if TBasArc(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_visible: ' + E.Message);
  end;
end;

// arc_visible#@#n - Set visible state
function p_arc_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_visible#') then Exit;
  try
    TBasArc(Args[0].p).Visible := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_visible#: ' + E.Message);
  end;
end;

// arc_enabled@# - Get enabled state
function n_arc_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_enabled') then Exit;
  try
    if TBasArc(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_enabled: ' + E.Message);
  end;
end;

// arc_enabled#@#n - Set enabled state
function p_arc_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_enabled#') then Exit;
  try
    TBasArc(Args[0].p).Enabled := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_enabled#: ' + E.Message);
  end;
end;

// arc_opacity@# - Get opacity
function n_arc_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_opacity') then Exit;
  try
    Result.n := TBasArc(Args[0].p).Opacity;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_opacity: ' + E.Message);
  end;
end;

// arc_opacity#@#n - Set opacity
function p_arc_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_opacity#') then Exit;
  try
    TBasArc(Args[0].p).Opacity := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_opacity#: ' + E.Message);
  end;
end;

// arc_hittest@# - Get hit test state
function n_arc_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_hittest') then Exit;
  try
    if TBasArc(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_hittest: ' + E.Message);
  end;
end;

// arc_hittest#@#n - Set hit test state
function p_arc_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_hittest#') then Exit;
  try
    TBasArc(Args[0].p).HitTest := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_hittest#: ' + E.Message);
  end;
end;

//==============================================================================
// Tag and Rotation Functions
//==============================================================================

// arc_tag@# - Get tag value
function n_arc_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_tag') then Exit;
  try
    Result.n := TBasArc(Args[0].p).Tag;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_tag: ' + E.Message);
  end;
end;

// arc_tag#@#n - Set tag value
function p_arc_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_tag#') then Exit;
  try
    TBasArc(Args[0].p).Tag := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_tag#: ' + E.Message);
  end;
end;

// arc_rotation@# - Get rotation angle (control rotation, not arc angle)
function n_arc_rotation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_rotation') then Exit;
  try
    Result.n := TBasArc(Args[0].p).RotationAngle;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_rotation: ' + E.Message);
  end;
end;

// arc_rotation#@#n - Set rotation angle
function p_arc_rotation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_rotation#') then Exit;
  try
    TBasArc(Args[0].p).RotationAngle := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_rotation#: ' + E.Message);
  end;
end;

//==============================================================================
// Parent Functions
//==============================================================================

// arc_parent#@# - Get parent control
function p_arc_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_parent#') then Exit;
  try
    Result.p := TBasArc(Args[0].p).Parent;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_parent#: ' + E.Message);
  end;
end;

// arc_parent#@## - Set parent control
function p_arc_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_parent#') then Exit;
  if not ValidateParent(Args[1].p, 'arc_parent#') then Exit;
  try
    TBasArc(Args[0].p).Parent := TFmxObject(Args[1].p);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_parent#: ' + E.Message);
  end;
end;

// arc_bringtofront#@# - Bring arc to front
function p_arc_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_bringtofront#') then Exit;
  try
    TBasArc(Args[0].p).BringToFront();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_bringtofront#: ' + E.Message);
  end;
end;

// arc_sendtoback#@# - Send arc to back
function p_arc_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_sendtoback#') then Exit;
  try
    TBasArc(Args[0].p).SendToBack();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_sendtoback#: ' + E.Message);
  end;
end;

//==============================================================================
// Invalidation Function
//==============================================================================

// arc_invalidate#@# - Invalidate arc (trigger repaint)
function p_arc_invalidate(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_invalidate#') then Exit;
  try
    TBasArc(Args[0].p).InvalidateRect(TBasArc(Args[0].p).LocalRect);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_invalidate#: ' + E.Message);
  end;
end;

//==============================================================================
// Event Callback Functions
//==============================================================================

// arc_onclick#@#$ - Set onclick callback
function p_arc_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onclick#') then Exit;
  try
    TBasArc(Args[0].p).OnClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onclick#: ' + E.Message);
  end;
end;

// arc_onclick$@# - Get onclick callback name
function s_arc_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onclick$') then Exit;
  try
    Result.s := TBasArc(Args[0].p).OnClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onclick$: ' + E.Message);
  end;
end;

// arc_ondblclick#@#$ - Set ondblclick callback
function p_arc_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_ondblclick#') then Exit;
  try
    TBasArc(Args[0].p).OnDblClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_ondblclick#: ' + E.Message);
  end;
end;

// arc_ondblclick$@# - Get ondblclick callback name
function s_arc_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_ondblclick$') then Exit;
  try
    Result.s := TBasArc(Args[0].p).OnDblClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_ondblclick$: ' + E.Message);
  end;
end;

// arc_onmousedown#@#$ - Set onmousedown callback
function p_arc_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onmousedown#') then Exit;
  try
    TBasArc(Args[0].p).OnMouseDownFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onmousedown#: ' + E.Message);
  end;
end;

// arc_onmousedown$@# - Get onmousedown callback name
function s_arc_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onmousedown$') then Exit;
  try
    Result.s := TBasArc(Args[0].p).OnMouseDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onmousedown$: ' + E.Message);
  end;
end;

// arc_onmouseup#@#$ - Set onmouseup callback
function p_arc_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onmouseup#') then Exit;
  try
    TBasArc(Args[0].p).OnMouseUpFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onmouseup#: ' + E.Message);
  end;
end;

// arc_onmouseup$@# - Get onmouseup callback name
function s_arc_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onmouseup$') then Exit;
  try
    Result.s := TBasArc(Args[0].p).OnMouseUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onmouseup$: ' + E.Message);
  end;
end;

// arc_onmousemove#@#$ - Set onmousemove callback
function p_arc_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onmousemove#') then Exit;
  try
    TBasArc(Args[0].p).OnMouseMoveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onmousemove#: ' + E.Message);
  end;
end;

// arc_onmousemove$@# - Get onmousemove callback name
function s_arc_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onmousemove$') then Exit;
  try
    Result.s := TBasArc(Args[0].p).OnMouseMoveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onmousemove$: ' + E.Message);
  end;
end;

// arc_onmouseenter#@#$ - Set onmouseenter callback
function p_arc_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onmouseenter#') then Exit;
  try
    TBasArc(Args[0].p).OnMouseEnterFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onmouseenter#: ' + E.Message);
  end;
end;

// arc_onmouseenter$@# - Get onmouseenter callback name
function s_arc_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onmouseenter$') then Exit;
  try
    Result.s := TBasArc(Args[0].p).OnMouseEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onmouseenter$: ' + E.Message);
  end;
end;

// arc_onmouseleave#@#$ - Set onmouseleave callback
function p_arc_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onmouseleave#') then Exit;
  try
    TBasArc(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onmouseleave#: ' + E.Message);
  end;
end;

// arc_onmouseleave$@# - Get onmouseleave callback name
function s_arc_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onmouseleave$') then Exit;
  try
    Result.s := TBasArc(Args[0].p).OnMouseLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onmouseleave$: ' + E.Message);
  end;
end;

// arc_onmousewheel#@#$ - Set onmousewheel callback
function p_arc_onmousewheel_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onmousewheel#') then Exit;
  try
    TBasArc(Args[0].p).OnMouseWheelFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onmousewheel#: ' + E.Message);
  end;
end;

// arc_onmousewheel$@# - Get onmousewheel callback name
function s_arc_onmousewheel_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onmousewheel$') then Exit;
  try
    Result.s := TBasArc(Args[0].p).OnMouseWheelFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onmousewheel$: ' + E.Message);
  end;
end;

// arc_onresize#@#$ - Set onresize callback
function p_arc_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onresize#') then Exit;
  try
    TBasArc(Args[0].p).OnResizeFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onresize#: ' + E.Message);
  end;
end;

// arc_onresize$@# - Get onresize callback name
function s_arc_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateArc(Args[0].p, 'arc_onresize$') then Exit;
  try
    Result.s := TBasArc(Args[0].p).OnResizeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'arc_onresize$: ' + E.Message);
  end;
end;

// arc_clearcallbacks#@# - Clear all callbacks
function p_arc_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateArc(Args[0].p, 'arc_clearcallbacks#') then Exit;

  try
    with TBasArc(Args[0].p) do
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
      SetError(ERR_OPERATION_FAILED, 'arc_clearcallbacks#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterArcFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin

  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_arc_error; Lib.Add('arc_error@', Fn);
  Fn.Entry := @s_arc_errormsg; Lib.Add('arc_errormsg$@', Fn);
  Fn.Entry := @s_arc_strerror; Lib.Add('arc_strerror$@n', Fn);
  Fn.Entry := @n_arc_clearerror; Lib.Add('arc_clearerror@', Fn);

  // Arc creation/destruction
  Fn.Entry := @p_arc_new; Lib.Add('arc#@#', Fn);
  Fn.Entry := @p_arc_new_size; Lib.Add('arc#@#nn', Fn);
  Fn.Entry := @p_arc_new_full; Lib.Add('arc#@#nnnn', Fn);
  Fn.Entry := @n_arc_free; Lib.Add('arc_free@#', Fn);

  // Arc-specific angle functions
  Fn.Entry := @n_arc_startangle_get; Lib.Add('arc_startangle@#', Fn);
  Fn.Entry := @p_arc_startangle_set; Lib.Add('arc_startangle#@#n', Fn);
  Fn.Entry := @n_arc_endangle_get; Lib.Add('arc_endangle@#', Fn);
  Fn.Entry := @p_arc_endangle_set; Lib.Add('arc_endangle#@#n', Fn);
  Fn.Entry := @p_arc_angles_set; Lib.Add('arc_angles#@#nn', Fn);

  // Fill
  Fn.Entry := @s_arc_fill_get; Lib.Add('arc_fill$@#', Fn);
  Fn.Entry := @p_arc_fill_set; Lib.Add('arc_fill#@#$', Fn);
  Fn.Entry := @p_arc_fillnone; Lib.Add('arc_fillnone#@#', Fn);

  // Stroke
  Fn.Entry := @s_arc_stroke_get; Lib.Add('arc_stroke$@#', Fn);
  Fn.Entry := @p_arc_stroke_set; Lib.Add('arc_stroke#@#$', Fn);
  Fn.Entry := @p_arc_strokenone; Lib.Add('arc_strokenone#@#', Fn);
  Fn.Entry := @n_arc_strokethickness_get; Lib.Add('arc_strokethickness@#', Fn);
  Fn.Entry := @p_arc_strokethickness_set; Lib.Add('arc_strokethickness#@#n', Fn);
  Fn.Entry := @n_arc_strokedash_get; Lib.Add('arc_strokedash@#', Fn);
  Fn.Entry := @p_arc_strokedash_set; Lib.Add('arc_strokedash#@#n', Fn);
  Fn.Entry := @n_arc_strokecap_get; Lib.Add('arc_strokecap@#', Fn);
  Fn.Entry := @p_arc_strokecap_set; Lib.Add('arc_strokecap#@#n', Fn);
  Fn.Entry := @n_arc_strokejoin_get; Lib.Add('arc_strokejoin@#', Fn);
  Fn.Entry := @p_arc_strokejoin_set; Lib.Add('arc_strokejoin#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_arc_x_get; Lib.Add('arc_x@#', Fn);
  Fn.Entry := @p_arc_x_set; Lib.Add('arc_x#@#n', Fn);
  Fn.Entry := @n_arc_y_get; Lib.Add('arc_y@#', Fn);
  Fn.Entry := @p_arc_y_set; Lib.Add('arc_y#@#n', Fn);
  Fn.Entry := @n_arc_width_get; Lib.Add('arc_width@#', Fn);
  Fn.Entry := @p_arc_width_set; Lib.Add('arc_width#@#n', Fn);
  Fn.Entry := @n_arc_height_get; Lib.Add('arc_height@#', Fn);
  Fn.Entry := @p_arc_height_set; Lib.Add('arc_height#@#n', Fn);
  Fn.Entry := @p_arc_bounds_set; Lib.Add('arc_bounds#@#nnnn', Fn);
  Fn.Entry := @p_arc_size_set; Lib.Add('arc_size#@#nn', Fn);
  Fn.Entry := @p_arc_move_set; Lib.Add('arc_move#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_arc_align_get; Lib.Add('arc_align@#', Fn);
  Fn.Entry := @p_arc_align_set; Lib.Add('arc_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_arc_marginleft_get; Lib.Add('arc_marginleft@#', Fn);
  Fn.Entry := @p_arc_marginleft_set; Lib.Add('arc_marginleft#@#n', Fn);
  Fn.Entry := @n_arc_margintop_get; Lib.Add('arc_margintop@#', Fn);
  Fn.Entry := @p_arc_margintop_set; Lib.Add('arc_margintop#@#n', Fn);
  Fn.Entry := @n_arc_marginright_get; Lib.Add('arc_marginright@#', Fn);
  Fn.Entry := @p_arc_marginright_set; Lib.Add('arc_marginright#@#n', Fn);
  Fn.Entry := @n_arc_marginbottom_get; Lib.Add('arc_marginbottom@#', Fn);
  Fn.Entry := @p_arc_marginbottom_set; Lib.Add('arc_marginbottom#@#n', Fn);
  Fn.Entry := @p_arc_margins_set; Lib.Add('arc_margins#@#nnnn', Fn);
  Fn.Entry := @p_arc_margin_set; Lib.Add('arc_margin#@#n', Fn);

  // Visibility and behavior
  Fn.Entry := @n_arc_visible_get; Lib.Add('arc_visible@#', Fn);
  Fn.Entry := @p_arc_visible_set; Lib.Add('arc_visible#@#n', Fn);
  Fn.Entry := @n_arc_enabled_get; Lib.Add('arc_enabled@#', Fn);
  Fn.Entry := @p_arc_enabled_set; Lib.Add('arc_enabled#@#n', Fn);
  Fn.Entry := @n_arc_opacity_get; Lib.Add('arc_opacity@#', Fn);
  Fn.Entry := @p_arc_opacity_set; Lib.Add('arc_opacity#@#n', Fn);
  Fn.Entry := @n_arc_hittest_get; Lib.Add('arc_hittest@#', Fn);
  Fn.Entry := @p_arc_hittest_set; Lib.Add('arc_hittest#@#n', Fn);

  // Tag and rotation
  Fn.Entry := @n_arc_tag_get; Lib.Add('arc_tag@#', Fn);
  Fn.Entry := @p_arc_tag_set; Lib.Add('arc_tag#@#n', Fn);
  Fn.Entry := @n_arc_rotation_get; Lib.Add('arc_rotation@#', Fn);
  Fn.Entry := @p_arc_rotation_set; Lib.Add('arc_rotation#@#n', Fn);

  // Parent
  Fn.Entry := @p_arc_parent_get; Lib.Add('arc_parent#@#', Fn);
  Fn.Entry := @p_arc_parent_set; Lib.Add('arc_parent#@##', Fn);
  Fn.Entry := @p_arc_bringtofront; Lib.Add('arc_bringtofront#@#', Fn);
  Fn.Entry := @p_arc_sendtoback; Lib.Add('arc_sendtoback#@#', Fn);

  // Invalidation
  Fn.Entry := @p_arc_invalidate; Lib.Add('arc_invalidate#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_arc_onclick_set; Lib.Add('arc_onclick#@#$', Fn);
  Fn.Entry := @s_arc_onclick_get; Lib.Add('arc_onclick$@#', Fn);
  Fn.Entry := @p_arc_ondblclick_set; Lib.Add('arc_ondblclick#@#$', Fn);
  Fn.Entry := @s_arc_ondblclick_get; Lib.Add('arc_ondblclick$@#', Fn);
  Fn.Entry := @p_arc_onmousedown_set; Lib.Add('arc_onmousedown#@#$', Fn);
  Fn.Entry := @s_arc_onmousedown_get; Lib.Add('arc_onmousedown$@#', Fn);
  Fn.Entry := @p_arc_onmouseup_set; Lib.Add('arc_onmouseup#@#$', Fn);
  Fn.Entry := @s_arc_onmouseup_get; Lib.Add('arc_onmouseup$@#', Fn);
  Fn.Entry := @p_arc_onmousemove_set; Lib.Add('arc_onmousemove#@#$', Fn);
  Fn.Entry := @s_arc_onmousemove_get; Lib.Add('arc_onmousemove$@#', Fn);
  Fn.Entry := @p_arc_onmouseenter_set; Lib.Add('arc_onmouseenter#@#$', Fn);
  Fn.Entry := @s_arc_onmouseenter_get; Lib.Add('arc_onmouseenter$@#', Fn);
  Fn.Entry := @p_arc_onmouseleave_set; Lib.Add('arc_onmouseleave#@#$', Fn);
  Fn.Entry := @s_arc_onmouseleave_get; Lib.Add('arc_onmouseleave$@#', Fn);
  Fn.Entry := @p_arc_onmousewheel_set; Lib.Add('arc_onmousewheel#@#$', Fn);
  Fn.Entry := @s_arc_onmousewheel_get; Lib.Add('arc_onmousewheel$@#', Fn);
  Fn.Entry := @p_arc_onresize_set; Lib.Add('arc_onresize#@#$', Fn);
  Fn.Entry := @s_arc_onresize_get; Lib.Add('arc_onresize$@#', Fn);
  Fn.Entry := @p_arc_clearcallbacks; Lib.Add('arc_clearcallbacks#@#', Fn);
end;

end.

