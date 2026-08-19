unit StrListLib;
{
  StrListLib - String List Library for Plan9Basic
  ===============================================

  Provides a wrapper around Delphi's TStringList class, enabling Plan9Basic
  programs to work with dynamic string collections, file I/O, key-value pairs,
  and sorted lists.

  IMPORTANT: This library is the first one that demonstrates the EVENT HANDLING
  pattern for Plan9Basic.
  The OnChange and OnChanging events can trigger user-defined BASIC functions,
  establishing a reusable pattern for event-driven programming.

  Version: 1.2.0

  Changes from original:
  - Fixed 64-bit pointer compatibility (Integer -> NativeInt)
  - Added bounds checking for index-based operations
  - Added empty string validation for character access
  - Refactored duplicate encoding parsing code
  - Added overloaded file operations with default UTF-8 encoding
  - Added function signature validation for events
  - Improved error messages with more context
  - Removed unnecessary name parameter from constructor

  Function Count: 55 functions

  Copyright (c) 2024-2026 Plan9Basic Project
}

interface

uses
  System.SysUtils, System.Types, System.Classes,
  basic, exec, UnitGC;

type
  // Forward declaration
  TBasStringList = class;

  // Class used by the interpreter
  TBasStringList = class(TStringList)
  private
    FOnChangeFunc: String;      // BASIC function name for OnChange
    FOnChangingFunc: String;    // BASIC function name for OnChanging
    FBasicEngine: TBasicEngine; // Reference to the BASIC interpreter
    FConsoleOutput: TStrings;   // Reference to console output

    // Event handler bridge methods
    procedure InternalOnChange(Sender: TObject);
    procedure InternalOnChanging(Sender: TObject);

    // Property accessors
    function GetEvtOnChange: String;
    procedure SetEvtOnChange(const Value: String);
    function GetEvtOnChanging: String;
    procedure SetEvtOnChanging(const Value: String);

    // Helper to execute BASIC callback
    procedure ExecuteCallback(const FuncSignature: String; Sender: TObject);
  public
    constructor Create;

    // Check if a callback function exists in the BASIC engine
    function CallbackExists(const FuncName: String): Boolean;
  published
    property ConsoleOutput: TStrings read FConsoleOutput write FConsoleOutput;
    property Interpreter: TBasicEngine read FBasicEngine write FBasicEngine;

    // Event properties - store BASIC function names
    property EvtOnChange: String read GetEvtOnChange write SetEvtOnChange;
    property EvtOnChanging: String read GetEvtOnChanging write SetEvtOnChanging;
  end;

// Registration procedure
// Note: Unlike other libraries, this requires engine and output references
// for event callback support
procedure RegisterStringsFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

uses
  UnitUtils;

const
  STRLIST_GC_TAG = 'BASIC_STRLIST';

var
  // Module-level references for callback support
  // These are set during registration and used by event handlers
  ModuleEngine: TBasicEngine;
  ModuleOutput: TStrings;

const
  // Error messages
  ERR_UNDEFINED_COMPONENT = 'Undefined or nil string list';
  ERR_INDEX_OUT_OF_BOUNDS = 'Index out of bounds: %d (count: %d)';
  ERR_EMPTY_STRING = 'Empty string provided where character expected';
  ERR_INVALID_CALLBACK = 'Invalid callback function name: %s';

//==============================================================================
// Helper Functions
//==============================================================================

// Parse encoding string to TEncoding
function ParseEncoding(const EncodingName: String): TEncoding;
var
  LowerName: String;
begin
  LowerName := EncodingName.ToLower.Trim;

  if (LowerName = 'utf7') or (LowerName = 'utf-7') then
    Result := TEncoding.UTF7
  else if (LowerName = 'utf8') or (LowerName = 'utf-8') then
    Result := TEncoding.UTF8
  else if LowerName = 'ansi' then
    Result := TEncoding.ANSI
  else if LowerName = 'ascii' then
    Result := TEncoding.ASCII
  else if (LowerName = 'big endian unicode') or (LowerName = 'utf-16be') then
    Result := TEncoding.BigEndianUnicode
  else if (LowerName = 'unicode') or (LowerName = 'utf-16') or (LowerName = 'utf-16le') then
    Result := TEncoding.Unicode
  else
    Result := TEncoding.UTF8; // Default to UTF-8 (modern standard)
