unit SwipeTransitionEffectLib;

{******************************************************************************
  SwipeTransitionEffectLib - Swipe Transition Effect Library for Plan9Basic
  Version: 1.4.0 - MousePoint now uses PIXEL coordinates (as per FireMonkey docs)

  Provides FireMonkey TSwipeTransitionEffect wrapper for creating page-fold
  swipe transitions on visual controls.

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
  - MousePointX/Y: Point where page corner is pulled to (PIXEL coordinates!)
    Default is (5,5). Example: (210, 60) for a typical effect.
  - Deep: Amount of folding (0-100, default 20)
  - Target: Bitmap revealed UNDER the folded page
  - Back: Bitmap shown on the BACK of the folded page (optional)
  - CornerPoint: Which corner the page folds FROM (default 0,0 = top-left)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  HOW IT WORKS:
  =============
  - The page corner is at CornerPoint (default top-left)
  - MousePoint controls where the corner is "pulled" to
  - The fold occurs between CornerPoint and MousePoint
  - Deep controls how much the page curls/folds
  - Target shows what's underneath when the page lifts
  - Back shows what's on the back of the page itself

  ANIMATION:
  ==========
  Animate MousePoint along a diagonal path from corner to opposite corner
  to create a page-turn animation effect.

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  FMX.Graphics, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, EffectCommon;

procedure RegisterSwipeTransitionEffectFuncs(Lib: TFunctionsDictionary);

implementation

var
  //One error slot for this library, shared shape in EffectCommon.
  Err: TEffectErrors;

const
  ERR_LOAD_FAILED = 6;
  ERR_NIL_BITMAP = 7;

procedure SetError(Code: Integer; const Msg: String);
begin
  Err.SetErr(Code, Msg);
end;

procedure ClearError();
begin
  Err.Clear();
end;

function ValidateEffect(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateEffect(P, TSwipeTransitionEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_swipetrans_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_swipetrans_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_swipetrans_strerror(var Args: array of TAsmData): TAsmData;
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

function n_swipetrans_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_swipetrans_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TSwipeTransitionEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'swipetrans#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TSwipeTransitionEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.MousePoint := PointF(5, 5);
    Effect.Deep := 20;
    
    //UnitGC.GC.Add<TSwipeTransitionEffect>(Effect, IntToStr(NativeInt(Effect)));
    
    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swipetrans#: ' + E.Message);
  end;
end;

function n_swipetrans_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TSwipeTransitionEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_free') then Exit;

  try
    Effect := TSwipeTransitionEffect(Args[0].p);
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'swipetrans_free: ' + E.Message);
  end;
end;

// =============================================================================
// MousePointX Property (PIXEL coordinates)
// Controls the X position where the page corner is being "pulled" to
// The fold occurs between CornerPoint and MousePoint
// =============================================================================

function p_swipetrans_mousex_set(var Args: array of TAsmData): TAsmData;
var
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_mousex#') then Exit;

  try
    // MousePoint uses PIXEL coordinates directly
    Pt := TSwipeTransitionEffect(Args[0].p).MousePoint;
    Pt.X := Args[1].n;
    TSwipeTransitionEffect(Args[0].p).MousePoint := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swipetrans_mousex#: ' + E.Message);
  end;
end;

function n_swipetrans_mousex_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_mousex') then Exit;

  try
    Result.n := TSwipeTransitionEffect(Args[0].p).MousePoint.X;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'swipetrans_mousex: ' + E.Message);
  end;
end;

// =============================================================================
// MousePointY Property (PIXEL coordinates)
// Controls the Y position where the page corner is being "pulled" to
// =============================================================================

function p_swipetrans_mousey_set(var Args: array of TAsmData): TAsmData;
var
  Pt: TPointF;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_mousey#') then Exit;

  try
    // MousePoint uses PIXEL coordinates directly
    Pt := TSwipeTransitionEffect(Args[0].p).MousePoint;
    Pt.Y := Args[1].n;
    TSwipeTransitionEffect(Args[0].p).MousePoint := Pt;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swipetrans_mousey#: ' + E.Message);
  end;
end;

function n_swipetrans_mousey_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_mousey') then Exit;

  try
    Result.n := TSwipeTransitionEffect(Args[0].p).MousePoint.Y;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'swipetrans_mousey: ' + E.Message);
  end;
end;

// =============================================================================
// Deep Property (0 - 100)
// =============================================================================

function p_swipetrans_deep_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_deep#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0 then Value := 0;
    if Value > 100 then Value := 100;
    TSwipeTransitionEffect(Args[0].p).Deep := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swipetrans_deep#: ' + E.Message);
  end;
end;

function n_swipetrans_deep_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_deep') then Exit;

  try
    Result.n := TSwipeTransitionEffect(Args[0].p).Deep;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'swipetrans_deep: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_swipetrans_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_enabled#') then Exit;

  try
    TSwipeTransitionEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swipetrans_enabled#: ' + E.Message);
  end;
end;

function n_swipetrans_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_enabled') then Exit;

  try
    if TSwipeTransitionEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'swipetrans_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_swipetrans_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_trigger#') then Exit;

  try
    TSwipeTransitionEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swipetrans_trigger#: ' + E.Message);
  end;
end;

