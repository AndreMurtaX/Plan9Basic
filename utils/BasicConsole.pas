unit BasicConsole;

// =============================================================================
// BasicConsole.pas - Rich Console Component for Plan9Basic
// =============================================================================
//
// Replaces the Console TMemo with a TTextLayout-based control that:
//   - Renders normal text output (PRINT, errors, Ready.) in the theme color
//   - Renders LIST output with full syntax highlighting
//   - Supports real-time line-by-line appending (compatible with TStrings)
//   - Provides smooth scrolling on all platforms (desktop + mobile)
//
// Architecture:
//   TBasicConsole (TScrollBox)  — H+V scrolling for long lines + many lines
//     +-- FBackground (TRectangle) - solid background, sized to content
//     +-- FContent (TConsoleContent : TControl) - paints via TTextLayout
//
// Data flow:
//   FLines: TStringList   <-- THE canonical line storage
//     exposed via [Lines] property
//     passed to ExecuteProgram(), all RegisterXxxFuncs(), PrintProc, etc.
//     OnChange event --> reconcile FIsCodeLine, repaint, auto-scroll
//
//   FIsCodeLine: TList<Boolean>  <-- parallel per-line flag
//     True  = syntax-highlighted (LIST output)
//     False = plain text (everything else)
//
// TTextLayout technique (from TTextLayout tutorial):
//   1. TTextLayoutManager.DefaultTextLayout.Create -> native engine
//   2. BeginUpdate / EndUpdate -> batch attribute changes (no flicker)
//   3. TTextAttributedRange -> per-token font + color
//   4. RenderLayout(Canvas) -> final output to screen
//
// Memory ownership for TTextLayout attributes:
//   TTextAttribute COPIES font properties — does NOT take TFont ownership!
//   Therefore we use a single reusable FTokenFont to avoid leaks.
//   TTextAttributedRange -> TTextLayout (AddAttribute takes ownership)
//   ClearAttributes() frees TTextAttributedRange + TTextAttribute objects.
//
// =============================================================================

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Generics.Collections, System.Math,
  FMX.Types, FMX.Controls, FMX.Graphics, FMX.TextLayout, FMX.Layouts,
  FMX.Objects;

