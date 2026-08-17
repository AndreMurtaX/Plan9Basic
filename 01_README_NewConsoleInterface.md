# Plan9 BASIC - Console Interface

## Overview

A complete redesign of the Plan9 BASIC interface combining the classic BASIC interpreter experience (like GW-BASIC, Commodore 64 BASIC, MSX BASIC) with a modern full-screen editor. The interface features dual modes, multiple color themes, and cross-platform support for desktop and mobile devices.

## Interface Modes

### COMMAND Mode (Classic BASIC Style)
- Line-number based programming like classic interpreters
- Direct command execution
- Command prompt (`>`) for entering commands and program lines
- Command history with Up/Down arrow navigation

### EDITOR Mode (Modern Text Editor)
- Full-screen text editor without line numbers
- Line number gutter on the left side
- Free-form editing like modern IDEs
- Synchronized scrolling between editor and line numbers

**Toggle between modes:** Press `F7` (desktop) or tap the `MODE` button (mobile)

## Visual Themes

Five built-in color themes are available:

| Theme | Description | Desktop | Mobile |
|-------|-------------|---------|--------|
| **GREEN** | Classic terminal (default) | Lime on black | Dark green on white |
| **AMBER** | Vintage monitor | Orange on dark brown | Dark orange on white |
| **WHITE** | High contrast | White on dark gray | Black on white |
| **BLUE** | Cool/modern | Cyan on navy | Dark blue on white |
| **PINK** | Cyberpunk/retro | Hot pink on dark | Dark pink on white |

**Cycle themes:** Press `F8` (desktop) or tap the `THEME` button (mobile), or type `THEME [name]`

## Toolbar Buttons

The toolbar provides touch-friendly access to all main functions:

| Button | Action |
|--------|--------|
| `NEW` | Clear program (with confirmation) |
| `LOAD` | Show files and load a program |
| `SAVE` | Save program (prompts for filename if new) |
| `RUN` | Execute the program |
| `MODE` / `CMD` / `EDITOR` | Toggle between COMMAND and EDITOR modes |
| `THEME` | Cycle through color themes |
| `FILES` | List .bas files in directory |
| `HELP` | Show command reference |

## Function Keys (Desktop)

| Key | Action |
|-----|--------|
| `F1` | Help |
| `F2` | Save |
| `F3` | Load |
| `F5` | Run |
| `F7` | Toggle Mode |
| `F8` | Cycle Theme |
| `F9` | List Files |

## Status Bar

The status bar at the bottom displays:

```
COMMAND │ filename.bas * │ GREEN │ 130 lines
   ↑           ↑            ↑         ↑
 Mode    File (+ modified)  Theme   Line count
```

## Direct Commands

### Program Management

| Command | Description |
|---------|-------------|
| `NEW` | Clear the program from memory |
| `LIST` | List the entire program |
| `LIST n` | List line n only |
| `LIST n-m` | List lines from n to m |
| `RUN` | Execute the program |
| `DELETE n` | Delete line n |
| `DELETE n-m` | Delete lines from n to m |
| `RENUM` | Renumber lines starting at 10, step 10 |
| `RENUM s,i` | Renumber starting at s with increment i |

### File Operations

| Command | Description |
|---------|-------------|
| `LOAD "filename"` | Load a program from disk |
| `SAVE "filename"` | Save the program to disk |
| `SAVE` | Save to current filename |
| `FILES` | List .bas files in the directory |
| `DIR` | Alias for FILES |
| `CATALOG` | Alias for FILES |

### Interface Commands

| Command | Description |
|---------|-------------|
| `CLS` | Clear the screen |
| `EDITOR` | Switch to EDITOR mode |
| `COMMAND` | Switch to COMMAND mode |
| `MODE` | Toggle between modes |
| `MODE E` | Switch to EDITOR mode |
| `MODE C` | Switch to COMMAND mode |
| `THEME` | Cycle to next theme |
| `THEME name` | Set specific theme (GREEN/AMBER/WHITE/BLUE/PINK) |

