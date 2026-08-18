unit WaveEffectLib;

{******************************************************************************
  WaveEffectLib - Wave Effect Library for Plan9Basic
  Version: 1.0.1

  Provides FireMonkey TWaveEffect wrapper for creating wave distortion
  on visual controls.

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
  - WaveSize: Size of waves (32-256, default 64)
    Higher values = smaller waves
  - Time: Wave time/phase for animation (animatable)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry;

procedure RegisterWaveEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, TWaveEffect)) then
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
  if not (IsHandleOf(P, TFmxObject)) then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': invalid parent object');
    Exit;
  end;
  Result := True;
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_wave_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_wave_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_wave_strerror(var Args: array of TAsmData): TAsmData;
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

function n_wave_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_wave_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TWaveEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'wave#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TWaveEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.WaveSize := 64;
    Effect.Time := 0;

    // GC registration removed - parent ownership handles cleanup
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    //UnitGC.GC.Add<TWaveEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'wave#: ' + E.Message);
  end;
end;

function n_wave_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TWaveEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wave_free') then Exit;

  try
    Effect := TWaveEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'wave_free: ' + E.Message);
  end;
end;

// =============================================================================
// WaveSize Property (32 - 256)
// =============================================================================

function p_wave_wavesize_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wave_wavesize#') then Exit;

  try
    Value := Args[1].n;
    if Value < 32 then Value := 32;
    if Value > 256 then Value := 256;
    TWaveEffect(Args[0].p).WaveSize := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'wave_wavesize#: ' + E.Message);
  end;
end;

function n_wave_wavesize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wave_wavesize') then Exit;

  try
    Result.n := TWaveEffect(Args[0].p).WaveSize;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'wave_wavesize: ' + E.Message);
  end;
end;

// =============================================================================
// Time Property (animatable for wave motion)
// =============================================================================

function p_wave_time_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wave_time#') then Exit;

  try
    TWaveEffect(Args[0].p).Time := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'wave_time#: ' + E.Message);
  end;
end;

function n_wave_time_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wave_time') then Exit;

  try
    Result.n := TWaveEffect(Args[0].p).Time;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'wave_time: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_wave_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wave_enabled#') then Exit;

  try
    TWaveEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'wave_enabled#: ' + E.Message);
  end;
end;

function n_wave_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wave_enabled') then Exit;

  try
    if TWaveEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'wave_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_wave_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wave_trigger#') then Exit;

  try
    TWaveEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'wave_trigger#: ' + E.Message);
  end;
end;

function s_wave_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'wave_trigger$') then Exit;

  try
    Result.s := TWaveEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'wave_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterWaveEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_wave_error; Lib.Add('wave_error@', Fn);
  Fn.Entry := @s_wave_errormsg; Lib.Add('wave_errormsg$@', Fn);
  Fn.Entry := @s_wave_strerror; Lib.Add('wave_strerror$@n', Fn);
  Fn.Entry := @n_wave_clearerror; Lib.Add('wave_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_wave_new; Lib.Add('wave#@#', Fn);
  Fn.Entry := @n_wave_free; Lib.Add('wave_free@#', Fn);

  // WaveSize property
  Fn.Entry := @p_wave_wavesize_set; Lib.Add('wave_wavesize#@#n', Fn);
  Fn.Entry := @n_wave_wavesize_get; Lib.Add('wave_wavesize@#', Fn);

  // Time property
  Fn.Entry := @p_wave_time_set; Lib.Add('wave_time#@#n', Fn);
  Fn.Entry := @n_wave_time_get; Lib.Add('wave_time@#', Fn);

  // Enabled property
  Fn.Entry := @p_wave_enabled_set; Lib.Add('wave_enabled#@#n', Fn);
  Fn.Entry := @n_wave_enabled_get; Lib.Add('wave_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_wave_trigger_set; Lib.Add('wave_trigger#@#$', Fn);
  Fn.Entry := @s_wave_trigger_get; Lib.Add('wave_trigger$@#', Fn);
end;

end.

