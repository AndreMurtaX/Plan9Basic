unit ToonEffectLib;

{******************************************************************************
  ToonEffectLib - Toon Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TToonEffect wrapper for creating cartoon/posterized
  appearance on visual controls. Reduces colors to create a flat, comic-like look.

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
  - Levels: Number of color levels (2-255, default 5)
    Lower values = fewer colors = more cartoon-like
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

procedure RegisterToonEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, TToonEffect)) then
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

function n_toon_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_toon_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_toon_strerror(var Args: array of TAsmData): TAsmData;
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

function n_toon_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_toon_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TToonEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'toon#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TToonEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Levels := 5;
    
    //UnitGC.GC.Add<TToonEffect>(Effect, IntToStr(NativeInt(Effect)));
    
    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'toon#: ' + E.Message);
  end;
end;

function n_toon_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TToonEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'toon_free') then Exit;

  try
    Effect := TToonEffect(Args[0].p);
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'toon_free: ' + E.Message);
  end;
end;

// =============================================================================
// Levels Property (2 - 255)
// =============================================================================

function p_toon_levels_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'toon_levels#') then Exit;

  try
    Value := Args[1].n;
    if Value < 2 then Value := 2;
    if Value > 255 then Value := 255;
    TToonEffect(Args[0].p).Levels := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'toon_levels#: ' + E.Message);
  end;
end;

function n_toon_levels_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'toon_levels') then Exit;

  try
    Result.n := TToonEffect(Args[0].p).Levels;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'toon_levels: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_toon_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'toon_enabled#') then Exit;

  try
    TToonEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'toon_enabled#: ' + E.Message);
  end;
end;

function n_toon_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'toon_enabled') then Exit;

  try
    if TToonEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'toon_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_toon_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'toon_trigger#') then Exit;

  try
    TToonEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'toon_trigger#: ' + E.Message);
  end;
end;

function s_toon_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'toon_trigger$') then Exit;

  try
    Result.s := TToonEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'toon_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterToonEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_toon_error; Lib.Add('toon_error@', Fn);
  Fn.Entry := @s_toon_errormsg; Lib.Add('toon_errormsg$@', Fn);
  Fn.Entry := @s_toon_strerror; Lib.Add('toon_strerror$@n', Fn);
  Fn.Entry := @n_toon_clearerror; Lib.Add('toon_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_toon_new; Lib.Add('toon#@#', Fn);
  Fn.Entry := @n_toon_free; Lib.Add('toon_free@#', Fn);

  // Levels property
  Fn.Entry := @p_toon_levels_set; Lib.Add('toon_levels#@#n', Fn);
  Fn.Entry := @n_toon_levels_get; Lib.Add('toon_levels@#', Fn);

  // Enabled property
  Fn.Entry := @p_toon_enabled_set; Lib.Add('toon_enabled#@#n', Fn);
  Fn.Entry := @n_toon_enabled_get; Lib.Add('toon_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_toon_trigger_set; Lib.Add('toon_trigger#@#$', Fn);
  Fn.Entry := @s_toon_trigger_get; Lib.Add('toon_trigger$@#', Fn);
end;

end.
