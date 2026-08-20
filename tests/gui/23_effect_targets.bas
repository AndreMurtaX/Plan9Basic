rem ---------------------------------------------------------------
rem How a transition effect is given the picture it transitions to.
rem
rem There are three ways, and the applets in Examples/ use all of them:
rem
rem   *_loadtarget#(fx#, source$)      a file OR a url -- covered in
rem                                    18_image_targets.bas
rem   *_targetfromimage#(fx#, img#)    take it from an image control
rem   *_target#(fx#)                   read back what it is holding
rem
rem The second is the one that matters for the way these are really
rem written: Examples/85_Tier4_DistortionEffects_Test.bas loads a
rem picture from the network into an image and hands the image to the
rem effect. So the picture reaching the effect can come from the web
rem without the effect knowing anything about the web.
rem
rem NOTHING IS FETCHED HERE. The url below is under .invalid, which
rem RFC 2606 reserves so it can never resolve, so the chain is proven
rem without a request leaving the machine.
rem ---------------------------------------------------------------

URL$ = "https://plan9basic.invalid/assets/image1.png"

f# = form#("effect host", 400, 300)
r# = rectangle#(f#, 10, 10, 200, 150)
img# = image#(f#, 220, 10, 100, 80)

test_case("effects/target-readback")
rem An effect with nothing loaded still answers when asked what its
rem target is -- a handle to an empty bitmap rather than nothing, so a
rem caller can hand it straight to something else.
fx# = fadetrans#(r#)
t# = fadetrans_target#(fx#)
assert_true(pnttonum(t#), "fadetrans_target# answers a bitmap handle")

test_case("effects/target-from-an-image")
rem The image is empty, so what is proven is the wiring rather than a
rem picture: the call reaches the effect and reports no error.
fadetrans_clearerror()
fadetrans_targetfromimage#(fx#, img#)
assert_eq(fadetrans_error(), 0, "an image can be handed to an effect")

test_case("effects/the-web-to-effect-chain")
rem The whole chain the applets use, with the fetch guaranteed to fail:
rem load a url into an image, then hand the image to the effect. What
rem is asserted is that each step reports for itself -- the image says
rem the fetch failed, and the effect still accepts the image it was
rem given rather than refusing on the image's account.
image_clearerror()
image_load(img#, URL$)
assert_true(image_error(), "the image reports a url it could not fetch")
assert_true(image_isempty(img#), "and stays empty")

fadetrans_clearerror()
fadetrans_targetfromimage#(fx#, img#)
assert_eq(fadetrans_error(), 0, "the effect takes the image regardless, empty or not")

test_case("effects/every-one-answers-its-target")
rem One call each. A library whose target accessor was never wired
rem shows up here rather than the first time somebody reads it back.
assert_true(pnttonum(bandedswirltr_target#(bandedswirltr#(r#))), "bandedswirltr")
assert_true(pnttonum(blindtrans_target#(blindtrans#(r#))), "blindtrans")
assert_true(pnttonum(bloodtrans_target#(bloodtrans#(r#))), "bloodtrans")
assert_true(pnttonum(blurtrans_target#(blurtrans#(r#))), "blurtrans")
assert_true(pnttonum(brighttrans_target#(brighttrans#(r#))), "brighttrans")
assert_true(pnttonum(circletrans_target#(circletrans#(r#))), "circletrans")
assert_true(pnttonum(crumpletrans_target#(crumpletrans#(r#))), "crumpletrans")
assert_true(pnttonum(dissolvetrans_target#(dissolvetrans#(r#))), "dissolvetrans")
assert_true(pnttonum(droptrans_target#(droptrans#(r#))), "droptrans")
assert_true(pnttonum(linetrans_target#(linetrans#(r#))), "linetrans")
assert_true(pnttonum(magnifytrans_target#(magnifytrans#(r#))), "magnifytrans")
assert_true(pnttonum(pixelatetrans_target#(pixelatetrans#(r#))), "pixelatetrans")
assert_true(pnttonum(rippletrans_target#(rippletrans#(r#))), "rippletrans")
assert_true(pnttonum(rotcrumpletrans_target#(rotcrumpletrans#(r#))), "rotcrumpletrans")
assert_true(pnttonum(saturatrans_target#(saturatrans#(r#))), "saturatrans")
assert_true(pnttonum(shapetrans_target#(shapetrans#(r#))), "shapetrans")
assert_true(pnttonum(swipetrans_target#(swipetrans#(r#))), "swipetrans")
assert_true(pnttonum(swirltrans_target#(swirltrans#(r#))), "swirltrans")
assert_true(pnttonum(watertrans_target#(watertrans#(r#))), "watertrans")
assert_true(pnttonum(wavetrans_target#(wavetrans#(r#))), "wavetrans")
assert_true(pnttonum(wiggletrans_target#(wiggletrans#(r#))), "wiggletrans")

test_case("effects/the-four-that-take-an-image")
rem Only some carry the image-control form. The rest take a file or a
rem url and nothing else, which is a difference worth knowing before
rem writing a program around one of them.
blindtrans_clearerror()
blindtrans_targetfromimage#(blindtrans#(r#), img#)
assert_eq(blindtrans_error(), 0, "blindtrans takes an image")

circletrans_clearerror()
circletrans_targetfromimage#(circletrans#(r#), img#)
assert_eq(circletrans_error(), 0, "circletrans does")

dissolvetrans_clearerror()
dissolvetrans_targetfromimage#(dissolvetrans#(r#), img#)
assert_eq(dissolvetrans_error(), 0, "dissolvetrans does")

swipetrans_clearerror()
swipetrans_targetfromimage#(swipetrans#(r#), img#)
assert_eq(swipetrans_error(), 0, "and swipetrans does")

test_case("effects/blend-and-colours")
rem The blend effect takes a second picture to blend with, and it must
rem be an IMAGE control -- not a shape, not a bitmap handle. Anything
rem else answers "target must be a TImage", which is the library
rem checking rather than dereferencing.
bl# = blend#(r#)
blend_clearerror()
blend_target#(bl#, rectangle#(f#, 10, 170, 60, 60))
assert_true(blend_error(), "a shape is refused as a blend target")
assert_true(instr(blend_errormsg$(), "TImage") + 1, "and the message says what was wanted")

blend_clearerror()
blend_target#(bl#, img#)
assert_eq(blend_error(), 0, "an image is accepted")

rem Two effects carry a colour, in the three spellings this engine uses
rem for one: a name in, a name out, and the number underneath.
gl# = glow#(r#)
glow_color#(gl#, "Red")
assert_true(len(glow_color$(gl#)), "glow_color$ reads a colour back as a name")
assert_true(glow_color(gl#), "and glow_color as a number")

rem The shadow has only two of the three: it takes a name and answers a
rem number, with no spelling that reads one back as a name. The glow has
rem all three. Two effects, two shapes, for the same idea.
sh# = shadow#(r#)
shadow_color#(sh#, "Black")
if shadow_color(sh#) >= 0 then sc_ok = 1
assert_true(sc_ok, "shadow_color answers a number and there is no $ form")

form_free(f#)
