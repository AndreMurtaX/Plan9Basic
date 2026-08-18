unit FillRGBEffectLib;

{******************************************************************************
  FillRGBEffectLib - Fill RGB Effect Library for Plan9Basic
  Version: 1.0.0
  
  Tints non-transparent pixels with the specified RGB color.
  Unlike FillEffect, this preserves transparency and only affects
  visible pixels.
  
  Function Count: 12 functions
  
  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterFillRGBEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TFillRGBEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_fillrgb_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_fillrgb_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_fillrgb_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_fillrgb_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_fillrgb_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TFillRGBEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'fillrgb#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TFillRGBEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Color := TAlphaColorRec.White;
    
    // GC registration removed - parent ownership handles cleanup
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    //UnitGC.GC.Add<TFillRGBEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'fillrgb#: ' + E.Message);
  end;
end;

function n_fillrgb_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TFillRGBEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fillrgb_free') then Exit;

  try
    Effect := TFillRGBEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'fillrgb_free: ' + E.Message);
  end;
end;

// =============================================================================
// Color Property (TAlphaColor as integer)
// =============================================================================

function p_fillrgb_color_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fillrgb_color#') then Exit;

  try
    TFillRGBEffect(Args[0].p).Color := TAlphaColor(Trunc(Args[1].n));
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'fillrgb_color#: ' + E.Message);
  end;
end;

function n_fillrgb_color_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fillrgb_color') then Exit;

  try
    Result.n := TFillRGBEffect(Args[0].p).Color;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'fillrgb_color: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_fillrgb_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fillrgb_enabled#') then Exit;

  try
    TFillRGBEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'fillrgb_enabled#: ' + E.Message);
  end;
end;

function n_fillrgb_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fillrgb_enabled') then Exit;

  try
    if TFillRGBEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'fillrgb_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_fillrgb_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fillrgb_trigger#') then Exit;

  try
    TFillRGBEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'fillrgb_trigger#: ' + E.Message);
  end;
end;

function s_fillrgb_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'fillrgb_trigger$') then Exit;

  try
    Result.s := TFillRGBEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'fillrgb_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterFillRGBEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_fillrgb_error; Lib.Add('fillrgb_error@', Fn);
  Fn.Entry := @s_fillrgb_errormsg; Lib.Add('fillrgb_errormsg$@', Fn);
  Fn.Entry := @s_fillrgb_strerror; Lib.Add('fillrgb_strerror$@n', Fn);
  Fn.Entry := @n_fillrgb_clearerror; Lib.Add('fillrgb_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_fillrgb_new; Lib.Add('fillrgb#@#', Fn);
  Fn.Entry := @n_fillrgb_free; Lib.Add('fillrgb_free@#', Fn);

  // Color property
  Fn.Entry := @p_fillrgb_color_set; Lib.Add('fillrgb_color#@#n', Fn);
  Fn.Entry := @n_fillrgb_color_get; Lib.Add('fillrgb_color@#', Fn);

  // Enabled property
  Fn.Entry := @p_fillrgb_enabled_set; Lib.Add('fillrgb_enabled#@#n', Fn);
  Fn.Entry := @n_fillrgb_enabled_get; Lib.Add('fillrgb_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_fillrgb_trigger_set; Lib.Add('fillrgb_trigger#@#$', Fn);
  Fn.Entry := @s_fillrgb_trigger_get; Lib.Add('fillrgb_trigger$@#', Fn);
end;

end.