function s_swipetrans_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_trigger$') then Exit;

  try
    Result.s := TSwipeTransitionEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'swipetrans_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Target Property (TBitmap - the image to transition TO)
// =============================================================================

function p_swipetrans_target_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TSwipeTransitionEffect;
  SourceBitmap: TBitmap;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_target#') then Exit;

  try
    Effect := TSwipeTransitionEffect(Args[0].p);
    
    if Args[1].p = nil then
    begin
      SetError(ERR_NIL_BITMAP, 'swipetrans_target#: bitmap is nil');
      Exit;
    end;
    
    SourceBitmap := TBitmap(Args[1].p);
    Effect.Target.Assign(SourceBitmap);
    
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swipetrans_target#: ' + E.Message);
  end;
end;

function p_swipetrans_target_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_target#') then Exit;

  try
    Result.p := TSwipeTransitionEffect(Args[0].p).Target;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'swipetrans_target#: ' + E.Message);
  end;
end;

// =============================================================================
// Target Load from File or URL
// =============================================================================

function p_swipetrans_loadtarget(var Args: array of TAsmData): TAsmData;
var
  Effect: TSwipeTransitionEffect;
  Path: String;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_loadtarget#') then Exit;

  try
    Effect := TSwipeTransitionEffect(Args[0].p);
    Path := Args[1].s;
    
    // Check if URL or file path
    if (Pos('http://', LowerCase(Path)) = 1) or (Pos('https://', LowerCase(Path)) = 1) then
    begin
      // Load from URL using TUtils.LoadImageFromWeb
      if not TUtils.LoadImageFromWeb(Path, Effect.Target) then
      begin
        SetError(ERR_LOAD_FAILED, 'swipetrans_loadtarget#: failed to load from URL');
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
        SetError(ERR_LOAD_FAILED, 'swipetrans_loadtarget#: file not found');
        Exit;
      end;
    end;
    
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_LOAD_FAILED, 'swipetrans_loadtarget#: ' + E.Message);
  end;
end;

// =============================================================================
// Target from TImage
// =============================================================================

function p_swipetrans_targetfromimage(var Args: array of TAsmData): TAsmData;
var
  Effect: TSwipeTransitionEffect;
  SourceImage: TImage;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'swipetrans_targetfromimage#') then Exit;

  try
    Effect := TSwipeTransitionEffect(Args[0].p);
    
    if Args[1].p = nil then
    begin
      SetError(ERR_NIL_BITMAP, 'swipetrans_targetfromimage#: image is nil');
      Exit;
    end;
    
    if not (TObject(Args[1].p) is TImage) then
    begin
      SetError(ERR_INVALID_VALUE, 'swipetrans_targetfromimage#: not a TImage');
      Exit;
    end;
    
    SourceImage := TImage(Args[1].p);
    Effect.Target.Assign(SourceImage.Bitmap);
    
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'swipetrans_targetfromimage#: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterSwipeTransitionEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_swipetrans_error; Lib.Add('swipetrans_error@', Fn);
  Fn.Entry := @s_swipetrans_errormsg; Lib.Add('swipetrans_errormsg$@', Fn);
  Fn.Entry := @s_swipetrans_strerror; Lib.Add('swipetrans_strerror$@n', Fn);
  Fn.Entry := @n_swipetrans_clearerror; Lib.Add('swipetrans_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_swipetrans_new; Lib.Add('swipetrans#@#', Fn);
  Fn.Entry := @n_swipetrans_free; Lib.Add('swipetrans_free@#', Fn);

  // MousePointX property
  Fn.Entry := @p_swipetrans_mousex_set; Lib.Add('swipetrans_mousex#@#n', Fn);
  Fn.Entry := @n_swipetrans_mousex_get; Lib.Add('swipetrans_mousex@#', Fn);

  // MousePointY property
  Fn.Entry := @p_swipetrans_mousey_set; Lib.Add('swipetrans_mousey#@#n', Fn);
  Fn.Entry := @n_swipetrans_mousey_get; Lib.Add('swipetrans_mousey@#', Fn);

  // Deep property
  Fn.Entry := @p_swipetrans_deep_set; Lib.Add('swipetrans_deep#@#n', Fn);
  Fn.Entry := @n_swipetrans_deep_get; Lib.Add('swipetrans_deep@#', Fn);

  // Enabled property
  Fn.Entry := @p_swipetrans_enabled_set; Lib.Add('swipetrans_enabled#@#n', Fn);
  Fn.Entry := @n_swipetrans_enabled_get; Lib.Add('swipetrans_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_swipetrans_trigger_set; Lib.Add('swipetrans_trigger#@#$', Fn);
  Fn.Entry := @s_swipetrans_trigger_get; Lib.Add('swipetrans_trigger$@#', Fn);

  // Target property (bitmap to transition TO)
  Fn.Entry := @p_swipetrans_target_set; Lib.Add('swipetrans_target#@##', Fn);
  Fn.Entry := @p_swipetrans_target_get; Lib.Add('swipetrans_target#@#', Fn);
  Fn.Entry := @p_swipetrans_loadtarget; Lib.Add('swipetrans_loadtarget#@#$', Fn);
  Fn.Entry := @p_swipetrans_targetfromimage; Lib.Add('swipetrans_targetfromimage#@##', Fn);
end;

end.
