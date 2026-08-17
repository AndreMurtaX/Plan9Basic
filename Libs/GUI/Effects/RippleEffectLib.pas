unit RippleEffectLib;

{******************************************************************************
  RippleEffectLib - Ripple Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TRippleEffect wrapper for creating water ripple distortion
  on visual controls.

  Function Count: 18 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PROPERTIES:
  ===========
  - Amplitude: Ripple height (0-1, default 0.1)
  - Frequency: Number of ripples (0-100, default 70)
  - Phase: Ripple phase for animation (0-360)
  - AspectRatio: Width/height ratio (0.5-2.0, default 1.5)
  - CenterX: Horizontal center (0.0-1.0, default 0.5)
  - CenterY: Vertical center (0.0-1.0, default 0.5)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC;

procedure RegisterRippleEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (TObject(P) is TRippleEffect) then
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

function n_ripple_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_ripple_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_ripple_strerror(var Args: array of TAsmData): TAsmData;
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

function n_ripple_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_ripple_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TRippleEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'ripple#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TRippleEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Amplitude := 0.1;
    Effect.Frequency := 70;
    Effect.Phase := 0;
    Effect.AspectRatio := 1.5;
    Effect.Center := PointF(0.5, 0.5);

    // GC.Add removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TRippleEffect>(Effect, IntToStr(NativeInt(Effect)));

    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'ripple#: ' + E.Message);
  end;
end;

function n_ripple_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TRippleEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_free') then Exit;

  try
    Effect := TRippleEffect(Args[0].p);
    // GC.Collect removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'ripple_free: ' + E.Message);
  end;
end;

// =============================================================================
// Amplitude Property (0 - 1)
// =============================================================================

function p_ripple_amplitude_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_amplitude#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TRippleEffect(Args[0].p).Amplitude := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'ripple_amplitude#: ' + E.Message);
  end;
end;

function n_ripple_amplitude_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_amplitude') then Exit;

  try
    Result.n := TRippleEffect(Args[0].p).Amplitude;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'ripple_amplitude: ' + E.Message);
  end;
end;

// =============================================================================
// Frequency Property (0 - 100)
// =============================================================================

function p_ripple_frequency_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_frequency#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 100 then Value := 100;
    TRippleEffect(Args[0].p).Frequency := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'ripple_frequency#: ' + E.Message);
  end;
end;

function n_ripple_frequency_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_frequency') then Exit;

  try
    Result.n := TRippleEffect(Args[0].p).Frequency;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'ripple_frequency: ' + E.Message);
  end;
end;

// =============================================================================
// Phase Property (animatable)
// =============================================================================

function p_ripple_phase_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_phase#') then Exit;

  try
    TRippleEffect(Args[0].p).Phase := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'ripple_phase#: ' + E.Message);
  end;
end;

function n_ripple_phase_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_phase') then Exit;

  try
    Result.n := TRippleEffect(Args[0].p).Phase;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'ripple_phase: ' + E.Message);
  end;
end;

// =============================================================================
// AspectRatio Property (0.5 - 2.0)
// =============================================================================

function p_ripple_aspectratio_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_aspectratio#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.5 then Value := 0.5;
    if Value > 2.0 then Value := 2.0;
    TRippleEffect(Args[0].p).AspectRatio := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'ripple_aspectratio#: ' + E.Message);
  end;
end;

function n_ripple_aspectratio_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_aspectratio') then Exit;

  try
    Result.n := TRippleEffect(Args[0].p).AspectRatio;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'ripple_aspectratio: ' + E.Message);
  end;
end;

// =============================================================================
// CenterX Property (0.0 - 1.0)
// =============================================================================

function p_ripple_centerx_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_centerx#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;
    Pt := TRippleEffect(Args[0].p).Center;
    Pt.X := Value;
    TRippleEffect(Args[0].p).Center := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'ripple_centerx#: ' + E.Message);
  end;
end;

function n_ripple_centerx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_centerx') then Exit;

  try
    Result.n := TRippleEffect(Args[0].p).Center.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'ripple_centerx: ' + E.Message);
  end;
end;

// =============================================================================
// CenterY Property (0.0 - 1.0)
// =============================================================================

function p_ripple_centery_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_centery#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;
    Pt := TRippleEffect(Args[0].p).Center;
    Pt.Y := Value;
    TRippleEffect(Args[0].p).Center := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'ripple_centery#: ' + E.Message);
  end;
end;

function n_ripple_centery_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_centery') then Exit;

  try
    Result.n := TRippleEffect(Args[0].p).Center.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'ripple_centery: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_ripple_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_enabled#') then Exit;

  try
    TRippleEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'ripple_enabled#: ' + E.Message);
  end;
end;

function n_ripple_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_enabled') then Exit;

  try
    if TRippleEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'ripple_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_ripple_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_trigger#') then Exit;

  try
    TRippleEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'ripple_trigger#: ' + E.Message);
  end;
end;

function s_ripple_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'ripple_trigger$') then Exit;

  try
    Result.s := TRippleEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'ripple_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterRippleEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_ripple_error; Lib.Add('ripple_error@', Fn);
  Fn.Entry := @s_ripple_errormsg; Lib.Add('ripple_errormsg$@', Fn);
  Fn.Entry := @s_ripple_strerror; Lib.Add('ripple_strerror$@n', Fn);
  Fn.Entry := @n_ripple_clearerror; Lib.Add('ripple_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_ripple_new; Lib.Add('ripple#@#', Fn);
  Fn.Entry := @n_ripple_free; Lib.Add('ripple_free@#', Fn);

  // Amplitude property
  Fn.Entry := @p_ripple_amplitude_set; Lib.Add('ripple_amplitude#@#n', Fn);
  Fn.Entry := @n_ripple_amplitude_get; Lib.Add('ripple_amplitude@#', Fn);

  // Frequency property
  Fn.Entry := @p_ripple_frequency_set; Lib.Add('ripple_frequency#@#n', Fn);
  Fn.Entry := @n_ripple_frequency_get; Lib.Add('ripple_frequency@#', Fn);

  // Phase property
  Fn.Entry := @p_ripple_phase_set; Lib.Add('ripple_phase#@#n', Fn);
  Fn.Entry := @n_ripple_phase_get; Lib.Add('ripple_phase@#', Fn);

  // AspectRatio property
  Fn.Entry := @p_ripple_aspectratio_set; Lib.Add('ripple_aspectratio#@#n', Fn);
  Fn.Entry := @n_ripple_aspectratio_get; Lib.Add('ripple_aspectratio@#', Fn);

  // CenterX property
  Fn.Entry := @p_ripple_centerx_set; Lib.Add('ripple_centerx#@#n', Fn);
  Fn.Entry := @n_ripple_centerx_get; Lib.Add('ripple_centerx@#', Fn);

  // CenterY property
  Fn.Entry := @p_ripple_centery_set; Lib.Add('ripple_centery#@#n', Fn);
  Fn.Entry := @n_ripple_centery_get; Lib.Add('ripple_centery@#', Fn);

  // Enabled property
  Fn.Entry := @p_ripple_enabled_set; Lib.Add('ripple_enabled#@#n', Fn);
  Fn.Entry := @n_ripple_enabled_get; Lib.Add('ripple_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_ripple_trigger_set; Lib.Add('ripple_trigger#@#$', Fn);
  Fn.Entry := @s_ripple_trigger_get; Lib.Add('ripple_trigger$@#', Fn);
end;

end.
