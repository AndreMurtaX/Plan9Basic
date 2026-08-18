unit BandsEffectLib;

{******************************************************************************
  BandsEffectLib - Bands Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TBandsEffect wrapper for creating horizontal bands
  distortion on visual controls.

  Function Count: 14 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PROPERTIES:
  ===========
  - BandDensity: Number of bands (0-100, default 50)
  - BandIntensity: Intensity of band effect (0-1, default 0.5)
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

procedure RegisterBandsEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TBandsEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_bands_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_bands_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_bands_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_bands_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_bands_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandsEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'bands#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TBandsEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.BandDensity := 50;
    Effect.BandIntensity := 0.5;

    // GC registration removed - parent ownership handles cleanup
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    // UnitGC.GC.Add<TBandsEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bands#: ' + E.Message);
  end;
end;

function n_bands_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandsEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bands_free') then Exit;

  try
    Effect := TBandsEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bands_free: ' + E.Message);
  end;
end;

// =============================================================================
// BandDensity Property (0 - 100)
// =============================================================================

function p_bands_density_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bands_density#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 100 then Value := 100;
    TBandsEffect(Args[0].p).BandDensity := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bands_density#: ' + E.Message);
  end;
end;

function n_bands_density_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bands_density') then Exit;

  try
    Result.n := TBandsEffect(Args[0].p).BandDensity;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bands_density: ' + E.Message);
  end;
end;

// =============================================================================
// BandIntensity Property (0 - 1)
// =============================================================================

function p_bands_intensity_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bands_intensity#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TBandsEffect(Args[0].p).BandIntensity := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bands_intensity#: ' + E.Message);
  end;
end;

function n_bands_intensity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bands_intensity') then Exit;

  try
    Result.n := TBandsEffect(Args[0].p).BandIntensity;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bands_intensity: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_bands_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bands_enabled#') then Exit;

  try
    TBandsEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bands_enabled#: ' + E.Message);
  end;
end;

function n_bands_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bands_enabled') then Exit;

  try
    if TBandsEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bands_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_bands_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bands_trigger#') then Exit;

  try
    TBandsEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bands_trigger#: ' + E.Message);
  end;
end;

function s_bands_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bands_trigger$') then Exit;

  try
    Result.s := TBandsEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bands_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterBandsEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_bands_error; Lib.Add('bands_error@', Fn);
  Fn.Entry := @s_bands_errormsg; Lib.Add('bands_errormsg$@', Fn);
  Fn.Entry := @s_bands_strerror; Lib.Add('bands_strerror$@n', Fn);
  Fn.Entry := @n_bands_clearerror; Lib.Add('bands_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_bands_new; Lib.Add('bands#@#', Fn);
  Fn.Entry := @n_bands_free; Lib.Add('bands_free@#', Fn);

  // BandDensity property
  Fn.Entry := @p_bands_density_set; Lib.Add('bands_density#@#n', Fn);
  Fn.Entry := @n_bands_density_get; Lib.Add('bands_density@#', Fn);

  // BandIntensity property
  Fn.Entry := @p_bands_intensity_set; Lib.Add('bands_intensity#@#n', Fn);
  Fn.Entry := @n_bands_intensity_get; Lib.Add('bands_intensity@#', Fn);

  // Enabled property
  Fn.Entry := @p_bands_enabled_set; Lib.Add('bands_enabled#@#n', Fn);
  Fn.Entry := @n_bands_enabled_get; Lib.Add('bands_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_bands_trigger_set; Lib.Add('bands_trigger#@#$', Fn);
  Fn.Entry := @s_bands_trigger_get; Lib.Add('bands_trigger$@#', Fn);
end;

end.
