unit RectangleLib;

{******************************************************************************
  RectangleLib - Rectangle Visual Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TRectangle wrapper functionality for creating
  and managing rectangle visual controls in Plan9Basic programs. TRectangle
  is the primary visual shape control with fill, stroke, and corner rounding.

  Function Count: 98 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All rectangles are created at RUNTIME using TRectangle.Create with dynamic
  parent assignment. This ensures proper dynamic creation across all platforms.

  FEATURES:
  =========
  - Rectangle creation and lifecycle management
  - Fill color and style (solid, gradient support via color)
  - Stroke (border) color, thickness, and style
  - Corner rounding (XRadius, YRadius)
  - Selective sides and corners
  - Complete positioning and alignment
  - Full event support with BASIC callback integration

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

  SIDES FLAGS (bitmask):
  ======================
  1 = Top
  2 = Left
  4 = Bottom
  8 = Right
  15 = All sides (default)

  CORNERS FLAGS (bitmask):
  ========================
  1 = TopLeft
  2 = TopRight
  4 = BottomLeft
  8 = BottomRight
  15 = All corners (default)

  USAGE PATTERN:
  ==============
    let frm# = form#("Rectangle Demo", 800, 600)

    ' Create a blue rectangle with rounded corners
    let r# = rectangle#(frm#, 50, 50, 200, 100)
    rectangle_fill#(r#, "#3498db")
    rectangle_stroke#(r#, "#2980b9")
    rectangle_strokethickness#(r#, 2)
    rectangle_corners#(r#, 10, 10)

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
  basic, exec, UnitGC, UnitUtils, HandleRegistry;

type
  // Forward declaration
  TBasRectangle = class;

  {****************************************************************************
    TBasRectangle - Extended TRectangle with BASIC event callback support

    Wraps a TRectangle and provides event bridging to Plan9Basic user functions.
    Each event stores the name of a BASIC function to call when triggered.
  ****************************************************************************}
  TBasRectangle = class(TRectangle)
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
procedure RegisterRectangleFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  RECT_GC_TAG = 'BASIC_RECTANGLE';

  // Error codes
  ERR_NONE = 0;
  ERR_INVALID_RECT = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INVALID_CALLBACK = 5;
  ERR_INVALID_COLOR = 6;

  // Alignment constants (matching TAlignLayout)
  ALIGN_NONE = 0;
  ALIGN_TOP = 1;
  ALIGN_LEFT = 2;
  ALIGN_RIGHT = 3;
  ALIGN_BOTTOM = 4;
  ALIGN_MOST_TOP = 5;
  ALIGN_MOST_BOTTOM = 6;
  ALIGN_MOST_LEFT = 7;
  ALIGN_MOST_RIGHT = 8;
  ALIGN_CLIENT = 9;
  ALIGN_CONTENTS = 10;
  ALIGN_CENTER = 11;
  ALIGN_VERT_CENTER = 12;
  ALIGN_HORZ_CENTER = 13;
  ALIGN_HORIZONTAL = 14;
  ALIGN_VERTICAL = 15;
  ALIGN_SCALE = 16;
  ALIGN_FIT = 17;
  ALIGN_FIT_LEFT = 18;
  ALIGN_FIT_RIGHT = 19;

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

  // Sides flags
  SIDE_TOP = 1;
  SIDE_LEFT = 2;
  SIDE_BOTTOM = 4;
  SIDE_RIGHT = 8;
  SIDE_ALL = 15;

  // Corners flags
  CORNER_TOPLEFT = 1;
  CORNER_TOPRIGHT = 2;
  CORNER_BOTTOMLEFT = 4;
  CORNER_BOTTOMRIGHT = 8;
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

function ValidateRect(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_RECT, FuncName + ': Nil rectangle pointer');
    Exit;
  end;

  try
    if not (IsHandleOf(P, TBasRectangle)) then
    begin
      SetError(ERR_INVALID_RECT, FuncName + ': Invalid rectangle object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_RECT, FuncName + ': Invalid rectangle pointer');
    Exit;
  end;

  ClearError();
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': Nil parent pointer');
    Exit;
  end;

  try
    if not (TObject(P) is TFmxObject) then
    begin
      SetError(ERR_INVALID_PARENT, FuncName + ': Invalid parent object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_PARENT, FuncName + ': Invalid parent pointer');
    Exit;
  end;

  ClearError();
  Result := True;
end;

function IntToAlign(Value: Integer): TAlignLayout;
begin
  case Value of
    ALIGN_NONE: Result := TAlignLayout.None;
    ALIGN_TOP: Result := TAlignLayout.Top;
    ALIGN_LEFT: Result := TAlignLayout.Left;
    ALIGN_RIGHT: Result := TAlignLayout.Right;
    ALIGN_BOTTOM: Result := TAlignLayout.Bottom;
    ALIGN_MOST_TOP: Result := TAlignLayout.MostTop;
    ALIGN_MOST_BOTTOM: Result := TAlignLayout.MostBottom;
    ALIGN_MOST_LEFT: Result := TAlignLayout.MostLeft;
    ALIGN_MOST_RIGHT: Result := TAlignLayout.MostRight;
    ALIGN_CLIENT: Result := TAlignLayout.Client;
    ALIGN_CONTENTS: Result := TAlignLayout.Contents;
    ALIGN_CENTER: Result := TAlignLayout.Center;
    ALIGN_VERT_CENTER: Result := TAlignLayout.VertCenter;
    ALIGN_HORZ_CENTER: Result := TAlignLayout.HorzCenter;
    ALIGN_HORIZONTAL: Result := TAlignLayout.Horizontal;
    ALIGN_VERTICAL: Result := TAlignLayout.Vertical;
    ALIGN_SCALE: Result := TAlignLayout.Scale;
    ALIGN_FIT: Result := TAlignLayout.Fit;
    ALIGN_FIT_LEFT: Result := TAlignLayout.FitLeft;
    ALIGN_FIT_RIGHT: Result := TAlignLayout.FitRight;
  else
    Result := TAlignLayout.None;
  end;
end;

function AlignToInt(Value: TAlignLayout): Integer;
begin
  case Value of
    TAlignLayout.None: Result := ALIGN_NONE;
    TAlignLayout.Top: Result := ALIGN_TOP;
    TAlignLayout.Left: Result := ALIGN_LEFT;
    TAlignLayout.Right: Result := ALIGN_RIGHT;
    TAlignLayout.Bottom: Result := ALIGN_BOTTOM;
    TAlignLayout.MostTop: Result := ALIGN_MOST_TOP;
    TAlignLayout.MostBottom: Result := ALIGN_MOST_BOTTOM;
    TAlignLayout.MostLeft: Result := ALIGN_MOST_LEFT;
    TAlignLayout.MostRight: Result := ALIGN_MOST_RIGHT;
    TAlignLayout.Client: Result := ALIGN_CLIENT;
    TAlignLayout.Contents: Result := ALIGN_CONTENTS;
    TAlignLayout.Center: Result := ALIGN_CENTER;
    TAlignLayout.VertCenter: Result := ALIGN_VERT_CENTER;
    TAlignLayout.HorzCenter: Result := ALIGN_HORZ_CENTER;
    TAlignLayout.Horizontal: Result := ALIGN_HORIZONTAL;
    TAlignLayout.Vertical: Result := ALIGN_VERTICAL;
    TAlignLayout.Scale: Result := ALIGN_SCALE;
    TAlignLayout.Fit: Result := ALIGN_FIT;
    TAlignLayout.FitLeft: Result := ALIGN_FIT_LEFT;
    TAlignLayout.FitRight: Result := ALIGN_FIT_RIGHT;
  else
    Result := ALIGN_NONE;
  end;
end;

function BuildShiftString(Shift: TShiftState): String;
begin
  Result := '';
  if ssShift in Shift then Result := Result + 'S';
  if ssCtrl in Shift then Result := Result + 'C';
  if ssAlt in Shift then Result := Result + 'A';
  if ssCommand in Shift then Result := Result + 'M';
  if ssLeft in Shift then Result := Result + 'L';
  if ssRight in Shift then Result := Result + 'R';
  if ssMiddle in Shift then Result := Result + 'X';
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

function IntToSides(Value: Integer): TSides;
begin
  Result := [];
  if (Value and SIDE_TOP) <> 0 then Include(Result, TSide.Top);
  if (Value and SIDE_LEFT) <> 0 then Include(Result, TSide.Left);
  if (Value and SIDE_BOTTOM) <> 0 then Include(Result, TSide.Bottom);
  if (Value and SIDE_RIGHT) <> 0 then Include(Result, TSide.Right);
end;

function SidesToInt(Value: TSides): Integer;
begin
  Result := 0;
  if TSide.Top in Value then Result := Result or SIDE_TOP;
  if TSide.Left in Value then Result := Result or SIDE_LEFT;
  if TSide.Bottom in Value then Result := Result or SIDE_BOTTOM;
  if TSide.Right in Value then Result := Result or SIDE_RIGHT;
end;

function IntToCorners(Value: Integer): TCorners;
begin
  Result := [];
  if (Value and CORNER_TOPLEFT) <> 0 then Include(Result, TCorner.TopLeft);
  if (Value and CORNER_TOPRIGHT) <> 0 then Include(Result, TCorner.TopRight);
  if (Value and CORNER_BOTTOMLEFT) <> 0 then Include(Result, TCorner.BottomLeft);
  if (Value and CORNER_BOTTOMRIGHT) <> 0 then Include(Result, TCorner.BottomRight);
end;

function CornersToInt(Value: TCorners): Integer;
begin
  Result := 0;
  if TCorner.TopLeft in Value then Result := Result or CORNER_TOPLEFT;
  if TCorner.TopRight in Value then Result := Result or CORNER_TOPRIGHT;
  if TCorner.BottomLeft in Value then Result := Result or CORNER_BOTTOMLEFT;
  if TCorner.BottomRight in Value then Result := Result or CORNER_BOTTOMRIGHT;
end;

//==============================================================================
// TBasRectangle Implementation
//==============================================================================

constructor TBasRectangle.Create(AOwner: TComponent);
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

  // Initialize engine references
  FBasicEngine := nil;
  FConsoleOutput := nil;
end;

destructor TBasRectangle.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectEvents();
  inherited Destroy();
end;

procedure TBasRectangle.DisconnectEvents();
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
end;

function TBasRectangle.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

procedure TBasRectangle.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
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
        FConsoleOutput.Add('*** Rectangle Event Callback Error ***');
        FConsoleOutput.Add('Function: ' + FuncSignature);
        FConsoleOutput.Add('Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

function TBasRectangle.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  i: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

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
      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs, RetType, Result);
    except
      on E: Exception do
      begin
        FConsoleOutput.Add('*** Rectangle Event Callback Error ***');
        FConsoleOutput.Add('Function: ' + FuncSignature);
        FConsoleOutput.Add('Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

procedure TBasRectangle.InternalOnClick(Sender: TObject);
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

procedure TBasRectangle.InternalOnDblClick(Sender: TObject);
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

procedure TBasRectangle.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasRectangle.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasRectangle.InternalOnDragLeave(Sender: TObject);
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

procedure TBasRectangle.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
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

procedure TBasRectangle.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasRectangle.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasRectangle.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
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

procedure TBasRectangle.InternalOnMouseEnter(Sender: TObject);
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

procedure TBasRectangle.InternalOnMouseLeave(Sender: TObject);
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

procedure TBasRectangle.InternalOnMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
  RetVal: TAsmData;
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

  RetVal := ExecuteCallbackWithResult(Signature, Args);
  Handled := (RetVal.n <> 0);
end;

procedure TBasRectangle.InternalOnResize(Sender: TObject);
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

procedure TBasRectangle.InternalOnResized(Sender: TObject);
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

procedure TBasRectangle.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    Self.OnClick := InternalOnClick
  else
    Self.OnClick := nil;
end;

procedure TBasRectangle.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    Self.OnDblClick := InternalOnDblClick
  else
    Self.OnDblClick := nil;
end;

procedure TBasRectangle.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    Self.OnDragDrop := InternalOnDragDrop
  else
    Self.OnDragDrop := nil;
end;

procedure TBasRectangle.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    Self.OnDragEnter := InternalOnDragEnter
  else
    Self.OnDragEnter := nil;
end;

procedure TBasRectangle.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    Self.OnDragLeave := InternalOnDragLeave
  else
    Self.OnDragLeave := nil;
end;

procedure TBasRectangle.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    Self.OnDragOver := InternalOnDragOver
  else
    Self.OnDragOver := nil;
end;

procedure TBasRectangle.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    Self.OnMouseDown := InternalOnMouseDown
  else
    Self.OnMouseDown := nil;
end;

procedure TBasRectangle.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    Self.OnMouseEnter := InternalOnMouseEnter
  else
    Self.OnMouseEnter := nil;
end;

procedure TBasRectangle.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    Self.OnMouseLeave := InternalOnMouseLeave
  else
    Self.OnMouseLeave := nil;
end;

procedure TBasRectangle.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    Self.OnMouseMove := InternalOnMouseMove
  else
    Self.OnMouseMove := nil;
end;

procedure TBasRectangle.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    Self.OnMouseUp := InternalOnMouseUp
  else
    Self.OnMouseUp := nil;
end;

procedure TBasRectangle.SetOnMouseWheelFunc(const Value: String);
begin
  FOnMouseWheelFunc := Value;
  if Value <> '' then
    Self.OnMouseWheel := InternalOnMouseWheel
  else
    Self.OnMouseWheel := nil;
end;

procedure TBasRectangle.SetOnPaintFunc(const Value: String);
begin
  FOnPaintFunc := Value;
  if Value <> '' then
    Self.OnPaint := InternalOnPaint
  else
    Self.OnPaint := nil;
end;

procedure TBasRectangle.SetOnResizedFunc(const Value: String);
begin
  FOnResizedFunc := Value;
  if Value <> '' then
    Self.OnResized := InternalOnResized
  else
    Self.OnResized := nil;
end;

procedure TBasRectangle.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    Self.OnResize := InternalOnResize
  else
    Self.OnResize := nil;
end;

procedure TBasRectangle.InternalOnPaint(Sender: TObject; Canvas: TCanvas;
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

//==============================================================================
// Library Functions - Error Handling
//==============================================================================

function n_rect_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

function s_rect_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

function s_rect_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_RECT: Result.s := 'Invalid or nil rectangle';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent control';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Rectangle creation failed';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback function';
    ERR_INVALID_COLOR: Result.s := 'Invalid color value';
  else
    Result.s := 'Unknown error: ' + IntToStr(Code);
  end;
end;

function n_rect_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

//==============================================================================
// Library Functions - Rectangle Creation and Destruction
//==============================================================================

// rect#(parent#) - Create a new rectangle with parent
function p_rect_new(var Args: array of TAsmData): TAsmData;
var
  Rect: TBasRectangle;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'rect#') then Exit();

  try
    ParentObj := TFmxObject(Args[0].p);
    Rect := TBasRectangle.Create(nil);
    Rect.BasicEngine := ModuleEngine;
    Rect.ConsoleOutput := ModuleOutput;
    Rect.Parent := ParentObj;

    // Set sensible defaults
    Rect.Width := 100;
    Rect.Height := 100;
    Rect.Align := TAlignLayout.None;
    Rect.Fill.Color := TAlphaColorRec.White;
    Rect.Stroke.Color := TAlphaColorRec.Black;
    Rect.Stroke.Thickness := 1;

    Result.p := Pointer(Rect);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Rect, RECT_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'rect#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// rect#(parent#, width, height) - Create with size
function p_rect_new_size(var Args: array of TAsmData): TAsmData;
var
  Rect: TBasRectangle;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'rect#') then Exit();

  try
    ParentObj := TFmxObject(Args[0].p);
    Rect := TBasRectangle.Create(nil);
    Rect.BasicEngine := ModuleEngine;
    Rect.ConsoleOutput := ModuleOutput;
    Rect.Parent := ParentObj;

    Rect.Width := Args[1].n;
    Rect.Height := Args[2].n;
    Rect.Align := TAlignLayout.None;
    Rect.Fill.Color := TAlphaColorRec.White;
    Rect.Stroke.Color := TAlphaColorRec.Black;
    Rect.Stroke.Thickness := 1;

    Result.p := Pointer(Rect);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Rect, RECT_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'rect#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// rect#(parent#, x, y, width, height) - Create with position and size
function p_rect_new_full(var Args: array of TAsmData): TAsmData;
var
  Rect: TBasRectangle;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'rect#') then Exit();

  try
    ParentObj := TFmxObject(Args[0].p);
    Rect := TBasRectangle.Create(nil);
    Rect.BasicEngine := ModuleEngine;
    Rect.ConsoleOutput := ModuleOutput;
    Rect.Parent := ParentObj;

    Rect.Position.X := Args[1].n;
    Rect.Position.Y := Args[2].n;
    Rect.Width := Args[3].n;
    Rect.Height := Args[4].n;
    Rect.Align := TAlignLayout.None;
    Rect.Fill.Color := TAlphaColorRec.White;
    Rect.Stroke.Color := TAlphaColorRec.Black;
    Rect.Stroke.Thickness := 1;

    Result.p := Pointer(Rect);
    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Rect, RECT_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'rect#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// rect_free(rect#) - Free a rectangle
function n_rect_free(var Args: array of TAsmData): TAsmData;
var
  Rect: TBasRectangle;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_free') then Exit();

  try
    Rect := TBasRectangle(Args[0].p);
    Rect.DisconnectEvents;
    Rect.Free();

    // Use GC to properly free the control
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(RECT_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_RECT, 'rect_free: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Fill (Background)
//==============================================================================

// rect_fill$(rect#) - Get fill color
function s_rect_fill_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_fill$') then Exit();

  try
    Result.s := TUtils.AlphaColorToStr(TBasRectangle(Args[0].p).Fill.Color);
  except
  end;
end;

// rect_fill#(rect#, color$) - Set fill color
function p_rect_fill_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_fill#') then Exit();

  try
    TBasRectangle(Args[0].p).Fill.Color := TUtils.ColorToAlphaColor(Args[1].s);
    TBasRectangle(Args[0].p).Fill.Kind := TBrushKind.Solid;
  except
  end;
end;

// rect_fillnone#(rect#) - Set fill to none (transparent)
function p_rect_fillnone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_fillnone#') then Exit();

  try
    TBasRectangle(Args[0].p).Fill.Kind := TBrushKind.None;
  except
  end;
end;

//==============================================================================
// Library Functions - Stroke (Border)
//==============================================================================

// rect_stroke$(rect#) - Get stroke color
function s_rect_stroke_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_stroke$') then Exit();

  try
    Result.s := TUtils.AlphaColorToStr(TBasRectangle(Args[0].p).Stroke.Color);
  except
  end;
end;

// rect_stroke#(rect#, color$) - Set stroke color
function p_rect_stroke_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_stroke#') then Exit();

  try
    TBasRectangle(Args[0].p).Stroke.Color := TUtils.ColorToAlphaColor(Args[1].s);
    TBasRectangle(Args[0].p).Stroke.Kind := TBrushKind.Solid;
  except
  end;
end;

// rect_strokenone#(rect#) - Set stroke to none
function p_rect_strokenone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_strokenone#') then Exit();

  try
    TBasRectangle(Args[0].p).Stroke.Kind := TBrushKind.None;
  except
  end;
end;

// rect_strokethickness(rect#) - Get stroke thickness
function n_rect_strokethickness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_strokethickness') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).Stroke.Thickness;
  except
  end;
end;

// rect_strokethickness#(rect#, value) - Set stroke thickness
function p_rect_strokethickness_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_strokethickness#') then Exit();

  try
    TBasRectangle(Args[0].p).Stroke.Thickness := Args[1].n;
  except
  end;
end;

// rect_strokedash(rect#) - Get stroke dash style
function n_rect_strokedash_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_strokedash') then Exit();

  try
    Result.n := StrokeDashToInt(TBasRectangle(Args[0].p).Stroke.Dash);
  except
  end;
end;

// rect_strokedash#(rect#, value) - Set stroke dash style
function p_rect_strokedash_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_strokedash#') then Exit();

  try
    TBasRectangle(Args[0].p).Stroke.Dash := IntToStrokeDash(Trunc(Args[1].n));
  except
  end;
end;

// rect_strokecap(rect#) - Get stroke cap style
function n_rect_strokecap_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_strokecap') then Exit();

  try
    Result.n := StrokeCapToInt(TBasRectangle(Args[0].p).Stroke.Cap);
  except
  end;
end;

// rect_strokecap#(rect#, value) - Set stroke cap style
function p_rect_strokecap_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_strokecap#') then Exit();

  try
    TBasRectangle(Args[0].p).Stroke.Cap := IntToStrokeCap(Trunc(Args[1].n));
  except
  end;
end;

// rect_strokejoin(rect#) - Get stroke join style
function n_rect_strokejoin_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_strokejoin') then Exit();

  try
    Result.n := StrokeJoinToInt(TBasRectangle(Args[0].p).Stroke.Join);
  except
  end;
end;

// rect_strokejoin#(rect#, value) - Set stroke join style
function p_rect_strokejoin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_strokejoin#') then Exit();

  try
    TBasRectangle(Args[0].p).Stroke.Join := IntToStrokeJoin(Trunc(Args[1].n));
  except
  end;
end;

//==============================================================================
// Library Functions - Corner Radius
//==============================================================================

// rect_xradius(rect#) - Get X radius
function n_rect_xradius_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_xradius') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).XRadius;
  except
  end;
end;

// rect_xradius#(rect#, value) - Set X radius
function p_rect_xradius_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_xradius#') then Exit();

  try
    TBasRectangle(Args[0].p).XRadius := Args[1].n;
  except
  end;
end;

// rect_yradius(rect#) - Get Y radius
function n_rect_yradius_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_yradius') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).YRadius;
  except
  end;
end;

// rect_yradius#(rect#, value) - Set Y radius
function p_rect_yradius_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_yradius#') then Exit();

  try
    TBasRectangle(Args[0].p).YRadius := Args[1].n;
  except
  end;
end;

// rect_corners#(rect#, xradius, yradius) - Set both radii at once
function p_rect_corners_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_corners#') then Exit();

  try
    TBasRectangle(Args[0].p).XRadius := Args[1].n;
    TBasRectangle(Args[0].p).YRadius := Args[2].n;
  except
  end;
end;

//==============================================================================
// Library Functions - Sides and Corners Selection
//==============================================================================

// rect_sides(rect#) - Get sides flags
function n_rect_sides_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_sides') then Exit();

  try
    Result.n := SidesToInt(TBasRectangle(Args[0].p).Sides);
  except
  end;
end;

// rect_sides#(rect#, value) - Set sides flags
function p_rect_sides_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_sides#') then Exit();

  try
    TBasRectangle(Args[0].p).Sides := IntToSides(Trunc(Args[1].n));
  except
  end;
end;

// rect_cornersflags(rect#) - Get corners flags
function n_rect_cornersflags_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_cornersflags') then Exit();

  try
    Result.n := CornersToInt(TBasRectangle(Args[0].p).Corners);
  except
  end;
end;

// rect_cornersflags#(rect#, value) - Set corners flags
function p_rect_cornersflags_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_cornersflags#') then Exit();

  try
    TBasRectangle(Args[0].p).Corners := IntToCorners(Trunc(Args[1].n));
  except
  end;
end;

//==============================================================================
// Library Functions - Position and Size
//==============================================================================

// rect_x(rect#) - Get X position
function n_rect_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_x') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).Position.X;
  except
  end;
end;

// rect_x#(rect#, value) - Set X position
function p_rect_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_x#') then Exit();

  try
    TBasRectangle(Args[0].p).Position.X := Args[1].n;
  except
  end;
end;

// rect_y(rect#) - Get Y position
function n_rect_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_y') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).Position.Y;
  except
  end;
end;

// rect_y#(rect#, value) - Set Y position
function p_rect_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_y#') then Exit();

  try
    TBasRectangle(Args[0].p).Position.Y := Args[1].n;
  except
  end;
end;

// rect_width(rect#) - Get width
function n_rect_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_width') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).Width;
  except
  end;
end;

// rect_width#(rect#, value) - Set width
function p_rect_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_width#') then Exit();

  try
    TBasRectangle(Args[0].p).Width := Args[1].n;
  except
  end;
end;

// rect_height(rect#) - Get height
function n_rect_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_height') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).Height;
  except
  end;
end;

// rect_height#(rect#, value) - Set height
function p_rect_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_height#') then Exit();

  try
    TBasRectangle(Args[0].p).Height := Args[1].n;
  except
  end;
end;

// rect_bounds#(rect#, x, y, width, height) - Set all bounds at once
function p_rect_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_bounds#') then Exit();

  try
    TBasRectangle(Args[0].p).SetBounds(Args[1].n, Args[2].n, Args[3].n, Args[4].n);
  except
  end;
end;

// rect_size#(rect#, width, height) - Set size
function p_rect_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_size#') then Exit();

  try
    TBasRectangle(Args[0].p).Width := Args[1].n;
    TBasRectangle(Args[0].p).Height := Args[2].n;
  except
  end;
end;

// rect_move#(rect#, x, y) - Set position
function p_rect_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_move#') then Exit();

  try
    TBasRectangle(Args[0].p).Position.X := Args[1].n;
    TBasRectangle(Args[0].p).Position.Y := Args[2].n;
  except
  end;
end;

//==============================================================================
// Library Functions - Alignment
//==============================================================================

// rect_align(rect#) - Get alignment
function n_rect_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_align') then Exit();

  try
    Result.n := AlignToInt(TBasRectangle(Args[0].p).Align);
  except
  end;
end;

// rect_align#(rect#, value) - Set alignment
function p_rect_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_align#') then Exit();

  try
    TBasRectangle(Args[0].p).Align := IntToAlign(Trunc(Args[1].n));
  except
  end;
end;

//==============================================================================
// Library Functions - Margins
//==============================================================================

// rect_marginleft(rect#) - Get left margin
function n_rect_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_marginleft') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).Margins.Left;
  except
  end;
end;

// rect_marginleft#(rect#, value) - Set left margin
function p_rect_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_marginleft#') then Exit();

  try
    TBasRectangle(Args[0].p).Margins.Left := Args[1].n;
  except
  end;
end;

// rect_margintop(rect#) - Get top margin
function n_rect_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_margintop') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).Margins.Top;
  except
  end;
end;

// rect_margintop#(rect#, value) - Set top margin
function p_rect_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_margintop#') then Exit();

  try
    TBasRectangle(Args[0].p).Margins.Top := Args[1].n;
  except
  end;
end;

// rect_marginright(rect#) - Get right margin
function n_rect_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_marginright') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).Margins.Right;
  except
  end;
end;

// rect_marginright#(rect#, value) - Set right margin
function p_rect_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_marginright#') then Exit();

  try
    TBasRectangle(Args[0].p).Margins.Right := Args[1].n;
  except
  end;
end;

// rect_marginbottom(rect#) - Get bottom margin
function n_rect_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_marginbottom') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).Margins.Bottom;
  except
  end;
end;

// rect_marginbottom#(rect#, value) - Set bottom margin
function p_rect_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_marginbottom#') then Exit();

  try
    TBasRectangle(Args[0].p).Margins.Bottom := Args[1].n;
  except
  end;
end;

// rect_margins#(rect#, left, top, right, bottom) - Set all margins
function p_rect_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_margins#') then Exit();

  try
    with TBasRectangle(Args[0].p).Margins do
    begin
      Left := Args[1].n;
      Top := Args[2].n;
      Right := Args[3].n;
      Bottom := Args[4].n;
    end;
  except
  end;
end;

// rect_margin#(rect#, value) - Set uniform margin
function p_rect_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_margin#') then Exit();

  try
    with TBasRectangle(Args[0].p).Margins do
    begin
      Left := Args[1].n;
      Top := Args[1].n;
      Right := Args[1].n;
      Bottom := Args[1].n;
    end;
  except
  end;
end;

//==============================================================================
// Library Functions - Visibility and Behavior
//==============================================================================

// rect_visible(rect#) - Get visible
function n_rect_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_visible') then Exit();

  try
    if TBasRectangle(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// rect_visible#(rect#, value) - Set visible
function p_rect_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_visible#') then Exit();

  try
    TBasRectangle(Args[0].p).Visible := (Args[1].n <> 0);
  except
  end;
end;

// rect_enabled(rect#) - Get enabled
function n_rect_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_enabled') then Exit();

  try
    if TBasRectangle(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// rect_enabled#(rect#, value) - Set enabled
function p_rect_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_enabled#') then Exit();

  try
    TBasRectangle(Args[0].p).Enabled := (Args[1].n <> 0);
  except
  end;
end;

// rect_opacity(rect#) - Get opacity (0.0-1.0)
function n_rect_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_opacity') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).Opacity;
  except
  end;
end;

// rect_opacity#(rect#, value) - Set opacity (0.0-1.0)
function p_rect_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_opacity#') then Exit();

  try
    TBasRectangle(Args[0].p).Opacity := Args[1].n;
  except
  end;
end;

// rect_hittest(rect#) - Get hit test
function n_rect_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_hittest') then Exit();

  try
    if TBasRectangle(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// rect_hittest#(rect#, value) - Set hit test
function p_rect_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_hittest#') then Exit();

  try
    TBasRectangle(Args[0].p).HitTest := (Args[1].n <> 0);
  except
  end;
end;

//==============================================================================
// Library Functions - Tag and Rotation
//==============================================================================

// rect_tag(rect#) - Get tag
function n_rect_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_tag') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).Tag;
  except
  end;
end;

// rect_tag#(rect#, value) - Set tag
function p_rect_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_tag#') then Exit();

  try
    TBasRectangle(Args[0].p).Tag := Trunc(Args[1].n);
  except
  end;
end;

// rect_rotation(rect#) - Get rotation angle
function n_rect_rotation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_rotation') then Exit();

  try
    Result.n := TBasRectangle(Args[0].p).RotationAngle;
  except
  end;
end;

// rect_rotation#(rect#, value) - Set rotation angle
function p_rect_rotation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_rotation#') then Exit();

  try
    TBasRectangle(Args[0].p).RotationAngle := Args[1].n;
  except
  end;
end;

//==============================================================================
// Library Functions - Parent
//==============================================================================

// rect_parent#(rect#) - Get parent
function p_rect_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_parent#') then Exit();

  try
    Result.p := Pointer(TBasRectangle(Args[0].p).Parent);
  except
  end;
end;

// rect_parent#(rect#, parent#) - Set parent
function p_rect_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_parent#') then Exit();
  if not ValidateParent(Args[1].p, 'rect_parent#') then Exit();

  try
    TBasRectangle(Args[0].p).Parent := TFmxObject(Args[1].p);
  except
  end;
end;

// rect_bringtofront#(rect#) - Bring to front
function p_rect_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_bringtofront#') then Exit();

  try
    TBasRectangle(Args[0].p).BringToFront;
  except
  end;
end;

// rect_sendtoback#(rect#) - Send to back
function p_rect_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_sendtoback#') then Exit();

  try
    TBasRectangle(Args[0].p).SendToBack;
  except
  end;
end;

//==============================================================================
// Library Functions - Invalidation
//==============================================================================

// rect_invalidate#(rect#) - Invalidate rectangle for repaint
function p_rect_invalidate(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateRect(Args[0].p, 'rect_invalidate#') then Exit();

  try
    TBasRectangle(Args[0].p).Repaint;
  except
  end;
end;

//==============================================================================
// Library Functions - Event Callbacks
//==============================================================================

function p_rect_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onclick#') then Exit();
  try
    TBasRectangle(Args[0].p).OnClickFunc := Args[1].s;
  except
  end;
end;

function s_rect_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onclick$') then Exit();
  try
    Result.s := TBasRectangle(Args[0].p).OnClickFunc;
  except
  end;
end;

function p_rect_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_ondblclick#') then Exit();
  try
    TBasRectangle(Args[0].p).OnDblClickFunc := Args[1].s;
  except
  end;
end;

function s_rect_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_ondblclick$') then Exit();
  try
    Result.s := TBasRectangle(Args[0].p).OnDblClickFunc;
  except
  end;
end;

function p_rect_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onmousedown#') then Exit();
  try
    TBasRectangle(Args[0].p).OnMouseDownFunc := Args[1].s;
  except
  end;
end;

function s_rect_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onmousedown$') then Exit();
  try
    Result.s := TBasRectangle(Args[0].p).OnMouseDownFunc;
  except
  end;
end;

function p_rect_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onmouseup#') then Exit();
  try
    TBasRectangle(Args[0].p).OnMouseUpFunc := Args[1].s;
  except
  end;
end;

function s_rect_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onmouseup$') then Exit();
  try
    Result.s := TBasRectangle(Args[0].p).OnMouseUpFunc;
  except
  end;
end;

function p_rect_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onmousemove#') then Exit();
  try
    TBasRectangle(Args[0].p).OnMouseMoveFunc := Args[1].s;
  except
  end;
end;

function s_rect_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onmousemove$') then Exit();
  try
    Result.s := TBasRectangle(Args[0].p).OnMouseMoveFunc;
  except
  end;
end;

function p_rect_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onmouseenter#') then Exit();
  try
    TBasRectangle(Args[0].p).OnMouseEnterFunc := Args[1].s;
  except
  end;
end;

function s_rect_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onmouseenter$') then Exit();
  try
    Result.s := TBasRectangle(Args[0].p).OnMouseEnterFunc;
  except
  end;
end;

function p_rect_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onmouseleave#') then Exit();
  try
    TBasRectangle(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  except
  end;
end;

function s_rect_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onmouseleave$') then Exit();
  try
    Result.s := TBasRectangle(Args[0].p).OnMouseLeaveFunc;
  except
  end;
end;

function p_rect_onmousewheel_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onmousewheel#') then Exit();
  try
    TBasRectangle(Args[0].p).OnMouseWheelFunc := Args[1].s;
  except
  end;
end;

function s_rect_onmousewheel_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onmousewheel$') then Exit();
  try
    Result.s := TBasRectangle(Args[0].p).OnMouseWheelFunc;
  except
  end;
end;

function p_rect_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onresize#') then Exit();
  try
    TBasRectangle(Args[0].p).OnResizeFunc := Args[1].s;
  except
  end;
end;

function s_rect_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_onresize$') then Exit();
  try
    Result.s := TBasRectangle(Args[0].p).OnResizeFunc;
  except
  end;
end;

function p_rect_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateRect(Args[0].p, 'rect_clearcallbacks#') then Exit();
  try
    with TBasRectangle(Args[0].p) do
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
    end;
  except
  end;
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterRectangleFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;

  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_rect_error; Lib.Add('rectangle_error@', Fn);
  Fn.Entry := @s_rect_errormsg; Lib.Add('rectangle_errormsg$@', Fn);
  Fn.Entry := @s_rect_strerror; Lib.Add('rectangle_strerror$@n', Fn);
  Fn.Entry := @n_rect_clearerror; Lib.Add('rectangle_clearerror@', Fn);

  // Rectangle creation/destruction
  Fn.Entry := @p_rect_new; Lib.Add('rectangle#@#', Fn);
  Fn.Entry := @p_rect_new_size; Lib.Add('rectangle#@#nn', Fn);
  Fn.Entry := @p_rect_new_full; Lib.Add('rectangle#@#nnnn', Fn);
  Fn.Entry := @n_rect_free; Lib.Add('rectangle_free@#', Fn);

  // Fill
  Fn.Entry := @s_rect_fill_get; Lib.Add('rectangle_fill$@#', Fn);
  Fn.Entry := @p_rect_fill_set; Lib.Add('rectangle_fill#@#$', Fn);
  Fn.Entry := @p_rect_fillnone; Lib.Add('rectangle_fillnone#@#', Fn);

  // Stroke
  Fn.Entry := @s_rect_stroke_get; Lib.Add('rectangle_stroke$@#', Fn);
  Fn.Entry := @p_rect_stroke_set; Lib.Add('rectangle_stroke#@#$', Fn);
  Fn.Entry := @p_rect_strokenone; Lib.Add('rectangle_strokenone#@#', Fn);
  Fn.Entry := @n_rect_strokethickness_get; Lib.Add('rectangle_strokethickness@#', Fn);
  Fn.Entry := @p_rect_strokethickness_set; Lib.Add('rectangle_strokethickness#@#n', Fn);
  Fn.Entry := @n_rect_strokedash_get; Lib.Add('rectangle_strokedash@#', Fn);
  Fn.Entry := @p_rect_strokedash_set; Lib.Add('rectangle_strokedash#@#n', Fn);
  Fn.Entry := @n_rect_strokecap_get; Lib.Add('rectangle_strokecap@#', Fn);
  Fn.Entry := @p_rect_strokecap_set; Lib.Add('rectangle_strokecap#@#n', Fn);
  Fn.Entry := @n_rect_strokejoin_get; Lib.Add('rectangle_strokejoin@#', Fn);
  Fn.Entry := @p_rect_strokejoin_set; Lib.Add('rectangle_strokejoin#@#n', Fn);

  // Corner radius
  Fn.Entry := @n_rect_xradius_get; Lib.Add('rectangle_xradius@#', Fn);
  Fn.Entry := @p_rect_xradius_set; Lib.Add('rectangle_xradius#@#n', Fn);
  Fn.Entry := @n_rect_yradius_get; Lib.Add('rectangle_yradius@#', Fn);
  Fn.Entry := @p_rect_yradius_set; Lib.Add('rectangle_yradius#@#n', Fn);
  Fn.Entry := @p_rect_corners_set; Lib.Add('rectangle_corners#@#nn', Fn);

  // Sides and corners flags
  Fn.Entry := @n_rect_sides_get; Lib.Add('rectangle_sides@#', Fn);
  Fn.Entry := @p_rect_sides_set; Lib.Add('rectangle_sides#@#n', Fn);
  Fn.Entry := @n_rect_cornersflags_get; Lib.Add('rectangle_cornersflags@#', Fn);
  Fn.Entry := @p_rect_cornersflags_set; Lib.Add('rectangle_cornersflags#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_rect_x_get; Lib.Add('rectangle_x@#', Fn);
  Fn.Entry := @p_rect_x_set; Lib.Add('rectangle_x#@#n', Fn);
  Fn.Entry := @n_rect_y_get; Lib.Add('rectangle_y@#', Fn);
  Fn.Entry := @p_rect_y_set; Lib.Add('rectangle_y#@#n', Fn);
  Fn.Entry := @n_rect_width_get; Lib.Add('rectangle_width@#', Fn);
  Fn.Entry := @p_rect_width_set; Lib.Add('rectangle_width#@#n', Fn);
  Fn.Entry := @n_rect_height_get; Lib.Add('rectangle_height@#', Fn);
  Fn.Entry := @p_rect_height_set; Lib.Add('rectangle_height#@#n', Fn);
  Fn.Entry := @p_rect_bounds_set; Lib.Add('rectangle_bounds#@#nnnn', Fn);
  Fn.Entry := @p_rect_size_set; Lib.Add('rectangle_size#@#nn', Fn);
  Fn.Entry := @p_rect_move_set; Lib.Add('rectangle_move#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_rect_align_get; Lib.Add('rectangle_align@#', Fn);
  Fn.Entry := @p_rect_align_set; Lib.Add('rectangle_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_rect_marginleft_get; Lib.Add('rectangle_marginleft@#', Fn);
  Fn.Entry := @p_rect_marginleft_set; Lib.Add('rectangle_marginleft#@#n', Fn);
  Fn.Entry := @n_rect_margintop_get; Lib.Add('rectangle_margintop@#', Fn);
  Fn.Entry := @p_rect_margintop_set; Lib.Add('rectangle_margintop#@#n', Fn);
  Fn.Entry := @n_rect_marginright_get; Lib.Add('rectangle_marginright@#', Fn);
  Fn.Entry := @p_rect_marginright_set; Lib.Add('rectangle_marginright#@#n', Fn);
  Fn.Entry := @n_rect_marginbottom_get; Lib.Add('rectangle_marginbottom@#', Fn);
  Fn.Entry := @p_rect_marginbottom_set; Lib.Add('rectangle_marginbottom#@#n', Fn);
  Fn.Entry := @p_rect_margins_set; Lib.Add('rectangle_margins#@#nnnn', Fn);
  Fn.Entry := @p_rect_margin_set; Lib.Add('rectangle_margin#@#n', Fn);

  // Visibility and behavior
  Fn.Entry := @n_rect_visible_get; Lib.Add('rectangle_visible@#', Fn);
  Fn.Entry := @p_rect_visible_set; Lib.Add('rectangle_visible#@#n', Fn);
  Fn.Entry := @n_rect_enabled_get; Lib.Add('rectangle_enabled@#', Fn);
  Fn.Entry := @p_rect_enabled_set; Lib.Add('rectangle_enabled#@#n', Fn);
  Fn.Entry := @n_rect_opacity_get; Lib.Add('rectangle_opacity@#', Fn);
  Fn.Entry := @p_rect_opacity_set; Lib.Add('rectangle_opacity#@#n', Fn);
  Fn.Entry := @n_rect_hittest_get; Lib.Add('rectangle_hittest@#', Fn);
  Fn.Entry := @p_rect_hittest_set; Lib.Add('rectangle_hittest#@#n', Fn);

  // Tag and rotation
  Fn.Entry := @n_rect_tag_get; Lib.Add('rectangle_tag@#', Fn);
  Fn.Entry := @p_rect_tag_set; Lib.Add('rectangle_tag#@#n', Fn);
  Fn.Entry := @n_rect_rotation_get; Lib.Add('rectangle_rotation@#', Fn);
  Fn.Entry := @p_rect_rotation_set; Lib.Add('rectangle_rotation#@#n', Fn);

  // Parent
  Fn.Entry := @p_rect_parent_get; Lib.Add('rectangle_parent#@#', Fn);
  Fn.Entry := @p_rect_parent_set; Lib.Add('rectangle_parent#@##', Fn);
  Fn.Entry := @p_rect_bringtofront; Lib.Add('rectangle_bringtofront#@#', Fn);
  Fn.Entry := @p_rect_sendtoback; Lib.Add('rectangle_sendtoback#@#', Fn);

  // Invalidation
  Fn.Entry := @p_rect_invalidate; Lib.Add('rectangle_invalidate#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_rect_onclick_set; Lib.Add('rectangle_onclick#@#$', Fn);
  Fn.Entry := @s_rect_onclick_get; Lib.Add('rectangle_onclick$@#', Fn);
  Fn.Entry := @p_rect_ondblclick_set; Lib.Add('rectangle_ondblclick#@#$', Fn);
  Fn.Entry := @s_rect_ondblclick_get; Lib.Add('rectangle_ondblclick$@#', Fn);
  Fn.Entry := @p_rect_onmousedown_set; Lib.Add('rectangle_onmousedown#@#$', Fn);
  Fn.Entry := @s_rect_onmousedown_get; Lib.Add('rectangle_onmousedown$@#', Fn);
  Fn.Entry := @p_rect_onmouseup_set; Lib.Add('rectangle_onmouseup#@#$', Fn);
  Fn.Entry := @s_rect_onmouseup_get; Lib.Add('rectangle_onmouseup$@#', Fn);
  Fn.Entry := @p_rect_onmousemove_set; Lib.Add('rectangle_onmousemove#@#$', Fn);
  Fn.Entry := @s_rect_onmousemove_get; Lib.Add('rectangle_onmousemove$@#', Fn);
  Fn.Entry := @p_rect_onmouseenter_set; Lib.Add('rectangle_onmouseenter#@#$', Fn);
  Fn.Entry := @s_rect_onmouseenter_get; Lib.Add('rectangle_onmouseenter$@#', Fn);
  Fn.Entry := @p_rect_onmouseleave_set; Lib.Add('rectangle_onmouseleave#@#$', Fn);
  Fn.Entry := @s_rect_onmouseleave_get; Lib.Add('rectangle_onmouseleave$@#', Fn);
  Fn.Entry := @p_rect_onmousewheel_set; Lib.Add('rectangle_onmousewheel#@#$', Fn);
  Fn.Entry := @s_rect_onmousewheel_get; Lib.Add('rectangle_onmousewheel$@#', Fn);
  Fn.Entry := @p_rect_onresize_set; Lib.Add('rectangle_onresize#@#$', Fn);
  Fn.Entry := @s_rect_onresize_get; Lib.Add('rectangle_onresize$@#', Fn);
  Fn.Entry := @p_rect_clearcallbacks; Lib.Add('rectangle_clearcallbacks#@#', Fn);
end;

end.

