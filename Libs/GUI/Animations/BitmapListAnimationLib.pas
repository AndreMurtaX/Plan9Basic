unit BitmapListAnimationLib;

{******************************************************************************
  BitmapListAnimationLib - Bitmap List Animation Library for Plan9Basic
  Version: 1.0.0

  Provides sprite sheet animation functionality for Image controls.
  Uses a single bitmap containing all frames arranged in a grid, with
  AnimationCount and AnimationRowCount to define the frame layout.

  Function Count: 55+ functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64)
  - macOS (Intel/ARM)
  - Linux
  - Android
  - iOS

  SPRITE SHEET APPROACH:
  ======================
  TBitmapListAnimation uses a single bitmap image containing all animation
  frames arranged in a grid. You specify:
  - AnimationBitmap: The sprite sheet bitmap (all frames in one image)
  - AnimationCount: Total number of frames
  - AnimationRowCount: Number of rows in the sprite sheet (frames per row = count/rows)

  Example sprite sheet layout (8 frames, 2 rows):
  +---+---+---+---+
  | 1 | 2 | 3 | 4 |  <- Row 1
  +---+---+---+---+
  | 5 | 6 | 7 | 8 |  <- Row 2
  +---+---+---+---+

  ANIMATION TYPES (AnimationType):
  ================================
  - "In" - Acceleration at start
  - "Out" - Deceleration at end
  - "InOut" - Acceleration then deceleration

  INTERPOLATION TYPES:
  ====================
  - "Linear", "Quadratic", "Cubic", "Quartic", "Quintic"
  - "Sinusoidal", "Exponential", "Circular"
  - "Elastic", "Back", "Bounce"

  EVENT SUPPORT:
  ==============
  - OnFinish: Animation completed
  - OnProcess: Called on each animation frame

  USAGE PATTERN:
  ==============
    let frm# = form#("Sprite Animation Demo", 400, 400)

    ' Create an image control for displaying the animated sprite
    let sprite# = image#(frm#, 100, 100, 64, 64)

    ' Create bitmap list animation on the sprite image
    let ani# = bmplistani#(sprite#)

    ' Option 1: Load sprite sheet directly from file
    bmplistani_loadspritesheet#(ani#, "spritesheet.png")

    ' Option 2: Use another image control as sprite sheet source
    ' let sheetImg# = image#(frm#, 0, 0, 256, 128)
    ' image_load#(sheetImg#, "spritesheet.png")
    ' image_visible#(sheetImg#, 0)  ' Hide the source image
    ' bmplistani_animationbitmap#(ani#, sheetImg#)

    ' Configure animation
    bmplistani_animationcount#(ani#, 8)      ' 8 frames total
    bmplistani_animationrowcount#(ani#, 2)   ' 2 rows (4 frames per row)
    bmplistani_duration#(ani#, 1.0)          ' 1 second per cycle
    bmplistani_loop#(ani#, 1)
    bmplistani_start(ani#)

    form_show(frm#)

  Copyright (c) 2024-2026 André Murta
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.TypInfo,
  FMX.Types, FMX.Controls, FMX.Ani, FMX.Graphics, FMX.Objects,
  basic, exec, UnitGC, UnitUtils, HandleRegistry, GuiUtils, ControlCommon;

type
  TBasBitmapListAnimation = class(TBitmapListAnimation)
  private
    FOnFinishFunc: String;
    FOnProcessFunc: String;
    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;

    procedure InternalOnFinish(Sender: TObject);
    procedure InternalOnProcess(Sender: TObject);

    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);

    procedure SetOnFinishFunc(const Value: String);
    procedure SetOnProcessFunc(const Value: String);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
    procedure DisconnectAllEvents();

    property OnFinishFunc: String read FOnFinishFunc write SetOnFinishFunc;
    property OnProcessFunc: String read FOnProcessFunc write SetOnProcessFunc;
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
  end;

procedure RegisterBitmapListAnimationFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

var
  LastError: Integer = 0;
  LastErrorMsg: String = '';

const
  ERR_NONE = 0;
  ERR_NIL_ANIMATION = 1;
  ERR_INVALID_PROPERTY = 2;
  ERR_INVALID_VALUE = 3;
  ERR_ANIMATION_RUNNING = 4;
  ERR_FILE_NOT_FOUND = 5;
  ERR_LOAD_FAILED = 6;

// =============================================================================
// Error Handling
// =============================================================================

procedure SetError(Code: Integer; const Msg: String);
begin
  LastError := Code;
  LastErrorMsg := Msg;
end;

procedure ClearError();
begin
  LastError := ERR_NONE;
  LastErrorMsg := '';
end;

function ValidateAnimation(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if not Assigned(P) then
  begin
    SetError(ERR_NIL_ANIMATION, FuncName + ': animation is nil');
    Exit;
  end;
  if not (IsHandleOf(P, TBasBitmapListAnimation)) then
  begin
    SetError(ERR_INVALID_PROPERTY, FuncName + ': invalid animation object');
    Exit;
  end;
  Result := True;
end;

// =============================================================================
// TBasBitmapListAnimation Implementation
// =============================================================================

constructor TBasBitmapListAnimation.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);
  FOnFinishFunc := '';
  FOnProcessFunc := '';
  FBasicEngine := nil;
  FConsoleOutput := nil;
end;

destructor TBasBitmapListAnimation.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectAllEvents();
  inherited Destroy();
end;

procedure TBasBitmapListAnimation.DisconnectAllEvents();
begin
  OnFinish := nil;
  OnProcess := nil;
  FOnFinishFunc := '';
  FOnProcessFunc := '';
end;

procedure TBasBitmapListAnimation.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
var
  CallArgs: array of TAsmData;
  RetType: TExprKind;
  RetVal: TAsmData;
  I: Integer;
begin
  if UnitGC.CallbackInProgress() then Exit;
  if not Assigned(FBasicEngine) then Exit;
  if not Assigned(FConsoleOutput) then Exit;
  if FuncSignature = '' then Exit;

  if not UnitGC.ClaimCallbackGuard() then
    Exit();
  UnitGC.SkipProcessMessages := True;

  try
    SetLength(CallArgs, Length(Args));
    for I := 0 to High(Args) do
      CallArgs[I] := Args[I];
    try
      FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, CallArgs,
        RetType, RetVal);
    except
      on E: Exception do
      begin
        FConsoleOutput.Add('*** BitmapListAnimation Callback Error: ' + E.Message);
      end;
    end;
  finally
    UnitGC.SkipProcessMessages := False;
    UnitGC.ReleaseCallbackGuard();
  end;
