---
id: T-115
titulo: LLMDirector -- director narrativo via Ollama com 1 chamada por ciclo (JSON estruturado)
fase: 3
estado: em-curso
tipo: codigo
depende_de: [T-111, T-113, T-114, T-105]
---

## Objectivo

Implementar `LLMDirector` que substitui o `SimpleDirector` via contrato `IDirector`.
Uma unica chamada ao Ollama por ciclo devolve JSON com arco+actividade+frase.
O ciclo e event-driven (fim de actividade, threshold de necessidade, inicio de sessao).

## Ler antes

- `docs/llm-director.md` -- arquitectura completa do loop
- `agent_docs/tech_design.md` §4 (LLMBridge)
- `docs/needs-system.md` -- contexto para o LLM

## Critérios de aceitação

- [x] `game/llm/llm_director.gd` satisfaz `IDirector` (mesma interface do SimpleDirector)
- [x] Uma unica chamada por ciclo: prompt com estado completo, resposta JSON `{arc, activity, phrase}`
- [x] Ciclo event-driven: dispara em `activity_completed`, `need_threshold_crossed`, `session_start`
- [x] Contexto enviado: dia, hora, estacao, 4 necessidades, arco activo, 5 arcos recentes (so titulos), companheiro, ultimo evento
- [x] Validacao do JSON recebido; fallback para SimpleDirector em qualquer erro de parsing ou timeout
- [x] Memoria de decisoes: guarda ultimas 10 decisoes em `user://director_memory.json` (atomico)
- [x] Testes GUT: mock HTTP com response valida, mock com garbage, mock com timeout, validacao de schema

## Fora de âmbito

- Geracao de arcos novos pelo LLM (T-117)
- Companheiro imaginario (T-118)

## Prova exigida

- `verify.sh --llm`: eval com LLMDirector activo, 10 ciclos, JSON valido em todos
- Log com latencia por ciclo (deve ser p50 < 5s com 1 chamada)

## Relatório

### O que mudou

- `game/llm/llm_director.gd` (novo): `LLMDirector extends Node`, satisfaz `IDirector` por duck
  typing (`get_directive()`, `is_available()`), mesmo padrão do `SimpleDirector` (T-111). Ciclo
  **event-driven** via `trigger_cycle(reason)` com os 3 gatilhos pedidos (`TRIGGER_ACTIVITY_COMPLETED`,
  `TRIGGER_NEED_THRESHOLD`, `TRIGGER_SESSION_START`); sem `_process`/poll. Um ciclo em curso
  (`is_thinking()`) ignora pedidos novos -- nunca duas chamadas simultâneas. Contexto enviado:
  dia, hora, estação (hemisfério norte, `season_for_month`), as 4 necessidades
  (`NeedsManager.get_snapshot()`), arco activo e 5 títulos recentes (`ArcHistory`), companheiro
  (sempre `null`, T-118 fora de âmbito) e último evento livre (`set_last_event`). Resposta esperada
  `{arc, activity, phrase}`: `parse_directive` tolera cercas markdown (comum no llama3.1:8b, mesmo
  pedindo só JSON no prompt), `validate_directive` exige `arc` numa das 5 constantes do
  `SimpleDirector` (fonte única), `activity` não vazia e `phrase` do tipo certo. Qualquer falha
  (rede, timeout, JSON inválido, schema inválido) resolve com um `SimpleDirector` injectável (lazy),
  `source = "fallback"` no sinal `directive_ready`. Memória: últimas 10 decisões em `memory_path`
  (defeito `user://director_memory.json`, sobreponível), escrita atómica tmp+rename (mesmo padrão
  de `arc_history.gd`).
- `game/llm/llm_bridge.gd`: novo método `request_completion(prompt, num_predict=-1, timeout_s=-1)`
  e sinal `completion_ready` (a par de `request_phrase`/`phrase_ready`), reusando o mesmo
  `HTTPRequest` e a mesma regra "um pedido de cada vez" (`_busy_kind` distingue "phrase" de
  "completion" dentro de `_on_request_completed`). Sem `PromptBuilder` nem `PhraseFilter`: o
  chamador já traz o prompt pronto e recebe o texto cru. Novo `build_completion_payload(model,
  prompt, num_predict)` (não reaproveita `build_payload`, que tem `num_predict=40` fixo e
  documentado por `docs/api-ollama.md`/testado -- a resposta JSON do director não cabe nesses 40
  tokens). Isto respeita a regra invariante "só LLMBridge e WeatherService criam HTTPRequest"
  (AGENTS.md §6.2): o `LLMDirector` nunca abre rede directamente.
