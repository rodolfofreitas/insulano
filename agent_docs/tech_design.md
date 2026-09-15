# Tech Design: Insulano

Versão 1.0, 2026-09-13. Contratos de cada componente: nomes, sinais, settings e dados.
Um agente que implementa uma tarefa segue estes contratos à letra; se precisar de os
mudar, muda este documento **no mesmo commit** e explica no Relatório da tarefa.

Estado de cada componente: `existe` (no código hoje) ou `planeado` (tarefa indicada).

---

## 1. Princípios de desenho

1. **Jogo primeiro, IA depois.** O personagem vive sem LLM; o LLM só dá voz. Se o Ollama cair,
   ninguém repara, a não ser pelas frases repetidas.
2. **Núcleo puro, casca fina.** Toda a lógica decidível (cor por hora, Páscoa, filtro de frases,
   montagem do prompt) vive em funções `static` ou `RefCounted` sem árvore de cena, testáveis em GUT
   em milissegundos. Nós de cena só ligam sinais e desenham.
3. **Uma porta por sistema externo.** Ollama só pelo `LLMBridge`; wttr.in só pelo `WeatherService`;
   relógio só pelo `GameClock`. Cada porta tem a sua costura de teste.
4. **Dados fora do código.** Prompt, regras, feriados, eventos, paletas e códigos meteorológicos em
   `game/data/*.json|txt`.

## 2. Autoloads

| Nome do autoload | Script | class_name | Tarefa | Estado |
|---|---|---|---|---|
| `LLM` | `game/llm/llm_bridge.gd` | `LLMBridge` | T-105 | planeado |
| `Clock` | `game/world/game_clock.gd` | `GameClock` | T-201 | planeado |
| `Events` | `game/events/event_director.gd` | `EventDirector` | T-301 | planeado |
| `Weather` | `game/world/weather_service.gd` | `WeatherService` | T-304 | planeado |
| `Screensaver` | `game/app/screensaver_mode.gd` | `ScreensaverMode` | T-501 | planeado |
| `BeehaveGlobalMetrics`, `BeehaveGlobalDebugger` | addon Beehave | - | herdado | existe |

## 3. Settings (ProjectSettings, prefixo `insulano/`)

Valores por defeito em `game/project.godot`. O utilizador pode sobrepor em `user://settings.cfg`
(secção igual ao segundo segmento, ex.: `[llm] model="..."`). Leitura centralizada no `LLMSettings`
(T-101) e equivalentes; nenhum outro script lê `ProjectSettings` com prefixo `insulano/`.

| Chave | Tipo | Defeito | Usado por |
|---|---|---|---|
| `insulano/llm/enabled` | bool | `true` | LLMBridge |
| `insulano/llm/url` | String | `http://127.0.0.1:11434` | LLMBridge |
| `insulano/llm/model` | String | `llama3.1:8b` | LLMBridge, llm_eval.py |
| `insulano/llm/timeout_s` | float | `8.0` | LLMBridge (igual a `timeout_s` em phrase_rules.json) |
| `insulano/llm/min_interval_s` | float | `30.0` | SayGeneratedAction (valores abaixo de 3 s sobem a 3 s, o piso `MIN_VISIBLE_S`, ver §4.6) |
| `insulano/debug/fake_time` | String | `""` | GameClock |
| `insulano/events/seed` | int | `0` (0 = aleatório) | EventDirector |
| `insulano/weather/enabled` | bool | `false` | WeatherService (defeito decidido na T-306, humano) |
| `insulano/weather/location` | String | `""` | WeatherService |

Variáveis de ambiente de teste (têm precedência sobre settings): `INSULANO_FAKE_TIME`
(`2026-12-25T21:30`), `INSULANO_FAKE_WEATHER` (`rain`), `INSULANO_LLM_URL`.

## 4. Camada LLM (Fase 1)

### 4.1 `LLMSettings` (T-101), `game/llm/llm_settings.gd`, RefCounted

