unit RotateCrumpleTransitionEffectLib;

{ ******************************************************************************
  RotateCrumpleTransitionEffectLib - Rotate Crumple Transition for Plan9Basic
  Version: 1.0.0 - Rotating crumple transition effect

  Function Count: 18 functions
  Copyright (c) 2024-2025 Plan9Basic Project
  ****************************************************************************** }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  FMX.Graphics, FMX.Objects,
  basic, exec, UnitGC, UnitUtils;

procedure RegisterRotateCrumpleTransitionEffectFuncs(Lib: TFunctionsDictionary);

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

procedure ClearError();
begin
  LastError := ERR_NONE;
  LastErrorMsg := '';
end;

function ValidateEffect(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_NIL_EFFECT, FuncName);
    Exit();
  end;
  if not(TObject(P) is TRotateCrumpleTransitionEffect) then
  begin
    SetError(ERR_INVALID_EFFECT, FuncName);
    Exit();
  end;
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_NIL_PARENT, FuncName);
    Exit();
  end;
  if not(TObject(P) is TFmxObject) then
  begin
    SetError(ERR_INVALID_PARENT, FuncName);
    Exit();
  end;
  Result := True;
end;

function n_rotatecrumpletrans_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.P := nil;
end;

function s_rotatecrumpletrans_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.P := nil;
end;

function s_rotatecrumpletrans_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.P := nil;
  case Trunc(Args[0].n) of
    ERR_NONE: Result.s := 'No error';
    ERR_NIL_EFFECT: Result.s := 'Effect nil';
    ERR_INVALID_EFFECT: Result.s := 'Invalid';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_NIL_PARENT: Result.s := 'Parent nil';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_LOAD_FAILED: Result.s := 'Load failed';
    ERR_NIL_BITMAP: Result.s := 'Bitmap nil';
  else
    Result.s := 'Unknown';
  end;
end;

function n_rotatecrumpletrans_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
end;

function p_rotatecrumpletrans_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TRotateCrumpleTransitionEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateParent(Args[0].P, 'rotcrumpletrans#') then
    Exit();
  try
    Effect := TRotateCrumpleTransitionEffect.Create(TFmxObject(Args[0].P));
    Effect.Parent := TFmxObject(Args[0].P);
    Effect.Enabled := True;
    //GC.Add(Effect, IntToStr(NativeInt(Effect)));
    Result.P := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, E.Message);
  end;
end;

function n_rotatecrumpletrans_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TRotateCrumpleTransitionEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'rotcrumpletrans_free') then
    Exit();
  try
    Effect := TRotateCrumpleTransitionEffect(Args[0].P);
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'rotcrumpletrans_free: ' + E.Message);
  end;
end;

function p_rotatecrumpletrans_progress_set(var Args: array of TAsmData): TAsmData;
var
  V: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'rotcrumpletrans_progress#') then
    Exit();
  try
    V := Args[1].n;
    if V <= 1.0 then
      V := V * 100;
    if V < 0 then
      V := 0;
    if V > 100 then
      V := 100;
    TRotateCrumpleTransitionEffect(Args[0].P).Progress := V;
    Result.P := Args[0].P;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, E.Message);
  end;
end;

function n_rotatecrumpletrans_progress_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'rotcrumpletrans_progress') then
    Exit();
  try
    Result.n := TRotateCrumpleTransitionEffect(Args[0].P).Progress / 100;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, E.Message);
  end;
end;

function p_rotatecrumpletrans_target_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'rotcrumpletrans_target#') then
    Exit();
  try
    if Args[1].P = nil then
    begin
      SetError(ERR_NIL_BITMAP, 'nil');
      Exit();
    end;
    TRotateCrumpleTransitionEffect(Args[0].P).Target.Assign(TBitmap(Args[1].P));
    Result.P := Args[0].P;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, E.Message);
  end;
end;

