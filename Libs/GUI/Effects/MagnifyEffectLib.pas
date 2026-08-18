unit MagnifyEffectLib;

{******************************************************************************
  MagnifyEffectLib - Magnify Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TMagnifyEffect wrapper for creating magnifying glass
  effect on visual controls.

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
  - Magnification: Zoom level (1.0-5.0, default 2.0)
  - Radius: Size of magnified area (0-200, default 100)
  - CenterX: Horizontal center (0.0-1.0, default 0.5)
  - CenterY: Vertical center (0.0-1.0, default 0.5)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry;

procedure RegisterMagnifyEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, TMagnifyEffect)) then
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

function n_magnify_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_magnify_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_magnify_strerror(var Args: array of TAsmData): TAsmData;
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

function n_magnify_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_magnify_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TMagnifyEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'magnify#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TMagnifyEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Magnification := 2.0;
    Effect.Radius := 100;
    Effect.Center := PointF(0.5, 0.5);

    // GC.Add removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TMagnifyEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Torna este efeito um handle validavel sem dereferenciar o
    //ponteiro que o programa BASIC devolver. A baixa e automatica:
    //o efeito pertence ao pai, e o registry escuta FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'magnify#: ' + E.Message);
  end;
end;

function n_magnify_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TMagnifyEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'magnify_free') then Exit;

  try
    Effect := TMagnifyEffect(Args[0].p);
    // GC.Collect removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'magnify_free: ' + E.Message);
  end;
end;

// =============================================================================
// Magnification Property (1.0 - 5.0)
// =============================================================================

function p_magnify_magnification_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'magnify_magnification#') then Exit;

  try
    Value := Args[1].n;
    if Value < 1.0 then Value := 1.0;
    if Value > 5.0 then Value := 5.0;
    TMagnifyEffect(Args[0].p).Magnification := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'magnify_magnification#: ' + E.Message);
  end;
end;

function n_magnify_magnification_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'magnify_magnification') then Exit;

  try
    Result.n := TMagnifyEffect(Args[0].p).Magnification;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'magnify_magnification: ' + E.Message);
  end;
end;

// =============================================================================
// Radius Property (0 - 200)
// =============================================================================

function p_magnify_radius_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'magnify_radius#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 200 then Value := 200;
    TMagnifyEffect(Args[0].p).Radius := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'magnify_radius#: ' + E.Message);
  end;
end;

function n_magnify_radius_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'magnify_radius') then Exit;

  try
    Result.n := TMagnifyEffect(Args[0].p).Radius;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'magnify_radius: ' + E.Message);
  end;
end;

// =============================================================================
// CenterX Property (0.0 - 1.0)
// =============================================================================

function p_magnify_centerx_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'magnify_centerx#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;
    Pt := TMagnifyEffect(Args[0].p).Center;
    Pt.X := Value;
    TMagnifyEffect(Args[0].p).Center := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'magnify_centerx#: ' + E.Message);
  end;
end;

function n_magnify_centerx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'magnify_centerx') then Exit;

  try
    Result.n := TMagnifyEffect(Args[0].p).Center.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'magnify_centerx: ' + E.Message);
  end;
end;

// =============================================================================
// CenterY Property (0.0 - 1.0)
// =============================================================================

function p_magnify_centery_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'magnify_centery#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;
    Pt := TMagnifyEffect(Args[0].p).Center;
    Pt.Y := Value;
    TMagnifyEffect(Args[0].p).Center := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'magnify_centery#: ' + E.Message);
  end;
end;

function n_magnify_centery_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'magnify_centery') then Exit;

  try
    Result.n := TMagnifyEffect(Args[0].p).Center.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'magnify_centery: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_magnify_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'magnify_enabled#') then Exit;

  try
    TMagnifyEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'magnify_enabled#: ' + E.Message);
  end;
end;

function n_magnify_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'magnify_enabled') then Exit;

  try
    if TMagnifyEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'magnify_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_magnify_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'magnify_trigger#') then Exit;

  try
    TMagnifyEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'magnify_trigger#: ' + E.Message);
  end;
end;

function s_magnify_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'magnify_trigger$') then Exit;

  try
    Result.s := TMagnifyEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'magnify_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterMagnifyEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_magnify_error; Lib.Add('magnify_error@', Fn);
  Fn.Entry := @s_magnify_errormsg; Lib.Add('magnify_errormsg$@', Fn);
  Fn.Entry := @s_magnify_strerror; Lib.Add('magnify_strerror$@n', Fn);
  Fn.Entry := @n_magnify_clearerror; Lib.Add('magnify_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_magnify_new; Lib.Add('magnify#@#', Fn);
  Fn.Entry := @n_magnify_free; Lib.Add('magnify_free@#', Fn);

  // Magnification property
  Fn.Entry := @p_magnify_magnification_set; Lib.Add('magnify_magnification#@#n', Fn);
  Fn.Entry := @n_magnify_magnification_get; Lib.Add('magnify_magnification@#', Fn);

  // Radius property
  Fn.Entry := @p_magnify_radius_set; Lib.Add('magnify_radius#@#n', Fn);
  Fn.Entry := @n_magnify_radius_get; Lib.Add('magnify_radius@#', Fn);

  // CenterX property
  Fn.Entry := @p_magnify_centerx_set; Lib.Add('magnify_centerx#@#n', Fn);
  Fn.Entry := @n_magnify_centerx_get; Lib.Add('magnify_centerx@#', Fn);

  // CenterY property
  Fn.Entry := @p_magnify_centery_set; Lib.Add('magnify_centery#@#n', Fn);
  Fn.Entry := @n_magnify_centery_get; Lib.Add('magnify_centery@#', Fn);

  // Enabled property
  Fn.Entry := @p_magnify_enabled_set; Lib.Add('magnify_enabled#@#n', Fn);
  Fn.Entry := @n_magnify_enabled_get; Lib.Add('magnify_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_magnify_trigger_set; Lib.Add('magnify_trigger#@#$', Fn);
  Fn.Entry := @s_magnify_trigger_get; Lib.Add('magnify_trigger$@#', Fn);
end;

end.

