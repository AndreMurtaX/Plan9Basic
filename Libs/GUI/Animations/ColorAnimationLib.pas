unit ColorAnimationLib;

{******************************************************************************
  ColorAnimationLib - Color Animation Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TColorAnimation wrapper functionality for
  animating color properties of any visual control in Plan9Basic programs.
  Essential for color transitions, hover effects, and visual feedback.

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
  - Fill.Color - Shape fill color
  - Stroke.Color - Shape stroke/border color
  - TextSettings.FontColor - Text color
  - Any TAlphaColor property accessible by name

  COLOR VALUES:
  =============
  Colors are specified as TAlphaColor integers (ARGB format):
  - Use colortoalphacolor("Red") to convert named colors
  - Use rgb(r,g,b) or rgba(r,g,b,a) helper functions
  - Direct hex values: $FFFF0000 = Red, $FF00FF00 = Green

  ANIMATION TYPES (AnimationType):
  ================================
  - "In" - Acceleration at start
  - "Out" - Deceleration at end
  - "InOut" - Acceleration then deceleration

  INTERPOLATION TYPES:
  ====================
  - "Linear" - Constant speed (recommended for colors)
  - "Quadratic", "Cubic", etc. - Various easing curves

  EVENT SUPPORT:
  ==============
  - OnFinish: Animation completed
  - OnProcess: Called on each animation frame

  USAGE PATTERN:
  ==============
    let frm# = form#("Color Animation Demo", 400, 300)
    let rect# = rectangle#(frm#)
    rectangle_bounds#(rect#, 50, 50, 200, 150)
    rectangle_fill#(rect#, "Blue")

    ' Create color transition animation (Blue -> Red)
    let colorAni# = colorani#(rect#)
    colorani_propertyname#(colorAni#, "Fill.Color")
    colorani_startvalue#(colorAni#, colortoalphacolor("Blue"))
    colorani_stopvalue#(colorAni#, colortoalphacolor("Red"))
    colorani_duration#(colorAni#, 2.0)
    colorani_onfinish#(colorAni#, "OnColorChanged")
    colorani_start(colorAni#)

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnColorChanged(sender#)
      println "Color animation finished!"
    endfunction

  Copyright (c) 2024-2026 André Murta
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.TypInfo,
  FMX.Types, FMX.Ani,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, ControlCommon;

type
  TBasColorAnimation = class(TColorAnimation)
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

procedure RegisterColorAnimationFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

var
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
  if not (IsHandleOf(P, TBasColorAnimation)) then
  begin
    SetError(ERR_INVALID_PROPERTY, FuncName + ': invalid animation object');
    Exit;
  end;
  Result := True;
end;

// =============================================================================
// TBasColorAnimation Implementation
// =============================================================================

constructor TBasColorAnimation.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);
  FOnFinishFunc := '';
  FOnProcessFunc := '';
  FBasicEngine := nil;
  FConsoleOutput := nil;
end;

destructor TBasColorAnimation.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasColorAnimation.DisconnectAllEvents();
begin
  OnFinish := nil;
  OnProcess := nil;
  FOnFinishFunc := '';
  FOnProcessFunc := '';
end;

procedure TBasColorAnimation.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
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
      begin
        FConsoleOutput.Add('*** ColorAnimation Callback Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.ReleaseCallbackGuard();
  end;
end;

procedure TBasColorAnimation.SetOnFinishFunc(const Value: String);
begin
  FOnFinishFunc := Value;
  if Value <> '' then
    OnFinish := InternalOnFinish
  else
    OnFinish := nil;
end;

procedure TBasColorAnimation.SetOnProcessFunc(const Value: String);
begin
  FOnProcessFunc := Value;
  if Value <> '' then
    OnProcess := InternalOnProcess
  else
    OnProcess := nil;
end;

procedure TBasColorAnimation.InternalOnFinish(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnFinishFunc = '' then Exit;

  SenderArg.n := 0;
  SenderArg.s := '';
  SenderArg.p := Pointer(Self);

  ExecuteCallback(LowerCase(FOnFinishFunc) + '@#', [SenderArg]);
end;

procedure TBasColorAnimation.InternalOnProcess(Sender: TObject);
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

function n_colorani_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_colorani_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_colorani_strerror(var Args: array of TAsmData): TAsmData;
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

function n_colorani_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 1;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Library Functions - Color Conversion Utility
// =============================================================================

// colortoalphacolor(colorName$) - Convert color name/hex to TAlphaColor number
function n_colortoalphacolor(var Args: array of TAsmData): TAsmData;
begin
  Result.p := nil;
  Result.s := '';
  Result.n := TUtils.ColorToAlphaColor(Args[0].s);
end;

// alphacolortostring$(color) - Convert TAlphaColor number to hex string
function s_alphacolortostring(var Args: array of TAsmData): TAsmData;
var
  Color: TAlphaColor;
begin
  Result.p := nil;
  Result.n := 0;
  Color := Trunc(Args[0].n);
  Result.s := TUtils.AlphaColorToStr(Color);
end;

// rgb(r, g, b) - Create color from RGB values (0-255)
function n_rgb(var Args: array of TAsmData): TAsmData;
var
  R, G, B: Byte;
begin
  Result.p := nil;
  Result.s := '';
  R := Trunc(Args[0].n) and $FF;
  G := Trunc(Args[1].n) and $FF;
  B := Trunc(Args[2].n) and $FF;
  Result.n := (TAlphaColor($FF) shl 24) or (TAlphaColor(R) shl 16) or (TAlphaColor(G) shl 8) or TAlphaColor(B);
end;

// rgba(r, g, b, a) - Create color from RGBA values (0-255)
function n_rgba(var Args: array of TAsmData): TAsmData;
var
  R, G, B, A: Byte;
begin
  Result.p := nil;
  Result.s := '';
  R := Trunc(Args[0].n) and $FF;
  G := Trunc(Args[1].n) and $FF;
  B := Trunc(Args[2].n) and $FF;
  A := Trunc(Args[3].n) and $FF;
  Result.n := (TAlphaColor(A) shl 24) or (TAlphaColor(R) shl 16) or (TAlphaColor(G) shl 8) or TAlphaColor(B);
end;

// =============================================================================
// Library Functions - Creation/Destruction
// =============================================================================

function p_colorani_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Ani: TBasColorAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  try
    // Create with parent as Owner - parent will free us when destroyed
    // This is safe because TBasRectAnimation is NOT a visual child (no Parent property)
    // Only the internal TFloatAnimation objects need Create(nil) to avoid double-free
    Ani := TBasColorAnimation.Create(TComponent(Args[0].p));
    Ani.Parent := TFmxObject(Args[0].p);
    //An animation is a TComponent with no Parent, so the walk starts at the
    //control it animates, which does have one.
    if EngineOf(TFmxObject(Args[0].p), Eng, Outp) then
    begin
      Ani.BasicEngine := Eng;
      Ani.ConsoleOutput := Outp;
    end;

    //UnitGC.GC.Add<TBasColorAnimation>(Ani, IntToStr(NativeInt(Ani)));

    Result.p := Pointer(Ani);
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani#: ' + E.Message);
  end;
end;

function p_colorani_new_named(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Ani: TBasColorAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  try
    // Create with parent as Owner - parent will free us when destroyed
    // This is safe because TBasRectAnimation is NOT a visual child (no Parent property)
    // Only the internal TFloatAnimation objects need Create(nil) to avoid double-free
    Ani := TBasColorAnimation.Create(TComponent(Args[0].p));
    Ani.Parent := TFmxObject(Args[0].p);
    Ani.Name := Args[1].s;
    //An animation is a TComponent with no Parent, so the walk starts at the
    //control it animates, which does have one.
    if EngineOf(TFmxObject(Args[0].p), Eng, Outp) then
    begin
      Ani.BasicEngine := Eng;
      Ani.ConsoleOutput := Outp;
    end;

    //UnitGC.GC.Add<TBasColorAnimation>(Ani, IntToStr(NativeInt(Ani)));

    Result.p := Pointer(Ani);
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani#: ' + E.Message);
  end;
end;

function n_colorani_free(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_free') then Exit;

  try
    TBasColorAnimation(Args[0].p).DisconnectAllEvents();
    //UnitGC.GC.Collect(IntToStr(NativeInt(Args[0].p)));
    TBasColorAnimation(Args[0].p).Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_free: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Animation Control
// =============================================================================

function n_colorani_start(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_start') then Exit;

  try
    TBasColorAnimation(Args[0].p).Start();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_start: ' + E.Message);
  end;
end;

function n_colorani_stop(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_stop') then Exit;

  try
    TBasColorAnimation(Args[0].p).Stop();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_stop: ' + E.Message);
  end;
end;

function n_colorani_stopatcurrent(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_stopatcurrent') then Exit;

  try
    TBasColorAnimation(Args[0].p).StopAtCurrent();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_stopatcurrent: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Core Properties
// =============================================================================

function p_colorani_propertyname_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_propertyname#') then Exit;

  try
    TBasColorAnimation(Args[0].p).PropertyName := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_propertyname#: ' + E.Message);
  end;
end;

function s_colorani_propertyname_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_propertyname$') then Exit;

  try
    Result.s := TBasColorAnimation(Args[0].p).PropertyName;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_propertyname$: ' + E.Message);
  end;
end;

function p_colorani_startvalue_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_startvalue#') then Exit;

  try
    TBasColorAnimation(Args[0].p).StartValue := TAlphaColor(Trunc(Args[1].n));
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_startvalue#: ' + E.Message);
  end;
end;

function n_colorani_startvalue_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_startvalue') then Exit;

  try
    Result.n := TBasColorAnimation(Args[0].p).StartValue;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_startvalue: ' + E.Message);
  end;
end;

function p_colorani_stopvalue_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_stopvalue#') then Exit;

  try
    TBasColorAnimation(Args[0].p).StopValue := TAlphaColor(Trunc(Args[1].n));
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_stopvalue#: ' + E.Message);
  end;
end;

function n_colorani_stopvalue_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_stopvalue') then Exit;

  try
    Result.n := TBasColorAnimation(Args[0].p).StopValue;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_stopvalue: ' + E.Message);
  end;
end;

function p_colorani_duration_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_duration#') then Exit;

  try
    TBasColorAnimation(Args[0].p).Duration := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_duration#: ' + E.Message);
  end;
end;

function n_colorani_duration_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_duration') then Exit;

  try
    Result.n := TBasColorAnimation(Args[0].p).Duration;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_duration: ' + E.Message);
  end;
end;

function p_colorani_delay_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_delay#') then Exit;

  try
    TBasColorAnimation(Args[0].p).Delay := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_delay#: ' + E.Message);
  end;
end;

function n_colorani_delay_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_delay') then Exit;

  try
    Result.n := TBasColorAnimation(Args[0].p).Delay;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_delay: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Animation Behavior
// =============================================================================

function p_colorani_animationtype_set(var Args: array of TAsmData): TAsmData;
var
  EnumVal: Integer;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_animationtype#') then Exit;

  try
    EnumVal := GetEnumValue(TypeInfo(TAnimationType), Args[1].s);
    if EnumVal >= 0 then
      TBasColorAnimation(Args[0].p).AnimationType := TAnimationType(EnumVal);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_animationtype#: ' + E.Message);
  end;
end;

function s_colorani_animationtype_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_animationtype$') then Exit;

  try
    Result.s := GetEnumName(TypeInfo(TAnimationType), Integer(TBasColorAnimation(Args[0].p).AnimationType));
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_animationtype$: ' + E.Message);
  end;
end;

function p_colorani_interpolation_set(var Args: array of TAsmData): TAsmData;
var
  EnumVal: Integer;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_interpolation#') then Exit;

  try
    EnumVal := GetEnumValue(TypeInfo(TInterpolationType), Args[1].s);
    if EnumVal >= 0 then
      TBasColorAnimation(Args[0].p).Interpolation := TInterpolationType(EnumVal);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_interpolation#: ' + E.Message);
  end;
end;

function s_colorani_interpolation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_interpolation$') then Exit;

  try
    Result.s := GetEnumName(TypeInfo(TInterpolationType), Integer(TBasColorAnimation(Args[0].p).Interpolation));
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_interpolation$: ' + E.Message);
  end;
end;

function p_colorani_autoreverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_autoreverse#') then Exit;

  try
    TBasColorAnimation(Args[0].p).AutoReverse := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_autoreverse#: ' + E.Message);
  end;
end;

function n_colorani_autoreverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_autoreverse') then Exit;

  try
    if TBasColorAnimation(Args[0].p).AutoReverse then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_autoreverse: ' + E.Message);
  end;
end;

function p_colorani_inverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_inverse#') then Exit;

  try
    TBasColorAnimation(Args[0].p).Inverse := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_inverse#: ' + E.Message);
  end;
end;

function n_colorani_inverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_inverse') then Exit;

  try
    if TBasColorAnimation(Args[0].p).Inverse then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_inverse: ' + E.Message);
  end;
end;

function p_colorani_loop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_loop#') then Exit;

  try
    TBasColorAnimation(Args[0].p).Loop := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_loop#: ' + E.Message);
  end;
end;

function n_colorani_loop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_loop') then Exit;

  try
    if TBasColorAnimation(Args[0].p).Loop then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_loop: ' + E.Message);
  end;
end;

function p_colorani_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_enabled#') then Exit;

  try
    TBasColorAnimation(Args[0].p).Enabled := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_enabled#: ' + E.Message);
  end;
end;

function n_colorani_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_enabled') then Exit;

  try
    if TBasColorAnimation(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_enabled: ' + E.Message);
  end;
end;

function p_colorani_startfromcurrent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_startfromcurrent#') then Exit;

  try
    TBasColorAnimation(Args[0].p).StartFromCurrent := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_startfromcurrent#: ' + E.Message);
  end;
end;

function n_colorani_startfromcurrent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_startfromcurrent') then Exit;

  try
    if TBasColorAnimation(Args[0].p).StartFromCurrent then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_startfromcurrent: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - State Queries
// =============================================================================

function n_colorani_running_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_running') then Exit;

  try
    if TBasColorAnimation(Args[0].p).Running then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_running: ' + E.Message);
  end;
end;

function n_colorani_normalizedtime_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_normalizedtime') then Exit;

  try
    Result.n := TBasColorAnimation(Args[0].p).NormalizedTime;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_normalizedtime: ' + E.Message);
  end;
end;

function s_colorani_name_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_name$') then Exit;

  try
    Result.s := TBasColorAnimation(Args[0].p).Name;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_name$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Triggers
// =============================================================================

function p_colorani_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_trigger#') then Exit;

  try
    TBasColorAnimation(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_trigger#: ' + E.Message);
  end;
end;

function s_colorani_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_trigger$') then Exit;

  try
    Result.s := TBasColorAnimation(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_trigger$: ' + E.Message);
  end;
end;

function p_colorani_triggerinverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_triggerinverse#') then Exit;

  try
    TBasColorAnimation(Args[0].p).TriggerInverse := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_triggerinverse#: ' + E.Message);
  end;
end;

function s_colorani_triggerinverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_triggerinverse$') then Exit;

  try
    Result.s := TBasColorAnimation(Args[0].p).TriggerInverse;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_triggerinverse$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Event Callbacks
// =============================================================================

function p_colorani_onfinish_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_onfinish#') then Exit;

  try
    TBasColorAnimation(Args[0].p).OnFinishFunc := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_onfinish#: ' + E.Message);
  end;
end;

function s_colorani_onfinish_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_onfinish$') then Exit;

  try
    Result.s := TBasColorAnimation(Args[0].p).OnFinishFunc;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_onfinish$: ' + E.Message);
  end;
end;

function p_colorani_onprocess_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_onprocess#') then Exit;

  try
    TBasColorAnimation(Args[0].p).OnProcessFunc := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorani_onprocess#: ' + E.Message);
  end;
end;

function s_colorani_onprocess_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_onprocess$') then Exit;

  try
    Result.s := TBasColorAnimation(Args[0].p).OnProcessFunc;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_onprocess$: ' + E.Message);
  end;
end;

function p_colorani_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateAnimation(Args[0].p, 'colorani_clearcallbacks#') then Exit;

  try
    TBasColorAnimation(Args[0].p).DisconnectAllEvents();
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'colorani_clearcallbacks#: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterColorAnimationFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_colorani_error; Lib.Add('colorani_error@', Fn);
  Fn.Entry := @s_colorani_errormsg; Lib.Add('colorani_errormsg$@', Fn);
  Fn.Entry := @s_colorani_strerror; Lib.Add('colorani_strerror$@n', Fn);
  Fn.Entry := @n_colorani_clearerror; Lib.Add('colorani_clearerror@', Fn);

  // Color utility functions
  Fn.Entry := @n_colortoalphacolor; Lib.Add('colortoalphacolor@$', Fn);
  Fn.Entry := @s_alphacolortostring; Lib.Add('alphacolortostring$@n', Fn);
  Fn.Entry := @n_rgb; Lib.Add('rgb@nnn', Fn);
  Fn.Entry := @n_rgba; Lib.Add('rgba@nnnn', Fn);

  // Creation/destruction
  Fn.Entry := @p_colorani_new; Lib.Add('colorani#@#', Fn);
  Fn.Entry := @p_colorani_new_named; Lib.Add('colorani#@#$', Fn);
  Fn.Entry := @n_colorani_free; Lib.Add('colorani_free@#', Fn);

  // Animation control
  Fn.Entry := @n_colorani_start; Lib.Add('colorani_start@#', Fn);
  Fn.Entry := @n_colorani_stop; Lib.Add('colorani_stop@#', Fn);
  Fn.Entry := @n_colorani_stopatcurrent; Lib.Add('colorani_stopatcurrent@#', Fn);

  // Core properties - PropertyName
  Fn.Entry := @p_colorani_propertyname_set; Lib.Add('colorani_propertyname#@#$', Fn);
  Fn.Entry := @s_colorani_propertyname_get; Lib.Add('colorani_propertyname$@#', Fn);

  // Core properties - StartValue/StopValue (colors as integers)
  Fn.Entry := @p_colorani_startvalue_set; Lib.Add('colorani_startvalue#@#n', Fn);
  Fn.Entry := @n_colorani_startvalue_get; Lib.Add('colorani_startvalue@#', Fn);
  Fn.Entry := @p_colorani_stopvalue_set; Lib.Add('colorani_stopvalue#@#n', Fn);
  Fn.Entry := @n_colorani_stopvalue_get; Lib.Add('colorani_stopvalue@#', Fn);

  // Core properties - Duration/Delay
  Fn.Entry := @p_colorani_duration_set; Lib.Add('colorani_duration#@#n', Fn);
  Fn.Entry := @n_colorani_duration_get; Lib.Add('colorani_duration@#', Fn);
  Fn.Entry := @p_colorani_delay_set; Lib.Add('colorani_delay#@#n', Fn);
  Fn.Entry := @n_colorani_delay_get; Lib.Add('colorani_delay@#', Fn);

  // Animation behavior - AnimationType/Interpolation
  Fn.Entry := @p_colorani_animationtype_set; Lib.Add('colorani_animationtype#@#$', Fn);
  Fn.Entry := @s_colorani_animationtype_get; Lib.Add('colorani_animationtype$@#', Fn);
  Fn.Entry := @p_colorani_interpolation_set; Lib.Add('colorani_interpolation#@#$', Fn);
  Fn.Entry := @s_colorani_interpolation_get; Lib.Add('colorani_interpolation$@#', Fn);

  // Animation behavior - Boolean flags
  Fn.Entry := @p_colorani_autoreverse_set; Lib.Add('colorani_autoreverse#@#n', Fn);
  Fn.Entry := @n_colorani_autoreverse_get; Lib.Add('colorani_autoreverse@#', Fn);
  Fn.Entry := @p_colorani_inverse_set; Lib.Add('colorani_inverse#@#n', Fn);
  Fn.Entry := @n_colorani_inverse_get; Lib.Add('colorani_inverse@#', Fn);
  Fn.Entry := @p_colorani_loop_set; Lib.Add('colorani_loop#@#n', Fn);
  Fn.Entry := @n_colorani_loop_get; Lib.Add('colorani_loop@#', Fn);
  Fn.Entry := @p_colorani_enabled_set; Lib.Add('colorani_enabled#@#n', Fn);
  Fn.Entry := @n_colorani_enabled_get; Lib.Add('colorani_enabled@#', Fn);
  Fn.Entry := @p_colorani_startfromcurrent_set; Lib.Add('colorani_startfromcurrent#@#n', Fn);
  Fn.Entry := @n_colorani_startfromcurrent_get; Lib.Add('colorani_startfromcurrent@#', Fn);

  // State queries
  Fn.Entry := @n_colorani_running_get; Lib.Add('colorani_running@#', Fn);
  Fn.Entry := @n_colorani_normalizedtime_get; Lib.Add('colorani_normalizedtime@#', Fn);
  Fn.Entry := @s_colorani_name_get; Lib.Add('colorani_name$@#', Fn);

  // Triggers
  Fn.Entry := @p_colorani_trigger_set; Lib.Add('colorani_trigger#@#$', Fn);
  Fn.Entry := @s_colorani_trigger_get; Lib.Add('colorani_trigger$@#', Fn);
  Fn.Entry := @p_colorani_triggerinverse_set; Lib.Add('colorani_triggerinverse#@#$', Fn);
  Fn.Entry := @s_colorani_triggerinverse_get; Lib.Add('colorani_triggerinverse$@#', Fn);

  // Event callbacks
  Fn.Entry := @p_colorani_onfinish_set; Lib.Add('colorani_onfinish#@#$', Fn);
  Fn.Entry := @s_colorani_onfinish_get; Lib.Add('colorani_onfinish$@#', Fn);
  Fn.Entry := @p_colorani_onprocess_set; Lib.Add('colorani_onprocess#@#$', Fn);
  Fn.Entry := @s_colorani_onprocess_get; Lib.Add('colorani_onprocess$@#', Fn);
  Fn.Entry := @p_colorani_clearcallbacks; Lib.Add('colorani_clearcallbacks#@#', Fn);
end;

end.

