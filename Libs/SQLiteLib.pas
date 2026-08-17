unit SqliteLib;

{******************************************************************************
  SqliteLib - SQLite Database Library for Plan9Basic
  Version: 1.0

  A comprehensive SQLite library providing full database functionality with
  seamless JSON integration for reading/writing records.

  Features:
  - Database connection management
  - Prepared statements with parameter binding
  - Result cursors with field access
  - Full JSON integration (read/write records as JSON)
  - Transaction support
  - Error handling
  - Table introspection

  Function Count: 75+ functions

  Memory Management:
  - Database connections: Managed by garbage collector
  - Statements/Cursors: Owned by their parent connection, NOT in GC
  - This prevents double-free issues during cleanup

  Design Pattern:
  - Connections own their statements (parent-child relationship)
  - When a connection is freed, all its statements are freed first
  - Statements are NOT added to GC since connection manages them
******************************************************************************}

interface

uses
  System.SysUtils, System.Classes, System.JSON, System.Generics.Collections,
  System.IOUtils, System.Math, System.DateUtils,
  Data.DB,  // TField, ftXXX field type constants
  FireDAC.Comp.Client, FireDAC.Stan.Def, FireDAC.Stan.Async,
  FireDAC.DApt, FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLite, FireDAC.Stan.Param, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.Stan.Intf,
  FireDAC.UI.Intf, FireDAC.FMXUI.Wait,  // Required for FMX applications
  exec, UnitGC, basic;

const
  SQL_GC_TAG = 'BASIC_SQLITE';

  // Error codes
  SQL_ERR_NONE          = 0;
  SQL_ERR_NOT_OPEN      = 1;
  SQL_ERR_INVALID_CONN  = 2;
  SQL_ERR_INVALID_STMT  = 3;
  SQL_ERR_EXEC_FAILED   = 4;
  SQL_ERR_QUERY_FAILED  = 5;
  SQL_ERR_PREPARE_FAIL  = 6;
  SQL_ERR_BIND_FAILED   = 7;
  SQL_ERR_STEP_FAILED   = 8;
  SQL_ERR_COLUMN_INDEX  = 9;
  SQL_ERR_COLUMN_NAME   = 10;
  SQL_ERR_TRANSACTION   = 11;
  SQL_ERR_FILE_ERROR    = 12;
  SQL_ERR_JSON_INVALID  = 13;
  SQL_ERR_TABLE_ERROR   = 14;
  SQL_ERR_BACKUP_FAILED = 15;

  // Column types
  SQL_TYPE_NULL    = 0;
  SQL_TYPE_INTEGER = 1;
  SQL_TYPE_FLOAT   = 2;
  SQL_TYPE_TEXT    = 3;
  SQL_TYPE_BLOB    = 4;

  // Step results
  SQL_STEP_ROW   = 1;   // Row available
  SQL_STEP_DONE  = 0;   // No more rows
  SQL_STEP_ERROR = -1;  // Error occurred

procedure RegisterSqliteFuncs(Funcs: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);

implementation

var
  lastError: Integer;
  lastErrorMsg: String;

  // Module-level references for callback support (if needed)
  ModuleEngine: TBasicEngine;
  ModuleOutput: TStrings;

  // FireDAC driver link - required for SQLite
  FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;

type
  // Forward declaration
  TBasSqliteConn = class;

  //----------------------------------------------------------------------------
  // TBasSqliteStmt - Prepared statement / cursor
  //----------------------------------------------------------------------------
  TBasSqliteStmt = class
  private
    FOwner: TBasSqliteConn;
    FQuery: TFDQuery;
    FActive: Boolean;
    FSQL: String;
    FIsSelect: Boolean;
    FEof: Boolean;
  public
    constructor Create(AOwner: TBasSqliteConn; const ASQL: String);
    destructor Destroy; override;

    function Step: Integer;  // Returns SQL_STEP_ROW, SQL_STEP_DONE, or SQL_STEP_ERROR
    procedure Reset;
    function Execute: Boolean;

    // Parameter binding
    procedure BindStr(Index: Integer; const Value: String);
    procedure BindNum(Index: Integer; Value: Extended);
    procedure BindNull(Index: Integer);
    procedure BindFromJson(Json: TJSONObject);
    procedure ClearBindings;

    // Column access
    function ColCount: Integer;
    function ColName(Index: Integer): String;
    function ColType(Index: Integer): Integer;
    function ColIndex(const Name: String): Integer;
    function GetStr(Index: Integer): String;
    function GetNum(Index: Integer): Extended;
    function IsNull(Index: Integer): Boolean;
    function IsBlob(Index: Integer): Boolean;

    // JSON access
    function RowToJson: TJSONObject;
    function FetchAll: TJSONArray;
    function FetchOne: TJSONObject;

    property Owner: TBasSqliteConn read FOwner;
    property Query: TFDQuery read FQuery;
    property Active: Boolean read FActive;
    property SQL: String read FSQL;
    property Eof: Boolean read FEof;
    property IsSelect: Boolean read FIsSelect;
  end;

  //----------------------------------------------------------------------------
  // TBasSqliteConn - Database connection
  //----------------------------------------------------------------------------
  TBasSqliteConn = class
  private
    FConnection: TFDConnection;
    FPath: String;
    FInTransaction: Boolean;
    FStatements: TObjectList<TBasSqliteStmt>;  // Owned statements
  public
    constructor Create;
    destructor Destroy; override;

    function Open(const APath: String): Boolean;
    function OpenMemory: Boolean;
    procedure Close;

    function IsOpen: Boolean;
    function ExecSQL(const ASQL: String): Boolean;
    function ExecSQLJson(const ASQL: String; Params: TJSONObject): Boolean;
    function Prepare(const ASQL: String): TBasSqliteStmt;
    function Query(const ASQL: String): TBasSqliteStmt;
    function QueryJson(const ASQL: String; Params: TJSONObject): TBasSqliteStmt;

    // Transaction
    function BeginTrans: Boolean;
    function Commit: Boolean;
    function Rollback: Boolean;

    // Utility
    function LastInsertId: Int64;
    function RowsAffected: Integer;
    function TotalChanges: Integer;
    function TableExists(const TableName: String): Boolean;
    function GetTables: TJSONArray;
    function GetColumns(const TableName: String): TJSONArray;
    function Backup(const DestPath: String): Boolean;
    function Vacuum: Boolean;

    // JSON convenience
    function InsertJson(const TableName: String; Data: TJSONObject): Boolean;
    function UpdateJson(const TableName: String; Data: TJSONObject; const WhereClause: String): Boolean;

    // Statement management (internal)
    procedure RegisterStatement(Stmt: TBasSqliteStmt);
    procedure UnregisterStatement(Stmt: TBasSqliteStmt);

    property Connection: TFDConnection read FConnection;
    property Path: String read FPath;
    property InTransaction: Boolean read FInTransaction;
  end;

//------------------------------------------------------------------------------
// Error Handling Helpers
//------------------------------------------------------------------------------

procedure SetError(Code: Integer; const Msg: String);
begin
  lastError := Code;
  lastErrorMsg := Msg;
end;

procedure ClearError;
begin
  lastError := SQL_ERR_NONE;
  lastErrorMsg := '';
end;

function GetErrorMessage(Code: Integer): String;
begin
  case Code of
    SQL_ERR_NONE:         Result := 'No error';
    SQL_ERR_NOT_OPEN:     Result := 'Database not open';
    SQL_ERR_INVALID_CONN: Result := 'Invalid connection';
    SQL_ERR_INVALID_STMT: Result := 'Invalid statement';
    SQL_ERR_EXEC_FAILED:  Result := 'SQL execution failed';
    SQL_ERR_QUERY_FAILED: Result := 'Query execution failed';
    SQL_ERR_PREPARE_FAIL: Result := 'Statement preparation failed';
    SQL_ERR_BIND_FAILED:  Result := 'Parameter binding failed';
    SQL_ERR_STEP_FAILED:  Result := 'Step execution failed';
    SQL_ERR_COLUMN_INDEX: Result := 'Column index out of bounds';
    SQL_ERR_COLUMN_NAME:  Result := 'Column not found';
    SQL_ERR_TRANSACTION:  Result := 'Transaction error';
    SQL_ERR_FILE_ERROR:   Result := 'File operation error';
    SQL_ERR_JSON_INVALID: Result := 'Invalid JSON data';
    SQL_ERR_TABLE_ERROR:  Result := 'Table operation error';
    SQL_ERR_BACKUP_FAILED: Result := 'Database backup failed';
  else
    Result := 'Unknown error';
  end;
