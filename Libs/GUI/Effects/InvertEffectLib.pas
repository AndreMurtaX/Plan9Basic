unit InvertEffectLib;

{******************************************************************************
  InvertEffectLib - Invert Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TInvertEffect wrapper for inverting the colors of
  visual controls. Creates a photographic negative effect.

  Function Count: 10 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PROPERTIES:
  ===========
  - Enabled: Turn effect on/off (default: on)
  - Trigger: Conditional activation string

  Note: This is a simple on/off effect with no adjustable parameters.
  When enabled, all colors are inverted (black becomes white, red becomes
  cyan, etc.)

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry;

procedure RegisterInvertEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, TInvertEffect)) then
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

function n_invert_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_invert_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_invert_strerror(var Args: array of TAsmData): TAsmData;
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

function n_invert_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_invert_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TInvertEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'invert#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    // Create with parent as Owner - parent will free effect when destroyed
    // This avoids double-free issues with the GC
    Effect := TInvertEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TInvertEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Torna este efeito um handle validavel sem dereferenciar o
    //ponteiro que o programa BASIC devolver. A baixa e automatica:
    //o efeito pertence ao pai, e o registry escuta FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'invert#: ' + E.Message);
  end;
end;

function n_invert_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TInvertEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'invert_free') then Exit;

  try
    Effect := TInvertEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'invert_free: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_invert_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'invert_enabled#') then Exit;

  try
    TInvertEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'invert_enabled#: ' + E.Message);
  end;
end;

function n_invert_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'invert_enabled') then Exit;

  try
    if TInvertEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'invert_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_invert_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'invert_trigger#') then Exit;

  try
    TInvertEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'invert_trigger#: ' + E.Message);
  end;
end;

function s_invert_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'invert_trigger$') then Exit;

  try
    Result.s := TInvertEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'invert_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterInvertEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_invert_error; Lib.Add('invert_error@', Fn);
  Fn.Entry := @s_invert_errormsg; Lib.Add('invert_errormsg$@', Fn);
  Fn.Entry := @s_invert_strerror; Lib.Add('invert_strerror$@n', Fn);
  Fn.Entry := @n_invert_clearerror; Lib.Add('invert_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_invert_new; Lib.Add('invert#@#', Fn);
  Fn.Entry := @n_invert_free; Lib.Add('invert_free@#', Fn);

  // Enabled property
  Fn.Entry := @p_invert_enabled_set; Lib.Add('invert_enabled#@#n', Fn);
  Fn.Entry := @n_invert_enabled_get; Lib.Add('invert_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_invert_trigger_set; Lib.Add('invert_trigger#@#$', Fn);
  Fn.Entry := @s_invert_trigger_get; Lib.Add('invert_trigger$@#', Fn);
end;

end.

