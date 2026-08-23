unit InvertEffectLib;

{******************************************************************************
  InvertEffectLib - Invert Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TInvertEffect wrapper for inverting the colors of
  visual controls. Creates a photographic negative effect.

  Function Count: 10 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PROPERTIES:
  ===========
  - Enabled: Turn effect on/off (default: on)
  - Trigger: Conditional activation string

  Note: This is a simple on/off effect with no adjustable parameters.
  When enabled, all colors are inverted (black becomes white, red becomes
  cyan, etc.)

  Copyright (c) 2024-2026 André Murta
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterInvertEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TInvertEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_invert_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_invert_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_invert_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_invert_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_invert_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TInvertEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'invert#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    // Create with parent as Owner - parent will free effect when destroyed
    // This avoids double-free issues with the GC
    Effect := TInvertEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TInvertEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'invert#: ' + E.Message);
  end;
end;

function n_invert_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TInvertEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'invert_free') then Exit;

  try
    Effect := TInvertEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'invert_free: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_invert_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'invert_enabled#') then Exit;

  try
    TInvertEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'invert_enabled#: ' + E.Message);
  end;
end;

function n_invert_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'invert_enabled') then Exit;

  try
    if TInvertEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'invert_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_invert_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'invert_trigger#') then Exit;

  try
    TInvertEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'invert_trigger#: ' + E.Message);
  end;
end;

function s_invert_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'invert_trigger$') then Exit;

  try
    Result.s := TInvertEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'invert_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterInvertEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_invert_error; Lib.Add('invert_error@', Fn);
  Fn.Entry := @s_invert_errormsg; Lib.Add('invert_errormsg$@', Fn);
  Fn.Entry := @s_invert_strerror; Lib.Add('invert_strerror$@n', Fn);
  Fn.Entry := @n_invert_clearerror; Lib.Add('invert_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_invert_new; Lib.Add('invert#@#', Fn);
  Fn.Entry := @n_invert_free; Lib.Add('invert_free@#', Fn);

  // Enabled property
  Fn.Entry := @p_invert_enabled_set; Lib.Add('invert_enabled#@#n', Fn);
  Fn.Entry := @n_invert_enabled_get; Lib.Add('invert_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_invert_trigger_set; Lib.Add('invert_trigger#@#$', Fn);
  Fn.Entry := @s_invert_trigger_get; Lib.Add('invert_trigger$@#', Fn);
end;

end.

