unit ContrastEffectLib;

{******************************************************************************
  ContrastEffectLib - Contrast Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TContrastEffect wrapper for adjusting the contrast
  of visual controls. Increases or decreases the difference between light
  and dark areas.

  Function Count: 16 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  FEATURES:
  =========
  - Adjusts contrast of any visual control
  - Adjustable brightness alongside contrast
  - GPU-accelerated rendering
  - Trigger support for conditional activation

  PROPERTIES:
  ===========
  - Contrast: Amount of contrast adjustment (0.0-2.0, default 1.0)
    - 0.0 = No contrast (gray)
    - 1.0 = Normal contrast
    - 2.0 = Maximum contrast
  - Brightness: Brightness adjustment (-1.0 to 1.0, default 0.0)
    - -1.0 = Completely dark
    - 0.0 = Normal brightness
    - 1.0 = Completely bright
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

procedure RegisterContrastEffectFuncs(Lib: TFunctionsDictionary);

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

// =============================================================================
// Error Handling
// =============================================================================

procedure SetError(Code: Integer; const Msg: String);
begin
  LastError := Code;
  LastErrorMsg := Msg;
end;

procedure ClearError();
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
  if not (IsHandleOf(P, TContrastEffect)) then
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

function n_contrast_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_contrast_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_contrast_strerror(var Args: array of TAsmData): TAsmData;
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

function n_contrast_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_contrast_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TContrastEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'contrast#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    // Create with parent as Owner - parent will free effect when destroyed
    // This avoids double-free issues with the GC
    Effect := TContrastEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Contrast := 1.0;
    Effect.Brightness := 0.0;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TContrastEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Torna este efeito um handle validavel sem dereferenciar o
    //ponteiro que o programa BASIC devolver. A baixa e automatica:
    //o efeito pertence ao pai, e o registry escuta FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'contrast#: ' + E.Message);
  end;
end;

function n_contrast_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TContrastEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'contrast_free') then Exit;

  try
    Effect := TContrastEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'contrast_free: ' + E.Message);
  end;
end;

// =============================================================================
// Contrast Property (0.0 - 2.0)
// =============================================================================

function p_contrast_contrast_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'contrast_contrast#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.0 then Value := 0.0;
    if Value > 2.0 then Value := 2.0;
    TContrastEffect(Args[0].p).Contrast := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'contrast_contrast#: ' + E.Message);
  end;
end;

function n_contrast_contrast_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'contrast_contrast') then Exit;

  try
    Result.n := TContrastEffect(Args[0].p).Contrast;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'contrast_contrast: ' + E.Message);
  end;
end;

// =============================================================================
// Brightness Property (-1.0 to 1.0)
// =============================================================================

function p_contrast_brightness_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'contrast_brightness#') then Exit;

  try
    Value := Args[1].n;
    if Value < -1.0 then Value := -1.0;
    if Value > 1.0 then Value := 1.0;
    TContrastEffect(Args[0].p).Brightness := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'contrast_brightness#: ' + E.Message);
  end;
end;

function n_contrast_brightness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'contrast_brightness') then Exit;

  try
    Result.n := TContrastEffect(Args[0].p).Brightness;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'contrast_brightness: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_contrast_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'contrast_enabled#') then Exit;

  try
    TContrastEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'contrast_enabled#: ' + E.Message);
  end;
end;

function n_contrast_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'contrast_enabled') then Exit;

  try
    if TContrastEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'contrast_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_contrast_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'contrast_trigger#') then Exit;

  try
    TContrastEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'contrast_trigger#: ' + E.Message);
  end;
end;

function s_contrast_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'contrast_trigger$') then Exit;

  try
    Result.s := TContrastEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'contrast_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterContrastEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_contrast_error; Lib.Add('contrast_error@', Fn);
  Fn.Entry := @s_contrast_errormsg; Lib.Add('contrast_errormsg$@', Fn);
  Fn.Entry := @s_contrast_strerror; Lib.Add('contrast_strerror$@n', Fn);
  Fn.Entry := @n_contrast_clearerror; Lib.Add('contrast_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_contrast_new; Lib.Add('contrast#@#', Fn);
  Fn.Entry := @n_contrast_free; Lib.Add('contrast_free@#', Fn);

  // Contrast property
  Fn.Entry := @p_contrast_contrast_set; Lib.Add('contrast_contrast#@#n', Fn);
  Fn.Entry := @n_contrast_contrast_get; Lib.Add('contrast_contrast@#', Fn);

  // Brightness property
  Fn.Entry := @p_contrast_brightness_set; Lib.Add('contrast_brightness#@#n', Fn);
  Fn.Entry := @n_contrast_brightness_get; Lib.Add('contrast_brightness@#', Fn);

  // Enabled property
  Fn.Entry := @p_contrast_enabled_set; Lib.Add('contrast_enabled#@#n', Fn);
  Fn.Entry := @n_contrast_enabled_get; Lib.Add('contrast_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_contrast_trigger_set; Lib.Add('contrast_trigger#@#$', Fn);
  Fn.Entry := @s_contrast_trigger_get; Lib.Add('contrast_trigger$@#', Fn);
end;

end.
