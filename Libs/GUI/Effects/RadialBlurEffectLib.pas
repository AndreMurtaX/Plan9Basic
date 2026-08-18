unit RadialBlurEffectLib;

{******************************************************************************
  RadialBlurEffectLib - Radial Blur Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TRadialBlurEffect wrapper for applying zoom/spin
  blur effects radiating from a center point.

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
  - BlurAmount: Blur intensity (0 to 100, default 10)
  - CenterX: Horizontal center point (0.0 to 1.0, default 0.5)
  - CenterY: Vertical center point (0.0 to 1.0, default 0.5)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  CENTER POINT REFERENCE:
  =======================
  - (0.0, 0.0): Top-left corner
  - (0.5, 0.5): Center of control
  - (1.0, 1.0): Bottom-right corner

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry;

procedure RegisterRadialBlurEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, TRadialBlurEffect)) then
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

function n_radblur_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_radblur_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_radblur_strerror(var Args: array of TAsmData): TAsmData;
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

function n_radblur_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_radblur_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TRadialBlurEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'radblur#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TRadialBlurEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.BlurAmount := 10;
    Effect.Center := PointF(0.5, 0.5);

    // GC.Add removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TRadialBlurEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Torna este efeito um handle validavel sem dereferenciar o
    //ponteiro que o programa BASIC devolver. A baixa e automatica:
    //o efeito pertence ao pai, e o registry escuta FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'radblur#: ' + E.Message);
  end;
end;

function n_radblur_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TRadialBlurEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'radblur_free') then Exit;

  try
    Effect := TRadialBlurEffect(Args[0].p);
    // GC.Collect removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'radblur_free: ' + E.Message);
  end;
end;

// =============================================================================
// BlurAmount Property (0 - 100)
// =============================================================================

function p_radblur_bluramount_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'radblur_bluramount#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 100 then Value := 100;
    TRadialBlurEffect(Args[0].p).BlurAmount := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'radblur_bluramount#: ' + E.Message);
  end;
end;

function n_radblur_bluramount_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'radblur_bluramount') then Exit;

  try
    Result.n := TRadialBlurEffect(Args[0].p).BlurAmount;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'radblur_bluramount: ' + E.Message);
  end;
end;

// =============================================================================
// CenterX Property (0.0 - 1.0)
// =============================================================================

function p_radblur_centerx_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'radblur_centerx#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    Pt := TRadialBlurEffect(Args[0].p).Center;
    Pt.X := Value;
    TRadialBlurEffect(Args[0].p).Center := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'radblur_centerx#: ' + E.Message);
  end;
end;

function n_radblur_centerx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'radblur_centerx') then Exit;

  try
    Result.n := TRadialBlurEffect(Args[0].p).Center.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'radblur_centerx: ' + E.Message);
  end;
end;

// =============================================================================
// CenterY Property (0.0 - 1.0)
// =============================================================================

function p_radblur_centery_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'radblur_centery#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    Pt := TRadialBlurEffect(Args[0].p).Center;
    Pt.Y := Value;
    TRadialBlurEffect(Args[0].p).Center := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'radblur_centery#: ' + E.Message);
  end;
end;

function n_radblur_centery_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'radblur_centery') then Exit;

  try
    Result.n := TRadialBlurEffect(Args[0].p).Center.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'radblur_centery: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_radblur_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'radblur_enabled#') then Exit;

  try
    TRadialBlurEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'radblur_enabled#: ' + E.Message);
  end;
end;

function n_radblur_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'radblur_enabled') then Exit;

  try
    if TRadialBlurEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'radblur_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_radblur_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'radblur_trigger#') then Exit;

  try
    TRadialBlurEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'radblur_trigger#: ' + E.Message);
  end;
end;

function s_radblur_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'radblur_trigger$') then Exit;

  try
    Result.s := TRadialBlurEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'radblur_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterRadialBlurEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_radblur_error; Lib.Add('radblur_error@', Fn);
  Fn.Entry := @s_radblur_errormsg; Lib.Add('radblur_errormsg$@', Fn);
  Fn.Entry := @s_radblur_strerror; Lib.Add('radblur_strerror$@n', Fn);
  Fn.Entry := @n_radblur_clearerror; Lib.Add('radblur_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_radblur_new; Lib.Add('radblur#@#', Fn);
  Fn.Entry := @n_radblur_free; Lib.Add('radblur_free@#', Fn);

  // BlurAmount property
  Fn.Entry := @p_radblur_bluramount_set; Lib.Add('radblur_bluramount#@#n', Fn);
  Fn.Entry := @n_radblur_bluramount_get; Lib.Add('radblur_bluramount@#', Fn);

  // CenterX property
  Fn.Entry := @p_radblur_centerx_set; Lib.Add('radblur_centerx#@#n', Fn);
  Fn.Entry := @n_radblur_centerx_get; Lib.Add('radblur_centerx@#', Fn);

  // CenterY property
  Fn.Entry := @p_radblur_centery_set; Lib.Add('radblur_centery#@#n', Fn);
  Fn.Entry := @n_radblur_centery_get; Lib.Add('radblur_centery@#', Fn);

  // Enabled property
  Fn.Entry := @p_radblur_enabled_set; Lib.Add('radblur_enabled#@#n', Fn);
  Fn.Entry := @n_radblur_enabled_get; Lib.Add('radblur_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_radblur_trigger_set; Lib.Add('radblur_trigger#@#$', Fn);
  Fn.Entry := @s_radblur_trigger_get; Lib.Add('radblur_trigger$@#', Fn);
end;

end.
