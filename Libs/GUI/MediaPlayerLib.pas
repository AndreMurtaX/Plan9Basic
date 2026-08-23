unit MediaPlayerLib;

{******************************************************************************
  MediaPlayerLib - Media Player Library for Plan9Basic
  Version: 1.0.0

  Provides comprehensive audio and video playback functionality for Plan9Basic
  programs. Supports loading and playing media files across multiple platforms.

  Function Count: 53 functions

  CROSS-PLATFORM SUPPORT:
  =======================
  - Windows (Win32/Win64): WMV, WMA, MP3, MP4, AVI, WAV
  - macOS (Intel/ARM): MP4, M4A, M4V, MP3, MOV, WAV, AAC
  - Linux: Depends on GStreamer (MP3, MP4, OGG, WAV)
  - Android: MP4, MP3, 3GP, OGG, WAV, AAC
  - iOS: MP4, M4A, M4V, MP3, MOV, WAV, AAC

  SUPPORTED FORMATS (platform-dependent):
  =======================================
  Audio: MP3, WAV, OGG, AAC, WMA, M4A, FLAC
  Video: MP4, AVI, MOV, WMV, 3GP, M4V, MKV

  COMPONENTS:
  ===========
  1. Media Player (Audio/Video, non-visual):
     - Plays audio files
     - Can play video files but requires a separate video control for display

  2. Media Player Control (Visual, for video):
     - Visual control that displays video
     - Must be parented to a form
     - Has its own integrated media player

  EVENTS SUPPORT:
  ===============
  - OnMediaEnd: Playback completed
  - OnStateChanged: Media state changed (playing, paused, stopped)

  MEDIA STATES:
  =============
  0 = Unavailable - No media loaded or error
  1 = Stopped - Media loaded but not playing
  2 = Playing - Media is currently playing
  3 = Paused - Playback is paused

  USAGE PATTERN (Audio):
  ======================
    ' Create a media player for audio (supports local files and URLs)
    let player# = media_player#()
    media_load#(player#, "https://www.w3schools.com/html/horse.mp3")
    media_volume#(player#, 0.8)
    media_onend#(player#, "OnMusicEnd")
    media_play(player#)

    function OnMusicEnd(sender#)
      println "Music finished!"
    endfunction

  USAGE PATTERN (Video):
  ======================
    let frm# = form#("Video Player", 800, 600)

    ' Create a video control (video requires local files)
    let video# = media_control#(frm#, 10, 10, 640, 480)
    media_ctrl_load#(video#, "video/movie.wmv")
    media_ctrl_onend#(video#, "OnVideoEnd")
    media_ctrl_play(video#)

    form_show(frm#)

    function OnVideoEnd(sender#)
      println "Video finished!"
    endfunction

  IMPORTANT NOTES:
  ================
  - Volume ranges from 0.0 (mute) to 1.0 (maximum)
  - Position and duration are in SECONDS (with decimal fractions)
  - Some formats may not be supported on all platforms
  - Video playback requires a visual control (media_control#)
  - Audio can use either media_player# or media_control#
  - Audio supports both local files and URLs (http/https)
  - Video requires local files (URL streaming not supported)

  Copyright (c) 2024-2026 André Murta
******************************************************************************}

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections,
  FMX.Types, FMX.Forms, FMX.Controls, FMX.Media, FMX.Objects, FMX.Layouts,
  basic, exec, UnitGC, HandleRegistry, GuiUtils, ControlCommon;

type
  {****************************************************************************
    TBasMediaPlayer - Non-visual media player for audio playback

    Wraps TMediaPlayer and provides event bridging to Plan9Basic functions.
  ****************************************************************************}
  TBasMediaPlayer = class
  private
    FMediaPlayer: TMediaPlayer;
    FOnEndFunc: String;
    FOnStateChangedFunc: String;
    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;
    FFileName: String;
    FLastState: TMediaState;
    FTimer: TTimer;  // For state change detection
    FTempFile: String;  // Local path of a temp file downloaded from a URL ('' when local)

    procedure InternalOnTimer(Sender: TObject);
    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
    procedure CleanupTempFile();  // Deletes FTempFile from disk and clears the field

    procedure SetOnEndFunc(const Value: String);
    procedure SetOnStateChangedFunc(const Value: String);

    function GetState(): TMediaState;
    function GetVolume(): Single;
    procedure SetVolume(const Value: Single);
    function GetDuration(): Single;
    function GetPosition(): Single;
    procedure SetPosition(const Value: Single);
  public
    constructor Create();
    destructor Destroy(); override;

    function LoadFromFile(const AFileName: String): Boolean;
    procedure Play();
    procedure Pause();
    procedure Stop();
    procedure Clear();

    property MediaPlayer: TMediaPlayer read FMediaPlayer;
    property FileName: String read FFileName;
    property State: TMediaState read GetState;
    property Volume: Single read GetVolume write SetVolume;
    property Duration: Single read GetDuration;
    property Position: Single read GetPosition write SetPosition;
    property OnEndFunc: String read FOnEndFunc write SetOnEndFunc;
    property OnStateChangedFunc: String read FOnStateChangedFunc write SetOnStateChangedFunc;
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
  end;

  {****************************************************************************
    TBasMediaPlayerControl - Visual media player control for video playback

    Uses a TLayout as a container with an embedded TMediaPlayer.
    The MediaPlayer's rendering surface is connected to a TMediaPlayerControl.
  ****************************************************************************}
  TBasMediaPlayerControl = class(TLayout)
  private
    FMediaPlayerControl: TMediaPlayerControl;
    FMediaPlayer: TMediaPlayer;  // The actual media player - must be created and linked!
    FOnEndFunc: String;
    FOnStateChangedFunc: String;
    FOnClickFunc: String;
    FOnDblClickFunc: String;
    FOnMouseDownFunc: String;
    FOnMouseUpFunc: String;
    FOnMouseMoveFunc: String;
    FOnMouseEnterFunc: String;
    FOnMouseLeaveFunc: String;
    FOnResizeFunc: String;

    FBasicEngine: TBasicEngine;
    FConsoleOutput: TStrings;
    FFileName: String;
    FLastState: TMediaState;
    FTimer: TTimer;  // For state change detection
    FTempFile: String;  // Local path of a temp file downloaded from a URL ('' when local)

    procedure InternalOnTimer(Sender: TObject);
    procedure CleanupTempFile();  // Deletes FTempFile from disk and clears the field
    procedure InternalOnClick(Sender: TObject);
    procedure InternalOnDblClick(Sender: TObject);
    procedure InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure InternalOnMouseEnter(Sender: TObject);
    procedure InternalOnMouseLeave(Sender: TObject);
    procedure InternalOnResize(Sender: TObject);

    procedure ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);

    procedure SetOnEndFunc(const Value: String);
    procedure SetOnStateChangedFunc(const Value: String);
    procedure SetOnClickFunc(const Value: String);
    procedure SetOnDblClickFunc(const Value: String);
    procedure SetOnMouseDownFunc(const Value: String);
    procedure SetOnMouseUpFunc(const Value: String);
    procedure SetOnMouseMoveFunc(const Value: String);
    procedure SetOnMouseEnterFunc(const Value: String);
    procedure SetOnMouseLeaveFunc(const Value: String);
    procedure SetOnResizeFunc(const Value: String);

    function GetCurrentState(): TMediaState;
    function GetVolume(): Single;
    procedure SetVolumeValue(const Value: Single);
    function GetDuration(): Single;
    function GetCurrentPosition(): Single;
    procedure SetCurrentPosition(const Value: Single);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;

    function GetMediaPlayer: TMediaPlayer;
    function LoadFromFile(const AFileName: String): Boolean;
    procedure PlayMedia();
    procedure PauseMedia();
    procedure StopMedia();
    procedure ClearMedia();
    procedure DisconnectEvents();

    property MediaPlayer: TMediaPlayer read GetMediaPlayer;
    property InnerControl: TMediaPlayerControl read FMediaPlayerControl;
    property FileName: String read FFileName;
    property CurrentState: TMediaState read GetCurrentState;
    property VolumeValue: Single read GetVolume write SetVolumeValue;
    property MediaDuration: Single read GetDuration;
    property MediaPosition: Single read GetCurrentPosition write SetCurrentPosition;
    property OnEndFunc: String read FOnEndFunc write SetOnEndFunc;
    property OnStateChangedFunc: String read FOnStateChangedFunc write SetOnStateChangedFunc;
    property OnClickFunc: String read FOnClickFunc write SetOnClickFunc;
    property OnDblClickFunc: String read FOnDblClickFunc write SetOnDblClickFunc;
    property OnMouseDownFunc: String read FOnMouseDownFunc write SetOnMouseDownFunc;
    property OnMouseUpFunc: String read FOnMouseUpFunc write SetOnMouseUpFunc;
    property OnMouseMoveFunc: String read FOnMouseMoveFunc write SetOnMouseMoveFunc;
    property OnMouseEnterFunc: String read FOnMouseEnterFunc write SetOnMouseEnterFunc;
    property OnMouseLeaveFunc: String read FOnMouseLeaveFunc write SetOnMouseLeaveFunc;
    property OnResizeFunc: String read FOnResizeFunc write SetOnResizeFunc;
    property BasicEngine: TBasicEngine read FBasicEngine write FBasicEngine;
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
  end;

procedure RegisterMediaPlayerFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

uses
  UnitUtils, System.Net.HttpClientComponent, System.IOUtils;

const
  MEDIA_GC_TAG = 'BASIC_MEDIA';

  // Media time scale: TMediaTime uses 100-nanosecond intervals
  // 10,000,000 units = 1 second
  MediaTimeScale: Int64 = 10000000;

  ERR_NONE = 0;
  ERR_INVALID_PLAYER = 1;
  ERR_INVALID_CONTROL = 2;
  ERR_INVALID_PARENT = 3;
  ERR_INVALID_VALUE = 4;
  ERR_CREATE_FAILED = 5;
  ERR_LOAD_FAILED = 6;
  ERR_FILE_NOT_FOUND = 7;
  ERR_NOT_LOADED = 8;
  ERR_INVALID_CALLBACK = 9;

  // Align constants (same as other control libraries)

var
  lastError: Integer;
  lastErrorMsg: String;
  ModuleEngine: TBasicEngine;
  ModuleOutput: TStrings;

// -----------------------------------------------------------------------------
// Error Handling
// -----------------------------------------------------------------------------

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

function ValidatePlayer(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_PLAYER, FuncName + ': Nil pointer');
    Exit();
  end;

  try
    if not (IsHandleOf(P, TBasMediaPlayer)) then
    begin
      SetError(ERR_INVALID_PLAYER, FuncName + ': Invalid object type');
      Exit();
    end;
  except
    SetError(ERR_INVALID_PLAYER, FuncName + ': Invalid pointer');
    Exit();
  end;

  Result := True;
end;

function ValidateControl(P: Pointer; const FuncName: String): Boolean;
begin
  Result := False;
  if P = nil then
  begin
    SetError(ERR_INVALID_CONTROL, FuncName + ': Nil pointer');
    Exit();
  end;

  try
    if not (IsHandleOf(P, TBasMediaPlayerControl)) then
    begin
      SetError(ERR_INVALID_CONTROL, FuncName + ': Invalid object type');
      Exit();
    end;
  except
    SetError(ERR_INVALID_CONTROL, FuncName + ': Invalid pointer');
    Exit();
  end;

  Result := True;
end;

function GetParentControl(P: Pointer; const FuncName: String): TFmxObject;
begin
  Result := nil;

  if P = nil then
  begin
    SetError(ERR_INVALID_PARENT, FuncName + ': Nil parent pointer');
    Exit();
  end;

  try
    if not (IsHandleOf(P, TFmxObject)) then
    begin
      SetError(ERR_INVALID_PARENT, FuncName + ': Invalid parent type');
      Exit();
    end;
    Result := TFmxObject(P);
  except
    SetError(ERR_INVALID_PARENT, FuncName + ': Invalid parent pointer');
  end;
end;

function MediaStateToInt(State: TMediaState): Integer;
begin
  case State of
    TMediaState.Unavailable: Result := 0;
    TMediaState.Stopped: Result := 1;
    TMediaState.Playing: Result := 2;
  else
    Result := 0;
  end;
end;

// =============================================================================
// Web Download Helper
// =============================================================================

// Download a media URL to a uniquely-named local temporary file.
// Returns the full path of the saved temp file on success, or '' on failure.
// The caller is responsible for tracking and deleting the file when done.
//
// Design mirrors TGuiUtils.LoadImageFromWeb / TUtils.LoadFromWeb in UnitUtils:
//   httpCli.Get(url, memoryStream) → save stream → return local path
//
function DownloadMediaToTemp(const AURL: String): String;
var
  ms: TMemoryStream;
  httpCli: TNetHTTPClient;
  Ext: String;
  QPos: Integer;
  TempName, TempFile: String;
begin
  Result := '';

  // --- Derive the file extension from the URL path (strip query/fragment) ---
  Ext := ExtractFileExt(AURL);
  QPos := Ext.IndexOf('?');
  if QPos >= 0 then Ext := Ext.Substring(0, QPos);
  QPos := Ext.IndexOf('#');
  if QPos >= 0 then Ext := Ext.Substring(0, QPos);
  if Ext = '' then Ext := '.tmp';

  // --- Build a collision-resistant temp file name ---
  TempName := Format('p9b_media_%s_%d%s', [FormatDateTime('yyyymmddhhnnsszzz', Now), Random(99999), Ext]);
  TempFile := TPath.Combine(TPath.GetTempPath, TempName);

  // --- Download using the same pattern as TGuiUtils.LoadImageFromWeb ---
  httpCli := TNetHTTPClient.Create(nil);
  ms := TMemoryStream.Create();
  try
    try
      httpCli.Get(AURL, ms);
      ms.Position := 0;
      ms.SaveToFile(TempFile);  // Save binary stream directly — no encoding needed
      Result := TempFile;
    except
      Result := '';  // Network error, bad URL, or I/O failure
    end;
  finally
    ms.Free();
    httpCli.Free();
  end;
end;

// =============================================================================
// TBasMediaPlayer Implementation
// =============================================================================

procedure TBasMediaPlayer.CleanupTempFile();
begin
  // Delete the temp file that was downloaded from a URL, then clear the field.
  // Called on Destroy and before every new load so stale temp files don't accumulate.
  if (FTempFile <> '') and TFile.Exists(FTempFile) then
  begin
    try
      TFile.Delete(FTempFile);
    except
      // Silently ignore — OS will eventually purge the temp directory
    end;
  end;
  FTempFile := '';
end;

constructor TBasMediaPlayer.Create();
begin
  inherited Create();
  RegisterHandle(Self);
  FMediaPlayer := TMediaPlayer.Create(nil);
  FOnEndFunc := '';
  FOnStateChangedFunc := '';
  FBasicEngine := nil;
  FConsoleOutput := nil;
  FFileName := '';
  FTempFile := '';
  FLastState := TMediaState.Unavailable;

  // Create timer for state change detection
  FTimer := TTimer.Create(nil);
  FTimer.Interval := 100;  // Check every 100ms
  FTimer.OnTimer := InternalOnTimer;
  FTimer.Enabled := True;
end;

destructor TBasMediaPlayer.Destroy();
begin
  UnregisterHandle(Self);
  FTimer.Enabled := False;
  FTimer.Free();
  FMediaPlayer.Free();
  CleanupTempFile();  // Delete temp file if this player loaded audio from a URL
  inherited Destroy();
end;

procedure TBasMediaPlayer.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'MediaPlayer');
end;

procedure TBasMediaPlayer.InternalOnTimer(Sender: TObject);
var
  CurrentState: TMediaState;
  Args: array[0..1] of TAsmData;
  Signature: String;
begin
  if not Assigned(FMediaPlayer) then
    Exit();

  CurrentState := FMediaPlayer.State;

  // Check for state change
  if CurrentState <> FLastState then
  begin
    // Fire OnStateChanged event
    if FOnStateChangedFunc <> '' then
    begin
      Signature := LowerCase(FOnStateChangedFunc) + '@#n';
      Args[0].p := Pointer(Self);
      Args[0].n := 0;
      Args[0].s := '';
      Args[1].n := MediaStateToInt(CurrentState);
      Args[1].p := nil;
      Args[1].s := '';
      ExecuteCallback(Signature, Args);
    end;

    // Check for media end (transition from Playing to Stopped)
    if (FLastState = TMediaState.Playing) and (CurrentState = TMediaState.Stopped) then
    begin
      if FOnEndFunc <> '' then
      begin
        Signature := LowerCase(FOnEndFunc) + '@#';
        Args[0].p := Pointer(Self);
        Args[0].n := 0;
        Args[0].s := '';
        ExecuteCallback(Signature, [Args[0]]);
      end;
    end;

    FLastState := CurrentState;
  end;
end;

procedure TBasMediaPlayer.SetOnEndFunc(const Value: String);
begin
  FOnEndFunc := Value;
end;

procedure TBasMediaPlayer.SetOnStateChangedFunc(const Value: String);
begin
  FOnStateChangedFunc := Value;
end;

function TBasMediaPlayer.GetState(): TMediaState;
begin
  if Assigned(FMediaPlayer) then
    Result := FMediaPlayer.State
  else
    Result := TMediaState.Unavailable;
end;

function TBasMediaPlayer.GetVolume(): Single;
begin
  if Assigned(FMediaPlayer) then
    Result := FMediaPlayer.Volume
  else
    Result := 0;
end;

procedure TBasMediaPlayer.SetVolume(const Value: Single);
begin
  if Assigned(FMediaPlayer) then
  begin
    if Value < 0 then
      FMediaPlayer.Volume := 0
    else if Value > 1 then
      FMediaPlayer.Volume := 1
    else
      FMediaPlayer.Volume := Value;
  end;
end;

function TBasMediaPlayer.GetDuration(): Single;
begin
  if Assigned(FMediaPlayer) then
    Result := FMediaPlayer.Duration / MediaTimeScale
  else
    Result := 0;
end;

function TBasMediaPlayer.GetPosition(): Single;
begin
  if Assigned(FMediaPlayer) then
    Result := FMediaPlayer.CurrentTime / MediaTimeScale
  else
    Result := 0;
end;

procedure TBasMediaPlayer.SetPosition(const Value: Single);
var
  NewTime: Int64;
  MaxTime: Int64;
begin
  if Assigned(FMediaPlayer) then
  begin
    MaxTime := FMediaPlayer.Duration;
    if Value < 0 then
      NewTime := 0
    else if Value * MediaTimeScale > MaxTime then
      NewTime := MaxTime
    else
      NewTime := Trunc(Value * MediaTimeScale);
    FMediaPlayer.CurrentTime := NewTime;
  end;
end;

function TBasMediaPlayer.LoadFromFile(const AFileName: String): Boolean;
begin
  Result := False;
  if not Assigned(FMediaPlayer) then
    Exit();

  try
    FMediaPlayer.Clear();
    FMediaPlayer.FileName := AFileName;
    FFileName := AFileName;
    FLastState := FMediaPlayer.State;
    // Note: State may remain Unavailable until Play is called on some platforms
    // We consider load successful if no exception was raised
    Result := True;
  except
    Result := False;
  end;
end;

procedure TBasMediaPlayer.Play();
begin
  if Assigned(FMediaPlayer) then
    FMediaPlayer.Play();
end;

procedure TBasMediaPlayer.Pause();
begin
  if Assigned(FMediaPlayer) then
    FMediaPlayer.Stop();  // Note: TMediaPlayer doesn't have Pause, only Stop
end;

procedure TBasMediaPlayer.Stop();
begin
  if Assigned(FMediaPlayer) then
  begin
    // On Android, TAndroidMedia.DoStop calls android.media.MediaPlayer.pause().
    // pause() is only valid from the 'Started' state.  Calling it while the
    // player is in 'Prepared' state (freshly loaded, never played) throws
    // IllegalStateException and moves the player permanently into 'Error' state,
    // after which Play() also throws and the player is silently dead.
    //
    // On Windows, DoStop calls DirectShow StopWhenReady() which is a safe no-op
    // on an idle graph, so the issue does not manifest there.
    //
    // Guard: only invoke the underlying Stop (= pause) when the player is
    // actually running.  seekTo(0) is valid from Prepared, Paused, and
    // PlaybackCompleted states, so we always reset the position regardless.
    if FMediaPlayer.State = TMediaState.Playing then
      FMediaPlayer.Stop();
    FMediaPlayer.CurrentTime := 0;
  end;
end;

procedure TBasMediaPlayer.Clear();
begin
  if Assigned(FMediaPlayer) then
  begin
    FMediaPlayer.Clear();
    FFileName := '';
    FLastState := TMediaState.Unavailable;
  end;
end;

// =============================================================================
// TBasMediaPlayerControl Implementation
// =============================================================================

procedure TBasMediaPlayerControl.CleanupTempFile();
begin
  // Delete the temp file that was downloaded from a URL, then clear the field.
  // Called on Destroy and before every new load so stale temp files don't accumulate.
  if (FTempFile <> '') and TFile.Exists(FTempFile) then
  begin
    try
      TFile.Delete(FTempFile);
    except
      // Silently ignore — OS will eventually purge the temp directory
    end;
  end;
  FTempFile := '';
end;

constructor TBasMediaPlayerControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  RegisterHandle(Self);

  // Create the inner media player control that will render video
  FMediaPlayerControl := TMediaPlayerControl.Create(Self);
  FMediaPlayerControl.Parent := Self;
  FMediaPlayerControl.Align := TAlignLayout.Client;
  FMediaPlayerControl.HitTest := False;  // Let parent handle mouse events

  // Create the actual TMediaPlayer and link it to the control
  // THIS IS ESSENTIAL - TMediaPlayerControl.MediaPlayer is nil until assigned!
  // Use nil owner like in TBasMediaPlayer (which works)
  FMediaPlayer := TMediaPlayer.Create(nil);
  FMediaPlayerControl.MediaPlayer := FMediaPlayer;

  FOnEndFunc := '';
  FOnStateChangedFunc := '';
  FOnClickFunc := '';
  FOnDblClickFunc := '';
  FOnMouseDownFunc := '';
  FOnMouseUpFunc := '';
  FOnMouseMoveFunc := '';
  FOnMouseEnterFunc := '';
  FOnMouseLeaveFunc := '';
  FOnResizeFunc := '';

  FBasicEngine := nil;
  FConsoleOutput := nil;
  FFileName := '';
  FTempFile := '';
  FLastState := TMediaState.Unavailable;

  // Create timer for state change detection
  FTimer := TTimer.Create(Self);
  FTimer.Interval := 100;
  FTimer.OnTimer := InternalOnTimer;
  FTimer.Enabled := True;

  // Connect default events to Self (the TLayout)
  Self.OnClick := InternalOnClick;
  Self.OnDblClick := InternalOnDblClick;
  Self.OnMouseDown := InternalOnMouseDown;
  Self.OnMouseUp := InternalOnMouseUp;
  Self.OnMouseMove := InternalOnMouseMove;
  Self.OnMouseEnter := InternalOnMouseEnter;
  Self.OnMouseLeave := InternalOnMouseLeave;
  Self.OnResize := InternalOnResize;
end;

destructor TBasMediaPlayerControl.Destroy();
begin
  UnregisterHandle(Self);
  DisconnectEvents();
  FTimer.Enabled := False;
  // Unlink before freeing
  if Assigned(FMediaPlayerControl) then
    FMediaPlayerControl.MediaPlayer := nil;
  FMediaPlayer.Free();
  CleanupTempFile();  // Delete temp file if this control loaded media from a URL
  // FTimer and FMediaPlayerControl will be freed automatically as owned by Self
  inherited Destroy();
end;

function TBasMediaPlayerControl.GetMediaPlayer: TMediaPlayer;
begin
  Result := FMediaPlayer;
end;

procedure TBasMediaPlayerControl.DisconnectEvents();
begin
  FOnEndFunc := '';
  FOnStateChangedFunc := '';
  FOnClickFunc := '';
  FOnDblClickFunc := '';
  FOnMouseDownFunc := '';
  FOnMouseUpFunc := '';
  FOnMouseMoveFunc := '';
  FOnMouseEnterFunc := '';
  FOnMouseLeaveFunc := '';
  FOnResizeFunc := '';
  OnClick := nil;
  OnDblClick := nil;
  OnMouseDown := nil;
  OnMouseUp := nil;
  OnMouseMove := nil;
  OnMouseEnter := nil;
  OnMouseLeave := nil;
  OnResize := nil;
end;

procedure TBasMediaPlayerControl.ExecuteCallback(const FuncSignature: String; const Args: array of TAsmData);
begin
  ControlCommon.RunCallback(FBasicEngine, FConsoleOutput,
                            FuncSignature, Args, 'MediaPlayerControl');
end;

procedure TBasMediaPlayerControl.InternalOnTimer(Sender: TObject);
var
  CurrentState: TMediaState;
  Args: array[0..1] of TAsmData;
  Signature: String;
begin
  CurrentState := FMediaPlayer.State;

  // Check for state change
  if CurrentState <> FLastState then
  begin
    // Fire OnStateChanged event
    if FOnStateChangedFunc <> '' then
    begin
      Signature := LowerCase(FOnStateChangedFunc) + '@#n';
      Args[0].p := Pointer(Self);
      Args[0].n := 0;
      Args[0].s := '';
      Args[1].n := MediaStateToInt(CurrentState);
      Args[1].p := nil;
      Args[1].s := '';
      ExecuteCallback(Signature, Args);
    end;

    // Check for media end (transition from Playing to Stopped)
    if (FLastState = TMediaState.Playing) and (CurrentState = TMediaState.Stopped) then
    begin
      if FOnEndFunc <> '' then
      begin
        Signature := LowerCase(FOnEndFunc) + '@#';
        Args[0].p := Pointer(Self);
        Args[0].n := 0;
        Args[0].s := '';
        ExecuteCallback(Signature, [Args[0]]);
      end;
    end;

    FLastState := CurrentState;
  end;
end;

procedure TBasMediaPlayerControl.InternalOnClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnClickFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnClickFunc) + '@#', Args);
end;

procedure TBasMediaPlayerControl.InternalOnDblClick(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnDblClickFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnDblClickFunc) + '@#', Args);
end;

procedure TBasMediaPlayerControl.InternalOnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasMediaPlayerControl.InternalOnMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
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

procedure TBasMediaPlayerControl.InternalOnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
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

procedure TBasMediaPlayerControl.InternalOnMouseEnter(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseEnterFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseEnterFunc) + '@#', Args);
end;

