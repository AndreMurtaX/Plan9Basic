unit PaperSketchEffectLib;

{******************************************************************************
  PaperSketchEffectLib - Paper Sketch Effect Library for Plan9Basic
  Version: 1.0.0

  Provides FireMonkey TPaperSketchEffect wrapper for creating a pencil
  sketch/drawing appearance on visual controls.

  Function Count: 12 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  PROPERTIES:
  ===========
  - BrushSize: Size of sketch strokes (0.0-10.0, default 1.0)
  - Enabled: Turn effect on/off
  - Trigger: Conditional activation string

  Copyright (c) 2024-2026 André Murta
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Effects, FMX.Filter.Effects,
  basic, exec, UnitGC, HandleRegistry, EffectCommon;

procedure RegisterPaperSketchEffectFuncs(Lib: TFunctionsDictionary);

implementation

var
  //One error slot for this library, shared shape in EffectCommon.
  Err: TEffectErrors;


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
  Result := EffectCommon.ValidateEffect(P, TPaperSketchEffect, Err, FuncName);
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := EffectCommon.ValidateParent(P, Err, FuncName);
end;

// =============================================================================
// Error Handling Functions
// =============================================================================

function n_papersketch_error(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorCodeResult(Err);
end;

function s_papersketch_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorMsgResult(Err);
end;

function s_papersketch_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ErrorTextResult(Trunc(Args[0].n));
end;

function n_papersketch_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result := ClearErrorResult(Err);
end;

// =============================================================================
// Creation/Destruction
// =============================================================================

function p_papersketch_new(var Args: array of TAsmData): TAsmData;
var
  Effect: TPaperSketchEffect;
  Parent: TFmxObject;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'papersketch#') then Exit;

  try
    Parent := TFmxObject(Args[0].p);
    Effect := TPaperSketchEffect.Create(Parent);
    Effect.Parent := Parent;
    Effect.Enabled := True;
    Effect.BrushSize := 1.0;

    // GC.Add removed - parent ownership handles cleanup
    // UnitGC.GC.Add<TPaperSketchEffect>(Effect, IntToStr(NativeInt(Effect)));

    //Makes this effect a handle that can be validated without dereferencing
    //the pointer the BASIC program hands back. Revocation is automatic: the
    //effect belongs to its parent, and the registry listens to FreeNotification.
    RegisterHandle(Effect);
    Result.p := Effect;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'papersketch#: ' + E.Message);
  end;
end;

function n_papersketch_free(var Args: array of TAsmData): TAsmData;
var
  Effect: TPaperSketchEffect;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'papersketch_free') then Exit;

  try
    Effect := TPaperSketchEffect(Args[0].p);
    // GC.Collect removed - use direct Free instead
    // UnitGC.GC.Collect(IntToStr(NativeInt(Effect)));
    Effect.Free;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'papersketch_free: ' + E.Message);
  end;
end;

// =============================================================================
// BrushSize Property (0.0 - 10.0)
// =============================================================================

function p_papersketch_brushsize_set(var Args: array of TAsmData): TAsmData;
var
  Value: Single;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'papersketch_brushsize#') then Exit;

  try
    Value := Args[1].n;
    if Value < 0.0 then Value := 0.0;
    if Value > 10.0 then Value := 10.0;
    TPaperSketchEffect(Args[0].p).BrushSize := Value;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'papersketch_brushsize#: ' + E.Message);
  end;
end;

function n_papersketch_brushsize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'papersketch_brushsize') then Exit;

  try
    Result.n := TPaperSketchEffect(Args[0].p).BrushSize;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'papersketch_brushsize: ' + E.Message);
  end;
end;

// =============================================================================
// Enabled Property
// =============================================================================

function p_papersketch_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'papersketch_enabled#') then Exit;

  try
    TPaperSketchEffect(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'papersketch_enabled#: ' + E.Message);
  end;
end;

function n_papersketch_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'papersketch_enabled') then Exit;

  try
    if TPaperSketchEffect(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'papersketch_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Trigger Property
// =============================================================================

function p_papersketch_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'papersketch_trigger#') then Exit;

  try
    TPaperSketchEffect(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'papersketch_trigger#: ' + E.Message);
  end;
end;

function s_papersketch_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateEffect(Args[0].p, 'papersketch_trigger$') then Exit;

  try
    Result.s := TPaperSketchEffect(Args[0].p).Trigger;
  except
    on E: Exception do
      SetError(ERR_INVALID_EFFECT, 'papersketch_trigger$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterPaperSketchEffectFuncs(Lib: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_papersketch_error; Lib.Add('papersketch_error@', Fn);
  Fn.Entry := @s_papersketch_errormsg; Lib.Add('papersketch_errormsg$@', Fn);
  Fn.Entry := @s_papersketch_strerror; Lib.Add('papersketch_strerror$@n', Fn);
  Fn.Entry := @n_papersketch_clearerror; Lib.Add('papersketch_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_papersketch_new; Lib.Add('papersketch#@#', Fn);
  Fn.Entry := @n_papersketch_free; Lib.Add('papersketch_free@#', Fn);

  // BrushSize property
  Fn.Entry := @p_papersketch_brushsize_set; Lib.Add('papersketch_brushsize#@#n', Fn);
  Fn.Entry := @n_papersketch_brushsize_get; Lib.Add('papersketch_brushsize@#', Fn);

  // Enabled property
  Fn.Entry := @p_papersketch_enabled_set; Lib.Add('papersketch_enabled#@#n', Fn);
  Fn.Entry := @n_papersketch_enabled_get; Lib.Add('papersketch_enabled@#', Fn);

  // Trigger property
  Fn.Entry := @p_papersketch_trigger_set; Lib.Add('papersketch_trigger#@#$', Fn);
  Fn.Entry := @s_papersketch_trigger_get; Lib.Add('papersketch_trigger$@#', Fn);
end;

end.

