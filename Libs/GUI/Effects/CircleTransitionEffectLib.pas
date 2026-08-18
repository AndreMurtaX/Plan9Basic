unit CircleTransitionEffectLib;

{******************************************************************************
  CircleTransitionEffectLib - Circle Transition Effect Library for Plan9Basic
  Version: 1.2.0 - Fixed Progress range (0-1 normalized, internally 0-100)

  Provides FireMonkey TCircleTransitionEffect wrapper for creating circular
  wipe transitions on visual controls.

  Function Count: 20 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PROPERTIES:
  ===========
  - Progress: Transition progress (0.0-1.0, default 0)
  - FuzzyAmount: Edge softness (0-1, default 0.1)
  - CircleSize: Circle size factor (0-2, default 1)
  - Target: Secondary bitmap to transition TO (REQUIRED for visible transition!)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  IMPORTANT:
  ==========
  Transition effects require TWO images:
  1. The source image (parent control's bitmap)
  2. The TARGET bitmap (what it transitions to)
  
  Without setting Target, the effect transitions to transparent/nothing!

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  FMX.Graphics, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry;

procedure RegisterCircleTransitionEffectFuncs(Lib: TFunctionsDictionary);

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
  ERR_LOAD_FAILED = 6;
  ERR_NIL_BITMAP = 7;

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
  if not (IsHandleOf(P, TCircleTransitionEffect)) then
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

function n_circletrans_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_circletrans_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_circletrans_strerror(var Args: array of TAsmData): TAsmData;
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
    ERR_LOAD_FAILED: Result.s := 'Failed to load target image';
    ERR_NIL_BITMAP: Result.s := 'Bitmap is nil';
  else
    Result.s := 'Unknown error code: ' + IntToStr(Code);
  end;
end;

function n_circletrans_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_circletrans_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TCircleTransitionEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'circletrans#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TCircleTransitionEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.Progress := 0;
    Effect.FuzzyAmount := 0.1;
    Effect.CircleSize := 1;
    Effect.Center := PointF(0.5, 0.5);
    
    //UnitGC.GC.Add<TCircleTransitionEffect>(Effect, IntToStr(NativeInt(Effect)));
    
    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'circletrans#: ' + E.Message);
  end;
end;

function n_circletrans_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TCircleTransitionEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_free') then Exit;

  try
    Effect := TCircleTransitionEffect(Args[0].p);
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'circletrans_free: ' + E.Message);
  end;
end;

// =============================================================================
// Target Property - CRITICAL for transitions to work!
// =============================================================================

// Set target from a TBitmap pointer
function p_circletrans_target_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TCircleTransitionEffect;
  Bitmap: TBitmap;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_target#') then Exit;

  try
    Effect := TCircleTransitionEffect(Args[0].p);
    
    if Args[1].p = nil then
      Effect.Target.SetSize(0, 0)
    else if TObject(Args[1].p) is TBitmap then
    begin
      Bitmap := TBitmap(Args[1].p);
      Effect.Target.Assign(Bitmap);
    end
    else
    begin
      SetError(ERR_NIL_BITMAP, 'circletrans_target#: invalid bitmap');
      Exit;
    end;
    
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'circletrans_target#: ' + E.Message);
  end;
end;

// Get target bitmap pointer
function p_circletrans_target_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_target') then Exit;

  try
    Result.p := TCircleTransitionEffect(Args[0].p).Target;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'circletrans_target: ' + E.Message);
  end;
end;

// Load target from file path or URL
function p_circletrans_loadtarget(var Args: array of TAsmData): TAsmData;
var
  Effect: TCircleTransitionEffect;
  Path: String;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_loadtarget#') then Exit;

  try
    Effect := TCircleTransitionEffect(Args[0].p);
    Path := Args[1].s;
    
    if Path = '' then
    begin
      SetError(ERR_INVALID_VALUE, 'circletrans_loadtarget#: empty path');
      Exit;
    end;
    
    // Check if URL or file path
    if (Pos('http://', LowerCase(Path)) = 1) or (Pos('https://', LowerCase(Path)) = 1) then
    begin
      // Load from URL using TUtils.LoadImageFromWeb
      if not TUtils.LoadImageFromWeb(Path, Effect.Target) then
      begin
        SetError(ERR_LOAD_FAILED, 'circletrans_loadtarget#: failed to load from URL');
        Exit;
      end;
    end
    else
    begin
      // Load from file
      if FileExists(Path) then
        Effect.Target.LoadFromFile(Path)
      else
      begin
        SetError(ERR_LOAD_FAILED, 'circletrans_loadtarget#: file not found');
        Exit;
      end;
    end;
    
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_LOAD_FAILED, 'circletrans_loadtarget#: ' + E.Message);
  end;
end;

// Copy target from an Image control's bitmap
function p_circletrans_targetfromimage(var Args: array of TAsmData): TAsmData;
var
  Effect: TCircleTransitionEffect;
  Img: TImage;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_targetfromimage#') then Exit;

  try
    Effect := TCircleTransitionEffect(Args[0].p);
    
    if not Assigned(Args[1].p) then
    begin
      SetError(ERR_NIL_BITMAP, 'circletrans_targetfromimage#: image is nil');
      Exit;
    end;
    
    if not (TObject(Args[1].p) is TImage) then
    begin
      SetError(ERR_INVALID_VALUE, 'circletrans_targetfromimage#: not an image control');
      Exit;
    end;
    
    Img := TImage(Args[1].p);
    Effect.Target.Assign(Img.Bitmap);
    
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'circletrans_targetfromimage#: ' + E.Message);
  end;
