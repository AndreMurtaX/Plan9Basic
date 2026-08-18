unit PixelateTransitionEffectLib;

{ ******************************************************************************
  PixelateTransitionEffectLib - Pixelate Transition Effect for Plan9Basic
  Version: 1.0.0 - Pixelate transition effect

  Function Count: 16 functions
  Copyright (c) 2024-2025 Plan9Basic Project
  ****************************************************************************** }

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  FMX.Graphics, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry;

procedure RegisterPixelateTransitionEffectFuncs(Lib: TFunctionsDictionary);

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
  if P = nil then
  begin
    SetError(ERR_NIL_EFFECT, FuncName);
    Exit;
  end;
  if not(IsHandleOf(P, TPixelateTransitionEffect)) then
  begin
    SetError(ERR_INVALID_EFFECT, FuncName);
    Exit;
  end;
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_NIL_PARENT, FuncName);
    Exit;
  end;
  if not(IsHandleOf(P, TFmxObject)) then
  begin
    SetError(ERR_INVALID_PARENT, FuncName);
    Exit;
  end;
  Result := True;
end;

function n_pixelatetrans_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.P := nil;
end;

function s_pixelatetrans_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.P := nil;
end;

function s_pixelatetrans_strerror(var Args: array of TAsmData): TAsmData;
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

function n_pixelatetrans_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
end;

function p_pixelatetrans_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TPixelateTransitionEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError;
  if not ValidateParent(Args[0].P, 'pixelatetrans#') then
    Exit;
  try
    Effect := TPixelateTransitionEffect.Create(TFmxObject(Args[0].P));
    Effect.Parent := TFmxObject(Args[0].P);
    Effect.Enabled := True;
    // GC.Add(Effect, IntToStr(NativeInt(Effect)));
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

function n_pixelatetrans_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TPixelateTransitionEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError;
  if not ValidateEffect(Args[0].P, 'pixelatetrans_free') then
    Exit;
  try
    Effect := TPixelateTransitionEffect(Args[0].P);
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'pixelatetrans_free: ' + E.Message);
  end;
end;

function p_pixelatetrans_progress_set(var Args: array of TAsmData): TAsmData;
var
  V: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError;
  if not ValidateEffect(Args[0].P, 'pixelatetrans_progress#') then
    Exit;
  try
    V := Args[1].n;
    if V <= 1.0 then
      V := V * 100;
    if V < 0 then
      V := 0;
    if V > 100 then
      V := 100;
    TPixelateTransitionEffect(Args[0].P).Progress := V;
    Result.P := Args[0].P;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, E.Message);
  end;
end;

function n_pixelatetrans_progress_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError;
  if not ValidateEffect(Args[0].P, 'pixelatetrans_progress') then
    Exit;
  try
    Result.n := TPixelateTransitionEffect(Args[0].P).Progress / 100;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, E.Message);
  end;
end;

function p_pixelatetrans_target_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError;
  if not ValidateEffect(Args[0].P, 'pixelatetrans_target#') then
    Exit;
  try
    if Args[1].P = nil then
    begin
      SetError(ERR_NIL_BITMAP, 'nil');
      Exit;
    end;
    TPixelateTransitionEffect(Args[0].P).Target.Assign(TBitmap(Args[1].P));
    Result.P := Args[0].P;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, E.Message);
  end;
end;

function p_pixelatetrans_target_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError;
  if not ValidateEffect(Args[0].P, 'pixelatetrans_target#') then
    Exit;
  try
    Result.P := TPixelateTransitionEffect(Args[0].P).Target;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, E.Message);
  end;
end;

function p_pixelatetrans_loadtarget(var Args: array of TAsmData): TAsmData;
var
  Effect: TPixelateTransitionEffect;
  Path: String;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError;
  if not ValidateEffect(Args[0].P, 'pixelatetrans_loadtarget#') then
    Exit;
  try
    Effect := TPixelateTransitionEffect(Args[0].P);
    Path := Args[1].s;
    if (Pos('http://', LowerCase(Path)) = 1) or (Pos('https://', LowerCase(Path)) = 1) then
    begin
      if not TUtils.LoadImageFromWeb(Path, Effect.Target) then
      begin
        SetError(ERR_LOAD_FAILED, 'URL');
        Exit;
      end;
    end
    else
    begin
      if FileExists(Path) then
        Effect.Target.LoadFromFile(Path)
      else
      begin
        SetError(ERR_LOAD_FAILED, 'file');
        Exit;
      end;
    end;
    Result.P := Args[0].P;
  except
    on E: Exception do
      SetError(ERR_LOAD_FAILED, E.Message);
  end;
end;

function p_pixelatetrans_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError;
  if not ValidateEffect(Args[0].P, 'pixelatetrans_enabled#') then
    Exit;
  try
    TPixelateTransitionEffect(Args[0].P).Enabled := Args[1].n <> 0;
    Result.P := Args[0].P;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, E.Message);
  end;
end;

function n_pixelatetrans_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.P := nil;
  ClearError;
  if not ValidateEffect(Args[0].P, 'pixelatetrans_enabled') then
    Exit;
  try
    if TPixelateTransitionEffect(Args[0].P).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, E.Message);
  end;
end;

procedure RegisterPixelateTransitionEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  Fn.Entry := @n_pixelatetrans_error; Lib.Add('pixelatetrans_error@', Fn);
  Fn.Entry := @s_pixelatetrans_errormsg; Lib.Add('pixelatetrans_errormsg$@', Fn);
  Fn.Entry := @s_pixelatetrans_strerror; Lib.Add('pixelatetrans_strerror$@n', Fn);
  Fn.Entry := @n_pixelatetrans_clearerror; Lib.Add('pixelatetrans_clearerror@', Fn);
  Fn.Entry := @p_pixelatetrans_new; Lib.Add('pixelatetrans#@#', Fn);
  Fn.Entry := @n_pixelatetrans_free; Lib.Add('pixelatetrans_free@#', Fn);
  Fn.Entry := @p_pixelatetrans_progress_set; Lib.Add('pixelatetrans_progress#@#n', Fn);
  Fn.Entry := @n_pixelatetrans_progress_get; Lib.Add('pixelatetrans_progress@#', Fn);
  Fn.Entry := @p_pixelatetrans_target_set; Lib.Add('pixelatetrans_target#@##', Fn);
  Fn.Entry := @p_pixelatetrans_target_get; Lib.Add('pixelatetrans_target#@#', Fn);
  Fn.Entry := @p_pixelatetrans_loadtarget; Lib.Add('pixelatetrans_loadtarget#@#$', Fn);
  Fn.Entry := @p_pixelatetrans_enabled_set; Lib.Add('pixelatetrans_enabled#@#n', Fn);
  Fn.Entry := @n_pixelatetrans_enabled_get; Lib.Add('pixelatetrans_enabled@#', Fn);
end;

end.
