unit ListBoxLib;

{******************************************************************************
  ListBoxLib - ListBox Control Library for Plan9Basic
  Version: 1.0.0

  Provides complete FireMonkey TListBox wrapper functionality for creating
  and managing list controls in Plan9Basic programs.

  Function Count: 120+ functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  EVENT CONNECTION MODEL:
  =======================
  Events are connected/disconnected individually when callbacks are set:
  - Setting a non-empty callback name connects ONLY that specific event
  - Setting an empty callback name ("") disconnects ONLY that specific event
  - No events are connected by default in the constructor

  EVENTS SUPPORT:
  ===============
  - OnChange: Selection changed (primary listbox event)
  - OnItemClick: Item was clicked (receives sender# and item#)
  - OnClick: ListBox was clicked
  - OnDblClick: ListBox was double-clicked
  - OnEnter: ListBox received focus
  - OnExit: ListBox lost focus
  - OnKeyDown: Key was pressed while focused
  - OnKeyUp: Key was released while focused
  - OnMouseDown: Mouse button pressed
  - OnMouseUp: Mouse button released
  - OnMouseMove: Mouse moved over control
  - OnMouseEnter: Mouse entered control area
  - OnMouseLeave: Mouse left control area
  - OnResize: Control is being resized
  - OnDragEnter: Drag operation entered control
  - OnDragOver: Drag operation over control (return non-zero to accept)
  - OnDragDrop: Item was dropped on control
  - OnDragLeave: Drag operation left control

  MULTI-SELECT SUPPORT:
  =====================
  ListBox supports multi-select mode:
  - listbox_multiselect#(lb#, 1) to enable
  - listbox_isselected(lb#, idx) to check if item is selected
  - listbox_selectitem#(lb#, idx, 1/0) to select/deselect
  - listbox_selectall(lb#) to select all items
  - listbox_clearselection(lb#) to deselect all
  - listbox_selcount(lb#) to get number of selected items

  USAGE PATTERN:
  ==============
    let frm# = form#("ListBox Demo", 400, 300)
    
    let lb# = listbox#(frm#)
    listbox_bounds#(lb#, 20, 20, 200, 200)
    listbox_multiselect#(lb#, 1)
    listbox_add(lb#, "Item 1")
    listbox_add(lb#, "Item 2")
    listbox_add(lb#, "Item 3")
    listbox_onchange#(lb#, "OnListChange")
    listbox_onitemclick#(lb#, "OnItemClick")
    
    form_show(frm#)

  EVENT CALLBACK SIGNATURES:
  ==========================
    function OnListChange(sender#) local cnt
      cnt = listbox_selcount(sender#)
      println "Selected: " + str$(cnt) + " items"
    endfunction

    function OnItemClick(sender#, item#) local txt$
      txt$ = listboxitem_text$(item#)
      println "Clicked: " + txt$
    endfunction

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.ListBox,
  FMX.Controls.Presentation, FMX.Text,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, ControlCommon;

type
  TBasListBox = class(TListBox)
  private
    FOnChangeFunc: String;
    FOnItemClickFunc: String;
    FOnClickFunc: String;
    FOnDblClickFunc: String;
    FOnEnterFunc: String;
    FOnExitFunc: String;
    FOnKeyDownFunc: String;
    FOnKeyUpFunc: String;
    FOnMouseDownFunc: String;
    FOnMouseUpFunc: String;
    FOnMouseMoveFunc: String;
    FOnMouseEnterFunc: String;
    FOnMouseLeaveFunc: String;
    FOnResizeFunc: String;
    FOnDragEnterFunc: String;
    FOnDragOverFunc: String;
    FOnDragDropFunc: String;
    FOnDragLeaveFunc: String;
    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;
    FSuppressCallbacks: Boolean;

    procedure InternalOnChange(Sender: TObject);
    procedure InternalOnItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure InternalOnClick(Sender: TObject);
    procedure InternalOnDblClick(Sender: TObject);
    procedure InternalOnEnter(Sender: TObject);
    procedure InternalOnExit(Sender: TObject);
    procedure InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseEnter(Sender: TObject);
    procedure InternalOnMouseLeave(Sender: TObject);
    procedure InternalOnResize(Sender: TObject);
    procedure InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
    procedure InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
    procedure InternalOnDragLeave(Sender: TObject);

    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
    function ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;

    procedure SetOnChangeFunc(const Value: String);
    procedure SetOnItemClickFunc(const Value: String);
    procedure SetOnClickFunc(const Value: String);
    procedure SetOnDblClickFunc(const Value: String);
    procedure SetOnEnterFunc(const Value: String);
    procedure SetOnExitFunc(const Value: String);
    procedure SetOnKeyDownFunc(const Value: String);
    procedure SetOnKeyUpFunc(const Value: String);
    procedure SetOnMouseDownFunc(const Value: String);
    procedure SetOnMouseUpFunc(const Value: String);
    procedure SetOnMouseMoveFunc(const Value: String);
    procedure SetOnMouseEnterFunc(const Value: String);
    procedure SetOnMouseLeaveFunc(const Value: String);
    procedure SetOnResizeFunc(const Value: String);
    procedure SetOnDragEnterFunc(const Value: String);
    procedure SetOnDragOverFunc(const Value: String);
    procedure SetOnDragDropFunc(const Value: String);
    procedure SetOnDragLeaveFunc(const Value: String);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure DisconnectAllEvents();

    property OnChangeFunc: String read FOnChangeFunc write SetOnChangeFunc;
    property OnItemClickFunc: String read FOnItemClickFunc write SetOnItemClickFunc;
    property OnClickFunc: String read FOnClickFunc write SetOnClickFunc;
    property OnDblClickFunc: String read FOnDblClickFunc write SetOnDblClickFunc;
    property OnEnterFunc: String read FOnEnterFunc write SetOnEnterFunc;
    property OnExitFunc: String read FOnExitFunc write SetOnExitFunc;
    property OnKeyDownFunc: String read FOnKeyDownFunc write SetOnKeyDownFunc;
    property OnKeyUpFunc: String read FOnKeyUpFunc write SetOnKeyUpFunc;
    property OnMouseDownFunc: String read FOnMouseDownFunc write SetOnMouseDownFunc;
    property OnMouseUpFunc: String read FOnMouseUpFunc write SetOnMouseUpFunc;
    property OnMouseMoveFunc: String read FOnMouseMoveFunc write SetOnMouseMoveFunc;
    property OnMouseEnterFunc: String read FOnMouseEnterFunc write SetOnMouseEnterFunc;
    property OnMouseLeaveFunc: String read FOnMouseLeaveFunc write SetOnMouseLeaveFunc;
    property OnResizeFunc: String read FOnResizeFunc write SetOnResizeFunc;
    property OnDragEnterFunc: String read FOnDragEnterFunc write SetOnDragEnterFunc;
    property OnDragOverFunc: String read FOnDragOverFunc write SetOnDragOverFunc;
    property OnDragDropFunc: String read FOnDragDropFunc write SetOnDragDropFunc;
    property OnDragLeaveFunc: String read FOnDragLeaveFunc write SetOnDragLeaveFunc;
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
    property SuppressCallbacks: Boolean read FSuppressCallbacks write FSuppressCallbacks;
  end;

procedure RegisterListBoxFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  LISTBOX_GC_TAG = 'BASIC_LISTBOX';
  ERR_NONE = 0;
  ERR_INVALID_LISTBOX = 1;
  ERR_INVALID_PARENT = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INDEX_OUT_OF_RANGE = 5;


var
  lastError: Integer;
  lastErrorMsg: String;
  ModuleEngine: TBasicEngine;
  ModuleOutput: TStrings;

{ Error handling }

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

{ Validation helpers }

function ValidateListBox(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;

  if P = nil then
  begin
    SetError(ERR_INVALID_LISTBOX, FuncName + ': Nil pointer');
    Exit();
  end;

  try
    if not(IsHandleOf(P, TBasListBox)) then
    begin
      SetError(ERR_INVALID_LISTBOX, FuncName + ': Invalid object');
      Exit();
    end;
  except
    SetError(ERR_INVALID_LISTBOX, FuncName + ': Invalid pointer');
    Exit();
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

{ Alignment conversion helpers }

{ TBasListBox implementation }

constructor TBasListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);
  FOnChangeFunc := '';
  FOnItemClickFunc := '';
  FOnClickFunc := '';
  FOnDblClickFunc := '';
  FOnEnterFunc := '';
  FOnExitFunc := '';
  FOnKeyDownFunc := '';
  FOnKeyUpFunc := '';
  FOnMouseDownFunc := '';
  FOnMouseUpFunc := '';
  FOnMouseMoveFunc := '';
  FOnMouseEnterFunc := '';
  FOnMouseLeaveFunc := '';
  FOnResizeFunc := '';
  FOnDragEnterFunc := '';
  FOnDragOverFunc := '';
  FOnDragDropFunc := '';
  FOnDragLeaveFunc := '';
  FBasicEngine := nil;
  FConsoleOutput := nil;
  FSuppressCallbacks := False;
end;

destructor TBasListBox.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasListBox.DisconnectAllEvents();
begin
  Self.OnChange := nil;
  Self.OnItemClick := nil;
  Self.OnClick := nil;
  Self.OnDblClick := nil;
  Self.OnEnter := nil;
  Self.OnExit := nil;
  Self.OnKeyDown := nil;
  Self.OnKeyUp := nil;
  Self.OnMouseDown := nil;
  Self.OnMouseUp := nil;
  Self.OnMouseMove := nil;
  Self.OnMouseEnter := nil;
  Self.OnMouseLeave := nil;
  Self.OnResize := nil;
  Self.OnDragEnter := nil;
  Self.OnDragOver := nil;
  Self.OnDragDrop := nil;
  Self.OnDragLeave := nil;
end;

{ Event property setters - individual event connection }

procedure TBasListBox.SetOnChangeFunc(const Value: String);
begin
  FOnChangeFunc := Value;
  if Value <> '' then
    Self.OnChange := InternalOnChange
  else
    Self.OnChange := nil;
end;

procedure TBasListBox.SetOnItemClickFunc(const Value: String);
begin
  FOnItemClickFunc := Value;
  if Value <> '' then
    Self.OnItemClick := InternalOnItemClick
  else
    Self.OnItemClick := nil;
end;

procedure TBasListBox.SetOnClickFunc(const Value: String);
begin
  FOnClickFunc := Value;
  if Value <> '' then
    Self.OnClick := InternalOnClick
  else
    Self.OnClick := nil;
end;

procedure TBasListBox.SetOnDblClickFunc(const Value: String);
begin
  FOnDblClickFunc := Value;
  if Value <> '' then
    Self.OnDblClick := InternalOnDblClick
  else
    Self.OnDblClick := nil;
end;

procedure TBasListBox.SetOnEnterFunc(const Value: String);
begin
  FOnEnterFunc := Value;
  if Value <> '' then
    Self.OnEnter := InternalOnEnter
  else
    Self.OnEnter := nil;
end;

procedure TBasListBox.SetOnExitFunc(const Value: String);
begin
  FOnExitFunc := Value;
  if Value <> '' then
    Self.OnExit := InternalOnExit
  else
    Self.OnExit := nil;
end;

procedure TBasListBox.SetOnKeyDownFunc(const Value: String);
begin
  FOnKeyDownFunc := Value;
  if Value <> '' then
    Self.OnKeyDown := InternalOnKeyDown
  else
    Self.OnKeyDown := nil;
end;

procedure TBasListBox.SetOnKeyUpFunc(const Value: String);
begin
  FOnKeyUpFunc := Value;
  if Value <> '' then
    Self.OnKeyUp := InternalOnKeyUp
  else
    Self.OnKeyUp := nil;
end;

procedure TBasListBox.SetOnMouseDownFunc(const Value: String);
begin
  FOnMouseDownFunc := Value;
  if Value <> '' then
    Self.OnMouseDown := InternalOnMouseDown
  else
    Self.OnMouseDown := nil;
end;

procedure TBasListBox.SetOnMouseUpFunc(const Value: String);
begin
  FOnMouseUpFunc := Value;
  if Value <> '' then
    Self.OnMouseUp := InternalOnMouseUp
  else
    Self.OnMouseUp := nil;
end;

procedure TBasListBox.SetOnMouseMoveFunc(const Value: String);
begin
  FOnMouseMoveFunc := Value;
  if Value <> '' then
    Self.OnMouseMove := InternalOnMouseMove
  else
    Self.OnMouseMove := nil;
end;

procedure TBasListBox.SetOnMouseEnterFunc(const Value: String);
begin
  FOnMouseEnterFunc := Value;
  if Value <> '' then
    Self.OnMouseEnter := InternalOnMouseEnter
  else
    Self.OnMouseEnter := nil;
end;

procedure TBasListBox.SetOnMouseLeaveFunc(const Value: String);
begin
  FOnMouseLeaveFunc := Value;
  if Value <> '' then
    Self.OnMouseLeave := InternalOnMouseLeave
  else
    Self.OnMouseLeave := nil;
end;

procedure TBasListBox.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    Self.OnResize := InternalOnResize
  else
    Self.OnResize := nil;
end;

procedure TBasListBox.SetOnDragEnterFunc(const Value: String);
begin
  FOnDragEnterFunc := Value;
  if Value <> '' then
    Self.OnDragEnter := InternalOnDragEnter
  else
    Self.OnDragEnter := nil;
end;

procedure TBasListBox.SetOnDragOverFunc(const Value: String);
begin
  FOnDragOverFunc := Value;
  if Value <> '' then
    Self.OnDragOver := InternalOnDragOver
  else
    Self.OnDragOver := nil;
end;

procedure TBasListBox.SetOnDragDropFunc(const Value: String);
begin
  FOnDragDropFunc := Value;
  if Value <> '' then
    Self.OnDragDrop := InternalOnDragDrop
  else
    Self.OnDragDrop := nil;
end;

procedure TBasListBox.SetOnDragLeaveFunc(const Value: String);
begin
  FOnDragLeaveFunc := Value;
  if Value <> '' then
    Self.OnDragLeave := InternalOnDragLeave
  else
    Self.OnDragLeave := nil;
end;

{ Callback execution helpers }

procedure TBasListBox.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'ListBox');
end;

function TBasListBox.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
begin
  Result := ControlCommon.RunCallbackWithResult(FBasicEngine, FConsoleOutput,
                          FuncSignature, Args, 'ListBox');
end;

{ Internal event handlers }

procedure TBasListBox.InternalOnChange(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnChangeFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnChangeFunc) + '@#', Args);
end;

procedure TBasListBox.InternalOnItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
var
  Args: array[0..1] of TAsmData;
begin
  if FOnItemClickFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].p := Pointer(Item);
  Args[1].n := 0;
  Args[1].s := '';
  ExecuteCallback(LowerCase(FOnItemClickFunc) + '@##', Args);
end;

procedure TBasListBox.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnClickFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnClickFunc) + '@#', Args);
end;

procedure TBasListBox.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDblClickFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDblClickFunc) + '@#', Args);
end;

procedure TBasListBox.InternalOnEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnEnterFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnEnterFunc) + '@#', Args);
end;

procedure TBasListBox.InternalOnExit(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnExitFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnExitFunc) + '@#', Args);
end;

procedure TBasListBox.InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnKeyDownFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Key;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Ord(KeyChar);
  Args[2].p := nil;
  Args[2].s := '';
  ExecuteCallback(LowerCase(FOnKeyDownFunc) + '@#nn', Args);
end;

procedure TBasListBox.InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnKeyUpFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Key;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Ord(KeyChar);
  Args[2].p := nil;
  Args[2].s := '';
  ExecuteCallback(LowerCase(FOnKeyUpFunc) + '@#nn', Args);
end;

procedure TBasListBox.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnMouseDownFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Ord(Button);
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := X;
  Args[2].p := nil;
  Args[2].s := '';
  Args[3].n := Y;
  Args[3].p := nil;
  Args[3].s := '';
  ExecuteCallback(LowerCase(FOnMouseDownFunc) + '@#nnn', Args);
end;

procedure TBasListBox.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..3] of TAsmData;
begin
  if FOnMouseUpFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Ord(Button);
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := X;
  Args[2].p := nil;
  Args[2].s := '';
  Args[3].n := Y;
  Args[3].p := nil;
  Args[3].s := '';
  ExecuteCallback(LowerCase(FOnMouseUpFunc) + '@#nnn', Args);
end;

procedure TBasListBox.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnMouseMoveFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := X;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Y;
  Args[2].p := nil;
  Args[2].s := '';
  ExecuteCallback(LowerCase(FOnMouseMoveFunc) + '@#nn', Args);
end;

procedure TBasListBox.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseEnterFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseEnterFunc) + '@#', Args);
end;

procedure TBasListBox.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseLeaveFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseLeaveFunc) + '@#', Args);
end;

