# AGENTS.md: Insulano

Plano mestre para qualquer agente (Hermes, Claude Code, Codex) que trabalhe neste
repositório. É a fonte de verdade sobre **como se trabalha aqui**. O que o produto
é vive no PRD; como está construído vive na arquitectura; o que falta fazer vive
no backlog.

---

## 0. Em 30 segundos

- **O que é:** protector de ecrã em Godot 4 com um náufrago autónomo numa ilha;
  frases geradas por um LLM local (Ollama), com fallback para frases fixas.
- **Onde está o jogo:** [`game/`](game/project.godot). O submódulo
  `base-guy-on-island/` é só referência upstream: nunca se edita.
- **O que fazer a seguir:** `python3 scripts/backlog.py next`.
- **Como saber se está bem:** `scripts/verify.sh` (portão único). Nada está feito
  sem ele verde e sem a prova que a tarefa exige.

## 1. Leitura obrigatória, por ordem

1. Este ficheiro.
2. [`agent_docs/project_brief.md`](agent_docs/project_brief.md): o produto numa página.
3. [`agent_docs/prd.md`](agent_docs/prd.md): requisitos e critérios de sucesso.
4. [`agent_docs/tech_design.md`](agent_docs/tech_design.md): contratos de cada componente (nomes, sinais, settings).
5. [`agent_docs/code_patterns.md`](agent_docs/code_patterns.md): como se escreve GDScript aqui.
6. [`agent_docs/testing.md`](agent_docs/testing.md): pirâmide de testes e o que cada portão prova.
7. A tarefa em curso em [`backlog/`](backlog/README.md) e os ficheiros da secção "Ler antes".

Referência sob demanda: [`docs/architecture.md`](docs/architecture.md),
[`docs/decisions.md`](docs/decisions.md), [`docs/api-ollama.md`](docs/api-ollama.md),
[`docs/runbook.md`](docs/runbook.md), [`docs/assets-licencas.md`](docs/assets-licencas.md).

## 2. O loop autónomo

Desenhado como loop de quatro peças (doutrina da fábrica):

| Peça | Neste projecto |
|---|---|
| Gatilho | uma sessão arranca com `/insulano-loop`, ou o Hermes despacha uma tarefa |
| Acção | executar UMA tarefa do backlog de ponta a ponta (passos abaixo) |
| Condição de paragem | `verify.sh` sem FALHOU e todos os critérios da tarefa provados |
| Estado | o frontmatter e a secção Relatório de cada `backlog/**/T-*.md`, mais o git |

### Passos por tarefa

1. `python3 scripts/backlog.py next`. Exit 3 significa que não há nada executável: parar e reportar.
2. Mudar `estado: em-curso` na tarefa. Ler "Ler antes" e os contratos em `tech_design.md`.
3. **Testes primeiro.** Escrever o teste GUT (ou pytest, para scripts) e vê-lo falhar pelo motivo certo.
4. Implementar o mínimo que o faz passar, seguindo `code_patterns.md`.
5. Correr `scripts/verify.sh`, mais `--visual` se `tipo: visual`, mais `--llm` se tocou em prompt, regras ou LLMBridge.
6. Se falhar: corrigir a causa, não o sintoma, e repetir o passo 5. No máximo **3 ciclos completos**;
   ao terceiro, `estado: bloqueado`, escrever no Relatório o que se tentou e o erro exacto, e passar à tarefa seguinte.
7. Documentação no mesmo commit: `python3 scripts/check_docs.py --fix` se criou ou renomeou `.gd`;
   actualizar `tech_design.md` se um contrato mudou; entrada em `CHANGELOG.md` na secção `[Não lançado]`;
   ADR novo em `docs/decisions.md` se tomou uma decisão que outro agente poderia tomar ao contrário.
8. Tarefas visuais: copiar a captura para `docs/proof/T-NNN-descricao.png` e **abrir a imagem** para confirmar o que se vê.
9. Preencher o Relatório (o que mudou, comandos corridos e resultado, desvios, o que ficou por verificar).
   Pedir o veredicto ao `insulano-verifier` (quem implementou não se julga). Só com PASSOU:
   `estado: feito` e commit `feat(T-NNN): descrição` (ou fix/docs/chore/test).
10. Voltar ao passo 1.

### Quando o loop pára sozinho

- `backlog.py next` devolve exit 3 (só restam tarefas `humano` ou `bloqueado`).
- Duas tarefas seguidas ficaram `bloqueado`: há um problema de fundo, parar e reportar.
- `verify.sh` falha numa verificação **que a tarefa não tocou** (regressão prévia): criar tarefa nova
  `fix` com a evidência, marcá-la como dependência da actual e parar.
- O turno ou o contexto está a esgotar: escrever no Relatório o estado exacto e o que falta,
  deixar `em-curso`, **não** marcar feito.

## 3. Definition of Done por tipo de tarefa

