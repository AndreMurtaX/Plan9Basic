'==============================================================================
' SqliteLib Example 4: Address Book Application
' Demonstrates: Complete CRUD application with search and export
'==============================================================================

println "=== Address Book Application ==="
println ""

' Global database handle
let gDB# = Pointer#(0)

'------------------------------------------------------------------------------
' Initialize database
'------------------------------------------------------------------------------
function InitDatabase() local sql$
    gDB# = sql_open#(documentspath$() + "addressbook.db")
    if PntToNum(gDB#) = 0 then
        println "ERROR: Failed to open database"
        return 0
    end if

    ' Create contacts table
    let sql$ = "CREATE TABLE IF NOT EXISTS contacts ("
    sql$ = sql$ + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
    sql$ = sql$ + "first_name TEXT NOT NULL, "
    sql$ = sql$ + "last_name TEXT NOT NULL, "
    sql$ = sql$ + "email TEXT, "
    sql$ = sql$ + "phone TEXT, "
    sql$ = sql$ + "address TEXT, "
    sql$ = sql$ + "city TEXT, "
    sql$ = sql$ + "notes TEXT, "
    sql$ = sql$ + "created_at TEXT DEFAULT CURRENT_TIMESTAMP, "
    sql$ = sql$ + "updated_at TEXT DEFAULT CURRENT_TIMESTAMP)"

    if sql_exec(gDB#, sql$) = 0 then
        println "ERROR creating table: " + sql_errormsg$()
        return 0
    end if

    ' Create index for faster searching
    sql_exec(gDB#, "CREATE INDEX IF NOT EXISTS idx_contacts_name ON contacts(last_name, first_name)")
    sql_exec(gDB#, "CREATE INDEX IF NOT EXISTS idx_contacts_email ON contacts(email)")
    
    return 1
end function

'------------------------------------------------------------------------------
' Add a new contact
'------------------------------------------------------------------------------
function AddContact(firstName$, lastName$, email$, phone$, address$, city$, notes$) local contact#
    let contact# = json_object#()
    json_sets#(contact#, "first_name", firstName$)
    json_sets#(contact#, "last_name", lastName$)
    json_sets#(contact#, "email", email$)
    json_sets#(contact#, "phone", phone$)
    json_sets#(contact#, "address", address$)
    json_sets#(contact#, "city", city$)
    json_sets#(contact#, "notes", notes$)
    
    if sql_insertjson(gDB#, "contacts", contact#) = 1 then
        return sql_lastid(gDB#)
    else
        println "ERROR adding contact: " + sql_errormsg$()
        return 0
    end if
end function

'------------------------------------------------------------------------------
' Update a contact
'------------------------------------------------------------------------------
function UpdateContact(id, firstName$, lastName$, email$, phone$, address$, city$, notes$) local contact#
    let contact# = json_object#()
    json_sets#(contact#, "first_name", firstName$)
    json_sets#(contact#, "last_name", lastName$)
    json_sets#(contact#, "email", email$)
    json_sets#(contact#, "phone", phone$)
    json_sets#(contact#, "address", address$)
    json_sets#(contact#, "city", city$)
    json_sets#(contact#, "notes", notes$)
    ' Use formatdatetime$ to set actual timestamp
    json_sets#(contact#, "updated_at", formatdatetime$("yyyy-mm-dd hh:nn:ss", now()))
    
    if sql_updatejson(gDB#, "contacts", contact#, "id = " + str$(id)) = 1 then
        return sql_changes(gDB#)
    else
        println "ERROR updating contact: " + sql_errormsg$()
        return 0
    end if
end function

'------------------------------------------------------------------------------
' Delete a contact
'------------------------------------------------------------------------------
function DeleteContact(id) local params#
    let params# = json_object#()
    json_setn#(params#, "id", id)
    
    if sql_exec(gDB#, "DELETE FROM contacts WHERE id = :id", params#) = 1 then
        return sql_changes(gDB#)
    else
        println "ERROR deleting contact: " + sql_errormsg$()
        return 0
    end if
end function

'------------------------------------------------------------------------------
' Get a contact by ID (returns JSON object)
'------------------------------------------------------------------------------
function GetContact#(id) local params#, cursor#, result#
    let params# = json_object#()
    json_setn#(params#, "id", id)
    
    let cursor# = sql_query#(gDB#, "SELECT * FROM contacts WHERE id = :id", params#)
    let result# = sql_fetchone#(cursor#)
    sql_finalize(cursor#)
    
    return result#
end function

'------------------------------------------------------------------------------
' Search contacts
'------------------------------------------------------------------------------
function SearchContacts#(searchTerm$) local params#, sql$, cursor#, results#
    let params# = json_object#()
    json_sets#(params#, "term", "%" + searchTerm$ + "%")

    let sql$ = "SELECT * FROM contacts WHERE "
    sql$ = sql$ + "first_name LIKE :term OR "
    sql$ = sql$ + "last_name LIKE :term OR "
    sql$ = sql$ + "email LIKE :term OR "
    sql$ = sql$ + "phone LIKE :term OR "
    sql$ = sql$ + "city LIKE :term "
    sql$ = sql$ + "ORDER BY last_name, first_name"
    
    let cursor# = sql_query#(gDB#, sql$, params#)
    let results# = sql_fetchall#(cursor#)
    sql_finalize(cursor#)
    
    return results#
endfunction

'------------------------------------------------------------------------------
' List all contacts
'------------------------------------------------------------------------------
function ListAllContacts#() local cursor#, results#
    let cursor# = sql_query#(gDB#, "SELECT * FROM contacts ORDER BY last_name, first_name")
    let results# = sql_fetchall#(cursor#)
    sql_finalize(cursor#)
    return results#
endfunction

'------------------------------------------------------------------------------
' Get contact count
'------------------------------------------------------------------------------
function GetContactCount() local cursor#, count
    let cursor# = sql_query#(gDB#, "SELECT COUNT(*) as cnt FROM contacts")
    sql_step(cursor#)
    let count = sql_getn(cursor#, "cnt")
    sql_finalize(cursor#)
    return count
end function

'------------------------------------------------------------------------------
' Export contacts to JSON file (using IOUtilsLib)
'------------------------------------------------------------------------------
function ExportToJson(filename$) local contacts#, jsonStr$, result
    let contacts# = ListAllContacts#()
    let jsonStr$ = json_pretty$(contacts#)
    
    ' Write to file using file_writealltext from IOUtilsLib
    let result = file_writealltext(filename$, jsonStr$)
    
    if result = 1 then
        println "Exported " + str$(json_len(contacts#)) + " contacts to " + filename$
        return 1
    else
        println "ERROR exporting to file: " + iostrerror$()
        return 0
    end if
end function

'------------------------------------------------------------------------------
' Import contacts from JSON file (using IOUtilsLib)
'------------------------------------------------------------------------------
function ImportFromJson(filename$) local jsonStr$, contacts#, count, i, c#, imported, result
    ' Check if file exists
    if file_exists(filename$) = 0 then
        println "ERROR: File not found: " + filename$
        return 0
    end if
    
    ' Read file content using file_readalltext from IOUtilsLib
    let jsonStr$ = file_readalltext$(filename$)
    
    if ioerror() <> 0 then
        println "ERROR reading file: " + iostrerror$()
        return 0
    end if
    
    ' Parse JSON array
    let contacts# = json_parse#(jsonStr$)
    if PntToNum(contacts#) = 0 then
        println "ERROR: Invalid JSON format"
        return 0
    end if
    
    ' Import each contact
    let count = json_len(contacts#)
    let imported = 0
    
    for i = 0 to count - 1
        let c# = json_item#(contacts#, i)
        let result = AddContact(json_gets$(c#, "first_name"), json_gets$(c#, "last_name"), json_gets$(c#, "email"), json_gets$(c#, "phone"), json_gets$(c#, "address"), json_gets$(c#, "city"), json_gets$(c#, "notes"))
        if result > 0 then
            let imported = imported + 1
        end if
    next
    
    println "Imported " + str$(imported) + " of " + str$(count) + " contacts"
    return imported
end function

'------------------------------------------------------------------------------
' Export contacts to CSV file (using IOUtilsLib)
'------------------------------------------------------------------------------
function ExportToCsv(filename$) local contacts#, csv$, count, i, c#, result
    let contacts# = ListAllContacts#()
    let count = json_len(contacts#)
    
    ' CSV header
    let csv$ = "ID,First Name,Last Name,Email,Phone,Address,City,Notes" + chr$(13) + chr$(10)
    
    ' Add each contact as a CSV row
    for i = 0 to count - 1
        let c# = json_item#(contacts#, i)
        csv$ = csv$ + json_gets$(c#, "id") + ","
        csv$ = csv$ + "\"" + json_gets$(c#, "first_name") + "\","
        csv$ = csv$ + "\"" + json_gets$(c#, "last_name") + "\","
        csv$ = csv$ + "\"" + json_gets$(c#, "email") + "\","
        csv$ = csv$ + "\"" + json_gets$(c#, "phone") + "\","
        csv$ = csv$ + "\"" + json_gets$(c#, "address") + "\","
        csv$ = csv$ + "\"" + json_gets$(c#, "city") + "\","
        csv$ = csv$ + "\"" + json_gets$(c#, "notes") + "\""
        csv$ = csv$ + chr$(13) + chr$(10)
    next
    
    ' Write to file using file_writealltext from IOUtilsLib
    let result = file_writealltext(filename$, csv$)
    
    if result = 1 then
        println "Exported " + str$(count) + " contacts to " + filename$
        return 1
    else
        println "ERROR exporting to CSV: " + iostrerror$()
        return 0
    end if
end function

'------------------------------------------------------------------------------
' Print a single contact
'------------------------------------------------------------------------------
function PrintContact(contact#) local email$, phone$, addr$, city$, notes$
    if PntToNum(contact#) = 0 then
        println "  (not found)"
        return 0
    end if
    
    println "  ID: " + json_gets$(contact#, "id")
    println "  Name: " + json_gets$(contact#, "first_name") + " " + json_gets$(contact#, "last_name")
    
    let email$ = json_gets$(contact#, "email")
    if email$ <> "" then
        println "  Email: " + email$
    endif
    
    let phone$ = json_gets$(contact#, "phone")
    if phone$ <> "" then
        println "  Phone: " + phone$
    end if
    
    let addr$ = json_gets$(contact#, "address")
    let city$ = json_gets$(contact#, "city")
    if addr$ <> "" or city$ <> "" then
        println "  Address: " + addr$ + ", " + city$
    end if
    
    let notes$ = json_gets$(contact#, "notes")
    if notes$ <> "" then
        println "  Notes: " + notes$
    end if
    
    return 1
end function

'------------------------------------------------------------------------------
' Print contact list
'------------------------------------------------------------------------------
function PrintContactList(contacts#) local count, i, c#, id$, name$, email$, phone$
    let count = json_len(contacts#)
    if count = 0 then
        println "  No contacts found."
        return 0
    end if
    
    for i = 0 to count - 1
        let c# = json_item#(contacts#, i)
        let id$ = json_gets$(c#, "id")
        let name$ = json_gets$(c#, "last_name") + ", " + json_gets$(c#, "first_name")
        let email$ = json_gets$(c#, "email")
        let phone$ = json_gets$(c#, "phone")
        
        println id$ + ". " + name$
        if email$ <> "" then
            println "     " + email$
        end if
        if phone$ <> "" then
            println "     " + phone$
        end if
    next
    
    return count
end function

'==============================================================================
' MAIN PROGRAM
'==============================================================================

' Initialize
if InitDatabase() = 0 then
    end
end if

println "Database initialized."
println ""

' Add sample contacts if database is empty
if GetContactCount() = 0 then
    println "Adding sample contacts..."
    
    AddContact("John", "Doe", "john.doe@email.com", "555-0100", "123 Main St", "New York", "Met at conference")
    AddContact("Jane", "Smith", "jane.smith@email.com", "555-0101", "456 Oak Ave", "Los Angeles", "College friend")
    AddContact("Bob", "Johnson", "bob.j@work.com", "555-0102", "789 Pine Rd", "Chicago", "Work colleague")
    AddContact("Alice", "Williams", "alice.w@email.com", "555-0103", "321 Elm St", "Houston", "")
    AddContact("Charlie", "Brown", "charlie@email.com", "555-0104", "654 Maple Dr", "Phoenix", "Neighbor")
    AddContact("Diana", "Miller", "diana.m@email.com", "555-0105", "987 Cedar Ln", "New York", "Gym buddy")
    
    println "Added " + str$(GetContactCount()) + " sample contacts"
    println ""
end if

' Display all contacts
println "=== All Contacts ==="
let all# = ListAllContacts#()
PrintContactList(all#)

' Search example
println ""
println "=== Search: 'New York' ==="
let results# = SearchContacts#("New York")
PrintContactList(results#)

' Get specific contact
println ""
println "=== Contact Details (ID 1) ==="
let contact# = GetContact#(1)
PrintContact(contact#)

' Update a contact
println ""
println "=== Updating Contact ID 1 ==="
UpdateContact(1, "John", "Doe", "john.doe@newemail.com", "555-9999", "123 Main St", "New York", "Updated phone and email")
println "Updated successfully"

contact# = GetContact#(1)
PrintContact(contact#)

' Statistics
println ""
println "=== Statistics ==="
println "Total contacts: " + str$(GetContactCount())

let cursor# = sql_query#(gDB#, "SELECT city, COUNT(*) as cnt FROM contacts GROUP BY city ORDER BY cnt DESC")
println "Contacts by city:"
while sql_step(cursor#) = 1
    println "  " + sql_gets$(cursor#, "city") + ": " + str$(sql_getn(cursor#, "cnt"))
end while
sql_finalize(cursor#)

' Export to JSON file
println ""
println "=== Exporting to JSON File ==="
ExportToJson(documentspath$() + "contacts_export.json")

' Export to CSV file
println ""
println "=== Exporting to CSV File ==="
ExportToCsv(documentspath$() + "contacts_export.csv")

' Show exported JSON content (preview)
println ""
println "=== JSON Export Preview ==="
let allJson# = ListAllContacts#()
println json_pretty$(allJson#)

' Cleanup
sql_close(gDB#)
println ""
println "Address Book closed."
