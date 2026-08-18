unit CalloutRectangleLib;

{******************************************************************************
  CalloutRectangleLib - Callout Rectangle Visual Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TCalloutRectangle wrapper functionality for
  creating and managing callout rectangle (speech bubble) visual controls
  in Plan9Basic programs.

  Function Count: 90 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All callouts are created at RUNTIME using TCalloutRectangle.Create with
  dynamic parent assignment.

  FEATURES:
  =========
  - Callout rectangle creation and lifecycle management
  - Callout pointer position, length, width, and offset
  - Fill color and style
  - Stroke (border) color, thickness, and style
  - Corner rounding (XRadius, YRadius)
  - Complete positioning and alignment
  - Full event support with BASIC callback integration

  CALLOUT POSITION:
  =================
  0 = Top (callout points upward from top edge)
  1 = Left (callout points leftward from left edge)
  2 = Bottom (callout points downward from bottom edge)
  3 = Right (callout points rightward from right edge)

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
    let frm# = form#("Callout Demo", 800, 600)

    ' Create a speech bubble callout
    let cb# = callout#(frm#, 50, 50, 200, 100)
    callout_fill#(cb#, "#3498db")
    callout_stroke#(cb#, "#2980b9")
    callout_calloutposition#(cb#, 2)  ' Bottom
    callout_calloutlength#(cb#, 20)
    callout_calloutwidth#(cb#, 30)
    callout_corners#(cb#, 10, 10)

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnCalloutClick(sender#)
      println "Callout clicked!"
    end function

    function OnCalloutMouseMove(sender#, x, y, shift$)
      println "Mouse at: " + stri$(x) + ", " + stri$(y)
    end function

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry;

type
  TBasCalloutRectangle = class(TCalloutRectangle)
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

procedure RegisterCalloutRectangleFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  CALLOUT_GC_TAG = 'BASIC_CALLOUT';
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_CALLOUT = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INVALID_CALLBACK = 5;
  ERR_INVALID_COLOR = 6;

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

  CALLOUT_TOP = 0;
  CALLOUT_LEFT = 1;
  CALLOUT_BOTTOM = 2;
  CALLOUT_RIGHT = 3;

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

function ValidateCallout(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_CALLOUT, FuncName + ': Nil callout pointer');
    Exit;
  end;

  try
    if not (IsHandleOf(P, TBasCalloutRectangle)) then
    begin
      SetError(ERR_INVALID_CALLOUT, FuncName + ': Invalid callout object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_CALLOUT, FuncName + ': Invalid callout pointer');
    Exit;
  end;

  ClearError;
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
    if not (IsHandleOf(P, TFmxObject)) then
    begin
      SetError(ERR_INVALID_PARENT, FuncName + ': Invalid parent object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_PARENT, FuncName + ': Invalid parent pointer');
    Exit;
  end;

  ClearError;
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

function IntToCalloutPosition(Value: Integer): TCalloutPosition;
begin
  case Value of
    CALLOUT_TOP: Result := TCalloutPosition.Top;
    CALLOUT_LEFT: Result := TCalloutPosition.Left;
    CALLOUT_BOTTOM: Result := TCalloutPosition.Bottom;
    CALLOUT_RIGHT: Result := TCalloutPosition.Right;
  else
    Result := TCalloutPosition.Bottom;
  end;
end;

function CalloutPositionToInt(Value: TCalloutPosition): Integer;
begin
  case Value of
    TCalloutPosition.Top: Result := CALLOUT_TOP;
    TCalloutPosition.Left: Result := CALLOUT_LEFT;
    TCalloutPosition.Bottom: Result := CALLOUT_BOTTOM;
    TCalloutPosition.Right: Result := CALLOUT_RIGHT;
  else
    Result := CALLOUT_BOTTOM;
  end;
end;

//==============================================================================
// TBasCalloutRectangle Implementation
//==============================================================================

constructor TBasCalloutRectangle.Create(AOwner: TComponent);
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

  HitTest := True;
end;

destructor TBasCalloutRectangle.Destroy;
begin
  UnregisterHandle(Self);
  DisconnectEvents;
  inherited Destroy;
end;

procedure TBasCalloutRectangle.DisconnectEvents;
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

function TBasCalloutRectangle.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

procedure TBasCalloutRectangle.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  RetVal: TAsmData;
  i: Integer;
begin
  if UnitGC.GlobalCallbackBusy then Exit;

  if not Assigned(FBasicEngine) then Exit;
  if not Assigned(FConsoleOutput) then Exit;
  if FuncSignature = '' then Exit;

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
        FConsoleOutput.Add('*** Callout Event Callback Error ***');
        FConsoleOutput.Add('Function: ' + FuncSignature);
        FConsoleOutput.Add('Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

//function TBasCalloutRectangle.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
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
//        FConsoleOutput.Add('*** Callout Event Callback Error ***');
//        FConsoleOutput.Add('Function: ' + FuncSignature);
//        FConsoleOutput.Add('Error: ' + E.Message);
//      end;
//    end;
//  finally
//    UnitGC.SkipProcessMessages := False;
//    UnitGC.GlobalCallbackBusy := False;
//  end;
//end;

procedure TBasCalloutRectangle.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    OnClick := InternalOnClick
  else
    OnClick := nil;
end;

procedure TBasCalloutRectangle.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    OnDblClick := InternalOnDblClick
  else
    OnDblClick := nil;
end;

procedure TBasCalloutRectangle.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    OnMouseDown := InternalOnMouseDown
  else
    OnMouseDown := nil;
end;

procedure TBasCalloutRectangle.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    OnMouseUp := InternalOnMouseUp
  else
    OnMouseUp := nil;
end;

procedure TBasCalloutRectangle.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    OnMouseMove := InternalOnMouseMove
  else
    OnMouseMove := nil;
end;

procedure TBasCalloutRectangle.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    OnMouseEnter := InternalOnMouseEnter
  else
    OnMouseEnter := nil;
end;

procedure TBasCalloutRectangle.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    OnMouseLeave := InternalOnMouseLeave
  else
    OnMouseLeave := nil;
end;

procedure TBasCalloutRectangle.SetOnMouseWheelFunc(const Value: String);
begin
  FOnMouseWheelFunc := Value;
  if Value <> '' then
    OnMouseWheel := InternalOnMouseWheel
  else
    OnMouseWheel := nil;
end;

procedure TBasCalloutRectangle.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    OnResize := InternalOnResize
  else
    OnResize := nil;
end;

procedure TBasCalloutRectangle.SetOnResizedFunc(const Value: String);
begin
  FOnResizedFunc := Value;
  if Value <> '' then
    OnResized := InternalOnResized
  else
    OnResized := nil;
end;

procedure TBasCalloutRectangle.SetOnPaintFunc(const Value: String);
begin
  FOnPaintFunc := Value;
  if Value <> '' then
    OnPainting := InternalOnPaint
  else
    OnPainting := nil;
end;

procedure TBasCalloutRectangle.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    OnDragEnter := InternalOnDragEnter
  else
    OnDragEnter := nil;
end;

procedure TBasCalloutRectangle.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    OnDragOver := InternalOnDragOver
  else
    OnDragOver := nil;
end;

procedure TBasCalloutRectangle.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    OnDragDrop := InternalOnDragDrop
  else
    OnDragDrop := nil;
end;

procedure TBasCalloutRectangle.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    OnDragLeave := InternalOnDragLeave
  else
    OnDragLeave := nil;
end;

procedure TBasCalloutRectangle.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnClickFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnClickFunc) + '@#', Args);
end;

procedure TBasCalloutRectangle.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDblClickFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDblClickFunc) + '@#', Args);
end;

procedure TBasCalloutRectangle.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasCalloutRectangle.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasCalloutRectangle.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
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

procedure TBasCalloutRectangle.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseEnterFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseEnterFunc) + '@#', Args);
end;

