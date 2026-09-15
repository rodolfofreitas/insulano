# Changelog

Formato: [Keep a Changelog](https://keepachangelog.com/pt-PT/1.1.0/). Versionamento: SemVer.
Entradas em linguagem de utilizador, não de commit. Cada tarefa acrescenta a sua em `[Não lançado]`.

## [Não lançado]

### Adicionado
- `GameClock` (T-201): autoload `Clock`, fonte unica da hora do sistema. API publica: `now()`, `hour_float()`, `period()`, `signal hour_changed`. Suporta override via variavel de ambiente `INSULANO_FAKE_TIME` (formato `AAAA-MM-DDTHH:MM`) e setting `insulano/debug/fake_time`, sem mexer no relogio da maquina. Valor invalido regista aviso e usa hora real.

## [0.1.0] - 2026-09-14

### Adicionado
- Projecto jogável em `game/`, a partir do Guy on Island, a correr em Godot 4.7.2.
- Portão de verificação único (`scripts/verify.sh`): documentação, backlog, lint, testes, arranque, imagem, LLM e export.
- Export templates 4.7.2 instalados e export Linux provado: `scripts/export.sh` produz
  `dist/linux/insulano.x86_64` e o binário arranca sem `SCRIPT ERROR`, `Parse Error` nem
  `Failed to load script` (os três padrões vigiados pelo portão), tanto headless (600 frames)
  como em modo janela real na sessão Hyprland (10 s, sem crash). Uma regressão latente exposta
  por esta corrida (erro de motor `TypedArray`/`erase`, fora dos três padrões vigiados) ficou
  registada na T-006, ainda não corrigida (fora do âmbito desta entrada).
- Testes automáticos: 20 testes GUT, 40 testes dos scripts, smoke de arranque de 30 s simulados.
- Captura de ecrã real de tamanho fixo, para provas visuais.
- Eval das frases do LLM local (latência, português de Portugal, comprimento, conteúdo proibido).
- Backlog de 33 tarefas em 6 fases, com critérios de aceitação verificáveis.
- Harness para agentes: AGENTS.md, tech design com contratos, agentes e skills do Claude Code.
- `LLMSettings` (T-101): leitura única das chaves `insulano/llm/*` (activo, URL, modelo, timeout,
  intervalo mínimo), com defeitos em `project.godot`, sobreposição por `user://settings.cfg` e,
  só para o URL, pela variável de ambiente de teste `INSULANO_LLM_URL`.
- `PhraseContext` e `PromptBuilder` (T-102): contexto tipado da situação do náufrago e montagem do
  prompt a partir de `game/data/prompts/phrase_prompt.txt`, com paridade carácter a carácter provada
  contra `scripts/llm_eval.py` (fixture `game/tests/fixtures/prompt_tarde_pescar.txt`, gerada pelo
  Python real). Contexto incompleto nunca produz um prompt com `{campo}` por preencher: devolve `""`
  e regista erro.
- `PhraseFilter` (T-103): aceita ou rejeita frases geradas pelo LLM, com regras lidas de
  `game/data/phrase_rules.json` (nunca hard-coded) e paridade total com `scripts/llm_eval.py`,
  provada contra a fixture partilhada `game/tests/fixtures/phrase_filter_cases.json` em ambos os
  lados (GUT e pytest, com casos de sobreposição de motivos e de NBSP para guardar a ordem de
  verificação e a contagem de palavras). Mesma ordem de verificação do Python: empty, english,
  ptbr, forbidden, too_short, too_long, mais o sétimo valor `rules_missing` (sem equivalente no
  Python), quando `phrase_rules.json` falta ou tem JSON inválido: o filtro falha FECHADO,
  `rejection_reason()` rejeita sempre, nunca aceita por omissão. Padrões
  `english_patterns`/`ptbr_patterns` e a contagem de palavras (`\S+`) compilados com o verbo PCRE2
  `(*UCP)`, para o `(?i)` inline ignorar maiúsculas também em acentuados (ex. `VOCÊ`, `TÔ`) e para
  o NBSP (U+00A0) contar como separador de palavra, como já fazia o Python (`re.IGNORECASE` e
  `str.split()`).
- `FallbackPhrases` (T-104): frases fixas em português de Portugal para quando o Ollama não
  responde, lidas de `game/data/phrases_fallback.json` (nunca hard-coded), com as categorias
  `idle`, `fishing`, `eating`, `morning`, `night`, `rain`, `seagull` e `boat`, cada uma com pelo
  menos 4 frases. `pick()` nunca repete de imediato a frase anterior da mesma categoria e uma
  categoria desconhecida cai sempre em `idle`. Todas as frases de fallback passam o mesmo
  `PhraseFilter` (T-103) que valida as frases geradas pelo LLM: um náufrago sem rede fala tão bem
  como um náufrago com Ollama.
- `LLMBridge` (T-105), autoload `LLM`: ponte assíncrona única com o Ollama, com `HTTPRequest` filho
  (nunca bloqueia um frame) e o sinal `phrase_ready(request_id, text, source)` emitido exactamente
  uma vez por pedido, sempre, mesmo em erro. Um só pedido de cada vez: um pedido novo com outro em
  curso responde já com fallback, sem tocar no pedido em curso. `settings.enabled = false` nunca
  cria o `HTTPRequest` filho. Qualquer falha (rede, timeout, HTTP diferente de 200, JSON inválido,
  resposta vazia ou frase rejeitada pelo `PhraseFilter`) cai no fallback garantido de
  `FallbackPhrases` (T-104). Log `[Insulano/LLM]` com modelo, latência e motivo de fallback, nunca
  o prompt inteiro. Teste ao vivo em `game/tests/live/test_llm_live.gd` (fora do
  `.gutconfig.json`, só corre com `scripts/verify.sh --llm`): marca-se `pending()` em vez de falhar
  quando o Ollama não responde nesta máquina.
- `SayGeneratedAction` (T-106): substitui todos os `TalkAction` fixos em inglês da árvore herdada
  por uma acção que pede uma frase à ponte `LLM` (ou ao fallback garantido) e fala sempre em
  português de Portugal. Lê `current_action` do blackboard, agora escrito por `FishingAction`
  ("pescar"), `UseUsableAction` ("comer"), `WatchOceanAction` ("observar o oceano") e, pelas três
  instâncias de `GoToUsableAction.current_action_label` em `guy.tscn`, "ir comer" (a caminho de
  comer), "ir pescar" (a caminho da pesca) e "passear" (sequência de passear): sem isto, a frase
  dita antes de comer ou pescar podia usar o verbo deixado pela sequência anterior. Respeita
  `LLMSettings.min_interval_s` partilhado entre todas as instâncias via `say_last_at_s` no
  blackboard (provado por mutação: um relógio por instância deixaria os 6 nós falar em sequência
  sem esperar pelos outros); quando o intervalo bloqueia, nunca toca em `talking_text` (nem para
  falar nem para o limpar: desde a T-107 quem manda no desaparecimento do balão é o `SpeechBubble`).
  Ignora `phrase_ready` com o
  `request_id` de outro pedido. Trata a resposta síncrona do `LLMBridge` (ponte desligada, pedido
  concorrente ou prompt vazio) ligando o sinal `phrase_ready` antes de chamar `request_phrase`,
  para nunca perder esse caso e ficar `RUNNING` para sempre. `interrupt()` esquece o pedido em
  curso, para uma resposta tardia de um pedido interrompido nunca falar sobre um contexto que já
  não é o actual. Relógio (`Time.get_ticks_msec` por defeito) injectável via `clock: Callable`,
  para os testes controlarem o tempo sem esperar segundos reais. `boot_smoke.gd` alargado para 90 s
  simulados e confirma que o náufrago diz pelo menos uma frase de `phrases_fallback.json` com
  `INSULANO_LLM_URL` apontado para uma porta morta (agora também passado por `scripts/verify.sh`,
  determinístico e sem depender de um Ollama real a responder).
- `SpeechBubble` (T-107): substitui o `Label` simples do balão de fala por um `PanelContainer` com
  fundo branco opaco e texto quase preto (contraste 18,4:1 pela luminância relativa WCAG, acima do
  mínimo de 4,5:1 pedido), com fundo opaco para se ler sobre qualquer fundo da ilha. Largura máxima de 220 px do mundo com
  quebra de linha automática, para uma frase de 15 palavras nunca sair do ecrã. Passa a ser este nó,
  e não a `SayGeneratedAction`, a decidir quanto tempo uma frase fica visível:
  `clamp(2.5 + 0.35 * palavras, 3, 9)` segundos, com o mínimo (3 s) igual a
  `SayGeneratedAction.MIN_VISIBLE_S`. `SayGeneratedAction.tick()` só pede uma frase nova depois de
  `maxf(min_interval_s, MIN_VISIBLE_S)`, nunca de `min_interval_s` sozinho: assim a garantia de
  "nenhuma frase visível menos de 3 s" vale para qualquer valor configurado em
  `user://settings.cfg`, incluindo 0 (bloqueante da revisão, ronda 1). Provado com
  `docs/proof/T-107-balao-1080p.png` e `docs/proof/T-107-balao-1600p.png`.

### Alterado
- Frases do náufrago afinadas (T-108): o filtro passa a rejeitar a próclise brasileira com verbos
  como poder, dever, querer, ir e conseguir (ex. "pode me ajudar", "vou me deitar"), com casos de
  teste para não rejeitar português de Portugal válido como "o barco que me leve" ou "vai se
  calhar chover"; e o prompt passa a descrever o que existe numa ilha deserta, para reduzir
  animais de quinta e objectos impossíveis nas frases. Eval de referência de 2026-09-14: 40
  amostras, todas aceites pelo filtro, latência mediana de 3 s.
- Renderer passa a Compatibility (OpenGL 3): mais leve para um protector de ecrã 2D.
- Feriados passam de YAML para JSON, com Carnaval e Páscoa calculados a partir da data da Páscoa.
- Modelo por defeito passa a `llama3.1:8b`, o único instalado, com limiares de latência medidos.
- Addon Beehave actualizado de 2.8.3 para 2.9.3 (código de `gh release download v2.9.3 -R bitbrain/beehave`):
  correcções internas de interrupção de árvore e sanitização do blackboard para o depurador, sem
  mudança de comportamento visível nem de contrato para as folhas próprias em `game/beehave/`.

### Corrigido
- Documentação que indicava modelos, versões e endpoints que não correspondiam à máquina real.
- Lint, formatação e documentação dos 21 ficheiros de GDScript herdados do Guy on Island
  (`scripts/gd_baseline.txt` fica vazia): cabeçalhos e docstrings novos, variáveis exportadas
  `fishingRod`, `searchArea` e `navigationAgent` renomeadas para `snake_case` (cenas actualizadas),
  sem alterar o comportamento do jogo.
- Seis bugs latentes do código herdado, cada um com teste de regressão (`test_regression_<bug>`):
  `search_area.body_exited` ligava ao handler errado e os objectos nunca saíam de
  `objects_in_area`; `NeedReplentishingUsable.get_satisfying_needs()` rebentava com
  `max_replentish_value == 0`; `FundUsableForNeedCondition` devolvia `FAILED` (erro global) em
  vez de `FAILURE` quando não havia objectos; `SetDeltaOnBlackboardAction` imprimia o delta a
  cada tick; `FishingAction.spawn_fish` usava um índice `-1` que apanhava o filho errado quando
  o personagem era o primeiro filho do pai; `fishing_spot.gd` desenhava o círculo de debug
  também fora do editor.
- Erro de motor `TypedArray`/`erase` (T-006): `FundUsableForNeedCondition._body_exited_area`
  chamava `objects_in_area.erase(body)` sem confirmar `body is UsableObject`, o que disparava
  `ERROR: Attempted to erase an object into a TypedArray` sempre que um corpo qualquer (não
  `UsableObject`) saía da área de busca. Regressão exposta pela T-004 depois da T-003 ligar o
  sinal correcto; corrigida com a mesma guarda de tipo que `_body_entered_area` já usava.
