unit SlideTransitionEffectLib;

{******************************************************************************
  SlideTransitionEffectLib - Slide Transition Effect Library for Plan9Basic
  Version: 1.2.0 - Fixed Progress range (0-1 normalized, internally 0-100)

  Provides FireMonkey TSlideTransitionEffect wrapper for creating slide
  transitions on visual controls.

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
  - Progress: Transition progress (0.0-1.0, default 0)
  - SlideAmount: Slide offset amount (x, y as PointF)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  FMX.Graphics,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterSlideTransitionEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TSlideTransitionEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_slidetrans_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_slidetrans_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_slidetrans_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_slidetrans_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_slidetrans_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TSlideTransitionEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'slidetrans#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TSlideTransitionEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Progress := 0;
    Effect.SlideAmount := PointF(0, 0);
    
    //UnitGC.GC.Add<TSlideTransitionEffect>(Effect, IntToStr(NativeInt(Effect)));
    
    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'slidetrans#: ' + E.Message);
  end;
end;

function n_slidetrans_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TSlideTransitionEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'slidetrans_free') then Exit;

  try
    Effect := TSlideTransitionEffect(Args[0].p);
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'slidetrans_free: ' + E.Message);
  end;
end;

// =============================================================================
// Progress Property (0-100 percentage)
// User passes 0.0-1.0 (normalized), we convert to 0-100 for FireMonkey
// =============================================================================

function p_slidetrans_progress_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'slidetrans_progress#') then Exit;

  try
    Value := Args[1].n;
    //The documented range is 0 to 1; FireMonkey's property is 0 to 100.
    //This used to multiply by 100 only when the value was at most 1, so
    //progress#(e, 1) meant 100% and progress#(e, 2) meant 2%.
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    Value := Value * 100;
    
    TSlideTransitionEffect(Args[0].p).Progress := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'slidetrans_progress#: ' + E.Message);
  end;
end;

function n_slidetrans_progress_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'slidetrans_progress') then Exit;

  try
    // Return normalized value (0-1) to user
    Result.n := TSlideTransitionEffect(Args[0].p).Progress / 100;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'slidetrans_progress: ' + E.Message);
  end;
end;

// =============================================================================
// SlideAmountX Property
// =============================================================================

function p_slidetrans_amountx_set(var Args: array of TAsmData): TAsmData;
var
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'slidetrans_amountx#') then Exit;

  try
    Pt := TSlideTransitionEffect(Args[0].p).SlideAmount;
    Pt.X := Args[1].n;
    TSlideTransitionEffect(Args[0].p).SlideAmount := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'slidetrans_amountx#: ' + E.Message);
  end;
end;

function n_slidetrans_amountx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'slidetrans_amountx') then Exit;

  try
    Result.n := TSlideTransitionEffect(Args[0].p).SlideAmount.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'slidetrans_amountx: ' + E.Message);
  end;
end;

// =============================================================================
// SlideAmountY Property
// =============================================================================

function p_slidetrans_amounty_set(var Args: array of TAsmData): TAsmData;
var
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'slidetrans_amounty#') then Exit;

  try
    Pt := TSlideTransitionEffect(Args[0].p).SlideAmount;
    Pt.Y := Args[1].n;
    TSlideTransitionEffect(Args[0].p).SlideAmount := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'slidetrans_amounty#: ' + E.Message);
  end;
end;

function n_slidetrans_amounty_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'slidetrans_amounty') then Exit;

  try
    Result.n := TSlideTransitionEffect(Args[0].p).SlideAmount.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'slidetrans_amounty: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_slidetrans_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'slidetrans_enabled#') then Exit;

  try
    TSlideTransitionEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'slidetrans_enabled#: ' + E.Message);
  end;
end;

function n_slidetrans_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'slidetrans_enabled') then Exit;

  try
    if TSlideTransitionEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'slidetrans_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_slidetrans_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'slidetrans_trigger#') then Exit;

  try
    TSlideTransitionEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'slidetrans_trigger#: ' + E.Message);
  end;
end;

function s_slidetrans_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'slidetrans_trigger$') then Exit;

  try
    Result.s := TSlideTransitionEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'slidetrans_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterSlideTransitionEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_slidetrans_error; Lib.Add('slidetrans_error@', Fn);
  Fn.Entry := @s_slidetrans_errormsg; Lib.Add('slidetrans_errormsg$@', Fn);
  Fn.Entry := @s_slidetrans_strerror; Lib.Add('slidetrans_strerror$@n', Fn);
  Fn.Entry := @n_slidetrans_clearerror; Lib.Add('slidetrans_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_slidetrans_new; Lib.Add('slidetrans#@#', Fn);
  Fn.Entry := @n_slidetrans_free; Lib.Add('slidetrans_free@#', Fn);

  // Progress property
  Fn.Entry := @p_slidetrans_progress_set; Lib.Add('slidetrans_progress#@#n', Fn);
  Fn.Entry := @n_slidetrans_progress_get; Lib.Add('slidetrans_progress@#', Fn);

  // SlideAmountX property
  Fn.Entry := @p_slidetrans_amountx_set; Lib.Add('slidetrans_amountx#@#n', Fn);
  Fn.Entry := @n_slidetrans_amountx_get; Lib.Add('slidetrans_amountx@#', Fn);

  // SlideAmountY property
  Fn.Entry := @p_slidetrans_amounty_set; Lib.Add('slidetrans_amounty#@#n', Fn);
  Fn.Entry := @n_slidetrans_amounty_get; Lib.Add('slidetrans_amounty@#', Fn);

  // Enabled property
  Fn.Entry := @p_slidetrans_enabled_set; Lib.Add('slidetrans_enabled#@#n', Fn);
  Fn.Entry := @n_slidetrans_enabled_get; Lib.Add('slidetrans_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_slidetrans_trigger_set; Lib.Add('slidetrans_trigger#@#$', Fn);
  Fn.Entry := @s_slidetrans_trigger_get; Lib.Add('slidetrans_trigger$@#', Fn);
end;

end.
