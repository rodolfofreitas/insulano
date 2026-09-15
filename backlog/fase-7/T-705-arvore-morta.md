---
id: T-705
titulo: Arvore morta -- 64px, corvo pode pousar
fase: 7
estado: pronto
tipo: visual
depende_de: [T-610]
---

## Objectivo
Desenhar arvore morta a 64x128px: tronco escuro, galhos sem folhas, textura de madeira velha. Incluir ponto de pouso para o corvo (evento raro visitante). Adiciona atmosfera e variedade visual.

## Ler antes
- docs/visual-identity.md (seccao 3, dimensoes arvore morta 64x128px)
- docs/events-catalogue.md (evento de corvo, se existir)
- game/world/island_map.gd

## Critérios de aceitação
- [ ] `game/assets/sprites/tree_dead.png` a 64x128px; galhos assimetricos, textura de madeira escura com dithering (prova: screenshot docs/proof/T-705-dead-tree.png)
- [ ] Ponto de pouso marcado como `Marker2D` no Node da arvore: coordenadas onde o sprite de corvo e posicionado (prova: grep Marker2D game/world/dead_tree.tscn)
- [ ] AnimationPlayer: `tree_creak` (loop muito lento, 2 frames) para vento (prova: GUT)
- [ ] Posicionada num local fixo da ilha; serve de ponto de referencia visual (prova: screenshot in-game com arvore visivel)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- O corvo em si (evento separado no EventDirector)
- Interaccao do naufrago com a arvore morta (tarefa futura)

## Prova exigida
- Screenshot docs/proof/T-705-dead-tree.png
- Screenshot in-game com arvore no cenario

## Relatório
(preenchido pelo executor)
