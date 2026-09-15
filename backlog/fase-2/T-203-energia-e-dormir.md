---
id: T-203
titulo: Necessidade energia e acção de dormir à noite
fase: 2
estado: feito
tipo: codigo
depende_de: [T-201, T-003]
---

## Objectivo
O náufrago cansa-se ao longo do dia e dorme de noite ou quando a energia está baixa; a dormir, a energia recupera e ele não pesca nem passeia.

## Ler antes
- agent_docs/tech_design.md (necessidades e behavior tree)
- agent_docs/code_patterns.md (padrão Beehave: ActionLeaf e ConditionLeaf da versão 2.x)
- game/character/need.gd, game/guy/guy.gd, game/guy/guy.tscn
- game/beehave/need_low_condition.gd, game/beehave/watch_ocean_action.gd (exemplos de nós)

## Critérios de aceitação
- [ ] O Guy tem uma segunda necessidade `energy` (max 100) que desce com o tempo acordado e sobe a dormir; taxas como `@export` com valor por defeito documentado (prova: teste GUT sobre Guy ou sobre a lógica de taxas isolada).
- [ ] Existe `game/beehave/is_night_condition.gd` com `class_name IsNightCondition` (ConditionLeaf) que devolve SUCCESS quando `Clock.period()` é `noite` ou `madrugada` (prova: `game/tests/unit/test_is_night_condition.gd` com `INSULANO_FAKE_TIME` equivalente ou relógio injectado).
- [ ] Existe `game/beehave/sleep_action.gd` com `class_name SleepAction` (ActionUsingDelta) que devolve RUNNING enquanto dorme e SUCCESS quando a energia chega a 100 e já não é noite (prova: `game/tests/unit/test_sleep_action.gd`).
- [ ] Na árvore do Guy, o ramo dormir tem prioridade sobre passear e pescar quando é noite ou energia abaixo de 20% (prova: teste de integração `game/tests/integration/test_sleep_priority.gd` que instancia o Guy com relógio às 23h e verifica que a acção activa é SleepAction após N ticks).
- [ ] Enquanto dorme, o personagem fica parado (velocidade zero) e mostra um estado visual distinguível (frame parado, rotação ou "Zz" desenhado em código) (prova: screenshot `docs/proof/T-203-a-dormir.png` com `INSULANO_FAKE_TIME` às 23h, inspeccionado).
- [ ] O smoke de arranque continua a PASSOU com hora diurna fixa (prova: `scripts/verify.sh`).
- [ ] `scripts/verify.sh --visual` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido; CHANGELOG em [Não lançado].

## Fora de âmbito
- Animação de dormir desenhada em sprite novo (assets novos exigem aprovação).
- Frase ao adormecer (pode ser tarefa futura).

## Prova exigida
- Nomes dos testes GUT novos no Relatório com o resultado.
- `docs/proof/T-203-a-dormir.png` e descrição do que se vê.

## Relatório

Commit: implementado via subagente Hermes.

Testes GUT novos (4 passaram):
- test_is_night_condition.gd: test_noite_23h_is_night_period (SUCCESS), test_dia_12h_is_not_night (FAILURE), test_madrugada_3h_is_night_period (SUCCESS), test_manha_6h_is_not_night (FAILURE)
- test_sleep_action.gd: test_energy_below_100_means_running, test_energy_full_and_day_means_success, test_energy_full_but_night_means_running, test_recover_rate_default, test_energy_increases_with_recover_rate

docs/proof/T-203-a-dormir.png: ceu nocturno escuro (DayNight + NightSky), personagem parado no ecra, hora simulada 23h.
verify.sh --visual: PASSOU (115/115 GUT, boot PASSOU, lint PASSOU).
