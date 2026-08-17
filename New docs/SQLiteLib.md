# SqliteLib - SQLite Database Library for Plan9Basic

## Overview

SqliteLib provides comprehensive SQLite database functionality for Plan9Basic, enabling applets to create, query, and manage SQLite databases. The library features seamless JSON integration for reading and writing records, making it easy to work with structured data.

**Version:** 1.0  
**Function Count:** 55+ functions  
**Dependencies:** JsonLib

## Key Features

- **Database Management**: Open, close, and manage SQLite database files
- **SQL Execution**: Execute queries and statements with parameter binding
- **JSON Integration**: Read/write records as JSON objects
- **Transaction Support**: Full ACID transaction support
- **Error Handling**: Comprehensive error codes and messages
- **Table Introspection**: Query table structure and metadata

## Memory Management

The library uses a parent-child ownership model:
- **Database connections** are managed by the garbage collector
- **Statements/cursors** are owned by their parent connection (NOT in GC)
- When a connection is freed, all its statements are automatically freed

This design prevents double-free issues during cleanup.

---

## Error Handling

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | SQL_ERR_NONE | No error |
| 1 | SQL_ERR_NOT_OPEN | Database not open |
| 2 | SQL_ERR_INVALID_CONN | Invalid connection |
| 3 | SQL_ERR_INVALID_STMT | Invalid statement |
| 4 | SQL_ERR_EXEC_FAILED | SQL execution failed |
| 5 | SQL_ERR_QUERY_FAILED | Query execution failed |
| 6 | SQL_ERR_PREPARE_FAIL | Statement preparation failed |
| 7 | SQL_ERR_BIND_FAILED | Parameter binding failed |
| 8 | SQL_ERR_STEP_FAILED | Step execution failed |
| 9 | SQL_ERR_COLUMN_INDEX | Column index out of bounds |
| 10 | SQL_ERR_COLUMN_NAME | Column not found |
| 11 | SQL_ERR_TRANSACTION | Transaction error |
| 12 | SQL_ERR_FILE_ERROR | File operation error |
| 13 | SQL_ERR_JSON_INVALID | Invalid JSON data |
| 14 | SQL_ERR_TABLE_ERROR | Table operation error |
| 15 | SQL_ERR_BACKUP_FAILED | Database backup failed |

### Column Type Codes

| Code | Constant | Description |
|------|----------|-------------|
| 0 | SQL_TYPE_NULL | NULL value |
| 1 | SQL_TYPE_INTEGER | Integer value |
| 2 | SQL_TYPE_FLOAT | Floating point value |
| 3 | SQL_TYPE_TEXT | Text/string value |
| 4 | SQL_TYPE_BLOB | Binary data |

### Step Result Codes

| Code | Constant | Description |
|------|----------|-------------|
| 1 | SQL_STEP_ROW | Row available |
| 0 | SQL_STEP_DONE | No more rows |
| -1 | SQL_STEP_ERROR | Error occurred |

---

## Function Reference

### Error Handling Functions

#### sql_error()
Returns the last error code.

```basic
let errCode = sql_error()
if errCode <> 0 then
    println "Error: " + sql_errormsg$()
endif
```

#### sql_errormsg$()
Returns the last error message as a string.

```basic
let msg$ = sql_errormsg$()
```

#### sql_strerror$(errCode)
Returns the error message for a specific error code.

```basic
let msg$ = sql_strerror$(5)  ' Returns "Query execution failed"
```

#### sql_clearerror()
Clears the current error state.

```basic
sql_clearerror()
```

---

### Connection Management Functions

#### sql_open#(db$)
Opens a database file. Creates the file if it doesn't exist.

```basic
let db# = sql_open#("mydata.db")
if PntToNum(db#) = 0 then
    println "Failed to open database: " + sql_errormsg$()
endif
```

#### sql_open#()
Opens an in-memory database (data is lost when connection closes).

```basic
let db# = sql_open#()  ' In-memory database
```

#### sql_close(db#)
Closes the database connection.

```basic
sql_close(db#)
```

#### sql_isopen(db#)
Checks if the database connection is open (returns 1 or 0).

```basic
if sql_isopen(db#) = 1 then
    println "Database is open"
endif
```

#### sql_path$(db#)
Returns the database file path.

```basic
let path$ = sql_path$(db#)
println "Database path: " + path$
```

#### sql_version$()
Returns the SQLite version string.