procedure TBasListBox.InternalOnResize(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizeFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizeFunc) + '@#', Args);
end;

procedure TBasListBox.InternalOnDragEnter(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragEnterFunc = '' then Exit();
  Args[0].p := Pointer(Self);
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

procedure TBasListBox.InternalOnDragOver(Sender: TObject; const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
var
  Args: array[0..2] of TAsmData;
  RetVal: TAsmData;
begin
  if FOnDragOverFunc = '' then
  begin
    Operation := TDragOperation.None;
    Exit();
  end;
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  Args[1].n := Point.X;
  Args[1].p := nil;
  Args[1].s := '';
  Args[2].n := Point.Y;
  Args[2].p := nil;
  Args[2].s := '';
  RetVal := ExecuteCallbackWithResult(LowerCase(FOnDragOverFunc) + '@#nn', Args);
  if RetVal.n <> 0 then
    Operation := TDragOperation.Move
  else
    Operation := TDragOperation.None;
end;

procedure TBasListBox.InternalOnDragDrop(Sender: TObject; const Data: TDragObject; const Point: TPointF);
var
  Args: array[0..2] of TAsmData;
begin
  if FOnDragDropFunc = '' then Exit();
  Args[0].p := Pointer(Self);
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

procedure TBasListBox.InternalOnDragLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDragLeaveFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDragLeaveFunc) + '@#', Args);
end;