procedure TBasCalloutRectangle.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseLeaveFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseLeaveFunc) + '@#', Args);
end;

procedure TBasCalloutRectangle.InternalOnMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
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

procedure TBasCalloutRectangle.InternalOnResize(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizeFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizeFunc) + '@#', Args);
end;

procedure TBasCalloutRectangle.InternalOnResized(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizedFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizedFunc) + '@#', Args);
end;

procedure TBasCalloutRectangle.InternalOnPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnPaintFunc = '' then Exit;
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnPaintFunc) + '@#', Args);
end;

procedure TBasCalloutRectangle.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasCalloutRectangle.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
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

procedure TBasCalloutRectangle.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
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

procedure TBasCalloutRectangle.InternalOnDragLeave(Sender: TObject);
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

function n_callout_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.s := '';
  Result.p := nil;
end;

function s_callout_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := lastErrorMsg;
  Result.p := nil;
end;

function s_callout_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Code := Round(Args[0].n);
  Result.n := 0;
  Result.p := nil;
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_CALLOUT: Result.s := 'Invalid callout';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Create failed';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback';
    ERR_INVALID_COLOR: Result.s := 'Invalid color';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_callout_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

//==============================================================================
// Library Functions - Creation/Destruction
//==============================================================================

function p_callout_new(var Args: array of TAsmData): TAsmData;
var
  C: TBasCalloutRectangle;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'callout#') then Exit;

  try
    C := TBasCalloutRectangle.Create(nil);
    C.Parent := TFmxObject(Args[0].p);
    C.BasicEngine := ModuleEngine;
    C.ConsoleOutput := ModuleOutput;

    Result.p := Pointer(C);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(C, CALLOUT_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'callout#: ' + E.Message);
  end;
