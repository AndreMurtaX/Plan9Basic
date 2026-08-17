unit ShadowEffectLib;

{******************************************************************************
  ShadowEffectLib - Shadow Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TShadowEffect wrapper functionality for applying
  drop shadow effects to any visual control in Plan9Basic programs.

  Function Count: 26 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  EFFECT PROPERTIES:
  ==================
  - Distance: Shadow offset distance (0-50)
  - Direction: Shadow angle in degrees (0-360)
  - Softness: Shadow blur/spread (0.0-1.0)
  - Opacity: Shadow transparency (0.0-1.0)
  - ShadowColor: Color of the shadow

  USAGE PATTERN:
  ==============
    let frm# = form#("Shadow Demo", 400, 300)
    let btn# = button#(frm#, "Click Me")
    button_bounds#(btn#, 100, 100, 120, 40)

    ' Add drop shadow
    let shadow# = shadow#(btn#)
    shadow_distance#(shadow#, 5)
    shadow_direction#(shadow#, 45)
    shadow_softness#(shadow#, 0.4)
    shadow_color#(shadow#, "Gray")

    form_show(frm#)

  ANIMATED SHADOW EXAMPLE:
  ========================
    ' Animate shadow distance for "lift" effect on hover
    let ani# = floatani#(shadow#)
    floatani_propertyname#(ani#, "Distance")
    floatani_startvalue#(ani#, 3)
    floatani_stopvalue#(ani#, 10)
    floatani_duration#(ani#, 0.2)

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Effects,
  basic, exec, UnitGC, HandleRegistry;

type
  TBasShadowEffect = class(TShadowEffect)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
  end;

procedure RegisterShadowEffectFuncs(Lib: TFunctionsDictionary);

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
    Exit();
  end;
  if not (IsHandleOf(P, TBasShadowEffect)) then
  begin
    SetError(ERR_INVALID_EFFECT, FuncName + ': invalid shadow effect object');
    Exit();
  end;
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if not Assigned(P) then
  begin
    SetError(ERR_NIL_PARENT, FuncName + ': parent control is nil');
    Exit();
  end;
  if not (TObject(P) is TFmxObject) then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': invalid parent object');
    Exit();
  end;
  Result := True;
end;

// Helper to convert color name to TAlphaColor
function StringToAlphaColor(const ColorStr: String): TAlphaColor;
begin
  //Result := TAlphaColorRec.Black; // Default
  try
    // Try parsing as hex first (e.g., "$FF000000" or "#FF000000")
    if (Length(ColorStr) > 0) and ((ColorStr[1] = '$') or (ColorStr[1] = '#')) then
    begin
      if ColorStr[1] = '#' then
        Result := TAlphaColor(StrToInt64('$' + Copy(ColorStr, 2, Length(ColorStr) - 1)))
      else
        Result := TAlphaColor(StrToInt64(ColorStr));
    end
    else
    begin
      // Try as color name
      Result := StringToAlphaColor(ColorStr);
    end;
  except
    Result := TAlphaColorRec.Black;
  end;
end;

// =============================================================================
// TBasShadowEffect Implementation
// =============================================================================

constructor TBasShadowEffect.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);
  // Set sensible defaults
  Distance := 3;
  Direction := 45;
  Softness := 0.3;
  Opacity := 0.6;
  ShadowColor := TAlphaColorRec.Black;
  Enabled := True;
end;

destructor TBasShadowEffect.Destroy();
begin
  UnregisterHandle(Self);
  inherited Destroy();
end;

// =============================================================================
// Error Functions
// =============================================================================

function n_shadow_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_shadow_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_shadow_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE:           Result.s := 'No error';
    ERR_NIL_EFFECT:     Result.s := 'Effect is nil';
    ERR_INVALID_EFFECT: Result.s := 'Invalid shadow effect object';
    ERR_INVALID_VALUE:  Result.s := 'Invalid value';
    ERR_NIL_PARENT:     Result.s := 'Parent control is nil';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent object';
    ERR_INVALID_COLOR:  Result.s := 'Invalid color value';
  else
    Result.s := 'Unknown error: ' + IntToStr(Code);
  end;
end;

function n_shadow_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation / Destruction
// =============================================================================

function p_shadow_new(var Args: array of TAsmData): TAsmData;
var
  ParentObj: TFmxObject;
  Effect: TBasShadowEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'shadow#') then Exit();

  try
    ParentObj := TFmxObject(Args[0].p);
    Effect := TBasShadowEffect.Create(ParentObj);
    Effect.Parent := ParentObj;

    // GC registration removed - parent ownership handles cleanup
    // if Assigned(UnitGC.GC) then
    //   UnitGC.GC.Add<TBasShadowEffect>(Effect, IntToStr(NativeInt(Effect)));

    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow#: ' + E.Message);
  end;
end;

function n_shadow_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TBasShadowEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_free') then Exit();

  try
    Effect := TBasShadowEffect(Args[0].p);

    // GC collection removed - use direct Free instead
    // if Assigned(UnitGC.GC) then
    //   UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));

    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_free: ' + E.Message);
  end;
end;

// =============================================================================
// Distance Property
// =============================================================================

