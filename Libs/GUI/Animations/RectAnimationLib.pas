unit RectAnimationLib;

{******************************************************************************
  RectAnimationLib - Bounds Animation Library for Plan9Basic
  Version: 2.0.0

  Provides bounds-based animation for animating Position.X, Position.Y,
  Width, and Height simultaneously using 4 synchronized TFloatAnimation
  objects internally.

  This is a COMPOSITE animation - it manages 4 TFloatAnimation objects
  internally to achieve smooth position+size animation.

  NOTE: NO rectani_propertyname# function needed - this library always
  animates position and size together.

  Copyright (c) 2024-2026 André Murta
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.TypInfo,
  FMX.Types, FMX.Controls, FMX.Ani,
  basic, exec, UnitGC, ControlCommon;

type
  TBasRectAnimation = class(TComponent)
  private
    FAniX: TFloatAnimation;
    FAniY: TFloatAnimation;
    FAniW: TFloatAnimation;
    FAniH: TFloatAnimation;
    FParentControl: TControl;

    FStartX, FStartY, FStartW, FStartH: Single;
    FStopX, FStopY, FStopW, FStopH: Single;
    FDuration: Single;
    FDelay: Single;
    FLoop: Boolean;
    FAutoReverse: Boolean;
    FInverse: Boolean;
    FEnabled: Boolean;
    FAnimationType: TAnimationType;
    FInterpolation: TInterpolationType;

    FOnFinishFunc: String;
    FOnProcessFunc: String;
    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;

    procedure CreateInternalAnimations;
    procedure SyncPropertiesToAnimations;
    procedure InternalOnFinish(Sender: TObject);
    procedure InternalOnProcess(Sender: TObject);
    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
    procedure SetOnFinishFunc(const Value: String);
    procedure SetOnProcessFunc(const Value: String);

  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Start;
    procedure Stop;
    procedure StopAtCurrent;
    function Running: Boolean;
    function NormalizedTime: Single;
    procedure DisconnectAllEvents;
    procedure SetTarget(ATarget: TControl);

    property StartX: Single read FStartX write FStartX;
    property StartY: Single read FStartY write FStartY;
    property StartWidth: Single read FStartW write FStartW;
    property StartHeight: Single read FStartH write FStartH;

    property StopX: Single read FStopX write FStopX;
    property StopY: Single read FStopY write FStopY;
    property StopWidth: Single read FStopW write FStopW;
    property StopHeight: Single read FStopH write FStopH;

    property Duration: Single read FDuration write FDuration;
    property Delay: Single read FDelay write FDelay;
    property Loop: Boolean read FLoop write FLoop;
    property AutoReverse: Boolean read FAutoReverse write FAutoReverse;
    property Inverse: Boolean read FInverse write FInverse;
    property Enabled: Boolean read FEnabled write FEnabled;
    property AnimationType: TAnimationType read FAnimationType write FAnimationType;
    property Interpolation: TInterpolationType read FInterpolation write FInterpolation;

    property OnFinishFunc: String read FOnFinishFunc write SetOnFinishFunc;
    property OnProcessFunc: String read FOnProcessFunc write SetOnProcessFunc;
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
    property ParentControl: TControl read FParentControl;
  end;

procedure RegisterRectAnimationFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

var
  LastError: Integer = 0;
  LastErrorMsg: String = '';

const
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_NIL_ANIMATION = 1;
  ERR_INVALID_PROPERTY = 2;
  ERR_INVALID_VALUE = 3;
  ERR_ANIMATION_RUNNING = 4;

constructor TBasRectAnimation.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if AOwner is TControl then
    FParentControl := TControl(AOwner)
  else
    FParentControl := nil;

  FDuration := 0.4;
  FDelay := 0;
  FLoop := False;
  FAutoReverse := False;
  FInverse := False;
  FEnabled := True;
  FAnimationType := TAnimationType.In;
  FInterpolation := TInterpolationType.Linear;

  FStartX := 0; FStartY := 0; FStartW := 100; FStartH := 100;
  FStopX := 0; FStopY := 0; FStopW := 100; FStopH := 100;

  FOnFinishFunc := '';
  FOnProcessFunc := '';

  CreateInternalAnimations;
end;

procedure TBasRectAnimation.CreateInternalAnimations;
begin
  if FParentControl = nil then Exit;
  if FAniX <> nil then Exit; // Already created

  // Create with NIL owner - only set Parent
  // The Parent relationship is all that's needed for animation to work
  // This avoids double-free (Owner list + Children list both trying to free)
  FAniX := TFloatAnimation.Create(nil);
  FAniX.Parent := FParentControl;
  FAniX.PropertyName := 'Position.X';
  FAniX.FreeNotification(Self);

  FAniY := TFloatAnimation.Create(nil);
  FAniY.Parent := FParentControl;
  FAniY.PropertyName := 'Position.Y';
  FAniY.FreeNotification(Self);

  FAniW := TFloatAnimation.Create(nil);
  FAniW.Parent := FParentControl;
  FAniW.PropertyName := 'Width';
  FAniW.FreeNotification(Self);

  FAniH := TFloatAnimation.Create(nil);
  FAniH.Parent := FParentControl;
  FAniH.PropertyName := 'Height';
  FAniH.FreeNotification(Self);

  FAniX.OnFinish := InternalOnFinish;
  FAniX.OnProcess := InternalOnProcess;
end;

procedure TBasRectAnimation.SetTarget(ATarget: TControl);
begin
  FParentControl := ATarget;
  CreateInternalAnimations;
end;

destructor TBasRectAnimation.Destroy;
begin
  // Disconnect our event handlers first
  try
    if FAniX <> nil then begin FAniX.OnFinish := nil; FAniX.OnProcess := nil; end;
  except
    //Teardown path: the only sane action is to keep unwinding. SetError is
    //also declared further down this unit and is not in scope here.
  end;

  // We don't own the animations (FParentControl does), so don't free them
  // Just clear our references - FreeNotification/Notification handles this if they're freed first
  FAniX := nil;
  FAniY := nil;
  FAniW := nil;
  FAniH := nil;

  FOnFinishFunc := '';
  FOnProcessFunc := '';

  inherited;
end;

procedure TBasRectAnimation.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  // When animations are freed (by parent control's destruction), set pointers to nil
  // This prevents us from accessing freed memory in destructor
  if Operation = opRemove then
  begin
    if AComponent = FAniX then FAniX := nil
    else if AComponent = FAniY then FAniY := nil
    else if AComponent = FAniW then FAniW := nil
    else if AComponent = FAniH then FAniH := nil;
  end;
end;

procedure TBasRectAnimation.DisconnectAllEvents;
begin
  try
    if FAniX <> nil then
    begin
      FAniX.OnFinish := nil;
      FAniX.OnProcess := nil;
    end;
  except
    //Teardown path: the only sane action is to keep unwinding. SetError is
    //also declared further down this unit and is not in scope here.
  end;
  FOnFinishFunc := '';
  FOnProcessFunc := '';
end;

procedure TBasRectAnimation.SyncPropertiesToAnimations;
begin
  if FAniX = nil then Exit;

  FAniX.StartValue := FStartX;
  FAniX.StopValue := FStopX;
  FAniX.Duration := FDuration;
  FAniX.Delay := FDelay;
  FAniX.Loop := FLoop;
  FAniX.AutoReverse := FAutoReverse;
  FAniX.Inverse := FInverse;
  FAniX.Enabled := FEnabled;
  FAniX.AnimationType := FAnimationType;
  FAniX.Interpolation := FInterpolation;

  FAniY.StartValue := FStartY;
  FAniY.StopValue := FStopY;
  FAniY.Duration := FDuration;
  FAniY.Delay := FDelay;
  FAniY.Loop := FLoop;
  FAniY.AutoReverse := FAutoReverse;
  FAniY.Inverse := FInverse;
  FAniY.Enabled := FEnabled;
  FAniY.AnimationType := FAnimationType;
  FAniY.Interpolation := FInterpolation;

  FAniW.StartValue := FStartW;
  FAniW.StopValue := FStopW;
  FAniW.Duration := FDuration;
  FAniW.Delay := FDelay;
  FAniW.Loop := FLoop;
  FAniW.AutoReverse := FAutoReverse;
  FAniW.Inverse := FInverse;
  FAniW.Enabled := FEnabled;
  FAniW.AnimationType := FAnimationType;
  FAniW.Interpolation := FInterpolation;

  FAniH.StartValue := FStartH;
  FAniH.StopValue := FStopH;
  FAniH.Duration := FDuration;
  FAniH.Delay := FDelay;
  FAniH.Loop := FLoop;
  FAniH.AutoReverse := FAutoReverse;
  FAniH.Inverse := FInverse;
  FAniH.Enabled := FEnabled;
  FAniH.AnimationType := FAnimationType;
  FAniH.Interpolation := FInterpolation;
end;

procedure TBasRectAnimation.Start;
begin
  if FAniX = nil then Exit;
  SyncPropertiesToAnimations;
  FAniX.Start;
  FAniY.Start;
  FAniW.Start;
  FAniH.Start;
end;

procedure TBasRectAnimation.Stop;
begin
  if FAniX = nil then Exit;
  FAniX.Stop;
  FAniY.Stop;
  FAniW.Stop;
  FAniH.Stop;
end;

procedure TBasRectAnimation.StopAtCurrent;
begin
  if FAniX = nil then Exit;
  FAniX.StopAtCurrent;
  FAniY.StopAtCurrent;
  FAniW.StopAtCurrent;
  FAniH.StopAtCurrent;
end;

function TBasRectAnimation.Running: Boolean;
begin
  if FAniX <> nil then
    Result := FAniX.Running
  else
    Result := False;
end;

function TBasRectAnimation.NormalizedTime: Single;
begin
  if FAniX <> nil then
    Result := FAniX.NormalizedTime
  else
    Result := 0;
end;

procedure TBasRectAnimation.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  RetVal: TAsmData;
  I: Integer;
begin
  if UnitGC.CallbackInProgress() then Exit;
  if not Assigned(FBasicEngine) then Exit;
  if not Assigned(FConsoleOutput) then Exit;
  if FuncSignature = '' then Exit;

  if not UnitGC.ClaimCallbackGuard() then
    Exit();
  UnitGC.SkipProcessMessages := True;

  try
    SetLength(CallArgs, Length(Args));
    for I := 0 to High(Args) do
      CallArgs[I] := Args[I];
    try
      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs,
        RetType, RetVal);
    except
      on E: Exception do
        FConsoleOutput.Add('*** RectAnimation Callback Error: ' + E.Message);
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.ReleaseCallbackGuard();
  end;
