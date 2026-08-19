unit FillEffectLib;

{******************************************************************************
  FillEffectLib - Fill Effect Library for Plan9Basic
  Version: 1.0.0

  Fills the entire visual control with a solid color.
  Useful for color overlays, tinting, and masking effects.

  Function Count: 12 functions

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterFillEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TFillEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_fill_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_fill_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_fill_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_fill_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_fill_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TFillEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'fill#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TFillEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Color := TAlphaColorRec.White;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TFillEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'fill#: ' + E.Message);
  end;
end;

function n_fill_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TFillEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fill_free') then Exit;

  try
    Effect := TFillEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'fill_free: ' + E.Message);
  end;
end;

// =============================================================================
// Color Property (TAlphaColor as integer)
// =============================================================================

function p_fill_color_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fill_color#') then Exit;

  try
    TFillEffect(Args[0].p).Color := TAlphaColor(Trunc(Args[1].n));
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'fill_color#: ' + E.Message);
  end;
end;

function n_fill_color_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fill_color') then Exit;

  try
    Result.n := TFillEffect(Args[0].p).Color;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'fill_color: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_fill_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fill_enabled#') then Exit;

  try
    TFillEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'fill_enabled#: ' + E.Message);
  end;
end;

function n_fill_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fill_enabled') then Exit;

  try
    if TFillEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'fill_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_fill_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fill_trigger#') then Exit;

  try
    TFillEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'fill_trigger#: ' + E.Message);
  end;
end;

function s_fill_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fill_trigger$') then Exit;

  try
    Result.s := TFillEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'fill_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterFillEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_fill_error; Lib.Add('fill_error@', Fn);
  Fn.Entry := @s_fill_errormsg; Lib.Add('fill_errormsg$@', Fn);
  Fn.Entry := @s_fill_strerror; Lib.Add('fill_strerror$@n', Fn);
  Fn.Entry := @n_fill_clearerror; Lib.Add('fill_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_fill_new; Lib.Add('fill#@#', Fn);
  Fn.Entry := @n_fill_free; Lib.Add('fill_free@#', Fn);

  // Color property
  Fn.Entry := @p_fill_color_set; Lib.Add('fill_color#@#n', Fn);
  Fn.Entry := @n_fill_color_get; Lib.Add('fill_color@#', Fn);

  // Enabled property
  Fn.Entry := @p_fill_enabled_set; Lib.Add('fill_enabled#@#n', Fn);
  Fn.Entry := @n_fill_enabled_get; Lib.Add('fill_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_fill_trigger_set; Lib.Add('fill_trigger#@#$', Fn);
  Fn.Entry := @s_fill_trigger_get; Lib.Add('fill_trigger$@#', Fn);
end;

end.
