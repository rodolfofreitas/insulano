---
id: T-124
titulo: Nadar livremente -- animacao de natacao, splash, estado a nadar
fase: 3
estado: pronto
tipo: codigo
depende_de: [T-111, T-304]
---

## Objectivo
Implementar accao D02 (nadar livremente): o naufrago entra no oceano, nada com animacao horizontal unica, cria CPUParticles2D splash, e sai apos duracao aleatoria. Activa quando MOVIMENTO >= 50 ou CALOR >= 60.

## Ler antes
- docs/actions-catalogue.md (D02 Nadar livremente -- sprites, Godot, notas)
- agent_docs/tech_design.md (camadas, beehave, CPUParticles2D)
- game/character/naufrago.tscn (AnimationPlayer existente)

## Critérios de aceitação
- [ ] `game/actions/swim_action.gd` criado com `class_name SwimAction extends BTAction`; condicao de entrada: beira do oceano (Area2D) + (MOVIMENTO >= 50 ou CALOR >= 60) (prova: grep)
- [ ] AnimationPlayer tem entry `swim_cycle` (6 frames loop, horizontal) -- sprite placeholder aceite se F7 ainda nao feito (prova: `grep swim_cycle game/character/naufrago.tscn`)
- [ ] CPUParticles2D `swim_splash` activado durante accao; desactivado ao sair (prova: GUT ou screenshot docs/proof/T-124-swim.png)
- [ ] Estado "a nadar" visivel: naufrago fica parcialmente na agua (Y-offset), Z-index abaixo das ondas (prova: screenshot in-game)
- [ ] Duracao 15-30s de jogo, aleatoria; ao sair: MOVIMENTO -= 30, CALOR -= 20 (se activo) (prova: GUT com duracao mockada)
- [ ] Som `swimming.ogg` em loop durante accao (placeholder ok); para ao sair (prova: grep AudioStreamPlayer)
- [ ] `scripts/verify.sh` sem FALHOU; CHANGELOG actualizado

## Fora de âmbito
- Sprites redesenhados (Fase 7 T-701)
- Fisica de agua real ou colisao com fundo do mar
- Nadar como escape (FUGA -- accao separada)

## Prova exigida
- Screenshot em docs/proof/T-124-swim.png mostrando naufrago na agua com splash
- GUT test para SwimAction com condicoes de entrada e saida

## Relatório
(preenchido pelo executor)
