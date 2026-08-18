{******************************************************************************
  Plan9BasicTest - headless test runner for Plan9Basic

  Compiles and executes .bas files with no IDE and no UI, then reports the
  assertions collected by TestLib.

  Usage:
    Plan9BasicTest [options] [path ...]

    path        .bas file or directory (recursive). Defaults to .\suite
    --smoke     only require that the file compiles and runs without a runtime
                error; do not require assertions. Turns the existing
                Examples/ and Demos/ programs into a regression net.
    --expect-fail
                invert the verdict: every file MUST fail. Used for the negative
                suite, where the point is that the engine rejects the program.
    --gui       also register the FMX libraries, so suites can exercise forms
                and controls. Windows are never shown.
    --compile-only
                stop after compiling: a file passes if it is valid source.
                For checking examples that must compile but should not run.
    --verbose   print each program's output, not just failures
    --timeout N script timeout in seconds per file (default 30, 0 = unlimited)

  Exit code: 0 all files passed, 1 one or more failed, 2 usage error.

  By default only the non-GUI libraries are registered. --gui adds the FMX ones:
  controls can be created and their properties exercised without a message loop,
  because form#() builds a form and form_show#() is a separate call.
******************************************************************************}
program Plan9BasicTest;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.StrUtils,
  System.Classes,
  System.IOUtils,
  System.Diagnostics,
  System.Generics.Collections,
  UnitUtils in '..\engine\UnitUtils.pas',
  lexer in '..\engine\lexer.pas',
  exec in '..\engine\exec.pas',
  parser in '..\engine\parser.pas',
  basic in '..\engine\basic.pas',
  UnitGC in '..\engine\utils\UnitGC.pas',
  HandleRegistry in '..\engine\utils\HandleRegistry.pas',
  ArrayLib in '..\engine\Libs\ArrayLib.pas',
  DateTimeLib in '..\engine\Libs\DateTimeLib.pas',
  StdLib in '..\engine\Libs\StdLib.pas',
  NumLib in '..\engine\Libs\NumLib.pas',
  StrLib in '..\engine\Libs\StrLib.pas',
  SysLib in '..\engine\Libs\SysLib.pas',
  PlatformInfoLib in '..\engine\Libs\PlatformInfoLib.pas',
  DictLib in '..\Libs\DictLib.pas',
  ConfigLib in '..\engine\Libs\ConfigLib.pas',
  StrListLib in '..\Libs\StrListLib.pas',
  JsonLib in '..\engine\Libs\JsonLib.pas',
  RegexLib in '..\Libs\RegexLib.pas',
  Base64Lib in '..\engine\Libs\Base64Lib.pas',
  GzipLib in '..\Libs\GzipLib.pas',
  ZipLib in '..\engine\Libs\ZipLib.pas',
  IOUtilsLib in '..\Libs\IOUtilsLib.pas',
  HttpLib in '..\engine\Libs\HttpLib.pas',
  ControlCommon in '..\Libs\GUI\ControlCommon.pas',
  FormLib in '..\Libs\GUI\FormLib.pas',
  LayoutLib in '..\Libs\GUI\LayoutLib.pas',
  RectangleLib in '..\Libs\GUI\RectangleLib.pas',
  LabelLib in '..\Libs\GUI\LabelLib.pas',
  EditLib in '..\Libs\GUI\EditLib.pas',
  MemoLib in '..\Libs\GUI\MemoLib.pas',
  ButtonLib in '..\Libs\GUI\ButtonLib.pas',
  SpeedButtonLib in '..\Libs\GUI\SpeedButtonLib.pas',
  ComboBoxLib in '..\Libs\GUI\ComboBoxLib.pas',
  ListBoxLib in '..\Libs\GUI\ListBoxLib.pas',
  CheckBoxLib in '..\Libs\GUI\CheckBoxLib.pas',
  RadioButtonLib in '..\Libs\GUI\RadioButtonLib.pas',
  PanelLib in '..\Libs\GUI\PanelLib.pas',
  CircleLib in '..\Libs\GUI\CircleLib.pas',
  RoundRectLib in '..\Libs\GUI\RoundRectLib.pas',
  EllipseLib in '..\Libs\GUI\EllipseLib.pas',
  ArcLib in '..\Libs\GUI\ArcLib.pas',
  PieLib in '..\Libs\GUI\PieLib.pas',
  LineLib in '..\Libs\GUI\LineLib.pas',
  CalloutRectangleLib in '..\Libs\GUI\CalloutRectangleLib.pas',
  PathLib in '..\Libs\GUI\PathLib.pas',
  ImageLib in '..\Libs\GUI\ImageLib.pas',
  SwitchLib in '..\Libs\GUI\SwitchLib.pas',
  StringGridLib in '..\Libs\GUI\StringGridLib.pas',
  ProgressBarLib in '..\Libs\GUI\ProgressBarLib.pas',
  TrackBarLib in '..\Libs\GUI\TrackBarLib.pas',
  TimerLib in '..\engine\Libs\GUI\TimerLib.pas',
  ScrollBoxLib in '..\Libs\GUI\ScrollBoxLib.pas',
  ColorAnimationLib in '..\Libs\GUI\Animations\ColorAnimationLib.pas',
  FloatAnimationLib in '..\Libs\GUI\Animations\FloatAnimationLib.pas',
  IntAnimationLib in '..\Libs\GUI\Animations\IntAnimationLib.pas',
  BitmapListAnimationLib in '..\Libs\GUI\Animations\BitmapListAnimationLib.pas',
  PathAnimationLib in '..\Libs\GUI\Animations\PathAnimationLib.pas',
  RectAnimationLib in '..\Libs\GUI\Animations\RectAnimationLib.pas',
  BlurEffectLib in '..\Libs\GUI\Effects\BlurEffectLib.pas',
  GlowEffectLib in '..\Libs\GUI\Effects\GlowEffectLib.pas',
  ShadowEffectLib in '..\Libs\GUI\Effects\ShadowEffectLib.pas',
  BevelEffectLib in '..\Libs\GUI\Effects\BevelEffectLib.pas',
  ColorKeyAlphaEffectLib in '..\Libs\GUI\Effects\ColorKeyAlphaEffectLib.pas',
  InnerGlowEffectLib in '..\Libs\GUI\Effects\InnerGlowEffectLib.pas',
  MonochromeEffectLib in '..\Libs\GUI\Effects\MonochromeEffectLib.pas',
  ReflectionEffectLib in '..\Libs\GUI\Effects\ReflectionEffectLib.pas',
  ContrastEffectLib in '..\Libs\GUI\Effects\ContrastEffectLib.pas',
  HueAdjustEffectLib in '..\Libs\GUI\Effects\HueAdjustEffectLib.pas',
  InvertEffectLib in '..\Libs\GUI\Effects\InvertEffectLib.pas',
  SepiaEffectLib in '..\Libs\GUI\Effects\SepiaEffectLib.pas',
  EmbossEffectLib in '..\Libs\GUI\Effects\EmbossEffectLib.pas',
  PaperSketchEffectLib in '..\Libs\GUI\Effects\PaperSketchEffectLib.pas',
  PencilStrokeEffectLib in '..\Libs\GUI\Effects\PencilStrokeEffectLib.pas',
  PixelateEffectLib in '..\Libs\GUI\Effects\PixelateEffectLib.pas',
  SharpenEffectLib in '..\Libs\GUI\Effects\SharpenEffectLib.pas',
  ToonEffectLib in '..\Libs\GUI\Effects\ToonEffectLib.pas',
  BandsEffectLib in '..\Libs\GUI\Effects\BandsEffectLib.pas',
  MagnifyEffectLib in '..\Libs\GUI\Effects\MagnifyEffectLib.pas',
  RippleEffectLib in '..\Libs\GUI\Effects\RippleEffectLib.pas',
  SwirlEffectLib in '..\Libs\GUI\Effects\SwirlEffectLib.pas',
  WaveEffectLib in '..\Libs\GUI\Effects\WaveEffectLib.pas',
  WrapEffectLib in '..\Libs\GUI\Effects\WrapEffectLib.pas',
  BlindTransitionEffectLib in '..\Libs\GUI\Effects\BlindTransitionEffectLib.pas',
  CircleTransitionEffectLib in '..\Libs\GUI\Effects\CircleTransitionEffectLib.pas',
  DissolveTransitionEffectLib in '..\Libs\GUI\Effects\DissolveTransitionEffectLib.pas',
  FadeTransitionEffectLib in '..\Libs\GUI\Effects\FadeTransitionEffectLib.pas',
  SlideTransitionEffectLib in '..\Libs\GUI\Effects\SlideTransitionEffectLib.pas',
  SWipeTransitionEffectLib in '..\Libs\GUI\Effects\SWipeTransitionEffectLib.pas',
  BloodTransitionEffectLib in '..\Libs\GUI\Effects\BloodTransitionEffectLib.pas',
  BlurTransitionEffectLib in '..\Libs\GUI\Effects\BlurTransitionEffectLib.pas',
  BrightTransitionEffectLib in '..\Libs\GUI\Effects\BrightTransitionEffectLib.pas',
  CrumpleTransitionEffectLib in '..\Libs\GUI\Effects\CrumpleTransitionEffectLib.pas',
  DropTransitionEffectLib in '..\Libs\GUI\Effects\DropTransitionEffectLib.pas',
  LineTransitionEffectLib in '..\Libs\GUI\Effects\LineTransitionEffectLib.pas',
  MagnifyTransitionEffectLib in '..\Libs\GUI\Effects\MagnifyTransitionEffectLib.pas',
  PixelateTransitionEffectLib in '..\Libs\GUI\Effects\PixelateTransitionEffectLib.pas',
  RotateCrumpleTransitionEffectLib in '..\Libs\GUI\Effects\RotateCrumpleTransitionEffectLib.pas',
  SaturateTransitionEffectLib in '..\Libs\GUI\Effects\SaturateTransitionEffectLib.pas',
  ShapeTransitionEffectLib in '..\Libs\GUI\Effects\ShapeTransitionEffectLib.pas',
  SwirlTransitionEffectLib in '..\Libs\GUI\Effects\SwirlTransitionEffectLib.pas',
  WaterTransitionEffectLib in '..\Libs\GUI\Effects\WaterTransitionEffectLib.pas',
  WaveTransitionEffectLib in '..\Libs\GUI\Effects\WaveTransitionEffectLib.pas',
  WiggleTransitionEffectLib in '..\Libs\GUI\Effects\WiggleTransitionEffectLib.pas',
  RippleTransitionEffectLib in '..\Libs\GUI\Effects\RippleTransitionEffectLib.pas',
  BoxBlurEffectLib in '..\Libs\GUI\Effects\BoxBlurEffectLib.pas',
  DirectionalBlurEffectLib in '..\Libs\GUI\Effects\DirectionalBlurEffectLib.pas',
  GaussianBlurEffectLib in '..\Libs\GUI\Effects\GaussianBlurEffectLib.pas',
  RadialBlurEffectLib in '..\Libs\GUI\Effects\RadialBlurEffectLib.pas',
  BloomEffectLib in '..\Libs\GUI\Effects\BloomEffectLib.pas',
  GloomEffectLib in '..\Libs\GUI\Effects\GloomEffectLib.pas',
  AffineTransformEffectLib in '..\Libs\GUI\Effects\AffineTransformEffectLib.pas',
  CropEffectLib in '..\Libs\GUI\Effects\CropEffectLib.pas',
  PerspectiveTransformEffectLib in '..\Libs\GUI\Effects\PerspectiveTransformEffectLib.pas',
  TilerEffectLib in '..\Libs\GUI\Effects\TilerEffectLib.pas',
  BandedSwirlTransitionEffectLib in '..\Libs\GUI\Effects\BandedSwirlTransitionEffectLib.pas',
  FillEffectLib in '..\Libs\GUI\Effects\FillEffectLib.pas',
  FillRGBEffectLib in '..\Libs\GUI\Effects\FillRGBEffectLib.pas',
  MaskToAlphaEffectLib in '..\Libs\GUI\Effects\MaskToAlphaEffectLib.pas',
  NormalBlendEffectLib in '..\Libs\GUI\Effects\NormalBlendEffectLib.pas',
  PinchEffectLib in '..\Libs\GUI\Effects\PinchEffectLib.pas',
  SmoothMagnifyEffectLib in '..\Libs\GUI\Effects\SmoothMagnifyEffectLib.pas',
  BandedSwirlEffectLib in '..\Libs\GUI\Effects\BandedSwirlEffectLib.pas',
  MediaPlayerLib in '..\Libs\GUI\MediaPlayerLib.pas',
  SQLiteLib in '..\Libs\SQLiteLib.pas',
  AILib in '..\engine\Libs\AI\AILib.pas',
  RAGEngine in '..\engine\Libs\AI\RAGEngine.pas',
  RAGLib in '..\engine\Libs\AI\RAGLib.pas',
  FMX.Forms,
  TestLib in 'TestLib.pas';

