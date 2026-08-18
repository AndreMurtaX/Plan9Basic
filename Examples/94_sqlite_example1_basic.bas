'==============================================================================
' SqliteLib Example 1: Basic Database Operations
' Demonstrates: Creating database, tables, CRUD operations
'==============================================================================

println "=== SQLite Basic Example ==="
println ""

' Create or open a database
let db# = sql_open#(documentspath$() + "example.db")
if PntToNum(db#) = 0 then
    println "ERROR: Failed to open database: " + sql_errormsg$()
    end
end if

println "Database opened: " + sql_path$(db#)

' Create a table
let createSQL$ = "CREATE TABLE IF NOT EXISTS notes ("
createSQL$ = createSQL$ + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
createSQL$ = createSQL$ + "title TEXT NOT NULL, "
createSQL$ = createSQL$ + "content TEXT, "
createSQL$ = createSQL$ + "created_at TEXT DEFAULT CURRENT_TIMESTAMP)"

if sql_exec(db#, createSQL$) = 1 then
    println "Table 'notes' ready"
else
    println "ERROR creating table: " + sql_errormsg$()
end if

' Insert some records
println ""
println "Inserting records..."

let stmt# = sql_prepare#(db#, "INSERT INTO notes (title, content) VALUES (:title, :content)")

let note1# = json_object#()
json_sets#(note1#, "title", "Shopping List")
json_sets#(note1#, "content", "Milk, Bread, Eggs, Cheese")
sql_bindjson#(stmt#, note1#)
sql_step(stmt#)
println "Inserted note 1, ID: " + str$(sql_lastid(db#))

sql_reset#(stmt#)

let note2# = json_object#()
json_sets#(note2#, "title", "Meeting Notes")
json_sets#(note2#, "content", "Discuss Q4 budget and hiring plans")
sql_bindjson#(stmt#, note2#)
sql_step(stmt#)
println "Inserted note 2, ID: " + str$(sql_lastid(db#))

sql_reset#(stmt#)

let note3# = json_object#()
json_sets#(note3#, "title", "Ideas")
json_sets#(note3#, "content", "Learn Plan9Basic, Build cool applets")
sql_bindjson#(stmt#, note3#)
sql_step(stmt#)
println "Inserted note 3, ID: " + str$(sql_lastid(db#))

sql_finalize(stmt#)

' Query all records
println ""
println "All Notes:"
println "=========="

let cursor# = sql_query#(db#, "SELECT * FROM notes ORDER BY id")
while sql_step(cursor#) = 1
    println "[" + str$(sql_getn(cursor#, "id")) + "] " + sql_gets$(cursor#, "title")
    println "    " + sql_gets$(cursor#, "content")
    println "    Created: " + sql_gets$(cursor#, "created_at")
    println ""
end while
sql_finalize(cursor#)

' Update a record
println "Updating note 1..."
let upd# = json_object#()
json_sets#(upd#, "content", "Milk, Bread, Eggs, Cheese, Butter, Coffee")
sql_updatejson(db#, "notes", upd#, "id = 1")
println "Updated " + str$(sql_changes(db#)) + " row(s)"

' Delete a record
println ""
println "Deleting note 3..."
sql_exec(db#, "DELETE FROM notes WHERE id = 3")
println "Deleted " + str$(sql_changes(db#)) + " row(s)"

' Final query
println ""
println "Final Notes List:"
println "================="
cursor# = sql_query#(db#, "SELECT id, title FROM notes ORDER BY id")
while sql_step(cursor#) = 1
    println str$(sql_getn(cursor#, "id")) + ": " + sql_gets$(cursor#, "title")
end while
sql_finalize(cursor#)

' Clean up
sql_close(db#)
println ""
println "Database closed."
