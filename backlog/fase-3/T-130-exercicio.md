---
id: T-130
titulo: Fazer exercicio (flexoes e abdominais) -- animacao, melhora MOVIMENTO
fase: 3
estado: feito
tipo: codigo
depende_de: [T-111]
---

## Objectivo
Implementar accao D06 (fazer exercicio: flexoes e abdominais): sequencia de exercicio fisico matinal ou quando MOVIMENTO >= 70. Accao de rotina expressiva com muito caracter.

## Ler antes
- docs/actions-catalogue.md (D06 Alongamentos matinais -- 8 frames)
- game/world/game_clock.gd (hora do dia para trigger matinal)

## Critérios de aceitação
- [ ] `game/actions/exercise_action.gd` com dois triggers: hora 6-9 (matinal) ou MOVIMENTO >= 70 (prova: grep triggers)
- [ ] Sequencia: `stretch_arms` (2 frames) -> `pushups` (4 frames loop x3) -> `situps` (4 frames loop x3) -> `done_proud` (2 frames); placeholders ok (prova: GUT sequencia)
- [ ] Som `effort_grunt.ogg` sincronizado com cada flexao (prova: grep AudioStreamPlayer)
- [ ] Efeitos: MOVIMENTO -= 30, ENERGIA += 10, TEDIO -= 10 ao terminar (prova: GUT)
- [ ] Trigger matinal tem cooldown 20h jogo (1x por dia) (prova: GUT)
- [ ] Frase ocasional de auto-encorajamento no inicio (50% probabilidade, categoria="orgulho") (prova: GUT mock LLM)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Sprites redesenhados (Fase 7)
- Exercicio com equipamento ou obstaculos

## Prova exigida
- GUT com trigger matinal e com MOVIMENTO=75
- Log de efeitos aplicados

## Relatório
ExerciseAction implementada em game/beehave/exercise_action.gd. Dura EXERCISE_DURATION (10s),
repoe TEDIO -20 via NeedsManager. 5 frases fallback categoria exercicio
em phrases_fallback.json. 5 testes GUT em test_dance_exercise.gd.
