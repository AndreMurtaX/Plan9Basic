unit RoundRectLib;

{******************************************************************************
  RoundRectLib - Rounded Rectangle Visual Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TRoundRect wrapper functionality for creating
  and managing rounded rectangle visual controls in Plan9Basic programs.
  TRoundRect is a visual shape control with fill, stroke, and fixed rounded
  corners.

  Function Count: 73 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All rounded rectangles are created at RUNTIME using TRoundRect.Create with
  dynamic parent assignment. This ensures proper dynamic creation across all
  platforms.

  FEATURES:
  =========
  - Rounded rectangle creation and lifecycle management
  - Selective corner rounding (choose which corners are rounded)
  - Fill color and style (solid, gradient support via color)
  - Stroke (border) color, thickness, and style
  - Complete positioning and alignment
  - Full event support with BASIC callback integration

  NOTE: TRoundRect has a fixed corner radius (not adjustable like TRectangle).
  Use roundrect_corners#() to select which corners are rounded.
  For adjustable corner radius, use RectangleLib with rect_xradius#/rect_yradius#.

  EVENTS SUPPORT:
  ===============
  - OnClick: Rectangle was clicked
  - OnDblClick: Rectangle was double-clicked
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over rectangle
  - OnMouseEnter: Mouse entered rectangle area
  - OnMouseLeave: Mouse left rectangle area
  - OnMouseWheel: Mouse wheel scrolled
  - OnResize: Rectangle is being resized
  - OnResized: Rectangle resize completed
  - OnPaint: Rectangle needs repainting

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

  CORNER FLAGS:
  =============
  Combine these values to select which corners are rounded:
  1 = Top-Left
  2 = Top-Right
  4 = Bottom-Left
  8 = Bottom-Right
  15 = All corners (default)

  USAGE PATTERN:
  ==============
    let frm# = form#("RoundRect Demo", 800, 600)

    ' Create a blue rounded rectangle
    let rr# = roundrect#(frm#, 50, 50, 200, 100)
    roundrect_fill#(rr#, "#3498db")
    roundrect_stroke#(rr#, "#2980b9")
    roundrect_strokethickness#(rr#, 2)

    ' Only round top corners (1 + 2 = 3)
    roundrect_corners#(rr#, 3)

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnRectClick(sender#)
      println "Rectangle clicked!"
    endfunction

    function OnRectMouseMove(sender#, x, y, shift$)
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
  TBasRoundRect = class;

  {****************************************************************************
    TBasRoundRect - Extended TRoundRect with BASIC event callback support

    Wraps a TRoundRect and provides event bridging to Plan9Basic user functions.
    Each event stores the name of a BASIC function to call when triggered.

    NOTE: TRoundRect has fixed corner radius (not adjustable like TRectangle).
    Use the Corners property to select which corners are rounded.
  ****************************************************************************}
  TBasRoundRect = class(TRoundRect)
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
    //function ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;

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
procedure RegisterRoundRectFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  ROUNDRECT_GC_TAG = 'BASIC_ROUNDRECT';

  // Error codes
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_ROUNDRECT = 1;
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

  // Corner flags
  CORNER_TOP_LEFT = 1;
  CORNER_TOP_RIGHT = 2;
  CORNER_BOTTOM_LEFT = 4;
  CORNER_BOTTOM_RIGHT = 8;
  CORNER_ALL = 15;

var
  lastError: Integer;
  lastErrorMsg: String;

  // Module-level references for event callback support
  ModuleEngine: TBasicEngine;
  ModuleOutput: TStrings;

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

function ValidateRoundRect(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_ROUNDRECT, FuncName + ': Nil roundrect pointer');
    Exit;
  end;

  try
    if not (IsHandleOf(P, TBasRoundRect)) then
    begin
      SetError(ERR_INVALID_ROUNDRECT, FuncName + ': Invalid roundrect object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_ROUNDRECT, FuncName + ': Invalid roundrect pointer');
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

function IntToCorners(Value: Integer): TCorners;
begin
  Result := [];
  if (Value and CORNER_TOP_LEFT) <> 0 then
    Result := Result + [TCorner.TopLeft];
  if (Value and CORNER_TOP_RIGHT) <> 0 then
    Result := Result + [TCorner.TopRight];
  if (Value and CORNER_BOTTOM_LEFT) <> 0 then
    Result := Result + [TCorner.BottomLeft];
  if (Value and CORNER_BOTTOM_RIGHT) <> 0 then
    Result := Result + [TCorner.BottomRight];
end;

function CornersToInt(Value: TCorners): Integer;
begin
  Result := 0;
  if TCorner.TopLeft in Value then
    Result := Result or CORNER_TOP_LEFT;
  if TCorner.TopRight in Value then
    Result := Result or CORNER_TOP_RIGHT;
  if TCorner.BottomLeft in Value then
    Result := Result or CORNER_BOTTOM_LEFT;
  if TCorner.BottomRight in Value then
    Result := Result or CORNER_BOTTOM_RIGHT;
end;

//==============================================================================
// TBasRoundRect Implementation
//==============================================================================

constructor TBasRoundRect.Create(AOwner: TComponent);
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

destructor TBasRoundRect.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectEvents();
  inherited Destroy();
end;

procedure TBasRoundRect.DisconnectEvents();
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

function TBasRoundRect.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

procedure TBasRoundRect.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  RetVal: TAsmData;
  i: Integer;
begin
  // Prevent reentrant callback execution
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
      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs, RetType, RetVal);
    except
      on E: Exception do
      begin
        FConsoleOutput.Add('*** RoundRect Event Callback Error ***');
        FConsoleOutput.Add('Function: ' + FuncSignature);
        FConsoleOutput.Add('Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

//function TBasRoundRect.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
//var
//  CallArgs: array of TAsmData;
//  RetType: TExprKind;
//  i: Integer;
//begin
//  Result.n := 0;
//  Result.p := nil;
//  Result.s := '';
//
//  // Prevent reentrant callback execution
//  if UnitGC.GlobalCallbackBusy then Exit();
//
//  if not Assigned(FBasicEngine) then Exit();
//  if not Assigned(FConsoleOutput) then Exit();
//  if FuncSignature = '' then Exit();
//
//  UnitGC.GlobalCallbackBusy := True;
//  UnitGC.SkipProcessMessages := True;
//  try
//    SetLength(CallArgs, Length(Args));
//    for i := 0 to High(Args) do
//      CallArgs[i] := Args[i];
//
//    try
//      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs, RetType, Result);
//    except
//      on E: Exception do
//      begin
//        FConsoleOutput.Add('*** RoundRect Event Callback Error ***');
//        FConsoleOutput.Add('Function: ' + FuncSignature);
//        FConsoleOutput.Add('Error: ' + E.Message);
//      end;
//    end;
//  finally
//    UnitGC.SkipProcessMessages := False;
//    UnitGC.GlobalCallbackBusy := False;
//  end;
//end;

procedure TBasRoundRect.InternalOnClick(Sender: TObject);
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

procedure TBasRoundRect.InternalOnDblClick(Sender: TObject);
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

procedure TBasRoundRect.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasRoundRect.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasRoundRect.InternalOnDragLeave(Sender: TObject);
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

procedure TBasRoundRect.InternalOnDragOver(Sender: TObject; const Data: TDragObject;
  const Point: TPointF; var Operation: TDragOperation);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnDragOverFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nn (sender#, x, y)
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

  ExecuteCallback(Signature, Args);
end;

procedure TBasRoundRect.InternalOnMouseDown(Sender: TObject; Button: TMouseButton;
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

procedure TBasRoundRect.InternalOnMouseUp(Sender: TObject; Button: TMouseButton;
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

procedure TBasRoundRect.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
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

procedure TBasRoundRect.InternalOnMouseEnter(Sender: TObject);
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

procedure TBasRoundRect.InternalOnMouseLeave(Sender: TObject);
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

procedure TBasRoundRect.InternalOnMouseWheel(Sender: TObject; Shift: TShiftState;
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

procedure TBasRoundRect.InternalOnResize(Sender: TObject);
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

procedure TBasRoundRect.InternalOnResized(Sender: TObject);
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

procedure TBasRoundRect.InternalOnPaint(Sender: TObject; Canvas: TCanvas;
  const ARect: TRectF);
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

procedure TBasRoundRect.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    Self.OnClick := InternalOnClick
  else
    Self.OnClick := nil;
end;

procedure TBasRoundRect.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    Self.OnDblClick := InternalOnDblClick
  else
    Self.OnDblClick := nil;
end;

procedure TBasRoundRect.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    Self.OnDragDrop := InternalOnDragDrop
  else
    Self.OnDragDrop := nil;
end;

procedure TBasRoundRect.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    Self.OnDragEnter := InternalOnDragEnter
  else
    Self.OnDragEnter := nil;
end;

procedure TBasRoundRect.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    Self.OnDragLeave := InternalOnDragLeave
  else
    Self.OnDragLeave := nil;
end;

procedure TBasRoundRect.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    Self.OnDragOver := InternalOnDragOver
  else
    Self.OnDragOver := nil;
end;

procedure TBasRoundRect.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    Self.OnMouseDown := InternalOnMouseDown
  else
    Self.OnMouseDown := nil;
end;

procedure TBasRoundRect.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    Self.OnMouseUp := InternalOnMouseUp
  else
    Self.OnMouseUp := nil;
end;

procedure TBasRoundRect.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    Self.OnMouseMove := InternalOnMouseMove
  else
    Self.OnMouseMove := nil;
end;

procedure TBasRoundRect.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    Self.OnMouseEnter := InternalOnMouseEnter
  else
    Self.OnMouseEnter := nil;
end;

procedure TBasRoundRect.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    Self.OnMouseLeave := InternalOnMouseLeave
  else
    Self.OnMouseLeave := nil;
end;

procedure TBasRoundRect.SetOnMouseWheelFunc(const Value: String);
begin
  FOnMouseWheelFunc := Value;
  if Value <> '' then
    Self.OnMouseWheel := InternalOnMouseWheel
  else
    Self.OnMouseWheel := nil;
end;

procedure TBasRoundRect.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    Self.OnResize := InternalOnResize
  else
    Self.OnResize := nil;
end;

procedure TBasRoundRect.SetOnResizedFunc(const Value: String);
begin
  FOnResizedFunc := Value;
  if Value <> '' then
    Self.OnResized := InternalOnResized
  else
    Self.OnResized := nil;
end;

procedure TBasRoundRect.SetOnPaintFunc(const Value: String);
begin
  FOnPaintFunc := Value;
  if Value <> '' then
    Self.OnPainting := InternalOnPaint
  else
    Self.OnPainting := nil;
end;

//==============================================================================
// Error Handling Functions
//==============================================================================

// roundrect_error@ - Get last error code
function n_roundrect_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

// roundrect_errormsg$@ - Get last error message
function s_roundrect_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

// roundrect_strerror$@n - Get error description by code
function s_roundrect_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Trunc(Args[0].n) of
    ERR_NONE:            Result.s := 'No error';
    ERR_INVALID_ROUNDRECT:  Result.s := 'Invalid roundrect';
    ERR_INVALID_PARENT:  Result.s := 'Invalid parent';
    ERR_INVALID_VALUE:   Result.s := 'Invalid value';
    ERR_CREATE_FAILED:   Result.s := 'Creation failed';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback';
    ERR_INVALID_COLOR:   Result.s := 'Invalid color';
  else
    Result.s := 'Unknown error';
  end;
end;

// roundrect_clearerror@ - Clear last error
function n_roundrect_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

//==============================================================================
// RoundRect Creation/Destruction Functions
//==============================================================================

// roundrect#@# - Create roundrect with parent only
function p_roundrect_new(var Args: array of TAsmData): TAsmData;
var
  RoundRect: TBasRoundRect;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'roundrect#') then Exit;

  try
    RoundRect := TBasRoundRect.Create(nil);
    RoundRect.Parent := TFmxObject(Args[0].p);
    RoundRect.BasicEngine := ModuleEngine;
    RoundRect.ConsoleOutput := ModuleOutput;
    RoundRect.HitTest := True;  // Enable mouse events by default

    Result.p := Pointer(RoundRect);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(RoundRect, ROUNDRECT_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'roundrect#: ' + E.Message);
    end;
  end;
end;

// roundrect#@#nn - Create roundrect with parent and size (width, height)
function p_roundrect_new_size(var Args: array of TAsmData): TAsmData;
var
  RoundRect: TBasRoundRect;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'roundrect#') then Exit;

  try
    RoundRect := TBasRoundRect.Create(nil);
    RoundRect.Parent := TFmxObject(Args[0].p);
    RoundRect.Width := Args[1].n;
    RoundRect.Height := Args[2].n;
    RoundRect.BasicEngine := ModuleEngine;
    RoundRect.ConsoleOutput := ModuleOutput;
    RoundRect.HitTest := True;

    Result.p := Pointer(RoundRect);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(RoundRect, ROUNDRECT_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'roundrect#: ' + E.Message);
    end;
  end;
end;

// roundrect#@#nnnn - Create roundrect with parent, position, and size
function p_roundrect_new_full(var Args: array of TAsmData): TAsmData;
var
  RoundRect: TBasRoundRect;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'roundrect#') then Exit;

  try
    RoundRect := TBasRoundRect.Create(nil);
    RoundRect.Parent := TFmxObject(Args[0].p);
    RoundRect.Position.X := Args[1].n;
    RoundRect.Position.Y := Args[2].n;
    RoundRect.Width := Args[3].n;
    RoundRect.Height := Args[4].n;
    RoundRect.BasicEngine := ModuleEngine;
    RoundRect.ConsoleOutput := ModuleOutput;
    RoundRect.HitTest := True;

    Result.p := Pointer(RoundRect);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(RoundRect, ROUNDRECT_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'roundrect#: ' + E.Message);
    end;
  end;
end;

// roundrect_free@# - Explicitly free a roundrect
function n_roundrect_free(var Args: array of TAsmData): TAsmData;
var
  RoundRect: TBasRoundRect;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRoundRect(Args[0].p, 'roundrect_free') then Exit;

  try
    RoundRect := TBasRoundRect(Args[0].p);
    RoundRect.DisconnectEvents();
    RoundRect.Free();

    // Use GC to properly free the control
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(ROUNDRECT_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_INVALID_ROUNDRECT, 'roundrect_free: ' + E.Message);
    end;
  end;
end;

//==============================================================================
// Corner Selection Functions
//==============================================================================

// roundrect_corners@# - Get which corners are rounded (bitmask)
function n_roundrect_corners_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_corners') then Exit;
  try
    Result.n := CornersToInt(TBasRoundRect(Args[0].p).Corners);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_corners: ' + E.Message);
  end;
end;

// roundrect_corners#@#n - Set which corners are rounded (bitmask)
function p_roundrect_corners_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_corners#') then Exit;
  try
    TBasRoundRect(Args[0].p).Corners := IntToCorners(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_corners#: ' + E.Message);
  end;
end;

//==============================================================================
// Fill Functions
//==============================================================================

// roundrect_fill$@# - Get fill color
function s_roundrect_fill_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_fill$') then Exit;
  try
    Result.s := TUtils.AlphaColorToStr(TBasRoundRect(Args[0].p).Fill.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_fill$: ' + E.Message);
  end;
end;

// roundrect_fill#@#$ - Set fill color
function p_roundrect_fill_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_fill#') then Exit;
  try
    TBasRoundRect(Args[0].p).Fill.Color := TUtils.ColorToAlphaColor(Args[1].s);
    TBasRoundRect(Args[0].p).Fill.Kind := TBrushKind.Solid;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_fill#: ' + E.Message);
  end;
end;

// roundrect_fillnone#@# - Set fill to none (transparent)
function p_roundrect_fillnone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_fillnone#') then Exit;
  try
    TBasRoundRect(Args[0].p).Fill.Kind := TBrushKind.None;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_fillnone#: ' + E.Message);
  end;
end;

//==============================================================================
// Stroke Functions
//==============================================================================

// roundrect_stroke$@# - Get stroke color
function s_roundrect_stroke_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_stroke$') then Exit;
  try
    Result.s := TUtils.AlphaColorToStr(TBasRoundRect(Args[0].p).Stroke.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_stroke$: ' + E.Message);
  end;
end;

// roundrect_stroke#@#$ - Set stroke color
function p_roundrect_stroke_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_stroke#') then Exit;
  try
    TBasRoundRect(Args[0].p).Stroke.Color := TUtils.ColorToAlphaColor(Args[1].s);
    TBasRoundRect(Args[0].p).Stroke.Kind := TBrushKind.Solid;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_stroke#: ' + E.Message);
  end;
end;

// roundrect_strokenone#@# - Set stroke to none
function p_roundrect_strokenone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_strokenone#') then Exit;
  try
    TBasRoundRect(Args[0].p).Stroke.Kind := TBrushKind.None;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_strokenone#: ' + E.Message);
  end;
end;

// roundrect_strokethickness@# - Get stroke thickness
function n_roundrect_strokethickness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_strokethickness') then Exit;
  try
    Result.n := TBasRoundRect(Args[0].p).Stroke.Thickness;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_strokethickness: ' + E.Message);
  end;
end;

// roundrect_strokethickness#@#n - Set stroke thickness
function p_roundrect_strokethickness_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_strokethickness#') then Exit;
  try
    TBasRoundRect(Args[0].p).Stroke.Thickness := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_strokethickness#: ' + E.Message);
  end;
end;

// roundrect_strokedash@# - Get stroke dash style
function n_roundrect_strokedash_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_strokedash') then Exit;
  try
    Result.n := StrokeDashToInt(TBasRoundRect(Args[0].p).Stroke.Dash);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_strokedash: ' + E.Message);
  end;
end;

// roundrect_strokedash#@#n - Set stroke dash style
function p_roundrect_strokedash_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_strokedash#') then Exit;
  try
    TBasRoundRect(Args[0].p).Stroke.Dash := IntToStrokeDash(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_strokedash#: ' + E.Message);
  end;
end;

// roundrect_strokecap@# - Get stroke cap style
function n_roundrect_strokecap_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_strokecap') then Exit;
  try
    Result.n := StrokeCapToInt(TBasRoundRect(Args[0].p).Stroke.Cap);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_strokecap: ' + E.Message);
  end;
end;

// roundrect_strokecap#@#n - Set stroke cap style
function p_roundrect_strokecap_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_strokecap#') then Exit;
  try
    TBasRoundRect(Args[0].p).Stroke.Cap := IntToStrokeCap(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_strokecap#: ' + E.Message);
  end;
end;

// roundrect_strokejoin@# - Get stroke join style
function n_roundrect_strokejoin_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_strokejoin') then Exit;
  try
    Result.n := StrokeJoinToInt(TBasRoundRect(Args[0].p).Stroke.Join);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_strokejoin: ' + E.Message);
  end;
end;

// roundrect_strokejoin#@#n - Set stroke join style
function p_roundrect_strokejoin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_strokejoin#') then Exit;
  try
    TBasRoundRect(Args[0].p).Stroke.Join := IntToStrokeJoin(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_strokejoin#: ' + E.Message);
  end;
end;

//==============================================================================
// Position and Size Functions
//==============================================================================

// roundrect_x@# - Get X position
function n_roundrect_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_x') then Exit;
  try
    Result.n := TBasRoundRect(Args[0].p).Position.X;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_x: ' + E.Message);
  end;
end;

// roundrect_x#@#n - Set X position
function p_roundrect_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_x#') then Exit;
  try
    TBasRoundRect(Args[0].p).Position.X := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_x#: ' + E.Message);
  end;
end;

// roundrect_y@# - Get Y position
function n_roundrect_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_y') then Exit;
  try
    Result.n := TBasRoundRect(Args[0].p).Position.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_y: ' + E.Message);
  end;
end;

// roundrect_y#@#n - Set Y position
function p_roundrect_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_y#') then Exit;
  try
    TBasRoundRect(Args[0].p).Position.Y := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_y#: ' + E.Message);
  end;
end;

// roundrect_width@# - Get width
function n_roundrect_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_width') then Exit;
  try
    Result.n := TBasRoundRect(Args[0].p).Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_width: ' + E.Message);
  end;
end;

// roundrect_width#@#n - Set width
function p_roundrect_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_width#') then Exit;
  try
    TBasRoundRect(Args[0].p).Width := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_width#: ' + E.Message);
  end;
end;

// roundrect_height@# - Get height
function n_roundrect_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_height') then Exit;
  try
    Result.n := TBasRoundRect(Args[0].p).Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_height: ' + E.Message);
  end;
end;

// roundrect_height#@#n - Set height
function p_roundrect_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_height#') then Exit;
  try
    TBasRoundRect(Args[0].p).Height := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_height#: ' + E.Message);
  end;
end;

// roundrect_bounds#@#nnnn - Set position and size at once
function p_roundrect_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_bounds#') then Exit;
  try
    TBasRoundRect(Args[0].p).Position.X := Args[1].n;
    TBasRoundRect(Args[0].p).Position.Y := Args[2].n;
    TBasRoundRect(Args[0].p).Width := Args[3].n;
    TBasRoundRect(Args[0].p).Height := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_bounds#: ' + E.Message);
  end;
end;

// roundrect_size#@#nn - Set width and height
function p_roundrect_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_size#') then Exit;
  try
    TBasRoundRect(Args[0].p).Width := Args[1].n;
    TBasRoundRect(Args[0].p).Height := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_size#: ' + E.Message);
  end;
end;

// roundrect_move#@#nn - Set X and Y position
function p_roundrect_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_move#') then Exit;
  try
    TBasRoundRect(Args[0].p).Position.X := Args[1].n;
    TBasRoundRect(Args[0].p).Position.Y := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_move#: ' + E.Message);
  end;
end;

//==============================================================================
// Alignment Functions
//==============================================================================

// roundrect_align@# - Get alignment
function n_roundrect_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_align') then Exit;
  try
    Result.n := AlignToInt(TBasRoundRect(Args[0].p).Align);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_align: ' + E.Message);
  end;
end;

// roundrect_align#@#n - Set alignment
function p_roundrect_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_align#') then Exit;
  try
    TBasRoundRect(Args[0].p).Align := AlignFromInt(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_align#: ' + E.Message);
  end;
end;

//==============================================================================
// Margin Functions
//==============================================================================

// roundrect_marginleft@# - Get left margin
function n_roundrect_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_marginleft') then Exit;
  try
    Result.n := TBasRoundRect(Args[0].p).Margins.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_marginleft: ' + E.Message);
  end;
end;

// roundrect_marginleft#@#n - Set left margin
function p_roundrect_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_marginleft#') then Exit;
  try
    TBasRoundRect(Args[0].p).Margins.Left := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_marginleft#: ' + E.Message);
  end;
end;

// roundrect_margintop@# - Get top margin
function n_roundrect_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_margintop') then Exit;
  try
    Result.n := TBasRoundRect(Args[0].p).Margins.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_margintop: ' + E.Message);
  end;
end;

// roundrect_margintop#@#n - Set top margin
function p_roundrect_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_margintop#') then Exit;
  try
    TBasRoundRect(Args[0].p).Margins.Top := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_margintop#: ' + E.Message);
  end;
end;

// roundrect_marginright@# - Get right margin
function n_roundrect_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_marginright') then Exit;
  try
    Result.n := TBasRoundRect(Args[0].p).Margins.Right;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_marginright: ' + E.Message);
  end;
end;

// roundrect_marginright#@#n - Set right margin
function p_roundrect_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_marginright#') then Exit;
  try
    TBasRoundRect(Args[0].p).Margins.Right := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_marginright#: ' + E.Message);
  end;
end;

// roundrect_marginbottom@# - Get bottom margin
function n_roundrect_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_marginbottom') then Exit;
  try
    Result.n := TBasRoundRect(Args[0].p).Margins.Bottom;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_marginbottom: ' + E.Message);
  end;
end;

// roundrect_marginbottom#@#n - Set bottom margin
function p_roundrect_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_marginbottom#') then Exit;
  try
    TBasRoundRect(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_marginbottom#: ' + E.Message);
  end;
end;

// roundrect_margins#@#nnnn - Set all margins
function p_roundrect_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_margins#') then Exit;
  try
    TBasRoundRect(Args[0].p).Margins.Left := Args[1].n;
    TBasRoundRect(Args[0].p).Margins.Top := Args[2].n;
    TBasRoundRect(Args[0].p).Margins.Right := Args[3].n;
    TBasRoundRect(Args[0].p).Margins.Bottom := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_margins#: ' + E.Message);
  end;
end;

// roundrect_margin#@#n - Set uniform margin
function p_roundrect_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_margin#') then Exit;
  try
    TBasRoundRect(Args[0].p).Margins.Left := Args[1].n;
    TBasRoundRect(Args[0].p).Margins.Top := Args[1].n;
    TBasRoundRect(Args[0].p).Margins.Right := Args[1].n;
    TBasRoundRect(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_margin#: ' + E.Message);
  end;
end;

//==============================================================================
// Visibility and Behavior Functions
//==============================================================================

// roundrect_visible@# - Get visibility
function n_roundrect_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_visible') then Exit;
  try
    if TBasRoundRect(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_visible: ' + E.Message);
  end;
end;

// roundrect_visible#@#n - Set visibility
function p_roundrect_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_visible#') then Exit;
  try
    TBasRoundRect(Args[0].p).Visible := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_visible#: ' + E.Message);
  end;
end;

// roundrect_enabled@# - Get enabled state
function n_roundrect_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_enabled') then Exit;
  try
    if TBasRoundRect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_enabled: ' + E.Message);
  end;
end;

// roundrect_enabled#@#n - Set enabled state
function p_roundrect_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_enabled#') then Exit;
  try
    TBasRoundRect(Args[0].p).Enabled := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_enabled#: ' + E.Message);
  end;
end;

// roundrect_opacity@# - Get opacity
function n_roundrect_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_opacity') then Exit;
  try
    Result.n := TBasRoundRect(Args[0].p).Opacity;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_opacity: ' + E.Message);
  end;
end;

// roundrect_opacity#@#n - Set opacity
function p_roundrect_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_opacity#') then Exit;
  try
    TBasRoundRect(Args[0].p).Opacity := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_opacity#: ' + E.Message);
  end;
end;

// roundrect_hittest@# - Get hit test state
function n_roundrect_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_hittest') then Exit;
  try
    if TBasRoundRect(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_hittest: ' + E.Message);
  end;
end;

// roundrect_hittest#@#n - Set hit test state
function p_roundrect_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_hittest#') then Exit;
  try
    TBasRoundRect(Args[0].p).HitTest := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_hittest#: ' + E.Message);
  end;
end;

//==============================================================================
// Tag and Rotation Functions
//==============================================================================

// roundrect_tag@# - Get tag value
function n_roundrect_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_tag') then Exit;
  try
    Result.n := TBasRoundRect(Args[0].p).Tag;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_tag: ' + E.Message);
  end;
end;

// roundrect_tag#@#n - Set tag value
function p_roundrect_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_tag#') then Exit;
  try
    TBasRoundRect(Args[0].p).Tag := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_tag#: ' + E.Message);
  end;
end;

// roundrect_rotation@# - Get rotation angle
function n_roundrect_rotation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_rotation') then Exit;
  try
    Result.n := TBasRoundRect(Args[0].p).RotationAngle;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_rotation: ' + E.Message);
  end;
end;

// roundrect_rotation#@#n - Set rotation angle
function p_roundrect_rotation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_rotation#') then Exit;
  try
    TBasRoundRect(Args[0].p).RotationAngle := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_rotation#: ' + E.Message);
  end;
end;

//==============================================================================
// Parent Control Functions
//==============================================================================

// roundrect_parent#@# - Get parent
function p_roundrect_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_parent#') then Exit;
  try
    Result.p := TBasRoundRect(Args[0].p).Parent;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_parent#: ' + E.Message);
  end;
end;

// roundrect_parent#@## - Set parent
function p_roundrect_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_parent#') then Exit;
  if not ValidateParent(Args[1].p, 'roundrect_parent#') then Exit;
  try
    TBasRoundRect(Args[0].p).Parent := TFmxObject(Args[1].p);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_parent#: ' + E.Message);
  end;
end;

// roundrect_bringtofront#@# - Bring to front
function p_roundrect_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_bringtofront#') then Exit;
  try
    TBasRoundRect(Args[0].p).BringToFront;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_bringtofront#: ' + E.Message);
  end;
end;

// roundrect_sendtoback#@# - Send to back
function p_roundrect_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_sendtoback#') then Exit;
  try
    TBasRoundRect(Args[0].p).SendToBack;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_sendtoback#: ' + E.Message);
  end;
end;

// roundrect_invalidate#@# - Force repaint
function p_roundrect_invalidate(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_invalidate#') then Exit;
  try
    TBasRoundRect(Args[0].p).InvalidateRect(TBasRoundRect(Args[0].p).LocalRect);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_invalidate#: ' + E.Message);
  end;
end;

//==============================================================================
// Event Callback Functions
//==============================================================================

// roundrect_onclick#@#$ - Set onclick callback
function p_roundrect_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onclick#') then Exit;
  try
    TBasRoundRect(Args[0].p).OnClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onclick#: ' + E.Message);
  end;
end;

// roundrect_onclick$@# - Get onclick callback name
function s_roundrect_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onclick$') then Exit;
  try
    Result.s := TBasRoundRect(Args[0].p).OnClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onclick$: ' + E.Message);
  end;
end;

// roundrect_ondblclick#@#$ - Set ondblclick callback
function p_roundrect_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_ondblclick#') then Exit;
  try
    TBasRoundRect(Args[0].p).OnDblClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_ondblclick#: ' + E.Message);
  end;
end;

// roundrect_ondblclick$@# - Get ondblclick callback name
function s_roundrect_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_ondblclick$') then Exit;
  try
    Result.s := TBasRoundRect(Args[0].p).OnDblClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_ondblclick$: ' + E.Message);
  end;
end;

// roundrect_onmousedown#@#$ - Set onmousedown callback
function p_roundrect_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onmousedown#') then Exit;
  try
    TBasRoundRect(Args[0].p).OnMouseDownFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onmousedown#: ' + E.Message);
  end;
end;

// roundrect_onmousedown$@# - Get onmousedown callback name
function s_roundrect_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onmousedown$') then Exit;
  try
    Result.s := TBasRoundRect(Args[0].p).OnMouseDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onmousedown$: ' + E.Message);
  end;
end;

// roundrect_onmouseup#@#$ - Set onmouseup callback
function p_roundrect_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onmouseup#') then Exit;
  try
    TBasRoundRect(Args[0].p).OnMouseUpFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onmouseup#: ' + E.Message);
  end;
end;

// roundrect_onmouseup$@# - Get onmouseup callback name
function s_roundrect_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onmouseup$') then Exit;
  try
    Result.s := TBasRoundRect(Args[0].p).OnMouseUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onmouseup$: ' + E.Message);
  end;
end;

// roundrect_onmousemove#@#$ - Set onmousemove callback
function p_roundrect_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onmousemove#') then Exit;
  try
    TBasRoundRect(Args[0].p).OnMouseMoveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onmousemove#: ' + E.Message);
  end;
end;

// roundrect_onmousemove$@# - Get onmousemove callback name
function s_roundrect_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onmousemove$') then Exit;
  try
    Result.s := TBasRoundRect(Args[0].p).OnMouseMoveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onmousemove$: ' + E.Message);
  end;
end;

// roundrect_onmouseenter#@#$ - Set onmouseenter callback
function p_roundrect_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onmouseenter#') then Exit;
  try
    TBasRoundRect(Args[0].p).OnMouseEnterFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onmouseenter#: ' + E.Message);
  end;
end;

// roundrect_onmouseenter$@# - Get onmouseenter callback name
function s_roundrect_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onmouseenter$') then Exit;
  try
    Result.s := TBasRoundRect(Args[0].p).OnMouseEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onmouseenter$: ' + E.Message);
  end;
end;

// roundrect_onmouseleave#@#$ - Set onmouseleave callback
function p_roundrect_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onmouseleave#') then Exit;
  try
    TBasRoundRect(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onmouseleave#: ' + E.Message);
  end;
end;

// roundrect_onmouseleave$@# - Get onmouseleave callback name
function s_roundrect_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onmouseleave$') then Exit;
  try
    Result.s := TBasRoundRect(Args[0].p).OnMouseLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onmouseleave$: ' + E.Message);
  end;
end;

// roundrect_onmousewheel#@#$ - Set onmousewheel callback
function p_roundrect_onmousewheel_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onmousewheel#') then Exit;
  try
    TBasRoundRect(Args[0].p).OnMouseWheelFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onmousewheel#: ' + E.Message);
  end;
end;

// roundrect_onmousewheel$@# - Get onmousewheel callback name
function s_roundrect_onmousewheel_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onmousewheel$') then Exit;
  try
    Result.s := TBasRoundRect(Args[0].p).OnMouseWheelFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onmousewheel$: ' + E.Message);
  end;
end;

// roundrect_onresize#@#$ - Set onresize callback
function p_roundrect_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onresize#') then Exit;
  try
    TBasRoundRect(Args[0].p).OnResizeFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onresize#: ' + E.Message);
  end;
end;

// roundrect_onresize$@# - Get onresize callback name
function s_roundrect_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRoundRect(Args[0].p, 'roundrect_onresize$') then Exit;
  try
    Result.s := TBasRoundRect(Args[0].p).OnResizeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'roundrect_onresize$: ' + E.Message);
  end;
end;

// roundrect_clearcallbacks#@# - Clear all callbacks
function p_roundrect_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRoundRect(Args[0].p, 'roundrect_clearcallbacks#') then Exit;

  try
    with TBasRoundRect(Args[0].p) do
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
      SetError(ERR_OPERATION_FAILED, 'roundrect_clearcallbacks#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterRoundRectFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;

  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_roundrect_error; Lib.Add('roundrect_error@', Fn);
  Fn.Entry := @s_roundrect_errormsg; Lib.Add('roundrect_errormsg$@', Fn);
  Fn.Entry := @s_roundrect_strerror; Lib.Add('roundrect_strerror$@n', Fn);
  Fn.Entry := @n_roundrect_clearerror; Lib.Add('roundrect_clearerror@', Fn);

  // RoundRect creation/destruction
  Fn.Entry := @p_roundrect_new; Lib.Add('roundrect#@#', Fn);
  Fn.Entry := @p_roundrect_new_size; Lib.Add('roundrect#@#nn', Fn);
  Fn.Entry := @p_roundrect_new_full; Lib.Add('roundrect#@#nnnn', Fn);
  Fn.Entry := @n_roundrect_free; Lib.Add('roundrect_free@#', Fn);

  // Corner selection
  Fn.Entry := @n_roundrect_corners_get; Lib.Add('roundrect_corners@#', Fn);
  Fn.Entry := @p_roundrect_corners_set; Lib.Add('roundrect_corners#@#n', Fn);

  // Fill
  Fn.Entry := @s_roundrect_fill_get; Lib.Add('roundrect_fill$@#', Fn);
  Fn.Entry := @p_roundrect_fill_set; Lib.Add('roundrect_fill#@#$', Fn);
  Fn.Entry := @p_roundrect_fillnone; Lib.Add('roundrect_fillnone#@#', Fn);

  // Stroke
  Fn.Entry := @s_roundrect_stroke_get; Lib.Add('roundrect_stroke$@#', Fn);
  Fn.Entry := @p_roundrect_stroke_set; Lib.Add('roundrect_stroke#@#$', Fn);
  Fn.Entry := @p_roundrect_strokenone; Lib.Add('roundrect_strokenone#@#', Fn);
  Fn.Entry := @n_roundrect_strokethickness_get; Lib.Add('roundrect_strokethickness@#', Fn);
  Fn.Entry := @p_roundrect_strokethickness_set; Lib.Add('roundrect_strokethickness#@#n', Fn);
  Fn.Entry := @n_roundrect_strokedash_get; Lib.Add('roundrect_strokedash@#', Fn);
  Fn.Entry := @p_roundrect_strokedash_set; Lib.Add('roundrect_strokedash#@#n', Fn);
  Fn.Entry := @n_roundrect_strokecap_get; Lib.Add('roundrect_strokecap@#', Fn);
  Fn.Entry := @p_roundrect_strokecap_set; Lib.Add('roundrect_strokecap#@#n', Fn);
  Fn.Entry := @n_roundrect_strokejoin_get; Lib.Add('roundrect_strokejoin@#', Fn);
  Fn.Entry := @p_roundrect_strokejoin_set; Lib.Add('roundrect_strokejoin#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_roundrect_x_get; Lib.Add('roundrect_x@#', Fn);
  Fn.Entry := @p_roundrect_x_set; Lib.Add('roundrect_x#@#n', Fn);
  Fn.Entry := @n_roundrect_y_get; Lib.Add('roundrect_y@#', Fn);
  Fn.Entry := @p_roundrect_y_set; Lib.Add('roundrect_y#@#n', Fn);
  Fn.Entry := @n_roundrect_width_get; Lib.Add('roundrect_width@#', Fn);
  Fn.Entry := @p_roundrect_width_set; Lib.Add('roundrect_width#@#n', Fn);
  Fn.Entry := @n_roundrect_height_get; Lib.Add('roundrect_height@#', Fn);
  Fn.Entry := @p_roundrect_height_set; Lib.Add('roundrect_height#@#n', Fn);
  Fn.Entry := @p_roundrect_bounds_set; Lib.Add('roundrect_bounds#@#nnnn', Fn);
  Fn.Entry := @p_roundrect_size_set; Lib.Add('roundrect_size#@#nn', Fn);
  Fn.Entry := @p_roundrect_move_set; Lib.Add('roundrect_move#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_roundrect_align_get; Lib.Add('roundrect_align@#', Fn);
  Fn.Entry := @p_roundrect_align_set; Lib.Add('roundrect_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_roundrect_marginleft_get; Lib.Add('roundrect_marginleft@#', Fn);
  Fn.Entry := @p_roundrect_marginleft_set; Lib.Add('roundrect_marginleft#@#n', Fn);
  Fn.Entry := @n_roundrect_margintop_get; Lib.Add('roundrect_margintop@#', Fn);
  Fn.Entry := @p_roundrect_margintop_set; Lib.Add('roundrect_margintop#@#n', Fn);
  Fn.Entry := @n_roundrect_marginright_get; Lib.Add('roundrect_marginright@#', Fn);
  Fn.Entry := @p_roundrect_marginright_set; Lib.Add('roundrect_marginright#@#n', Fn);
  Fn.Entry := @n_roundrect_marginbottom_get; Lib.Add('roundrect_marginbottom@#', Fn);
  Fn.Entry := @p_roundrect_marginbottom_set; Lib.Add('roundrect_marginbottom#@#n', Fn);
  Fn.Entry := @p_roundrect_margins_set; Lib.Add('roundrect_margins#@#nnnn', Fn);
  Fn.Entry := @p_roundrect_margin_set; Lib.Add('roundrect_margin#@#n', Fn);

  // Visibility and behavior
  Fn.Entry := @n_roundrect_visible_get; Lib.Add('roundrect_visible@#', Fn);
  Fn.Entry := @p_roundrect_visible_set; Lib.Add('roundrect_visible#@#n', Fn);
  Fn.Entry := @n_roundrect_enabled_get; Lib.Add('roundrect_enabled@#', Fn);
  Fn.Entry := @p_roundrect_enabled_set; Lib.Add('roundrect_enabled#@#n', Fn);
  Fn.Entry := @n_roundrect_opacity_get; Lib.Add('roundrect_opacity@#', Fn);
  Fn.Entry := @p_roundrect_opacity_set; Lib.Add('roundrect_opacity#@#n', Fn);
  Fn.Entry := @n_roundrect_hittest_get; Lib.Add('roundrect_hittest@#', Fn);
  Fn.Entry := @p_roundrect_hittest_set; Lib.Add('roundrect_hittest#@#n', Fn);

  // Tag and rotation
  Fn.Entry := @n_roundrect_tag_get; Lib.Add('roundrect_tag@#', Fn);
  Fn.Entry := @p_roundrect_tag_set; Lib.Add('roundrect_tag#@#n', Fn);
  Fn.Entry := @n_roundrect_rotation_get; Lib.Add('roundrect_rotation@#', Fn);
  Fn.Entry := @p_roundrect_rotation_set; Lib.Add('roundrect_rotation#@#n', Fn);

  // Parent
  Fn.Entry := @p_roundrect_parent_get; Lib.Add('roundrect_parent#@#', Fn);
  Fn.Entry := @p_roundrect_parent_set; Lib.Add('roundrect_parent#@##', Fn);
  Fn.Entry := @p_roundrect_bringtofront; Lib.Add('roundrect_bringtofront#@#', Fn);
  Fn.Entry := @p_roundrect_sendtoback; Lib.Add('roundrect_sendtoback#@#', Fn);

  // Invalidation
  Fn.Entry := @p_roundrect_invalidate; Lib.Add('roundrect_invalidate#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_roundrect_onclick_set; Lib.Add('roundrect_onclick#@#$', Fn);
  Fn.Entry := @s_roundrect_onclick_get; Lib.Add('roundrect_onclick$@#', Fn);
  Fn.Entry := @p_roundrect_ondblclick_set; Lib.Add('roundrect_ondblclick#@#$', Fn);
  Fn.Entry := @s_roundrect_ondblclick_get; Lib.Add('roundrect_ondblclick$@#', Fn);
  Fn.Entry := @p_roundrect_onmousedown_set; Lib.Add('roundrect_onmousedown#@#$', Fn);
  Fn.Entry := @s_roundrect_onmousedown_get; Lib.Add('roundrect_onmousedown$@#', Fn);
  Fn.Entry := @p_roundrect_onmouseup_set; Lib.Add('roundrect_onmouseup#@#$', Fn);
  Fn.Entry := @s_roundrect_onmouseup_get; Lib.Add('roundrect_onmouseup$@#', Fn);
  Fn.Entry := @p_roundrect_onmousemove_set; Lib.Add('roundrect_onmousemove#@#$', Fn);
  Fn.Entry := @s_roundrect_onmousemove_get; Lib.Add('roundrect_onmousemove$@#', Fn);
  Fn.Entry := @p_roundrect_onmouseenter_set; Lib.Add('roundrect_onmouseenter#@#$', Fn);
  Fn.Entry := @s_roundrect_onmouseenter_get; Lib.Add('roundrect_onmouseenter$@#', Fn);
  Fn.Entry := @p_roundrect_onmouseleave_set; Lib.Add('roundrect_onmouseleave#@#$', Fn);
  Fn.Entry := @s_roundrect_onmouseleave_get; Lib.Add('roundrect_onmouseleave$@#', Fn);
  Fn.Entry := @p_roundrect_onmousewheel_set; Lib.Add('roundrect_onmousewheel#@#$', Fn);
  Fn.Entry := @s_roundrect_onmousewheel_get; Lib.Add('roundrect_onmousewheel$@#', Fn);
  Fn.Entry := @p_roundrect_onresize_set; Lib.Add('roundrect_onresize#@#$', Fn);
  Fn.Entry := @s_roundrect_onresize_get; Lib.Add('roundrect_onresize$@#', Fn);
  Fn.Entry := @p_roundrect_clearcallbacks; Lib.Add('roundrect_clearcallbacks#@#', Fn);
end;

end.

