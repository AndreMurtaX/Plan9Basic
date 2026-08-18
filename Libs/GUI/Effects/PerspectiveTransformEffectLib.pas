unit PerspectiveTransformEffectLib;

{******************************************************************************
  PerspectiveTransformEffectLib - Perspective Transform Effect for Plan9Basic
  Version: 1.0.1 - Fixed: removed incorrect 0-1 corner init (uses pixels)

  Provides FireMonkey TPerspectiveTransformEffect wrapper for applying 3D
  perspective transformations to visual controls by setting four corner points.

  Function Count: 24 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PROPERTIES:
  ===========
  - TopLeftX/Y: Top-left corner position (pixels)
  - TopRightX/Y: Top-right corner position (pixels)
  - BottomRightX/Y: Bottom-right corner position (pixels)
  - BottomLeftX/Y: Bottom-left corner position (pixels)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  USAGE:
  ======
  Perspective transform warps an image by repositioning its four corners.
  Great for creating 3D effects, card flips, and perspective distortions.
  Coordinates are in PIXELS. Set corners to match your image dimensions.

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry;

procedure RegisterPerspectiveTransformEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, TPerspectiveTransformEffect)) then
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

function n_persp_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_persp_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_persp_strerror(var Args: array of TAsmData): TAsmData;
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

function n_persp_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_persp_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TPerspectiveTransformEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'persp#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TPerspectiveTransformEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    // Effect.TopLeft := PointF(0, 0); // Commented - uses pixels not 0-1
    // Effect.TopRight := PointF(1, 0);
    // Effect.BottomRight := PointF(1, 1);
    // Effect.BottomLeft := PointF(0, 1);

    // GC.Add removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TPerspectiveTransformEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'persp#: ' + E.Message);
  end;
end;

function n_persp_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TPerspectiveTransformEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_free') then Exit;

  try
    Effect := TPerspectiveTransformEffect(Args[0].p);
    // GC.Collect removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'persp_free: ' + E.Message);
  end;
end;

// =============================================================================
// TopLeft Corner
// =============================================================================

function p_persp_topleftx_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TPerspectiveTransformEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_topleftx#') then Exit;

  try
    Effect := TPerspectiveTransformEffect(Args[0].p);
    Effect.TopLeft := PointF(Args[1].n, Effect.TopLeft.Y);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'persp_topleftx#: ' + E.Message);
  end;
end;

function n_persp_topleftx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_topleftx') then Exit;

  try
    Result.n := TPerspectiveTransformEffect(Args[0].p).TopLeft.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'persp_topleftx: ' + E.Message);
  end;
end;

function p_persp_toplefty_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TPerspectiveTransformEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_toplefty#') then Exit;

  try
    Effect := TPerspectiveTransformEffect(Args[0].p);
    Effect.TopLeft := PointF(Effect.TopLeft.X, Args[1].n);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'persp_toplefty#: ' + E.Message);
  end;
end;

function n_persp_toplefty_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_toplefty') then Exit;

  try
    Result.n := TPerspectiveTransformEffect(Args[0].p).TopLeft.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'persp_toplefty: ' + E.Message);
  end;
end;

// =============================================================================
// TopRight Corner
// =============================================================================

function p_persp_toprightx_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TPerspectiveTransformEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_toprightx#') then Exit;

  try
    Effect := TPerspectiveTransformEffect(Args[0].p);
    Effect.TopRight := PointF(Args[1].n, Effect.TopRight.Y);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'persp_toprightx#: ' + E.Message);
  end;
end;

function n_persp_toprightx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_toprightx') then Exit;

  try
    Result.n := TPerspectiveTransformEffect(Args[0].p).TopRight.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'persp_toprightx: ' + E.Message);
  end;
end;

function p_persp_toprighty_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TPerspectiveTransformEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_toprighty#') then Exit;

  try
    Effect := TPerspectiveTransformEffect(Args[0].p);
    Effect.TopRight := PointF(Effect.TopRight.X, Args[1].n);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'persp_toprighty#: ' + E.Message);
  end;
end;

function n_persp_toprighty_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_toprighty') then Exit;

  try
    Result.n := TPerspectiveTransformEffect(Args[0].p).TopRight.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'persp_toprighty: ' + E.Message);
  end;
end;

// =============================================================================
// BottomRight Corner
// =============================================================================

function p_persp_bottomrightx_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TPerspectiveTransformEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_bottomrightx#') then Exit;

  try
    Effect := TPerspectiveTransformEffect(Args[0].p);
    Effect.BottomRight := PointF(Args[1].n, Effect.BottomRight.Y);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'persp_bottomrightx#: ' + E.Message);
  end;
end;

function n_persp_bottomrightx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_bottomrightx') then Exit;

  try
    Result.n := TPerspectiveTransformEffect(Args[0].p).BottomRight.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'persp_bottomrightx: ' + E.Message);
  end;
end;