type
  // -------------------------------------------------------------------------
  // Syntax token types for highlighting (LIST output only)
  // -------------------------------------------------------------------------
  TSyntaxTokenKind = (
    stkDefault,      // Regular identifiers and text
    stkKeyword,      // Language keywords (IF, THEN, FOR, etc.)
    stkString,       // String literals ("...")
    stkNumber,       // Numeric constants (42, 3.14, 1E10)
    stkComment,      // Comments (REM ..., ' ...)
    stkFunction,     // Function calls (name$(), name#(), name())
    stkOperator,     // Operators (+, -, *, /, =, <>, etc.)
    stkLineNumber,   // Line number at start of listing line
    stkLabel,        // Labels (name:)
    stkDirective     // DATA, RESTORE, TRACE, etc.
  );

  // -------------------------------------------------------------------------
  // A single token identified during syntax analysis
  // -------------------------------------------------------------------------
  TSyntaxToken = record
    Kind: TSyntaxTokenKind;
    Start: Integer;   // 0-based character position in the line
    Len: Integer;     // Number of characters
  end;

  // -------------------------------------------------------------------------
  // Color scheme for syntax highlighting
  // -------------------------------------------------------------------------
  TSyntaxColors = record
    Background:  TAlphaColor;
    Default:     TAlphaColor;  // Regular/plain text
    Keyword:     TAlphaColor;  // Keywords (bold)
    StringLit:   TAlphaColor;  // String literals
    Number:      TAlphaColor;  // Numbers
    Comment:     TAlphaColor;  // Comments (italic)
    FuncCall:    TAlphaColor;  // Function calls
    Operator:    TAlphaColor;  // Operators
    LineNum:     TAlphaColor;  // Line numbers in listings
    LabelColor:  TAlphaColor;  // Labels
    Directive:   TAlphaColor;  // DATA, RESTORE
  end;

  // Forward declaration
  TBasicConsole = class;

  // -------------------------------------------------------------------------
  // TConsoleContent - Internal painting surface
  // -------------------------------------------------------------------------
  TConsoleContent = class(TControl)
  private
    FOwner: TBasicConsole;
    FLayout: TTextLayout;
    FTokenFont: TFont;  // Reusable font for token attributes (avoids TFont leak)
    procedure RenderPlainLine(const LineText: string; Y: Single);
    procedure RenderCodeLine(const LineText: string; Y: Single);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  // -------------------------------------------------------------------------
  // TBasicConsole - Drop-in replacement for Console TMemo
  //
  // Usage in UnitMain:
  //   FConsole := TBasicConsole.Create(Self);
  //   FConsole.Parent := RectConsoleBackground;
  //   FConsole.Align := TAlignLayout.Client;
  //
  //   // All libraries receive FConsole.Lines (TStrings):
  //   FormLib.RegisterFormFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  //   FBasic.ExecuteProgram(FConsole.Lines);
  //
  //   // Normal output:
  //   FConsole.AddLine('Ready.');
  //
  //   // LIST output (syntax highlighted):
  //   FConsole.AddCodeLine('10 PRINT "Hello"');
  //
  //   // CLS:
  //   FConsole.ClearLines;
  // -------------------------------------------------------------------------
  TBasicConsole = class(TScrollBox)
  private
    FContent: TConsoleContent;
    FBackground: TRectangle;

    // --- Line storage ---
    FLines: TStringList;           // Canonical storage, exposed via Lines
    FIsCodeLine: TList<Boolean>;   // Parallel flag: True = highlighted
    FAddingCodeLine: Boolean;      // Flag checked by OnChange handler

    // --- Appearance ---
    FColors: TSyntaxColors;
    FFontFamily: string;
    FFontSize: Single;
    FLineHeight: Single;
    FCharWidth: Single;            // Monospace character width (for H-scroll calc)
    FMaxCharCount: Integer;        // Longest line character count
    FPaddingLeft: Single;
    FPaddingTop: Single;
    FAutoScroll: Boolean;

    // --- Keyword lookup ---
    FKeywords: TDictionary<string, Boolean>;
    FDirectives: TDictionary<string, Boolean>;

    procedure InitKeywordDicts;
    procedure CalculateLineHeight;
    procedure HandleLinesChange(Sender: TObject);
    procedure RecalcContentSize;
    procedure DoAutoScroll;
    procedure UpdateMaxCharCount;
    function IsKeyword(const Word: string): Boolean;
    function IsDirective(const Word: string): Boolean;
  protected
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // === Console Output API ===

    /// <summary>Add a plain text line (PRINT output, errors, Ready., etc.)</summary>
    procedure AddLine(const Text: string);
    /// <summary>Append text to the current (last) line without line break</summary>
    procedure AppendToLastLine(const Text: string);
    /// <summary>Add a syntax-highlighted line (LIST output)</summary>
    procedure AddCodeLine(const Text: string);
    /// <summary>Add multiple syntax-highlighted lines at once (batch)</summary>
    procedure AddCodeLines(const CodeLines: TArray<string>);
    /// <summary>Clear all console content</summary>
    procedure ClearLines();
    /// <summary>Scroll to the bottom of the console</summary>
    procedure GoToTextEnd();
    /// <summary>Return all console lines as a single string (for clipboard/save)</summary>
    function GetAllText(): string;
    // === Tokenizer (for LIST output) ===
    /// <summary>Tokenize a source code line into colored tokens</summary>
    procedure TokenizeLine(const Line: string; Tokens: TList<TSyntaxToken>);
    /// <summary>Get the TAlphaColor for a given token kind</summary>
    function GetColorForToken(Kind: TSyntaxTokenKind): TAlphaColor;
    // === Configuration ===
    /// <summary>Set the monospaced font family and size</summary>
    procedure SetFontFamily(const Family: string; Size: Single);
    /// <summary>Apply background color from Colors record</summary>
    procedure UpdateBackground();

    // === Properties ===

    /// <summary>
    /// The canonical line storage. Pass this to ExecuteProgram() and
    /// all RegisterXxxFuncs() calls. External writes (by the engine)
    /// automatically trigger repaint and auto-scroll.
    /// </summary>
    property Lines: TStringList read FLines;
    /// <summary>Syntax color scheme (set per theme, then call UpdateBackground)</summary>
    property Colors: TSyntaxColors read FColors write FColors;
    /// <summary>Current font family name</summary>
    property FontFamily: string read FFontFamily;
    /// <summary>Current font size in points</summary>
    property FontSize: Single read FFontSize;
    /// <summary>Calculated line height in pixels</summary>
    property LineHeight: Single read FLineHeight;
    /// <summary>Left padding for text rendering</summary>
    property PaddingLeft: Single read FPaddingLeft write FPaddingLeft;
    /// <summary>Top padding for text rendering</summary>
    property PaddingTop: Single read FPaddingTop write FPaddingTop;
    /// <summary>Auto-scroll to bottom on new content (default: True)</summary>
    property AutoScroll: Boolean read FAutoScroll write FAutoScroll;
  end;

