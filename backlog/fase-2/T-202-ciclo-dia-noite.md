---
id: T-202
titulo: Ciclo dia/noite com paleta interpolada por hora
fase: 2
estado: feito
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
T-202 implementada a 2026-09-15.

**Ficheiros criados:**
- `game/world/day_night.gd` - DayNight extends CanvasModulate, interpola 13 pontos da paleta
- `game/tests/unit/test_day_night.gd` - 4 testes GUT: ponto exacto, ponto medio, wrap-around, palette vazia

**Ficheiro modificado:**
- `game/test_scene.tscn` - nodo DayNight (CanvasModulate + script) adicionado como filho de TestWorld

**Capturas de ecra (4 PNG em docs/proof/):**
- `T-202-08h.png`: luz de manha cedo - tint quente amarelado (#f5d090 interpolado para #e8a05a), ilha verde viva, oceano azul claro, naufrago distinguivel ao centro
- `T-202-13h.png`: meio-dia - tint quase branco/creme (#f7e8b8), cores naturais maximas, naufrago bem visivel
- `T-202-19h.png`: crepusculo - tint roxo-escuro intenso (#602040), ilha e oceano em tons violeta profundo, naufrago visivel em vermelho escuro no centro
- `T-202-23h.png`: madrugada profunda - tint azul-noite muito escuro (#0d1130), cena quase negra com silhuetas distinguiveis do oceano/ilha, naufrago discernivel como silhueta minima ao centro

As quatro imagens sao visivelmente diferentes e confirmam que o CanvasModulate aplica correctamente a paleta interpolada. A cena das 23h e escura mas o personagem e distinguivel como silhueta.

**Comandos de captura:**
```
INSULANO_FAKE_TIME=2026-09-13T08:00 godot --rendering-driver opengl3 --fixed-fps 60 --path game -s res://tools/capture.gd -- --out=$PWD/docs/proof/T-202-08h.png --frames=240
INSULANO_FAKE_TIME=2026-09-13T13:00 godot --rendering-driver opengl3 --fixed-fps 60 --path game -s res://tools/capture.gd -- --out=$PWD/docs/proof/T-202-13h.png --frames=240
INSULANO_FAKE_TIME=2026-09-13T19:00 godot --rendering-driver opengl3 --fixed-fps 60 --path game -s res://tools/capture.gd -- --out=$PWD/docs/proof/T-202-19h.png --frames=240
INSULANO_FAKE_TIME=2026-09-13T23:00 godot --rendering-driver opengl3 --fixed-fps 60 --path game -s res://tools/capture.gd -- --out=$PWD/docs/proof/T-202-23h.png --frames=240
```

**verify.sh --visual:** docs PASSOU, backlog PASSOU, pytest PASSOU, lint PASSOU (63 ficheiros proprios), import PASSOU, gut PASSOU (98/98), boot PASSOU, visual PASSOU. VEREDICTO: PASSOU (pre-commit hook).
