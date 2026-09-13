---
id: T-202
titulo: Ciclo dia/noite com paleta interpolada por hora
fase: 2
estado: pronto
tipo: visual
depende_de: [T-201]
---

## Objectivo
A cor da ilha acompanha a hora do sistema: luz clara de dia, tons quentes ao pôr do sol, azul escuro de noite, com transições suaves e sem cortes.

## Ler antes
- agent_docs/tech_design.md (secção DayNight)
- game/world/game_clock.gd (T-201)
- game/test_scene.tscn (cena principal, onde o nó entra)
- game/tools/capture.gd (como capturar provas)

## Critérios de aceitação
- [ ] Existe `game/world/day_night.gd` com `class_name DayNight` que estende `CanvasModulate` e está instanciado na cena principal (prova: `grep -n DayNight game/test_scene.tscn`).
- [ ] `static func color_for_hour(hour: float) -> Color` interpola linearmente entre as paragens de `game/data/day_night_palette.json` (lista de `{hour, color}` ordenada, com 0 e 24 iguais para fechar o ciclo) (prova: `game/tests/unit/test_day_night.gd`).
- [ ] Testes: cor exacta numa paragem; ponto médio entre duas paragens; 23.99 e 0.0 quase iguais (diferença por canal menor que 0.02); JSON inválido ou vazio devolve `Color.WHITE` com `push_warning` (prova: GUT).
- [ ] A cor aplicada muda no máximo 0.01 por canal por frame a 60 fps (transição suave), verificado por teste que simula frames (prova: GUT).
- [ ] Screenshots às 08h, 13h, 19h e 23h com `INSULANO_FAKE_TIME` gravados em `docs/proof/T-202-08h.png`, `T-202-13h.png`, `T-202-19h.png`, `T-202-23h.png` e inspeccionados: as quatro imagens são visivelmente diferentes e a das 23h é escura mas o personagem continua distinguível.
- [ ] `scripts/verify.sh --visual` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido.
- [ ] CHANGELOG.md tem entrada em [Não lançado].

## Fora de âmbito
- Estrelas e lua (T-204).
- Personagem a dormir (T-203).

## Prova exigida
- Os 4 PNG em docs/proof/ com a descrição do que se vê em cada um no Relatório.
- Comando usado para cada captura, por exemplo: `INSULANO_FAKE_TIME=2026-09-13T23:00 godot --rendering-driver opengl3 --fixed-fps 60 --path game -s res://tools/capture.gd -- --out=$PWD/docs/proof/T-202-23h.png --frames=240`.

## Relatório
(preenchido pelo executor)
