# Plan9Basic — testes automatizados

Runner headless que compila e executa programas `.bas` sem IDE e sem UI, e
reporta as asserções coletadas. Existe para dar rede de segurança às
refatorações do engine e das bibliotecas.

## Como rodar

```powershell
.\tests\build.ps1 -Run
```

O script localiza o `dcc64.exe` pelo registro do RAD Studio, compila
`Plan9BasicTest.dpr` em `tests\bin\` e executa a suíte em `tests\suite\`.
Código de saída: `0` se tudo passou, `1` se algo falhou.

Rodar um arquivo ou pasta específicos:

```powershell
.\tests\build.ps1 -Run -Path .\suite\06_strings.bas
```

## Modo smoke

Os programas em `Examples/` e `Demos/` não têm asserções — foram escritos para
conferência visual. O modo smoke exige apenas que compilem e executem sem erro
de runtime, transformando-os em rede de regressão:

```powershell
.\tests\build.ps1 -Run -Smoke -Path ..\Examples\01_stdlib_test.bas
```

O runner ainda varre a saída em busca de linhas `[FAIL]` e `[ASSERT FAILED]`,
porque vários exemplos reportam o próprio resultado imprimindo. Sem isso um
arquivo que só imprime falhas passaria como verde.

Só as bibliotecas não-GUI são registradas: os wrappers FMX precisam de um form
e de um message loop, que não existem numa execução headless. Exemplos que
criam janelas não rodam aqui.

## Escrevendo testes

Cada arquivo em `suite/` é um programa BASIC comum com as funções de asserção
abaixo. Um arquivo sem nenhuma asserção é reportado como `EMPTY`, não como
aprovado.

| Função | Efeito |
|---|---|
| `test_case(nome$)` | rotula as asserções seguintes |
| `assert_true(n)` / `assert_true(n, msg$)` | falha se `n` for zero |
| `assert_false(n)` / `assert_false(n, msg$)` | falha se `n` não for zero |
| `assert_eq(a, b)` / `assert_eq(a, b, msg$)` | igualdade numérica com epsilon relativo |
| `assert_eq(a$, b$)` / `assert_eq(a$, b$, msg$)` | igualdade de strings |
| `assert_near(a, b, tol)` / `assert_near(a, b, tol, msg$)` | igualdade com tolerância explícita |
| `test_fail(msg$)` | falha incondicional |
| `test_passed()` / `test_failed()` | contadores acumulados |

Uma falha registra o caso, a linha e o valor obtido, e a execução **continua** —
uma rodada mostra todos os problemas, não só o primeiro.

Isso é diferente do comando `ASSERT` embutido na linguagem, que só dispara com
`TRACE` ligado e interrompe o programa na primeira falha. O `ASSERT` continua
servindo para depuração; estas funções servem para suíte.

### Restrições de sintaxe que afetam os testes

Expressão booleana só é válida dentro da condição de `IF`/`WHILE`/`UNTIL`. Não
dá para escrever `assert_true(2 > 1)` nem `x = 2 > 1`. O idioma usado na suíte é:

```basic
ok = 0
if 2 > 1 then ok = 1
assert_eq(ok, 1, "2 > 1")
```

Funções que devolvem número também não valem como condição sozinhas — é preciso
comparar: `if dict_haskey(d#, "k") <> 0 then ...`.

## Cobertura atual

| Arquivo | Assunto |
|---|---|
| `00_harness.bas` | auto-verificação das próprias asserções |
| `01_language_core.bas` | aritmética, precedência, comparação, lógica |
| `02_control_flow.bas` | IF, WHILE, DO, REPEAT, FOR, SELECT CASE, GOSUB, GOTO |
| `03_functions.bas` | UDFs, locais, recursão, os três tipos de retorno |
| `04_arrays.bas` | ArrayLib, indexação 1-based, multidimensionais |
| `05_data_read.bas` | DATA / READ / RESTORE |
| `06_strings.bas` | StrLib, `s$[n]` (linha) e `s$[[n]]` (caractere) |
| `07_numbers.bas` | NumLib |
| `08_dict.bas` | DictLib |
| `09_json.bas` | JsonLib |
| `10_strlist.bas` | StrListLib |
| `11_encoding.bas` | Base64Lib, GzipLib, RegexLib |
| `12_fileio.bas` | IOUtilsLib e o round-trip de `savetext$`/`opentext$` |
| `13_global_limit.bas` | 513 globais (o teto) ainda compila e roda |
| `14_handle_registry.bas` | ponteiro forjado, discriminação de classe, revogação |

## Suíte negativa

`negative/` contém programas que o engine **tem** que rejeitar. São rodados com
`--expect-fail`, onde o veredito é invertido: passar limpo é falha. `build.ps1`
roda as duas suítes quando nenhum `-Path` é informado.

| Arquivo | Deve ser rejeitado porque |
|---|---|
| `01_too_many_globals.bas` | 520 globais, acima do teto de 513 |
| `02_fabricated_array_handle.bas` | ponteiro inventado passado ao ArrayLib |
| `03_fabricated_dict_handle.bas` | idem para DictLib |
| `04_fabricated_arr_free.bas` | idem para `arr_free` |

Nos três últimos o que importa é *como* falha: a mensagem tem que ser o
diagnóstico da própria biblioteca, e não uma access violation. A validação
passou a consultar o `HandleRegistry` pelo valor do ponteiro em vez de
dereferenciá-lo — no Android e no Linux o dereference matava o processo.

Arquivos de trabalho dos testes são escritos em `bin/`, que não é versionado.
