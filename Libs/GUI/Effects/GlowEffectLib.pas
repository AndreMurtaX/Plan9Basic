unit GlowEffectLib;

{******************************************************************************
  GlowEffectLib - Glow Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TGlowEffect wrapper functionality for applying
  outer glow effects to any visual control in Plan9Basic programs.

  Function Count: 18 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  EFFECT PROPERTIES:
  ==================
  - Softness: Glow spread/blur (0.0-9.0)
  - GlowColor: Color of the glow
  - Opacity: Glow transparency (0.0-1.0)

  USAGE PATTERN:
  ==============
    let frm# = form#("Glow Demo", 400, 300)
    let btn# = button#(frm#, "Glowing Button")
    button_bounds#(btn#, 100, 100, 150, 40)

    ' Add outer glow
    let glow# = glow#(btn#)
    glow_color#(glow#, "Cyan")
    glow_softness#(glow#, 4.0)
    glow_opacity#(glow#, 0.8)

    form_show(frm#)

  ANIMATED GLOW (PULSING EFFECT):
  ===============================
    ' Create pulsing glow animation
    let ani# = floatani#(glow#)
    floatani_propertyname#(ani#, "Softness")
    floatani_startvalue#(ani#, 2.0)
    floatani_stopvalue#(ani#, 6.0)
    floatani_duration#(ani#, 1.0)
    floatani_autoreverse#(ani#, 1)
    floatani_loop#(ani#, 1)
    floatani_start(ani#)

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Effects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry;

type
  TBasGlowEffect = class(TGlowEffect)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
  end;

procedure RegisterGlowEffectFuncs(Lib: TFunctionsDictionary);

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
    Exit;
  end;
  if not (IsHandleOf(P, TBasGlowEffect)) then
  begin
    SetError(ERR_INVALID_EFFECT, FuncName + ': invalid glow effect object');
    Exit;
  end;
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if not Assigned(P) then
  begin
    SetError(ERR_NIL_PARENT, FuncName + ': parent control is nil');
    Exit;
  end;
  if not (TObject(P) is TFmxObject) then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': invalid parent object');
    Exit;
  end;
  Result := True;
end;

// =============================================================================
// TBasGlowEffect Implementation
// =============================================================================

constructor TBasGlowEffect.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);
  // Set sensible defaults for visible glow
  Softness := 4.0;
  GlowColor := TAlphaColorRec.Yellow;
  Opacity := 0.9;
  Enabled := True;
end;

destructor TBasGlowEffect.Destroy();
begin
  UnregisterHandle(Self);
  inherited Destroy();
end;

// =============================================================================
// Error Functions
// =============================================================================

function n_glow_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_glow_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_glow_strerror(var Args: array of TAsmData): TAsmData;
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
    ERR_INVALID_EFFECT: Result.s := 'Invalid glow effect object';
    ERR_INVALID_VALUE:  Result.s := 'Invalid value';
    ERR_NIL_PARENT:     Result.s := 'Parent control is nil';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent object';
    ERR_INVALID_COLOR:  Result.s := 'Invalid color value';
  else
    Result.s := 'Unknown error: ' + IntToStr(Code);
  end;
end;

function n_glow_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation / Destruction
// =============================================================================

function p_glow_new(var Args: array of TAsmData): TAsmData;
var
  ParentObj: TFmxObject;
  Effect: TBasGlowEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateParent(Args[0].p, 'glow#') then Exit;

  try
    ParentObj := TFmxObject(Args[0].p);
    Effect := TBasGlowEffect.Create(ParentObj);
    Effect.Parent := ParentObj;

    // GC registration removed - parent ownership handles cleanup
    // if Assigned(UnitGC.GC) then
    //   UnitGC.GC.Add<TBasGlowEffect>(Effect, IntToStr(NativeInt(Effect)));
    Result.p := Pointer(Effect);
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'glow#: ' + E.Message);
  end;
end;

function n_glow_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TBasGlowEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'glow_free') then Exit;

  try
    Effect := TBasGlowEffect(Args[0].p);

    // GC collection removed - use direct Free instead
    // if Assigned(UnitGC.GC) then
    //   UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));

    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'glow_free: ' + E.Message);
  end;
end;

// =============================================================================
// Softness Property
// =============================================================================

