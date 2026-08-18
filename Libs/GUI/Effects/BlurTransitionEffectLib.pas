unit BlurTransitionEffectLib;

{******************************************************************************
  BlurTransitionEffectLib - Blur Transition Effect for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TBlurTransitionEffect wrapper for creating
  blur-based transitions between two images.

  Function Count: 16 functions

  PROPERTIES:
  ===========
  - Progress: Transition progress (0.0-1.0, internally 0-100)
  - Target: Bitmap to transition TO
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  FMX.Graphics, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, EffectCommon;

procedure RegisterBlurTransitionEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TBlurTransitionEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// Error Handling
function n_blurtrans_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_blurtrans_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_blurtrans_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil;
  case Trunc(Args[0].n) of
    ERR_NONE: Result.s := 'No error';
    ERR_NIL_EFFECT: Result.s := 'Effect is nil';
    ERR_INVALID_EFFECT: Result.s := 'Invalid effect type';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_NIL_PARENT: Result.s := 'Parent is nil';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent type';
    ERR_LOAD_FAILED: Result.s := 'Failed to load image';
    ERR_NIL_BITMAP: Result.s := 'Bitmap is nil';
  else Result.s := 'Unknown error';
  end;
end;

function n_blurtrans_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// Creation/Destruction
function p_blurtrans_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TBlurTransitionEffect;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateParent(Args[0].p, 'blurtrans#') then Exit;
  try
    Effect := TBlurTransitionEffect.Create(TFmxObject(Args[0].p));
    Effect.Parent := TFmxObject(Args[0].p);
    Effect.Enabled := True;
    // GC registration removed - parent ownership handles cleanup
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    //GC.Add(Effect, IntToStr(NativeInt(Effect)));
    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'blurtrans#: ' + E.Message); end;
end;

function n_blurtrans_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TBlurTransitionEffect;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'blurtrans_free') then Exit;
  try
    Effect := TBlurTransitionEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except on E: Exception do SetError(ERR_INVALID_EFFECT, 'blurtrans_free: ' + E.Message); end;
end;

// Progress Property
function p_blurtrans_progress_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'blurtrans_progress#') then Exit;
  try
    Value := Args[1].n;
    if Value <= 1.0 then
      Value := Value * 100;
    if Value < 0 then
      Value := 0; if Value > 100 then Value := 100;
    TBlurTransitionEffect(Args[0].p).Progress := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'blurtrans_progress#: ' + E.Message);
  end;
end;

function n_blurtrans_progress_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'blurtrans_progress') then Exit;
  try Result.n := TBlurTransitionEffect(Args[0].p).Progress / 100;
  except on E: Exception do SetError(ERR_INVALID_EFFECT, 'blurtrans_progress: ' + E.Message); end;
end;

// Target Property
function p_blurtrans_target_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'blurtrans_target#') then Exit;
  try
    if Args[1].p = nil then begin SetError(ERR_NIL_BITMAP, 'blurtrans_target#: bitmap is nil'); Exit; end;
    TBlurTransitionEffect(Args[0].p).Target.Assign(TBitmap(Args[1].p));
    Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'blurtrans_target#: ' + E.Message); end;
end;

function p_blurtrans_target_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'blurtrans_target#') then Exit;
  try Result.p := TBlurTransitionEffect(Args[0].p).Target;
  except on E: Exception do SetError(ERR_INVALID_EFFECT, 'blurtrans_target#: ' + E.Message); end;
end;

function p_blurtrans_loadtarget(var Args: array of TAsmData): TAsmData;
var Effect: TBlurTransitionEffect; Path: String;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'blurtrans_loadtarget#') then Exit;
  try
    Effect := TBlurTransitionEffect(Args[0].p); Path := Args[1].s;
    if (Pos('http://', LowerCase(Path)) = 1) or (Pos('https://', LowerCase(Path)) = 1) then
    begin
      if not TUtils.LoadImageFromWeb(Path, Effect.Target) then
      begin SetError(ERR_LOAD_FAILED, 'blurtrans_loadtarget#: failed to load from URL'); Exit; end;
    end
    else begin
      if FileExists(Path) then Effect.Target.LoadFromFile(Path)
      else begin SetError(ERR_LOAD_FAILED, 'blurtrans_loadtarget#: file not found'); Exit; end;
    end;
    Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_LOAD_FAILED, 'blurtrans_loadtarget#: ' + E.Message); end;
end;

// Enabled Property
function p_blurtrans_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'blurtrans_enabled#') then Exit;
  try TBlurTransitionEffect(Args[0].p).Enabled := Args[1].n <> 0; Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'blurtrans_enabled#: ' + E.Message); end;
end;

function n_blurtrans_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'blurtrans_enabled') then Exit;
  try if TBlurTransitionEffect(Args[0].p).Enabled then Result.n := 1 else Result.n := 0;
  except on E: Exception do SetError(ERR_INVALID_EFFECT, 'blurtrans_enabled: ' + E.Message); end;
end;

// Registration
procedure RegisterBlurTransitionEffectFuncs(Lib: TFunctionsDictionary);
var Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  Fn.Entry := @n_blurtrans_error; Lib.Add('blurtrans_error@', Fn);
  Fn.Entry := @s_blurtrans_errormsg; Lib.Add('blurtrans_errormsg$@', Fn);
  Fn.Entry := @s_blurtrans_strerror; Lib.Add('blurtrans_strerror$@n', Fn);
  Fn.Entry := @n_blurtrans_clearerror; Lib.Add('blurtrans_clearerror@', Fn);
  Fn.Entry := @p_blurtrans_new; Lib.Add('blurtrans#@#', Fn);
  Fn.Entry := @n_blurtrans_free; Lib.Add('blurtrans_free@#', Fn);
  Fn.Entry := @p_blurtrans_progress_set; Lib.Add('blurtrans_progress#@#n', Fn);
  Fn.Entry := @n_blurtrans_progress_get; Lib.Add('blurtrans_progress@#', Fn);
  Fn.Entry := @p_blurtrans_target_set; Lib.Add('blurtrans_target#@##', Fn);
  Fn.Entry := @p_blurtrans_target_get; Lib.Add('blurtrans_target#@#', Fn);
  Fn.Entry := @p_blurtrans_loadtarget; Lib.Add('blurtrans_loadtarget#@#$', Fn);
  Fn.Entry := @p_blurtrans_enabled_set; Lib.Add('blurtrans_enabled#@#n', Fn);
  Fn.Entry := @n_blurtrans_enabled_get; Lib.Add('blurtrans_enabled@#', Fn);
end;

end.
