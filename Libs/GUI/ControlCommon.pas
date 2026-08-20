{******************************************************************************
  Plan9Basic Interpreter Engine

  MIT License
  Copyright (c) 2026 Andre Murta

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
unit ControlCommon;

{******************************************************************************
  ControlCommon - the conversions every control library carried its own copy of.

  These four functions and the alignment codes had been pasted into 27 units and
  had drifted. AlignToInt existed in six versions, covering 6, 7 or 20 of the
  TAlignLayout values depending on which unit the author copied from, so the
  same number meant different things in different controls:

      rectangle_align#(r, 5)   sets MostTop
      button_align#(b, 5)      silently set None

  Both now answer from the tables below. A control that could not express
  MostTop can, and no BASIC program can tell which unit implements a control
  from how that control reports its alignment.

  What is deliberately NOT here: each library keeps its own error slot and its
  own error codes, because code 1 names the library's own type -- so
  ERR_INVALID_BUTTON and ERR_INVALID_CIRCLE both are 1, and button_error() must
  stay independent of circle_error(). ValidateParent stays in each unit too, as
  a short forwarder over ParentIsValid, for the same reason: only the unit knows
  where to record what went wrong.

  Anything added here must be genuinely common to controls. A conversion used by
  a single library belongs in that library.
******************************************************************************}

interface

uses
  System.SysUtils, System.UITypes, System.Classes, System.Types,
  FMX.Types, FMX.Controls, FMX.Graphics,
  basic, exec, UnitGC, HandleRegistry;

const
  //Alignment codes as seen from BASIC. The order follows TAlignLayout, and the
  //values are frozen: applets pass these numbers as literals.
  ALIGN_NONE        = 0;
  ALIGN_TOP         = 1;
  ALIGN_LEFT        = 2;
  ALIGN_RIGHT       = 3;
  ALIGN_BOTTOM      = 4;
  ALIGN_MOST_TOP    = 5;
  ALIGN_MOST_BOTTOM = 6;
  ALIGN_MOST_LEFT   = 7;
  ALIGN_MOST_RIGHT  = 8;
  ALIGN_CLIENT      = 9;
  ALIGN_CONTENTS    = 10;
  ALIGN_CENTER      = 11;
  ALIGN_VERT_CENTER = 12;
  ALIGN_HORZ_CENTER = 13;
  ALIGN_HORIZONTAL  = 14;
  ALIGN_VERTICAL    = 15;
  ALIGN_SCALE       = 16;
  ALIGN_FIT         = 17;
  ALIGN_FIT_LEFT    = 18;
  ALIGN_FIT_RIGHT   = 19;

type
  //Implemented by the form, which is where a running program's engine and
  //output actually live. Everything a program builds hangs off a form, so a
  //control can reach them by asking upwards instead of reading a unit variable.
  //
  //An interface rather than a class reference, because ControlCommon cannot
  //name TBasForm: FormLib already uses this unit, and the dependency would
  //close a circle.
  IEngineHost = interface
    ['{4B1E9A62-3C7D-4E58-9E2A-7C0F5D8B41A6}']
    function GetEngine: TBasicEngine;
    function GetOutput: TStrings;
  end;

//The engine and output that own Obj, found by walking up to the form.
//
//This replaces `Obj.BasicEngine := ModuleEngine` at construction, where
//ModuleEngine was a unit variable filled in once at registration. That made the
//engine per-process: a second one could not exist beside the first. Reached
//through the parent chain it is per form tree instead, which is what "two
//engines in one process" needs.
//
//False when the chain reaches no host, which is what happens to a control
//created with no parent.
function EngineOf(Obj: TFmxObject; out Engine: TBasicEngine;
                  out Output: TStrings): Boolean;

//Alignment, both directions. An unknown value yields None rather than an error,
//which is what every previous copy did.
function AlignToInt(Value: TAlignLayout): Integer;
function AlignFromInt(Value: Integer): TAlignLayout;

//Modifier keys and buttons held during a mouse or key event, as the letters the
//event callbacks hand to BASIC: S C A M for the modifiers, L R X for buttons.
function BuildShiftString(Shift: TShiftState): String;

//Mouse button as reported to BASIC: 0 left, 1 right, 2 middle.
function MouseButtonToInt(Button: TMouseButton): Integer;

//Answers whether P may serve as a parent, from the handle registry and never by
//dereferencing the pointer: the language lets a program fabricate one with
//pointer#(n), and following it kills the process on Android and Linux.
//On False, Msg carries the reason, for the caller to record in its own slot.
function ParentIsValid(P: Pointer; const FuncName: String; out Msg: String): Boolean;

//Runs a BASIC function as a callback, with the guards every control library had
//written out around it: no reentry, an engine and an output to run against, and
//a signature to call. Owner names the library in the error line, since by the
//time a callback fails the stack no longer says which control raised it.
//
//GlobalCallbackBusy is what stops an event fired from inside a callback from
//re-entering the VM, and SkipProcessMessages stops the callback from pumping
//the message loop underneath its own caller.
//Wiring a BASIC callback name to an FMX event, once per event rather than
//once per control. 369 of the 420 setters across the GUI libraries were the
//same five lines with three identifiers changed:
//
//    FOnClickFunc := Value;
//    if Value <> '' then Self.OnClick := InternalOnClick
//    else Self.OnClick := nil;
//
//ANALYSIS 9 recorded that as a boundary, because Delphi cannot abstract over
//a property name at compile time. It cannot -- and it does not have to. The
//name is fixed inside the helper, and there are 19 names against 369 sites.
//
//The field is passed by reference because it is a field and may be; the
//property is assigned inside, because a property may not.
procedure BindClick(AControl: TControl; const AName: String;
                     var AField: String; AHandler: TNotifyEvent);
procedure BindDblClick(AControl: TControl; const AName: String;
                        var AField: String; AHandler: TNotifyEvent);
procedure BindMouseEnter(AControl: TControl; const AName: String;
                          var AField: String; AHandler: TNotifyEvent);
procedure BindMouseLeave(AControl: TControl; const AName: String;
                          var AField: String; AHandler: TNotifyEvent);
procedure BindResize(AControl: TControl; const AName: String;
                      var AField: String; AHandler: TNotifyEvent);
procedure BindResized(AControl: TControl; const AName: String;
                       var AField: String; AHandler: TNotifyEvent);
procedure BindEnter(AControl: TControl; const AName: String;
                     var AField: String; AHandler: TNotifyEvent);
procedure BindExit(AControl: TControl; const AName: String;
                    var AField: String; AHandler: TNotifyEvent);
procedure BindDragLeave(AControl: TControl; const AName: String;
                         var AField: String; AHandler: TNotifyEvent);
procedure BindMouseDown(AControl: TControl; const AName: String;
                         var AField: String; AHandler: TMouseEvent);
procedure BindMouseUp(AControl: TControl; const AName: String;
                       var AField: String; AHandler: TMouseEvent);
procedure BindMouseMove(AControl: TControl; const AName: String;
                         var AField: String; AHandler: TMouseMoveEvent);
procedure BindMouseWheel(AControl: TControl; const AName: String;
                          var AField: String; AHandler: TMouseWheelEvent);
procedure BindKeyDown(AControl: TControl; const AName: String;
                       var AField: String; AHandler: TKeyEvent);
procedure BindKeyUp(AControl: TControl; const AName: String;
                     var AField: String; AHandler: TKeyEvent);
procedure BindPaint(AControl: TControl; const AName: String;
                     var AField: String; AHandler: TOnPaintEvent);
procedure BindDragEnter(AControl: TControl; const AName: String;
                         var AField: String; AHandler: TDragEnterEvent);
procedure BindDragOver(AControl: TControl; const AName: String;
                        var AField: String; AHandler: TDragOverEvent);
procedure BindDragDrop(AControl: TControl; const AName: String;
                        var AField: String; AHandler: TDragDropEvent);

procedure RunCallback(Engine: TBasicEngine; Output: TStrings;
                      const FuncSignature: String; const Args: array of TAsmData;
                      const Owner: String);
function RunCallbackWithResult(Engine: TBasicEngine; Output: TStrings;
                      const FuncSignature: String; const Args: array of TAsmData;
                      const Owner: String): TAsmData;

implementation

function EngineOf(Obj: TFmxObject; out Engine: TBasicEngine;
                  out Output: TStrings): Boolean;
var
  Host: IEngineHost;
begin
  Engine := nil;
  Output := nil;
  Result := False;

  while Assigned(Obj) do
  begin
    if Supports(Obj, IEngineHost, Host) then
    begin
      Engine := Host.GetEngine;
      Output := Host.GetOutput;
      Exit(Assigned(Engine));
    end;
    Obj := Obj.Parent;
  end;
end;

function AlignToInt(Value: TAlignLayout): Integer;
begin
  case Value of
    TAlignLayout.None: Result := ALIGN_NONE;
    TAlignLayout.Top: Result := ALIGN_TOP;
    TAlignLayout.Left: Result := ALIGN_LEFT;
    TAlignLayout.Right: Result := ALIGN_RIGHT;
    TAlignLayout.Bottom: Result := ALIGN_BOTTOM;
    TAlignLayout.MostTop: Result := ALIGN_MOST_TOP;
    TAlignLayout.MostBottom: Result := ALIGN_MOST_BOTTOM;
    TAlignLayout.MostLeft: Result := ALIGN_MOST_LEFT;
    TAlignLayout.MostRight: Result := ALIGN_MOST_RIGHT;
    TAlignLayout.Client: Result := ALIGN_CLIENT;
    TAlignLayout.Contents: Result := ALIGN_CONTENTS;
    TAlignLayout.Center: Result := ALIGN_CENTER;
    TAlignLayout.VertCenter: Result := ALIGN_VERT_CENTER;
    TAlignLayout.HorzCenter: Result := ALIGN_HORZ_CENTER;
    TAlignLayout.Horizontal: Result := ALIGN_HORIZONTAL;
    TAlignLayout.Vertical: Result := ALIGN_VERTICAL;
    TAlignLayout.Scale: Result := ALIGN_SCALE;
    TAlignLayout.Fit: Result := ALIGN_FIT;
    TAlignLayout.FitLeft: Result := ALIGN_FIT_LEFT;
    TAlignLayout.FitRight: Result := ALIGN_FIT_RIGHT;
  else
    Result := ALIGN_NONE;
  end;
end;

function AlignFromInt(Value: Integer): TAlignLayout;
begin
  case Value of
    ALIGN_NONE: Result := TAlignLayout.None;
    ALIGN_TOP: Result := TAlignLayout.Top;
    ALIGN_LEFT: Result := TAlignLayout.Left;
    ALIGN_RIGHT: Result := TAlignLayout.Right;
    ALIGN_BOTTOM: Result := TAlignLayout.Bottom;
    ALIGN_MOST_TOP: Result := TAlignLayout.MostTop;
    ALIGN_MOST_BOTTOM: Result := TAlignLayout.MostBottom;
    ALIGN_MOST_LEFT: Result := TAlignLayout.MostLeft;
    ALIGN_MOST_RIGHT: Result := TAlignLayout.MostRight;
    ALIGN_CLIENT: Result := TAlignLayout.Client;
    ALIGN_CONTENTS: Result := TAlignLayout.Contents;
    ALIGN_CENTER: Result := TAlignLayout.Center;
    ALIGN_VERT_CENTER: Result := TAlignLayout.VertCenter;
    ALIGN_HORZ_CENTER: Result := TAlignLayout.HorzCenter;
    ALIGN_HORIZONTAL: Result := TAlignLayout.Horizontal;
    ALIGN_VERTICAL: Result := TAlignLayout.Vertical;
    ALIGN_SCALE: Result := TAlignLayout.Scale;
    ALIGN_FIT: Result := TAlignLayout.Fit;
    ALIGN_FIT_LEFT: Result := TAlignLayout.FitLeft;
    ALIGN_FIT_RIGHT: Result := TAlignLayout.FitRight;
  else
    Result := TAlignLayout.None;
  end;
end;

function BuildShiftString(Shift: TShiftState): String;
begin
  Result := '';
  if ssShift in Shift then Result := Result + 'S';
  if ssCtrl in Shift then Result := Result + 'C';
  if ssAlt in Shift then Result := Result + 'A';
  if ssCommand in Shift then Result := Result + 'M';
  if ssLeft in Shift then Result := Result + 'L';
  if ssRight in Shift then Result := Result + 'R';
  if ssMiddle in Shift then Result := Result + 'X';
end;

function MouseButtonToInt(Button: TMouseButton): Integer;
begin
  case Button of
    TMouseButton.mbLeft: Result := 0;
    TMouseButton.mbRight: Result := 1;
    TMouseButton.mbMiddle: Result := 2;
  else
    Result := 0;
  end;
end;

function ParentIsValid(P: Pointer; const FuncName: String; out Msg: String): Boolean;
begin
  Result := False;
  Msg := '';

  if P = nil then
  begin
    Msg := FuncName + ': Nil parent pointer';
    Exit();
  end;

  try
    if not IsHandleOf(P, TFmxObject) then
    begin
      Msg := FuncName + ': Invalid parent object';
      Exit();
    end;
  except
    //IsHandleOf answers from a dictionary and should not raise, but a library
    //must never be the reason the interpreter dies.
    Msg := FuncName + ': Invalid parent pointer';
    Exit();
  end;

  Result := True;
end;

//Shared by RunCallback and RunCallbackWithResult: everything except what is
//done with the return value.
function CallbackCore(Engine: TBasicEngine; Output: TStrings;
                      const FuncSignature: String; const Args: array of TAsmData;
                      const Owner: String): TAsmData;
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  i: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if UnitGC.CallbackInProgress() then Exit();
  if not Assigned(Engine) then Exit();
  if not Assigned(Output) then Exit();
  if FuncSignature = '' then Exit();

  if not UnitGC.ClaimCallbackGuard() then
    Exit();
  UnitGC.SkipProcessMessages := True;
  try
    SetLength(CallArgs, Length(Args));
    for i := 0 to High(Args) do
      CallArgs[i] := Args[i];
    try
      Engine.ExecuteUserFunction(Output, FuncSignature, CallArgs, RetType, Result);
    except
      on E: Exception do
        Output.Add('*** ' + Owner + ' callback error in ' + FuncSignature +
                   ': ' + E.Message);
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.ReleaseCallbackGuard();
  end;
end;

procedure RunCallback(Engine: TBasicEngine; Output: TStrings;
                      const FuncSignature: String; const Args: array of TAsmData;
                      const Owner: String);
begin
  CallbackCore(Engine, Output, FuncSignature, Args, Owner);
end;

function RunCallbackWithResult(Engine: TBasicEngine; Output: TStrings;
                      const FuncSignature: String; const Args: array of TAsmData;
                      const Owner: String): TAsmData;
begin
  Result := CallbackCore(Engine, Output, FuncSignature, Args, Owner);
end;


{ Event binding }

procedure BindClick(AControl: TControl; const AName: String;
                     var AField: String; AHandler: TNotifyEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnClick := AHandler
  else
    AControl.OnClick := nil;
end;

procedure BindDblClick(AControl: TControl; const AName: String;
                        var AField: String; AHandler: TNotifyEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnDblClick := AHandler
  else
    AControl.OnDblClick := nil;
end;

procedure BindMouseEnter(AControl: TControl; const AName: String;
                          var AField: String; AHandler: TNotifyEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnMouseEnter := AHandler
  else
    AControl.OnMouseEnter := nil;
end;

procedure BindMouseLeave(AControl: TControl; const AName: String;
                          var AField: String; AHandler: TNotifyEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnMouseLeave := AHandler
  else
    AControl.OnMouseLeave := nil;
end;

procedure BindResize(AControl: TControl; const AName: String;
                      var AField: String; AHandler: TNotifyEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnResize := AHandler
  else
    AControl.OnResize := nil;
end;

procedure BindResized(AControl: TControl; const AName: String;
                       var AField: String; AHandler: TNotifyEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnResized := AHandler
  else
    AControl.OnResized := nil;
end;

procedure BindEnter(AControl: TControl; const AName: String;
                     var AField: String; AHandler: TNotifyEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnEnter := AHandler
  else
    AControl.OnEnter := nil;
end;

procedure BindExit(AControl: TControl; const AName: String;
                    var AField: String; AHandler: TNotifyEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnExit := AHandler
  else
    AControl.OnExit := nil;
end;

procedure BindDragLeave(AControl: TControl; const AName: String;
                         var AField: String; AHandler: TNotifyEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnDragLeave := AHandler
  else
    AControl.OnDragLeave := nil;
end;

procedure BindMouseDown(AControl: TControl; const AName: String;
                         var AField: String; AHandler: TMouseEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnMouseDown := AHandler
  else
    AControl.OnMouseDown := nil;
end;

procedure BindMouseUp(AControl: TControl; const AName: String;
                       var AField: String; AHandler: TMouseEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnMouseUp := AHandler
  else
    AControl.OnMouseUp := nil;
end;

procedure BindMouseMove(AControl: TControl; const AName: String;
                         var AField: String; AHandler: TMouseMoveEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnMouseMove := AHandler
  else
    AControl.OnMouseMove := nil;
end;

procedure BindMouseWheel(AControl: TControl; const AName: String;
                          var AField: String; AHandler: TMouseWheelEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnMouseWheel := AHandler
  else
    AControl.OnMouseWheel := nil;
end;

procedure BindKeyDown(AControl: TControl; const AName: String;
                       var AField: String; AHandler: TKeyEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnKeyDown := AHandler
  else
    AControl.OnKeyDown := nil;
end;

procedure BindKeyUp(AControl: TControl; const AName: String;
                     var AField: String; AHandler: TKeyEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnKeyUp := AHandler
  else
    AControl.OnKeyUp := nil;
end;

procedure BindPaint(AControl: TControl; const AName: String;
                     var AField: String; AHandler: TOnPaintEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnPainting := AHandler
  else
    AControl.OnPainting := nil;
end;

procedure BindDragEnter(AControl: TControl; const AName: String;
                         var AField: String; AHandler: TDragEnterEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnDragEnter := AHandler
  else
    AControl.OnDragEnter := nil;
end;

procedure BindDragOver(AControl: TControl; const AName: String;
                        var AField: String; AHandler: TDragOverEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnDragOver := AHandler
  else
    AControl.OnDragOver := nil;
end;

procedure BindDragDrop(AControl: TControl; const AName: String;
                        var AField: String; AHandler: TDragDropEvent);
begin
  AField := AName;
  if AName <> '' then
    AControl.OnDragDrop := AHandler
  else
    AControl.OnDragDrop := nil;
end;
end.