end;

function p_callout_new_size(var Args: array of TAsmData): TAsmData;
var
  C: TBasCalloutRectangle;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'callout#') then Exit;

  try
    C := TBasCalloutRectangle.Create(nil);
    C.Parent := TFmxObject(Args[0].p);
    C.Width := Args[1].n;
    C.Height := Args[2].n;
    C.BasicEngine := ModuleEngine;
    C.ConsoleOutput := ModuleOutput;

    Result.p := Pointer(C);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(C, CALLOUT_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'callout#: ' + E.Message);
  end;
end;

function p_callout_new_full(var Args: array of TAsmData): TAsmData;
var
  C: TBasCalloutRectangle;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'callout#') then Exit;

  try
    C := TBasCalloutRectangle.Create(nil);
    C.Parent := TFmxObject(Args[0].p);
    C.Position.X := Args[1].n;
    C.Position.Y := Args[2].n;
    C.Width := Args[3].n;
    C.Height := Args[4].n;
    C.BasicEngine := ModuleEngine;
    C.ConsoleOutput := ModuleOutput;

    Result.p := Pointer(C);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(C, CALLOUT_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'callout#: ' + E.Message);
  end;
end;

function n_callout_free(var Args: array of TAsmData): TAsmData;
var
  C: TBasCalloutRectangle;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateCallout(Args[0].p, 'callout_free') then Exit;

  try
    C := TBasCalloutRectangle(Args[0].p);
    C.DisconnectEvents();
    C.Free();

//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(CALLOUT_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_CALLOUT, 'callout_free: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Callout Specific Properties
//==============================================================================

function n_callout_calloutlength_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_calloutlength') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).CalloutLength;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_calloutlength: ' + E.Message);
  end;
end;

function p_callout_calloutlength_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_calloutlength#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).CalloutLength := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_calloutlength#: ' + E.Message);
  end;
end;

function n_callout_calloutwidth_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_calloutwidth') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).CalloutWidth;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_calloutwidth: ' + E.Message);
  end;
end;

function p_callout_calloutwidth_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_calloutwidth#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).CalloutWidth := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_calloutwidth#: ' + E.Message);
  end;
end;

function n_callout_calloutposition_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_calloutposition') then Exit;
  try
    Result.n := CalloutPositionToInt(TBasCalloutRectangle(Args[0].p).CalloutPosition);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_calloutposition: ' + E.Message);
  end;
end;

function p_callout_calloutposition_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_calloutposition#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).CalloutPosition := IntToCalloutPosition(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_calloutposition#: ' + E.Message);
  end;
end;

function n_callout_calloutoffset_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_calloutoffset') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).CalloutOffset;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_calloutoffset: ' + E.Message);
  end;
end;

function p_callout_calloutoffset_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_calloutoffset#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).CalloutOffset := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_calloutoffset#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Fill
//==============================================================================

