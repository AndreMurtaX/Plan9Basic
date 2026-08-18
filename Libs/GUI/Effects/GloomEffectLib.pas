unit GloomEffectLib;

{******************************************************************************
  GloomEffectLib - Gloom Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TGloomEffect wrapper for creating gloom (darkening
  around dark areas) effects on visual controls. Opposite of Bloom.

  Function Count: 18 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PROPERTIES:
  ===========
  - GloomIntensity: Intensity of the gloom darkening (0-1, default 0.5)
  - BaseIntensity: Brightness of the base image (0-1, default 1.0)
  - GloomSaturation: Color saturation of gloom (0-1, default 1.0)
  - BaseSaturation: Color saturation of base image (0-1, default 1.0)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  USAGE:
  ======
  Gloom effect intensifies dark areas of an image, creating a darker,
  moodier look. Higher GloomIntensity = stronger darkening effect.

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterGloomEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TGloomEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_gloom_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_gloom_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_gloom_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_gloom_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_gloom_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TGloomEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'gloom#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TGloomEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.GloomIntensity := 0.5;
    Effect.BaseIntensity := 1.0;
    Effect.GloomSaturation := 1.0;
    Effect.BaseSaturation := 1.0;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TGloomEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'gloom#: ' + E.Message);
  end;
end;

function n_gloom_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TGloomEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gloom_free') then Exit;

  try
    Effect := TGloomEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'gloom_free: ' + E.Message);
  end;
end;

// =============================================================================
// GloomIntensity Property (0 - 1)
// =============================================================================

function p_gloom_gloomintensity_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gloom_gloomintensity#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TGloomEffect(Args[0].p).GloomIntensity := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'gloom_gloomintensity#: ' + E.Message);
  end;
end;

function n_gloom_gloomintensity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gloom_gloomintensity') then Exit;

  try
    Result.n := TGloomEffect(Args[0].p).GloomIntensity;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'gloom_gloomintensity: ' + E.Message);
  end;
end;

// =============================================================================
// BaseIntensity Property (0 - 1)
// =============================================================================

function p_gloom_baseintensity_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gloom_baseintensity#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TGloomEffect(Args[0].p).BaseIntensity := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'gloom_baseintensity#: ' + E.Message);
  end;
end;

function n_gloom_baseintensity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gloom_baseintensity') then Exit;

  try
    Result.n := TGloomEffect(Args[0].p).BaseIntensity;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'gloom_baseintensity: ' + E.Message);
  end;
end;

// =============================================================================
// GloomSaturation Property (0 - 1)
// =============================================================================

function p_gloom_gloomsaturation_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gloom_gloomsaturation#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TGloomEffect(Args[0].p).GloomSaturation := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'gloom_gloomsaturation#: ' + E.Message);
  end;
end;

function n_gloom_gloomsaturation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gloom_gloomsaturation') then Exit;

  try
    Result.n := TGloomEffect(Args[0].p).GloomSaturation;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'gloom_gloomsaturation: ' + E.Message);
  end;
end;

// =============================================================================
// BaseSaturation Property (0 - 1)
// =============================================================================

function p_gloom_basesaturation_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gloom_basesaturation#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TGloomEffect(Args[0].p).BaseSaturation := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'gloom_basesaturation#: ' + E.Message);
  end;
end;

function n_gloom_basesaturation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gloom_basesaturation') then Exit;

  try
    Result.n := TGloomEffect(Args[0].p).BaseSaturation;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'gloom_basesaturation: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_gloom_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gloom_enabled#') then Exit;

  try
    TGloomEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'gloom_enabled#: ' + E.Message);
  end;
end;

function n_gloom_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gloom_enabled') then Exit;

  try
    if TGloomEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'gloom_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_gloom_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gloom_trigger#') then Exit;

  try
    TGloomEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'gloom_trigger#: ' + E.Message);
  end;
end;

function s_gloom_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gloom_trigger$') then Exit;

  try
    Result.s := TGloomEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'gloom_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterGloomEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_gloom_error; Lib.Add('gloom_error@', Fn);
  Fn.Entry := @s_gloom_errormsg; Lib.Add('gloom_errormsg$@', Fn);
  Fn.Entry := @s_gloom_strerror; Lib.Add('gloom_strerror$@n', Fn);
  Fn.Entry := @n_gloom_clearerror; Lib.Add('gloom_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_gloom_new; Lib.Add('gloom#@#', Fn);
  Fn.Entry := @n_gloom_free; Lib.Add('gloom_free@#', Fn);

  // GloomIntensity property
  Fn.Entry := @p_gloom_gloomintensity_set; Lib.Add('gloom_gloomintensity#@#n', Fn);
  Fn.Entry := @n_gloom_gloomintensity_get; Lib.Add('gloom_gloomintensity@#', Fn);

  // BaseIntensity property
  Fn.Entry := @p_gloom_baseintensity_set; Lib.Add('gloom_baseintensity#@#n', Fn);
  Fn.Entry := @n_gloom_baseintensity_get; Lib.Add('gloom_baseintensity@#', Fn);

  // GloomSaturation property
  Fn.Entry := @p_gloom_gloomsaturation_set; Lib.Add('gloom_gloomsaturation#@#n', Fn);
  Fn.Entry := @n_gloom_gloomsaturation_get; Lib.Add('gloom_gloomsaturation@#', Fn);

  // BaseSaturation property
  Fn.Entry := @p_gloom_basesaturation_set; Lib.Add('gloom_basesaturation#@#n', Fn);
  Fn.Entry := @n_gloom_basesaturation_get; Lib.Add('gloom_basesaturation@#', Fn);

  // Enabled property
  Fn.Entry := @p_gloom_enabled_set; Lib.Add('gloom_enabled#@#n', Fn);
  Fn.Entry := @n_gloom_enabled_get; Lib.Add('gloom_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_gloom_trigger_set; Lib.Add('gloom_trigger#@#$', Fn);
  Fn.Entry := @s_gloom_trigger_get; Lib.Add('gloom_trigger$@#', Fn);
end;

end.
