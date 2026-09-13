# Insulano

Protector de ecrã para Linux e Windows onde um náufrago pixel art vive sozinho numa ilha tropical,
decide o que fazer pelas próprias necessidades e comenta a vida com frases geradas por um LLM local.

## O que faz

- O personagem pesca quando tem fome, passeia, observa o mar e fala, sem cenas pré-gravadas.
- As frases são geradas por IA a correr na tua máquina (Ollama): nada vai para a cloud, não há chaves de API.
- Sem Ollama, continua a funcionar com frases fixas em português.
- Planeado: ciclo dia e noite pela hora real, eventos (gaivota, barco, chuva), feriados portugueses.

## Estado

Fase 0 (fundação) em curso. O jogo herdado da base arranca, tem testes e o harness de desenvolvimento
autónomo está montado e verificado. As frases ainda são as fixas em inglês da base. Estado vivo por
tarefa: `python3 scripts/backlog.py list`.

## Pré-requisitos

- Linux x86_64 (desenvolvido em Omarchy, Hyprland/Wayland)
- [mise](https://mise.jdx.dev) (instala o Godot 4.7.2 fixado em `mise.toml`)
- [uv](https://docs.astral.sh/uv/) (corre `gdtoolkit` e `pytest` sem instalação global)
- Python 3.11 ou superior
- Opcional: Ollama em `127.0.0.1:11434` com o modelo `llama3.1:8b`

## Instalar

```bash
cd ~/Programacao/Kaeto/Insulano
git submodule update --init          # base upstream, só referência
mise install                         # Godot 4.7.2
git config core.hooksPath .githooks  # portão rápido antes de cada commit
```

## Correr

```bash
$(mise which godot) --path game       # jogo em janela
$(mise which godot) -e --path game    # editor
```

## Estrutura

| Pasta | O que tem |
|---|---|
| `game/` | projecto Godot: código, cenas, dados (`game/data/`) e testes (`game/tests/`) |
| `scripts/` | portão de verificação, eval do LLM, backlog, export |
| `backlog/` | tarefas por fase, com critérios de aceitação |
| `agent_docs/` | brief, PRD, tech design, padrões e testes (para quem constrói) |
| `docs/` | arquitectura, decisões, API do Ollama, runbook, licenças, provas |
| `base-guy-on-island/` | código base upstream (MIT), não se edita |

## Configuração

Por defeito em `game/project.godot`, com sobreposição em `user://settings.cfg` a partir da T-101.
Chaves (sem valores sensíveis, não há segredos neste projecto):

- `insulano/llm/enabled`, `insulano/llm/url`, `insulano/llm/model`, `insulano/llm/timeout_s`, `insulano/llm/min_interval_s`
- `insulano/weather/enabled`, `insulano/weather/location`
- Variáveis de teste: `INSULANO_FAKE_TIME`, `INSULANO_FAKE_WEATHER`, `INSULANO_LLM_URL`

Detalhe em [`agent_docs/tech_design.md`](agent_docs/tech_design.md).

## Testes

```bash
scripts/verify.sh            # docs, backlog, pytest, lint, testes GUT e smoke de arranque
scripts/verify.sh --visual   # mais screenshot real em reports/verify-latest.png
scripts/verify.sh --llm      # mais eval das frases contra o Ollama
scripts/verify.sh --full     # tudo, incluindo export
```

O que cada portão prova: [`agent_docs/testing.md`](agent_docs/testing.md).

## Build e deploy

```bash
scripts/export.sh            # dist/linux/insulano.x86_64 (precisa de export templates, ver runbook)
```

Procedimentos, incidentes e export templates em [`docs/runbook.md`](docs/runbook.md).

## Desenvolvimento autónomo

Este repositório está preparado para ser construído por agentes de IA de ponta a ponta. O ponto de
entrada é [`AGENTS.md`](AGENTS.md); no Claude Code, `/insulano-loop`.

## Licença

Código herdado sob MIT (Doubi, [`game/LICENSE-guy-on-island.md`](game/LICENSE-guy-on-island.md)).
Licença do código novo do Insulano por confirmar (T-506). Assets e créditos obrigatórios em
[`docs/assets-licencas.md`](docs/assets-licencas.md).

Inspirações: Johnny Castaway (Sierra, 1992, só conceito, nenhum asset), Guy on Island (Doubi, 2025),
Hunter Davis PS1 Port (feriados), Mochi LLM Pet (arquitectura LLM para comportamento).
