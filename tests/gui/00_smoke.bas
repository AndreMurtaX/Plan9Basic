rem Menor teste possivel do modo --gui: criar um form e um controle,
rem conferir round-trip de propriedade, e liberar. Nada e exibido.
test_case("gui/form")
f# = form#()
assert_true(1, "form criado sem erro")
form_caption#(f#, "titulo de teste")
assert_eq(form_caption$(f#), "titulo de teste", "caption round-trip")
form_width#(f#, 800)
assert_eq(form_width(f#), 800, "width round-trip")

test_case("gui/button")
b# = button#(f#)
button_text#(b#, "clique")
assert_eq(button_text$(b#), "clique", "text round-trip")