implementation

// =============================================================================
// Plan9Basic Keywords and Directives
// =============================================================================

const
  PLAN9_KEYWORDS: array[0..46] of string = (
    'IF', 'THEN', 'ELSE', 'ENDIF', 'END',
    'FOR', 'TO', 'STEP', 'NEXT', 'ENDFOR',
    'WHILE', 'ENDWHILE', 'WEND',
    'DO', 'LOOP', 'UNTIL',
    'REPEAT',
    'SELECT', 'CASE', 'ENDSELECT',
    'FUNCTION', 'ENDFUNCTION', 'RETURN', 'LOCAL',
    'GOTO', 'GOSUB', 'CALL', 'ON',
    'LET', 'PRINT', 'PRINTLN', 'INPUT',
    'AND', 'OR', 'NOT', 'MOD',
    'TRUE', 'FALSE',
    'CLS',
    'BREAK', 'CONTINUE',
    'DIM', 'REM',
    'ASSERT', 'BREAKPOINT',
    'DUMP', 'WATCH'
  );

  PLAN9_DIRECTIVES: array[0..7] of string = (
    'DATA', 'READ', 'RESTORE',
    'TRACE', 'TRACEON', 'TRACEOFF',
    'REFRESHRATE', 'UNWATCH'
  );

// =============================================================================
// Inline helper functions
// =============================================================================

function IsAlphaChar(C: Char): Boolean; inline;
begin
  Result := ((C >= 'A') and (C <= 'Z')) or ((C >= 'a') and (C <= 'z')) or (C = '_');
end;

function IsDigitChar(C: Char): Boolean; inline;
begin
  Result := (C >= '0') and (C <= '9');
end;

function IsIdentChar(C: Char): Boolean; inline;
begin
  Result := ((C >= 'A') and (C <= 'Z')) or ((C >= 'a') and (C <= 'z')) or
            ((C >= '0') and (C <= '9')) or
            (C = '_') or (C = '$') or (C = '#') or (C = ':');
end;

function IsOperatorChar(C: Char): Boolean; inline;
begin
  Result := CharInSet(C, ['+', '-', '*', '/', '=', '<', '>', '(', ')',
    '[', ']', '{', '}', ',', ';', '^', '&', '|', '@', '?', '%', '!']);
end;

// =============================================================================
// TConsoleContent
// =============================================================================

constructor TConsoleContent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // TTextLayoutManager selects the native text engine:
  //   Windows: DirectWrite
  //   macOS/iOS: CoreText
  //   Android: platform renderer
  FLayout := TTextLayoutManager.DefaultTextLayout.Create;

  // Reusable font for token attributes.
  // TTextAttribute copies font properties — it does NOT take ownership.
  // Creating a new TFont per token causes massive leaks (329K+ objects).
  FTokenFont := TFont.Create;
end;

destructor TConsoleContent.Destroy;
begin
  FTokenFont.Free;
  FLayout.Free;
  inherited;
end;

