unit CropEffectLib;

{******************************************************************************
  CropEffectLib - Crop Effect Library for Plan9Basic
  Version: 1.0.1

  Provides FireMonkey TCropEffect wrapper for cropping a rectangular area
  from visual controls.

  Function Count: 16 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PROPERTIES:
  ===========
  - LeftTopX: Left edge of crop rectangle (pixels, default 0)
  - LeftTopY: Top edge of crop rectangle (pixels, default 0)
  - RightBottomX: Right edge of crop rectangle (pixels, default 150)
  - RightBottomY: Bottom edge of crop rectangle (pixels, default 150)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  USAGE:
  ======
  Crop effect shows only the specified rectangle area from the image.
  Coordinates are in PIXELS relative to the image texture.
  (0,0) = top-left corner of the image.
  The cropped area is repositioned to the upper-left corner and scaled
  to fit the control boundaries.

  NOTE: This effect only works with bitmap/texture content (TImage).
  It does NOT work with vector shapes (TRectangle, TCircle, etc.).

  MEMORY MANAGEMENT:
  ==================
  GC registration removed - parent ownership handles cleanup.
  Using GC caused Access Violations due to double-free when parent
  controls were destroyed.

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterCropEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TCropEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_crop_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_crop_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_crop_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_crop_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_crop_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TCropEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'crop#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TCropEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    // FireMonkey default values: LeftTop=(0,0), RightBottom=(150,150)
    // We use the default values - no need to set them explicitly

    // GC registration removed - parent ownership handles cleanup
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    // UnitGC.GC.Add<TCropEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'crop#: ' + E.Message);
  end;
end;

function n_crop_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TCropEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'crop_free') then Exit;

  try
    Effect := TCropEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'crop_free: ' + E.Message);
  end;
end;

// =============================================================================
// LeftTop Corner (pixel coordinates)
// =============================================================================

function p_crop_lefttopx_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TCropEffect;
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'crop_lefttopx#') then Exit;

  try
    Effect := TCropEffect(Args[0].p);
    Value := Args[1].n;
    // Only validate non-negative - pixel coordinates have no upper limit
    if Value < 0 then Value := 0;
    Effect.LeftTop := PointF(Value, Effect.LeftTop.Y);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'crop_lefttopx#: ' + E.Message);
  end;
end;

function n_crop_lefttopx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'crop_lefttopx') then Exit;

  try
    Result.n := TCropEffect(Args[0].p).LeftTop.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'crop_lefttopx: ' + E.Message);
  end;
end;

function p_crop_lefttopy_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TCropEffect;
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'crop_lefttopy#') then Exit;

  try
    Effect := TCropEffect(Args[0].p);
    Value := Args[1].n;
    // Only validate non-negative - pixel coordinates have no upper limit
    if Value < 0 then Value := 0;
    Effect.LeftTop := PointF(Effect.LeftTop.X, Value);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'crop_lefttopy#: ' + E.Message);
  end;
end;

function n_crop_lefttopy_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'crop_lefttopy') then Exit;

  try
    Result.n := TCropEffect(Args[0].p).LeftTop.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'crop_lefttopy: ' + E.Message);
  end;
end;

// =============================================================================
// RightBottom Corner (pixel coordinates)
// =============================================================================

function p_crop_rightbottomx_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TCropEffect;
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'crop_rightbottomx#') then Exit;

  try
    Effect := TCropEffect(Args[0].p);
    Value := Args[1].n;
    // Only validate non-negative - pixel coordinates have no upper limit
    if Value < 0 then Value := 0;
    Effect.RightBottom := PointF(Value, Effect.RightBottom.Y);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'crop_rightbottomx#: ' + E.Message);
  end;
end;

function n_crop_rightbottomx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'crop_rightbottomx') then Exit;

  try
    Result.n := TCropEffect(Args[0].p).RightBottom.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'crop_rightbottomx: ' + E.Message);
  end;
end;

function p_crop_rightbottomy_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TCropEffect;
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'crop_rightbottomy#') then Exit;

  try
    Effect := TCropEffect(Args[0].p);
    Value := Args[1].n;
    // Only validate non-negative - pixel coordinates have no upper limit
    if Value < 0 then Value := 0;
    Effect.RightBottom := PointF(Effect.RightBottom.X, Value);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'crop_rightbottomy#: ' + E.Message);
  end;
end;

function n_crop_rightbottomy_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'crop_rightbottomy') then Exit;

  try
    Result.n := TCropEffect(Args[0].p).RightBottom.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'crop_rightbottomy: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_crop_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'crop_enabled#') then Exit;

  try
    TCropEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'crop_enabled#: ' + E.Message);
  end;
end;

function n_crop_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'crop_enabled') then Exit;

  try
    if TCropEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'crop_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_crop_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'crop_trigger#') then Exit;

  try
    TCropEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'crop_trigger#: ' + E.Message);
  end;
end;

function s_crop_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'crop_trigger$') then Exit;

  try
    Result.s := TCropEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'crop_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterCropEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_crop_error; Lib.Add('crop_error@', Fn);
  Fn.Entry := @s_crop_errormsg; Lib.Add('crop_errormsg$@', Fn);
  Fn.Entry := @s_crop_strerror; Lib.Add('crop_strerror$@n', Fn);
  Fn.Entry := @n_crop_clearerror; Lib.Add('crop_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_crop_new; Lib.Add('crop#@#', Fn);
  Fn.Entry := @n_crop_free; Lib.Add('crop_free@#', Fn);

  // LeftTop corner (pixel coordinates)
  Fn.Entry := @p_crop_lefttopx_set; Lib.Add('crop_lefttopx#@#n', Fn);
  Fn.Entry := @n_crop_lefttopx_get; Lib.Add('crop_lefttopx@#', Fn);
  Fn.Entry := @p_crop_lefttopy_set; Lib.Add('crop_lefttopy#@#n', Fn);
  Fn.Entry := @n_crop_lefttopy_get; Lib.Add('crop_lefttopy@#', Fn);

  // RightBottom corner (pixel coordinates)
  Fn.Entry := @p_crop_rightbottomx_set; Lib.Add('crop_rightbottomx#@#n', Fn);
  Fn.Entry := @n_crop_rightbottomx_get; Lib.Add('crop_rightbottomx@#', Fn);
  Fn.Entry := @p_crop_rightbottomy_set; Lib.Add('crop_rightbottomy#@#n', Fn);
  Fn.Entry := @n_crop_rightbottomy_get; Lib.Add('crop_rightbottomy@#', Fn);

  // Enabled property
  Fn.Entry := @p_crop_enabled_set; Lib.Add('crop_enabled#@#n', Fn);
  Fn.Entry := @n_crop_enabled_get; Lib.Add('crop_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_crop_trigger_set; Lib.Add('crop_trigger#@#$', Fn);
  Fn.Entry := @s_crop_trigger_get; Lib.Add('crop_trigger$@#', Fn);
end;

end.

