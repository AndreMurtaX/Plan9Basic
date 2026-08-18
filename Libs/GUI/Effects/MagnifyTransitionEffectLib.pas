unit MagnifyTransitionEffectLib;

{******************************************************************************
  MagnifyTransitionEffectLib - Magnify Transition Effect for Plan9Basic
  Version: 1.0.0 - Magnify zoom transition effect

  Function Count: 20 functions
  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  FMX.Graphics, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, EffectCommon, GuiUtils;

procedure RegisterMagnifyTransitionEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TMagnifyTransitionEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

function n_magnifytrans_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_magnifytrans_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_magnifytrans_strerror(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.p := nil;
  case Trunc(Args[0].n) of ERR_NONE: Result.s := 'No error'; ERR_NIL_EFFECT: Result.s := 'Effect nil';
    ERR_INVALID_EFFECT: Result.s := 'Invalid effect'; ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_NIL_PARENT: Result.s := 'Parent nil'; ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_LOAD_FAILED: Result.s := 'Load failed'; ERR_NIL_BITMAP: Result.s := 'Bitmap nil'; else Result.s := 'Unknown'; end;
end;

function n_magnifytrans_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

function p_magnifytrans_new(var Args: array of TAsmData): TAsmData;
var Effect: TMagnifyTransitionEffect;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateParent(Args[0].p, 'magnifytrans#') then Exit;
  try Effect := TMagnifyTransitionEffect.Create(TFmxObject(Args[0].p));
    Effect.Parent := TFmxObject(Args[0].p); Effect.Enabled := True;
    // GC.Add(Effect, IntToStr(NativeInt(Effect)));
    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except on E: Exception do SetError(ERR_INVALID_VALUE, E.Message); end;
end;

function n_magnifytrans_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TMagnifyTransitionEffect;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'magnifytrans_free') then Exit;
  try
    Effect := TMagnifyTransitionEffect(Args[0].p);
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except on E: Exception do SetError(ERR_INVALID_EFFECT, 'magnifytrans_free: ' + E.Message); end;
end;

function p_magnifytrans_progress_set(var Args: array of TAsmData): TAsmData;
var V: Single;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'magnifytrans_progress#') then Exit;
  try V := Args[1].n; if V <= 1.0 then V := V * 100; if V < 0 then V := 0; if V > 100 then V := 100;
    TMagnifyTransitionEffect(Args[0].p).Progress := V; Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, E.Message); end;
end;

function n_magnifytrans_progress_get(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'magnifytrans_progress') then Exit;
  try Result.n := TMagnifyTransitionEffect(Args[0].p).Progress / 100; except on E: Exception do SetError(ERR_INVALID_EFFECT, E.Message); end;
end;

function p_magnifytrans_target_set(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'magnifytrans_target#') then Exit;
  try if Args[1].p = nil then begin SetError(ERR_NIL_BITMAP, 'nil'); Exit; end;
    TMagnifyTransitionEffect(Args[0].p).Target.Assign(TBitmap(Args[1].p)); Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, E.Message); end;
end;

function p_magnifytrans_target_get(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'magnifytrans_target#') then Exit;
  try Result.p := TMagnifyTransitionEffect(Args[0].p).Target; except on E: Exception do SetError(ERR_INVALID_EFFECT, E.Message); end;
end;

function p_magnifytrans_loadtarget(var Args: array of TAsmData): TAsmData;
var Effect: TMagnifyTransitionEffect; Path: String;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'magnifytrans_loadtarget#') then Exit;
  try Effect := TMagnifyTransitionEffect(Args[0].p); Path := Args[1].s;
    if (Pos('http://', LowerCase(Path)) = 1) or (Pos('https://', LowerCase(Path)) = 1) then
    begin if not TGuiUtils.LoadImageFromWeb(Path, Effect.Target) then begin SetError(ERR_LOAD_FAILED, 'URL'); Exit; end; end
    else begin if FileExists(Path) then Effect.Target.LoadFromFile(Path) else begin SetError(ERR_LOAD_FAILED, 'file'); Exit; end; end;
    Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_LOAD_FAILED, E.Message); end;
