unit PixelateEffectLib;

{******************************************************************************
  PixelateEffectLib - Pixelate Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TPixelateEffect wrapper for creating pixelated/mosaic
  appearance on visual controls.

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
  - BlockCount: Number of pixel blocks (1-100, default 20)
    Higher values = more blocks = smaller pixels = more detail
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

procedure RegisterPixelateEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, TPixelateEffect)) then
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

function n_pixelate_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_pixelate_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_pixelate_strerror(var Args: array of TAsmData): TAsmData;
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

function n_pixelate_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_pixelate_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TPixelateEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'pixelate#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TPixelateEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.BlockCount := 20;
    
    // GC registration removed - parent ownership handles cleanup
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    //UnitGC.GC.Add<TPixelateEffect>(Effect, IntToStr(NativeInt(Effect)));
    
    //Torna este efeito um handle validavel sem dereferenciar o
    //ponteiro que o programa BASIC devolver. A baixa e automatica:
    //o efeito pertence ao pai, e o registry escuta FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pixelate#: ' + E.Message);
  end;
end;

function n_pixelate_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TPixelateEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pixelate_free') then Exit;

  try
    Effect := TPixelateEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pixelate_free: ' + E.Message);
  end;
end;

// =============================================================================
// BlockCount Property (1 - 100)
// =============================================================================

function p_pixelate_blockcount_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pixelate_blockcount#') then Exit;

  try
    Value := Args[1].n;
    if Value < 1 then Value := 1;
    if Value > 100 then Value := 100;
    TPixelateEffect(Args[0].p).BlockCount := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pixelate_blockcount#: ' + E.Message);
  end;
end;

function n_pixelate_blockcount_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pixelate_blockcount') then Exit;

  try
    Result.n := TPixelateEffect(Args[0].p).BlockCount;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pixelate_blockcount: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_pixelate_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pixelate_enabled#') then Exit;

  try
    TPixelateEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pixelate_enabled#: ' + E.Message);
  end;
end;

function n_pixelate_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pixelate_enabled') then Exit;

  try
    if TPixelateEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pixelate_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_pixelate_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pixelate_trigger#') then Exit;

  try
    TPixelateEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pixelate_trigger#: ' + E.Message);
  end;
end;

function s_pixelate_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pixelate_trigger$') then Exit;

  try
    Result.s := TPixelateEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pixelate_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterPixelateEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_pixelate_error; Lib.Add('pixelate_error@', Fn);
  Fn.Entry := @s_pixelate_errormsg; Lib.Add('pixelate_errormsg$@', Fn);
  Fn.Entry := @s_pixelate_strerror; Lib.Add('pixelate_strerror$@n', Fn);
  Fn.Entry := @n_pixelate_clearerror; Lib.Add('pixelate_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_pixelate_new; Lib.Add('pixelate#@#', Fn);
  Fn.Entry := @n_pixelate_free; Lib.Add('pixelate_free@#', Fn);

  // BlockCount property
  Fn.Entry := @p_pixelate_blockcount_set; Lib.Add('pixelate_blockcount#@#n', Fn);
  Fn.Entry := @n_pixelate_blockcount_get; Lib.Add('pixelate_blockcount@#', Fn);

  // Enabled property
  Fn.Entry := @p_pixelate_enabled_set; Lib.Add('pixelate_enabled#@#n', Fn);
  Fn.Entry := @n_pixelate_enabled_get; Lib.Add('pixelate_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_pixelate_trigger_set; Lib.Add('pixelate_trigger#@#$', Fn);
  Fn.Entry := @s_pixelate_trigger_get; Lib.Add('pixelate_trigger$@#', Fn);
end;

end.
