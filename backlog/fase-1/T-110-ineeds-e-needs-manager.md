---
id: T-110
titulo: IDirector -- contrato abstracto e NeedsManager com SOLIDAO, TEDIO, ESPERANCA
fase: 1
estado: pronto
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

- [ ] `game/llm/i_director.gd` existe com metodos `get_directive() -> DirectorDirective` e `is_available() -> bool`
- [ ] `DirectorDirective` resource com campos: `arc_id`, `activity`, `tone`, `phrase_context_extra`
- [ ] `NeedsManager` autoload com as 4 necessidades (FOME, SOLIDAO, TEDIO, ESPERANCA) e taxas por defeito
- [ ] SOLIDAO, TEDIO, ESPERANCA tem decay passivo configuravel em `game/data/needs_config.json`
- [ ] Testes GUT: decay ao longo do tempo, interaccoes (FOME alta drena ESPERANCA), thresholds de urgencia
- [ ] Smoke de arranque passa com as 4 necessidades activas

## Fora de âmbito

- Comportamentos disparados pelas novas necessidades (isso e a T-111)
- LLMDirector (T-115)
- Companheiro imaginario (T-118)

## Prova exigida

- Testes GUT: `test_solitude_increases_passively`, `test_boredom_slows_when_hungry`, `test_hope_drains_when_all_needs_high`
- Screenshot do smoke com 4 barras de necessidade visiveis
