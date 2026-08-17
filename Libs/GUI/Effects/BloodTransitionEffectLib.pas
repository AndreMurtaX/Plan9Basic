unit BloodTransitionEffectLib;

{******************************************************************************
  BloodTransitionEffectLib - Blood Transition Effect for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TBloodTransitionEffect wrapper for creating
  dripping blood-like transitions between two images.

  Function Count: 18 functions

  PROPERTIES:
  ===========
  - Progress: Transition progress (0.0-1.0, internally 0-100)
  - Target: Bitmap to transition TO
  - RandomSeed: Seed for randomization (default 0.5)
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
  basic, exec, UnitGC, UnitUtils;

procedure RegisterBloodTransitionEffectFuncs(Lib: TFunctionsDictionary);

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
    SetError(ERR_NIL_EFFECT, FuncName + ': effect is nil');
    Exit;
  end;
  if not (TObject(P) is TBloodTransitionEffect) then
  begin
    SetError(ERR_INVALID_EFFECT, FuncName + ': not a TBloodTransitionEffect');
    Exit;
  end;
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_NIL_PARENT, FuncName + ': parent is nil');
    Exit;
  end;
  if not (TObject(P) is TFmxObject) then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': not a valid parent');
    Exit;
  end;
  Result := True;
end;

// =============================================================================
// Error Handling
// =============================================================================

function n_bloodtrans_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_bloodtrans_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_bloodtrans_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_NIL_EFFECT: Result.s := 'Effect is nil';
    ERR_INVALID_EFFECT: Result.s := 'Invalid effect type';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_NIL_PARENT: Result.s := 'Parent is nil';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent type';
    ERR_LOAD_FAILED: Result.s := 'Failed to load image';
    ERR_NIL_BITMAP: Result.s := 'Bitmap is nil';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_bloodtrans_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_bloodtrans_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TBloodTransitionEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'bloodtrans#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TBloodTransitionEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    // GC registration removed - parent ownership handles cleanup
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    //GC.Add(Effect, IntToStr(NativeInt(Effect)));

    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bloodtrans#: ' + E.Message);
  end;
end;

function n_bloodtrans_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TBloodTransitionEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloodtrans_free') then Exit;

  try
    Effect := TBloodTransitionEffect(Args[0].p);
    // GC collection removed - use direct Free instead
    // Using GC caused Access Violations due to double-free when parent
    // controls were destroyed.
    //UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bloodtrans_free: ' + E.Message);
  end;
end;

// =============================================================================
// Progress Property
// =============================================================================

function p_bloodtrans_progress_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloodtrans_progress#') then Exit;

  try
    Value := Args[1].n;
    if Value <= 1.0 then Value := Value * 100;
    if Value < 0 then Value := 0;
    if Value > 100 then Value := 100;
    TBloodTransitionEffect(Args[0].p).Progress := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bloodtrans_progress#: ' + E.Message);
  end;
end;

function n_bloodtrans_progress_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloodtrans_progress') then Exit;

  try
    Result.n := TBloodTransitionEffect(Args[0].p).Progress / 100;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bloodtrans_progress: ' + E.Message);
  end;
end;

// =============================================================================
// Target Property
// =============================================================================

function p_bloodtrans_target_set(var Args: array of TAsmData): TAsmData;
var
  Effect: TBloodTransitionEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloodtrans_target#') then Exit;

  try
    Effect := TBloodTransitionEffect(Args[0].p);
    if Args[1].p = nil then
    begin
      SetError(ERR_NIL_BITMAP, 'bloodtrans_target#: bitmap is nil');
      Exit;
    end;
    Effect.Target.Assign(TBitmap(Args[1].p));
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bloodtrans_target#: ' + E.Message);
  end;
end;

function p_bloodtrans_target_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloodtrans_target#') then Exit;

  try
    Result.p := TBloodTransitionEffect(Args[0].p).Target;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bloodtrans_target#: ' + E.Message);
  end;
