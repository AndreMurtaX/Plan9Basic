unit IOUtilsLib;

{
  IOUtilsLib - I/O Utilities Library for Plan9Basic

  Provides comprehensive file and directory operations based on Delphi's
  System.IOUtils unit (TFile, TDirectory, TPath records).

  This library is designed to be fully cross-platform (Windows, macOS,
  Linux, Android, iOS). Platform-specific features like file attributes
  have been omitted to ensure compatibility.

  Error Handling:
    Use ioerror@ to get the last error code
    Use iostrerror$@ to get a descriptive error message

  Error Codes:
    0 = No error
    1 = File not found
    2 = Directory not found
    3 = Access denied
    4 = Path too long
    5 = Invalid path
    6 = I/O error
    7 = File already exists
    8 = Directory not empty
    9 = Invalid argument
    10 = Unknown error
}

interface

uses
  {$IF Defined(MSWINDOWS)}
  Winapi.Windows,
  {$ENDIF}
  System.SysUtils, System.Types, System.Classes, System.IOUtils,
  System.DateUtils,
  exec, UnitGC;

procedure RegisterIOUtilsFuncs(Lib: TFunctionsDictionary);

implementation

var
  lastError: Integer;  // Error code for last operation (0 = success)

const
  ERR_NONE = 0;
  ERR_FILE_NOT_FOUND = 1;
  ERR_DIR_NOT_FOUND = 2;
  ERR_ACCESS_DENIED = 3;
  ERR_PATH_TOO_LONG = 4;
  ERR_INVALID_PATH = 5;
  ERR_IO_ERROR = 6;
  ERR_FILE_EXISTS = 7;
  ERR_DIR_NOT_EMPTY = 8;
  ERR_INVALID_ARGUMENT = 9;
  ERR_UNKNOWN = 10;

//==============================================================================
// Helper Functions
//==============================================================================

// Convert exception to error code
procedure SetErrorFromException(E: Exception);
begin
  if E is EFileNotFoundException then
    lastError := ERR_FILE_NOT_FOUND
  else if E is EDirectoryNotFoundException then
    lastError := ERR_DIR_NOT_FOUND
  else if E is EInOutError then
    lastError := ERR_IO_ERROR
  else if E is EPathTooLongException then
    lastError := ERR_PATH_TOO_LONG
  else if E is EArgumentException then
    lastError := ERR_INVALID_ARGUMENT
  else
    lastError := ERR_UNKNOWN;
end;

// Converts encoding name string to TEncoding object
// Supported names: utf8, utf7, ascii, ansi, unicode, unicode-be
// Default: UTF-8 (for maximum compatibility)
function ParseEncoding(const EncodingName: String): TEncoding;
var
  LowerName: String;
begin
  LowerName := EncodingName.ToLower().Trim();

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

//==============================================================================
// Error Handling
//==============================================================================

