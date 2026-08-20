rem ---------------------------------------------------------------
rem StringGridLib. check-coverage.py reported 60/110: the columns, the
rem typed cells, the row operations, the sorting, the clipboard and
rem the CSV round trip had never been run.
rem
rem A grid needs a parent, so a form is made and never shown -- the
rem control exists whether or not a window does.
rem
rem Three conventions. Rows and columns are 0-BASED. Every cell
rem accessor takes the COLUMN FIRST and the row second -- (grid, col,
rem row) -- which is the opposite of how a grid is usually spoken about
rem and is the mistake this file made on its first run. And a column
rem has a TYPE chosen when it is added. 0 is text, 1 a checkbox, 7 a
rem progress bar, and each type has its own cell accessor: writing a
rem number into a text column with stringgrid_cellnum# reaches a
rem column that cannot hold one.
rem ---------------------------------------------------------------

f# = form#("grid host", 600, 400)
g# = stringgrid#(f#, 10, 10, 500, 300)

test_case("grid/construction")
assert_true(pnttonum(g#), "stringgrid# answers a handle")
assert_eq(pnttonum(stringgrid_parent#(g#)), pnttonum(f#), "which knows the form it was put on")
stringgrid_clearerror()
assert_eq(stringgrid_error(), 0, "with nothing to report")

test_case("grid/columns")
assert_eq(stringgrid_colcount(g#), 0, "a new grid has no columns")

stringgrid_addcolumn#(g#, "Name", 0, 150)
stringgrid_addcolumn#(g#, "Done", 1, 60)
stringgrid_addcolumn#(g#, "Progress", 7, 100)
assert_eq(stringgrid_colcount(g#), 3, "stringgrid_addcolumn# adds them")

assert_eq(stringgrid_columnheader$(g#, 0), "Name", "the header is what it was given")
stringgrid_columnheader#(g#, 0, "Renamed")
assert_eq(stringgrid_columnheader$(g#, 0), "Renamed", "and can be changed")

assert_eq(stringgrid_columnwidth(g#, 0), 150, "the width too")
stringgrid_columnwidth#(g#, 0, 200)
assert_eq(stringgrid_columnwidth(g#, 0), 200, "and changes")

assert_eq(stringgrid_columntype(g#, 0), 0, "column zero is text")
assert_eq(stringgrid_columntype(g#, 1), 1, "column one is a checkbox")
assert_eq(stringgrid_columntype(g#, 2), 7, "and column two a progress bar")

assert_true(pnttonum(stringgrid_column#(g#, 0)), "stringgrid_column# answers the column object")

test_case("grid/column-flags")
stringgrid_columnvisible#(g#, 1, 0)
assert_false(stringgrid_columnvisible(g#, 1), "a column can be hidden")
stringgrid_columnvisible#(g#, 1, 1)
assert_true(stringgrid_columnvisible(g#, 1), "and shown again")

stringgrid_columnreadonly#(g#, 0, 1)
assert_true(stringgrid_columnreadonly(g#, 0), "and made read-only")
stringgrid_columnreadonly#(g#, 0, 0)
assert_false(stringgrid_columnreadonly(g#, 0), "and writable again")

stringgrid_columnalign#(g#, 0, 1)
assert_eq(stringgrid_columnalign(g#, 0), 1, "stringgrid_columnalign# holds an alignment")

test_case("grid/rows-and-text-cells")
stringgrid_rowcount#(g#, 3)
assert_eq(stringgrid_rowcount(g#), 3, "stringgrid_rowcount# sets the row count")

stringgrid_cell#(g#, 0, 0, "first")
stringgrid_cell#(g#, 0, 1, "second")
stringgrid_cell#(g#, 0, 2, "third")
assert_eq(stringgrid_cell$(g#, 0, 0), "first", "stringgrid_cell# writes a text cell")
assert_eq(stringgrid_cell$(g#, 0, 2), "third", "at any row")

stringgrid_rowheight#(g#, 28)
assert_eq(stringgrid_rowheight(g#), 28, "stringgrid_rowheight# sets the height")

test_case("grid/typed-cells")
rem Each accessor belongs to its column's type. A checkbox column holds
rem a flag and a progress column a number, and neither is reachable
rem through the text accessor.
stringgrid_cellcheck#(g#, 1, 0, 1)
assert_true(stringgrid_cellcheck(g#, 1, 0), "stringgrid_cellcheck# ticks a checkbox cell")
stringgrid_cellcheck#(g#, 1, 0, 0)
assert_false(stringgrid_cellcheck(g#, 1, 0), "and unticks it")

stringgrid_cellprogress#(g#, 2, 0, 42)
assert_eq(stringgrid_cellprogress(g#, 2, 0), 42, "stringgrid_cellprogress# sets a progress cell")

rem cellnum reads and writes a number through whichever column it is
rem pointed at, which for a text column means the text of a number.
stringgrid_cellnum#(g#, 0, 1, 99)
assert_eq(stringgrid_cellnum(g#, 0, 1), 99, "stringgrid_cellnum# round-trips a number")

test_case("grid/row-operations")
stringgrid_rowcount#(g#, 3)
stringgrid_cell#(g#, 0, 0, "a")
stringgrid_cell#(g#, 0, 1, "b")
stringgrid_cell#(g#, 0, 2, "c")

stringgrid_swaprows(g#, 0, 2)
assert_eq(stringgrid_cell$(g#, 0, 0), "c", "stringgrid_swaprows exchanges two")
assert_eq(stringgrid_cell$(g#, 0, 2), "a", "both ways")

stringgrid_moverow(g#, 0, 2)
assert_eq(stringgrid_cell$(g#, 0, 2), "c", "stringgrid_moverow takes one to a new place")

stringgrid_copyrow(g#, 0, 1)
assert_eq(stringgrid_cell$(g#, 0, 1), stringgrid_cell$(g#, 0, 0), "stringgrid_copyrow duplicates one onto another")

stringgrid_clearrow(g#, 1)
assert_eq(stringgrid_cell$(g#, 0, 1), "", "stringgrid_clearrow empties one")

stringgrid_insertrow(g#, 0)
assert_eq(stringgrid_rowcount(g#), 4, "stringgrid_insertrow makes room")
stringgrid_deleterow(g#, 0)
assert_eq(stringgrid_rowcount(g#), 3, "and stringgrid_deleterow takes it away")

test_case("grid/sorting")
stringgrid_rowcount#(g#, 3)
stringgrid_cell#(g#, 0, 0, "banana")
stringgrid_cell#(g#, 0, 1, "apple")
stringgrid_cell#(g#, 0, 2, "cherry")
rem The third argument is the flag that REVERSES the sort: zero gives
rem A to Z and non-zero gives Z to A. The reference called it
rem "ascending", which reads as the opposite of what it does --
rem Examples/66_StringGrid_NewFeatures_Demo.bas has passed 0 for
rem ascending since it was written, so the code and the author agreed
rem and only the page was wrong. It says "descending" now.
stringgrid_sort(g#, 0, 0)
assert_eq(stringgrid_cell$(g#, 0, 0), "apple", "zero sorts a text column A to Z")
stringgrid_sort(g#, 0, 1)
assert_eq(stringgrid_cell$(g#, 0, 0), "cherry", "and non-zero reverses it")

rem Sorting text and sorting numbers are different: "10" sorts before
rem "9" as text and after it as a number.
stringgrid_cell#(g#, 0, 0, "10")
stringgrid_cell#(g#, 0, 1, "9")
stringgrid_cell#(g#, 0, 2, "100")
stringgrid_sortnum(g#, 0, 0)
assert_eq(stringgrid_cell$(g#, 0, 0), "9", "stringgrid_sortnum orders by value and not by spelling")
assert_eq(stringgrid_cell$(g#, 0, 2), "100", "all the way up")
stringgrid_sortnum(g#, 0, 1)
assert_eq(stringgrid_cell$(g#, 0, 0), "100", "and its flag reverses the same way")

test_case("grid/selection")
stringgrid_selectcell#(g#, 0, 1)
assert_eq(stringgrid_row(g#), 1, "stringgrid_selectcell# moves the current row")
stringgrid_row#(g#, 2)
assert_eq(stringgrid_row(g#), 2, "stringgrid_row# moves it directly")

stringgrid_rowselect#(g#, 1)
assert_true(stringgrid_rowselect(g#), "stringgrid_rowselect# turns whole-row selection on")
stringgrid_rowselect#(g#, 0)
assert_false(stringgrid_rowselect(g#), "and off")

stringgrid_scrolltorow(g#, 0)
assert_eq(stringgrid_error(), 0, "stringgrid_scrolltorow is reachable")

test_case("grid/focus")
rem A control can hold the focus without a window being on screen --
rem focus is the form's business and not the desktop's -- so asking for
rem it works even here.
stringgrid_focus(g#)
assert_true(stringgrid_isfocused(g#), "stringgrid_focus gives it the focus")

test_case("grid/csv")
rem The CSV pair is the only way to get a whole grid in or out in one
rem call, and it is the one place a defect would lose somebody's data.
p$ = "bin/p9b_grid.csv"
file_delete(p$)

stringgrid_rowcount#(g#, 2)
stringgrid_cell#(g#, 0, 0, "alpha")
stringgrid_cell#(g#, 0, 1, "beta")

csv$ = stringgrid_tocsv$(g#, ",", 1)
assert_true(instr(csv$, "alpha") + 1, "stringgrid_tocsv$ renders the cells")

assert_true(stringgrid_exportcsv(g#, p$, ",", 1), "stringgrid_exportcsv writes a file")
assert_true(file_exists(p$), "and the file is there")

g2# = stringgrid#(f#, 10, 10, 500, 300)
stringgrid_addcolumn#(g2#, "Name", 0, 150)
assert_true(stringgrid_importcsv(g2#, p$, ",", 1), "stringgrid_importcsv reads it back")
assert_eq(stringgrid_cell$(g2#, 0, 0), "alpha", "with the cells intact")

g3# = stringgrid#(f#, 10, 10, 500, 300)
stringgrid_addcolumn#(g3#, "Name", 0, 150)
assert_true(stringgrid_fromcsv(g3#, csv$, ",", 1), "stringgrid_fromcsv reads a string rather than a file")
assert_eq(stringgrid_cell$(g3#, 0, 0), "alpha", "with the same result")

file_delete(p$)

test_case("grid/clipboard")
rem These reach the system clipboard, so what comes back depends on the
rem machine. What is asserted is that each is reachable and leaves no
rem error -- asserting a paste would be asserting the desktop.
stringgrid_clearerror()
stringgrid_copycell(g#, 0, 0)
stringgrid_pastecell(g#, 0, 1)
stringgrid_copyrow(g#, 0, 1)
stringgrid_copy(g#)
stringgrid_copysel(g#)
stringgrid_paste(g#)
assert_eq(stringgrid_error(), 0, "the clipboard verbs are reachable")

test_case("grid/popup-columns")
rem A popup column carries its own list of choices.
stringgrid_addcolumn#(g#, "Choice", 6, 80)
last = stringgrid_colcount(g#) - 1
assert_eq(stringgrid_popupcount(g#, last), 0, "a new popup column has no items")
stringgrid_popupadd(g#, last, "one")
stringgrid_popupadd(g#, last, "two")
assert_eq(stringgrid_popupcount(g#, last), 2, "stringgrid_popupadd adds them")
stringgrid_popupclear(g#, last)
assert_eq(stringgrid_popupcount(g#, last), 0, "and stringgrid_popupclear empties them")

test_case("grid/event-names")
stringgrid_oncellclick#(g#, "h_cellclick")
assert_eq(stringgrid_oncellclick$(g#), "h_cellclick", "oncellclick stores a name")
stringgrid_oncelldblclick#(g#, "h_dblclick")
assert_eq(stringgrid_oncelldblclick$(g#), "h_dblclick", "oncelldblclick too")
stringgrid_onselectcell#(g#, "h_select")
assert_eq(stringgrid_onselectcell$(g#), "h_select", "and onselectcell")

stringgrid_clearcallbacks#(g#)
assert_eq(stringgrid_oncellclick$(g#), "", "stringgrid_clearcallbacks# unwires them all at once")

test_case("grid/clearing")
stringgrid_clearrows(g#)
assert_eq(stringgrid_rowcount(g#), 0, "stringgrid_clearrows empties the rows")
stringgrid_deletecolumn(g#, 0)
assert_true(stringgrid_colcount(g#), "stringgrid_deletecolumn removes one")
stringgrid_clearcolumns(g#)
assert_eq(stringgrid_colcount(g#), 0, "and stringgrid_clearcolumns removes the rest")

form_free(f#)
