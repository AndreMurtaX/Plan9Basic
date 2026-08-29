{******************************************************************************
  AsmDump - what the parser actually emitted

  Compiles a .bas file and prints the assembly the VM will run, one instruction
  per line with its index. Nothing about the engine is exercised: this is for
  reading, and for diffing.

  Two jobs:

    * Answering "what does this compile to" without guessing. A peephole pass
      that rewrites a four-instruction window has to be written against the
      window the parser really emits, not the one it is assumed to emit.

    * Proving a change to the parser did not disturb anything else. Dump every
      example before and after, diff the two, and a syntax addition that is
      genuinely additive shows zero lines changed for every program that does
      not use it.

  Usage:
    AsmDump [--quiet] <file.bas | directory> ...

    --quiet   one line per file with a checksum instead of the full listing,
              which is what you want when diffing a hundred programs
    --gui     register the FireMonkey libraries too. Without this every
              program that touches a control fails to compile, which on this
              tree is most of them.

  Exit code: 0 if everything compiled, 1 otherwise.
******************************************************************************}
program AsmDump;

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
  HostServices in '..\engine\utils\HostServices.pas',
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
    //MediaPlayerLib is the only one of these that belongs here: it reaches
    //FMX.Media. SQLiteLib, AILib and RAGLib do not touch FireMonkey at all and
    //are registered with the rest of the core, below.
    MediaPlayerLib.RegisterMediaPlayerFuncs(Engine.Functions, Engine, Output);
end;

var
  OptQuiet: Boolean = False;
  OptGui: Boolean = False;
  Failures: Integer = 0;

function DumpOne(const FileName: String): Boolean;
var
  Engine: TBasicEngine;
  Output, Source: TStringList;
  i: Integer;
  Line: String;
  Sum: Cardinal;
  ch: Char;
begin
  Result := False;
  GC := TGarbageCollector.Create();
  Engine := TBasicEngine.Create();
  Output := TStringList.Create();
  Source := TStringList.Create();
  try
    Engine.ScriptTimeOut := 0;
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
    SQLiteLib.RegisterSqliteFuncs(Engine.Functions, Engine, Output);
    AILib.RegisterAIFuncs(Engine.Functions, Engine, Output);
    RAGLib.RegisterRAGFuncs(Engine.Functions);
    if OptGui then
      RegisterGuiLibs(Engine, Output);

    try
      Source.LoadFromFile(FileName, TEncoding.UTF8);
    except
      on E: Exception do
      begin
        WriteLn(Format('%s: cannot read: %s', [FileName, E.Message]));
        Exit();
      end;
    end;

    //A GUI program will not compile here, because the FMX libraries are not
    //registered. Say so rather than reporting it as a difference.
    if Engine.Compile(Source) <> 0 then
    begin
      WriteLn(Format('%s: line %d, pos %d: %s',
        [TPath.GetFileName(FileName), Engine.ErrorLine, Engine.ErrorPos,
         Engine.ErrorMessage]));
      Exit();
    end;

    if OptQuiet then
    begin
      Sum := 0;
      for i := 0 to Engine.ASMCode.Count - 1 do
        for ch in Engine.ASMCode[i].Str do
          Sum := ((Sum shl 5) - Sum + Ord(ch)) and $FFFFFFFF;
      WriteLn(Format('%-40s %6d instr  %.8x',
        [TPath.GetFileName(FileName), Engine.ASMCode.Count, Sum]));
    end
    else
    begin
      WriteLn('== ' + TPath.GetFileName(FileName) + ' ==');
      for i := 0 to Engine.ASMCode.Count - 1 do
      begin
        Line := Engine.ASMCode[i].Str;
        WriteLn(Format('%6d  %s', [i, Line]));
      end;
    end;
    Result := True;
  finally
    Source.Free();
    Output.Free();
    Engine.Free();
    FreeAndNil(GC);
  end;
end;

procedure Collect(const APath: String; AInto: TStrings);
var
  Found: TArray<String>;
  S: String;
begin
  if TFile.Exists(APath) then
  begin
    AInto.Add(APath);
    Exit();
  end;
  if not TDirectory.Exists(APath) then
  begin
    WriteLn('no such file or directory: ' + APath);
    Exit();
  end;
  Found := TDirectory.GetFiles(APath, '*.bas', TSearchOption.soAllDirectories);
  TArray.Sort<String>(Found);
  for S in Found do
    AInto.Add(S);
end;

var
  Paths, Files: TStringList;
  i: Integer;
  Arg, F: String;
begin
  Paths := TStringList.Create();
  Files := TStringList.Create();
  try
    for i := 1 to ParamCount() do
    begin
      Arg := ParamStr(i);
      if Arg = '--quiet' then
        OptQuiet := True
      else if Arg = '--gui' then
        OptGui := True
      else if StartsStr('--', Arg) then
      begin
        WriteLn('unknown option: ' + Arg);
        ExitCode := 2;
        Exit();
      end
      else
        Paths.Add(Arg);
    end;

    if Paths.Count = 0 then
    begin
      WriteLn('usage: AsmDump [--quiet] <file.bas | directory> ...');
      ExitCode := 2;
      Exit();
    end;

    for Arg in Paths do
      Collect(Arg, Files);

    for F in Files do
      if not DumpOne(F) then
        Inc(Failures);

    if Failures > 0 then
    begin
      WriteLn(Format('%d file(s) did not compile', [Failures]));
      ExitCode := 1;
    end;
  finally
    Files.Free();
    Paths.Free();
  end;
end.