procedure TConsoleContent.RenderPlainLine(const LineText: string; Y: Single);
begin
  // Simple rendering: entire line in default color, no tokenization
  FLayout.BeginUpdate;
  try
    FLayout.Text := LineText;
    FLayout.ClearAttributes;
    FLayout.Font.Family := FOwner.FontFamily;
    FLayout.Font.Size := FOwner.FontSize;
    FLayout.Font.Style := [];
    FLayout.Color := FOwner.Colors.Default;
    FLayout.TopLeft := PointF(FOwner.PaddingLeft, Y);
    // Use full content width so long lines are not clipped
    FLayout.MaxSize := PointF(Width - FOwner.PaddingLeft, FOwner.LineHeight + 4);
    FLayout.WordWrap := False;
  finally
    FLayout.EndUpdate;
  end;
  FLayout.RenderLayout(Canvas);
end;

procedure TConsoleContent.RenderCodeLine(const LineText: string; Y: Single);
var
  Tokens: TList<TSyntaxToken>;
  Token: TSyntaxToken;
  Range: TTextRange;
  Attr: TTextAttribute;
  AttrRange: TTextAttributedRange;
begin
  Tokens := TList<TSyntaxToken>.Create;
  try
    // Tokenize for syntax coloring
    FOwner.TokenizeLine(LineText, Tokens);

    // === TTextLayout rendering (from tutorial) ===
    // BeginUpdate batches all attribute changes -> no flicker
    FLayout.BeginUpdate;
    try
      FLayout.Text := LineText;
      FLayout.ClearAttributes;  // Frees previous round's objects
      FLayout.Font.Family := FOwner.FontFamily;
      FLayout.Font.Size := FOwner.FontSize;
      FLayout.Font.Style := [];
      FLayout.Color := FOwner.Colors.Default;  // Base color for unattributed text
      FLayout.TopLeft := PointF(FOwner.PaddingLeft, Y);
      // Use full content width so long lines are not clipped
      FLayout.MaxSize := PointF(Width - FOwner.PaddingLeft, FOwner.LineHeight + 4);
      FLayout.WordWrap := False;

      // Apply colored attributes for each non-default token
      for Token in Tokens do
      begin
        if Token.Kind = stkDefault then
          Continue;

        Range.Pos := Token.Start;
        Range.Length := Token.Len;

        // Configure the reusable font for this token.
        // TTextAttribute copies font properties — it does NOT take ownership
        // of the TFont. Using a single reusable TFont avoids massive leaks.
        FTokenFont.Family := FOwner.FontFamily;
        FTokenFont.Size := FOwner.FontSize;
        FTokenFont.Style := [];

        case Token.Kind of
          stkKeyword:   FTokenFont.Style := [TFontStyle.fsBold];
          stkComment:   FTokenFont.Style := [TFontStyle.fsItalic];
          stkDirective: FTokenFont.Style := [TFontStyle.fsBold];
        end;

        Attr := TTextAttribute.Create(FTokenFont, FOwner.GetColorForToken(Token.Kind));
        AttrRange := TTextAttributedRange.Create(Range, Attr);
        FLayout.AddAttribute(AttrRange);
      end;
    finally
      FLayout.EndUpdate;
    end;

    FLayout.RenderLayout(Canvas);
  finally
    Tokens.Free;
  end;
end;

procedure TConsoleContent.Paint;
var
  I: Integer;
  Y: Single;
  VisibleTop, VisibleBottom: Single;
  FirstLine, LastLine: Integer;
begin
  inherited;

  if (FOwner = nil) or (FOwner.FLines.Count = 0) then
    Exit;

  // --- Optimization: only render lines visible in the viewport ---
  VisibleTop := FOwner.ViewportPosition.Y;
  VisibleBottom := VisibleTop + FOwner.Height;

  FirstLine := Trunc((VisibleTop - FOwner.PaddingTop) / FOwner.LineHeight);
  if FirstLine < 0 then
    FirstLine := 0;

  LastLine := Trunc((VisibleBottom - FOwner.PaddingTop) / FOwner.LineHeight) + 1;
  if LastLine >= FOwner.FLines.Count then
    LastLine := FOwner.FLines.Count - 1;

  // Render each visible line
  for I := FirstLine to LastLine do
  begin
    Y := FOwner.PaddingTop + (I * FOwner.LineHeight);

    // Check parallel flag: code line -> syntax highlight, plain -> default
    if (I < FOwner.FIsCodeLine.Count) and FOwner.FIsCodeLine[I] then
      RenderCodeLine(FOwner.FLines[I], Y)
    else
      RenderPlainLine(FOwner.FLines[I], Y);
  end;
