unit MonochromeEffectLib;

{******************************************************************************
  MonochromeEffectLib - Monochrome Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TMonochromeEffect wrapper for converting visual controls
  to grayscale/monochrome appearance. Useful for disabled states, artistic
  effects, and focus indication.

  Function Count: 12 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  FEATURES:
  =========
  - Converts any visual control to grayscale
  - GPU-accelerated rendering
  - Instant application (no animation needed)
  - Trigger support for conditional activation
  - Perfect for disabled state indication

  PROPERTIES:
  ===========
  - Enabled: Turn effect on/off (default: on)
  - Trigger: Conditional activation string

  USAGE PATTERN:
  ==============
    let frm# = form#("Monochrome Demo", 400, 300)
    let btn# = button#(frm#, "Grayscale Button")
    button_bounds#(btn#, 50, 50, 150, 50)

    let mono# = monochrome#(btn#)
    ' Effect is immediately active

    form_show(frm#)

  COMMON USE CASES:
  =================
  - Disabled/inactive state indication
  - Before/after comparison effects
  - Focus highlighting (invert logic)
  - Artistic black & white effects
  - Photo gallery filters

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterMonochromeEffectFuncs(Lib: TFunctionsDictionary);

implementation

var
  //One error slot for this library, shared shape in EffectCommon.
  Err: TEffectErrors;


// =============================================================================
// Error Handling
// =============================================================================

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
  Result := EffectCommon.ValidateEffect(P, TMonochromeEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_mono_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_mono_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_mono_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_mono_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_mono_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TMonochromeEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'monochrome#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    // Create with parent as Owner - parent will free effect when destroyed
    // This avoids double-free issues with the GC
    Effect := TMonochromeEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TMonochromeEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'monochrome#: ' + E.Message);
  end;
end;

function n_mono_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TMonochromeEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'monochrome_free') then Exit;

  try
    Effect := TMonochromeEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'monochrome_free: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_mono_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'monochrome_enabled#') then Exit;

  try
    TMonochromeEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'monochrome_enabled#: ' + E.Message);
  end;
end;

function n_mono_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'monochrome_enabled') then Exit;

  try
    if TMonochromeEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'monochrome_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_mono_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'monochrome_trigger#') then Exit;

  try
    TMonochromeEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'monochrome_trigger#: ' + E.Message);
  end;
end;

function s_mono_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'monochrome_trigger$') then Exit;

  try
    Result.s := TMonochromeEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'monochrome_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterMonochromeEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_mono_error; Lib.Add('monochrome_error@', Fn);
  Fn.Entry := @s_mono_errormsg; Lib.Add('monochrome_errormsg$@', Fn);
  Fn.Entry := @s_mono_strerror; Lib.Add('monochrome_strerror$@n', Fn);
  Fn.Entry := @n_mono_clearerror; Lib.Add('monochrome_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_mono_new; Lib.Add('monochrome#@#', Fn);
  Fn.Entry := @n_mono_free; Lib.Add('monochrome_free@#', Fn);

  // Enabled property
  Fn.Entry := @p_mono_enabled_set; Lib.Add('monochrome_enabled#@#n', Fn);
  Fn.Entry := @n_mono_enabled_get; Lib.Add('monochrome_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_mono_trigger_set; Lib.Add('monochrome_trigger#@#$', Fn);
  Fn.Entry := @s_mono_trigger_get; Lib.Add('monochrome_trigger$@#', Fn);
end;

end.
