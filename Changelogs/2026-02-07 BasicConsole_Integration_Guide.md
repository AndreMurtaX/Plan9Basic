# BasicConsole Integration Guide

## What Changed vs. the Previous Solution

The first version used a **dual-component approach** (hide Console TMemo, show TSyntaxListView).
This new version uses a **single component** (`TBasicConsole`) that **replaces** the Console TMemo entirely.

| Aspect | Old approach | New approach |
|--------|-------------|--------------|
| Architecture | TMemo + TSyntaxListView (toggle) | Single TBasicConsole |
| Plain text | TMemo handles it | TBasicConsole renders plain via TTextLayout |
| LIST output | TSyntaxListView handles it | Same component, per-line flag triggers highlighting |
| Engine compat | N/A (still used TMemo) | `FConsole.Lines` (TStringList) passed to all libs |
| Toggling | ShowSyntaxView / HideSyntaxView | Not needed — single component |

## How Non-Code Output Works

Each line in the console has a parallel Boolean flag (`FIsCodeLine`):

```
FLines[0] = "Plan9 BASIC v1.0"          FIsCodeLine[0] = False  → plain
FLines[1] = "Type HELP for commands."    FIsCodeLine[1] = False  → plain
FLines[2] = ""                           FIsCodeLine[2] = False  → plain
FLines[3] = "Ready."                     FIsCodeLine[3] = False  → plain
FLines[4] = "> LIST"                     FIsCodeLine[4] = False  → plain
FLines[5] = "10 PRINT "Hello""           FIsCodeLine[5] = True   → HIGHLIGHTED
FLines[6] = "20 FOR i = 1 TO 10"         FIsCodeLine[6] = True   → HIGHLIGHTED
FLines[7] = "30   PRINT i"              FIsCodeLine[7] = True   → HIGHLIGHTED
FLines[8] = "40 NEXT"                    FIsCodeLine[8] = True   → HIGHLIGHTED
FLines[9] = "Ready."                     FIsCodeLine[9] = False  → plain
```

- `AddLine("text")` → flag = False (plain)
- `AddCodeLine("text")` → flag = True (highlighted)
- External writes via `Lines.Add(...)` (from engine/libs) → flag = False (plain)

---

## Step-by-Step Integration

### Step 1: Add files to the project

Add `BasicConsole.pas` to your project and to `Plan9Basic.dpr`:

```pascal
BasicConsole in 'BasicConsole.pas',
```

### Step 2: UnitMain.pas — Add to uses clause

In the **implementation** uses clause (around line 185):

```pascal
  MediaPlayerLib, SQLiteLib, IOUtilsLib,
  BasicConsole;  // ← ADD
```

### Step 3: UnitMain.pas — Add FConsole field

In the `private` section of `TfrmMain`, add:

```pascal
  FCurrentTheme: TColorTheme;
  FThemes: array[TColorTheme] of TThemeColors;
  FConsole: TBasicConsole;                        // ← ADD
```

### Step 4: UnitMain.pas — Add helper method declarations

In the `private` section:

```pascal
  // Console management
  procedure CreateConsole;
  function GetSyntaxColors(Theme: TColorTheme): TSyntaxColors;
```

### Step 5: Implement CreateConsole

```pascal
procedure TfrmMain.CreateConsole;
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
```

### Step 6: Implement GetSyntaxColors

