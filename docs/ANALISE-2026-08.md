# Plan9Basic — Análise Técnica e Roteiro de Modernização

**Data:** 2026-08-17
**Base:** commit `5d54670` (estado do código no commit inicial do repositório)
**Escopo:** projeto principal (IDE + engine). Referências de linha valem para o commit acima.

---

## 1. Panorama

| Métrica | Valor |
|---|---|
| Código Pascal (projeto principal) | **136 unidades / ~150.400 linhas** |
| Núcleo do interpretador | 15.174 linhas |
| Bibliotecas GUI (controles, 64 efeitos, animações) | **71.895 linhas — 48% do projeto** |
| Bibliotecas não-GUI (Str, Num, Json, Http, SQLite, AI/RAG…) | 21.791 linhas |
| Funções nativas registradas | ~4.690 bindings |
| Documentação | 217 arquivos `.md` (duas gerações: `Changelogs/` e `New docs/`) |
| Exemplos / demos `.bas` | 98 exemplos + 9 jogos |
| Plataformas configuradas no `.dproj` | Win32/64, Linux64, macOS (3), Android (2), iOS (3) |

Detalhamento do núcleo:

| Unidade | Linhas | Papel |
|---|---|---|
| `parser.pas` | 5.103 | Parser e gerador de código |
| `UnitMain.pas` | 3.550 | IDE (console, editor, comandos) |
| `exec.pas` | 3.001 | Máquina de pilha (VM) |
| `UnitUtils.pas` | 1.011 | Utilitários compartilhados |
| `utils/BasicConsole.pas` | 963 | Console com syntax highlighting |
| `lexer.pas` | 775 | Tokenizador |
| `basic.pas` | 450 | Fachada `TBasicEngine` |
| `utils/UnitGC.pas` | 321 | Coletor de lixo |

---

## 2. Arquitetura

O pipeline é limpo e bem separado:

```
fonte BASIC
   ↓  lexer.pas          tokenização (TBasToken)
   ↓  parser.pas         validação sintática → código intermediário postfix
   ↓  ProcessPostfixCode geração de assembly (TAsmToken)
   ↓  exec.pas           máquina de pilha executa
saída
```

`TBasicEngine` ([basic.pas:48](../basic.pas)) é uma fachada fina e correta sobre esse conjunto. O despacho da VM resolve ponteiros de método em tempo de carga, e não com um `case` no loop quente ([exec.pas:2911](../exec.pas)) — decisão acertada.

O modelo de extensão usa assinaturas em string (`"strlen@$"`, `"pointer#@n"`) mapeadas para `TBindFunction`. Simples e produtivo: foi o que viabilizou 4.690 funções.

### Pontos genuinamente bons

- Separação de camadas do engine, com o host desacoplado por trás de `TBasicEngine`
- `LoadIntermediate` permite distribuir applets pré-compilados sem o fonte
- GC com tags e separação explícita entre objetos visuais FMX e não-visuais ([utils/UnitGC.pas:41](../utils/UnitGC.pas))
- Ordem de teardown documentada e correta em `InitBASICEngine` (timers → forms → engine → GC)
- Console próprio com realce de sintaxe via `Paint` customizado
- Cobertura real de 5 plataformas
- Documentação por biblioteca acima da média do mercado

---

## 3. Dívidas técnicas, por gravidade

### 3.1 Versionamento — ✅ RESOLVIDO em 2026-08-17

O projeto vivia sem controle de versão, em OneDrive, com `__history/`, `__recovery/` e uma pasta `archive/` de 2,3 GB. Resolvido com a criação do repositório privado `AndreMurtaX/Plan9Basic`. Ver seção 6.

### 3.2 Engine duplicado

`exec.pas`, `parser.pas`, `lexer.pas`, `basic.pas`, `UnitUtils.pas` e 15 bibliotecas existem em duas cópias: neste repositório e em `Plan9BasicAppletRunner` (repositório próprio, `AndreMurtaX/Plan9BasicAppletRunner`).

Hoje as cópias diferem **apenas** na linha de copyright e no BOM. São 5.103 linhas de parser mantidas em dobro; a divergência é questão de tempo.

### 3.3 Exceções silenciadas em escala