```basic
println "SQLite version: " + sql_version$()
```

---

### SQL Execution Functions

#### sql_exec(db#, sql$)
Executes an SQL statement that doesn't return results (INSERT, UPDATE, DELETE, CREATE, etc.).

```basic
let ok = sql_exec(db#, "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT, age INTEGER)")
if ok = 1 then
    println "Table created successfully"
endif
```

#### sql_exec(db#, sql$, params#)
Executes SQL with parameters from a JSON object.

```basic
let params# = json_object#()
json_sets#(params#, "name", "John")
json_setn#(params#, "age", 30)

let ok = sql_exec(db#, "INSERT INTO users (name, age) VALUES (:name, :age)", params#)
```

#### sql_query#(db#, sql$)
Executes a SELECT query and returns a cursor.

```basic
let cursor# = sql_query#(db#, "SELECT * FROM users")
while sql_step(cursor#) = 1
    println sql_gets$(cursor#, "name")
end while
sql_finalize(cursor#)
```

#### sql_query#(db#, sql$, params#)
Executes a SELECT query with JSON parameters.

```basic
let params# = json_object#()
json_setn#(params#, "minAge", 18)

let cursor# = sql_query#(db#, "SELECT * FROM users WHERE age >= :minAge", params#)
```

---

### Statement Management Functions

#### sql_prepare#(db#, sql$)
Prepares an SQL statement for repeated execution.

```basic
let stmt# = sql_prepare#(db#, "INSERT INTO users (name, age) VALUES (:name, :age)")
```

#### sql_step(stmt#)
Executes one step of the statement. Returns 1 (row available), 0 (done), or -1 (error).

```basic
let result = sql_step(cursor#)
if result = 1 then
    ' Process row
else if result = 0 then
    ' No more rows
else
    ' Error occurred
endif
```

#### sql_reset#(stmt#)
Resets the statement for re-execution (allows reuse with new parameters).

```basic
sql_reset#(stmt#)
```

#### sql_finalize(stmt#)
Finalizes (frees) the statement.

```basic
sql_finalize(stmt#)
```

#### sql_eof(stmt#)
Checks if the cursor has reached the end of results.

```basic
while sql_eof(cursor#) = 0
    ' Process row
    sql_step(cursor#)
end while
```

---

### Parameter Binding Functions

#### sql_bindstr#(stmt#, index, value$)
Binds a string value to a parameter by index (0-based).

```basic
let stmt# = sql_prepare#(db#, "INSERT INTO users (name) VALUES (?)")
sql_bindstr#(stmt#, 0, "Alice")
sql_step(stmt#)
```

#### sql_bindnum#(stmt#, index, value)
Binds a numeric value to a parameter by index.

```basic
let stmt# = sql_prepare#(db#, "UPDATE users SET age = ? WHERE id = ?")
sql_bindnum#(stmt#, 0, 25)
sql_bindnum#(stmt#, 1, 1)
sql_step(stmt#)
```

#### sql_bindnull#(stmt#, index)
Binds NULL to a parameter by index.

```basic
sql_bindnull#(stmt#, 0)
```

#### sql_bindjson#(stmt#, params#)
Binds all parameters from a JSON object (by parameter name).

```basic
let params# = json_object#()
json_sets#(params#, "name", "Bob")
json_setn#(params#, "age", 35)

let stmt# = sql_prepare#(db#, "INSERT INTO users (name, age) VALUES (:name, :age)")
sql_bindjson#(stmt#, params#)
sql_step(stmt#)
```

#### sql_clearbind#(stmt#)
Clears all parameter bindings.

```basic
sql_clearbind#(stmt#)
```

---

### Column Information Functions

#### sql_colcount(stmt#)
Returns the number of columns in the result set.

```basic
let cursor# = sql_query#(db#, "SELECT * FROM users")
println "Columns: " + str$(sql_colcount(cursor#))
```

#### sql_colname$(stmt#, index)
Returns the column name at the specified index (0-based).

```basic
for i = 0 to sql_colcount(cursor#) - 1
    println "Column " + str$(i) + ": " + sql_colname$(cursor#, i)
next
```

#### sql_coltype(stmt#, index)
Returns the column type code at the specified index.

```basic
let colType = sql_coltype(cursor#, 0)
```

#### sql_coltypename$(typeCode)
Returns the type name for a type code.

```basic
println "Type: " + sql_coltypename$(sql_coltype(cursor#, 0))
```