| Tipo | Obrigatório antes de `estado: feito` |
|---|---|
| `codigo` | teste novo que falhava e agora passa; `verify.sh` sem FALHOU; docstrings `##`; CHANGELOG |
| `visual` | tudo o de `codigo`, mais `verify.sh --visual` e PNG em `docs/proof/` inspeccionado |
| `infra` | comando real corrido com o output no Relatório (ex.: `scripts/export.sh` a PASSOU) |
| `docs` | `check_docs.py` a PASSOU; nenhum comando descrito que não tenha sido corrido |

Fecho de fase: `scripts/verify.sh --full` sem FALHOU (INDETERMINADO só com motivo escrito e aceite
numa tarefa `humano`), export Linux a arrancar e `CHANGELOG` com a versão.

## 4. Fronteiras de autonomia

**Pode fazer sozinho:** tudo dentro de `game/`, `scripts/`, `evals/`, `backlog/`, `agent_docs/`,
`docs/` (excepto o ficheiro protegido abaixo), testes, commits locais, instalar ferramentas de
utilizador via `mise` ou `uvx`.

**Nunca sem o Rodolfo** (a tarefa nasce ou passa a `estado: humano`):

- assets de terceiros novos (imagem, som, fonte): licença verificada e registada por ele;
- qualquer funcionalidade que envie dados para a rede **ligada por defeito**;
- editar `~/.config/` (hypridle, Hyprland) ou qualquer coisa fora do repositório;
- `ollama pull` de modelos, alterar o contentor Docker do Ollama, `sudo`;
- publicar (itch.io, GitHub, qualquer destino externo), `git push`;
- alterar `docs/threat_model.md`, `.gitmodules` ou o submódulo `base-guy-on-island/`;
- decisões de licença do próprio Insulano.

## 5. Mapa do repositório

| Caminho | Conteúdo |
|---|---|
| `game/` | projecto Godot (`project.godot`), código, cenas, dados e testes |
| `game/data/` | JSON de dados e o template do prompt (fonte única, partilhada com o eval) |
| `game/tests/unit`, `game/tests/integration` | testes GUT; `game/tests/fixtures` com casos partilhados |
| `game/tools/` | `boot_smoke.gd` (smoke headless) e `capture.gd` (screenshot) |
| `scripts/` | `verify.sh`, `check_docs.py`, `backlog.py`, `llm_eval.py`, `export.sh` e os seus testes |
| `evals/` | contextos de avaliação das frases do LLM |
| `backlog/` | tarefas por fase, estado do loop |
| `agent_docs/` | harness para agentes: brief, PRD, tech design, padrões, testes |
| `docs/` | artefactos para humanos: arquitectura, ADRs, API Ollama, runbook, licenças, provas |
| `.claude/` | agentes e skills do Claude Code específicos deste projecto |
| `base-guy-on-island/` | submódulo upstream (MIT), só leitura |

## 6. Regras invariantes de código

1. GDScript tipado em tudo o que é novo. Nada de C#.
2. `LLMBridge` é o único sítio que fala com o Ollama; `WeatherService` o único que fala com o wttr.in.
3. Nenhuma chamada de rede bloqueia um frame. Toda a chamada tem timeout e fallback.
4. O jogo corre completo sem Ollama e sem internet.
5. Prompt, regras de filtro, feriados, frases de fallback e paletas vivem em `game/data/`, nunca no código.
   O `scripts/llm_eval.py` lê os mesmos ficheiros: se divergirem, o eval mente.
6. Tempo, clima e aleatoriedade têm costuras de teste (`INSULANO_FAKE_TIME`, `INSULANO_FAKE_WEATHER`, seeds).
7. Caminhos só `res://` e `user://`.
8. Nenhum asset da Sierra ou Activision, nem "inspirado ao pixel". Todo o asset em `docs/assets-licencas.md`.
9. Todo o `.gd` novo com cabeçalho `##` e `##` em cada função pública (o `check_docs.py` falha sem isso).
10. Texto visível ao utilizador em português de Portugal. Sem travessões em lado nenhum.

## 7. Agentes e skills do projecto

| Nome | Tipo | Para que |
|---|---|---|
| `/insulano-loop` | skill Claude Code | corre o loop da seccao 2 ate uma condicao de paragem |
| `/insulano-task` | skill Claude Code | executa uma unica tarefa (passos 2 a 9) |
| `/insulano-verify` | skill Claude Code | corre e interpreta os portoes, sem falsos verdes |
| `/insulano-docs-sync` | skill Claude Code | scan, generate, check da documentacao contra o codigo |
| `/insulano-new-task` | skill Claude Code | escreve tarefas novas com criterios binarios |
| `/insulano-asset` | skill Claude Code | adiciona um asset com licenca registada (ou marca humano) |
| `insulano` | skill Hermes | loop autonomo Hermes com agentes paralelos; contexto completo |
| `insulano-builder` | agente | implementa uma tarefa em GDScript com testes primeiro |
| `insulano-reviewer` | agente | revisao adversarial do diff contra contratos e regras invariantes |
| `insulano-verifier` | agente | corre verify.sh, le logs e imagens, devolve veredicto sem corrigir |
| `insulano-docs-keeper` | agente | detecta e corrige deriva entre docs e codigo |
| `insulano-llm-tuner` | agente | afina prompt e regras com o eval como metrica |