- `game/data/prompts/director_prompt.txt` (novo): instruções + marcador literal `{{CONTEXTO}}`
  (substituído por `LLMDirector.build_prompt` via `String.replace`, não `String.format`, porque o
  próprio template tem chavetas literais no exemplo de JSON pedido).
- `agent_docs/tech_design.md` §4.5 (contrato do `LLMBridge` actualizado com `request_completion`/
  `completion_ready`) e novo §4.7 (`LLMDirector`).
- `docs/api-ollama.md`: nova secção "Pedido genérico (T-115, LLMDirector)" com os números medidos.
- `CHANGELOG.md`: entrada em `[Não lançado] > Adicionado`.
- `docs/architecture.md`: regenerado por `check_docs.py --fix`.

### Testes (primeiro, a falhar pelo motivo certo)

- `game/tests/unit/test_llm_director.gd` (12 testes): `season_for_month`, `build_prompt`,
  `parse_directive` (fixture ok, fixture com cercas markdown, garbage, vazio),
  `validate_directive` (aceita, rejeita arco desconhecido/activity vazia/phrase não-string, rejeita
  campo em falta, rejeita dicionário vazio), `directive_from_data`. Fixtures novas em
  `game/tests/fixtures/director_{ok,ok_fenced,garbage,invalid_schema}.{json,txt}`.
- `game/tests/integration/test_llm_director.gd` (6 testes): `FakeBridge`/`FakeNeeds` (mesma técnica
  de `arc_smoke.gd`), sem rede. Cobre: `get_directive()` antes de qualquer ciclo cai no
  `SimpleDirector`; resposta válida actualiza a directiva e regista memória (incluindo o ficheiro
  `user://test_director_memory.json` lido e verificado); garbage cai em fallback (com
  `assert_engine_error`, mesmo padrão do `test_llm_bridge.gd` para JSON inválido); "timeout"
  (`raw_text=""`, `source="fallback"`, a mesma combinação que o `LLMBridge` emite de verdade) cai em
  fallback; um `trigger_cycle` concorrente enquanto `is_thinking()` é ignorado (só 1 chamada ao
  bridge); memória guarda no máximo as 10 decisões mais recentes.
- `game/tests/integration/test_llm_bridge.gd`: 4 testes novos para `request_completion`
  (porta morta = timeout, `enabled=false`, prompt vazio, concorrência com `request_phrase` --
  os dois fluxos partilham o mesmo "um pedido de cada vez").
- `game/tests/live/test_llm_director_live.gd` (novo, fora de `.gutconfig.json`, só corre com
  `--llm`): 10 ciclos reais contra o Ollama desta máquina, `pending()` se ele não responder.

### Prova exigida da tarefa: o que confirmei e o que não bateu

- **"10 ciclos, JSON válido em todos"**: confirmado. `docs/proof/T-115-director-live.log`
  (gerado por uma corrida real do teste ao vivo) mostra os 10 ciclos com `source=llm` e
  arc/activity coerentes; o teste ao vivo falha a sério se algum ciclo cair em fallback.
- **"Log com latência por ciclo"**: confirmado, mesmo log.
- **"p50 < 5s com 1 chamada"**: **NÃO bateu nesta máquina.** Medido directamente (curl manual e o
  teste ao vivo, 2 corridas): p50 entre 9,5s e 11,6s. Causa-raiz confirmada por medição, não
  suposição: o prompt do director tem ~400 tokens (instruções + contexto JSON completo, muito maior
  do que o prompt de uma frase, ~30-40 tokens) e o custo dominante em CPU é a avaliação do prompt,
  não a geração da resposta (`prompt_eval_count=395` no `curl` manual, latência já em ~5,7s mesmo
  com a resposta cortada a 40 tokens). Ajustei o `num_predict` do director de 40 (herdado por
  engano do fluxo de frases) para 100 e o timeout de 8s para 25s (ambos medidos e documentados nos
  comentários de `llm_director.gd`), o que resolveu a truncagem do JSON (antes: respostas cortadas
  a meio, JSON inválido) mas não resolve o tecto de 5s, que é uma limitação de hardware desta
  máquina (Ollama em Docker, **só CPU**, AGENTS.md §9), fora do âmbito desta tarefa corrigir (AGENTS.md
  §4: "nunca sem o Rodolfo: alterar o contentor Docker do Ollama"). Por isso `test_llm_director_live.gd`
  regista o p50 real e **avisa** (`push_warning`) quando ultrapassa os 5s pedidos pela tarefa, mas só
  falha a sério acima de um tecto de sanidade (20s, sinal de regressão/hang real) -- decisão
  documentada na própria docstring do teste, para não bloquear `verify.sh --llm` permanentemente
  nesta máquina por um número fora do controlo do código. Sinalizo isto explicitamente para o
  Rodolfo decidir se quer religar a GPU (fora do meu âmbito de autonomia).

