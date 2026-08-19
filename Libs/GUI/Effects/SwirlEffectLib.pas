unit SwirlEffectLib;

{******************************************************************************
  SwirlEffectLib - Swirl Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TSwirlEffect wrapper for creating swirl/vortex distortion
  on visual controls.

  Function Count: 16 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PROPERTIES:
  ===========
  - Strength: Swirl intensity (-10 to 10, default 1)
    Positive = clockwise, Negative = counter-clockwise
  - CenterX: Horizontal center (0.0-1.0, default 0.5)
  - CenterY: Vertical center (0.0-1.0, default 0.5)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterSwirlEffectFuncs(Lib: TFunctionsDictionary);

implementation

var
  //One error slot for this library, shared shape in EffectCommon.
  Err: TEffectErrors;


procedure SetError(Code: Integer; const Msg: String);
begin
  Err.SetErr(Code, Msg);
end;

procedure ClearError();
begin
  Err.Clear();
end;

function ValidateEffect(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateEffect(P, TSwirlEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_swirl_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_swirl_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_swirl_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_swirl_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_swirl_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TSwirlEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'swirl#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TSwirlEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.SpiralStrength := 1.0;
    Effect.Center := PointF(0.5, 0.5);
    
    //UnitGC.GC.Add<TSwirlEffect>(Effect, IntToStr(NativeInt(Effect)));
    
    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swirl#: ' + E.Message);
  end;
end;

function n_swirl_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TSwirlEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swirl_free') then Exit;

  try
    Effect := TSwirlEffect(Args[0].p);
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'swirl_free: ' + E.Message);
  end;
end;

// =============================================================================
// Strength Property (-10 to 10)
// =============================================================================

function p_swirl_strength_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swirl_strength#') then Exit;

  try
    Value := Args[1].n;
    if Value < -10 then Value := -10;
    if Value > 10 then Value := 10;
    TSwirlEffect(Args[0].p).SpiralStrength := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swirl_strength#: ' + E.Message);
  end;
end;

function n_swirl_strength_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swirl_strength') then Exit;

  try
    Result.n := TSwirlEffect(Args[0].p).SpiralStrength;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'swirl_strength: ' + E.Message);
  end;
end;

// =============================================================================
// CenterX Property (0.0 - 1.0)
// =============================================================================

function p_swirl_centerx_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swirl_centerx#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;
    Pt := TSwirlEffect(Args[0].p).Center;
    Pt.X := Value;
    TSwirlEffect(Args[0].p).Center := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swirl_centerx#: ' + E.Message);
  end;
end;

function n_swirl_centerx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swirl_centerx') then Exit;

  try
    Result.n := TSwirlEffect(Args[0].p).Center.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'swirl_centerx: ' + E.Message);
  end;
end;

// =============================================================================
// CenterY Property (0.0 - 1.0)
// =============================================================================

function p_swirl_centery_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swirl_centery#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;
    Pt := TSwirlEffect(Args[0].p).Center;
    Pt.Y := Value;
    TSwirlEffect(Args[0].p).Center := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swirl_centery#: ' + E.Message);
  end;
end;

function n_swirl_centery_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swirl_centery') then Exit;

  try
    Result.n := TSwirlEffect(Args[0].p).Center.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'swirl_centery: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_swirl_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swirl_enabled#') then Exit;

  try
    TSwirlEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swirl_enabled#: ' + E.Message);
  end;
end;

function n_swirl_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swirl_enabled') then Exit;

  try
    if TSwirlEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'swirl_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_swirl_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swirl_trigger#') then Exit;

  try
    TSwirlEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swirl_trigger#: ' + E.Message);
  end;
end;

function s_swirl_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swirl_trigger$') then Exit;

  try
    Result.s := TSwirlEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'swirl_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterSwirlEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_swirl_error; Lib.Add('swirl_error@', Fn);
  Fn.Entry := @s_swirl_errormsg; Lib.Add('swirl_errormsg$@', Fn);
  Fn.Entry := @s_swirl_strerror; Lib.Add('swirl_strerror$@n', Fn);
  Fn.Entry := @n_swirl_clearerror; Lib.Add('swirl_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_swirl_new; Lib.Add('swirl#@#', Fn);
  Fn.Entry := @n_swirl_free; Lib.Add('swirl_free@#', Fn);

  // Strength property
  Fn.Entry := @p_swirl_strength_set; Lib.Add('swirl_strength#@#n', Fn);
  Fn.Entry := @n_swirl_strength_get; Lib.Add('swirl_strength@#', Fn);

  // CenterX property
  Fn.Entry := @p_swirl_centerx_set; Lib.Add('swirl_centerx#@#n', Fn);
  Fn.Entry := @n_swirl_centerx_get; Lib.Add('swirl_centerx@#', Fn);

  // CenterY property
  Fn.Entry := @p_swirl_centery_set; Lib.Add('swirl_centery#@#n', Fn);
  Fn.Entry := @n_swirl_centery_get; Lib.Add('swirl_centery@#', Fn);

  // Enabled property
  Fn.Entry := @p_swirl_enabled_set; Lib.Add('swirl_enabled#@#n', Fn);
  Fn.Entry := @n_swirl_enabled_get; Lib.Add('swirl_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_swirl_trigger_set; Lib.Add('swirl_trigger#@#$', Fn);
  Fn.Entry := @s_swirl_trigger_get; Lib.Add('swirl_trigger$@#', Fn);
end;

end.
