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
| 2 | **Unificar o engine** | Uma única cópia de `exec`/`parser`/`lexer`/`basic`, consumida pelo IDE e pelo AppletRunner | Pendente |
| 3 | **Segurança de runtime** | Handles opacos por registry; política de erro no lugar do `except end`; guarda no limite de globais | Pendente |
| 4 | **Testes** | Runner headless de `.bas` com asserts, convertendo os 98 exemplos em suíte executável | Pendente |
| 5 | **Colapsar boilerplate GUI** | Gerar os wrappers a partir de descritores, ou substituir por camada RTTI genérica | Pendente |

A frente 4 é pré-requisito prático das frentes 2, 3 e 5: sem suíte executável, qualquer refatoração do engine ou das bibliotecas é feita no escuro.

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