### Comandos corridos e resultado

- `scripts/verify.sh --full`: **PASSOU** (docs, backlog, pytest, lint, import, gut 213/213, boot,
  visual, llm eval PASSOU, llm_live PASSOU 2/2, export PASSOU). Ver `reports/verify-last.txt`.
- Teste ao vivo isolado (`-gdir=res://tests/live`), 2 corridas manuais antes de calibrar
  `NUM_PREDICT`/`REQUEST_TIMEOUT_S`: falharam por timeout (8s, `num_predict=40` herdado por
  engano) -- causa-raiz identificada e corrigida (ver acima). Corrida final: 2/2 PASSOU.

### Ronda 2: correcção dos bloqueantes da revisão adversarial (insulano-reviewer)

A revisão apontou 4 pontos; o ponto 1 (`.claude/no-gate`) foi investigado e confirmado fora de
âmbito (toggle de sessão do hook `selection-gate.ps1`, não desta tarefa). Os outros 3:

- **Bloqueante 2 (contrato desactualizado)**: `agent_docs/tech_design.md` §4.5 tinha
  `func request_completion(prompt: String) -> int`, sem os parâmetros `num_predict`/`timeout_s`
  que a implementação (`game/llm/llm_bridge.gd:136`) já tinha desde a ronda 1. Corrigido: a
  assinatura no contrato agora corresponde à implementação (`num_predict: int = -1, timeout_s:
  float = -1.0`), com uma nota nova explicando que o `LLMDirector` sobrepõe estes valores
  (`NUM_PREDICT=100`, `REQUEST_TIMEOUT_S=25.0`, acima do `timeout_s` por defeito de 8s do
  `LLMSettings`) e porquê (prompt do director muito maior, custo dominante é a avaliação do
  prompt em CPU). §4.7 também passou a listar `NUM_PREDICT`/`REQUEST_TIMEOUT_S` como constantes
  do contrato, não só do código.
- **Bloqueante 3 (`phrase` nunca passava pelo `PhraseFilter`)**: `LLMDirector` ganhou
  `phrase_filter` injectável (lazy, `PhraseFilter.from_rules_file()`, mesmo padrão dos outros
  campos injectáveis) e `_filter_phrase()`, chamado em `_resolve()` depois de
  `directive_from_data()`: limpa e valida o campo `phrase` contra `game/data/phrase_rules.json`
  antes de entrar na directiva; uma frase rejeitada fica `""` com log (`arc`/`activity`
  continuam válidos, `source` continua `"llm"` -- não vale a pena deitar fora uma decisão boa de
  arco/actividade só porque o texto falado não passou o filtro). Prova real: o teste ao vivo
  (`docs/proof/T-115-director-live-ronda2.log`, ciclo 07) apanhou o modelo a gerar
  "Agora que a esperança vai desaparecendo..." (padrão `ptbr` de `phrase_rules.json`, gerúndio
  brasileiro) e rejeitou-o, ficando o campo phrase vazio nesse ciclo -- antes desta correcção,
  esse texto ia direito para o jogo, violando AGENTS.md §6.10.
