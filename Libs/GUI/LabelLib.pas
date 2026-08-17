unit LabelLib;

{******************************************************************************
  LabelLib - Label Text Control Library for Plan9Basic
  Version: 1.1.0

  Provides complete FireMonkey TLabel wrapper functionality for creating
  and managing text label controls in Plan9Basic programs. TLabel displays
  static or dynamic text with full font styling support.

  Function Count: 82 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All labels are created at RUNTIME using TLabel.Create with dynamic
  parent assignment. This ensures proper dynamic creation across all platforms.

  EVENT CONNECTION MODEL (v1.1.0):
  ================================
  Events are connected/disconnected individually when callbacks are set:
  - Setting a non-empty callback name connects ONLY that specific event
  - Setting an empty callback name ("") disconnects ONLY that specific event
  - No events are connected by default in the constructor
  - Users must also enable HitTest for mouse events: label_hittest#(lbl#, 1)

  FEATURES:
  =========
  - Label creation and lifecycle management
  - Text content with font styling (family, size, bold, italic, etc.)
  - Text color and background
  - Horizontal and vertical text alignment
  - Word wrap and auto-sizing
  - Complete positioning and alignment
  - Full event support with BASIC callback integration

  EVENTS SUPPORT:
  ===============
  - OnClick: Label was clicked
  - OnDblClick: Label was double-clicked
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over label
  - OnMouseEnter: Mouse entered label area
  - OnMouseLeave: Mouse left label area
  - OnResize: Label is being resized

  TEXT HORIZONTAL ALIGNMENT:
  ==========================
  0 = Center
  1 = Leading (Left for LTR languages)
  2 = Trailing (Right for LTR languages)

  TEXT VERTICAL ALIGNMENT:
  ========================
  0 = Center
  1 = Leading (Top)
  2 = Trailing (Bottom)

  FONT STYLES:
  ============
  Use individual functions or combine:
  - Bold: label_bold#(lbl#, 1)
  - Italic: label_italic#(lbl#, 1)
  - Underline: label_underline#(lbl#, 1)
  - Strikeout: label_strikeout#(lbl#, 1)

  USAGE PATTERN:
  ==============
    let frm# = form#("Label Demo", 800, 600)

    ' Create a simple label
    let lbl# = label#(frm#, "Hello, World!")
    label_move#(lbl#, 50, 50)
    label_fontsize#(lbl#, 24)
    label_fontcolor#(lbl#, "blue")

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnLabelClick(sender#)
      println "Label clicked!"
    endfunction

    function OnLabelMouseMove(sender#, x, y, shift$)
      println "Mouse at: " + stri$(x) + ", " + stri$(y)
    endfunction

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.StdCtrls,
  basic, exec, UnitGC, UnitUtils, HandleRegistry;

type
  // Forward declaration
  TBasLabel = class;

  {****************************************************************************
    TBasLabel - Extended TLabel with BASIC event callback support

    Wraps a TLabel and provides event bridging to Plan9Basic user functions.
    Each event stores the name of a BASIC function to call when triggered.
  ****************************************************************************}
  TBasLabel = class(TLabel)
  private
    // Event callback function names (stored in lowercase+signature format)
    FOnClickFunc: String;
    FOnDblClickFunc: String;
    FOnMouseDownFunc: String;
    FOnMouseUpFunc: String;
    FOnMouseMoveFunc: String;
    FOnMouseEnterFunc: String;
    FOnMouseLeaveFunc: String;
    FOnResizeFunc: String;

    // Engine references for callback execution
    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;

    // Internal event handlers
    procedure InternalOnClick(Sender: TObject);
    procedure InternalOnDblClick(Sender: TObject);
    procedure InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseEnter(Sender: TObject);
    procedure InternalOnMouseLeave(Sender: TObject);
    procedure InternalOnResize(Sender: TObject);

    // Callback execution helper
    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);

    // Property setters that connect/disconnect individual events
    procedure SetOnClickFunc(const Value: String);
    procedure SetOnDblClickFunc(const Value: String);
    procedure SetOnMouseDownFunc(const Value: String);
    procedure SetOnMouseUpFunc(const Value: String);
    procedure SetOnMouseMoveFunc(const Value: String);
    procedure SetOnMouseEnterFunc(const Value: String);
    procedure SetOnMouseLeaveFunc(const Value: String);
    procedure SetOnResizeFunc(const Value: String);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    // Disconnect all events (for cleanup)
    procedure DisconnectAllEvents();

    // Properties for event function names (setters handle connect/disconnect)
    property OnClickFunc: String read FOnClickFunc write SetOnClickFunc;
    property OnDblClickFunc: String read FOnDblClickFunc write SetOnDblClickFunc;
    property OnMouseDownFunc: String read FOnMouseDownFunc write SetOnMouseDownFunc;
    property OnMouseUpFunc: String read FOnMouseUpFunc write SetOnMouseUpFunc;
    property OnMouseMoveFunc: String read FOnMouseMoveFunc write SetOnMouseMoveFunc;
    property OnMouseEnterFunc: String read FOnMouseEnterFunc write SetOnMouseEnterFunc;
    property OnMouseLeaveFunc: String read FOnMouseLeaveFunc write SetOnMouseLeaveFunc;
    property OnResizeFunc: String read FOnResizeFunc write SetOnResizeFunc;

    // Engine references
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
  end;

// Library registration
procedure RegisterLabelFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  LABEL_GC_TAG = 'BASIC_LABEL';

  // Error codes
  ERR_NONE = 0;
  ERR_INVALID_LABEL = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INVALID_CALLBACK = 5;
  ERR_INVALID_COLOR = 6;

  // Alignment constants (matching TAlignLayout)
  ALIGN_NONE = 0;
  ALIGN_TOP = 1;
  ALIGN_LEFT = 2;
  ALIGN_RIGHT = 3;
  ALIGN_BOTTOM = 4;
  ALIGN_MOST_TOP = 5;
  ALIGN_MOST_BOTTOM = 6;
  ALIGN_MOST_LEFT = 7;
  ALIGN_MOST_RIGHT = 8;
  ALIGN_CLIENT = 9;
  ALIGN_CONTENTS = 10;
  ALIGN_CENTER = 11;
  ALIGN_VERT_CENTER = 12;
  ALIGN_HORZ_CENTER = 13;
  ALIGN_HORIZONTAL = 14;
  ALIGN_VERTICAL = 15;
  ALIGN_SCALE = 16;
  ALIGN_FIT = 17;
  ALIGN_FIT_LEFT = 18;
  ALIGN_FIT_RIGHT = 19;

  // Text alignment constants
  TEXT_ALIGN_CENTER = 0;
  TEXT_ALIGN_LEADING = 1;
  TEXT_ALIGN_TRAILING = 2;

var
  lastError: Integer;
  lastErrorMsg: String;

  // Module-level references for event callback support
  ModuleEngine: TBasicEngine;
  ModuleOutput: TStrings;

//==============================================================================
// Helper Functions
//==============================================================================

procedure SetError(Code: Integer; const Msg: String);
begin
  lastError := Code;
  lastErrorMsg := Msg;
end;

procedure ClearError();
begin
  lastError := ERR_NONE;
  lastErrorMsg := '';
end;

function ValidateLabel(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_LABEL, FuncName + ': Nil label pointer');
    Exit;
  end;

  try
    if not (IsHandleOf(P, TBasLabel)) then
    begin
      SetError(ERR_INVALID_LABEL, FuncName + ': Invalid label object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_LABEL, FuncName + ': Invalid label pointer');
    Exit;
  end;

  ClearError();
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': Nil parent pointer');
    Exit;
  end;

  try
    if not (TObject(P) is TFmxObject) then
    begin
      SetError(ERR_INVALID_PARENT, FuncName + ': Invalid parent object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_PARENT, FuncName + ': Invalid parent pointer');
    Exit;
  end;

  ClearError();
  Result := True;
end;

function IntToAlign(Value: Integer): TAlignLayout;
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

function IntToTextAlign(Value: Integer): TTextAlign;
begin
  case Value of
    TEXT_ALIGN_CENTER: Result := TTextAlign.Center;
    TEXT_ALIGN_LEADING: Result := TTextAlign.Leading;
    TEXT_ALIGN_TRAILING: Result := TTextAlign.Trailing;
  else
    Result := TTextAlign.Center;
  end;
end;

function TextAlignToInt(Value: TTextAlign): Integer;
begin
  case Value of
    TTextAlign.Center: Result := TEXT_ALIGN_CENTER;
    TTextAlign.Leading: Result := TEXT_ALIGN_LEADING;
    TTextAlign.Trailing: Result := TEXT_ALIGN_TRAILING;
  else
    Result := TEXT_ALIGN_CENTER;
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

//==============================================================================
// TBasLabel Implementation
//==============================================================================

constructor TBasLabel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);

  // Initialize callback function names (all empty = no events connected)
  FOnClickFunc := '';
  FOnDblClickFunc := '';
  FOnMouseDownFunc := '';
  FOnMouseUpFunc := '';
  FOnMouseMoveFunc := '';
  FOnMouseEnterFunc := '';
  FOnMouseLeaveFunc := '';
  FOnResizeFunc := '';

  // Initialize engine references
  FBasicEngine := nil;
  FConsoleOutput := nil;

  // Note: HitTest remains False by default (FireMonkey default for TLabel)
  // Users must call label_hittest#(lbl#, 1) to enable mouse events

  // Note: No events are connected by default
  // Events are connected individually when callbacks are set via property setters
end;

destructor TBasLabel.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasLabel.DisconnectAllEvents();
begin
  Self.OnClick := nil;
  Self.OnDblClick := nil;
  Self.OnMouseDown := nil;
  Self.OnMouseUp := nil;
  Self.OnMouseMove := nil;
  Self.OnMouseEnter := nil;
  Self.OnMouseLeave := nil;
  Self.OnResize := nil;
end;

//==============================================================================
// Property Setters - Connect/Disconnect individual events
//==============================================================================

procedure TBasLabel.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    Self.OnClick := InternalOnClick
  else
    Self.OnClick := nil;
end;

procedure TBasLabel.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    Self.OnDblClick := InternalOnDblClick
  else
    Self.OnDblClick := nil;
end;

procedure TBasLabel.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    Self.OnMouseDown := InternalOnMouseDown
  else
    Self.OnMouseDown := nil;
end;

procedure TBasLabel.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    Self.OnMouseUp := InternalOnMouseUp
  else
    Self.OnMouseUp := nil;
end;

procedure TBasLabel.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    Self.OnMouseMove := InternalOnMouseMove
  else
    Self.OnMouseMove := nil;
end;

procedure TBasLabel.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    Self.OnMouseEnter := InternalOnMouseEnter
  else
    Self.OnMouseEnter := nil;
end;

procedure TBasLabel.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    Self.OnMouseLeave := InternalOnMouseLeave
  else
    Self.OnMouseLeave := nil;
end;

procedure TBasLabel.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    Self.OnResize := InternalOnResize
  else
    Self.OnResize := nil;
end;

procedure TBasLabel.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  RetVal: TAsmData;
  i: Integer;
begin
  // Prevent reentrant callback execution
  if UnitGC.GlobalCallbackBusy then Exit();

  if not Assigned(FBasicEngine) then Exit();
  if not Assigned(FConsoleOutput) then Exit();
  if FuncSignature = '' then Exit();

  UnitGC.GlobalCallbackBusy := True;
  UnitGC.SkipProcessMessages := True;
  try
    SetLength(CallArgs, Length(Args));
    for i := 0 to High(Args) do
      CallArgs[i] := Args[i];

    try
      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs, RetType, RetVal);
    except
      on E: Exception do
      begin
        FConsoleOutput.Add('*** Label Event Callback Error ***');
        FConsoleOutput.Add('Function: ' + FuncSignature);
        FConsoleOutput.Add('Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

procedure TBasLabel.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnClickFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnClickFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasLabel.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnDblClickFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnDblClickFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasLabel.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
  Signature: String;
begin
  if FOnMouseDownFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnMouseDownFunc) + '@#nnn$';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := MouseButtonToInt(Button);
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := X;
  Args[2].p := nil;
  Args[2].s := '';

  Args[3].n := Y;
  Args[3].p := nil;
  Args[3].s := '';

  Args[4].n := 0;
  Args[4].p := nil;
  Args[4].s := BuildShiftString(Shift);

  ExecuteCallback(Signature, Args);
end;

procedure TBasLabel.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
  Signature: String;
begin
  if FOnMouseUpFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnMouseUpFunc) + '@#nnn$';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := MouseButtonToInt(Button);
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := X;
  Args[2].p := nil;
  Args[2].s := '';

  Args[3].n := Y;
  Args[3].p := nil;
  Args[3].s := '';

  Args[4].n := 0;
  Args[4].p := nil;
  Args[4].s := BuildShiftString(Shift);

  ExecuteCallback(Signature, Args);