end;

function p_bloodtrans_loadtarget(var Args: array of TAsmData): TAsmData;
var
  Effect: TBloodTransitionEffect;
  Path: String;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloodtrans_loadtarget#') then Exit;

  try
    Effect := TBloodTransitionEffect(Args[0].p);
    Path := Args[1].s;
    
    if (Pos('http://', LowerCase(Path)) = 1) or (Pos('https://', LowerCase(Path)) = 1) then
    begin
      if not TUtils.LoadImageFromWeb(Path, Effect.Target) then
      begin
        SetError(ERR_LOAD_FAILED, 'bloodtrans_loadtarget#: failed to load from URL');
        Exit;
      end;
    end
    else
    begin
      if FileExists(Path) then
        Effect.Target.LoadFromFile(Path)
      else
      begin
        SetError(ERR_LOAD_FAILED, 'bloodtrans_loadtarget#: file not found');
        Exit;
      end;
    end;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_LOAD_FAILED, 'bloodtrans_loadtarget#: ' + E.Message);
  end;
end;

// =============================================================================
// RandomSeed Property
// =============================================================================

function p_bloodtrans_randomseed_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloodtrans_randomseed#') then Exit;

  try
    TBloodTransitionEffect(Args[0].p).RandomSeed := Args[1].n;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bloodtrans_randomseed#: ' + E.Message);
  end;
end;

function n_bloodtrans_randomseed_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloodtrans_randomseed') then Exit;

  try
    Result.n := TBloodTransitionEffect(Args[0].p).RandomSeed;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bloodtrans_randomseed: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_bloodtrans_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloodtrans_enabled#') then Exit;

  try
    TBloodTransitionEffect(Args[0].p).Enabled := Args[1].n <> 0;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bloodtrans_enabled#: ' + E.Message);
  end;
end;

function n_bloodtrans_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'bloodtrans_enabled') then Exit;

  try
    if TBloodTransitionEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'bloodtrans_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterBloodTransitionEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_bloodtrans_error; Lib.Add('bloodtrans_error@', Fn);
  Fn.Entry := @s_bloodtrans_errormsg; Lib.Add('bloodtrans_errormsg$@', Fn);
  Fn.Entry := @s_bloodtrans_strerror; Lib.Add('bloodtrans_strerror$@n', Fn);
  Fn.Entry := @n_bloodtrans_clearerror; Lib.Add('bloodtrans_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_bloodtrans_new; Lib.Add('bloodtrans#@#', Fn);
  Fn.Entry := @n_bloodtrans_free; Lib.Add('bloodtrans_free@#', Fn);

  // Progress property
  Fn.Entry := @p_bloodtrans_progress_set; Lib.Add('bloodtrans_progress#@#n', Fn);
  Fn.Entry := @n_bloodtrans_progress_get; Lib.Add('bloodtrans_progress@#', Fn);

  // Target property
  Fn.Entry := @p_bloodtrans_target_set; Lib.Add('bloodtrans_target#@##', Fn);
  Fn.Entry := @p_bloodtrans_target_get; Lib.Add('bloodtrans_target#@#', Fn);
  Fn.Entry := @p_bloodtrans_loadtarget; Lib.Add('bloodtrans_loadtarget#@#$', Fn);

  // RandomSeed property
  Fn.Entry := @p_bloodtrans_randomseed_set; Lib.Add('bloodtrans_randomseed#@#n', Fn);
  Fn.Entry := @n_bloodtrans_randomseed_get; Lib.Add('bloodtrans_randomseed@#', Fn);

  // Enabled property
  Fn.Entry := @p_bloodtrans_enabled_set; Lib.Add('bloodtrans_enabled#@#n', Fn);
  Fn.Entry := @n_bloodtrans_enabled_get; Lib.Add('bloodtrans_enabled@#', Fn);
end;

end.