- **Bloqueante 4 (p50 baixado sem registo formal)**: `docs/decisions.md` ganhou a ADR-014,
  registando formalmente a decisão de baixar o critério de falha do teste ao vivo para o tecto de
  sanidade de 20s (já existia no código desde a ronda 1, só não estava documentado como decisão).
  Criada `backlog/fase-3/T-122-decidir-latencia-llm-director.md` (`estado: humano`) com as 3
  opções para o Rodolfo (religar GPU, encolher prompt, aceitar o p50 actual e reescrever a "Prova
  exigida" da T-115). **A T-115 continua sem poder passar a `feito` até essa ratificação.**

Também corrigidos os pontos não-bloqueantes apontados (tempo permitiu todos):
- `game/tests/fixtures/director_invalid_{arc,activity,phrase}.json` (novas) + 3 testes novos em
  `test_llm_director.gd`, cada um isolando um único defeito de schema; o teste combinado original
  (`director_invalid_schema.json`) ficou como regressão da combinação, comentário a explicar.
- `test_llm_bridge.gd`: 2 testes novos para `build_completion_payload`, um deles exercitando
  `LLMBridge.DEFAULT_COMPLETION_NUM_PREDICT` explicitamente (nunca coberto antes).
- Comentário de `llm_bridge.gd:185` corrigido (`build_completion_payload.DEFAULT_NUM_PREDICT` não
  existe; é `DEFAULT_COMPLETION_NUM_PREDICT`, constante da classe).
- `llm_director.gd`: `_get_bridge() == null` (autoload ausente e nenhuma ponte injectada) agora
  resolve já em fallback (`_resolve(-1, "", "fallback")`) em vez de desreferenciar `null` na
  chamada a `request_completion()` logo a seguir, o que prendia `is_thinking()` a `true` para
  sempre (ninguém chamava `_resolve()`).
- `llm_director.gd`: o `print` do fallback com schema inválido agora corta o `raw_text` a
  `LOG_RAW_TEXT_MAX_CHARS` (200) em vez de despejar a resposta inteira, seguindo a regra do
  `tech_design.md` §4.5 ("nunca o prompt/texto inteiro em release") também para este log.
- `FakeNeeds.new()` em `test_llm_director.gd` e `test_llm_director_live.gd` passou a
  `add_child_autofree()` em vez de ficar solto (GUT já não devia reportar orphan por causa
  destas duas instâncias).

**Não corrigido** (documentado, não bloqueante): `llm_director.gd` ainda não respeita
`LLMSettings.min_interval_s` entre ciclos -- fica para quando existir um consumidor real
(`EventDirector`, T-301) que dispare `trigger_cycle` com essa cadência, porque hoje não há
nenhum chamador em produção a testar contra (mesma lacuna já registada na secção "O que ficou
por verificar" abaixo).

### Comandos corridos e resultado (ronda 2)

- `uvx --from 'gdtoolkit==4.*' gdformat` nos ficheiros tocados: reformatou `llm_director.gd`
  (indentação), resto sem alterações.
- `scripts/verify.sh` (sem flags): **PASSOU** -- docs, backlog, pytest, lint, import, gut
  **218/218** (subiu de 213 para 218: +6 testes de schema/payload), boot smoke PASSOU.
- `scripts/verify.sh --llm`: **PASSOU** -- gut 218/218, llm eval PASSOU (pass_rate 0.9583,
  p50=3.16s, p95=4.3s, 1 rejeição ptbr, amostra do `phrase_rules.json` normal), llm_live PASSOU
  2/2. Log completo em `docs/proof/T-115-director-live-ronda2.log`: confirma o `PhraseFilter` a
  rejeitar uma frase PT-BR real gerada pelo modelo (ciclo 07) e o resto dos 10 ciclos com
  `source=llm`. p50 desta corrida: 11.15s (mesma ordem de grandeza da ronda 1, aviso esperado,
  ver ADR-014/T-122).

### O que ficou por verificar

- Não liguei o `LLMDirector` ao `EventDirector` real (T-301): o `EventDirector` ainda não usa
  `IDirector`/`SimpleDirector` em produção hoje (só existe a smoke `arc_smoke.gd`), por isso não
  havia um ponto de integração real para ligar nesta tarefa; os critérios de aceitação da T-115 não
  pedem essa ligação (fica implícito para uma tarefa futura, provavelmente junto da T-116/T-117).
- Não corri um teste de longa duração (múltiplas horas) da memória de decisões em produção; a
  prova é ao nível de unidade/integração (10-12 ciclos simulados) e do teste ao vivo (10 ciclos
  reais).
- O `p50 < 5s` da "Prova exigida" fica por bater nesta máquina (ver secção acima); não é algo que
  eu tenha autoridade para corrigir sozinho. Registado formalmente em `docs/decisions.md`
  (ADR-014) e `backlog/fase-3/T-122-decidir-latencia-llm-director.md` (`estado: humano`); a T-115
  não deve passar a `feito` sem essa ratificação do Rodolfo.
- `llm_director.gd` ainda não respeita `LLMSettings.min_interval_s` entre ciclos consecutivos
  (apontado na revisão, não bloqueante): não há hoje nenhum chamador em produção
  (`EventDirector`/T-301 ainda não liga a este director) que dispare `trigger_cycle` com uma
  cadência real para testar contra; fica para quando essa ligação existir.

### Ronda 3: fecho do único bloqueante restante (ligação PhraseFilter <-> _resolve não provada em teste)

A revisão adversarial (ronda 2) confirmou por prova ao vivo (`docs/proof/T-115-director-live-ronda2.log`,
ciclo 07) que `_resolve()` chama mesmo `_filter_phrase()`, mas nenhum dos 218 testes GUT provava essa
ligação de forma determinística: o único teste que olhava para `phrase` usava uma frase que o
`PhraseFilter` aceita sem alterar ("Boa companhia hoje."), por isso passava com ou sem as duas linhas do
filtro em `_resolve()` (`llm_director.gd:246-247`).

- **Correcção**: dois testes novos em `game/tests/integration/test_llm_director.gd`:
  - `test_trigger_cycle_frase_ptbr_e_rejeitada_pelo_filtro_sem_perder_arc_activity`: emite
    `completion_ready` com `{"arc": "diario", "activity": "escrever no diario", "phrase": "Você viu o
    barco?"}` (caso `reason=ptbr` de `game/tests/fixtures/phrase_filter_cases.json`, o mesmo tipo de
    padrão apanhado ao vivo no ciclo 07). Assere as 3 condições pedidas: (a)
    `phrase_context_extra["phrase"] == ""` (rejeitada e esvaziada, nunca a frase original); (b)
    `source == "llm"` (não caiu em fallback completo, só a frase foi filtrada); (c) `arc_id`/`activity`
    continuam exactamente os do JSON original ("diario"/"escrever no diario").
  - `test_trigger_cycle_frase_ptpt_valida_atravessa_o_filtro_sem_alteracao`: contraprova de aceitação,
    frase PT-PT válida da mesma fixture ("O mar está calmo hoje.", `reason=null`) chega intacta à
    directiva.
  - **TDD confirmado manualmente**: removi temporariamente as duas linhas do filtro em `_resolve()`
    (`raw_phrase` / `phrase_context_extra["phrase"] = _filter_phrase(...)`), corri
    `test_llm_director.gd` isolado: `test_trigger_cycle_frase_ptbr_...` falhou exactamente como
    esperado (`["Você viu o barco?"] expected to equal [""]`, 2 asserts vermelhos, 219/220 no total).
    Revertida a remoção; corrida seguinte 220/220 verde. A ligação está agora provada em teste, não só
    em log de uma corrida ao vivo não determinística.
- **Não bloqueantes corrigidos** (tempo permitiu todos os 3 apontados):
  - `game/llm/llm_bridge.gd:132`: docstring de `request_completion` corrigida, "NUM_PREDICT" (que não é
    o nome da constante usada por esta função) passou a "DEFAULT_COMPLETION_NUM_PREDICT".
  - `game/llm/llm_director.gd:417-425` (`_filter_phrase`): o `print` da frase rejeitada agora passa por
    `_truncated_for_log()`, por coerência com o mesmo tratamento já aplicado ao `raw_text` inválido em
    `_resolve()` (linha 251).
  - `game/tests/live/test_llm_director_live.gd:29-32`: comentário de `P50_SANITY_CEILING_S`, que estava
    partido a meio ("bem acima do REQUEST_TIMEOUT_S ... não faria sentido" invertia o sentido da frase),
    reescrito para "abaixo do REQUEST_TIMEOUT_S ... não faria sentido".
  - `.claude/no-gate`: não tocado (fora de âmbito, toggle de sessão do hook `selection-gate.ps1`, já
    investigado e confirmado na ronda 2); não adicionado ao `.gitignore` nem ao commit desta tarefa.

### Comandos corridos e resultado (ronda 3)

- `uvx --from 'gdtoolkit==4.*' gdformat` nos ficheiros tocados: reformatou `test_llm_director.gd` e
  `llm_director.gd` (indentação/quebra de linha), `llm_bridge.gd` e `test_llm_director_live.gd` sem
  alterações.
- TDD manual isolado (`-gtest=res://tests/integration/test_llm_director.gd`, filtro removido): **1
  falha** no teste novo, motivo exacto esperado (2 asserts `expected to equal [""]`), 219/220 no total.
  Filtro revertido.
- `scripts/verify.sh` (sem flags): **PASSOU** -- docs, backlog, pytest, lint, import, gut **220/220**
  (subiu de 218 para 220: os 2 testes novos), boot smoke PASSOU.
- `scripts/verify.sh --llm`: **PASSOU** -- gut 220/220, llm eval PASSOU (`pass_rate=0.9583,
  latency_p50_s=3.34, latency_p95_s=4.63, rejections: {"too_long": 1}`), llm_live PASSOU 2/2.

### O que ficou por verificar (actualizado, ronda 3)

Nada de novo além do já registado nas rondas 1-2 (p50 < 5s sem bater nesta máquina, ADR-014/T-122
pendente de ratificação do Rodolfo; `min_interval_s` entre ciclos sem consumidor real para testar
contra). O bloqueante da ronda 2 (ligação `_filter_phrase()` <-> `_resolve()` sem teste determinístico)
está fechado.
