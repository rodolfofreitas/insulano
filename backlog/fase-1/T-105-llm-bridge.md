---
id: T-105
titulo: LLMBridge assíncrono com timeout, filtro e fallback garantido
fase: 1
estado: pronto
tipo: codigo
depende_de: [T-101, T-102, T-103, T-104]
---

## Objectivo
Qualquer parte do jogo pede uma frase e recebe exactamente uma resposta, do LLM ou do fallback,
sem nunca bloquear um frame.

## Ler antes
- `agent_docs/tech_design.md` §4.5 (contrato de comportamento completo), `docs/api-ollama.md`

## Critérios de aceitação
- [ ] `game/llm/llm_bridge.gd` registado como autoload `LLM` em `project.godot`
- [ ] Teste GUT unit: `build_payload` igual ao payload documentado em `docs/api-ollama.md`
- [ ] Teste GUT unit: `parse_response` com fixtures `game/tests/fixtures/ollama_ok.json`, `ollama_empty.json`, `ollama_invalid.txt` e código 500
- [ ] Teste GUT integração: `INSULANO_LLM_URL=http://127.0.0.1:9` emite `phrase_ready` com `source == "fallback"` em menos de `timeout_s + 1` s
- [ ] Teste GUT integração: com `enabled = false` emite fallback sem criar pedido HTTP
- [ ] Teste GUT integração: dois pedidos seguidos, o segundo recebe fallback imediato; cada `request_id` recebe um e um só sinal
- [ ] Teste ao vivo em `game/tests/live/test_llm_live.gd` (fora do `.gutconfig.json`), corrido pelo `scripts/verify.sh --llm` quando o Ollama responde; `verify.sh` alterado para isso
- [ ] `scripts/verify.sh --llm` sem FALHOU

## Fora de âmbito
- Ligar à behavior tree (T-106)
- Streaming de tokens

## Prova exigida
- Testes listados; excerto do log `[Insulano/LLM]` com latência de uma chamada real no Relatório

## Relatório
(preenchido pelo executor)