#### sql_colindex(stmt#, colName$)
Returns the column index for a column name (-1 if not found).

```basic
let idx = sql_colindex(cursor#, "name")
```

---

### Result Access Functions (by Index)

#### sql_getstr$(stmt#, index)
Gets a string value from the specified column index.

```basic
let name$ = sql_getstr$(cursor#, 0)
```

#### sql_getnum(stmt#, index)
Gets a numeric value from the specified column index.

```basic
let age = sql_getnum(cursor#, 1)
```

#### sql_isnull(stmt#, index)
Checks if the column value is NULL (returns 1 or 0).

```basic
if sql_isnull(cursor#, 2) = 1 then
    println "Value is NULL"
endif
```

#### sql_isblob(stmt#, index)
Checks if the column contains BLOB data (returns 1 or 0).

```basic
if sql_isblob(cursor#, 3) = 1 then
    println "Column contains binary data"
endif
```

---

### Result Access Functions (by Name)

#### sql_gets$(stmt#, colName$)
Gets a string value by column name.

```basic
let name$ = sql_gets$(cursor#, "name")
```

#### sql_getn(stmt#, colName$)
Gets a numeric value by column name.

```basic
let age = sql_getn(cursor#, "age")
```

#### sql_isn(stmt#, colName$)
Checks if the named column is NULL.

```basic
if sql_isn(cursor#, "email") = 1 then
    println "Email is not set"
endif
```

---

### JSON Integration Functions

These functions provide seamless integration with JsonLib.

#### sql_row#(stmt#)
Returns the current row as a JSON object.

```basic
let cursor# = sql_query#(db#, "SELECT * FROM users WHERE id = 1")
if sql_step(cursor#) = 1 then
    let row# = sql_row#(cursor#)
    println json_stringify$(row#)
endif
```

#### sql_fetchall#(stmt#)
Fetches all rows as a JSON array. Opens the query if not already active.

```basic
let cursor# = sql_query#(db#, "SELECT * FROM users")
let allRows# = sql_fetchall#(cursor#)
println "Total rows: " + str$(json_len(allRows#))
sql_finalize(cursor#)
```

#### sql_fetchone#(stmt#)
Fetches the current row as JSON and advances to the next.

```basic
let cursor# = sql_query#(db#, "SELECT * FROM users")
let row# = Pointer#(0)
row# = sql_fetchone#(cursor#)
while PntToNum(row#) <> 0
    println json_stringify$(row#)
    row# = sql_fetchone#(cursor#)
end while
```

#### sql_insertjson(db#, table$, data#)
Inserts a JSON object as a new row.

```basic
let user# = json_object#()
json_sets#(user#, "name", "Charlie")
json_setn#(user#, "age", 28)

if sql_insertjson(db#, "users", user#) = 1 then
    println "User inserted with ID: " + str$(sql_lastid(db#))
endif
```

#### sql_updatejson(db#, table$, data#, where$)
Updates rows using a JSON object for SET values.

```basic
let updates# = json_object#()
json_setn#(updates#, "age", 29)

if sql_updatejson(db#, "users", updates#, "name = 'Charlie'") = 1 then
    println "Updated " + str$(sql_changes(db#)) + " rows"
endif
```

---

### Transaction Functions

#### sql_begin(db#)
Begins a transaction.

```basic
if sql_begin(db#) = 1 then
    ' Transaction started
endif
```

#### sql_commit(db#)
Commits the current transaction.

```basic
if sql_commit(db#) = 1 then
    println "Transaction committed"
endif
```

#### sql_rollback(db#)
Rolls back the current transaction.

```basic
if sql_rollback(db#) = 1 then
    println "Transaction rolled back"
endif
```

#### sql_intrans(db#)
Checks if currently in a transaction.

```basic
if sql_intrans(db#) = 1 then
    println "In transaction"
endif
```

**Transaction Example:**

```basic
sql_begin(db#)

let ok = sql_exec(db#, "UPDATE accounts SET balance = balance - 100 WHERE id = 1")
if ok = 1 then
    ok = sql_exec(db#, "UPDATE accounts SET balance = balance + 100 WHERE id = 2")
endif

if ok = 1 then
    sql_commit(db#)
    println "Transfer complete"
else
    sql_rollback(db#)
    println "Transfer failed"
endif
```

---

### Utility Functions

#### sql_lastid(db#)
Returns the rowid of the last inserted row.