end;

procedure ValidateConn(p: Pointer; const FuncName: String);
begin
  if p = nil then
  begin
    SetError(SQL_ERR_INVALID_CONN, FuncName + ': Null connection pointer');
    raise Exception.Create(lastErrorMsg);
  end;
  if not (TObject(p) is TBasSqliteConn) then
  begin
    SetError(SQL_ERR_INVALID_CONN, FuncName + ': Invalid connection object');
    raise Exception.Create(lastErrorMsg);
  end;
end;

procedure ValidateStmt(p: Pointer; const FuncName: String);
begin
  if p = nil then
  begin
    SetError(SQL_ERR_INVALID_STMT, FuncName + ': Null statement pointer');
    raise Exception.Create(lastErrorMsg);
  end;
  if not (TObject(p) is TBasSqliteStmt) then
  begin
    SetError(SQL_ERR_INVALID_STMT, FuncName + ': Invalid statement object');
    raise Exception.Create(lastErrorMsg);
  end;
end;

//------------------------------------------------------------------------------
// TBasSqliteStmt Implementation
//------------------------------------------------------------------------------

constructor TBasSqliteStmt.Create(AOwner: TBasSqliteConn; const ASQL: String);
var
  TrimSQL: String;
begin
  inherited Create;
  FOwner := AOwner;
  FSQL := ASQL;
  FActive := False;
  FEof := True;

  // Determine if this is a SELECT query
  TrimSQL := Trim(UpperCase(ASQL));
  FIsSelect := (Pos('SELECT', TrimSQL) = 1) or
               (Pos('PRAGMA', TrimSQL) = 1) or
               (Pos('EXPLAIN', TrimSQL) = 1);

  FQuery := TFDQuery.Create(nil);
  FQuery.Connection := AOwner.Connection;
  FQuery.SQL.Text := ASQL;
  FQuery.FetchOptions.Mode := fmAll;

  // Register with owner
  AOwner.RegisterStatement(Self);
end;

destructor TBasSqliteStmt.Destroy;
begin
  // Unregister from owner (if owner still exists)
  if Assigned(FOwner) and Assigned(FOwner.FStatements) then
    FOwner.UnregisterStatement(Self);

  if Assigned(FQuery) then
  begin
    if FQuery.Active then
      FQuery.Close;
    FreeAndNil(FQuery);
  end;

  inherited Destroy;
end;

function TBasSqliteStmt.Step: Integer;
begin
  try
    if not FActive then
    begin
      // First call - open the query
      if FIsSelect then
      begin
        FQuery.Open;
        FActive := True;
        FEof := FQuery.Eof;
        if FEof then
          Result := SQL_STEP_DONE
        else
          Result := SQL_STEP_ROW;
      end
      else
      begin
        // Non-select statement
        FQuery.ExecSQL;
        FActive := True;
        FEof := True;
        Result := SQL_STEP_DONE;
      end;
    end
    else
    begin
      // Subsequent calls - move to next row
      if FIsSelect and not FEof then
      begin
        FQuery.Next;
        FEof := FQuery.Eof;
        if FEof then
          Result := SQL_STEP_DONE
        else
          Result := SQL_STEP_ROW;
      end
      else
        Result := SQL_STEP_DONE;
    end;
    ClearError;
  except
    on E: Exception do
    begin
      SetError(SQL_ERR_STEP_FAILED, E.Message);
      Result := SQL_STEP_ERROR;
    end;
  end;
end;

procedure TBasSqliteStmt.Reset;
begin
  try
    if FQuery.Active then
      FQuery.Close;
    FActive := False;
    FEof := True;
    ClearError;
  except
    on E: Exception do
      SetError(SQL_ERR_STEP_FAILED, E.Message);
  end;
end;

function TBasSqliteStmt.Execute: Boolean;
begin
  try
    Reset;
    FQuery.ExecSQL;
    FActive := True;
    FEof := True;
    ClearError;
    Result := True;
  except
    on E: Exception do
    begin
      SetError(SQL_ERR_EXEC_FAILED, E.Message);
      Result := False;
    end;
  end;
end;

procedure TBasSqliteStmt.BindStr(Index: Integer; const Value: String);
begin
  try
    if (Index >= 0) and (Index < FQuery.Params.Count) then
      FQuery.Params[Index].AsString := Value
    else
      raise Exception.CreateFmt('Parameter index %d out of bounds', [Index]);
    ClearError;
  except
    on E: Exception do
      SetError(SQL_ERR_BIND_FAILED, E.Message);
  end;
end;

procedure TBasSqliteStmt.BindNum(Index: Integer; Value: Extended);
begin
  try
    if (Index >= 0) and (Index < FQuery.Params.Count) then
      FQuery.Params[Index].AsFloat := Value
    else
      raise Exception.CreateFmt('Parameter index %d out of bounds', [Index]);
    ClearError;
  except
    on E: Exception do
      SetError(SQL_ERR_BIND_FAILED, E.Message);
  end;
end;

procedure TBasSqliteStmt.BindNull(Index: Integer);
begin
  try
    if (Index >= 0) and (Index < FQuery.Params.Count) then
      FQuery.Params[Index].Clear
    else
      raise Exception.CreateFmt('Parameter index %d out of bounds', [Index]);
    ClearError;
  except
    on E: Exception do
      SetError(SQL_ERR_BIND_FAILED, E.Message);
  end;
end;

procedure TBasSqliteStmt.BindFromJson(Json: TJSONObject);
var
  i: Integer;
  Pair: TJSONPair;
  ParamName: String;
  Param: TFDParam;
begin
  if Json = nil then Exit;

  try
    for i := 0 to Json.Count - 1 do
    begin
      Pair := Json.Pairs[i];
      ParamName := Pair.JsonString.Value;

      // Try to find parameter by name
      Param := FQuery.Params.FindParam(ParamName);
      if Param = nil then Continue;

      if Pair.JsonValue is TJSONNull then
        Param.Clear
      else if Pair.JsonValue is TJSONNumber then
        Param.AsFloat := TJSONNumber(Pair.JsonValue).AsDouble
      else if Pair.JsonValue is TJSONString then
        Param.AsString := TJSONString(Pair.JsonValue).Value
      else if Pair.JsonValue is TJSONTrue then
        Param.AsInteger := 1
      else if Pair.JsonValue is TJSONFalse then
        Param.AsInteger := 0
      else
        Param.AsString := Pair.JsonValue.ToString;
    end;
    ClearError;
  except
    on E: Exception do
      SetError(SQL_ERR_BIND_FAILED, E.Message);
  end;
end;

procedure TBasSqliteStmt.ClearBindings;
var
  i: Integer;
begin
  for i := 0 to FQuery.Params.Count - 1 do
    FQuery.Params[i].Clear;
end;

function TBasSqliteStmt.ColCount: Integer;
begin
  if FQuery.Active then
    Result := FQuery.FieldCount
  else
    Result := 0;
end;

function TBasSqliteStmt.ColName(Index: Integer): String;
begin
  if FQuery.Active and (Index >= 0) and (Index < FQuery.FieldCount) then
    Result := FQuery.Fields[Index].FieldName
  else
  begin
    SetError(SQL_ERR_COLUMN_INDEX, Format('Column index %d out of bounds', [Index]));
    Result := '';
  end;