### System Commands

| Command | Description |
|---------|-------------|
| `HELP` | Show command reference |
| `?` | Alias for HELP |
| `BYE` | Exit Plan9 BASIC |
| `EXIT` | Alias for BYE |
| `QUIT` | Alias for BYE |
| `SYSTEM` | Alias for BYE |

## Program Entry (COMMAND Mode)

To enter a program, type a line number followed by the BASIC code:

```
> 10 PRINT "Hello, World!"
> 20 PRINT "This is Plan9 BASIC"
> 30 END
> RUN

Hello, World!
This is Plan9 BASIC
Program completed.
Ready.
```

To delete a line, type just its number:

```
> 20
Line 20 deleted.
Ready.
```

### Command History

- **Up Arrow**: Navigate to previous command
- **Down Arrow**: Navigate to next command
- **Escape**: Clear current input

## Sample Session

```
Plan9 BASIC v1.0
Type HELP or press F1 for commands.
Tap MODE to switch COMMAND/EDITOR.

Ready.
> 10 LET name$ = "World"
> 20 PRINT "Hello, "; name$; "!"
> 30 END
> LIST
10 LET name$ = "World"
20 PRINT "Hello, "; name$; "!"
30 END
Ready.
> RUN

Hello, World!
Program completed.
Ready.
> SAVE "hello"
Saved: hello.bas
Ready.
> THEME AMBER
Theme: AMBER
Ready.
> EDITOR
(switches to full-screen editor mode)
```

## Platform Support

### Desktop (Windows, Linux, macOS)

- Full keyboard support with function keys
- Dark background with bright text colors
- Monospace fonts: Consolas (Windows), DejaVu Sans Mono (Linux), Menlo (macOS)
- Transparent memo styling for dark theme effect

### Mobile (Android, iOS)

- Touch-friendly toolbar with large buttons
- Virtual keyboard support with automatic layout adjustment
- Light background with dark text colors (better contrast on mobile)
- Larger font sizes for readability
- System monospace font

## Technical Notes

### What's Preserved
- All library registrations (300+ functions)
- Compilation and execution engine
- Translation manager support
- Garbage collector integration

### What's Changed from Previous Interface
- Removed `TFrameMemoLineCount` frame
- Removed `TMultiView` menu system
- Removed `TTabControl` tab interface
- Removed `TStringGrid` file browser
- Added dual-mode interface (COMMAND/EDITOR)
- Added internal program storage (`TList<TProgramLine>`)
- Added command history
- Added line number parsing
- Added color theme system
- Added toolbar for mobile
- Added status bar

### Files to Replace
1. `UnitMain.fmx` - Form definition
2. `UnitMain.pas` - Main unit code

### Dependencies That Can Be Removed
- `FMX_MultiView_CustomPresentation.pas` (unless used elsewhere)
- `FrameMemoLineCount.pas` (unless used elsewhere)

### File Storage Locations

| Platform | Path |
|----------|------|
| Windows | `Documents\Plan9Basic\` |
| Linux | `~/Documents/Plan9Basic/` |
| macOS | `~/Documents/Plan9Basic/` |
| Android | App documents folder |
| iOS | App documents folder |

## Font Reference

### Desktop Fonts
| Platform | Primary | Alternatives |
|----------|---------|--------------|
| Windows | Consolas | Cascadia Mono, Fixedsys |
| Linux | DejaVu Sans Mono | Liberation Mono, Ubuntu Mono |
| macOS | Menlo | Monaco, SF Mono |

### Mobile Fonts
| Platform | Font |
|----------|------|
| Android | System monospace |
| iOS | System monospace |

## Future Enhancement Ideas

- `EDIT n` - Load line n into the input for editing
- `AUTO` - Automatic line numbering mode
- `CONT` - Continue execution after break
- `FIND` - Search within program
- Syntax highlighting
- Breakpoint indicators in editor gutter
- Recent files list
- Cloud storage integration