type
  TFileOutcome = (foPass, foCompileError, foRuntimeError, foAssertFailed,
                  foNoAsserts, foOutputFailure);

  TFileResult = record
    FileName: String;
    Outcome: TFileOutcome;
    Passed: Integer;
    Failed: Integer;
    Detail: String;
    Failures: TArray<String>;
    Output: String;
    ElapsedMs: Int64;
  end;

var
  OptSmoke: Boolean = False;
  OptVerbose: Boolean = False;
  OptExpectFail: Boolean = False;
  OptGui: Boolean = False;
  OptCompileOnly: Boolean = False;
  OptTimeout: Int64 = 30;

//Programs written before this runner existed report their own results by
//printing lines like "[FAIL] Test 3: ...". Without this check a file that
//printed nothing but failures would still be reported as passing in smoke
//mode, which is worse than not running it at all.
function OutputFailureLines(const Output: String): TArray<String>;
var
  Line: String;
  Collected: TStringList;
begin
  Collected := TStringList.Create();
  try
    for Line in Output.Split([sLineBreak]) do
      if Line.Contains('[FAIL]') or Line.Contains('[ASSERT FAILED]') then
        Collected.Add(Line.Trim());
    Result := Collected.ToStringArray();
  finally
    Collected.Free();
  end;