function p_glow_softness_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'glow_softness#') then Exit;

  try
    Value := Args[1].n;
    // Clamp to valid range
    if Value < 0.0 then Value := 0.0;
    if Value > 9.0 then Value := 9.0;

    TBasGlowEffect(Args[0].p).Softness := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'glow_softness#: ' + E.Message);
  end;
end;

function n_glow_softness_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'glow_softness') then Exit;

  try
    Result.n := TBasGlowEffect(Args[0].p).Softness;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'glow_softness: ' + E.Message);
  end;
end;

// =============================================================================
// GlowColor Property
// =============================================================================

function p_glow_color_set(var Args: array of TAsmData): TAsmData;
var
  ColorVal: TAlphaColor;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'glow_color#') then Exit;

  try
    ColorVal := TUtils.ColorToAlphaColor(Args[1].s);
    TBasGlowEffect(Args[0].p).GlowColor := ColorVal;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_COLOR, 'glow_color#: ' + E.Message);
  end;
end;

function n_glow_color_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'glow_color') then Exit;

  try
    Result.n := TBasGlowEffect(Args[0].p).GlowColor;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'glow_color: ' + E.Message);
  end;
end;

function s_glow_color_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'glow_color') then Exit;

  try
    Result.s := TUtils.AlphaColorToStr(TBasGlowEffect(Args[0].p).GlowColor);
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'glow_color: ' + E.Message);
  end;
end;

// =============================================================================
// Opacity Property
// =============================================================================

function p_glow_opacity_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'glow_opacity#') then Exit;

  try
    Value := Args[1].n;
    // Clamp to valid range
    if Value < 0.0 then Value := 0.0;
    if Value > 1.0 then Value := 1.0;

    TBasGlowEffect(Args[0].p).Opacity := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'glow_opacity#: ' + E.Message);
  end;
end;

function n_glow_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'glow_opacity') then Exit;

  try
    Result.n := TBasGlowEffect(Args[0].p).Opacity;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'glow_opacity: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_glow_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'glow_enabled#') then Exit;

  try
    TBasGlowEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'glow_enabled#: ' + E.Message);
  end;
end;

function n_glow_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'glow_enabled') then Exit;

  try
    if TBasGlowEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'glow_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_glow_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'glow_trigger#') then Exit;

  try
    TBasGlowEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'glow_trigger#: ' + E.Message);
  end;
end;

function s_glow_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  if not ValidateEffect(Args[0].p, 'glow_trigger$') then Exit;

  try
    Result.s := TBasGlowEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'glow_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterGlowEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_glow_error; Lib.Add('glow_error@', Fn);
  Fn.Entry := @s_glow_errormsg; Lib.Add('glow_errormsg$@', Fn);
  Fn.Entry := @s_glow_strerror; Lib.Add('glow_strerror$@n', Fn);
  Fn.Entry := @n_glow_clearerror; Lib.Add('glow_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_glow_new; Lib.Add('glow#@#', Fn);
  Fn.Entry := @n_glow_free; Lib.Add('glow_free@#', Fn);

  // Softness property
  Fn.Entry := @p_glow_softness_set; Lib.Add('glow_softness#@#n', Fn);
  Fn.Entry := @n_glow_softness_get; Lib.Add('glow_softness@#', Fn);

  // GlowColor property
  Fn.Entry := @p_glow_color_set; Lib.Add('glow_color#@#$', Fn);
  Fn.Entry := @n_glow_color_get; Lib.Add('glow_color@#', Fn);
  Fn.Entry := @s_glow_color_get; Lib.Add('glow_color$@#', Fn);

  // Opacity property
  Fn.Entry := @p_glow_opacity_set; Lib.Add('glow_opacity#@#n', Fn);
  Fn.Entry := @n_glow_opacity_get; Lib.Add('glow_opacity@#', Fn);

  // Enabled property
  Fn.Entry := @p_glow_enabled_set; Lib.Add('glow_enabled#@#n', Fn);
  Fn.Entry := @n_glow_enabled_get; Lib.Add('glow_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_glow_trigger_set; Lib.Add('glow_trigger#@#$', Fn);
  Fn.Entry := @s_glow_trigger_get; Lib.Add('glow_trigger$@#', Fn);
end;

end.