end;

procedure TBasLabel.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..3] of TAsmData;
  Signature: String;
begin
  if FOnMouseMoveFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnMouseMoveFunc) + '@#nn$';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := X;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := Y;
  Args[2].p := nil;
  Args[2].s := '';

  Args[3].n := 0;
  Args[3].p := nil;
  Args[3].s := BuildShiftString(Shift);

  ExecuteCallback(Signature, Args);
end;

procedure TBasLabel.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnMouseEnterFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnMouseEnterFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasLabel.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnMouseLeaveFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnMouseLeaveFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasLabel.InternalOnResize(Sender: TObject);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnResizeFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnResizeFunc) + '@#nn';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := Self.Width;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := Self.Height;
  Args[2].p := nil;
  Args[2].s := '';

  ExecuteCallback(Signature, Args);
end;

//==============================================================================
// Library Functions - Error Handling
//==============================================================================

function n_label_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

function s_label_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

function s_label_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_LABEL: Result.s := 'Invalid or nil label';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent control';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Label creation failed';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback function';
    ERR_INVALID_COLOR: Result.s := 'Invalid color value';
  else
    Result.s := 'Unknown error: ' + IntToStr(Code);
  end;
end;

function n_label_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

//==============================================================================
// Library Functions - Label Creation and Destruction
//==============================================================================