end;


//The GUI wrappers need an FMX Application and a parent form, so they are only
//registered under --gui. Creating a control does not show anything: form#()
//builds the form and form_show#() is a separate call the suites never make.
procedure RegisterGuiLibs(Engine: TBasicEngine; Output: TStrings);
begin
    FormLib.RegisterFormFuncs(Engine.Functions, Engine, Output);
    LayoutLib.RegisterLayoutFuncs(Engine.Functions, Engine, Output);
    RectangleLib.RegisterRectangleFuncs(Engine.Functions, Engine, Output);
    LabelLib.RegisterLabelFuncs(Engine.Functions, Engine, Output);
    EditLib.RegisterEditFuncs(Engine.Functions, Engine, Output);
    MemoLib.RegisterMemoFuncs(Engine.Functions, Engine, Output);
    ButtonLib.RegisterButtonFuncs(Engine.Functions, Engine, Output);
    SpeedButtonLib.RegisterSpeedButtonFuncs(Engine.Functions, Engine, Output);
    ComboBoxLib.RegisterComboBoxFuncs(Engine.Functions, Engine, Output);
    ListBoxLib.RegisterListBoxFuncs(Engine.Functions, Engine, Output);
    CheckBoxLib.RegisterCheckBoxFuncs(Engine.Functions, Engine, Output);
    RadioButtonLib.RegisterRadioButtonFuncs(Engine.Functions, Engine, Output);
    PanelLib.RegisterPanelFuncs(Engine.Functions, Engine, Output);
    ScrollBoxLib.RegisterScrollBoxFuncs(Engine.Functions, Engine, Output);
    CircleLib.RegisterCircleFuncs(Engine.Functions, Engine, Output);
    RoundRectLib.RegisterRoundRectFuncs(Engine.Functions, Engine, Output);
    EllipseLib.RegisterEllipseFuncs(Engine.Functions, Engine, Output);
    ArcLib.RegisterArcFuncs(Engine.Functions, Engine, Output);
    PieLib.RegisterPieFuncs(Engine.Functions, Engine, Output);
    LineLib.RegisterLineFuncs(Engine.Functions, Engine, Output);
    CalloutRectangleLib.RegisterCalloutRectangleFuncs(Engine.Functions, Engine, Output);
    PathLib.RegisterPathFuncs(Engine.Functions, Engine, Output);
    ImageLib.RegisterImageFuncs(Engine.Functions, Engine, Output);
    SwitchLib.RegisterSwitchFuncs(Engine.Functions, Engine, Output);
    StringGridLib.RegisterStringGridFuncs(Engine.Functions, Engine, Output);
    ProgressBarLib.RegisterProgressBarFuncs(Engine.Functions, Engine, Output);
    TrackBarLib.RegisterTrackBarFuncs(Engine.Functions, Engine, Output);
    TimerLib.RegisterTimerFuncs(Engine.Functions, Engine, Output);
    ColorAnimationLib.RegisterColorAnimationFuncs(Engine.Functions, Engine, Output);
    FloatAnimationLib.RegisterFloatAnimationFuncs(Engine.Functions, Engine, Output);
    IntAnimationLib.RegisterIntAnimationFuncs(Engine.Functions, Engine, Output);
    BitmapListAnimationLib.RegisterBitmapListAnimationFuncs(Engine.Functions, Engine, Output);
    PathAnimationLib.RegisterPathAnimationFuncs(Engine.Functions, Engine, Output);
    RectAnimationLib.RegisterRectAnimationFuncs(Engine.Functions, Engine, Output);
    BlurEffectLib.RegisterBlurEffectFuncs(Engine.Functions);
    GlowEffectLib.RegisterGlowEffectFuncs(Engine.Functions);
    ShadowEffectLib.RegisterShadowEffectFuncs(Engine.Functions);
    BevelEffectLib.RegisterBevelEffectFuncs(Engine.Functions);
    ColorKeyAlphaEffectLib.RegisterColorKeyAlphaEffectFuncs(Engine.Functions);
    InnerGlowEffectLib.RegisterInnerGlowEffectFuncs(Engine.Functions);
    MonochromeEffectLib.RegisterMonochromeEffectFuncs(Engine.Functions);
    ReflectionEffectLib.RegisterReflectionEffectFuncs(Engine.Functions);
    ContrastEffectLib.RegisterContrastEffectFuncs(Engine.Functions);
    HueAdjustEffectLib.RegisterHueAdjustEffectFuncs(Engine.Functions);
    InvertEffectLib.RegisterInvertEffectFuncs(Engine.Functions);
    SepiaEffectLib.RegisterSepiaEffectFuncs(Engine.Functions);
    EmbossEffectLib.RegisterEmbossEffectFuncs(Engine.Functions);
    PaperSketchEffectLib.RegisterPaperSketchEffectFuncs(Engine.Functions);
    PencilStrokeEffectLib.RegisterPencilStrokeEffectFuncs(Engine.Functions);
    PixelateEffectLib.RegisterPixelateEffectFuncs(Engine.Functions);
    SharpenEffectLib.RegisterSharpenEffectFuncs(Engine.Functions);
    ToonEffectLib.RegisterToonEffectFuncs(Engine.Functions);
    BandsEffectLib.RegisterBandsEffectFuncs(Engine.Functions);
    MagnifyEffectLib.RegisterMagnifyEffectFuncs(Engine.Functions);
    RippleEffectLib.RegisterRippleEffectFuncs(Engine.Functions);
    SwirlEffectLib.RegisterSwirlEffectFuncs(Engine.Functions);
    WaveEffectLib.RegisterWaveEffectFuncs(Engine.Functions);
    WrapEffectLib.RegisterWrapEffectFuncs(Engine.Functions);
    BlindTransitionEffectLib.RegisterBlindTransitionEffectFuncs(Engine.Functions);
    CircleTransitionEffectLib.RegisterCircleTransitionEffectFuncs(Engine.Functions);
    DissolveTransitionEffectLib.RegisterDissolveTransitionEffectFuncs(Engine.Functions);
    SlideTransitionEffectLib.RegisterSlideTransitionEffectFuncs(Engine.Functions);
    SwipeTransitionEffectLib.RegisterSwipeTransitionEffectFuncs(Engine.Functions);
    FadeTransitionEffectLib.RegisterFadeTransitionEffectFuncs(Engine.Functions);
    BandedSwirlTransitionEffectLib.RegisterBandedSwirlTransitionEffectFuncs(Engine.Functions);
    BloodTransitionEffectLib.RegisterBloodTransitionEffectFuncs(Engine.Functions);
    BlurTransitionEffectLib.RegisterBlurTransitionEffectFuncs(Engine.Functions);
    BrightTransitionEffectLib.RegisterBrightTransitionEffectFuncs(Engine.Functions);
    CrumpleTransitionEffectLib.RegisterCrumpleTransitionEffectFuncs(Engine.Functions);
    DropTransitionEffectLib.RegisterDropTransitionEffectFuncs(Engine.Functions);
    LineTransitionEffectLib.RegisterLineTransitionEffectFuncs(Engine.Functions);
    MagnifyTransitionEffectLib.RegisterMagnifyTransitionEffectFuncs(Engine.Functions);
    PixelateTransitionEffectLib.RegisterPixelateTransitionEffectFuncs(Engine.Functions);
    RotateCrumpleTransitionEffectLib.RegisterRotateCrumpleTransitionEffectFuncs(Engine.Functions);
    SaturateTransitionEffectLib.RegisterSaturateTransitionEffectFuncs(Engine.Functions);
    ShapeTransitionEffectLib.RegisterShapeTransitionEffectFuncs(Engine.Functions);
    SwirlTransitionEffectLib.RegisterSwirlTransitionEffectFuncs(Engine.Functions);
    WaterTransitionEffectLib.RegisterWaterTransitionEffectFuncs(Engine.Functions);
    WaveTransitionEffectLib.RegisterWaveTransitionEffectFuncs(Engine.Functions);
    WiggleTransitionEffectLib.RegisterWiggleTransitionEffectFuncs(Engine.Functions);
    RippleTransitionEffectLib.RegisterRippleTransitionEffectFuncs(Engine.Functions);
    BoxBlurEffectLib.RegisterBoxBlurEffectFuncs(Engine.Functions);
    DirectionalBlurEffectLib.RegisterDirectionalBlurEffectFuncs(Engine.Functions);
    GaussianBlurEffectLib.RegisterGaussianBlurEffectFuncs(Engine.Functions);
    RadialBlurEffectLib.RegisterRadialBlurEffectFuncs(Engine.Functions);
    BloomEffectLib.RegisterBloomEffectFuncs(Engine.Functions);
    GloomEffectLib.RegisterGloomEffectFuncs(Engine.Functions);
    AffineTransformEffectLib.RegisterAffineTransformEffectFuncs(Engine.Functions);
    CropEffectLib.RegisterCropEffectFuncs(Engine.Functions);
    PerspectiveTransformEffectLib.RegisterPerspectiveTransformEffectFuncs(Engine.Functions);
    TilerEffectLib.RegisterTilerEffectFuncs(Engine.Functions);
    NormalBlendEffectLib.RegisterNormalBlendEffectFuncs(Engine.Functions);
    BandedSwirlEffectLib.RegisterBandedSwirlEffectFuncs(Engine.Functions);
    PinchEffectLib.RegisterPinchEffectFuncs(Engine.Functions);
    SmoothMagnifyEffectLib.RegisterSmoothMagnifyEffectFuncs(Engine.Functions);
    MaskToAlphaEffectLib.RegisterMaskToAlphaEffectFuncs(Engine.Functions);
    FillRGBEffectLib.RegisterFillRGBEffectFuncs(Engine.Functions);
    FillEffectLib.RegisterFillEffectFuncs(Engine.Functions);
    MediaPlayerLib.RegisterMediaPlayerFuncs(Engine.Functions, Engine, Output);
    SQLiteLib.RegisterSqliteFuncs(Engine.Functions, Engine, Output);
    AILib.RegisterAIFuncs(Engine.Functions, Engine, Output);
    RAGLib.RegisterRAGFuncs(Engine.Functions);