```pascal
function TfrmMain.GetSyntaxColors(Theme: TColorTheme): TSyntaxColors;
var
  T: TThemeColors;
begin
  T := FThemes[Theme];

  // Background and default text match the theme
  Result.Background := T.Background;
  Result.Default    := T.MemoForeground;

  // Syntax colors derived from the Plan9Basic website neon palette:
  //   --neon-green:  #39ff14      --neon-pink:   #ff6ec7
  //   --neon-purple: #bc13fe      --terminal-green: #33ff33
  //   dot-yellow:    #ffbd2e      dot-red:       #ff5f56
  //   --text-primary: #e0e0e0

  case Theme of
    ctGreen:
    begin
      // Faithful to the website's terminal aesthetic
      Result.Background := $FF0C1A0C;   // --terminal-bg
      Result.Default    := $FF33FF33;   // --terminal-green
      Result.Keyword    := $FFFF6EC7;   // neon-pink (bold)
      Result.StringLit  := $FF39FF14;   // neon-green (brighter)
      Result.Number     := $FFBC13FE;   // neon-purple
      Result.Comment    := $FF2A6A2A;   // muted dark green
      Result.FuncCall   := $FFFFBD2E;   // warm gold
      Result.Operator   := $FFE0E0E0;   // text-primary
      Result.LineNum    := $FF3A7A3A;   // subdued green
      Result.LabelColor := $FFBC13FE;   // neon-purple
      Result.Directive  := $FFFF5F56;   // warm red
    end;

    ctAmber:
    begin
      // Neon palette adapted to amber warmth
      Result.Keyword    := $FFFF6EC7;   // neon-pink
      Result.StringLit  := $FF39FF14;   // neon-green
      Result.Number     := $FFBC13FE;   // neon-purple
      Result.Comment    := $FF6A5A20;   // muted amber
      Result.FuncCall   := $FFFFBD2E;   // gold
      Result.Operator   := $FFE0E0E0;   // text-primary
      Result.LineNum    := $FF7A6A30;   // dim amber
      Result.LabelColor := $FFBC13FE;   // neon-purple
      Result.Directive  := $FFFF5F56;   // warm red
    end;

    ctWhite:
    begin
      // Dark-on-light: saturated versions of the neon palette
      Result.Keyword    := $FFCC1177;   // deep pink
      Result.StringLit  := $FF1A8A0A;   // deep green
      Result.Number     := $FF8A0ACE;   // deep purple
      Result.Comment    := $FF888888;   // mid gray
      Result.FuncCall   := $FFCC8800;   // dark gold
      Result.Operator   := $FF555555;   // dark gray
      Result.LineNum    := $FFAAAAAA;   // light gray
      Result.LabelColor := $FF8A0ACE;   // deep purple
      Result.Directive  := $FFCC3322;   // dark red
    end;

    ctBlue:
    begin
      // Neon palette on dark blue canvas
      Result.Keyword    := $FFFF6EC7;   // neon-pink
      Result.StringLit  := $FF39FF14;   // neon-green
      Result.Number     := $FFBC13FE;   // neon-purple
      Result.Comment    := $FF3A5A7A;   // muted steel blue
      Result.FuncCall   := $FFFFBD2E;   // gold
      Result.Operator   := $FFE0E0E0;   // text-primary
      Result.LineNum    := $FF3A5A8A;   // dim blue
      Result.LabelColor := $FFBC13FE;   // neon-purple
      Result.Directive  := $FFFF5F56;   // warm red
    end;

    ctPink:
    begin
      // Neon palette with pink as the base
      Result.Keyword    := $FF39FF14;   // neon-green (inverted: green pops on pink)
      Result.StringLit  := $FFFFBD2E;   // gold
      Result.Number     := $FFBC13FE;   // neon-purple
      Result.Comment    := $FF7A4A5A;   // muted mauve
      Result.FuncCall   := $FF33CCFF;   // bright cyan
      Result.Operator   := $FFE0E0E0;   // text-primary
      Result.LineNum    := $FF8A5A6A;   // dim pink
      Result.LabelColor := $FFBC13FE;   // neon-purple
      Result.Directive  := $FFFF5F56;   // warm red
    end;
  end;
end;
```

### Step 7: FormCreate — Create the console and hide the TMemo

In `FormCreate`, **before** the welcome messages, add:

```pascal
  // Apply initial theme
  ApplyTheme(FCurrentTheme);

  // Set initial mode
  SetInterfaceMode(imCommand);

  // Create the rich console (replaces Console TMemo)     ← ADD
  CreateConsole;                                          // ← ADD

  // Hide the original TMemo Console                      ← ADD
  Console.Visible := False;                               // ← ADD

  // Welcome message
  PrintLn('Plan9 BASIC v' + VERSION);
```

> **Note:** We keep the Console TMemo in the .fmx form but hide it.
> This avoids editing the .fmx file. If you prefer, you can remove
> Console from the form entirely and delete all old Console references.

### Step 8: Replace Print and PrintLn

Replace the existing `Print` and `PrintLn` methods:

```pascal
procedure TfrmMain.Print(const Text: string);
begin
  FConsole.AppendToLastLine(Text);
end;

procedure TfrmMain.PrintLn(const Text: string);
begin
  FConsole.AddLine(Text);
end;
```