function s_callout_fill_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_fill$') then Exit;
  try
    Result.s := TUtils.AlphaColorToStr(TBasCalloutRectangle(Args[0].p).Fill.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_fill$: ' + E.Message);
  end;
end;

function p_callout_fill_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_fill#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Fill.Kind := TBrushKind.Solid;
    TBasCalloutRectangle(Args[0].p).Fill.Color := TUtils.ColorToAlphaColor(Args[1].s);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_fill#: ' + E.Message);
  end;
end;

function p_callout_fillnone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_fillnone#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Fill.Kind := TBrushKind.None;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_fillnone#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Stroke
//==============================================================================

function s_callout_stroke_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_stroke$') then Exit;
  try
    Result.s := TUtils.AlphaColorToStr(TBasCalloutRectangle(Args[0].p).Stroke.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_stroke$: ' + E.Message);
  end;
end;

function p_callout_stroke_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_stroke#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Stroke.Kind := TBrushKind.Solid;
    TBasCalloutRectangle(Args[0].p).Stroke.Color := TUtils.ColorToAlphaColor(Args[1].s);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_stroke#: ' + E.Message);
  end;
end;

function p_callout_strokenone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_strokenone#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Stroke.Kind := TBrushKind.None;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_strokenone#: ' + E.Message);
  end;
end;

function n_callout_strokethickness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_strokethickness') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).Stroke.Thickness;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_strokethickness: ' + E.Message);
  end;
end;

function p_callout_strokethickness_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_strokethickness#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Stroke.Thickness := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_strokethickness#: ' + E.Message);
  end;
end;

function n_callout_strokedash_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_strokedash') then Exit;
  try
    Result.n := StrokeDashToInt(TBasCalloutRectangle(Args[0].p).Stroke.Dash);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_strokedash: ' + E.Message);
  end;
end;

function p_callout_strokedash_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_strokedash#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Stroke.Dash := IntToStrokeDash(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_strokedash#: ' + E.Message);
  end;
end;

function n_callout_strokecap_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_strokecap') then Exit;
  try
    Result.n := StrokeCapToInt(TBasCalloutRectangle(Args[0].p).Stroke.Cap);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_strokecap: ' + E.Message);
  end;
end;

function p_callout_strokecap_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_strokecap#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Stroke.Cap := IntToStrokeCap(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_strokecap#: ' + E.Message);
  end;
end;

function n_callout_strokejoin_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_strokejoin') then Exit;
  try
    Result.n := StrokeJoinToInt(TBasCalloutRectangle(Args[0].p).Stroke.Join);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_strokejoin: ' + E.Message);
  end;
end;

function p_callout_strokejoin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_strokejoin#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Stroke.Join := IntToStrokeJoin(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_strokejoin#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Corner Radius
//==============================================================================

function n_callout_xradius_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_xradius') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).XRadius;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_xradius: ' + E.Message);
  end;
end;

function p_callout_xradius_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_xradius#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).XRadius := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_xradius#: ' + E.Message);
  end;
end;

function n_callout_yradius_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_yradius') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).YRadius;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_yradius: ' + E.Message);
  end;
end;

function p_callout_yradius_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_yradius#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).YRadius := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_yradius#: ' + E.Message);
  end;
end;

function p_callout_corners_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_corners#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).XRadius := Args[1].n;
    TBasCalloutRectangle(Args[0].p).YRadius := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_corners#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Position and Size
//==============================================================================

function n_callout_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_x') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).Position.X;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_x: ' + E.Message);
  end;
end;

function p_callout_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_x#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Position.X := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_x#: ' + E.Message);
  end;
end;

function n_callout_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_y') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).Position.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_y: ' + E.Message);
  end;
end;

function p_callout_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_y#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Position.Y := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_y#: ' + E.Message);
  end;
end;

function n_callout_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_width') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_width: ' + E.Message);
  end;
end;

function p_callout_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_width#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Width := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_width#: ' + E.Message);
  end;
end;

function n_callout_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_height') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_height: ' + E.Message);
  end;
end;

function p_callout_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_height#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Height := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_height#: ' + E.Message);
  end;
end;

function p_callout_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_bounds#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Position.X := Args[1].n;
    TBasCalloutRectangle(Args[0].p).Position.Y := Args[2].n;
    TBasCalloutRectangle(Args[0].p).Width := Args[3].n;
    TBasCalloutRectangle(Args[0].p).Height := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_bounds#: ' + E.Message);
  end;
end;

function p_callout_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_size#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Width := Args[1].n;
    TBasCalloutRectangle(Args[0].p).Height := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_size#: ' + E.Message);
  end;
end;

function p_callout_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_move#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Position.X := Args[1].n;
    TBasCalloutRectangle(Args[0].p).Position.Y := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_move#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Alignment
//==============================================================================

function n_callout_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_align') then Exit;
  try
    Result.n := AlignToInt(TBasCalloutRectangle(Args[0].p).Align);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_align: ' + E.Message);
  end;
end;

