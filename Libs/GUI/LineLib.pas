unit LineLib;

{******************************************************************************
  LineLib - Line Visual Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TLine wrapper functionality for creating
  and managing line visual controls in Plan9Basic programs. TLine is a visual
  shape control that draws a line within a bounding rectangle.

  Function Count: 72 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All lines are created at RUNTIME using TLine.Create with dynamic parent
  assignment. This ensures proper dynamic creation across all platforms.

  FEATURES:
  =========
  - Line creation and lifecycle management
  - Line type control (Diagonal, Top, Left)
  - Stroke color, thickness, and style
  - Complete positioning and alignment
  - Full event support with BASIC callback integration

  NOTE: Unlike other shape controls, TLine does NOT have a Fill property.
  Lines are drawn using only the Stroke properties.

  LINE TYPE:
  ==========
  The LineType property determines how the line is drawn within its bounds:
  0 = Diagonal (default): Line from top-left to bottom-right corner
  1 = Top: Horizontal line at the top edge
  2 = Left: Vertical line at the left edge

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, ControlCommon;

type
  TBasLine = class(TLine)
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

    procedure DisconnectEvents();
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

procedure RegisterLineFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  LINE_GC_TAG = 'BASIC_LINE';
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_LINE = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INVALID_CALLBACK = 5;
  ERR_INVALID_COLOR = 6;


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

  LINE_DIAGONAL = 0;
  LINE_TOP = 1;
  LINE_LEFT = 2;

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

function ValidateLine(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_LINE, FuncName + ': Nil line pointer');
    Exit;
  end;

  try
    if not (IsHandleOf(P, TBasLine)) then
    begin
      SetError(ERR_INVALID_LINE, FuncName + ': Invalid line object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_LINE, FuncName + ': Invalid line pointer');
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

function IntToLineType(Value: Integer): TLineType;
begin
  case Value of
    LINE_TOP: Result := TLineType.Top;
    LINE_LEFT: Result := TLineType.Left;
  else
    Result := TLineType.Diagonal;
  end;
end;

function LineTypeToInt(Value: TLineType): Integer;
begin
  case Value of
    TLineType.Top: Result := LINE_TOP;
    TLineType.Left: Result := LINE_LEFT;
  else
    Result := LINE_DIAGONAL;
  end;
end;

//==============================================================================
// TBasLine Implementation
//==============================================================================

constructor TBasLine.Create(AOwner: TComponent);
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

  // Set default line stroke
  Stroke.Kind := TBrushKind.Solid;
  Stroke.Color := TAlphaColorRec.Black;
  Stroke.Thickness := 1;

  // Enable hit testing for mouse events
  HitTest := True;
end;

destructor TBasLine.Destroy;
begin
  UnregisterHandle(Self);
  DisconnectEvents();
  inherited Destroy;
end;

procedure TBasLine.DisconnectEvents();
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

function TBasLine.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

procedure TBasLine.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'Line');
end;

//function TBasLine.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
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
//        FConsoleOutput.Add('*** Line Event Callback Error ***');
//        FConsoleOutput.Add('Function: ' + FuncSignature);
//        FConsoleOutput.Add('Error: ' + E.Message);
//      end;
//    end;
//  finally
//    UnitGC.SkipProcessMessages := False;
//    UnitGC.GlobalCallbackBusy := False;
//  end;
//end;

procedure TBasLine.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    OnClick := InternalOnClick
  else
    OnClick := nil;
end;

procedure TBasLine.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    OnDblClick := InternalOnDblClick
  else
    OnDblClick := nil;
end;

procedure TBasLine.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    OnMouseDown := InternalOnMouseDown
  else
    OnMouseDown := nil;
end;

procedure TBasLine.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    OnMouseUp := InternalOnMouseUp
  else
    OnMouseUp := nil;
end;

procedure TBasLine.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    OnMouseMove := InternalOnMouseMove
  else
    OnMouseMove := nil;
end;

procedure TBasLine.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    OnMouseEnter := InternalOnMouseEnter
  else
    OnMouseEnter := nil;
end;

procedure TBasLine.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    OnMouseLeave := InternalOnMouseLeave
  else
    OnMouseLeave := nil;
end;

procedure TBasLine.SetOnMouseWheelFunc(const Value: String);
begin
  FOnMouseWheelFunc := Value;
  if Value <> '' then
    OnMouseWheel := InternalOnMouseWheel
  else
    OnMouseWheel := nil;
end;

procedure TBasLine.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    OnResize := InternalOnResize
  else
    OnResize := nil;
end;

procedure TBasLine.SetOnResizedFunc(const Value: String);
begin
  FOnResizedFunc := Value;
  if Value <> '' then
    OnResized := InternalOnResized
  else
    OnResized := nil;
end;

procedure TBasLine.SetOnPaintFunc(const Value: String);
begin
  FOnPaintFunc := Value;
  if Value <> '' then
    OnPainting := InternalOnPaint
  else
    OnPainting := nil;
end;

procedure TBasLine.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    OnDragEnter := InternalOnDragEnter
  else
    OnDragEnter := nil;
end;

procedure TBasLine.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    OnDragOver := InternalOnDragOver
  else
    OnDragOver := nil;
end;

procedure TBasLine.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    OnDragDrop := InternalOnDragDrop
  else
    OnDragDrop := nil;
end;

procedure TBasLine.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    OnDragLeave := InternalOnDragLeave
  else
    OnDragLeave := nil;
end;

procedure TBasLine.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnClickFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnClickFunc) + '@#', Args);
end;