end;

procedure TBasRectAnimation.InternalOnFinish(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnFinishFunc = '' then Exit;
  SenderArg.n := 0;
  SenderArg.s := '';
  SenderArg.p := Pointer(Self);
  ExecuteCallback(LowerCase(FOnFinishFunc) + '@#', [SenderArg]);
end;

procedure TBasRectAnimation.InternalOnProcess(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnProcessFunc = '' then Exit;
  SenderArg.n := 0;
  SenderArg.s := '';
  SenderArg.p := Pointer(Self);
  ExecuteCallback(LowerCase(FOnProcessFunc) + '@#', [SenderArg]);
end;

procedure TBasRectAnimation.SetOnFinishFunc(const Value: String);
begin
  FOnFinishFunc := Value;
end;

procedure TBasRectAnimation.SetOnProcessFunc(const Value: String);
begin
  FOnProcessFunc := Value;
end;

procedure SetError(Code: Integer; const Msg: String);
begin
  LastError := Code;
  LastErrorMsg := Msg;
end;

procedure ClearError;
begin
  LastError := ERR_NONE;
  LastErrorMsg := '';
end;

function ValidateAnimation(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_NIL_ANIMATION, FuncName + ': Animation is nil');
    Exit;
  end;
  Result := True;
end;

function n_rectani_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_rectani_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_rectani_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Trunc(Args[0].n) of
    ERR_NONE: Result.s := 'No error';
    ERR_NIL_ANIMATION: Result.s := 'Animation is nil';
    ERR_INVALID_PROPERTY: Result.s := 'Invalid property or object';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_ANIMATION_RUNNING: Result.s := 'Cannot modify while animation is running';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_rectani_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 1;
  Result.s := '';
  Result.p := nil;
end;

function p_rectani_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Ani: TBasRectAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;
  try
    // Create with parent as Owner - parent will free us when destroyed
    // This is safe because TBasRectAnimation is NOT a visual child (no Parent property)
    // Only the internal TFloatAnimation objects need Create(nil) to avoid double-free
    Ani := TBasRectAnimation.Create(TComponent(Args[0].p));
    Ani.SetTarget(TControl(Args[0].p));
    //An animation is a TComponent with no Parent, so the walk starts at the
    //control it animates, which does have one.
    if EngineOf(TFmxObject(Args[0].p), Eng, Outp) then
    begin
      Ani.BasicEngine := Eng;
      Ani.ConsoleOutput := Outp;
    end;
    Result.p := Pointer(Ani);
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'rectani#: ' + E.Message);
  end;
end;

function p_rectani_new_named(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Ani: TBasRectAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;
  try
    Ani := TBasRectAnimation.Create(TComponent(Args[0].p));
    Ani.SetTarget(TControl(Args[0].p));
    Ani.Name := Args[1].s;
    //An animation is a TComponent with no Parent, so the walk starts at the
    //control it animates, which does have one.
    if EngineOf(TFmxObject(Args[0].p), Eng, Outp) then
    begin
      Ani.BasicEngine := Eng;
      Ani.ConsoleOutput := Outp;
    end;
    Result.p := Pointer(Ani);
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'rectani#: ' + E.Message);
  end;
end;

function n_rectani_free(var Args: array of TAsmData): TAsmData;
var
  Ani: TBasRectAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_free') then Exit;
  try
    Ani := TBasRectAnimation(Args[0].p);
    Ani.DisconnectAllEvents;
    Ani.Free;  // Direct free - removes itself from Owner's component list
    Result.n := 1;
    ClearError;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'rectani_free: ' + E.Message);
  end;