function p_rotatecrumpletrans_target_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'rotcrumpletrans_target#') then
    Exit();
  try
    Result.P := TRotateCrumpleTransitionEffect(Args[0].P).Target;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, E.Message);
  end;
end;

function p_rotatecrumpletrans_loadtarget(var Args: array of TAsmData): TAsmData;
var
  Effect: TRotateCrumpleTransitionEffect;
  Path: String;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'rotcrumpletrans_loadtarget#') then
    Exit();
  try
    Effect := TRotateCrumpleTransitionEffect(Args[0].P);
    Path := Args[1].s;
    if (Pos('http://', LowerCase(Path)) = 1) or (Pos('https://', LowerCase(Path)) = 1) then
    begin
      if not TUtils.LoadImageFromWeb(Path, Effect.Target) then
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

function p_rotatecrumpletrans_randomseed_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'rotcrumpletrans_randomseed#') then
    Exit();
  try
    TRotateCrumpleTransitionEffect(Args[0].P).RandomSeed := Args[1].n;
    Result.P := Args[0].P;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, E.Message);
  end;
end;

function n_rotatecrumpletrans_randomseed_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'rotcrumpletrans_randomseed') then
    Exit();
  try
    Result.n := TRotateCrumpleTransitionEffect(Args[0].P).RandomSeed;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, E.Message);
  end;
end;

function p_rotatecrumpletrans_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'rotcrumpletrans_enabled#') then
    Exit();
  try
    TRotateCrumpleTransitionEffect(Args[0].P).Enabled := Args[1].n <> 0;
    Result.P := Args[0].P;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, E.Message);
  end;
end;

function n_rotatecrumpletrans_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError();
  if not ValidateEffect(Args[0].P, 'rotcrumpletrans_enabled') then
    Exit();
  try
    if TRotateCrumpleTransitionEffect(Args[0].P).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, E.Message);
  end;
end;

procedure RegisterRotateCrumpleTransitionEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  Fn.Entry := @n_rotatecrumpletrans_error; Lib.Add('rotcrumpletrans_error@', Fn);
  Fn.Entry := @s_rotatecrumpletrans_errormsg; Lib.Add('rotcrumpletrans_errormsg$@', Fn);
  Fn.Entry := @s_rotatecrumpletrans_strerror; Lib.Add('rotcrumpletrans_strerror$@n', Fn);
  Fn.Entry := @n_rotatecrumpletrans_clearerror; Lib.Add('rotcrumpletrans_clearerror@', Fn);
  Fn.Entry := @p_rotatecrumpletrans_new; Lib.Add('rotcrumpletrans#@#', Fn);
  Fn.Entry := @n_rotatecrumpletrans_free; Lib.Add('rotcrumpletrans_free@#', Fn);
  Fn.Entry := @p_rotatecrumpletrans_progress_set; Lib.Add('rotcrumpletrans_progress#@#n', Fn);
  Fn.Entry := @n_rotatecrumpletrans_progress_get; Lib.Add('rotcrumpletrans_progress@#', Fn);
  Fn.Entry := @p_rotatecrumpletrans_target_set; Lib.Add('rotcrumpletrans_target#@##', Fn);
  Fn.Entry := @p_rotatecrumpletrans_target_get; Lib.Add('rotcrumpletrans_target#@#', Fn);
  Fn.Entry := @p_rotatecrumpletrans_loadtarget; Lib.Add('rotcrumpletrans_loadtarget#@#$', Fn);
  Fn.Entry := @p_rotatecrumpletrans_randomseed_set; Lib.Add('rotcrumpletrans_randomseed#@#n', Fn);
  Fn.Entry := @n_rotatecrumpletrans_randomseed_get; Lib.Add('rotcrumpletrans_randomseed@#', Fn);
  Fn.Entry := @p_rotatecrumpletrans_enabled_set; Lib.Add('rotcrumpletrans_enabled#@#n', Fn);
  Fn.Entry := @n_rotatecrumpletrans_enabled_get; Lib.Add('rotcrumpletrans_enabled@#', Fn);
end;

end.
