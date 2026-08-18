rem ---------------------------------------------------------------
rem Handle validation in the real GUI libraries.
rem
rem The language lets a program fabricate a pointer with pointer#(n).
rem Before HandleRegistry the check was "TObject(P) is TBasXxx" inside
rem try/except, which follows whatever address it is given: recoverable
rem on Windows, a dead process on Android and Linux.
rem
rem The GUI libraries do not raise in that case: they record the failure
rem in xxx_error(). That makes the behaviour checkable from here.
rem ---------------------------------------------------------------

f# = form#()
lbl# = label#(f#)
btn# = button#(f#)

test_case("handles/fabricated-pointer")
button_clearerror()
junk# = pointer#(305419896)
r$ = button_text$(junk#)
ok = 0
if button_error() <> 0 then ok = 1
assert_eq(ok, 1, "an invented address is rejected")
assert_eq(r$, "", "and returns no content")

test_case("handles/nil")
button_clearerror()
z# = pointer#(0)
r$ = button_text$(z#)
ok = 0
if button_error() <> 0 then ok = 1
assert_eq(ok, 1, "nil is rejected")

test_case("handles/wrong-class")
rem A valid handle, but of another class. This is the case that used to
rem write through the wrong vtable.
button_clearerror()
r$ = button_text$(lbl#)
ok = 0
if button_error() <> 0 then ok = 1
assert_eq(ok, 1, "a label is not a button")

label_clearerror()
r2$ = label_text$(btn#)
ok = 0
if label_error() <> 0 then ok = 1
assert_eq(ok, 1, "a button is not a label")

test_case("handles/valid-handle-reports-no-error")
button_clearerror()
button_text#(btn#, "right")
assert_eq(button_text$(btn#), "right")
assert_eq(button_error(), 0, "the good path records no error")

test_case("handles/freed-handle")
rem Once freed the pointer stops being valid, instead of becoming access
rem to memory that was already returned.
tmp# = button#(f#)
button_text#(tmp#, "ephemeral")
assert_eq(button_text$(tmp#), "ephemeral", "valid while alive")
button_free(tmp#)
button_clearerror()
r3$ = button_text$(tmp#)
ok = 0
if button_error() <> 0 then ok = 1
assert_eq(ok, 1, "a stale pointer is rejected")

rem ---------------------------------------------------------------
rem The cases below cover the two paths missed by the first conversion,
rem because they validated against raw FMX classes (TFmxObject,
rem TSepiaEffect) rather than against TBas classes.
rem ---------------------------------------------------------------

test_case("handles/fabricated-parent")
rem ValidateParent receives the parent whenever a program creates a control.
button_clearerror()
fake# = pointer#(305419896)
b2# = button#(fake#)
ok = 0
if button_error() <> 0 then ok = 1
assert_eq(ok, 1, "an invented parent is rejected")

test_case("handles/valid-parent")
button_clearerror()
b3# = button#(f#)
assert_eq(button_error(), 0, "a real form works as a parent")
button_text#(b3#, "child")
assert_eq(button_text$(b3#), "child")

test_case("handles/fabricated-effect")
sepia_clearerror()
a = sepia_amount(fake#)
ok = 0
if sepia_error() <> 0 then ok = 1
assert_eq(ok, 1, "an invented effect is rejected")

test_case("handles/valid-effect")
host# = rectangle#(f#)
sepia_clearerror()
ef# = sepia#(host#)
assert_eq(sepia_error(), 0, "effect created over a real control")
sepia_amount#(ef#, 0.5)
assert_near(sepia_amount(ef#), 0.5, 0.001, "the property responds")

test_case("handles/effect-wrong-class")
rem A valid handle, but of another effect type.
bevel_clearerror()
d = bevel_size(ef#)
ok = 0
if bevel_error() <> 0 then ok = 1
assert_eq(ok, 1, "a sepia is not a bevel")

test_case("handles/effect-freed-by-its-parent")
rem FMX frees the effect together with the control that owns it, without
rem telling the library. The registry listens to FreeNotification exactly
rem so the handle stops being valid on that path.
host2# = rectangle#(f#)
ef2# = sepia#(host2#)
assert_eq(sepia_error(), 0, "effect alive")
rectangle_free(host2#)
sepia_clearerror()
a2 = sepia_amount(ef2#)
ok = 0
if sepia_error() <> 0 then ok = 1
assert_eq(ok, 1, "the handle dies with the control that owns it")
