---
id: T-709
titulo: Animacoes novas -- apanhar lenha, acender fogueira, assar, companheiro
fase: 7
estado: pronto
tipo: visual
depende_de: [T-701, T-119]
---

## Objectivo
Criar as animacoes detalhadas para as accoes de sobrevivencia criticas que actualmente usam placeholders: apanhar lenha (A10), acender fogueira (A09), assar peixe (A02), interagir com companheiro (T-118). Estilo Stardew Valley / Graveyard Keeper a 32x48px.

## Ler antes
- docs/actions-catalogue.md (A10 recolher lenha, A09 acender fogueira, A02 comer peixe assado -- campo "Sprites necessarios")
- docs/visual-identity.md (seccao 2, proporcoes, paleta)
- game/character/naufrago.tscn (AnimationPlayer)
- game/objects/campfire.tscn (T-119)

## Critérios de aceitação
- [ ] `game/assets/sprites/naufrago_fogueira.png`: `rub_sticks` (4 frames), `blow_fire` (3 frames), `fire_success` (3 frames); contorno `#1a0a00`, paleta fase-correcta (prova: screenshot docs/proof/T-709-fogueira.png)
- [ ] `game/assets/sprites/naufrago_lenha.png`: `pick_up` (3 frames reutilizavel); variante `carry_wood` (walk com lenha nos bracos, 4 frames) (prova: screenshot docs/proof/T-709-lenha.png)
- [ ] `game/assets/sprites/naufrago_comer.png`: `eat_sit` (2 frames), `eat_chew` (4 frames loop), `eat_done` (2 frames) (prova: screenshot docs/proof/T-709-comer.png)
- [ ] `game/assets/sprites/naufrago_companheiro.png`: `talk_companion` (4 frames), `hug_companion` (4 frames), `present_companion` (3 frames) (prova: screenshot docs/proof/T-709-companheiro.png)
- [ ] Todas as animacoes adicionadas ao AnimationPlayer de naufrago.tscn e nomeadas de acordo com o catalogo (prova: `grep rub_sticks game/character/naufrago.tscn`)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Animacoes de sede e higiene (T-805, T-806)
- Redesenho do sprite base (T-701)

## Prova exigida
- Screenshots de cada spritesheet em docs/proof/T-709-*.png
- Screenshot in-game de acender fogueira com nova animacao

## Relatório
(preenchido pelo executor)