end;
//----------------------------------------------------------------------------
// Execution of a single file
//----------------------------------------------------------------------------

function RunFile(const FileName: String): TFileResult;
var
  Engine: TBasicEngine;
  Output, Source: TStringList;
  Watch: TStopwatch;
  RuntimeMsg: String;
begin
  Result := Default(TFileResult);
  Result.FileName := FileName;

  //Each file gets a fresh GC and engine so that state cannot leak between
  //tests. Teardown order mirrors InitBASICEngine: engine, then GC.
  GC := TGarbageCollector.Create();
  Engine := TBasicEngine.Create();
  Output := TStringList.Create();
  Source := TStringList.Create();
  Watch := TStopwatch.StartNew();
  try
    Engine.ScriptTimeOut := OptTimeout;

    ArrayLib.RegisterArrayFuncs(Engine.Functions);
    DateTimeLib.RegisterDateTimeFuncs(Engine.Functions);
    StdLib.RegisterStdFuncs(Engine.Functions);
    NumLib.RegisterNumFuncs(Engine.Functions);
    StrLib.RegisterStrFuncs(Engine.Functions);
    SysLib.RegisterSysFuncs(Engine.Functions);
    PlatformInfoLib.RegisterPlatformInfoFuncs(Engine.Functions);
    DictLib.RegisterDictFuncs(Engine.Functions);
    ConfigLib.RegisterConfigFuncs(Engine.Functions);
    StrListLib.RegisterStringsFuncs(Engine.Functions, Engine, Output);
    JsonLib.RegisterJsonFuncs(Engine.Functions);
    RegexLib.RegisterRegexFuncs(Engine.Functions);
    Base64Lib.RegisterBase64Funcs(Engine.Functions);
    GzipLib.RegisterGzipFuncs(Engine.Functions);
    ZipLib.RegisterZipFuncs(Engine.Functions);
    IOUtilsLib.RegisterIOUtilsFuncs(Engine.Functions);
    HttpLib.RegisterHttpFuncs(Engine.Functions, Engine, Output);
    if OptGui then
      RegisterGuiLibs(Engine, Output);
    TestLib.RegisterTestFuncs(Engine.Functions, Engine);

    TestLib.ResetTestState();

    try
      Source.LoadFromFile(FileName, TEncoding.UTF8);
    except
      on E: Exception do
      begin
        Result.Outcome := foCompileError;
        Result.Detail := 'cannot read file: ' + E.Message;
        Exit();
      end;
    end;

    if Engine.Compile(Source) <> 0 then
    begin
      Result.Outcome := foCompileError;
      Result.Detail := Format('line %d, pos %d: %s',
        [Engine.ErrorLine, Engine.ErrorPos, Engine.ErrorMessage]);
      Exit();
    end;

    //Compiling is the whole verdict when the caller only wants to know that
    //the source is valid. Documentation examples are the reason: they must
    //compile, but running one may open a window or reach the network, and the
    //page is not asking the reader to accept either just to read it.
    if OptCompileOnly then
    begin
      Result.Outcome := foPass;
      Exit();
    end;

    RuntimeMsg := '';
    try
      Engine.ExecuteProgram(Output);
    except
      on E: Exception do
        RuntimeMsg := Format('line %d: %s', [Engine.Parser.exec.SourceLine, E.Message]);
    end;

    //The VM also records recoverable runtime errors without raising
    if (RuntimeMsg = '') and (Engine.Parser.exec.ErrorMessage <> '') then
      RuntimeMsg := Engine.Parser.exec.ErrorMessage;

    Result.Passed := TestLib.AssertsPassed;
    Result.Failed := TestLib.AssertsFailed;
    Result.Failures := TestLib.Failures.ToStringArray();
    Result.Output := Output.Text;

    if RuntimeMsg <> '' then
    begin
      Result.Outcome := foRuntimeError;
      Result.Detail := RuntimeMsg;
    end
    else if Result.Failed > 0 then
      Result.Outcome := foAssertFailed
    else if Length(OutputFailureLines(Result.Output)) > 0 then
    begin
      Result.Outcome := foOutputFailure;
      Result.Failures := OutputFailureLines(Result.Output);
      Result.Detail := Format('%d self-reported failure(s) in the program output',
        [Length(Result.Failures)]);
    end
    else if (Result.Passed = 0) and (not OptSmoke) then
      Result.Outcome := foNoAsserts
    else
      Result.Outcome := foPass;
  finally
    Result.ElapsedMs := Watch.ElapsedMilliseconds;
    //Teardown order from InitBASICEngine: timers, forms, engine, GC.
    if OptGui then
    begin
      TimerLib.CleanupAllTimers();
      FormLib.CleanupAllForms();
    end;
    Source.Free();
    Output.Free();
    Engine.Free();
    FreeAndNil(GC);
  end;