procedure TBasLine.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDblClickFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDblClickFunc) + '@#', Args);
end;

procedure TBasLine.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasLine.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasLine.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
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

procedure TBasLine.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseEnterFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseEnterFunc) + '@#', Args);
end;

procedure TBasLine.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseLeaveFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseLeaveFunc) + '@#', Args);
end;

procedure TBasLine.InternalOnMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
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

procedure TBasLine.InternalOnResize(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizeFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizeFunc) + '@#', Args);
end;

procedure TBasLine.InternalOnResized(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizedFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizedFunc) + '@#', Args);
end;

procedure TBasLine.InternalOnPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnPaintFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnPaintFunc) + '@#', Args);
end;

procedure TBasLine.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasLine.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
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

procedure TBasLine.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasLine.InternalOnDragLeave(Sender: TObject);
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
// Library Functions
//==============================================================================

// Error handling functions
function n_line_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.s := '';
  Result.p := nil;
end;

function s_line_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := lastErrorMsg;
  Result.p := nil;
end;

function s_line_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Code := Round(Args[0].n);
  Result.n := 0;
  Result.p := nil;
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_LINE: Result.s := 'Invalid line';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Create failed';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback';
    ERR_INVALID_COLOR: Result.s := 'Invalid color';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_line_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// Line creation functions
function p_line_new(var Args: array of TAsmData): TAsmData;
var
  L: TBasLine;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateParent(Args[0].p, 'line#') then Exit;

  try
    L := TBasLine.Create(nil);
    L.Parent := TFmxObject(Args[0].p);
    L.BasicEngine := ModuleEngine;
    L.ConsoleOutput := ModuleOutput;

    Result.p := Pointer(L);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(L, LINE_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'line#: ' + E.Message);
  end;
end;

function p_line_new_size(var Args: array of TAsmData): TAsmData;
var
  L: TBasLine;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateParent(Args[0].p, 'line#') then Exit;

  try
    L := TBasLine.Create(nil);
    L.Parent := TFmxObject(Args[0].p);
    L.Width := Args[1].n;
    L.Height := Args[2].n;
    L.BasicEngine := ModuleEngine;
    L.ConsoleOutput := ModuleOutput;

    Result.p := Pointer(L);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(L, LINE_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'line#: ' + E.Message);
  end;
end;

function p_line_new_full(var Args: array of TAsmData): TAsmData;
var
  L: TBasLine;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'line#') then Exit;

  try
    L := TBasLine.Create(nil);
    L.Parent := TFmxObject(Args[0].p);
    L.Position.X := Args[1].n;
    L.Position.Y := Args[2].n;
    L.Width := Args[3].n;
    L.Height := Args[4].n;
    L.BasicEngine := ModuleEngine;
    L.ConsoleOutput := ModuleOutput;

    Result.p := Pointer(L);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(L, LINE_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'line#: ' + E.Message);
  end;
end;

function n_line_free(var Args: array of TAsmData): TAsmData;
var
  L: TBasLine;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateLine(Args[0].p, 'line_free') then Exit;

  try
    L := TBasLine(Args[0].p);
    L.DisconnectEvents();
    L.Free();

//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(LINE_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_LINE, 'line_free: ' + E.Message);
  end;
end;

