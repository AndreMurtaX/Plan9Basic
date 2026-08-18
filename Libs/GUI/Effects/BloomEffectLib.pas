unit BloomEffectLib;

{******************************************************************************
  BloomEffectLib - Bloom Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TBloomEffect wrapper for creating bloom (glow around
  bright areas) effects on visual controls.

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
  - BloomIntensity: Brightness of the bloom glow (0-1, default 0.5)
  - BaseIntensity: Brightness of the base image (0-1, default 1.0)
  - BloomSaturation: Color saturation of bloom (0-1, default 1.0)
  - BaseSaturation: Color saturation of base image (0-1, default 1.0)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  USAGE:
  ======
  Bloom effect makes bright areas of an image appear to glow, creating
  a dreamy or ethereal look. Higher BloomIntensity = stronger glow.

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry;

procedure RegisterBloomEffectFuncs(Lib: TFunctionsDictionary);

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

function ValidateEffect(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if not Assigned(P) then
  begin
    SetError(ERR_NIL_EFFECT, FuncName + ': effect is nil');
    Exit;
  end;
  if not (IsHandleOf(P, TBloomEffect)) then
  begin
    SetError(ERR_INVALID_EFFECT, FuncName + ': invalid effect object');
    Exit;
  end;
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if not Assigned(P) then
  begin
    SetError(ERR_NIL_PARENT, FuncName + ': parent is nil');
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
// Error Handling Functions
// =============================================================================

function n_bloom_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_bloom_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_bloom_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_NIL_EFFECT: Result.s := 'Effect is nil';
    ERR_INVALID_EFFECT: Result.s := 'Invalid effect object';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_NIL_PARENT: Result.s := 'Parent is nil';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent object';
  else
    Result.s := 'Unknown error code: ' + IntToStr(Code);
  end;
end;

function n_bloom_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_bloom_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TBloomEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'bloom#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TBloomEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.BloomIntensity := 0.5;
    Effect.BaseIntensity := 1.0;
    Effect.BloomSaturation := 1.0;
    Effect.BaseSaturation := 1.0;
    
    // GC registration removed - parent ownership handles cleanup
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    //UnitGC.GC.Add<TBloomEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Torna este efeito um handle validavel sem dereferenciar o
    //ponteiro que o programa BASIC devolver. A baixa e automatica:
    //o efeito pertence ao pai, e o registry escuta FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bloom#: ' + E.Message);
  end;
end;

function n_bloom_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TBloomEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloom_free') then Exit;

  try
    Effect := TBloomEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bloom_free: ' + E.Message);
  end;
end;

// =============================================================================
// BloomIntensity Property (0 - 1)
// =============================================================================

function p_bloom_bloomintensity_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloom_bloomintensity#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TBloomEffect(Args[0].p).BloomIntensity := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bloom_bloomintensity#: ' + E.Message);
  end;
end;

function n_bloom_bloomintensity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloom_bloomintensity') then Exit;

  try
    Result.n := TBloomEffect(Args[0].p).BloomIntensity;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bloom_bloomintensity: ' + E.Message);
  end;
end;

// =============================================================================
// BaseIntensity Property (0 - 1)
// =============================================================================

function p_bloom_baseintensity_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloom_baseintensity#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TBloomEffect(Args[0].p).BaseIntensity := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bloom_baseintensity#: ' + E.Message);
  end;
end;

function n_bloom_baseintensity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloom_baseintensity') then Exit;

  try
    Result.n := TBloomEffect(Args[0].p).BaseIntensity;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bloom_baseintensity: ' + E.Message);
  end;
end;

// =============================================================================
// BloomSaturation Property (0 - 1)
// =============================================================================

function p_bloom_bloomsaturation_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloom_bloomsaturation#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TBloomEffect(Args[0].p).BloomSaturation := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bloom_bloomsaturation#: ' + E.Message);
  end;
end;

function n_bloom_bloomsaturation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloom_bloomsaturation') then Exit;

  try
    Result.n := TBloomEffect(Args[0].p).BloomSaturation;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bloom_bloomsaturation: ' + E.Message);
  end;
end;

// =============================================================================
// BaseSaturation Property (0 - 1)
// =============================================================================

function p_bloom_basesaturation_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloom_basesaturation#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TBloomEffect(Args[0].p).BaseSaturation := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bloom_basesaturation#: ' + E.Message);
  end;
end;

function n_bloom_basesaturation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloom_basesaturation') then Exit;

  try
    Result.n := TBloomEffect(Args[0].p).BaseSaturation;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bloom_basesaturation: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_bloom_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloom_enabled#') then Exit;

  try
    TBloomEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bloom_enabled#: ' + E.Message);
  end;
end;

function n_bloom_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloom_enabled') then Exit;

  try
    if TBloomEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bloom_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_bloom_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloom_trigger#') then Exit;

  try
    TBloomEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bloom_trigger#: ' + E.Message);
  end;
end;

function s_bloom_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloom_trigger$') then Exit;

  try
    Result.s := TBloomEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bloom_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterBloomEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_bloom_error; Lib.Add('bloom_error@', Fn);
  Fn.Entry := @s_bloom_errormsg; Lib.Add('bloom_errormsg$@', Fn);
  Fn.Entry := @s_bloom_strerror; Lib.Add('bloom_strerror$@n', Fn);
  Fn.Entry := @n_bloom_clearerror; Lib.Add('bloom_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_bloom_new; Lib.Add('bloom#@#', Fn);
  Fn.Entry := @n_bloom_free; Lib.Add('bloom_free@#', Fn);

  // BloomIntensity property
  Fn.Entry := @p_bloom_bloomintensity_set; Lib.Add('bloom_bloomintensity#@#n', Fn);
  Fn.Entry := @n_bloom_bloomintensity_get; Lib.Add('bloom_bloomintensity@#', Fn);

  // BaseIntensity property
  Fn.Entry := @p_bloom_baseintensity_set; Lib.Add('bloom_baseintensity#@#n', Fn);
  Fn.Entry := @n_bloom_baseintensity_get; Lib.Add('bloom_baseintensity@#', Fn);

  // BloomSaturation property
  Fn.Entry := @p_bloom_bloomsaturation_set; Lib.Add('bloom_bloomsaturation#@#n', Fn);
  Fn.Entry := @n_bloom_bloomsaturation_get; Lib.Add('bloom_bloomsaturation@#', Fn);

  // BaseSaturation property
  Fn.Entry := @p_bloom_basesaturation_set; Lib.Add('bloom_basesaturation#@#n', Fn);
  Fn.Entry := @n_bloom_basesaturation_get; Lib.Add('bloom_basesaturation@#', Fn);

  // Enabled property
  Fn.Entry := @p_bloom_enabled_set; Lib.Add('bloom_enabled#@#n', Fn);
  Fn.Entry := @n_bloom_enabled_get; Lib.Add('bloom_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_bloom_trigger_set; Lib.Add('bloom_trigger#@#$', Fn);
  Fn.Entry := @s_bloom_trigger_get; Lib.Add('bloom_trigger$@#', Fn);
end;

end.
