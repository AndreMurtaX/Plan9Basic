unit LayoutLib;

{******************************************************************************
  LayoutLib - Layout Container Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TLayout wrapper functionality for creating and
  managing container controls in Plan9Basic programs. TLayout is a non-visual
  container that helps organize child controls with alignment and positioning.

  Function Count: 78 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All layouts are created at RUNTIME using TLayout.Create with dynamic parent
  assignment. This ensures proper dynamic creation across all FireMonkey platforms.

  FEATURES:
  =========
  - Layout creation and lifecycle management
  - Comprehensive property access (position, size, alignment, margins, padding)
  - Parent/child relationship management
  - Complete event support with BASIC callback integration
  - Clipping and hit-testing control

  EVENTS SUPPORT (following FormLib pattern):
  ============================================
  - OnClick: Layout was clicked
  - OnDblClick: Layout was double-clicked
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over layout
  - OnMouseEnter: Mouse entered layout area
  - OnMouseLeave: Mouse left layout area
  - OnMouseWheel: Mouse wheel scrolled
  - OnResize: Layout is being resized
  - OnResized: Layout resize completed
  - OnPaint: Layout needs repainting
  - OnDragEnter: Drag operation entered
  - OnDragOver: Dragging over layout
  - OnDragDrop: Item dropped on layout
  - OnDragLeave: Drag operation left

  ALIGNMENT VALUES:
  =================
  0 = None         - No alignment (manual positioning)
  1 = Top          - Align to top
  2 = Left         - Align to left
  3 = Right        - Align to right
  4 = Bottom       - Align to bottom
  5 = MostTop      - Align to very top (above Top)
  6 = MostBottom   - Align to very bottom (below Bottom)
  7 = MostLeft     - Align to very left (before Left)
  8 = MostRight    - Align to very right (after Right)
  9 = Client       - Fill remaining client area
  10 = Contents    - Fit to contents
  11 = Center      - Center in parent
  12 = VertCenter  - Center vertically
  13 = HorzCenter  - Center horizontally
  14 = Horizontal  - Stretch horizontally
  15 = Vertical    - Stretch vertically
  16 = Scale       - Scale proportionally
  17 = Fit         - Fit within parent
  18 = FitLeft     - Fit and align left
  19 = FitRight    - Fit and align right

  USAGE PATTERN:
  ==============
    let frm# = form#("My App", 800, 600)
    let mainLayout# = layout#(frm#)
    layout_align#(mainLayout#, 9)  ' Client fill

    let topBar# = layout#(mainLayout#)
    layout_align#(topBar#, 1)      ' Top alignment
    layout_height#(topBar#, 50)

    let content# = layout#(mainLayout#)
    layout_align#(content#, 9)     ' Fill remaining

    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnLayoutClick(sender#)
      println "Layout clicked!"
    endfunction

    function OnLayoutMouseMove(sender#, x, y)
      println "Mouse at: " + stri$(x) + ", " + stri$(y)
    endfunction

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Layouts,
  basic, exec, UnitGC;

type
  // Forward declaration
  TBasLayout = class;

  {****************************************************************************
    TBasLayout - Extended TLayout with BASIC event callback support

    Wraps a TLayout and provides event bridging to Plan9Basic user functions.
    Each event stores the name of a BASIC function to call when triggered.
  ****************************************************************************}
  TBasLayout = class(TLayout)
  private
    // Event callback function names (stored in lowercase+signature format)
    FOnClickFunc: String;
    FOnDblClickFunc: String;
    FOnMouseDownFunc: String;
    FOnMouseUpFunc: String;
    FOnMouseMoveFunc: String;
    FOnMouseEnterFunc: String;
    FOnMouseLeaveFunc: String;
    FOnMouseWheelFunc: String;
    FOnResizeFunc: String;
    FOnResizedFunc: String;
    FOnPaintFunc: String;
    FOnDragEnterFunc: String;
    FOnDragOverFunc: String;
    FOnDragDropFunc: String;
    FOnDragLeaveFunc: String;

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
    procedure InternalOnMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
    procedure InternalOnResize(Sender: TObject);
    procedure InternalOnResized(Sender: TObject);
    procedure InternalOnPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
    procedure InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure InternalOnDragLeave(Sender: TObject);

    // Callback execution helper
    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
    function ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;

    // Property setters that connect/disconnect individual events
    procedure SetOnClickFunc(const Value: String);
    procedure SetOnDblClickFunc(const Value: String);
    procedure SetOnMouseDownFunc(const Value: String);
    procedure SetOnMouseUpFunc(const Value: String);
    procedure SetOnMouseMoveFunc(const Value: String);
    procedure SetOnMouseEnterFunc(const Value: String);
    procedure SetOnMouseLeaveFunc(const Value: String);
    procedure SetOnMouseWheelFunc(const Value: String);
    procedure SetOnResizeFunc(const Value: String);
    procedure SetOnResizedFunc(const Value: String);
    procedure SetOnPaintFunc(const Value: String);
    procedure SetOnDragEnterFunc(const Value: String);
    procedure SetOnDragOverFunc(const Value: String);
    procedure SetOnDragDropFunc(const Value: String);
    procedure SetOnDragLeaveFunc(const Value: String);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    // Disconnect all events (for cleanup)
    procedure DisconnectEvents();

    // Check if callback exists
    function CallbackExists(const FuncName: String): Boolean;

    // Properties for event function names
    property OnClickFunc: String read FOnClickFunc write SetOnClickFunc;
    property OnDblClickFunc: String read FOnDblClickFunc write SetOnDblClickFunc;
    property OnMouseDownFunc: String read FOnMouseDownFunc write SetOnMouseDownFunc;
    property OnMouseUpFunc: String read FOnMouseUpFunc write SetOnMouseUpFunc;
    property OnMouseMoveFunc: String read FOnMouseMoveFunc write SetOnMouseMoveFunc;
    property OnMouseEnterFunc: String read FOnMouseEnterFunc write SetOnMouseEnterFunc;
    property OnMouseLeaveFunc: String read FOnMouseLeaveFunc write SetOnMouseLeaveFunc;
    property OnMouseWheelFunc: String read FOnMouseWheelFunc write SetOnMouseWheelFunc;
    property OnResizeFunc: String read FOnResizeFunc write SetOnResizeFunc;
    property OnResizedFunc: String read FOnResizedFunc write SetOnResizedFunc;
    property OnPaintFunc: String read FOnPaintFunc write SetOnPaintFunc;
    property OnDragEnterFunc: String read FOnDragEnterFunc write SetOnDragEnterFunc;
    property OnDragOverFunc: String read FOnDragOverFunc write SetOnDragOverFunc;
    property OnDragDropFunc: String read FOnDragDropFunc write SetOnDragDropFunc;
    property OnDragLeaveFunc: String read FOnDragLeaveFunc write SetOnDragLeaveFunc;

    // Engine references
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
  end;

// Library registration
procedure RegisterLayoutFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  LAYOUT_GC_TAG = 'BASIC_LAYOUT';

  // Error codes
  ERR_NONE = 0;
  ERR_INVALID_LAYOUT = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INVALID_CALLBACK = 5;
  ERR_INVALID_CONTROL = 6;

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

function ValidateLayout(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_LAYOUT, FuncName + ': Nil layout pointer');
    Exit;
  end;

  // Use try-except because "is" operator can crash on invalid pointers
  try
    if not (TObject(P) is TBasLayout) then
    begin
      SetError(ERR_INVALID_LAYOUT, FuncName + ': Invalid layout object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_LAYOUT, FuncName + ': Invalid layout pointer');
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

  // Parent can be TForm, TLayout, or any TFmxObject
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

function ValidateControl(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_CONTROL, FuncName + ': Nil control pointer');
    Exit;
  end;

  try
    if not (TObject(P) is TFmxObject) then
    begin
      SetError(ERR_INVALID_CONTROL, FuncName + ': Invalid control object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_CONTROL, FuncName + ': Invalid control pointer');
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
    TAlignLayout.None:        Result := ALIGN_NONE;
    TAlignLayout.Top:         Result := ALIGN_TOP;
    TAlignLayout.Left:        Result := ALIGN_LEFT;
    TAlignLayout.Right:       Result := ALIGN_RIGHT;
    TAlignLayout.Bottom:      Result := ALIGN_BOTTOM;
    TAlignLayout.MostTop:     Result := ALIGN_MOST_TOP;
    TAlignLayout.MostBottom:  Result := ALIGN_MOST_BOTTOM;
    TAlignLayout.MostLeft:    Result := ALIGN_MOST_LEFT;
    TAlignLayout.MostRight:   Result := ALIGN_MOST_RIGHT;
    TAlignLayout.Client:      Result := ALIGN_CLIENT;
    TAlignLayout.Contents:    Result := ALIGN_CONTENTS;
    TAlignLayout.Center:      Result := ALIGN_CENTER;
    TAlignLayout.VertCenter:  Result := ALIGN_VERT_CENTER;
    TAlignLayout.HorzCenter:  Result := ALIGN_HORZ_CENTER;
    TAlignLayout.Horizontal:  Result := ALIGN_HORIZONTAL;
    TAlignLayout.Vertical:    Result := ALIGN_VERTICAL;
    TAlignLayout.Scale:       Result := ALIGN_SCALE;
    TAlignLayout.Fit:         Result := ALIGN_FIT;
    TAlignLayout.FitLeft:     Result := ALIGN_FIT_LEFT;
    TAlignLayout.FitRight:    Result := ALIGN_FIT_RIGHT;
  else
    Result := ALIGN_NONE;
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
// TBasLayout Implementation
//==============================================================================

constructor TBasLayout.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // Initialize callback function names
  FOnClickFunc := '';
  FOnDblClickFunc := '';
  FOnMouseDownFunc := '';
  FOnMouseUpFunc := '';
  FOnMouseMoveFunc := '';
  FOnMouseEnterFunc := '';
  FOnMouseLeaveFunc := '';
  FOnMouseWheelFunc := '';
  FOnResizeFunc := '';
  FOnResizedFunc := '';
  FOnPaintFunc := '';
  FOnDragEnterFunc := '';
  FOnDragOverFunc := '';
  FOnDragDropFunc := '';
  FOnDragLeaveFunc := '';

  // Initialize engine references
  FBasicEngine := nil;
  FConsoleOutput := nil;
end;

destructor TBasLayout.Destroy();
begin
  DisconnectEvents();
  inherited Destroy();
end;

procedure TBasLayout.DisconnectEvents();
begin
  Self.OnClick := nil;
  Self.OnDblClick := nil;
  Self.OnMouseDown := nil;
  Self.OnMouseUp := nil;
  Self.OnMouseMove := nil;
  Self.OnMouseEnter := nil;
  Self.OnMouseLeave := nil;
  Self.OnMouseWheel := nil;
  Self.OnResize := nil;
  Self.OnResized := nil;
  Self.OnPainting := nil;
  Self.OnDragEnter := nil;
  Self.OnDragOver := nil;
  Self.OnDragDrop := nil;
  Self.OnDragLeave := nil;
end;

function TBasLayout.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

procedure TBasLayout.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  RetVal: TAsmData;
  i: Integer;
begin
  // Prevent reentrant callback execution
  if UnitGC.GlobalCallbackBusy then Exit();

  if not Assigned(FBasicEngine) then Exit;
  if not Assigned(FConsoleOutput) then Exit;
  if FuncSignature = '' then Exit;

  UnitGC.GlobalCallbackBusy := True;
  UnitGC.SkipProcessMessages := True;
  try
    // Copy args to dynamic array
    SetLength(CallArgs, Length(Args));
    for i := 0 to High(Args) do
      CallArgs[i] := Args[i];

    try
      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs, RetType, RetVal);
    except
      on E: Exception do
      begin
        FConsoleOutput.Add('*** Layout Event Callback Error ***');
        FConsoleOutput.Add('Function: ' + FuncSignature);
        FConsoleOutput.Add('Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

function TBasLayout.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  i: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  // Prevent reentrant callback execution
  if UnitGC.GlobalCallbackBusy then Exit();

  if not Assigned(FBasicEngine) then Exit;
  if not Assigned(FConsoleOutput) then Exit;
  if FuncSignature = '' then Exit;

  UnitGC.GlobalCallbackBusy := True;
  UnitGC.SkipProcessMessages := True;
  try
    // Copy args to dynamic array
    SetLength(CallArgs, Length(Args));
    for i := 0 to High(Args) do
      CallArgs[i] := Args[i];

    try
      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs, RetType, Result);
    except
      on E: Exception do
      begin
        FConsoleOutput.Add('*** Layout Event Callback Error ***');
        FConsoleOutput.Add('Function: ' + FuncSignature);
        FConsoleOutput.Add('Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

procedure TBasLayout.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnClickFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  Signature := LowerCase(FOnClickFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasLayout.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnDblClickFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  Signature := LowerCase(FOnDblClickFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasLayout.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
  Signature: String;
begin
  if FOnMouseDownFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nnn$ (sender#, button, x, y, shift$)
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

procedure TBasLayout.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
  Signature: String;
begin
  if FOnMouseUpFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nnn$ (sender#, button, x, y, shift$)
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

procedure TBasLayout.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..3] of TAsmData;
  Signature: String;
begin
  if FOnMouseMoveFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nn$ (sender#, x, y, shift$)
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

procedure TBasLayout.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnMouseEnterFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  Signature := LowerCase(FOnMouseEnterFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasLayout.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnMouseLeaveFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  Signature := LowerCase(FOnMouseLeaveFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasLayout.InternalOnMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
  RetVal: TAsmData;
begin
  if FOnMouseWheelFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#n$ (sender#, delta, shift$) -> returns handled
  Signature := LowerCase(FOnMouseWheelFunc) + '@#n$';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := WheelDelta;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := 0;
  Args[2].p := nil;
  Args[2].s := BuildShiftString(Shift);

  RetVal := ExecuteCallbackWithResult(Signature, Args);
  Handled := (RetVal.n <> 0);
end;

procedure TBasLayout.InternalOnResize(Sender: TObject);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnResizeFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nn (sender#, width, height)
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

procedure TBasLayout.InternalOnResized(Sender: TObject);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnResizedFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nn (sender#, width, height)
  Signature := LowerCase(FOnResizedFunc) + '@#nn';

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

procedure TBasLayout.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    Self.OnClick := InternalOnClick
  else
    Self.OnClick := nil;
end;

procedure TBasLayout.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    Self.OnDblClick := InternalOnDblClick
  else
    Self.OnDblClick := nil;
end;

procedure TBasLayout.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    Self.OnDragDrop := InternalOnDragDrop
  else
    Self.OnDragDrop := nil;
end;

procedure TBasLayout.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    Self.OnDragEnter := InternalOnDragEnter
  else
    Self.OnDragEnter := nil;
end;

procedure TBasLayout.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    Self.OnDragLeave := InternalOnDragLeave
  else
    Self.OnDragLeave := nil;
end;

procedure TBasLayout.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    Self.OnDragOver := InternalOnDragOver
  else
    Self.OnDragOver := nil;
end;

procedure TBasLayout.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    Self.OnMouseDown := InternalOnMouseDown
  else
    Self.OnMouseDown := nil;
end;

procedure TBasLayout.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    Self.OnMouseEnter := InternalOnMouseEnter
  else
    Self.OnMouseEnter := nil;
end;

procedure TBasLayout.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    Self.OnMouseLeave := InternalOnMouseLeave
  else
    Self.OnMouseLeave := nil;
end;

procedure TBasLayout.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    Self.OnMouseMove := InternalOnMouseMove
  else
    Self.OnMouseMove := nil;
end;

procedure TBasLayout.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    Self.OnMouseUp := InternalOnMouseUp
  else
    Self.OnMouseUp := nil;
end;

procedure TBasLayout.SetOnMouseWheelFunc(const Value: String);
begin
  FOnMouseWheelFunc := Value;
  if Value <> '' then
    Self.OnMouseWheel := InternalOnMouseWheel
  else
    Self.OnMouseWheel := nil;
end;

procedure TBasLayout.SetOnPaintFunc(const Value: String);
begin
  FOnPaintFunc := Value;
  if Value <> '' then
    Self.OnPaint := InternalOnPaint
  else
    Self.OnPaint := nil;
end;

procedure TBasLayout.SetOnResizedFunc(const Value: String);
begin
  FOnResizedFunc := Value;
  if Value <> '' then
    Self.OnResized := InternalOnResized
  else
    Self.OnResized := nil;
end;

procedure TBasLayout.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    Self.OnResize := InternalOnResize
  else
    Self.OnResize := nil;
end;

procedure TBasLayout.InternalOnPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Args: array[0..4] of TAsmData;
  Signature: String;
begin
  if FOnPaintFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nnnn (sender#, left, top, right, bottom)
  Signature := LowerCase(FOnPaintFunc) + '@#nnnn';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := ARect.Left;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := ARect.Top;
  Args[2].p := nil;
  Args[2].s := '';

  Args[3].n := ARect.Right;
  Args[3].p := nil;
  Args[3].s := '';

  Args[4].n := ARect.Bottom;
  Args[4].p := nil;
  Args[4].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasLayout.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnDragEnterFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nn (sender#, x, y)
  Signature := LowerCase(FOnDragEnterFunc) + '@#nn';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasLayout.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
  RetVal: TAsmData;
begin
  if FOnDragOverFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nn (sender#, x, y) -> returns accept (0/1)
  Signature := LowerCase(FOnDragOverFunc) + '@#nn';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';

  RetVal := ExecuteCallbackWithResult(Signature, Args);
  if RetVal.n <> 0 then
    Operation := TDragOperation.Move
  else
    Operation := TDragOperation.None;
end;

procedure TBasLayout.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnDragDropFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  // Signature: funcname@#nn (sender#, x, y)
  Signature := LowerCase(FOnDragDropFunc) + '@#nn';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasLayout.InternalOnDragLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnDragLeaveFunc = '' then Exit;
  if not Assigned(FBasicEngine) then Exit;

  Signature := LowerCase(FOnDragLeaveFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

//==============================================================================
// Library Functions - Error Handling
//==============================================================================

// layout_error() - Get last error code
function n_layout_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

// layout_errormsg$() - Get last error message
function s_layout_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

// layout_strerror$(code) - Get error description
function s_layout_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_LAYOUT: Result.s := 'Invalid or nil layout';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent control';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Layout creation failed';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback function';
    ERR_INVALID_CONTROL: Result.s := 'Invalid control';
  else
    Result.s := 'Unknown error: ' + IntToStr(Code);
  end;
end;

// layout_clearerror() - Clear error state
function n_layout_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

//==============================================================================
// Library Functions - Layout Creation and Destruction
//==============================================================================

// layout#(parent#) - Create a new layout with parent
function p_layout_new(var Args: array of TAsmData): TAsmData;
var
  Layout: TBasLayout;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'layout#') then Exit;

  try
    ParentObj := TFmxObject(Args[0].p);
    Layout := TBasLayout.Create(nil);
    Layout.BasicEngine := ModuleEngine;
    Layout.ConsoleOutput := ModuleOutput;
    Layout.Parent := ParentObj;

    // Set sensible defaults
    Layout.Width := 100;
    Layout.Height := 100;
    Layout.Align := TAlignLayout.None;

    Result.p := Pointer(Layout);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Layout, LAYOUT_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'layout#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// layout#(parent#, width, height) - Create with size
function p_layout_new_size(var Args: array of TAsmData): TAsmData;
var
  Layout: TBasLayout;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'layout#') then Exit;

  try
    ParentObj := TFmxObject(Args[0].p);
    Layout := TBasLayout.Create(nil);
    Layout.BasicEngine := ModuleEngine;
    Layout.ConsoleOutput := ModuleOutput;
    Layout.Parent := ParentObj;

    Layout.Width := Args[1].n;
    Layout.Height := Args[2].n;
    Layout.Align := TAlignLayout.None;

    Result.p := Pointer(Layout);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Layout, LAYOUT_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'layout#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// layout#(parent#, x, y, width, height) - Create with position and size
function p_layout_new_full(var Args: array of TAsmData): TAsmData;
var
  Layout: TBasLayout;
  ParentObj: TFmxObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'layout#') then Exit;

  try
    ParentObj := TFmxObject(Args[0].p);
    Layout := TBasLayout.Create(nil);
    Layout.BasicEngine := ModuleEngine;
    Layout.ConsoleOutput := ModuleOutput;
    Layout.Parent := ParentObj;

    Layout.Position.X := Args[1].n;
    Layout.Position.Y := Args[2].n;
    Layout.Width := Args[3].n;
    Layout.Height := Args[4].n;
    Layout.Align := TAlignLayout.None;

    Result.p := Pointer(Layout);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Layout, LAYOUT_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'layout#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// layout_free(layout#) - Free a layout
function n_layout_free(var Args: array of TAsmData): TAsmData;
var
  Layout: TBasLayout;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_free') then Exit;

  try
    Layout := TBasLayout(Args[0].p);
    Layout.DisconnectEvents;
    Layout.Free();

    // Use GC to properly free the layout
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_LAYOUT, 'layout_free: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Parent/Child Management
//==============================================================================

// layout_parent#(layout#) - Get parent
function p_layout_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_parent#') then Exit;

  try
    Result.p := Pointer(TBasLayout(Args[0].p).Parent);
  except
  end;
end;

// layout_parent#(layout#, parent#) - Set parent
function p_layout_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_parent#') then Exit;
  if not ValidateParent(Args[1].p, 'layout_parent#') then Exit;

  try
    TBasLayout(Args[0].p).Parent := TFmxObject(Args[1].p);
  except
  end;
end;

// layout_childcount(layout#) - Get number of children
function n_layout_childcount(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_childcount') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).ChildrenCount;
  except
  end;
end;

// layout_child#(layout#, index) - Get child by index
function p_layout_child(var Args: array of TAsmData): TAsmData;
var
  Layout: TBasLayout;
  Index: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_child#') then Exit;

  try
    Layout := TBasLayout(Args[0].p);
    Index := Trunc(Args[1].n);
    if (Index >= 0) and (Index < Layout.ChildrenCount) then
      Result.p := Pointer(Layout.Children[Index])
    else
      SetError(ERR_INVALID_VALUE, 'layout_child#: Index out of bounds');
  except
    on E: Exception do
      SetError(ERR_INVALID_LAYOUT, 'layout_child#: ' + E.Message);
  end;
end;

// layout_bringtofront#(layout#) - Bring layout to front
function p_layout_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_bringtofront#') then Exit;

  try
    TBasLayout(Args[0].p).BringToFront;
  except
  end;
end;

// layout_sendtoback#(layout#) - Send layout to back
function p_layout_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_sendtoback#') then Exit;

  try
    TBasLayout(Args[0].p).SendToBack;
  except
  end;
end;

//==============================================================================
// Library Functions - Position and Size
//==============================================================================

// layout_x(layout#) - Get X position
function n_layout_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_x') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Position.X;
  except
  end;
end;

// layout_x#(layout#, value) - Set X position
function p_layout_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_x#') then Exit;

  try
    TBasLayout(Args[0].p).Position.X := Args[1].n;
  except
  end;
end;

// layout_y(layout#) - Get Y position
function n_layout_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_y') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Position.Y;
  except
  end;
end;

// layout_y#(layout#, value) - Set Y position
function p_layout_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_y#') then Exit;

  try
    TBasLayout(Args[0].p).Position.Y := Args[1].n;
  except
  end;
end;

// layout_width(layout#) - Get width
function n_layout_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_width') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Width;
  except
  end;
end;

// layout_width#(layout#, value) - Set width
function p_layout_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_width#') then Exit;

  try
    TBasLayout(Args[0].p).Width := Args[1].n;
  except
  end;
end;

// layout_height(layout#) - Get height
function n_layout_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_height') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Height;
  except
  end;
end;

// layout_height#(layout#, value) - Set height
function p_layout_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_height#') then Exit;

  try
    TBasLayout(Args[0].p).Height := Args[1].n;
  except
  end;
end;

// layout_bounds#(layout#, x, y, width, height) - Set all bounds at once
function p_layout_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_bounds#') then Exit;

  try
    TBasLayout(Args[0].p).SetBounds(
      Args[1].n,  // X
      Args[2].n,  // Y
      Args[3].n,  // Width
      Args[4].n   // Height
    );
  except
  end;
end;

// layout_size#(layout#, width, height) - Set size
function p_layout_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_size#') then Exit;

  try
    TBasLayout(Args[0].p).Width := Args[1].n;
    TBasLayout(Args[0].p).Height := Args[2].n;
  except
  end;
end;

// layout_move#(layout#, x, y) - Set position
function p_layout_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_move#') then Exit;

  try
    TBasLayout(Args[0].p).Position.X := Args[1].n;
    TBasLayout(Args[0].p).Position.Y := Args[2].n;
  except
  end;
end;

//==============================================================================
// Library Functions - Alignment
//==============================================================================

// layout_align(layout#) - Get alignment
function n_layout_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_align') then Exit;

  try
    Result.n := AlignToInt(TBasLayout(Args[0].p).Align);
  except
  end;
end;

// layout_align#(layout#, value) - Set alignment
function p_layout_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_align#') then Exit;

  try
    TBasLayout(Args[0].p).Align := IntToAlign(Trunc(Args[1].n));
  except
  end;
end;

//==============================================================================
// Library Functions - Margins
//==============================================================================

// layout_marginleft(layout#) - Get left margin
function n_layout_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_marginleft') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Margins.Left;
  except
  end;
end;

// layout_marginleft#(layout#, value) - Set left margin
function p_layout_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_marginleft#') then Exit;

  try
    TBasLayout(Args[0].p).Margins.Left := Args[1].n;
  except
  end;
end;

// layout_margintop(layout#) - Get top margin
function n_layout_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_margintop') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Margins.Top;
  except
  end;
end;

// layout_margintop#(layout#, value) - Set top margin
function p_layout_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_margintop#') then Exit;

  try
    TBasLayout(Args[0].p).Margins.Top := Args[1].n;
  except
  end;
end;

// layout_marginright(layout#) - Get right margin
function n_layout_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_marginright') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Margins.Right;
  except
  end;
end;

// layout_marginright#(layout#, value) - Set right margin
function p_layout_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_marginright#') then Exit;

  try
    TBasLayout(Args[0].p).Margins.Right := Args[1].n;
  except
  end;
end;

// layout_marginbottom(layout#) - Get bottom margin
function n_layout_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_marginbottom') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Margins.Bottom;
  except
  end;
end;

// layout_marginbottom#(layout#, value) - Set bottom margin
function p_layout_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_marginbottom#') then Exit;

  try
    TBasLayout(Args[0].p).Margins.Bottom := Args[1].n;
  except
  end;
end;

// layout_margins#(layout#, left, top, right, bottom) - Set all margins
function p_layout_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_margins#') then Exit;

  try
    with TBasLayout(Args[0].p).Margins do
    begin
      Left := Args[1].n;
      Top := Args[2].n;
      Right := Args[3].n;
      Bottom := Args[4].n;
    end;
  except
  end;
end;

// layout_margin#(layout#, value) - Set uniform margin
function p_layout_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_margin#') then Exit;

  try
    with TBasLayout(Args[0].p).Margins do
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
// Library Functions - Padding
//==============================================================================

// layout_paddingleft(layout#) - Get left padding
function n_layout_paddingleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_paddingleft') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Padding.Left;
  except
  end;
end;

// layout_paddingleft#(layout#, value) - Set left padding
function p_layout_paddingleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_paddingleft#') then Exit;

  try
    TBasLayout(Args[0].p).Padding.Left := Args[1].n;
  except
  end;
end;

// layout_paddingtop(layout#) - Get top padding
function n_layout_paddingtop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_paddingtop') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Padding.Top;
  except
  end;
end;

// layout_paddingtop#(layout#, value) - Set top padding
function p_layout_paddingtop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_paddingtop#') then Exit;

  try
    TBasLayout(Args[0].p).Padding.Top := Args[1].n;
  except
  end;
end;

// layout_paddingright(layout#) - Get right padding
function n_layout_paddingright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_paddingright') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Padding.Right;
  except
  end;
end;

// layout_paddingright#(layout#, value) - Set right padding
function p_layout_paddingright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_paddingright#') then Exit;

  try
    TBasLayout(Args[0].p).Padding.Right := Args[1].n;
  except
  end;
end;

// layout_paddingbottom(layout#) - Get bottom padding
function n_layout_paddingbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_paddingbottom') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Padding.Bottom;
  except
  end;
end;

// layout_paddingbottom#(layout#, value) - Set bottom padding
function p_layout_paddingbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_paddingbottom#') then Exit;

  try
    TBasLayout(Args[0].p).Padding.Bottom := Args[1].n;
  except
  end;
end;

// layout_paddings#(layout#, left, top, right, bottom) - Set all padding
function p_layout_paddings_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_paddings#') then Exit;

  try
    with TBasLayout(Args[0].p).Padding do
    begin
      Left := Args[1].n;
      Top := Args[2].n;
      Right := Args[3].n;
      Bottom := Args[4].n;
    end;
  except
  end;
end;

// layout_padding#(layout#, value) - Set uniform padding
function p_layout_padding_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_padding#') then Exit;

  try
    with TBasLayout(Args[0].p).Padding do
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

// layout_visible(layout#) - Get visible
function n_layout_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_visible') then Exit;

  try
    if TBasLayout(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// layout_visible#(layout#, value) - Set visible
function p_layout_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_visible#') then Exit;

  try
    TBasLayout(Args[0].p).Visible := (Args[1].n <> 0);
  except
  end;
end;

// layout_enabled(layout#) - Get enabled
function n_layout_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_enabled') then Exit;

  try
    if TBasLayout(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// layout_enabled#(layout#, value) - Set enabled
function p_layout_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_enabled#') then Exit;

  try
    TBasLayout(Args[0].p).Enabled := (Args[1].n <> 0);
  except
  end;
end;

// layout_opacity(layout#) - Get opacity (0.0-1.0)
function n_layout_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_opacity') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Opacity;
  except
  end;
end;

// layout_opacity#(layout#, value) - Set opacity (0.0-1.0)
function p_layout_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_opacity#') then Exit;

  try
    TBasLayout(Args[0].p).Opacity := Args[1].n;
  except
  end;
end;

// layout_clipchildren(layout#) - Get clip children
function n_layout_clipchildren_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_clipchildren') then Exit;

  try
    if TBasLayout(Args[0].p).ClipChildren then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// layout_clipchildren#(layout#, value) - Set clip children
function p_layout_clipchildren_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_clipchildren#') then Exit;

  try
    TBasLayout(Args[0].p).ClipChildren := (Args[1].n <> 0);
  except
  end;
end;

// layout_hittest(layout#) - Get hit test
function n_layout_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_hittest') then Exit;

  try
    if TBasLayout(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// layout_hittest#(layout#, value) - Set hit test
function p_layout_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_hittest#') then Exit;

  try
    TBasLayout(Args[0].p).HitTest := (Args[1].n <> 0);
  except
  end;
end;

// layout_locked(layout#) - Get locked state
function n_layout_locked_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_locked') then Exit;

  try
    if TBasLayout(Args[0].p).Locked then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// layout_locked#(layout#, value) - Set locked state
function p_layout_locked_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_locked#') then Exit;

  try
    TBasLayout(Args[0].p).Locked := (Args[1].n <> 0);
  except
  end;
end;

//==============================================================================
// Library Functions - Tag
//==============================================================================

// layout_tag(layout#) - Get tag
function n_layout_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_tag') then Exit;

  try
    Result.n := TBasLayout(Args[0].p).Tag;
  except
  end;
end;

// layout_tag#(layout#, value) - Set tag
function p_layout_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_tag#') then Exit;

  try
    TBasLayout(Args[0].p).Tag := Trunc(Args[1].n);
  except
  end;
end;

//==============================================================================
// Library Functions - Invalidation
//==============================================================================

// layout_invalidate#(layout#) - Invalidate layout for repaint
function p_layout_invalidate(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_invalidate#') then Exit;

  try
    TBasLayout(Args[0].p).InvalidateRect(TBasLayout(Args[0].p).LocalRect);
  except
  end;
end;

//==============================================================================
// Library Functions - Event Callbacks
//==============================================================================

// layout_onclick#(layout#, funcname$) - Set OnClick handler
function p_layout_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onclick#') then Exit;

  try
    TBasLayout(Args[0].p).OnClickFunc := Args[1].s;
  except
  end;
end;

// layout_onclick$(layout#) - Get OnClick handler name
function s_layout_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onclick$') then Exit;

  try
    Result.s := TBasLayout(Args[0].p).OnClickFunc;
  except
  end;
end;

// layout_ondblclick#(layout#, funcname$) - Set OnDblClick handler
function p_layout_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_ondblclick#') then Exit;

  try
    TBasLayout(Args[0].p).OnDblClickFunc := Args[1].s;
  except
  end;
end;

// layout_ondblclick$(layout#) - Get OnDblClick handler name
function s_layout_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_ondblclick$') then Exit;

  try
    Result.s := TBasLayout(Args[0].p).OnDblClickFunc;
  except
  end;
end;

// layout_onmousedown#(layout#, funcname$) - Set OnMouseDown handler
function p_layout_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onmousedown#') then Exit;

  try
    TBasLayout(Args[0].p).OnMouseDownFunc := Args[1].s;
  except
  end;
end;

// layout_onmousedown$(layout#) - Get OnMouseDown handler name
function s_layout_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onmousedown$') then Exit;

  try
    Result.s := TBasLayout(Args[0].p).OnMouseDownFunc;
  except
  end;
end;

// layout_onmouseup#(layout#, funcname$) - Set OnMouseUp handler
function p_layout_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onmouseup#') then Exit;

  try
    TBasLayout(Args[0].p).OnMouseUpFunc := Args[1].s;
  except
  end;
end;

// layout_onmouseup$(layout#) - Get OnMouseUp handler name
function s_layout_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onmouseup$') then Exit;

  try
    Result.s := TBasLayout(Args[0].p).OnMouseUpFunc;
  except
  end;
end;

// layout_onmousemove#(layout#, funcname$) - Set OnMouseMove handler
function p_layout_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onmousemove#') then Exit;

  try
    TBasLayout(Args[0].p).OnMouseMoveFunc := Args[1].s;
  except
  end;
end;

// layout_onmousemove$(layout#) - Get OnMouseMove handler name
function s_layout_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onmousemove$') then Exit;

  try
    Result.s := TBasLayout(Args[0].p).OnMouseMoveFunc;
  except
  end;
end;

// layout_onmouseenter#(layout#, funcname$) - Set OnMouseEnter handler
function p_layout_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onmouseenter#') then Exit;

  try
    TBasLayout(Args[0].p).OnMouseEnterFunc := Args[1].s;
  except
  end;
end;

// layout_onmouseenter$(layout#) - Get OnMouseEnter handler name
function s_layout_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onmouseenter$') then Exit;

  try
    Result.s := TBasLayout(Args[0].p).OnMouseEnterFunc;
  except
  end;
end;

// layout_onmouseleave#(layout#, funcname$) - Set OnMouseLeave handler
function p_layout_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onmouseleave#') then Exit;

  try
    TBasLayout(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  except
  end;
end;

// layout_onmouseleave$(layout#) - Get OnMouseLeave handler name
function s_layout_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onmouseleave$') then Exit;

  try
    Result.s := TBasLayout(Args[0].p).OnMouseLeaveFunc;
  except
  end;
end;

// layout_onmousewheel#(layout#, funcname$) - Set OnMouseWheel handler
function p_layout_onmousewheel_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onmousewheel#') then Exit;

  try
    TBasLayout(Args[0].p).OnMouseWheelFunc := Args[1].s;
  except
  end;
end;

// layout_onmousewheel$(layout#) - Get OnMouseWheel handler name
function s_layout_onmousewheel_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onmousewheel$') then Exit;

  try
    Result.s := TBasLayout(Args[0].p).OnMouseWheelFunc;
  except
  end;
end;

// layout_onresize#(layout#, funcname$) - Set OnResize handler
function p_layout_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onresize#') then Exit;

  try
    TBasLayout(Args[0].p).OnResizeFunc := Args[1].s;
  except
  end;
end;

// layout_onresize$(layout#) - Get OnResize handler name
function s_layout_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onresize$') then Exit;

  try
    Result.s := TBasLayout(Args[0].p).OnResizeFunc;
  except
  end;
end;

// layout_onresized#(layout#, funcname$) - Set OnResized handler
function p_layout_onresized_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onresized#') then Exit;

  try
    TBasLayout(Args[0].p).OnResizedFunc := Args[1].s;
  except
  end;
end;

// layout_onresized$(layout#) - Get OnResized handler name
function s_layout_onresized_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onresized$') then Exit;

  try
    Result.s := TBasLayout(Args[0].p).OnResizedFunc;
  except
  end;
end;

// layout_onpaint#(layout#, funcname$) - Set OnPaint handler
function p_layout_onpaint_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onpaint#') then Exit;

  try
    TBasLayout(Args[0].p).OnPaintFunc := Args[1].s;
  except
  end;
end;

// layout_onpaint$(layout#) - Get OnPaint handler name
function s_layout_onpaint_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_onpaint$') then Exit;

  try
    Result.s := TBasLayout(Args[0].p).OnPaintFunc;
  except
  end;
end;

// layout_clearcallbacks#(layout#) - Clear all callbacks
function p_layout_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateLayout(Args[0].p, 'layout_clearcallbacks#') then Exit;

  try
    with TBasLayout(Args[0].p) do
    begin
      OnClickFunc := '';
      OnDblClickFunc := '';
      OnMouseDownFunc := '';
      OnMouseUpFunc := '';
      OnMouseMoveFunc := '';
      OnMouseEnterFunc := '';
      OnMouseLeaveFunc := '';
      OnMouseWheelFunc := '';
      OnResizeFunc := '';
      OnResizedFunc := '';
      OnPaintFunc := '';
      OnDragEnterFunc := '';
      OnDragOverFunc := '';
      OnDragDropFunc := '';
      OnDragLeaveFunc := '';
    end;
  except
  end;
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterLayoutFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  // Store module-level references for event callbacks
  ModuleEngine := Eng;
  ModuleOutput := OutP;

  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_layout_error; Lib.Add('layout_error@', Fn);
  Fn.Entry := @s_layout_errormsg; Lib.Add('layout_errormsg$@', Fn);
  Fn.Entry := @s_layout_strerror; Lib.Add('layout_strerror$@n', Fn);
  Fn.Entry := @n_layout_clearerror; Lib.Add('layout_clearerror@', Fn);

  // Layout creation/destruction
  Fn.Entry := @p_layout_new; Lib.Add('layout#@#', Fn);
  Fn.Entry := @p_layout_new_size; Lib.Add('layout#@#nn', Fn);
  Fn.Entry := @p_layout_new_full; Lib.Add('layout#@#nnnn', Fn);
  Fn.Entry := @n_layout_free; Lib.Add('layout_free@#', Fn);

  // Parent/child management
  Fn.Entry := @p_layout_parent_get; Lib.Add('layout_parent#@#', Fn);
  Fn.Entry := @p_layout_parent_set; Lib.Add('layout_parent#@##', Fn);
  Fn.Entry := @n_layout_childcount; Lib.Add('layout_childcount@#', Fn);
  Fn.Entry := @p_layout_child; Lib.Add('layout_child#@#n', Fn);
  Fn.Entry := @p_layout_bringtofront; Lib.Add('layout_bringtofront#@#', Fn);
  Fn.Entry := @p_layout_sendtoback; Lib.Add('layout_sendtoback#@#', Fn);

  // Position and Size
  Fn.Entry := @n_layout_x_get; Lib.Add('layout_x@#', Fn);
  Fn.Entry := @p_layout_x_set; Lib.Add('layout_x#@#n', Fn);
  Fn.Entry := @n_layout_y_get; Lib.Add('layout_y@#', Fn);
  Fn.Entry := @p_layout_y_set; Lib.Add('layout_y#@#n', Fn);
  Fn.Entry := @n_layout_width_get; Lib.Add('layout_width@#', Fn);
  Fn.Entry := @p_layout_width_set; Lib.Add('layout_width#@#n', Fn);
  Fn.Entry := @n_layout_height_get; Lib.Add('layout_height@#', Fn);
  Fn.Entry := @p_layout_height_set; Lib.Add('layout_height#@#n', Fn);
  Fn.Entry := @p_layout_bounds_set; Lib.Add('layout_bounds#@#nnnn', Fn);
  Fn.Entry := @p_layout_size_set; Lib.Add('layout_size#@#nn', Fn);
  Fn.Entry := @p_layout_move_set; Lib.Add('layout_move#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_layout_align_get; Lib.Add('layout_align@#', Fn);
  Fn.Entry := @p_layout_align_set; Lib.Add('layout_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_layout_marginleft_get; Lib.Add('layout_marginleft@#', Fn);
  Fn.Entry := @p_layout_marginleft_set; Lib.Add('layout_marginleft#@#n', Fn);
  Fn.Entry := @n_layout_margintop_get; Lib.Add('layout_margintop@#', Fn);
  Fn.Entry := @p_layout_margintop_set; Lib.Add('layout_margintop#@#n', Fn);
  Fn.Entry := @n_layout_marginright_get; Lib.Add('layout_marginright@#', Fn);
  Fn.Entry := @p_layout_marginright_set; Lib.Add('layout_marginright#@#n', Fn);
  Fn.Entry := @n_layout_marginbottom_get; Lib.Add('layout_marginbottom@#', Fn);
  Fn.Entry := @p_layout_marginbottom_set; Lib.Add('layout_marginbottom#@#n', Fn);
  Fn.Entry := @p_layout_margins_set; Lib.Add('layout_margins#@#nnnn', Fn);
  Fn.Entry := @p_layout_margin_set; Lib.Add('layout_margin#@#n', Fn);

  // Padding
  Fn.Entry := @n_layout_paddingleft_get; Lib.Add('layout_paddingleft@#', Fn);
  Fn.Entry := @p_layout_paddingleft_set; Lib.Add('layout_paddingleft#@#n', Fn);
  Fn.Entry := @n_layout_paddingtop_get; Lib.Add('layout_paddingtop@#', Fn);
  Fn.Entry := @p_layout_paddingtop_set; Lib.Add('layout_paddingtop#@#n', Fn);
  Fn.Entry := @n_layout_paddingright_get; Lib.Add('layout_paddingright@#', Fn);
  Fn.Entry := @p_layout_paddingright_set; Lib.Add('layout_paddingright#@#n', Fn);
  Fn.Entry := @n_layout_paddingbottom_get; Lib.Add('layout_paddingbottom@#', Fn);
  Fn.Entry := @p_layout_paddingbottom_set; Lib.Add('layout_paddingbottom#@#n', Fn);
  Fn.Entry := @p_layout_paddings_set; Lib.Add('layout_paddings#@#nnnn', Fn);
  Fn.Entry := @p_layout_padding_set; Lib.Add('layout_padding#@#n', Fn);

  // Visibility and behavior
  Fn.Entry := @n_layout_visible_get; Lib.Add('layout_visible@#', Fn);
  Fn.Entry := @p_layout_visible_set; Lib.Add('layout_visible#@#n', Fn);
  Fn.Entry := @n_layout_enabled_get; Lib.Add('layout_enabled@#', Fn);
  Fn.Entry := @p_layout_enabled_set; Lib.Add('layout_enabled#@#n', Fn);
  Fn.Entry := @n_layout_opacity_get; Lib.Add('layout_opacity@#', Fn);
  Fn.Entry := @p_layout_opacity_set; Lib.Add('layout_opacity#@#n', Fn);
  Fn.Entry := @n_layout_clipchildren_get; Lib.Add('layout_clipchildren@#', Fn);
  Fn.Entry := @p_layout_clipchildren_set; Lib.Add('layout_clipchildren#@#n', Fn);
  Fn.Entry := @n_layout_hittest_get; Lib.Add('layout_hittest@#', Fn);
  Fn.Entry := @p_layout_hittest_set; Lib.Add('layout_hittest#@#n', Fn);
  Fn.Entry := @n_layout_locked_get; Lib.Add('layout_locked@#', Fn);
  Fn.Entry := @p_layout_locked_set; Lib.Add('layout_locked#@#n', Fn);

  // Tag
  Fn.Entry := @n_layout_tag_get; Lib.Add('layout_tag@#', Fn);
  Fn.Entry := @p_layout_tag_set; Lib.Add('layout_tag#@#n', Fn);

  // Invalidation
  Fn.Entry := @p_layout_invalidate; Lib.Add('layout_invalidate#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_layout_onclick_set; Lib.Add('layout_onclick#@#$', Fn);
  Fn.Entry := @s_layout_onclick_get; Lib.Add('layout_onclick$@#', Fn);
  Fn.Entry := @p_layout_ondblclick_set; Lib.Add('layout_ondblclick#@#$', Fn);
  Fn.Entry := @s_layout_ondblclick_get; Lib.Add('layout_ondblclick$@#', Fn);
  Fn.Entry := @p_layout_onmousedown_set; Lib.Add('layout_onmousedown#@#$', Fn);
  Fn.Entry := @s_layout_onmousedown_get; Lib.Add('layout_onmousedown$@#', Fn);
  Fn.Entry := @p_layout_onmouseup_set; Lib.Add('layout_onmouseup#@#$', Fn);
  Fn.Entry := @s_layout_onmouseup_get; Lib.Add('layout_onmouseup$@#', Fn);
  Fn.Entry := @p_layout_onmousemove_set; Lib.Add('layout_onmousemove#@#$', Fn);
  Fn.Entry := @s_layout_onmousemove_get; Lib.Add('layout_onmousemove$@#', Fn);
  Fn.Entry := @p_layout_onmouseenter_set; Lib.Add('layout_onmouseenter#@#$', Fn);
  Fn.Entry := @s_layout_onmouseenter_get; Lib.Add('layout_onmouseenter$@#', Fn);
  Fn.Entry := @p_layout_onmouseleave_set; Lib.Add('layout_onmouseleave#@#$', Fn);
  Fn.Entry := @s_layout_onmouseleave_get; Lib.Add('layout_onmouseleave$@#', Fn);
  Fn.Entry := @p_layout_onmousewheel_set; Lib.Add('layout_onmousewheel#@#$', Fn);
  Fn.Entry := @s_layout_onmousewheel_get; Lib.Add('layout_onmousewheel$@#', Fn);
  Fn.Entry := @p_layout_onresize_set; Lib.Add('layout_onresize#@#$', Fn);
  Fn.Entry := @s_layout_onresize_get; Lib.Add('layout_onresize$@#', Fn);
  Fn.Entry := @p_layout_onresized_set; Lib.Add('layout_onresized#@#$', Fn);
  Fn.Entry := @s_layout_onresized_get; Lib.Add('layout_onresized$@#', Fn);
  Fn.Entry := @p_layout_onpaint_set; Lib.Add('layout_onpaint#@#$', Fn);
  Fn.Entry := @s_layout_onpaint_get; Lib.Add('layout_onpaint$@#', Fn);
  Fn.Entry := @p_layout_clearcallbacks; Lib.Add('layout_clearcallbacks#@#', Fn);
end;

end.