{ ============================================================================
  PLAN9BASIC FUNCTION IMPLEMENTATIONS
  ============================================================================ }

{ Error functions }

function n_listbox_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

function s_listbox_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

function s_listbox_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Trunc(Args[0].n) of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_LISTBOX: Result.s := 'Invalid listbox';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Create failed';
    ERR_INDEX_OUT_OF_RANGE: Result.s := 'Index out of range';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_listbox_clearerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
  ClearError();
end;

{ Creation and destruction }

function p_listbox_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  LB: TBasListBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'listbox#') then Exit();

  try
    LB := TBasListBox.Create(nil);
    LB.Parent := TFmxObject(Args[0].p);
    LB.Position.X := 0;
    LB.Position.Y := 0;
    LB.Width := 150;
    LB.Height := 200;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(LB, Eng, Outp) then
    begin
      LB.BasicEngine := Eng;
      LB.ConsoleOutput := Outp;
    end;

    Result.p := Pointer(LB);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(LB, LISTBOX_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'listbox#: ' + E.Message);
  end;
end;

function p_listbox_new_pos(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  LB: TBasListBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateParent(Args[0].p, 'listbox#') then Exit();

  try
    LB := TBasListBox.Create(nil);
    LB.Parent := TFmxObject(Args[0].p);
    LB.Position.X := Args[1].n;
    LB.Position.Y := Args[2].n;
    LB.Width := Args[3].n;
    LB.Height := Args[4].n;
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(LB, Eng, Outp) then
    begin
      LB.BasicEngine := Eng;
      LB.ConsoleOutput := Outp;
    end;

    Result.p := Pointer(LB);

    // Register with GC using tag
//    if Assigned(UnitGC.GC) then
//      UnitGC.GC.Add(LB, LISTBOX_GC_TAG + '_' + IntToStr(NativeInt(Result.p)));

    ClearError();
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'listbox#: ' + E.Message);
  end;
end;

function n_listbox_free(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_free') then Exit();

  try
    LB := TBasListBox(Args[0].p);
    LB.DisconnectAllEvents();
    LB.Free();

    // Free via GC using individualized tag
//    if Assigned(UnitGC.GC) then
//    begin
//      UnitGC.GC.Collect(LISTBOX_GC_TAG + '_' + IntToStr(NativeInt(Args[0].p)));
//      Result.n := 1;
//    end;

    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_LISTBOX, 'listbox_free: ' + E.Message);
  end;
end;

{ Items management }

