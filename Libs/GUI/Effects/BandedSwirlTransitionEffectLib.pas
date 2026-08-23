unit BandedSwirlTransitionEffectLib;

{******************************************************************************
  BandedSwirlTransitionEffectLib - Banded Swirl Transition Effect for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TBandedSwirlTransitionEffect wrapper for creating
  swirling band transitions between two images.

  Function Count: 22 functions

  PROPERTIES:
  ===========
  - Progress: Transition progress (0.0-1.0, internally 0-100)
  - Target: Bitmap to transition TO
  - Strength: Swirl strength (default 0.5)
  - Frequency: Number of swirl bands (default 20)
  - Center: Center point of the swirl effect
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  Copyright (c) 2024-2026 André Murta
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  FMX.Graphics, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, EffectCommon, GuiUtils;

procedure RegisterBandedSwirlTransitionEffectFuncs(Lib: TFunctionsDictionary);

implementation

var
  //One error slot for this library, shared shape in EffectCommon.
  Err: TEffectErrors;

const
  ERR_LOAD_FAILED = 6;
  ERR_NIL_BITMAP = 7;

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
  Result := EffectCommon.ValidateEffect(P, TBandedSwirlTransitionEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling
// =============================================================================

function n_bandedswirltr_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_bandedswirltr_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_bandedswirltr_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_NIL_EFFECT: Result.s := 'Effect is nil';
    ERR_INVALID_EFFECT: Result.s := 'Invalid effect type';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_NIL_PARENT: Result.s := 'Parent is nil';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent type';
    ERR_LOAD_FAILED: Result.s := 'Failed to load image';
    ERR_NIL_BITMAP: Result.s := 'Bitmap is nil';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_bandedswirltr_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_bandedswirltr_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandedSwirlTransitionEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'bandedswirltr#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TBandedSwirlTransitionEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    // GC registration removed - parent ownership handles cleanup
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    // GC.Add(Effect, IntToStr(NativeInt(Effect)));
    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bandedswirltr#: ' + E.Message);
  end;
end;

function n_bandedswirltr_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandedSwirlTransitionEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_free') then Exit;

  try
    Effect := TBandedSwirlTransitionEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bandedswirltr_free: ' + E.Message);
  end;
end;

// =============================================================================
// Progress Property (0-1 normalized, internally 0-100)
// =============================================================================

function p_bandedswirltr_progress_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_progress#') then Exit;

  try
    Value := Args[1].n;
    //The documented range is 0 to 1; FireMonkey's property is 0 to 100.
    //This used to multiply by 100 only when the value was at most 1, so
    //progress#(e, 1) meant 100% and progress#(e, 2) meant 2%.
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    Value := Value * 100;
    TBandedSwirlTransitionEffect(Args[0].p).Progress := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bandedswirltr_progress#: ' + E.Message);
  end;
end;

function n_bandedswirltr_progress_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_progress') then Exit;

  try
    // Return normalized 0-1 to user
    Result.n := TBandedSwirlTransitionEffect(Args[0].p).Progress / 100;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bandedswirltr_progress: ' + E.Message);
  end;
end;

// =============================================================================
// Target Property
// =============================================================================

function p_bandedswirltr_target_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandedSwirlTransitionEffect;
  SourceBitmap: TBitmap;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_target#') then Exit;

  try
    Effect := TBandedSwirlTransitionEffect(Args[0].p);
    if Args[1].p = nil then
    begin
      SetError(ERR_NIL_BITMAP, 'bandedswirltr_target#: bitmap is nil');
      Exit;
    end;
    SourceBitmap := TBitmap(Args[1].p);
    Effect.Target.Assign(SourceBitmap);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bandedswirltr_target#: ' + E.Message);
  end;
end;

function p_bandedswirltr_target_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_target#') then Exit;

  try
    Result.p := TBandedSwirlTransitionEffect(Args[0].p).Target;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bandedswirltr_target#: ' + E.Message);
  end;
end;

function p_bandedswirltr_loadtarget(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandedSwirlTransitionEffect;
  Path: String;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_loadtarget#') then Exit;

  try
    Effect := TBandedSwirlTransitionEffect(Args[0].p);
    Path := Args[1].s;

    if (Pos('http://', LowerCase(Path)) = 1) or (Pos('https://', LowerCase(Path)) = 1) then
    begin
      if not TGuiUtils.LoadImageFromWeb(Path, Effect.Target) then
      begin
        SetError(ERR_LOAD_FAILED, 'bandedswirltr_loadtarget#: failed to load from URL');
        Exit;
      end;
    end
    else
    begin
      if FileExists(Path) then
        Effect.Target.LoadFromFile(Path)
      else
      begin
        SetError(ERR_LOAD_FAILED, 'bandedswirltr_loadtarget#: file not found');
        Exit;
      end;
    end;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_LOAD_FAILED, 'bandedswirltr_loadtarget#: ' + E.Message);
  end;
end;

// =============================================================================
// Strength Property
// =============================================================================

function p_bandedswirltr_strength_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_strength#') then Exit;

  try
    TBandedSwirlTransitionEffect(Args[0].p).Strength := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bandedswirltr_strength#: ' + E.Message);
  end;
end;

function n_bandedswirltr_strength_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_strength') then Exit;

  try
    Result.n := TBandedSwirlTransitionEffect(Args[0].p).Strength;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bandedswirltr_strength: ' + E.Message);
  end;
end;

// =============================================================================
// Frequency Property
// =============================================================================

function p_bandedswirltr_frequency_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_frequency#') then Exit;

  try
    TBandedSwirlTransitionEffect(Args[0].p).Frequency := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bandedswirltr_frequency#: ' + E.Message);
  end;
end;

function n_bandedswirltr_frequency_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_frequency') then Exit;

  try
    Result.n := TBandedSwirlTransitionEffect(Args[0].p).Frequency;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bandedswirltr_frequency: ' + E.Message);
  end;
end;

// =============================================================================
// Center Property
// =============================================================================

function p_bandedswirltr_centerx_set(var Args: array of TAsmData): TAsmData;
var
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_centerx#') then Exit;

  try
    Pt := TBandedSwirlTransitionEffect(Args[0].p).Center;
    Pt.X := Args[1].n;
    TBandedSwirlTransitionEffect(Args[0].p).Center := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bandedswirltr_centerx#: ' + E.Message);
  end;
end;

function n_bandedswirltr_centerx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_centerx') then Exit;

  try
    Result.n := TBandedSwirlTransitionEffect(Args[0].p).Center.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bandedswirltr_centerx: ' + E.Message);
  end;
end;

function p_bandedswirltr_centery_set(var Args: array of TAsmData): TAsmData;
var
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_centery#') then Exit;

  try
    Pt := TBandedSwirlTransitionEffect(Args[0].p).Center;
    Pt.Y := Args[1].n;
    TBandedSwirlTransitionEffect(Args[0].p).Center := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bandedswirltr_centery#: ' + E.Message);
  end;
end;

function n_bandedswirltr_centery_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_centery') then Exit;

  try
    Result.n := TBandedSwirlTransitionEffect(Args[0].p).Center.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bandedswirltr_centery: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_bandedswirltr_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_enabled#') then Exit;

  try
    TBandedSwirlTransitionEffect(Args[0].p).Enabled := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bandedswirltr_enabled#: ' + E.Message);
  end;
end;

function n_bandedswirltr_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bandedswirltr_enabled') then Exit;

  try
    if TBandedSwirlTransitionEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bandedswirltr_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterBandedSwirlTransitionEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_bandedswirltr_error; Lib.Add('bandedswirltr_error@', Fn);
  Fn.Entry := @s_bandedswirltr_errormsg; Lib.Add('bandedswirltr_errormsg$@', Fn);
  Fn.Entry := @s_bandedswirltr_strerror; Lib.Add('bandedswirltr_strerror$@n', Fn);
  Fn.Entry := @n_bandedswirltr_clearerror; Lib.Add('bandedswirltr_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_bandedswirltr_new; Lib.Add('bandedswirltr#@#', Fn);
  Fn.Entry := @n_bandedswirltr_free; Lib.Add('bandedswirltr_free@#', Fn);

  // Progress property
  Fn.Entry := @p_bandedswirltr_progress_set; Lib.Add('bandedswirltr_progress#@#n', Fn);
  Fn.Entry := @n_bandedswirltr_progress_get; Lib.Add('bandedswirltr_progress@#', Fn);

  // Target property
  Fn.Entry := @p_bandedswirltr_target_set; Lib.Add('bandedswirltr_target#@##', Fn);
  Fn.Entry := @p_bandedswirltr_target_get; Lib.Add('bandedswirltr_target#@#', Fn);
  Fn.Entry := @p_bandedswirltr_loadtarget; Lib.Add('bandedswirltr_loadtarget#@#$', Fn);

  // Strength property
  Fn.Entry := @p_bandedswirltr_strength_set; Lib.Add('bandedswirltr_strength#@#n', Fn);
  Fn.Entry := @n_bandedswirltr_strength_get; Lib.Add('bandedswirltr_strength@#', Fn);

  // Frequency property
  Fn.Entry := @p_bandedswirltr_frequency_set; Lib.Add('bandedswirltr_frequency#@#n', Fn);
  Fn.Entry := @n_bandedswirltr_frequency_get; Lib.Add('bandedswirltr_frequency@#', Fn);

  // Center property
  Fn.Entry := @p_bandedswirltr_centerx_set; Lib.Add('bandedswirltr_centerx#@#n', Fn);
  Fn.Entry := @n_bandedswirltr_centerx_get; Lib.Add('bandedswirltr_centerx@#', Fn);
  Fn.Entry := @p_bandedswirltr_centery_set; Lib.Add('bandedswirltr_centery#@#n', Fn);
  Fn.Entry := @n_bandedswirltr_centery_get; Lib.Add('bandedswirltr_centery@#', Fn);

  // Enabled property
  Fn.Entry := @p_bandedswirltr_enabled_set; Lib.Add('bandedswirltr_enabled#@#n', Fn);
  Fn.Entry := @n_bandedswirltr_enabled_get; Lib.Add('bandedswirltr_enabled@#', Fn);
end;

end.

