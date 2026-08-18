unit ImageLib;

{******************************************************************************
  ImageLib - Image Visual Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete image display functionality for creating and managing
  bitmap image controls in Plan9Basic programs. Supports loading images from
  files, displaying with various scaling modes, and basic image manipulation.

  Function Count: 85 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  SUPPORTED IMAGE FORMATS:
  ========================
  - PNG (recommended for transparency)
  - JPEG/JPG
  - BMP
  - GIF
  - Other formats supported by the platform

  FEATURES:
  =========
  - Image creation and lifecycle management
  - Load images from file
  - Save images to file
  - Multiple wrap/scaling modes
  - Bitmap dimensions and properties
  - Clear and empty detection
  - Complete positioning and alignment
  - Full event support with BASIC callback integration

  WRAP MODE (Scaling):
  ====================
  0 = Original - Display at original size, positioned at top-left
  1 = Fit      - Scale to fit while keeping aspect ratio (default)
  2 = Stretch  - Stretch to fill entire control bounds
  3 = Tile     - Tile/repeat image to fill control
  4 = Center   - Center image without resizing
  5 = Place    - Fit if larger than control, center if smaller

  COLOR FORMAT:
  =============
  Colors are specified as strings in these formats:
  - Named colors: "red", "blue", "green", "white", "black", etc.
  - Hex RGB: "#RRGGBB" (e.g., "#FF5500")
  - Hex ARGB: "#AARRGGBB" (e.g., "#80FF5500" for semi-transparent)

  USAGE PATTERN:
  ==============
    let frm# = form#("Image Demo", 800, 600)

    ' Create an image control and load a picture
    let img# = image#(frm#, 50, 50, 300, 200)
    image_load#(img#, "photo.png")
    image_wrapmode#(img#, 1)  ' Fit mode

    ' Create another image with stretch mode
    let img2# = image#(frm#, 400, 50, 300, 200)
    image_load#(img2#, "background.jpg")
    image_wrapmode#(img2#, 2)  ' Stretch mode

    form_show(frm#)

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Objects,
  basic, exec, UnitGC, HandleRegistry, GuiUtils;

type
  TBasImage = class(TImage)
  private
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

    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;

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

    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
    //function ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;

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

    procedure DisconnectEvents();
    function CallbackExists(const FuncName: String): Boolean;

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
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
  end;

procedure RegisterImageFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

uses
  UnitUtils;

const
  IMAGE_GC_TAG = 'BASIC_IMAGE';
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_IMAGE = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INVALID_CALLBACK = 5;
  ERR_FILE_NOT_FOUND = 6;
  ERR_LOAD_FAILED = 7;
  ERR_SAVE_FAILED = 8;

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

  WRAP_ORIGINAL = 0;
  WRAP_FIT = 1;
  WRAP_STRETCH = 2;
  WRAP_TILE = 3;
  WRAP_CENTER = 4;
  WRAP_PLACE = 5;

var
  lastError: Integer;
  lastErrorMsg: String;
  ModuleEngine: TBasicEngine;
  ModuleOutput: TStrings;

procedure SetError(Code: Integer; const Msg: String);
begin
  lastError := Code;
  lastErrorMsg := Msg;
end;

procedure ClearError;
begin
  lastError := ERR_NONE;
  lastErrorMsg := '';
end;

function ValidateImage(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_IMAGE, FuncName + ': Nil image pointer');
    Exit();
  end;

  try
    if not (IsHandleOf(P, TBasImage)) then
    begin
      SetError(ERR_INVALID_IMAGE, FuncName + ': Invalid image object');
      Exit();
    end;
  except
    SetError(ERR_INVALID_IMAGE, FuncName + ': Invalid image pointer');
    Exit();
  end;

  ClearError;
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': Nil parent pointer');
    Exit();
  end;

  try
    if not (IsHandleOf(P, TFmxObject)) then
    begin
      SetError(ERR_INVALID_PARENT, FuncName + ': Invalid parent object');
      Exit();
    end;
  except
    SetError(ERR_INVALID_PARENT, FuncName + ': Invalid parent pointer');
    Exit();
  end;

  ClearError;
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

function IntToWrapMode(Value: Integer): TImageWrapMode;
begin
  case Value of
    WRAP_ORIGINAL: Result := TImageWrapMode.Original;
    WRAP_FIT: Result := TImageWrapMode.Fit;
    WRAP_STRETCH: Result := TImageWrapMode.Stretch;
    WRAP_TILE: Result := TImageWrapMode.Tile;
    WRAP_CENTER: Result := TImageWrapMode.Center;
    WRAP_PLACE: Result := TImageWrapMode.Place;
  else
    Result := TImageWrapMode.Fit;
  end;
end;

function WrapModeToInt(Value: TImageWrapMode): Integer;
begin
  case Value of
    TImageWrapMode.Original: Result := WRAP_ORIGINAL;
    TImageWrapMode.Fit: Result := WRAP_FIT;
    TImageWrapMode.Stretch: Result := WRAP_STRETCH;
    TImageWrapMode.Tile: Result := WRAP_TILE;
    TImageWrapMode.Center: Result := WRAP_CENTER;
    TImageWrapMode.Place: Result := WRAP_PLACE;
  else
    Result := WRAP_FIT;
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
// TBasImage Implementation
//==============================================================================

constructor TBasImage.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);

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

  FBasicEngine := nil;
  FConsoleOutput := nil;

  WrapMode := TImageWrapMode.Fit;
  HitTest := True;
