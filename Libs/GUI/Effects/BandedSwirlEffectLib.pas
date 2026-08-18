unit BandedSwirlEffectLib;

{******************************************************************************
  BandedSwirlEffectLib - Banded Swirl Effect Library for Plan9Basic
  Version: 1.0.0

  Creates a swirl distortion effect with concentric bands.
  The swirl rotates pixels around a center point with alternating bands.

  Function Count: 18 functions

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry;

procedure RegisterBandedSwirlEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, TBandedSwirlEffect)) then
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

function n_bswirl_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_bswirl_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_bswirl_strerror(var Args: array of TAsmData): TAsmData;
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

function n_bswirl_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_bswirl_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandedSwirlEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'bswirl#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TBandedSwirlEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Center := TPointF.Create(0.5, 0.5);
    Effect.Bands := 3.0;
    Effect.Strength := 0.5;
    Effect.AspectRatio := 1.0;

    // GC registration removed - parent ownership handles cleanup
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    // UnitGC.GC.Add<TBandedSwirlEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Torna este efeito um handle validavel sem dereferenciar o
    //ponteiro que o programa BASIC devolver. A baixa e automatica:
    //o efeito pertence ao pai, e o registry escuta FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl#: ' + E.Message);
  end;
end;

function n_bswirl_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandedSwirlEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_free') then Exit;

  try
    Effect := TBandedSwirlEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_free: ' + E.Message);
  end;
end;

// =============================================================================
// CenterX Property
// =============================================================================

function p_bswirl_centerx_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandedSwirlEffect;
  CurY: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_centerx#') then Exit;

  try
    Effect := TBandedSwirlEffect(Args[0].p);
    CurY := Effect.Center.Y;
    Effect.Center := TPointF.Create(Args[1].n, CurY);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_centerx#: ' + E.Message);
  end;
end;

function n_bswirl_centerx_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_centerx') then Exit;

  try
    Result.n := TBandedSwirlEffect(Args[0].p).Center.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_centerx: ' + E.Message);
  end;
end;

// =============================================================================
// CenterY Property
// =============================================================================

function p_bswirl_centery_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TBandedSwirlEffect;
  CurX: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_centery#') then Exit;

  try
    Effect := TBandedSwirlEffect(Args[0].p);
    CurX := Effect.Center.X;
    Effect.Center := TPointF.Create(CurX, Args[1].n);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_centery#: ' + E.Message);
  end;
end;

function n_bswirl_centery_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_centery') then Exit;

  try
    Result.n := TBandedSwirlEffect(Args[0].p).Center.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_centery: ' + E.Message);
  end;
end;

// =============================================================================
// Bands Property
// =============================================================================

function p_bswirl_bands_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_bands#') then Exit;

  try
    TBandedSwirlEffect(Args[0].p).Bands := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_bands#: ' + E.Message);
  end;
end;

function n_bswirl_bands_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_bands') then Exit;

  try
    Result.n := TBandedSwirlEffect(Args[0].p).Bands;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_bands: ' + E.Message);
  end;
end;

// =============================================================================
// Strength Property
// =============================================================================

function p_bswirl_strength_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_strength#') then Exit;

  try
    TBandedSwirlEffect(Args[0].p).Strength := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_strength#: ' + E.Message);
  end;
end;

function n_bswirl_strength_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_strength') then Exit;

  try
    Result.n := TBandedSwirlEffect(Args[0].p).Strength;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_strength: ' + E.Message);
  end;
end;

// =============================================================================
// AspectRatio Property
// =============================================================================

function p_bswirl_aspect_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_aspect#') then Exit;

  try
    TBandedSwirlEffect(Args[0].p).AspectRatio := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_aspect#: ' + E.Message);
  end;
end;

function n_bswirl_aspect_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_aspect') then Exit;

  try
    Result.n := TBandedSwirlEffect(Args[0].p).AspectRatio;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_aspect: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_bswirl_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_enabled#') then Exit;

  try
    TBandedSwirlEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_enabled#: ' + E.Message);
  end;
end;

function n_bswirl_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_enabled') then Exit;

  try
    if TBandedSwirlEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_bswirl_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_trigger#') then Exit;

  try
    TBandedSwirlEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bswirl_trigger#: ' + E.Message);
  end;
end;

function s_bswirl_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bswirl_trigger$') then Exit;

  try
    Result.s := TBandedSwirlEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bswirl_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterBandedSwirlEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_bswirl_error; Lib.Add('bswirl_error@', Fn);
  Fn.Entry := @s_bswirl_errormsg; Lib.Add('bswirl_errormsg$@', Fn);
  Fn.Entry := @s_bswirl_strerror; Lib.Add('bswirl_strerror$@n', Fn);
  Fn.Entry := @n_bswirl_clearerror; Lib.Add('bswirl_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_bswirl_new; Lib.Add('bswirl#@#', Fn);
  Fn.Entry := @n_bswirl_free; Lib.Add('bswirl_free@#', Fn);

  // CenterX property
  Fn.Entry := @p_bswirl_centerx_set; Lib.Add('bswirl_centerx#@#n', Fn);
  Fn.Entry := @n_bswirl_centerx_get; Lib.Add('bswirl_centerx@#', Fn);

  // CenterY property
  Fn.Entry := @p_bswirl_centery_set; Lib.Add('bswirl_centery#@#n', Fn);
  Fn.Entry := @n_bswirl_centery_get; Lib.Add('bswirl_centery@#', Fn);

  // Bands property
  Fn.Entry := @p_bswirl_bands_set; Lib.Add('bswirl_bands#@#n', Fn);
  Fn.Entry := @n_bswirl_bands_get; Lib.Add('bswirl_bands@#', Fn);

  // Strength property
  Fn.Entry := @p_bswirl_strength_set; Lib.Add('bswirl_strength#@#n', Fn);
  Fn.Entry := @n_bswirl_strength_get; Lib.Add('bswirl_strength@#', Fn);

  // AspectRatio property
  Fn.Entry := @p_bswirl_aspect_set; Lib.Add('bswirl_aspect#@#n', Fn);
  Fn.Entry := @n_bswirl_aspect_get; Lib.Add('bswirl_aspect@#', Fn);

  // Enabled property
  Fn.Entry := @p_bswirl_enabled_set; Lib.Add('bswirl_enabled#@#n', Fn);
  Fn.Entry := @n_bswirl_enabled_get; Lib.Add('bswirl_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_bswirl_trigger_set; Lib.Add('bswirl_trigger#@#$', Fn);
  Fn.Entry := @s_bswirl_trigger_get; Lib.Add('bswirl_trigger$@#', Fn);
end;

end.
