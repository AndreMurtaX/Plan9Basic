unit EllipseLib;

{******************************************************************************
  EllipseLib - Ellipse Visual Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TEllipse wrapper functionality for creating
  and managing ellipse visual controls in Plan9Basic programs. TEllipse
  is a visual shape control with fill and stroke properties.

  Function Count: 81 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  Copyright (c) 2024-2026 André Murta
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, ControlCommon;

type
  TBasEllipse = class;

  TBasEllipse = class(TEllipse)
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

    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
  end;

procedure RegisterEllipseFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  ELLIPSE_GC_TAG = 'BASIC_ELLIPSE';

  ERR_NONE = 0;
  ERR_INVALID_ELLIPSE = 1;
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

var
  lastError: Integer;
  lastErrorMsg: String;

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

function ValidateEllipse(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_ELLIPSE, FuncName + ': Nil ellipse pointer');
    Exit;
  end;
  try
    if not (IsHandleOf(P, TBasEllipse)) then
    begin
      SetError(ERR_INVALID_ELLIPSE, FuncName + ': Invalid ellipse object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_ELLIPSE, FuncName + ': Invalid ellipse pointer');
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
// TBasEllipse Implementation
//==============================================================================

constructor TBasEllipse.Create(AOwner: TComponent);
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
  FBasicEngine := nil;
  FConsoleOutput := nil;
end;

destructor TBasEllipse.Destroy;
begin
  UnregisterHandle(Self);
  DisconnectEvents();
  inherited Destroy();
end;

procedure TBasEllipse.DisconnectEvents();
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

function TBasEllipse.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

procedure TBasEllipse.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'Ellipse');
end;

//function TBasEllipse.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
//var
//  CallArgs: array of TAsmData;
//  RetType: TExprKind;
//  i: Integer;
//begin
//  Result.n := 0;
//  Result.p := nil;
//  Result.s := '';
//
//  if UnitGC.GlobalCallbackBusy then Exit();
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
//        FConsoleOutput.Add('*** Ellipse Event Callback Error ***');
//        FConsoleOutput.Add('Function: ' + FuncSignature);
//        FConsoleOutput.Add('Error: ' + E.Message);
//      end;
//    end;
//  finally
//    UnitGC.SkipProcessMessages := False;
//    UnitGC.GlobalCallbackBusy := False;
//  end;
//end;

// Property setters

procedure TBasEllipse.SetOnClickFunc(const Value: String);
begin
  ControlCommon.BindClick(Self, Value, FOnClickFunc, InternalOnClick);
end;

procedure TBasEllipse.SetOnDblClickFunc(const Value: String);
begin
  ControlCommon.BindDblClick(Self, Value, FOnDblClickFunc, InternalOnDblClick);
end;

procedure TBasEllipse.SetOnMouseDownFunc(const Value: String);
begin
  ControlCommon.BindMouseDown(Self, Value, FOnMouseDownFunc, InternalOnMouseDown);
end;

procedure TBasEllipse.SetOnMouseUpFunc(const Value: String);
begin
  ControlCommon.BindMouseUp(Self, Value, FOnMouseUpFunc, InternalOnMouseUp);
end;

procedure TBasEllipse.SetOnMouseMoveFunc(const Value: String);
begin
  ControlCommon.BindMouseMove(Self, Value, FOnMouseMoveFunc, InternalOnMouseMove);
end;

procedure TBasEllipse.SetOnMouseEnterFunc(const Value: String);
begin
  ControlCommon.BindMouseEnter(Self, Value, FOnMouseEnterFunc, InternalOnMouseEnter);
end;

procedure TBasEllipse.SetOnMouseLeaveFunc(const Value: String);
begin
  ControlCommon.BindMouseLeave(Self, Value, FOnMouseLeaveFunc, InternalOnMouseLeave);
end;

procedure TBasEllipse.SetOnMouseWheelFunc(const Value: String);
begin
  ControlCommon.BindMouseWheel(Self, Value, FOnMouseWheelFunc, InternalOnMouseWheel);
end;

procedure TBasEllipse.SetOnResizeFunc(const Value: String);
begin
  ControlCommon.BindResize(Self, Value, FOnResizeFunc, InternalOnResize);
end;

procedure TBasEllipse.SetOnResizedFunc(const Value: String);
begin
  ControlCommon.BindResized(Self, Value, FOnResizedFunc, InternalOnResized);
end;

procedure TBasEllipse.SetOnPaintFunc(const Value: String);
begin
  ControlCommon.BindPaint(Self, Value, FOnPaintFunc, InternalOnPaint);
end;

// Internal event handlers

procedure TBasEllipse.InternalOnClick(Sender: TObject);
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

procedure TBasEllipse.InternalOnDblClick(Sender: TObject);
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

procedure TBasEllipse.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasEllipse.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasEllipse.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
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

procedure TBasEllipse.InternalOnMouseEnter(Sender: TObject);
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

procedure TBasEllipse.InternalOnMouseLeave(Sender: TObject);
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

procedure TBasEllipse.InternalOnMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
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

procedure TBasEllipse.InternalOnResize(Sender: TObject);
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

procedure TBasEllipse.InternalOnResized(Sender: TObject);
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

procedure TBasEllipse.InternalOnPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnPaintFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnPaintFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

//==============================================================================
// Error Handling Functions
//==============================================================================

function n_ellipse_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

function s_ellipse_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

function s_ellipse_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Trunc(Args[0].n) of
    ERR_NONE:            Result.s := 'No error';
    ERR_INVALID_ELLIPSE: Result.s := 'Invalid ellipse';
    ERR_INVALID_PARENT:  Result.s := 'Invalid parent';
    ERR_INVALID_VALUE:   Result.s := 'Invalid value';
    ERR_CREATE_FAILED:   Result.s := 'Creation failed';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback';
    ERR_INVALID_COLOR:   Result.s := 'Invalid color';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_ellipse_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

//==============================================================================
// Ellipse Creation/Destruction Functions
//==============================================================================

function p_ellipse_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Ellipse: TBasEllipse;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'ellipse#') then Exit;

  try
    Ellipse := TBasEllipse.Create(nil);
    Ellipse.Parent := TFmxObject(Args[0].p);
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Ellipse, Eng, Outp) then
    begin
      Ellipse.BasicEngine := Eng;
      Ellipse.ConsoleOutput := Outp;
    end;
    Ellipse.HitTest := True;

    Result.p := Pointer(Ellipse);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Ellipse, ELLIPSE_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'ellipse#: ' + E.Message);
  end;
