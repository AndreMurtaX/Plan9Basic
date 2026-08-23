unit SharpenEffectLib;

{******************************************************************************
  SharpenEffectLib - Sharpen Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TSharpenEffect wrapper for sharpening/enhancing
  edge details in visual controls.

  Function Count: 12 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PROPERTIES:
  ===========
  - Amount: Sharpening intensity (0.0-2.0, default 1.0)
    0.0 = No sharpening
    1.0 = Normal sharpening
    2.0 = Maximum sharpening
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

procedure RegisterSharpenEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TSharpenEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_sharpen_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_sharpen_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_sharpen_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_sharpen_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_sharpen_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TSharpenEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'sharpen#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TSharpenEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Amount := 1.0;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TSharpenEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'sharpen#: ' + E.Message);
  end;
end;

function n_sharpen_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TSharpenEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'sharpen_free') then Exit;

  try
    Effect := TSharpenEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'sharpen_free: ' + E.Message);
  end;
end;

// =============================================================================
// Amount Property (0.0 - 2.0)
// =============================================================================

function p_sharpen_amount_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'sharpen_amount#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.0 then Value := 0.0;
    if Value > 2.0 then Value := 2.0;
    TSharpenEffect(Args[0].p).Amount := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'sharpen_amount#: ' + E.Message);
  end;
end;

function n_sharpen_amount_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'sharpen_amount') then Exit;

  try
    Result.n := TSharpenEffect(Args[0].p).Amount;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'sharpen_amount: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_sharpen_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'sharpen_enabled#') then Exit;

  try
    TSharpenEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'sharpen_enabled#: ' + E.Message);
  end;
end;

function n_sharpen_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'sharpen_enabled') then Exit;

  try
    if TSharpenEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'sharpen_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_sharpen_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'sharpen_trigger#') then Exit;

  try
    TSharpenEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'sharpen_trigger#: ' + E.Message);
  end;
end;

function s_sharpen_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'sharpen_trigger$') then Exit;

  try
    Result.s := TSharpenEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'sharpen_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterSharpenEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_sharpen_error; Lib.Add('sharpen_error@', Fn);
  Fn.Entry := @s_sharpen_errormsg; Lib.Add('sharpen_errormsg$@', Fn);
  Fn.Entry := @s_sharpen_strerror; Lib.Add('sharpen_strerror$@n', Fn);
  Fn.Entry := @n_sharpen_clearerror; Lib.Add('sharpen_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_sharpen_new; Lib.Add('sharpen#@#', Fn);
  Fn.Entry := @n_sharpen_free; Lib.Add('sharpen_free@#', Fn);

  // Amount property
  Fn.Entry := @p_sharpen_amount_set; Lib.Add('sharpen_amount#@#n', Fn);
  Fn.Entry := @n_sharpen_amount_get; Lib.Add('sharpen_amount@#', Fn);

  // Enabled property
  Fn.Entry := @p_sharpen_enabled_set; Lib.Add('sharpen_enabled#@#n', Fn);
  Fn.Entry := @n_sharpen_enabled_get; Lib.Add('sharpen_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_sharpen_trigger_set; Lib.Add('sharpen_trigger#@#$', Fn);
  Fn.Entry := @s_sharpen_trigger_get; Lib.Add('sharpen_trigger$@#', Fn);
end;

end.
