unit WrapEffectLib;

{******************************************************************************
  WrapEffectLib - Wrap Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TWrapEffect wrapper for creating wrap/warp distortion
  on visual controls (pinch/bulge effect).

  Function Count: 16 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PROPERTIES:
  ===========
  - LeftStart: Left edge start position (0-1, default 0)
  - LeftControl1: Left control point 1 (0-1, default 0)
  - LeftControl2: Left control point 2 (0-1, default 0)
  - LeftEnd: Left edge end position (0-1, default 0)
  - RightStart: Right edge start position (0-1, default 1)
  - RightControl1: Right control point 1 (0-1, default 1)
  - RightControl2: Right control point 2 (0-1, default 1)
  - RightEnd: Right edge end position (0-1, default 1)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  Note: This effect wraps/warps the image using bezier curves on left/right edges

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterWrapEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TWrapEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_wrap_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_wrap_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_wrap_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_wrap_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_wrap_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TWrapEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'wrap#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TWrapEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    // Default values create no distortion
    Effect.LeftStart := 0;
    Effect.LeftControl1 := 0;
    Effect.LeftControl2 := 0;
    Effect.LeftEnd := 0;
    Effect.RightStart := 1;
    Effect.RightControl1 := 1;
    Effect.RightControl2 := 1;
    Effect.RightEnd := 1;
    
    //UnitGC.GC.Add<TWrapEffect>(Effect, IntToStr(NativeInt(Effect)));
    
    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'wrap#: ' + E.Message);
  end;
end;

function n_wrap_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TWrapEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wrap_free') then Exit;

  try
    Effect := TWrapEffect(Args[0].p);
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'wrap_free: ' + E.Message);
  end;
end;

// =============================================================================
// LeftStart Property (0 - 1)
// =============================================================================

function p_wrap_leftstart_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wrap_leftstart#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TWrapEffect(Args[0].p).LeftStart := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'wrap_leftstart#: ' + E.Message);
  end;
end;

function n_wrap_leftstart_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wrap_leftstart') then Exit;

  try
    Result.n := TWrapEffect(Args[0].p).LeftStart;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'wrap_leftstart: ' + E.Message);
  end;
end;

// =============================================================================
// LeftControl1 Property (0 - 1)
// =============================================================================

function p_wrap_leftctrl1_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wrap_leftctrl1#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TWrapEffect(Args[0].p).LeftControl1 := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'wrap_leftctrl1#: ' + E.Message);
  end;
end;

function n_wrap_leftctrl1_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wrap_leftctrl1') then Exit;

  try
    Result.n := TWrapEffect(Args[0].p).LeftControl1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'wrap_leftctrl1: ' + E.Message);
  end;
end;

// =============================================================================
// LeftControl2 Property (0 - 1)
// =============================================================================

function p_wrap_leftctrl2_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wrap_leftctrl2#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TWrapEffect(Args[0].p).LeftControl2 := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'wrap_leftctrl2#: ' + E.Message);
  end;
end;

function n_wrap_leftctrl2_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wrap_leftctrl2') then Exit;

  try
    Result.n := TWrapEffect(Args[0].p).LeftControl2;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'wrap_leftctrl2: ' + E.Message);
  end;
end;

// =============================================================================
// LeftEnd Property (0 - 1)
// =============================================================================

function p_wrap_leftend_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wrap_leftend#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TWrapEffect(Args[0].p).LeftEnd := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'wrap_leftend#: ' + E.Message);
  end;
end;

function n_wrap_leftend_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wrap_leftend') then Exit;

  try
    Result.n := TWrapEffect(Args[0].p).LeftEnd;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'wrap_leftend: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_wrap_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wrap_enabled#') then Exit;

  try
    TWrapEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'wrap_enabled#: ' + E.Message);
  end;
end;

function n_wrap_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wrap_enabled') then Exit;

  try
    if TWrapEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'wrap_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_wrap_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wrap_trigger#') then Exit;

  try
    TWrapEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'wrap_trigger#: ' + E.Message);
  end;
end;

function s_wrap_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wrap_trigger$') then Exit;

  try
    Result.s := TWrapEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'wrap_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterWrapEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_wrap_error; Lib.Add('wrap_error@', Fn);
  Fn.Entry := @s_wrap_errormsg; Lib.Add('wrap_errormsg$@', Fn);
  Fn.Entry := @s_wrap_strerror; Lib.Add('wrap_strerror$@n', Fn);
  Fn.Entry := @n_wrap_clearerror; Lib.Add('wrap_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_wrap_new; Lib.Add('wrap#@#', Fn);
  Fn.Entry := @n_wrap_free; Lib.Add('wrap_free@#', Fn);

  // LeftStart property
  Fn.Entry := @p_wrap_leftstart_set; Lib.Add('wrap_leftstart#@#n', Fn);
  Fn.Entry := @n_wrap_leftstart_get; Lib.Add('wrap_leftstart@#', Fn);

  // LeftControl1 property
  Fn.Entry := @p_wrap_leftctrl1_set; Lib.Add('wrap_leftctrl1#@#n', Fn);
  Fn.Entry := @n_wrap_leftctrl1_get; Lib.Add('wrap_leftctrl1@#', Fn);

  // LeftControl2 property
  Fn.Entry := @p_wrap_leftctrl2_set; Lib.Add('wrap_leftctrl2#@#n', Fn);
  Fn.Entry := @n_wrap_leftctrl2_get; Lib.Add('wrap_leftctrl2@#', Fn);

  // LeftEnd property
  Fn.Entry := @p_wrap_leftend_set; Lib.Add('wrap_leftend#@#n', Fn);
  Fn.Entry := @n_wrap_leftend_get; Lib.Add('wrap_leftend@#', Fn);

  // Enabled property
  Fn.Entry := @p_wrap_enabled_set; Lib.Add('wrap_enabled#@#n', Fn);
  Fn.Entry := @n_wrap_enabled_get; Lib.Add('wrap_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_wrap_trigger_set; Lib.Add('wrap_trigger#@#$', Fn);
  Fn.Entry := @s_wrap_trigger_get; Lib.Add('wrap_trigger$@#', Fn);
end;

end.
