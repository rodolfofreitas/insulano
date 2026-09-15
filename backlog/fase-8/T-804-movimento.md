---
id: T-804
titulo: Necessidade MOVIMENTO -- correr, nadar, saltar, danca
fase: 8
estado: pronto
tipo: codigo
depende_de: [T-110]
---

## Objectivo
Implementar a necessidade MOVIMENTO: range 0-100 (100 = inactividade maxima), sobe com idle prolongado, desce com accoes fisicas (correr, nadar, saltar, dancar). Cria incentivo autonomo para o naufrago ser activo em vez de estar parado.

## Ler antes
- docs/needs-system.md
- docs/actions-catalogue.md (D01 correr, D02 nadar, D07 dancar, D06 alongamentos)
- game/core/needs_manager.gd

## Critérios de aceitação
- [ ] `game/core/needs/movement_need.gd` com `class_name MovementNeed extends INeed`, range 0-100 (inactividade), sobe +0.3/s em idle, desce durante accoes fisicas (prova: grep + GUT 60s idle)
- [ ] Correr na praia (D01): MOVIMENTO -= 25, duracao 10s de jogo (prova: GUT)
- [ ] Nadar (D02): MOVIMENTO -= 30, CALOR -= 20 (se activo); requer estar na beira do oceano (prova: GUT)
- [ ] Dancar (D07): MOVIMENTO -= 35, SOLIDAO -= 10, TEDIO -= 20; trigger automatico quando ESPERANCA >= 80 (prova: GUT com ESPERANCA=85)
- [ ] Alongamentos matinais (D06): MOVIMENTO -= 20, ENERGIA += 10; trigger automatico ao acordar (hora 6-8) (prova: GUT)
- [ ] Crise (MOVIMENTO >= 85): naufrago parte em corrida espontanea pela praia, frase expressiva sobre precisar de se mexer (prova: GUT)
- [ ] `scripts/verify.sh` sem FALHOU; CHANGELOG actualizado

## Fora de âmbito
- Sprites e animacoes de corrida/nado (ver T-124, T-125 em fase-3)
- Fisicas de colisao ao nadar (sistema de agua separado)

## Prova exigida
- GUT tests para MovementNeed
- Log do trigger automatico de danca com ESPERANCA >= 80

## Relatório
(preenchido pelo executor)
