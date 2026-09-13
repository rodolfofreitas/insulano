# Insulano: registo de decisões (ADR)

Formato Nygard: contexto, decisão, consequências. Uma decisão nova entra aqui quando
outro agente, sem este registo, poderia razoavelmente decidir ao contrário. Não se
apagam ADRs: substituem-se com uma nova que diz "substitui ADR-NNN".

---

## ADR-001: base de código a partir do Guy on Island

Data: 2026-09-13 · Estado: aceite

**Contexto.** Precisávamos de um ponto de partida em Godot 4 com behavior trees integradas.

**Decisão.** Partir do Guy on Island (Doubi, MIT): código pequeno, usa Beehave, e já demonstra
o conceito de personagem movido por necessidades.

**Consequências.** Licença MIT herdada (manter o aviso de copyright). Dependência do addon Beehave.
O código herdado não segue os nossos padrões de lint e documentação (ver T-002).

## ADR-002: LLM local via API HTTP do Ollama

Data: 2026-09-13 · Estado: aceite

**Contexto.** Frases geradas por IA sem custo recorrente, sem cloud e sem chaves de API.

**Decisão.** Ollama local, chamado por `HTTPRequest` do Godot em `POST /api/generate`, sempre em
`127.0.0.1:11434`.

**Consequências.** Zero custo, nada sai da máquina. Depende do Ollama estar a correr, logo o fallback
para frases fixas é obrigatório.

## ADR-003: assets CC0 e CC-BY, nada da Sierra

Data: 2026-09-13 · Estado: aceite

**Contexto.** O Johnny Castaway continua sob copyright da Activision.

**Decisão.** Tileset Tiny Islands (Majadroid, CC0), sprites Character Base (Antifarea e Clint Bellanger,
CC-BY). Assets novos só com licença verificada pelo Rodolfo e registada em `docs/assets-licencas.md`.

**Consequências.** Projecto distribuível. Crédito CC-BY obrigatório dentro do jogo (T-503).

## ADR-004: o jogo vive em `game/`, o submódulo é só referência

Data: 2026-09-13 · Estado: aceite

**Contexto.** `base-guy-on-island/` é um submódulo que aponta para o repositório upstream no Codeberg.
Editá-lo criaria commits num repositório que não é nosso ou divergência silenciosa.

**Decisão.** Copiar a base para `game/` (preservando `LICENSE-guy-on-island.md`) e desenvolver aí.
O submódulo fica intocado, para comparar com o upstream e para o `check_docs.py` validar que a
baseline de lint só contém ficheiros herdados.

**Consequências.** Actualizações do upstream entram à mão, se alguma vez interessarem. Um único
projecto Godot a abrir: `game/project.godot`.

## ADR-005: verificação autónoma com GUT, gdtoolkit, smoke headless e captura real

Data: 2026-09-13 · Estado: aceite

**Contexto.** O loop autónomo precisa de uma condição de paragem objectiva. O `testing.md` original
dizia que um protector de ecrã não tinha testes automáticos, o que tornava a autonomia impossível
de verificar.

**Decisão.** Um único portão, `scripts/verify.sh`, com: `check_docs.py` (deriva), `backlog.py check`,
pytest dos scripts, gdlint e gdformat (gdtoolkit 4.x via uvx), import do Godot, GUT 9.7.1 headless,
`boot_smoke.gd` (30 s de jogo simulados com `--fixed-fps 60`), captura real num SubViewport,
eval do LLM e export Linux. Os logs são lidos à procura de `SCRIPT ERROR` porque o Godot sai com 0.

**Consequências.** Verificado nesta máquina a 2026-09-13 (11 testes GUT, smoke e captura a passar).
A captura visual precisa de sessão gráfica. O código herdado fica em baseline até à T-002.

## ADR-006: modelo por defeito `llama3.1:8b`, limiares medidos

Data: 2026-09-13 · Estado: aceite

**Contexto.** Os docs originais recomendavam `gemma3:4b` e `llama3.2:3b` como "já instalados" e
exigiam frase em menos de 3 s. Nenhum dos dois modelos está instalado; o Ollama corre em Docker
só com CPU (sem passagem da RTX 3060).

**Decisão.** Defeito `llama3.1:8b` (o instalado), configurável em `insulano/llm/model`. Eval de
2026-09-13, 24 amostras: 95,8% aceites, p50 2,82 s, p95 4,42 s. Limiares do portão: taxa de
aceitação de pelo menos 90%, p50 até 4 s, p95 até 8 s, timeout 8 s. O critério "menos de 3 s" do
PRD passa a ler-se como p50.

**Consequências.** A latência não afecta a fluidez porque o pedido é assíncrono e o personagem
continua a agir. Trocar de modelo exige correr o eval e actualizar este ADR. Ligar a GPU ao
contentor do Ollama ou instalar um modelo menor é decisão do Rodolfo (fora do repositório).

## ADR-007: renderer Compatibility (OpenGL 3)

Data: 2026-09-13 · Estado: aceite

**Contexto.** A base usava Forward+. O Insulano é 2D pixel art, corre horas como protector e tem
export Web previsto.

**Decisão.** `rendering_method = gl_compatibility` em desktop e mobile.

**Consequências.** Menos consumo de GPU, o mesmo renderer no jogo, na captura e no Web. Efeitos
exclusivos do Forward+ (ex.: alguns pós-processamentos) ficam fora.

## ADR-008: dados em JSON e fontes únicas partilhadas com o eval

Data: 2026-09-13 · Estado: aceite

**Contexto.** Os feriados estavam em YAML, que o Godot não lê sem addon. O prompt estava descrito
em três documentos com três textos diferentes.

**Decisão.** Todos os dados em JSON em `game/data/`. O prompt vive em
`game/data/prompts/phrase_prompt.txt` e as regras de filtro em `game/data/phrase_rules.json`; o jogo
e o `scripts/llm_eval.py` lêem os mesmos ficheiros, e o filtro em GDScript e o de Python são
testados contra a mesma fixture. Datas móveis calculadas a partir da Páscoa.

**Consequências.** Mudar o prompt muda o jogo e o eval ao mesmo tempo. Os docs referem os ficheiros
em vez de copiar o texto.

## ADR-009: no Linux, o protector é arrancado pelo hypridle

Data: 2026-09-13 · Estado: aceite

**Contexto.** Wayland não tem uma API de protector de ecrã como o X11 ou o Windows. O Omarchy usa
hypridle para inactividade.

**Decisão.** O Insulano é uma aplicação normal com o modo `--screensaver` (fullscreen, sai com
input). O hypridle lança-o em `on-timeout` e termina-o em `on-resume`. Em Windows, um `.exe` com o
mesmo argumento; `.scr` fica fora de âmbito.

**Consequências.** A configuração do hypridle vive em `~/.config/hypr` e é do Rodolfo (T-502).

## ADR-010: backlog em ficheiros como estado do loop autónomo

Data: 2026-09-13 · Estado: aceite

**Contexto.** Um agente autónomo precisa de saber o que está feito, o que falta e porque é que algo
parou, entre sessões e entre ferramentas (Claude Code, Hermes, Codex).

**Decisão.** Uma tarefa por ficheiro em `backlog/fase-N/`, com frontmatter validado por
`scripts/backlog.py`, critérios binários e secção Relatório. Um executor de cada vez (no máximo uma
tarefa `em-curso`). Máximo 3 ciclos por tarefa antes de `bloqueado`.

**Consequências.** O histórico do git mostra a evolução do estado. Paralelizar tarefas exige
worktrees e uma decisão nova.
