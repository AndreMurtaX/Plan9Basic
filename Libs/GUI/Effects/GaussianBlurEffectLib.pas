unit GaussianBlurEffectLib;

{******************************************************************************
  GaussianBlurEffectLib - Gaussian Blur Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TGaussianBlurEffect wrapper for applying smooth
  Gaussian blur effects to visual controls.

  Function Count: 12 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PROPERTIES:
  ===========
  - BlurAmount: Blur intensity (0 to 10, default 0.1)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry;

procedure RegisterGaussianBlurEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, TGaussianBlurEffect)) then
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

function n_gaussblur_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_gaussblur_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_gaussblur_strerror(var Args: array of TAsmData): TAsmData;
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

function n_gaussblur_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_gaussblur_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TGaussianBlurEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'gaussblur#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TGaussianBlurEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.BlurAmount := 0.1;

    // GC.Add removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TGaussianBlurEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'gaussblur#: ' + E.Message);
  end;
end;

function n_gaussblur_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TGaussianBlurEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gaussblur_free') then Exit;

  try
    Effect := TGaussianBlurEffect(Args[0].p);
    // GC.Collect removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'gaussblur_free: ' + E.Message);
  end;
end;

// =============================================================================
// BlurAmount Property (0 - 10)
// =============================================================================

function p_gaussblur_bluramount_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gaussblur_bluramount#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 10 then Value := 10;
    TGaussianBlurEffect(Args[0].p).BlurAmount := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'gaussblur_bluramount#: ' + E.Message);
  end;
end;

function n_gaussblur_bluramount_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gaussblur_bluramount') then Exit;

  try
    Result.n := TGaussianBlurEffect(Args[0].p).BlurAmount;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'gaussblur_bluramount: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_gaussblur_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gaussblur_enabled#') then Exit;

  try
    TGaussianBlurEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'gaussblur_enabled#: ' + E.Message);
  end;
end;

function n_gaussblur_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gaussblur_enabled') then Exit;

  try
    if TGaussianBlurEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'gaussblur_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_gaussblur_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gaussblur_trigger#') then Exit;

  try
    TGaussianBlurEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'gaussblur_trigger#: ' + E.Message);
  end;
end;

function s_gaussblur_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'gaussblur_trigger$') then Exit;

  try
    Result.s := TGaussianBlurEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'gaussblur_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterGaussianBlurEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_gaussblur_error; Lib.Add('gaussblur_error@', Fn);
  Fn.Entry := @s_gaussblur_errormsg; Lib.Add('gaussblur_errormsg$@', Fn);
  Fn.Entry := @s_gaussblur_strerror; Lib.Add('gaussblur_strerror$@n', Fn);
  Fn.Entry := @n_gaussblur_clearerror; Lib.Add('gaussblur_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_gaussblur_new; Lib.Add('gaussblur#@#', Fn);
  Fn.Entry := @n_gaussblur_free; Lib.Add('gaussblur_free@#', Fn);

  // BlurAmount property
  Fn.Entry := @p_gaussblur_bluramount_set; Lib.Add('gaussblur_bluramount#@#n', Fn);
  Fn.Entry := @n_gaussblur_bluramount_get; Lib.Add('gaussblur_bluramount@#', Fn);

  // Enabled property
  Fn.Entry := @p_gaussblur_enabled_set; Lib.Add('gaussblur_enabled#@#n', Fn);
  Fn.Entry := @n_gaussblur_enabled_get; Lib.Add('gaussblur_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_gaussblur_trigger_set; Lib.Add('gaussblur_trigger#@#$', Fn);
  Fn.Entry := @s_gaussblur_trigger_get; Lib.Add('gaussblur_trigger$@#', Fn);
end;

end.