procedure TBasMediaPlayerControl.InternalOnMouseLeave(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnMouseLeaveFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnMouseLeaveFunc) + '@#', Args);
end;

procedure TBasMediaPlayerControl.InternalOnResize(Sender: TObject);
var
  Args: array[0..0] of TAsmData;
begin
  if FOnResizeFunc = '' then Exit();
  Args[0].p := Pointer(Self);
  Args[0].n := 0;
  Args[0].s := '';
  ExecuteCallback(LowerCase(FOnResizeFunc) + '@#', Args);
end;

procedure TBasMediaPlayerControl.SetOnEndFunc(const Value: String);
begin
  FOnEndFunc := Value;
end;

procedure TBasMediaPlayerControl.SetOnStateChangedFunc(const Value: String);
begin
  FOnStateChangedFunc := Value;
end;

procedure TBasMediaPlayerControl.SetOnClickFunc(const Value: String);
begin
  ControlCommon.BindClick(Self, Value, FOnClickFunc, InternalOnClick);
end;

procedure TBasMediaPlayerControl.SetOnDblClickFunc(const Value: String);
begin
  ControlCommon.BindDblClick(Self, Value, FOnDblClickFunc, InternalOnDblClick);
end;

procedure TBasMediaPlayerControl.SetOnMouseDownFunc(const Value: String);
begin
  ControlCommon.BindMouseDown(Self, Value, FOnMouseDownFunc, InternalOnMouseDown);
