---
id: T-710
titulo: Revisao visual Fase 7 -- screenshot panoramico, gauntlet vs SV+GK
fase: 7
estado: pronto
tipo: docs
depende_de: [T-701, T-702, T-703, T-704, T-705, T-706, T-707, T-708, T-709]
---

## Objectivo
Validar toda a Fase 7 visualmente: screenshot panoramico da ilha com todos os assets novos, gauntlet de qualidade comparativo com Stardew Valley e Graveyard Keeper, e actualizacao do CHANGELOG com o redesenho completo.

## Ler antes
- docs/visual-identity.md (seccao 5 criterios de qualidade visual, ADR-013)
- scripts/verify.sh
- CHANGELOG.md

## Critérios de aceitação
- [ ] Screenshot panoramico `docs/proof/T-710-panorama.png` com todos os assets Fase 7: naufrago, palmeiras, arbusto, arvore morta, oceano animado, ceu pintado; screenshot feito em resolucao 1280x720 (prova: ls docs/proof/T-710-panorama.png)
- [ ] Gauntlet de qualidade executado via `scripts/gauntlet.sh` (ou equivalente): comparacao visual descrita em docs/proof/T-710-gauntlet.md com referencias a SV e GK (prova: ls docs/proof/T-710-gauntlet.md)
- [ ] `python3 scripts/check_docs.py --fix` sem erros (prova: output colado no Relatorio)
- [ ] CHANGELOG.md actualizado com entrada "Fase 7: Redesenho Visual Completo" com lista de assets criados
- [ ] `scripts/verify.sh` verde (prova: output colado no Relatorio)
- [ ] docs/visual-identity.md actualizado com nota de conclusao da Fase 7 (prova: grep "Fase 7 concluida" docs/visual-identity.md)

## Fora de âmbito
- Animacoes de jogo em si (Fase 8)
- Publicacao ou distribuicao (T-505)

## Prova exigida
- docs/proof/T-710-panorama.png
- docs/proof/T-710-gauntlet.md
- Output de verify.sh verde

## Relatório
(preenchido pelo executor)
