unit EmbossEffectLib;

{******************************************************************************
  EmbossEffectLib - Emboss Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TEmbossEffect wrapper for creating a 3D embossed
  appearance on visual controls.

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
  - Amount: Intensity of emboss effect (0.0-1.0, default 0.5)
  - Width: Width of emboss edges (0.0-10.0, default 1.0)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  Copyright (c) 2024-2026 André Murta
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterEmbossEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TEmbossEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_emboss_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_emboss_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_emboss_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_emboss_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_emboss_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TEmbossEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'emboss#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TEmbossEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Amount := 0.5;
    Effect.Width := 1.0;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TEmbossEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'emboss#: ' + E.Message);
  end;
end;

function n_emboss_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TEmbossEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'emboss_free') then Exit;

  try
    Effect := TEmbossEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'emboss_free: ' + E.Message);
  end;
end;

// =============================================================================
// Amount Property (0.0 - 1.0)
// =============================================================================

function p_emboss_amount_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'emboss_amount#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;
    TEmbossEffect(Args[0].p).Amount := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'emboss_amount#: ' + E.Message);
  end;
end;

function n_emboss_amount_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'emboss_amount') then Exit;

  try
    Result.n := TEmbossEffect(Args[0].p).Amount;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'emboss_amount: ' + E.Message);
  end;
end;

// =============================================================================
// Width Property (0.0 - 10.0)
// =============================================================================

function p_emboss_width_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'emboss_width#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.0 then Value := 0.0;
    if Value > 10.0 then Value := 10.0;
    TEmbossEffect(Args[0].p).Width := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'emboss_width#: ' + E.Message);
  end;
end;

function n_emboss_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'emboss_width') then Exit;

  try
    Result.n := TEmbossEffect(Args[0].p).Width;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'emboss_width: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_emboss_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'emboss_enabled#') then Exit;

  try
    TEmbossEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'emboss_enabled#: ' + E.Message);
  end;
end;

function n_emboss_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'emboss_enabled') then Exit;

  try
    if TEmbossEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'emboss_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_emboss_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'emboss_trigger#') then Exit;

  try
    TEmbossEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'emboss_trigger#: ' + E.Message);
  end;
end;

function s_emboss_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'emboss_trigger$') then Exit;

  try
    Result.s := TEmbossEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'emboss_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterEmbossEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_emboss_error; Lib.Add('emboss_error@', Fn);
  Fn.Entry := @s_emboss_errormsg; Lib.Add('emboss_errormsg$@', Fn);
  Fn.Entry := @s_emboss_strerror; Lib.Add('emboss_strerror$@n', Fn);
  Fn.Entry := @n_emboss_clearerror; Lib.Add('emboss_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_emboss_new; Lib.Add('emboss#@#', Fn);
  Fn.Entry := @n_emboss_free; Lib.Add('emboss_free@#', Fn);

  // Amount property
  Fn.Entry := @p_emboss_amount_set; Lib.Add('emboss_amount#@#n', Fn);
  Fn.Entry := @n_emboss_amount_get; Lib.Add('emboss_amount@#', Fn);

  // Width property
  Fn.Entry := @p_emboss_width_set; Lib.Add('emboss_width#@#n', Fn);
  Fn.Entry := @n_emboss_width_get; Lib.Add('emboss_width@#', Fn);

  // Enabled property
  Fn.Entry := @p_emboss_enabled_set; Lib.Add('emboss_enabled#@#n', Fn);
  Fn.Entry := @n_emboss_enabled_get; Lib.Add('emboss_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_emboss_trigger_set; Lib.Add('emboss_trigger#@#$', Fn);
  Fn.Entry := @s_emboss_trigger_get; Lib.Add('emboss_trigger$@#', Fn);
end;

end.
