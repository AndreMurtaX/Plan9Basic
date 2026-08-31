unit UnitMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.IOUtils, System.Generics.Collections, System.Generics.Defaults, System.UIConsts,
  System.Math, System.NetEncoding,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Memo.Types, FMX.Layouts, FMX.StdCtrls, FMX.ScrollBox, FMX.Memo,
  FMX.Controls.Presentation, FMX.Edit, FMX.Objects, FMX.DialogService,
  FMX.DialogService.Async,
  FMX.Platform,
  {$IFDEF ANDROID}FMX.VirtualKeyboard.Android,{$ENDIF}
  System.Net.HttpClient, System.Net.URLClient, System.Threading,
  System.Rtti,
  basic, lexer, parser, exec, TranslationManager, UnitGC, HostServices,
  BasicConsole;

const
  VERSION = '1.8 (BETA)';
  PROMPT = '>';
  MAX_HISTORY = 100;

  // Base URL for first-run file downloads.
  // Update these to match your actual hosting location before distribution.
  URL_TRANSLATIONS = 'https://www.plan9basic.com/assets/devenv/Translations.ini';
  URL_EXAMPLES_BROWSER = 'https://www.plan9basic.com/assets/examples/ExamplesBrowser.bas';
  //Chosen so no file on disk can answer to it: a real name never starts with
  //a colon, and the picker only ever offers names it read from the directory.
  PICK_EXAMPLES = ':examples';

