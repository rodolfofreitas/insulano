---
id: T-503
titulo: Ecrã de créditos com as atribuições obrigatórias
fase: 5
estado: pronto
tipo: visual
depende_de: [T-501]
---

## Objectivo
Os créditos de todos os assets e bibliotecas ficam visíveis no próprio jogo, cumprindo a atribuição obrigatória da licença CC-BY dos sprites.

## Ler antes
- docs/assets-licencas.md (fonte única de autores e licenças)
- docs/threat_model.md (secção 4, licenças; só leitura)
- game/app/screensaver_mode.gd (T-501)

## Critérios de aceitação
- [ ] Existe um ecrã de créditos (cena e script em `game/app/`) com, pelo menos: sprites do personagem por Antifarea e Clint Bellanger (CC-BY, com link da licença); tileset Tiny Islands por Majadroid (CC0); código base Guy on Island por Doubi (MIT); Beehave (MIT); GUT (MIT); Godot Engine (MIT) (prova: teste GUT que lê o texto do ecrã e procura cada nome).
- [ ] O texto dos créditos é gerado a partir de um único ficheiro de dados (por exemplo `game/data/credits.json`) e existe um teste que verifica que cada linha de `docs/assets-licencas.md` tem correspondência nesse ficheiro (prova: GUT ou pytest em `scripts/tests/`).
- [ ] `-- --credits` abre directamente o ecrã de créditos (prova: GUT da interpretação de argumentos).
- [ ] Em modo protector, os créditos aparecem durante 5 s no início de cada hora do relógio (prova: GUT com relógio simulado).
- [ ] Texto legível: contraste suficiente sobre o fundo e tamanho mínimo equivalente a 16 px a 1280x720 (prova: screenshot `docs/proof/T-503-creditos.png` inspeccionado).
- [ ] `scripts/verify.sh --visual` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido; CHANGELOG em [Não lançado].

## Fora de âmbito
- Página itch.io (T-505).

## Prova exigida
- PNG em docs/proof/ e os testes nomeados.

## Relatório
(preenchido pelo executor)
