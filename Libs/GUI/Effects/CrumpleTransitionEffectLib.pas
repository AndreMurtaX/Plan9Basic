unit CrumpleTransitionEffectLib;

{******************************************************************************
  CrumpleTransitionEffectLib - Crumple Transition Effect for Plan9Basic
  Version: 1.0.0 - Paper crumple transition effect

  Function Count: 16 functions
  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  FMX.Graphics, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry;

procedure RegisterCrumpleTransitionEffectFuncs(Lib: TFunctionsDictionary);

implementation

var LastError: Integer = 0; LastErrorMsg: String = '';

const
  ERR_NONE = 0; ERR_NIL_EFFECT = 1; ERR_INVALID_EFFECT = 2; ERR_INVALID_VALUE = 3;
  ERR_NIL_PARENT = 4; ERR_INVALID_PARENT = 5; ERR_LOAD_FAILED = 6; ERR_NIL_BITMAP = 7;

procedure SetError(Code: Integer; const Msg: String); begin LastError := Code; LastErrorMsg := Msg; end;
procedure ClearError; begin LastError := ERR_NONE; LastErrorMsg := ''; end;

function ValidateEffect(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then begin SetError(ERR_NIL_EFFECT, FuncName + ': nil'); Exit; end;
  if not (IsHandleOf(P, TCrumpleTransitionEffect)) then begin SetError(ERR_INVALID_EFFECT, FuncName + ': invalid'); Exit; end;
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then begin SetError(ERR_NIL_PARENT, FuncName + ': nil'); Exit; end;
  if not (IsHandleOf(P, TFmxObject)) then begin SetError(ERR_INVALID_PARENT, FuncName + ': invalid'); Exit; end;
  Result := True;
end;

function n_crumpletrans_error(var Args: array of TAsmData): TAsmData;
begin Result.n := LastError; Result.s := ''; Result.p := nil; end;

function s_crumpletrans_errormsg(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := LastErrorMsg; Result.p := nil; end;

function s_crumpletrans_strerror(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.p := nil;
  case Trunc(Args[0].n) of ERR_NONE: Result.s := 'No error'; ERR_NIL_EFFECT: Result.s := 'Effect nil';
    ERR_INVALID_EFFECT: Result.s := 'Invalid effect'; ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_NIL_PARENT: Result.s := 'Parent nil'; ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_LOAD_FAILED: Result.s := 'Load failed'; ERR_NIL_BITMAP: Result.s := 'Bitmap nil'; else Result.s := 'Unknown'; end;
end;

function n_crumpletrans_clearerror(var Args: array of TAsmData): TAsmData;
begin ClearError; Result.n := 0; Result.s := ''; Result.p := nil; end;

function p_crumpletrans_new(var Args: array of TAsmData): TAsmData;
var Effect: TCrumpleTransitionEffect;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateParent(Args[0].p, 'crumpletrans#') then Exit;
  try
    Effect := TCrumpleTransitionEffect.Create(TFmxObject(Args[0].p));
    Effect.Parent := TFmxObject(Args[0].p);
    Effect.Enabled := True;
    //GC.Add(Effect, IntToStr(NativeInt(Effect)));
    //Torna este efeito um handle validavel sem dereferenciar o
    //ponteiro que o programa BASIC devolver. A baixa e automatica:
    //o efeito pertence ao pai, e o registry escuta FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except on E: Exception do SetError(ERR_INVALID_VALUE, E.Message); end;
end;

function n_crumpletrans_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TCrumpleTransitionEffect;
begin
  Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'crumpletrans_free') then Exit;
  try
    Effect := TCrumpleTransitionEffect(Args[0].p);
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except on E: Exception do SetError(ERR_INVALID_EFFECT, 'crumpletrans_free: ' + E.Message); end;
end;

function p_crumpletrans_progress_set(var Args: array of TAsmData): TAsmData;
var V: Single;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'crumpletrans_progress#') then Exit;
  try V := Args[1].n; if V <= 1.0 then V := V * 100; if V < 0 then V := 0; if V > 100 then V := 100;
    TCrumpleTransitionEffect(Args[0].p).Progress := V; Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, E.Message); end;
end;

function n_crumpletrans_progress_get(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'crumpletrans_progress') then Exit;
  try Result.n := TCrumpleTransitionEffect(Args[0].p).Progress / 100; except on E: Exception do SetError(ERR_INVALID_EFFECT, E.Message); end;
end;

function p_crumpletrans_target_set(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'crumpletrans_target#') then Exit;
  try if Args[1].p = nil then begin SetError(ERR_NIL_BITMAP, 'nil'); Exit; end;
    TCrumpleTransitionEffect(Args[0].p).Target.Assign(TBitmap(Args[1].p)); Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, E.Message); end;