### Step 9: Replace CmdCls

```pascal
procedure TfrmMain.CmdCls();
begin
  FConsole.ClearLines;
end;
```

### Step 10: Replace CmdList

Replace the entire method:

```pascal
procedure TfrmMain.CmdList(const Args: string);
var
  I, StartLine, EndLine: Integer;
  Line: TProgramLine;
  DashPos: Integer;
  StartStr, EndStr: string;
  ListCount: Integer;
begin
  if FInterfaceMode = imEditor then
    SyncProgramToEditor();

  if FProgram.Count = 0 then
  begin
    PrintLn('No program in memory.');
    PrintReady();
    Exit();
  end;

  StartLine := 0;
  EndLine := MaxInt;

  if Args.Trim <> '' then
  begin
    DashPos := Pos('-', Args);
    if DashPos > 0 then
    begin
      StartStr := Copy(Args, 1, DashPos - 1).Trim;
      EndStr := Copy(Args, DashPos + 1, Length(Args)).Trim;

      if StartStr <> '' then
        TryStrToInt(StartStr, StartLine);
      if EndStr <> '' then
        TryStrToInt(EndStr, EndLine);
    end
    else
    begin
      if TryStrToInt(Args.Trim, StartLine) then
        EndLine := StartLine;
    end;
  end;

  SortProgram();

  // Output each line as a CODE line (syntax highlighted)
  ListCount := 0;
  for I := 0 to FProgram.Count - 1 do
  begin
    Line := FProgram[I];
    if (Line.LineNumber >= StartLine) and (Line.LineNumber <= EndLine) then
    begin
      FConsole.AddCodeLine(IntToStr(Line.LineNumber) + ' ' + Line.Text);
      Inc(ListCount);
    end;
  end;

  if ListCount = 0 then
    PrintLn('No lines in range.');

  PrintReady();
end;
```

### Step 11: Update HandlePrintOutput

```pascal
procedure TfrmMain.HandlePrintOutput(Sender: TObject; const Text: string; IsClear: Boolean);
begin
  // Text was already added to FConsole.Lines by PrintProc
  // Just update UI
  FConsole.GoToTextEnd;
  Application.ProcessMessages;
end;
```

### Step 12: Update CmdRun

Change `Console.Lines` to `FConsole.Lines`:

```pascal
    FBasic.ExecuteProgram(FConsole.Lines);
```

### Step 13: Update InitBASICEngine

Replace ALL occurrences of `Console.Lines` with `FConsole.Lines`.

This affects ~60+ lines. A simple find-and-replace works:

**Find:** `Console.Lines`
**Replace:** `FConsole.Lines`

The affected calls look like:
```pascal
  StrListLib.RegisterStringsFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  HttpLib.RegisterHttpFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  FormLib.RegisterFormFuncs(FBasic.Functions, FBasic, FConsole.Lines);
  // ... all other RegisterXxxFuncs calls ...
```

### Step 14: Simplify ApplyTheme

Remove all the TMemo-specific styling for the Console. Replace with:

```pascal
  // Update the rich console
  if Assigned(FConsole) then
  begin
    FConsole.Colors := GetSyntaxColors(Theme);
    FConsole.UpdateBackground;
  end;
```

You can **remove** these lines from ApplyTheme (they styled the old Console TMemo):
```pascal
  // REMOVE these:
  Console.StyleLookup := 'transparentedit';
  Console.StyledSettings := [];
  Console.TextSettings.FontColor := T.Foreground;
  Console.TextSettings.FontColor := T.MemoForeground;
  Console.TextSettings.Font.Family := '...';
  MakeMemoTransparent(Console);
```

Keep the Editor and memoLineNumbers styling as-is.

### Step 15: Simplify AdjustForPlatform

Remove the Console-specific lines:
```pascal
  // REMOVE:
  Console.TextSettings.Font.Size := 16;
  Console.ControlType := TControlType.Styled;
```

The font for FConsole is set in `CreateConsole` via `SetFontFamily`.

---

## Complete Change Summary

