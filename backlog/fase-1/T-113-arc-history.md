---
id: T-113
titulo: ArcHistory -- persistencia de arcos com escrita atomica e schema_version
fase: 1
estado: pronto
tipo: codigo
depende_de: [T-111]
---

## Objectivo

Sistema de persistencia de arcos entre sessoes em `user://arc_history.json` com escrita
atomica (write-to-temp + rename), limite de 50 arcos, schema_version e reset gracioso em erro.

## Ler antes

- `docs/narrative-design.md` §4 (Memoria entre sessoes)
- `docs/llm-director.md` §4 (arc_history.json)
- `agent_docs/tech_design.md` §7 (dados em user://)

## Critérios de aceitação

- [ ] `game/world/arc_history.gd` com `class_name ArcHistory`
- [ ] Escrita atomica: escreve para `arc_history.tmp.json`, faz rename so apos `store_string()` completo
- [ ] Campo `"schema_version": 1` no JSON; mismatch de versao loga aviso e reseta para estado vazio
- [ ] Limite: maximo 50 arcos em `completed_arcs`; descarta os mais antigos
- [ ] `get_recent_titles(n: int) -> Array[String]` para contexto do LLM (ultimos n titulos)
- [ ] Erro de parsing: `push_warning()` + retorna estado vazio, nunca crasha
- [ ] Testes GUT: escrita/leitura, limite de 50, schema mismatch, ficheiro corrompido

## Fora de âmbito

- arc_history de arcos gerados pelo LLM (esses usam a mesma estrutura, entra com T-115)
- Outros ficheiros de persistencia (save.json, memory.json -- v1.x)

## Prova exigida

- Teste GUT `test_atomic_write_survives_corruption`: escrever ficheiro corrupto manualmente, confirmar que carrega estado vazio
- Teste GUT `test_max_50_arcs_enforced`