end;

// =============================================================================
// TBasicConsole
// =============================================================================

constructor TBasicConsole.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  // --- Line storage ---
  FLines := TStringList.Create;
  FLines.OnChange := HandleLinesChange;
  FIsCodeLine := TList<Boolean>.Create;
  FAddingCodeLine := False;

  // --- Keyword dictionaries ---
  FKeywords := TDictionary<string, Boolean>.Create;
  FDirectives := TDictionary<string, Boolean>.Create;
  InitKeywordDicts;

  // --- Default appearance ---
  FFontFamily := 'Consolas';
  FFontSize := 14;
  FLineHeight := 20;
  FCharWidth := 8;
  FMaxCharCount := 0;
  FPaddingLeft := 8;
  FPaddingTop := 6;
  FAutoScroll := True;

  // Default colors (GREEN theme — matches Plan9Basic website neon palette)
  //   --terminal-bg:    #0c1a0c
  //   --terminal-green: #33ff33
  //   --neon-green:     #39ff14
  //   --neon-pink:      #ff6ec7
  //   --neon-purple:    #bc13fe
  FColors.Background  := $FF0C1A0C;   // terminal-bg
  FColors.Default     := $FF33FF33;   // terminal-green (plain text)
  FColors.Keyword     := $FFFF6EC7;   // neon-pink (bold)
  FColors.StringLit   := $FF39FF14;   // neon-green (brighter than default)
  FColors.Number      := $FFBC13FE;   // neon-purple
  FColors.Comment     := $FF2A6A2A;   // muted dark green
  FColors.FuncCall    := $FFFFBD2E;   // warm gold (from site dot-yellow)
  FColors.Operator    := $FFE0E0E0;   // text-primary (clean white)
  FColors.LineNum     := $FF3A7A3A;   // subdued green
  FColors.LabelColor  := $FFBC13FE;   // neon-purple
  FColors.Directive   := $FFFF5F56;   // warm red (from site dot-red)

  // --- Visual structure ---
  // Background rectangle — manually sized to match FContent
  // (Align=Client would only cover the viewport, leaving scrolled areas empty)
  FBackground := TRectangle.Create(Self);
  FBackground.Parent := Self;
  FBackground.Align := TAlignLayout.None;
  FBackground.Position.X := 0;
  FBackground.Position.Y := 0;
  FBackground.Fill.Color := FColors.Background;
  FBackground.Stroke.Kind := TBrushKind.None;
  FBackground.HitTest := False;

  // Content painting surface
  FContent := TConsoleContent.Create(Self);
  FContent.FOwner := Self;
  FContent.Parent := Self;
  FContent.Align := TAlignLayout.None;
  FContent.Position.X := 0;
  FContent.Position.Y := 0;
  FContent.HitTest := False;

  // Scroll configuration
  ShowScrollBars := True;

  CalculateLineHeight;
end;

destructor TBasicConsole.Destroy;
begin
  FLines.OnChange := nil;  // Prevent events during teardown
  FLines.Free;
  FIsCodeLine.Free;
  FKeywords.Free;
  FDirectives.Free;
  inherited;
end;

// =============================================================================
// Keyword Dictionaries
// =============================================================================

procedure TBasicConsole.InitKeywordDicts;
var
  K: string;
begin
  for K in PLAN9_KEYWORDS do
    FKeywords.AddOrSetValue(K, True);
  for K in PLAN9_DIRECTIVES do
    FDirectives.AddOrSetValue(K, True);
end;

function TBasicConsole.IsKeyword(const Word: string): Boolean;
begin
  Result := FKeywords.ContainsKey(UpperCase(Word));
end;

function TBasicConsole.IsDirective(const Word: string): Boolean;
begin
  Result := FDirectives.ContainsKey(UpperCase(Word));
end;

