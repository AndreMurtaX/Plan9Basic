unit DictLib;

{******************************************************************************
  DictLib - Dictionary Library for Plan9Basic

  Features:
  - Key/Value storage with string keys
  - Support for Numeric, String, and Pointer value types
  - Type safety with TBasDictType enum
  - Proper error handling with clear error messages
  - 64-bit compatibility (NativeInt for pointers)
  - Integration with garbage collector
  - Iteration support via key/value array extraction

  Version: 1.0
  Date: January 2026
******************************************************************************}

interface

uses
  System.SysUtils, System.Generics.Collections, System.Math,
  exec, UnitGC;

type
  // Dictionary type enumeration for runtime type checking
  TBasDictType = (bdtNumeric, bdtString, bdtPointer);

  // Base class for all dictionary types
  TBasDictBase = class
  protected
    FDictType: TBasDictType;
  public
    property DictType: TBasDictType read FDictType;
    function GetCount: Integer; virtual; abstract;
    function ContainsKey(const key: String): Boolean; virtual; abstract;
    function RemoveKey(const key: String): Boolean; virtual; abstract;
    procedure Clear; virtual; abstract;
    function GetKeys: TArray<String>; virtual; abstract;
  end;

  // Numeric dictionary class
  TBasNumericDict = class(TBasDictBase)
  private
    FData: TDictionary<String, Extended>;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCount: Integer; override;
    function ContainsKey(const key: String): Boolean; override;
    function RemoveKey(const key: String): Boolean; override;
    procedure Clear; override;
    function GetKeys: TArray<String>; override;
    procedure SetValue(const key: String; value: Extended);
    function GetValue(const key: String): Extended;
    function TryGetValue(const key: String; out value: Extended): Boolean;
    function GetValues: TArray<Extended>;
  end;

  // String dictionary class
  TBasStringDict = class(TBasDictBase)
  private
    FData: TDictionary<String, String>;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCount: Integer; override;
    function ContainsKey(const key: String): Boolean; override;
    function RemoveKey(const key: String): Boolean; override;
    procedure Clear; override;
    function GetKeys: TArray<String>; override;
    procedure SetValue(const key: String; const value: String);
    function GetValue(const key: String): String;
    function TryGetValue(const key: String; out value: String): Boolean;
    function GetValues: TArray<String>;
  end;

  // Pointer dictionary class
  TBasPointerDict = class(TBasDictBase)
  private
    FData: TDictionary<String, Pointer>;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCount: Integer; override;
    function ContainsKey(const key: String): Boolean; override;
    function RemoveKey(const key: String): Boolean; override;
    procedure Clear; override;
    function GetKeys: TArray<String>; override;
    procedure SetValue(const key: String; value: Pointer);
    function GetValue(const key: String): Pointer;
    function TryGetValue(const key: String; out value: Pointer): Boolean;
    function GetValues: TArray<Pointer>;
  end;

// Library registration
procedure RegisterDictFuncs(Lib: TFunctionsDictionary);

// Utility functions (exposed for testing)
function GetDictTypeName(dt: TBasDictType): String;
procedure ValidateDictType(p: Pointer; expected: TBasDictType; const funcName: String);

implementation

const
  DICT_GC_TAG = 'BASIC_DICT';

{------------------------------------------------------------------------------
  Utility Functions
------------------------------------------------------------------------------}

function GetDictTypeName(dt: TBasDictType): String;
begin
  case dt of
    bdtNumeric: Result := 'numeric';
    bdtString:  Result := 'string';
    bdtPointer: Result := 'pointer';
  else
    Result := 'unknown'; //This must never happens
  end;
end;

procedure ValidateDictType(p: Pointer; expected: TBasDictType; const funcName: String);
var
  base: TBasDictBase;
begin
  if p = nil then
    raise Exception.CreateFmt('%s: Null dictionary pointer', [funcName]);

  if not (TObject(p) is TBasDictBase) then
    raise Exception.CreateFmt('%s: Invalid dictionary object', [funcName]);

  base := TBasDictBase(p);
  if base.DictType <> expected then
    raise Exception.CreateFmt('%s: Expected %s dictionary, got %s dictionary', [funcName, GetDictTypeName(expected), GetDictTypeName(base.DictType)]);
end;

procedure ValidateDict(p: Pointer; const funcName: String);
begin
  if p = nil then
    raise Exception.CreateFmt('%s: Null dictionary pointer', [funcName]);

  if not (TObject(p) is TBasDictBase) then
    raise Exception.CreateFmt('%s: Invalid dictionary object', [funcName]);
end;

