---
id: T-701
titulo: Sprite base do naufrago redesenhado -- 32x48px, 5 fases barba/cabelo
fase: 7
estado: pronto
tipo: visual
depende_de: [T-610]
---

## Objectivo
Redesenhar o sprite base do naufrago de raiz a ~32x48px, estilo Stardew Valley / Graveyard Keeper. Criar 5 variantes de fase (crescimento de barba e cabelo ao longo do tempo). Substituir o sprite actual de 16x24px upscalado.

## Ler antes
- docs/visual-identity.md (seccao 2, 2a fases I-V, paletas de pele e cabelo, proporcoes 1:2 a 1:2.5)
- docs/visual-identity.md (seccao 1.3 estilo visual, 1.4 dimensoes-alvo)
- docs/decisions.md (ADR-013 -- nova direccao visual)
- game/character/naufrago.tscn (AnimationPlayer, como substituir spritesheet)

## Critérios de aceitação
- [ ] `game/assets/sprites/naufrago_fase1.png` criado a 32x48px por frame; spritesheet com animacoes base: idle (4 frames), walk (4 frames), sit (2 frames) (prova: screenshot docs/proof/T-701-fase1.png com escala x4 para visualizacao)
- [ ] Cinco fases criadas: naufrago_fase1.png ate naufrago_fase5.png; diferenca visual de barba e cabelo visivel entre cada fase (prova: screenshots comparativos em docs/proof/T-701-fases-comparativo.png)
- [ ] Paleta Fase I respeita docs/visual-identity.md: pele `#c8723a`, sombra `#7a3510`, contorno `#1a0a00` (prova: `python3 scripts/check_docs.py --fix` valida paleta)
- [ ] Ratio cabeca/corpo entre 1:2 e 1:2.5; silhueta legivel a 32x48 e a 8x12 (miniatura) (prova: screenshot comparativo de tamanhos)
- [ ] AnimationPlayer em naufrago.tscn actualizado para usar naufrago_fase1.png como novo default; script de selecao de fase carrega a variante correcta com base em `days_survived` (prova: grep days_survived game/character/naufrago.gd)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Variacoes sazonais (bronzeado, neve) -- ver T-702
- Animacoes novas alem das base (ver T-709)
- Sombra de arvore ou elementos de fundo

## Prova exigida
- Screenshots de todas as 5 fases em docs/proof/T-701-*.png
- Screenshot in-game com sprite novo a animar

## Relatório
(preenchido pelo executor)
