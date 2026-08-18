unit NormalBlendEffectLib;

{******************************************************************************
  NormalBlendEffectLib - Normal Blend Effect Library for Plan9Basic
  Version: 1.0.0

  Blends two images using normal (alpha) blending mode.
  The Target property receives a second bitmap to blend with the source.

  Note: Target must be set using blend_target# with a TImage control.
  The effect will use the TImage's internal bitmap for blending.

  Function Count: 12 functions

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Objects, FMX.Graphics, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry;

procedure RegisterNormalBlendEffectFuncs(Lib: TFunctionsDictionary);

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
  ERR_NIL_TARGET = 6;
  ERR_INVALID_TARGET = 7;

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
  if not (IsHandleOf(P, TNormalBlendEffect)) then
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

function n_blend_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_blend_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_blend_strerror(var Args: array of TAsmData): TAsmData;
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
    ERR_NIL_TARGET: Result.s := 'Target is nil';
    ERR_INVALID_TARGET: Result.s := 'Invalid target object';
  else
    Result.s := 'Unknown error code: ' + IntToStr(Code);
  end;
end;

function n_blend_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_blend_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TNormalBlendEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'blend#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TNormalBlendEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;

    // GC.Add removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TNormalBlendEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Torna este efeito um handle validavel sem dereferenciar o
    //ponteiro que o programa BASIC devolver. A baixa e automatica:
    //o efeito pertence ao pai, e o registry escuta FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'blend#: ' + E.Message);
  end;
end;

function n_blend_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TNormalBlendEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'blend_free') then Exit;

  try
    Effect := TNormalBlendEffect(Args[0].p);
    // GC.Collect removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'blend_free: ' + E.Message);
  end;
end;

// =============================================================================
// Target Property - accepts TImage and uses its Bitmap
// =============================================================================

function p_blend_target_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TNormalBlendEffect;
  TargetImage: TImage;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'blend_target#') then Exit;

  if not Assigned(Args[1].p) then
  begin
    SetError(ERR_NIL_TARGET, 'blend_target#: target is nil');
    Exit;
  end;

  if not (TObject(Args[1].p) is TImage) then
  begin
    SetError(ERR_INVALID_TARGET, 'blend_target#: target must be a TImage');
    Exit;
  end;

  try
    Effect := TNormalBlendEffect(Args[0].p);
    TargetImage := TImage(Args[1].p);
    Effect.Target := TargetImage.Bitmap;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'blend_target#: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_blend_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'blend_enabled#') then Exit;

  try
    TNormalBlendEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'blend_enabled#: ' + E.Message);
  end;
end;

function n_blend_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'blend_enabled') then Exit;

  try
    if TNormalBlendEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'blend_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_blend_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'blend_trigger#') then Exit;

  try
    TNormalBlendEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'blend_trigger#: ' + E.Message);
  end;
end;

function s_blend_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'blend_trigger$') then Exit;

  try
    Result.s := TNormalBlendEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'blend_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterNormalBlendEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_blend_error; Lib.Add('blend_error@', Fn);
  Fn.Entry := @s_blend_errormsg; Lib.Add('blend_errormsg$@', Fn);
  Fn.Entry := @s_blend_strerror; Lib.Add('blend_strerror$@n', Fn);
  Fn.Entry := @n_blend_clearerror; Lib.Add('blend_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_blend_new; Lib.Add('blend#@#', Fn);
  Fn.Entry := @n_blend_free; Lib.Add('blend_free@#', Fn);

  // Target property (TImage -> TBitmap)
  Fn.Entry := @p_blend_target_set; Lib.Add('blend_target#@##', Fn);

  // Enabled property
  Fn.Entry := @p_blend_enabled_set; Lib.Add('blend_enabled#@#n', Fn);
  Fn.Entry := @n_blend_enabled_get; Lib.Add('blend_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_blend_trigger_set; Lib.Add('blend_trigger#@#$', Fn);
  Fn.Entry := @s_blend_trigger_get; Lib.Add('blend_trigger$@#', Fn);
end;

end.