function p_callout_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_align#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Align := IntToAlign(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_align#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Margins
//==============================================================================

function n_callout_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_marginleft') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).Margins.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_marginleft: ' + E.Message);
  end;
end;

function p_callout_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_marginleft#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Margins.Left := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_marginleft#: ' + E.Message);
  end;
end;

function n_callout_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_margintop') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).Margins.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_margintop: ' + E.Message);
  end;
end;

function p_callout_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_margintop#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Margins.Top := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_margintop#: ' + E.Message);
  end;
end;

function n_callout_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_marginright') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).Margins.Right;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_marginright: ' + E.Message);
  end;
end;

function p_callout_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_marginright#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Margins.Right := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_marginright#: ' + E.Message);
  end;
end;

function n_callout_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_marginbottom') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).Margins.Bottom;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_marginbottom: ' + E.Message);
  end;
end;

function p_callout_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_marginbottom#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_marginbottom#: ' + E.Message);
  end;
end;

function p_callout_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_margins#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Margins.Left := Args[1].n;
    TBasCalloutRectangle(Args[0].p).Margins.Top := Args[2].n;
    TBasCalloutRectangle(Args[0].p).Margins.Right := Args[3].n;
    TBasCalloutRectangle(Args[0].p).Margins.Bottom := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_margins#: ' + E.Message);
  end;
end;

