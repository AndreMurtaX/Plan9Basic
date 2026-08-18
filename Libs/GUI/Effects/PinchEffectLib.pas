unit PinchEffectLib;

{******************************************************************************
  PinchEffectLib - Pinch Effect Library for Plan9Basic
  Version: 1.0.0

  Creates a pinch or bulge distortion effect at a specified location.
  Positive strength creates a pinch (inward), negative creates a bulge (outward).

  Function Count: 18 functions

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry;

procedure RegisterPinchEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, TPinchEffect)) then
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

function n_pinch_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_pinch_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_pinch_strerror(var Args: array of TAsmData): TAsmData;
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

function n_pinch_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_pinch_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TPinchEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'pinch#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TPinchEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Center := TPointF.Create(0.5, 0.5);
    Effect.Radius := 0.25;
    Effect.Strength := 0.5;
    Effect.AspectRatio := 1.0;

    // GC.Add removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TPinchEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Torna este efeito um handle validavel sem dereferenciar o
    //ponteiro que o programa BASIC devolver. A baixa e automatica:
    //o efeito pertence ao pai, e o registry escuta FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pinch#: ' + E.Message);
  end;
end;

function n_pinch_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TPinchEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_free') then Exit;

  try
    Effect := TPinchEffect(Args[0].p);
    // GC.Collect removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pinch_free: ' + E.Message);
  end;
end;

// =============================================================================
// CenterX Property
// =============================================================================

function p_pinch_centerx_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TPinchEffect;
  CurY: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_centerx#') then Exit;

  try
    Effect := TPinchEffect(Args[0].p);
    CurY := Effect.Center.Y;
    Effect.Center := TPointF.Create(Args[1].n, CurY);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pinch_centerx#: ' + E.Message);
  end;
end;

function n_pinch_centerx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_centerx') then Exit;

  try
    Result.n := TPinchEffect(Args[0].p).Center.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pinch_centerx: ' + E.Message);
  end;
end;

// =============================================================================
// CenterY Property
// =============================================================================

function p_pinch_centery_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TPinchEffect;
  CurX: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_centery#') then Exit;

  try
    Effect := TPinchEffect(Args[0].p);
    CurX := Effect.Center.X;
    Effect.Center := TPointF.Create(CurX, Args[1].n);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pinch_centery#: ' + E.Message);
  end;
end;

function n_pinch_centery_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_centery') then Exit;

  try
    Result.n := TPinchEffect(Args[0].p).Center.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pinch_centery: ' + E.Message);
  end;
end;

// =============================================================================
// Radius Property
// =============================================================================

function p_pinch_radius_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_radius#') then Exit;

  try
    TPinchEffect(Args[0].p).Radius := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pinch_radius#: ' + E.Message);
  end;
end;

function n_pinch_radius_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_radius') then Exit;

  try
    Result.n := TPinchEffect(Args[0].p).Radius;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pinch_radius: ' + E.Message);
  end;
end;

// =============================================================================
// Strength Property
// =============================================================================

function p_pinch_strength_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_strength#') then Exit;

  try
    TPinchEffect(Args[0].p).Strength := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pinch_strength#: ' + E.Message);
  end;
end;

function n_pinch_strength_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_strength') then Exit;

  try
    Result.n := TPinchEffect(Args[0].p).Strength;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pinch_strength: ' + E.Message);
  end;
end;

// =============================================================================
// AspectRatio Property
// =============================================================================

function p_pinch_aspect_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_aspect#') then Exit;

  try
    TPinchEffect(Args[0].p).AspectRatio := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pinch_aspect#: ' + E.Message);
  end;
end;

function n_pinch_aspect_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_aspect') then Exit;

  try
    Result.n := TPinchEffect(Args[0].p).AspectRatio;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pinch_aspect: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_pinch_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_enabled#') then Exit;

  try
    TPinchEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pinch_enabled#: ' + E.Message);
  end;
end;

function n_pinch_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_enabled') then Exit;

  try
    if TPinchEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pinch_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_pinch_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_trigger#') then Exit;

  try
    TPinchEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pinch_trigger#: ' + E.Message);
  end;
end;

function s_pinch_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pinch_trigger$') then Exit;

  try
    Result.s := TPinchEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pinch_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterPinchEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_pinch_error; Lib.Add('pinch_error@', Fn);
  Fn.Entry := @s_pinch_errormsg; Lib.Add('pinch_errormsg$@', Fn);
  Fn.Entry := @s_pinch_strerror; Lib.Add('pinch_strerror$@n', Fn);
  Fn.Entry := @n_pinch_clearerror; Lib.Add('pinch_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_pinch_new; Lib.Add('pinch#@#', Fn);
  Fn.Entry := @n_pinch_free; Lib.Add('pinch_free@#', Fn);

  // CenterX property
  Fn.Entry := @p_pinch_centerx_set; Lib.Add('pinch_centerx#@#n', Fn);
  Fn.Entry := @n_pinch_centerx_get; Lib.Add('pinch_centerx@#', Fn);

  // CenterY property
  Fn.Entry := @p_pinch_centery_set; Lib.Add('pinch_centery#@#n', Fn);
  Fn.Entry := @n_pinch_centery_get; Lib.Add('pinch_centery@#', Fn);

  // Radius property
  Fn.Entry := @p_pinch_radius_set; Lib.Add('pinch_radius#@#n', Fn);
  Fn.Entry := @n_pinch_radius_get; Lib.Add('pinch_radius@#', Fn);

  // Strength property
  Fn.Entry := @p_pinch_strength_set; Lib.Add('pinch_strength#@#n', Fn);
  Fn.Entry := @n_pinch_strength_get; Lib.Add('pinch_strength@#', Fn);

  // AspectRatio property
  Fn.Entry := @p_pinch_aspect_set; Lib.Add('pinch_aspect#@#n', Fn);
  Fn.Entry := @n_pinch_aspect_get; Lib.Add('pinch_aspect@#', Fn);

  // Enabled property
  Fn.Entry := @p_pinch_enabled_set; Lib.Add('pinch_enabled#@#n', Fn);
  Fn.Entry := @n_pinch_enabled_get; Lib.Add('pinch_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_pinch_trigger_set; Lib.Add('pinch_trigger#@#$', Fn);
  Fn.Entry := @s_pinch_trigger_get; Lib.Add('pinch_trigger$@#', Fn);
end;

end.

