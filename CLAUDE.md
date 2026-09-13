# Insulano — Contexto para Claude Code

## O que é

Protetor de ecrã com personagem autónomo numa ilha tropical. Inspirado no Johnny Castaway
(Sierra, 1992). Comportamento dirigido por LLM local (Ollama). Sem cloud, sem API keys.

## Stack

- Godot 4 + GDScript
- Plugin Beehave (behavior trees)
- Ollama HTTP API (localhost:11434) para frases e decisões
- Tileset CC0 (Tiny Islands), sprites CC-BY (Character Base Template)

## Base de código

A pasta `base-guy-on-island/` contém o fork do Guy on Island (MIT, Doubi/Codeberg).
É a referência — ler antes de escrever código novo.

Estrutura relevante do original:
- `guy/` — lógica do personagem e behavior tree
- `world/` — ilha, spots de pesca
- `character/` — sprites e animações
- `beehave/` — plugin behavior trees
- `fishing_spot.gd` — lógica de pesca
- `need_bar.gd` — sistema de necessidades (fome)

## O que está feito (herdado do Guy on Island)

- Personagem que anda, pesca, come, diz frases (lista fixa)
- Sistema de necessidades: fome diminui, pesca repõe
- Behavior tree com Beehave
- Export Linux/Windows/HTML5 configurado

## O que falta construir (roadmap Insulano)

### Fase 1 — LLM local (mínimo viável)
- Substituir frases fixas por chamadas HTTP ao Ollama
- Endpoint: GET http://localhost:11434/api/generate
- O personagem diz coisas geradas pelo modelo baseadas no contexto (hora, acção, necessidades)
- Fallback: frases fixas se Ollama não responder

### Fase 2 — Ciclo dia/noite
- Paleta de cores muda com a hora do sistema
- Personagem vai dormir à noite
- Efeitos visuais: pôr do sol, estrelas, lua

### Fase 3 — Eventos e visitantes
- Gaivota passa
- Barco ao longe
- Chuva (ligada à API de clima real, ex: wttr.in)
- Personagem reage ao evento com frase gerada pelo LLM

### Fase 4 — Feriados e contexto temporal
- Datas especiais (Natal, Ano Novo, etc.) mudam cenas
- Estrutura YAML de feriados (inspirada no Hunter Davis)

## Convenções

- Código em inglês (GDScript)
- Comentários em português quando explicam decisão de negócio
- Commits: tipo: descrição (feat/fix/docs/chore)
- Sem assets Sierra — projecto 100% legalmente limpo

## Modelos Ollama recomendados (já instalado localmente)

- gemma3:4b — rápido, frases curtas
- llama3.2:3b — alternativa leve
- Para produção: testar latência com `ollama run gemma3:4b "frase curta de um náufrago"`

## Legal

MIT (base) + CC0 (tileset) + CC-BY (sprites — crédito obrigatório no jogo)
Projecto Kaeto — desenvolvimento interno Rodolfo
