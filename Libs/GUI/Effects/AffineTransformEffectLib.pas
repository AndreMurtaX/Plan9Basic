unit AffineTransformEffectLib;

{******************************************************************************
  AffineTransformEffectLib - Affine Transform Effect Library for Plan9Basic
  Version: 1.0.0

  Properties:
  - Center: TPointF (CenterX, CenterY)
  - Scale: Single (uniform scale factor)
  - Rotation: Single (degrees)

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterAffineTransformEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TAffineTransformEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_affine_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_affine_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_affine_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_affine_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_affine_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TAffineTransformEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'affine#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TAffineTransformEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Rotation := 0;
    Effect.Center := TPointF.Create(0.5, 0.5);
    Effect.Scale := 1.0;

    // GC registration removed - parent ownership handles cleanup
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    // UnitGC.GC.Add<TAffineTransformEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'affine#: ' + E.Message);
  end;
end;

function n_affine_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TAffineTransformEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'affine_free') then Exit;

  try
    Effect := TAffineTransformEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'affine_free: ' + E.Message);
  end;
end;

// =============================================================================
// CenterX Property
// =============================================================================

function p_affine_centerx_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TAffineTransformEffect;
  Value, CurY: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'affine_centerx#') then Exit;

  try
    Effect := TAffineTransformEffect(Args[0].p);
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    CurY := Effect.Center.Y;
    Effect.Center := TPointF.Create(Value, CurY);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'affine_centerx#: ' + E.Message);
  end;
end;

function n_affine_centerx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'affine_centerx') then Exit;

  try
    Result.n := TAffineTransformEffect(Args[0].p).Center.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'affine_centerx: ' + E.Message);
  end;
end;

// =============================================================================
// CenterY Property
// =============================================================================

function p_affine_centery_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TAffineTransformEffect;
  Value, CurX: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'affine_centery#') then Exit;

  try
    Effect := TAffineTransformEffect(Args[0].p);
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    CurX := Effect.Center.X;
    Effect.Center := TPointF.Create(CurX, Value);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'affine_centery#: ' + E.Message);
  end;
end;

function n_affine_centery_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'affine_centery') then Exit;

  try
    Result.n := TAffineTransformEffect(Args[0].p).Center.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'affine_centery: ' + E.Message);
  end;
end;

// =============================================================================
// Rotation Property (degrees)
// =============================================================================

function p_affine_rotation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'affine_rotation#') then Exit;

  try
    TAffineTransformEffect(Args[0].p).Rotation := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'affine_rotation#: ' + E.Message);
  end;
end;

function n_affine_rotation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'affine_rotation') then Exit;

  try
    Result.n := TAffineTransformEffect(Args[0].p).Rotation;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'affine_rotation: ' + E.Message);
  end;
end;

// =============================================================================
// Scale Property (Single - uniform scale)
// =============================================================================

function p_affine_scale_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'affine_scale#') then Exit;

  try
    TAffineTransformEffect(Args[0].p).Scale := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'affine_scale#: ' + E.Message);
  end;
end;

function n_affine_scale_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'affine_scale') then Exit;

  try
    Result.n := TAffineTransformEffect(Args[0].p).Scale;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'affine_scale: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_affine_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'affine_enabled#') then Exit;

  try
    TAffineTransformEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'affine_enabled#: ' + E.Message);
  end;
end;

function n_affine_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'affine_enabled') then Exit;

  try
    if TAffineTransformEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'affine_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_affine_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'affine_trigger#') then Exit;

  try
    TAffineTransformEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'affine_trigger#: ' + E.Message);
  end;
end;

function s_affine_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'affine_trigger$') then Exit;

  try
    Result.s := TAffineTransformEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'affine_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration (18 functions)
// =============================================================================

procedure RegisterAffineTransformEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_affine_error; Lib.Add('affine_error@', Fn);
  Fn.Entry := @s_affine_errormsg; Lib.Add('affine_errormsg$@', Fn);
  Fn.Entry := @s_affine_strerror; Lib.Add('affine_strerror$@n', Fn);
  Fn.Entry := @n_affine_clearerror; Lib.Add('affine_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_affine_new; Lib.Add('affine#@#', Fn);
  Fn.Entry := @n_affine_free; Lib.Add('affine_free@#', Fn);

  // CenterX property
  Fn.Entry := @p_affine_centerx_set; Lib.Add('affine_centerx#@#n', Fn);
  Fn.Entry := @n_affine_centerx_get; Lib.Add('affine_centerx@#', Fn);

  // CenterY property
  Fn.Entry := @p_affine_centery_set; Lib.Add('affine_centery#@#n', Fn);
  Fn.Entry := @n_affine_centery_get; Lib.Add('affine_centery@#', Fn);

  // Rotation property
  Fn.Entry := @p_affine_rotation_set; Lib.Add('affine_rotation#@#n', Fn);
  Fn.Entry := @n_affine_rotation_get; Lib.Add('affine_rotation@#', Fn);

  // Scale property (uniform)
  Fn.Entry := @p_affine_scale_set; Lib.Add('affine_scale#@#n', Fn);
  Fn.Entry := @n_affine_scale_get; Lib.Add('affine_scale@#', Fn);

  // Enabled property
  Fn.Entry := @p_affine_enabled_set; Lib.Add('affine_enabled#@#n', Fn);
  Fn.Entry := @n_affine_enabled_get; Lib.Add('affine_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_affine_trigger_set; Lib.Add('affine_trigger#@#$', Fn);
  Fn.Entry := @s_affine_trigger_get; Lib.Add('affine_trigger$@#', Fn);
end;

end.