// Line-specific: LineType
function n_line_linetype_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_linetype') then Exit;
  try
    Result.n := LineTypeToInt(TBasLine(Args[0].p).LineType);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_linetype: ' + E.Message);
  end;
end;

function p_line_linetype_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_linetype#') then Exit;
  try
    TBasLine(Args[0].p).LineType := IntToLineType(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_linetype#: ' + E.Message);
  end;
end;

// Stroke functions
function s_line_stroke_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_stroke$') then Exit;
  try
    Result.s := TUtils.AlphaColorToStr(TBasLine(Args[0].p).Stroke.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_stroke$: ' + E.Message);
  end;
end;

function p_line_stroke_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_stroke#') then Exit;
  try
    TBasLine(Args[0].p).Stroke.Kind := TBrushKind.Solid;
    TBasLine(Args[0].p).Stroke.Color := TUtils.ColorToAlphaColor(Args[1].s);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_stroke#: ' + E.Message);
  end;
end;

function p_line_strokenone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_strokenone#') then Exit;
  try
    TBasLine(Args[0].p).Stroke.Kind := TBrushKind.None;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_strokenone#: ' + E.Message);
  end;
end;

function n_line_strokethickness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_strokethickness') then Exit;
  try
    Result.n := TBasLine(Args[0].p).Stroke.Thickness;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_strokethickness: ' + E.Message);
  end;
end;

function p_line_strokethickness_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_strokethickness#') then Exit;
  try
    TBasLine(Args[0].p).Stroke.Thickness := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_strokethickness#: ' + E.Message);
  end;
end;

function n_line_strokedash_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_strokedash') then Exit;
  try
    Result.n := StrokeDashToInt(TBasLine(Args[0].p).Stroke.Dash);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_strokedash: ' + E.Message);
  end;
end;

function p_line_strokedash_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_strokedash#') then Exit;
  try
    TBasLine(Args[0].p).Stroke.Dash := IntToStrokeDash(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_strokedash#: ' + E.Message);
  end;
end;

function n_line_strokecap_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_strokecap') then Exit;
  try
    Result.n := StrokeCapToInt(TBasLine(Args[0].p).Stroke.Cap);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_strokecap: ' + E.Message);
  end;
end;

function p_line_strokecap_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_strokecap#') then Exit;
  try
    TBasLine(Args[0].p).Stroke.Cap := IntToStrokeCap(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_strokecap#: ' + E.Message);
  end;
end;

function n_line_strokejoin_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_strokejoin') then Exit;
  try
    Result.n := StrokeJoinToInt(TBasLine(Args[0].p).Stroke.Join);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_strokejoin: ' + E.Message);
  end;
end;

function p_line_strokejoin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_strokejoin#') then Exit;
  try
    TBasLine(Args[0].p).Stroke.Join := IntToStrokeJoin(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_strokejoin#: ' + E.Message);
  end;
end;

// Position and Size functions
function n_line_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_x') then Exit;
  try
    Result.n := TBasLine(Args[0].p).Position.X;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_x: ' + E.Message);
  end;
end;

function p_line_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_x#') then Exit;
  try
    TBasLine(Args[0].p).Position.X := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_x#: ' + E.Message);
  end;
end;

function n_line_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_y') then Exit;
  try
    Result.n := TBasLine(Args[0].p).Position.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_y: ' + E.Message);
  end;
end;

function p_line_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_y#') then Exit;
  try
    TBasLine(Args[0].p).Position.Y := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_y#: ' + E.Message);
  end;
end;

function n_line_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_width') then Exit;
  try
    Result.n := TBasLine(Args[0].p).Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_width: ' + E.Message);
  end;
end;

function p_line_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_width#') then Exit;
  try
    TBasLine(Args[0].p).Width := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_width#: ' + E.Message);
  end;
end;

function n_line_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_height') then Exit;
  try
    Result.n := TBasLine(Args[0].p).Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_height: ' + E.Message);
  end;
end;

function p_line_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_height#') then Exit;
  try
    TBasLine(Args[0].p).Height := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_height#: ' + E.Message);
  end;
end;

function p_line_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_bounds#') then Exit;
  try
    TBasLine(Args[0].p).Position.X := Args[1].n;
    TBasLine(Args[0].p).Position.Y := Args[2].n;
    TBasLine(Args[0].p).Width := Args[3].n;
    TBasLine(Args[0].p).Height := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_bounds#: ' + E.Message);
  end;
end;

function p_line_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_size#') then Exit;
  try
    TBasLine(Args[0].p).Width := Args[1].n;
    TBasLine(Args[0].p).Height := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_size#: ' + E.Message);
  end;
end;

function p_line_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_move#') then Exit;
  try
    TBasLine(Args[0].p).Position.X := Args[1].n;
    TBasLine(Args[0].p).Position.Y := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_move#: ' + E.Message);
  end;
end;

// Alignment functions
function n_line_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_align') then Exit;
  try
    Result.n := AlignToInt(TBasLine(Args[0].p).Align);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_align: ' + E.Message);
  end;
end;

function p_line_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_align#') then Exit;
  try
    TBasLine(Args[0].p).Align := AlignFromInt(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_align#: ' + E.Message);
  end;
end;

// Margin functions
function n_line_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_marginleft') then Exit;
  try
    Result.n := TBasLine(Args[0].p).Margins.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_marginleft: ' + E.Message);
  end;
end;

function p_line_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_marginleft#') then Exit;
  try
    TBasLine(Args[0].p).Margins.Left := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_marginleft#: ' + E.Message);
  end;
end;

function n_line_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_margintop') then Exit;
  try
    Result.n := TBasLine(Args[0].p).Margins.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_margintop: ' + E.Message);
  end;
end;

function p_line_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_margintop#') then Exit;
  try
    TBasLine(Args[0].p).Margins.Top := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_margintop#: ' + E.Message);
  end;
end;

function n_line_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_marginright') then Exit;
  try
    Result.n := TBasLine(Args[0].p).Margins.Right;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_marginright: ' + E.Message);
  end;
end;

function p_line_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_marginright#') then Exit;
  try
    TBasLine(Args[0].p).Margins.Right := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_marginright#: ' + E.Message);
  end;
end;

function n_line_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_marginbottom') then Exit;
  try
    Result.n := TBasLine(Args[0].p).Margins.Bottom;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_marginbottom: ' + E.Message);
  end;
end;

function p_line_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_marginbottom#') then Exit;
  try
    TBasLine(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_marginbottom#: ' + E.Message);
  end;
end;

function p_line_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_margins#') then Exit;
  try
    TBasLine(Args[0].p).Margins.Left := Args[1].n;
    TBasLine(Args[0].p).Margins.Top := Args[2].n;
    TBasLine(Args[0].p).Margins.Right := Args[3].n;
    TBasLine(Args[0].p).Margins.Bottom := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_margins#: ' + E.Message);
  end;
end;

function p_line_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_margin#') then Exit;
  try
    TBasLine(Args[0].p).Margins.Left := Args[1].n;
    TBasLine(Args[0].p).Margins.Top := Args[1].n;
    TBasLine(Args[0].p).Margins.Right := Args[1].n;
    TBasLine(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_margin#: ' + E.Message);
  end;
end;

// Visibility and behavior functions
function n_line_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_visible') then Exit;
  try
    if TBasLine(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_visible: ' + E.Message);
  end;
end;

function p_line_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_visible#') then Exit;
  try
    TBasLine(Args[0].p).Visible := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_visible#: ' + E.Message);
  end;
end;

function n_line_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_enabled') then Exit;
  try
    if TBasLine(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_enabled: ' + E.Message);
  end;
end;

function p_line_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_enabled#') then Exit;
  try
    TBasLine(Args[0].p).Enabled := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_enabled#: ' + E.Message);
  end;
end;

function n_line_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_opacity') then Exit;
  try
    Result.n := TBasLine(Args[0].p).Opacity;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_opacity: ' + E.Message);
  end;
end;

function p_line_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_opacity#') then Exit;
  try
    TBasLine(Args[0].p).Opacity := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_opacity#: ' + E.Message);
  end;
end;

function n_line_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_hittest') then Exit;
  try
    if TBasLine(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_hittest: ' + E.Message);
  end;
end;

function p_line_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_hittest#') then Exit;
  try
    TBasLine(Args[0].p).HitTest := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_hittest#: ' + E.Message);
  end;
end;

// Tag and rotation functions
function n_line_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_tag') then Exit;
  try
    Result.n := TBasLine(Args[0].p).Tag;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_tag: ' + E.Message);
  end;
end;

function p_line_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_tag#') then Exit;
  try
    TBasLine(Args[0].p).Tag := Round(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_tag#: ' + E.Message);
  end;
end;

function n_line_rotation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateLine(Args[0].p, 'line_rotation') then Exit;
  try
    Result.n := TBasLine(Args[0].p).RotationAngle;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_rotation: ' + E.Message);
  end;
end;

function p_line_rotation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_rotation#') then Exit;
  try
    TBasLine(Args[0].p).RotationAngle := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_rotation#: ' + E.Message);
  end;
end;

// Parent and Z-order functions
function p_line_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_parent#') then Exit;
  try
    Result.p := TBasLine(Args[0].p).Parent;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_parent#: ' + E.Message);
  end;
end;

function p_line_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_parent#') then Exit;
  if not ValidateParent(Args[1].p, 'line_parent#') then Exit;
  try
    TBasLine(Args[0].p).Parent := TFmxObject(Args[1].p);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_parent#: ' + E.Message);
  end;
end;

function p_line_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_bringtofront#') then Exit;
  try
    TBasLine(Args[0].p).BringToFront;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_bringtofront#: ' + E.Message);
  end;
end;

function p_line_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_sendtoback#') then Exit;
  try
    TBasLine(Args[0].p).SendToBack;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_sendtoback#: ' + E.Message);
  end;
end;

// Invalidation
function p_line_invalidate(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_invalidate#') then Exit;
  try
    TBasLine(Args[0].p).Repaint;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_invalidate#: ' + E.Message);
  end;
end;

// Event callback functions
function p_line_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onclick#') then Exit;
  try
    TBasLine(Args[0].p).OnClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onclick#: ' + E.Message);
  end;
end;

function s_line_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onclick$') then Exit;
  try
    Result.s := TBasLine(Args[0].p).OnClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onclick$: ' + E.Message);
  end;
end;

function p_line_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_ondblclick#') then Exit;
  try
    TBasLine(Args[0].p).OnDblClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_ondblclick#: ' + E.Message);
  end;
end;

function s_line_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_ondblclick$') then Exit;
  try
    Result.s := TBasLine(Args[0].p).OnDblClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_ondblclick$: ' + E.Message);
  end;
end;

function p_line_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onmousedown#') then Exit;
  try
    TBasLine(Args[0].p).OnMouseDownFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onmousedown#: ' + E.Message);
  end;
end;

function s_line_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onmousedown$') then Exit;
  try
    Result.s := TBasLine(Args[0].p).OnMouseDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onmousedown$: ' + E.Message);
  end;
end;

function p_line_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onmouseup#') then Exit;
  try
    TBasLine(Args[0].p).OnMouseUpFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onmouseup#: ' + E.Message);
  end;
end;

function s_line_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onmouseup$') then Exit;
  try
    Result.s := TBasLine(Args[0].p).OnMouseUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onmouseup$: ' + E.Message);
  end;
end;

function p_line_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onmousemove#') then Exit;
  try
    TBasLine(Args[0].p).OnMouseMoveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onmousemove#: ' + E.Message);
  end;
end;

function s_line_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onmousemove$') then Exit;
  try
    Result.s := TBasLine(Args[0].p).OnMouseMoveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onmousemove$: ' + E.Message);
  end;
end;

function p_line_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onmouseenter#') then Exit;
  try
    TBasLine(Args[0].p).OnMouseEnterFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onmouseenter#: ' + E.Message);
  end;
end;

function s_line_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onmouseenter$') then Exit;
  try
    Result.s := TBasLine(Args[0].p).OnMouseEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onmouseenter$: ' + E.Message);
  end;
end;

function p_line_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onmouseleave#') then Exit;
  try
    TBasLine(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onmouseleave#: ' + E.Message);
  end;
end;

function s_line_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onmouseleave$') then Exit;
  try
    Result.s := TBasLine(Args[0].p).OnMouseLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onmouseleave$: ' + E.Message);
  end;
end;

function p_line_onmousewheel_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onmousewheel#') then Exit;
  try
    TBasLine(Args[0].p).OnMouseWheelFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onmousewheel#: ' + E.Message);
  end;
end;

function s_line_onmousewheel_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onmousewheel$') then Exit;
  try
    Result.s := TBasLine(Args[0].p).OnMouseWheelFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onmousewheel$: ' + E.Message);
  end;
end;

function p_line_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onresize#') then Exit;
  try
    TBasLine(Args[0].p).OnResizeFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onresize#: ' + E.Message);
  end;
end;

function s_line_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLine(Args[0].p, 'line_onresize$') then Exit;
  try
    Result.s := TBasLine(Args[0].p).OnResizeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'line_onresize$: ' + E.Message);
  end;
end;

function p_line_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLine(Args[0].p, 'line_clearcallbacks#') then Exit;

  try
    with TBasLine(Args[0].p) do
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
      SetError(ERR_OPERATION_FAILED, 'line_clearcallbacks#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterLineFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;

  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_line_error; Lib.Add('line_error@', Fn);
  Fn.Entry := @s_line_errormsg; Lib.Add('line_errormsg$@', Fn);
  Fn.Entry := @s_line_strerror; Lib.Add('line_strerror$@n', Fn);
  Fn.Entry := @n_line_clearerror; Lib.Add('line_clearerror@', Fn);

  // Line creation/destruction
  Fn.Entry := @p_line_new; Lib.Add('line#@#', Fn);
  Fn.Entry := @p_line_new_size; Lib.Add('line#@#nn', Fn);
  Fn.Entry := @p_line_new_full; Lib.Add('line#@#nnnn', Fn);
  Fn.Entry := @n_line_free; Lib.Add('line_free@#', Fn);

  // Line-specific: LineType
  Fn.Entry := @n_line_linetype_get; Lib.Add('line_linetype@#', Fn);
  Fn.Entry := @p_line_linetype_set; Lib.Add('line_linetype#@#n', Fn);

  // Stroke
  Fn.Entry := @s_line_stroke_get; Lib.Add('line_stroke$@#', Fn);
  Fn.Entry := @p_line_stroke_set; Lib.Add('line_stroke#@#$', Fn);
  Fn.Entry := @p_line_strokenone; Lib.Add('line_strokenone#@#', Fn);
  Fn.Entry := @n_line_strokethickness_get; Lib.Add('line_strokethickness@#', Fn);
  Fn.Entry := @p_line_strokethickness_set; Lib.Add('line_strokethickness#@#n', Fn);
  Fn.Entry := @n_line_strokedash_get; Lib.Add('line_strokedash@#', Fn);
  Fn.Entry := @p_line_strokedash_set; Lib.Add('line_strokedash#@#n', Fn);
  Fn.Entry := @n_line_strokecap_get; Lib.Add('line_strokecap@#', Fn);
  Fn.Entry := @p_line_strokecap_set; Lib.Add('line_strokecap#@#n', Fn);
  Fn.Entry := @n_line_strokejoin_get; Lib.Add('line_strokejoin@#', Fn);
  Fn.Entry := @p_line_strokejoin_set; Lib.Add('line_strokejoin#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_line_x_get; Lib.Add('line_x@#', Fn);
  Fn.Entry := @p_line_x_set; Lib.Add('line_x#@#n', Fn);
  Fn.Entry := @n_line_y_get; Lib.Add('line_y@#', Fn);
  Fn.Entry := @p_line_y_set; Lib.Add('line_y#@#n', Fn);
  Fn.Entry := @n_line_width_get; Lib.Add('line_width@#', Fn);
  Fn.Entry := @p_line_width_set; Lib.Add('line_width#@#n', Fn);
  Fn.Entry := @n_line_height_get; Lib.Add('line_height@#', Fn);
  Fn.Entry := @p_line_height_set; Lib.Add('line_height#@#n', Fn);
  Fn.Entry := @p_line_bounds_set; Lib.Add('line_bounds#@#nnnn', Fn);
  Fn.Entry := @p_line_size_set; Lib.Add('line_size#@#nn', Fn);
  Fn.Entry := @p_line_move_set; Lib.Add('line_move#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_line_align_get; Lib.Add('line_align@#', Fn);
  Fn.Entry := @p_line_align_set; Lib.Add('line_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_line_marginleft_get; Lib.Add('line_marginleft@#', Fn);
  Fn.Entry := @p_line_marginleft_set; Lib.Add('line_marginleft#@#n', Fn);
  Fn.Entry := @n_line_margintop_get; Lib.Add('line_margintop@#', Fn);
  Fn.Entry := @p_line_margintop_set; Lib.Add('line_margintop#@#n', Fn);
  Fn.Entry := @n_line_marginright_get; Lib.Add('line_marginright@#', Fn);
  Fn.Entry := @p_line_marginright_set; Lib.Add('line_marginright#@#n', Fn);
  Fn.Entry := @n_line_marginbottom_get; Lib.Add('line_marginbottom@#', Fn);
  Fn.Entry := @p_line_marginbottom_set; Lib.Add('line_marginbottom#@#n', Fn);
  Fn.Entry := @p_line_margins_set; Lib.Add('line_margins#@#nnnn', Fn);
  Fn.Entry := @p_line_margin_set; Lib.Add('line_margin#@#n', Fn);

  // Visibility and behavior
  Fn.Entry := @n_line_visible_get; Lib.Add('line_visible@#', Fn);
  Fn.Entry := @p_line_visible_set; Lib.Add('line_visible#@#n', Fn);
  Fn.Entry := @n_line_enabled_get; Lib.Add('line_enabled@#', Fn);
  Fn.Entry := @p_line_enabled_set; Lib.Add('line_enabled#@#n', Fn);
  Fn.Entry := @n_line_opacity_get; Lib.Add('line_opacity@#', Fn);
  Fn.Entry := @p_line_opacity_set; Lib.Add('line_opacity#@#n', Fn);
  Fn.Entry := @n_line_hittest_get; Lib.Add('line_hittest@#', Fn);
  Fn.Entry := @p_line_hittest_set; Lib.Add('line_hittest#@#n', Fn);

  // Tag and rotation
  Fn.Entry := @n_line_tag_get; Lib.Add('line_tag@#', Fn);
  Fn.Entry := @p_line_tag_set; Lib.Add('line_tag#@#n', Fn);
  Fn.Entry := @n_line_rotation_get; Lib.Add('line_rotation@#', Fn);
  Fn.Entry := @p_line_rotation_set; Lib.Add('line_rotation#@#n', Fn);

  // Parent
  Fn.Entry := @p_line_parent_get; Lib.Add('line_parent#@#', Fn);
  Fn.Entry := @p_line_parent_set; Lib.Add('line_parent#@##', Fn);
  Fn.Entry := @p_line_bringtofront; Lib.Add('line_bringtofront#@#', Fn);
  Fn.Entry := @p_line_sendtoback; Lib.Add('line_sendtoback#@#', Fn);

  // Invalidation
  Fn.Entry := @p_line_invalidate; Lib.Add('line_invalidate#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_line_onclick_set; Lib.Add('line_onclick#@#$', Fn);
  Fn.Entry := @s_line_onclick_get; Lib.Add('line_onclick$@#', Fn);
  Fn.Entry := @p_line_ondblclick_set; Lib.Add('line_ondblclick#@#$', Fn);
  Fn.Entry := @s_line_ondblclick_get; Lib.Add('line_ondblclick$@#', Fn);
  Fn.Entry := @p_line_onmousedown_set; Lib.Add('line_onmousedown#@#$', Fn);
  Fn.Entry := @s_line_onmousedown_get; Lib.Add('line_onmousedown$@#', Fn);
  Fn.Entry := @p_line_onmouseup_set; Lib.Add('line_onmouseup#@#$', Fn);
  Fn.Entry := @s_line_onmouseup_get; Lib.Add('line_onmouseup$@#', Fn);
  Fn.Entry := @p_line_onmousemove_set; Lib.Add('line_onmousemove#@#$', Fn);
  Fn.Entry := @s_line_onmousemove_get; Lib.Add('line_onmousemove$@#', Fn);
  Fn.Entry := @p_line_onmouseenter_set; Lib.Add('line_onmouseenter#@#$', Fn);
  Fn.Entry := @s_line_onmouseenter_get; Lib.Add('line_onmouseenter$@#', Fn);
  Fn.Entry := @p_line_onmouseleave_set; Lib.Add('line_onmouseleave#@#$', Fn);
  Fn.Entry := @s_line_onmouseleave_get; Lib.Add('line_onmouseleave$@#', Fn);
  Fn.Entry := @p_line_onmousewheel_set; Lib.Add('line_onmousewheel#@#$', Fn);
  Fn.Entry := @s_line_onmousewheel_get; Lib.Add('line_onmousewheel$@#', Fn);
  Fn.Entry := @p_line_onresize_set; Lib.Add('line_onresize#@#$', Fn);
  Fn.Entry := @s_line_onresize_get; Lib.Add('line_onresize$@#', Fn);
  Fn.Entry := @p_line_clearcallbacks; Lib.Add('line_clearcallbacks#@#', Fn);
end;

end.