234 ocorrências de `try ... except end;` e ~3.510 blocos `except` nas bibliotecas. O padrão dominante nos acessores GUI:

```pascal
function p_button_text_set(var Args: array of TAsmData): TAsmData;
begin
  ...
  if not ValidateButton(Args[0].p, 'button_text#') then Exit();
  try TBasButton(Args[0].p).Text := Args[1].s; except end;   // falha em silêncio
end;
```

A falha não chega sequer ao `lastError` do módulo. Depurar um applet que "não faz nada" fica próximo do impossível.

### 3.4 Validação de handle por `is` sobre ponteiro arbitrário

`ValidateButton` faz `TObject(P) is TBasButton` dentro de `try/except` ([Libs/GUI/ButtonLib.pas:238](../Libs/GUI/ButtonLib.pas)). Como a linguagem permite fabricar ponteiros (`pointer#(n)`), isso dereferencia memória arbitrária. No Windows a AV é capturável; no Android e no Linux o SIGSEGV normalmente **não** é — resulta em crash duro. O padrão está replicado em cerca de 30 bibliotecas GUI.

### 3.5 Estado global por módulo

38 bibliotecas mantêm `ModuleEngine`, `ModuleOutput` e `lastError` como variáveis de unidade. Zero `TCriticalSection` nas libs. Consequências: impossível ter duas instâncias de engine no mesmo processo, "BASIC dentro de BASIC" é arriscado, e execução fora da thread de UI está fechada.

### 3.6 VM na thread da UI

`CmdRun` chama `ExecuteProgram` direto no handler do botão, e há 127 ocorrências de `Application.ProcessMessages` entre engine e bibliotecas. Isso gera reentrância (RUN durante o RUN) e risco permanente de ANR no Android. O `TThread.Sleep(16)` no loop de pausa ([exec.pas:941](../exec.pas)) é remendo do mesmo problema.

### 3.7 Limites fixos sem guarda

```pascal
MAXSTACK  = 16384;   // itens de pilha
MAXLOCALS = 259;     // 256 args+locais + 3 registradores
MAXVARS   = 515;     // 512 globais + 3 registradores
HeapMem: array [0 .. MAXVARS] of TAsmData;   // exec.pas:247
```

`fPush`/`fPopStore` indexam `HeapMem` sem verificação, e o parser adiciona globais sem checar teto ([parser.pas:4855](../parser.pas)). Range checking está habilitado **apenas na configuração Debug** do `.dproj`. Em Release, um programa com mais de 513 globais corrompe memória silenciosamente.

Locais, argumentos e pilha **têm** guarda ([exec.pas:1782](../exec.pas)); globais não.

### 3.8 Boilerplate massivo nas bibliotecas GUI

64 unidades de efeitos somam 27.184 linhas; comparando duas quaisquer, cerca de 95% do conteúdo é idêntico a menos de nomes. O mesmo vale para os wrappers de controle (2.000 a 3.600 linhas cada, majoritariamente `get`/`set` de propriedade). Metade do projeto é código que geração por template ou uma camada RTTI produziria.

### 3.9 Ausência de testes automatizados

Os 98 `.bas` em `Examples/` são suítes na intenção, mas exigem execução manual e conferência visual. Não há runner headless, asserts agregados nem CI. Com 4.690 bindings, qualquer mudança no parser é uma aposta.

### 3.10 Documentação sem vínculo com o código

Duas gerações coexistem (`Changelogs/`, de janeiro/2026, e `New docs/`, de março/2026) e nada garante que uma assinatura documentada ainda exista no `.pas` correspondente.

---

## 4. A linguagem

Cobertura sólida para um BASIC: `FUNCTION` com locais, `SELECT CASE`, `DO/LOOP/UNTIL`, `FOR/NEXT`, `GOTO/GOSUB/ON`, `DATA/READ/RESTORE`, arrays multidimensionais, ponteiros como handles, chamada indireta (callbacks), literais JSON no parser, e recursos de depuração (`TRACE`, `WATCH`, `BREAKPOINT`).

Ausências notáveis:

- Tipos ou estruturas definidos pelo usuário
- `INCLUDE` / módulos — todo programa é um arquivo único
- Tratamento de erro na linguagem (`TRY` / `ON ERROR`)
- Escopo de bloco