O construtor nao se julga: quem implementou nao declara o proprio veredicto final;
o `insulano-verifier` (ou o Hermes) confirma.

### Hermes vs Claude Code

| | Hermes (`insulano` skill) | Claude Code (`/insulano-loop`) |
|---|---|---|
| Paralelismo | Vagas de agentes em paralelo | Loop sequencial |
| Velocidade | Mais rapido (madrugada) | Mais lento mas interactivo |
| Stop hooks | Nao afectado | Hook `feedback-sempre-quadro-de-selecao` pode interromper |
| Quando usar | Sessoes autonomas, utilizador ausente | Exploratorio, utilizador a acompanhar |

Para iniciar o loop Hermes: dizer "Continua o backlog do Insulano".

## 8. Integração com a fábrica

Quando o Hermes despacha uma célula S8 para este repositório, a célula executa uma tarefa
do backlog pelos passos 2 a 9 e escreve o `RELATORIO.md` pedido pela fábrica com o mesmo
conteúdo da secção Relatório da tarefa. A regra de fecho da fábrica aplica-se: o artefacto real
tem de correr (export Linux ou `boot_smoke`) e a UI tem screenshot em `docs/proof/`.
`BLOQUEADO_HUMANO` corresponde a `estado: humano`.

## 9. Ambiente desta máquina

- Godot 4.7.2 via mise (`mise.toml` na raiz). Binário: `mise which godot`.
- gdtoolkit 4.x (gdlint, gdformat) e pytest via `uvx`, sem instalação global.
- Ollama em Docker, **só CPU**, em `127.0.0.1:11434`. Modelo instalado e medido: `llama3.1:8b`.
- Sessão Wayland (Hyprland): a captura visual abre uma janela durante uns segundos.

## 10. Armadilhas conhecidas

- O Godot sai com código 0 mesmo com `SCRIPT ERROR`: o `verify.sh` procura esses padrões nos logs.
- O Beehave imprime `Can't send message. No active debugger` em headless: ruído conhecido, ignorar.
- O Hyprland ignora `--resolution`: por isso o `capture.gd` renderiza num SubViewport fixo.
- O GUT conta como erro uma pasta de testes configurada que não existe.
- Uma `class_name` nova só é visível depois de `godot --headless --import` (o `verify.sh` já o faz).
- Na base, `FAILED` (constante global de erro, vale 1) é usado onde devia ser `FAILURE`; funciona por coincidência.
- O RegEx do Godot não trata letras acentuadas como letras em `\b` e `\w`: ver `game/data/phrase_rules.json`.
- O JSON do Godot devolve números como `float`: converter com `int()` ao ler meses e dias.
- `HTTPRequest` para `localhost` pode tentar IPv6: usar sempre `127.0.0.1`.
- A behavior tree usa `randf()`: testes que dependem de comportamento fixam a seed. Mesmo assim,
  `NavigationServer2D.map_get_random_point` não obedece ao `seed()`: asserções sobre posições usam limiares, nunca valores exactos.

## 11. Gauntlet Loop

Usar o Gauntlet Loop para polimento subjectivo (qualidade visual, comportamento, narrativa).
NAO usar para tarefas de backlog com criterios binarios claros (infraestrutura, builds, testes).

### Quando usar Gauntlet vs loop de backlog

| Situacao | Loop |
|---|---|
| Nova feature (T-114...) ou bug fix | Backlog loop + verify.sh |
| Polimento de sprites existentes | Gauntlet |
| Melhorar comportamento do naufrago | Gauntlet |
| Afinar frases PT-PT | Gauntlet |
| Screensaver feel geral | Gauntlet |

Ver playbook completo: docs/gauntlet/playbook.md

### Modo A -- Hermes compoe, Claude Code executa (recomendado)

1. Dizer ao Hermes: 'Gauntlet: [dimensao] -- [peca especifica]'
2. O Hermes propoe 2-3 barras fetchable. Tu escolhes.
3. O Hermes escreve o prompt e grava em docs/gauntlet/PROMPT-YYYYMMDD.md
4. Abrir sessao Claude Code fresca: `cd ~/Programacao/Kaeto/Insulano && claude`
5. Colar o conteudo de PROMPT-YYYYMMDD.md. Tu es o travao.

### Modo B -- Hermes executa com subagentes isolados

1. Dizer: 'Corre o gauntlet [peca] contra [barra]'
2. O Hermes faz fan-out: builder-subagente + critic-subagente (contextos distintos)
3. O critico recebe APENAS: screenshot do resultado + screenshot da barra + 'pick um'
4. Loop ate o humano parar. Nunca round cap.

## 12. Ficheiros protegidos

- `docs/threat_model.md`: só o Rodolfo altera. Propostas vão para `docs/threat_model-propostas.md`.
- `base-guy-on-island/` e `.gitmodules`: referência upstream.
- `scripts/gd_baseline.txt`: só pode perder linhas, nunca ganhar.