end;

procedure TBasMediaPlayerControl.SetOnMouseUpFunc(const Value: String);
begin
  ControlCommon.BindMouseUp(Self, Value, FOnMouseUpFunc, InternalOnMouseUp);
end;

procedure TBasMediaPlayerControl.SetOnMouseMoveFunc(const Value: String);
begin
  ControlCommon.BindMouseMove(Self, Value, FOnMouseMoveFunc, InternalOnMouseMove);
end;

procedure TBasMediaPlayerControl.SetOnMouseEnterFunc(const Value: String);
begin
  ControlCommon.BindMouseEnter(Self, Value, FOnMouseEnterFunc, InternalOnMouseEnter);
end;

procedure TBasMediaPlayerControl.SetOnMouseLeaveFunc(const Value: String);
begin
  ControlCommon.BindMouseLeave(Self, Value, FOnMouseLeaveFunc, InternalOnMouseLeave);
end;

procedure TBasMediaPlayerControl.SetOnResizeFunc(const Value: String);
begin
  ControlCommon.BindResize(Self, Value, FOnResizeFunc, InternalOnResize);
end;

function TBasMediaPlayerControl.GetCurrentState(): TMediaState;
begin
  Result := FMediaPlayer.State;
end;

function TBasMediaPlayerControl.GetVolume(): Single;
begin
  Result := FMediaPlayer.Volume;
