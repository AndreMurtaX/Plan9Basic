unit InnerGlowEffectLib;

{******************************************************************************
  InnerGlowEffectLib - Inner Glow Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TInnerGlowEffect wrapper for creating inner glow effects
  inside visual controls. Unlike GlowEffect (outer glow), this creates a glow
  that appears inside the control's boundaries.

  Function Count: 18 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  FEATURES:
  =========
  - Creates glow effect inside control boundaries
  - Adjustable glow color
  - Adjustable softness/spread
  - Adjustable opacity
  - GPU-accelerated rendering
  - Trigger support for conditional activation

  PROPERTIES:
  ===========
  - GlowColor: Color of the inner glow (default: Gold)
  - Softness: Spread of the glow (0.0-9.0, default: 4.0)
  - Opacity: Transparency of glow (0.0-1.0, default: 0.9)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  USAGE PATTERN:
  ==============
    let frm# = form#("Inner Glow Demo", 400, 300)
    let btn# = button#(frm#, "Glowing Inside")
    button_bounds#(btn#, 50, 50, 150, 50)

    let ig# = innerglow#(btn#)
    innerglow_color#(ig#, "Gold")
    innerglow_softness#(ig#, 3)
    innerglow_opacity#(ig#, 0.8)

    form_show(frm#)

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, EffectCommon;

procedure RegisterInnerGlowEffectFuncs(Lib: TFunctionsDictionary);

implementation

var
  //One error slot for this library, shared shape in EffectCommon.
  Err: TEffectErrors;

const
  ERR_INVALID_COLOR = 6;

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
  Result := EffectCommon.ValidateEffect(P, TInnerGlowEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_innerglow_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_innerglow_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_innerglow_strerror(var Args: array of TAsmData): TAsmData;
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
    ERR_INVALID_COLOR: Result.s := 'Invalid color value';
  else
    Result.s := 'Unknown error code: ' + IntToStr(Code);
  end;
end;

function n_innerglow_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_innerglow_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TInnerGlowEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'innerglow#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TInnerGlowEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.GlowColor := TAlphaColorRec.Gold;
    Effect.Softness := 4.0;
    Effect.Opacity := 0.9;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TInnerGlowEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'innerglow#: ' + E.Message);
  end;
end;

function n_innerglow_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TInnerGlowEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'innerglow_free') then Exit;

  try
    Effect := TInnerGlowEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'innerglow_free: ' + E.Message);
  end;
end;

// =============================================================================
// GlowColor Property
// =============================================================================

function p_innerglow_color_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'innerglow_color#') then Exit;

  try
    TInnerGlowEffect(Args[0].p).GlowColor := TUtils.ColorToAlphaColor(Args[1].s);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_COLOR, 'innerglow_color#: ' + E.Message);
  end;
end;

function s_innerglow_color_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'innerglow_color$') then Exit;

  try
    Result.s := TUtils.AlphaColorToStr(TInnerGlowEffect(Args[0].p).GlowColor);
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'innerglow_color$: ' + E.Message);
  end;
end;

// =============================================================================
// Softness Property (0.0 - 9.0)
// =============================================================================

function p_innerglow_softness_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'innerglow_softness#') then Exit;

  try
    Value := Args[1].n;
    // Clamp to valid range
    if Value < 0.0 then Value := 0.0;
    if Value > 9.0 then Value := 9.0;
    TInnerGlowEffect(Args[0].p).Softness := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'innerglow_softness#: ' + E.Message);
  end;
end;

function n_innerglow_softness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'innerglow_softness') then Exit;

  try
    Result.n := TInnerGlowEffect(Args[0].p).Softness;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'innerglow_softness: ' + E.Message);
  end;
end;

// =============================================================================
// Opacity Property (0.0 - 1.0)
// =============================================================================

function p_innerglow_opacity_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'innerglow_opacity#') then Exit;

  try
    Value := Args[1].n;
    // Clamp to valid range
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;
    TInnerGlowEffect(Args[0].p).Opacity := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'innerglow_opacity#: ' + E.Message);
  end;
end;

function n_innerglow_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'innerglow_opacity') then Exit;

  try
    Result.n := TInnerGlowEffect(Args[0].p).Opacity;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'innerglow_opacity: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_innerglow_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'innerglow_enabled#') then Exit;

  try
    TInnerGlowEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'innerglow_enabled#: ' + E.Message);
  end;
end;

function n_innerglow_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'innerglow_enabled') then Exit;

  try
    if TInnerGlowEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'innerglow_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_innerglow_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'innerglow_trigger#') then Exit;

  try
    TInnerGlowEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'innerglow_trigger#: ' + E.Message);
  end;
end;

function s_innerglow_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'innerglow_trigger$') then Exit;

  try
    Result.s := TInnerGlowEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'innerglow_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterInnerGlowEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_innerglow_error; Lib.Add('innerglow_error@', Fn);
  Fn.Entry := @s_innerglow_errormsg; Lib.Add('innerglow_errormsg$@', Fn);
  Fn.Entry := @s_innerglow_strerror; Lib.Add('innerglow_strerror$@n', Fn);
  Fn.Entry := @n_innerglow_clearerror; Lib.Add('innerglow_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_innerglow_new; Lib.Add('innerglow#@#', Fn);
  Fn.Entry := @n_innerglow_free; Lib.Add('innerglow_free@#', Fn);

  // GlowColor property
  Fn.Entry := @p_innerglow_color_set; Lib.Add('innerglow_color#@#$', Fn);
  Fn.Entry := @s_innerglow_color_get; Lib.Add('innerglow_color$@#', Fn);

  // Softness property
  Fn.Entry := @p_innerglow_softness_set; Lib.Add('innerglow_softness#@#n', Fn);
  Fn.Entry := @n_innerglow_softness_get; Lib.Add('innerglow_softness@#', Fn);

  // Opacity property
  Fn.Entry := @p_innerglow_opacity_set; Lib.Add('innerglow_opacity#@#n', Fn);
  Fn.Entry := @n_innerglow_opacity_get; Lib.Add('innerglow_opacity@#', Fn);

  // Enabled property
  Fn.Entry := @p_innerglow_enabled_set; Lib.Add('innerglow_enabled#@#n', Fn);
  Fn.Entry := @n_innerglow_enabled_get; Lib.Add('innerglow_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_innerglow_trigger_set; Lib.Add('innerglow_trigger#@#$', Fn);
  Fn.Entry := @s_innerglow_trigger_get; Lib.Add('innerglow_trigger$@#', Fn);
end;

end.
