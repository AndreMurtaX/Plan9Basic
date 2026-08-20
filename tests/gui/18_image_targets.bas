rem ---------------------------------------------------------------
rem Every place in this engine that takes a picture takes a URL as
rem readily as a path: an argument beginning http:// or https:// is
rem fetched, and anything else is opened as a file. There is no
rem separate function and no flag. Twenty-six units share the same
rem helper -- ImageLib, MediaPlayerLib, BitmapListAnimationLib and the
rem twenty-two transition effects.
rem
rem NOTHING IS FETCHED HERE. A suite that downloads a picture fails
rem whenever somebody else's server is down, and this repository
rem already pays that cost in Examples/, where 22 applets reach
rem picsum.photos and httpbin.org on every verification run.
rem
rem What is asserted instead is that the two paths are told APART. The
rem host below ends in .invalid, which RFC 2606 reserves so that it can
rem never resolve: no request leaves the machine, the answer is
rem immediate, and a URL that cannot be reached reports differently
rem from a file that is not there.
rem ---------------------------------------------------------------

URL$ = "https://plan9basic.invalid/assets/image1.png"
FILE$ = "bin/p9b_no_such_picture.png"

f# = form#("target host", 400, 300)
r# = rectangle#(f#, 10, 10, 200, 150)

test_case("transitions/a-target-can-be-a-url")
rem fadetrans stands for all twenty-two: they share one helper, so what
rem holds for the shape of the answer holds for every one of them. The
rem sweep below then checks that each is actually wired to it.
fx# = fadetrans#(r#)
assert_true(pnttonum(fx#), "a transition effect is made on a control")

fadetrans_clearerror()
fadetrans_loadtarget#(fx#, FILE$)
file_err = fadetrans_error()
assert_true(file_err, "a target file that is not there fails")

fadetrans_clearerror()
fadetrans_loadtarget#(fx#, URL$)
url_err = fadetrans_error()
assert_true(url_err, "and a target url that cannot be reached fails too")

rem Both answer the SAME code -- these libraries have one load-failed
rem code and no separate file-not-found -- so the code cannot tell the
rem branches apart. The message can, and does: one says the file was
rem not found and the other that the URL could not be fetched. That is
rem what proves the url went down the fetching branch instead of being
rem opened as a file name.
assert_eq(file_err, url_err, "both failures share one code")

fadetrans_clearerror()
fadetrans_loadtarget#(fx#, FILE$)
assert_true(instr(fadetrans_errormsg$(), "file not found") + 1, "the file failure says so")

fadetrans_clearerror()
fadetrans_loadtarget#(fx#, URL$)
assert_true(instr(fadetrans_errormsg$(), "URL") + 1, "and the url failure names the url")

test_case("transitions/every-effect-takes-one")
rem One call each, so a library that was never wired to the shared
rem helper -- or was wired to the wrong control type -- shows up here
rem rather than the first time somebody uses it.
bandedswirltr_clearerror()
bandedswirltr_loadtarget#(bandedswirltr#(r#), URL$)
assert_true(instr(bandedswirltr_errormsg$(), "URL") + 1, "bandedswirltr takes a url")

blindtrans_clearerror()
blindtrans_loadtarget#(blindtrans#(r#), URL$)
assert_true(instr(blindtrans_errormsg$(), "URL") + 1, "blindtrans takes a url")

bloodtrans_clearerror()
bloodtrans_loadtarget#(bloodtrans#(r#), URL$)
assert_true(instr(bloodtrans_errormsg$(), "URL") + 1, "bloodtrans takes a url")

blurtrans_clearerror()
blurtrans_loadtarget#(blurtrans#(r#), URL$)
assert_true(instr(blurtrans_errormsg$(), "URL") + 1, "blurtrans takes a url")

brighttrans_clearerror()
brighttrans_loadtarget#(brighttrans#(r#), URL$)
assert_true(instr(brighttrans_errormsg$(), "URL") + 1, "brighttrans takes a url")

circletrans_clearerror()
circletrans_loadtarget#(circletrans#(r#), URL$)
assert_true(instr(circletrans_errormsg$(), "URL") + 1, "circletrans takes a url")

crumpletrans_clearerror()
crumpletrans_loadtarget#(crumpletrans#(r#), URL$)
assert_true(instr(crumpletrans_errormsg$(), "URL") + 1, "crumpletrans takes a url")

dissolvetrans_clearerror()
dissolvetrans_loadtarget#(dissolvetrans#(r#), URL$)
assert_true(instr(dissolvetrans_errormsg$(), "URL") + 1, "dissolvetrans takes a url")

droptrans_clearerror()
droptrans_loadtarget#(droptrans#(r#), URL$)
assert_true(instr(droptrans_errormsg$(), "URL") + 1, "droptrans takes a url")

linetrans_clearerror()
linetrans_loadtarget#(linetrans#(r#), URL$)
assert_true(instr(linetrans_errormsg$(), "URL") + 1, "linetrans takes a url")

magnifytrans_clearerror()
magnifytrans_loadtarget#(magnifytrans#(r#), URL$)
assert_true(instr(magnifytrans_errormsg$(), "URL") + 1, "magnifytrans takes a url")

pixelatetrans_clearerror()
pixelatetrans_loadtarget#(pixelatetrans#(r#), URL$)
assert_true(instr(pixelatetrans_errormsg$(), "URL") + 1, "pixelatetrans takes a url")

rippletrans_clearerror()
rippletrans_loadtarget#(rippletrans#(r#), URL$)
assert_true(instr(rippletrans_errormsg$(), "URL") + 1, "rippletrans takes a url")

rotcrumpletrans_clearerror()
rotcrumpletrans_loadtarget#(rotcrumpletrans#(r#), URL$)
assert_true(instr(rotcrumpletrans_errormsg$(), "URL") + 1, "rotcrumpletrans takes a url")

saturatrans_clearerror()
saturatrans_loadtarget#(saturatrans#(r#), URL$)
assert_true(instr(saturatrans_errormsg$(), "URL") + 1, "saturatrans takes a url")

shapetrans_clearerror()
shapetrans_loadtarget#(shapetrans#(r#), URL$)
assert_true(instr(shapetrans_errormsg$(), "URL") + 1, "shapetrans takes a url")

swipetrans_clearerror()
swipetrans_loadtarget#(swipetrans#(r#), URL$)
assert_true(instr(swipetrans_errormsg$(), "URL") + 1, "swipetrans takes a url")

swirltrans_clearerror()
swirltrans_loadtarget#(swirltrans#(r#), URL$)
assert_true(instr(swirltrans_errormsg$(), "URL") + 1, "swirltrans takes a url")

watertrans_clearerror()
watertrans_loadtarget#(watertrans#(r#), URL$)
assert_true(instr(watertrans_errormsg$(), "URL") + 1, "watertrans takes a url")

wavetrans_clearerror()
wavetrans_loadtarget#(wavetrans#(r#), URL$)
assert_true(instr(wavetrans_errormsg$(), "URL") + 1, "wavetrans takes a url")

wiggletrans_clearerror()
wiggletrans_loadtarget#(wiggletrans#(r#), URL$)
assert_true(instr(wiggletrans_errormsg$(), "URL") + 1, "wiggletrans takes a url")

test_case("animation/a-sprite-sheet-can-be-a-url")
rem The same rule reaches the animation that walks a strip of frames:
rem the sheet is a picture, so it can come from the network.
a# = bmplistani#(r#)
assert_true(pnttonum(a#), "a bitmap-list animation is made on a control")

bmplistani_clearerror()
bmplistani_loadspritesheet#(a#, FILE$)
sheet_file = bmplistani_error()
assert_true(sheet_file, "a sheet that is not there fails")

bmplistani_clearerror()
bmplistani_loadspritesheet#(a#, URL$)
sheet_url = bmplistani_error()
assert_true(sheet_url, "and one that cannot be fetched fails too")

assert_eq(sheet_file, sheet_url, "both failures share one code here too")

rem This one is built the other way round from the transitions: it tries
rem the web FIRST and, if that comes back empty, falls through to
rem opening the same string as a file. So a URL that cannot be reached
rem is reported as "File not found", naming the URL -- which is honest
rem about what was tried last and misleading about what was tried
rem first. The wording is worth knowing; the behaviour, trying both, is
rem the more forgiving of the two designs.
bmplistani_clearerror()
bmplistani_loadspritesheet#(a#, URL$)
assert_true(instr(bmplistani_errormsg$(), URL$) + 1, "the message names what failed")
assert_true(instr(bmplistani_errormsg$(), "File not found") + 1, "though it calls a url a file")

test_case("animation/verbs")
rem start, stop and running only mean something while a message loop is
rem turning, and this runner has none -- so what is pinned is that the
rem verbs are reachable and leave the object intact.
bmplistani_clearerror()
bmplistani_start(a#)
bmplistani_stop(a#)
bmplistani_stopatcurrent(a#)
assert_eq(bmplistani_error(), 0, "the three verbs are reachable")

form_free(f#)
