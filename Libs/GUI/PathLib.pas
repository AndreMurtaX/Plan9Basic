unit PathLib;

{******************************************************************************
  PathLib - Path Visual Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TPath wrapper functionality for creating
  and managing vector path visual controls in Plan9Basic programs. TPath
  renders arbitrary shapes defined by connected lines and curves using
  SVG-like path syntax or programmatic construction.

  Function Count: 105 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All paths are created at RUNTIME using TPath.Create with dynamic
  parent assignment.

  FEATURES:
  =========
  - Path creation and lifecycle management
  - SVG-like path string syntax support
  - Programmatic path construction (MoveTo, LineTo, CurveTo, etc.)
  - All curve types: Cubic Bézier, Quadratic Bézier, Smooth curves, Arcs
  - Helper shape functions (AddRectangle, AddEllipse, AddArc)
  - Path transformation (Scale, Translate, Rotate)
  - Path query functions (bounds, point count, last point)
  - WrapMode for scaling behavior
  - Fill color and style
  - Stroke (border) color, thickness, and style
  - Complete positioning and alignment
  - Full event support with BASIC callback integration

  PATH DATA STRING SYNTAX (SVG-like):
  ===================================
  M x,y       - MoveTo: Move pen to point
  L x,y       - LineTo: Draw line to point
  H x         - HLineTo: Horizontal line to x
  V y         - VLineTo: Vertical line to y
  C x1,y1 x2,y2 x,y - CurveTo: Cubic Bézier curve
  S x2,y2 x,y - SmoothCurveTo: Smooth cubic Bézier
  Q x1,y1 x,y - QuadCurveTo: Quadratic Bézier curve
  T x,y       - SmoothQuadTo: Smooth quadratic Bézier
  A rx,ry rot large-arc sweep x,y - Arc
  Z           - ClosePath: Close current subpath

  Example: "M 10,10 L 100,10 L 100,100 L 10,100 Z" (draws a square)

  WRAP MODE:
  ==========
  0 = Original - Original path size at top-left
  1 = Fit      - Scale to fit maintaining aspect ratio
  2 = Stretch  - Stretch to fill bounds (default)
  3 = Tile     - Repeat path to fill area

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
    let frm# = form#("Path Demo", 800, 600)

    ' Create a path using SVG string
    let p# = path#(frm#, 50, 50, 200, 200)
    path_data#(p#, "M 10,10 L 190,10 L 100,190 Z")
    path_fill#(p#, "#3498db")
    path_stroke#(p#, "#2980b9")
    path_strokethickness#(p#, 2)

    ' Or build programmatically
    let p2# = path#(frm#, 300, 50, 200, 200)
    path_moveto#(p2#, 10, 10)
    path_lineto#(p2#, 190, 10)
    path_lineto#(p2#, 100, 190)
    path_closepath#(p2#)
    path_fill#(p2#, "#e74c3c")

    form_show(frm#)

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math, System.Math.Vectors,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, ControlCommon;

type
  TBasPath = class(TPath)
  private
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

    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;

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

    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
    //function ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;

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

    procedure DisconnectEvents;
    function CallbackExists(const FuncName: String): Boolean;

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
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
  end;

procedure RegisterPathFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  PATH_GC_TAG = 'BASIC_PATH';
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_PATH = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INVALID_CALLBACK = 5;
  ERR_INVALID_COLOR = 6;
  ERR_INVALID_DATA = 7;


  DASH_SOLID = 0;
  DASH_DASH = 1;
  DASH_DOT = 2;
  DASH_DASHDOT = 3;
  DASH_DASHDOTDOT = 4;
  CAP_FLAT = 0;
  CAP_ROUND = 1;
  JOIN_MITER = 0;
  JOIN_ROUND = 1;
  JOIN_BEVEL = 2;

  WRAP_ORIGINAL = 0;
  WRAP_FIT = 1;
  WRAP_STRETCH = 2;
  WRAP_TILE = 3;

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

procedure ClearError;
begin
  lastError := ERR_NONE;
  lastErrorMsg := '';
end;

function ValidatePath(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_PATH, FuncName + ': Nil path pointer');
    Exit;
  end;

  try
    if not (IsHandleOf(P, TBasPath)) then
    begin
      SetError(ERR_INVALID_PATH, FuncName + ': Invalid path object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_PATH, FuncName + ': Invalid path pointer');
    Exit;
  end;

  ClearError;
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

function IntToWrapMode(Value: Integer): TPathWrapMode;
begin
  case Value of
    WRAP_ORIGINAL: Result := TPathWrapMode.Original;
    WRAP_FIT: Result := TPathWrapMode.Fit;
    WRAP_STRETCH: Result := TPathWrapMode.Stretch;
    WRAP_TILE: Result := TPathWrapMode.Tile;
  else
    Result := TPathWrapMode.Stretch;
  end;
end;

function WrapModeToInt(Value: TPathWrapMode): Integer;
begin
  case Value of
    TPathWrapMode.Original: Result := WRAP_ORIGINAL;
    TPathWrapMode.Fit: Result := WRAP_FIT;
    TPathWrapMode.Stretch: Result := WRAP_STRETCH;
    TPathWrapMode.Tile: Result := WRAP_TILE;
  else
    Result := WRAP_STRETCH;
  end;
end;

//==============================================================================
// TBasPath Implementation
//==============================================================================

constructor TBasPath.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);

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

  FBasicEngine := nil;
  FConsoleOutput := nil;

  Fill.Kind := TBrushKind.Solid;
  Fill.Color := TAlphaColorRec.White;
  Stroke.Kind := TBrushKind.Solid;
  Stroke.Color := TAlphaColorRec.Black;
  Stroke.Thickness := 1;
  WrapMode := TPathWrapMode.Stretch;

  HitTest := True;
end;

destructor TBasPath.Destroy;
begin
  UnregisterHandle(Self);
  DisconnectEvents;
  inherited Destroy;
end;

procedure TBasPath.DisconnectEvents;
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

function TBasPath.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

procedure TBasPath.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'Path');
end;

//function TBasPath.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
//var
//  CallArgs: array of TAsmData;
//  RetType: TExprKind;
//  i: Integer;
//begin
//  Result.n := 0;
//  Result.p := nil;
//  Result.s := '';
//
//  if UnitGC.GlobalCallbackBusy then Exit;
//
//  if not Assigned(FBasicEngine) then Exit;
//  if not Assigned(FConsoleOutput) then Exit;
//  if FuncSignature = '' then Exit;
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
//        FConsoleOutput.Add('*** Path Event Callback Error ***');
//        FConsoleOutput.Add('Function: ' + FuncSignature);
//        FConsoleOutput.Add('Error: ' + E.Message);
//      end;
//    end;
//  finally
//    UnitGC.SkipProcessMessages := False;
//    UnitGC.GlobalCallbackBusy := False;
//  end;
//end;

procedure TBasPath.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    OnClick := InternalOnClick
  else
    OnClick := nil;
end;

procedure TBasPath.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    OnDblClick := InternalOnDblClick
  else
    OnDblClick := nil;
end;

procedure TBasPath.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    OnMouseDown := InternalOnMouseDown
  else
    OnMouseDown := nil;
end;

procedure TBasPath.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    OnMouseUp := InternalOnMouseUp
  else
    OnMouseUp := nil;
end;

procedure TBasPath.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    OnMouseMove := InternalOnMouseMove
  else
    OnMouseMove := nil;
end;

procedure TBasPath.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    OnMouseEnter := InternalOnMouseEnter
  else
    OnMouseEnter := nil;
end;

procedure TBasPath.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    OnMouseLeave := InternalOnMouseLeave
  else
    OnMouseLeave := nil;
end;

procedure TBasPath.SetOnMouseWheelFunc(const Value: String);
begin
  FOnMouseWheelFunc := Value;
  if Value <> '' then
    OnMouseWheel := InternalOnMouseWheel
  else
    OnMouseWheel := nil;
end;

procedure TBasPath.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    OnResize := InternalOnResize
  else
    OnResize := nil;
end;

procedure TBasPath.SetOnResizedFunc(const Value: String);
begin
  FOnResizedFunc := Value;
  if Value <> '' then
    OnResized := InternalOnResized
  else
    OnResized := nil;
end;

procedure TBasPath.SetOnPaintFunc(const Value: String);
begin
  FOnPaintFunc := Value;
  if Value <> '' then
    OnPainting := InternalOnPaint
  else
    OnPainting := nil;
end;

procedure TBasPath.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    OnDragEnter := InternalOnDragEnter
  else
    OnDragEnter := nil;
end;

procedure TBasPath.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    OnDragOver := InternalOnDragOver
  else
    OnDragOver := nil;
end;

procedure TBasPath.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    OnDragDrop := InternalOnDragDrop
  else
    OnDragDrop := nil;
end;

procedure TBasPath.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    OnDragLeave := InternalOnDragLeave
  else
    OnDragLeave := nil;
end;

procedure TBasPath.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnClickFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnClickFunc) + '@#', Args);
end;

