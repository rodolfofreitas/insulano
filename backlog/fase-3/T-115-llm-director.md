---
id: T-115
titulo: LLMDirector -- director narrativo via Ollama com 1 chamada por ciclo (JSON estruturado)
fase: 3
estado: pronto
tipo: codigo
depende_de: [T-111, T-113, T-114, T-105]
---

## Objectivo

Implementar `LLMDirector` que substitui o `SimpleDirector` via contrato `IDirector`.
Uma unica chamada ao Ollama por ciclo devolve JSON com arco+actividade+frase.
O ciclo e event-driven (fim de actividade, threshold de necessidade, inicio de sessao).

## Ler antes

- `docs/llm-director.md` -- arquitectura completa do loop
- `agent_docs/tech_design.md` §4 (LLMBridge)
- `docs/needs-system.md` -- contexto para o LLM

## Critérios de aceitação

- [ ] `game/llm/llm_director.gd` satisfaz `IDirector` (mesma interface do SimpleDirector)
- [ ] Uma unica chamada por ciclo: prompt com estado completo, resposta JSON `{arc, activity, phrase}`
- [ ] Ciclo event-driven: dispara em `activity_completed`, `need_threshold_crossed`, `session_start`
- [ ] Contexto enviado: dia, hora, estacao, 4 necessidades, arco activo, 5 arcos recentes (so titulos), companheiro, ultimo evento
- [ ] Validacao do JSON recebido; fallback para SimpleDirector em qualquer erro de parsing ou timeout
- [ ] Memoria de decisoes: guarda ultimas 10 decisoes em `user://director_memory.json` (atomico)
- [ ] Testes GUT: mock HTTP com response valida, mock com garbage, mock com timeout, validacao de schema

## Fora de âmbito

- Geracao de arcos novos pelo LLM (T-117)
- Companheiro imaginario (T-118)

## Prova exigida

- `verify.sh --llm`: eval com LLMDirector activo, 10 ciclos, JSON valido em todos
- Log com latencia por ciclo (deve ser p50 < 5s com 1 chamada)