end;

function TBasSqliteStmt.ColType(Index: Integer): Integer;
var
  Field: TField;
begin
  Result := SQL_TYPE_NULL;
  if not FQuery.Active then Exit;
  if (Index < 0) or (Index >= FQuery.FieldCount) then
  begin
    SetError(SQL_ERR_COLUMN_INDEX, Format('Column index %d out of bounds', [Index]));
    Exit;
  end;

  Field := FQuery.Fields[Index];
  if Field.IsNull then
    Result := SQL_TYPE_NULL
  else
    case Field.DataType of
      ftSmallint, ftInteger, ftWord, ftLargeint, ftShortint, ftByte, ftLongWord:
        Result := SQL_TYPE_INTEGER;
      ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftSingle, ftExtended:
        Result := SQL_TYPE_FLOAT;
      ftString, ftWideString, ftMemo, ftWideMemo, ftFixedChar, ftFixedWideChar:
        Result := SQL_TYPE_TEXT;
      ftBlob, ftGraphic, ftTypedBinary, ftBytes, ftVarBytes:
        Result := SQL_TYPE_BLOB;
    else
      Result := SQL_TYPE_TEXT;
    end;
end;

function TBasSqliteStmt.ColIndex(const Name: String): Integer;
var
  Field: TField;
begin
  Result := -1;
  if not FQuery.Active then Exit;

  Field := FQuery.FindField(Name);
  if Field <> nil then
    Result := Field.Index
  else
    SetError(SQL_ERR_COLUMN_NAME, Format('Column "%s" not found', [Name]));
end;

function TBasSqliteStmt.GetStr(Index: Integer): String;
begin
  Result := '';
  if not FQuery.Active then Exit;
  if (Index < 0) or (Index >= FQuery.FieldCount) then
  begin
    SetError(SQL_ERR_COLUMN_INDEX, Format('Column index %d out of bounds', [Index]));
    Exit;
  end;

  if FQuery.Fields[Index].IsNull then
    Result := ''
  else
    Result := FQuery.Fields[Index].AsString;
end;

function TBasSqliteStmt.GetNum(Index: Integer): Extended;
begin
  Result := 0;
  if not FQuery.Active then Exit;
  if (Index < 0) or (Index >= FQuery.FieldCount) then
  begin
    SetError(SQL_ERR_COLUMN_INDEX, Format('Column index %d out of bounds', [Index]));
    Exit;
  end;

  if FQuery.Fields[Index].IsNull then
    Result := 0
  else
    Result := FQuery.Fields[Index].AsFloat;
end;

function TBasSqliteStmt.IsNull(Index: Integer): Boolean;
begin
  Result := True;
  if not FQuery.Active then Exit;
  if (Index < 0) or (Index >= FQuery.FieldCount) then
  begin
    SetError(SQL_ERR_COLUMN_INDEX, Format('Column index %d out of bounds', [Index]));
    Exit;
  end;

  Result := FQuery.Fields[Index].IsNull;
end;

function TBasSqliteStmt.IsBlob(Index: Integer): Boolean;
begin
  Result := False;
  if not FQuery.Active then Exit;
  if (Index < 0) or (Index >= FQuery.FieldCount) then
  begin
    SetError(SQL_ERR_COLUMN_INDEX, Format('Column index %d out of bounds', [Index]));
    Exit;
  end;

  Result := FQuery.Fields[Index].DataType in [ftBlob, ftGraphic, ftTypedBinary, ftBytes, ftVarBytes];
end;

function TBasSqliteStmt.RowToJson: TJSONObject;
var
  i: Integer;
  Field: TField;
begin
  Result := TJSONObject.Create;

  if not FQuery.Active or FEof then Exit;

  for i := 0 to FQuery.FieldCount - 1 do
  begin
    Field := FQuery.Fields[i];
    if Field.IsNull then
      Result.AddPair(Field.FieldName, TJSONNull.Create)
    else
      case Field.DataType of
        ftSmallint, ftInteger, ftWord, ftLargeint, ftShortint, ftByte, ftLongWord:
          Result.AddPair(Field.FieldName, TJSONNumber.Create(Field.AsLargeInt));
        ftFloat, ftCurrency, ftBCD, ftFMTBcd, ftSingle, ftExtended:
          Result.AddPair(Field.FieldName, TJSONNumber.Create(Field.AsFloat));
        ftBoolean:
          if Field.AsBoolean then
            Result.AddPair(Field.FieldName, TJSONTrue.Create)
          else
            Result.AddPair(Field.FieldName, TJSONFalse.Create);
      else
        Result.AddPair(Field.FieldName, TJSONString.Create(Field.AsString));
      end;
  end;
end;

function TBasSqliteStmt.FetchAll: TJSONArray;
var
  Row: TJSONObject;
begin
  Result := TJSONArray.Create;

  // Open the query if not already active
  if not FQuery.Active then
  begin
    try
      FQuery.Open;
      FActive := True;
    except
      on E: Exception do
      begin
        SetError(SQL_ERR_QUERY_FAILED, E.Message);
        Exit;
      end;
    end;
  end;

  FQuery.First;
  FEof := FQuery.Eof;
  while not FQuery.Eof do
  begin
    Row := RowToJson;
    Result.AddElement(Row);
    FQuery.Next;
  end;
  FEof := True;  // After fetching all, we're at EOF
end;

function TBasSqliteStmt.FetchOne: TJSONObject;
begin
  Result := nil;

  if not FActive then
  begin
    // First call - open and get first row
    if Step = SQL_STEP_ROW then
      Result := RowToJson;
  end
  else if not FEof then
  begin
    // Get current row, then advance
    Result := RowToJson;
    Step;
  end;
end;

//------------------------------------------------------------------------------
// TBasSqliteConn Implementation
//------------------------------------------------------------------------------

constructor TBasSqliteConn.Create;
begin
  inherited Create;
  FConnection := TFDConnection.Create(nil);
  FConnection.DriverName := 'SQLite';
  FConnection.LoginPrompt := False;
  FPath := '';
  FInTransaction := False;
  FStatements := TObjectList<TBasSqliteStmt>.Create(False);  // Don't own objects here
end;

destructor TBasSqliteConn.Destroy;
var
  i: Integer;
  Stmt: TBasSqliteStmt;
begin
  // First, close all statements (in reverse order to avoid index issues)
  if Assigned(FStatements) then
  begin
    for i := FStatements.Count - 1 downto 0 do
    begin
      Stmt := FStatements[i];
      Stmt.FOwner := nil;  // Prevent unregister during free
      Stmt.Free;
    end;
    FreeAndNil(FStatements);
  end;

  // Then close connection
  if Assigned(FConnection) then
  begin
    if FConnection.Connected then
      FConnection.Close;
    FreeAndNil(FConnection);
  end;

  inherited Destroy;
end;

procedure TBasSqliteConn.RegisterStatement(Stmt: TBasSqliteStmt);
begin
  if Assigned(FStatements) and not FStatements.Contains(Stmt) then
    FStatements.Add(Stmt);
end;

procedure TBasSqliteConn.UnregisterStatement(Stmt: TBasSqliteStmt);
begin
  if Assigned(FStatements) then
    FStatements.Remove(Stmt);
end;

function TBasSqliteConn.Open(const APath: String): Boolean;
begin
  //Result := False;
  try
    if FConnection.Connected then
      FConnection.Close;

    FPath := APath;
    FConnection.Params.Clear;
    FConnection.Params.Values['DriverID'] := 'SQLite';
    FConnection.Params.Values['Database'] := APath;
    FConnection.Params.Values['LockingMode'] := 'Normal';
    FConnection.Params.Values['Synchronous'] := 'Normal';
    FConnection.Open;
    Result := FConnection.Connected;
    ClearError;
  except
    on E: Exception do
    begin
      SetError(SQL_ERR_FILE_ERROR, E.Message);
      Result := False;
    end;
  end;
end;

