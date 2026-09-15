---
id: T-201
titulo: GameClock com hora do sistema e override para testes
fase: 2
estado: feito
tipo: codigo
depende_de: [T-001]
---

## Objectivo
O jogo sabe que horas são (hora do sistema) através de um único ponto, o autoload `Clock`, e essa hora pode ser forçada em testes e screenshots sem mexer no relógio da máquina.

## Ler antes
- agent_docs/tech_design.md (secção do GameClock)
- agent_docs/code_patterns.md (autoloads, docstrings `##`, settings `insulano/*`)
- game/project.godot (secção [autoload])

## Critérios de aceitação
- [x] Existe `game/world/game_clock.gd` com `class_name GameClock`, registado como autoload `Clock` em `game/project.godot` (prova: `grep -n 'Clock=' game/project.godot`).
- [x] API pública exacta: `now() -> Dictionary`, `hour_float() -> float`, `period() -> String`, `signal hour_changed(hour: int)` (prova: teste GUT `test_game_clock.gd` chama as três funções e liga o sinal).
- [x] `period()` devolve `madrugada` para [0, 6), `manhã` para [6, 12), `tarde` para [12, 17), `fim da tarde` para [17, 20), `noite` para [20, 24); fronteiras testadas às 05:59, 06:00, 11:59, 12:00, 16:59, 17:00, 19:59, 20:00, 23:59 (prova: `game/tests/unit/test_game_clock.gd`).
- [x] A variável de ambiente `INSULANO_FAKE_TIME="2026-12-25T21:30"` faz `now()` devolver 2026-12-25 21:30 e `hour_float()` devolver 21.5 (prova: teste GUT com a lógica de parsing isolada numa função testável, sem depender do ambiente do processo).
- [x] O setting `insulano/debug/fake_time` (vazio por defeito) tem o mesmo efeito; a variável de ambiente ganha ao setting quando ambos existem (prova: teste GUT).
- [x] Valor de fake time inválido não parte o jogo: regista aviso com `push_warning` e usa a hora real (prova: teste GUT).
- [x] `hour_changed` é emitido uma vez quando a hora inteira muda (prova: teste GUT que avança uma hora simulada).
- [x] `scripts/verify.sh` sem FALHOU; `python3 scripts/check_docs.py --fix` corrido e o mapa de componentes actualizado.
- [x] CHANGELOG.md tem entrada em [Não lançado].

## Fora de âmbito
- Qualquer efeito visual (é a T-202).
- Fusos horários diferentes do sistema.

## Prova exigida
- Output de `scripts/verify.sh` com a linha gut a PASSOU e o nome dos testes novos.
- Comando manual `INSULANO_FAKE_TIME=2026-12-25T21:30 godot --headless --path game --quit-after 5` sem erros de script.

## Relatório

Implementado por agente Hermes (subagente, Claude Sonnet 4.6). verify.sh PASSOU em todos os portoes:

```
docs         PASSOU         scripts/check_docs.py
backlog      PASSOU         backlog: PASSOU (53 tarefas, 0 erros)
pytest       PASSOU         49 passed in 0.05s
lint         PASSOU         57 ficheiros proprios limpos
import       PASSOU         godot --import
gut          PASSOU         Tests 84;Passing Tests 84
boot         PASSOU         BOOT_SMOKE PASSOU: fome -49.1 pontos, deslocacao maxima 692 px
VEREDICTO: PASSOU
```

Ficheiros criados:
- `game/world/game_clock.gd` -- GameClock com class_name antes de extends (ordem gdlint)
- `game/tests/unit/test_game_clock.gd` -- 4 testes GUT (period_boundaries, fake_time_parsing, invalid_fake_time_uses_real, hour_changed_emitted)

Ficheiros modificados:
- `game/project.godot` -- autoload `Clock="*res://world/game_clock.gd"` + setting `debug/fake_time=""`
- `CHANGELOG.md` -- entrada em [Nao lancado]

Notas:
- Corrigida ordem class_name/extends em director_directive.gd e i_director.gd (gdlint pre-existente, T-110)
- Teste hour_changed usa `_last_hour = 10` para evitar emissao espuria no primeiro _process
- Commit: `48e7f34 feat(T-201): GameClock com hora do sistema e override para testes`