---

## 5. Roteiro de modernização

Cinco frentes, em ordem de retorno esperado.

| # | Frente | Objetivo | Status |
|---|---|---|---|
| 1 | **Fundação de engenharia** | Versionamento, `.gitignore`, organização em disco | ✅ Concluída em 2026-08-17 |
| 4 | **Testes** | Runner headless de `.bas` com asserts | ✅ Concluída em 2026-08-17 |
| 3 | **Segurança de runtime** | Handles opacos por registry; política de erro; guarda no limite de globais | ✅ Concluída em 2026-08-17 |
| 2 | **Unificar o engine** | Uma única cópia de `exec`/`parser`/`lexer`/`basic`, consumida pelo IDE e pelo AppletRunner | ✅ Concluída em 2026-08-17 |
| 5 | **Colapsar boilerplate GUI** | Gerar os wrappers a partir de descritores, ou substituir por camada RTTI genérica | Pendente — ver §9 |

A frente 4 foi executada primeiro por ser pré-requisito prático das demais:
sem suíte executável, refatorar o engine ou as bibliotecas é trabalho no escuro.
Ela já se pagou — encontrou dois defeitos reais durante a própria construção
(§7).

A frente 3 saiu completa: guarda de globais, handles opacos e política de erro.
O volume real do `except end` silencioso era **1.675 blocos**, não os 234 que
esta análise estimou — a contagem original usava um padrão mais estreito e não
alcançava a forma multilinha, que é a dominante.

À parte do técnico, há uma discussão de produto pendente: o IDE console, o AppletRunner e o site sugerem uma direção de distribuição de applets que vale explicitar antes de fixar prioridades.

---

## 6. Registro da frente 1

Executada em 2026-08-17.

**Repositórios**

| Repositório | Visibilidade | Local em disco |
|---|---|---|
| `AndreMurtaX/Plan9Basic` | privado | `C:\Dev\Plan9Basic` |
| `AndreMurtaX/Plan9BasicAppletRunner` | público | `C:\Dev\Plan9BasicAppletRunner` |

**Decisões de versionamento**

- `archive/` (2,3 GB de snapshots antigos) fica **fora** do repositório, preservado apenas na cópia do OneDrive
- `Plan9BasicAppletRunner/` é excluído via `.gitignore`: sendo repositório próprio, aninhá-lo criaria um *gitlink* quebrado. A entrada permanece como proteção mesmo após ele ter sido movido para fora da árvore
- Excluídos também: saída de compilação, artefatos do IDE, binários distribuíveis do site e PDFs de terceiros

**Organização em disco**

O projeto saiu do OneDrive para `C:\Dev`, o AppletRunner deixou de ser aninhado, e a pasta do projeto caiu de 3.363 MB para 622 MB. A cópia antiga do OneDrive foi preservada como backup, com `.git` renomeado para `.git.disabled` para impedir commit acidental na árvore errada.

**Portabilidade verificada:** `.dproj`, `.dpr`, `.deployproj` e `.git/config` não contêm nenhum caminho absoluto — o projeto move-se sem ajuste. Carregam caminho absoluto apenas `Plan9Basic.dsk` (regenerável pelo IDE) e `.claude/settings.local.json` (regras de permissão locais).

---

## 7. Registro das frentes 4 e 3

Executadas em 2026-08-17, sobre o commit `9f1215b`.

### Ferramental descoberto

O compilador de linha de comando (`dcc64.exe`, RAD Studio 37.0) compila os dois
projetos sem nenhum setup de ambiente:

| Projeto | Linhas | Tempo |
|---|---|---|
| `Plan9Basic.dpr` (IDE completo, FMX) | 144.244 | ~4,5 s |
| `Plan9BasicApplet.dpr` (runner) | 27.280 | ~1,4 s |

Isso é o que torna verificável qualquer refatoração daqui para frente, e é o que
permitiu mexer em 37 bibliotecas com confiança.

### Frente 4 — testes

`tests/Plan9BasicTest.dpr` executa `.bas` sem IDE e sem UI, com engine e GC novos
por arquivo. O engine já era headless-capaz: `exec.pas` referencia FMX, mas a
flag `UnitGC.SkipProcessMessages` desliga o bombeamento de mensagens no caminho
do PRINT, e o único outro `Application.ProcessMessages` só roda em pausa/
breakpoint.

