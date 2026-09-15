---
id: T-301
titulo: EventDirector que agenda eventos aleatórios com seed
fase: 3
estado: feito
tipo: codigo
depende_de: [T-201]
---

## Objectivo
Um único director decide quando acontecem eventos (gaivota, barco, e os que vierem), com pesos e intervalos configuráveis em dados e resultados reprodutíveis quando se fixa a seed.

## Ler antes
- agent_docs/tech_design.md (secção EventDirector)
- agent_docs/code_patterns.md (sinais entre camadas, dados em game/data)
- game/world/game_clock.gd (T-201)

## Critérios de aceitação
- [x] Existe `game/events/event_director.gd` com `class_name EventDirector`, registado como autoload `Events` (prova: `grep -n 'Events=' game/project.godot`).
- [x] Sinais exactos: `signal event_started(kind: String, data: Dictionary)` e `signal event_finished(kind: String)` (prova: teste GUT que os escuta com `watch_signals`).
- [x] Configuração lida de `game/data/events.json` com, por evento, `kind`, `weight`, `min_interval_s`, `duration_s`; o ficheiro traz pelo menos `seagull` e `boat` (prova: `python3 scripts/check_docs.py` valida o JSON; teste GUT carrega-o).
- [x] A seed vem do setting `insulano/events/seed` (0 significa aleatória); com a mesma seed e o mesmo tempo simulado, a sequência de eventos é idêntica em duas corridas (prova: `game/tests/unit/test_event_director.gd`, avançando o tempo por uma função pública de tick, sem esperar tempo real).
- [x] Nunca há dois eventos do mesmo `kind` activos em simultâneo e `min_interval_s` é respeitado (prova: GUT com 1 hora simulada).
- [x] `events.json` em falta ou inválido: o director fica inactivo, regista `push_warning` e o jogo arranca (prova: GUT).
- [x] `scripts/verify.sh` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido; CHANGELOG em [Não lançado].

## Fora de âmbito
- Qualquer visual dos eventos (T-302, T-303).
- Eventos dependentes do clima (T-305).

## Prova exigida
- Output dos testes GUT novos e a sequência de eventos de uma corrida com seed fixa colada no Relatório.

## Relatório

`verify.sh` PASSOU (125 testes, 125 passaram).

GUT tests: `test_signals_watched`, `test_same_seed_same_sequence`, `test_no_simultaneous_same_kind`, `test_min_interval_respected`, `test_missing_config_inactive` -- todos PASSOU.

Ficheiros criados/modificados:
- `game/events/event_director.gd` -- class_name EventDirector, autoload Events
- `game/tests/unit/test_event_director.gd` -- 5 testes GUT
- `game/project.godot` -- autoload Events + setting insulano/events/seed=0
- `CHANGELOG.md` -- entrada em [Nao lancado]
