unit HueAdjustEffectLib;

{******************************************************************************
  HueAdjustEffectLib - Hue Adjust Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey THueAdjustEffect wrapper for shifting the hue of
  visual controls. Rotates colors around the color wheel.

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
  - Hue: Amount of hue shift (-1.0 to 1.0, default 0.0)
    - -1.0 = Shift 180 degrees counter-clockwise
    - 0.0 = No shift (original colors)
    - 1.0 = Shift 180 degrees clockwise
    Note: -1.0 and 1.0 produce same result (opposite colors)
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

procedure RegisterHueAdjustEffectFuncs(Lib: TFunctionsDictionary);

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
  if not (IsHandleOf(P, THueAdjustEffect)) then
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

function n_hueadjust_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_hueadjust_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_hueadjust_strerror(var Args: array of TAsmData): TAsmData;
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

function n_hueadjust_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_hueadjust_new(var Args: array of TAsmData): TAsmData;
var
  Effect: THueAdjustEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'hueadjust#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := THueAdjustEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Hue := 0.0;

    // GC registration removed - parent ownership handles cleanup
    // UnitGC.GC.Add<THueAdjustEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Torna este efeito um handle validavel sem dereferenciar o
    //ponteiro que o programa BASIC devolver. A baixa e automatica:
    //o efeito pertence ao pai, e o registry escuta FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'hueadjust#: ' + E.Message);
  end;
end;

function n_hueadjust_free(var Args: array of TAsmData): TAsmData;
var
  Effect: THueAdjustEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_free') then Exit;

  try
    Effect := THueAdjustEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'hueadjust_free: ' + E.Message);
  end;
end;

// =============================================================================
// Hue Property (-1.0 to 1.0)
// =============================================================================

function p_hueadjust_hue_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_hue#') then Exit;

  try
    Value := Args[1].n;
    if Value < -1.0 then Value := -1.0;
    if Value > 1.0 then Value := 1.0;
    THueAdjustEffect(Args[0].p).Hue := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'hueadjust_hue#: ' + E.Message);
  end;
end;

function n_hueadjust_hue_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_hue') then Exit;

  try
    Result.n := THueAdjustEffect(Args[0].p).Hue;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'hueadjust_hue: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_hueadjust_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_enabled#') then Exit;

  try
    THueAdjustEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'hueadjust_enabled#: ' + E.Message);
  end;
end;

function n_hueadjust_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_enabled') then Exit;

  try
    if THueAdjustEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'hueadjust_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_hueadjust_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_trigger#') then Exit;

  try
    THueAdjustEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'hueadjust_trigger#: ' + E.Message);
  end;
end;

function s_hueadjust_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'hueadjust_trigger$') then Exit;

  try
    Result.s := THueAdjustEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'hueadjust_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterHueAdjustEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_hueadjust_error; Lib.Add('hueadjust_error@', Fn);
  Fn.Entry := @s_hueadjust_errormsg; Lib.Add('hueadjust_errormsg$@', Fn);
  Fn.Entry := @s_hueadjust_strerror; Lib.Add('hueadjust_strerror$@n', Fn);
  Fn.Entry := @n_hueadjust_clearerror; Lib.Add('hueadjust_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_hueadjust_new; Lib.Add('hueadjust#@#', Fn);
  Fn.Entry := @n_hueadjust_free; Lib.Add('hueadjust_free@#', Fn);

  // Hue property
  Fn.Entry := @p_hueadjust_hue_set; Lib.Add('hueadjust_hue#@#n', Fn);
  Fn.Entry := @n_hueadjust_hue_get; Lib.Add('hueadjust_hue@#', Fn);

  // Enabled property
  Fn.Entry := @p_hueadjust_enabled_set; Lib.Add('hueadjust_enabled#@#n', Fn);
  Fn.Entry := @n_hueadjust_enabled_get; Lib.Add('hueadjust_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_hueadjust_trigger_set; Lib.Add('hueadjust_trigger#@#$', Fn);
  Fn.Entry := @s_hueadjust_trigger_get; Lib.Add('hueadjust_trigger$@#', Fn);
end;

end.
