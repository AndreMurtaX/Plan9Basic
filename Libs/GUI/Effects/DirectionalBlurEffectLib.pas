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

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC;

procedure RegisterDirectionalBlurEffectFuncs(Lib: TFunctionsDictionary);

implementation

var
  LastError: Integer = 0;
  LastErrorMsg: String = '';

const
  ERR_NONE = 0;
  ERR_NIL_EFFECT = 1;
  ERR_INVALID_EFFECT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_NIL_PARENT = 4;
  ERR_INVALID_PARENT = 5;

procedure SetError(Code: Integer; const Msg: String);
begin
  LastError := Code;
  LastErrorMsg := Msg;
end;

procedure ClearError;
begin
  LastError := ERR_NONE;
  LastErrorMsg := '';
end;

function ValidateEffect(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if not Assigned(P) then
  begin
    SetError(ERR_NIL_EFFECT, FuncName + ': effect is nil');
    Exit;
  end;
  if not (TObject(P) is TDirectionalBlurEffect) then
  begin
    SetError(ERR_INVALID_EFFECT, FuncName + ': invalid effect object');
    Exit;
  end;
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if not Assigned(P) then
  begin
    SetError(ERR_NIL_PARENT, FuncName + ': parent is nil');
    Exit;
  end;
  if not (TObject(P) is TFmxObject) then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': invalid parent object');
    Exit;
  end;
  Result := True;
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_dirblur_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_dirblur_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_dirblur_strerror(var Args: array of TAsmData): TAsmData;
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
  else
    Result.s := 'Unknown error code: ' + IntToStr(Code);
  end;
end;

function n_dirblur_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
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