```basic
sql_exec(db#, "INSERT INTO users (name) VALUES ('Test')")
println "New ID: " + str$(sql_lastid(db#))
```

#### sql_changes(db#)
Returns the number of rows affected by the last statement.

```basic
sql_exec(db#, "DELETE FROM users WHERE age < 18")
println "Deleted " + str$(sql_changes(db#)) + " users"
```

#### sql_totalchanges(db#)
Returns the total number of row changes since the connection was opened.

```basic
println "Total changes: " + str$(sql_totalchanges(db#))
```

#### sql_tableexists(db#, table$)
Checks if a table exists (returns 1 or 0).

```basic
if sql_tableexists(db#, "users") = 1 then
    println "Table exists"
else
    println "Table does not exist"
endif
```

#### sql_tables#(db#)
Returns a JSON array of all table names.

```basic
let tables# = sql_tables#(db#)
for i = 0 to json_len(tables#) - 1
    println json_items$(tables#, i)
next
```

#### sql_columns#(db#, table$)
Returns column information for a table as a JSON array.

```basic
let cols# = sql_columns#(db#, "users")
for i = 0 to json_len(cols#) - 1
    let col# = json_item#(cols#, i)
    println json_gets$(col#, "name") + " - " + json_gets$(col#, "type")
next
```

Each column object contains: `cid`, `name`, `type`, `notnull`, `pk`, `default`

#### sql_backup(db#, file$)
Backs up the database to a file.

```basic
if sql_backup(db#, "backup.db") = 1 then
    println "Backup created successfully"
endif
```

#### sql_vacuum(db#)
Optimizes the database by rebuilding it.

```basic
sql_vacuum(db#)
```

---

### String Helper Functions

#### sql_escape$(str$)
Escapes a string for use in SQL (doubles single quotes).

```basic
let safe$ = sql_escape$("O'Brien")  ' Returns "O''Brien"
```

#### sql_quote$(str$)
Escapes and wraps a string in single quotes.

```basic
let quoted$ = sql_quote$("O'Brien")  ' Returns "'O''Brien'"
```

---

## Complete Examples

### Example 1: Basic CRUD Operations

```basic
' Create or open database
let db# = sql_open#("contacts.db")

' Create table if not exists
sql_exec(db#, "CREATE TABLE IF NOT EXISTS contacts (id INTEGER PRIMARY KEY, name TEXT, phone TEXT, email TEXT)")

' Insert records
let c1# = json_object#()
json_sets#(c1#, "name", "Alice Smith")
json_sets#(c1#, "phone", "555-0100")
json_sets#(c1#, "email", "alice@example.com")
sql_insertjson(db#, "contacts", c1#)

let c2# = json_object#()
json_sets#(c2#, "name", "Bob Jones")
json_sets#(c2#, "phone", "555-0200")
sql_insertjson(db#, "contacts", c2#)

' Query all contacts
println "All Contacts:"
println "============="
let cursor# = sql_query#(db#, "SELECT * FROM contacts ORDER BY name")
while sql_step(cursor#) = 1
    println sql_gets$(cursor#, "name") + " - " + sql_gets$(cursor#, "phone")
end while
sql_finalize(cursor#)

' Update a contact
let upd# = json_object#()
json_sets#(upd#, "email", "bob.jones@example.com")
sql_updatejson(db#, "contacts", upd#, "name = 'Bob Jones'")

' Delete contacts without email
sql_exec(db#, "DELETE FROM contacts WHERE email IS NULL")
println ""
println "Deleted " + str$(sql_changes(db#)) + " contacts without email"

' Close database
sql_close(db#)
```

### Example 2: Working with JSON

```basic
let db# = sql_open#("products.db")

sql_exec(db#, "CREATE TABLE IF NOT EXISTS products (id INTEGER PRIMARY KEY, name TEXT, price REAL, stock INTEGER)")

' Insert products using JSON
let products# = json_array#()
let p1# = json_object#()
json_sets#(p1#, "name", "Widget")
json_setn#(p1#, "price", 9.99)
json_setn#(p1#, "stock", 100)
json_push#(products#, p1#)

let p2# = json_object#()
json_sets#(p2#, "name", "Gadget")
json_setn#(p2#, "price", 19.99)
json_setn#(p2#, "stock", 50)
json_push#(products#, p2#)

' Insert each product
for i = 0 to json_len(products#) - 1
    let prod# = json_item#(products#, i)
    sql_insertjson(db#, "products", prod#)
next

' Query and get all as JSON array
let cursor# = sql_query#(db#, "SELECT * FROM products")
sql_step(cursor#)
let allProducts# = sql_fetchall#(cursor#)

' Pretty print the JSON
println json_pretty$(allProducts#)

sql_close(db#)
```

