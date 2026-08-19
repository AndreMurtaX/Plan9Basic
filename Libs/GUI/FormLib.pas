unit FormLib;

{******************************************************************************
  FormLib - Form Management Library for Plan9Basic
  Version: 2.0.0

  Provides complete FireMonkey TForm wrapper functionality for creating and
  managing application windows in Plan9Basic programs.

  Function Count: 105 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  All forms are created at RUNTIME using TForm.CreateNew (no DFM resources).
  This ensures proper dynamic creation across all FireMonkey platforms.

  PLATFORM DETECTION:
  ===================
  Use PlatformInfoLib for platform detection:
  - os_name$() returns "Windows", "macOS", "Linux", "Android", or "iOS"
  - os_platform$() returns full platform string
  - os_architecture$() returns CPU architecture

  DESKTOP-ONLY FUNCTIONS:
  =======================
  The following functions have limited support on mobile (Android, iOS):
  - form_showmodal: Falls back to form_show on mobile (returns 0)
  - form_handle: Returns 0 on mobile (no native handles)

  For cross-platform modal-like behavior, use:
  - form_showex#(frm#, "OnCloseCallback") instead of form_showmodal

  FEATURES:
  =========
  - Form creation and lifecycle management
  - Comprehensive property access (position, size, style, colors, etc.)
  - Modal and non-modal display modes
  - Complete event support with BASIC callback integration

  EVENTS SUPPORT (following HttpLib/StrListLib pattern):
  ======================================================
  - OnShow: Form is about to be shown
  - OnHide: Form is about to be hidden
  - OnClose: Form is being closed (with action parameter)
  - OnCloseQuery: Query if form can close (return 0 to cancel)
  - OnActivate: Form gains focus
  - OnDeactivate: Form loses focus
  - OnResize: Form was resized
  - OnPaint: Form needs repainting
  - OnKeyDown: Key was pressed
  - OnKeyUp: Key was released
  - OnFocusChanged: Focus changed within form

  USAGE PATTERN:
  ==============
    let frm# = form#()
    form_caption#(frm#, "My Window")
    form_size#(frm#, 640, 480)
    form_position#(frm#, 4)  ' center screen
    form_onshow#(frm#, "OnFormShow")
    form_show(frm#)

  EVENT CALLBACK SIGNATURE:
  =========================
    function OnFormShow(sender#)
      println "Form is now visible!"
    end function

  Copyright (c) 2024-2026 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Forms, FMX.Graphics, FMX.Controls, FMX.Dialogs,
  FMX.Platform, FMX.Styles, FMX.StdCtrls,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, ControlCommon;

type
  // Forward declaration
  TBasForm = class;

  {****************************************************************************
    TBasForm - Extended TForm with BASIC event callback support

    Wraps a TForm and provides event bridging to Plan9Basic user functions.
    Each event stores the name of a BASIC function to call when triggered.
  ****************************************************************************}
  //IEngineHost is how a control finds the engine it belongs to: it walks up its
  //parents until something answers, and the form is what answers. Before this,
  //every library kept a ModuleEngine unit variable and copied it into each
  //object at construction, which made the engine per-process.
  //
  //TComponent implements IInterface without reference counting, so holding this
  //interface does not affect the form's lifetime.
  TBasForm = class(TForm, IEngineHost)
  private
    // Event callback function names (stored in lowercase+signature format)
    FOnShowFunc: String;
    FOnHideFunc: String;
    FOnCloseFunc: String;
    FOnCloseQueryFunc: String;
    FOnActivateFunc: String;
    FOnDeactivateFunc: String;
    FOnResizeFunc: String;
    FOnPaintFunc: String;
    FOnKeyDownFunc: String;
    FOnKeyUpFunc: String;
    FOnCreateFunc: String;
    FOnDestroyFunc: String;
    FOnConstrainedResizeFunc: String;
    FOnFocusChangedFunc: String;
    FOnVirtualKeyboardShownFunc: String;
    FOnVirtualKeyboardHiddenFunc: String;

    // Engine references for callback execution
    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;

    // Close action result from OnCloseQuery
    FAllowClose: Boolean;
    FCloseAction: TCloseAction;

    // Internal event handlers
    procedure InternalOnShow(Sender: TObject);
    procedure InternalOnHide(Sender: TObject);
    procedure InternalOnClose(Sender: TObject; var Action: TCloseAction);
    procedure InternalOnCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure InternalOnActivate(Sender: TObject);
    procedure InternalOnDeactivate(Sender: TObject);
    procedure InternalOnResize(Sender: TObject);
    procedure InternalOnPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
    procedure InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure InternalOnCreate(Sender: TObject);
    procedure InternalOnDestroy(Sender: TObject);
    procedure InternalOnFocusChanged(Sender: TObject);
    procedure InternalOnVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure InternalOnVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);

    // Callback execution helper
    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
    function ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;

    // Property setters that connect/disconnect individual events
    procedure SetOnShowFunc(const Value: String);
    procedure SetOnHideFunc(const Value: String);
    procedure SetOnCloseFunc(const Value: String);
    procedure SetOnCloseQueryFunc(const Value: String);
    procedure SetOnActivateFunc(const Value: String);
    procedure SetOnDeactivateFunc(const Value: String);
    procedure SetOnResizeFunc(const Value: String);
    procedure SetOnPaintFunc(const Value: String);
    procedure SetOnKeyDownFunc(const Value: String);
    procedure SetOnKeyUpFunc(const Value: String);
    procedure SetOnCreateFunc(const Value: String);
    procedure SetOnDestroyFunc(const Value: String);
    procedure SetOnFocusChangedFunc(const Value: String);
    procedure SetOnVirtualKeyboardShownFunc(const Value: String);
    procedure SetOnVirtualKeyboardHiddenFunc(const Value: String);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Disconnect all events (for cleanup)
    procedure DisconnectEvents();

    // Check if callback exists
    function CallbackExists(const FuncName: String): Boolean;

    // Properties for event function names
    property OnShowFunc: String read FOnShowFunc write SetOnShowFunc;
    property OnHideFunc: String read FOnHideFunc write SetOnHideFunc;
    property OnCloseFunc: String read FOnCloseFunc write SetOnCloseFunc;
    property OnCloseQueryFunc: String read FOnCloseQueryFunc write SetOnCloseQueryFunc;
    property OnActivateFunc: String read FOnActivateFunc write SetOnActivateFunc;
    property OnDeactivateFunc: String read FOnDeactivateFunc write SetOnDeactivateFunc;
    property OnResizeFunc: String read FOnResizeFunc write SetOnResizeFunc;
    property OnPaintFunc: String read FOnPaintFunc write SetOnPaintFunc;
    property OnKeyDownFunc: String read FOnKeyDownFunc write SetOnKeyDownFunc;
    property OnKeyUpFunc: String read FOnKeyUpFunc write SetOnKeyUpFunc;
    property OnCreateFunc: String read FOnCreateFunc write SetOnCreateFunc;
    property OnDestroyFunc: String read FOnDestroyFunc write SetOnDestroyFunc;
    property OnFocusChangedFunc: String read FOnFocusChangedFunc write SetOnFocusChangedFunc;
    property OnVirtualKeyboardShownFunc: String read FOnVirtualKeyboardShownFunc write SetOnVirtualKeyboardShownFunc;
    property OnVirtualKeyboardHiddenFunc: String read FOnVirtualKeyboardHiddenFunc write SetOnVirtualKeyboardHiddenFunc;

    // Engine references
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;

    //IEngineHost
    function GetEngine: TBasicEngine;
    function GetOutput: TStrings;

    // Close behavior
    property AllowClose: Boolean read FAllowClose write FAllowClose;
    property CloseActionValue: TCloseAction read FCloseAction write FCloseAction;
  end;

// Cleanup all forms — called by UnitMain before freeing the engine
procedure CleanupAllForms();
// Library registration
procedure RegisterFormFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

const
  FORM_GC_TAG = 'BASIC_FORM';

  // Error codes
  ERR_NONE = 0;
  ERR_OPERATION_FAILED = 99; //failure recorded by a formerly silent except
  ERR_INVALID_FORM = 1;
  ERR_INVALID_PROPERTY = 2;
  ERR_INVALID_VALUE = 3;
  ERR_CREATE_FAILED = 4;
  ERR_INVALID_CALLBACK = 5;

  // Form position constants (matching TFormPosition)
  POS_DESIGNED = 0;        // Use design-time position
  POS_DEFAULT = 1;         // Default position
  POS_DEFAULT_POS_ONLY = 2;// Default position only
  POS_DEFAULT_SIZE_ONLY = 3;// Default size only
  POS_SCREEN_CENTER = 4;   // Center on screen
  POS_DESKTOP_CENTER = 5;  // Center on desktop
  POS_MAIN_FORM_CENTER = 6;// Center on main form
  POS_OWNER_FORM_CENTER = 7;// Center on owner form

  // Border style constants (matching TFmxFormBorderStyle)
  BORDER_NONE = 0;
  BORDER_SINGLE = 1;
  BORDER_SIZEABLE = 2;
  BORDER_TOOL_WINDOW = 3;
  BORDER_SIZE_TOOL_WIN = 4;

  // Close action constants
  ACTION_NONE = 0;
  ACTION_HIDE = 1;
  ACTION_FREE = 2;
  ACTION_MINIMIZE = 3;

  // Window state constants
  STATE_NORMAL = 0;
  STATE_MINIMIZED = 1;
  STATE_MAXIMIZED = 2;

var
  lastError: Integer;
  lastErrorMsg: String;

  // Module-level references for event callback support
  ModuleEngine: TBasicEngine;
  ModuleOutput: TStrings;

  // ActiveForms is the SOLE owner of all form instances.
  // Same pattern as TimerLib.ActiveTimers.
  // No GC involvement — this list manages the complete lifecycle.
  ActiveForms: TList<TBasForm>;

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

function ValidateForm(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_FORM, FuncName + ': Nil form pointer');
    Exit();
  end;

  try
    if not (IsHandleOf(P, TBasForm)) then
    begin
      SetError(ERR_INVALID_FORM, FuncName + ': Invalid form object');
      Exit();
    end;

    // Verify it's in our managed list (same pattern as TimerLib)
    if Assigned(ActiveForms) and (not ActiveForms.Contains(TBasForm(P))) then
    begin
      SetError(ERR_INVALID_FORM, FuncName + ': Form not in managed list');
      Exit();
    end;
  except
    SetError(ERR_INVALID_FORM, FuncName + ': Invalid form pointer');
    Exit();
  end;

  ClearError();
  Result := True;
end;

function AlphaColorToStr(const Color: TAlphaColor): String;
begin
  Result := '#' + IntToHex(TAlphaColorRec(Color).A, 2) + IntToHex(TAlphaColorRec(Color).R, 2) + IntToHex(TAlphaColorRec(Color).G, 2) + IntToHex(TAlphaColorRec(Color).B, 2);
end;

//==============================================================================
// TBasForm Implementation
//==============================================================================

constructor TBasForm.Create(AOwner: TComponent);
begin
  // Use CreateNew for runtime form creation without DFM resources
  // This is essential for cross-platform dynamic form creation
  inherited CreateNew(AOwner);
  RegisterHandle(Self);

  // Initialize callback function names
  FOnShowFunc := '';
  FOnHideFunc := '';
  FOnCloseFunc := '';
  FOnCloseQueryFunc := '';
  FOnActivateFunc := '';
  FOnDeactivateFunc := '';
  FOnResizeFunc := '';
  FOnPaintFunc := '';
  FOnKeyDownFunc := '';
  FOnKeyUpFunc := '';
  FOnCreateFunc := '';
  FOnDestroyFunc := '';
  FOnConstrainedResizeFunc := '';
  FOnFocusChangedFunc := '';
  FOnVirtualKeyboardShownFunc := '';
  FOnVirtualKeyboardHiddenFunc := '';

  // Initialize engine references
  FBasicEngine := nil;
  FConsoleOutput := nil;

  // Default close behavior
  FAllowClose := True;
  FCloseAction := TCloseAction.caHide;
end;

destructor TBasForm.Destroy;
begin
  UnregisterHandle(Self);
  DisconnectEvents();
  inherited Destroy;
end;

procedure TBasForm.DisconnectEvents();
begin
  Self.OnShow := nil;
  Self.OnHide := nil;
  Self.OnClose := nil;
  Self.OnCloseQuery := nil;
  Self.OnActivate := nil;
  Self.OnDeactivate := nil;
  Self.OnResize := nil;
  Self.OnPaint := nil;
  Self.OnKeyDown := nil;
  Self.OnKeyUp := nil;
  Self.OnFocusChanged := nil;
  Self.OnVirtualKeyboardShown := nil;
  Self.OnVirtualKeyboardHidden := nil;
end;

function TBasForm.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

function TBasForm.GetEngine: TBasicEngine;
begin
  Result := FBasicEngine;
end;

function TBasForm.GetOutput: TStrings;
begin
  Result := FConsoleOutput;
end;

procedure TBasForm.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'Form');
end;

function TBasForm.ExecuteCallbackWithResult(const FuncSignature: String; const Args: array of TAsmData): TAsmData;
begin
  Result := ControlCommon.RunCallbackWithResult(FBasicEngine, FConsoleOutput,
                          FuncSignature, Args, 'Form');
end;

procedure TBasForm.InternalOnShow(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnShowFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnShowFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasForm.InternalOnHide(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnHideFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnHideFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasForm.InternalOnClose(Sender: TObject; var Action: TCloseAction);
var
  Args: array[0..1] of TAsmData;
  Signature: String;
  RetVal: TAsmData;
begin
  // First apply configured close action
  Action := FCloseAction;

  if FOnCloseFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  // Signature: funcname@#n (form#, action)
  Signature := LowerCase(FOnCloseFunc) + '@#n';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := Ord(Action);
  Args[1].p := nil;
  Args[1].s := '';

  RetVal := ExecuteCallbackWithResult(Signature, Args);

  // Allow callback to modify action (0=None, 1=Hide, 2=Free, 3=Minimize)
  if RetVal.n >= 0 then
    Action := TCloseAction(Trunc(RetVal.n) mod 4);
end;

procedure TBasForm.InternalOnCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
  RetVal: TAsmData;
begin
  // Default to allowing close
  CanClose := FAllowClose;

  if FOnCloseQueryFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  // Signature: funcname@# (form#) -> returns 0 to cancel, non-zero to allow
  Signature := LowerCase(FOnCloseQueryFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  RetVal := ExecuteCallbackWithResult(Signature, Args);

  // Return value: 0 = cancel close, non-zero = allow close
  CanClose := (RetVal.n <> 0);
end;

procedure TBasForm.InternalOnCreate(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnCreateFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnCreateFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasForm.InternalOnActivate(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnActivateFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnActivateFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasForm.InternalOnDeactivate(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnDeactivateFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnDeactivateFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasForm.InternalOnDestroy(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnDestroyFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnDestroyFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasForm.InternalOnResize(Sender: TObject);
var
  Args: array[0..2] of TAsmData;
  Signature: String;
begin
  if FOnResizeFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  // Signature: funcname@#nn (form#, width, height)
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

procedure TBasForm.InternalOnPaint(Sender: TObject; Canvas: TCanvas; const ARect: TRectF);
var
  Args: array[0..4] of TAsmData;
  Signature: String;
begin
  if FOnPaintFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  // Signature: funcname@#nnnn (form#, left, top, right, bottom)
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

procedure TBasForm.InternalOnKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..3] of TAsmData;
  Signature: String;
  ShiftStr: String;
begin
  if FOnKeyDownFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  // Build shift state string
  ShiftStr := '';
  if ssShift in Shift then ShiftStr := ShiftStr + 'S';
  if ssCtrl in Shift then ShiftStr := ShiftStr + 'C';
  if ssAlt in Shift then ShiftStr := ShiftStr + 'A';
  if ssCommand in Shift then ShiftStr := ShiftStr + 'M';

  // Signature: funcname@#n$$ (form#, keyCode, keyChar$, shiftState$)
  Signature := LowerCase(FOnKeyDownFunc) + '@#n$$';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := Key;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := 0;
  Args[2].p := nil;
  Args[2].s := KeyChar;

  Args[3].n := 0;
  Args[3].p := nil;
  Args[3].s := ShiftStr;

  ExecuteCallback(Signature, Args);
end;

procedure TBasForm.InternalOnKeyUp(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
var
  Args: array[0..3] of TAsmData;
  Signature: String;
  ShiftStr: String;
begin
  if FOnKeyUpFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  // Build shift state string
  ShiftStr := '';
  if ssShift in Shift then ShiftStr := ShiftStr + 'S';
  if ssCtrl in Shift then ShiftStr := ShiftStr + 'C';
  if ssAlt in Shift then ShiftStr := ShiftStr + 'A';
  if ssCommand in Shift then ShiftStr := ShiftStr + 'M';

  // Signature: funcname@#n$$ (form#, keyCode, keyChar$, shiftState$)
  Signature := LowerCase(FOnKeyUpFunc) + '@#n$$';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := Key;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := 0;
  Args[2].p := nil;
  Args[2].s := KeyChar;

  Args[3].n := 0;
  Args[3].p := nil;
  Args[3].s := ShiftStr;

  ExecuteCallback(Signature, Args);
end;

procedure TBasForm.InternalOnFocusChanged(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnFocusChangedFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnFocusChangedFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasForm.InternalOnVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
var
  Args: array[0..4] of TAsmData;
  Signature: String;
begin
  if FOnVirtualKeyboardShownFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  // Signature: funcname@#nnnn (form#, left, top, right, bottom)
  Signature := LowerCase(FOnVirtualKeyboardShownFunc) + '@#nnnn';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  Args[1].n := Bounds.Left;
  Args[1].p := nil;
  Args[1].s := '';

  Args[2].n := Bounds.Top;
  Args[2].p := nil;
  Args[2].s := '';

  Args[3].n := Bounds.Right;
  Args[3].p := nil;
  Args[3].s := '';

  Args[4].n := Bounds.Bottom;
  Args[4].p := nil;
  Args[4].s := '';

  ExecuteCallback(Signature, Args);
end;

procedure TBasForm.SetOnActivateFunc(const Value: String);
begin
  FOnActivateFunc := Value;
  if Value <> '' then
    Self.OnActivate := InternalOnActivate
  else
    Self.OnActivate := nil;
end;

procedure TBasForm.SetOnCloseFunc(const Value: String);
begin
  FOnCloseFunc := Value;
  if Value <> '' then
    Self.OnClose := InternalOnClose
  else
    Self.OnClose := nil;
end;

procedure TBasForm.SetOnCloseQueryFunc(const Value: String);
begin
  FOnCloseQueryFunc := Value;
  if Value <> '' then
    Self.OnCloseQuery := InternalOnCloseQuery
  else
    Self.OnCloseQuery := nil;
end;

procedure TBasForm.SetOnResizeFunc(const Value: String);
begin
  FOnResizeFunc := Value;
  if Value <> '' then
    Self.OnResize := InternalOnResize
  else
    Self.OnResize := nil;
end;

procedure TBasForm.SetOnCreateFunc(const Value: String);
begin
  FOnCreateFunc := Value;
  if Value <> '' then
    Self.OnCreate := InternalOnCreate
  else
    Self.OnCreate := nil;
end;

procedure TBasForm.SetOnDeactivateFunc(const Value: String);
begin
  FOnDeactivateFunc := Value;
  if Value <> '' then
    Self.OnDeactivate := InternalOnDeactivate
  else
    Self.OnDeactivate := nil;
end;

procedure TBasForm.SetOnDestroyFunc(const Value: String);
begin
  FOnDestroyFunc := Value;
  if Value <> '' then
    Self.OnDestroy := InternalOnDestroy
  else
    Self.OnDestroy := nil;
end;

procedure TBasForm.SetOnFocusChangedFunc(const Value: String);
begin
  FOnFocusChangedFunc := Value;
  if Value <> '' then
    Self.OnFocusChanged := InternalOnFocusChanged
  else
    Self.OnFocusChanged := nil;
end;

procedure TBasForm.SetOnHideFunc(const Value: String);
begin
  FOnHideFunc := Value;
  if Value <> '' then
    Self.OnHide := InternalOnHide
  else
    Self.OnHide := nil;
end;

procedure TBasForm.SetOnKeyDownFunc(const Value: String);
begin
  FOnKeyDownFunc := Value;
  if Value <> '' then
    Self.OnKeyDown := InternalOnKeyDown
  else
    Self.OnKeyDown := nil;
end;

procedure TBasForm.SetOnKeyUpFunc(const Value: String);
begin
  FOnKeyUpFunc := Value;
  if Value <> '' then
    Self.OnKeyUp := InternalOnKeyUp
  else
    Self.OnKeyUp := nil;
end;

procedure TBasForm.SetOnPaintFunc(const Value: String);
begin
  FOnPaintFunc := Value;
  if Value <> '' then
    Self.OnPaint := InternalOnPaint
  else
    Self.OnPaint := nil;
end;

procedure TBasForm.SetOnShowFunc(const Value: String);
begin
  FOnShowFunc := Value;
  if Value <> '' then
    Self.OnShow := InternalOnShow
  else
    Self.OnShow := nil;
end;

procedure TBasForm.SetOnVirtualKeyboardHiddenFunc(const Value: String);
begin
  FOnVirtualKeyboardHiddenFunc := Value;
  if Value <> '' then
    Self.OnVirtualKeyboardHidden := InternalOnVirtualKeyboardHidden
  else
    Self.OnVirtualKeyboardHidden := nil;
end;

procedure TBasForm.SetOnVirtualKeyboardShownFunc(const Value: String);
begin
  FOnVirtualKeyboardShownFunc := Value;
  if Value <> '' then
    Self.OnVirtualKeyboardShown := InternalOnVirtualKeyboardShown
  else
    Self.OnVirtualKeyboardShown := nil;
end;

procedure TBasForm.InternalOnVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
var
  Args: array[0..0] of TAsmData;
  Signature: String;
begin
  if FOnVirtualKeyboardHiddenFunc = '' then Exit();
  if not Assigned(FBasicEngine) then Exit();

  Signature := LowerCase(FOnVirtualKeyboardHiddenFunc) + '@#';

  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';

  ExecuteCallback(Signature, Args);
end;

//==============================================================================
// Library Functions - Error Handling
//==============================================================================

// form_error() - Get last error code
function n_form_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

// form_errormsg$() - Get last error message
function s_form_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

// form_strerror$(code) - Get error description
function s_form_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_FORM: Result.s := 'Invalid or nil form';
    ERR_INVALID_PROPERTY: Result.s := 'Invalid property';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Form creation failed';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback function';
  else
    Result.s := 'Unknown error: ' + IntToStr(Code);
  end;
end;

// form_clearerror() - Clear error state
function n_form_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

//==============================================================================
// Library Functions - Form Creation and Destruction
//==============================================================================

// form#() - Create a new form
function p_form_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Frm: TBasForm;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    Frm := TBasForm.Create(nil); // Cannot be Application due to the GC collector
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Frm, Eng, Outp) then
    begin
      Frm.BasicEngine := Eng;
      Frm.ConsoleOutput := Outp;
    end;

    // Set sensible defaults
    Frm.Caption := 'Plan9Basic Form';
    Frm.Width := 640;
    Frm.Height := 480;
    Frm.Position := TFormPosition.ScreenCenter;

    Result.p := Pointer(Frm);

    // Register with ActiveForms list (sole lifecycle manager)
    if Assigned(ActiveForms) then
      ActiveForms.Add(Frm);

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'form#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// form#(caption$) - Create a new form with caption
function p_form_new_caption(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Frm: TBasForm;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    Frm := TBasForm.Create(nil); // Cannot be Application due to the GC collector
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Frm, Eng, Outp) then
    begin
      Frm.BasicEngine := Eng;
      Frm.ConsoleOutput := Outp;
    end;

    Frm.Caption := Args[0].s;
    Frm.Width := 640;
    Frm.Height := 480;
    Frm.Position := TFormPosition.ScreenCenter;

    Result.p := Pointer(Frm);

    // Register with ActiveForms list (sole lifecycle manager)
    if Assigned(ActiveForms) then
      ActiveForms.Add(Frm);

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'form#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// form#(caption$, width, height) - Create with caption and size
function p_form_new_full(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Frm: TBasForm;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    Frm := TBasForm.Create(nil); // Cannot be Application due to the GC collector
    //The engine belongs to the form this control now hangs from,
    //rather than to a unit variable filled in at registration.
    if EngineOf(Frm, Eng, Outp) then
    begin
      Frm.BasicEngine := Eng;
      Frm.ConsoleOutput := Outp;
    end;

    Frm.Caption := Args[0].s;
    Frm.Width := Trunc(Args[1].n);
    Frm.Height := Trunc(Args[2].n);
    Frm.Position := TFormPosition.ScreenCenter;

    Result.p := Pointer(Frm);

    // Register with ActiveForms list (sole lifecycle manager)
    if Assigned(ActiveForms) then
      ActiveForms.Add(Frm);

    ClearError();
  except
    on E: Exception do
    begin
      SetError(ERR_CREATE_FAILED, 'form#: ' + E.Message);
      Result.p := nil;
    end;
  end;
end;

// form_free(frm#) - Free a form
function n_form_free(var Args: array of TAsmData): TAsmData;
var
  Frm: TBasForm;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_free') then Exit();

  try
    Frm := TBasForm(Args[0].p);
    Frm.DisconnectEvents();

    // Remove from ActiveForms and free
    if Assigned(ActiveForms) then
      ActiveForms.Remove(Frm);

    try
      Frm.Close;
      Frm.Free();
    except
      // Ignore errors during form destruction
    end;

    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_FORM, 'form_free: ' + E.Message);
  end;
end;

// form_close(frm#) - Close a form
function n_form_close(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_close') then Exit();

  try
    TBasForm(Args[0].p).Close;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_close: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Form Display
//==============================================================================

// form_show(frm#) - Show form non-modally
function n_form_show(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_show') then Exit();

  try
    TBasForm(Args[0].p).Show;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_show: ' + E.Message);
  end;
end;

// form_showmodal(frm#) - Show form modally, returns modal result
// DESKTOP ONLY: On mobile platforms, this function shows the form non-modally
// and returns 0 immediately. Use event-driven approach for cross-platform code.
function n_form_showmodal(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_showmodal') then Exit();

  try
    {$IF DEFINED(MSWINDOWS) OR DEFINED(MACOS) OR DEFINED(LINUX)}
    // Desktop platforms: ShowModal works normally
    Result.n := TBasForm(Args[0].p).ShowModal;
    {$ELSE}
    // Mobile platforms (Android, iOS): ShowModal is not recommended
    // Show non-modally instead and return 0
    // Developers should use event-driven approach with OnClose callback
    TBasForm(Args[0].p).Show;
    Result.n := 0;
    SetError(ERR_NONE, 'form_showmodal: On mobile platforms, form shown non-modally. Use form_onclose# for results.');
    {$ENDIF}
  except
    on E: Exception do
      SetError(ERR_INVALID_FORM, 'form_showmodal: ' + E.Message);
  end;
end;

// form_showex#(frm#, onCloseCallback$) - Show form with close callback (CROSS-PLATFORM)
// This is the recommended approach for cross-platform "modal-like" behavior.
// The callback receives: (sender#, modalResult) and is called when the form closes.
// Works identically on all platforms (Windows, macOS, Linux, Android, iOS).
function p_form_showex(var Args: array of TAsmData): TAsmData;
var
  Frm: TBasForm;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_showex#') then Exit();

  try
    Frm := TBasForm(Args[0].p);
    // Set the OnClose callback
    Frm.OnCloseFunc := Args[1].s;
    // Show the form (non-modal, works on all platforms)
    Frm.Show;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_FORM, 'form_showex#: ' + E.Message);
  end;
end;

// form_hide(frm#) - Hide form
function n_form_hide(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_hide') then Exit();

  try
    TBasForm(Args[0].p).Hide;
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_hide: ' + E.Message);
  end;
end;

// form_visible(frm#) - Get visibility state
function n_form_visible_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_visible') then Exit();

  try
    if TBasForm(Args[0].p).Visible then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_visible: ' + E.Message);
  end;
end;

// form_visible#(frm#, visible) - Set visibility state
function p_form_visible_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_visible#') then Exit();

  try
    TBasForm(Args[0].p).Visible := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_visible#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Caption Property
//==============================================================================

// form_caption$(frm#) - Get caption
function s_form_caption_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_caption$') then Exit();

  try
    Result.s := TBasForm(Args[0].p).Caption;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_caption$: ' + E.Message);
  end;
end;

// form_caption#(frm#, caption$) - Set caption
function p_form_caption_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_caption#') then Exit();

  try
    TBasForm(Args[0].p).Caption := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_caption#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Position and Size
//==============================================================================

// form_left(frm#) - Get left position
function n_form_left_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_left') then Exit();

  try
    Result.n := TBasForm(Args[0].p).Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_left: ' + E.Message);
  end;
end;

// form_left#(frm#, value) - Set left position
function p_form_left_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_left#') then Exit();

  try
    TBasForm(Args[0].p).Left := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_left#: ' + E.Message);
  end;
end;

// form_top(frm#) - Get top position
function n_form_top_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_top') then Exit();

  try
    Result.n := TBasForm(Args[0].p).Top;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_top: ' + E.Message);
  end;
end;

// form_top#(frm#, value) - Set top position
function p_form_top_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_top#') then Exit();

  try
    TBasForm(Args[0].p).Top := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_top#: ' + E.Message);
  end;
end;

// form_width(frm#) - Get width
function n_form_width_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_width') then Exit();

  try
    Result.n := TBasForm(Args[0].p).Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_width: ' + E.Message);
  end;
end;

// form_width#(frm#, value) - Set width
function p_form_width_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_width#') then Exit();

  try
    TBasForm(Args[0].p).Width := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_width#: ' + E.Message);
  end;
end;

// form_height(frm#) - Get height
function n_form_height_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_height') then Exit();

  try
    Result.n := TBasForm(Args[0].p).Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_height: ' + E.Message);
  end;
end;

// form_height#(frm#, value) - Set height
function p_form_height_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_height#') then Exit();

  try
    TBasForm(Args[0].p).Height := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_height#: ' + E.Message);
  end;
end;

// form_bounds#(frm#, left, top, width, height) - Set all bounds at once
function p_form_bounds_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_bounds#') then Exit();

  try
    TBasForm(Args[0].p).SetBounds(
      Trunc(Args[1].n),
      Trunc(Args[2].n),
      Trunc(Args[3].n),
      Trunc(Args[4].n)
    );
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_bounds#: ' + E.Message);
  end;
end;

// form_size#(frm#, width, height) - Set size
function p_form_size_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_size#') then Exit();

  try
    TBasForm(Args[0].p).Width := Trunc(Args[1].n);
    TBasForm(Args[0].p).Height := Trunc(Args[2].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_size#: ' + E.Message);
  end;
end;

// form_move#(frm#, left, top) - Move form
function p_form_move_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_move#') then Exit();

  try
    TBasForm(Args[0].p).Left := Trunc(Args[1].n);
    TBasForm(Args[0].p).Top := Trunc(Args[2].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_move#: ' + E.Message);
  end;
end;

// form_center#(frm#) - Center on screen
function p_form_center(var Args: array of TAsmData): TAsmData;
var
  Frm: TBasForm;
  ScreenService: IFMXScreenService;
  ScreenSize: TPointF;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_center#') then Exit();

  try
    Frm := TBasForm(Args[0].p);
    // Use cross-platform screen service
    if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, ScreenService) then
    begin
      ScreenSize := ScreenService.GetScreenSize;
      Frm.Left := Trunc((ScreenSize.X - Frm.Width) / 2);
      Frm.Top := Trunc((ScreenSize.Y - Frm.Height) / 2);
    end
    else
    begin
      // Fallback using Screen object
      Frm.Left := Trunc((Screen.Width - Frm.Width) / 2);
      Frm.Top := Trunc((Screen.Height - Frm.Height) / 2);
    end;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_center#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Min/Max Size Constraints
//==============================================================================

// form_minwidth(frm#) - Get minimum width
function n_form_minwidth_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_minwidth') then Exit();

  try
    Result.n := TBasForm(Args[0].p).Constraints.MinWidth;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_minwidth: ' + E.Message);
  end;
end;

// form_minwidth#(frm#, value) - Set minimum width
function p_form_minwidth_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_minwidth#') then Exit();

  try
    TBasForm(Args[0].p).Constraints.MinWidth := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_minwidth#: ' + E.Message);
  end;
end;

// form_minheight(frm#) - Get minimum height
function n_form_minheight_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_minheight') then Exit();

  try
    Result.n := TBasForm(Args[0].p).Constraints.MinHeight;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_minheight: ' + E.Message);
  end;
end;

// form_minheight#(frm#, value) - Set minimum height
function p_form_minheight_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_minheight#') then Exit();

  try
    TBasForm(Args[0].p).Constraints.MinHeight := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_minheight#: ' + E.Message);
  end;
end;

// form_maxwidth(frm#) - Get maximum width
function n_form_maxwidth_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_maxwidth') then Exit();

  try
    Result.n := TBasForm(Args[0].p).Constraints.MaxWidth;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_maxwidth: ' + E.Message);
  end;
end;

// form_maxwidth#(frm#, value) - Set maximum width
function p_form_maxwidth_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_maxwidth#') then Exit();

  try
    TBasForm(Args[0].p).Constraints.MaxWidth := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_maxwidth#: ' + E.Message);
  end;
end;

// form_maxheight(frm#) - Get maximum height
function n_form_maxheight_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_maxheight') then Exit();

  try
    Result.n := TBasForm(Args[0].p).Constraints.MaxHeight;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_maxheight: ' + E.Message);
  end;
end;

// form_maxheight#(frm#, value) - Set maximum height
function p_form_maxheight_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_maxheight#') then Exit();

  try
    TBasForm(Args[0].p).Constraints.MaxHeight := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_maxheight#: ' + E.Message);
  end;
end;

// form_constraints#(frm#, minW, minH, maxW, maxH) - Set all constraints
function p_form_constraints_set(var Args: array of TAsmData): TAsmData;
var
  Frm: TBasForm;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_constraints#') then Exit();

  try
    Frm := TBasForm(Args[0].p);
    Frm.Constraints.MinWidth := Trunc(Args[1].n);
    Frm.Constraints.MinHeight := Trunc(Args[2].n);
    Frm.Constraints.MaxWidth := Trunc(Args[3].n);
    Frm.Constraints.MaxHeight := Trunc(Args[4].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_constraints#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Form Position Mode
//==============================================================================

// form_position(frm#) - Get position mode
function n_form_position_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_position') then Exit();

  try
    Result.n := Ord(TBasForm(Args[0].p).Position);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_position: ' + E.Message);
  end;
end;

// form_position#(frm#, mode) - Set position mode
function p_form_position_set(var Args: array of TAsmData): TAsmData;
var
  Mode: Integer;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_position#') then Exit();

  try
    Mode := Trunc(Args[1].n);
    if (Mode >= 0) and (Mode <= Ord(High(TFormPosition))) then
      TBasForm(Args[0].p).Position := TFormPosition(Mode);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_position#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Window State
//==============================================================================

// form_windowstate(frm#) - Get window state
function n_form_windowstate_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_windowstate') then Exit();

  try
    Result.n := Ord(TBasForm(Args[0].p).WindowState);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_windowstate: ' + E.Message);
  end;
end;

// form_windowstate#(frm#, state) - Set window state
function p_form_windowstate_set(var Args: array of TAsmData): TAsmData;
var
  State: Integer;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_windowstate#') then Exit();

  try
    State := Trunc(Args[1].n);
    if (State >= 0) and (State <= 2) then
      TBasForm(Args[0].p).WindowState := TWindowState(State);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_windowstate#: ' + E.Message);
  end;
end;

// form_maximize#(frm#) - Maximize form
function p_form_maximize(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_maximize#') then Exit();

  try
    TBasForm(Args[0].p).WindowState := TWindowState.wsMaximized;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_maximize#: ' + E.Message);
  end;
end;

// form_minimize#(frm#) - Minimize form
function p_form_minimize(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_minimize#') then Exit();

  try
    TBasForm(Args[0].p).WindowState := TWindowState.wsMinimized;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_minimize#: ' + E.Message);
  end;
end;

// form_restore#(frm#) - Restore form to normal state
function p_form_restore(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_restore#') then Exit();

  try
    TBasForm(Args[0].p).WindowState := TWindowState.wsNormal;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_restore#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Border Style
//==============================================================================

// form_borderstyle(frm#) - Get border style
function n_form_borderstyle_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_borderstyle') then Exit();

  try
    Result.n := Ord(TBasForm(Args[0].p).BorderStyle);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_borderstyle: ' + E.Message);
  end;
end;

// form_borderstyle#(frm#, style) - Set border style
function p_form_borderstyle_set(var Args: array of TAsmData): TAsmData;
var
  Style: Integer;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_borderstyle#') then Exit();

  try
    Style := Trunc(Args[1].n);
    if (Style >= 0) and (Style <= Ord(High(TFmxFormBorderStyle))) then
      TBasForm(Args[0].p).BorderStyle := TFmxFormBorderStyle(Style);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_borderstyle#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Form Style Flags
//==============================================================================

// form_fullscreen(frm#) - Get fullscreen mode
function n_form_fullscreen_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_fullscreen') then Exit();

  try
    if TBasForm(Args[0].p).FullScreen then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_fullscreen: ' + E.Message);
  end;
end;

// form_fullscreen#(frm#, value) - Set fullscreen mode
function p_form_fullscreen_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_fullscreen#') then Exit();

  try
    TBasForm(Args[0].p).FullScreen := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_fullscreen#: ' + E.Message);
  end;
end;

// form_stayontop(frm#) - Get stay on top flag
function n_form_stayontop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_stayontop') then Exit();

  try
    // In FMX, StayOnTop is controlled via FormStyle property
    if TBasForm(Args[0].p).FormStyle = TFormStyle.StayOnTop then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_stayontop: ' + E.Message);
  end;
end;

// form_stayontop#(frm#, value) - Set stay on top flag
function p_form_stayontop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_stayontop#') then Exit();

  try
    // In FMX, StayOnTop is controlled via FormStyle property
    if Args[1].n <> 0 then
      TBasForm(Args[0].p).FormStyle := TFormStyle.StayOnTop
    else
      TBasForm(Args[0].p).FormStyle := TFormStyle.Normal;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_stayontop#: ' + E.Message);
  end;
end;

// form_showfullscreenicon(frm#) - Get show fullscreen icon
function n_form_showfullscreenicon_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_showfullscreenicon') then Exit();

  try
    if TBasForm(Args[0].p).ShowFullScreenIcon then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_showfullscreenicon: ' + E.Message);
  end;
end;

// form_showfullscreenicon#(frm#, value) - Set show fullscreen icon
function p_form_showfullscreenicon_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_showfullscreenicon#') then Exit();

  try
    TBasForm(Args[0].p).ShowFullScreenIcon := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_showfullscreenicon#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Fill/Background Color
//==============================================================================

// form_fill$(frm#) - Get fill color as string
function s_form_fill_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_fill$') then Exit();

  try
    Result.s := AlphaColorToStr(TBasForm(Args[0].p).Fill.Color);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_fill$: ' + E.Message);
  end;
end;

// form_fill#(frm#, color$) - Set fill color
function p_form_fill_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_fill#') then Exit();

  try
    TBasForm(Args[0].p).Fill.Kind := TBrushKind.Solid;
    TBasForm(Args[0].p).Fill.Color := TUtils.ColorToAlphaColor(Args[1].s);
    TBasForm(Args[0].p).Invalidate();
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_fill#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Transparency
//==============================================================================

// form_transparency(frm#) - Get transparency flag
function n_form_transparency_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_transparency') then Exit();

  try
    if TBasForm(Args[0].p).Transparency then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_transparency: ' + E.Message);
  end;
end;

// form_transparency#(frm#, value) - Set transparency
function p_form_transparency_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_transparency#') then Exit();

  try
    TBasForm(Args[0].p).Transparency := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_transparency#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Focus and Activation
//==============================================================================

// form_active(frm#) - Check if form is active
function n_form_active_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_active') then Exit();

  try
    if TBasForm(Args[0].p).Active then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_active: ' + E.Message);
  end;
end;

// form_bringtofront#(frm#) - Bring form to front
function p_form_bringtofront(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_bringtofront#') then Exit();

  try
    TBasForm(Args[0].p).BringToFront;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_bringtofront#: ' + E.Message);
  end;
end;

// form_sendtoback#(frm#) - Send form to back
function p_form_sendtoback(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_sendtoback#') then Exit();

  try
    TBasForm(Args[0].p).SendToBack;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_sendtoback#: ' + E.Message);
  end;
end;

// form_setfocus#(frm#) - Set focus to form
function p_form_setfocus(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_setfocus#') then Exit();

  try
    // In FMX, use Activate to bring form to focus
    TBasForm(Args[0].p).Activate;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_setfocus#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Close Action and Behavior
//==============================================================================

// form_closeaction(frm#) - Get close action
function n_form_closeaction_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_closeaction') then Exit();

  try
    Result.n := Ord(TBasForm(Args[0].p).CloseActionValue);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_closeaction: ' + E.Message);
  end;
end;

// form_closeaction#(frm#, action) - Set close action (0=None, 1=Hide, 2=Free, 3=Minimize)
function p_form_closeaction_set(var Args: array of TAsmData): TAsmData;
var
  Action: Integer;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_closeaction#') then Exit();

  try
    Action := Trunc(Args[1].n);
    if (Action >= 0) and (Action <= 3) then
      TBasForm(Args[0].p).CloseActionValue := TCloseAction(Action);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_closeaction#: ' + E.Message);
  end;
end;

// form_allowclose(frm#) - Get allow close flag
function n_form_allowclose_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_allowclose') then Exit();

  try
    if TBasForm(Args[0].p).AllowClose then
      Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_allowclose: ' + E.Message);
  end;
end;

// form_allowclose#(frm#, value) - Set allow close flag
function p_form_allowclose_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_allowclose#') then Exit();

  try
    TBasForm(Args[0].p).AllowClose := (Args[1].n <> 0);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_allowclose#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Modal Result
//==============================================================================

// form_modalresult(frm#) - Get modal result
function n_form_modalresult_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_modalresult') then Exit();

  try
    Result.n := TBasForm(Args[0].p).ModalResult;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_modalresult: ' + E.Message);
  end;
end;

// form_modalresult#(frm#, value) - Set modal result
function p_form_modalresult_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_modalresult#') then Exit();

  try
    TBasForm(Args[0].p).ModalResult := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_modalresult#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Client Area
//==============================================================================

// form_clientwidth(frm#) - Get client area width
function n_form_clientwidth_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_clientwidth') then Exit();

  try
    Result.n := TBasForm(Args[0].p).ClientWidth;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_clientwidth: ' + E.Message);
  end;
end;

// form_clientheight(frm#) - Get client area height
function n_form_clientheight_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_clientheight') then Exit();

  try
    Result.n := TBasForm(Args[0].p).ClientHeight;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_clientheight: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Invalidation/Repaint
//==============================================================================

// form_invalidate#(frm#) - Force repaint
function p_form_invalidate(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_invalidate#') then Exit();

  try
    TBasForm(Args[0].p).Invalidate;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_invalidate#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Form Handle (Desktop platforms only)
//==============================================================================

// form_handle(frm#) - Get native window handle (Windows only in FMX)
// Returns 0 on non-Windows platforms
function n_form_handle_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_handle') then Exit();

  // In FMX, getting native window handle is complex and platform-specific
  // For now, return 0 - this function is mainly for advanced interop scenarios
  {$IFDEF MSWINDOWS}
  try
    // On Windows, we would need FMX.Platform.Win and WindowHandleToPlatform
    // This requires the form to be visible first
    // For simplicity, returning 0 - implement if needed for specific use cases
    Result.n := 0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_handle: ' + E.Message);
  end;
  {$ENDIF}
end;

//==============================================================================
// Library Functions - Form Style
//==============================================================================

// form_formstyle(frm#) - Get form style (0=Normal, 1=Popup, 2=StayOnTop)
function n_form_formstyle_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_formstyle') then Exit();

  try
    Result.n := Ord(TBasForm(Args[0].p).FormStyle);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_formstyle: ' + E.Message);
  end;
end;

// form_formstyle#(frm#, style) - Set form style
function p_form_formstyle_set(var Args: array of TAsmData): TAsmData;
var
  Style: Integer;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_formstyle#') then Exit();

  try
    Style := Trunc(Args[1].n);
    if (Style >= 0) and (Style <= Ord(High(TFormStyle))) then
      TBasForm(Args[0].p).FormStyle := TFormStyle(Style);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_formstyle#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Screen Information (Cross-Platform)
//==============================================================================

// form_screenwidth() - Get screen width (cross-platform)
function n_form_screenwidth(var Args: array of TAsmData): TAsmData;
var
  ScreenService: IFMXScreenService;
  ScreenSize: TPointF;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, ScreenService) then
    begin
      ScreenSize := ScreenService.GetScreenSize;
      Result.n := ScreenSize.X;
    end
    else
      Result.n := Screen.Width;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'n_form_screenwidth: ' + E.Message);
  end;
end;

// form_screenheight() - Get screen height (cross-platform)
function n_form_screenheight(var Args: array of TAsmData): TAsmData;
var
  ScreenService: IFMXScreenService;
  ScreenSize: TPointF;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, ScreenService) then
    begin
      ScreenSize := ScreenService.GetScreenSize;
      Result.n := ScreenSize.Y;
    end
    else
      Result.n := Screen.Height;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'n_form_screenheight: ' + E.Message);
  end;
end;

// form_screenscale() - Get screen scale factor (for HiDPI/Retina)
function n_form_screenscale(var Args: array of TAsmData): TAsmData;
var
  ScreenService: IFMXScreenService;
begin
  Result.n := 1.0;
  Result.p := nil;
  Result.s := '';

  try
    if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, ScreenService) then
      Result.n := ScreenService.GetScreenScale
    else
      Result.n := 1.0;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'n_form_screenscale: ' + E.Message);
  end;
end;

// form_screenorientation() - Get screen orientation (mobile)
// Returns: 0=Portrait, 1=Landscape, 2=InvertedPortrait, 3=InvertedLandscape
function n_form_screenorientation(var Args: array of TAsmData): TAsmData;
var
  ScreenService: IFMXScreenService;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    if TPlatformServices.Current.SupportsPlatformService(IFMXScreenService, ScreenService) then
      Result.n := Ord(ScreenService.GetScreenOrientation);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'n_form_screenorientation: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Event Callbacks
//==============================================================================

// form_onshow#(frm#, funcName$) - Set OnShow callback
function p_form_onshow_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onshow#') then Exit();

  try
    TBasForm(Args[0].p).OnShowFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onshow#: ' + E.Message);
  end;
end;

// form_onshow$(frm#) - Get OnShow callback name
function s_form_onshow_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onshow$') then Exit();

  try
    Result.s := TBasForm(Args[0].p).OnShowFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onshow$: ' + E.Message);
  end;
end;

// form_onhide#(frm#, funcName$) - Set OnHide callback
function p_form_onhide_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onhide#') then Exit();

  try
    TBasForm(Args[0].p).OnHideFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onhide#: ' + E.Message);
  end;
end;

// form_onhide$(frm#) - Get OnHide callback name
function s_form_onhide_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onhide$') then Exit();

  try
    Result.s := TBasForm(Args[0].p).OnHideFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onhide$: ' + E.Message);
  end;
end;

// form_onclose#(frm#, funcName$) - Set OnClose callback
function p_form_onclose_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onclose#') then Exit();

  try
    TBasForm(Args[0].p).OnCloseFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onclose#: ' + E.Message);
  end;
end;

// form_onclose$(frm#) - Get OnClose callback name
function s_form_onclose_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onclose$') then Exit();

  try
    Result.s := TBasForm(Args[0].p).OnCloseFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onclose$: ' + E.Message);
  end;
end;

// form_onclosequery#(frm#, funcName$) - Set OnCloseQuery callback
function p_form_onclosequery_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onclosequery#') then Exit();

  try
    TBasForm(Args[0].p).OnCloseQueryFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onclosequery#: ' + E.Message);
  end;
end;

// form_onclosequery$(frm#) - Get OnCloseQuery callback name
function s_form_onclosequery_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onclosequery$') then Exit();

  try
    Result.s := TBasForm(Args[0].p).OnCloseQueryFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onclosequery$: ' + E.Message);
  end;
end;

// form_onactivate#(frm#, funcName$) - Set OnActivate callback
function p_form_onactivate_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onactivate#') then Exit();

  try
    TBasForm(Args[0].p).OnActivateFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onactivate#: ' + E.Message);
  end;
end;

// form_onactivate$(frm#) - Get OnActivate callback name
function s_form_onactivate_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onactivate$') then Exit();

  try
    Result.s := TBasForm(Args[0].p).OnActivateFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onactivate$: ' + E.Message);
  end;
end;

// form_ondeactivate#(frm#, funcName$) - Set OnDeactivate callback
function p_form_ondeactivate_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_ondeactivate#') then Exit();

  try
    TBasForm(Args[0].p).OnDeactivateFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_ondeactivate#: ' + E.Message);
  end;
end;

// form_ondeactivate$(frm#) - Get OnDeactivate callback name
function s_form_ondeactivate_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_ondeactivate$') then Exit();

  try
    Result.s := TBasForm(Args[0].p).OnDeactivateFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_ondeactivate$: ' + E.Message);
  end;
end;

// form_onresize#(frm#, funcName$) - Set OnResize callback
function p_form_onresize_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onresize#') then Exit();

  try
    TBasForm(Args[0].p).OnResizeFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onresize#: ' + E.Message);
  end;
end;

// form_onresize$(frm#) - Get OnResize callback name
function s_form_onresize_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onresize$') then Exit();

  try
    Result.s := TBasForm(Args[0].p).OnResizeFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onresize$: ' + E.Message);
  end;
end;

// form_onpaint#(frm#, funcName$) - Set OnPaint callback
function p_form_onpaint_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onpaint#') then Exit();

  try
    TBasForm(Args[0].p).OnPaintFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onpaint#: ' + E.Message);
  end;
end;

// form_onpaint$(frm#) - Get OnPaint callback name
function s_form_onpaint_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onpaint$') then Exit();

  try
    Result.s := TBasForm(Args[0].p).OnPaintFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onpaint$: ' + E.Message);
  end;
end;

// form_onkeydown#(frm#, funcName$) - Set OnKeyDown callback
function p_form_onkeydown_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onkeydown#') then Exit();

  try
    TBasForm(Args[0].p).OnKeyDownFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onkeydown#: ' + E.Message);
  end;
end;

// form_onkeydown$(frm#) - Get OnKeyDown callback name
function s_form_onkeydown_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onkeydown$') then Exit();

  try
    Result.s := TBasForm(Args[0].p).OnKeyDownFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onkeydown$: ' + E.Message);
  end;
end;

// form_onkeyup#(frm#, funcName$) - Set OnKeyUp callback
function p_form_onkeyup_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onkeyup#') then Exit();

  try
    TBasForm(Args[0].p).OnKeyUpFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onkeyup#: ' + E.Message);
  end;
end;

// form_onkeyup$(frm#) - Get OnKeyUp callback name
function s_form_onkeyup_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onkeyup$') then Exit();

  try
    Result.s := TBasForm(Args[0].p).OnKeyUpFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onkeyup$: ' + E.Message);
  end;
end;

// form_onfocuschanged#(frm#, funcName$) - Set OnFocusChanged callback
function p_form_onfocuschanged_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onfocuschanged#') then Exit();

  try
    TBasForm(Args[0].p).OnFocusChangedFunc := Args[1].s;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onfocuschanged#: ' + E.Message);
  end;
end;

// form_onfocuschanged$(frm#) - Get OnFocusChanged callback name
function s_form_onfocuschanged_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_onfocuschanged$') then Exit();

  try
    Result.s := TBasForm(Args[0].p).OnFocusChangedFunc;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_onfocuschanged$: ' + E.Message);
  end;
end;

// form_clearcallbacks#(frm#) - Clear all event callbacks
function p_form_clearcallbacks(var Args: array of TAsmData): TAsmData;
var
  Frm: TBasForm;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_clearcallbacks#') then Exit();

  try
    Frm := TBasForm(Args[0].p);
    Frm.OnShowFunc := '';
    Frm.OnHideFunc := '';
    Frm.OnCloseFunc := '';
    Frm.OnCloseQueryFunc := '';
    Frm.OnActivateFunc := '';
    Frm.OnDeactivateFunc := '';
    Frm.OnResizeFunc := '';
    Frm.OnPaintFunc := '';
    Frm.OnKeyDownFunc := '';
    Frm.OnKeyUpFunc := '';
    Frm.OnFocusChangedFunc := '';
    Frm.OnVirtualKeyboardShownFunc := '';
    Frm.OnVirtualKeyboardHiddenFunc := '';
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_clearcallbacks#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Padding
//==============================================================================

// form_padding(frm#) - Get padding (returns average if uniform)
function n_form_padding_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_padding') then Exit();

  try
    Result.n := TBasForm(Args[0].p).Padding.Left;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_padding: ' + E.Message);
  end;
end;

// form_padding#(frm#, value) - Set uniform padding
function p_form_padding_set(var Args: array of TAsmData): TAsmData;
var
  Frm: TBasForm;
  P: Single;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_padding#') then Exit();

  try
    Frm := TBasForm(Args[0].p);
    P := Args[1].n;
    Frm.Padding.Left := P;
    Frm.Padding.Top := P;
    Frm.Padding.Right := P;
    Frm.Padding.Bottom := P;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_padding#: ' + E.Message);
  end;
end;

// form_paddings#(frm#, left, top, right, bottom) - Set individual paddings
function p_form_paddings_set(var Args: array of TAsmData): TAsmData;
var
  Frm: TBasForm;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_paddings#') then Exit();

  try
    Frm := TBasForm(Args[0].p);
    Frm.Padding.Left := Args[1].n;
    Frm.Padding.Top := Args[2].n;
    Frm.Padding.Right := Args[3].n;
    Frm.Padding.Bottom := Args[4].n;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_paddings#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Functions - Tag (for user data)
//==============================================================================

// form_tag(frm#) - Get tag value
function n_form_tag_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_tag') then Exit();

  try
    Result.n := TBasForm(Args[0].p).Tag;
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_tag: ' + E.Message);
  end;
end;

// form_tag#(frm#, value) - Set tag value
function p_form_tag_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateForm(Args[0].p, 'form_tag#') then Exit();

  try
    TBasForm(Args[0].p).Tag := Trunc(Args[1].n);
  except
    on E: Exception do
      SetError(ERR_OPERATION_FAILED, 'form_tag#: ' + E.Message);
  end;
end;

//==============================================================================
// Library Registration
//==============================================================================

procedure RegisterFormFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  // Store module-level references for event callbacks
  ModuleEngine := Eng;
  ModuleOutput := OutP;

  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_form_error; Lib.Add('form_error@', Fn);
  Fn.Entry := @s_form_errormsg; Lib.Add('form_errormsg$@', Fn);
  Fn.Entry := @s_form_strerror; Lib.Add('form_strerror$@n', Fn);
  Fn.Entry := @n_form_clearerror; Lib.Add('form_clearerror@', Fn);

  // Form creation/destruction
  Fn.Entry := @p_form_new; Lib.Add('form#@', Fn);
  Fn.Entry := @p_form_new_caption; Lib.Add('form#@$', Fn);
  Fn.Entry := @p_form_new_full; Lib.Add('form#@$nn', Fn);
  Fn.Entry := @n_form_free; Lib.Add('form_free@#', Fn);
  Fn.Entry := @n_form_close; Lib.Add('form_close@#', Fn);

  // Form display
  Fn.Entry := @n_form_show; Lib.Add('form_show@#', Fn);
  Fn.Entry := @n_form_showmodal; Lib.Add('form_showmodal@#', Fn);
  Fn.Entry := @p_form_showex; Lib.Add('form_showex#@#$', Fn);
  Fn.Entry := @n_form_hide; Lib.Add('form_hide@#', Fn);
  Fn.Entry := @n_form_visible_get; Lib.Add('form_visible@#', Fn);
  Fn.Entry := @p_form_visible_set; Lib.Add('form_visible#@#n', Fn);

  // Caption
  Fn.Entry := @s_form_caption_get; Lib.Add('form_caption$@#', Fn);
  Fn.Entry := @p_form_caption_set; Lib.Add('form_caption#@#$', Fn);

  // Position and Size
  Fn.Entry := @n_form_left_get; Lib.Add('form_left@#', Fn);
  Fn.Entry := @p_form_left_set; Lib.Add('form_left#@#n', Fn);
  Fn.Entry := @n_form_top_get; Lib.Add('form_top@#', Fn);
  Fn.Entry := @p_form_top_set; Lib.Add('form_top#@#n', Fn);
  Fn.Entry := @n_form_width_get; Lib.Add('form_width@#', Fn);
  Fn.Entry := @p_form_width_set; Lib.Add('form_width#@#n', Fn);
  Fn.Entry := @n_form_height_get; Lib.Add('form_height@#', Fn);
  Fn.Entry := @p_form_height_set; Lib.Add('form_height#@#n', Fn);
  Fn.Entry := @p_form_bounds_set; Lib.Add('form_bounds#@#nnnn', Fn);
  Fn.Entry := @p_form_size_set; Lib.Add('form_size#@#nn', Fn);
  Fn.Entry := @p_form_move_set; Lib.Add('form_move#@#nn', Fn);
  Fn.Entry := @p_form_center; Lib.Add('form_center#@#', Fn);

  // Size constraints
  Fn.Entry := @n_form_minwidth_get; Lib.Add('form_minwidth@#', Fn);
  Fn.Entry := @p_form_minwidth_set; Lib.Add('form_minwidth#@#n', Fn);
  Fn.Entry := @n_form_minheight_get; Lib.Add('form_minheight@#', Fn);
  Fn.Entry := @p_form_minheight_set; Lib.Add('form_minheight#@#n', Fn);
  Fn.Entry := @n_form_maxwidth_get; Lib.Add('form_maxwidth@#', Fn);
  Fn.Entry := @p_form_maxwidth_set; Lib.Add('form_maxwidth#@#n', Fn);
  Fn.Entry := @n_form_maxheight_get; Lib.Add('form_maxheight@#', Fn);
  Fn.Entry := @p_form_maxheight_set; Lib.Add('form_maxheight#@#n', Fn);
  Fn.Entry := @p_form_constraints_set; Lib.Add('form_constraints#@#nnnn', Fn);

  // Position mode
  Fn.Entry := @n_form_position_get; Lib.Add('form_position@#', Fn);
  Fn.Entry := @p_form_position_set; Lib.Add('form_position#@#n', Fn);

  // Window state
  Fn.Entry := @n_form_windowstate_get; Lib.Add('form_windowstate@#', Fn);
  Fn.Entry := @p_form_windowstate_set; Lib.Add('form_windowstate#@#n', Fn);
  Fn.Entry := @p_form_maximize; Lib.Add('form_maximize#@#', Fn);
  Fn.Entry := @p_form_minimize; Lib.Add('form_minimize#@#', Fn);
  Fn.Entry := @p_form_restore; Lib.Add('form_restore#@#', Fn);

  // Border style
  Fn.Entry := @n_form_borderstyle_get; Lib.Add('form_borderstyle@#', Fn);
  Fn.Entry := @p_form_borderstyle_set; Lib.Add('form_borderstyle#@#n', Fn);

  // Form style flags
  Fn.Entry := @n_form_fullscreen_get; Lib.Add('form_fullscreen@#', Fn);
  Fn.Entry := @p_form_fullscreen_set; Lib.Add('form_fullscreen#@#n', Fn);
  Fn.Entry := @n_form_stayontop_get; Lib.Add('form_stayontop@#', Fn);
  Fn.Entry := @p_form_stayontop_set; Lib.Add('form_stayontop#@#n', Fn);
  Fn.Entry := @n_form_showfullscreenicon_get; Lib.Add('form_showfullscreenicon@#', Fn);
  Fn.Entry := @p_form_showfullscreenicon_set; Lib.Add('form_showfullscreenicon#@#n', Fn);

  // Fill color
  Fn.Entry := @s_form_fill_get; Lib.Add('form_fill$@#', Fn);
  Fn.Entry := @p_form_fill_set; Lib.Add('form_fill#@#$', Fn);

  // Transparency
  Fn.Entry := @n_form_transparency_get; Lib.Add('form_transparency@#', Fn);
  Fn.Entry := @p_form_transparency_set; Lib.Add('form_transparency#@#n', Fn);

  // Focus and activation
  Fn.Entry := @n_form_active_get; Lib.Add('form_active@#', Fn);
  Fn.Entry := @p_form_bringtofront; Lib.Add('form_bringtofront#@#', Fn);
  Fn.Entry := @p_form_sendtoback; Lib.Add('form_sendtoback#@#', Fn);
  Fn.Entry := @p_form_setfocus; Lib.Add('form_setfocus#@#', Fn);

  // Close action and behavior
  Fn.Entry := @n_form_closeaction_get; Lib.Add('form_closeaction@#', Fn);
  Fn.Entry := @p_form_closeaction_set; Lib.Add('form_closeaction#@#n', Fn);
  Fn.Entry := @n_form_allowclose_get; Lib.Add('form_allowclose@#', Fn);
  Fn.Entry := @p_form_allowclose_set; Lib.Add('form_allowclose#@#n', Fn);

  // Modal result
  Fn.Entry := @n_form_modalresult_get; Lib.Add('form_modalresult@#', Fn);
  Fn.Entry := @p_form_modalresult_set; Lib.Add('form_modalresult#@#n', Fn);

  // Client area
  Fn.Entry := @n_form_clientwidth_get; Lib.Add('form_clientwidth@#', Fn);
  Fn.Entry := @n_form_clientheight_get; Lib.Add('form_clientheight@#', Fn);

  // Invalidation/Repaint
  Fn.Entry := @p_form_invalidate; Lib.Add('form_invalidate#@#', Fn);

  // Handle
  Fn.Entry := @n_form_handle_get; Lib.Add('form_handle@#', Fn);

  // Event callbacks
  Fn.Entry := @p_form_onshow_set; Lib.Add('form_onshow#@#$', Fn);
  Fn.Entry := @s_form_onshow_get; Lib.Add('form_onshow$@#', Fn);
  Fn.Entry := @p_form_onhide_set; Lib.Add('form_onhide#@#$', Fn);
  Fn.Entry := @s_form_onhide_get; Lib.Add('form_onhide$@#', Fn);
  Fn.Entry := @p_form_onclose_set; Lib.Add('form_onclose#@#$', Fn);
  Fn.Entry := @s_form_onclose_get; Lib.Add('form_onclose$@#', Fn);
  Fn.Entry := @p_form_onclosequery_set; Lib.Add('form_onclosequery#@#$', Fn);
  Fn.Entry := @s_form_onclosequery_get; Lib.Add('form_onclosequery$@#', Fn);
  Fn.Entry := @p_form_onactivate_set; Lib.Add('form_onactivate#@#$', Fn);
  Fn.Entry := @s_form_onactivate_get; Lib.Add('form_onactivate$@#', Fn);
  Fn.Entry := @p_form_ondeactivate_set; Lib.Add('form_ondeactivate#@#$', Fn);
  Fn.Entry := @s_form_ondeactivate_get; Lib.Add('form_ondeactivate$@#', Fn);
  Fn.Entry := @p_form_onresize_set; Lib.Add('form_onresize#@#$', Fn);
  Fn.Entry := @s_form_onresize_get; Lib.Add('form_onresize$@#', Fn);
  Fn.Entry := @p_form_onpaint_set; Lib.Add('form_onpaint#@#$', Fn);
  Fn.Entry := @s_form_onpaint_get; Lib.Add('form_onpaint$@#', Fn);
  Fn.Entry := @p_form_onkeydown_set; Lib.Add('form_onkeydown#@#$', Fn);
  Fn.Entry := @s_form_onkeydown_get; Lib.Add('form_onkeydown$@#', Fn);
  Fn.Entry := @p_form_onkeyup_set; Lib.Add('form_onkeyup#@#$', Fn);
  Fn.Entry := @s_form_onkeyup_get; Lib.Add('form_onkeyup$@#', Fn);
  Fn.Entry := @p_form_onfocuschanged_set; Lib.Add('form_onfocuschanged#@#$', Fn);
  Fn.Entry := @s_form_onfocuschanged_get; Lib.Add('form_onfocuschanged$@#', Fn);
  Fn.Entry := @p_form_clearcallbacks; Lib.Add('form_clearcallbacks#@#', Fn);

  // Padding
  Fn.Entry := @n_form_padding_get; Lib.Add('form_padding@#', Fn);
  Fn.Entry := @p_form_padding_set; Lib.Add('form_padding#@#n', Fn);
  Fn.Entry := @p_form_paddings_set; Lib.Add('form_paddings#@#nnnn', Fn);

  // Tag
  Fn.Entry := @n_form_tag_get; Lib.Add('form_tag@#', Fn);
  Fn.Entry := @p_form_tag_set; Lib.Add('form_tag#@#n', Fn);

  // Form style
  Fn.Entry := @n_form_formstyle_get; Lib.Add('form_formstyle@#', Fn);
  Fn.Entry := @p_form_formstyle_set; Lib.Add('form_formstyle#@#n', Fn);

  // Screen information (cross-platform)
  Fn.Entry := @n_form_screenwidth; Lib.Add('form_screenwidth@', Fn);
  Fn.Entry := @n_form_screenheight; Lib.Add('form_screenheight@', Fn);
  Fn.Entry := @n_form_screenscale; Lib.Add('form_screenscale@', Fn);
  Fn.Entry := @n_form_screenorientation; Lib.Add('form_screenorientation@', Fn);
end;

// =============================================================================
// Cleanup — called by UnitMain during engine reset and app shutdown
// =============================================================================

procedure CleanupAllForms();
var
  Frm: TBasForm;
begin
  if not Assigned(ActiveForms) then
    Exit;

  // Free all forms in reverse order (LIFO), same pattern as TimerLib
  while ActiveForms.Count > 0 do
  begin
    Frm := ActiveForms[ActiveForms.Count - 1];
    ActiveForms.Delete(ActiveForms.Count - 1);
    try
      Frm.DisconnectEvents();
      Frm.Close();
      Frm.Free();
    except
      // Ignore errors during cleanup
    end;
  end;
end;

// =============================================================================
// Initialization and Finalization
// =============================================================================

initialization
  ActiveForms := TList<TBasForm>.Create();

finalization
  CleanupAllForms();
  FreeAndNil(ActiveForms);

end.