// =============================================================================
// Line Height Calculation
// =============================================================================

procedure TBasicConsole.CalculateLineHeight;
var
  TempLayout: TTextLayout;
begin
  TempLayout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    TempLayout.BeginUpdate;
    TempLayout.Font.Family := FFontFamily;
    TempLayout.Font.Size := FFontSize;
    TempLayout.Text := 'Wg|q';  // Ascenders + descenders for accurate height
    TempLayout.MaxSize := PointF(500, 100);
    TempLayout.WordWrap := False;
    TempLayout.EndUpdate;

    FLineHeight := TempLayout.TextHeight + 3;
    if FLineHeight < 12 then
      FLineHeight := FFontSize + 6;

    // Measure monospace character width using a 10-char sample for accuracy
    TempLayout.BeginUpdate;
    TempLayout.Text := 'MMMMMMMMMM';  // 10 wide chars
    TempLayout.MaxSize := PointF(10000, 100);
    TempLayout.EndUpdate;

    FCharWidth := TempLayout.TextWidth / 10;
    if FCharWidth < 1 then
      FCharWidth := FFontSize * 0.6;
  finally
    TempLayout.Free;
  end;
end;

// =============================================================================
// Internal Event Handler
// =============================================================================

procedure TBasicConsole.HandleLinesChange(Sender: TObject);
begin
  // Reconcile the parallel metadata list with actual line count.
  // New lines get FAddingCodeLine as their flag:
  //   - False when added externally (by engine, PrintProc, etc.)
  //   - True when added via AddCodeLine()
  while FIsCodeLine.Count < FLines.Count do
    FIsCodeLine.Add(FAddingCodeLine);

  // Handle line deletions
  while FIsCodeLine.Count > FLines.Count do
    FIsCodeLine.Delete(FIsCodeLine.Count - 1);

  // Track longest line for horizontal scrolling
  UpdateMaxCharCount;

  RecalcContentSize;
  FContent.Repaint;

  if FAutoScroll then
    DoAutoScroll;
end;

procedure TBasicConsole.RecalcContentSize;
var
  TotalHeight, TotalWidth: Single;
begin
  TotalHeight := FPaddingTop + (FLines.Count * FLineHeight) + FPaddingTop;
  if TotalHeight < Self.Height then
    TotalHeight := Self.Height;

  // Content width: max of viewport and the widest line + padding
  TotalWidth := FPaddingLeft + (FMaxCharCount * FCharWidth) + FPaddingLeft;
  if TotalWidth < Self.Width then
    TotalWidth := Self.Width;

  FContent.Width := TotalWidth;
  FContent.Height := TotalHeight;

  // Background must cover the full content area (not just viewport)
  FBackground.Width := TotalWidth;
  FBackground.Height := TotalHeight;
  FBackground.SendToBack;
end;

procedure TBasicConsole.DoAutoScroll;
var
  MaxScrollY: Single;
begin
  MaxScrollY := FContent.Height - Self.Height;
  if MaxScrollY < 0 then
    MaxScrollY := 0;
  // Scroll to bottom, keep horizontal position
  ViewportPosition := PointF(ViewportPosition.X, MaxScrollY);
end;

procedure TBasicConsole.UpdateMaxCharCount;
var
  I, Len: Integer;
begin
  // Incrementally track the longest line.
  // On clear, FLines.Count = 0 so FMaxCharCount resets.
  if FLines.Count = 0 then
  begin
    FMaxCharCount := 0;
    Exit;
  end;

  for I := 0 to FLines.Count - 1 do
  begin
    Len := Length(FLines[I]);
    if Len > FMaxCharCount then
      FMaxCharCount := Len;
  end;
end;

procedure TBasicConsole.Resize;
begin
  inherited;
  // Recalculate on viewport size change (rotation, window resize)
  RecalcContentSize;
  FContent.Repaint;
end;

// =============================================================================
// Console Output API
// =============================================================================

procedure TBasicConsole.AddLine(const Text: string);
begin
  // FAddingCodeLine is False by default -> OnChange adds False flag
  FLines.Add(Text);
end;

