unit BrightTransitionEffectLib;

{******************************************************************************
  BrightTransitionEffectLib - Bright Transition Effect for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TBrightTransitionEffect wrapper for creating
  brightness-based transitions between two images.

  Function Count: 16 functions

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  FMX.Graphics, FMX.Objects,
  basic, exec, UnitGC, UnitUtils;

procedure RegisterBrightTransitionEffectFuncs(Lib: TFunctionsDictionary);

implementation

var
  LastError: Integer = 0;
  LastErrorMsg: String = '';

const
  ERR_NONE = 0; ERR_NIL_EFFECT = 1; ERR_INVALID_EFFECT = 2;
  ERR_INVALID_VALUE = 3; ERR_NIL_PARENT = 4; ERR_INVALID_PARENT = 5;
  ERR_LOAD_FAILED = 6; ERR_NIL_BITMAP = 7;

procedure SetError(Code: Integer; const Msg: String);
begin LastError := Code; LastErrorMsg := Msg; end;

procedure ClearError;
begin LastError := ERR_NONE; LastErrorMsg := ''; end;

function ValidateEffect(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then begin SetError(ERR_NIL_EFFECT, FuncName + ': effect is nil'); Exit; end;
  if not (TObject(P) is TBrightTransitionEffect) then begin SetError(ERR_INVALID_EFFECT, FuncName + ': invalid type'); Exit; end;
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then begin SetError(ERR_NIL_PARENT, FuncName + ': parent is nil'); Exit; end;
  if not (TObject(P) is TFmxObject) then begin SetError(ERR_INVALID_PARENT, FuncName + ': invalid parent'); Exit; end;
  Result := True;
end;

function n_brighttrans_error(var Args: array of TAsmData): TAsmData;
begin Result.n := LastError; Result.s := ''; Result.p := nil; end;

function s_brighttrans_errormsg(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := LastErrorMsg; Result.p := nil; end;

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
begin ClearError; Result.n := 0; Result.s := ''; Result.p := nil; end;

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
    Value := Args[1].n; if Value <= 1.0 then Value := Value * 100;
    if Value < 0 then Value := 0; if Value > 100 then Value := 100;
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
    begin if not TUtils.LoadImageFromWeb(Path, Effect.Target) then begin SetError(ERR_LOAD_FAILED, 'brighttrans_loadtarget#: URL load failed'); Exit; end; end
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
