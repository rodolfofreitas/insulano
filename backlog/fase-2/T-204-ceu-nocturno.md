---
id: T-204
titulo: Céu nocturno com estrelas e lua desenhadas em código
fase: 2
estado: pronto
tipo: visual
depende_de: [T-202]
---

## Objectivo
De noite aparecem estrelas a cintilar e uma lua sobre o mar; de dia não se vêem. Tudo desenhado em código, sem assets novos.

## Ler antes
- game/world/day_night.gd (T-202) e game/data/day_night_palette.json
- game/tools/capture.gd
- docs/assets-licencas.md (confirmar que não entra asset novo)

## Critérios de aceitação
- [ ] Existe `game/world/night_sky.gd` com `class_name NightSky` que desenha estrelas e lua com `_draw()` (sem `load()` de texturas novas) (prova: `grep -n 'load(' game/world/night_sky.gd` vazio ou só recursos já existentes).
- [ ] As posições das estrelas são geradas com seed fixa, idênticas entre arranques (prova: teste GUT `game/tests/unit/test_night_sky.gd` que compara duas gerações com a mesma seed).
- [ ] `static func sky_alpha_for_hour(hour: float) -> float` devolve 0 entre as 07h e as 18h, 1 entre as 21h e as 05h e valores intermédios no crepúsculo (prova: GUT com as fronteiras).
- [ ] O céu fica atrás do personagem e da ilha (z_index ou ordem na árvore) e não recebe a modulação escura do DayNight de forma que desapareça (prova: screenshot).
- [ ] Screenshot `docs/proof/T-204-23h.png` com estrelas e lua visíveis e `docs/proof/T-204-13h.png` sem elas, ambos inspeccionados e descritos no Relatório.
- [ ] `scripts/verify.sh --visual` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido; CHANGELOG em [Não lançado].

## Fora de âmbito
- Fases da lua reais (pode vir depois).
- Estrelas cadentes ou outros eventos.

## Prova exigida
- Os dois PNG em docs/proof/ e o comando usado para cada um.

## Relatório
(preenchido pelo executor)