function p_callout_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_margin#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Margins.Left := Args[1].n;
    TBasCalloutRectangle(Args[0].p).Margins.Top := Args[1].n;
    TBasCalloutRectangle(Args[0].p).Margins.Right := Args[1].n;
    TBasCalloutRectangle(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_margin#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Visibility and Behavior
//==============================================================================

function n_callout_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_visible') then Exit;
  try
    if TBasCalloutRectangle(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_visible: ' + E.Message);
  end;
end;

function p_callout_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_visible#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Visible := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_visible#: ' + E.Message);
  end;
end;

function n_callout_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_enabled') then Exit;
  try
    if TBasCalloutRectangle(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_enabled: ' + E.Message);
  end;
end;

function p_callout_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_enabled#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Enabled := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_enabled#: ' + E.Message);
  end;
end;

function n_callout_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_opacity') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).Opacity;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_opacity: ' + E.Message);
  end;
end;

function p_callout_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_opacity#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Opacity := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_opacity#: ' + E.Message);
  end;
end;

function n_callout_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_hittest') then Exit;
  try
    if TBasCalloutRectangle(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_hittest: ' + E.Message);
  end;
end;

function p_callout_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_hittest#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).HitTest := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_hittest#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Tag and Rotation
//==============================================================================

function n_callout_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_tag') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).Tag;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_tag: ' + E.Message);
  end;
end;

function p_callout_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_tag#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Tag := Round(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_tag#: ' + E.Message);
  end;
end;

function n_callout_rotation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateCallout(Args[0].p, 'callout_rotation') then Exit;
  try
    Result.n := TBasCalloutRectangle(Args[0].p).RotationAngle;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_rotation: ' + E.Message);
  end;
end;

function p_callout_rotation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_rotation#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).RotationAngle := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_rotation#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Parent and Z-Order
//==============================================================================

function p_callout_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_parent#') then Exit;
  try
    Result.p := TBasCalloutRectangle(Args[0].p).Parent;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_parent#: ' + E.Message);
  end;
end;

function p_callout_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_parent#') then Exit;
  if not ValidateParent(Args[1].p, 'callout_parent#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Parent := TFmxObject(Args[1].p);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_parent#: ' + E.Message);
  end;
end;

function p_callout_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_bringtofront#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).BringToFront;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_bringtofront#: ' + E.Message);
  end;
end;

function p_callout_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_sendtoback#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).SendToBack;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_sendtoback#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Invalidation
//==============================================================================

function p_callout_invalidate(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_invalidate#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).Repaint;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_invalidate#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Event Callbacks
//==============================================================================

function p_callout_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onclick#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).OnClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onclick#: ' + E.Message);
  end;
end;

function s_callout_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onclick$') then Exit;
  try
    Result.s := TBasCalloutRectangle(Args[0].p).OnClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onclick$: ' + E.Message);
  end;
end;

function p_callout_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_ondblclick#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).OnDblClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_ondblclick#: ' + E.Message);
  end;
end;

function s_callout_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_ondblclick$') then Exit;
  try
    Result.s := TBasCalloutRectangle(Args[0].p).OnDblClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_ondblclick$: ' + E.Message);
  end;
end;

function p_callout_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onmousedown#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).OnMouseDownFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onmousedown#: ' + E.Message);
  end;
end;

function s_callout_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onmousedown$') then Exit;
  try
    Result.s := TBasCalloutRectangle(Args[0].p).OnMouseDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onmousedown$: ' + E.Message);
  end;
end;

function p_callout_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onmouseup#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).OnMouseUpFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onmouseup#: ' + E.Message);
  end;
end;

function s_callout_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onmouseup$') then Exit;
  try
    Result.s := TBasCalloutRectangle(Args[0].p).OnMouseUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onmouseup$: ' + E.Message);
  end;
end;

function p_callout_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onmousemove#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).OnMouseMoveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onmousemove#: ' + E.Message);
  end;
end;

function s_callout_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onmousemove$') then Exit;
  try
    Result.s := TBasCalloutRectangle(Args[0].p).OnMouseMoveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onmousemove$: ' + E.Message);
  end;
end;

function p_callout_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onmouseenter#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).OnMouseEnterFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onmouseenter#: ' + E.Message);
  end;
end;

function s_callout_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onmouseenter$') then Exit;
  try
    Result.s := TBasCalloutRectangle(Args[0].p).OnMouseEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onmouseenter$: ' + E.Message);
  end;
end;

function p_callout_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onmouseleave#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onmouseleave#: ' + E.Message);
  end;
end;

function s_callout_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onmouseleave$') then Exit;
  try
    Result.s := TBasCalloutRectangle(Args[0].p).OnMouseLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onmouseleave$: ' + E.Message);
  end;
end;

function p_callout_onmousewheel_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onmousewheel#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).OnMouseWheelFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onmousewheel#: ' + E.Message);
  end;
end;

function s_callout_onmousewheel_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onmousewheel$') then Exit;
  try
    Result.s := TBasCalloutRectangle(Args[0].p).OnMouseWheelFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onmousewheel$: ' + E.Message);
  end;
end;

function p_callout_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onresize#') then Exit;
  try
    TBasCalloutRectangle(Args[0].p).OnResizeFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onresize#: ' + E.Message);
  end;
end;

function s_callout_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateCallout(Args[0].p, 'callout_onresize$') then Exit;
  try
    Result.s := TBasCalloutRectangle(Args[0].p).OnResizeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'callout_onresize$: ' + E.Message);
  end;
end;

function p_callout_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateCallout(Args[0].p, 'callout_clearcallbacks#') then Exit;

  try
    with TBasCalloutRectangle(Args[0].p) do
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
      SetError(ERR_OPERATION_FAILED, 'callout_clearcallbacks#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterCalloutRectangleFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;

  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_callout_error; Lib.Add('callout_error@', Fn);
  Fn.Entry := @s_callout_errormsg; Lib.Add('callout_errormsg$@', Fn);
  Fn.Entry := @s_callout_strerror; Lib.Add('callout_strerror$@n', Fn);
  Fn.Entry := @n_callout_clearerror; Lib.Add('callout_clearerror@', Fn);

  // Callout creation/destruction
  Fn.Entry := @p_callout_new; Lib.Add('callout#@#', Fn);
  Fn.Entry := @p_callout_new_size; Lib.Add('callout#@#nn', Fn);
  Fn.Entry := @p_callout_new_full; Lib.Add('callout#@#nnnn', Fn);
  Fn.Entry := @n_callout_free; Lib.Add('callout_free@#', Fn);

  // Callout-specific properties
  Fn.Entry := @n_callout_calloutlength_get; Lib.Add('callout_calloutlength@#', Fn);
  Fn.Entry := @p_callout_calloutlength_set; Lib.Add('callout_calloutlength#@#n', Fn);
  Fn.Entry := @n_callout_calloutwidth_get; Lib.Add('callout_calloutwidth@#', Fn);
  Fn.Entry := @p_callout_calloutwidth_set; Lib.Add('callout_calloutwidth#@#n', Fn);
  Fn.Entry := @n_callout_calloutposition_get; Lib.Add('callout_calloutposition@#', Fn);
  Fn.Entry := @p_callout_calloutposition_set; Lib.Add('callout_calloutposition#@#n', Fn);
  Fn.Entry := @n_callout_calloutoffset_get; Lib.Add('callout_calloutoffset@#', Fn);
  Fn.Entry := @p_callout_calloutoffset_set; Lib.Add('callout_calloutoffset#@#n', Fn);

  // Fill
  Fn.Entry := @s_callout_fill_get; Lib.Add('callout_fill$@#', Fn);
  Fn.Entry := @p_callout_fill_set; Lib.Add('callout_fill#@#$', Fn);
  Fn.Entry := @p_callout_fillnone; Lib.Add('callout_fillnone#@#', Fn);

  // Stroke
  Fn.Entry := @s_callout_stroke_get; Lib.Add('callout_stroke$@#', Fn);
  Fn.Entry := @p_callout_stroke_set; Lib.Add('callout_stroke#@#$', Fn);
  Fn.Entry := @p_callout_strokenone; Lib.Add('callout_strokenone#@#', Fn);
  Fn.Entry := @n_callout_strokethickness_get; Lib.Add('callout_strokethickness@#', Fn);
  Fn.Entry := @p_callout_strokethickness_set; Lib.Add('callout_strokethickness#@#n', Fn);
  Fn.Entry := @n_callout_strokedash_get; Lib.Add('callout_strokedash@#', Fn);
  Fn.Entry := @p_callout_strokedash_set; Lib.Add('callout_strokedash#@#n', Fn);
  Fn.Entry := @n_callout_strokecap_get; Lib.Add('callout_strokecap@#', Fn);
  Fn.Entry := @p_callout_strokecap_set; Lib.Add('callout_strokecap#@#n', Fn);
  Fn.Entry := @n_callout_strokejoin_get; Lib.Add('callout_strokejoin@#', Fn);
  Fn.Entry := @p_callout_strokejoin_set; Lib.Add('callout_strokejoin#@#n', Fn);

  // Corner radius
  Fn.Entry := @n_callout_xradius_get; Lib.Add('callout_xradius@#', Fn);
  Fn.Entry := @p_callout_xradius_set; Lib.Add('callout_xradius#@#n', Fn);
  Fn.Entry := @n_callout_yradius_get; Lib.Add('callout_yradius@#', Fn);
  Fn.Entry := @p_callout_yradius_set; Lib.Add('callout_yradius#@#n', Fn);
  Fn.Entry := @p_callout_corners_set; Lib.Add('callout_corners#@#nn', Fn);

  // Position and Size
  Fn.Entry := @n_callout_x_get; Lib.Add('callout_x@#', Fn);
  Fn.Entry := @p_callout_x_set; Lib.Add('callout_x#@#n', Fn);
  Fn.Entry := @n_callout_y_get; Lib.Add('callout_y@#', Fn);
  Fn.Entry := @p_callout_y_set; Lib.Add('callout_y#@#n', Fn);
  Fn.Entry := @n_callout_width_get; Lib.Add('callout_width@#', Fn);
  Fn.Entry := @p_callout_width_set; Lib.Add('callout_width#@#n', Fn);
  Fn.Entry := @n_callout_height_get; Lib.Add('callout_height@#', Fn);
  Fn.Entry := @p_callout_height_set; Lib.Add('callout_height#@#n', Fn);
  Fn.Entry := @p_callout_bounds_set; Lib.Add('callout_bounds#@#nnnn', Fn);
  Fn.Entry := @p_callout_size_set; Lib.Add('callout_size#@#nn', Fn);
  Fn.Entry := @p_callout_move_set; Lib.Add('callout_move#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_callout_align_get; Lib.Add('callout_align@#', Fn);
  Fn.Entry := @p_callout_align_set; Lib.Add('callout_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_callout_marginleft_get; Lib.Add('callout_marginleft@#', Fn);
  Fn.Entry := @p_callout_marginleft_set; Lib.Add('callout_marginleft#@#n', Fn);
  Fn.Entry := @n_callout_margintop_get; Lib.Add('callout_margintop@#', Fn);
  Fn.Entry := @p_callout_margintop_set; Lib.Add('callout_margintop#@#n', Fn);
  Fn.Entry := @n_callout_marginright_get; Lib.Add('callout_marginright@#', Fn);
  Fn.Entry := @p_callout_marginright_set; Lib.Add('callout_marginright#@#n', Fn);
  Fn.Entry := @n_callout_marginbottom_get; Lib.Add('callout_marginbottom@#', Fn);
  Fn.Entry := @p_callout_marginbottom_set; Lib.Add('callout_marginbottom#@#n', Fn);
  Fn.Entry := @p_callout_margins_set; Lib.Add('callout_margins#@#nnnn', Fn);
  Fn.Entry := @p_callout_margin_set; Lib.Add('callout_margin#@#n', Fn);

  // Visibility and behavior
  Fn.Entry := @n_callout_visible_get; Lib.Add('callout_visible@#', Fn);
  Fn.Entry := @p_callout_visible_set; Lib.Add('callout_visible#@#n', Fn);
  Fn.Entry := @n_callout_enabled_get; Lib.Add('callout_enabled@#', Fn);
  Fn.Entry := @p_callout_enabled_set; Lib.Add('callout_enabled#@#n', Fn);
  Fn.Entry := @n_callout_opacity_get; Lib.Add('callout_opacity@#', Fn);
  Fn.Entry := @p_callout_opacity_set; Lib.Add('callout_opacity#@#n', Fn);
  Fn.Entry := @n_callout_hittest_get; Lib.Add('callout_hittest@#', Fn);
  Fn.Entry := @p_callout_hittest_set; Lib.Add('callout_hittest#@#n', Fn);

  // Tag and rotation
  Fn.Entry := @n_callout_tag_get; Lib.Add('callout_tag@#', Fn);
  Fn.Entry := @p_callout_tag_set; Lib.Add('callout_tag#@#n', Fn);
  Fn.Entry := @n_callout_rotation_get; Lib.Add('callout_rotation@#', Fn);
  Fn.Entry := @p_callout_rotation_set; Lib.Add('callout_rotation#@#n', Fn);

  // Parent
  Fn.Entry := @p_callout_parent_get; Lib.Add('callout_parent#@#', Fn);
  Fn.Entry := @p_callout_parent_set; Lib.Add('callout_parent#@##', Fn);
  Fn.Entry := @p_callout_bringtofront; Lib.Add('callout_bringtofront#@#', Fn);
  Fn.Entry := @p_callout_sendtoback; Lib.Add('callout_sendtoback#@#', Fn);

  // Invalidation
  Fn.Entry := @p_callout_invalidate; Lib.Add('callout_invalidate#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_callout_onclick_set; Lib.Add('callout_onclick#@#$', Fn);
  Fn.Entry := @s_callout_onclick_get; Lib.Add('callout_onclick$@#', Fn);
  Fn.Entry := @p_callout_ondblclick_set; Lib.Add('callout_ondblclick#@#$', Fn);
  Fn.Entry := @s_callout_ondblclick_get; Lib.Add('callout_ondblclick$@#', Fn);
  Fn.Entry := @p_callout_onmousedown_set; Lib.Add('callout_onmousedown#@#$', Fn);
  Fn.Entry := @s_callout_onmousedown_get; Lib.Add('callout_onmousedown$@#', Fn);
  Fn.Entry := @p_callout_onmouseup_set; Lib.Add('callout_onmouseup#@#$', Fn);
  Fn.Entry := @s_callout_onmouseup_get; Lib.Add('callout_onmouseup$@#', Fn);
  Fn.Entry := @p_callout_onmousemove_set; Lib.Add('callout_onmousemove#@#$', Fn);
  Fn.Entry := @s_callout_onmousemove_get; Lib.Add('callout_onmousemove$@#', Fn);
  Fn.Entry := @p_callout_onmouseenter_set; Lib.Add('callout_onmouseenter#@#$', Fn);
  Fn.Entry := @s_callout_onmouseenter_get; Lib.Add('callout_onmouseenter$@#', Fn);
  Fn.Entry := @p_callout_onmouseleave_set; Lib.Add('callout_onmouseleave#@#$', Fn);
  Fn.Entry := @s_callout_onmouseleave_get; Lib.Add('callout_onmouseleave$@#', Fn);
  Fn.Entry := @p_callout_onmousewheel_set; Lib.Add('callout_onmousewheel#@#$', Fn);
  Fn.Entry := @s_callout_onmousewheel_get; Lib.Add('callout_onmousewheel$@#', Fn);
  Fn.Entry := @p_callout_onresize_set; Lib.Add('callout_onresize#@#$', Fn);
  Fn.Entry := @s_callout_onresize_get; Lib.Add('callout_onresize$@#', Fn);
  Fn.Entry := @p_callout_clearcallbacks; Lib.Add('callout_clearcallbacks#@#', Fn);
end;

end.

