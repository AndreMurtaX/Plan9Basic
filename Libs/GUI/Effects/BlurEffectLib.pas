unit BlurEffectLib;

{******************************************************************************
  BlurEffectLib - Blur Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TBlurEffect wrapper functionality for applying
  blur effects to any visual control in Plan9Basic programs.

  Function Count: 12 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  EFFECT PROPERTIES:
  ==================
  - Softness: Blur intensity (0.0 to 3.0)
  - Enabled: Enable/disable the effect
  - Trigger: Property-based trigger string

  KEY CONCEPTS:
  =============
  Effects are NON-VISUAL components that must be children of a visual control.
  Unlike animations, effects are STATIC - they apply immediately when properties
  change. Effects can be ANIMATED using FloatAnimationLib.

  USAGE PATTERN:
  ==============
    let frm# = form#("Blur Effect Demo", 400, 300)
    let img# = image#(frm#, 50, 50, 200, 150)
    image_load#(img#, "photo.png")

    ' Apply blur effect to image
    let blur# = blur#(img#)
    blur_softness#(blur#, 1.5)

    form_show(frm#)

  ANIMATED BLUR EXAMPLE:
  ======================
    ' Create blur effect
    let blur# = blur#(img#)
    blur_softness#(blur#, 0.0)

    ' Animate blur from 0 to 3 over 2 seconds
    let ani# = floatani#(blur#)
    floatani_propertyname#(ani#, "Softness")
    floatani_startvalue#(ani#, 0.0)
    floatani_stopvalue#(ani#, 3.0)
    floatani_duration#(ani#, 2.0)
    floatani_start(ani#)

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Effects,
  basic, exec, UnitGC, HandleRegistry;

type
  TBasBlurEffect = class(TBlurEffect)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
  end;

procedure RegisterBlurEffectFuncs(Lib: TFunctionsDictionary);

implementation

var
  LastError: Integer = 0;
  LastErrorMsg: String = '';

const
  ERR_NONE = 0;
  ERR_NIL_EFFECT = 1;
  ERR_INVALID_EFFECT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_NIL_PARENT = 4;
  ERR_INVALID_PARENT = 5;

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

function ValidateEffect(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if not Assigned(P) then
  begin
    SetError(ERR_NIL_EFFECT, FuncName + ': effect is nil');
    Exit;
  end;
  if not (IsHandleOf(P, TBasBlurEffect)) then
  begin
    SetError(ERR_INVALID_EFFECT, FuncName + ': invalid blur effect object');
    Exit;
  end;
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if not Assigned(P) then
  begin
    SetError(ERR_NIL_PARENT, FuncName + ': parent control is nil');
    Exit;
  end;
  if not (IsHandleOf(P, TFmxObject)) then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': invalid parent object');
    Exit;
  end;
  Result := True;
end;

// =============================================================================
// TBasBlurEffect Implementation
// =============================================================================

constructor TBasBlurEffect.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);
  // Default values
  Softness := 0.4; // FireMonkey default
  Enabled := True;
end;

destructor TBasBlurEffect.Destroy();
begin
  UnregisterHandle(Self);
  inherited Destroy();
end;

// =============================================================================
// Error Functions
// =============================================================================

function n_blur_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_blur_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_blur_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_NIL_EFFECT: Result.s := 'Effect is nil';
    ERR_INVALID_EFFECT: Result.s := 'Invalid blur effect object';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_NIL_PARENT: Result.s := 'Parent control is nil';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent object';
  else
    Result.s := 'Unknown error: ' + IntToStr(Code);
  end;
end;

function n_blur_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation / Destruction
// =============================================================================

function p_blur_new(var Args: array of TAsmData): TAsmData;
var
  ParentObj: TFmxObject;
  Effect: TBasBlurEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'blur#') then Exit;

  try
    ParentObj := TFmxObject(Args[0].p);
    // Create with parent as Owner - parent will free effect when destroyed
    // This avoids double-free issues with the GC
    Effect := TBasBlurEffect.Create(ParentObj);
    Effect.Parent := ParentObj;

    // GC registration removed - parent ownership handles cleanup
    // if Assigned(UnitGC.GC) then
    //   UnitGC.GC.Add<TBasBlurEffect>(Effect, IntToStr(NativeInt(Effect)));
    Result.p := Pointer(Effect);
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'blur#: ' + E.Message);
  end;
end;

function n_blur_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TBasBlurEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'blur_free') then Exit;

  try
    Effect := TBasBlurEffect(Args[0].p);

    // GC collection removed - parent ownership handles cleanup
    // if Assigned(UnitGC.GC) then
    //   UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));

    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'blur_free: ' + E.Message);
  end;
end;

// =============================================================================
// Softness Property
// =============================================================================

function p_blur_softness_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'blur_softness#') then Exit;

  try
    Value := Args[1].n;
    // Clamp to valid range
    if Value < 0.0 then Value := 0.0;
    if Value > 3.0 then Value := 3.0;

    TBasBlurEffect(Args[0].p).Softness := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'blur_softness#: ' + E.Message);
  end;
end;

function n_blur_softness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'blur_softness') then Exit;

  try
    Result.n := TBasBlurEffect(Args[0].p).Softness;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'blur_softness: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_blur_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'blur_enabled#') then Exit;

  try
    TBasBlurEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'blur_enabled#: ' + E.Message);
  end;
end;

function n_blur_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'blur_enabled') then Exit;

  try
    if TBasBlurEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'blur_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_blur_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'blur_trigger#') then Exit;

  try
    TBasBlurEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'blur_trigger#: ' + E.Message);
  end;
end;

function s_blur_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'blur_trigger$') then Exit;

  try
    Result.s := TBasBlurEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'blur_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterBlurEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_blur_error; Lib.Add('blur_error@', Fn);
  Fn.Entry := @s_blur_errormsg; Lib.Add('blur_errormsg$@', Fn);
  Fn.Entry := @s_blur_strerror; Lib.Add('blur_strerror$@n', Fn);
  Fn.Entry := @n_blur_clearerror; Lib.Add('blur_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_blur_new; Lib.Add('blur#@#', Fn);
  Fn.Entry := @n_blur_free; Lib.Add('blur_free@#', Fn);

  // Softness property
  Fn.Entry := @p_blur_softness_set; Lib.Add('blur_softness#@#n', Fn);
  Fn.Entry := @n_blur_softness_get; Lib.Add('blur_softness@#', Fn);

  // Enabled property
  Fn.Entry := @p_blur_enabled_set; Lib.Add('blur_enabled#@#n', Fn);
  Fn.Entry := @n_blur_enabled_get; Lib.Add('blur_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_blur_trigger_set; Lib.Add('blur_trigger#@#$', Fn);
  Fn.Entry := @s_blur_trigger_get; Lib.Add('blur_trigger$@#', Fn);
end;

end.
