unit PieLib;

{ ******************************************************************************
  PieLib - Pie Visual Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TPie wrapper functionality.
  Function Count: 77 functions

  Copyright (c) 2024-2025 Plan9Basic Project
  ****************************************************************************** }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry;

type
  TBasPie = class(TPie)
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
    function ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;

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

procedure RegisterPieFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  PIE_GC_TAG = 'BASIC_PIE';
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_PIE = 1;
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

function ValidatePie(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_PIE, FuncName + ': Nil pie pointer');
    Exit;
  end;
  if not(IsHandleOf(P, TBasPie)) then
  begin
    SetError(ERR_INVALID_PIE, FuncName + ': Not a pie object');
    Exit;
  end;
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
  if not(TObject(P) is TFmxObject) then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': Not a valid parent object');
    Exit;
  end;
  Result := True;
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
  if ssCommand in Shift then
    Result := Result + 'M';
  if ssLeft in Shift then
    Result := Result + 'L';
  if ssRight in Shift then
    Result := Result + 'R';
  if ssMiddle in Shift then
    Result := Result + 'X';
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
    CAP_ROUND: Result := TStrokeCap.Round;
  else
    Result := TStrokeCap.Flat;
  end;
end;

function StrokeCapToInt(Value: TStrokeCap): Integer;
begin
  case Value of
    TStrokeCap.Round: Result := CAP_ROUND;
  else
    Result := CAP_FLAT;
  end;
end;

function IntToStrokeJoin(Value: Integer): TStrokeJoin;
begin
  case Value of
    JOIN_ROUND: Result := TStrokeJoin.Round;
    JOIN_BEVEL: Result := TStrokeJoin.Bevel;
  else
    Result := TStrokeJoin.Miter;
  end;
end;

function StrokeJoinToInt(Value: TStrokeJoin): Integer;
begin
  case Value of
    TStrokeJoin.Round: Result := JOIN_ROUND;
    TStrokeJoin.Bevel: Result := JOIN_BEVEL;
  else
    Result := JOIN_MITER;
  end;
end;

function IntToAlign(Value: Integer): TAlignLayout;
begin
  case Value of
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

function AlignToInt(Align: TAlignLayout): Integer;
begin
  case Align of
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

// TBasPie Implementation

constructor TBasPie.Create(AOwner: TComponent);
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
end;

destructor TBasPie.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectEvents();
  inherited Destroy();
end;

procedure TBasPie.DisconnectEvents();
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

function TBasPie.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