{------------------------------------------------------------------------------
  TBasNumericDict - Numeric dictionary implementation
------------------------------------------------------------------------------}

constructor TBasNumericDict.Create();
begin
  inherited Create();
  FDictType := bdtNumeric;
  FData := TDictionary<String, Extended>.Create();
end;

destructor TBasNumericDict.Destroy();
begin
  if Assigned(FData) then
    FreeAndNil(FData);
  inherited Destroy;
end;

function TBasNumericDict.GetCount(): Integer;
begin
  Result := FData.Count;
end;

function TBasNumericDict.ContainsKey(const key: String): Boolean;
begin
  Result := FData.ContainsKey(key);
end;

function TBasNumericDict.RemoveKey(const key: String): Boolean;
begin
  if FData.ContainsKey(key) then
  begin
    FData.Remove(key);
    Result := True;
  end
  else
    Result := False;
end;

procedure TBasNumericDict.Clear();
begin
  FData.Clear;
end;

function TBasNumericDict.GetKeys(): TArray<String>;
begin
  Result := FData.Keys.ToArray();
end;

procedure TBasNumericDict.SetValue(const key: String; value: Extended);
begin
  FData.AddOrSetValue(key, value);
end;

function TBasNumericDict.GetValue(const key: String): Extended;
begin
  if not FData.TryGetValue(key, Result) then
    raise Exception.CreateFmt('Key not found: "%s"', [key]);
end;

function TBasNumericDict.TryGetValue(const key: String; out value: Extended): Boolean;
begin
  Result := FData.TryGetValue(key, value);
end;

function TBasNumericDict.GetValues: TArray<Extended>;
begin
  Result := FData.Values.ToArray();
end;

{------------------------------------------------------------------------------
  TBasStringDict - String dictionary implementation
------------------------------------------------------------------------------}

constructor TBasStringDict.Create();
begin
  inherited Create();
  FDictType := bdtString;
  FData := TDictionary<String, String>.Create();
end;

destructor TBasStringDict.Destroy();
begin
  if Assigned(FData) then
    FreeAndNil(FData);
  inherited Destroy();
end;

function TBasStringDict.GetCount(): Integer;
begin
  Result := FData.Count;
end;

function TBasStringDict.ContainsKey(const key: String): Boolean;
begin
  Result := FData.ContainsKey(key);
end;

function TBasStringDict.RemoveKey(const key: String): Boolean;
begin
  if FData.ContainsKey(key) then
  begin
    FData.Remove(key);
    Result := True;
  end
  else
    Result := False;
end;

procedure TBasStringDict.Clear();
begin
  FData.Clear;
end;

function TBasStringDict.GetKeys: TArray<String>;
begin
  Result := FData.Keys.ToArray();
end;

procedure TBasStringDict.SetValue(const key: String; const value: String);
begin
  FData.AddOrSetValue(key, value);
end;

function TBasStringDict.GetValue(const key: String): String;
begin
  if not FData.TryGetValue(key, Result) then
    raise Exception.CreateFmt('Key not found: "%s"', [key]);
end;

function TBasStringDict.TryGetValue(const key: String; out value: String): Boolean;
begin
  Result := FData.TryGetValue(key, value);
end;

function TBasStringDict.GetValues: TArray<String>;
begin
  Result := FData.Values.ToArray();
end;

{------------------------------------------------------------------------------
  TBasPointerDict - Pointer dictionary implementation
------------------------------------------------------------------------------}

constructor TBasPointerDict.Create;
begin
  inherited Create;
  FDictType := bdtPointer;
  FData := TDictionary<String, Pointer>.Create;
end;

destructor TBasPointerDict.Destroy;
begin
  if Assigned(FData) then
    FreeAndNil(FData);
  inherited Destroy;
end;

function TBasPointerDict.GetCount: Integer;
begin
  Result := FData.Count;
end;

function TBasPointerDict.ContainsKey(const key: String): Boolean;
begin
  Result := FData.ContainsKey(key);
end;

function TBasPointerDict.RemoveKey(const key: String): Boolean;
begin
  if FData.ContainsKey(key) then
  begin
    FData.Remove(key);
    Result := True;
  end
  else
    Result := False;
end;

procedure TBasPointerDict.Clear;
begin
  FData.Clear;
end;

function TBasPointerDict.GetKeys: TArray<String>;
begin
  Result := FData.Keys.ToArray();
end;

procedure TBasPointerDict.SetValue(const key: String; value: Pointer);
begin
  FData.AddOrSetValue(key, value);
end;

function TBasPointerDict.GetValue(const key: String): Pointer;
begin
  if not FData.TryGetValue(key, Result) then
    raise Exception.CreateFmt('Key not found: "%s"', [key]);
