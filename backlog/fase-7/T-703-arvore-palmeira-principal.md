---
id: T-703
titulo: Palmeira principal -- 128px com cocos, sombra dinamica
fase: 7
estado: pronto
tipo: visual
depende_de: [T-610]
---

## Objectivo
Desenhar a palmeira principal da ilha a 128x192px: tronco com textura de fibra, folhas com gradiente, cocos visiveis, sombra dinamica que muda com a hora do dia. Substituir o asset actual de palmeira.

## Ler antes
- docs/visual-identity.md (seccao 3 Palmeiras e Arvores, dimensoes-alvo 128x192px)
- docs/visual-identity.md (seccao 1.1 -- palmeira com textura do Johnny Castaway como referencia)
- game/world/island_map.gd (como a palmeira e posicionada)
- game/world/game_clock.gd (hora para sombra)

## Critérios de aceitação
- [ ] `game/assets/sprites/tree_palm_main.png` a 128x192px; tronco com linhas de fibra em dithering; folhas com gradiente interno verde-escuro/verde-claro (prova: screenshot docs/proof/T-703-palm.png com zoom x2)
- [ ] 3 estados de cocos: `cocos_3.png`, `cocos_2.png`, `cocos_1.png`, `cocos_0.png` -- sub-sprites compostos sobre o tronco (prova: ls game/assets/sprites/tree_palm_main_cocos*.png)
- [ ] Sombra dinamica: sprite de sombra eliptica que muda de angulo/comprimento com a hora (madrugada = longa, meio-dia = curta); implementado via shader ou AnimationPlayer de sombra (prova: screenshot sombra ao meio-dia vs manha)
- [ ] AnimationPlayer: `palm_sway` (loop suave, 4 frames); vento forte aumenta amplitude (prova: GUT com WeatherService.wind)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Cocos como inventario (T-126)
- Palmeira inclinada (T-706)
- Arbusto e arvore morta (T-704, T-705)

## Prova exigida
- Screenshots: sombra da palmeira de manha vs meio-dia em docs/proof/T-703-sombra-*.png
- Screenshot dos 4 estados de cocos

## Relatório
(preenchido pelo executor)
