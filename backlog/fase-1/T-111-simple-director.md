---
id: T-111
titulo: SimpleDirector -- director deterministico sem LLM com maquina de estados de arcos
fase: 1
estado: pronto
tipo: codigo
depende_de: [T-110]
---

## Objectivo

Implementar `SimpleDirector` que satisfaz `IDirector` com uma maquina de estados deterministica
e uma tabela de frases. O jogo deve ser completamente interessante sem Ollama.

## Ler antes

- `docs/llm-director.md` -- seccao 3 (Fallback sem LLM)
- `docs/narrative-design.md` -- arcos base
- `agent_docs/tech_design.md` -- autoloads

## Critérios de aceitação

- [ ] `game/llm/simple_director.gd` satisfaz `IDirector` (duck typing com `has_method`)
- [ ] Maquina de estados com pelo menos 5 arcos base (A Jangada, O Companheiro, A Sinalizacao, O Diario, Avulso)
- [ ] Tabela de frases em `game/data/simple_director_phrases.json`: minimo 8 frases por arco
- [ ] Transicoes entre arcos baseadas nos thresholds de NeedsManager (SOLIDAO >= 70 -> arco companheiro, etc.)
- [ ] `Events` autoload usa `SimpleDirector` por defeito quando `LLMBridge.enabled == false`
- [ ] Testes GUT: transicoes de arco, seleccao de frases sem repeticao, fallback para arco avulso

## Fora de âmbito

- LLMDirector (T-115)
- Animacoes dos arcos (isso entra com cada arco visual)
- Persistencia entre sessoes (T-116)

## Prova exigida

- Smoke de 30s com SimpleDirector activo e arco visivel no log
- Teste de frases: 10 picks sem repeticao imediata