end;

function TBasPointerDict.TryGetValue(const key: String; out value: Pointer): Boolean;
begin
  Result := FData.TryGetValue(key, value);
end;

function TBasPointerDict.GetValues: TArray<Pointer>;
begin
  Result := FData.Values.ToArray();
end;

{------------------------------------------------------------------------------
  Dictionary Creation Functions
------------------------------------------------------------------------------}

// dict#() - Create empty numeric dictionary
function p_dict_new(var Args: array of TAsmData): TAsmData;
var
  dict: TBasNumericDict;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  dict := TBasNumericDict.Create();

  if Assigned(UnitGC.GC) then
    UnitGC.GC.Add<TBasNumericDict>(dict, DICT_GC_TAG);

  Result.p := dict;
end;

// sdict#() - Create empty string dictionary
function p_sdict_new(var Args: array of TAsmData): TAsmData;
var
  dict: TBasStringDict;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  dict := TBasStringDict.Create();

  if Assigned(UnitGC.GC) then
    UnitGC.GC.Add<TBasStringDict>(dict, DICT_GC_TAG);

  Result.p := dict;
end;

// pdict#() - Create empty pointer dictionary
function p_pdict_new(var Args: array of TAsmData): TAsmData;
var
  dict: TBasPointerDict;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  dict := TBasPointerDict.Create();

  if Assigned(UnitGC.GC) then
    UnitGC.GC.Add<TBasPointerDict>(dict, DICT_GC_TAG);

  Result.p := dict;
end;

{------------------------------------------------------------------------------
  Numeric Dictionary Access Functions
------------------------------------------------------------------------------}

// dict_set#(dict#, key$, value) - Set numeric value
function p_dict_set(var Args: array of TAsmData): TAsmData;
var
  dict: TBasNumericDict;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 3 then
    raise Exception.Create('dict_set# requires dictionary, key, and value');

  ValidateDictType(Args[0].p, bdtNumeric, 'dict_set#');
  dict := TBasNumericDict(Args[0].p);
  dict.SetValue(Args[1].s, Args[2].n);

  Result.p := Args[0].p;  // Return the dictionary for chaining
end;

// dict_get(dict#, key$) - Get numeric value
function n_dict_get(var Args: array of TAsmData): TAsmData;
var
  dict: TBasNumericDict;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 2 then
    raise Exception.Create('dict_get requires dictionary and key');

  ValidateDictType(Args[0].p, bdtNumeric, 'dict_get');
  dict := TBasNumericDict(Args[0].p);
  Result.n := dict.GetValue(Args[1].s);
end;

// dict_getdef(dict#, key$, default) - Get numeric value with default
function n_dict_getdef(var Args: array of TAsmData): TAsmData;
var
  dict: TBasNumericDict;
  value: Extended;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 3 then
    raise Exception.Create('dict_getdef requires dictionary, key, and default value');

  ValidateDictType(Args[0].p, bdtNumeric, 'dict_getdef');
  dict := TBasNumericDict(Args[0].p);

  if dict.TryGetValue(Args[1].s, value) then
    Result.n := value
  else
    Result.n := Args[2].n;  // Return default
end;

{------------------------------------------------------------------------------
  String Dictionary Access Functions
------------------------------------------------------------------------------}

// sdict_set#(dict#, key$, value$) - Set string value
function p_sdict_set(var Args: array of TAsmData): TAsmData;
var
  dict: TBasStringDict;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 3 then
    raise Exception.Create('sdict_set# requires dictionary, key, and value');

  ValidateDictType(Args[0].p, bdtString, 'sdict_set#');
  dict := TBasStringDict(Args[0].p);
  dict.SetValue(Args[1].s, Args[2].s);

  Result.p := Args[0].p;  // Return the dictionary for chaining
end;

// sdict_get$(dict#, key$) - Get string value
function s_sdict_get(var Args: array of TAsmData): TAsmData;
var
  dict: TBasStringDict;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 2 then
    raise Exception.Create('sdict_get$ requires dictionary and key');

  ValidateDictType(Args[0].p, bdtString, 'sdict_get$');
  dict := TBasStringDict(Args[0].p);
  Result.s := dict.GetValue(Args[1].s);
end;

// sdict_getdef$(dict#, key$, default$) - Get string value with default
function s_sdict_getdef(var Args: array of TAsmData): TAsmData;
var
  dict: TBasStringDict;
  value: String;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 3 then
    raise Exception.Create('sdict_getdef$ requires dictionary, key, and default value');

  ValidateDictType(Args[0].p, bdtString, 'sdict_getdef$');
  dict := TBasStringDict(Args[0].p);

  if dict.TryGetValue(Args[1].s, value) then
    Result.s := value
  else
    Result.s := Args[2].s;  // Return default