procedure TBasPath.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDblClickFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDblClickFunc) + '@#', Args);
end;

procedure TBasPath.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseDownFunc = '' then Exit;
  Args[0].p := Sender;
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
  Args[4].s := BuildShiftString(Shift);
  Args[4].n := 0;
  Args[4].p := nil;
  ExecuteCallback(LowerCase(FOnMouseDownFunc) + '@#nnn$', Args);
end;

procedure TBasPath.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseUpFunc = '' then Exit;
  Args[0].p := Sender;
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
  Args[4].s := BuildShiftString(Shift);
  Args[4].n := 0;
  Args[4].p := nil;
  ExecuteCallback(LowerCase(FOnMouseUpFunc) + '@#nnn$', Args);
end;

procedure TBasPath.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnMouseMoveFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := X;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Y;
  Args[2].p := nil;
  Args[2].s := '';
  Args[3].s := BuildShiftString(Shift);
  Args[3].n := 0;
  Args[3].p := nil;
  ExecuteCallback(LowerCase(FOnMouseMoveFunc) + '@#nn$', Args);
end;

procedure TBasPath.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseEnterFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseEnterFunc) + '@#', Args);
end;

procedure TBasPath.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseLeaveFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseLeaveFunc) + '@#', Args);
end;

procedure TBasPath.InternalOnMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnMouseWheelFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := WheelDelta;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].s := BuildShiftString(Shift);
  Args[2].n := 0;
  Args[2].p := nil;
  ExecuteCallback(LowerCase(FOnMouseWheelFunc) + '@#n$', Args);
  Handled := True;
end;

procedure TBasPath.InternalOnResize(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizeFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizeFunc) + '@#', Args);
end;

procedure TBasPath.InternalOnResized(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizedFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizedFunc) + '@#', Args);
end;

procedure TBasPath.InternalOnPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnPaintFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnPaintFunc) + '@#', Args);
end;

procedure TBasPath.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragEnterFunc = '' then Exit;
  Args[0].p := Sender;
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