end;

procedure TBasMediaPlayerControl.SetVolumeValue(const Value: Single);
begin
  if Value < 0 then
    FMediaPlayer.Volume := 0
  else if Value > 1 then
    FMediaPlayer.Volume := 1
  else
    FMediaPlayer.Volume := Value;
end;

function TBasMediaPlayerControl.GetDuration(): Single;
begin
  Result := FMediaPlayer.Duration / MediaTimeScale;
end;

function TBasMediaPlayerControl.GetCurrentPosition(): Single;
begin
  Result := FMediaPlayer.CurrentTime / MediaTimeScale;
end;

procedure TBasMediaPlayerControl.SetCurrentPosition(const Value: Single);
var
  NewTime: Int64;
  MaxTime: Int64;
begin
  MaxTime := FMediaPlayer.Duration;
  if Value < 0 then
    NewTime := 0
  else if Value * MediaTimeScale > MaxTime then
    NewTime := MaxTime
  else
    NewTime := Trunc(Value * MediaTimeScale);
  FMediaPlayer.CurrentTime := NewTime;
end;

function TBasMediaPlayerControl.LoadFromFile(const AFileName: String): Boolean;
begin
  //Result := False;
  try
    FMediaPlayer.FileName := AFileName;
    FFileName := AFileName;
    FLastState := FMediaPlayer.State;
    Result := True;
  except
    Result := False;
  end;