### Example 3: Transactions and Error Handling

```basic
let db# = sql_open#("bank.db")

' Create accounts table
sql_exec(db#, "CREATE TABLE IF NOT EXISTS accounts (id INTEGER PRIMARY KEY, name TEXT, balance REAL)")

' Insert test data
sql_exec(db#, "INSERT OR IGNORE INTO accounts (id, name, balance) VALUES (1, 'Savings', 1000)")
sql_exec(db#, "INSERT OR IGNORE INTO accounts (id, name, balance) VALUES (2, 'Checking', 500)")

' Transfer function
function Transfer(db#, fromId, toId, amount) local ok
    ok = 1
    
    ' Start transaction
    if sql_begin(db#) = 0 then
        println "Failed to begin transaction"
        return 0
    endfunction
    
    ' Debit source account
    let params# = json_object#()
    json_setn#(params#, "amount", amount)
    json_setn#(params#, "id", fromId)
    
    ok = sql_exec(db#, "UPDATE accounts SET balance = balance - :amount WHERE id = :id AND balance >= :amount", params#)
    
    if ok = 0 then
        println "Debit failed: " + sql_errormsg$()
        sql_rollback(db#)
        return 0
    endfunction
    
    if sql_changes(db#) = 0 then
        println "Insufficient funds"
        sql_rollback(db#)
        return 0
    endfunction
    
    ' Credit destination account
    json_setn#(params#, "id", toId)
    ok = sql_exec(db#, "UPDATE accounts SET balance = balance + :amount WHERE id = :id", params#)
    
    if ok = 0 then
        println "Credit failed: " + sql_errormsg$()
        sql_rollback(db#)
        return 0
    endfunction
    
    ' Commit transaction
    if sql_commit(db#) = 1 then
        println "Transfer complete"
        return 1
    else
        println "Commit failed"
        sql_rollback(db#)
        return 0
    endfunction
endfunction

' Perform transfer
Transfer(db#, 1, 2, 200)

' Show final balances
let cursor# = sql_query#(db#, "SELECT * FROM accounts")
while sql_step(cursor#) = 1
    println sql_gets$(cursor#, "name") + ": $" + str$(sql_getn(cursor#, "balance"))
end while
sql_finalize(cursor#)

sql_close(db#)
```

### Example 4: Table Introspection

```basic
let db# = sql_open#("sample.db")

' Create sample tables
sql_exec(db#, "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, username TEXT NOT NULL, email TEXT)")
sql_exec(db#, "CREATE TABLE IF NOT EXISTS posts (id INTEGER PRIMARY KEY, user_id INTEGER, title TEXT, body TEXT)")

' List all tables
println "Tables in database:"
println "==================="
let tables# = sql_tables#(db#)
for i = 0 to json_len(tables#) - 1
    let tableName$ = json_items$(tables#, i)
    println ""
    println "Table: " + tableName$
    
    ' Get columns for this table
    let cols# = sql_columns#(db#, tableName$)
    for j = 0 to json_len(cols#) - 1
        let col# = json_item#(cols#, j)
        let colInfo$ = "  - " + json_gets$(col#, "name")
        colInfo$ = colInfo$ + " (" + json_gets$(col#, "type") + ")"
        
        if json_getn(col#, "pk") = 1 then
            colInfo$ = colInfo$ + " PRIMARY KEY"
        endif
        
        if json_getn(col#, "notnull") = 1 then
            colInfo$ = colInfo$ + " NOT NULL"
        endif
        
        println colInfo$
    next
next

sql_close(db#)
```

---

## Best Practices

1. **Always check for errors** after operations that can fail (open, exec, query)
2. **Use transactions** for multiple related operations
3. **Use prepared statements** with parameter binding to prevent SQL injection
4. **Close cursors** with `sql_finalize` when done iterating
5. **Use JSON functions** for cleaner code when working with multiple fields
6. **Backup regularly** using `sql_backup` for important databases

## See Also

- [JsonLib Documentation](JsonLib_Documentation.md) - JSON manipulation functions
- [StdLib Documentation](StdLib_Documentation.md) - Standard library functions