end;

//----------------------------------------------------------------------------
// Reporting
//----------------------------------------------------------------------------

function OutcomeLabel(Outcome: TFileOutcome): String;
begin
  case Outcome of
    foPass:         Result := 'PASS';
    foCompileError: Result := 'COMPILE';
    foRuntimeError: Result := 'RUNTIME';
    foAssertFailed: Result := 'FAIL';
    foNoAsserts:    Result := 'EMPTY';
    foOutputFailure: Result := 'OUTPUT';
  else
    Result := '????';
  end;
end;

//A file counts as good when it passed, or -- under --expect-fail -- when it
//did not. The negative suite exists to prove the engine rejects things.
function FileSucceeded(const R: TFileResult): Boolean;
begin
  if OptExpectFail then
    Result := R.Outcome <> foPass
  else
    Result := R.Outcome = foPass;
end;

procedure ReportFile(const R: TFileResult; const BaseDir: String);
var
  Name, Line: String;
begin
  Name := R.FileName;
  if (BaseDir <> '') and Name.StartsWith(BaseDir) then
    Name := Name.Substring(BaseDir.Length).TrimLeft([PathDelim]);

  Writeln(Format('%-8s %-52s %4d ok %4d fail %6d ms',
    [OutcomeLabel(R.Outcome), Name, R.Passed, R.Failed, R.ElapsedMs]));

  //Under --expect-fail the detail is the evidence that the rejection happened
  //for the right reason, so it stays visible.
  if R.Detail <> '' then
    Writeln('         ! ' + R.Detail);

  if not OptExpectFail then
    for Line in R.Failures do
      Writeln('         - ' + Line);

  if OptExpectFail and (R.Outcome = foPass) then
    Writeln('         ! expected this file to be rejected, but it ran clean');

  if (not OptExpectFail) and (R.Outcome = foNoAsserts) then
    Writeln('         ! no assertions were executed (use --smoke to allow this)');

  if OptVerbose and (R.Output <> '') then
  begin
    Writeln('         --- output ---');
    for Line in R.Output.Split([sLineBreak]) do
      Writeln('         | ' + Line);
  end;