procedure TBasPie.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
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
      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs, RetType, RetVal);
    except
      on E: Exception do
      begin
        FConsoleOutput.Add('*** Pie Event Callback Error ***');
        FConsoleOutput.Add('Function: ' + FuncSignature);
        FConsoleOutput.Add('Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

function TBasPie.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  i: Integer;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
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
      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs, RetType, Result);
    except
      on E: Exception do
      begin
        FConsoleOutput.Add('*** Pie Event Callback Error ***');
        FConsoleOutput.Add('Function: ' + FuncSignature);
        FConsoleOutput.Add('Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

procedure TBasPie.InternalOnClick(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
  Signature: String;
begin
  if FOnClickFunc = '' then
    Exit();
  if not Assigned(FBasicEngine) then
    Exit();
  Signature := LowerCase(FOnClickFunc) + '@#';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(Signature, Args);
end;

procedure TBasPie.InternalOnDblClick(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
  Signature: String;
begin
  if FOnDblClickFunc = '' then
    Exit();
  if not Assigned(FBasicEngine) then
    Exit();
  Signature := LowerCase(FOnDblClickFunc) + '@#';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(Signature, Args);
end;

procedure TBasPie.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array [0 .. 4] of TAsmData;
  Signature: String;
begin
  if FOnMouseDownFunc = '' then
    Exit();
  if not Assigned(FBasicEngine) then
    Exit();
  Signature := LowerCase(FOnMouseDownFunc) + '@#nnn$';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  Args[1].n := MouseButtonToInt(Button);
  Args[1].P := nil;
  Args[1].S := '';
  Args[2].n := X;
  Args[2].P := nil;
  Args[2].S := '';
  Args[3].n := Y;
  Args[3].P := nil;
  Args[3].S := '';
  Args[4].n := 0;
  Args[4].P := nil;
  Args[4].S := BuildShiftString(Shift);
  ExecuteCallback(Signature, Args);
end;

procedure TBasPie.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array [0 .. 4] of TAsmData;
  Signature: String;
begin
  if FOnMouseUpFunc = '' then
    Exit();
  if not Assigned(FBasicEngine) then
    Exit();
  Signature := LowerCase(FOnMouseUpFunc) + '@#nnn$';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  Args[1].n := MouseButtonToInt(Button);
  Args[1].P := nil;
  Args[1].S := '';
  Args[2].n := X;
  Args[2].P := nil;
  Args[2].S := '';
  Args[3].n := Y;
  Args[3].P := nil;
  Args[3].S := '';
  Args[4].n := 0;
  Args[4].P := nil;
  Args[4].S := BuildShiftString(Shift);
  ExecuteCallback(Signature, Args);
end;

procedure TBasPie.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array [0 .. 3] of TAsmData;
  Signature: String;
begin
  if FOnMouseMoveFunc = '' then
    Exit();
  if not Assigned(FBasicEngine) then
    Exit();
  Signature := LowerCase(FOnMouseMoveFunc) + '@#nn$';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  Args[1].n := X;
  Args[1].P := nil;
  Args[1].S := '';
  Args[2].n := Y;
  Args[2].P := nil;
  Args[2].S := '';
  Args[3].n := 0;
  Args[3].P := nil;
  Args[3].S := BuildShiftString(Shift);
  ExecuteCallback(Signature, Args);
end;

procedure TBasPie.InternalOnMouseEnter(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
  Signature: String;
begin
  if FOnMouseEnterFunc = '' then
    Exit();
  if not Assigned(FBasicEngine) then
    Exit();
  Signature := LowerCase(FOnMouseEnterFunc) + '@#';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(Signature, Args);
end;

procedure TBasPie.InternalOnMouseLeave(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
  Signature: String;
begin
  if FOnMouseLeaveFunc = '' then
    Exit();
  if not Assigned(FBasicEngine) then
    Exit();
  Signature := LowerCase(FOnMouseLeaveFunc) + '@#';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(Signature, Args);
end;

procedure TBasPie.InternalOnMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
var
  Args: array [0 .. 2] of TAsmData;
  Signature: String;
begin
  if FOnMouseWheelFunc = '' then
    Exit();
  if not Assigned(FBasicEngine) then
    Exit();
  Signature := LowerCase(FOnMouseWheelFunc) + '@#n$';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  Args[1].n := WheelDelta;
  Args[1].P := nil;
  Args[1].S := '';
  Args[2].n := 0;
  Args[2].P := nil;
  Args[2].S := BuildShiftString(Shift);
  ExecuteCallback(Signature, Args);
  Handled := True;
end;

procedure TBasPie.InternalOnResize(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
  Signature: String;
begin
  if FOnResizeFunc = '' then
    Exit();
  if not Assigned(FBasicEngine) then
    Exit();
  Signature := LowerCase(FOnResizeFunc) + '@#';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(Signature, Args);
end;

procedure TBasPie.InternalOnResized(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
  Signature: String;
begin
  if FOnResizedFunc = '' then
    Exit();
  if not Assigned(FBasicEngine) then
    Exit();
  Signature := LowerCase(FOnResizedFunc) + '@#';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(Signature, Args);
end;

procedure TBasPie.InternalOnPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Args: array [0 .. 0] of TAsmData;
  Signature: String;
begin
  if FOnPaintFunc = '' then
    Exit();
  if not Assigned(FBasicEngine) then
    Exit();
  Signature := LowerCase(FOnPaintFunc) + '@#';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(Signature, Args);
end;

procedure TBasPie.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array [0 .. 2] of TAsmData;
  Signature: String;
begin
  if FOnDragEnterFunc = '' then
    Exit;
  if not Assigned(FBasicEngine) then
    Exit;
  Signature := LowerCase(FOnDragEnterFunc) + '@#nn';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  Args[1].n := Point.X;
  Args[1].P := nil;
  Args[1].S := '';
  Args[2].n := Point.Y;
  Args[2].P := nil;
  Args[2].S := '';
  ExecuteCallback(Signature, Args);
end;

procedure TBasPie.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
var
  Args: array [0 .. 2] of TAsmData;
  Signature: String;
  RetVal: TAsmData;
begin
  if FOnDragOverFunc = '' then
    Exit;
  if not Assigned(FBasicEngine) then
    Exit;
  Signature := LowerCase(FOnDragOverFunc) + '@#nn';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  Args[1].n := Point.X;
  Args[1].P := nil;
  Args[1].S := '';
  Args[2].n := Point.Y;
  Args[2].P := nil;
  Args[2].S := '';
  RetVal := ExecuteCallbackWithResult(Signature, Args);
  if RetVal.n <> 0 then
    Operation := TDragOperation.Copy
  else
    Operation := TDragOperation.None;
end;

procedure TBasPie.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array [0 .. 2] of TAsmData;
  Signature: String;
begin
  if FOnDragDropFunc = '' then
    Exit;
  if not Assigned(FBasicEngine) then
    Exit;
  Signature := LowerCase(FOnDragDropFunc) + '@#nn';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  Args[1].n := Point.X;
  Args[1].P := nil;
  Args[1].S := '';
  Args[2].n := Point.Y;
  Args[2].P := nil;
  Args[2].S := '';
  ExecuteCallback(Signature, Args);
end;

procedure TBasPie.InternalOnDragLeave(Sender: TObject);
var
  Args: array [0 .. 0] of TAsmData;
  Signature: String;
begin
  if FOnDragLeaveFunc = '' then
    Exit;
  if not Assigned(FBasicEngine) then
    Exit;
  Signature := LowerCase(FOnDragLeaveFunc) + '@#';
  Args[0].P := Pointer(Self);
  Args[0].n := 0;
  Args[0].S := '';
  ExecuteCallback(Signature, Args);
end;

// Property setters
procedure TBasPie.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    Self.OnClick := InternalOnClick
  else
    Self.OnClick := nil;
end;

procedure TBasPie.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    Self.OnDblClick := InternalOnDblClick
  else
    Self.OnDblClick := nil;
end;

procedure TBasPie.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    Self.OnMouseDown := InternalOnMouseDown
  else
    Self.OnMouseDown := nil;
end;

procedure TBasPie.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    Self.OnMouseUp := InternalOnMouseUp
  else
    Self.OnMouseUp := nil;
end;

procedure TBasPie.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    Self.OnMouseMove := InternalOnMouseMove
  else
    Self.OnMouseMove := nil;
end;

procedure TBasPie.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    Self.OnMouseEnter := InternalOnMouseEnter
  else
    Self.OnMouseEnter := nil;
end;

procedure TBasPie.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    Self.OnMouseLeave := InternalOnMouseLeave
  else
    Self.OnMouseLeave := nil;
end;

procedure TBasPie.SetOnMouseWheelFunc(const Value: String);
begin
  FOnMouseWheelFunc := Value;
  if Value <> '' then
    Self.OnMouseWheel := InternalOnMouseWheel
  else
    Self.OnMouseWheel := nil;
end;

procedure TBasPie.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    Self.OnResize := InternalOnResize
  else
    Self.OnResize := nil;
end;

procedure TBasPie.SetOnResizedFunc(const Value: String);
begin
  FOnResizedFunc := Value;
  if Value <> '' then
    Self.OnResized := InternalOnResized
  else
    Self.OnResized := nil;
end;

procedure TBasPie.SetOnPaintFunc(const Value: String);
begin
  FOnPaintFunc := Value;
  if Value <> '' then
    Self.OnPainting := InternalOnPaint
  else
    Self.OnPainting := nil;
end;

procedure TBasPie.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    Self.OnDragEnter := InternalOnDragEnter
  else
    Self.OnDragEnter := nil;
end;

procedure TBasPie.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    Self.OnDragOver := InternalOnDragOver
  else
    Self.OnDragOver := nil;
end;

procedure TBasPie.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    Self.OnDragDrop := InternalOnDragDrop
  else
    Self.OnDragDrop := nil;
end;

procedure TBasPie.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    Self.OnDragLeave := InternalOnDragLeave
  else
    Self.OnDragLeave := nil;
end;

// Error Handling Functions
function n_pie_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.P := nil;
  Result.S := '';
end;

function s_pie_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := lastErrorMsg;
end;

function s_pie_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  case Trunc(Args[0].n) of
    ERR_NONE: Result.S := 'No error';
    ERR_INVALID_PIE: Result.S := 'Invalid pie';
    ERR_INVALID_PARENT: Result.S := 'Invalid parent';
    ERR_INVALID_VALUE: Result.S := 'Invalid value';
    ERR_CREATE_FAILED: Result.S := 'Creation failed';
    ERR_INVALID_CALLBACK: Result.S := 'Invalid callback';
    ERR_INVALID_COLOR: Result.S := 'Invalid color';
  else
    Result.S := 'Unknown error';
  end;
end;

function n_pie_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
end;

// Pie Creation/Destruction
function p_pie_new(var Args: array of TAsmData): TAsmData;
var
  Pie: TBasPie;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateParent(Args[0].P, 'pie#') then
    Exit;
  try
    Pie := TBasPie.Create(nil);
    Pie.Parent := TFmxObject(Args[0].P);
    Pie.BasicEngine := ModuleEngine;
    Pie.ConsoleOutput := ModuleOutput;
    Pie.HitTest := True;

    Result.P := Pointer(Pie);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Pie, PIE_GC_TAG + '_' + IntToStr(NativeInt(Result.P)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'pie#: ' + E.Message);
  end;
end;

function p_pie_new_size(var Args: array of TAsmData): TAsmData;
var
  Pie: TBasPie;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateParent(Args[0].P, 'pie#') then
    Exit;
  try
    Pie := TBasPie.Create(nil);
    Pie.Parent := TFmxObject(Args[0].P);
    Pie.Width := Args[1].n;
    Pie.Height := Args[2].n;
    Pie.BasicEngine := ModuleEngine;
    Pie.ConsoleOutput := ModuleOutput;
    Pie.HitTest := True;

    Result.P := Pointer(Pie);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Pie, PIE_GC_TAG + '_' + IntToStr(NativeInt(Result.P)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'pie#: ' + E.Message);
  end;
end;

function p_pie_new_full(var Args: array of TAsmData): TAsmData;
var
  Pie: TBasPie;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidateParent(Args[0].P, 'pie#') then
    Exit;
  try
    Pie := TBasPie.Create(nil);
    Pie.Parent := TFmxObject(Args[0].P);
    Pie.Position.X := Args[1].n;
    Pie.Position.Y := Args[2].n;
    Pie.Width := Args[3].n;
    Pie.Height := Args[4].n;
    Pie.BasicEngine := ModuleEngine;
    Pie.ConsoleOutput := ModuleOutput;
    Pie.HitTest := True;

    Result.P := Pointer(Pie);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Pie, PIE_GC_TAG + '_' + IntToStr(NativeInt(Result.P)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'pie#: ' + E.Message);
  end;
end;

function n_pie_free(var Args: array of TAsmData): TAsmData;
var
  Pie: TBasPie;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_free') then
    Exit;
  try
    Pie := TBasPie(Args[0].P);
    Pie.DisconnectEvents;
    Pie.Free();

//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(PIE_GC_TAG + '_' + IntToStr(NativeInt(Args[0].P)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PIE, 'pie_free: ' + E.Message);
  end;
end;

// Pie-Specific Angle Functions
function n_pie_startangle_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_startangle') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).StartAngle;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_startangle: ' + E.Message);
  end;
end;

function p_pie_startangle_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_startangle#') then
    Exit;
  try
    TBasPie(Args[0].P).StartAngle := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_startangle#: ' + E.Message);
  end;
end;

function n_pie_endangle_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_endangle') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).EndAngle;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_endangle: ' + E.Message);
  end;
end;

function p_pie_endangle_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_endangle#') then
    Exit;
  try
    TBasPie(Args[0].P).EndAngle := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_endangle#: ' + E.Message);
  end;
end;

function p_pie_angles_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_angles#') then
    Exit;
  try
    TBasPie(Args[0].P).StartAngle := Args[1].n;
    TBasPie(Args[0].P).EndAngle := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_angles#: ' + E.Message);
  end;
end;

// Fill Functions
function s_pie_fill_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_fill$') then
    Exit;
  try
    Result.S := TUtils.AlphaColorToStr(TBasPie(Args[0].P).Fill.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_fill$: ' + E.Message);
  end;
end;

function p_pie_fill_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_fill#') then
    Exit;
  try
    TBasPie(Args[0].P).Fill.Color := TUtils.ColorToAlphaColor(Args[1].S);
    TBasPie(Args[0].P).Fill.Kind := TBrushKind.Solid;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_fill#: ' + E.Message);
  end;
end;

function p_pie_fillnone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_fillnone#') then
    Exit;
  try
    TBasPie(Args[0].P).Fill.Kind := TBrushKind.None;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_fillnone#: ' + E.Message);
  end;
end;

// Stroke Functions
function s_pie_stroke_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_stroke$') then
    Exit;
  try
    Result.S := TUtils.AlphaColorToStr(TBasPie(Args[0].P).Stroke.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_stroke$: ' + E.Message);
  end;
end;

function p_pie_stroke_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_stroke#') then
    Exit;
  try
    TBasPie(Args[0].P).Stroke.Color := TUtils.ColorToAlphaColor(Args[1].S);
    TBasPie(Args[0].P).Stroke.Kind := TBrushKind.Solid;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_stroke#: ' + E.Message);
  end;
end;

function p_pie_strokenone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_strokenone#') then
    Exit;
  try
    TBasPie(Args[0].P).Stroke.Kind := TBrushKind.None;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_strokenone#: ' + E.Message);
  end;
end;

function n_pie_strokethickness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_strokethickness') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).Stroke.Thickness;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_strokethickness: ' + E.Message);
  end;
end;

function p_pie_strokethickness_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_strokethickness#') then
    Exit;
  try
    TBasPie(Args[0].P).Stroke.Thickness := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_strokethickness#: ' + E.Message);
  end;
end;

function n_pie_strokedash_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_strokedash') then
    Exit;
  try
    Result.n := StrokeDashToInt(TBasPie(Args[0].P).Stroke.Dash);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_strokedash: ' + E.Message);
  end;
end;

function p_pie_strokedash_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_strokedash#') then
    Exit;
  try
    TBasPie(Args[0].P).Stroke.Dash := IntToStrokeDash(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_strokedash#: ' + E.Message);
  end;
end;

function n_pie_strokecap_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_strokecap') then
    Exit;
  try
    Result.n := StrokeCapToInt(TBasPie(Args[0].P).Stroke.Cap);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_strokecap: ' + E.Message);
  end;
end;

function p_pie_strokecap_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_strokecap#') then
    Exit;
  try
    TBasPie(Args[0].P).Stroke.Cap := IntToStrokeCap(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_strokecap#: ' + E.Message);
  end;
end;

function n_pie_strokejoin_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_strokejoin') then
    Exit;
  try
    Result.n := StrokeJoinToInt(TBasPie(Args[0].P).Stroke.Join);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_strokejoin: ' + E.Message);
  end;
end;

function p_pie_strokejoin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_strokejoin#') then
    Exit;
  try
    TBasPie(Args[0].P).Stroke.Join := IntToStrokeJoin(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_strokejoin#: ' + E.Message);
  end;
end;

// Position and Size Functions
function n_pie_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_x') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).Position.X;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_x: ' + E.Message);
  end;
end;

function p_pie_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_x#') then
    Exit;
  try
    TBasPie(Args[0].P).Position.X := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_x#: ' + E.Message);
  end;
end;

function n_pie_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_y') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).Position.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_y: ' + E.Message);
  end;
end;

function p_pie_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_y#') then
    Exit;
  try
    TBasPie(Args[0].P).Position.Y := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_y#: ' + E.Message);
  end;
end;

function n_pie_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_width') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_width: ' + E.Message);
  end;
end;

function p_pie_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_width#') then
    Exit;
  try
    TBasPie(Args[0].P).Width := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_width#: ' + E.Message);
  end;
end;

function n_pie_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_height') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_height: ' + E.Message);
  end;
end;

function p_pie_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_height#') then
    Exit;
  try
    TBasPie(Args[0].P).Height := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_height#: ' + E.Message);
  end;
end;

function p_pie_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_bounds#') then
    Exit;
  try
    TBasPie(Args[0].P).SetBounds(Args[1].n, Args[2].n, Args[3].n, Args[4].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_bounds#: ' + E.Message);
  end;
end;

function p_pie_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_size#') then
    Exit;
  try
    TBasPie(Args[0].P).Width := Args[1].n;
    TBasPie(Args[0].P).Height := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_size#: ' + E.Message);
  end;
end;

function p_pie_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_move#') then
    Exit;
  try
    TBasPie(Args[0].P).Position.X := Args[1].n;
    TBasPie(Args[0].P).Position.Y := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_move#: ' + E.Message);
  end;
end;

// Alignment Functions
function n_pie_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_align') then
    Exit;
  try
    Result.n := AlignToInt(TBasPie(Args[0].P).Align);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_align: ' + E.Message);
  end;
end;

function p_pie_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_align#') then
    Exit;
  try
    TBasPie(Args[0].P).Align := IntToAlign(Trunc(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_align#: ' + E.Message);
  end;
end;

// Margin Functions
function n_pie_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_marginleft') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).Margins.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_marginleft: ' + E.Message);
  end;
end;

function p_pie_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_marginleft#') then
    Exit;
  try
    TBasPie(Args[0].P).Margins.Left := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_marginleft#: ' + E.Message);
  end;
end;

function n_pie_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_margintop') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).Margins.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_margintop: ' + E.Message);
  end;
end;

function p_pie_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_margintop#') then
    Exit;
  try
    TBasPie(Args[0].P).Margins.Top := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_margintop#: ' + E.Message);
  end;
end;

function n_pie_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_marginright') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).Margins.Right;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_marginright: ' + E.Message);
  end;
end;

function p_pie_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_marginright#') then
    Exit;
  try
    TBasPie(Args[0].P).Margins.Right := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_marginright#: ' + E.Message);
  end;
end;

function n_pie_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_marginbottom') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).Margins.Bottom;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_marginbottom: ' + E.Message);
  end;
end;

function p_pie_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_marginbottom#') then
    Exit;
  try
    TBasPie(Args[0].P).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_marginbottom#: ' + E.Message);
  end;
end;

function p_pie_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_margins#') then
    Exit;
  try
    TBasPie(Args[0].P).Margins.Left := Args[1].n;
    TBasPie(Args[0].P).Margins.Top := Args[2].n;
    TBasPie(Args[0].P).Margins.Right := Args[3].n;
    TBasPie(Args[0].P).Margins.Bottom := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_margins#: ' + E.Message);
  end;
end;

function p_pie_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_margin#') then
    Exit;
  try
    TBasPie(Args[0].P).Margins.Left := Args[1].n;
    TBasPie(Args[0].P).Margins.Top := Args[1].n;
    TBasPie(Args[0].P).Margins.Right := Args[1].n;
    TBasPie(Args[0].P).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_margin#: ' + E.Message);
  end;
end;

// Visibility and Behavior Functions
function n_pie_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_visible') then
    Exit;
  try
    if TBasPie(Args[0].P).Visible then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_visible: ' + E.Message);
  end;
end;

function p_pie_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_visible#') then
    Exit;
  try
    TBasPie(Args[0].P).Visible := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_visible#: ' + E.Message);
  end;
end;

function n_pie_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_enabled') then
    Exit;
  try
    if TBasPie(Args[0].P).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_enabled: ' + E.Message);
  end;
end;

function p_pie_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_enabled#') then
    Exit;
  try
    TBasPie(Args[0].P).Enabled := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_enabled#: ' + E.Message);
  end;
end;

function n_pie_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_opacity') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).Opacity;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_opacity: ' + E.Message);
  end;
end;

function p_pie_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_opacity#') then
    Exit;
  try
    TBasPie(Args[0].P).Opacity := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_opacity#: ' + E.Message);
  end;
end;

function n_pie_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_hittest') then
    Exit;
  try
    if TBasPie(Args[0].P).HitTest then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_hittest: ' + E.Message);
  end;
end;

function p_pie_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_hittest#') then
    Exit;
  try
    TBasPie(Args[0].P).HitTest := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_hittest#: ' + E.Message);
  end;
end;

// Tag and Rotation Functions
function n_pie_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_tag') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).Tag;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_tag: ' + E.Message);
  end;
end;

function p_pie_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_tag#') then
    Exit;
  try
    TBasPie(Args[0].P).Tag := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_tag#: ' + E.Message);
  end;
end;

function n_pie_rotation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_rotation') then
    Exit;
  try
    Result.n := TBasPie(Args[0].P).RotationAngle;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_rotation: ' + E.Message);
  end;
end;

function p_pie_rotation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_rotation#') then
    Exit;
  try
    TBasPie(Args[0].P).RotationAngle := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_rotation#: ' + E.Message);
  end;
end;

// Parent and Z-Order Functions
function p_pie_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_parent#') then
    Exit;
  try
    Result.P := TBasPie(Args[0].P).Parent;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_parent#: ' + E.Message);
  end;
end;

function p_pie_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_parent#') then
    Exit;
  if not ValidateParent(Args[1].P, 'pie_parent#') then
    Exit;
  try
    TBasPie(Args[0].P).Parent := TFmxObject(Args[1].P);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_parent#: ' + E.Message);
  end;
end;

function p_pie_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_bringtofront#') then
    Exit;
  try
    TBasPie(Args[0].P).BringToFront;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_bringtofront#: ' + E.Message);
  end;
end;

function p_pie_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_sendtoback#') then
    Exit;
  try
    TBasPie(Args[0].P).SendToBack;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_sendtoback#: ' + E.Message);
  end;
end;

// Invalidation
function p_pie_invalidate(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_invalidate#') then
    Exit;
  try
    TBasPie(Args[0].P).Repaint;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_invalidate#: ' + E.Message);
  end;
end;

// Event Callback Functions
function p_pie_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onclick#') then
    Exit;
  try
    TBasPie(Args[0].P).OnClickFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onclick#: ' + E.Message);
  end;
end;

function s_pie_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onclick$') then
    Exit;
  try
    Result.S := TBasPie(Args[0].P).OnClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onclick$: ' + E.Message);
  end;
end;

function p_pie_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_ondblclick#') then
    Exit;
  try
    TBasPie(Args[0].P).OnDblClickFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_ondblclick#: ' + E.Message);
  end;
end;

function s_pie_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_ondblclick$') then
    Exit;
  try
    Result.S := TBasPie(Args[0].P).OnDblClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_ondblclick$: ' + E.Message);
  end;
end;

function p_pie_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onmousedown#') then
    Exit;
  try
    TBasPie(Args[0].P).OnMouseDownFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onmousedown#: ' + E.Message);
  end;
end;

function s_pie_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onmousedown$') then
    Exit;
  try
    Result.S := TBasPie(Args[0].P).OnMouseDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onmousedown$: ' + E.Message);
  end;
end;

function p_pie_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onmouseup#') then
    Exit;
  try
    TBasPie(Args[0].P).OnMouseUpFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onmouseup#: ' + E.Message);
  end;
end;

function s_pie_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onmouseup$') then
    Exit;
  try
    Result.S := TBasPie(Args[0].P).OnMouseUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onmouseup$: ' + E.Message);
  end;
end;

function p_pie_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onmousemove#') then
    Exit;
  try
    TBasPie(Args[0].P).OnMouseMoveFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onmousemove#: ' + E.Message);
  end;
end;

function s_pie_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onmousemove$') then
    Exit;
  try
    Result.S := TBasPie(Args[0].P).OnMouseMoveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onmousemove$: ' + E.Message);
  end;
end;

function p_pie_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onmouseenter#') then
    Exit;
  try
    TBasPie(Args[0].P).OnMouseEnterFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onmouseenter#: ' + E.Message);
  end;
end;

function s_pie_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onmouseenter$') then
    Exit;
  try
    Result.S := TBasPie(Args[0].P).OnMouseEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onmouseenter$: ' + E.Message);
  end;
end;

function p_pie_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onmouseleave#') then
    Exit;
  try
    TBasPie(Args[0].P).OnMouseLeaveFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onmouseleave#: ' + E.Message);
  end;
end;

function s_pie_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onmouseleave$') then
    Exit;
  try
    Result.S := TBasPie(Args[0].P).OnMouseLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onmouseleave$: ' + E.Message);
  end;
end;

function p_pie_onmousewheel_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onmousewheel#') then
    Exit;
  try
    TBasPie(Args[0].P).OnMouseWheelFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onmousewheel#: ' + E.Message);
  end;
end;

function s_pie_onmousewheel_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onmousewheel$') then
    Exit;
  try
    Result.S := TBasPie(Args[0].P).OnMouseWheelFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onmousewheel$: ' + E.Message);
  end;
end;

function p_pie_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onresize#') then
    Exit;
  try
    TBasPie(Args[0].P).OnResizeFunc := Args[1].S;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onresize#: ' + E.Message);
  end;
end;

function s_pie_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_onresize$') then
    Exit;
  try
    Result.S := TBasPie(Args[0].P).OnResizeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'pie_onresize$: ' + E.Message);
  end;
end;

function p_pie_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := Args[0].P;
  Result.S := '';
  if not ValidatePie(Args[0].P, 'pie_clearcallbacks#') then
    Exit;
  try
    with TBasPie(Args[0].P) do
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
      SetError(ERR_OPERATION_FAILED, 'pie_clearcallbacks#: ' + E.Message);
  end;
end;

// Library Registration
procedure RegisterPieFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_pie_error; Lib.Add('pie_error@', Fn);
  Fn.Entry := @s_pie_errormsg; Lib.Add('pie_errormsg$@', Fn);
  Fn.Entry := @s_pie_strerror; Lib.Add('pie_strerror$@n', Fn);
  Fn.Entry := @n_pie_clearerror; Lib.Add('pie_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_pie_new; Lib.Add('pie#@#', Fn);
  Fn.Entry := @p_pie_new_size; Lib.Add('pie#@#nn', Fn);
  Fn.Entry := @p_pie_new_full; Lib.Add('pie#@#nnnn', Fn);
  Fn.Entry := @n_pie_free; Lib.Add('pie_free@#', Fn);

  // Angles
  Fn.Entry := @n_pie_startangle_get; Lib.Add('pie_startangle@#', Fn);
  Fn.Entry := @p_pie_startangle_set; Lib.Add('pie_startangle#@#n', Fn);
  Fn.Entry := @n_pie_endangle_get; Lib.Add('pie_endangle@#', Fn);
  Fn.Entry := @p_pie_endangle_set; Lib.Add('pie_endangle#@#n', Fn);
  Fn.Entry := @p_pie_angles_set; Lib.Add('pie_angles#@#nn', Fn);

  // Fill
  Fn.Entry := @s_pie_fill_get; Lib.Add('pie_fill$@#', Fn);
  Fn.Entry := @p_pie_fill_set; Lib.Add('pie_fill#@#$', Fn);
  Fn.Entry := @p_pie_fillnone; Lib.Add('pie_fillnone#@#', Fn);

  // Stroke
  Fn.Entry := @s_pie_stroke_get; Lib.Add('pie_stroke$@#', Fn);
  Fn.Entry := @p_pie_stroke_set; Lib.Add('pie_stroke#@#$', Fn);
  Fn.Entry := @p_pie_strokenone; Lib.Add('pie_strokenone#@#', Fn);
  Fn.Entry := @n_pie_strokethickness_get; Lib.Add('pie_strokethickness@#', Fn);
  Fn.Entry := @p_pie_strokethickness_set; Lib.Add('pie_strokethickness#@#n', Fn);
  Fn.Entry := @n_pie_strokedash_get; Lib.Add('pie_strokedash@#', Fn);
  Fn.Entry := @p_pie_strokedash_set; Lib.Add('pie_strokedash#@#n', Fn);
  Fn.Entry := @n_pie_strokecap_get; Lib.Add('pie_strokecap@#', Fn);
  Fn.Entry := @p_pie_strokecap_set; Lib.Add('pie_strokecap#@#n', Fn);
  Fn.Entry := @n_pie_strokejoin_get; Lib.Add('pie_strokejoin@#', Fn);
  Fn.Entry := @p_pie_strokejoin_set; Lib.Add('pie_strokejoin#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_pie_x_get; Lib.Add('pie_x@#', Fn);
  Fn.Entry := @p_pie_x_set; Lib.Add('pie_x#@#n', Fn);
  Fn.Entry := @n_pie_y_get; Lib.Add('pie_y@#', Fn);
  Fn.Entry := @p_pie_y_set; Lib.Add('pie_y#@#n', Fn);
  Fn.Entry := @n_pie_width_get; Lib.Add('pie_width@#', Fn);
  Fn.Entry := @p_pie_width_set; Lib.Add('pie_width#@#n', Fn);
  Fn.Entry := @n_pie_height_get; Lib.Add('pie_height@#', Fn);
  Fn.Entry := @p_pie_height_set; Lib.Add('pie_height#@#n', Fn);
  Fn.Entry := @p_pie_bounds_set; Lib.Add('pie_bounds#@#nnnn', Fn);
  Fn.Entry := @p_pie_size_set; Lib.Add('pie_size#@#nn', Fn);
  Fn.Entry := @p_pie_move_set; Lib.Add('pie_move#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_pie_align_get; Lib.Add('pie_align@#', Fn);
  Fn.Entry := @p_pie_align_set; Lib.Add('pie_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_pie_marginleft_get; Lib.Add('pie_marginleft@#', Fn);
  Fn.Entry := @p_pie_marginleft_set; Lib.Add('pie_marginleft#@#n', Fn);
  Fn.Entry := @n_pie_margintop_get; Lib.Add('pie_margintop@#', Fn);
  Fn.Entry := @p_pie_margintop_set; Lib.Add('pie_margintop#@#n', Fn);
  Fn.Entry := @n_pie_marginright_get; Lib.Add('pie_marginright@#', Fn);
  Fn.Entry := @p_pie_marginright_set; Lib.Add('pie_marginright#@#n', Fn);
  Fn.Entry := @n_pie_marginbottom_get; Lib.Add('pie_marginbottom@#', Fn);
  Fn.Entry := @p_pie_marginbottom_set; Lib.Add('pie_marginbottom#@#n', Fn);
  Fn.Entry := @p_pie_margins_set; Lib.Add('pie_margins#@#nnnn', Fn);
  Fn.Entry := @p_pie_margin_set; Lib.Add('pie_margin#@#n', Fn);

  // Visibility and behavior
  Fn.Entry := @n_pie_visible_get; Lib.Add('pie_visible@#', Fn);
  Fn.Entry := @p_pie_visible_set; Lib.Add('pie_visible#@#n', Fn);
  Fn.Entry := @n_pie_enabled_get; Lib.Add('pie_enabled@#', Fn);
  Fn.Entry := @p_pie_enabled_set; Lib.Add('pie_enabled#@#n', Fn);
  Fn.Entry := @n_pie_opacity_get; Lib.Add('pie_opacity@#', Fn);
  Fn.Entry := @p_pie_opacity_set; Lib.Add('pie_opacity#@#n', Fn);
  Fn.Entry := @n_pie_hittest_get; Lib.Add('pie_hittest@#', Fn);
  Fn.Entry := @p_pie_hittest_set; Lib.Add('pie_hittest#@#n', Fn);

  // Tag and rotation
  Fn.Entry := @n_pie_tag_get; Lib.Add('pie_tag@#', Fn);
  Fn.Entry := @p_pie_tag_set; Lib.Add('pie_tag#@#n', Fn);
  Fn.Entry := @n_pie_rotation_get; Lib.Add('pie_rotation@#', Fn);
  Fn.Entry := @p_pie_rotation_set; Lib.Add('pie_rotation#@#n', Fn);

  // Parent and Z-order
  Fn.Entry := @p_pie_parent_get; Lib.Add('pie_parent#@#', Fn);
  Fn.Entry := @p_pie_parent_set; Lib.Add('pie_parent#@##', Fn);
  Fn.Entry := @p_pie_bringtofront; Lib.Add('pie_bringtofront#@#', Fn);
  Fn.Entry := @p_pie_sendtoback; Lib.Add('pie_sendtoback#@#', Fn);

  // Invalidation
  Fn.Entry := @p_pie_invalidate; Lib.Add('pie_invalidate#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_pie_onclick_set; Lib.Add('pie_onclick#@#$', Fn);
  Fn.Entry := @s_pie_onclick_get; Lib.Add('pie_onclick$@#', Fn);
  Fn.Entry := @p_pie_ondblclick_set; Lib.Add('pie_ondblclick#@#$', Fn);
  Fn.Entry := @s_pie_ondblclick_get; Lib.Add('pie_ondblclick$@#', Fn);
  Fn.Entry := @p_pie_onmousedown_set; Lib.Add('pie_onmousedown#@#$', Fn);
  Fn.Entry := @s_pie_onmousedown_get; Lib.Add('pie_onmousedown$@#', Fn);
  Fn.Entry := @p_pie_onmouseup_set; Lib.Add('pie_onmouseup#@#$', Fn);
  Fn.Entry := @s_pie_onmouseup_get; Lib.Add('pie_onmouseup$@#', Fn);
  Fn.Entry := @p_pie_onmousemove_set; Lib.Add('pie_onmousemove#@#$', Fn);
  Fn.Entry := @s_pie_onmousemove_get; Lib.Add('pie_onmousemove$@#', Fn);
  Fn.Entry := @p_pie_onmouseenter_set; Lib.Add('pie_onmouseenter#@#$', Fn);
  Fn.Entry := @s_pie_onmouseenter_get; Lib.Add('pie_onmouseenter$@#', Fn);
  Fn.Entry := @p_pie_onmouseleave_set; Lib.Add('pie_onmouseleave#@#$', Fn);
  Fn.Entry := @s_pie_onmouseleave_get; Lib.Add('pie_onmouseleave$@#', Fn);
  Fn.Entry := @p_pie_onmousewheel_set; Lib.Add('pie_onmousewheel#@#$', Fn);
  Fn.Entry := @s_pie_onmousewheel_get; Lib.Add('pie_onmousewheel$@#', Fn);
  Fn.Entry := @p_pie_onresize_set; Lib.Add('pie_onresize#@#$', Fn);
  Fn.Entry := @s_pie_onresize_get; Lib.Add('pie_onresize$@#', Fn);
  Fn.Entry := @p_pie_clearcallbacks; Lib.Add('pie_clearcallbacks#@#', Fn);
end;

end.

