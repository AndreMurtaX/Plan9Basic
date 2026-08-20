rem ---------------------------------------------------------------
rem ListBoxLib, ComboBoxLib, MemoLib and ImageLib -- the four that had
rem their properties covered by the generated suite and their actual
rem work covered by nothing: the items, the selection, the text
rem editing and the bitmap.
rem
rem The map came from Examples/46_test_combobox_listbox.bas and
rem 59_ImageLib_Tests.bas.
rem
rem Two things are deliberately not asserted. The clipboard verbs reach
rem the system clipboard, so what comes back belongs to the machine.
rem And no picture is ever fetched: image_load takes a URL as readily
rem as a path, but a suite that downloads one is a suite that fails
rem when somebody else's server is down. What is asserted instead is
rem that the two are told apart -- see image/urls below.
rem ---------------------------------------------------------------

f# = form#("list host", 500, 400)

test_case("listbox/items")
lb# = listbox#(f#, 10, 10, 200, 150)
assert_true(pnttonum(lb#), "listbox# answers a handle")
assert_eq(pnttonum(listbox_parent#(lb#)), pnttonum(f#), "which knows its form")
assert_eq(listbox_count(lb#), 0, "and starts empty")

listbox_add(lb#, "alpha")
listbox_add(lb#, "beta")
listbox_add(lb#, "gamma")
assert_eq(listbox_count(lb#), 3, "listbox_add appends")
assert_eq(listbox_item$(lb#, 0), "alpha", "listbox_item$ reads by position")
assert_eq(listbox_item$(lb#, 2), "gamma", "at either end")

listbox_insert(lb#, 1, "inserted")
assert_eq(listbox_count(lb#), 4, "listbox_insert makes room")
assert_eq(listbox_item$(lb#, 1), "inserted", "and puts it where it was told")
assert_eq(listbox_item$(lb#, 2), "beta", "pushing the rest down")

listbox_item#(lb#, 1, "rewritten")
assert_eq(listbox_item$(lb#, 1), "rewritten", "listbox_item# rewrites one")

assert_eq(listbox_indexof(lb#, "gamma"), 3, "listbox_indexof finds one")
assert_eq(listbox_indexof(lb#, "absent"), -1, "and answers -1 for one that is not there")

listbox_delete(lb#, 1)
assert_eq(listbox_count(lb#), 3, "listbox_delete removes one")
assert_eq(listbox_item$(lb#, 1), "beta", "and the rest close up")

test_case("listbox/selection")
listbox_itemindex#(lb#, 1)
assert_eq(listbox_itemindex(lb#), 1, "listbox_itemindex# selects by position")
assert_eq(listbox_selected$(lb#), "beta", "and listbox_selected$ answers its text")
assert_true(listbox_isselected(lb#, 1), "listbox_isselected agrees")
assert_false(listbox_isselected(lb#, 0), "about the one that is not")

listbox_selectitem#(lb#, 0, 1)
assert_true(listbox_isselected(lb#, 0), "listbox_selectitem# selects one directly")

rem selectall can only reach one row while the box is single-select,
rem which is what it is by default -- so the multiselect flag has to go
rem on first, and that is the whole difference between the two modes.
assert_false(listbox_multiselect(lb#), "a listbox is single-select to begin with")
listbox_selectall(lb#)
assert_eq(listbox_selcount(lb#), 1, "so selectall reaches exactly one row")

listbox_multiselect#(lb#, 1)
assert_true(listbox_multiselect(lb#), "listbox_multiselect# turns it on")
listbox_selectall(lb#)
assert_eq(listbox_selcount(lb#), 3, "and now selectall reaches them all")
listbox_clearselection(lb#)
assert_eq(listbox_selcount(lb#), 0, "listbox_clearselection lets them go")

test_case("listbox/items-as-objects")
rem Each row is an object of its own, which is what lets a program hold
rem on to one rather than to a position that moves.
it# = listbox_itemat#(lb#, 0)
assert_true(pnttonum(it#), "listbox_itemat# answers the item object")
assert_eq(listboxitem_text$(it#), "alpha", "which carries its own text")
assert_eq(listboxitem_index(it#), 0, "and knows where it sits")

listboxitem_text#(it#, "renamed")
assert_eq(listbox_item$(lb#, 0), "renamed", "writing through the object reaches the list")

listboxitem_isselected#(it#, 1)
assert_true(listboxitem_isselected(it#), "and so does selecting through it")
assert_true(listbox_isselected(lb#, 0), "which the list agrees with")

test_case("listbox/focus-and-clearing")
listbox_focus(lb#)
assert_true(listbox_isfocused(lb#), "listbox_focus gives it the focus")

listbox_clearerror()
listbox_clearcallbacks#(lb#)
assert_eq(listbox_error(), 0, "listbox_clearcallbacks# is reachable")

listbox_clear(lb#)
assert_eq(listbox_count(lb#), 0, "listbox_clear empties it")

test_case("combobox/items")
rem The same shape as a listbox, minus the multiple selection: a combo
rem box has one current item and no concept of several.
cb# = combobox#(f#, 220, 10, 200, 30)
assert_eq(pnttonum(combobox_parent#(cb#)), pnttonum(f#), "combobox# knows its form")
assert_eq(combobox_count(cb#), 0, "and starts empty")

combobox_add(cb#, "one")
combobox_add(cb#, "three")
combobox_insert(cb#, 1, "two")
assert_eq(combobox_count(cb#), 3, "combobox_add and combobox_insert fill it")
assert_eq(combobox_item$(cb#, 1), "two", "in the order asked for")

combobox_item#(cb#, 1, "second")
assert_eq(combobox_item$(cb#, 1), "second", "combobox_item# rewrites one")
assert_eq(combobox_indexof(cb#, "three"), 2, "combobox_indexof finds one")
assert_eq(combobox_indexof(cb#, "absent"), -1, "and answers -1 otherwise")

combobox_itemindex#(cb#, 2)
assert_eq(combobox_itemindex(cb#), 2, "combobox_itemindex# selects")
assert_eq(combobox_selected$(cb#), "three", "and combobox_selected$ answers its text")

combobox_delete(cb#, 0)
assert_eq(combobox_count(cb#), 2, "combobox_delete removes one")
assert_false(combobox_isfocused(cb#), "an untouched combo box has no focus")

combobox_clearerror()
combobox_clearcallbacks#(cb#)
assert_eq(combobox_error(), 0, "combobox_clearcallbacks# is reachable")

combobox_clear(cb#)
assert_eq(combobox_count(cb#), 0, "combobox_clear empties it")

test_case("memo/lines")
m# = memo#(f#, 10, 180, 300, 150)
assert_eq(pnttonum(memo_parent#(m#)), pnttonum(f#), "memo# knows its form")

memo_clear#(m#)
assert_eq(memo_linecount(m#), 0, "a cleared memo has no lines")

memo_addline#(m#, "first")
memo_addline#(m#, "third")
memo_insertline#(m#, 1, "second")
assert_eq(memo_linecount(m#), 3, "the three ways of adding agree")
assert_eq(memo_line$(m#, 1), "second", "and the insert landed where it was told")

memo_line#(m#, 1, "rewritten")
assert_eq(memo_line$(m#, 1), "rewritten", "memo_line# rewrites one")

memo_deleteline#(m#, 1)
assert_eq(memo_linecount(m#), 2, "memo_deleteline# removes one")
assert_eq(memo_line$(m#, 1), "third", "and the rest close up")

test_case("memo/text-and-selection")
memo_text#(m#, "hello world")
assert_eq(memo_text$(m#), "hello world", "memo_text# replaces the lot")
assert_eq(memo_textlength(m#), 11, "and memo_textlength counts the characters")

memo_selstart#(m#, 0)
memo_sellength#(m#, 5)
assert_eq(memo_selstart(m#), 0, "memo_selstart# sets where the selection begins")
assert_eq(memo_sellength(m#), 5, "memo_sellength# how far it runs")
assert_eq(memo_seltext$(m#), "hello", "and memo_seltext$ answers what is inside it")

memo_selectall#(m#)
assert_eq(memo_sellength(m#), 11, "memo_selectall# takes the lot")
memo_clearselection#(m#)
assert_eq(memo_sellength(m#), 0, "memo_clearselection# lets it go")

memo_selstart#(m#, 0)
memo_sellength#(m#, 6)
memo_deleteselection#(m#)
assert_eq(memo_text$(m#), "world", "memo_deleteselection# cuts out what was selected")

test_case("memo/line-breaks-are-normalised")
rem Text put into a memo is not the text that comes back out. A bare
rem line feed is stored as a carriage return and a line feed, so seven
rem characters in are eight characters out. A program that writes a
rem memo and compares what it reads against what it wrote will find
rem them different, and this is why.
memo_text#(m#, "one" + chr$(10) + "two")
assert_eq(memo_textlength(m#), 8, "a bare line feed becomes two characters")
assert_eq(instr(memo_text$(m#), chr$(13)), 3, "a carriage return appears")
assert_eq(instr(memo_text$(m#), chr$(10)), 4, "with the line feed after it")
assert_eq(memo_linecount(m#), 2, "and it is still two lines")

rem The caret cannot stand between the two, so asking for the position
rem in the middle of the pair answers the one after it.
memo_selstart#(m#, 3)
assert_eq(memo_selstart(m#), 3, "a position before the break is kept")
memo_selstart#(m#, 4)
assert_eq(memo_selstart(m#), 5, "one inside the break moves past it")
memo_selstart#(m#, 5)
assert_eq(memo_selstart(m#), 5, "and one after it is kept")

test_case("memo/navigation")
rem gotoend and gotobegin move the caret. On a memo that was never
rem shown the caret has nowhere to be -- FMX moves it when the control
rem is realised -- so selstart does not follow, and asserting that it
rem did would be asserting a window that is not there. What is pinned
rem is that both are reachable and leave the text alone.
memo_clearerror()
before = memo_textlength(m#)
memo_gotoend#(m#)
memo_gotobegin#(m#)
assert_eq(memo_error(), 0, "both caret verbs are reachable")
assert_eq(memo_textlength(m#), before, "and neither disturbs the text")

memo_scrolltop#(m#, 0)
assert_eq(memo_scrolltop(m#), 0, "memo_scrolltop# holds a scroll position")
memo_scrolltoend#(m#)
assert_eq(memo_error(), 0, "memo_scrolltoend# is reachable")

test_case("memo/focus-and-clipboard")
memo_setfocus#(m#)
assert_true(memo_isfocused(m#), "memo_setfocus# gives it the focus")
memo_resetfocus#(m#)

rem The clipboard reaches the desktop, so these are exercised for
rem reachability. Asserting a paste would be asserting the machine.
memo_clearerror()
memo_selectall#(m#)
memo_copy#(m#)
memo_cut#(m#)
memo_paste#(m#)
assert_eq(memo_error(), 0, "the clipboard verbs are reachable")

memo_clearcallbacks#(m#)
assert_eq(memo_error(), 0, "memo_clearcallbacks# too")

test_case("image/bitmap")
rem An image with nothing loaded is empty and measures zero. That is
rem the state every image starts in and the one a program has to be
rem able to ask about before it draws.
i# = image#(f#, 320, 180, 100, 100)
assert_eq(pnttonum(image_parent#(i#)), pnttonum(f#), "image# knows its form")
assert_true(image_isempty(i#), "a new image holds no bitmap")
assert_eq(image_bitmapwidth(i#), 0, "so its width is zero")
assert_eq(image_bitmapheight(i#), 0, "and its height")

test_case("image/loading-a-file")
rem This repository ships no picture, so what is asserted is the
rem refusal: a file that is not there must answer failure rather than
rem leaving the image in a half state.
image_clearerror()
assert_false(image_load(i#, "bin/p9b_no_such_picture.png"), "loading a file that is not there fails")
assert_eq(image_error(), 6, "with the file-not-found code")
assert_true(image_isempty(i#), "and the image is still empty afterwards")

image_clearerror()
image_load#(i#, "bin/p9b_no_such_picture.png")
assert_true(image_isempty(i#), "the chaining form leaves it empty too")

test_case("image/urls")
rem An argument beginning http:// or https:// is fetched rather than
rem opened. That is the whole of the rule -- there is no separate
rem function and no flag -- and Examples/60_ImageLib_WebGallery_Demo.bas
rem has been loading pictures that way since it was written.
rem
rem What is proved here is that the two paths are told APART, without
rem fetching anything. The host below ends in .invalid, which RFC 2606
rem reserves so that it can never resolve, so no request leaves this
rem machine and the answer is immediate. A missing FILE answers code 6,
rem file-not-found; a URL that cannot be reached answers code 7, load
rem failed. Different codes mean the URL went down the other branch.
image_clearerror()
assert_false(image_load(i#, "https://plan9basic.invalid/assets/image1.png"), "an unreachable url fails")
assert_eq(image_error(), 7, "with the load-failed code, not file-not-found")
assert_true(image_isempty(i#), "and the image is left empty rather than half-loaded")

image_clearerror()
image_load(i#, "http://plan9basic.invalid/assets/image1.png")
assert_eq(image_error(), 7, "http is recognised as well as https")

rem The prefix is matched without regard to case, and after trimming.
image_clearerror()
image_load(i#, "HTTPS://plan9basic.invalid/assets/image1.png")
assert_eq(image_error(), 7, "and the prefix is recognised whatever its case")

rem Anything that is not one of the two prefixes is a path, however
rem much it looks like an address.
image_clearerror()
image_load(i#, "ftp://plan9basic.invalid/assets/image1.png")
assert_eq(image_error(), 6, "another scheme is treated as a file name")

image_clearerror()
image_clear#(i#)
assert_true(image_isempty(i#), "image_clear# empties one that already was")
image_invalidate#(i#)
image_clearcallbacks#(i#)
assert_eq(image_error(), 0, "invalidate and clearcallbacks are reachable")

form_free(f#)