function n_listbox_add(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
  Item: TListBoxItem;
begin
  Result.n := -1;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_add') then Exit();

  try
    LB := TBasListBox(Args[0].p);
    Item := TListBoxItem.Create(LB);
    Item.Parent := LB;
    Item.Text := Args[1].s;
    Result.n := LB.Count - 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listbox_add: ' + E.Message);
  end;
end;

function p_listbox_additem(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
  Item: TListBoxItem;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_additem#') then Exit();

  try
    LB := TBasListBox(Args[0].p);
    Item := TListBoxItem.Create(LB);
    Item.Parent := LB;
    Item.Text := Args[1].s;
    Result.p := Pointer(Item);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listbox_additem#: ' + E.Message);
  end;
end;

function n_listbox_insert(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
  Item: TListBoxItem;
  Idx: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_insert') then Exit();

  try
    LB := TBasListBox(Args[0].p);
    Idx := Trunc(Args[1].n);
    if (Idx < 0) or (Idx > LB.Count) then
    begin
      SetError(ERR_INDEX_OUT_OF_RANGE, 'listbox_insert: Index out of range');
      Exit();
    end;
    Item := TListBoxItem.Create(LB);
    Item.Text := Args[2].s;
    LB.InsertObject(Idx, Item);
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listbox_insert: ' + E.Message);
  end;
end;

function n_listbox_delete(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
  Idx: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_delete') then Exit();

  try
    LB := TBasListBox(Args[0].p);
    Idx := Trunc(Args[1].n);
    if (Idx < 0) or (Idx >= LB.Count) then
    begin
      SetError(ERR_INDEX_OUT_OF_RANGE, 'listbox_delete: Index out of range');
      Exit();
    end;
    LB.ListItems[Idx].Free;
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listbox_delete: ' + E.Message);
  end;
end;

function n_listbox_clear(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_clear') then Exit();

  try
    LB := TBasListBox(Args[0].p);
    LB.Clear;
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listbox_clear: ' + E.Message);
  end;
end;

function n_listbox_count(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_count') then Exit();

  try
    Result.n := TBasListBox(Args[0].p).Count;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_LISTBOX, 'listbox_count: ' + E.Message);
  end;
end;

{ Item access }

function s_listbox_item_get(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
  Idx: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_item$') then Exit();

  try
    LB := TBasListBox(Args[0].p);
    Idx := Trunc(Args[1].n);
    if (Idx < 0) or (Idx >= LB.Count) then
    begin
      SetError(ERR_INDEX_OUT_OF_RANGE, 'listbox_item$: Index out of range');
      Exit();
    end;
    Result.s := LB.ListItems[Idx].Text;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listbox_item$: ' + E.Message);
  end;
end;

function p_listbox_item_set(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
  Idx: Integer;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_item#') then Exit();

  try
    LB := TBasListBox(Args[0].p);
    Idx := Trunc(Args[1].n);
    if (Idx < 0) or (Idx >= LB.Count) then
    begin
      SetError(ERR_INDEX_OUT_OF_RANGE, 'listbox_item#: Index out of range');
      Exit();
    end;
    LB.ListItems[Idx].Text := Args[2].s;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listbox_item#: ' + E.Message);
  end;
end;

function p_listbox_itemat(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
  Idx: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_itemat#') then Exit();

  try
    LB := TBasListBox(Args[0].p);
    Idx := Trunc(Args[1].n);
    if (Idx < 0) or (Idx >= LB.Count) then
    begin
      SetError(ERR_INDEX_OUT_OF_RANGE, 'listbox_itemat#: Index out of range');
      Exit();
    end;
    Result.p := Pointer(LB.ListItems[Idx]);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listbox_itemat#: ' + E.Message);
  end;
end;

{ ItemIndex }

function n_listbox_itemindex_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := -1;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_itemindex') then Exit();

  try
    Result.n := TBasListBox(Args[0].p).ItemIndex;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_LISTBOX, 'listbox_itemindex: ' + E.Message);
  end;
end;

function p_listbox_itemindex_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_itemindex#') then Exit();

  try
    TBasListBox(Args[0].p).ItemIndex := Trunc(Args[1].n);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listbox_itemindex#: ' + E.Message);
  end;
end;

{ Selected text (convenience function) }

function s_listbox_selected(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_selected$') then Exit();

  try
    LB := TBasListBox(Args[0].p);
    if (LB.ItemIndex >= 0) and (LB.ItemIndex < LB.Count) then
      Result.s := LB.ListItems[LB.ItemIndex].Text;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_LISTBOX, 'listbox_selected$: ' + E.Message);
  end;
end;

{ Find item by text }

function n_listbox_indexof(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
  i: Integer;
  SearchText: String;
begin
  Result.n := -1;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_indexof') then Exit();

  try
    LB := TBasListBox(Args[0].p);
    SearchText := Args[1].s;
    for i := 0 to LB.Count - 1 do
    begin
      if LB.ListItems[i].Text = SearchText then
      begin
        Result.n := i;
        Break;
      end;
    end;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listbox_indexof: ' + E.Message);
  end;
end;

{ Multi-select support }

function n_listbox_multiselect_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_multiselect') then Exit();

  if TBasListBox(Args[0].p).MultiSelectStyle <> TMultiSelectStyle.None then
    Result.n := 1;
  ClearError();
end;

function p_listbox_multiselect_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_multiselect#') then Exit();

  if Args[1].n <> 0 then
    TBasListBox(Args[0].p).MultiSelectStyle := TMultiSelectStyle.Default
  else
    TBasListBox(Args[0].p).MultiSelectStyle := TMultiSelectStyle.None;
  ClearError();
end;

function n_listbox_isselected(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
  Idx: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_isselected') then Exit();

  LB := TBasListBox(Args[0].p);
  Idx := Trunc(Args[1].n);
  if (Idx >= 0) and (Idx < LB.Count) then
    if LB.ListItems[Idx].IsSelected then
      Result.n := 1;
  ClearError();
end;

function p_listbox_selectitem(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
  Idx: Integer;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_selectitem#') then Exit();

  LB := TBasListBox(Args[0].p);
  Idx := Trunc(Args[1].n);
  if (Idx >= 0) and (Idx < LB.Count) then
    LB.ListItems[Idx].IsSelected := (Args[2].n <> 0);
  ClearError();
end;

function n_listbox_selectall(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_selectall') then Exit();

  TBasListBox(Args[0].p).SelectAll;
  ClearError();
end;

function n_listbox_clearselection(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_clearselection') then Exit();

  TBasListBox(Args[0].p).ClearSelection;
  ClearError();
end;

function n_listbox_selcount(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
  i, cnt: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_selcount') then Exit();

  LB := TBasListBox(Args[0].p);
  cnt := 0;
  for i := 0 to LB.Count - 1 do
    if LB.ListItems[i].IsSelected then
      Inc(cnt);
  Result.n := cnt;
  ClearError();
end;

{ Position and Size }

function n_listbox_x_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_x') then Exit();

  Result.n := TBasListBox(Args[0].p).Position.X;
  ClearError();
end;

function p_listbox_x_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_x#') then Exit();

  TBasListBox(Args[0].p).Position.X := Args[1].n;
  ClearError();
end;

function n_listbox_y_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_y') then Exit();

  Result.n := TBasListBox(Args[0].p).Position.Y;
  ClearError();
end;

function p_listbox_y_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_y#') then Exit();

  TBasListBox(Args[0].p).Position.Y := Args[1].n;
  ClearError();
end;

function n_listbox_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_width') then Exit();

  Result.n := TBasListBox(Args[0].p).Width;
  ClearError();
end;

function p_listbox_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_width#') then Exit();

  TBasListBox(Args[0].p).Width := Args[1].n;
  ClearError();
end;

function n_listbox_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_height') then Exit();

  Result.n := TBasListBox(Args[0].p).Height;
  ClearError();
end;

function p_listbox_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_height#') then Exit();

  TBasListBox(Args[0].p).Height := Args[1].n;
  ClearError();
end;

function p_listbox_bounds_set(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_bounds#') then Exit();

  LB := TBasListBox(Args[0].p);
  LB.Position.X := Args[1].n;
  LB.Position.Y := Args[2].n;
  LB.Width := Args[3].n;
  LB.Height := Args[4].n;
  ClearError();
end;

function p_listbox_move_set(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_move#') then Exit();

  LB := TBasListBox(Args[0].p);
  LB.Position.X := Args[1].n;
  LB.Position.Y := Args[2].n;
  ClearError();
end;

function p_listbox_size_set(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_size#') then Exit();

  LB := TBasListBox(Args[0].p);
  LB.Width := Args[1].n;
  LB.Height := Args[2].n;
  ClearError();
end;

{ Margins }

function n_listbox_marginleft_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_marginleft') then Exit();

  Result.n := TBasListBox(Args[0].p).Margins.Left;
  ClearError();
end;

function p_listbox_marginleft_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_marginleft#') then Exit();

  TBasListBox(Args[0].p).Margins.Left := Args[1].n;
  ClearError();
end;

function n_listbox_margintop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_margintop') then Exit();

  Result.n := TBasListBox(Args[0].p).Margins.Top;
  ClearError();
end;

function p_listbox_margintop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_margintop#') then Exit();

  TBasListBox(Args[0].p).Margins.Top := Args[1].n;
  ClearError();
end;

function n_listbox_marginright_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_marginright') then Exit();

  Result.n := TBasListBox(Args[0].p).Margins.Right;
  ClearError();
end;

function p_listbox_marginright_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_marginright#') then Exit();

  TBasListBox(Args[0].p).Margins.Right := Args[1].n;
  ClearError();
end;

function n_listbox_marginbottom_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_marginbottom') then Exit();

  Result.n := TBasListBox(Args[0].p).Margins.Bottom;
  ClearError();
end;

function p_listbox_marginbottom_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_marginbottom#') then Exit();

  TBasListBox(Args[0].p).Margins.Bottom := Args[1].n;
  ClearError();
end;

function p_listbox_margins_set(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_margins#') then Exit();

  LB := TBasListBox(Args[0].p);
  LB.Margins.Left := Args[1].n;
  LB.Margins.Top := Args[2].n;
  LB.Margins.Right := Args[3].n;
  LB.Margins.Bottom := Args[4].n;
  ClearError();
end;

function p_listbox_margin_set(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_margin#') then Exit();

  LB := TBasListBox(Args[0].p);
  LB.Margins.Left := Args[1].n;
  LB.Margins.Top := Args[1].n;
  LB.Margins.Right := Args[1].n;
  LB.Margins.Bottom := Args[1].n;
  ClearError();
end;

{ Alignment }

function n_listbox_align_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_align') then Exit();

  Result.n := AlignToInt(TBasListBox(Args[0].p).Align);
  ClearError();
end;

function p_listbox_align_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_align#') then Exit();

  TBasListBox(Args[0].p).Align := AlignFromInt(Trunc(Args[1].n));
  ClearError();
end;

{ Visibility and state }

function n_listbox_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_visible') then Exit();

  if TBasListBox(Args[0].p).Visible then
    Result.n := 1;
  ClearError();
end;

function p_listbox_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_visible#') then Exit();

  TBasListBox(Args[0].p).Visible := (Args[1].n <> 0);
  ClearError();
end;

function n_listbox_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_enabled') then Exit();

  if TBasListBox(Args[0].p).Enabled then
    Result.n := 1;
  ClearError();
end;

function p_listbox_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_enabled#') then Exit();

  TBasListBox(Args[0].p).Enabled := (Args[1].n <> 0);
  ClearError();
end;

function n_listbox_opacity_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_opacity') then Exit();

  Result.n := TBasListBox(Args[0].p).Opacity;
  ClearError();
end;

function p_listbox_opacity_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_opacity#') then Exit();

  TBasListBox(Args[0].p).Opacity := Args[1].n;
  ClearError();
end;

{ Focus }

function n_listbox_focus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_focus') then Exit();

  TBasListBox(Args[0].p).SetFocus;
  ClearError();
end;

function n_listbox_isfocused(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_isfocused') then Exit();

  if TBasListBox(Args[0].p).IsFocused then
    Result.n := 1;
  ClearError();
end;

{ Tab order }

function n_listbox_taborder_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_taborder') then Exit();

  Result.n := TBasListBox(Args[0].p).TabOrder;
  ClearError();
end;

function p_listbox_taborder_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_taborder#') then Exit();

  TBasListBox(Args[0].p).TabOrder := Trunc(Args[1].n);
  ClearError();
end;

function n_listbox_canfocus_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_canfocus') then Exit();

  if TBasListBox(Args[0].p).CanFocus then
    Result.n := 1;
  ClearError();
end;

function p_listbox_canfocus_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_canfocus#') then Exit();

  TBasListBox(Args[0].p).CanFocus := (Args[1].n <> 0);
  ClearError();
end;

{ Tag }

function n_listbox_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_tag') then Exit();

  Result.n := TBasListBox(Args[0].p).Tag;
  ClearError();
end;

function p_listbox_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_tag#') then Exit();

  TBasListBox(Args[0].p).Tag := Trunc(Args[1].n);
  ClearError();
end;

{ HitTest and DragMode }

function n_listbox_hittest_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_hittest') then Exit();

  if TBasListBox(Args[0].p).HitTest then
    Result.n := 1;
  ClearError();
end;

function p_listbox_hittest_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_hittest#') then Exit();

  TBasListBox(Args[0].p).HitTest := (Args[1].n <> 0);
  ClearError();
end;

function n_listbox_dragmode_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_dragmode') then Exit();

  if TBasListBox(Args[0].p).DragMode = TDragMode.dmAutomatic then
    Result.n := 1;
  ClearError();
end;

function p_listbox_dragmode_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_dragmode#') then Exit();

  if Args[1].n <> 0 then
    TBasListBox(Args[0].p).DragMode := TDragMode.dmAutomatic
  else
    TBasListBox(Args[0].p).DragMode := TDragMode.dmManual;
  ClearError();
end;

{ Parent }

function p_listbox_parent_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_parent#') then Exit();

  Result.p := Pointer(TBasListBox(Args[0].p).Parent);
  ClearError();
end;

function p_listbox_parent_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_parent#') then Exit();

  if Args[1].p = nil then
    TBasListBox(Args[0].p).Parent := nil
  else
    TBasListBox(Args[0].p).Parent := TFmxObject(Args[1].p);
  ClearError();
end;

{ Event callbacks - getters }

function s_listbox_onchange_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onchange$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnChangeFunc;
  ClearError();
end;

function s_listbox_onitemclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onitemclick$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnItemClickFunc;
  ClearError();
end;

function s_listbox_onclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onclick$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnClickFunc;
  ClearError();
end;

function s_listbox_ondblclick_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_ondblclick$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnDblClickFunc;
  ClearError();
end;

function s_listbox_onenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onenter$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnEnterFunc;
  ClearError();
end;

function s_listbox_onexit_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onexit$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnExitFunc;
  ClearError();
end;

function s_listbox_onkeydown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onkeydown$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnKeyDownFunc;
  ClearError();
end;

function s_listbox_onkeyup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onkeyup$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnKeyUpFunc;
  ClearError();
end;

function s_listbox_onmousedown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onmousedown$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnMouseDownFunc;
  ClearError();
end;

function s_listbox_onmouseup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onmouseup$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnMouseUpFunc;
  ClearError();
end;

function s_listbox_onmousemove_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onmousemove$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnMouseMoveFunc;
  ClearError();
end;

function s_listbox_onmouseenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onmouseenter$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnMouseEnterFunc;
  ClearError();
end;

function s_listbox_onmouseleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onmouseleave$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnMouseLeaveFunc;
  ClearError();
end;

function s_listbox_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onresize$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnResizeFunc;
  ClearError();
end;

function s_listbox_ondragenter_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_ondragenter$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnDragEnterFunc;
  ClearError();
end;

function s_listbox_ondragover_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_ondragover$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnDragOverFunc;
  ClearError();
end;

function s_listbox_ondragdrop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_ondragdrop$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnDragDropFunc;
  ClearError();
end;

function s_listbox_ondragleave_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_ondragleave$') then Exit();

  Result.s := TBasListBox(Args[0].p).OnDragLeaveFunc;
  ClearError();
end;

{ Event callbacks - setters }

function p_listbox_onchange_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onchange#') then Exit();

  TBasListBox(Args[0].p).OnChangeFunc := Args[1].s;
  ClearError();
end;

function p_listbox_onitemclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onitemclick#') then Exit();

  TBasListBox(Args[0].p).OnItemClickFunc := Args[1].s;
  ClearError();
end;

function p_listbox_onclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onclick#') then Exit();

  TBasListBox(Args[0].p).OnClickFunc := Args[1].s;
  ClearError();
end;

function p_listbox_ondblclick_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_ondblclick#') then Exit();

  TBasListBox(Args[0].p).OnDblClickFunc := Args[1].s;
  ClearError();
end;

function p_listbox_onenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onenter#') then Exit();

  TBasListBox(Args[0].p).OnEnterFunc := Args[1].s;
  ClearError();
end;

function p_listbox_onexit_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onexit#') then Exit();

  TBasListBox(Args[0].p).OnExitFunc := Args[1].s;
  ClearError();
end;

function p_listbox_onkeydown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onkeydown#') then Exit();

  TBasListBox(Args[0].p).OnKeyDownFunc := Args[1].s;
  ClearError();
end;

function p_listbox_onkeyup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onkeyup#') then Exit();

  TBasListBox(Args[0].p).OnKeyUpFunc := Args[1].s;
  ClearError();
end;

function p_listbox_onmousedown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onmousedown#') then Exit();

  TBasListBox(Args[0].p).OnMouseDownFunc := Args[1].s;
  ClearError();
end;

function p_listbox_onmouseup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onmouseup#') then Exit();

  TBasListBox(Args[0].p).OnMouseUpFunc := Args[1].s;
  ClearError();
end;

function p_listbox_onmousemove_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onmousemove#') then Exit();

  TBasListBox(Args[0].p).OnMouseMoveFunc := Args[1].s;
  ClearError();
end;

function p_listbox_onmouseenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onmouseenter#') then Exit();

  TBasListBox(Args[0].p).OnMouseEnterFunc := Args[1].s;
  ClearError();
end;

function p_listbox_onmouseleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onmouseleave#') then Exit();

  TBasListBox(Args[0].p).OnMouseLeaveFunc := Args[1].s;
  ClearError();
end;

function p_listbox_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_onresize#') then Exit();

  TBasListBox(Args[0].p).OnResizeFunc := Args[1].s;
  ClearError();
end;

function p_listbox_ondragenter_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_ondragenter#') then Exit();

  TBasListBox(Args[0].p).OnDragEnterFunc := Args[1].s;
  ClearError();
end;

function p_listbox_ondragover_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_ondragover#') then Exit();

  TBasListBox(Args[0].p).OnDragOverFunc := Args[1].s;
  ClearError();
end;

function p_listbox_ondragdrop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_ondragdrop#') then Exit();

  TBasListBox(Args[0].p).OnDragDropFunc := Args[1].s;
  ClearError();
end;

function p_listbox_ondragleave_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_ondragleave#') then Exit();

  TBasListBox(Args[0].p).OnDragLeaveFunc := Args[1].s;
  ClearError();
end;

{ Clear all callbacks }

function p_listbox_clearcallbacks(var Args: array of TAsmData): TAsmData;
var
  LB: TBasListBox;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateListBox(Args[0].p, 'listbox_clearcallbacks') then Exit();

  LB := TBasListBox(Args[0].p);
  LB.OnChangeFunc := '';
  LB.OnItemClickFunc := '';
  LB.OnClickFunc := '';
  LB.OnDblClickFunc := '';
  LB.OnEnterFunc := '';
  LB.OnExitFunc := '';
  LB.OnKeyDownFunc := '';
  LB.OnKeyUpFunc := '';
  LB.OnMouseDownFunc := '';
  LB.OnMouseUpFunc := '';
  LB.OnMouseMoveFunc := '';
  LB.OnMouseEnterFunc := '';
  LB.OnMouseLeaveFunc := '';
  LB.OnResizeFunc := '';
  LB.OnDragEnterFunc := '';
  LB.OnDragOverFunc := '';
  LB.OnDragDropFunc := '';
  LB.OnDragLeaveFunc := '';
  ClearError();
end;

{ ListBoxItem helper functions }

function s_listboxitem_text_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Args[0].p = nil then
  begin
    SetError(ERR_INVALID_VALUE, 'listboxitem_text$: Nil pointer');
    Exit();
  end;

  try
    Result.s := TListBoxItem(Args[0].p).Text;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listboxitem_text$: ' + E.Message);
  end;
end;

function p_listboxitem_text_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if Args[0].p = nil then
  begin
    SetError(ERR_INVALID_VALUE, 'listboxitem_text#: Nil pointer');
    Exit();
  end;

  try
    TListBoxItem(Args[0].p).Text := Args[1].s;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listboxitem_text#: ' + E.Message);
  end;
end;

function n_listboxitem_index(var Args: array of TAsmData): TAsmData;
begin
  Result.n := -1;
  Result.p := nil;
  Result.s := '';

  if Args[0].p = nil then
  begin
    SetError(ERR_INVALID_VALUE, 'listboxitem_index: Nil pointer');
    Exit();
  end;

  try
    Result.n := TListBoxItem(Args[0].p).Index;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listboxitem_index: ' + E.Message);
  end;
end;

function n_listboxitem_isselected_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Args[0].p = nil then
  begin
    SetError(ERR_INVALID_VALUE, 'listboxitem_isselected: Nil pointer');
    Exit();
  end;

  try
    if TListBoxItem(Args[0].p).IsSelected then
      Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listboxitem_isselected: ' + E.Message);
  end;
end;

function p_listboxitem_isselected_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if Args[0].p = nil then
  begin
    SetError(ERR_INVALID_VALUE, 'listboxitem_isselected#: Nil pointer');
    Exit();
  end;

  try
    TListBoxItem(Args[0].p).IsSelected := (Args[1].n <> 0);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'listboxitem_isselected#: ' + E.Message);
  end;
end;

{ ============================================================================
  FONT / TEXT STYLING — applied to all current TListBoxItem children.
  TListBox itself is a TStyledControl without TextSettings; each TListBoxItem
  is a TTextControl and does have TextSettings, matching the ButtonLib pattern.
  Getters read from the first item (returns default if list is empty).
  ============================================================================ }

{ fontcolor }

function s_listbox_fontcolor_get(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_fontcolor$') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    if LB.Count > 0 then
      Result.s := TUtils.AlphaColorToStr(LB.ListItems[0].TextSettings.FontColor);
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_fontcolor$: ' + E.Message); end;
end;

function p_listbox_fontcolor_set(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox; i: Integer; Item: TListBoxItem;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_fontcolor#') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    for i := 0 to LB.Count - 1 do
    begin
      Item := LB.ListItems[i];
      Item.StyledSettings := Item.StyledSettings - [TStyledSetting.FontColor];
      Item.TextSettings.FontColor := TUtils.ColorToAlphaColor(Args[1].s);
    end;
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_fontcolor#: ' + E.Message); end;
end;

{ fontsize }

function n_listbox_fontsize_get(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_fontsize') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    if LB.Count > 0 then
      Result.n := LB.ListItems[0].TextSettings.Font.Size;
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_fontsize: ' + E.Message); end;
end;

function p_listbox_fontsize_set(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox; i: Integer; Item: TListBoxItem;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_fontsize#') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    for i := 0 to LB.Count - 1 do
    begin
      Item := LB.ListItems[i];
      Item.StyledSettings := Item.StyledSettings - [TStyledSetting.Size];
      Item.TextSettings.Font.Size := Args[1].n;
    end;
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_fontsize#: ' + E.Message); end;
end;

{ fontfamily }

function s_listbox_fontfamily_get(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_fontfamily$') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    if LB.Count > 0 then
      Result.s := LB.ListItems[0].TextSettings.Font.Family;
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_fontfamily$: ' + E.Message); end;
end;

function p_listbox_fontfamily_set(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox; i: Integer; Item: TListBoxItem;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_fontfamily#') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    for i := 0 to LB.Count - 1 do
    begin
      Item := LB.ListItems[i];
      Item.StyledSettings := Item.StyledSettings - [TStyledSetting.Family];
      Item.TextSettings.Font.Family := Args[1].s;
    end;
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_fontfamily#: ' + E.Message); end;
end;

{ bold }

function n_listbox_bold_get(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_bold') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    if (LB.Count > 0) and (TFontStyle.fsBold in LB.ListItems[0].TextSettings.Font.Style) then
      Result.n := 1;
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_bold: ' + E.Message); end;
end;

function p_listbox_bold_set(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox; i: Integer; Item: TListBoxItem;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_bold#') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    for i := 0 to LB.Count - 1 do
    begin
      Item := LB.ListItems[i];
      Item.StyledSettings := Item.StyledSettings - [TStyledSetting.Style];
      if Args[1].n <> 0 then
        Item.TextSettings.Font.Style := Item.TextSettings.Font.Style + [TFontStyle.fsBold]
      else
        Item.TextSettings.Font.Style := Item.TextSettings.Font.Style - [TFontStyle.fsBold];
    end;
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_bold#: ' + E.Message); end;
end;

{ italic }

function n_listbox_italic_get(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_italic') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    if (LB.Count > 0) and (TFontStyle.fsItalic in LB.ListItems[0].TextSettings.Font.Style) then
      Result.n := 1;
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_italic: ' + E.Message); end;
end;

function p_listbox_italic_set(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox; i: Integer; Item: TListBoxItem;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_italic#') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    for i := 0 to LB.Count - 1 do
    begin
      Item := LB.ListItems[i];
      Item.StyledSettings := Item.StyledSettings - [TStyledSetting.Style];
      if Args[1].n <> 0 then
        Item.TextSettings.Font.Style := Item.TextSettings.Font.Style + [TFontStyle.fsItalic]
      else
        Item.TextSettings.Font.Style := Item.TextSettings.Font.Style - [TFontStyle.fsItalic];
    end;
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_italic#: ' + E.Message); end;
end;

{ underline }

function n_listbox_underline_get(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_underline') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    if (LB.Count > 0) and (TFontStyle.fsUnderline in LB.ListItems[0].TextSettings.Font.Style) then
      Result.n := 1;
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_underline: ' + E.Message); end;
end;

function p_listbox_underline_set(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox; i: Integer; Item: TListBoxItem;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_underline#') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    for i := 0 to LB.Count - 1 do
    begin
      Item := LB.ListItems[i];
      Item.StyledSettings := Item.StyledSettings - [TStyledSetting.Style];
      if Args[1].n <> 0 then
        Item.TextSettings.Font.Style := Item.TextSettings.Font.Style + [TFontStyle.fsUnderline]
      else
        Item.TextSettings.Font.Style := Item.TextSettings.Font.Style - [TFontStyle.fsUnderline];
    end;
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_underline#: ' + E.Message); end;
end;

{ strikeout }

function n_listbox_strikeout_get(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox;
begin
  Result.n := 0; Result.p := nil; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_strikeout') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    if (LB.Count > 0) and (TFontStyle.fsStrikeOut in LB.ListItems[0].TextSettings.Font.Style) then
      Result.n := 1;
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_strikeout: ' + E.Message); end;
end;

function p_listbox_strikeout_set(var Args: array of TAsmData): TAsmData;
var LB: TBasListBox; i: Integer; Item: TListBoxItem;
begin
  Result.n := 0; Result.p := Args[0].p; Result.s := '';
  if not ValidateListBox(Args[0].p, 'listbox_strikeout#') then Exit();
  try
    LB := TBasListBox(Args[0].p);
    for i := 0 to LB.Count - 1 do
    begin
      Item := LB.ListItems[i];
      Item.StyledSettings := Item.StyledSettings - [TStyledSetting.Style];
      if Args[1].n <> 0 then
        Item.TextSettings.Font.Style := Item.TextSettings.Font.Style + [TFontStyle.fsStrikeOut]
      else
        Item.TextSettings.Font.Style := Item.TextSettings.Font.Style - [TFontStyle.fsStrikeOut];
    end;
    ClearError();
  except on E: Exception do SetError(ERR_INVALID_VALUE, 'listbox_strikeout#: ' + E.Message); end;
end;

{ ============================================================================
  FUNCTION REGISTRATION
  ============================================================================ }

procedure RegisterListBoxFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;
  Fn.FarCall := True;

  // Error functions
  Fn.Entry := @n_listbox_error; Lib.Add('listbox_error@', Fn);
  Fn.Entry := @s_listbox_errormsg; Lib.Add('listbox_errormsg$@', Fn);
  Fn.Entry := @s_listbox_strerror; Lib.Add('listbox_strerror$@n', Fn);
  Fn.Entry := @n_listbox_clearerror; Lib.Add('listbox_clearerror@', Fn);

  // Creation and destruction
  Fn.Entry := @p_listbox_new; Lib.Add('listbox#@#', Fn);
  Fn.Entry := @p_listbox_new_pos; Lib.Add('listbox#@#nnnn', Fn);
  Fn.Entry := @n_listbox_free; Lib.Add('listbox_free@#', Fn);

  // Items management
  Fn.Entry := @n_listbox_add; Lib.Add('listbox_add@#$', Fn);
  Fn.Entry := @p_listbox_additem; Lib.Add('listbox_additem#@#$', Fn);
  Fn.Entry := @n_listbox_insert; Lib.Add('listbox_insert@#n$', Fn);
  Fn.Entry := @n_listbox_delete; Lib.Add('listbox_delete@#n', Fn);
  Fn.Entry := @n_listbox_clear; Lib.Add('listbox_clear@#', Fn);
  Fn.Entry := @n_listbox_count; Lib.Add('listbox_count@#', Fn);

  // Item access
  Fn.Entry := @s_listbox_item_get; Lib.Add('listbox_item$@#n', Fn);
  Fn.Entry := @p_listbox_item_set; Lib.Add('listbox_item#@#n$', Fn);
  Fn.Entry := @p_listbox_itemat; Lib.Add('listbox_itemat#@#n', Fn);

  // ItemIndex
  Fn.Entry := @n_listbox_itemindex_get; Lib.Add('listbox_itemindex@#', Fn);
  Fn.Entry := @p_listbox_itemindex_set; Lib.Add('listbox_itemindex#@#n', Fn);
  Fn.Entry := @s_listbox_selected; Lib.Add('listbox_selected$@#', Fn);
  Fn.Entry := @n_listbox_indexof; Lib.Add('listbox_indexof@#$', Fn);

  // Multi-select support
  Fn.Entry := @n_listbox_multiselect_get; Lib.Add('listbox_multiselect@#', Fn);
  Fn.Entry := @p_listbox_multiselect_set; Lib.Add('listbox_multiselect#@#n', Fn);
  Fn.Entry := @n_listbox_isselected; Lib.Add('listbox_isselected@#n', Fn);
  Fn.Entry := @p_listbox_selectitem; Lib.Add('listbox_selectitem#@#nn', Fn);
  Fn.Entry := @n_listbox_selectall; Lib.Add('listbox_selectall@#', Fn);
  Fn.Entry := @n_listbox_clearselection; Lib.Add('listbox_clearselection@#', Fn);
  Fn.Entry := @n_listbox_selcount; Lib.Add('listbox_selcount@#', Fn);

  // Position and Size
  Fn.Entry := @n_listbox_x_get; Lib.Add('listbox_x@#', Fn);
  Fn.Entry := @p_listbox_x_set; Lib.Add('listbox_x#@#n', Fn);
  Fn.Entry := @n_listbox_y_get; Lib.Add('listbox_y@#', Fn);
  Fn.Entry := @p_listbox_y_set; Lib.Add('listbox_y#@#n', Fn);
  Fn.Entry := @n_listbox_width_get; Lib.Add('listbox_width@#', Fn);
  Fn.Entry := @p_listbox_width_set; Lib.Add('listbox_width#@#n', Fn);
  Fn.Entry := @n_listbox_height_get; Lib.Add('listbox_height@#', Fn);
  Fn.Entry := @p_listbox_height_set; Lib.Add('listbox_height#@#n', Fn);
  Fn.Entry := @p_listbox_bounds_set; Lib.Add('listbox_bounds#@#nnnn', Fn);
  Fn.Entry := @p_listbox_move_set; Lib.Add('listbox_move#@#nn', Fn);
  Fn.Entry := @p_listbox_size_set; Lib.Add('listbox_size#@#nn', Fn);

  // Margins
  Fn.Entry := @n_listbox_marginleft_get; Lib.Add('listbox_marginleft@#', Fn);
  Fn.Entry := @p_listbox_marginleft_set; Lib.Add('listbox_marginleft#@#n', Fn);
  Fn.Entry := @n_listbox_margintop_get; Lib.Add('listbox_margintop@#', Fn);
  Fn.Entry := @p_listbox_margintop_set; Lib.Add('listbox_margintop#@#n', Fn);
  Fn.Entry := @n_listbox_marginright_get; Lib.Add('listbox_marginright@#', Fn);
  Fn.Entry := @p_listbox_marginright_set; Lib.Add('listbox_marginright#@#n', Fn);
  Fn.Entry := @n_listbox_marginbottom_get; Lib.Add('listbox_marginbottom@#', Fn);
  Fn.Entry := @p_listbox_marginbottom_set; Lib.Add('listbox_marginbottom#@#n', Fn);
  Fn.Entry := @p_listbox_margins_set; Lib.Add('listbox_margins#@#nnnn', Fn);
  Fn.Entry := @p_listbox_margin_set; Lib.Add('listbox_margin#@#n', Fn);

  // Alignment
  Fn.Entry := @n_listbox_align_get; Lib.Add('listbox_align@#', Fn);
  Fn.Entry := @p_listbox_align_set; Lib.Add('listbox_align#@#n', Fn);

  // Visibility and state
  Fn.Entry := @n_listbox_visible_get; Lib.Add('listbox_visible@#', Fn);
  Fn.Entry := @p_listbox_visible_set; Lib.Add('listbox_visible#@#n', Fn);
  Fn.Entry := @n_listbox_enabled_get; Lib.Add('listbox_enabled@#', Fn);
  Fn.Entry := @p_listbox_enabled_set; Lib.Add('listbox_enabled#@#n', Fn);
  Fn.Entry := @n_listbox_opacity_get; Lib.Add('listbox_opacity@#', Fn);
  Fn.Entry := @p_listbox_opacity_set; Lib.Add('listbox_opacity#@#n', Fn);

  // Focus
  Fn.Entry := @n_listbox_focus; Lib.Add('listbox_focus@#', Fn);
  Fn.Entry := @n_listbox_isfocused; Lib.Add('listbox_isfocused@#', Fn);

  // Tab order
  Fn.Entry := @n_listbox_taborder_get; Lib.Add('listbox_taborder@#', Fn);
  Fn.Entry := @p_listbox_taborder_set; Lib.Add('listbox_taborder#@#n', Fn);
  Fn.Entry := @n_listbox_canfocus_get; Lib.Add('listbox_canfocus@#', Fn);
  Fn.Entry := @p_listbox_canfocus_set; Lib.Add('listbox_canfocus#@#n', Fn);

  // Tag
  Fn.Entry := @n_listbox_tag_get; Lib.Add('listbox_tag@#', Fn);
  Fn.Entry := @p_listbox_tag_set; Lib.Add('listbox_tag#@#n', Fn);

  // HitTest and DragMode
  Fn.Entry := @n_listbox_hittest_get; Lib.Add('listbox_hittest@#', Fn);
  Fn.Entry := @p_listbox_hittest_set; Lib.Add('listbox_hittest#@#n', Fn);
  Fn.Entry := @n_listbox_dragmode_get; Lib.Add('listbox_dragmode@#', Fn);
  Fn.Entry := @p_listbox_dragmode_set; Lib.Add('listbox_dragmode#@#n', Fn);

  // Parent
  Fn.Entry := @p_listbox_parent_get; Lib.Add('listbox_parent#@#', Fn);
  Fn.Entry := @p_listbox_parent_set; Lib.Add('listbox_parent#@##', Fn);

  // Event callbacks - getters
  Fn.Entry := @s_listbox_onchange_get; Lib.Add('listbox_onchange$@#', Fn);
  Fn.Entry := @s_listbox_onitemclick_get; Lib.Add('listbox_onitemclick$@#', Fn);
  Fn.Entry := @s_listbox_onclick_get; Lib.Add('listbox_onclick$@#', Fn);
  Fn.Entry := @s_listbox_ondblclick_get; Lib.Add('listbox_ondblclick$@#', Fn);
  Fn.Entry := @s_listbox_onenter_get; Lib.Add('listbox_onenter$@#', Fn);
  Fn.Entry := @s_listbox_onexit_get; Lib.Add('listbox_onexit$@#', Fn);
  Fn.Entry := @s_listbox_onkeydown_get; Lib.Add('listbox_onkeydown$@#', Fn);
  Fn.Entry := @s_listbox_onkeyup_get; Lib.Add('listbox_onkeyup$@#', Fn);
  Fn.Entry := @s_listbox_onmousedown_get; Lib.Add('listbox_onmousedown$@#', Fn);
  Fn.Entry := @s_listbox_onmouseup_get; Lib.Add('listbox_onmouseup$@#', Fn);
  Fn.Entry := @s_listbox_onmousemove_get; Lib.Add('listbox_onmousemove$@#', Fn);
  Fn.Entry := @s_listbox_onmouseenter_get; Lib.Add('listbox_onmouseenter$@#', Fn);
  Fn.Entry := @s_listbox_onmouseleave_get; Lib.Add('listbox_onmouseleave$@#', Fn);
  Fn.Entry := @s_listbox_onresize_get; Lib.Add('listbox_onresize$@#', Fn);
  Fn.Entry := @s_listbox_ondragenter_get; Lib.Add('listbox_ondragenter$@#', Fn);
  Fn.Entry := @s_listbox_ondragover_get; Lib.Add('listbox_ondragover$@#', Fn);
  Fn.Entry := @s_listbox_ondragdrop_get; Lib.Add('listbox_ondragdrop$@#', Fn);
  Fn.Entry := @s_listbox_ondragleave_get; Lib.Add('listbox_ondragleave$@#', Fn);

  // Event callbacks - setters
  Fn.Entry := @p_listbox_onchange_set; Lib.Add('listbox_onchange#@#$', Fn);
  Fn.Entry := @p_listbox_onitemclick_set; Lib.Add('listbox_onitemclick#@#$', Fn);
  Fn.Entry := @p_listbox_onclick_set; Lib.Add('listbox_onclick#@#$', Fn);
  Fn.Entry := @p_listbox_ondblclick_set; Lib.Add('listbox_ondblclick#@#$', Fn);
  Fn.Entry := @p_listbox_onenter_set; Lib.Add('listbox_onenter#@#$', Fn);
  Fn.Entry := @p_listbox_onexit_set; Lib.Add('listbox_onexit#@#$', Fn);
  Fn.Entry := @p_listbox_onkeydown_set; Lib.Add('listbox_onkeydown#@#$', Fn);
  Fn.Entry := @p_listbox_onkeyup_set; Lib.Add('listbox_onkeyup#@#$', Fn);
  Fn.Entry := @p_listbox_onmousedown_set; Lib.Add('listbox_onmousedown#@#$', Fn);
  Fn.Entry := @p_listbox_onmouseup_set; Lib.Add('listbox_onmouseup#@#$', Fn);
  Fn.Entry := @p_listbox_onmousemove_set; Lib.Add('listbox_onmousemove#@#$', Fn);
  Fn.Entry := @p_listbox_onmouseenter_set; Lib.Add('listbox_onmouseenter#@#$', Fn);
  Fn.Entry := @p_listbox_onmouseleave_set; Lib.Add('listbox_onmouseleave#@#$', Fn);
  Fn.Entry := @p_listbox_onresize_set; Lib.Add('listbox_onresize#@#$', Fn);
  Fn.Entry := @p_listbox_ondragenter_set; Lib.Add('listbox_ondragenter#@#$', Fn);
  Fn.Entry := @p_listbox_ondragover_set; Lib.Add('listbox_ondragover#@#$', Fn);
  Fn.Entry := @p_listbox_ondragdrop_set; Lib.Add('listbox_ondragdrop#@#$', Fn);
  Fn.Entry := @p_listbox_ondragleave_set; Lib.Add('listbox_ondragleave#@#$', Fn);

  // Clear all callbacks
  Fn.Entry := @p_listbox_clearcallbacks; Lib.Add('listbox_clearcallbacks#@#', Fn);

  // ListBoxItem helper functions
  Fn.Entry := @s_listboxitem_text_get; Lib.Add('listboxitem_text$@#', Fn);
  Fn.Entry := @p_listboxitem_text_set; Lib.Add('listboxitem_text#@#$', Fn);
  Fn.Entry := @n_listboxitem_index; Lib.Add('listboxitem_index@#', Fn);
  Fn.Entry := @n_listboxitem_isselected_get; Lib.Add('listboxitem_isselected@#', Fn);
  Fn.Entry := @p_listboxitem_isselected_set; Lib.Add('listboxitem_isselected#@#n', Fn);

  // Font / text styling (applied to all current items via TextSettings)
  Fn.Entry := @s_listbox_fontcolor_get; Lib.Add('listbox_fontcolor$@#', Fn);
  Fn.Entry := @p_listbox_fontcolor_set; Lib.Add('listbox_fontcolor#@#$', Fn);
  Fn.Entry := @n_listbox_fontsize_get; Lib.Add('listbox_fontsize@#', Fn);
  Fn.Entry := @p_listbox_fontsize_set; Lib.Add('listbox_fontsize#@#n', Fn);
  Fn.Entry := @s_listbox_fontfamily_get; Lib.Add('listbox_fontfamily$@#', Fn);
  Fn.Entry := @p_listbox_fontfamily_set; Lib.Add('listbox_fontfamily#@#$', Fn);
  Fn.Entry := @n_listbox_bold_get; Lib.Add('listbox_bold@#', Fn);
  Fn.Entry := @p_listbox_bold_set; Lib.Add('listbox_bold#@#n', Fn);
  Fn.Entry := @n_listbox_italic_get; Lib.Add('listbox_italic@#', Fn);
  Fn.Entry := @p_listbox_italic_set; Lib.Add('listbox_italic#@#n', Fn);
  Fn.Entry := @n_listbox_underline_get; Lib.Add('listbox_underline@#', Fn);
  Fn.Entry := @p_listbox_underline_set; Lib.Add('listbox_underline#@#n', Fn);
  Fn.Entry := @n_listbox_strikeout_get; Lib.Add('listbox_strikeout@#', Fn);
  Fn.Entry := @p_listbox_strikeout_set; Lib.Add('listbox_strikeout#@#n', Fn);
end;

end.
