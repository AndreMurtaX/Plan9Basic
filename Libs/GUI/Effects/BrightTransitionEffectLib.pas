unit BrightTransitionEffectLib;

{******************************************************************************
  BrightTransitionEffectLib - Bright Transition Effect for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TBrightTransitionEffect wrapper for creating
  brightness-based transitions between two images.

  Function Count: 16 functions

  Copyright (c) 2024-2026 André Murta
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  FMX.Graphics, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, EffectCommon, GuiUtils;

procedure RegisterBrightTransitionEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TBrightTransitionEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

function n_brighttrans_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_brighttrans_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_brighttrans_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil;
  case Trunc(Args[0].n) of
    ERR_NONE: Result.s := 'No error'; ERR_NIL_EFFECT: Result.s := 'Effect is nil';
    ERR_INVALID_EFFECT: Result.s := 'Invalid effect'; ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_NIL_PARENT: Result.s := 'Parent is nil'; ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_LOAD_FAILED: Result.s := 'Load failed'; ERR_NIL_BITMAP: Result.s := 'Bitmap is nil';
  else Result.s := 'Unknown error'; end;
end;

function n_brighttrans_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

function p_brighttrans_new(var Args: array of TAsmData): TAsmData;
var Effect: TBrightTransitionEffect;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateParent(Args[0].p, 'brighttrans#') then Exit;
  try
    Effect := TBrightTransitionEffect.Create(TFmxObject(Args[0].p));
    Effect.Parent := TFmxObject(Args[0].p); Effect.Enabled := True;
    // GC registration removed - parent ownership handles cleanup
    // GC.Add(Effect, IntToStr(NativeInt(Effect)));
    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'brighttrans#: ' + E.Message); end;
end;

function n_brighttrans_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TBrightTransitionEffect;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'brighttrans_free') then Exit;
  try
    Effect := TBrightTransitionEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except on E: Exception do SetError(ERR_INVALID_EFFECT, 'brighttrans_free: ' + E.Message); end;
end;

function p_brighttrans_progress_set(var Args: array of TAsmData): TAsmData;
var Value: Single;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'brighttrans_progress#') then Exit;
  try
    Value := Args[1].n;
    //The documented range is 0 to 1; FireMonkey's property is 0 to 100.
    //This used to multiply by 100 only when the value was at most 1, so
    //progress#(e, 1) meant 100% and progress#(e, 2) meant 2%.
    if Value < 0 then Value := 0;
    if Value > 1 then Value := 1;
    Value := Value * 100;
    TBrightTransitionEffect(Args[0].p).Progress := Value; Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'brighttrans_progress#: ' + E.Message); end;
end;

function n_brighttrans_progress_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'brighttrans_progress') then Exit;
  try Result.n := TBrightTransitionEffect(Args[0].p).Progress / 100;
  except on E: Exception do SetError(ERR_INVALID_EFFECT, 'brighttrans_progress: ' + E.Message); end;
end;

function p_brighttrans_target_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'brighttrans_target#') then Exit;
  try
    if Args[1].p = nil then begin SetError(ERR_NIL_BITMAP, 'brighttrans_target#: bitmap is nil'); Exit; end;
    TBrightTransitionEffect(Args[0].p).Target.Assign(TBitmap(Args[1].p)); Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'brighttrans_target#: ' + E.Message); end;
end;

function p_brighttrans_target_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'brighttrans_target#') then Exit;
  try Result.p := TBrightTransitionEffect(Args[0].p).Target;
  except on E: Exception do SetError(ERR_INVALID_EFFECT, 'brighttrans_target#: ' + E.Message); end;
end;

function p_brighttrans_loadtarget(var Args: array of TAsmData): TAsmData;
var Effect: TBrightTransitionEffect; Path: String;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'brighttrans_loadtarget#') then Exit;
  try
    Effect := TBrightTransitionEffect(Args[0].p); Path := Args[1].s;
    if (Pos('http://', LowerCase(Path)) = 1) or (Pos('https://', LowerCase(Path)) = 1) then
    begin if not TGuiUtils.LoadImageFromWeb(Path, Effect.Target) then begin SetError(ERR_LOAD_FAILED, 'brighttrans_loadtarget#: URL load failed'); Exit; end; end
    else begin if FileExists(Path) then Effect.Target.LoadFromFile(Path) else begin SetError(ERR_LOAD_FAILED, 'brighttrans_loadtarget#: file not found'); Exit; end; end;
    Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_LOAD_FAILED, 'brighttrans_loadtarget#: ' + E.Message); end;
end;

function p_brighttrans_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'brighttrans_enabled#') then Exit;
  try TBrightTransitionEffect(Args[0].p).Enabled := Args[1].n <> 0; Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'brighttrans_enabled#: ' + E.Message); end;
end;

function n_brighttrans_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'brighttrans_enabled') then Exit;
  try if TBrightTransitionEffect(Args[0].p).Enabled then Result.n := 1 else Result.n := 0;
  except on E: Exception do SetError(ERR_INVALID_EFFECT, 'brighttrans_enabled: ' + E.Message); end;
end;

procedure RegisterBrightTransitionEffectFuncs(Lib: TFunctionsDictionary);
var Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;
  Fn.Entry := @n_brighttrans_error; Lib.Add('brighttrans_error@', Fn);
  Fn.Entry := @s_brighttrans_errormsg; Lib.Add('brighttrans_errormsg$@', Fn);
  Fn.Entry := @s_brighttrans_strerror; Lib.Add('brighttrans_strerror$@n', Fn);
  Fn.Entry := @n_brighttrans_clearerror; Lib.Add('brighttrans_clearerror@', Fn);
  Fn.Entry := @p_brighttrans_new; Lib.Add('brighttrans#@#', Fn);
  Fn.Entry := @n_brighttrans_free; Lib.Add('brighttrans_free@#', Fn);
  Fn.Entry := @p_brighttrans_progress_set; Lib.Add('brighttrans_progress#@#n', Fn);
  Fn.Entry := @n_brighttrans_progress_get; Lib.Add('brighttrans_progress@#', Fn);
  Fn.Entry := @p_brighttrans_target_set; Lib.Add('brighttrans_target#@##', Fn);
  Fn.Entry := @p_brighttrans_target_get; Lib.Add('brighttrans_target#@#', Fn);
  Fn.Entry := @p_brighttrans_loadtarget; Lib.Add('brighttrans_loadtarget#@#$', Fn);
  Fn.Entry := @p_brighttrans_enabled_set; Lib.Add('brighttrans_enabled#@#n', Fn);
  Fn.Entry := @n_brighttrans_enabled_get; Lib.Add('brighttrans_enabled@#', Fn);
end;

end.
