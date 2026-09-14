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
| `insulano/llm/min_interval_s` | float | `30.0` | SayGeneratedAction |
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
func request_phrase(context: PhraseContext, fallback_category: String) -> int
func is_busy() -> bool
static func build_payload(model: String, prompt: String) -> Dictionary
static func parse_response(result: int, response_code: int, body: PackedByteArray) -> String  ## "" em qualquer falha
```

Contrato de comportamento:

- Um pedido de cada vez. Pedido novo com um em curso: responde já com fallback (`source = "fallback"`).
- `HTTPRequest` filho com `timeout = timeout_s`. Falha de rede, código diferente de 200, JSON inválido,
  resposta vazia ou rejeitada pelo `PhraseFilter`: emite fallback. Nunca emite texto rejeitado.
- `enabled = false`: emite sempre fallback, sem abrir sockets.
- O sinal é emitido sempre, exactamente uma vez por `request_id`, mesmo em erro.
- Log com prefixo `[Insulano/LLM]`: modelo, latência, motivo de fallback. Nunca o prompt inteiro em release.
- Payload: `{"model", "prompt", "stream": false, "keep_alive": "10m", "options": {"temperature": 0.8, "top_p": 0.9, "num_predict": 40}}`.

### 4.6 Integração na behavior tree (T-106) e balão (T-107)

- `game/beehave/say_generated_action.gd`, `class_name SayGeneratedAction extends ActionLeaf`:
  substitui o `TalkAction` fixo. Primeiro tick pede a frase e devolve `RUNNING`; quando o sinal chega
  com o seu `request_id`, escreve `character.talking_text` e devolve `SUCCESS`. Respeita
  `min_interval_s` entre frases; se ainda não passou, devolve `SUCCESS` sem falar, e só limpa o balão
  (`character.talking_text = ""`) se a frase actual já esteve visível pelo menos `MIN_VISIBLE_S`
  (constante da classe, 3 s, o limite inferior do clamp de duração abaixo). Sem esta guarda, uma
  sequência que chega ao seu nó de abertura poucos frames depois de outra ter falado no nó de fecho
  apagava a frase mal ela aparecia. Diferença para a base: a base nunca fazia o nó de fecho falar,
  só limpava; esta classe faz os dois nós de cada sequência falarem. A garantia de 3 s visíveis só
  vale com `min_interval_s >= MIN_VISIBLE_S`: com um intervalo menor (possível através de
  `user://settings.cfg`), uma frase nova pode substituir a anterior antes dos 3 s. O relógio (`Time.get_ticks_msec`
  por defeito) é injectável (`clock: Callable`) para os testes controlarem o tempo sem esperar
  segundos reais. `interrupt()` esquece o pedido em curso (`_awaiting_request_id`/`_has_result`), para
  uma resposta tardia de um pedido interrompido nunca resolver com um contexto que já não é o actual;
  não chama `super.interrupt()` de propósito: o `super` só notifica o depurador visual do Beehave e,
  a correr sem depurador activo (headless, testes), imprime um `ERROR` que o GUT conta como erro
  inesperado; a execução não aborta (AGENTS.md §10, ruído conhecido). Monta o `PhraseContext` a
  partir do blackboard (`current_action`), da fome e do `Clock`/`Weather` quando existirem.
- `game/beehave/go_to_usable_action.gd`, `@export var current_action_label: String`: verbo em pt-PT
  a escrever em `current_action` enquanto este nó anda, para a `SayGeneratedAction` que segue na
  mesma sequência nunca ler o verbo deixado por uma sequência anterior. Vazio (defeito) não escreve
  nada. Em `guy.tscn`: "ir comer" (sequência de comer), "ir pescar" (sequência de pesca) e "passear"
  (sequência de passear, único verbo dessa sequência).
- `game/ui/speech_bubble.gd`, `class_name SpeechBubble extends PanelContainer`: fundo legível sobre
  água e relva, largura máxima com quebra de linha, duração visível `clamp(2.5 + 0.35 * palavras, 3, 9)` segundos.

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

## 10. Costuras de teste

| Costura | Como se usa |
|---|---|
| `INSULANO_FAKE_TIME` | fixa o relógio para screenshots de noite, Natal, etc. |
| `INSULANO_FAKE_WEATHER` | força condição de clima sem rede |
| `INSULANO_LLM_URL=http://127.0.0.1:9` | nada a escutar: prova o fallback em integração |
| `seed()` e `insulano/events/seed` | comportamento repetível |
| `static func` puras | testes unitários sem cena |
| `game/tests/fixtures/` | respostas gravadas do Ollama e do wttr.in; os testes nunca usam rede |