// ioerror@ - Returns the last error code
function n_ioerror(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := lastError;
end;

// iostrerror$@ - Returns descriptive error message for last error
function s_iostrerror(var Args: Array of TAsmData): TAsmData;
begin
  case lastError of
    ERR_NONE: Result.s := 'No error';
    ERR_FILE_NOT_FOUND: Result.s := 'File not found';
    ERR_DIR_NOT_FOUND: Result.s := 'Directory not found';
    ERR_ACCESS_DENIED: Result.s := 'Access denied';
    ERR_PATH_TOO_LONG: Result.s := 'Path too long';
    ERR_INVALID_PATH: Result.s := 'Invalid path';
    ERR_IO_ERROR: Result.s := 'I/O error';
    ERR_FILE_EXISTS: Result.s := 'File already exists';
    ERR_DIR_NOT_EMPTY: Result.s := 'Directory not empty';
    ERR_INVALID_ARGUMENT: Result.s := 'Invalid argument';
    ERR_UNKNOWN: Result.s := 'Unknown error';
  else
    Result.s := 'Unknown error code: ' + IntToStr(lastError);
  end;
end;

//==============================================================================
// TFile Functions - File Operations
//==============================================================================

// file_readalltext$(path$) - Read entire file as text (UTF-8)
function s_file_readalltext(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Result.s := TFile.ReadAllText(Args[0].s, TEncoding.UTF8);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_readalltext$(path$, encoding$) - Read entire file with specified encoding
function s_file_readalltext_enc(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Result.s := TFile.ReadAllText(Args[0].s, ParseEncoding(Args[1].s));
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_writealltext(path$, content$) - Write text to file (UTF-8)
function n_file_writealltext(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TFile.WriteAllText(Args[0].s, Args[1].s, TEncoding.UTF8);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_writealltext(path$, content$, encoding$) - Write with encoding
function n_file_writealltext_enc(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TFile.WriteAllText(Args[0].s, Args[1].s, ParseEncoding(Args[2].s));
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_appendalltext(path$, content$) - Append text to file (UTF-8)
function n_file_appendalltext(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TFile.AppendAllText(Args[0].s, Args[1].s, TEncoding.UTF8);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_appendalltext(path$, content$, encoding$) - Append with encoding
function n_file_appendalltext_enc(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TFile.AppendAllText(Args[0].s, Args[1].s, ParseEncoding(Args[2].s));
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_readallbytes#(path$) - Read entire file as byte array (returns TMemoryStream pointer)
function p_file_readallbytes(var Args: Array of TAsmData): TAsmData;
var
  Bytes: TBytes;
  Stream: TMemoryStream;
begin
  lastError := ERR_NONE;
  Result.p := nil;
  try
    Bytes := TFile.ReadAllBytes(Args[0].s);
    Stream := TMemoryStream.Create;
    if Length(Bytes) > 0 then
      Stream.WriteBuffer(Bytes[0], Length(Bytes));
    Stream.Position := 0;
    Result.p := Stream;
    GC.Add(Result.p);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_writeallbytes(path$, stream#) - Write byte array to file
function n_file_writeallbytes(var Args: Array of TAsmData): TAsmData;
var
  Stream: TMemoryStream;
  Bytes: TBytes;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    Stream := TMemoryStream(Args[1].p);
    if Assigned(Stream) then
    begin
      SetLength(Bytes, Stream.Size);
      Stream.Position := 0;
      if Stream.Size > 0 then
        Stream.ReadBuffer(Bytes[0], Stream.Size);
      TFile.WriteAllBytes(Args[0].s, Bytes);
      Result.n := 1;
    end
    else
      lastError := ERR_INVALID_ARGUMENT;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_copy(source$, dest$) - Copy file (don't overwrite)
function n_file_copy(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TFile.Copy(Args[0].s, Args[1].s);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_copy(source$, dest$, overwrite) - Copy file with overwrite option
function n_file_copy_ow(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TFile.Copy(Args[0].s, Args[1].s, Args[2].n <> 0);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_move(source$, dest$) - Move/rename file
function n_file_move(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TFile.Move(Args[0].s, Args[1].s);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_delete(path$) - Delete file
function n_file_delete(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TFile.Delete(Args[0].s);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_exists(path$) - Check if file exists
function n_file_exists(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    if TFile.Exists(Args[0].s) then
      Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_getsize(path$) - Get file size in bytes
function n_file_getsize(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    Result.n := TFile.GetSize(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_getcreationtime(path$) - Get file creation time as TDateTime
function n_file_getcreationtime(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    Result.n := TFile.GetCreationTime(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_getlastaccesstime(path$) - Get last access time
function n_file_getlastaccesstime(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    Result.n := TFile.GetLastAccessTime(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_getlastwritetime(path$) - Get last modification time
function n_file_getlastwritetime(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    Result.n := TFile.GetLastWriteTime(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_setcreationtime(path$, datetime) - Set creation time
function n_file_setcreationtime(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TFile.SetCreationTime(Args[0].s, Args[1].n);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_setlastaccesstime(path$, datetime) - Set last access time
function n_file_setlastaccesstime(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TFile.SetLastAccessTime(Args[0].s, Args[1].n);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_setlastwritetime(path$, datetime) - Set last modification time
function n_file_setlastwritetime(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TFile.SetLastWriteTime(Args[0].s, Args[1].n);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// file_createempty(path$) - Create empty file or update timestamp
function n_file_createempty(var Args: Array of TAsmData): TAsmData;
var
  FS: TFileStream;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    if TFile.Exists(Args[0].s) then
      TFile.SetLastWriteTime(Args[0].s, Now)
    else
    begin
      FS := TFileStream.Create(Args[0].s, fmCreate);
      try
        // File created empty
      finally
        FS.Free;
      end;
    end;
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

//==============================================================================
// TDirectory Functions - Directory Operations
//==============================================================================

// dir_create(path$) - Create directory
function n_dir_create(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TDirectory.CreateDirectory(Args[0].s);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_delete(path$) - Delete empty directory
function n_dir_delete(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TDirectory.Delete(Args[0].s);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_delete(path$, recursive) - Delete directory with recursive option
function n_dir_delete_rec(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TDirectory.Delete(Args[0].s, Args[1].n <> 0);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_exists(path$) - Check if directory exists
function n_dir_exists(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    if TDirectory.Exists(Args[0].s) then
      Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_move(source$, dest$) - Move/rename directory
function n_dir_move(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TDirectory.Move(Args[0].s, Args[1].s);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_copy(source$, dest$) - Copy directory recursively
function n_dir_copy(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TDirectory.Copy(Args[0].s, Args[1].s);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_getfiles$(path$) - Get files in directory (CRLF separated)
function s_dir_getfiles(var Args: Array of TAsmData): TAsmData;
var
  Files: TStringDynArray;
  i: Integer;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Files := TDirectory.GetFiles(Args[0].s);
    for i := 0 to High(Files) do
    begin
      if i > 0 then
        Result.s := Result.s + #13#10;
      Result.s := Result.s + Files[i];
    end;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_getfiles$(path$, pattern$) - Get files matching pattern
function s_dir_getfiles_pattern(var Args: Array of TAsmData): TAsmData;
var
  Files: TStringDynArray;
  i: Integer;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Files := TDirectory.GetFiles(Args[0].s, Args[1].s);
    for i := 0 to High(Files) do
    begin
      if i > 0 then
        Result.s := Result.s + #13#10;
      Result.s := Result.s + Files[i];
    end;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_getfiles$(path$, pattern$, recursive) - Get files with search option
function s_dir_getfiles_rec(var Args: Array of TAsmData): TAsmData;
var
  Files: TStringDynArray;
  i: Integer;
  SearchOpt: TSearchOption;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    if Args[2].n <> 0 then
      SearchOpt := TSearchOption.soAllDirectories
    else
      SearchOpt := TSearchOption.soTopDirectoryOnly;
    Files := TDirectory.GetFiles(Args[0].s, Args[1].s, SearchOpt);
    for i := 0 to High(Files) do
    begin
      if i > 0 then
        Result.s := Result.s + #13#10;
      Result.s := Result.s + Files[i];
    end;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_getdirectories$(path$) - Get subdirectories (CRLF separated)
function s_dir_getdirectories(var Args: Array of TAsmData): TAsmData;
var
  Dirs: TStringDynArray;
  i: Integer;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Dirs := TDirectory.GetDirectories(Args[0].s);
    for i := 0 to High(Dirs) do
    begin
      if i > 0 then
        Result.s := Result.s + #13#10;
      Result.s := Result.s + Dirs[i];
    end;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_getdirectories$(path$, pattern$) - Get subdirectories matching pattern
function s_dir_getdirectories_pattern(var Args: Array of TAsmData): TAsmData;
var
  Dirs: TStringDynArray;
  i: Integer;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Dirs := TDirectory.GetDirectories(Args[0].s, Args[1].s);
    for i := 0 to High(Dirs) do
    begin
      if i > 0 then
        Result.s := Result.s + #13#10;
      Result.s := Result.s + Dirs[i];
    end;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_getdirectories$(path$, pattern$, recursive) - Get subdirectories with search option
function s_dir_getdirectories_rec(var Args: Array of TAsmData): TAsmData;
var
  Dirs: TStringDynArray;
  i: Integer;
  SearchOpt: TSearchOption;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    if Args[2].n <> 0 then
      SearchOpt := TSearchOption.soAllDirectories
    else
      SearchOpt := TSearchOption.soTopDirectoryOnly;
    Dirs := TDirectory.GetDirectories(Args[0].s, Args[1].s, SearchOpt);
    for i := 0 to High(Dirs) do
    begin
      if i > 0 then
        Result.s := Result.s + #13#10;
      Result.s := Result.s + Dirs[i];
    end;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_getfilesystementries$(path$) - Get all files and directories
function s_dir_getfilesystementries(var Args: Array of TAsmData): TAsmData;
var
  Entries: TStringDynArray;
  i: Integer;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Entries := TDirectory.GetFileSystemEntries(Args[0].s);
    for i := 0 to High(Entries) do
    begin
      if i > 0 then
        Result.s := Result.s + #13#10;
      Result.s := Result.s + Entries[i];
    end;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_getfilesystementries$(path$, pattern$) - Get entries matching pattern
function s_dir_getfilesystementries_pattern(var Args: Array of TAsmData): TAsmData;
var
  Entries: TStringDynArray;
  i: Integer;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Entries := TDirectory.GetFileSystemEntries(Args[0].s, Args[1].s);
    for i := 0 to High(Entries) do
    begin
      if i > 0 then
        Result.s := Result.s + #13#10;
      Result.s := Result.s + Entries[i];
    end;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_getcreationtime(path$) - Get directory creation time
function n_dir_getcreationtime(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    Result.n := TDirectory.GetCreationTime(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_getlastaccesstime(path$) - Get directory last access time
function n_dir_getlastaccesstime(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    Result.n := TDirectory.GetLastAccessTime(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_getlastwritetime(path$) - Get directory last modification time
function n_dir_getlastwritetime(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    Result.n := TDirectory.GetLastWriteTime(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_setcreationtime(path$, datetime) - Set directory creation time
function n_dir_setcreationtime(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TDirectory.SetCreationTime(Args[0].s, Args[1].n);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_setlastaccesstime(path$, datetime) - Set directory last access time
function n_dir_setlastaccesstime(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TDirectory.SetLastAccessTime(Args[0].s, Args[1].n);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_setlastwritetime(path$, datetime) - Set directory last modification time
function n_dir_setlastwritetime(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TDirectory.SetLastWriteTime(Args[0].s, Args[1].n);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_getparent$(path$) - Get parent directory path
function s_dir_getparent(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Result.s := TDirectory.GetParent(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_getcurrent$() - Get current working directory
function s_dir_getcurrent(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Result.s := TDirectory.GetCurrentDirectory();
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_setcurrent(path$) - Set current working directory
function n_dir_setcurrent(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    TDirectory.SetCurrentDirectory(Args[0].s);
    Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_isempty(path$) - Check if directory is empty
function n_dir_isempty(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    if TDirectory.IsEmpty(Args[0].s) then
      Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// dir_isrelativepath(path$) - Check if path is relative
function n_dir_isrelativepath(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    if TDirectory.IsRelativePath(Args[0].s) then
      Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

//==============================================================================
// TPath Functions - Path Manipulation (Cross-Platform)
//==============================================================================

// path_combine$(path1$, path2$) - Combine two path segments
function s_path_combine(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Result.s := TPath.Combine(Args[0].s, Args[1].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_combine$(path1$, path2$, path3$) - Combine three path segments
function s_path_combine3(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Result.s := TPath.Combine(TPath.Combine(Args[0].s, Args[1].s), Args[2].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_getdirectoryname$(path$) - Get directory portion of path
function s_path_getdirectoryname(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Result.s := TPath.GetDirectoryName(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_getfilename$(path$) - Get filename with extension from path
function s_path_getfilename(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Result.s := TPath.GetFileName(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_getfilenamewithoutextension$(path$) - Get filename without extension
function s_path_getfilenamewithoutextension(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Result.s := TPath.GetFileNameWithoutExtension(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_getextension$(path$) - Get file extension (including dot)
function s_path_getextension(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Result.s := TPath.GetExtension(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_changeextension$(path$, newext$) - Change file extension
function s_path_changeextension(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Result.s := TPath.ChangeExtension(Args[0].s, Args[1].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_hasextension(path$) - Check if path has extension
function n_path_hasextension(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    if TPath.HasExtension(Args[0].s) then
      Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_getfullpath$(path$) - Get full/absolute path
function s_path_getfullpath(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Result.s := TPath.GetFullPath(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_ispathrooted(path$) - Check if path is rooted/absolute
function n_path_ispathrooted(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    if TPath.IsPathRooted(Args[0].s) then
      Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_getpathroot$(path$) - Get root portion of path
function s_path_getpathroot(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  try
    Result.s := TPath.GetPathRoot(Args[0].s);
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_matchespattern(path$, pattern$) - Check if path matches pattern
function n_path_matchespattern(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    if TPath.MatchesPattern(Args[0].s, Args[1].s, False) then
      Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_matchespattern(path$, pattern$, casesensitive) - Match with case option
function n_path_matchespattern_cs(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    if TPath.MatchesPattern(Args[0].s, Args[1].s, Args[2].n <> 0) then
      Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_hasvalidpathchars(path$) - Check if path has valid characters
function n_path_hasvalidpathchars(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    if TPath.HasValidPathChars(Args[0].s, False) then
      Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_hasvalidfilenamechars(filename$) - Check if filename has valid characters
function n_path_hasvalidfilenamechars(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    if TPath.HasValidFileNameChars(Args[0].s, False) then
      Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

// path_isrelativepath(path$) - Check if path is relative
function n_path_isrelativepath(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  try
    if TPath.IsRelativePath(Args[0].s) then
      Result.n := 1;
  except
    on E: Exception do SetErrorFromException(E);
  end;
end;

//==============================================================================
// Registration
//==============================================================================

procedure RegisterIOUtilsFuncs(Lib: TFunctionsDictionary);
var
  FnData: TLinkFunction;
begin
  FnData.FarCall := True;

  // Error handling
  FnData.Entry := n_ioerror; Lib.Add('ioerror@', FnData);
  FnData.Entry := s_iostrerror; Lib.Add('iostrerror$@', FnData);

  // TFile functions
  FnData.Entry := s_file_readalltext; Lib.Add('file_readalltext$@$', FnData);
  FnData.Entry := s_file_readalltext_enc; Lib.Add('file_readalltext$@$$', FnData);
  FnData.Entry := n_file_writealltext; Lib.Add('file_writealltext@$$', FnData);
  FnData.Entry := n_file_writealltext_enc; Lib.Add('file_writealltext@$$$', FnData);
  FnData.Entry := n_file_appendalltext; Lib.Add('file_appendalltext@$$', FnData);
  FnData.Entry := n_file_appendalltext_enc; Lib.Add('file_appendalltext@$$$', FnData);
  FnData.Entry := p_file_readallbytes; Lib.Add('file_readallbytes#@$', FnData);
  FnData.Entry := n_file_writeallbytes; Lib.Add('file_writeallbytes@$#', FnData);
  FnData.Entry := n_file_copy; Lib.Add('file_copy@$$', FnData);
  FnData.Entry := n_file_copy_ow; Lib.Add('file_copy@$$n', FnData);
  FnData.Entry := n_file_move; Lib.Add('file_move@$$', FnData);
  FnData.Entry := n_file_delete; Lib.Add('file_delete@$', FnData);
  FnData.Entry := n_file_exists; Lib.Add('file_exists@$', FnData);
  FnData.Entry := n_file_getsize; Lib.Add('file_getsize@$', FnData);
  FnData.Entry := n_file_getcreationtime; Lib.Add('file_getcreationtime@$', FnData);
  FnData.Entry := n_file_getlastaccesstime; Lib.Add('file_getlastaccesstime@$', FnData);
  FnData.Entry := n_file_getlastwritetime; Lib.Add('file_getlastwritetime@$', FnData);
  FnData.Entry := n_file_setcreationtime; Lib.Add('file_setcreationtime@$n', FnData);
  FnData.Entry := n_file_setlastaccesstime; Lib.Add('file_setlastaccesstime@$n', FnData);
  FnData.Entry := n_file_setlastwritetime; Lib.Add('file_setlastwritetime@$n', FnData);
  FnData.Entry := n_file_createempty; Lib.Add('file_createempty@$', FnData);

  // TDirectory functions
  FnData.Entry := n_dir_create; Lib.Add('dir_create@$', FnData);
  FnData.Entry := n_dir_delete; Lib.Add('dir_delete@$', FnData);
  FnData.Entry := n_dir_delete_rec; Lib.Add('dir_delete@$n', FnData);
  FnData.Entry := n_dir_exists; Lib.Add('dir_exists@$', FnData);
  FnData.Entry := n_dir_move; Lib.Add('dir_move@$$', FnData);
  FnData.Entry := n_dir_copy; Lib.Add('dir_copy@$$', FnData);
  FnData.Entry := s_dir_getfiles; Lib.Add('dir_getfiles$@$', FnData);
  FnData.Entry := s_dir_getfiles_pattern; Lib.Add('dir_getfiles$@$$', FnData);
  FnData.Entry := s_dir_getfiles_rec; Lib.Add('dir_getfiles$@$$n', FnData);
  FnData.Entry := s_dir_getdirectories; Lib.Add('dir_getdirectories$@$', FnData);
  FnData.Entry := s_dir_getdirectories_pattern; Lib.Add('dir_getdirectories$@$$', FnData);
  FnData.Entry := s_dir_getdirectories_rec; Lib.Add('dir_getdirectories$@$$n', FnData);
  FnData.Entry := s_dir_getfilesystementries; Lib.Add('dir_getentries$@$', FnData);
  FnData.Entry := s_dir_getfilesystementries_pattern; Lib.Add('dir_getentries$@$$', FnData);
  FnData.Entry := n_dir_getcreationtime; Lib.Add('dir_getcreationtime@$', FnData);
  FnData.Entry := n_dir_getlastaccesstime; Lib.Add('dir_getlastaccesstime@$', FnData);
  FnData.Entry := n_dir_getlastwritetime; Lib.Add('dir_getlastwritetime@$', FnData);
  FnData.Entry := n_dir_setcreationtime; Lib.Add('dir_setcreationtime@$n', FnData);
  FnData.Entry := n_dir_setlastaccesstime; Lib.Add('dir_setlastaccesstime@$n', FnData);
  FnData.Entry := n_dir_setlastwritetime; Lib.Add('dir_setlastwritetime@$n', FnData);
  FnData.Entry := s_dir_getparent; Lib.Add('dir_getparent$@$', FnData);
  FnData.Entry := s_dir_getcurrent; Lib.Add('dir_getcurrent$@', FnData);
  FnData.Entry := n_dir_setcurrent; Lib.Add('dir_setcurrent@$', FnData);
  FnData.Entry := n_dir_isempty; Lib.Add('dir_isempty@$', FnData);
  FnData.Entry := n_dir_isrelativepath; Lib.Add('dir_isrelativepath@$', FnData);

  // TPath functions (cross-platform)
  FnData.Entry := s_path_combine; Lib.Add('path_combine$@$$', FnData);
  FnData.Entry := s_path_combine3; Lib.Add('path_combine$@$$$', FnData);
  FnData.Entry := s_path_getdirectoryname; Lib.Add('path_getdirectoryname$@$', FnData);
  FnData.Entry := s_path_getfilename; Lib.Add('path_getfilename$@$', FnData);
  FnData.Entry := s_path_getfilenamewithoutextension; Lib.Add('path_getfilenamenoext$@$', FnData);
  FnData.Entry := s_path_getextension; Lib.Add('path_getextension$@$', FnData);
  FnData.Entry := s_path_changeextension; Lib.Add('path_changeextension$@$$', FnData);
  FnData.Entry := n_path_hasextension; Lib.Add('path_hasextension@$', FnData);
  FnData.Entry := s_path_getfullpath; Lib.Add('path_getfullpath$@$', FnData);
  FnData.Entry := n_path_ispathrooted; Lib.Add('path_ispathrooted@$', FnData);
  FnData.Entry := s_path_getpathroot; Lib.Add('path_getpathroot$@$', FnData);
  FnData.Entry := n_path_matchespattern; Lib.Add('path_matchespattern@$$', FnData);
  FnData.Entry := n_path_matchespattern_cs; Lib.Add('path_matchespattern@$$n', FnData);
  FnData.Entry := n_path_hasvalidpathchars; Lib.Add('path_hasvalidpathchars@$', FnData);
  FnData.Entry := n_path_hasvalidfilenamechars; Lib.Add('path_hasvalidfilenamechars@$', FnData);
  FnData.Entry := n_path_isrelativepath; Lib.Add('path_isrelativepath@$', FnData);
end;

end.