end;

// =============================================================================
// Progress Property (0-100 percentage)
// User passes 0.0-1.0 (normalized), we convert to 0-100 for FireMonkey
// =============================================================================

function p_circletrans_progress_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_progress#') then Exit;

  try
    Value := Args[1].n;
    
    // User passes 0-1 (normalized), convert to 0-100 for FireMonkey
    if Value <= 1.0 then
      Value := Value * 100;
    
    // Clamp to valid range
    if Value < 0 then Value := 0;
    if Value > 100 then Value := 100;
    
    TCircleTransitionEffect(Args[0].p).Progress := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'circletrans_progress#: ' + E.Message);
  end;
end;

function n_circletrans_progress_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_progress') then Exit;

  try
    // Return normalized value (0-1) to user
    Result.n := TCircleTransitionEffect(Args[0].p).Progress / 100;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'circletrans_progress: ' + E.Message);
  end;
end;

// =============================================================================
// FuzzyAmount Property (0 - 1)
// =============================================================================

function p_circletrans_fuzzy_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_fuzzy#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    TCircleTransitionEffect(Args[0].p).FuzzyAmount := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'circletrans_fuzzy#: ' + E.Message);
  end;
end;

function n_circletrans_fuzzy_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_fuzzy') then Exit;

  try
    Result.n := TCircleTransitionEffect(Args[0].p).FuzzyAmount;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'circletrans_fuzzy: ' + E.Message);
  end;
end;

// =============================================================================
// CircleSize Property (0 - 2)
// =============================================================================

function p_circletrans_circlesize_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_circlesize#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 2 then Value := 2;
    TCircleTransitionEffect(Args[0].p).CircleSize := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'circletrans_circlesize#: ' + E.Message);
  end;
end;

function n_circletrans_circlesize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_circlesize') then Exit;

  try
    Result.n := TCircleTransitionEffect(Args[0].p).CircleSize;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'circletrans_circlesize: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_circletrans_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_enabled#') then Exit;

  try
    TCircleTransitionEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'circletrans_enabled#: ' + E.Message);
  end;
end;

function n_circletrans_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_enabled') then Exit;

  try
    if TCircleTransitionEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'circletrans_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_circletrans_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_trigger#') then Exit;

  try
    TCircleTransitionEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'circletrans_trigger#: ' + E.Message);
  end;
end;

function s_circletrans_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'circletrans_trigger$') then Exit;

  try
    Result.s := TCircleTransitionEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'circletrans_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterCircleTransitionEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_circletrans_error; Lib.Add('circletrans_error@', Fn);
  Fn.Entry := @s_circletrans_errormsg; Lib.Add('circletrans_errormsg$@', Fn);
  Fn.Entry := @s_circletrans_strerror; Lib.Add('circletrans_strerror$@n', Fn);
  Fn.Entry := @n_circletrans_clearerror; Lib.Add('circletrans_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_circletrans_new; Lib.Add('circletrans#@#', Fn);
  Fn.Entry := @n_circletrans_free; Lib.Add('circletrans_free@#', Fn);

  // Target property - CRITICAL for transitions!
  Fn.Entry := @p_circletrans_target_set; Lib.Add('circletrans_target#@##', Fn);
  Fn.Entry := @p_circletrans_target_get; Lib.Add('circletrans_target#@#', Fn);
  Fn.Entry := @p_circletrans_loadtarget; Lib.Add('circletrans_loadtarget#@#$', Fn);
  Fn.Entry := @p_circletrans_targetfromimage; Lib.Add('circletrans_targetfromimage#@##', Fn);

  // Progress property
  Fn.Entry := @p_circletrans_progress_set; Lib.Add('circletrans_progress#@#n', Fn);
  Fn.Entry := @n_circletrans_progress_get; Lib.Add('circletrans_progress@#', Fn);

  // FuzzyAmount property
  Fn.Entry := @p_circletrans_fuzzy_set; Lib.Add('circletrans_fuzzy#@#n', Fn);
  Fn.Entry := @n_circletrans_fuzzy_get; Lib.Add('circletrans_fuzzy@#', Fn);

  // CircleSize property
  Fn.Entry := @p_circletrans_circlesize_set; Lib.Add('circletrans_circlesize#@#n', Fn);
  Fn.Entry := @n_circletrans_circlesize_get; Lib.Add('circletrans_circlesize@#', Fn);

  // Enabled property
  Fn.Entry := @p_circletrans_enabled_set; Lib.Add('circletrans_enabled#@#n', Fn);
  Fn.Entry := @n_circletrans_enabled_get; Lib.Add('circletrans_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_circletrans_trigger_set; Lib.Add('circletrans_trigger#@#$', Fn);
  Fn.Entry := @s_circletrans_trigger_get; Lib.Add('circletrans_trigger$@#', Fn);
end;

end.