end;

destructor TBasImage.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectEvents();
  inherited Destroy();
end;

procedure TBasImage.DisconnectEvents();
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

function TBasImage.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

procedure TBasImage.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  RetVal: TAsmData;
  i: Integer;
begin
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
        FConsoleOutput.Add('*** Image Event Callback Error ***');
        FConsoleOutput.Add('Function: ' + FuncSignature);
        FConsoleOutput.Add('Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.GlobalCallbackBusy := False;
  end;
end;

//function TBasImage.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
//var
//  CallArgs: array of TAsmData;
//  RetType: TExprKind;
//  i: Integer;
//begin
//  Result.n := 0;
//  Result.p := nil;
//  Result.s := '';
//
//  if UnitGC.GlobalCallbackBusy then Exit();
//
//  if not Assigned(FBasicEngine) then Exit();
//  if not Assigned(FConsoleOutput) then Exit();
//  if FuncSignature = '' then Exit();
//
//  UnitGC.GlobalCallbackBusy := True;
//  UnitGC.SkipProcessMessages := True;
//  try
//    SetLength(CallArgs, Length(Args));
//    for i := 0 to High(Args) do
//      CallArgs[i] := Args[i];
//
//    try
//      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs, RetType, Result);
//    except
//      on E: Exception do
//      begin
//        FConsoleOutput.Add('*** Image Event Callback Error ***');
//        FConsoleOutput.Add('Function: ' + FuncSignature);
//        FConsoleOutput.Add('Error: ' + E.Message);
//      end;
//    end;
//  finally
//    UnitGC.SkipProcessMessages := False;
//    UnitGC.GlobalCallbackBusy := False;
//  end;
//end;

procedure TBasImage.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    OnClick := InternalOnClick
  else
    OnClick := nil;
end;

procedure TBasImage.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    OnDblClick := InternalOnDblClick
  else
    OnDblClick := nil;
end;

procedure TBasImage.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    OnMouseDown := InternalOnMouseDown
  else
    OnMouseDown := nil;
end;

procedure TBasImage.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    OnMouseUp := InternalOnMouseUp
  else
    OnMouseUp := nil;
end;

procedure TBasImage.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    OnMouseMove := InternalOnMouseMove
  else
    OnMouseMove := nil;
end;

procedure TBasImage.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    OnMouseEnter := InternalOnMouseEnter
  else
    OnMouseEnter := nil;
end;

procedure TBasImage.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    OnMouseLeave := InternalOnMouseLeave
  else
    OnMouseLeave := nil;
end;

procedure TBasImage.SetOnMouseWheelFunc(const Value: String);
begin
  FOnMouseWheelFunc := Value;
  if Value <> '' then
    OnMouseWheel := InternalOnMouseWheel
  else
    OnMouseWheel := nil;
end;

procedure TBasImage.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    OnResize := InternalOnResize
  else
    OnResize := nil;
end;

procedure TBasImage.SetOnResizedFunc(const Value: String);
begin
  FOnResizedFunc := Value;
  if Value <> '' then
    OnResized := InternalOnResized
  else
    OnResized := nil;
end;

procedure TBasImage.SetOnPaintFunc(const Value: String);
begin
  FOnPaintFunc := Value;
  if Value <> '' then
    OnPainting := InternalOnPaint
  else
    OnPainting := nil;
end;

procedure TBasImage.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    OnDragEnter := InternalOnDragEnter
  else
    OnDragEnter := nil;
end;

procedure TBasImage.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    OnDragOver := InternalOnDragOver
  else
    OnDragOver := nil;
end;

procedure TBasImage.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    OnDragDrop := InternalOnDragDrop
  else
    OnDragDrop := nil;
end;

procedure TBasImage.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    OnDragLeave := InternalOnDragLeave
  else
    OnDragLeave := nil;
end;

procedure TBasImage.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnClickFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnClickFunc) + '@#', Args);
end;

procedure TBasImage.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDblClickFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDblClickFunc) + '@#', Args);
end;

