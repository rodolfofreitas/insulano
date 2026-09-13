---
id: T-506
titulo: Confirmar a licença do código Insulano e criar LICENSE
fase: 5
estado: humano
tipo: docs
depende_de: [T-001]
---

## Objectivo
O repositório tem um ficheiro LICENSE na raiz com a licença escolhida pelo Rodolfo para o código próprio do Insulano, compatível com as licenças herdadas.

## Ler antes
- game/LICENSE-guy-on-island.md (MIT, Doubi)
- docs/threat_model.md secção 4 (só leitura)
- docs/assets-licencas.md
- CLAUDE.md do monorepo Kaeto (repositório privado entre sócios)

## Critérios de aceitação
- [ ] O Rodolfo escolheu a licença (por exemplo MIT com titular Kaeto) e a escolha está registada como ADR em `docs/decisions.md` (prova: diff).
- [ ] Existe `LICENSE` na raiz com o texto completo, ano e titular correctos (prova: o ficheiro).
- [ ] O aviso de copyright MIT do Guy on Island continua preservado em `game/LICENSE-guy-on-island.md` e referido no README (prova: `grep -n 'LICENSE-guy-on-island' README.md`).
- [ ] `python3 scripts/check_docs.py` sem FALHA.

## Fora de âmbito
- Licenciamento dos assets de terceiros (já registado em docs/assets-licencas.md).

## Prova exigida
- ADR, ficheiro LICENSE e output do check_docs.

## Relatório
(preenchido pelo executor)
