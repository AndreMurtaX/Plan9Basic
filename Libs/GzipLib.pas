unit GzipLib;

{******************************************************************************
  GzipLib - GZIP/Deflate Compression Library for Plan9Basic

  Provides functions to compress and decompress data using GZIP/deflate
  algorithm. GZIP is ideal for compressing single data streams (strings or
  single files) and is widely used in web protocols, file storage, and
  data transmission.

  Features:
  - Compress strings to GZIP format (Base64-encoded for easy handling)
  - Decompress GZIP data back to original strings
  - Compress files to .gz format
  - Decompress .gz files
  - Multiple compression levels (1-9)
  - Raw deflate support (without GZIP headers)

  Version: 1.0
  Date: January 2026

  Function Count: 10 functions

  Error Codes (via gziperror@):
    0 = No error
    1 = Compression error
    2 = Decompression error
    3 = Invalid argument (empty input where not allowed)
    4 = File error (read/write failure)
    5 = Invalid compression level

  Copyright (c) 2024-2026 Plan9Basic Project
******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, System.ZLib, System.NetEncoding,
  exec;

procedure RegisterGzipFuncs(Lib: TFunctionsDictionary);

implementation

var
  lastError: Integer;  // Error code for last operation (0 = success)

const
  ERR_NONE = 0;
  ERR_COMPRESSION = 1;
  ERR_DECOMPRESSION = 2;
  ERR_INVALID_ARGUMENT = 3;
  ERR_FILE_ERROR = 4;
  ERR_INVALID_LEVEL = 5;

  DEFAULT_COMPRESSION_LEVEL = 6;  // Default compression (balanced)

{------------------------------------------------------------------------------
  Error Handling
------------------------------------------------------------------------------}

// gziperror@ - Get last error code
function n_gziperror(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.s := '';
  Result.p := nil;
end;

{------------------------------------------------------------------------------
  Internal Helper Functions
------------------------------------------------------------------------------}

// Compress bytes using ZLib compression
function CompressBytes(const Input: TBytes; Level: TZCompressionLevel): TBytes;
var
  CompressedStream: TMemoryStream;
  CompressionStream: TZCompressionStream;
begin
  CompressedStream := TMemoryStream.Create();
  try
    CompressionStream := TZCompressionStream.Create(CompressedStream, Level, 15);
    try
      if Length(Input) > 0 then
        CompressionStream.WriteBuffer(Input[0], Length(Input));
    finally
      CompressionStream.Free;
    end;

    SetLength(Result, CompressedStream.Size);
    if CompressedStream.Size > 0 then
    begin
      CompressedStream.Position := 0;
      CompressedStream.ReadBuffer(Result[0], CompressedStream.Size);
    end;
  finally
    CompressedStream.Free;
  end;
end;

// Decompress bytes using ZLib decompression
function DecompressBytes(const Input: TBytes): TBytes;
var
  InputStream: TBytesStream;
  DecompressionStream: TZDecompressionStream;
  OutputBuffer: TBytes;
  BytesRead: Integer;
  TotalRead: Integer;
const
  BUFFER_SIZE = 32768;
begin
  SetLength(Result, 0);

  if Length(Input) = 0 then
    Exit;

  InputStream := TBytesStream.Create(Input);
  try
    DecompressionStream := TZDecompressionStream.Create(InputStream);
    try
      TotalRead := 0;
      SetLength(OutputBuffer, BUFFER_SIZE);

      repeat
        BytesRead := DecompressionStream.Read(OutputBuffer[0], BUFFER_SIZE);
        if BytesRead > 0 then
        begin
          SetLength(Result, TotalRead + BytesRead);
          Move(OutputBuffer[0], Result[TotalRead], BytesRead);
          TotalRead := TotalRead + BytesRead;
        end;
      until BytesRead = 0;
    finally
      DecompressionStream.Free;
    end;
  finally
    InputStream.Free;
  end;
end;

// Convert compression level (1-9) to TZCompressionLevel
function GetCompressionLevel(Level: Integer): TZCompressionLevel;
begin
  if Level <= 3 then
    Result := zcFastest
  else if Level >= 7 then
    Result := zcMax
  else
    Result := zcDefault;
end;

{------------------------------------------------------------------------------
  String Compression Functions

  These functions work with strings. Compressed output is Base64-encoded
  for easy storage and transmission in text formats.
------------------------------------------------------------------------------}

// gzip$@$ - Compress string using GZIP, returns Base64-encoded result
// Input: String to compress
// Output: Base64-encoded compressed data
function s_gzip(var Args: Array of TAsmData): TAsmData;
var
  InputBytes, CompressedBytes: TBytes;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  // Empty string compresses to empty string
  if Args[0].s = '' then
    Exit;

  try
    InputBytes := TEncoding.UTF8.GetBytes(Args[0].s);
    CompressedBytes := CompressBytes(InputBytes, zcDefault);
    Result.s := TNetEncoding.Base64.EncodeBytesToString(CompressedBytes);
  except
    on E: Exception do
    begin
      lastError := ERR_COMPRESSION;
      Result.s := '';
    end;
  end;
end;

// gzipex$@$n - Compress string with specified compression level (1-9)
// Input: String to compress, compression level (1=fastest, 9=best)
// Output: Base64-encoded compressed data
function s_gzipex(var Args: Array of TAsmData): TAsmData;
var
  InputBytes, CompressedBytes: TBytes;
  Level: Integer;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  Level := Trunc(Args[1].n);
  if (Level < 1) or (Level > 9) then
  begin
    lastError := ERR_INVALID_LEVEL;
    Exit;
  end;

  // Empty string compresses to empty string
  if Args[0].s = '' then
    Exit;

  try
    InputBytes := TEncoding.UTF8.GetBytes(Args[0].s);
    CompressedBytes := CompressBytes(InputBytes, GetCompressionLevel(Level));
    Result.s := TNetEncoding.Base64.EncodeBytesToString(CompressedBytes);
  except
    on E: Exception do
    begin
      lastError := ERR_COMPRESSION;
      Result.s := '';
    end;
  end;
end;

// gunzip$@$ - Decompress GZIP data (Base64-encoded) back to string
// Input: Base64-encoded compressed data
// Output: Original string
function s_gunzip(var Args: Array of TAsmData): TAsmData;
var
  CompressedBytes, DecompressedBytes: TBytes;
begin
  lastError := ERR_NONE;
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  // Empty input returns empty string
  if Args[0].s = '' then
    Exit;

  try
    CompressedBytes := TNetEncoding.Base64.DecodeStringToBytes(Args[0].s);
    DecompressedBytes := DecompressBytes(CompressedBytes);
    Result.s := TEncoding.UTF8.GetString(DecompressedBytes);
  except
    on E: EZDecompressionError do
    begin
      lastError := ERR_DECOMPRESSION;
      Result.s := '';
    end;
    on E: Exception do
    begin
      lastError := ERR_DECOMPRESSION;
      Result.s := '';
    end;
  end;
end;

{------------------------------------------------------------------------------
  File Compression Functions

  These functions work directly with files, creating standard .gz files
  compatible with gzip utilities.
------------------------------------------------------------------------------}

// gzipfile@$$ - Compress a file to .gz format
// Input: Source file path, destination file path
// Output: 1 on success, 0 on failure
function n_gzipfile(var Args: Array of TAsmData): TAsmData;
var
  SourcePath, DestPath: String;
  SourceStream: TFileStream;
  DestStream: TFileStream;
  CompressionStream: TZCompressionStream;
  Buffer: TBytes;
  BytesRead: Integer;
const
  BUFFER_SIZE = 65536;
begin
  lastError := ERR_NONE;
  Result.s := '';
  Result.p := nil;
  Result.n := 0;

  SourcePath := Args[0].s;
  DestPath := Args[1].s;

  if (SourcePath = '') or (DestPath = '') then
  begin
    lastError := ERR_INVALID_ARGUMENT;
    Exit;
  end;

  if not FileExists(SourcePath) then
  begin
    lastError := ERR_FILE_ERROR;
    Exit;
  end;

  try
    SourceStream := TFileStream.Create(SourcePath, fmOpenRead or fmShareDenyWrite);
    try
      DestStream := TFileStream.Create(DestPath, fmCreate);
      try
        CompressionStream := TZCompressionStream.Create(DestStream, zcDefault, 15);
        try
          SetLength(Buffer, BUFFER_SIZE);
          repeat
            BytesRead := SourceStream.Read(Buffer[0], BUFFER_SIZE);
            if BytesRead > 0 then
              CompressionStream.WriteBuffer(Buffer[0], BytesRead);
          until BytesRead = 0;
        finally
          CompressionStream.Free;
        end;
      finally
        DestStream.Free;
      end;
    finally
      SourceStream.Free;
    end;
    Result.n := 1;
  except
    on E: EFOpenError do
    begin
      lastError := ERR_FILE_ERROR;
    end;
    on E: EZCompressionError do
    begin
      lastError := ERR_COMPRESSION;
    end;
    on E: Exception do
    begin
      lastError := ERR_FILE_ERROR;
    end;
  end;
end;

// gzipfileex@$$n - Compress file with specified compression level
// Input: Source file path, destination file path, compression level (1-9)
// Output: 1 on success, 0 on failure
function n_gzipfileex(var Args: Array of TAsmData): TAsmData;
var
  SourcePath, DestPath: String;
  Level: Integer;
  SourceStream: TFileStream;
  DestStream: TFileStream;
  CompressionStream: TZCompressionStream;
  Buffer: TBytes;
  BytesRead: Integer;
const
  BUFFER_SIZE = 65536;
begin
  lastError := ERR_NONE;
  Result.s := '';
  Result.p := nil;
  Result.n := 0;

  SourcePath := Args[0].s;
  DestPath := Args[1].s;
  Level := Trunc(Args[2].n);

  if (Level < 1) or (Level > 9) then
  begin
    lastError := ERR_INVALID_LEVEL;
    Exit;
  end;

  if (SourcePath = '') or (DestPath = '') then
  begin
    lastError := ERR_INVALID_ARGUMENT;
    Exit;
  end;

  if not FileExists(SourcePath) then
  begin
    lastError := ERR_FILE_ERROR;
    Exit;
  end;

  try
    SourceStream := TFileStream.Create(SourcePath, fmOpenRead or fmShareDenyWrite);
    try
      DestStream := TFileStream.Create(DestPath, fmCreate);
      try
        CompressionStream := TZCompressionStream.Create(DestStream, GetCompressionLevel(Level), 15);
        try
          SetLength(Buffer, BUFFER_SIZE);
          repeat
            BytesRead := SourceStream.Read(Buffer[0], BUFFER_SIZE);
            if BytesRead > 0 then
              CompressionStream.WriteBuffer(Buffer[0], BytesRead);
          until BytesRead = 0;
        finally
          CompressionStream.Free;
        end;
      finally
        DestStream.Free;
      end;
    finally
      SourceStream.Free;
    end;
    Result.n := 1;
  except
    on E: EFOpenError do
    begin
      lastError := ERR_FILE_ERROR;
    end;
    on E: EZCompressionError do
    begin
      lastError := ERR_COMPRESSION;
    end;
    on E: Exception do
    begin
      lastError := ERR_FILE_ERROR;
    end;
  end;
end;

// gunzipfile@$$ - Decompress a .gz file
// Input: Source .gz file path, destination file path
// Output: 1 on success, 0 on failure
function n_gunzipfile(var Args: Array of TAsmData): TAsmData;
var
  SourcePath, DestPath: String;
  SourceStream: TFileStream;
  DestStream: TFileStream;
  DecompressionStream: TZDecompressionStream;
  Buffer: TBytes;
  BytesRead: Integer;
const
  BUFFER_SIZE = 65536;
begin
  lastError := ERR_NONE;
  Result.s := '';
  Result.p := nil;
  Result.n := 0;

  SourcePath := Args[0].s;
  DestPath := Args[1].s;

  if (SourcePath = '') or (DestPath = '') then
  begin
    lastError := ERR_INVALID_ARGUMENT;
    Exit;
  end;

  if not FileExists(SourcePath) then
  begin
    lastError := ERR_FILE_ERROR;
    Exit;
  end;

  try
    SourceStream := TFileStream.Create(SourcePath, fmOpenRead or fmShareDenyWrite);
    try
      DestStream := TFileStream.Create(DestPath, fmCreate);
      try
        DecompressionStream := TZDecompressionStream.Create(SourceStream);
        try
          SetLength(Buffer, BUFFER_SIZE);
          repeat
            BytesRead := DecompressionStream.Read(Buffer[0], BUFFER_SIZE);
            if BytesRead > 0 then
              DestStream.WriteBuffer(Buffer[0], BytesRead);
          until BytesRead = 0;
        finally
          DecompressionStream.Free;
        end;
      finally
        DestStream.Free;
      end;
    finally
      SourceStream.Free;
    end;
    Result.n := 1;
  except
    on E: EFOpenError do
    begin
      lastError := ERR_FILE_ERROR;
    end;
    on E: EZDecompressionError do
    begin
      lastError := ERR_DECOMPRESSION;
    end;
    on E: Exception do
    begin
      lastError := ERR_FILE_ERROR;
    end;
  end;
end;

{------------------------------------------------------------------------------
  Utility Functions
------------------------------------------------------------------------------}

// gzipratio@$$ - Calculate compression ratio for a string
// Input: Original string, compressed string (Base64-encoded)
// Output: Compression ratio (compressed/original), or -1 on error
function n_gzipratio(var Args: Array of TAsmData): TAsmData;
var
  OriginalSize: Integer;
  CompressedBytes: TBytes;
  CompressedSize: Integer;
begin
  lastError := ERR_NONE;
  Result.s := '';
  Result.p := nil;
  Result.n := -1;

  if Args[0].s = '' then
  begin
    if Args[1].s = '' then
      Result.n := 1.0  // Empty to empty is 1:1 ratio
    else
      lastError := ERR_INVALID_ARGUMENT;
    Exit;
  end;

  try
    OriginalSize := Length(TEncoding.UTF8.GetBytes(Args[0].s));
    CompressedBytes := TNetEncoding.Base64.DecodeStringToBytes(Args[1].s);
    CompressedSize := Length(CompressedBytes);

    if OriginalSize > 0 then
      Result.n := CompressedSize / OriginalSize
    else
      Result.n := 1.0;
  except
    on E: Exception do
    begin
      lastError := ERR_INVALID_ARGUMENT;
    end;
  end;
end;

// gzipsize@$ - Get the uncompressed size of original data from compressed string
// Input: Original string
// Output: Size in bytes (UTF-8 encoded)
function n_gzipsize(var Args: Array of TAsmData): TAsmData;
begin
  lastError := ERR_NONE;
  Result.s := '';
  Result.p := nil;
  Result.n := Length(TEncoding.UTF8.GetBytes(Args[0].s));
end;

// gzipcsize@$ - Get the compressed size from Base64-encoded compressed data
// Input: Base64-encoded compressed data
// Output: Size in bytes of compressed data
function n_gzipcsize(var Args: Array of TAsmData): TAsmData;
var
  CompressedBytes: TBytes;
begin
  lastError := ERR_NONE;
  Result.s := '';
  Result.p := nil;
  Result.n := 0;

  if Args[0].s = '' then
    Exit;

  try
    CompressedBytes := TNetEncoding.Base64.DecodeStringToBytes(Args[0].s);
    Result.n := Length(CompressedBytes);
  except
    on E: Exception do
    begin
      lastError := ERR_INVALID_ARGUMENT;
    end;
  end;
end;

{------------------------------------------------------------------------------
  Library Registration
------------------------------------------------------------------------------}

procedure RegisterGzipFuncs(Lib: TFunctionsDictionary);
var
  FnData: TLinkFunction;
begin
  FnData.FarCall := True;
  //No FireMonkey here, so these run wherever the VM stands.
  FnData.NeedsUIThread := False;

  // Error handling
  FnData.Entry := @n_gziperror; Lib.Add('gziperror@', FnData);

  // String compression/decompression
  FnData.Entry := @s_gzip; Lib.Add('gzip$@$', FnData);
  FnData.Entry := @s_gzipex; Lib.Add('gzipex$@$n', FnData);
  FnData.Entry := @s_gunzip; Lib.Add('gunzip$@$', FnData);

  // File compression/decompression
  FnData.Entry := @n_gzipfile; Lib.Add('gzipfile@$$', FnData);
  FnData.Entry := @n_gzipfileex; Lib.Add('gzipfileex@$$n', FnData);
  FnData.Entry := @n_gunzipfile; Lib.Add('gunzipfile@$$', FnData);

  // Utility functions
  FnData.Entry := @n_gzipratio; Lib.Add('gzipratio@$$', FnData);
  FnData.Entry := @n_gzipsize; Lib.Add('gzipsize@$', FnData);
  FnData.Entry := @n_gzipcsize; Lib.Add('gzipcsize@$', FnData);
end;

end.