end;

function p_magnifytrans_centerx_set(var Args: array of TAsmData): TAsmData;
var Pt: TPointF;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'magnifytrans_centerx#') then Exit;
  try Pt := TMagnifyTransitionEffect(Args[0].p).Center; Pt.X := Args[1].n;
    TMagnifyTransitionEffect(Args[0].p).Center := Pt; Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, E.Message); end;
end;

function n_magnifytrans_centerx_get(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'magnifytrans_centerx') then Exit;
  try Result.n := TMagnifyTransitionEffect(Args[0].p).Center.X; except on E: Exception do SetError(ERR_INVALID_EFFECT, E.Message); end;
end;

function p_magnifytrans_centery_set(var Args: array of TAsmData): TAsmData;
var Pt: TPointF;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'magnifytrans_centery#') then Exit;
  try Pt := TMagnifyTransitionEffect(Args[0].p).Center; Pt.Y := Args[1].n;
    TMagnifyTransitionEffect(Args[0].p).Center := Pt; Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, E.Message); end;
end;

function n_magnifytrans_centery_get(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'magnifytrans_centery') then Exit;
  try Result.n := TMagnifyTransitionEffect(Args[0].p).Center.Y; except on E: Exception do SetError(ERR_INVALID_EFFECT, E.Message); end;
end;

function p_magnifytrans_enabled_set(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'magnifytrans_enabled#') then Exit;
  try TMagnifyTransitionEffect(Args[0].p).Enabled := Args[1].n <> 0; Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, E.Message); end;
end;

function n_magnifytrans_enabled_get(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'magnifytrans_enabled') then Exit;
  try if TMagnifyTransitionEffect(Args[0].p).Enabled then Result.n := 1 else Result.n := 0;
  except on E: Exception do SetError(ERR_INVALID_EFFECT, E.Message); end;
end;

procedure RegisterMagnifyTransitionEffectFuncs(Lib: TFunctionsDictionary);
var Fn: TLinkFunction;
begin Fn.FarCall := True;
  Fn.Entry := @n_magnifytrans_error; Lib.Add('magnifytrans_error@', Fn);
  Fn.Entry := @s_magnifytrans_errormsg; Lib.Add('magnifytrans_errormsg$@', Fn);
  Fn.Entry := @s_magnifytrans_strerror; Lib.Add('magnifytrans_strerror$@n', Fn);
  Fn.Entry := @n_magnifytrans_clearerror; Lib.Add('magnifytrans_clearerror@', Fn);
  Fn.Entry := @p_magnifytrans_new; Lib.Add('magnifytrans#@#', Fn);
  Fn.Entry := @n_magnifytrans_free; Lib.Add('magnifytrans_free@#', Fn);
  Fn.Entry := @p_magnifytrans_progress_set; Lib.Add('magnifytrans_progress#@#n', Fn);
  Fn.Entry := @n_magnifytrans_progress_get; Lib.Add('magnifytrans_progress@#', Fn);
  Fn.Entry := @p_magnifytrans_target_set; Lib.Add('magnifytrans_target#@##', Fn);
  Fn.Entry := @p_magnifytrans_target_get; Lib.Add('magnifytrans_target#@#', Fn);
  Fn.Entry := @p_magnifytrans_loadtarget; Lib.Add('magnifytrans_loadtarget#@#$', Fn);
  Fn.Entry := @p_magnifytrans_centerx_set; Lib.Add('magnifytrans_centerx#@#n', Fn);
  Fn.Entry := @n_magnifytrans_centerx_get; Lib.Add('magnifytrans_centerx@#', Fn);
  Fn.Entry := @p_magnifytrans_centery_set; Lib.Add('magnifytrans_centery#@#n', Fn);
  Fn.Entry := @n_magnifytrans_centery_get; Lib.Add('magnifytrans_centery@#', Fn);
  Fn.Entry := @p_magnifytrans_enabled_set; Lib.Add('magnifytrans_enabled#@#n', Fn);
  Fn.Entry := @n_magnifytrans_enabled_get; Lib.Add('magnifytrans_enabled@#', Fn);
end;

end.