```gdscript
class_name LLMSettings
static func load_settings(cfg_path: String = "user://settings.cfg") -> LLMSettings   ## env > .cfg > ProjectSettings
var enabled: bool
var url: String
var model: String
var timeout_s: float
var min_interval_s: float
```

### 4.2 `PhraseContext` e `PromptBuilder` (T-102)

```gdscript
# game/llm/phrase_context.gd
class_name PhraseContext extends RefCounted
var hour: int                 ## 0-23
var period: String            ## "madrugada" | "manhã" | "tarde" | "fim da tarde" | "noite"
var action: String            ## verbo no infinitivo com complemento: "pescar", "comer um peixe"
var hunger_label: String      ## "satisfeito" | "com fome" | "esfomeado"
var weather: String           ## texto pt-PT: "sol", "chuva forte", ...
var holiday: String           ## nome do feriado ou "nenhuma"
func to_template_fields() -> Dictionary   ## chaves: hour, period, action, hunger, weather, holiday

# game/llm/prompt_builder.gd
class_name PromptBuilder extends RefCounted
static func build(template: String, context: PhraseContext) -> String
static func load_template() -> String     ## res://data/prompts/phrase_prompt.txt
static func hunger_label_for(percentage: float) -> String   ## >60 satisfeito, >25 com fome, resto esfomeado
```

O template usa `{campo}` (compatível com `String.format` do Godot e `str.format` do Python).
Campo em falta é erro, nunca prompt com chavetas por preencher.

### 4.3 `PhraseFilter` (T-103), `game/llm/phrase_filter.gd`, RefCounted

```gdscript
class_name PhraseFilter extends RefCounted
static func from_rules_file(path: String = "res://data/phrase_rules.json") -> PhraseFilter
func clean(raw: String) -> String              ## primeira linha, sem aspas nem espaços nas pontas
func rejection_reason(text: String) -> String  ## "" se aceite; senão empty|english|ptbr|forbidden|too_short|too_long|rules_missing
```

Paridade obrigatória com `scripts/llm_eval.py`: o teste GUT percorre
`game/tests/fixtures/phrase_filter_cases.json`, o mesmo ficheiro que o pytest usa.

`rules_missing` é o único dos sete valores sem equivalente no lado Python: sai quando
`from_rules_file` não conseguiu ler ou interpretar `phrase_rules.json` (motor a correr, ficheiro
de dados em falta ou inválido); nesse caso o filtro falha FECHADO e rejeita sempre, antes de
qualquer outra verificação. `scripts/llm_eval.py` não tem este estado porque falha alto
(excepção) se `phrase_rules.json` não existir, em vez de continuar a correr sem regras.

### 4.4 `FallbackPhrases` (T-104), `game/llm/fallback_phrases.gd`, RefCounted

```gdscript
class_name FallbackPhrases extends RefCounted
static func from_file(path: String = "res://data/phrases_fallback.json") -> FallbackPhrases
func pick(category: String) -> String   ## categoria inexistente cai em "idle"; nunca repete a última frase da categoria
func categories() -> PackedStringArray
```

### 4.5 `LLMBridge` (T-105), autoload `LLM`, Node

```gdscript
class_name LLMBridge extends Node
signal phrase_ready(request_id: int, text: String, source: String)   ## source: "llm" | "fallback"
signal completion_ready(request_id: int, raw_text: String, source: String)   ## T-115, ver abaixo
func request_phrase(context: PhraseContext, fallback_category: String) -> int
func request_completion(prompt: String, num_predict: int = -1, timeout_s: float = -1.0) -> int   ## T-115, ver abaixo
func is_busy() -> bool
static func build_payload(model: String, prompt: String) -> Dictionary
static func parse_response(result: int, response_code: int, body: PackedByteArray) -> String  ## "" em qualquer falha
```

Contrato de comportamento:

