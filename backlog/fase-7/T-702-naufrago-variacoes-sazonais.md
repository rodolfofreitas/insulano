---
id: T-702
titulo: Variacoes sazonais do naufrago -- bronzeado verao, neve barba inverno
fase: 7
estado: pronto
tipo: visual
depende_de: [T-701, T-202]
---

## Objectivo
Criar variacoes sazonais do sprite do naufrago baseadas na estacao actual: bronzeado progressivo no verao, barba com neve/geada no inverno, tom mais palido no outono/inverno. O seletor de aparencia combina fase + estacao.

## Ler antes
- docs/visual-identity.md (seccao 2b variacoes sazonais, paletas por estacao)
- game/character/naufrago.gd (selector de fase actual)
- game/world/game_clock.gd (current_season)

## Critérios de aceitação
- [ ] Para cada estacao, variante de paleta de pele diferente: verao (bronzeado +15% saturacao), inverno (palido -10% brilho), primavera/outono (neutro base) (prova: screenshots docs/proof/T-702-estacoes.png)
- [ ] Variante inverno: partias de neve/geada na barba (pixels brancos `#f0f8ff` nas fases III-V apenas) (prova: screenshot T-702-inverno-barba.png)
- [ ] `game/character/appearance_selector.gd` actualizado para combinar `fase + current_season` -> spritesheet correcto (prova: GUT com 4 estacoes x 5 fases = 20 combinacoes verificadas por spot check de 8)
- [ ] Transicao de estacao e suave: sem pop visual brusco (fade 5s) (prova: screenshot antes/depois)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Variacoes por hora do dia (shader de iluminacao -- T-708)
- Animacoes especificas de estacao

## Prova exigida
- Screenshots das 4 estacoes para fase III em docs/proof/T-702-*.png

## Relatório
(preenchido pelo executor)