end;

{------------------------------------------------------------------------------
  Pointer Dictionary Access Functions
------------------------------------------------------------------------------}

// pdict_set#(dict#, key$, value#) - Set pointer value
function p_pdict_set(var Args: array of TAsmData): TAsmData;
var
  dict: TBasPointerDict;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 3 then
    raise Exception.Create('pdict_set# requires dictionary, key, and value');

  ValidateDictType(Args[0].p, bdtPointer, 'pdict_set#');
  dict := TBasPointerDict(Args[0].p);
  dict.SetValue(Args[1].s, Args[2].p);

  Result.p := Args[0].p;  // Return the dictionary for chaining
end;

// pdict_get#(dict#, key$) - Get pointer value
function p_pdict_get(var Args: array of TAsmData): TAsmData;
var
  dict: TBasPointerDict;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 2 then
    raise Exception.Create('pdict_get# requires dictionary and key');

  ValidateDictType(Args[0].p, bdtPointer, 'pdict_get#');
  dict := TBasPointerDict(Args[0].p);
  Result.p := dict.GetValue(Args[1].s);
end;

// pdict_getdef#(dict#, key$, default#) - Get pointer value with default
function p_pdict_getdef(var Args: array of TAsmData): TAsmData;
var
  dict: TBasPointerDict;
  value: Pointer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 3 then
    raise Exception.Create('pdict_getdef# requires dictionary, key, and default value');

  ValidateDictType(Args[0].p, bdtPointer, 'pdict_getdef#');
  dict := TBasPointerDict(Args[0].p);

  if dict.TryGetValue(Args[1].s, value) then
    Result.p := value
  else
    Result.p := Args[2].p;  // Return default
end;

{------------------------------------------------------------------------------
  Dictionary Query Functions (work with any dictionary type)
------------------------------------------------------------------------------}

// dict_exists(dict#, key$) - Check if key exists
function n_dict_exists(var Args: array of TAsmData): TAsmData;
var
  base: TBasDictBase;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 2 then
    raise Exception.Create('dict_exists requires dictionary and key');

  ValidateDict(Args[0].p, 'dict_exists');
  base := TBasDictBase(Args[0].p);

  if base.ContainsKey(Args[1].s) then
    Result.n := 1
  else
    Result.n := 0;
end;

// dict_count(dict#) - Get number of entries
function n_dict_count(var Args: array of TAsmData): TAsmData;
var
  base: TBasDictBase;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 1 then
    raise Exception.Create('dict_count requires dictionary');

  ValidateDict(Args[0].p, 'dict_count');
  base := TBasDictBase(Args[0].p);
  Result.n := base.GetCount;
end;

// dict_remove(dict#, key$) - Remove a key, returns 1 if removed, 0 if not found
function n_dict_remove(var Args: array of TAsmData): TAsmData;
var
  base: TBasDictBase;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 2 then
    raise Exception.Create('dict_remove requires dictionary and key');

  ValidateDict(Args[0].p, 'dict_remove');
  base := TBasDictBase(Args[0].p);

  if base.RemoveKey(Args[1].s) then
    Result.n := 1
  else
    Result.n := 0;
end;

// dict_clear#(dict#) - Clear all entries, returns the dictionary
function p_dict_clear(var Args: array of TAsmData): TAsmData;
var
  base: TBasDictBase;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 1 then
    raise Exception.Create('dict_clear# requires dictionary');

  ValidateDict(Args[0].p, 'dict_clear#');
  base := TBasDictBase(Args[0].p);
  base.Clear;

  Result.p := Args[0].p;  // Return the dictionary for chaining
end;

// dict_type(dict#) - Get dictionary type (0=numeric, 1=string, 2=pointer)
function n_dict_type(var Args: array of TAsmData): TAsmData;
var
  base: TBasDictBase;
begin
  Result.n := -1;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 1 then
    raise Exception.Create('dict_type requires dictionary');

  ValidateDict(Args[0].p, 'dict_type');
  base := TBasDictBase(Args[0].p);
  Result.n := Ord(base.DictType);
end;

// dict_typename$(dict#) - Get dictionary type name as string
function s_dict_typename(var Args: array of TAsmData): TAsmData;
var
  base: TBasDictBase;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 1 then
    raise Exception.Create('dict_typename$ requires dictionary');

  ValidateDict(Args[0].p, 'dict_typename$');
  base := TBasDictBase(Args[0].p);
  Result.s := GetDictTypeName(base.DictType);
