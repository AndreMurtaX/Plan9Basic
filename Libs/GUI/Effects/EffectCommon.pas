{******************************************************************************
  Plan9Basic Interpreter Engine

  MIT License
  Copyright (c) 2026 André Murta

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
******************************************************************************}
unit EffectCommon;

{******************************************************************************
  EffectCommon - shared plumbing for the effect libraries

  Every effect library exposes the same four things to BASIC -- an error code,
  an error message, a text for a code, and a way to clear the error -- and
  guards every call with the same two checks. That plumbing used to be written
  out in all 64 units; it lives here instead.

  What is deliberately NOT here: the property getters and setters. Those differ
  per effect (scale conversions, range clamps, TPointF components, target
  loading) and collapsing them would mean either a generator or an RTTI layer.
  See docs/ANALYSIS-2026-08.md section 9.

  Each library keeps its own TEffectErrors instance, so sepia_error() stays
  independent from bevel_error(), exactly as before.

  Usage, in each effect library:

    var
      Err: TEffectErrors;

    function ValidateEffect(P: Pointer; const FuncName: String): Boolean;
    begin
      Result := EffectCommon.ValidateEffect(P, TSepiaEffect, Err, FuncName);
    end;
******************************************************************************}

interface

uses
  System.SysUtils, FMX.Types,
  exec, HandleRegistry;

const
  //Codes shared by every effect library. A library that needs more declares
  //them locally, starting at 6, and keeps its own strerror implementation.
  ERR_NONE           = 0;
  ERR_NIL_EFFECT     = 1;
  ERR_INVALID_EFFECT = 2;
  ERR_INVALID_VALUE  = 3;
  ERR_NIL_PARENT     = 4;
  ERR_INVALID_PARENT = 5;

type
  //One error slot per library. A record rather than a class so that a library
  //can declare it as a unit variable with no construction or teardown.
  TEffectErrors = record
    Code: Integer;
    Msg: String;
    procedure SetErr(ACode: Integer; const AMsg: String);
    procedure Clear();
  end;

//Both validations answer from the handle registry, never by dereferencing the
//pointer the BASIC program supplied: the language lets a program fabricate one
//with pointer#(n), and following it kills the process on Android and Linux.
function ValidateEffect(P: Pointer; AClass: TClass; var Err: TEffectErrors;
                        const FuncName: String): Boolean;
function ValidateParent(P: Pointer; var Err: TEffectErrors;
                        const FuncName: String): Boolean;

//Bodies for the four error accessors every effect library binds into BASIC.
function ErrorCodeResult(const Err: TEffectErrors): TAsmData;
function ErrorMsgResult(const Err: TEffectErrors): TAsmData;
function ErrorTextResult(Code: Integer): TAsmData;
function ClearErrorResult(var Err: TEffectErrors): TAsmData;

implementation

{ TEffectErrors }

procedure TEffectErrors.SetErr(ACode: Integer; const AMsg: String);
begin
  Code := ACode;
  Msg := AMsg;
end;

procedure TEffectErrors.Clear();
begin
  Code := ERR_NONE;
  Msg := '';
end;

{ validation }

function ValidateEffect(P: Pointer; AClass: TClass; var Err: TEffectErrors;
                        const FuncName: String): Boolean;
begin
  Result := False;

  if not Assigned(P) then
  begin
    Err.SetErr(ERR_NIL_EFFECT, FuncName + ': effect is nil');
    Exit();
  end;

  if not IsHandleOf(P, AClass) then
  begin
    Err.SetErr(ERR_INVALID_EFFECT, FuncName + ': invalid effect object');
    Exit();
  end;

  Result := True;
end;

function ValidateParent(P: Pointer; var Err: TEffectErrors;
                        const FuncName: String): Boolean;
begin
  Result := False;

  if not Assigned(P) then
  begin
    Err.SetErr(ERR_NIL_PARENT, FuncName + ': parent is nil');
    Exit();
  end;

  if not IsHandleOf(P, TFmxObject) then
  begin
    Err.SetErr(ERR_INVALID_PARENT, FuncName + ': invalid parent object');
    Exit();
  end;

  Result := True;
end;

{ accessor bodies }

function ErrorCodeResult(const Err: TEffectErrors): TAsmData;
begin
  Result.n := Err.Code;
  Result.s := '';
  Result.p := nil;
end;

function ErrorMsgResult(const Err: TEffectErrors): TAsmData;
begin
  Result.n := 0;
  Result.s := Err.Msg;
  Result.p := nil;
end;

function ErrorTextResult(Code: Integer): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Code of
    ERR_NONE:           Result.s := 'No error';
    ERR_NIL_EFFECT:     Result.s := 'Effect is nil';
    ERR_INVALID_EFFECT: Result.s := 'Invalid effect object';
    ERR_INVALID_VALUE:  Result.s := 'Invalid value';
    ERR_NIL_PARENT:     Result.s := 'Parent is nil';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent object';
  else
    Result.s := 'Unknown error code: ' + IntToStr(Code);
  end;
end;

function ClearErrorResult(var Err: TEffectErrors): TAsmData;
begin
  Err.Clear();
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

end.
