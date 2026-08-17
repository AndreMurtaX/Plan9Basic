unit ReflectionEffectLib;

{******************************************************************************
  ReflectionEffectLib - Reflection Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TReflectionEffect wrapper for creating mirror-like
  reflections below visual controls. Creates professional UI effects similar
  to iOS-style reflections.

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
  - Creates mirror reflection below any visual control
  - Adjustable reflection length (how far down it extends)
  - Adjustable opacity (how visible the reflection is)
  - Adjustable offset (gap between control and reflection)
  - GPU-accelerated rendering
  - Trigger support for conditional activation

  PROPERTIES:
  ===========
  - Length: 0.0-1.0, portion of control height reflected (default 0.5)
  - Opacity: 0.0-1.0, reflection transparency (default 0.5)
  - Offset: Pixels between control and reflection (default 0)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  USAGE PATTERN:
  ==============
    let frm# = form#("Reflection Demo", 400, 300)
    let btn# = button#(frm#, "Reflected Button")
    button_bounds#(btn#, 50, 50, 150, 50)

    let refl# = reflection#(btn#)
    reflection_length#(refl#, 0.4)
    reflection_opacity#(refl#, 0.3)
    reflection_offset#(refl#, 2)

    form_show(frm#)

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC;

procedure RegisterReflectionEffectFuncs(Lib: TFunctionsDictionary);

implementation

var
  //ModuleEngine: TBasicEngine;
  //ModuleOutput: TStrings;
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
  if not (TObject(P) is TReflectionEffect) then
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

function n_reflection_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_reflection_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_reflection_strerror(var Args: array of TAsmData): TAsmData;
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

function n_reflection_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_reflection_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TReflectionEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'reflection#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TReflectionEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TReflectionEffect>(Effect, IntToStr(NativeInt(Effect)));

    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'reflection#: ' + E.Message);
  end;
end;

function n_reflection_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TReflectionEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'reflection_free') then Exit;

  try
    Effect := TReflectionEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'reflection_free: ' + E.Message);
  end;
end;

// =============================================================================
// Length Property (0.0 - 1.0)
// =============================================================================

function p_reflection_length_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'reflection_length#') then Exit;

  try
    Value := Args[1].n;
    // Clamp to valid range
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;
    TReflectionEffect(Args[0].p).Length := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'reflection_length#: ' + E.Message);
  end;
end;

function n_reflection_length_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'reflection_length') then Exit;

  try
    Result.n := TReflectionEffect(Args[0].p).Length;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'reflection_length: ' + E.Message);
  end;
end;

// =============================================================================
// Opacity Property (0.0 - 1.0)
// =============================================================================

function p_reflection_opacity_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'reflection_opacity#') then Exit;

  try
    Value := Args[1].n;
    // Clamp to valid range
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;
    TReflectionEffect(Args[0].p).Opacity := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'reflection_opacity#: ' + E.Message);
  end;
end;

function n_reflection_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'reflection_opacity') then Exit;

  try
    Result.n := TReflectionEffect(Args[0].p).Opacity;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'reflection_opacity: ' + E.Message);
  end;
end;

// =============================================================================
// Offset Property (pixels)
// =============================================================================

function p_reflection_offset_set(var Args: array of TAsmData): TAsmData;
var
  Value: Integer;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'reflection_offset#') then Exit;

  try
    Value := Trunc(Args[1].n);
    if Value < 0 then Value := 0;
    TReflectionEffect(Args[0].p).Offset := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'reflection_offset#: ' + E.Message);
  end;
end;

function n_reflection_offset_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'reflection_offset') then Exit;

  try
    Result.n := TReflectionEffect(Args[0].p).Offset;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'reflection_offset: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_reflection_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'reflection_enabled#') then Exit;

  try
    TReflectionEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'reflection_enabled#: ' + E.Message);
  end;
end;

function n_reflection_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'reflection_enabled') then Exit;

  try
    if TReflectionEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'reflection_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_reflection_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'reflection_trigger#') then Exit;

  try
    TReflectionEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'reflection_trigger#: ' + E.Message);
  end;
end;

function s_reflection_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'reflection_trigger$') then Exit;

  try
    Result.s := TReflectionEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'reflection_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterReflectionEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_reflection_error; Lib.Add('reflection_error@', Fn);
  Fn.Entry := @s_reflection_errormsg; Lib.Add('reflection_errormsg$@', Fn);
  Fn.Entry := @s_reflection_strerror; Lib.Add('reflection_strerror$@n', Fn);
  Fn.Entry := @n_reflection_clearerror; Lib.Add('reflection_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_reflection_new; Lib.Add('reflection#@#', Fn);
  Fn.Entry := @n_reflection_free; Lib.Add('reflection_free@#', Fn);

  // Length property
  Fn.Entry := @p_reflection_length_set; Lib.Add('reflection_length#@#n', Fn);
  Fn.Entry := @n_reflection_length_get; Lib.Add('reflection_length@#', Fn);

  // Opacity property
  Fn.Entry := @p_reflection_opacity_set; Lib.Add('reflection_opacity#@#n', Fn);
  Fn.Entry := @n_reflection_opacity_get; Lib.Add('reflection_opacity@#', Fn);

  // Offset property
  Fn.Entry := @p_reflection_offset_set; Lib.Add('reflection_offset#@#n', Fn);
  Fn.Entry := @n_reflection_offset_get; Lib.Add('reflection_offset@#', Fn);

  // Enabled property
  Fn.Entry := @p_reflection_enabled_set; Lib.Add('reflection_enabled#@#n', Fn);
  Fn.Entry := @n_reflection_enabled_get; Lib.Add('reflection_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_reflection_trigger_set; Lib.Add('reflection_trigger#@#$', Fn);
  Fn.Entry := @s_reflection_trigger_get; Lib.Add('reflection_trigger$@#', Fn);
end;

end.