end;

// Get encoding name from TEncoding
function GetEncodingName(Encoding: TEncoding): String;
begin
  if Encoding = TEncoding.UTF7 then
    Result := 'utf-7'
  else if Encoding = TEncoding.UTF8 then
    Result := 'utf-8'
  else if Encoding = TEncoding.ANSI then
    Result := 'ansi'
  else if Encoding = TEncoding.ASCII then
    Result := 'ascii'
  else if Encoding = TEncoding.BigEndianUnicode then
    Result := 'utf-16be'
  else if Encoding = TEncoding.Unicode then
    Result := 'utf-16le'
  else
    Result := Encoding.EncodingName.ToLower;
end;

// Validate string list pointer
function ValidateStringList(P: Pointer; const Operation: String): TBasStringList;
begin
  if not Assigned(P) then
    raise Exception.CreateFmt('%s: %s', [Operation, ERR_UNDEFINED_COMPONENT]);
  Result := TBasStringList(P);
end;

// Validate index bounds
procedure ValidateIndex(SL: TBasStringList; Index: Integer; const Operation: String);
begin
  if (Index < 0) or (Index >= SL.Count) then
    raise Exception.CreateFmt('%s: ' + ERR_INDEX_OUT_OF_BOUNDS,
      [Operation, Index, SL.Count]);
end;

//==============================================================================
// TBasStringList Implementation
//==============================================================================

constructor TBasStringList.Create();
begin
  inherited Create();
  FOnChangeFunc := '';
  FOnChangingFunc := '';
  FBasicEngine := nil;
  FConsoleOutput := nil;
end;

function TBasStringList.GetEvtOnChange(): String;
begin
  Result := FOnChangeFunc;
end;

procedure TBasStringList.SetEvtOnChange(const Value: String);
begin
  if FOnChangeFunc <> Value then
  begin
    FOnChangeFunc := Value;
    if Value <> '' then
      Self.OnChange := InternalOnChange
    else
      Self.OnChange := nil;
  end;
end;

function TBasStringList.GetEvtOnChanging(): String;
begin
  Result := FOnChangingFunc;
end;

procedure TBasStringList.SetEvtOnChanging(const Value: String);
begin
  if FOnChangingFunc <> Value then
  begin
    FOnChangingFunc := Value;
    if Value <> '' then
      Self.OnChanging := InternalOnChanging
    else
      Self.OnChanging := nil;
  end;
end;

function TBasStringList.CallbackExists(const FuncName: String): Boolean;
begin
  Result := False;
  if Assigned(FBasicEngine) then
    Result := FBasicEngine.UserFunctionExists(FuncName);
end;

procedure TBasStringList.ExecuteCallback(const FuncSignature: String; Sender: TObject);
var
  Args: array of TAsmData;
  RetType: TExprKind;
  RetVal: TAsmData;
begin
  if not Assigned(FBasicEngine) then Exit();
  if not Assigned(FConsoleOutput) then Exit();
  if FuncSignature = '' then Exit();

  SetLength(Args, 1);
  Args[0].p := Pointer(Sender);
  Args[0].n := 0;
  Args[0].s := '';

  try
    FBasicEngine.ExecuteUserFunction(FConsoleOutput, FuncSignature, Args, RetType, RetVal);
  except
    on E: Exception do
    begin
      FConsoleOutput.Add('*** Event Callback Error ***');
      FConsoleOutput.Add('Function: ' + FuncSignature);
      if Assigned(FBasicEngine.Parser) and Assigned(FBasicEngine.Parser.exec) then
      begin
        FConsoleOutput.Add('IP: ' + IntToStr(FBasicEngine.Parser.exec.IP));
        FConsoleOutput.Add('Line: ' + IntToStr(FBasicEngine.Parser.exec.SourceLine));
      end;
      FConsoleOutput.Add('Error: ' + E.Message);
    end;
  end;
end;

procedure TBasStringList.InternalOnChange(Sender: TObject);
begin
  ExecuteCallback(FOnChangeFunc, Sender);
end;

procedure TBasStringList.InternalOnChanging(Sender: TObject);
begin
  ExecuteCallback(FOnChangingFunc, Sender);
end;

//==============================================================================
// Library Functions - Creation and Destruction
//==============================================================================

