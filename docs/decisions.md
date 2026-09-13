# Insulano — Decisões de Arquitectura

## ADR-001 — Base de código: fork do Guy on Island

Data: 2026-09-13
Estado: ACEITE

### Contexto
Precisamos de um ponto de partida em Godot 4 com behavior trees já integradas.

### Decisão
Fork do Guy on Island (Doubi, MIT) como base. O código é pequeno (13 commits),
bem estruturado, usa Beehave, e já demonstra o conceito a funcionar.

### Consequências
- Licença MIT herdada — compatível com Kaeto
- Dependência do Beehave plugin (estável, mantido)
- Código GDScript (Godot 4) — stack escolhida para o projecto

---

## ADR-002 — LLM local via Ollama HTTP API

Data: 2026-09-13
Estado: ACEITE

### Contexto
Queremos frases e comportamento gerado por IA sem custo recorrente, sem cloud,
sem dependência de API keys externas.

### Decisão
Ollama a correr localmente (já instalado em lenovo-omarchy, porta 11434).
Chamadas HTTP simples de dentro do GDScript via HTTPRequest.

### Consequências
- Zero custo de operação
- Privacy total (nada sai da máquina)
- Depende do Ollama estar a correr — precisamos de fallback para frases fixas
- Latência de ~1-3s por geração (aceitável para um protetor de ecrã)

---

## ADR-003 — Assets: CC0 + CC-BY, sem Sierra

Data: 2026-09-13
Estado: ACEITE

### Contexto
Johnny Castaway continua copyright Activision. Usar os seus assets é risco legal.

### Decisão
- Tileset: Tiny Islands por Majadroid (CC0 — domínio público)
- Sprites: Character Base Template por Antifarea & Clint Bellanger (CC-BY)
- Qualquer asset novo gerado com IA (Stable Diffusion local via ComfyUI)
- Crédito CC-BY obrigatório no ecrã de créditos do jogo

### Consequências
- Projecto 100% legalmente limpo
- Podemos distribuir, publicar no itch.io, Steam, etc.
- Visual diferente do Johnny original — é intencional