end;

function p_ellipse_new_size(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Ellipse: TBasEllipse;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'ellipse#') then Exit;

  try
    Ellipse := TBasEllipse.Create(nil);
    Ellipse.Parent := TFmxObject(Args[0].p);
    Ellipse.Width := Args[1].n;
    Ellipse.Height := Args[2].n;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Ellipse, Eng, Outp) then
    begin
      Ellipse.BasicEngine := Eng;
      Ellipse.ConsoleOutput := Outp;
    end;
    Ellipse.HitTest := True;

    Result.p := Pointer(Ellipse);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Ellipse, ELLIPSE_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'ellipse#: ' + E.Message);
  end;
end;

function p_ellipse_new_full(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Ellipse: TBasEllipse;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'ellipse#') then Exit;

  try
    Ellipse := TBasEllipse.Create(nil);
    Ellipse.Parent := TFmxObject(Args[0].p);
    Ellipse.Position.X := Args[1].n;
    Ellipse.Position.Y := Args[2].n;
    Ellipse.Width := Args[3].n;
    Ellipse.Height := Args[4].n;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Ellipse, Eng, Outp) then
    begin
      Ellipse.BasicEngine := Eng;
      Ellipse.ConsoleOutput := Outp;
    end;
    Ellipse.HitTest := True;

    Result.p := Pointer(Ellipse);
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Ellipse, ELLIPSE_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'ellipse#: ' + E.Message);
  end;