| Location | What to do |
|----------|-----------|
| `Plan9Basic.dpr` | Add `BasicConsole in 'BasicConsole.pas'` |
| `uses` (impl) | Add `BasicConsole` |
| `TfrmMain` fields | Add `FConsole: TBasicConsole` |
| `TfrmMain` methods | Add `CreateConsole`, `GetSyntaxColors` |
| `FormCreate` | Call `CreateConsole`, hide `Console` |
| `Print` | Use `FConsole.AppendToLastLine` |
| `PrintLn` | Use `FConsole.AddLine` |
| `CmdCls` | Use `FConsole.ClearLines` |
| `CmdList` | Use `FConsole.AddCodeLine` for each line |
| `CmdRun` | Change `Console.Lines` → `FConsole.Lines` |
| `HandlePrintOutput` | Change `Console.GoToTextEnd` → `FConsole.GoToTextEnd` |
| `InitBASICEngine` | Find/replace `Console.Lines` → `FConsole.Lines` (60+ lines) |
| `ApplyTheme` | Remove Console styling, add `FConsole.Colors` update |
| `AdjustForPlatform` | Remove Console-specific lines |

---

## Architecture Diagram

```
┌───────────────────────────────────────────────────────┐
│  UnitMain.pas                                         │
│                                                       │
│  Print("text")  ──→ FConsole.AppendToLastLine("text") │
│  PrintLn("text") ──→ FConsole.AddLine("text")         │
│  CmdList         ──→ FConsole.AddCodeLine(...)        │
│  CmdCls          ──→ FConsole.ClearLines              │
│                                                       │
│  InitBASICEngine:                                     │
│    RegisterXxxFuncs(..., FConsole.Lines)               │
│    ExecuteProgram(FConsole.Lines)                      │
│         │                                             │
│         ▼                                             │
│    PrintProc writes to FConsole.Lines (TStringList)    │
│         │ OnChange event fires                        │
│         ▼                                             │
│    HandleLinesChange:                                 │
│      reconcile FIsCodeLine                            │
│      RecalcContentSize                                │
│      FContent.Repaint                                 │
│      DoAutoScroll                                     │
└───────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────┐
│  TBasicConsole (TVertScrollBox)                       │
│                                                       │
│    FLines: TStringList ◄── Lines property             │
│    FIsCodeLine: TList<Boolean>                        │
│                                                       │
│    ┌─────────────────────────────────────────────┐    │
│    │  TConsoleContent.Paint                      │    │
│    │                                             │    │
│    │  for each visible line:                     │    │
│    │    if FIsCodeLine[i] = False then           │    │
│    │      RenderPlainLine (default color only)   │    │
│    │    else                                     │    │
│    │      RenderCodeLine:                        │    │
│    │        TokenizeLine → tokens                │    │
│    │        TTextLayout.BeginUpdate              │    │
│    │          set text, font, base color         │    │
│    │          for each token:                    │    │
│    │            Font(bold/italic) + Color        │    │
│    │            → TTextAttributedRange           │    │
│    │            → AddAttribute                   │    │
│    │        TTextLayout.EndUpdate                │    │
│    │        TTextLayout.RenderLayout(Canvas)     │    │
│    └─────────────────────────────────────────────┘    │
└───────────────────────────────────────────────────────┘
```

## Notes

### Why keep Console TMemo hidden?
Removing it from the `.fmx` form is cleaner but requires manual form editing.
Hiding it is safer — the TMemo consumes minimal resources when invisible,
and you can remove it from the `.fmx` later at your convenience.

### Thread safety
The BASIC engine runs on the main thread (via `ExecuteProgram`), and
`PrintProc` writes to `FConsole.Lines` synchronously. The `OnChange` handler
runs immediately, updating the visual display. `Application.ProcessMessages()`
in `HandlePrintOutput` ensures the UI refreshes between PRINT statements.

### Performance considerations
- Only visible lines are rendered (viewport culling in `Paint`)
- `BeginUpdate`/`EndUpdate` batches all TTextLayout attribute changes per line
- Plain lines skip tokenization entirely (no overhead for regular output)
- `AddCodeLines()` uses `BeginUpdate`/`EndUpdate` on TStringList for batch LIST

### Future: Editor syntax highlighting
The tokenizer in `TBasicConsole` can be extracted into a separate unit
(e.g., `BasicTokenizer.pas`) and reused by a syntax-highlighted editor
component when you're ready for that phase.