- Um pedido de cada vez, partilhado pelos DOIS fluxos (`request_phrase` e `request_completion`, ver
  abaixo): pedido novo com um em curso (de qualquer um dos dois) responde já com fallback
  (`source = "fallback"`).
- `HTTPRequest` filho com `timeout = timeout_s`. Falha de rede, código diferente de 200, JSON inválido,
  resposta vazia ou rejeitada pelo `PhraseFilter`: emite fallback. Nunca emite texto rejeitado.
  `request_completion` pode sobrepor este `timeout_s` e o `num_predict` do payload por chamada
  (parâmetros `timeout_s`/`num_predict`, ambos com defeito `<= 0` = "usa o valor de `LLMSettings`/
  `DEFAULT_COMPLETION_NUM_PREDICT`"): o `LLMDirector` (T-115) usa sempre `num_predict=100` e
  `timeout_s=25.0` (`LLMDirector.NUM_PREDICT`/`REQUEST_TIMEOUT_S`), acima do `timeout_s` por
  defeito de `LLMSettings` (8 s, calibrado para uma frase curta), porque o prompt do director
  (~400 tokens de contexto) demora muito mais a avaliar em CPU do que o prompt de uma frase
  (~30-40 tokens); números medidos e o porquê em `backlog/fase-3/T-115-llm-director.md`,
  secção Relatório.
- `enabled = false`: emite sempre fallback, sem abrir sockets.
- O sinal é emitido sempre, exactamente uma vez por `request_id`, mesmo em erro.
- Log com prefixo `[Insulano/LLM]`: modelo, latência, motivo de fallback. Nunca o prompt inteiro em release.
- Payload: `{"model", "prompt", "stream": false, "keep_alive": "10m", "options": {"temperature": 0.8, "top_p": 0.9, "num_predict": 40}}`.

`request_completion(prompt, num_predict=-1, timeout_s=-1.0)` (T-115, para o `LLMDirector`): pedido genérico ao Ollama, sem
`PromptBuilder` nem `PhraseFilter` nem `FallbackPhrases` -- o chamador já traz o prompt pronto e
recebe o texto cru da resposta via `completion_ready`. `source = "llm"` só quando a resposta chegou
com sucesso (HTTP 200, JSON válido, corpo com `response` não vazio); em qualquer outra falha
(desligado, pedido concorrente, prompt vazio, erro de rede, timeout, JSON inválido, HTTP != 200),
`raw_text = ""` e `source = "fallback"` -- ao contrário de `request_phrase`, não há aqui nenhuma
frase de recurso: quem chama decide o próprio fallback (o `LLMDirector` cai no `SimpleDirector`).

### 4.6 Integração na behavior tree (T-106) e balão (T-107)

- `game/beehave/say_generated_action.gd`, `class_name SayGeneratedAction extends ActionLeaf`:
  substitui o `TalkAction` fixo. Primeiro tick pede a frase e devolve `RUNNING`; quando o sinal chega
  com o seu `request_id`, escreve `character.talking_text` e devolve `SUCCESS`. Respeita um intervalo
  EFECTIVO entre frases (`maxf(min_interval_s, MIN_VISIBLE_S)`, nunca `min_interval_s` sozinho); se
  ainda não passou, devolve `SUCCESS` sem tocar em `character.talking_text`, nem para falar nem para o
  limpar (T-107: quem manda no desaparecimento do balão é o `SpeechBubble` abaixo, nunca esta classe;
  até à T-106 esta classe limpava o balão aqui mesmo depois de `MIN_VISIBLE_S`, um padrão "fala antes,
  limpa depois" copiado do `TalkAction` da base, mas isso deixava dois donos da mesma duração quando o
  `SpeechBubble` passou a ter a sua própria). Diferença para a base: a base nunca fazia o nó de fecho
  falar, só limpava; esta classe faz os dois nós de cada sequência falarem. O relógio
  (`Time.get_ticks_msec` por defeito) é injectável (`clock: Callable`) para os testes controlarem o
  tempo sem esperar segundos reais.
  `MIN_VISIBLE_S` (3 s) é o piso desse intervalo efectivo: o `SpeechBubble` substitui o texto sem
  condição em `show_text()` (nunca espera que a frase anterior tenha ficado visível o suficiente), por
  isso a garantia de "nenhuma frase visível menos de 3 s" só é verdadeira se `tick()` nunca pedir uma
  frase nova antes de `MIN_VISIBLE_S` desde a anterior, mesmo que `LLMSettings.min_interval_s` venha
  configurado (via `user://settings.cfg`, sem limite nenhum) com um valor menor, incluindo 0; por isso
  a garantia vale para QUALQUER `min_interval_s` configurado, não só para valores sensatos (bloqueante
  da revisão da T-107, ronda 1, com prova por mutação em `backlog/fase-1/T-107-speech-bubble.md`).
  `MIN_VISIBLE_S` tem de continuar igual a `SpeechBubble.MIN_SECONDS` (testado em
  `test_speech_bubble.gd`), senão os dois números podem divergir sem ninguém notar. `interrupt()`
  esquece o pedido em curso
  (`_awaiting_request_id`/`_has_result`), para uma resposta tardia de um pedido interrompido nunca
  resolver com um contexto que já não é o actual; não chama `super.interrupt()` de propósito: o
  `super` só notifica o depurador visual do Beehave e, a correr sem depurador activo (headless,
  testes), imprime um `ERROR` que o GUT conta como erro inesperado; a execução não aborta
  (AGENTS.md §10, ruído conhecido). Monta o `PhraseContext` a partir do blackboard (`current_action`),
  da fome e do `Clock`/`Weather` quando existirem.
- `game/beehave/go_to_usable_action.gd`, `@export var current_action_label: String`: verbo em pt-PT
  a escrever em `current_action` enquanto este nó anda, para a `SayGeneratedAction` que segue na
  mesma sequência nunca ler o verbo deixado por uma sequência anterior. Vazio (defeito) não escreve
  nada. Em `guy.tscn`: "ir comer" (sequência de comer), "ir pescar" (sequência de pesca) e "passear"
  (sequência de passear, único verbo dessa sequência).
- `game/ui/speech_bubble.gd`, `class_name SpeechBubble extends PanelContainer` (T-107): fundo branco
  opaco (`bg_color` alfa 1.0) com texto quase preto, contraste 18,4:1 pela luminância relativa WCAG
  (muito acima do mínimo de 4,5:1), legível sobre a água azul e a relva verde da ilha; largura máxima
  `MAX_WIDTH` (220 px do mundo) com `autowrap_mode = AUTOWRAP_WORD_SMART` no `Label` interno, para uma
  frase longa quebrar linha em vez de sair do ecrã. Quem manda na duração é este nó, não quem lhe pede
  para falar: `show_text(texto)` escreve o texto, redimensiona o balão ao conteúdo
  (`reset_size()`) e agenda o próprio desaparecimento via `display_seconds_for(texto)`
  (`clamp(2.5 + 0.35 * palavras, 3, 9)` segundos, contagem de palavras com o mesmo padrão `(*UCP)\S+`
  de `PhraseFilter`); `check_hide()` (chamado a cada `_process`, e directamente pelos testes com um
  `clock` injectado) esconde-o quando o relógio passa desse instante. `Character.talking_text`
  (`game/character/character.gd`) só chama `show_text()`; `SayGeneratedAction` nunca conhece o
  `SpeechBubble` directamente. Depois de `reset_size()`, `position` é recalculada explicitamente
  (`Vector2(-size.x / 2.0, BOTTOM_OFFSET - size.y)`) para o balão crescer para CIMA quando precisa de
  mais linhas: `reset_size()`, chamado a partir de código, cresce sempre a partir do canto superior
  esquerdo do rectângulo actual (para baixo), sem respeitar `grow_vertical`; sem esta correcção o
  balão crescia por cima do próprio personagem, escondendo-o (bug apanhado por inspecção visual,
  corrigido antes da versão final de `docs/proof/T-107-balao-1080p.png`).

### 4.7 `LLMDirector` (T-115), `game/llm/llm_director.gd`, Node

```gdscript
class_name LLMDirector extends Node
signal directive_ready(directive: DirectorDirective, source: String)   ## source: "llm" | "fallback"
const TRIGGER_ACTIVITY_COMPLETED: String = "activity_completed"
const TRIGGER_NEED_THRESHOLD: String = "need_threshold_crossed"
const TRIGGER_SESSION_START: String = "session_start"
const NUM_PREDICT: int = 100        ## sobrepõe request_completion(num_predict), medido nesta máquina
const REQUEST_TIMEOUT_S: float = 25.0   ## sobrepõe request_completion(timeout_s), > LLMSettings.timeout_s (8s)
func get_directive() -> DirectorDirective   ## contrato IDirector, duck typing como o SimpleDirector
func is_available() -> bool                 ## sempre true: fallback garantido
func is_thinking() -> bool
func trigger_cycle(reason: String) -> void  ## 1 única chamada ao LLM (LLM.request_completion) por ciclo
func set_last_event(event: String) -> void
static func season_for_month(month: int) -> String
static func build_prompt(template: String, context: Dictionary) -> String
static func parse_directive(raw_text: String) -> Dictionary   ## {} em qualquer falha de parsing
static func validate_directive(data: Dictionary) -> bool      ## schema {arc, activity, phrase}
static func directive_from_data(data: Dictionary) -> DirectorDirective
```

Substitui o `SimpleDirector` (T-111) via `IDirector`, sem mudar quem o consome: `get_directive()`
continua síncrono. Como o pedido ao LLM é assíncrono, `get_directive()` devolve sempre a última
directiva de um ciclo já terminado (ou a de um `SimpleDirector` interno, antes do primeiro ciclo
terminar); `trigger_cycle(reason)` é quem dispara um ciclo novo, chamado por quem gere o jogo quando
um dos três `TRIGGER_*` acontece (fim de actividade, cruzamento de limiar de necessidade, início de
sessão) -- não há `_process` a fazer polling. Um `trigger_cycle` novo enquanto `is_thinking()` é
verdadeiro é ignorado: nunca duas chamadas simultâneas ao Ollama.

Contexto enviado (critério de aceitação da T-115): `{gatilho, dia, hora, estacao, necessidades,
arco_activo, arcos_recentes (5 títulos), companheiro (sempre null até à T-118), ultimo_evento}`.
`estacao` vem de `season_for_month` (hemisfério norte: Dez-Fev inverno, Mar-Mai primavera, Jun-Ago
verão, Set-Nov outono). O prompt (`game/data/prompts/director_prompt.txt`) usa o marcador literal
`{{CONTEXTO}}` (não `String.format`, que colidiria com as chavetas do exemplo JSON no próprio
texto); `build_prompt` substitui-o pelo contexto em JSON.

Resposta esperada: `{"arc", "activity", "phrase"}`. `parse_directive` aceita a resposta envolvida em
cercas markdown (```` ```json ... ``` ````, comum no `llama3.1:8b` apesar do prompt pedir só JSON) e
devolve `{}` em qualquer JSON inválido ou que não seja objecto. `validate_directive` exige `arc`
numa das 5 constantes de arco do `SimpleDirector` (`ARC_JANGADA`, `ARC_COMPANHEIRO`,
`ARC_SINALIZACAO`, `ARC_DIARIO`, `ARC_AVULSO`, fonte única, sem duplicar a lista), `activity` String
não vazia e `phrase` String (pode ser vazia). `validate_directive` só confirma o TIPO de `phrase`;
o CONTEÚDO passa pelo mesmo `PhraseFilter` (§4.3) do `LLMBridge` antes de entrar na directiva
(`phrase_filter`, injectável, lazy via `PhraseFilter.from_rules_file()`): uma frase rejeitada
(inglês, PT-BR, proibida, fora dos limites de palavras/caracteres) fica `""` com log, mas `arc`/
`activity` continuam válidos e `source` continua `"llm"` -- rejeitar a directiva inteira por causa
só do texto falado desperdiçaria uma decisão de arco/actividade boa. Qualquer falha -- `completion_ready` com
`source = "fallback"`, JSON inválido, ou schema inválido -- resolve com `fallback_director.get_directive()`
(um `SimpleDirector` injectável, lazy por defeito) e `source = "fallback"` no sinal `directive_ready`.

Memória: as últimas 10 decisões (`{arc, activity, source, timestamp}`) em `memory_path` (por defeito
`user://director_memory.json`, sobreponível nos testes), escrita atómica tmp + rename, mesmo padrão
de `game/world/arc_history.gd`.

## 5. Tempo e ambiente (Fase 2)

- `GameClock` (T-201): `now() -> Dictionary` (formato de `Time.get_datetime_dict_from_system()`),
  `hour_float() -> float`, `period() -> String`, `signal hour_changed(hour: int)`.
  Períodos: madrugada [0,6), manhã [6,12), tarde [12,17), fim da tarde [17,20), noite [20,24).
- `DayNight` (T-202), `CanvasModulate`: `static func color_for_hour(hour: float) -> Color`, interpolação
  linear entre os pontos de `game/data/day_night_palette.json` (`[{"hour": 0.0, "color": "#1b2140"}, ...]`, cíclico).
- Energia e sono (T-203): `Need` `energy` no personagem; `IsNightCondition` (período noite ou madrugada)
  e `SleepAction` (animação e recuperação de energia). O ramo de dormir tem prioridade sobre passear.
- `NightSky` (T-204): estrelas e lua desenhadas com `_draw()`, alfa ligado à hora.

## 6. Eventos e clima (Fase 3)

- `ArcManager` (T-114), `game/llm/arc_manager.gd`, `RefCounted`: máquina de estados de
  fases dos arcos base, lida de `game/data/arc_definitions.json`
  (`arcs.<id> = {tipo, condicoes_activacao, fases: [{id, activities, effects}]}`; cada
  `activities` é uma lista de códigos reais de `docs/events-catalogue.md`, ex.: `R13`,
  `C16`, `MR06`, `L05`, nunca nomes livres inventados). `has_arc(id)`, `arc_type(id)`
  (`"CICLICO"`, `"UNICO"` ou `""`), `is_activation_condition_met(id, needs_manager)`
  (regras `min`/`max` por necessidade; dicionário vazio = sempre activável; guarda
  `has_method` antes de chamar `get_value`), `current_phase(id) -> Dictionary` (não
  avança; inclui `index` e `total`), `advance_phase(id, needs_manager) -> Dictionary`
  (aplica `effects` da fase actual ao `needs_manager` por `get_value`/`set_value`,
  devolve essa fase e avança o índice; arcos `CICLICO` voltam a 0 depois da última
  fase; arcos `UNICO` ficam parados no último índice e não reaplicam efeitos nas
  chamadas seguintes, que devolvem `{}`), `is_finished(id) -> bool` (só fica `true`
  para arcos `UNICO` depois de `advance_phase` processar a última fase),
  `reset_phase(id)` (volta ao índice 0 e limpa `is_finished`). Os 3 arcos base, todos
  `CICLICO`: "A Jangada" (5 fases, ESPERANCA +30 na 1a fase, TEDIO -30 na fase
  `construir`, ESPERANCA -40 na fase `afunda`), "O Companheiro" (4 fases,
  `condicoes_activacao = {SOLIDAO: {min: 70}}`), "A Sinalização" (4 fases, ESPERANCA
  -20 na fase `barco_passa_sem_parar`). `SimpleDirector` (T-111) usa uma instância
  (injectável via `arc_manager`, lazy por defeito) para avançar a fase do arco
  escolhido em cada `get_directive()`, sobrepondo a `activity` e escrevendo `fase_id`/
  `fase_index` em `phrase_context_extra`; a activação do arco "companheiro" pergunta a
  este `ArcManager` (`is_activation_condition_met`) em vez de repetir o limiar SOLIDAO
  >= 70 numa constante própria, fonte única em `arc_definitions.json`. A escolha de
  frase (`_pick_phrase`) e de actividade de fase usam um `RandomNumberGenerator`
  injectável (`director.rng`), costura de teste para determinismo (AGENTS.md §6.6).
- `EventDirector` (T-301): `signal event_started(kind: String, data: Dictionary)`,
  `signal event_finished(kind: String)`; configuração em `game/data/events.json`
  (`kind`, `weight`, `min_interval_s`, `duration_s`); `RandomNumberGenerator` com seed de settings.
- Gaivota (T-302) e barco (T-303) escutam `event_started` e pedem frase ao `LLM` com a acção
  "ver uma gaivota a passar" ou "ver um barco ao longe".
- `WeatherService` (T-304): `current() -> String` em `clear | clouds | rain | storm | snow | unknown`,
  `signal weather_changed(condition: String)`. `GET https://wttr.in/{location}?format=j1`,
  `current_condition[0].weatherCode` traduzido por `game/data/weather_codes.json`. Timeout 3 s,
  refresh de hora a hora, `unknown` em qualquer falha. Desligado por defeito.
- `Rain` (T-305): partículas quando `rain` ou `storm`.

## 7. Feriados (Fase 4)

- `HolidayCalendar` (T-401): `static func easter_sunday(year: int) -> Dictionary` (algoritmo de
  Meeus/Butcher, devolve `{year, month, day}`), `static func holidays_on(date: Dictionary) -> Array`.
  Dados em `game/data/holidays.json`: `rule.type` `fixed` (`month`, `day`) ou `easter` (`offset_days`).
- Cenas (T-402): decoração e partículas por `scene` do feriado; frases do JSON misturadas com LLM.

## 8. Produto (Fase 5)

- `ScreensaverMode` (T-501): `--screensaver` põe fullscreen, esconde o cursor e sai com tecla ou rato
  movido mais de 8 px, depois de 1 s de graça; `--windowed` é o modo janela.
- No Linux quem decide quando arrancar é o hypridle (T-502, humano), ver ADR-009.

## 9. Orçamentos e limites

| Recurso | Limite | Porquê |
|---|---|---|
| Frame | 60 fps em modo protector, sem picos acima de 50 ms | um protector que engasga parece avariado |
| Pedidos ao LLM | no máximo 1 por `min_interval_s` (30 s) | o Ollama em CPU ocupa todos os núcleos ~3 s |
| Latência LLM | p50 até 4 s, p95 até 8 s (eval) | medido: p50 2,82 s, p95 4,42 s em CPU (ADR-006) |
| Rede externa | só wttr.in, desligado por defeito | privacidade (T-306) |

## 10. Direccao Visual

Direccao visual: ADR-013 (Stardew Valley + Graveyard Keeper). Ver docs/gauntlet/bars.md.
Nao imitar Johnny Castaway visualmente. JC = referencia de comportamento apenas.
Sprites do naufrago: ~32x48px. Paleta quente/tropical.

## 11. Costuras de teste

| Costura | Como se usa |
|---|---|
| `INSULANO_FAKE_TIME` | fixa o relógio para screenshots de noite, Natal, etc. |
| `INSULANO_FAKE_WEATHER` | força condição de clima sem rede |
| `INSULANO_LLM_URL=http://127.0.0.1:9` | nada a escutar: prova o fallback em integração |
| `seed()` e `insulano/events/seed` | comportamento repetível |
| `static func` puras | testes unitários sem cena |
| `game/tests/fixtures/` | respostas gravadas do Ollama e do wttr.in; os testes nunca usam rede |
