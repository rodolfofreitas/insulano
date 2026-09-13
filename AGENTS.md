# AGENTS.md — Insulano

Plano mestre para qualquer agente (Hermes, Claude Code, Codex) que opere neste projecto.
Ler ANTES de tocar em qualquer ficheiro.

---

## 1. O que é este projecto

Insulano é um protetor de ecrã com personagem autónomo numa ilha tropical.
Inspirado no Johnny Castaway (Sierra, 1992). Comportamento dirigido por LLM local (Ollama).
Motor: Godot 4. Licença: MIT. 100% local, sem cloud, sem API keys externas.

## 2. Leitura obrigatória antes de trabalhar

Ordem de leitura:

    1. AGENTS.md                         (este ficheiro — contexto global)
    2. CLAUDE.md                         (contexto para Claude Code)
    3. agent_docs/prd.md                 (o que o produto faz e para quem)
    4. agent_docs/tech_stack.md          (stack e dependências)
    5. agent_docs/code_patterns.md       (padrões a seguir)
    6. base-guy-on-island/               (código base — ler antes de escrever)

## 3. Regras invariantes

- NUNCA usar assets da Sierra/Activision — risco legal. Ver docs/threat_model.md.
- TODO código novo vai em GDScript (Godot 4), não C# nem GDScript 1.
- Ollama sempre com fallback para frases fixas quando indisponível.
- Commits: tipo: descrição em inglês (feat/fix/docs/chore/refactor).
- Código em inglês. Comentários em português quando justificam decisão de negócio.
- Testes manuais: Export Linux .x86_64 deve correr antes de fechar qualquer fase.

## 4. Arquitectura em 3 camadas

    [World / Ilha]        — tileset, ambiente, ciclo dia/noite, clima
         ↓
    [Character / Guy]     — behavior tree (Beehave), necessidades, animações
         ↓
    [LLM Bridge]          — HTTP request ao Ollama, fallback, contexto de prompt

Cada camada é independente. Alterações numa não devem quebrar as outras.

## 5. Quando delegar vs. executar directamente

Fazer directamente (Hermes):
- Editar docs (README, AGENTS.md, CLAUDE.md, roadmap)
- Configs (export_presets.cfg, project.godot)
- Fixes triviais (typo, ajuste de constante)
- Pesquisa e análise

Delegar ao Claude Code:
- Qualquer feature nova (≥ 2 ficheiros .gd envolvidos)
- Integração Ollama (LLMBridge.gd)
- Ciclo dia/noite (WorldEnvironment, shader)
- Novos eventos (gaivota, barco, chuva)
- Qualquer alteração ao behavior tree

## 6. Portões de qualidade antes de fechar fase

Fase 1 (LLM):
- [ ] Jogo corre no Omarchy (Linux/Wayland) sem erro
- [ ] Ollama responde com frase em < 3s
- [ ] Fallback activa quando Ollama está offline
- [ ] Export .x86_64 funcional

Fase 2+ (adicionar portões equivalentes no roadmap)

## 7. Contexto de ambiente

- Máquina: lenovo-omarchy, Arch Linux, Hyprland/Wayland
- Ollama porta: 11434 (já instalado, já a correr)
- Godot 4: verificar instalação antes de começar
- Path do projecto: ~/Programacao/Kaeto/Insulano/
- Base de código: base-guy-on-island/ (submodulo git, MIT)

## 8. Ficheiros que não tocar sem discussão

- base-guy-on-island/ — submodulo, alterações vão para o repo próprio do projecto
- docs/threat_model.md — só o Rodolfo altera
- .gitmodules — só alterar com instrução explícita

## 9. Referências

- PRD completo: agent_docs/prd.md
- Tech stack: agent_docs/tech_stack.md
- Padrões de código: agent_docs/code_patterns.md
- Decisões de arquitectura: docs/decisions.md
- Roadmap: docs/roadmap.md
- Runbook: docs/runbook.md
- Threat model: docs/threat_model.md
