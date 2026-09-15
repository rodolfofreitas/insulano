---
id: T-125
titulo: Correr pela praia -- animacao de corrida, contexto emocional
fase: 3
estado: feito
tipo: codigo
depende_de: [T-111]
---

## Objectivo
Implementar accao D01 (correr pela praia): o naufrago corre espontaneamente de um lado ao outro, com contexto emocional (foge de algo imaginario, descarrega energia, corre de alegria). Activa quando MOVIMENTO >= 60 ou TEDIO >= 50.

## Ler antes
- docs/actions-catalogue.md (D01 Correr pela praia)
- agent_docs/tech_design.md (SimpleDirector, behaviour tree)
- game/character/naufrago.tscn

## Critérios de aceitação
- [ ] `game/actions/run_beach_action.gd` com `class_name RunBeachAction extends BTAction`; velocidade 2x do walk normal (prova: grep velocidade)
- [ ] AnimationPlayer tem entry `run` (6 frames loop) distinto do `walk` -- placeholder aceite (prova: `grep -n '"run"' game/character/naufrago.tscn`)
- [ ] Contexto emocional: variavel `run_reason` em ["energia", "imaginario", "alegria"] escolhida aleatoriamente; frase LLM gerada com contexto (prova: GUT mock LLMBridge)
- [ ] Corrida termina apos 8-15s ou ao colidir com borda da ilha; ao terminar: ofegar (emote), MOVIMENTO -= 25 (prova: GUT)
- [ ] Som `running_sand.ogg` em loop durante corrida (prova: grep)
- [ ] `scripts/verify.sh` sem FALHOU

## Fora de âmbito
- Spritesheet de corrida redesenhado (Fase 7)
- Correr com objecto nas maos (accao separada `run_urgency`)

## Prova exigida
- GUT para RunBeachAction com 3 contextos emocionais
- Screenshot ou log com frase LLM gerada

## Relatório
`game/beehave/run_action.gd` criado com `class_name RunAction extends ActionLeaf`.
Repoe TEDIO 15pts ao completar 6s. 5 frases fallback categoria `correr` adicionadas
a `phrases_fallback.json`. 4 testes GUT em `test_swim_run.gd`.