procedure TBasicConsole.AppendToLastLine(const Text: string);
begin
  if FLines.Count = 0 then
    AddLine(Text)
  else
    // Modifying existing line: OnChange fires but count unchanged,
    // so FIsCodeLine stays in sync (no new entries added)
    FLines[FLines.Count - 1] := FLines[FLines.Count - 1] + Text;
end;

procedure TBasicConsole.AddCodeLine(const Text: string);
begin
  FAddingCodeLine := True;
  try
    FLines.Add(Text);  // OnChange fires -> adds True to FIsCodeLine
  finally
    FAddingCodeLine := False;
  end;
end;

procedure TBasicConsole.AddCodeLines(const CodeLines: TArray<string>);
var
  S: string;
begin
  FAddingCodeLine := True;
  try
    FLines.BeginUpdate;
    try
      for S in CodeLines do
        FLines.Add(S);
    finally
      FLines.EndUpdate;  // Single OnChange at the end
    end;
  finally
    FAddingCodeLine := False;
  end;
end;

procedure TBasicConsole.ClearLines();
begin
  FLines.Clear;  // OnChange fires -> FIsCodeLine reconciled to 0
end;

procedure TBasicConsole.GoToTextEnd();
begin
  DoAutoScroll;
end;

function TBasicConsole.GetAllText(): string;
begin
  Result := FLines.Text;
end;

// =============================================================================
// Configuration
// =============================================================================

procedure TBasicConsole.SetFontFamily(const Family: string; Size: Single);
begin
  FFontFamily := Family;
  FFontSize := Size;
  CalculateLineHeight;
  RecalcContentSize;
  FContent.Repaint;
end;

procedure TBasicConsole.UpdateBackground();
begin
  if Assigned(FBackground) then
    FBackground.Fill.Color := FColors.Background;
end;

function TBasicConsole.GetColorForToken(Kind: TSyntaxTokenKind): TAlphaColor;
begin
  case Kind of
    stkKeyword: Result := FColors.Keyword;
    stkString: Result := FColors.StringLit;
    stkNumber: Result := FColors.Number;
    stkComment: Result := FColors.Comment;
    stkFunction: Result := FColors.FuncCall;
    stkOperator: Result := FColors.Operator;
    stkLineNumber: Result := FColors.LineNum;
    stkLabel: Result := FColors.LabelColor;
    stkDirective: Result := FColors.Directive;
  else
    Result := FColors.Default;
  end;
end;

// =============================================================================
// Lightweight Tokenizer for Syntax Highlighting
// =============================================================================
//
// Applied ONLY to lines flagged as code (LIST output).
// Identifies: line numbers, keywords, strings, numbers, comments,
// function calls, labels, directives, operators.
// =============================================================================

procedure TBasicConsole.TokenizeLine(const Line: string; Tokens: TList<TSyntaxToken>);
var
  I, Len, Start: Integer;
  Ch: Char;
  Word, BaseWord: string;
  J: Integer;

  function PeekChar(Pos: Integer): Char;
  begin
    if (Pos >= 1) and (Pos <= Len) then
      Result := Line[Pos]
    else
      Result := #0;
  end;

  procedure AddToken(AKind: TSyntaxTokenKind; AStart, ALen: Integer);
  var
    T: TSyntaxToken;
  begin
    T.Kind := AKind;
    T.Start := AStart;   // 0-based for TTextRange
    T.Len := ALen;
    Tokens.Add(T);
  end;

