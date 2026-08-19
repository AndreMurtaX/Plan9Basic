unit FloatAnimationLib;

{******************************************************************************
  FloatAnimationLib - Float Animation Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TFloatAnimation wrapper functionality for
  animating numeric (float) properties of any visual control in Plan9Basic
  programs. This is the most versatile animation type.

  Function Count: 45+ functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  ANIMATABLE PROPERTIES (Examples):
  =================================
  - Position.X, Position.Y - Move controls
  - Width, Height - Resize controls
  - Opacity - Fade in/out effects
  - RotationAngle - Rotation effects
  - Scale.X, Scale.Y - Scaling effects
  - Any numeric property accessible by name

  ANIMATION TYPES (AnimationType):
  ================================
  - "In" - Acceleration at start
  - "Out" - Deceleration at end
  - "InOut" - Acceleration then deceleration

  INTERPOLATION TYPES:
  ====================
  - "Linear" - Constant speed
  - "Quadratic" - Smooth acceleration
  - "Cubic" - More pronounced acceleration
  - "Quartic" - Even more pronounced
  - "Quintic" - Very pronounced
  - "Sinusoidal" - Sine-based easing
  - "Exponential" - Exponential curve
  - "Circular" - Circular curve
  - "Elastic" - Bouncy/springy effect
  - "Back" - Overshoots then returns
  - "Bounce" - Bouncing effect

  EVENT SUPPORT:
  ==============
  - OnFinish: Animation completed (including all loops if looping)
  - OnProcess: Called on each animation frame (use sparingly)

  USAGE PATTERN:
  ==============
    let frm# = form#("Animation Demo", 400, 300)
    let rect# = rectangle#(frm#)
    rectangle_bounds#(rect#, 50, 50, 100, 100)
    rectangle_fill#(rect#, "Blue")

    ' Create fade-out animation
    let fadeAni# = floatani#(rect#)
    floatani_propertyname#(fadeAni#, "Opacity")
    floatani_startvalue#(fadeAni#, 1.0)
    floatani_stopvalue#(fadeAni#, 0.0)
    floatani_duration#(fadeAni#, 2.0)
    floatani_onfinish#(fadeAni#, "OnFadeComplete")
    floatani_start(fadeAni#)

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnFadeComplete(sender#)
      println "Fade animation finished!"
    endfunction

    function OnAnimationProcess(sender#)
      ' Called every frame - use sparingly!
      let progress = floatani_normalizedtime(sender#)
      println "Progress: " + stri$(progress * 100) + "%"
    endfunction

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.TypInfo,
  FMX.Types, FMX.Ani,
  basic, exec, UnitGC, HandleRegistry, ControlCommon;

type
  TBasFloatAnimation = class(TFloatAnimation)
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

procedure RegisterFloatAnimationFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

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
  if not (IsHandleOf(P, TBasFloatAnimation)) then
  begin
    SetError(ERR_INVALID_PROPERTY, FuncName + ': invalid animation object');
    Exit;
  end;
  Result := True;
end;

// =============================================================================
// TBasFloatAnimation Implementation
// =============================================================================

constructor TBasFloatAnimation.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);
  FOnFinishFunc := '';
  FOnProcessFunc := '';
  FBasicEngine := nil;
  FConsoleOutput := nil;
  // Events are NOT connected by default - only when callbacks are assigned
end;

destructor TBasFloatAnimation.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasFloatAnimation.DisconnectAllEvents();
begin
  OnFinish := nil;
  OnProcess := nil;
  FOnFinishFunc := '';
  FOnProcessFunc := '';
end;

procedure TBasFloatAnimation.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
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
      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs,
        RetType, RetVal);
    except
      on E: Exception do
      begin
        FConsoleOutput.Add('*** FloatAnimation Callback Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

procedure TBasFloatAnimation.SetOnFinishFunc(const Value: String);
begin
  FOnFinishFunc := Value;
  if Value <> '' then
    OnFinish := InternalOnFinish
  else
    OnFinish := nil;
end;

procedure TBasFloatAnimation.SetOnProcessFunc(const Value: String);
begin
  FOnProcessFunc := Value;
  if Value <> '' then
    OnProcess := InternalOnProcess
  else
    OnProcess := nil;
end;

procedure TBasFloatAnimation.InternalOnFinish(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnFinishFunc = '' then Exit;

  SenderArg.n := 0;
  SenderArg.s := '';
  SenderArg.p := Pointer(Self);

  ExecuteCallback(LowerCase(FOnFinishFunc) + '@#', [SenderArg]);
end;

procedure TBasFloatAnimation.InternalOnProcess(Sender: TObject);
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

function n_floatani_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_floatani_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_floatani_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_NIL_ANIMATION: Result.s := 'Animation is nil';
    ERR_INVALID_PROPERTY: Result.s := 'Invalid property';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_ANIMATION_RUNNING: Result.s := 'Animation is running';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_floatani_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 1;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Library Functions - Creation/Destruction
// =============================================================================

function p_floatani_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Ani: TBasFloatAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  try
    // Create with parent as Owner - parent will free us when destroyed
    // This is safe because TBasRectAnimation is NOT a visual child (no Parent property)
    // Only the internal TFloatAnimation objects need Create(nil) to avoid double-free
    Ani := TBasFloatAnimation.Create(TComponent(Args[0].p));
    Ani.Parent := TFmxObject(Args[0].p);
    //An animation is a TComponent with no Parent, so the walk starts at the
    //control it animates, which does have one.
    if EngineOf(TFmxObject(Args[0].p), Eng, Outp) then
    begin
      Ani.BasicEngine := Eng;
      Ani.ConsoleOutput := Outp;
    end;

    // Register with GC using NativeInt for 64-bit safety
    //UnitGC.GC.Add<TBasFloatAnimation>(Ani, IntToStr(NativeInt(Ani)));

    Result.p := Pointer(Ani);
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani#: ' + E.Message);
  end;
end;

function p_floatani_new_named(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Ani: TBasFloatAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  try
    // Create with parent as Owner - parent will free us when destroyed
    // This is safe because TBasRectAnimation is NOT a visual child (no Parent property)
    // Only the internal TFloatAnimation objects need Create(nil) to avoid double-free
    Ani := TBasFloatAnimation.Create(TComponent(Args[0].p));
    Ani.Parent := TFmxObject(Args[0].p);
    Ani.Name := Args[1].s;
    //An animation is a TComponent with no Parent, so the walk starts at the
    //control it animates, which does have one.
    if EngineOf(TFmxObject(Args[0].p), Eng, Outp) then
    begin
      Ani.BasicEngine := Eng;
      Ani.ConsoleOutput := Outp;
    end;

    //UnitGC.GC.Add<TBasFloatAnimation>(Ani, IntToStr(NativeInt(Ani)));

    Result.p := Pointer(Ani);
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani#: ' + E.Message);
  end;
end;

function n_floatani_free(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_free') then Exit;

  try
    TBasFloatAnimation(Args[0].p).DisconnectAllEvents();
    //UnitGC.GC.Collect(IntToStr(NativeInt(Args[0].p)));
    TBasFloatAnimation(Args[0].p).Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_free: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Animation Control
// =============================================================================

function n_floatani_start(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_start') then Exit;

  try
    TBasFloatAnimation(Args[0].p).Start();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_start: ' + E.Message);
  end;
end;

function n_floatani_stop(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_stop') then Exit;

  try
    TBasFloatAnimation(Args[0].p).Stop();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_stop: ' + E.Message);
  end;
end;

function n_floatani_stopatcurrent(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_stopatcurrent') then Exit;

  try
    TBasFloatAnimation(Args[0].p).StopAtCurrent();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_stopatcurrent: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Core Properties
// =============================================================================

function p_floatani_propertyname_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_propertyname#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).PropertyName := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_propertyname#: ' + E.Message);
  end;
end;

function s_floatani_propertyname_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_propertyname$') then Exit;

  try
    Result.s := TBasFloatAnimation(Args[0].p).PropertyName;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_propertyname$: ' + E.Message);
  end;
end;

function p_floatani_startvalue_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_startvalue#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).StartValue := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_startvalue#: ' + E.Message);
  end;
end;

function n_floatani_startvalue_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_startvalue') then Exit;

  try
    Result.n := TBasFloatAnimation(Args[0].p).StartValue;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_startvalue: ' + E.Message);
  end;
end;

function p_floatani_stopvalue_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_stopvalue#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).StopValue := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_stopvalue#: ' + E.Message);
  end;
end;

function n_floatani_stopvalue_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_stopvalue') then Exit;

  try
    Result.n := TBasFloatAnimation(Args[0].p).StopValue;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_stopvalue: ' + E.Message);
  end;
end;

function p_floatani_duration_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_duration#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).Duration := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_duration#: ' + E.Message);
  end;
end;

function n_floatani_duration_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_duration') then Exit;

  try
    Result.n := TBasFloatAnimation(Args[0].p).Duration;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_duration: ' + E.Message);
  end;
end;

function p_floatani_delay_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_delay#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).Delay := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_delay#: ' + E.Message);
  end;
end;

function n_floatani_delay_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_delay') then Exit;

  try
    Result.n := TBasFloatAnimation(Args[0].p).Delay;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_delay: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Animation Behavior
// =============================================================================

function p_floatani_animationtype_set(var Args: array of TAsmData): TAsmData;
var
  EnumVal: Integer;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_animationtype#') then Exit;

  try
    EnumVal := GetEnumValue(TypeInfo(TAnimationType), Args[1].s);
    if EnumVal >= 0 then
      TBasFloatAnimation(Args[0].p).AnimationType := TAnimationType(EnumVal);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_animationtype#: ' + E.Message);
  end;
end;

function s_floatani_animationtype_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_animationtype$') then Exit;

  try
    Result.s := GetEnumName(TypeInfo(TAnimationType), Integer(TBasFloatAnimation(Args[0].p).AnimationType));
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_animationtype$: ' + E.Message);
  end;
end;

function p_floatani_interpolation_set(var Args: array of TAsmData): TAsmData;
var
  EnumVal: Integer;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_interpolation#') then Exit;

  try
    EnumVal := GetEnumValue(TypeInfo(TInterpolationType), Args[1].s);
    if EnumVal >= 0 then
      TBasFloatAnimation(Args[0].p).Interpolation := TInterpolationType(EnumVal);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_interpolation#: ' + E.Message);
  end;
end;

function s_floatani_interpolation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_interpolation$') then Exit;

  try
    Result.s := GetEnumName(TypeInfo(TInterpolationType), Integer(TBasFloatAnimation(Args[0].p).Interpolation));
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_interpolation$: ' + E.Message);
  end;
end;

function p_floatani_autoreverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_autoreverse#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).AutoReverse := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_autoreverse#: ' + E.Message);
  end;
end;

function n_floatani_autoreverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_autoreverse') then Exit;

  try
    if TBasFloatAnimation(Args[0].p).AutoReverse then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_autoreverse: ' + E.Message);
  end;
end;

function p_floatani_inverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_inverse#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).Inverse := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_inverse#: ' + E.Message);
  end;
end;

function n_floatani_inverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_inverse') then Exit;

  try
    if TBasFloatAnimation(Args[0].p).Inverse then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_inverse: ' + E.Message);
  end;
end;

function p_floatani_loop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_loop#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).Loop := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_loop#: ' + E.Message);
  end;
end;

function n_floatani_loop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_loop') then Exit;

  try
    if TBasFloatAnimation(Args[0].p).Loop then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_loop: ' + E.Message);
  end;
end;

function p_floatani_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_enabled#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).Enabled := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_enabled#: ' + E.Message);
  end;
end;

function n_floatani_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_enabled') then Exit;

  try
    if TBasFloatAnimation(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_enabled: ' + E.Message);
  end;
end;

function p_floatani_startfromcurrent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_startfromcurrent#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).StartFromCurrent := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_startfromcurrent#: ' + E.Message);
  end;
end;

function n_floatani_startfromcurrent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_startfromcurrent') then Exit;

  try
    if TBasFloatAnimation(Args[0].p).StartFromCurrent then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_startfromcurrent: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - State Queries
// =============================================================================

function n_floatani_running_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_running') then Exit;

  try
    if TBasFloatAnimation(Args[0].p).Running then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_running: ' + E.Message);
  end;
end;

function n_floatani_normalizedtime_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_normalizedtime') then Exit;

  try
    Result.n := TBasFloatAnimation(Args[0].p).NormalizedTime;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_normalizedtime: ' + E.Message);
  end;
end;

function s_floatani_name_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_name$') then Exit;

  try
    Result.s := TBasFloatAnimation(Args[0].p).Name;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_name$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Triggers
// =============================================================================

function p_floatani_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_trigger#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_trigger#: ' + E.Message);
  end;
end;

function s_floatani_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_trigger$') then Exit;

  try
    Result.s := TBasFloatAnimation(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_trigger$: ' + E.Message);
  end;
end;

function p_floatani_triggerinverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_triggerinverse#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).TriggerInverse := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_triggerinverse#: ' + E.Message);
  end;
end;

function s_floatani_triggerinverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_triggerinverse$') then Exit;

  try
    Result.s := TBasFloatAnimation(Args[0].p).TriggerInverse;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_triggerinverse$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Event Callbacks
// =============================================================================

function p_floatani_onfinish_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_onfinish#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).OnFinishFunc := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_onfinish#: ' + E.Message);
  end;
end;

function s_floatani_onfinish_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_onfinish$') then Exit;

  try
    Result.s := TBasFloatAnimation(Args[0].p).OnFinishFunc;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_onfinish$: ' + E.Message);
  end;
end;

function p_floatani_onprocess_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_onprocess#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).OnProcessFunc := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'floatani_onprocess#: ' + E.Message);
  end;
end;

function s_floatani_onprocess_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_onprocess$') then Exit;

  try
    Result.s := TBasFloatAnimation(Args[0].p).OnProcessFunc;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_onprocess$: ' + E.Message);
  end;
end;

function p_floatani_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'floatani_clearcallbacks#') then Exit;

  try
    TBasFloatAnimation(Args[0].p).DisconnectAllEvents();
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'floatani_clearcallbacks#: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterFloatAnimationFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_floatani_error; Lib.Add('floatani_error@', Fn);
  Fn.Entry := @s_floatani_errormsg; Lib.Add('floatani_errormsg$@', Fn);
  Fn.Entry := @s_floatani_strerror; Lib.Add('floatani_strerror$@n', Fn);
  Fn.Entry := @n_floatani_clearerror; Lib.Add('floatani_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_floatani_new; Lib.Add('floatani#@#', Fn);
  Fn.Entry := @p_floatani_new_named; Lib.Add('floatani#@#$', Fn);
  Fn.Entry := @n_floatani_free; Lib.Add('floatani_free@#', Fn);

  // Animation control
  Fn.Entry := @n_floatani_start; Lib.Add('floatani_start@#', Fn);
  Fn.Entry := @n_floatani_stop; Lib.Add('floatani_stop@#', Fn);
  Fn.Entry := @n_floatani_stopatcurrent; Lib.Add('floatani_stopatcurrent@#', Fn);

  // Core properties - PropertyName
  Fn.Entry := @p_floatani_propertyname_set; Lib.Add('floatani_propertyname#@#$', Fn);
  Fn.Entry := @s_floatani_propertyname_get; Lib.Add('floatani_propertyname$@#', Fn);

  // Core properties - StartValue/StopValue
  Fn.Entry := @p_floatani_startvalue_set; Lib.Add('floatani_startvalue#@#n', Fn);
  Fn.Entry := @n_floatani_startvalue_get; Lib.Add('floatani_startvalue@#', Fn);
  Fn.Entry := @p_floatani_stopvalue_set; Lib.Add('floatani_stopvalue#@#n', Fn);
  Fn.Entry := @n_floatani_stopvalue_get; Lib.Add('floatani_stopvalue@#', Fn);

  // Core properties - Duration/Delay
  Fn.Entry := @p_floatani_duration_set; Lib.Add('floatani_duration#@#n', Fn);
  Fn.Entry := @n_floatani_duration_get; Lib.Add('floatani_duration@#', Fn);
  Fn.Entry := @p_floatani_delay_set; Lib.Add('floatani_delay#@#n', Fn);
  Fn.Entry := @n_floatani_delay_get; Lib.Add('floatani_delay@#', Fn);

  // Animation behavior - AnimationType/Interpolation
  Fn.Entry := @p_floatani_animationtype_set; Lib.Add('floatani_animationtype#@#$', Fn);
  Fn.Entry := @s_floatani_animationtype_get; Lib.Add('floatani_animationtype$@#', Fn);
  Fn.Entry := @p_floatani_interpolation_set; Lib.Add('floatani_interpolation#@#$', Fn);
  Fn.Entry := @s_floatani_interpolation_get; Lib.Add('floatani_interpolation$@#', Fn);

  // Animation behavior - Boolean flags
  Fn.Entry := @p_floatani_autoreverse_set; Lib.Add('floatani_autoreverse#@#n', Fn);
  Fn.Entry := @n_floatani_autoreverse_get; Lib.Add('floatani_autoreverse@#', Fn);
  Fn.Entry := @p_floatani_inverse_set; Lib.Add('floatani_inverse#@#n', Fn);
  Fn.Entry := @n_floatani_inverse_get; Lib.Add('floatani_inverse@#', Fn);
  Fn.Entry := @p_floatani_loop_set; Lib.Add('floatani_loop#@#n', Fn);
  Fn.Entry := @n_floatani_loop_get; Lib.Add('floatani_loop@#', Fn);
  Fn.Entry := @p_floatani_enabled_set; Lib.Add('floatani_enabled#@#n', Fn);
  Fn.Entry := @n_floatani_enabled_get; Lib.Add('floatani_enabled@#', Fn);
  Fn.Entry := @p_floatani_startfromcurrent_set; Lib.Add('floatani_startfromcurrent#@#n', Fn);
  Fn.Entry := @n_floatani_startfromcurrent_get; Lib.Add('floatani_startfromcurrent@#', Fn);

  // State queries
  Fn.Entry := @n_floatani_running_get; Lib.Add('floatani_running@#', Fn);
  Fn.Entry := @n_floatani_normalizedtime_get; Lib.Add('floatani_normalizedtime@#', Fn);
  Fn.Entry := @s_floatani_name_get; Lib.Add('floatani_name$@#', Fn);

  // Triggers
  Fn.Entry := @p_floatani_trigger_set; Lib.Add('floatani_trigger#@#$', Fn);
  Fn.Entry := @s_floatani_trigger_get; Lib.Add('floatani_trigger$@#', Fn);
  Fn.Entry := @p_floatani_triggerinverse_set; Lib.Add('floatani_triggerinverse#@#$', Fn);
  Fn.Entry := @s_floatani_triggerinverse_get; Lib.Add('floatani_triggerinverse$@#', Fn);

  // Event callbacks
  Fn.Entry := @p_floatani_onfinish_set; Lib.Add('floatani_onfinish#@#$', Fn);
  Fn.Entry := @s_floatani_onfinish_get; Lib.Add('floatani_onfinish$@#', Fn);
  Fn.Entry := @p_floatani_onprocess_set; Lib.Add('floatani_onprocess#@#$', Fn);
  Fn.Entry := @s_floatani_onprocess_get; Lib.Add('floatani_onprocess$@#', Fn);
  Fn.Entry := @p_floatani_clearcallbacks; Lib.Add('floatani_clearcallbacks#@#', Fn);
end;

end.


