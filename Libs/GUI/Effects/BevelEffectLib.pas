unit BevelEffectLib;

{******************************************************************************
  BevelEffectLib - Bevel Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TBevelEffect wrapper for creating 3D bevel/emboss effects
  on visual controls. Creates raised or sunken appearances with adjustable
  light direction.

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
  - Creates 3D raised or sunken bevel effect
  - Adjustable light direction (0-360 degrees)
  - Adjustable bevel size
  - GPU-accelerated rendering
  - Trigger support for conditional activation

  PROPERTIES:
  ===========
  - Direction: Light source angle in degrees (0-360, default: 45)
  - Size: Bevel edge size in pixels (0-10, default: 1)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  DIRECTION VALUES:
  =================
  - 0/360: Light from right
  - 45: Light from top-right (default)
  - 90: Light from top
  - 135: Light from top-left
  - 180: Light from left
  - 225: Light from bottom-left
  - 270: Light from bottom
  - 315: Light from bottom-right

  USAGE PATTERN:
  ==============
    let frm# = form#("Bevel Demo", 400, 300)
    let btn# = button#(frm#, "Beveled Button")
    button_bounds#(btn#, 50, 50, 150, 50)

    let bvl# = bevel#(btn#)
    bevel_direction#(bvl#, 45)
    bevel_size#(bvl#, 2)

    form_show(frm#)

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC;

procedure RegisterBevelEffectFuncs(Lib: TFunctionsDictionary);

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

// =============================================================================
// Error Handling
// =============================================================================

procedure SetError(Code: Integer; const Msg: String);
begin
  LastError := Code;
  LastErrorMsg := Msg;
end;

procedure ClearError();
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
  if not (TObject(P) is TBevelEffect) then
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

function n_bevel_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_bevel_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_bevel_strerror(var Args: array of TAsmData): TAsmData;
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

function n_bevel_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_bevel_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TBevelEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'bevel#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TBevelEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Direction := 45; // Default: light from top-right
    Effect.Size := 1;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TBevelEffect>(Effect, IntToStr(NativeInt(Effect)));

    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bevel#: ' + E.Message);
  end;
end;

function n_bevel_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TBevelEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'bevel_free') then Exit;

  try
    Effect := TBevelEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bevel_free: ' + E.Message);
  end;
end;

// =============================================================================
// Direction Property (0 - 360 degrees)
// =============================================================================

function p_bevel_direction_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'bevel_direction#') then Exit;

  try
    Value := Args[1].n;
    // Normalize to 0-360 range
    while Value < 0 do Value := Value + 360;
    while Value >= 360 do Value := Value - 360;
    TBevelEffect(Args[0].p).Direction := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bevel_direction#: ' + E.Message);
  end;
end;

function n_bevel_direction_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'bevel_direction') then Exit;

  try
    Result.n := TBevelEffect(Args[0].p).Direction;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bevel_direction: ' + E.Message);
  end;
end;

// =============================================================================
// Size Property (0 - 10 pixels)
// =============================================================================

function p_bevel_size_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'bevel_size#') then Exit;

  try
    Value := Args[1].n;
    // Clamp to valid range
    if Value < 0 then Value := 0;
    if Value > 10 then Value := 10;
    TBevelEffect(Args[0].p).Size := Trunc(Value);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bevel_size#: ' + E.Message);
  end;
end;

function n_bevel_size_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'bevel_size') then Exit;

  try
    Result.n := TBevelEffect(Args[0].p).Size;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bevel_size: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_bevel_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'bevel_enabled#') then Exit;

  try
    TBevelEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bevel_enabled#: ' + E.Message);
  end;
end;

function n_bevel_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'bevel_enabled') then Exit;

  try
    if TBevelEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bevel_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_bevel_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'bevel_trigger#') then Exit;

  try
    TBevelEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bevel_trigger#: ' + E.Message);
  end;
end;

function s_bevel_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'bevel_trigger$') then Exit;

  try
    Result.s := TBevelEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bevel_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterBevelEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_bevel_error; Lib.Add('bevel_error@', Fn);
  Fn.Entry := @s_bevel_errormsg; Lib.Add('bevel_errormsg$@', Fn);
  Fn.Entry := @s_bevel_strerror; Lib.Add('bevel_strerror$@n', Fn);
  Fn.Entry := @n_bevel_clearerror; Lib.Add('bevel_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_bevel_new; Lib.Add('bevel#@#', Fn);
  Fn.Entry := @n_bevel_free; Lib.Add('bevel_free@#', Fn);

  // Direction property
  Fn.Entry := @p_bevel_direction_set; Lib.Add('bevel_direction#@#n', Fn);
  Fn.Entry := @n_bevel_direction_get; Lib.Add('bevel_direction@#', Fn);

  // Size property
  Fn.Entry := @p_bevel_size_set; Lib.Add('bevel_size#@#n', Fn);
  Fn.Entry := @n_bevel_size_get; Lib.Add('bevel_size@#', Fn);

  // Enabled property
  Fn.Entry := @p_bevel_enabled_set; Lib.Add('bevel_enabled#@#n', Fn);
  Fn.Entry := @n_bevel_enabled_get; Lib.Add('bevel_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_bevel_trigger_set; Lib.Add('bevel_trigger#@#$', Fn);
  Fn.Entry := @s_bevel_trigger_get; Lib.Add('bevel_trigger$@#', Fn);
end;

end.
