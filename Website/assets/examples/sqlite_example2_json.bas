'==============================================================================
' SqliteLib Example 2: JSON Integration
' Demonstrates: Reading/writing records as JSON, bulk operations
'==============================================================================

println "=== SQLite JSON Integration Example ==="
println ""

' Open in-memory database for this example
let db# = sql_open#()
if PntToNum(db#) = 0 then
    println "ERROR: Failed to create database"
    end
endif
println "In-memory database created"

' Create products table
let sql$ = "CREATE TABLE products ("
sql$ = sql$ + "id INTEGER PRIMARY KEY AUTOINCREMENT, "
sql$ = sql$ + "name TEXT NOT NULL, "
sql$ = sql$ + "category TEXT, "
sql$ = sql$ + "price REAL, "
sql$ = sql$ + "stock INTEGER DEFAULT 0)"
sql_exec(db#, sql$)

' Insert products using JSON objects
println ""
println "Adding products using JSON..."

' Product 1
let p1# = json_object#()
json_sets#(p1#, "name", "Wireless Mouse")
json_sets#(p1#, "category", "Electronics")
json_setn#(p1#, "price", 29.99)
json_setn#(p1#, "stock", 150)
sql_insertjson(db#, "products", p1#)

' Product 2
let p2# = json_object#()
json_sets#(p2#, "name", "USB Keyboard")
json_sets#(p2#, "category", "Electronics")
json_setn#(p2#, "price", 49.99)
json_setn#(p2#, "stock", 75)
sql_insertjson(db#, "products", p2#)

' Product 3
let p3# = json_object#()
json_sets#(p3#, "name", "Coffee Mug")
json_sets#(p3#, "category", "Kitchen")
json_setn#(p3#, "price", 12.50)
json_setn#(p3#, "stock", 200)
sql_insertjson(db#, "products", p3#)

' Product 4
let p4# = json_object#()
json_sets#(p4#, "name", "Desk Lamp")
json_sets#(p4#, "category", "Office")
json_setn#(p4#, "price", 34.99)
json_setn#(p4#, "stock", 50)
sql_insertjson(db#, "products", p4#)

' Product 5
let p5# = json_object#()
json_sets#(p5#, "name", "Notebook")
json_sets#(p5#, "category", "Office")
json_setn#(p5#, "price", 4.99)
json_setn#(p5#, "stock", 500)
sql_insertjson(db#, "products", p5#)

println "Inserted " + str$(sql_totalchanges(db#)) + " products"

' Fetch all products as JSON array
println ""
println "All Products (as JSON):"
println "======================="
let cursor# = sql_query#(db#, "SELECT * FROM products ORDER BY category, name")
let allProducts# = sql_fetchall#(cursor#)
sql_finalize(cursor#)

println json_pretty$(allProducts#)

' Query specific category using JSON parameters
println ""
println "Electronics Category:"
println "===================="
let params# = json_object#()
json_sets#(params#, "cat", "Electronics")
cursor# = sql_query#(db#, "SELECT name, price FROM products WHERE category = :cat", params#)

let row# = Pointer#(0)
row# = sql_fetchone#(cursor#)
while PntToNum(row#) <> 0
    let name$ = json_gets$(row#, "name")
    let price = json_getn(row#, "price")
    println "  " + name$ + " - $" + stri$(price, 2)
    row# = sql_fetchone#(cursor#)
end while
sql_finalize(cursor#)

' Calculate totals using SQL and get result as JSON
println ""
println "Category Summary:"
println "================="
cursor# = sql_query#(db#, "SELECT category, COUNT(*) as count, SUM(stock) as total_stock, AVG(price) as avg_price FROM products GROUP BY category")
while sql_step(cursor#) = 1
    let row# = sql_row#(cursor#)
    let cat$ = json_gets$(row#, "category")
    let cnt = json_getn(row#, "count")
    let totalStock = json_getn(row#, "total_stock")
    let avgPrice = json_getn(row#, "avg_price")
    println cat$ + ": " + str$(cnt) + " products, " + str$(totalStock) + " in stock, avg $" + stri$(avgPrice, 2)
end while
sql_finalize(cursor#)

' Update using JSON
println ""
println "Applying 10% price increase to Electronics..."
cursor# = sql_query#(db#, "SELECT id, price FROM products WHERE category = 'Electronics'")
while sql_step(cursor#) = 1
    let id = sql_getn(cursor#, "id")
    let oldPrice = sql_getn(cursor#, "price")
    let newPrice = oldPrice * 1.1
    
    let upd# = json_object#()
    json_setn#(upd#, "price", newPrice)
    sql_updatejson(db#, "products", upd#, "id = " + str$(id))
end while
sql_finalize(cursor#)

' Show updated prices
println ""
println "Updated Electronics Prices:"
cursor# = sql_query#(db#, "SELECT name, price FROM products WHERE category = 'Electronics'")
while sql_step(cursor#) = 1
    println "  " + sql_gets$(cursor#, "name") + " - $" + stri$(sql_getn(cursor#, "price"), 2)
end while
sql_finalize(cursor#)

sql_close(db#)
println ""
println "Done!"
