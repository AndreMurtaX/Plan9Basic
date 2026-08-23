unit HueAdjustEffectLib;

{******************************************************************************
  HueAdjustEffectLib - Hue Adjust Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey THueAdjustEffect wrapper for shifting the hue of
  visual controls. Rotates colors around the color wheel.

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
  - Hue: Amount of hue shift (-1.0 to 1.0, default 0.0)
    - -1.0 = Shift 180 degrees counter-clockwise
    - 0.0 = No shift (original colors)
    - 1.0 = Shift 180 degrees clockwise
    Note: -1.0 and 1.0 produce same result (opposite colors)
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

procedure RegisterHueAdjustEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, THueAdjustEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_hueadjust_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_hueadjust_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_hueadjust_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_hueadjust_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_hueadjust_new(var Args: array of TAsmData): TAsmData;
var
  Effect: THueAdjustEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'hueadjust#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := THueAdjustEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Hue := 0.0;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<THueAdjustEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'hueadjust#: ' + E.Message);
  end;
end;

function n_hueadjust_free(var Args: array of TAsmData): TAsmData;
var
  Effect: THueAdjustEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_free') then Exit;

  try
    Effect := THueAdjustEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'hueadjust_free: ' + E.Message);
  end;
end;

// =============================================================================
// Hue Property (-1.0 to 1.0)
// =============================================================================

function p_hueadjust_hue_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_hue#') then Exit;

  try
    Value := Args[1].n;
    if Value < -1.0 then Value := -1.0;
    if Value > 1.0 then Value := 1.0;
    THueAdjustEffect(Args[0].p).Hue := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'hueadjust_hue#: ' + E.Message);
  end;
end;

function n_hueadjust_hue_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_hue') then Exit;

  try
    Result.n := THueAdjustEffect(Args[0].p).Hue;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'hueadjust_hue: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_hueadjust_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_enabled#') then Exit;

  try
    THueAdjustEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'hueadjust_enabled#: ' + E.Message);
  end;
end;

function n_hueadjust_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_enabled') then Exit;

  try
    if THueAdjustEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'hueadjust_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_hueadjust_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_trigger#') then Exit;

  try
    THueAdjustEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'hueadjust_trigger#: ' + E.Message);
  end;
end;

function s_hueadjust_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_trigger$') then Exit;

  try
    Result.s := THueAdjustEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'hueadjust_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterHueAdjustEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_hueadjust_error; Lib.Add('hueadjust_error@', Fn);
  Fn.Entry := @s_hueadjust_errormsg; Lib.Add('hueadjust_errormsg$@', Fn);
  Fn.Entry := @s_hueadjust_strerror; Lib.Add('hueadjust_strerror$@n', Fn);
  Fn.Entry := @n_hueadjust_clearerror; Lib.Add('hueadjust_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_hueadjust_new; Lib.Add('hueadjust#@#', Fn);
  Fn.Entry := @n_hueadjust_free; Lib.Add('hueadjust_free@#', Fn);

  // Hue property
  Fn.Entry := @p_hueadjust_hue_set; Lib.Add('hueadjust_hue#@#n', Fn);
  Fn.Entry := @n_hueadjust_hue_get; Lib.Add('hueadjust_hue@#', Fn);

  // Enabled property
  Fn.Entry := @p_hueadjust_enabled_set; Lib.Add('hueadjust_enabled#@#n', Fn);
  Fn.Entry := @n_hueadjust_enabled_get; Lib.Add('hueadjust_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_hueadjust_trigger_set; Lib.Add('hueadjust_trigger#@#$', Fn);
  Fn.Entry := @s_hueadjust_trigger_get; Lib.Add('hueadjust_trigger$@#', Fn);
end;

end.