- **322 asserções** em 15 arquivos, mais suíte negativa de 4 arquivos
- Modo `--smoke` roda os `Examples/` existentes como rede de regressão: **24 dos
  25 exemplos não-GUI** passam
- A saída é varrida por `[FAIL]`, porque vários exemplos reportam o próprio
  resultado imprimindo — sem isso, um arquivo que só imprime falhas passaria
  como verde

Detalhe da linguagem que moldou a suíte: expressão booleana só é válida dentro
da condição de `IF`/`WHILE`/`UNTIL`. `assert_true(2 > 1)` não compila.

### Frente 3 — limite de globais

O índice de uma global endereça `HeapMem`, array fixo `[0..515]`, e range
checking só está ligado na configuração Debug. O parser não checava o teto: em
Release, um programa com mais de 513 globais corrompia memória em silêncio.

Agora é erro de compilação com a linha exata, e os acessos a `HeapMem` no
`exec` validam o índice. O limite está fixado nas duas pontas por teste: 513
globais compila e roda, 514 é rejeitado.

### Frente 3 — handles opacos

`utils/HandleRegistry.pas`. Cada objeto entregue como handle se registra na
construção junto com sua classe, e se remove na destruição. A validação virou
consulta de dicionário pelo **valor** do ponteiro, comparando com a classe
gravada no registro — o ponteiro do chamador nunca é seguido.

O cancelamento do registro fica no destrutor, e não na biblioteca que criou o
objeto, porque o FMX libera controles filhos por posse do pai e a biblioteca
nunca vê essas liberações. Em `ArrayLib` e `DictLib`, cujas descendentes têm
construtores próprios e nenhum destrutor, as classes base usam
`AfterConstruction`/`BeforeDestruction`.

Convertidas **37 classes** em 35 bibliotecas GUI mais `ArrayLib` e `DictLib`.
Nenhum `TObject(P) is TBasXxx` resta. `arr_free` tinha o mesmo dereference sem
sequer o `try/except` em volta.

Ponteiro forjado passado a `ndims`, `dict_count` ou `arr_free` agora produz o
diagnóstico da própria biblioteca com a linha exata, em vez de access violation.

### Frente 3 — política de erro

1.675 blocos `try ... except end;` em 25 bibliotecas engoliam a exceção sem
sequer registrar no `lastError` do módulo. Passam a registrar, mantendo o fluxo
de controle: o acessor continua retornando normalmente, mas a falha fica visível
pelos acessores de erro que cada lib já expõe.

O rótulo é o nome que o programa BASIC usa, extraído da chamada de validação de
handle que quase toda função já faz — `ValidateMemo(Args[0].P, 'memo_text#')`
vira `SetError(ERR_OPERATION_FAILED, 'memo_text#: ' + E.Message)`. Dos 1.675
sítios, 1.673 receberam o nome BASIC correto; 2 em `AILib` estavam em métodos de
classe sem essa chamada e receberam o nome do método.

Dois sítios em `RectAnimationLib` continuam silenciosos de propósito: são
caminho de teardown, onde a única ação sensata é continuar desempilhando, e
`SetError` é declarado depois deles na unidade.

`SQLiteLib` ficou de fora: não segue o padrão de constantes de erro das demais.

### Defeitos encontrados pela suíte

1. **`RegexLib.regex_isvalid` / `regex_error$`** — usavam `TRegEx.Create`, que no
   Delphi é preguiçoso e não compila o padrão. Todo padrão malformado era
   reportado como válido. Corrigido forçando a compilação, com o padrão vazio
   (que é regex legal) tratado à parte.
2. **`Examples/21_Base64Lib_tests.bas`** — chamada de `savetext$` com argumentos
   fora de ordem, que criava um arquivo de lixo com o conteúdo como nome.

### Achados registrados, sem correção

- **`savetext$`/`opentext$` não faz round-trip fiel**: passam por `TStringList`,
  então o texto lido de volta ganha um CRLF no fim — 11 caracteres entram, 13
  voltam. `file_writealltext`/`file_readalltext$` (IOUtilsLib) não têm o
  problema. Comportamento fixado por teste em `suite/12_fileio.bas` para que
  mudá-lo seja decisão, e não acidente.