end;

{------------------------------------------------------------------------------
  Dictionary Iteration Functions
------------------------------------------------------------------------------}

// dict_key$(dict#, index) - Get key at index (0-based)
function s_dict_key(var Args: array of TAsmData): TAsmData;
var
  base: TBasDictBase;
  keys: TArray<String>;
  idx: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  if Length(Args) < 2 then
    raise Exception.Create('dict_key$ requires dictionary and index');

  ValidateDict(Args[0].p, 'dict_key$');
  base := TBasDictBase(Args[0].p);

  idx := Trunc(Args[1].n);
  keys := base.GetKeys;

  if (idx < 0) or (idx >= Length(keys)) then
    raise Exception.CreateFmt('dict_key$: Index %d out of bounds (0..%d)', [idx, Length(keys) - 1]);

  Result.s := keys[idx];
end;

// dict_haskey(dict#, key$) - Alias for dict_exists
function n_dict_haskey(var Args: array of TAsmData): TAsmData;
begin
  Result := n_dict_exists(Args);
end;

{------------------------------------------------------------------------------
  Library Registration
------------------------------------------------------------------------------}

procedure RegisterDictFuncs(Lib: TFunctionsDictionary);
var
  FnData: TLinkFunction;
begin
  FnData.FarCall := True;

  //----------------------------------------------------------------------------
  // Dictionary creation
  //----------------------------------------------------------------------------
  FnData.Entry := p_dict_new; Lib.Add('dict#@', FnData);        // dict#() - numeric dictionary
  FnData.Entry := p_sdict_new; Lib.Add('sdict#@', FnData);       // sdict#() - string dictionary
  FnData.Entry := p_pdict_new; Lib.Add('pdict#@', FnData);       // pdict#() - pointer dictionary

  //----------------------------------------------------------------------------
  // Numeric dictionary operations
  //----------------------------------------------------------------------------
  FnData.Entry := p_dict_set; Lib.Add('dict_set#@#$n', FnData);     // dict_set#(dict#, key$, value)
  FnData.Entry := n_dict_get; Lib.Add('dict_get@#$', FnData);       // dict_get(dict#, key$)
  FnData.Entry := n_dict_getdef; Lib.Add('dict_getdef@#$n', FnData);   // dict_getdef(dict#, key$, default)

  //----------------------------------------------------------------------------
  // String dictionary operations
  //----------------------------------------------------------------------------
  FnData.Entry := p_sdict_set; Lib.Add('sdict_set#@#$$', FnData);    // sdict_set#(dict#, key$, value$)
  FnData.Entry := s_sdict_get; Lib.Add('sdict_get$@#$', FnData);     // sdict_get$(dict#, key$)
  FnData.Entry := s_sdict_getdef; Lib.Add('sdict_getdef$@#$$', FnData); // sdict_getdef$(dict#, key$, default$)

  //----------------------------------------------------------------------------
  // Pointer dictionary operations
  //----------------------------------------------------------------------------
  FnData.Entry := p_pdict_set; Lib.Add('pdict_set#@#$#', FnData);    // pdict_set#(dict#, key$, value#)
  FnData.Entry := p_pdict_get; Lib.Add('pdict_get#@#$', FnData);     // pdict_get#(dict#, key$)
  FnData.Entry := p_pdict_getdef; Lib.Add('pdict_getdef#@#$#', FnData); // pdict_getdef#(dict#, key$, default#)

  //----------------------------------------------------------------------------
  // Generic dictionary operations (work with any type)
  //----------------------------------------------------------------------------
  FnData.Entry := n_dict_exists; Lib.Add('dict_exists@#$', FnData);    // dict_exists(dict#, key$)
  FnData.Entry := n_dict_haskey; Lib.Add('dict_haskey@#$', FnData);    // dict_haskey(dict#, key$) - alias
  FnData.Entry := n_dict_count; Lib.Add('dict_count@#', FnData);      // dict_count(dict#)
  FnData.Entry := n_dict_remove; Lib.Add('dict_remove@#$', FnData);    // dict_remove(dict#, key$)
  FnData.Entry := p_dict_clear; Lib.Add('dict_clear#@#', FnData);     // dict_clear#(dict#)
  FnData.Entry := n_dict_type; Lib.Add('dict_type@#', FnData);       // dict_type(dict#)
  FnData.Entry := s_dict_typename; Lib.Add('dict_typename$@#', FnData);  // dict_typename$(dict#)
  FnData.Entry := s_dict_key; Lib.Add('dict_key$@#n', FnData);      // dict_key$(dict#, index)
end;

end.