end;

//----------------------------------------------------------------------------
// Entry point
//----------------------------------------------------------------------------

procedure CollectFiles(const Path: String; Files: TStringList);
var
  Found: TArray<String>;
  F: String;
begin
  if TFile.Exists(Path) then
  begin
    Files.Add(TPath.GetFullPath(Path));
    Exit();
  end;

  if TDirectory.Exists(Path) then
  begin
    Found := TDirectory.GetFiles(Path, '*.bas', TSearchOption.soAllDirectories);
    for F in Found do
      Files.Add(TPath.GetFullPath(F));
    Exit();
  end;

  Writeln(ErrOutput, 'path not found: ' + Path);
end;

var
  Args, Paths, Files: TStringList;
  i: Integer;
  Arg, BaseDir: String;
  Results: TList<TFileResult>;
  R: TFileResult;
  TotalPassed, TotalFailed, FilesOk, FilesBad: Integer;
  Watch: TStopwatch;
begin
  //Headless: no message loop exists, so the VM must not pump one
  UnitGC.SkipProcessMessages := True;
  //Keep number formatting stable regardless of the machine's locale
  FormatSettings := TFormatSettings.Invariant;

  Args := TStringList.Create();
  Paths := TStringList.Create();
  Files := TStringList.Create();
  Results := TList<TFileResult>.Create();
  try
    for i := 1 to ParamCount do
      Args.Add(ParamStr(i));

    i := 0;
    while i < Args.Count do
    begin
      Arg := Args[i];
      if Arg = '--smoke' then
        OptSmoke := True
      else if Arg = '--verbose' then
        OptVerbose := True
      else if Arg = '--expect-fail' then
        OptExpectFail := True
      else if Arg = '--gui' then
        OptGui := True
      else if Arg = '--compile-only' then
        OptCompileOnly := True
      else if Arg = '--timeout' then
      begin
        Inc(i);
        if (i >= Args.Count) or not TryStrToInt64(Args[i], OptTimeout) then
        begin
          Writeln(ErrOutput, '--timeout requires a number of seconds');
          ExitCode := 2;
          Exit();
        end;
      end
      else if Arg.StartsWith('--') then
      begin
        Writeln(ErrOutput, 'unknown option: ' + Arg);
        ExitCode := 2;
        Exit();
      end
      else
        Paths.Add(Arg);
      Inc(i);
    end;

    if Paths.Count = 0 then
      Paths.Add('suite');

    for i := 0 to Paths.Count - 1 do
      CollectFiles(Paths[i], Files);

    if Files.Count = 0 then
    begin
      Writeln(ErrOutput, 'no .bas files found');
      ExitCode := 2;
      Exit();
    end;

    Files.Sort();

    //Trim the common root from reported names to keep the output readable
    BaseDir := TPath.GetFullPath(Paths[0]);
    if not TDirectory.Exists(BaseDir) then
      BaseDir := TPath.GetDirectoryName(BaseDir);

    Writeln(Format('Plan9Basic test runner - %d file(s)%s%s', [Files.Count,
      IfThen(OptSmoke, ' [smoke mode]', ''),
      IfThen(OptExpectFail, ' [expect-fail mode]', '')]));
    Writeln(StringOfChar('-', 92));

    Watch := TStopwatch.StartNew();
    for i := 0 to Files.Count - 1 do
    begin
      R := RunFile(Files[i]);
      Results.Add(R);
      ReportFile(R, BaseDir);
    end;

    TotalPassed := 0;
    TotalFailed := 0;
    FilesOk := 0;
    FilesBad := 0;
    for R in Results do
    begin
      Inc(TotalPassed, R.Passed);
      Inc(TotalFailed, R.Failed);
      if FileSucceeded(R) then Inc(FilesOk) else Inc(FilesBad);
    end;

    Writeln(StringOfChar('-', 92));
    Writeln(Format('%d file(s): %d passed, %d failed | %d assertion(s): %d ok, %d failed | %d ms',
      [Files.Count, FilesOk, FilesBad, TotalPassed + TotalFailed, TotalPassed,
       TotalFailed, Watch.ElapsedMilliseconds]));

    if FilesBad > 0 then
      ExitCode := 1
    else
      ExitCode := 0;
  finally
    Results.Free();
    Files.Free();
    Paths.Free();
    Args.Free();
  end;
end.