// label#(parent#) - Create a new label with parent (empty text)
function p_label_new(var Args: array of TAsmData): TAsmData;
var
  Lbl: TBasLabel;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'label#') then Exit();

  try
    ParentObj := TFmxObject(Args[0].p);
    Lbl := TBasLabel.Create(nil);
    Lbl.BasicEngine := ModuleEngine;
    Lbl.ConsoleOutput := ModuleOutput;
    Lbl.Parent := ParentObj;

    // Set sensible defaults
    Lbl.Text := '';
    Lbl.Align := TAlignLayout.None;
    Lbl.AutoSize := True;
    Lbl.WordWrap := False;

    Result.p := Pointer(Lbl);

//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Lbl, LABEL_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'label#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// label#(parent#, text$) - Create with text
function p_label_new_text(var Args: array of TAsmData): TAsmData;
var
  Lbl: TBasLabel;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'label#') then Exit();

  try
    ParentObj := TFmxObject(Args[0].p);
    Lbl := TBasLabel.Create(nil);
    Lbl.BasicEngine := ModuleEngine;
    Lbl.ConsoleOutput := ModuleOutput;
    Lbl.Parent := ParentObj;

    Lbl.Text := Args[1].s;
    Lbl.Align := TAlignLayout.None;
    Lbl.AutoSize := True;
    Lbl.WordWrap := False;

    Result.p := Pointer(Lbl);

//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Lbl, LABEL_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'label#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// label#(parent#, text$, x, y) - Create with text and position
function p_label_new_pos(var Args: array of TAsmData): TAsmData;
var
  Lbl: TBasLabel;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'label#') then Exit();

  try
    ParentObj := TFmxObject(Args[0].p);
    Lbl := TBasLabel.Create(nil);
    Lbl.BasicEngine := ModuleEngine;
    Lbl.ConsoleOutput := ModuleOutput;
    Lbl.Parent := ParentObj;

    Lbl.Text := Args[1].s;
    Lbl.Position.X := Args[2].n;
    Lbl.Position.Y := Args[3].n;
    Lbl.Align := TAlignLayout.None;
    Lbl.AutoSize := True;
    Lbl.WordWrap := False;

    Result.p := Pointer(Lbl);

//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Lbl, LABEL_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'label#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// label#(parent#, text$, x, y, width, height) - Create with text, position and size
function p_label_new_full(var Args: array of TAsmData): TAsmData;
var
  Lbl: TBasLabel;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'label#') then Exit();

  try
    ParentObj := TFmxObject(Args[0].p);
    Lbl := TBasLabel.Create(nil);
    Lbl.BasicEngine := ModuleEngine;
    Lbl.ConsoleOutput := ModuleOutput;
    Lbl.Parent := ParentObj;

    Lbl.Text := Args[1].s;
    Lbl.Position.X := Args[2].n;
    Lbl.Position.Y := Args[3].n;
    Lbl.Width := Args[4].n;
    Lbl.Height := Args[5].n;
    Lbl.Align := TAlignLayout.None;
    Lbl.AutoSize := False;
    Lbl.WordWrap := False;

    Result.p := Pointer(Lbl);

//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Add(Lbl, LABEL_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'label#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// label_free(label#) - Free a label
function n_label_free(var Args: array of TAsmData): TAsmData;
var
  Lbl: TBasLabel;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_free') then Exit();

  try
    Lbl := TBasLabel(Args[0].p);
    Lbl.DisconnectAllEvents;
    Lbl.Free();