function TBasSqliteConn.OpenMemory: Boolean;
begin
  Result := Open(':memory:');
end;

procedure TBasSqliteConn.Close;
begin
  try
    if FInTransaction then
      Rollback;

    if FConnection.Connected then
      FConnection.Close;

    FPath := '';
    ClearError;
  except
    on E: Exception do
      SetError(SQL_ERR_FILE_ERROR, E.Message);
  end;
end;

function TBasSqliteConn.IsOpen: Boolean;
begin
  Result := FConnection.Connected;
end;

function TBasSqliteConn.ExecSQL(const ASQL: String): Boolean;
begin
  Result := False;
  try
    if not FConnection.Connected then
    begin
      SetError(SQL_ERR_NOT_OPEN, 'Database not open');
      Exit;
    end;

    FConnection.ExecSQL(ASQL);
    ClearError;
    Result := True;
  except
    on E: Exception do
    begin
      SetError(SQL_ERR_EXEC_FAILED, E.Message);
      Result := False;
    end;
  end;
end;

function TBasSqliteConn.ExecSQLJson(const ASQL: String; Params: TJSONObject): Boolean;
var
  Query: TFDQuery;
  i: Integer;
  Pair: TJSONPair;
  Param: TFDParam;
begin
  Result := False;
  if not FConnection.Connected then
  begin
    SetError(SQL_ERR_NOT_OPEN, 'Database not open');
    Exit;
  end;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := ASQL;

    // Bind parameters from JSON
    if Params <> nil then
    begin
      for i := 0 to Params.Count - 1 do
      begin
        Pair := Params.Pairs[i];
        Param := Query.Params.FindParam(Pair.JsonString.Value);
        if Param = nil then Continue;

        if Pair.JsonValue is TJSONNull then
          Param.Clear
        else if Pair.JsonValue is TJSONNumber then
          Param.AsFloat := TJSONNumber(Pair.JsonValue).AsDouble
        else if Pair.JsonValue is TJSONString then
          Param.AsString := TJSONString(Pair.JsonValue).Value
        else if Pair.JsonValue is TJSONTrue then
          Param.AsInteger := 1
        else if Pair.JsonValue is TJSONFalse then
          Param.AsInteger := 0
        else
          Param.AsString := Pair.JsonValue.ToString;
      end;
    end;

    Query.ExecSQL;
    ClearError;
    Result := True;
  except
    on E: Exception do
    begin
      SetError(SQL_ERR_EXEC_FAILED, E.Message);
      Result := False;
    end;
  end;
  Query.Free;
end;

function TBasSqliteConn.Prepare(const ASQL: String): TBasSqliteStmt;
begin
  Result := nil;
  try
    if not FConnection.Connected then
    begin
      SetError(SQL_ERR_NOT_OPEN, 'Database not open');
      Exit;
    end;

    Result := TBasSqliteStmt.Create(Self, ASQL);
    ClearError;
  except
    on E: Exception do
    begin
      SetError(SQL_ERR_PREPARE_FAIL, E.Message);
      Result := nil;
    end;
  end;
end;

function TBasSqliteConn.Query(const ASQL: String): TBasSqliteStmt;
begin
  // Just prepare the statement - user calls sql_step to iterate
  // This allows the standard pattern: while sql_step(cursor#) = 1
  Result := Prepare(ASQL);
end;

function TBasSqliteConn.QueryJson(const ASQL: String; Params: TJSONObject): TBasSqliteStmt;
begin
  Result := Prepare(ASQL);
  if Result <> nil then
    Result.BindFromJson(Params);
  // Don't auto-step - user calls sql_step to iterate
end;

function TBasSqliteConn.BeginTrans: Boolean;
begin
  Result := False;
  try
    if not FConnection.Connected then
    begin
      SetError(SQL_ERR_NOT_OPEN, 'Database not open');
      Exit;
    end;

    if FInTransaction then
    begin
      SetError(SQL_ERR_TRANSACTION, 'Already in transaction');
      Exit;
    end;

    FConnection.StartTransaction;
    FInTransaction := True;
    ClearError;
    Result := True;
  except
    on E: Exception do
    begin
      SetError(SQL_ERR_TRANSACTION, E.Message);
      Result := False;
    end;
  end;
end;

function TBasSqliteConn.Commit: Boolean;
begin
  Result := False;
  try
    if not FConnection.Connected then
    begin
      SetError(SQL_ERR_NOT_OPEN, 'Database not open');
      Exit;
    end;

    if not FInTransaction then
    begin
      SetError(SQL_ERR_TRANSACTION, 'Not in transaction');
      Exit;
    end;

    FConnection.Commit;
    FInTransaction := False;
    ClearError;
    Result := True;
  except
    on E: Exception do
    begin
      SetError(SQL_ERR_TRANSACTION, E.Message);
      Result := False;
    end;
  end;
end;

function TBasSqliteConn.Rollback: Boolean;
begin
  Result := False;
  try
    if not FConnection.Connected then
    begin
      SetError(SQL_ERR_NOT_OPEN, 'Database not open');
      Exit;
    end;

    if not FInTransaction then
    begin
      SetError(SQL_ERR_TRANSACTION, 'Not in transaction');
      Exit;
    end;

    FConnection.Rollback;
    FInTransaction := False;
    ClearError;
    Result := True;
  except
    on E: Exception do
    begin
      SetError(SQL_ERR_TRANSACTION, E.Message);
      Result := False;
    end;
  end;
end;

function TBasSqliteConn.LastInsertId: Int64;
begin
  Result := 0;
  if FConnection.Connected then
  begin
    try
      Result := FConnection.GetLastAutoGenValue('');
    except
      // Fallback to query method
      try
        Result := Trunc(FConnection.ExecSQLScalar('SELECT last_insert_rowid()'));
      except
        Result := 0;
      end;
    end;
  end;
end;

function TBasSqliteConn.RowsAffected: Integer;
begin
  Result := 0;
  if FConnection.Connected then
  begin
    try
      // Use SQLite's changes() function to get rows affected by last statement
      Result := Trunc(FConnection.ExecSQLScalar('SELECT changes()'));
    except
      Result := 0;
    end;
  end;
end;

function TBasSqliteConn.TotalChanges: Integer;
begin
  Result := 0;
  if FConnection.Connected then
  begin
    try
      Result := Trunc(FConnection.ExecSQLScalar('SELECT total_changes()'));
    except
      Result := 0;
    end;
  end;
end;

function TBasSqliteConn.TableExists(const TableName: String): Boolean;
var
  Count: Variant;
begin
  Result := False;
  if not FConnection.Connected then Exit;

  try
    Count := FConnection.ExecSQLScalar(
      'SELECT COUNT(*) FROM sqlite_master WHERE type=''table'' AND name=:name',
      [TableName]);
    Result := (Count > 0);
  except
    Result := False;
  end;
end;

function TBasSqliteConn.GetTables: TJSONArray;
var
  Query: TFDQuery;
begin
  Result := TJSONArray.Create;
  if not FConnection.Connected then Exit;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'SELECT name FROM sqlite_master WHERE type=''table'' ORDER BY name';
    Query.Open;

    while not Query.Eof do
    begin
      Result.Add(Query.Fields[0].AsString);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TBasSqliteConn.GetColumns(const TableName: String): TJSONArray;
var
  Query: TFDQuery;
  ColInfo: TJSONObject;
begin
  Result := TJSONArray.Create;
  if not FConnection.Connected then Exit;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := 'PRAGMA table_info(' + QuotedStr(TableName) + ')';
    Query.Open;

    while not Query.Eof do
    begin
      ColInfo := TJSONObject.Create;
      ColInfo.AddPair('cid', TJSONNumber.Create(Query.FieldByName('cid').AsInteger));
      ColInfo.AddPair('name', Query.FieldByName('name').AsString);
      ColInfo.AddPair('type', Query.FieldByName('type').AsString);
      ColInfo.AddPair('notnull', TJSONNumber.Create(Query.FieldByName('notnull').AsInteger));
      ColInfo.AddPair('pk', TJSONNumber.Create(Query.FieldByName('pk').AsInteger));
      if not Query.FieldByName('dflt_value').IsNull then
        ColInfo.AddPair('default', Query.FieldByName('dflt_value').AsString)
      else
        ColInfo.AddPair('default', TJSONNull.Create);
      Result.AddElement(ColInfo);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

