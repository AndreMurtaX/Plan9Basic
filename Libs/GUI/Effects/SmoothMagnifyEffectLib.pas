unit SmoothMagnifyEffectLib;

{******************************************************************************
  SmoothMagnifyEffectLib - Smooth Magnify Effect Library for Plan9Basic
  Version: 1.0.0
  
  Creates a smooth magnifying lens effect with configurable size,
  position, and magnification level.
  
  Function Count: 20 functions
  
  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry;

procedure RegisterSmoothMagnifyEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, TSmoothMagnifyEffect)) then
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

function n_smag_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_smag_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_smag_strerror(var Args: array of TAsmData): TAsmData;
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

function n_smag_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_smag_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TSmoothMagnifyEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'smag#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TSmoothMagnifyEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Center := TPointF.Create(0.5, 0.5);
    Effect.Magnification := 2.0;
    Effect.InnerRadius := 0.1;
    Effect.OuterRadius := 0.2;
    Effect.AspectRatio := 1.0;
    
    //UnitGC.GC.Add<TSmoothMagnifyEffect>(Effect, IntToStr(NativeInt(Effect)));
    
    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'smag#: ' + E.Message);
  end;
end;

function n_smag_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TSmoothMagnifyEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_free') then Exit;

  try
    Effect := TSmoothMagnifyEffect(Args[0].p);
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'smag_free: ' + E.Message);
  end;
end;

// =============================================================================
// CenterX Property
// =============================================================================

function p_smag_centerx_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TSmoothMagnifyEffect;
  CurY: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_centerx#') then Exit;

  try
    Effect := TSmoothMagnifyEffect(Args[0].p);
    CurY := Effect.Center.Y;
    Effect.Center := TPointF.Create(Args[1].n, CurY);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'smag_centerx#: ' + E.Message);
  end;
end;

function n_smag_centerx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_centerx') then Exit;

  try
    Result.n := TSmoothMagnifyEffect(Args[0].p).Center.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'smag_centerx: ' + E.Message);
  end;
end;

// =============================================================================
// CenterY Property
// =============================================================================

function p_smag_centery_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TSmoothMagnifyEffect;
  CurX: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_centery#') then Exit;

  try
    Effect := TSmoothMagnifyEffect(Args[0].p);
    CurX := Effect.Center.X;
    Effect.Center := TPointF.Create(CurX, Args[1].n);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'smag_centery#: ' + E.Message);
  end;
end;

function n_smag_centery_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_centery') then Exit;

  try
    Result.n := TSmoothMagnifyEffect(Args[0].p).Center.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'smag_centery: ' + E.Message);
  end;
end;

// =============================================================================
// Magnification Property
// =============================================================================

function p_smag_magnification_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_mag#') then Exit;

  try
    TSmoothMagnifyEffect(Args[0].p).Magnification := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'smag_mag#: ' + E.Message);
  end;
end;

function n_smag_magnification_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_mag') then Exit;

  try
    Result.n := TSmoothMagnifyEffect(Args[0].p).Magnification;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'smag_mag: ' + E.Message);
  end;
end;

// =============================================================================
// InnerRadius Property
// =============================================================================

function p_smag_innerradius_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_inner#') then Exit;

  try
    TSmoothMagnifyEffect(Args[0].p).InnerRadius := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'smag_inner#: ' + E.Message);
  end;
end;

function n_smag_innerradius_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_inner') then Exit;

  try
    Result.n := TSmoothMagnifyEffect(Args[0].p).InnerRadius;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'smag_inner: ' + E.Message);
  end;
end;

// =============================================================================
// OuterRadius Property
// =============================================================================

function p_smag_outerradius_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_outer#') then Exit;

  try
    TSmoothMagnifyEffect(Args[0].p).OuterRadius := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'smag_outer#: ' + E.Message);
  end;
end;

function n_smag_outerradius_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_outer') then Exit;

  try
    Result.n := TSmoothMagnifyEffect(Args[0].p).OuterRadius;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'smag_outer: ' + E.Message);
  end;
end;

// =============================================================================
// AspectRatio Property
// =============================================================================

function p_smag_aspect_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_aspect#') then Exit;

  try
    TSmoothMagnifyEffect(Args[0].p).AspectRatio := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'smag_aspect#: ' + E.Message);
  end;
end;

function n_smag_aspect_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_aspect') then Exit;

  try
    Result.n := TSmoothMagnifyEffect(Args[0].p).AspectRatio;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'smag_aspect: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_smag_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_enabled#') then Exit;

  try
    TSmoothMagnifyEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'smag_enabled#: ' + E.Message);
  end;
end;

function n_smag_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_enabled') then Exit;

  try
    if TSmoothMagnifyEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'smag_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_smag_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_trigger#') then Exit;

  try
    TSmoothMagnifyEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'smag_trigger#: ' + E.Message);
  end;
end;

function s_smag_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'smag_trigger$') then Exit;

  try
    Result.s := TSmoothMagnifyEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'smag_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterSmoothMagnifyEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_smag_error; Lib.Add('smag_error@', Fn);
  Fn.Entry := @s_smag_errormsg; Lib.Add('smag_errormsg$@', Fn);
  Fn.Entry := @s_smag_strerror; Lib.Add('smag_strerror$@n', Fn);
  Fn.Entry := @n_smag_clearerror; Lib.Add('smag_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_smag_new; Lib.Add('smag#@#', Fn);
  Fn.Entry := @n_smag_free; Lib.Add('smag_free@#', Fn);

  // CenterX property
  Fn.Entry := @p_smag_centerx_set; Lib.Add('smag_centerx#@#n', Fn);
  Fn.Entry := @n_smag_centerx_get; Lib.Add('smag_centerx@#', Fn);

  // CenterY property
  Fn.Entry := @p_smag_centery_set; Lib.Add('smag_centery#@#n', Fn);
  Fn.Entry := @n_smag_centery_get; Lib.Add('smag_centery@#', Fn);

  // Magnification property
  Fn.Entry := @p_smag_magnification_set; Lib.Add('smag_mag#@#n', Fn);
  Fn.Entry := @n_smag_magnification_get; Lib.Add('smag_mag@#', Fn);

  // InnerRadius property
  Fn.Entry := @p_smag_innerradius_set; Lib.Add('smag_inner#@#n', Fn);
  Fn.Entry := @n_smag_innerradius_get; Lib.Add('smag_inner@#', Fn);

  // OuterRadius property
  Fn.Entry := @p_smag_outerradius_set; Lib.Add('smag_outer#@#n', Fn);
  Fn.Entry := @n_smag_outerradius_get; Lib.Add('smag_outer@#', Fn);

  // AspectRatio property
  Fn.Entry := @p_smag_aspect_set; Lib.Add('smag_aspect#@#n', Fn);
  Fn.Entry := @n_smag_aspect_get; Lib.Add('smag_aspect@#', Fn);

  // Enabled property
  Fn.Entry := @p_smag_enabled_set; Lib.Add('smag_enabled#@#n', Fn);
  Fn.Entry := @n_smag_enabled_get; Lib.Add('smag_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_smag_trigger_set; Lib.Add('smag_trigger#@#$', Fn);
  Fn.Entry := @s_smag_trigger_get; Lib.Add('smag_trigger$@#', Fn);
end;

end.