end;

function n_rectani_start(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_start') then Exit;
  try
    TBasRectAnimation(Args[0].p).Start;
    Result.n := 1;
    ClearError;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'rectani_start: ' + E.Message);
  end;
end;

function n_rectani_stop(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_stop') then Exit;
  try
    TBasRectAnimation(Args[0].p).Stop;
    Result.n := 1;
    ClearError;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'rectani_stop: ' + E.Message);
  end;
end;

function n_rectani_stopatcurrent(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_stopatcurrent') then Exit;
  try
    TBasRectAnimation(Args[0].p).StopAtCurrent;
    Result.n := 1;
    ClearError;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'rectani_stopatcurrent: ' + E.Message);
  end;
end;

function p_rectani_startbounds_set(var Args: array of TAsmData): TAsmData;
var
  Ani: TBasRectAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_startbounds#') then Exit;
  try
    Ani := TBasRectAnimation(Args[0].p);
    Ani.StartX := Args[1].n;
    Ani.StartY := Args[2].n;
    Ani.StartWidth := Args[3].n;
    Ani.StartHeight := Args[4].n;
    Result.p := Args[0].p;
    ClearError;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'rectani_startbounds#: ' + E.Message);
  end;
end;

function n_rectani_startx(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_startx') then Exit;
  Result.n := TBasRectAnimation(Args[0].p).StartX;
end;

function n_rectani_starty(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_starty') then Exit;
  Result.n := TBasRectAnimation(Args[0].p).StartY;
end;

function n_rectani_startwidth(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_startwidth') then Exit;
  Result.n := TBasRectAnimation(Args[0].p).StartWidth;
end;

function n_rectani_startheight(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_startheight') then Exit;
  Result.n := TBasRectAnimation(Args[0].p).StartHeight;
end;

function p_rectani_stopbounds_set(var Args: array of TAsmData): TAsmData;
var
  Ani: TBasRectAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_stopbounds#') then Exit;
  try
    Ani := TBasRectAnimation(Args[0].p);
    Ani.StopX := Args[1].n;
    Ani.StopY := Args[2].n;
    Ani.StopWidth := Args[3].n;
    Ani.StopHeight := Args[4].n;
    Result.p := Args[0].p;
    ClearError;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'rectani_stopbounds#: ' + E.Message);
  end;
end;

function n_rectani_stopx(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_stopx') then Exit;
  Result.n := TBasRectAnimation(Args[0].p).StopX;
end;

function n_rectani_stopy(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_stopy') then Exit;
  Result.n := TBasRectAnimation(Args[0].p).StopY;
end;

function n_rectani_stopwidth(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_stopwidth') then Exit;
  Result.n := TBasRectAnimation(Args[0].p).StopWidth;
end;

function n_rectani_stopheight(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_stopheight') then Exit;
  Result.n := TBasRectAnimation(Args[0].p).StopHeight;
end;

function p_rectani_duration_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_duration#') then Exit;
  TBasRectAnimation(Args[0].p).Duration := Args[1].n;
  Result.p := Args[0].p;
end;

function n_rectani_duration_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_duration') then Exit;
  Result.n := TBasRectAnimation(Args[0].p).Duration;
end;

function p_rectani_delay_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_delay#') then Exit;
  TBasRectAnimation(Args[0].p).Delay := Args[1].n;
  Result.p := Args[0].p;
end;

function n_rectani_delay_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_delay') then Exit;
  Result.n := TBasRectAnimation(Args[0].p).Delay;
end;

function p_rectani_animationtype_set(var Args: array of TAsmData): TAsmData;
var
  TypeStr: String;
  AniType: TAnimationType;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_animationtype#') then Exit;
  TypeStr := LowerCase(Args[1].s);
  if TypeStr = 'in' then AniType := TAnimationType.In
  else if TypeStr = 'out' then AniType := TAnimationType.Out
  else if TypeStr = 'inout' then AniType := TAnimationType.InOut
  else AniType := TAnimationType.In;
  TBasRectAnimation(Args[0].p).AnimationType := AniType;
  Result.p := Args[0].p;
end;

function s_rectani_animationtype_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_animationtype$') then Exit;
  case TBasRectAnimation(Args[0].p).AnimationType of
    TAnimationType.In: Result.s := 'In';
    TAnimationType.Out: Result.s := 'Out';
    TAnimationType.InOut: Result.s := 'InOut';
  end;
end;

function p_rectani_interpolation_set(var Args: array of TAsmData): TAsmData;
var
  InterpStr: String;
  Interp: TInterpolationType;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_interpolation#') then Exit;
  InterpStr := LowerCase(Args[1].s);
  if InterpStr = 'linear' then Interp := TInterpolationType.Linear
  else if InterpStr = 'quadratic' then Interp := TInterpolationType.Quadratic
  else if InterpStr = 'cubic' then Interp := TInterpolationType.Cubic
  else if InterpStr = 'quartic' then Interp := TInterpolationType.Quartic
  else if InterpStr = 'quintic' then Interp := TInterpolationType.Quintic
  else if InterpStr = 'sinusoidal' then Interp := TInterpolationType.Sinusoidal
  else if InterpStr = 'exponential' then Interp := TInterpolationType.Exponential
  else if InterpStr = 'circular' then Interp := TInterpolationType.Circular
  else if InterpStr = 'elastic' then Interp := TInterpolationType.Elastic
  else if InterpStr = 'back' then Interp := TInterpolationType.Back
  else if InterpStr = 'bounce' then Interp := TInterpolationType.Bounce
  else Interp := TInterpolationType.Linear;
  TBasRectAnimation(Args[0].p).Interpolation := Interp;
  Result.p := Args[0].p;
end;

function s_rectani_interpolation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_interpolation$') then Exit;
  case TBasRectAnimation(Args[0].p).Interpolation of
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
  end;
end;

function p_rectani_loop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_loop#') then Exit;
  TBasRectAnimation(Args[0].p).Loop := (Trunc(Args[1].n) <> 0);
  Result.p := Args[0].p;
end;

function n_rectani_loop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_loop') then Exit;
  if TBasRectAnimation(Args[0].p).Loop then Result.n := 1 else Result.n := 0;
end;

function p_rectani_autoreverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_autoreverse#') then Exit;
  TBasRectAnimation(Args[0].p).AutoReverse := (Trunc(Args[1].n) <> 0);
  Result.p := Args[0].p;
end;

function n_rectani_autoreverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_autoreverse') then Exit;
  if TBasRectAnimation(Args[0].p).AutoReverse then Result.n := 1 else Result.n := 0;
end;

function p_rectani_inverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_inverse#') then Exit;
  TBasRectAnimation(Args[0].p).Inverse := (Trunc(Args[1].n) <> 0);
  Result.p := Args[0].p;
end;

function n_rectani_inverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_inverse') then Exit;
  if TBasRectAnimation(Args[0].p).Inverse then Result.n := 1 else Result.n := 0;
end;

function p_rectani_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_enabled#') then Exit;
  TBasRectAnimation(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
  Result.p := Args[0].p;
end;

function n_rectani_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_enabled') then Exit;
  if TBasRectAnimation(Args[0].p).Enabled then Result.n := 1 else Result.n := 0;
end;

function n_rectani_running(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_running') then Exit;
  if TBasRectAnimation(Args[0].p).Running then Result.n := 1 else Result.n := 0;
end;

function n_rectani_normalizedtime(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_normalizedtime') then Exit;
  Result.n := TBasRectAnimation(Args[0].p).NormalizedTime;
end;

function s_rectani_name(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_name$') then Exit;
  Result.s := TBasRectAnimation(Args[0].p).Name;
end;

function p_rectani_onfinish_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_onfinish#') then Exit;
  TBasRectAnimation(Args[0].p).OnFinishFunc := Args[1].s;
  Result.p := Args[0].p;
end;

function s_rectani_onfinish_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_onfinish$') then Exit;
  Result.s := TBasRectAnimation(Args[0].p).OnFinishFunc;
end;

function p_rectani_onprocess_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_onprocess#') then Exit;
  TBasRectAnimation(Args[0].p).OnProcessFunc := Args[1].s;
  Result.p := Args[0].p;
end;

function s_rectani_onprocess_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_onprocess$') then Exit;
  Result.s := TBasRectAnimation(Args[0].p).OnProcessFunc;
end;

function p_rectani_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil;
  if not ValidateAnimation(Args[0].p, 'rectani_clearcallbacks#') then Exit;
  TBasRectAnimation(Args[0].p).DisconnectAllEvents;
  Result.p := Args[0].p;
end;

procedure RegisterRectAnimationFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  Fn.Entry := @n_rectani_error; Lib.Add('rectani_error@', Fn);
  Fn.Entry := @s_rectani_errormsg; Lib.Add('rectani_errormsg$@', Fn);
  Fn.Entry := @s_rectani_strerror; Lib.Add('rectani_strerror$@n', Fn);
  Fn.Entry := @n_rectani_clearerror; Lib.Add('rectani_clearerror@', Fn);

  Fn.Entry := @p_rectani_new; Lib.Add('rectani#@#', Fn);
  Fn.Entry := @p_rectani_new_named; Lib.Add('rectani#@#$', Fn);
  Fn.Entry := @n_rectani_free; Lib.Add('rectani_free@#', Fn);

  Fn.Entry := @n_rectani_start; Lib.Add('rectani_start@#', Fn);
  Fn.Entry := @n_rectani_stop; Lib.Add('rectani_stop@#', Fn);
  Fn.Entry := @n_rectani_stopatcurrent; Lib.Add('rectani_stopatcurrent@#', Fn);

  Fn.Entry := @p_rectani_startbounds_set; Lib.Add('rectani_startbounds#@#nnnn', Fn);
  Fn.Entry := @n_rectani_startx; Lib.Add('rectani_startx@#', Fn);
  Fn.Entry := @n_rectani_starty; Lib.Add('rectani_starty@#', Fn);
  Fn.Entry := @n_rectani_startwidth; Lib.Add('rectani_startwidth@#', Fn);
  Fn.Entry := @n_rectani_startheight; Lib.Add('rectani_startheight@#', Fn);

  Fn.Entry := @p_rectani_stopbounds_set; Lib.Add('rectani_stopbounds#@#nnnn', Fn);
  Fn.Entry := @n_rectani_stopx; Lib.Add('rectani_stopx@#', Fn);
  Fn.Entry := @n_rectani_stopy; Lib.Add('rectani_stopy@#', Fn);
  Fn.Entry := @n_rectani_stopwidth; Lib.Add('rectani_stopwidth@#', Fn);
  Fn.Entry := @n_rectani_stopheight; Lib.Add('rectani_stopheight@#', Fn);

  Fn.Entry := @p_rectani_duration_set; Lib.Add('rectani_duration#@#n', Fn);
  Fn.Entry := @n_rectani_duration_get; Lib.Add('rectani_duration@#', Fn);
  Fn.Entry := @p_rectani_delay_set; Lib.Add('rectani_delay#@#n', Fn);
  Fn.Entry := @n_rectani_delay_get; Lib.Add('rectani_delay@#', Fn);

  Fn.Entry := @p_rectani_animationtype_set; Lib.Add('rectani_animationtype#@#$', Fn);
  Fn.Entry := @s_rectani_animationtype_get; Lib.Add('rectani_animationtype$@#', Fn);
  Fn.Entry := @p_rectani_interpolation_set; Lib.Add('rectani_interpolation#@#$', Fn);
  Fn.Entry := @s_rectani_interpolation_get; Lib.Add('rectani_interpolation$@#', Fn);
  Fn.Entry := @p_rectani_loop_set; Lib.Add('rectani_loop#@#n', Fn);
  Fn.Entry := @n_rectani_loop_get; Lib.Add('rectani_loop@#', Fn);
  Fn.Entry := @p_rectani_autoreverse_set; Lib.Add('rectani_autoreverse#@#n', Fn);
  Fn.Entry := @n_rectani_autoreverse_get; Lib.Add('rectani_autoreverse@#', Fn);
  Fn.Entry := @p_rectani_inverse_set; Lib.Add('rectani_inverse#@#n', Fn);
  Fn.Entry := @n_rectani_inverse_get; Lib.Add('rectani_inverse@#', Fn);
  Fn.Entry := @p_rectani_enabled_set; Lib.Add('rectani_enabled#@#n', Fn);
  Fn.Entry := @n_rectani_enabled_get; Lib.Add('rectani_enabled@#', Fn);

  Fn.Entry := @n_rectani_running; Lib.Add('rectani_running@#', Fn);
  Fn.Entry := @n_rectani_normalizedtime; Lib.Add('rectani_normalizedtime@#', Fn);
  Fn.Entry := @s_rectani_name; Lib.Add('rectani_name$@#', Fn);

  Fn.Entry := @p_rectani_onfinish_set; Lib.Add('rectani_onfinish#@#$', Fn);
  Fn.Entry := @s_rectani_onfinish_get; Lib.Add('rectani_onfinish$@#', Fn);
  Fn.Entry := @p_rectani_onprocess_set; Lib.Add('rectani_onprocess#@#$', Fn);
  Fn.Entry := @s_rectani_onprocess_get; Lib.Add('rectani_onprocess$@#', Fn);
  Fn.Entry := @p_rectani_clearcallbacks; Lib.Add('rectani_clearcallbacks#@#', Fn);
end;

end.