//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Collect(IntToStr(NativeInt(Args[0].p)));

    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_LABEL, 'label_free: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Text Content
//==============================================================================

// label_text$(label#) - Get text
function s_label_text_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_text$') then Exit();

  try
    Result.s := TBasLabel(Args[0].p).Text;
  except
  end;
end;

// label_text#(label#, text$) - Set text
function p_label_text_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_text#') then Exit();

  try
    TBasLabel(Args[0].p).Text := Args[1].s;
  except
  end;
end;

//==============================================================================
// Library Functions - Font Properties
//==============================================================================

// label_fontfamily$(label#) - Get font family
function s_label_fontfamily_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_fontfamily$') then Exit();

  try
    Result.s := TBasLabel(Args[0].p).TextSettings.Font.Family;
  except
  end;
end;

// label_fontfamily#(label#, family$) - Set font family
function p_label_fontfamily_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_fontfamily#') then Exit();

  try
    // Remove Family from StyledSettings so our explicit setting takes effect
    //TBasLabel(Args[0].p).StyledSettings := TBasLabel(Args[0].p).StyledSettings - [TStyledSetting.Family];
    TBasLabel(Args[0].p).StyledSettings := [];
    TBasLabel(Args[0].p).TextSettings.Font.Family := Args[1].s;
  except
  end;
end;

// label_fontsize(label#) - Get font size
function n_label_fontsize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_fontsize') then Exit();

  try
    Result.n := TBasLabel(Args[0].p).TextSettings.Font.Size;
  except
  end;
end;

// label_fontsize#(label#, size) - Set font size
function p_label_fontsize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_fontsize#') then Exit();

  try
    // Remove Size from StyledSettings so our explicit setting takes effect
    //TBasLabel(Args[0].p).StyledSettings := TBasLabel(Args[0].p).StyledSettings - [TStyledSetting.Size];
    TBasLabel(Args[0].p).StyledSettings := [];
    TBasLabel(Args[0].p).TextSettings.Font.Size := Args[1].n;
  except
  end;
end;

// label_fontcolor$(label#) - Get font color
function s_label_fontcolor_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_fontcolor$') then Exit();

  try
    Result.s := TUtils.AlphaColorToStr(TBasLabel(Args[0].p).TextSettings.FontColor);
  except
  end;
end;

// label_fontcolor#(label#, color$) - Set font color
function p_label_fontcolor_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_fontcolor#') then Exit();

  try
    // Remove FontColor from StyledSettings so our explicit setting takes effect
    //TBasLabel(Args[0].p).StyledSettings := TBasLabel(Args[0].p).StyledSettings - [TStyledSetting.FontColor];
    TBasLabel(Args[0].p).StyledSettings := [];
    TBasLabel(Args[0].p).TextSettings.FontColor := Tutils.ColorToAlphaColor(Args[1].s);
  except
  end;
end;

