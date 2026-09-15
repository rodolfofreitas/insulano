---
id: T-127
titulo: Saltar de arvore para o mar -- animacao complexa, splash, frase
fase: 3
estado: pronto
tipo: codigo
depende_de: [T-111, T-703]
---

## Objectivo
Implementar accao D03 (saltar de arvore para o mar): o naufrago sobe pela palmeira inclinada, prepara o salto, salta para a agua com grande splash CPUParticles2D, emite frase de exaltacao. Accao rara e espetacular.

## Ler antes
- docs/actions-catalogue.md (D03 Saltar de arvore para o mar -- 15 frames)
- docs/visual-identity.md (T-706 palmeira inclinada, "lugar favorito")
- game/character/naufrago.tscn
- game/world/island_map.gd (posicao da palmeira inclinada)

## Critérios de aceitação
- [ ] `game/actions/tree_jump_action.gd` com raridade RARO (max 1x/dia jogo); condicao: palmeira inclinada (T-706) existe na cena (prova: grep raridade)
- [ ] Sequencia: `walk_to_tree` -> `climb_tree` (4 frames) -> `prepare_jump` (3 frames) -> `jump_arc` (5 frames) -> `splash_land` (3 frames); placeholders ok (prova: GUT que avanca sequencia completa)
- [ ] CPUParticles2D `big_splash` activado no frame `splash_land`: particulas em arco, duracao 1.5s (prova: screenshot docs/proof/T-127-splash.png)
- [ ] Som `big_splash.ogg` no momento do impacto (prova: grep)
- [ ] Frase LLM com categoria="exaltacao" gerada apos aterrar (prova: GUT mock LLM)
- [ ] MOVIMENTO -= 50, TEDIO -= 30, ESPERANCA += 10 apos accao (prova: GUT)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Sprites de subida de arvore redesenhados (Fase 7)
- Palmeira inclinada como objecto (T-706 em Fase 7)

## Prova exigida
- GUT para sequencia completa de 15 frames
- Screenshot do splash em docs/proof/T-127-splash.png

## Relatório
(preenchido pelo executor)
