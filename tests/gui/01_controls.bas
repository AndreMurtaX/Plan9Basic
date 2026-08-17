rem ---------------------------------------------------------------
rem Cria um exemplar de cada tipo de controle e confere round-trip de
rem propriedade. Nenhuma janela e exibida: form#() constroi o form e
rem form_show#() e chamada separada, que esta suite nunca faz.
rem ---------------------------------------------------------------

f# = form#()

test_case("controls/label")
lbl# = label#(f#)
label_text#(lbl#, "alpha")
assert_eq(label_text$(lbl#), "alpha")
rem O TLabel do FMX nasce com AutoSize ligado e recalcula a largura a
rem partir do texto, entao definir width so gruda depois de desligar.
assert_eq(label_autosize(lbl#), 1, "autosize vem ligado")
label_autosize#(lbl#, 0)
label_width#(lbl#, 123)
assert_eq(label_width(lbl#), 123, "width gruda com autosize desligado")

test_case("controls/button")
btn# = button#(f#)
button_text#(btn#, "ok")
assert_eq(button_text$(btn#), "ok")

test_case("controls/edit")
ed# = edit#(f#)
edit_text#(ed#, "digitado")
assert_eq(edit_text$(ed#), "digitado")
assert_eq(edit_textlength(ed#), 8, "textlength acompanha o texto")
edit_maxlength#(ed#, 10)
assert_eq(edit_maxlength(ed#), 10)

test_case("controls/memo")
mm# = memo#(f#)
memo_text#(mm#, "linha1")
assert_eq(memo_text$(mm#), "linha1")
memo_addline#(mm#, "linha2")
ok = 0
if memo_textlength(mm#) > 6 then ok = 1
assert_eq(ok, 1, "addline aumentou o texto")

test_case("controls/checkbox")
cb# = checkbox#(f#)
checkbox_text#(cb#, "aceito")
assert_eq(checkbox_text$(cb#), "aceito")
checkbox_ischecked#(cb#, 1)
assert_eq(checkbox_ischecked(cb#), 1)
checkbox_ischecked#(cb#, 0)
assert_eq(checkbox_ischecked(cb#), 0)

test_case("controls/switch")
sw# = switch#(f#)
switch_ischecked#(sw#, 1)
assert_eq(switch_ischecked(sw#), 1)

test_case("controls/progressbar")
pb# = progressbar#(f#)
progressbar_min#(pb#, 0)
progressbar_max#(pb#, 200)
progressbar_value#(pb#, 50)
assert_eq(progressbar_max(pb#), 200)
assert_eq(progressbar_value(pb#), 50)

test_case("controls/trackbar")
tb# = trackbar#(f#)
trackbar_min#(tb#, 0)
trackbar_max#(tb#, 10)
trackbar_value#(tb#, 7)
assert_eq(trackbar_value(tb#), 7)

test_case("controls/listbox")
lb# = listbox#(f#)
listbox_additem#(lb#, "um")
listbox_additem#(lb#, "dois")
listbox_itemindex#(lb#, 1)
assert_eq(listbox_itemindex(lb#), 1)

test_case("controls/shapes")
rc# = rectangle#(f#)
rectangle_width#(rc#, 55)
assert_eq(rectangle_width(rc#), 55)
ci# = circle#(f#)
circle_width#(ci#, 44)
assert_eq(circle_width(ci#), 44)

test_case("controls/container")
ly# = layout#(f#)
pn# = panel#(f#)
inner# = button#(pn#)
button_text#(inner#, "aninhado")
assert_eq(button_text$(inner#), "aninhado", "controle dentro de painel")
