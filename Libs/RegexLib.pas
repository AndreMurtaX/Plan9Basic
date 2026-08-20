unit RegexLib;

{******************************************************************************
  RegexLib - Regular Expression Library for Plan9Basic

  Provides comprehensive regular expression support using Delphi's
  System.RegularExpressions unit. Enables pattern matching, searching,
  replacing, and splitting operations on strings.

  Version: 1.0
  Date: 2025

  Function naming convention:
    regex_xxx#()   - Returns pointer (TStringList for collections)
    regex_xxx$()   - Returns string
    regex_xxx()    - Returns number

  Regex Options (values for use in Plan9Basic - not predefined):
    1 = Ignore case      - Case-insensitive matching
    2 = Multiline        - ^ and $ match line boundaries
    4 = Singleline       - . matches newlines
    8 = Explicit capture - Only named/numbered groups capture
  
  Users should define their own variables or use numeric values directly.

  Function Count: 25 functions

  Copyright (c) 2024-2025 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, System.RegularExpressions,
  exec, UnitGC, HandleRegistry;

const
  REGEX_GC_TAG = 'BASIC_REGEX';

  // Regex option flags (combinable with OR/addition)
  REGEX_OPT_NONE = 0;
  REGEX_OPT_IGNORECASE = 1;
  REGEX_OPT_MULTILINE = 2;
  REGEX_OPT_SINGLELINE = 4;
  REGEX_OPT_EXPLICITCAPTURE = 8;

// Register all regex functions with the function dictionary
procedure RegisterRegexFuncs(Funcs: TFunctionsDictionary);

implementation

//------------------------------------------------------------------------------
// Helper Functions
//------------------------------------------------------------------------------

// Convert numeric options to TRegExOptions set
function GetRegExOptions(Options: Integer): TRegExOptions;
begin
  Result := [];
  if (Options and REGEX_OPT_IGNORECASE) <> 0 then
    Include(Result, roIgnoreCase);
  if (Options and REGEX_OPT_MULTILINE) <> 0 then
    Include(Result, roMultiLine);
  if (Options and REGEX_OPT_SINGLELINE) <> 0 then
    Include(Result, roSingleLine);
  if (Options and REGEX_OPT_EXPLICITCAPTURE) <> 0 then
    Include(Result, roExplicitCapture);
end;

// Create and register a TStringList with GC
function CreateManagedStringList: TStringList;
begin
  Result := TStringList.Create;
  GC.Add<TStringList>(Result, REGEX_GC_TAG);
  //A regex match list is handed to BASIC as a handle and read back with the
  //strings_* family, so it has to be in the registry for those calls to tell
  //it from a number the program invented. StrListLib validated by casting
  //until 2026-08-20 and nothing here needed to be registered; now it does.
  RegisterHandle(Result);
end;

//------------------------------------------------------------------------------
// Validation Functions
//------------------------------------------------------------------------------

// regex_isvalid(pattern$) - Check if pattern is a valid regex
// Returns: 1 if valid, 0 if invalid
function p_regex_isvalid(var Args: Array of TAsmData): TAsmData;
var
  RE: TRegEx;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  //An empty pattern is legal (it matches at every position), but the
  //underlying engine refuses to compile it, so it is answered directly.
  if Args[0].s = '' then
  begin
    Result.n := 1;
    Exit();
  end;

  try
    RE := TRegEx.Create(Args[0].s);
    //TRegEx.Create only stores the pattern; it does not compile it, so an
    //invalid pattern raises nothing here. Running a match forces compilation,
    //which is what actually validates the pattern.
    RE.IsMatch('');
    Result.n := 1;
  except
    Result.n := 0;
  end;
end;

// regex_error$(pattern$) - Get error message for invalid pattern
// Returns: Empty string if valid, error message if invalid
function p_regex_error(var Args: Array of TAsmData): TAsmData;
var
  RE: TRegEx;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  //See p_regex_isvalid: an empty pattern is legal but will not compile.
  if Args[0].s = '' then
    Exit();

  try
    RE := TRegEx.Create(Args[0].s);
    //See p_regex_isvalid: compilation only happens on first use.
    RE.IsMatch('');
    Result.s := '';  // Valid pattern
  except
    on E: Exception do
      Result.s := E.Message;
  end;
end;

//------------------------------------------------------------------------------
// Basic Matching Functions
//------------------------------------------------------------------------------

// regex_match(pattern$, text$) - Check if pattern matches anywhere in text
// Returns: 1 if match found, 0 if not
function p_regex_match_2(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    if TRegEx.IsMatch(Args[1].s, Args[0].s) then
      Result.n := 1;
  except
    Result.n := 0;
  end;
end;

// regex_match(pattern$, text$, options) - Match with options
// Returns: 1 if match found, 0 if not
function p_regex_match_3(var Args: Array of TAsmData): TAsmData;
var
  opts: TRegExOptions;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    opts := GetRegExOptions(Round(Args[2].n));
    if TRegEx.IsMatch(Args[1].s, Args[0].s, opts) then
      Result.n := 1;
  except
    Result.n := 0;
  end;
end;

// regex_matchfull(pattern$, text$) - Check if pattern matches entire text
// Returns: 1 if full match, 0 if not
function p_regex_matchfull_2(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    m := TRegEx.Match(Args[1].s, Args[0].s);
    if m.Success and (m.Index = 1) and (m.Length = Length(Args[1].s)) then
      Result.n := 1;
  except
    Result.n := 0;
  end;
end;

// regex_matchfull(pattern$, text$, options) - Full match with options
// Returns: 1 if full match, 0 if not
function p_regex_matchfull_3(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
  opts: TRegExOptions;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    opts := GetRegExOptions(Round(Args[2].n));
    m := TRegEx.Match(Args[1].s, Args[0].s, opts);
    if m.Success and (m.Index = 1) and (m.Length = Length(Args[1].s)) then
      Result.n := 1;
  except
    Result.n := 0;
  end;
end;

//------------------------------------------------------------------------------
// Find/Search Functions
//------------------------------------------------------------------------------

// regex_find$(pattern$, text$) - Find first match
// Returns: Matched string or empty if no match
function p_regex_find_2(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    m := TRegEx.Match(Args[1].s, Args[0].s);
    if m.Success then
      Result.s := m.Value;
  except
    // Return empty string on error
  end;
end;

// regex_find$(pattern$, text$, options) - Find first match with options
// Returns: Matched string or empty if no match
function p_regex_find_3(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
  opts: TRegExOptions;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    opts := GetRegExOptions(Round(Args[2].n));
    m := TRegEx.Match(Args[1].s, Args[0].s, opts);
    if m.Success then
      Result.s := m.Value;
  except
    // Return empty string on error
  end;
end;

// regex_findpos(pattern$, text$) - Find position of first match
// Returns: 1-based position or 0 if no match
function p_regex_findpos_2(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    m := TRegEx.Match(Args[1].s, Args[0].s);
    if m.Success then
      Result.n := m.Index;  // TMatch.Index is already 1-based
  except
    Result.n := 0;
  end;
end;

// regex_findpos(pattern$, text$, options) - Find position with options
// Returns: 1-based position or 0 if no match
function p_regex_findpos_3(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
  opts: TRegExOptions;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    opts := GetRegExOptions(Round(Args[2].n));
    m := TRegEx.Match(Args[1].s, Args[0].s, opts);
    if m.Success then
      Result.n := m.Index;
  except
    Result.n := 0;
  end;
end;

// regex_findlen(pattern$, text$) - Find length of first match
// Returns: Length of match or 0 if no match
function p_regex_findlen_2(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    m := TRegEx.Match(Args[1].s, Args[0].s);
    if m.Success then
      Result.n := m.Length;
  except
    Result.n := 0;
  end;
end;

// regex_findlen(pattern$, text$, options) - Find length with options
// Returns: Length of match or 0 if no match
function p_regex_findlen_3(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
  opts: TRegExOptions;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    opts := GetRegExOptions(Round(Args[2].n));
    m := TRegEx.Match(Args[1].s, Args[0].s, opts);
    if m.Success then
      Result.n := m.Length;
  except
    Result.n := 0;
  end;
end;

//------------------------------------------------------------------------------
// Find All Functions (return TStringList)
//------------------------------------------------------------------------------

// regex_findall#(pattern$, text$) - Find all matches
// Returns: TStringList with all matches (0-based indexing)
function p_regex_findall_2(var Args: Array of TAsmData): TAsmData;
var
  mc: TMatchCollection;
  i: Integer;
  sl: TStringList;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  sl := CreateManagedStringList;
  Result.p := sl;

  try
    mc := TRegEx.Matches(Args[1].s, Args[0].s);
    for i := 0 to mc.Count - 1 do
      sl.Add(mc[i].Value);
  except
    // Return empty list on error
  end;
end;

// regex_findall#(pattern$, text$, options) - Find all with options
// Returns: TStringList with all matches
function p_regex_findall_3(var Args: Array of TAsmData): TAsmData;
var
  mc: TMatchCollection;
  i: Integer;
  sl: TStringList;
  opts: TRegExOptions;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  sl := CreateManagedStringList;
  Result.p := sl;

  try
    opts := GetRegExOptions(Round(Args[2].n));
    mc := TRegEx.Matches(Args[1].s, Args[0].s, opts);
    for i := 0 to mc.Count - 1 do
      sl.Add(mc[i].Value);
  except
    // Return empty list on error
  end;
end;

// regex_count(pattern$, text$) - Count number of matches
// Returns: Number of matches
function p_regex_count_2(var Args: Array of TAsmData): TAsmData;
var
  mc: TMatchCollection;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    mc := TRegEx.Matches(Args[1].s, Args[0].s);
    Result.n := mc.Count;
  except
    Result.n := 0;
  end;
end;

// regex_count(pattern$, text$, options) - Count with options
// Returns: Number of matches
function p_regex_count_3(var Args: Array of TAsmData): TAsmData;
var
  mc: TMatchCollection;
  opts: TRegExOptions;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    opts := GetRegExOptions(Round(Args[2].n));
    mc := TRegEx.Matches(Args[1].s, Args[0].s, opts);
    Result.n := mc.Count;
  except
    Result.n := 0;
  end;
end;

//------------------------------------------------------------------------------
// Replace Functions
//------------------------------------------------------------------------------

// regex_replace$(pattern$, text$, replacement$) - Replace all matches
// Returns: String with all matches replaced
function p_regex_replace_3(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := Args[1].s;  // Return original on error

  try
    Result.s := TRegEx.Replace(Args[1].s, Args[0].s, Args[2].s);
  except
    // Return original text on error
  end;
end;

// regex_replace$(pattern$, text$, replacement$, options) - Replace with options
// Returns: String with all matches replaced
function p_regex_replace_4(var Args: Array of TAsmData): TAsmData;
var
  opts: TRegExOptions;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := Args[1].s;

  try
    opts := GetRegExOptions(Round(Args[3].n));
    Result.s := TRegEx.Replace(Args[1].s, Args[0].s, Args[2].s, opts);
  except
    // Return original text on error
  end;
end;

// regex_replacefirst$(pattern$, text$, replacement$) - Replace first match only
// Returns: String with first match replaced
function p_regex_replacefirst_3(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := Args[1].s;

  try
    m := TRegEx.Match(Args[1].s, Args[0].s);
    if m.Success then
    begin
      Result.s := Copy(Args[1].s, 1, m.Index - 1) +
                  Args[2].s +
                  Copy(Args[1].s, m.Index + m.Length, MaxInt);
    end;
  except
    // Return original text on error
  end;
end;

// regex_replacefirst$(pattern$, text$, replacement$, options) - Replace first with options
// Returns: String with first match replaced
function p_regex_replacefirst_4(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
  opts: TRegExOptions;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := Args[1].s;

  try
    opts := GetRegExOptions(Round(Args[3].n));
    m := TRegEx.Match(Args[1].s, Args[0].s, opts);
    if m.Success then
      Result.s := Copy(Args[1].s, 1, m.Index - 1) + Args[2].s + Copy(Args[1].s, m.Index + m.Length, MaxInt);
  except
    // Return original text on error
  end;
end;

//------------------------------------------------------------------------------
// Split Functions
//------------------------------------------------------------------------------

// regex_split#(pattern$, text$) - Split string by pattern
// Returns: TStringList with split parts
function p_regex_split_2(var Args: Array of TAsmData): TAsmData;
var
  parts: TArray<String>;
  i: Integer;
  sl: TStringList;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  sl := CreateManagedStringList;
  Result.p := sl;

  try
    parts := TRegEx.Split(Args[1].s, Args[0].s);
    for i := 0 to High(parts) do
      sl.Add(parts[i]);
  except
    // Return empty list on error
  end;
end;

// regex_split#(pattern$, text$, options) - Split with options
// Returns: TStringList with split parts
function p_regex_split_3(var Args: Array of TAsmData): TAsmData;
var
  parts: TArray<String>;
  i: Integer;
  sl: TStringList;
  opts: TRegExOptions;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  sl := CreateManagedStringList;
  Result.p := sl;

  try
    opts := GetRegExOptions(Round(Args[2].n));
    parts := TRegEx.Split(Args[1].s, Args[0].s, opts);
    for i := 0 to High(parts) do
      sl.Add(parts[i]);
  except
    // Return empty list on error
  end;
end;

//------------------------------------------------------------------------------
// Group/Capture Functions
//------------------------------------------------------------------------------

// regex_groups#(pattern$, text$) - Get capture groups from first match
// Returns: TStringList with groups (index 0 = full match, 1+ = capture groups)
function p_regex_groups_2(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
  i: Integer;
  sl: TStringList;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  sl := CreateManagedStringList;
  Result.p := sl;

  try
    m := TRegEx.Match(Args[1].s, Args[0].s);
    if m.Success then
    begin
      for i := 0 to m.Groups.Count - 1 do
        sl.Add(m.Groups[i].Value);
    end;
  except
    // Return empty list on error
  end;
end;

// regex_groups#(pattern$, text$, options) - Get groups with options
// Returns: TStringList with groups
function p_regex_groups_3(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
  i: Integer;
  sl: TStringList;
  opts: TRegExOptions;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  sl := CreateManagedStringList;
  Result.p := sl;

  try
    opts := GetRegExOptions(Round(Args[2].n));
    m := TRegEx.Match(Args[1].s, Args[0].s, opts);
    if m.Success then
    begin
      for i := 0 to m.Groups.Count - 1 do
        sl.Add(m.Groups[i].Value);
    end;
  except
    // Return empty list on error
  end;
end;

// regex_group$(pattern$, text$, index) - Get specific group from first match
// Returns: Group value or empty string
function p_regex_group_3(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
  idx: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    idx := Round(Args[2].n);
    m := TRegEx.Match(Args[1].s, Args[0].s);
    if m.Success and (idx >= 0) and (idx < m.Groups.Count) then
      Result.s := m.Groups[idx].Value;
  except
    // Return empty string on error
  end;
end;

// regex_group$(pattern$, text$, index, options) - Get group with options
// Returns: Group value or empty string
function p_regex_group_4(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
  idx: Integer;
  opts: TRegExOptions;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    idx := Round(Args[2].n);
    opts := GetRegExOptions(Round(Args[3].n));
    m := TRegEx.Match(Args[1].s, Args[0].s, opts);
    if m.Success and (idx >= 0) and (idx < m.Groups.Count) then
      Result.s := m.Groups[idx].Value;
  except
    // Return empty string on error
  end;
end;

// regex_groupcount(pattern$, text$) - Count groups in first match
// Returns: Number of groups (including full match at index 0)
function p_regex_groupcount_2(var Args: Array of TAsmData): TAsmData;
var
  m: TMatch;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    m := TRegEx.Match(Args[1].s, Args[0].s);
    if m.Success then
      Result.n := m.Groups.Count;
  except
    Result.n := 0;
  end;
end;

//------------------------------------------------------------------------------
// Utility Functions
//------------------------------------------------------------------------------

// regex_escape$(text$) - Escape special regex characters
// Returns: Escaped string safe for use in patterns
function p_regex_escape(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  Result.s := TRegEx.Escape(Args[0].s);
end;

//------------------------------------------------------------------------------
// Registration
//------------------------------------------------------------------------------

procedure RegisterRegexFuncs(Funcs: TFunctionsDictionary);
var
  Fn: TLinkFunction;
begin
  Fn.FarCall := True;
  //No FireMonkey here, so these run wherever the VM stands.
  Fn.NeedsUIThread := False;

  // Validation functions
  Fn.Entry := @p_regex_isvalid; Funcs.Add('regex_isvalid@$', Fn);
  Fn.Entry := @p_regex_error; Funcs.Add('regex_error$@$', Fn);

  // Basic matching functions
  Fn.Entry := @p_regex_match_2; Funcs.Add('regex_match@$$', Fn);
  Fn.Entry := @p_regex_match_3; Funcs.Add('regex_match@$$n', Fn);
  Fn.Entry := @p_regex_matchfull_2; Funcs.Add('regex_matchfull@$$', Fn);
  Fn.Entry := @p_regex_matchfull_3; Funcs.Add('regex_matchfull@$$n', Fn);

  // Find/search functions
  Fn.Entry := @p_regex_find_2; Funcs.Add('regex_find$@$$', Fn);
  Fn.Entry := @p_regex_find_3; Funcs.Add('regex_find$@$$n', Fn);
  Fn.Entry := @p_regex_findpos_2; Funcs.Add('regex_findpos@$$', Fn);
  Fn.Entry := @p_regex_findpos_3; Funcs.Add('regex_findpos@$$n', Fn);
  Fn.Entry := @p_regex_findlen_2; Funcs.Add('regex_findlen@$$', Fn);
  Fn.Entry := @p_regex_findlen_3; Funcs.Add('regex_findlen@$$n', Fn);

  // Find all functions
  Fn.Entry := @p_regex_findall_2; Funcs.Add('regex_findall#@$$', Fn);
  Fn.Entry := @p_regex_findall_3; Funcs.Add('regex_findall#@$$n', Fn);
  Fn.Entry := @p_regex_count_2; Funcs.Add('regex_count@$$', Fn);
  Fn.Entry := @p_regex_count_3; Funcs.Add('regex_count@$$n', Fn);

  // Replace functions
  Fn.Entry := @p_regex_replace_3; Funcs.Add('regex_replace$@$$$', Fn);
  Fn.Entry := @p_regex_replace_4; Funcs.Add('regex_replace$@$$$n', Fn);
  Fn.Entry := @p_regex_replacefirst_3; Funcs.Add('regex_replacefirst$@$$$', Fn);
  Fn.Entry := @p_regex_replacefirst_4; Funcs.Add('regex_replacefirst$@$$$n', Fn);

  // Split functions
  Fn.Entry := @p_regex_split_2; Funcs.Add('regex_split#@$$', Fn);
  Fn.Entry := @p_regex_split_3; Funcs.Add('regex_split#@$$n', Fn);

  // Group functions
  Fn.Entry := @p_regex_groups_2; Funcs.Add('regex_groups#@$$', Fn);
  Fn.Entry := @p_regex_groups_3; Funcs.Add('regex_groups#@$$n', Fn);
  Fn.Entry := @p_regex_group_3; Funcs.Add('regex_group$@$$n', Fn);
  Fn.Entry := @p_regex_group_4; Funcs.Add('regex_group$@$$nn', Fn);
  Fn.Entry := @p_regex_groupcount_2; Funcs.Add('regex_groupcount@$$', Fn);

  // Utility functions
  Fn.Entry := @p_regex_escape; Funcs.Add('regex_escape$@$', Fn);
end;

end.
