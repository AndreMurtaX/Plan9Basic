unit DirectionalBlurEffectLib;

{******************************************************************************
  DirectionalBlurEffectLib - Directional Blur Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TDirectionalBlurEffect wrapper for applying motion
  blur effects in a specified direction.

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
  - BlurAmount: Blur intensity (0 to 10, default 0.1)
  - Angle: Blur direction in degrees (0 to 360, default 0)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  ANGLE REFERENCE:
  ================
  - 0°: Right (horizontal)
  - 90°: Down (vertical)
  - 180°: Left (horizontal)
  - 270°: Up (vertical)

  Copyright (c) 2024-2026 André Murta
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterDirectionalBlurEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TDirectionalBlurEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_dirblur_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_dirblur_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_dirblur_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_dirblur_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_dirblur_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TDirectionalBlurEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'dirblur#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TDirectionalBlurEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.BlurAmount := 0.1;
    Effect.Angle := 0;

    //UnitGC.GC.Add<TDirectionalBlurEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'dirblur#: ' + E.Message);
  end;
end;

function n_dirblur_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TDirectionalBlurEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'dirblur_free') then Exit;

  try
    Effect := TDirectionalBlurEffect(Args[0].p);
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'dirblur_free: ' + E.Message);
  end;
end;

// =============================================================================
// BlurAmount Property (0 - 10)
// =============================================================================

function p_dirblur_bluramount_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'dirblur_bluramount#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 10 then Value := 10;
    TDirectionalBlurEffect(Args[0].p).BlurAmount := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'dirblur_bluramount#: ' + E.Message);
  end;
end;

function n_dirblur_bluramount_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'dirblur_bluramount') then Exit;

  try
    Result.n := TDirectionalBlurEffect(Args[0].p).BlurAmount;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'dirblur_bluramount: ' + E.Message);
  end;
end;

// =============================================================================
// Angle Property (0 - 360)
// =============================================================================

function p_dirblur_angle_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'dirblur_angle#') then Exit;

  try
    Value := Args[1].n;
    // Normalize to 0-360 range
    while Value < 0 do Value := Value + 360;
    while Value >= 360 do Value := Value - 360;
    TDirectionalBlurEffect(Args[0].p).Angle := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'dirblur_angle#: ' + E.Message);
  end;
end;

function n_dirblur_angle_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'dirblur_angle') then Exit;

  try
    Result.n := TDirectionalBlurEffect(Args[0].p).Angle;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'dirblur_angle: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_dirblur_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'dirblur_enabled#') then Exit;

  try
    TDirectionalBlurEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'dirblur_enabled#: ' + E.Message);
  end;
end;

function n_dirblur_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'dirblur_enabled') then Exit;

  try
    if TDirectionalBlurEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'dirblur_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_dirblur_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'dirblur_trigger#') then Exit;

  try
    TDirectionalBlurEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'dirblur_trigger#: ' + E.Message);
  end;
end;

function s_dirblur_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'dirblur_trigger$') then Exit;

  try
    Result.s := TDirectionalBlurEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'dirblur_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterDirectionalBlurEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_dirblur_error; Lib.Add('dirblur_error@', Fn);
  Fn.Entry := @s_dirblur_errormsg; Lib.Add('dirblur_errormsg$@', Fn);
  Fn.Entry := @s_dirblur_strerror; Lib.Add('dirblur_strerror$@n', Fn);
  Fn.Entry := @n_dirblur_clearerror; Lib.Add('dirblur_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_dirblur_new; Lib.Add('dirblur#@#', Fn);
  Fn.Entry := @n_dirblur_free; Lib.Add('dirblur_free@#', Fn);

  // BlurAmount property
  Fn.Entry := @p_dirblur_bluramount_set; Lib.Add('dirblur_bluramount#@#n', Fn);
  Fn.Entry := @n_dirblur_bluramount_get; Lib.Add('dirblur_bluramount@#', Fn);

  // Angle property
  Fn.Entry := @p_dirblur_angle_set; Lib.Add('dirblur_angle#@#n', Fn);
  Fn.Entry := @n_dirblur_angle_get; Lib.Add('dirblur_angle@#', Fn);

  // Enabled property
  Fn.Entry := @p_dirblur_enabled_set; Lib.Add('dirblur_enabled#@#n', Fn);
  Fn.Entry := @n_dirblur_enabled_get; Lib.Add('dirblur_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_dirblur_trigger_set; Lib.Add('dirblur_trigger#@#$', Fn);
  Fn.Entry := @s_dirblur_trigger_get; Lib.Add('dirblur_trigger$@#', Fn);
end;

end.

