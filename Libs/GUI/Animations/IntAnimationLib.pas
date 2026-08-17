unit IntAnimationLib;

{******************************************************************************
  IntAnimationLib - Integer Animation Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TIntAnimation wrapper functionality for
  animating integer properties of any visual control in Plan9Basic programs.
  Useful for properties that require whole numbers.

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
  - Tag - Control tag value
  - TabOrder - Tab ordering
  - ColumnCount - Grid columns
  - Any integer property accessible by name

  Note: For most visual animations (position, size, opacity), use
  FloatAnimationLib instead, as FireMonkey uses floats for these properties.

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
  - And others...

  EVENT SUPPORT:
  ==============
  - OnFinish: Animation completed
  - OnProcess: Called on each animation frame

  USAGE PATTERN:
  ==============
    let frm# = form#("Integer Animation Demo", 400, 300)
    let lbl# = label#(frm#, "Counter: 0")
    label_move#(lbl#, 50, 50)

    ' Create counter animation (0 -> 100)
    let countAni# = intani#(lbl#)
    intani_propertyname#(countAni#, "Tag")
    intani_startvalue#(countAni#, 0)
    intani_stopvalue#(countAni#, 100)
    intani_duration#(countAni#, 5.0)
    intani_onprocess#(countAni#, "OnCounterUpdate")
    intani_onfinish#(countAni#, "OnCounterFinish")
    intani_start(countAni#)

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnCounterUpdate(sender#) local ctrl#, val
      ctrl# = intani_parent#(sender#)
      val = label_tag(ctrl#)
      label_text#(ctrl#, "Counter: " + str$(val))
    endfunction

    function OnCounterFinish(sender#)
      println "Counting finished!"
    endfunction

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.TypInfo,
  FMX.Types, FMX.Ani,
  basic, exec, UnitGC;

type
  TBasIntAnimation = class(TIntAnimation)
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

procedure RegisterIntAnimationFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

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
  if not (TObject(P) is TBasIntAnimation) then
  begin
    SetError(ERR_INVALID_PROPERTY, FuncName + ': invalid animation object');
    Exit;
  end;
  Result := True;
end;

// =============================================================================
// TBasIntAnimation Implementation
// =============================================================================

constructor TBasIntAnimation.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOnFinishFunc := '';
  FOnProcessFunc := '';
  FBasicEngine := nil;
  FConsoleOutput := nil;
  // Events are NOT connected by default - only when callbacks are assigned
end;

destructor TBasIntAnimation.Destroy();
begin
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasIntAnimation.DisconnectAllEvents();
begin
  OnFinish := nil;
  OnProcess := nil;
  FOnFinishFunc := '';
  FOnProcessFunc := '';
end;

procedure TBasIntAnimation.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
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
        FConsoleOutput.Add('*** IntAnimation Callback Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

procedure TBasIntAnimation.SetOnFinishFunc(const Value: String);
begin
  FOnFinishFunc := Value;
  if Value <> '' then
    OnFinish := InternalOnFinish
  else
    OnFinish := nil;
end;

procedure TBasIntAnimation.SetOnProcessFunc(const Value: String);
begin
  FOnProcessFunc := Value;
  if Value <> '' then
    OnProcess := InternalOnProcess
  else
    OnProcess := nil;
end;

procedure TBasIntAnimation.InternalOnFinish(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnFinishFunc = '' then Exit;

  SenderArg.n := 0;
  SenderArg.s := '';
  SenderArg.p := Pointer(Self);

  ExecuteCallback(LowerCase(FOnFinishFunc) + '@#', [SenderArg]);
end;

procedure TBasIntAnimation.InternalOnProcess(Sender: TObject);
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

function n_intani_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_intani_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_intani_strerror(var Args: array of TAsmData): TAsmData;
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

function n_intani_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 1;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Library Functions - Creation/Destruction
// =============================================================================

function p_intani_new(var Args: array of TAsmData): TAsmData;
var
  Ani: TBasIntAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  try
    // Create with parent as Owner - parent will free us when destroyed
    // This is safe because TBasRectAnimation is NOT a visual child (no Parent property)
    // Only the internal TFloatAnimation objects need Create(nil) to avoid double-free
    Ani := TBasIntAnimation.Create(TComponent(Args[0].p));
    Ani.Parent := TFmxObject(Args[0].p);
    Ani.BasicEngine := ModuleEngine;
    Ani.ConsoleOutput := ModuleOutput;

    // Register with GC using NativeInt for 64-bit safety
    //UnitGC.GC.Add<TBasIntAnimation>(Ani, IntToStr(NativeInt(Ani)));

    Result.p := Pointer(Ani);
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani#: ' + E.Message);
  end;
end;

function p_intani_new_named(var Args: array of TAsmData): TAsmData;
var
  Ani: TBasIntAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  try
    // Create with parent as Owner - parent will free us when destroyed
    // This is safe because TBasRectAnimation is NOT a visual child (no Parent property)
    // Only the internal TFloatAnimation objects need Create(nil) to avoid double-free
    Ani := TBasIntAnimation.Create(TComponent(Args[0].p));
    Ani.Parent := TFmxObject(Args[0].p);
    Ani.Name := Args[1].s;
    Ani.BasicEngine := ModuleEngine;
    Ani.ConsoleOutput := ModuleOutput;

    //UnitGC.GC.Add<TBasIntAnimation>(Ani, IntToStr(NativeInt(Ani)));

    Result.p := Pointer(Ani);
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani#: ' + E.Message);
  end;
end;

function n_intani_free(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_free') then Exit;

  try
    TBasIntAnimation(Args[0].p).DisconnectAllEvents();
    //UnitGC.GC.Collect(IntToStr(NativeInt(Args[0].p)));
    TBasIntAnimation(Args[0].p).Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_free: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Animation Control
// =============================================================================

function n_intani_start(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_start') then Exit;

  try
    TBasIntAnimation(Args[0].p).Start();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_start: ' + E.Message);
  end;
end;

function n_intani_stop(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_stop') then Exit;

  try
    TBasIntAnimation(Args[0].p).Stop();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_stop: ' + E.Message);
  end;
end;

function n_intani_stopatcurrent(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_stopatcurrent') then Exit;

  try
    TBasIntAnimation(Args[0].p).StopAtCurrent();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_stopatcurrent: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Core Properties
// =============================================================================

function p_intani_propertyname_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_propertyname#') then Exit;

  try
    TBasIntAnimation(Args[0].p).PropertyName := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_propertyname#: ' + E.Message);
  end;
end;

function s_intani_propertyname_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_propertyname$') then Exit;

  try
    Result.s := TBasIntAnimation(Args[0].p).PropertyName;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_propertyname$: ' + E.Message);
  end;
end;

function p_intani_startvalue_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_startvalue#') then Exit;

  try
    TBasIntAnimation(Args[0].p).StartValue := Trunc(Args[1].n);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_startvalue#: ' + E.Message);
  end;
end;

function n_intani_startvalue_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_startvalue') then Exit;

  try
    Result.n := TBasIntAnimation(Args[0].p).StartValue;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_startvalue: ' + E.Message);
  end;
end;

function p_intani_stopvalue_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_stopvalue#') then Exit;

  try
    TBasIntAnimation(Args[0].p).StopValue := Trunc(Args[1].n);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_stopvalue#: ' + E.Message);
  end;
end;

function n_intani_stopvalue_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_stopvalue') then Exit;

  try
    Result.n := TBasIntAnimation(Args[0].p).StopValue;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_stopvalue: ' + E.Message);
  end;
end;

function p_intani_duration_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_duration#') then Exit;

  try
    TBasIntAnimation(Args[0].p).Duration := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_duration#: ' + E.Message);
  end;
end;

function n_intani_duration_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_duration') then Exit;

  try
    Result.n := TBasIntAnimation(Args[0].p).Duration;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_duration: ' + E.Message);
  end;
end;

function p_intani_delay_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_delay#') then Exit;

  try
    TBasIntAnimation(Args[0].p).Delay := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_delay#: ' + E.Message);
  end;
end;

function n_intani_delay_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_delay') then Exit;

  try
    Result.n := TBasIntAnimation(Args[0].p).Delay;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_delay: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Animation Behavior
// =============================================================================

function p_intani_animationtype_set(var Args: array of TAsmData): TAsmData;
var
  EnumVal: Integer;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_animationtype#') then Exit;

  try
    EnumVal := GetEnumValue(TypeInfo(TAnimationType), Args[1].s);
    if EnumVal >= 0 then
      TBasIntAnimation(Args[0].p).AnimationType := TAnimationType(EnumVal);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_animationtype#: ' + E.Message);
  end;
end;

function s_intani_animationtype_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_animationtype$') then Exit;

  try
    Result.s := GetEnumName(TypeInfo(TAnimationType), Integer(TBasIntAnimation(Args[0].p).AnimationType));
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_animationtype$: ' + E.Message);
  end;
end;

function p_intani_interpolation_set(var Args: array of TAsmData): TAsmData;
var
  EnumVal: Integer;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_interpolation#') then Exit;

  try
    EnumVal := GetEnumValue(TypeInfo(TInterpolationType), Args[1].s);
    if EnumVal >= 0 then
      TBasIntAnimation(Args[0].p).Interpolation := TInterpolationType(EnumVal);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_interpolation#: ' + E.Message);
  end;
end;

function s_intani_interpolation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_interpolation$') then Exit;

  try
    Result.s := GetEnumName(TypeInfo(TInterpolationType), Integer(TBasIntAnimation(Args[0].p).Interpolation));
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_interpolation$: ' + E.Message);
  end;
end;

function p_intani_autoreverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_autoreverse#') then Exit;

  try
    TBasIntAnimation(Args[0].p).AutoReverse := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_autoreverse#: ' + E.Message);
  end;
end;

function n_intani_autoreverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_autoreverse') then Exit;

  try
    if TBasIntAnimation(Args[0].p).AutoReverse then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_autoreverse: ' + E.Message);
  end;
end;

function p_intani_inverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_inverse#') then Exit;

  try
    TBasIntAnimation(Args[0].p).Inverse := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_inverse#: ' + E.Message);
  end;
end;

function n_intani_inverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_inverse') then Exit;

  try
    if TBasIntAnimation(Args[0].p).Inverse then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_inverse: ' + E.Message);
  end;
end;

function p_intani_loop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_loop#') then Exit;

  try
    TBasIntAnimation(Args[0].p).Loop := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_loop#: ' + E.Message);
  end;
end;

function n_intani_loop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_loop') then Exit;

  try
    if TBasIntAnimation(Args[0].p).Loop then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_loop: ' + E.Message);
  end;
end;

function p_intani_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_enabled#') then Exit;

  try
    TBasIntAnimation(Args[0].p).Enabled := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_enabled#: ' + E.Message);
  end;
end;

function n_intani_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_enabled') then Exit;

  try
    if TBasIntAnimation(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_enabled: ' + E.Message);
  end;
end;

function p_intani_startfromcurrent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_startfromcurrent#') then Exit;

  try
    TBasIntAnimation(Args[0].p).StartFromCurrent := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_startfromcurrent#: ' + E.Message);
  end;
end;

function n_intani_startfromcurrent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_startfromcurrent') then Exit;

  try
    if TBasIntAnimation(Args[0].p).StartFromCurrent then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_startfromcurrent: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - State Queries
// =============================================================================

function n_intani_running_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_running') then Exit;

  try
    if TBasIntAnimation(Args[0].p).Running then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_running: ' + E.Message);
  end;
end;

function n_intani_normalizedtime_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_normalizedtime') then Exit;

  try
    Result.n := TBasIntAnimation(Args[0].p).NormalizedTime;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_normalizedtime: ' + E.Message);
  end;
end;

function s_intani_name_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_name$') then Exit;

  try
    Result.s := TBasIntAnimation(Args[0].p).Name;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_name$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Triggers
// =============================================================================

function p_intani_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_trigger#') then Exit;

  try
    TBasIntAnimation(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_trigger#: ' + E.Message);
  end;
end;

function s_intani_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_trigger$') then Exit;

  try
    Result.s := TBasIntAnimation(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_trigger$: ' + E.Message);
  end;
end;

function p_intani_triggerinverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_triggerinverse#') then Exit;

  try
    TBasIntAnimation(Args[0].p).TriggerInverse := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_triggerinverse#: ' + E.Message);
  end;
end;

function s_intani_triggerinverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_triggerinverse$') then Exit;

  try
    Result.s := TBasIntAnimation(Args[0].p).TriggerInverse;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_triggerinverse$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Event Callbacks
// =============================================================================

function p_intani_onfinish_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_onfinish#') then Exit;

  try
    TBasIntAnimation(Args[0].p).OnFinishFunc := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_onfinish#: ' + E.Message);
  end;
end;

function s_intani_onfinish_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_onfinish$') then Exit;

  try
    Result.s := TBasIntAnimation(Args[0].p).OnFinishFunc;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_onfinish$: ' + E.Message);
  end;
end;

function p_intani_onprocess_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_onprocess#') then Exit;

  try
    TBasIntAnimation(Args[0].p).OnProcessFunc := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'intani_onprocess#: ' + E.Message);
  end;
end;

function s_intani_onprocess_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_onprocess$') then Exit;

  try
    Result.s := TBasIntAnimation(Args[0].p).OnProcessFunc;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_onprocess$: ' + E.Message);
  end;
end;

function p_intani_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'intani_clearcallbacks#') then Exit;

  try
    TBasIntAnimation(Args[0].p).DisconnectAllEvents();
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'intani_clearcallbacks#: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterIntAnimationFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_intani_error; Lib.Add('intani_error@', Fn);
  Fn.Entry := @s_intani_errormsg; Lib.Add('intani_errormsg$@', Fn);
  Fn.Entry := @s_intani_strerror; Lib.Add('intani_strerror$@n', Fn);
  Fn.Entry := @n_intani_clearerror; Lib.Add('intani_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_intani_new; Lib.Add('intani#@#', Fn);
  Fn.Entry := @p_intani_new_named; Lib.Add('intani#@#$', Fn);
  Fn.Entry := @n_intani_free; Lib.Add('intani_free@#', Fn);

  // Animation control
  Fn.Entry := @n_intani_start; Lib.Add('intani_start@#', Fn);
  Fn.Entry := @n_intani_stop; Lib.Add('intani_stop@#', Fn);
  Fn.Entry := @n_intani_stopatcurrent; Lib.Add('intani_stopatcurrent@#', Fn);

  // Core properties - PropertyName
  Fn.Entry := @p_intani_propertyname_set; Lib.Add('intani_propertyname#@#$', Fn);
  Fn.Entry := @s_intani_propertyname_get; Lib.Add('intani_propertyname$@#', Fn);

  // Core properties - StartValue/StopValue (integers)
  Fn.Entry := @p_intani_startvalue_set; Lib.Add('intani_startvalue#@#n', Fn);
  Fn.Entry := @n_intani_startvalue_get; Lib.Add('intani_startvalue@#', Fn);
  Fn.Entry := @p_intani_stopvalue_set; Lib.Add('intani_stopvalue#@#n', Fn);
  Fn.Entry := @n_intani_stopvalue_get; Lib.Add('intani_stopvalue@#', Fn);

  // Core properties - Duration/Delay
  Fn.Entry := @p_intani_duration_set; Lib.Add('intani_duration#@#n', Fn);
  Fn.Entry := @n_intani_duration_get; Lib.Add('intani_duration@#', Fn);
  Fn.Entry := @p_intani_delay_set; Lib.Add('intani_delay#@#n', Fn);
  Fn.Entry := @n_intani_delay_get; Lib.Add('intani_delay@#', Fn);

  // Animation behavior - AnimationType/Interpolation
  Fn.Entry := @p_intani_animationtype_set; Lib.Add('intani_animationtype#@#$', Fn);
  Fn.Entry := @s_intani_animationtype_get; Lib.Add('intani_animationtype$@#', Fn);
  Fn.Entry := @p_intani_interpolation_set; Lib.Add('intani_interpolation#@#$', Fn);
  Fn.Entry := @s_intani_interpolation_get; Lib.Add('intani_interpolation$@#', Fn);

  // Animation behavior - Boolean flags
  Fn.Entry := @p_intani_autoreverse_set; Lib.Add('intani_autoreverse#@#n', Fn);
  Fn.Entry := @n_intani_autoreverse_get; Lib.Add('intani_autoreverse@#', Fn);
  Fn.Entry := @p_intani_inverse_set; Lib.Add('intani_inverse#@#n', Fn);
  Fn.Entry := @n_intani_inverse_get; Lib.Add('intani_inverse@#', Fn);
  Fn.Entry := @p_intani_loop_set; Lib.Add('intani_loop#@#n', Fn);
  Fn.Entry := @n_intani_loop_get; Lib.Add('intani_loop@#', Fn);
  Fn.Entry := @p_intani_enabled_set; Lib.Add('intani_enabled#@#n', Fn);
  Fn.Entry := @n_intani_enabled_get; Lib.Add('intani_enabled@#', Fn);
  Fn.Entry := @p_intani_startfromcurrent_set; Lib.Add('intani_startfromcurrent#@#n', Fn);
  Fn.Entry := @n_intani_startfromcurrent_get; Lib.Add('intani_startfromcurrent@#', Fn);

  // State queries
  Fn.Entry := @n_intani_running_get; Lib.Add('intani_running@#', Fn);
  Fn.Entry := @n_intani_normalizedtime_get; Lib.Add('intani_normalizedtime@#', Fn);
  Fn.Entry := @s_intani_name_get; Lib.Add('intani_name$@#', Fn);

  // Triggers
  Fn.Entry := @p_intani_trigger_set; Lib.Add('intani_trigger#@#$', Fn);
  Fn.Entry := @s_intani_trigger_get; Lib.Add('intani_trigger$@#', Fn);
  Fn.Entry := @p_intani_triggerinverse_set; Lib.Add('intani_triggerinverse#@#$', Fn);
  Fn.Entry := @s_intani_triggerinverse_get; Lib.Add('intani_triggerinverse$@#', Fn);

  // Event callbacks
  Fn.Entry := @p_intani_onfinish_set; Lib.Add('intani_onfinish#@#$', Fn);
  Fn.Entry := @s_intani_onfinish_get; Lib.Add('intani_onfinish$@#', Fn);
  Fn.Entry := @p_intani_onprocess_set; Lib.Add('intani_onprocess#@#$', Fn);
  Fn.Entry := @s_intani_onprocess_get; Lib.Add('intani_onprocess$@#', Fn);
  Fn.Entry := @p_intani_clearcallbacks; Lib.Add('intani_clearcallbacks#@#', Fn);
end;

end.

