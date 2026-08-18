unit PencilStrokeEffectLib;

{******************************************************************************
  PencilStrokeEffectLib - Pencil Stroke Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TPencilStrokeEffect wrapper for creating a pencil
  stroke/hatching appearance on visual controls.

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
  - BrushSize: Size of pencil strokes (0.0-10.0, default 1.0)
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

procedure RegisterPencilStrokeEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, TPencilStrokeEffect)) then
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

function n_pencilstroke_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_pencilstroke_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_pencilstroke_strerror(var Args: array of TAsmData): TAsmData;
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

function n_pencilstroke_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_pencilstroke_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TPencilStrokeEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'pencilstroke#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TPencilStrokeEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.BrushSize := 1.0;

    // GC.Add removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TPencilStrokeEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Torna este efeito um handle validavel sem dereferenciar o
    //ponteiro que o programa BASIC devolver. A baixa e automatica:
    //o efeito pertence ao pai, e o registry escuta FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pencilstroke#: ' + E.Message);
  end;
end;

function n_pencilstroke_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TPencilStrokeEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pencilstroke_free') then Exit;

  try
    Effect := TPencilStrokeEffect(Args[0].p);
    // GC.Collect removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pencilstroke_free: ' + E.Message);
  end;
end;

// =============================================================================
// BrushSize Property (0.0 - 10.0)
// =============================================================================

function p_pencilstroke_brushsize_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pencilstroke_brushsize#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.0 then Value := 0.0;
    if Value > 10.0 then Value := 10.0;
    TPencilStrokeEffect(Args[0].p).BrushSize := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pencilstroke_brushsize#: ' + E.Message);
  end;
end;

function n_pencilstroke_brushsize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pencilstroke_brushsize') then Exit;

  try
    Result.n := TPencilStrokeEffect(Args[0].p).BrushSize;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pencilstroke_brushsize: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_pencilstroke_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pencilstroke_enabled#') then Exit;

  try
    TPencilStrokeEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pencilstroke_enabled#: ' + E.Message);
  end;
end;

function n_pencilstroke_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pencilstroke_enabled') then Exit;

  try
    if TPencilStrokeEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pencilstroke_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_pencilstroke_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pencilstroke_trigger#') then Exit;

  try
    TPencilStrokeEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'pencilstroke_trigger#: ' + E.Message);
  end;
end;

function s_pencilstroke_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'pencilstroke_trigger$') then Exit;

  try
    Result.s := TPencilStrokeEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pencilstroke_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterPencilStrokeEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_pencilstroke_error; Lib.Add('pencilstroke_error@', Fn);
  Fn.Entry := @s_pencilstroke_errormsg; Lib.Add('pencilstroke_errormsg$@', Fn);
  Fn.Entry := @s_pencilstroke_strerror; Lib.Add('pencilstroke_strerror$@n', Fn);
  Fn.Entry := @n_pencilstroke_clearerror; Lib.Add('pencilstroke_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_pencilstroke_new; Lib.Add('pencilstroke#@#', Fn);
  Fn.Entry := @n_pencilstroke_free; Lib.Add('pencilstroke_free@#', Fn);

  // BrushSize property
  Fn.Entry := @p_pencilstroke_brushsize_set; Lib.Add('pencilstroke_brushsize#@#n', Fn);
  Fn.Entry := @n_pencilstroke_brushsize_get; Lib.Add('pencilstroke_brushsize@#', Fn);

  // Enabled property
  Fn.Entry := @p_pencilstroke_enabled_set; Lib.Add('pencilstroke_enabled#@#n', Fn);
  Fn.Entry := @n_pencilstroke_enabled_get; Lib.Add('pencilstroke_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_pencilstroke_trigger_set; Lib.Add('pencilstroke_trigger#@#$', Fn);
  Fn.Entry := @s_pencilstroke_trigger_get; Lib.Add('pencilstroke_trigger$@#', Fn);
end;

end.

