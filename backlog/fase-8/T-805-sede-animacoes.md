---
id: T-805
titulo: Sprites e animacoes para accoes de sede
fase: 8
estado: pronto
tipo: visual
depende_de: [T-801, T-602]
---

## Objectivo
Criar sprites e animacoes pixel art para as tres accoes de sede: beber agua de coco (A03), recolher agua da chuva (A08), destilar agua do mar (A05). Estilo Stardew Valley / Graveyard Keeper, ~32x48px, contorno preto.

## Ler antes
- docs/visual-identity.md (seccao 1.3 estilo visual, 1.4 dimensoes-alvo, paleta de pele)
- docs/actions-catalogue.md (A03, A05, A08 -- campo "Sprites necessarios" em cada accao)
- game/character/naufrago.tscn (como adicionar AnimationPlayer entries)

## Critérios de aceitação
- [ ] `game/assets/sprites/naufrago_sede.png` com spritesheet contendo: `coconut_crack` (4 frames), `coconut_drink` (3 frames), `coconut_done` (2 frames) -- total 9 frames (prova: screenshot em docs/proof/T-805-coconut.png)
- [ ] `game/assets/sprites/naufrago_chuva.png` com: `mouth_open_sky` (2 frames), `run_urgency` (6 frames) -- total 8 frames (prova: screenshot docs/proof/T-805-chuva.png)
- [ ] `game/assets/sprites/naufrago_destilar.png` com: `crouch_tend` (2 frames loop), `wait_patient` (3 frames) -- total 5 frames (prova: screenshot)
- [ ] Props: `coco_fechado.png`, `coco_aberto.png`, `concha_pedra.png` -- cada um 1 sprite estatico (prova: ls game/assets/sprites/props/)
- [ ] Animacoes adicionadas ao AnimationPlayer do naufrago.tscn e disponiveis por nome (prova: `grep coconut_crack game/character/naufrago.tscn`)
- [ ] Paleta respeita docs/visual-identity.md Fase I (pele `#c8723a`, contorno `#1a0a00`)

## Fora de âmbito
- Sprites de Fase II-V (barba/bronzeado) -- tarefa T-701 e T-702
- Sons (T-504 ou tarefa separada)
- Animacoes de higiene (T-806)

## Prova exigida
- Screenshots de cada spritesheet em docs/proof/T-805-*.png
- AnimationPlayer a reproduzir coconut_drink em loop (video ou GIF no Relatorio)

## Relatório
(preenchido pelo executor)
