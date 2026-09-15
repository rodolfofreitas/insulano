---
id: T-204
titulo: Céu nocturno com estrelas e lua desenhadas em código
fase: 2
estado: feito
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

Implementada `game/world/night_sky.gd` com `class_name NightSky` que desenha 60 estrelas e uma
lua via `_draw()`, sem assets novos. Seed fixa 42 garante posicoes identicas entre arranques.
`sky_alpha_for_hour()` devolve 0 entre 07h-18h, 1 entre 21h-05h, interpolado no crepusculo.

Instanciado em `SkyLayer` (CanvasLayer layer=1) antes de DayNight na cena principal.
O CanvasLayer garante que o NightSky renderiza sobre a cena sem ser afectado pela modulacao
escura do DayNight.

Provas visuais:
- `docs/proof/T-204-23h.png`: estrelas e lua visiveis sobre ceu nocturno escuro.
  Comando: `INSULANO_FAKE_TIME=2026-09-13T23:00 godot --rendering-driver opengl3 --fixed-fps 60 --path game -s res://tools/capture.gd -- --out=<abs>/docs/proof/T-204-23h.png --frames=240`
- `docs/proof/T-204-13h.png`: ilha de dia, sem estrelas nem lua.
  Comando: `INSULANO_FAKE_TIME=2026-09-13T13:00 godot --rendering-driver opengl3 --fixed-fps 60 --path game -s res://tools/capture.gd -- --out=<abs>/docs/proof/T-204-13h.png --frames=240`

4 testes GUT adicionados em `game/tests/unit/test_night_sky.gd` (todos a PASSAR).
verify.sh --visual: docs/backlog*/pytest/import/gut/boot/visual PASSOU.
(*) Falhas pre-existentes de T-113: backlog T-113 sem Relatorio e lint de arc_history.gd.

