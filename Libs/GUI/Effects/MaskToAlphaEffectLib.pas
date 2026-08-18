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
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterMaskToAlphaEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TMaskToAlphaEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_mask2a_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_mask2a_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_mask2a_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_mask2a_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
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

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
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