procedure TBasImage.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseDownFunc = '' then Exit();
  Args[0].p := Sender;
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
  Args[4].s := BuildShiftString(Shift);
  Args[4].n := 0;
  Args[4].p := nil;
  ExecuteCallback(LowerCase(FOnMouseDownFunc) + '@#nnn$', Args);
end;

procedure TBasImage.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..4] of TAsmData;
begin
  if FOnMouseUpFunc = '' then Exit();
  Args[0].p := Sender;
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
  Args[4].s := BuildShiftString(Shift);
  Args[4].n := 0;
  Args[4].p := nil;
  ExecuteCallback(LowerCase(FOnMouseUpFunc) + '@#nnn$', Args);
end;

procedure TBasImage.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnMouseMoveFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := X;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Y;
  Args[2].p := nil;
  Args[2].s := '';
  Args[3].s := BuildShiftString(Shift);
  Args[3].n := 0;
  Args[3].p := nil;
  ExecuteCallback(LowerCase(FOnMouseMoveFunc) + '@#nn$', Args);
end;

procedure TBasImage.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseEnterFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseEnterFunc) + '@#', Args);
end;

procedure TBasImage.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseLeaveFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseLeaveFunc) + '@#', Args);
end;

procedure TBasImage.InternalOnMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; var Handled: Boolean);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnMouseWheelFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := WheelDelta;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].s := BuildShiftString(Shift);
  Args[2].n := 0;
  Args[2].p := nil;
  ExecuteCallback(LowerCase(FOnMouseWheelFunc) + '@#n$', Args);
  Handled := True;
end;

procedure TBasImage.InternalOnResize(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizeFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizeFunc) + '@#', Args);
end;

procedure TBasImage.InternalOnResized(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizedFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizedFunc) + '@#', Args);
end;

procedure TBasImage.InternalOnPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnPaintFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnPaintFunc) + '@#', Args);
end;

procedure TBasImage.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragEnterFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';
  ExecuteCallback(LowerCase(FOnDragEnterFunc) + '@#nn', Args);
end;

procedure TBasImage.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragOverFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';
  ExecuteCallback(LowerCase(FOnDragOverFunc) + '@#nn', Args);
  Operation := TDragOperation.Copy;
end;

procedure TBasImage.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragDropFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';
  ExecuteCallback(LowerCase(FOnDragDropFunc) + '@#nn', Args);
end;

procedure TBasImage.InternalOnDragLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDragLeaveFunc = '' then Exit();
  Args[0].p := Sender;
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDragLeaveFunc) + '@#', Args);
end;

//==============================================================================
// Library Functions - Error Handling
//==============================================================================

function n_image_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.s := '';
  Result.p := nil;
end;

function s_image_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := lastErrorMsg;
  Result.p := nil;
end;

function s_image_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Code := Round(Args[0].n);
  Result.n := 0;
  Result.p := nil;
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_IMAGE: Result.s := 'Invalid image';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Create failed';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback';
    ERR_FILE_NOT_FOUND: Result.s := 'File not found';
    ERR_LOAD_FAILED: Result.s := 'Load failed';
    ERR_SAVE_FAILED: Result.s := 'Save failed';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_image_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
end;

//==============================================================================
// Library Functions - Creation/Destruction
//==============================================================================

function p_image_new(var Args: array of TAsmData): TAsmData;
var
  Img: TBasImage;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'image#') then Exit();

  try
    Img := TBasImage.Create(nil);
    Img.Parent := TFmxObject(Args[0].p);
    Img.BasicEngine := ModuleEngine;
    Img.ConsoleOutput := ModuleOutput;

    Result.p := Img;

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Img, IMAGE_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'image#: ' + E.Message);
  end;
end;

function p_image_new_size(var Args: array of TAsmData): TAsmData;
var
  Img: TBasImage;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'image#') then Exit();

  try
    Img := TBasImage.Create(nil);
    Img.Parent := TFmxObject(Args[0].p);
    Img.Width := Args[1].n;
    Img.Height := Args[2].n;
    Img.BasicEngine := ModuleEngine;
    Img.ConsoleOutput := ModuleOutput;

    Result.p := Img;

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Img, IMAGE_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'image#: ' + E.Message);
  end;
end;

function p_image_new_full(var Args: array of TAsmData): TAsmData;
var
  Img: TBasImage;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateParent(Args[0].p, 'image#') then Exit();

  try
    Img := TBasImage.Create(nil);
    Img.Parent := TFmxObject(Args[0].p);
    Img.Position.X := Args[1].n;
    Img.Position.Y := Args[2].n;
    Img.Width := Args[3].n;
    Img.Height := Args[4].n;
    Img.BasicEngine := ModuleEngine;
    Img.ConsoleOutput := ModuleOutput;

    Result.p := Img;

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(Img, IMAGE_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'image#: ' + E.Message);
  end;
end;

