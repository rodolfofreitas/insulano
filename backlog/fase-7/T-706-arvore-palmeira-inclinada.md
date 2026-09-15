---
id: T-706
titulo: Palmeira inclinada -- 80px, lugar favorito do naufrago
fase: 7
estado: pronto
tipo: visual
depende_de: [T-703]
---

## Objectivo
Desenhar palmeira inclinada a 80x128px, inclinada sobre o oceano. E o "lugar favorito" do naufrago: ele usa-a para contemplar o horizonte, descansar, e como plataforma para saltar para o mar (T-127). Visual unico e iconica.

## Ler antes
- docs/visual-identity.md (seccao 3, palmeira inclinada 80x128px, "lugar favorito")
- docs/visual-identity.md (gjhot.bmp referencia Johnny a descansar na palmeira)
- game/world/island_map.gd (posicao junto ao oceano)

## Critérios de aceitação
- [ ] `game/assets/sprites/tree_palm_lean.png` a 80x128px; inclinada ~30-45 graus sobre a agua; tronco curvado naturalmente (prova: screenshot docs/proof/T-706-lean-palm.png)
- [ ] Ponto de descanso marcado como `Marker2D` onde o naufrago fica sentado/deitado quando usa esta palmeira (prova: grep Marker2D game/world/lean_palm.tscn)
- [ ] Ponto de salto marcado como `Marker2D` para T-127 (saltar de arvore para o mar) (prova: grep jump_point game/world/lean_palm.tscn)
- [ ] AnimationPlayer: `palm_lean_sway` (4 frames loop, amplitude maior que palmeira direita) (prova: GUT)
- [ ] Palmeira posicionada na borda da ilha sobre o oceano; colisao com o solo configur correctamente (prova: screenshot in-game)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Accao de saltar da palmeira (T-127 -- depende desta tarefa)
- Cocos nesta palmeira (usa o sistema de T-703)

## Prova exigida
- Screenshot docs/proof/T-706-lean-palm.png
- Screenshot in-game com naufrago sentado no ponto de descanso

## Relatório
(preenchido pelo executor)
