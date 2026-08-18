unit TilerEffectLib;

{******************************************************************************
  TilerEffectLib - Tiler Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TTilerEffect wrapper for tiling images across
  multiple rows and columns.

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
  - VerticalTileCount: Number of vertical tiles (default 1)
  - HorizontalTileCount: Number of horizontal tiles (default 1)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  USAGE:
  ======
  Tiler effect repeats an image in a grid pattern. Great for creating
  wallpaper effects, texture tiling, and pattern repetition.

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry;

procedure RegisterTilerEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, TTilerEffect)) then
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

function n_tiler_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_tiler_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_tiler_strerror(var Args: array of TAsmData): TAsmData;
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

function n_tiler_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_tiler_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TTilerEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'tiler#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TTilerEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.VerticalTileCount := 1;
    Effect.HorizontalTileCount := 1;

    //UnitGC.GC.Add<TTilerEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'tiler#: ' + E.Message);
  end;
end;

function n_tiler_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TTilerEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'tiler_free') then Exit;

  try
    Effect := TTilerEffect(Args[0].p);
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'tiler_free: ' + E.Message);
  end;
end;

// =============================================================================
// VerticalTileCount Property
// =============================================================================

function p_tiler_vtiles_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'tiler_vtiles#') then Exit;

  try
    Value := Args[1].n;
    if Value < 1 then Value := 1;
    TTilerEffect(Args[0].p).VerticalTileCount := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'tiler_vtiles#: ' + E.Message);
  end;
end;

function n_tiler_vtiles_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'tiler_vtiles') then Exit;

  try
    Result.n := TTilerEffect(Args[0].p).VerticalTileCount;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'tiler_vtiles: ' + E.Message);
  end;
end;

// =============================================================================
// HorizontalTileCount Property
// =============================================================================

function p_tiler_htiles_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'tiler_htiles#') then Exit;

  try
    Value := Args[1].n;
    if Value < 1 then Value := 1;
    TTilerEffect(Args[0].p).HorizontalTileCount := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'tiler_htiles#: ' + E.Message);
  end;
end;

function n_tiler_htiles_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'tiler_htiles') then Exit;

  try
    Result.n := TTilerEffect(Args[0].p).HorizontalTileCount;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'tiler_htiles: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_tiler_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'tiler_enabled#') then Exit;

  try
    TTilerEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'tiler_enabled#: ' + E.Message);
  end;
end;

function n_tiler_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'tiler_enabled') then Exit;

  try
    if TTilerEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'tiler_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_tiler_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'tiler_trigger#') then Exit;

  try
    TTilerEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'tiler_trigger#: ' + E.Message);
  end;
end;

function s_tiler_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'tiler_trigger$') then Exit;

  try
    Result.s := TTilerEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'tiler_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterTilerEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_tiler_error; Lib.Add('tiler_error@', Fn);
  Fn.Entry := @s_tiler_errormsg; Lib.Add('tiler_errormsg$@', Fn);
  Fn.Entry := @s_tiler_strerror; Lib.Add('tiler_strerror$@n', Fn);
  Fn.Entry := @n_tiler_clearerror; Lib.Add('tiler_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_tiler_new; Lib.Add('tiler#@#', Fn);
  Fn.Entry := @n_tiler_free; Lib.Add('tiler_free@#', Fn);

  // VerticalTileCount property
  Fn.Entry := @p_tiler_vtiles_set; Lib.Add('tiler_vtiles#@#n', Fn);
  Fn.Entry := @n_tiler_vtiles_get; Lib.Add('tiler_vtiles@#', Fn);

  // HorizontalTileCount property
  Fn.Entry := @p_tiler_htiles_set; Lib.Add('tiler_htiles#@#n', Fn);
  Fn.Entry := @n_tiler_htiles_get; Lib.Add('tiler_htiles@#', Fn);

  // Enabled property
  Fn.Entry := @p_tiler_enabled_set; Lib.Add('tiler_enabled#@#n', Fn);
  Fn.Entry := @n_tiler_enabled_get; Lib.Add('tiler_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_tiler_trigger_set; Lib.Add('tiler_trigger#@#$', Fn);
  Fn.Entry := @s_tiler_trigger_get; Lib.Add('tiler_trigger$@#', Fn);
end;

end.