procedure TBasPath.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragOverFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';
  ExecuteCallback(LowerCase(FOnDragOverFunc) + '@#nn', Args);
  Operation := TDragOperation.Copy;
end;

procedure TBasPath.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragDropFunc = '' then Exit;
  Args[0].p := Sender;
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

procedure TBasPath.InternalOnDragLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDragLeaveFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDragLeaveFunc) + '@#', Args);
end;

//==============================================================================
// Library Functions - Error Handling
//==============================================================================

function n_path_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.s := '';
  Result.p := nil;
end;

function s_path_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := lastErrorMsg;
  Result.p := nil;
end;

function s_path_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Code := Round(Args[0].n);
  Result.n := 0;
  Result.p := nil;
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_PATH: Result.s := 'Invalid path';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Create failed';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback';
    ERR_INVALID_COLOR: Result.s := 'Invalid color';
    ERR_INVALID_DATA: Result.s := 'Invalid path data';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_path_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

//==============================================================================
// Library Functions - Creation/Destruction
//==============================================================================

function p_path_new(var Args: array of TAsmData): TAsmData;
var
  P: TBasPath;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateParent(Args[0].p, 'path#') then Exit;

  try
    P := TBasPath.Create(nil);
    P.Parent := TFmxObject(Args[0].p);
    P.BasicEngine := ModuleEngine;
    P.ConsoleOutput := ModuleOutput;

    Result.p := Pointer(P);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(P, PATH_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'path#: ' + E.Message);
  end;
end;

function p_path_new_size(var Args: array of TAsmData): TAsmData;
var
  P: TBasPath;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'path#') then Exit;

  try
    P := TBasPath.Create(nil);
    P.Parent := TFmxObject(Args[0].p);
    P.Width := Args[1].n;
    P.Height := Args[2].n;
    P.BasicEngine := ModuleEngine;
    P.ConsoleOutput := ModuleOutput;

    Result.p := Pointer(P);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(P, PATH_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'path#: ' + E.Message);
  end;
end;

function p_path_new_full(var Args: array of TAsmData): TAsmData;
var
  P: TBasPath;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'path#') then Exit;

  try
    P := TBasPath.Create(nil);
    P.Parent := TFmxObject(Args[0].p);
    P.Position.X := Args[1].n;
    P.Position.Y := Args[2].n;
    P.Width := Args[3].n;
    P.Height := Args[4].n;
    P.BasicEngine := ModuleEngine;
    P.ConsoleOutput := ModuleOutput;

    Result.p := Pointer(P);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(P, PATH_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'path#: ' + E.Message);
  end;
end;

function n_path_free(var Args: array of TAsmData): TAsmData;
var
  P: TBasPath;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidatePath(Args[0].p, 'path_free') then Exit;

  try
    P := TBasPath(Args[0].p);
    P.DisconnectEvents;
    P.Free();

//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(PATH_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PATH, 'path_free: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Path Data (String-based)
//==============================================================================

function s_path_data_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_data$') then Exit;
  try
    Result.s := TBasPath(Args[0].p).Data.Data;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_data$: ' + E.Message);
  end;
end;

function p_path_data_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_data#') then Exit;
  try
    TBasPath(Args[0].p).Data.Data := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_INVALID_DATA, 'path_data#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Path Data (Programmatic Construction)
//==============================================================================

