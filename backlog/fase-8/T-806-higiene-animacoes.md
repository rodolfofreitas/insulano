---
id: T-806
titulo: Sprites e animacoes para accoes de higiene
fase: 8
estado: pronto
tipo: visual
depende_de: [T-802, T-602]
---

## Objectivo
Criar sprites e animacoes pixel art para as accoes de higiene: tomar banho no mar (B01), lavar maos (B02), fazer xixi atras da palmeira (B03). Estilo Stardew Valley / Graveyard Keeper, ~32x48px.

## Ler antes
- docs/visual-identity.md (seccao 1.3, paleta)
- docs/actions-catalogue.md (B01, B02, B03 -- campo "Sprites necessarios")
- game/character/naufrago.tscn

## Critérios de aceitação
- [ ] `game/assets/sprites/naufrago_banho.png`: `wade_in` (4 frames entrar na agua), `splash_bath` (4 frames a esfregar), `wade_out` (3 frames sair satisfeito) -- total 11 frames (prova: screenshot docs/proof/T-806-banho.png)
- [ ] `game/assets/sprites/naufrago_lavar_maos.png`: `crouch_water` (2 frames), `wash_hands` (3 frames), `shake_dry` (2 frames) -- total 7 frames (prova: screenshot)
- [ ] `game/assets/sprites/naufrago_xixi.png`: `walk_behind_tree` (adaptacao do walk existente), `behind_tree_idle` (2 frames, corpo parcialmente oculto), `relief_sigh` (2 frames ao sair) -- total variavel (prova: screenshot docs/proof/T-806-xixi.png)
- [ ] Emote de nuvem fedorenta: `emote_stink.png` sprite separado 16x16px (prova: ls game/assets/sprites/emotes/)
- [ ] Animacoes adicionadas ao AnimationPlayer; `behind_tree_idle` usa oclusao por arvore (Z-index correcto) (prova: GUT visual ou screenshot in-game)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Sons de agua e alivio (T-504)
- Shader de sujidade acumulada (Fase 7)
- Sprites para destilar agua ou sede (T-805)

## Prova exigida
- Screenshots em docs/proof/T-806-*.png
- Screenshot in-game mostrando oclusao correcta atras da palmeira

## Relatório
(preenchido pelo executor)
