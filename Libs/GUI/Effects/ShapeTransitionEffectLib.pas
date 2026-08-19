unit ShapeTransitionEffectLib;

{ ******************************************************************************
  ShapeTransitionEffectLib - Shape Transition Effect for Plan9Basic
  Version: 1.0.0 - Shape mask wipe transition effect

  Function Count: 18 functions (includes RandomSeed)
  Copyright (c) 2024-2025 Plan9Basic Project
  ****************************************************************************** }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  FMX.Graphics, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, EffectCommon, GuiUtils;

procedure RegisterShapeTransitionEffectFuncs(Lib: TFunctionsDictionary);

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
  Result := EffectCommon.ValidateEffect(P, TShapeTransitionEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

function n_shapetrans_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_shapetrans_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_shapetrans_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  case Trunc(Args[0].n) of
    ERR_NONE: Result.s := 'No error';
    ERR_NIL_EFFECT: Result.s := 'Effect nil';
    ERR_INVALID_EFFECT: Result.s := 'Invalid effect';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_NIL_PARENT: Result.s := 'Parent nil';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_LOAD_FAILED: Result.s := 'Load failed';
    ERR_NIL_BITMAP: Result.s := 'Bitmap nil';
  else
    Result.s := 'Unknown';
  end;
end;

function n_shapetrans_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

function p_shapetrans_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TShapeTransitionEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateParent(Args[0].P, 'shapetrans#') then
    Exit();
  try
    Effect := TShapeTransitionEffect.Create(TFmxObject(Args[0].P));
    Effect.Parent := TFmxObject(Args[0].P);
    Effect.Enabled := True;
    //GC.Add(Effect, IntToStr(NativeInt(Effect)));
    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.P := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, E.Message);
  end;
end;

function n_shapetrans_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TShapeTransitionEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'shapetrans_free') then
    Exit();
  try
    Effect := TShapeTransitionEffect(Args[0].P);
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'shapetrans_free: ' + E.Message);
  end;
end;

function p_shapetrans_progress_set(var Args: array of TAsmData): TAsmData;
var
  V: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'shapetrans_progress#') then
    Exit();
  try
    V := Args[1].n;
    //The documented range is 0 to 1; FireMonkey's property is 0 to 100.
    //This used to multiply by 100 only when the value was at most 1, so
    //progress#(e, 1) meant 100% and progress#(e, 2) meant 2%.
    if V < 0 then V := 0;
    if V > 1 then V := 1;
    V := V * 100;
    TShapeTransitionEffect(Args[0].P).Progress := V;
    Result.P := Args[0].P;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, E.Message);
  end;
end;

function n_shapetrans_progress_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'shapetrans_progress') then
    Exit();
  try
    Result.n := TShapeTransitionEffect(Args[0].P).Progress / 100;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, E.Message);
  end;
end;

function p_shapetrans_target_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'shapetrans_target#') then
    Exit();
  try
    if Args[1].P = nil then
    begin
      SetError(ERR_NIL_BITMAP, 'nil');
      Exit();
    end;
    TShapeTransitionEffect(Args[0].P).Target.Assign(TBitmap(Args[1].P));
    Result.P := Args[0].P;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, E.Message);
  end;
end;

function p_shapetrans_target_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'shapetrans_target#') then
    Exit();
  try
    Result.P := TShapeTransitionEffect(Args[0].P).Target;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, E.Message);
  end;
end;

function p_shapetrans_loadtarget(var Args: array of TAsmData): TAsmData;
var
  Effect: TShapeTransitionEffect;
  Path: String;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'shapetrans_loadtarget#') then
    Exit();
  try
    Effect := TShapeTransitionEffect(Args[0].P);
    Path := Args[1].s;
    if (Pos('http://', LowerCase(Path)) = 1) or (Pos('https://', LowerCase(Path)) = 1) then
    begin
      if not TGuiUtils.LoadImageFromWeb(Path, Effect.Target) then
      begin
        SetError(ERR_LOAD_FAILED, 'URL');
        Exit();
      end;
    end
    else
    begin
      if FileExists(Path) then
        Effect.Target.LoadFromFile(Path)
      else
      begin
        SetError(ERR_LOAD_FAILED, 'file');
        Exit();
      end;
    end;
    Result.P := Args[0].P;
  except
    on E: Exception do
      SetError(ERR_LOAD_FAILED, E.Message);
  end;
end;

function p_shapetrans_randomseed_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'shapetrans_randomseed#') then
    Exit();
  try
    TShapeTransitionEffect(Args[0].P).RandomSeed := Args[1].n;
    Result.P := Args[0].P;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, E.Message);
  end;
end;

function n_shapetrans_randomseed_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'shapetrans_randomseed') then
    Exit();
  try
    Result.n := TShapeTransitionEffect(Args[0].P).RandomSeed;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, E.Message);
  end;
end;

function p_shapetrans_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'shapetrans_enabled#') then
    Exit();
  try
    TShapeTransitionEffect(Args[0].P).Enabled := Args[1].n <> 0;
    Result.P := Args[0].P;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, E.Message);
  end;
end;

function n_shapetrans_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'shapetrans_enabled') then
    Exit();
  try
    if TShapeTransitionEffect(Args[0].P).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, E.Message);
  end;
end;

procedure RegisterShapeTransitionEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;
  Fn.Entry := @n_shapetrans_error; Lib.Add('shapetrans_error@', Fn);
  Fn.Entry := @s_shapetrans_errormsg; Lib.Add('shapetrans_errormsg$@', Fn);
  Fn.Entry := @s_shapetrans_strerror; Lib.Add('shapetrans_strerror$@n', Fn);
  Fn.Entry := @n_shapetrans_clearerror; Lib.Add('shapetrans_clearerror@', Fn);
  Fn.Entry := @p_shapetrans_new; Lib.Add('shapetrans#@#', Fn);
  Fn.Entry := @n_shapetrans_free; Lib.Add('shapetrans_free@#', Fn);
  Fn.Entry := @p_shapetrans_progress_set; Lib.Add('shapetrans_progress#@#n', Fn);
  Fn.Entry := @n_shapetrans_progress_get; Lib.Add('shapetrans_progress@#', Fn);
  Fn.Entry := @p_shapetrans_target_set; Lib.Add('shapetrans_target#@##', Fn);
  Fn.Entry := @p_shapetrans_target_get; Lib.Add('shapetrans_target#@#', Fn);
  Fn.Entry := @p_shapetrans_loadtarget; Lib.Add('shapetrans_loadtarget#@#$', Fn);
  Fn.Entry := @p_shapetrans_randomseed_set; Lib.Add('shapetrans_randomseed#@#n', Fn);
  Fn.Entry := @n_shapetrans_randomseed_get; Lib.Add('shapetrans_randomseed@#', Fn);
  Fn.Entry := @p_shapetrans_enabled_set; Lib.Add('shapetrans_enabled#@#n', Fn);
  Fn.Entry := @n_shapetrans_enabled_get; Lib.Add('shapetrans_enabled@#', Fn);
end;

end.