function n_image_free(var Args: array of TAsmData): TAsmData;
var
  Img: TBasImage;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateImage(Args[0].p, 'image_free') then Exit();

  try
    Img := TBasImage(Args[0].p);
    Img.DisconnectEvents();
    Img.Free();

    // Free via GC using individualized tag
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(IMAGE_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_IMAGE, 'image_free: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Image Loading/Saving
//==============================================================================

function IsWebUrl(const Path: String): Boolean;
var
  LowerPath: String;
begin
  LowerPath := LowerCase(Trim(Path));
  Result := LowerPath.StartsWith('http://') or LowerPath.StartsWith('https://');
end;

function n_image_load(var Args: array of TAsmData): TAsmData;
var
  FilePath: String;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateImage(Args[0].p, 'image_load') then Exit();

  FilePath := Args[1].s;

  try
    if IsWebUrl(FilePath) then
    begin
      if not TGuiUtils.LoadImageFromWeb(FilePath, TBasImage(Args[0].p).Bitmap) then
      begin
        SetError(ERR_LOAD_FAILED, 'image_load: Failed to load from URL: ' + FilePath);
        Exit();
      end;
    end
    else
    begin
      if not FileExists(FilePath) then
      begin
        SetError(ERR_FILE_NOT_FOUND, 'image_load: File not found: ' + FilePath);
        Exit();
      end;
      TBasImage(Args[0].p).Bitmap.LoadFromFile(FilePath);
    end;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_LOAD_FAILED, 'image_load: ' + E.Message);
  end;
end;

function p_image_load_ptr(var Args: array of TAsmData): TAsmData;
var
  FilePath: String;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := Args[0].p;
  ClearError;

  if not ValidateImage(Args[0].p, 'image_load#') then Exit;

  FilePath := Args[1].s;

  try
    if IsWebUrl(FilePath) then
    begin
      if not TGuiUtils.LoadImageFromWeb(FilePath, TBasImage(Args[0].p).Bitmap) then
        SetError(ERR_LOAD_FAILED, 'image_load#: Failed to load from URL: ' + FilePath);
    end
    else
    begin
      if not FileExists(FilePath) then
      begin
        SetError(ERR_FILE_NOT_FOUND, 'image_load#: File not found: ' + FilePath);
        Exit;
      end;
      TBasImage(Args[0].p).Bitmap.LoadFromFile(FilePath);
    end;
  except
    on E: Exception do
      SetError(ERR_LOAD_FAILED, 'image_load#: ' + E.Message);
  end;
end;

function n_image_save(var Args: array of TAsmData): TAsmData;
var
  FilePath: String;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError;

  if not ValidateImage(Args[0].p, 'image_save') then Exit();

  FilePath := Args[1].s;

  try
    TBasImage(Args[0].p).Bitmap.SaveToFile(FilePath);
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_SAVE_FAILED, 'image_save: ' + E.Message);
  end;
end;

