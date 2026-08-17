# Plan9Basic Test Applets

This folder contains 17 test applets for the Plan9Basic IDE, covering all 6 extension libraries and demonstrating various language features.

## Library Tests

| # | File | Description |
|---|------|-------------|
| 01 | `01_stdlib_test.bas` | StdLib - pause, sign, format settings |
| 02 | `02_strlib_test.bas` | StrLib - string manipulation |
| 03 | `03_numlib_test.bas` | NumLib - mathematical functions |
| 04 | `04_datetimelib_test.bas` | DateTimeLib - date/time operations |
| 05 | `05_platforminfolib_test.bas` | PlatformInfoLib - OS information |
| 06 | `06_syslib_test.bas` | SysLib - system paths and files |

## Demo Applets

| # | File | Description |
|---|------|-------------|
| 07 | `07_digital_clock.bas` | Digital clock display |
| 08 | `08_calculator.bas` | Math calculator demo |
| 09 | `09_text_statistics.bas` | Text analysis demo |
| 10 | `10_system_info.bas` | System information report |
| 11 | `11_string_formatter.bas` | Text formatting demo |
| 12 | `12_number_game.bas` | Number guessing game |
| 13 | `13_age_calculator.bas` | Age and date calculator |
| 14 | `14_comprehensive_test.bas` | All libraries in one test |
| 15 | `15_math_demo.bas` | Mathematical functions showcase |
| 16 | `16_do_loop_test.bas` | DO...LOOP structure tests |
| 17 | `17_file_io_demo.bas` | File I/O operations demo |

## Library Function Summary

### StdLib (13 functions)
- `pause(n)` - Sleep for n seconds
- `sign(n)` - Return sign (-1, 0, 1)
- `isnan(n)`, `isinfinite(n)`, `isnil(p)`, `isnull(s)` - Type checking
- `formatsettings$()`, `formatsettings()` - Format settings get/set
- `classname$(p)`, `number(p)`, `pointer#(n)`, `pnttonum(p)` - Conversions
- `processmessages()`, `handlemessage()` - Message processing

### StrLib (35 functions)
- Case: `lcase$`, `ucase$`, `alcase$`, `aucase$`
- Trim: `ltrim$`, `rtrim$`
- Pad: `ltab$`, `rtab$`, `lfill$`, `rfill$`
- Char: `chr$`, `asc`, `len`
- Convert: `hex$`, `oct$`, `bin$`, `str$`, `val`, `valcode`
- Substring: `left$`, `right$`, `mid$`
- Search: `containsstr`, `containstext`, `startsstr`, `startstext`, `endsstr`, `endstext`
- Manipulate: `replacestr$`, `replacetext$`, `reverse$`, `mulstring$`, `stuffstring$`
- Lines: `count`, `line$`
- File: `opentext$`, `savetext$`
- Clipboard: `copytext$`, `pastetext$`

### NumLib (34 functions)
- Basic: `abs`, `cint`, `fix`, `frac`, `int`, `round`, `sgn`
- Trig: `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `atan2`
- Hyperbolic: `sinh`, `cosh`, `tanh`, `asinh`, `acosh`, `atanh`
- Log/Exp: `ln`, `log2`, `log10`, `exp`, `sqr`
- Min/Max: `min`, `max`
- Random: `randomize`, `rnd`
- Convert: `degtorad`, `radtodeg`
- Compare: `cmpval`

### DateTimeLib (63 functions)
- Current: `now`, `date`, `date$`, `time`, `time$`, `gettime`, `datetime$`
- Convert: `datetostr$`, `strtodate`, `timetostr$`, `strtotime`, `datetimetostr$`, `strtodatetime`, `formatdatetime$`
- Extract: `yearof`, `monthof`, `dayof`, `hourof`, `minuteof`, `millisecondof`, `monthoftheyear`, `weekof`, `weekofthemonth`, `weekoftheyear`, `dayofweek`, `dayoftheweek`, `dayofthemonth`, `dayoftheyear`
- Increment: `incday`, `inchour`, `incminute`, `incsecond`, `incmillisecond`, `incweek`, `incyear`
- Between: `daysbetween`, `hoursbetween`, `minutesbetween`, `millisecondsbetween`, `weeksbetween`, `monthsbetween`, `yearsbetween`
- Span: `dayspan`, `hourspan`, `minutespan`, `millisecondspan`, `weekspan`, `monthspan`, `yearspan`
- Days: `daysinamonth`, `daysinayear`, `daysinmonth`, `daysinyear`, `weeksinayear`, `weeksinyear`
- Check: `isam`, `ispm`, `istoday`, `issameday`, `isinleapyear`
- Special: `yesterday`, `today`, `tomorrow`

### PlatformInfoLib (10 functions)
- `os_platform$`, `os_name$`, `os_architecture$`
- `os_major`, `os_minor`, `os_build`
- `os_spmajor`, `os_spminor`
- `os_check`

### SysLib (43 functions)
- Params: `paramcount`, `paramstr$`
- Dirs: `chdir`, `mkdir`, `rmdir`, `forcedirectories`
- Files: `kill`, `fileexists`
- Paths: `homepath$`, `temppath$`, `documentspath$`, `downloadspath$`, `picturespath$`, `musicpath$`, `moviespath$`, `cachepath$`, `publicpath$`, `librarypath$`, `camerapath$`, `alarmspath$`, `ringtonespath$` (+ shared variants)
- Path Utils: `dirseparator$`, `altseparator$`, `pathseparator$`, `extractfilename$`, `extractfilepath$`, `extractfileext$`, `changefileext$`
- Temp: `randomfilename$`, `guidfilename$`, `tempfilename$`
- Env: `environ$`
- Colors: `color`, `alphacolor`, `colortostr$`

## Usage

1. Open Plan9Basic IDE
2. Load any `.bas` file from this folder
3. Run the applet
4. View output in the console

## Notes

- Some functions may behave differently on different platforms (Windows, macOS, Android, iOS)
- File operations require appropriate permissions
- The DO...LOOP test (16) requires the Phase 5 language extension
