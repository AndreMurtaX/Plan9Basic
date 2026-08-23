unit SepiaEffectLib;

{******************************************************************************
  SepiaEffectLib - Sepia Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TSepiaEffect wrapper for applying vintage sepia toning
  to visual controls. Creates a warm, antique photo look.

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
  - Amount: Intensity of sepia effect (0.0-1.0, default 1.0)
    - 0.0 = No effect (original colors)
    - 0.5 = Partial sepia (blended)
    - 1.0 = Full sepia (maximum vintage look)
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

procedure RegisterSepiaEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TSepiaEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_sepia_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_sepia_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_sepia_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_sepia_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_sepia_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TSepiaEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'sepia#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    // Create with parent as Owner - parent will free effect when destroyed
    // This avoids double-free issues with the GC
    Effect := TSepiaEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Amount := 1.0;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TSepiaEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'sepia#: ' + E.Message);
  end;
end;

function n_sepia_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TSepiaEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'sepia_free') then Exit;

  try
    Effect := TSepiaEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'sepia_free: ' + E.Message);
  end;
end;

// =============================================================================
// Amount Property (0.0 to 1.0)
// =============================================================================

function p_sepia_amount_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'sepia_amount#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;
    TSepiaEffect(Args[0].p).Amount := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'sepia_amount#: ' + E.Message);
  end;
end;

function n_sepia_amount_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'sepia_amount') then Exit;

  try
    Result.n := TSepiaEffect(Args[0].p).Amount;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'sepia_amount: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_sepia_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'sepia_enabled#') then Exit;

  try
    TSepiaEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'sepia_enabled#: ' + E.Message);
  end;
end;

function n_sepia_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'sepia_enabled') then Exit;

  try
    if TSepiaEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'sepia_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_sepia_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'sepia_trigger#') then Exit;

  try
    TSepiaEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'sepia_trigger#: ' + E.Message);
  end;
end;

function s_sepia_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'sepia_trigger$') then Exit;

  try
    Result.s := TSepiaEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'sepia_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterSepiaEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_sepia_error; Lib.Add('sepia_error@', Fn);
  Fn.Entry := @s_sepia_errormsg; Lib.Add('sepia_errormsg$@', Fn);
  Fn.Entry := @s_sepia_strerror; Lib.Add('sepia_strerror$@n', Fn);
  Fn.Entry := @n_sepia_clearerror; Lib.Add('sepia_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_sepia_new; Lib.Add('sepia#@#', Fn);
  Fn.Entry := @n_sepia_free; Lib.Add('sepia_free@#', Fn);

  // Amount property
  Fn.Entry := @p_sepia_amount_set; Lib.Add('sepia_amount#@#n', Fn);
  Fn.Entry := @n_sepia_amount_get; Lib.Add('sepia_amount@#', Fn);

  // Enabled property
  Fn.Entry := @p_sepia_enabled_set; Lib.Add('sepia_enabled#@#n', Fn);
  Fn.Entry := @n_sepia_enabled_get; Lib.Add('sepia_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_sepia_trigger_set; Lib.Add('sepia_trigger#@#$', Fn);
  Fn.Entry := @s_sepia_trigger_get; Lib.Add('sepia_trigger$@#', Fn);
end;

end.