function p_persp_bottomrighty_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TPerspectiveTransformEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_bottomrighty#') then Exit;

  try
    Effect := TPerspectiveTransformEffect(Args[0].p);
    Effect.BottomRight := PointF(Effect.BottomRight.X, Args[1].n);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'persp_bottomrighty#: ' + E.Message);
  end;
end;

function n_persp_bottomrighty_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_bottomrighty') then Exit;

  try
    Result.n := TPerspectiveTransformEffect(Args[0].p).BottomRight.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'persp_bottomrighty: ' + E.Message);
  end;
end;

// =============================================================================
// BottomLeft Corner
// =============================================================================

function p_persp_bottomleftx_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TPerspectiveTransformEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_bottomleftx#') then Exit;

  try
    Effect := TPerspectiveTransformEffect(Args[0].p);
    Effect.BottomLeft := PointF(Args[1].n, Effect.BottomLeft.Y);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'persp_bottomleftx#: ' + E.Message);
  end;
end;

function n_persp_bottomleftx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_bottomleftx') then Exit;

  try
    Result.n := TPerspectiveTransformEffect(Args[0].p).BottomLeft.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'persp_bottomleftx: ' + E.Message);
  end;
end;

function p_persp_bottomlefty_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TPerspectiveTransformEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_bottomlefty#') then Exit;

  try
    Effect := TPerspectiveTransformEffect(Args[0].p);
    Effect.BottomLeft := PointF(Effect.BottomLeft.X, Args[1].n);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'persp_bottomlefty#: ' + E.Message);
  end;
end;

function n_persp_bottomlefty_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_bottomlefty') then Exit;

  try
    Result.n := TPerspectiveTransformEffect(Args[0].p).BottomLeft.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'persp_bottomlefty: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_persp_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_enabled#') then Exit;

  try
    TPerspectiveTransformEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'persp_enabled#: ' + E.Message);
  end;
end;

function n_persp_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_enabled') then Exit;

  try
    if TPerspectiveTransformEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'persp_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_persp_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_trigger#') then Exit;

  try
    TPerspectiveTransformEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'persp_trigger#: ' + E.Message);
  end;
end;

function s_persp_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'persp_trigger$') then Exit;

  try
    Result.s := TPerspectiveTransformEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'persp_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterPerspectiveTransformEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_persp_error; Lib.Add('persp_error@', Fn);
  Fn.Entry := @s_persp_errormsg; Lib.Add('persp_errormsg$@', Fn);
  Fn.Entry := @s_persp_strerror; Lib.Add('persp_strerror$@n', Fn);
  Fn.Entry := @n_persp_clearerror; Lib.Add('persp_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_persp_new; Lib.Add('persp#@#', Fn);
  Fn.Entry := @n_persp_free; Lib.Add('persp_free@#', Fn);

  // TopLeft corner
  Fn.Entry := @p_persp_topleftx_set; Lib.Add('persp_topleftx#@#n', Fn);
  Fn.Entry := @n_persp_topleftx_get; Lib.Add('persp_topleftx@#', Fn);
  Fn.Entry := @p_persp_toplefty_set; Lib.Add('persp_toplefty#@#n', Fn);
  Fn.Entry := @n_persp_toplefty_get; Lib.Add('persp_toplefty@#', Fn);

  // TopRight corner
  Fn.Entry := @p_persp_toprightx_set; Lib.Add('persp_toprightx#@#n', Fn);
  Fn.Entry := @n_persp_toprightx_get; Lib.Add('persp_toprightx@#', Fn);
  Fn.Entry := @p_persp_toprighty_set; Lib.Add('persp_toprighty#@#n', Fn);
  Fn.Entry := @n_persp_toprighty_get; Lib.Add('persp_toprighty@#', Fn);

  // BottomRight corner
  Fn.Entry := @p_persp_bottomrightx_set; Lib.Add('persp_bottomrightx#@#n', Fn);
  Fn.Entry := @n_persp_bottomrightx_get; Lib.Add('persp_bottomrightx@#', Fn);
  Fn.Entry := @p_persp_bottomrighty_set; Lib.Add('persp_bottomrighty#@#n', Fn);
  Fn.Entry := @n_persp_bottomrighty_get; Lib.Add('persp_bottomrighty@#', Fn);

  // BottomLeft corner
  Fn.Entry := @p_persp_bottomleftx_set; Lib.Add('persp_bottomleftx#@#n', Fn);
  Fn.Entry := @n_persp_bottomleftx_get; Lib.Add('persp_bottomleftx@#', Fn);
  Fn.Entry := @p_persp_bottomlefty_set; Lib.Add('persp_bottomlefty#@#n', Fn);
  Fn.Entry := @n_persp_bottomlefty_get; Lib.Add('persp_bottomlefty@#', Fn);

  // Enabled property
  Fn.Entry := @p_persp_enabled_set; Lib.Add('persp_enabled#@#n', Fn);
  Fn.Entry := @n_persp_enabled_get; Lib.Add('persp_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_persp_trigger_set; Lib.Add('persp_trigger#@#$', Fn);
  Fn.Entry := @s_persp_trigger_get; Lib.Add('persp_trigger$@#', Fn);
end;

end.

