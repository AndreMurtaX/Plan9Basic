unit MaskToAlphaEffectLib;

{******************************************************************************
  MaskToAlphaEffectLib - Mask To Alpha Effect Library for Plan9Basic
  Version: 1.0.0

  Converts the grayscale values of the image to alpha channel values.
  White becomes fully opaque, black becomes fully transparent.
  Useful for creating masks from grayscale images.

  Function Count: 10 functions

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC;

procedure RegisterMaskToAlphaEffectFuncs(Lib: TFunctionsDictionary);

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
    Exit();
  end;
  if not (TObject(P) is TMaskToAlphaEffect) then
  begin
    SetError(ERR_INVALID_EFFECT, FuncName + ': invalid effect object');
    Exit();
  end;
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if not Assigned(P) then
  begin
    SetError(ERR_NIL_PARENT, FuncName + ': parent is nil');
    Exit();
  end;
  if not (TObject(P) is TFmxObject) then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': invalid parent object');
    Exit();
  end;
  Result := True;
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_mask2a_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_mask2a_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_mask2a_strerror(var Args: array of TAsmData): TAsmData;
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

function n_mask2a_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_mask2a_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TMaskToAlphaEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'mask2a#') then Exit();

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TMaskToAlphaEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;

    // GC.Add removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TMaskToAlphaEffect>(Effect, IntToStr(NativeInt(Effect)));

    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'mask2a#: ' + E.Message);
  end;
end;

function n_mask2a_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TMaskToAlphaEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'mask2a_free') then Exit();

  try
    Effect := TMaskToAlphaEffect(Args[0].p);
    // GC.Collect removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'mask2a_free: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_mask2a_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'mask2a_enabled#') then Exit();

  try
    TMaskToAlphaEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'mask2a_enabled#: ' + E.Message);
  end;
end;

function n_mask2a_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'mask2a_enabled') then Exit();

  try
    if TMaskToAlphaEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'mask2a_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_mask2a_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'mask2a_trigger#') then Exit();

  try
    TMaskToAlphaEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'mask2a_trigger#: ' + E.Message);
  end;
end;

function s_mask2a_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'mask2a_trigger$') then Exit();

  try
    Result.s := TMaskToAlphaEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'mask2a_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterMaskToAlphaEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_mask2a_error; Lib.Add('mask2a_error@', Fn);
  Fn.Entry := @s_mask2a_errormsg; Lib.Add('mask2a_errormsg$@', Fn);
  Fn.Entry := @s_mask2a_strerror; Lib.Add('mask2a_strerror$@n', Fn);
  Fn.Entry := @n_mask2a_ClearError; Lib.Add('mask2a_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_mask2a_new; Lib.Add('mask2a#@#', Fn);
  Fn.Entry := @n_mask2a_free; Lib.Add('mask2a_free@#', Fn);

  // Enabled property
  Fn.Entry := @p_mask2a_enabled_set; Lib.Add('mask2a_enabled#@#n', Fn);
  Fn.Entry := @n_mask2a_enabled_get; Lib.Add('mask2a_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_mask2a_trigger_set; Lib.Add('mask2a_trigger#@#$', Fn);
  Fn.Entry := @s_mask2a_trigger_get; Lib.Add('mask2a_trigger$@#', Fn);
end;

end.