end;

function p_crumpletrans_target_get(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'crumpletrans_target#') then Exit;
  try Result.p := TCrumpleTransitionEffect(Args[0].p).Target; except on E: Exception do SetError(ERR_INVALID_EFFECT, E.Message); end;
end;

function p_crumpletrans_loadtarget(var Args: array of TAsmData): TAsmData;
var Effect: TCrumpleTransitionEffect; Path: String;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'crumpletrans_loadtarget#') then Exit;
  try Effect := TCrumpleTransitionEffect(Args[0].p); Path := Args[1].s;
    if (Pos('http://', LowerCase(Path)) = 1) or (Pos('https://', LowerCase(Path)) = 1) then
    begin if not TUtils.LoadImageFromWeb(Path, Effect.Target) then begin SetError(ERR_LOAD_FAILED, 'URL'); Exit; end; end
    else begin if FileExists(Path) then Effect.Target.LoadFromFile(Path) else begin SetError(ERR_LOAD_FAILED, 'file'); Exit; end; end;
    Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_LOAD_FAILED, E.Message); end;
end;

function p_crumpletrans_randomseed_set(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'crumpletrans_randomseed#') then Exit;
  try TCrumpleTransitionEffect(Args[0].p).RandomSeed := Args[1].n; Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, E.Message); end;
end;

function n_crumpletrans_randomseed_get(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'crumpletrans_randomseed') then Exit;
  try Result.n := TCrumpleTransitionEffect(Args[0].p).RandomSeed; except on E: Exception do SetError(ERR_INVALID_EFFECT, E.Message); end;
end;

function p_crumpletrans_enabled_set(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'crumpletrans_enabled#') then Exit;
  try TCrumpleTransitionEffect(Args[0].p).Enabled := Args[1].n <> 0; Result.p := Args[0].p;
  except on E: Exception do SetError(ERR_INVALID_VALUE, E.Message); end;
end;

function n_crumpletrans_enabled_get(var Args: array of TAsmData): TAsmData;
begin Result.n := 0; Result.s := ''; Result.p := nil; ClearError;
  if not ValidateEffect(Args[0].p, 'crumpletrans_enabled') then Exit;
  try if TCrumpleTransitionEffect(Args[0].p).Enabled then Result.n := 1 else Result.n := 0;
  except on E: Exception do SetError(ERR_INVALID_EFFECT, E.Message); end;
end;

procedure RegisterCrumpleTransitionEffectFuncs(Lib: TFunctionsDictionary);
var Fn: TLinkFunction;
begin Fn.FarCall := True;
  Fn.Entry := @n_crumpletrans_error; Lib.Add('crumpletrans_error@', Fn);
  Fn.Entry := @s_crumpletrans_errormsg; Lib.Add('crumpletrans_errormsg$@', Fn);
  Fn.Entry := @s_crumpletrans_strerror; Lib.Add('crumpletrans_strerror$@n', Fn);
  Fn.Entry := @n_crumpletrans_clearerror; Lib.Add('crumpletrans_clearerror@', Fn);
  Fn.Entry := @p_crumpletrans_new; Lib.Add('crumpletrans#@#', Fn);
  Fn.Entry := @n_crumpletrans_free; Lib.Add('crumpletrans_free@#', Fn);
  Fn.Entry := @p_crumpletrans_progress_set; Lib.Add('crumpletrans_progress#@#n', Fn);
  Fn.Entry := @n_crumpletrans_progress_get; Lib.Add('crumpletrans_progress@#', Fn);
  Fn.Entry := @p_crumpletrans_target_set; Lib.Add('crumpletrans_target#@##', Fn);
  Fn.Entry := @p_crumpletrans_target_get; Lib.Add('crumpletrans_target#@#', Fn);
  Fn.Entry := @p_crumpletrans_loadtarget; Lib.Add('crumpletrans_loadtarget#@#$', Fn);
  Fn.Entry := @p_crumpletrans_randomseed_set; Lib.Add('crumpletrans_randomseed#@#n', Fn);
  Fn.Entry := @n_crumpletrans_randomseed_get; Lib.Add('crumpletrans_randomseed@#', Fn);
  Fn.Entry := @p_crumpletrans_enabled_set; Lib.Add('crumpletrans_enabled#@#n', Fn);
  Fn.Entry := @n_crumpletrans_enabled_get; Lib.Add('crumpletrans_enabled@#', Fn);
end;

end.