end;

procedure TBasMediaPlayerControl.PlayMedia();
begin
  FMediaPlayer.Play();
end;

procedure TBasMediaPlayerControl.PauseMedia();
begin
  // Same Android guard as TBasMediaPlayer.Stop: pause() only valid from Started.
  if FMediaPlayer.State = TMediaState.Playing then
    FMediaPlayer.Stop();
end;

procedure TBasMediaPlayerControl.StopMedia();
begin
  if FMediaPlayer.State = TMediaState.Playing then
    FMediaPlayer.Stop();
  FMediaPlayer.CurrentTime := 0;
end;

procedure TBasMediaPlayerControl.ClearMedia();
begin
  FMediaPlayer.Clear();
  FFileName := '';
  FLastState := TMediaState.Unavailable;
end;

// =============================================================================
// Library Functions - Error Handling
// =============================================================================

// media_error@ - Get last error code
function n_media_error(var Args: array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

// media_errormsg$@ - Get last error message
function s_media_errormsg(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

// media_strerror$@n - Get error message for code
function s_media_strerror(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  case Trunc(Args[0].n) of
    ERR_NONE: Result.s := 'No error';
    ERR_INVALID_PLAYER: Result.s := 'Invalid media player';
    ERR_INVALID_CONTROL: Result.s := 'Invalid media control';
    ERR_INVALID_PARENT: Result.s := 'Invalid parent';
    ERR_INVALID_VALUE: Result.s := 'Invalid value';
    ERR_CREATE_FAILED: Result.s := 'Failed to create media player';
    ERR_LOAD_FAILED: Result.s := 'Failed to load media file';
    ERR_FILE_NOT_FOUND: Result.s := 'Media file not found';
    ERR_NOT_LOADED: Result.s := 'No media loaded';
    ERR_INVALID_CALLBACK: Result.s := 'Invalid callback function';
  else
    Result.s := 'Unknown error';
  end;
end;

// media_clearerror@ - Clear error state
function n_media_clearerror(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

// =============================================================================
// Library Functions - Non-Visual Media Player (Audio)
// =============================================================================

// media_player#@ - Create a new media player
function p_media_player(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Player: TBasMediaPlayer;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    Player := TBasMediaPlayer.Create();
    //The only object here with no place in a form tree: TBasMediaPlayer is a
    //plain TObject created without a parent, so there is nothing to walk up.
    //It keeps the module-level engine, and is the one exception to the
    //parent-chain rule the other libraries follow.
    Player.BasicEngine := ModuleEngine;
    Player.ConsoleOutput := ModuleOutput;
    GC.Add(Player, MEDIA_GC_TAG);
    Result.p := Player;
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'media_player#: ' + E.Message);
  end;
end;

// media_free@# - Free a media player
function n_media_free(var Args: array of TAsmData): TAsmData;
var
  Player: TBasMediaPlayer;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_free') then
    Exit();

  try
    Player := TBasMediaPlayer(Args[0].p);
    if GC.Contains(Player) then
      GC.Release(Player);
    Player.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PLAYER, 'media_free: ' + E.Message);
  end;
end;

// media_load#@#$ - Load a media file (local path or http/https URL)
//
// URL handling: TMediaPlayer.FileName does not support HTTP streaming on all
// platforms (notably Windows and Linux). We therefore download the remote file
// to a uniquely-named local temp file first, then point TMediaPlayer at that
// local copy.  The temp file is tracked in FTempFile and deleted automatically
// when the player is freed (Destroy) or when a new source is loaded.
function p_media_load(var Args: array of TAsmData): TAsmData;
var
  Player: TBasMediaPlayer;
  FileName: String;
  IsURL: Boolean;
  LocalFile: String;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_load#') then
    Exit();

  Player   := TBasMediaPlayer(Args[0].p);
  FileName := Args[1].s;

  IsURL := (Pos('http://',  LowerCase(FileName)) = 1) or (Pos('https://', LowerCase(FileName)) = 1);
  if IsURL then
  begin
    // --- Remote source: download to a local temp file first ---
    LocalFile := DownloadMediaToTemp(FileName);
    if LocalFile = '' then
    begin
      SetError(ERR_LOAD_FAILED, 'media_load#: Failed to download URL: ' + FileName);
      Exit();
    end;

    Player.CleanupTempFile();              // Remove the previous temp file (if any)

    if Player.LoadFromFile(LocalFile) then
      Player.FTempFile := LocalFile      // Track for cleanup on free or next load
    else
    begin
      TFile.Delete(LocalFile);           // Download OK but codec rejected the file
      SetError(ERR_LOAD_FAILED, 'media_load#: Failed to open downloaded file from: ' + FileName);
    end;
  end
  else
  begin
    // --- Local source: existing behaviour ---
    if not FileExists(FileName) then
    begin
      SetError(ERR_FILE_NOT_FOUND, 'media_load#: File not found: ' + FileName);
      Exit();
    end;

    Player.CleanupTempFile();              // Remove cached temp file from a previous URL load

    if not Player.LoadFromFile(FileName) then
      SetError(ERR_LOAD_FAILED, 'media_load#: Failed to load: ' + FileName);
  end;
end;

// media_play@# - Start playback
function n_media_play(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_play') then
    Exit();

  try
    TBasMediaPlayer(Args[0].p).Play();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PLAYER, 'media_play: ' + E.Message);
  end;
end;

// media_pause@# - Pause playback
function n_media_pause(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_pause') then
    Exit();

  try
    TBasMediaPlayer(Args[0].p).Pause();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PLAYER, 'media_pause: ' + E.Message);
  end;
end;

// media_stop@# - Stop playback and reset position
function n_media_stop(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_stop') then
    Exit();

  try
    TBasMediaPlayer(Args[0].p).Stop();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PLAYER, 'media_stop: ' + E.Message);
  end;
end;

// media_clear@# - Clear loaded media
function n_media_clear(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_clear') then
    Exit();

  try
    TBasMediaPlayer(Args[0].p).Clear();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_PLAYER, 'media_clear: ' + E.Message);
  end;
end;

// media_state@# - Get playback state (0=unavailable, 1=stopped, 2=playing, 3=paused)
function n_media_state(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_state') then
    Exit();

  Result.n := MediaStateToInt(TBasMediaPlayer(Args[0].p).State);
end;

// media_volume#@#n - Set volume (0.0 to 1.0)
function p_media_volume_set(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_volume#') then
    Exit();

  TBasMediaPlayer(Args[0].p).Volume := Args[1].n;
end;

// media_volume@# - Get volume
function n_media_volume_get(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_volume') then
    Exit();

  Result.n := TBasMediaPlayer(Args[0].p).Volume;
end;

// media_duration@# - Get duration in seconds
function n_media_duration(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_duration') then
    Exit();

  Result.n := TBasMediaPlayer(Args[0].p).Duration;
end;

// media_position#@#n - Set position in seconds
function p_media_position_set(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_position#') then
    Exit();

  TBasMediaPlayer(Args[0].p).Position := Args[1].n;
end;

// media_position@# - Get position in seconds
function n_media_position_get(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_position') then
    Exit();

  Result.n := TBasMediaPlayer(Args[0].p).Position;
end;

// media_filename$@# - Get loaded filename
function s_media_filename(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_filename$') then
    Exit();

  Result.s := TBasMediaPlayer(Args[0].p).FileName;
end;

// media_isplaying@# - Check if playing
function n_media_isplaying(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_isplaying') then
    Exit();

  if TBasMediaPlayer(Args[0].p).State = TMediaState.Playing then
    Result.n := 1;
end;

// media_onend#@#$ - Set OnEnd callback
function p_media_onend(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_onend#') then
    Exit();

  TBasMediaPlayer(Args[0].p).OnEndFunc := Args[1].s;
end;

// media_onstatechanged#@#$ - Set OnStateChanged callback
function p_media_onstatechanged(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidatePlayer(Args[0].p, 'media_onstatechanged#') then
    Exit();

  TBasMediaPlayer(Args[0].p).OnStateChangedFunc := Args[1].s;
end;

// =============================================================================
// Library Functions - Visual Media Control (Video)
// =============================================================================

// media_control#@#nnnn - Create a media player control
function p_media_control(var Args: array of TAsmData): TAsmData;
var
  Eng: TBasicEngine;
  Outp: TStrings;
  Parent: TFmxObject;
  Control: TBasMediaPlayerControl;
  X, Y, W, H: Single;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  Parent := GetParentControl(Args[0].p, 'media_control#');
  if Parent = nil then
    Exit();

  X := Args[1].n;
  Y := Args[2].n;
  W := Args[3].n;
  H := Args[4].n;

  try
    // Pass Parent as Owner - required for MediaPlayer to initialize properly
    Control := TBasMediaPlayerControl.Create(TComponent(Parent));
    Control.Parent := Parent;
    Control.Position.X := X;
    Control.Position.Y := Y;
    Control.Width := W;
    Control.Height := H;
    //The only object here with no place in a form tree: TBasMediaPlayer is a
    //plain TObject created without a parent, so there is nothing to walk up.
    //It keeps the module-level engine, and is the one exception to the
    //parent-chain rule the other libraries follow.
    Control.BasicEngine := ModuleEngine;
    Control.ConsoleOutput := ModuleOutput;
    Result.p := Control;
  except
    on E: Exception do
      SetError(ERR_CREATE_FAILED, 'media_control#: ' + E.Message);
  end;
end;

// media_ctrl_free@# - Free a media control
function n_media_ctrl_free(var Args: array of TAsmData): TAsmData;
var
  Control: TBasMediaPlayerControl;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_free') then
    Exit();

  try
    Control := TBasMediaPlayerControl(Args[0].p);
    Control.DisconnectEvents();
    Control.Free();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_CONTROL, 'media_ctrl_free: ' + E.Message);
  end;
end;

// media_ctrl_load#@#$ - Load a media file into a visual control (local path or http/https URL)
//
// URL handling mirrors p_media_load: the remote file is downloaded to a local
// temp file first, because TMediaPlayerControl wraps TMediaPlayer which does
// not support HTTP streaming on all platforms.  The temp file is tracked in
// FTempFile and deleted automatically when the control is freed or reloaded.
function p_media_ctrl_load(var Args: array of TAsmData): TAsmData;
var
  Control: TBasMediaPlayerControl;
  FileName: String;
  IsURL: Boolean;
  LocalFile: String;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_load#') then
    Exit();

  Control  := TBasMediaPlayerControl(Args[0].p);
  FileName := Args[1].s;

  IsURL := (Pos('http://',  LowerCase(FileName)) = 1) or (Pos('https://', LowerCase(FileName)) = 1);
  if IsURL then
  begin
    // --- Remote source: download to a local temp file first ---
    LocalFile := DownloadMediaToTemp(FileName);
    if LocalFile = '' then
    begin
      SetError(ERR_LOAD_FAILED, 'media_ctrl_load#: Failed to download URL: ' + FileName);
      Exit();
    end;

    Control.CleanupTempFile();             // Remove the previous temp file (if any)

    try
      if Control.LoadFromFile(LocalFile) then
        Control.FTempFile := LocalFile   // Track for cleanup on free or next load
      else
      begin
        TFile.Delete(LocalFile);         // Download OK but codec rejected the file
        SetError(ERR_LOAD_FAILED, 'media_ctrl_load#: Failed to open downloaded file from: ' + FileName);
      end;
    except
      on E: Exception do
      begin
        TFile.Delete(LocalFile);
        SetError(ERR_LOAD_FAILED, 'media_ctrl_load#: Exception loading downloaded file from: ' + FileName + ' (' + E.Message + ')');
      end;
    end;
  end
  else
  begin
    // --- Local source: existing behaviour ---
    if not FileExists(FileName) then
    begin
      SetError(ERR_FILE_NOT_FOUND, 'media_ctrl_load#: File not found: ' + FileName);
      Exit();
    end;

    Control.CleanupTempFile();             // Remove cached temp file from a previous URL load

    try
      if not Control.LoadFromFile(FileName) then
        SetError(ERR_LOAD_FAILED, 'media_ctrl_load#: Failed to load: ' + FileName);
    except
      on E: Exception do
        SetError(ERR_LOAD_FAILED, 'media_ctrl_load#: Exception: ' + E.Message);
    end;
  end;
end;

// media_ctrl_play@# - Start playback
function n_media_ctrl_play(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_play') then
    Exit();

  try
    TBasMediaPlayerControl(Args[0].p).PlayMedia();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_CONTROL, 'media_ctrl_play: ' + E.Message);
  end;
end;

// media_ctrl_pause@# - Pause playback
function n_media_ctrl_pause(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_pause') then
    Exit();

  try
    TBasMediaPlayerControl(Args[0].p).PauseMedia();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_CONTROL, 'media_ctrl_pause: ' + E.Message);
  end;
end;

// media_ctrl_stop@# - Stop playback
function n_media_ctrl_stop(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_stop') then
    Exit();

  try
    TBasMediaPlayerControl(Args[0].p).StopMedia();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_CONTROL, 'media_ctrl_stop: ' + E.Message);
  end;
end;

// media_ctrl_clear@# - Clear loaded media
function n_media_ctrl_clear(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_clear') then
    Exit();

  try
    TBasMediaPlayerControl(Args[0].p).ClearMedia();
    Result.n := 1;
  except
    on E: Exception do
      SetError(ERR_INVALID_CONTROL, 'media_ctrl_clear: ' + E.Message);
  end;
end;

// media_ctrl_state@# - Get playback state
function n_media_ctrl_state(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_state') then
    Exit();

  Result.n := MediaStateToInt(TBasMediaPlayerControl(Args[0].p).CurrentState);
end;

// media_ctrl_volume#@#n - Set volume
function p_media_ctrl_volume_set(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_volume#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).VolumeValue := Args[1].n;
end;

// media_ctrl_volume@# - Get volume
function n_media_ctrl_volume_get(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_volume') then
    Exit();

  Result.n := TBasMediaPlayerControl(Args[0].p).VolumeValue;
end;

// media_ctrl_duration@# - Get duration in seconds
function n_media_ctrl_duration(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_duration') then
    Exit();

  Result.n := TBasMediaPlayerControl(Args[0].p).MediaDuration;
end;

// media_ctrl_position#@#n - Set position in seconds
function p_media_ctrl_position_set(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_position#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).MediaPosition := Args[1].n;
end;

// media_ctrl_position@# - Get position in seconds
function n_media_ctrl_position_get(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_position') then
    Exit();

  Result.n := TBasMediaPlayerControl(Args[0].p).MediaPosition;
end;

// media_ctrl_filename$@# - Get loaded filename
function s_media_ctrl_filename(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_filename$') then
    Exit();

  Result.s := TBasMediaPlayerControl(Args[0].p).FileName;
end;

// media_ctrl_isplaying@# - Check if playing
function n_media_ctrl_isplaying(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_isplaying') then
    Exit();

  if TBasMediaPlayerControl(Args[0].p).CurrentState = TMediaState.Playing then
    Result.n := 1;
end;

// media_ctrl_hasplayer@# - Check if MediaPlayer is initialized (debug)
function n_media_ctrl_hasplayer(var Args: array of TAsmData): TAsmData;
var
  Control: TBasMediaPlayerControl;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_hasplayer') then
    Exit();

  Control := TBasMediaPlayerControl(Args[0].p);
  if Assigned(Control.MediaPlayer) then
    Result.n := 1;
end;

// =============================================================================
// Visual Control Properties
// =============================================================================

// media_ctrl_pos#@#nn - Set position
function p_media_ctrl_pos(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_pos#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).Position.X := Args[1].n;
  TBasMediaPlayerControl(Args[0].p).Position.Y := Args[2].n;
end;

// media_ctrl_size#@#nn - Set size
function p_media_ctrl_size(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_size#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).Width := Args[1].n;
  TBasMediaPlayerControl(Args[0].p).Height := Args[2].n;
end;

// media_ctrl_bounds#@#nnnn - Set bounds
function p_media_ctrl_bounds(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_bounds#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).Position.X := Args[1].n;
  TBasMediaPlayerControl(Args[0].p).Position.Y := Args[2].n;
  TBasMediaPlayerControl(Args[0].p).Width := Args[3].n;
  TBasMediaPlayerControl(Args[0].p).Height := Args[4].n;
end;

// media_ctrl_x@# - Get X position
function n_media_ctrl_x(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_x') then
    Exit();

  Result.n := TBasMediaPlayerControl(Args[0].p).Position.X;
end;

// media_ctrl_y@# - Get Y position
function n_media_ctrl_y(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_y') then
    Exit();

  Result.n := TBasMediaPlayerControl(Args[0].p).Position.Y;
end;

// media_ctrl_width@# - Get width
function n_media_ctrl_width(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_width') then
    Exit();

  Result.n := TBasMediaPlayerControl(Args[0].p).Width;
end;

// media_ctrl_height@# - Get height
function n_media_ctrl_height(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_height') then
    Exit();

  Result.n := TBasMediaPlayerControl(Args[0].p).Height;
end;

// media_ctrl_visible#@#n - Set visibility
function p_media_ctrl_visible(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_visible#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).Visible := (Trunc(Args[1].n) <> 0);
end;

// media_ctrl_visible@# - Get visibility
function n_media_ctrl_visible_get(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_visible') then
    Exit();

  if TBasMediaPlayerControl(Args[0].p).Visible then
    Result.n := 1;
end;

// media_ctrl_enabled#@#n - Set enabled
function p_media_ctrl_enabled(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_enabled#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).Enabled := (Trunc(Args[1].n) <> 0);
end;

// media_ctrl_enabled@# - Get enabled
function n_media_ctrl_enabled_get(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_enabled') then
    Exit();

  if TBasMediaPlayerControl(Args[0].p).Enabled then
    Result.n := 1;
end;

// media_ctrl_align#@#n - Set alignment
function p_media_ctrl_align(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_align#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).Align := AlignFromInt(Trunc(Args[1].n));
end;

// media_ctrl_align@# - Get alignment
function n_media_ctrl_align_get(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_align') then
    Exit();

  Result.n := AlignToInt(TBasMediaPlayerControl(Args[0].p).Align);
end;

// =============================================================================
// Event Callbacks for Media Control
// =============================================================================

// media_ctrl_onend#@#$ - Set OnEnd callback
function p_media_ctrl_onend(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_onend#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).OnEndFunc := Args[1].s;
end;

// media_ctrl_onstatechanged#@#$ - Set OnStateChanged callback
function p_media_ctrl_onstatechanged(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_onstatechanged#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).OnStateChangedFunc := Args[1].s;
end;

// media_ctrl_onclick#@#$ - Set OnClick callback
function p_media_ctrl_onclick(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_onclick#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).OnClickFunc := Args[1].s;
end;

// media_ctrl_ondblclick#@#$ - Set OnDblClick callback
function p_media_ctrl_ondblclick(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_ondblclick#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).OnDblClickFunc := Args[1].s;
end;

// media_ctrl_onmousedown#@#$ - Set OnMouseDown callback
function p_media_ctrl_onmousedown(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_onmousedown#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).OnMouseDownFunc := Args[1].s;
end;

// media_ctrl_onmouseup#@#$ - Set OnMouseUp callback
function p_media_ctrl_onmouseup(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_onmouseup#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).OnMouseUpFunc := Args[1].s;
end;

// media_ctrl_onmousemove#@#$ - Set OnMouseMove callback
function p_media_ctrl_onmousemove(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_onmousemove#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).OnMouseMoveFunc := Args[1].s;
end;

// media_ctrl_onresize#@#$ - Set OnResize callback
function p_media_ctrl_onresize(var Args: array of TAsmData): TAsmData;
begin
  ClearError();
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  if not ValidateControl(Args[0].p, 'media_ctrl_onresize#') then
    Exit();

  TBasMediaPlayerControl(Args[0].p).OnResizeFunc := Args[1].s;
end;

// =============================================================================
// Registration
// =============================================================================

procedure RegisterMediaPlayerFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  ModuleEngine := Eng;
  ModuleOutput := OutP;

  Fn.FarCall := True;
  //FireMonkey, so these run on the UI thread when the VM does not.
  Fn.NeedsUIThread := True;

  // Error handling
  Fn.Entry := @n_media_error; Lib.Add('media_error@', Fn);
  Fn.Entry := @s_media_errormsg; Lib.Add('media_errormsg$@', Fn);
  Fn.Entry := @s_media_strerror; Lib.Add('media_strerror$@n', Fn);
  Fn.Entry := @n_media_ClearError; Lib.Add('media_clearerror@', Fn);

  // Non-visual media player (audio)
  Fn.Entry := @p_media_player; Lib.Add('media_player#@', Fn);
  Fn.Entry := @n_media_Free; Lib.Add('media_free@#', Fn);
  Fn.Entry := @p_media_load; Lib.Add('media_load#@#$', Fn);
  Fn.Entry := @n_media_Play; Lib.Add('media_play@#', Fn);
  Fn.Entry := @n_media_pause; Lib.Add('media_pause@#', Fn);
  Fn.Entry := @n_media_stop; Lib.Add('media_stop@#', Fn);
  Fn.Entry := @n_media_Clear; Lib.Add('media_clear@#', Fn);
  Fn.Entry := @n_media_state; Lib.Add('media_state@#', Fn);
  Fn.Entry := @p_media_volume_set; Lib.Add('media_volume#@#n', Fn);
  Fn.Entry := @n_media_volume_get; Lib.Add('media_volume@#', Fn);
  Fn.Entry := @n_media_duration; Lib.Add('media_duration@#', Fn);
  Fn.Entry := @p_media_position_set; Lib.Add('media_position#@#n', Fn);
  Fn.Entry := @n_media_position_get; Lib.Add('media_position@#', Fn);
  Fn.Entry := @s_media_filename; Lib.Add('media_filename$@#', Fn);
  Fn.Entry := @n_media_isplaying; Lib.Add('media_isplaying@#', Fn);
  Fn.Entry := @p_media_onend; Lib.Add('media_onend#@#$', Fn);
  Fn.Entry := @p_media_onstatechanged; Lib.Add('media_onstatechanged#@#$', Fn);

  // Visual media control (video)
  Fn.Entry := @p_media_control; Lib.Add('media_control#@#nnnn', Fn);
  Fn.Entry := @n_media_ctrl_free; Lib.Add('media_ctrl_free@#', Fn);
  Fn.Entry := @p_media_ctrl_load; Lib.Add('media_ctrl_load#@#$', Fn);
  Fn.Entry := @n_media_ctrl_play; Lib.Add('media_ctrl_play@#', Fn);
  Fn.Entry := @n_media_ctrl_pause; Lib.Add('media_ctrl_pause@#', Fn);
  Fn.Entry := @n_media_ctrl_stop; Lib.Add('media_ctrl_stop@#', Fn);
  Fn.Entry := @n_media_ctrl_clear; Lib.Add('media_ctrl_clear@#', Fn);
  Fn.Entry := @n_media_ctrl_state; Lib.Add('media_ctrl_state@#', Fn);
  Fn.Entry := @p_media_ctrl_volume_set; Lib.Add('media_ctrl_volume#@#n', Fn);
  Fn.Entry := @n_media_ctrl_volume_get; Lib.Add('media_ctrl_volume@#', Fn);
  Fn.Entry := @n_media_ctrl_duration; Lib.Add('media_ctrl_duration@#', Fn);
  Fn.Entry := @p_media_ctrl_position_set; Lib.Add('media_ctrl_position#@#n', Fn);
  Fn.Entry := @n_media_ctrl_position_get; Lib.Add('media_ctrl_position@#', Fn);
  Fn.Entry := @s_media_ctrl_filename; Lib.Add('media_ctrl_filename$@#', Fn);
  Fn.Entry := @n_media_ctrl_isplaying; Lib.Add('media_ctrl_isplaying@#', Fn);
  Fn.Entry := @n_media_ctrl_hasplayer; Lib.Add('media_ctrl_hasplayer@#', Fn);

  // Visual control properties
  Fn.Entry := @p_media_ctrl_pos; Lib.Add('media_ctrl_pos#@#nn', Fn);
  Fn.Entry := @p_media_ctrl_size; Lib.Add('media_ctrl_size#@#nn', Fn);
  Fn.Entry := @p_media_ctrl_bounds; Lib.Add('media_ctrl_bounds#@#nnnn', Fn);
  Fn.Entry := @n_media_ctrl_x; Lib.Add('media_ctrl_x@#', Fn);
  Fn.Entry := @n_media_ctrl_y; Lib.Add('media_ctrl_y@#', Fn);
  Fn.Entry := @n_media_ctrl_width; Lib.Add('media_ctrl_width@#', Fn);
  Fn.Entry := @n_media_ctrl_height; Lib.Add('media_ctrl_height@#', Fn);
  Fn.Entry := @p_media_ctrl_visible; Lib.Add('media_ctrl_visible#@#n', Fn);
  Fn.Entry := @n_media_ctrl_visible_get; Lib.Add('media_ctrl_visible@#', Fn);
  Fn.Entry := @p_media_ctrl_enabled; Lib.Add('media_ctrl_enabled#@#n', Fn);
  Fn.Entry := @n_media_ctrl_enabled_get; Lib.Add('media_ctrl_enabled@#', Fn);
  Fn.Entry := @p_media_ctrl_align; Lib.Add('media_ctrl_align#@#n', Fn);
  Fn.Entry := @n_media_ctrl_align_get; Lib.Add('media_ctrl_align@#', Fn);

  // Event callbacks for media control
  Fn.Entry := @p_media_ctrl_onend; Lib.Add('media_ctrl_onend#@#$', Fn);
  Fn.Entry := @p_media_ctrl_onstatechanged; Lib.Add('media_ctrl_onstatechanged#@#$', Fn);
  Fn.Entry := @p_media_ctrl_onclick; Lib.Add('media_ctrl_onclick#@#$', Fn);
  Fn.Entry := @p_media_ctrl_ondblclick; Lib.Add('media_ctrl_ondblclick#@#$', Fn);
  Fn.Entry := @p_media_ctrl_onmousedown; Lib.Add('media_ctrl_onmousedown#@#$', Fn);
  Fn.Entry := @p_media_ctrl_onmouseup; Lib.Add('media_ctrl_onmouseup#@#$', Fn);
  Fn.Entry := @p_media_ctrl_onmousemove; Lib.Add('media_ctrl_onmousemove#@#$', Fn);
  Fn.Entry := @p_media_ctrl_onresize; Lib.Add('media_ctrl_onresize#@#$', Fn);
end;

end.