function TBasSqliteConn.Backup(const DestPath: String): Boolean;
begin
  Result := False;
  if not FConnection.Connected then
  begin
    SetError(SQL_ERR_NOT_OPEN, 'Database not open');
    Exit;
  end;

  try
    // Use VACUUM INTO for backup (SQLite 3.27+)
    FConnection.ExecSQL('VACUUM INTO ' + QuotedStr(DestPath));
    ClearError;
    Result := True;
  except
    on E: Exception do
    begin
      // Fallback: Try file copy for in-memory or if VACUUM INTO fails
      try
        if (FPath <> ':memory:') and FileExists(FPath) then
        begin
          TFile.Copy(FPath, DestPath, True);
          ClearError;
          Result := True;
        end
        else
        begin
          SetError(SQL_ERR_BACKUP_FAILED, E.Message);
          Result := False;
        end;
      except
        on E2: Exception do
        begin
          SetError(SQL_ERR_BACKUP_FAILED, E2.Message);
          Result := False;
        end;
      end;
    end;
  end;
end;

function TBasSqliteConn.Vacuum: Boolean;
begin
  Result := ExecSQL('VACUUM');
end;

function TBasSqliteConn.InsertJson(const TableName: String; Data: TJSONObject): Boolean;
var
  SQL: String;
  Columns, Values: String;
  i: Integer;
  Pair: TJSONPair;
  Query: TFDQuery;
begin
  Result := False;
  if Data = nil then
  begin
    SetError(SQL_ERR_JSON_INVALID, 'Null JSON object');
    Exit;
  end;

  if Data.Count = 0 then
  begin
    SetError(SQL_ERR_JSON_INVALID, 'Empty JSON object');
    Exit;
  end;

  // Build INSERT statement
  Columns := '';
  Values := '';
  for i := 0 to Data.Count - 1 do
  begin
    Pair := Data.Pairs[i];
    if i > 0 then
    begin
      Columns := Columns + ', ';
      Values := Values + ', ';
    end;
    Columns := Columns + '"' + Pair.JsonString.Value + '"';
    Values := Values + ':' + Pair.JsonString.Value;
  end;

  SQL := 'INSERT INTO "' + TableName + '" (' + Columns + ') VALUES (' + Values + ')';

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := SQL;

    // Bind parameters
    for i := 0 to Data.Count - 1 do
    begin
      Pair := Data.Pairs[i];
      if Pair.JsonValue is TJSONNull then
        Query.ParamByName(Pair.JsonString.Value).Clear
      else if Pair.JsonValue is TJSONNumber then
        Query.ParamByName(Pair.JsonString.Value).AsFloat := TJSONNumber(Pair.JsonValue).AsDouble
      else if Pair.JsonValue is TJSONString then
        Query.ParamByName(Pair.JsonString.Value).AsString := TJSONString(Pair.JsonValue).Value
      else if Pair.JsonValue is TJSONTrue then
        Query.ParamByName(Pair.JsonString.Value).AsInteger := 1
      else if Pair.JsonValue is TJSONFalse then
        Query.ParamByName(Pair.JsonString.Value).AsInteger := 0
      else
        Query.ParamByName(Pair.JsonString.Value).AsString := Pair.JsonValue.ToString;
    end;

    Query.ExecSQL;
    ClearError;
    Result := True;
  except
    on E: Exception do
    begin
      SetError(SQL_ERR_EXEC_FAILED, E.Message);
      Result := False;
    end;
  end;
  Query.Free;
end;

function TBasSqliteConn.UpdateJson(const TableName: String; Data: TJSONObject; const WhereClause: String): Boolean;
var
  SQL: String;
  SetClause: String;
  i: Integer;
  Pair: TJSONPair;
  Query: TFDQuery;
begin
  Result := False;
  if Data = nil then
  begin
    SetError(SQL_ERR_JSON_INVALID, 'Null JSON object');
    Exit;
  end;

  if Data.Count = 0 then
  begin
    SetError(SQL_ERR_JSON_INVALID, 'Empty JSON object');
    Exit;
  end;

  // Build UPDATE statement
  SetClause := '';
  for i := 0 to Data.Count - 1 do
  begin
    Pair := Data.Pairs[i];
    if i > 0 then
      SetClause := SetClause + ', ';
    SetClause := SetClause + '"' + Pair.JsonString.Value + '" = :' + Pair.JsonString.Value;
  end;

  SQL := 'UPDATE "' + TableName + '" SET ' + SetClause;
  if WhereClause <> '' then
    SQL := SQL + ' WHERE ' + WhereClause;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text := SQL;

    // Bind parameters
    for i := 0 to Data.Count - 1 do
    begin
      Pair := Data.Pairs[i];
      if Pair.JsonValue is TJSONNull then
        Query.ParamByName(Pair.JsonString.Value).Clear
      else if Pair.JsonValue is TJSONNumber then
        Query.ParamByName(Pair.JsonString.Value).AsFloat := TJSONNumber(Pair.JsonValue).AsDouble
      else if Pair.JsonValue is TJSONString then
        Query.ParamByName(Pair.JsonString.Value).AsString := TJSONString(Pair.JsonValue).Value
      else if Pair.JsonValue is TJSONTrue then
        Query.ParamByName(Pair.JsonString.Value).AsInteger := 1
      else if Pair.JsonValue is TJSONFalse then
        Query.ParamByName(Pair.JsonString.Value).AsInteger := 0
      else
        Query.ParamByName(Pair.JsonString.Value).AsString := Pair.JsonValue.ToString;
    end;

    Query.ExecSQL;
    ClearError;
    Result := True;
  except
    on E: Exception do
    begin
      SetError(SQL_ERR_EXEC_FAILED, E.Message);
      Result := False;
    end;
  end;
  Query.Free;
end;

//==============================================================================
// Plan9Basic Function Implementations
//==============================================================================

//------------------------------------------------------------------------------
// Error Handling Functions
//------------------------------------------------------------------------------