end;

function n_ellipse_free(var Args: array of TAsmData): TAsmData;
var
  Ellipse: TBasEllipse;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateEllipse(Args[0].p, 'ellipse_free') then Exit;

  try
    Ellipse := TBasEllipse(Args[0].p);
    Ellipse.DisconnectEvents();
    Ellipse.Free();

//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(ELLIPSE_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
    //Its eighty-one siblings answer 1 on success. This one did too, inside
    //the collector block that was commented out.
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_ELLIPSE, 'ellipse_free: ' + E.Message);
  end;
end;

//==============================================================================
// Fill Functions
//==============================================================================

function s_ellipse_fill_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_fill$') then Exit;
  Result.s := TUtils.AlphaColorToStr(TBasEllipse(Args[0].p).Fill.Color);
end;

function p_ellipse_fill_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_fill#') then Exit;
  TBasEllipse(Args[0].p).Fill.Color := TUtils.ColorToAlphaColor(Args[1].s);
  TBasEllipse(Args[0].p).Fill.Kind := TBrushKind.Solid;
end;

function p_ellipse_fillnone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_fillnone#') then Exit;
  TBasEllipse(Args[0].p).Fill.Kind := TBrushKind.None;
end;

//==============================================================================
// Stroke Functions
//==============================================================================

function s_ellipse_stroke_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_stroke$') then Exit;
  Result.s := TUtils.AlphaColorToStr(TBasEllipse(Args[0].p).Stroke.Color);
end;

function p_ellipse_stroke_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_stroke#') then Exit;
  TBasEllipse(Args[0].p).Stroke.Color := TUtils.ColorToAlphaColor(Args[1].s);
  TBasEllipse(Args[0].p).Stroke.Kind := TBrushKind.Solid;
end;

