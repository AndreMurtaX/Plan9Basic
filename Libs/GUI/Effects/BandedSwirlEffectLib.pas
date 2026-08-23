unit BandedSwirlEffectLib;

{******************************************************************************
  BandedSwirlEffectLib - Banded Swirl Effect Library for Plan9Basic
  Version: 1.0.0

  Creates a swirl distortion effect with concentric bands.
  The swirl rotates pixels around a center point with alternating bands.

  Function Count: 18 functions

  Copyright (c) 2024-2026 André Murta
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterBandedSwirlEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TBandedSwirlEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_bswirl_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_bswirl_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_bswirl_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_bswirl_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_bswirl_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandedSwirlEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'bswirl#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TBandedSwirlEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Center := TPointF.Create(0.5, 0.5);
    Effect.Bands := 3.0;
    Effect.Strength := 0.5;
    Effect.AspectRatio := 1.0;

    // GC registration removed - parent ownership handles cleanup
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    // UnitGC.GC.Add<TBandedSwirlEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl#: ' + E.Message);
  end;
end;

function n_bswirl_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandedSwirlEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_free') then Exit;

  try
    Effect := TBandedSwirlEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_free: ' + E.Message);
  end;
end;

// =============================================================================
// CenterX Property
// =============================================================================

function p_bswirl_centerx_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandedSwirlEffect;
  CurY: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_centerx#') then Exit;

  try
    Effect := TBandedSwirlEffect(Args[0].p);
    CurY := Effect.Center.Y;
    Effect.Center := TPointF.Create(Args[1].n, CurY);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_centerx#: ' + E.Message);
  end;
end;

function n_bswirl_centerx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_centerx') then Exit;

  try
    Result.n := TBandedSwirlEffect(Args[0].p).Center.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_centerx: ' + E.Message);
  end;
end;

// =============================================================================
// CenterY Property
// =============================================================================

function p_bswirl_centery_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandedSwirlEffect;
  CurX: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_centery#') then Exit;

  try
    Effect := TBandedSwirlEffect(Args[0].p);
    CurX := Effect.Center.X;
    Effect.Center := TPointF.Create(CurX, Args[1].n);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_centery#: ' + E.Message);
  end;
end;

function n_bswirl_centery_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_centery') then Exit;

  try
    Result.n := TBandedSwirlEffect(Args[0].p).Center.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_centery: ' + E.Message);
  end;
end;

// =============================================================================
// Bands Property
// =============================================================================

function p_bswirl_bands_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_bands#') then Exit;

  try
    TBandedSwirlEffect(Args[0].p).Bands := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_bands#: ' + E.Message);
  end;
end;

function n_bswirl_bands_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_bands') then Exit;

  try
    Result.n := TBandedSwirlEffect(Args[0].p).Bands;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_bands: ' + E.Message);
  end;
end;

// =============================================================================
// Strength Property
// =============================================================================

function p_bswirl_strength_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_strength#') then Exit;

  try
    TBandedSwirlEffect(Args[0].p).Strength := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_strength#: ' + E.Message);
  end;
end;

function n_bswirl_strength_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_strength') then Exit;

  try
    Result.n := TBandedSwirlEffect(Args[0].p).Strength;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_strength: ' + E.Message);
  end;
end;

// =============================================================================
// AspectRatio Property
// =============================================================================

function p_bswirl_aspect_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_aspect#') then Exit;

  try
    TBandedSwirlEffect(Args[0].p).AspectRatio := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_aspect#: ' + E.Message);
  end;
end;

function n_bswirl_aspect_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_aspect') then Exit;

  try
    Result.n := TBandedSwirlEffect(Args[0].p).AspectRatio;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_aspect: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_bswirl_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_enabled#') then Exit;

  try
    TBandedSwirlEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_enabled#: ' + E.Message);
  end;
end;

function n_bswirl_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_enabled') then Exit;

  try
    if TBandedSwirlEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_bswirl_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_trigger#') then Exit;

  try
    TBandedSwirlEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_trigger#: ' + E.Message);
  end;
end;

function s_bswirl_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_trigger$') then Exit;

  try
    Result.s := TBandedSwirlEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterBandedSwirlEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_bswirl_error; Lib.Add('bswirl_error@', Fn);
  Fn.Entry := @s_bswirl_errormsg; Lib.Add('bswirl_errormsg$@', Fn);
  Fn.Entry := @s_bswirl_strerror; Lib.Add('bswirl_strerror$@n', Fn);
  Fn.Entry := @n_bswirl_clearerror; Lib.Add('bswirl_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_bswirl_new; Lib.Add('bswirl#@#', Fn);
  Fn.Entry := @n_bswirl_free; Lib.Add('bswirl_free@#', Fn);

  // CenterX property
  Fn.Entry := @p_bswirl_centerx_set; Lib.Add('bswirl_centerx#@#n', Fn);
  Fn.Entry := @n_bswirl_centerx_get; Lib.Add('bswirl_centerx@#', Fn);

  // CenterY property
  Fn.Entry := @p_bswirl_centery_set; Lib.Add('bswirl_centery#@#n', Fn);
  Fn.Entry := @n_bswirl_centery_get; Lib.Add('bswirl_centery@#', Fn);

  // Bands property
  Fn.Entry := @p_bswirl_bands_set; Lib.Add('bswirl_bands#@#n', Fn);
  Fn.Entry := @n_bswirl_bands_get; Lib.Add('bswirl_bands@#', Fn);

  // Strength property
  Fn.Entry := @p_bswirl_strength_set; Lib.Add('bswirl_strength#@#n', Fn);
  Fn.Entry := @n_bswirl_strength_get; Lib.Add('bswirl_strength@#', Fn);

  // AspectRatio property
  Fn.Entry := @p_bswirl_aspect_set; Lib.Add('bswirl_aspect#@#n', Fn);
  Fn.Entry := @n_bswirl_aspect_get; Lib.Add('bswirl_aspect@#', Fn);

  // Enabled property
  Fn.Entry := @p_bswirl_enabled_set; Lib.Add('bswirl_enabled#@#n', Fn);
  Fn.Entry := @n_bswirl_enabled_get; Lib.Add('bswirl_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_bswirl_trigger_set; Lib.Add('bswirl_trigger#@#$', Fn);
  Fn.Entry := @s_bswirl_trigger_get; Lib.Add('bswirl_trigger$@#', Fn);
end;

end.
