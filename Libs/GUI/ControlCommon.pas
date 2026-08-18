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
  System.SysUtils, System.UITypes, System.Classes,
  FMX.Types,
  HandleRegistry;

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

implementation

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

end.