begin
  Len := Length(Line);
  if Len = 0 then
    Exit;

  I := 1;

  // --- Phase 1: Check for line number at the start ---
  while (I <= Len) and (Line[I] = ' ') do
    Inc(I);

  if (I <= Len) and IsDigitChar(Line[I]) then
  begin
    Start := I;
    while (I <= Len) and IsDigitChar(Line[I]) do
      Inc(I);
    if (I > Len) or (Line[I] = ' ') then
      AddToken(stkLineNumber, Start - 1, I - Start)
    else
      I := Start;  // Not a line number, reset
  end;

  // --- Phase 2: Tokenize remaining content ---
  while I <= Len do
  begin
    Ch := Line[I];

    // Skip spaces
    if Ch = ' ' then
    begin
      Inc(I);
      Continue;
    end;

    // ---- Comment: apostrophe -> rest of line ----
    if Ch = '''' then
    begin
      AddToken(stkComment, I - 1, Len - I + 1);
      Break;
    end;

    // ---- String literal: "..." ----
    if Ch = '"' then
    begin
      Start := I;
      Inc(I);
      while I <= Len do
      begin
        if (Line[I] = '\') and (I + 1 <= Len) then
        begin
          Inc(I, 2);
          Continue;
        end;
        if Line[I] = '"' then
        begin
          Inc(I);
          Break;
        end;
        if CharInSet(Line[I], [#10, #13]) then
          Break;
        Inc(I);
      end;
      AddToken(stkString, Start - 1, I - Start);
      Continue;
    end;

    // ---- Number ----
    if IsDigitChar(Ch) or ((Ch = '.') and (I + 1 <= Len) and IsDigitChar(PeekChar(I + 1))) then
    begin
      Start := I;
      while (I <= Len) and IsDigitChar(Line[I]) do
        Inc(I);
      if (I <= Len) and (Line[I] = '.') then
      begin
        Inc(I);
        while (I <= Len) and IsDigitChar(Line[I]) do
          Inc(I);
      end;
      if (I <= Len) and CharInSet(Line[I], ['e', 'E']) then
      begin
        Inc(I);
        if (I <= Len) and CharInSet(Line[I], ['+', '-']) then
          Inc(I);
        while (I <= Len) and IsDigitChar(Line[I]) do
          Inc(I);
      end;
      AddToken(stkNumber, Start - 1, I - Start);
      Continue;
    end;

    // ---- Identifier / Keyword / Function / Label ----
    if IsAlphaChar(Ch) then
    begin
      Start := I;
      Inc(I);
      while (I <= Len) and IsIdentChar(Line[I]) do
        Inc(I);

      Word := Copy(Line, Start, I - Start);

      // Label (ends with ':')
      if (Length(Word) > 1) and (Word[Length(Word)] = ':') then
      begin
        AddToken(stkLabel, Start - 1, I - Start);
        Continue;
      end;

      // REM keyword -> rest of line is comment
      if UpperCase(Word) = 'REM' then
      begin
        AddToken(stkComment, Start - 1, Len - Start + 1);
        Break;
      end;

      // Strip type suffix ($, #) for keyword lookup
      BaseWord := Word;
      if (Length(BaseWord) > 0) and CharInSet(BaseWord[Length(BaseWord)], ['$', '#']) then
        BaseWord := Copy(BaseWord, 1, Length(BaseWord) - 1);

      // Check for function call: identifier followed by '('
      J := I;
      while (J <= Len) and (Line[J] = ' ') do
        Inc(J);
      if (J <= Len) and (Line[J] = '(') and
         (not IsKeyword(BaseWord)) and (not IsDirective(BaseWord)) then
      begin
        AddToken(stkFunction, Start - 1, I - Start);
        Continue;
      end;

      // Classify the word
      if IsKeyword(BaseWord) then
        AddToken(stkKeyword, Start - 1, I - Start)
      else if IsDirective(BaseWord) then
        AddToken(stkDirective, Start - 1, I - Start)
      else
        AddToken(stkDefault, Start - 1, I - Start);

      Continue;
    end;

    // ---- Operators ----
    if IsOperatorChar(Ch) then
    begin
      Start := I;
      if (Ch = '<') and (PeekChar(I + 1) = '=') then
        Inc(I, 2)
      else if (Ch = '<') and (PeekChar(I + 1) = '>') then
        Inc(I, 2)
      else if (Ch = '>') and (PeekChar(I + 1) = '=') then
        Inc(I, 2)
      else if (Ch = '?') and CharInSet(PeekChar(I + 1), ['>', '<']) then
        Inc(I, 2)
      else if (Ch = '&') and CharInSet(PeekChar(I + 1), ['$', '#']) then
        Inc(I, 2)
      else
        Inc(I);

      AddToken(stkOperator, Start - 1, I - Start);
      Continue;
    end;

    // Skip anything else
    Inc(I);
  end;
end;

end.
