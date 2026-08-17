'==============================================================================
' SqliteLib Example 3: Transactions and Table Introspection
' Demonstrates: Transactions, error handling, schema inspection
'==============================================================================

println "=== SQLite Transactions & Introspection Example ==="
println ""

' Open database
let db# = sql_open#(docsdir$() + "banking.db")
if PntToNum(db#) = 0 then
    println "ERROR: " + sql_errormsg$()
    end
endif

' Create schema
println "Creating database schema..."
sql_exec(db#, "DROP TABLE IF EXISTS transactions")
sql_exec(db#, "DROP TABLE IF EXISTS accounts")

let sql1$ = "CREATE TABLE accounts ("
sql1$ = sql1$ + "id INTEGER PRIMARY KEY, "
sql1$ = sql1$ + "name TEXT NOT NULL, "
sql1$ = sql1$ + "type TEXT CHECK(type IN ('checking', 'savings')), "
sql1$ = sql1$ + "balance REAL DEFAULT 0.00 CHECK(balance >= 0))"
sql_exec(db#, sql1$)

let sql2$ = "CREATE TABLE transactions ("
sql2$ = sql2$ + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
sql2$ = sql2$ + "from_account INTEGER, "
sql2$ = sql2$ + "to_account INTEGER, "
sql2$ = sql2$ + "amount REAL NOT NULL, "
sql2$ = sql2$ + "timestamp TEXT DEFAULT CURRENT_TIMESTAMP, "
sql2$ = sql2$ + "FOREIGN KEY (from_account) REFERENCES accounts(id), "
sql2$ = sql2$ + "FOREIGN KEY (to_account) REFERENCES accounts(id))"
sql_exec(db#, sql2$)

' Insert initial accounts
sql_exec(db#, "INSERT INTO accounts (id, name, type, balance) VALUES (1, 'Main Checking', 'checking', 5000)")
sql_exec(db#, "INSERT INTO accounts (id, name, type, balance) VALUES (2, 'Savings Account', 'savings', 10000)")
sql_exec(db#, "INSERT INTO accounts (id, name, type, balance) VALUES (3, 'Emergency Fund', 'savings', 2500)")

println "Schema created with 3 accounts"

'------------------------------------------------------------------------------
' Table Introspection
'------------------------------------------------------------------------------
println ""
println "=== Database Schema ==="

let tables# = sql_tables#(db#)
println "Tables found: " + str$(json_len(tables#))

for i = 0 to json_len(tables#) - 1
    let tableName$ = json_items$(tables#, i)
    println ""
    println "TABLE: " + tableName$
    println mulstring$("-", 40)
    
    let cols# = sql_columns#(db#, tableName$)
    for j = 0 to json_len(cols#) - 1
        let col# = json_item#(cols#, j)
        let info$ = "  " + json_gets$(col#, "name")
        info$ = info$ + " " + json_gets$(col#, "type")
        
        if json_getn(col#, "pk") = 1 then
            info$ = info$ + " [PK]"
        endif
        
        if json_getn(col#, "notnull") = 1 then
            info$ = info$ + " NOT NULL"
        endif
        
        let def$ = json_gets$(col#, "default")
        if def$ <> "" then
            info$ = info$ + " DEFAULT " + def$
        endif
        
        println info$
    next
next

'------------------------------------------------------------------------------
' Function to display account balances
'------------------------------------------------------------------------------
function ShowBalances(db#) local cursor#, bal$
    println ""
    println "Current Balances:"
    println mulstring$("-", 30)
    let cursor# = sql_query#(db#, "SELECT id, name, balance FROM accounts ORDER BY id")
    while sql_step(cursor#) = 1
        let bal$ = stri$(sql_getn(cursor#, "balance"), 2)
        println str$(sql_getn(cursor#, "id")) + ". " + sql_gets$(cursor#, "name") + ": $" + bal$
    end while
    sql_finalize(cursor#)
end function

'------------------------------------------------------------------------------
' Transfer function with transaction support
'------------------------------------------------------------------------------
function Transfer(db#, fromId, toId, amount) local success, cursor#, available, params#
    success = 0
    
    println ""
    println "Attempting transfer: $" + stri$(amount, 2) + " from Account " + str$(fromId) + " to Account " + str$(toId)
    
    ' Start transaction
    if sql_begin(db#) = 0 then
        println "ERROR: Could not begin transaction"
        return 0
    end if
    
    ' Check source account balance
    let params# = json_object#()
    json_setn#(params#, "id", fromId)
    cursor# = sql_query#(db#, "SELECT balance FROM accounts WHERE id = :id", params#)
    if sql_step(cursor#) <> 1 then
        println "ERROR: Source account not found"
        sql_rollback(db#)
        sql_finalize(cursor#)
        return 0
    end if
    
    available = sql_getn(cursor#, "balance")
    sql_finalize(cursor#)
    
    if available < amount then
        println "ERROR: Insufficient funds (available: $" + stri$(available, 2) + ")"
        sql_rollback(db#)
        return 0
    end if
    
    ' Debit source account
    params# = json_object#()
    json_setn#(params#, "amount", amount)
    json_setn#(params#, "id", fromId)
    
    if sql_exec(db#, "UPDATE accounts SET balance = balance - :amount WHERE id = :id", params#) = 0 then
        println "ERROR: Debit failed - " + sql_errormsg$()
        sql_rollback(db#)
        return 0
    end if
    
    ' Credit destination account
    json_setn#(params#, "id", toId)
    if sql_exec(db#, "UPDATE accounts SET balance = balance + :amount WHERE id = :id", params#) = 0 then
        println "ERROR: Credit failed - " + sql_errormsg$()
        sql_rollback(db#)
        return 0
    end if
    
    ' Record transaction
    params# = json_object#()
    json_setn#(params#, "from_id", fromId)
    json_setn#(params#, "to_id", toId)
    json_setn#(params#, "amount", amount)
    
    if sql_exec(db#, "INSERT INTO transactions (from_account, to_account, amount) VALUES (:from_id, :to_id, :amount)", params#) = 0 then
        println "ERROR: Could not record transaction"
        sql_rollback(db#)
        return 0
    end if
    
    ' Commit transaction
    if sql_commit(db#) = 1 then
        println "SUCCESS: Transfer completed"
        success = 1
    else
        println "ERROR: Commit failed"
        sql_rollback(db#)
        success = 0
    endif
    
    return success
endfunction

'------------------------------------------------------------------------------
' Main program
'------------------------------------------------------------------------------

ShowBalances(db#)

' Test successful transfer
Transfer(db#, 1, 2, 1000)
ShowBalances(db#)

' Test another transfer
Transfer(db#, 2, 3, 500)
ShowBalances(db#)

' Test failed transfer (insufficient funds)
Transfer(db#, 3, 1, 5000)
ShowBalances(db#)

' Show transaction history
println ""
println "Transaction History:"
println mulstring$("-", 50)
let cursor# = sql_query#(db#, "SELECT t.*, a1.name as from_name, a2.name as to_name FROM transactions t LEFT JOIN accounts a1 ON t.from_account = a1.id LEFT JOIN accounts a2 ON t.to_account = a2.id ORDER BY t.timestamp")

while sql_step(cursor#) = 1
    let row# = sql_row#(cursor#)
    let fromName$ = json_gets$(row#, "from_name")
    let toName$ = json_gets$(row#, "to_name")
    let amt = json_getn(row#, "amount")
    let ts$ = json_gets$(row#, "timestamp")
    println ts$ + ": $" + stri$(amt, 2) + " from " + fromName$ + " to " + toName$
end while
sql_finalize(cursor#)

' Backup the database
println ""
println "Creating backup..."
if sql_backup(db#, docsdir$() + "banking_backup.db") = 1 then
    println "Backup created: " + docsdir$() + "banking_backup.db"
else
    println "Backup failed: " + sql_errormsg$()
endif

' Clean up
sql_close(db#)
println ""
println "Database closed."
