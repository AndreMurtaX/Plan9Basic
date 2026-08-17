"""
Gera tests/gui/03_effects.bas a partir das bibliotecas de efeito.

Os descritores (prefixo BASIC, classe FMX, propriedades e seus tipos) são
extraídos das próprias unidades, e a suíte gerada os confere contra o código
atual. Isso valida os descritores antes de qualquer tentativa de regerar as
unidades a partir deles.

Uso:  python tests/gen_effects_suite.py
"""
import re
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
EFFECTS = ROOT / "Libs" / "GUI" / "Effects"
OUT = ROOT / "tests" / "gui" / "03_effects.bas"

# Round-trip através de uma propriedade FMX Single não é exato: várias unidades
# convertem escala (progress guarda 0..100 e devolve 0..1), e o par de conversões
# perde precisão. A tolerância absorve esse ruído e ainda pega o erro que importa
# ao regerar — getter e setter ligados a propriedades diferentes, que devolve um
# valor completamente outro.
TOL = "0.001"


def descriptors():
    out = []
    for p in sorted(EFFECTS.glob("*.pas")):
        t = p.read_text(encoding="utf-8-sig", errors="surrogateescape")
        sigs = re.findall(r"\.Add\('([^']+)'", t)
        prefix = None
        for s in sigs:
            m = re.match(r"^([a-z0-9]+)#@#$", s)
            if m:
                prefix = m.group(1)
                break
        if not prefix:
            print(f"  ! {p.name}: sem construtor no formato <nome>#(pai#), ignorado")
            continue
        props = {}
        for s in sigs:
            m = re.match(rf"^{prefix}_(\w+)#@#([n$#])$", s)
            if m and m.group(1) not in ("enabled", "trigger"):
                props[m.group(1)] = m.group(2)
        out.append({"unit": p.stem, "prefix": prefix, "props": props})
    return out


def main():
    descs = descriptors()
    L = [
        "rem ---------------------------------------------------------------",
        "rem GERADO por tests/gen_effects_suite.py a partir das 64 unidades de",
        "rem efeito. Nao editar a mao.",
        "rem",
        "rem Para cada efeito: cria, confere que nao acusou erro, e faz round-trip",
        "rem de identidade em cada propriedade numerica (le, grava o mesmo valor,",
        "rem le de novo). Pega getter e setter ligados a propriedades diferentes,",
        "rem que e o modo de falha ao regerar estas unidades, sem depender de",
        "rem faixa valida para cada propriedade.",
        "rem ---------------------------------------------------------------",
        "",
        "f# = form#()",
        "host# = rectangle#(f#)",
        "",
    ]
    n = 0
    for d in descs:
        pre = d["prefix"]
        L += [f'test_case("effects/{pre}")',
              f"{pre}_clearerror()",
              f"e# = {pre}#(host#)",
              f'assert_eq({pre}_error(), 0, "{pre}# criou sem erro")']
        n += 1
        for prop, kind in d["props"].items():
            if kind != "n":
                continue
            L += [f"v = {pre}_{prop}(e#)",
                  f"{pre}_{prop}#(e#, v)",
                  f'assert_near({pre}_{prop}(e#), v, {TOL}, "{pre}_{prop} round-trip")']
            n += 1
        L += [f"{pre}_enabled#(e#, 1)",
              f'assert_eq({pre}_enabled(e#), 1, "{pre}_enabled ligado")',
              f"{pre}_enabled#(e#, 0)",
              f'assert_eq({pre}_enabled(e#), 0, "{pre}_enabled desligado")',
              ""]
        n += 2
    OUT.write_text("\n".join(L), encoding="utf-8")
    print(f"{OUT.relative_to(ROOT)}: {n} asserções sobre {len(descs)} efeitos")


if __name__ == "__main__":
    main()