function p_path_moveto(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_moveto#') then Exit;
  try
    TBasPath(Args[0].p).Data.MoveTo(PointF(Args[1].n, Args[2].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_moveto#: ' + E.Message);
  end;
end;

function p_path_lineto(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_lineto#') then Exit;
  try
    TBasPath(Args[0].p).Data.LineTo(PointF(Args[1].n, Args[2].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_lineto#: ' + E.Message);
  end;
end;

function p_path_hlineto(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_hlineto#') then Exit;
  try
    TBasPath(Args[0].p).Data.HLineTo(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_hlineto#: ' + E.Message);
  end;
end;

function p_path_vlineto(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_vlineto#') then Exit;
  try
    TBasPath(Args[0].p).Data.VLineTo(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_vlineto#: ' + E.Message);
  end;
end;

function p_path_curveto(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_curveto#') then Exit;
  try
    TBasPath(Args[0].p).Data.CurveTo(
      PointF(Args[1].n, Args[2].n),  // Control point 1
      PointF(Args[3].n, Args[4].n),  // Control point 2
      PointF(Args[5].n, Args[6].n)   // End point
    );
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_curveto#: ' + E.Message);
  end;
end;

function p_path_smoothcurveto(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_smoothcurveto#') then Exit;
  try
    TBasPath(Args[0].p).Data.SmoothCurveTo(
      PointF(Args[1].n, Args[2].n),  // Control point 2
      PointF(Args[3].n, Args[4].n)   // End point
    );
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_smoothcurveto#: ' + E.Message);
  end;
end;

function p_path_quadcurveto(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_quadcurveto#') then Exit;
  try
    TBasPath(Args[0].p).Data.QuadCurveTo(
      PointF(Args[1].n, Args[2].n),  // Control point
      PointF(Args[3].n, Args[4].n)   // End point
    );
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_quadcurveto#: ' + E.Message);
  end;
end;

function p_path_closepath(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_closepath#') then Exit;
  try
    TBasPath(Args[0].p).Data.ClosePath;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_closepath#: ' + E.Message);
  end;
end;

function p_path_clear(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_clear#') then Exit;
  try
    TBasPath(Args[0].p).Data.Clear;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_clear#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Helper Shape Functions
//==============================================================================

function p_path_addrectangle(var Args: array of TAsmData): TAsmData;
var
  R: TRectF;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_addrectangle#') then Exit;
  try
    R := RectF(Args[1].n, Args[2].n, Args[1].n + Args[3].n, Args[2].n + Args[4].n);
    TBasPath(Args[0].p).Data.AddRectangle(R, Args[5].n, Args[6].n, AllCorners);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_addrectangle#: ' + E.Message);
  end;
end;

function p_path_addellipse(var Args: array of TAsmData): TAsmData;
var
  R: TRectF;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_addellipse#') then Exit;
  try
    R := RectF(Args[1].n, Args[2].n, Args[1].n + Args[3].n, Args[2].n + Args[4].n);
    TBasPath(Args[0].p).Data.AddEllipse(R);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_addellipse#: ' + E.Message);
  end;
end;

function p_path_addarc(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_addarc#') then Exit;
  try
    TBasPath(Args[0].p).Data.AddArc(
      PointF(Args[1].n, Args[2].n),  // Center
      PointF(Args[3].n, Args[4].n),  // Radius (X, Y)
      Args[5].n,                      // Start angle
      Args[6].n                       // Sweep angle
    );
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_addarc#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Path Transformation
//==============================================================================

function p_path_scale(var Args: array of TAsmData): TAsmData;
var
  M: TMatrix;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_scale#') then Exit;
  try
    M := TMatrix.CreateScaling(Args[1].n, Args[2].n);
    TBasPath(Args[0].p).Data.ApplyMatrix(M);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_scale#: ' + E.Message);
  end;
end;

function p_path_translate(var Args: array of TAsmData): TAsmData;
var
  M: TMatrix;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_translate#') then Exit;
  try
    M := TMatrix.CreateTranslation(Args[1].n, Args[2].n);
    TBasPath(Args[0].p).Data.ApplyMatrix(M);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_translate#: ' + E.Message);
  end;
end;

function p_path_rotate(var Args: array of TAsmData): TAsmData;
var
  M: TMatrix;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_rotate#') then Exit;
  try
    M := TMatrix.CreateRotation(DegToRad(Args[1].n));
    TBasPath(Args[0].p).Data.ApplyMatrix(M);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_rotate#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Path Query
//==============================================================================

function n_path_pointcount(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_pointcount') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Data.Count;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_pointcount: ' + E.Message);
  end;
end;

function n_path_lastx(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_lastx') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Data.LastPoint.X;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_lastx: ' + E.Message);
  end;
end;

function n_path_lasty(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_lasty') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Data.LastPoint.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_lasty: ' + E.Message);
  end;
end;

function n_path_boundsx(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_boundsx') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Data.GetBounds.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_boundsx: ' + E.Message);
  end;
end;

function n_path_boundsy(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_boundsy') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Data.GetBounds.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_boundsy: ' + E.Message);
  end;
end;

function n_path_boundswidth(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_boundswidth') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Data.GetBounds.Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_boundswidth: ' + E.Message);
  end;
end;

function n_path_boundsheight(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_boundsheight') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Data.GetBounds.Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_boundsheight: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - WrapMode
//==============================================================================

function n_path_wrapmode_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_wrapmode') then Exit;
  try
    Result.n := WrapModeToInt(TBasPath(Args[0].p).WrapMode);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_wrapmode: ' + E.Message);
  end;
end;

function p_path_wrapmode_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_wrapmode#') then Exit;
  try
    TBasPath(Args[0].p).WrapMode := IntToWrapMode(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_wrapmode#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Fill
//==============================================================================

function s_path_fill_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_fill$') then Exit;
  try
    Result.s := TUtils.AlphaColorToStr(TBasPath(Args[0].p).Fill.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_fill$: ' + E.Message);
  end;
end;

function p_path_fill_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_fill#') then Exit;
  try
    TBasPath(Args[0].p).Fill.Kind := TBrushKind.Solid;
    TBasPath(Args[0].p).Fill.Color := TUtils.ColorToAlphaColor(Args[1].s);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_fill#: ' + E.Message);
  end;
end;

function p_path_fillnone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_fillnone#') then Exit;
  try
    TBasPath(Args[0].p).Fill.Kind := TBrushKind.None;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_fillnone#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Stroke
//==============================================================================

function s_path_stroke_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_stroke$') then Exit;
  try
    Result.s := TUtils.AlphaColorToStr(TBasPath(Args[0].p).Stroke.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_stroke$: ' + E.Message);
  end;
end;

function p_path_stroke_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_stroke#') then Exit;
  try
    TBasPath(Args[0].p).Stroke.Kind := TBrushKind.Solid;
    TBasPath(Args[0].p).Stroke.Color := TUtils.ColorToAlphaColor(Args[1].s);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_stroke#: ' + E.Message);
  end;
end;

function p_path_strokenone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_strokenone#') then Exit;
  try
    TBasPath(Args[0].p).Stroke.Kind := TBrushKind.None;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_strokenone#: ' + E.Message);
  end;
end;

function n_path_strokethickness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_strokethickness') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Stroke.Thickness;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_strokethickness: ' + E.Message);
  end;
end;

function p_path_strokethickness_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_strokethickness#') then Exit;
  try
    TBasPath(Args[0].p).Stroke.Thickness := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_strokethickness#: ' + E.Message);
  end;
end;

function n_path_strokedash_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_strokedash') then Exit;
  try
    Result.n := StrokeDashToInt(TBasPath(Args[0].p).Stroke.Dash);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_strokedash: ' + E.Message);
  end;
end;

function p_path_strokedash_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_strokedash#') then Exit;
  try
    TBasPath(Args[0].p).Stroke.Dash := IntToStrokeDash(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_strokedash#: ' + E.Message);
  end;
end;

function n_path_strokecap_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_strokecap') then Exit;
  try
    Result.n := StrokeCapToInt(TBasPath(Args[0].p).Stroke.Cap);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_strokecap: ' + E.Message);
  end;
end;

function p_path_strokecap_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_strokecap#') then Exit;
  try
    TBasPath(Args[0].p).Stroke.Cap := IntToStrokeCap(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_strokecap#: ' + E.Message);
  end;
end;

function n_path_strokejoin_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_strokejoin') then Exit;
  try
    Result.n := StrokeJoinToInt(TBasPath(Args[0].p).Stroke.Join);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_strokejoin: ' + E.Message);
  end;
end;

function p_path_strokejoin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_strokejoin#') then Exit;
  try
    TBasPath(Args[0].p).Stroke.Join := IntToStrokeJoin(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_strokejoin#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Position and Size
//==============================================================================

function n_path_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_x') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Position.X;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_x: ' + E.Message);
  end;
end;

function p_path_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_x#') then Exit;
  try
    TBasPath(Args[0].p).Position.X := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_x#: ' + E.Message);
  end;
end;

function n_path_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_y') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Position.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_y: ' + E.Message);
  end;
end;

function p_path_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_y#') then Exit;
  try
    TBasPath(Args[0].p).Position.Y := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_y#: ' + E.Message);
  end;
end;

function n_path_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_width') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_width: ' + E.Message);
  end;
end;

function p_path_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_width#') then Exit;
  try
    TBasPath(Args[0].p).Width := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_width#: ' + E.Message);
  end;
end;

function n_path_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_height') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_height: ' + E.Message);
  end;
end;

function p_path_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_height#') then Exit;
  try
    TBasPath(Args[0].p).Height := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_height#: ' + E.Message);
  end;
end;

function p_path_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_bounds#') then Exit;
  try
    TBasPath(Args[0].p).Position.X := Args[1].n;
    TBasPath(Args[0].p).Position.Y := Args[2].n;
    TBasPath(Args[0].p).Width := Args[3].n;
    TBasPath(Args[0].p).Height := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_bounds#: ' + E.Message);
  end;
end;

function p_path_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_size#') then Exit;
  try
    TBasPath(Args[0].p).Width := Args[1].n;
    TBasPath(Args[0].p).Height := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_size#: ' + E.Message);
  end;
end;

function p_path_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_move#') then Exit;
  try
    TBasPath(Args[0].p).Position.X := Args[1].n;
    TBasPath(Args[0].p).Position.Y := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_move#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Alignment
//==============================================================================

function n_path_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_align') then Exit;
  try
    Result.n := AlignToInt(TBasPath(Args[0].p).Align);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_align: ' + E.Message);
  end;
end;

function p_path_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_align#') then Exit;
  try
    TBasPath(Args[0].p).Align := AlignFromInt(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_align#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Margins
//==============================================================================

function n_path_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_marginleft') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Margins.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_marginleft: ' + E.Message);
  end;
end;

function p_path_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_marginleft#') then Exit;
  try
    TBasPath(Args[0].p).Margins.Left := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_marginleft#: ' + E.Message);
  end;
end;

function n_path_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_margintop') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Margins.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_margintop: ' + E.Message);
  end;
end;

function p_path_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_margintop#') then Exit;
  try
    TBasPath(Args[0].p).Margins.Top := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_margintop#: ' + E.Message);
  end;
end;

function n_path_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_marginright') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Margins.Right;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_marginright: ' + E.Message);
  end;
end;

function p_path_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_marginright#') then Exit;
  try
    TBasPath(Args[0].p).Margins.Right := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_marginright#: ' + E.Message);
  end;
end;

function n_path_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_marginbottom') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Margins.Bottom;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_marginbottom: ' + E.Message);
  end;
end;

function p_path_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_marginbottom#') then Exit;
  try
    TBasPath(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_marginbottom#: ' + E.Message);
  end;
end;

function p_path_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_margins#') then Exit;
  try
    TBasPath(Args[0].p).Margins.Left := Args[1].n;
    TBasPath(Args[0].p).Margins.Top := Args[2].n;
    TBasPath(Args[0].p).Margins.Right := Args[3].n;
    TBasPath(Args[0].p).Margins.Bottom := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_margins#: ' + E.Message);
  end;
end;

function p_path_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_margin#') then Exit;
  try
    TBasPath(Args[0].p).Margins.Left := Args[1].n;
    TBasPath(Args[0].p).Margins.Top := Args[1].n;
    TBasPath(Args[0].p).Margins.Right := Args[1].n;
    TBasPath(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_margin#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Visibility and Behavior
//==============================================================================

function n_path_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_visible') then Exit;
  try
    if TBasPath(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_visible: ' + E.Message);
  end;
end;

function p_path_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_visible#') then Exit;
  try
    TBasPath(Args[0].p).Visible := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_visible#: ' + E.Message);
  end;
end;

function n_path_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_enabled') then Exit;
  try
    if TBasPath(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_enabled: ' + E.Message);
  end;
end;

function p_path_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_enabled#') then Exit;
  try
    TBasPath(Args[0].p).Enabled := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_enabled#: ' + E.Message);
  end;
end;

function n_path_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_opacity') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Opacity;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_opacity: ' + E.Message);
  end;
end;

function p_path_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_opacity#') then Exit;
  try
    TBasPath(Args[0].p).Opacity := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_opacity#: ' + E.Message);
  end;
end;

function n_path_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_hittest') then Exit;
  try
    if TBasPath(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_hittest: ' + E.Message);
  end;
end;

function p_path_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_hittest#') then Exit;
  try
    TBasPath(Args[0].p).HitTest := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_hittest#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Tag and Rotation
//==============================================================================

function n_path_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_tag') then Exit;
  try
    Result.n := TBasPath(Args[0].p).Tag;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_tag: ' + E.Message);
  end;
end;

function p_path_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_tag#') then Exit;
  try
    TBasPath(Args[0].p).Tag := Round(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_tag#: ' + E.Message);
  end;
end;

function n_path_rotation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidatePath(Args[0].p, 'path_rotation') then Exit;
  try
    Result.n := TBasPath(Args[0].p).RotationAngle;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_rotation: ' + E.Message);
  end;
end;

function p_path_rotation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_rotation#') then Exit;
  try
    TBasPath(Args[0].p).RotationAngle := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_rotation#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Parent and Z-Order
//==============================================================================

function p_path_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_parent#') then Exit;
  try
    Result.p := TBasPath(Args[0].p).Parent;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_parent#: ' + E.Message);
  end;
end;

function p_path_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_parent#') then Exit;
  if not ValidateParent(Args[1].p, 'path_parent#') then Exit;
  try
    TBasPath(Args[0].p).Parent := TFmxObject(Args[1].p);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_parent#: ' + E.Message);
  end;
end;

function p_path_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_bringtofront#') then Exit;
  try
    TBasPath(Args[0].p).BringToFront;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_bringtofront#: ' + E.Message);
  end;
end;

function p_path_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_sendtoback#') then Exit;
  try
    TBasPath(Args[0].p).SendToBack;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_sendtoback#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Invalidation
//==============================================================================

function p_path_invalidate(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_invalidate#') then Exit;
  try
    TBasPath(Args[0].p).Repaint;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_invalidate#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Event Callbacks
//==============================================================================

function p_path_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onclick#') then Exit;
  try
    TBasPath(Args[0].p).OnClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onclick#: ' + E.Message);
  end;
end;

function s_path_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onclick$') then Exit;
  try
    Result.s := TBasPath(Args[0].p).OnClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onclick$: ' + E.Message);
  end;
end;

function p_path_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_ondblclick#') then Exit;
  try
    TBasPath(Args[0].p).OnDblClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_ondblclick#: ' + E.Message);
  end;
end;

function s_path_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_ondblclick$') then Exit;
  try
    Result.s := TBasPath(Args[0].p).OnDblClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_ondblclick$: ' + E.Message);
  end;
end;

function p_path_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onmousedown#') then Exit;
  try
    TBasPath(Args[0].p).OnMouseDownFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onmousedown#: ' + E.Message);
  end;
end;

function s_path_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onmousedown$') then Exit;
  try
    Result.s := TBasPath(Args[0].p).OnMouseDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onmousedown$: ' + E.Message);
  end;
end;

function p_path_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onmouseup#') then Exit;
  try
    TBasPath(Args[0].p).OnMouseUpFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onmouseup#: ' + E.Message);
  end;
end;

function s_path_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onmouseup$') then Exit;
  try
    Result.s := TBasPath(Args[0].p).OnMouseUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onmouseup$: ' + E.Message);
  end;
end;

function p_path_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onmousemove#') then Exit;
  try
    TBasPath(Args[0].p).OnMouseMoveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onmousemove#: ' + E.Message);
  end;
end;

function s_path_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onmousemove$') then Exit;
  try
    Result.s := TBasPath(Args[0].p).OnMouseMoveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onmousemove$: ' + E.Message);
  end;
end;

function p_path_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onmouseenter#') then Exit;
  try
    TBasPath(Args[0].p).OnMouseEnterFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onmouseenter#: ' + E.Message);
  end;
end;

function s_path_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onmouseenter$') then Exit;
  try
    Result.s := TBasPath(Args[0].p).OnMouseEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onmouseenter$: ' + E.Message);
  end;
end;

function p_path_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onmouseleave#') then Exit;
  try
    TBasPath(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onmouseleave#: ' + E.Message);
  end;
end;

function s_path_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onmouseleave$') then Exit;
  try
    Result.s := TBasPath(Args[0].p).OnMouseLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onmouseleave$: ' + E.Message);
  end;
end;

function p_path_onmousewheel_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onmousewheel#') then Exit;
  try
    TBasPath(Args[0].p).OnMouseWheelFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onmousewheel#: ' + E.Message);
  end;
end;

function s_path_onmousewheel_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onmousewheel$') then Exit;
  try
    Result.s := TBasPath(Args[0].p).OnMouseWheelFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onmousewheel$: ' + E.Message);
  end;
end;

function p_path_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onresize#') then Exit;
  try
    TBasPath(Args[0].p).OnResizeFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onresize#: ' + E.Message);
  end;
end;

function s_path_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidatePath(Args[0].p, 'path_onresize$') then Exit;
  try
    Result.s := TBasPath(Args[0].p).OnResizeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'path_onresize$: ' + E.Message);
  end;
end;

function p_path_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePath(Args[0].p, 'path_clearcallbacks#') then Exit;

  try
    with TBasPath(Args[0].p) do
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
      SetError(ERR_OPERATION_FAILED, 'path_clearcallbacks#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterPathFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;

  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_path_error; Lib.Add('path_error@', Fn);
  Fn.Entry := @s_path_errormsg; Lib.Add('path_errormsg$@', Fn);
  Fn.Entry := @s_path_strerror; Lib.Add('path_strerror$@n', Fn);
  Fn.Entry := @n_path_clearerror; Lib.Add('path_clearerror@', Fn);

  // Path creation/destruction
  Fn.Entry := @p_path_new; Lib.Add('path#@#', Fn);
  Fn.Entry := @p_path_new_size; Lib.Add('path#@#nn', Fn);
  Fn.Entry := @p_path_new_full; Lib.Add('path#@#nnnn', Fn);
  Fn.Entry := @n_path_free; Lib.Add('path_free@#', Fn);

  // Path data (string-based)
  Fn.Entry := @s_path_data_get; Lib.Add('path_data$@#', Fn);
  Fn.Entry := @p_path_data_set; Lib.Add('path_data#@#$', Fn);

  // Path data (programmatic construction)
  Fn.Entry := @p_path_moveto; Lib.Add('path_moveto#@#nn', Fn);
  Fn.Entry := @p_path_lineto; Lib.Add('path_lineto#@#nn', Fn);
  Fn.Entry := @p_path_hlineto; Lib.Add('path_hlineto#@#n', Fn);
  Fn.Entry := @p_path_vlineto; Lib.Add('path_vlineto#@#n', Fn);
  Fn.Entry := @p_path_curveto; Lib.Add('path_curveto#@#nnnnnn', Fn);
  Fn.Entry := @p_path_smoothcurveto; Lib.Add('path_smoothcurveto#@#nnnn', Fn);
  Fn.Entry := @p_path_quadcurveto; Lib.Add('path_quadcurveto#@#nnnn', Fn);
  Fn.Entry := @p_path_closepath; Lib.Add('path_closepath#@#', Fn);
  Fn.Entry := @p_path_clear; Lib.Add('path_clear#@#', Fn);

  // Helper shape functions
  Fn.Entry := @p_path_addrectangle; Lib.Add('path_addrectangle#@#nnnnnn', Fn);
  Fn.Entry := @p_path_addellipse; Lib.Add('path_addellipse#@#nnnn', Fn);
  Fn.Entry := @p_path_addarc; Lib.Add('path_addarc#@#nnnnnn', Fn);

  // Path transformation
  Fn.Entry := @p_path_scale; Lib.Add('path_scale#@#nn', Fn);
  Fn.Entry := @p_path_translate; Lib.Add('path_translate#@#nn', Fn);
  Fn.Entry := @p_path_rotate; Lib.Add('path_rotate#@#n', Fn);

  // Path query
  Fn.Entry := @n_path_pointcount; Lib.Add('path_pointcount@#', Fn);
  Fn.Entry := @n_path_lastx; Lib.Add('path_lastx@#', Fn);
  Fn.Entry := @n_path_lasty; Lib.Add('path_lasty@#', Fn);
  Fn.Entry := @n_path_boundsx; Lib.Add('path_boundsx@#', Fn);
  Fn.Entry := @n_path_boundsy; Lib.Add('path_boundsy@#', Fn);
  Fn.Entry := @n_path_boundswidth; Lib.Add('path_boundswidth@#', Fn);
  Fn.Entry := @n_path_boundsheight; Lib.Add('path_boundsheight@#', Fn);

  // WrapMode
  Fn.Entry := @n_path_wrapmode_get; Lib.Add('path_wrapmode@#', Fn);
  Fn.Entry := @p_path_wrapmode_set; Lib.Add('path_wrapmode#@#n', Fn);

  // Fill
  Fn.Entry := @s_path_fill_get; Lib.Add('path_fill$@#', Fn);
  Fn.Entry := @p_path_fill_set; Lib.Add('path_fill#@#$', Fn);
  Fn.Entry := @p_path_fillnone; Lib.Add('path_fillnone#@#', Fn);

  // Stroke
  Fn.Entry := @s_path_stroke_get; Lib.Add('path_stroke$@#', Fn);
  Fn.Entry := @p_path_stroke_set; Lib.Add('path_stroke#@#$', Fn);
  Fn.Entry := @p_path_strokenone; Lib.Add('path_strokenone#@#', Fn);
  Fn.Entry := @n_path_strokethickness_get; Lib.Add('path_strokethickness@#', Fn);
  Fn.Entry := @p_path_strokethickness_set; Lib.Add('path_strokethickness#@#n', Fn);
  Fn.Entry := @n_path_strokedash_get; Lib.Add('path_strokedash@#', Fn);
  Fn.Entry := @p_path_strokedash_set; Lib.Add('path_strokedash#@#n', Fn);
  Fn.Entry := @n_path_strokecap_get; Lib.Add('path_strokecap@#', Fn);
  Fn.Entry := @p_path_strokecap_set; Lib.Add('path_strokecap#@#n', Fn);
  Fn.Entry := @n_path_strokejoin_get; Lib.Add('path_strokejoin@#', Fn);
  Fn.Entry := @p_path_strokejoin_set; Lib.Add('path_strokejoin#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_path_x_get; Lib.Add('path_x@#', Fn);
  Fn.Entry := @p_path_x_set; Lib.Add('path_x#@#n', Fn);
  Fn.Entry := @n_path_y_get; Lib.Add('path_y@#', Fn);
  Fn.Entry := @p_path_y_set; Lib.Add('path_y#@#n', Fn);
  Fn.Entry := @n_path_width_get; Lib.Add('path_width@#', Fn);
  Fn.Entry := @p_path_width_set; Lib.Add('path_width#@#n', Fn);
  Fn.Entry := @n_path_height_get; Lib.Add('path_height@#', Fn);
  Fn.Entry := @p_path_height_set; Lib.Add('path_height#@#n', Fn);
  Fn.Entry := @p_path_bounds_set; Lib.Add('path_bounds#@#nnnn', Fn);
  Fn.Entry := @p_path_size_set; Lib.Add('path_size#@#nn', Fn);
  Fn.Entry := @p_path_move_set; Lib.Add('path_move#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_path_align_get; Lib.Add('path_align@#', Fn);
  Fn.Entry := @p_path_align_set; Lib.Add('path_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_path_marginleft_get; Lib.Add('path_marginleft@#', Fn);
  Fn.Entry := @p_path_marginleft_set; Lib.Add('path_marginleft#@#n', Fn);
  Fn.Entry := @n_path_margintop_get; Lib.Add('path_margintop@#', Fn);
  Fn.Entry := @p_path_margintop_set; Lib.Add('path_margintop#@#n', Fn);
  Fn.Entry := @n_path_marginright_get; Lib.Add('path_marginright@#', Fn);
  Fn.Entry := @p_path_marginright_set; Lib.Add('path_marginright#@#n', Fn);
  Fn.Entry := @n_path_marginbottom_get; Lib.Add('path_marginbottom@#', Fn);
  Fn.Entry := @p_path_marginbottom_set; Lib.Add('path_marginbottom#@#n', Fn);
  Fn.Entry := @p_path_margins_set; Lib.Add('path_margins#@#nnnn', Fn);
  Fn.Entry := @p_path_margin_set; Lib.Add('path_margin#@#n', Fn);

  // Visibility and behavior
  Fn.Entry := @n_path_visible_get; Lib.Add('path_visible@#', Fn);
  Fn.Entry := @p_path_visible_set; Lib.Add('path_visible#@#n', Fn);
  Fn.Entry := @n_path_enabled_get; Lib.Add('path_enabled@#', Fn);
  Fn.Entry := @p_path_enabled_set; Lib.Add('path_enabled#@#n', Fn);
  Fn.Entry := @n_path_opacity_get; Lib.Add('path_opacity@#', Fn);
  Fn.Entry := @p_path_opacity_set; Lib.Add('path_opacity#@#n', Fn);
  Fn.Entry := @n_path_hittest_get; Lib.Add('path_hittest@#', Fn);
  Fn.Entry := @p_path_hittest_set; Lib.Add('path_hittest#@#n', Fn);

  // Tag and rotation
  Fn.Entry := @n_path_tag_get; Lib.Add('path_tag@#', Fn);
  Fn.Entry := @p_path_tag_set; Lib.Add('path_tag#@#n', Fn);
  Fn.Entry := @n_path_rotation_get; Lib.Add('path_rotation@#', Fn);
  Fn.Entry := @p_path_rotation_set; Lib.Add('path_rotation#@#n', Fn);

  // Parent
  Fn.Entry := @p_path_parent_get; Lib.Add('path_parent#@#', Fn);
  Fn.Entry := @p_path_parent_set; Lib.Add('path_parent#@##', Fn);
  Fn.Entry := @p_path_bringtofront; Lib.Add('path_bringtofront#@#', Fn);
  Fn.Entry := @p_path_sendtoback; Lib.Add('path_sendtoback#@#', Fn);

  // Invalidation
  Fn.Entry := @p_path_invalidate; Lib.Add('path_invalidate#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_path_onclick_set; Lib.Add('path_onclick#@#$', Fn);
  Fn.Entry := @s_path_onclick_get; Lib.Add('path_onclick$@#', Fn);
  Fn.Entry := @p_path_ondblclick_set; Lib.Add('path_ondblclick#@#$', Fn);
  Fn.Entry := @s_path_ondblclick_get; Lib.Add('path_ondblclick$@#', Fn);
  Fn.Entry := @p_path_onmousedown_set; Lib.Add('path_onmousedown#@#$', Fn);
  Fn.Entry := @s_path_onmousedown_get; Lib.Add('path_onmousedown$@#', Fn);
  Fn.Entry := @p_path_onmouseup_set; Lib.Add('path_onmouseup#@#$', Fn);
  Fn.Entry := @s_path_onmouseup_get; Lib.Add('path_onmouseup$@#', Fn);
  Fn.Entry := @p_path_onmousemove_set; Lib.Add('path_onmousemove#@#$', Fn);
  Fn.Entry := @s_path_onmousemove_get; Lib.Add('path_onmousemove$@#', Fn);
  Fn.Entry := @p_path_onmouseenter_set; Lib.Add('path_onmouseenter#@#$', Fn);
  Fn.Entry := @s_path_onmouseenter_get; Lib.Add('path_onmouseenter$@#', Fn);
  Fn.Entry := @p_path_onmouseleave_set; Lib.Add('path_onmouseleave#@#$', Fn);
  Fn.Entry := @s_path_onmouseleave_get; Lib.Add('path_onmouseleave$@#', Fn);
  Fn.Entry := @p_path_onmousewheel_set; Lib.Add('path_onmousewheel#@#$', Fn);
  Fn.Entry := @s_path_onmousewheel_get; Lib.Add('path_onmousewheel$@#', Fn);
  Fn.Entry := @p_path_onresize_set; Lib.Add('path_onresize#@#$', Fn);
  Fn.Entry := @s_path_onresize_get; Lib.Add('path_onresize$@#', Fn);
  Fn.Entry := @p_path_clearcallbacks; Lib.Add('path_clearcallbacks#@#', Fn);
end;

end.