function p_image_save_ptr(var Args: array of TAsmData): TAsmData;
var
  FilePath: String;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := Args[0].p;
  ClearError;

  if not ValidateImage(Args[0].p, 'image_save#') then Exit();

  FilePath := Args[1].s;

  try
    TBasImage(Args[0].p).Bitmap.SaveToFile(FilePath);
  except
    on E: Exception do
      SetError(ERR_SAVE_FAILED, 'image_save#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Bitmap Properties
//==============================================================================

function n_image_bitmapwidth(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_bitmapwidth') then Exit();
  try
    Result.n := TBasImage(Args[0].p).Bitmap.Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_bitmapwidth: ' + E.Message);
  end;
end;

function n_image_bitmapheight(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_bitmapheight') then Exit();
  try
    Result.n := TBasImage(Args[0].p).Bitmap.Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_bitmapheight: ' + E.Message);
  end;
end;

function n_image_isempty(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_isempty') then Exit();
  try
    if TBasImage(Args[0].p).Bitmap.IsEmpty then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_isempty: ' + E.Message);
  end;
end;

function p_image_clear(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_clear#') then Exit();
  try
    TBasImage(Args[0].p).Bitmap.Clear(TAlphaColorRec.Null);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_clear#: ' + E.Message);
  end;
end;

function p_image_clearcolor(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_clear#') then Exit();
  try
    TBasImage(Args[0].p).Bitmap.Clear(TUtils.ColorToAlphaColor(Args[1].s));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_clear#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - WrapMode
//==============================================================================

function n_image_wrapmode_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_wrapmode') then Exit();
  try
    Result.n := WrapModeToInt(TBasImage(Args[0].p).WrapMode);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_wrapmode: ' + E.Message);
  end;
end;

function p_image_wrapmode_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_wrapmode#') then Exit();
  try
    TBasImage(Args[0].p).WrapMode := IntToWrapMode(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_wrapmode#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Position and Size
//==============================================================================

function n_image_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_x') then Exit();
  try
    Result.n := TBasImage(Args[0].p).Position.X;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_x: ' + E.Message);
  end;
end;

function p_image_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_x#') then Exit();
  try
    TBasImage(Args[0].p).Position.X := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_x#: ' + E.Message);
  end;
end;

function n_image_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_y') then Exit();
  try
    Result.n := TBasImage(Args[0].p).Position.Y;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_y: ' + E.Message);
  end;
end;

function p_image_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_y#') then Exit();
  try
    TBasImage(Args[0].p).Position.Y := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_y#: ' + E.Message);
  end;
end;

function n_image_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_width') then Exit();
  try
    Result.n := TBasImage(Args[0].p).Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_width: ' + E.Message);
  end;
end;

function p_image_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_width#') then Exit();
  try
    TBasImage(Args[0].p).Width := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_width#: ' + E.Message);
  end;
end;

function n_image_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_height') then Exit();
  try
    Result.n := TBasImage(Args[0].p).Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_height: ' + E.Message);
  end;
end;

function p_image_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_height#') then Exit();
  try
    TBasImage(Args[0].p).Height := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_height#: ' + E.Message);
  end;
end;

function p_image_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_bounds#') then Exit();
  try
    TBasImage(Args[0].p).Position.X := Args[1].n;
    TBasImage(Args[0].p).Position.Y := Args[2].n;
    TBasImage(Args[0].p).Width := Args[3].n;
    TBasImage(Args[0].p).Height := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_bounds#: ' + E.Message);
  end;
end;

function p_image_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_size#') then Exit();
  try
    TBasImage(Args[0].p).Width := Args[1].n;
    TBasImage(Args[0].p).Height := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_size#: ' + E.Message);
  end;
end;

function p_image_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_move#') then Exit();
  try
    TBasImage(Args[0].p).Position.X := Args[1].n;
    TBasImage(Args[0].p).Position.Y := Args[2].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_move#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Alignment
//==============================================================================

function n_image_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_align') then Exit();
  try
    Result.n := AlignToInt(TBasImage(Args[0].p).Align);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_align: ' + E.Message);
  end;
end;

function p_image_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_align#') then Exit();
  try
    TBasImage(Args[0].p).Align := IntToAlign(Round(Args[1].n));
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_align#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Margins
//==============================================================================

function n_image_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_marginleft') then Exit();
  try
    Result.n := TBasImage(Args[0].p).Margins.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_marginleft: ' + E.Message);
  end;
end;

function p_image_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_marginleft#') then Exit();
  try
    TBasImage(Args[0].p).Margins.Left := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_marginleft#: ' + E.Message);
  end;
end;

function n_image_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_margintop') then Exit();
  try
    Result.n := TBasImage(Args[0].p).Margins.Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_margintop: ' + E.Message);
  end;
end;

function p_image_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_margintop#') then Exit();
  try
    TBasImage(Args[0].p).Margins.Top := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_margintop#: ' + E.Message);
  end;
end;

function n_image_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_marginright') then Exit();
  try
    Result.n := TBasImage(Args[0].p).Margins.Right;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_marginright: ' + E.Message);
  end;
end;

function p_image_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_marginright#') then Exit();
  try
    TBasImage(Args[0].p).Margins.Right := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_marginright#: ' + E.Message);
  end;
end;

function n_image_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_marginbottom') then Exit();
  try
    Result.n := TBasImage(Args[0].p).Margins.Bottom;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_marginbottom: ' + E.Message);
  end;
end;

function p_image_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_marginbottom#') then Exit();
  try
    TBasImage(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_marginbottom#: ' + E.Message);
  end;
end;

function p_image_margins_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_margins#') then Exit();
  try
    TBasImage(Args[0].p).Margins.Left := Args[1].n;
    TBasImage(Args[0].p).Margins.Top := Args[2].n;
    TBasImage(Args[0].p).Margins.Right := Args[3].n;
    TBasImage(Args[0].p).Margins.Bottom := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_margins#: ' + E.Message);
  end;
end;

function p_image_margin_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_margin#') then Exit();
  try
    TBasImage(Args[0].p).Margins.Left := Args[1].n;
    TBasImage(Args[0].p).Margins.Top := Args[1].n;
    TBasImage(Args[0].p).Margins.Right := Args[1].n;
    TBasImage(Args[0].p).Margins.Bottom := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_margin#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Visibility and Behavior
//==============================================================================

function n_image_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_visible') then Exit();
  try
    if TBasImage(Args[0].p).Visible then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_visible: ' + E.Message);
  end;
end;

function p_image_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_visible#') then Exit();
  try
    TBasImage(Args[0].p).Visible := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_visible#: ' + E.Message);
  end;
end;

function n_image_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_enabled') then Exit();
  try
    if TBasImage(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_enabled: ' + E.Message);
  end;
end;

function p_image_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_enabled#') then Exit();
  try
    TBasImage(Args[0].p).Enabled := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_enabled#: ' + E.Message);
  end;
end;

function n_image_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_opacity') then Exit();
  try
    Result.n := TBasImage(Args[0].p).Opacity;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_opacity: ' + E.Message);
  end;
end;

function p_image_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_opacity#') then Exit();
  try
    TBasImage(Args[0].p).Opacity := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_opacity#: ' + E.Message);
  end;
end;

function n_image_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_hittest') then Exit();
  try
    if TBasImage(Args[0].p).HitTest then
      Result.n := 1
    else
      Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_hittest: ' + E.Message);
  end;
end;

function p_image_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_hittest#') then Exit();
  try
    TBasImage(Args[0].p).HitTest := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_hittest#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Tag and Rotation
//==============================================================================

function n_image_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_tag') then Exit();
  try
    Result.n := TBasImage(Args[0].p).Tag;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_tag: ' + E.Message);
  end;
end;

function p_image_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_tag#') then Exit();
  try
    TBasImage(Args[0].p).Tag := Round(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_tag#: ' + E.Message);
  end;
end;

function n_image_rotation_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  if not ValidateImage(Args[0].p, 'image_rotation') then Exit();
  try
    Result.n := TBasImage(Args[0].p).RotationAngle;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_rotation: ' + E.Message);
  end;
end;

function p_image_rotation_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_rotation#') then Exit();
  try
    TBasImage(Args[0].p).RotationAngle := Args[1].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_rotation#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Parent and Z-Order
//==============================================================================

function p_image_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_parent#') then Exit();
  try
    Result.p := TBasImage(Args[0].p).Parent;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_parent#: ' + E.Message);
  end;
end;

function p_image_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_parent#') then Exit();
  if not ValidateParent(Args[1].p, 'image_parent#') then Exit();
  try
    TBasImage(Args[0].p).Parent := TFmxObject(Args[1].p);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_parent#: ' + E.Message);
  end;
end;

function p_image_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_bringtofront#') then Exit();
  try
    TBasImage(Args[0].p).BringToFront;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_bringtofront#: ' + E.Message);
  end;
end;

function p_image_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_sendtoback#') then Exit();
  try
    TBasImage(Args[0].p).SendToBack;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_sendtoback#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Invalidation
//==============================================================================

function p_image_invalidate(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_invalidate#') then Exit();
  try
    TBasImage(Args[0].p).Repaint;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_invalidate#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Event Callbacks
//==============================================================================

function p_image_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onclick#') then Exit();
  try
    TBasImage(Args[0].p).OnClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onclick#: ' + E.Message);
  end;
end;

function s_image_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onclick$') then Exit();
  try
    Result.s := TBasImage(Args[0].p).OnClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onclick$: ' + E.Message);
  end;
end;

function p_image_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_ondblclick#') then Exit();
  try
    TBasImage(Args[0].p).OnDblClickFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_ondblclick#: ' + E.Message);
  end;
end;

function s_image_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_ondblclick$') then Exit();
  try
    Result.s := TBasImage(Args[0].p).OnDblClickFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_ondblclick$: ' + E.Message);
  end;
end;

function p_image_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onmousedown#') then Exit();
  try
    TBasImage(Args[0].p).OnMouseDownFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onmousedown#: ' + E.Message);
  end;
end;

function s_image_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onmousedown$') then Exit();
  try
    Result.s := TBasImage(Args[0].p).OnMouseDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onmousedown$: ' + E.Message);
  end;
end;

function p_image_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onmouseup#') then Exit();
  try
    TBasImage(Args[0].p).OnMouseUpFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onmouseup#: ' + E.Message);
  end;
end;

function s_image_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onmouseup$') then Exit();
  try
    Result.s := TBasImage(Args[0].p).OnMouseUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onmouseup$: ' + E.Message);
  end;
end;

function p_image_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onmousemove#') then Exit();
  try
    TBasImage(Args[0].p).OnMouseMoveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onmousemove#: ' + E.Message);
  end;
end;

function s_image_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onmousemove$') then Exit();
  try
    Result.s := TBasImage(Args[0].p).OnMouseMoveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onmousemove$: ' + E.Message);
  end;
end;

function p_image_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onmouseenter#') then Exit();
  try
    TBasImage(Args[0].p).OnMouseEnterFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onmouseenter#: ' + E.Message);
  end;
end;

function s_image_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onmouseenter$') then Exit();
  try
    Result.s := TBasImage(Args[0].p).OnMouseEnterFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onmouseenter$: ' + E.Message);
  end;
end;

function p_image_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onmouseleave#') then Exit();
  try
    TBasImage(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onmouseleave#: ' + E.Message);
  end;
end;

function s_image_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onmouseleave$') then Exit();
  try
    Result.s := TBasImage(Args[0].p).OnMouseLeaveFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onmouseleave$: ' + E.Message);
  end;
end;

function p_image_onmousewheel_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onmousewheel#') then Exit();
  try
    TBasImage(Args[0].p).OnMouseWheelFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onmousewheel#: ' + E.Message);
  end;
end;

function s_image_onmousewheel_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onmousewheel$') then Exit();
  try
    Result.s := TBasImage(Args[0].p).OnMouseWheelFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onmousewheel$: ' + E.Message);
  end;
end;

function p_image_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onresize#') then Exit();
  try
    TBasImage(Args[0].p).OnResizeFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onresize#: ' + E.Message);
  end;
end;

function s_image_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateImage(Args[0].p, 'image_onresize$') then Exit();
  try
    Result.s := TBasImage(Args[0].p).OnResizeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_onresize$: ' + E.Message);
  end;
end;

function p_image_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateImage(Args[0].p, 'image_clearcallbacks#') then Exit();

  try
    with TBasImage(Args[0].p) do
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
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'image_clearcallbacks#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterImageFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;

  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_image_error; Lib.Add('image_error@', Fn);
  Fn.Entry := @s_image_errormsg; Lib.Add('image_errormsg$@', Fn);
  Fn.Entry := @s_image_strerror; Lib.Add('image_strerror$@n', Fn);
  Fn.Entry := @n_image_clearerror; Lib.Add('image_clearerror@', Fn);

  // Image creation/destruction
  Fn.Entry := @p_image_new; Lib.Add('image#@#', Fn);
  Fn.Entry := @p_image_new_size; Lib.Add('image#@#nn', Fn);
  Fn.Entry := @p_image_new_full; Lib.Add('image#@#nnnn', Fn);
  Fn.Entry := @n_image_free; Lib.Add('image_free@#', Fn);

  // Image loading/saving
  Fn.Entry := @n_image_load; Lib.Add('image_load@#$', Fn);
  Fn.Entry := @p_image_load_ptr; Lib.Add('image_load#@#$', Fn);
  Fn.Entry := @n_image_save; Lib.Add('image_save@#$', Fn);
  Fn.Entry := @p_image_save_ptr; Lib.Add('image_save#@#$', Fn);

  // Bitmap properties
  Fn.Entry := @n_image_bitmapwidth; Lib.Add('image_bitmapwidth@#', Fn);
  Fn.Entry := @n_image_bitmapheight; Lib.Add('image_bitmapheight@#', Fn);
  Fn.Entry := @n_image_isempty; Lib.Add('image_isempty@#', Fn);
  Fn.Entry := @p_image_clear; Lib.Add('image_clear#@#', Fn);
  Fn.Entry := @p_image_clearcolor; Lib.Add('image_clear#@#$', Fn);

  // WrapMode
  Fn.Entry := @n_image_wrapmode_get; Lib.Add('image_wrapmode@#', Fn);
  Fn.Entry := @p_image_wrapmode_set; Lib.Add('image_wrapmode#@#n', Fn);

  // Position and Size
  Fn.Entry := @n_image_x_get; Lib.Add('image_x@#', Fn);
  Fn.Entry := @p_image_x_set; Lib.Add('image_x#@#n', Fn);
  Fn.Entry := @n_image_y_get; Lib.Add('image_y@#', Fn);
  Fn.Entry := @p_image_y_set; Lib.Add('image_y#@#n', Fn);
  Fn.Entry := @n_image_width_get; Lib.Add('image_width@#', Fn);
  Fn.Entry := @p_image_width_set; Lib.Add('image_width#@#n', Fn);
  Fn.Entry := @n_image_height_get; Lib.Add('image_height@#', Fn);
  Fn.Entry := @p_image_height_set; Lib.Add('image_height#@#n', Fn);
  Fn.Entry := @p_image_bounds_set; Lib.Add('image_bounds#@#nnnn', Fn);
  Fn.Entry := @p_image_size_set; Lib.Add('image_size#@#nn', Fn);
  Fn.Entry := @p_image_move_set; Lib.Add('image_move#@#nn', Fn);

  // Alignment
  Fn.Entry := @n_image_align_get; Lib.Add('image_align@#', Fn);
  Fn.Entry := @p_image_align_set; Lib.Add('image_align#@#n', Fn);

  // Margins
  Fn.Entry := @n_image_marginleft_get; Lib.Add('image_marginleft@#', Fn);
  Fn.Entry := @p_image_marginleft_set; Lib.Add('image_marginleft#@#n', Fn);
  Fn.Entry := @n_image_margintop_get; Lib.Add('image_margintop@#', Fn);
  Fn.Entry := @p_image_margintop_set; Lib.Add('image_margintop#@#n', Fn);
  Fn.Entry := @n_image_marginright_get; Lib.Add('image_marginright@#', Fn);
  Fn.Entry := @p_image_marginright_set; Lib.Add('image_marginright#@#n', Fn);
  Fn.Entry := @n_image_marginbottom_get; Lib.Add('image_marginbottom@#', Fn);
  Fn.Entry := @p_image_marginbottom_set; Lib.Add('image_marginbottom#@#n', Fn);
  Fn.Entry := @p_image_margins_set; Lib.Add('image_margins#@#nnnn', Fn);
  Fn.Entry := @p_image_margin_set; Lib.Add('image_margin#@#n', Fn);

  // Visibility and behavior
  Fn.Entry := @n_image_visible_get; Lib.Add('image_visible@#', Fn);
  Fn.Entry := @p_image_visible_set; Lib.Add('image_visible#@#n', Fn);
  Fn.Entry := @n_image_enabled_get; Lib.Add('image_enabled@#', Fn);
  Fn.Entry := @p_image_enabled_set; Lib.Add('image_enabled#@#n', Fn);
  Fn.Entry := @n_image_opacity_get; Lib.Add('image_opacity@#', Fn);
  Fn.Entry := @p_image_opacity_set; Lib.Add('image_opacity#@#n', Fn);
  Fn.Entry := @n_image_hittest_get; Lib.Add('image_hittest@#', Fn);
  Fn.Entry := @p_image_hittest_set; Lib.Add('image_hittest#@#n', Fn);

  // Tag and rotation
  Fn.Entry := @n_image_tag_get; Lib.Add('image_tag@#', Fn);
  Fn.Entry := @p_image_tag_set; Lib.Add('image_tag#@#n', Fn);
  Fn.Entry := @n_image_rotation_get; Lib.Add('image_rotation@#', Fn);
  Fn.Entry := @p_image_rotation_set; Lib.Add('image_rotation#@#n', Fn);

  // Parent
  Fn.Entry := @p_image_parent_get; Lib.Add('image_parent#@#', Fn);
  Fn.Entry := @p_image_parent_set; Lib.Add('image_parent#@##', Fn);
  Fn.Entry := @p_image_bringtofront; Lib.Add('image_bringtofront#@#', Fn);
  Fn.Entry := @p_image_sendtoback; Lib.Add('image_sendtoback#@#', Fn);

  // Invalidation
  Fn.Entry := @p_image_invalidate; Lib.Add('image_invalidate#@#', Fn);

  // Event callbacks
  Fn.Entry := @p_image_onclick_set; Lib.Add('image_onclick#@#$', Fn);
  Fn.Entry := @s_image_onclick_get; Lib.Add('image_onclick$@#', Fn);
  Fn.Entry := @p_image_ondblclick_set; Lib.Add('image_ondblclick#@#$', Fn);
  Fn.Entry := @s_image_ondblclick_get; Lib.Add('image_ondblclick$@#', Fn);
  Fn.Entry := @p_image_onmousedown_set; Lib.Add('image_onmousedown#@#$', Fn);
  Fn.Entry := @s_image_onmousedown_get; Lib.Add('image_onmousedown$@#', Fn);
  Fn.Entry := @p_image_onmouseup_set; Lib.Add('image_onmouseup#@#$', Fn);
  Fn.Entry := @s_image_onmouseup_get; Lib.Add('image_onmouseup$@#', Fn);
  Fn.Entry := @p_image_onmousemove_set; Lib.Add('image_onmousemove#@#$', Fn);
  Fn.Entry := @s_image_onmousemove_get; Lib.Add('image_onmousemove$@#', Fn);
  Fn.Entry := @p_image_onmouseenter_set; Lib.Add('image_onmouseenter#@#$', Fn);
  Fn.Entry := @s_image_onmouseenter_get; Lib.Add('image_onmouseenter$@#', Fn);
  Fn.Entry := @p_image_onmouseleave_set; Lib.Add('image_onmouseleave#@#$', Fn);
  Fn.Entry := @s_image_onmouseleave_get; Lib.Add('image_onmouseleave$@#', Fn);
  Fn.Entry := @p_image_onmousewheel_set; Lib.Add('image_onmousewheel#@#$', Fn);
  Fn.Entry := @s_image_onmousewheel_get; Lib.Add('image_onmousewheel$@#', Fn);
  Fn.Entry := @p_image_onresize_set; Lib.Add('image_onresize#@#$', Fn);
  Fn.Entry := @s_image_onresize_get; Lib.Add('image_onresize$@#', Fn);
  Fn.Entry := @p_image_clearcallbacks; Lib.Add('image_clearcallbacks#@#', Fn);
end;

end.
