rem ---------------------------------------------------------------
rem Validacao de handle nas bibliotecas GUI reais.
rem
rem A linguagem permite fabricar um ponteiro com pointer#(n). Antes do
rem HandleRegistry a validacao era "TObject(P) is TBasXxx" dentro de
rem try/except, que segue o endereco recebido: recuperavel no Windows,
rem morte do processo no Android e no Linux.
rem
rem As libs GUI nao levantam excecao nesse caso: registram em
rem xxx_error(). Isso deixa o comportamento conferivel aqui dentro.
rem ---------------------------------------------------------------

f# = form#()
lbl# = label#(f#)
btn# = button#(f#)

test_case("handles/ponteiro-forjado")
button_clearerror()
junk# = pointer#(305419896)
r$ = button_text$(junk#)
ok = 0
if button_error() <> 0 then ok = 1
assert_eq(ok, 1, "endereco inventado e recusado")
assert_eq(r$, "", "e nao devolve conteudo")

test_case("handles/nil")
button_clearerror()
z# = pointer#(0)
r$ = button_text$(z#)
ok = 0
if button_error() <> 0 then ok = 1
assert_eq(ok, 1, "nil e recusado")

test_case("handles/classe-errada")
rem Handle valido, mas de outra classe. E o caso que antes escrevia
rem atraves da vtable errada.
button_clearerror()
r$ = button_text$(lbl#)
ok = 0
if button_error() <> 0 then ok = 1
assert_eq(ok, 1, "um label nao serve como botao")

label_clearerror()
r2$ = label_text$(btn#)
ok = 0
if label_error() <> 0 then ok = 1
assert_eq(ok, 1, "um botao nao serve como label")

test_case("handles/handle-valido-nao-acusa-erro")
button_clearerror()
button_text#(btn#, "certo")
assert_eq(button_text$(btn#), "certo")
assert_eq(button_error(), 0, "o caminho bom nao registra erro")

test_case("handles/handle-liberado")
rem Depois de liberado o ponteiro deixa de valer, em vez de virar
rem acesso a memoria ja devolvida.
tmp# = button#(f#)
button_text#(tmp#, "efemero")
assert_eq(button_text$(tmp#), "efemero", "vale enquanto vivo")
button_free(tmp#)
button_clearerror()
r3$ = button_text$(tmp#)
ok = 0
if button_error() <> 0 then ok = 1
assert_eq(ok, 1, "ponteiro obsoleto e recusado")
