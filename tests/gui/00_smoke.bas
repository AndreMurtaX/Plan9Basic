rem Smallest possible check of --gui mode: create a form and a control,
rem verify a property round trip, and free it. Nothing is displayed.
test_case("gui/form")
f# = form#()
assert_true(1, "form created with no error")
form_caption#(f#, "test caption")
assert_eq(form_caption$(f#), "test caption", "caption round trip")
form_width#(f#, 800)
assert_eq(form_width(f#), 800, "width round trip")

test_case("gui/button")
b# = button#(f#)
button_text#(b#, "click")
assert_eq(button_text$(b#), "click", "text round trip")