end;

procedure TBasBitmapListAnimation.SetOnFinishFunc(const Value: String);
begin
  FOnFinishFunc := Value;
  if Value <> '' then
    OnFinish := InternalOnFinish
  else
    OnFinish := nil;
end;

procedure TBasBitmapListAnimation.SetOnProcessFunc(const Value: String);
begin
  FOnProcessFunc := Value;
  if Value <> '' then
    OnProcess := InternalOnProcess
  else
    OnProcess := nil;
end;

procedure TBasBitmapListAnimation.InternalOnFinish(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnFinishFunc = '' then Exit;

  SenderArg.n := 0;
  SenderArg.s := '';
  SenderArg.p := Pointer(Self);

  ExecuteCallback(LowerCase(FOnFinishFunc) + '@#', [SenderArg]);
end;

procedure TBasBitmapListAnimation.InternalOnProcess(Sender: TObject);
var
  SenderArg: TAsmData;
begin
  if FOnProcessFunc = '' then Exit;

  SenderArg.n := 0;
  SenderArg.s := '';
  SenderArg.p := Pointer(Self);

  ExecuteCallback(LowerCase(FOnProcessFunc) + '@#', [SenderArg]);
end;

// =============================================================================
// Library Functions - Error Handling
// =============================================================================

function n_bmplistani_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := LastError;
  Result.s := '';
  Result.p := nil;
end;

function s_bmplistani_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := LastErrorMsg;
  Result.p := nil;
end;

function s_bmplistani_strerror(var Args: array of TAsmData): TAsmData;
var
  Code: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Code := Trunc(Args[0].n);
  case Code of
    ERR_NONE: Result.s := 'No error';
    ERR_NIL_ANIMATION: Result.s := 'Animation is nil';
    ERR_INVALID_PROPERTY: Result.s := 'Invalid property or object';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_ANIMATION_RUNNING: Result.s := 'Cannot modify while animation is running';
    ERR_FILE_NOT_FOUND: Result.s := 'Image file not found';
    ERR_LOAD_FAILED: Result.s := 'Failed to load image';
  else
    Result.s := 'Unknown error';
  end;
end;

function n_bmplistani_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 1;
  Result.s := '';
  Result.p := nil;
end;

// =============================================================================
// Library Functions - Creation/Destruction
// =============================================================================

function p_bmplistani_new(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Ani: TBasBitmapListAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  try
    // Create with parent as Owner - parent will free us when destroyed
    // This is safe because TBasRectAnimation is NOT a visual child (no Parent property)
    // Only the internal TFloatAnimation objects need Create(nil) to avoid double-free
    Ani := TBasBitmapListAnimation.Create(TComponent(Args[0].p));
    Ani.Parent := TFmxObject(Args[0].p);
    Ani.PropertyName := 'Bitmap';  // Default property for TImage
    //An animation is a TComponent with no Parent, so the walk starts at the
    //control it animates, which does have one.
    if EngineOf(TFmxObject(Args[0].p), Eng, Outp) then
    begin
      Ani.BasicEngine := Eng;
      Ani.ConsoleOutput := Outp;
    end;

    //UnitGC.GC.Add<TBasBitmapListAnimation>(Ani, IntToStr(NativeInt(Ani)));

    Result.p := Pointer(Ani);
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani#: ' + E.Message);
  end;
end;

function p_bmplistani_new_named(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Ani: TBasBitmapListAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;
  ClearError();

  try
    // Create with parent as Owner - parent will free us when destroyed
    // This is safe because TBasRectAnimation is NOT a visual child (no Parent property)
    // Only the internal TFloatAnimation objects need Create(nil) to avoid double-free
    Ani := TBasBitmapListAnimation.Create(TComponent(Args[0].p));
    Ani.Parent := TFmxObject(Args[0].p);
    Ani.Name := Args[1].s;
    Ani.PropertyName := 'Bitmap';
    //An animation is a TComponent with no Parent, so the walk starts at the
    //control it animates, which does have one.
    if EngineOf(TFmxObject(Args[0].p), Eng, Outp) then
    begin
      Ani.BasicEngine := Eng;
      Ani.ConsoleOutput := Outp;
    end;

    //UnitGC.GC.Add<TBasBitmapListAnimation>(Ani, IntToStr(NativeInt(Ani)));

    Result.p := Pointer(Ani);
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani#: ' + E.Message);
  end;
end;

function n_bmplistani_free(var Args: array of TAsmData): TAsmData;
var
  Ani: TBasBitmapListAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_free') then Exit;

  try
    Ani := TBasBitmapListAnimation(Args[0].p);
    Ani.DisconnectAllEvents();
    //UnitGC.GC.Collect(IntToStr(NativeInt(Args[0].p))); No GC. The object is freed automatically by the owner
    Ani.Free();
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_free: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Animation Control
// =============================================================================

function n_bmplistani_start(var Args: array of TAsmData): TAsmData;
var
  Ani: TBasBitmapListAnimation;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_start') then Exit;

  try
    Ani := TBasBitmapListAnimation(Args[0].p);

    // Check if sprite sheet is loaded
    if not Assigned(Ani.AnimationBitmap) or Ani.AnimationBitmap.IsEmpty then
    begin
      SetError(ERR_INVALID_VALUE, 'bmplistani_start: No sprite sheet loaded. Use bmplistani_loadspritesheet# first.');
      Exit;
    end;

    Ani.Start;
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_start: ' + E.Message);
  end;
end;

function n_bmplistani_stop(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_stop') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).Stop;
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_stop: ' + E.Message);
  end;
end;

function n_bmplistani_stopatcurrent(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_stopatcurrent') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).StopAtCurrent;
    Result.n := 1;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_stopatcurrent: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Sprite Sheet Properties (Core)
// =============================================================================

// Set animation bitmap from an Image control's bitmap (sprite sheet source)
function p_bmplistani_animationbitmap_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_animationbitmap#') then Exit;

  try
    // Args[1].p is an Image control (TImage) - get its Bitmap
    if not Assigned(Args[1].p) then
    begin
      SetError(ERR_INVALID_VALUE, 'bmplistani_animationbitmap#: Image control is nil');
      Exit;
    end;

    TBasBitmapListAnimation(Args[0].p).AnimationBitmap := TImage(Args[1].p).Bitmap;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_animationbitmap#: ' + E.Message);
  end;
end;

// Get animation bitmap pointer (returns the internal TBitmap, not an Image control)
function p_bmplistani_animationbitmap_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_animationbitmap#') then Exit;

  try
    Result.p := Pointer(TBasBitmapListAnimation(Args[0].p).AnimationBitmap);
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_animationbitmap#: ' + E.Message);
  end;
end;

// Helper: Detect web URLs
function IsWebUrl(const Path: String): Boolean;
var
  LowerPath: String;
begin
  LowerPath := LowerCase(Trim(Path));
  Result := LowerPath.StartsWith('http://') or LowerPath.StartsWith('https://');
end;

// Load sprite sheet from web URL or local file (convenience function)
// Strategy: try web first if URL; on failure, silently fall back to file system.
function p_bmplistani_loadspritesheet(var Args: array of TAsmData): TAsmData;
var
  Ani: TBasBitmapListAnimation;
  Bmp: TBitmap;
  FilePath: String;
  Loaded: Boolean;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_loadspritesheet#') then Exit;

  try
    FilePath := Args[1].s;
    Ani := TBasBitmapListAnimation(Args[0].p);
    Loaded := False;

    // Create a temporary bitmap, load, then assign to animation
    Bmp := TBitmap.Create;
    try
      // First, try loading from web if it looks like a URL
      if IsWebUrl(FilePath) then
      begin
        if TGuiUtils.LoadImageFromWeb(FilePath, Bmp) then
          Loaded := True;
      end;

      // If not loaded yet, silently try loading from file system
      if not Loaded then
      begin
        if FileExists(FilePath) then
        begin
          Bmp.LoadFromFile(FilePath);
          Loaded := True;
        end;
      end;

      // Assign or report error
      if Loaded then
      begin
        Ani.AnimationBitmap := Bmp;
        Result.p := Args[0].p;
        ClearError();
      end
      else
        SetError(ERR_FILE_NOT_FOUND, 'bmplistani_loadspritesheet#: File not found: ' + FilePath);
    finally
      Bmp.Free;
    end;
  except
    on E: Exception do
      SetError(ERR_LOAD_FAILED, 'bmplistani_loadspritesheet#: ' + E.Message);
  end;
end;

// Set animation count (total number of frames)
function p_bmplistani_animationcount_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_animationcount#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).AnimationCount := Trunc(Args[1].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_animationcount#: ' + E.Message);
  end;
end;

// Get animation count
function n_bmplistani_animationcount_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_animationcount') then Exit;

  try
    Result.n := TBasBitmapListAnimation(Args[0].p).AnimationCount;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_animationcount: ' + E.Message);
  end;
end;

// Set animation row count (rows in sprite sheet)
function p_bmplistani_animationrowcount_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_animationrowcount#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).AnimationRowCount := Trunc(Args[1].n);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_animationrowcount#: ' + E.Message);
  end;
end;

// Get animation row count
function n_bmplistani_animationrowcount_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_animationrowcount') then Exit;

  try
    Result.n := TBasBitmapListAnimation(Args[0].p).AnimationRowCount;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_animationrowcount: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Duration/Delay
// =============================================================================

function p_bmplistani_duration_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_duration#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).Duration := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_duration#: ' + E.Message);
  end;
end;

function n_bmplistani_duration_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_duration') then Exit;

  try
    Result.n := TBasBitmapListAnimation(Args[0].p).Duration;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_duration: ' + E.Message);
  end;
end;

function p_bmplistani_delay_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_delay#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).Delay := Args[1].n;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_delay#: ' + E.Message);
  end;
end;

function n_bmplistani_delay_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_delay') then Exit;

  try
    Result.n := TBasBitmapListAnimation(Args[0].p).Delay;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_delay: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Animation Behavior
// =============================================================================

function p_bmplistani_animationtype_set(var Args: array of TAsmData): TAsmData;
var
  TypeStr: String;
  AniType: TAnimationType;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_animationtype#') then Exit;

  try
    TypeStr := LowerCase(Args[1].s);
    if TypeStr = 'in' then
      AniType := TAnimationType.In
    else if TypeStr = 'out' then
      AniType := TAnimationType.Out
    else if TypeStr = 'inout' then
      AniType := TAnimationType.InOut
    else
      AniType := TAnimationType.In;

    TBasBitmapListAnimation(Args[0].p).AnimationType := AniType;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_animationtype#: ' + E.Message);
  end;
end;

function s_bmplistani_animationtype_get(var Args: array of TAsmData): TAsmData;
var
  AniType: TAnimationType;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_animationtype$') then Exit;

  try
    AniType := TBasBitmapListAnimation(Args[0].p).AnimationType;
    case AniType of
      TAnimationType.In: Result.s := 'In';
      TAnimationType.Out: Result.s := 'Out';
      TAnimationType.InOut: Result.s := 'InOut';
    else
      Result.s := 'In';
    end;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_animationtype$: ' + E.Message);
  end;
end;

function p_bmplistani_interpolation_set(var Args: array of TAsmData): TAsmData;
var
  InterpStr: String;
  Interp: TInterpolationType;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_interpolation#') then Exit;

  try
    InterpStr := LowerCase(Args[1].s);
    if InterpStr = 'linear' then
      Interp := TInterpolationType.Linear
    else if InterpStr = 'quadratic' then
      Interp := TInterpolationType.Quadratic
    else if InterpStr = 'cubic' then
      Interp := TInterpolationType.Cubic
    else if InterpStr = 'quartic' then
      Interp := TInterpolationType.Quartic
    else if InterpStr = 'quintic' then
      Interp := TInterpolationType.Quintic
    else if InterpStr = 'sinusoidal' then
      Interp := TInterpolationType.Sinusoidal
    else if InterpStr = 'exponential' then
      Interp := TInterpolationType.Exponential
    else if InterpStr = 'circular' then
      Interp := TInterpolationType.Circular
    else if InterpStr = 'elastic' then
      Interp := TInterpolationType.Elastic
    else if InterpStr = 'back' then
      Interp := TInterpolationType.Back
    else if InterpStr = 'bounce' then
      Interp := TInterpolationType.Bounce
    else
      Interp := TInterpolationType.Linear;

    TBasBitmapListAnimation(Args[0].p).Interpolation := Interp;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_interpolation#: ' + E.Message);
  end;
end;

function s_bmplistani_interpolation_get(var Args: array of TAsmData): TAsmData;
var
  Interp: TInterpolationType;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_interpolation$') then Exit;

  try
    Interp := TBasBitmapListAnimation(Args[0].p).Interpolation;
    case Interp of
      TInterpolationType.Linear: Result.s := 'Linear';
      TInterpolationType.Quadratic: Result.s := 'Quadratic';
      TInterpolationType.Cubic: Result.s := 'Cubic';
      TInterpolationType.Quartic: Result.s := 'Quartic';
      TInterpolationType.Quintic: Result.s := 'Quintic';
      TInterpolationType.Sinusoidal: Result.s := 'Sinusoidal';
      TInterpolationType.Exponential: Result.s := 'Exponential';
      TInterpolationType.Circular: Result.s := 'Circular';
      TInterpolationType.Elastic: Result.s := 'Elastic';
      TInterpolationType.Back: Result.s := 'Back';
      TInterpolationType.Bounce: Result.s := 'Bounce';
    else
      Result.s := 'Linear';
    end;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_interpolation$: ' + E.Message);
  end;
end;

function p_bmplistani_loop_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_loop#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).Loop := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_loop#: ' + E.Message);
  end;
end;

function n_bmplistani_loop_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_loop') then Exit;

  try
    if TBasBitmapListAnimation(Args[0].p).Loop then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_loop: ' + E.Message);
  end;
end;

function p_bmplistani_autoreverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_autoreverse#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).AutoReverse := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_autoreverse#: ' + E.Message);
  end;
end;

function n_bmplistani_autoreverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_autoreverse') then Exit;

  try
    if TBasBitmapListAnimation(Args[0].p).AutoReverse then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_autoreverse: ' + E.Message);
  end;
end;

function p_bmplistani_inverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_inverse#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).Inverse := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_inverse#: ' + E.Message);
  end;
end;

function n_bmplistani_inverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_inverse') then Exit;

  try
    if TBasBitmapListAnimation(Args[0].p).Inverse then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_inverse: ' + E.Message);
  end;
end;

function p_bmplistani_enabled_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_enabled#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_enabled#: ' + E.Message);
  end;
end;

function n_bmplistani_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_enabled') then Exit;

  try
    if TBasBitmapListAnimation(Args[0].p).Enabled then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_enabled: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - State Queries
// =============================================================================

function n_bmplistani_running(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_running') then Exit;

  try
    if TBasBitmapListAnimation(Args[0].p).Running then
      Result.n := 1
    else
      Result.n := 0;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_running: ' + E.Message);
  end;
end;

function n_bmplistani_normalizedtime(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_normalizedtime') then Exit;

  try
    Result.n := TBasBitmapListAnimation(Args[0].p).NormalizedTime;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_normalizedtime: ' + E.Message);
  end;
end;

function s_bmplistani_name(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_name$') then Exit;

  try
    Result.s := TBasBitmapListAnimation(Args[0].p).Name;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_name$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Property Name
// =============================================================================

function p_bmplistani_propertyname_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_propertyname#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).PropertyName := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_propertyname#: ' + E.Message);
  end;
end;

function s_bmplistani_propertyname_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_propertyname$') then Exit;

  try
    Result.s := TBasBitmapListAnimation(Args[0].p).PropertyName;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_propertyname$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Triggers
// =============================================================================

function p_bmplistani_trigger_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_trigger#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).Trigger := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_trigger#: ' + E.Message);
  end;
end;

function s_bmplistani_trigger_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_trigger$') then Exit;

  try
    Result.s := TBasBitmapListAnimation(Args[0].p).Trigger;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_trigger$: ' + E.Message);
  end;
end;

function p_bmplistani_triggerinverse_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_triggerinverse#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).TriggerInverse := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_triggerinverse#: ' + E.Message);
  end;
end;

function s_bmplistani_triggerinverse_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_triggerinverse$') then Exit;

  try
    Result.s := TBasBitmapListAnimation(Args[0].p).TriggerInverse;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_triggerinverse$: ' + E.Message);
  end;
end;

// =============================================================================
// Library Functions - Event Callbacks
// =============================================================================

function p_bmplistani_onfinish_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_onfinish#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).OnFinishFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_onfinish#: ' + E.Message);
  end;
end;

function s_bmplistani_onfinish_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_onfinish$') then Exit;

  try
    Result.s := TBasBitmapListAnimation(Args[0].p).OnFinishFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_onfinish$: ' + E.Message);
  end;
end;

function p_bmplistani_onprocess_set(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_onprocess#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).OnProcessFunc := Args[1].s;
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_VALUE, 'bmplistani_onprocess#: ' + E.Message);
  end;
end;

function s_bmplistani_onprocess_get(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_onprocess$') then Exit;

  try
    Result.s := TBasBitmapListAnimation(Args[0].p).OnProcessFunc;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_onprocess$: ' + E.Message);
  end;
end;

function p_bmplistani_clearcallbacks(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.s := '';
  Result.p := nil;

  if not ValidateAnimation(Args[0].p, 'bmplistani_clearcallbacks#') then Exit;

  try
    TBasBitmapListAnimation(Args[0].p).DisconnectAllEvents();
    Result.p := Args[0].p;
    ClearError();
  except
    on E: Exception do
      SetError(ERR_INVALID_PROPERTY, 'bmplistani_clearcallbacks#: ' + E.Message);
  end;
end;

// =============================================================================
// Library Registration
// =============================================================================

procedure RegisterBitmapListAnimationFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_bmplistani_error; Lib.Add('bmplistani_error@', Fn);
  Fn.Entry := @s_bmplistani_errormsg; Lib.Add('bmplistani_errormsg$@', Fn);
  Fn.Entry := @s_bmplistani_strerror; Lib.Add('bmplistani_strerror$@n', Fn);
  Fn.Entry := @n_bmplistani_clearerror; Lib.Add('bmplistani_clearerror@', Fn);

  // Creation/destruction
  Fn.Entry := @p_bmplistani_new; Lib.Add('bmplistani#@#', Fn);
  Fn.Entry := @p_bmplistani_new_named; Lib.Add('bmplistani#@#$', Fn);
  Fn.Entry := @n_bmplistani_free; Lib.Add('bmplistani_free@#', Fn);

  // Animation control
  Fn.Entry := @n_bmplistani_start; Lib.Add('bmplistani_start@#', Fn);
  Fn.Entry := @n_bmplistani_stop; Lib.Add('bmplistani_stop@#', Fn);
  Fn.Entry := @n_bmplistani_stopatcurrent; Lib.Add('bmplistani_stopatcurrent@#', Fn);

  // Sprite sheet properties (Core)
  Fn.Entry := @p_bmplistani_animationbitmap_set; Lib.Add('bmplistani_animationbitmap#@##', Fn);
  Fn.Entry := @p_bmplistani_animationbitmap_get; Lib.Add('bmplistani_animationbitmap#@#', Fn);
  Fn.Entry := @p_bmplistani_loadspritesheet; Lib.Add('bmplistani_loadspritesheet#@#$', Fn);
  Fn.Entry := @p_bmplistani_animationcount_set; Lib.Add('bmplistani_animationcount#@#n', Fn);
  Fn.Entry := @n_bmplistani_animationcount_get; Lib.Add('bmplistani_animationcount@#', Fn);
  Fn.Entry := @p_bmplistani_animationrowcount_set; Lib.Add('bmplistani_animationrowcount#@#n', Fn);
  Fn.Entry := @n_bmplistani_animationrowcount_get; Lib.Add('bmplistani_animationrowcount@#', Fn);

  // Duration/Delay
  Fn.Entry := @p_bmplistani_duration_set; Lib.Add('bmplistani_duration#@#n', Fn);
  Fn.Entry := @n_bmplistani_duration_get; Lib.Add('bmplistani_duration@#', Fn);
  Fn.Entry := @p_bmplistani_delay_set; Lib.Add('bmplistani_delay#@#n', Fn);
  Fn.Entry := @n_bmplistani_delay_get; Lib.Add('bmplistani_delay@#', Fn);

  // Animation behavior
  Fn.Entry := @p_bmplistani_animationtype_set; Lib.Add('bmplistani_animationtype#@#$', Fn);
  Fn.Entry := @s_bmplistani_animationtype_get; Lib.Add('bmplistani_animationtype$@#', Fn);
  Fn.Entry := @p_bmplistani_interpolation_set; Lib.Add('bmplistani_interpolation#@#$', Fn);
  Fn.Entry := @s_bmplistani_interpolation_get; Lib.Add('bmplistani_interpolation$@#', Fn);
  Fn.Entry := @p_bmplistani_loop_set; Lib.Add('bmplistani_loop#@#n', Fn);
  Fn.Entry := @n_bmplistani_loop_get; Lib.Add('bmplistani_loop@#', Fn);
  Fn.Entry := @p_bmplistani_autoreverse_set; Lib.Add('bmplistani_autoreverse#@#n', Fn);
  Fn.Entry := @n_bmplistani_autoreverse_get; Lib.Add('bmplistani_autoreverse@#', Fn);
  Fn.Entry := @p_bmplistani_inverse_set; Lib.Add('bmplistani_inverse#@#n', Fn);
  Fn.Entry := @n_bmplistani_inverse_get; Lib.Add('bmplistani_inverse@#', Fn);
  Fn.Entry := @p_bmplistani_enabled_set; Lib.Add('bmplistani_enabled#@#n', Fn);
  Fn.Entry := @n_bmplistani_enabled_get; Lib.Add('bmplistani_enabled@#', Fn);

  // State queries
  Fn.Entry := @n_bmplistani_running; Lib.Add('bmplistani_running@#', Fn);
  Fn.Entry := @n_bmplistani_normalizedtime; Lib.Add('bmplistani_normalizedtime@#', Fn);
  Fn.Entry := @s_bmplistani_name; Lib.Add('bmplistani_name$@#', Fn);

  // Property name
  Fn.Entry := @p_bmplistani_propertyname_set; Lib.Add('bmplistani_propertyname#@#$', Fn);
  Fn.Entry := @s_bmplistani_propertyname_get; Lib.Add('bmplistani_propertyname$@#', Fn);

  // Triggers
  Fn.Entry := @p_bmplistani_trigger_set; Lib.Add('bmplistani_trigger#@#$', Fn);
  Fn.Entry := @s_bmplistani_trigger_get; Lib.Add('bmplistani_trigger$@#', Fn);
  Fn.Entry := @p_bmplistani_triggerinverse_set; Lib.Add('bmplistani_triggerinverse#@#$', Fn);
  Fn.Entry := @s_bmplistani_triggerinverse_get; Lib.Add('bmplistani_triggerinverse$@#', Fn);

  // Event callbacks
  Fn.Entry := @p_bmplistani_onfinish_set; Lib.Add('bmplistani_onfinish#@#$', Fn);
  Fn.Entry := @s_bmplistani_onfinish_get; Lib.Add('bmplistani_onfinish$@#', Fn);
  Fn.Entry := @p_bmplistani_onprocess_set; Lib.Add('bmplistani_onprocess#@#$', Fn);
  Fn.Entry := @s_bmplistani_onprocess_get; Lib.Add('bmplistani_onprocess$@#', Fn);
  Fn.Entry := @p_bmplistani_clearcallbacks; Lib.Add('bmplistani_clearcallbacks#@#', Fn);
end;

end.