function p_ellipse_strokenone(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_strokenone#') then Exit;
  TBasEllipse(Args[0].p).Stroke.Kind := TBrushKind.None;
end;

function n_ellipse_strokethickness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_strokethickness') then Exit;
  Result.n := TBasEllipse(Args[0].p).Stroke.Thickness;
end;

function p_ellipse_strokethickness_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_strokethickness#') then Exit;
  TBasEllipse(Args[0].p).Stroke.Thickness := Args[1].n;
end;

function n_ellipse_strokedash_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_strokedash') then Exit;
  Result.n := StrokeDashToInt(TBasEllipse(Args[0].p).Stroke.Dash);
end;

function p_ellipse_strokedash_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_strokedash#') then Exit;
  TBasEllipse(Args[0].p).Stroke.Dash := IntToStrokeDash(Trunc(Args[1].n));
end;

function n_ellipse_strokecap_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_strokecap') then Exit;
  Result.n := StrokeCapToInt(TBasEllipse(Args[0].p).Stroke.Cap);
end;

function p_ellipse_strokecap_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_strokecap#') then Exit;
  TBasEllipse(Args[0].p).Stroke.Cap := IntToStrokeCap(Trunc(Args[1].n));
end;

function n_ellipse_strokejoin_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_strokejoin') then Exit;
  Result.n := StrokeJoinToInt(TBasEllipse(Args[0].p).Stroke.Join);
end;

function p_ellipse_strokejoin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_strokejoin#') then Exit;
  TBasEllipse(Args[0].p).Stroke.Join := IntToStrokeJoin(Trunc(Args[1].n));
end;

//==============================================================================
// Position and Size Functions
//==============================================================================

function n_ellipse_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_x') then Exit;
  Result.n := TBasEllipse(Args[0].p).Position.X;
end;

function p_ellipse_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_x#') then Exit;
  TBasEllipse(Args[0].p).Position.X := Args[1].n;
end;

function n_ellipse_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_y') then Exit;
  Result.n := TBasEllipse(Args[0].p).Position.Y;
end;

function p_ellipse_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_y#') then Exit;
  TBasEllipse(Args[0].p).Position.Y := Args[1].n;
end;

function n_ellipse_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_width') then Exit;
  Result.n := TBasEllipse(Args[0].p).Width;
end;

function p_ellipse_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_width#') then Exit;
  TBasEllipse(Args[0].p).Width := Args[1].n;
end;

function n_ellipse_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_height') then Exit;
  Result.n := TBasEllipse(Args[0].p).Height;
end;

function p_ellipse_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_height#') then Exit;
  TBasEllipse(Args[0].p).Height := Args[1].n;
end;

function p_ellipse_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_bounds#') then Exit;
  TBasEllipse(Args[0].p).Position.X := Args[1].n;
  TBasEllipse(Args[0].p).Position.Y := Args[2].n;
  TBasEllipse(Args[0].p).Width := Args[3].n;
  TBasEllipse(Args[0].p).Height := Args[4].n;
end;

function p_ellipse_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_size#') then Exit;
  TBasEllipse(Args[0].p).Width := Args[1].n;
  TBasEllipse(Args[0].p).Height := Args[2].n;
end;

function p_ellipse_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_move#') then Exit;
  TBasEllipse(Args[0].p).Position.X := Args[1].n;
  TBasEllipse(Args[0].p).Position.Y := Args[2].n;
end;

//==============================================================================
// Alignment Functions
//==============================================================================

function n_ellipse_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_align') then Exit;
  Result.n := AlignToInt(TBasEllipse(Args[0].p).Align);
end;

function p_ellipse_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_align#') then Exit;
  TBasEllipse(Args[0].p).Align := AlignFromInt(Trunc(Args[1].n));
end;

//==============================================================================
// Margin Functions
//==============================================================================

function n_ellipse_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_marginleft') then Exit;
  Result.n := TBasEllipse(Args[0].p).Margins.Left;
end;

function p_ellipse_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_marginleft#') then Exit;
  TBasEllipse(Args[0].p).Margins.Left := Args[1].n;
end;

function n_ellipse_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_margintop') then Exit;
  Result.n := TBasEllipse(Args[0].p).Margins.Top;
end;

function p_ellipse_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_margintop#') then Exit;
  TBasEllipse(Args[0].p).Margins.Top := Args[1].n;
end;

function n_ellipse_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_marginright') then Exit;
  Result.n := TBasEllipse(Args[0].p).Margins.Right;
end;

function p_ellipse_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_marginright#') then Exit;
  TBasEllipse(Args[0].p).Margins.Right := Args[1].n;
end;

function n_ellipse_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_marginbottom') then Exit;
  Result.n := TBasEllipse(Args[0].p).Margins.Bottom;
end;

function p_ellipse_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_marginbottom#') then Exit;
  TBasEllipse(Args[0].p).Margins.Bottom := Args[1].n;
end;

function p_ellipse_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_margins#') then Exit;
  TBasEllipse(Args[0].p).Margins.Left := Args[1].n;
  TBasEllipse(Args[0].p).Margins.Top := Args[2].n;
  TBasEllipse(Args[0].p).Margins.Right := Args[3].n;
  TBasEllipse(Args[0].p).Margins.Bottom := Args[4].n;
end;

function p_ellipse_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_margin#') then Exit;
  TBasEllipse(Args[0].p).Margins.Left := Args[1].n;
  TBasEllipse(Args[0].p).Margins.Top := Args[1].n;
  TBasEllipse(Args[0].p).Margins.Right := Args[1].n;
  TBasEllipse(Args[0].p).Margins.Bottom := Args[1].n;
end;

//==============================================================================
// Visibility and Behavior Functions
//==============================================================================

function n_ellipse_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_visible') then Exit;
  if TBasEllipse(Args[0].p).Visible then
    Result.n := 1
  else
    Result.n := 0;
end;

function p_ellipse_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_visible#') then Exit;
  TBasEllipse(Args[0].p).Visible := Args[1].n <> 0;
end;

function n_ellipse_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_enabled') then Exit;
  if TBasEllipse(Args[0].p).Enabled then
    Result.n := 1
  else
    Result.n := 0;
end;

function p_ellipse_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_enabled#') then Exit;
  TBasEllipse(Args[0].p).Enabled := Args[1].n <> 0;
end;

function n_ellipse_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_opacity') then Exit;
  Result.n := TBasEllipse(Args[0].p).Opacity;
end;

function p_ellipse_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_opacity#') then Exit;
  TBasEllipse(Args[0].p).Opacity := Args[1].n;
end;

function n_ellipse_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_hittest') then Exit;
  if TBasEllipse(Args[0].p).HitTest then
    Result.n := 1
  else
    Result.n := 0;
end;

function p_ellipse_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_hittest#') then Exit;
  TBasEllipse(Args[0].p).HitTest := Args[1].n <> 0;
end;

//==============================================================================
// Tag and Rotation Functions
//==============================================================================

function n_ellipse_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_tag') then Exit;
  Result.n := TBasEllipse(Args[0].p).Tag;
end;

function p_ellipse_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_tag#') then Exit;
  TBasEllipse(Args[0].p).Tag := Trunc(Args[1].n);
end;

function n_ellipse_rotation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_rotation') then Exit;
  Result.n := TBasEllipse(Args[0].p).RotationAngle;
end;

function p_ellipse_rotation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_rotation#') then Exit;
  TBasEllipse(Args[0].p).RotationAngle := Args[1].n;
end;

//==============================================================================
// Parent Control Functions
//==============================================================================

function p_ellipse_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_parent#') then Exit;
  Result.p := TBasEllipse(Args[0].p).Parent;
end;

function p_ellipse_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_parent#') then Exit;
  if not ValidateParent(Args[1].p, 'ellipse_parent#') then Exit;
  TBasEllipse(Args[0].p).Parent := TFmxObject(Args[1].p);
end;

function p_ellipse_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_bringtofront#') then Exit;
  TBasEllipse(Args[0].p).BringToFront();
end;

function p_ellipse_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_sendtoback#') then Exit;
  TBasEllipse(Args[0].p).SendToBack();
end;

function p_ellipse_invalidate(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_invalidate#') then Exit;
  TBasEllipse(Args[0].p).Repaint();
end;

//==============================================================================
// Event Callback Functions
//==============================================================================

function p_ellipse_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onclick#') then Exit;
  TBasEllipse(Args[0].p).OnClickFunc := Args[1].s;
end;

function s_ellipse_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onclick$') then Exit;
  Result.s := TBasEllipse(Args[0].p).OnClickFunc;
end;

function p_ellipse_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_ondblclick#') then Exit;
  TBasEllipse(Args[0].p).OnDblClickFunc := Args[1].s;
end;

function s_ellipse_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_ondblclick$') then Exit;
  Result.s := TBasEllipse(Args[0].p).OnDblClickFunc;
end;

function p_ellipse_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onmousedown#') then Exit;
  TBasEllipse(Args[0].p).OnMouseDownFunc := Args[1].s;
end;

function s_ellipse_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onmousedown$') then Exit;
  Result.s := TBasEllipse(Args[0].p).OnMouseDownFunc;
end;

function p_ellipse_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onmouseup#') then Exit;
  TBasEllipse(Args[0].p).OnMouseUpFunc := Args[1].s;
end;

function s_ellipse_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onmouseup$') then Exit;
  Result.s := TBasEllipse(Args[0].p).OnMouseUpFunc;
end;

function p_ellipse_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onmousemove#') then Exit;
  TBasEllipse(Args[0].p).OnMouseMoveFunc := Args[1].s;
end;

function s_ellipse_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onmousemove$') then Exit;
  Result.s := TBasEllipse(Args[0].p).OnMouseMoveFunc;
end;

function p_ellipse_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onmouseenter#') then Exit;
  TBasEllipse(Args[0].p).OnMouseEnterFunc := Args[1].s;
end;

function s_ellipse_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onmouseenter$') then Exit;
  Result.s := TBasEllipse(Args[0].p).OnMouseEnterFunc;
end;

function p_ellipse_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onmouseleave#') then Exit;
  TBasEllipse(Args[0].p).OnMouseLeaveFunc := Args[1].s;
end;

function s_ellipse_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onmouseleave$') then Exit;
  Result.s := TBasEllipse(Args[0].p).OnMouseLeaveFunc;
end;

function p_ellipse_onmousewheel_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onmousewheel#') then Exit;
  TBasEllipse(Args[0].p).OnMouseWheelFunc := Args[1].s;
end;

function s_ellipse_onmousewheel_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onmousewheel$') then Exit;
  Result.s := TBasEllipse(Args[0].p).OnMouseWheelFunc;
end;

function p_ellipse_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onresize#') then Exit;
  TBasEllipse(Args[0].p).OnResizeFunc := Args[1].s;
end;

function s_ellipse_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_onresize$') then Exit;
  Result.s := TBasEllipse(Args[0].p).OnResizeFunc;
end;

function p_ellipse_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateEllipse(Args[0].p, 'ellipse_clearcallbacks#') then Exit;
  TBasEllipse(Args[0].p).OnClickFunc := '';
  TBasEllipse(Args[0].p).OnDblClickFunc := '';
  TBasEllipse(Args[0].p).OnMouseDownFunc := '';
  TBasEllipse(Args[0].p).OnMouseUpFunc := '';
  TBasEllipse(Args[0].p).OnMouseMoveFunc := '';
  TBasEllipse(Args[0].p).OnMouseEnterFunc := '';
  TBasEllipse(Args[0].p).OnMouseLeaveFunc := '';
  TBasEllipse(Args[0].p).OnMouseWheelFunc := '';
  TBasEllipse(Args[0].p).OnResizeFunc := '';
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterEllipseFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin

  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_ellipse_error; Lib.Add('ellipse_error@', Fn);
  Fn.Entry := @s_ellipse_errormsg; Lib.Add('ellipse_errormsg$@', Fn);
  Fn.Entry := @s_ellipse_strerror; Lib.Add('ellipse_strerror$@n', Fn);
  Fn.Entry := @n_ellipse_clearerror; Lib.Add('ellipse_clearerror@', Fn);

  // Ellipse creation/destruction
  Fn.Entry := @p_ellipse_new; Lib.Add('ellipse#@#', Fn);
  Fn.Entry := @p_ellipse_new_size; Lib.Add('ellipse#@#nn', Fn);
  Fn.Entry := @p_ellipse_new_full; Lib.Add('ellipse#@#nnnn', Fn);
  Fn.Entry := @n_ellipse_free; Lib.Add('ellipse_free@#', Fn);

  // Fill
  Fn.Entry := @s_ellipse_fill_get; Lib.Add('ellipse_fill$@#', Fn);
  Fn.Entry := @p_ellipse_fill_set; Lib.Add('ellipse_fill#@#$', Fn);
  Fn.Entry := @p_ellipse_fillnone; Lib.Add('ellipse_fillnone#@#', Fn);

  // Stroke
  Fn.Entry := @s_ellipse_stroke_get; Lib.Add('ellipse_stroke$@#', Fn);
  Fn.Entry := @p_ellipse_stroke_set; Lib.Add('ellipse_stroke#@#$', Fn);
  Fn.Entry := @p_ellipse_strokenone; Lib.Add('ellipse_strokenone#@#', Fn);
  Fn.Entry := @n_ellipse_strokethickness_get; Lib.Add('ellipse_strokethickness@#', Fn);
  Fn.Entry := @p_ellipse_strokethickness_set; Lib.Add('ellipse_strokethickness#@#n', Fn);
  Fn.Entry := @n_ellipse_strokedash_get; Lib.Add('ellipse_strokedash@#', Fn);
  Fn.Entry := @p_ellipse_strokedash_set; Lib.Add('ellipse_strokedash#@#n', Fn);
  Fn.Entry := @n_ellipse_strokecap_get; Lib.Add('ellipse_strokecap@#', Fn);
  Fn.Entry := @p_ellipse_strokecap_set; Lib.Add('ellipse_strokecap#@#n', Fn);
  Fn.Entry := @n_ellipse_strokejoin_get; Lib.Add('ellipse_strokejoin@#', Fn);
  Fn.Entry := @p_ellipse_strokejoin_set; Lib.Add('ellipse_strokejoin#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_ellipse_x_get; Lib.Add('ellipse_x@#', Fn);
  Fn.Entry := @p_ellipse_x_set; Lib.Add('ellipse_x#@#n', Fn);
  Fn.Entry := @n_ellipse_y_get; Lib.Add('ellipse_y@#', Fn);
  Fn.Entry := @p_ellipse_y_set; Lib.Add('ellipse_y#@#n', Fn);
  Fn.Entry := @n_ellipse_width_get; Lib.Add('ellipse_width@#', Fn);
  Fn.Entry := @p_ellipse_width_set; Lib.Add('ellipse_width#@#n', Fn);
  Fn.Entry := @n_ellipse_height_get; Lib.Add('ellipse_height@#', Fn);
  Fn.Entry := @p_ellipse_height_set; Lib.Add('ellipse_height#@#n', Fn);
  Fn.Entry := @p_ellipse_bounds_set; Lib.Add('ellipse_bounds#@#nnnn', Fn);
  Fn.Entry := @p_ellipse_size_set; Lib.Add('ellipse_size#@#nn', Fn);
  Fn.Entry := @p_ellipse_move_set; Lib.Add('ellipse_move#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_ellipse_align_get; Lib.Add('ellipse_align@#', Fn);
  Fn.Entry := @p_ellipse_align_set; Lib.Add('ellipse_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_ellipse_marginleft_get; Lib.Add('ellipse_marginleft@#', Fn);
  Fn.Entry := @p_ellipse_marginleft_set; Lib.Add('ellipse_marginleft#@#n', Fn);
  Fn.Entry := @n_ellipse_margintop_get; Lib.Add('ellipse_margintop@#', Fn);
  Fn.Entry := @p_ellipse_margintop_set; Lib.Add('ellipse_margintop#@#n', Fn);
  Fn.Entry := @n_ellipse_marginright_get; Lib.Add('ellipse_marginright@#', Fn);
  Fn.Entry := @p_ellipse_marginright_set; Lib.Add('ellipse_marginright#@#n', Fn);
  Fn.Entry := @n_ellipse_marginbottom_get; Lib.Add('ellipse_marginbottom@#', Fn);
  Fn.Entry := @p_ellipse_marginbottom_set; Lib.Add('ellipse_marginbottom#@#n', Fn);
  Fn.Entry := @p_ellipse_margins_set; Lib.Add('ellipse_margins#@#nnnn', Fn);
  Fn.Entry := @p_ellipse_margin_set; Lib.Add('ellipse_margin#@#n', Fn);

  // Visibility and Behavior
  Fn.Entry := @n_ellipse_visible_get; Lib.Add('ellipse_visible@#', Fn);
  Fn.Entry := @p_ellipse_visible_set; Lib.Add('ellipse_visible#@#n', Fn);
  Fn.Entry := @n_ellipse_enabled_get; Lib.Add('ellipse_enabled@#', Fn);
  Fn.Entry := @p_ellipse_enabled_set; Lib.Add('ellipse_enabled#@#n', Fn);
  Fn.Entry := @n_ellipse_opacity_get; Lib.Add('ellipse_opacity@#', Fn);
  Fn.Entry := @p_ellipse_opacity_set; Lib.Add('ellipse_opacity#@#n', Fn);
  Fn.Entry := @n_ellipse_hittest_get; Lib.Add('ellipse_hittest@#', Fn);
  Fn.Entry := @p_ellipse_hittest_set; Lib.Add('ellipse_hittest#@#n', Fn);

  // Tag and Rotation
  Fn.Entry := @n_ellipse_tag_get; Lib.Add('ellipse_tag@#', Fn);
  Fn.Entry := @p_ellipse_tag_set; Lib.Add('ellipse_tag#@#n', Fn);
  Fn.Entry := @n_ellipse_rotation_get; Lib.Add('ellipse_rotation@#', Fn);
  Fn.Entry := @p_ellipse_rotation_set; Lib.Add('ellipse_rotation#@#n', Fn);

  // Parent control
  Fn.Entry := @p_ellipse_parent_get; Lib.Add('ellipse_parent#@#', Fn);
  Fn.Entry := @p_ellipse_parent_set; Lib.Add('ellipse_parent#@##', Fn);
  Fn.Entry := @p_ellipse_bringtofront; Lib.Add('ellipse_bringtofront#@#', Fn);
  Fn.Entry := @p_ellipse_sendtoback; Lib.Add('ellipse_sendtoback#@#', Fn);
  Fn.Entry := @p_ellipse_invalidate; Lib.Add('ellipse_invalidate#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_ellipse_onclick_set; Lib.Add('ellipse_onclick#@#$', Fn);
  Fn.Entry := @s_ellipse_onclick_get; Lib.Add('ellipse_onclick$@#', Fn);
  Fn.Entry := @p_ellipse_ondblclick_set; Lib.Add('ellipse_ondblclick#@#$', Fn);
  Fn.Entry := @s_ellipse_ondblclick_get; Lib.Add('ellipse_ondblclick$@#', Fn);
  Fn.Entry := @p_ellipse_onmousedown_set; Lib.Add('ellipse_onmousedown#@#$', Fn);
  Fn.Entry := @s_ellipse_onmousedown_get; Lib.Add('ellipse_onmousedown$@#', Fn);
  Fn.Entry := @p_ellipse_onmouseup_set; Lib.Add('ellipse_onmouseup#@#$', Fn);
  Fn.Entry := @s_ellipse_onmouseup_get; Lib.Add('ellipse_onmouseup$@#', Fn);
  Fn.Entry := @p_ellipse_onmousemove_set; Lib.Add('ellipse_onmousemove#@#$', Fn);
  Fn.Entry := @s_ellipse_onmousemove_get; Lib.Add('ellipse_onmousemove$@#', Fn);
  Fn.Entry := @p_ellipse_onmouseenter_set; Lib.Add('ellipse_onmouseenter#@#$', Fn);
  Fn.Entry := @s_ellipse_onmouseenter_get; Lib.Add('ellipse_onmouseenter$@#', Fn);
  Fn.Entry := @p_ellipse_onmouseleave_set; Lib.Add('ellipse_onmouseleave#@#$', Fn);
  Fn.Entry := @s_ellipse_onmouseleave_get; Lib.Add('ellipse_onmouseleave$@#', Fn);
  Fn.Entry := @p_ellipse_onmousewheel_set; Lib.Add('ellipse_onmousewheel#@#$', Fn);
  Fn.Entry := @s_ellipse_onmousewheel_get; Lib.Add('ellipse_onmousewheel$@#', Fn);
  Fn.Entry := @p_ellipse_onresize_set; Lib.Add('ellipse_onresize#@#$', Fn);
  Fn.Entry := @s_ellipse_onresize_get; Lib.Add('ellipse_onresize$@#', Fn);
  Fn.Entry := @p_ellipse_clearcallbacks; Lib.Add('ellipse_clearcallbacks#@#', Fn);
end;

end.

