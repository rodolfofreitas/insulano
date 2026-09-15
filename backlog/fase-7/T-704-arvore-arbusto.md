---
id: T-704
titulo: Arbusto tropical -- 32px, flores na primavera
fase: 7
estado: pronto
tipo: visual
depende_de: [T-610]
---

## Objectivo
Desenhar arbusto tropical a 32x48px: folhas verdes tropicais, flores coloridas na primavera (estacao actual via GameClock). Adicionar variacoes de densidade (esparso, medio, denso) para decorar a ilha.

## Ler antes
- docs/visual-identity.md (seccao 3, dimensoes arbusto 32x48px)
- game/world/island_map.gd (posicionamento de vegetacao)
- game/world/game_clock.gd (current_season)

## Critérios de aceitação
- [ ] `game/assets/sprites/tree_bush.png` a 32x48px; 3 variantes de densidade em spritesheet (prova: screenshot docs/proof/T-704-bush.png)
- [ ] Variante primavera: flores cor-de-rosa/amarelas em 4-6 pixels por flor, visiveis e identificaveis (prova: screenshot docs/proof/T-704-bush-spring.png)
- [ ] `AnimationPlayer` com `bush_sway` (2 frames loop) e `bush_flower_bloom` (3 frames, uma vez na transicao para primavera) (prova: GUT)
- [ ] Posicionado em 2-3 locais na ilha por `island_map.gd`; nao bloqueia percurso do naufrago (prova: screenshot in-game sem naufrago preso)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Frutos comestiveis no arbusto (tarefa futura)
- Arbusto como abrigo (T-803 area de sombra -- usa palmeira, nao arbusto)

## Prova exigida
- Screenshots das 4 estacoes em docs/proof/T-704-*.png

## Relatório
(preenchido pelo executor)
