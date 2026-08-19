unit PathAnimationLib;

{******************************************************************************
  PathAnimationLib - Path Animation Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TPathAnimation wrapper functionality for
  animating controls along a path defined by SVG-like path data. Controls
  move smoothly along curves, lines, and complex trajectories.

  Function Count: 50+ functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PATH DATA STRING SYNTAX (SVG-like):
  ===================================
  M x,y       - MoveTo: Start point
  L x,y       - LineTo: Draw line to point
  H x         - HLineTo: Horizontal line to x
  V y         - VLineTo: Vertical line to y
  C x1,y1 x2,y2 x,y - CurveTo: Cubic Bézier curve
  S x2,y2 x,y - SmoothCurveTo: Smooth cubic Bézier
  Q x1,y1 x,y - QuadCurveTo: Quadratic Bézier curve
  T x,y       - SmoothQuadTo: Smooth quadratic Bézier
  A rx,ry rot large-arc sweep x,y - Arc
  Z           - ClosePath: Close current subpath

  Example paths:
  - "M 0,0 L 200,0 L 200,200 L 0,200 Z" - Square path
  - "M 100,0 Q 200,100 100,200 Q 0,100 100,0" - Figure-8 curve
  - "M 0,100 C 50,0 150,200 200,100" - S-curve

  ANIMATION TYPES (AnimationType):
  ================================
  - "In" - Acceleration at start
  - "Out" - Deceleration at end
  - "InOut" - Acceleration then deceleration

  INTERPOLATION TYPES:
  ====================
  - "Linear" - Constant speed along path
  - "Quadratic" - Smooth acceleration
  - "Cubic", "Quartic", "Quintic" - More pronounced
  - "Sinusoidal", "Exponential", "Circular" - Various curves
  - "Elastic", "Back", "Bounce" - Special effects

  EVENT SUPPORT:
  ==============
  - OnFinish: Animation completed
  - OnProcess: Called on each animation frame

  USAGE PATTERN:
  ==============
    let frm# = form#("Path Animation Demo", 400, 400)
    let circle# = circle#(frm#)
    circle_bounds#(circle#, 0, 0, 30, 30)
    circle_fill#(circle#, "Red")

    ' Create path animation - circle moves along a curved path
    let pathAni# = pathani#(circle#)
    pathani_path#(pathAni#, "M 50,200 C 100,50 300,50 350,200 C 300,350 100,350 50,200")
    pathani_duration#(pathAni#, 3.0)
    pathani_loop#(pathAni#, 1)
    pathani_start(pathAni#)

    form_show(frm#)

  ROTATE PROPERTY:
  ================
  When pathani_rotate#(ani#, 1) is set, the control rotates to follow
  the path tangent, useful for vehicles, arrows, or directional objects.

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.TypInfo,
  FMX.Types, FMX.Ani, FMX.Graphics, FMX.Objects, FMX.Controls,
  basic, exec, UnitGC, HandleRegistry, ControlCommon;

type
  TBasPathAnimation = class(TPathAnimation)
  private
    FOnFinishFunc: String;
    FOnProcessFunc: String;
    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;

    procedure InternalOnFinish(Sender: TObject);
    procedure InternalOnProcess(Sender: TObject);

    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);

    procedure SetOnFinishFunc(const Value: String);
    procedure SetOnProcessFunc(const Value: String);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure DisconnectAllEvents();

    property OnFinishFunc: String read FOnFinishFunc write SetOnFinishFunc;
    property OnProcessFunc: String read FOnProcessFunc write SetOnProcessFunc;
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
  end;

procedure RegisterPathAnimationFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

var
  ModuleEngine: TBasicEngine;
  ModuleOutput: TStrings;
  LastError: Integer = 0;
  LastErrorMsg: String = '';

const
  ERR_NONE = 0;
  ERR_NIL_ANIMATION = 1;
  ERR_INVALID_PROPERTY = 2;
  ERR_INVALID_VALUE = 3;
  ERR_ANIMATION_RUNNING = 4;
  ERR_INVALID_PATH = 5;

// =============================================================================
// Error Handling
// =============================================================================

procedure SetError(Code: Integer; const Msg: String);
begin
  LastError := Code;
  LastErrorMsg := Msg;
end;

procedure ClearError();
begin
  LastError := ERR_NONE;
  LastErrorMsg := '';
end;

function ValidateAnimation(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if not Assigned(P) then
  begin
    SetError(ERR_NIL_ANIMATION, FuncName + ': animation is nil');
    Exit;
  end;
  if not (IsHandleOf(P, TBasPathAnimation)) then
  begin
    SetError(ERR_INVALID_PROPERTY, FuncName + ': invalid animation object');
    Exit;
  end;
  Result := True;
end;

// =============================================================================
// TBasPathAnimation Implementation
// =============================================================================

constructor TBasPathAnimation.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);
  FOnFinishFunc := '';
  FOnProcessFunc := '';
  FBasicEngine := nil;
  FConsoleOutput := nil;
  // Events are NOT connected by default - only when callbacks are assigned
end;

destructor TBasPathAnimation.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasPathAnimation.DisconnectAllEvents();
begin
  OnFinish := nil;
  OnProcess := nil;
  FOnFinishFunc := '';
  FOnProcessFunc := '';
end;

procedure TBasPathAnimation.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  RetVal: TAsmData;
  I: Integer;
begin
  if UnitGC.GlobalCallbackBusy then Exit;
  if not Assigned(FBasicEngine) then Exit;
  if not Assigned(FConsoleOutput) then Exit;
  if FuncSignature = '' then Exit;

  UnitGC.GlobalCallbackBusy := True;
  UnitGC.SkipProcessMessages := True;

  try
    SetLength(CallArgs, Length(Args));
    for I := 0 to High(Args) do
      CallArgs[I] := Args[I];
    try
      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs, RetType, RetVal);
    except
      on E: Exception do
      begin
        FConsoleOutput.Add('*** PathAnimation Callback Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

procedure TBasPathAnimation.SetOnFinishFunc(const Value: String);
begin
  FOnFinishFunc := Value;
  if Value <> '' then
    OnFinish := InternalOnFinish
  else
    OnFinish := nil;
end;

procedure TBasPathAnimation.SetOnProcessFunc(const Value: String);
begin
  FOnProcessFunc := Value;
  if Value <> '' then
    OnProcess := InternalOnProcess
  else
    OnProcess := nil;
end;

procedure TBasPathAnimation.InternalOnFinish(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnFinishFunc = '' then Exit;

  SenderArg.n := 0;
  SenderArg.s := '';
  SenderArg.p := Pointer(Self);

  ExecuteCallback(LowerCase(FOnFinishFunc) + '@#', [SenderArg]);
end;

procedure TBasPathAnimation.InternalOnProcess(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnProcessFunc = '' then Exit;

  SenderArg.n := 0;
  SenderArg.s := '';
  SenderArg.p := Pointer(Self);

  ExecuteCallback(LowerCase(FOnProcessFunc) + '@#', [SenderArg]);
end;

// =============================================================================
// Library Functions - Error Handling
// =============================================================================

function n_pathani_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_pathani_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_pathani_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_NIL_ANIMATION: Result.s := 'Animation is nil';
    ERR_INVALID_PROPERTY: Result.s := 'Invalid property or object';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_ANIMATION_RUNNING: Result.s := 'Cannot modify while animation is running';
    ERR_INVALID_PATH: Result.s := 'Invalid path data';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_pathani_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 1;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Library Functions - Creation/Destruction
// =============================================================================

function p_pathani_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Ani: TBasPathAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  try
    // Create with parent as Owner - parent will free us when destroyed
    // This is safe because TBasRectAnimation is NOT a visual child (no Parent property)
    // Only the internal TFloatAnimation objects need Create(nil) to avoid double-free
    Ani := TBasPathAnimation.Create(TComponent(Args[0].p));
    Ani.Parent := TFmxObject(Args[0].p);
    //An animation is a TComponent with no Parent, so the walk starts at the
    //control it animates, which does have one.
    if EngineOf(TFmxObject(Args[0].p), Eng, Outp) then
    begin
      Ani.BasicEngine := Eng;
      Ani.ConsoleOutput := Outp;
    end;

    // Register with GC using NativeInt for 64-bit safety
    //UnitGC.GC.Add<TBasPathAnimation>(Ani, IntToStr(NativeInt(Ani)));

    Result.p := Pointer(Ani);
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani#: ' + E.Message);
  end;
end;

function p_pathani_new_named(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Ani: TBasPathAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  try
    // Create with parent as Owner - parent will free us when destroyed
    // This is safe because TBasRectAnimation is NOT a visual child (no Parent property)
    // Only the internal TFloatAnimation objects need Create(nil) to avoid double-free
    Ani := TBasPathAnimation.Create(TComponent(Args[0].p));
    Ani.Parent := TFmxObject(Args[0].p);
    Ani.Name := Args[1].s;
    //An animation is a TComponent with no Parent, so the walk starts at the
    //control it animates, which does have one.
    if EngineOf(TFmxObject(Args[0].p), Eng, Outp) then
    begin
      Ani.BasicEngine := Eng;
      Ani.ConsoleOutput := Outp;
    end;

    //UnitGC.GC.Add<TBasPathAnimation>(Ani, IntToStr(NativeInt(Ani)));

    Result.p := Pointer(Ani);
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani#: ' + E.Message);
  end;
end;

function n_pathani_free(var Args: array of TAsmData): TAsmData;
var
  Ani: TBasPathAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_free') then Exit;

  try
    Ani := TBasPathAnimation(Args[0].p);
    Ani.DisconnectAllEvents();
    //UnitGC.GC.Collect(IntToStr(NativeInt(Args[0].p)));
    Ani.Free();
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_free: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Animation Control
// =============================================================================

function n_pathani_start(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_start') then Exit;

  try
    TBasPathAnimation(Args[0].p).Start();
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_start: ' + E.Message);
  end;
end;

function n_pathani_stop(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_stop') then Exit;

  try
    TBasPathAnimation(Args[0].p).Stop();
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_stop: ' + E.Message);
  end;
end;

function n_pathani_stopatcurrent(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_stopatcurrent') then Exit;

  try
    TBasPathAnimation(Args[0].p).StopAtCurrent();
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_stopatcurrent: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Path Property (Core)
// =============================================================================

// Set path data from SVG-like string
function p_pathani_path_set(var Args: array of TAsmData): TAsmData;
var
  Ani: TBasPathAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_path#') then Exit;

  try
    Ani := TBasPathAnimation(Args[0].p);
    Ani.Path.Data := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PATH, 'pathani_path#: ' + E.Message);
  end;
end;

// Get path data as SVG-like string
function s_pathani_path_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_path$') then Exit;

  try
    Result.s := TBasPathAnimation(Args[0].p).Path.Data;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_path$: ' + E.Message);
  end;
end;

// Clear path data
function p_pathani_clearpath(var Args: array of TAsmData): TAsmData;
var
  Ani: TBasPathAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_clearpath#') then Exit;

  try
    Ani := TBasPathAnimation(Args[0].p);
    Ani.Path.Clear();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_clearpath#: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Rotate Property
// =============================================================================

function p_pathani_rotate_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_rotate#') then Exit;

  try
    TBasPathAnimation(Args[0].p).Rotate := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_rotate#: ' + E.Message);
  end;
end;

function n_pathani_rotate_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_rotate') then Exit;

  try
    if TBasPathAnimation(Args[0].p).Rotate then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_rotate: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Duration/Delay
// =============================================================================

function p_pathani_duration_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_duration#') then Exit;

  try
    TBasPathAnimation(Args[0].p).Duration := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_duration#: ' + E.Message);
  end;
end;

function n_pathani_duration_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_duration') then Exit;

  try
    Result.n := TBasPathAnimation(Args[0].p).Duration;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_duration: ' + E.Message);
  end;
end;

function p_pathani_delay_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_delay#') then Exit;

  try
    TBasPathAnimation(Args[0].p).Delay := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_delay#: ' + E.Message);
  end;
end;

function n_pathani_delay_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_delay') then Exit;

  try
    Result.n := TBasPathAnimation(Args[0].p).Delay;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_delay: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Animation Behavior
// =============================================================================

// AnimationType: "In", "Out", "InOut"
function p_pathani_animationtype_set(var Args: array of TAsmData): TAsmData;
var
  TypeStr: String;
  AniType: TAnimationType;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_animationtype#') then Exit;

  try
    TypeStr := LowerCase(Args[1].s);
    if TypeStr = 'in' then
      AniType := TAnimationType.In
    else if TypeStr = 'out' then
      AniType := TAnimationType.Out
    else if TypeStr = 'inout' then
      AniType := TAnimationType.InOut
    else
      AniType := TAnimationType.In;

    TBasPathAnimation(Args[0].p).AnimationType := AniType;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_animationtype#: ' + E.Message);
  end;
end;

function s_pathani_animationtype_get(var Args: array of TAsmData): TAsmData;
var
  AniType: TAnimationType;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_animationtype$') then Exit;

  try
    AniType := TBasPathAnimation(Args[0].p).AnimationType;
    case AniType of
      TAnimationType.In: Result.s := 'In';
      TAnimationType.Out: Result.s := 'Out';
      TAnimationType.InOut: Result.s := 'InOut';
    else
      Result.s := 'In';
    end;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_animationtype$: ' + E.Message);
  end;
end;

// Interpolation
function p_pathani_interpolation_set(var Args: array of TAsmData): TAsmData;
var
  InterpStr: String;
  Interp: TInterpolationType;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_interpolation#') then Exit;

  try
    InterpStr := LowerCase(Args[1].s);
    if InterpStr = 'linear' then
      Interp := TInterpolationType.Linear
    else if InterpStr = 'quadratic' then
      Interp := TInterpolationType.Quadratic
    else if InterpStr = 'cubic' then
      Interp := TInterpolationType.Cubic
    else if InterpStr = 'quartic' then
      Interp := TInterpolationType.Quartic
    else if InterpStr = 'quintic' then
      Interp := TInterpolationType.Quintic
    else if InterpStr = 'sinusoidal' then
      Interp := TInterpolationType.Sinusoidal
    else if InterpStr = 'exponential' then
      Interp := TInterpolationType.Exponential
    else if InterpStr = 'circular' then
      Interp := TInterpolationType.Circular
    else if InterpStr = 'elastic' then
      Interp := TInterpolationType.Elastic
    else if InterpStr = 'back' then
      Interp := TInterpolationType.Back
    else if InterpStr = 'bounce' then
      Interp := TInterpolationType.Bounce
    else
      Interp := TInterpolationType.Linear;

    TBasPathAnimation(Args[0].p).Interpolation := Interp;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_interpolation#: ' + E.Message);
  end;
end;

function s_pathani_interpolation_get(var Args: array of TAsmData): TAsmData;
var
  Interp: TInterpolationType;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_interpolation$') then Exit;

  try
    Interp := TBasPathAnimation(Args[0].p).Interpolation;
    case Interp of
      TInterpolationType.Linear: Result.s := 'Linear';
      TInterpolationType.Quadratic: Result.s := 'Quadratic';
      TInterpolationType.Cubic: Result.s := 'Cubic';
      TInterpolationType.Quartic: Result.s := 'Quartic';
      TInterpolationType.Quintic: Result.s := 'Quintic';
      TInterpolationType.Sinusoidal: Result.s := 'Sinusoidal';
      TInterpolationType.Exponential: Result.s := 'Exponential';
      TInterpolationType.Circular: Result.s := 'Circular';
      TInterpolationType.Elastic: Result.s := 'Elastic';
      TInterpolationType.Back: Result.s := 'Back';
      TInterpolationType.Bounce: Result.s := 'Bounce';
    else
      Result.s := 'Linear';
    end;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_interpolation$: ' + E.Message);
  end;
end;

// Loop
function p_pathani_loop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_loop#') then Exit;

  try
    TBasPathAnimation(Args[0].p).Loop := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_loop#: ' + E.Message);
  end;
end;

function n_pathani_loop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_loop') then Exit;

  try
    if TBasPathAnimation(Args[0].p).Loop then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_loop: ' + E.Message);
  end;
end;

// AutoReverse
function p_pathani_autoreverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_autoreverse#') then Exit;

  try
    TBasPathAnimation(Args[0].p).AutoReverse := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_autoreverse#: ' + E.Message);
  end;
end;

function n_pathani_autoreverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_autoreverse') then Exit;

  try
    if TBasPathAnimation(Args[0].p).AutoReverse then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_autoreverse: ' + E.Message);
  end;
end;

// Inverse
function p_pathani_inverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_inverse#') then Exit;

  try
    TBasPathAnimation(Args[0].p).Inverse := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_inverse#: ' + E.Message);
  end;
end;

function n_pathani_inverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_inverse') then Exit;

  try
    if TBasPathAnimation(Args[0].p).Inverse then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_inverse: ' + E.Message);
  end;
end;

// Enabled
function p_pathani_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_enabled#') then Exit;

  try
    TBasPathAnimation(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_enabled#: ' + E.Message);
  end;
end;

function n_pathani_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_enabled') then Exit;

  try
    if TBasPathAnimation(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - State Queries
// =============================================================================

function n_pathani_running(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_running') then Exit;

  try
    if TBasPathAnimation(Args[0].p).Running then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_running: ' + E.Message);
  end;
end;

function n_pathani_normalizedtime(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_normalizedtime') then Exit;

  try
    Result.n := TBasPathAnimation(Args[0].p).NormalizedTime;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_normalizedtime: ' + E.Message);
  end;
end;

function s_pathani_name(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_name$') then Exit;

  try
    Result.s := TBasPathAnimation(Args[0].p).Name;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_name$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Triggers
// =============================================================================

function p_pathani_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_trigger#') then Exit;

  try
    TBasPathAnimation(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_trigger#: ' + E.Message);
  end;
end;

function s_pathani_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_trigger$') then Exit;

  try
    Result.s := TBasPathAnimation(Args[0].p).Trigger;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_trigger$: ' + E.Message);
  end;
end;

function p_pathani_triggerinverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_triggerinverse#') then Exit;

  try
    TBasPathAnimation(Args[0].p).TriggerInverse := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_triggerinverse#: ' + E.Message);
  end;
end;

function s_pathani_triggerinverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_triggerinverse$') then Exit;

  try
    Result.s := TBasPathAnimation(Args[0].p).TriggerInverse;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_triggerinverse$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Event Callbacks
// =============================================================================

function p_pathani_onfinish_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_onfinish#') then Exit;

  try
    TBasPathAnimation(Args[0].p).OnFinishFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_onfinish#: ' + E.Message);
  end;
end;

function s_pathani_onfinish_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_onfinish$') then Exit;

  try
    Result.s := TBasPathAnimation(Args[0].p).OnFinishFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_onfinish$: ' + E.Message);
  end;
end;

function p_pathani_onprocess_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_onprocess#') then Exit;

  try
    TBasPathAnimation(Args[0].p).OnProcessFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pathani_onprocess#: ' + E.Message);
  end;
end;

function s_pathani_onprocess_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_onprocess$') then Exit;

  try
    Result.s := TBasPathAnimation(Args[0].p).OnProcessFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_onprocess$: ' + E.Message);
  end;
end;

function p_pathani_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'pathani_clearcallbacks#') then Exit;

  try
    TBasPathAnimation(Args[0].p).DisconnectAllEvents();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'pathani_clearcallbacks#: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterPathAnimationFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_pathani_error; Lib.Add('pathani_error@', Fn);
  Fn.Entry := @s_pathani_errormsg; Lib.Add('pathani_errormsg$@', Fn);
  Fn.Entry := @s_pathani_strerror; Lib.Add('pathani_strerror$@n', Fn);
  Fn.Entry := @n_pathani_clearerror; Lib.Add('pathani_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_pathani_new; Lib.Add('pathani#@#', Fn);
  Fn.Entry := @p_pathani_new_named; Lib.Add('pathani#@#$', Fn);
  Fn.Entry := @n_pathani_free; Lib.Add('pathani_free@#', Fn);

  // Animation control
  Fn.Entry := @n_pathani_start; Lib.Add('pathani_start@#', Fn);
  Fn.Entry := @n_pathani_stop; Lib.Add('pathani_stop@#', Fn);
  Fn.Entry := @n_pathani_stopatcurrent; Lib.Add('pathani_stopatcurrent@#', Fn);

  // Path property
  Fn.Entry := @p_pathani_path_set; Lib.Add('pathani_path#@#$', Fn);
  Fn.Entry := @s_pathani_path_get; Lib.Add('pathani_path$@#', Fn);
  Fn.Entry := @p_pathani_clearpath; Lib.Add('pathani_clearpath#@#', Fn);

  // Rotate property
  Fn.Entry := @p_pathani_rotate_set; Lib.Add('pathani_rotate#@#n', Fn);
  Fn.Entry := @n_pathani_rotate_get; Lib.Add('pathani_rotate@#', Fn);

  // Duration/Delay
  Fn.Entry := @p_pathani_duration_set; Lib.Add('pathani_duration#@#n', Fn);
  Fn.Entry := @n_pathani_duration_get; Lib.Add('pathani_duration@#', Fn);
  Fn.Entry := @p_pathani_delay_set; Lib.Add('pathani_delay#@#n', Fn);
  Fn.Entry := @n_pathani_delay_get; Lib.Add('pathani_delay@#', Fn);

  // Animation behavior
  Fn.Entry := @p_pathani_animationtype_set; Lib.Add('pathani_animationtype#@#$', Fn);
  Fn.Entry := @s_pathani_animationtype_get; Lib.Add('pathani_animationtype$@#', Fn);
  Fn.Entry := @p_pathani_interpolation_set; Lib.Add('pathani_interpolation#@#$', Fn);
  Fn.Entry := @s_pathani_interpolation_get; Lib.Add('pathani_interpolation$@#', Fn);
  Fn.Entry := @p_pathani_loop_set; Lib.Add('pathani_loop#@#n', Fn);
  Fn.Entry := @n_pathani_loop_get; Lib.Add('pathani_loop@#', Fn);
  Fn.Entry := @p_pathani_autoreverse_set; Lib.Add('pathani_autoreverse#@#n', Fn);
  Fn.Entry := @n_pathani_autoreverse_get; Lib.Add('pathani_autoreverse@#', Fn);
  Fn.Entry := @p_pathani_inverse_set; Lib.Add('pathani_inverse#@#n', Fn);
  Fn.Entry := @n_pathani_inverse_get; Lib.Add('pathani_inverse@#', Fn);
  Fn.Entry := @p_pathani_enabled_set; Lib.Add('pathani_enabled#@#n', Fn);
  Fn.Entry := @n_pathani_enabled_get; Lib.Add('pathani_enabled@#', Fn);

  // State queries
  Fn.Entry := @n_pathani_running; Lib.Add('pathani_running@#', Fn);
  Fn.Entry := @n_pathani_normalizedtime; Lib.Add('pathani_normalizedtime@#', Fn);
  Fn.Entry := @s_pathani_name; Lib.Add('pathani_name$@#', Fn);

  // Triggers
  Fn.Entry := @p_pathani_trigger_set; Lib.Add('pathani_trigger#@#$', Fn);
  Fn.Entry := @s_pathani_trigger_get; Lib.Add('pathani_trigger$@#', Fn);
  Fn.Entry := @p_pathani_triggerinverse_set; Lib.Add('pathani_triggerinverse#@#$', Fn);
  Fn.Entry := @s_pathani_triggerinverse_get; Lib.Add('pathani_triggerinverse$@#', Fn);

  // Event callbacks
  Fn.Entry := @p_pathani_onfinish_set; Lib.Add('pathani_onfinish#@#$', Fn);
  Fn.Entry := @s_pathani_onfinish_get; Lib.Add('pathani_onfinish$@#', Fn);
  Fn.Entry := @p_pathani_onprocess_set; Lib.Add('pathani_onprocess#@#$', Fn);
  Fn.Entry := @s_pathani_onprocess_get; Lib.Add('pathani_onprocess$@#', Fn);
  Fn.Entry := @p_pathani_clearcallbacks; Lib.Add('pathani_clearcallbacks#@#', Fn);
end;

end.

