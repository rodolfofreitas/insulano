# API Ollama: referência para o Insulano

Referência da integração. O contrato de comportamento da ponte (fallback, concorrência, sinais) está em
[`../agent_docs/tech_design.md`](../agent_docs/tech_design.md) §4.5; o texto do prompt vive em
`game/data/prompts/phrase_prompt.txt` e **não se copia para aqui** (ADR-008).

## Onde está o Ollama nesta máquina

- Contentor Docker `ollama`, só CPU, porta publicada 11434.
- O CLI `ollama` não existe no host: usar `docker exec ollama ollama <comando>`.
- URL a usar no jogo e nos scripts: `http://127.0.0.1:11434` (nunca `localhost`, evita tentativas IPv6).
- Modelo configurado: `llama3.1:8b`.

## Endpoint

`POST http://127.0.0.1:11434/api/generate`

### Pedido

```json
{
  "model": "llama3.1:8b",
  "prompt": "<phrase_prompt.txt preenchido pelo PromptBuilder>",
  "stream": false,
  "keep_alive": "10m",
  "options": { "temperature": 0.8, "top_p": 0.9, "num_predict": 40 }
}
```

- `stream: false`: uma resposta única, mais simples de tratar com `HTTPRequest`.
- `keep_alive: "10m"`: mantém o modelo carregado entre frases (carregar custa segundos).
- `num_predict: 40`: chega para 15 palavras; corta respostas que se alongam.

### Resposta (campos usados)

```json
{ "model": "llama3.1:8b", "response": "Parece que até o Natal estou sozinho.", "done": true, "total_duration": 2003000000 }
```

Só `response` é usado. `total_duration` (nanossegundos) pode ir para o log de latência.

### Erros e o que a ponte faz

| Situação | `HTTPRequest` | Acção |
|---|---|---|
| Ollama parado | `result != RESULT_SUCCESS` | fallback |
| Modelo não instalado | código 404 | fallback, log com o nome do modelo |
| Timeout (8 s) | `RESULT_TIMEOUT` | fallback |
| JSON inválido ou `response` vazio | parse falha | fallback |
| Frase rejeitada pelo `PhraseFilter` | - | fallback, log com o motivo |

## Pedido genérico (T-115, LLMDirector)

Mesmo endpoint, `LLMBridge.request_completion(prompt, num_predict, timeout_s)`: o `prompt` já vem
pronto de quem chama (sem `PromptBuilder`), `num_predict` sobrepõe o 40 da tabela "Pedido" acima
(o `LLMDirector` usa 100 -- uma resposta JSON `{arc, activity, phrase}` não cabe em 40 tokens) e
`timeout_s` sobrepõe o timeout por defeito (o `LLMDirector` usa 25 s). Resposta chega crua a
`completion_ready`, sem `PhraseFilter`: quem chama valida o próprio schema.

Medido nesta máquina (Docker, só CPU, `docs/proof/T-115-director-live.log`): o prompt do director
tem ~400 tokens (muito maior do que o de uma frase), o que domina a latência mesmo com poucos
tokens de resposta -- p50 observado de 6 a 12 s, acima do alvo de <5 s da tarefa. É uma limitação
de hardware desta máquina (sem GPU), não do código; corrigir isso é decisão do Rodolfo (AGENTS.md
§4, "nunca sem o Rodolfo: alterar o contentor Docker do Ollama").

## Verificar à mão

```bash
# Está a responder? Que modelos há?
curl -s http://127.0.0.1:11434/api/tags | python3 -c 'import sys,json; [print(m["name"]) for m in json.load(sys.stdin)["models"]]'

# Onde corre o modelo (CPU ou GPU)?
docker exec ollama ollama ps

# Uma frase
curl -s http://127.0.0.1:11434/api/generate -d '{"model":"llama3.1:8b","prompt":"Diz uma frase curta de náufrago em português de Portugal.","stream":false}' \
  | python3 -c 'import sys,json; print(json.load(sys.stdin)["response"])'

# Eval completo com os contextos e regras do jogo
python3 scripts/llm_eval.py
```

## Modelos medidos

| Modelo | Instalado | Aceitação | p50 | p95 | Data | Relatório |
|---|---|---|---|---|---|---|
| `llama3.1:8b` (CPU) | sim | 95,8% | 2,82 s | 4,42 s | 2026-09-13 | `docs/proof/llm-eval-llama3.1_8b-2026-09-13.json` |
| `gemma3:4b` | não | - | - | - | - | instalar é decisão do Rodolfo |
| `llama3.2:3b` | não | - | - | - | - | instalar é decisão do Rodolfo |

Um modelo só entra nesta tabela com um eval corrido. Mudar o defeito exige actualizar a ADR-006.