// strings#() - Create a new string list
function stringlist_new(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := TBasStringList.Create();
  SL.Interpreter := ModuleEngine;
  SL.ConsoleOutput := ModuleOutput;

  Result.n := 0;
  Result.s := '';

  // Register with GC using NativeInt for 64-bit compatibility
  if Assigned(UnitGC.GC) then
    UnitGC.GC.Add<TBasStringList>(SL, STRLIST_GC_TAG+'_'+IntToStr(NativeInt(Result.p)));

  Result.p := Pointer(SL);
end;

// strings_free(sl#) - Free a string list
function stringlist_free(var Args: array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Assigned(Args[0].p) then
  begin
    UnitGC.GC.Collect(STRLIST_GC_TAG+'_'+IntToStr(NativeInt(Args[0].p)));
    Result.n := 1;
  end
  else
    raise Exception.Create('strings_free: ' + ERR_UNDEFINED_COMPONENT);
end;

//==============================================================================
// Library Functions - Properties (Getters and Setters)
//==============================================================================

// strings_capacity(sl#, n) - Set capacity
function stringlist_setcapacity(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_capacity');
  SL.Capacity := Trunc(Args[1].n);
end;

// strings_capacity(sl#) - Get capacity
function stringlist_getcapacity(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_capacity');
  Result.n := SL.Capacity;
end;

// strings_casesensitive(sl#, n) - Set case sensitivity
function stringlist_setcasesensitive(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_casesensitive');
  SL.CaseSensitive := Trunc(Args[1].n) <> 0;
end;

// strings_casesensitive(sl#) - Get case sensitivity
function stringlist_getcasesensitive(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_casesensitive');
  Result.n := Ord(SL.CaseSensitive);
end;

// strings_commatext(sl#, s$) - Set comma-separated text
function stringlist_setcommatext(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_commatext');
  SL.CommaText := Args[1].s;
end;

// strings_commatext$(sl#) - Get comma-separated text
function stringlist_getcommatext(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_commatext$');
  Result.s := SL.CommaText;
end;

// strings_count(sl#) - Get item count
function stringlist_getcount(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_count');
  Result.n := SL.Count;
end;

// strings_defaultencoding(sl#, enc$) - Set default encoding
function stringlist_setdefaultencoding(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_defaultencoding');
  SL.DefaultEncoding := ParseEncoding(Args[1].s);
end;

// strings_defaultencoding$(sl#) - Get default encoding
function stringlist_getdefaultencoding(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_defaultencoding$');
  Result.s := GetEncodingName(SL.DefaultEncoding);
end;

// strings_delimitedtext(sl#, s$) - Set delimited text
function stringlist_setdelimitedtext(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_delimitedtext');
  SL.DelimitedText := Args[1].s;
end;

// strings_delimitedtext$(sl#) - Get delimited text
function stringlist_getdelimitedtext(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_delimitedtext$');
  Result.s := SL.DelimitedText;
end;

// strings_delimiter(sl#, c$) - Set delimiter character
function stringlist_setdelimiter(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_delimiter');
  if Args[1].s.Length = 0 then
    raise Exception.Create('strings_delimiter: ' + ERR_EMPTY_STRING);
  SL.Delimiter := Args[1].s.Chars[0];
end;

// strings_delimiter$(sl#) - Get delimiter character
function stringlist_getdelimiter(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_delimiter$');
  Result.s := SL.Delimiter;
end;

// strings_duplicates(sl#, mode$) - Set duplicate handling mode
function stringlist_setduplicates(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  Mode: String;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_duplicates');
  Mode := Args[1].s.ToLower;

  if Mode = 'ignore' then
    SL.Duplicates := dupIgnore
  else if Mode = 'accept' then
    SL.Duplicates := dupAccept
  else if Mode = 'error' then
    SL.Duplicates := dupError
  else
    SL.Duplicates := dupIgnore; // Default
end;

// strings_duplicates$(sl#) - Get duplicate handling mode
function stringlist_getduplicates(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_duplicates$');
  case SL.Duplicates of
    dupIgnore: Result.s := 'ignore';
    dupAccept: Result.s := 'accept';
    dupError:  Result.s := 'error';
  else
    Result.s := 'ignore';
  end;
end;

// strings_encoding$(sl#) - Get current encoding (read-only)
function stringlist_getencoding(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_encoding$');
  Result.s := GetEncodingName(SL.Encoding);
end;

// strings_keynames$(sl#, index) - Get key name at index
function stringlist_getkeynames(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  Index: Integer;
begin
  SL := ValidateStringList(Args[0].p, 'strings_keynames$');
  Index := Trunc(Args[1].n);
  ValidateIndex(SL, Index, 'strings_keynames$');
  Result.s := SL.KeyNames[Index];
end;

// strings_linebreak(sl#, s$) - Set line break string
function stringlist_setlinebreak(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_linebreak');
  SL.LineBreak := Args[1].s;
end;

// strings_linebreak$(sl#) - Get line break string
function stringlist_getlinebreak(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_linebreak$');
  Result.s := SL.LineBreak;
end;

// strings_names$(sl#, index) - Get name part at index (from Name=Value pairs)
function stringlist_getnames(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  Index: Integer;
begin
  SL := ValidateStringList(Args[0].p, 'strings_names$');
  Index := Trunc(Args[1].n);
  ValidateIndex(SL, Index, 'strings_names$');
  Result.s := SL.Names[Index];
end;

// strings_namevalueseparator(sl#, c$) - Set name-value separator
function stringlist_setnamevalueseparator(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_namevalueseparator');
  if Args[1].s.Length = 0 then
    raise Exception.Create('strings_namevalueseparator: ' + ERR_EMPTY_STRING);
  SL.NameValueSeparator := Args[1].s.Chars[0];
end;

// strings_namevalueseparator$(sl#) - Get name-value separator
function stringlist_getnamevalueseparator(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_namevalueseparator$');
  Result.s := SL.NameValueSeparator;
end;

// strings_quotechar(sl#, c$) - Set quote character
function stringlist_setquotechar(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_quotechar');
  if Args[1].s.Length = 0 then
    raise Exception.Create('strings_quotechar: ' + ERR_EMPTY_STRING);
  SL.QuoteChar := Args[1].s.Chars[0];
end;

// strings_quotechar$(sl#) - Get quote character
function stringlist_getquotechar(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_quotechar$');
  Result.s := SL.QuoteChar;
end;

// strings_sorted(sl#, n) - Set sorted mode
function stringlist_setsorted(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_sorted');
  SL.Sorted := Trunc(Args[1].n) <> 0;
end;

// strings_sorted(sl#) - Get sorted mode
function stringlist_getsorted(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_sorted');
  Result.n := Ord(SL.Sorted);
end;

// strings_strictdelimiter(sl#, n) - Set strict delimiter mode
function stringlist_setstrictdelimiter(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_strictdelimiter');
  SL.StrictDelimiter := Trunc(Args[1].n) <> 0;
end;

// strings_strictdelimiter(sl#) - Get strict delimiter mode
function stringlist_getstrictdelimiter(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_strictdelimiter');
  Result.n := Ord(SL.StrictDelimiter);
end;

// strings_strings(sl#, index, s$) - Set string at index
function stringlist_setstrings(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  Index: Integer;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_strings');
  Index := Trunc(Args[1].n);
  ValidateIndex(SL, Index, 'strings_strings');
  SL.Strings[Index] := Args[2].s;
end;

// strings_strings$(sl#, index) - Get string at index
function stringlist_getstrings(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  Index: Integer;
begin
  SL := ValidateStringList(Args[0].p, 'strings_strings$');
  Index := Trunc(Args[1].n);
  ValidateIndex(SL, Index, 'strings_strings$');
  Result.s := SL.Strings[Index];
end;

// strings_text(sl#, s$) - Set entire text content
function stringlist_settext(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_text');
  SL.Text := Args[1].s;
end;

// strings_text$(sl#) - Get entire text content
function stringlist_gettext(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_text$');
  Result.s := SL.Text;
end;

// strings_trailinglinebreak(sl#, n) - Set trailing line break
function stringlist_settrailinglinebreak(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_trailinglinebreak');
  SL.TrailingLineBreak := Trunc(Args[1].n) <> 0;
end;

// strings_trailinglinebreak(sl#) - Get trailing line break
function stringlist_gettrailinglinebreak(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_trailinglinebreak');
  Result.n := Ord(SL.TrailingLineBreak);
end;

// strings_valuefromindex(sl#, index, s$) - Set value at index
function stringlist_setvaluefromindex(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  Index: Integer;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_valuefromindex');
  Index := Trunc(Args[1].n);
  ValidateIndex(SL, Index, 'strings_valuefromindex');
  SL.ValueFromIndex[Index] := Args[2].s;
end;

// strings_valuefromindex$(sl#, index) - Get value at index
function stringlist_getvaluefromindex(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  Index: Integer;
begin
  SL := ValidateStringList(Args[0].p, 'strings_valuefromindex$');
  Index := Trunc(Args[1].n);
  ValidateIndex(SL, Index, 'strings_valuefromindex$');
  Result.s := SL.ValueFromIndex[Index];
end;

// strings_values(sl#, key$, value$) - Set value by key name
function stringlist_setvalues(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_values');
  SL.Values[Args[1].s] := Args[2].s;
end;

// strings_values$(sl#, key$) - Get value by key name
function stringlist_getvalues(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_values$');
  Result.s := SL.Values[Args[1].s];
end;

// strings_writebom(sl#, n) - Set write BOM flag
function stringlist_setwritebom(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_writebom');
  SL.WriteBOM := Trunc(Args[1].n) <> 0;
end;

// strings_writebom(sl#) - Get write BOM flag
function stringlist_getwritebom(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_writebom');
  Result.n := Ord(SL.WriteBOM);
end;

//==============================================================================
// Library Functions - Methods
//==============================================================================

// strings_add(sl#, s$) - Add string, returns index
function stringlist_add(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_add');
  Result.n := SL.Add(Args[1].s);
end;

// strings_append(sl#, s$) - Append string, returns count
function stringlist_append(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_append');
  SL.Append(Args[1].s);
  Result.n := SL.Count;
end;

// strings_beginupdate(sl#) - Begin batch update
function stringlist_beginupdate(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_beginupdate');
  SL.BeginUpdate;
end;

// strings_clear(sl#) - Clear all items
function stringlist_clear(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_clear');
  SL.Clear;
end;

// strings_delete(sl#, index) - Delete item at index, returns new count
function stringlist_delete(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  Index: Integer;
begin
  SL := ValidateStringList(Args[0].p, 'strings_delete');
  Index := Trunc(Args[1].n);
  ValidateIndex(SL, Index, 'strings_delete');
  SL.Delete(Index);
  Result.n := SL.Count;
end;

// strings_endupdate(sl#) - End batch update
function stringlist_endupdate(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_endupdate');
  SL.EndUpdate;
end;

// strings_equals(sl1#, sl2#) - Compare two string lists
function stringlist_equals(var Args: array of TAsmData): TAsmData;
var
  SL1, SL2: TBasStringList;
begin
  Result.n := 0;
  SL1 := ValidateStringList(Args[0].p, 'strings_equals');
  if Assigned(Args[1].p) then
  begin
    SL2 := TBasStringList(Args[1].p);
    Result.n := Ord(SL1.Equals(SL2));
  end;
end;

// strings_exchange(sl#, idx1, idx2) - Exchange two items
function stringlist_exchange(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  Idx1, Idx2: Integer;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_exchange');
  Idx1 := Trunc(Args[1].n);
  Idx2 := Trunc(Args[2].n);
  ValidateIndex(SL, Idx1, 'strings_exchange (index1)');
  ValidateIndex(SL, Idx2, 'strings_exchange (index2)');
  SL.Exchange(Idx1, Idx2);
end;

// strings_find(sl#, s$) - Find string (for sorted lists), returns index or -1
function stringlist_find(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  Index: Integer;
begin
  Result.n := -1;
  SL := ValidateStringList(Args[0].p, 'strings_find');
  if SL.Find(Args[1].s, Index) then
    Result.n := Index;
end;

// strings_indexof(sl#, s$) - Find string index, returns -1 if not found
function stringlist_indexof(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_indexof');
  Result.n := SL.IndexOf(Args[1].s);
end;

// strings_indexofname(sl#, name$) - Find name index in Name=Value pairs
function stringlist_indexofname(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_indexofname');
  Result.n := SL.IndexOfName(Args[1].s);
end;

// strings_insert(sl#, index, s$) - Insert string at index, returns new count
function stringlist_insert(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  Index: Integer;
begin
  SL := ValidateStringList(Args[0].p, 'strings_insert');
  Index := Trunc(Args[1].n);
  // For insert, index can be 0..Count (inclusive)
  if (Index < 0) or (Index > SL.Count) then
    raise Exception.CreateFmt('strings_insert: Index out of bounds: %d (valid: 0..%d)',
      [Index, SL.Count]);
  SL.Insert(Index, Args[2].s);
  Result.n := SL.Count;
end;

// strings_loadfromfile(sl#, filename$, encoding$) - Load from file with encoding
function stringlist_loadfromfile(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_loadfromfile');
  SL.LoadFromFile(Args[1].s, ParseEncoding(Args[2].s));
  Result.n := SL.Count;
end;

// strings_load(sl#, filename$) - Load from file (UTF-8 default)
function stringlist_load(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_load');
  SL.LoadFromFile(Args[1].s, TEncoding.UTF8);
  Result.n := SL.Count;
end;

// strings_loadfromstream(sl#, stream#, encoding$) - Load from stream
function stringlist_loadfromstream(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_loadfromstream');
  if not Assigned(Args[1].p) then
    raise Exception.Create('strings_loadfromstream: Invalid stream');
  SL.LoadFromStream(TStream(Args[1].p), ParseEncoding(Args[2].s));
  Result.n := SL.Count;
end;

// strings_savetofile(sl#, filename$, encoding$) - Save to file with encoding
function stringlist_savetofile(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_savetofile');
  SL.SaveToFile(Args[1].s, ParseEncoding(Args[2].s));
  Result.n := SL.Count;
end;

// strings_save(sl#, filename$) - Save to file (UTF-8 default)
function stringlist_save(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_save');
  SL.SaveToFile(Args[1].s, TEncoding.UTF8);
  Result.n := SL.Count;
end;

// strings_savetostream(sl#, stream#, encoding$) - Save to stream
function stringlist_savetostream(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_savetostream');
  if not Assigned(Args[1].p) then
    raise Exception.Create('strings_savetostream: Invalid stream');
  SL.SaveToStream(TStream(Args[1].p), ParseEncoding(Args[2].s));
  Result.n := SL.Count;
end;

// strings_move(sl#, curIndex, newIndex) - Move item
function stringlist_move(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  CurIdx, NewIdx: Integer;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_move');
  CurIdx := Trunc(Args[1].n);
  NewIdx := Trunc(Args[2].n);
  ValidateIndex(SL, CurIdx, 'strings_move (current index)');
  ValidateIndex(SL, NewIdx, 'strings_move (new index)');
  SL.Move(CurIdx, NewIdx);
end;

// strings_sort(sl#) - Sort the list
function stringlist_sort(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  Result.n := 1;
  SL := ValidateStringList(Args[0].p, 'strings_sort');
  SL.Sort;
end;

//==============================================================================
// Library Functions - Events
//==============================================================================

// strings_onchange$(sl#) - Get OnChange handler name
function stringlist_getevtonchange(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_onchange$');
  Result.s := SL.EvtOnChange;
end;

// strings_onchange(sl#, funcname$) - Set OnChange handler
function stringlist_setevtonchange(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  FuncName: String;
begin
  Result.n := 0;
  SL := ValidateStringList(Args[0].p, 'strings_onchange');
  FuncName := Args[1].s.Trim;

  if FuncName = '' then
  begin
    // Clear the event handler
    SL.EvtOnChange := '';
    Result.n := 1;
    Exit;
  end;

  if not IsValidIdent(FuncName, False) then
    raise Exception.CreateFmt('strings_onchange: ' + ERR_INVALID_CALLBACK, [FuncName]);

  // Build signature: functionname#@# (pointer function with pointer parameter)
  SL.EvtOnChange := FuncName.ToLower + '#@#';
  Result.n := 1;
end;

// strings_onchanging$(sl#) - Get OnChanging handler name
function stringlist_getevtonchanging(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
begin
  SL := ValidateStringList(Args[0].p, 'strings_onchanging$');
  Result.s := SL.EvtOnChanging;
end;

// strings_onchanging(sl#, funcname$) - Set OnChanging handler
function stringlist_setevtonchanging(var Args: array of TAsmData): TAsmData;
var
  SL: TBasStringList;
  FuncName: String;
begin
  Result.n := 0;
  SL := ValidateStringList(Args[0].p, 'strings_onchanging');
  FuncName := Args[1].s.Trim;

  if FuncName = '' then
  begin
    // Clear the event handler
    SL.EvtOnChanging := '';
    Result.n := 1;
    Exit;
  end;

  if not IsValidIdent(FuncName, False) then
    raise Exception.CreateFmt('strings_onchanging: ' + ERR_INVALID_CALLBACK, [FuncName]);

  // Build signature: functionname#@# (pointer function with pointer parameter)
  SL.EvtOnChanging := FuncName.ToLower + '#@#';
  Result.n := 1;
end;

//==============================================================================
// Registration
//==============================================================================

procedure RegisterStringsFuncs(Lib: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  FnData: TLinkFunction;
begin
  // Store references for event callbacks
  ModuleEngine := Eng;
  ModuleOutput := OutP;

  FnData.FarCall := True;
  //No FireMonkey here, so these run wherever the VM stands.
  FnData.NeedsUIThread := False;

  // Creation and destruction
  FnData.Entry := stringlist_new;         Lib.Add('strings#@', FnData);
  FnData.Entry := stringlist_free;        Lib.Add('strings_free@#', FnData);

  // Properties - Capacity
  FnData.Entry := stringlist_setcapacity; Lib.Add('strings_capacity@#n', FnData);
  FnData.Entry := stringlist_getcapacity; Lib.Add('strings_capacity@#', FnData);

  // Properties - Case Sensitivity
  FnData.Entry := stringlist_setcasesensitive; Lib.Add('strings_casesensitive@#n', FnData);
  FnData.Entry := stringlist_getcasesensitive; Lib.Add('strings_casesensitive@#', FnData);

  // Properties - Text formats
  FnData.Entry := stringlist_setcommatext;      Lib.Add('strings_commatext@#$', FnData);
  FnData.Entry := stringlist_getcommatext;      Lib.Add('strings_commatext$@#', FnData);
  FnData.Entry := stringlist_setdelimitedtext;  Lib.Add('strings_delimitedtext@#$', FnData);
  FnData.Entry := stringlist_getdelimitedtext;  Lib.Add('strings_delimitedtext$@#', FnData);
  FnData.Entry := stringlist_settext;           Lib.Add('strings_text@#$', FnData);
  FnData.Entry := stringlist_gettext;           Lib.Add('strings_text$@#', FnData);

  // Properties - Count (read-only)
  FnData.Entry := stringlist_getcount;    Lib.Add('strings_count@#', FnData);

  // Properties - Encoding
  FnData.Entry := stringlist_setdefaultencoding; Lib.Add('strings_defaultencoding@#$', FnData);
  FnData.Entry := stringlist_getdefaultencoding; Lib.Add('strings_defaultencoding$@#', FnData);
  FnData.Entry := stringlist_getencoding;        Lib.Add('strings_encoding$@#', FnData);

  // Properties - Delimiters
  FnData.Entry := stringlist_setdelimiter;          Lib.Add('strings_delimiter@#$', FnData);
  FnData.Entry := stringlist_getdelimiter;          Lib.Add('strings_delimiter$@#', FnData);
  FnData.Entry := stringlist_setstrictdelimiter;    Lib.Add('strings_strictdelimiter@#n', FnData);
  FnData.Entry := stringlist_getstrictdelimiter;    Lib.Add('strings_strictdelimiter@#', FnData);
  FnData.Entry := stringlist_setquotechar;          Lib.Add('strings_quotechar@#$', FnData);
  FnData.Entry := stringlist_getquotechar;          Lib.Add('strings_quotechar$@#', FnData);
  FnData.Entry := stringlist_setlinebreak;          Lib.Add('strings_linebreak@#$', FnData);
  FnData.Entry := stringlist_getlinebreak;          Lib.Add('strings_linebreak$@#', FnData);
  FnData.Entry := stringlist_setnamevalueseparator; Lib.Add('strings_namevalueseparator@#$', FnData);
  FnData.Entry := stringlist_getnamevalueseparator; Lib.Add('strings_namevalueseparator$@#', FnData);

  // Properties - Duplicates and Sorting
  FnData.Entry := stringlist_setduplicates;  Lib.Add('strings_duplicates@#$', FnData);
  FnData.Entry := stringlist_getduplicates;  Lib.Add('strings_duplicates$@#', FnData);
  FnData.Entry := stringlist_setsorted;      Lib.Add('strings_sorted@#n', FnData);
  FnData.Entry := stringlist_getsorted;      Lib.Add('strings_sorted@#', FnData);

  // Properties - Item Access
  FnData.Entry := stringlist_setstrings;        Lib.Add('strings_strings@#n$', FnData);
  FnData.Entry := stringlist_getstrings;        Lib.Add('strings_strings$@#n', FnData);
  FnData.Entry := stringlist_setvaluefromindex; Lib.Add('strings_valuefromindex@#n$', FnData);
  FnData.Entry := stringlist_getvaluefromindex; Lib.Add('strings_valuefromindex$@#n', FnData);
  FnData.Entry := stringlist_setvalues;         Lib.Add('strings_values@#$$', FnData);
  FnData.Entry := stringlist_getvalues;         Lib.Add('strings_values$@#$', FnData);

  // Properties - Name/Value pairs
  FnData.Entry := stringlist_getnames;    Lib.Add('strings_names$@#n', FnData);
  FnData.Entry := stringlist_getkeynames; Lib.Add('strings_keynames$@#n', FnData);

  // Properties - Miscellaneous
  FnData.Entry := stringlist_settrailinglinebreak; Lib.Add('strings_trailinglinebreak@#n', FnData);
  FnData.Entry := stringlist_gettrailinglinebreak; Lib.Add('strings_trailinglinebreak@#', FnData);
  FnData.Entry := stringlist_setwritebom;          Lib.Add('strings_writebom@#n', FnData);
  FnData.Entry := stringlist_getwritebom;          Lib.Add('strings_writebom@#', FnData);

  // Methods - Add/Insert/Delete
  FnData.Entry := stringlist_add;     Lib.Add('strings_add@#$', FnData);
  FnData.Entry := stringlist_append;  Lib.Add('strings_append@#$', FnData);
  FnData.Entry := stringlist_insert;  Lib.Add('strings_insert@#n$', FnData);
  FnData.Entry := stringlist_delete;  Lib.Add('strings_delete@#n', FnData);
  FnData.Entry := stringlist_clear;   Lib.Add('strings_clear@#', FnData);

  // Methods - Update batching
  FnData.Entry := stringlist_beginupdate; Lib.Add('strings_beginupdate@#', FnData);
  FnData.Entry := stringlist_endupdate;   Lib.Add('strings_endupdate@#', FnData);

  // Methods - Search
  FnData.Entry := stringlist_find;        Lib.Add('strings_find@#$', FnData);
  FnData.Entry := stringlist_indexof;     Lib.Add('strings_indexof@#$', FnData);
  FnData.Entry := stringlist_indexofname; Lib.Add('strings_indexofname@#$', FnData);

  // Methods - Manipulation
  FnData.Entry := stringlist_exchange; Lib.Add('strings_exchange@#nn', FnData);
  FnData.Entry := stringlist_move;     Lib.Add('strings_move@#nn', FnData);
  FnData.Entry := stringlist_sort;     Lib.Add('strings_sort@#', FnData);
  FnData.Entry := stringlist_equals;   Lib.Add('strings_equals@##', FnData);

  // Methods - File I/O (with encoding)
  FnData.Entry := stringlist_loadfromfile; Lib.Add('strings_loadfromfile@#$$', FnData);
  FnData.Entry := stringlist_savetofile;   Lib.Add('strings_savetofile@#$$', FnData);

  // Methods - File I/O (UTF-8 default)
  FnData.Entry := stringlist_load; Lib.Add('strings_load@#$', FnData);
  FnData.Entry := stringlist_save; Lib.Add('strings_save@#$', FnData);

  // Methods - Stream I/O
  FnData.Entry := stringlist_loadfromstream; Lib.Add('strings_loadfromstream@##$', FnData);
  FnData.Entry := stringlist_savetostream;   Lib.Add('strings_savetostream@##$', FnData);

  // Events
  FnData.Entry := stringlist_getevtonchange;   Lib.Add('strings_onchange$@#', FnData);
  FnData.Entry := stringlist_setevtonchange;   Lib.Add('strings_onchange@#$', FnData);
  FnData.Entry := stringlist_getevtonchanging; Lib.Add('strings_onchanging$@#', FnData);
  FnData.Entry := stringlist_setevtonchanging; Lib.Add('strings_onchanging@#$', FnData);
end;

end.