// sql_error@ - Get last error code
function n_sql_error(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := lastError;
  Result.p := nil;
  Result.s := '';
end;

// sql_errormsg$@ - Get last error message
function s_sql_errormsg(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := lastErrorMsg;
end;

// sql_strerror$@n - Get error message for code
function s_sql_strerror(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := GetErrorMessage(Trunc(Args[0].n));
end;

// sql_clearerror@ - Clear error state
function n_sql_clearerror(var Args: Array of TAsmData): TAsmData;
begin
  ClearError;
  Result.n := 0;
  Result.p := nil;
  Result.s := '';
end;

//------------------------------------------------------------------------------
// Connection Management Functions
//------------------------------------------------------------------------------

// sql_open#@$ - Open database
function p_sql_open(var Args: Array of TAsmData): TAsmData;
var
  Conn: TBasSqliteConn;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  Conn := TBasSqliteConn.Create;
  if Conn.Open(Args[0].s) then
  begin
    GC.Add<TBasSqliteConn>(Conn, SQL_GC_TAG);
    Result.p := Conn;
  end
  else
  begin
    Conn.Free;
    Result.p := nil;
  end;
end;

// sql_open#@ - Open in-memory database
function p_sql_openmem(var Args: Array of TAsmData): TAsmData;
var
  Conn: TBasSqliteConn;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  Conn := TBasSqliteConn.Create;
  if Conn.OpenMemory then
  begin
    GC.Add<TBasSqliteConn>(Conn, SQL_GC_TAG);
    Result.p := Conn;
  end
  else
  begin
    Conn.Free;
    Result.p := nil;
  end;
end;

// sql_close@# - Close database
function n_sql_close(var Args: Array of TAsmData): TAsmData;
var
  Conn: TBasSqliteConn;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_close');
    Conn := TBasSqliteConn(Args[0].p);
    Conn.Close;
    Result.n := 1;
  except
    Result.n := 0;
  end;
end;

// sql_isopen@# - Check if database is open
function n_sql_isopen(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_isopen');
    if TBasSqliteConn(Args[0].p).IsOpen then
      Result.n := 1
    else
      Result.n := 0;
  except
    Result.n := 0;
  end;
end;

// sql_path$@# - Get database path
function s_sql_path(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_path$');
    Result.s := TBasSqliteConn(Args[0].p).Path;
  except
  end;
end;

// sql_version$@ - Get SQLite version
function s_sql_version(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '3.x (FireDAC)';  // FireDAC handles SQLite version internally
end;

//------------------------------------------------------------------------------
// SQL Execution Functions
//------------------------------------------------------------------------------

// sql_exec@#$ - Execute SQL (no results)
function n_sql_exec(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_exec');
    if TBasSqliteConn(Args[0].p).ExecSQL(Args[1].s) then
      Result.n := 1
    else
      Result.n := 0;
  except
    Result.n := 0;
  end;
end;

// sql_exec@#$# - Execute SQL with JSON parameters
function n_sql_execjson(var Args: Array of TAsmData): TAsmData;
var
  Json: TJSONObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_exec');
    Json := nil;
    if Args[2].p <> nil then
      Json := TJSONObject(Args[2].p);

    if TBasSqliteConn(Args[0].p).ExecSQLJson(Args[1].s, Json) then
      Result.n := 1
    else
      Result.n := 0;
  except
    Result.n := 0;
  end;
end;

// sql_query#@#$ - Execute query, return cursor
function p_sql_query(var Args: Array of TAsmData): TAsmData;
var
  Stmt: TBasSqliteStmt;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_query#');
    Stmt := TBasSqliteConn(Args[0].p).Query(Args[1].s);
    // Note: Statement is owned by connection, NOT added to GC
    Result.p := Stmt;
  except
    Result.p := nil;
  end;
end;

// sql_query#@#$# - Execute query with JSON parameters
function p_sql_queryjson(var Args: Array of TAsmData): TAsmData;
var
  Stmt: TBasSqliteStmt;
  Json: TJSONObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_query#');
    Json := nil;
    if Args[2].p <> nil then
      Json := TJSONObject(Args[2].p);

    Stmt := TBasSqliteConn(Args[0].p).QueryJson(Args[1].s, Json);
    // Note: Statement is owned by connection, NOT added to GC
    Result.p := Stmt;
  except
    Result.p := nil;
  end;
end;

//------------------------------------------------------------------------------
// Statement Management Functions
//------------------------------------------------------------------------------

// sql_prepare#@#$ - Prepare a statement
function p_sql_prepare(var Args: Array of TAsmData): TAsmData;
var
  Stmt: TBasSqliteStmt;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_prepare#');
    Stmt := TBasSqliteConn(Args[0].p).Prepare(Args[1].s);
    // Note: Statement is owned by connection, NOT added to GC
    Result.p := Stmt;
  except
    Result.p := nil;
  end;
end;

// sql_step@# - Step through results
function n_sql_step(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := SQL_STEP_ERROR;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_step');
    Result.n := TBasSqliteStmt(Args[0].p).Step;
  except
    Result.n := SQL_STEP_ERROR;
  end;
end;

// sql_reset#@# - Reset cursor
function p_sql_reset(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_reset#');
    TBasSqliteStmt(Args[0].p).Reset;
  except
  end;
end;

// sql_finalize@# - Finalize/free statement
function n_sql_finalize(var Args: Array of TAsmData): TAsmData;
var
  Stmt: TBasSqliteStmt;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_finalize');
    Stmt := TBasSqliteStmt(Args[0].p);
    Stmt.Free;
    Result.n := 1;
  except
    Result.n := 0;
  end;
end;

//------------------------------------------------------------------------------
// Parameter Binding Functions
//------------------------------------------------------------------------------

// sql_bindstr#@#n$ - Bind string parameter by index
function p_sql_bindstr(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_bindstr#');
    TBasSqliteStmt(Args[0].p).BindStr(Trunc(Args[1].n), Args[2].s);
  except
  end;
end;

// sql_bindnum#@#nn - Bind number parameter by index
function p_sql_bindnum(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_bindnum#');
    TBasSqliteStmt(Args[0].p).BindNum(Trunc(Args[1].n), Args[2].n);
  except
  end;
end;

// sql_bindnull#@#n - Bind NULL parameter by index
function p_sql_bindnull(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_bindnull#');
    TBasSqliteStmt(Args[0].p).BindNull(Trunc(Args[1].n));
  except
  end;
end;

// sql_bindjson#@## - Bind parameters from JSON object
function p_sql_bindjson(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_bindjson#');
    if Args[1].p <> nil then
      TBasSqliteStmt(Args[0].p).BindFromJson(TJSONObject(Args[1].p));
  except
  end;
end;

// sql_clearbind#@# - Clear all parameter bindings
function p_sql_clearbind(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := Args[0].p;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_clearbind#');
    TBasSqliteStmt(Args[0].p).ClearBindings;
  except
  end;
end;

//------------------------------------------------------------------------------
// Column Information Functions
//------------------------------------------------------------------------------

// sql_colcount@# - Get column count
function n_sql_colcount(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_colcount');
    Result.n := TBasSqliteStmt(Args[0].p).ColCount;
  except
  end;
end;

// sql_colname$@#n - Get column name by index
function s_sql_colname(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_colname$');
    Result.s := TBasSqliteStmt(Args[0].p).ColName(Trunc(Args[1].n));
  except
  end;
end;

// sql_coltype@#n - Get column type by index
function n_sql_coltype(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := SQL_TYPE_NULL;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_coltype');
    Result.n := TBasSqliteStmt(Args[0].p).ColType(Trunc(Args[1].n));
  except
  end;
end;

// sql_coltypename$@n - Get type name for type code
function s_sql_coltypename(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;

  case Trunc(Args[0].n) of
    SQL_TYPE_NULL:    Result.s := 'NULL';
    SQL_TYPE_INTEGER: Result.s := 'INTEGER';
    SQL_TYPE_FLOAT:   Result.s := 'REAL';
    SQL_TYPE_TEXT:    Result.s := 'TEXT';
    SQL_TYPE_BLOB:    Result.s := 'BLOB';
  else
    Result.s := 'UNKNOWN';
  end;
end;

// sql_colindex@#$ - Get column index by name
function n_sql_colindex(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := -1;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_colindex');
    Result.n := TBasSqliteStmt(Args[0].p).ColIndex(Args[1].s);
  except
  end;
end;

//------------------------------------------------------------------------------
// Result Access Functions (by index)
//------------------------------------------------------------------------------

// sql_getstr$@#n - Get string value by index
function s_sql_getstr(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_getstr$');
    Result.s := TBasSqliteStmt(Args[0].p).GetStr(Trunc(Args[1].n));
  except
  end;
end;

// sql_getnum@#n - Get numeric value by index
function n_sql_getnum(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_getnum');
    Result.n := TBasSqliteStmt(Args[0].p).GetNum(Trunc(Args[1].n));
  except
  end;
end;

// sql_isnull@#n - Check if column is null by index
function n_sql_isnull(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 1;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_isnull');
    if TBasSqliteStmt(Args[0].p).IsNull(Trunc(Args[1].n)) then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// sql_isblob@#n - Check if column is blob by index
function n_sql_isblob(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_isblob');
    if TBasSqliteStmt(Args[0].p).IsBlob(Trunc(Args[1].n)) then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

//------------------------------------------------------------------------------
// Result Access Functions (by name)
//------------------------------------------------------------------------------

// sql_gets$@#$ - Get string value by column name
function s_sql_gets(var Args: Array of TAsmData): TAsmData;
var
  Stmt: TBasSqliteStmt;
  Idx: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_gets$');
    Stmt := TBasSqliteStmt(Args[0].p);
    Idx := Stmt.ColIndex(Args[1].s);
    if Idx >= 0 then
      Result.s := Stmt.GetStr(Idx);
  except
  end;
end;

// sql_getn@#$ - Get numeric value by column name
function n_sql_getn(var Args: Array of TAsmData): TAsmData;
var
  Stmt: TBasSqliteStmt;
  Idx: Integer;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_getn$');
    Stmt := TBasSqliteStmt(Args[0].p);
    Idx := Stmt.ColIndex(Args[1].s);
    if Idx >= 0 then
      Result.n := Stmt.GetNum(Idx);
  except
  end;
end;

// sql_isn@#$ - Check if column is null by name
function n_sql_isn(var Args: Array of TAsmData): TAsmData;
var
  Stmt: TBasSqliteStmt;
  Idx: Integer;
begin
  Result.n := 1;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_isn');
    Stmt := TBasSqliteStmt(Args[0].p);
    Idx := Stmt.ColIndex(Args[1].s);
    if Idx >= 0 then
    begin
      if Stmt.IsNull(Idx) then
        Result.n := 1
      else
        Result.n := 0;
    end;
  except
  end;
end;

//------------------------------------------------------------------------------
// JSON Integration Functions
//------------------------------------------------------------------------------

// sql_row#@# - Get current row as JSON object
function p_sql_row(var Args: Array of TAsmData): TAsmData;
var
  Json: TJSONObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_row#');
    Json := TBasSqliteStmt(Args[0].p).RowToJson;
    GC.Add<TJSONObject>(Json, SQL_GC_TAG);
    Result.p := Json;
  except
    Result.p := nil;
  end;
end;

// sql_fetchall#@# - Fetch all rows as JSON array
function p_sql_fetchall(var Args: Array of TAsmData): TAsmData;
var
  Arr: TJSONArray;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_fetchall#');
    Arr := TBasSqliteStmt(Args[0].p).FetchAll;
    GC.Add<TJSONArray>(Arr, SQL_GC_TAG);
    Result.p := Arr;
  except
    Result.p := nil;
  end;
end;

// sql_fetchone#@# - Fetch one row as JSON and advance
function p_sql_fetchone(var Args: Array of TAsmData): TAsmData;
var
  Json: TJSONObject;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_fetchone#');
    Json := TBasSqliteStmt(Args[0].p).FetchOne;
    if Json <> nil then
    begin
      GC.Add<TJSONObject>(Json, SQL_GC_TAG);
      Result.p := Json;
    end;
  except
    Result.p := nil;
  end;
end;

// sql_insertjson@#$# - Insert JSON object as row
function n_sql_insertjson(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_insertjson');
    if Args[2].p = nil then
    begin
      SetError(SQL_ERR_JSON_INVALID, 'Null JSON object');
      Exit;
    end;

    if TBasSqliteConn(Args[0].p).InsertJson(Args[1].s, TJSONObject(Args[2].p)) then
      Result.n := 1
    else
      Result.n := 0;
  except
    Result.n := 0;
  end;
end;

// sql_updatejson@#$#$ - Update with JSON object
function n_sql_updatejson(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_updatejson');
    if Args[2].p = nil then
    begin
      SetError(SQL_ERR_JSON_INVALID, 'Null JSON object');
      Exit;
    end;

    if TBasSqliteConn(Args[0].p).UpdateJson(Args[1].s, TJSONObject(Args[2].p), Args[3].s) then
      Result.n := 1
    else
      Result.n := 0;
  except
    Result.n := 0;
  end;
end;

//------------------------------------------------------------------------------
// Transaction Functions
//------------------------------------------------------------------------------

// sql_begin@# - Begin transaction
function n_sql_begin(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_begin');
    if TBasSqliteConn(Args[0].p).BeginTrans then
      Result.n := 1
    else
      Result.n := 0;
  except
    Result.n := 0;
  end;
end;

// sql_commit@# - Commit transaction
function n_sql_commit(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_commit');
    if TBasSqliteConn(Args[0].p).Commit then
      Result.n := 1
    else
      Result.n := 0;
  except
    Result.n := 0;
  end;
end;

// sql_rollback@# - Rollback transaction
function n_sql_rollback(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_rollback');
    if TBasSqliteConn(Args[0].p).Rollback then
      Result.n := 1
    else
      Result.n := 0;
  except
    Result.n := 0;
  end;
end;

// sql_intrans@# - Check if in transaction
function n_sql_intrans(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_intrans');
    if TBasSqliteConn(Args[0].p).InTransaction then
      Result.n := 1
    else
      Result.n := 0;
  except
    Result.n := 0;
  end;
end;

//------------------------------------------------------------------------------
// Utility Functions
//------------------------------------------------------------------------------

// sql_lastid@# - Get last insert rowid
function n_sql_lastid(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_lastid');
    Result.n := TBasSqliteConn(Args[0].p).LastInsertId;
  except
  end;
end;

// sql_changes@# - Get number of rows affected
function n_sql_changes(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_changes');
    Result.n := TBasSqliteConn(Args[0].p).RowsAffected;
  except
  end;
end;

// sql_totalchanges@# - Get total changes since connection opened
function n_sql_totalchanges(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_totalchanges');
    Result.n := TBasSqliteConn(Args[0].p).TotalChanges;
  except
  end;
end;

// sql_tableexists@#$ - Check if table exists
function n_sql_tableexists(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_tableexists');
    if TBasSqliteConn(Args[0].p).TableExists(Args[1].s) then
      Result.n := 1
    else
      Result.n := 0;
  except
    Result.n := 0;
  end;
end;

// sql_tables#@# - Get list of tables as JSON array
function p_sql_tables(var Args: Array of TAsmData): TAsmData;
var
  Arr: TJSONArray;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_tables#');
    Arr := TBasSqliteConn(Args[0].p).GetTables;
    GC.Add<TJSONArray>(Arr, SQL_GC_TAG);
    Result.p := Arr;
  except
    Result.p := nil;
  end;
end;

// sql_columns#@#$ - Get column info for table as JSON array
function p_sql_columns(var Args: Array of TAsmData): TAsmData;
var
  Arr: TJSONArray;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_columns#');
    Arr := TBasSqliteConn(Args[0].p).GetColumns(Args[1].s);
    GC.Add<TJSONArray>(Arr, SQL_GC_TAG);
    Result.p := Arr;
  except
    Result.p := nil;
  end;
end;

// sql_backup@#$ - Backup database to file
function n_sql_backup(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_backup');
    if TBasSqliteConn(Args[0].p).Backup(Args[1].s) then
      Result.n := 1
    else
      Result.n := 0;
  except
    Result.n := 0;
  end;
end;

// sql_vacuum@# - Vacuum database
function n_sql_vacuum(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 0;
  Result.p := nil;
  Result.s := '';

  try
    ValidateConn(Args[0].p, 'sql_vacuum');
    if TBasSqliteConn(Args[0].p).Vacuum then
      Result.n := 1
    else
      Result.n := 0;
  except
    Result.n := 0;
  end;
end;

// sql_eof@# - Check if cursor is at end
function n_sql_eof(var Args: Array of TAsmData): TAsmData;
begin
  Result.n := 1;
  Result.p := nil;
  Result.s := '';

  try
    ValidateStmt(Args[0].p, 'sql_eof');
    if TBasSqliteStmt(Args[0].p).Eof then
      Result.n := 1
    else
      Result.n := 0;
  except
  end;
end;

// sql_escape$@$ - Escape string for SQL
function s_sql_escape(var Args: Array of TAsmData): TAsmData;
var
  S: String;
begin
  Result.n := 0;
  Result.p := nil;
  S := Args[0].s;
  S := StringReplace(S, '''', '''''', [rfReplaceAll]);
  Result.s := S;
end;

// sql_quote$@$ - Quote and escape string for SQL
function s_sql_quote(var Args: Array of TAsmData): TAsmData;
var
  S: String;
begin
  Result.n := 0;
  Result.p := nil;
  S := Args[0].s;
  S := StringReplace(S, '''', '''''', [rfReplaceAll]);
  Result.s := '''' + S + '''';
end;

//==============================================================================
// Function Registration
//==============================================================================

procedure RegisterSqliteFuncs(Funcs: TFunctionsDictionary; Eng: TBasicEngine; OutP: TStrings);
var
  Fn: TLinkFunction;
begin
  // Store module-level references
  ModuleEngine := Eng;
  ModuleOutput := OutP;

  Fn.FarCall := True;

  //----------------------------------------------------------------------------
  // Error handling
  //----------------------------------------------------------------------------
  Fn.Entry := @n_sql_error; Funcs.Add('sql_error@', Fn);
  Fn.Entry := @s_sql_errormsg; Funcs.Add('sql_errormsg$@', Fn);
  Fn.Entry := @s_sql_strerror; Funcs.Add('sql_strerror$@n', Fn);
  Fn.Entry := @n_sql_clearerror; Funcs.Add('sql_clearerror@', Fn);

  //----------------------------------------------------------------------------
  // Connection management
  //----------------------------------------------------------------------------
  Fn.Entry := @p_sql_open; Funcs.Add('sql_open#@$', Fn);
  Fn.Entry := @p_sql_openmem; Funcs.Add('sql_open#@', Fn);
  Fn.Entry := @n_sql_close; Funcs.Add('sql_close@#', Fn);
  Fn.Entry := @n_sql_isopen; Funcs.Add('sql_isopen@#', Fn);
  Fn.Entry := @s_sql_path; Funcs.Add('sql_path$@#', Fn);
  Fn.Entry := @s_sql_version; Funcs.Add('sql_version$@', Fn);

  //----------------------------------------------------------------------------
  // SQL execution
  //----------------------------------------------------------------------------
  Fn.Entry := @n_sql_exec; Funcs.Add('sql_exec@#$', Fn);
  Fn.Entry := @n_sql_execjson; Funcs.Add('sql_exec@#$#', Fn);
  Fn.Entry := @p_sql_query; Funcs.Add('sql_query#@#$', Fn);
  Fn.Entry := @p_sql_queryjson; Funcs.Add('sql_query#@#$#', Fn);

  //----------------------------------------------------------------------------
  // Statement management
  //----------------------------------------------------------------------------
  Fn.Entry := @p_sql_prepare; Funcs.Add('sql_prepare#@#$', Fn);
  Fn.Entry := @n_sql_step; Funcs.Add('sql_step@#', Fn);
  Fn.Entry := @p_sql_reset; Funcs.Add('sql_reset#@#', Fn);
  Fn.Entry := @n_sql_finalize; Funcs.Add('sql_finalize@#', Fn);
  Fn.Entry := @n_sql_eof; Funcs.Add('sql_eof@#', Fn);

  //----------------------------------------------------------------------------
  // Parameter binding
  //----------------------------------------------------------------------------
  Fn.Entry := @p_sql_bindstr; Funcs.Add('sql_bindstr#@#n$', Fn);
  Fn.Entry := @p_sql_bindnum; Funcs.Add('sql_bindnum#@#nn', Fn);
  Fn.Entry := @p_sql_bindnull; Funcs.Add('sql_bindnull#@#n', Fn);
  Fn.Entry := @p_sql_bindjson; Funcs.Add('sql_bindjson#@##', Fn);
  Fn.Entry := @p_sql_clearbind; Funcs.Add('sql_clearbind#@#', Fn);

  //----------------------------------------------------------------------------
  // Column information
  //----------------------------------------------------------------------------
  Fn.Entry := @n_sql_colcount; Funcs.Add('sql_colcount@#', Fn);
  Fn.Entry := @s_sql_colname; Funcs.Add('sql_colname$@#n', Fn);
  Fn.Entry := @n_sql_coltype; Funcs.Add('sql_coltype@#n', Fn);
  Fn.Entry := @s_sql_coltypename; Funcs.Add('sql_coltypename$@n', Fn);
  Fn.Entry := @n_sql_colindex; Funcs.Add('sql_colindex@#$', Fn);

  //----------------------------------------------------------------------------
  // Result access (by index)
  //----------------------------------------------------------------------------
  Fn.Entry := @s_sql_getstr; Funcs.Add('sql_getstr$@#n', Fn);
  Fn.Entry := @n_sql_getnum; Funcs.Add('sql_getnum@#n', Fn);
  Fn.Entry := @n_sql_isnull; Funcs.Add('sql_isnull@#n', Fn);
  Fn.Entry := @n_sql_isblob; Funcs.Add('sql_isblob@#n', Fn);

  //----------------------------------------------------------------------------
  // Result access (by name)
  //----------------------------------------------------------------------------
  Fn.Entry := @s_sql_gets; Funcs.Add('sql_gets$@#$', Fn);
  Fn.Entry := @n_sql_getn; Funcs.Add('sql_getn@#$', Fn);
  Fn.Entry := @n_sql_isn; Funcs.Add('sql_isn@#$', Fn);

  //----------------------------------------------------------------------------
  // JSON integration
  //----------------------------------------------------------------------------
  Fn.Entry := @p_sql_row; Funcs.Add('sql_row#@#', Fn);
  Fn.Entry := @p_sql_fetchall; Funcs.Add('sql_fetchall#@#', Fn);
  Fn.Entry := @p_sql_fetchone; Funcs.Add('sql_fetchone#@#', Fn);
  Fn.Entry := @n_sql_insertjson; Funcs.Add('sql_insertjson@#$#', Fn);
  Fn.Entry := @n_sql_updatejson; Funcs.Add('sql_updatejson@#$#$', Fn);

  //----------------------------------------------------------------------------
  // Transaction support
  //----------------------------------------------------------------------------
  Fn.Entry := @n_sql_begin; Funcs.Add('sql_begin@#', Fn);
  Fn.Entry := @n_sql_commit; Funcs.Add('sql_commit@#', Fn);
  Fn.Entry := @n_sql_rollback; Funcs.Add('sql_rollback@#', Fn);
  Fn.Entry := @n_sql_intrans; Funcs.Add('sql_intrans@#', Fn);

  //----------------------------------------------------------------------------
  // Utility functions
  //----------------------------------------------------------------------------
  Fn.Entry := @n_sql_lastid; Funcs.Add('sql_lastid@#', Fn);
  Fn.Entry := @n_sql_changes; Funcs.Add('sql_changes@#', Fn);
  Fn.Entry := @n_sql_totalchanges; Funcs.Add('sql_totalchanges@#', Fn);
  Fn.Entry := @n_sql_tableexists; Funcs.Add('sql_tableexists@#$', Fn);
  Fn.Entry := @p_sql_tables; Funcs.Add('sql_tables#@#', Fn);
  Fn.Entry := @p_sql_columns; Funcs.Add('sql_columns#@#$', Fn);
  Fn.Entry := @n_sql_backup; Funcs.Add('sql_backup@#$', Fn);
  Fn.Entry := @n_sql_vacuum; Funcs.Add('sql_vacuum@#', Fn);

  //----------------------------------------------------------------------------
  // String helpers
  //----------------------------------------------------------------------------
  Fn.Entry := @s_sql_escape; Funcs.Add('sql_escape$@$', Fn);
  Fn.Entry := @s_sql_quote; Funcs.Add('sql_quote$@$', Fn);
end;

initialization
  // Create FireDAC driver link for SQLite
  FDPhysSQLiteDriverLink := TFDPhysSQLiteDriverLink.Create(nil);

finalization
  // Free driver link
  if Assigned(FDPhysSQLiteDriverLink) then
    FreeAndNil(FDPhysSQLiteDriverLink);

end.

