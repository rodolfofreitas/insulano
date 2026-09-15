---
id: T-110
titulo: IDirector -- contrato abstracto e NeedsManager com SOLIDAO, TEDIO, ESPERANCA
fase: 1
estado: feito
tipo: codigo
depende_de: [T-105]
---

## Objectivo

Definir o contrato `IDirector` que tanto o `SimpleDirector` (deterministico) como o `LLMDirector`
satisfazem, e adicionar as tres novas necessidades ao personagem sem quebrar a fome existente.

## Ler antes

- `docs/needs-system.md` -- valores, taxas, interaccoes
- `docs/llm-director.md` -- contrato IDirector
- `agent_docs/tech_design.md` §4 -- estrutura de Need

## Critérios de aceitação

- [x] `game/llm/i_director.gd` existe com metodos `get_directive() -> DirectorDirective` e `is_available() -> bool`
- [x] `DirectorDirective` resource com campos: `arc_id`, `activity`, `tone`, `phrase_context_extra`
- [x] `NeedsManager` autoload com as 4 necessidades (FOME, SOLIDAO, TEDIO, ESPERANCA) e taxas por defeito
- [x] SOLIDAO, TEDIO, ESPERANCA tem decay passivo configuravel em `game/data/needs_config.json`
- [x] Testes GUT: decay ao longo do tempo, interaccoes (FOME alta drena ESPERANCA), thresholds de urgencia
- [x] Smoke de arranque passa com as 4 necessidades activas

## Fora de âmbito

- Comportamentos disparados pelas novas necessidades (isso e a T-111)
- LLMDirector (T-115)
- Companheiro imaginario (T-118)

## Prova exigida

- Testes GUT: `test_solitude_increases_passively`, `test_boredom_slows_when_hungry`, `test_hope_drains_when_all_needs_high`
- Screenshot do smoke com 4 barras de necessidade visiveis

## Relatório

Implementado por agente Hermes. verify.sh PASSOU em todos os portoes:
- docs, backlog, pytest, lint, import, gut (84/84 testes), boot.
- Ficheiros criados: `game/llm/i_director.gd`, `game/llm/director_directive.gd`,
  `game/world/needs_manager.gd`, `game/data/needs_config.json`,
  `game/tests/unit/test_needs_manager.gd`.
- NeedsManager adicionado ao autoload em `game/project.godot`.
- Taxas lidas de `needs_config.json`; sem valores hard-coded.
- 4 testes GUT aprovados: decay passivo, TEDIO com fome, dreno de ESPERANCA, snapshot.