// label_bold(label#) - Get bold
function n_label_bold_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_bold') then Exit();

  try
    if TFontStyle.fsBold in TBasLabel(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// label_bold#(label#, value) - Set bold
function p_label_bold_set(var Args: array of TAsmData): TAsmData;
var
  Style: TFontStyles;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_bold#') then Exit();

  try
    // Remove Style from StyledSettings so our explicit setting takes effect
    //TBasLabel(Args[0].p).StyledSettings := TBasLabel(Args[0].p).StyledSettings - [TStyledSetting.Style];
    TBasLabel(Args[0].p).StyledSettings := [];
    Style := TBasLabel(Args[0].p).TextSettings.Font.Style;
    if Args[1].n <> 0 then
      Include(Style, TFontStyle.fsBold)
    else
      Exclude(Style, TFontStyle.fsBold);
    TBasLabel(Args[0].p).TextSettings.Font.Style := Style;
  except
  end;
end;

// label_italic(label#) - Get italic
function n_label_italic_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_italic') then Exit();

  try
    if TFontStyle.fsItalic in TBasLabel(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// label_italic#(label#, value) - Set italic
function p_label_italic_set(var Args: array of TAsmData): TAsmData;
var
  Style: TFontStyles;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_italic#') then Exit();

  try
    // Remove Style from StyledSettings so our explicit setting takes effect
    //TBasLabel(Args[0].p).StyledSettings := TBasLabel(Args[0].p).StyledSettings - [TStyledSetting.Style];
    TBasLabel(Args[0].p).StyledSettings := [];
    Style := TBasLabel(Args[0].p).TextSettings.Font.Style;
    if Args[1].n <> 0 then
      Include(Style, TFontStyle.fsItalic)
    else
      Exclude(Style, TFontStyle.fsItalic);
    TBasLabel(Args[0].p).TextSettings.Font.Style := Style;
  except
  end;
end;

// label_underline(label#) - Get underline
function n_label_underline_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_underline') then Exit();

  try
    if TFontStyle.fsUnderline in TBasLabel(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// label_underline#(label#, value) - Set underline
function p_label_underline_set(var Args: array of TAsmData): TAsmData;
var
  Style: TFontStyles;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_underline#') then Exit();

  try
    // Remove Style from StyledSettings so our explicit setting takes effect
    //TBasLabel(Args[0].p).StyledSettings := TBasLabel(Args[0].p).StyledSettings - [TStyledSetting.Style];
    TBasLabel(Args[0].p).StyledSettings := [];
    Style := TBasLabel(Args[0].p).TextSettings.Font.Style;
    if Args[1].n <> 0 then
      Include(Style, TFontStyle.fsUnderline)
    else
      Exclude(Style, TFontStyle.fsUnderline);
    TBasLabel(Args[0].p).TextSettings.Font.Style := Style;
  except
  end;
end;

// label_strikeout(label#) - Get strikeout
function n_label_strikeout_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_strikeout') then Exit();

  try
    if TFontStyle.fsStrikeOut in TBasLabel(Args[0].p).TextSettings.Font.Style then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// label_strikeout#(label#, value) - Set strikeout
function p_label_strikeout_set(var Args: array of TAsmData): TAsmData;
var
  Style: TFontStyles;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_strikeout#') then Exit();

  try
    // Remove Style from StyledSettings so our explicit setting takes effect
    //TBasLabel(Args[0].p).StyledSettings := TBasLabel(Args[0].p).StyledSettings - [TStyledSetting.Style];
    TBasLabel(Args[0].p).StyledSettings := [];
    Style := TBasLabel(Args[0].p).TextSettings.Font.Style;
    if Args[1].n <> 0 then
      Include(Style, TFontStyle.fsStrikeOut)
    else
      Exclude(Style, TFontStyle.fsStrikeOut);
    TBasLabel(Args[0].p).TextSettings.Font.Style := Style;
  except
  end;
end;

//==============================================================================
// Library Functions - Text Alignment
//==============================================================================

// label_textalign(label#) - Get horizontal text alignment
function n_label_textalign_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_textalign') then Exit();

  try
    Result.n := TextAlignToInt(TBasLabel(Args[0].p).TextSettings.HorzAlign);
  except
  end;
end;

// label_textalign#(label#, value) - Set horizontal text alignment
function p_label_textalign_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_textalign#') then Exit();

  try
    TBasLabel(Args[0].p).TextSettings.HorzAlign := IntToTextAlign(Trunc(Args[1].n));
  except
  end;
end;

// label_vertalign(label#) - Get vertical text alignment
function n_label_vertalign_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_vertalign') then Exit();

  try
    Result.n := TextAlignToInt(TBasLabel(Args[0].p).TextSettings.VertAlign);
  except
  end;
end;

// label_vertalign#(label#, value) - Set vertical text alignment
function p_label_vertalign_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_vertalign#') then Exit();

  try
    TBasLabel(Args[0].p).TextSettings.VertAlign := IntToTextAlign(Trunc(Args[1].n));
  except
  end;
end;

//==============================================================================
// Library Functions - Word Wrap and Auto Size
//==============================================================================

// label_wordwrap(label#) - Get word wrap
function n_label_wordwrap_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_wordwrap') then Exit();

  try
    if TBasLabel(Args[0].p).TextSettings.WordWrap then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// label_wordwrap#(label#, value) - Set word wrap
function p_label_wordwrap_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_wordwrap#') then Exit();

  try
    TBasLabel(Args[0].p).TextSettings.WordWrap := (Args[1].n <> 0);
  except
  end;
end;

// label_autosize(label#) - Get auto size
function n_label_autosize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_autosize') then Exit();

  try
    if TBasLabel(Args[0].p).AutoSize then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// label_autosize#(label#, value) - Set auto size
function p_label_autosize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_autosize#') then Exit();

  try
    TBasLabel(Args[0].p).AutoSize := (Args[1].n <> 0);
  except
  end;
end;

//==============================================================================
// Library Functions - Position and Size
//==============================================================================

// label_x(label#) - Get X position
function n_label_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_x') then Exit();

  try
    Result.n := TBasLabel(Args[0].p).Position.X;
  except
  end;
end;

// label_x#(label#, value) - Set X position
function p_label_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_x#') then Exit();

  try
    TBasLabel(Args[0].p).Position.X := Args[1].n;
  except
  end;
end;

// label_y(label#) - Get Y position
function n_label_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_y') then Exit();

  try
    Result.n := TBasLabel(Args[0].p).Position.Y;
  except
  end;
end;

// label_y#(label#, value) - Set Y position
function p_label_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_y#') then Exit();

  try
    TBasLabel(Args[0].p).Position.Y := Args[1].n;
  except
  end;
end;

// label_width(label#) - Get width
function n_label_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_width') then Exit();

  try
    Result.n := TBasLabel(Args[0].p).Width;
  except
  end;
end;

// label_width#(label#, value) - Set width
function p_label_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_width#') then Exit();

  try
    TBasLabel(Args[0].p).Width := Args[1].n;
  except
  end;
end;

// label_height(label#) - Get height
function n_label_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_height') then Exit();

  try
    Result.n := TBasLabel(Args[0].p).Height;
  except
  end;
end;

// label_height#(label#, value) - Set height
function p_label_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_height#') then Exit();

  try
    TBasLabel(Args[0].p).Height := Args[1].n;
  except
  end;
end;

// label_bounds#(label#, x, y, width, height) - Set all bounds at once
function p_label_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_bounds#') then Exit();

  try
    TBasLabel(Args[0].p).SetBounds(Args[1].n, Args[2].n, Args[3].n, Args[4].n);
  except
  end;
end;

// label_move#(label#, x, y) - Set position
function p_label_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_move#') then Exit();

  try
    TBasLabel(Args[0].p).Position.X := Args[1].n;
    TBasLabel(Args[0].p).Position.Y := Args[2].n;
  except
  end;
end;

// label_size#(label#, width, height) - Set size
function p_label_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_size#') then Exit();

  try
    TBasLabel(Args[0].p).Width := Args[1].n;
    TBasLabel(Args[0].p).Height := Args[2].n;
  except
  end;
end;

//==============================================================================
// Library Functions - Alignment
//==============================================================================

// label_align(label#) - Get alignment
function n_label_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_align') then Exit();

  try
    Result.n := AlignToInt(TBasLabel(Args[0].p).Align);
  except
  end;
end;

// label_align#(label#, value) - Set alignment
function p_label_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_align#') then Exit();

  try
    TBasLabel(Args[0].p).Align := IntToAlign(Trunc(Args[1].n));
  except
  end;
end;

//==============================================================================
// Library Functions - Margins
//==============================================================================

// label_marginleft(label#) - Get left margin
function n_label_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_marginleft') then Exit();

  try
    Result.n := TBasLabel(Args[0].p).Margins.Left;
  except
  end;
end;

// label_marginleft#(label#, value) - Set left margin
function p_label_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_marginleft#') then Exit();

  try
    TBasLabel(Args[0].p).Margins.Left := Args[1].n;
  except
  end;
end;

// label_margintop(label#) - Get top margin
function n_label_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_margintop') then Exit();

  try
    Result.n := TBasLabel(Args[0].p).Margins.Top;
  except
  end;
end;

// label_margintop#(label#, value) - Set top margin
function p_label_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_margintop#') then Exit();

  try
    TBasLabel(Args[0].p).Margins.Top := Args[1].n;
  except
  end;
end;

// label_marginright(label#) - Get right margin
function n_label_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_marginright') then Exit();

  try
    Result.n := TBasLabel(Args[0].p).Margins.Right;
  except
  end;
end;

// label_marginright#(label#, value) - Set right margin
function p_label_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_marginright#') then Exit();

  try
    TBasLabel(Args[0].p).Margins.Right := Args[1].n;
  except
  end;
end;

// label_marginbottom(label#) - Get bottom margin
function n_label_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_marginbottom') then Exit();

  try
    Result.n := TBasLabel(Args[0].p).Margins.Bottom;
  except
  end;
end;

// label_marginbottom#(label#, value) - Set bottom margin
function p_label_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_marginbottom#') then Exit();

  try
    TBasLabel(Args[0].p).Margins.Bottom := Args[1].n;
  except
  end;
end;

// label_margins#(label#, left, top, right, bottom) - Set all margins
function p_label_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_margins#') then Exit();

  try
    with TBasLabel(Args[0].p).Margins do
    begin
      Left := Args[1].n;
      Top := Args[2].n;
      Right := Args[3].n;
      Bottom := Args[4].n;
    end;
  except
  end;
end;

// label_margin#(label#, value) - Set uniform margin
function p_label_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_margin#') then Exit();

  try
    with TBasLabel(Args[0].p).Margins do
    begin
      Left := Args[1].n;
      Top := Args[1].n;
      Right := Args[1].n;
      Bottom := Args[1].n;
    end;
  except
  end;
end;

//==============================================================================
// Library Functions - Visibility and Behavior
//==============================================================================

// label_visible(label#) - Get visible
function n_label_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_visible') then Exit();

  try
    if TBasLabel(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// label_visible#(label#, value) - Set visible
function p_label_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_visible#') then Exit();

  try
    TBasLabel(Args[0].p).Visible := (Args[1].n <> 0);
  except
  end;
end;

// label_enabled(label#) - Get enabled
function n_label_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_enabled') then Exit();

  try
    if TBasLabel(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// label_enabled#(label#, value) - Set enabled
function p_label_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_enabled#') then Exit();

  try
    TBasLabel(Args[0].p).Enabled := (Args[1].n <> 0);
  except
  end;
end;

// label_opacity(label#) - Get opacity (0.0-1.0)
function n_label_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_opacity') then Exit();

  try
    Result.n := TBasLabel(Args[0].p).Opacity;
  except
  end;
end;

// label_opacity#(label#, value) - Set opacity (0.0-1.0)
function p_label_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_opacity#') then Exit();

  try
    TBasLabel(Args[0].p).Opacity := Args[1].n;
  except
  end;
end;

// label_hittest(label#) - Get hit test
function n_label_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_hittest') then Exit();

  try
    if TBasLabel(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// label_hittest#(label#, value) - Set hit test
function p_label_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_hittest#') then Exit();

  try
    TBasLabel(Args[0].p).HitTest := (Args[1].n <> 0);
  except
  end;
end;

//==============================================================================
// Library Functions - Tag and Rotation
//==============================================================================

// label_tag(label#) - Get tag
function n_label_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_tag') then Exit();

  try
    Result.n := TBasLabel(Args[0].p).Tag;
  except
  end;
end;

// label_tag#(label#, value) - Set tag
function p_label_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_tag#') then Exit();

  try
    TBasLabel(Args[0].p).Tag := Trunc(Args[1].n);
  except
  end;
end;

// label_rotation(label#) - Get rotation angle
function n_label_rotation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_rotation') then Exit();

  try
    Result.n := TBasLabel(Args[0].p).RotationAngle;
  except
  end;
end;

// label_rotation#(label#, value) - Set rotation angle
function p_label_rotation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_rotation#') then Exit();

  try
    TBasLabel(Args[0].p).RotationAngle := Args[1].n;
  except
  end;
end;

//==============================================================================
// Library Functions - Parent
//==============================================================================

// label_parent#(label#) - Get parent
function p_label_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_parent#') then Exit();

  try
    Result.p := Pointer(TBasLabel(Args[0].p).Parent);
  except
  end;
end;

// label_parent#(label#, parent#) - Set parent
function p_label_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_parent#') then Exit();
  if not ValidateParent(Args[1].p, 'label_parent#') then Exit();

  try
    TBasLabel(Args[0].p).Parent := TFmxObject(Args[1].p);
  except
  end;
end;

// label_bringtofront#(label#) - Bring to front
function p_label_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_bringtofront#') then Exit();

  try
    TBasLabel(Args[0].p).BringToFront;
  except
  end;
end;

// label_sendtoback#(label#) - Send to back
function p_label_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLabel(Args[0].p, 'label_sendtoback#') then Exit();

  try
    TBasLabel(Args[0].p).SendToBack;
  except
  end;
end;

//==============================================================================
// Library Functions - Event Callbacks
//==============================================================================

function p_label_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onclick#') then Exit();
  try
    TBasLabel(Args[0].p).OnClickFunc := Args[1].s;
  except
  end;
end;

function s_label_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onclick$') then Exit();
  try
    Result.s := TBasLabel(Args[0].p).OnClickFunc;
  except
  end;
end;

function p_label_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_ondblclick#') then Exit();
  try
    TBasLabel(Args[0].p).OnDblClickFunc := Args[1].s;
  except
  end;
end;

function s_label_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_ondblclick$') then Exit();
  try
    Result.s := TBasLabel(Args[0].p).OnDblClickFunc;
  except
  end;
end;

function p_label_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onmousedown#') then Exit();
  try
    TBasLabel(Args[0].p).OnMouseDownFunc := Args[1].s;
  except
  end;
end;

function s_label_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onmousedown$') then Exit();
  try
    Result.s := TBasLabel(Args[0].p).OnMouseDownFunc;
  except
  end;
end;

function p_label_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onmouseup#') then Exit();
  try
    TBasLabel(Args[0].p).OnMouseUpFunc := Args[1].s;
  except
  end;
end;

function s_label_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onmouseup$') then Exit();
  try
    Result.s := TBasLabel(Args[0].p).OnMouseUpFunc;
  except
  end;
end;

function p_label_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onmousemove#') then Exit();
  try
    TBasLabel(Args[0].p).OnMouseMoveFunc := Args[1].s;
  except
  end;
end;

function s_label_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onmousemove$') then Exit();
  try
    Result.s := TBasLabel(Args[0].p).OnMouseMoveFunc;
  except
  end;
end;

function p_label_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onmouseenter#') then Exit();
  try
    TBasLabel(Args[0].p).OnMouseEnterFunc := Args[1].s;
  except
  end;
end;

function s_label_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onmouseenter$') then Exit();
  try
    Result.s := TBasLabel(Args[0].p).OnMouseEnterFunc;
  except
  end;
end;

function p_label_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onmouseleave#') then Exit();
  try
    TBasLabel(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  except
  end;
end;

function s_label_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onmouseleave$') then Exit();
  try
    Result.s := TBasLabel(Args[0].p).OnMouseLeaveFunc;
  except
  end;
end;

function p_label_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onresize#') then Exit();
  try
    TBasLabel(Args[0].p).OnResizeFunc := Args[1].s;
  except
  end;
end;

function s_label_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_onresize$') then Exit();
  try
    Result.s := TBasLabel(Args[0].p).OnResizeFunc;
  except
  end;
end;

function p_label_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateLabel(Args[0].p, 'label_clearcallbacks#') then Exit();
  try
    with TBasLabel(Args[0].p) do
    begin
      OnClickFunc := '';
      OnDblClickFunc := '';
      OnMouseDownFunc := '';
      OnMouseUpFunc := '';
      OnMouseMoveFunc := '';
      OnMouseEnterFunc := '';
      OnMouseLeaveFunc := '';
      OnResizeFunc := '';
    end;
  except
  end;
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterLabelFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;

  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_label_error; Lib.Add('label_error@', Fn);
  Fn.Entry := @s_label_errormsg; Lib.Add('label_errormsg$@', Fn);
  Fn.Entry := @s_label_strerror; Lib.Add('label_strerror$@n', Fn);
  Fn.Entry := @n_label_ClearError; Lib.Add('label_clearerror@', Fn);

  // Label creation/destruction
  Fn.Entry := @p_label_new; Lib.Add('label#@#', Fn);
  Fn.Entry := @p_label_new_text; Lib.Add('label#@#$', Fn);
  Fn.Entry := @p_label_new_pos; Lib.Add('label#@#$nn', Fn);
  Fn.Entry := @p_label_new_full; Lib.Add('label#@#$nnnn', Fn);
  Fn.Entry := @n_label_free; Lib.Add('label_free@#', Fn);

  // Text content
  Fn.Entry := @s_label_text_get; Lib.Add('label_text$@#', Fn);
  Fn.Entry := @p_label_text_set; Lib.Add('label_text#@#$', Fn);

  // Font properties
  Fn.Entry := @s_label_fontfamily_get; Lib.Add('label_fontfamily$@#', Fn);
  Fn.Entry := @p_label_fontfamily_set; Lib.Add('label_fontfamily#@#$', Fn);
  Fn.Entry := @n_label_fontsize_get; Lib.Add('label_fontsize@#', Fn);
  Fn.Entry := @p_label_fontsize_set; Lib.Add('label_fontsize#@#n', Fn);
  Fn.Entry := @s_label_fontcolor_get; Lib.Add('label_fontcolor$@#', Fn);
  Fn.Entry := @p_label_fontcolor_set; Lib.Add('label_fontcolor#@#$', Fn);
  Fn.Entry := @n_label_bold_get; Lib.Add('label_bold@#', Fn);
  Fn.Entry := @p_label_bold_set; Lib.Add('label_bold#@#n', Fn);
  Fn.Entry := @n_label_italic_get; Lib.Add('label_italic@#', Fn);
  Fn.Entry := @p_label_italic_set; Lib.Add('label_italic#@#n', Fn);
  Fn.Entry := @n_label_underline_get; Lib.Add('label_underline@#', Fn);
  Fn.Entry := @p_label_underline_set; Lib.Add('label_underline#@#n', Fn);
  Fn.Entry := @n_label_strikeout_get; Lib.Add('label_strikeout@#', Fn);
  Fn.Entry := @p_label_strikeout_set; Lib.Add('label_strikeout#@#n', Fn);

  // Text alignment
  Fn.Entry := @n_label_textalign_get; Lib.Add('label_textalign@#', Fn);
  Fn.Entry := @p_label_textalign_set; Lib.Add('label_textalign#@#n', Fn);
  Fn.Entry := @n_label_vertalign_get; Lib.Add('label_vertalign@#', Fn);
  Fn.Entry := @p_label_vertalign_set; Lib.Add('label_vertalign#@#n', Fn);

  // Word wrap and auto size
  Fn.Entry := @n_label_wordwrap_get; Lib.Add('label_wordwrap@#', Fn);
  Fn.Entry := @p_label_wordwrap_set; Lib.Add('label_wordwrap#@#n', Fn);
  Fn.Entry := @n_label_autosize_get; Lib.Add('label_autosize@#', Fn);
  Fn.Entry := @p_label_autosize_set; Lib.Add('label_autosize#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_label_x_get; Lib.Add('label_x@#', Fn);
  Fn.Entry := @p_label_x_set; Lib.Add('label_x#@#n', Fn);
  Fn.Entry := @n_label_y_get; Lib.Add('label_y@#', Fn);
  Fn.Entry := @p_label_y_set; Lib.Add('label_y#@#n', Fn);
  Fn.Entry := @n_label_width_get; Lib.Add('label_width@#', Fn);
  Fn.Entry := @p_label_width_set; Lib.Add('label_width#@#n', Fn);
  Fn.Entry := @n_label_height_get; Lib.Add('label_height@#', Fn);
  Fn.Entry := @p_label_height_set; Lib.Add('label_height#@#n', Fn);
  Fn.Entry := @p_label_bounds_set; Lib.Add('label_bounds#@#nnnn', Fn);
  Fn.Entry := @p_label_move_set; Lib.Add('label_move#@#nn', Fn);
  Fn.Entry := @p_label_size_set; Lib.Add('label_size#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_label_align_get; Lib.Add('label_align@#', Fn);
  Fn.Entry := @p_label_align_set; Lib.Add('label_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_label_marginleft_get; Lib.Add('label_marginleft@#', Fn);
  Fn.Entry := @p_label_marginleft_set; Lib.Add('label_marginleft#@#n', Fn);
  Fn.Entry := @n_label_margintop_get; Lib.Add('label_margintop@#', Fn);
  Fn.Entry := @p_label_margintop_set; Lib.Add('label_margintop#@#n', Fn);
  Fn.Entry := @n_label_marginright_get; Lib.Add('label_marginright@#', Fn);
  Fn.Entry := @p_label_marginright_set; Lib.Add('label_marginright#@#n', Fn);
  Fn.Entry := @n_label_marginbottom_get; Lib.Add('label_marginbottom@#', Fn);
  Fn.Entry := @p_label_marginbottom_set; Lib.Add('label_marginbottom#@#n', Fn);
  Fn.Entry := @p_label_margins_set; Lib.Add('label_margins#@#nnnn', Fn);
  Fn.Entry := @p_label_margin_set; Lib.Add('label_margin#@#n', Fn);

  // Visibility and behavior
  Fn.Entry := @n_label_visible_get; Lib.Add('label_visible@#', Fn);
  Fn.Entry := @p_label_visible_set; Lib.Add('label_visible#@#n', Fn);
  Fn.Entry := @n_label_enabled_get; Lib.Add('label_enabled@#', Fn);
  Fn.Entry := @p_label_enabled_set; Lib.Add('label_enabled#@#n', Fn);
  Fn.Entry := @n_label_opacity_get; Lib.Add('label_opacity@#', Fn);
  Fn.Entry := @p_label_opacity_set; Lib.Add('label_opacity#@#n', Fn);
  Fn.Entry := @n_label_hittest_get; Lib.Add('label_hittest@#', Fn);
  Fn.Entry := @p_label_hittest_set; Lib.Add('label_hittest#@#n', Fn);

  // Tag and rotation
  Fn.Entry := @n_label_tag_get; Lib.Add('label_tag@#', Fn);
  Fn.Entry := @p_label_tag_set; Lib.Add('label_tag#@#n', Fn);
  Fn.Entry := @n_label_rotation_get; Lib.Add('label_rotation@#', Fn);
  Fn.Entry := @p_label_rotation_set; Lib.Add('label_rotation#@#n', Fn);

  // Parent
  Fn.Entry := @p_label_parent_get; Lib.Add('label_parent#@#', Fn);
  Fn.Entry := @p_label_parent_set; Lib.Add('label_parent#@##', Fn);
  Fn.Entry := @p_label_bringtofront; Lib.Add('label_bringtofront#@#', Fn);
  Fn.Entry := @p_label_sendtoback; Lib.Add('label_sendtoback#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_label_onclick_set; Lib.Add('label_onclick#@#$', Fn);
  Fn.Entry := @s_label_onclick_get; Lib.Add('label_onclick$@#', Fn);
  Fn.Entry := @p_label_ondblclick_set; Lib.Add('label_ondblclick#@#$', Fn);
  Fn.Entry := @s_label_ondblclick_get; Lib.Add('label_ondblclick$@#', Fn);
  Fn.Entry := @p_label_onmousedown_set; Lib.Add('label_onmousedown#@#$', Fn);
  Fn.Entry := @s_label_onmousedown_get; Lib.Add('label_onmousedown$@#', Fn);
  Fn.Entry := @p_label_onmouseup_set; Lib.Add('label_onmouseup#@#$', Fn);
  Fn.Entry := @s_label_onmouseup_get; Lib.Add('label_onmouseup$@#', Fn);
  Fn.Entry := @p_label_onmousemove_set; Lib.Add('label_onmousemove#@#$', Fn);
  Fn.Entry := @s_label_onmousemove_get; Lib.Add('label_onmousemove$@#', Fn);
  Fn.Entry := @p_label_onmouseenter_set; Lib.Add('label_onmouseenter#@#$', Fn);
  Fn.Entry := @s_label_onmouseenter_get; Lib.Add('label_onmouseenter$@#', Fn);
  Fn.Entry := @p_label_onmouseleave_set; Lib.Add('label_onmouseleave#@#$', Fn);
  Fn.Entry := @s_label_onmouseleave_get; Lib.Add('label_onmouseleave$@#', Fn);
  Fn.Entry := @p_label_onresize_set; Lib.Add('label_onresize#@#$', Fn);
  Fn.Entry := @s_label_onresize_get; Lib.Add('label_onresize$@#', Fn);
  Fn.Entry := @p_label_clearcallbacks; Lib.Add('label_clearcallbacks#@#', Fn);
end;

end.