type
  TInterfaceMode = (imCommand, imEditor);
  TColorTheme = (ctGreen, ctAmber, ctWhite, ctBlue, ctPink);

  TThemeColors = record
    Name: string;
    Background: TAlphaColor;
    BackgroundAlt: TAlphaColor;
    Foreground: TAlphaColor;
    ForegroundDim: TAlphaColor;
    MemoForeground: TAlphaColor;
    MemoForegroundDim: TAlphaColor;
    LineNumbers: TAlphaColor;
    Border: TAlphaColor;
  end;

  TfrmMain = class(TForm)
    LayoutMain: TLayout;
    RectBackground: TRectangle;
    LayoutHeader: TLayout;
    lblTitle: TLabel;
    lblFKeys: TLabel;
    LayoutToolbar: TLayout;
    RectToolbarBackground: TRectangle;
    FlowToolbar: TFlowLayout;
    btnNew: TSpeedButton;
    btnLoad: TSpeedButton;
    btnSave: TSpeedButton;
    btnRun: TSpeedButton;
    btnMode: TSpeedButton;
    btnTheme: TSpeedButton;
    btnFiles: TSpeedButton;
    btnHelp: TSpeedButton;
    LayoutConsole: TLayout;
    RectConsoleBackground: TRectangle;
    Console: TMemo;
    LayoutEditor: TLayout;
    RectEditorBackground: TRectangle;
    LayoutLineNumbers: TLayout;
    RectLineNumbers: TRectangle;
    memoLineNumbers: TMemo;
    Editor: TMemo;
    LayoutInput: TLayout;
    RectInputBackground: TRectangle;
    lblPrompt: TLabel;
    edtCommand: TEdit;
    LayoutStatus: TLayout;
    RectStatusBackground: TRectangle;
    lblStatusMode: TLabel;
    lblStatusFile: TLabel;
    lblStatusLines: TLabel;
    lblStatusTheme: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure FormResize(Sender: TObject);
    procedure FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
    procedure edtCommandKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure EditorChange(Sender: TObject);
    procedure EditorViewportPositionChange(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF; const ContentSizeChanged: Boolean);
    // Toolbar button handlers
    procedure btnNewClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure btnModeClick(Sender: TObject);
    procedure btnThemeClick(Sender: TObject);
    procedure btnFilesClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    // Toolbar hover effects
    procedure ToolbarButtonMouseEnter(Sender: TObject);
    procedure ToolbarButtonMouseLeave(Sender: TObject);
    procedure EditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure EditorKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure EditorMouseUp(Sender: TObject; Button: TMouseButton;
                            Shift: TShiftState; X, Y: Single);
  private
    FBasic: TBasicEngine;
    FFilename: string;
    FProgram: TStringList;
    FCommandHistory: TList<string>;
    FHistoryIndex: Integer;
    FModified: Boolean;
    FPendingEditorSync: Boolean;
    //The line the caret was on when it was last looked at. Reformatting
    //happens when this changes, which is what makes leaving a line by any
    //means -- ENTER, an arrow key, a click -- do the same thing.
    FLastCaretLine: Integer;
    FFormattingLine: Boolean;
    FInterfaceMode: TInterfaceMode;
    FCurrentTheme: TColorTheme;
    FThemes: array[TColorTheme] of TThemeColors;
    FConsole: TBasicConsole;
    //How many lines the welcome block left behind, so a later reprint can tell
    //whether anything has been added since. See PrintWelcomeBlock.
    FWelcomeLines: Integer;

    // --- Self-test ---------------------------------------------------------
    // Run with --selftest and the IDE loads a program, runs it, checks its own
    // console and exits with a verdict.
    //
    // The applet runner got this first (ANALYSIS 24) and it is worth more here:
    // the IDE is the thing on the download page, it is the largest of the two
    // hosts, and until now nothing exercised it at all. It is also the host
    // still running the VM on its interface thread, which is a difference from
    // the runner worth having covered rather than assumed.
    FSelfTest: Boolean;
    FSelfTestTimer: TTimer;
    FSelfTestStarted: Boolean;
    FSelfTestElapsed: Integer;
    //Accumulated as it appears, not read at the end. The console can be
    //cleared out from under a running program: when the translations finish
    //downloading, the IDE reprints its welcome block and calls CmdCls to do it.
    //The first run of this test failed for exactly that reason and passed on
    //every run afterwards, because by then the file was cached.
    FSelfTestSeen: String;

    // Search & Replace controls (created at runtime)
    FLayoutSearchBar: TLayout;
    FRectSearchBackground: TRectangle;
    FLayoutSearchRow: TLayout;
    FLayoutReplaceRow: TLayout;
    FedtSearch: TEdit;
    FedtReplace: TEdit;
    FbtnFindNext: TSpeedButton;
    FbtnFindPrev: TSpeedButton;
    FbtnReplace: TSpeedButton;
    FbtnReplaceAll: TSpeedButton;
    FbtnSearchClose: TSpeedButton;
    FlblMatchInfo: TLabel;
    FSearchLastPos: Integer;
    FSearchBarVisible: Boolean;
    FbtnFindToolbar: TSpeedButton;
    FbtnCopyToolbar: TSpeedButton;
    FClosing: Boolean;
    FAnonymousCounter: Integer;

    // Gutter drag-to-scroll overlay
    FGutterOverlay: TRectangle;
    FGutterDragging: Boolean;
    FGutterLastY: Single;

    // File picker overlay (created at runtime, embedded in main form)
    // File picker overlay (created at runtime, embedded in main form)
    FLayoutFilePicker: TLayout;
    FRectFilePickerBg: TRectangle;
    FScrollFilePicker: TVertScrollBox;
    FlblFilePickerCaption: TLabel;
    FbtnFilePickerClose: TSpeedButton;
    FbtnFilePickerOpen: TSpeedButton;
    FSelectedFileBtn: TSpeedButton;
    FFilePickerCallback: TProc<string>;

    procedure SetFilename(Value: string);
    procedure HandlePrintOutput(Sender: TObject; const Text: string; IsClear: Boolean);

    // Gutter drag-to-scroll
    procedure CreateGutterOverlay();
    procedure GutterOverlayMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
    procedure GutterOverlayMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
    procedure GutterOverlayMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);

    // Theme management
    procedure InitializeThemes();
    procedure ApplyTheme(Theme: TColorTheme);
    procedure CycleTheme();

    // Mode management
    procedure SetInterfaceMode(Mode: TInterfaceMode);
    procedure ToggleMode();
    procedure SyncEditorToProgram();
    procedure SyncProgramToEditor();

    // The system bars
    //
    // From Android 15 (API 35) an app draws behind the status bar and the
    // navigation bar, and from 16 there is no opting out. This one targets 36,
    // so on a phone the clock sat on top of the title and the gesture bar sat
    // on top of the prompt and the status line.
    //
    // FireMonkey does report the space they take: the Android platform
    // registers IFMXWindowSafeAreaService, DoShow asks it once, and the
    // platform calls SafeAreaChanged again when it changes. Nothing here was
    // listening.
    //
    // The padding goes on RectBackground rather than on the form or on
    // LayoutMain, so the dark background still paints edge to edge under the
    // bars while every child -- header, toolbar, console, editor, input,
    // status -- is pushed inside the safe area.
    procedure ApplySafeArea(const AInsets: TRectF);
    procedure FormSafeAreaChanged(Sender: TObject; const AInsets: TRectF);
    procedure QuerySafeArea();

    // Status bar
    procedure UpdateStatusBar();
    procedure UpdateLineNumbers();
    procedure DeferredUpdateLineNumbers();

    // Search & Replace
    procedure CreateSearchBar();
    procedure ShowSearchBar();
    procedure HideSearchBar();
    procedure DoFindNext();
    procedure DoFindPrev();
    procedure DoReplace();
    procedure DoReplaceAll();
    procedure SelectEditorRange(AStart, ALength: Integer);
    function CountMatches(const SearchText, FullText: string): Integer;
    procedure UpdateMatchInfo();
    procedure edtSearchKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure edtReplaceKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
    procedure btnFindNextClick(Sender: TObject);
    procedure btnFindPrevClick(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
    procedure btnReplaceAllClick(Sender: TObject);
    procedure btnSearchCloseClick(Sender: TObject);
    procedure edtSearchChangeTracking(Sender: TObject);
    procedure btnFindToolbarClick(Sender: TObject);
    procedure btnCopyToolbarClick(Sender: TObject);

    // File picker helpers
    procedure FilePickerOpenClick(Sender: TObject);

    // Platform-specific adjustments
    procedure AdjustForPlatform();
    procedure RefreshTranslatedUI();
    procedure SetupToolbarButtons();
    procedure RecalcToolbarHeight();
    procedure MakeMemoTransparent(AMemo: TMemo);

    // Unsaved changes guard
    procedure ConfirmDiscardChanges(OnConfirmed: TProc);

    // Command processing
    procedure ProcessCommand(const Cmd: string);
    procedure ProcessDirectCommand(const Cmd: string);
    function ExtractFilenameFromCmd(const Cmd: string): string;

    // Direct commands
    procedure CmdNew();
    procedure CmdList(const Args: string);
    procedure CmdRun();
    procedure SelfTestTick(Sender: TObject);
    function SelfTestFeatures(): String;
    procedure CmdLoad(const Filename: string);
    procedure CmdSave(const Filename: string);
    procedure CmdFiles();
    procedure CmdCls();
    procedure CmdHelp();
    procedure CmdBye();
    procedure CmdMode(const Args: string);
    procedure CmdTheme(const Args: string);
    procedure CmdIntro();

    // Program management
    function GetProgramText(): string;

    // History management
    procedure AddToHistory(const Cmd: string);
    procedure NavigateHistory(Direction: Integer);

    // Output helpers
    procedure Print(const Text: string);
    procedure PrintLn(const Text: string = '');
    procedure PrintReady();
    //The banner, in one place, because it is printed twice: at startup and
    //again if translations arrive afterwards.
    procedure PrintWelcomeBlock();
    //True while the console still holds exactly what PrintWelcomeBlock left.
    function ConsoleHoldsOnlyWelcome(): Boolean;
    procedure PrintError(const Msg: string);
    procedure PrintSyntaxError();

    // File operations
    function GetAppPath(): string;
    function GetBasePath(): string;
    function DownloadFile(const AURL, ADestPath: string): Boolean;
    procedure EnsureRequiredFiles();

    // Console management
    procedure CreateConsole();
    function GetSyntaxColors(Theme: TColorTheme): TSyntaxColors;

    // Dialog helpers for mobile
    procedure ShowSaveDialog();
    procedure ShowFileListDialog();
    procedure CreateFilePicker();
    procedure PopulateFilePicker(ACallback: TProc<string>);
    procedure HideFilePicker();
    procedure FilePickerItemClick(Sender: TObject);
    //The row that opens the online catalogue rather than a file on disk. A
    //name no file can have, because a real one would collide with it.
    procedure AddExamplesRow(AFontFamily: String; AFontSize, AItemH: Single);
    procedure FilePickerCloseClick(Sender: TObject);

    function IsKeyword(const Word: string): Boolean;
    function UppercaseKeywords(const Line: string): string;
    function IsContextualKeyword(const Word: string; AtStatementStart: Boolean;
                                 const Rest: string): Boolean;
    procedure FormatLineLeft();
    procedure TrackCaretLine();
    procedure FormatLoadedSource();


  public
    //Host side of the engine's three interactions with a person. The engine
    //itself no longer knows FireMonkey; these are where the dialogs live.
    procedure HostInput(const ACaption: String; const ALabels: array of String;
                        const ADefaults: array of String; const ADone: TInputDoneProc);
    procedure HostConfirm(const AMessage: String; const ADone: TConfirmDoneProc);
    procedure HostYield();
    //The platform services the engine asks HostServices for. FireMonkey lives
    //here, in the host that already has a window, rather than in StrLib.
    procedure WireHostServices();
    procedure HostPumpMessages();
    procedure HostHandleOneMessage();
    procedure HostSetClipboard(const AText: string);
    function HostGetClipboard(): string;
    procedure InitBASICEngine();
    property Basic: TBasicEngine read FBasic;
    property Filename: string read FFilename write SetFilename;
  end;

var
  frmMain: TfrmMain;

implementation

uses
  UnitUtils, ArrayLib, DateTimeLib, NumLib, StdLib, StrLib, SysLib, PlatformInfoLib,
  DictLib, ConfigLib, StrListLib, JsonLib, RegexLib, Base64Lib, GZipLib, ZipLib,
  HttpLib, FormLib, LayoutLib, RectangleLib, LabelLib, EditLib, MemoLib, ButtonLib,
  SpeedButtonLib, ComboBoxLib, ListBoxLib, CheckBoxLib, RadioButtonLib, PanelLib,
  CircleLib, RoundRectLib, EllipseLib, ArcLib, PieLib, LineLib, CalloutRectangleLib,
  PathLib, ImageLib, SwitchLib, StringGridLib, ProgressBarLib, TrackBarLib, TimerLib,
  ScrollBoxLib, ColorAnimationLib, FloatAnimationLib, IntAnimationLib, BitmapListAnimationLib,
  PathAnimationLib, RectAnimationLib, BlurEffectLib, GlowEffectLib, ShadowEffectLib,
  BevelEffectLib, ColorKeyAlphaEffectLib, InnerGlowEffectLib, MonochromeEffectLib,
  ReflectionEffectLib, ContrastEffectLib, HueAdjustEffectLib, InvertEffectLib,
  SepiaEffectLib, EmbossEffectLib, PaperSketchEffectLib, PencilStrokeEffectLib,
  PixelateEffectLib, SharpenEffectLib, ToonEffectLib, BandsEffectLib, MagnifyEffectLib,
  RippleEffectLib, SwirlEffectLib, WaveEffectLib, WrapEffectLib, BlindTransitionEffectLib,
  CircleTransitionEffectLib, DissolveTransitionEffectLib, SlideTransitionEffectLib,
  SwipeTransitionEffectLib, FadeTransitionEffectLib, BandedSwirlTransitionEffectLib,
  BloodTransitionEffectLib, BlurTransitionEffectLib, BrightTransitionEffectLib,
  CrumpleTransitionEffectLib, DropTransitionEffectLib, LineTransitionEffectLib,
  MagnifyTransitionEffectLib, PixelateTransitionEffectLib, RotateCrumpleTransitionEffectLib,
  SaturateTransitionEffectLib, ShapeTransitionEffectLib, SwirlTransitionEffectLib,
  WaterTransitionEffectLib, WaveTransitionEffectLib, WiggleTransitionEffectLib,
  RippleTransitionEffectLib, BoxBlurEffectLib, DirectionalBlurEffectLib,
  GaussianBlurEffectLib, RadialBlurEffectLib, BloomEffectLib, GloomEffectLib,
  AffineTransformEffectLib, CropEffectLib, PerspectiveTransformEffectLib,
  TilerEffectLib, NormalBlendEffectLib, BandedSwirlEffectLib, PinchEffectLib,
  SmoothMagnifyEffectLib, MaskToAlphaEffectLib, FillRGBEffectLib, FillEffectLib,
  MediaPlayerLib, SQLiteLib, IOUtilsLib, AILib, RAGLib;

{$R *.fmx}

{ TfrmMain }

// -----------------------------------------------------------------------
// Step 4: FormatLoadedSource - applies indentation + keyword uppercasing
// Call this from CmdLoad after loading lines into FProgram.
// -----------------------------------------------------------------------
procedure TfrmMain.FormatLoadedSource();
var
  I: Integer;
  IndentLevel: Integer;
  Line, Trimmed, Upper: string;
  FirstWord, SecondWord: string;
  SpacePos: Integer;
  IsBlockClose, IsBlockOpen, IsMidBlock: Boolean;
  IndentStr: string;
begin
  IndentLevel := 0;

  for I := 0 to FProgram.Count - 1 do
  begin
    // First, uppercase keywords in the line
    Line := UppercaseKeywords(Trim(FProgram[I]));
    Trimmed := Trim(Line);

    if Trimmed = '' then
      Continue;

    // Skip pure comment lines (preserve as-is, just indent them)
    if (Trimmed[1] = '''') then
    begin
      // Apply current indentation to comment
      IndentStr := StringOfChar(' ', IndentLevel * 2);
      FProgram[I] := IndentStr + Trimmed;
      Continue;
    end;

    // Extract first word (and second word for compound keywords)
    FirstWord := '';
    SecondWord := '';
    SpacePos := Pos(' ', Trimmed);
    if SpacePos > 0 then
    begin
      FirstWord := UpperCase(Copy(Trimmed, 1, SpacePos - 1));
      // Extract second word
      SecondWord := Trim(Copy(Trimmed, SpacePos + 1, Length(Trimmed)));
      SpacePos := Pos(' ', SecondWord);
      if SpacePos > 0 then
        SecondWord := Copy(SecondWord, 1, SpacePos - 1);
      SecondWord := UpperCase(SecondWord);
    end
    else
      FirstWord := UpperCase(Trimmed);

    // --- Determine if this line closes a block ---
    IsBlockClose := False;
    IsMidBlock := False;
    IsBlockOpen := False;

    // Block closers (dedent this line)
    if (FirstWord = 'LOOP') or (FirstWord = 'NEXT') or (FirstWord = 'WEND') or (FirstWord = 'ENDWHILE') or
       (FirstWord = 'ENDFOR') or (FirstWord = 'ENDIF') or (FirstWord = 'ENDFUNCTION') or (FirstWord = 'ENDSELECT') or
       (FirstWord = 'UNTIL') then
      IsBlockClose := True;

    // Compound closers: END FUNCTION, END IF, END WHILE, END FOR, END SELECT
    if (FirstWord = 'END') and
       ((SecondWord = 'FUNCTION') or (SecondWord = 'IF') or
        (SecondWord = 'WHILE') or (SecondWord = 'FOR') or
        (SecondWord = 'SELECT')) then
      IsBlockClose := True;

    // Standalone END (program terminator) at top level
    if (FirstWord = 'END') and (SecondWord = '') then
      IsBlockClose := (IndentLevel > 0);

    // Mid-block keywords: ELSE, CASE (dedent this line, then indent again)
    if (FirstWord = 'ELSE') or (FirstWord = 'CASE') then
      IsMidBlock := True;

    // --- Apply dedent for closers and mid-block ---
    if IsBlockClose or IsMidBlock then
    begin
      Dec(IndentLevel);
      if IndentLevel < 0 then
        IndentLevel := 0;
    end;

    // --- Apply indentation ---
    IndentStr := StringOfChar(' ', IndentLevel * 2);
    FProgram[I] := IndentStr + Trimmed;

    // --- Determine if this line opens a block ---
    // Block openers (indent subsequent lines)
    if (FirstWord = 'FOR') or (FirstWord = 'DO') or
       (FirstWord = 'WHILE') or (FirstWord = 'SELECT') or
       (FirstWord = 'REPEAT') or (FirstWord = 'FUNCTION') then
      IsBlockOpen := True;

    // IF...THEN is a block opener only if THEN is at the end of the line
    // (multi-line IF). If there's code after THEN, it's a single-line IF.
    if (FirstWord = 'IF') then
    begin
      Upper := UpperCase(Trimmed);
      // Check if THEN is present and is the last significant token
      SpacePos := Pos(' THEN', Upper);
      if SpacePos > 0 then
      begin
        // Check if there's meaningful code after THEN
        Line := Trim(Copy(Trimmed, SpacePos + 5, Length(Trimmed)));
        // Remove trailing comment
        if (Length(Line) > 0) and (Line[1] = '''') then
          Line := '';
        if Line = '' then
          IsBlockOpen := True; // Multi-line IF
      end;
    end;

    // Mid-block also opens for the next line
    if IsMidBlock then
      IsBlockOpen := True;

    if IsBlockOpen then
      Inc(IndentLevel);
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  SelfTestArg: Integer;
begin
  {$IF Defined(DEBUG) and Defined(MSWINDOWS)}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}

  // ---- Self-test ----
  // FindCmdLineSwitch strips one switch character, so --selftest would reach it
  // as -selftest and never match. Read the parameters directly.
  FSelfTest := False;
  for SelfTestArg := 1 to ParamCount do
    if SameText(ParamStr(SelfTestArg), '--selftest') or
       SameText(ParamStr(SelfTestArg), '-selftest') or
       SameText(ParamStr(SelfTestArg), '/selftest') then
      FSelfTest := True;

  //A phone has no command line. An activity is started by the launcher and
  //ParamStr carries nothing, so the switch above can never arrive there --
  //which is why the one host this project most needs to measure was the one
  //it could not run unattended.
  //
  //A file does arrive: adb push writes it, the app finds it on the next start,
  //and deletes it so a person who installs the IDE never meets a self-test.
  if not FSelfTest then
    if System.IOUtils.TFile.Exists(
         System.IOUtils.TPath.Combine(GetBasePath(), 'selftest.run')) then
    begin
      FSelfTest := True;
      try
        System.IOUtils.TFile.Delete(
          System.IOUtils.TPath.Combine(GetBasePath(), 'selftest.run'));
      except
        //Running once is what matters; failing to tidy up is not a verdict.
      end;
    end;

  // Initialize collections
  FProgram := TStringList.Create;
  FCommandHistory := TList<string>.Create;
  FHistoryIndex := -1;
  FModified := False;
  FPendingEditorSync := False;
  FFilename := '';
  FInterfaceMode := imCommand;
  FClosing := False;
  FCurrentTheme := ctGreen;
  FAnonymousCounter := 0;
  FLastCaretLine := 0;

  InitializeThemes();

  lblTitle.Text := 'P9B v' + VERSION;

  // Create the translation manager pointing to the app folder.
  // If Translations.ini does not exist yet (first run), TIniFile returns empty
  // values and _() falls back to the key name — EnsureRequiredFiles() will
  // download the file in the background and reload the manager when done.
  LanguageManager := TTranslationManager.Create(System.IOUtils.TPath.Combine(GetAppPath(), 'Translations.ini'));

  //Started last, so everything above it exists before the first tick.
  if FSelfTest then
  begin
    FSelfTestStarted := False;
    FSelfTestElapsed := 0;
    FSelfTestTimer := TTimer.Create(Self);
    FSelfTestTimer.Interval := 250;
    FSelfTestTimer.OnTimer := SelfTestTick;
    FSelfTestTimer.Enabled := True;
  end;

  // Platform-specific adjustments
  AdjustForPlatform();

  // Apply initial theme
  ApplyTheme(FCurrentTheme);

  // Prevent user from scrolling the gutter independently —
  // it must always follow the Editor viewport position
  memoLineNumbers.HitTest := False;

  // Create invisible overlay on gutter for drag-to-scroll
  CreateGutterOverlay();

  // Set initial mode
  SetInterfaceMode(imCommand);

  // Create the rich console (replaces Console TMemo)
  CreateConsole();

  // Download Translations.ini and ExamplesBrowser.bas if missing (first run).
  // Desktop only — on Android/iOS the files are always bundled by the
  // deployment framework, so the download path is not needed there.
  {$IF not Defined(ANDROID) and not Defined(IOS)}
  EnsureRequiredFiles();
  {$ENDIF}

  // Create the search & replace bar (hidden by default)
  FSearchLastPos := 0;
  FSearchBarVisible := False;
  CreateSearchBar();

  // Create the file picker overlay (hidden by default)
  CreateFilePicker();

  // Add a FIND button to the toolbar (essential for mobile — no Ctrl+F)
  FbtnFindToolbar := TSpeedButton.Create(Self);
  FbtnFindToolbar.Parent := FlowToolbar;
  FbtnFindToolbar.Index := btnRun.Index; // place FIND between SAVE and RUN
  FbtnFindToolbar.Text := _('ToolbarBtnFind');
  FbtnFindToolbar.StyledSettings := [];
  FbtnFindToolbar.TextSettings.FontColor := FThemes[FCurrentTheme].Foreground;
  FbtnFindToolbar.TextSettings.Font.Size := 11;
  FbtnFindToolbar.OnClick := btnFindToolbarClick;
  {$IF Defined(ANDROID) or Defined(IOS)}
  FbtnFindToolbar.Width := 55;
  FbtnFindToolbar.Height := 50;
  FbtnFindToolbar.TextSettings.Font.Family := 'monospace';
  {$ELSE}
  FbtnFindToolbar.Width := 60;
  FbtnFindToolbar.Height := 44;
  FbtnFindToolbar.Hint := _('HintFind');
  FbtnFindToolbar.ShowHint := True;
  FbtnFindToolbar.TextSettings.Font.Style := [TFontStyle.fsBold];
    {$IFDEF MSWINDOWS}
    FbtnFindToolbar.TextSettings.Font.Family := 'Consolas';
    {$ENDIF}
    {$IFDEF LINUX}
    FbtnFindToolbar.TextSettings.Font.Family := 'DejaVu Sans Mono';
    {$ENDIF}
    {$IFDEF MACOS}
    FbtnFindToolbar.TextSettings.Font.Family := 'Menlo';
    {$ENDIF}
  FbtnFindToolbar.OnMouseEnter := ToolbarButtonMouseEnter;
  FbtnFindToolbar.OnMouseLeave := ToolbarButtonMouseLeave;
  {$ENDIF}

  // COPY button — copies console output to clipboard
  FbtnCopyToolbar := TSpeedButton.Create(Self);
  FbtnCopyToolbar.Parent := FlowToolbar;
  FbtnCopyToolbar.Text := _('ToolbarBtnCopy');
  FbtnCopyToolbar.StyledSettings := [];
  FbtnCopyToolbar.TextSettings.FontColor := FThemes[FCurrentTheme].Foreground;
  FbtnCopyToolbar.TextSettings.Font.Size := 11;
  FbtnCopyToolbar.OnClick := btnCopyToolbarClick;
  {$IF Defined(ANDROID) or Defined(IOS)}
  FbtnCopyToolbar.Width := 55;
  FbtnCopyToolbar.Height := 50;
  FbtnCopyToolbar.TextSettings.Font.Family := 'monospace';
  {$ELSE}
  FbtnCopyToolbar.Width := 60;
  FbtnCopyToolbar.Height := 44;
  FbtnCopyToolbar.Hint := _('HintCopy');
  FbtnCopyToolbar.ShowHint := True;
  FbtnCopyToolbar.TextSettings.Font.Style := [TFontStyle.fsBold];
    {$IFDEF MSWINDOWS}
    FbtnCopyToolbar.TextSettings.Font.Family := 'Consolas';
    {$ENDIF}
    {$IFDEF LINUX}
    FbtnCopyToolbar.TextSettings.Font.Family := 'DejaVu Sans Mono';
    {$ENDIF}
    {$IFDEF MACOS}
    FbtnCopyToolbar.TextSettings.Font.Family := 'Menlo';
    {$ENDIF}
  FbtnCopyToolbar.OnMouseEnter := ToolbarButtonMouseEnter;
  FbtnCopyToolbar.OnMouseLeave := ToolbarButtonMouseLeave;
  {$ENDIF}

  // Calculate toolbar height based on flow layout
  RecalcToolbarHeight();

  // Re-apply theme now that all runtime controls exist
  ApplyTheme(FCurrentTheme);

  //*********************************
  // Hide the original TMemo Console
  //*********************************
  Console.Visible := False;

  // Welcome message
  PrintWelcomeBlock();

  UpdateStatusBar();
  edtCommand.SetFocus();

  Editor.OnKeyDown := EditorKeyDown;
  //Leaving a line by moving the caret, rather than by typing. OnChange cannot
  //see an arrow key or a click, and FMX gives a memo no caret-moved event, so
  //these two are where navigation is noticed.
  Editor.OnKeyUp := EditorKeyUp;
  Editor.OnMouseUp := EditorMouseUp;

  //Assigned here rather than in the designer, so the whole of this belongs to
  //one file. DoShow asks the safe-area service and raises this before the form
  //is first painted, and the platform raises it again on rotation, so the
  //handler alone covers both -- but the service is asked directly as well,
  //because a form that is already visible when this runs would never see that
  //first call.
  OnSafeAreaChanged := FormSafeAreaChanged;
  QuerySafeArea();
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  {$IF not Defined(ANDROID) and not Defined(IOS)}
  // On desktop (Windows, Linux, macOS): intercept the close gesture and ask
  // the user to save if there are unsaved changes in the editor.
  if FModified and not FClosing then
  begin
    CanClose := False;
    ConfirmDiscardChanges(
      procedure
      begin
        // User chose to save or discard — commit to closing.
        // Setting FClosing prevents deferred callbacks from firing on the way
        // out, and allows the next Application.Terminate() call to pass the
        // CloseQuery check without entering this branch again.
        FClosing := True;
        Application.Terminate();
      end);
  end;
  {$ENDIF}
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  // Prevent queued callbacks from accessing destroyed controls
  FClosing := True;

  // === SAME CLEANUP ORDER AS InitBASICEngine ===

  // 1. Kill all timers — stop async callbacks
  TimerLib.CleanupAllTimers();

  // 2. Close and free all applet forms
  FormLib.CleanupAllForms();

  // 3. Free the engine
  if Assigned(FBasic) then
    FreeAndNil(FBasic);

  // 4. Free the GC (non-visual objects only)
  if Assigned(GC) then
    FreeAndNil(GC);

  if Assigned(TranslationManager.LanguageManager) then
    FreeAndNil(TranslationManager.LanguageManager);

  FProgram.Free();
  FCommandHistory.Free();
end;

procedure TfrmMain.AdjustForPlatform();
begin
  {$IF Defined(ANDROID) or Defined(IOS)}
  // Mobile: Hide function key labels, show toolbar prominently
  lblFKeys.Visible := False;
  LayoutHeader.Height := 28;

  // Larger fonts for touch
  Console.TextSettings.Font.Size := 16;
  Editor.TextSettings.Font.Size := 16;
  memoLineNumbers.TextSettings.Font.Size := 16;
  edtCommand.TextSettings.Font.Size := 16;

  // Larger touch targets for buttons (FlowLayout wraps to next row)
  btnNew.Width := 55;   btnNew.Height := 50;
  btnLoad.Width := 55;  btnLoad.Height := 50;
  btnSave.Width := 55;  btnSave.Height := 50;
  btnRun.Width := 50;   btnRun.Height := 50;
  btnMode.Width := 60;  btnMode.Height := 50;
  btnTheme.Width := 65; btnTheme.Height := 50;
  btnFiles.Width := 55; btnFiles.Height := 50;
  btnHelp.Width := 55;  btnHelp.Height := 50;

  // Force FMX styled rendering instead of native controls
  // so that transparentedit works and the dark background
  // rectangle shows through
  Console.ControlType := TControlType.Styled;
  Editor.ControlType := TControlType.Styled;
  memoLineNumbers.ControlType := TControlType.Styled;
  edtCommand.ControlType := TControlType.Styled;
  {$ELSE}
  // Desktop: Show function key labels, toolbar is secondary
  lblFKeys.Visible := True;

  btnNew.Hint := _('HintNew');   btnNew.ShowHint := true;
  btnLoad.Hint := _('HintLoad'); btnLoad.ShowHint := true;
  btnSave.Hint := _('HintSave'); btnSave.ShowHint := true;
  btnRun.Hint := _('HintRun');   btnRun.ShowHint := true;
  btnMode.Hint := _('HintMode'); btnMode.ShowHint := true;
  btnTheme.Hint := _('HintTheme'); btnTheme.ShowHint := true;
  btnFiles.Hint := _('HintFiles'); btnFiles.ShowHint := true;
  btnHelp.Hint := _('HintHelp'); btnHelp.ShowHint := true;

  // Setup hover effects for desktop
  SetupToolbarButtons();
  {$ENDIF}
end;

// Refreshes every UI element whose label/hint/prompt was set via _() during
// FormCreate.  Call this after reloading LanguageManager so the entire
// interface reflects the newly loaded translations.
procedure TfrmMain.RefreshTranslatedUI();
begin
  // --- Toolbar dynamic buttons ---
  FbtnFindToolbar.Text := _('ToolbarBtnFind');
  FbtnCopyToolbar.Text := _('ToolbarBtnCopy');

  // --- Mode button + status-mode label ---
  if FInterfaceMode = imCommand then
  begin
    lblStatusMode.Text := _('ModeLabelCommand');
    btnMode.Text := _('BtnModeToEditor');
  end
  else
  begin
    lblStatusMode.Text := _('ModeLabelEditor');
    btnMode.Text := _('BtnModeToCMD');
  end;

  // --- Status bar (file name, line count) ---
  UpdateStatusBar();

  // --- File picker overlay ---
  FlblFilePickerCaption.Text := _('FilePickerTitle');
  FbtnFilePickerClose.Text := _('FilePickerCancel');
  FbtnFilePickerOpen.Text := _('FilePickerOpen');

  // --- Search & Replace bar ---
  FbtnSearchClose.Text := _('SearchBarCloseBtn');
  FedtSearch.TextPrompt := _('SearchBarSearchPrompt');
  FedtReplace.TextPrompt := _('SearchBarReplacePrompt');
  FbtnReplace.Text := _('SearchBarReplaceBtn');
  FbtnReplaceAll.Text := _('SearchBarReplaceAllBtn');

  {$IF not Defined(ANDROID) and not Defined(IOS)}
  // --- Desktop button hints ---
  btnNew.Hint := _('HintNew');
  btnLoad.Hint := _('HintLoad');
  btnSave.Hint := _('HintSave');
  btnRun.Hint := _('HintRun');
  btnMode.Hint := _('HintMode');
  btnTheme.Hint := _('HintTheme');
  btnFiles.Hint := _('HintFiles');
  btnHelp.Hint := _('HintHelp');
  FbtnFindToolbar.Hint := _('HintFind');
  FbtnCopyToolbar.Hint := _('HintCopy');
  {$ENDIF}
end;

procedure TfrmMain.SetupToolbarButtons();
begin
  // Assign mouse events for hover effects
  btnNew.OnMouseEnter := ToolbarButtonMouseEnter;
  btnNew.OnMouseLeave := ToolbarButtonMouseLeave;
  btnLoad.OnMouseEnter := ToolbarButtonMouseEnter;
  btnLoad.OnMouseLeave := ToolbarButtonMouseLeave;
  btnSave.OnMouseEnter := ToolbarButtonMouseEnter;
  btnSave.OnMouseLeave := ToolbarButtonMouseLeave;
  btnRun.OnMouseEnter := ToolbarButtonMouseEnter;
  btnRun.OnMouseLeave := ToolbarButtonMouseLeave;
  btnMode.OnMouseEnter := ToolbarButtonMouseEnter;
  btnMode.OnMouseLeave := ToolbarButtonMouseLeave;
  btnTheme.OnMouseEnter := ToolbarButtonMouseEnter;
  btnTheme.OnMouseLeave := ToolbarButtonMouseLeave;
  btnFiles.OnMouseEnter := ToolbarButtonMouseEnter;
  btnFiles.OnMouseLeave := ToolbarButtonMouseLeave;
  btnHelp.OnMouseEnter := ToolbarButtonMouseEnter;
  btnHelp.OnMouseLeave := ToolbarButtonMouseLeave;

  // Make button text bold/larger for emphasis
  btnNew.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnLoad.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnSave.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnRun.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnMode.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnTheme.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnFiles.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnHelp.TextSettings.Font.Style := [TFontStyle.fsBold];
end;

procedure TfrmMain.RecalcToolbarHeight();
var
  I: Integer;
  Child: TFmxObject;
  MaxBottom: Single;
  BtnHeight: Single;
begin
  // Let the FlowLayout position its children
  FlowToolbar.Width := RectToolbarBackground.Width;

  // Find the bottom-most child to determine required height
  MaxBottom := 0;
  BtnHeight := 44; // default button height

  for I := 0 to FlowToolbar.ChildrenCount - 1 do
  begin
    Child := FlowToolbar.Children[I];
    if (Child is TControl) and TControl(Child).Visible then
    begin
      if TControl(Child).Position.Y + TControl(Child).Height > MaxBottom then
      begin
        MaxBottom := TControl(Child).Position.Y + TControl(Child).Height;
        BtnHeight := TControl(Child).Height;
      end;
    end;
  end;

  if MaxBottom < BtnHeight then
    MaxBottom := BtnHeight;

  // Update FlowLayout and outer toolbar container heights
  FlowToolbar.Height := MaxBottom;
  LayoutToolbar.Height := MaxBottom;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  RecalcToolbarHeight();
end;

procedure TfrmMain.ToolbarButtonMouseEnter(Sender: TObject);
var
  Btn: TSpeedButton;
begin
  if Sender is TSpeedButton then
  begin
    Btn := TSpeedButton(Sender);
    // Brighten the text color on hover
    case FCurrentTheme of
      ctGreen: Btn.TextSettings.FontColor := $FF9400D3;  // Dark Violet
      ctAmber: Btn.TextSettings.FontColor := $FFFFFFFF;  // White
      ctWhite: Btn.TextSettings.FontColor := $FF9400D3;  // Dark Violet
      ctBlue:  Btn.TextSettings.FontColor := $FF9400D3;  // Dark Violet
      ctPink:  Btn.TextSettings.FontColor := $FFFFFFFF;  // White
    end;
  end;
end;

procedure TfrmMain.ToolbarButtonMouseLeave(Sender: TObject);
var
  Btn: TSpeedButton;
  T: TThemeColors;
begin
  if Sender is TSpeedButton then
  begin
    Btn := TSpeedButton(Sender);
    T := FThemes[FCurrentTheme];
    // Restore original theme color
    Btn.TextSettings.FontColor := T.Foreground;
  end;
end;

procedure TfrmMain.FormKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  // When file picker is visible, only Escape is allowed
  if FLayoutFilePicker.Visible then
  begin
    if Key = vkEscape then
      HideFilePicker();
    Exit();
  end;

  case Key of
    vkF1: CmdHelp();
    vkF2: btnSaveClick(nil);
    vkF3:
    begin
      if FInterfaceMode = imEditor then
      begin
        if FSearchBarVisible then
          DoFindNext()
        else
          btnLoadClick(nil);
      end
      else
        btnLoadClick(nil);
    end;
    vkF5: CmdRun();
    vkF7: ToggleMode();
    vkF8: CycleTheme();
    vkF9: CmdFiles();
  end;

  // Ctrl+F or Ctrl+H: Show search bar in editor mode
  if (ssCtrl in Shift) and (FInterfaceMode = imEditor) then
  begin
    if (Key = Ord('F')) or (Key = Ord('H')) then
      ShowSearchBar();
  end;

  // Escape: Close search bar if visible
  if (Key = vkEscape) and FSearchBarVisible then
    HideSearchBar();
end;

procedure TfrmMain.FormVirtualKeyboardHidden(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  {$IF Defined(ANDROID) or Defined(IOS)}
  LayoutMain.Align := TAlignLayout.Client;
  {$ENDIF}
end;

procedure TfrmMain.FormVirtualKeyboardShown(Sender: TObject; KeyboardVisible: Boolean; const Bounds: TRect);
begin
  {$IF Defined(ANDROID) or Defined(IOS)}
  LayoutMain.Align := TAlignLayout.Top;
  LayoutMain.Height := ClientHeight - Bounds.Height;
  {$ENDIF}
end;

procedure TfrmMain.edtCommandKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  case Key of
    vkReturn:
    begin
      if edtCommand.Text.Trim <> '' then
      begin
        AddToHistory(edtCommand.Text);
        PrintLn(PROMPT + ' ' + edtCommand.Text);
        ProcessCommand(edtCommand.Text.Trim);
        edtCommand.Text := '';
      end;
    end;
    vkUp: NavigateHistory(-1);
    vkDown: NavigateHistory(1);
    vkEscape: edtCommand.Text := '';
  end;
end;

//Uppercase the keywords on the line the caret has just left.
//
//One line, in place. The previous version read the whole document out of the
//memo, split it into a TStringList, replaced one entry, joined it back and
//assigned the result to Editor.Text -- which makes FireMonkey rebuild the
//layout of every line. Measured with tests/EditorFormatProbe.dpr on a
//5,000-line program that was 1.30 ms; Editor.Lines[i] is 0.0001 ms and does not
//grow with the document. The formatting itself was never the cost: it is
//0.001 ms and flat.
procedure TfrmMain.FormatLineLeft();
var
  Line, Formatted: string;
  Caret: TCaretPosition;
begin
  //Assigning to Lines fires OnChange, which calls back into here.
  if FFormattingLine then
    Exit();
  if (FLastCaretLine < 0) or (FLastCaretLine >= Editor.Lines.Count) then
    Exit();
  Line := Editor.Lines[FLastCaretLine];
  Formatted := UppercaseKeywords(Line);
  if Formatted = Line then
    Exit();

  FFormattingLine := True;
  try
    Caret := Editor.CaretPosition;
    Editor.OnChange := nil;
    try
      Editor.Lines[FLastCaretLine] := Formatted;
      //Replacing a line moves the caret to it. Put it back where the person
      //left it, or every ENTER would drop them on the line above.
      Editor.CaretPosition := Caret;
    finally
      Editor.OnChange := EditorChange;
    end;
  finally
    FFormattingLine := False;
  end;
end;

//Has the caret changed line since this was last asked? Then the line it left is
//finished, and gets formatted.
//
//This is called from typing, from key-up and from mouse-up, which between them
//cover ENTER, the arrow keys, Page Up and Down, and clicking somewhere else.
//FireMonkey gives a memo no caret-moved event, so there is no single place.
procedure TfrmMain.TrackCaretLine();
var
  L: Integer;
begin
  if FFormattingLine then
    Exit();
  L := Editor.CaretPosition.Line;
  if L = FLastCaretLine then
    Exit();
  FormatLineLeft();
  FLastCaretLine := L;
end;

procedure TfrmMain.EditorKeyUp(Sender: TObject; var Key: Word;
  var KeyChar: WideChar; Shift: TShiftState);
begin
  TrackCaretLine();
end;

procedure TfrmMain.EditorMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  TrackCaretLine();
end;

procedure TfrmMain.EditorChange(Sender: TObject);
begin
  FModified := True;
  //Formatting used to be triggered by counting the document's lines on every
  //keystroke and looking for the count to go up by one -- which meant copying
  //the whole document out of the memo and walking it character by character
  //before knowing whether anything had happened at all. On a 5,000-line
  //program that was 0.36 ms per keystroke and growing. Comparing two integers
  //answers the same question.
  TrackCaretLine();
  DeferredUpdateLineNumbers();
  UpdateStatusBar();
end;

procedure TfrmMain.EditorKeyDown(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  // Ctrl+Up / Ctrl+Down triggers FMX TMemo's internal paragraph-navigation
  // code path which accesses a nil layout reference, causing an AV.
  // Consume these keys here (before the presenter processes them) and
  // implement safe viewport scrolling instead.
  if (ssCtrl in Shift) then
  begin
    case Key of
      vkUp:
      begin
        Editor.ViewportPosition := PointF(Editor.ViewportPosition.X, Max(0, Editor.ViewportPosition.Y - Editor.TextSettings.Font.Size - 2));
        Key := 0;
      end;
      vkDown:
      begin
        Editor.ViewportPosition := PointF(Editor.ViewportPosition.X, Editor.ViewportPosition.Y + Editor.TextSettings.Font.Size + 2);
        Key := 0;
      end;
    end;
  end;
end;

procedure TfrmMain.EditorViewportPositionChange(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF; const ContentSizeChanged: Boolean);
begin
  // Sync line numbers scroll with editor
  memoLineNumbers.ViewportPosition := PointF(0, NewViewportPosition.Y);

  // ContentSizeChanged is True after paste operations and other edits
  // that change the text dimensions — update gutter to stay in sync
  if ContentSizeChanged then
    DeferredUpdateLineNumbers();
end;

// -----------------------------------------------------------------------------
// Toolbar Button Handlers
// -----------------------------------------------------------------------------

procedure TfrmMain.btnNewClick(Sender: TObject);
begin
  CmdNew();
end;

procedure TfrmMain.btnLoadClick(Sender: TObject);
begin
  ShowFileListDialog();
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  // Always show the save dialog — it pre-fills the current filename
  // and also serves as "Save As" when the user changes the name
  ShowSaveDialog();
end;

procedure TfrmMain.btnRunClick(Sender: TObject);
begin
  CmdRun();
end;

procedure TfrmMain.btnModeClick(Sender: TObject);
begin
  ToggleMode();
end;

procedure TfrmMain.btnThemeClick(Sender: TObject);
begin
  CycleTheme();
end;

procedure TfrmMain.btnFilesClick(Sender: TObject);
begin
  CmdFiles();
end;

procedure TfrmMain.btnHelpClick(Sender: TObject);
begin
  CmdHelp();
end;

// -----------------------------------------------------------------------------
// Dialog Helpers
// -----------------------------------------------------------------------------

procedure TfrmMain.ShowSaveDialog();
var
  DefaultName: string;
begin
  if FFilename <> '' then
    // Pre-fill with current filename (without extension) — acts as "Save As"
    DefaultName := ChangeFileExt(ExtractFileName(FFilename), '')
  else
  begin
    // No file yet — suggest "Anonymous1", "Anonymous2", etc.
    if FAnonymousCounter < 1 then
      FAnonymousCounter := 1;
    DefaultName := 'Anonymous' + IntToStr(FAnonymousCounter);
  end;

  TDialogService.InputQuery(_('DialogSaveAsCaption'), [_('DialogSaveAsPrompt')], [DefaultName],
    procedure(const AResult: TModalResult; const AValues: array of string)
    begin
      if (AResult = mrOk) and (Length(AValues) > 0) and (AValues[0].Trim <> '') then
        CmdSave(AValues[0]);
    end);
end;

procedure TfrmMain.ShowFileListDialog();
begin
  // Guard unsaved changes BEFORE showing the file picker — more professional UX
  ConfirmDiscardChanges(
    procedure
    begin
      PopulateFilePicker(
        procedure(AFilename: string)
        begin
          if AFilename = '' then
            Exit();
          //The catalogue row loads the browser AND runs it. Loading alone would
          //leave somebody looking at a program when what they asked for was the
          //list it fetches.
          if AFilename = PICK_EXAMPLES then
          begin
            CmdLoad('ExamplesBrowser.bas');
            CmdRun();
          end
          else
            CmdLoad(AFilename);
        end);
    end);
end;

procedure TfrmMain.CreateFilePicker();
var
  LayoutTop: TLayout;
  FontFamily: string;
  FontSize: Single;
begin
  {$IF Defined(ANDROID) or Defined(IOS)}
  FontFamily := 'monospace';
  FontSize := 16;
  {$ELSE}
    {$IFDEF MSWINDOWS}FontFamily := 'Consolas';{$ENDIF}
    {$IFDEF LINUX}FontFamily := 'DejaVu Sans Mono';{$ENDIF}
    {$IFDEF MACOS}FontFamily := 'Menlo';{$ENDIF}
  FontSize := 13;
  {$ENDIF}

  // Main overlay — covers the full content area, hidden by default
  FLayoutFilePicker := TLayout.Create(Self);
  FLayoutFilePicker.Parent := RectBackground;
  FLayoutFilePicker.Align := TAlignLayout.Client;
  FLayoutFilePicker.Visible := False;

  // Background rectangle (themed)
  FRectFilePickerBg := TRectangle.Create(FLayoutFilePicker);
  FRectFilePickerBg.Parent := FLayoutFilePicker;
  FRectFilePickerBg.Align := TAlignLayout.Client;
  FRectFilePickerBg.Fill.Color := FThemes[FCurrentTheme].Background;
  FRectFilePickerBg.Stroke.Color := FThemes[FCurrentTheme].Border;
  FRectFilePickerBg.HitTest := True; // absorb clicks behind the list

  // Top bar: caption + close button
  LayoutTop := TLayout.Create(FRectFilePickerBg);
  LayoutTop.Parent := FRectFilePickerBg;
  LayoutTop.Align := TAlignLayout.Top;
  LayoutTop.Height := 36;
  {$IF Defined(ANDROID) or Defined(IOS)}
  LayoutTop.Height := 48;
  {$ENDIF}

  FlblFilePickerCaption := TLabel.Create(LayoutTop);
  FlblFilePickerCaption.Parent := LayoutTop;
  FlblFilePickerCaption.Align := TAlignLayout.Client;
  FlblFilePickerCaption.Margins.Left := 10;
  FlblFilePickerCaption.StyledSettings := [];
  FlblFilePickerCaption.TextSettings.Font.Family := FontFamily;
  FlblFilePickerCaption.TextSettings.Font.Size := FontSize;
  FlblFilePickerCaption.TextSettings.Font.Style := [TFontStyle.fsBold];
  FlblFilePickerCaption.TextSettings.FontColor := FThemes[FCurrentTheme].Foreground;
  FlblFilePickerCaption.Text := _('FilePickerTitle');

  FbtnFilePickerClose := TSpeedButton.Create(LayoutTop);
  FbtnFilePickerClose.Parent := LayoutTop;
  FbtnFilePickerClose.Align := TAlignLayout.Right;
  FbtnFilePickerClose.Width := 70;
  FbtnFilePickerClose.Text := _('FilePickerCancel');
  FbtnFilePickerClose.StyledSettings := [];
  FbtnFilePickerClose.TextSettings.Font.Family := FontFamily;
  FbtnFilePickerClose.TextSettings.Font.Size := FontSize;
  FbtnFilePickerClose.TextSettings.FontColor := FThemes[FCurrentTheme].ForegroundDim;
  FbtnFilePickerClose.OnClick := FilePickerCloseClick;

  // OPEN button — confirms the selected file
  FbtnFilePickerOpen := TSpeedButton.Create(LayoutTop);
  FbtnFilePickerOpen.Parent := LayoutTop;
  FbtnFilePickerOpen.Align := TAlignLayout.Right;
  FbtnFilePickerOpen.Width := 70;
  FbtnFilePickerOpen.Text := _('FilePickerOpen');
  FbtnFilePickerOpen.StyledSettings := [];
  FbtnFilePickerOpen.TextSettings.Font.Family := FontFamily;
  FbtnFilePickerOpen.TextSettings.Font.Size := FontSize;
  FbtnFilePickerOpen.TextSettings.Font.Style := [TFontStyle.fsBold];
  FbtnFilePickerOpen.TextSettings.FontColor := FThemes[FCurrentTheme].ForegroundDim;
  FbtnFilePickerOpen.Enabled := False; // disabled until a file is selected
  FbtnFilePickerOpen.OnClick := FilePickerOpenClick;

  // Scrollable area for file items
  FScrollFilePicker := TVertScrollBox.Create(FRectFilePickerBg);
  FScrollFilePicker.Parent := FRectFilePickerBg;
  FScrollFilePicker.Align := TAlignLayout.Client;
  FScrollFilePicker.Margins.Left := 5;
  FScrollFilePicker.Margins.Top := 3;
  FScrollFilePicker.Margins.Right := 5;
  FScrollFilePicker.Margins.Bottom := 5;
end;

// -----------------------------------------------------------------------------
// Gutter Drag-to-Scroll
// -----------------------------------------------------------------------------

procedure TfrmMain.CreateGutterOverlay();
begin
  FGutterDragging := False;
  FGutterLastY := 0;

  // Transparent rectangle sitting on top of memoLineNumbers.
  // It captures mouse/touch input so the user can drag to scroll
  // the editor without activating the virtual keyboard (Android)
  // and without selecting gutter text.
  FGutterOverlay := TRectangle.Create(Self);
  FGutterOverlay.Parent := RectLineNumbers;
  FGutterOverlay.Align := TAlignLayout.Client;
  FGutterOverlay.Fill.Kind := TBrushKind.None;
  FGutterOverlay.Stroke.Kind := TBrushKind.None;
  FGutterOverlay.HitTest := True;
  FGutterOverlay.Cursor := crSizeNS;
  FGutterOverlay.BringToFront;

  // Enable touch pan gesture for Android/iOS
  FGutterOverlay.Touch.InteractiveGestures := [TInteractiveGesture.Pan];

  FGutterOverlay.OnMouseDown := GutterOverlayMouseDown;
  FGutterOverlay.OnMouseMove := GutterOverlayMouseMove;
  FGutterOverlay.OnMouseUp := GutterOverlayMouseUp;
end;

procedure TfrmMain.PopulateFilePicker(ACallback: TProc<string>);
var
  Files: TArray<string>;
  I: Integer;
  Fn: string;
  FileSize: Int64;
  Btn: TSpeedButton;
  T: TThemeColors;
  FontFamily: string;
  FontSize, ItemH: Single;
begin
  try
    Files := TDirectory.GetFiles(GetBasePath, '*.bas');
  except
    PrintError(_('ErrorAccessFileDir'));
    Exit();
  end;

  //An empty directory used to close the picker before it opened, which on a
  //fresh install is exactly when somebody most needs the catalogue.
  if (Length(Files) = 0) and
     not System.IOUtils.TFile.Exists(System.IOUtils.TPath.Combine(GetBasePath(), 'ExamplesBrowser.bas')) then
  begin
    PrintLn(_('NoBasFilesFound'));
    PrintReady();
    Exit();
  end;

  // Sort alphabetically
  TArray.Sort<string>(Files, TComparer<string>.Construct(
    function(const Left, Right: string): Integer
    begin
      Result := CompareText(ExtractFileName(Left), ExtractFileName(Right));
    end));

  FFilePickerCallback := ACallback;
  FSelectedFileBtn := nil;  // Reset file selection
  T := FThemes[FCurrentTheme];

  {$IF Defined(ANDROID) or Defined(IOS)}
  FontFamily := 'monospace';
  FontSize := 16;
  ItemH := 48;  // comfortable touch target
  {$ELSE}
    {$IFDEF MSWINDOWS}FontFamily := 'Consolas';{$ENDIF}
    {$IFDEF LINUX}FontFamily := 'DejaVu Sans Mono';{$ENDIF}
    {$IFDEF MACOS}FontFamily := 'Menlo';{$ENDIF}
  FontSize := 13;
  ItemH := 30;
  {$ENDIF}

  // Clear previous file buttons from scroll box
  while FScrollFilePicker.Content.ChildrenCount > 0 do
    FScrollFilePicker.Content.Children[0].Free;

  // Update caption
  FlblFilePickerCaption.Text := Format(_('FilePickerSelectFile'), [Length(Files)]);

  // Theme the overlay (in case theme changed since CreateFilePicker)
  FRectFilePickerBg.Fill.Color := T.Background;
  FRectFilePickerBg.Stroke.Color := T.Border;
  FlblFilePickerCaption.TextSettings.FontColor := T.Foreground;
  FbtnFilePickerClose.TextSettings.FontColor := T.ForegroundDim;
  FbtnFilePickerOpen.TextSettings.FontColor := T.ForegroundDim;
  FbtnFilePickerOpen.Enabled := False; // no file selected yet

  // Create a TSpeedButton per file — reliable across all platforms
  for I := 0 to Length(Files) - 1 do
  begin
    Fn := ExtractFileName(Files[I]);
    try
      FileSize := TFile.GetSize(Files[I]);
    except
      FileSize := 0;
    end;

    Btn := TSpeedButton.Create(FScrollFilePicker);
    Btn.Parent := FScrollFilePicker;
    Btn.Align := TAlignLayout.Top;
    Btn.Height := ItemH;
    Btn.StyledSettings := [];
    Btn.TextSettings.Font.Family := FontFamily;
    Btn.TextSettings.Font.Size := FontSize;
    Btn.TextSettings.FontColor := T.Foreground;
    Btn.TextSettings.HorzAlign := TTextAlign.Leading;
    Btn.Margins.Left := 5;
    Btn.Margins.Right := 5;
    Btn.Margins.Top := 1;
    Btn.Text := Format('  %-28s %6d bytes', [Fn, FileSize]);
    Btn.TagString := Fn;
    Btn.OnClick := FilePickerItemClick;
  end;

  //Created last and then moved to the front, which is what Index := 0 inside
  //it is for.
  AddExamplesRow(FontFamily, FontSize, ItemH);

  // Show the overlay
  FLayoutFilePicker.Visible := True;
  FLayoutFilePicker.BringToFront;

  // Disable main UI elements so the picker acts as a modal overlay
  LayoutToolbar.Enabled := False;
  LayoutConsole.Enabled := False;
  LayoutEditor.Enabled := False;
  LayoutInput.Enabled := False;
end;

//A row that is not a file. It sits above the list, says what it does, and
//runs the browser rather than loading it -- which is the difference between
//"here is a program about examples" and "here are the examples".
procedure TfrmMain.AddExamplesRow(AFontFamily: String; AFontSize, AItemH: Single);
var
  Btn: TSpeedButton;
  T: TThemeColors;
begin
  //Only when the browser is actually there. It arrives on the first run with a
  //network, and offering a row that cannot work is worse than offering none.
  if not System.IOUtils.TFile.Exists(System.IOUtils.TPath.Combine(GetBasePath(), 'ExamplesBrowser.bas')) then
    Exit();

  T := FThemes[FCurrentTheme];
  Btn := TSpeedButton.Create(FScrollFilePicker);
  Btn.Parent := FScrollFilePicker;
  Btn.Align := TAlignLayout.Top;
  Btn.Height := AItemH;
  Btn.StyledSettings := [];
  Btn.TextSettings.Font.Family := AFontFamily;
  Btn.TextSettings.Font.Size := AFontSize;
  Btn.TextSettings.Font.Style := [TFontStyle.fsBold];
  Btn.TextSettings.FontColor := T.Foreground;
  Btn.TextSettings.HorzAlign := TTextAlign.Leading;
  Btn.Margins.Left := 5;
  Btn.Margins.Right := 5;
  Btn.Margins.Top := 1;
  Btn.Text := '  ' + _('FilePickerExamplesRow');
  Btn.TagString := PICK_EXAMPLES;
  Btn.OnClick := FilePickerItemClick;
  //Top-aligned siblings are stacked by their current Position.Y, and only where
  //two share a Y does the parent's list order break the tie. Every row here is
  //created with Y still 0 -- this loop never turns the message queue -- so the
  //tie-break decides all of them, and Index := 0 lifts this one to the top.
  //
  //Measured, not assumed: an earlier comment claimed the reverse of the list
  //rule and the row duly appeared under the files, which a screenshot caught and
  //the compiler never could. If a layout pass is ever provoked partway through
  //this loop, the rows acquire real Y values, the tie-break stops applying and
  //Index := 0 stops moving anything -- so keep the loop free of ProcessMessages,
  //or create this row before the files instead, which works under either rule.
  Btn.Index := 0;
end;

procedure TfrmMain.HideFilePicker();
begin
  FLayoutFilePicker.Visible := False;
  FSelectedFileBtn := nil;

  // Re-enable main UI elements
  LayoutToolbar.Enabled := True;
  LayoutConsole.Enabled := True;
  LayoutEditor.Enabled := True;
  LayoutInput.Enabled := True;
end;

procedure TfrmMain.FilePickerCloseClick(Sender: TObject);
begin
  HideFilePicker();
end;

procedure TfrmMain.FilePickerItemClick(Sender: TObject);
var
  Btn: TSpeedButton;
  T: TThemeColors;
begin
  if not (Sender is TSpeedButton) then
    Exit();

  Btn := TSpeedButton(Sender);
  T := FThemes[FCurrentTheme];

  // Deselect previously highlighted button
  if Assigned(FSelectedFileBtn) and (FSelectedFileBtn <> Btn) then
  begin
    FSelectedFileBtn.TextSettings.FontColor := T.Foreground;
    FSelectedFileBtn.TextSettings.Font.Style := [];
  end;

  // Highlight the clicked button with a distinctive marker
  FSelectedFileBtn := Btn;
  case FCurrentTheme of
    ctGreen: Btn.TextSettings.FontColor := $FFFFFF00; // Yellow on green theme
    ctAmber: Btn.TextSettings.FontColor := $FFFFFFFF; // White on amber theme
    ctWhite: Btn.TextSettings.FontColor := $FF00BFFF; // Blue on white theme
    ctBlue:  Btn.TextSettings.FontColor := $FFFFFF00; // Yellow on blue theme
    ctPink:  Btn.TextSettings.FontColor := $FFFFFF00; // Yellow on pink theme
  else
    Btn.TextSettings.FontColor := $FFFFFF00;
  end;
  Btn.TextSettings.Font.Style := [TFontStyle.fsBold];

  // Enable the OPEN button now that a file is selected
  FbtnFilePickerOpen.Enabled := True;
  FbtnFilePickerOpen.TextSettings.FontColor := T.Foreground;
end;

procedure TfrmMain.FilePickerOpenClick(Sender: TObject);
var
  SelectedFile: string;
begin
  if Assigned(FSelectedFileBtn) then
  begin
    SelectedFile := FSelectedFileBtn.TagString;
    HideFilePicker();

    if Assigned(FFilePickerCallback) and (SelectedFile <> '') then
      FFilePickerCallback(SelectedFile);
  end;
end;

// -----------------------------------------------------------------------------
// Theme Management
// -----------------------------------------------------------------------------

procedure TfrmMain.InitializeThemes();
begin
  // ===== GREEN THEME =====
  FThemes[ctGreen].Name := 'GREEN';
  FThemes[ctGreen].Background := $FF0A0A0A; // Near-black (very dark gray, R:10 G:10 B:10)
  FThemes[ctGreen].BackgroundAlt := $FF151515; // Very dark gray (R:21 G:21 B:21)
  FThemes[ctGreen].Foreground := $FF00FF00; // Pure bright green (lime green)
  FThemes[ctGreen].ForegroundDim := $FF00AA00; // Medium green (darker green)
  FThemes[ctGreen].MemoForeground := $FF00FF00; // Pure bright green (lime green)
  FThemes[ctGreen].MemoForegroundDim := $FF00AA00; // Medium green (darker green)
  FThemes[ctGreen].LineNumbers := $FF666666; // Medium gray (R:102 G:102 B:102)
  FThemes[ctGreen].Border := $FF333333; // Dark gray (R:51 G:51 B:51)

  // ===== AMBER THEME =====
  FThemes[ctAmber].Name := 'AMBER';
  FThemes[ctAmber].Background := $FF0A0800; // Near-black with slight warm tint (R:10 G:8 B:0)
  FThemes[ctAmber].BackgroundAlt := $FF151208; // Very dark brown/sepia (R:21 G:18 B:8)
  FThemes[ctAmber].Foreground := $FFFFB000; // Bright amber/orange-yellow (R:255 G:176 B:0)
  FThemes[ctAmber].ForegroundDim := $FFAA7500; // Dark amber/brownish-orange (R:170 G:117 B:0)
  FThemes[ctAmber].MemoForeground := $FFFFB000; // Bright amber/orange-yellow (R:255 G:176 B:0)
  FThemes[ctAmber].MemoForegroundDim := $FFAA7500; // Dark amber/brownish-orange (R:170 G:117 B:0)
  FThemes[ctAmber].LineNumbers := $FF665500; // Dark olive/brown (R:102 G:85 B:0)
  FThemes[ctAmber].Border := $FF332A00; // Very dark brown (R:51 G:42 B:0)

  // ===== WHITE THEME =====
  FThemes[ctWhite].Name := 'WHITE';
  FThemes[ctWhite].Background := $FF1A1A1A; // Very dark gray (R:26 G:26 B:26)
  FThemes[ctWhite].BackgroundAlt := $FF252525; // Dark gray (R:37 G:37 B:37)
  FThemes[ctWhite].Foreground := $FFFFFFFF; // Pure white (R:255 G:255 B:255)
  FThemes[ctWhite].ForegroundDim := $FFAAAAAA; // Light gray (R:170 G:170 B:170)
  FThemes[ctWhite].MemoForeground := $FFFFFFFF; // Pure white (R:255 G:255 B:255)
  FThemes[ctWhite].MemoForegroundDim := $FFAAAAAA; // Light gray (R:170 G:170 B:170)
  FThemes[ctWhite].LineNumbers := $FF666666; // Medium gray (R:102 G:102 B:102)
  FThemes[ctWhite].Border := $FF444444; // Medium-dark gray (R:68 G:68 B:68)

  // ===== BLUE THEME =====
  FThemes[ctBlue].Name := 'BLUE';
  FThemes[ctBlue].Background := $FF000A14; // Near-black with deep blue tint (R:0 G:10 B:20)
  FThemes[ctBlue].BackgroundAlt := $FF001525; // Very dark navy blue (R:0 G:21 B:37)
  FThemes[ctBlue].Foreground := $FF00BFFF; // Deep sky blue / bright cyan-blue (R:0 G:191 B:255)
  FThemes[ctBlue].ForegroundDim := $FF0080AA; // Medium teal/dark cyan (R:0 G:128 B:170)
  FThemes[ctBlue].MemoForeground := $FF00BFFF; // Deep sky blue / bright cyan-blue (R:0 G:191 B:255)
  FThemes[ctBlue].MemoForegroundDim := $FF0080AA; // Medium teal/dark cyan (R:0 G:128 B:170)
  FThemes[ctBlue].LineNumbers := $FF405060; // Dark blue-gray (R:64 G:80 B:96)
  FThemes[ctBlue].Border := $FF203040; // Very dark blue-gray (R:32 G:48 B:64)

  // ===== PINK THEME =====
  FThemes[ctPink].Name := 'PINK';
  FThemes[ctPink].Background := $FF0A0008; // Near-black with slight magenta tint (R:10 G:0 B:8)
  FThemes[ctPink].BackgroundAlt := $FF150010; // Very dark magenta/purple (R:21 G:0 B:16)
  FThemes[ctPink].Foreground := $FFFF69B4; // Hot pink (R:255 G:105 B:180)
  FThemes[ctPink].ForegroundDim := $FFAA4578; // Dark rose/muted pink (R:170 G:69 B:120)
  FThemes[ctPink].MemoForeground := $FFFF69B4; // Hot pink (R:255 G:105 B:180)
  FThemes[ctPink].MemoForegroundDim := $FFAA4578; // Dark rose/muted pink (R:170 G:69 B:120)
  FThemes[ctPink].LineNumbers := $FF664455; // Dark mauve/plum gray (R:102 G:68 B:85)
  FThemes[ctPink].Border := $FF332233; // Very dark purple-gray (R:51 G:34 B:51)

  {$IFDEF ANDROID}
  // Android memos use native controls with a light background,
  // so override only memo text colors with darker shades

  // --- Green theme Android overrides ---
  FThemes[ctGreen].MemoForeground := $FF006400; // Dark green (R:0 G:100 B:0)
  FThemes[ctGreen].MemoForegroundDim := $FF004D00; // Very dark green (R:0 G:77 B:0)
  FThemes[ctGreen].LineNumbers := $FF404040; // Dark gray (R:64 G:64 B:64)

  // --- Amber theme Android overrides ---
  FThemes[ctAmber].MemoForeground := $FF8B4500; // Dark orange / saddle brown (R:139 G:69 B:0)
  FThemes[ctAmber].MemoForegroundDim := $FF6B3500; // Very dark brown (R:107 G:53 B:0)
  FThemes[ctAmber].LineNumbers := $FF5C4000; // Dark olive-brown (R:92 G:64 B:0)

  // --- White theme Android overrides ---
  FThemes[ctWhite].MemoForeground := $FF000000; // Pure black (R:0 G:0 B:0)
  FThemes[ctWhite].MemoForegroundDim := $FF404040; // Dark gray (R:64 G:64 B:64)
  FThemes[ctWhite].LineNumbers := $FF606060; // Medium-dark gray (R:96 G:96 B:96)

  // --- Blue theme Android overrides ---
  FThemes[ctBlue].MemoForeground := $FF00008B; // Dark blue / navy (R:0 G:0 B:139)
  FThemes[ctBlue].MemoForegroundDim := $FF000066; // Very dark blue (R:0 G:0 B:102)
  FThemes[ctBlue].LineNumbers := $FF404060; // Dark blue-gray (R:64 G:64 B:96)

  // --- Pink theme Android overrides ---
  FThemes[ctPink].MemoForeground := $FF8B0060; // Dark magenta/deep pink (R:139 G:0 B:96)
  FThemes[ctPink].MemoForegroundDim := $FF660048; // Very dark magenta (R:102 G:0 B:72)
  FThemes[ctPink].LineNumbers := $FF604050; // Dark mauve-gray (R:96 G:64 B:80)
  {$ENDIF}
end;

procedure TfrmMain.ApplyTheme(Theme: TColorTheme);
var
  T: TThemeColors;
begin
  FCurrentTheme := Theme;
  T := FThemes[Theme];

  // Backgrounds
  RectBackground.Fill.Color := T.Background;
  RectConsoleBackground.Fill.Color := T.Background;
  RectConsoleBackground.Stroke.Color := T.Border;
  RectEditorBackground.Fill.Color := T.Background;
  RectEditorBackground.Stroke.Color := T.Border;
  RectInputBackground.Fill.Color := T.Background;
  RectInputBackground.Stroke.Color := T.Border;
  RectStatusBackground.Fill.Color := T.BackgroundAlt;
  RectToolbarBackground.Fill.Color := T.BackgroundAlt;
  RectLineNumbers.Fill.Color := T.BackgroundAlt;

  // Transparent style for all platforms (on mobile, AdjustForPlatform
  // has already set ControlType := TControlType.Styled so this works)
  //Console.StyleLookup := 'transparentedit';
  //Console.StyledSettings := [];
  Editor.StyleLookup := 'transparentedit';
  Editor.StyledSettings := [];
  edtCommand.StyleLookup := 'transparentedit';
  edtCommand.StyledSettings := [];

  // On Linux, TMemo with 'transparentedit' in narrow layouts fails to
  // render text.  Skip the transparent style and paint the background
  // via RectLineNumbers instead.
  {$IFDEF LINUX}
  memoLineNumbers.StyledSettings := [];
  {$ELSE}
  memoLineNumbers.StyleLookup := 'transparentedit';
  memoLineNumbers.StyledSettings := [];
  {$ENDIF}

  // Update the rich console
  if Assigned(FConsole) then
  begin
    FConsole.Colors := GetSyntaxColors(Theme);
    FConsole.UpdateBackground();
  end;

  // Force-clear background as safety net for platforms where
  // transparentedit may not fully remove the background
  //MakeMemoTransparent(Console);
  MakeMemoTransparent(Editor);
  {$IFNDEF LINUX}
  MakeMemoTransparent(memoLineNumbers);
  {$ENDIF}

  // Theme colors — unified for all platforms (bright on dark)
  //Console.TextSettings.FontColor := T.Foreground;
  Editor.TextSettings.FontColor := T.Foreground;
  edtCommand.TextSettings.FontColor := T.Foreground;
  memoLineNumbers.TextSettings.FontColor := T.LineNumbers;
  // Memo/editor text uses MemoForeground (darker on Android, same as Foreground elsewhere)
  //Console.TextSettings.FontColor := T.MemoForeground;
  Editor.TextSettings.FontColor := T.MemoForeground;
  edtCommand.TextSettings.FontColor := T.MemoForeground;
  memoLineNumbers.TextSettings.FontColor := T.LineNumbers;

  // Set fonts based on platform
  {$IF Defined(ANDROID) or Defined(IOS)}
  //Console.TextSettings.Font.Family := 'monospace';
  Editor.TextSettings.Font.Family := 'monospace';
  memoLineNumbers.TextSettings.Font.Family := 'monospace';
  edtCommand.TextSettings.Font.Family := 'monospace';
  lblPrompt.TextSettings.Font.Family := 'monospace';
  lblTitle.TextSettings.Font.Family := 'monospace';
  lblFKeys.TextSettings.Font.Family := 'monospace';
  lblStatusMode.TextSettings.Font.Family := 'monospace';
  lblStatusFile.TextSettings.Font.Family := 'monospace';
  lblStatusLines.TextSettings.Font.Family := 'monospace';
  lblStatusTheme.TextSettings.Font.Family := 'monospace';
  {$ENDIF}
  {$IFDEF MSWINDOWS}
  //Console.TextSettings.Font.Family := 'Consolas';
  Editor.TextSettings.Font.Family := 'Consolas';
  memoLineNumbers.TextSettings.Font.Family := 'Consolas';
  edtCommand.TextSettings.Font.Family := 'Consolas';
  lblPrompt.TextSettings.Font.Family := 'Consolas';
  lblTitle.TextSettings.Font.Family := 'Consolas';
  lblFKeys.TextSettings.Font.Family := 'Consolas';
  lblStatusMode.TextSettings.Font.Family := 'Consolas';
  lblStatusFile.TextSettings.Font.Family := 'Consolas';
  lblStatusLines.TextSettings.Font.Family := 'Consolas';
  lblStatusTheme.TextSettings.Font.Family := 'Consolas';
  {$ENDIF}
  {$IFDEF LINUX}
  //Console.TextSettings.Font.Family := 'DejaVu Sans Mono';
  Editor.TextSettings.Font.Family := 'DejaVu Sans Mono';
  memoLineNumbers.TextSettings.Font.Family := 'DejaVu Sans Mono';
  edtCommand.TextSettings.Font.Family := 'DejaVu Sans Mono';
  lblPrompt.TextSettings.Font.Family := 'DejaVu Sans Mono';
  lblTitle.TextSettings.Font.Family := 'DejaVu Sans Mono';
  lblFKeys.TextSettings.Font.Family := 'DejaVu Sans Mono';
  lblStatusMode.TextSettings.Font.Family := 'DejaVu Sans Mono';
  lblStatusFile.TextSettings.Font.Family := 'DejaVu Sans Mono';
  lblStatusLines.TextSettings.Font.Family := 'DejaVu Sans Mono';
  lblStatusTheme.TextSettings.Font.Family := 'DejaVu Sans Mono';
  {$ENDIF}
  {$IFDEF MACOS}
  //Console.TextSettings.Font.Family := 'Menlo';
  Editor.TextSettings.Font.Family := 'Menlo';
  memoLineNumbers.TextSettings.Font.Family := 'Menlo';
  edtCommand.TextSettings.Font.Family := 'Menlo';
  lblPrompt.TextSettings.Font.Family := 'Menlo';
  lblTitle.TextSettings.Font.Family := 'Menlo';
  lblFKeys.TextSettings.Font.Family := 'Menlo';
  lblStatusMode.TextSettings.Font.Family := 'Menlo';
  lblStatusFile.TextSettings.Font.Family := 'Menlo';
  lblStatusLines.TextSettings.Font.Family := 'Menlo';
  lblStatusTheme.TextSettings.Font.Family := 'Menlo';
  {$ENDIF}

  // Labels always use theme colors (they work on all platforms)
  lblPrompt.TextSettings.FontColor := T.Foreground;
  lblTitle.TextSettings.FontColor := T.Foreground;
  lblFKeys.TextSettings.FontColor := T.ForegroundDim;
  lblStatusMode.TextSettings.FontColor := T.Foreground;
  lblStatusFile.TextSettings.FontColor := T.ForegroundDim;
  lblStatusLines.TextSettings.FontColor := T.ForegroundDim;
  lblStatusTheme.TextSettings.FontColor := T.ForegroundDim;

  // Toolbar buttons
  btnNew.StyledSettings := [];
  btnLoad.StyledSettings := [];
  btnSave.StyledSettings := [];
  btnRun.StyledSettings := [];
  btnMode.StyledSettings := [];
  btnTheme.StyledSettings := [];
  btnFiles.StyledSettings := [];
  btnHelp.StyledSettings := [];

  btnNew.TextSettings.FontColor := T.Foreground;
  btnLoad.TextSettings.FontColor := T.Foreground;
  btnSave.TextSettings.FontColor := T.Foreground;
  btnRun.TextSettings.FontColor := T.Foreground;
  btnMode.TextSettings.FontColor := T.Foreground;
  btnTheme.TextSettings.FontColor := T.Foreground;
  btnFiles.TextSettings.FontColor := T.Foreground;
  btnHelp.TextSettings.FontColor := T.Foreground;

  {$IF not Defined(ANDROID) and not Defined(IOS)}
  // Bold text for desktop toolbar buttons
  btnNew.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnLoad.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnSave.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnRun.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnMode.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnTheme.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnFiles.TextSettings.Font.Style := [TFontStyle.fsBold];
  btnHelp.TextSettings.Font.Style := [TFontStyle.fsBold];

    {$IFDEF MSWINDOWS}
    btnNew.TextSettings.Font.Family := 'Consolas';
    btnLoad.TextSettings.Font.Family := 'Consolas';
    btnSave.TextSettings.Font.Family := 'Consolas';
    btnRun.TextSettings.Font.Family := 'Consolas';
    btnMode.TextSettings.Font.Family := 'Consolas';
    btnTheme.TextSettings.Font.Family := 'Consolas';
    btnFiles.TextSettings.Font.Family := 'Consolas';
    btnHelp.TextSettings.Font.Family := 'Consolas';
    {$ENDIF}
    {$IFDEF LINUX}
    btnNew.TextSettings.Font.Family := 'DejaVu Sans Mono';
    btnLoad.TextSettings.Font.Family := 'DejaVu Sans Mono';
    btnSave.TextSettings.Font.Family := 'DejaVu Sans Mono';
    btnRun.TextSettings.Font.Family := 'DejaVu Sans Mono';
    btnMode.TextSettings.Font.Family := 'DejaVu Sans Mono';
    btnTheme.TextSettings.Font.Family := 'DejaVu Sans Mono';
    btnFiles.TextSettings.Font.Family := 'DejaVu Sans Mono';
    btnHelp.TextSettings.Font.Family := 'DejaVu Sans Mono';
    {$ENDIF}
    {$IFDEF MACOS}
    btnNew.TextSettings.Font.Family := 'Menlo';
    btnLoad.TextSettings.Font.Family := 'Menlo';
    btnSave.TextSettings.Font.Family := 'Menlo';
    btnRun.TextSettings.Font.Family := 'Menlo';
    btnMode.TextSettings.Font.Family := 'Menlo';
    btnTheme.TextSettings.Font.Family := 'Menlo';
    btnFiles.TextSettings.Font.Family := 'Menlo';
    btnHelp.TextSettings.Font.Family := 'Menlo';
    {$ENDIF}
  {$ENDIF}

  lblStatusTheme.Text := T.Name;

  // Search bar theming
  if Assigned(FRectSearchBackground) then
  begin
    FRectSearchBackground.Fill.Color := T.BackgroundAlt;
    FRectSearchBackground.Stroke.Color := T.Border;

    FedtSearch.StyleLookup := 'transparentedit';
    FedtSearch.StyledSettings := [];
    FedtSearch.TextSettings.FontColor := T.MemoForeground;
    FedtReplace.StyleLookup := 'transparentedit';
    FedtReplace.StyledSettings := [];
    FedtReplace.TextSettings.FontColor := T.MemoForeground;

    FlblMatchInfo.TextSettings.FontColor := T.ForegroundDim;

    FbtnFindNext.StyledSettings := [];
    FbtnFindNext.TextSettings.FontColor := T.Foreground;
    FbtnFindPrev.StyledSettings := [];
    FbtnFindPrev.TextSettings.FontColor := T.Foreground;
    FbtnReplace.StyledSettings := [];
    FbtnReplace.TextSettings.FontColor := T.Foreground;
    FbtnReplaceAll.StyledSettings := [];
    FbtnReplaceAll.TextSettings.FontColor := T.Foreground;
    FbtnSearchClose.StyledSettings := [];
    FbtnSearchClose.TextSettings.FontColor := T.Foreground;
  end;

  // FIND toolbar button theming
  if Assigned(FbtnFindToolbar) then
  begin
    FbtnFindToolbar.StyledSettings := [];
    FbtnFindToolbar.TextSettings.FontColor := T.Foreground;
  end;

  // COPY toolbar button theming
  if Assigned(FbtnCopyToolbar) then
  begin
    FbtnCopyToolbar.StyledSettings := [];
    FbtnCopyToolbar.TextSettings.FontColor := T.Foreground;
  end;

  // File picker overlay theming
  if Assigned(FRectFilePickerBg) then
  begin
    FRectFilePickerBg.Fill.Color := T.Background;
    FRectFilePickerBg.Stroke.Color := T.Border;
  end;
  if Assigned(FlblFilePickerCaption) then
    FlblFilePickerCaption.TextSettings.FontColor := T.Foreground;
  if Assigned(FbtnFilePickerClose) then
  begin
    FbtnFilePickerClose.StyledSettings := [];
    FbtnFilePickerClose.TextSettings.FontColor := T.ForegroundDim;
  end;
  if Assigned(FbtnFilePickerOpen) then
  begin
    FbtnFilePickerOpen.StyledSettings := [];
    if FbtnFilePickerOpen.Enabled then
      FbtnFilePickerOpen.TextSettings.FontColor := T.Foreground
    else
      FbtnFilePickerOpen.TextSettings.FontColor := T.ForegroundDim;
  end;
end;

procedure TfrmMain.CycleTheme();
begin
  if FCurrentTheme = High(TColorTheme) then
    ApplyTheme(Low(TColorTheme))
  else
    ApplyTheme(Succ(FCurrentTheme));

  if FInterfaceMode = imCommand then
    PrintLn(Format(_('ThemeChanged'), [FThemes[FCurrentTheme].Name]));
end;

// -----------------------------------------------------------------------------
// Mode Management
// -----------------------------------------------------------------------------

procedure TfrmMain.SetInterfaceMode(Mode: TInterfaceMode);
begin
  FInterfaceMode := Mode;

  case Mode of
    imCommand:
    begin
      if LayoutEditor.Visible then
        SyncProgramToEditor();

      LayoutConsole.Visible := True;
      LayoutEditor.Visible := False;
      LayoutInput.Visible := True;
      lblStatusMode.Text := _('ModeLabelCommand');
      btnMode.Text := _('BtnModeToEditor');
      edtCommand.SetFocus();
    end;
    imEditor:
    begin
      SyncEditorToProgram();

      LayoutConsole.Visible := False;
      LayoutEditor.Visible := True;
      LayoutInput.Visible := False;
      lblStatusMode.Text := _('ModeLabelEditor');
      btnMode.Text := _('BtnModeToCMD');
      UpdateLineNumbers();
      Editor.SetFocus();
    end;
  end;

  UpdateStatusBar();
end;

procedure TfrmMain.ToggleMode();
begin
  if FInterfaceMode = imCommand then
    SetInterfaceMode(imEditor)
  else
    SetInterfaceMode(imCommand);
end;

procedure TfrmMain.SyncEditorToProgram();
begin
  Editor.Text := FProgram.Text;
end;

procedure TfrmMain.SyncProgramToEditor();
var
  I: Integer;
  SL: TStringList;
begin
  FProgram.Clear();
  // Read text via TStringList instead of Editor.Lines directly.
  // On Android, Editor.Lines may return stale data if the native
  // control hasn't flushed its internal buffer yet.
  SL := TStringList.Create();
  try
    SL.Text := Editor.Text;
    for I := 0 to SL.Count - 1 do
    begin
      if SL[I].Trim <> '' then
        FProgram.Add(SL[I]);
    end;
  finally
    SL.Free();
  end;

  FormatLoadedSource();
end;

// -----------------------------------------------------------------------------
// Status Bar
// -----------------------------------------------------------------------------

procedure TfrmMain.ApplySafeArea(const AInsets: TRectF);
begin
  if RectBackground = nil then
    Exit;
  //Assigning the whole rect at once, so a phone that reports only a top inset
  //does not keep a bottom one from a previous orientation.
  RectBackground.Padding.Rect := AInsets;
end;

procedure TfrmMain.FormSafeAreaChanged(Sender: TObject; const AInsets: TRectF);
begin
  ApplySafeArea(AInsets);
end;

procedure TfrmMain.QuerySafeArea();
var
  Svc: IFMXWindowSafeAreaService;
begin
  //No conditional compilation: on a desktop the service is simply not
  //registered and this does nothing, which is the right answer there -- a
  //window has no system bars to sit under.
  if TPlatformServices.Current.SupportsPlatformService(IFMXWindowSafeAreaService, Svc) then
    ApplySafeArea(Svc.GetSafeAreaInsets(Self));
end;

procedure TfrmMain.UpdateStatusBar();
var
  LineCount: Integer;
  ModStr: string;
begin
  if FFilename = '' then
    lblStatusFile.Text := _('StatusNoFile')
  else
  begin
    if FModified then
      ModStr := ' *'
    else
      ModStr := '';
    lblStatusFile.Text := ExtractFileName(FFilename) + ModStr;
  end;

  if FInterfaceMode = imEditor then
    LineCount := Editor.Lines.Count
  else
    LineCount := FProgram.Count;

  if LineCount = 1 then
    lblStatusLines.Text := _('StatusOneLine')
  else
    lblStatusLines.Text := Format(_('StatusLines'), [LineCount]);
end;

// -----------------------------------------------------------------------
// Step 3: UppercaseKeywords - processes a single line
// Walks character by character, preserving strings and comments.
// -----------------------------------------------------------------------
//CONST and ELSEIF are keywords only where a statement begins and only when
//they are not being assigned to -- the same rule the parser applies, and for
//the same reason. Neither is in the lexer's keyword table, so both remain
//usable as ordinary variable and function names: `const = 7` compiles and runs,
//and uppercasing it there would tell the reader something untrue.
function TfrmMain.IsContextualKeyword(const Word: string;
  AtStatementStart: Boolean; const Rest: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  if not AtStatementStart then
    Exit();
  if not (SameText(Word, 'CONST') or SameText(Word, 'ELSEIF')) then
    Exit();
  //What follows, ignoring spaces. An '=' means this is an assignment to a
  //variable that happens to have the name.
  i := 1;
  while (i <= Length(Rest)) and (Rest[i] = ' ') do
    Inc(i);
  Result := (i > Length(Rest)) or (Rest[i] <> '=');
end;

function TfrmMain.UppercaseKeywords(const Line: string): string;
var
  I, Len, WordStart: Integer;
  Ch: Char;
  Word: string;
  InString: Boolean;
  StringChar: Char;
  AtStatementStart: Boolean;
begin
  Result := '';
  Len := Length(Line);
  I := 1;
  InString := False;
  StringChar := #0;
  //True until the line's first word, and again after every ':'. This is what
  //lets CONST and ELSEIF be recognised where the parser recognises them.
  AtStatementStart := True;

  while I <= Len do
  begin
    Ch := Line[I];

    // --- Handle comment (') - copy rest of line as-is ---
    if (not InString) and (Ch = '''') then
    begin
      Result := Result + Copy(Line, I, Len - I + 1);
      Exit();
    end;

    // --- Handle REM comment ---
    if (not InString) and (I + 2 <= Len) and
       (UpperCase(Copy(Line, I, 4)) = 'REM ') then
    begin
      // Uppercase the REM keyword, copy rest as-is
      Result := Result + 'REM' + Copy(Line, I + 3, Len - I - 2);
      Exit();
    end;

    // --- Handle string literals - copy verbatim ---
    if InString then
    begin
      Result := Result + Ch;
      if Ch = StringChar then
        InString := False;
      Inc(I);
      Continue;
    end;

    if (Ch = '"') then
    begin
      InString := True;
      StringChar := Ch;
      Result := Result + Ch;
      Inc(I);
      Continue;
    end;

    // --- Handle identifiers/keywords ---
    if CharInSet(Ch, ['A'..'Z', 'a'..'z', '_']) then
    begin
      WordStart := I;
      while (I <= Len) and CharInSet(Line[I], ['A'..'Z', 'a'..'z', '0'..'9', '_']) do
        Inc(I);

      Word := Copy(Line, WordStart, I - WordStart);

      if IsKeyword(Word) or
         IsContextualKeyword(Word, AtStatementStart, Copy(Line, I, Len - I + 1)) then
        Result := Result + UpperCase(Word)
      else
        Result := Result + Word; // preserve original case for identifiers

      AtStatementStart := False;
      Continue; // I already advanced past the word
    end;

    // --- Everything else (operators, numbers, spaces, etc.) ---
    if Ch = ':' then
      AtStatementStart := True
    else if Ch <> ' ' then
      AtStatementStart := False;
    Result := Result + Ch;
    Inc(I);
  end;
end;

procedure TfrmMain.UpdateLineNumbers();
var
  I, LineCount: Integer;
  SL: TStringList;
  EdText: string;
begin
  SL := TStringList.Create();
  try
    // Snapshot the editor text — avoid repeated property access
    EdText := Editor.Text;

    // Count lines from Editor.Text, not Editor.Lines —
    // Editor.Lines can be stale on Android and after paste on all platforms
    LineCount := 1;
    for I := 1 to Length(EdText) do
    begin
      if EdText[I] = #10 then
        Inc(LineCount);
    end;

    // If editor is completely empty, show at least line 1
    if EdText = '' then
      LineCount := 1;

    for I := 1 to LineCount do
      SL.Add(IntToStr(I));
    memoLineNumbers.Text := SL.Text;

    // Keep gutter scroll in sync with editor
    memoLineNumbers.ViewportPosition :=
      PointF(0, Editor.ViewportPosition.Y);
  finally
    SL.Free();
  end;
end;

procedure TfrmMain.DeferredUpdateLineNumbers();
begin
  // Schedule the update to run after the current event cycle completes.
  // This ensures the TMemo internal text buffer is fully committed
  // (critical for paste operations and Android platform).
  TThread.ForceQueue(nil,
    procedure
    begin
      if not FClosing then
      begin
        UpdateLineNumbers();
        // Schedule a second update one cycle later — Android's native TMemo
        // can sometimes commit pasted text across two event cycles
        TThread.ForceQueue(nil,
          procedure
          begin
            if not FClosing then
              UpdateLineNumbers();
          end);
      end;
    end);
end;

// -----------------------------------------------------------------------------
// BASIC Engine
// -----------------------------------------------------------------------------

//procedure TfrmMain.HandlePrintOutput(Sender: TObject; const Text: string; IsClear: Boolean);
//begin
//  // O texto já foi adicionado ao Console.Lines pelo PrintProc
//  // Aqui só precisamos atualizar a UI
//  Console.GoToTextEnd();
//  Application.ProcessMessages();
//end;
procedure TfrmMain.HandlePrintOutput(Sender: TObject; const Text: string; IsClear: Boolean);
begin
  // Text was already added to FConsole.Lines by PrintProc
  // Just update UI
  FConsole.GoToTextEnd();
  Application.ProcessMessages();
end;

procedure TfrmMain.HostInput(const ACaption: String; const ALabels: array of String;
  const ADefaults: array of String; const ADone: TInputDoneProc);
var
  Values: array of String;
  I: Integer;
begin
  SetLength(Values, Length(ADefaults));
  for I := 0 to High(ADefaults) do
    Values[I] := ADefaults[I];

  TDialogServiceAsync.InputQuery(ACaption, ALabels, Values,
    procedure(const AResult: TModalResult; const AValues: array of string)
    begin
      ADone(AResult = mrOk, AValues);
    end);
end;

procedure TfrmMain.HostConfirm(const AMessage: String; const ADone: TConfirmDoneProc);
begin
  //Timers belong to the host, so pausing them around a breakpoint is the
  //host's job. The engine only asks the question.
  TimerLib.PauseAllTimers();

  TDialogServiceAsync.MessageDialog(AMessage, TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbYes, 0,
    procedure(const AResult: TModalResult)
    begin
      if AResult <> mrNo then
        TimerLib.ResumeAllTimers();
      ADone(AResult <> mrNo);
    end);
end;

procedure TfrmMain.HostPumpMessages();
begin
  Application.ProcessMessages();
end;

procedure TfrmMain.HostHandleOneMessage();
begin
  Application.HandleMessage();
end;

procedure TfrmMain.HostSetClipboard(const AText: string);
var
  Svc: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService,
                                                       IInterface(Svc)) then
    Svc.SetClipboard(TValue.From(AText))
  else
    //StrLib turns an exception here into ERR_CLIPBOARD_ERROR, which is what
    //the missing platform service used to produce.
    raise Exception.Create('no clipboard service on this platform');
end;

function TfrmMain.HostGetClipboard(): string;
var
  Svc: IFMXClipboardService;
begin
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService,
                                                       IInterface(Svc)) then
    Result := Svc.GetClipboard.AsString
  else
    raise Exception.Create('no clipboard service on this platform');
end;

procedure TfrmMain.WireHostServices();
begin
  HostServices.PumpMessages := HostPumpMessages;
  HostServices.HandleOneMessage := HostHandleOneMessage;
  HostServices.SetClipboardText := HostSetClipboard;
  HostServices.GetClipboardText := HostGetClipboard;
end;

procedure TfrmMain.HostYield();
begin
  Application.ProcessMessages();
end;

procedure TfrmMain.InitBASICEngine();
begin
  // === CLEANUP ORDER IS CRITICAL ===
  // 1. Timers  — stop async callbacks that reference engine/forms/arrays
  // 2. Forms   — close/free FMX forms (children auto-freed via parent ownership)
  // 3. Engine  — destroy execution engine (clears HeapMem pointers)
  // 4. GC      — free non-visual objects (arrays, dicts, JSON, etc.)

  // 1. Kill all timers first
  TimerLib.CleanupAllTimers();

  // 2. Close and free all applet forms
  FormLib.CleanupAllForms();

  // 3. Free the engine
  if Assigned(FBasic) then
    FreeAndNil(FBasic);

  // 4. Free the GC (only non-visual objects remain)
  if Assigned(GC) then
    FreeAndNil(GC);

  // 5. Create fresh GC — plain TObject, no owner
  GC := TGarbageCollector.Create();

  // 6. Create fresh engine
  FBasic := TBasicEngine.Create(); // Now it's OK.
  FBasic.ScriptTimeOut := 0;
  FBasic.InputProc := HostInput;
  //BREAKPOINT parks the VM until this answers, so it is only safe where the
  //platform can deliver a modal answer with the calling thread blocked. Left
  //unset, the engine reports the breakpoint frame to the trace and carries on,
  //instead of waiting for a reply that can never arrive.
  if CanPauseForHostDialog then
    FBasic.ConfirmProc := HostConfirm;
  FBasic.YieldProc := HostYield;
  WireHostServices();

  // Register all libraries
  ArrayLib.RegisterArrayFuncs(FBasic.Functions);
  DateTimeLib.RegisterDateTimeFuncs(FBasic.Functions);
  StdLib.RegisterStdFuncs(FBasic.Functions);
  NumLib.RegisterNumFuncs(FBasic.Functions);
  StrLib.RegisterStrFuncs(FBasic.Functions);
  SysLib.RegisterSysFuncs(FBasic.Functions);
  PlatformInfoLib.RegisterPlatformInfoFuncs(FBasic.Functions);
  DictLib.RegisterDictFuncs(FBasic.Functions);
  ConfigLib.RegisterConfigFuncs(FBasic.Functions);
  StrListLib.RegisterStringsFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  JsonLib.RegisterJsonFuncs(FBasic.Functions);
  RegexLib.RegisterRegexFuncs(FBasic.Functions);
  Base64Lib.RegisterBase64Funcs(FBasic.Functions);
  GZipLib.RegisterGzipFuncs(FBasic.Functions);
  ZipLib.RegisterZipFuncs(FBasic.Functions);
  HttpLib.RegisterHttpFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  FormLib.RegisterFormFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  LayoutLib.RegisterLayoutFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  RectangleLib.RegisterRectangleFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  LabelLib.RegisterLabelFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  EditLib.RegisterEditFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  MemoLib.RegisterMemoFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  ButtonLib.RegisterButtonFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  SpeedButtonLib.RegisterSpeedButtonFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  ComboBoxLib.RegisterComboBoxFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  ListBoxLib.RegisterListBoxFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  CheckBoxLib.RegisterCheckBoxFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  RadioButtonLib.RegisterRadioButtonFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  PanelLib.RegisterPanelFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  ScrollBoxLib.RegisterScrollBoxFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  CircleLib.RegisterCircleFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  RoundRectLib.RegisterRoundRectFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  EllipseLib.RegisterEllipseFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  ArcLib.RegisterArcFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  PieLib.RegisterPieFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  LineLib.RegisterLineFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  CalloutRectangleLib.RegisterCalloutRectangleFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  PathLib.RegisterPathFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  ImageLib.RegisterImageFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  SwitchLib.RegisterSwitchFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  StringGridLib.RegisterStringGridFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  ProgressBarLib.RegisterProgressBarFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  TrackBarLib.RegisterTrackBarFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  TimerLib.RegisterTimerFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  ColorAnimationLib.RegisterColorAnimationFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  FloatAnimationLib.RegisterFloatAnimationFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  IntAnimationLib.RegisterIntAnimationFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  BitmapListAnimationLib.RegisterBitmapListAnimationFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  PathAnimationLib.RegisterPathAnimationFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  RectAnimationLib.RegisterRectAnimationFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  BlurEffectLib.RegisterBlurEffectFuncs(FBasic.Functions);
  GlowEffectLib.RegisterGlowEffectFuncs(FBasic.Functions);
  ShadowEffectLib.RegisterShadowEffectFuncs(FBasic.Functions);
  BevelEffectLib.RegisterBevelEffectFuncs(FBasic.Functions);
  ColorKeyAlphaEffectLib.RegisterColorKeyAlphaEffectFuncs(FBasic.Functions);
  InnerGlowEffectLib.RegisterInnerGlowEffectFuncs(FBasic.Functions);
  MonochromeEffectLib.RegisterMonochromeEffectFuncs(FBasic.Functions);
  ReflectionEffectLib.RegisterReflectionEffectFuncs(FBasic.Functions);
  ContrastEffectLib.RegisterContrastEffectFuncs(FBasic.Functions);
  HueAdjustEffectLib.RegisterHueAdjustEffectFuncs(FBasic.Functions);
  InvertEffectLib.RegisterInvertEffectFuncs(FBasic.Functions);
  SepiaEffectLib.RegisterSepiaEffectFuncs(FBasic.Functions);
  EmbossEffectLib.RegisterEmbossEffectFuncs(FBasic.Functions);
  PaperSketchEffectLib.RegisterPaperSketchEffectFuncs(FBasic.Functions);
  PencilStrokeEffectLib.RegisterPencilStrokeEffectFuncs(FBasic.Functions);
  PixelateEffectLib.RegisterPixelateEffectFuncs(FBasic.Functions);
  SharpenEffectLib.RegisterSharpenEffectFuncs(FBasic.Functions);
  ToonEffectLib.RegisterToonEffectFuncs(FBasic.Functions);
  BandsEffectLib.RegisterBandsEffectFuncs(FBasic.Functions);
  MagnifyEffectLib.RegisterMagnifyEffectFuncs(FBasic.Functions);
  RippleEffectLib.RegisterRippleEffectFuncs(FBasic.Functions);
  SwirlEffectLib.RegisterSwirlEffectFuncs(FBasic.Functions);
  WaveEffectLib.RegisterWaveEffectFuncs(FBasic.Functions);
  WrapEffectLib.RegisterWrapEffectFuncs(FBasic.Functions);
  BlindTransitionEffectLib.RegisterBlindTransitionEffectFuncs(FBasic.Functions);
  CircleTransitionEffectLib.RegisterCircleTransitionEffectFuncs(FBasic.Functions);
  DissolveTransitionEffectLib.RegisterDissolveTransitionEffectFuncs(FBasic.Functions);
  SlideTransitionEffectLib.RegisterSlideTransitionEffectFuncs(FBasic.Functions);
  SwipeTransitionEffectLib.RegisterSwipeTransitionEffectFuncs(FBasic.Functions);
  FadeTransitionEffectLib.RegisterFadeTransitionEffectFuncs(FBasic.Functions);
  BandedSwirlTransitionEffectLib.RegisterBandedSwirlTransitionEffectFuncs(FBasic.Functions);
  BloodTransitionEffectLib.RegisterBloodTransitionEffectFuncs(FBasic.Functions);
  BlurTransitionEffectLib.RegisterBlurTransitionEffectFuncs(FBasic.Functions);
  BrightTransitionEffectLib.RegisterBrightTransitionEffectFuncs(FBasic.Functions);
  CrumpleTransitionEffectLib.RegisterCrumpleTransitionEffectFuncs(FBasic.Functions);
  DropTransitionEffectLib.RegisterDropTransitionEffectFuncs(FBasic.Functions);
  LineTransitionEffectLib.RegisterLineTransitionEffectFuncs(FBasic.Functions);
  MagnifyTransitionEffectLib.RegisterMagnifyTransitionEffectFuncs(FBasic.Functions);
  PixelateTransitionEffectLib.RegisterPixelateTransitionEffectFuncs(FBasic.Functions);
  RotateCrumpleTransitionEffectLib.RegisterRotateCrumpleTransitionEffectFuncs(FBasic.Functions);
  SaturateTransitionEffectLib.RegisterSaturateTransitionEffectFuncs(FBasic.Functions);
  ShapeTransitionEffectLib.RegisterShapeTransitionEffectFuncs(FBasic.Functions);
  SwirlTransitionEffectLib.RegisterSwirlTransitionEffectFuncs(FBasic.Functions);
  WaterTransitionEffectLib.RegisterWaterTransitionEffectFuncs(FBasic.Functions);
  WaveTransitionEffectLib.RegisterWaveTransitionEffectFuncs(FBasic.Functions);
  WiggleTransitionEffectLib.RegisterWiggleTransitionEffectFuncs(FBasic.Functions);
  RippleTransitionEffectLib.RegisterRippleTransitionEffectFuncs(FBasic.Functions);
  BoxBlurEffectLib.RegisterBoxBlurEffectFuncs(FBasic.Functions);
  DirectionalBlurEffectLib.RegisterDirectionalBlurEffectFuncs(FBasic.Functions);
  GaussianBlurEffectLib.RegisterGaussianBlurEffectFuncs(FBasic.Functions);
  RadialBlurEffectLib.RegisterRadialBlurEffectFuncs(FBasic.Functions);
  BloomEffectLib.RegisterBloomEffectFuncs(FBasic.Functions);
  GloomEffectLib.RegisterGloomEffectFuncs(FBasic.Functions);
  AffineTransformEffectLib.RegisterAffineTransformEffectFuncs(FBasic.Functions);
  CropEffectLib.RegisterCropEffectFuncs(FBasic.Functions);
  PerspectiveTransformEffectLib.RegisterPerspectiveTransformEffectFuncs(FBasic.Functions);
  TilerEffectLib.RegisterTilerEffectFuncs(FBasic.Functions);
  NormalBlendEffectLib.RegisterNormalBlendEffectFuncs(FBasic.Functions);
  BandedSwirlEffectLib.RegisterBandedSwirlEffectFuncs(FBasic.Functions);
  PinchEffectLib.RegisterPinchEffectFuncs(FBasic.Functions);
  SmoothMagnifyEffectLib.RegisterSmoothMagnifyEffectFuncs(FBasic.Functions);
  MaskToAlphaEffectLib.RegisterMaskToAlphaEffectFuncs(FBasic.Functions);
  FillRGBEffectLib.RegisterFillRGBEffectFuncs(FBasic.Functions);
  FillEffectLib.RegisterFillEffectFuncs(FBasic.Functions);
  MediaPlayerLib.RegisterMediaPlayerFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  SQLiteLib.RegisterSqliteFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  IOUtilsLib.RegisterIOUtilsFuncs(FBasic.Functions);
  AILib.RegisterAIFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  RAGLib.RegisterRAGFuncs(FBasic.Functions);

  FBasic.OnPrintOutput := HandlePrintOutput;
end;

procedure TfrmMain.SetFilename(Value: string);
begin
  if Value.ToLower.CompareTo(FFilename.ToLower) <> 0 then
  begin
    FFilename := Value;
    UpdateStatusBar();
  end;
end;

function TfrmMain.GetBasePath(): string;
begin
  {$IF Defined(ANDROID)}
  Result := System.IOUtils.TPath.GetDocumentsPath;
  {$ELSE}
  Result := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, 'Plan9Basic');
  {$ENDIF}

  if not System.IOUtils.TDirectory.Exists(Result) then
    System.IOUtils.TDirectory.CreateDirectory(Result);
end;

// Returns the folder where the Plan9Basic executable lives (desktop) or the
// writable documents area (mobile).  Translations.ini is placed here so that
// it sits next to the binary on all platforms.
function TfrmMain.GetAppPath(): string;
begin
  {$IF Defined(ANDROID) or Defined(IOS)}
  Result := System.IOUtils.TPath.GetDocumentsPath;
  {$ELSE}
  Result := ExtractFilePath(ParamStr(0));
  {$ENDIF}
end;

// Downloads AURL into ADestPath using THTTPClient.
// Returns True only when the server replies 200 and the write succeeds.
// Any incomplete file is deleted before returning False.
function TfrmMain.DownloadFile(const AURL, ADestPath: string): Boolean;
var
  HTTP: THTTPClient;
  FS: TFileStream;
  Response: IHTTPResponse;
begin
  Result := False;
  HTTP := THTTPClient.Create;
  try
    HTTP.ConnectionTimeout := 10000;
    HTTP.ResponseTimeout   := 30000;
    try
      FS := TFileStream.Create(ADestPath, fmCreate);
      try
        Response := HTTP.Get(AURL, FS);
        Result := (Response <> nil) and (Response.StatusCode = 200);
      finally
        FS.Free;
      end;
    except
      // Network or I/O error — Result stays False
    end;
    if not Result and System.IOUtils.TFile.Exists(ADestPath) then
      System.IOUtils.TFile.Delete(ADestPath);
  finally
    HTTP.Free;
  end;
end;

// Checks whether Translations.ini and ExamplesBrowser.bas are present and
// downloads any that are missing.  Runs entirely on a background thread so
// the UI is never blocked.  When Translations.ini is freshly downloaded the
// LanguageManager is reloaded on the main thread so subsequent output uses
// the real translations.
procedure TfrmMain.EnsureRequiredFiles();
var
  TransPath, ExPath: string;
begin
  TransPath := System.IOUtils.TPath.Combine(GetAppPath(), 'Translations.ini');
  ExPath    := System.IOUtils.TPath.Combine(GetBasePath(), 'ExamplesBrowser.bas');

  TTask.Run(
    procedure
    var
      TransDownloaded: Boolean;
    begin
      TransDownloaded := False;

      if not System.IOUtils.TFile.Exists(TransPath) then
        TransDownloaded := DownloadFile(URL_TRANSLATIONS, TransPath);

      if not System.IOUtils.TFile.Exists(ExPath) then
        DownloadFile(URL_EXAMPLES_BROWSER, ExPath);

      if TransDownloaded then
        TThread.Synchronize(nil,
          procedure
          begin
            if not FClosing then
            begin
              FreeAndNil(LanguageManager);
              LanguageManager := TTranslationManager.Create(TransPath);
              // Refresh all translated UI elements (toolbar, status bar, hints)
              RefreshTranslatedUI();
              // Reprint the welcome block in the language that just arrived --
              // but only while reprinting cannot cost anything. This runs on
              // the first launch of a fresh installation, which is also when
              // somebody is most likely to be typing at it, and it used to
              // clear the console unconditionally: run a program while the
              // download is in flight and your output went with the banner.
              // Nobody chose that; it was a side effect of reprinting a header.
              if ConsoleHoldsOnlyWelcome() then
              begin
                CmdCls();
                PrintWelcomeBlock();
              end;
              // Said either way, because it is news in both cases.
              PrintLn(_('TranslationsLoaded'));
            end;
          end);
    end);
end;

// -----------------------------------------------------------------------------
// Unsaved Changes Guard
// -----------------------------------------------------------------------------

procedure TfrmMain.ConfirmDiscardChanges(OnConfirmed: TProc);
begin
  if not FModified then
  begin
    // Nothing to lose — proceed immediately
    OnConfirmed();
    Exit();
  end;

  TDialogService.MessageDialog(
    _('UnsavedChangesMsg'),
    TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo, TMsgDlgBtn.mbCancel],
    TMsgDlgBtn.mbCancel, 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        mrYes:
        begin
          // Save first, then proceed
          if FFilename <> '' then
          begin
            CmdSave(ExtractFileName(FFilename));
            OnConfirmed();
          end
          else
          begin
            // No filename yet — show Save As dialog, then proceed on success
            TDialogService.InputQuery(_('DialogSaveAsCaption'), [_('DialogSaveAsPrompt')],
              ['Anonymous' + IntToStr(FAnonymousCounter)],
              procedure(const ASaveResult: TModalResult;
                const AValues: array of string)
              begin
                if (ASaveResult = mrOk) and (Length(AValues) > 0) and
                   (AValues[0].Trim <> '') then
                begin
                  CmdSave(AValues[0]);
                  OnConfirmed();
                end;
                // If user cancels the Save As, do nothing (abort the whole operation)
              end);
          end;
        end;
        mrNo:
        begin
          // Discard changes and proceed
          OnConfirmed();
        end;
        // mrCancel: do nothing — abort the operation
      end;
    end);
end;

// -----------------------------------------------------------------------------
// Command Processing
// -----------------------------------------------------------------------------

procedure TfrmMain.ProcessCommand(const Cmd: string);
begin
  ProcessDirectCommand(Cmd);
end;

procedure TfrmMain.ProcessDirectCommand(const Cmd: string);
var
  UpperCmd, Args: string;
  SpacePos: Integer;
begin
  UpperCmd := Cmd.ToUpper.Trim;

  SpacePos := Pos(' ', UpperCmd);
  if SpacePos > 0 then
  begin
    Args := Copy(Cmd, SpacePos + 1, Length(Cmd)).Trim;
    UpperCmd := Copy(UpperCmd, 1, SpacePos - 1);
  end
  else
    Args := '';

  if UpperCmd = 'NEW' then
    CmdNew()
  else if UpperCmd = 'LIST' then
    CmdList(Args)
  else if UpperCmd = 'RUN' then
    CmdRun()
  else if (UpperCmd = 'LOAD') or (UpperCmd = 'OLD') then
  begin
    // Guard unsaved changes before loading
    ConfirmDiscardChanges(
      procedure
      begin
        CmdLoad(Args);
      end);
  end
  else if UpperCmd = 'SAVE' then
    CmdSave(Args)
  else if (UpperCmd = 'FILES') or (UpperCmd = 'DIR') or (UpperCmd = 'CATALOG') then
    CmdFiles()
  else if UpperCmd = 'CLS' then
    CmdCls()
  else if (UpperCmd = 'HELP') or (UpperCmd = '?') then
    CmdHelp()
  else if (UpperCmd = 'BYE') or (UpperCmd = 'EXIT') or (UpperCmd = 'QUIT') or (UpperCmd = 'SYSTEM') then
    CmdBye()
  else if UpperCmd = 'MODE' then
    CmdMode(Args)
  else if UpperCmd = 'THEME' then
    CmdTheme(Args)
  else if UpperCmd = 'EDITOR' then
    SetInterfaceMode(imEditor)
  else if UpperCmd = 'COMMAND' then
    SetInterfaceMode(imCommand)
  else if UpperCmd = 'WHO' then
    CmdIntro()
  else
    PrintError(Format(_('ErrorUnknownCommand'), [UpperCmd]));
end;

function TfrmMain.ExtractFilenameFromCmd(const Cmd: string): string;
var
  S: string;
begin
  S := Cmd.Trim;

  if (S.Length >= 2) and (S[1] = '"') and (S[S.Length] = '"') then
    Result := Copy(S, 2, S.Length - 2)
  else
    Result := S;
end;

// -----------------------------------------------------------------------------
// Direct Commands
// -----------------------------------------------------------------------------

procedure TfrmMain.CmdNew();
begin
  ConfirmDiscardChanges(
    procedure
    begin
      FProgram.Clear();
      Editor.Lines.Clear();
      FFilename := '';
      FModified := False;
      Inc(FAnonymousCounter);
      UpdateLineNumbers();
      InitBASICEngine();
      PrintLn(_('ProgramCleared'));
      UpdateStatusBar();
      PrintReady();
    end);
end;

procedure TfrmMain.CmdList(const Args: string);
var
  I: Integer;
begin
  if FInterfaceMode = imEditor then
    SyncProgramToEditor();

  if FProgram.Count = 0 then
  begin
    PrintLn(_('NoProgramInMemory'));
    PrintReady();
    Exit();
  end;

  for I := 0 to FProgram.Count - 1 do
    FConsole.AddCodeLine(FProgram[I]);

  PrintReady();
end;

//A program that exercises the pieces the IDE is made of, and says so in its
//own output. Deliberately small: this checks that the host works, not that the
//language does -- 387 assertions and 225 applets already cover that.
const
  SELFTEST_PROGRAM =
    'PRINTLN "p9b-selftest begin"' + sLineBreak +
    'LET a = 6 * 7' + sLineBreak +
    'IF a = 42 THEN' + sLineBreak +
    '  PRINTLN "  PASS arithmetic"' + sLineBreak +
    'END IF' + sLineBreak +
    'LET s$ = ucase$("plan9")' + sLineBreak +
    'IF s$ = "PLAN9" THEN' + sLineBreak +
    '  PRINTLN "  PASS strings"' + sLineBreak +
    'END IF' + sLineBreak +
    'LET f# = form#("selftest", 200, 150)' + sLineBreak +
    'LET b# = button#(f#, "ok", 10, 10, 80, 30)' + sLineBreak +
    'IF PntToNum(b#) <> 0 THEN' + sLineBreak +
    '  PRINTLN "  PASS gui controls"' + sLineBreak +
    'END IF' + sLineBreak +
    'LET freed = button_free(b#)' + sLineBreak +
    'IF freed = 1 THEN' + sLineBreak +
    '  PRINTLN "  PASS free reports success"' + sLineBreak +
    'END IF' + sLineBreak +
    'LET p = instr(os_name$(), "n")' + sLineBreak +
    'IF p >= -1 THEN' + sLineBreak +
    '  PRINTLN "  PASS instr answers a position"' + sLineBreak +
    'END IF' + sLineBreak +
    'PRINTLN "p9b-selftest end"' + sLineBreak +
    'END';

  //BREAKPOINT is inert until trace is on, so proving anything about it means
  //turning trace on around the one statement.
  //
  //Only where the VM may not park. Where it may -- the desktop IDE, which runs
  //the VM on the UI thread and can pump a modal dialog from inside the wait --
  //BREAKPOINT is supposed to stop and ask, and a self-test that stops and asks
  //never finishes. The claim under test is the other one: where parking would
  //hang the platform, the frame is reported and execution carries on.
  SELFTEST_BREAKPOINT =
    'TRACE 1' + sLineBreak +
    'BREAKPOINT "selftest frame", a' + sLineBreak +
    'TRACE 0' + sLineBreak +
    'PRINTLN "  PASS breakpoint returned control"' + sLineBreak;

//The IDE's own features, as opposed to the engine reached through it.
//
//Running a program proves the engine works. These are the things that are the
//IDE: getting code from the editor into the program buffer, saving it, loading
//it back, switching modes, and the search that edits somebody's source. A fault
//in any of them loses work, which is the worst thing a text editor can do.
//
//Answers an empty string when everything held, or the first failure it found.
function TfrmMain.SelfTestFeatures(): String;
var
  Original, RoundTripped: String;
  TempName: String;
  WelcomeLines: Integer;
begin
  Result := '';

  //--- the catalogue row is offered exactly when it can work ---
  //
  //The row itself is built with the picker on screen and chosen by a tap, so
  //neither can be reached from here. What can: the condition it hangs on, and
  //the sentinel it carries. A sentinel that a real file could answer to would
  //send somebody to the catalogue when they asked for their own program.
  if PICK_EXAMPLES = '' then
    Exit('the catalogue sentinel is empty');
  if System.IOUtils.TPath.GetFileName(PICK_EXAMPLES) = PICK_EXAMPLES then
    if System.IOUtils.TPath.HasValidFileNameChars(PICK_EXAMPLES, False) then
      Exit('the catalogue sentinel is a name a file could have');

  //And the file it stands for is the one EnsureRequiredFiles fetches, so a
  //rename on either side stops the row being offered rather than offering one
  //that opens nothing.
  if not URL_EXAMPLES_BROWSER.EndsWith('/ExamplesBrowser.bas') then
    Exit('the browser url and the file the picker looks for have parted');

  //--- the editor and the program buffer are two copies of one thing ---
  FProgram.Text := 'PRINTLN "one"' + sLineBreak + 'PRINTLN "two"';
  SyncEditorToProgram();
  if Pos('PRINTLN "two"', Editor.Text) = 0 then
    Exit('program -> editor did not carry the text');

  Editor.Text := 'PRINTLN "three"' + sLineBreak + 'PRINTLN "four"';
  SyncProgramToEditor();
  if FProgram.Count <> 2 then
    Exit('editor -> program produced ' + IntToStr(FProgram.Count) +
         ' line(s), not 2');
  if Pos('four', FProgram.Text) = 0 then
    Exit('editor -> program lost a line');

  //--- switching modes must not disturb the program ---
  Original := FProgram.Text;
  SetInterfaceMode(imEditor);
  SetInterfaceMode(imCommand);
  if FProgram.Text <> Original then
    Exit('switching interface mode changed the program');

  //--- save and load are a round trip, or somebody loses a file ---
  TempName := 'p9b-selftest-tmp';
  CmdSave(TempName);
  FProgram.Text := 'PRINTLN "replaced"';
  CmdLoad(TempName);
  RoundTripped := FProgram.Text;
  if Pos('three', RoundTripped) = 0 then
    Exit('save then load did not return the program');
  if Pos('replaced', RoundTripped) > 0 then
    Exit('load left the previous program behind');

  //Tidied away. CmdSave writes into the user's own documents folder, and a
  //test has no business leaving a file there -- the first run of this left
  //p9b-selftest-tmp.bas sitting among somebody's real programs.
  try
    if System.IOUtils.TFile.Exists(
         System.IOUtils.TPath.Combine(GetBasePath(), TempName + '.bas')) then
      System.IOUtils.TFile.Delete(
        System.IOUtils.TPath.Combine(GetBasePath(), TempName + '.bas'));
  except
    //Leaving it is untidy, not a failure of what is being tested.
  end;

  //--- new empties it ---
  FProgram.Text := 'PRINTLN "something"';
  FProgram.Clear();
  if FProgram.Count <> 0 then
    Exit('clearing the program left ' + IntToStr(FProgram.Count) + ' line(s)');

  //--- replace-all edits the source it is given ---
  Editor.Text := 'aa bb aa';
  FedtSearch.Text := 'aa';
  FedtReplace.Text := 'zz';
  DoReplaceAll();
  if Pos('aa', Editor.Text) > 0 then
    Exit('replace all left an occurrence behind: ' + Editor.Text);
  if Pos('zz bb zz', Editor.Text) = 0 then
    Exit('replace all produced: ' + Editor.Text);

  //--- arriving translations must not take the console with them ---
  //On the first launch of a fresh installation the IDE downloads
  //Translations.ini and reprints its banner in the new language. It used to
  //clear the console to do it, so a program run while the download was in
  //flight lost its output -- to a user as much as to this test, which is how
  //it was found (ANALYSIS 26). The reprint now asks first, and this is that
  //question, put both ways.
  //
  //The console holds this test's program output right now, so the answer has
  //to be no.
  if ConsoleHoldsOnlyWelcome() then
    Exit('the console holds ' + IntToStr(FConsole.Lines.Count) +
         ' line(s) of program output and still reports itself untouched');

  WelcomeLines := FWelcomeLines;
  try
    //And yes exactly when nothing has been added since the banner.
    FWelcomeLines := FConsole.Lines.Count;
    if not ConsoleHoldsOnlyWelcome() then
      Exit('nothing has been printed since the banner and it still refuses ' +
           'to reprint');

    //One more line, and it refuses again.
    PrintLn('p9b-selftest: a line the banner did not print');
    if ConsoleHoldsOnlyWelcome() then
      Exit('a line was printed after the banner and it did not notice');
  finally
    FWelcomeLines := WelcomeLines;
  end;
end;

procedure TfrmMain.SelfTestTick(Sender: TObject);
var
  Report: TStringList;
  Text, Verdict, Feature: String;
  Code, Wanted: Integer;
begin
  Inc(FSelfTestElapsed, FSelfTestTimer.Interval);

  if not FSelfTestStarted then
  begin
    //One tick's grace so the window and the engine are up first.
    FSelfTestStarted := True;
    if CanPauseForHostDialog then
      FProgram.Text := SELFTEST_PROGRAM
    else
      FProgram.Text := StringReplace(SELFTEST_PROGRAM,
        'PRINTLN "p9b-selftest end"',
        SELFTEST_BREAKPOINT + 'PRINTLN "p9b-selftest end"',
        [rfReplaceAll]);
    CmdRun();
    Exit();
  end;

  FSelfTestSeen := FSelfTestSeen + FConsole.Lines.Text;
  Text := FSelfTestSeen;
  //CmdRun returns only when the program has finished, because this host still
  //runs the VM on its interface thread. The wait is here so a change to that
  //cannot turn a hang into a pass.
  if (Pos('p9b-selftest end', Text) = 0) and (FSelfTestElapsed < 30000) then
    Exit();

  FSelfTestTimer.Enabled := False;

  Wanted := 5;
  Code := 0;
  if Pos('p9b-selftest end', Text) = 0 then
  begin
    Verdict := 'FAIL - the program did not finish within 30s';
    Code := 1;
  end
  else
  begin
    Code := 0;
    Verdict := 'OK - the IDE ran a program and its own features hold';
    if (Pos('PASS arithmetic', Text) = 0) or
       (Pos('PASS strings', Text) = 0) or
       (Pos('PASS gui controls', Text) = 0) or
       (Pos('PASS free reports success', Text) = 0) or
       (Pos('PASS instr answers a position', Text) = 0) then
    begin
      Verdict := 'FAIL - not all ' + IntToStr(Wanted) + ' checks reported PASS';
      Code := 1;
    end
    else
    begin
      Feature := SelfTestFeatures();
      if Feature <> '' then
      begin
        Verdict := 'FAIL - IDE feature: ' + Feature;
        Code := 1;
      end;
    end;
  end;

  Report := TStringList.Create();
  try
    Report.Add(Verdict);
    Report.Add('--- state ---');
    Report.Add('  started      : ' + BoolToStr(FSelfTestStarted, True));
    Report.Add('  elapsed ms   : ' + IntToStr(FSelfTestElapsed));
    Report.Add('  program lines: ' + IntToStr(FProgram.Count));
    Report.Add('  console lines: ' + IntToStr(FConsole.Lines.Count));
    Report.Add('--- console ---');
    Report.AddStrings(FConsole.Lines);
    //Beside the executable on desktop, where the build scripts read it; in
    //the documents folder on a device, because that is the only place adb pull
    //can reach without root.
    {$IF Defined(ANDROID) or Defined(IOS)}
    Report.SaveToFile(System.IOUtils.TPath.Combine(GetBasePath(),
                                                   'ide-selftest.out'));
    {$ELSE}
    Report.SaveToFile(System.IOUtils.TPath.Combine(
      System.IOUtils.TPath.GetDirectoryName(ParamStr(0)), 'ide-selftest.out'));
    {$ENDIF}
  finally
    Report.Free();
  end;
  Halt(Code);
end;

procedure TfrmMain.CmdRun();
var
  CompResult: Integer;
  Status: string;
  SourceCode: TStringList;
begin
  if FInterfaceMode = imEditor then
  begin
    SyncProgramToEditor();
    SetInterfaceMode(imCommand);
  end;

  if FProgram.Count = 0 then
  begin
    PrintLn(_('NoProgramInMemory'));
    PrintReady();
    Exit();
  end;

  SourceCode := TStringList.Create();
  try
    SourceCode.Text := GetProgramText();

    InitBASICEngine();

    CompResult := FBasic.Compile(SourceCode);
    if CompResult = 0 then
    begin
      try
        PrintLn();
        //FBasic.ExecuteProgram(Console.Lines);
        FBasic.ExecuteProgram(FConsole.Lines);
      except
        on E: Exception do
        begin
          PrintLn();
          PrintLn(_('RuntimeErrorHeader'));
          PrintLn(Format(_('RuntimeErrorIP'),   [FBasic.Parser.Exec.IP]));
          PrintLn(Format(_('RuntimeErrorLine'), [FBasic.Parser.Exec.SourceLine]));
          PrintLn(Format(_('RuntimeErrorMsg'),  [E.Message]));
        end;
      end;
      Status := FBasic.Parser.Exec.ErrorMessage;
      if Status.Length = 0 then
        PrintLn(_('ProgramCompleted'));
    end
    else
    begin
      PrintLn();
      PrintLn(_('SyntaxErrorHeader'));
      PrintLn(Format(_('SyntaxErrorDetail'),
        [FBasic.ErrorPos, FBasic.ErrorLine, FBasic.ErrorMessage]));
    end;
  finally
    SourceCode.Free();
  end;

  // After VM execution is fully complete, apply any pending editor sync
  // from tool callbacks that deferred FMX control updates
  if FPendingEditorSync then
  begin
    FPendingEditorSync := False;
    SyncEditorToProgram;
    UpdateStatusBar;
  end;

  PrintReady();
end;

procedure TfrmMain.CmdLoad(const Filename: string);
var
  FullPath, Fn: string;
  Lines: TStringList;
  I: Integer;
begin
  Fn := ExtractFilenameFromCmd(Filename);

  if Fn = '' then
  begin
    PrintError(_('ErrorLoadNoFilename'));
    Exit();
  end;

  FullPath := System.IOUtils.TPath.Combine(GetBasePath, Fn);
  if ExtractFileExt(FullPath) = '' then
    FullPath := FullPath + '.bas';

  if not FileExists(FullPath) then
  begin
    PrintError(_('FileNotFound') + Fn);
    Exit();
  end;

  Lines := TStringList.Create();
  try
    Lines.LoadFromFile(FullPath, TEncoding.UTF8);

    FProgram.Clear();

    for I := 0 to Lines.Count - 1 do
    begin
      if Lines[I].Trim <> '' then
        FProgram.Add(Lines[I]);
    end;

    FormatLoadedSource();
    FFilename := FullPath;
    FModified := False;

    SyncEditorToProgram();

    PrintLn(Format(_('FileLoaded'),  [ExtractFileName(FullPath)]));
    PrintLn(Format(_('LinesCount'), [FProgram.Count]));
  finally
    Lines.Free();
  end;

  UpdateStatusBar();
  PrintReady();
end;

procedure TfrmMain.CmdSave(const Filename: string);
var
  FullPath, Fn: string;
begin
  if FInterfaceMode = imEditor then
    SyncProgramToEditor();

  Fn := ExtractFilenameFromCmd(Filename);

  if Fn = '' then
  begin
    if FFilename <> '' then
      FullPath := FFilename
    else
    begin
      PrintError(_('ErrorSaveNoFilename'));
      Exit();
    end;
  end
  else
  begin
    FullPath := System.IOUtils.TPath.Combine(GetBasePath, Fn);
    if ExtractFileExt(FullPath) = '' then
      FullPath := FullPath + '.bas';
  end;

  if FProgram.Count = 0 then
  begin
    PrintError(_('ErrorNoProgramToSave'));
    Exit();
  end;

  FProgram.SaveToFile(FullPath, TEncoding.UTF8);

  FFilename := FullPath;
  FModified := False;

  PrintLn(Format(_('FileSavedAs'), [ExtractFileName(FullPath)]));

  UpdateStatusBar();
  PrintReady();
end;

procedure TfrmMain.CmdFiles();
var
  Files: TArray<string>;
  F: string;
  FileSize: Int64;
  Count: Integer;
begin
  try
    Files := TDirectory.GetFiles(GetBasePath, '*.bas');
  except
    PrintError(_('ErrorAccessDirectory'));
    Exit();
  end;

  Count := 0;

  PrintLn();
  PrintLn(Format(_('FilesDirectory'), [GetBasePath]));
  PrintLn(StringOfChar('-', 40));

  for F in Files do
  begin
    FileSize := TFile.GetSize(F);
    PrintLn(Format('%-25s %8d', [ExtractFileName(F), FileSize]));
    Inc(Count);
  end;

  PrintLn(StringOfChar('-', 40));
  PrintLn(Format(_('FilesCount'), [Count]));

  PrintReady();
end;

procedure TfrmMain.CmdCls();
begin
  FConsole.ClearLines();
end;

procedure TfrmMain.CmdHelp();
begin
  PrintLn();
  PrintLn(_('HelpTitle'));
  PrintLn(_('HelpSeparator'));
  PrintLn(_('HelpNew'));
  PrintLn(_('HelpList'));
  PrintLn(_('HelpRun'));
  PrintLn(_('HelpLoad'));
  PrintLn(_('HelpSave'));
  PrintLn(_('HelpFiles'));
  PrintLn(_('HelpCls'));
  PrintLn(_('HelpEditor'));
  PrintLn(_('HelpCommand'));
  PrintLn(_('HelpTheme'));
  PrintLn(_('HelpBye'));
  PrintLn;
  {$IF not Defined(ANDROID) and not Defined(IOS)}
  PrintLn(_('HelpFunctionKeys'));
  PrintLn(_('HelpwhoFunctionKeysSep'));
  PrintLn(_('HelpFKeys1'));
  PrintLn(_('HelpFKeys2'));
  PrintLn;
  PrintLn(_('HelpCtrlF'));
  PrintLn(_('HelpCtrlH'));
  PrintLn;
  {$ELSE}
  PrintLn(_('HelpTapFind'));
  PrintLn;
  {$ENDIF}
  PrintLn(_('HelpThemes1'));
  PrintLn(_('HelpThemes2'));
  PrintLn();
  PrintReady();
end;

procedure TfrmMain.CmdIntro();
begin
  PrintLn();
  PrintLn(System.NetEncoding.TNetEncoding.Base64.Decode('QXV0aG9yOiBBbmRyw6kgTXVydGE='));
  PrintLn(System.NetEncoding.TNetEncoding.Base64.Decode('RGF0YTogMjAyNi0wMg=='));
  PrintLn(System.NetEncoding.TNetEncoding.Base64.Decode('TGluZ3VhZ2VtOiBEZWxwaGk='));
  PrintLn();
  PrintReady();
end;

procedure TfrmMain.CmdBye();
begin
  ConfirmDiscardChanges(
    procedure
    begin
      PrintLn(_('GoodbyeMsg'));
      Application.Terminate();
    end);
end;

procedure TfrmMain.CmdMode(const Args: string);
var
  UpperArgs: string;
begin
  UpperArgs := Args.ToUpper.Trim();

  if (UpperArgs = 'EDITOR') or (UpperArgs = 'E') then
    SetInterfaceMode(imEditor)
  else if (UpperArgs = 'COMMAND') or (UpperArgs = 'C') then
    SetInterfaceMode(imCommand)
  else
    ToggleMode();
end;

procedure TfrmMain.CmdTheme(const Args: string);
var
  UpperArgs: string;
begin
  UpperArgs := Args.ToUpper.Trim;

  if UpperArgs = 'GREEN' then
    ApplyTheme(ctGreen)
  else if UpperArgs = 'AMBER' then
    ApplyTheme(ctAmber)
  else if UpperArgs = 'WHITE' then
    ApplyTheme(ctWhite)
  else if UpperArgs = 'BLUE' then
    ApplyTheme(ctBlue)
  else if UpperArgs = 'PINK' then
    ApplyTheme(ctPink)
  else
    CycleTheme();

  PrintLn(Format(_('ThemeChanged'), [FThemes[FCurrentTheme].Name]));
  PrintReady();
end;

procedure TfrmMain.CreateConsole();
begin
  FConsole := TBasicConsole.Create(Self);
  FConsole.Parent := RectConsoleBackground;
  FConsole.Align := TAlignLayout.Client;
  FConsole.Margins.Left := 5;
  FConsole.Margins.Top := 5;
  FConsole.Margins.Right := 5;
  FConsole.Margins.Bottom := 5;
  FConsole.ShowScrollBars := True;
  FConsole.AutoScroll := True;

  // Platform-specific font
  {$IFDEF MSWINDOWS}
  FConsole.SetFontFamily('Consolas', 14);
  {$ENDIF}
  {$IFDEF LINUX}
  FConsole.SetFontFamily('DejaVu Sans Mono', 14);
  {$ENDIF}
  {$IFDEF MACOS}
  FConsole.SetFontFamily('Menlo', 14);
  {$ENDIF}
  {$IF Defined(ANDROID) or Defined(IOS)}
  FConsole.SetFontFamily('monospace', 16);
  {$ENDIF}

  // Apply theme colors
  FConsole.Colors := GetSyntaxColors(FCurrentTheme);
  FConsole.UpdateBackground;
end;

// -----------------------------------------------------------------------------
// Search & Replace
// -----------------------------------------------------------------------------

procedure TfrmMain.CreateSearchBar();
var
  BtnW, RowH, BarH: Single;
  FontFamily: string;
  FontSize: Single;
  ThemeColor, ThemeDim: TAlphaColor;
begin
  // Grab current theme colors for initial rendering
  ThemeColor := FThemes[FCurrentTheme].Foreground;
  ThemeDim := FThemes[FCurrentTheme].ForegroundDim;

  {$IF Defined(ANDROID) or Defined(IOS)}
  BtnW := 70;
  RowH := 40;
  BarH := 84;
  FontFamily := 'monospace';
  FontSize := 14;
  {$ELSE}
  BtnW := 50;
  RowH := 32;
  BarH := 68;
  {$IFDEF MSWINDOWS}FontFamily := 'Consolas';{$ENDIF}
  {$IFDEF LINUX}FontFamily := 'DejaVu Sans Mono';{$ENDIF}
  {$IFDEF MACOS}FontFamily := 'Menlo';{$ENDIF}
  FontSize := 11;
  {$ENDIF}

  // Main container — sits at top of RectEditorBackground
  FLayoutSearchBar := TLayout.Create(Self);
  FLayoutSearchBar.Parent := RectEditorBackground;
  FLayoutSearchBar.Align := TAlignLayout.Top;
  FLayoutSearchBar.Height := BarH;
  FLayoutSearchBar.Visible := False;

  // Background rectangle (purely visual, no layout role)
  FRectSearchBackground := TRectangle.Create(FLayoutSearchBar);
  FRectSearchBackground.Parent := FLayoutSearchBar;
  FRectSearchBackground.Align := TAlignLayout.Contents;
  FRectSearchBackground.Fill.Color := $FF151515;
  FRectSearchBackground.Stroke.Color := $FF333333;
  FRectSearchBackground.HitTest := False;

  // === Row 1: Search field + Find buttons + Close ===
  FLayoutSearchRow := TLayout.Create(FLayoutSearchBar);
  FLayoutSearchRow.Parent := FLayoutSearchBar;
  FLayoutSearchRow.Align := TAlignLayout.Top;
  FLayoutSearchRow.Height := RowH;
  FLayoutSearchRow.Margins.Left := 5;
  FLayoutSearchRow.Margins.Top := 3;
  FLayoutSearchRow.Margins.Right := 5;

  // Close button (rightmost)
  FbtnSearchClose := TSpeedButton.Create(FLayoutSearchRow);
  FbtnSearchClose.Parent := FLayoutSearchRow;
  FbtnSearchClose.Align := TAlignLayout.Right;
  FbtnSearchClose.Width := 30;
  FbtnSearchClose.Text := _('SearchBarCloseBtn');
  FbtnSearchClose.StyledSettings := [];
  FbtnSearchClose.TextSettings.Font.Family := FontFamily;
  FbtnSearchClose.TextSettings.Font.Size := FontSize;
  FbtnSearchClose.TextSettings.Font.Style := [TFontStyle.fsBold];
  FbtnSearchClose.TextSettings.FontColor := ThemeColor;
  FbtnSearchClose.OnClick := btnSearchCloseClick;

  // Find Previous button
  FbtnFindPrev := TSpeedButton.Create(FLayoutSearchRow);
  FbtnFindPrev.Parent := FLayoutSearchRow;
  FbtnFindPrev.Align := TAlignLayout.Right;
  FbtnFindPrev.Width := BtnW;
  FbtnFindPrev.Text := #9650; // up triangle
  FbtnFindPrev.StyledSettings := [];
  FbtnFindPrev.TextSettings.Font.Family := FontFamily;
  FbtnFindPrev.TextSettings.Font.Size := FontSize;
  FbtnFindPrev.TextSettings.FontColor := ThemeColor;
  FbtnFindPrev.OnClick := btnFindPrevClick;

  // Find Next button
  FbtnFindNext := TSpeedButton.Create(FLayoutSearchRow);
  FbtnFindNext.Parent := FLayoutSearchRow;
  FbtnFindNext.Align := TAlignLayout.Right;
  FbtnFindNext.Width := BtnW;
  FbtnFindNext.Text := #9660; // down triangle
  FbtnFindNext.StyledSettings := [];
  FbtnFindNext.TextSettings.Font.Family := FontFamily;
  FbtnFindNext.TextSettings.Font.Size := FontSize;
  FbtnFindNext.TextSettings.FontColor := ThemeColor;
  FbtnFindNext.OnClick := btnFindNextClick;

  // Match info label (right of search field)
  FlblMatchInfo := TLabel.Create(FLayoutSearchRow);
  FlblMatchInfo.Parent := FLayoutSearchRow;
  FlblMatchInfo.Align := TAlignLayout.Right;
  FlblMatchInfo.Width := 80;
  FlblMatchInfo.StyledSettings := [];
  FlblMatchInfo.TextSettings.Font.Family := FontFamily;
  FlblMatchInfo.TextSettings.Font.Size := FontSize;
  FlblMatchInfo.TextSettings.FontColor := ThemeDim;
  FlblMatchInfo.TextSettings.HorzAlign := TTextAlign.Center;
  FlblMatchInfo.Text := '';

  // Search edit field (fills remaining space)
  FedtSearch := TEdit.Create(FLayoutSearchRow);
  FedtSearch.Parent := FLayoutSearchRow;
  FedtSearch.Align := TAlignLayout.Client;
  FedtSearch.StyledSettings := [];
  FedtSearch.StyleLookup := 'transparentedit';
  FedtSearch.TextSettings.Font.Family := FontFamily;
  FedtSearch.TextSettings.Font.Size := FontSize;
  FedtSearch.TextSettings.FontColor := ThemeColor;
  FedtSearch.TextPrompt := _('SearchBarSearchPrompt');
  FedtSearch.OnKeyUp := edtSearchKeyUp;
  FedtSearch.OnChangeTracking := edtSearchChangeTracking;
  {$IF Defined(ANDROID) or Defined(IOS)}
  FedtSearch.ControlType := TControlType.Styled;
  {$ENDIF}

  // === Row 2: Replace field + Replace buttons ===
  FLayoutReplaceRow := TLayout.Create(FLayoutSearchBar);
  FLayoutReplaceRow.Parent := FLayoutSearchBar;
  FLayoutReplaceRow.Align := TAlignLayout.Top;
  FLayoutReplaceRow.Height := RowH;
  FLayoutReplaceRow.Margins.Left := 5;
  FLayoutReplaceRow.Margins.Top := 1;
  FLayoutReplaceRow.Margins.Right := 5;

  // Replace All button (rightmost)
  FbtnReplaceAll := TSpeedButton.Create(FLayoutReplaceRow);
  FbtnReplaceAll.Parent := FLayoutReplaceRow;
  FbtnReplaceAll.Align := TAlignLayout.Right;
  FbtnReplaceAll.Width := BtnW;
  FbtnReplaceAll.Text := _('SearchBarReplaceAllBtn');
  FbtnReplaceAll.StyledSettings := [];
  FbtnReplaceAll.TextSettings.Font.Family := FontFamily;
  FbtnReplaceAll.TextSettings.Font.Size := FontSize;
  FbtnReplaceAll.TextSettings.FontColor := ThemeColor;
  FbtnReplaceAll.OnClick := btnReplaceAllClick;

  // Replace button
  FbtnReplace := TSpeedButton.Create(FLayoutReplaceRow);
  FbtnReplace.Parent := FLayoutReplaceRow;
  FbtnReplace.Align := TAlignLayout.Right;
  FbtnReplace.Width := BtnW + 25;
  FbtnReplace.Text := _('SearchBarReplaceBtn');
  FbtnReplace.StyledSettings := [];
  FbtnReplace.TextSettings.Font.Family := FontFamily;
  FbtnReplace.TextSettings.Font.Size := FontSize;
  FbtnReplace.TextSettings.FontColor := ThemeColor;
  FbtnReplace.OnClick := btnReplaceClick;

  // Replace edit field (fills remaining space)
  FedtReplace := TEdit.Create(FLayoutReplaceRow);
  FedtReplace.Parent := FLayoutReplaceRow;
  FedtReplace.Align := TAlignLayout.Client;
  FedtReplace.StyledSettings := [];
  FedtReplace.StyleLookup := 'transparentedit';
  FedtReplace.TextSettings.Font.Family := FontFamily;
  FedtReplace.TextSettings.Font.Size := FontSize;
  FedtReplace.TextSettings.FontColor := ThemeColor;
  FedtReplace.TextPrompt := _('SearchBarReplacePrompt');
  FedtReplace.OnKeyUp := edtReplaceKeyUp;
  {$IF Defined(ANDROID) or Defined(IOS)}
  FedtReplace.ControlType := TControlType.Styled;
  {$ENDIF}
end;

procedure TfrmMain.ShowSearchBar();
begin
  if not FSearchBarVisible then
  begin
    FLayoutSearchBar.Visible := True;
    FSearchBarVisible := True;
    FSearchLastPos := 0;
  end;
  FedtSearch.SetFocus();

  // If there's selected text in the editor, use it as the search term
  if Editor.SelLength > 0 then
    FedtSearch.Text := Editor.SelText;

  UpdateMatchInfo();
end;

procedure TfrmMain.HideSearchBar();
begin
  FLayoutSearchBar.Visible := False;
  FSearchBarVisible := False;
  FlblMatchInfo.Text := '';
  Editor.SetFocus();
end;

function TfrmMain.CountMatches(const SearchText, FullText: string): Integer;
var
  UpperSearch, UpperFull: string;
  Pos, StartFrom: Integer;
begin
  Result := 0;
  if SearchText = '' then
    Exit();

  UpperSearch := SearchText.ToUpper();
  UpperFull := FullText.ToUpper();
  StartFrom := 1;

  repeat
    Pos := System.SysUtils.AnsiPos(UpperSearch, Copy(UpperFull, StartFrom, Length(UpperFull)));
    if Pos > 0 then
    begin
      Inc(Result);
      StartFrom := StartFrom + Pos; // move past this match
    end;
  until Pos = 0;
end;

procedure TfrmMain.UpdateMatchInfo();
var
  Total: Integer;
begin
  if FedtSearch.Text = '' then
  begin
    FlblMatchInfo.Text := '';
    Exit();
  end;

  Total := CountMatches(FedtSearch.Text, Editor.Text);
  if Total = 0 then
    FlblMatchInfo.Text := _('SearchNoMatch')
  else if Total = 1 then
    FlblMatchInfo.Text := _('SearchOneMatch')
  else
    FlblMatchInfo.Text := Format(_('SearchMatches'), [Total]);
end;

procedure TfrmMain.SelectEditorRange(AStart, ALength: Integer);
begin
  // AStart is 0-based character position in Editor.Text
  Editor.SetFocus();
  Editor.SelStart := AStart;
  Editor.SelLength := ALength;
end;

procedure TfrmMain.DoFindNext();
var
  SearchText, FullText, UpperSearch, UpperFull: string;
  Pos, StartFrom: Integer;
begin
  SearchText := FedtSearch.Text;
  if SearchText = '' then
    Exit();

  FullText := Editor.Text;
  UpperSearch := SearchText.ToUpper();
  UpperFull := FullText.ToUpper();

  // Start searching after the current position
  StartFrom := FSearchLastPos + 1; // 1-based for string operations
  if StartFrom < 1 then
    StartFrom := 1;

  // Search forward from current position
  Pos := System.SysUtils.AnsiPos(UpperSearch, Copy(UpperFull, StartFrom, Length(UpperFull)));

  if Pos > 0 then
  begin
    // Found — Pos is relative to StartFrom
    FSearchLastPos := StartFrom + Pos - 1;
    SelectEditorRange(FSearchLastPos - 1, Length(SearchText)); // SelStart is 0-based
  end
  else
  begin
    // Wrap around — search from beginning
    Pos := System.SysUtils.AnsiPos(UpperSearch, UpperFull);
    if Pos > 0 then
    begin
      FSearchLastPos := Pos;
      SelectEditorRange(FSearchLastPos - 1, Length(SearchText));
    end
    else
    begin
      FSearchLastPos := 0;
      FlblMatchInfo.Text := _('SearchNoMatch');
    end;
  end;

  UpdateMatchInfo();
end;

procedure TfrmMain.DoFindPrev();
var
  SearchText, FullText, UpperSearch, UpperFull: string;
  FoundPos, StartFrom, SearchUpTo: Integer;
  LastFound: Integer;
begin
  SearchText := FedtSearch.Text;
  if SearchText = '' then
    Exit();

  FullText := Editor.Text;
  UpperSearch := SearchText.ToUpper();
  UpperFull := FullText.ToUpper();

  // Find the last match BEFORE FSearchLastPos
  SearchUpTo := FSearchLastPos - 1;
  if SearchUpTo < 1 then
    SearchUpTo := Length(UpperFull); // wrap to end

  // Iterate forward collecting the last match within range
  LastFound := 0;
  StartFrom := 1;
  while StartFrom <= SearchUpTo do
  begin
    FoundPos := System.SysUtils.AnsiPos(UpperSearch, Copy(UpperFull, StartFrom, SearchUpTo - StartFrom + 1));
    if FoundPos > 0 then
    begin
      LastFound := StartFrom + FoundPos - 1; // absolute position
      StartFrom := LastFound + 1;
    end
    else
      Break;
  end;

  if LastFound > 0 then
  begin
    FSearchLastPos := LastFound;
    SelectEditorRange(LastFound - 1, Length(SearchText));
  end
  else
  begin
    // Wrap around: find the last occurrence in the entire text
    LastFound := 0;
    StartFrom := 1;
    while StartFrom <= Length(UpperFull) do
    begin
      FoundPos := System.SysUtils.AnsiPos(UpperSearch,
        Copy(UpperFull, StartFrom, Length(UpperFull)));
      if FoundPos > 0 then
      begin
        LastFound := StartFrom + FoundPos - 1;
        StartFrom := LastFound + 1;
      end
      else
        Break;
    end;

    if LastFound > 0 then
    begin
      FSearchLastPos := LastFound;
      SelectEditorRange(LastFound - 1, Length(SearchText));
    end
    else
    begin
      FSearchLastPos := 0;
      FlblMatchInfo.Text := _('SearchNoMatch');
    end;
  end;

  UpdateMatchInfo();
end;

procedure TfrmMain.DoReplace();
var
  SearchText, ReplaceText, FullText, UpperSearch: string;
  SelUpper: string;
begin
  SearchText := FedtSearch.Text;
  ReplaceText := FedtReplace.Text;
  if SearchText = '' then
    Exit();

  FullText := Editor.Text;
  UpperSearch := SearchText.ToUpper();

  // If current selection matches search text, replace it
  if Editor.SelLength > 0 then
  begin
    SelUpper := Copy(Editor.Text, Editor.SelStart + 1, Editor.SelLength).ToUpper();
    if SelUpper = UpperSearch then
    begin
      // Replace by rebuilding the text around the selection
      FullText := Editor.Text;
      Editor.Text := Copy(FullText, 1, Editor.SelStart)
                   + ReplaceText
                   + Copy(FullText, Editor.SelStart + Editor.SelLength + 1, Length(FullText));
      // Place caret after the replacement
      Editor.SelStart := Editor.SelStart + Length(ReplaceText);
      Editor.SelLength := 0;
      // Update position after replacement
      FSearchLastPos := Editor.SelStart;
      FModified := True;
      DeferredUpdateLineNumbers();
      UpdateStatusBar();
    end;
  end;

  // Find the next occurrence
  DoFindNext();
end;

procedure TfrmMain.DoReplaceAll();
var
  SearchText, ReplaceText, FullText, UpperSearch, UpperFull: string;
  NewText: string;
  Count, Pos, StartFrom: Integer;
begin
  SearchText := FedtSearch.Text;
  ReplaceText := FedtReplace.Text;
  if SearchText = '' then
    Exit();

  FullText := Editor.Text;
  UpperSearch := SearchText.ToUpper();
  //Uppercased once, not once per match. The loop below used to call
  //FullText.ToUpper() inside itself, so a file with a hundred matches
  //uppercased the whole file a hundred times -- work proportional to the
  //length times the number of hits, for an answer that never changes.
  //
  //The variable was already declared and never used, which is what the
  //compiler had been saying with H2164 all along.
  UpperFull := FullText.ToUpper();

  // Perform case-insensitive replace all
  NewText := '';
  Count := 0;
  StartFrom := 1;

  while StartFrom <= Length(FullText) do
  begin
    Pos := System.SysUtils.AnsiPos(UpperSearch,
      Copy(UpperFull, StartFrom, Length(FullText)));

    if Pos > 0 then
    begin
      // Append text before the match, then the replacement
      NewText := NewText + Copy(FullText, StartFrom, Pos - 1) + ReplaceText;
      StartFrom := StartFrom + Pos - 1 + Length(SearchText);
      Inc(Count);
    end
    else
    begin
      // No more matches — append remainder
      NewText := NewText + Copy(FullText, StartFrom, Length(FullText));
      Break;
    end;
  end;

  if Count > 0 then
  begin
    Editor.Text := NewText;
    FModified := True;
    FSearchLastPos := 0;
    DeferredUpdateLineNumbers();
    UpdateStatusBar();

    if Count = 1 then
      FlblMatchInfo.Text := _('SearchOneReplaced')
    else
      FlblMatchInfo.Text := Format(_('SearchReplaced'), [Count]);
  end
  else
    FlblMatchInfo.Text := _('SearchNoMatch');
end;

// --- Search bar event handlers ---

procedure TfrmMain.edtSearchKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  case Key of
    vkReturn:
    begin
      if ssShift in Shift then
        DoFindPrev()
      else
        DoFindNext();
    end;
    vkEscape: HideSearchBar();
  end;
end;

procedure TfrmMain.edtReplaceKeyUp(Sender: TObject; var Key: Word; var KeyChar: WideChar; Shift: TShiftState);
begin
  case Key of
    vkReturn: DoReplace();
    vkEscape: HideSearchBar();
  end;
end;

procedure TfrmMain.edtSearchChangeTracking(Sender: TObject);
begin
  // Reset search position when text changes
  FSearchLastPos := 0;
  UpdateMatchInfo();
end;

procedure TfrmMain.btnFindNextClick(Sender: TObject);
begin
  DoFindNext();
end;

procedure TfrmMain.btnFindPrevClick(Sender: TObject);
begin
  DoFindPrev();
end;

procedure TfrmMain.btnReplaceClick(Sender: TObject);
begin
  DoReplace();
end;

procedure TfrmMain.btnReplaceAllClick(Sender: TObject);
begin
  DoReplaceAll();
end;

procedure TfrmMain.btnSearchCloseClick(Sender: TObject);
begin
  HideSearchBar();
end;

procedure TfrmMain.btnFindToolbarClick(Sender: TObject);
begin
  if FInterfaceMode <> imEditor then
    SetInterfaceMode(imEditor);
  ShowSearchBar();
end;

procedure TfrmMain.btnCopyToolbarClick(Sender: TObject);
var
  ClipSvc: IFMXClipboardService;
  OutputText: string;
begin
  // Copy console output text to clipboard
  if TPlatformServices.Current.SupportsPlatformService(IFMXClipboardService, ClipSvc) then
  begin
    OutputText := FConsole.Lines.Text;
    if OutputText.Trim <> '' then
    begin
      ClipSvc.SetClipboard(OutputText);
      PrintLn(_('OutputCopied'));
    end
    else
      PrintLn(_('ConsoleEmpty'));
  end
  else
    PrintLn(_('ClipboardNotAvailable'));
end;

// -----------------------------------------------------------------------------
// Program Management
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------
// Step 2: Implementation of IsKeyword
// Uses a simple hash-set approach for fast lookup.
// -----------------------------------------------------------------------

function TfrmMain.IsKeyword(const Word: string): Boolean;
var
  W: string;
begin
  W := UpperCase(Word);
  Result :=
    (W = 'IF') or (W = 'DO') or (W = 'ON') or (W = 'OR') or (W = 'TO') or
    (W = 'AND') or (W = 'END') or (W = 'MOD') or (W = 'REM') or
    (W = 'CLS') or (W = 'LET') or (W = 'FOR') or (W = 'NOT') or
    (W = 'DATA') or (W = 'CALL') or (W = 'CASE') or (W = 'READ') or
    (W = 'ELSE') or (W = 'WEND') or (W = 'THEN') or (W = 'DUMP') or
    (W = 'GOTO') or (W = 'LOOP') or (W = 'NULL') or (W = 'STEP') or
    (W = 'NEXT') or (W = 'TRUE') or (W = 'BREAK') or (W = 'ENDIF') or
    (W = 'LOCAL') or (W = 'FALSE') or (W = 'TRACE') or (W = 'WATCH') or
    (W = 'WHILE') or (W = 'GOSUB') or (W = 'UNTIL') or (W = 'PRINT') or
    (W = 'INPUT') or (W = 'ENDFOR') or (W = 'SELECT') or (W = 'REPEAT') or
    (W = 'ASSERT') or (W = 'RETURN') or (W = 'TRACEON') or
    (W = 'UNWATCH') or (W = 'RESTORE') or (W = 'PRINTLN') or
    (W = 'TRACEOFF') or (W = 'ENDWHILE') or (W = 'CONTINUE') or
    (W = 'FUNCTION') or (W = 'ENDSELECT') or (W = 'BREAKPOINT') or
    (W = 'REFRESHRATE') or (W = 'ENDFUNCTION');
end;

procedure TfrmMain.MakeMemoTransparent(AMemo: TMemo);
var
  Obj: TFmxObject;
begin
  AMemo.ApplyStyleLookup;
  Obj := AMemo.FindStyleResource('background');
  if (Obj <> nil) and (Obj is TShape) then
    TShape(Obj).Fill.Kind := TBrushKind.None;
end;

function TfrmMain.GetProgramText(): string;
begin
  Result := FProgram.Text;
end;

function TfrmMain.GetSyntaxColors(Theme: TColorTheme): TSyntaxColors;
var
  T: TThemeColors;
begin
  T := FThemes[Theme];

  // Background and default text match the theme
  Result.Background := T.Background;
  //Result.Default := T.MemoForeground;
  Result.Default := T.Foreground;

  // Syntax colors derived from the Plan9Basic website neon palette:
  //   --neon-green:  #39ff14      --neon-pink:   #ff6ec7
  //   --neon-purple: #bc13fe      --terminal-green: #33ff33
  //   dot-yellow:    #ffbd2e      dot-red:       #ff5f56
  //   --text-primary: #e0e0e0

  case Theme of
    ctGreen:
    begin
      // Faithful to the website's terminal aesthetic
      Result.Background := $FF0C1A0C; // --terminal-bg
      Result.Default := $FF33FF33; // --terminal-green
      Result.Keyword := $FFFF6EC7; // neon-pink (bold)
      Result.StringLit := $FF39FF14; // neon-green (brighter)
      Result.Number := $FFBC13FE; // neon-purple
      Result.Comment := $FF2A6A2A; // muted dark green
      Result.FuncCall := $FFFFBD2E; // warm gold
      Result.Operator := $FFE0E0E0; // text-primary
      Result.LineNum := $FF3A7A3A; // subdued green
      Result.LabelColor := $FFBC13FE; // neon-purple
      Result.Directive := $FFFF5F56; // warm red
    end;

    ctAmber:
    begin
      // Neon palette adapted to amber warmth
      Result.Keyword := $FFFF6EC7; // neon-pink
      Result.StringLit := $FF39FF14; // neon-green
      Result.Number := $FFBC13FE; // neon-purple
      Result.Comment := $FF6A5A20; // muted amber
      Result.FuncCall := $FFFFBD2E; // gold
      Result.Operator := $FFE0E0E0; // text-primary
      Result.LineNum := $FF7A6A30; // dim amber
      Result.LabelColor := $FFBC13FE; // neon-purple
      Result.Directive := $FFFF5F56; // warm red
    end;

    ctWhite:
    begin
      // Dark-on-light: saturated versions of the neon palette
      Result.Keyword := $FFCC1177; // deep pink
      Result.StringLit := $FF1A8A0A; // deep green
      Result.Number := $FF8A0ACE; // deep purple
      Result.Comment := $FF888888; // mid gray
      Result.FuncCall := $FFCC8800; // dark gold
      Result.Operator := $FF555555; // dark gray
      Result.LineNum := $FFAAAAAA; // light gray
      Result.LabelColor := $FF8A0ACE; // deep purple
      Result.Directive := $FFCC3322; // dark red
    end;

    ctBlue:
    begin
      // Neon palette on dark blue canvas
      Result.Keyword := $FFFF6EC7; // neon-pink
      Result.StringLit := $FF39FF14; // neon-green
      Result.Number := $FFBC13FE; // neon-purple
      Result.Comment := $FF3A5A7A; // muted steel blue
      Result.FuncCall := $FFFFBD2E; // gold
      Result.Operator := $FFE0E0E0; // text-primary
      Result.LineNum := $FF3A5A8A; // dim blue
      Result.LabelColor := $FFBC13FE; // neon-purple
      Result.Directive := $FFFF5F56; // warm red
    end;

    ctPink:
    begin
      // Neon palette with pink as the base
      Result.Keyword := $FF39FF14; // neon-green (inverted: green pops on pink)
      Result.StringLit := $FFFFBD2E; // gold
      Result.Number := $FFBC13FE; // neon-purple
      Result.Comment := $FF7A4A5A; // muted mauve
      Result.FuncCall := $FF33CCFF; // bright cyan
      Result.Operator := $FFE0E0E0; // text-primary
      Result.LineNum := $FF8A5A6A; // dim pink
      Result.LabelColor := $FFBC13FE; // neon-purple
      Result.Directive := $FFFF5F56; // warm red
    end;
  end;
end;

procedure TfrmMain.GutterOverlayMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FGutterDragging := True;
  FGutterLastY := Y;
end;

procedure TfrmMain.GutterOverlayMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Single);
var
  Delta, NewY: Single;
begin
  if not FGutterDragging then
    Exit();

  Delta := FGutterLastY - Y;  // Drag up = positive delta = scroll down
  FGutterLastY := Y;

  NewY := Editor.ViewportPosition.Y + Delta;
  if NewY < 0 then
    NewY := 0;

  Editor.ViewportPosition := PointF(Editor.ViewportPosition.X, NewY);
end;

procedure TfrmMain.GutterOverlayMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Single);
begin
  FGutterDragging := False;
end;

// -----------------------------------------------------------------------------
// History Management
// -----------------------------------------------------------------------------

procedure TfrmMain.AddToHistory(const Cmd: string);
begin
  if (FCommandHistory.Count = 0) or (FCommandHistory[FCommandHistory.Count - 1] <> Cmd) then
  begin
    FCommandHistory.Add(Cmd);
    if FCommandHistory.Count > MAX_HISTORY then
      FCommandHistory.Delete(0);
  end;
  FHistoryIndex := FCommandHistory.Count;
end;

procedure TfrmMain.NavigateHistory(Direction: Integer);
var
  NewIndex: Integer;
begin
  if FCommandHistory.Count = 0 then
    Exit();

  NewIndex := FHistoryIndex + Direction;

  if NewIndex < 0 then
    NewIndex := 0
  else if NewIndex >= FCommandHistory.Count then
  begin
    FHistoryIndex := FCommandHistory.Count;
    edtCommand.Text := '';
    Exit();
  end;

  FHistoryIndex := NewIndex;
  edtCommand.Text := FCommandHistory[FHistoryIndex];
  edtCommand.GoToTextEnd();
end;

// -----------------------------------------------------------------------------
// Output Helpers
// -----------------------------------------------------------------------------

procedure TfrmMain.Print(const Text: string);
begin
  FConsole.AppendToLastLine(Text);
end;

procedure TfrmMain.PrintLn(const Text: string);
begin
  FConsole.AddLine(Text);
end;

procedure TfrmMain.PrintReady();
begin
  PrintLn(_('ReadyMsg'));
  PrintLn('');
end;

procedure TfrmMain.PrintWelcomeBlock();
begin
  PrintLn('Plan9 BASIC v' + VERSION);
  {$IF Defined(ANDROID) or Defined(IOS)}
  PrintLn(_('WelcomeMobileTip'));
  {$ELSE}
  PrintLn(_('WelcomeDesktopTip'));
  {$ENDIF}
  PrintLn(_('WelcomeModeTip'));
  PrintLn();
  PrintReady();
  //Remembered so a later reprint can tell whether the console still holds
  //only this, or whether somebody has used the thing in the meantime.
  FWelcomeLines := FConsole.Lines.Count;
end;

function TfrmMain.ConsoleHoldsOnlyWelcome(): Boolean;
begin
  Result := (FConsole <> nil) and (FConsole.Lines.Count = FWelcomeLines);
end;

procedure TfrmMain.PrintError(const Msg: string);
begin
  PrintLn('? ' + Msg);
  PrintReady();
end;

procedure TfrmMain.PrintSyntaxError();
begin
  PrintError(_('SyntaxError'));
end;

end.

