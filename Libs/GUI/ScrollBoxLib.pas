unit ScrollBoxLib;

{******************************************************************************
  ScrollBoxLib - Vertical Scroll Box Container Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TVertScrollBox wrapper functionality for
  creating and managing vertically-scrolling container controls in Plan9Basic
  programs. TVertScrollBox is a scrollable container that enables vertical
  scrolling of its child controls.

  Function Count: 25 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All scroll boxes are created at RUNTIME using TVertScrollBox.Create with
  dynamic parent assignment. This ensures proper dynamic creation across all
  FireMonkey platforms.

  FEATURES:
  =========
  - Scroll box creation and lifecycle management
  - Position, size, and alignment control
  - Visibility and opacity control
  - ShowScrollBars property access
  - Content size query (viewport content dimensions)
  - Tag support for user data
  - Error tracking with descriptive messages

  ALIGNMENT VALUES:
  =================
  0  = None         - No alignment (manual positioning)
  1  = Top          - Align to top
  2  = Left         - Align to left
  3  = Right        - Align to right
  4  = Bottom       - Align to bottom
  5  = MostTop      - Align to very top (above Top)
  6  = MostBottom   - Align to very bottom (below Bottom)
  7  = MostLeft     - Align to very left (before Left)
  8  = MostRight    - Align to very right (after Right)
  9  = Client       - Fill remaining client area
  10 = Contents     - Fit to contents
  11 = Center       - Center in parent
  12 = VertCenter   - Center vertically
  13 = HorzCenter   - Center horizontally
  14 = Horizontal   - Stretch horizontally
  15 = Vertical     - Stretch vertically
  16 = Scale        - Scale proportionally
  17 = Fit          - Fit within parent
  18 = FitLeft      - Fit and align left
  19 = FitRight     - Fit and align right

  USAGE PATTERN:
  ==============
    LET frm# = form#("Scroll Demo", 800, 600)

    ' Create a scroll box filling the form
    LET sb# = scrollbox#(frm#)
    scrollbox_align#(sb#, 9)  ' Client fill (default)

    ' Create a scroll box at a specific position
    LET sb2# = scrollbox#(frm#, 10, 10, 300, 400)

    ' Add child controls to the scroll box (children scroll with it)
    LET lbl# = label#(sb#, "Line 1 of many...", 10, 10)

    ' Control scroll bar visibility
    scrollbox_showscrollbars#(sb#, 1)

    ' Query content dimensions
    LET cw = scrollbox_contentwidth(sb#)
    LET ch = scrollbox_contentheight(sb#)

    form_show(frm#)

  FUNCTION REFERENCE:
  ===================
  Creation / Destruction:
    scrollbox#(parent#)                - Create scroll box filling parent (Client align)
    scrollbox#(parent#, x, y, w, h)   - Create scroll box at specific bounds
    scrollbox_free(sb#)                - Destroy scroll box and free memory

  Position and Size:
    scrollbox_x(sb#)                   - Get X position
    scrollbox_y(sb#)                   - Get Y position
    scrollbox_move#(sb#, x, y)         - Set position
    scrollbox_width(sb#)               - Get width
    scrollbox_width#(sb#, w)           - Set width
    scrollbox_height(sb#)              - Get height
    scrollbox_height#(sb#, h)          - Set height

  Alignment:
    scrollbox_align(sb#)               - Get alignment (see ALIGNMENT VALUES)
    scrollbox_align#(sb#, a)           - Set alignment

  Visibility and Opacity:
    scrollbox_visible(sb#)             - Get visibility (1=visible, 0=hidden)
    scrollbox_visible#(sb#, v)         - Set visibility
    scrollbox_opacity(sb#)             - Get opacity (0.0 to 1.0)
    scrollbox_opacity#(sb#, o)         - Set opacity

  Tag:
    scrollbox_tag(sb#)                 - Get integer tag value
    scrollbox_tag#(sb#, t)             - Set integer tag value

  ScrollBox-specific:
    scrollbox_showscrollbars(sb#)      - Get scroll bar visibility (1=shown)
    scrollbox_showscrollbars#(sb#, v)  - Show (1) or hide (0) scroll bars
    scrollbox_contentwidth(sb#)        - Get scrollable content width
    scrollbox_contentheight(sb#)       - Get scrollable content height

  Error Handling:
    scrollbox_error()                  - Get last error code (0 = no error)
    scrollbox_clearerror()             - Clear last error
    scrollbox_strerror$(code)          - Get error description string

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Layouts,
  FMX.ScrollBox,
  basic, exec, UnitGC, HandleRegistry, ControlCommon;

// Library registration
procedure RegisterScrollBoxFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  // Error codes
  ERR_NONE            = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_SB      = 1;
  ERR_INVALID_PARENT  = 2;
  ERR_INVALID_VALUE   = 3;
  ERR_CREATE_FAILED   = 4;

  // Alignment constants (matching TAlignLayout ordinals)

var
  lastError: Integer;
  lastErrorMsg: String;
  ModuleEngine: TBasicEngine;
  ModuleOutput: TStrings;

//==============================================================================
// Internal Helpers
//==============================================================================

procedure SetError(Code: Integer; const Msg: String);
begin
  lastError    := Code;
  lastErrorMsg := Msg;
end;

procedure ClearError();
begin
  lastError    := ERR_NONE;
  lastErrorMsg := '';
end;

function ValidateScrollBox(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_SB, FuncName + ': Nil scroll box pointer');
    Exit;
  end;
  try
    if not (IsHandleOf(P, TVertScrollBox)) then
    begin
      SetError(ERR_INVALID_SB, FuncName + ': Invalid scroll box object');
      Exit;
    end;
  except
    SetError(ERR_INVALID_SB, FuncName + ': Invalid scroll box pointer');
    Exit;
  end;
  ClearError();
  Result := True;
end;

function ValidateParent(P: Pointer; const FuncName: String): Boolean;
var
  M: String;
begin
  Result := ControlCommon.ParentIsValid(P, FuncName, M);
  if Result then
    ClearError()
  else
    SetError(ERR_INVALID_PARENT, M);
end;

//==============================================================================
// Error Handling Functions
//==============================================================================

// scrollbox_error() - Get last error code
function n_scrollbox_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

// scrollbox_clearerror() - Clear error state
function n_scrollbox_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

// scrollbox_strerror$(code) - Get error description string
function s_scrollbox_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE:           Result.s := 'No error';
    ERR_INVALID_SB:     Result.s := 'Invalid or nil scroll box';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent control';
    ERR_INVALID_VALUE:  Result.s := 'Invalid value';
    ERR_CREATE_FAILED:  Result.s := 'Scroll box creation failed';
  else
    Result.s := 'Unknown error: ' + IntToStr(Code);
  end;
end;

//==============================================================================
// Creation and Destruction
//==============================================================================

// scrollbox#(parent#) - Create filling parent with Client alignment
function p_scrollbox_new(var Args: array of TAsmData): TAsmData;
var
  SB: TVertScrollBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateParent(Args[0].p, 'scrollbox#') then Exit;
  try
    SB        := TVertScrollBox.Create(nil);
    //Without this every scrollbox_* call fails validation: the handle is
    //checked against the registry, and an unregistered object is indis-
    //tinguishable from a fabricated pointer. Revocation rides on the
    //watcher's FreeNotification, since the parent is what frees this.
    RegisterHandle(SB);
    SB.Parent := TFmxObject(Args[0].p);
    SB.Align  := TAlignLayout.Client;
    Result.p  := Pointer(SB);
    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'scrollbox#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// scrollbox#(parent#, x, y, w, h) - Create at specific bounds
function p_scrollbox_new_full(var Args: array of TAsmData): TAsmData;
var
  SB: TVertScrollBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateParent(Args[0].p, 'scrollbox#') then Exit;
  try
    SB              := TVertScrollBox.Create(nil);
    //Without this every scrollbox_* call fails validation: the handle is
    //checked against the registry, and an unregistered object is indis-
    //tinguishable from a fabricated pointer. Revocation rides on the
    //watcher's FreeNotification, since the parent is what frees this.
    RegisterHandle(SB);
    SB.Parent       := TFmxObject(Args[0].p);
    SB.Align        := TAlignLayout.None;
    SB.Position.X   := Args[1].n;
    SB.Position.Y   := Args[2].n;
    SB.Width        := Args[3].n;
    SB.Height       := Args[4].n;
    Result.p        := Pointer(SB);
    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'scrollbox#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// scrollbox_free(sb#) - Destroy scroll box
function n_scrollbox_free(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_free') then Exit;
  try
    TVertScrollBox(Args[0].p).Free();
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_SB, 'scrollbox_free: ' + E.Message);
  end;
end;

//==============================================================================
// Position and Size
//==============================================================================

// scrollbox_x(sb#) - Get X position
function n_scrollbox_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_x') then Exit;
  try Result.n := TVertScrollBox(Args[0].p).Position.X; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_x: ' + E.Message); end;
end;

// scrollbox_y(sb#) - Get Y position
function n_scrollbox_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_y') then Exit;
  try Result.n := TVertScrollBox(Args[0].p).Position.Y; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_y: ' + E.Message); end;
end;

// scrollbox_move#(sb#, x, y) - Set position
function p_scrollbox_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_move#') then Exit;
  try
    TVertScrollBox(Args[0].p).Position.X := Args[1].n;
    TVertScrollBox(Args[0].p).Position.Y := Args[2].n;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_move#: ' + E.Message); end;
end;

// scrollbox_width(sb#) - Get width
function n_scrollbox_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_width') then Exit;
  try Result.n := TVertScrollBox(Args[0].p).Width; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_width: ' + E.Message); end;
end;

// scrollbox_width#(sb#, w) - Set width
function p_scrollbox_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_width#') then Exit;
  try TVertScrollBox(Args[0].p).Width := Args[1].n; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_width#: ' + E.Message); end;
end;

// scrollbox_height(sb#) - Get height
function n_scrollbox_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_height') then Exit;
  try Result.n := TVertScrollBox(Args[0].p).Height; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_height: ' + E.Message); end;
end;

// scrollbox_height#(sb#, h) - Set height
function p_scrollbox_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_height#') then Exit;
  try TVertScrollBox(Args[0].p).Height := Args[1].n; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_height#: ' + E.Message); end;
end;

//==============================================================================
// Alignment
//==============================================================================

// scrollbox_align(sb#) - Get alignment
function n_scrollbox_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_align') then Exit;
  try Result.n := AlignToInt(TVertScrollBox(Args[0].p).Align); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_align: ' + E.Message); end;
end;

// scrollbox_align#(sb#, a) - Set alignment
function p_scrollbox_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_align#') then Exit;
  try TVertScrollBox(Args[0].p).Align := AlignFromInt(Trunc(Args[1].n)); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_align#: ' + E.Message); end;
end;

//==============================================================================
// Visibility and Opacity
//==============================================================================

// scrollbox_visible(sb#) - Get visibility
function n_scrollbox_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_visible') then Exit;
  try
    if TVertScrollBox(Args[0].p).Visible then Result.n := 1 else Result.n := 0;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_visible: ' + E.Message); end;
end;

// scrollbox_visible#(sb#, v) - Set visibility
function p_scrollbox_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_visible#') then Exit;
  try TVertScrollBox(Args[0].p).Visible := (Args[1].n <> 0); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_visible#: ' + E.Message); end;
end;

// scrollbox_opacity(sb#) - Get opacity
function n_scrollbox_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_opacity') then Exit;
  try Result.n := TVertScrollBox(Args[0].p).Opacity; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_opacity: ' + E.Message); end;
end;

// scrollbox_opacity#(sb#, o) - Set opacity
function p_scrollbox_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_opacity#') then Exit;
  try TVertScrollBox(Args[0].p).Opacity := Args[1].n; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_opacity#: ' + E.Message); end;
end;

//==============================================================================
// Tag
//==============================================================================

// scrollbox_tag(sb#) - Get tag
function n_scrollbox_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_tag') then Exit;
  try Result.n := TVertScrollBox(Args[0].p).Tag; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_tag: ' + E.Message); end;
end;

// scrollbox_tag#(sb#, t) - Set tag
function p_scrollbox_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_tag#') then Exit;
  try TVertScrollBox(Args[0].p).Tag := Trunc(Args[1].n); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_tag#: ' + E.Message); end;
end;

//==============================================================================
// ScrollBox-specific
//==============================================================================

// scrollbox_showscrollbars(sb#) - Get scroll bar visibility
function n_scrollbox_showscrollbars_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_showscrollbars') then Exit;
  try
    if TVertScrollBox(Args[0].p).ShowScrollBars then Result.n := 1 else Result.n := 0;
  except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_showscrollbars: ' + E.Message); end;
end;

// scrollbox_showscrollbars#(sb#, v) - Show or hide scroll bars
function p_scrollbox_showscrollbars_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_showscrollbars#') then Exit;
  try TVertScrollBox(Args[0].p).ShowScrollBars := (Args[1].n <> 0); except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_showscrollbars#: ' + E.Message); end;
end;

// scrollbox_contentwidth(sb#) - Get scrollable content width
function n_scrollbox_contentwidth_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_contentwidth') then Exit;
  try Result.n := TVertScrollBox(Args[0].p).ContentBounds.Width; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_contentwidth: ' + E.Message); end;
end;

// scrollbox_contentheight(sb#) - Get scrollable content height
function n_scrollbox_contentheight_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateScrollBox(Args[0].p, 'scrollbox_contentheight') then Exit;
  try Result.n := TVertScrollBox(Args[0].p).ContentBounds.Height; except on E: Exception do SetError(ERR_OPERATION_FAILED, 'scrollbox_contentheight: ' + E.Message); end;
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterScrollBoxFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;

  Fn.FarCall := True;

  // Error handling
  Fn.Entry := @n_scrollbox_error; Lib.Add('scrollbox_error@', Fn);
  Fn.Entry := @n_scrollbox_clearerror; Lib.Add('scrollbox_clearerror@', Fn);
  Fn.Entry := @s_scrollbox_strerror; Lib.Add('scrollbox_strerror$@n', Fn);

  // Creation / destruction
  Fn.Entry := @p_scrollbox_new; Lib.Add('scrollbox#@#', Fn);
  Fn.Entry := @p_scrollbox_new_full; Lib.Add('scrollbox#@#nnnn', Fn);
  Fn.Entry := @n_scrollbox_free; Lib.Add('scrollbox_free@#', Fn);

  // Position
  Fn.Entry := @n_scrollbox_x_get; Lib.Add('scrollbox_x@#', Fn);
  Fn.Entry := @n_scrollbox_y_get; Lib.Add('scrollbox_y@#', Fn);
  Fn.Entry := @p_scrollbox_move_set; Lib.Add('scrollbox_move#@#nn', Fn);

  // Size
  Fn.Entry := @n_scrollbox_width_get; Lib.Add('scrollbox_width@#', Fn);
  Fn.Entry := @p_scrollbox_width_set; Lib.Add('scrollbox_width#@#n', Fn);
  Fn.Entry := @n_scrollbox_height_get; Lib.Add('scrollbox_height@#', Fn);
  Fn.Entry := @p_scrollbox_height_set; Lib.Add('scrollbox_height#@#n', Fn);

  // Alignment
  Fn.Entry := @n_scrollbox_align_get; Lib.Add('scrollbox_align@#', Fn);
  Fn.Entry := @p_scrollbox_align_set; Lib.Add('scrollbox_align#@#n', Fn);

  // Visibility
  Fn.Entry := @n_scrollbox_visible_get; Lib.Add('scrollbox_visible@#', Fn);
  Fn.Entry := @p_scrollbox_visible_set; Lib.Add('scrollbox_visible#@#n', Fn);

  // Opacity
  Fn.Entry := @n_scrollbox_opacity_get; Lib.Add('scrollbox_opacity@#', Fn);
  Fn.Entry := @p_scrollbox_opacity_set; Lib.Add('scrollbox_opacity#@#n', Fn);

  // Tag
  Fn.Entry := @n_scrollbox_tag_get; Lib.Add('scrollbox_tag@#', Fn);
  Fn.Entry := @p_scrollbox_tag_set; Lib.Add('scrollbox_tag#@#n', Fn);

  // ScrollBox-specific
  Fn.Entry := @n_scrollbox_showscrollbars_get; Lib.Add('scrollbox_showscrollbars@#', Fn);
  Fn.Entry := @p_scrollbox_showscrollbars_set; Lib.Add('scrollbox_showscrollbars#@#n', Fn);
  Fn.Entry := @n_scrollbox_contentwidth_get; Lib.Add('scrollbox_contentwidth@#', Fn);
  Fn.Entry := @n_scrollbox_contentheight_get; Lib.Add('scrollbox_contentheight@#', Fn);
end;

end.