- **Ordem de argumentos inconsistente em StrLib**: `containsstr(texto$, parte$)`
  mas `startsstr(prefixo$, texto$)` e `endsstr(sufixo$, texto$)`. Herdado do
  `System.StrUtils` do Delphi, que é irregular. Documentado em
  `suite/06_strings.bas`.

---

## 8. Registro da frente 2

Executada em 2026-08-17, logo depois das frentes 4 e 3.

A divergência que esta análise previu tinha acabado de se materializar: até as
correções de segurança, as duas cópias diferiam apenas no cabeçalho de licença
(**zero divergência de código** em 22 unidades); depois delas, `exec.pas`
divergia em 45 linhas e `parser.pas` em 19, com o AppletRunner — que executa
applets distribuídos — ficando com a corrupção de memória e o dereference de
ponteiro arbitrário.

**Solução adotada:** repositório próprio para o engine, consumido como submódulo
pelos dois hospedeiros.

| Repositório | Visibilidade | Papel |
|---|---|---|
| [`AndreMurtaX/Plan9BasicEngine`](https://github.com/AndreMurtaX/Plan9BasicEngine) | público | núcleo + biblioteca padrão (23 unidades) |
| `AndreMurtaX/Plan9Basic` | privado | IDE — consome em `engine/` |
| `AndreMurtaX/Plan9BasicAppletRunner` | público | runner — consome em `engine/` |

Fundir tudo num repositório só estava bloqueado pela diferença de visibilidade;
o engine é MIT pelos próprios cabeçalhos, então publicá-lo à parte é coerente.

**O que foi para o engine:** núcleo (`basic`, `exec`, `lexer`, `parser`,
`UnitUtils`), `utils/UnitGC`, `utils/HandleRegistry`, `Libs/GUI/TimerLib`
(dependência de `exec.pas`), as 12 bibliotecas não-GUI que o runner usa e as 3
de IA. Cabeçalho MIT normalizado em todas — 14 não tinham, e 9 traziam o
placeholder `[Your Name]`.

**O que ficou no IDE:** as 34 bibliotecas GUI restantes, os 64 efeitos,
`DictLib`, `StrListLib`, `RegexLib`, `GzipLib`, `IOUtilsLib` e `SQLiteLib`.

Caminhos atualizados no `.dpr` **e** no `.dproj` dos dois projetos — o `.dproj`
lista cada unidade individualmente, e esquecê-lo quebraria o build pelo IDE.

**Verificação:** IDE compila (147.701 linhas), runner compila (27.752), 338
asserções e a suíte negativa verdes, e a divergência entre as duas árvores caiu
para **zero linha** nas cinco unidades do núcleo. Um clone novo com
`--recurse-submodules` compila igual.

**Pendência descoberta na verificação:** `Plan9BasicApplet.res` não é versionado
(`*.res` no `.gitignore`), então um clone limpo só compila depois de abrir o
projeto uma vez no RAD Studio, que regenera o arquivo. Lacuna pré-existente, não
introduzida aqui, mas incômoda num repositório público cujo objetivo é que
terceiros consigam compilar.

---

## 9. Frente 5 — dimensionamento

As 64 unidades de efeito somam **27.190 linhas**. Comparando duas quaisquer com
os nomes normalizados, a diferença é pequena: `SepiaEffectLib` (362 linhas) e
`InvertEffectLib` (313) diferem em 67 linhas, e boa parte disso é a própria
diferença de tamanho — cerca de 82% idêntico.

O caminho de menor risco é gerar essas unidades a partir de descritores
(nome do efeito, classe FMX, lista de propriedades com tipo), mantendo a saída
versionada para o diff continuar legível. A camada RTTI genérica elimina mais
código, mas troca erro de compilação por erro de runtime num projeto que hoje
não tem cobertura de teste na parte GUI — a suíte headless não alcança as libs
FMX.

Pré-requisito prático: alguma forma de exercitar as bibliotecas GUI
automaticamente. Sem isso, colapsar 27 mil linhas é uma aposta.
