unit ColorKeyAlphaEffectLib;

{******************************************************************************
  ColorKeyAlphaEffectLib - Color Key Alpha Effect Library for Plan9Basic
  Version: 1.0.2

  Provides FireMonkey TColorKeyAlphaEffect wrapper for making specific colors
  transparent in visual controls.

  Function Count: 14 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  FEATURES:
  =========
  - Makes any specified color transparent
  - Adjustable tolerance for color matching
  - GPU-accelerated rendering
  - Trigger support for conditional activation
  - Perfect for image background removal

  PROPERTIES:
  ===========
  - ColorKey: Color to make transparent (TAlphaColor, default varies)
  - Tolerance: How similar colors must be (0.0-1.0, default: 0.0)
               IMPORTANT: If Tolerance is 0, NO color becomes transparent!
  - Enabled: Turn effect on/off (default: on)
  - Trigger: Conditional activation string

  COLOR FORMAT:
  =============
  Colors can be specified as:
  - Named colors: "Red", "Green", "Blue", "Lime", "White", "Black", etc.
  - Hex RGB: "#RRGGBB" (e.g., "#00FF00" for green)
  - Hex ARGB: "#AARRGGBB" (e.g., "#FF00FF00")

  MEMORY MANAGEMENT:
  ==================
  GC registration removed - parent ownership handles cleanup.
  Using GC caused Access Violations due to double-free when parent
  controls were destroyed.

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry;

procedure RegisterColorKeyAlphaEffectFuncs(Lib: TFunctionsDictionary);

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
  ERR_INVALID_COLOR = 6;

// =============================================================================
// Error Handling
// =============================================================================

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
  if not (IsHandleOf(P, TColorKeyAlphaEffect)) then
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

function n_colorkey_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_colorkey_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_colorkey_strerror(var Args: array of TAsmData): TAsmData;
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
    ERR_INVALID_COLOR: Result.s := 'Invalid color value';
  else
    Result.s := 'Unknown error code: ' + IntToStr(Code);
  end;
end;

function n_colorkey_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_colorkey_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TColorKeyAlphaEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'colorkey#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TColorKeyAlphaEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    // Use FireMonkey defaults for ColorKey and Tolerance

    // GC registration removed - parent ownership handles cleanup
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.

    //Torna este efeito um handle validavel sem dereferenciar o
    //ponteiro que o programa BASIC devolver. A baixa e automatica:
    //o efeito pertence ao pai, e o registry escuta FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorkey#: ' + E.Message);
  end;
end;

function n_colorkey_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TColorKeyAlphaEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'colorkey_free') then Exit;

  try
    Effect := TColorKeyAlphaEffect(Args[0].p);
    // Direct Free - GC removed to prevent double-free
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'colorkey_free: ' + E.Message);
  end;
end;

// =============================================================================
// ColorKey Property (TAlphaColor - the color to make transparent)
// =============================================================================

function p_colorkey_color_set(var Args: array of TAsmData): TAsmData;
var
  ColorValue: TAlphaColor;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'colorkey_color#') then Exit;

  try
    // Convert string to TAlphaColor using TUtils helper
    ColorValue := TUtils.ColorToAlphaColor(Args[1].s);
    TColorKeyAlphaEffect(Args[0].p).ColorKey := ColorValue;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_COLOR, 'colorkey_color#: ' + E.Message);
  end;
end;

function s_colorkey_color_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'colorkey_color$') then Exit;

  try
    Result.s := TUtils.AlphaColorToStr(TColorKeyAlphaEffect(Args[0].p).ColorKey);
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'colorkey_color$: ' + E.Message);
  end;
end;

// =============================================================================
// Tolerance Property (0.0 - 1.0)
// IMPORTANT: If Tolerance is 0, NO color becomes transparent!
// =============================================================================

function p_colorkey_tolerance_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'colorkey_tolerance#') then Exit;

  try
    Value := Args[1].n;
    // Clamp to valid range 0.0-1.0
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;
    TColorKeyAlphaEffect(Args[0].p).Tolerance := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorkey_tolerance#: ' + E.Message);
  end;
end;

function n_colorkey_tolerance_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'colorkey_tolerance') then Exit;

  try
    Result.n := TColorKeyAlphaEffect(Args[0].p).Tolerance;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'colorkey_tolerance: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_colorkey_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'colorkey_enabled#') then Exit;

  try
    TColorKeyAlphaEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorkey_enabled#: ' + E.Message);
  end;
end;

function n_colorkey_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'colorkey_enabled') then Exit;

  try
    if TColorKeyAlphaEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'colorkey_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_colorkey_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'colorkey_trigger#') then Exit;

  try
    TColorKeyAlphaEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'colorkey_trigger#: ' + E.Message);
  end;
end;

function s_colorkey_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'colorkey_trigger$') then Exit;

  try
    Result.s := TColorKeyAlphaEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'colorkey_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterColorKeyAlphaEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_colorkey_error; Lib.Add('colorkey_error@', Fn);
  Fn.Entry := @s_colorkey_errormsg; Lib.Add('colorkey_errormsg$@', Fn);
  Fn.Entry := @s_colorkey_strerror; Lib.Add('colorkey_strerror$@n', Fn);
  Fn.Entry := @n_colorkey_clearerror; Lib.Add('colorkey_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_colorkey_new; Lib.Add('colorkey#@#', Fn);
  Fn.Entry := @n_colorkey_free; Lib.Add('colorkey_free@#', Fn);

  // ColorKey property (TAlphaColor as string)
  Fn.Entry := @p_colorkey_color_set; Lib.Add('colorkey_color#@#$', Fn);
  Fn.Entry := @s_colorkey_color_get; Lib.Add('colorkey_color$@#', Fn);

  // Tolerance property (0.0-1.0)
  Fn.Entry := @p_colorkey_tolerance_set; Lib.Add('colorkey_tolerance#@#n', Fn);
  Fn.Entry := @n_colorkey_tolerance_get; Lib.Add('colorkey_tolerance@#', Fn);

  // Enabled property
  Fn.Entry := @p_colorkey_enabled_set; Lib.Add('colorkey_enabled#@#n', Fn);
  Fn.Entry := @n_colorkey_enabled_get; Lib.Add('colorkey_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_colorkey_trigger_set; Lib.Add('colorkey_trigger#@#$', Fn);
  Fn.Entry := @s_colorkey_trigger_get; Lib.Add('colorkey_trigger$@#', Fn);
end;

end.