function p_shadow_distance_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_distance#') then Exit();

  try
    Value := Args[1].n;
    // Clamp to valid range
    if Value < 0 then Value := 0;
    if Value > 50 then Value := 50;

    TBasShadowEffect(Args[0].p).Distance := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_distance#: ' + E.Message);
  end;
end;

function n_shadow_distance_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_distance') then Exit();

  try
    Result.n := TBasShadowEffect(Args[0].p).Distance;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_distance: ' + E.Message);
  end;
end;

// =============================================================================
// Direction Property
// =============================================================================

function p_shadow_direction_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_direction#') then Exit();

  try
    Value := Args[1].n;
    // Normalize angle to 0-360
    while Value < 0 do Value := Value + 360;
    while Value >= 360 do Value := Value - 360;

    TBasShadowEffect(Args[0].p).Direction := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_direction#: ' + E.Message);
  end;
end;

function n_shadow_direction_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_direction') then Exit();

  try
    Result.n := TBasShadowEffect(Args[0].p).Direction;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_direction: ' + E.Message);
  end;
end;

// =============================================================================
// Softness Property
// =============================================================================

function p_shadow_softness_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_softness#') then Exit();

  try
    Value := Args[1].n;
    // Clamp to valid range
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;

    TBasShadowEffect(Args[0].p).Softness := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_softness#: ' + E.Message);
  end;
end;

function n_shadow_softness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_softness') then Exit();

  try
    Result.n := TBasShadowEffect(Args[0].p).Softness;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_softness: ' + E.Message);
  end;
end;

// =============================================================================
// Opacity Property
// =============================================================================

function p_shadow_opacity_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_opacity#') then Exit();

  try
    Value := Args[1].n;
    // Clamp to valid range
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;

    TBasShadowEffect(Args[0].p).Opacity := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_opacity#: ' + E.Message);
  end;
end;

function n_shadow_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_opacity') then Exit();

  try
    Result.n := TBasShadowEffect(Args[0].p).Opacity;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_opacity: ' + E.Message);
  end;
end;

// =============================================================================
// ShadowColor Property
// =============================================================================

function p_shadow_color_set(var Args: array of TAsmData): TAsmData;
var
  ColorVal: TAlphaColor;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_color#') then Exit();

  try
    ColorVal := StringToAlphaColor(Args[1].s);
    TBasShadowEffect(Args[0].p).ShadowColor := ColorVal;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_COLOR, 'shadow_color#: ' + E.Message);
  end;
end;

function n_shadow_color_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_color') then Exit();

  try
    Result.n := TBasShadowEffect(Args[0].p).ShadowColor;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_color: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_shadow_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_enabled#') then Exit();

  try
    TBasShadowEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_enabled#: ' + E.Message);
  end;
end;

function n_shadow_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_enabled') then Exit();

  try
    if TBasShadowEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_shadow_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_trigger#') then Exit();

  try
    TBasShadowEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_trigger#: ' + E.Message);
  end;
end;

function s_shadow_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'shadow_trigger$') then Exit();

  try
    Result.s := TBasShadowEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'shadow_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterShadowEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_shadow_error; Lib.Add('shadow_error@', Fn);
  Fn.Entry := @s_shadow_errormsg; Lib.Add('shadow_errormsg$@', Fn);
  Fn.Entry := @s_shadow_strerror; Lib.Add('shadow_strerror$@n', Fn);
  Fn.Entry := @n_shadow_clearerror; Lib.Add('shadow_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_shadow_new; Lib.Add('shadow#@#', Fn);
  Fn.Entry := @n_shadow_free; Lib.Add('shadow_free@#', Fn);

  // Distance property
  Fn.Entry := @p_shadow_distance_set; Lib.Add('shadow_distance#@#n', Fn);
  Fn.Entry := @n_shadow_distance_get; Lib.Add('shadow_distance@#', Fn);

  // Direction property
  Fn.Entry := @p_shadow_direction_set; Lib.Add('shadow_direction#@#n', Fn);
  Fn.Entry := @n_shadow_direction_get; Lib.Add('shadow_direction@#', Fn);

  // Softness property
  Fn.Entry := @p_shadow_softness_set; Lib.Add('shadow_softness#@#n', Fn);
  Fn.Entry := @n_shadow_softness_get; Lib.Add('shadow_softness@#', Fn);

  // Opacity property
  Fn.Entry := @p_shadow_opacity_set; Lib.Add('shadow_opacity#@#n', Fn);
  Fn.Entry := @n_shadow_opacity_get; Lib.Add('shadow_opacity@#', Fn);

  // ShadowColor property
  Fn.Entry := @p_shadow_color_set; Lib.Add('shadow_color#@#$', Fn);
  Fn.Entry := @n_shadow_color_get; Lib.Add('shadow_color@#', Fn);

  // Enabled property
  Fn.Entry := @p_shadow_enabled_set; Lib.Add('shadow_enabled#@#n', Fn);
  Fn.Entry := @n_shadow_enabled_get; Lib.Add('shadow_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_shadow_trigger_set; Lib.Add('shadow_trigger#@#$', Fn);
  Fn.Entry := @s_shadow_trigger_get; Lib.Add('shadow_trigger$@#', Fn);
end;

end.

